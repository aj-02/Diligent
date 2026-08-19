*--- MAIN PROGRAM: MZMMPREPROLE1_PHASEII_ADMNF01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.

************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 1240.
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

    data : l_get3(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'BACK'
        TEXT_QUESTION               = 'Data will be lost, Want to quit? '
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

  if sy-tcode = 'ZIC_ARMS_CONNECT'.
       old_ok_code = 'DISPLAY'.
       get parameter id 'ZREQNO' field zic_prep_rolereq-docno.
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

  CALL FUNCTION 'ENQUEUE_EZ_IC_PREPHDR'
       EXPORTING
            MODE_ZMM_CDHD  = 'E'
            MANDT          = SY-MANDT
            DOCNO          = zic_prep_rolereq-docno
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
*&      Form  get_correspondence
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_correspondence.

  DATA : l_cors like THEAD-TDNAME.

  IF old_ok_code <> 'CREATE' or
     old_ok_code <> 'CROSSCO'.

    refresh lines_cors.

    move zic_prep_rolereq-docno to l_cors.

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
      zic_prep_rolereq-long_text_fl = ''.
    Else.
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
  g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

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

***
   data : l_i like sy-index.
     l_i = 36.
    IF <MARK_FIELD> = 'X' and <WA>+l_i(1) = ''.
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

  if ZIC_PREP_ROLEREQ-CCODE is initial.
    set cursor field 'ZIC_PREP_ROLEREQ-CCODE'.
    message i082(zhelp).
    leave to screen 0.
  endif.
  refresh : it_cond.
  concatenate 'FICTR'  'LIKE'  into g_line separated by
  space.
  concatenate g_line+0(10) '''' ZIC_PREP_ROLEREQ-CCODE '%' ''''  into
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
    if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc2 or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc3 or
       wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc4.
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc.
             ZIC_PREP_ROLEREQ-fundc = 'X'.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc2.
            clear ZIC_PREP_ROLEREQ-fundc2.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc3.
             clear ZIC_PREP_ROLEREQ-fundc3.
           endif.

           if wa_m_fistb-fictr = ZIC_PREP_ROLEREQ-fundc4.
            clear ZIC_PREP_ROLEREQ-fundc4.
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

      ZIC_PREP_ROLEREQ-FUNDC = wa_m_fistb-FICTR.

    else.

      clear ZIC_PREP_ROLEREQ-FUNDC .

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

    g_release = ZIC_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZIC_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZIC_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZIC_PREP_ROLEREQ-req_app1_fl.


    select single * from ZIC_PREP_ROLEREQ
                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

    if ZIC_PREP_ROLEREQ-req_cr_fl is initial.
      ZIC_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZIC_PREP_ROLEREQ-req_app_fl is initial.
      ZIC_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZIC_PREP_ROLEREQ-req_app1_fl is initial.
      ZIC_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZIC_PREP_ROLEREQ-req_app0_fl is initial.
      ZIC_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.


    clear : g_release, g_approve, g_approve0, g_approve1.

    if g_release = 'X' and ( g_approve <> 'X' and
                             g_approve0 <> 'X' and
                             g_approve1 <> 'X' ).

      g_app_rel = 'X'.

    endif.

  endif.

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

  ZIC_PREP_ROLEREQ-mandt = sy-mandt.
  if old_ok_code = 'CREATE' or
     old_ok_code = 'CROSSCO' or
     old_ok_code = 'CRCROLES'.
    ZIC_PREP_ROLEREQ-docno = ZDOCNUMB.
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
           where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                 a~sprps = ' ' and
                 a~endda = '99991231' and
                 c~sprps = ' ' and
                 c~endda = '99991231' .

  if sy-subrc = 0.
    read table ist_data index 1. "#EC CI_NOORDER

    ZIC_PREP_ROLEREQ-PERSA = ist_data-werks .

  endif.
****************************************


  if ZIC_PREP_ROLEREQ-USERIDCR is initial.

    ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZIC_PREP_ROLEREQ-CR_DATE  = sy-datum.

    clear zusrmst.

    select single * from usr02 where bname =
                               ZIC_PREP_ROLEREQ-useridcr.

    if sy-subrc ne 0.

    else.
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
                where a~pernr = ZIC_PREP_ROLEREQ-USERIDCR and
                      a~sprps = ' ' and
                      a~endda = '99991231' and
                      c~sprps = ' ' and
                      c~endda = '99991231' .

      if sy-subrc = 0.
        read table ist_data index 1. "#EC CI_NOORDER
        ZIC_PREP_ROLEREQ-NAMECR = ist_data-name.
        ZIC_PREP_ROLEREQ-DESIGCR = ist_data-designation.
      endif.

    endif.

    clear : ist_data.
    refresh : ist_data.

  endif.


  if ZIC_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and
          ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' ).
      ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZIC_PREP_ROLEREQ-APP_DATE  = sy-datum.

      if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      endif.

      clear zusrmst.

      select single * from usr02 where bname =
                            ZIC_PREP_ROLEREQ-useridap.

      if sy-subrc ne 0.

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
        where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*
        if sy-subrc = 0.
          read table ist_data index 1.  "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
                 not ZIC_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
            where persa = ist_data-werks.
            if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                where userid = ZIC_PREP_ROLEREQ-USERIDAP.
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
          ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
*                and
*                      ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZIC_PREP_ROLEREQ-APP_DATE = sy-datum.

      if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
      else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
      endif.


      select single * from usr02 where bname =
                              ZIC_PREP_ROLEREQ-useridap.
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
            where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
                  a~sprps = ' ' and
                  a~endda = '99991231' and
                  c~sprps = ' ' and
                  c~endda = '99991231' .

        if sy-subrc = 0.
          read table ist_data index 1. "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
          if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
             not ZIC_PREP_ROLEREQ-PERSA is initial.
            select single * from t500p
                where persa = ist_data-werks.
            if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
            else.
              select single * from zmm_prep_ex_app
                   where userid = ZIC_PREP_ROLEREQ-USERIDAP.
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
*
                   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

        ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
        ZIC_PREP_ROLEREQ-APP_DATE = sy-datum.

        if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
           ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
        else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
        endif.


        select single * from usr02 where bname =
                                ZIC_PREP_ROLEREQ-useridap.
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
              where a~pernr = ZIC_PREP_ROLEREQ-USERIDAP and
                    a~sprps = ' ' and
                    a~endda = '99991231' and
                    c~sprps = ' ' and
                    c~endda = '99991231' .
*
          if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
            ZIC_PREP_ROLEREQ-DESIGAP = ist_data-designation.
            if ZIC_PREP_ROLEREQ-PERSA <> ist_data-werks and
               not ZIC_PREP_ROLEREQ-PERSA is initial.
              select single * from t500p
                  where persa = ist_data-werks.
              if ZIC_PREP_ROLEREQ-ccode = t500p-bukrs.
              else.
                select single * from zmm_prep_ex_app
                     where userid = ZIC_PREP_ROLEREQ-USERIDAP.
                if sy-subrc = 0.
                else.
* Check for L1 inserted  05/03/2007
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

if not ZIC_PREP_ROLEREQ-USERIDAP is initial and
     old_ok_code = 'APPROVE' and
              ( ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' or
                   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
                   ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' ).

**
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
        where a~pernr = sy-uname and
              a~sprps = ' ' and
              a~endda = '99991231' and
              c~sprps = ' ' and
              c~endda = '99991231' .

*
        if sy-subrc = 0.
          read table ist_data index 1. "#EC CI_NOORDER
          ZIC_PREP_ROLEREQ-NAMEAPP = ist_data-name.
          ZIC_PREP_ROLEREQ-USERIDAP = sy-uname.
        endif.

**

     if ZIC_PREP_ROLEREQ-STATUS = 'IC' or
         ZIC_PREP_ROLEREQ-STATUS = 'IR'.
         ZIC_PREP_ROLEREQ-STATUS   = 'IF'.
     else.
         ZIC_PREP_ROLEREQ-STATUS   = 'N'.
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
          ZIC_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZIC_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZIC_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message i078(zhelp).
          okcode_100 = 'MULTI'.
          g_fundc_err_flag = 'X'.
      endcase.
    endif.
  endloop.
*****************************

** CAB_AJIT 20/04/2007

*if ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X' or
*   ZIC_PREP_ROLEREQ-REQ_APP0_FL = 'X' or
*   ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' .
*else.
*    clear ZIC_PREP_ROLEREQ-NAMEAPP.
*    clear ZIC_PREP_ROLEREQ-USERIDAP.
*    clear ZIC_PREP_ROLEREQ-APP_DATE.
*endif.

****

*****
  if g_fundc_err_flag <> 'X'.

    if old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'.
      g_comm_fl = 'X'.
      if g_lines_2 <> 0.
        clear ZIC_PREP_ROLEREQ-comm_fl.
        clear g_lines_2.
** Status New changed to IF
        ZIC_PREP_ROLEREQ-status = 'IF'.
      endif.
    endif.

*Begin of <RD1K963151>.
data : new_status  like  ZIC_PREP_ROLEREQ-status.
      move ZIC_PREP_ROLEREQ-status to new_status.
*End of <RD1K963151>.
   if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = 'X'.

** Status New changed to IR
      ZIC_PREP_ROLEREQ-status = 'IR'.
      clear ZIC_PREP_ROLEREQ-comm_fl.
    endif.

*Begin of <RD1K963151>.
   if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = ' ' and  SY-UCOMM = 'SAV'.
   ZIC_PREP_ROLEREQ-status = new_status.
   CLEAR new_status.
   endif.
*End of <RD1K963151>.
    if old_ok_code = 'CROSSCO'.
      ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    endif.

    if old_ok_code = 'CRCROLES'.
      ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    endif.

    if ZIC_PREP_ROLEREQ-CCODE is initial.
      message e142(zhelp).
    endif.

    if G_MULT_MODULE_FL = 'X' and old_ok_code = 'CHANGE'.
       ZIC_PREP_ROLEREQ-MULTIMODULE_FL = 'X'.
    endif.



    modify ZIC_PREP_ROLEREQ from ZIC_PREP_ROLEREQ.


    if sy-subrc = 0.

      if g_app_rel = 'X'.

        clear g_app_rel.

      elseif
      ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X' )
      or ( old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-comm_fl = 'X' ).

      else.

        g_approver_level = 'L3'.

** Module wise check & insertion

    if g_reset_fl <> 'X'.

      case moduleid.

       when 'MM'.

        Perform insert_items.

       when 'PM'.

        Perform insert_items_pm.

       when 'PS'.

        Perform insert_items_ps.

       when 'PP'.

        Perform insert_items_pp.

       when 'SD'.

        Perform insert_items_sd.

       when 'QM'.

        Perform insert_items_qm.

      endcase.

   endif.

      endif.

   if g_reset_fl <> 'X'.
      Perform items_approval_check.
   endif.

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

**** Check if moduleid has changed
**13/04/07
   if module_changed_flag = 'X' and ( old_ok_code = 'CHANGE' or
      old_ok_code = 'APPROVE' ).
      moduleid = new_moduleid.
      clear new_moduleid.
      clear module_changed_flag.
      if old_ok_code <> 'APPROVE'.
        old_ok_code = 'CHANGE'.
      endif.
      perform clear_for_newmodule.
   else.
      perform clear.
   endif.
****
*   if module_changed_flag = 'X' and old_ok_code = 'APPROVE'.
*      moduleid = new_moduleid.
*      clear new_moduleid.
*      clear module_changed_flag.
*      old_ok_code = 'CHANGE'.
*      perform clear_for_newmodule.
*   else.
*      perform clear.
*   endif.
****
      perform unlock_record.
      if g_reset_fl = 'X'.
        clear g_reset_fl.
        clear set_disc_mm_flag.
        clear set_disc_fi_flag.
        clear g_hd_copied.
**13/04/07
        if old_ok_code = 'APPROVE'.
        else.
          old_ok_code = 'CHANGE'.
        endif.
        ZIC_PREP_ROLEREQ-docno = g_docno.
      endif.

*      ZIC_PREP_ROLEREQ-crc_fl = g_crc_fl.
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

  sort g_TABLCTRL110_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABLCTRL110_itab
    comparing role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

  loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.

    move-corresponding g_TABLCTRL110_wa to wa_itemtab.

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

***added g_reset_fl to check resetting & no rollback
  if g_lines_rl = 0 .
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                  moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid..
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

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
*                 DEFAULTOPTION = 'N'
*         IMPORTING
*              ANSWER         = l_choice1.

DATA : l_get4(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'EXIT '
    TEXT_QUESTION               = 'Data will be lost, Want to quit? '
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

  CALL FUNCTION 'DEQUEUE_EZ_IC_PREPHDR'
       EXPORTING
            MODE_ZIC_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = ZIC_PREP_ROLEREQ-docno.

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
  refresh : g_TABLCTRL110_itab[].
  clear   : g_TABLCTRL110_itab.
  refresh : g_TABLCTRL111_itab[].
  clear   : g_TABLCTRL111_itab.
  refresh : g_TABLCTRL112_itab[].
  clear   : g_TABLCTRL112_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear set_disc_fi_flag.
  clear   : zic_prep_rolerei, ZIC_PREP_ROLEREQ.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.
  clear   : moduleid.

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
  or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
       and  ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

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
   or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
       and  ZIC_PREP_ROLEREQ-STATUS <> 'C').
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
  move ZIC_PREP_ROLEREQ-docno to l_theader-tdname.
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
                    ID 'FRGCO' FIELD : 'L2'.
  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  Endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L3'.
  if sy-subrc = 0.
    g_user = 'L3'.
    check 1 = 2.
  endif.

  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                      ID 'FRGCO' FIELD : 'L4'.

  if sy-subrc = 0.
    g_user = 'L3'.
    zic_prep_rolereq-radio_fl = 'X'.
    g_l4 = 'X'.
    check 1 = 2.
  Endif.

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

     select single * from zic_prep_rolerei where moduleid = 'MM'
        and docno = zic_prep_rolereq-docno.

     if sy-subrc = 0.
        modulemm_fl = 'X'.
     endif.

     if g_user = 'L1' or
        g_user = 'IM' or
        ( g_user = 'L3' and g_l4 <> 'X' ).
     elseif modulemm_fl <> 'X' and g_l4 = 'X'.
     else.
          message i131(zhelp).
          clear old_ok_code.
          call screen 100.
     endif.

     if g_user = 'L1' and
        ( ZIC_PREP_ROLEREQ-req_app0_fl = 'X' or
          ZIC_PREP_ROLEREQ-req_app_fl = 'X' ).
        message i132(zhelp).
        clear old_ok_code.
        call screen 100.
     endif.

  endif.

*  if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.
*
*    if  ZIC_PREP_ROLEREQ-USERIDCR = sy-uname.
*    else.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*              TEXTLINE1  = 'Not authorised to use this document- not
*yours '.
**                     message i046(zhelp).
*      perform clear.
*      call screen 100.
*    endif.
*
*  endif.

*  if old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.
*
*    if ZIC_PREP_ROLEREQ-status = 'IF' or
*          ZIC_PREP_ROLEREQ-status = 'PC' or
*          ZIC_PREP_ROLEREQ-status = 'C'.
*      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*           EXPORTING
*                TEXTLINE1 = 'Request under process / completed can''t
*change/reset'.
*
**                message e065(zhelp).
*      perform clear.
*      call screen 100.
*
*    else.
*      g_reset_fl = ZIC_PREP_ROLEREQ-REQ_CR_FL.
*      g_docno = ZIC_PREP_ROLEREQ-docno.
*      perform verify.
*  endif.
*  endif.

  if old_ok_code = 'APPROVE' and
                    ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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

  if old_ok_code = 'RELEASE' and ZIC_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1 = 'Request already released by creator'.

*          message e053(zhelp).
    perform clear.
    call screen 100.

  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZIC_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.

*                   message e051(zhelp).
      perform clear.
      call screen 100.

    endif.

    if ( g_user = 'IM' or g_user = 'L3' ) and
                          ZIC_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request not released by creator'.
*                   message e051(zhelp)..
      perform clear.
      call screen 100.

    endif.

      if  ZIC_PREP_ROLEREQ-REQ_APP1_FL = 'X' or
          ZIC_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
           EXPORTING
                TEXTLINE1 = 'Request already approved'.

      perform clear.
      call screen 100.

    endif.

  endif.

*  if ( ZIC_PREP_ROLEREQ-status = 'IF' or
*      ZIC_PREP_ROLEREQ-status  = 'C' )
*      and old_ok_code <> 'DISPLAY'.
*    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*       EXPORTING
*              TEXTLINE1   = 'Request can not  be  changed, Can only be
*displayed'.
*
**              message e079(zhelp).
**               perform clear.
*    old_ok_code = 'DISPLAY'.
*    call screen 100.
*
*  endif.

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
 WHERE FISTL = ZIC_PREP_ROLEREQ-FUNDC
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

     select single docno from zic_prep_rolereq
                     into l_docno where docno = zic_prep_rolereq-docno.

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

  if zic_prep_rolerei-rej_fl = ''.

    if old_ok_code = 'APPROVE' and
                      ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
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

data : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = ' '
    TEXT_QUESTION               = 'Are you sure, you want to delete the Document? '
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
" End of <RD1K960036>.
If l_choice = 'J'.
      clear l_choice.

**************************************

  ZIC_PREP_ROLEREQ-mandt = sy-mandt.

  delete ZIC_PREP_ROLEREQ from ZIC_PREP_ROLEREQ.

  if sy-subrc = 0.

    Perform delete_items.


    if ZIC_PREP_ROLEREQ-long_text_fl <> ''.
      perform delete_cors_text.
    endif.

    perform clear.
    perform unlock_record.
    call screen 100.

  else.

    message i057(zhelp) with ZIC_PREP_ROLEREQ-docno.

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

  delete zic_prep_rolerei from table ist_itemtab.

  if sy-subrc = 0.
    message i120(zhelp) with ZIC_PREP_ROLEREQ-docno.
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

  l_name = ZIC_PREP_ROLEREQ-docno.

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
data : l_get5(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'RESET'
    TEXT_QUESTION               = 'Request already released Flags will be cancelled? '
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
" End of <RD1K960036>.

  If l_choice = 'J'.

    clear ZIC_PREP_ROLEREQ-req_cr_fl.
    clear ZIC_PREP_ROLEREQ-req_app_fl.
    clear ZIC_PREP_ROLEREQ-req_app0_fl.
    clear ZIC_PREP_ROLEREQ-req_app1_fl.
    ZIC_PREP_ROLEREQ-status = 'IC'.
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

   if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 WA_ITEMTAB-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.

     if zmm_prep_rolecrc+0(1) = 'C'.

       if zmm_prep_rolecrc-plant = 'X' and
           wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-p_grp = 'X' and
           wa_itemtab-grp is initial.
          g_field = 'ZIC_PREP_ROLEREI-P_GRP'.
          rollback work.
          message i085(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.

        if zmm_prep_rolecrc-app_level = 'X' and
          wa_itemtab-approver is initial.
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
**
      else.
       g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
       rollback work.
       message i197(zhelp).
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
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
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
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
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
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
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
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
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
          g_field = 'ZIC_PREP_ROLEREI-APPROVER'.
          rollback work.
          message i096(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

    endif.

   endif.

  endif.
**  if wa_itemtab-rej_fl is initial.
**** Header level changes for integration
**    perform validate_role_approval_level.
**  endif.
** Line item changes for integration call diffrent subs ( def 110 )
  perform validate_lineitem_datax.
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

data : l_get6(1)  TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Do you want to cancel release? '
    TEXT_QUESTION               = 'If u cancel release, u can change data else go in display mode & just do correspondence without cancelling release'
   DEFAULT_BUTTON              = '2'
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
           MOVE 'J' TO l_choice.
           WHEN '2'.
             MOVE 'N' TO l_choice.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
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
    tel_len = strlen( ZIC_PREP_ROLEREQ-TELNO ).
    if  ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
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
*&      Form  validate_lineitem_datax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL110_itab into g_TABLCTRL110_wa.

  if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    select single * from zmm_prep_rolecrc where role_type =
                    g_TABLCTRL110_wa-role_name.

    if sy-subrc <> 0.
       rollback work.
       message e117(zhelp).
    endif.

  else.
    select single * from zmm_prep_roledes where role_type =
                    g_TABLCTRL110_wa-role_name.
    if sy-subrc <> 0.
       rollback work.
       message e118(zhelp).
    endif.

  endif.

**********************************************************

if old_ok_code <> 'DISPLAY'.

 if old_ok_code = 'CRCROLES'.

 else.

   if zmm_prep_roledes-mm_disc_flag = 'X'.

         if ZIC_PREP_ROLEREQ-disc_mm_flag = 'X'.
         else.
           rollback work.
           message e081(zhelp) with g_TABLCTRL110_wa-role_name.
         endif.

   endif.

 endif.

*  endif.

  if not g_TABLCTRL110_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL110_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL110_wa-role_name.

      endif.

   endif.


************finding group*******************

  refresh : it_cond, it_t024, it_t024_1.
*  clear   : it_cond, it_t024, it_t024_1.
  clear   : wa_t024.
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
 if g_TABLCTRL110_wa-role_name = 'M6' or
     g_TABLCTRL110_wa-role_name = 'M7' or
     g_TABLCTRL110_wa-role_name = 'M8'.
    concatenate '%' G_CCODE '%' into g_line1.
    select * from t024 into table it_t024 where TELFX like g_line1.
  else.
    if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      concatenate '%' G_CCODE '%' 'IND' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    else.
      concatenate  '%' G_CCODE '%' 'MM' '%'
      into g_line1.
      select * from t024 into table it_t024 where TELFX like g_line1.
    endif.
   endif.

**
   if  not g_TABLCTRL110_wa-GRP is initial.

       loop at it_t024 into wa_t024.

           if g_TABLCTRL110_wa-GRP = wa_t024-ekgrp.
              grp_flag = 'X'.
           endif.

       endloop.

       if grp_flag = 'X'.
          clear grp_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-GRP'.
          rollback work.
          message i069(zhelp).
          call screen 100.

       endif.

   endif.

***************************

clear : l_zarea, wa_t001l.
refresh it_t001l.

if ( g_TABLCTRL110_wa-role_name = 'M13' or
   g_TABLCTRL110_wa-role_name = 'M14' or
    g_TABLCTRL110_wa-role_name = 'M16' or
    g_TABLCTRL110_wa-role_name = 'M18' or
    g_TABLCTRL110_wa-role_name = 'M19' ) and
    not g_TABLCTRL110_wa-PLANT is initial.

    select * from t001l into corresponding fields of
                 table it_t001l  where werks = g_TABLCTRL110_wa-PLANT.

    if  sy-subrc <> 0.
       g_e_fl = 'X'.
       g_field = 'ZIC_PREP_ROLEREI-PLANT'.
       rollback work.
       message e074(zhelp).

    endif.

endif.

   if ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

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

    if  not g_TABLCTRL110_wa-SLOC is initial.

       loop at it_t001l into wa_t001l.

           if g_TABLCTRL110_wa-SLOC = wa_t001l-lgort.
              loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
** cab_ajit 07.02.2006
          g_e_fl = 'X'.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          rollback work.
          message e073(zhelp).

       endif.

   endif.


***************************

clear wa_recpt.
refresh it_recpt.

    if ( g_TABLCTRL110_wa-role_name = 'M12' or
       g_TABLCTRL110_wa-role_name = 'M17' ) and
       not g_TABLCTRL110_wa-receipt_loc is initial.

        select * from zmm_location into table it_recpt.

                     if g_TABLCTRL110_wa-role_name = 'M12'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'RL'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.


                      if g_TABLCTRL110_wa-role_name = 'M17'.

                          loop at it_recpt into wa_recpt.

                            if wa_recpt-loccg <> 'CF'.
                              delete it_recpt.
                            endif.

                          endloop.

                      endif.

    endif.

    if  not g_TABLCTRL110_wa-RECEIPT_LOC is initial.

       loop at it_recpt into wa_recpt.

           if g_TABLCTRL110_wa-receipt_loc = wa_recpt-loccd.
               loc_flag = 'X'.
           endif.

       endloop.

       if loc_flag = 'X'.
          clear loc_flag.
       else.
          g_e_fl = 'X'.
           g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
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

g_att_files_wa-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
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

g_att_files_wa-LOGSYS = ZIC_PREP_ROLEREQ-DOCNO+2(10).
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
  select * from ZIC_PREP_ROLEREI into table ist_itemtab
  where docno = zic_prep_rolereq-docno.
  loop at ist_itemtab into wa_itemtab.
  if wa_itemtab-rej_fl is initial.
** Header level changes for integration
    perform validate_role_approval_level.
  endif.
  endloop.
  clear ist_itemtab.
  refresh ist_itemtab[].
  clear wa_itemtab.
**      if sy-subrc = 0.
** Messages to be checked modulewise in sub
        perform clear1.
        if old_ok_code = 'CROSSCO' or
              ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.

              if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CROSSCO' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.

               if old_ok_code = 'APPROVE' or
                  ZIC_PREP_ROLEREQ-status = 'IF'.
                  perform popup_approve_message.
               endif.

               perform pop_up_crossco_message.          .
*          message i113(zhelp) with ZIC_PREP_ROLEREQ-docno.
               set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.

          else.
            if old_ok_code = 'CRCROLES' or
              ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
               if old_ok_code = 'RELEASE' or
                  old_ok_code = 'CRCROLES' or
                  old_ok_code = 'CHANGE'.
                  perform popup_release_message.
               endif.
               if old_ok_code = 'APPROVE' or
                  ZIC_PREP_ROLEREQ-status = 'IF'.
                    perform popup_approve_message.
               endif.
               perform pop_up_crc_message.
*              message i119(zhelp) with ZIC_PREP_ROLEREQ-docno.
               message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
               g_crc_fl = 'X'.
            else.
              if old_ok_code = 'RELEASE'.
                perform popup_release_message.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'APPROVE'.
** 13/04/07
                if module_changed_flag <> 'X'.
.                 perform popup_approve_message.
                  message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
                endif.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif old_ok_code = 'CREATE' or old_ok_code =
'CHANGE'.
** 13/04/07
                if module_changed_flag <> 'X'.
                  perform popup_release_message1.
                  message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
                endif.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
*                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              elseif ZIC_PREP_ROLEREQ-status = 'IF'.
                perform popup_approve_message.
              else.
                set parameter id 'ZREQNO'
                  field zic_prep_rolereq-docno.
                message i045(zhelp) with ZIC_PREP_ROLEREQ-docno.
              endif.
            endif.
        endif.
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

** Check approval module wise & line item wise

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
     TEXTLINE2          = 'user will get updated message once the request is processed '
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
if zic_prep_rolereq-status <> 'C'.
**
CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Request Status IR'
     TEXTLINE1          =  'Please go to display mode & reply the query of the ICE core team in '
     TEXTLINE2          = 'correspondence  &  save the request.  No re-release or approval reqd.'
     TEXTLINE3          = 'The request will go directly to ICE core team for further processing.'.
old_ok_code = 'DISPLAY'.
**
else.
CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT_LO'
   EXPORTING
     TITEL              = 'Request Status C'
     TEXTLINE1          =  'Request is closed, you can not change anything now'
     TEXTLINE2          =  'No more processing of the request can be done'.
old_ok_code = 'DISPLAY'.
**
endif.
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
  clear   : dynnr.

ENDFORM.                    " clear1
*&---------------------------------------------------------------------*
*&      Form  insert_items_pm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pm.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABLCTRL111_itab
  by role_name plant shop_no.

  delete adjacent duplicates from g_TABLCTRL111_itab
    comparing role_name plant rej_fl shop_no.

  loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.

    move-corresponding g_TABLCTRL111_wa to wa_itemtab.

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

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

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
**              elseif old_ok_code = 'CREATE' or old_ok_code = 'CHANGE'.
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

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zpm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zpm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zpm_prep_roledes-shop_no = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-shop_no is initial.
          g_field = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
          rollback work.
          message i095(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if ( zic_prep_rolereq-ccode = 'BDW' or
        zic_prep_rolereq-ccode = 'SBW' ).

        if  ( zpm_prep_roledes-role_type = 'PM14' or
            zpm_prep_roledes-role_type = 'PM15' or
            zpm_prep_roledes-role_type = 'PM16' ).

        else.
          message e164(zhelp) with ZIC_PREP_ROLEREI-role_name
          ZIC_PREP_ROLEREQ-ccode .
        endif.
     endif.

   endif.

 endif.
*
**
  perform validate_lineitem_datax11.

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

  case moduleid.

     when 'MM'.

      Perform check_items_save.

     when 'PM'.

      Perform check_items_save_pm.

     when 'PS'.

      Perform check_items_save_ps.

     when 'PP'.

      Perform check_items_save_pp.

     when 'SD'.

      Perform check_items_save_sd.

     when 'QM'.

      Perform check_items_save_qm.

    endcase.

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

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL111_itab into g_TABLCTRL111_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL111_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL111_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL111_wa-role_name.

      endif.

   endif.

endif.

endloop.

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
  if old_ok_code = 'CRCROLES' or zic_prep_rolereq-CRC_FL = 'X'.
     moduleid = 'MM'.
  endif.
ENDFORM.                    " crc_module_checking
*&---------------------------------------------------------------------*
*&      Form  check_module_status_mm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_mm.
  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     mm_not_ok = 'X'.
  endif.
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
  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     pm_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_pm
*&---------------------------------------------------------------------*
*&      Form  confirm_app
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_app.

" Begin of <RD1K960036>.

*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Are you sure, you want to approve the Document? '
*              TITEL          = ''
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = g_choice_app.

data : l_get(1) TYPE c.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    TEXT_QUESTION               = 'Are you sure, you want to approve the Document? '
    DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = l_get
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_get.
         WHEN '1'.
           MOVE 'J' TO g_choice_app.
           WHEN '2'.
             MOVE 'N' TO g_choice_app.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

ENDFORM.                    " confirm_app
*&---------------------------------------------------------------------*
*&      Form  insert_items_ps
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_ps.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL112_itab
  by role_name service project location asset basin.

  delete adjacent duplicates from g_TABLCTRL112_itab
    comparing role_name rej_fl service project location
    asset basin.

  loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.

    move-corresponding g_TABLCTRL112_wa to wa_itemtab.

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

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
*      delete from ZIC_PREP_ROLEREQ
*            where docno = ZIC_PREP_ROLEREQ-docno.
*      delete from zic_prep_rolerei
*            where docno = ZIC_PREP_ROLEREQ-docno and
*                   moduleid = moduleid.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

  if not ZIC_PREP_ROLEREI-SERVICE is initial and
        ZIC_PREP_ROLEREI-ROLE_NAME is initial.
  message e185(zhelp).
  endif.

  if old_ok_code <> 'DISPLAY' .

    select single * from zps_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zps_prep_roledes-service = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-service is initial.
          g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
          rollback work.
          message i174(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zps_prep_roledes-project = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-project is initial.
          g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
          rollback work.
          message i175(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-location = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-location is initial.
          g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
          rollback work.
          message i176(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-asset = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-asset is initial.
          g_field = 'ZIC_PREP_ROLEREI-ASSET'.
          rollback work.
          message i177(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zps_prep_roledes-basin = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-basin is initial.
          g_field = 'ZIC_PREP_ROLEREI-BASIN'.
          rollback work.
          message i178(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax12.

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

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL112_itab into g_TABLCTRL112_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL112_wa-service is initial.

       select single * from zps_prep_service
               where service = g_TABLCTRL112_wa-service.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SERVICE'.
            rollback work.
            message e179(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

   endif.

   if not g_TABLCTRL112_wa-project is initial.

       select single * from zps_prep_project
            where service = g_TABLCTRL112_wa-service and
            project = g_TABLCTRL112_wa-project.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PROJECT'.
            rollback work.
            message e180(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

   endif.

   if not g_TABLCTRL112_wa-location is initial.

       select single * from zps_prep_loca
            where ccode = ZIC_PREP_ROLEREQ-CCODE and
                  location = g_TABLCTRL112_wa-location and
                  service = g_TABLCTRL112_wa-service.

       if sy-subrc <> 0.
             g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-LOCATION'.
            rollback work.
            g_i = g_curr_line.
            message e181(zhelp) with g_TABLCTRL112_wa-role_name.
      endif.

    endif.

    if not g_TABLCTRL112_wa-basin is initial.

     if g_TABLCTRL112_wa-basin <> ZIC_PREP_ROLEREQ-CCODE and
            g_TABLCTRL112_wa-basin <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-BASIN'.
            rollback work.
            message e181(zhelp) with g_TABLCTRL112_wa-role_name.

      endif.

    endif.


      if not g_TABLCTRL112_wa-asset is initial.

       if ZIC_PREP_ROLEREQ-CCODE = 'MUM'.

         if g_TABLCTRL112_wa-asset <> 'ALL'.
           select single * from zps_prep_asst_ex
                  where ccode = ZIC_PREP_ROLEREQ-CCODE and
                    asset = g_TABLCTRL112_wa-asset.
         endif.
         if sy-subrc <> 0 and zps_prep_asst_ex-asset <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET'.
            rollback work.
            message e182(zhelp) with g_TABLCTRL112_wa-role_name.

        endif.

       else.

        if g_TABLCTRL112_wa-asset <> ZIC_PREP_ROLEREQ-CCODE and
            g_TABLCTRL112_wa-asset <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET'.
            rollback work.
            message e182(zhelp) with g_TABLCTRL112_wa-role_name.

        endif.
       endif.
      endif.
************
endif.

endloop.

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
 if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     ps_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_ps
*&---------------------------------------------------------------------*
*&      Form  clear_for_newmodule
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_for_newmodule.

  perform destroy_ctrl.

  clear   : okcode_100, err_flg.
  refresh : g_TABLCTRL110_itab[].
  clear   : g_TABLCTRL110_itab.
  refresh : g_TABLCTRL111_itab[].
  clear   : g_TABLCTRL111_itab.
  refresh : g_TABLCTRL112_itab[].
  clear   : g_TABLCTRL112_itab.
  clear   : sy-ucomm.
  clear   : g_curr_line.
  clear set_disc_mm_flag.
  clear set_disc_fi_flag.
  clear   : zic_prep_rolerei.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].
  clear   : t500p-name1.
  clear   : CRC_CHECK_FL.
  clear   : help_list_flag.
  refresh : it_m_fistb.
  clear   : g_hd_copied.

ENDFORM.                    " clear_for_newmodule
*&---------------------------------------------------------------------*
*&      Form  insert_items_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_pp.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL113_itab
  by role_name plant sloc res ctf_sloc.

  delete adjacent duplicates from g_TABLCTRL113_itab
    comparing role_name rej_fl plant sloc res
    ctf_sloc.

  loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.

    move-corresponding g_TABLCTRL113_wa to wa_itemtab.

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

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zpp_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zpp_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i074(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zpp_prep_roledes-sloc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sloc is initial.
          g_field = 'ZIC_PREP_ROLEREI-SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zpp_prep_roledes-res = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-res is initial.
          g_field = 'ZIC_PREP_ROLEREI-RES'.
          rollback work.
          message i184(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zpp_prep_roledes-ctf_sloc = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-ctf_sloc is initial.
          g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
          rollback work.
          message i090(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax13.


ENDFORM.                    " check_items_save_pp
*&---------------------------------------------------------------------*
*&      Form  check_module_status_pp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_pp.

  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     pp_not_ok = 'X'.
  endif.

ENDFORM.                    " check_module_status_pp
*&---------------------------------------------------------------------*
*&      Form  insert_items_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_sd.

DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL114_itab
  by role_name sale_org div plant ship_point.

  delete adjacent duplicates from g_TABLCTRL114_itab
    comparing role_name rej_fl sale_org div plant ship_point.

  loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.

    clear wa_itemtab.

    move-corresponding g_TABLCTRL114_wa to wa_itemtab.

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

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zsd_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zsd_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i074(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

     if zsd_prep_roledes-sale_org = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-sale_org is initial.
          g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          rollback work.
          message i190(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zsd_prep_roledes-div = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-div is initial.
          g_field = 'ZIC_PREP_ROLEREI-DIV'.
          rollback work.
          message i194(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

      if zsd_prep_roledes-ship_point = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-ship_point is initial.
          g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
          rollback work.
          message i191(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

*****
   endif.

 endif.
*
**
  perform validate_lineitem_datax14.


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

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

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
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL113_itab into g_TABLCTRL113_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.


  if not ZIC_PREP_ROLEREI-PLANT is initial.

   select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
   if sy-subrc = 0.

   select single * from zhelp_pproles1 into corresponding fields of
                        zhelp_pproles1 where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

   if sy-subrc <> 0.

   select single * from ZPP_PREP_GENERIC into corresponding fields of
                        ZPP_PREP_GENERIC where
                        role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
                        plant     = ZIC_PREP_ROLEREI-PLANT.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            rollback work.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   else.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_113.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
   endif.

   endif.

   if not ZIC_PREP_ROLEREI-SLOC is initial.

    select single * from t001l into corresponding fields of
             it_t001l  where werks = ZIC_PREP_ROLEREI-PLANT
             and lgort = ZIC_PREP_ROLEREI-SLOC.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SLOC'.
            g_i = g_curr_line_113.
            rollback work.
            message e073(zhelp) with ZIC_PREP_ROLEREI-sloc.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-RES is initial.

    select single * from zpp_prep_res into corresponding fields of
             it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and
             plant = ZIC_PREP_ROLEREI-PLANT
             and
             res = ZIC_PREP_ROLEREI-RES.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-RES'.
            g_i = g_curr_line_113.
            rollback work.
            message e183(zhelp) with ZIC_PREP_ROLEREI-res.

      endif.

   endif.


    if not ZIC_PREP_ROLEREI-ctf_sloc is initial.

       select single * from ZPP_PREP_DROLEEX where role_type =
         ZIC_PREP_ROLEREI-ROLE_NAME
         and plant = ZIC_PREP_ROLEREI-PLANT
         and sloc = ZIC_PREP_ROLEREI-SLOC
         and ctf_sloc = ZIC_PREP_ROLEREI-CTF_SLOC.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
            g_i = g_curr_line.
            rollback work.
            message e073(zhelp) with ZIC_PREP_ROLEREI-ctf_sloc.

      endif.

    endif.
****
endif.

endloop.

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

  if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     sd_not_ok = 'X'.
  endif.

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

if  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

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
                  where a~pernr =  ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

else.

G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL114_itab into g_TABLCTRL114_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not ZIC_PREP_ROLEREI-PLANT is initial.

  select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs =  ZIC_PREP_ROLEREQ-CCODE
                                    and werks = ZIC_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            g_i = g_curr_line_114.
            message e068(zhelp) with ZIC_PREP_ROLEREI-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-SALE_ORG is initial.

    select single * from tvko client specified into corresponding fields
             of it_tvko  where mandt = sy-mandt and
             bukrs =  zic_prep_rolereq-ccode and
             vkorg = ZIC_PREP_ROLEREI-SALE_ORG.

      if sy-subrc <> 0 and ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
            g_i = g_curr_line_114.
            message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
      else.
           if zic_prep_rolereq-ccode = 'MUM' and
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' and
              ZIC_PREP_ROLEREI-SALE_ORG <> 'MUMPHPOP'.
              g_e_fl = 'X'.
              g_field = 'ZIC_PREP_ROLEREI-SALE_ORG'.
              g_i = g_curr_line_114.
              message e186(zhelp) with ZIC_PREP_ROLEREI-SALE_ORG.
           endif.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-DIV is initial.

    select single * from tvkos client specified into corresponding
             fields of it_tvkos  where mandt = sy-mandt and
             vkorg =  ZIC_PREP_ROLEREI-SALE_ORG and
             spart =  ZIC_PREP_ROLEREI-DIV.

      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-DIV'.
            g_i = g_curr_line_114.
            message e187(zhelp) with ZIC_PREP_ROLEREI-DIV.

      endif.

   endif.


   if not ZIC_PREP_ROLEREI-SHIP_POINT is initial.

       select single * from tvswz into corresponding fields of
             it_tvswz  where werks = ZIC_PREP_ROLEREI-PLANT and
             vstel = ZIC_PREP_ROLEREI-SHIP_POINT.

       if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
            g_i = g_curr_line.
            message e188(zhelp) with ZIC_PREP_ROLEREI-SHIP_POINT.

      endif.

    endif.

endif.

endloop.

ENDFORM.                    " validate_lineitem_datax14
*&---------------------------------------------------------------------*
*&      Form  insert_items_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_items_qm.

  DATA : i like sy-index .
  Clear : wa_itemtab, ist_itemtab, i.

  sort g_TABLCTRL115_itab
  by role_name plant asset_qm.

  delete adjacent duplicates from g_TABLCTRL115_itab
    comparing role_name rej_fl plant asset_qm.

  loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.

    move-corresponding g_TABLCTRL115_wa to wa_itemtab.

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

  perform check_module_wise.

  endloop.

  describe table ist_itemtab lines g_lines_rl.

  if g_lines_rl = 0.
    rollback work.
    if old_ok_code = 'CHANGE'.
      if sy-subrc = 0.
        set cursor field 'ZIC_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZIC_PREP_ROLEREQ-docno.
      endif.
    elseif old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' .
      message i103(zhelp) with ZIC_PREP_ROLEREQ-docno.
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
        delete from zic_prep_rolerei where
        docno = ZIC_PREP_ROLEREQ-docno and
        moduleid = moduleid.
      endif.

      modify zic_prep_rolerei from table ist_itemtab.

    endif.

  endif.

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

if old_ok_code <> 'DISPLAY' .

    select single * from zqm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

      if zqm_prep_roledes-plant = 'X' and
                     ( old_ok_code = 'APPROVE' or
                    old_ok_code = 'RELEASE' or
                    old_ok_code = 'CHANGE' or
                    old_ok_code = 'CREATE' or
                    old_ok_code = 'CROSSCO' ) and
                    not wa_itemtab-role_name is initial.

        if wa_itemtab-plant is initial and
              zic_prep_rolereq-ccode = 'MUM'.
          g_field = 'ZIC_PREP_ROLEREI-PLANT'.
          rollback work.
          message i084(zhelp) with g_i.
          clear okcode_100.
          call screen 100.
        endif.
      endif.

   endif.

 endif.
*
**
  perform validate_lineitem_datax15.

ENDFORM.                    " check_items_save_qm
**********************************************************************
*DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
*       messages of call transaction

*----------------------------------------------------------------------*
*   at selection screen                                                *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   create batchinput session                                          *
*   (not for call transaction using...)                                *
*----------------------------------------------------------------------*
FORM OPEN_GROUP.
    CALL FUNCTION 'BDC_OPEN_GROUP'
         EXPORTING  CLIENT   = SY-MANDT
                    GROUP    = sy-uname
                    USER     = sy-uname
                    KEEP     = ''
                    HOLDDATE = sy-datum.

ENDFORM.

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*   (call transaction using...: error session)                         *
*----------------------------------------------------------------------*
FORM CLOSE_GROUP.
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
ENDFORM.
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL <> '/'.
    CLEAR BDCDATA.
    BDCDATA-FNAM = FNAM.
    BDCDATA-FVAL = FVAL.
    APPEND BDCDATA.
  ENDIF.
ENDFORM.
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.
**********************************************************************
*&---------------------------------------------------------------------*
*&      Form  call_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_fi.

 SET PARAMETER ID 'ZOLDCODE_FI' field old_ok_code.

 SET PARAMETER ID 'ZMODULEID_FI' field 'FI'.

 SET PARAMETER ID 'ZUSERID_FI' field ZIC_PREP_ROLEREQ-USERID.

 SET PARAMETER ID 'ZRSN_CODE_FI' field ZIC_PREP_ROLEREQ-RSN_CODE.

 SET PARAMETER ID 'ZTELNO_FI' field ZIC_PREP_ROLEREQ-TELNO.

 SET PARAMETER ID 'ZDOCNO_FI' field ZIC_PREP_ROLEREQ-DOCNO.

 dynnr = '0101'.

 clear old_ok_code.

 perform clear.

  CALL TRANSACTION 'ZIC_AUTH_FI' .

  endform. "call_fi
*&---------------------------------------------------------------------*
*&      Form  check_module_status_qm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_status_qm.
 if wa_item-rej_fl = '' and wa_item-role_request <> ''.
  elseif wa_item-rej_fl <> '' and wa_item-role_request = ''.
  else.
     qm_not_ok = 'X'.
  endif.
ENDFORM.                    " check_module_status_qm
*&---------------------------------------------------------------------*
*&      Form  validate_lineitem_datax15
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_lineitem_datax15.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' or old_ok_code = 'CROSSCO'.

concatenate '000' ZIC_PREP_ROLEREQ-userid into cpf_lfb1.

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
                  where a~pernr = ZIC_PREP_ROLEREQ-USERID and
                        a~sprps = ' ' and
                        a~endda = '99991231' and
                        c~sprps = ' ' and
                        c~endda = '99991231' .

        if sy-subrc = 0.
            read table ist_data index 1. "#EC CI_NOORDER
            G_CCODE = ist_data-bukrs.
        endif.

  else.

  G_CCODE = ZIC_PREP_ROLEREQ-CCODE.

endif.

loop at g_TABLCTRL115_itab into g_TABLCTRL115_wa.

**********************************************************

if old_ok_code <> 'DISPLAY'.

  if not g_TABLCTRL115_wa-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZIC_PREP_ROLEREQ-CCODE
                                    and werks = g_TABLCTRL115_wa-PLANT.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-PLANT'.
            rollback work.
            message e068(zhelp) with g_TABLCTRL115_wa-role_name.
      endif.

   endif.

   if not ZIC_PREP_ROLEREI-ASSET_QM is initial.

    if ZIC_PREP_ROLEREQ-CCODE = 'MUM' or ZIC_PREP_ROLEREQ-CCODE = 'KKL'.

      select single * from ZQM_PREP_ASSET into zqm_prep_asset where
                      ccode =  ZIC_PREP_ROLEREQ-CCODE and
                      asset =  ZIC_PREP_ROLEREI-ASSET_QM.
      if sy-subrc <> 0.
            g_e_fl = 'X'.
            g_field = 'ZIC_PREP_ROLEREI-ASSET_QM'.
            g_i = g_curr_line.
           message e172(zhelp) with ZIC_PREP_ROLEREI-asset_qm.
      endif.

    endif.

   endif.

endif.

endloop.

ENDFORM.                    " validate_lineitem_datax15
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
  data : l_get1(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'ATTACH MORE '
      TEXT_QUESTION               = 'Do you want to attach more files?'
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
           MOVE 'J' TO g_choice_more.
           WHEN '2'.
             MOVE 'N' TO g_choice_more.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.
ENDFORM.                    " confirm_more
*&---------------------------------------------------------------------*
*&      Form  check_module_fi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_module_fi.

  if ( old_ok_code = 'CHANGE' or
  old_ok_code = 'DISPLAY' ) and moduleid = 'FI'.
     select single * from zic_prep_rolerei into
                     corresponding fields of wa_module1 where
                     docno = zic_prep_rolereq-docno and
                     moduleid = 'FI'.
     if sy-subrc <> 0.
        if old_ok_code = 'CHANGE'.
          message e196(zhelp) with zic_prep_rolereq-docno.
        else.
          message e198(zhelp) with zic_prep_rolereq-docno.
        endif.
     endif.
  endif.

ENDFORM.                    " check_module_fi
*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_auth.

AUTHORITY-CHECK OBJECT 'ZARMSADM'
                     ID 'ACTVT' FIELD : '01'.

  if sy-subrc <> 0.
    message e199(zhelp).
  endif.

ENDFORM.                    " check_auth
