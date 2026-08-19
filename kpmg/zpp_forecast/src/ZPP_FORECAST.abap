*&---------------------------------------------------------------------*
*& Report        ZPP_FORECAST
*& Transaction   ZFCST
*& Package       ZPP_FORECAST
*& Description   ZFORECAST (Adhesive) - forecast generation.
*&               Three planning modes selected by radio button:
*&               Annual (BRD 1.1), Quarter based (1.2), Month based (1.3).
*&
*& Created by    Arnav Johri
*& Reference     WRICEF ID-2A Forecast Template-Adhesive.xlsx, 14.08.2026
*&               Assumptions B01 - B42
*&---------------------------------------------------------------------*
REPORT zpp_forecast MESSAGE-ID zpp_forecast.

TABLES: marc.

TYPES: tt_alv TYPE zcl_pp_forecast=>tt_alv.

DATA: gt_alv     TYPE tt_alv,
      go_fcst    TYPE REF TO zcl_pp_forecast,
      go_cc      TYPE REF TO cl_gui_custom_container,
      go_grid    TYPE REF TO cl_gui_alv_grid,
      go_handler TYPE REF TO lcl_handler,
      g_ok_code  TYPE sy-ucomm,
      g_type     TYPE zde_fcst_type.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_ann RADIOBUTTON GROUP mod DEFAULT 'X' USER-COMMAND mode,
            p_qtr RADIOBUTTON GROUP mod,
            p_mth RADIOBUTTON GROUP mod.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_werks FOR marc-werks OBLIGATORY,
                s_matnr FOR marc-matnr.
PARAMETERS: p_fyear TYPE zde_fyear OBLIGATORY,
            p_quart TYPE zde_quarter MODIF ID qtr,
            p_perio TYPE numc2       MODIF ID mth.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_tonnet AS CHECKBOX,
            p_tongrs AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.


*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_toolbar      FOR EVENT toolbar      OF cl_gui_alv_grid IMPORTING e_object.
    METHODS on_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_toolbar.
    APPEND VALUE stb_button( butn_type = 3 ) TO e_object->mt_toolbar.
    APPEND VALUE stb_button( function  = 'SELALL'
                             icon      = CONV #( icon_select_all )
                             quickinfo = 'Select all unsaved lines' ) TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD on_user_command.
    CASE e_ucomm.
      WHEN 'SELALL'.
        LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>) WHERE status <> 'S'.
          <ls>-mark = abap_true.
        ENDLOOP.
        go_grid->refresh_table_display(
          is_stable = VALUE #( row = abap_true col = abap_true ) ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
INITIALIZATION.

  " Default to the financial year containing today (April to March, B04)
  DATA(lv_y) = CONV i( sy-datum(4) ).
  IF sy-datum+4(2) < '04'.
    lv_y = lv_y - 1.
  ENDIF.
  p_fyear = |{ lv_y }-{ lv_y + 1 }|.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'QTR'.
        screen-active = COND #( WHEN p_qtr = abap_true THEN 1 ELSE 0 ).
      WHEN 'MTH'.
        screen-active = COND #( WHEN p_mth = abap_true THEN 1 ELSE 0 ).
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF zcl_pp_forecast_util=>split_fyear( p_fyear ) = abap_false.
    MESSAGE e003 WITH p_fyear.
  ENDIF.

  " Tonnage options are mutually exclusive (B35)
  IF p_tonnet = abap_true AND p_tongrs = abap_true.
    MESSAGE e004.
  ENDIF.

  IF p_qtr = abap_true AND p_quart IS INITIAL.
    MESSAGE e012.
  ENDIF.

  IF p_mth = abap_true AND p_perio IS INITIAL.
    MESSAGE e013.
  ENDIF.

  LOOP AT s_werks INTO DATA(ls_w).
    IF zcl_pp_forecast_util=>check_authority( iv_werks = CONV #( ls_w-low )
                                              iv_actvt = '03' ) = abap_false.
      MESSAGE e011 WITH ls_w-low '03'.
    ENDIF.
  ENDLOOP.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM generate.

  IF gt_alv IS INITIAL.
    MESSAGE s009 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  CALL SCREEN 0100.


*&---------------------------------------------------------------------*
FORM generate.

  DATA lt_msg TYPE bapiret2_t.

  CLEAR gt_alv.
  CREATE OBJECT go_fcst.

  g_type = COND #( WHEN p_ann = abap_true THEN zcl_pp_forecast=>gc_type-annual
                   WHEN p_qtr = abap_true THEN zcl_pp_forecast=>gc_type-quarterly
                   ELSE                        zcl_pp_forecast=>gc_type-monthly ).

  CASE g_type.

    WHEN zcl_pp_forecast=>gc_type-annual.
      go_fcst->generate_annual( EXPORTING ir_werks = s_werks[]
                                          ir_matnr = s_matnr[]
                                          iv_fyear = p_fyear
                                IMPORTING et_alv   = gt_alv
                                          et_msg   = lt_msg ).

    WHEN zcl_pp_forecast=>gc_type-quarterly.
      go_fcst->generate_quarterly( EXPORTING ir_werks   = s_werks[]
                                             ir_matnr   = s_matnr[]
                                             iv_fyear   = p_fyear
                                             iv_quarter = p_quart
                                   IMPORTING et_alv     = gt_alv
                                             et_msg     = lt_msg ).

    WHEN zcl_pp_forecast=>gc_type-monthly.
      go_fcst->generate_monthly( EXPORTING ir_werks  = s_werks[]
                                           ir_matnr  = s_matnr[]
                                           iv_fyear  = p_fyear
                                           iv_period = p_perio
                                 IMPORTING et_alv    = gt_alv
                                           et_msg    = lt_msg ).
  ENDCASE.

  " Tonnage columns - display only, the stored quantity stays in base UoM (B36)
  IF p_tonnet = abap_true OR p_tongrs = abap_true.
    PERFORM fill_tonnage.
  ENDIF.

  IF lt_msg IS NOT INITIAL.
    PERFORM show_log USING lt_msg.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM fill_tonnage.

  DATA(lv_gross) = p_tongrs.

  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>).

    CASE g_type.

      WHEN zcl_pp_forecast=>gc_type-annual.
        DO 12 TIMES.
          DATA(lv_p) = CONV numc2( sy-index ).
          ASSIGN COMPONENT |M{ lv_p }|  OF STRUCTURE <ls> TO FIELD-SYMBOL(<lv_q>).
          ASSIGN COMPONENT |TN{ lv_p }| OF STRUCTURE <ls> TO FIELD-SYMBOL(<lv_t>).
          IF <lv_q> IS ASSIGNED AND <lv_t> IS ASSIGNED.
            <lv_t> = zcl_pp_forecast_util=>to_tonnage( iv_matnr = <ls>-matnr
                                                       iv_qty   = <lv_q>
                                                       iv_gross = lv_gross ).
          ENDIF.
        ENDDO.

      WHEN OTHERS.
        DO 3 TIMES.
          ASSIGN COMPONENT |MTH{ sy-index }| OF STRUCTURE <ls> TO FIELD-SYMBOL(<lv_m>).
          ASSIGN COMPONENT |TN{ sy-index }|  OF STRUCTURE <ls> TO FIELD-SYMBOL(<lv_mt>).
          IF <lv_m> IS ASSIGNED AND <lv_mt> IS ASSIGNED.
            <lv_mt> = zcl_pp_forecast_util=>to_tonnage( iv_matnr = <ls>-matnr
                                                        iv_qty   = <lv_m>
                                                        iv_gross = lv_gross ).
          ENDIF.
        ENDDO.
    ENDCASE.

    <ls>-ton_total = zcl_pp_forecast_util=>to_tonnage( iv_matnr = <ls>-matnr
                                                       iv_qty   = <ls>-total_qty
                                                       iv_gross = lv_gross ).
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA lt_excl TYPE STANDARD TABLE OF sy-ucomm.

  " Save and Delete only for users who may maintain the plant
  LOOP AT s_werks INTO DATA(ls_w).
    IF zcl_pp_forecast_util=>check_authority( iv_werks = CONV #( ls_w-low )
                                              iv_actvt = '01' ) = abap_false.
      APPEND 'SAVE' TO lt_excl.
    ENDIF.
    IF zcl_pp_forecast_util=>check_authority( iv_werks = CONV #( ls_w-low )
                                              iv_actvt = '06' ) = abap_false.
      APPEND 'DELE' TO lt_excl.
    ENDIF.
  ENDLOOP.

  SET PF-STATUS 'S0100' EXCLUDING lt_excl.
  SET TITLEBAR  'T0100' WITH SWITCH string( g_type
                                            WHEN 'A' THEN 'Annual'
                                            WHEN 'Q' THEN 'Quarterly'
                                            ELSE          'Monthly' )
                             p_fyear.

  PERFORM build_alv.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA(lv_ok) = g_ok_code.
  CLEAR g_ok_code.

  IF go_grid IS BOUND.
    go_grid->check_changed_data( ).
  ENDIF.

  CASE lv_ok.

    WHEN 'SAVE'.
      PERFORM save_forecast.

    WHEN 'DELE'.
      PERFORM delete_forecast.

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF go_grid IS BOUND. go_grid->free( ). CLEAR go_grid. ENDIF.
      IF go_cc   IS BOUND. go_cc->free( ).   CLEAR go_cc.   ENDIF.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
FORM save_forecast.

  IF NOT line_exists( gt_alv[ mark = abap_true ] ).
    MESSAGE e022.
    RETURN.
  ENDIF.

  DATA(lt_msg) = go_fcst->save( EXPORTING iv_type = g_type
                                CHANGING  ct_alv  = gt_alv ).

  go_grid->refresh_table_display(
    is_stable = VALUE #( row = abap_true col = abap_true ) ).

  PERFORM show_log USING lt_msg.

ENDFORM.

*&---------------------------------------------------------------------*
FORM delete_forecast.

  DATA lv_answer TYPE char1.

  IF NOT line_exists( gt_alv[ mark = abap_true ] ).
    MESSAGE e022.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING titlebar              = 'Delete Forecast'
              text_question         = 'Delete the saved forecast for the selected lines?'
              default_button        = '2'
              display_cancel_button = abap_false
    IMPORTING answer                = lv_answer
    EXCEPTIONS OTHERS               = 1.

  CHECK lv_answer = '1'.

  DATA(lt_msg) = go_fcst->delete( iv_type = g_type it_alv = gt_alv ).

  PERFORM generate.

  go_grid->refresh_table_display(
    is_stable = VALUE #( row = abap_true col = abap_true ) ).

  PERFORM show_log USING lt_msg.

ENDFORM.

*&---------------------------------------------------------------------*
*& ALV. One field catalogue, columns switched by planning mode.
*&---------------------------------------------------------------------*
FORM build_alv.

  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_layo TYPE lvc_s_layo.

  IF go_grid IS BOUND.
    go_grid->refresh_table_display(
      is_stable = VALUE #( row = abap_true col = abap_true ) ).
    RETURN.
  ENDIF.

  CREATE OBJECT go_cc   EXPORTING container_name = 'CC_ALV'.
  CREATE OBJECT go_grid EXPORTING i_parent       = go_cc.

  DEFINE add_col.
    APPEND VALUE lvc_s_fcat( fieldname = &1 coltext = &2 outputlen = &3
                             qfieldname = &4 ) TO lt_fcat.
  END-OF-DEFINITION.

  APPEND VALUE lvc_s_fcat( fieldname = 'MARK'  coltext = 'Sel' checkbox = abap_true
                           edit = abap_true outputlen = 3 ) TO lt_fcat.
  APPEND VALUE lvc_s_fcat( fieldname = 'LIGHT' coltext = 'St'  outputlen = 3 ) TO lt_fcat.

  add_col 'FCST_NO'  'Forecast Number'  10 ''.
  add_col 'WERKS'    'Plant'             4 ''.
  add_col 'MATNR'    'Material'         18 ''.
  add_col 'MAKTX'    'Description'      40 ''.
  add_col 'MATKL'    'Material Group'    9 ''.
  add_col 'NTGEW'    'Net Weight'       13 'GEWEI'.
  add_col 'MVGR1'    'Material Group 1'  6 ''.
  add_col 'MVGR2'    'Material Group 2'  6 ''.
  add_col 'MVGR3'    'Material Group 3'  6 ''.
  add_col 'MVGR4'    'Material Group 4'  6 ''.
  add_col 'MVGR5'    'Material Group 5'  6 ''.
  add_col 'PROD_CAT' 'Product Cat.'      5 ''.
  add_col 'LOAD_FCT' 'Load Factor'       8 ''.
  add_col 'MTS_MTO'  'MTS / MTO'         5 ''.

  CASE g_type.

    WHEN zcl_pp_forecast=>gc_type-annual.
      " Last year twelve months, then the twelve forecast months (B14)
      DO 12 TIMES.
        DATA(lv_p)  = CONV numc2( sy-index ).
        DATA(lv_mn) = zcl_pp_forecast_util=>period_to_month( lv_p ).
        APPEND VALUE lvc_s_fcat( fieldname  = |LY{ lv_p }|
                                 coltext    = |LY { lv_mn }|
                                 qfieldname = 'MEINS'
                                 outputlen  = 13 ) TO lt_fcat.
      ENDDO.
      add_col 'LY_TOTAL'   'Total LY Sales Qty' 16 'MEINS'.
      add_col 'FCST_TOTAL' 'Forecast Qty'       16 'MEINS'.
      DO 12 TIMES.
        lv_p  = sy-index.
        lv_mn = zcl_pp_forecast_util=>period_to_month( lv_p ).
        APPEND VALUE lvc_s_fcat( fieldname  = |M{ lv_p }|
                                 coltext    = |FC { lv_mn }|
                                 qfieldname = 'MEINS'
                                 outputlen  = 13 ) TO lt_fcat.
        IF p_tonnet = abap_true OR p_tongrs = abap_true.
          APPEND VALUE lvc_s_fcat( fieldname = |TN{ lv_p }|
                                   coltext   = |Tonnage { lv_mn }|
                                   outputlen = 13 ) TO lt_fcat.
        ENDIF.
      ENDDO.

    WHEN zcl_pp_forecast=>gc_type-quarterly.
      add_col 'QUARTER'    'Quarter'                 3 ''.
      add_col 'LY_QTR_QTY' 'Total LY Quarter Sales' 16 'MEINS'.
      add_col 'L3M_QTY'    'L3 Month Total'         16 'MEINS'.
      add_col 'BASE_QTY'   'Max Qty'                16 'MEINS'.
      add_col 'FCST_QTY'   'Forecast (Max x Load)'  16 'MEINS'.
      add_col 'BUS_FCST'   'Business Forecast'      16 'MEINS'.
      add_col 'FINAL_QTY'  'Final Forecast Qty'     16 'MEINS'.
      add_col 'MTH1'       'Month 1'                14 'MEINS'.
      add_col 'MTH2'       'Month 2'                14 'MEINS'.
      add_col 'MTH3'       'Month 3'                14 'MEINS'.

    WHEN zcl_pp_forecast=>gc_type-monthly.
      add_col 'PERIOD'     'Period'                  4 ''.
      add_col 'LY_MTH_QTY' 'LY Same Month'          16 'MEINS'.
      add_col 'L3M_QTY'    'L3 Month Total'         16 'MEINS'.
      add_col 'L3M_AVG'    'L3 Month Average'       16 'MEINS'.
      add_col 'AVG_LOAD'   'Average x Load'         16 'MEINS'.
      add_col 'REQ_QTY'    'Requirement Qty'        16 'MEINS'.
      add_col 'BUS_FCST'   'Business Forecast'      16 'MEINS'.
      add_col 'FINAL_QTY'  'Final Forecast Qty'     16 'MEINS'.

  ENDCASE.

  add_col 'ADJ_QTY'   'Additional / (-) Qty' 16 'MEINS'.
  add_col 'TOTAL_QTY' 'Total Forecast Qty'   16 'MEINS'.

  IF p_tonnet = abap_true OR p_tongrs = abap_true.
    add_col 'TON_TOTAL' 'Total Tonnage' 16 ''.
  ENDIF.

  add_col 'MEINS'   'UoM'      4 ''.
  add_col 'MESSAGE' 'Message' 50 ''.

  ls_layo = VALUE #( cwidth_opt = abap_true
                     zebra      = abap_true
                     sel_mode   = 'D'
                     excp_fname = 'LIGHT'
                     grid_title = |Forecast { p_fyear }| ).

  CREATE OBJECT go_handler.
  SET HANDLER go_handler->on_toolbar      FOR go_grid.
  SET HANDLER go_handler->on_user_command FOR go_grid.

  go_grid->set_table_for_first_display(
    EXPORTING is_layout       = ls_layo
    CHANGING  it_fieldcatalog = lt_fcat
              it_outtab       = gt_alv ).

ENDFORM.

*&---------------------------------------------------------------------*
FORM show_log USING pt_msg TYPE bapiret2_t.

  CHECK pt_msg IS NOT INITIAL.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT pt_msg INTO DATA(ls_msg).
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

ENDFORM.

*&---------------------------------------------------------------------*
*& Screen 0100 of ZPP_FORECAST
*&   Element   Type            Line Col  Size
*&   CC_ALV    Custom control   1    1   28 lines x 200 cols
*&
*& Flow logic
*&   PROCESS BEFORE OUTPUT.  MODULE status_0100.
*&   PROCESS AFTER INPUT.    MODULE user_command_0100.
*&
*& GUI status S0100 : SAVE (Ctrl+S), DELE (Shift+F2, icon ICON_DELETE),
*& BACK / EXIT / CANC standard.
*& Title T0100 : '&1 Forecast - Financial Year &2'
*&---------------------------------------------------------------------*
