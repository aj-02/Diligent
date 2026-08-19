*&---------------------------------------------------------------------*
*& Class         ZCL_PP_FORECAST
*& Package       ZPP_FORECAST
*& Description   ZFORECAST (Adhesive) - calculation engine.
*&               Sales history, annual / quarterly / monthly forecast,
*&               save and delete. Shared by ZPP_FORECAST,
*&               ZPP_FORECAST_REPORT and ZPP_FORECAST_UPLOAD so the three
*&               can never diverge (B42).
*&
*& Created by    Arnav Johri
*& Reference     WRICEF ID-2A Forecast Template-Adhesive.xlsx, 14.08.2026
*&
*& Formulae (all reconciled against the worked example in the BRD)
*&   Annual     FCST_TOTAL = LY_TOTAL x LOAD_FCT              (B13)
*&              M(n)       = LY month(n) x LOAD_FCT           (B14)
*&   Quarterly  BASE_QTY   = max( LY quarter , last 3 months ) (B16)
*&              FCST_QTY   = BASE_QTY x LOAD_FCT              (B17)
*&              FINAL_QTY  = max( FCST_QTY , BUS_FCST )       (B18)
*&              MTH(n)     = FINAL_QTY x LY month(n) / LY qtr (B20)
*&   Monthly    L3M_AVG    = last 3 months / 3                (B22)
*&              REQ_QTY    = max( LY month , L3M_AVG x LOAD ) (B23)
*&              FINAL_QTY  = max( REQ_QTY , BUS_FCST )        (B24)
*&   All modes  TOTAL_QTY  = FINAL_QTY + adjustment (signed)  (B25, B26)
*&---------------------------------------------------------------------*
CLASS zcl_pp_forecast DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: tt_alv   TYPE STANDARD TABLE OF zpps_fcst_alv WITH DEFAULT KEY,
           tr_werks TYPE RANGE OF werks_d,
           tr_matnr TYPE RANGE OF matnr.

    TYPES: BEGIN OF ty_hist,
             werks TYPE werks_d,
             matnr TYPE matnr,
             gjahr TYPE gjahr,
             month TYPE numc2,
             qty   TYPE zde_fcst_qty,
             meins TYPE meins,
           END OF ty_hist,
           tt_hist TYPE SORTED TABLE OF ty_hist
                     WITH UNIQUE KEY werks matnr gjahr month.

    CONSTANTS: BEGIN OF gc_type,
                 annual    TYPE zde_fcst_type VALUE 'A',
                 quarterly TYPE zde_fcst_type VALUE 'Q',
                 monthly   TYPE zde_fcst_type VALUE 'M',
               END OF gc_type,
               gc_msgid TYPE symsgid VALUE 'ZPP_FORECAST'.

    "! Annual forecast (BRD 1.1)
    METHODS generate_annual
      IMPORTING ir_werks TYPE tr_werks
                ir_matnr TYPE tr_matnr
                iv_fyear TYPE zde_fyear
      EXPORTING et_alv   TYPE tt_alv
                et_msg   TYPE bapiret2_t.

    "! Quarterly forecast (BRD 1.2)
    METHODS generate_quarterly
      IMPORTING ir_werks   TYPE tr_werks
                ir_matnr   TYPE tr_matnr
                iv_fyear   TYPE zde_fyear
                iv_quarter TYPE zde_quarter
      EXPORTING et_alv     TYPE tt_alv
                et_msg     TYPE bapiret2_t.

    "! Monthly forecast (BRD 1.3)
    METHODS generate_monthly
      IMPORTING ir_werks  TYPE tr_werks
                ir_matnr  TYPE tr_matnr
                iv_fyear  TYPE zde_fyear
                iv_period TYPE numc2
      EXPORTING et_alv    TYPE tt_alv
                et_msg    TYPE bapiret2_t.

    "! Save. Draws one forecast number for the whole run (B31) and
    "! stamps it on every line saved.
    METHODS save
      IMPORTING iv_type       TYPE zde_fcst_type
      CHANGING  ct_alv        TYPE tt_alv
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    "! Delete a saved forecast so it can be regenerated (B33, Q7).
    METHODS delete
      IMPORTING iv_type       TYPE zde_fcst_type
                it_alv        TYPE tt_alv
      RETURNING VALUE(rt_msg) TYPE bapiret2_t.

    "! Monthly sales history. Reads the uploaded history table for
    "! periods before go-live and VBRK / VBRP after it (B08, B12).
    METHODS read_history
      IMPORTING ir_werks       TYPE tr_werks
                ir_matnr       TYPE tr_matnr
                iv_from        TYPE dats
                iv_to          TYPE dats
      RETURNING VALUE(rt_hist) TYPE tt_hist.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_scope,
             werks TYPE werks_d,
             matnr TYPE matnr,
           END OF ty_scope,
           tt_scope TYPE SORTED TABLE OF ty_scope WITH UNIQUE KEY werks matnr.

    DATA: mt_hist TYPE tt_hist.

    "! Materials to forecast: everything with sales history in the base
    "! period, plus everything with a product category maintained, less
    "! the exclusion table (B30).
    METHODS build_scope
      IMPORTING ir_werks        TYPE tr_werks
                ir_matnr        TYPE tr_matnr
                it_hist         TYPE tt_hist
      RETURNING VALUE(rt_scope) TYPE tt_scope.

    METHODS fill_master_data
      CHANGING cs_alv TYPE zpps_fcst_alv.

    METHODS get_prod_cat
      IMPORTING iv_werks      TYPE werks_d
                iv_matnr      TYPE matnr
      RETURNING VALUE(rv_cat) TYPE zde_prod_cat.

    "! Load factor for the category. QUARTER = 0 is the annual default (B28).
    METHODS get_load_factor
      IMPORTING iv_werks      TYPE werks_d
                iv_cat        TYPE zde_prod_cat
                iv_fyear      TYPE zde_fyear
                iv_quarter    TYPE zde_quarter DEFAULT 0
      RETURNING VALUE(rv_fct) TYPE zde_load_fct.

    METHODS get_business_fcst
      IMPORTING iv_werks      TYPE werks_d
                iv_matnr      TYPE matnr
                iv_fyear      TYPE zde_fyear
                iv_type       TYPE zde_fcst_type
                iv_period     TYPE numc2
      RETURNING VALUE(rv_qty) TYPE zde_fcst_qty.

    METHODS get_adjustment
      IMPORTING iv_werks      TYPE werks_d
                iv_matnr      TYPE matnr
                iv_fyear      TYPE zde_fyear
                iv_type       TYPE zde_fcst_type
                iv_period     TYPE numc2
      RETURNING VALUE(rv_qty) TYPE zde_fcst_qty.

    METHODS hist_qty
      IMPORTING iv_werks      TYPE werks_d
                iv_matnr      TYPE matnr
                iv_gjahr      TYPE gjahr
                iv_month      TYPE numc2
      RETURNING VALUE(rv_qty) TYPE zde_fcst_qty.

    METHODS annual_exists
      IMPORTING iv_werks         TYPE werks_d
                iv_matnr         TYPE matnr
                iv_fyear         TYPE zde_fyear
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS number_get
      RETURNING VALUE(rv_no) TYPE zde_fcst_no.

    METHODS add_msg
      IMPORTING iv_type   TYPE bapi_mtype DEFAULT 'E'
                iv_number TYPE symsgno
                iv_v1     TYPE any OPTIONAL
                iv_v2     TYPE any OPTIONAL
                iv_v3     TYPE any OPTIONAL
                iv_v4     TYPE any OPTIONAL
      CHANGING  ct_msg    TYPE bapiret2_t.

ENDCLASS.


CLASS zcl_pp_forecast IMPLEMENTATION.

*&---------------------------------------------------------------------*
*& Sales history (B08 - B12)
*&---------------------------------------------------------------------*
  METHOD read_history.

    DATA: lt_raw TYPE STANDARD TABLE OF ty_hist.

    " Go-live cut-off: before it the uploaded history table is the source,
    " after it the live billing documents are (B12, Q5)
    SELECT SINGLE golive_dt FROM zppt_fcst_cfg INTO @DATA(lv_golive)
      WHERE werks IN @ir_werks.

    "--- uploaded history ------------------------------------------------
    IF lv_golive IS INITIAL OR iv_from < lv_golive.

      DATA(lv_hist_to) = COND dats( WHEN lv_golive IS INITIAL OR lv_golive > iv_to
                                    THEN iv_to ELSE lv_golive - 1 ).

      SELECT werks, matnr, gjahr, period, sls_qty, meins
        FROM zppt_sls_hist
        INTO TABLE @DATA(lt_upl)
        WHERE werks IN @ir_werks
          AND matnr IN @ir_matnr.

      LOOP AT lt_upl INTO DATA(ls_upl).

        " The history table is keyed on financial period; convert back to
        " a calendar year and month so both sources are comparable
        DATA(lv_month) = zcl_pp_forecast_util=>period_to_month( ls_upl-period ).
        DATA(lv_date)  = CONV dats( |{ ls_upl-gjahr }{ lv_month }01| ).

        CHECK lv_date >= iv_from AND lv_date <= lv_hist_to.

        APPEND VALUE ty_hist( werks = ls_upl-werks
                              matnr = ls_upl-matnr
                              gjahr = ls_upl-gjahr
                              month = lv_month
                              qty   = ls_upl-sls_qty
                              meins = ls_upl-meins ) TO lt_raw.
      ENDLOOP.

    ENDIF.

    "--- live billing documents ------------------------------------------
    IF lv_golive IS INITIAL OR iv_to >= lv_golive.

      DATA(lv_bill_fr) = COND dats( WHEN lv_golive IS INITIAL OR lv_golive < iv_from
                                    THEN iv_from ELSE lv_golive ).

      " Billing types that count as normal, direct sales (B09, B10, Q4)
      SELECT fkart FROM zppt_fcst_cfg INTO TABLE @DATA(lt_fkart)
        WHERE werks IN @ir_werks.

      IF lt_fkart IS NOT INITIAL.

        DATA lr_fkart TYPE RANGE OF fkart.
        lr_fkart = VALUE #( FOR ls IN lt_fkart
                            ( sign = 'I' option = 'EQ' low = ls-fkart ) ).
        SORT lr_fkart BY low.
        DELETE ADJACENT DUPLICATES FROM lr_fkart COMPARING low.

        SELECT p~werks, p~matnr, k~fkdat, p~fkimg, p~vrkme, p~meins
          FROM vbrk AS k
          INNER JOIN vbrp AS p ON p~vbeln = k~vbeln
          INTO TABLE @DATA(lt_bill)
          WHERE k~fkdat BETWEEN @lv_bill_fr AND @iv_to
            AND k~fksto  = @space
            AND k~rfbsk  = 'C'
            AND k~fkart IN @lr_fkart
            AND p~werks IN @ir_werks
            AND p~matnr IN @ir_matnr.

        LOOP AT lt_bill INTO DATA(ls_bill).

          " Base unit of measure (B11)
          DATA(lv_qty) = CONV zde_fcst_qty( ls_bill-fkimg ).
          IF ls_bill-vrkme <> ls_bill-meins AND lv_qty <> 0.
            CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
              EXPORTING  i_matnr              = ls_bill-matnr
                         i_in_me              = ls_bill-vrkme
                         i_out_me             = ls_bill-meins
                         i_menge              = lv_qty
              IMPORTING  e_menge              = lv_qty
              EXCEPTIONS error_in_application = 1
                         error                = 2
                         OTHERS               = 3.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
          ENDIF.

          APPEND VALUE ty_hist( werks = ls_bill-werks
                                matnr = ls_bill-matnr
                                gjahr = ls_bill-fkdat(4)
                                month = ls_bill-fkdat+4(2)
                                qty   = lv_qty
                                meins = ls_bill-meins ) TO lt_raw.
        ENDLOOP.

      ENDIF.
    ENDIF.

    "--- aggregate to plant / material / year / month ---------------------
    LOOP AT lt_raw INTO DATA(ls_raw).
      READ TABLE rt_hist ASSIGNING FIELD-SYMBOL(<ls_h>)
        WITH TABLE KEY werks = ls_raw-werks matnr = ls_raw-matnr
                       gjahr = ls_raw-gjahr month = ls_raw-month.
      IF sy-subrc <> 0.
        INSERT ls_raw INTO TABLE rt_hist.
      ELSE.
        <ls_h>-qty = <ls_h>-qty + ls_raw-qty.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Annual forecast (BRD 1.1, B13 - B15)
*&---------------------------------------------------------------------*
  METHOD generate_annual.

    CLEAR: et_alv, et_msg.

    DATA(lv_prev) = zcl_pp_forecast_util=>previous_fyear( iv_fyear ).
    IF lv_prev IS INITIAL.
      add_msg( EXPORTING iv_number = 003 iv_v1 = iv_fyear CHANGING ct_msg = et_msg ).
      RETURN.
    ENDIF.

    zcl_pp_forecast_util=>fyear_dates( EXPORTING iv_fyear = lv_prev
                                       IMPORTING ev_from  = DATA(lv_from)
                                                 ev_to    = DATA(lv_to) ).

    mt_hist = read_history( ir_werks = ir_werks
                            ir_matnr = ir_matnr
                            iv_from  = lv_from
                            iv_to    = lv_to ).

    LOOP AT build_scope( ir_werks = ir_werks
                         ir_matnr = ir_matnr
                         it_hist  = mt_hist ) INTO DATA(ls_scope).

      DATA(ls_alv) = VALUE zpps_fcst_alv( werks     = ls_scope-werks
                                          matnr     = ls_scope-matnr
                                          fyear     = iv_fyear
                                          fcst_type = gc_type-annual ).

      fill_master_data( CHANGING cs_alv = ls_alv ).

      ls_alv-prod_cat = get_prod_cat( iv_werks = ls_scope-werks
                                      iv_matnr = ls_scope-matnr ).

      IF ls_alv-prod_cat IS INITIAL.
        ls_alv-message = |No product category maintained|.
        ls_alv-light   = '1'.
      ENDIF.

      ls_alv-load_fct = get_load_factor( iv_werks = ls_scope-werks
                                         iv_cat   = ls_alv-prod_cat
                                         iv_fyear = iv_fyear ).

      " Monthly split is last year month x load factor, not the annual
      " total divided by twelve (B14)
      DO 12 TIMES.
        DATA(lv_period) = CONV numc2( sy-index ).

        zcl_pp_forecast_util=>period_to_yearmonth(
          EXPORTING iv_fyear  = lv_prev
                    iv_period = lv_period
          IMPORTING ev_gjahr  = DATA(lv_gjahr)
                    ev_month  = DATA(lv_month) ).

        DATA(lv_ly) = hist_qty( iv_werks = ls_scope-werks
                                iv_matnr = ls_scope-matnr
                                iv_gjahr = lv_gjahr
                                iv_month = lv_month ).

        ASSIGN COMPONENT |LY{ lv_period }| OF STRUCTURE ls_alv TO FIELD-SYMBOL(<lv_lyf>).
        IF sy-subrc = 0. <lv_lyf> = lv_ly. ENDIF.

        ASSIGN COMPONENT |M{ lv_period }| OF STRUCTURE ls_alv TO FIELD-SYMBOL(<lv_mf>).
        IF sy-subrc = 0. <lv_mf> = lv_ly * ls_alv-load_fct. ENDIF.

        ls_alv-ly_total   = ls_alv-ly_total   + lv_ly.
        ls_alv-fcst_total = ls_alv-fcst_total + lv_ly * ls_alv-load_fct.
      ENDDO.

      ls_alv-final_qty = ls_alv-fcst_total.
      ls_alv-adj_qty   = get_adjustment( iv_werks  = ls_scope-werks
                                         iv_matnr  = ls_scope-matnr
                                         iv_fyear  = iv_fyear
                                         iv_type   = gc_type-annual
                                         iv_period = '00' ).
      ls_alv-total_qty = ls_alv-final_qty + ls_alv-adj_qty.

      " Already saved?
      IF annual_exists( iv_werks = ls_scope-werks
                        iv_matnr = ls_scope-matnr
                        iv_fyear = iv_fyear ) = abap_true.
        SELECT SINGLE fcst_no FROM zppt_fcst_yr INTO @ls_alv-fcst_no
          WHERE werks = @ls_scope-werks
            AND matnr = @ls_scope-matnr
            AND fyear = @iv_fyear.
        ls_alv-status  = 'S'.
        ls_alv-light   = '3'.
        ls_alv-message = |Already saved|.
      ELSEIF ls_alv-light IS INITIAL.
        ls_alv-light = '2'.
      ENDIF.

      APPEND ls_alv TO et_alv.

    ENDLOOP.

    IF et_alv IS INITIAL.
      add_msg( EXPORTING iv_type = 'I' iv_number = 009 CHANGING ct_msg = et_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Quarterly forecast (BRD 1.2, B16 - B21)
*&---------------------------------------------------------------------*
  METHOD generate_quarterly.

    CLEAR: et_alv, et_msg.

    " Periods making up the forecast quarter, the same quarter last year,
    " and the three calendar months immediately before it (B07)
    DATA(lt_qtr_per) = zcl_pp_forecast_util=>quarter_periods( iv_quarter ).
    DATA(lt_ly_per)  = zcl_pp_forecast_util=>last_year_quarter( iv_fyear   = iv_fyear
                                                                iv_quarter = iv_quarter ).
    DATA(lt_l3m)     = zcl_pp_forecast_util=>last_three_months(
                         iv_fyear  = iv_fyear
                         iv_period = VALUE #( lt_qtr_per[ 1 ]-period OPTIONAL ) ).

    " One history read spanning both windows
    DATA(lv_from) = CONV dats( |{ VALUE #( lt_ly_per[ 1 ]-gjahr ) }| &&
                               |{ VALUE #( lt_ly_per[ 1 ]-month ) }01| ).
    DATA(lv_to)   = CONV dats( |{ VALUE #( lt_l3m[ 3 ]-gjahr ) }| &&
                               |{ VALUE #( lt_l3m[ 3 ]-month ) }31| ).
    IF lv_to < lv_from.
      DATA(lv_swap) = lv_from. lv_from = lv_to. lv_to = lv_swap.
    ENDIF.

    mt_hist = read_history( ir_werks = ir_werks
                            ir_matnr = ir_matnr
                            iv_from  = lv_from
                            iv_to    = lv_to ).

    LOOP AT build_scope( ir_werks = ir_werks
                         ir_matnr = ir_matnr
                         it_hist  = mt_hist ) INTO DATA(ls_scope).

      " Annual forecast is a precondition for quarterly planning (B34)
      IF annual_exists( iv_werks = ls_scope-werks
                        iv_matnr = ls_scope-matnr
                        iv_fyear = iv_fyear ) = abap_false.
        add_msg( EXPORTING iv_number = 005
                           iv_v1 = ls_scope-werks iv_v2 = ls_scope-matnr iv_v3 = iv_fyear
                 CHANGING  ct_msg = et_msg ).
        CONTINUE.
      ENDIF.

      DATA(ls_alv) = VALUE zpps_fcst_alv( werks     = ls_scope-werks
                                          matnr     = ls_scope-matnr
                                          fyear     = iv_fyear
                                          quarter   = iv_quarter
                                          fcst_type = gc_type-quarterly ).

      fill_master_data( CHANGING cs_alv = ls_alv ).

      ls_alv-prod_cat = get_prod_cat( iv_werks = ls_scope-werks
                                      iv_matnr = ls_scope-matnr ).
      ls_alv-load_fct = get_load_factor( iv_werks   = ls_scope-werks
                                         iv_cat     = ls_alv-prod_cat
                                         iv_fyear   = iv_fyear
                                         iv_quarter = iv_quarter ).

      " Last year same quarter, month by month - the monthly figures are
      " kept because the split back to months is proportional to them (B20)
      DATA: lt_ly_month TYPE STANDARD TABLE OF zde_fcst_qty.
      CLEAR lt_ly_month.

      LOOP AT lt_ly_per INTO DATA(ls_ly).
        DATA(lv_q) = hist_qty( iv_werks = ls_scope-werks
                               iv_matnr = ls_scope-matnr
                               iv_gjahr = ls_ly-gjahr
                               iv_month = ls_ly-month ).
        APPEND lv_q TO lt_ly_month.
        ls_alv-ly_qtr_qty = ls_alv-ly_qtr_qty + lv_q.
      ENDLOOP.

      LOOP AT lt_l3m INTO DATA(ls_l3).
        ls_alv-l3m_qty = ls_alv-l3m_qty + hist_qty( iv_werks = ls_scope-werks
                                                    iv_matnr = ls_scope-matnr
                                                    iv_gjahr = ls_l3-gjahr
                                                    iv_month = ls_l3-month ).
      ENDLOOP.

      "--- B16 / B17 / B18 ------------------------------------------------
      ls_alv-base_qty = nmax( val1 = ls_alv-ly_qtr_qty val2 = ls_alv-l3m_qty ).
      ls_alv-fcst_qty = ls_alv-base_qty * ls_alv-load_fct.

      ls_alv-bus_fcst = get_business_fcst( iv_werks  = ls_scope-werks
                                           iv_matnr  = ls_scope-matnr
                                           iv_fyear  = iv_fyear
                                           iv_type   = gc_type-quarterly
                                           iv_period = CONV #( iv_quarter ) ).

      ls_alv-final_qty = nmax( val1 = ls_alv-fcst_qty val2 = ls_alv-bus_fcst ).

      "--- B20 / B21: split back into the three months ---------------------
      DO 3 TIMES.
        DATA(lv_idx) = sy-index.
        DATA(lv_share) = CONV zde_fcst_qty( 0 ).

        IF ls_alv-ly_qtr_qty > 0.
          lv_share = ls_alv-final_qty * VALUE zde_fcst_qty( lt_ly_month[ lv_idx ] )
                                      / ls_alv-ly_qtr_qty.
        ELSE.
          " No last year base to weight against - divide equally (B21)
          lv_share = ls_alv-final_qty / 3.
        ENDIF.

        ASSIGN COMPONENT |MTH{ lv_idx }| OF STRUCTURE ls_alv TO FIELD-SYMBOL(<lv_m>).
        IF sy-subrc = 0. <lv_m> = lv_share. ENDIF.
      ENDDO.

      ls_alv-adj_qty   = get_adjustment( iv_werks  = ls_scope-werks
                                         iv_matnr  = ls_scope-matnr
                                         iv_fyear  = iv_fyear
                                         iv_type   = gc_type-quarterly
                                         iv_period = CONV #( iv_quarter ) ).
      ls_alv-total_qty = ls_alv-final_qty + ls_alv-adj_qty.
      ls_alv-light     = '2'.

      SELECT SINGLE fcst_no FROM zppt_fcst_qt INTO @ls_alv-fcst_no
        WHERE werks = @ls_scope-werks AND matnr = @ls_scope-matnr
          AND fyear = @iv_fyear       AND quarter = @iv_quarter.
      IF sy-subrc = 0.
        ls_alv-status  = 'S'.
        ls_alv-light   = '3'.
        ls_alv-message = |Already saved|.
      ENDIF.

      APPEND ls_alv TO et_alv.

    ENDLOOP.

    IF et_alv IS INITIAL.
      add_msg( EXPORTING iv_type = 'I' iv_number = 009 CHANGING ct_msg = et_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Monthly forecast (BRD 1.3, B22 - B24)
*&---------------------------------------------------------------------*
  METHOD generate_monthly.

    CLEAR: et_alv, et_msg.

    DATA(lv_quarter) = zcl_pp_forecast_util=>period_to_quarter( iv_period ).
    DATA(lt_l3m)     = zcl_pp_forecast_util=>last_three_months( iv_fyear  = iv_fyear
                                                                iv_period = iv_period ).

    " Last year, same month
    DATA(lv_prev) = zcl_pp_forecast_util=>previous_fyear( iv_fyear ).
    zcl_pp_forecast_util=>period_to_yearmonth( EXPORTING iv_fyear  = lv_prev
                                                         iv_period = iv_period
                                               IMPORTING ev_gjahr  = DATA(lv_ly_year)
                                                         ev_month  = DATA(lv_ly_month) ).

    DATA(lv_from) = CONV dats( |{ lv_ly_year }{ lv_ly_month }01| ).
    DATA(lv_to)   = CONV dats( |{ VALUE #( lt_l3m[ 3 ]-gjahr ) }| &&
                               |{ VALUE #( lt_l3m[ 3 ]-month ) }31| ).
    IF lv_to < lv_from.
      DATA(lv_swap) = lv_from. lv_from = lv_to. lv_to = lv_swap.
    ENDIF.

    mt_hist = read_history( ir_werks = ir_werks
                            ir_matnr = ir_matnr
                            iv_from  = lv_from
                            iv_to    = lv_to ).

    LOOP AT build_scope( ir_werks = ir_werks
                         ir_matnr = ir_matnr
                         it_hist  = mt_hist ) INTO DATA(ls_scope).

      IF annual_exists( iv_werks = ls_scope-werks
                        iv_matnr = ls_scope-matnr
                        iv_fyear = iv_fyear ) = abap_false.
        add_msg( EXPORTING iv_number = 005
                           iv_v1 = ls_scope-werks iv_v2 = ls_scope-matnr iv_v3 = iv_fyear
                 CHANGING  ct_msg = et_msg ).
        CONTINUE.
      ENDIF.

      DATA(ls_alv) = VALUE zpps_fcst_alv( werks     = ls_scope-werks
                                          matnr     = ls_scope-matnr
                                          fyear     = iv_fyear
                                          period    = iv_period
                                          quarter   = lv_quarter
                                          fcst_type = gc_type-monthly ).

      fill_master_data( CHANGING cs_alv = ls_alv ).

      ls_alv-prod_cat = get_prod_cat( iv_werks = ls_scope-werks
                                      iv_matnr = ls_scope-matnr ).
      ls_alv-load_fct = get_load_factor( iv_werks   = ls_scope-werks
                                         iv_cat     = ls_alv-prod_cat
                                         iv_fyear   = iv_fyear
                                         iv_quarter = lv_quarter ).

      ls_alv-ly_mth_qty = hist_qty( iv_werks = ls_scope-werks
                                    iv_matnr = ls_scope-matnr
                                    iv_gjahr = lv_ly_year
                                    iv_month = lv_ly_month ).

      LOOP AT lt_l3m INTO DATA(ls_l3).
        ls_alv-l3m_qty = ls_alv-l3m_qty + hist_qty( iv_werks = ls_scope-werks
                                                    iv_matnr = ls_scope-matnr
                                                    iv_gjahr = ls_l3-gjahr
                                                    iv_month = ls_l3-month ).
      ENDLOOP.

      "--- B22 / B23 / B24 -------------------------------------------------
      ls_alv-l3m_avg   = ls_alv-l3m_qty / 3.
      ls_alv-avg_load  = ls_alv-l3m_avg * ls_alv-load_fct.
      ls_alv-req_qty   = nmax( val1 = ls_alv-ly_mth_qty val2 = ls_alv-avg_load ).

      ls_alv-bus_fcst  = get_business_fcst( iv_werks  = ls_scope-werks
                                            iv_matnr  = ls_scope-matnr
                                            iv_fyear  = iv_fyear
                                            iv_type   = gc_type-monthly
                                            iv_period = iv_period ).

      ls_alv-final_qty = nmax( val1 = ls_alv-req_qty val2 = ls_alv-bus_fcst ).

      ls_alv-adj_qty   = get_adjustment( iv_werks  = ls_scope-werks
                                         iv_matnr  = ls_scope-matnr
                                         iv_fyear  = iv_fyear
                                         iv_type   = gc_type-monthly
                                         iv_period = iv_period ).
      ls_alv-total_qty = ls_alv-final_qty + ls_alv-adj_qty.
      ls_alv-light     = '2'.

      SELECT SINGLE fcst_no FROM zppt_fcst_mn INTO @ls_alv-fcst_no
        WHERE werks = @ls_scope-werks AND matnr = @ls_scope-matnr
          AND fyear = @iv_fyear       AND period = @iv_period.
      IF sy-subrc = 0.
        ls_alv-status  = 'S'.
        ls_alv-light   = '3'.
        ls_alv-message = |Already saved|.
      ENDIF.

      APPEND ls_alv TO et_alv.

    ENDLOOP.

    IF et_alv IS INITIAL.
      add_msg( EXPORTING iv_type = 'I' iv_number = 009 CHANGING ct_msg = et_msg ).
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Save (B31, B32). One forecast number for the run.
*& Duplicate protection is the primary key of the target table - no
*& coded duplicate check is needed or possible to bypass.
*&---------------------------------------------------------------------*
  METHOD save.

    DATA: lv_saved TYPE i.

    DATA(lv_fcst_no) = number_get( ).
    IF lv_fcst_no IS INITIAL.
      add_msg( EXPORTING iv_number = 020 iv_v1 = space CHANGING ct_msg = rt_msg ).
      RETURN.
    ENDIF.

    LOOP AT ct_alv ASSIGNING FIELD-SYMBOL(<ls>) WHERE mark = abap_true.

      IF <ls>-status = 'S'.
        add_msg( EXPORTING iv_number = 006
                           iv_v1 = <ls>-werks iv_v2 = <ls>-matnr iv_v3 = <ls>-fyear
                 CHANGING  ct_msg = rt_msg ).
        CONTINUE.
      ENDIF.

      IF zcl_pp_forecast_util=>check_authority( iv_werks = <ls>-werks
                                                iv_actvt = '01' ) = abap_false.
        add_msg( EXPORTING iv_number = 011 iv_v1 = <ls>-werks iv_v2 = '01'
                 CHANGING  ct_msg = rt_msg ).
        <ls>-light = '1'.
        CONTINUE.
      ENDIF.

      <ls>-fcst_no = lv_fcst_no.

      CASE iv_type.

        WHEN gc_type-annual.
          DATA(ls_yr) = CORRESPONDING zppt_fcst_yr( <ls> ).
          ls_yr-fcst_no = lv_fcst_no.
          ls_yr-ernam   = sy-uname.
          ls_yr-erdat   = sy-datum.
          ls_yr-erzet   = sy-uzeit.
          INSERT zppt_fcst_yr FROM @ls_yr.

        WHEN gc_type-quarterly.
          DATA(ls_qt) = CORRESPONDING zppt_fcst_qt( <ls> ).
          ls_qt-fcst_no = lv_fcst_no.
          ls_qt-ernam   = sy-uname.
          ls_qt-erdat   = sy-datum.
          ls_qt-erzet   = sy-uzeit.
          INSERT zppt_fcst_qt FROM @ls_qt.

        WHEN gc_type-monthly.
          DATA(ls_mn) = CORRESPONDING zppt_fcst_mn( <ls> ).
          ls_mn-fcst_no = lv_fcst_no.
          ls_mn-ernam   = sy-uname.
          ls_mn-erdat   = sy-datum.
          ls_mn-erzet   = sy-uzeit.
          INSERT zppt_fcst_mn FROM @ls_mn.

      ENDCASE.

      IF sy-subrc = 0.
        <ls>-status  = 'S'.
        <ls>-light   = '3'.
        <ls>-message = |Saved under forecast { lv_fcst_no }|.
        CLEAR <ls>-mark.
        lv_saved = lv_saved + 1.
      ELSE.
        " Only reachable if the same key was saved by a parallel user
        <ls>-light   = '1'.
        <ls>-message = |Already exists|.
        add_msg( EXPORTING iv_number = 006
                           iv_v1 = <ls>-werks iv_v2 = <ls>-matnr iv_v3 = <ls>-fyear
                 CHANGING  ct_msg = rt_msg ).
      ENDIF.

    ENDLOOP.

    IF lv_saved > 0.
      COMMIT WORK AND WAIT.
      add_msg( EXPORTING iv_type = 'S' iv_number = 010
                         iv_v1 = lv_fcst_no iv_v2 = lv_saved
               CHANGING  ct_msg = rt_msg ).
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Delete (B33). The only route to revising a saved forecast, because
*& the key makes a second save impossible - see Query Q7.
*&---------------------------------------------------------------------*
  METHOD delete.

    LOOP AT it_alv INTO DATA(ls) WHERE mark = abap_true AND status = 'S'.

      IF zcl_pp_forecast_util=>check_authority( iv_werks = ls-werks
                                                iv_actvt = '06' ) = abap_false.
        add_msg( EXPORTING iv_number = 011 iv_v1 = ls-werks iv_v2 = '06'
                 CHANGING  ct_msg = rt_msg ).
        CONTINUE.
      ENDIF.

      CASE iv_type.
        WHEN gc_type-annual.
          DELETE FROM zppt_fcst_yr
            WHERE werks = @ls-werks AND matnr = @ls-matnr AND fyear = @ls-fyear.
        WHEN gc_type-quarterly.
          DELETE FROM zppt_fcst_qt
            WHERE werks = @ls-werks AND matnr = @ls-matnr
              AND fyear = @ls-fyear AND quarter = @ls-quarter.
        WHEN gc_type-monthly.
          DELETE FROM zppt_fcst_mn
            WHERE werks = @ls-werks AND matnr = @ls-matnr
              AND fyear = @ls-fyear AND period = @ls-period.
      ENDCASE.

      add_msg( EXPORTING iv_type = 'S' iv_number = 021
                         iv_v1 = ls-werks iv_v2 = ls-matnr iv_v3 = ls-fyear
               CHANGING  ct_msg = rt_msg ).
    ENDLOOP.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD build_scope.

    " Everything with sales history in the base window ...
    LOOP AT it_hist INTO DATA(ls_hist).
      INSERT VALUE #( werks = ls_hist-werks
                      matnr = ls_hist-matnr ) INTO TABLE rt_scope.
    ENDLOOP.

    " ... plus everything with a product category maintained, so a material
    " with no sales last year still appears with a zero forecast (B15)
    SELECT werks, matnr FROM zppt_prod_cat INTO TABLE @DATA(lt_cat)
      WHERE werks IN @ir_werks
        AND matnr IN @ir_matnr.

    LOOP AT lt_cat INTO DATA(ls_cat).
      INSERT VALUE #( werks = ls_cat-werks
                      matnr = ls_cat-matnr ) INTO TABLE rt_scope.
    ENDLOOP.

    " ... less the exclusion table (B30)
    SELECT werks, matnr FROM zppt_fcst_excl INTO TABLE @DATA(lt_excl)
      WHERE werks IN @ir_werks
        AND matnr IN @ir_matnr.

    LOOP AT lt_excl INTO DATA(ls_excl).
      DELETE rt_scope WHERE werks = ls_excl-werks AND matnr = ls_excl-matnr.
    ENDLOOP.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD fill_master_data.

    SELECT SINGLE matkl, meins, ntgew, brgew, gewei
      FROM mara INTO @DATA(ls_mara)
      WHERE matnr = @cs_alv-matnr.

    IF sy-subrc = 0.
      cs_alv-matkl = ls_mara-matkl.
      cs_alv-meins = ls_mara-meins.
      cs_alv-ntgew = ls_mara-ntgew.
      cs_alv-brgew = ls_mara-brgew.
      cs_alv-gewei = ls_mara-gewei.
    ENDIF.

    SELECT SINGLE maktx FROM makt INTO @cs_alv-maktx
      WHERE matnr = @cs_alv-matnr AND spras = @sy-langu.

    " Material groups 1 to 5 are sales-view fields; taken from the plant's
    " own sales organisation is not possible here, so MVKE is read without
    " a sales area restriction and the first entry is used
    SELECT SINGLE mvgr1, mvgr2, mvgr3, mvgr4, mvgr5
      FROM mvke INTO @DATA(ls_mvke)
      WHERE matnr = @cs_alv-matnr.

    IF sy-subrc = 0.
      cs_alv-mvgr1 = ls_mvke-mvgr1.
      cs_alv-mvgr2 = ls_mvke-mvgr2.
      cs_alv-mvgr3 = ls_mvke-mvgr3.
      cs_alv-mvgr4 = ls_mvke-mvgr4.
      cs_alv-mvgr5 = ls_mvke-mvgr5.
    ENDIF.

    " MTS / MTO indicator - display only (B37, Q8)
    SELECT SINGLE mts_mto FROM zppt_mts_mto INTO @cs_alv-mts_mto
      WHERE werks = @cs_alv-werks AND matnr = @cs_alv-matnr.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_prod_cat.

    SELECT SINGLE prod_cat FROM zppt_prod_cat INTO @rv_cat
      WHERE werks = @iv_werks AND matnr = @iv_matnr.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& Load factor (B28, B29). Falls back from the quarter-specific factor to
*& the annual default (QUARTER = 0), then to 1.000.
*&---------------------------------------------------------------------*
  METHOD get_load_factor.

    IF iv_cat IS NOT INITIAL.

      SELECT SINGLE load_fct FROM zppt_load_fct INTO @rv_fct
        WHERE werks    = @iv_werks
          AND prod_cat = @iv_cat
          AND fyear    = @iv_fyear
          AND quarter  = @iv_quarter.

      IF sy-subrc <> 0 AND iv_quarter <> 0.
        SELECT SINGLE load_fct FROM zppt_load_fct INTO @rv_fct
          WHERE werks    = @iv_werks
            AND prod_cat = @iv_cat
            AND fyear    = @iv_fyear
            AND quarter  = 0.
      ENDIF.
    ENDIF.

    IF rv_fct IS INITIAL.
      rv_fct = 1.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_business_fcst.

    SELECT SINGLE bus_qty FROM zppt_fcst_bus INTO @rv_qty
      WHERE werks     = @iv_werks
        AND matnr     = @iv_matnr
        AND fyear     = @iv_fyear
        AND fcst_type = @iv_type
        AND period    = @iv_period.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD get_adjustment.

    " Signed sum - negative rows are the subtraction case (B25)
    SELECT SUM( adj_qty ) FROM zppt_fcst_adj INTO @rv_qty
      WHERE werks     = @iv_werks
        AND matnr     = @iv_matnr
        AND fyear     = @iv_fyear
        AND fcst_type = @iv_type
        AND period    = @iv_period.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD hist_qty.

    READ TABLE mt_hist INTO DATA(ls) WITH TABLE KEY werks = iv_werks
                                                    matnr = iv_matnr
                                                    gjahr = iv_gjahr
                                                    month = iv_month.
    IF sy-subrc = 0.
      rv_qty = ls-qty.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD annual_exists.

    SELECT SINGLE @abap_true FROM zppt_fcst_yr INTO @rv_exists
      WHERE werks = @iv_werks AND matnr = @iv_matnr AND fyear = @iv_fyear.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD number_get.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING  nr_range_nr             = '01'
                 object                  = 'ZPPFCST'
      IMPORTING  number                  = rv_no
      EXCEPTIONS interval_not_found      = 1
                 number_range_not_intern = 2
                 object_not_found        = 3
                 OTHERS                  = 4.

    IF sy-subrc <> 0.
      CLEAR rv_no.
    ELSE.
      rv_no = |{ rv_no ALPHA = IN }|.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
  METHOD add_msg.

    DATA(ls_msg) = VALUE bapiret2( id = gc_msgid type = iv_type number = iv_number
                                   message_v1 = iv_v1 message_v2 = iv_v2
                                   message_v3 = iv_v3 message_v4 = iv_v4 ).

    MESSAGE ID ls_msg-id TYPE 'S' NUMBER ls_msg-number
      WITH iv_v1 iv_v2 iv_v3 iv_v4 INTO ls_msg-message.

    APPEND ls_msg TO ct_msg.

  ENDMETHOD.

ENDCLASS.
