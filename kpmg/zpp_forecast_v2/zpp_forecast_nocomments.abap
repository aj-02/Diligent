REPORT zpp_forecast MESSAGE-ID zpp_fcst.

TABLES: marc, sscrfields.

TYPES tt_fname TYPE STANDARD TABLE OF lvc_fname WITH DEFAULT KEY.

CONSTANTS gc_show_extras TYPE abap_bool VALUE abap_false.

CONSTANTS gc_status TYPE sypfkey VALUE 'PF_STATUS'.

DATA: gt_msg  TYPE bapiret2_t,
      gt_show TYPE tt_fname,
      gt_alv  TYPE zcl_pp_fcst=>tt_alv,
      go_fcst TYPE REF TO zcl_pp_fcst,
      go_alv  TYPE REF TO cl_salv_table,
      g_mode  TYPE char1,
      g_quart TYPE zde_quarter.

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_ann RADIOBUTTON GROUP mod USER-COMMAND md DEFAULT 'X',
            p_qtr RADIOBUTTON GROUP mod,
            p_mth RADIOBUTTON GROUP mod.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_werks FOR marc-werks,
                s_matnr FOR marc-matnr.
PARAMETERS: p_fyear TYPE zde_fyear,
            p_quart TYPE zde_quarter MODIF ID qtr,
            p_perio TYPE poper       MODIF ID mth.
SELECT-OPTIONS: s_datum FOR sy-datum NO-EXTENSION MODIF ID dat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_tonn AS CHECKBOX,
            p_legc AS CHECKBOX,
            p_save AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.

CLASS lcl_handler DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS on_added_function
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

    CLASS-METHODS show_log
      IMPORTING it_msg TYPE bapiret2_t.

  PRIVATE SECTION.

    CLASS-METHODS save_selected.
    CLASS-METHODS select_all
      IMPORTING iv_on TYPE abap_bool.
    CLASS-METHODS export.

ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_added_function.

    CASE e_salv_function.

      WHEN 'ZSAVE'.
        save_selected( ).

      WHEN 'ZSELALL'.
        select_all( abap_true ).

      WHEN 'ZDESEL'.
        select_all( abap_false ).

      WHEN 'ZEXCEL'.
        export( ).

      WHEN 'BACK' OR 'EXIT' OR 'CANC'.
        LEAVE TO SCREEN 0.

      WHEN OTHERS.
        RETURN.

    ENDCASE.

  ENDMETHOD.

  METHOD save_selected.

    DATA lv_row TYPE i.

    DATA(lt_rows) = go_alv->get_selections( )->get_selected_rows( ).

    IF lt_rows IS INITIAL.
      MESSAGE s017 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>).
      <ls>-mark = abap_false.
    ENDLOOP.

    LOOP AT lt_rows INTO lv_row.
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

  METHOD select_all.

    DATA: lt_rows TYPE salv_t_row,
          lv_row  TYPE i.

    IF iv_on = abap_true.
      lv_row = 1.
      WHILE lv_row <= lines( gt_alv ).
        APPEND lv_row TO lt_rows.
        lv_row = lv_row + 1.
      ENDWHILE.
    ENDIF.

    go_alv->get_selections( )->set_selected_rows( lt_rows ).
    go_alv->refresh( ).

  ENDMETHOD.

  METHOD export.

    DATA: lt_out  TYPE string_table,
          lv_line TYPE string,
          lv_val  TYPE string,
          lv_col  TYPE lvc_fname,
          lv_tab  TYPE c LENGTH 1,
          lv_file TYPE string,
          lv_path TYPE string,
          lv_full TYPE string,
          lv_msg  TYPE string,
          lv_ix   TYPE i.

    FIELD-SYMBOLS <lv_f> TYPE any.

    IF gt_alv IS INITIAL.
      MESSAGE s008 DISPLAY LIKE 'I'.
      RETURN.
    ENDIF.

    lv_tab = cl_abap_char_utilities=>horizontal_tab.

    CLEAR lv_line.
    LOOP AT gt_show INTO lv_col.
      IF lv_line IS INITIAL.
        lv_line = lv_col.
      ELSE.
        CONCATENATE lv_line lv_tab lv_col INTO lv_line.
      ENDIF.
    ENDLOOP.
    APPEND lv_line TO lt_out.

    LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>).

      CLEAR: lv_line, lv_ix.

      LOOP AT gt_show INTO lv_col.

        lv_ix = lv_ix + 1.
        CLEAR lv_val.
        UNASSIGN <lv_f>.
        ASSIGN COMPONENT lv_col OF STRUCTURE <ls> TO <lv_f>.
        IF <lv_f> IS ASSIGNED.
          lv_val = <lv_f>.
          CONDENSE lv_val.
        ENDIF.

        IF lv_ix = 1.
          lv_line = lv_val.
        ELSE.
          CONCATENATE lv_line lv_tab lv_val INTO lv_line.
        ENDIF.

      ENDLOOP.

      APPEND lv_line TO lt_out.

    ENDLOOP.

    CONCATENATE 'ZFORECAST_' g_mode '.txt' INTO lv_file.

    cl_gui_frontend_services=>file_save_dialog(
      EXPORTING  default_file_name = lv_file
                 default_extension = 'txt'
      CHANGING   filename          = lv_file
                 path              = lv_path
                 fullpath          = lv_full
      EXCEPTIONS OTHERS            = 1 ).

    IF sy-subrc <> 0 OR lv_full IS INITIAL.
      RETURN.
    ENDIF.

    cl_gui_frontend_services=>gui_download(
      EXPORTING  filename         = lv_full
                 filetype         = 'ASC'
      CHANGING   data_tab         = lt_out
      EXCEPTIONS file_write_error = 1
                 OTHERS           = 2 ).

    IF sy-subrc = 0.
      CONCATENATE 'List saved to' lv_full INTO lv_msg SEPARATED BY space.
      MESSAGE lv_msg TYPE 'S'.
    ELSE.
      MESSAGE e013 WITH lv_full.
    ENDIF.

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

INITIALIZATION.

  DATA(gv_y) = CONV i( sy-datum(4) ).
  IF sy-datum+4(2) < '04'.
    gv_y = gv_y - 1.
  ENDIF.
  p_fyear = |{ gv_y }-{ gv_y + 1 }|.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'QTR'. screen-active = COND #( WHEN p_qtr = abap_true THEN 1 ELSE 0 ).
      WHEN 'MTH'. screen-active = COND #( WHEN p_mth = abap_true THEN 1 ELSE 0 ).
      WHEN 'DAT'. screen-active = COND #( WHEN p_ann = abap_true THEN 0 ELSE 1 ).
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fyear.

  PERFORM f4_fyear.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_quart.

  PERFORM f4_quart.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_perio.

  PERFORM f4_perio.

AT SELECTION-SCREEN.

  IF sscrfields-ucomm = 'MD'.
    RETURN.
  ENDIF.

  IF s_werks[] IS INITIAL.
    MESSAGE e001.
  ENDIF.

  IF zcl_pp_fcst_util=>split_fyear( p_fyear ) = abap_false.
    MESSAGE e002 WITH p_fyear.
  ENDIF.

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

START-OF-SELECTION.

  PERFORM generate.

  PERFORM save_log.

  IF gt_alv IS INITIAL.
    MESSAGE s008 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  IF p_save = abap_true.
    PERFORM save_all.
  ENDIF.

  PERFORM display.

  PERFORM save_prompt.

FORM save_log.

  DATA: ls_log    TYPE bal_s_log,
        ls_bal    TYPE bal_s_msg,
        ls_msg    TYPE bapiret2,
        lv_handle TYPE balloghndl,
        lt_handle TYPE bal_t_logh.

  CHECK gt_msg IS NOT INITIAL.

  ls_log-object    = 'ZPP_FCST'.
  ls_log-subobject = 'GENERATE'.
  ls_log-aldate    = sy-datum.
  ls_log-altime    = sy-uzeit.
  ls_log-aluser    = sy-uname.
  ls_log-alprog    = sy-repid.

  ls_log-extnumber = |{ g_mode } { p_fyear } { sy-uname }|.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING  i_s_log      = ls_log
    IMPORTING  e_log_handle = lv_handle
    EXCEPTIONS OTHERS       = 1.

  CHECK sy-subrc = 0.

  LOOP AT gt_msg INTO ls_msg.
    CLEAR ls_bal.
    ls_bal-msgty = ls_msg-type.
    ls_bal-msgid = ls_msg-id.
    ls_bal-msgno = ls_msg-number.
    ls_bal-msgv1 = ls_msg-message_v1.
    ls_bal-msgv2 = ls_msg-message_v2.
    ls_bal-msgv3 = ls_msg-message_v3.
    ls_bal-msgv4 = ls_msg-message_v4.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING  i_log_handle = lv_handle
                 i_s_msg      = ls_bal
      EXCEPTIONS OTHERS       = 1.
  ENDLOOP.

  APPEND lv_handle TO lt_handle.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING  i_t_log_handle = lt_handle
               i_save_all     = abap_true
    EXCEPTIONS OTHERS         = 1.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.

FORM generate.

  DATA lt_msg TYPE bapiret2_t.

  CLEAR: gt_alv, gt_msg.
  CREATE OBJECT go_fcst.

  g_mode = COND #( WHEN p_ann = abap_true THEN zcl_pp_fcst=>gc_mode-annual
                   WHEN p_qtr = abap_true THEN zcl_pp_fcst=>gc_mode-quarterly
                   ELSE                        zcl_pp_fcst=>gc_mode-monthly ).

  PERFORM resolve_quarter.

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
                                             iv_quarter = g_quart
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

  gt_msg = lt_msg.

ENDFORM.

FORM save_all.

  DATA ls_w LIKE LINE OF s_werks.

  LOOP AT s_werks INTO ls_w.
    IF zcl_pp_fcst_util=>check_authority( iv_werks = ls_w-low
                                          iv_actvt = '01' ) = abap_false.
      MESSAGE e010 WITH ls_w-low '01'.
    ENDIF.
  ENDLOOP.

  LOOP AT gt_alv ASSIGNING FIELD-SYMBOL(<ls>).
    <ls>-mark = abap_true.
  ENDLOOP.

  DATA(lt_msg) = go_fcst->save( EXPORTING iv_mode = g_mode
                                CHANGING  ct_alv  = gt_alv ).

  lcl_handler=>show_log( lt_msg ).

  APPEND LINES OF lt_msg TO gt_msg.

ENDFORM.

FORM display.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                              CHANGING  t_table      = gt_alv ).

      go_alv->get_functions( )->set_all( ).

      DATA(lv_save_ok) = abap_true.

      LOOP AT s_werks INTO DATA(ls_w2).
        IF zcl_pp_fcst_util=>check_authority( iv_werks = ls_w2-low
                                              iv_actvt = '01' ) = abap_false.
          lv_save_ok = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_save_ok = abap_true.
        go_alv->set_screen_status(
          pfstatus      = gc_status
          report        = sy-repid
          set_functions = cl_salv_table=>c_functions_all ).
      ENDIF.

      go_alv->get_selections( )->set_selection_mode(
        if_salv_c_selection_mode=>row_column ).

      SET HANDLER lcl_handler=>on_added_function FOR go_alv->get_event( ).

      PERFORM visible_columns CHANGING gt_show.
      PERFORM setup_columns   USING    gt_show.

      DATA(lv_head) = |{ SWITCH string( g_mode
                                        WHEN 'A' THEN 'Annual'
                                        WHEN 'Q' THEN 'Quarterly'
                                        ELSE          'Monthly' ) }| &&
                      | Forecast - { p_fyear }|.

      go_alv->get_display_settings( )->set_list_header( CONV lvc_title( lv_head ) ).

      TRY.
          go_alv->display( ).
        CATCH cx_salv_object_not_found.
          DATA(lv_stmsg) = |GUI status { gc_status } not found in { sy-repid }, | &&
                           |standard toolbar used|.
          MESSAGE lv_stmsg TYPE 'S' DISPLAY LIKE 'W'.
          go_alv->set_screen_status(
            report        = 'SAPLSALV_METADATA_STATUS'
            pfstatus      = 'SALV_STANDARD'
            set_functions = cl_salv_table=>c_functions_all ).
          go_alv->display( ).
      ENDTRY.

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error
          cx_salv_existing cx_salv_wrong_call
          cx_salv_object_not_found INTO DATA(lx_salv).
      DATA(lv_err) = lx_salv->get_text( ).
      MESSAGE lv_err TYPE 'E'.
  ENDTRY.

ENDFORM.

FORM visible_columns CHANGING ct_show TYPE tt_fname.

  DATA lv_p TYPE numc2.

  CLEAR ct_show.

  APPEND 'WERKS'     TO ct_show.
  APPEND 'MATNR'     TO ct_show.
  APPEND 'MAKTX'     TO ct_show.
  APPEND 'MATKL'     TO ct_show.
  APPEND 'NTGEW'     TO ct_show.
  APPEND 'MVGR1_TXT' TO ct_show.
  APPEND 'MVGR2_TXT' TO ct_show.
  APPEND 'MVGR3_TXT' TO ct_show.
  APPEND 'MVGR4_TXT' TO ct_show.
  APPEND 'MVGR5_TXT' TO ct_show.

  CASE g_mode.

    WHEN zcl_pp_fcst=>gc_mode-annual.

      DO 12 TIMES.
        lv_p = sy-index.
        APPEND CONV lvc_fname( |M{ lv_p }| ) TO ct_show.
      ENDDO.

      APPEND 'LY_TOTAL'   TO ct_show.
      APPEND 'PROD_CAT'   TO ct_show.
      APPEND 'MTS_MTO'    TO ct_show.
      APPEND 'LOAD_FCT'   TO ct_show.
      APPEND 'FCST_TOTAL' TO ct_show.

      DO 12 TIMES.
        lv_p = sy-index.
        APPEND CONV lvc_fname( |M{ lv_p }_FCST| ) TO ct_show.
      ENDDO.

      IF p_tonn = abap_true.
        DO 12 TIMES.
          lv_p = sy-index.
          APPEND CONV lvc_fname( |M{ lv_p }_TON| ) TO ct_show.
        ENDDO.
      ENDIF.

    WHEN zcl_pp_fcst=>gc_mode-quarterly.

      APPEND 'M4_LAST'    TO ct_show.
      APPEND 'M5_LAST'    TO ct_show.
      APPEND 'M6_LAST'    TO ct_show.
      APPEND 'LY_QTR_TOT' TO ct_show.
      APPEND 'M1_CURR'    TO ct_show.
      APPEND 'M2_CURR'    TO ct_show.
      APPEND 'M3_CURR'    TO ct_show.
      APPEND 'L3M_TOT'    TO ct_show.
      APPEND 'MAX_QTY'    TO ct_show.
      APPEND 'PROD_CAT'   TO ct_show.
      APPEND 'LOAD_FCT'   TO ct_show.
      APPEND 'FCST_QTY'   TO ct_show.
      APPEND 'BUS_FCST'   TO ct_show.
      APPEND 'FINAL_QTY'  TO ct_show.
      APPEND 'M4_FCST'    TO ct_show.
      APPEND 'M5_FCST'    TO ct_show.
      APPEND 'M6_FCST'    TO ct_show.

      IF p_tonn = abap_true.
        APPEND 'M4_TON' TO ct_show.
        APPEND 'M5_TON' TO ct_show.
        APPEND 'M6_TON' TO ct_show.
      ENDIF.

      APPEND 'MTS_MTO'    TO ct_show.

    WHEN zcl_pp_fcst=>gc_mode-monthly.

      APPEND 'M4_LAST'      TO ct_show.
      APPEND 'M5_LAST'      TO ct_show.
      APPEND 'M6_LAST'      TO ct_show.
      APPEND 'LY_QTR_TOT'   TO ct_show.
      APPEND 'M1_CURR'      TO ct_show.
      APPEND 'M2_CURR'      TO ct_show.
      APPEND 'M3_CURR'      TO ct_show.
      APPEND 'L3M_AVG'      TO ct_show.
      APPEND 'PROD_CAT'     TO ct_show.
      APPEND 'LOAD_FCT'     TO ct_show.
      APPEND 'MAX_QTY'      TO ct_show.
      APPEND 'FCST_QTY'     TO ct_show.
      APPEND 'BUS_FCST'     TO ct_show.
      APPEND 'FINAL_QTY'    TO ct_show.
      APPEND 'BUS_FCST_ADD' TO ct_show.
      APPEND 'TOTAL_QTY'    TO ct_show.

      IF p_tonn = abap_true.
        APPEND 'M4_TON' TO ct_show.
      ENDIF.

  ENDCASE.

  APPEND 'PRICE' TO ct_show.

  IF p_save = abap_true.
    APPEND 'FCST_NO' TO ct_show.
    APPEND 'MESSAGE' TO ct_show.
  ENDIF.

  IF gc_show_extras = abap_true.

    IF g_mode = zcl_pp_fcst=>gc_mode-quarterly.
      APPEND 'BUS_FCST_ADD' TO ct_show.
    ELSEIF g_mode = zcl_pp_fcst=>gc_mode-monthly.
      APPEND 'MTS_MTO' TO ct_show.
    ENDIF.

    APPEND 'MEINS'   TO ct_show.
    APPEND 'FCST_NO' TO ct_show.
    APPEND 'LIGHT'   TO ct_show.
    APPEND 'MESSAGE' TO ct_show.

  ENDIF.

ENDFORM.

FORM setup_columns USING pt_show TYPE tt_fname.

  DATA: lv_col TYPE lvc_fname,
        lv_hdr TYPE string,
        lv_nam TYPE char3,
        lv_pos TYPE i.

  DATA(lo_cols) = go_alv->get_columns( ).
  lo_cols->set_optimize( ).

  IF gc_show_extras = abap_true.
    TRY.
        lo_cols->set_exception_column( 'LIGHT' ).
      CATCH cx_salv_data_error.
    ENDTRY.
  ENDIF.

  DATA(lt_cols) = lo_cols->get( ).

  LOOP AT lt_cols INTO DATA(ls_col).

    READ TABLE pt_show TRANSPORTING NO FIELDS
      WITH KEY table_line = ls_col-columnname.

    IF sy-subrc <> 0.
      TRY.
          ls_col-r_column->set_technical( abap_true ).
        CATCH cx_salv_error.
      ENDTRY.
    ENDIF.

  ENDLOOP.

  lv_pos = 0.
  LOOP AT pt_show INTO lv_col.
    lv_pos = lv_pos + 1.
    TRY.
        lo_cols->set_column_position( columnname = lv_col
                                      position   = lv_pos ).
      CATCH cx_salv_error.
    ENDTRY.
  ENDLOOP.

  IF g_mode = zcl_pp_fcst=>gc_mode-annual.

    DATA(lv_prev) = zcl_pp_fcst_util=>previous_fyear( p_fyear ).

    DO 12 TIMES.

      DATA(lv_p) = CONV numc2( sy-index ).

      zcl_pp_fcst_util=>period_to_yearmonth( EXPORTING iv_fyear  = lv_prev
                                                       iv_period = lv_p
                                             IMPORTING ev_gjahr  = DATA(lv_yy)
                                                       ev_month  = DATA(lv_mm) ).
      lv_col = |M{ lv_p }|.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
      PERFORM txt USING lv_col lv_hdr.

      zcl_pp_fcst_util=>period_to_yearmonth( EXPORTING iv_fyear  = p_fyear
                                                       iv_period = lv_p
                                             IMPORTING ev_gjahr  = lv_yy
                                                       ev_month  = lv_mm ).
      lv_col = |M{ lv_p }_FCST|.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
      PERFORM txt USING lv_col lv_hdr.

      lv_col = |M{ lv_p }_TON|.
      PERFORM month_name USING lv_mm CHANGING lv_nam.
      lv_hdr = |{ lv_nam }-{ lv_yy+2(2) } tonnage|.
      PERFORM txt USING lv_col lv_hdr.

    ENDDO.

    PERFORM txt USING 'LY_TOTAL' 'Total LY Sales Qty'.
    PERFORM txt USING 'LOAD_FCT' 'Load Factor'.

    lv_hdr = |Forecast Qty FY{ p_fyear }|.
    PERFORM txt USING 'FCST_TOTAL' lv_hdr.

  ELSE.

    PERFORM txt USING 'M4_LAST'      'LY Month 1'.
    PERFORM txt USING 'M5_LAST'      'LY Month 2'.
    PERFORM txt USING 'M6_LAST'      'LY Month 3'.
    PERFORM txt USING 'LY_QTR_TOT'   'Total LY Quarter Sales Qty'.
    PERFORM txt USING 'M1_CURR'      'Current Month 1'.
    PERFORM txt USING 'M2_CURR'      'Current Month 2'.
    PERFORM txt USING 'M3_CURR'      'Current Month 3'.
    PERFORM txt USING 'L3M_TOT'      'L3 Month Total Sales Qty'.
    PERFORM txt USING 'L3M_AVG'      'L3 Month Average'.
    PERFORM txt USING 'LOAD_FCT'     'Growth Based on Category'.
    PERFORM txt USING 'BUS_FCST'     'Business Forecast'.
    PERFORM txt USING 'BUS_FCST_ADD' 'Additional Plan Qty'.
    PERFORM txt USING 'FINAL_QTY'    'Final Forecast Qty'.
    PERFORM txt USING 'TOTAL_QTY'    'Final Fcst Qty incl. Additional'.
    PERFORM txt USING 'M4_FCST'      'Month 1'.
    PERFORM txt USING 'M5_FCST'      'Month 2'.
    PERFORM txt USING 'M6_FCST'      'Month 3'.
    PERFORM txt USING 'M4_TON'       'Month 1 tonnage'.
    PERFORM txt USING 'M5_TON'       'Month 2 tonnage'.
    PERFORM txt USING 'M6_TON'       'Month 3 tonnage'.

    IF g_mode = zcl_pp_fcst=>gc_mode-quarterly.
      PERFORM txt USING 'MAX_QTY'  'Max. Qty'.
      PERFORM txt USING 'FCST_QTY' 'Forecast (Max * Growth %)'.
    ELSE.
      PERFORM txt USING 'MAX_QTY'  'Average * Load'.
      PERFORM txt USING 'FCST_QTY' 'LY vs Current Requirement Qty'.
    ENDIF.

    PERFORM month_headings.

  ENDIF.

  PERFORM txt USING 'PROD_CAT'  'Product Cat.'.
  PERFORM txt USING 'MTS_MTO'   'MTS / MTO'.
  PERFORM txt USING 'NTGEW'     'Net Weight'.
  PERFORM txt USING 'PRICE'     'Price'.
  PERFORM txt USING 'MVGR1_TXT' 'Material Group 1'.
  PERFORM txt USING 'MVGR2_TXT' 'Material Group 2'.
  PERFORM txt USING 'MVGR3_TXT' 'Material Group 3'.
  PERFORM txt USING 'MVGR4_TXT' 'Material Group 4'.
  PERFORM txt USING 'MVGR5_TXT' 'Material Group 5'.
  PERFORM txt USING 'FCST_NO'   'Forecast Number'.

ENDFORM.

FORM resolve_quarter.

  DATA: lv_month TYPE numc2,
        lv_per   TYPE numc2,
        lv_date  TYPE dats.

  CLEAR g_quart.

  CASE g_mode.

    WHEN zcl_pp_fcst=>gc_mode-quarterly.

      IF p_quart IS NOT INITIAL.
        g_quart = p_quart.
        RETURN.
      ENDIF.

      READ TABLE s_datum INTO DATA(ls_dt) INDEX 1.
      CHECK sy-subrc = 0.

      lv_date = ls_dt-low.
      CHECK lv_date IS NOT INITIAL.

      lv_month = lv_date+4(2).
      lv_per   = zcl_pp_fcst_util=>month_to_period( lv_month ).
      g_quart  = zcl_pp_fcst_util=>period_to_quarter( lv_per ).

    WHEN zcl_pp_fcst=>gc_mode-monthly.

      CHECK p_perio IS NOT INITIAL.
      lv_per  = p_perio.
      g_quart = zcl_pp_fcst_util=>period_to_quarter( lv_per ).

  ENDCASE.

ENDFORM.

FORM month_headings.

  DATA: lv_nam TYPE char3,
        lv_hdr TYPE string,
        lv_col TYPE lvc_fname,
        lv_ix  TYPE i,
        lv_qi  TYPE i,
        lv_per TYPE numc2,
        lv_yy  TYPE gjahr,
        lv_mm  TYPE numc2.

  CHECK g_quart IS NOT INITIAL.

  DATA(lt_ly) = zcl_pp_fcst_util=>last_year_quarter( iv_fyear   = p_fyear
                                                     iv_quarter = g_quart ).

  lv_ix = 3.
  LOOP AT lt_ly INTO DATA(ls_ly).
    lv_ix  = lv_ix + 1.
    lv_yy  = ls_ly-gjahr.
    lv_mm  = ls_ly-month.
    PERFORM month_name USING lv_mm CHANGING lv_nam.
    lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
    lv_col = |M{ lv_ix }_LAST|.
    PERFORM txt USING lv_col lv_hdr.
  ENDLOOP.

  lv_hdr = |Total LY Q{ g_quart } Sales Qty|.
  PERFORM txt USING 'LY_QTR_TOT' lv_hdr.

  IF g_mode = zcl_pp_fcst=>gc_mode-monthly.
    lv_per = p_perio.
  ELSE.
    lv_qi  = g_quart.
    lv_per = ( lv_qi - 1 ) * 3 + 1.
  ENDIF.

  DATA(lt_l3m) = zcl_pp_fcst_util=>last_three_months( iv_fyear  = p_fyear
                                                      iv_period = lv_per ).

  lv_ix = 0.
  LOOP AT lt_l3m INTO DATA(ls_l3).
    lv_ix  = lv_ix + 1.
    lv_yy  = ls_l3-gjahr.
    lv_mm  = ls_l3-month.
    PERFORM month_name USING lv_mm CHANGING lv_nam.
    lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
    lv_col = |M{ lv_ix }_CURR|.
    PERFORM txt USING lv_col lv_hdr.
  ENDLOOP.

  IF g_mode = zcl_pp_fcst=>gc_mode-quarterly.

    DATA(lt_qtr) = zcl_pp_fcst_util=>quarter_periods( iv_fyear   = p_fyear
                                                      iv_quarter = g_quart ).

    lv_ix = 3.
    LOOP AT lt_qtr INTO DATA(ls_q).
      lv_ix  = lv_ix + 1.
      lv_yy  = ls_q-gjahr.
      lv_mm  = ls_q-month.
      PERFORM month_name USING lv_mm CHANGING lv_nam.

      lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
      lv_col = |M{ lv_ix }_FCST|.
      PERFORM txt USING lv_col lv_hdr.

      lv_hdr = |{ lv_nam }-{ lv_yy+2(2) } tonnage|.
      lv_col = |M{ lv_ix }_TON|.
      PERFORM txt USING lv_col lv_hdr.
    ENDLOOP.

  ELSE.

    lv_per = p_perio.
    zcl_pp_fcst_util=>period_to_yearmonth( EXPORTING iv_fyear  = p_fyear
                                                     iv_period = lv_per
                                           IMPORTING ev_gjahr  = lv_yy
                                                     ev_month  = lv_mm ).
    PERFORM month_name USING lv_mm CHANGING lv_nam.

    lv_hdr = |{ lv_nam }-{ lv_yy+2(2) }|.
    PERFORM txt USING 'M4_FCST' lv_hdr.

    lv_hdr = |{ lv_nam }-{ lv_yy+2(2) } tonnage|.
    PERFORM txt USING 'M4_TON' lv_hdr.

    lv_hdr = |Additional Plan Qty { lv_nam }-{ lv_yy+2(2) }|.
    PERFORM txt USING 'BUS_FCST_ADD' lv_hdr.

  ENDIF.

ENDFORM.

FORM save_prompt.

  DATA: lv_ans  TYPE c LENGTH 1,
        lv_q    TYPE char100,
        lv_rows TYPE char10.

  CHECK p_save = abap_false.
  CHECK gt_alv IS NOT INITIAL.
  CHECK go_fcst IS BOUND.

  LOOP AT s_werks INTO DATA(ls_w3).
    IF zcl_pp_fcst_util=>check_authority( iv_werks = ls_w3-low
                                          iv_actvt = '01' ) = abap_false.
      RETURN.
    ENDIF.
  ENDLOOP.

  lv_rows = lines( gt_alv ).
  CONDENSE lv_rows.
  CONCATENATE 'Save' lv_rows 'forecast row(s) for' p_fyear
         INTO lv_q SEPARATED BY space.
  CONCATENATE lv_q '?' INTO lv_q.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING  titlebar              = 'Save forecast'
               text_question         = lv_q
               text_button_1         = 'Save'
               text_button_2         = 'Do not save'
               default_button        = '2'
               display_cancel_button = abap_false
    IMPORTING  answer                = lv_ans
    EXCEPTIONS text_not_found        = 1
               OTHERS                = 2.

  CHECK sy-subrc = 0 AND lv_ans = '1'.

  PERFORM save_all.

ENDFORM.

FORM month_name USING pv_mm TYPE any
                CHANGING cv_name TYPE any.

  CONSTANTS lc_names TYPE char36
    VALUE 'JanFebMarAprMayJunJulAugSepOctNovDec'.

  DATA: lv_i   TYPE i,
        lv_off TYPE i.

  CLEAR cv_name.

  lv_i = pv_mm.
  CHECK lv_i >= 1 AND lv_i <= 12.

  lv_off  = ( lv_i - 1 ) * 3.
  cv_name = lc_names+lv_off(3).

ENDFORM.

FORM f4_fyear.

  TYPES: BEGIN OF ty_f4,
           fyear TYPE char9,
           text  TYPE char30,
         END OF ty_f4.

  DATA: lt_f4  TYPE STANDARD TABLE OF ty_f4 WITH DEFAULT KEY,
        ls_f4  TYPE ty_f4,
        lt_ret TYPE STANDARD TABLE OF ddshretval WITH DEFAULT KEY,
        ls_ret TYPE ddshretval,
        lv_y   TYPE i,
        lv_nx  TYPE i.

  lv_y = sy-datum(4).
  IF sy-datum+4(2) < '04'.
    lv_y = lv_y - 1.
  ENDIF.

  lv_y = lv_y - 5.

  DO 11 TIMES.
    CLEAR ls_f4.
    lv_nx = lv_y + 1.
    ls_f4-fyear = |{ lv_y }-{ lv_nx }|.
    ls_f4-text  = |April { lv_y } to March { lv_nx }|.
    APPEND ls_f4 TO lt_f4.
    lv_y = lv_y + 1.
  ENDDO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING  retfield        = 'FYEAR'
               dynpprog        = sy-repid
               dynpnr          = sy-dynnr
               dynprofield     = 'P_FYEAR'
               value_org       = 'S'
    TABLES     value_tab       = lt_f4
               return_tab      = lt_ret
    EXCEPTIONS parameter_error = 1
               no_values_found = 2
               OTHERS          = 3.

  IF sy-subrc = 0.
    READ TABLE lt_ret INTO ls_ret INDEX 1.
    IF sy-subrc = 0.
      p_fyear = ls_ret-fieldval.
    ENDIF.
  ENDIF.

ENDFORM.

FORM f4_quart.

  TYPES: BEGIN OF ty_f4,
           quarter TYPE char1,
           months  TYPE char24,
         END OF ty_f4.

  DATA: lt_f4  TYPE STANDARD TABLE OF ty_f4 WITH DEFAULT KEY,
        ls_f4  TYPE ty_f4,
        lt_ret TYPE STANDARD TABLE OF ddshretval WITH DEFAULT KEY,
        ls_ret TYPE ddshretval,
        lv_q   TYPE i,
        lv_p1  TYPE numc2,
        lv_p3  TYPE numc2,
        lv_i   TYPE i,
        lv_y1  TYPE gjahr,
        lv_y3  TYPE gjahr,
        lv_m1  TYPE numc2,
        lv_m3  TYPE numc2,
        lv_n1  TYPE char3,
        lv_n3  TYPE char3,
        lv_ok  TYPE abap_bool.

  lv_ok = zcl_pp_fcst_util=>split_fyear( p_fyear ).

  DO 4 TIMES.

    CLEAR ls_f4.
    lv_q = sy-index.
    ls_f4-quarter = lv_q.

    lv_i  = ( lv_q - 1 ) * 3 + 1.
    lv_p1 = lv_i.
    lv_i  = lv_i + 2.
    lv_p3 = lv_i.

    CLEAR: lv_y1, lv_y3, lv_m1, lv_m3.

    IF lv_ok = abap_true.
      zcl_pp_fcst_util=>period_to_yearmonth(
        EXPORTING iv_fyear = p_fyear iv_period = lv_p1
        IMPORTING ev_gjahr = lv_y1   ev_month  = lv_m1 ).
      zcl_pp_fcst_util=>period_to_yearmonth(
        EXPORTING iv_fyear = p_fyear iv_period = lv_p3
        IMPORTING ev_gjahr = lv_y3   ev_month  = lv_m3 ).
    ELSE.
      lv_i  = ( lv_q - 1 ) * 3 + 4.
      IF lv_i > 12.
        lv_i = lv_i - 12.
      ENDIF.
      lv_m1 = lv_i.
      lv_i  = lv_i + 2.
      IF lv_i > 12.
        lv_i = lv_i - 12.
      ENDIF.
      lv_m3 = lv_i.
    ENDIF.

    PERFORM month_name USING lv_m1 CHANGING lv_n1.
    PERFORM month_name USING lv_m3 CHANGING lv_n3.

    IF lv_y1 IS INITIAL.
      ls_f4-months = |{ lv_n1 } to { lv_n3 }|.
    ELSE.
      ls_f4-months = |{ lv_n1 } { lv_y1 } to { lv_n3 } { lv_y3 }|.
    ENDIF.

    APPEND ls_f4 TO lt_f4.

  ENDDO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING  retfield        = 'QUARTER'
               dynpprog        = sy-repid
               dynpnr          = sy-dynnr
               dynprofield     = 'P_QUART'
               value_org       = 'S'
    TABLES     value_tab       = lt_f4
               return_tab      = lt_ret
    EXCEPTIONS parameter_error = 1
               no_values_found = 2
               OTHERS          = 3.

  IF sy-subrc = 0.
    READ TABLE lt_ret INTO ls_ret INDEX 1.
    IF sy-subrc = 0.
      p_quart = ls_ret-fieldval.
    ENDIF.
  ENDIF.

ENDFORM.

FORM f4_perio.

  TYPES: BEGIN OF ty_f4,
           period TYPE char2,
           month  TYPE char3,
           year   TYPE char4,
         END OF ty_f4.

  DATA: lt_f4  TYPE STANDARD TABLE OF ty_f4 WITH DEFAULT KEY,
        ls_f4  TYPE ty_f4,
        lt_ret TYPE STANDARD TABLE OF ddshretval WITH DEFAULT KEY,
        ls_ret TYPE ddshretval,
        lv_p   TYPE numc2,
        lv_i   TYPE i,
        lv_yy  TYPE gjahr,
        lv_mm  TYPE numc2,
        lv_nam TYPE char3,
        lv_ok  TYPE abap_bool.

  lv_ok = zcl_pp_fcst_util=>split_fyear( p_fyear ).

  DO 12 TIMES.

    CLEAR: ls_f4, lv_yy, lv_mm.
    lv_p = sy-index.
    ls_f4-period = lv_p.

    IF lv_ok = abap_true.
      zcl_pp_fcst_util=>period_to_yearmonth(
        EXPORTING iv_fyear = p_fyear iv_period = lv_p
        IMPORTING ev_gjahr = lv_yy   ev_month  = lv_mm ).
      ls_f4-year = lv_yy.
    ELSE.
      lv_i = sy-index + 3.
      IF lv_i > 12.
        lv_i = lv_i - 12.
      ENDIF.
      lv_mm = lv_i.
    ENDIF.

    PERFORM month_name USING lv_mm CHANGING lv_nam.
    ls_f4-month = lv_nam.

    APPEND ls_f4 TO lt_f4.

  ENDDO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING  retfield        = 'PERIOD'
               dynpprog        = sy-repid
               dynpnr          = sy-dynnr
               dynprofield     = 'P_PERIO'
               value_org       = 'S'
    TABLES     value_tab       = lt_f4
               return_tab      = lt_ret
    EXCEPTIONS parameter_error = 1
               no_values_found = 2
               OTHERS          = 3.

  IF sy-subrc = 0.
    READ TABLE lt_ret INTO ls_ret INDEX 1.
    IF sy-subrc = 0.
      p_perio = ls_ret-fieldval.
    ENDIF.
  ENDIF.

ENDFORM.

FORM txt USING pv_name TYPE any
               pv_text TYPE any.

  DATA: lv_txt TYPE string,
        lv_len TYPE lvc_outlen.

  lv_txt = pv_text.
  lv_len = strlen( lv_txt ).
  IF lv_len < 10.
    lv_len = 10.
  ELSEIF lv_len > 40.
    lv_len = 40.
  ENDIF.

  TRY.
      DATA(lo_col) = go_alv->get_columns( )->get_column( CONV lvc_fname( pv_name ) ).
      lo_col->set_short_text( CONV scrtext_s( lv_txt ) ).
      lo_col->set_medium_text( CONV scrtext_m( lv_txt ) ).
      lo_col->set_long_text( CONV scrtext_l( lv_txt ) ).
      lo_col->set_output_length( lv_len ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.
