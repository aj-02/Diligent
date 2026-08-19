*&---------------------------------------------------------------------*
*& Report        ZSD_SCHEME_REPORT
*& Transaction   ZSCHM_RPT
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - Report with Settlement
*&               ALV over the calculated scheme results with a selection
*&               column and a Post button that creates the credit memo
*&               request and the credit memo.
*&
*& Created by    Arnav Johri
*& Reference     FS "Scheme - Pipes" V.01 10.08.2026, assumptions A15-A32, A42
*&
*& The Post button is removed from the GUI status entirely when the user
*& has no ZSD_SCHM_ST authorisation - segregation of duties is enforced
*& by what is on screen, not only by a check at posting time (A37).
*&---------------------------------------------------------------------*
REPORT zsd_scheme_report MESSAGE-ID zsd_scheme.

TABLES: zsdt_schm_hdr, sscrfields.

TYPES: BEGIN OF ty_alv.
         INCLUDE TYPE zsds_schm_res.
TYPES:   stat_text TYPE char20,
       END OF ty_alv,
       tt_alv TYPE STANDARD TABLE OF ty_alv WITH DEFAULT KEY.

DATA: gt_alv     TYPE tt_alv,
      go_settle  TYPE REF TO zcl_sd_scheme_settle,
      go_cc      TYPE REF TO cl_gui_custom_container,
      go_grid    TYPE REF TO cl_gui_alv_grid,
      go_handler TYPE REF TO lcl_handler,
      g_ok_code  TYPE sy-ucomm,
      g_post_ok  TYPE abap_bool.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_schno FOR zsdt_schm_hdr-scheme_no,
                s_vkorg FOR zsdt_schm_hdr-vkorg OBLIGATORY,
                s_vtweg FOR zsdt_schm_hdr-vtweg,
                s_spart FOR zsdt_schm_hdr-spart.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_datfr TYPE dats OBLIGATORY,
            p_datto TYPE dats OBLIGATORY.
SELECT-OPTIONS: s_kunnr FOR zsdt_schm_hdr-scheme_no NO INTERVALS.  "customer filter
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
PARAMETERS: p_open  AS CHECKBOX DEFAULT abap_true,   "hide already settled lines
            p_test  AS CHECKBOX.                     "simulate posting only
SELECTION-SCREEN END OF BLOCK b3.


*&---------------------------------------------------------------------*
*& Local ALV handler
*&---------------------------------------------------------------------*
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object.
    METHODS on_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS on_hotspot
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id e_column_id.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_toolbar.

    " Post button only for users holding ZSD_SCHM_ST (A37)
    CHECK g_post_ok = abap_true.

    APPEND VALUE stb_button( butn_type = 3 ) TO e_object->mt_toolbar.

    APPEND VALUE stb_button( function  = 'POST'
                             icon      = CONV #( icon_execute_object )
                             text      = 'Post Settlement'
                             quickinfo = 'Create credit memo request and credit memo'
                           ) TO e_object->mt_toolbar.

    APPEND VALUE stb_button( function  = 'SELALL'
                             icon      = CONV #( icon_select_all )
                             quickinfo = 'Select all payable lines'
                           ) TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD on_user_command.

    CASE e_ucomm.

      WHEN 'POST'.
        PERFORM post_settlement.

      WHEN 'SELALL'.
        " Only lines that are actually payable and not yet settled (A27, A31)
        LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>)
             WHERE cn_value > 0 AND status = 'O'.
          <ls>-mark = abap_true.
        ENDLOOP.
        go_grid->refresh_table_display(
          is_stable = VALUE #( row = abap_true col = abap_true ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_hotspot.

    READ TABLE gt_alv INTO DATA(ls) INDEX e_row_id-index.
    CHECK sy-subrc = 0.

    CASE e_column_id-fieldname.
      WHEN 'CN_ORDER'.
        CHECK ls-cn_order IS NOT INITIAL.
        SET PARAMETER ID 'AUN' FIELD ls-cn_order.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      WHEN 'CN_INVOICE'.
        CHECK ls-cn_invoice IS NOT INITIAL.
        SET PARAMETER ID 'VF' FIELD ls-cn_invoice.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      WHEN 'SCHEME_NO'.
        SET PARAMETER ID 'ZSCHEME' FIELD ls-scheme_no.
        CALL TRANSACTION 'ZSCHM03'.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
INITIALIZATION.

  " Default the settlement window to the current month
  p_datto = sy-datum.
  p_datfr = |{ sy-datum(6) }01|.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF p_datto < p_datfr.
    MESSAGE e004.
  ENDIF.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM select_data.

  IF gt_alv IS INITIAL.
    MESSAGE s029 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  CALL SCREEN 0100.


*&---------------------------------------------------------------------*
FORM select_data.

  DATA lt_res TYPE zcl_sd_scheme_settle=>tt_res.
  DATA lt_msg TYPE bapiret2_t.

  CLEAR gt_alv.

  CREATE OBJECT go_settle.

  go_settle->simulate(
    EXPORTING ir_scheme_no = s_schno[]
              ir_kunnr     = s_kunnr[]
              iv_date_from = p_datfr
              iv_date_to   = p_datto
              iv_only_open = p_open
    IMPORTING et_res       = lt_res
              et_msg       = lt_msg ).

  " The simulate method is scheme-driven; the sales-area selection screen
  " values narrow the result afterwards
  LOOP AT lt_res INTO DATA(ls_res).

    CHECK ls_res-vkorg IN s_vkorg
      AND ls_res-vtweg IN s_vtweg
      AND ls_res-spart IN s_spart.

    APPEND VALUE ty_alv(
      BASE CORRESPONDING #( ls_res )
      stat_text = zcl_sd_scheme_ui=>get_setl_status_text( ls_res-status ) ) TO gt_alv.

  ENDLOOP.

  SORT gt_alv BY scheme_no period_seq kunnr.

  " Post authorisation is evaluated once, per sales organisation selected
  g_post_ok = abap_false.
  LOOP AT gt_alv INTO DATA(ls_chk).
    IF zcl_sd_scheme_settle=>check_post_authority( ls_chk-vkorg ) = abap_true.
      g_post_ok = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'S0100'.
  SET TITLEBAR  'T0100' WITH p_datfr p_datto.

  PERFORM build_alv.

ENDMODULE.

*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA(lv_ok) = g_ok_code.
  CLEAR g_ok_code.

  CASE lv_ok.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF go_grid IS BOUND. go_grid->free( ). CLEAR go_grid. ENDIF.
      IF go_cc   IS BOUND. go_cc->free( ).   CLEAR go_cc.   ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'REFR'.
      PERFORM select_data.
      go_grid->refresh_table_display(
        is_stable = VALUE #( row = abap_true col = abap_true ) ).
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& ALV. Column order follows the four blocks of FS section 2.1 exactly.
*&---------------------------------------------------------------------*
FORM build_alv.

  DATA: lt_fcat TYPE lvc_t_fcat,
        ls_layo TYPE lvc_s_layo.

  IF go_grid IS BOUND.
    go_grid->refresh_table_display(
      is_stable = VALUE #( row = abap_true col = abap_true ) ).
    RETURN.
  ENDIF.

  CREATE OBJECT go_cc  EXPORTING container_name = 'CC_ALV'.
  CREATE OBJECT go_grid EXPORTING i_parent       = go_cc.

  DEFINE add_col.
    APPEND VALUE lvc_s_fcat( fieldname = &1
                             coltext   = &2
                             outputlen = &3 ) TO lt_fcat.
  END-OF-DEFINITION.

  " selection column - the FS's "selection option"
  APPEND VALUE lvc_s_fcat( fieldname = 'MARK'
                           coltext   = 'Sel'
                           checkbox  = abap_true
                           edit      = abap_true
                           outputlen = 3 ) TO lt_fcat.

  APPEND VALUE lvc_s_fcat( fieldname = 'LIGHT'
                           coltext   = 'St'
                           outputlen = 3 ) TO lt_fcat.

  "--- block 1: scheme -------------------------------------------------
  APPEND VALUE lvc_s_fcat( fieldname = 'SCHEME_NO'
                           coltext   = 'Scheme No'
                           hotspot   = abap_true
                           outputlen = 10 ) TO lt_fcat.
  add_col 'DESCR'       'Scheme Description' 30.
  add_col 'SCHEME_TYPE' 'Scheme Type'         6.
  add_col 'SCHEME_CAT'  'Scheme Category'     8.
  add_col 'TARGET_VAL'  'Target Value'       16.
  add_col 'TARGET_QTY'  'Target Quantity'    16.
  add_col 'VALID_FROM'  'Valid From'         10.
  add_col 'VALID_TO'    'Valid To'           10.

  "--- block 2: selection ----------------------------------------------
  add_col 'MVGR1'     'Material Group 1' 6.
  add_col 'MVGR2'     'Material Group 2' 6.
  add_col 'MVGR3'     'Material Group 3' 6.
  add_col 'MVGR4'     'Material Group 4' 6.
  add_col 'MVGR5'     'Material Group 5' 6.
  add_col 'SPART'     'Division'         4.
  add_col 'VTWEG'     'Dis. Channel'     4.
  add_col 'WKREG'     'State'            5.
  add_col 'PAR_CHILD' 'Parent / Child'   4.
  add_col 'KUNNR'     'Customer'        10.
  add_col 'NAME1'     'Customer Name'   30.

  "--- block 3: customer -----------------------------------------------
  add_col 'KVGR1'      'Customer Group 1' 6.
  add_col 'KVGR2'      'Customer Group 2' 6.
  add_col 'LOC1'       'Location 1'      20.
  add_col 'LOC2'       'Location 2'      20.
  add_col 'SCHEME_PCT' 'CN %'             7.
  add_col 'SCHM_TEXT'  'Text'            40.

  "--- block 4: values -------------------------------------------------
  add_col 'PER_FROM'  'Period From'   10.
  add_col 'PER_TO'    'Period To'     10.
  add_col 'BUS_VOL'   'Business Volume' 18.
  add_col 'BUS_QTY'   'Business Qty'    16.
  add_col 'TARGET_MET' 'Achieved'        4.
  add_col 'EB_AMOUNT' 'Early Bird Amount' 18.
  add_col 'CASC_VAL'  'Cascading Value'   18.
  add_col 'MAIN_CN'   'Scheme CN'         18.
  add_col 'CN_VALUE'  'CN Value'          18.

  APPEND VALUE lvc_s_fcat( fieldname = 'CN_ORDER'
                           coltext   = 'CN Order No.'
                           hotspot   = abap_true
                           outputlen = 10 ) TO lt_fcat.
  APPEND VALUE lvc_s_fcat( fieldname = 'CN_INVOICE'
                           coltext   = 'CN Invoice No.'
                           hotspot   = abap_true
                           outputlen = 10 ) TO lt_fcat.

  add_col 'STAT_TEXT' 'Settlement Status' 20.
  add_col 'MESSAGE'   'Message'           60.

  " Currency and quantity reference so amounts format correctly
  LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<ls_f>)
       WHERE fieldname = 'BUS_VOL'   OR fieldname = 'EB_AMOUNT'
          OR fieldname = 'CASC_VAL'  OR fieldname = 'MAIN_CN'
          OR fieldname = 'CN_VALUE'  OR fieldname = 'TARGET_VAL'.
    <ls_f>-cfieldname = 'WAERS'.
  ENDLOOP.

  ls_layo = VALUE #( cwidth_opt = abap_true
                     zebra      = abap_true
                     sel_mode   = 'D'
                     excp_fname = 'LIGHT'
                     grid_title = |Scheme Settlement { p_datfr DATE = USER } - { p_datto DATE = USER }| ).

  CREATE OBJECT go_handler.
  SET HANDLER go_handler->on_toolbar      FOR go_grid.
  SET HANDLER go_handler->on_user_command FOR go_grid.
  SET HANDLER go_handler->on_hotspot      FOR go_grid.

  go_grid->set_table_for_first_display(
    EXPORTING is_layout       = ls_layo
    CHANGING  it_fieldcatalog = lt_fcat
              it_outtab       = gt_alv ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Post button
*&---------------------------------------------------------------------*
FORM post_settlement.

  DATA lv_answer TYPE char1.

  go_grid->check_changed_data( ).

  IF NOT line_exists( gt_alv[ mark = abap_true ] ).
    MESSAGE e035.
    RETURN.
  ENDIF.

  DATA(lv_count) = REDUCE i( INIT n = 0
                             FOR ls IN gt_alv WHERE ( mark = abap_true )
                             NEXT n = n + 1 ).

  DATA(lv_total) = REDUCE netwr( INIT v = CONV netwr( 0 )
                                 FOR ls IN gt_alv WHERE ( mark = abap_true )
                                 NEXT v = v + ls-cn_value ).

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING titlebar              = 'Post Settlement'
              text_question         = |Create credit memos for { lv_count } line(s), | &&
                                      |total value { lv_total } ?|
              text_button_1         = 'Post'
              text_button_2         = 'Cancel'
              default_button        = '2'
              display_cancel_button = abap_false
    IMPORTING answer                = lv_answer
    EXCEPTIONS OTHERS               = 1.

  CHECK lv_answer = '1'.

  DATA lt_res TYPE zcl_sd_scheme_settle=>tt_res.
  lt_res = CORRESPONDING #( gt_alv ).

  DATA(lt_msg) = go_settle->post( EXPORTING iv_test = p_test
                                  CHANGING  ct_res  = lt_res ).

  " Write the posting outcome back to the displayed table
  LOOP AT lt_res INTO DATA(ls_res).
    READ TABLE gt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>)
      WITH KEY scheme_no  = ls_res-scheme_no
               period_seq = ls_res-period_seq
               kunnr      = ls_res-kunnr.
    CHECK sy-subrc = 0.
    <ls_alv>-cn_order   = ls_res-cn_order.
    <ls_alv>-cn_invoice = ls_res-cn_invoice.
    <ls_alv>-status     = ls_res-status.
    <ls_alv>-message    = ls_res-message.
    <ls_alv>-light      = ls_res-light.
    <ls_alv>-mark       = ls_res-mark.
    <ls_alv>-stat_text  = zcl_sd_scheme_ui=>get_setl_status_text( ls_res-status ).
  ENDLOOP.

  go_grid->refresh_table_display(
    is_stable = VALUE #( row = abap_true col = abap_true ) ).

  PERFORM show_log USING lt_msg.

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
*& Screen 0100 of ZSD_SCHEME_REPORT
*&   Element     Type            Line Col  Size
*&   CC_ALV      Custom control   1    1   28 lines x 200 cols
*&
*& Flow logic
*&   PROCESS BEFORE OUTPUT.
*&     MODULE status_0100.
*&   PROCESS AFTER INPUT.
*&     MODULE user_command_0100.
*&
*& GUI status S0100 : BACK / EXIT / CANC standard, REFR in the
*& application toolbar (icon ICON_REFRESH, text Refresh, key F8).
*& Title T0100 : 'Scheme Settlement &1 to &2'
*&---------------------------------------------------------------------*
