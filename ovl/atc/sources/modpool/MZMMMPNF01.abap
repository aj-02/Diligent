*--- MAIN PROGRAM: MZMMMPNF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMMPNF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       screen exit confirmation routine
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.

  IF g_function NE 'DIS'.
    CASE g_exit.
      WHEN 'BACK' OR 'CANC'.
        PERFORM  confirm_action  USING  text-202 text-203 g_action.
      WHEN 'EXIT'.
        PERFORM  confirm_action  USING  text-200 text-201 g_action.
    ENDCASE.
    IF g_action EQ '1'.
      IF g_exit = 'BACK' OR g_exit = 'CANC'.
        PERFORM exit_screen.
        LEAVE TO SCREEN '9001'.
      ELSE.
        PERFORM exit_screen.
        LEAVE PROGRAM.
      ENDIF.
    ENDIF.
  ELSE.
    IF sy-calld NE space.
      LEAVE.
    ELSE.
      IF g_exit = 'BACK' .
        PERFORM exit_screen.
        LEAVE TO SCREEN '9001'.
      ELSE.
        PERFORM exit_screen.
        LEAVE PROGRAM.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " confirm_step
*&---------------------------------------------------------------------*
*&      Form  confirm_action
*&---------------------------------------------------------------------*
*       pop up function for confirmation
*----------------------------------------------------------------------*
*      -->l_title  text
*      -->l_question  text
*      -->l_action  text
*----------------------------------------------------------------------*
FORM confirm_action USING  l_title  l_question l_action.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
            titlebar              = l_title
            text_question         = l_question
            text_button_1         = 'Yes'
            icon_button_1         = 'ICON_OKAY'
            text_button_2         = 'No'
            icon_button_2         = 'ICON_REJECT'
            default_button        = '1'
            display_cancel_button = 'X'
            start_column          = 25
            start_row             = 6
       IMPORTING
            answer                = g_action
       EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " confirm_action
*&---------------------------------------------------------------------*
*&      Form  exit_screen
*&---------------------------------------------------------------------*
*       clear variables routine
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_screen.

  CLEAR : zmm_mpn,
          g_function,
          g_ok_9001,
          wa_mpn,
          g_ok_9010 ,
          g_exit ,
          g_action,
          g_butxt ,
          g_fctext,
          g_obj_code.
  CLEAR : ist_mpn, ist_zmmmpn, ist_mpn_srch, ist_mara.
  REFRESH : ist_mpn,ist_zmmmpn, ist_mpn_srch, ist_mara.
ENDFORM.                    " exit_screen

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
  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.
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
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         IMPORTING
              entry_new             = l_tc_new_top_line
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
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
*&      Form  get_valid_cocodes
*&---------------------------------------------------------------------*
*       Valid company codes routine
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_valid_cocodes.

  SELECT bukrs butxt FROM t001 INTO TABLE ist_t001 WHERE
                               land1 = 'IN' AND spras = 'E' AND
                               ktopl = 'ONGC' AND bukrs <> 'RNT'.

ENDFORM.                    " get_valid_cocodes
*&---------------------------------------------------------------------*
*&      Form  get_search_results
*&---------------------------------------------------------------------*
*       search results data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_search_results USING matnr.

  DATA :l_count(2) TYPE n.
  CHECK g_function = 'CRE' OR g_ok_9010 = '/CS' OR
        g_function = 'CHG'.
*  if not g_ok_9010 = '/CS'.
*    describe table ist_mpn lines l_count.
  CLEAR ist_mpn_srch.
  REFRESH ist_mpn_srch.
*    check l_count gt 0.
**    read table ist_mpn into wa_mpn index l_count.
*  endif.
  SELECT * FROM mara INTO TABLE ist_mara WHERE matkl IN r_mat_grp AND
*                                               mfrnr = wa_mpn-mfrnr and
                                               mtart = 'ZMPN' AND
*                                               bmatn = wa_mpn-matnr and
                                               bmatn = matnr AND
                                               matnr <> ' '.
  IF sy-subrc IS INITIAL.
    CLEAR ist_mpn_srch.
    REFRESH ist_mpn_srch.
    LOOP AT ist_mara.
      MOVE-CORRESPONDING ist_mara TO ist_mpn_srch.
      MOVE wa_makt-maktx TO ist_mpn_srch-maktx.
      SELECT SINGLE name1 FROM lfa1 INTO ist_mpn_srch-name1 WHERE
                                         lifnr = ist_mara-mfrnr.
      APPEND ist_mpn_srch.
      CLEAR : ist_mpn_srch, ist_mara.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_search_results
*&---------------------------------------------------------------------*
*&      Form  save_database
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_database.
  PERFORM check_req_fields.
  CHECK g_dup IS INITIAL.
  PERFORM get_document_number.
  PERFORM other_data.
  PERFORM action_request.

ENDFORM.                    " save_database
*&---------------------------------------------------------------------*
*&      Form  check_req_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_req_fields.
  CLEAR :wa_mpn, g_dup.
  LOOP AT ist_mpn INTO wa_mpn.
    READ TABLE ist_mpn_srch WITH KEY bmatn = wa_mpn-matnr
                                     mfrnr = wa_mpn-mfrnr
                                     mfrpn = wa_mpn-mfrpn.
    IF sy-subrc = 0.
      MESSAGE i815(zmm) WITH wa_mpn-matnr wa_mpn-mfrnr wa_mpn-mfrpn.
      g_dup = 1.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " check_req_fields
*&---------------------------------------------------------------------*
*&      Form  get_document_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_document_number.

  CHECK g_function = 'CRE'.
  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
            nr_range_nr             = '01'
            object                  = 'ZMM_MPN'
            quantity                = '1'
            toyear                  = '2005'
       IMPORTING
            number                  = g_docno
            returncode              = rc
       EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            buffer_overflow         = 7
            OTHERS                  = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " get_document_number
*&---------------------------------------------------------------------*
*&      Form  action_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM action_request.
  CASE g_function.
    WHEN 'CRE' OR 'CHG'.
      PERFORM modify_database ON COMMIT.
      PERFORM commit_rollback.
      IF g_docno <> ' ' AND sy-subrc = 0.
        """"""""""""""""""""""""""""""""""""""""""
"added by lipsy on 27.8.2015 for generating mpn code RD1K998398
REFRESH : g_tc_details_itab[].

      select * from zmm_mpn appending corresponding fields of table
                 g_tc_details_itab where docno = g_docno
                                   and sflag = 'N'.
      if sy-subrc = 0.
        clear ist_log.
      endif.


  if not g_tc_details_itab[] is initial.
    sort g_tc_details_itab.
    delete adjacent duplicates from g_tc_details_itab.
  endif.

  if not  g_tc_details_itab[] is initial.
    perform check_orig_mpncode.
    sort g_tc_details_itab.
    delete adjacent duplicates from g_tc_details_itab.
  endif.

        PERFORM generate_mpn_code.

        "end of addition by lipsy on 27.8.2015 for generating mpn code RD1K998398
        """""""""""""""""""""""""""""""""""""""""""""""""""


        MESSAGE s351(zmm) WITH g_docno.
      ELSE.
        MESSAGE s352(zmm) WITH zmm_mpn-docno.
      ENDIF.
    WHEN 'DEL'.
      PERFORM del_database_entry ON COMMIT.
      PERFORM commit_rollback.
      IF sy-subrc = 0.
        MESSAGE s356(zmm) WITH zmm_mpn-docno.
      ENDIF.
  ENDCASE.
ENDFORM.                    " action_request
*&---------------------------------------------------------------------*
*&      Form  other_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM other_data.

  CHECK NOT g_function = 'DEL'.
  LOOP AT ist_mpn INTO wa_mpn.
    IF NOT wa_mpn-matnr IS INITIAL AND                      "+rk001
       NOT wa_mpn-mfrnr IS INITIAL AND                      "+rk001
       NOT wa_mpn-mfrpn IS INITIAL.                         "+rk001
      MOVE-CORRESPONDING zmm_mpn TO ist_zmmmpn.
      MOVE-CORRESPONDING wa_mpn TO ist_zmmmpn.
      IF g_function = 'CRE'.
        ist_zmmmpn-docno = g_docno.
        ist_zmmmpn-sflag = 'N'.
      ENDIF.
      ist_zmmmpn-mandt = sy-mandt.
      IF g_function = 'CHG'.
        ist_zmmmpn-laeda = sy-datum.
        ist_zmmmpn-aenam = sy-uname.
      ENDIF.
      APPEND ist_zmmmpn.
    ENDIF.                                                  "+rk001
  ENDLOOP.

ENDFORM.                    " other_data
*&---------------------------------------------------------------------*
*&      Form  modify_database
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_database.
  IF NOT ist_zmmmpn[] IS INITIAL.
    CASE g_function.
      WHEN 'CRE'.
        MODIFY zmm_mpn FROM TABLE ist_zmmmpn.
      WHEN 'CHG'.
        DELETE FROM zmm_mpn WHERE docno = zmm_mpn-docno.
        MODIFY zmm_mpn FROM TABLE ist_zmmmpn.
    ENDCASE.
  ENDIF.

ENDFORM.                    " modify_database
*&---------------------------------------------------------------------*
*&      Form  commit_rollback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM commit_rollback.

  CASE sy-subrc.
    WHEN 0 .
      COMMIT WORK.
    WHEN OTHERS .
      ROLLBACK WORK .
      MESSAGE e671(zps).
  ENDCASE .

ENDFORM.                    " commit_rollback
*&---------------------------------------------------------------------*
*&      Form  clear_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_memory.

  CLEAR :zmm_mpn, wa_mpn, ist_mpn, g_docno, wa_makt, ist_zmmmpn,
         ist_mpn_srch.
  REFRESH : ist_zmmmpn, ist_mpn, ist_mpn_srch.

ENDFORM.                    " clear_memory
*&---------------------------------------------------------------------*
*&      Form  chk_item_open_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_item_open_request.

  SELECT * FROM ZMM_MPN UP TO 1 ROWS
 WHERE MATNR = ZMM_MPN-MATNR AND
 MFRNR = ZMM_MPN-MFRNR AND MFRPN = ZMM_MPN-MFRPN AND SFLAG = 'N'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc IS INITIAL.
    MESSAGE e330(zmm) WITH text-004 zmm_mpn-docno.
    EXIT.
  ENDIF.
ENDFORM.                    " chk_item_open_request
*&---------------------------------------------------------------------*
*&      Form  fcode_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fcode_table.

  ist_gui-fcode = 'CRE' .
  APPEND ist_gui .
  CLEAR ist_gui .
  ist_gui-fcode = 'CHG' .
  APPEND ist_gui .
  CLEAR ist_gui .
  ist_gui-fcode = 'DIS' .
  APPEND ist_gui .
  CLEAR ist_gui .
  ist_gui-fcode = 'DEL' .
  APPEND ist_gui .
  CLEAR ist_gui .

ENDFORM.                    " fcode_table
*&---------------------------------------------------------------------*
*&      Form  read_function_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_function_text.

  CALL FUNCTION 'K_CUA_FUNC_TEXT_FIND'
       EXPORTING
            e_program  = 'SAPMZMMMPN'
            e_langu    = sy-langu
            e_function = g_obj_code
       IMPORTING
            i_text     = g_fctext
       EXCEPTIONS
            not_found  = 0
            OTHERS     = 0.

ENDFORM.                    " read_function_text
*&---------------------------------------------------------------------*
*&      Form  del_database_entry
*&---------------------------------------------------------------------*
*       permanent del from DB item wise
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_database_entry.

  IF NOT zmm_mpn-docno IS INITIAL.
    DELETE FROM zmm_mpn WHERE docno = zmm_mpn-docno.
  ENDIF.

ENDFORM.                    " del_database_entry
*&---------------------------------------------------------------------*
*&      Form  chk_item_search_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_item_search_result.

  IF NOT ist_mpn_srch[] IS INITIAL AND g_ok_9010 <> '/CS'.
    CHECK NOT zmm_mpn-matnr IS INITIAL AND
          NOT zmm_mpn-mfrnr IS INITIAL AND
          NOT zmm_mpn-mfrpn IS INITIAL.
    READ TABLE ist_mpn_srch WITH KEY bmatn = zmm_mpn-matnr
                                     mfrnr = zmm_mpn-mfrnr
                                     mfrpn = zmm_mpn-mfrpn.
    IF sy-subrc = 0.
      MESSAGE e815(zmm) WITH zmm_mpn-matnr zmm_mpn-mfrnr zmm_mpn-mfrpn.
    ELSE.
      LOOP AT ist_mpn_srch WHERE mfrpn = zmm_mpn-mfrpn.
        MOVE-CORRESPONDING ist_mpn_srch TO ist_pop_list.
        ist_pop_list-matnr = ist_mpn_srch-bmatn.
        APPEND ist_pop_list.
      ENDLOOP.
      PERFORM pop_up_list.

    ENDIF.
  ENDIF.

ENDFORM.                    " chk_item_search_result
*&---------------------------------------------------------------------*
*&      Form  VERIFY_CERTIFICATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify_certificate.

  CALL SCREEN '2000' STARTING AT 30 10  ENDING AT 85 15.

ENDFORM.                    " VERIFY_CERTIFICATE
*&---------------------------------------------------------------------*
*&      Form  pop_up_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IST_POP_LIST  text
*----------------------------------------------------------------------*
FORM pop_up_list.
  g_token = 'D'.
  CALL SCREEN '2000' STARTING AT 5 10  ENDING AT 100 15.

ENDFORM.                    " pop_up_list
*&---------------------------------------------------------------------*
*&      Form  fetch_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_MPN_MFRPN  text
*----------------------------------------------------------------------*
FORM fetch_matnr USING p_mfrpn.
  IF NOT p_mfrpn IS INITIAL.
  SELECT matnr mfrnr mfrpn FROM mara INTO CORRESPONDING FIELDS OF TABLE
                                    ist_pop_list WHERE mfrpn = p_mfrpn ORDER BY PRIMARY KEY.

    IF NOT ist_pop_list[] IS INITIAL.
      LOOP AT ist_pop_list.
        IF ist_pop_list-matnr+0(1) = '9'.
          DELETE ist_pop_list INDEX sy-tabix.
        ELSE.
          SELECT MAKTX FROM MAKT INTO IST_POP_LIST-MAKTX UP TO 1 ROWS WHERE
 MATNR = IST_POP_LIST-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          MODIFY ist_pop_list INDEX sy-tabix.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT ist_pop_list[] IS INITIAL.
      PERFORM pop_up_list.
    ENDIF.
  ENDIF.
ENDFORM.                    " fetch_matnr
*&---------------------------------------------------------------------*
*&      Form  chk_org_new_vend_part
*&---------------------------------------------------------------------*
*       if org vend/partno = new vend/partno raise error message
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chk_org_new_vend_part.

  IF zmm_mpn-mfrnr = ist_mara-mfrnr AND
     zmm_mpn-mfrpn = ist_mara-mfrpn.
    MESSAGE e330(zmm) WITH zmm_mpn-matnr text-018 text-019.
  ENDIF.
ENDFORM.                    " chk_org_new_vend_part
*&---------------------------------------------------------------------*
*&      Form  GENERATE_MPN_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_mpn_code .
clear gt_buffer.
    refresh gt_buffer.
    if not g_tc_details_itab[] is initial.


      """""""""""""""
      PERFORM provide_lsmw_role.

      """"""""
      perform get_data_lsmw.
*      PERFORM SCH_LSMW.
      perform insert_process.
*      PERFORM CLOSE_JOB.

      """""""""""""""
      PERFORM remove_lsmw_role.
      """"""""""""
      perform populate_log.
      perform send_mail.
    endif.
    perform unlock_records.
    perform clear_source_tables.
ENDFORM.                    " GENERATE_MPN_CODE
""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 27.8.2015 RD1K998398

 form get_data_lsmw.

* Initializations
   perform initializations.

* Create initial structures with nodata characters
   perform create_initial_structures.

* Execute data conversion.
   perform execute_data_conversion.

* Close files
   perform close_files.

 endform.                    " GET_DATA_LSMW
*&---------------------------------------------------------------------*
*&      Form  lock_output_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form lock_output_file.

   call function '/SAPDMC/LSM_FILE_ENQUEUE'
     exporting
       filename    = g_dsn_out
     importing
       return_code = g_return
       lockuser    = g_lockuser.
   if g_return <> '0'.
     perform issue_message
             using 'A' '/SAPDMC/LSMW' '086' g_dsn_out g_lockuser.
   endif.

 endform.                    " lock_output_file
*&---------------------------------------------------------------------*
*&      Form  open_output_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form open_output_file.

   call function '/SAPDMC/LSM_SAVE_FILE_USE'
     exporting
       filename = g_dsn_out
       project  = g_project
       subproj  = g_subproj
       object   = g_object
       filetype = '3'
       action   = 'OW'
       batch    = sy-batch.
*             fromdx   = p_fromdx.

*  IF p_trfcpt = no.
*{   REPLACE        OCQK901323                                        1
*\   open dataset g_dsn_out for output in text mode.
   open dataset g_dsn_out for output in text mode ENCODING DEFAULT.
*}   REPLACE
   if sy-subrc <> 0.
     perform issue_message
                     using 'E' '/SAPDMC/LSMW' '804' g_dsn_out ' '.
   endif.
*  ENDIF.

 endform.                    " open_output_file
*&---------------------------------------------------------------------*
*&      Form  issue_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0602   text
*      -->P_0603   text
*      -->P_0604   text
*      -->P_G_DSN_OUT  text
*      -->P_G_LOCKUSER  text
*----------------------------------------------------------------------*
 form issue_message using    msgty msgid msgno msgv1 msgv2.

   if not msgv2 is initial.
     message id msgid type msgty number msgno with msgv1 msgv2.
   elseif not msgv1 is initial.
     message id msgid type msgty number msgno with msgv1.
   else.
     message id msgid type msgty number msgno.
   endif.

 endform.                    " issue_message
*&---------------------------------------------------------------------*
*&      Form  initializations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form initializations.
   g_userid = sy-uname.
   g_groupname = g_object.
   g_nodata = '/'.

   concatenate g_project '_' g_subproj '_' g_object '.lsmw.conv' into
   g_dsn_out.

* Lock files
   perform lock_output_file.

* Open output file
   perform open_output_file.

 endform.                    " initializations
*&---------------------------------------------------------------------*
*&      Form  create_initial_structures
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form create_initial_structures.

   perform initialize_with_nodata using
           'BGR00' init_bgr00.

   perform initialize_with_nodata using
           'BMM00' init_bmm00.

   perform initialize_with_nodata using
           'BMMH1' init_bmmh1.

 endform.                    " create_initial_structures
*&---------------------------------------------------------------------*
*&      Form  initialize_with_nodata
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0721   text
*      -->P_INIT_BGR00  text
*----------------------------------------------------------------------*
 form initialize_with_nodata using  p_tabname p_tab.

* Initialize every field with nodata
   field-symbols:
     <f>.

   data:
     l_string(50),
     lt_dfies like dfies occurs 50 with header line.

   data:
     l_len_trgstr type i.

   call function '/SAPDMC/LSM_TARGET_FIELDS_GET'
     exporting
       project                = g_project
       subproj                = g_subproj
       object                 = g_object
       segment                = p_tabname
       with_dataelements      = ' '
     tables
       t_dfies                = lt_dfies
     exceptions
       no_such_object         = 1
       no_such_segment        = 2
       no_target_fields_found = 3
       others                 = 4.

   loop at lt_dfies.
     l_len_trgstr = strlen( p_tabname ).
     if l_len_trgstr <= 25.
       concatenate 'init_' p_tabname '-' lt_dfies-fieldname
                   into l_string.
     else.
       concatenate 'in_' p_tabname '-' lt_dfies-fieldname
                   into l_string.
     endif.
     assign (l_string) to <f>.
     if lt_dfies-datatype = 'FLTP' or lt_dfies-datatype = 'QUAN'.
*      <F> = 0.
     else.
       <f> = g_nodata.
     endif.
   endloop.

 endform.                    " initialize_with_nodata
*&---------------------------------------------------------------------*
*&      Form  execute_data_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form execute_data_conversion.

   perform convert_transaction.
*   perform clear_source_tables.

 endform.                    " execute_data_conversion
*&---------------------------------------------------------------------*
*&      Form  close_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form close_files.

   call function '/SAPDMC/LSM_SAVE_FILE_USE'
        exporting
             filename       = g_dsn_out
             project        = g_project
             subproj        = g_subproj
             object         = g_object
             filetype       = '3'
             action         = 'CL'
             batch          = sy-batch
*            fromdx         = p_fromdx
             t_transactions = g_cnt_transactions_transferred
             t_records      = g_cnt_records_transferred.

* Unlock files
*  IF p_fromdx NE 'X' AND sy-batch NE 'X'.
   call function '/SAPDMC/LSM_FILE_DEQUEUE'
     exporting
       filename = g_dsn_out.
*  ENDIF.

*  IF p_trfcpt = no.
   close dataset g_dsn_out.
*  ENDIF.

 endform.                    " close_files
*&---------------------------------------------------------------------*
*&      Form  convert_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form convert_transaction.
   data wa_mara like mara.
   data l_tabix like sy-tabix.
   data l_count(3) type n.
   data:
     begin of gt_buffer1 occurs 0,
       record type tumls_segment,
       data(7960) type c,
     end of gt_buffer1.

   clear :g_tc_details_wa.

   loop at g_tc_details_itab into g_tc_details_wa .
     at new matnr.
       select single * from mara into wa_mara where
                                matnr = g_tc_details_wa-matnr.
       if sy-subrc is initial and wa_mara-mprof <> '0002'.
         perform update_mara using wa_mara. "upd mprof in mara
       endif.
     endat.
     perform lock_record.
     perform convert_0001.                                  " BGR00
     perform convert_0002.                                  " BMM00
     perform convert_0003.                                  " BMMH1
     clear g_tc_details_wa.
   endloop.

*{+rk001 remove duplicates
   if not gt_buffer[] is initial.
     gt_buffer1[] = gt_buffer[].
     sort gt_buffer1.
     delete adjacent duplicates from gt_buffer1.
     describe table gt_buffer1 lines l_count.
     clear gt_buffer[].

     loop at gt_buffer1.
       l_tabix = sy-tabix.
       append gt_buffer1 to gt_buffer.
       if l_tabix ge '3' and l_tabix lt l_count.
         read table gt_buffer1 index 1.
         if sy-subrc = 0.
           append gt_buffer1 to gt_buffer.
         endif.
         read table gt_buffer1 index 2.
         if sy-subrc = 0.
           append gt_buffer1 to gt_buffer.
         endif.
       else.
         continue.
       endif.
     endloop.

   endif.

   clear gt_buffer1. refresh gt_buffer1.
*}+rk001
*write to file
   perform transfer_transaction.

 endform.                    " convert_transaction
*&---------------------------------------------------------------------*
*&      Form  convert_0001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form convert_0001.

   check g_skip_transaction = no.

   g_skip_record = no.

   g_record = 'BGR00'.

* --- __BEGIN_OF_RECORD__
   bgr00 = init_bgr00.

* --- BGR00-STYPE
   bgr00-stype = '0'.

* --- BGR00-GROUP
   bgr00-group = g_groupname.

* --- BGR00-MANDT
   bgr00-mandt = sy-mandt.

* --- BGR00-USNAM
   bgr00-usnam = g_userid.

* --- BGR00-START
   bgr00-start = ''.

* --- BGR00-XKEEP
   bgr00-xkeep = ''.

* --- BGR00-NODATA
   bgr00-nodata = '/'.

* --- __END_OF_RECORD__

   perform transfer_record.

 endform.                    " convert_0001
*&---------------------------------------------------------------------*
*&      Form  TRANSFER_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form transfer_record.

   field-symbols:
     <l_record>.

   assign (g_record) to <l_record>.

   gt_buffer-record = g_record.
   gt_buffer-data = <l_record>.
   append gt_buffer.

 endform.                    " TRANSFER_RECORD
*&---------------------------------------------------------------------*
*&      Form  convert_0002
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form convert_0002.

   check g_skip_transaction = no.

   g_skip_record = no.

   g_record = 'BMM00'.

* --- __BEGIN_OF_RECORD__
   bmm00 = init_bmm00.

* --- BMM00-STYPE
   bmm00-stype = '1'.

* --- BMM00-TCODE
   bmm00-tcode = 'MM01'.

* --- BMM00-MATNR
   bmm00-matnr = ''.

* --- BMM00-MBRSH
   bmm00-mbrsh = 'O'.

* --- BMM00-MTART
   bmm00-mtart = 'ZMPN'.

* --- BMM00-XEIE1
   bmm00-xeie1 = 'X'.

* --- BMM00-XEIE2
   bmm00-xeie2 = 'X'.

* --- __END_OF_RECORD__
   perform transfer_record.

   g_skip_record = no.

 endform.                    " convert_0002
*&---------------------------------------------------------------------*
*&      Form  convert_0003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form convert_0003.

   data: lv_mara type mara.

   check g_skip_transaction = no.

   g_skip_record = no.

   g_record = 'BMMH1'.

* --- __BEGIN_OF_RECORD__
   bmmh1 = init_bmmh1.

* --- BMMH1-STYPE
   bmmh1-stype = '2'.

* --- BMMH1-MAKTX
* Target field: BMMH1-MAKTX Material description
*   TABLES MAKT.
   SELECT * FROM MAKT UP TO 1 ROWS
 WHERE MATNR = G_TC_DETAILS_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
   bmmh1-maktx = makt-maktx.

   select single * from mara into lv_mara where matnr = g_tc_details_wa-matnr.
   if sy-subrc eq 0.
     bmmh1-zzoem_name      = lv_mara-zzoem_name.
     bmmh1-zzcap_code      = lv_mara-zzcap_code.
     bmmh1-zzcap_name      = lv_mara-zzcap_name.
     bmmh1-zzmodelno       = lv_mara-zzmodelno.
     bmmh1-zzmodelextn     = lv_mara-zzmodelextn.
     bmmh1-zzref_book      = lv_mara-zzref_book.
     bmmh1-zzref_book_desc = lv_mara-zzref_book_desc.
     bmmh1-zzcsades        = lv_mara-zzcsades.
     bmmh1-zzsano          = lv_mara-zzsano.
   endif.
* --- BMMH1-MATKL
   bmmh1-matkl = g_tc_details_wa-matnr+0(2).

* --- BMMH1-BMATN
   bmmh1-bmatn = g_tc_details_wa-matnr.

* --- BMMH1-MFRNR
   bmmh1-mfrnr = g_tc_details_wa-mfrnr.

* --- BMMH1-MFRPN
   bmmh1-mfrpn = g_tc_details_wa-mfrpn.

* --- __END_OF_RECORD__
   perform transfer_record.

   g_skip_record = no.

 endform.                    " convert_0003
*&---------------------------------------------------------------------*
*&      Form  transfer_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form transfer_transaction.

   field-symbols:
     <buffer>.

   loop at gt_buffer.
     assign (gt_buffer-record) to <buffer>.
     move gt_buffer-data to <buffer>.
     transfer <buffer> to g_dsn_out.
     add 1 to g_cnt_records_transferred.
   endloop.

   clear:
   gt_buffer[].

 endform.                    " transfer_transaction
*&---------------------------------------------------------------------*
*&      Form  clear_source_tables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form clear_source_tables.
   clear : g_tc_details_itab, g_tc_details_wa.
 endform.                    " clear_source_tables
*&---------------------------------------------------------------------*
*&      Form  SCH_LSMW
*&---------------------------------------------------------------------*
*       Schedule LSMW
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form sch_lsmw.
   call function 'JOB_OPEN'
     exporting
       delanfrep        = ' '
       jobgroup         = ' '
       jobname          = g_jobname
     importing
       jobcount         = g_jobcount
     exceptions
       cant_create_job  = 01
       invalid_job_data = 02
       jobname_missing  = 03.
   if sy-subrc <> 0.
*-----HANDLING EXCEPTION --------------------------*
     case sy-subrc.
       when '01'.
         message e026(bt).
       when '02'.
         message e155(bt) with 'INVALID DATA'.
       when '03'.
         message e093(bt).
     endcase.
   endif.

 endform.                    " SCH_LSMW
*&---------------------------------------------------------------------*
*&      Form  INSERT_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form insert_process.

*Begin of <RD1K960036>.
*   SUBMIT rmdatind
*                   WITH %%%_r_p = 'X'
*                   WITH %%%_phy = g_dsn_out
*                   WITH level = '2'
*                   WITH erf_meld = 'X'
*                   WITH sperr = 'E'
*                   WITH prf_kz = ' '
*                   WITH flag_m = 'X'
*                   AND RETURN EXPORTING LIST TO MEMORY.
*                   USER SY-UNAME
*                   VIA JOB G_JOBNAME
*                   NUMBER G_JOBCOUNT
*                   .

   submit zrmdatind
                   with %%%_r_p = 'X'
                   with %%%_phy = g_dsn_out
                   with level = '2'
                   with erf_meld = 'X'
                   with sperr = 'E'
                   with prf_kz = ' '
                   with flag_m = 'X'
                   and return exporting list to memory.
*                   USER SY-UNAME
*                   VIA JOB G_JOBNAME
*                   NUMBER G_JOBCOUNT
*End of <RD1K960036>.
   if sy-subrc > 0.
     "error processing
   else.
     perform get_output_list.
     perform update_material.
   endif.

 endform.                    " INSERT_PROCESS
*&---------------------------------------------------------------------*
*&      Form  CLOSE_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form close_job.

   wa_starttime-sdlstrtdt = sy-datum.
   wa_starttime-sdlstrttm = sy-uzeit + 1.
   call function 'JOB_CLOSE'
        exporting
*             event_id             = wa_starttime-eventid
*             event_param          = wa_starttime-eventparm
*             event_periodic       = wa_starttime-periodic
             jobcount             = g_jobcount
             jobname              = g_jobname
*             laststrtdt           = wa_starttime-laststrtdt
*             laststrttm           = wa_starttime-laststrttm
*             prddays              = 1
*             prdhours             = 0
*             prdmins              = 0
*             prdmonths            = 0
*             prdweeks             = 0
*             sdlstrtdt            = wa_starttime-sdlstrtdt
*             sdlstrttm            = wa_starttime-sdlstrttm
             strtimmed            =  'X'
*             targetsystem         = g_host
*             DIRECT_START         = 'X'
        exceptions
             cant_start_immediate = 01
             invalid_startdate    = 02
             jobname_missing      = 03
             job_close_failed     = 04
             job_nosteps          = 05
             job_notex            = 06
             lock_failed          = 07
             others               = 99.
   if sy-subrc eq 0.
     "error processing
   endif.


 endform.                    " CLOSE_JOB
*&---------------------------------------------------------------------*
*&      Form  GET_OUTPUT_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_output_list.

   call function 'LIST_FROM_MEMORY'
     tables
       listobject = ist_list
     exceptions
       not_found  = 1
       others     = 2.

   call function 'LIST_TO_ASCI'
     tables
       listasci   = ist_lsmw_log
       listobject = ist_list.

   if not ist_lsmw_log[] is initial.
     loop at ist_lsmw_log into wa_lsmw_log.
       if wa_lsmw_log+0(1) = ' ' and ( wa_lsmw_log+4(1) = 'S' or
          wa_lsmw_log+4(1) = 'E' or wa_lsmw_log+4(1) = 'W' ).
         wa_merrdat-msgty = wa_lsmw_log+4(1).
         wa_merrdat-msgid = wa_lsmw_log+6(2).
         wa_merrdat-msgno = wa_lsmw_log+26(3).
         wa_merrdat-msgv1 = wa_lsmw_log+31(50).
         wa_merrdat-msgv2 = wa_lsmw_log+81(50).
         wa_merrdat-matnr = wa_merrdat-msgv1+9(9).
         append wa_merrdat to ist_merrdat.
         clear :wa_merrdat, wa_lsmw_log.
       endif.
     endloop.
   endif.

 endform.                    " GET_OUTPUT_LIST
*&---------------------------------------------------------------------*
*&      Form  POPULATE_LOG
*&---------------------------------------------------------------------*
*       POPULATE DI PROGRAM LOG INTO SCREEN INTERNAL TABLE IST_LOG
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form populate_log.
   data l_log(3) type n.
   data l_data(3) type n.
   data l_matnr type mara-matnr. "03062011

   if not ist_merrdat[] is initial.
     describe table ist_merrdat lines l_log.
     l_data = 0.
*     do l_log times.
*       clear : g_TC_DETAILS_wa, wa_merrdat,wa_log.
*       l_data = l_data + 1.
*       read table g_TC_DETAILS_itab into g_TC_DETAILS_wa
*                                    index l_data.
*       if sy-subrc = 0.
*         MOVE-CORRESPONDING g_TC_DETAILS_wa TO wa_log.
*         read table ist_merrdat into wa_merrdat index l_data.
*         if sy-subrc = 0.
*           wa_log-MSGNO = wa_merrdat-MSGNO.
*           wa_log-MSGTY = wa_merrdat-MSGTY.
*           concatenate wa_merrdat-MSGV1 wa_merrdat-MSGV2 into
*                                            wa_log-MSGV1.
*           append wa_log to ist_log.
*           if wa_log-MSGTY = 'S' and wa_log-MSGNO = '800'.
*             PERFORM UPDATE_TABLE.
*           endif.
*         endif.
*       endif.
*     enddo.
     clear : g_tc_details_wa, wa_merrdat,wa_log.
     loop at g_tc_details_itab into g_tc_details_wa.
* Begin of <> on 03062011 BY SUDHIR SHARMA
       SELECT MATNR INTO L_MATNR FROM MARA UP TO 1 ROWS WHERE BMATN = G_TC_DETAILS_WA-MATNR
 AND MFRNR = G_TC_DETAILS_WA-MFRNR AND MFRPN = G_TC_DETAILS_WA-MFRPN
 ORDER BY PRIMARY KEY .
 ENDSELECT.
       if sy-subrc = 0.
          update zmm_mpn set mpnco = l_matnr+0(9)
                             sflag = 'C'
                             where docno = g_tc_details_wa-docno
                                and matnr = g_tc_details_wa-matnr
                                and mfrnr = g_tc_details_wa-mfrnr
                                and mfrpn = g_tc_details_wa-mfrpn.


       endif.
       l_data = l_data + 1.
       move-corresponding g_tc_details_wa to wa_log.
       read table ist_merrdat into wa_merrdat index l_data.
       if sy-subrc = 0.
         wa_log-msgno = wa_merrdat-msgno.
         wa_log-msgty = wa_merrdat-msgty.
         concatenate l_matnr wa_merrdat-msgv2 into        "WA_MERRDAT-MSGV1
                                      wa_log-msgv1.
         append wa_log to ist_log.
*         IF WA_LOG-MSGTY = 'S' AND WA_LOG-MSGNO = '800'.
*           PERFORM UPDATE_TABLE.
*         ENDIF.
       endif.
* End of <> on 03062011
     endloop.

   endif.

 endform.                    " POPULATE_LOG
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form update_table.

*   update zmm_mpn set: sflag = 'C', mpnco = wa_log-MSGV1+9(9)
*                                 where MATNR = wa_log-matnr
*                                  and MFRNR = g_TC_DETAILS_wa-mfrnr
*                                  and MFRPN = g_TC_DETAILS_wa-mfrpn
*                                  and DOCNO = wa_log-docno.
*                                  and MPNCO = ' '.
   select single * from zmm_mpn where docno = wa_log-docno
                                and matnr = wa_log-matnr
                                and mfrnr = g_tc_details_wa-mfrnr
                                and mfrpn = g_tc_details_wa-mfrpn.
   if sy-subrc = 0.
     zmm_mpn-mpnco = wa_log-msgv1+9(9).
     zmm_mpn-sflag = 'C'.
     if not zmm_mpn-matnr is initial and                    "+rk001
        not zmm_mpn-mfrnr is initial and                    "+rk001
        not zmm_mpn-mfrpn is initial.                       "+rk001
       modify zmm_mpn.
       if sy-subrc = 0.
         commit work.
       else.
         rollback work.
       endif.
     endif.
   endif.

 endform.                    " UPDATE_TABLE
*&---------------------------------------------------------------------*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form lock_record.

   call function 'ENQUEUE_EZMM_MPN'
     exporting
       mode_zmm_mpn   = 'E'
       mandt          = sy-mandt
       docno          = g_tc_details_wa-docno
       matnr          = g_tc_details_wa-matnr
       mfrnr          = g_tc_details_wa-mfrnr
       mfrpn          = g_tc_details_wa-mfrpn
     exceptions
       foreign_lock   = 1
       system_failure = 2
       others         = 3.
   if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   endif.

 endform.                    " lock_record
*&---------------------------------------------------------------------*
*&      Form  unlock_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form unlock_records.
   clear g_tc_details_wa.

   loop at g_tc_details_itab into g_tc_details_wa.
     call function 'DEQUEUE_EZMM_MPN'
       exporting
         mode_zmm_mpn = 'E'
         mandt        = sy-mandt
         docno        = g_tc_details_wa-docno
         matnr        = g_tc_details_wa-matnr
         mfrnr        = g_tc_details_wa-mfrnr
         mfrpn        = g_tc_details_wa-mfrpn.

   endloop.
 endform.                    " unlock_records
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form send_mail.

* Fill the document
   describe table ist_log lines g_entries.
   if g_entries > 0.
     sort ist_log by docno.
     delete adjacent duplicates from ist_log comparing matnr.
     wa_doc_chng-obj_name = wa_log-docno.
     wa_doc_chng-obj_descr = 'mpn code generation request status'.
     wa_doc_chng-sensitivty = 'B'.

     loop at ist_log into wa_log.
       if sy-tabix = 1.
         wa_doc_chng-obj_name = wa_log-docno.
       endif.
       ist_objcont = wa_log-msgv1.
       if wa_log-msgty = 'S'.
         concatenate ist_objcont text-100 wa_log-matnr text-101  "#EC CI_FLDEXT_OK[2215424]
         wa_log-docno text-102 into ist_objcont separated by space.
       else.
         concatenate ist_objcont text-100 wa_log-matnr text-101  "#EC CI_FLDEXT_OK[2215424]
         wa_log-docno text-103 into ist_objcont separated by space.
       endif.
       append ist_objcont.
       at new ernam.
* Fill the receiver list
         clear ist_reclist.
         ist_reclist-receiver = wa_log-ernam.
*         ist_reclist-rec_type = 'b'.
         ist_reclist-express = 'X'.
         append ist_reclist.
       endat.
     endloop.
     wa_doc_chng-doc_size = ( g_entries - 1 ) * 255 +
                            strlen( ist_objcont ).
   endif.

   if not ist_reclist[] is initial.
     sort ist_reclist.
     delete adjacent duplicates from ist_reclist.
   endif.

* Send the document
   call function 'SO_NEW_DOCUMENT_SEND_API1'
     exporting
       document_type              = 'RAW'
       document_data              = wa_doc_chng
       put_in_outbox              = 'X'
     tables
       object_content             = ist_objcont
       receivers                  = ist_reclist
     exceptions
       too_many_receivers         = 1
       document_not_sent          = 2
       operation_no_authorization = 4
       others                     = 99.


   case sy-subrc.
     when 0.
       loop at ist_reclist.
         if ist_reclist-receiver = space.
           g_name = ist_reclist-rec_id.
         else.
           g_name = ist_reclist-receiver.
         endif.
         if ist_reclist-retrn_code = 0.
           write: / g_name, ': succesfully sent'.
         else.
           write: / g_name, ': error occured'.
         endif.
       endloop.
     when 1.
       write: / 'too many receivers specified !'.
     when 2.
       write: / 'no receiver got the document !'.
     when 4.
       write: / 'missing send authority !'.
     when others.
       write: / 'unexpected error occurred !'.
   endcase.

   clear : ist_reclist, ist_objcont, wa_doc_chng.
   refresh : ist_reclist, ist_objcont.

 endform.                    " SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  update_mara
*&---------------------------------------------------------------------*
*       use Call transaction MM02 to update MARA Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form update_mara using wa_mara structure mara.
* Begin of <RD1K960611>
* Modified the length, because it was not slection proper view if no. of
* views for Maerial Master is more than 10.
*   DATA : l_strlen TYPE n.
   data:   messtab like bdcmsgcoll occurs 0 with header line.
   data : l_strlen(2) type n.
* End of <RD1K960611>

   clear : ist_bdcdata, messtab.
   refresh : ist_bdcdata, messtab.

   l_strlen = strlen( wa_mara-pstat ).

   perform bdc_dynpro      using 'SAPLMGMM' '0060'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'RMMG1-MATNR'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=ENTR'.
   perform bdc_field       using 'RMMG1-MATNR'
                                  wa_mara-matnr.
   perform bdc_dynpro      using 'SAPLMGMM' '0070'.

   if l_strlen lt 6.
* Begin of <RD1K976493> on 03060211 by Sudhir Sharma
     perform bdc_field       using 'BDC_CURSOR'
                                'MSICHTAUSW-DYTXT(04)'.
     perform bdc_field       using 'BDC_OKCODE'
                                   '=ENTR'.
     perform bdc_field       using 'MSICHTAUSW-KZSEL(04)'
                                   'X'.
*     PERFORM BDC_FIELD       USING 'BDC_CURSOR'
*                                   'MSICHTAUSW-DYTXT(06)'.
*     PERFORM BDC_FIELD       USING 'BDC_OKCODE'
*                                   '=ENTR'.
*     PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(06)'
*                                   'X'.
* End of <RD1K976493>
   else.
     perform bdc_field       using 'BDC_CURSOR'
                                   'MSICHTAUSW-DYTXT(10)'.
     perform bdc_field       using 'BDC_OKCODE'
                                   '=ENTR'.
     perform bdc_field       using 'MSICHTAUSW-KZSEL(10)'
                                   'X'.
   endif.
   perform bdc_dynpro      using 'SAPLMGMM' '0080'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'RMMG1-WERKS'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=ENTR'.
   perform bdc_dynpro      using 'SAPLMGMM' '4000'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '/00'.
*perform bdc_field       using 'MARA-MEINS'
*                              'NO'.
*perform bdc_field       using 'MARA-MATKL'
*                              '21'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'MARA-MPROF'.
   perform bdc_field       using 'MARA-MPROF'
                                 '0002'.
*perform bdc_field       using 'MARA-MFRPN'
*                              '157098'.
*perform bdc_field       using 'MARA-MFRNR'
*                              '300001'.
   perform bdc_dynpro      using 'SAPLSPO1' '0300'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=YES'.
   call transaction 'MM02' using ist_bdcdata mode 'N' update 'L' messages into messtab.
*  saB_PUNIT
   if sy-subrc <> 0.
     message e330(zmm) with text-106.
     leave program.
   endif.
 endform.                    " update_mara

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
 form bdc_dynpro using program dynpro.
   clear ist_bdcdata.
   ist_bdcdata-program  = program.
   ist_bdcdata-dynpro   = dynpro.
   ist_bdcdata-dynbegin = 'X'.
   append ist_bdcdata.
 endform.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
 form bdc_field using fnam fval.
   clear ist_bdcdata.
   ist_bdcdata-fnam = fnam.
   ist_bdcdata-fval = fval.
   append ist_bdcdata.
 endform.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  check_orig_mpncode
*&---------------------------------------------------------------------*
* chk if mpn code has been created for org.vendor/partno if not generate
*----------------------------------------------------------------------*
* g_tc_details_itab - materials for which mpn code to be generated
* ist_bmatn - orig vendor/partno for the materials in g_tc_details_itab
*
*----------------------------------------------------------------------*
 form check_orig_mpncode.
   data l_index like sy-tabix.
   data l_tc_details_itab like g_tc_details_itab with header line.
   refresh l_tc_details_itab.

*----GET ORIG VEND/PARTNO OF ALL MATERIALS SELECTED ------*
refresh:ist_bmatn[].

   select matnr mfrnr mfrpn bmatn from mara into table ist_bmatn
                                 for all entries in g_tc_details_itab
                                 where matnr =  g_tc_details_itab-matnr
                                 and mfrnr <> ' '
                                 and mfrpn <> ' '
                                 and bmatn = ' '.
   if sy-subrc = 0.
     perform get_matnr_mpncode.
     loop at ist_bmatn into wa_bmatn.
       move sy-tabix to l_index.
       read table ist_mara2 with key bmatn = wa_bmatn-matnr
                                transporting no fields.
       if sy-subrc = 0.
*---delete matnr's which have mpn code for org vend/partno
         delete ist_bmatn index l_index.
       endif.
     endloop.

     loop at g_tc_details_itab into g_tc_details_wa.
       read table ist_bmatn into wa_bmatn with key
                                 matnr = g_tc_details_wa-matnr.
       if sy-subrc is initial.
         move-corresponding g_tc_details_wa to l_tc_details_itab.
         l_tc_details_itab-mfrnr = wa_bmatn-mfrnr.
         l_tc_details_itab-mfrpn = wa_bmatn-mfrpn.
         append l_tc_details_itab.
       endif.
       append g_tc_details_wa to l_tc_details_itab.
     endloop.
   endif.

   clear l_tc_details_itab.
   g_tc_details_itab[] = l_tc_details_itab[].

 endform.                    " check_orig_mpncode
*&---------------------------------------------------------------------*
*&      Form  get_matnr_no_mpncode
*&---------------------------------------------------------------------*
*       get matnr with mpn code for its org vend/partno
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_matnr_mpncode.

   select bmatn from mara into table ist_mara2 for all entries in
                              g_tc_details_itab where
                              bmatn =  g_tc_details_itab-matnr.
   if sy-subrc = 0.
     sort ist_mara2.
     delete adjacent duplicates from ist_mara2.
   endif.
 endform.                    " get_matnr_no_mpncode
*&---------------------------------------------------------------------*
*&      Form  UPDATE_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form update_material .
   data: lt_mat type standard table of merrdat,
         ls_mara1 type mara,
         ls_mara2 type mara.
   field-symbols: <fs_mat> type merrdat.

   lt_mat[] = ist_merrdat[].

   if lt_mat[] is not initial.
     loop at lt_mat assigning <fs_mat>.
       clear: ls_mara1, ls_mara2.
       select single * from mara into ls_mara1 where matnr = <fs_mat>-matnr.
       if sy-subrc eq 0 .
         select single * from mara into ls_mara2 where matnr = ls_mara1-bmatn.
         if sy-subrc eq 0 .
           perform update using ls_mara1 ls_mara2.
         endif.
       endif.
     endloop.
   endif.
 endform.                    " UPDATE_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MARA2  text
*----------------------------------------------------------------------*
 form update  using  p_ls_mara1 type mara
                     p_ls_mara2 type mara.
*perform open_group.
   data:   messtab like bdcmsgcoll occurs 0 with header line.

   clear: ist_bdcdata[], ist_bdcdata, messtab, messtab[].


   perform bdc_dynpro      using 'SAPLMGMM' '0060'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'RMMG1-MATNR'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=AUSW'.
   perform bdc_field       using 'RMMG1-MATNR'
                                 p_ls_mara1-matnr.
   perform bdc_dynpro      using 'SAPLMGMM' '0070'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'MSICHTAUSW-DYTXT(01)'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=ENTR'.
   perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                                 'X'.
   perform bdc_dynpro      using 'SAPLMGMM' '4000'.
   perform bdc_field       using 'BDC_OKCODE'
                                 '=BU'.
*perform bdc_field       using 'MAKT-MAKTX'
*                              'CIRCUIT BREAKER SHUNT 480V,3P,100A FDC'.
*perform bdc_field       using 'MARA-MATKL'
*                              '28'.
*perform bdc_field       using 'MARA-BMATN'
*                              '280200142'.
*perform bdc_field       using 'MARA-MFRPN'
*                              'XS100NB'.
*perform bdc_field       using 'MARA-MFRNR'
*                              '400853'.
   perform bdc_field       using 'BDC_CURSOR'
                                 'MARA-ZZCAP_CODE'.
   perform bdc_field       using 'MARA-ZZCAP_CODE'
                                 p_ls_mara2-zzcap_code.
   perform bdc_field       using 'MARA-ZZMODELNO'
                                 p_ls_mara2-zzmodelno.
   perform bdc_field       using 'MARA-ZZMODELEXTN'
                                 p_ls_mara2-zzmodelextn.
   perform bdc_field       using 'MARA-ZZREF_BOOK'
                                 p_ls_mara2-zzref_book.
   perform bdc_field       using 'MARA-ZZREF_BOOK_DESC'
                                 p_ls_mara2-zzref_book_desc.
   perform bdc_field       using 'MARA-ZZSANO'
                                 p_ls_mara2-zzsano.
   perform bdc_field       using 'MARA-ZZCSADES'
                                 p_ls_mara2-zzcsades.
   call transaction 'MM02' using ist_bdcdata mode 'N' update 'L' messages into messtab.

*perform close_group.
 endform.                    " UPDATE



*&---------------------------------------------------------------------*
*&      Form  PROVIDE_LSMW_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM provide_lsmw_role .

lv_syuname = sy-uname.
clear: w_agr_users .
select single * from agr_users into w_agr_users where uname = lv_syuname.
  w_agr_users-agr_name = 'D:MM_MAT_BASIC_ZMPN'."'Z:CORETEAM_ALL_MEMBERS'.
  w_agr_users-from_dat = sy-datum .
  w_agr_users-to_dat = sy-datum.
  perform update_agrname on commit.
  perform commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.

call function 'PRGN_ACTIVITY_GROUP_USERPROFC'
  exporting
    activity_group                      =  'D:MM_MAT_BASIC_ZMPN'
   display_messages                    = space
    collective_role                     = space
*   DB_UPDATE                           = 'X'
* IMPORTING
*   MESSAGES                            =
* TABLES
*   PROCESSED_SINGLE_ROLES              =
*   SGLS_IN_COLL                        =
* CHANGING
*   RETURN_TAB                          =
 exceptions
   no_authority_for_user_compare       = 1
   authority_incomplete                = 2
   child_agr_enqueued                  = 3
   others                              = 4
          .
if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
endif.

  commit work.
  sy-uname = lv_syuname.
  clear: w_agr_users.

ENDFORM.                    " PROVIDE_LSMW_ROLE
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agrname .
insert agr_users from w_agr_users.
ENDFORM.                    " UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*&      Form  REMOVE_LSMW_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM remove_lsmw_role .
select single * from agr_users into w_agr_users where agr_name =   'D:MM_MAT_BASIC_ZMPN'
  and uname = lv_syuname.
  perform update_agr on commit.
  perform commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.

call function 'PRGN_ACTIVITY_GROUP_USERPROFC'
  exporting
    activity_group                      = 'D:MM_MAT_BASIC_ZMPN'
   display_messages                     = space
    collective_role                     = space
*   DB_UPDATE                           = 'X'
* IMPORTING
*   MESSAGES                            =
* TABLES
*   PROCESSED_SINGLE_ROLES              =
*   SGLS_IN_COLL                        =
* CHANGING
*   RETURN_TAB                          =
 exceptions
   no_authority_for_user_compare       = 1
   authority_incomplete                = 2
   child_agr_enqueued                  = 3
   others                              = 4
          .
if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
endif.

  commit work.
ENDFORM.                    " REMOVE_LSMW_ROLE
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agr .
  delete agr_users from w_agr_users.
ENDFORM.                    " UPDATE_AGR


""end of addition by lipsy on 27.8.2015  RD1K998398

""""""""""""""""""""""""""""""""""""""""""""""""
