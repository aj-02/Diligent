*&---------------------------------------------------------------------*
*& Report  ZPP_FORECAST          Transaction  ZFCST
*& ZFORECAST (Adhesive) - forecast generation
*&
*& Three planning modes selected by radio button:
*&   1  Annual        FS radio Button 1
*&   2  Quarter based FS radio Button 2
*&   3  Month based   FS radio button 3
*&
*& Displayed with CL_SALV_TABLE full screen, so no screen and no GUI
*& status need to be built. Rows are picked with the standard selection
*& column rather than a checkbox of our own, and Save is added to the
*& SALV toolbar.
*&
*& Built to Forecast Template-Adhesive.xlsx dated 20.08.2026
*&---------------------------------------------------------------------*
REPORT zpp_forecast MESSAGE-ID zpp_fcst.

TABLES marc.

* LVC_T_FNAME is not available in every release, so the column name
* list is typed locally over LVC_FNAME
TYPES tt_fname TYPE STANDARD TABLE OF lvc_fname WITH DEFAULT KEY.

DATA: gt_alv  TYPE zcl_pp_fcst=>tt_alv,
      go_fcst TYPE REF TO zcl_pp_fcst,
      go_alv  TYPE REF TO cl_salv_table,
      g_mode  TYPE char1.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_ann RADIOBUTTON GROUP mod DEFAULT 'X' USER-COMMAND md,
            p_qtr RADIOBUTTON GROUP mod,
            p_mth RADIOBUTTON GROUP mod.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_werks FOR marc-werks OBLIGATORY,
                s_matnr FOR marc-matnr.
PARAMETERS: p_fyear TYPE zde_fyear OBLIGATORY,
            p_quart TYPE zde_quarter MODIF ID qtr,
            p_perio TYPE poper       MODIF ID mth.
SELECT-OPTIONS: s_datum FOR sy-datum NO-EXTENSION MODIF ID dat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_tonn AS CHECKBOX,
            p_legc AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.


*&---------------------------------------------------------------------*
*& Local handler for the Save function added to the SALV toolbar
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_added_function
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.
    CLASS-METHODS show_log
      IMPORTING it_msg TYPE bapiret2_t.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_added_function.

    CHECK e_salv_function = 'SAVE'.

    " Rows picked in the standard selection column
    DATA(lt_rows) = go_alv->get_selections( )->get_selected_rows( ).

    IF lt_rows IS INITIAL.
      MESSAGE s017 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>).
      <ls>-mark = abap_false.
    ENDLOOP.

    LOOP AT lt_rows INTO DATA(lv_row).
      READ TABLE gt_alv ASSIGNING <ls> INDEX lv_row.
      IF sy-subrc = 0.
        <ls>-mark = abap_true.
      ENDIF.
    ENDLOOP.

    DATA(lt_msg) = go_fcst->save( EXPORTING iv_mode = g_mode
                                  CHANGING  ct_alv  = gt_alv ).

    go_alv->refresh( ).
    show_log( lt_msg ).

  ENDMETHOD.


  METHOD show_log.

    CHECK it_msg IS NOT INITIAL.

    CALL FUNCTION 'MESSAGES_INITIALIZE'.

    LOOP AT it_msg INTO DATA(ls_msg).
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING  arbgb  = ls_msg-id
                   msgty  = ls_msg-type
                   msgv1  = ls_msg-message_v1
                   msgv2  = ls_msg-message_v2
                   msgv3  = ls_msg-message_v3
                   msgv4  = ls_msg-message_v4
                   txtnr  = ls_msg-number
        EXCEPTIONS OTHERS = 1.
    ENDLOOP.

    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING  show_linno = abap_false
      EXCEPTIONS OTHERS     = 1.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
INITIALIZATION.

  " Financial year containing today, April to March
  DATA(gv_y) = CONV i( sy-datum(4) ).
  IF sy-datum+4(2) < '04'.
    gv_y = gv_y - 1.
  ENDIF.
  p_fyear = |{ gv_y }-{ gv_y + 1 }|.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'QTR'. screen-active = COND #( WHEN p_qtr = abap_true THEN 1 ELSE 0 ).
      WHEN 'MTH'. screen-active = COND #( WHEN p_mth = abap_true THEN 1 ELSE 0 ).
      WHEN 'DAT'. screen-active = COND #( WHEN p_ann = abap_true THEN 0 ELSE 1 ).
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF zcl_pp_fcst_util=>split_fyear( p_fyear ) = abap_false.
    MESSAGE e002 WITH p_fyear.
  ENDIF.

  " Either quarter or date, one of them mandatory
  IF p_qtr = abap_true.
    IF p_quart IS NOT INITIAL AND s_datum[] IS NOT INITIAL.
      MESSAGE e003.
    ENDIF.
    IF p_quart IS INITIAL AND s_datum[] IS INITIAL.
      MESSAGE e003.
    ENDIF.
  ENDIF.

  IF p_mth = abap_true AND p_perio IS INITIAL.
    MESSAGE e004.
  ENDIF.

  LOOP AT s_werks INTO DATA(ls_w).
    IF zcl_pp_fcst_util=>check_authority( iv_werks = ls_w-low
                                          iv_actvt = '03' ) = abap_false.
      MESSAGE e010 WITH ls_w-low '03'.
    ENDIF.
    IF p_legc = abap_true
   AND zcl_pp_fcst_util=>check_legacy_authority( ls_w-low ) = abap_false.
      MESSAGE e011.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM generate.

  IF gt_alv IS INITIAL.
    MESSAGE s008 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  PERFORM display.


*&---------------------------------------------------------------------*
FORM generate.

  DATA lt_msg TYPE bapiret2_t.

  CLEAR gt_alv.
  CREATE OBJECT go_fcst.

  g_mode = COND #( WHEN p_ann = abap_true THEN zcl_pp_fcst=>gc_mode-annual
                   WHEN p_qtr = abap_true THEN zcl_pp_fcst=>gc_mode-quarterly
                   ELSE                        zcl_pp_fcst=>gc_mode-monthly ).

  CASE g_mode.

    WHEN zcl_pp_fcst=>gc_mode-annual.
      go_fcst->generate_annual( EXPORTING ir_werks   = s_werks[]
                                          ir_matnr   = s_matnr[]
                                          iv_fyear   = p_fyear
                                          iv_legacy  = p_legc
                                          iv_tonnage = p_tonn
                                IMPORTING et_alv     = gt_alv
                                          et_msg     = lt_msg ).

    WHEN zcl_pp_fcst=>gc_mode-quarterly.
      go_fcst->generate_quarterly( EXPORTING ir_werks   = s_werks[]
                                             ir_matnr   = s_matnr[]
                                             iv_fyear   = p_fyear
                                             iv_quarter = p_quart
                                             iv_legacy  = p_legc
                                             iv_tonnage = p_tonn
                                   IMPORTING et_alv     = gt_alv
                                             et_msg     = lt_msg ).

    WHEN zcl_pp_fcst=>gc_mode-monthly.
      go_fcst->generate_monthly( EXPORTING ir_werks   = s_werks[]
                                           ir_matnr   = s_matnr[]
                                           iv_fyear   = p_fyear
                                           iv_period  = p_perio
                                           iv_legacy  = p_legc
                                           iv_tonnage = p_tonn
                                 IMPORTING et_alv     = gt_alv
                                           et_msg     = lt_msg ).
  ENDCASE.

  lcl_handler=>show_log( lt_msg ).

ENDFORM.


*&---------------------------------------------------------------------*
FORM display.

  DATA lt_show TYPE tt_fname.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                              CHANGING  t_table      = gt_alv ).

      "--- toolbar: standard functions plus Save ------------------------
      DATA(lo_funcs) = go_alv->get_functions( ).
      lo_funcs->set_all( ).

      DATA(lv_save_ok) = abap_true.

      LOOP AT s_werks INTO DATA(ls_w).
        IF zcl_pp_fcst_util=>check_authority( iv_werks = ls_w-low
                                              iv_actvt = '01' ) = abap_false.
          lv_save_ok = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_save_ok = abap_true.
        lo_funcs->add_function(
          name     = 'SAVE'
          icon     = CONV string( icon_system_save )
          text     = 'Save'
          tooltip  = 'Save the selected forecast lines'
          position = if_salv_c_function_position=>right_of_salv_functions ).
      ENDIF.

      "--- row selection replaces the old checkbox column ---------------
      go_alv->get_selections( )->set_selection_mode(
        if_salv_c_selection_mode=>row_column ).

      SET HANDLER lcl_handler=>on_added_function FOR go_alv->get_event( ).

      "--- columns ------------------------------------------------------
      PERFORM visible_columns CHANGING lt_show.
      PERFORM setup_columns   USING    lt_show.

      DATA(lv_head) = |{ SWITCH string( g_mode
                                        WHEN 'A' THEN 'Annual'
                                        WHEN 'Q' THEN 'Quarterly'
                                        ELSE          'Monthly' ) }| &&
                      | Forecast - { p_fyear }|.

      go_alv->get_display_settings( )->set_list_header( CONV lvc_title( lv_head ) ).

      go_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error
          cx_salv_existing cx_salv_wrong_call.
      MESSAGE e008.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& Columns belonging to the chosen mode. Everything else is set
*& technical, so one wide structure serves all three modes.
*&---------------------------------------------------------------------*
FORM visible_columns CHANGING ct_show TYPE tt_fname.

  DATA lv_p TYPE numc2.

  ct_show = VALUE tt_fname(
    ( 'LIGHT' ) ( 'FCST_NO' ) ( 'WERKS' ) ( 'MATNR' ) ( 'MAKTX' ) ( 'MATKL' )
    ( 'NTGEW' ) ( 'MVGR1_TXT' ) ( 'MVGR2_TXT' ) ( 'MVGR3_TXT' )
    ( 'MVGR4_TXT' ) ( 'MVGR5_TXT' )
    ( 'PROD_CAT' ) ( 'LOAD_FCT' ) ( 'MTS_MTO' ) ( 'MEINS' ) ( 'MESSAGE' ) ).

  CASE g_mode.

    WHEN zcl_pp_fcst=>gc_mode-annual.

      DO 12 TIMES.
        lv_p = sy-index.
        APPEND CONV lvc_fname( |M{ lv_p }| )      TO ct_show.
        APPEND CONV lvc_fname( |M{ lv_p }_FCST| ) TO ct_show.
        IF p_tonn = abap_true.
          APPEND CONV lvc_fname( |M{ lv_p }_TON| ) TO ct_show.
        ENDIF.
      ENDDO.

      APPEND 'LY_TOTAL'   TO ct_show.
      APPEND 'FCST_TOTAL' TO ct_show.

    WHEN zcl_pp_fcst=>gc_mode-quarterly.

      APPEND 'QUARTER'      TO ct_show.
      APPEND 'M4_LAST'      TO ct_show.
      APPEND 'M5_LAST'      TO ct_show.
      APPEND 'M6_LAST'      TO ct_show.
      APPEND 'LY_QTR_TOT'   TO ct_show.
      APPEND 'M1_CURR'      TO ct_show.
      APPEND 'M2_CURR'      TO ct_show.
      APPEND 'M3_CURR'      TO ct_show.
      APPEND 'L3M_TOT'      TO ct_show.
      APPEND 'MAX_QTY'      TO ct_show.
      APPEND 'FCST_QTY'     TO ct_show.
      APPEND 'BUS_FCST'     TO ct_show.
      APPEND 'BUS_FCST_ADD' TO ct_show.
      APPEND 'FINAL_QTY'    TO ct_show.
      APPEND 'M4_FCST'      TO ct_show.
      APPEND 'M5_FCST'      TO ct_show.
      APPEND 'M6_FCST'      TO ct_show.

      IF p_tonn = abap_true.
        APPEND 'M4_TON' TO ct_show.
        APPEND 'M5_TON' TO ct_show.
        APPEND 'M6_TON' TO ct_show.
      ENDIF.

    WHEN zcl_pp_fcst=>gc_mode-monthly.

      APPEND 'PERIOD'       TO ct_show.
      APPEND 'M4_LAST'      TO ct_show.
      APPEND 'M5_LAST'      TO ct_show.
      APPEND 'M6_LAST'      TO ct_show.
      APPEND 'LY_QTR_TOT'   TO ct_show.
      APPEND 'M1_CURR'      TO ct_show.
      APPEND 'M2_CURR'      TO ct_show.
      APPEND 'M3_CURR'      TO ct_show.
      APPEND 'L3M_AVG'      TO ct_show.
      APPEND 'MAX_QTY'      TO ct_show.
      APPEND 'FCST_QTY'     TO ct_show.
      APPEND 'BUS_FCST'     TO ct_show.
      APPEND 'BUS_FCST_ADD' TO ct_show.
      APPEND 'FINAL_QTY'    TO ct_show.

      IF p_tonn = abap_true.
        APPEND 'M4_TON' TO ct_show.
      ENDIF.

  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
FORM setup_columns USING pt_show TYPE tt_fname.

  DATA(lo_cols) = go_alv->get_columns( ).
  lo_cols->set_optimize( ).

  TRY.
      lo_cols->set_exception_column( 'LIGHT' ).
    CATCH cx_salv_data_error.
  ENDTRY.

  " Hide everything that does not belong to this mode
  LOOP AT lo_cols->get( ) INTO DATA(ls_col).

    READ TABLE pt_show TRANSPORTING NO FIELDS
      WITH KEY table_line = ls_col-columnname.

    IF sy-subrc <> 0.
      TRY.
          ls_col-r_column->set_technical( abap_true ).
        CATCH cx_salv_error.
      ENDTRY.
    ENDIF.

  ENDLOOP.

  " Month columns carry real dates as headings
  IF g_mode = zcl_pp_fcst=>gc_mode-annual.

    DATA(lv_prev) = zcl_pp_fcst_util=>previous_fyear( p_fyear ).

*   PERFORM ... USING takes data objects only, so the column name and the
*   heading are built into variables first
    DATA: lv_col TYPE lvc_fname,
          lv_hdr TYPE string.

    DO 12 TIMES.

      DATA(lv_p) = CONV numc2( sy-index ).

      zcl_pp_fcst_util=>period_to_yearmonth( EXPORTING iv_fyear  = lv_prev
                                                       iv_period = lv_p
                                             IMPORTING ev_gjahr  = DATA(lv_yy)
                                                       ev_month  = DATA(lv_mm) ).
      lv_col = |M{ lv_p }|.
      lv_hdr = |{ lv_mm }-{ lv_yy+2(2) }|.
      PERFORM txt USING lv_col lv_hdr.

      zcl_pp_fcst_util=>period_to_yearmonth( EXPORTING iv_fyear  = p_fyear
                                                       iv_period = lv_p
                                             IMPORTING ev_gjahr  = lv_yy
                                                       ev_month  = lv_mm ).
      lv_col = |M{ lv_p }_FCST|.
      lv_hdr = |FC { lv_mm }-{ lv_yy+2(2) }|.
      PERFORM txt USING lv_col lv_hdr.

      lv_col = |M{ lv_p }_TON|.
      lv_hdr = |Ton { lv_mm }-{ lv_yy+2(2) }|.
      PERFORM txt USING lv_col lv_hdr.

    ENDDO.

    PERFORM txt USING 'LY_TOTAL'   'Total LY Sales Qty'.
    PERFORM txt USING 'FCST_TOTAL' 'Forecast Qty'.

  ELSE.

    PERFORM txt USING 'M4_LAST'      'LY Month 1'.
    PERFORM txt USING 'M5_LAST'      'LY Month 2'.
    PERFORM txt USING 'M6_LAST'      'LY Month 3'.
    PERFORM txt USING 'LY_QTR_TOT'   'Total LY Quarter'.
    PERFORM txt USING 'M1_CURR'      'Current Month 1'.
    PERFORM txt USING 'M2_CURR'      'Current Month 2'.
    PERFORM txt USING 'M3_CURR'      'Current Month 3'.
    PERFORM txt USING 'L3M_TOT'      'L3 Month Total'.
    PERFORM txt USING 'L3M_AVG'      'L3 Month Average'.
    PERFORM txt USING 'BUS_FCST'     'Business Forecast'.
    PERFORM txt USING 'BUS_FCST_ADD' 'Business Fcst Additional'.
    PERFORM txt USING 'FINAL_QTY'    'Final Forecast Qty'.
    PERFORM txt USING 'M4_FCST'      'Month 1'.
    PERFORM txt USING 'M5_FCST'      'Month 2'.
    PERFORM txt USING 'M6_FCST'      'Month 3'.

    IF g_mode = zcl_pp_fcst=>gc_mode-quarterly.
      PERFORM txt USING 'MAX_QTY'  'Max Qty'.
      PERFORM txt USING 'FCST_QTY' 'Forecast Max x Growth'.
    ELSE.
      PERFORM txt USING 'MAX_QTY'  'Average x Load'.
      PERFORM txt USING 'FCST_QTY' 'LY vs Current Reqt Qty'.
    ENDIF.

  ENDIF.

  PERFORM txt USING 'PROD_CAT'  'Product Cat.'.
  PERFORM txt USING 'LOAD_FCT'  'Load Factor'.
  PERFORM txt USING 'MTS_MTO'   'MTS / MTO'.
  PERFORM txt USING 'MVGR1_TXT' 'Material Group 1'.
  PERFORM txt USING 'MVGR2_TXT' 'Material Group 2'.
  PERFORM txt USING 'MVGR3_TXT' 'Material Group 3'.
  PERFORM txt USING 'MVGR4_TXT' 'Material Group 4'.
  PERFORM txt USING 'MVGR5_TXT' 'Material Group 5'.
  PERFORM txt USING 'FCST_NO'   'Forecast Number'.

ENDFORM.


*&---------------------------------------------------------------------*
FORM txt USING pv_name TYPE any
               pv_text TYPE any.

  TRY.
      DATA(lo_col) = go_alv->get_columns( )->get_column( CONV lvc_fname( pv_name ) ).
      lo_col->set_short_text( CONV scrtext_s( pv_text ) ).
      lo_col->set_medium_text( CONV scrtext_m( pv_text ) ).
      lo_col->set_long_text( CONV scrtext_l( pv_text ) ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.
