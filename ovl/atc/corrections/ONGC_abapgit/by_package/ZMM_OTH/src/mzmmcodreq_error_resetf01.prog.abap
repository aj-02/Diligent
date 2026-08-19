************************************************************************
*  Date            Transport      USERID        Description
* 30/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
*
*
************************************************************************
***INCLUDE MZMMCODREQF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: l_ok     TYPE sy-ucomm,
         l_offset TYPE i.
   DATA l_110itab TYPE TABLE OF t_tabctrl110.
   DATA x(80).
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
* execute general and TC specific operations                           *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM check_tabrows.
       IF g_mode = 'CRE'.
         IF g_insrflg = 'Y'.
           PERFORM fcode_insert_row
            USING p_tc_name p_table_name.
           CLEAR p_ok.
         ENDIF.
       ELSE.
         PERFORM fcode_insert_row
          USING p_tc_name p_table_name.
         CLEAR: p_ok,l_ok,sy-ucomm.
       ENDIF.
     WHEN 'DELE'.                      "delete row
********Addition*****************************************
       CASE zmm_cdhd_st-mtart.
         WHEN 'ZSTO'.
           PERFORM add_delitem110.
         WHEN 'ZSPR'.
           PERFORM add_delitem120.
         WHEN 'ZCAP'.
           PERFORM add_delitem130.
         WHEN 'ZDIS'.
           PERFORM add_delitem140.
       ENDCASE.
********End**********************************************
       IF g_delflag <> 'N'.
*       message w052(zmm_oth).
         PERFORM confirm_deletion.
         IF g_confdel = 'J'.
           PERFORM fcode_delete_row USING    p_tc_name
                                            p_table_name
                                            p_mark_name.
           CLEAR g_confdel.
         ENDIF.
       ENDIF.
       CLEAR g_delflag.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
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
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

     WHEN 'FILTER'.
       READ  TABLE tabctrl110-cols WITH  KEY selected = 'X' INTO
           wa_tabctrl110_cols .
       IF sy-subrc <> 0.
         MESSAGE e030(zmm_oth).
       ENDIF.
       g_filname = wa_tabctrl110_cols-screen-name.
       CALL SCREEN 150 STARTING AT 20 05 ENDING AT 80 10.

*       concatenate g_filname '=' g_filval into X separated by space.
*Loop at g_tabctrl110_itab into g_tabctrl110_wa.
*   exit.
*Endloop.

*       read table g_tabctrl110_itab with table key (g_filname) =
*(g_filval).
*       delete g_tabctrl110_itab where (X).
*       append lines of g_tabctrl110_itab to l_110itab
*                    where (g_filname+11) = g_filval.
*       loop at g_tabctrl110_itab into g_tabctrl110_wa
*            where (g_filname+11) = g_filval.
*       endloop.
       CLEAR: p_ok,wa_tablctrl120_cols.

     WHEN 'SORTU'.
       g_order = 'ASCENDING'.
       CASE zmm_cdhd_st-mtart.
         WHEN 'ZSTO'.
           PERFORM sort_sto USING g_order.
           CLEAR: p_ok,wa_tabctrl110_cols.
         WHEN 'ZSPR'.
           PERFORM sort_spr USING g_order.
           CLEAR: p_ok,wa_tablctrl120_cols.
         WHEN 'ZCAP'.
           PERFORM sort_cap USING g_order.
           CLEAR: p_ok,wa_tablctrl130_cols.
         WHEN 'ZDIS'.
           PERFORM sort_dis USING g_order.
           CLEAR: p_ok,wa_tablctrl140_cols.
       ENDCASE.
     WHEN 'SORTD'.
       g_order = 'DESCENDING'.
       CASE zmm_cdhd_st-mtart.
         WHEN 'ZSTO'.
           PERFORM sort_sto USING g_order.
           CLEAR: p_ok,wa_tabctrl110_cols.
         WHEN 'ZSPR'.
           PERFORM sort_spr USING g_order.
           CLEAR: p_ok,wa_tablctrl120_cols.
         WHEN 'ZCAP'.
           PERFORM sort_cap USING g_order.
           CLEAR: p_ok,wa_tablctrl130_cols.
         WHEN 'ZDIS'.
           PERFORM sort_dis USING g_order.
           CLEAR: p_ok,wa_tablctrl140_cols.
       ENDCASE.
   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: l_itab110 LIKE g_tabctrl110_wa OCCURS 0,
         l_itab120 LIKE g_tablctrl120_wa OCCURS 0,
         l_itab130 LIKE g_tablctrl130_wa OCCURS 0,
         l_itab140 LIKE g_tablctrl140_wa OCCURS 0.

   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>  TYPE i.                           "#EC *

**-END OF LOCAL
*DATA----------------------------------------------------*
**********************************************************************
*   ASSIGN (P_TC_NAME) TO <TC>.
*
** get the table, which belongs to the tc
**
*   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
*   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
*
** get looplines of TableControl
*   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
*   ASSIGN (L_LINES_NAME) TO <LINES>.
*
** get current line
*   GET CURSOR LINE L_SELLINE.
*   if sy-subrc <> 0.                   " append line to table
*     l_selline = <tc>-lines + 1.
**&SPWIZARD: set top line and new cursor line
**
*     if l_selline > <lines>.
*       <tc>-top_line = l_selline - <lines> + 1 .
*       L_LINE = 1.
*     else.
*       <tc>-top_line = 1.
*       L_LINE = L_SELLINE.
*     endif.
*   else.                               " insert line into table
*     l_selline = <tc>-top_line + l_selline - 1.
*     l_lastline = <tc>-top_line + <lines> - 1.
*     IF L_LASTLINE <= <TC>-LINES.
*       <TC>-TOP_LINE = L_SELLINE.
*       L_LINE = 1.
*     ELSEIF <LINES> > <TC>-LINES.
*       <TC>-TOP_LINE = 1.
*       L_LINE = L_SELLINE.
*     ELSE.
*       <TC>-TOP_LINE = <TC>-LINES - <LINES> + 2 .
*       L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
*     ENDIF.
*   endif.
**&SPWIZARD: set new cursor line
**
**   l_line = l_selline - <tc>-top_line + 1.
** insert initial line
*   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
*   <TC>-LINES = <TC>-LINES + 1.
** set cursor
*   SET CURSOR LINE L_LINE.
********************************************************
********change/addition**********************************
   CLEAR l_selline.
   REFRESH:l_itab110,l_itab120,l_itab130,l_itab140.
   ASSIGN (p_tc_name) TO <tc>.
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.
*Case zmm_cdhd_st-mtart.
* When 'ZSTO'.
*   Append lines of g_tabctrl110_itab to l_itab110.
*   Delete l_itab110 where srno = 0.
*   describe table l_itab110 lines l_selline.
* When 'ZSPR'.
*   Append lines of g_tablctrl120_itab to l_itab120.
*   Delete l_itab120 where srno = 0..
*   describe table l_itab120 lines l_selline.
* When 'ZCAP'.
*   Append lines of g_tablctrl130_itab to l_itab130.
*   Delete l_itab130 where srno = 0..
*   describe table l_itab130 lines l_selline.
*Endcase.
*l_selline = l_selline + 1.
*INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
   APPEND INITIAL LINE TO <table>.
   <tc>-lines = <tc>-lines + 1.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* delete marked lines                                                  *
   DESCRIBE TABLE <table> LINES <tc>-lines.

   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
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
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
   DATA l_tc_itab_name        LIKE feld-name.
   DATA l_totln               TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
* get looplines of TableControl
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


* is no line filled?                                                   *
   IF <tc>-lines = 0.
*   yes, ...                                                           *
     l_tc_new_top_line = 1.
   ELSE.
*   no, ...
****Addition
     CASE zmm_cdhd_st-mtart.
       WHEN 'ZSTO'.
         DESCRIBE TABLE g_tabctrl110_itab LINES l_totln.
       WHEN 'ZSPR'.
         DESCRIBE TABLE g_tablctrl120_itab LINES l_totln.
       WHEN 'ZCAP'.
         DESCRIBE TABLE g_tablctrl130_itab LINES l_totln.
       WHEN 'ZDIS'.
         DESCRIBE TABLE g_tablctrl140_itab LINES l_totln.
     ENDCASE.
****End
     IF <tc> = tabctrl100.
       CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
           entry_act      = <tc>-top_line
           entry_from     = 1
           entry_to       = <tc>-lines
*          ENTRY_TO       = l_totln
*          LAST_PAGE_FULL = ''
           last_page_full = 'X'
           loops          = <lines>
           ok_code        = p_ok
           overlapping    = 'X'
         IMPORTING
           entry_new      = l_tc_new_top_line
         EXCEPTIONS
*          NO_ENTRY_OR_PAGE_ACT  = 01
*          NO_ENTRY_TO    = 02
*          NO_OK_CODE_OR_PAGE_GO = 03
           OTHERS         = 0.
     ELSE.
       CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
           entry_act      = <tc>-top_line
           entry_from     = 1
*          ENTRY_TO       = <TC>-LINES
           entry_to       = l_totln
           last_page_full = ''
*          LAST_PAGE_FULL = 'X'
           loops          = <lines>
           ok_code        = p_ok
           overlapping    = 'X'
         IMPORTING
           entry_new      = l_tc_new_top_line
         EXCEPTIONS
*          NO_ENTRY_OR_PAGE_ACT  = 01
*          NO_ENTRY_TO    = 02
*          NO_OK_CODE_OR_PAGE_GO = 03
           OTHERS         = 0.
     ENDIF.
   ENDIF.

* get actual tc and column                                             *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*     set actual column                                                *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

* set the new top line                                                 *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
   LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
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
 FORM fill_sttab.
   REFRESH it_tab1.

   IF dynnr IS INITIAL.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.


   IF g_mode =  'CRE'.
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
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'CHA' .
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     IF dynnr = '0101'.
       MOVE 'CR_MATCODE' TO wa_tab-fcode.
       APPEND wa_tab TO it_tab1.

       MOVE 'CHECK' TO wa_tab-fcode.
       APPEND wa_tab TO it_tab1.
     ENDIF.

   ELSEIF g_mode = 'DEL'.
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
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'DIS'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'REL'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ELSEIF g_mode = 'APR'.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.

   ENDIF.

   IF sy-tcode = 'ZCODG'.
     CLEAR wa_tab.
     REFRESH it_tab1.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DISPLAY' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.

   IF sy-tcode = 'ZMATRESERR'.
     CLEAR wa_tab.
     REFRESH it_tab1.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE_E' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.


   IF sy-tcode = 'ZMATRESERR' AND NOT sy-dynnr IS INITIAL AND NOT
                                      zmm_cdhd_st-reqno IS INITIAL.
     CLEAR wa_tab.
     REFRESH it_tab1.
     MOVE 'CREATE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHANGE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'DELETE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'APPROVE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'RELEASE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
     MOVE 'CHECK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
*     move 'CHANGE_E' to wa_tab-fcode.
*     append wa_tab to it_tab1.
     MOVE 'CR_MATCODE' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ENDIF.

 ENDFORM.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  fill_mattyp_itemdt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM fill_mattyp_itemdt.

   DATA l_cdhd LIKE zmm_cdhd.

   IF g_mode = 'CRE'.
     PERFORM set_dynnr USING zmm_cdhd_st-mtart.
   ELSE.
     SELECT SINGLE * INTO l_cdhd FROM zmm_cdhd
            WHERE reqno = zmm_cdhd_st-reqno.
     IF sy-subrc = 0.
       PERFORM set_dynnr USING l_cdhd-mtart.
     ELSE.
*       message e003(zmm_oth) with zmm_cdhd_st-reqno.
     ENDIF.
*
     IF l_cdhd-mtart = 'ZSTO'.
       SELECT SINGLE * FROM zmm_cditem
         INTO CORRESPONDING FIELDS OF zmm_cditem
          WHERE reqno = zmm_cdhd_st-reqno
          AND   oth1  = 'X'.
       IF sy-subrc = 0.
         g_techapr_visible = 'Y'.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " fill_mattyp_itemdt
*&---------------------------------------------------------------------*
*&      Form  chng_attr_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM chng_attr_100.
   IF g_mode = 'CRE'.
     LOOP AT SCREEN.
       IF screen-name = 'ZMM_CDHD_ST-REQNO'.
         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " chng_attr_100
*&---------------------------------------------------------------------*
*&      Form  SELECT_HELP_DATA
*&---------------------------------------------------------------------*
 FORM select_mat_data USING
                      partno LIKE zmm_cditem-user_desc
                      matgp LIKE zmm_modifier-matgrp
                      mtart LIKE mara-mtart
                      CHANGING sel_flag.

   DATA : l_lines LIKE sy-index.
   DATA : l_srno  LIKE sy-index.
   DATA : l_len   LIKE sy-index.
   DATA : l_len1  LIKE sy-index.
   DATA : l_len2  LIKE sy-index.
   DATA : l_check.
   DATA : g_partno1 LIKE zmm_cditem-user_desc.
   DATA : g_partno2 LIKE zmm_cditem-user_desc.

   DATA : g_capcode_no   LIKE ausp-atinn.
   DATA : g_modelcode_no LIKE ausp-atinn.

   DESCRIBE TABLE ist_srchlp LINES l_lines.

   IF g_lineno <> g_curr_line.
     l_lines = 0.
   ENDIF.

   TRANSLATE desc TO UPPER CASE.

   IF mtart = 'ZSPR'  .

     IF  l_lines = 0  OR field1 = 'ZMM_CDITEM-PARTNO'.

       SELECT a~maktg a~matnr b~mfrnr b~meins b~mfrpn b~wrkst
       INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
       FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
       WHERE b~mfrpn LIKE partno AND
       ( b~mtart = mtart OR b~mtart = 'ZMPN' ). "Anil Gupta 17-06-05

       IF sy-subrc = 0.
* Added by cab_uniyal to get capital code and model no in
* spares running search help
         SELECT atinn FROM cabn INTO g_capcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CAPCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         IF sy-subrc <> 0.
           g_capcode_no = ''.
         ENDIF.
         SELECT atinn FROM cabn INTO g_modelcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MODELCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         IF sy-subrc <> 0.
           g_modelcode_no = ''.
         ENDIF.

         LOOP AT ist_srchlp INTO wa_srchlp.
           IF g_capcode_no <> ''.
             SELECT atwrt FROM ausp INTO wa_srchlp-atwrt UP TO 1 ROWS
 WHERE objek = wa_srchlp-matnr AND atinn = g_capcode_no
 ORDER BY PRIMARY KEY .
             ENDSELECT.

             MODIFY  ist_srchlp FROM wa_srchlp INDEX sy-tabix
             TRANSPORTING atwrt.
           ENDIF.
           IF g_modelcode_no <> ''.
             SELECT atwrt FROM ausp INTO wa_srchlp-mdlno UP TO 1 ROWS
 WHERE objek = wa_srchlp-matnr AND atinn = g_modelcode_no
 ORDER BY PRIMARY KEY .
             ENDSELECT.

             MODIFY ist_srchlp FROM wa_srchlp INDEX sy-tabix
             TRANSPORTING mdlno.
           ENDIF.
         ENDLOOP.

       ENDIF.  "For sy-subrc = 0.


     ELSEIF field1 = 'ZMM_CDITEM-DESC1'.

       SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
       INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
       FROM makt AS a
       JOIN mara AS b
       ON a~matnr = b~matnr
       WHERE a~maktg LIKE desc
       AND   b~mtart = mtart
       AND   b~mfrpn LIKE partno
**Addition***********************************************
       AND b~mstae = ''.
**End****************************************************
       IF sy-subrc = 0.
*       sel_flag = '0'.
       ENDIF.
     ENDIF.
*      if check_flag2 <> 'X'.
     PERFORM change_partno1 CHANGING g_partno1 g_partnoc.
     l_len1 = strlen( g_partno1 ).
     LOOP AT ist_srchlp INTO wa_srchlp.
       PERFORM change_partno2 CHANGING g_partno2 wa_srchlp-mfrpn.
       l_len2 = strlen( g_partno2 ).
       SEARCH g_partno2 FOR g_partno1.
       IF sy-subrc = 0 AND l_len1 = l_len2.
       ELSE.
         DELETE ist_srchlp.
       ENDIF.
     ENDLOOP.
   ENDIF.                " For matty = ZSPR

   IF mtart = 'ZSTO'.

     IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
                      OR sel_flag = '5'.
*       if not matgp is initial.
*         select a~MAKTG a~MATNR b~meins b~mfrpn b~wrkst
*         into corresponding fields of table ist_srchlp
*         from makt as A join mara as B on a~matnr = b~matnr
*        where a~maktg like desc and b~mtart = mtart and b~matkl = matgp
*.
*       else.
       SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
       INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
       FROM makt AS a
       JOIN mara AS b
       ON a~matnr = b~matnr
       WHERE ( a~maktg LIKE desc OR b~wrkst <> '' )
             AND b~mtart = mtart
**Addition***********************************************
             AND b~mstae = ''.
**End****************************************************
*       endif.
     ENDIF.

     IF sy-subrc = 0.

       sel_flag = '1'.

     ENDIF.

   ENDIF.


   IF mtart = 'ZCAP'.

     IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
                      OR sel_flag = '5'.
       SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
       INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
       FROM makt AS a
       JOIN mara AS b
       ON a~matnr = b~matnr
       WHERE ( a~maktg LIKE desc OR b~wrkst <> '' )
       AND b~mtart = mtart
**Addition***********************************************
       AND b~mstae = ''.
**End****************************************************

     ENDIF.

     IF sy-subrc = 0.

       sel_flag = '1'.

     ENDIF.

   ENDIF.

   IF mtart = 'ZDIS'.

     IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
                      OR sel_flag = '5'.
       SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
       INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
       FROM makt AS a
       JOIN mara AS b
       ON a~matnr = b~matnr
       WHERE ( a~maktg LIKE desc OR b~wrkst LIKE desc )
       AND b~mtart = mtart
**Addition***********************************************
       AND b~mstae = ''.
**End****************************************************

     ENDIF.

     IF sy-subrc = 0.

       sel_flag = '1'.

     ENDIF.

   ENDIF.

   LOOP AT ist_srchlp INTO wa_srchlp.

*   l_srno = l_srno + 1.
*
*   wa_srchlp-srno = l_srno.

     l_len = strlen( wa_srchlp-maktg ).

*    concatenate wa_srchlp-maktg+0(39) wa_srchlp-wrkst into
*                wa_srchlp-maktx.
     l_len = l_len - 1.
     l_check = wa_srchlp-maktg+l_len(1).
     IF l_check = '*'.
       CONCATENATE wa_srchlp-maktg+0(l_len) wa_srchlp-wrkst INTO
       wa_srchlp-maktx.
     ELSE.
       MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
     ENDIF.

     TRANSLATE wa_srchlp-maktx TO UPPER CASE.

     IF NOT desc11 IS INITIAL.

       SEARCH wa_srchlp-maktx FOR desc11.

       IF sy-subrc = 0.

         l_srno = l_srno + 1.

         wa_srchlp-srno = l_srno.

         MODIFY ist_srchlp FROM wa_srchlp.

       ELSE.

         DELETE ist_srchlp.

       ENDIF.

     ELSE.

       l_srno = l_srno + 1.

       wa_srchlp-srno = l_srno.

       MODIFY ist_srchlp FROM wa_srchlp.

     ENDIF.

   ENDLOOP.

 ENDFORM.

***********************************
* Form SELECT_HELP_DATA
***********************************

 FORM select_help_data USING VALUE(partno) LIKE zmm_cditem-user_desc
                             VALUE(desc1) LIKE zmm_cditem-desc1
                             VALUE(desc2) LIKE zmm_cditem-desc2
                             VALUE(desc3) LIKE zmm_cditem-desc3
                             VALUE(desc4) LIKE zmm_cditem-desc4
                             VALUE(desc5) LIKE zmm_cditem-user_desc
                             VALUE(matgp) LIKE zmm_modifier-matgrp
                             VALUE(matty) LIKE zmm_cdhd_st-mtart
                             CHANGING sel_flag.


   DATA : l_srno TYPE i.

   IF NOT desc1 IS INITIAL OR NOT partno IS INITIAL.
     CONCATENATE '%' desc1 '%' INTO desc.
     PERFORM select_mat_data USING partno matgp matty CHANGING sel_flag.
     CLEAR : wa_srchlp.
   ENDIF.

   CLEAR l_srno.
   IF NOT desc2 IS INITIAL.

     LOOP AT ist_srchlp INTO wa_srchlp.

       TRANSLATE desc2 TO UPPER CASE.

       SEARCH wa_srchlp-maktx FOR desc2.

       IF sy-subrc <> 0.
         DELETE ist_srchlp .
       ELSE.
         l_srno = l_srno + 1.
         wa_srchlp-srno = l_srno.
         MODIFY ist_srchlp FROM wa_srchlp.
       ENDIF.

     ENDLOOP.

     sel_flag = '2'.

   ENDIF.

   CLEAR l_srno.

   IF NOT desc3 IS INITIAL.

     LOOP AT ist_srchlp INTO wa_srchlp.

       TRANSLATE desc3 TO UPPER CASE.

       SEARCH wa_srchlp-maktx FOR desc3.

       IF sy-subrc <> 0.
         DELETE ist_srchlp .
       ELSE.
         l_srno = l_srno + 1.
         wa_srchlp-srno = l_srno.
         MODIFY ist_srchlp FROM wa_srchlp.

       ENDIF.

     ENDLOOP.

     sel_flag = '3'.

   ENDIF.

   CLEAR l_srno.

   IF NOT desc4 IS INITIAL.

     LOOP AT ist_srchlp INTO wa_srchlp.

       TRANSLATE desc4 TO UPPER CASE.

       SEARCH wa_srchlp-maktx FOR desc4.

       IF sy-subrc <> 0.
         DELETE ist_srchlp .
       ELSE.
         l_srno = l_srno + 1.
         wa_srchlp-srno = l_srno.
         MODIFY ist_srchlp FROM wa_srchlp.

       ENDIF.

     ENDLOOP.

     sel_flag = '4'.

   ENDIF.

   CLEAR l_srno.

   IF NOT desc5 IS INITIAL.

     LOOP AT ist_srchlp INTO wa_srchlp.

       TRANSLATE desc5 TO UPPER CASE.

       SEARCH wa_srchlp-maktx FOR desc5.

       IF sy-subrc <> 0.
         DELETE ist_srchlp .
       ELSE.
         l_srno = l_srno + 1.
         wa_srchlp-srno = l_srno.
         MODIFY ist_srchlp FROM wa_srchlp.

       ENDIF.

     ENDLOOP.

     sel_flag = '5'.

   ENDIF.


 ENDFORM.                    " SELECT_HELP_DATA
*&---------------------------------------------------------------------*
*&      Form  Gen_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM Save_request.
   PERFORM check_other.
   IF g_mode = 'CRE'.
     PERFORM gen_request.
     CASE  zmm_cdhd_st-mtart.
       WHEN 'ZSTO'.
         l_MATTYPE = 'S'.
       WHEN 'ZSPR'.
         l_MATTYPE = 'P'.
       WHEN 'ZCAP'.
         l_MATTYPE = 'C'.
       WHEN 'ZDIS'.
         l_MATTYPE = 'D'.
     ENDCASE.
*
     zmm_cdhd_st-reqno = g_reqno.
     g_request_no = g_reqno.
     PERFORM Insert_into_tab.
     MESSAGE i005(zmm_oth) WITH g_request_no.
   ELSEIF g_mode = 'CHA' OR g_mode = 'CHE'.     "OR  g_mode = 'APR'.
     g_request_no = zmm_cdhd_st-reqno.
     PERFORM prepare_update."on commit.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     IF g_lock = 'Y'.
       PERFORM unlock_req.
       CLEAR g_lock.
     ENDIF.
     PERFORM clear_var.
   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
   ELSEIF g_mode = 'REL'.
     IF zmm_cdhd_st-status_flag = ''.
       MESSAGE i024(zmm_oth) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
     ENDIF.

*    Perform update_release.
   ELSEIF g_mode = 'APR'.
**Note - Status flag is not pertaining to Request status, for that
**purpose flag is Reqcl ( Request Status ).
     IF zmm_cdhd_st-status_flag = ''.
       MESSAGE i026(zmm_oth).
       LEAVE TO SCREEN 0.
     ELSEIF zmm_cdhd_st-approve_mrp = ''.
       MESSAGE i024(zmm_oth) WITH 'APPROVAL MRP CTRL'.
     ELSEIF g_user = 'M'.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
     ELSEIF zmm_cdhd_st-approve_L2 = '' AND g_user = 'L'.
       MESSAGE i024(zmm_oth) WITH 'L2 APPROVAL'.
     ELSEIF zmm_cdhd_st-approve_L2 = 'X' AND g_user = 'L'.
       PERFORM update_approval.
     ENDIF.
   ELSEIF g_mode = 'CRC'.
     g_request_no = zmm_cdhd_st-reqno.
     PERFORM update_codes.
     COMMIT WORK.
     IF zmm_cdhd_st-reqcl <> 'C'.
       PERFORM check_reqstatus.
     ENDIF.
     MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
     MODIFY zmm_cdhd FROM zmm_cdhd.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     PERFORM send_mail_to_reqn.
   ENDIF.
***********end**************************************
   IF sy-tcode = 'ZCODG'.
     IF g_mode = ''.
       IF zmm_cdhd_st-reqcl <> 'C'.
         PERFORM check_reqstatus.
       ENDIF.
       MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
       MODIFY zmm_cdhd FROM zmm_cdhd.
************************************************************
****Saving the long text.                              *****
************************************************************
******Header(Correspondence)********************************
       PERFORM prepare_update.
       COMMIT WORK.
       PERFORM send_mail_to_reqn.
       MESSAGE i006(zmm_oth) WITH g_request_no.
     ENDIF.
   ENDIF.
 ENDFORM.                    " Gen_request
*&---------------------------------------------------------------------*
*&      Form  gen_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM gen_request.

   CALL FUNCTION 'NUMBER_GET_NEXT'
     EXPORTING
       nr_range_nr = '01'
       object      = 'ZMMCODREQ'
     IMPORTING
       number      = g_reqno.
   IF sy-subrc <> 0.
   ENDIF.

 ENDFORM.                    " gen_request
*&---------------------------------------------------------------------*
*&      Form  Insert_into_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM Insert_into_tab.
   IF g_mode = 'CRE'.
     MOVE sy-datum TO zmm_cdhd_st-reqdate.
     MOVE sy-uname TO zmm_cdhd_st-reqcpf.
     MOVE 'N' TO zmm_cdhd_st-reqcl.
     MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
     INSERT INTO zmm_cdhd VALUES zmm_cdhd.
     IF sy-subrc = 0.
       MESSAGE i001(zmm_oth) WITH zmm_cdhd-reqno.
     ENDIF.
   ELSEIF g_mode = 'CHA'.
     IF matgen_flag = 'X'.
       MOVE matgen_flag TO zmm_cdhd_st-matgen_flag.
       MOVE sy-datum TO zmm_cdhd_st-MATGEN_date.
     ENDIF.
     MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
     MODIFY zmm_cdhd FROM zmm_cdhd.
   ENDIF.
**
   REFRESH ist_zmm_cditem.
   CASE L_mattype.
     WHEN 'S'.
       LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
         IF NOT g_TABCTRL110_wa-desc_fin IS INITIAL.

           IF sy-tcode = 'ZMATRESERR' AND g_TABCTRL110_wa-comp_flg = 'E'.
             g_TABCTRL110_wa-comp_flg = ''.
           ENDIF.

           MOVE-CORRESPONDING g_TABCTRL110_wa TO wa_zmm_cditem.
           MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
           MOVE sy-datum TO wa_zmm_cditem-coddt.
           MOVE sy-uname TO wa_zmm_cditem-codby.
           MOVE g_TABCTRL110_wa-matgp TO wa_zmm_cditem-matgp.
           APPEND wa_zmm_cditem TO ist_zmm_cditem.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'P'.
       LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
         IF NOT g_TABLCTRL120_wa-desc_fin IS INITIAL.
           IF sy-tcode = 'ZMATRESERR' AND g_TABLCTRL120_wa-comp_flg = 'E'.
             g_TABLCTRL120_wa-comp_flg = ''.
           ENDIF.
           MOVE-CORRESPONDING g_TABLCTRL120_wa TO wa_zmm_cditem.
           MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
           MOVE sy-datum TO wa_zmm_cditem-coddt.
           MOVE sy-uname TO wa_zmm_cditem-codby.
           MOVE g_TABLCTRL120_wa-matgp TO wa_zmm_cditem-matgp.
           APPEND wa_zmm_cditem TO ist_zmm_cditem.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'C'.
       LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
         IF NOT g_TABLCTRL130_wa-desc_fin IS INITIAL.
           IF sy-tcode = 'ZMATRESERR' AND g_TABLCTRL130_wa-comp_flg = 'E'.
             g_TABLCTRL130_wa-comp_flg = ''.
           ENDIF.

           MOVE-CORRESPONDING g_TABLCTRL130_wa TO wa_zmm_cditem.
           MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
           MOVE sy-datum TO wa_zmm_cditem-coddt.
           MOVE sy-uname TO wa_zmm_cditem-codby.
*           move g_TABLCTRL130_wa-matgp to wa_zmm_cditem-matgp.
           APPEND wa_zmm_cditem TO ist_zmm_cditem.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'D'.
       LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
         IF NOT g_TABLCTRL140_wa-desc_fin IS INITIAL.
           MOVE-CORRESPONDING g_TABLCTRL140_wa TO wa_zmm_cditem.
           MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
           MOVE sy-datum TO wa_zmm_cditem-coddt.
           MOVE sy-uname TO wa_zmm_cditem-codby.
*           move g_TABLCTRL140_wa-matgp to wa_zmm_cditem-matgp.
           APPEND wa_zmm_cditem TO ist_zmm_cditem.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
   ENDCASE.

*   Insert ZMM_CDITEM from table ist_zmm_cditem.
************************************************************
****Saving the long text.                              *****
************************************************************
******Header(Correspondence)********************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'APR' ) OR ( g_mode = 'MRP' ) OR
        sy-tcode = 'ZCODG'.
     PERFORM save_cors_text.
   ENDIF.
******Items*************************************************
   IF g_mode = 'CRE'.
     DELETE ADJACENT DUPLICATES FROM ist_textid_items.
     LOOP AT ist_textid_items INTO wa_textid.
       REFRESH : ist_dtspecs.
       PERFORM read_text_data TABLES ist_dtspecs USING wa_textid.
       CONCATENATE 'CDDS'
                    zmm_cdhd_st-reqno
                    wa_textid-tdname+14(3)
              INTO  wa_textid-tdname.
       PERFORM save_text.
     ENDLOOP.
     CLEAR wa_textid.
*****Delete temporarily saved long text
     LOOP AT ist_textid_items INTO wa_textid.
       SELECT SINGLE * INTO g_stxl FROM stxl
                  WHERE tdobject = wa_textid-tdobject
                   AND  tdid     = wa_textid-tdid
                   AND  tdname   = wa_textid-tdname.
       IF sy-subrc = 0.
         PERFORM delete_text.
       ENDIF.
     ENDLOOP.
     REFRESH ist_textid_items.
   ENDIF.
*************End of Long Text Save************************************
   PERFORM clear_var.

 ENDFORM.                    " Insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM clear_var.
   IF NOT gv_text_editor1 IS INITIAL.
     PERFORM destroy_ctrl.
   ENDIF.
   CLEAR zmm_cdhd_st.

   REFRESH g_tabctrl110_itab.
   REFRESH CONTROL 'TABCTRL110' FROM SCREEN '0110'.

   REFRESH g_tablctrl120_itab.
   REFRESH CONTROL 'TABLCTRL120' FROM SCREEN '0120'.

   REFRESH g_tablctrl130_itab.
   REFRESH CONTROL 'TABLCTRL130' FROM SCREEN '0130'.

   REFRESH g_tablctrl140_itab.
   REFRESH CONTROL 'TABLCTRL140' FROM SCREEN '0140'.


   CLEAR: zmm_cdhd_st-reqcpf, zmm_cdhd_st-reqdate, zmm_cdhd_st-appcpf,
          zmm_cdhd_st-appdate, zmm_cdhd_st-addr1, zmm_cdhd_st-addr2,
          zmm_cdhd_st-addr3,zmm_cdhd_st-reqloc,
          g_TABCTRL110_wa, g_TABLCTRL120_wa, g_TABLCTRL130_wa,
          g_TABLCTRL140_wa,g_lineno,g_mode,g_hd_copied,
          l_mattype,g_saveflag,g_check_flag,g_techapr_visible.
   CLEAR  g_cors.
   REFRESH: ist_srchlp,tlinetab1,tlinetab2,lines_cors.
   REFRESH:lt_text_table1,lt_text_table2.

*   free object GV_CUSTOM_CONTAINER .
*   free object GV_SPLITTER2.
*   free object gv_text_editor1.
*   free object gv_text_editor2.
*
*   clear:GV_SPLITTER1,GV_SPLITTER2,gv_text_editor1,gv_text_editor2.
*****************
*   CALL FUNCTION 'CONTROL_DESTROY'
**    EXPORTING
**       NO_FLUSH                  = 'X'
*     CHANGING
*       H_CONTROL               = 'C_WRT'
*    EXCEPTIONS
*      CNTL_SYSTEM_ERROR       = 1
*      CNTL_ERROR              = 2
*      OTHERS                  = 3
*             .
*   IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*   ENDIF.
*****Assigning constants and status*****************************
   dynnr = ''.
   REFRESH it_tab1.
   g_TABCTRL110_copied = ''.
   g_TABLCTRL120_copied = ''.
   g_TABLCTRL130_copied = ''.
   g_TABLCTRL140_copied = ''.

******
 ENDFORM.                    " clear_var

*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_desc1_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM TABCTRL110_desc1_check .

   IF NOT g_TABCTRL110_wa-matgp IS INITIAL AND
         TABCTRL110_check_flag <> 'X'.
*
     matgrp_change_flag = 'X'.
     matgrp_orig = g_TABCTRL110_wa-matgp.
   ENDIF.

   SELECT * FROM zmm_modifier INTO TABLE ist_modifier_check_list
             WHERE desc1 = zmm_cditem-desc1 .
*   and matgrp = g_TABCTRL110_wa-matgp.
   IF sy-subrc = 0.
     SORT ist_modifier_check_list BY
                     desc1 matgrp.
     DELETE ADJACENT DUPLICATES FROM ist_modifier_check_list COMPARING
                     desc1 matgrp.
     LOOP AT ist_modifier_check_list INTO wa_modifier_check_list.

       IF      wa_modifier_check_list-matgrp = '01'
            OR wa_modifier_check_list-matgrp = '02'
            OR wa_modifier_check_list-matgrp = '03'
            OR wa_modifier_check_list-matgrp = '04'
            OR wa_modifier_check_list-matgrp = '05'
            OR wa_modifier_check_list-matgrp = '06'
            OR wa_modifier_check_list-matgrp = '07'
            OR wa_modifier_check_list-matgrp = '08'
            OR wa_modifier_check_list-matgrp = '09'
            OR wa_modifier_check_list-matgrp = '10'
            OR wa_modifier_check_list-matgrp = '11'
            OR wa_modifier_check_list-matgrp = '12'
            OR wa_modifier_check_list-matgrp = '13'
            OR wa_modifier_check_list-matgrp = '14'
            OR wa_modifier_check_list-matgrp = '15'
            OR wa_modifier_check_list-matgrp = '16'
            OR wa_modifier_check_list-matgrp = 'XX'.
       ELSE.
         DELETE ist_modifier_check_list.
       ENDIF.

     ENDLOOP.

     DESCRIBE TABLE ist_modifier_check_list LINES check_list_lines.

     IF check_list_lines > 1 AND TABCTRL110_check_flag ='X'.
*     g_matgp_selected ne 'X'.
       CALL SCREEN 104 STARTING AT 40 2
                       ENDING   AT 80 18.
       g_matgp_selected = 'X'.
       CLEAR check_list_lines.
     ELSE.
       READ TABLE ist_modifier_check_list               "#EC CI_NOORDER
       INTO wa_modifier_check_list INDEX 1.
     ENDIF.

     IF matgrp_change_flag = 'X'.
       CLEAR g_matgp_selected.
       zmm_cditem-matgp = matgrp_orig.
       g_TABCTRL110_wa-matgp = matgrp_orig.
       CLEAR : matgrp_orig, matgrp_change_flag.
     ELSE.
       zmm_cditem-matgp = wa_modifier_check_list-matgrp.
       g_TABCTRL110_wa-matgp = wa_modifier_check_list-matgrp.
     ENDIF.

*     if check_list_lines > 1.
*       message i025(zmm_oth) with zmm_cditem-matgp.
*     endif.
*+090505 ---------------------------------------------------
* This is being commented because in change mode
* if Other is chosen from F4 at 1st level and data are entered
* then 'X' vanishes from OTH1 field.
*     clear g_TABCTRL110_wa-oth1.
*-090505 ---------------------------------------------------
     CLEAR zmm_cditem-oth1.
     CLEAR check_list_lines.
   ELSE.
     IF zmm_cditem-oth1 <> 'X'.
*       g_parno = 1.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                 " TABCTRL110_desc1_check

*---------------------------------------------------------------------*
*       FORM TABCTRL110_desc2_check                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABCTRL110_desc2_check .

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
                                           desc2 = zmm_cditem-desc2 .

   IF sy-subrc = 0.
     CLEAR g_TABCTRL110_wa-oth2.
     CLEAR zmm_cditem-oth2.
   ELSE.
     IF zmm_cditem-oth2 <> 'X'.
       g_parno = 2.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                 " TABCTRL110_desc2_check
*&---------------------------------------------------------------------*
*&      Form  TABCTRL110_desc3_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TABCTRL110_desc3_check.

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
                                           desc2 = zmm_cditem-desc2 AND
                                           desc3 = zmm_cditem-desc3 .

   IF sy-subrc = 0.
     CLEAR g_TABCTRL110_wa-oth3.
     CLEAR zmm_cditem-oth3.
   ELSE.
     IF zmm_cditem-oth3 <> 'X'.
       g_parno = 3.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABCTRL110_desc3_check
*---------------------------------------------------------------------*
*       FORM TABCTRL110_desc4_check                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABCTRL110_desc4_check.

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
                                           desc2 = zmm_cditem-desc2 AND
                                           desc3 = zmm_cditem-desc3 AND
                                           desc4 = zmm_cditem-desc4 .
   IF sy-subrc = 0.
     CLEAR g_TABCTRL110_wa-oth4.
     CLEAR zmm_cditem-oth4.
   ELSE.
     IF zmm_cditem-oth4 <> 'X'.
       g_parno = 4.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABCTRL110_desc4_check

****************************************************
 FORM popup_userdesc1.
   REFRESH : ist_sval1.
   CLEAR : ist_sval1.
   MOVE : 'ZMM_CDITEM'  TO ist_sval1-tabname,
          'USER_DESC'   TO ist_sval1-fieldname,
          'X'           TO ist_sval1-field_obl.
   APPEND ist_sval1.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       popup_title     = 'USER DESCRIPTION'
       start_column    = '5'
       start_row       = '5'
     TABLES
       fields          = ist_sval1
     EXCEPTIONS
       error_in_fields = 1
       OTHERS          = 2.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   READ TABLE ist_sval1 INDEX 1.
   g_TABCTRL110_wa-user_desc = ist_sval1-value.

 ENDFORM.                    " popup_userdesc1

*---------------------------------------------------------------------*
*       FORM popup_userdesc2                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM popup_userdesc2.
   REFRESH : ist_sval2.
   CLEAR : ist_sval2.
   MOVE : 'ZMM_CDITEM'  TO ist_sval2-tabname,
          'USER_DESC'   TO ist_sval2-fieldname,
          'X'           TO ist_sval2-field_obl.
   APPEND ist_sval2.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       popup_title     = 'USER DESCRIPTION'
       start_column    = '5'
       start_row       = '5'
     TABLES
       fields          = ist_sval2
     EXCEPTIONS
       error_in_fields = 1
       OTHERS          = 2.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   READ TABLE ist_sval2 INDEX 1.
   g_TABCTRL110_wa-user_desc = ist_sval2-value.

 ENDFORM.                    " popup_userdesc2

*---------------------------------------------------------------------*
*       FORM popup_userdesc3                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM popup_userdesc3.
   REFRESH : ist_sval3.
   CLEAR : ist_sval3.
   MOVE : 'ZMM_CDITEM'  TO ist_sval3-tabname,
          'USER_DESC'   TO ist_sval3-fieldname,
          'X'           TO ist_sval3-field_obl.
   APPEND ist_sval3.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       popup_title     = 'USER DESCRIPTION'
       start_column    = '5'
       start_row       = '5'
     TABLES
       fields          = ist_sval3
     EXCEPTIONS
       error_in_fields = 1
       OTHERS          = 2.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   READ TABLE ist_sval3 INDEX 1.
   g_TABCTRL110_wa-user_desc = ist_sval3-value.

 ENDFORM.                    " popup_userdesc3

*---------------------------------------------------------------------*
*       FORM popup_userdesc4                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM popup_userdesc4.
   REFRESH : ist_sval4.
   CLEAR : ist_sval4.
   MOVE : 'ZMM_CDITEM'  TO ist_sval4-tabname,
          'USER_DESC'   TO ist_sval4-fieldname,
          'X'           TO ist_sval4-field_obl.
   APPEND ist_sval4.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       popup_title     = 'USER DESCRIPTION'
       start_column    = '5'
       start_row       = '5'
     TABLES
       fields          = ist_sval4
     EXCEPTIONS
       error_in_fields = 1
       OTHERS          = 2.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ENDIF.
   READ TABLE ist_sval4 INDEX 1.
   g_TABCTRL110_wa-user_desc = ist_sval4-value.

 ENDFORM.                    " popup_userdesc4

*---------------------------------------------------------------------*
*       FORM TABLCTRL120_desc1_check                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABLCTRL120_desc1_check .

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .

   IF sy-subrc = 0.
     CLEAR g_TABLCTRL120_wa-oth1.
     CLEAR zmm_cditem-oth1.
   ELSE.
     IF zmm_cditem-oth1 <> 'X'.
       g_parno = 1.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                 " TABLCTRL120_desc1_check

*&---------------------------------------------------------------------*
*&      Form  popup_userdesc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
* FORM popup_userdesc.
*
*   call screen 115 starting at 18 17 ending at 120 23.
*
* ENDFORM.                    " popup_userdesc
*&---------------------------------------------------------------------*
*&      Form  CHANGE_PARTNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_G_PARTNO  text
*----------------------------------------------------------------------*
 FORM change_partno CHANGING p_g_partno LIKE zmm_cditem-user_desc
                             p_g_partnoc LIKE zmm_cditem-partno.

   DATA : l_len TYPE i.
   DATA : l_ctr TYPE i.
   DATA : l_ctr1 TYPE i.
   DATA : l_add TYPE i.
   DATA : l_sub TYPE i.
   DATA : l_ctrf TYPE i.
   DATA : l_p_g_partnoc LIKE zmm_cditem-partno.

   CLEAR : p_g_partno.
   CLEAR : check_flag2.

   l_len = strlen( p_g_partnoc ).

   l_p_g_partnoc = p_g_partnoc.

   DO l_len TIMES.

     l_ctr = l_ctr + 1.

     wa_char = l_p_g_partnoc+l_ctr(1).
     TRANSLATE wa_char TO UPPER CASE.

     LOOP AT ist_alphanum INTO wa_alphanum.

       IF wa_char = wa_alphanum.
         check_flag1 = 'X'.
         EXIT.
       ELSEIF wa_char = '*'.
         check_flag2 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF check_flag1 = 'X'.
       CLEAR check_flag1.
     ELSE.
       l_add = l_ctr + 1.
       l_sub = l_len - l_add + 1.
       IF l_add > l_len.
       ELSE.
         CONCATENATE l_p_g_partnoc+0(l_ctr) '%' l_p_g_partnoc+l_add(l_sub)
                        INTO l_p_g_partnoc.
       ENDIF.
     ENDIF.

   ENDDO.
   CLEAR l_ctr.
   l_ctrf = l_len - 1.
   DO l_len TIMES.
     wa_alphanum = l_p_g_partnoc+l_ctr(1).
     IF l_ctr = l_ctrf.
       CONCATENATE p_g_partno wa_alphanum INTO p_g_partno.
     ELSEIF wa_alphanum <> '%'.
       CONCATENATE p_g_partno wa_alphanum '%' INTO p_g_partno.
     ENDIF.

     l_ctr = l_ctr + 1.
   ENDDO.

 ENDFORM.                    " CHANGE_PARTNO

*---------------------------------------------------------------------*
*       FORM CHANGE_PARTNO1                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_G_PARTNOO                                                   *
*  -->  P_G_PARTNOCC                                                  *
*---------------------------------------------------------------------*
 FORM change_partno1 CHANGING p_g_partnoo LIKE zmm_cditem-user_desc
                             p_g_partnocc LIKE zmm_cditem-partno.

   DATA : l_len TYPE i.
   DATA : l_ctr TYPE i.

   CLEAR : p_g_partnoo.

   l_len = strlen( p_g_partnocc ).

   CLEAR check_flag1.

   DO l_len TIMES.

     wa_char = p_g_partnocc+l_ctr(1).
     TRANSLATE wa_char TO UPPER CASE.
     l_ctr = l_ctr + 1.

     LOOP AT ist_alphanum INTO wa_alphanum.

       IF wa_char = wa_alphanum.
         check_flag1 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF check_flag1 = 'X'.
       CLEAR check_flag1.
       CONCATENATE p_g_partnoo wa_char INTO p_g_partnoo.
     ENDIF.

   ENDDO.

 ENDFORM.                    " CHANGE_PARTNO

*---------------------------------------------------------------------*
*       FORM CHANGE_PARTNO2                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_G_PARTNOO                                                   *
*  -->  P_G_PARTNOCC                                                  *
*---------------------------------------------------------------------*
 FORM change_partno2 CHANGING p_g_partnoo LIKE zmm_cditem-user_desc
                             p_g_partnocc LIKE zmm_cditem-partno.

   DATA : l_len TYPE i.
   DATA : l_ctr TYPE i.

   CLEAR : p_g_partnoo.

   l_len = strlen( p_g_partnocc ).

   CLEAR check_flag1.

   DO l_len TIMES.

     wa_char = p_g_partnocc+l_ctr(1).
     TRANSLATE wa_char TO UPPER CASE.
     l_ctr = l_ctr + 1.

     LOOP AT ist_alphanum INTO wa_alphanum.

       IF wa_char = wa_alphanum.
         check_flag1 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF check_flag1 = 'X'.
       CLEAR check_flag1.
       CONCATENATE p_g_partnoo wa_char INTO p_g_partnoo.
     ENDIF.

   ENDDO.

 ENDFORM.                    " CHANGE_PARTNO



*---------------------------------------------------------------------*
*       FORM attrib_parno                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM attrib_parno.


   SELECT * FROM zmm_modifier UP TO 1 ROWS
  WHERE desc1 = g_tabctrl110_wa-desc1
  AND matgrp = g_tabctrl110_wa-matgp
  ORDER BY PRIMARY KEY .
   ENDSELECT.
   IF sy-subrc <> 0.
     g_parno = '1'.
   ENDIF.

   IF sy-subrc = 0.

     IF  zmm_modifier-desc2 IS INITIAL.
       g_parno = '1'.
     ELSEIF  zmm_modifier-desc3 IS INITIAL.
       g_parno = '2'.
     ELSEIF  zmm_modifier-desc4 IS INITIAL.
       g_parno = '3'.
     ELSE.
       g_parno = '4'.
     ENDIF.

   ENDIF.

 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TABLCTRL140_desc1_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TABLCTRL140_desc1_check.

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .

   IF sy-subrc = 0.
     CLEAR g_TABLCTRL140_wa-oth1.
     CLEAR zmm_cditem-oth1.
   ELSE.
     IF zmm_cditem-oth1 <> 'X'.
       g_parno = 1.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABLCTRL140_desc1_check
*&---------------------------------------------------------------------*
*&      Form  TABLCTRL130_desc1_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TABLCTRL130_desc1_check.

   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .

   IF sy-subrc = 0.
     CLEAR g_TABLCTRL130_wa-oth1.
     CLEAR zmm_cditem-oth1.
   ELSE.
     IF zmm_cditem-oth1 <> 'X'.
       g_parno = 1.
       MESSAGE i002(zmm_oth).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABLCTRL130_desc1_check

*&---------------------------------------------------------------------*
*&      Form  add_delitem
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem110.
   LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
     IF g_TABCTRL110_wa-flag = 'X'.
       IF g_TABCTRL110_wa-matcode IS INITIAL.
         APPEND g_TABCTRL110_wa TO g_itab_del110.
       ELSE.
         MESSAGE i031(zmm_oth).
         g_TABCTRL110_wa-flag = ''.
         g_delflag = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR g_TABCTRL110_wa.
 ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  add_delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem120.
   LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
     IF g_TABLCTRL120_wa-flag = 'X'.
       IF g_TABLCTRL120_wa-matcode IS INITIAL.
         APPEND g_TABLCTRL120_wa TO g_itab_del120.
       ELSE.
         MESSAGE i031(zmm_oth).
         g_TABLCTRL120_wa-flag = ''.
         g_delflag = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR g_TABLCTRL120_wa.

 ENDFORM.                    " add_delitem120
*&---------------------------------------------------------------------*
*&      Form  add_delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem130.
   LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
     IF g_TABLCTRL130_wa-flag = 'X'.
       IF g_TABLCTRL130_wa-matcode IS INITIAL.
         APPEND g_TABLCTRL130_wa TO g_itab_del130.
       ELSE.
         MESSAGE i031(zmm_oth).
         g_TABLCTRL130_wa-flag = ''.
         g_delflag = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR g_TABLCTRL130_wa.

 ENDFORM.                    " add_delitem130
*&---------------------------------------------------------------------*
*&      Form  add_delitem140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem140.
   LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
     IF g_TABLCTRL140_wa-flag = 'X'.
       APPEND g_TABLCTRL140_wa TO g_itab_del140.
     ENDIF.
   ENDLOOP.
   CLEAR g_TABLCTRL140_wa.

 ENDFORM.                    " add_delitem140

*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM prepare_update.
***To delete the 'DELETED' marked item from the DB table.

   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
       l_mattype = 'S'.
       PERFORM delitem110.
     WHEN 'ZSPR'.
       l_mattype = 'P'.
       PERFORM delitem120.
     WHEN 'ZCAP'.
       l_mattype = 'C'.
       PERFORM delitem130.
     WHEN 'ZDIS'.
       l_mattype = 'D'.
       PERFORM delitem140.
   ENDCASE.
   PERFORM Insert_into_tab.

 ENDFORM.                    " prepare_update

*&---------------------------------------------------------------------*
*&      Form  delitem110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delitem110.
* if not g_itab_del110 is initial.
*     loop at g_itab_del110 into g_tabctrl110_wa.
   DELETE FROM zmm_cditem
   WHERE  reqno   = zmm_cdhd_st-reqno.
*       and    srno    = g_project200.
*     endloop.
   REFRESH g_itab_del110.
*  endif.
 ENDFORM.                    " delitem110

*&---------------------------------------------------------------------*
*&      Form  delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delitem120.
*  if not g_itab_del120 is initial.
*     loop at g_itab_del120 into g_tablctrl120_wa.
   DELETE FROM zmm_cditem
   WHERE  reqno   = zmm_cdhd_st-reqno.
*       and    srno    = g_project200.
*     endloop.
   REFRESH g_itab_del120.
*  endif.



 ENDFORM.                    " delitem120

*&---------------------------------------------------------------------*
*&      Form  delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delitem130.
* if not g_itab_del130 is initial.
*     loop at g_itab_del130 into g_tablctrl130_wa.
   DELETE FROM zmm_cditem
   WHERE  reqno   = zmm_cdhd_st-reqno.
*       and    srno    = g_project200.
*     endloop.
   REFRESH g_itab_del130.
* endif.

 ENDFORM.                    " delitem130
*&---------------------------------------------------------------------*
*&      Form  delitem140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delitem140.
* if not g_itab_del140 is initial.
*     loop at g_itab_del140 into g_tablctrl140_wa.
   DELETE FROM zmm_cditem
   WHERE  reqno   = zmm_cdhd_st-reqno.
*       and    srno    = g_project200.
*     endloop.
   REFRESH g_itab_del140.
* endif.
 ENDFORM.                    " delitem140

*&---------------------------------------------------------------------*
*&      Form  prepare_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM prepare_delete.

   PERFORM confirm_del.

   IF g_choice = 'J'.

     DELETE FROM zmm_cdhd
     WHERE reqno = zmm_cdhd_st-reqno.
     IF sy-subrc <> 0.
       MESSAGE e007(zmm_oth) WITH zmm_cdhd_st-reqno.
     ENDIF.
***
     SELECT tdobject tdname tdid FROM stxl
      INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
      WHERE tdid = 'CDDS'.
     IF sy-subrc = 0.
       DELETE ist_textid_items
          WHERE tdname+4(10) <> zmm_cdhd_st-reqno.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.

     DELETE FROM zmm_cditem
     WHERE reqno = zmm_cdhd_st-reqno.
     IF sy-subrc = 0.
       MESSAGE i004(zmm_oth) WITH zmm_cdhd_st-reqno.
     ENDIF.


*  update zmm_cdhd
*  set lvorm = 'D'
*  where reqno = zmm_cdhd_st-reqno
*  and   lvorm = ''.
*  if sy-subrc <> 0.
*   message e003(zmm_oth) with zmm_cdhd_st-reqno.
*  endif.
*
*  update zmm_cditem
*  set lvorm = 'D'
*  where reqno = zmm_cdhd_st-reqno.
*  if sy-subrc = 0.
*   message i004(zmm_oth) with zmm_cdhd_st-reqno.
*  endif.

     CLEAR g_choice.
   ENDIF.

*  clear zmm_cdhd_st.
*  case l_mattype.
*    when 'S'.
*      refresh g_tabctrl110_itab.
*      refresh control 'TABCTRL110' from screen '0110'.
*    when 'P'.
*      refresh g_tablctrl120_itab.
*      refresh control 'TABCTRL120' from screen '0120'.
*    when 'C'.
*      refresh g_tablctrl130_itab.
*      refresh control 'TABCTRL130' from screen '0130'.
*    when 'D'.
*      refresh g_tablctrl140_itab.
*      refresh control 'TABCTRL140' from screen '0140'.
*  endcase.

 ENDFORM.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  bac_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM matcode_confirm.
   " Begin of <RD1K960036>.

*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               DEFAULTOPTION  = 'N'
*               TEXTLINE1      = 'The details in the request have been'
*               TEXTLINE2      = 'checked. Please generate new Material
*Codes '
*               TITEL          = 'CONFIRM'
*               START_COLUMN   = 25
*               START_ROW      = 6
*               CANCEL_DISPLAY = ''
*          IMPORTING
*               ANSWER         = a_choice.

   DATA : l_answer(1) TYPE c.



   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'CONFIRM'
       text_question         = 'The details in the request have been checked.'
                               & ' Please generate new Material Codes. '
       text_button_1         = 'Yes'
       text_button_2         = 'No'
       default_button        = '2'
       display_cancel_button = ' '
       start_column          = 25
       start_row             = 6
     IMPORTING
       answer                = l_answer
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.
   IF sy-subrc = 0.

     CASE l_answer.
       WHEN '1'.
         MOVE 'J' TO a_choice.
       WHEN '2'.
         MOVE 'N' TO a_choice.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
 ENDFORM.                    " matcode_confirm

 FORM bac_confirm.
   DATA l_choice.
   IF g_mode <> 'DIS'.
     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               TEXTLINE1      = 'Data will be lost, Want to quit? '
*               TITEL          = 'BACK'
*               START_COLUMN   = 25
*               START_ROW      = 6
*               CANCEL_DISPLAY = ''
*          IMPORTING
*               ANSWER         = l_choice.
     DATA : l_answer(1) TYPE c.

     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'BACK'
         text_question         = 'Data will be lost, Want to quit? '
         text_button_1         = 'Yes'
         text_button_2         = 'No'
         display_cancel_button = ' '
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_answer
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.
     IF sy-subrc = 0.
       CASE l_answer.
         WHEN '1'.
           MOVE 'J' TO l_choice.
         WHEN '2'.
           MOVE 'N' TO l_choice.
       ENDCASE.
     ENDIF.

     " End of <RD1K960036>.

     IF l_choice = 'J'.
       PERFORM undo_longtext.
       PERFORM clear_var.
       CLEAR l_choice.
     ENDIF.
   ELSE.
     PERFORM clear_var.
   ENDIF.
 ENDFORM.                    " bac_confirm

*&---------------------------------------------------------------------*
*&      Form  check_delreq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_delreq.
   DATA l_zmm_cdhd LIKE zmm_cdhd.
   IF g_mode = 'DEL'.
     SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
           WHERE reqno = zmm_cdhd_st-reqno
           AND   lvorm = 'D'.
     IF sy-subrc = 0.
       MESSAGE e004(zmm_oth) WITH zmm_cdhd_st-reqno.
     ENDIF.

     SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
           WHERE reqno = zmm_cdhd_st-reqno
           AND   reqcl IN ('C','AC','IC','IR').
     IF sy-subrc = 0.
       MESSAGE e056(zmm_oth) WITH zmm_cdhd_st-reqno.
     ENDIF.

   ENDIF.
****
   IF g_mode = 'CHA' OR
      g_mode = 'APR'.
     SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
            WHERE reqno = zmm_cdhd_st-reqno.
     IF sy-subrc = 0.
       IF l_zmm_cdhd-reqcl = 'AC' OR
          l_zmm_cdhd-reqcl = 'C'.
         MESSAGE e053(zmm_oth) WITH zmm_cdhd_st-reqno.
       ELSEIF l_zmm_cdhd-reqcl = 'IC'.
         MESSAGE i054(zmm_oth) WITH zmm_cdhd_st-reqno.
       ENDIF.
     ENDIF.
   ENDIF.
****
   IF g_mode = 'APR' AND g_user = 'L'.
***To check , if Tech Auth Appr is reqired.
     SELECT SINGLE * FROM zmm_cditem INTO CORRESPONDING FIELDS OF zmm_cditem
           WHERE reqno = zmm_cdhd_st-reqno
           AND   oth1  = 'X'.
     IF sy-subrc = 0.
       MESSAGE e055(zmm_oth) WITH zmm_cdhd_st-reqno.
     ENDIF.
   ENDIF.

 ENDFORM.                    " check_delreq
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_del.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*    EXPORTING
*    TEXTLINE1   = 'Data will be lost, No recovery possible, Are you sure
* ? '
*     TITEL       = 'BACK'
*     START_COLUMN     = 25
*     START_ROW        = 6
*     CANCEL_DISPLAY   = ''
*    IMPORTING
*     ANSWER           = g_choice.

   DATA : l_answer(1) TYPE c.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar       = 'BACK '
       text_question  = 'Data will be lost, No recovery possible, Are you sure ?'
       start_column   = 25
       start_row      = 6
     IMPORTING
       answer         = l_answer
     EXCEPTIONS
       text_not_found = 1
       OTHERS         = 2.
   IF sy-subrc = 0.
     CASE l_answer.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
*  If g_choice = 'J'.
*    perform clear_var.
*    clear g_choice.
*  endif.



 ENDFORM.                    " confirm_del
*&---------------------------------------------------------------------*
*&      Form  check_tabrows
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_tabrows.
   DATA: wa_itab110 TYPE t_TABCTRL110,
         wa_itab120 TYPE t_TABLCTRL120,
         wa_itab130 TYPE t_TABLCTRL130,
         wa_itab140 TYPE t_TABLCTRL140.
   CLEAR g_insrflg.
   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
       READ TABLE g_tabctrl110_itab INTO wa_itab110
            WITH KEY srno = 10.
       IF sy-subrc = 0.
         g_insrflg = 'Y'.
       ENDIF.
     WHEN 'ZSPR'.
       READ TABLE g_tablctrl120_itab INTO wa_itab120
            WITH KEY srno = 10.
       IF sy-subrc = 0.
         g_insrflg = 'Y'.
       ENDIF.
     WHEN 'ZCAP'.
       READ TABLE g_tablctrl130_itab INTO wa_itab130
            WITH KEY srno = 10.
       IF sy-subrc = 0.
         g_insrflg = 'Y'.
       ENDIF.
     WHEN 'ZDIS'.
       READ TABLE g_tablctrl140_itab INTO wa_itab140
            WITH KEY srno = 10.
       IF sy-subrc = 0.
         g_insrflg = 'Y'.
       ENDIF.
   ENDCASE.

 ENDFORM.                    " check_tabrows
*&---------------------------------------------------------------------*
*&      Form  set_dynnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_CDHD_ST_MTART  text
*----------------------------------------------------------------------*
 FORM set_dynnr USING p_mtart.
   CASE p_mtart.
     WHEN 'ZSTO'.
       dynnr = '0110'.
     WHEN 'ZSPR'.
       dynnr = '0120'.
     WHEN 'ZCAP'.
       dynnr = '0130'.
     WHEN 'ZDIS'.
       dynnr = '0140'.
   ENDCASE.
 ENDFORM.                    " set_dynnr
*&---------------------------------------------------------------------*
*&      Form  ltxtdtsp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ltxtdtsp.
*************Local Data*******************************
   DATA: l_srno    LIKE zmm_cditem-srno,
         l_curs_ln TYPE i,
         l_itab110 TYPE t_TABCTRL110,
         l_itab120 TYPE t_TABLCTRL120,
         l_itab130 TYPE t_TABLCTRL130,
         l_itab140 TYPE t_TABLCTRL140.
**
   CLEAR ist_textid.

********************************************************
*  get cursor line l_curs_ln.
***To get the proper serial no of line item against the
***Cursor position
   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
*   move tabctrl110-current_line to l_curs_ln.
       l_curs_ln = g_curr_line_110.
       READ TABLE g_tabctrl110_itab INTO l_itab110
                                   INDEX l_curs_ln.
       l_srno = l_itab110-srno.
     WHEN 'ZSPR'.
*   move tablctrl120-current_line to l_curs_ln.
       l_curs_ln = g_curr_line_120.
       READ TABLE g_tablctrl120_itab INTO l_itab120
                                   INDEX l_curs_ln.
       l_srno = l_itab120-srno.
     WHEN 'ZCAP'.
       MOVE tablctrl130-current_line TO l_curs_ln.
       READ TABLE g_tablctrl130_itab INTO l_itab130
                                   INDEX l_curs_ln.
       l_srno = l_itab130-srno.
     WHEN 'ZDIS'.
       MOVE tablctrl140-current_line TO l_curs_ln.
       READ TABLE g_tablctrl140_itab INTO l_itab140
                                   INDEX l_curs_ln.
       l_srno = l_itab140-srno.
   ENDCASE.

***
   IF g_mode = 'CRE'.
     CONCATENATE 'CDDS' '9999999999' l_srno
     INTO ist_textid-tdname.
   ELSE.
     CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
     INTO ist_textid-tdname.
   ENDIF.

   ist_textid-tdobject   = 'ZMMCD'.
   ist_textid-tdid       = 'CDDS'.
   ist_textid-tdspras    =  sy-langu.
   ist_textid-tdlinesize =  72.
***Appending to internal table for all textid/name.
   APPEND ist_textid TO ist_textid_items.
*  if l_srno <> '000'.
   PERFORM read_text_dtspecs.
*  endif.

 ENDFORM.                    " ltxtdtsp
*&---------------------------------------------------------------------*
*&      Form  read_text_dtspecs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM read_text_dtspecs.
   CLEAR   : ist_dtspecs.
   REFRESH : ist_dtspecs.
   PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
   PERFORM edit_text.
*****To save temporarily in the stxl table with [CDDS9999999999(srno)]
**** for Creation and with [CDDS(reqno)(srno)] for Change
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
     wa_textid = ist_textid.
     PERFORM save_text.
   ENDIF.

 ENDFORM.                    " read_text_dtspecs
*&---------------------------------------------------------------------*
*&      Form  read_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_DTSPECS  text
*      -->P_IST_TEXTID  text
*----------------------------------------------------------------------*
 FORM read_text_data TABLES   p_ist_dtspecs STRUCTURE  tline
                     USING    p_ist_textid  STRUCTURE  thead.

   CALL FUNCTION 'READ_TEXT'
     EXPORTING
       client                  = sy-mandt
       id                      = p_ist_textid-tdid
       language                = sy-langu
       name                    = p_ist_textid-tdname
       object                  = p_ist_textid-tdobject
     IMPORTING
       header                  = p_ist_textid
     TABLES
       lines                   = p_ist_dtspecs
     EXCEPTIONS
       id                      = 1
       language                = 2
       name                    = 3
       not_found               = 4
       object                  = 5
       reference_check         = 6
       wrong_access_to_archive = 7
       OTHERS                  = 8.

 ENDFORM.                    " read_text_data
*&---------------------------------------------------------------------*
*&      Form  edit_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM edit_text.

   DATA: l_display,
         l_USERTITLE,
         l_itced LIKE itced.
   l_usertitle       = 'X'.
   l_itced-usertitle = l_usertitle.

   IF ( g_mode = 'CRE' ) OR  ( g_mode = 'CHA' ).
     l_display = ''.
   ELSE.
     l_display = 'X'.
   ENDIF.
   CALL FUNCTION 'EDIT_TEXT'
     EXPORTING
       display       = l_display
       header        = ist_textid
*************************************************************
       control       = l_itced
*************************************************************
     TABLES
       lines         = ist_dtspecs
     EXCEPTIONS
       id            = 1
       language      = 2
       linesize      = 3
       name          = 4
       object        = 5
       textformat    = 6
       communication = 7
       OTHERS        = 8.

 ENDFORM.                    " edit_text
*&---------------------------------------------------------------------*
*&      Form  SAVE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM save_text.

   DATA : l_dtspecs LIKE tline.

   LOOP AT ist_dtspecs INTO l_dtspecs.
     TRANSLATE l_dtspecs TO UPPER CASE.
     MODIFY ist_dtspecs FROM l_dtspecs INDEX sy-tabix.
   ENDLOOP.

   CALL FUNCTION 'SAVE_TEXT'
     EXPORTING
       client          = sy-mandt
       header          = wa_textid
       savemode_direct = 'X'
     TABLES
       lines           = ist_dtspecs
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

 ENDFORM.                    " SAVE_TEXT
*&---------------------------------------------------------------------*
*&      Form  delete_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delete_text.
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

 ENDFORM.                    " delete_text
*&---------------------------------------------------------------------*
*&      Form  delete_addedtext
*&---------------------------------------------------------------------*
*  This subroutine delete the added long text, added during the change
*mode.From the internal table, delete the items other than original
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM delete_addedtext.
   TYPES: BEGIN OF l_items,
            reqno LIKE zmm_cdhd-reqno,
            srno  LIKE zmm_cditem-srno,
          END OF l_items.
   DATA: l_items_itab TYPE TABLE OF l_items WITH HEADER LINE.
**************************************************************
****To get the original items for a reqno
   REFRESH l_items_itab.
*Select srno reqno from zmm_cditem
*       appending corresponding fields of table l_items_itab[]
*                  where reqno = zmm_cdhd_st-reqno.
   SELECT reqno srno FROM zmm_cditem
    INTO CORRESPONDING FIELDS OF TABLE l_items_itab[]
                    WHERE reqno = zmm_cdhd_st-reqno.
   IF sy-subrc = 0.

****To delete these numbers from internal table ist_textid_items
****if found in original items list.
     LOOP AT ist_textid_items INTO wa_textid.
       READ TABLE l_items_itab WITH KEY
                  reqno = wa_textid-tdname+4(10)
                  srno  = wa_textid-tdname+14(3).
       IF sy-subrc = 0.
         DELETE ist_textid_items
                WHERE tdobject = wa_textid-tdobject
                AND   tdid     = wa_textid-tdid
                AND   tdname   = wa_textid-tdname.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " delete_addedtext
*&---------------------------------------------------------------------*
*&      Form  undo_longtext
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM undo_longtext.
   IF NOT ist_textid_items IS INITIAL.
     IF g_mode = 'CRE'.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ELSEIF g_mode = 'CHA'.
       PERFORM delete_addedtext.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.
   ENDIF.
 ENDFORM.                    " undo_longtext
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM text_control_eingabebereit1.
   CALL METHOD gv_text_editor1->set_readonly_mode
     EXPORTING
       readonly_mode          = gv_text_editor1->true
     EXCEPTIONS
       error_cntl_call_method = 1
       invalid_parameter      = 2
       OTHERS                 = 3.
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'MRP' ) OR
      ( g_mode = 'APR' ) OR sy-tcode = 'ZCODG'.

     CALL METHOD gv_text_editor2->set_readonly_mode
       EXPORTING
         readonly_mode          = gv_text_editor2->false
       EXCEPTIONS
         error_cntl_call_method = 1
         invalid_parameter      = 2
         OTHERS                 = 3.
   ENDIF.


 ENDFORM.                    " text_control_eingabebereit1
*&---------------------------------------------------------------------*
*&      Form  text_control_set_text_table1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM text_control_set_text_table1.
*Addition***********************************************
   REFRESH: tlinetab1,g_linefrto_itab.
   IF g_mode <> 'CRE'.
     APPEND LINES OF lines_cors TO tlinetab1[].
   ENDIF.
*End     ***********************************************
*Addition***********************************************
   LOOP AT tlinetab1[] INTO g_line132.
     IF ( g_line132+0(7) = '* Reply' ) OR
        ( g_line132+0(7) = '**Reply' ).
       g_linefrto-line_fr = sy-tabix.
       g_linefrto-line_to = sy-tabix.
       APPEND g_linefrto TO g_linefrto_itab.
       CLEAR: g_linefrto.
     ENDIF.
   ENDLOOP.
*End     ***********************************************

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


   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'MRP' ) OR
      ( g_mode = 'APR' ) OR sy-tcode = 'ZCODG'.


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

 ENDFORM.                    " text_control_set_text_table1

*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_correspondense.

   DATA : l_cors LIKE thead-tdname.

   IF g_mode <> 'CRE'.
     CONCATENATE 'CORS' zmm_cdhd_st-reqno INTO l_cors.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client                  = sy-mandt
         id                      = 'CORS'
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
   ENDIF.

 ENDFORM.                    " get_correspondense

*&---------------------------------------------------------------------*
*&      Form  save_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM save_cors_text.
   DATA: l_theader LIKE thead.
   DATA: l_datech(10) TYPE c.
***********Assignments***********************
   CLEAR l_theader.
   l_theader-tdobject   = 'ZMMCD'.
   l_theader-tdid       = 'CORS'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_cdhd_st-reqno INTO l_theader-tdname.
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

 ENDFORM.                    " save_cors_text
*&---------------------------------------------------------------------*
*&      Form  destroy_ctrl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM destroy_ctrl.
   CASE g_mode.
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'MRP' OR 'APR'.
       CALL METHOD gv_text_editor1->free.
       CALL METHOD gv_text_editor2->free.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD gv_text_editor1->free.
   ENDCASE.
   CLEAR:gv_text_editor1,gv_text_editor2.

 ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  check_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_items.
   DATA : l_t110 TYPE t_tabctrl110,
          l_t120 TYPE t_tablctrl120,
          l_t130 TYPE t_TABLCTRL130.
   CLEAR g_saveflag.

   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
       READ TABLE g_tabctrl110_itab INTO l_t110 INDEX 1.
       IF sy-subrc = 0.
         IF NOT l_t110-uom IS INITIAL.
           g_saveflag = 'Y'.
         ELSE.
           g_saveflag = 'N'.
         ENDIF.
       ELSE.
         g_saveflag = 'N'.
       ENDIF.
     WHEN 'ZSPR'.
       READ TABLE g_tablctrl120_itab INTO l_t120 INDEX 1.
       IF sy-subrc = 0.
         IF NOT l_t120-manu IS INITIAL.
           g_saveflag = 'Y'.
         ELSE.
           g_saveflag = 'N'.
         ENDIF.
       ELSE.
         g_saveflag = 'N'.
       ENDIF.
     WHEN 'ZCAP'.
       READ TABLE g_tablctrl130_itab INTO l_t130 INDEX 1.
       IF sy-subrc = 0.
         IF NOT l_t130-uom IS INITIAL.
           g_saveflag = 'Y'.
         ELSE.
           g_saveflag = 'N'.
         ENDIF.
       ELSE.
         g_saveflag = 'N'.
       ENDIF.

   ENDCASE.
 ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  check_lt_exist
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TDNAME  text
*      -->P_L_LINES  text
*----------------------------------------------------------------------*
 FORM check_lt_exist USING    p_tdname.

   REFRESH g_lines.
   CALL FUNCTION 'READ_TEXT'
     EXPORTING
       client                  = sy-mandt
       id                      = 'CDDS'
       language                = sy-langu
       name                    = p_tdname
       object                  = 'ZMMCD'
     TABLES
       lines                   = g_lines
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
   ENDIF.


 ENDFORM.                    " check_lt_exist
*&---------------------------------------------------------------------*
*&      Form  lock_reqhd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM lock_reqhd.
   CALL FUNCTION 'ENQUEUE_EZ_MM_CDHD'
     EXPORTING
       mode_zmm_cdhd  = 'E'
       mandt          = sy-mandt
       reqno          = zmm_cdhd_st-reqno
     EXCEPTIONS
       foreign_lock   = 1
       system_failure = 2
       OTHERS         = 3.

   IF sy-subrc <> 0.
     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   ELSE.
     MOVE 'Y' TO g_lock.
   ENDIF.

 ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  unlock_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unlock_req .
*********Header*******************************
   CALL FUNCTION 'DEQUEUE_EZ_MM_CDHD'
     EXPORTING
       mode_zmm_cdhd = 'E'
       mandt         = sy-mandt
       reqno         = zmm_cdhd_st-reqno.

 ENDFORM.                    " unlock_req
***************************************************

 AT USER-COMMAND.
   IF sy-ucomm = 'AGREE'.
     IF g_mode = 'REL'.
       PERFORM update_release.
     ELSEIF g_mode = 'APR'.
       PERFORM update_approval.
     ENDIF.
   ENDIF.
   PERFORM clear_var.
   LEAVE TO SCREEN 0.
***************************************************
*&---------------------------------------------------------------------*
*&      Form  other_sectime
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM other_sectime.
   IF zmm_cditem-oth1 = 'X'.
     LOOP AT SCREEN.
       IF screen-name = 'G_USER_DESC'.
         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ELSEIF zmm_cditem-oth1 = '' AND
          zmm_cditem-oth2 = 'X'.
     LOOP AT SCREEN.
       IF screen-name = 'G_USER_DESC' OR
          screen-name = 'G_DESC1'    OR
          screen-name = 'G_MATGP'.
         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ELSEIF zmm_cditem-oth1 = '' AND
          zmm_cditem-oth2 = '' AND
          zmm_cditem-oth3 = 'X'.
     LOOP AT SCREEN.
       IF screen-name = 'G_USER_DESC' OR
          screen-name = 'G_DESC1'     OR
          screen-name = 'G_DESC2'     OR
          screen-name = 'G_MATGP'.
         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.

   ELSEIF zmm_cditem-oth1 = '' AND
          zmm_cditem-oth2 = '' AND
          zmm_cditem-oth3 = '' AND
          zmm_cditem-oth4 = 'X'.
     LOOP AT SCREEN.
       IF screen-name = 'G_USER_DESC' OR
          screen-name = 'G_DESC1'     OR
          screen-name = 'G_DESC2'     OR
          screen-name = 'G_DESC3'     OR
          screen-name = 'G_MATGP'.

         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.

   ENDIF.


 ENDFORM.                    " other_sectime
*&---------------------------------------------------------------------*
*&      Form  sort_sto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM sort_sto USING p_order.
   READ  TABLE tabctrl110-cols WITH  KEY selected = 'X' INTO
         wa_tabctrl110_cols.
   IF sy-subrc <> 0.
     MESSAGE e063(zmm_oth).
   ENDIF.
   g_sel_colsort = wa_tabctrl110_cols-screen-name.
   IF p_order = 'ASCENDING'.
     SORT g_tabctrl110_itab STABLE BY (g_sel_colsort+11) ASCENDING.
   ELSEIF p_order = 'DESCENDING'.
     SORT g_tabctrl110_itab STABLE BY (g_sel_colsort+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_sto
*&---------------------------------------------------------------------*
*&      Form  sort_spr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM sort_spr USING    p_order.
   READ  TABLE tablctrl120-cols WITH  KEY selected = 'X' INTO
         wa_tablctrl120_cols.
   IF sy-subrc <> 0.
     MESSAGE e063(zmm_oth).
   ENDIF.
   g_sel_colsort = wa_tablctrl120_cols-screen-name.
   IF p_order = 'ASCENDING'.
     SORT g_tablctrl120_itab STABLE BY (g_sel_colsort+11) ASCENDING.
   ELSEIF p_order = 'DESCENDING'.
     SORT g_tablctrl120_itab STABLE BY (g_sel_colsort+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_spr
*&---------------------------------------------------------------------*
*&      Form  sort_cap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM sort_cap USING    p_order.
   READ  TABLE tablctrl130-cols WITH  KEY selected = 'X' INTO
         wa_tablctrl130_cols.
   IF sy-subrc <> 0.
     MESSAGE e063(zmm_oth).
   ENDIF.
   g_sel_colsort = wa_tablctrl130_cols-screen-name.
   IF p_order = 'ASCENDING'.
     SORT g_tablctrl130_itab STABLE BY (g_sel_colsort+11) ASCENDING.
   ELSEIF p_order = 'DESCENDING'.
     SORT g_tablctrl130_itab STABLE BY (g_sel_colsort+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_cap
*&---------------------------------------------------------------------*
*&      Form  sort_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM sort_dis USING    p_order.
   READ  TABLE tablctrl140-cols WITH  KEY selected = 'X' INTO
          wa_tablctrl140_cols.
   IF sy-subrc <> 0.
     MESSAGE e063(zmm_oth).
   ENDIF.
   g_sel_colsort = wa_tablctrl140_cols-screen-name.
   IF p_order = 'ASCENDING'.
     SORT g_tablctrl140_itab STABLE BY (g_sel_colsort+11) ASCENDING.
   ELSEIF p_order = 'DESCENDING'.
     SORT g_tablctrl140_itab STABLE BY (g_sel_colsort+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_dis
*&---------------------------------------------------------------------*
*&      Form  srchlp_spr_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM srchlp_spr_del.

   CLEAR g_spr_par.

   IF g_sh_capeqt = 'X' AND g_sh_mfr = '' AND g_sh_mdlno = ''.
     g_spr_par   = '100'.
   ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = 'X' AND g_sh_mdlno = ''.
     g_spr_par   = '120'.
   ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = 'X' AND g_sh_mdlno = 'X'.
     g_spr_par   = '123'.
   ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = '' AND g_sh_mdlno = 'X'.
     g_spr_par   = '103'.
   ELSEIF g_sh_capeqt = '' AND g_sh_mfr = 'X' AND g_sh_mdlno = ''.
     g_spr_par   = '020'.
   ELSEIF g_sh_capeqt = '' AND g_sh_mfr = 'X' AND g_sh_mdlno = 'X'.
     g_spr_par   = '023'.
   ELSEIF g_sh_capeqt = '' AND g_sh_mfr = '' AND g_sh_mdlno = 'X'.
     g_spr_par   = '003'.
   ENDIF.

   CASE g_spr_par.
     WHEN '100'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       DELETE ist_srchlp_cp
       WHERE atwrt <> g_tablctrl120_wa-cap_code.  "#EC CI_FLDEXT_OK[2215424]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
     WHEN '120'.
       DELETE ist_srchlp_cp
       WHERE atwrt <> g_tablctrl120_wa-cap_code.  "#EC CI_FLDEXT_OK[2215424]
       DELETE ist_srchlp_cp
       WHERE mfrnr <> g_tablctrl120_wa-manu.
     WHEN '123'.  "#EC CI_FLDEXT_OK[2215424]
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       DELETE ist_srchlp_cp
       WHERE atwrt <> g_tablctrl120_wa-cap_code.  "#EC CI_FLDEXT_OK[2215424]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       DELETE ist_srchlp_cp
       WHERE mfrnr <> g_tablctrl120_wa-manu.
       DELETE ist_srchlp_cp
       WHERE mdlno <> g_tablctrl120_wa-mdlno.  "#EC CI_FLDEXT_OK[2215424]
     WHEN '103'.
       DELETE ist_srchlp_cp
       WHERE atwrt <> g_tablctrl120_wa-cap_code. "#EC CI_FLDEXT_OK[2215424]
       DELETE ist_srchlp_cp
       WHERE mdlno <> g_tablctrl120_wa-mdlno.
     WHEN '020'.
       DELETE ist_srchlp_cp
       WHERE mfrnr <> g_tablctrl120_wa-manu.
     WHEN '023'.
       DELETE ist_srchlp_cp
       WHERE mfrnr <> g_tablctrl120_wa-manu.
       DELETE ist_srchlp_cp
       WHERE mdlno <> g_tablctrl120_wa-mdlno.
     WHEN '003'.
       DELETE ist_srchlp_cp
       WHERE mdlno <> g_tablctrl120_wa-mdlno.
   ENDCASE.

 ENDFORM.                    " srchlp_spr_del
*&---------------------------------------------------------------------*
*&      Form  tcode_zcodg_attr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM tcode_zcodg_attr.
   IF sy-tcode = 'ZCODG'.
     LOOP AT SCREEN.
       IF screen-group3 = 'GC'.
         screen-input = 1.
         MODIFY SCREEN.
       ELSEIF screen-name = 'ZMM_CDITEM-DESC1'.
         IF zmm_cditem-oth1 = 'X'.
           screen-input = 1.
         ELSE.
           screen-input = 0.
         ENDIF.
         MODIFY SCREEN.

       ELSEIF screen-name = 'ZMM_CDITEM-DESC2'.
         IF zmm_cditem-oth1 = 'X' OR
            zmm_cditem-oth2 = 'X'.
           screen-input = 1.
         ELSE.
           screen-input = 0.
         ENDIF.
         MODIFY SCREEN.
       ELSEIF screen-name = 'ZMM_CDITEM-DESC3'.
         IF zmm_cditem-oth1 = 'X' OR
            zmm_cditem-oth2 = 'X' OR
            zmm_cditem-oth3 = 'X'.
           screen-input = 1.
         ELSE.
           screen-input = 0.
         ENDIF.
         MODIFY SCREEN.

       ELSEIF screen-name = 'ZMM_CDITEM-DESC4'.
         IF zmm_cditem-oth1 = 'X' OR
            zmm_cditem-oth2 = 'X' OR
            zmm_cditem-oth3 = 'X' OR
            zmm_cditem-oth4 = 'X'.
           screen-input = 1.
         ELSE.
           screen-input = 0.
         ENDIF.
         MODIFY SCREEN.
       ELSEIF screen-name = 'WA_SRCHLP-MARK'.
         screen-input = 1.
         MODIFY SCREEN.
       ELSEIF screen-name = 'G_TABCTRL110_WA-FLAG'.
         screen-input = 1.
         MODIFY SCREEN.
       ELSE.
         screen-input = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " tcode_zcodg_attr
*&---------------------------------------------------------------------*
*&      Form  update_codes
*&---------------------------------------------------------------------*
* TO update the created material codes in the request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_codes.
   REFRESH ist_zmm_cditem.
   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
*       append lines of g_TABCTRL110_itab to ist_zmm_cditem.
       LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
         MOVE-CORRESPONDING g_TABCTRL110_wa TO wa_zmm_cditem.
         MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
         APPEND wa_zmm_cditem TO ist_zmm_cditem.
         CLEAR wa_zmm_cditem.
       ENDLOOP.
     WHEN 'ZSPR'.
*       append lines of g_TABLCTRL120_itab to ist_zmm_cditem.
       LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
         MOVE-CORRESPONDING g_TABLCTRL120_wa TO wa_zmm_cditem.
         MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
         APPEND wa_zmm_cditem TO ist_zmm_cditem.
         CLEAR wa_zmm_cditem.
       ENDLOOP.
     WHEN 'ZCAP'.
*       append lines of g_TABLCTRL130_itab to ist_zmm_cditem.
       LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
         MOVE-CORRESPONDING g_TABLCTRL130_wa TO wa_zmm_cditem.
         MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
         APPEND wa_zmm_cditem TO ist_zmm_cditem.
         CLEAR wa_zmm_cditem.
       ENDLOOP.

     WHEN 'ZDIS'.
*       append lines of g_TABLCTRL140_itab to ist_zmm_cditem.
       LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
         MOVE-CORRESPONDING g_TABLCTRL140_wa TO wa_zmm_cditem.
         MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
         APPEND wa_zmm_cditem TO ist_zmm_cditem.
         CLEAR wa_zmm_cditem.
       ENDLOOP.
   ENDCASE.
   DATA lt_zmm_cditem_db TYPE TABLE OF zmm_cditem.
   DATA ls_zmm_cditem_db TYPE zmm_cditem.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

   LOOP AT ist_zmm_cditem INTO DATA(ls_cditem).
     CLEAR ls_zmm_cditem_db.
     MOVE-CORRESPONDING ls_cditem TO ls_zmm_cditem_db.
     APPEND ls_zmm_cditem_db TO lt_zmm_cditem_db.
   ENDLOOP.
   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

      LOOP AT ist_zmm_cditem INTO ls_cditem.
        CLEAR ls_zmm_cditem_db.
        MOVE-CORRESPONDING ls_cditem TO ls_zmm_cditem_db.
        APPEND ls_zmm_cditem_db TO lt_zmm_cditem_db.
      ENDLOOP.
  MODIFY zmm_cditem FROM TABLE lt_zmm_cditem_db.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
************************************************************
****Saving the long text.                              *****
************************************************************
******Header(Correspondence)********************************
   PERFORM save_cors_text.

 ENDFORM.                    " update_codes
*&---------------------------------------------------------------------*
*&      Form  check_reqstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_reqstatus.
   DATA : l_titem TYPE i,
          l_citem TYPE i.
   CLEAR: l_titem,l_citem.

   SELECT COUNT(*) INTO l_titem FROM zmm_cditem
          WHERE reqno = zmm_cdhd_st-reqno.
   SELECT COUNT(*) INTO l_citem FROM zmm_cditem
          WHERE reqno = zmm_cdhd_st-reqno
          AND   matcode <> ''.
   IF l_citem = l_titem.
     MOVE 'C' TO zmm_cdhd_st-reqcl.
   ELSEIF l_citem < l_titem.
     IF zmm_cdhd_st-reqcl <> 'IR'.
       MOVE 'IC' TO zmm_cdhd_st-reqcl.
     ENDIF.
   ENDIF.

 ENDFORM.                    " check_reqstatus
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM send_mail_to_cdcell.
   DATA: l_text  TYPE soli,
         l_name  LIKE sood1-objnam,
         l_title LIKE sood1-objdes,
         l_user  LIKE sy-uname.
   DATA  l_text_itab LIKE TABLE OF l_text.
   CLEAR : l_name,l_title,l_text,l_user.
   REFRESH l_text_itab.
**Assignments.....
   l_name   = zmm_cdhd_st-reqno.
   CONCATENATE 'New MatCode Request for' zmm_cdhd_st-reqno
               INTO l_title SEPARATED BY space.
   l_text = 'Please check the Request and provide the new material codes.This is'
&'a system generated mail, please do not reply.'.
   APPEND l_text TO l_text_itab.

   l_user = 'CODIFICATION'.

***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*      SPOOLNUMBER       = SY-SPONO
       mailname  = l_name
       mailtitel = l_title
       user      = l_user
     TABLES
       text      = l_text_itab
*   EXCEPTIONS
*      ERROR     = 1
*      OTHERS    = 2.
     .
   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " send_mail_to_cdcell
*&---------------------------------------------------------------------*
*&      Form  send_mail_to_reqn
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM send_mail_to_reqn.
   DATA: r_text  TYPE soli,
         r_name  LIKE sood1-objnam,
         r_title LIKE sood1-objdes,
         r_user  TYPE sy-uname.
   DATA:  r_text_itab LIKE TABLE OF r_text.
   CLEAR : r_name,r_title,r_text.
   REFRESH r_text_itab.
**Assignments.....
   r_name   = zmm_cdhd_st-reqno.
   CONCATENATE 'Request' zmm_cdhd_st-reqno 'Status'
               INTO r_title SEPARATED BY space.
   r_text = 'Request has been updated.Please check the Request,Request'
 &'status and Correspondence within it.This is a system generated mail,'
 &'please do not reply. - Codification Cell'.
   APPEND r_text TO r_text_itab.
   SELECT SINGLE reqcpf INTO r_user FROM zmm_cdhd
          WHERE reqno = zmm_cdhd_st-reqno.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*      SPOOLNUMBER       = SY-SPONO
       mailname  = r_name
       mailtitel = r_title
       user      = r_user
     TABLES
       text      = r_text_itab
     EXCEPTIONS
       error     = 1
       OTHERS    = 2.
   IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

 ENDFORM.                    " send_mail_to_reqn
*&---------------------------------------------------------------------*
*&      Form  confirm_deletion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_deletion.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*    EXPORTING
*    TEXTLINE1            = 'Once deleted can not be restore, Continue?'
*     TITEL                = 'Confirm Deletion'
*     START_COLUMN         = 25
*     START_ROW            = 6
*     CANCEL_DISPLAY       = ''
*    IMPORTING
*     ANSWER               = g_confdel.

   DATA : l_answer(1) TYPE c.

   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'CONFRIM DELETION '
       text_question         = 'Once deleted can not be restore, Continue?'
       display_cancel_button = ' '
       start_column          = 25
       start_row             = 6
     IMPORTING
       answer                = l_answer
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.
   IF sy-subrc = 0.
     CASE l_answer.
       WHEN '1'.
         MOVE 'J' TO g_confdel.
       WHEN '2'.
         MOVE 'N' TO g_confdel.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
 ENDFORM.                    " confirm_deletion

*----------------------------------------------------------------------*
*   INCLUDE MZMM_CODREQ_GCU                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GC_FIELDS_115
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM gc_fields_115.
   IF g_ok_code110 = 'PB_AD'.
     g_TABCTRL110_wa-user_desc = g_user_desc.
     g_oth = ''.
     g_user_desc = ''.
   ELSE.
     CASE 'X'.
       WHEN g_TABCTRL110_wa-oth1.
         g_TABCTRL110_wa-desc1 = g_desc1.
         g_TABCTRL110_wa-desc2 = g_desc2.
         g_TABCTRL110_wa-desc3 = g_desc3.
         g_TABCTRL110_wa-desc4 = g_desc4.
         g_TABCTRL110_wa-matgp = g_matgp.
         CLEAR : g_desc1,g_desc2,g_desc3,g_desc4.
         MOVE : 'X' TO g_TABCTRL110_wa-oth2.
*+1205050
         IF g_TABCTRL110_wa-desc3 <> ''.
           g_TABCTRL110_wa-oth3 = 'X'.
         ENDIF.
         IF g_TABCTRL110_wa-desc4 <> ''.
           g_TABCTRL110_wa-oth4 = 'X'.
         ENDIF.
*-120505
         g_TABCTRL110_wa-user_desc = g_user_desc.
         LOOP AT SCREEN.
           IF screen-name = 'ZMM_CDITEM-DESC1' OR
              screen-name = 'ZMM_CDITEM-DESC2' OR
              screen-name = 'ZMM_CDITEM-DESC3' OR
              screen-name = 'ZMM_CDITEM-DESC4'.
             screen-intensified = 1.
             MODIFY SCREEN.
           ENDIF.
         ENDLOOP.
       WHEN g_TABCTRL110_wa-oth2.
         g_TABCTRL110_wa-desc2 = g_desc2.
         g_TABCTRL110_wa-desc3 = g_desc3.
         g_TABCTRL110_wa-desc4 = g_desc4.
*+1205050
         IF g_TABCTRL110_wa-desc3 <> ''.
           g_TABCTRL110_wa-oth3 = 'X'.
         ENDIF.
         IF g_TABCTRL110_wa-desc4 <> ''.
           g_TABCTRL110_wa-oth4 = 'X'.
         ENDIF.
*+1205050
         CLEAR : g_desc2,g_desc3,g_desc4.
         g_TABCTRL110_wa-user_desc = g_user_desc.
         IF g_mode = 'CHA'.
           MODIFY g_tabctrl110_itab FROM g_TABCTRL110_wa INDEX
           g_curr_line_110.
         ENDIF.
       WHEN g_TABCTRL110_wa-oth3.
         g_TABCTRL110_wa-desc3 = g_desc3.
         g_TABCTRL110_wa-desc4 = g_desc4.
         MOVE 'X' TO g_TABCTRL110_wa-oth4.
         g_TABCTRL110_wa-user_desc = g_user_desc.
         IF g_mode = 'CHA'.
           MODIFY g_tabctrl110_itab FROM g_TABCTRL110_wa INDEX
           g_curr_line_110.
         ENDIF.

         CLEAR : g_desc3,g_desc4.
       WHEN g_TABCTRL110_wa-oth4.
         g_TABCTRL110_wa-desc4 = g_desc4.
         g_TABCTRL110_wa-user_desc = g_user_desc.
*        clear : G_DESC1,G_DESC2,G_DESC3,G_DESC4.
         CLEAR : g_desc4.
     ENDCASE.
   ENDIF.
*  clear : G_DESC1,G_DESC2,G_DESC3,G_DESC4,g_ok_code110.
   CLEAR : g_desc1,g_desc2,g_desc3,g_desc4,g_ok_code110,g_user_desc.


 ENDFORM.                    " GC_FIELDS_115
*&---------------------------------------------------------------------*
*&      Form  GC_input_keywords
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GC_input_keywords.
   CASE 'X'.
     WHEN g_TABCTRL110_wa-oth2.
       LOOP AT SCREEN.
         IF screen-name = 'G_DESC1'.
           screen-input = 0.
           screen-intensified = 1.
           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.
       g_desc1 = g_TABCTRL110_wa-desc1.
     WHEN g_TABCTRL110_wa-oth3.
       LOOP AT SCREEN.
         IF screen-name = 'G_DESC1' OR screen-name = 'G_DESC2'.
           screen-input = 0.
           screen-intensified = 1.

           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.
       g_desc1 = g_TABCTRL110_wa-desc1.
       g_desc2 = g_TABCTRL110_wa-desc2.

     WHEN g_TABCTRL110_wa-oth4.
       LOOP AT SCREEN.
         IF screen-name = 'G_DESC1' OR screen-name = 'G_DESC2' OR
            screen-name = 'G_DESC3'.
           screen-input = 0.
           screen-intensified = 1.

           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
       g_desc1 = g_TABCTRL110_wa-desc1.
       g_desc2 = g_TABCTRL110_wa-desc2.
       g_desc3 = g_TABCTRL110_wa-desc3.
   ENDCASE.
 ENDFORM.                    " GC_input_keywords
*&---------------------------------------------------------------------*
*&      Module  GC_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE gc_cursor INPUT.
 ENDMODULE.                 " GC_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Form  SELECT_MATERIAL_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM select_material_details.

   CLEAR do_not_change_flag.

   IF g_mode = 'CRE' OR g_mode = 'CHA'.

     CASE g_hits_par.

       WHEN '0'.
         g_mat_fnd = '0'.
       WHEN '1'.
         IF check_pos = 1
            AND desc22 IS INITIAL
            AND desc33 IS INITIAL
            AND desc44 IS INITIAL.
           DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
           IF g_mat_fnd = 0.
             g_mat_fnd_flag = 'X'.
           ENDIF.
         ENDIF.
       WHEN '2'.
         IF check_pos = 2
            AND desc33 IS INITIAL
            AND desc44 IS INITIAL.
           DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
           IF g_mat_fnd = 0.
             g_mat_fnd_flag = 'X'.
           ENDIF.
         ENDIF.
       WHEN '3'.
         IF check_pos = 3
            AND desc44 IS INITIAL.
           DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
           IF g_mat_fnd = 0.
             g_mat_fnd_flag = 'X'.
           ENDIF.
         ENDIF.
       WHEN '4'.
         IF check_pos = 4. .
           DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
           IF g_mat_fnd = 0.
             g_mat_fnd_flag = 'X'.
           ENDIF.
         ENDIF.
         IF g_hits_par_oth = 'X'.
           DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
           IF g_mat_fnd = 0.
             g_mat_fnd_flag = 'X'.
           ENDIF.
           CLEAR g_hits_par_oth.
         ENDIF.
       WHEN OTHERS.
         CLEAR g_mat_fnd.

     ENDCASE.

     IF g_lineno_old <> g_lineno.
*     clear g_mat_fnd.
       do_not_change_flag = 'X'.
     ENDIF.

     CLEAR g_hits_par.

   ENDIF.

   LOOP AT ist_srchlp INTO wa_srchlp.

     DATA : l_matnr LIKE thead-tdname.
     l_matnr = wa_srchlp-matnr.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*        CLIENT                  = SY-MANDT
         id                      = 'BEST'
         language                = 'E'
         name                    = l_matnr
         object                  = 'MATERIAL'
       TABLES
         lines                   = lines
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       wa_srchlp-mark = '1'.
       MODIFY ist_srchlp FROM wa_srchlp.
     ENDIF.

   ENDLOOP.

 ENDFORM.                    " SELECT_MATERIAL_DETAILS
*&---------------------------------------------------------------------*
*&      Form  Display_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM Display_text.

   DATA : l_matnr LIKE thead-tdname.
   DATA : l_header LIKE thead.
   DATA : i LIKE sy-tabix.
   READ TABLE ist_srchlp INTO wa_srchlp INDEX g_curr_line_100.
   l_matnr = wa_srchlp-matnr.

*  if not l_matnr is initial.
   IF NOT l_matnr IS INITIAL AND
     g_curr_line_100 <> 0.
     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*        CLIENT                  = SY-MANDT
         id                      = 'BEST'
         language                = 'E'
         name                    = l_matnr
         object                  = 'MATERIAL'
*        ARCHIVE_HANDLE          = 0
*        LOCAL_CAT               = ' '
* IMPORTING
*        HEADER                  =
       TABLES
         lines                   = tlinetab
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

       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     ENDIF.


     CALL SCREEN 117 STARTING AT 70 15 ENDING AT 130 24.

   ENDIF.

 ENDFORM.                    " Display_text
*&---------------------------------------------------------------------*
*&      Form  text_control_eingabebereit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM text_control_eingabebereit.

   CALL METHOD gv_text_editor->set_readonly_mode
     EXPORTING
       readonly_mode          = gv_text_editor->true
     EXCEPTIONS
       error_cntl_call_method = 1
       invalid_parameter      = 2
       OTHERS                 = 3.



 ENDFORM.                    " text_control_eingabebereit
*&---------------------------------------------------------------------*
*&      Form  text_control_set_text_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM text_control_set_text_table.

   CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
     TABLES
       itf_text    = tlinetab
       text_stream = lt_text_table.

   CALL METHOD gv_text_editor->set_text_as_stream
     EXPORTING
       text            = lt_text_table
     EXCEPTIONS
       error_dp        = 1
       error_dp_create = 2
       OTHERS          = 3.


 ENDFORM.                    " text_control_set_text_table


*&---------------------------------------------------------------------*
*&      Form  clear_srchlp_parms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM clear_srchlp_parms.

   CLEAR : desc11, desc22, desc33, desc44, desc55, g_partno, g_matgp,
           g_matty, sel_flag.

 ENDFORM.                    " clear_srchlp_parms
*&---------------------------------------------------------------------*
*&      Form  Create_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM create_matcode.

   DATA : l_num1 TYPE sy-index.
   DATA : l_num2(3) TYPE c.



   PERFORM matcode_confirm.

   CHECK a_choice = 'J'.

   DO 26 TIMES.

     it_alpha_num1-alpha = alpha+l_num1(1).
     l_num2 = l_num2 + 10.

     IF l_num2 < 100.
       CONCATENATE '0' l_num2 INTO l_num2.
     ENDIF.
     it_alpha_num1-number = l_num2.
     l_num1 = l_num1 + 1.
     APPEND it_alpha_num1.
   ENDDO.

   CASE zmm_cdhd_st-mtart.

     WHEN 'ZSTO'.

       DATA : l_mat_len LIKE sy-index.
       DATA : l_desc(87) TYPE c.
       DATA : l_desc1(40) TYPE c, l_desc2(48) TYPE c.

       LOOP AT g_TABCTRL110_itab
              INTO g_TABCTRL110_wa.

*        if      g_TABCTRL110_wa-oth1 = 'X'
*             or g_TABCTRL110_wa-oth2 = 'X'
*             or g_TABCTRL110_wa-oth3 = 'X'
*             or g_TABCTRL110_wa-oth4 = 'X'.
*          check_others = 'X'.
*        endif.

         IF ( g_TABCTRL110_wa-matcode IS INITIAL
                 OR g_TABCTRL110_wa-matcode = '000000000' )
*                and check_others <> 'X'
                 AND g_TABCTRL110_wa-comp_flg IS INITIAL
                 AND g_tabctrl110_wa-rej_flg  IS INITIAL.

           l_desc = g_TABCTRL110_wa-desc_fin.
           l_mat_len = strlen( l_desc ).

           IF l_mat_len <= 40 .

             l_desc1 = l_desc.

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             CLEAR l_desc2.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ELSE.

             l_desc1 = l_desc+0(39).
             CONCATENATE l_desc1 '*' INTO l_desc1.
             l_desc2 = l_desc+39(48).

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ENDIF.

           seltab-selname = 'P_UOM'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABCTRL110_wa-uom.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATKL'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABCTRL110_wa-matgp.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MTART'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = zmm_cdhd_st-mtart.
           APPEND seltab TO ist_seltab.

           SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
           GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABCTRL110_wa-matcode.
           IF g_TABCTRL110_wa-matcode IS INITIAL
              OR g_TABCTRL110_wa-matcode = '000000000'.
             g_TABCTRL110_wa-comp_flg = 'E'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'E'.
             g_TABCTRL110_wa-rsn = wa_rsn-description.
           ELSE.
             matgen_flag = 'X'.
             g_TABCTRL110_wa-comp_flg = 'N'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'N'.
             g_TABCTRL110_wa-rsn = wa_rsn-description.
***********************************************************************
             DATA: l_srno LIKE zmm_cditem-srno.
             CLEAR ist_textid.
             MOVE g_TABCTRL110_wa-srno TO l_srno.
             CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
             INTO ist_textid-tdname.

             ist_textid-tdobject   = 'ZMMCD'.
             ist_textid-tdid       = 'CDDS'.
             ist_textid-tdspras    =  sy-langu.
             ist_textid-tdlinesize =  72.
***Appending to internal table for all textid/name.
             APPEND ist_textid TO ist_textid_items.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

             PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.

             CLEAR : wa_textid.

             wa_textid-tdname   = g_TABCTRL110_wa-matcode.
             wa_textid-tdid     = 'BEST'.
             wa_textid-tdspras  = 'E'.
             wa_textid-tdobject = 'MATERIAL'.

             PERFORM save_text.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

**********************************************************************

           ENDIF.
           MODIFY g_TABCTRL110_itab FROM g_TABCTRL110_wa.
           CLEAR g_TABCTRL110_wa-comp_flg.

           CLEAR seltab.
           REFRESH ist_seltab.
         ENDIF.

***********************************************************************
*
*       if check_others = 'X'.
*                  g_TABCTRL110_wa-comp_flg = 'E'.
*                  select single * from ZMM_CODREQ_RSN into wa_rsn
*                  where reason = 'E'.
*                  g_TABCTRL110_wa-rsn = wa_rsn-description.
*
*          modify g_TABCTRL110_itab from g_TABCTRL110_wa.
*
*          clear g_TABCTRL110_wa-comp_flg.
*
*                  clear check_others.
*
*       endif.
*
**********************************************************************
         CLEAR : g_TABCTRL110_wa-comp_flg,
                 g_TABCTRL110_wa-rsn.
       ENDLOOP.

     WHEN 'ZSPR'.

       DATA : l_mpartno_len LIKE sy-index.
       DATA : l_mpartno LIKE g_TABLCTRL120_wa-partno.
       DATA : l_mpartno1(30) TYPE c.
       DATA : l_mpartno2(10) TYPE c.
       DATA : l_mfgname(30) TYPE c.

       LOOP AT g_TABLCTRL120_itab
                INTO g_TABLCTRL120_wa.


         IF ( g_TABLCTRL120_wa-matcode IS INITIAL
                   OR g_TABLCTRL120_wa-matcode = '000000000' )
*                and check_others <> 'X'
                   AND g_TABLCTRL120_wa-comp_flg IS INITIAL
                   AND g_tablctrl120_wa-rej_flg  IS INITIAL.

           l_mpartno = g_TABLCTRL120_wa-partno.
           l_desc = g_TABLCTRL120_wa-desc_fin.
           l_mpartno_len = strlen( l_mpartno ).
           l_mat_len = strlen( l_desc ).

           IF l_mat_len <= 40 .

             l_desc1 = l_desc.

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             CLEAR l_desc2.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ELSE.

             l_desc1 = l_desc+0(39).
             CONCATENATE l_desc1 '*' INTO l_desc1.
             l_desc2 = l_desc+39(48).

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ENDIF.

           seltab-selname = 'P_UOM'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-uom.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATKL'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-matgp.
           APPEND seltab TO ist_seltab.

           SELECT SINGLE name1 FROM lfa1 INTO l_mfgname
                  WHERE lifnr = g_TABLCTRL120_wa-manu.

           seltab-selname = 'P_MFGNME'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = l_mfgname.
           APPEND seltab TO ist_seltab.
*
           seltab-selname = 'P_MFGCDE'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-manu.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_CPCDE'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-cap_code.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_CPCDED'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-cap_name.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MDLCDE'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-mdlno.
           APPEND seltab TO ist_seltab.


           IF l_mpartno_len <= 30.

             l_mpartno1 = l_mpartno.

             seltab-selname = 'P_MPRTN1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_mpartno1.
             APPEND seltab TO ist_seltab.

             l_mpartno2 = ''.

           ELSE.

             l_mpartno1 = l_mpartno.

             seltab-selname = 'P_MPRTN2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_mpartno1.
             APPEND seltab TO ist_seltab.

             l_mpartno2 = l_mpartno+30(10).

             seltab-selname = 'P_MPRTN2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_mpartno2.
             APPEND seltab TO ist_seltab.

           ENDIF.

           seltab-selname = 'P_MPRTN'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = l_mpartno.
           APPEND seltab TO ist_seltab.

*          seltab-selname = 'P_MCODE'.
*          seltab-sign    = 'I'.
*          seltab-option = 'EQ'.
*          seltab-low   = g_TABLCTRL120_wa-matgp.
*          append seltab to ist_seltab.

           seltab-selname = 'P_DESC'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL120_wa-desc_fin.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MTART'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = zmm_cdhd_st-mtart.
           APPEND seltab TO ist_seltab.


           SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
           GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABLCTRL120_wa-matcode.
           IF g_TABLCTRL120_wa-matcode IS INITIAL
              OR g_TABLCTRL120_wa-matcode = '000000000'.
             g_TABLCTRL120_wa-comp_flg = 'E'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'E'.
             g_TABLCTRL120_wa-rsn = wa_rsn-description.
           ELSE.
             matgen_flag = 'X'.
             g_TABLCTRL120_wa-comp_flg = 'N'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'N'.
             g_TABLCTRL120_wa-rsn = wa_rsn-description.
***********************************************************************
*            Data: l_srno like ZMM_CDITEM-SRNO.
             CLEAR ist_textid.
             MOVE g_TABLCTRL120_wa-srno TO l_srno.
             CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
             INTO ist_textid-tdname.

             ist_textid-tdobject   = 'ZMMCD'.
             ist_textid-tdid       = 'CDDS'.
             ist_textid-tdspras    =  sy-langu.
             ist_textid-tdlinesize =  72.
***Appending to internal table for all textid/name.
             APPEND ist_textid TO ist_textid_items.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

             PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
             CLEAR : wa_textid.

             wa_textid-tdname   = g_TABLCTRL120_wa-matcode.
             wa_textid-tdid     = 'BEST'.
             wa_textid-tdspras  = 'E'.
             wa_textid-tdobject = 'MATERIAL'.

             PERFORM save_text.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

**********************************************************************

           ENDIF.
           MODIFY g_TABLCTRL120_itab FROM g_TABLCTRL120_wa.
           CLEAR g_TABLCTRL120_wa-comp_flg.

           CLEAR seltab.
           REFRESH ist_seltab.
         ENDIF.
         CLEAR : g_TABLCTRL120_wa-comp_flg,
         g_TABLCTRL120_wa-rsn.
       ENDLOOP.

     WHEN 'ZCAP'.

       DATA : l_matcost(15) TYPE c.

       LOOP AT g_TABLCTRL130_itab
                INTO g_TABLCTRL130_wa.


         IF ( g_TABLCTRL130_wa-matcode IS INITIAL
                   OR g_TABLCTRL130_wa-matcode = '000000000' )
*                and check_others <> 'X'
                   AND g_TABLCTRL130_wa-comp_flg IS INITIAL
                   AND g_tablctrl130_wa-rej_flg  IS INITIAL.

           l_desc = g_TABLCTRL130_wa-desc_fin.
           l_mat_len = strlen( l_desc ).

           IF l_mat_len <= 40 .

             l_desc1 = l_desc.

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             CLEAR l_desc2.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ELSE.

             l_desc1 = l_desc+0(39).
             CONCATENATE l_desc1 '*' INTO l_desc1.
             l_desc2 = l_desc+39(48).

             seltab-selname = 'P_DESC1'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc1.
             APPEND seltab TO ist_seltab.

             seltab-selname = 'P_DESC2'.
             seltab-sign    = 'I'.
             seltab-option = 'EQ'.
             seltab-low   = l_desc2.
             APPEND seltab TO ist_seltab.

           ENDIF.

           seltab-selname = 'P_UOM'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-uom.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATKL'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = '0C'.
           APPEND seltab TO ist_seltab.


           l_matcost = g_TABLCTRL130_wa-matcost.

           seltab-selname = 'P_MATCOS'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = l_matcost.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATCAT'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-matcatg.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATLOC'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-matloc.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_WKLIFE'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-wrkng_life.

           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MATGP'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-spa_grp.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_DESC'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = g_TABLCTRL130_wa-desc_fin.
           APPEND seltab TO ist_seltab.

           seltab-selname = 'P_MTART'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = zmm_cdhd_st-mtart.
           APPEND seltab TO ist_seltab.

           DATA : l_matnr(8) TYPE c.
           DATA : rcode_number_get LIKE inri-returncode.
           DATA : matnr LIKE mara-matnr.
           DATA : l_number_range LIKE it_cap_group1-number_range.



           SELECT * FROM zmm_cap_group INTO TABLE it_cap_group1
                  WHERE description = g_TABLCTRL130_wa-matcatg.

           IF sy-subrc = 0.
             SORT it_cap_group1 BY number_range description ASCENDING.
             LOOP AT it_cap_group1.
               IF it_cap_group1-used_flag = 'X'.
                 CONTINUE.
               ELSE.
                 EXIT.
               ENDIF.
             ENDLOOP.
           ENDIF.

           l_number_range = it_cap_group1-number_range.

           DO.

             CALL FUNCTION 'NUMBER_GET_NEXT'
               EXPORTING
                 nr_range_nr = l_number_range
                 object      = 'ZMATERIALC'
               IMPORTING
                 number      = l_matnr
                 returncode  = rcode_number_get.

             DATA : l_alphaa TYPE c.
             DATA : l_char2(2) TYPE c.
             DATA : l_char3(3) TYPE c.

             l_char3 = l_matnr+2(3).

             READ TABLE it_alpha_num1 WITH KEY number = l_char3.
             l_alphaa = it_alpha_num1-alpha.

             l_char2 = l_matnr+2(2).

             IF l_char2 EQ '00'.

               CONCATENATE '0C' l_matnr+4(4) '000' INTO matnr.

             ELSE.

               CONCATENATE '0C' l_alphaa l_matnr+5(3) '000' INTO matnr.

             ENDIF.

             CALL FUNCTION 'MARA_SINGLE_READ'
               EXPORTING
                 matnr      = matnr
                 sperrmodus = ' '
               IMPORTING
                 wmara      = mara
               EXCEPTIONS
                 not_found  = 4
                 OTHERS     = 5.

             IF sy-subrc EQ 0.
               CONTINUE.
             ELSE.
               EXIT.
             ENDIF.

           ENDDO.

           seltab-selname = 'P_MATNR'.
           seltab-sign    = 'I'.
           seltab-option = 'EQ'.
           seltab-low   = matnr.
           APPEND seltab TO ist_seltab.

           SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
           GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABLCTRL130_wa-matcode.
           IF g_TABLCTRL130_wa-matcode IS INITIAL
              OR g_TABLCTRL130_wa-matcode = '000000000'.
             g_TABLCTRL130_wa-comp_flg = 'E'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'E'.
             g_TABLCTRL130_wa-rsn = wa_rsn-description.
           ELSE.
             matgen_flag = 'X'.
             g_TABLCTRL130_wa-comp_flg = 'N'.
             SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
             WHERE reason = 'N'.
             g_TABLCTRL130_wa-rsn = wa_rsn-description.
***********************************************************************
*            Data: l_srno like ZMM_CDITEM-SRNO.
             CLEAR ist_textid.
             MOVE g_TABLCTRL130_wa-srno TO l_srno.
             CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
             INTO ist_textid-tdname.

             ist_textid-tdobject   = 'ZMMCD'.
             ist_textid-tdid       = 'CDDS'.
             ist_textid-tdspras    =  sy-langu.
             ist_textid-tdlinesize =  72.
***Appending to internal table for all textid/name.
             APPEND ist_textid TO ist_textid_items.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

             PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
             CLEAR : wa_textid.

             wa_textid-tdname   = g_TABLCTRL130_wa-matcode.
             wa_textid-tdid     = 'BEST'.
             wa_textid-tdspras  = 'E'.
             wa_textid-tdobject = 'MATERIAL'.

             PERFORM save_text.

             CLEAR   : ist_dtspecs.
             REFRESH : ist_dtspecs.

**********************************************************************

           ENDIF.
           MODIFY g_TABLCTRL130_itab FROM g_TABLCTRL130_wa.
           CLEAR g_TABLCTRL130_wa-comp_flg.

           CLEAR seltab.
           REFRESH ist_seltab.
         ENDIF.
         CLEAR : g_TABLCTRL130_wa-comp_flg,
         g_TABLCTRL130_wa-rsn.
       ENDLOOP.

   ENDCASE.

   PERFORM save_request.

 ENDFORM.                    " Create_matcode
*&---------------------------------------------------------------------*
*&      Form  update_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_release.
   UPDATE zmm_cdhd SET status_flag = 'X'
   WHERE reqno = zmm_cdhd_st-reqno.
   MESSAGE i019(zmm_oth) WITH zmm_cdhd_st-reqno.
   PERFORM save_cors_text.
   PERFORM clear_var.

 ENDFORM.                    " update_approval
*&---------------------------------------------------------------------*
*&      Form  Insert_modif
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM Insert_modif.
   CLEAR zmm_modifier.
   READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa WITH KEY flag = 'X'.

   IF sy-subrc = 0.
     IF ( g_tabctrl110_wa-oth1 = 'X' OR
          g_tabctrl110_wa-oth2 = 'X' OR
          g_tabctrl110_wa-oth3 = 'X' OR
          g_tabctrl110_wa-oth4 = 'X' ) AND
           g_tabctrl110_wa-comp_flg+0(1) <> 'S'.

       MOVE: g_tabctrl110_wa-matgp TO zmm_modifier-matgrp,
             g_tabctrl110_wa-desc1 TO zmm_modifier-desc1,
             g_tabctrl110_wa-desc2 TO zmm_modifier-desc2,
             g_tabctrl110_wa-desc3 TO zmm_modifier-desc3,
             g_tabctrl110_wa-desc4 TO zmm_modifier-desc4,
             sy-uname              TO zmm_modifier-created_by,
             sy-datum              TO zmm_modifier-create_date.
       INSERT INTO zmm_modifier VALUES zmm_modifier.
*         g_tabctrl110_wa-oth1 = '' .
*         g_tabctrl110_wa-oth2 = '' .
*         g_tabctrl110_wa-oth3 = '' .
*      concatenate zmm_modifier-desc1 modif_list
       REPLACE 'M' WITH '' INTO g_tabctrl110_wa-comp_flg .

       MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
       TRANSPORTING comp_flg.
       CALL FUNCTION 'POPUP_TO_DISPLAY_VALUE'
         EXPORTING
           colbeg    = 1
           colend    = 5
           itemtxt   = 'Following modifiers inserted'
           textline1 = zmm_modifier-desc1
           textline2 = zmm_modifier-desc2
           textline3 = zmm_modifier-desc3
           textline4 = zmm_modifier-desc4
           title     = 'Modifiers inserted'.

*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TITEL        = 'Insert Modifiers '
*                TEXTLINE1    = 'Following Modifiers inserted.'
*                TEXTLINE2    =
*                START_COLUMN = 25
*                START_ROW    = 6.
     ELSE.
       MESSAGE i035(zmm_oth).
     ENDIF.
   ELSE.
     MESSAGE i040(zmm_oth).
   ENDIF.
 ENDFORM.                    " Insert_modif
*&---------------------------------------------------------------------*
*&      Form  reset_other
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM reset_other.
   IF g_ok_code115 <> 'CANC'.
     CASE 'OTHER'.
       WHEN g_TABCTRL110_wa-desc1.
         CLEAR : g_TABCTRL110_wa-desc1,
                 g_TABCTRL110_wa-oth1,
                 g_TABCTRL110_wa-matgp.

       WHEN g_TABCTRL110_wa-desc2.
         CLEAR: g_TABCTRL110_wa-desc2,
                g_TABCTRL110_wa-oth2.

       WHEN g_TABCTRL110_wa-desc3.
         CLEAR: g_TABCTRL110_wa-desc3,
                g_TABCTRL110_wa-oth3.

       WHEN g_TABCTRL110_wa-desc4.
         CLEAR: g_TABCTRL110_wa-desc4,
                g_TABCTRL110_wa-oth2 .
     ENDCASE.
*+1105
   ELSE.
     CASE 'OTHER'.
       WHEN g_TABCTRL110_wa-desc1.
         CLEAR : g_TABCTRL110_wa-desc1,
                 g_TABCTRL110_wa-oth1.
       WHEN g_TABCTRL110_wa-desc2.
         CLEAR: g_TABCTRL110_wa-desc2,
                g_TABCTRL110_wa-oth2.

       WHEN g_TABCTRL110_wa-desc3.
         CLEAR: g_TABCTRL110_wa-desc3,
                g_TABCTRL110_wa-oth3.

       WHEN g_TABCTRL110_wa-desc4.
         CLEAR: g_TABCTRL110_wa-desc4,
                g_TABCTRL110_wa-oth2 .
     ENDCASE.
*-1105
   ENDIF.
 ENDFORM.                    " reset_other
*&---------------------------------------------------------------------*
*&      Form  other_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM other_check.
   IF sy-ucomm <> 'CANC' . "X in toolbar of modal screen
     CASE 'X'.
       WHEN g_TABCTRL110_wa-oth1.
         IF g_desc1 = '' OR
            g_desc2 = ''.
           MESSAGE e007(zmm_oth) WITH 'DESC1' 'DESC2'.
*      elseif g_desc4 <> '' and g_desc3 = ''.
*        message e003(ZMM_OTH) with 'DESC1' 'DESC2'.
         ENDIF.
         IF g_desc4 <> ''.
           IF g_desc3 = ''.
             MESSAGE e007(zmm_oth).
           ENDIF.
         ENDIF.

       WHEN g_TABCTRL110_wa-oth2.
         IF g_desc2 IS INITIAL.
           MESSAGE e007(zmm_oth) WITH 'DESC2'.
         ENDIF.
         IF g_desc4 <> ''.
           IF g_desc3 = ''.
             MESSAGE e007(zmm_oth).
           ENDIF.
         ENDIF.
       WHEN g_TABCTRL110_wa-oth3.
         IF g_desc3 IS INITIAL.
           MESSAGE e007(zmm_oth) WITH 'DESC3'.
         ENDIF.
       WHEN g_TABCTRL110_wa-oth4.
         IF g_desc4 IS INITIAL.
           MESSAGE e007(zmm_oth) WITH 'DESC4'.
         ENDIF.
     ENDCASE.
   ENDIF.


 ENDFORM.                    " other_check
*****************************************************
 FORM find_user.
*****************************************************
*clear g_user.
*

*Data : auth_field1(2) Value 'IM', auth_field2(2) value 'L2'.

   AUTHORITY-CHECK OBJECT 'ZMM_CD'
                       ID 'ZMM_CODIFR' FIELD '01'.
   IF sy-subrc = 0 .
     g_user = 'X'.  "Codifier.
   ELSE.
* MRP CONTROLLER AUTH CHECK.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                         ID 'FRGCO' FIELD '02'.

*                        ACTVT WERKS '01'.
*                        ID 'FRGGR' FIELD '02'.

     IF sy-subrc = 0.
       g_user = 'M'.
     ELSE.
       AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                          ID 'FRGCO' FIELD : 'L2',
                                             'L1',
                                             'HS',
                                             'HL',
                                             'HC',
                                             '1A',
                                             '1B',
                                             '1C',
                                             '1D',
                                             '1E',
                                             '1F',
                                             'DI',
                                             'DF',
                                             'CS',
                                             'BO',
                                             'MD',
                                             'EC'.

       IF sy-subrc = 0.
         g_user = 'L'.
       ELSE.
         g_user = ''.
       ENDIF.
     ENDIF.
   ENDIF.


*
   g_user_found = 'X'.
*if g_mode = 'REL'.
*select single * from agr_users where uname = sy-uname and agr_name =
*'D:MM_MAT_IND_APPROVE_02'.
*
*if sy-subrc = 0.
*   g_user = 'M'.
*else.
*   select single * from agr_users where uname = sy-uname and agr_name =
*   'D:MM_SRV_IND_APPROVE_L2'.
*   if sy-subrc = 0.
*       g_user = 'L'.
*   endif.
*Endif.
*Endif.

*
 ENDFORM.                    " find_user
*********************************************************************
 FORM check_modi.
* Check for existing modifiers
   SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1.
   IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc1 = 'OTHER' OR
                         g_tabctrl110_wa-oth1 = 'X' ) .
     LOOP AT SCREEN.
       screen-input = 0.
       MODIFY SCREEN.
     ENDLOOP.
     g_modi_exists = 'X'.
     MESSAGE e010(zmm_oth) WITH 'Desc1' g_desc1 .
   ELSE.
     SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND desc2 =
      g_desc2.
     IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc2 = 'OTHER'  OR
                          g_tabctrl110_wa-oth2 = 'X' ) .

       LOOP AT SCREEN.
         screen-input = 0.
         MODIFY SCREEN.
       ENDLOOP.

       MESSAGE e010(zmm_oth) WITH  'Desc2' g_desc2.
     ELSE.
       SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND desc2 =
                g_desc2 AND desc3 = g_desc3.
       IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc3 = 'OTHER' OR
                             g_tabctrl110_wa-oth3 = 'X' ) .

         LOOP AT SCREEN.
           screen-input = 0.
           MODIFY SCREEN.
         ENDLOOP.
         MESSAGE e010(zmm_oth) WITH  'Desc3' g_desc3.
       ELSE.
         SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND
         desc2 = g_desc2 AND desc3 = g_desc3 AND desc4 = g_desc4.
         IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc4 = 'OTHER'  OR
                               g_tabctrl110_wa-oth4 = 'X' ) .

           LOOP AT SCREEN.
             screen-input = 0.
             MODIFY SCREEN.
           ENDLOOP.
           MESSAGE e010(zmm_oth) WITH 'Desc4' g_desc4 .
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  Spell_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM Spell_check.
   DATA : l_ans.
*clear ist_spell_line.
*if G_USER = '' Or G_USER = 'X'.
*   concatenate g_desc1 g_desc2 g_desc3 g_desc4 g_user_desc
*   into ist_spell_line-tdline separated by space.
*Else.
*   concatenate g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
*    g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
*    g_tabctrl110_wa-user_desc into ist_spell_line-tdline separated by
*    space.
*Endif.
*   append ist_spell_line.
   IF NOT ist_spell_line[] IS INITIAL.
     EXPORT g_user TO MEMORY ID 'G_USER1' .
     EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.

     CALL FUNCTION 'ZSPELL_CHECK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_spell_line.
     IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
     IF NOT checktab[] IS INITIAL.

       MESSAGE i017(Zmm_oth).
       PERFORM spell_error_lines.
     ELSE.
       MESSAGE i008(Zmm_oth).
       LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
         IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
           REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
           g_tabctrl110_wa-rsn      = ''.
           MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
             TRANSPORTING comp_flg rsn.
         ENDIF.
       ENDLOOP.


     ENDIF.

     IF g_user = ''.
       IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
       IF NOT checktab[] IS INITIAL.
         " Begin of <RD1K960036>.
*         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*            EXPORTING
**        DEFAULTOPTION        = 'Y'
*    TEXTLINE1 = 'There are spelling errors in description(s)'
*           TEXTLINE2            = 'Proceed with errors? '
*            TITEL                = 'Spelling Errors'
**                  START_COLUMN         = 25
**                  START_ROW            = 6
**                  CANCEL_DISPLAY       = 'X'
*           IMPORTING
*              ANSWER               = l_ans.

         DATA : l_answer(1) TYPE c.



         CALL FUNCTION 'POPUP_TO_CONFIRM'
           EXPORTING
             titlebar              = 'Spelling Errors'
             text_question         = 'There are spelling errors in description(s) Proceed with errors?'
             text_button_1         = 'Yes'
             text_button_2         = 'No'
             default_button        = '1'
             display_cancel_button = 'X'
             start_column          = 25
             start_row             = 6
           IMPORTING
             answer                = l_answer
           EXCEPTIONS
             text_not_found        = 1
             OTHERS                = 2.
         IF sy-subrc = 0.
           CASE l_answer.
             WHEN '1'.
               MOVE 'J' TO l_ans.
             WHEN '2'.
               MOVE 'N' TO l_ans.
           ENDCASE.
         ENDIF.

         " End of <RD1K960036>.


         IF l_ans = 'J'.
           PERFORM spell_error_lines.
           CLEAR : g_screen115_1st,user_desc_len.
           g_other = 'X'.
           g_spellerror = ''.
*           FREE MEMORY ID 'G_SPELL'.
           g_modi_exists = ''.
           LEAVE TO SCREEN 0.
         ELSE.
           LOOP AT SCREEN.
             IF screen-name = 'G_DESC1' OR
                screen-name = 'G_DESC2' OR
                screen-name = 'G_DESC3' OR
                screen-name = 'G_DESC4'.
               screen-input = 1.
               MODIFY SCREEN.
             ENDIF.
           ENDLOOP.
         ENDIF.
       ELSE.
         CLEAR : g_screen115_1st,user_desc_len.
         g_other = 'X'.
         g_spellerror = ''.
         g_modi_exists = ''.
*      FREE MEMORY ID 'G_SPELL'.
         LEAVE TO SCREEN 0.
       ENDIF.
     ENDIF.
   ELSE.
     MESSAGE i008(Zmm_oth).
     LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
       IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
         g_tabctrl110_wa-rsn      = ''.
         MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
           TRANSPORTING comp_flg rsn.
       ENDIF.
     ENDLOOP.

   ENDIF.
 ENDFORM.                    " Spell_check
*&---------------------------------------------------------------------*
*&      Module  spell_check1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE spell_check1 INPUT.
 FORM spell_check1.
*+

   DATA : ok_code110 LIKE sy-ucomm.
**
   ok_code110 = Sy-ucomm.
   CLEAR sy-ucomm.
   CLEAR ist_spell_line.
   REFRESH ist_spell_line.
**
   IF ok_code110 = 'SPELL' OR
      Check_code = 'CHECK'.
     READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa WITH KEY
     flag = 'X' .
     IF sy-subrc = 0.
       g_curr_line1 = sy-tabix.
       IF  g_TABCTRL110_wa-oth1  = 'X'.

         CONCATENATE g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
         g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
         BY space.

       ELSEIF g_TABCTRL110_wa-oth2 = 'X'.
         CONCATENATE g_tabctrl110_wa-desc2
         g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
         BY space.

       ELSEIF g_TABCTRL110_wa-oth3 = 'X'.
         CONCATENATE g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
         BY space.


       ELSEIF g_TABCTRL110_wa-oth4 = 'X'.
         CONCATENATE g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
         BY space.

       ELSE.
         ist_spell_line-tdline = g_tabctrl110_wa-user_desc.
       ENDIF.

       APPEND ist_spell_line.
       PERFORM Spell_check.
       CLEAR:sy-ucomm,ok_code110.
     ELSE.
       LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
         CASE 'X'.
           WHEN g_TABCTRL110_wa-oth1.
             CONCATENATE g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
             g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
             BY space.
             ist_spell_line-srno = g_tabctrl110_wa-srno.
             APPEND ist_spell_line.
             CONTINUE.
           WHEN g_TABCTRL110_wa-oth2.
             CONCATENATE g_tabctrl110_wa-desc2
             g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
             BY space.
             ist_spell_line-srno = g_tabctrl110_wa-srno.
             APPEND ist_spell_line.
             CONTINUE.

           WHEN g_TABCTRL110_wa-oth3.
             CONCATENATE g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
             BY space.
             ist_spell_line-srno = g_tabctrl110_wa-srno.
             APPEND ist_spell_line.
             CONTINUE.

           WHEN g_TABCTRL110_wa-oth4.
             CONCATENATE g_tabctrl110_wa-desc4
         g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
             BY space.
             ist_spell_line-srno = g_tabctrl110_wa-srno.
             APPEND ist_spell_line.
             CONTINUE.

           WHEN OTHERS.
             IF NOT g_tabctrl110_wa-user_desc IS INITIAL.
               ist_spell_line-tdline = g_tabctrl110_wa-user_desc .
               ist_spell_line-srno   = g_tabctrl110_wa-srno.
               APPEND ist_spell_line.
             ENDIF.
             CONTINUE.
         ENDCASE.
       ENDLOOP.
       CLEAR:sy-ucomm,ok_code110.

*     Export ist_spell_line to memory id 'SPELL'.
       ist_spell_line1[] = ist_spell_line[].
       PERFORM Spell_check.

     ENDIF.
   ELSE.

   ENDIF.

 ENDFORM.
*ENDMODULE.                 " spell_check1  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_Other  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE change_Other INPUT.
   IF sy-ucomm = 'DBCLICK' AND g_mode = 'CHA'.
*   Read table tabctrl110_itab index g_currline.
   ENDIF.
 ENDMODULE.                 " change_Other  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_user  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE get_user OUTPUT.
   IF g_user_found = ''.
     PERFORM find_user.
   ENDIF.
***
   IF g_mode = 'APR'.
     IF g_user = 'M' OR
        g_user = 'L'.
**      do nothing.
     ELSE.
       MESSAGE e057(zmm_oth).
     ENDIF.
   ENDIF.
***
   IF sy-tcode = 'ZCODG'.
     GET PARAMETER ID 'ZREQNO' FIELD zmm_cdhd_st-reqno.
   ENDIF.

 ENDMODULE.                 " get_user  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  change_Rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM change_Rel.
   DATA : l_ans.
   CHECK g_mode <> 'CHE'.
   IF zmm_cdhd_st-status_flag = 'X' AND g_mode = 'CHA'. " and g_user =
     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*        DEFAULTOPTION        = 'N'
*         TEXTLINE1            = 'Release will be reset. Proceed ?'
**         TEXTLINE2            = ' '
*         TITEL                = 'Release Reset'
**         START_COLUMN         = 25
**         START_ROW            = 6
**         CANCEL_DISPLAY       = 'X'
*    IMPORTING
*        ANSWER               = l_ans.

     DATA : l_answer(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'Release Reset '
         text_question         = 'Release will be reset. Proceed ?'
         default_button        = '2'
         display_cancel_button = 'X'
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_answer
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.
     IF sy-subrc = 0.
       CASE l_answer.
         WHEN '1'.
           MOVE 'J' TO l_ans.
         WHEN '2'.
           MOVE 'N' TO l_ans.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.


     IF l_ans = 'J'.
       zmm_cdhd_st-status_flag = ''.
       zmm_cdhd_st-approve_mrp = ''.
       zmm_cdhd_st-approve_l2 = ''.
     ELSE.
       PERFORM clear_var.
       LEAVE TO SCREEN 100.
     ENDIF.
   ENDIF.
 ENDFORM.                    " change_Rel
*&---------------------------------------------------------------------*
*&      Form  Change_Restrict
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_CDHD  text
*----------------------------------------------------------------------*
 FORM Change_Restrict1.
   DATA : l_ans.
   IF sy-uname <> zmm_cdhd_st-reqcpf AND g_user = ''.
     CASE g_mode.
       WHEN 'CHA' OR 'REL'.
         MESSAGE i020(zmm_oth).
         PERFORM Clear_var.
         LEAVE TO SCREEN 100.
     ENDCASE.
   ENDIF.
*Else.
   IF zmm_cdhd_st-status_flag = 'X' AND g_mode = 'CHA'..
     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*        DEFAULTOPTION        = 'N'
*         TEXTLINE1            = 'Release will be reset. Proceed ?'
**         TEXTLINE2            = ' '
*         TITEL                = 'Release Reset'
**         START_COLUMN         = 25
**         START_ROW            = 6
**         CANCEL_DISPLAY       = 'X'
*    IMPORTING
*        ANSWER               = l_ans.
     DATA : l_answer(1) TYPE c.


     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'Release Reset '
         text_question         = 'Release will be reset. Proceed ?'
         default_button        = '2'
         display_cancel_button = 'X'
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_answer
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.

     IF sy-subrc = 0.
       CASE l_answer.
         WHEN '1'.
           MOVE 'J' TO l_ans.
         WHEN '2'.
           MOVE 'N' TO l_ans.
       ENDCASE.
     ENDIF.

     " End of <RD1K960036>.

     IF l_ans = 'J'.
       zmm_cdhd_st-status_flag = ''.
       zmm_cdhd_st-approve_mrp = ''.
       zmm_cdhd_st-approve_l2 = ''.
     ELSE.
       PERFORM clear_var.
       LEAVE TO SCREEN 100.
     ENDIF.
   ENDIF.
 ENDFORM.                    " Change_Restrict
*&---------------------------------------------------------------------*
*&      Form  update_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_approval.
   CASE g_user.
     WHEN 'M'.
       IF zmm_cdhd_st-approve_mrp <> ''.
         UPDATE zmm_cdhd SET Approve_mrp = 'X'
                             appdate     = sy-datum
                             appcpf      = sy-uname
                             WHERE reqno = zmm_cdhd_st-reqno.
*Addition********************************
**To check, if the mail has to be send after Tech Auth Approval.
         READ TABLE ist_zmm_cditem WITH KEY oth1 = 'X'.
         IF sy-subrc <> 0.
           PERFORM send_mail_to_cdcell.
           IF zmm_cdhd_st-reqcl <> 'N'.
             MOVE 'IC' TO zmm_cdhd_st-reqcl.
             UPDATE zmm_cdhd SET reqcl = zmm_cdhd_st-reqcl
                          WHERE reqno = zmm_cdhd_st-reqno.
           ENDIF.
         ENDIF.
*End*************************************
         PERFORM prepare_update.
         MESSAGE i022(zmm_oth).
       ELSE.
         MESSAGE i024(zmm_oth) WITH 'MRP APPROVAL'.
       ENDIF.
     WHEN 'L'.
       IF zmm_cdhd_st-approve_L2 <> ''.
         UPDATE zmm_cdhd SET Approve_L2 = 'X'
                             appdate    = sy-datum
                             appcpf     = sy-uname
         WHERE reqno = zmm_cdhd_st-reqno.
*Addition********************************
         PERFORM send_mail_to_cdcell.
         IF zmm_cdhd_st-reqcl <> 'N'.
           MOVE 'IC' TO zmm_cdhd_st-reqcl.
           UPDATE zmm_cdhd SET reqcl = zmm_cdhd_st-reqcl
                          WHERE reqno = zmm_cdhd_st-reqno.
         ENDIF.

*End*************************************

         PERFORM prepare_update.
         MESSAGE i023(zmm_oth).
       ELSE.
         MESSAGE i024(zmm_oth) WITH 'L2 APPROVAL'.
       ENDIF.
   ENDCASE.
   PERFORM clear_var.

 ENDFORM.                    " update_approval

*&---------------------------------------------------------------------*
*&      Form  move_descriptions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM move_descriptions.

   descp1 = g_TABCTRL110_wa-desc1.
   descp2 = g_TABCTRL110_wa-desc2.
   descp3 = g_TABCTRL110_wa-desc3.
   descp4 = g_TABCTRL110_wa-desc4.

 ENDFORM.                    " move_descriptions
*&---------------------------------------------------------------------*
*&      Form  REL_APR_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM rel_apr_status.
   IF zmm_cdhd_st-status_flag IS INITIAL. "Req not released
     MESSAGE i026(zmm_oth) WITH '1'.
     PERFORM clear_var.
     LEAVE TO SCREEN 100.
   ENDIF.

   IF g_user = 'L' AND zmm_cdhd_st-approve_mrp = ''.
     MESSAGE i027(zmm_oth) WITH 'MRP CONTROLLER'.
     PERFORM clear_var.
     LEAVE TO SCREEN 100.
   ENDIF.

 ENDFORM.                    " REL_APR_STATUS
**********************************************************
 FORM popup_userdesc.
   DATA l_ans.
   IF g_tabctrl110_wa-desc1 = 'OTHER'.
     " Begin of <RD1K960036>.
*
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*         DEFAULTOPTION        = 'N'
*        TEXTLINE1     = 'OTHER in Main Attribute will require approval'
*         TEXTLINE2     = 'of request by Tech.Appr.Authority, Continue?'
*        TITEL                = 'Technical Authority Approval Required.'
**   START_COLUMN         = 25
**   START_ROW            = 6
*        CANCEL_DISPLAY       = ''
*      IMPORTING
*        ANSWER               = l_ans.


     DATA: l_answer(1) TYPE c.


     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'Technical Authority Approval Required.'
         text_question         = 'OTHER in Main Attribute will require approval of '
                                 & 'request by Tech.Appr.Authority, Continue?'
         default_button        = '2'
         display_cancel_button = 'X'
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_answer
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.

     IF sy-subrc = 0.
       CASE l_answer.
         WHEN '1'.
           MOVE 'J' TO l_ans.
         WHEN '2'.
           MOVE 'N' TO l_ans.
       ENDCASE.
     ENDIF.

     " End of <RD1K960036>.

     IF l_ans = 'J'.
       CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
     ELSE.
       g_tabctrl110_wa-desc1 = ''.
       g_tabctrl110_wa-oth1 = ''.

     ENDIF.
   ELSE.
     CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
   ENDIF.
 ENDFORM.                    " popup_userdesc

**********************************************************
 FORM check_other.
*+120505
   LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
     IF g_TABCTRL110_wa-Desc1 = 'OTHER' OR
        g_TABCTRL110_wa-Desc2 = 'OTHER' OR
        g_TABCTRL110_wa-Desc3 = 'OTHER' OR
        g_TABCTRL110_wa-Desc4 = 'OTHER'.
       MESSAGE i029(zmm_oth).
       LEAVE TO SCREEN 100.
     ENDIF.
   ENDLOOP.
*+120505

 ENDFORM.                    " check_other
**********************************************************
*&---------------------------------------------------------------------*
*&      Form  SPELL_ERROR_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_error_lines.
   DATA :z      TYPE i, ct_idx TYPE i.
   DATA : l_status(2).
*DATA  ist_spell_line1 like table of wa_spell_line with header line.
   TYPES: BEGIN OF itab_type,
            word(60),
            srno(3),
          END   OF itab_type.

   DATA: BEGIN OF checktab1 OCCURS 0,
           begriff(60),
           srno(3)     TYPE n,
         END OF checktab1.

   DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
   DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.

   IF checktab[] IS INITIAL.
     LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
       IF g_tabctrl110_wa-comp_flg = 'S'.
         REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
         g_tabctrl110_wa-rsn      = ''.
         MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX z
            TRANSPORTING comp_flg rsn.
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT checktab[] IS INITIAL.


   checktab1[] = checktab[].
   LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
     z = sy-tabix.
     SPLIT  g_tabctrl110_wa-desc_fin AT ' ' INTO TABLE itab.
     LOOP AT itab.
       MOVE z TO itab-srno.
       MODIFY itab INDEX sy-tabix.
     ENDLOOP.
     APPEND LINES OF itab TO itab1.
     CLEAR z.
   ENDLOOP.

*LOGIC-2
   CLEAR z.
   LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
     IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
       CONCATENATE '' g_tabctrl110_wa-comp_flg+1(1) INTO
              g_tabctrl110_wa-comp_flg.
       g_tabctrl110_wa-rsn      = ''.

       MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
               TRANSPORTING comp_flg rsn.
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT checktab1.
     ct_idx = sy-tabix.
     READ TABLE itab1 WITH KEY word = checktab1-begriff.
     IF sy-subrc = 0.
       checktab1-srno = itab1-srno.
       MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
       IF g_tabctrl110_wa-comp_flg+1(1) = ''.
         g_tabctrl110_wa-comp_flg = 'S'.
         g_tabctrl110_wa-rsn      = 'Spelling Mistake'.
       ELSE.
         CONCATENATE 'S' g_tabctrl110_wa-comp_flg+1(1) INTO l_status.
         g_tabctrl110_wa-comp_flg = l_status.
       ENDIF.
       z = itab1-srno.
       MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX z
            TRANSPORTING comp_flg rsn.
     ENDIF.
   ENDLOOP.
*loop at checktab1.
*write : / checktab1-begriff color 5, checktab1-srno.
*Endloop.




******LOGIC-1
*append lines of checktab to itab1.
*
*sort itab1 by word srno.
*clear z.
*read table itab1 index 1.
*
*loop at itab1.
*   If itab1-srno = ''.
*       word = itab1-word.
*   Endif.
*   if word = itab1-word and itab1-srno <> ''.
*      z = itab1-srno.
*      ist_spell_line1-spell_err = 'S'.
*      modify ist_spell_line1 index z transporting spell_err.
*      clear word.
*   Endif.
**word = itab1-word.
*Endloop.
*sort ist_spell_line1 by srno.
*sort checktab1 by srno.
*
*loop at ist_spell_line1 where spell_err = 'S'.
*  Loop at checktab1.
*       if ist_spell_line1-srno = checktab1-srno.
*          write : / ist_spell_line1-spell_err ,
*ist_spell_line1-tdline+0(88) ,
*                    checktab1-begriff+0(20) color 7,
*ist_spell_line1-srno.
*       Endif.
*  Endloop.
*Endloop.


*loop at checktab.
*
*        search g_tabctrl110_itab for checktab-begriff .
*        if sy-subrc = 0.
*           g_tabctrl110_wa-comp_flg = 'S'.
*           modify g_tabctrl110_itab from g_tabctrl110_wa
*             index sy-tabix transporting comp_flg.
*        Else.
*            g_tabctrl110_wa-comp_flg = ''.
*           modify g_tabctrl110_itab from g_tabctrl110_wa
*             index sy-tabix transporting comp_flg.
*
*        Endif.
*Endloop.
   CLEAR sy-ucomm.
 ENDFORM.                    " SPELL_ERROR_LINES
*&---------------------------------------------------------------------*
*&      Form  modi_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM modi_check.
   DATA : l_status(2).
   LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
     IF g_tabctrl110_wa-oth1 = 'X' OR
        g_tabctrl110_wa-oth2 = 'X' OR
        g_tabctrl110_wa-oth3 = 'X' OR
        g_tabctrl110_wa-oth4 = 'X' .

       SELECT SINGLE * FROM zmm_modifier WHERE
          desc1 = g_tabctrl110_wa-desc1 AND
          desc2 = g_tabctrl110_wa-desc2 AND
          desc3 = g_tabctrl110_wa-desc3 AND
          desc4 = g_tabctrl110_wa-desc4.
       IF sy-subrc <> 0.
         IF g_tabctrl110_wa-comp_flg+1(1) = 'M'.
           CONTINUE.
         ELSE.
           IF g_tabctrl110_wa-comp_flg+0(1) <> 'M'.
             CONCATENATE g_tabctrl110_wa-comp_flg 'M' INTO
             g_tabctrl110_wa-comp_flg.
             MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
                  TRANSPORTING comp_flg.
           ENDIF.
         ENDIF.
       ELSE.
*
*        replace  'M' with '' into g_tabctrl110_wa-comp_flg.
       ENDIF.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " modi_check
*&---------------------------------------------------------------------*
*&      Form  SELECT_MATERIAL_DETAILS1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM select_material_details1.

   CLEAR do_not_change_flag.

   IF g_mode = 'CRE' OR g_mode = 'CHA'.

     IF check_pos = 0.
       DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
     ENDIF.
*
*    if g_lineno_old <> g_lineno.
**     clear g_mat_fnd.
*      do_not_change_flag = 'X'.
*    endif.

     CLEAR g_hits_par.

   ENDIF.

   LOOP AT ist_srchlp INTO wa_srchlp.

     DATA : l_matnr LIKE thead-tdname.
     l_matnr = wa_srchlp-matnr.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client                  = sy-mandt
         id                      = 'BEST'
         language                = 'E'
         name                    = l_matnr
         object                  = 'MATERIAL'
       TABLES
         lines                   = lines
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       wa_srchlp-mark = '1'.
       MODIFY ist_srchlp FROM wa_srchlp.
     ENDIF.

   ENDLOOP.


 ENDFORM.                    " SELECT_MATERIAL_DETAILS1
*&---------------------------------------------------------------------*
*&      Module  CHECK_SPELL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE check_spell INPUT.

   IF sy-ucomm <> 'SPELL'.
     CLEAR ist_spell_line.
     REFRESH ist_spell_line.
     ist_spell_line-tdline = zmm_cditem-desc_fin.
     APPEND ist_spell_line.
     EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.
     CALL FUNCTION 'ZSPELL_CHECK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_spell_line.
     IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
     IF NOT checktab[] IS INITIAL.
       MESSAGE i016(zmm_oth).
       REPLACE zmm_cditem-comp_flg+0(1) WITH 'S' INTO zmm_cditem-comp_flg
   .
     ELSE.
       REPLACE zmm_cditem-comp_flg+0(1) WITH '' INTO zmm_cditem-comp_flg.
     ENDIF.
   ENDIF.
 ENDMODULE.                 " CHECK_SPELL  INPUT

*---------------------------------------------------------------------*
*       FORM insert_mdlno                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM insert_mdlno.
   DATA l_ans1.
*
   READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa INDEX
    g_curr_line_120.
   IF sy-subrc = 0.
     IF g_tablctrl120_wa-oth_mdl <> 'X'.
       MESSAGE i048(zmm_oth).
     ELSE.
       zmm_mdl-mdlno = g_tablctrl120_wa-mdlno.

       IF  zmm_mdl-mdlno <> ''.
         TRANSLATE zmm_mdl-mdlno TO UPPER CASE.
         " Begin of <RD1K960036>.
*         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*           EXPORTING
*             DEFAULTOPTION        = 'Y'
*             TEXTLINE1            = 'Insert Model No. '
*             TEXTLINE2            = zmm_mdl-mdlno
*             TITEL                = 'Insert model no.'
**       START_COLUMN         = 25
**       START_ROW            = 6
**       CANCEL_DISPLAY       = 'X'
*          IMPORTING
*            ANSWER               = l_ans1

         DATA : l_answer(1) TYPE c.
         CALL FUNCTION 'POPUP_TO_CONFIRM'
           EXPORTING
             titlebar              = 'Insert model no '
             text_question         = 'Insert Model No. zmm_mdl-mdlno '
             text_button_1         = 'Yes'
             text_button_2         = 'No'
             default_button        = '1'
             display_cancel_button = 'X'
             start_column          = 25
             start_row             = 6
           IMPORTING
             answer                = l_answer
           EXCEPTIONS
             text_not_found        = 1
             OTHERS                = 2.

         IF sy-subrc = 0.
           CASE l_answer.
             WHEN '1'.
               MOVE 'J' TO l_ans1.
             WHEN '2'.
               MOVE 'N' TO l_ans1.
           ENDCASE.
         ENDIF.
         " End of <RD1K960036>.
         IF l_ans1 = 'J'.
           INSERT INTO zmm_mdl VALUES zmm_mdl.
           REPLACE 'L' WITH '' INTO g_TABLCTRL120_wa-comp_flg.
           MODIFY g_TABLCTRL120_itab FROM g_TABLCTRL120_wa INDEX
            g_curr_line_120 TRANSPORTING comp_flg.
         ELSE.
*  message i045(zmm_oth). "Operation cancelled by the user
         ENDIF.
       ELSE.
*    message i046(zmm_oth). "Model no blank!
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " insert_mdlno
*&---------------------------------------------------------------------*
*&      Form  spell_check2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check2.
*
   CLEAR ist_spell_line.
   REFRESH ist_spell_line.
   CLEAR sy-ucomm.

   LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
     ist_spell_line-tdline = g_tablctrl120_wa-desc_fin.
     ist_spell_line-srno =   g_tablctrl120_wa-srno.
     APPEND ist_spell_line.
   ENDLOOP.
   EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.

   CALL FUNCTION 'ZSPELL_CHECK'
     EXPORTING
       sprache = 'EN'
     TABLES
       iline   = ist_spell_line.

   IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
   IF NOT checktab[] IS INITIAL.

     MESSAGE i017(Zmm_oth).
     PERFORM spell_error_lines_zspr.
   ELSE.
     MESSAGE i008(Zmm_oth).
     LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
*      if g_tablctrl120_wa-comp_flg+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
       MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX sy-tabix
         TRANSPORTING comp_flg .
*      Endif.
     ENDLOOP.
   ENDIF.
*
 ENDFORM.                    " spell_check2
*********************************************************************
 AT LINE-SELECTION.
*

   IF zmm_cdhd_st-mtart = 'ZSTO'.
     READ CURRENT LINE .
     wa_modifier_check_list = ist_modifier_check_list.
     SET PARAMETER ID 'S_MATGP' FIELD wa_modifier_check_list-matgrp.
   ENDIF.

   IF sy-dynnr = '0120'.
     READ CURRENT LINE .
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
     zmm_cditem-mdlno = sy-lisel.  "#EC CI_FLDEXT_OK[2215424]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
     zmm_cditem-oth_mdl = ''.
   ENDIF.
   LEAVE TO SCREEN 0.
*&---------------------------------------------------------------------*
*&      Form  SPELL_ERROR_LINES_ZSPR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_error_lines_zspr.
   DATA :z      TYPE i, ct_idx TYPE i.
   DATA : l_status(2).
*DATA  ist_spell_line1 like table of wa_spell_line with header line.
   TYPES: BEGIN OF itab_type,
            word(60),
            srno(3),
          END   OF itab_type.

   DATA: BEGIN OF checktab1 OCCURS 0,
           begriff(60),
           srno(3)     TYPE n,
         END OF checktab1.

   DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
   DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.

*
   IF checktab[] IS INITIAL.
     LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
       IF g_tablctrl120_wa-comp_flg+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
         MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX z
            TRANSPORTING comp_flg .
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT checktab[] IS INITIAL.

*
   checktab1[] = checktab[].
   LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
     z = sy-tabix.
     SPLIT  g_tablctrl120_wa-desc_fin AT ' ' INTO TABLE itab.
     LOOP AT itab.
       MOVE z TO itab-srno.
       MODIFY itab INDEX sy-tabix.
     ENDLOOP.
     APPEND LINES OF itab TO itab1.
     CLEAR z.
   ENDLOOP.

*LOGIC-2
   CLEAR z.
   LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
     IF g_tablctrl120_wa-comp_flg+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
       MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX sy-tabix
               TRANSPORTING comp_flg .
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT checktab1.
     ct_idx = sy-tabix.
     READ TABLE itab1 WITH KEY word = checktab1-begriff.
     IF sy-subrc = 0.
       checktab1-srno = itab1-srno.
       MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
       READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa INDEX
       itab1-srno.
       IF g_tablctrl120_wa-comp_flg+1(1) = ''.
         g_tablctrl120_wa-comp_flg = 'S'.
       ELSE.
         CONCATENATE 'S' g_tablctrl120_wa-comp_flg+1(1) INTO l_status.
         g_tablctrl120_wa-comp_flg = l_status.
       ENDIF.
       z = itab1-srno.
       MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX z
            TRANSPORTING comp_flg .
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " SPELL_ERROR_LINES_ZSPR
*&---------------------------------------------------------------------*
*&      Form  get_srchlp_zcap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_srchlp_zcap.
   DATA : l_srno  LIKE sy-index.
   DATA : l_len   LIKE sy-index.
   DATA : l_check.
   DATA : BEGIN OF wa_partdesc,
            part(40),
          END OF wa_partdesc.
   DATA : ist_partdesc LIKE TABLE OF wa_partdesc.
   DATA : l_desc(100).
   DATA : part1(40),part2(40),part3(40),part4(40).
   DATA : l_matnr LIKE thead-tdname.
   DATA : ist_partdesc_lines TYPE i.


*
   CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_FIN'.
*  If not zmm_cditem-desc_fin  is initial.
   READ TABLE g_TABLCTRL130_itab INTO g_TABLCTRL130_wa INDEX
 g_curr_line_130.
   IF NOT g_TABLCTRL130_wa-desc_fin  IS INITIAL.
     TRANSLATE g_TABLCTRL130_wa-desc_fin TO UPPER CASE.
     SPLIT g_TABLCTRL130_wa-desc_fin AT ' ' INTO TABLE ist_partdesc.
*    split zmm_cditem-desc_fin at ' ' into table ist_partdesc.
     DESCRIBE TABLE ist_partdesc LINES ist_partdesc_lines.
     IF ist_partdesc_lines > 4.
       DELETE ist_partdesc FROM 5 TO ist_partdesc_lines.
     ENDIF.
     READ TABLE ist_partdesc INTO wa_partdesc INDEX 1.

     CONCATENATE '%' wa_partdesc-part '%' INTO l_desc .
     CONDENSE l_Desc NO-GAPS.
*
     SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
     INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
     FROM makt AS a
     JOIN mara AS b
     ON a~matnr = b~matnr
     WHERE b~mtart = 'ZCAP'  AND
     ( a~maktg LIKE l_desc OR b~wrkst LIKE l_desc ).
*

     LOOP AT ist_partdesc INTO wa_partdesc.
       IF sy-tabix = 1.
         part1 = wa_partdesc-part.
         CONDENSE part1 NO-GAPS.
       ELSEIF sy-tabix = 2.
         part2 = wa_partdesc-part.
         CONDENSE part1 NO-GAPS.
       ELSEIF sy-tabix = 3.
         part3 = wa_partdesc-part.
         CONDENSE part1 NO-GAPS.
       ELSEIF sy-tabix = 4.
         part4 = wa_partdesc-part.
         CONDENSE part1 NO-GAPS.
       ENDIF.
     ENDLOOP.

     LOOP AT ist_srchlp INTO wa_srchlp.
       IF wa_srchlp-maktg+39(1) = '*'.
         CONCATENATE wa_srchlp-maktg+0(39) wa_srchlp-wrkst INTO
         wa_srchlp-maktx.
       ELSE.
         MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
       ENDIF.

       TRANSLATE wa_srchlp-maktx TO UPPER CASE.
       CHECK part2 <> ''.
       SEARCH wa_srchlp-maktx FOR part2.
       IF sy-subrc = 0.
         CHECK part3 <> ''.
         SEARCH wa_srchlp-maktx FOR part3.
         IF sy-subrc = 0.
           CHECK part4 <> ''.
           SEARCH wa_srchlp-maktx FOR part4.
           IF sy-subrc = 0.
*             l_srno         = l_srno + 1.
*             wa_srchlp-srno = l_srno.
*             l_matnr = WA_SRCHLP-MATNR.
*
*            CALL FUNCTION 'READ_TEXT'
*               EXPORTING
*                ID                      = 'BEST'
*                LANGUAGE                = 'E'
*                NAME                    = l_matnr
*                OBJECT                  = 'MATERIAL'
*             TABLES
*                LINES                   = lines
*             EXCEPTIONS
*              ID                      = 1
*              LANGUAGE                = 2
*              NAME                    = 3
*              NOT_FOUND               = 4
*              OBJECT                  = 5
*              REFERENCE_CHECK         = 6
*              WRONG_ACCESS_TO_ARCHIVE = 7
*              OTHERS                  = 8.
*
*             IF SY-SUBRC <> 0.
*              wa_srchlp-mark = '1'.
*             ENDIF.
*             modify ist_srchlp from wa_srchlp.
             CONTINUE.
           ELSE.
             DELETE  ist_srchlp INDEX sy-tabix.
           ENDIF.
         ELSE.
           DELETE  ist_srchlp INDEX sy-tabix.
         ENDIF.
       ELSE.
         DELETE  ist_srchlp INDEX sy-tabix.
       ENDIF.
     ENDLOOP.
   ENDIF.
   LOOP AT ist_srchlp INTO wa_srchlp.
     IF wa_srchlp-maktg+39(1) = '*'.
       CONCATENATE wa_srchlp-maktg+0(39) wa_srchlp-wrkst INTO
       wa_srchlp-maktx.
     ELSE.
       MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
     ENDIF.
     l_srno         = l_srno + 1.
     wa_srchlp-srno = l_srno.
     l_matnr = wa_srchlp-matnr.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         id                      = 'BEST'
         language                = 'E'
         name                    = l_matnr
         object                  = 'MATERIAL'
       TABLES
         lines                   = lines
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       wa_srchlp-mark = '1'.
     ENDIF.
     MODIFY ist_srchlp FROM wa_srchlp.
   ENDLOOP.

 ENDFORM.                    " get_srchlp_zcap
*&---------------------------------------------------------------------*
*&      Form  spell_check3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check3.
   CLEAR ist_spell_line.
   REFRESH ist_spell_line.
   CLEAR sy-ucomm.

   LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
     ist_spell_line-tdline = g_tablctrl130_wa-desc_fin.
     ist_spell_line-srno =   g_tablctrl130_wa-srno.
     APPEND ist_spell_line.
   ENDLOOP.
   EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.

   CALL FUNCTION 'ZSPELL_CHECK'
     EXPORTING
       sprache = 'EN'
     TABLES
       iline   = ist_spell_line.

   IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
   IF NOT checktab[] IS INITIAL.

     MESSAGE i017(Zmm_oth).
     PERFORM spell_error_lines_zcap.
   ELSE.
     MESSAGE i008(Zmm_oth).
     LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
*      if g_tablctrl130_wa-comp_flg+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
       MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX sy-tabix
         TRANSPORTING comp_flg .
*      Endif.
     ENDLOOP.
   ENDIF.
*

 ENDFORM.                    " spell_check3
*&---------------------------------------------------------------------*
*&      Form  SPELL_ERROR_LINES_ZCAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_error_lines_zcap.
   DATA :z      TYPE i, ct_idx TYPE i.
   DATA : l_status(2).
*DATA  ist_spell_line1 like table of wa_spell_line with header line.
   TYPES: BEGIN OF itab_type,
            word(60),
            srno(3),
          END   OF itab_type.

   DATA: BEGIN OF checktab1 OCCURS 0,
           begriff(60),
           srno(3)     TYPE n,
         END OF checktab1.

   DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
   DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.

*
   IF checktab[] IS INITIAL.
     LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
       IF g_tablctrl130_wa-comp_flg+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
         MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX z
            TRANSPORTING comp_flg .
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT checktab[] IS INITIAL.

*
   checktab1[] = checktab[].
   LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
     z = sy-tabix.
     SPLIT  g_tablctrl130_wa-desc_fin AT ' ' INTO TABLE itab.
     LOOP AT itab.
       MOVE z TO itab-srno.
       MODIFY itab INDEX sy-tabix.
     ENDLOOP.
     APPEND LINES OF itab TO itab1.
     CLEAR z.
   ENDLOOP.

*LOGIC-2
   CLEAR z.
   LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
     IF g_tablctrl130_wa-comp_flg+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
       MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX sy-tabix
               TRANSPORTING comp_flg .
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT checktab1.
     ct_idx = sy-tabix.
     READ TABLE itab1 WITH KEY word = checktab1-begriff.
     IF sy-subrc = 0.
       checktab1-srno = itab1-srno.
       MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
       READ TABLE g_tablctrl130_itab INTO g_tablctrl130_wa INDEX
       itab1-srno.
       IF g_tablctrl130_wa-comp_flg+1(1) = ''.
         g_tablctrl130_wa-comp_flg = 'S'.
       ELSE.
         CONCATENATE 'S' g_tablctrl130_wa-comp_flg+1(1) INTO l_status.
         g_tablctrl130_wa-comp_flg = l_status.
       ENDIF.
       z = itab1-srno.
       MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX z
            TRANSPORTING comp_flg .
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " SPELL_ERROR_LINES_ZCAP
*&---------------------------------------------------------------------*
*&      Form  cp_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM cp_matcode.
*   g_tabctrl110_wa = wa_srchlp-matnr.

 ENDFORM.                    " cp_matcode
*&---------------------------------------------------------------------*
*&      Form  get_srno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_srno.
*  get cursor line l_curs_ln.
***To get the proper serial no of line item against the
***Cursor position
   CASE zmm_cdhd_st-mtart.
     WHEN 'ZSTO'.
*   move tabctrl110-current_line to l_curs_ln.
       g_curs_ln = g_curr_line_110.
       READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa
                                   INDEX g_curs_ln.
       g_srno = g_tabctrl110_wa-srno.
     WHEN 'ZSPR'.
*   move tablctrl120-current_line to l_curs_ln.
       g_curs_ln = g_curr_line_120.
       READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa
                     INDEX g_curs_ln.
       g_srno = g_tablctrl120_wa-srno.
     WHEN 'ZCAP'.
       MOVE tablctrl130-current_line TO g_curs_ln.
       READ TABLE g_tablctrl130_itab INTO g_tablctrl130_wa
                     INDEX g_curs_ln.
       g_srno = g_tablctrl130_wa-srno.
     WHEN 'ZDIS'.
       MOVE tablctrl140-current_line TO g_curs_ln.
       READ TABLE g_tablctrl140_itab INTO g_tablctrl140_wa
                                   INDEX g_curs_ln.
       g_srno = g_tablctrl140_wa-srno.
   ENDCASE.


 ENDFORM.                    " get_srno
*&---------------------------------------------------------------------*
*&      Form  CHANGE_MRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM change_mrp.
   IF  g_mode = 'CHA' OR g_mode = 'REL' OR g_mode = 'APR'.

     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'M_BANF_WRK' FIELD zmm_cdhd_st-werks
                    ID 'ACTVT' FIELD '01'.
     IF sy-subrc = 0.
       g_change_auth = 'X'.
     ELSE.
       g_change_auth = ''.
     ENDIF.

   ENDIF.
 ENDFORM.                    " CHANGE_MRP
