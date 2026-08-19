*&---------------------------------------------------------------------*
*& Report        ZPP_FORECAST_REPORT
*& Transaction   ZFCST_RPT
*& Package       ZPP_FORECAST
*& Description   ZFORECAST (Adhesive) - final forecast report.
*&               Consolidates annual, quarterly and monthly forecasts
*&               with their adjustments into one line per material, per
*&               the "Final Report" layout in the BRD.
*&
*& Created by    Arnav Johri
*& Reference     WRICEF ID-2A Forecast Template-Adhesive.xlsx, 14.08.2026
*&
*& Layout    Forecast No | Material | Plant | Fin.Year | Annual
*&           | Q1..Q4 | M01..M12 | M01..M12 additional | Total M01..M12
*&           where Total M(n) = M(n) + M(n) additional  (B26)
*&---------------------------------------------------------------------*
REPORT zpp_forecast_report MESSAGE-ID zpp_forecast.

TABLES: marc, zppt_fcst_yr.

TYPES: BEGIN OF ty_out,
         fcst_no  TYPE zde_fcst_no,
         werks    TYPE werks_d,
         matnr    TYPE matnr,
         maktx    TYPE maktx,
         matkl    TYPE matkl,
         mvgr1    TYPE mvgr1,
         mvgr2    TYPE mvgr2,
         mvgr5    TYPE mvgr5,
         fyear    TYPE zde_fyear,
         prod_cat TYPE zde_prod_cat,
         annual   TYPE zde_fcst_qty,
         q1       TYPE zde_fcst_qty,
         q2       TYPE zde_fcst_qty,
         q3       TYPE zde_fcst_qty,
         q4       TYPE zde_fcst_qty,
         m01 TYPE zde_fcst_qty, m02 TYPE zde_fcst_qty, m03 TYPE zde_fcst_qty,
         m04 TYPE zde_fcst_qty, m05 TYPE zde_fcst_qty, m06 TYPE zde_fcst_qty,
         m07 TYPE zde_fcst_qty, m08 TYPE zde_fcst_qty, m09 TYPE zde_fcst_qty,
         m10 TYPE zde_fcst_qty, m11 TYPE zde_fcst_qty, m12 TYPE zde_fcst_qty,
         a01 TYPE zde_fcst_qty, a02 TYPE zde_fcst_qty, a03 TYPE zde_fcst_qty,
         a04 TYPE zde_fcst_qty, a05 TYPE zde_fcst_qty, a06 TYPE zde_fcst_qty,
         a07 TYPE zde_fcst_qty, a08 TYPE zde_fcst_qty, a09 TYPE zde_fcst_qty,
         a10 TYPE zde_fcst_qty, a11 TYPE zde_fcst_qty, a12 TYPE zde_fcst_qty,
         t01 TYPE zde_fcst_qty, t02 TYPE zde_fcst_qty, t03 TYPE zde_fcst_qty,
         t04 TYPE zde_fcst_qty, t05 TYPE zde_fcst_qty, t06 TYPE zde_fcst_qty,
         t07 TYPE zde_fcst_qty, t08 TYPE zde_fcst_qty, t09 TYPE zde_fcst_qty,
         t10 TYPE zde_fcst_qty, t11 TYPE zde_fcst_qty, t12 TYPE zde_fcst_qty,
         meins    TYPE meins,
       END OF ty_out,
       tt_out TYPE STANDARD TABLE OF ty_out WITH DEFAULT KEY.

DATA: gt_out TYPE tt_out.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_fcstno FOR zppt_fcst_yr-fcst_no,
                s_werks  FOR marc-werks OBLIGATORY,
                s_matnr  FOR marc-matnr.
PARAMETERS:     p_fyear  TYPE zde_fyear OBLIGATORY.
SELECT-OPTIONS: s_quart  FOR zppt_fcst_yr-fcst_no NO INTERVALS,   "quarter filter
                s_perio  FOR zppt_fcst_yr-fcst_no NO INTERVALS.   "period filter
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
INITIALIZATION.

  DATA(lv_y) = CONV i( sy-datum(4) ).
  IF sy-datum+4(2) < '04'.
    lv_y = lv_y - 1.
  ENDIF.
  p_fyear = |{ lv_y }-{ lv_y + 1 }|.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF zcl_pp_forecast_util=>split_fyear( p_fyear ) = abap_false.
    MESSAGE e003 WITH p_fyear.
  ENDIF.

  LOOP AT s_werks INTO DATA(ls_w).
    IF zcl_pp_forecast_util=>check_authority( iv_werks = CONV #( ls_w-low )
                                              iv_actvt = '03' ) = abap_false.
      MESSAGE e011 WITH ls_w-low '03'.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM collect.

  IF gt_out IS INITIAL.
    MESSAGE s009 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  PERFORM display.


*&---------------------------------------------------------------------*
FORM collect.

  CLEAR gt_out.

  "--- annual is the anchor: one row per plant / material / year --------
  SELECT * FROM zppt_fcst_yr INTO TABLE @DATA(lt_yr)
    WHERE werks   IN @s_werks
      AND matnr   IN @s_matnr
      AND fyear    = @p_fyear
      AND fcst_no IN @s_fcstno.

  IF lt_yr IS INITIAL.
    RETURN.
  ENDIF.

  SELECT * FROM zppt_fcst_qt INTO TABLE @DATA(lt_qt)
    FOR ALL ENTRIES IN @lt_yr
    WHERE werks = @lt_yr-werks AND matnr = @lt_yr-matnr AND fyear = @lt_yr-fyear.

  SELECT * FROM zppt_fcst_mn INTO TABLE @DATA(lt_mn)
    FOR ALL ENTRIES IN @lt_yr
    WHERE werks = @lt_yr-werks AND matnr = @lt_yr-matnr AND fyear = @lt_yr-fyear.

  SELECT werks, matnr, fyear, fcst_type, period, SUM( adj_qty ) AS adj_qty
    FROM zppt_fcst_adj
    INTO TABLE @DATA(lt_adj)
    FOR ALL ENTRIES IN @lt_yr
    WHERE werks = @lt_yr-werks AND matnr = @lt_yr-matnr AND fyear = @lt_yr-fyear
    GROUP BY werks, matnr, fyear, fcst_type, period.

  LOOP AT lt_yr INTO DATA(ls_yr).

    DATA(ls_out) = VALUE ty_out( fcst_no = ls_yr-fcst_no
                                 werks   = ls_yr-werks
                                 matnr   = ls_yr-matnr
                                 fyear   = ls_yr-fyear
                                 prod_cat = ls_yr-prod_cat
                                 annual  = ls_yr-fcst_total
                                 meins   = ls_yr-meins ).

    SELECT SINGLE maktx FROM makt INTO @ls_out-maktx
      WHERE matnr = @ls_yr-matnr AND spras = @sy-langu.
    SELECT SINGLE matkl FROM mara INTO @ls_out-matkl
      WHERE matnr = @ls_yr-matnr.
    SELECT SINGLE mvgr1, mvgr2, mvgr5 FROM mvke INTO @DATA(ls_mvke)
      WHERE matnr = @ls_yr-matnr.
    IF sy-subrc = 0.
      ls_out-mvgr1 = ls_mvke-mvgr1.
      ls_out-mvgr2 = ls_mvke-mvgr2.
      ls_out-mvgr5 = ls_mvke-mvgr5.
    ENDIF.

    "--- quarters -------------------------------------------------------
    LOOP AT lt_qt INTO DATA(ls_qt) WHERE werks = ls_yr-werks
                                     AND matnr = ls_yr-matnr
                                     AND fyear = ls_yr-fyear.
      CHECK s_quart[] IS INITIAL OR ls_qt-quarter IN s_quart.
      ASSIGN COMPONENT |Q{ ls_qt-quarter }| OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_q>).
      IF sy-subrc = 0.
        <lv_q> = ls_qt-final_qty.
      ENDIF.
    ENDLOOP.

    "--- months ---------------------------------------------------------
    LOOP AT lt_mn INTO DATA(ls_mn) WHERE werks = ls_yr-werks
                                     AND matnr = ls_yr-matnr
                                     AND fyear = ls_yr-fyear.
      CHECK s_perio[] IS INITIAL OR ls_mn-period IN s_perio.
      ASSIGN COMPONENT |M{ ls_mn-period }| OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_m>).
      IF sy-subrc = 0.
        <lv_m> = ls_mn-final_qty.
      ENDIF.
    ENDLOOP.

    " Where no monthly forecast has been generated, fall back to the
    " annual split so the report is never blank for a saved forecast
    DO 12 TIMES.
      DATA(lv_p) = CONV numc2( sy-index ).
      ASSIGN COMPONENT |M{ lv_p }| OF STRUCTURE ls_out TO <lv_m>.
      CHECK sy-subrc = 0 AND <lv_m> IS INITIAL.
      ASSIGN COMPONENT |M{ lv_p }| OF STRUCTURE ls_yr TO FIELD-SYMBOL(<lv_ym>).
      IF sy-subrc = 0.
        <lv_m> = <lv_ym>.
      ENDIF.
    ENDDO.

    "--- adjustments and totals (B26) -----------------------------------
    LOOP AT lt_adj INTO DATA(ls_adj) WHERE werks = ls_yr-werks
                                       AND matnr = ls_yr-matnr
                                       AND fyear = ls_yr-fyear
                                       AND fcst_type = 'M'.
      ASSIGN COMPONENT |A{ ls_adj-period }| OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_a>).
      IF sy-subrc = 0.
        <lv_a> = ls_adj-adj_qty.
      ENDIF.
    ENDLOOP.

    DO 12 TIMES.
      lv_p = sy-index.
      ASSIGN COMPONENT |M{ lv_p }| OF STRUCTURE ls_out TO <lv_m>.
      ASSIGN COMPONENT |A{ lv_p }| OF STRUCTURE ls_out TO <lv_a>.
      ASSIGN COMPONENT |T{ lv_p }| OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_t>).
      IF <lv_m> IS ASSIGNED AND <lv_a> IS ASSIGNED AND <lv_t> IS ASSIGNED.
        <lv_t> = <lv_m> + <lv_a>.
      ENDIF.
    ENDDO.

    APPEND ls_out TO gt_out.

  ENDLOOP.

  SORT gt_out BY werks matnr.

ENDFORM.

*&---------------------------------------------------------------------*
FORM display.

  DATA lo_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_out ).

      lo_alv->get_functions( )->set_all( ).

      DATA(lo_cols) = lo_alv->get_columns( ).
      lo_cols->set_optimize( ).

      PERFORM set_text USING lo_cols 'FCST_NO'  'Forecast Number'.
      PERFORM set_text USING lo_cols 'WERKS'    'Plant'.
      PERFORM set_text USING lo_cols 'MATNR'    'Material'.
      PERFORM set_text USING lo_cols 'MAKTX'    'Material Description'.
      PERFORM set_text USING lo_cols 'MATKL'    'Material Group'.
      PERFORM set_text USING lo_cols 'FYEAR'    'Financial Year'.
      PERFORM set_text USING lo_cols 'PROD_CAT' 'Product Category'.
      PERFORM set_text USING lo_cols 'ANNUAL'   'Annual Forecast'.

      DO 4 TIMES.
        PERFORM set_text USING lo_cols |Q{ sy-index }| |Quarter { sy-index }|.
      ENDDO.

      DO 12 TIMES.
        DATA(lv_p)  = CONV numc2( sy-index ).
        DATA(lv_mn) = zcl_pp_forecast_util=>period_to_month( lv_p ).
        PERFORM set_text USING lo_cols |M{ lv_p }| |Month { lv_mn }|.
        PERFORM set_text USING lo_cols |A{ lv_p }| |Month { lv_mn } Additional|.
        PERFORM set_text USING lo_cols |T{ lv_p }| |Total Month { lv_mn }|.
      ENDDO.

      lo_alv->get_display_settings( )->set_list_header(
        |Forecast Report - Financial Year { p_fyear }| ).

      lo_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error.
      MESSAGE e009.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
FORM set_text USING po_cols TYPE REF TO cl_salv_columns_table
                    pv_name TYPE any
                    pv_text TYPE any.

  TRY.
      DATA(lo_col) = po_cols->get_column( CONV lvc_fname( pv_name ) ).
      lo_col->set_long_text( CONV scrtext_l( pv_text ) ).
      lo_col->set_medium_text( CONV scrtext_m( pv_text ) ).
      lo_col->set_short_text( CONV scrtext_s( pv_text ) ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.
