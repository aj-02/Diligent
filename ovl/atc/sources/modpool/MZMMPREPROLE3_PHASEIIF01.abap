*--- MAIN PROGRAM: MZMMPREPROLE3_PHASEIIF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEF01                                            *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID     Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT  1) Replaced obsolete FM
*                                         "POPUP_TO_CONFIRM_STEP" and
*                                         "WS_DOWNLOAD"
*                                      2) Removed erros for literal
*                                         exceeding more than one line.
* 18/12/2008 <RD1K960611>   SAB_PUNIT  1) Wrong variable was used the
*                                         previous change.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 2156.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/05/2009      <RD1K964305>    SAB_SUMODH
*
*1)Change in Line 3554.
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company              *
*                                           roles during approval)     *
*&                                                                     *
*&                                                                     *
************************************************************************

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
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'BACK'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.
*
*    If l_choice = 'J'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'BACK'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = 'Data will be lost, Want to quit? '
        text_button_1         = 'Yes'(003)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'No'(002)
*       ICON_BUTTON_2         = ' '
*       DEFAULT_BUTTON        = '1'
        display_cancel_button = space
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = l_choice
*     TABLES
*       PARAMETER             =
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    IF l_choice EQ '1'.
* end of <RD1K960036>
*       perform clear_var.
      CLEAR l_choice.
    ENDIF.
  ELSE.
*     perform clear_var.
  ENDIF.

ENDFORM.                    " bac_confirm
*&---------------------------------------------------------------------*
*&      Form  fill_sttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sttab.

  IF   old_ok_code = 'DISPLAY' .
    MOVE 'ROLE_DEL' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
  ENDIF.
  IF   old_ok_code = 'DELETE' .
    MOVE 'ROLE_CR' TO wa_tab-fcode.
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
      mode_zic_prep_rolereq = 'E'
      mandt                 = sy-mandt
      docno                 = zic_prep_rolereq-docno
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
    CLEAR g_lock.
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

    IF <mark_field> = 'X' AND <wa>+90(1) = ''.
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

  IF old_ok_code = 'CREATE'.

    PERFORM gen_no.

  ENDIF.

  PERFORM insert_header.


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


  IF zic_prep_rolereq-useridcr IS INITIAL.

    zic_prep_rolereq-useridcr = sy-uname.
    zic_prep_rolereq-cr_date  = sy-datum.

    IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

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

*****************************
  DATA l_fundc_no LIKE sy-index.
  CLEAR l_fundc_no.
  LOOP AT it_m_fistb INTO wa_m_fistb.
    IF wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      CASE l_fundc_no.
        WHEN 2.
          zic_prep_rolereq-fundc2 = wa_m_fistb-fictr.
        WHEN 3.
          zic_prep_rolereq-fundc3 = wa_m_fistb-fictr.
        WHEN 4.
          zic_prep_rolereq-fundc4 = wa_m_fistb-fictr.
        WHEN 5.
          MESSAGE i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      ENDCASE.
    ENDIF.
  ENDLOOP.
*****************************
  IF zic_prep_rolereq-status <> 'C'.

    zic_prep_rolereq-status = 'IF'.

  ENDIF.

*****
  IF g_fundc_err_flag <> 'X'.

    IF corr_code = 'CORR' AND sy-tcode = 'ZIC_AUTH_CORETEAM'.
      CLEAR : corr_code.
**
      IF g_mult_module_fl = 'X'.
        PERFORM confirm_message.
      ELSE.
        gl_ans = 'J'.
      ENDIF.
      IF gl_ans = 'J'.
        CLEAR gl_ans.
        PERFORM confirm_process.
* begin of <RD1K960036>
* Handled differnt response from obsolete FM and its
* replacement
*      if status_process = 'J'.
        IF status_process = '1'.
* end of <RD1K960036>
          CLEAR status_process.
          status_process_flag = 'X'.
        ELSE.
          IF zic_prep_rolereq-comm_fl = 'X'.
            zic_prep_rolereq-status = 'IR'.
          ELSE.
            PERFORM confirm_status.
* begin of <RD1K960036>
* Handles different responces for obsolete FM
* POPUP_TO_CONFIRM_STEP and its replacement.
*            if status_choice = 'J'.
            IF status_choice = '1'.
* end of <RD1K960036>
              CLEAR status_choice.
              zic_prep_rolereq-status = 'IC'.
            ELSE.
              zic_prep_rolereq-comm_fl = 'X'.
              zic_prep_rolereq-status = 'IR'.
            ENDIF.
          ENDIF.
          PERFORM send_sapmail.
          REFRESH object_content.
          CLEAR corr_code.
        ENDIF.
      ENDIF.
**
    ELSE.
    ENDIF.


*************************************************************

** Module wise check & insertion

    CASE moduleid.

      WHEN 'MM'.

        PERFORM insert_items.

      WHEN 'PM'.

        PERFORM insert_items_pm.

      WHEN 'PS'.

        PERFORM insert_items_ps.

      WHEN 'PP'.

        PERFORM insert_items_pp.

      WHEN 'SD'.

        PERFORM insert_items_sd.

      WHEN 'QM'.

        PERFORM insert_items_qm.

      WHEN 'HSE'.

        PERFORM insert_items_hs.

      WHEN 'OLM'.

        PERFORM insert_items_olm.

        """""""""""
      WHEN 'SRM'.
        PERFORM insert_items_srm.
        """""""""""

    ENDCASE.

    IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

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

*    if status_process_flag = 'X' and ZIC_PREP_ROLEREQ-status <> 'C'.
*          ZIC_PREP_ROLEREQ-status = 'IR'.
*    endif.

    MODIFY zic_prep_rolereq FROM zic_prep_rolereq.

    CLEAR : g_request_close_flag_p, g_request_close_flag_h,
            g_request_close_flag_r.


****Saving the long text.                              *****

    IF ( old_ok_code = 'CREATE' ) OR
       ( old_ok_code = 'CHANGE' ) OR
       ( old_ok_code = 'RELEASE' ) OR
       ( old_ok_code = 'APPROVE' ).

      PERFORM save_cors_text.

    ENDIF.

    IF g_role_flag = 'X'.
      CLEAR g_role_flag.
      PERFORM unlock_record.

    ELSE.

      IF l_old_ok_code = 'X'.
        SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
        LEAVE PROGRAM.
      ELSE.
        PERFORM clear.
        PERFORM unlock_record.
        CALL SCREEN 100.
      ENDIF.

    ENDIF.

  ELSE.

    CLEAR g_fundc_err_flag.
    CALL SCREEN 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    CLEAR okcode_100.

  ENDIF.

ENDFORM.                    " insert_header
*&---------------------------------------------------------------------*
*&      Form  insert_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl110_itab
  BY role_name plant grp  sloc receipt_loc approver.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl110_itab
    COMPARING role_name plant grp  sloc receipt_loc approver rej_fl.

  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

    MOVE-CORRESPONDING g_tablctrl110_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

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

    PERFORM check_items_save.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

  IF g_lines_rl = 0.
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
       AND moduleid = moduleid..

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

**      if sy-subrc = 0.
**** Messages to be checked modulewise in sub
**        perform clear1.
**        if old_ok_code = 'CROSSCO' or
**              ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
**
**              if old_ok_code = 'RELEASE' or
**                  old_ok_code = 'CROSSCO' or
**                  old_ok_code = 'CHANGE'.
**                  perform popup_release_message.
**               endif.
**
**               if old_ok_code = 'APPROVE' or
**                  ZIC_PREP_ROLEREQ-status = 'IF'.
**                  perform popup_approve_message.
**               endif.
**
**               perform pop_up_crossco_message.          .
***          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**
**          else.
**            if old_ok_code = 'CRCROLES' or
**              ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
**               if old_ok_code = 'RELEASE' or
**                  old_ok_code = 'CRCROLES' or
**                  old_ok_code = 'CHANGE'.
**                  perform popup_release_message.
**               endif.
**               if old_ok_code = 'APPROVE' or
**                  ZIC_PREP_ROLEREQ-status = 'IF'.
**                  perform popup_approve_message.
**               endif.
**               perform pop_up_crc_message.
***              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**               g_crc_fl = 'X'.
**            else.
**              if old_ok_code = 'RELEASE'.
**                perform popup_release_message.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif old_ok_code = 'APPROVE'.
**.               perform popup_approve_message.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif old_ok_code = 'CREATE' or old_ok_code =
**'CHANGE'
    .
*.
**                perform popup_release_message1.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              elseif ZIC_PREP_ROLEREQ-status = 'IF'.
**                perform popup_approve_message.
**              else.
**                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
**              endif.
**            endif.
**        endif.
**      endif.

  ENDIF.

ENDFORM.                    " insert_items
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
     old_ok_code = 'APPROVE'.
* begin of <RD1K960036>
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'EXIT'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
**                 DEFAULTOPTION = 'N'
*         IMPORTING
*              ANSWER         = l_choice1.
*
*    If l_choice1 = 'J'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'EXIT'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = 'Data will be lost, Want to quit? '
        text_button_1         = 'Yes'(003)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'No'(002)
*       ICON_BUTTON_2         = ' '
        default_button        = '2'
        display_cancel_button = space
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = l_choice1
*     TABLES
*       PARAMETER             =
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    IF l_choice1 EQ '1'.
* end of <RD1K960036>
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

  CLEAR   : old_ok_code, okcode_100, err_flg.
  REFRESH : g_tablctrl110_itab[].
  CLEAR   : g_tablctrl110_itab.
  REFRESH : g_tablctrl111_itab[].
  CLEAR   : g_tablctrl111_itab.
  CLEAR   : sy-ucomm.
  CLEAR   : g_curr_line.
  CLEAR set_disc_mm_flag.
  CLEAR   : zic_prep_rolerei, zic_prep_rolereq.
  CLEAR   : it_tab.
  REFRESH : tlinetab1[],tlinetab2[].
  CLEAR   : t500p-name1.
  CLEAR   : crc_check_fl.
  CLEAR   : help_list_flag.
  REFRESH : it_m_fistb.
  CLEAR   : moduleid.
  REFRESH : it_module1.
  CLEAR   : status_process_flag.

  """""""""
  REFRESH : g_tablctrl118_itab[].
  CLEAR   : g_tablctrl118_itab.

  """""""""

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
   OR ( old_ok_code = 'RELEASE' )
   OR ( old_ok_code = 'APPROVE' )
  OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-status = 'IR' )
 .

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
   OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-status = 'IR' )
 .
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
** select module
    SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**
    CONCATENATE '**Reply' l_datech sy-uname zauth_user-primary_module
    ' Module' INTO g_cores_sender  SEPARATED BY '    '.
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

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'L1'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'DI'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'CS'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'MD'.

  IF sy-subrc = 0.
    g_user = 'L1'.
    CHECK 1 = 2.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'IM'.

  IF sy-subrc = 0.
    g_user = 'IM'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD : 'L2'.
  IF sy-subrc = 0.
    g_user = 'L3'.
    CHECK 1 = 2.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  IF sy-subrc = 0.
    g_user = 'L3'.
    CHECK 1 = 2.
  ENDIF.

*   g_user_found = 'X'.
*
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

  IF sy-tcode <> 'ZIC_AUTH_CORETEAM'.

    IF old_ok_code <> 'DISPLAY' AND old_ok_code <> 'APPROVE'.

      IF  zic_prep_rolereq-useridcr = sy-uname.
      ELSE.
        MESSAGE e046(zhelp).
      ENDIF.

    ENDIF.

    IF old_ok_code = 'CHANGE' AND zic_prep_rolereq-req_cr_fl = 'X'.
      PERFORM verify.
    ENDIF.

  ELSE.

    IF ( old_ok_code = 'CHANGE' OR old_ok_code = 'DELETE' ) AND
                            ( zic_prep_rolereq-status = 'IC'
                            OR
                              zic_prep_rolereq-status = 'IR' ).

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*         TEXTLINE1 = 'Can''t change / delete this document it is
*with creator'.
          textline1 = 'Can''t change / delete this document it is'
                      & 'with creator'.
* end of <RD1K960036>
      SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
      old_ok_code = 'DISPLAY'.
      CALL SCREEN 100.

    ENDIF.

    IF zic_prep_rolereq-status  = 'C'
       AND old_ok_code <> 'DISPLAY'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*         TEXTLINE1 = 'Request can not be changed Can only be disp
*layed'.
          textline1 = 'Request can not be changed Can only be'
                      & 'displayed'.
* end of <RD1K960036>

      SET PARAMETER ID 'ZOLDCODE' FIELD l_initial.
      old_ok_code = 'DISPLAY'.
*
    ENDIF.


  ENDIF.

  IF old_ok_code = 'APPROVE' AND
                    zic_prep_rolereq-disc_mm_flag = 'X'.
    IF g_user = 'IM' OR g_user = 'L1'.
    ELSE.
      MESSAGE e048(zhelp).
    ENDIF.
  ENDIF.

  IF old_ok_code = 'RELEASE' AND zic_prep_rolereq-req_cr_fl = 'X'.
    MESSAGE e053(zhelp).
  ENDIF.

  IF old_ok_code = 'APPROVE'.

    IF g_user = 'L1' AND zic_prep_rolereq-req_app1_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp).
    ENDIF.

    IF ( g_user = 'IM' ) AND
                          zic_prep_rolereq-req_app0_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp)..
    ENDIF.

    IF ( g_user = 'L3' ) AND
                          zic_prep_rolereq-req_app_fl = ' ' AND
       zic_prep_rolereq-req_cr_fl <> 'X'.
      MESSAGE e051(zhelp)..
    ENDIF.

    IF g_user = 'L1' AND zic_prep_rolereq-req_app1_fl = 'X'.
      MESSAGE e049(zhelp).
    ENDIF.

    IF ( g_user = 'IM' ) AND
                          zic_prep_rolereq-req_app0_fl = 'X'.
      MESSAGE e050(zhelp)..
    ENDIF.

    IF ( g_user = 'L3' ) AND
                          zic_prep_rolereq-req_app_fl = 'X'.
      MESSAGE e050(zhelp)..
    ENDIF.

  ENDIF.

  IF old_ok_code <> 'DISPLAY' AND
       ( zic_prep_rolereq-req_app_fl <> 'X' AND
       zic_prep_rolereq-req_app0_fl <> 'X' AND
       zic_prep_rolereq-req_app1_fl <> 'X' ).
    MESSAGE i080(zhelp).
    g_reset_change = 'X'.
    SET PARAMETER ID 'ZOLDCODE' FIELD ''.
    old_ok_code = 'DISPLAY'.
    PERFORM change_status.
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
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to delete the
*Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.
*
*If l_choice = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Are you sure, you want to '
                              & 'delete the Document?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*    TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF l_choice = '1'.
* end of <RD1K960036>
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
*     SAVEMODE_DIRECT       = ' '
*     TEXTMEMORY_ONLY       = ' '
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
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be
*cancelled? '
*           TITEL          = 'RESET'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
*
*  If l_choice = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'RESET'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Request already released'
                              & ' Flags will be cancelled?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'NO'(002)
*     ICON_BUTTON_2         = ' '
      default_button        = '2'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*      TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF l_choice = '1'.
* end of <RD1K960036>
    CLEAR zic_prep_rolereq-req_cr_fl.
    CLEAR zic_prep_rolereq-req_app_fl.
    CLEAR zic_prep_rolereq-req_app0_fl.
    CLEAR zic_prep_rolereq-req_app1_fl.
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
*&      Form  check_items_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save.
  IF old_ok_code <> 'DISPLAY' .

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.

      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.

        IF zmm_prep_rolecrc-plant = 'X' AND
            wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

        IF zmm_prep_rolecrc-p_grp = 'X' AND
           wa_itemtab-grp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-P_GRP'.
          ROLLBACK WORK.
          MESSAGE i085(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

        IF zmm_prep_rolecrc-app_level = 'X' AND
          wa_itemtab-approver IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          ROLLBACK WORK.
          MESSAGE i096(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.

      ENDIF.

    ELSE.

      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                                                  wa_itemtab-role_name.
      IF sy-subrc = 0.

        IF zmm_prep_roledes-plant = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-plant IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            ROLLBACK WORK.
            MESSAGE i084(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-p_grp = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE'  OR
                      old_ok_code = 'CREATE'  OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-grp IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-GRP'.
            ROLLBACK WORK.
            MESSAGE i085(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-s_loc = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-sloc IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            ROLLBACK WORK.
            MESSAGE i090(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-r_loc = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-receipt_loc IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
            ROLLBACK WORK.
            MESSAGE i095(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

        IF zmm_prep_roledes-app_level = 'X' AND
                       ( old_ok_code = 'APPROVE' OR
                      old_ok_code = 'RELEASE' OR
                      old_ok_code = 'CHANGE' OR
                      old_ok_code = 'CREATE' OR
                      old_ok_code = 'CROSSCO' ) AND
                      NOT wa_itemtab-role_name IS INITIAL.

          IF wa_itemtab-approver IS INITIAL.
            g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
            ROLLBACK WORK.
            MESSAGE i096(zhelp) WITH g_i.
            CLEAR okcode_100.
            CALL SCREEN 100.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.
**  if wa_itemtab-rej_fl is initial.
**** Header level changes for integration
**    perform validate_role_approval_level.
**  endif.
** Line item changes for integration call diffrent subs ( def 110 )
*Begin of <RD1K963151>.
  IF old_ok_code = 'CHANGE' AND sy-ucomm NE 'REQ1'.
*End of <RD1K963151>.
    PERFORM validate_lineitem_datax.
*Begin of <RD1K963151>.
  ENDIF.
*End of <RD1K963151>.
ENDFORM.                    " check_items_save
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

* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'If u cancel release, u can change data
*else go in display mode'
*               TEXTLINE2      = '& just do correspondence without
*cancelling release'
*           TITEL          = 'Do you want to cancel release?'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
*  If l_choice = 'J'.
  DATA l_question TYPE string.

  MOVE 'If u cancel release, u can change data else go in'
       & ' display mode & just do correspondence '
       & ' without cancelling release'
       TO l_question.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Do you want to cancel release?'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = l_question
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
      default_button        = '2'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = l_choice
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF l_choice EQ '1'.
* end of <RD1K960036>

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
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC

***START OF COMMENT <RD1K983325>   CR: 30007580  dt: 05.04.2013.
*      g_ccode = ist_data-bukrs.
***end OF COMMENT <RD1K983325>.

**code added by CAB_AMITMOZA  <RD1K983325>   CR: 30007580  dt: 05.04.2013.
      g_ccode =  zic_prep_rolereq-ccode.
**code end by CAB_AMITMOZA  <RD1K983325>

    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl110_itab INTO g_tablctrl110_wa.

    IF old_ok_code = 'CRCROLES' OR zic_prep_rolereq-crc_fl = 'X'.

      SELECT SINGLE * FROM zmm_prep_rolecrc WHERE role_type =
                      g_tablctrl110_wa-role_name.

      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE e117(zhelp).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM zmm_prep_roledes WHERE role_type =
                      g_tablctrl110_wa-role_name.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE e118(zhelp).
      ENDIF.

    ENDIF.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF old_ok_code = 'CRCROLES'.

      ELSE.

        IF zmm_prep_roledes-mm_disc_flag = 'X'.

          IF zic_prep_rolereq-disc_mm_flag = 'X'.
          ELSE.
            ROLLBACK WORK.
            MESSAGE e081(zhelp) WITH g_tablctrl110_wa-role_name.
          ENDIF.

        ENDIF.

      ENDIF.

*  endif.

      IF NOT g_tablctrl110_wa-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs = zic_prep_rolereq-ccode
                                      AND werks = g_tablctrl110_wa-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl110_wa-role_name.

        ENDIF.

      ENDIF.


************finding group*******************

      REFRESH : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
*  clear   : wa_t024.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.
*
*
* if  g_TABLCTRL110_wa-role_name = 'M6' or
*     g_TABLCTRL110_wa-role_name = 'M7' or
*     g_TABLCTRL110_wa-role_name = 'M8'.
*
* else.
*
*      if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*            loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) between '0' and 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*
*      else.
*
*          loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) < '0'  or
*              l_ekgrp+1(1) > 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*      endif.
*
* endif.
*
**
      IF g_tablctrl110_wa-role_name = 'M6' OR
          g_tablctrl110_wa-role_name = 'M7' OR
          g_tablctrl110_wa-role_name = 'M8'.
        CONCATENATE '%' g_ccode '%' INTO g_line1.
        SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
      ELSE.
        IF zic_prep_rolereq-disc_mm_flag <> 'X'.
          CONCATENATE '%' g_ccode '%' 'IND' '%'
          INTO g_line1.
          SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
        ELSE.
          CONCATENATE  '%' g_ccode '%' 'MM' '%'
          INTO g_line1.
          SELECT * FROM t024 INTO TABLE it_t024 WHERE telfx LIKE g_line1.
        ENDIF.
      ENDIF.
**
      IF  NOT g_tablctrl110_wa-grp IS INITIAL.

        LOOP AT it_t024 INTO wa_t024.

          IF g_tablctrl110_wa-grp = wa_t024-ekgrp.
            grp_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF grp_flag = 'X'.
          CLEAR grp_flag.
        ELSE.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          ROLLBACK WORK.
          MESSAGE i069(zhelp).
          CALL SCREEN 100.

        ENDIF.

      ENDIF.

***************************

      CLEAR : l_zarea, wa_t001l.
      REFRESH it_t001l.

      IF ( g_tablctrl110_wa-role_name = 'M13' OR
         g_tablctrl110_wa-role_name = 'M14' OR
          g_tablctrl110_wa-role_name = 'M16' OR
          g_tablctrl110_wa-role_name = 'M18' OR
          g_tablctrl110_wa-role_name = 'M19' ) AND
          NOT g_tablctrl110_wa-plant IS INITIAL.

        SELECT * FROM t001l INTO CORRESPONDING FIELDS OF
                     TABLE it_t001l  WHERE werks = g_tablctrl110_wa-plant.

        IF  sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e074(zhelp).

        ENDIF.

      ENDIF.

      IF zic_prep_rolereq-disc_mm_flag = 'X'.

        LOOP AT it_t001l INTO wa_t001l.

          SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

          IF sy-subrc = 0.

            IF l_zarea+0(1) <> 'M'.
              DELETE it_t001l.
            ENDIF.

          ELSE.

            DELETE it_t001l.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT it_t001l INTO wa_t001l.

          SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

          IF sy-subrc = 0.

            IF l_zarea+0(1) = 'M'.
              DELETE it_t001l.
            ENDIF.

          ELSE.

            DELETE it_t001l.

          ENDIF.

        ENDLOOP.

      ENDIF.

      IF  NOT g_tablctrl110_wa-sloc IS INITIAL.

        LOOP AT it_t001l INTO wa_t001l.

          IF g_tablctrl110_wa-sloc = wa_t001l-lgort.
            loc_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF loc_flag = 'X'.
          CLEAR loc_flag.
        ELSE.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          ROLLBACK WORK.
          MESSAGE e073(zhelp).

        ENDIF.

      ENDIF.


***************************

      CLEAR wa_recpt.
      REFRESH it_recpt.

      IF ( g_tablctrl110_wa-role_name = 'M12' OR
         g_tablctrl110_wa-role_name = 'M17' ) AND
         NOT g_tablctrl110_wa-receipt_loc IS INITIAL.

        SELECT * FROM zmm_location INTO TABLE it_recpt.

        IF g_tablctrl110_wa-role_name = 'M12'.

          LOOP AT it_recpt INTO wa_recpt.

            IF wa_recpt-loccg <> 'RL'.
              DELETE it_recpt.
            ENDIF.

          ENDLOOP.

        ENDIF.


        IF g_tablctrl110_wa-role_name = 'M17'.

          LOOP AT it_recpt INTO wa_recpt.

            IF wa_recpt-loccg <> 'CF'.
              DELETE it_recpt.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

      IF  NOT g_tablctrl110_wa-receipt_loc IS INITIAL.

        LOOP AT it_recpt INTO wa_recpt.

          IF g_tablctrl110_wa-receipt_loc = wa_recpt-loccd.
            loc_flag = 'X'.
          ENDIF.

        ENDLOOP.

        IF loc_flag = 'X'.
          CLEAR loc_flag.
        ELSE.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE e075(zhelp).

        ENDIF.

      ENDIF.


*****************************

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax
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
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'It is understood that user has joined at new
*location & HR Data'
*     TEXTLINE2 = 'is updated. Please choose appropriate current
*location?'
      textline1 = 'It is understood that user has joined' &
                  ' at new location & HR Data'
      textline2 = 'is updated. Please choose appropriate' &
                  ' current location?'
* end of <RD1K960036>
*     START_COLUMN       = 25
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
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF old_ok_code = 'APPROVE'.
        .               PERFORM popup_approve_message.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF old_ok_code = 'CREATE' OR old_ok_code =
'CHANGE'.
        PERFORM popup_release_message1.
        MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
      ELSEIF zic_prep_rolereq-status = 'IF'.
        PERFORM popup_approve_message.
      ELSE.
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
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please attach the scanned order copy with the
*request or '
      textline1 = 'Please attach the scanned order copy with' &
                  ' the request or '
* end of <RD1K960036>
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN       = 25
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
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please attach the scanned order copy with the
*request or '
      textline1 = 'Please attach the scanned order copy' &
                  ' with the request or '
* end of <RD1K960036>
      textline2 = 'Please send order copy by fax to Head-ICE '
*     START_COLUMN       = 25
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

  SELECT SINGLE * FROM zmm_prep_rolegrp
       WHERE role_type = wa_itemtab-role_name.

  IF sy-subrc = 0.

    IF zmm_prep_rolegrp-approver1 = 'L3' AND
                 g_approver_level = 'L3'.

    ELSEIF zmm_prep_rolegrp-approver1 = 'IM' AND
                 g_approver_level = 'L3'.
      g_approver_level = 'IM'.
    ELSEIF  zmm_prep_rolegrp-approver1 = 'L1' AND
                 ( g_approver_level = 'L3' OR
                   g_approver_level = 'IM' ).
      g_approver_level = 'L1'.
    ENDIF.

  ENDIF.

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
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE2 = 'Request for authorization will be routed to
*ICE core team only '
      textline2 = 'Request for authorization will be' &
                  ' routed to ICE core team only '
* end of <RD1K960036>
      textline3 = 'after requisite approval '
*     START_COLUMN       = 15
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
      textline1 = g_approve_text
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE2 = 'The request will now be processed by ICE core
* team & '
*     TEXTLINE3 = 'user will get updated message once the
*request is processed '
      textline2 = 'The request will now be processed by'
                  & ' ICE core team & '
      textline3 = 'user will get updated message once' &
                  ' the request is processed '
* end of <RD1K960036>
*     START_COLUMN       = 15
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
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Request Status IR'
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Please go to display mode & reply the query
*of the ICE core team in '
*     TEXTLINE2 = 'correspondence  &  save the request.  No re-
*release or approval reqd.'
*     TEXTLINE3 = 'The request will go directly to ICE core team
* for further processing.'.
      textline1 = 'Please go to display mode & reply the' &
                  ' query of the ICE core team in '
      textline2 = 'correspondence  &  save the request.  No' &
                  ' re-release or approval reqd.'
      textline3 = 'The request will go directly to ICE core' &
                  ' team for further processing.'.
* end of <RD1K960036>

  old_ok_code = 'DISPLAY'.
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

* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*  concatenate g_approver_level ' or above. Request  for  authorization
*will be routed to ICE core' into g_approve_text.
  CONCATENATE g_approver_level
             ' or above. Request  for  authorization will be'
             ' routed to ICE core'
    INTO g_approve_text
    SEPARATED BY space.
* end of <RD1K960036>
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
    EXPORTING
      titel     = 'Approval Requirement'
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     TEXTLINE1 = 'Kindly self release the  request  &  get it
*approved by competent authority:'
      textline1 = 'Kindly self release the  request  &' &
                  ' get it approved by competent authority:'
* end of <RD1K960036>
      textline2 = g_approve_text
      textline3 = 'team only after requisite approval '
*     START_COLUMN       = 15
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
*&      Form  insert_items_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pm.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl111_itab
  BY role_name plant shop_no.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl111_itab
    COMPARING role_name plant rej_fl shop_no.

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

    MOVE-CORRESPONDING g_tablctrl111_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

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
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
        AND moduleid = moduleid.

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

  ENDIF.

ENDFORM.                    " insert_items_pm
***&--------------------------------------------------------------------
*-
***
***&      Form  check_items_save_pm
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
FORM check_items_save_pm.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpm_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zpm_prep_roledes-plant = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zpm_prep_roledes-shop_no = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-shop_no IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          ROLLBACK WORK.
          MESSAGE i095(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF ( zic_prep_rolereq-ccode <> 'BDW' AND
         zic_prep_rolereq-ccode <> 'SBW' ).

        IF  ( zpm_prep_roledes-role_type = 'PM14' OR
            zpm_prep_roledes-role_type = 'PM15' OR
            zpm_prep_roledes-role_type = 'PM16' ).
          MESSAGE e164(zhelp) WITH zic_prep_rolerei-role_name
          zic_prep_rolereq-ccode .
        ENDIF.
      ENDIF.

      IF wa_itemtab-role_name = 'PM8'.
        IF wa_itemtab-plant CS 'E1' OR
            wa_itemtab-plant CS 'E2' OR
            wa_itemtab-plant CS 'C1'.
        ELSE.
          MESSAGE e202(zhelp) WITH wa_itemtab-plant
          zpm_prep_roledes-role_type.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax11.

ENDFORM.                    " check_items_save_pm
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

    WHEN 'MM'.

      PERFORM check_items_save.

    WHEN 'PM'.

      PERFORM check_items_save_pm.

    WHEN 'PS'.

      PERFORM check_items_save_ps.

    WHEN 'PP'.

      PERFORM check_items_save_pp.

    WHEN 'SD'.

      PERFORM check_items_save_sd.

    WHEN 'QM'.

      PERFORM check_items_save_qm.

    WHEN 'HSE'.

      PERFORM check_items_save_hs.

    WHEN 'OLM'.

      PERFORM check_items_save_olm.

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

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl111_itab INTO g_tablctrl111_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT g_tablctrl111_wa-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs = zic_prep_rolereq-ccode
                                      AND werks = g_tablctrl111_wa-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl111_wa-role_name.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax11
*&---------------------------------------------------------------------*
*&      Form  check_list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_list_processing.
  IF g_list_proc_flag = 'X'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " check_list_processing
*&---------------------------------------------------------------------*
*&      Form  upload1_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload1_file.
  SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE it_roles.
  SELECT * FROM zhelp_pmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_pm.
  SELECT * FROM zhelp_psroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_ps.
  SELECT * FROM zhelp_pproles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_pp.
  SELECT * FROM zhelp_pproles1 INTO CORRESPONDING FIELDS OF TABLE
  it_roles1_pp.
  SELECT * FROM zhelp_sdroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_sd.
  SELECT * FROM zhelp_qmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_qm.
  SELECT * FROM zhelp_hsroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_hs.
  SELECT * FROM zhelp_olmroles INTO CORRESPONDING FIELDS OF TABLE
  it_roles_olm.

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
  READ TABLE it_module1 INTO wa_module1 INDEX 1.
  SELECT * FROM ZAUTH_USER UP TO 1 ROWS
 WHERE
 BNAME = SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF wa_module1-moduleid = 'PS'.
    moduleid = wa_module1-moduleid.
  ELSE.
    moduleid = zauth_user-primary_module.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
   moduleid = wa_module1-moduleid.
  ENDIF.


  IF moduleid = 'MM'.

    SELECT SINGLE * FROM zmm_prep_usrcont WHERE
                bname = sy-uname.
    IF sy-subrc <> 0.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ELSE.
      PERFORM auth_check1.
*   old_ok_code = 'CHANGE'.
    ENDIF.
***
  ELSE.
    IF zauth_user-approve_flag <> 'X'.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ENDIF.
***
  ENDIF.

ENDFORM.                    " auth_check
*&---------------------------------------------------------------------*
*&      Form  auth_check1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check1.
  IF zic_prep_rolereq-crc_fl = 'X' AND
     zmm_prep_usrcont-crc_app = 'X'.
*     old_ok_code = 'CHANGE'.
  ELSEIF
     zic_prep_rolereq-crossco_fl = 'X' AND
     zmm_prep_usrcont-crossco_app = 'X'.
*     old_ok_code = 'CHANGE'.
  ELSE.
    IF  zmm_prep_usrcont-gen_app = 'X' AND
        zic_prep_rolereq-crc_fl <> 'X' AND
          zic_prep_rolereq-crossco_fl <> 'X' .
*         old_ok_code = 'CHANGE'.
    ELSE.
      MESSAGE i104(zhelp).
      old_ok_code = 'DISPLAY'.
    ENDIF.
  ENDIF.

ENDFORM.                    " auth_check1
*&---------------------------------------------------------------------*
*&      Form  change_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_status.

  PERFORM fill_sttab.

  IF old_ok_code = 'CREATE' OR old_ok_code = 'CHANGE' OR
      old_ok_code = 'DISPLAY' OR old_ok_code = 'DELETE'.

    SET PF-STATUS 'OPTNS1' EXCLUDING it_tab.

  ELSE.

    SET PF-STATUS 'OPTNS'.

  ENDIF.

  CASE sy-ucomm.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
    WHEN 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Change Request'.
    WHEN 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Display Request'.
    WHEN 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Delete Request'.
    WHEN 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Release Request'.

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.

ENDFORM.                    " change_status
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

  LOOP AT it_roles INTO wa_roles.

    PERFORM check_mum.
    APPEND wa_roles TO it_roles0.

  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles.

    IF NOT wa_roles-role_type IS INITIAL.

      LOOP AT g_tablctrl110_itab INTO wa_rolesz.
        IF wa_roles-role_type = wa_rolesz-role_name AND
                                wa_rolesz-rej_fl = '' AND
                                wa_rolesz-status = '' AND
                                wa_rolesz-role_request = ''.
          PERFORM insert_data.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT g_tablctrl110_itab INTO wa_rolesz.
*Begin of <RD1K964305>.
*    IF WA_ROLESZ-ROLE_NAME+0(1) = 'C' AND
*    IF ( wa_rolesz-role_name+0(1) = 'C' OR wa_rolesz-role_name+0(1) = 'N' )  AND
*End of <RD1K964305>.
                    if   wa_rolesz-rej_fl = '' AND
                         wa_rolesz-status = '' AND
                         wa_rolesz-role_request = ''.
      PERFORM insert_data_addl.
    ENDIF.
  ENDLOOP.

  SORT it_roles1.

**** Deleting tempelate as it gets added in logic

  LOOP AT it_roles1 INTO wa_role_del_data.

    IF wa_role_del_data-role_name = 'D:MM_SRV_IND_APPROVE_XX'
     OR wa_role_del_data-role_name = 'D:MM_PUR_PO_APPROVE_XX'.
      DELETE it_roles1.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles
*&---------------------------------------------------------------------*
*&      Form  confirm_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_mail.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            TEXTLINE1 = text-008
*            TITEL     = text-009
*       IMPORTING
*            ANSWER    = g_ans_mail.

*  If g_ans_mail = 'J'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-009
*     DIAGNOSE_OBJECT             = ' '
      text_question  = text-008
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = g_ans_mail
*    TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF g_ans_mail EQ '1'.
* end of <RD1K960036>
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
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.
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

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
zic_prep_rolereq-userid INTO  object_content-line
SEPARATED BY space.
  APPEND object_content.

  MOVE space TO object_content-line.
  APPEND object_content.
  IF zic_prep_rolereq-status = 'C'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please  check  your role request  which  has  been
*assigned  &  completed - ' zic_prep_rolereq-docno into
    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' zic_prep_rolereq-docno INTO
* end of <RD1K960036>
object_content-line
SEPARATED BY space.
    APPEND object_content.
  ELSE.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      concatenate 'Please check your role request which has been updated
* - ' zic_prep_rolereq-docno into  object_content-line
    CONCATENATE 'Please check your role request which has been' &
     ' updated - ' zic_prep_rolereq-docno INTO  object_content-line
* end of <RD1K960036>
SEPARATED BY space.
    APPEND object_content.
  ENDIF.
********************************************************************
  IF zic_prep_rolereq-status = 'IC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through correspondence in the request. The request
* needs to be changed, re-released & re-approved by competent authority.
*Once the request is approved, the request will flow to ICE core team.'
    MOVE 'Please go through correspondence in the request. The' &
         ' request needs to be changed, re-released & re-approved' &
         ' by competent authority. Once the request is approved, the' &
         ' request will flow to ICE core team.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'IR'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Please go through the correspondence in the request & reply
*to the query raised by ICE core team. You need to save the request after
* giving reply in correspondence(In display mode only). Once the request
*is saved, the request will flow to ICE core team.'
    MOVE 'Please go through the correspondence in the request &' &
         ' reply to the query raised by ICE core team. You need to' &
         ' save the request after giving reply in correspondence' &
         '(In display mode only). Once the request is saved, the' &
         ' request will flow to ICE core team.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*     Move 'No re-release or approvals are required in this case & user
*will not be able to open the request in change mode.'
    MOVE 'No re-release or approvals are required in this case &' &
         ' user will not be able to open the request in change mode.'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
  ENDIF.
  IF zic_prep_rolereq-status = 'PC'.
* begin of <RD1K960036>
* Literal exceeding more then one line is not allowed
*      Move 'Your request is still under process with ICE core team. Only
* partial roles have been assigned. You will get the next message'
    MOVE 'Your request is still under process with ICE core team.' &
         ' Only partial roles have been assigned. You will get the' &
         ' next message'
* end of <RD1K960036>
TO object_content-line.
    APPEND object_content.
    MOVE 'for completion or return of request soon.' TO
object_content-line.
    APPEND object_content.
  ENDIF.
********************************************************************
  MOVE space TO object_content-line.
  APPEND object_content.

  object_content-line = 'ICE Core Team'.
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
*&      Form  hide
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hide.

  MOVE 'REQ1' TO wa_tab.
  APPEND wa_tab TO tab.

ENDFORM.                    " hide
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
* begin of <RD1K960036>
* FM 'WS_DOWNLOAD' is obsolete
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**     BIN_FILESIZE                  = ' '
**     CODEPAGE                      = ' '
*       FILENAME                      = 'C:\role_upload.txt'
*       FILETYPE                      = 'DAT'
**     MODE                          = ' '
**     WK1_N_FORMAT                  = ' '
**     WK1_N_SIZE                    = ' '
**     WK1_T_FORMAT                  = ' '
**     WK1_T_SIZE                    = ' '
**     COL_SELECT                    = ' '
**     COL_SELECTMASK                = ' '
**     NO_AUTH_CHECK                 = ' '
**   IMPORTING
**     FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = it_role_del_data
**     FIELDNAMES                    =
*     EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       NO_BATCH                      = 5
*       UNKNOWN_ERROR                 = 6
*       INVALID_TABLE_WIDTH           = 7
*       GUI_REFUSE_FILETRANSFER       = 8
*       CUSTOMER_ERROR                = 9
*       OTHERS                        = 10
*              .

    DATA l_file TYPE string VALUE 'C:\role_upload.txt'.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = l_file
        filetype                = 'DAT'
*       APPEND                  = ' '
*       WRITE_FIELD_SEPARATOR   = ' '
*       HEADER                  = '00'
*       TRUNC_TRAILING_BLANKS   = ' '
*       WRITE_LF                = 'X'
*       COL_SELECT              = ' '
*       COL_SELECT_MASK         = ' '
*       DAT_MODE                = ' '
*       CONFIRM_OVERWRITE       = ' '
*       NO_AUTH_CHECK           = ' '
*       CODEPAGE                = ' '
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
*       WRITE_BOM               = ' '
*       TRUNC_TRAILING_BLANKS_EOL       = 'X'
*       WK1_N_FORMAT            = ' '
*       WK1_N_SIZE              = ' '
*       WK1_T_FORMAT            = ' '
*       WK1_T_SIZE              = ' '
*       WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*       SHOW_TRANSFER_STATUS    = ABAP_TRUE
*   IMPORTING
*       FILELENGTH              =
      TABLES
        data_tab                = it_role_del_data
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
* end of <RD1K960036>
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.

    CLEAR disp_flag.
    MESSAGE i059(zhelp).
    CLEAR old_ok_code.

  ENDIF.

ENDFORM.                    " help_suim
*&---------------------------------------------------------------------*
*&      Form  check_mum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_mum.

*     To be checked with Mehta & MVS Sharma ???
  IF zic_prep_rolereq-ccode = 'MUM'.
    SEARCH wa_roles-role_name FOR 'D:FM_LOGS_FFFFFFFF'.
    IF sy-subrc = 0.
      wa_roles-role_name = 'FM_LOGS_FFFFFFFF'.
    ENDIF.
    SEARCH wa_roles-role_name FOR 'FI_AP_LOGS_DISP_CCC'.
    IF sy-subrc = 0.
      wa_roles-role_name = 'FI_AP_LOGS_DISP_CCC_AL'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_mum
*&---------------------------------------------------------------------*
*&      Form  insert_data_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_pm.

  SEARCH wa_roles_pm-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_pm-role_name.
    REPLACE 'YYY' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'XXXX' WITH wa_rolesz_pm-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_pm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

*
ENDFORM.                    " insert_data_pm
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
* begin of <RD1K960036>
* Replaced obsolete FM 'WS_DOWNLOAD'
*    CALL FUNCTION 'WS_DOWNLOAD'
*         EXPORTING
*              filename                = p1_file
*              filetype                = 'DAT'
*         TABLES
*              data_tab                = it_roles1
*         EXCEPTIONS
*              file_open_error         = 1
*              file_write_error        = 2
*              invalid_filesize        = 3
*              invalid_type            = 4
*              no_batch                = 5
*              unknown_error           = 6
*              invalid_table_width     = 7
*              gui_refuse_filetransfer = 8
*              customer_error          = 9
*              OTHERS                  = 10.

    DATA l_file TYPE string.

    l_file = p1_file.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE            =
        filename                = l_file
        filetype                = 'DAT'
*       APPEND                  = ' '
*       WRITE_FIELD_SEPARATOR   = ' '
*       HEADER                  = '00'
*       TRUNC_TRAILING_BLANKS   = ' '
*       WRITE_LF                = 'X'
*       COL_SELECT              = ' '
*       COL_SELECT_MASK         = ' '
*       DAT_MODE                = ' '
*       CONFIRM_OVERWRITE       = ' '
*       NO_AUTH_CHECK           = ' '
*       CODEPAGE                = ' '
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
*       WRITE_BOM               = ' '
*       TRUNC_TRAILING_BLANKS_EOL       = 'X'
*       WK1_N_FORMAT            = ' '
*       WK1_N_SIZE              = ' '
*       WK1_T_FORMAT            = ' '
*       WK1_T_SIZE              = ' '
*       WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*       SHOW_TRANSFER_STATUS    = ABAP_TRUE
*     IMPORTING
*       FILELENGTH              =
      TABLES
        data_tab                = it_roles1
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
* end of <RD1K960036>
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
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.
* begin of <RD1K960036>
* Replaced obsolete FM 'POPUP_TO_CONFIRM_STEP'
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'Y'
*            TEXTLINE1     = 'Role request being created'
*            TEXTLINE2     = 'Continue ??? '
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      text_question  = 'Role request being created' &
                       'Continue ??? '
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = gl_ans
*    TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF gl_ans EQ '1'.
    CLEAR gl_ans.
    MOVE 'J' TO gl_ans.
  ELSEIF gl_ans EQ '2'.
    CLEAR gl_ans.
    MOVE 'N' TO gl_ans.
  ELSE.
    CLEAR gl_ans.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_step
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

  READ TABLE it_roles1 INTO wa_roles1 INDEX 1.
  g_userid = wa_roles1-userid.
  l_color = 5.
  LOOP AT it_roles1 INTO wa_roles1.
    IF g_userid = wa_roles1-userid.
      WRITE : / wa_roles1-userid COLOR 1,wa_roles1-role_name COLOR 2.
    ELSE.
      WRITE : / wa_roles1-userid COLOR 3,wa_roles1-role_name COLOR 3.
    ENDIF.
    g_userid = wa_roles1-userid.
  ENDLOOP.

ENDFORM.                    " write_list
*&---------------------------------------------------------------------*
*&      Form  create_roles_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_pm.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_pm INTO wa_roles_pm.
    APPEND wa_roles_pm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_pm.

    IF NOT wa_roles_pm-role_type IS INITIAL.

      LOOP AT g_tablctrl111_itab INTO wa_rolesz_pm.
        IF wa_roles_pm-role_type = wa_rolesz_pm-role_name AND
                                wa_rolesz_pm-rej_fl = '' AND
                                wa_rolesz_pm-status = '' AND
                                wa_rolesz_pm-role_request = ''.
          PERFORM insert_data_pm.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

*  perform display_role_pm.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles_pm
*&---------------------------------------------------------------------*
*&      Form  insert_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data.

  SEARCH wa_roles-role_name FOR 'INPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'INPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'SSPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
    REPLACE 'SSPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  SEARCH wa_roles-role_name FOR 'PLANT'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    IF wa_roles-role_type = 'M15' OR wa_roles-role_type = 'M20'.
      wa_roles1-role_name = 'MM_INV_CCC_PLANT_PPPP'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
      REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.

      APPEND wa_roles1 TO it_roles1.
    ELSE.
*End of <RD1K963151>.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
      REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.

    ENDIF.
  ENDIF.
  SEARCH wa_roles-role_name FOR 'POPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    REPLACE 'POPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

*
  SEARCH wa_roles-role_name FOR 'IGG'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    DATA : l_bukrs1 TYPE bukrs.
    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
               a~persk a~sbmod  c~designo c~r_p_cd c~version
             d~sdesig_text AS designation d~adesig_text AS adesignation
             d~disc_cd AS disc_cd
               INTO CORRESPONDING FIELDS OF TABLE ist_data1
          FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      l_bukrs1 = ist_data1-bukrs.
    ENDIF.


*End of <RD1K963151>.
*Begin  of <RD1K963151>.
    """""""""""""""""""
    "added by lipsy on 9.03.2015 for cross-company RD1K996555
    IF  zic_prep_rolerei-moduleid = 'MM'.
      IF old_ok_code = 'APPROVE' AND   zic_prep_rolereq-crossco_fl = 'X' .
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                        wa_roles1-role_name.
      ELSE.
        "end of addition by lipsy on 9.03.2015  for cross-company RD1K996555

        """"""""""""""""""""

        REPLACE 'CCC' WITH l_bukrs1+0(3) INTO wa_roles1-role_name.
*    REPLACE 'CCC' WITH ZIC_PREP_ROLEREQ-CCODE+0(3) INTO
*                                  WA_ROLES1-ROLE_NAME.
*End of <RD1K963151>.

        """""""""""""""""""""""""""""""
        "added  by lipsy on 9.03.2015 for cross-company RD1K996555
      ENDIF.
    ENDIF.
    "end of addition  by lipsy on 9.03.2015 for cross-company RD1K996555
    """""""""""""""""""""""

    REPLACE 'IGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

*
  SEARCH wa_roles-role_name FOR 'SGG'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                        wa_roles1-role_name.
    REPLACE 'SGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'PGG'.
  IF sy-subrc = 0.

    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    DATA : l_bukrs TYPE bukrs.
    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
               a~persk a~sbmod  c~designo c~r_p_cd c~version
             d~sdesig_text AS designation d~adesig_text AS adesignation
             d~disc_cd AS disc_cd
               INTO CORRESPONDING FIELDS OF TABLE ist_data
          FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      l_bukrs = ist_data-bukrs.
    ENDIF.
***CODE ADDED BY CAB_AMITMOZA <RD1K983325>   CR: 30007580  dt: 05.04.2013.
    IF zic_prep_rolereq-crossco_fl = 'X'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
    ELSE.
**CODE END BY CAB_AMITMOZA <RD1K983325>
*End of <RD1K963151>.
*Begin  of <RD1K963151>.
*     REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
*                                    wa_roles1-role_name.
      REPLACE 'CCC' WITH l_bukrs+0(3) INTO wa_roles1-role_name.
*End of <RD1K963151>.
    ENDIF.
    REPLACE 'PGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  SEARCH wa_roles-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    wa_roles1-userid = zic_prep_rolereq-userid.
    IF flag <> 'X'.
      wa_roles1-role_name = wa_roles-role_name.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                    wa_roles1-role_name.
*      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
    flag = 'X'.
    IF wa_roles-role_type = 'M12' OR wa_roles-role_type = 'M17'.
      REPLACE 'RR' WITH wa_rolesz-receipt_loc+0(2) INTO
                                              wa_roles1-role_name.


    ENDIF.

    APPEND wa_roles1 TO it_roles1.

    SELECT SINGLE * FROM zhelp_mmroles_rc WHERE
                        receipt_loc = wa_rolesz-receipt_loc AND
                        ccode = zic_prep_rolereq-ccode.
    IF sy-subrc = 0.
      wa_roles1-role_name = zhelp_mmroles_rc-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.



  ENDIF.

  SEARCH wa_roles-role_name FOR 'FM_LOGS'.
  IF sy-subrc = 0.
    flag = 'X'.
*BEGIN OF  <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = 'D:FM_LOGS_OVL_ALL'.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
*END OF <RD1K963151>.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles-role_name.
      IF zic_prep_rolereq-fundc1 <> '' AND
            zic_prep_rolereq-fundc_fl = 'X'.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc1 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc2 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc2 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc3 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc3 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      IF zic_prep_rolereq-fundc4 <> ''.
        wa_roles1-role_name = wa_roles-role_name.
        REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc4 INTO
                           wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

    ENDIF.
  ENDIF.
  SEARCH wa_roles-role_name FOR 'MM_SRV_SES_ACCEPT'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'YY' WITH wa_rolesz-approver INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.
*
  SEARCH wa_roles-role_name FOR 'MM_PUR_PO_APPROVE_ZZ'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
    REPLACE 'ZZ' WITH wa_rolesz-approver INTO wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles-role_name.
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'  AND wa_roles1-role_name = 'D:MM_DISPLAY_ALL'.
      wa_roles1-role_name = 'D:MM_OVL_DISPLAY_ALL'.
    ELSEIF zic_prep_rolereq-ccode = 'OVL'  AND wa_roles1-role_name = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
      wa_roles1-role_name = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
    ENDIF.
*End of <RD1K963151>.
    APPEND wa_roles1 TO it_roles1.

  ENDIF.

  CLEAR flag.

  IF wa_roles-role_type = 'M13'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.

**code added by CAB_AMITMOZA  RD1K983325   CR:30007580
      SELECT * FROM zmm_prep_role_sl WHERE
                werks = wa_rolesz-plant AND
                lgort = wa_rolesz-sloc.
**code end RD1K983325

***comment start by CAB_AMITMOZA  RD1K983325   CR:30007580
*      SELECT SINGLE * FROM zmm_prep_role_sl WHERE
*                werks = wa_rolesz-plant AND
*                lgort = wa_rolesz-sloc.
***comment end RD1K983325

        wa_roles1-role_name = zmm_prep_role_sl-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDSELECT.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M14'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      wa_roles1-role_name = zmm_prep_role_sl-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M16'.
    IF flag1 <> 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      wa_roles1-role_name = zmm_prep_role_sl-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M11S' OR
     wa_roles-role_type = 'M11M' OR
     wa_roles-role_type = 'M3'   OR
     wa_roles-role_type = 'M3A'  OR
     wa_roles-role_type = 'M3B'  .

    SEARCH wa_roles-role_name FOR 'XX'.
    IF sy-subrc = 0.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles-role_name.
      REPLACE 'XX' WITH wa_rolesz-approver INTO
                                    wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

**11/05/2007
  CLEAR flag.

ENDFORM.                    " insert_data
*&---------------------------------------------------------------------*
*&      Form  display_role_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_role_pm.
  wa_roles1-userid = zic_prep_rolereq-userid.
  wa_roles1-role_name = 'D:PM_DISPLAY'.
  APPEND wa_roles1 TO it_roles1.
ENDFORM.                    " display_role_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_status.
* begin of <RD1K960036>
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to change status to IC? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_choice.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Do you want to change status to IC? '
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
* Begin of <RD1K960611>
*   Worng variable was used in the previous change
*     ANSWER                = status_process
      answer                = status_choice
* End of <RD1K960611>
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* end of <RD1K960036>

ENDFORM.                    " confirm_status
*&---------------------------------------------------------------------*
*&      Form  confirm_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_process.
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to process request after sav
*ing? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = status_process.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR              = ' '
*     DIAGNOSE_OBJECT       = ' '
      text_question         = 'Do you want to process request after'
                              & ' saving?'
      text_button_1         = 'Yes'(003)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'No'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = space
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = status_process
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_process

*&---------------------------------------------------------------------*
*&      Form  check_module_status_mm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_mm.
  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    mm_not_ok = 'X'.
  ENDIF.
ENDFORM.                    " check_module_status_mm
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pm.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    pm_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_message.
* begin of <RD1K960036>
* FM 'POPUP_TO_CONFIRM_STEP' is obsolete.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'N'
*            TEXTLINE1     = 'This is a multiple module request. If u con
*tinue with correspondence,'
*            TEXTLINE2     = 'other modules will not be able to process t
*heir part of the request,OK'
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirm'
*     DIAGNOSE_OBJECT             = ' '
      text_question  = 'This is a multiple module request.' &
                       ' If u continue with correspondence,' &
                       ' other modules will not be able to' &
                       ' process their part of the request,OK'
      text_button_1  = 'Yes'(003)
*     ICON_BUTTON_1  = ' '
      text_button_2  = 'No'(002)
*     ICON_BUTTON_2  = ' '
      default_button = '2'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = gl_ans
*   TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF gl_ans EQ '1'.
    CLEAR gl_ans.
    MOVE 'Y' TO gl_ans.
  ELSEIF gl_ans EQ '2'.
    CLEAR gl_ans.
    MOVE 'N' TO gl_ans.
  ELSE.
    CLEAR gl_ans.
  ENDIF.
* end of <RD1K960036>
ENDFORM.                    " confirm_message
*&---------------------------------------------------------------------*
*&      Form  create_roles_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_ps.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_ps INTO wa_roles_ps.
    APPEND wa_roles_ps TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_ps.

    IF NOT wa_roles_ps-role_type IS INITIAL.

      LOOP AT g_tablctrl112_itab INTO wa_rolesz_ps.
        IF wa_roles_ps-role_type = wa_rolesz_ps-role_name AND
                                wa_rolesz_ps-rej_fl = '' AND
                                wa_rolesz_ps-status = '' AND
                                wa_rolesz_ps-role_request = ''.
          PERFORM insert_data_ps.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
**
*  clear : flag, flag1.

ENDFORM.                    " create_roles_ps
*&---------------------------------------------------------------------*
*&      Form  insert_data_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_ps.

  SEARCH wa_roles_ps-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'AAA'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'AAA' WITH wa_rolesz_ps-asset INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'BBB'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'BBB' WITH wa_rolesz_ps-basin INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'XXYY'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'XX' WITH wa_rolesz_ps-project INTO
                                wa_roles1-role_name.
    REPLACE 'YY' WITH wa_rolesz_ps-location INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_ps-role_name FOR 'ZZZ'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    REPLACE 'ZZZ' WITH 'ALL' INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_ps-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_ps
*&---------------------------------------------------------------------*
*&      Form  insert_items_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_ps.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl112_itab
  BY role_name service project location asset basin.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl112_itab
    COMPARING role_name rej_fl service project location
    asset basin.

  LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

    MOVE-CORRESPONDING g_tablctrl112_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

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

ENDFORM.                    " insert_items_ps
*&---------------------------------------------------------------------*
*&      Form  check_items_save_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_ps.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zps_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zps_prep_roledes-service = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-service IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE i084(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zps_prep_roledes-project = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-project IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
          ROLLBACK WORK.
          MESSAGE i095(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax12.

ENDFORM.                    " check_items_save_ps
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax12
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax12.
  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl112_itab INTO g_tablctrl112_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT g_tablctrl112_wa-service IS INITIAL.
**?
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH g_tablctrl112_wa-role_name.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax12
*&---------------------------------------------------------------------*
*&      Form  check_module_status_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_ps.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    ps_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_ps
*&---------------------------------------------------------------------*
*&      Form  create_roles_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_pp.
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_pp INTO wa_roles_pp.
    APPEND wa_roles_pp TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_pp.

    IF NOT wa_roles_pp-role_type IS INITIAL.

      LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
        IF wa_roles_pp-role_type = wa_rolesz_pp-role_name AND
                                wa_rolesz_pp-rej_fl = '' AND
                                wa_rolesz_pp-status = '' AND
                                wa_rolesz_pp-role_request = ''.
          PERFORM insert_data_pp.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT it_roles1_pp INTO wa_roles1_pp.

    IF NOT wa_roles_pp-role_type IS INITIAL.

      LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
        IF wa_roles1_pp-role_type = wa_rolesz_pp-role_name AND
               wa_roles1_pp-plant = wa_rolesz_pp-plant    AND
                                wa_rolesz_pp-rej_fl = '' AND
                                wa_rolesz_pp-status = '' AND
                                wa_rolesz_pp-role_request = ''.
          PERFORM insert_data1_pp.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  LOOP AT g_tablctrl113_itab INTO wa_rolesz_pp.
    IF  wa_rolesz_pp-rej_fl = '' AND
        wa_rolesz_pp-status = '' AND
        wa_rolesz_pp-role_request = ''.
      PERFORM insert_data3_pp.
    ENDIF.
  ENDLOOP.

*  PERFORM insert_data2_pp.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  PERFORM modify_data4_pp.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
*
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_pp.

  SEARCH wa_roles_pp-role_name FOR 'XXXX'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'XXXX'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'XXXX' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'YYYY'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'YYYY'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'YYYY' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'AAAA'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
         role_type = wa_rolesz_pp-role_name AND
         plant     = wa_rolesz_pp-plant    AND
         plant_gen = 'AAAA'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'AAAA' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'BBBB'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'BBBB'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'BBBB' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'CCCC'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'CCCC'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'CCCC' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'DDDD'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'DDDD'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'DDDD' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'EEEE'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'EEEE'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'EEEE' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.
  SEARCH wa_roles_pp-role_name FOR 'FFFF'.
  IF sy-subrc = 0.

    SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'FFFF'.
    IF sy-subrc = 0.
      wa_flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_pp-role_name.
      REPLACE 'FFFF' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ELSE.
      wa_flag1 = 'X'.
    ENDIF.
  ENDIF.

  IF wa_flag <> 'X' AND wa_flag1 <> 'X'.
    SEARCH wa_roles_pp-role_name FOR 'ZZZZ'.
    IF sy-subrc <> 0.
      CLEAR :wa_flag, wa_flag1.
      SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant.
      IF sy-subrc = 0.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles_pp-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.

  IF wa_rolesz_pp-role_name = 'PP3'.

    SEARCH wa_roles_pp-role_name FOR 'ZZZZ'.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zpp_prep_generic WHERE
           role_type = wa_rolesz_pp-role_name AND
           plant     = wa_rolesz_pp-plant    AND
           plant_gen = 'AAAA'.
      IF sy-subrc = 0.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles_pp-role_name.
        REPLACE 'ZZZZ' WITH wa_rolesz_pp-plant INTO wa_roles1-role_name.
        SELECT * FROM ZPP_PREP_RES UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ROLESZ_PP-ROLE_NAME AND PLANT = WA_ROLESZ_PP-PLANT AND RES = WA_ROLESZ_PP-RES
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        CONCATENATE wa_roles1-role_name zpp_prep_res-res_code INTO
        wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
    ENDIF.

  ENDIF.

  CLEAR : wa_flag, wa_flag1.

ENDFORM.                    " insert_data_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pp.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl113_itab
  BY role_name plant sloc res ctf_sloc.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl113_itab
    COMPARING role_name rej_fl plant sloc res
    ctf_sloc.

  LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

    MOVE-CORRESPONDING g_tablctrl113_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
       wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO'.
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

ENDFORM.                    " insert_items_pp
*&---------------------------------------------------------------------*
*&      Form  check_items_save_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_pp.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

*      if zpp_prep_roledes-plant = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-plant is initial.
*          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*          rollback work.
*          message i074(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*     if zpp_prep_roledes-sloc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-sloc is initial.
*          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
*          rollback work.
*          message i090(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zpp_prep_roledes-res = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-res is initial.
*          g_field = 'ZIC_PREP_ROLEREI-RES'.
*          rollback work.
*          message i184(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zpp_prep_roledes-ctf_sloc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' or
*                    old_ok_code = 'CROSSCO' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-ctf_sloc is initial.
*          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
*          rollback work.
*          message i090(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
******
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax13.

ENDFORM.                    " check_items_save_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data1_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data1_pp.

  IF wa_rolesz_pp-role_name = 'PP1' OR
     wa_rolesz_pp-role_name = 'PP2' OR
     wa_rolesz_pp-role_name = 'PP10'.
    SELECT * FROM  zhelp_pproles1 INTO TABLE it_roles1_pp_tmp WHERE
    role_type = wa_rolesz_pp-role_name AND
    plant = wa_rolesz_pp-plant.
    IF sy-subrc = 0.
      LOOP AT it_roles1_pp_tmp INTO wa_roles1_pp.
        wa_roles1-userid = zic_prep_rolereq-userid.
        wa_roles1-role_name = wa_roles1_pp-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDLOOP.
    ENDIF.

  ENDIF.

ENDFORM.                    " insert_data1_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data2_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data2_pp.

*  if not wa_flag is initial.
*    WA_ROLES1-USERID = zic_prep_rolereq-userid.
*    WA_ROLES1-ROLE_NAME = 'PP_DIS_PROFILES_ALL'.
*    APPEND WA_ROLES1 to IT_ROLES1.
*    clear wa_flag.
*  endif.

ENDFORM.                    " insert_data2_pp
*&---------------------------------------------------------------------*
*&      Form  insert_data3_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data3_pp.

  IF wa_rolesz_pp-role_name = 'PP4' OR
      wa_rolesz_pp-role_name = 'PP8'.
    SELECT SINGLE * FROM  zpp_prep_droleex INTO wa_roles2_pp WHERE
    role_type = wa_rolesz_pp-role_name AND
    plant = wa_rolesz_pp-plant         AND
    sloc  = wa_rolesz_pp-sloc          AND
    ctf_sloc = wa_rolesz_pp-ctf_sloc.
    IF sy-subrc = 0.
      SELECT * FROM zpp_prep_drole INTO TABLE it_roles3_pp WHERE
          plant = wa_rolesz_pp-plant AND
          sloc  = wa_rolesz_pp-sloc  AND
          ctf_sloc = wa_rolesz_pp-ctf_sloc.
    ELSE.
      SELECT * FROM zpp_prep_drole INTO TABLE it_roles3_pp WHERE
          plant = wa_rolesz_pp-plant AND
          sloc  = wa_rolesz_pp-sloc  AND
          ctf_sloc = ''.
    ENDIF.
  ENDIF.

  LOOP AT it_roles3_pp INTO wa_roles3_pp.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles3_pp-drole.
    APPEND wa_roles1 TO it_roles1.
  ENDLOOP.
ENDFORM.                    " insert_data3_pp
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pp.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    pp_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_pp
*&---------------------------------------------------------------------*
*&      Form  create_roles_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_sd.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_sd INTO wa_roles_sd.
    APPEND wa_roles_sd TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_sd.

    IF NOT wa_roles_sd-role_type IS INITIAL.

      LOOP AT g_tablctrl114_itab INTO wa_rolesz_sd.
        IF wa_roles_sd-role_type = wa_rolesz_sd-role_name AND
                                wa_rolesz_sd-rej_fl = '' AND
                                wa_rolesz_sd-status = '' AND
                                wa_rolesz_sd-role_request = ''.
          PERFORM insert_data_sd.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_sd
*&---------------------------------------------------------------------*
*&      Form  insert_items_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_sd.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl114_itab
  BY role_name sale_org div plant ship_point.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl114_itab
    COMPARING role_name rej_fl sale_org div plant ship_point.

  LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

    MOVE-CORRESPONDING g_tablctrl114_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
       wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
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

ENDFORM.                    " insert_items_sd
*&---------------------------------------------------------------------*
*&      Form  check_items_save_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_sd.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zsd_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.

      IF zsd_prep_roledes-plant = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-plant IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          ROLLBACK WORK.
          MESSAGE i074(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-sale_org = 'X' AND
                      ( old_ok_code = 'APPROVE' OR
                     old_ok_code = 'RELEASE' OR
                     old_ok_code = 'CHANGE' OR
                     old_ok_code = 'CREATE' OR
                     old_ok_code = 'CROSSCO' ) AND
                     NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-sale_org IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          ROLLBACK WORK.
          MESSAGE i190(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-div = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-div IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          ROLLBACK WORK.
          MESSAGE i194(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

      IF zsd_prep_roledes-ship_point = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE' OR
                    old_ok_code = 'CREATE' OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-ship_point IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          ROLLBACK WORK.
          MESSAGE i191(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.

*****
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax14.

ENDFORM.                    " check_items_save_sd
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax13
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax13.

  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl113_itab INTO g_tablctrl113_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.


      IF NOT zic_prep_rolerei-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                   TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                      AND werks = zic_prep_rolerei-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-sloc IS INITIAL.

        SELECT SINGLE * FROM t001l INTO CORRESPONDING FIELDS OF
                 it_t001l  WHERE werks = zic_prep_rolerei-plant
                 AND lgort = zic_prep_rolerei-sloc.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e073(zhelp) WITH zic_prep_rolerei-sloc.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-res IS INITIAL.

        SELECT SINGLE * FROM zpp_prep_res INTO CORRESPONDING FIELDS OF
                 it_res  WHERE role_type = zic_prep_rolerei-role_name
                 AND
                 plant = zic_prep_rolerei-plant
                 AND
                 res = zic_prep_rolerei-res.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-RES'.
          g_i = g_curr_line_113.
          ROLLBACK WORK.
          MESSAGE e183(zhelp) WITH zic_prep_rolerei-res.

        ENDIF.

      ENDIF.


      IF NOT zic_prep_rolerei-ctf_sloc IS INITIAL.

        SELECT SINGLE * FROM zpp_prep_droleex WHERE role_type =
          zic_prep_rolerei-role_name
          AND plant = zic_prep_rolerei-plant
          AND sloc = zic_prep_rolerei-sloc
          AND ctf_sloc = zic_prep_rolerei-ctf_sloc.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
          g_i = g_curr_line.
          ROLLBACK WORK.
          MESSAGE e073(zhelp) WITH zic_prep_rolerei-ctf_sloc.

        ENDIF.

      ENDIF.
****
    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax13
*&---------------------------------------------------------------------*
*&      Form  check_module_status_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_sd.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    sd_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_sd
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax14
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax14.
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl114_itab INTO g_tablctrl114_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

      IF NOT zic_prep_rolerei-plant IS INITIAL.

        SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
                       TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
                                          AND werks = zic_prep_rolerei-plant.
        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          g_i = g_curr_line_114.
          MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-sale_org IS INITIAL.

        SELECT SINGLE * FROM tvko CLIENT SPECIFIED INTO CORRESPONDING FIELDS
                 OF it_tvko  WHERE mandt = sy-mandt AND
                 bukrs =  zic_prep_rolereq-ccode AND
                 vkorg = zic_prep_rolerei-sale_org.

        IF sy-subrc <> 0 AND zic_prep_rolerei-sale_org <> 'ALL'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          g_i = g_curr_line_114.
          MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
        ELSEIF zic_prep_rolereq-ccode = 'MUM' AND
                zic_prep_rolereq-fundc1 = 'MUMPHPOP' AND
          zic_prep_rolereq-fundc1 <> 'MUMPHPSP' AND         "12102015
                zic_prep_rolerei-sale_org <> 'HZRS'.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          g_i = g_curr_line_114.
          MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
        ELSE.
          IF zic_prep_rolereq-ccode = 'MUM' AND
          zic_prep_rolereq-fundc1 <> 'MUMPHPOP' AND
              zic_prep_rolereq-fundc1 <> 'MUMPHPSP' AND     "12102015
          zic_prep_rolerei-sale_org = 'HZRS'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            MESSAGE e186(zhelp) WITH zic_prep_rolerei-sale_org.
          ENDIF.
        ENDIF.

      ENDIF.

      IF NOT zic_prep_rolerei-div IS INITIAL.

        SELECT SINGLE * FROM tvkos CLIENT SPECIFIED INTO CORRESPONDING
                 FIELDS OF it_tvkos  WHERE mandt = sy-mandt AND
                 vkorg =  zic_prep_rolerei-sale_org AND
                 spart =  zic_prep_rolerei-div.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          g_i = g_curr_line_114.
          MESSAGE e187(zhelp) WITH zic_prep_rolerei-div.

        ENDIF.

      ENDIF.


      IF NOT zic_prep_rolerei-ship_point IS INITIAL.

        SELECT SINGLE * FROM tvswz INTO CORRESPONDING FIELDS OF
              it_tvswz  WHERE werks = zic_prep_rolerei-plant AND
              vstel = zic_prep_rolerei-ship_point.

        IF sy-subrc <> 0.
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          g_i = g_curr_line.
          MESSAGE e188(zhelp) WITH zic_prep_rolerei-ship_point.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax14
*&---------------------------------------------------------------------*
*&      Form  insert_data_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_sd.

  SEARCH wa_roles_sd-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    REPLACE 'XXXX' WITH wa_rolesz_sd-sale_org INTO
                             wa_roles1-role_name.
    REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                             wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_sd-role_name FOR 'YYYY'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    IF wa_rolesz_sd-role_name = 'S2'.
      IF wa_rolesz_sd-div = 'GA' AND
         ( wa_rolesz_sd-ship_point = 'GAIL' OR
           wa_rolesz_sd-ship_point = 'HBJ' ).
        REPLACE 'YYYY' WITH wa_rolesz_sd-sale_org INTO
                                   wa_roles1-role_name.
      ELSE.
        REPLACE 'YYYY' WITH wa_rolesz_sd-ship_point INTO
                                    wa_roles1-role_name.
      ENDIF.
    ENDIF.
    REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  SEARCH wa_roles_sd-role_name FOR 'PPPP'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    REPLACE 'PPPP' WITH wa_rolesz_sd-plant INTO
                                  wa_roles1-role_name.
    IF wa_rolesz_sd-role_name = 'S7A'.
      REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                  wa_roles1-role_name.
    ENDIF.
    SELECT SINGLE * FROM zsd_prep_level WHERE plant = wa_rolesz_sd-plant
.
    IF sy-subrc = 0 AND wa_rolesz_sd-role_name = 'S7'.
      REPLACE 'LL' WITH zsd_prep_level-level_ex INTO
                                wa_roles1-role_name.
    ELSE.
      REPLACE 'ZZ' WITH wa_rolesz_sd-div INTO
                                wa_roles1-role_name.
    ENDIF.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF wa_rolesz_sd-role_name = 'SXX'.
    SELECT SINGLE * FROM zsd_prep_area WHERE
                  sale_org = wa_rolesz_sd-sale_org.
    IF sy-subrc = 0.
      flag = 'X'.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles_sd-role_name.
      REPLACE 'AAA' WITH zsd_prep_area-area INTO
                                wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_sd-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_sd
*&---------------------------------------------------------------------*
*&      Form  modify_data4_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data4_pp.
  LOOP AT it_roles1 INTO wa_roles1_pp.
    SEARCH wa_roles1_pp-role_name FOR 'PP_DIS_PROFILES'.
    IF sy-subrc = 0.
      IF wa_roles1_pp-role_name+17(3) <> 'ALL'.
        check_plant_fl = 'X'.
        EXIT.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF check_plant_fl = 'X'.
    CLEAR check_plant_fl.
    DELETE it_roles1 WHERE role_name =  'PP_DIS_PROFILES_ALL'.
  ENDIF.
ENDFORM.                    " modify_data4_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_qm.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab, i.

  SORT g_tablctrl115_itab
  BY role_name plant asset_qm.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl115_itab
    COMPARING role_name rej_fl plant asset_qm.

  LOOP AT g_tablctrl115_itab INTO g_tablctrl115_wa.

    MOVE-CORRESPONDING g_tablctrl115_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
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

ENDFORM.                    " insert_items_qm
*&---------------------------------------------------------------------*
*&      Form  check_items_save_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_qm.

ENDFORM.                    " check_items_save_qm
*&---------------------------------------------------------------------*
*&      Form  create_roles_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_qm.
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_qm INTO wa_roles_qm.
    APPEND wa_roles_qm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.

  LOOP AT it_roles0 INTO wa_roles_qm.

    IF NOT wa_roles_qm-role_type IS INITIAL.

      LOOP AT g_tablctrl115_itab INTO wa_rolesz_qm.
        IF wa_roles_qm-role_type = wa_rolesz_qm-role_name AND
                                wa_rolesz_qm-rej_fl = '' AND
                                wa_rolesz_qm-status = '' AND
                                wa_rolesz_qm-role_request = ''.
          PERFORM insert_data_qm.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.

  ENDLOOP.

  PERFORM download_file.
*
  PERFORM copy_values.
*
  PERFORM confirm_step.
*
  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
*
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.
*
ENDFORM.                    " create_roles_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_qm.
  SEARCH wa_roles_qm-role_name FOR 'XXXX'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    IF wa_rolesz_qm-role_name = 'Q1'.
      SELECT SINGLE * FROM zqm_prep_loc WHERE
             plant = wa_rolesz_qm-plant.
      IF sy-subrc = 0.
        REPLACE 'XXXX' WITH zqm_prep_loc-loc INTO
                                 wa_roles1-role_name.
      ELSE.
        REPLACE 'XXXX' WITH zic_prep_rolereq-ccode+0(3) INTO
                                 wa_roles1-role_name.
      ENDIF.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  SEARCH wa_roles_qm-role_name FOR 'YYYY'.

  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    IF wa_rolesz_qm-role_name = 'Q2'.
      IF  wa_rolesz_qm-asset_qm <> ''.
        REPLACE 'YYYY' WITH wa_rolesz_qm-asset_qm INTO
                                    wa_roles1-role_name.
      ELSE.
        REPLACE 'YYYY' WITH zic_prep_rolereq-ccode+0(3) INTO
                                    wa_roles1-role_name.
      ENDIF.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

  IF wa_rolesz_qm-role_name = 'Q3'.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_qm-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

ENDFORM.                    " insert_data_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data1_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data1_sd.

  IF wa_rolesz_sd-role_name = 'SXX'.
    SELECT SINGLE * FROM zsd_prep_area WHERE
                  sale_org = wa_rolesz_sd-sale_org.
    IF sy-subrc = 0.
      wa_roles1-userid = zic_prep_rolereq-userid.
      CONCATENATE 'SD_XX_DI_' zsd_prep_area-area INTO
      wa_roles1-role_name.
      APPEND wa_roles1 TO it_roles1.
    ENDIF.
  ENDIF.

ENDFORM.                    " insert_data1_sd
*&---------------------------------------------------------------------*
*&      Form  check_module_status_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_qm.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    qm_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_qm
*&---------------------------------------------------------------------*
*&      Form  insert_data_addl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_addl.
  CLEAR wa_roles1.
  DATA : condition(3) TYPE c.
*Begin of <RD1K962817>.
  CLEAR : lv_min_desig,
           lv_curr_role.
*End of <RD1K962817>.
  REFRESH it_roles1_addl.
  SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE
 ROLE_TYPE = WA_ROLESZ-ROLE_NAME AND ROLE_TYPE_EX = WA_ROLESZ-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
*Begin of <RD1K962817>.
    lv_min_desig = zmm_prep_crcdesg-min_designation.
    lv_curr_role = zic_prep_rolereq-persk.
*End of <RD1K962817>.

*Begin of< RD1K963297>.
*    IF zmm_prep_crcdesg-crc_level_addl <> space.
*      wa_rolesz-approver = zmm_prep_crcdesg-crc_level_addl.
*      IF lv_curr_role = lv_min_desig.
*      ELSE.
*        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
*          CASE wa_rolesz-approver.
*            WHEN 'L2'.
*              wa_rolesz-approver = 'L3'.
*            WHEN 'L1'.
*              wa_rolesz-approver = 'L2'.
*            WHEN 'L3'.
*              wa_rolesz-approver = 'L4'.
*          ENDCASE.
*
*        ENDIF.
*      ENDIF.
*      MOVE wa_rolesz-approver TO zmm_prep_crcdesg-crc_level_addl.
    IF zmm_prep_crcdesg-crc_level_addl <> space.
*      wa_rolesz-approver = zmm_prep_crcdesg-crc_level_addl.
      IF lv_curr_role = lv_min_desig  OR lv_min_desig = space.
      ELSE.
        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
*          CASE wa_rolesz-approver.
*            WHEN 'L2'.
*              wa_rolesz-approver = 'L3'.
*            WHEN 'L1'.
*              wa_rolesz-approver = 'L2'.
*            WHEN 'L3'.
*              wa_rolesz-approver = 'L4'.
*          ENDCASE.
          SELECT SINGLE * FROM zmm_prep_crcimii WHERE
          crc_level_addl = zmm_prep_crcdesg-crc_level_addl AND
          crc_level      = zmm_prep_crcdesg-crc_level   AND
          min_designation = zic_prep_rolereq-persk.
          IF sy-subrc = 0 .
            MOVE zmm_prep_crcimii-po_level TO zmm_prep_crcdesg-crc_level.
            MOVE zmm_prep_crcimii-srv_levl TO zmm_prep_crcdesg-crc_level_addl.
          ELSE .
            MESSAGE e803(zmm) WITH 'No Entries Found in The Table ZMM_PREP_CRCIMII'.
          ENDIF.
        ENDIF.
      ENDIF.
      MOVE zmm_prep_crcdesg-crc_level_addl TO wa_rolesz-approver.

    ELSE.    "zmm_prep_crcdesg-crc_level_addl IS INITIAL.  LV_CURR_ROLE LE LV_MIN_DESIG.
      wa_rolesz-approver = zmm_prep_crcdesg-crc_level.
      IF lv_curr_role = lv_min_desig OR lv_min_desig = space..
      ELSE.
        IF lv_curr_role LE lv_min_desig OR lv_min_desig = space.
          CASE wa_rolesz-approver.
            WHEN 'L2'.
              wa_rolesz-approver = 'L3'.
            WHEN 'L1'.
              wa_rolesz-approver = 'L2'.
            WHEN 'L3'.
              wa_rolesz-approver = 'L4'.
          ENDCASE.
        ENDIF.
      ENDIF.
      MOVE wa_rolesz-approver TO zmm_prep_crcdesg-crc_level.
    ENDIF.
*End of < RD1K963297>.
*    IF zmm_prep_crcdesg-crc_level = 'L1'.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3'.
*    ELSEIF  zmm_prep_crcdesg-crc_level = 'L2' OR
*            zmm_prep_crcdesg-crc_level = 'L3' OR
*            zmm_prep_crcdesg-crc_level = 'IM' OR
**Begin of <RD1K963297>.
*           zmm_prep_crcdesg-crc_level = 'SM'.
**End of <RD1K963297>.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3A'.
*    ELSEIF zmm_prep_crcdesg-crc_level = 'L4' OR
*            zmm_prep_crcdesg-crc_level = 'E5' OR
*            zmm_prep_crcdesg-crc_level = 'E6' OR
*            zmm_prep_crcdesg-crc_level = 'E7'.
*      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
*             it_roles1_addl WHERE role_type = 'M3B'.
   SELECT * FROM ZMM_PREP_CRCROLE INTO @DATA(WA_MROLE) UP TO 1 ROWS
 WHERE CRC_LEVEL = @ZMM_PREP_CRCDESG-CRC_LEVEL
 ORDER BY PRIMARY KEY .
 ENDSELECT.
     IF sy-subrc = 0.
       SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
             it_roles1_addl WHERE role_type = wa_mrole-MAPPED_ROLE.
     ENDIF.

    IF ( zmm_prep_crcdesg-crc_level = 'SM' AND
            zmm_prep_crcdesg-crc_level_addl = 'SM' ).

      SELECT * FROM zhelp_mmroles INTO CORRESPONDING FIELDS OF TABLE
            it_roles1_addl WHERE role_type = 'M11M'.
    ENDIF.
    CLEAR flag.
    LOOP AT it_roles1_addl INTO wa_roles1.
      wa_roles1-userid = zic_prep_rolereq-userid.
      wa_roles1-role_name = wa_roles1-role_name.
      SEARCH wa_roles1-role_name FOR 'XX'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'XX' WITH wa_rolesz-approver INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      SEARCH wa_roles1-role_name FOR 'QQ'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'QQ' WITH zmm_prep_crcdesg-crc_level INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.
      SEARCH wa_roles1-role_name FOR 'PLANT'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                              wa_roles1-role_name.
        REPLACE 'PPPP' WITH wa_rolesz-plant INTO wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'FM_LOGS'.
      IF sy-subrc = 0.
        flag = 'X'.
*BEGIN OF  <RD1K963151>.
        IF zic_prep_rolereq-ccode = 'OVL'.

          wa_roles1-role_name = 'D:FM_LOGS_OVL_ALL'.
          APPEND wa_roles1 TO it_roles1.
        ELSE.
*END OF <RD1K963151>.
          IF zic_prep_rolereq-fundc1 <> '' .
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc1 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc2 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc2 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc3 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc3 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
          IF zic_prep_rolereq-fundc4 <> ''.
            REPLACE 'FFFFFFFF' WITH zic_prep_rolereq-fundc4 INTO
                               wa_roles1-role_name.
            APPEND wa_roles1 TO it_roles1.
          ENDIF.
        ENDIF.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'CCC_YY'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                      wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      SEARCH wa_roles1-role_name FOR 'PGG'.
      IF sy-subrc = 0.
        flag = 'X'.
        REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                      wa_roles1-role_name.
        REPLACE 'PGG' WITH wa_rolesz-grp INTO wa_roles1-role_name.
        APPEND wa_roles1 TO it_roles1.
      ENDIF.

      IF flag <> 'X'.
        APPEND wa_roles1 TO it_roles1.
      ELSE.
        CLEAR flag.
      ENDIF.
    ENDLOOP.
*Begin of <RD1K963151>.
    IF zic_prep_rolereq-ccode = 'OVL'.
      CLEAR wa_roles1.
      LOOP AT it_roles1 INTO wa_roles1.
        IF wa_roles1-role_name = 'D:MM_DISPLAY_ALL'.
          wa_roles1-role_name = 'D:MM_OVL_DISPLAY_ALL'.
        ENDIF.
        IF wa_roles1-role_name = 'D:MM_DISPLAY_PM_PS_LIS_CIN'.
          wa_roles1-role_name = 'D:MM_OVL_DISPLAY_PM_PS_LIS_CIN'.
        ENDIF.
        MODIFY it_roles1 FROM wa_roles1.
      ENDLOOP.
    ENDIF.
*End of <RD1K963151>.
  ENDIF.
ENDFORM.                    " insert_data_addl
*&---------------------------------------------------------------------*
*&      Form  insert_items_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_hs.

  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl116_itab
  BY role_name.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl116_itab
    COMPARING role_name rej_fl.

  LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

    MOVE-CORRESPONDING g_tablctrl116_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
        wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.


*    Perform check_items_save.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
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


ENDFORM.                    " insert_items_hs
*&---------------------------------------------------------------------*
*&      Form  check_items_save_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_hs.

  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zhs_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc <> 0.

      MESSAGE e102(zhelp) WITH zhs_prep_roledes-role_type.

    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax16.

ENDFORM.                    " check_items_save_hs
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax16
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax16.

  IF zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    CONCATENATE '000' zic_prep_rolereq-userid INTO cpf_lfb1.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
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
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode = zic_prep_rolereq-ccode.

  ENDIF.

  LOOP AT g_tablctrl116_itab INTO g_tablctrl116_wa.

**********************************************************

    IF old_ok_code <> 'DISPLAY'.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " validate_lineitem_datax16
*&---------------------------------------------------------------------*
*&      Form  check_module_status_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_hse.

  IF wa_item-rej_fl = '' AND wa_item-role_request <> ''.
  ELSEIF wa_item-rej_fl <> '' AND wa_item-role_request = ''.
  ELSE.
    hs_not_ok = 'X'.
  ENDIF.

ENDFORM.                    " check_module_status_hs
*&---------------------------------------------------------------------*
*&      Form  create_roles_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_hs.

  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_hs INTO wa_roles_hs.
    APPEND wa_roles_hs TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_hs.

    IF NOT wa_roles_hs-role_type IS INITIAL.

      LOOP AT g_tablctrl116_itab INTO wa_rolesz_hs.
        IF wa_roles_hs-role_type = wa_rolesz_hs-role_name AND
                                wa_rolesz_hs-rej_fl = '' AND
                                wa_rolesz_hs-status = '' AND
                                wa_rolesz_hs-role_request = ''.
          PERFORM insert_data_hs.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.

***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***
  PERFORM list_processing.

*
  CLEAR : flag, flag1.

ENDFORM.                    " create_roles_hs
*&---------------------------------------------------------------------*
*&      Form  insert_data_hs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_hs.

  SEARCH wa_roles_hs-role_name FOR 'CCC'.
  IF sy-subrc = 0.
    flag = 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_hs-role_name.
    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
                                wa_roles1-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  IF flag <> 'X'.
    wa_roles1-userid = zic_prep_rolereq-userid.
    wa_roles1-role_name = wa_roles_hs-role_name.
    APPEND wa_roles1 TO it_roles1.
  ENDIF.

  CLEAR flag.

*
ENDFORM.                    " insert_data_hs
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_olm .
  CLEAR it_roles0.
  CLEAR it_roles1.

  LOOP AT it_roles_olm INTO wa_roles_olm.
    APPEND wa_roles_olm TO it_roles0.
  ENDLOOP.

  CLEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles_olm.

    IF NOT wa_roles_olm-role_type IS INITIAL.

      LOOP AT g_tablctrl117_itab INTO wa_rolesz_olm.
        IF wa_roles_olm-role_type = wa_rolesz_olm-role_name .
          "      AND
          "  wa_rolesz_olm-rej_fl = '' AND
          "   wa_rolesz_olm-status = '' AND
          "  wa_rolesz_olm-role_request = ''.
*          PERFORM insert_data_olm.
          wa_roles1-userid = zic_prep_rolereq-userid.
          wa_roles1-role_name = wa_roles_olm-role_name.
          APPEND wa_roles1 TO it_roles1.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT it_roles1.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  LOOP AT it_roles1 INTO wa_roles1.

    WRITE zic_prep_rolereq-fr_date_auth TO wa_dat1 DD/MM/YYYY.

    WRITE zic_prep_rolereq-to_date_auth TO wa_dat2 DD/MM/YYYY.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    MODIFY it_roles1 FROM wa_roles1.
    CLEAR wa_roles1.
  ENDLOOP.

  PERFORM download_file.

  PERFORM copy_values.

  PERFORM confirm_step.

  IF gl_ans = 'J'.
    gl_ans_save = gl_ans.
    PERFORM insert_record.
    PERFORM save_request.
  ENDIF.
***
  gl_ans = gl_ans_save.
  CLEAR gl_ans_save.
***

  PERFORM list_processing.

*
*  CLEAR : flag, flag1.

ENDFORM.                    " CREATE_ROLES_OLM
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data_olm .

* SEARCH wa_roles_olm-role_name FOR 'CCC'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'CCC' WITH zic_prep_rolereq-ccode+0(3) INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  SEARCH wa_roles_olm-role_name FOR 'AAA'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'AAA' WITH wa_rolesz_olm-asset INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  SEARCH wa_roles_olm-role_name FOR 'BBB'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'BBB' WITH wa_rolesz_olm-basin INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.
*
*  SEARCH wa_roles_olm-role_name FOR 'XXYY'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'XX' WITH wa_rolesz_olm-project INTO
*                                wa_roles1-role_name.
*    REPLACE 'YY' WITH wa_rolesz_olm-location INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.
*
*  SEARCH wa_roles_olm-role_name FOR 'ZZZ'.
*  IF sy-subrc = 0.
*    flag = 'X'.
*    wa_roles1-userid = zic_prep_rolereq-userid.
*    wa_roles1-role_name = wa_roles_olm-role_name.
*    REPLACE 'ZZZ' WITH 'ALL' INTO
*                                wa_roles1-role_name.
*    APPEND wa_roles1 TO it_roles1.
*  ENDIF.

*  IF flag <> 'X'.
  wa_roles1-userid = zic_prep_rolereq-userid.
  wa_roles1-role_name = wa_roles_olm-role_name.
  APPEND wa_roles1 TO it_roles1.
*  ENDIF.

  CLEAR flag.
ENDFORM.                    " INSERT_DATA_OLM
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_olm .
  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl117_itab
  BY role_name.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl117_itab
    COMPARING role_name.

  LOOP AT g_tablctrl117_itab INTO g_tablctrl117_wa.

    MOVE-CORRESPONDING g_tablctrl117_wa TO wa_itemtab.

    IF g_role_flag = 'X' AND wa_itemtab-rej_fl = '' AND
         wa_itemtab-status = '' AND wa_itemtab-role_request = ''.
      wa_itemtab-role_request = zrolereqno.
    ENDIF.

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
    IF old_ok_code = 'CHANGE'.
      IF sy-subrc = 0.
        SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-DOCNO'.
        MESSAGE i099(zhelp) WITH zic_prep_rolereq-docno.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ELSE.

    DELETE FROM zic_prep_rolerei WHERE docno = zic_prep_rolereq-docno
        AND moduleid = moduleid.

    MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.

    IF sy-subrc = 0 AND g_role_flag <> 'X'.
      MESSAGE i045(zhelp) WITH zic_prep_rolereq-docno.
    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_OLM
*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEMS_SAVE_OLM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_items_save_olm .
  IF old_ok_code <> 'DISPLAY' .

    SELECT SINGLE * FROM zpp_prep_roledes WHERE role_type =
                                                wa_itemtab-role_name.
    IF sy-subrc = 0.
    ENDIF.

  ENDIF.
*
**
  PERFORM validate_lineitem_datax17.
ENDFORM.                    " CHECK_ITEMS_SAVE_OLM
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_LINEITEM_DATAX17
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax17 .
  IF  zic_prep_rolereq-crossco_fl = 'X' OR old_ok_code = 'CROSSCO'.

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
                 a~persk a~sbmod  c~designo c~r_p_cd c~version
               d~sdesig_text AS designation d~adesig_text AS adesignation
               d~disc_cd AS disc_cd
                 INTO CORRESPONDING FIELDS OF TABLE ist_data
            FROM ( ( pa0001 AS a INNER JOIN pa9930 AS c
                  ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                     ON c~designo = d~desig_code AND
                         c~r_p_cd  = d~r_p_cd AND
                         c~version = d~version )
                      WHERE a~pernr =  zic_prep_rolereq-userid AND
                            a~sprps = ' ' AND
                            a~endda = '99991231' AND
                            c~sprps = ' ' AND
                            c~endda = '99991231' .

    IF sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      g_ccode = ist_data-bukrs.
    ENDIF.

  ELSE.

    g_ccode =  zic_prep_rolereq-ccode.

  ENDIF.
ENDFORM.                    " VALIDATE_LINEITEM_DATAX17
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLES_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles_srm .
  CLEAR:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.

    LOOP AT   g_tablctrl118_itab INTO g_tablctrl118_wa.

      wa_roles_srmp-userid = zic_prep_rolereq-userid.
      wa_roles_srmp-role_name = g_tablctrl118_wa-role_name.
      wa_roles_srmp-ccode = zic_prep_rolereq-ccode.
      wa_roles_srmp-from_dat = sy-datum.
      wa_roles_srmp-to_dat   = '99991231'.
      wa_roles_srmp-grp =  g_tablctrl118_wa-grp.
      APPEND  wa_roles_srmp TO it_roles_srmp.

    ENDLOOP.




    p_uname = zic_prep_rolereq-userid.

    SELECT SINGLE * FROM zbcusrmst  INTO CORRESPONDING FIELDS OF wa_zbcusrmst
      WHERE cpfno = zic_prep_rolereq-userid.

    p_fname        = wa_zbcusrmst-first_name.
    p_lname        = wa_zbcusrmst-last_name.
    p_ccode =    zic_prep_rolereq-ccode.


    CALL FUNCTION 'ZSRM_ROLE_ASSIGN_ARMS' DESTINATION l_logsys
      EXPORTING
        p_uname       = p_uname
        p_fname       = p_fname
        p_lname       = p_lname
        p_ccode       = p_ccode
      TABLES
        it_roles_srmp = it_roles_srmp
        itab_return   = itab_return.

    IF itab_return[] IS NOT INITIAL.

      v_srm_st = 'C'.

      LOOP AT itab_return INTO wa_return.

        IF   wa_return-status NE  'C'.
          v_srm_st = 'IF'.
        ELSE.

        ENDIF.
      ENDLOOP.

      IF  v_srm_st = 'C'.
        zic_prep_rolereq-status = 'C'.

      ELSE.
        zic_prep_rolereq-status = 'IF'.
        PERFORM send_sapmail_srmassign .
      ENDIF.


      v_rolereq-docno = zic_prep_rolereq-docno.
      p_uname_sms = p_uname.
      g_userid_n = ''.
      MODIFY zic_prep_rolereq FROM zic_prep_rolereq.
      IF sy-subrc = 0.
        IF  zic_prep_rolereq-status = 'C'.

          CALL FUNCTION 'ZMM_SEND_SMS'
            EXPORTING
              cpfno_s     = g_userid_n
              cpfno_r     = p_uname_sms
              from_dat    = sy-datum
              to_dat      = '99991231'
              auth_req_no = v_rolereq-docno
            IMPORTING
              flag_msg    = l_flag_msg.

          PERFORM send_sapmail_srmassign .

        ENDIF.
      ENDIF.


    ELSE.
      IF  v_srm_st = ''.
        zic_prep_rolereq-status = 'N'.
        MODIFY zic_prep_rolereq FROM zic_prep_rolereq.
      ENDIF.

    ENDIF.

    PERFORM unlock_record.

    CLEAR:v_message_srm.
    IF zic_prep_rolereq-status = 'C'.

      CONCATENATE 'Roles assigned for request No .' zic_prep_rolereq-docno INTO
      v_message_srm SEPARATED BY space.

      MESSAGE i735(zmm) WITH v_message_srm.

    ELSE.

      CONCATENATE 'Roles not  assigned for request No .' zic_prep_rolereq-docno INTO
   v_message_srm SEPARATED BY space.

      MESSAGE i735(zmm) WITH v_message_srm.
    ENDIF.

    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    " CREATE_ROLES_SRM
*&---------------------------------------------------------------------*
*&      Form  SEND_SAPMAIL_SRMASSIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_sapmail_srmassign .
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.

  CONCATENATE document_data-obj_descr '---' moduleid
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

  CONCATENATE  'Subject: '  'Creation of Roles for userid '
zic_prep_rolereq-userid INTO  object_content-line
SEPARATED BY space.
  APPEND object_content.

  MOVE space TO object_content-line.
  APPEND object_content.
  IF zic_prep_rolereq-status = 'C'.


    CONCATENATE 'Please  check  your role request  which  has'
     'been assigned  &  completed - ' zic_prep_rolereq-docno INTO
object_content-line
SEPARATED BY space.
    APPEND object_content.
  ELSE.

  ENDIF.
********************************************************************
  """"""""""""""""""""""
  IF zic_prep_rolereq-status = 'IF'.

    CONCATENATE ' Roles are not assigned for Request no.- ' zic_prep_rolereq-docno INTO
object_content-line
SEPARATED BY space.

    APPEND object_content.
  ENDIF.
  """""""""""""""""""""""""""""
********************************************************************
  MOVE space TO object_content-line.
  APPEND object_content.

  object_content-line = 'ICE Core Team'.
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

*      MESSAGE i060(zhelp) WITH zic_prep_rolereq-useridcr.
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
ENDFORM.                    " SEND_SAPMAIL_SRMASSIGN
*&---------------------------------------------------------------------*
*&      Form  INSERT_ITEMS_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_srm .
  DATA : i LIKE sy-index .
  CLEAR : wa_itemtab, ist_itemtab.

  SORT g_tablctrl118_itab
  BY role_name plant grp  sloc receipt_loc approver.

  DELETE ADJACENT DUPLICATES FROM g_tablctrl118_itab
    COMPARING role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

  LOOP AT g_tablctrl118_itab INTO g_tablctrl118_wa.

    MOVE-CORRESPONDING g_tablctrl118_wa TO wa_itemtab.

    IF old_ok_code = 'CREATE' OR
       old_ok_code = 'CROSSCO' OR
       old_ok_code = 'CRCROLES'.
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

    SELECT SINGLE * FROM zsr_prep_roledes WHERE role_type =
                                                     wa_itemtab-role_name.
    IF sy-subrc = 0.



      IF zsr_prep_roledes-p_grp = 'X' AND
                     ( old_ok_code = 'APPROVE' OR
                    old_ok_code = 'RELEASE' OR
                    old_ok_code = 'CHANGE'  OR
                    old_ok_code = 'CREATE'  OR
                    old_ok_code = 'CROSSCO' ) AND
                    NOT wa_itemtab-role_name IS INITIAL.

        IF wa_itemtab-grp IS INITIAL.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          ROLLBACK WORK.
          MESSAGE i085(zhelp) WITH g_i.
          CLEAR okcode_100.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR:count_grp,g_wa_pgrp.

    LOOP AT g_tablctrl118_itab INTO g_wa_pgrp WHERE  grp = wa_itemtab-grp  .
      IF g_wa_pgrp-grp  IS NOT INITIAL.
        count_grp = count_grp + 1.
      ENDIF.
    ENDLOOP.
    IF  count_grp > '1'.
      MESSAGE i092(zhelp) .
      CLEAR okcode_100.
      CALL SCREEN 100.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE ist_itemtab LINES g_lines_rl.

***added g_reset_fl to check resetting & no rollback
  IF g_lines_rl = 0 .
    ROLLBACK WORK.
    IF old_ok_code = 'CHANGE'.

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
        moduleid = moduleid..
      ENDIF.

      MODIFY zic_prep_rolerei FROM TABLE ist_itemtab.


    ENDIF.

  ENDIF.
ENDFORM.                    " INSERT_ITEMS_SRM
