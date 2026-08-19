*--- MAIN PROGRAM: MZMMPREPROLE1F01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced by POPUP_TO_CONFIRM.
*
************************************************************************

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEF01                                            *
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

  Data l_choice.
  clear l_choice.
  IF g_mode <> 'DIS'.
" Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'BACK'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.

    DATA : l_get1(1) TYPE c.
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


    If l_choice = 'J'.
*       perform clear_var.
      clear l_choice.
    endif.
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

  if sy-tcode = 'ZMM_ARMS_CONNECT'.
       old_ok_code = 'DISPLAY'.
       get parameter id 'ZREQNO' field zmm_prep_rolereq-docno.
  endif.

  refresh it_tab.
  clear wa_tab.

  if old_ok_code =  'CREATE' or
        old_ok_code = 'CROSSCO' or
        old_ok_code = 'CRCROLES' or
        old_ok_code =  'CHANGE' or
        old_ok_code =  'RELEASE' or
        old_ok_code =  'APPROVE' or
        old_ok_code = 'DISPLAY'  or
        old_ok_code = 'DELETE'.

    move 'CREATE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CHANGE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'DELETE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'DISPLAY' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'RELEASE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'APPROVE' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'SUIM' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CROSSCO' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'CRCROLES' to wa_tab-fcode.
    append wa_tab to it_tab.
*     move 'ATTACH' to wa_tab-fcode.
*     append wa_tab to it_tab.

  else.

    move 'CHECK' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'LIST' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'SAV' to wa_tab-fcode.
    append wa_tab to it_tab.

  endif.

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

  CALL FUNCTION 'ENQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_CDHD  = 'E'
            MANDT          = SY-MANDT
            DOCNO          = zmm_prep_rolereq-docno
       EXCEPTIONS
            FOREIGN_LOCK   = 1
            SYSTEM_FAILURE = 2
            OTHERS         = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    MOVE 'Y' to g_lock.
  ENDIF.

ENDFORM.                    " lock_reqhd
*&---------------------------------------------------------------------*
*&      Form  get_correspondense
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_correspondense.

  DATA : l_cors like THEAD-TDNAME.

  IF old_ok_code <> 'CREATE' or
     old_ok_code <> 'CROSSCO'.

    refresh lines_cors.

    move zmm_prep_rolereq-docno to l_cors.

    CALL FUNCTION 'READ_TEXT'
         EXPORTING
              CLIENT                  = SY-MANDT
              ID                      = '0001'
              LANGUAGE                = SY-LANGU
              NAME                    = l_cors
              OBJECT                  = 'ZHELP'
         TABLES
              LINES                   = lines_cors
         EXCEPTIONS
              ID                      = 1
              LANGUAGE                = 2
              NAME                    = 3
              NOT_FOUND               = 4
              OBJECT                  = 5
              REFERENCE_CHECK         = 6
              WRONG_ACCESS_TO_ARCHIVE = 7
              OTHERS                  = 8.

    IF SY-SUBRC <> 0.
      read_flag = ''.
      zmm_prep_rolereq-long_text_fl = ''.
    Else.
      read_flag = 'X'.
      zmm_prep_rolereq-long_text_fl = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_correspondense

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
      g_ins_flag = 'X'.

    WHEN 'DELE'.                      "delete row

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

  g_i = L_LINE.
  g_field = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

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

    IF <MARK_FIELD> = 'X' and <WA>+90(1) = ''.
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
***********************************************************************
  g_tc_lines = <TC>-LINES.
***********************************************************************

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
*&      Form  HELP_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HELP_LIST.

  if ZMM_PREP_ROLEREQ-CCODE is initial.
    set cursor field 'ZMM_PREP_ROLEREQ-CCODE'.
    message i082(zhelp).
    leave to screen 0.
  endif.
  refresh : it_cond.
  concatenate 'FICTR'  'LIKE'  into g_line separated by
  space.
  concatenate g_line+0(10) '''' ZMM_PREP_ROLEREQ-CCODE '%' ''''  into
              g_line.
  append g_line to it_cond.
  if help_list_flag <> 'X' .
    select * from m_fistb into corresponding fields of table it_m_fistb
                  where (it_cond).
    SORT IT_M_FISTB BY BEZEICH SPRAS1 BOSSID FIKRS FICTR. help_list_flag = 'X'.
    refresh it_cond.
  endif.
  loop at it_m_fistb into wa_m_fistb.
*
    if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc2 or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc3 or
       wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc4.
       wa_m_fistb-g_mark = 'X'.
    endif.

   if old_ok_code = 'DISPLAY' or old_ok_code = 'APPROVE'.
      if wa_m_fistb-g_mark = 'X'.
        write: / wa_m_fistb-fictr, wa_m_fistb-bezeich.
      endif.
    else.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
            wa_m_fistb-bezeich.
    endif.

    HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*    CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr.
  endloop.
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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
           COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.
*
      wa_m_fistb-g_mark = 'X'.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    lines = sy-linno .

  endif.


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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.
*
      wa_m_fistb-g_mark = ''.
      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.
      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    lines = sy-linno .

  endif.

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

  MOVE 'REQ1' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'SELALL' to WA_TAB.
  APPEND WA_TAB to TAB.
  MOVE 'DESELALL' to WA_TAB.
  APPEND WA_TAB to TAB.

  data l_blank value ''.

  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
         COLOR COL_HEADING.
  ULINE.


  if flag_s_fundc = 'X'.
*    refresh : s_fundc.
    loop at it_m_fistb into wa_m_fistb.

      lines_index = sy-tabix + 4.

      READ LINE lines_index FIELD VALUE wa_m_fistb-g_mark.

      write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
               wa_m_fistb-bezeich.

      if wa_m_fistb-g_mark <> 'X'.

           if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc.
             ZMM_PREP_ROLEREQ-fundc = 'X'.
           endif.

           if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc2.
            clear ZMM_PREP_ROLEREQ-fundc2.
           endif.

           if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc3.
             clear ZMM_PREP_ROLEREQ-fundc3.
           endif.

           if wa_m_fistb-fictr = ZMM_PREP_ROLEREQ-fundc4.
            clear ZMM_PREP_ROLEREQ-fundc4.
           endif.

      endif.

      modify  it_m_fistb from wa_m_fistb.
      HIDE : wa_m_fistb-g_mark, wa_m_fistb-fictr.
*      CLEAR : wa_m_fistb-g_mark, wa_m_fistb-fictr, wa_m_fistb-bezeich.
    endloop.

    help_list_flag = 'X'.

    lines = sy-linno .

    read table it_m_fistb into wa_m_fistb with key g_mark = 'X'.

    if sy-subrc = 0.

      ZMM_PREP_ROLEREQ-FUNDC = wa_m_fistb-FICTR.

    else.

      clear ZMM_PREP_ROLEREQ-FUNDC .

    endif.

  endif.

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

  perform validations1.

ENDFORM.                    " check_items
*&---------------------------------------------------------------------*
*&      Form  Save_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM Save_request.

  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.

    perform gen_no.

  endif.

  if old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

    g_release = ZMM_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZMM_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZMM_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZMM_PREP_ROLEREQ-req_app1_fl.


    select single * from ZMM_PREP_ROLEREQ
                    where DOCNO = ZMM_PREP_ROLEREQ-docno.

    if ZMM_PREP_ROLEREQ-req_cr_fl is initial.
      ZMM_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZMM_PREP_ROLEREQ-req_app_fl is initial.
      ZMM_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZMM_PREP_ROLEREQ-req_app1_fl is initial.
      ZMM_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZMM_PREP_ROLEREQ-req_app0_fl is initial.
      ZMM_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.

    clear : g_release, g_approve, g_approve0, g_approve1.

    if g_release = 'X' and ( g_approve <> 'X' and
                             g_approve0 <> 'X' and
                             g_approve1 <> 'X' ).

      g_app_rel = 'X'.

    endif.

  endif.

*describe table ist_itemtab lines g_lines_rl.

  if old_ok_code = 'RELEASE' and g_lines_rl = 0.
    message i089(zhelp).
  else.
    perform insert_header.
  endif.

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
            NR_RANGE_NR = '01'
            OBJECT      = 'ZDOCNUMB'
       IMPORTING
            NUMBER      = ZDOCNUMB.
  IF SY-SUBRC <> 0.
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

  ZMM_PREP_ROLEREQ-mandt = sy-mandt.
  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.
    ZMM_PREP_ROLEREQ-docno = ZDOCNUMB.
  endif.

****************************************
  select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
      a~persk a~sbmod  c~designo c~r_p_cd c~version
    d~sdesig_text as designation d~adesig_text as adesignation
    d~DISC_CD as DISC_CD
      into corresponding fields of table ist_data
       from ( ( pa0001 as a inner join pa9930 as c
       on a~pernr = c~pernr ) inner join zdesignation_rev as d
          on c~designo = d~desig_code and
              c~r_p_cd  = d~r_p_cd and
              c~version = d~version )
           where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                 a~sprps = ' ' and
                 a~endda = '99991231' and
                 c~sprps = ' ' and
                 c~endda = '99991231' .

  if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*            ZMM_PREP_ROLEREQ-NAME = ist_data-name.
*            ZMM_PREP_ROLEREQ-DESIGNATION = ist_data-designation.

    ZMM_PREP_ROLEREQ-PERSA = ist_data-werks .
*            select single * from t500p
*                           where persa = ist_data-werks.
*                     if old_ok_code <> 'CROSSCO'.
*                           ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
*                     endif.

  endif.
****************************************


  if ZMM_PREP_ROLEREQ-USERIDCR is initial.

    ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZMM_PREP_ROLEREQ-CR_DATE  = sy-datum.

*      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
*      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

    clear zusrmst.


*       select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-useridcr.
    select single * from usr02 where bname =
                               ZMM_PREP_ROLEREQ-useridcr.


    if sy-subrc ne 0.

    else.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*          ZMM_PREP_ROLEREQ-NAMECR = zusrmst-last_name.
*        endif.

*
      clear ist_data.
      refresh ist_data.

      select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
           a~persk a~sbmod  c~designo c~r_p_cd c~version
         d~sdesig_text as designation d~adesig_text as adesignation
           into corresponding fields of table ist_data
      from ( ( pa0001 as a inner join pa9930 as c
            on a~pernr = c~pernr ) inner join zdesignation_rev as d
               on c~designo = d~desig_code and
                   c~r_p_cd  = d~r_p_cd and
                   c~version = d~version )
                where a~pernr = ZMM_PREP_ROLEREQ-USERIDCR and
                      a~sprps = ' ' and
                      a~endda = '99991231' and
                      c~sprps = ' ' and
                      c~endda = '99991231' .

      if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
        ZMM_PREP_ROLEREQ-NAMECR = ist_data-name.
        ZMM_PREP_ROLEREQ-DESIGCR = ist_data-designation.
      endif.

    endif.

    clear : ist_data.
    refresh : ist_data.

  endif.


  if ZMM_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and
          ( ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
*            or ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'
*            or ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' ).
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
      endif.

      clear zusrmst.

*             select single * from zusrmst where cpfno =
*                                   ZMM_PREP_ROLEREQ-useridap.

      select single * from usr02 where bname =
                            ZMM_PREP_ROLEREQ-useridap.

      if sy-subrc ne 0.

      else.
*                concatenate zusrmst-first_name zusrmst-last_name into
*                zusrmst-last_name.
*                ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.

        clear ist_data.
        refresh ist_data.

        select a~pernr a~begda a~endda a~ename as name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text as designation
                 d~adesig_text as adesignation
             into corresponding fields of table ist_data
             from ( ( pa0001 as a inner join pa9930 as c
       on a~pernr = c~pernr ) inner join zdesignation_rev as d
       on c~designo = d~desig_code and
           c~r_p_cd  = d~r_p_cd and
           c~version = d~version )
        where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*                 select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.
*

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
                 not ZMM_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
            where persa = ist_data-werks.
            if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                where userid = ZMM_PREP_ROLEREQ-USERIDAP.
              if sy-subrc = 0.
              else.
                if g_ccode_crossco = t500p-bukrs.
                else.
                  message e112(zhelp).
                endif.
              endif.
            endif.
          endif.
        else.
          message e110(zhelp).
        endif.

      endif.
*    endif.

  elseif old_ok_code = 'APPROVE' and
          ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
*                and
*                      ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

      if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
      endif.


      select single * from usr02 where bname =
                              ZMM_PREP_ROLEREQ-useridap.
      if sy-subrc ne 0.
*              message e043(zhelp).
      else.

        clear ist_data.
        refresh ist_data.

        select a~pernr a~begda a~endda a~ename as name a~bukrs
                a~werks a~persk a~sbmod  c~designo c~r_p_cd
                c~version d~sdesig_text as designation
                 d~adesig_text as adesignation
                 into corresponding fields of table ist_data
                 from ( ( pa0001 as a inner join pa9930 as c
           on a~pernr = c~pernr ) inner join zdesignation_rev as d
           on c~designo = d~desig_code and
               c~r_p_cd  = d~r_p_cd and
               c~version = d~version )
            where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
                  a~sprps = ' ' and
                  a~endda = '99991231' and
                  c~sprps = ' ' and
                  c~endda = '99991231' .
*
*                select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
             not ZMM_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
                where persa = ist_data-werks.
            if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                   where userid = ZMM_PREP_ROLEREQ-USERIDAP.
              if sy-subrc = 0.
              else.
                message e112(zhelp).
              endif.
            endif.
          endif.
        else.
          message e110(zhelp).
        endif.
      endif.
**13.02.06

    elseif old_ok_code = 'APPROVE' and
*                ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' and
                   ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

        ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
        ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

        if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
           ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
        else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
        endif.


        select single * from usr02 where bname =
                                ZMM_PREP_ROLEREQ-useridap.
        if sy-subrc ne 0.
*              message e043(zhelp).
        else.

          clear ist_data.
          refresh ist_data.

          select a~pernr a~begda a~endda a~ename as name a~bukrs
                  a~werks a~persk a~sbmod  c~designo c~r_p_cd
                  c~version d~sdesig_text as designation
                   d~adesig_text as adesignation
                   into corresponding fields of table ist_data
                   from ( ( pa0001 as a inner join pa9930 as c
             on a~pernr = c~pernr ) inner join zdesignation_rev as d
             on c~designo = d~desig_code and
                 c~r_p_cd  = d~r_p_cd and
                 c~version = d~version )
              where a~pernr = ZMM_PREP_ROLEREQ-USERIDAP and
                    a~sprps = ' ' and
                    a~endda = '99991231' and
                    c~sprps = ' ' and
                    c~endda = '99991231' .
*
*                select single werks from pa0001 into g_persa
*                  where pernr = ZMM_PREP_ROLEREQ-USERIDAP.

          if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            ZMM_PREP_ROLEREQ-NAMEAPP = ist_data-name.
            ZMM_PREP_ROLEREQ-DESIGAP = ist_data-designation.
            if ZMM_PREP_ROLEREQ-PERSA <> ist_data-werks and
               not ZMM_PREP_ROLEREQ-PERSA is initial.
              select single * from t500p
                  where persa = ist_data-werks.
              if ZMM_PREP_ROLEREQ-ccode = t500p-bukrs.
              else.
                select single * from zmm_prep_ex_app
                     where userid = ZMM_PREP_ROLEREQ-USERIDAP.
                if sy-subrc = 0.
                else.
* Check for L1 inserted  26/12/2006
                  if g_user = 'L1'.
                  else.
                    message e112(zhelp).
                  endif.
                endif.
              endif.
            endif.
          else.
            message e110(zhelp).
          endif.
        endif.
      endif.
**13.02.06
    endif.
*endif.
**12.06.06 vivek begin

if not ZMM_PREP_ROLEREQ-USERIDAP is initial and
     old_ok_code = 'APPROVE' and
              ( ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' or
                   ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
                   ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X' ).

** inserted to modify approval data
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE = sy-datum.

     if ZMM_PREP_ROLEREQ-STATUS = 'IC' or
         ZMM_PREP_ROLEREQ-STATUS = 'IR'.
         ZMM_PREP_ROLEREQ-STATUS   = 'IF'.
     else.
         ZMM_PREP_ROLEREQ-STATUS   = 'N'.
     endif.
**12.06.06 vivek end
endif.
*****************************
  data l_fundc_no like sy-index.
  clear l_fundc_no.
  loop at it_m_fistb into wa_m_fistb.
    if wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      case l_fundc_no.
        when 2.
          ZMM_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZMM_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZMM_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      endcase.
    endif.
  endloop.
*****************************

*****
  if g_fundc_err_flag <> 'X'.

    if old_ok_code = 'DISPLAY' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
      g_comm_fl = 'X'.
      if g_lines_2 <> 0.
        clear ZMM_PREP_ROLEREQ-comm_fl.
        clear g_lines_2.
** Status New changed to IF
        ZMM_PREP_ROLEREQ-status = 'IF'.
      endif.
    endif.

    if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
** Status New changed to IR
      ZMM_PREP_ROLEREQ-status = 'IR'.
      clear ZMM_PREP_ROLEREQ-comm_fl.
    endif.

    if old_ok_code = 'CROSSCO'.
      ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    endif.

    if old_ok_code = 'CRCROLES'.
      ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    endif.

    if ZMM_PREP_ROLEREQ-CCODE is initial.
      message e142(zhelp).
    endif.

**** CAB_AJIT 19/10/2006
    if ( old_ok_code = 'DISPLAY' and attach_fl = 'X' and
         ZMM_PREP_ROLEREQ-status = 'IR' ).
         ZMM_PREP_ROLEREQ-status = 'IF'.
         status_ir_fl = 'X'.
    endif.

    modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    if sy-subrc = 0.

      if g_app_rel = 'X'.

        clear g_app_rel.

      elseif
**** CAB_AJIT 19/10/2006
      ( old_ok_code = 'DISPLAY' and attach_fl = 'X' and
        status_ir_fl = 'X' ).
        clear : attach_fl, status_ir_fl.
        perform popup_approve_message.
      elseif
      ( old_ok_code = 'DISPLAY' and ZMM_PREP_ROLEREQ-comm_fl = 'X' )
      or ( old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-comm_fl = 'X' ).
**** CAB_AJIT 19/10/2006
        perform popup_approve_message.
      else.

        g_approver_level = 'L3'.

        Perform insert_items.

      endif.

*      Perform items_approval_check.
*
      set parameter id 'ZREQNO' field zmm_prep_rolereq-docno.

****Saving the long text.                              *****

      IF ( old_ok_code = 'CREATE' ) or
      ( old_ok_code = 'CROSSCO' ) or ( OLD_OK_CODE = 'CHANGE' )
          or ( OLD_OK_CODE = 'CRCROLES' )
          or ( OLD_OK_CODE = 'RELEASE' )
          or ( OLD_OK_CODE = 'APPROVE' ).

        perform save_cors_text.
      elseif g_comm_fl = 'X'.
        perform save_cors_text.
        clear g_comm_fl.
      ENDIF.

      perform clear.
      perform unlock_record.
      if g_reset_fl = 'X'.
        clear g_reset_fl.
        clear set_disc_mm_flag.
        clear g_hd_copied.
        old_ok_code = 'CHANGE'.
        ZMM_PREP_ROLEREQ-docno = g_docno.
      endif.
*      zmm_prep_rolereq-crc_fl = g_crc_fl.
*      clear g_crc_fl.
      call screen 100.

    endif.

*****
  else.

    clear g_fundc_err_flag.
    call screen 120 STARTING AT 10 5
                      ENDING   AT 90 15.
    clear okcode_100.

  endif.

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

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABCTRL100_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

*    if old_ok_code = 'CREATE'.
*    elseif old_ok_code <> 'DISPLAY'.
*       delete from ZMM_PREP_ROLEREI where
*       docno = ZMM_PREP_ROLEREQ-docno.
*    endif.

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.

*    Perform check_items_save.

    if old_ok_code = 'CREATE' or
       old_ok_code = 'CROSSCO' or
       old_ok_code = 'CRCROLES'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    wa_itemtab-mandt = sy-mandt.
    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

    Perform check_items_save.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      delete from ZMM_PREP_ROLEREQ
            where docno = ZMM_PREP_ROLEREQ-docno.
      delete from ZMM_PREP_ROLEREI
            where docno = ZMM_PREP_ROLEREQ-docno.
      if sy-subrc = 0.
        set cursor field 'ZMM_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZMM_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZMM_PREP_ROLEREQ-docno.
    else.
      rollback work.
    endif.
  else.
    if old_ok_code = 'RELEASE' and g_lines_rl = 0.
      rollback work.
      message i089(zhelp).
    else.

      if old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO'
.
      elseif old_ok_code <> 'DISPLAY'.
        delete from ZMM_PREP_ROLEREI where
        docno = ZMM_PREP_ROLEREQ-docno.
      endif.

      modify ZMM_PREP_ROLEREI from table ist_itemtab.

      if sy-subrc = 0.
        perform clear1.
        if old_ok_code = 'CROSSCO' or
              ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.

              if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CROSSCO' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.

               if old_ok_code = 'APPROVE' or
                  ZMM_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.

               perform pop_up_crossco_message.          .
*          message i113(zhelp) with ZMM_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.

          else.
            if old_ok_code = 'CRCROLES' or
              ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
               if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CRCROLES' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.
               if old_ok_code = 'APPROVE' or
                  ZMM_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.
               perform pop_up_crc_message.
*              message i119(zhelp) with ZMM_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
               g_crc_fl = 'X'.
            else.
              if old_ok_code = 'RELEASE'.
                perform popup_release_message.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'APPROVE'.
.               perform popup_approve_message.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'CREATE' or old_ok_code = 'CHANGE'..
                perform popup_release_message1.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              elseif ZMM_PREP_ROLEREQ-status = 'IF'.
                perform popup_approve_message.
              else.
                message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
              endif.
            endif.
        endif.
      endif.

    endif.

  endif.

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

  Data l_choice1.
  clear l_choice1.

  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CHANGE' or
     old_ok_code = 'DELETE' or
     old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

" Begin of <RD1K960036>.
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

DATA : l_get2(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'EXIT '
    TEXT_QUESTION               = 'Data will be lost, Want to quit? '
   DEFAULT_BUTTON              = '2'
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
           MOVE 'J' TO l_choice1.
           WHEN '2'.
             MOVE 'N' TO l_choice1.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.


    If l_choice1 = 'J'.
      clear l_choice1.
      perform clear.
      perform unlock_record.
      call screen 100.
    else.
    ENDIF.

  else.

    perform clear.
    perform unlock_record.
    call screen 100.

  endif.


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

  perform clear.

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

  CALL FUNCTION 'DEQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno.

  clear g_lock.

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

  perform destroy_ctrl.

  clear   : old_ok_code, okcode_100, err_flg.
  refresh : g_TABCTRL100_itab.
  clear   : g_TABCTRL100_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear   : zmm_prep_rolerei, zmm_prep_rolereq.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.

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

  call method gv_text_editor1->set_readonly_mode
             exporting
                  readonly_mode = gv_text_editor1->true
             exceptions
                  error_cntl_call_method = 1
                  invalid_parameter      = 2
                  others                 = 3.

  if ( old_ok_code = 'CREATE' )
   or ( old_ok_code = 'CROSSCO' )
   or ( old_ok_code = 'CRCROLES' )
   or ( old_ok_code = 'CHANGE' )
   or ( old_ok_code = 'RELEASE' )
   or ( OLD_OK_CODE = 'APPROVE' )
  or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
 .

    call method gv_text_editor2->set_readonly_mode
         exporting
              readonly_mode = gv_text_editor2->false
         exceptions
              error_cntl_call_method = 1
              invalid_parameter      = 2
              others                 = 3.

  endif.

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

  Refresh: tlinetab1, g_linefrto_itab.
  If old_ok_code <> 'CREATE' or
     old_ok_code = 'CROSSCO' .
    append lines of lines_cors to tlinetab1[].
  Endif.
*
  loop at tlinetab1[] into g_line132.
    if ( g_line132+0(7) = '* Reply' ) or
       ( g_line132+0(7) = '**Reply' ).
      g_linefrto-line_fr = sy-tabix.
      g_linefrto-line_to = sy-tabix.
      append g_linefrto to g_linefrto_itab.
      clear: g_linefrto.
    endif.
  endloop.
*
  call function 'CONVERT_ITF_TO_STREAM_TEXT'
       TABLES
            itf_text    = tlinetab1[]
            text_stream = lt_text_table1.

  call method gv_text_editor1->set_text_as_stream
       exporting
            text = lt_text_table1
       exceptions
            error_dp        = 1
            error_dp_create = 2
            others          = 3.
********************highlight**************************************
  clear g_linefrto.
  loop at g_linefrto_itab into g_linefrto.
    call method gv_text_editor1->HIGHLIGHT_LINES
       exporting
            FROM_LINE = g_linefrto-line_fr
            TO_LINE   = g_linefrto-line_to
            HIGHLIGHT_MODE = 1.
  endloop.
********************************************************************

  if ( old_ok_code = 'CREATE' )
   or ( old_ok_code = 'CROSSCO' )
   or ( old_ok_code = 'CRCROLES' )
   or ( old_ok_code = 'CHANGE' )
   or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
 .
    call function 'CONVERT_ITF_TO_STREAM_TEXT'
         TABLES
              itf_text    = tlinetab2
              text_stream = lt_text_table2.

    call method gv_text_editor2->set_text_as_stream
         exporting
              text = lt_text_table2
         exceptions
              error_dp        = 1
              error_dp_create = 2
              others          = 3.
  endif.

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

  Data: l_theader like thead.
  Data: l_datech(10) type c.
***********Assignments***********************
  Clear l_theader.
  l_theader-tdobject   = 'ZHELP'.
  l_theader-tdid       = '0001'.
  l_theader-tdspras    =  sy-langu.
  l_theader-tdlinesize =  72.
  move zmm_prep_rolereq-docno to l_theader-tdname.
  Append lines of TLINETAB2 to TLINETAB1.
*********************************************
  IF NOT TLINETAB1[] IS INITIAL.
    clear g_cores_sender.
    Concatenate sy-datum+6(2) '/'
                sy-datum+4(2) '/'
                sy-datum+0(4) into l_datech.
    Concatenate '**Reply' l_datech sy-uname into g_cores_sender
     separated by '          '.
    if NOT TLINETAB2[] IS INITIAL.
      append g_cores_sender to tlinetab1.
    endif.
    clear g_cores_sender.
    CALL FUNCTION 'SAVE_TEXT'
         EXPORTING
              CLIENT          = SY-MANDT
              HEADER          = l_theader
              SAVEMODE_DIRECT = 'X'
         TABLES
              LINES           = TLINETAB1
         EXCEPTIONS
              ID              = 1
              LANGUAGE        = 2
              NAME            = 3
              OBJECT          = 4
              OTHERS          = 5.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  clear g_user.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'L1'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'DI'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                     ID 'FRGCO' FIELD : 'CS'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'MD'.

  if sy-subrc = 0.
    g_user = 'L1'.
    check 1 = 2.
  Endif.


  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'IM'.

  if sy-subrc = 0.
    g_user = 'IM'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'FRGCO' FIELD : 'L2'. "#EC *

  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  Endif.

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

  if old_ok_code = 'APPROVE'.

     if g_user = 'L1' or
        g_user = 'IM' or
        g_user = 'L3'.
     else.
        message i131(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

     if g_user = 'L1' and
        ( zmm_prep_rolereq-req_app0_fl = 'X' or
          zmm_prep_rolereq-req_app_fl = 'X' ).
        message i132(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

  endif.

  if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.

    if  ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    else.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
              TEXTLINE1  = 'Not authorised to use this document- not yours '.
*                     message i046(zhelp).
      perform clear.
      call screen 100.
    endif.

  endif.

  if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.

    if zmm_prep_rolereq-status = 'IF' or
          zmm_prep_rolereq-status = 'PC' or
          zmm_prep_rolereq-status = 'C'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request under process / completed can''t change/reset'.

*                message e065(zhelp).
      perform clear.
      call screen 100.

    else.
      g_reset_fl = ZMM_PREP_ROLEREQ-REQ_CR_FL.
      g_docno = ZMM_PREP_ROLEREQ-docno.
      perform verify.
  endif.
  endif.

  if old_ok_code = 'APPROVE' and
                    ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    if g_user = 'IM' or g_user = 'L1'.
    else.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'This requires approval of I/C MM'.

*               message e048(zhelp).
      perform clear.
      call screen 100.
    endif.
  endif.

  if old_ok_code = 'RELEASE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1 = 'Request already released by creator'.

*          message e053(zhelp).
    perform clear.
    call screen 100.

  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.

*                   message e051(zhelp).
      perform clear.
      call screen 100.

    endif.

    if ( g_user = 'IM' or g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.
*                   message e051(zhelp)..
      perform clear.
      call screen 100.

    endif.


*    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request already approved'.
*
**                   message e049(zhelp).
*      perform clear.
*      call screen 100.
*
*    endif.
*
*    if ( g_user = 'IM' or g_user = 'L3' ) and
*                          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request already approved by L3/IM'.
*
**                   message e050(zhelp)..

      if  ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request already approved'.

      perform clear.
      call screen 100.

    endif.

  endif.

  if ( ZMM_PREP_ROLEREQ-status = 'IF' or
      ZMM_PREP_ROLEREQ-status  = 'C' )
      and old_ok_code <> 'DISPLAY'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
       EXPORTING
              TEXTLINE1   = 'Request can not  be  changed, Can only be displayed'.

*              message e079(zhelp).
*               perform clear.
    old_ok_code = 'DISPLAY'.
    call screen 100.

  endif.

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

  data : l_docno like zmm_prep_rolereq-docno.

  SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE FISTL = ZMM_PREP_ROLEREQ-FUNDC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  if sy-subrc <> 0.
     message i166(zhelp).
     g_error_fundc = 'X'.
     call screen 100.
  endif.

  if old_ok_code = 'CHANGE' or
     old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

     select single docno from zmm_prep_rolereq
                     into l_docno where docno = zmm_prep_rolereq-docno.

     if sy-subrc <> 0.
       message i167(zhelp).
       g_error_fundc = 'X'.
       call screen 100.
     endif.

  endif.

  if g_val_err = 'X'.
     clear g_val_err.
     message i118(zhelp).
     call screen 100.
  endif.

  if ZMM_PREP_ROLEREI-rej_fl = ''.


    if old_ok_code = 'APPROVE' and
                      ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
      if g_user = 'IM' or g_user = 'L1'.
      else.
        message e048(zhelp).
      endif.
    endif.

  endif.

  perform check_tel.

ENDFORM.                    " validations1


*---------------------------------------------------------------------*
*       FORM destroy_ctrl                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM destroy_ctrl.

  if not flag2 is initial.
    clear : flag2, flag1.
    call method gv_text_editor1->free.
    call method gv_text_editor2->free.
  endif.

  if not flag1 is initial.
    clear flag1.
    call method gv_text_editor1->free.
  endif.

  clear:gv_text_editor1,gv_text_editor2.

  perform unlock_record.

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

    data : l_choice.
" Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to delete the Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice.

    DATA : l_get3(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
*       TITLEBAR                    = ' '
        TEXT_QUESTION               = 'Are you sure, you want to delete the Document? '
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

If l_choice = 'J'.
      clear l_choice.

**************************************

  ZMM_PREP_ROLEREQ-mandt = sy-mandt.

  delete ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

  if sy-subrc = 0.

    Perform delete_items.


    if zmm_prep_rolereq-long_text_fl <> ''.
      perform delete_cors_text.
    endif.

    perform clear.
    perform unlock_record.
    call screen 100.

  else.

    message i057(zhelp) with ZMM_PREP_ROLEREQ-docno.

  endif.

else.

endif.

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

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.
    wa_itemtab-mandt = sy-mandt.
    append wa_itemtab to ist_itemtab.

  endloop.

  delete ZMM_PREP_ROLEREI from table ist_itemtab.

  if sy-subrc = 0.
    message i120(zhelp) with ZMM_PREP_ROLEREQ-docno.
  endif.

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

  data : l_name like thead-tdname.

  l_name = zmm_prep_rolereq-docno.

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      CLIENT                = SY-MANDT
      ID                    = '0001'
      LANGUAGE              = sy-langu
      NAME                  = l_name
      OBJECT                = 'ZHELP'
*     SAVEMODE_DIRECT       = ' '
*     TEXTMEMORY_ONLY       = ' '
*     LOCAL_CAT             = ' '
   EXCEPTIONS
     NOT_FOUND             = 1
     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  Data l_choice.
  clear l_choice.

" Begin of <RD1K960036>.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be cancelled? '
*           TITEL          = 'RESET'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.
  DATA : l_get4(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'RESET '
      TEXT_QUESTION               = 'Request already released Flags will be cancelled? '
     DEFAULT_BUTTON              = '2'
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

  If l_choice = 'J'.

    clear zmm_prep_rolereq-req_cr_fl.
    clear zmm_prep_rolereq-req_app_fl.
    clear zmm_prep_rolereq-req_app0_fl.
    clear zmm_prep_rolereq-req_app1_fl.
    zmm_prep_rolereq-status = 'IC'.
    perform save_request.
**20/03/2006
    g_app_rel = 'X'.
    clear l_choice.

  else.

    perform clear.
    perform unlock_record.
    call screen 100.

  endif.

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
  if old_ok_code <> 'DISPLAY' .

   if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.

       if zmm_prep_rolecrc-plant = 'X' and
           wa_itemtab-plant is initial.
          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-p_grp = 'X' and
           wa_itemtab-grp is initial.
          g_field = 'ZMM_PREP_ROLEREI-P_GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-app_level = 'X' and
          wa_itemtab-approver is initial.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

    endif.

   else.

    select single * from zmm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zmm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-p_grp = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE'  or
                    old_ok_code = 'CREATE'  or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-grp is initial.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-s_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sloc is initial.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-r_loc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-receipt_loc is initial.
          g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
          rollback work.
          message i095(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zmm_prep_roledes-app_level = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-approver is initial.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

    endif.

   endif.

  endif.
  if wa_itemtab-rej_fl is initial.
    perform validate_role_approval_level.
  endif.
  perform validate_lineitem_datax.
  Perform items_approval_check.
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

  data : l_choice.
  clear l_choice.
" Begin of <RD1K960036>.
*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*               TEXTLINE1      = 'If u cancel release, u can change data else go in display mode'
*               TEXTLINE2      = '& just do correspondence without cancelling release'
*           TITEL          = 'Do you want to cancel release?'
*           START_COLUMN   = 25
*           START_ROW      = 6
*           CANCEL_DISPLAY = ''
*           DEFAULTOPTION = 'N'
*      IMPORTING
*           ANSWER         = l_choice.

DATA : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Do you want to cancel release?'
    TEXT_QUESTION               = 'If u cancel release, u can change data else go in display mode '
                                  &'& just do correspondence without cancelling release.'

   DEFAULT_BUTTON              = '2'
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1k960036>.

  If l_choice = 'J'.

    old_ok_code = 'CHANGE'.
    clear l_choice.

  else.

    old_ok_code = 'DISPLAY'.
    clear l_choice.

  endif.

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

  if    ( ( old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
         old_ok_code = 'DELETE'
         or old_ok_code = 'RELEASE' or OLD_OK_CODE = 'APPROVE' )
         and g_hd_copied = 'X' )
         or ( old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' ).
    data : tel_len type i.
    tel_len = strlen( ZMM_PREP_ROLEREQ-TELNO ).
    if  ZMM_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
      message i097(zhelp).
      call screen 100.
    Else.
      if tel_len < 7.
        message i098(zhelp).
        call screen 100.
      Endif.
    Endif.
  endif.
ENDFORM.                    " check_tel
*&---------------------------------------------------------------------*
*&      Form  attach_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_file.

  data: "lv_cancelled like sonv-flag,   " Flag: Upload was cancelled
        l_action    type i,            " Benutzeraktion
        l_rc        type i,            " Anzahl gefundener Dateinamen
        l_filetab   type filetable,    " Tabelle mit Dateinamen
        l_filename  like gv_filename,
        l_filenam0  like gv_filename,
        l_mode(10),
        l_length type i,
        l_tab_len type i,
        l_asc_type(1).
*   Upload des Files
  clear: gt_cont[], gt_contx[], l_tab_len.
  if sy-saprl gt '4.6D'. "Methode hat sich veraendert
    clear l_filetab[].
    call method cl_gui_frontend_services=>file_open_dialog
*          exporting default_filename        = l_filename
*                    default_extension       = 'rtf'
*                    file_filter             = '*.rtf'       "#EC NOTEXT
*                    file_filter             = '(*.*)|*.*|'  "#EC NOTEXT
*                    initial_directory       = 'C:\TEMP'     "#EC NOTEXT
*                    multiselection          = abap_false
*                    window_title            = i_title
        changing   file_table              = l_filetab
                   rc                      = l_rc
                   user_action             = l_action
        exceptions file_open_dialog_failed = 1
                   cntl_error              = 2
                   error_no_gui            = 3
                   others                  = 4.

    if l_action = cl_gui_frontend_services=>action_cancel.
*   The user pressed the cancel button (in windows)
      message s076(zhelp).
      leave screen.
    endif.
  else.
    clear l_filetab[].
    call method cl_gui_frontend_services=>file_open_dialog
*          exporting default_filename        = l_filename
*                    default_extension       = 'rtf'
*                    file_filter             = '*.rtf'       "#EC NOTEXT
*                    file_filter             = '(*.*)|*.*|'  "#EC NOTEXT
*                    initial_directory       = 'C:\TEMP'     "#EC NOTEXT
*                    multiselection          = abap_false
*                    window_title            = i_title
        changing   file_table              = l_filetab
                   rc                      = l_rc
*                    user_action             = l_action
        exceptions file_open_dialog_failed = 1
                   cntl_error              = 2
*                    error_no_gui            = 3
                   others                  = 4.

*     if l_action = cl_gui_frontend_services=>action_cancel.
    if l_rc ne 0.
*   The user pressed the cancel button (in windows)
      message s076(zhelp).
      leave screen.
    endif.
  endif.
  if sy-subrc = 0 and l_rc > 0.       " Anzahl gefundener Dateinamen
    read table l_filetab index 1 into gv_filename.
    move gv_filename to l_filenam0.
    while l_filenam0 ca '\'.
      shift l_filenam0 up to '\'.
      shift l_filenam0.
    endwhile.
    move l_filenam0 to l_filename.
    if l_filename na '.'.
      clear l_filename.
    else.
      while l_filename ca '.'.
        shift l_filename up to '.'.
        shift l_filename.
      endwhile.
    endif.
    move l_filename to gv_filetype.
    translate l_filename to upper case.
    if l_filename eq 'TXT'
      or l_filename eq 'HTM'.
*      or l_filename eq 'HTM'
*      or l_filename eq 'RTF'.
      move 'ASC' to l_mode.
*      move gv_filename to gv_filn.
*      move l_mode to l_filetype.
      call function 'GUI_UPLOAD'
           EXPORTING
                filename   = gv_filename
                filetype   = l_mode
           IMPORTING
                filelength = l_length
           TABLES
                data_tab   = gt_cont
           EXCEPTIONS
                others     = 1.
      if sy-subrc ne 0.
        message s077(zhelp) with 'Upload'(006).
        leave screen.
      else.
        describe table gt_cont lines l_tab_len.
      endif.
    else.
      move 'BIN' to l_mode.
*      move gv_filename to gv_filn.
*      move l_mode to l_filetype.
      call function 'GUI_UPLOAD'
           EXPORTING
                filename   = gv_filename
                filetype   = l_mode
           IMPORTING
                filelength = l_length
           TABLES
                data_tab   = gt_contx
           EXCEPTIONS
                others     = 1.
      if sy-subrc ne 0.
        message s077(zhelp) with 'Upload'(006).
        leave screen.
      else.
        describe table gt_contx lines l_tab_len.
      endif.
    endif.
    if l_tab_len eq 0.
      message s106(zhelp).
      leave screen.
    endif.
  else.
    message s077(zhelp) with 'Upload'(006).
    leave screen.
  endif.
  gs_win_head-doc_length = l_length.
  move cs_x to g_apx_exist.
  add 1 to g_apx_cnt.
  get time stamp field gt_ac_apx-timestamp.
  gt_ac_apx-descr = l_filenam0.
  gt_ac_apx-appxno = g_apx_cnt.
  gt_ac_apx-filetyp = gv_filetype.
  translate gt_ac_apx-filetyp to upper case.
  gt_ac_apx-filenam = l_filenam0.
  gt_ac_apx-filelen = gs_win_head-doc_length.
  gt_ac_apx-last_usr = sy-uname.
  if l_mode = 'ASC'.
    gt_ac_apx-filefm_ul = 'ASC'.
    gt_ac_apx-firstl = g_apx_ptr.
    clear gt_cont.
    loop at gt_cont.
      move gt_cont to gt_ac_cont.
      append gt_ac_cont.
      add 1 to g_apx_ptr.
    endloop.
    gt_ac_apx-lastl = g_apx_ptr - 1.
  else.
    gt_ac_apx-filefm_ul = 'BIN'.
    gt_ac_apx-firstl = g_apx_bin_ptr.
    clear: gt_contx.
    loop at gt_contx.
      move gt_contx to gt_ac_contx.
      append gt_ac_contx.
      add 1 to g_apx_bin_ptr.
    endloop.
    gt_ac_apx-lastl = g_apx_bin_ptr - 1.
  endif.
  append gt_ac_apx.

  perform download_appendix.

endform.                    " load_appendix
*&---------------------------------------------------------------------*
*&      Form  delete_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form delete_appendix .
  clear gt_view_apx.
  loop at gt_view_apx where selc eq cs_x.
    read table gt_ac_apx with key appxno = gt_view_apx-appxno.
    if sy-subrc eq 0.
      delete gt_ac_apx index sy-tabix.
    endif.
  endloop.
endform.                    " delete_appendix
*&---------------------------------------------------------------------*
*&      Form  download_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form download_appendix .
  clear gt_view_apx.
  loop at gt_view_apx where selc eq cs_x.
    read table gt_ac_apx with key appxno = gt_view_apx-appxno.
    if sy-subrc eq 0.
* move daten und Start download
      perform save_appendix using gt_ac_apx.
    endif.
  endloop.
ENDFORM.                    " attach_file
*&---------------------------------------------------------------------*
*&      Form  save_appendix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_AC_APX  text
*----------------------------------------------------------------------*
FORM save_appendix USING    Ps_AC_APX structure bcos_appx.
  data: l_action    type i,            " Benutzeraktion
          l_filetype   type string,
          l_mode(10),
          l_filename  like gv_filename,
          l_path type string,
*        ll_filenam like RLGRAP-FILENAME,
*        ll_FILETYP LIKE  RLGRAP-FILETYPE,
          ll_len type i.
  "lv_cancelled like sonv-flag,   " Flag: Upload was cancelled
  "l_rc        type i,            " Anzahl gefundener Dateinamen
  "l_length type i.

* Schaufeln der Anhangsinformationen incl. Datei in ac-Tabellen
  if Ps_AC_APX-filefm_ul eq 'ASC'.
    clear: gt_cont, gt_cont[].
    loop at gt_ac_cont from Ps_AC_APX-firstl to Ps_AC_APX-lastl.
      move gt_ac_cont to gt_cont.
      append gt_cont.
    endloop.
  else.
    clear: gt_contx, gt_contx[].
    loop at gt_ac_contx from Ps_AC_APX-firstl to Ps_AC_APX-lastl.
      move gt_ac_contx to gt_contx.
      append gt_contx.
    endloop.
**cab_ajit
*** Macros for OBJCONT conversion
    field-symbols: <ptr_text> type soli, "#EC *
                    <ptr_x>      type any, "#EC *
                   <ptr_hex> type solix.

    data wa_soli type soli.
    data wa_solix type solix.

    define hex_to_cont.
*   &1 Table of structure SOLIX
*   &2 Table of structure SOLI
      refresh &2.
      loop at &1 into wa_solix.
        clear wa_soli.
        assign wa_soli to <ptr_hex> casting.
        move wa_solix to <ptr_hex>.
        append wa_soli to &2.
      endloop.
    end-of-definition.

**
    hex_to_cont gt_contx gt_cont.
  endif.
  l_filetype = Ps_AC_APX-filetyp.
  gv_filename = Ps_AC_APX-filenam.
*   Upload des Files
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
     EXPORTING
*        WINDOW_TITLE      =
         DEFAULT_EXTENSION = l_filetype
         DEFAULT_FILE_NAME = gv_filename
*        FILE_FILTER       =
*        INITIAL_DIRECTORY =
    CHANGING
         FILENAME          = gv_filename
         PATH              = l_path
         FULLPATH          = l_filename
         USER_ACTION       = l_action
    EXCEPTIONS
         CNTL_ERROR        = 1
         ERROR_NO_GUI      = 2
         others            = 3
          .
  IF SY-SUBRC <> 0.
    message s076(zhelp).
    leave screen.
  elseif l_action = cl_gui_frontend_services=>action_cancel.
*   The user pressed the cancel button (in windows)
    message s076(zhelp).
    leave screen.
  endif.
  if sy-subrc = 0.
    move Ps_AC_APX-filefm_ul to l_mode.
*    move l_filename to gv_filn.
*    move l_mode to gv_filetype.
    if l_mode eq 'ASC'.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
*       BIN_FILESIZE                  =
          FILENAME                      = l_filename
          FILETYPE                      = l_mode
*       APPEND                        = ' '
*       WRITE_FIELD_SEPARATOR         = ' '
*       HEADER                        = '00'
*       TRUNC_TRAILING_BLANKS         = ' '
*       WRITE_LF                      = 'X'
*       COL_SELECT                    = ' '
*       COL_SELECT_MASK               = ' '
*     IMPORTING
*       FILELENGTH                    =
        TABLES
*       DATA_TAB                      = gt_contx
          DATA_TAB                      = gt_cont
        EXCEPTIONS
          FILE_WRITE_ERROR              = 1
          NO_BATCH                      = 2
          GUI_REFUSE_FILETRANSFER       = 3
          INVALID_TYPE                  = 4
          NO_AUTHORITY                  = 5
          UNKNOWN_ERROR                 = 6
          HEADER_NOT_ALLOWED            = 7
          SEPARATOR_NOT_ALLOWED         = 8
          FILESIZE_NOT_ALLOWED          = 9
          HEADER_TOO_LONG               = 10
          DP_ERROR_CREATE               = 11
          DP_ERROR_SEND                 = 12
          DP_ERROR_WRITE                = 13
          UNKNOWN_DP_ERROR              = 14
          ACCESS_DENIED                 = 15
          DP_OUT_OF_MEMORY              = 16
          DISK_FULL                     = 17
          DP_TIMEOUT                    = 18
          FILE_NOT_FOUND                = 19
          DATAPROVIDER_EXCEPTION        = 20
          CONTROL_FLUSH_ERROR           = 21
          OTHERS                        = 22
                .
    else.
      ll_len = Ps_AC_APX-fILELEN.
*      move l_filename to gv_filn.
*      move l_mode to gv_filetype.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          BIN_FILESIZE                  = ll_len
          FILENAME                      = l_filename
          FILETYPE                      = l_mode
*       APPEND                        = ' '
*       WRITE_FIELD_SEPARATOR         = ' '
*       HEADER                        = '00'
*       TRUNC_TRAILING_BLANKS         = ' '
*       WRITE_LF                      = 'X'
*       COL_SELECT                    = ' '
*       COL_SELECT_MASK               = ' '
*     IMPORTING
*       FILELENGTH                    =
        TABLES
          DATA_TAB                      = gt_contx
*       DATA_TAB                      = gt_cont
        EXCEPTIONS
          FILE_WRITE_ERROR              = 1
          NO_BATCH                      = 2
          GUI_REFUSE_FILETRANSFER       = 3
          INVALID_TYPE                  = 4
          NO_AUTHORITY                  = 5
          UNKNOWN_ERROR                 = 6
          HEADER_NOT_ALLOWED            = 7
          SEPARATOR_NOT_ALLOWED         = 8
          FILESIZE_NOT_ALLOWED          = 9
          HEADER_TOO_LONG               = 10
          DP_ERROR_CREATE               = 11
          DP_ERROR_SEND                 = 12
          DP_ERROR_WRITE                = 13
          UNKNOWN_DP_ERROR              = 14
          ACCESS_DENIED                 = 15
          DP_OUT_OF_MEMORY              = 16
          DISK_FULL                     = 17
          DP_TIMEOUT                    = 18
          FILE_NOT_FOUND                = 19
          DATAPROVIDER_EXCEPTION        = 20
          CONTROL_FLUSH_ERROR           = 21
          OTHERS                        = 22
                .

    endif.
    IF SY-SUBRC <> 0.
      message s077(zhelp) with 'Download'(007).
      leave screen.
    ENDIF.
  ENDIF.

ENDFORM.                    " save_appendix

*---------------------------------------------------------------------*
*       FORM attachment_list_get                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form attachment_list_get.
  if g_attachments_read is initial.
*    if g_header_data-enccnt > 0.
*      clear g_attachments. clear g_attachments[].
    call function 'SO_ATTACHMENT_LIST_READ'
         EXPORTING
              object_id = g_object_id
         TABLES
              objects   = g_attachments
         EXCEPTIONS
              others    = 1.
    if sy-subrc = 0.
      g_attachments_read = on.
    endif.
  endif.
*  endif.

endform.                    " ATTACHMENT_LIST_GET
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZMM_PREP_ROLEREQ-userid into cpf_lfb1.

select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
             a~persk a~sbmod  c~designo c~r_p_cd c~version
           d~sdesig_text as designation d~adesig_text as adesignation
           d~DISC_CD as DISC_CD
             into corresponding fields of table ist_data
        from ( ( pa0001 as a inner join pa9930 as c
              on a~pernr = c~pernr ) inner join zdesignation_rev as d
                 on c~designo = d~desig_code and
                     c~r_p_cd  = d~r_p_cd and
                     c~version = d~version )
                  where a~pernr = ZMM_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*          read table ist_data index 1.
          read table ist_data index 1.    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
            G_CCODE = ist_data-bukrs.
        endif.


*  SELECT single *
*         FROM pa0027
*         INTO wa_pa0027
*         WHERE pernr = cpf_lfb1 AND
*               endda = '99991231' AND
*               sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*  G_CCODE = wa_pa0027-kbu01+0(3).

  else.

  G_CCODE = ZMM_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc <> 0.
       rollback work.
       message e117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    g_TABCTRL100_wa-role_name.
    if sy-subrc <> 0.
       rollback work.
       message e118(zhelp).
    endif.

  endif.

*elseif g_e_fl = 'X'.
*       clear g_e_fl.
*  else.
*  clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
*  clear  ZMM_PREP_ROLEREI-SLOC.
*  clear  ZMM_PREP_ROLEREI-plant.
*  clear  ZMM_PREP_ROLEREI-grp.
*  clear  ZMM_PREP_ROLEREI-approver.
*
*  clear g_read_fl.
*
*endif.

*if g_role_name_flag = 'X'.
*     clear g_role_name_flag.
*     clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
*      clear  ZMM_PREP_ROLEREI-SLOC.
*      clear  ZMM_PREP_ROLEREI-plant.
*      clear  ZMM_PREP_ROLEREI-grp.
*      clear  ZMM_PREP_ROLEREI-approver.
*endif.
*
*
*g_field = 'ZMM_PREP_ROLEREI-PLANT'.

*g_i = g_i + 1.
*
*l_role_name = ZMM_PREP_ROLEREI-role_name.
*
**********************************************************

if old_ok_code <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZMM_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           rollback work.
           message e081(zhelp) with g_TABCTRL100_wa-role_name.
         endif.

   endif.

 endif.

*  endif.

  if not g_TABCTRL100_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = g_TABCTRL100_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZMM_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABCTRL100_wa-role_name.

      endif.

   endif.


************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
*  IF G_CCODE = 'JOR'.
  IF G_CCODE = 'DVP'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF G_CCODE = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
    g_select = 'V%'.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024_1 where (it_cond).
    refresh it_cond.
    append lines of it_t024_1 to it_t024.
    refresh it_t024_1.

  ENDIF.
*
  if G_CCODE <> 'KKL'.
    refresh it_cond.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
  endif.

  if g_select_flag <> 'X'.
    select * from t024 into table it_t024 where
            ( ekgrp not between 'A' and 'EZZ' ) and
            ( ekgrp not between 'K' and 'MZZ' ) and
            ( ekgrp not between 'G' and 'GZZ' ) and
            ( ekgrp not between 'R' and 'TZZ' ) and
            ( ekgrp not between 'V' and 'WZZ' ).
  endif.


 if  g_TABCTRL100_wa-role_name = 'M6' or
     g_TABCTRL100_wa-role_name = 'M7' or
     g_TABCTRL100_wa-role_name = 'M8'.

 else.

      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

            loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) between '0' and 'A'.
                delete it_t024.
              endif.

          endloop.


      else.

          loop at it_t024 into wa_t024.

             l_ekgrp = wa_t024-ekgrp.

              if l_ekgrp+1(1) < '0'  or
              l_ekgrp+1(1) > 'A'.
                delete it_t024.
              endif.

          endloop.

      endif.

 endif.


**
   if  not g_TABCTRL100_wa-GRP is initial.

       loop at it_t024 into wa_t024.

           if g_TABCTRL100_wa-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-GRP'.
          rollback work.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( g_TABCTRL100_wa-role_name = 'M13' or
   g_TABCTRL100_wa-role_name = 'M14' or
    g_TABCTRL100_wa-role_name = 'M16' or
    g_TABCTRL100_wa-role_name = 'M18' or
    g_TABCTRL100_wa-role_name = 'M19' ) and
    not g_TABCTRL100_wa-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = g_TABCTRL100_wa-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZMM_PREP_ROLEREI-PLANT'.
       rollback work.
       message e074(zhelp).

    endif.

endif.

   if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

         loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                  if l_zarea+0(1) <> 'M'.
                    delete it_t001l.
                  endif.

              else.

                 delete it_t001l.

              endif.

          endloop.

    else.

          loop at it_t001l into wa_t001l.

             SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

              if sy-subrc = 0.

                if l_zarea+0(1) = 'M'.
                  delete it_t001l.
                endif.

              else.

                  delete it_t001l.

              endif.

          endloop.

    endif.

    if  not g_TABCTRL100_wa-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if g_TABCTRL100_wa-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
          rollback work.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( g_TABCTRL100_wa-role_name = 'M12' or
       g_TABCTRL100_wa-role_name = 'M17' ) and
       not g_TABCTRL100_wa-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if g_TABCTRL100_wa-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if g_TABCTRL100_wa-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not g_TABCTRL100_wa-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if g_TABCTRL100_wa-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
           rollback work.
           message e075(zhelp).

       endif.

    endif.


*****************************

endif.

endloop.

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

clear g_att_files_wa.
refresh g_att_files.

g_att_files_wa-LOGSYS = ZMM_PREP_ROLEREQ-DOCNO+2(10).
g_att_files_wa-objtype = 'ATT'.
g_att_files_wa-objkey = '01'.

append g_att_files_wa to g_att_files.

CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
  EXPORTING
    ATTACHMENT_DATA           = ''
    ATTACHMENT_TYPE           = 'DOC'
  TABLES
    APPLICATION_OBJECTS       = g_att_files
          .


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

g_att_files_wa-LOGSYS = ZMM_PREP_ROLEREQ-DOCNO+2(10).
g_att_files_wa-objtype = 'ATT'.
g_att_files_wa-objkey = '01'.

CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
  EXPORTING
    APPLICATION_OBJECT       = g_att_files_wa
*   FUNCTION                 = ' '
* TABLES
*   FUNC_EXCLUDE             =
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
   TITEL              = 'Choosing Location '
   TEXTLINE1          = 'It is understood that user has joined at new location & HR Data'
   TEXTLINE2          = 'is updated. Please choose appropriate current location?'
*   START_COLUMN       = 25
*   START_ROW          = 6
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
  loop at ist_itemtab into wa_itemtab.
*** CAB_AJIT Approval check added on 11/12/2006
if wa_itemtab-rej_fl = '' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.

      if sy-subrc = 0 and old_ok_code = 'APPROVE'.
        if zmm_prep_rolegrp-approver1 = g_user
           or zmm_prep_rolegrp-approver2 = g_user
           or zmm_prep_rolegrp-approver3 = g_user.
        else.

          if okcode_100 = 'SAV'.
             if err_flg <> 'X'.
                 err_flg = 'X'.
                 clear : sy-ucomm, okcode_100.
             endif.
            rollback work.
            message i047(zhelp) with zmm_prep_rolegrp-role_type.
            clear okcode_100.
            call screen 100.
          endif.
        endif.
      endif.

   endif.
***
  endloop.
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
   TITEL              = 'CRC Authorizations '
   TEXTLINE1          = 'Please attach the scanned order copy with the request or '
   TEXTLINE2          = 'Please send order copy by fax to Head-ICE '
*   START_COLUMN       = 25
*   START_ROW          = 6
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
   TITEL              = 'Cross Company Authorisations '
   TEXTLINE1          = 'Please attach the scanned order copy with the request or '
   TEXTLINE2          = 'Please send order copy by fax to Head-ICE '
*   START_COLUMN       = 25
*   START_ROW          = 6
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

  select single * from ZMM_PREP_ROLEGRP
       where role_type = wa_itemtab-role_name.

if sy-subrc = 0.

  if ZMM_PREP_ROLEGRP-approver1 = 'L3' and
               g_approver_level = 'L3'.

  elseif ZMM_PREP_ROLEGRP-approver1 = 'IM' and
               g_approver_level = 'L3'.
               g_approver_level = 'IM'.
  elseif  ZMM_PREP_ROLEGRP-approver1 = 'L1' and
               ( g_approver_level = 'L3' or
                 g_approver_level = 'IM' ).
                 g_approver_level = 'L1'.
  endif.

endif.

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

  if g_approver_level = 'IM'.
     g_approver_level = 'I/C MM'.
  endif.

  concatenate 'Kindly get the request approved by competent authority: '
  g_approver_level ' or above' into g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Approval Requirement'
     TEXTLINE1          =  g_approve_text
     TEXTLINE2          = 'Request for authorization will be routed to ICE core team only '
     TEXTLINE3          = 'after requisite approval '
*     START_COLUMN       = 15
*     START_ROW          = 6
            .
  clear : g_approver_level, g_approve_text.
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
     TITEL              = 'Request Processing'
     TEXTLINE1          = 'The request will now be processed by ICE core  team & '
     TEXTLINE2          = 'user will get updated message once the reques t is processed '
*     START_COLUMN       = 15
*     START_ROW          = 6
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
     TITEL              = 'Request Status IR'
     TEXTLINE1          =  'Please go to display mode & reply the query of the ICE core team in '
     TEXTLINE2          = 'correspondence  &  save the request.  No re-release or approval reqd.'
     TEXTLINE3          = 'The request will go directly to ICE core team  for further processing.'.
old_ok_code = 'DISPLAY'.
ENDFORM.                    " verify2
*&---------------------------------------------------------------------*
*&      Form  popup_release_message1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_release_message1.
if g_approver_level = 'IM'.
     g_approver_level = 'I/C MM'.
  endif.

  concatenate g_approver_level ' or above. Request  for  authorization will be routed to ICE core' into g_approve_text.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Approval Requirement'
     TEXTLINE1          =  'Kindly self release the  request  &  get it approved by competent authority:'
     TEXTLINE2          = g_approve_text
     TEXTLINE3          = 'team only after requisite approval '
*     START_COLUMN       = 15
*     START_ROW          = 6
            .
  clear : g_approver_level, g_approve_text.
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

  clear   : help_list_flag.
  refresh : it_m_fistb.

ENDFORM.                    " clear1
*&---------------------------------------------------------------------*
*&      Form  confirm_more
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_more.
" Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Do you want to attach more files?'
*              DEFAULTOPTION  = ''
*              TITEL          = 'ATTACH MORE'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = g_choice_more.

  DATA : l_get6(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'ATTACH MORE'
      TEXT_QUESTION               = 'Do you want to attach more files?'
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = l_get6
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .
  IF SY-SUBRC = 0.
       CASE l_get6.
         WHEN '1'.
           MOVE 'J' TO g_choice_more.
           WHEN '2'.
             MOVE 'N' TO g_choice_more.
             ENDCASE.
             ENDIF.

" End of <RD1K960036>.
ENDFORM.                    " confirm_more
