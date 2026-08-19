*--- MAIN PROGRAM: MZMMCODUNBLOCKF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete F.M POPUP_TO_CONFRIM_STEP replaced with POPUP_TO_CONFRIM.
*
************************************************************************

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
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       CASE zmm_matblockhd_st-mtart.
         WHEN 'ZSTO'.
           PERFORM add_delitem110.
         WHEN 'ZSPR'.
           PERFORM add_delitem120.
         WHEN 'ZCAP'.
           PERFORM add_delitem130.
       ENDCASE.
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
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

     WHEN 'SPELL'.
       CASE zmm_matblockhd_st-mtart.
         WHEN 'ZSTO' .
           PERFORM spell_check_110.
         WHEN 'ZSPR'.
           PERFORM spell_check_120.
         WHEN 'ZCAP'.
           PERFORM spell_check_130.
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
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

* get looplines of TableControl
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

* get current line
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line                           *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     ELSE.
       <tc>-top_line = 1.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.
* insert initial line
   INSERT INITIAL LINE INTO <table> INDEX l_selline.
   <tc>-lines = <tc>-lines + 1.
* set cursor
   SET CURSOR LINE l_line.

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
*   no, ...                                                            *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         entry_act      = <tc>-top_line
         entry_from     = 1
         entry_to       = <tc>-lines
         last_page_full = 'X'
         loops          = <lines>
         ok_code        = p_ok
         overlapping    = 'X'
       IMPORTING
         entry_new      = l_tc_new_top_line
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS         = 0.
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
   IF g_mode =  'CRE' OR
      g_mode =  'CHA' OR
      g_mode =  'REL'.
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
     MOVE 'UNBLOCK' TO wa_tab-fcode.
     APPEND wa_tab TO it_tab1.
   ELSEIF g_mode = 'DEL' OR
          g_mode = 'DIS'.
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
     MOVE 'UNBLOCK' TO wa_tab-fcode.
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
   ELSE.
     MOVE 'UNBLOCK' TO wa_tab-fcode.
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
   DATA l_matblockhd LIKE zmm_matblock_hd.

   IF g_mode = 'CRE'.
     PERFORM set_dynnr USING zmm_matblockhd_st-mtart.
   ELSE.
     SELECT SINGLE * INTO l_matblockhd FROM zmm_matblock_hd
            WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc = 0.
       PERFORM set_dynnr USING l_matblockhd-mtart.
     ELSE.
*       message e003(zmm_oth) with zmm_matblockhd_st-reqno.
     ENDIF.
**
*     IF l_cdhd-mtart = 'ZSTO'.
*       Select single * from zmm_cditem
*          where reqno = zmm_cdhd_st-reqno
*          and   oth1  = 'X'.
*       IF sy-subrc = 0.
*         g_techapr_visible = 'Y'.
*       ENDIF.
*     ENDIF.
   ENDIF.

 ENDFORM.                    " fill_mattyp_itemdt
*&---------------------------------------------------------------------*
*&      Form  set_dynnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_MTART  text
*----------------------------------------------------------------------*
 FORM set_dynnr USING  p_mtart.
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
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM save_request.
   IF g_mode = 'CRE' OR g_mode = 'CHA'.
     CASE zmm_matblockhd_st-mtart.
       WHEN 'ZSTO'.
         IF NOT g_tc110_itab[] IS INITIAL.
           READ TABLE g_tc110_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
       WHEN 'ZSPR'.
         IF NOT g_tc120_itab[] IS INITIAL.
           READ TABLE g_tc120_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
       WHEN 'ZCAP'.
         IF NOT g_tc130_itab[] IS INITIAL.
           READ TABLE g_tc130_itab WITH KEY srno = 0.
           IF sy-subrc = 0.
             EXIT.
           ENDIF.
           IF g_mode = 'CRE'.
             PERFORM gen_request.
             SET PARAMETER ID 'ZREQNO' FIELD g_reqno.
           ENDIF.
         ELSE.
           MESSAGE i091(zmm_oth).
           EXIT.
         ENDIF.
     ENDCASE.
   ENDIF.
   IF g_mode = 'CRE'.
     zmm_matblockhd_st-reqno = g_reqno.
     PERFORM insert_into_tab.
     MESSAGE i005(zmm_oth) WITH g_reqno.
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'CHA'.
     g_request_no = zmm_matblockhd_st-reqno .
     PERFORM prepare_update.
     COMMIT WORK.
     MESSAGE i006(zmm_oth) WITH g_request_no.
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'DEL'.
     PERFORM prepare_delete .
     PERFORM clear_var.
     CLEAR okcode_100.
   ELSEIF g_mode = 'REL'.
     IF zmm_matblockhd_st-rel_flag = ''.
       CLEAR okcode_100.
       MESSAGE i024(zmm_oth) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
       IF g_rel = 'Y'.
         PERFORM update_rel.
         PERFORM send_mail_to_cdcell.
         PERFORM clear_var.
         CLEAR okcode_100.
       ELSE.
         CLEAR okcode_100.
         EXIT.
       ENDIF.
     ENDIF.
   ELSEIF g_mode = 'BLK'.
     PERFORM update_cdcell.
     IF zmm_matblockhd_st-reqcl = 'IR'.
       PERFORM send_mail_to_reqn.
     ENDIF.
     PERFORM clear_var.
     CLEAR okcode_100.
     LEAVE PROGRAM.
   ENDIF.

 ENDFORM.                    " Save_request
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
       object      = 'ZMMCDUNBLK'
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
 FORM insert_into_tab.

   DATA: l_blkhd LIKE zmm_matblock_hd.
   CLEAR : l_blkhd.
****Header Part*********
   IF g_mode = 'CRE'.
     MOVE sy-datum TO zmm_matblockhd_st-reqdate.
     MOVE sy-uname TO zmm_matblockhd_st-reqcpf.
     MOVE 'N' TO zmm_matblockhd_st-reqcl.
     MOVE-CORRESPONDING zmm_matblockhd_st TO l_blkhd.
     INSERT INTO zmm_matblock_hd VALUES l_blkhd.
*     if sy-subrc = 0.
*       message i001(zmm_oth) with ZMM_MATBLOCKHD_ST-reqno.
*     endif.
   ELSEIF g_mode = 'CHA'.
     MOVE-CORRESPONDING zmm_matblockhd_st TO l_blkhd.
     MODIFY zmm_matblock_hd FROM l_blkhd.
   ENDIF.
****Detail Part************
*   Refresh ist_zmm_cditem.
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       LOOP AT g_tc110_itab INTO g_tc110_wa.
         MOVE-CORRESPONDING g_tc110_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
     WHEN 'ZSPR'.
       LOOP AT g_tc120_itab INTO g_tc120_wa.
         MOVE-CORRESPONDING g_tc120_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
     WHEN 'ZCAP'.
       LOOP AT g_tc130_itab INTO g_tc130_wa.
         MOVE-CORRESPONDING g_tc130_wa TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
       ENDLOOP.
   ENDCASE.
   IF g_mode = 'CRE'.
     INSERT zmm_matblock_dt FROM TABLE itab_matblock_dt.
   ELSE.
     MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   ENDIF.
******Header(Correspondence)********************************
   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) .
     PERFORM save_cors_text.
   ENDIF.

 ENDFORM.                    " Insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM prepare_update.
   DATA : l_del110 TYPE ty_tc110,
          l_del120 TYPE ty_tc120,
          l_del130 TYPE ty_tc130.
   CLEAR g_item.
   SELECT SINGLE * INTO g_item FROM zmm_matblock_dt
          WHERE reqno = zmm_matblockhd_st-reqno.
**
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       IF NOT g_itab_del110[] IS INITIAL.
         LOOP AT g_itab_del110 INTO l_del110.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del110-srno.
         ENDLOOP.
       ENDIF.
     WHEN 'ZSPR'.
       IF NOT g_itab_del120[] IS INITIAL.
         LOOP AT g_itab_del120 INTO l_del120.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del120-srno.
         ENDLOOP.
       ENDIF.
     WHEN 'ZCAP'.
       IF NOT g_itab_del130[] IS INITIAL.
         LOOP AT g_itab_del130 INTO l_del130.
           DELETE FROM zmm_matblock_dt
             WHERE reqno = zmm_matblockhd_st-reqno
             AND   srno  = l_del130-srno.
         ENDLOOP.
       ENDIF.
   ENDCASE.
**
   PERFORM insert_into_tab.

 ENDFORM.                    " prepare_update
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
     CONCATENATE 'CORS' zmm_matblockhd_st-reqno INTO l_cors.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client                  = sy-mandt
         id                      = 'BLCK'
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
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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


   IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
      ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).

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
   l_theader-tdid       = 'BLCK'.
   l_theader-tdspras    =  sy-langu.
   l_theader-tdlinesize =  72.
   CONCATENATE 'CORS' zmm_matblockhd_st-reqno INTO l_theader-tdname.
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
*&      Form  update_rel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_rel.
   UPDATE zmm_matblock_hd
   SET   rel_flag = 'X'
   WHERE reqno    = zmm_matblockhd_st-reqno.
***If the req status id is 'IR', should be updated to 'IC'
***At the time of releasing the request.
   IF zmm_matblockhd_st-reqcl = 'IR'.
     UPDATE zmm_matblock_hd
     SET   reqcl    = 'IC'
     WHERE reqno    = zmm_matblockhd_st-reqno.
   ENDIF.
***
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_matblockhd_st-reqno.
 ENDFORM.                    " update_rel
*&---------------------------------------------------------------------*
*&      Form  update_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_approval.
   UPDATE zmm_matblock_hd
    SET   apr_flag = 'X'
    WHERE reqno    = zmm_matblockhd_st-reqno.
   PERFORM save_cors_text.
   MESSAGE i019(zmm_oth) WITH zmm_matblockhd_st-reqno.
 ENDFORM.                    " update_approval
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
   CLEAR zmm_matblockhd_st.
   CLEAR g_mode.
   REFRESH g_tc110_itab[].
   REFRESH CONTROL 'TCT110' FROM SCREEN '0110'.

   REFRESH g_tc120_itab[].
   REFRESH CONTROL 'TCT120' FROM SCREEN '0120'.

   REFRESH g_tc130_itab[].
   REFRESH CONTROL 'TCT130' FROM SCREEN '0130'.

   IF g_lock = 'Y'.
     PERFORM unlock_req.
     CLEAR g_lock.
   ENDIF.
   CLEAR: g_tc110_wa,g_tc120_wa,g_tc130_wa.
   CLEAR: g_hd_copied,g_tct130_copied,g_tct110_copied,g_tct120_copied.
   CLEAR  g_cors.
   REFRESH: tlinetab1,tlinetab2,lines_cors.
   REFRESH: lt_text_table1,lt_text_table2.
   REFRESH : itab_matblock_dt.

*****
*   dynnr = '0110'.

 ENDFORM.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_sto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_sto.
   DATA : g_110itab TYPE TABLE OF ty_tc110.
   DATA : l_110itab TYPE ty_tc110.
   CLEAR  l_110itab.
   REFRESH g_110itab.

   APPEND LINES OF g_tc110_itab TO g_110itab.
   SORT g_110itab BY srno DESCENDING.
   READ TABLE g_110itab INTO l_110itab INDEX 1.
   l_srno = l_110itab-srno + 1.
 ENDFORM.                    " get_nextsrno_sto
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_spr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_spr.
   DATA : g_120itab TYPE TABLE OF ty_tc120.
   DATA : l_120itab TYPE ty_tc120.
   CLEAR  l_120itab.
   REFRESH g_120itab.

   APPEND LINES OF g_tc120_itab TO g_120itab.
   SORT g_120itab BY srno DESCENDING.
   READ TABLE g_120itab INTO l_120itab INDEX 1.
   l_srno = l_120itab-srno + 1.

 ENDFORM.                    " get_nextsrno_spr
*&---------------------------------------------------------------------*
*&      Form  check_splchar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC120_WA_splchar  text
*----------------------------------------------------------------------*
 FORM check_splchar USING p_splchar.

   g_iputdata   = p_splchar.
   g_iputstring = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.

   CALL FUNCTION 'ZREM_SPLCHAR'
     EXPORTING
       iput    = g_iputdata
       istring = g_iputstring
     IMPORTING
       oput    = g_oputdata.

 ENDFORM.                    " check_splchar
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

     DELETE FROM zmm_matblock_hd
     WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc <> 0.
       MESSAGE e007(zmm_oth) WITH zmm_matblockhd_st-reqno.
     ENDIF.
*
     SELECT tdobject tdname tdid FROM stxl
      INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
      WHERE tdid = 'BLCK'.
     IF sy-subrc = 0.
       DELETE ist_textid_items
          WHERE tdname+4(10) <> zmm_matblockhd_st-reqno.
       LOOP AT ist_textid_items INTO wa_textid.
         PERFORM delete_text.
       ENDLOOP.
       REFRESH ist_textid_items.
     ENDIF.

     DELETE FROM zmm_matblock_dt
     WHERE reqno = zmm_matblockhd_st-reqno.
     IF sy-subrc = 0.
       MESSAGE i004(zmm_oth) WITH zmm_matblockhd_st-reqno.
     ENDIF.
     CLEAR g_choice.
   ENDIF.

 ENDFORM.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_del.
   CLEAR g_choice.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*     EXPORTING
*    textline1 = 'Data will be lost,No recovery possible,Are you sure ?'
*      titel       = 'BACK'
*      start_column     = 25
*      start_row        = 6
*      cancel_display   = ''
*     IMPORTING
*       answer          = g_choice.

   DATA : l_var(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'BACK'
       text_question         = 'Data will be lost,No recovery possible,Are you sure ?'
       display_cancel_button = ' '
       start_column          = 25
       start_row             = 6
     IMPORTING
       answer                = l_var
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.

   IF sy-subrc = 0.
     CASE l_answer.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
 ENDFORM.                    " confirm_del
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
*&      Form  spell_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC110_WA_MATDESC  text
*----------------------------------------------------------------------*
 FORM spell_check USING p_matdesc.
   DATA : ist_descline LIKE tline OCCURS 0 WITH HEADER LINE.
   REFRESH : ist_descline[].
   CLEAR g_errflag.

**
   ist_descline-tdformat = '**'.
   ist_descline-tdline   = p_matdesc.
   APPEND ist_descline.
**
   CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
     EXPORTING
       sprache = 'EN'
     IMPORTING
       errflag = g_errflag
     TABLES
       iline   = ist_descline.

 ENDFORM.                    " spell_check
*&---------------------------------------------------------------------*
*&      Form  add_delitem110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem110.
   DATA : l_tc110_wa TYPE ty_tc110.
   LOOP AT g_tc110_itab INTO l_tc110_wa.
     IF l_tc110_wa-mark = 'X'.
       APPEND l_tc110_wa TO g_itab_del110.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc110_wa.

 ENDFORM.                    " add_delitem110
*&---------------------------------------------------------------------*
*&      Form  add_delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem120.
   DATA : l_tc120_wa TYPE ty_tc120.
   LOOP AT g_tc120_itab INTO l_tc120_wa.
     IF l_tc120_wa-mark = 'X'.
       APPEND l_tc120_wa TO g_itab_del120.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc120_wa.

 ENDFORM.                    " add_delitem120
*&---------------------------------------------------------------------*
*&      Form  back_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM back_confirm.
   DATA  l_choice.
   CLEAR l_choice.
   IF g_mode = 'BLK'.
     PERFORM clear_var.
     LEAVE PROGRAM.
   ENDIF.
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

     DATA : l_var1(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'BACK '
         text_question         = 'Data will be lost, Want to quit?'
         display_cancel_button = ' '
       IMPORTING
         answer                = l_var1.
     IF sy-subrc = 0.
       CASE l_var1.
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
         dynnr = '0110'.
         CLEAR l_choice.
       ELSE.
         CLEAR l_choice.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ELSE.
     IF NOT g_mode IS INITIAL.
       PERFORM clear_var.
       dynnr = '0110'.
     ELSE.
       LEAVE PROGRAM.
     ENDIF.
*     leave program.
   ENDIF.

 ENDFORM.                    " back_confirm
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
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'BLK'.
       CALL METHOD gv_text_editor1->free.
       CALL METHOD gv_text_editor2->free.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD gv_text_editor1->free.
   ENDCASE.
   CLEAR:gv_text_editor1,gv_text_editor2.

 ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  confirm_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_exit.
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
     DATA : l_get(1) TYPE c.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         titlebar              = 'EXIT '
         text_question         = 'Data will be lost, Want to quit?'
         display_cancel_button = ' '
         start_column          = 25
         start_row             = 6
       IMPORTING
         answer                = l_get
       EXCEPTIONS
         text_not_found        = 1
         OTHERS                = 2.
     IF sy-subrc = 0.
       CASE l_get.
         WHEN '1'.
           MOVE 'J' TO l_choice1 .
         WHEN '2'.
           MOVE 'N' TO l_choice1 .
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
 ENDFORM.                    " confirm_exit
*&---------------------------------------------------------------------*
*&      Form  spell_check_110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_110.
   DATA:ist_line LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc110 TYPE ty_tc110.
**
   REFRESH ist_line.
**
   LOOP AT g_tc110_itab INTO l_tc110 WHERE errcd = 'S'.
     ist_line-tdline = l_tc110-matdesc.
     APPEND ist_line.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line.
   ENDIF.
***To update the internal table, if new word inserted..

   LOOP AT g_tc110_itab INTO l_tc110.
     PERFORM spell_check USING l_tc110-matdesc.
     IF g_errflag = ''.
       l_tc110-errcd = ''.
       MODIFY g_tc110_itab FROM l_tc110.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.
 ENDFORM.                    " spell_check_110
*&---------------------------------------------------------------------*
*&      Form  spell_check_120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_120.
   DATA:ist_line120 LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc120 TYPE ty_tc120.
**
   REFRESH ist_line120.
**
   LOOP AT g_tc120_itab INTO l_tc120 WHERE errcd = 'S'.
     ist_line120-tdline = l_tc120-matdesc.
     APPEND ist_line120.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line120.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line120.
   ENDIF.

***To update the internal table, if new word inserted..
   LOOP AT g_tc120_itab INTO l_tc120.
     PERFORM spell_check USING l_tc120-matdesc.
     IF g_errflag = ''.
       l_tc120-errcd = ''.
       MODIFY g_tc120_itab FROM l_tc120.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.


 ENDFORM.                    " spell_check_120
*&---------------------------------------------------------------------*
*&      Form  unblock_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_matcode.
   DATA : l_totlines   TYPE i,
          l_unblklines TYPE i.
****
   CASE zmm_matblockhd_st-mtart.

     WHEN 'ZSTO'.
       READ TABLE  g_tc110_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE  g_tc110_itab WITH KEY mark  = 'X'
                                         errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_110.
***Setting the request status.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*           DESCRIBE TABLE g_tc110_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                           FROM zmm_matblock_dt
                           WHERE reqno = zmm_matblockhd_st-reqno.

           SELECT COUNT(*) INTO l_unblklines
                         FROM zmm_matblock_dt
           WHERE reqno = zmm_matblockhd_st-reqno
           AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.

     WHEN 'ZSPR'.
       READ TABLE  g_tc120_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE  g_tc120_itab WITH KEY mark  = 'X'
                                         errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_120.
*** Setting the request status.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*            DESCRIBE TABLE g_tc120_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                          FROM zmm_matblock_dt
                          WHERE reqno = zmm_matblockhd_st-reqno.
           SELECT COUNT(*) INTO l_unblklines
                           FROM zmm_matblock_dt
          WHERE reqno = zmm_matblockhd_st-reqno
          AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.
     WHEN 'ZCAP'.
       READ TABLE  g_tc130_itab WITH KEY mark  = 'X'.
       IF sy-subrc <> 0.
         MESSAGE i101(zmm_oth).
         EXIT.
       ENDIF.

       READ TABLE g_tc130_itab WITH KEY mark  = 'X'
                                        errcd = 'S'.
       IF sy-subrc = 0.
         MESSAGE e100(zmm_oth).
       ENDIF.

       PERFORM confirm_unblock.
       IF g_choice = 'J'.
         PERFORM unblock_130.
         IF zmm_matblockhd_st-reqcl = 'IR'.
           PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
         ELSE.
*** Setting the request status.
*           DESCRIBE TABLE g_tc130_itab LINES l_totlines.
           SELECT COUNT(*) INTO l_totlines
                           FROM zmm_matblock_dt
                           WHERE reqno = zmm_matblockhd_st-reqno.
           SELECT COUNT(*) INTO l_unblklines
                         FROM zmm_matblock_dt
           WHERE reqno = zmm_matblockhd_st-reqno
           AND   mstae = ''.
           IF l_unblklines < l_totlines.
             zmm_matblockhd_st-reqcl = 'IC'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ELSE.
             zmm_matblockhd_st-reqcl = 'C'.
             PERFORM set_reqcl USING zmm_matblockhd_st-reqcl.
           ENDIF.
         ENDIF.
         PERFORM save_cors_text.
       ENDIF.
*       CLEAR g_choice.
   ENDCASE.

 ENDFORM.                    " unblock_matcode
*&---------------------------------------------------------------------*
*&      Form  confirm_unblock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM confirm_unblock.

   CLEAR g_choice.
   " BEGIN OF <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*             textline1      = 'Want to unblock selected Codes ?'
*             titel          = 'Unblock'
*             start_column   = 25
*             start_row      = 6
*             cancel_display = ''
*        IMPORTING
*             answer         = g_choice.

   DATA : l_get1(1) TYPE c.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       titlebar              = 'Unblock '
       text_question         = 'Want to unblock selected Codes ?'
       display_cancel_button = ' '
     IMPORTING
       answer                = l_get1
     EXCEPTIONS
       text_not_found        = 1
       OTHERS                = 2.
   IF sy-subrc = 0.
     CASE l_get1.
       WHEN '1'.
         MOVE 'J' TO g_choice.
       WHEN '2'.
         MOVE 'N' TO g_choice.
     ENDCASE.
   ENDIF.
   " End of <RD1K960036>.
 ENDFORM.                    " confirm_unblock
*&---------------------------------------------------------------------*
*&      Form  unblock_110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_110.
   DATA: l_tc110wa TYPE ty_tc110.
   CLEAR: l_tc110wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.

   LOOP AT g_tc110_itab INTO l_tc110wa WHERE mark = 'X'.
     IF l_tc110wa-errcd IS INITIAL.
***Updating MARA table.**********************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc110wa-matcode.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc110wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc110wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc110wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc110wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc110wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc110wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc110wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc110wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc110wa-matdesc
           WHERE  matnr = l_tc110wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc110wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc110wa-matcode
                                   l_tc110wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc110wa-mstae = ''.
       l_tc110wa-unblkby = sy-uname.
       l_tc110wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc110_itab FROM l_tc110wa.
***Modifying database table
       MOVE-CORRESPONDING l_tc110wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc110wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc110wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
***Modifying those items which have been changed
***but not selected for unblocking.
   LOOP AT g_tc110_itab INTO l_tc110wa WHERE mark <> 'X'.
     l_tc110wa-unblkby = sy-uname.
     l_tc110wa-unblkdt = sy-datum.
*      MODIFY TABLE g_tc110_itab FROM l_tc110wa.
     MOVE-CORRESPONDING l_tc110wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc110wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.

 ENDFORM.                    " unblock_110
*&---------------------------------------------------------------------*
*&      Form  unblock_120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_120.
   DATA : l_tc120wa TYPE ty_tc120.
   DATA : l_atinn        LIKE cabn-atinn,
          l_name1        LIKE  lfa1-name1,
          l_maktx        LIKE makt-maktx,
          "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026


*          l_partno30(30) TYPE c,
          l_partno30(70) TYPE c,
*          l_partno(30)   TYPE c.
          l_partno(70)   TYPE c.
   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026

   DATA : l_ausp  LIKE ausp.
   CLEAR :l_tc120wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.
   LOOP AT g_tc120_itab INTO l_tc120wa WHERE mark = 'X'.
     IF l_tc120wa-errcd IS INITIAL.
***Updating MARA table.*************************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc120wa-matcode.
***Part Number
       IF NOT l_tc120wa-npartno IS INITIAL.
         UPDATE mara
         SET    mfrpn = l_tc120wa-npartno
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***OEM ( Manufacturer)
       IF NOT l_tc120wa-noem IS INITIAL.
         UPDATE mara
         SET    mfrnr = l_tc120wa-noem
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc120wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc120wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc120wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc120wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc120wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc120wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc120wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc120wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc120wa-matdesc
           WHERE  matnr = l_tc120wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating AUSP table.*************************
***Part Number
       CLEAR l_atinn.
       IF NOT l_tc120wa-npartno IS INITIAL.
         g_desclen = strlen( l_tc120wa-npartno ).
         IF g_desclen > 30.
           l_partno30 = l_tc120wa-npartno+0(30).
           l_partno   = l_tc120wa-npartno+30(10).
***Updating classification view with 30 char.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_partno30
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_partno30.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR: l_ausp,l_partno30.
           ENDIF.
***Updating classification view with remaining char.
           CLEAR l_atinn.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO_CONTINUED'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_partno
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_partno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR: l_ausp,l_partno.
           ENDIF.
****
         ELSE.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           UPDATE ausp
           SET    atwrt = l_tc120wa-npartno
           WHERE  objek = l_tc120wa-matcode  "#EC CI_FLDEXT_OK[2215424]
           AND    atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_tc120wa-npartno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR l_ausp.
           ENDIF.
         ENDIF.
       ELSE.      "oldpartno exist, but not in cls view
         CLEAR: l_atinn,l_ausp.
         IF NOT l_tc120wa-opartno IS INITIAL.
           SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGPARTNO'
 ORDER BY PRIMARY KEY .
           ENDSELECT.
           SELECT SINGLE * FROM ausp
                 WHERE objek = l_tc120wa-matcode "#EC CI_FLDEXT_OK[2215424]
                 AND   atinn = l_atinn.
           IF sy-subrc <> 0.
             l_ausp-objek = l_tc120wa-matcode.
             l_ausp-atinn  = l_atinn.
             l_ausp-atzhl  = 1.
             l_ausp-mafid  = 'O'.
             l_ausp-klart  = '001'.
             l_ausp-adzhl  = '000'.
             l_ausp-atwrt  = l_tc120wa-opartno.
             INSERT INTO ausp VALUES l_ausp.
             CLEAR l_ausp.
           ENDIF.

         ENDIF.
       ENDIF.
***Manufacturer (OEM)
       CLEAR: l_atinn, l_name1.
       SELECT SINGLE name1 INTO l_name1 FROM lfa1
              WHERE lifnr = l_tc120wa-noem.
       IF sy-subrc <> 0.
         l_name1 = ''.
       ENDIF.
       IF NOT l_tc120wa-noem IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MFGCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_name1
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_name1.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Model Number
       CLEAR l_atinn.
       IF NOT l_tc120wa-nmdlno IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MODELCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         lv_atwrt = l_tc120wa-nmdlno.
         UPDATE ausp
*         SET    atwrt = l_tc120wa-nmdlno
         SET    atwrt = lv_atwrt
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_tc120wa-nmdlno.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Capital Code
       CLEAR l_atinn.
       IF NOT l_tc120wa-ncapno IS INITIAL.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CAPCODE'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_tc120wa-ncapno
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_tc120wa-ncapno.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
***Capital Description ( If new Capital Code is entered )
         CLEAR l_atinn.
         SELECT atinn INTO l_atinn FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CPCODE_DESC'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         SELECT maktx INTO l_maktx FROM makt UP TO 1 ROWS
 WHERE matnr = l_tc120wa-ncapno
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_maktx
         WHERE  objek = l_tc120wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn.
         IF sy-subrc <> 0.
           l_ausp-objek = l_tc120wa-matcode.
           l_ausp-atinn  = l_atinn.
           l_ausp-atzhl  = 1.
           l_ausp-mafid  = 'O'.
           l_ausp-klart  = '001'.
           l_ausp-adzhl  = '000'.
           l_ausp-atwrt  = l_maktx.
           INSERT INTO ausp VALUES l_ausp.
           CLEAR l_ausp.
         ENDIF.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc120wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc120wa-matcode
                                   l_tc120wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc120wa-mstae = ''.
       l_tc120wa-unblkby = sy-uname.
       l_tc120wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc120_itab FROM l_tc120wa.
***Modifying database table..
       MOVE-CORRESPONDING l_tc120wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc120wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc120wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
****Modifying those items which have been changed
****but not selected for unblocking.
   LOOP AT g_tc120_itab INTO l_tc120wa WHERE mark <> 'X'.
     l_tc120wa-unblkby = sy-uname.
     l_tc120wa-unblkdt = sy-datum.
*      MODIFY TABLE g_tc120_itab FROM l_tc120wa.
     MOVE-CORRESPONDING l_tc120wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc120wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.


 ENDFORM.                    " unblock_120
*&---------------------------------------------------------------------*
*&      Form  set_reqcl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MATBLOCKHD_ST_REQCL  text
*----------------------------------------------------------------------*
 FORM set_reqcl USING p_reqcl.
   UPDATE zmm_matblock_hd
     SET reqcl = p_reqcl
     WHERE reqno = zmm_matblockhd_st-reqno.

**
   IF zmm_matblockhd_st-reqcl = 'IR'.
     UPDATE zmm_matblock_hd
      SET ir_date = sy-datum
      WHERE reqno = zmm_matblockhd_st-reqno.
   ENDIF.
 ENDFORM.                    " set_reqcl
*&---------------------------------------------------------------------*
*&      Form  update_cdcell
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM update_cdcell.
   DATA   : l_tc110 TYPE ty_tc110,
            l_tc120 TYPE ty_tc120,
            l_tc130 TYPE ty_tc130.
   CLEAR  : l_tc110,l_tc120,l_tc130,wa_matblock_dt.
   REFRESH: itab_matblock_dt.

***Header
   IF zmm_matblockhd_st-reqcl = 'IR'.
     SELECT SINGLE * FROM zmm_matblock_hd
            WHERE reqno = zmm_MATBLOCKhd_st-reqno.
     IF zmm_MATBLOCK_hd-ir_date IS INITIAL.
       zmm_matblockhd_st-ir_date = sy-datum.
     ENDIF.
   ELSE.
     CLEAR zmm_matblockhd_st-ir_date.
   ENDIF.

   MOVE-CORRESPONDING zmm_matblockhd_st TO Zmm_MATBLOCK_hd.
   MODIFY zmm_matblock_hd FROM zmm_MATBLOCK_hd.
*   UPDATE zmm_matblock_hd
*   SET reqcl   = zmm_matblockhd_st-reqcl
*   WHERE reqno = zmm_matblockhd_st-reqno.
***details
   CASE zmm_matblockhd_st-mtart.
     WHEN 'ZSTO'.
       LOOP AT g_tc110_itab INTO l_tc110.
         MOVE-CORRESPONDING l_tc110 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc110.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
*
     WHEN 'ZSPR'.
       LOOP AT g_tc120_itab INTO l_tc120.
         MOVE-CORRESPONDING l_tc120 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc120.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
     WHEN 'ZCAP'.
       LOOP AT g_tc130_itab INTO l_tc130.
         MOVE-CORRESPONDING l_tc130 TO wa_matblock_dt.
         MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
         APPEND wa_matblock_dt TO itab_matblock_dt.
         CLEAR:wa_matblock_dt,l_tc130.
       ENDLOOP.
       MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
       REFRESH itab_matblock_dt.
   ENDCASE.
***Correspondense.
   PERFORM save_cors_text.
 ENDFORM.                    " update_cdcell
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_cap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_nextsrno_cap.
   DATA : g_130itab TYPE TABLE OF ty_tc130.
   DATA : l_130itab TYPE ty_tc130.
   CLEAR  l_130itab.
   REFRESH g_130itab.

   APPEND LINES OF g_tc130_itab TO g_130itab.
   SORT g_130itab BY srno DESCENDING.
   READ TABLE g_130itab INTO l_130itab INDEX 1.
   l_srno = l_130itab-srno + 1.
 ENDFORM.                    " get_nextsrno_cap
*&---------------------------------------------------------------------*
*&      Form  add_delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM add_delitem130.
   DATA : l_tc130_wa TYPE ty_tc130.
   LOOP AT g_tc130_itab INTO l_tc130_wa.
     IF l_tc130_wa-mark = 'X'.
       APPEND l_tc130_wa TO g_itab_del130.
     ENDIF.
   ENDLOOP.
   CLEAR l_tc130_wa.

 ENDFORM.                    " add_delitem130
*&---------------------------------------------------------------------*
*&      Form  spell_check_130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM spell_check_130.
   DATA: ist_line130 LIKE tline OCCURS 0 WITH HEADER LINE.
   DATA: l_tc130 TYPE ty_tc130.
**
   REFRESH ist_line130.
**
   LOOP AT g_tc130_itab INTO l_tc130 WHERE errcd = 'S'.
     ist_line130-tdline = l_tc130-matdesc.
     APPEND ist_line130.
   ENDLOOP.

   IF g_mode = 'BLK'.
     CALL FUNCTION 'ZSPELL_CHECK_BLK'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line130.
   ELSE.
     CALL FUNCTION 'ZSPELL_CHECK_EXCEP'
       EXPORTING
         sprache = 'EN'
       TABLES
         iline   = ist_line130.
   ENDIF.
***To update the internal table, if new word inserted..

   LOOP AT g_tc130_itab INTO l_tc130.
     PERFORM spell_check USING l_tc130-matdesc.
     IF g_errflag = ''.
       l_tc130-errcd = ''.
       MODIFY g_tc130_itab FROM l_tc130.
     ENDIF.
     CLEAR g_errflag.
   ENDLOOP.

 ENDFORM.                    " spell_check_130
*&---------------------------------------------------------------------*
*&      Form  unblock_130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM unblock_130.
   DATA: l_tc130wa  TYPE ty_tc130,
         l_atinn130 LIKE ausp-atinn,
         l_ausp130  LIKE ausp.
   DATA: l_matcost LIKE ausp-atflv,
         l_matlife LIKE ausp-atflv.
   CLEAR: l_tc130wa,wa_matblock_dt.
   REFRESH : itab_matblock_dt.

   LOOP AT g_tc130_itab INTO l_tc130wa WHERE mark = 'X'.
     IF l_tc130wa-errcd IS INITIAL.
***Updating MARA table.**********************
***flag
       UPDATE mara
       SET    mstae = ''
       WHERE  matnr = l_tc130wa-matcode.
***NORMT
       SELECT SINGLE * FROM mara WHERE
              matnr = l_tc130wa-matcode.
       IF NOT mara-normt IS INITIAL.
         g_normt = mara-normt+0(5).
         UPDATE mara
         SET    normt = g_normt
         WHERE  matnr = l_tc130wa-matcode.
       ENDIF.
***Updating MAKT table.*************************
       IF NOT l_tc130wa-matdesc IS INITIAL.
         g_desclen = strlen( l_tc130wa-matdesc ).
         IF g_desclen > 40.
           g_wrkst39 = l_tc130wa-matdesc+0(39).
           CONCATENATE g_wrkst39 '*' INTO g_wrkst39.
           g_wrkst = l_tc130wa-matdesc+39.
           UPDATE mara
            SET wrkst   = g_wrkst
            WHERE matnr = l_tc130wa-matcode.
           UPDATE makt
            SET    maktx = g_wrkst39
            WHERE  matnr = l_tc130wa-matcode.
         ELSE.
           UPDATE makt
           SET    maktx = l_tc130wa-matdesc
           WHERE  matnr = l_tc130wa-matcode.
         ENDIF.
         CLEAR: g_wrkst,g_wrkst39,g_desclen.
       ENDIF.
***Updating AUSP table
***Material Location
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matloc IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_PLACE_OF_USE_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         DATA: lv_atwrt TYPE ausp-atwrt.
         lv_atwrt = l_tc130wa-matloc.
         UPDATE ausp
*         SET    atwrt = l_tc130wa-matloc
         SET    atwrt = lv_atwrt
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matloc.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
       BREAK cab_subodhk.
***Material life
       CLEAR l_atinn130.
       IF NOT l_tc130wa-mat_life IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_LIFE_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atflv = l_tc130wa-mat_life
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atflv  = l_tc130wa-mat_life.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR: l_ausp130,l_matlife.
         ENDIF.
       ENDIF.

***Material Cost
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matcost IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_COST_OF_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atflv = l_tc130wa-matcost
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atflv  = l_tc130wa-matcost.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR:l_matcost, l_ausp130.
         ENDIF.
       ENDIF.
***Material Category
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matcatg IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_GROUP_CAPITAL'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         lv_objek = l_tc130wa-matcode.
         lv_atwrt = l_tc130wa-matcatg.
         UPDATE ausp
*         SET    atwrt = l_tc130wa-matcatg
         SET    atwrt = lv_atwrt
*         WHERE  objek = l_tc130wa-matcode
         WHERE  objek =  lv_objek
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matcatg.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
***Material Group
       CLEAR l_atinn130.
       IF NOT l_tc130wa-matgp IS INITIAL.
         SELECT atinn INTO l_atinn130 FROM cabn UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_GROUP_OF_SPARES'
 ORDER BY PRIMARY KEY .
         ENDSELECT.
         UPDATE ausp
         SET    atwrt = l_tc130wa-matgp
         WHERE  objek = l_tc130wa-matcode    "#EC CI_FLDEXT_OK[2215424]
         AND    atinn = l_atinn130.
         IF sy-subrc <> 0.
           l_ausp130-objek  = l_tc130wa-matcode.
           l_ausp130-atinn  = l_atinn130.
           l_ausp130-atzhl  = 1.
           l_ausp130-mafid  = 'O'.
           l_ausp130-klart  = '001'.
           l_ausp130-adzhl  = '000'.
           l_ausp130-atcod  = '1'.
           l_ausp130-atwrt  = l_tc130wa-matgp.
           INSERT INTO ausp VALUES l_ausp130.
           CLEAR l_ausp130.
         ENDIF.
       ENDIF.
***Updating long text for Non Moving items.
*       IF l_tc130wa-mstae = 'NM'.
       PERFORM upd_lt_for_nm USING l_tc130wa-matcode
                                   l_tc130wa-res_nm.
*       ENDIF.
***Mofifying internal table.
       l_tc130wa-mstae = ''.
       l_tc130wa-unblkby = sy-uname.
       l_tc130wa-unblkdt = sy-datum.
       MODIFY TABLE g_tc130_itab FROM l_tc130wa.
***Modifying database table
       MOVE-CORRESPONDING l_tc130wa TO wa_matblock_dt.
       MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
       APPEND wa_matblock_dt TO itab_matblock_dt.
       CLEAR:wa_matblock_dt,l_tc130wa.
       MESSAGE i102(zmm_oth).
     ELSE.
       MESSAGE i110(zmm_oth) WITH l_tc130wa-errcd.
     ENDIF.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.
****Modifying those items which have been changed
****but not selected for unblocking.
   LOOP AT g_tc130_itab INTO l_tc130wa WHERE mark <> 'X'.
     l_tc130wa-unblkby = sy-uname.
     l_tc130wa-unblkdt = sy-datum.
     MOVE-CORRESPONDING l_tc130wa TO wa_matblock_dt.
     MOVE zmm_matblockhd_st-reqno TO wa_matblock_dt-reqno.
     APPEND wa_matblock_dt TO itab_matblock_dt.
     CLEAR:wa_matblock_dt,l_tc130wa.
   ENDLOOP.
   MODIFY zmm_matblock_dt FROM TABLE itab_matblock_dt.
   REFRESH : itab_matblock_dt.

 ENDFORM.                    " unblock_130
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
**
   CLEAR : l_name,l_title,l_text,l_user.
   REFRESH l_text_itab.
**Assignments.....
   l_name   = zmm_matblockhd_st-reqno.
   CONCATENATE 'Unblock MatCode Request for' zmm_matblockhd_st-reqno
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
       mailname  = l_name
       mailtitel = l_title
       user      = l_user
     TABLES
       text      = l_text_itab.

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
**
   CLEAR : r_name,r_title,r_text.
   REFRESH r_text_itab.
**Assignments.....
   r_name   = zmm_matblockhd_st-reqno.
   CONCATENATE 'Request' zmm_matblockhd_st-reqno 'Status'
               INTO r_title SEPARATED BY space.
   IF zmm_matblockhd_st-reqcl = 'C'.
     r_text = 'Request has been updated.Please check the Request,Request'
   &'status and correspondence within it.this is a system generated mail,'
   &'please do not reply. - codification cell'.
     APPEND r_text TO r_text_itab.
**
   ELSEIF zmm_matblockhd_st-reqcl = 'IR'.
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
   SELECT SINGLE reqcpf INTO r_user FROM zmm_matblock_hd
          WHERE reqno = zmm_matblockhd_st-reqno.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
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
*&      Form  UPD_LT_FOR_NM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_TC110WA_MATCODE  text
*      -->P_L_TC110WA_RES_NM  text
*----------------------------------------------------------------------*
 FORM upd_lt_for_nm USING  p_matcode
                           p_res_nm.
   DATA: wa_lines LIKE tline,
         l_txt    LIKE tline-tdline,
         l_insert TYPE c.
   DATA : header   LIKE  thead,
          l_tdname LIKE thead-tdname.
   DATA : ist_nmlines LIKE tline OCCURS 0 WITH HEADER LINE.

****Update Internal Comments
   header-tdobject = 'MATERIAL'.
   header-tdid     = 'IVER'.
   header-tdname   =  p_matcode .
   header-tdspras  = 'EN'.
   header-tdform   = 'SYSTEM'.
   header-mandt    = sy-mandt .
   l_tdname        = p_matcode.
   REFRESH: ist_nmlines.

***Fetching the existing text against matcode.
   SELECT SINGLE * FROM stxh
            WHERE tdobject = 'MATERIAL'
            AND   tdname   = l_tdname
            AND   tdid     = 'IVER'.
   IF sy-subrc = 0.
     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         client   = sy-mandt
         id       = 'IVER'
         language = 'E'
         name     = l_tdname
         object   = 'MATERIAL'
       TABLES
         lines    = ist_nmlines.
   ENDIF.
***Appending the remark to existing text.
   IF NOT ist_nmlines[] IS INITIAL.
     wa_lines-tdformat = '*'.
     wa_lines-tdline = '               '.
     APPEND wa_lines TO ist_nmlines .
   ENDIF.
   CONCATENATE sy-uname '-' sy-datum INTO l_txt .
   wa_lines-tdformat = '*'.
   wa_lines-tdline  =  l_txt .
   APPEND wa_lines TO ist_nmlines .
   wa_lines-tdline = p_res_nm.
   APPEND wa_lines TO ist_nmlines .
   CLEAR l_txt.
   CONCATENATE 'Request no-' zmm_matblockhd_st-reqno INTO l_txt.
   wa_lines-tdline = l_txt.
   APPEND wa_lines TO ist_nmlines .

   IF ist_nmlines[] IS INITIAL.
     l_insert = 'X'.
   ELSE.
     l_insert =  space.
   ENDIF.
***Saving the nonmoving text ( Remark)

   CALL FUNCTION 'SAVE_TEXT'
     EXPORTING
       client          = sy-mandt
       header          = header
       insert          = l_insert
       savemode_direct = 'X'
     TABLES
       lines           = ist_nmlines.


 ENDFORM.                    " UPD_LT_FOR_NM
*&---------------------------------------------------------------------*
*&      Form  lock_reqhd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM lock_reqhd.

   CALL FUNCTION 'ENQUEUE_EZ_MM_MATBLOCK'
     EXPORTING
       mode_zmm_cdhd  = 'E'
       mandt          = sy-mandt
       reqno          = zmm_matblockhd_st-reqno
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
 FORM unlock_req.
   CALL FUNCTION 'DEQUEUE_EZ_MM_MATBLOCK'
     EXPORTING
       mode_zmm_cdhd = 'E'
       mandt         = sy-mandt
       reqno         = zmm_matblockhd_st-reqno.

 ENDFORM.                    " unlock_req
