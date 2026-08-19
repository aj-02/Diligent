*--- MAIN PROGRAM: MZMMNMUNBLKF01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 29/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced with POPUP_TO_CONFIRM.
* 2) Obsolete FM UPLOAD Replaced with GUI_UPLOAD.
************************************************************************

***INCLUDE MZMMNMUNBLKF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                          P_TABLE_NAME
                          P_MARK_NAME
                 CHANGING P_OK      LIKE SY-UCOMM.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: L_OK              TYPE SY-UCOMM,
         L_OFFSET          TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
   SEARCH P_OK FOR P_TC_NAME.
   IF SY-SUBRC <> 0.
     EXIT.
   ENDIF.
   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
   L_OK = P_OK+L_OFFSET.
* execute general and TC specific operations                           *
   CASE L_OK.
     WHEN 'INSR'.                      "insert row
       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
       CLEAR P_OK.

     WHEN 'DELE'.                      "delete row
       perform add_delitem100.
       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME.
       CLEAR P_OK.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                         P_TABLE_NAME
                                         P_MARK_NAME   .
       CLEAR P_OK.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                           P_TABLE_NAME
                                           P_MARK_NAME .
       CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
     WHEN 'UPLOAD'.
       PERFORM upload_from_textfile using p_tc_name
                                          p_table_name
                                          p_mark_name.
       CLEAR P_OK.
   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>              TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
   ASSIGN (L_LINES_NAME) TO <LINES>.

* get current line
   GET CURSOR LINE L_SELLINE.
   if sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line                           *
     if l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     else.
       <tc>-top_line = 1.
     endif.
   else.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   endif.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.
* insert initial line
   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   <TC>-LINES = <TC>-LINES + 1.
* set cursor
   SET CURSOR LINE L_LINE.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <WA>.
   FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* delete marked lines                                                  *
   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

   LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     IF <MARK_FIELD> = 'X'.
       DELETE <TABLE> INDEX SYST-TABIX.
       IF SY-SUBRC = 0.
         <TC>-LINES = <TC>-LINES - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                       P_OK.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA L_TC_NEW_TOP_LINE     TYPE I.
   DATA L_TC_NAME             LIKE FELD-NAME.
   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
   FIELD-SYMBOLS <LINES>      TYPE I.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (P_TC_NAME) TO <TC>.
* get looplines of TableControl
   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
   ASSIGN (L_TC_LINES_NAME) TO <LINES>.


* is no line filled?                                                   *
   IF <TC>-LINES = 0.
*   yes, ...                                                           *
     L_TC_NEW_TOP_LINE = 1.
   ELSE.
*   no, ...                                                            *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
               ENTRY_ACT             = <TC>-TOP_LINE
               ENTRY_FROM            = 1
               ENTRY_TO              = <TC>-LINES
               LAST_PAGE_FULL        = 'X'
               LOOPS                 = <LINES>
               OK_CODE               = P_OK
               OVERLAPPING           = 'X'
          IMPORTING
               ENTRY_NEW             = L_TC_NEW_TOP_LINE
          EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
               OTHERS                = 0.
   ENDIF.

* get actual tc and column                                             *
   GET CURSOR FIELD L_TC_FIELD_NAME
              AREA  L_TC_NAME.

   IF SYST-SUBRC = 0.
     IF L_TC_NAME = P_TC_NAME.
*     set actual column                                                *
       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
     ENDIF.
   ENDIF.

* set the new top line                                                 *
   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

* get the table, which belongs to the tc                               *
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <TABLE> ASSIGNING <WA>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

     <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form fill_sttab.
 REFRESH it_tab1.
   IF g_mode =  'CHA' OR
      g_mode =  'APR'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'DIS' OR
          g_mode = 'REL'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'CRE' OR
          g_mode = 'DEL'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'LIST' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'BLK'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'REPORT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'HELP' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSE.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'ATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'LIST' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELATTACH' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.

endform.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  back_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form back_confirm.
DATA  l_choice.
CLEAR l_choice.
*   IF g_mode = 'BLK'.
*     PERFORM clear_var.
*     LEAVE PROGRAM.
*   ENDIF.
   IF g_mode <> 'DIS'.
" Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Data will be lost, Want to quit? '
*               titel          = 'BACK'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = l_choice.
DATA : l_get1(1) TYPE c.
clear l_get1.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'BACK '
         TEXT_QUESTION               = 'Data will be lost, Want to quit? '
        DISPLAY_CANCEL_BUTTON       = ' '
        START_COLUMN                = 25
        START_ROW                   = 6
      IMPORTING
        ANSWER                      = l_get1
      EXCEPTIONS
        TEXT_NOT_FOUND              = 1
        OTHERS                      = 2
               .
    IF SY-SUBRC = 0.
       CASE l_get1.
         WHEN '1'.
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

     IF l_choice = 'J'.
       IF NOT g_mode IS INITIAL.
         PERFORM clear_var.
         CLEAR l_choice.
       ELSE.
         CLEAR l_choice.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ELSE.
     IF NOT g_mode IS INITIAL.
       PERFORM clear_var.
     ELSE.
       LEAVE PROGRAM.
     ENDIF.
   ENDIF.

endform.                    " back_confirm
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_var.
   IF NOT gv_text_editor1 IS INITIAL.
     PERFORM destroy_ctrl.
   ENDIF.
   CLEAR zmm_nmblkcdhd_st.
   CLEAR g_mode.
**CODE ADDED BY CAB_AMITMOZA
CLEAR : NAME1 , NAME2 , NAME3.
**CODE END BY CAB_AMITMOZA

*   REFRESH g_tc100_itab[].
   REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
*   if g_lock = 'Y'.
*     perform unlock_req.
*     clear g_lock.
*   endif.
*   CLEAR: g_tc110_wa,g_tc120_wa,g_tc130_wa.
   CLEAR: g_hd_copied,g_tct100_copied.
   CLEAR:  g_cors, g_errstat,G_ERRCD_M.

   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.

endform.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_correspondense.
 DATA : l_cors LIKE thead-tdname.

   IF g_mode <> 'CRE'.
     CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_cors.

     CALL FUNCTION 'READ_TEXT'
          EXPORTING
               client                  = sy-mandt
               id                      = 'NMOV'
               language                = sy-langu
               name                    = l_cors
               object                  = 'ZMMCD'
          TABLES
               lines                   = lines_cors
          EXCEPTIONS
               id                      = 1
               language                = 2
               name                    = 3
               not_found               = 4
               object                  = 5
               reference_check         = 6
               wrong_access_to_archive = 7
               OTHERS                  = 8.

     IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       g_cors = ''.
     ELSE.
       g_cors = 'X'.
     ENDIF.
****Attachments.
     Select single * from srrelroles
             where logsys  = zmm_nmblkcdhd_st-reqno
             and   objtype = 'NMC'
             and   objkey  = '01'.
     if sy-subrc = 0.
       g_attach = 'X'.
     else.
       g_attach = ''.
     endif.
   ENDIF.

endform.                    " get_correspondense
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form text_control_eingabebereit1.
  CALL METHOD gv_text_editor1->set_readonly_mode
            EXPORTING
                 readonly_mode = gv_text_editor1->true
            EXCEPTIONS
                 error_cntl_call_method = 1
                 invalid_parameter      = 2
                 OTHERS                 = 3.
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
      ( g_mode = 'APR' ).

     CALL METHOD gv_text_editor2->set_readonly_mode
          EXPORTING
               readonly_mode = gv_text_editor2->false
          EXCEPTIONS
               error_cntl_call_method = 1
               invalid_parameter      = 2
               OTHERS                 = 3.
   ENDIF.
endform.                    " text_control_eingabebereit1
*&---------------------------------------------------------------------*
*&      Form  text_control_set_text_table1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form text_control_set_text_table1.
 REFRESH: tlinetab1,g_linefrto_itab.
*
   IF g_mode <> 'CRE'.
     APPEND LINES OF lines_cors TO tlinetab1[].
   ENDIF.
*
   LOOP AT tlinetab1[] INTO g_line132.
     IF ( g_line132+0(7) = '* Reply' ) OR
        ( g_line132+0(7) = '**Reply' ).
       g_linefrto-line_fr = sy-tabix.
       g_linefrto-line_to = sy-tabix.
       APPEND g_linefrto TO g_linefrto_itab.
       CLEAR: g_linefrto.
     ENDIF.
   ENDLOOP.
*
   CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
        TABLES
             itf_text    = tlinetab1[]
             text_stream = lt_text_table1.

   CALL METHOD gv_text_editor1->set_text_as_stream
        EXPORTING
             text = lt_text_table1
        EXCEPTIONS
             error_dp        = 1
             error_dp_create = 2
             OTHERS          = 3.
********************highlight**************************************
   CLEAR g_linefrto.
   LOOP AT g_linefrto_itab INTO g_linefrto.
     CALL METHOD gv_text_editor1->highlight_lines
        EXPORTING
             from_line = g_linefrto-line_fr
             to_line   = g_linefrto-line_to
             highlight_mode = 1.
   ENDLOOP.
********************************************************************
**Setting of first line..
   CALL METHOD gv_text_editor1->set_first_visible_line
        EXPORTING
               line = '1'.
********************************************************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
      ( g_mode = 'APR' ).

     CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          TABLES
               itf_text    = tlinetab2
               text_stream = lt_text_table2.

     CALL METHOD gv_text_editor2->set_text_as_stream
          EXPORTING
               text = lt_text_table2
          EXCEPTIONS
               error_dp        = 1
               error_dp_create = 2
               OTHERS          = 3.
   ENDIF.

endform.                    " text_control_set_text_table1
*&---------------------------------------------------------------------*
*&      Form  destroy_ctrl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form destroy_ctrl.
 CASE g_mode.
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'APR' OR 'BLK'.
       CALL METHOD gv_text_editor1->free.
       CALL METHOD gv_text_editor2->free.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD gv_text_editor1->free.
  ENDCASE.
   CLEAR:gv_text_editor1,gv_text_editor2.

endform.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_request.
   Data: l_tct100_wa type t_tct100.
   IF g_mode = 'CRE' OR g_mode = 'CHA'.
         IF NOT g_tct100_itab[] IS INITIAL.
           READ TABLE g_tct100_itab into l_tct100_wa
                WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           Perform check_errors changing g_errstat.
             if g_errstat = 'E'.
               CLEAR:g_errstat,ok_code100.
               EXIT.
             endif.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_nmblkcdhd_st-reqno = g_reqno.
     PERFORM insert_into_tab.
     perform popup_message.
     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_nmblkcdhd_st-reqno .
     PERFORM prepare_update.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR ok_code100.
   ELSEIF g_mode = 'REL'.
     IF zmm_nmblkcdhd_st-relflag = ''.
       CLEAR ok_code100.
       MESSAGE i024(zmm_oth) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_rel = 'Y'.
         PERFORM update_rel.
*         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR ok_code100.
       ELSE.
         clear zmm_nmblkcdhd_st-relflag.
         CLEAR ok_code100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'APR'.
     IF zmm_nmblkcdhd_st-appflag = ''.
       CLEAR ok_code100.
       MESSAGE i024(zmm_oth) WITH 'Approval'.
     ELSE.
       perform confirm_approval.
*       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_app = 'J'.
         PERFORM update_apr.
         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR ok_code100.
       ELSE.
         clear zmm_nmblkcdhd_st-appflag.
         CLEAR ok_code100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'BLK'.
     PERFORM update_cdcell.
     IF zmm_nmblkcdhd_st-status = 'IR'.
       PERFORM send_mail_to_reqn.
     ENDIF.
     PERFORM clear_var.
     CLEAR ok_code100.
     LEAVE PROGRAM.
   ENDIF.

endform.                    " save_request
*&---------------------------------------------------------------------*
*&      Form  insert_into_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form insert_into_tab.
 DATA: l_blkhd LIKE zmm_nmblkcdhd.
 CLEAR : l_blkhd.
****Header Part*********
   IF g_mode = 'CRE'.
     MOVE sy-datum TO zmm_nmblkcdhd_st-reqdate.
     MOVE sy-uname TO zmm_nmblkcdhd_st-reqcpf.
     MOVE 'N' TO zmm_nmblkcdhd_st-status.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     INSERT INTO zmm_nmblkcdhd VALUES l_blkhd.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     MODIFY zmm_nmblkcdhd FROM l_blkhd.
   ENDIF.
****Detail Part************
*   Refresh ist_zmm_cditem.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   IF g_mode = 'CRE'.
     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ELSE.
     MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
***If the req status id is 'IR', should be updated to 'IC'
    IF zmm_nmblkcdhd_st-status = 'IR'.
     IF g_result = '1'.
      UPDATE zmm_nmblkcdhd
      SET   status    = 'IC'
      WHERE reqno     = zmm_nmblkcdhd_st-reqno.
     ENDIf.
    ENDIF.

   ENDIF.
******Header(Correspondence)********************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'APR' ).
     PERFORM save_cors_text.
   ENDIF.

endform.                    " insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_update.
 DATA : l_del100 TYPE t_tct100.
* CLEAR g_item.
*   SELECT SINGLE * INTO g_item FROM zmm_nmblkcddt
*          WHERE reqno = zmm_nmblkcdhd_st-reqno.
**
      IF NOT g_itab_del100[] IS INITIAL.
         LOOP AT g_itab_del100 INTO l_del100.
           DELETE FROM zmm_nmblkcddt
             WHERE reqno = zmm_nmblkcdhd_st-reqno
             AND   srno  = l_del100-srno.
         ENDLOOP.
       ENDIF.
**
   PERFORM insert_into_tab.

endform.                    " prepare_update
*&---------------------------------------------------------------------*
*&      Form  prepare_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_delete.

   PERFORM confirm_del.

   IF g_choice = 'J'.

     DELETE FROM zmm_nmblkcdhd
     WHERE reqno = zmm_nmblkcdhd_st-reqno.
     IF sy-subrc <> 0.
       MESSAGE e007(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
     ENDIF.
*
     SELECT tdobject tdname tdid FROM stxl
      INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
      WHERE tdid = 'NMOV'.
     IF sy-subrc = 0.
       DELETE ist_textid_items
          WHERE tdname+4(10) <> zmm_nmblkcdhd_st-reqno.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.

     DELETE FROM zmm_nmblkcddt
     WHERE reqno = zmm_nmblkcdhd_st-reqno.
     IF sy-subrc = 0.
       MESSAGE i004(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
     ENDIF.
     CLEAR g_choice.
   ENDIF.

endform.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  update_rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_rel.
 UPDATE zmm_nmblkcdhd
   SET   relflag = 'X'
         relby   = sy-uname
         reldate = sy-datum
   WHERE reqno    = zmm_nmblkcdhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
*   IF zmm_nmblkcdhd_st-status = 'IR'.
*     UPDATE zmm_nmblkcdhd
*     SET   status    = 'IC'
*     WHERE reqno     = zmm_nmblkcdhd_st-reqno.
*   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

endform.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form send_mail_to_cdcell.
   DATA: l_text  TYPE soli,
         l_name  LIKE sood1-objnam,
         l_title LIKE sood1-objdes,
         l_user  LIKE sy-uname.
   DATA  l_text_itab LIKE TABLE OF l_text.
**
   CLEAR : l_name,l_title,l_text,l_user.
   REFRESH l_text_itab.
**Assignments.....
   l_name   = zmm_nmblkcdhd_st-reqno.
   CONCATENATE 'Unblock MatCode Request for' zmm_nmblkcdhd_st-reqno
               INTO l_title SEPARATED BY space.
   l_text =
   'Please check the Request and unblock the material codes.This is'
&'a system generated mail, please do not reply.'.
   APPEND l_text TO l_text_itab.

   l_user = 'CODIFICATION'.

***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       mailname          = l_name
       mailtitel         = l_title
       user              = l_user
    TABLES
      text              =  l_text_itab.

   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

endform.                    " send_mail_to_cdcell
*&---------------------------------------------------------------------*
*&      Form  update_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_cdcell.
   DATA   : l_tc100 TYPE t_tct100.

   CLEAR  : l_tc100,zmm_nmblkcddt.
   REFRESH: itab_nmblkcddt.

***Header
   if ZMM_NMBLKCDHD_ST-status = 'IR'.
     Select single * from zmm_nmblkcdhd
            where reqno = zmm_NMBLKCDHD_st-reqno.
     if zmm_NMBLKCDHD-ir_date is initial.
        ZMM_NMBLKCDHD_ST-ir_date = sy-datum.
     endif.
   else.
      clear ZMM_NMBLKCDHD_ST-ir_date.
   endif.
   move-corresponding ZMM_NMBLKCDHD_ST to Zmm_NMBLKCDHD.
   modify ZMM_NMBLKCDHD from zmm_NMBLKCDHD.
***details
       LOOP AT g_tct100_itab INTO l_tc100.
         MOVE-CORRESPONDING l_tc100 TO wa_nmblkcddt.
         MOVE zmm_NMBLKCDHD_st-reqno TO wa_nmblkcddt-reqno.
         APPEND wa_nmblkcddt TO itab_nmblkcddt.
         CLEAR:wa_nmblkcddt,l_tc100.
       ENDLOOP.
       MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
       REFRESH itab_nmblkcddt.
***Correspondense.
   PERFORM save_cors_text.

endform.                    " update_cdcell
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_reqn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form send_mail_to_reqn.
   DATA:  r_text  TYPE soli,
          r_name  LIKE sood1-objnam,
          r_title LIKE sood1-objdes,
          r_user  TYPE sy-uname.
   DATA:  r_text_itab LIKE TABLE OF r_text.
**
   CLEAR : r_name,r_title,r_text.
   REFRESH r_text_itab.
**Assignments.....
   r_name   = zmm_nmblkcdhd_st-reqno.
   CONCATENATE 'Request' zmm_nmblkcdhd_st-reqno 'Status'
               INTO r_title SEPARATED BY space.
   IF zmm_nmblkcdhd_st-status = 'C'.
  r_text = 'Request has been updated.Please check the Request,Request'
&'status and correspondence within it.this is a system generated mail,'
&'please do not reply. - codification cell'.
     APPEND r_text TO r_text_itab.
**
   ELSEIF zmm_nmblkcdhd_st-status = 'IR'.
  r_text = 'Please go through the correspondence comments if any & the'
&'request. after changes, the request should be re-released.'.
     APPEND r_text TO r_text_itab.
     CLEAR r_text.
  r_text = 'All the actions taken should be recorded only in'
&'correspondence. no separate communication will be entertained. this is a'
 &'system generatedmail.please do not reply'.
     APPEND r_text TO r_text_itab.
   ENDIF..

*   append r_text to r_text_itab.
   SELECT SINGLE reqcpf INTO r_user FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       mailname          = r_name
       mailtitel         = r_title
       user              = r_user
    TABLES
      text              =  r_text_itab
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

endform.                    " send_mail_to_reqn
*&---------------------------------------------------------------------*
*&      Form  save_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form save_cors_text.
   DATA: l_theader LIKE thead.
   DATA: l_datech(10) TYPE c.
***********Assignments***********************
   CLEAR l_theader.
   l_theader-tdobject   = 'ZMMCD'.
   l_theader-tdid       = 'NMOV'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_theader-tdname.
   APPEND LINES OF tlinetab2 TO tlinetab1.
*********************************************
   IF NOT tlinetab1[] IS INITIAL.
     CLEAR g_cores_sender.
     CONCATENATE sy-datum+6(2) '/'
                 sy-datum+4(2) '/'
                 sy-datum+0(4) INTO l_datech.
     CONCATENATE '**Reply' l_datech sy-uname INTO g_cores_sender
      SEPARATED BY '          '.
     IF NOT tlinetab2[] IS INITIAL.
       APPEND g_cores_sender TO tlinetab1.
     ENDIF.
     CLEAR g_cores_sender.
     CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
               client          = sy-mandt
               header          = l_theader
               savemode_direct = 'X'
          TABLES
               lines           = tlinetab1
          EXCEPTIONS
               id              = 1
               language        = 2
               name            = 3
               object          = 4
               OTHERS          = 5.

     IF sy-subrc <> 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     ENDIF.
   ENDIF.

endform.                    " save_cors_text
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_del.
 CLEAR g_choice.
" Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*    textline1 = 'Data will be lost,No recovery possible,Are you sure ?'
*      titel            = 'DELETE'
*      start_column     = 25
*      start_row        = 6
*      cancel_display   = ''
*     IMPORTING
*       answer          = g_choice.
 DATA : l_get2(1) TYPE c.
 CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR                    = 'DELETE '
     TEXT_QUESTION               = 'Data will be lost,No recovery possible,Are you sure ?'
    DISPLAY_CANCEL_BUTTON       = ' '
    START_COLUMN                = 25
    START_ROW                   = 6
  IMPORTING
    ANSWER                      = l_get2
  EXCEPTIONS
    TEXT_NOT_FOUND              = 1
    OTHERS                      = 2
           .
 IF SY-SUBRC = 0.
       CASE l_get2.
         WHEN '1'.
           MOVE 'J' TO g_choice.
           WHEN '2'.
             MOVE 'N' TO g_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
endform.                    " confirm_del
*&---------------------------------------------------------------------*
*&      Form  delete_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_text.
 CALL FUNCTION 'DELETE_TEXT'
        EXPORTING
             client          = sy-mandt
             id              = wa_textid-tdid
             language        = sy-langu
             name            = wa_textid-tdname
             object          = wa_textid-tdobject
             savemode_direct = 'X'
        EXCEPTIONS
             not_found       = 1
             OTHERS          = 2.

   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
endform.                    " delete_text
*&---------------------------------------------------------------------*
*&      Form  update_apr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_apr.
 UPDATE zmm_nmblkcdhd
   SET   appflag = 'X'
         APPBY   = sy-uname
         APPDATE = sy-datum
   WHERE reqno    = zmm_nmblkcdhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
   IF zmm_nmblkcdhd_st-status = 'IR'.
     UPDATE zmm_nmblkcdhd
     SET   status    = 'IC'
     WHERE reqno     = zmm_nmblkcdhd_st-reqno.
   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i119(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

endform.                    " update_apr
*&---------------------------------------------------------------------*
*&      Form  add_delitem100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form add_delitem100.
 DATA : l_tc100_wa TYPE t_tct100.
   LOOP AT g_tct100_itab INTO l_tc100_wa.
     IF l_tc100_wa-flag = 'X'.
       APPEND l_tc100_wa TO g_itab_del100.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc100_wa.
endform.                    " add_delitem100
*&---------------------------------------------------------------------*
*&      Form  gen_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form gen_request.
 CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
             nr_range_nr = '01'
             object      = 'ZMMNMUNBLK'
        IMPORTING
             number      = g_reqno.
   IF sy-subrc <> 0.
   ENDIF.
endform.                    " gen_request
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_nextsrno.
 DATA : g_100itab TYPE TABLE OF t_tct100.
 DATA : l_100itab TYPE t_tct100.
 CLEAR  l_100itab.
 REFRESH g_100itab.

   APPEND LINES OF g_tct100_itab TO g_100itab.
   SORT g_100itab BY srno DESCENDING.
   READ TABLE g_100itab INTO l_100itab INDEX 1.
   l_srno = l_100itab-srno + 1.

endform.                    " get_nextsrno
*&---------------------------------------------------------------------*
*&      Form  unblock_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form unblock_matcode.
 Data : l_unblk100 type t_tct100.
 Data : l_atwrt like ausp-atwrt,
        l_matnr like mara-matnr,
        l_atinn like ausp-atinn.
 Data : l_totlines type i,
        l_unblklines type i.
**
  CLEAR   wa_nmblkcddt.
  REFRESH itab_nmblkcddt[].
**
  clear g_mesg.
  READ TABLE g_tct100_itab into l_unblk100
       WITH KEY flag  = 'X'.
       IF sy-subrc <> 0.
         g_mesg = 'X'.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.
**
  PERFORM confirm_unblock.
  IF g_choice = 'J'.
***Updating classification view.
   LOOP AT g_tct100_itab into g_tct100_wa
        where flag  = 'X'
        and   errcd = ''.
    l_matnr = g_tct100_wa-matcode.
* Begin of <RD1K976495> on 03062011

     update mara set ZZMBPR = ''
                     ZZNMFLG = ''
                 where matnr = l_matnr.
     if sy-subrc = 0.

    endif.
* End of <RD1K976495> on 03062011
    SELECT * FROM KLAH UP TO 1 ROWS

 WHERE KLART = '001' AND CLASS = 'Z_ONGC_BLOCK'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
     DELETE FROM KSSK
            where objek = l_matnr
            AND   clint = klah-clint
            AND   klart = '001'.
    ENDIF.
**
    SELECT ATINN INTO L_ATINN
 FROM CABN UP TO 1 ROWS WHERE ATNAM = 'Z_ONGC_REASON'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    If sy-subrc = 0.
       Delete from AUSP
              WHERE  objek = l_matnr
              AND    atinn = l_atinn.
**
      g_tct100_wa-mstae = ''.
      modify g_tct100_itab from g_tct100_wa.
**
    Endif.
**  Updating internal comment in basic view..
    perform update_internal_comment using g_tct100_wa-matcode
                                          g_tct100_wa-res_nm.
    Clear: l_matnr,l_atinn.

   ENDLOOP.
**Updating database table
   LOOP AT g_tct100_itab INTO g_tct100_wa
                         where flag = 'X'
                         and   errcd = ''.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        move sy-uname to wa_nmblkcddt-unblkby.
        move sy-datum to wa_nmblkcddt-unblkdt.
        append wa_nmblkcddt to itab_nmblkcddt.
        clear:g_tct100_wa,wa_nmblkcddt.
   ENDLOOP.
   LOOP AT g_tct100_itab INTO g_tct100_wa
                         where errcd <> ''.
        MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
        MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
        append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.
   modify zmm_nmblkcddt from table itab_nmblkcddt.

***Setting the request status.
      IF zmm_nmblkcdhd_st-status = 'IR'.
        PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
      ELSE.
*        DESCRIBE TABLE g_tct100_itab LINES l_totlines.
        SELECT COUNT(*) INTO l_totlines
                        FROM zmm_nmblkcddt
                        WHERE reqno = zmm_nmblkcdhd_st-reqno.

        SELECT COUNT(*) INTO l_unblklines
                      FROM zmm_nmblkcddt
        WHERE reqno = zmm_nmblkcdhd_st-reqno
        AND   mstae = ''.

        IF l_unblklines < l_totlines.
          zmm_nmblkcdhd_st-status = 'IC'.
          PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
        ELSE.
          zmm_nmblkcdhd_st-status = 'C'.
           PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
        ENDIF.
      ENDIF.
      PERFORM save_cors_text.
  ELSE.
    g_mesg = 'X'.
  ENDIF.
  CLEAR g_choice.

* LOOP AT C_EBAN
*    SELECT * FROM kssk INTO TABLE tkssk
*              WHERE objek = c_eban-matnr
*              AND   klart = '001'.
*     IF sy-subrc = 0.  " kssk
*      LOOP AT tkssk.
*        SELECT SINGLE * FROM klah
*               WHERE klart  = '001'
*               AND   clint  = tkssk-clint
*               AND   class  = 'Z_ONGC_BLOCK'.
*        IF sy-subrc = 0.
*          SELECT SINGLE atinn INTO l_atinn
*                 FROM   cabn
*                 WHERE atnam = 'Z_ONGC_REASON'.
*          If sy-subrc = 0.
*             Select single atwrt into l_atwrt
*                    from ausp
*                    WHERE  objek = l_matnr
*                    AND    atinn = l_atinn.
*              IF sy-subrc = 0.
*                if l_atwrt = 'NM'.
*                 message e154(zmm_oth) with l_matnr.
*                endif.
*              ENDIF.
*              CLEAR: l_atinn,l_atwrt.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*     ENDIF.
*   ENDLOOP.

endform.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_approval.
" Begin of <RD1K960036>.

* CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Want to Approve the request ? '
*               titel          = 'Approval'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = g_app.
  DATA : l_get3(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'Approval '
      TEXT_QUESTION               = 'Want to Approve the request ? '
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = l_get3
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .
  IF SY-SUBRC = 0.
       CASE l_get3.
         WHEN '1'.
           MOVE 'J' TO g_app.
           WHEN '2'.
             MOVE 'N' TO g_app.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
endform.                    " confirm_approval
*&---------------------------------------------------------------------*
*&      Form  upload_from_textfile
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
form upload_from_textfile using  p_tc_name
                                 p_table_name
                                 p_mark_name.
 DATA: l_filename LIKE rlgrap-filename.
 DATA: l_tx100  TYPE t_tx100.
 DATA: wa_tx100 TYPE t_tx100.
 refresh : g_ex100_itab[].
" Begin of <RD1K960036>.
*   CALL FUNCTION 'UPLOAD'
*        EXPORTING
*             filename                = l_filename
*             filetype                = 'DAT'
*             item                    = ' '
*             filemask_mask           = ' '
*             filemask_text           = ' '
*             filetype_no_change      = ' '
*             filemask_all            = ' '
*             filetype_no_show        = ' '
*             line_exit               = ' '
*             user_form               = ' '
*             user_prog               = ' '
*             silent                  = 'S'
*        TABLES
*             data_tab                = g_tx100_itab
*        EXCEPTIONS
*             conversion_error        = 1
*             invalid_table_width     = 2
*             invalid_type            = 3
*             no_batch                = 4
*             unknown_error           = 5
*             gui_refuse_filetransfer = 6
*             OTHERS                  = 7.
*   IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*   ENDIF.



DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
       l_FILETABLE  TYPE  FILE_TABLE,
       l_RC         TYPE  I,
       l_P_DEF_FILE TYPE  STRING,
       l_P_FILE     TYPE  STRING,
       l_usr_act    TYPE  I.

 l_P_DEF_FILE = l_filename.

CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
  EXPORTING
*    WINDOW_TITLE            =
*    DEFAULT_EXTENSION       =
    DEFAULT_FILENAME        = l_P_DEF_FILE
*    FILE_FILTER             =
*    WITH_ENCODING           =
*    INITIAL_DIRECTORY       =
*    MULTISELECTION          =
  CHANGING
    FILE_TABLE              = I_FILE_TABLE
    RC                      = l_RC
    USER_ACTION             = l_usr_act
*    FILE_ENCODING           =
  EXCEPTIONS
    FILE_OPEN_DIALOG_FAILED = 1
    CNTL_ERROR              = 2
    ERROR_NO_GUI            = 3
    NOT_SUPPORTED_BY_GUI    = 4
    others                  = 5
        .
IF SY-SUBRC = 0 AND
   l_usr_act <>
   CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

    LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
       l_P_FILE = l_FILETABLE.
        EXIT.
    ENDLOOP.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
       FILENAME                      = l_P_FILE
       FILETYPE                       = g_c_asc
       HAS_FIELD_SEPARATOR            = 'X'
      TABLES
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*        DATA_TAB                      = g_tx100_itab
        DATA_TAB                      = g_tx100_itab     "#EC CI_FLDEXT_OK[2215424]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
     EXCEPTIONS
       FILE_OPEN_ERROR               = 1
       FILE_READ_ERROR               = 2
       NO_BATCH                      = 3
       GUI_REFUSE_FILETRANSFER       = 4
       INVALID_TYPE                  = 5
       NO_AUTHORITY                  = 6
       UNKNOWN_ERROR                 = 7
       BAD_DATA_FORMAT               = 8
       HEADER_NOT_ALLOWED            = 9
       SEPARATOR_NOT_ALLOWED         = 10
       HEADER_TOO_LONG               = 11
       UNKNOWN_DP_ERROR              = 12
       ACCESS_DENIED                 = 13
       DP_OUT_OF_MEMORY              = 14
       DISK_FULL                     = 15
       DP_TIMEOUT                    = 16
       OTHERS                        = 17
              .
    IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

ENDIF.
" End of <RD1K960036>.

   sort g_tx100_itab ascending by matcode.
   delete adjacent duplicates from g_tx100_itab comparing matcode.
*   if g_mode = 'CRE'.
*     perform get_data_from_tx100.
*   endif.

*matcode validation durin text file data upload
*   IF NOT g_tx100_itab[] IS INITIAL.
*     LOOP AT g_tx100_itab[] INTO wa_tx100.
*       clear g_recstat.
*       PERFORM validate_matcode USING wa_tx100-matcode
*                                CHANGING g_recstat.
*       if g_recstat = 'E'.
*         append wa_tx100 to g_ex100_itab.
*         delete g_tx100_itab[] where matcode = wa_tx100-matcode.
*       endif.
*     ENDLOOP.
*   ENDIF.


endform.                    " upload_from_textfile
*&---------------------------------------------------------------------*
*&      Form  get_data_from_tx100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data_from_tx100.
Data: l_tx100_wa type t_tx100,
      l_srno like zmm_nmblkcddt-srno.
***Setting serial number.
 if g_tctlines = 0.
   l_srno = 0.
  else.
   if g_mode = 'CHA'.
    Select max( srno ) into l_srno from zmm_nmblkcddt
           where reqno = zmm_nmblkcdhd_st-reqno.
   else.
     l_srno = g_tctlines.
   endif.
  endif.
***
 loop at g_tx100_itab into l_tx100_wa.
  l_srno = l_srno + 1.
  g_tct100_wa-srno    = l_srno.
  g_tct100_wa-matcode = l_tx100_wa-matcode.
  SELECT MAKTX INTO G_TCT100_WA-MATDESC FROM MAKT UP TO 1 ROWS
 WHERE MATNR = L_TX100_WA-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  select single meins into g_tct100_wa-uom from mara
         where matnr = l_tx100_wa-matcode.
  g_tct100_wa-res_nm  = l_tx100_wa-res_nm.
***check for non moving items..
       clear g_recstat.
       PERFORM validate_matcode USING l_tx100_wa-matcode
                                CHANGING g_recstat.
       if g_recstat = 'E'.
        g_tct100_wa-errcd = 'M'.
        g_tct100_wa-flag  = 'X'.
       endif.
***
  append g_tct100_wa to g_tct100_itab .
  clear g_tct100_wa.
 endloop.
endform.                    " get_data_from_tx100
*&---------------------------------------------------------------------*
*&      Form  validate_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_TX100_MATCODE  text
*      <--P_G_RECSTAT  text
*----------------------------------------------------------------------*
form validate_matcode using    p_matcode
                      changing p_recstat.
 Data: l_objek like ausp-objek.
 Select single objek into l_objek from ausp
         where objek = p_matcode
         and   atinn = ( Select atinn from cabn
                                where atnam = 'Z_ONGC_REASON' )
         and   klart = '001'
         and   atwrt = 'NM'.
 if sy-subrc <> 0.
   p_recstat = 'E'.
 endif.
endform.                    " validate_matcode
*&---------------------------------------------------------------------*
*&      Form  check_errors
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_errors changing p_errstat.
Data : l_tct100 type t_tct100.
**
 read table g_tct100_itab into l_tct100
                          with key errcd = 'M'.
  if sy-subrc = 0.
    p_errstat = 'E'.
    message i121(zmm_oth) with l_tct100-srno.
  endif.

endform.                    " check_errors
*&---------------------------------------------------------------------*
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form attach_file.

 clear g_att_files_wa.
 refresh g_att_files.
 IF g_mode = 'CHA'.
   g_att_files_wa-LOGSYS  = zmm_nmblkcdhd_st-reqno.
   g_att_files_wa-objtype = 'NMC'.   "'ATT'.
   g_att_files_wa-objkey  = '01'.

   append g_att_files_wa to g_att_files.

   CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
             ATTACHMENT_DATA           = ''
             ATTACHMENT_TYPE           = 'DOC'
         TABLES
             APPLICATION_OBJECTS       = g_att_files.
 Endif.

endform.                    " attach_file
*&---------------------------------------------------------------------*
*&      Form  list_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form list_file.
 g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa.
*   FUNCTION                 = ' '
* TABLES
*   FUNC_EXCLUDE             =  .


endform.                    " list_file
*&---------------------------------------------------------------------*
*&      Form  confirm_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_exit.
 DATA  l_choice1.
   CLEAR l_choice1.
   IF g_mode <> 'DIS'.
" Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               textline1      = 'Data will be lost, Want to quit? '
*               titel          = 'EXIT'
*               start_column   = 25
*               start_row      = 6
*               cancel_display = ''
*          IMPORTING
*               answer         = l_choice1.
     DATA : l_get4(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'EXIT '
         TEXT_QUESTION               = 'Data will be lost, Want to quit? '
        DISPLAY_CANCEL_BUTTON       = ' '
        START_COLUMN                = 25
        START_ROW                   = 6
      IMPORTING
        ANSWER                      = l_get4
      EXCEPTIONS
        TEXT_NOT_FOUND              = 1
        OTHERS                      = 2
               .

     IF SY-SUBRC = 0.
       CASE l_get4.
         WHEN '1'.
           MOVE 'J' TO l_choice1.
           WHEN '2'.
             MOVE 'N' TO l_choice1.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

     IF l_choice1 = 'J'.
       CLEAR l_choice1.
       PERFORM clear_var.
       LEAVE PROGRAM.
     ENDIF.
   ELSE.
     PERFORM clear_var.
     LEAVE PROGRAM.
   ENDIF.

endform.                    " confirm_exit
*&---------------------------------------------------------------------*
*&      Form  confirm_unblock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form confirm_unblock.
  CLEAR g_choice.
" Begin of <RD1K960036>.

*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*             textline1      = 'Want to unblock selected Codes ?'
*             titel          = 'Unblock'
*             start_column   = 25
*             start_row      = 6
*             cancel_display = ''
*        IMPORTING
*             answer         = g_choice.
DATA : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Unblock'
    TEXT_QUESTION               = 'Want to unblock selected Codes ?'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get5
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE l_get5.
         WHEN '1'.
           MOVE 'J' TO g_choice.
           WHEN '2'.
             MOVE 'N' TO g_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

endform.                    " confirm_unblock
*&---------------------------------------------------------------------*
*&      Form  popup_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form popup_message.
Data : wa_text like trtab.
Data : itab_text like trtab occurs 0.
refresh itab_text.
**
 wa_text =
 'Please ensure that approval of concerned Director for unblocking '.
  append wa_text to itab_text.
  clear wa_text.

 wa_text =
 'of Material codes has been attached in the change mode.'.
  append wa_text to itab_text.
  clear wa_text.

CALL FUNCTION 'LAW_SHOW_POPUP_WITH_TEXT'
  EXPORTING
    titelbar                     = 'NOTE'
    SHOW_CANCEL_BUTTON           = 'X'
    LINE_SIZE                    = 65
  tables
    list_tab                     =  itab_text.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

endform.                    " popup_message
*&---------------------------------------------------------------------*
*&      Form  set_reqcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
*----------------------------------------------------------------------*
form set_reqcl using p_status.
     UPDATE zmm_nmblkcdhd
     SET status = p_status
     WHERE reqno = zmm_nmblkcdhd_st-reqno.

**
   IF zmm_nmblkcdhd_st-status = 'IR'.
     UPDATE zmm_nmblkcdhd
      SET ir_date = sy-datum
      WHERE reqno = zmm_nmblkcdhd_st-reqno.
   ENDIF.

endform.                    " set_reqcl
*&---------------------------------------------------------------------*
*&      Form  update_internal_comment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TCT100_WA_MATCODE  text
*      -->P_G_TCT100_WA_RESNM  text
*----------------------------------------------------------------------*
form update_internal_comment using    p_matcode
                                      p_res_nm.
 Data: wa_lines like tline,
       l_txt like tline-tdline,
       l_insert type c.
 Data : header like  thead,
        l_tdname like thead-tdname.
 Data : ist_nmlines like tline occurs 0 with header line.

****Update Internal Comments
        header-tdobject = 'MATERIAL'.
        header-tdid     = 'IVER'.
        header-tdname   =  p_matcode .
        header-tdspras  = 'EN'.
        header-tdform   = 'SYSTEM'.
        header-mandt    = sy-mandt .
        l_tdname        = p_matcode.
 refresh: ist_nmlines.

***Fetching the existing text against matcode.
        select single * from stxh
                 where tdobject = 'MATERIAL'
                 and   tdname   = l_tdname
                 and   tdid     = 'IVER'.
        if sy-subrc = 0.
          call function 'READ_TEXT'
               exporting
                    client   = sy-mandt
                    id       = 'IVER'
                    language = 'E'
                    name     = l_tdname
                    object   = 'MATERIAL'
               tables
                    lines    = ist_nmlines.
        endif.
***Appending the remark to existing text.
        IF NOT ist_nmlines[] IS INITIAL.
         wa_lines-tdformat = '*'.
         wa_lines-tdline = '               '.
         append wa_lines to ist_nmlines .
        ENDIF.
        concatenate sy-uname '-' sy-datum+6(2) '/'
                                 sy-datum+4(2) '/'
                                 sy-datum+0(4) '/' into l_txt .
        wa_lines-tdformat = '*'.
        wa_lines-tdline  =  l_txt .
        append wa_lines to ist_nmlines .
        wa_lines-tdline = p_res_nm.
        append wa_lines to ist_nmlines .
        clear l_txt.
        concatenate 'Request no-' zmm_nmblkcdhd_st-reqno into l_txt.
        wa_lines-tdline = l_txt.
        append wa_lines to ist_nmlines .
        wa_lines-tdline = '******************************************'.
        append wa_lines to ist_nmlines .

        if ist_nmlines[] is initial.
          l_insert = 'X'.
        else.
          l_insert =  space.
        endif.
***Saving the nonmoving text ( Remark)

        call function 'SAVE_TEXT'
             exporting
                  client          = sy-mandt
                  header          = header
                  insert          = l_insert
                  savemode_direct = 'X'
             tables
                  lines           = ist_nmlines.


endform.                    " update_internal_comment
*&---------------------------------------------------------------------*
*&      Form  del_attachment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form del_attachment.
  g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
  g_att_files_wa-objtype = 'NMC'.
  g_att_files_wa-objkey = '01'.

 CALL FUNCTION 'ZSO_DEL_ATTACHMENT'
   EXPORTING
    application_object       = g_att_files_wa.
*    FUNCTION                 = ' '.



endform.                    " del_attachment
*&---------------------------------------------------------------------*
*&      Form  guidelines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form guidelines.

 clear g_att_files_wa.
 g_att_files_wa-LOGSYS = 'UBNMCDHELP'.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.



 refresh exclude_tab[].
 MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa
   TABLES
    FUNC_EXCLUDE             = EXCLUDE_TAB.

endform.                    " guidelines
*&---------------------------------------------------------------------*
*&      Form  circular
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form circular.
 clear g_att_files_wa.

 g_att_files_wa-LOGSYS = 'UBNMCDCIRC'.
 g_att_files_wa-objtype = 'NMC'.
 g_att_files_wa-objkey = '01'.

 refresh exclude_tab[].
 MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
 MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa
   TABLES
    FUNC_EXCLUDE             = EXCLUDE_TAB.

endform.                    " circular
