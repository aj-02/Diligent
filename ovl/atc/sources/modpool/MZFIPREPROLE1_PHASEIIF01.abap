*--- MAIN PROGRAM: MZFIPREPROLE1_PHASEIIF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZFIPREPROLEF01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bac_confirm_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bac_confirm_100.

  DATA l_choice.
  CLEAR l_choice.
  IF g_mode <> 'DIS'.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        textline1      = 'Data will be lost, Want to quit? '
        titel          = 'BACK'
        start_column   = 25
        start_row      = 6
        cancel_display = ''
      IMPORTING
        answer         = l_choice.

    IF l_choice = 'J'.
*       perform clear_var.
      CLEAR old_ok_code.
      CLEAR moduleid.
      CLEAR dynnr.
      CLEAR zic_prep_rolereq-userid.
      CLEAR zic_prep_rolereq-rsn_code.
      CLEAR zic_prep_rolereq-telno.
      CLEAR zic_prep_rolereq-fr_date_auth.
      CLEAR zic_prep_rolereq-to_date_auth.
      CLEAR zic_prep_rolereq-rsn_text1.
      CLEAR zic_prep_rolereq-name.
      CLEAR zic_prep_rolereq-designation.
      CLEAR zic_prep_rolereq-disc_fi_flag.
      CLEAR zic_prep_rolereq-ccode.
      CLEAR zic_prep_rolereq-s_desc.
      CLEAR zic_prep_rolereq-desig_level.
      CALL SCREEN 100.
      CLEAR l_choice.
    ENDIF.

  ENDIF.

ENDFORM.                    " bac_confirm_100
*&---------------------------------------------------------------------*
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sttab.

  IF sy-tcode = 'ZIC_AUTH_FI_REP'.
*    old_ok_code = 'DISPLAY'.
    GET PARAMETER ID 'ZREQNO' FIELD zic_prep_rolereq-docno.
  ENDIF.

  REFRESH it_tab.
  CLEAR wa_tab.

  IF old_ok_code =  'CREATE' OR
        old_ok_code = 'CROSSCO' OR
        old_ok_code = 'CRCROLES' OR
        old_ok_code =  'CHANGE' OR
        old_ok_code =  'RELEASE' OR
        old_ok_code =  'APPROVE' OR
        old_ok_code = 'DISPLAY'  OR
        old_ok_code = 'ROLE_DEL'  OR
        old_ok_code = 'DELETE'.

    MOVE 'CREATE' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'CHANGE' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'DELETE' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'DISPLAY' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'RELEASE' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'APPROVE' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'SUIM' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ROLE_DEL' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'CROSSCO' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'CRCROLES' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
*     move 'ATTACH' to wa_tab-fcode.
*     append wa_tab to it_tab.

  ELSE.

    MOVE 'CHECK' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ATTACH' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'LIST' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'SAV' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.

  ENDIF.

ENDFORM.                    " fill_sttab
*&---------------------------------------------------------------------*
*&      Form  lock_reqhd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_reqhd.

  CALL FUNCTION 'ENQUEUE_EZ_IC_PREPHDR'
    EXPORTING
*     mode_zmm_cdhd         = 'E'
      mode_zic_prep_rolereq = 'E'
      mandt                 = sy-mandt
      docno                 = zic_prep_rolereq-docno
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    MOVE 'Y' TO g_lock.
  ENDIF.

ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  get_correspondence
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_correspondence.

  DATA : l_cors LIKE thead-tdname.

  IF old_ok_code <> 'CREATE' OR
     old_ok_code <> 'CROSSCO'.

    REFRESH lines_cors.

    MOVE zic_prep_rolereq-docno TO l_cors.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = '0001'
        language                = sy-langu
        name                    = l_cors
        object                  = 'ZHELP'
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
      read_flag = ''.
      zic_prep_rolereq-long_text_fl = ''.
    ELSE.
      read_flag = 'X'.
      zic_prep_rolereq-long_text_fl = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_correspondense

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
      g_ins_flag = 'X'.

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

  IF sy-ucomm = 'TABLCTRL110_INSR'.
    CLEAR okcode_100.
    CLEAR sy-ucomm.
  ENDIF.

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

  g_i = l_line.
  g_field = 'zic_prep_rolerei-ROLE_NAME'.

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

    IF <mark_field> = 'X'. " and <WA>+54(1) = ''.
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
***********************************************************************
  g_tc_lines = <tc>-lines.
***********************************************************************

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
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
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
  FIELD-SYMBOLS <mark_field1>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* mark all filled lines                                                *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *

    IF p_tc_name = 'TABLECTRL_215'.
      ASSIGN COMPONENT 'ROLE_SEL' OF STRUCTURE <wa> TO <mark_field1>.
      <mark_field1> = 'X'.
    ELSE.
      ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
      <mark_field> = 'X'.
    ENDIF.

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
  FIELD-SYMBOLS <mark_field1>.
*-END OF LOCAL DATA----------------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

* demark all filled lines                                              *
  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    IF p_tc_name = 'TABLECTRL_215'.
      ASSIGN COMPONENT 'ROLE_SEL' OF STRUCTURE <wa> TO <mark_field1>.
      <mark_field1> = space.
    ELSE.
      ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
      <mark_field> = space.
    ENDIF.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  HELP_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_list.

  IF zic_prep_rolereq-ccode IS INITIAL.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-CCODE'.
    MESSAGE i082(zhelp).
    LEAVE TO SCREEN 0.
  ENDIF.
  REFRESH : it_cond.
  CONCATENATE 'FICTR'  'LIKE'  INTO g_line SEPARATED BY
  space.
  CONCATENATE g_line+0(10) '''' zic_prep_rolereq-ccode '%' ''''  INTO
              g_line.
  APPEND g_line TO it_cond.
  IF help_list_flag <> 'X' .
    SELECT * FROM m_fistb INTO CORRESPONDING FIELDS OF TABLE it_m_fistb
                  WHERE (it_cond).
    SORT IT_M_FISTB BY BEZEICH SPRAS1 BOSSID FIKRS FICTR. help_list_flag = 'X'.
    REFRESH it_cond.
  ENDIF.
  LOOP AT it_m_fistb INTO wa_m_fistb.
*
    IF wa_m_fistb-fictr = zic_prep_rolereq-fundc OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc2 OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc3 OR
       wa_m_fistb-fictr = zic_prep_rolereq-fundc4.
      wa_m_fistb-g_mark = 'X'.
    ENDIF.

    IF old_ok_code = 'DISPLAY' OR old_ok_code = 'APPROVE'.
      IF wa_m_fistb-g_mark = 'X'.
        WRITE: / wa_m_fistb-fictr, wa_m_fistb-bezeich.
      ENDIF.
    ELSE.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
            wa_m_fistb-bezeich.
    ENDIF.

    HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*    CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr.
  ENDLOOP.
  lines = sy-linno .

ENDFORM.                    " HELP_LIST
*&---------------------------------------------------------------------*
*&      Form  tick_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tick_all.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
           COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.
*
      wa_m_fistb-g_mark = 'X'.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    lines = sy-linno .

  ENDIF.


ENDFORM.                    " tick_all
*&---------------------------------------------------------------------*
*&      Form  notick_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM notick_all.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
         COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.
*
      wa_m_fistb-g_mark = ''.
      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    lines = sy-linno .

  ENDIF.

ENDFORM.                    " notick_all
*&---------------------------------------------------------------------*
*&      Form  pick
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pick.

  sy-lsind = 0.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'SELALL' TO wa_tab.
  APPEND wa_tab TO tab.
  MOVE 'DESELALL' TO wa_tab.
  APPEND wa_tab TO tab.

  DATA l_blank VALUE ''.

  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
         COLOR COL_HEADING.
  ULINE.


  IF flag_s_fundc = 'X'.
*    refresh : s_fundc.
    LOOP AT it_m_fistb INTO wa_m_fistb.

      lines_index = sy-tabix + 4.

      READ LINE lines_index FIELD VALUE wa_m_fistb-g_mark.

      WRITE: / wa_m_fistb-g_mark AS CHECKBOX, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.

      IF wa_m_fistb-g_mark <> 'X'.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc.
          zic_prep_rolereq-fundc = 'X'.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc2.
          CLEAR zic_prep_rolereq-fundc2.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc3.
          CLEAR zic_prep_rolereq-fundc3.
        ENDIF.

        IF wa_m_fistb-fictr = zic_prep_rolereq-fundc4.
          CLEAR zic_prep_rolereq-fundc4.
        ENDIF.

      ENDIF.

      MODIFY  it_m_fistb FROM wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    ENDLOOP.

    help_list_flag = 'X'.

    lines = sy-linno .

    READ TABLE it_m_fistb INTO wa_m_fistb WITH KEY g_mark = 'X'.

    IF sy-subrc = 0.

      zic_prep_rolereq-fundc = wa_m_fistb-fictr.

    ELSE.

      CLEAR zic_prep_rolereq-fundc .

    ENDIF.

  ENDIF.

ENDFORM.                    " pick
*&---------------------------------------------------------------------*
*&      Form  check_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items.

  PERFORM validations1.

ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_request.

  IF old_ok_code = 'CREATE' OR
     old_ok_code = 'CROSSCO' OR
     old_ok_code = 'CRCROLES' OR
     old_ok_code = 'ROLE_DEL'.

    PERFORM gen_no.

  ENDIF.

  IF old_ok_code = 'RELEASE' OR
     old_ok_code = 'APPROVE'.

    g_release = zic_prep_rolereq-req_cr_fl.
    g_approve = zic_prep_rolereq-req_appfi_fl.
*    g_approve0 = ZIC_PREP_ROLEREQ-req_app0_fl.
*    g_approve1 = ZIC_PREP_ROLEREQ-req_app1_fl.


    SELECT SINGLE * FROM zic_prep_rolereq
                    WHERE docno = zic_prep_rolereq-docno.

    IF zic_prep_rolereq-req_cr_fl IS INITIAL.
      zic_prep_rolereq-req_cr_fl = g_release.
    ENDIF.
    IF zic_prep_rolereq-req_appfi_fl IS INITIAL.
      zic_prep_rolereq-req_appfi_fl = g_approve.
    ENDIF.


    CLEAR : g_release, g_approve.

    IF g_release = 'X' AND ( g_approve <> 'X' ).

      g_app_rel = 'X'.

    ENDIF.

  ENDIF.

  IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
    MESSAGE i089(zhelp).
  ELSE.
    IF sy-tcode = 'ZIC_AUTH_FI_REP'.
      PERFORM insert_header_assign.
      PERFORM create_roles.
    ELSE.
      PERFORM insert_header.
    ENDIF.
  ENDIF.

ENDFORM.                    " Save_request
*&---------------------------------------------------------------------*
*&      Form  gen_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gen_no.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZDOCNUMB'
    IMPORTING
      number      = zdocnumb.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " gen_no
*&---------------------------------------------------------------------*
*&      Form  insert_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_header.

  zic_prep_rolereq-mandt = sy-mandt.
  IF old_ok_code = 'CREATE'.
    zic_prep_rolereq-docno = zdocnumb.
  ENDIF.

  IF old_ok_code = 'ROLE_DEL'.
    zic_prep_rolereq-docno = zdocnumb.
    zic_prep_rolereq-delimit = 'X'.
  ENDIF.


****************************************
  SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
      a~persk a~sbmod  c~designo c~r_p_cd c~version
    d~sdesig_text AS designation d~adesig_text AS adesignation
    d~disc_cd AS disc_cd
      INTO CORRESPONDING FIELDS OF TABLE ist_data
       FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c       " Bipin + 02/08/2016
       ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
          ON c~designo = d~desig_code AND
              c~r_p_cd  = d~r_p_cd AND
              c~version = d~version )
           WHERE a~pernr = zic_prep_rolereq-userid AND
                 a~sprps = ' ' AND
                 a~endda = '99991231' AND
                 c~sprps = ' ' AND
                 c~endda = '99991231' .

  IF sy-subrc = 0.
    READ TABLE ist_data INDEX 1. "#EC CI_NOORDER

    zic_prep_rolereq-persa = ist_data-werks .

  ENDIF.
****************************************


  IF zic_prep_rolereq-useridcr IS INITIAL.

    zic_prep_rolereq-useridcr = sy-uname.
    zic_prep_rolereq-cr_date  = sy-datum.

    CLEAR zusrmst.

    SELECT SINGLE * FROM usr02 WHERE bname =
                               zic_prep_rolereq-useridcr.

    IF sy-subrc NE 0.

    ELSE.
*
      CLEAR ist_data.
      REFRESH ist_data.

      SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
           a~persk a~sbmod  c~designo c~r_p_cd c~version
         d~sdesig_text AS designation d~adesig_text AS adesignation
           INTO CORRESPONDING FIELDS OF TABLE ist_data
      FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c   " Bipin + 02/08/2016
            ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
               ON c~designo = d~desig_code AND
                   c~r_p_cd  = d~r_p_cd AND
                   c~version = d~version )
                WHERE a~pernr = zic_prep_rolereq-useridcr AND
                      a~sprps = ' ' AND
                      a~endda = '99991231' AND
                      c~sprps = ' ' AND
                      c~endda = '99991231' .

      IF sy-subrc = 0.
        READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
        zic_prep_rolereq-namecr = ist_data-name.
        zic_prep_rolereq-desigcr = ist_data-designation.
      ENDIF.

    ENDIF.

    CLEAR : ist_data.
    REFRESH : ist_data.

  ENDIF.


  IF zic_prep_rolereq-useridap IS INITIAL.

    IF old_ok_code = 'APPROVE' AND
          ( zic_prep_rolereq-req_appfi_fl = 'X' ).
      zic_prep_rolereq-useridap = sy-uname.
      zic_prep_rolereq-app_date  = sy-datum.

      IF zic_prep_rolereq-status = 'IC' OR
         zic_prep_rolereq-status = 'IR'.
        zic_prep_rolereq-status   = 'IF'.
      ELSE.
        zic_prep_rolereq-status   = 'N'.
      ENDIF.

      CLEAR zusrmst.

      SELECT SINGLE * FROM usr02 WHERE bname =
                            zic_prep_rolereq-useridap.

      IF sy-subrc NE 0.

      ELSE.

        CLEAR ist_data.
        REFRESH ist_data.

        SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text AS designation
                 d~adesig_text AS adesignation
             INTO CORRESPONDING FIELDS OF TABLE ist_data
             FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c   " Bipin + 02/08/2016
       ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
       ON c~designo = d~desig_code AND
           c~r_p_cd  = d~r_p_cd AND
           c~version = d~version )
        WHERE a~pernr = zic_prep_rolereq-useridap AND
              a~sprps = ' ' AND
              a~endda = '99991231' AND
              c~sprps = ' ' AND
              c~endda = '99991231' .

*
        IF sy-subrc = 0.
          READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
          zic_prep_rolereq-nameapp = ist_data-name.
          zic_prep_rolereq-desigap = ist_data-designation.
          IF zic_prep_rolereq-persa <> ist_data-werks AND
                 NOT zic_prep_rolereq-persa IS INITIAL.
            SELECT SINGLE * FROM t500p
            WHERE persa = ist_data-werks.
            IF zic_prep_rolereq-ccode = t500p-bukrs.
            ELSE.
              SELECT SINGLE * FROM zmm_prep_ex_app
                WHERE userid = zic_prep_rolereq-useridap.
              IF sy-subrc = 0.
              ELSE.
                IF g_ccode_crossco = t500p-bukrs.
                ELSE.
                  MESSAGE e112(zhelp).
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE e110(zhelp).
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
**12.06.06 vivek begin

  IF NOT zic_prep_rolereq-useridap IS INITIAL AND
       old_ok_code = 'APPROVE' AND
                ( zic_prep_rolereq-req_appfi_fl = 'X' ).

**
    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs
              a~werks a~persk a~sbmod  c~designo c~r_p_cd
              c~version d~sdesig_text AS designation
               d~adesig_text AS adesignation
           INTO CORRESPONDING FIELDS OF TABLE ist_data
           FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c    " Bipin + 02/08/2016
     ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
     ON c~designo = d~desig_code AND
         c~r_p_cd  = d~r_p_cd AND
         c~version = d~version )
      WHERE a~pernr = sy-uname AND
            a~sprps = ' ' AND
            a~endda = '99991231' AND
            c~sprps = ' ' AND
            c~endda = '99991231' .

*
    IF sy-subrc = 0.
      READ TABLE ist_data INDEX 1.  "#EC CI_NOORDER
      zic_prep_rolereq-nameapp = ist_data-name.
      zic_prep_rolereq-useridap = sy-uname.
    ENDIF.

**

    IF zic_prep_rolereq-status = 'IC' OR
        zic_prep_rolereq-status = 'IR'.
      zic_prep_rolereq-status   = 'IF'.
    ELSE.
      zic_prep_rolereq-status   = 'N'.
    ENDIF.
**12.06.06 vivek end
  ENDIF.

  IF g_fundc_err_flag <> 'X'.

    IF old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X'.
      g_comm_fl = 'X'.
      IF g_lines_2 <> 0.
        CLEAR zic_prep_rolereq-comm_fl.
        CLEAR g_lines_2.
** Status New changed to IF
        zic_prep_rolereq-status = 'IF'.
      ENDIF.
    ENDIF.

    IF old_ok_code = 'CHANGE' AND zic_prep_rolereq-comm_fl = 'X'.
** Status New changed to IR
      zic_prep_rolereq-status = 'IR'.
      CLEAR zic_prep_rolereq-comm_fl.
    ENDIF.



    IF zic_prep_rolereq-ccode IS INITIAL.
      MESSAGE e142(zhelp).
    ENDIF.

    IF g_mult_module_fl = 'X' AND old_ok_code = 'CHANGE'.
      zic_prep_rolereq-multimodule_fl = 'X'.
    ENDIF.

    MODIFY zic_prep_rolereq FROM zic_prep_rolereq.

    IF sy-subrc = 0.

      IF g_app_rel = 'X'.

        CLEAR g_app_rel.

      ELSEIF
      ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X' )
      OR ( old_ok_code = 'CHANGE' AND zic_prep_rolereq-comm_fl = 'X' ).

      ELSE.

        g_approver_level = 'HF'.

** Module wise check & insertion

        IF g_reset_fl <> 'X'.

          CASE moduleid.

            WHEN 'FI'.
              IF old_ok_code = 'ROLE_DEL' OR l_del_request = 'X'.
                PERFORM insert_items_delfi.
              ELSE.
                PERFORM insert_items_fi.
              ENDIF.

          ENDCASE.

        ENDIF.

      ENDIF.

*      if l_del_request <> 'X'.
      IF g_reset_fl <> 'X'.
        PERFORM items_approval_check.
      ENDIF.
*      endif.


*     if sy-tcode <> 'ZIC_AUTH_FI_REP'.

****Saving the long text.                              *****

      IF ( old_ok_code = 'CREATE' )
          OR ( old_ok_code = 'CHANGE' )
          OR ( old_ok_code = 'RELEASE' )
          OR ( old_ok_code = 'APPROVE' ).

        PERFORM save_cors_text.
      ELSEIF g_comm_fl = 'X'.
        PERFORM save_cors_text.
        CLEAR g_comm_fl.
      ENDIF.

**** Check if moduleid has changed
      IF module_changed_flag = 'X' AND old_ok_code = 'CHANGE'.
*       if  old_ok_code = 'CHANGE'.
        moduleid = new_moduleid.
        CLEAR new_moduleid.
        CLEAR module_changed_flag.
        old_ok_code = 'CHANGE'.
        PERFORM clear_for_newmodule.
      ELSE.
        PERFORM clear.
      ENDIF.
****
      PERFORM unlock_record.
      IF g_reset_fl = 'X'.
        CLEAR g_reset_fl.
        CLEAR set_disc_fi_flag.
        CLEAR g_hd_copied.
        old_ok_code = 'CHANGE'.
        zic_prep_rolereq-docno = g_docno.
      ENDIF.

      IF sy-tcode = 'ZIC_AUTH_FI_REP'.
        SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
        EXIT.
      ELSE.
*        perform clear.
        PERFORM unlock_record.

*        call screen 100.
        LEAVE.
      ENDIF.




    ENDIF.

*****
  ELSE.

    CLEAR g_fundc_err_flag.
    CALL SCREEN 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    CLEAR okcode_100.


  ENDIF.

ENDFORM.                    " insert_header
*&---------------------------------------------------------------------*
*&      Form  exit_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_confirm.

  DATA l_choice1.
  CLEAR l_choice1.

  IF old_ok_code = 'CREATE' OR
     old_ok_code = 'CROSSCO' OR
     old_ok_code = 'CHANGE' OR
     old_ok_code = 'DELETE' OR
     old_ok_code = 'RELEASE' OR
     old_ok_code = 'ASSIGN' OR
     old_ok_code = 'APPROVE'.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        textline1      = 'Data will be lost, Want to quit? '
        titel          = 'EXIT'
        start_column   = 25
        start_row      = 6
        cancel_display = ''
*       DEFAULTOPTION  = 'N'
      IMPORTING
        answer         = l_choice1.

    IF l_choice1 = 'J'.
      CLEAR l_choice1.
      PERFORM clear.
      PERFORM unlock_record.
      CALL SCREEN 100.
    ELSE.
    ENDIF.

  ELSE.

    PERFORM clear.
    PERFORM unlock_record.
    CALL SCREEN 100.

  ENDIF.


ENDFORM.                    " exit_confirm
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_var.

  PERFORM clear.

ENDFORM.                    " clear_var
*&---------------------------------------------------------------------*
*&      Form  unlock_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_req.



ENDFORM.                    " unlock_req
*&---------------------------------------------------------------------*
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_record.

  CALL FUNCTION 'DEQUEUE_EZ_IC_PREPHDR'
    EXPORTING
      mode_zic_prep_rolereq = 'E'
      mandt                 = sy-mandt
      docno                 = zic_prep_rolereq-docno.

  CLEAR g_lock.

ENDFORM.                    " unlock_record
*&---------------------------------------------------------------------*
*&      Form  clear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear.

  PERFORM destroy_ctrl.
***** CHANGES ON 25 JULY 2013 : BIPIN SHUKLA
*  DATA : WA_GRCDATA TYPE ZIC_PREP_ROLEREQ.
  MOVE-CORRESPONDING zic_prep_rolereq TO wa_grcdata.
******** END OF CHANGES
  CLEAR   : old_ok_code, okcode_100, err_flg.
  REFRESH : g_tablctrl111_itab[].
  CLEAR   : g_tablctrl111_itab.
  CLEAR   : sy-ucomm.
  CLEAR   : g_curr_line.
  CLEAR set_disc_fi_flag.
  CLEAR   : zic_prep_rolerei, zic_prep_rolereq.
  CLEAR   : it_tab.
  REFRESH : tlinetab1[],tlinetab2[].
  CLEAR   : t500p-name1.
  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : moduleid.

ENDFORM.                    " clear
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

  IF ( old_ok_code = 'CREATE' )
   OR ( old_ok_code = 'CROSSCO' )
   OR ( old_ok_code = 'CRCROLES' )
   OR ( old_ok_code = 'CHANGE' )
   OR ( ok_code_assign = 'ASSIGN' )
   OR ( old_ok_code = 'RELEASE' )
   OR ( old_ok_code = 'APPROVE' )
  OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X'
       AND  zic_prep_rolereq-status <> 'C' ).

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

  REFRESH: tlinetab1, g_linefrto_itab.
  IF old_ok_code <> 'CREATE' OR
     old_ok_code = 'CROSSCO' .
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

  IF ( old_ok_code = 'CREATE' )
   OR ( old_ok_code = 'CROSSCO' )
   OR ( old_ok_code = 'CRCROLES' )
   OR ( old_ok_code = 'CHANGE' )
   OR ( ok_code_assign = 'ASSIGN' )
   OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X'
       AND  zic_prep_rolereq-status <> 'C').
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
  l_theader-tdobject   = 'ZHELP'.
  l_theader-tdid       = '0001'.
  l_theader-tdspras    =  sy-langu.
  l_theader-tdlinesize =  72.
  MOVE zic_prep_rolereq-docno TO l_theader-tdname.
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
*&      Form  get_user
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_user.

  CLEAR g_user.


  SELECT SINGLE * FROM zauth_user WHERE primary_module = 'FI' AND
                                        bname = sy-uname .
*  and   APPROVE_FLAG = 'X'.

*   if sy-subrc = 0.
*    g_user = 'HF'.
*    check 1 = 2.
*  Endif.

  IF zauth_user-release_flag = 'X'.
    g_user ='HF'.
    CHECK 1 = 2.
  ENDIF.

  IF zauth_user-approve_flag = 'X'.
    g_user_assign = 'X'.
  ELSE.
    g_user_assign = ''.
  ENDIF.


****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                     ID 'FRGCO' FIELD : 'L1'.
****
****  if sy-subrc = 0.
****    g_user = 'L1'.
****    check 1 = 2.
****  Endif.
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                     ID 'FRGCO' FIELD : 'DI'.
****
****  if sy-subrc = 0.
****    g_user = 'L1'.
****    check 1 = 2.
****  Endif.
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                     ID 'FRGCO' FIELD : 'CS'.
****
****  if sy-subrc = 0.
****    g_user = 'L1'.
****    check 1 = 2.
****  Endif.
****
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                      ID 'FRGCO' FIELD : 'MD'.
****
****  if sy-subrc = 0.
****    g_user = 'L1'.
****    check 1 = 2.
****  Endif.
****
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                      ID 'FRGCO' FIELD : 'IM'.
****
****  if sy-subrc = 0.
****    g_user = 'IM'.
****    check 1 = 2.
****  Endif.
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                    ID 'FRGCO' FIELD : 'L2'.
****  if sy-subrc = 0.
****    g_user = 'L3'.
****    check 1 = 2.
****  Endif.
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                      ID 'FRGCO' FIELD : 'L3'.
****  if sy-subrc = 0.
****    g_user = 'L3'.
****    check 1 = 2.
****  endif.
****
****  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
****                      ID 'FRGCO' FIELD : 'L4'.
****
****  if sy-subrc = 0.
****    g_user = 'L3'.
****    zic_prep_rolereq-radio_fl = 'X'.
****    g_l4 = 'X'.
****    check 1 = 2.
****  Endif.
****
ENDFORM.                    " find_user
*&---------------------------------------------------------------------*
*&      Form  validations
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations.

  IF old_ok_code = 'APPROVE'.

    SELECT SINGLE * FROM zic_prep_rolerei WHERE moduleid = 'FI'
       AND docno = zic_prep_rolereq-docno.

    IF sy-subrc = 0.
      modulefi_fl = 'X'.
    ENDIF.

    IF g_user <> 'HF'.
      MESSAGE i147(zhelp).
      CLEAR old_ok_code.
      CALL SCREEN 100.
    ENDIF.

    IF g_user = 'HF' AND
       ( zic_prep_rolereq-req_appfi_fl = 'X' ).
      MESSAGE i132(zhelp).
      CLEAR old_ok_code.
      CALL SCREEN 100.
    ENDIF.

  ENDIF.

****  if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.
****
****    if  ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.
****    else.
****      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
****          EXPORTING
****              TEXTLINE1  = 'Not authorised to use this document- not
****yours '.
*****                     message i046(zhelp).
****      perform clear.
****      call screen 100.
****    endif.
****
****  endif.

  IF old_ok_code = 'CHANGE' AND zic_prep_rolereq-req_cr_fl = 'X'.

    IF zic_prep_rolereq-status = 'IF' OR
          zic_prep_rolereq-status = 'PC' OR
          zic_prep_rolereq-status = 'C'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'Request under process / completed can not change/reset'.

*                message e065(zhelp).
      PERFORM clear.
      CALL SCREEN 100.

    ELSE.
      g_reset_fl = zic_prep_rolereq-req_cr_fl.
      g_docno = zic_prep_rolereq-docno.

*Start--- Changed for Assigning roles
*      if sy-tcode <> 'ZIC_AUTH_FI_REP'.
      PERFORM verify.
*      endif.

*End--- Changed for Assigning roles


    ENDIF.
  ENDIF.

  IF old_ok_code = 'APPROVE' AND
                    zic_prep_rolereq-disc_fi_flag = 'X'.
    IF g_user = 'HF'.
    ELSE.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'This requires approval of Head of Finance'.

*               message e048(zhelp).
      PERFORM clear.
      CALL SCREEN 100.
    ENDIF.
  ENDIF.

  IF old_ok_code = 'RELEASE' AND zic_prep_rolereq-req_cr_fl = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        textline1 = 'Request already released by creator'.

*          message e053(zhelp).
    PERFORM clear.
    CALL SCREEN 100.

  ENDIF.

  IF old_ok_code = 'APPROVE'.

    IF g_user = 'HF' AND zic_prep_rolereq-req_app1_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'Request not released by creator'.

*                   message e051(zhelp).
      PERFORM clear.
      CALL SCREEN 100.

    ENDIF.

****    if ( g_user = 'IM' or g_user = 'L3' ) and
****                          ZIC_PREP_ROLEREQ-REQ_APP_FL = ' ' and
****       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
****      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
****           EXPORTING
****                TEXTLINE1 = 'Request not released by creator'.
*****                   message e051(zhelp)..
****      perform clear.
****      call screen 100.
****
****    endif.

    IF  zic_prep_rolereq-req_app1_fl = 'X' OR
        zic_prep_rolereq-req_app_fl = 'X' OR
        zic_prep_rolereq-req_appfi_fl = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'Request already approved'.

      PERFORM clear.
      CALL SCREEN 100.

    ENDIF.

  ENDIF.
  IF sy-tcode <> 'ZIC_AUTH_FI_REP'.
    IF ( zic_prep_rolereq-status = 'IF' OR
        zic_prep_rolereq-status  = 'C' )
        AND old_ok_code <> 'DISPLAY'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          textline1 = 'Request can not  be  changed, Can only be'
                      &
                      'displayed'.

*                message e079(zhelp).
*                 perform clear.
      old_ok_code = 'DISPLAY'.
      CALL SCREEN 100.

    ENDIF.
  ENDIF.

ENDFORM.                    " validations
*&---------------------------------------------------------------------*
*&      Form  validations1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validations1.

  IF g_val_err = 'X'.
    CLEAR g_val_err.
    MESSAGE i118(zhelp).
    CALL SCREEN 100.
  ENDIF.

  IF zic_prep_rolerei-rej_fl = ''.

    IF old_ok_code = 'APPROVE' AND
                      zic_prep_rolereq-disc_mm_flag = 'X'.
      IF g_user = 'IM' OR g_user = 'L1'.
      ELSE.
        MESSAGE e048(zhelp).
      ENDIF.
    ENDIF.

  ENDIF.

  PERFORM check_tel.

ENDFORM.                    " validations1


*---------------------------------------------------------------------*
*       FORM destroy_ctrl                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM destroy_ctrl.

  IF NOT flag2 IS INITIAL.
    CLEAR : flag2, flag1.
    CALL METHOD gv_text_editor1->free.
    CALL METHOD gv_text_editor2->free.
  ENDIF.

  IF NOT flag1 IS INITIAL.
    CLEAR flag1.
    CALL METHOD gv_text_editor1->free.
  ENDIF.

  CLEAR:gv_text_editor1,gv_text_editor2.

  PERFORM unlock_record.

ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  delete_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_request.

  DATA : l_choice.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = 'Are you sure, you want to delete the'
                       &
                       'Document? '
      titel          = ''
      start_column   = 25
      start_row      = 6
      cancel_display = ''
    IMPORTING
      answer         = l_choice.

  IF l_choice = 'J'.
    CLEAR l_choice.

**************************************

    zic_prep_rolereq-mandt = sy-mandt.

    DELETE zic_prep_rolereq FROM zic_prep_rolereq.

    IF sy-subrc = 0.

      PERFORM delete_items.


      IF zic_prep_rolereq-long_text_fl <> ''.
        PERFORM delete_cors_text.
      ENDIF.

      PERFORM clear.
      PERFORM unlock_record.
      CALL SCREEN 100.

    ELSE.

      MESSAGE i057(zhelp) WITH zic_prep_rolereq-docno.

    ENDIF.

  ELSE.

  ENDIF.

ENDFORM.                    " delete_request
*&---------------------------------------------------------------------*
*&      Form  delete_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_items.

  LOOP AT g_tabctrl100_itab INTO g_tabctrl100_wa.

    MOVE-CORRESPONDING g_tabctrl100_wa TO wa_itemtab.
    wa_itemtab-mandt = sy-mandt.
    APPEND wa_itemtab TO ist_itemtab.

  ENDLOOP.

  DELETE zic_prep_rolerei FROM TABLE ist_itemtab.

  IF sy-subrc = 0.
    MESSAGE i120(zhelp) WITH zic_prep_rolereq-docno.
  ENDIF.

ENDFORM.                    " delete_items
*&---------------------------------------------------------------------*
*&      Form  delete_cors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_cors_text.

  DATA : l_name LIKE thead-tdname.

  l_name = zic_prep_rolereq-docno.

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      client    = sy-mandt
      id        = '0001'
      language  = sy-langu
      name      = l_name
      object    = 'ZHELP'
*     SAVEMODE_DIRECT = ' '
*     TEXTMEMORY_ONLY = ' '
*     LOCAL_CAT = ' '
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " delete_cors_text
*&---------------------------------------------------------------------*
*&      Form  verify
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify.

  DATA l_choice.
  CLEAR l_choice.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = 'Request already released Flags will be'
                       &
                       'cancelled? '
      titel          = 'RESET'
      start_column   = 25
      start_row      = 6
      cancel_display = ''
      defaultoption  = 'N'
    IMPORTING
      answer         = l_choice.

  IF l_choice = 'J'.

    CLEAR zic_prep_rolereq-req_cr_fl.
    CLEAR zic_prep_rolereq-req_app_fl.
    CLEAR zic_prep_rolereq-req_app0_fl.
    CLEAR zic_prep_rolereq-req_app1_fl.
    CLEAR zic_prep_rolereq-req_appfi_fl.
    zic_prep_rolereq-status = 'IC'.
    PERFORM save_request.
**20/03/2006
    g_app_rel = 'X'.
    CLEAR l_choice.

  ELSE.

    PERFORM clear.
    PERFORM unlock_record.
    CALL SCREEN 100.

  ENDIF.

ENDFORM.                    " verify

*&---------------------------------------------------------------------*
*&      Form  verify1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify1.

  DATA : l_choice.
  CLEAR l_choice.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = 'If u cancel release, u can change data'
                       &
                       'else go in display mode'
      textline2      = '& just do correspondence without'
                       &
                       'cancelling release'
      titel          = 'Do you want to cancel release?'
      start_column   = 25
      start_row      = 6
      cancel_display = ''
      defaultoption  = 'N'
    IMPORTING
      answer         = l_choice.

  IF l_choice = 'J'.

    old_ok_code = 'CHANGE'.
    CLEAR l_choice.

  ELSE.

    old_ok_code = 'DISPLAY'.
    CLEAR l_choice.

  ENDIF.

ENDFORM.                                                    " verify1
*&---------------------------------------------------------------------*
*&      Form  check_tel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tel.

  IF    ( ( old_ok_code = 'DISPLAY' OR old_ok_code = 'CHANGE' OR
         old_ok_code = 'DELETE'
         OR old_ok_code = 'RELEASE' OR old_ok_code = 'APPROVE' )
         AND g_hd_copied = 'X' )
         OR ( old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' ).
    DATA : tel_len TYPE i.
    tel_len = strlen( zic_prep_rolereq-telno ).
    IF  zic_prep_rolereq-telno CN ' 0123456789-'.
      MESSAGE i097(zhelp).
      CALL SCREEN 100.
    ELSE.
      IF tel_len < 7.
        MESSAGE i098(zhelp).
        CALL SCREEN 100.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_tel
*&---------------------------------------------------------------------*
*&      Form  attach_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files.

  CLEAR g_att_files_wa.
  REFRESH g_att_files.

  g_att_files_wa-logsys = zic_prep_rolereq-docno+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  APPEND g_att_files_wa TO g_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      attachment_data     = ''
      attachment_type     = 'DOC'
    TABLES
      application_objects = g_att_files.


ENDFORM.                    " attach_files
*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files.

  g_att_files_wa-logsys = zic_prep_rolereq-docno+2(10).
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = g_att_files_wa
*     FUNCTION           = ' '
* TABLES
*     FUNC_EXCLUDE       =
    .

ENDFORM.                    " list_files
*&---------------------------------------------------------------------*
*&      Form  pop_up_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'Choosing Location '
      textline1 = 'It is understood that user has joined at new'
                  &
                  'location & HR Data'
      textline2 = 'is updated.'
                  &
                  '               Please choose appropriate current location?'
*     START_COLUMN                                                 = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_message
*&---------------------------------------------------------------------*
*&      Form  items_approval_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM items_approval_check.
  SELECT * FROM zic_prep_rolerei INTO TABLE ist_itemtab
  WHERE docno = zic_prep_rolereq-docno.
  LOOP AT ist_itemtab INTO wa_itemtab.
    IF wa_itemtab-rej_fl IS INITIAL.
** Header level changes for integration
      PERFORM validate_role_approval_level.
    ENDIF.
  ENDLOOP.
  CLEAR ist_itemtab.
  REFRESH ist_itemtab[].
  CLEAR wa_itemtab.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
  PERFORM clear1.
  IF old_ok_code = 'CROSSCO' OR
        zic_prep_rolereq-crossco_fl = 'X'.

    IF old_ok_code = 'RELEASE' OR
        old_ok_code = 'CROSSCO' OR
        old_ok_code = 'CHANGE'.
      PERFORM popup_release_message.
    ENDIF.

    IF old_ok_code = 'APPROVE' OR
       zic_prep_rolereq-status = 'IF'.
      PERFORM popup_approve_message.
    ENDIF.

    PERFORM pop_up_crossco_message.          .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
    SET PARAMETER ID 'ZREQNO'
       FIELD zic_prep_rolereq-docno.
    MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.

  ELSE.
    IF old_ok_code = 'CRCROLES' OR
      zic_prep_rolereq-crc_fl = 'X'.
      IF old_ok_code = 'RELEASE' OR
         old_ok_code = 'CRCROLES' OR
         old_ok_code = 'CHANGE'.
        PERFORM popup_release_message.
      ENDIF.
      IF old_ok_code = 'APPROVE' OR
         zic_prep_rolereq-status = 'IF'.
        PERFORM popup_approve_message.
      ENDIF.
      PERFORM pop_up_crc_message.
*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      g_crc_fl = 'X'.
    ELSE.
      IF old_ok_code = 'RELEASE'.

        PERFORM popup_release_message.
        SET PARAMETER ID 'ZREQNO'
          FIELD zic_prep_rolereq-docno.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.

      ELSEIF old_ok_code = 'APPROVE'.
        .               PERFORM popup_approve_message.
        SET PARAMETER ID 'ZREQNO'
          FIELD zic_prep_rolereq-docno.
****************************************** changes done by bipin shukla to sent mail

        IMPORT crt_name FROM MEMORY ID 'CRT_NAME_RJ'.
        CLEAR : wa_urinfo , wa_uname , wa_appinfo.
        SELECT PERNR FROM PA0105 INTO WA_URINFO-PERNR UP TO 1 ROWS WHERE USRID = CRT_NAME
 AND USRTY = '0001'
 ORDER BY PRIMARY KEY .
 ENDSELECT. "AND ENDDA = '31.12.9999'.
        IF sy-subrc EQ 0.
          SELECT USRID_LONG FROM PA0105 INTO WA_URINFO-USRID_LONG UP TO 1 ROWS WHERE PERNR = WA_URINFO-PERNR
 AND USRTY = '0010'
 ORDER BY PRIMARY KEY .
 ENDSELECT. " AND ENDDA = '31.12.9999'.


          SELECT SINGLE *   FROM pa0002 INTO CORRESPONDING FIELDS OF wa_uname
                WHERE pernr = wa_urinfo-pernr.
        ENDIF.


**********************************************Get approver user name
        SELECT PERNR FROM PA0105 INTO WA_APPINFO-PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME
 AND USRTY = '0001'
 ORDER BY PRIMARY KEY .
 ENDSELECT. "AND ENDDA = '31.12.9999'.
        IF sy-subrc EQ 0.
          SELECT * FROM PA0002 INTO CORRESPONDING FIELDS OF WA_APPNAME UP TO 1 ROWS
 WHERE PERNR = WA_APPINFO-PERNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        ENDIF.
        CONCATENATE wa_appname-nachn wa_appname-vorna INTO lv_appname SEPARATED BY space.
**********************************************Get approver user name


        CONCATENATE 'Approval of Role Request No.' zic_prep_rolereq-docno
      INTO docdata-obj_descr SEPARATED BY space.

        wa_objhead = 'Dear Sir/Madam,'.
        APPEND wa_objhead TO gt_objhead.
        CLEAR wa_objhead.
        APPEND wa_objhead TO gt_objhead.

        CONCATENATE 'Your Role Request No.' zic_prep_rolereq-docno 'has been approved and sent to OVL Core Team for assignment'
        INTO  wa_objhead SEPARATED BY space.
        APPEND wa_objhead TO gt_objhead.
        CLEAR wa_objhead.
        APPEND wa_objhead TO gt_objhead.

        wa_objhead = 'Please check your request for details'.
        APPEND wa_objhead TO gt_objhead.
        CLEAR wa_objhead.
        APPEND wa_objhead TO gt_objhead.

        CLEAR wa_objhead.

        APPEND wa_objhead TO gt_objhead.

        wa_objhead = 'Regards'.
        APPEND wa_objhead TO gt_objhead.
        CLEAR wa_objhead.
        wa_objhead = lv_appname.
        APPEND wa_objhead TO gt_objhead.
        CLEAR wa_objhead.




*      WA_RECLIST-RECEIVER  = 'bipin@sapcnorth.in'.
        wa_reclist-receiver  = wa_urinfo-usrid_long.
        wa_reclist-rec_type = 'U'.
        APPEND wa_reclist TO gt_reclist.
        wa_reclist-receiver  = crt_name.
        wa_reclist-rec_type = 'B'.
        APPEND wa_reclist TO gt_reclist.

*** Creation of the entry for the document
        DESCRIBE TABLE gt_objhead LINES lv_tab_lines.
        CLEAR objpack-transf_bin.
        objpack-head_start = 1.
        objpack-head_num = 0.
        objpack-body_start = 1.
        objpack-body_num = lv_tab_lines.
        objpack-doc_type = 'RAW'.
        APPEND objpack." TO LT_OBJPACK.
        CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
          EXPORTING
            document_data              = docdata
            put_in_outbox              = 'X'
            commit_work                = 'X'
          TABLES
            packing_list               = objpack[]
*           OBJECT_HEADER              =
*           CONTENTS_BIN               =
            contents_txt               = gt_objhead[]
*           CONTENTS_HEX               =
*           OBJECT_PARA                =
*           OBJECT_PARB                =
            receivers                  = gt_reclist[]
          EXCEPTIONS
            too_many_receivers         = 1
            document_not_sent          = 2
            document_type_not_exist    = 3
            operation_no_authorization = 4
            parameter_error            = 5
            x_error                    = 6
            enqueue_error              = 7
            OTHERS                     = 8.
        IF sy-subrc EQ 0.
* Implement suitable error handling here
          MESSAGE 'Mail successfully sent to creator !!' TYPE 'S'.
        ENDIF.


****************************************** changes done by bipin shukla to sent mail
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF old_ok_code = 'CREATE' OR old_ok_code =
'CHANGE'.
        PERFORM popup_release_message1.
        SET PARAMETER ID 'ZREQNO'
          FIELD zic_prep_rolereq-docno.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
****************************** start of chages by bipin : for risk analysis : 02/09/2013
        CLEAR : it_tvarv.
        SELECT * FROM tvarvc INTO CORRESPONDING FIELDS OF TABLE it_tvarv
        WHERE name = 'ZGRC_CALL'.
        IF it_tvarv[] IS NOT INITIAL.
          READ TABLE it_tvarv INTO wa_tvarv WITH KEY name = 'ZGRC_CALL'.
        ENDIF.
        IF wa_tvarv-low IS NOT INITIAL.
          lv_grccall = wa_tvarv-low.
        ENDIF.
        DATA : lv_rfc1 TYPE rfcdest.
        IF syst-sysid = 'RD1'.

          lv_rfc1 = 'GRDCLNT500'.

        ELSEIF syst-sysid = 'RQ1'.

          lv_rfc1 = 'GRDCLNT500'.

        ELSEIF syst-sysid = 'RP1'.

          lv_rfc1 = 'GRPCLNT500'.
        ENDIF.

        CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
          EXPORTING
            rfcdestination = lv_rfc1 ""'GRDCLNT500'
          IMPORTING
*           MSGV1          =
*           MSGV2          =
            rfc_subrc      = lv_subrc.
        IF  lv_grccall = 'X' AND lv_subrc = '0'.
          MESSAGE i232(zhelp) WITH zic_prep_rolereq-docno.
          reqnum_ex = zic_prep_rolereq-docno.
          EXPORT reqnum_ex TO MEMORY ID 'REQNUM_IM'.
          PERFORM grc_risk_analysis.
          IMPORT gt_rdesc FROM MEMORY ID 'IM_GT_RDESC'.

*          IF GT_RDESC IS NOT INITIAL.
          CALL TRANSACTION 'ZGRC_RESULT'.
*          ELSE.
*          MESSAGE 'No risk found!!' TYPE 'I'.
*          ENDIF.
*          CLEAR GT_RDESC.

          CLEAR reqnum_ex.
        ENDIF.
****************************** end of chages by bipin : for risk analysis : 02/09/2013

      ELSEIF zic_prep_rolereq-status = 'IF'.
        PERFORM popup_approve_message.
      ELSE.
        SET PARAMETER ID 'ZREQNO'
          FIELD zic_prep_rolereq-docno.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ENDIF.
  ENDIF.
**      endif.
ENDFORM.                    " items_approval_check
*&---------------------------------------------------------------------*
*&      Form  pop_up_crc_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_crc_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'CRC Authorizations '
      textline1 = 'Please attach the scanned order copy with the'
                  &
                  'request or '
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN  = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_crc_message
*&---------------------------------------------------------------------*
*&      Form  pop_up_crossco_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_crossco_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel     = 'Cross Company Authorisations '
      textline1 = 'Please attach the scanned order copy with the'
                  &
                  'request or '
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN  = 25
*     START_ROW = 6
    .

ENDFORM.                    " pop_up_crossco_message
*&---------------------------------------------------------------------*
*&      Form  validate_role_approval_level
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_role_approval_level.

** Check approval module wise & line item wise

  g_approver_level = 'HF'.


ENDFORM.                    " validate_role_approval_level
*&---------------------------------------------------------------------*
*&      Form  popup_release_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message.

  IF g_approver_level = 'IM'.
    g_approver_level = 'I/C MM'.
  ENDIF.

  CONCATENATE 'Kindly get the request approved by competent authority: '
            g_approver_level ' or above' INTO g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Approval Requirement'
      textline1 = g_approve_text
*     textline2 = 'Request for authorization will be routed to'
*                  &
*                  'OVL core team only '
*     textline3 = 'after requisite approval '
*     START_COLUMN          = 15
*     START_ROW = 6
    .
  CLEAR : g_approver_level, g_approve_text.
ENDFORM.                    " popup_release_message
*&---------------------------------------------------------------------*
*&      Form  popup_approve_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_approve_message.
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Request Processing'
      textline1 = 'The request will now be processed by OVL core'
                  &
                  ' team & '
      textline2 = 'user will get updated message once the reques'
                  &
                  't is processed '
*     START_COLUMN      = 15
*     START_ROW = 6
    .
ENDFORM.                    " popup_approve_message
*&---------------------------------------------------------------------*
*&      Form  verify2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verify2.
  IF zic_prep_rolereq-status <> 'C'.
**
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
      EXPORTING
        titel     = 'Request Status IR'
        textline1 = 'Please go to display mode & reply the query'
                    &
                    'of the ICE core team in '
        textline2 = 'correspondence  &  save the request.'
                    &
                    '                No re-'
                    &
                    'release or approval reqd.'
        textline3 = 'The request will go directly to OVL core team'
                    &
                    ' for further processing.'.
    old_ok_code = 'DISPLAY'.
**
  ELSE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
      EXPORTING
        titel     = 'Request Status C'
        textline1 = 'Request is closed, you can not change'
                    &
                    'anything now'
        textline2 = 'No more processing of the request can be'
                    &
                    'done'.
    old_ok_code = 'DISPLAY'.
**
  ENDIF.
ENDFORM.                                                    " verify2
*&---------------------------------------------------------------------*
*&      Form  popup_release_message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message1.
  IF g_approver_level = 'IM'.
    g_approver_level = 'I/C MM'.
  ENDIF.

  CONCATENATE g_approver_level ' or above.'"" Request will be routed to OVL' & 'core Team'
  INTO g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Approval Requirement'
      textline1 = 'Kindly self release request & get approved by competent'
                  &
                  'authority'
      textline2 = g_approve_text
*     textline3 = 'Team will process only after requisite approval'
*     START_COLUMN = 15
*     START_ROW = 6
    .
  CLEAR : g_approver_level, g_approve_text.
ENDFORM.                    " popup_release_message1
*&---------------------------------------------------------------------*
*&      Form  clear1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear1.

  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : dynnr.

ENDFORM.                                                    " clear1
*&---------------------------------------------------------------------*
*&      Form  insert_items_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_fi.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl111_itab
  BY role_name gl_account bussiness_area fund_ctr_gp jva_grp.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl111_itab
    COMPARING role_name gl_account bussiness_area fund_ctr_gp jva_grp.

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

    MOVE-CORRESPONDING g_tablctrl111_wa TO wa_itemtab.

    IF sy-tcode = 'ZIC_AUTH_FI_REP'.
      IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
          wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
        wa_itemtab-role_request = zrolereqno.
      ENDIF.
    ENDIF.


*    Perform check_items_save.

    IF old_ok_code = 'CREATE'.
      wa_itemtab-docno = zdocnumb.
    ENDIF.

    wa_itemtab-mandt = sy-mandt.
    IF wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    ENDIF.
    IF NOT wa_itemtab-role_name IS INITIAL.
      i = i + 1.
      wa_itemtab-srno = i .
      APPEND wa_itemtab TO ist_itemtab.
    ENDIF.

    g_i = i.

    PERFORM check_module_wise.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO'
.
      ELSEIF old_ok_code <> 'DISPLAY'.
        DELETE FROM zic_prep_rolerei WHERE
        docno = zic_prep_rolereq-docno AND
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_fi
***&--------------------------------------------------------------------
*-
***
***&      Form  check_items_save_fi
***&--------------------------------------------------------------------
*-
***
***       text
***---------------------------------------------------------------------
*-
***
***  -->  p1        text
***  <--  p2        text
***---------------------------------------------------------------------
*-
***
FORM check_items_save_fi.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zfi_prep_roledes-gl_account = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-gl_account IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-GL_ACCOUNT'.
          ROLLBACK WORK.
          MESSAGE i122(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zfi_prep_roledes-bussiness_area = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-bussiness_area IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-BUSSINESS_AREA'.
          ROLLBACK WORK.
          MESSAGE i123(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zfi_prep_roledes-fund_ctr_grp = 'X' AND
                  ( old_ok_code = 'APPROVE' OR
                 old_ok_code = 'RELEASE' OR
                 old_ok_code = 'CHANGE' OR
                 old_ok_code = 'CREATE' OR
                 old_ok_code = 'CROSSCO' ) AND
                 NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-fund_ctr_gp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-FUND_CTR_GP'.
          ROLLBACK WORK.
          MESSAGE i127(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.
      IF zfi_prep_roledes-jva_grp = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-jva_grp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-JVA_GRP'.
          ROLLBACK WORK.
          MESSAGE i126(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.


    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax11.

ENDFORM.                    " check_items_save_fi
*&---------------------------------------------------------------------*
*&      Form  check_module_wise
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_wise.

  CASE moduleid.

    WHEN 'FI'.

      PERFORM check_items_save_fi.


  ENDCASE.

ENDFORM.                    " check_module_wise
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax11.

  g_ccode = zic_prep_rolereq-ccode.


  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

*      IF NOT g_tablctrl111_wa-gl_account IS INITIAL.
*
*        SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF
*                   TABLE it_saknr  WHERE bukrs = zic_prep_rolereq-ccode
*                           AND saknr = g_tablctrl111_wa-gl_account.
*        IF sy-subrc <> 0.
*          g_e_fl = 'X'.
*          g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
*          ROLLBACK WORK.
*          MESSAGE e058(zhelp) WITH g_tablctrl111_wa-role_name.
*
*        ENDIF.
*
*      ENDIF.


*   if not g_TABLCTRL111_wa-GL_ACCOUNT is initial.
*
*      select * from skb1 into corresponding fields of
*                 table it_saknr  where bukrs = ZIC_PREP_ROLEREQ-CCODE
*                         and saknr = g_TABLCTRL111_wa-GL_ACCOUNT.
*      if sy-subrc <> 0.
*            g_e_fl = 'X'.
*            g_field = 'ZIC_PREP_ROLEREI-GL_ACCOUNT'.
*            rollback work.
*            message e068(zhelp) with g_TABLCTRL111_wa-role_name.
*
*      endif.
*
*   endif.


    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax11
*&---------------------------------------------------------------------*
*&      Form  crc_module_checking
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM crc_module_checking.
  IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.
    moduleid = 'MM'.
  ENDIF.
ENDFORM.                    " crc_module_checking
*&---------------------------------------------------------------------*
*&      Form  check_module_status_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_fi.
  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    fi_not_ok = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_fi
*&---------------------------------------------------------------------*
*&      Form  confirm_app
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_app.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1      = 'Are you sure, you want to approve the'
                       &
                       'Document? '
      titel          = ''
      start_column   = 25
      start_row      = 6
      cancel_display = ''
    IMPORTING
      answer         = g_choice_app.

ENDFORM.                    " confirm_app
*&---------------------------------------------------------------------*
*&      Form  clear_for_newmodule
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_for_newmodule.

  PERFORM destroy_ctrl.

  CLEAR   : okcode_100, err_flg.
  REFRESH : g_tablctrl110_itab[].
  CLEAR   : g_tablctrl110_itab.
  REFRESH : g_tablctrl111_itab[].
  CLEAR   : g_tablctrl111_itab.
  REFRESH : g_tablctrl112_itab[].
  CLEAR   : g_tablctrl112_itab.
  CLEAR   : sy-ucomm.
  CLEAR   : g_curr_line.
  CLEAR set_disc_fi_flag.
  CLEAR   : zic_prep_rolerei.
  CLEAR   : it_tab.
  REFRESH : tlinetab1[],tlinetab2[].
  CLEAR   : t500p-name1.
  CLEAR   : crc_check_fl.
  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : g_hd_copied.

ENDFORM.                    " clear_for_newmodule

*&---------------------------------------------------------------------*
*&      Form  icon_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM icon_create.
  CLEAR status_icon.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_name
      text                  = icon_text
      info                  = 'Role'
      add_stdinf            = 'X'
    IMPORTING
      result                = status_icon
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
ENDFORM.                    " icon_create
*&---------------------------------------------------------------------*
*&      Form  fill_sttab_assign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sttab_assign.
*  if   old_ok_code = 'DISPLAY' .
*    move 'ROLE_DEL' to wa_tab-fcode.
*    append wa_tab to it_tab.
*    move 'ROLE_CR' to wa_tab-fcode.
*    append wa_tab to it_tab.
*  endif.
  IF   old_ok_code = 'DELETE' .
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
  ENDIF.

ENDFORM.                    " fill_sttab_assign

*&---------------------------------------------------------------------*
*&      Form  upload1_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload1_file.
  SELECT * FROM zhelp_firoles INTO CORRESPONDING FIELDS OF TABLE it_roles.
ENDFORM.                    " upload1_file

*&---------------------------------------------------------------------*
*&      Form  auth_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check.

  IF g_user_assign <> 'X'.
    MESSAGE i104(zhelp).
    old_ok_code = 'DISPLAY'.
  ENDIF.


ENDFORM.                    " auth_check

*&---------------------------------------------------------------------*
*&      FORM set_title_assign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_title_assign.

  IF l_old_ok_code = 'X' AND g_reset_change <> 'X'.
*    perform auth_check.
  ELSE.
    CLEAR g_reset_change.
  ENDIF.


*  if ZIC_PREP_ROLEREQ-STATUS = 'C' or
*       ZIC_PREP_ROLEREQ-STATUS = 'IC'.
***     or
***     zic_prep_rolereq-status = 'IR'..
*    move 'ROLE_DEL' to wa_tab-fcode.
*    append wa_tab to it_tab.
*    move 'ROLE_CR' to wa_tab-fcode.
*    append wa_tab to it_tab.
*
*    set pf-status 'OPTNS1' excluding it_tab..
*  endif.

*  if old_ok_code = 'DISPLAY'.
*    move 'ROLE_DEL' to wa_tab-fcode.
*    append wa_tab to it_tab.
*    move 'ROLE_CR' to wa_tab-fcode.
*    append wa_tab to it_tab.
*    SET PF-STATUS 'OPTNS1' excluding it_tab.
*  endif.

  SET TITLEBAR 'PREP_TITLE' WITH g_text.

ENDFORM.                 " set_title_assign  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  create_roles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles.

  CLEAR it_roles0.
  CLEAR it_roles1.
  CLEAR it_roles2.
  REFRESH it_roles0.
  REFRESH it_roles1.
  REFRESH it_roles2.

  CLEAR wa_roles2.

  LOOP AT it_roles INTO wa_roles.
    APPEND wa_roles TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles.

    IF NOT wa_roles-role_type IS INITIAL.

      LOOP AT g_tablctrl111_itab INTO wa_rolesz.
        IF wa_roles-role_type = wa_rolesz-role_name AND
                                wa_rolesz-rej_fl = '' AND
                                wa_rolesz-status = '' AND
                                wa_rolesz-role_request = ''.
          PERFORM insert_data.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  PERFORM common_role.

  SORT it_roles1.

  SORT it_roles2 BY role_name.

  DELETE ADJACENT DUPLICATES FROM it_roles1.
  DELETE ADJACENT DUPLICATES FROM it_roles2 COMPARING role_name.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolerei-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolerei-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

*  PERFORM download_file.

  PERFORM copy_values.

*  PERFORM confirm_step.

*  IF gl_ans = 'J'.
*  PERFORM insert_record.
*  PERFORM save_request.
*  ENDIF.

*  PERFORM list_processing.
  REFRESH it_agr.
  IF zic_prep_rolereq-rsn_code = '02'.
    SET PARAMETER ID 'RCODE' FIELD zic_prep_rolereq-rsn_code.
    PERFORM delimit_roles.
  ENDIF.

  SET PARAMETER ID 'ZROLEREQNO' FIELD zrolereqno.

  CLEAR:v_moduleid.
  v_moduleid  = moduleid.
*  EXPORT v_moduleid TO MEMORY ID 'ID3'.

  CLEAR v_remarks_head.
  CONCATENATE zic_prep_rolereq-docno ' - ARMS'
       ' - ' moduleid ' Module' INTO v_remarks_head.
*  EXPORT v_remarks_head TO MEMORY ID 'ID2'.

  CLEAR zuserid.
  MOVE zic_prep_rolereq-useridcr TO zuserid.
*  EXPORT zuserid TO MEMORY ID 'ID'.

  CLEAR zapprover.
  MOVE zic_prep_rolereq-useridap TO zapprover.
*  EXPORT zapprover TO MEMORY ID 'ID1'.
*
*  CLEAR:v_message_as.
  PERFORM role_help.
  GET PARAMETER ID 'ZROLEREQNO' FIELD zrolereqno.

  IF NOT zrolereqno IS INITIAL AND zrolereqno <> '00000000'.

    SUBMIT zbc_role_rep01_rfc AND RETURN.

    MESSAGE i056(zbc) WITH zic_prep_rolereq-docno.

    g_role_flag = 'X'.
    zic_prep_rolereq-status = 'IR'.

*    PERFORM save_request_assign.
*    IF zic_prep_rolereq-status = 'IF' OR
*     zic_prep_rolereq-status = 'N'.
*    ELSE.
*      PERFORM send_sapmail_assign .
*
*    ENDIF.
    PERFORM send_sapmail.
    REFRESH object_content.
  ENDIF.
  IF v_message_as = 'X'.
*    PERFORM save_request_assign.
*    PERFORM send_sapmail_assign .

    v_message_unas = 'All roles already assigned or do not exist.'.

    MESSAGE i735(zmm) WITH v_message_unas.
*  ELSE.
  ENDIF.

*  LEAVE PROGRAM.
  " FINAL_PROCESS
  IF g_role_flag = 'X'.
    CLEAR g_role_flag.
    PERFORM unlock_record.
    PERFORM clear.
  ELSE.

    IF l_old_ok_code = 'X'.
      SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
      EXIT.
    ELSE.
      PERFORM clear.
      PERFORM unlock_record.
      CALL SCREEN 100.
    ENDIF.

  ENDIF.
*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles

*&---------------------------------------------------------------------*
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = 'Role request being created'
      textline2     = 'Continue ??? '
      titel         = 'Confirm'
    IMPORTING
      answer        = gl_ans.

ENDFORM.                    " confirm_step
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM download_file.

  IF NOT p1_file IS INITIAL.

* Download the file on presentation server
    "  commented UC CHECK
**    CALL FUNCTION 'WS_DOWNLOAD'
**      EXPORTING
**        FILENAME                = P1_FILE
**        FILETYPE                = 'DAT'
**      TABLES
**        DATA_TAB                = IT_ROLES1
**      EXCEPTIONS
**        FILE_OPEN_ERROR         = 1
**        FILE_WRITE_ERROR        = 2
**        INVALID_FILESIZE        = 3
**        INVALID_TYPE            = 4
**        NO_BATCH                = 5
**        UNKNOWN_ERROR           = 6
**        INVALID_TABLE_WIDTH     = 7
**        GUI_REFUSE_FILETRANSFER = 8
**        CUSTOMER_ERROR          = 9
**        OTHERS                  = 10.
**
**    IF SY-SUBRC <> 0.
**
**      MESSAGE I061(ZHELP) WITH TEXT-053.
**
**      EXIT.
**
**    ENDIF.
**

    "  Added UC CHECK
    DATA: gd_file TYPE string.
    TYPES: t_uctable LIKE LINE OF it_roles1.
    DATA: it_uctable TYPE STANDARD TABLE OF t_uctable.

    gd_file = p1_file.

    it_uctable[] = it_roles1[].

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = gd_file
        filetype                = 'DAT'
      TABLES
        data_tab                = it_uctable
*       FIELDNAMES              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc <> 0.
      MESSAGE i061(zhelp) WITH text-053.

      EXIT.

    ENDIF.



  ENDIF.

ENDFORM.                    " DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  copy_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_values.

  IF NOT zrolereqno IS INITIAL.
    zic_prep_rolereq-req_no = zrolereqno.
  ENDIF.

ENDFORM.                    " copy_values

*&---------------------------------------------------------------------*
*&      Form  display_role
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_role.
  wa_roles1-userid = zic_prep_rolereq-userid.
  wa_roles1-role_name = 'D:PM_DISPLAY'.
  APPEND wa_roles1 TO it_roles1.
ENDFORM.                    " display_role

*&---------------------------------------------------------------------*
*&      Form  insert_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data.

  DATA : l_desig_level_rule1 TYPE string,
         l_desig_level_rule2 TYPE string,
         l_desig_level_rule3 TYPE string,
         l_desig_level_rule4 TYPE string,
         l_desig_level_rule5 TYPE string.
  DATA : l_appended.
  DATA : l_gl TYPE string.

  l_appended = ''.

  CASE zic_prep_rolereq-desig_level.

    WHEN 'E0'.
      l_desig_level_rule1 = 'E0'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E0'.
      l_desig_level_rule4 = 'OFFICER_E0'.
    WHEN 'E1'.
      l_desig_level_rule1 = 'E1'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E1'.

    WHEN 'E2'.
      l_desig_level_rule1 = 'E2'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E2'.

    WHEN 'E3'.
      l_desig_level_rule1 = 'E3'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E3'.


    WHEN 'E4'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E4'.


    WHEN 'E5'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E4'.


    WHEN 'E6'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E4'.


    WHEN 'E7'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E4'.

    WHEN 'E8'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E1'.
      l_desig_level_rule4 = 'OFFICER_E4'.

    WHEN 'E9'.
      l_desig_level_rule1 = 'E4'.
      l_desig_level_rule2 = 'OFFICER'.
      l_desig_level_rule3 = 'E0'.
      l_desig_level_rule4 = 'OFFICER_E4'.

    WHEN OTHERS.
      l_desig_level_rule1 = 'ASSTT'.
      l_desig_level_rule2 = 'ASSTT'.
      l_desig_level_rule3 = 'ASSTT'.
      l_desig_level_rule4 = 'ASSTT'.
      l_desig_level_rule5 = 'ASSET'.
  ENDCASE.

  SEARCH wa_roles-role_name FOR 'CCCC'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.


*    if ZIC_PREP_ROLEREQ-DESIG_LEVEL = 'E1'.
    REPLACE 'OOOOOOOO' WITH l_desig_level_rule2 INTO
                                wa_roles1-role_name.
*    ENDIF.
    REPLACE 'CCCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.

    REPLACE 'RULE1' WITH l_desig_level_rule1 INTO
                                wa_roles1-role_name.
    REPLACE 'RULE3' WITH l_desig_level_rule3 INTO
                                wa_roles1-role_name.

    REPLACE 'OOOOOOOO' WITH l_desig_level_rule2 INTO
                                  wa_roles2-role_name.


    REPLACE 'CCCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles2-role_name.

    REPLACE 'RULE1' WITH l_desig_level_rule1 INTO
                                wa_roles2-role_name.
    REPLACE 'RULE3' WITH l_desig_level_rule3 INTO
                                wa_roles2-role_name.


    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  SEARCH wa_roles-role_name FOR 'GGGGG'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.

*    pack wa_rolesz-gl_account to l_gl.
    REPLACE 'GGGGG' WITH wa_rolesz-gl_account+5(5) INTO
                                wa_roles1-role_name.

    REPLACE 'GGGGG' WITH wa_rolesz-gl_account+5(5) INTO
                                wa_roles2-role_name.

    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  SEARCH wa_roles-role_name FOR 'JJJJ'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.

    CONDENSE wa_rolesz-jva_grp.
    REPLACE 'JJJJ' WITH wa_rolesz-jva_grp+0(3) INTO
                                wa_roles1-role_name.

    REPLACE 'RULE1' WITH l_desig_level_rule1 INTO
                                wa_roles1-role_name.
    REPLACE 'RULE3' WITH l_desig_level_rule3 INTO
                                wa_roles1-role_name.
    REPLACE 'RULE444444' WITH l_desig_level_rule4 INTO
                                wa_roles1-role_name.

    REPLACE 'JJJJ' WITH wa_rolesz-jva_grp+0(3) INTO
                                wa_roles2-role_name.

    REPLACE 'RULE1' WITH l_desig_level_rule1 INTO
                                wa_roles2-role_name.
    REPLACE 'RULE3' WITH l_desig_level_rule3 INTO
                                wa_roles2-role_name.
    REPLACE 'RULE444444' WITH l_desig_level_rule4 INTO
                                wa_roles2-role_name.


    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  SEARCH wa_roles-role_name FOR 'AREA'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.


    REPLACE 'AREA' WITH wa_rolesz-bussiness_area INTO
                                wa_roles1-role_name.

    REPLACE 'AREA' WITH wa_rolesz-bussiness_area INTO
                                wa_roles2-role_name.

    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  SEARCH wa_roles-role_name FOR 'DDD'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.

    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.


    REPLACE 'AREA' WITH wa_rolesz-bussiness_area INTO
                                wa_roles1-role_name.
    REPLACE 'CCCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.

    REPLACE 'AREA' WITH wa_rolesz-bussiness_area INTO
                                wa_roles2-role_name.
    REPLACE 'CCCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles2-role_name.


    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  SEARCH wa_roles-role_name FOR 'FFFFFF'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.


    REPLACE 'FFFFFF' WITH wa_rolesz-fund_ctr_gp INTO
                                wa_roles1-role_name.

    REPLACE 'FFFFFF' WITH wa_rolesz-fund_ctr_gp INTO
                                wa_roles2-role_name.

    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
    l_appended = 'X'.
  ENDIF.

  IF l_appended <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.


    wa_roles2-userid = zic_prep_rolereq-userid.
    wa_roles2-role_name = wa_roles-role_name.
    wa_roles2-role_type = wa_roles-role_type.

    APPEND wa_roles1 TO it_roles1.
    APPEND wa_roles2 TO it_roles2.
  ENDIF.


ENDFORM.                    " insert_data

*&---------------------------------------------------------------------*
*&      Form  insert_record
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_record.
  g_role_flag = 'X'.
ENDFORM.                    " insert_record
*&---------------------------------------------------------------------*
*&      Form  list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_processing.

  IF gl_ans = 'J'.
    SUPPRESS DIALOG.
    LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 100.
    PERFORM write_list.
    g_list_proc_flag = 'X'.
    CLEAR gl_ans.
  ENDIF.

ENDFORM.                    " list_processing

*&---------------------------------------------------------------------*
*&      Form  write_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_list.

  SET PF-STATUS 'STATUS_130' EXCLUDING 'SEL'.

  READ TABLE it_roles2 INTO wa_roles2 INDEX 1. "#EC CI_NOORDER
  g_userid = wa_roles2-userid.
  l_color = 5.
  LOOP AT it_roles2 INTO wa_roles2.
    IF g_userid = wa_roles2-userid.
      WRITE : / wa_roles2-userid COLOR 1, wa_roles2-role_name COLOR 3.
    ELSE.
      WRITE : / wa_roles2-userid COLOR 1, wa_roles2-role_name COLOR 3.
    ENDIF.
    g_userid = wa_roles2-userid.
  ENDLOOP.

  CLEAR wa_roles2.
  CLEAR it_roles2.

ENDFORM.                    " write_list

*&---------------------------------------------------------------------*
*&      Form  help_suim
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_suim.
  SELECT * FROM agr_users INTO TABLE it_agr_users
                  WHERE uname = zic_prep_rolereq-userid .

  REFRESH it_role_del_data.

  SORT it_agr_users DESCENDING BY from_dat to_dat.

  LOOP AT it_agr_users INTO wa_agr_users.
*
    IF wa_agr_users-from_dat <= sy-datum.
      WRITE: / wa_agr_users-agr_name,
             wa_agr_users-from_dat,
             wa_agr_users-to_dat.
      wa_role_del_data-userid = wa_agr_users-uname.
      wa_role_del_data-role_name = wa_agr_users-agr_name.
      APPEND wa_role_del_data TO it_role_del_data.
      HIDE :  wa_agr_users-agr_name,
              wa_agr_users-from_dat,
              wa_agr_users-to_dat.
      CLEAR :  wa_agr_users-agr_name,
               wa_agr_users-from_dat,
               wa_agr_users-to_dat.
      .
    ENDIF.
  ENDLOOP.
  lines = sy-linno .
  it_roles[] = it_role_del_data[].

  DESCRIBE TABLE it_role_del_data LINES g_lines1.

  IF g_lines1 > 0.


    " UC CHECK added
    DATA: gd_file TYPE string.
    TYPES: t_uctable LIKE LINE OF it_role_del_data.
    DATA: it_uctable TYPE STANDARD TABLE OF t_uctable.

    gd_file = 'C:\role_upload.txt'.

    it_uctable[] = it_roles1[].

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = gd_file
        filetype                = 'DAT'
      TABLES
        data_tab                = it_uctable
*       FIELDNAMES              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    " UC CHECK commented
**    CALL FUNCTION 'WS_DOWNLOAD'
**     EXPORTING
***     BIN_FILESIZE                  = ' '
***     CODEPAGE                      = ' '
**       FILENAME                      = 'C:\role_upload.txt'
**       FILETYPE                      = 'DAT'
***     MODE                          = ' '
***     WK1_N_FORMAT                  = ' '
***     WK1_N_SIZE                    = ' '
***     WK1_T_FORMAT                  = ' '
***     WK1_T_SIZE                    = ' '
***     COL_SELECT                    = ' '
***     COL_SELECTMASK                = ' '
***     NO_AUTH_CHECK                 = ' '
***   IMPORTING
***     FILELENGTH                    =
**      TABLES
**        DATA_TAB                      = IT_ROLE_DEL_DATA
***     FIELDNAMES                    =
**     EXCEPTIONS
**       FILE_OPEN_ERROR               = 1
**       FILE_WRITE_ERROR              = 2
**       INVALID_FILESIZE              = 3
**       INVALID_TYPE                  = 4
**       NO_BATCH                      = 5
**       UNKNOWN_ERROR                 = 6
**       INVALID_TABLE_WIDTH           = 7
**       GUI_REFUSE_FILETRANSFER       = 8
**       CUSTOMER_ERROR                = 9
**       OTHERS                        = 10
    .
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

  ELSE.

    CLEAR disp_flag.
    MESSAGE i059(zhelp).
    CLEAR old_ok_code.

  ENDIF.

ENDFORM.                    " help_suim

*&---------------------------------------------------------------------*
*&      Form  confirm_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_mail.

  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      textline1 = text-008
      titel     = text-009
    IMPORTING
      answer    = g_ans_mail.

  IF g_ans_mail = 'J'.
    PERFORM send_sapmail.
  ENDIF.

  CLEAR object_content.
  REFRESH object_content.

ENDFORM.                    " confirm_mail

*&---------------------------------------------------------------------*
*&      Form  SEND_SAPMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sapmail.

*--- Send mail to user

*
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'OVL Core Team'.
  document_data-obj_descr  = 'Mail from OVL Core Team'.
  SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  CONCATENATE document_data-obj_descr '---' zauth_user-primary_module
  '-' 'Module' INTO document_data-obj_descr.
  document_data-priority   = '3'.

* Remove prefix 'US' from receiver
  REFRESH receivers.

  CLEAR wa_receivers.
  wa_receivers-receiver = zic_prep_rolereq-useridcr.
  wa_receivers-rec_type = 'B'.
  wa_receivers-express  = 'X'.
  APPEND wa_receivers TO receivers.

  CLEAR wa_receivers.

  MOVE space TO object_content-line.
  APPEND object_content.

  CONCATENATE  'Subject: '  'Assigning of Roles for userid '
zic_prep_rolereq-userid INTO  object_content-line
SEPARATED BY space.
  APPEND object_content.

**********************************  Added by Bipin Shukla : on 16/10/2013
  MOVE space TO object_content-line.
  object_content-line = 'Dear Sir/Madam'.
  APPEND object_content.
**********************************  Added by Bipin Shukla : on 16/10/2013

  MOVE space TO object_content-line.
  APPEND object_content.
  IF zic_prep_rolereq-status = 'C'.
    CONCATENATE 'Your Role Request No.' zic_prep_rolereq-docno 'has  been assigned  &  completed' INTO
object_content-line
SEPARATED BY space.
    APPEND object_content.
  ELSE.
    CONCATENATE 'Please check your role request which has been updated' &
' - ' zic_prep_rolereq-docno INTO  object_content-line
SEPARATED BY space.
    APPEND object_content.
  ENDIF.
********************************************************************
  IF zic_prep_rolereq-status = 'IC'.
    MOVE 'Please go through correspondence in the request.The request' &
'needs to be changed, re-released & re-approved by competent authority.' &
'Once the request is approved, the request will flow to OVL core team.'
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'IR'.
    MOVE 'Please go through the correspondence in the request & reply' &
'to the query raised by OVL core team. You need to save the request after' &
'giving reply in correspondence(In display mode only).Once the request' &
'is saved, the request will flow to ICE core team.' TO
object_content-line.
    APPEND object_content.
    MOVE 'No re-release or approvals are required in this case & user' &
'will not be able to open the request in change mode.'
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'PC'.
    MOVE 'Your request is still under process with OVL core team. Only' &
' partial roles have been assigned. You will get the next message'
TO object_content-line.
    APPEND object_content.
    MOVE 'for completion or return of request soon.'
                                                     TO
object_content-line.
    APPEND object_content.
  ENDIF.
********************************************************************
  MOVE space TO object_content-line.
  APPEND object_content.

  object_content-line = 'Regards'.
  APPEND object_content.

  object_content-line = 'OVL Core Team'.
  APPEND object_content.

  CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = document_data
      document_type              = 'RAW'
      put_in_outbox              = 'X'
    IMPORTING
      sent_to_all                = sent_to_all
    TABLES
      object_header              = objhead
      object_content             = object_content
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 01
      document_not_sent          = 02
      document_type_not_exist    = 03
      operation_no_authorization = 04
      parameter_error            = 05
      x_error                    = 06
      enqueue_error              = 07.

  CASE sy-subrc.
    WHEN 0.

      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
    WHEN '01'.
      RAISE too_many_receivers.
    WHEN '02'.
      RAISE document_not_sent.
    WHEN '03'.
      RAISE document_type_not_exist.
    WHEN '04'.
      RAISE operation_no_authorization.
    WHEN '05'.
      RAISE parameter_error.
    WHEN '06'.
      RAISE x_error.
    WHEN '07'.
      RAISE enqueue_error.
  ENDCASE.

********************************************
********************************************

ENDFORM.                    " SEND_SAPMAIL
*&---------------------------------------------------------------------*
*&      Form  insert_header_assign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_header_assign.

  zic_prep_rolereq-mandt = sy-mandt.
  IF old_ok_code = 'CREATE'.
    zic_prep_rolereq-docno = zdocnumb.
  ENDIF.


  IF zic_prep_rolereq-useridcr IS INITIAL.

    zic_prep_rolereq-useridcr = sy-uname.
    zic_prep_rolereq-cr_date  = sy-datum.

    IF sy-tcode <> 'ZIC_AUTH_FI_REP'.

      CLEAR zusrmst.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                                 zic_prep_rolereq-useridcr.

      IF sy-subrc NE 0.

      ELSE.
*
        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
          zusrmst-last_name.
        zic_prep_rolereq-namecr = zusrmst-last_name.

      ENDIF.

    ENDIF.

  ENDIF.

  IF zic_prep_rolereq-useridap IS INITIAL.

    IF old_ok_code = 'APPROVE' AND
          ( zic_prep_rolereq-req_app_fl = 'X' ).
      zic_prep_rolereq-useridap = sy-uname.
      zic_prep_rolereq-app_date  = sy-datum.

      CLEAR zusrmst.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                            zic_prep_rolereq-useridap.

      IF sy-subrc NE 0.

      ELSE.

        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
         zusrmst-last_name.
        zic_prep_rolereq-nameapp = zusrmst-last_name.
      ENDIF.

    ENDIF.

  ELSE.

    IF old_ok_code = 'APPROVE' AND
          zic_prep_rolereq-req_app0_fl = 'X'
                AND zic_prep_rolereq-req_app1_fl = 'X'.

      zic_prep_rolereq-useridap = sy-uname.
      zic_prep_rolereq-app_date = sy-datum.

      SELECT SINGLE * FROM zusrmst WHERE cpfno =
                              zic_prep_rolereq-useridap.
      IF sy-subrc NE 0.
        MESSAGE e043(zhelp).
      ELSE.

        CONCATENATE zusrmst-first_name zusrmst-last_name INTO
        zusrmst-last_name.
        zic_prep_rolereq-nameapp = zusrmst-last_name.
      ENDIF.
    ENDIF.
  ENDIF.

  IF zic_prep_rolereq-status <> 'C'.

    zic_prep_rolereq-status = 'IF'.
  ENDIF.

*****
  IF g_fundc_err_flag <> 'X'.

*    IF corr_code = 'CORR' AND sy-tcode = 'ZIC_AUTH_FI_REP'.
*      CLEAR : corr_code.
*
*      PERFORM confirm_process.
*      IF status_process = 'J'.
*        CLEAR status_process.
*        status_process_flag = 'X'.
*      ELSE.
*        IF zic_prep_rolereq-comm_fl = 'X'.
*          zic_prep_rolereq-status = 'IR'.
*        ELSE.
*          PERFORM confirm_status.
*          IF status_choice = 'J'.
*            CLEAR status_choice.
*            zic_prep_rolereq-status = 'IC'.
*          ELSE.
*            zic_prep_rolereq-comm_fl = 'X'.
*            zic_prep_rolereq-status = 'IR'.
*          ENDIF.
*        ENDIF.
*        PERFORM send_sapmail.
*        REFRESH object_content.
*        CLEAR corr_code.
*      ENDIF.
*    ENDIF.

*************************************************************

** Module wise check & insertion

    CASE moduleid.

      WHEN 'FI'.

        PERFORM insert_items_fi.

    ENDCASE.

    IF sy-tcode <> 'ZIC_AUTH_FI_REP'.

      PERFORM items_approval_check.

    ENDIF.

***********************

    IF sy-subrc = 0 AND ( zic_prep_rolereq-status <> 'IC'
                        AND zic_prep_rolereq-status <> 'IR' ).

      SELECT * FROM zic_prep_rolerei INTO TABLE ist_itemtab
              WHERE docno = zic_prep_rolereq-docno.

      LOOP AT ist_itemtab INTO wa_itemtab.
        IF wa_itemtab-rej_fl = ''.
          IF wa_itemtab-status = '' AND
              wa_itemtab-role_request = ''.
            g_request_close_flag_p  = 'X'.
          ELSEIF wa_itemtab-status = 'H'.
            g_request_close_flag_h = 'X'.
          ELSEIF  wa_itemtab-role_request <> ''.
            g_request_close_flag_r = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF ( g_request_close_flag_p  = 'X' OR
         g_request_close_flag_h  = 'X' ) AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'PC'.
      ELSEIF g_request_close_flag_p  <> 'X' AND
         g_request_close_flag_h  = 'X' AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'PC'.
      ELSEIF g_request_close_flag_p  = '' AND
         g_request_close_flag_h  = '' AND
         g_request_close_flag_r = 'X'.
        zic_prep_rolereq-status = 'C'.
      ELSEIF g_request_close_flag_p  = 'X' AND
         g_request_close_flag_h  <> 'X' AND
         g_request_close_flag_r <> 'X'.
        zic_prep_rolereq-status = 'IF'.
      ELSEIF  g_request_close_flag_p = '' AND
               g_request_close_flag_h = '' AND
                 g_request_close_flag_r <> ''.
        zic_prep_rolereq-status = 'C'.
      ENDIF.

    ENDIF.

    MODIFY zic_prep_rolereq FROM zic_prep_rolereq.

    CLEAR : g_request_close_flag_p, g_request_close_flag_h,
            g_request_close_flag_r.


****Saving the long text.                              *****

    IF ( old_ok_code = 'CREATE' ) OR
       ( old_ok_code = 'CHANGE' ) OR
       ( old_ok_code = 'RELEASE' ) OR
       ( old_ok_code = 'APPROVE' ) OR
       ( save_old_ok_code = 'ASSIGN' ).

      CLEAR save_old_ok_code.
      PERFORM save_cors_text.

    ENDIF.

*    IF g_role_flag = 'X'.
*      CLEAR g_role_flag.
*      PERFORM unlock_record.
*
*    ELSE.
*
*      IF l_old_ok_code = 'X'.
*        SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
*        EXIT.
*      ELSE.
*        PERFORM clear.
*        PERFORM unlock_record.
*        CALL SCREEN 100.
*      ENDIF.
*
*    ENDIF.

  ELSE.

    CLEAR g_fundc_err_flag.
    CALL SCREEN 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    CLEAR okcode_100.

  ENDIF.

ENDFORM.                    " insert_header_assign

*----------------------------------------------------------------------*
*   INCLUDE MZFIPREPROLEF01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bac_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM bac_confirm.

  DATA l_choice.
  CLEAR l_choice.
  IF g_mode <> 'DIS'.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        textline1      = 'Data will be lost, Want to quit? '
        titel          = 'BACK'
        start_column   = 25
        start_row      = 6
        cancel_display = ''
      IMPORTING
        answer         = l_choice.

    IF l_choice = 'J'.

*       perform clear_var.
      CLEAR l_choice.
    ENDIF.
  ELSE.
*     perform clear_var.
  ENDIF.

ENDFORM.                    " bac_confirm

*&---------------------------------------------------------------------*
*&      Form  insert_items_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_delfi.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab_del, ist_itemtab_del.

  SORT g_tablectrl_215_itab  BY role_name .

  DELETE ADJACENT DUPLICATES FROM g_tablectrl_215_itab
    COMPARING role_name moduleid fr_date_auth to_date_auth.

  LOOP AT g_tablectrl_215_itab INTO g_tablectrl_215_wa.
    IF g_tablectrl_215_wa-role_sel = 'X'.
      MOVE-CORRESPONDING g_tablectrl_215_wa TO wa_itemtab_del.
*    endif.

      IF sy-tcode = 'ZIC_AUTH_FI_REP'.
        IF g_role_flag = 'X' AND wa_itemtab_del-rej_fl = '' AND
          wa_itemtab_del-status = '' AND wa_itemtab_del-role_request = ''.
          wa_itemtab_del-role_request = zrolereqno.
        ENDIF.
      ENDIF.


*    Perform check_items_save.

      IF old_ok_code = 'ROLE_DEL'.
        wa_itemtab_del-docno = zdocnumb.
      ENDIF.

      wa_itemtab_del-mandt = sy-mandt.
      IF wa_itemtab_del-rej_fl <> ''.
        wa_itemtab_del-rej_fl_save = 'X'.
      ENDIF.
      IF NOT wa_itemtab_del-role_name IS INITIAL.
        i = i + 1.
        wa_itemtab_del-srno = i .
        APPEND wa_itemtab_del TO ist_itemtab_del.
      ENDIF.

      g_i = i.

*    perform check_module_wise.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE ist_itemtab_del LINES g_lines_rl.

  IF g_lines_rl = 0.
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSEIF old_ok_code = 'ROLE_DEL' .
      MESSAGE i103(zhelp) WITH zic_prep_rolereq-docno.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    IF old_ok_code = 'RELEASE' AND g_lines_rl = 0.
      ROLLBACK WORK.
      MESSAGE i089(zhelp).
    ELSE.

      IF old_ok_code = 'ROLE_DEL'.
      ELSEIF old_ok_code <> 'DISPLAY'.
*        delete from zic_prep_delrole where
*        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      ENDIF.

      MODIFY zic_prep_delrole FROM TABLE ist_itemtab_del.

    ENDIF.

  ENDIF.

  CLEAR l_del_request.

ENDFORM.                    " insert_items_delfi
*&---------------------------------------------------------------------*
*&      Form  GRC_RISK_ANALYSIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM grc_risk_analysis." USING P_VALUE

  IF old_ok_code = 'APPROVE'.
    check_okcode = 'A'.
  ELSEIF old_ok_code = 'CREATE'.
    check_okcode = 'C'.
  ELSEIF old_ok_code = 'CHANGE'.
    check_okcode = 'M'.
  ENDIF.
  CLEAR gt_buk_role.
  CLEAR gt_final_tb.
  CLEAR gt_viol_dtl.
  CLEAR gt_bucket.
  CLEAR gt_bucket1.
  CLEAR gt_eroles.
  CLEAR gt_eroles1.
  CLEAR gt_userinfo.
  CLEAR gt_output.
  CLEAR gt_violdtl.
  CLEAR gt_rdesc.
  IMPORT  reqnum_ex FROM MEMORY ID 'REQNUM_IM'.
******************* DELETING PRIVIOUS RISK ANALYSIS**************************

  DELETE FROM zgrc_sod_result WHERE docno = reqnum_ex.
  DELETE FROM zgrc_viol_dtl WHERE docno = reqnum_ex.
  COMMIT WORK AND WAIT.
******************* DELETING PRIVIOUS RISK ANALYSIS**************************

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

    MOVE-CORRESPONDING g_tablctrl111_wa TO wa_bucket.
    wa_bucket-docno = reqnum_ex.
    APPEND wa_bucket TO gt_bucket.
*    CLEAR WA_BUCKET.
  ENDLOOP.

  DELETE gt_bucket WHERE rej_fl = 'H'.


  LOOP AT gt_bucket INTO wa_bucket.

    MOVE-CORRESPONDING wa_bucket TO wa_bucket1.
    APPEND  wa_bucket1 TO gt_bucket1.



    CALL FUNCTION 'ZGRC_DEV_FM'
      EXPORTING
        t_tbtc    = gt_bucket1
        req_num   = wa_bucket-docno
      IMPORTING
        it_roles2 = gt_eroles.

*CLEAR WA_BUCKET1.
    LOOP AT  gt_eroles INTO wa_eroles.

      MOVE-CORRESPONDING wa_eroles TO wa_eroles1.
      APPEND wa_eroles1 TO  gt_eroles1.

    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_bucket1 INTO wa_bucket1.
    wa_buk_role-docno	=	wa_bucket1-docno.
    wa_buk_role-moduleid  = wa_bucket1-moduleid.
    wa_buk_role-srno  = wa_bucket1-srno.
    wa_buk_role-role_name	=	wa_bucket1-role_name.
    wa_buk_role-plant = wa_bucket1-plant .
    wa_buk_role-grp = wa_bucket1-grp .
    wa_buk_role-sloc  = wa_bucket1-sloc  .
    wa_buk_role-receipt_loc = wa_bucket1-receipt_loc .
    wa_buk_role-approver  = wa_bucket1-approver  .
    wa_buk_role-status  = wa_bucket1-status  .
    wa_buk_role-role_request  = wa_bucket1-role_request.
    wa_buk_role-rej_fl  = wa_bucket1-rej_fl  .
    wa_buk_role-rej_id  = wa_bucket1-rej_id  .
    wa_buk_role-rej_date  = wa_bucket1-rej_date  .
    wa_buk_role-rej_fl_save = wa_bucket1-rej_fl_save .
    wa_buk_role-shop_no = wa_bucket1-shop_no .
    wa_buk_role-role_desc = wa_bucket1-role_desc .
    wa_buk_role-flag  = wa_bucket1-flag  .
    wa_buk_role-gl_account  = wa_bucket1-gl_account  .
    wa_buk_role-bussiness_area  = wa_bucket1-bussiness_area  .
    wa_buk_role-fund_ctr_gp = wa_bucket1-fund_ctr_gp .
    wa_buk_role-jva_grp = wa_bucket1-jva_grp .
    wa_buk_role-sub_module  = wa_bucket1-sub_module.
    wa_buk_role-role_sensitivity  = wa_bucket1-role_sensitivity  .
    wa_buk_role-fr_date_auth  = wa_bucket1-fr_date_auth  .
    wa_buk_role-to_date_auth  = wa_bucket1-to_date_auth.
    wa_buk_role-role_type_ex  = wa_bucket-role_type_ex  .
    wa_buk_role-sale_org  = wa_bucket1-sale_org  .
    wa_buk_role-div = wa_bucket1-div .
    wa_buk_role-ship_point  = wa_bucket1-ship_point  .
    wa_buk_role-asset = wa_bucket1-asset .
    wa_buk_role-basin = wa_bucket1-basin .
    wa_buk_role-project = wa_bucket1-project .
    wa_buk_role-location  = wa_bucket1-location  .
    wa_buk_role-asset_qm  = wa_bucket1-asset_qm  .
    wa_buk_role-res = wa_bucket1-res .
    wa_buk_role-ctf_sloc  = wa_bucket1-ctf_sloc  .

    LOOP AT gt_eroles INTO wa_eroles WHERE role_type = wa_buk_role-role_name .

      wa_buk_role-userid  = wa_eroles-userid  .
      wa_buk_role-role_type	=	wa_eroles-role_type	.
      wa_buk_role-role_name_final	=	wa_eroles-role_name	.
      wa_buk_role-fr_date_auth_final  = wa_eroles-fr_date_auth  .
      wa_buk_role-to_date_auth_final  = wa_eroles-to_date_auth  .

      IF  wa_buk_role-role_name_final = 'M:COMMON_USER_TOOLS'.
        wa_buk_role-role_name = ''.
        wa_buk_role-role_type = ''.
      ENDIF.


      APPEND wa_buk_role TO gt_buk_role.



    ENDLOOP.

    CLEAR  wa_buk_role.
  ENDLOOP.
  SORT gt_buk_role BY role_name_final.
  DELETE ADJACENT DUPLICATES FROM gt_buk_role COMPARING role_name_final.

  SORT gt_eroles1 BY role_name.
  DELETE ADJACENT DUPLICATES FROM gt_eroles1 COMPARING role_name.

*  IF GT_BUCKET1 IS NOT INITIAL.
  SELECT userid designation persa rsn_code telno ccode fundc1 persk reasonforauth
  costc desig_level name name1 rsn_text1
  FROM zic_prep_rolereq
  INTO CORRESPONDING FIELDS OF TABLE gt_userinfo
  WHERE docno = wa_bucket-docno.
*  ENDIF.

  IF gt_bucket1 IS INITIAL.
    MESSAGE 'All Role are rejected by HOF !!' TYPE 'I'.
    RETURN.
  ENDIF .

  IF syst-sysid = 'RD1'.

    lv_rfc = 'GRDCLNT500'.

  ELSEIF syst-sysid = 'RQ1'.

    lv_rfc = 'GRDCLNT500'.

  ELSEIF syst-sysid = 'RP1'.

    lv_rfc = 'GRPCLNT500'.
  ENDIF.

  CALL FUNCTION 'ZGRC_RFC_FM' DESTINATION lv_rfc "'GRDCLNT500'
    EXPORTING
      it_roles2       = gt_eroles1
      ip_bucket       = gt_bucket1
      ip_userinfo     = gt_userinfo
      ip_cokcode      = check_okcode
    IMPORTING
      et_final        = gt_output
      gt_risk_desc    = gt_rdesc
      lt_act_viol_det = gt_violdtl.

*   IF GT_RDESC IS INITIAL.

  EXPORT gt_rdesc TO MEMORY ID 'IM_GT_RDESC'.
*     ENDIF.


  CHECK sy-subrc EQ 0.
  DESCRIBE TABLE gt_violdtl LINES lv_lines.
*   LV_LINES = SY-DBCNT.
  CLEAR: gd_percent.


  READ TABLE gt_buk_role INTO wa_buk_role INDEX 1. "#EC CI_NOORDER
  IF sy-subrc = 0.
    lv_docno = wa_buk_role-docno.
  ENDIF.

  LOOP AT gt_rdesc INTO wa_rdesc. "WHERE COMPROLE EQ WA_FINAL_TB-ROLE_NAME_FINAL OR ROLE EQ WA_FINAL_TB-ROLE_NAME_FINAL .

    wa_final_tb-xconnector  = wa_rdesc-xconnector  .
    wa_final_tb-objectid  = wa_rdesc-objectid  .
    wa_final_tb-riskid  = wa_rdesc-riskid  .
    wa_final_tb-actruleid = wa_rdesc-actruleid  .
    wa_final_tb-connector = wa_rdesc-connector  .
    wa_final_tb-functid = wa_rdesc-functid  .
    wa_final_tb-action  = wa_rdesc-action  .
    wa_final_tb-resourceid  = wa_rdesc-resourceid  .
    wa_final_tb-resourceextn  = wa_rdesc-resourceextn  .
    wa_final_tb-fromval = wa_rdesc-fromval  .
    wa_final_tb-toval = wa_rdesc-toval  .
    wa_final_tb-role  = wa_rdesc-role  .
    wa_final_tb-comprole  = wa_rdesc-comprole  .
    wa_final_tb-accontrolid = wa_rdesc-accontrolid  .
    wa_final_tb-monitor = wa_rdesc-monitor  .
    wa_final_tb-orgruleid = wa_rdesc-orgruleid  .
    wa_final_tb-prmsource = wa_rdesc-prmsource  .
    wa_final_tb-risktype  = wa_rdesc-risktype  .
    wa_final_tb-objecttype  = wa_rdesc-objecttype  .
    wa_final_tb-validfrom = wa_rdesc-validfrom  .
    wa_final_tb-validto = wa_rdesc-validto  .
    wa_final_tb-active  = wa_rdesc-active  .
    wa_final_tb-lastexecutedon  = wa_rdesc-lastexecutedon  .
    wa_final_tb-terminalname  = wa_rdesc-terminalname  .
    wa_final_tb-executioncount  = wa_rdesc-executioncount  .
    wa_final_tb-lang  = wa_rdesc-lang  .
    wa_final_tb-descn  = wa_rdesc-descn  .
    wa_final_tb-dt_desc  = wa_rdesc-dt_desc  .
    wa_final_tb-grc_rqno  = wa_rdesc-grc_rqno  .


*  V_SNUM = LV_SNUM = LV_SNUM + 1.
    v_snum = v_snum + 1.
    wa_final_tb-serialno = v_snum.

*  start of role
    READ TABLE gt_buk_role INTO wa_buk_role WITH KEY role_name_final = wa_rdesc-comprole.
    IF sy-subrc NE 0.
      READ TABLE gt_buk_role INTO wa_buk_role WITH KEY role_name_final = wa_rdesc-role.
    ENDIF.
    wa_final_tb-docno =     lv_docno. "WA_BUK_ROLE-DOCNO.
    wa_final_tb-moduleid = 	 wa_buk_role-moduleid.
    wa_final_tb-srno  =	 wa_buk_role-srno.
    wa_final_tb-role_name =     wa_buk_role-role_name.
    wa_final_tb-plant =	 wa_buk_role-plant .
    wa_final_tb-grp =	 wa_buk_role-grp .
    wa_final_tb-sloc  =	 wa_buk_role-sloc  .
    wa_final_tb-receipt_loc =	 wa_buk_role-receipt_loc .
    wa_final_tb-approver  =	 wa_buk_role-approver  .
    wa_final_tb-status = wa_buk_role-status  .
    wa_final_tb-role_request =   wa_buk_role-role_request.
    wa_final_tb-rej_fl = 	 wa_buk_role-rej_fl  .
    wa_final_tb-rej_id = 	 wa_buk_role-rej_id  .
    wa_final_tb-rej_date = 	 wa_buk_role-rej_date  .
    wa_final_tb-rej_fl_save =	 wa_buk_role-rej_fl_save .
    wa_final_tb-shop_no =	 wa_buk_role-shop_no .
    wa_final_tb-role_desc =	 wa_buk_role-role_desc .
    wa_final_tb-flag = 	 wa_buk_role-flag  .
    wa_final_tb-gl_account =     wa_buk_role-gl_account  .
    wa_final_tb-bussiness_area =     wa_buk_role-bussiness_area  .
    wa_final_tb-fund_ctr_gp =	 wa_buk_role-fund_ctr_gp .
    wa_final_tb-jva_grp =	 wa_buk_role-jva_grp .
    wa_final_tb-sub_module  =	 wa_buk_role-sub_module.
    wa_final_tb-role_sensitivity  =	 wa_buk_role-role_sensitivity  .
    wa_final_tb-fr_date_auth  =	 wa_buk_role-fr_date_auth  .
    wa_final_tb-to_date_auth = 	 wa_buk_role-to_date_auth.
    wa_final_tb-role_type_ex  =	 wa_bucket-role_type_ex  .
    wa_final_tb-sale_org = 	 wa_buk_role-sale_org  .
    wa_final_tb-div =	 wa_buk_role-div .
    wa_final_tb-ship_point =     wa_buk_role-ship_point  .
    wa_final_tb-asset =    wa_buk_role-asset .
    wa_final_tb-basin =	 wa_buk_role-basin .
    wa_final_tb-project =	 wa_buk_role-project .
    wa_final_tb-location = 	 wa_buk_role-location  .
    wa_final_tb-asset_qm  =	 wa_buk_role-asset_qm  .
    wa_final_tb-res =	 wa_buk_role-res .
    wa_final_tb-ctf_sloc  =	 wa_buk_role-ctf_sloc  .
    wa_final_tb-userid  = wa_buk_role-userid  .
    wa_final_tb-role_type	=	wa_buk_role-role_type	.
    wa_final_tb-role_name_final	=	wa_buk_role-role_name_final	.
    wa_final_tb-fr_date_auth_final  = wa_buk_role-fr_date_auth_final  .
    wa_final_tb-to_date_auth_final  = wa_buk_role-to_date_auth_final  .

*  end of role

    APPEND wa_final_tb TO gt_final_tb.
    CLEAR :wa_final_tb,gs_output_temp,wa_buk_role.


  ENDLOOP.




  CLEAR: lv_docno.
  IF gt_final_tb[] IS INITIAL.
*  V_SNUM = LV_SNUM = LV_SNUM + 1.
    v_snum = v_snum + 1.
    wa_final_tb-serialno = v_snum.
    wa_final_tb-docno = reqnum_ex.
    APPEND wa_final_tb TO gt_final_tb.
    CLEAR: wa_final_tb.
  ENDIF.

*SELECT SINGLE MAX( SERIALNO ) FROM ZGRC_VIOL_DTL INTO LV_SNUM1.


  LOOP AT gt_violdtl INTO wa_violdtl.

    lv_indx1 = sy-tabix.


    v_snum1 = v_snum1 + 1.
    wa_viol_dtl-docno =     reqnum_ex.
    wa_viol_dtl-serialno = v_snum1.

    wa_viol_dtl-xconnector  = wa_violdtl-xconnector  .
    wa_viol_dtl-objectid  = wa_violdtl-objectid  .
    wa_viol_dtl-riskid  = wa_violdtl-riskid  .
    wa_viol_dtl-actruleid = wa_violdtl-actruleid  .
    wa_viol_dtl-connector = wa_violdtl-connector  .
    wa_viol_dtl-functid = wa_violdtl-functid  .
    wa_viol_dtl-action  = wa_violdtl-action  .
    wa_viol_dtl-resourceid  = wa_violdtl-resourceid  .
    wa_viol_dtl-resourceextn  = wa_violdtl-resourceextn  .
    wa_viol_dtl-fromval = wa_violdtl-fromval  .
    wa_viol_dtl-toval = wa_violdtl-toval  .
    wa_viol_dtl-role  = wa_violdtl-role  .
    wa_viol_dtl-comprole  = wa_violdtl-comprole  .
    wa_viol_dtl-accontrolid = wa_violdtl-accontrolid  .
    wa_viol_dtl-monitor = wa_violdtl-monitor  .
    wa_viol_dtl-orgruleid = wa_violdtl-orgruleid  .
    wa_viol_dtl-prmsource = wa_violdtl-prmsource  .
    wa_viol_dtl-risktype  = wa_violdtl-risktype  .
    wa_viol_dtl-objecttype  = wa_violdtl-objecttype  .
    wa_viol_dtl-validfrom = wa_violdtl-validfrom  .
    wa_viol_dtl-validto = wa_violdtl-validto  .
    wa_viol_dtl-active  = wa_violdtl-active  .
    wa_viol_dtl-lastexecutedon  = wa_violdtl-lastexecutedon  .
    wa_viol_dtl-terminalname  = wa_violdtl-terminalname  .
    wa_viol_dtl-executioncount  = wa_violdtl-executioncount  .


*    READ TABLE GT_FINAL_RISK  INTO WA_FINAL_RISK WITH KEY RISKID = WA_FINAL-RISKID.

    READ TABLE gt_final_tb INTO wa_final_tb WITH KEY riskid = wa_violdtl-riskid.

    PERFORM progress_bar USING 'Please wait Risk analysis is in process..'(005)
                               lv_indx1
                               lv_lines.

    wa_viol_dtl-descn = wa_final_tb-descn.
    wa_viol_dtl-dt_desc = wa_final_tb-dt_desc.
    wa_viol_dtl-grc_rqno = wa_final_tb-grc_rqno.

    APPEND wa_viol_dtl TO gt_viol_dtl.
    CLEAR: wa_viol_dtl.
    CLEAR wa_violdtl.
    CLEAR wa_final_tb.
  ENDLOOP.

  IF gt_viol_dtl[] IS INITIAL.
    v_snum1 = v_snum1 + 1.
    wa_viol_dtl-serialno = v_snum1.
    wa_viol_dtl-docno = reqnum_ex.
    APPEND wa_viol_dtl TO gt_viol_dtl.
    CLEAR: wa_viol_dtl.
  ENDIF.

*************** Progress indicator
*DATA: LV_LINES TYPE I.




*  LOOP AT GT_FINAL_TB INTO WA_FINAL_TB.

*    ENDLOOP.

*************** Progress indicator





  MODIFY  zgrc_sod_result FROM  TABLE gt_final_tb .
  MODIFY  zgrc_viol_dtl FROM  TABLE gt_viol_dtl .
  COMMIT WORK AND WAIT.

*  REQNUM_ALV = ZIC_PREP_ROLEREQ-DOCNO.
*
*  IMPORT  REQNUM_ALV FROM MEMORY ID 'REQNUM_IP'.
*  CALL TRANSACTION 'ZGRC_RESULT'.

ENDFORM.                    " GRC_RISK_ANALYSIS
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_BAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7438   text
*      -->P_LV_INDX1  text
*      -->P_LV_LINES  text
*----------------------------------------------------------------------*
*FORM PROGRESS_BAR  USING    P_VALUE
*                            P_LV_INDX1
*                            P_LV_LINES.
*
*
*  DATA: W_TEXT(40),
*        W_PERCENTAGE TYPE P,
*        W_PERCENT_CHAR(3).
*
*  W_PERCENTAGE = ( P_LV_INDX1 / P_LV_LINES ) * 100.
*  W_PERCENT_CHAR = W_PERCENTAGE.
*  SHIFT W_PERCENT_CHAR LEFT DELETING LEADING ' '.
*  CONCATENATE P_VALUE W_PERCENT_CHAR '% Complete'(002) INTO W_TEXT.
*
**  IF W_PERCENTAGE GT GD_PERCENT OR P_LV_INDX1 EQ 1.
*    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*      EXPORTING
*        PERCENTAGE = W_PERCENTAGE
*        TEXT       = W_TEXT.
*    GD_PERCENT = W_PERCENTAGE.
**  ENDIF.                " PROGRESS_BAR
*
*
*
*ENDFORM.                    " PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_BAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_7439   text
*      -->P_LV_INDX1  text
*      -->P_LV_LINES  text
*----------------------------------------------------------------------*
FORM progress_bar  USING    VALUE(p_7439)
                            p_lv_indx1
                            p_lv_lines.
  DATA: w_text(40),
        w_percentage      TYPE p,
        w_percent_char(3).

  w_percentage = ( p_lv_indx1 / p_lv_lines ) * 100.
  w_percent_char = w_percentage.
  SHIFT w_percent_char LEFT DELETING LEADING ' '.
  CONCATENATE p_7439 w_percent_char '% Complete'(004) INTO w_text SEPARATED BY space.

*  IF W_PERCENTAGE GT GD_PERCENT OR P_LV_INDX1 EQ 1.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = w_percentage
      text       = w_text.
  gd_percent = w_percentage.
*  ENDIF.                " PROGRESS_BAR


ENDFORM.                    " PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  ROLE_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM role_help .
  DATA: upl_count TYPE i.
  DATA: xflag(1).
  DATA: xxcpf_no LIKE zauth_item-cpf_no.
  DATA: xxrole LIKE zauth_item-role.


  DATA: xxfrom_dat LIKE zauth_item-from_dat .
  DATA: xxto_dat LIKE zauth_item-to_dat .
  DATA: l_agr_users LIKE TABLE OF agr_users WITH HEADER LINE .


  DATA : dateo(10), date LIKE sy-datum.
*  DATA : zuserid LIKE zauth_head-requested_by.
*  DATA : zapprover LIKE zauth_head-approved_by.
*  DATA:v_remarks_head TYPE zauth_head-remarks,
*       v_moduleid(3).

  zauth_head-auth_req_date = sy-datum.

*  IMPORT  v_moduleid TO  v_moduleid FROM MEMORY ID 'ID3'.
  zauth_head-primod = v_moduleid.

*  IMPORT v_remarks_head TO v_remarks_head FROM MEMORY ID 'ID2'.


  zauth_head-remarks  = v_remarks_head.

*  IMPORT zuserid TO zuserid FROM MEMORY ID 'ID'.
  zauth_head-requested_by  = zuserid.

*  IMPORT zapprover TO zapprover FROM MEMORY ID 'ID1'.
  zauth_head-approved_by = zapprover.


  CLEAR upl_tab. REFRESH upl_tab.
  CLEAR upl_tabx. REFRESH upl_tabx.




  CLEAR:wa_roles1.
  LOOP AT it_roles1 INTO wa_roles1.
    upl_tabx-cpf_no = wa_roles1-userid.
    upl_tabx-role = wa_roles1-role_name.
    upl_tabx-from_dat = wa_roles1-fr_date_auth.
    upl_tabx-to_dat  = wa_roles1-to_date_auth.
    APPEND  upl_tabx.
  ENDLOOP.

  LOOP AT upl_tabx.

    upl_tab-cpf_no = upl_tabx-cpf_no.
    upl_tab-role   = upl_tabx-role.

*******************************************************
    dateo = upl_tabx-from_dat.
    CONCATENATE dateo+6(4) dateo+3(2) dateo+0(2) INTO date.
***************************************************
    upl_tab-from_dat   = date.

    CLEAR : dateo, date.

    dateo = upl_tabx-to_dat.
    CONCATENATE dateo+6(4) dateo+3(2) dateo+0(2) INTO date.

    upl_tab-to_dat   = date.

    CLEAR : dateo, date.


***************************************************

    APPEND upl_tab.

  ENDLOOP.
***********************
  REFRESH upl_tabx.
  CLEAR   upl_tabx.
***********************
  IF sy-subrc EQ 0.
    xxcpf_no = 'XX'.
    xxrole   = 'XX'.
*******************************************************
    LOOP AT upl_tab.
      TRANSLATE upl_tab TO UPPER CASE.
      MODIFY upl_tab.
    ENDLOOP.
***********************************************************************
    LOOP AT upl_tab.
      IF upl_tab-cpf_no EQ space AND
         upl_tab-role EQ space.
        DELETE upl_tab.
        CONTINUE.
      ENDIF.
      IF upl_tab-cpf_no EQ space.
        upl_tab-cpf_no = xxcpf_no.
      ENDIF.
      IF upl_tab-role EQ space.
        upl_tab-role  = xxrole.
      ENDIF.

      IF upl_tab-from_dat EQ '00000000' .
        upl_tab-from_dat = sy-datum .
      ENDIF .
      IF upl_tab-to_dat EQ '00000000' .
        upl_tab-to_dat = '99991231' .
      ENDIF .


      MODIFY upl_tab.
      xxcpf_no = upl_tab-cpf_no.
      xxrole   = upl_tab-role.
    ENDLOOP.
    SORT upl_tab.
    DELETE ADJACENT DUPLICATES FROM upl_tab.

    LOOP AT upl_tab.
      xflag = 'N'.
      upl_tabx-cpf_no = upl_tab-cpf_no.
      upl_tabx-role   = upl_tab-role.

      upl_tabx-from_dat = upl_tab-from_dat.
      upl_tabx-to_dat   = upl_tab-to_dat.


      SELECT SINGLE * FROM usr02 WHERE
           bname = upl_tab-cpf_no.
      IF sy-subrc NE 0.
        upl_tabx-user_na = 'X'.
      ENDIF.

      SELECT SINGLE * FROM agr_define INTO @DATA(agr) WHERE
         agr_name = @upl_tab-role.
      IF sy-subrc NE 0.
        upl_tabx-role_na = 'X'.
      ENDIF.


      IF upl_tabx-user_na = 'X'.
        DELETE upl_tab.

        CLEAR upl_tabx.
        CONTINUE.
      ELSE .

        SELECT agr_name uname from_dat to_dat INTO CORRESPONDING FIELDS
        OF TABLE l_agr_users FROM agr_users
        WHERE agr_name = upl_tabx-role AND uname = upl_tabx-cpf_no .

        IF sy-subrc  EQ 0 .
          SORT l_agr_users BY to_dat ASCENDING .
          CLEAR l_agr_users .
          LOOP AT l_agr_users .
            IF l_agr_users-from_dat <= upl_tabx-from_dat AND
               l_agr_users-to_dat >= upl_tabx-to_dat .
              xflag = 'X'.
              EXIT.
            ELSE .
              IF l_agr_users-from_dat <= upl_tabx-from_dat AND
                 l_agr_users-to_dat >= upl_tabx-from_dat .
                upl_tab-from_dat = l_agr_users-to_dat .
                MODIFY upl_tab .
              ENDIF .
              IF l_agr_users-from_dat <= upl_tabx-to_dat AND
                 l_agr_users-to_dat >= upl_tabx-to_dat .
                upl_tab-to_dat = l_agr_users-from_dat .
                MODIFY upl_tab .
              ENDIF .
            ENDIF .
          ENDLOOP .
        ENDIF .
**
        CLEAR upl_tabx.
      ENDIF.
      IF xflag = 'X'.
        DELETE upl_tab.
      ENDIF.
      CLEAR upl_tabx.

    ENDLOOP.
  ENDIF.
  LOOP AT upl_tab.
    MOVE-CORRESPONDING upl_tab TO g_role_itab.
    g_role_itab-item_no = zitem_no.
    APPEND g_role_itab.
    zitem_no = zitem_no + 1.
  ENDLOOP.


***************************************************************
***************************************************************

  """""""""""""""""""""""""""
  """"""""for text
  LOOP AT g_role_itab.

    SELECT SINGLE * FROM usr21 INTO @DATA(usr21) WHERE bname = @g_role_itab-cpf_no.
    SELECT NAME_TEXT INTO G_ROLE_ITAB-USER_NAME
 FROM ADRP UP TO 1 ROWS WHERE PERSNUMBER = USR21-PERSNUMBER
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    SELECT TEXT INTO G_ROLE_ITAB-TEXT
 FROM AGR_TEXTS UP TO 1 ROWS WHERE AGR_NAME = G_ROLE_ITAB-ROLE AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
    ELSE.
      DELETE g_role_itab WHERE role = g_role_itab-role.
    ENDIF.
    MODIFY g_role_itab.
  ENDLOOP.
  """""""""""""""""""""""""""""
  """"""""""""""""""""""""

  """"""""""""""""


  IF  g_role_itab[]  IS  NOT INITIAL.
***********************************************************************
    IF zauth_head-auth_req_no IS INITIAL.


      PERFORM get_next_number_asn.

      zauth_head-auth_req_no = zget_number.

    ENDIF.
    MODIFY zauth_head.


    SET PARAMETER ID 'ZROLEREQNO' FIELD zget_number.

******************************************************************

    zauth_item-auth_req_no = zauth_head-auth_req_no.
    zitem_no = 1.
    DELETE FROM zauth_item
       WHERE auth_req_no = zauth_head-auth_req_no.

***************************Added by Abhishek - Delimit existing roles.
    IF it_agr IS NOT INITIAL.

      CLEAR s_itab.
      LOOP AT g_role_itab.
        MOVE-CORRESPONDING g_role_itab TO s_itab.
      ENDLOOP.

      LOOP AT it_agr INTO wa_agr WHERE agr_name NE 'M:COMMON_USER_TOOLS'.
        s_itab-item_no = s_itab-item_no + 1.
        g_role_itab-item_no = s_itab-item_no.
        g_role_itab-cpf_no = s_itab-cpf_no.
        g_role_itab-role = wa_agr-agr_name.
        g_role_itab-text = wa_agr-agr_text.
        g_role_itab-user_name = s_itab-user_name.
        g_role_itab-from_dat = wa_agr-from_dat.
        g_role_itab-to_dat = sy-datum.
        APPEND g_role_itab.
      ENDLOOP.

    ENDIF.
****************************************************End of addition by Abhishek

    LOOP AT g_role_itab.
      IF g_role_itab-cpf_no NE space AND
         g_role_itab-role NE space .

        zauth_item-from_dat = g_role_itab-from_dat .
        zauth_item-to_dat = g_role_itab-to_dat .
************************************************************************
        zauth_item-cpf_no = g_role_itab-cpf_no.
        zauth_item-role = g_role_itab-role.
        zauth_item-item_no = zitem_no.
        zitem_no = zitem_no + 1.
        MODIFY zauth_item.
      ENDIF.
    ENDLOOP.
    zauth_excp-auth_req_no = zauth_head-auth_req_no.

    LOOP AT upl_tabx.
      zauth_excp-cpf_no = upl_tabx-cpf_no.
      zauth_excp-role   = upl_tabx-role.
      zauth_excp-remarks = upl_tabx-remarks.
      zauth_excp-role_na = upl_tabx-role_na.
      zauth_excp-user_na = upl_tabx-user_na.
      MODIFY zauth_excp.
    ENDLOOP.

  ELSE.
    v_message_as = 'X'.
  ENDIF.
************************************************************************
ENDFORM.                    " ROLE_HELP
*&---------------------------------------------------------------------*
*&      Form  GET_NEXT_NUMBER_ASN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_next_number_asn .
  DATA: rc         LIKE inri-returncode.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZROLEREQ'
      quantity    = '1'
*     SUBOBJECT   = ' '
*     TOYEAR      = '0000'
*     IGNORE_BUFFER                 = ' '
    IMPORTING
      number      = zget_number
*     QUANTITY    =
      returncode  = rc
* EXCEPTIONS
*     INTERVAL_NOT_FOUND            = 1
*     NUMBER_RANGE_NOT_INTERN       = 2
*     OBJECT_NOT_FOUND              = 3
*     QUANTITY_IS_0                 = 4
*     QUANTITY_IS_NOT_1             = 5
*     INTERVAL_OVERFLOW             = 6
*     BUFFER_OVERFLOW               = 7
*     OTHERS      = 8
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DELIMIT_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delimit_roles .

  DATA  it_retn TYPE STANDARD TABLE OF bapiret2.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username       = zic_prep_rolereq-userid
      cache_results  = ''
    TABLES
*     PARAMETER      =
*     PROFILES       =
      activitygroups = it_agr
      return         = it_retn.

ENDFORM.
