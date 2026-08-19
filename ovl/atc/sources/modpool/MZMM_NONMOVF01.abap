*--- MAIN PROGRAM: MZMM_NONMOVF01 ---*
************************************************************************
*  Date            Transport      USERID        Description

************************************************************************

***INCLUDE MZMM_NONMOVF01 .
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
***     WHEN 'UPLOAD'.
***       PERFORM upload_from_textfile using p_tc_name
***                                          p_table_name
***                                          p_mark_name.
***
***       CLEAR P_OK.

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
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO           = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
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

   MOVE 'ZMMNMPRINT' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'HELP' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'ATTACH' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'DELATTACH' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'LIST' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'REPORT' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'UNBLOCK' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'CIRCULAR' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.
   MOVE 'RELEASE' TO wa_tab-fcode.
   APPEND wa_tab TO it_tab1.

   IF g_mode =  'CHA'.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'DIS'.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

****   ELSEIF g_mode = 'REL'.
****     MOVE 'SAV' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'CREATE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'CHANGE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DELETE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DISPLAY' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'RELEASE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'APPROVE' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'UNBLOCK' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'ATTACH' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'DELATTACH' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'REPORT' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.
****     MOVE 'HELP' TO wa_tab-fcode.
****     APPEND wa_tab TO it_tab1.

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
     MOVE 'SUBMIT' TO wa_tab-fcode.
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
     MOVE 'SUBMIT' TO wa_tab-fcode.
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

   IF g_mode <> 'DIS'.

     DATA : l_get1(1) TYPE c.
     clear l_get1.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR              = 'BACK '
         TEXT_QUESTION         = 'Data will be lost, Want to quit? '
         DISPLAY_CANCEL_BUTTON = ' '
         START_COLUMN          = 25
         START_ROW             = 6
       IMPORTING
         ANSWER                = l_get1
       EXCEPTIONS
         TEXT_NOT_FOUND        = 1
         OTHERS                = 2.
     IF SY-SUBRC = 0.
       CASE l_get1.
         WHEN '1'.
           MOVE 'J' TO l_choice.
         WHEN '2'.
           MOVE 'N' TO l_choice.
       ENDCASE.
     ENDIF.

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
   CLEAR : NAME1.

   REFRESH CONTROL 'TCT100' FROM SCREEN '0100'.
   CLEAR: g_hd_copied,g_tct100_copied.
   CLEAR:  g_cors, g_errstat,G_ERRCD_M.

   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.

   clear: G_REQ_NO.
   FREE MEMORY ID 'ID_NMREQ'.
   clear FLAG_WF.
   FREE MEMORY ID 'ID_NMWF'.
*   FREE MEMORY ID 'ID_NMSTT'.
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
         id                      = 'MMNM'
         language                = sy-langu
         name                    = l_cors
         object                  = 'ZMMNM'
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
       readonly_mode          = gv_text_editor1->true
     EXCEPTIONS
       error_cntl_call_method = 1
       invalid_parameter      = 2
       OTHERS                 = 3.
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).

     CALL METHOD gv_text_editor2->set_readonly_mode
       EXPORTING
         readonly_mode          = gv_text_editor2->false
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

*     IF ( g_line132+0(2) = '* ' ) OR
*        ( g_line132+0(2) = '**' ).
     IF  g_line132+2(2) = '**'.
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
       text            = lt_text_table1
     EXCEPTIONS
       error_dp        = 1
       error_dp_create = 2
       OTHERS          = 3.
********************highlight**************************************
   CLEAR g_linefrto.
   LOOP AT g_linefrto_itab INTO g_linefrto.
     CALL METHOD gv_text_editor1->highlight_lines
       EXPORTING
         from_line      = g_linefrto-line_fr
         to_line        = g_linefrto-line_to
         highlight_mode = 1.
   ENDLOOP.
********************************************************************
**Setting of first line..
   CALL METHOD gv_text_editor1->set_first_visible_line
     EXPORTING
       line = '1'.
********************************************************************
   IF ( g_mode = 'CRE' ) OR
      ( g_mode = 'CHA' ) OR
      ( sy-tcode = 'ZMMNMWF2' ) OR
      ( sy-tcode = 'ZMMNMWFL2' ) OR
      ( sy-tcode = 'ZMMNMWF3' ) OR
      ( sy-tcode = 'ZMMNMWF4' ).

     CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
       TABLES
         itf_text    = tlinetab2
         text_stream = lt_text_table2.

     CALL METHOD gv_text_editor2->set_text_as_stream
       EXPORTING
         text            = lt_text_table2
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
   IF ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ) OR
      ( sy-tcode = 'ZMMNMWF2' ) OR
      ( sy-tcode = 'ZMMNMWFL2' ) OR
      ( sy-tcode = 'ZMMNMWF3' ) OR
      ( sy-tcode = 'ZMMNMWF4' ).

     CALL METHOD gv_text_editor1->free.
     CALL METHOD gv_text_editor2->free.
   ELSEIF ( g_mode = 'DIS' ) OR ( g_mode = 'DEL' ).
     CALL METHOD gv_text_editor1->free.
   ENDIF.
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
             WITH KEY MATCODE = ''.

       READ TABLE g_tct100_itab into l_tct100_wa
            WITH KEY srno = 0.
       IF sy-subrc = 0.
         MESSAGE w220(zmm_oth). "Pls press enter to populate detail data before saving.
         flag_dont_clear = 'X'.  "X : don't clear variables, take another loop thro' PBO
         EXIT.

       ENDIF.

       IF g_mode = 'CRE'.
         PERFORM gen_request.
         SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
       ENDIF.
     ELSE.
       MESSAGE i091(zmm_oth).
       flag_dont_clear = 'X'.  "X : don't clear variables, take another loop thro' PBO
       EXIT.
     ENDIF.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_nmblkcdhd_st-reqno = g_reqno.

     PERFORM insert_into_tab. " For Creator, Update Header & deatails


     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR ok_code100.

   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_nmblkcdhd_st-reqno .
     PERFORM remove_deleted_items.

** Release from creator
     if G_REL_FLAG = 'X'.  " SAVE with Release by ceator to L3l4

       perform validate_reqno.
       perform validate_before_rel_rej_rev.
       PERFORM insert_into_tab.  " For Creator, Update Header & deatails
       COMMIT WORK.
       perform submit_request.
       clear ok_code100.

     else .               " SAVE only by ceator
       PERFORM insert_into_tab.  " For Creator, Update Header & deatails
       COMMIT WORK.
       MESSAGE i006(zmm_oth) WITH g_request_no.
       PERFORM clear_var.
       CLEAR ok_code100.
     endif.

   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR ok_code100.

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
 form insert_into_tab.   " For Creator: Update Header & deatails
   DATA: l_blkhd LIKE zmm_nmblkcdhd.
   CLEAR : l_blkhd.
****Update Header *********
   IF g_mode = 'CRE'.

     zmm_nmblkcdhd_st-nm_status = 'NEW'.
     zmm_nmblkcdhd_st-DOC_DATE = sy-datum.

     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     INSERT  zmm_nmblkcdhd FROM l_blkhd.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_nmblkcdhd_st TO l_blkhd.
     MODIFY zmm_nmblkcdhd FROM l_blkhd.
   ENDIF.

****Update Details ************
   refresh itab_nmblkcddt.
   clear g_tct100_wa.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.

*
**row status: Creator- If this is a reverted request and being released by the creator,  Update ROW STATUS as per the decision.
* Also validate: creator can choose only 'REJECT', 'REPLY'."Already ACCEPTed row will be read only.
     if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL and G_REL_FLAG = 'X'.

       IF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECT'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
         wa_nmblkcddt-STATUS = 'REPLY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
*     wa_nmblkcddt-STATUS = 'QUERY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
            or wa_nmblkcddt-DECISION = 'QUERY' .
         MESSAGE E231(zmm_oth).
       ENDIF.

     endif.

     append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   IF g_mode = 'CRE'.
     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ELSE.
     MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
   ENDIF.

***Note Sheet
   IF ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ).

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
 form remove_deleted_items.
   DATA : l_del100 TYPE t_tct100.
* CLEAR g_item.
*   SELECT SINGLE * INTO g_item FROM zmm_nmblkcddt
*          WHERE reqno = zmm_nmblkcdhd_st-reqno.
**
   IF g_itab_del100[] IS  NOT  INITIAL.
     LOOP AT g_itab_del100 INTO l_del100.
       DELETE FROM zmm_nmblkcddt
         WHERE reqno = zmm_nmblkcdhd_st-reqno
         AND   srno  = l_del100-srno.
     ENDLOOP.
   ENDIF.
**


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

* deletion possible only when the request is NEW
* and sy-uname = requester.

     if zmm_nmblkcdhd_st-ID_CREATOR = sy-uname.
       if zmm_nmblkcdhd_st-NM_STATUS = 'NEW'.

         DELETE FROM zmm_nmblkcdhd
         WHERE reqno = zmm_nmblkcdhd_st-reqno.
         IF sy-subrc <> 0.
           MESSAGE e233(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
           EXIT.
         ENDIF.
*
         SELECT tdobject tdname tdid FROM stxl
          INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
          WHERE tdid = 'MMNM'.
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
         ELSE.
           MESSAGE e233(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
           EXIT.
         ENDIF.

        else.
          MESSAGE e235(zmm_oth).
       endif. "//zmm_nmblkcdhd_st-NM_STATUS = 'NEW'.
     else.
       MESSAGE e234(zmm_oth).
     endif. "// zmm_nmblkcdhd_st-ID_CREATOR = sy-uname.
     CLEAR g_choice.
   ENDIF.

 endform.                    " prepare_delete


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
   DATA: l_datech(20) TYPE c.
***********Assignments***********************
   CLEAR l_theader.
   l_theader-tdobject   = 'ZMMNM'.
   l_theader-tdid       = 'MMNM'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_nmblkcdhd_st-reqno INTO l_theader-tdname.

   IF tlinetab2[] IS NOT INITIAL.

* append date & time to previous communication
     CLEAR g_cores_sender.
     CONCATENATE sy-datum+6(2) '/'
                 sy-datum+4(2) '/'
                 sy-datum+0(4) '  '
                 sy-uzeit+0(2) ':'
                 sy-uzeit+2(2) ':'
                 sy-uzeit+4(2) INTO l_datech RESPECTING BLANKS.


     CONCATENATE '****' sy-uname l_datech INTO g_cores_sender
      SEPARATED BY '   '.

     APPEND g_cores_sender TO tlinetab1.
     CLEAR g_cores_sender.

* append current communication
     APPEND LINES OF tlinetab2 TO tlinetab1.

*append a blank line

     CONCATENATE '*    ' '  '  INTO g_cores_sender RESPECTING BLANKS.
     APPEND g_cores_sender TO tlinetab1.


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

** after saving, clear contents of tlinetab2
   clear tlinetab2.
   REFRESH tlinetab2.

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
   DATA : l_get2(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR              = 'DELETE '
       TEXT_QUESTION         = 'Data will be lost,No recovery possible,Are you sure ?'
       DISPLAY_CANCEL_BUTTON = ' '
       START_COLUMN          = 25
       START_ROW             = 6
     IMPORTING
       ANSWER                = l_get2
     EXCEPTIONS
       TEXT_NOT_FOUND        = 1
       OTHERS                = 2.
   IF SY-SUBRC = 0.
     CASE l_get2.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.

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

***********&---------------------------------------------------------------------*
***********&      Form  unblock_matcode
***********&---------------------------------------------------------------------*
***********       text
***********----------------------------------------------------------------------*
***********  -->  p1        text
***********  <--  p2        text
***********----------------------------------------------------------------------*
**************** form unblock_matcode.
****************   Data : l_unblk100 type t_tct100.
****************   Data : l_atwrt like ausp-atwrt,
****************          l_matnr like mara-matnr,
****************          l_atinn like ausp-atinn.
****************   Data : l_totlines type i,
****************          l_unblklines type i.
******************
****************   CLEAR   wa_nmblkcddt.
****************   REFRESH itab_nmblkcddt[].
******************
****************   clear g_mesg.
****************   READ TABLE g_tct100_itab into l_unblk100
****************        WITH KEY flag  = 'X'.
****************   IF sy-subrc <> 0.
****************     g_mesg = 'X'.
****************     MESSAGE i101(zmm_oth).
****************     EXIT.
****************   ENDIF.
******************
****************   PERFORM confirm_unblock.
****************   IF g_choice = 'J'.
*******************Updating classification view.
****************     LOOP AT g_tct100_itab into g_tct100_wa
****************          where flag  = 'X'
****************          and   errcd = ''.
****************       l_matnr = g_tct100_wa-matcode.
****************
****************
****************       update mara set ZZMBPR = ''
****************                       ZZNMFLG = ''
****************                   where matnr = l_matnr.
****************       if sy-subrc = 0.
****************
****************       endif.
****************
****************       SELECT SINGLE * FROM klah
****************                  WHERE klart  = '001'
****************                  AND   class  = 'Z_ONGC_BLOCK'.
****************       IF sy-subrc = 0.
****************         DELETE FROM KSSK
****************                where objek = l_matnr
****************                AND   clint = klah-clint
****************                AND   klart = '001'.
****************       ENDIF.
******************
****************       SELECT SINGLE atinn INTO l_atinn
****************                           FROM   cabn
****************                           WHERE  atnam = 'Z_ONGC_REASON'.
****************       If sy-subrc = 0.
****************         Delete from AUSP
****************                WHERE  objek = l_matnr
****************                AND    atinn = l_atinn.
******************
****************         g_tct100_wa-mstae = ''.
****************         modify g_tct100_itab from g_tct100_wa.
******************
****************       Endif.
******************  Updating internal comment in basic view..
****************       perform update_internal_comment using g_tct100_wa-matcode
****************                                             g_tct100_wa-res_nm.
****************       Clear: l_matnr,l_atinn.
****************
****************     ENDLOOP.
******************Updating database table
****************     LOOP AT g_tct100_itab INTO g_tct100_wa
****************                           where flag = 'X'
****************                           and   errcd = ''.
****************       MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
****************       MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
****************       move sy-uname to wa_nmblkcddt-unblkby.
****************       move sy-datum to wa_nmblkcddt-unblkdt.
****************       append wa_nmblkcddt to itab_nmblkcddt.
****************       clear:g_tct100_wa,wa_nmblkcddt.
****************     ENDLOOP.
****************     LOOP AT g_tct100_itab INTO g_tct100_wa
****************                           where errcd <> ''.
****************       MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
****************       MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
****************       append wa_nmblkcddt to itab_nmblkcddt.
****************     ENDLOOP.
****************     modify zmm_nmblkcddt from table itab_nmblkcddt.
****************
*******************Setting the request status.
****************     IF zmm_nmblkcdhd_st-status = 'IR'.
****************       PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************     ELSE.
*****************        DESCRIBE TABLE g_tct100_itab LINES l_totlines.
****************       SELECT COUNT(*) INTO l_totlines
****************                       FROM zmm_nmblkcddt
****************                       WHERE reqno = zmm_nmblkcdhd_st-reqno.
****************
****************       SELECT COUNT(*) INTO l_unblklines
****************                     FROM zmm_nmblkcddt
****************       WHERE reqno = zmm_nmblkcdhd_st-reqno
****************       AND   mstae = ''.
****************
****************       IF l_unblklines < l_totlines.
****************         zmm_nmblkcdhd_st-status = 'IC'.
****************         PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************       ELSE.
****************         zmm_nmblkcdhd_st-status = 'C'.
****************         PERFORM set_reqcl USING zmm_nmblkcdhd_st-status.
****************       ENDIF.
****************     ENDIF.
****************     PERFORM save_cors_text.
****************   ELSE.
****************     g_mesg = 'X'.
****************   ENDIF.
****************   CLEAR g_choice.
****************
***************** LOOP AT C_EBAN
*****************    SELECT * FROM kssk INTO TABLE tkssk
*****************              WHERE objek = c_eban-matnr
*****************              AND   klart = '001'.
*****************     IF sy-subrc = 0.  " kssk
*****************      LOOP AT tkssk.
*****************        SELECT SINGLE * FROM klah
*****************               WHERE klart  = '001'
*****************               AND   clint  = tkssk-clint
*****************               AND   class  = 'Z_ONGC_BLOCK'.
*****************        IF sy-subrc = 0.
*****************          SELECT SINGLE atinn INTO l_atinn
*****************                 FROM   cabn
*****************                 WHERE atnam = 'Z_ONGC_REASON'.
*****************          If sy-subrc = 0.
*****************             Select single atwrt into l_atwrt
*****************                    from ausp
*****************                    WHERE  objek = l_matnr
*****************                    AND    atinn = l_atinn.
*****************              IF sy-subrc = 0.
*****************                if l_atwrt = 'NM'.
*****************                 message e154(zmm_oth) with l_matnr.
*****************                endif.
*****************              ENDIF.
*****************              CLEAR: l_atinn,l_atwrt.
*****************          ENDIF.
*****************        ENDIF.
*****************      ENDLOOP.
*****************     ENDIF.
*****************   ENDLOOP.
****************
**************** endform.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************** form confirm_approval.
**************
**************   DATA : l_get3(1) TYPE c.
**************   CALL FUNCTION 'POPUP_TO_CONFIRM'
**************     EXPORTING
**************       TITLEBAR              = 'Approval '
**************       TEXT_QUESTION         = 'Want to Approve the request ? '
**************       DISPLAY_CANCEL_BUTTON = ' '
**************       START_COLUMN          = 25
**************       START_ROW             = 6
**************     IMPORTING
**************       ANSWER                = l_get3
**************     EXCEPTIONS
**************       TEXT_NOT_FOUND        = 1
**************       OTHERS                = 2.
**************   IF SY-SUBRC = 0.
**************     CASE l_get3.
**************       WHEN '1'.
**************         MOVE 'J' TO g_app.
**************       WHEN '2'.
**************         MOVE 'N' TO g_app.
**************     ENDCASE.
**************   ENDIF.
**************
************** endform.                    " confirm_approval




****&---------------------------------------------------------------------*
****&      Form  upload_from_textfile
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****      -->P_P_TC_NAME  text
****      -->P_P_TABLE_NAME  text
****      -->P_P_MARK_NAME  text
****----------------------------------------------------------------------*
*** form upload_from_textfile using  p_tc_name
***                                  p_table_name
***                                  p_mark_name.
***   DATA: l_filename LIKE rlgrap-filename.
***   DATA: l_tx100  TYPE t_tx100.
***   DATA: wa_tx100 TYPE t_tx100.
***   refresh : g_ex100_itab[].
***
***
***   DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
***          l_FILETABLE  TYPE  FILE_TABLE,
***          l_RC         TYPE  I,
***          l_P_DEF_FILE TYPE  STRING,
***          l_P_FILE     TYPE  STRING,
***          l_usr_act    TYPE  I.
***
***   l_P_DEF_FILE = l_filename.
***
***   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
***     EXPORTING
****      WINDOW_TITLE            =
****      DEFAULT_EXTENSION       =
***       DEFAULT_FILENAME        = l_P_DEF_FILE
****      FILE_FILTER             =
****      WITH_ENCODING           =
****      INITIAL_DIRECTORY       =
****      MULTISELECTION          =
***     CHANGING
***       FILE_TABLE              = I_FILE_TABLE
***       RC                      = l_RC
***       USER_ACTION             = l_usr_act
****      FILE_ENCODING           =
***     EXCEPTIONS
***       FILE_OPEN_DIALOG_FAILED = 1
***       CNTL_ERROR              = 2
***       ERROR_NO_GUI            = 3
***       NOT_SUPPORTED_BY_GUI    = 4
***       others                  = 5.
***   IF SY-SUBRC = 0 AND
***      l_usr_act <>
***      CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
***
***     LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
***       l_P_FILE = l_FILETABLE.
***       EXIT.
***     ENDLOOP.
***
***     CALL FUNCTION 'GUI_UPLOAD'
***       EXPORTING
***         FILENAME                = l_P_FILE
***         FILETYPE                = g_c_asc
***         HAS_FIELD_SEPARATOR     = 'X'
***       TABLES
***         DATA_TAB                = g_tx100_itab
***       EXCEPTIONS
***         FILE_OPEN_ERROR         = 1
***         FILE_READ_ERROR         = 2
***         NO_BATCH                = 3
***         GUI_REFUSE_FILETRANSFER = 4
***         INVALID_TYPE            = 5
***         NO_AUTHORITY            = 6
***         UNKNOWN_ERROR           = 7
***         BAD_DATA_FORMAT         = 8
***         HEADER_NOT_ALLOWED      = 9
***         SEPARATOR_NOT_ALLOWED   = 10
***         HEADER_TOO_LONG         = 11
***         UNKNOWN_DP_ERROR        = 12
***         ACCESS_DENIED           = 13
***         DP_OUT_OF_MEMORY        = 14
***         DISK_FULL               = 15
***         DP_TIMEOUT              = 16
***         OTHERS                  = 17.
***     IF SY-SUBRC <> 0.
***       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
***     ENDIF.
***
***   ENDIF.
***
***   sort g_tx100_itab ascending by matcode.
***   delete adjacent duplicates from g_tx100_itab comparing matcode.
***
***data:  WA_TCT100 LIKE LINE OF g_TCT100_itab.
***   loop at g_tx100_itab[] INTO wa_tx100.
***    MOVE-CORRESPONDING wa_tx100 to  WA_TCT100.
***    APPEND  WA_TCT100 to g_TCT100_itab.
***    CLEAR WA_TCT100.
***   endloop.
***
***    CLEAR g_tx100_itab.
***    refresh g_tx100_itab[].
***
***
***
*** endform.                    " upload_from_textfile



******************&---------------------------------------------------------------------*
******************&      Form  get_data_from_tx100
******************&---------------------------------------------------------------------*
******************       text
******************----------------------------------------------------------------------*
******************  -->  p1        text
******************  <--  p2        text
******************----------------------------------------------------------------------*
****************** form get_data_from_tx100.
******************   Data: l_tx100_wa type t_tx100,
******************         l_srno like zmm_nmblkcddt-srno.
*********************Setting serial number.
******************   if g_tctlines = 0.
******************     l_srno = 0.
******************   else.
******************     if g_mode = 'CHA'.
******************       Select max( srno ) into l_srno from zmm_nmblkcddt
******************              where reqno = zmm_nmblkcdhd_st-reqno.
******************     else.
******************       l_srno = g_tctlines.
******************     endif.
******************   endif.
*********************
******************   loop at g_tx100_itab into l_tx100_wa.
******************     l_srno = l_srno + 1.
******************     g_tct100_wa-srno    = l_srno.
******************     g_tct100_wa-matcode = l_tx100_wa-matcode.
******************     select single maktx into g_tct100_wa-matdesc from makt
******************            where matnr = l_tx100_wa-matcode.
******************     select single meins into g_tct100_wa-uom from mara
******************            where matnr = l_tx100_wa-matcode.
******************     g_tct100_wa-res_nm  = l_tx100_wa-res_nm.
*********************check for non moving items..
******************     clear g_recstat.
******************     PERFORM validate_matcode USING l_tx100_wa-matcode
******************                              CHANGING g_recstat.
******************     if g_recstat = 'E'.
******************       g_tct100_wa-errcd = 'M'.
******************       g_tct100_wa-flag  = 'X'.
******************     endif.
*********************
******************     append g_tct100_wa to g_tct100_itab .
******************     clear g_tct100_wa.
******************   endloop.
****************** endform.                    " get_data_from_tx100


*******************&---------------------------------------------------------------------*
*******************&      Form  validate_matcode
*******************&---------------------------------------------------------------------*
*******************       text
*******************----------------------------------------------------------------------*
*******************      -->P_WA_TX100_MATCODE  text
*******************      <--P_G_RECSTAT  text
*******************----------------------------------------------------------------------*
****************** form validate_matcode using    p_matcode
******************                       changing p_recstat.
******************   Data: l_objek like ausp-objek.
******************   Select single objek into l_objek from ausp
******************           where objek = p_matcode
******************           and   atinn = ( Select atinn from cabn
******************                                  where atnam = 'Z_ONGC_REASON' )
******************           and   klart = '001'
******************           and   atwrt = 'NM'.
******************   if sy-subrc <> 0.
******************     p_recstat = 'E'.
******************   endif.
****************** endform.                    " validate_matcode
******************

********************&---------------------------------------------------------------------*
********************&      Form  check_errors
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
********************  -->  p1        text
********************  <--  p2        text
********************----------------------------------------------------------------------*
******************* form check_errors changing p_errstat.
*******************   Data : l_tct100 type t_tct100.
*********************
*******************   read table g_tct100_itab into l_tct100
*******************                            with key errcd = 'M'.
*******************   if sy-subrc = 0.
*******************     p_errstat = 'E'.
*******************     message i121(zmm_oth) with l_tct100-srno.
*******************   endif.
*******************
******************* endform.                    " check_errors


*&---------------------------------------------------------------------*
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*** form attach_file.
***
***   clear g_att_files_wa.
***   refresh g_att_files.
***   IF g_mode = 'CHA'.
***     g_att_files_wa-LOGSYS  = zmm_nmblkcdhd_st-reqno.
***     g_att_files_wa-objtype = 'NMC'.   "'ATT'.
***     g_att_files_wa-objkey  = '01'.
***
***     append g_att_files_wa to g_att_files.
***
***     CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
***       EXPORTING
***         ATTACHMENT_DATA     = ''
***         ATTACHMENT_TYPE     = 'DOC'
***       TABLES
***         APPLICATION_OBJECTS = g_att_files.
***   Endif.
***
***
*** endform.                    " attach_file


*&---------------------------------------------------------------------*
*&      Form  list_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*** form list_file.
***   g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa.
****   FUNCTION                 = ' '
**** TABLES
****   FUNC_EXCLUDE             =  .
*** endform.                    " list_file



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

     DATA : l_get4(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR              = 'EXIT '
         TEXT_QUESTION         = 'Data will be lost, Want to quit? '
         DISPLAY_CANCEL_BUTTON = ' '
         START_COLUMN          = 25
         START_ROW             = 6
       IMPORTING
         ANSWER                = l_get4
       EXCEPTIONS
         TEXT_NOT_FOUND        = 1
         OTHERS                = 2.

     IF SY-SUBRC = 0.
       CASE l_get4.
         WHEN '1'.
           MOVE 'J' TO l_choice1.
         WHEN '2'.
           MOVE 'N' TO l_choice1.
       ENDCASE.
     ENDIF.

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


*************************&---------------------------------------------------------------------*
*************************&      Form  confirm_unblock
*************************&---------------------------------------------------------------------*
*************************       text
*************************----------------------------------------------------------------------*
*************************  -->  p1        text
*************************  <--  p2        text
*************************----------------------------------------------------------------------*
************************ form confirm_unblock.
************************   CLEAR g_choice.
************************
************************   DATA : l_get5(1) TYPE c.
************************   CALL FUNCTION 'POPUP_TO_CONFIRM'
************************     EXPORTING
************************       TITLEBAR              = 'Unblock'
************************       TEXT_QUESTION         = 'Want to unblock selected Codes ?'
************************       DISPLAY_CANCEL_BUTTON = ' '
************************       START_COLUMN          = 25
************************       START_ROW             = 6
************************     IMPORTING
************************       ANSWER                = l_get5
************************     EXCEPTIONS
************************       TEXT_NOT_FOUND        = 1
************************       OTHERS                = 2.
************************   IF SY-SUBRC = 0.
************************     CASE l_get5.
************************       WHEN '1'.
************************         MOVE 'J' TO g_choice.
************************       WHEN '2'.
************************         MOVE 'N' TO g_choice.
************************     ENDCASE.
************************   ENDIF.
************************
************************ endform.                    " confirm_unblock



*********************&---------------------------------------------------------------------*
*********************&      Form  popup_message
*********************&---------------------------------------------------------------------*
*********************       text
*********************----------------------------------------------------------------------*
*********************  -->  p1        text
*********************  <--  p2        text
*********************----------------------------------------------------------------------*
******************** form popup_message.
********************   Data : wa_text like trtab.
********************   Data : itab_text like trtab occurs 0.
********************   refresh itab_text.
**********************
********************   wa_text =
********************   'Please ensure that approval of concerned Director for unblocking '.
********************   append wa_text to itab_text.
********************   clear wa_text.
********************
********************   wa_text =
********************   'of Material codes has been attached in the change mode.'.
********************   append wa_text to itab_text.
********************   clear wa_text.
********************
********************   CALL FUNCTION 'LAW_SHOW_POPUP_WITH_TEXT'
********************     EXPORTING
********************       titelbar           = 'NOTE'
********************       SHOW_CANCEL_BUTTON = 'X'
********************       LINE_SIZE          = 65
********************     TABLES
********************       list_tab           = itab_text.
********************   IF sy-subrc <> 0.
********************* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*********************         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
********************   ENDIF.
********************
******************** endform.                    " popup_message



***********************&---------------------------------------------------------------------*
***********************&      Form  set_reqcl
***********************&---------------------------------------------------------------------*
***********************       text
***********************----------------------------------------------------------------------*
***********************      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
***********************----------------------------------------------------------------------*
********************** form set_reqcl using p_status.
**********************   UPDATE zmm_nmblkcdhd
**********************   SET status = p_status
**********************   WHERE reqno = zmm_nmblkcdhd_st-reqno.
**********************
************************
**********************   IF zmm_nmblkcdhd_st-status = 'IR'.
**********************     UPDATE zmm_nmblkcdhd
**********************      SET ir_date = sy-datum
**********************      WHERE reqno = zmm_nmblkcdhd_st-reqno.
**********************   ENDIF.
**********************
********************** endform.                    " set_reqcl


********************&---------------------------------------------------------------------*
********************&      Form  update_internal_comment
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
********************      -->P_G_TCT100_WA_MATCODE  text
********************      -->P_G_TCT100_WA_RESNM  text
********************----------------------------------------------------------------------*
******************* form update_internal_comment using    p_matcode
*******************                                       p_res_nm.
*******************   Data: wa_lines like tline,
*******************         l_txt like tline-tdline,
*******************         l_insert type c.
*******************   Data : header like  thead,
*******************          l_tdname like thead-tdname.
*******************   Data : ist_nmlines like tline occurs 0 with header line.
*******************
***********************Update Internal Comments
*******************   header-tdobject = 'MATERIAL'.
*******************   header-tdid     = 'IVER'.
*******************   header-tdname   =  p_matcode .
*******************   header-tdspras  = 'EN'.
*******************   header-tdform   = 'SYSTEM'.
*******************   header-mandt    = sy-mandt .
*******************   l_tdname        = p_matcode.
*******************   refresh: ist_nmlines.
*******************
**********************Fetching the existing text against matcode.
*******************   select single * from stxh
*******************            where tdobject = 'MATERIAL'
*******************            and   tdname   = l_tdname
*******************            and   tdid     = 'IVER'.
*******************   if sy-subrc = 0.
*******************     CALL FUNCTION 'READ_TEXT'
*******************       EXPORTING
*******************         client   = sy-mandt
*******************         id       = 'IVER'
*******************         language = 'E'
*******************         name     = l_tdname
*******************         object   = 'MATERIAL'
*******************       TABLES
*******************         lines    = ist_nmlines.
*******************   endif.
**********************Appending the remark to existing text.
*******************   IF NOT ist_nmlines[] IS INITIAL.
*******************     wa_lines-tdformat = '*'.
*******************     wa_lines-tdline = '               '.
*******************     append wa_lines to ist_nmlines .
*******************   ENDIF.
*******************   concatenate sy-uname '-' sy-datum+6(2) '/'
*******************                            sy-datum+4(2) '/'
*******************                            sy-datum+0(4) '/' into l_txt .
*******************   wa_lines-tdformat = '*'.
*******************   wa_lines-tdline  =  l_txt .
*******************   append wa_lines to ist_nmlines .
*******************   wa_lines-tdline = p_res_nm.
*******************   append wa_lines to ist_nmlines .
*******************   clear l_txt.
*******************   concatenate 'Request no-' zmm_nmblkcdhd_st-reqno into l_txt.
*******************   wa_lines-tdline = l_txt.
*******************   append wa_lines to ist_nmlines .
*******************   wa_lines-tdline = '******************************************'.
*******************   append wa_lines to ist_nmlines .
*******************
*******************   if ist_nmlines[] is initial.
*******************     l_insert = 'X'.
*******************   else.
*******************     l_insert =  space.
*******************   endif.
**********************Saving the nonmoving text ( Remark)
*******************
*******************   CALL FUNCTION 'SAVE_TEXT'
*******************     EXPORTING
*******************       client          = sy-mandt
*******************       header          = header
*******************       insert          = l_insert
*******************       savemode_direct = 'X'
*******************     TABLES
*******************       lines           = ist_nmlines.
*******************
*******************
******************* endform.                    " update_internal_comment



****&---------------------------------------------------------------------*
****&      Form  del_attachment
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form del_attachment.
***   g_att_files_wa-LOGSYS = zmm_nmblkcdhd_st-reqno.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   CALL FUNCTION 'ZSO_DEL_ATTACHMENT'
***     EXPORTING
***       application_object = g_att_files_wa.
****    FUNCTION                 = ' '.
***
***
***
*** endform.                    " del_attachment


****&---------------------------------------------------------------------*
****&      Form  guidelines
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form guidelines.
***
***   clear g_att_files_wa.
***   g_att_files_wa-LOGSYS = 'UBNMCDHELP'.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***
***
***   refresh exclude_tab[].
***   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa
***     TABLES
***       FUNC_EXCLUDE       = EXCLUDE_TAB.
***
*** endform.                    " guidelines


****&---------------------------------------------------------------------*
****&      Form  circular
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****  -->  p1        text
****  <--  p2        text
****----------------------------------------------------------------------*
*** form circular.
***   clear g_att_files_wa.
***
***   g_att_files_wa-LOGSYS = 'UBNMCDCIRC'.
***   g_att_files_wa-objtype = 'NMC'.
***   g_att_files_wa-objkey = '01'.
***
***   refresh exclude_tab[].
***   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
***
***   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
***     EXPORTING
***       APPLICATION_OBJECT = g_att_files_wa
***     TABLES
***       FUNC_EXCLUDE       = EXCLUDE_TAB.
***
*** endform.                    " circular



*&---------------------------------------------------------------------*
*&      Form  EXTRACT_PLANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXTRACT_PLANTS .
   REFRESH: ist_agr_users_plant, ist_plant.
   clear: wa_agr_users_plant, wa_plant.

   Data: L_ROLE_PLANT type agr_name.
   data: len type i,
         plant type WERKS_D.

   CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE_PLANT.

   len = strlen( L_ROLE_PLANT ).   " length including %
   len = len - 1.

   select * from agr_users
       into TABLE ist_agr_users_plant
         where uname = sy-uname
           and agr_name like L_ROLE_PLANT
           and from_dat <=   sy-datum
           and   to_dat >=  sy-datum.
   if  ist_agr_users_plant[] is initial.
     message id 'ZMSG' type 'E' number '000' with 'No MM INDENT PLANT authorization in' ZMM_NMBLKCDHD_ST-BUKRS 'comp code'.
   else .
     loop at ist_agr_users_plant INTO wa_agr_users_plant.
       wa_plant-plant = wa_agr_users_plant-agr_name+len(4).
       APPEND wa_plant to ist_plant.
     endloop.
   endif.


 ENDFORM.                    " EXTRACT_PLANTS
*&---------------------------------------------------------------------*
*&      Form  EXTRACT_PURCH_GRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXTRACT_PURCH_GRP .
   REFRESH: ist_agr_users_pgrp, ist_pgrp.
   clear: wa_agr_users_pgrp, wa_pgrp.

   Data: L_ROLE_PGRP type agr_name.   "purchase grp. MM_PUR_PO_MUM_PGRP_*
   data: len type i,
         pgrp type EKGRP.

   CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE_PGRP.

   len = strlen( L_ROLE_PGRP ).   " length including %
   len = len - 1.

   select * from agr_users
       into TABLE ist_agr_users_pgrp
         where uname = sy-uname
           and agr_name like L_ROLE_PGRP
           and from_dat <=   sy-datum
           and   to_dat >=  sy-datum.

   if  ist_agr_users_pgrp[] is initial.
     message id 'ZMSG' type 'W' number '000' with 'No Purchase Grp authorization in' ZMM_NMBLKCDHD_ST-BUKRS 'comp code'.
   else .
     loop at ist_agr_users_pgrp INTO wa_agr_users_pgrp.
       wa_pgrp-EKGRP = wa_agr_users_pgrp-agr_name+len(3).
       APPEND wa_pgrp to ist_pgrp.
     endloop.
   endif.

*  wa_pgrp-EKGRP = '1U1'. " TEMP
*  APPEND wa_pgrp to ist_pgrp.


 ENDFORM.                    " EXTRACT_PURCH_GRP

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SUBMIT_REQUEST .
   CALL SCREEN 103 STARTING AT 10 2 ENDING AT 71 7.
   IF g_rel = 'Y'.
     PERFORM update_submit.
     PERFORM clear_var.
   ELSE.
     EXIT.
   ENDIF.


 ENDFORM.                    " SUBMIT_REQUEST

 form update_submit.
*update status & rel date
   UPDATE zmm_nmblkcdhd
     SET NM_STATUS    = 'IL3L4'
         DATE_CREATOR = sy-datum
     WHERE reqno    = zmm_nmblkcdhd_st-reqno.

   PERFORM save_cors_text.
   COMMIT WORK.
*    FM SWE_EVENT_CREATE

   data L_OBJKEY type SWEINSTCOU-OBJKEY.
   move zmm_nmblkcdhd_st-reqno to L_OBJKEY.

   CALL FUNCTION 'SWE_EVENT_CREATE'
     EXPORTING
       OBJTYPE                       = 'ZBUS_NM'
       OBJKEY                        = L_OBJKEY
       EVENT                         = 'RELEASE'
*   CREATOR                       = ' '
*   TAKE_WORKITEM_REQUESTER       = ' '
*   START_WITH_DELAY              = ' '
*   START_RECFB_SYNCHRON          = ' '
*   NO_COMMIT_FOR_QUEUE           = ' '
*   DEBUG_FLAG                    = ' '
*   NO_LOGGING                    = ' '
*   IDENT                         =
* IMPORTING
*   EVENT_ID                      =
*   RECEIVER_COUNT                =
* TABLES
*   EVENT_CONTAINER               =
* EXCEPTIONS
*   OBJTYPE_NOT_FOUND             = 1
*   OTHERS                        = 2
             .
   IF SY-SUBRC <> 0.
     MESSAGE i217(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. " Event creation error for req &.
   else.  " successful
     COMMIT WORK.
     MESSAGE i216(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.

*      mail and SMS to incharge                                           by                       mail/sms_to            other_text
     perform send_mail using ZMM_NMBLKCDHD_ST-REQNO 'released' ZMM_NMBLKCDHD_ST-ID_CREATOR ZMM_NMBLKCDHD_ST-ID_INCHARGE 'for your kind approval'. "'for your kind approval'.
     perform send_sms using ZMM_NMBLKCDHD_ST-REQNO 'released' ZMM_NMBLKCDHD_ST-ID_CREATOR ZMM_NMBLKCDHD_ST-ID_INCHARGE 'for your kind approval'. "'for your kind approval'.
   ENDIF.


 endform.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_REQNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VALIDATE_REQNO .

   data: zmm_nmblkcdhd_t type zmm_nmblkcdhd.


   SELECT SINGLE * FROM zmm_nmblkcdhd
     INTO  zmm_nmblkcdhd_t
       WHERE reqno = zmm_nmblkcdhd_st-reqno.

   IF sy-subrc = 0.

     IF zmm_nmblkcdhd_t-nm_status <> 'NEW'.
       MESSAGE e201(zmm_oth) WITH zmm_nmblkcdhd_t-nm_status. "Request is not with the creator(Current Status: &)
     ENDIF.

     IF zmm_nmblkcdhd_t-id_creator <> sy-uname.
       MESSAGE e107(zmm_oth) WITH zmm_nmblkcdhd_t-id_creator. "Request can only be released by the creator
     ENDIF.

   else.
     MESSAGE e202(zmm_oth) WITH zmm_nmblkcdhd_st-reqno. "Invalid request no.

   ENDIF.


 ENDFORM.                    " VALIDATE_REQNO
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA .
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_DATA . " For L3L4, L2, L1, DIR
*update IDs if changed (ID_L1L2 ID_DIRECTOR) , correspondence
   data: WA_ZMM_NMBLKCDHD type ZMM_NMBLKCDHD.
   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF
*SAVE HEADER DATA
   MOVE-CORRESPONDING ZMM_NMBLKCDHD_ST to WA_ZMM_NMBLKCDHD.
   Modify ZMM_NMBLKCDHD from WA_ZMM_NMBLKCDHD.
   clear WA_ZMM_NMBLKCDHD..

*SAVE deatail data
   PERFORM SAVE_DETAILS.

*save correspondence
   PERFORM save_cors_text.

   COMMIT WORK.

   APPR_STATUS = 'SAV'.  " for WF
   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i205(zmm_oth). "data saved

 ENDFORM.                    " SAVE_DATA .
*&---------------------------------------------------------------------*
*&      Form  REL_REJ_REV.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM REL_REJ_REV.

*update status, IDs changed (ID_L1L2 ID_DIRECTOR) , correspondence
   data: WA_ZMM_NMBLKCDHD type ZMM_NMBLKCDHD.
   data: msg(40).

   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF

*Update HEADER DATA
   MOVE-CORRESPONDING ZMM_NMBLKCDHD_ST to WA_ZMM_NMBLKCDHD.

   CASE ok_code100.
     WHEN 'RELL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL2'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request released to L2 Level.'.
       APPR_STATUS = 'REL'.

*   Request ### to unblock NON MOVING materials is released by user id ####/Name |for your kind approval.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L2: WA_ZMM_NMBLKCDHD-ID_L2
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L2 ', for your kind approval'. " 'for your kind approval'
* mail to L2: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L2 ', for your kind approval'. "'for your kind approval'.

     WHEN 'REJL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL3L4'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.
* SAP MAIL and SMS to CREATOR:                                    by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL3L4'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'NEW'.
       WA_ZMM_NMBLKCDHD-DATE_L3L4 = sy-datum.
       msg = 'Request sent back to Requisitioner.'.
       APPR_STATUS = 'REV'.   " WF ends if REVERTED by L3L4
* SAP MAIL and SMS to CREATOR:                                    by                       mail/sms_to            other_text
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_CREATOR
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

     WHEN 'RELL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL1'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request released to L1 Level.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L1: WA_ZMM_NMBLKCDHD-ID_L1
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_L1 ', for your kind approval'. " 'for your kind approval'

* mail to L1: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_INCHARGE WA_ZMM_NMBLKCDHD-ID_L1 ', for your kind approval'. "'for your kind approval'.


     WHEN 'REJL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL2'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL3L4'.
       WA_ZMM_NMBLKCDHD-DATE_L2 = sy-datum.
       msg = 'Request sent back to L3/L4 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to INCHARGE: WA_ZMM_NMBLKCDHD-ID_INCHARGE
       PERFORM send_sms  using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_INCHARGE
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to I/c: 02.04.2014
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L2 WA_ZMM_NMBLKCDHD-ID_INCHARGE
             '. Pls see comments, if any, in the note sheet and take appropriate action'. "'for your kind approval'.


     WHEN 'RELL1L2'.   " Now L1
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IDIR'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request released to the Director Level.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                    rel_by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to Dir: WA_ZMM_NMBLKCDHD-ID_DIRECTOR
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_DIRECTOR ', for your kind approval'. " 'for your kind approval'

* SMS to Dir's PA : WA_ZMM_NMBLKCDHD-ID_DIRECTOR
       data: L_ID_DIRS_PA type sy-uname.
       clear L_ID_DIRS_PA.
       PERFORM get_dirs_pa USING WA_ZMM_NMBLKCDHD-ID_DIRECTOR CHANGING L_ID_DIRS_PA.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 L_ID_DIRS_PA ', for Director''s kind approval'. " 'for your kind approval'

* mail to Dir: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_DIRECTOR ', for your kind approval'. " 'for your kind approval'

* mail to Dir's PA: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' WA_ZMM_NMBLKCDHD-ID_L1 L_ID_DIRS_PA ', for Director''s kind approval'. " 'for your kind approval'


     WHEN 'REJL1L2'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJL1'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'

     WHEN 'REVL1L2'.

       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL2'.
       WA_ZMM_NMBLKCDHD-DATE_L1 = sy-datum.
       msg = 'Request sent back to L2 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     rev by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L2: WA_ZMM_NMBLKCDHD-ID_L2
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_L2
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to L2: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_L1 WA_ZMM_NMBLKCDHD-ID_L2
              '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'


     WHEN 'APPRDIR'.
** remove NM flags : form unblock_matcode.
*    WA_ZMM_NMBLKCDHD-NM_STATUS = 'COMPLETE'. "status will be set to 'complete' in the WF
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'APPRDIR'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request approved.'.
       APPR_STATUS = 'REL'.

* SAP MAIL and SMS to CREATOR:                                     appr by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'approved' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR '. Non moving flag has been removed'. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'approved' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR '. Non moving flag has been removed'. " 'for your kind approval'


     WHEN 'REJDIR'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'REJDIR'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request rejected completely.'.
       APPR_STATUS = 'REJ'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'rejected' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'


     WHEN 'REVDIR'.
       WA_ZMM_NMBLKCDHD-NM_STATUS = 'IL1'.
       WA_ZMM_NMBLKCDHD-DATE_DIR = sy-datum.
       msg = 'Request sent back to L1 Level.'.
       APPR_STATUS = 'REV'.

* SAP MAIL and SMS to CREATOR:                                     by                       mail/sms_to            other_text
       perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. "'for your kind approval'.
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_CREATOR ''. " 'for your kind approval'
* SMS to L1: WA_ZMM_NMBLKCDHD-ID_L1
       PERFORM send_sms using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_L1
*             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'
             '. Plz see the note & Reprocess.'. " 'for your kind approval'

* mail to L1: 02.04.2014
       PERFORM send_mail using WA_ZMM_NMBLKCDHD-REQNO 'reverted' WA_ZMM_NMBLKCDHD-ID_DIRECTOR WA_ZMM_NMBLKCDHD-ID_L1
             '. Pls see comments, if any, in the note sheet and take appropriate action'. " 'for your kind approval'

   ENDCASE.

   Modify ZMM_NMBLKCDHD from WA_ZMM_NMBLKCDHD.
   clear WA_ZMM_NMBLKCDHD..

*SAVE deatail data
   PERFORM SAVE_DETAILS.
*save correspondence
   PERFORM save_cors_text.

   COMMIT WORK.


   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i206(zmm_oth) with msg. "Request released to L1/L2 Level

***  now SMS and SAP MAIL to CREATOR


 ENDFORM.                    " REL_REJ_REV.

*&---------------------------------------------------------------------*
*&      Form  ROLE_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ROLE_AUTH .
* role & data based AUTH check
   Data: L_ROLE type agr_name.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
   data: L_SUBRC(1).
   clear L_SUBRC.
*End RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

**IF  sy-uname+0(3) <> 'CMM' . " no role check

   if sy-tcode = 'ZMMNMREQ'    . " User is requisitioner

     IF g_mode = 'CRE' OR g_mode = 'CHA'.
*1. MM_INDENT_MUM_PLANT_*
*2. MM_PUR_PO_MUM_PGRP_*

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*       PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.
       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

       CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE.
       PERFORM AUTH_CHECK_COMP USING L_ROLE 'Purchase Group'.

     ENDIF.

   elseif sy-tcode = 'ZMMNMWF2'.  "User is Incharge (L3/L4)

*1. MM_INDENT_MUM_PLANT_%
*2. MM_PUR_PO_MUM_PGRP_%(purchase grp)
*3. D:MM_PUR_PO_APPROVE_L4 OR L3


*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.

       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' '%' INTO L_ROLE.
     PERFORM AUTH_CHECK_COMP USING L_ROLE 'Purchase Group'.

     PERFORM AUTH_CHECK_L3L4.

   elseif sy-tcode = 'ZMMNMWFL2'. " User is L2, addnl requirement
*1. MM_INDENT_MUM_PLANT_*
*2. D:MM_PUR_PO_APPROVE_L2

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.

       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     PERFORM AUTH_CHECK_L2.

   elseif sy-tcode = 'ZMMNMWF3'. " User is L1
*1. MM_INDENT_MUM_PLANT_*
*2. D:MM_PUR_PO_APPROVE_L1 or D:MM_PUR_PO_APPROVE_L2

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE.
*     PERFORM AUTH_CHECK_COMP USING L_ROLE 'MM INDENT PLANT' L_SUBRC.
       CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE1.
       CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' '%' INTO L_ROLE2.
       PERFORM AUTH_CHECK_COMP_INDENT  USING L_ROLE1 L_ROLE2  'MM INDENT PLANT'.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     PERFORM AUTH_CHECK_L1.

   elseif sy-tcode = 'ZMMNMWF4'. " User is a Dir
*1.     D:MM_SRV_IND_APPROVE_DI
     PERFORM AUTH_CHECK_DIR.
   endif.

**ENDIF.

 ENDFORM.                    " ROLE_AUTH
*&---------------------------------------------------------------------*
*&      Form  PLANT_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_ROLE_PLANT  text
*----------------------------------------------------------------------*
 FORM AUTH_CHECK_COMP  USING P_L_ROLE P_TEXT .
** Purch grp specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and agr_name like P_L_ROLE
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e214(zmm_oth) with P_TEXT  ZMM_NMBLKCDHD_ST-BUKRS.  "No & authorization in & Company Code
   endif.

 ENDFORM.                    " PLANT_AUTH

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
FORM AUTH_CHECK_COMP_INDENT  USING P_L_ROLE1 P_L_ROLE2 P_TEXT .
** INDENT company code specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name like P_L_ROLE1
             or agr_name = P_L_ROLE2 )
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.

   if  wa_agr_users is initial.
     message e214(zmm_oth) with P_TEXT  ZMM_NMBLKCDHD_ST-BUKRS.  "No & authorization in & Company Code
   endif.

 ENDFORM.                    " PLANT_AUTH
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853


*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L3L4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L3L4.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L3'
               or agr_name =  'D:MM_PUR_PO_APPROVE_L4'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               or agr_name =  'D:MM_SRV_IND_APPROVE_L3'
               or agr_name =  'D:MM_SRV_IND_APPROVE_L4' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L3/L4'   .    "No relevant & level authorization.
   endif.

 ENDFORM.                    " AUTH_CHECK_L3L4

*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L1L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L2.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L2'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               or agr_name =  'D:MM_SRV_IND_APPROVE_L2' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L2' .    "No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_LEVEL


*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_L1L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
 FORM AUTH_CHECK_L1.
** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and ( agr_name =  'D:MM_PUR_PO_APPROVE_L1'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                or agr_name =  'D:MM_SRV_IND_APPROVE_L1' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'L1' .    "No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_LEVEL
*&---------------------------------------------------------------------*
*&      Form  AUTH_CHECK_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM AUTH_CHECK_DIR .

** level specific auth

   data: wa_agr_users type agr_users.

   select single * from agr_users
     into wa_agr_users
       where uname = sy-uname
         and  agr_name =  'D:MM_SRV_IND_APPROVE_DI'
         and from_dat <=   sy-datum
         and   to_dat >=  sy-datum.
   if  wa_agr_users is initial.
     message e215(zmm_oth) with 'Director' .    " No & level authorization for approving the request.
   endif.

 ENDFORM.                    " AUTH_CHECK_DIR
*&---------------------------------------------------------------------*
*&      Form  SAVE_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SAVE_DETAILS . "Save by L3L4, L2, L1, Dir
   clear g_tct100_wa.
   REFRESH itab_nmblkcddt.

   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
* fill Req. No. in each row
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
* fill Status, Rej_by , Rej_date for rejected rows

** Row status : Above L3l4: Update each row's status into DB table only when
* the request is being RELEASED, REVERTED or REJECTED, but not when only SAVEd.
* Also validate rows on RELEASE, REVERT and APPR.
     IF ok_code100+0(3) = 'REL'.
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
         wa_nmblkcddt-STATUS = 'REPLY'.
***  ELSEIF wa_nmblkcddt-DECISION = '' or wa_nmblkcddt-DECISION = 'QUERY'.

***       clear ok_code100.
***       MESSAGE E231(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REJ'.
       " Whole Request rejected, no update of row status or validation needed

     ELSEIF ok_code100+0(3) = 'REV'.

       IF wa_nmblkcddt-DECISION = 'ACCEPT'.   " solving: reverted accept is editable.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
         wa_nmblkcddt-STATUS = 'QUERY'.

***  ELSEIF wa_nmblkcddt-DECISION = ''
***          or wa_nmblkcddt-DECISION = 'REPLY'.
***       clear ok_code100 .
***       MESSAGE E232(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'APP'.   "approval by DIR

       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
         wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
         wa_nmblkcddt-STATUS = 'REJECTED'.
         move sy-uname to wa_nmblkcddt-REJBY.
         move sy-datum to wa_nmblkcddt-REJDATE.
**  ELSEIF wa_nmblkcddt-DECISION = ''
**            or wa_nmblkcddt-DECISION = 'QUERY'
**              or wa_nmblkcddt-DECISION = 'REPLY'..
**       clear ok_code100.
**       MESSAGE E230(zmm_oth).
       ENDIF.

     ENDIF.

     append wa_nmblkcddt to itab_nmblkcddt.
   ENDLOOP.

   MODIFY zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
*     INSERT zmm_nmblkcddt FROM TABLE itab_nmblkcddt.
 ENDFORM.                    " SAVE_DETAILS



*&---------------------------------------------------------------------*
*&      Form  VALIDATE_BEFORE_REL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VALIDATE_BEFORE_REL_REJ_REV .
*BREAK cab_alok.
   CASE ok_code100.
     WHEN 'SAV'. "Creator: Release by Creator
** Approval chain
       if G_REL_FLAG = 'X'.  " Release by Creator
         if ZMM_NMBLKCDHD_ST-ID_INCHARGE is INITIAL.
           CLEAR ok_code100.
           message e224(zmm_oth)  .
         endif.
       endif.

     WHEN 'RELL3L4'.
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_L2 is INITIAL
         or ZMM_NMBLKCDHD_ST-ID_L1 is INITIAL
           or ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth)  .
       endif.

     WHEN 'RELL2'.
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_L1 is INITIAL
           or ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth).
       endif.

     WHEN 'RELL1L2'.   "now for L1 only
** Approval chain
       if ZMM_NMBLKCDHD_ST-ID_DIRECTOR is INITIAL .
         CLEAR ok_code100.
         message e223(zmm_oth) .
       endif.

   ENDCASE.

* 11111
* row status: check accept  while release by creator
* delete duplicate validation code from  form insert_into_tab.  .
* reverted row can't be accpted by previous levels.

** Row status : validate each row for allowed status on Release by Creator,
**  and on rej/ rel/ rev by L3L4+

   clear g_tct100_wa.
   REFRESH itab_nmblkcddt.
   LOOP AT g_tct100_itab INTO g_tct100_wa.
     MOVE-CORRESPONDING g_tct100_wa TO wa_nmblkcddt.
* fill Req. No. in each row
     MOVE zmm_nmblkcdhd_st-reqno TO wa_nmblkcddt-reqno.
*

**Row status: For L3L4+: validate rows on RELEASE, REVERT and APPR.
*   For Creator: validate rows on Release by Creator, If this is a
*    reverted request and being released by the creator, creator can choose
*   only 'REJECT', 'REPLY'. ( Already ACCEPTed row will be read only. If this is
*   a fresh request, decision column will not be available to him. )
*   Fill Status, Rej_by , Rej_date for rejected rows

     IF ok_code100 = 'SAV' AND  G_REL_FLAG = 'X'  " Release by Creator
        and ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL is NOT INITIAL. "reverted request

       IF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECT'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
***     wa_nmblkcddt-STATUS = 'REPLY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
*     wa_nmblkcddt-STATUS = 'QUERY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
               or wa_nmblkcddt-DECISION = 'QUERY'.
*             or wa_nmblkcddt-DECISION = 'ACCEPT'.
         clear ok_code100.
         MESSAGE E231(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REL'.    " Rel by L3L4+
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.     "check
***     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
***     wa_nmblkcddt-STATUS = 'REPLY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
                or wa_nmblkcddt-DECISION = 'QUERY'.

         clear ok_code100.
         MESSAGE E231(zmm_oth) with wa_nmblkcddt-srno.
       ENDIF.

     ELSEIF ok_code100+0(3) = 'REJ'.    " Rej by L3L4+
       " Whole Request rejected, no update of row status or validation needed

     ELSEIF ok_code100+0(3) = 'REV'.
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
*     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = 'QUERY'.
***     wa_nmblkcddt-STATUS = 'QUERY'.
*  ELSEIF wa_nmblkcddt-DECISION = 'REPLY'.
*     wa_nmblkcddt-STATUS = 'REPLY'.
       ELSEIF wa_nmblkcddt-DECISION = ''
               or wa_nmblkcddt-DECISION = 'REPLY'. .
         clear ok_code100 .
         MESSAGE E232(zmm_oth).
       ENDIF.

     ELSEIF ok_code100+0(3) = 'APP'.   "approval by DIR
       IF wa_nmblkcddt-DECISION = 'ACCEPT'.
***     wa_nmblkcddt-STATUS = 'ACCEPTED'.
       ELSEIF wa_nmblkcddt-DECISION = 'REJECT'.
***     wa_nmblkcddt-STATUS = 'REJECTED'.
***     move sy-uname to wa_nmblkcddt-REJBY.
***     move sy-datum to wa_nmblkcddt-REJDATE.
       ELSEIF wa_nmblkcddt-DECISION = ''
                or wa_nmblkcddt-DECISION = 'QUERY'
                  or wa_nmblkcddt-DECISION = 'REPLY'..
         clear ok_code100.
         MESSAGE E230(zmm_oth).
       ENDIF.

     ENDIF.

     append wa_nmblkcddt to itab_nmblkcddt.
     clear wa_nmblkcddt.
   ENDLOOP.

 ENDFORM.                    " VALIDATE_BEFORE_REL_REJ_REV .
*&---------------------------------------------------------------------*
*&      Form  FILL_ENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_INCHARGE  text
*----------------------------------------------------------------------*
* FORM FILL_ENAME  TABLES   P_IST_INCHARGE like IST_INCHARGE.
 FORM FILL_ENAME  TABLES   P_IST_APPROVER STRUCTURE WA_APPROVER ."OR like IST_INCHARGE. OR "type STANDARD TABLE ty_user.

*SELECT ENAME FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE P_IST_INCHARGE
*  FOR ALL ENTRIES IN P_IST_INCHARGE
*  WHERE PERNR = P_IST_INCHARGE-UNAME.
   data: P_WA_APPROVER type ty_user.
   DATA: l_tabix      TYPE sy-tabix.
   data: L_ENAME type EMNAM.
   LOOP at P_IST_APPROVER into P_WA_APPROVER.
     l_tabix  = sy-tabix.
     SELECT ENAME
 FROM PA0001 INTO P_WA_APPROVER-ENAME UP TO 1 ROWS WHERE PERNR = P_WA_APPROVER-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     MODIFY P_IST_APPROVER index l_tabix  FROM P_WA_APPROVER TRANSPORTING ENAME.

   ENDLOOP.


 ENDFORM.                    " FILL_ENAME
*&---------------------------------------------------------------------*
*&      Form  CLEAR_OLD_VRM_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLEAR_OLD_APPR_CHAIN .
   if   FLAG_CLEAR_OLD_APPR_CHAIN = 'X'.
     clear ZMM_NMBLKCDHD_ST-ID_INCHARGE.
     clear ZMM_NMBLKCDHD_ST-ID_L2.
     clear ZMM_NMBLKCDHD_ST-ID_L1.
     clear ZMM_NMBLKCDHD_ST-ID_DIRECTOR.

     clear FLAG_CLEAR_OLD_APPR_CHAIN.
   endif.

 ENDFORM.                    " CLEAR_OLD_APPR_CHAIN
*&---------------------------------------------------------------------*
*&      Form  LOV_INCHARGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_INCHARGE .  "L3 / L4

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     data: IST_INCHARGE type TABLE OF ty_user,
           WA_INCHARGE type ty_user.

    CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

     CONCATENATE 'MM_PUR_PO_' ZMM_NMBLKCDHD_ST-BUKRS '_PGRP_' ZMM_NMBLKCDHD_ST-EKGRP INTO L_ROLE2.


     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_INCHARGE
         from ( ( agr_users as A
                  INNER JOIN  agr_users as B on B~uname = A~uname )
                  INNER JOIN  agr_users as C on C~uname = B~uname )

*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and B~agr_name = L_ROLE2
               and ( C~agr_name = 'D:MM_PUR_PO_APPROVE_L3'
                     or C~agr_name = 'D:MM_PUR_PO_APPROVE_L4'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                     or C~agr_name = 'D:MM_SRV_IND_APPROVE_L3'
                     or C~agr_name = 'D:MM_SRV_IND_APPROVE_L4' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.

     SORT IST_INCHARGE ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_INCHARGE COMPARING UNAME.

     perform FILL_ENAME TABLES IST_INCHARGE.

***  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
***    exporting
***      retfield        = 'UNAME'
***      dynpprog        = sy-cprog
***      dynpnr          = sy-dynnr
***      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
***      value_org       = 'S'
***    tables
***      value_tab       = IST_INCHARGE
***      field_tab       = ist_field
***      return_tab      = ist_return_tab
***      dynpfld_mapping = ist_dynpfld_mapping
***    exceptions
***      parameter_error = 1
***      no_values_found = 2
***      others          = 3.
***  if sy-subrc <> 0.
***    message id sy-msgid type sy-msgty number sy-msgno
***            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
***  endif.
***
***  ZMM_NMBLKCDHD_ST-ID_INCHARGE = ist_return_tab-fieldval.


     refresh g_list[].
     CLEAR g_value.
     loop at IST_INCHARGE INTO WA_INCHARGE.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_INCHARGE-UNAME.
       concatenate WA_INCHARGE-UNAME '-' WA_INCHARGE-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_INCHARGE


*&---------------------------------------------------------------------*
*&      Form  LOV_L2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_L2 .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     data: IST_L2 type TABLE OF ty_user,
           WA_L2 type ty_user.
    CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853


     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_L2
         from ( agr_users as A
                INNER JOIN  agr_users as B on B~uname = A~uname )
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
            and ( B~agr_name = 'D:MM_PUR_PO_APPROVE_L2'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                  or B~agr_name = 'D:MM_SRV_IND_APPROVE_L2' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.


     SORT IST_L2 ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_L2 COMPARING UNAME.

     perform FILL_ENAME TABLES IST_L2.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L2'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_L2
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_L2 = ist_return_tab-fieldval.


     refresh g_list[].
     CLEAR g_value.
     loop at IST_L2 INTO WA_L2.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_L2-UNAME.
       concatenate WA_L2-UNAME '-' WA_L2-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_L2'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.


   ENDIF.

 ENDFORM.                    " LOV_L2

*&---------------------------------------------------------------------*
*&      Form  LOV_L1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_L1 .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     clear: L_ROLE1A .
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     data: IST_L1 type TABLE OF ty_user,
           WA_L1 type ty_user.

     CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
    CONCATENATE 'C:MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1A.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
     select A~uname
       into CORRESPONDING FIELDS OF TABLE IST_L1
         from ( agr_users as A
                INNER JOIN  agr_users as B on B~uname = A~uname )
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
*         where A~agr_name = L_ROLE1
         where ( A~agr_name = L_ROLE1
                 or A~agr_name = L_ROLE1A )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
               and ( B~agr_name = 'D:MM_PUR_PO_APPROVE_L1'
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
                  or B~agr_name = 'D:MM_SRV_IND_APPROVE_L1' )
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 3001185
               and A~from_dat <=   sy-datum
               and A~to_dat >=  sy-datum.

     SORT IST_L1 ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_L1 COMPARING UNAME.

     perform FILL_ENAME TABLES IST_L1.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L1'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_L1
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_L1 = ist_return_tab-fieldval.

     refresh g_list[].
     CLEAR g_value.
     loop at IST_L1 INTO WA_L1.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_L1-UNAME.
       concatenate WA_L1-UNAME '-' WA_L1-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_L1'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_L1

*&---------------------------------------------------------------------*
*&      Form  LOV_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM LOV_DIR .

   IF g_mode <> 'DIS'.

     refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
     clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

     clear: L_ROLE1 ,
            L_ROLE2 ,
            L_ROLE3 .

     data: IST_DIR type TABLE OF ty_user,
           WA_DIR type ty_user.

     select uname
       into CORRESPONDING FIELDS OF TABLE IST_DIR
         from agr_users
         where agr_name = 'D:MM_SRV_IND_APPROVE_DI'
               and from_dat <=   sy-datum
               and to_dat >=  sy-datum.

     SORT IST_DIR ASCENDING by UNAME.
     delete ADJACENT DUPLICATES FROM IST_DIR COMPARING UNAME.

     perform FILL_ENAME TABLES IST_DIR.

*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*    exporting
*      retfield        = 'uname'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
*      value_org       = 'S'
*    tables
*      value_tab       = IST_DIR
*      field_tab       = ist_field
*      return_tab      = ist_return_tab
*      dynpfld_mapping = ist_dynpfld_mapping
*    exceptions
*      parameter_error = 1
*      no_values_found = 2
*      others          = 3.
*  if sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.
*  ZMM_NMBLKCDHD_ST-ID_DIRECTOR = ist_return_tab-fieldval.

     refresh g_list[].
     CLEAR g_value.
     loop at IST_DIR INTO WA_DIR.
**    g_value-key = itab-zcrdno.
       g_value-key = WA_DIR-UNAME.
       concatenate WA_DIR-UNAME '-' WA_DIR-ENAME into g_value-text separated by space.

       append g_value to g_list.
       clear g_value.

     endloop.

     CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
         id              = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
         values          = g_list
       EXCEPTIONS
         id_illegal_name = 1
         OTHERS          = 2.
     IF sy-subrc <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     ENDIF.

   ENDIF.

 ENDFORM.                    " LOV_DIR
*&---------------------------------------------------------------------*
*&      Form  KEEP_IN_INBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM KEEP_IN_INBOX .
   data: APPR_STATUS TYPE ZMM_NMBLKCDHD-NM_STATUS. " for WF

   APPR_STATUS = 'KEEP'.
   EXPORT APPR_STATUS to MEMORY ID 'ID_NMSTT'. " exported to WF

   MESSAGE i225(zmm_oth). "Workitem sent back in the inbox.


 ENDFORM.                    " KEEP_IN_INBOX
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_ACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONFIRM_ACTION .
   data: question(400).


   CASE ok_code100.
     WHEN 'RELL3L4'.
       CONCATENATE  'Request will be released to L2 level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'RELL2'.
       CONCATENATE  'Request will be released to L1 level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'RELL1L2'.  " now L1
       CONCATENATE  'Request will be released to DI level.'
           '                                 Do you want to release?'
            into question respecting blanks.

     WHEN 'APPRDIR'.
       CONCATENATE  'Request for removal of Non-moving flag for materials will be approved.'
           '                                 Do you want to approve?'
            into question respecting blanks.

***

     WHEN 'REVL3L4'.
       CONCATENATE  'Request will be reverted back to the requisitioner.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVL2'.
       CONCATENATE  'Request will be reverted back to the L3/L4.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVL1L2'.       "Now L1
       CONCATENATE  'Request will be reverted back to the L2.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.

     WHEN 'REVDIR'.
       CONCATENATE  'Request will be reverted back to the L1.' 'Pls mentioned your query in the Note Sheet.'
           '                                 Please note that rejected items, if any, in this request will be rejected '
           'completely and can not be activated again.                                  Do you want to revert?'
            into question respecting blanks.
***


     WHEN 'REJL3L4' or 'REJL2' or 'REJL1L2' or  'REJDIR'..
       CONCATENATE  'Request will be rejected completely and can not be activated again.'
           '                                 Do you want to reject?'
           into question respecting blanks.

   ENDCASE.




   clear ANS_CONFIRM_ACTION.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
      TITLEBAR                    = 'Confirm action'
*   DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = question
      TEXT_BUTTON_1               = 'Yes'   "(001)
*   ICON_BUTTON_1               = ' '
      TEXT_BUTTON_2               = 'No'   " (002)
*   ICON_BUTTON_2               = ' '
*   DEFAULT_BUTTON              = '1'
      DISPLAY_CANCEL_BUTTON       = ''
*   USERDEFINED_F1_HELP         = ' '
      START_COLUMN                = 25
      START_ROW                   = 6
*   POPUP_TYPE                  =
*   IV_QUICKINFO_BUTTON_1       = ' '
*   IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER                      = ANS_CONFIRM_ACTION " '1' / '2'
* TABLES
*   PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .

 ENDFORM.                    " CONFIRM_ACTION


*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
* To send mail to PO creater
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_IMS_STATUS  IMS Status
*----------------------------------------------------------------------*
 form send_mail  using  P_REQNO type ZMM_NMBLKCDHD-REQNO
                        P_STATUS type ztxt10
                        p_rel_by TYPE sy-uname
                        p_mail_to type sy-uname
                        p_addl_text type ztxt100.

*perform send_mail using WA_ZMM_NMBLKCDHD-REQNO 'released' ID_INCHARGE ID_CREATOR 'for your kind approval'.


   data: L_REL_BY_ENAME type EMNAM.
   data: L_MAIL_SUBJ(50).
   data : w_object_hd  type sodocchgi1.
   data : ist_receiver type somlreci1  occurs 0  with header line.
   data : ist_message type solisti1 occurs 0 with header line.
   data : l_send_to_all(1).

*get emp name
   SELECT ENAME
 FROM PA0001 INTO L_REL_BY_ENAME UP TO 1 ROWS WHERE PERNR = P_REL_BY
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*Mail header
   w_object_hd-obj_name   = 'MAIL_NON_MOV'.
   w_object_hd-obj_langu  = sy-langu .
   w_object_hd-obj_prio   = '1'.
   w_object_hd-no_change  = 'X'.
   w_object_hd-priority   = '1'.
   CONCATENATE 'Non-moving material: Req no. ' P_REQNO INTO L_MAIL_SUBJ RESPECTING BLANKS. "separated by space.
   w_object_hd-OBJ_DESCR  = L_MAIL_SUBJ.

*Receivers
   ist_receiver-receiver = p_mail_to.
   ist_receiver-rec_type = 'B'. "'B' : SAP user name, 'U' : Internet address
   ist_receiver-express  = 'X'.
*  ist_receiver-COPY  = 'X'.  " CC
*  ist_receiver-BLIND_COPY = 'X'.  "BCC
   append ist_receiver.

* Mail  content

   clear  ist_message.
   append ist_message. "blank line

   clear  ist_message.
   ist_message = 'Dear Ma''am/Sir'.
   append ist_message.

   clear  ist_message.
   append ist_message.

   clear  ist_message.
*Request ### to unblock NON MOVING materials is released by user id ####/Name for your kind approval.
   concatenate 'Request no. ' P_REQNO 'to unblock NON MOVING materials has been ' P_STATUS
               'by Mr./Ms.' L_REL_BY_ENAME ', ID:' p_rel_by  p_addl_text '.'
               into ist_message separated by space.
   append ist_message.

   clear  ist_message.
   ist_message = 'This is an automatically generated e-mail. Please do not respond to this mail.'.
   append ist_message.

   clear  ist_message.
   ist_message = 'Kindly check work item in Inbox -> Workflow.'.
   append ist_message.


   CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
     EXPORTING
       document_data              = w_object_hd
       document_type              = 'RAW'
     IMPORTING
       sent_to_all                = l_send_to_all
     TABLES
       object_content             = ist_message
       receivers                  = ist_receiver
     EXCEPTIONS
       too_many_receivers         = 1
       document_not_sent          = 2
       document_type_not_exist    = 3
       operation_no_authorization = 4
       parameter_error            = 5
       x_error                    = 6
       enqueue_error              = 7.

   if l_send_to_all <> 'X'.
     message i226(zmm_oth) with p_mail_to.
   endif.


 endform.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_NMBLKCDHD_REQNO  text
*      -->P_4647   text
*      -->P_WA_ZMM_NMBLKCDHD_ID_INCHARGE  text
*      -->P_WA_ZMM_NMBLKCDHD_ID_CREATOR  text
*      -->P_4650   text
*----------------------------------------------------------------------*
 FORM SEND_SMS  USING   P_REQNO type ZMM_NMBLKCDHD-REQNO
                        P_STATUS type ztxt10
                        p_rel_by TYPE sy-uname
                        p_sms_to type sy-uname   "user ID
                        p_addl_text type ztxt100.

   data: mob_no(12),
         Msg(255).
   DATA: wf_string TYPE string ,
         result    TYPE string ,
         l_result(50).
   DATA: result_tab TYPE TABLE OF string.
   DATA: http_client TYPE REF TO if_http_client .
   data: L_REL_BY_ENAME type EMNAM.

   data: L_REQNO TYPE ZMM_NMBLKCDHD-REQNO.
   L_REQNO  = P_REQNO .
   SHIFT L_REQNO LEFT DELETING LEADING '0'.

   clear: mob_no, Msg, wf_string, result, l_result.
   refresh result_tab .

*get emp name
   SELECT ENAME
 FROM PA0001 INTO L_REL_BY_ENAME UP TO 1 ROWS WHERE PERNR = P_REL_BY
 ORDER BY PRIMARY KEY .
 ENDSELECT.

* get mob_no for user ID p_sms_to
   PERFORM get_emp_mobile using p_sms_to CHANGING mob_no.



   if mob_no is not INITIAL.
*msg
*Request ### to unblock NON MOVING materials is released by user id ####/Name / for your kind approval.
     concatenate 'Request no. ' L_REQNO 'to unblock NON MOVING materials' P_STATUS
                 'by Mr./Ms.' L_REL_BY_ENAME ',ID:' p_rel_by  p_addl_text '.'
                 into MSG separated by space.

     CONCATENATE 'http://10.205.48.190:13013/cgi-bin/sendsms?'
                 'username=ongc&password=ongc12&from=ONGC-OL&to=' MOB_NO
                 '&text=' msg
                 '&remLen=160'
         INTO wf_string .

     CALL METHOD cl_http_client=>create_by_url
       EXPORTING
         url                = wf_string
       IMPORTING
         client             = http_client
       EXCEPTIONS
         argument_not_found = 1
         plugin_not_active  = 2
         internal_error     = 3
         OTHERS             = 4.


     CALL METHOD http_client->send
       EXCEPTIONS
         http_communication_failure = 1
         http_invalid_state         = 2.

     CALL METHOD http_client->receive
       EXCEPTIONS
         http_communication_failure = 1
         http_invalid_state         = 2
         http_processing_failed     = 3.
     CLEAR result .
     result = http_client->response->get_cdata( ).




* for debugging
*      move result to l_result .
*      CONCATENATE 'Message from SMS gateway:' l_result+2 INTO l_result.
*      MESSAGE i206(zmm_oth) WITH l_result. "0: Accepted for delivery
*      REFRESH result_tab .
*      SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .

     CALL METHOD http_client->close( ).


   endif.  "/  mob_no is not INITIAL.

 ENDFORM.                    " SEND_SMS

 FORM GET_EMP_MOBILE using p_sms_to TYPE sy-uname
                     CHANGING mob_no TYPE zmob_no.

*employee's Mobile Number: to be fetched from PA9205
   DATA: max_begda type PA9205-BEGDA,
         l_zphone TYPE PA9205-ZPHONE.

   DATA: l_sms_to  TYPE pernr_d.

   if p_sms_to+0(3) = 'CAB' or p_sms_to+0(3) = 'CMM'.  "Coreteam members
     select single pernr from ZMM_CORETEAM
       into l_sms_to
         where uname = p_sms_to.
     if sy-subrc <> 0.
       message id 'ZMSG' type 'E' number '000' with 'USER ID' p_sms_to text-001 .
     endif.

   else.  " cpf user
     l_sms_to = p_sms_to.

   endif.

   select max( begda )
     from PA9205
       into max_begda
         where PERNR = l_sms_to  "pernr ~ user id
           and SUBTY = '01'
           and ENDDA = '99991231'.

   SELECT ZPHONE
 FROM PA9205 INTO L_ZPHONE UP TO 1 ROWS WHERE PERNR = L_SMS_TO AND SUBTY = '01' AND ENDDA => '99991231' AND BEGDA = MAX_BEGDA
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   SHIFT l_zphone LEFT DELETING LEADING '0'.
   if MOB_NO is NOT INITIAL.
     CONCATENATE '91' l_zphone INTO  MOB_NO.
   endif.

 ENDFORM.                    " GET_EMP_MOBILE
*&---------------------------------------------------------------------*
*&      Form  GET_DIRS_PA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_NMBLKCDHD_ID_DIRECTOR  text
*      <--P_L_ID_DIRS_PA  text
*----------------------------------------------------------------------*
 FORM GET_DIRS_PA  USING    P_ID_DIRECTOR type ZMM_NMBLKCDHD-ID_DIRECTOR
                   CHANGING P_ID_DIRS_PA type ZMMNM_DIR_PA-ID_PA.

   select single ID_PA
     from ZMMNM_DIR_PA
       INTO P_ID_DIRS_PA
         where ID_DIRECTOR = P_ID_DIRECTOR.

 ENDFORM.                    " GET_DIRS_PA
*&---------------------------------------------------------------------*
*&      Form  SHOW_PROCESS_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PROCESS_HELP .
   clear g_att_files_wa.
   g_att_files_wa-LOGSYS = 'MMNM_PG'.
   g_att_files_wa-objtype = 'ATT'.
   g_att_files_wa-objkey = '01'.


*   refresh exclude_tab[].
*   MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
*   MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.

   CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
     EXPORTING
       APPLICATION_OBJECT = g_att_files_wa
     TABLES
       FUNC_EXCLUDE       = EXCLUDE_TAB.

 ENDFORM.                    " SHOW_PROCESS_HELP
*&---------------------------------------------------------------------*
*&      Form  SHOW_NAME_CREATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_NAME_CREATOR .

   CLEAR NAME1.

   IF zmm_nmblkcdhd_st-ID_CREATOR IS NOT INITIAL.

*if zmm_nmblkcdhd_st-ID_CREATOR = 'CAB_ALOK'.
*   zmm_nmblkcdhd_st-ID_CREATOR = '77783'.
*endif.

     SELECT SINGLE ENAME FROM PA0001 INTO NAME1
       WHERE PERNR = zmm_nmblkcdhd_st-ID_CREATOR . "G_USER_PERNR.

*if zmm_nmblkcdhd_st-ID_CREATOR = '77783'.
*   zmm_nmblkcdhd_st-ID_CREATOR = 'CAB_ALOK'.
*endif.

   ENDIF.

 ENDFORM.                    " SHOW_NAME_CREATOR
*&---------------------------------------------------------------------*
*&      Form  SHOW_NAME_INCHARGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_NAME_INCHARGE .


   IF g_mode = 'DIS'.

     data: L_ENAME TYPE PA0001-ENAME.
     refresh g_list_inc.
     CLEAR g_value_inc.

     if ZMM_NMBLKCDHD_ST-ID_INCHARGE is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_INCHARGE
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_INCHARGE.
       concatenate ZMM_NMBLKCDHD_ST-ID_INCHARGE '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_INCHARGE'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


     if ZMM_NMBLKCDHD_ST-ID_L2 is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_L2
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_L2.
       concatenate ZMM_NMBLKCDHD_ST-ID_L2 '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_L2'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.

     if ZMM_NMBLKCDHD_ST-ID_L1 is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_L1
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_L1.
       concatenate ZMM_NMBLKCDHD_ST-ID_L1 '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_L1'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


     if ZMM_NMBLKCDHD_ST-ID_DIRECTOR is NOT INITIAL.

       clear L_ENAME.
       SELECT ENAME
 FROM PA0001 INTO L_ENAME UP TO 1 ROWS WHERE PERNR = ZMM_NMBLKCDHD_ST-ID_DIRECTOR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       g_value_inc-key = ZMM_NMBLKCDHD_ST-ID_DIRECTOR.
       concatenate ZMM_NMBLKCDHD_ST-ID_DIRECTOR '-' L_ENAME into g_value_inc-text separated by space.
       append g_value_inc to g_list_inc.
       clear g_value_inc.

       CALL FUNCTION 'VRM_SET_VALUES'
         EXPORTING
           id              = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
           values          = g_list_inc
         EXCEPTIONS
           id_illegal_name = 1
           OTHERS          = 2.
     endif.


   ENDIF.
 ENDFORM.                    " SHOW_NAME_INCHARGE
*&---------------------------------------------------------------------*
*&      Form  SHOW_PLANT_STK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PLANT_STK .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = zmm_NMBLKCDHD_st-werks.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_PLANT_STK
*&---------------------------------------------------------------------*
*&      Form  SHOW_ONGC_STK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_ONGC_STK .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = ''.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_ONGC_STK
*&---------------------------------------------------------------------*
*&      Form  SHOW_PLANT_CONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_PLANT_CONS .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks.

   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = zmm_NMBLKCDHD_st-werks.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MC.9' AND SKIP FIRST SCREEN.

 ENDFORM.                    " SHOW_PLANT_CONS
*&---------------------------------------------------------------------*
*&      Form  SHOW_ONGC_CONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SHOW_ONGC_CONS .
   DATA : l_matcode LIKE zmm_matblock_dt-matcode,
          l_werks   LIKE zmm_nmblkcdhd-werks,
          l_slv type SELVS.

*BREAK cab_alok.
   l_matcode = zmm_nmblkcddt-matcode.
   l_werks = ''.
   SET PARAMETER ID 'MAT' FIELD l_matcode.
   SET PARAMETER ID 'WRK' FIELD l_werks.
   CALL TRANSACTION 'MC.9' AND SKIP FIRST SCREEN.
 ENDFORM.                    " SHOW_ONGC_CONS
