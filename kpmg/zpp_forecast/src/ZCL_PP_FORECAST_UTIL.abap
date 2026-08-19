*&---------------------------------------------------------------------*
*& Class         ZCL_PP_FORECAST_UTIL
*& Package       ZPP_FORECAST
*& Description   ZFORECAST (Adhesive) - financial year, quarter, period
*&               and tonnage helpers.
*&
*& Created by    Arnav Johri
*& Reference     WRICEF ID-2A Forecast Template-Adhesive.xlsx, 14.08.2026
*&               Assumptions B04 - B07, B35, B36
*&
*& Financial year is April to March (B04). Period 01 = April, 12 = March.
*& Quarters: Q1 Apr-Jun, Q2 Jul-Sep, Q3 Oct-Dec, Q4 Jan-Mar (B05).
*&---------------------------------------------------------------------*
CLASS zcl_pp_forecast_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_period,
             gjahr  TYPE gjahr,          "calendar year
             month  TYPE numc2,          "calendar month 01-12
             period TYPE numc2,          "financial period 01 = April
           END OF ty_period,
           tt_period TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    CONSTANTS: gc_msgid TYPE symsgid VALUE 'ZPP_FORECAST'.

    "! Split "2026-2027" into its two calendar years.
    CLASS-METHODS split_fyear
      IMPORTING iv_fyear     TYPE zde_fyear
      EXPORTING ev_year_from TYPE gjahr
                ev_year_to   TYPE gjahr
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    "! Previous financial year, e.g. 2026-2027 -> 2025-2026 (B06).
    CLASS-METHODS previous_fyear
      IMPORTING iv_fyear      TYPE zde_fyear
      RETURNING VALUE(rv_prev) TYPE zde_fyear.

    "! First and last calendar date of a financial year.
    CLASS-METHODS fyear_dates
      IMPORTING iv_fyear TYPE zde_fyear
      EXPORTING ev_from  TYPE dats
                ev_to    TYPE dats.

    "! Financial period (01 = April) for a calendar month.
    CLASS-METHODS month_to_period
      IMPORTING iv_month         TYPE numc2
      RETURNING VALUE(rv_period) TYPE numc2.

    "! Calendar month for a financial period.
    CLASS-METHODS period_to_month
      IMPORTING iv_period       TYPE numc2
      RETURNING VALUE(rv_month) TYPE numc2.

    "! Calendar year and month of a financial period within a year.
    CLASS-METHODS period_to_yearmonth
      IMPORTING iv_fyear  TYPE zde_fyear
                iv_period TYPE numc2
      EXPORTING ev_gjahr  TYPE gjahr
                ev_month  TYPE numc2.

    "! The three financial periods of a quarter (B05).
    CLASS-METHODS quarter_periods
      IMPORTING iv_quarter    TYPE zde_quarter
      RETURNING VALUE(rt_per) TYPE tt_period.

    "! Quarter that a financial period falls into.
    CLASS-METHODS period_to_quarter
      IMPORTING iv_period         TYPE numc2
      RETURNING VALUE(rv_quarter) TYPE zde_quarter.

    "! The three calendar months immediately before the first month of the
    "! forecast quarter (B07). For Q1 these fall into the previous
    "! financial year - see Query Q6.
    CLASS-METHODS last_three_months
      IMPORTING iv_fyear      TYPE zde_fyear
                iv_period     TYPE numc2
      RETURNING VALUE(rt_per) TYPE tt_period.

    "! The three calendar months of the same quarter one year earlier.
    CLASS-METHODS last_year_quarter
      IMPORTING iv_fyear      TYPE zde_fyear
                iv_quarter    TYPE zde_quarter
      RETURNING VALUE(rt_per) TYPE tt_period.

    "! Quantity converted to tonnes using net or gross weight (B35, B36).
    CLASS-METHODS to_tonnage
      IMPORTING iv_matnr      TYPE matnr
                iv_qty        TYPE zde_fcst_qty
                iv_gross      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_ton) TYPE zde_fcst_qty.

    CLASS-METHODS check_authority
      IMPORTING iv_werks     TYPE werks_d
                iv_actvt     TYPE activ_auth
      RETURNING VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_pp_forecast_util IMPLEMENTATION.

*&---------------------------------------------------------------------*
  METHOD split_fyear.

    CLEAR: ev_year_from, ev_year_to.

    " Expected format YYYY-YYYY, e.g. 2026-2027
    IF strlen( iv_fyear ) <> 9 OR iv_fyear+4(1) <> '-'.
      RETURN.
    ENDIF.

    TRY.
        ev_year_from = iv_fyear(4).
        ev_year_to   = iv_fyear+5(4).
      CATCH cx_sy_conversion_no_number.
        RETURN.
    ENDTRY.

    IF ev_year_to <> ev_year_from + 1.
      CLEAR: ev_year_from, ev_year_to.
      RETURN.
    ENDIF.

    rv_ok = abap_true.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD previous_fyear.

    split_fyear( EXPORTING iv_fyear     = iv_fyear
                 IMPORTING ev_year_from = DATA(lv_from) ).

    CHECK lv_from IS NOT INITIAL.

    rv_prev = |{ lv_from - 1 }-{ lv_from }|.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD fyear_dates.

    CLEAR: ev_from, ev_to.

    split_fyear( EXPORTING iv_fyear     = iv_fyear
                 IMPORTING ev_year_from = DATA(lv_from)
                           ev_year_to   = DATA(lv_to) ).

    CHECK lv_from IS NOT INITIAL.

    ev_from = |{ lv_from }0401|.
    ev_to   = |{ lv_to }0331|.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD month_to_period.

    " April (04) = period 01 ... March (03) = period 12
    DATA(lv_m) = CONV i( iv_month ).

    rv_period = COND numc2( WHEN lv_m >= 4 THEN lv_m - 3
                            ELSE                lv_m + 9 ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD period_to_month.

    DATA(lv_p) = CONV i( iv_period ).

    rv_month = COND numc2( WHEN lv_p <= 9 THEN lv_p + 3
                           ELSE                lv_p - 9 ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD period_to_yearmonth.

    CLEAR: ev_gjahr, ev_month.

    split_fyear( EXPORTING iv_fyear     = iv_fyear
                 IMPORTING ev_year_from = DATA(lv_from)
                           ev_year_to   = DATA(lv_to) ).

    CHECK lv_from IS NOT INITIAL.

    ev_month = period_to_month( iv_period ).

    " Periods 01-09 are April to December of the first calendar year,
    " periods 10-12 are January to March of the second.
    ev_gjahr = COND gjahr( WHEN iv_period <= 9 THEN lv_from ELSE lv_to ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD quarter_periods.

    DATA(lv_first) = ( CONV i( iv_quarter ) - 1 ) * 3 + 1.

    DO 3 TIMES.
      DATA(lv_period) = CONV numc2( lv_first + sy-index - 1 ).
      APPEND VALUE #( period = lv_period
                      month  = period_to_month( lv_period ) ) TO rt_per.
    ENDDO.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD period_to_quarter.

    rv_quarter = ( ( CONV i( iv_period ) - 1 ) DIV 3 ) + 1.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Three calendar months immediately preceding iv_period (B07).
*& Walks backwards in real calendar terms, so a Q1 forecast correctly
*& lands in January-March of the previous financial year (Q6).
*&---------------------------------------------------------------------*
  METHOD last_three_months.

    period_to_yearmonth( EXPORTING iv_fyear  = iv_fyear
                                   iv_period = iv_period
                         IMPORTING ev_gjahr  = DATA(lv_year)
                                   ev_month  = DATA(lv_month) ).

    CHECK lv_year IS NOT INITIAL.

    DATA(lv_y) = CONV i( lv_year ).
    DATA(lv_m) = CONV i( lv_month ).

    DO 3 TIMES.
      lv_m = lv_m - 1.
      IF lv_m = 0.
        lv_m = 12.
        lv_y = lv_y - 1.
      ENDIF.
      INSERT VALUE #( gjahr  = lv_y
                      month  = lv_m
                      period = month_to_period( CONV #( lv_m ) ) )
        INTO rt_per INDEX 1.
    ENDDO.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD last_year_quarter.

    DATA(lv_prev) = previous_fyear( iv_fyear ).

    LOOP AT quarter_periods( iv_quarter ) INTO DATA(ls_per).
      period_to_yearmonth( EXPORTING iv_fyear  = lv_prev
                                     iv_period = ls_per-period
                           IMPORTING ev_gjahr  = ls_per-gjahr
                                     ev_month  = ls_per-month ).
      APPEND ls_per TO rt_per.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Tonnage (B35, B36). Display only - the stored forecast is always in
*& the material base unit of measure.
*&---------------------------------------------------------------------*
  METHOD to_tonnage.

    SELECT SINGLE ntgew, brgew, gewei FROM mara
      INTO @DATA(ls_mara)
      WHERE matnr = @iv_matnr.

    CHECK sy-subrc = 0.

    DATA(lv_weight) = COND brgew( WHEN iv_gross = abap_true
                                  THEN ls_mara-brgew ELSE ls_mara-ntgew ).

    CHECK lv_weight IS NOT INITIAL AND ls_mara-gewei IS NOT INITIAL.

    DATA(lv_total) = CONV f( iv_qty * lv_weight ).

    " Weight unit of the material master converted to tonnes
    IF ls_mara-gewei = 'TO'.
      rv_ton = lv_total.
    ELSE.
      CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
        EXPORTING  input                = CONV f( lv_total )
                   unit_in              = ls_mara-gewei
                   unit_out             = 'TO'
        IMPORTING  output               = rv_ton
        EXCEPTIONS conversion_not_found = 1
                   OTHERS               = 2.
      IF sy-subrc <> 0.
        CLEAR rv_ton.
      ENDIF.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD check_authority.

    rv_ok = abap_true.

    AUTHORITY-CHECK OBJECT 'ZPP_FCST'
      ID 'WERKS' FIELD iv_werks
      ID 'ACTVT' FIELD iv_actvt.

    IF sy-subrc <> 0.
      rv_ok = abap_false.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
