*&---------------------------------------------------------------------*
*& Class          : ZCL_PP_PFCST_UTIL
*& Title          : ZFORECAST Paints - year, quarter, period, conversions
*& Project        : KPMG                          Module: PP
*& Related FS     : CR-2C, Forecast-Template-Paints
*& Author         : Arnav Johri                   Date: 31.08.2026
*& Transport      : <TR>
*&---------------------------------------------------------------------*
*& DESCRIPTION
*&   Stateless helper class for the Paints forecast (package ZPP_PNT_FCST).
*&   The financial year runs April to March, so period 01 is April and
*&   period 12 is March, and the quarters are
*&     Q1 Apr-Jun   Q2 Jul-Sep   Q3 Oct-Dec   Q4 Jan-Mar
*&   The class also carries the quantity conversions (tonnage, kilolitre,
*&   value in crore), the plant configuration read from ZPPT_PNT_CFG, the
*&   forecast number from number range object ZPPPFCST, and the plant
*&   authorisation check on object ZPP_PFCST.
*&
*& CHANGE HISTORY
*&   31.08.2026  Arnav Johri  <TR>  Initial development
*&---------------------------------------------------------------------*
CLASS zcl_pp_pfcst_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_daterange,
             date_from TYPE dats,
             date_to   TYPE dats,
           END OF ty_daterange.

    "! True when the financial year reads YYYY-YYYY and the second year
    "! is the first year plus one, for example 2026-2027.
    CLASS-METHODS is_fyear_valid
      IMPORTING iv_fyear        TYPE zde_pnt_fyear
      RETURNING VALUE(rv_valid) TYPE abap_bool.

    "! 2026-2027 gives 01.04.2026 to 31.03.2027.
    CLASS-METHODS get_fyear_range
      IMPORTING iv_fyear        TYPE zde_pnt_fyear
      RETURNING VALUE(rs_range) TYPE ty_daterange.

    "! Financial year a calendar date falls in, April to March.
    CLASS-METHODS get_fyear_from_date
      IMPORTING iv_date         TYPE dats
      RETURNING VALUE(rv_fyear) TYPE zde_pnt_fyear.

    "! Q1 Apr-Jun, Q2 Jul-Sep, Q3 Oct-Dec, Q4 Jan-Mar of the second year.
    CLASS-METHODS get_quarter_range
      IMPORTING iv_fyear        TYPE zde_pnt_fyear
                iv_quarter      TYPE zde_pnt_quarter
      RETURNING VALUE(rs_range) TYPE ty_daterange.

    "! Fiscal quarter a calendar date falls in.
    CLASS-METHODS get_quarter_from_date
      IMPORTING iv_date           TYPE dats
      RETURNING VALUE(rv_quarter) TYPE zde_pnt_quarter.

    "! First and last calendar date of one financial period, 1 = April.
    CLASS-METHODS get_period_range
      IMPORTING iv_fyear        TYPE zde_pnt_fyear
                iv_period       TYPE poper
      RETURNING VALUE(rs_range) TYPE ty_daterange.

    "! Move a date range by whole years, keeping day and month.
    CLASS-METHODS shift_range_years
      IMPORTING is_range        TYPE ty_daterange
                iv_years        TYPE i
      RETURNING VALUE(rs_range) TYPE ty_daterange.

    "! Month slot of a date in the forecast tables: 1 = April .. 12 = March.
    CLASS-METHODS get_month_slot
      IMPORTING iv_date        TYPE dats
      RETURNING VALUE(rv_slot) TYPE i.

    "! Tonnage from quantity and gross weight, kilogram based.
    CLASS-METHODS to_tonnage
      IMPORTING iv_qty        TYPE zde_pnt_fcst_qty
                iv_brgew      TYPE brgew
      RETURNING VALUE(rv_ton) TYPE zde_pnt_fcst_qty.

    "! Volume in kilolitre from quantity and pack size in litre.
    CLASS-METHODS to_volume_kl
      IMPORTING iv_qty       TYPE zde_pnt_fcst_qty
                iv_pack_sz   TYPE zde_pnt_pack_sz
      RETURNING VALUE(rv_kl) TYPE zde_pnt_vol_kl.

    "! Value in crore from quantity and dealer price list rate.
    CLASS-METHODS to_value_cr
      IMPORTING iv_qty       TYPE zde_pnt_fcst_qty
                iv_dpl       TYPE zde_pnt_dpl
      RETURNING VALUE(rv_cr) TYPE zde_pnt_val_cr.

    "! Plant configuration. Message 006 as E when the plant is not set up.
    CLASS-METHODS get_config
      IMPORTING iv_werks      TYPE werks_d
      RETURNING VALUE(rs_cfg) TYPE zppt_pnt_cfg.

    "! Next forecast number. The number range interval is the last two
    "! digits of the first year of the financial year: 2026-2027 gives 26.
    CLASS-METHODS get_next_fcst_no
      IMPORTING iv_fyear          TYPE zde_pnt_fyear
      RETURNING VALUE(rv_fcst_no) TYPE zde_pnt_fcst_no.

    "! Authorisation object ZPP_PFCST, fields WERKS and ACTVT.
    CLASS-METHODS check_plant_auth
      IMPORTING iv_werks     TYPE werks_d
                iv_actvt     TYPE activ_auth
      RETURNING VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.

    CONSTANTS gc_nr_object   TYPE inri-object VALUE 'ZPPPFCST'.
    CONSTANTS gc_kg_per_ton  TYPE i VALUE 1000.
    CONSTANTS gc_ltr_per_kl  TYPE i VALUE 1000.
    CONSTANTS gc_per_crore   TYPE i VALUE 10000000.

    "! Split a valid financial year into its two calendar years.
    CLASS-METHODS split_fyear
      IMPORTING iv_fyear     TYPE zde_pnt_fyear
      EXPORTING ev_year_from TYPE gjahr
                ev_year_to   TYPE gjahr
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    CLASS-METHODS last_day
      IMPORTING iv_date        TYPE dats
      RETURNING VALUE(rv_date) TYPE dats.

    "! Add whole years to a date. 29 February moves to 28 February when
    "! the target year is not a leap year, so the date stays valid.
    CLASS-METHODS add_years
      IMPORTING iv_date        TYPE dats
                iv_years       TYPE i
      RETURNING VALUE(rv_date) TYPE dats.

ENDCLASS.


CLASS zcl_pp_pfcst_util IMPLEMENTATION.

  METHOD is_fyear_valid.

    " Expected pattern is YYYY-YYYY with the second year one higher
    IF strlen( iv_fyear ) <> 9 OR iv_fyear+4(1) <> '-'.
      RETURN.
    ENDIF.

    TRY.
        DATA(lv_from) = CONV i( iv_fyear(4) ).
        DATA(lv_to)   = CONV i( iv_fyear+5(4) ).
      CATCH cx_sy_conversion_no_number.
        RETURN.
    ENDTRY.

    IF lv_to = lv_from + 1.
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD split_fyear.

    CLEAR: ev_year_from, ev_year_to.

    IF is_fyear_valid( iv_fyear ) = abap_false.
      RETURN.
    ENDIF.

    ev_year_from = iv_fyear(4).
    ev_year_to   = iv_fyear+5(4).
    rv_ok        = abap_true.

  ENDMETHOD.


  METHOD get_fyear_range.

    CLEAR rs_range.

    " An invalid financial year yields an empty range. The callers
    " validate with IS_FYEAR_VALID and issue message 002 themselves.
    split_fyear( EXPORTING iv_fyear     = iv_fyear
                 IMPORTING ev_year_from = DATA(lv_from)
                           ev_year_to   = DATA(lv_to) ).

    CHECK lv_from IS NOT INITIAL.

    rs_range-date_from = |{ lv_from }0401|.
    rs_range-date_to   = |{ lv_to }0331|.

  ENDMETHOD.


  METHOD get_fyear_from_date.

    CLEAR rv_fyear.

    CHECK iv_date IS NOT INITIAL.

    DATA(lv_year)  = CONV i( iv_date(4) ).
    DATA(lv_month) = CONV i( iv_date+4(2) ).

    " April onwards belongs to the year that starts the financial year,
    " January to March belongs to the one before it
    IF lv_month < 4.
      lv_year = lv_year - 1.
    ENDIF.

    rv_fyear = |{ lv_year }-{ lv_year + 1 }|.

  ENDMETHOD.


  METHOD get_quarter_range.

    CLEAR rs_range.

    DATA(lv_quarter) = CONV i( iv_quarter ).

    IF lv_quarter < 1 OR lv_quarter > 4.
      RETURN.
    ENDIF.

    " Q1 covers periods 1 to 3, Q2 periods 4 to 6, and so on
    DATA(lv_first) = CONV poper( ( lv_quarter - 1 ) * 3 + 1 ).
    DATA(lv_last)  = CONV poper( lv_quarter * 3 ).

    DATA(ls_first) = get_period_range( iv_fyear  = iv_fyear
                                       iv_period = lv_first ).

    DATA(ls_last)  = get_period_range( iv_fyear  = iv_fyear
                                       iv_period = lv_last ).

    rs_range-date_from = ls_first-date_from.
    rs_range-date_to   = ls_last-date_to.

  ENDMETHOD.


  METHOD get_quarter_from_date.

    CLEAR rv_quarter.

    DATA(lv_slot) = get_month_slot( iv_date ).

    CHECK lv_slot > 0.

    rv_quarter = ( ( lv_slot - 1 ) DIV 3 ) + 1.

  ENDMETHOD.


  METHOD get_period_range.

    CLEAR rs_range.

    DATA(lv_period) = CONV i( iv_period ).

    IF lv_period < 1 OR lv_period > 12.
      RETURN.
    ENDIF.

    split_fyear( EXPORTING iv_fyear     = iv_fyear
                 IMPORTING ev_year_from = DATA(lv_from)
                           ev_year_to   = DATA(lv_to) ).

    CHECK lv_from IS NOT INITIAL.

    " Periods 1 to 9 are April to December of the first calendar year,
    " periods 10 to 12 are January to March of the second
    DATA(lv_month) = COND i( WHEN lv_period <= 9 THEN lv_period + 3
                                                 ELSE lv_period - 9 ).

    DATA(lv_year)  = COND gjahr( WHEN lv_period <= 9 THEN lv_from
                                                     ELSE lv_to ).

    rs_range-date_from = |{ lv_year }{ lv_month WIDTH = 2 PAD = '0' ALIGN = RIGHT }01|.
    rs_range-date_to   = last_day( rs_range-date_from ).

  ENDMETHOD.


  METHOD shift_range_years.

    CLEAR rs_range.

    IF is_range-date_from IS NOT INITIAL.
      rs_range-date_from = add_years( iv_date  = is_range-date_from
                                      iv_years = iv_years ).
    ENDIF.

    IF is_range-date_to IS NOT INITIAL.
      rs_range-date_to = add_years( iv_date  = is_range-date_to
                                    iv_years = iv_years ).
    ENDIF.

  ENDMETHOD.


  METHOD get_month_slot.

    CLEAR rv_slot.

    CHECK iv_date IS NOT INITIAL.

    DATA(lv_month) = CONV i( iv_date+4(2) ).

    IF lv_month < 1 OR lv_month > 12.
      RETURN.
    ENDIF.

    " April is slot 1 and March is slot 12
    rv_slot = COND i( WHEN lv_month >= 4 THEN lv_month - 3
                                         ELSE lv_month + 9 ).

  ENDMETHOD.


  METHOD to_tonnage.

    CLEAR rv_ton.

    " The divisor is a constant, but it is still guarded so that no
    " division in this class can run against a zero denominator
    CHECK gc_kg_per_ton IS NOT INITIAL.

    rv_ton = iv_qty * iv_brgew / gc_kg_per_ton.

  ENDMETHOD.


  METHOD to_volume_kl.

    CLEAR rv_kl.

    CHECK gc_ltr_per_kl IS NOT INITIAL.

    rv_kl = iv_qty * iv_pack_sz / gc_ltr_per_kl.

  ENDMETHOD.


  METHOD to_value_cr.

    CLEAR rv_cr.

    CHECK gc_per_crore IS NOT INITIAL.

    rv_cr = iv_qty * iv_dpl / gc_per_crore.

  ENDMETHOD.


  METHOD get_config.

    CLEAR rs_cfg.

    SELECT SINGLE * FROM zppt_pnt_cfg INTO @rs_cfg
      WHERE werks = @iv_werks.

    IF sy-subrc <> 0.
      " VKORG and BWART are configuration, never literals in the code,
      " so there is no fallback here - the user is told to maintain it
      CLEAR rs_cfg.
      MESSAGE e006(zpp_pfcst) WITH iv_werks.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD get_next_fcst_no.

    DATA lv_number   TYPE inri-nrlevel.
    DATA lv_range_nr TYPE inri-nrrangenr.
    DATA lv_value    TYPE p LENGTH 8.

    CLEAR rv_fcst_no.

    IF is_fyear_valid( iv_fyear ) = abap_false.
      MESSAGE e002(zpp_pfcst) WITH iv_fyear.
      RETURN.
    ENDIF.

    " One interval per financial year, named after the last two digits
    " of its first year: 2026-2027 uses interval 26
    lv_range_nr = iv_fyear+2(2).

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING  nr_range_nr             = lv_range_nr
                 object                  = gc_nr_object
                 quantity                = '1'
      IMPORTING  number                  = lv_number
      EXCEPTIONS interval_not_found      = 1
                 number_range_not_intern = 2
                 object_not_found        = 3
                 quantity_is_0           = 4
                 quantity_is_not_1       = 5
                 interval_overflow       = 6
                 buffer_overflow         = 7
                 OTHERS                  = 8.

    IF sy-subrc <> 0 OR lv_number IS INITIAL.
      MESSAGE e021(zpp_pfcst).
      RETURN.
    ENDIF.

    " NRLEVEL is twenty characters wide, so the number is taken over as a
    " value and padded to ten - a plain move would cut off the right hand
    " digits instead of the leading zeros
    TRY.
        lv_value   = lv_number.
        rv_fcst_no = |{ lv_value WIDTH = 10 PAD = '0' ALIGN = RIGHT }|.
      CATCH cx_sy_conversion_no_number.
        " ASSUMPTION: interval 'NN' of ZPPPFCST is numeric. A non numeric
        " number is passed on unchanged rather than dumping.
        CONDENSE lv_number.
        rv_fcst_no = lv_number.
    ENDTRY.

  ENDMETHOD.


  METHOD check_plant_auth.

    rv_ok = abap_true.

    AUTHORITY-CHECK OBJECT 'ZPP_PFCST'
      ID 'WERKS' FIELD iv_werks
      ID 'ACTVT' FIELD iv_actvt.

    IF sy-subrc <> 0.
      rv_ok = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD last_day.

    rv_date = iv_date.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING  day_in            = iv_date
      IMPORTING  last_day_of_month = rv_date
      EXCEPTIONS OTHERS            = 1.

  ENDMETHOD.


  METHOD add_years.

    DATA lv_mmdd TYPE c LENGTH 4.

    rv_date = iv_date.

    CHECK iv_date IS NOT INITIAL.

    DATA(lv_year) = CONV i( iv_date(4) ) + iv_years.
    lv_mmdd       = iv_date+4(4).

    " 29 February only exists in a leap year
    IF lv_mmdd = '0229'.
      DATA(lv_leap) = xsdbool(     lv_year MOD 4 = 0
                               AND (    lv_year MOD 100 <> 0
                                     OR lv_year MOD 400 = 0 ) ).
      IF lv_leap = abap_false.
        lv_mmdd = '0228'.
      ENDIF.
    ENDIF.

    rv_date = |{ lv_year WIDTH = 4 PAD = '0' ALIGN = RIGHT }{ lv_mmdd }|.

  ENDMETHOD.

ENDCLASS.
