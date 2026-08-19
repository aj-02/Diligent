*--- MAIN PROGRAM: MZMMPREPROLE2F01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
*2) Onsolete FM WS_DOWNLOAD Replaced by GUI_DOWNLOAD.
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

    DATA : L_ANSWER(1) TYPE C.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'BACK '
        TEXT_QUESTION               = 'Data will be lost, Want to quit? '
       DISPLAY_CANCEL_BUTTON       = ' '
       START_COLUMN                = 25
       START_ROW                   = 6
     IMPORTING
       ANSWER                      = L_ANSWER
     EXCEPTIONS
       TEXT_NOT_FOUND              = 1
       OTHERS                      = 2
              .
    IF SY-SUBRC = 0.
       CASE L_ANSWER.
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

  data : l_docno like zmm_prep_rolereq-docno.

  CALL FUNCTION 'ENQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno
       EXCEPTIONS
            FOREIGN_LOCK          = 1
            SYSTEM_FAILURE        = 2
            OTHERS                = 3.

  IF SY-SUBRC <> 0.
    clear g_lock.
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

    write: / wa_m_fistb-g_mark as checkbox, wa_m_fistb-fictr,
          wa_m_fistb-bezeich.
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

      clear ZMM_PREP_ROLEREQ-FUNDC.

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

*  perform validations1.

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

  if old_ok_code = 'CREATE'.

    perform gen_no.

  endif.

  perform insert_header.

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
  if old_ok_code = 'CREATE'.
    ZMM_PREP_ROLEREQ-docno = ZDOCNUMB.
  endif.

  if ZMM_PREP_ROLEREQ-USERIDCR is initial.

    ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
    ZMM_PREP_ROLEREQ-CR_DATE  = sy-datum.

*      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
*      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.
    if sy-tcode <> 'ZPREPTEST3'.

      clear zusrmst.

      select single * from zusrmst where cpfno =
                                  ZMM_PREP_ROLEREQ-useridcr.
      if sy-subrc ne 0.

      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMECR = zusrmst-last_name.
      endif.

    endif.

*
*        select a~pernr a~begda a~endda a~ename as name a~bukrs  a~werks
*             a~persk a~sbmod  c~designo c~r_p_cd c~version
*           d~sdesig_text as designation d~adesig_text as adesignation
*             into corresponding fields of table ist_data
*        from ( ( pa0001 as a inner join pa9930 as c
*              on a~pernr = c~pernr ) inner join zdesignation_rev as d
*                 on c~designo = d~desig_code and
*                     c~r_p_cd  = d~r_p_cd and
*                     c~version = d~version )
*                  where a~pernr = ZMM_PREP_ROLEREQ-USERIDCR and
*                        a~sprps = ' ' and
*                        a~endda = '99991231' and
*                        c~sprps = ' ' and
*                        c~endda = '99991231' .
*
*        if sy-subrc = 0.
*            read table ist_data index 1.
*            ZMM_PREP_ROLEREQ-NAMECR = ist_data-name.
*            ZMM_PREP_ROLEREQ-DESIGCR = ist_data-designation.
*        endif.

  endif.

*       clear : ist_data.
*       refresh : ist_data.


  if ZMM_PREP_ROLEREQ-USERIDAP is initial.

    if old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      clear zusrmst.

      select single * from zusrmst where cpfno =
                            ZMM_PREP_ROLEREQ-useridap.
      if sy-subrc ne 0.

      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.
      endif.
    endif.

  else.

    if old_ok_code = 'APPROVE' and
          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X' and
                ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.

      ZMM_PREP_ROLEREQ-USERIDAP = sy-uname.
      ZMM_PREP_ROLEREQ-APP_DATE  = sy-datum.

      select single * from zusrmst where cpfno =
                              ZMM_PREP_ROLEREQ-userid.
      if sy-subrc ne 0.
        message e043(zhelp).
      else.
        concatenate zusrmst-first_name zusrmst-last_name into
        zusrmst-last_name.
        ZMM_PREP_ROLEREQ-NAMEAPP = zusrmst-last_name.
      endif.

    endif.

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
******************************

**Lines deleted for admn tasks

******************************
  if g_fundc_err_flag <> 'X'.

*    if corr_code = 'CORR' and sy-tcode = 'ZMM_AUTH_CORETEAM'.
*      clear : corr_code.
**        ZMM_PREP_ROLEREQ-REQ_CR_FL,
**        ZMM_PREP_ROLEREQ-REQ_APP_FL,
**        ZMM_PREP_ROLEREQ-REQ_APP1_FL.
*      if ZMM_PREP_ROLEREQ-comm_fl = 'X'.
*        ZMM_PREP_ROLEREQ-STATUS = 'IR'.
*      else.
*        ZMM_PREP_ROLEREQ-STATUS = 'IC'.
*      endif.
*      perform send_sapmail.
*      refresh object_content.
*      clear corr_code.
*    endif.

*************************************************************

*    if corr_code = 'CORR' and ZMM_PREP_ROLEREQ-comm_fl = ''.
*      ZMM_PREP_ROLEREQ-status = 'IC'.
*    endif.

*    if corr_code = 'CORR' and ZMM_PREP_ROLEREQ-comm_fl = 'X'.
*      ZMM_PREP_ROLEREQ-status = 'IR'.
*    endif.

*     modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    Perform insert_items.

*     if sy-subrc = 0 and ZMM_PREP_ROLEREQ-status <> 'C'.

    if sy-subrc = 0 .

*lines deleted for admn tasks

    endif.

    modify ZMM_PREP_ROLEREQ from ZMM_PREP_ROLEREQ.

    clear : g_request_close_flag_P, g_request_close_flag_H,
            g_request_close_flag_R.

****Saving the long text.                              *****

    IF ( old_ok_code = 'CREATE' ) or ( OLD_OK_CODE = 'CHANGE' )
        or ( OLD_OK_CODE = 'RELEASE' )
        or ( OLD_OK_CODE = 'APPROVE' ).
      perform save_cors_text.
    ENDIF.

    if g_role_flag = 'X'.
      clear g_role_flag.
      perform unlock_record.

    else.
*           perform clear.
*           perform unlock_record.
*           call screen 100.
      if l_old_ok_code = 'X'.
        SET PARAMETER ID 'ZOLDCODE' field l_initial.
        leave program.
      else.
        perform clear.
        perform unlock_record.
        call screen 100.
      endif.

    endif.

*     endif.
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

  DATA  : i like sy-index .
  Clear : wa_itemtab, ist_itemtab.

  sort g_TABCTRL100_itab
  by role_name plant grp  sloc receipt_loc approver.

  delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp  sloc receipt_loc approver rej_fl
    role_type_ex crc_pos.

  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.

    move-corresponding g_TABCTRL100_wa to wa_itemtab.

    if g_role_flag = 'X' and wa_itemtab-rej_fl = '' and
        wa_itemtab-status = '' and wa_itemtab-role_request = ''.
      wa_itemtab-role_request = ZROLEREQNO.
    endif.

    if old_ok_code = 'CREATE'.
      wa_itemtab-docno = ZDOCNUMB.
    endif.

    if wa_itemtab-rej_fl <> ''.
      wa_itemtab-rej_fl_save = 'X'.
    endif.


    wa_itemtab-mandt = sy-mandt.
    if not wa_itemtab-role_name is initial.
      i = i + 1.
      wa_itemtab-srno = i .
      append wa_itemtab to ist_itemtab.
    endif.

    g_i = i.

    Perform check_items_save.

  endloop.

  if g_lines_rl = 0.
    if old_ok_code = 'CHANGE'.
      delete from ZMM_PREP_ROLEREQ
            where docno = ZMM_PREP_ROLEREQ-docno.
      delete from ZMM_PREP_ROLEREI
            where docno = ZMM_PREP_ROLEREQ-docno.
      if sy-subrc = 0.
        set cursor field 'ZMM_PREP_ROLEREQ-DOCNO'.
        message i099(zhelp) with ZMM_PREP_ROLEREQ-docno.
      endif.
    else.
      rollback work.
    endif.
  else.

    delete from ZMM_PREP_ROLEREI where docno = wa_itemtab-docno.

    modify ZMM_PREP_ROLEREI from table ist_itemtab.

    if sy-subrc = 0 and g_role_flag <> 'X'.
      message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
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
     old_ok_code = 'CHANGE' or
     old_ok_code = 'DELETE' or
     old_ok_code = 'RELEASE' or
     old_ok_code = 'APPROVE'.

" Begin of <RD1K960036>.
*
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*         EXPORTING
*              TEXTLINE1      = 'Data will be lost, Want to quit? '
*              TITEL          = 'EXIT'
*              START_COLUMN   = 25
*              START_ROW      = 6
*              CANCEL_DISPLAY = ''
*         IMPORTING
*              ANSWER         = l_choice1.

    DATA : L_GET(1) TYPE C.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'EXIT '
        TEXT_QUESTION               = 'Data will be lost, Want to quit? '
       DISPLAY_CANCEL_BUTTON       = ' '
       START_COLUMN                = 25
       START_ROW                   = 6
     IMPORTING
       ANSWER                      = L_GET
     EXCEPTIONS
       TEXT_NOT_FOUND              = 1
       OTHERS                      = 2
              .
    IF SY-SUBRC = 0.
       CASE L_GET.
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
      if l_old_ok_code = 'X'.
*              data : l_initial.
        SET PARAMETER ID 'ZOLDCODE' field l_initial.
        leave program.
      else.
        call screen 100.
      endif.
    else.
    ENDIF.

  else.

    if l_old_ok_code = 'X' and old_ok_code = 'DISPLAY'.
      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      leave program.
    else.

      if sy-tcode = 'ZPREPTEST3'.
        leave program.
      else.
        perform clear.
        perform unlock_record.
        call screen 100.
      endif.

    endif.

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

  data : l_del_docno like zmm_prep_rolereq-docno.

  CALL FUNCTION 'DEQUEUE_EZ_MM_PREPHDR'
       EXPORTING
            MODE_ZMM_PREP_ROLEREQ = 'E'
            MANDT                 = SY-MANDT
            DOCNO                 = zmm_prep_rolereq-docno.

  if sy-subrc = 0.
    clear g_lock.
  endif.

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
  clear   : zmm_prep_rolerei, zmm_prep_rolereq.
  clear   : it_tab.
  refresh : tlinetab1[],tlinetab2[].


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

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
 or ( old_ok_code = 'RELEASE' )
 or ( OLD_OK_CODE = 'APPROVE' ).

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
  If old_ok_code <> 'CREATE'.
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

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' ).

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

  if sy-tcode <> 'ZMM_AUTH_CORETEAM'.

    if old_ok_code <> 'DISPLAY' and old_ok_code <> 'APPROVE'.

*      if  ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
*      else.
*        message e046(zhelp).
*      endif.

    endif.

    if old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
      perform verify.
*          message e055(zhelp).
    endif.

  else.

    if ( old_ok_code = 'CHANGE' or old_ok_code = 'DELETE' ) and
                            ( ZMM_PREP_ROLEREQ-STATUS = 'IC' or
                              ZMM_PREP_ROLEREQ-STATUS = 'IR' ).
*           message e072(zhelp).

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
             EXPORTING
              TEXTLINE1   = 'Can''t cahnge / delete this document it is with creator'.

      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      old_ok_code = 'DISPLAY'.
      call screen 100.

    endif.

    if ZMM_PREP_ROLEREQ-status  = 'C'
       and old_ok_code <> 'DISPLAY'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
         EXPORTING
              TEXTLINE1   = 'Request can not be changed Can only be displayed'.

*              message e079(zhelp).
*               perform clear.
      SET PARAMETER ID 'ZOLDCODE' field l_initial.
      old_ok_code = 'DISPLAY'.
*                 call screen 100.

    endif.


  endif.

  if old_ok_code = 'APPROVE' and
                    ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    if g_user = 'IM' or g_user = 'L1'.
    else.
      message e048(zhelp).
    endif.
  endif.

  if old_ok_code = 'RELEASE' and ZMM_PREP_ROLEREQ-REQ_CR_FL = 'X'.
    message e053(zhelp).
  endif.

  if old_ok_code = 'APPROVE'.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp).
    endif.

    if ( g_user = 'IM' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP0_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp)..
    endif.

    if ( g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = ' ' and
       ZMM_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
      message e051(zhelp)..
    endif.

    if g_user = 'L1' and ZMM_PREP_ROLEREQ-REQ_APP1_FL = 'X'.
      message e049(zhelp).
    endif.

    if ( g_user = 'IM' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP0_FL = 'X'.
      message e050(zhelp)..
    endif.

    if ( g_user = 'L3' ) and
                          ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.
      message e050(zhelp)..
    endif.

  endif.

  if old_ok_code <> 'DISPLAY' and
       ( ZMM_PREP_ROLEREQ-REQ_APP_FL <> 'X' and
       ZMM_PREP_ROLEREQ-REQ_APP0_FL <> 'X' and
       ZMM_PREP_ROLEREQ-REQ_APP1_FL <> 'X' ) and
       sy-tcode <> 'ZMM_ARMS_ADMN'.
    message i080(zhelp).
    g_reset_change = 'X'.
    old_ok_code = 'DISPLAY'.
    perform change_status.
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

  if ZMM_PREP_ROLEREI-rej_fl = ''.


    if old_ok_code = 'APPROVE' and
                      ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
      if g_user = 'IM' or g_user = 'L1'.
      else.
        message e048(zhelp).
      endif.
    endif.

    if old_ok_code = 'APPROVE' and g_user = 'L1' and
                 ZMM_PREP_ROLEREQ-REQ_APP_FL <> 'X'.
      ZMM_PREP_ROLEREQ-REQ_APP_FL = 'X'.

    endif.

  endif.

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
    message i045(zhelp) with ZMM_PREP_ROLEREQ-docno.
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
*       EXPORTING
*               TEXTLINE1      = 'Request already released Flags will be reset? '
*            TITEL          = 'RESET'
*            DEFAULTOPTION  = 'N'
*            START_COLUMN   = 25
*            START_ROW      = 6
*            CANCEL_DISPLAY = ''
*       IMPORTING
*            ANSWER         = l_choice.

  DATA : L_GET4(1) TYPE C.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'RESET'
      TEXT_QUESTION               = 'Request already released Flags will be reset? '
     DEFAULT_BUTTON              = '2'
     DISPLAY_CANCEL_BUTTON       = ' '
     START_COLUMN                = 25
     START_ROW                   = 6
   IMPORTING
     ANSWER                      = L_GET4
   EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
            .
  IF SY-SUBRC = 0.
       CASE L_GET4.
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
    clear zmm_prep_rolereq-req_app1_fl.
    perform save_request.
    clear l_choice.
  endif.

ENDFORM.                    " verify
*&---------------------------------------------------------------------*
*&      Form  upload1_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload1_file.

select * from zhelp_mmroles into corresponding fields of table it_roles.

ENDFORM.                    " upload1_file
*&---------------------------------------------------------------------*
*&      Form  help_suim
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM help_suim.

  select * from agr_users into table it_agr_users
                  where uname = zmm_prep_rolereq-userid ORDER BY PRIMARY KEY.

  refresh it_role_del_data.

  loop at it_agr_users into wa_agr_users.
*
    if wa_agr_users-from_dat <= sy-datum.
      write: / wa_agr_users-agr_name.
      wa_role_del_data-userid = wa_agr_users-uname.
      wa_role_del_data-role_name = wa_agr_users-agr_name.
      append wa_role_del_data to it_role_del_data.
      HIDE :  wa_agr_users-agr_name.
      CLEAR :  wa_agr_users-agr_name.
    endif.
  endloop.
  lines = sy-linno .
  it_roles[] = it_role_del_data[].

  describe table it_role_del_data lines g_lines1.

  if g_lines1 > 0.

" Begin of <RD1K960036>.
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
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.


     CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = 'C:\role_upload.txt'
        FILETYPE                = 'DAT'
      TABLES
        DATA_TAB                = it_role_del_data
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.

          IF SY-SUBRC <> 0.
           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
   ENDIF.
" End of <RD1K960036>.

    clear disp_flag.
    message i059(zhelp).
    clear old_ok_code.

*  endif.


ENDFORM.                    " help_suim
*&---------------------------------------------------------------------*
*&      Form  hide
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM hide.

  move 'REQ1' to wa_TAB.
  append wa_tab to tab.

ENDFORM.                    " hide
*&---------------------------------------------------------------------*
*&      Form  confirm_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_mail.

" Begin of <RD1K960036>.

*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            TEXTLINE1 = text-008
*            TITEL     = text-009
*       IMPORTING
*            ANSWER    = g_ans_mail.

DATA : L_GET1(1) TYPE C.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = text-009
    TEXT_QUESTION               = text-008
   DEFAULT_BUTTON              = '1'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = L_GET1
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_GET1.
         WHEN '1'.
           MOVE 'J' TO g_ans_mail.
           WHEN '2'.
             MOVE 'N' TO g_ans_mail.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

  If g_ans_mail = 'J'.
    perform SEND_SAPMAIL.
  endif.

  clear object_content.
  refresh object_content.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM SEND_SAPMAIL                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SEND_SAPMAIL.

*--- Send mail to user

*
  document_data-obj_langu  = sy-langu.
  document_data-obj_name   = 'ICE Core Team'.
  document_data-obj_descr  = 'Mail from ICE Core Team'.
  document_data-priority   = '3'.

* Remove prefix 'US' from receiver
  refresh receivers.

  clear wa_receivers.
  wa_receivers-receiver = zmm_prep_rolereq-useridcr.
  wa_receivers-rec_type = 'B'.
  wa_receivers-express  = 'X'.
  append wa_receivers to receivers.

  clear wa_receivers.

  move space to object_content-line.
  append object_content.

  concatenate  'Subject: '  'Creation of Roles for userid '
zmm_prep_rolereq-userid into  object_content-line
separated by space.
  append object_content.

  move space to object_content-line.
  append object_content.
  if ZMM_PREP_ROLEREQ-STATUS = 'C'.
      concatenate 'Please check your role request which has been'
&'assigned & completed - ' zmm_prep_rolereq-docno into
object_content-line
separated by space.
    append object_content.
  else.
      concatenate 'Please check your role request which has been updated  - ' zmm_prep_rolereq-docno into  object_content-line
separated by space.
    append object_content.
  endif.
********************************************************************
  if ZMM_PREP_ROLEREQ-STATUS = 'IC'.
      Move 'Please go through correspondence in the request. The request '
 &'needs to be changed, re-released & re-approved by competent authority. '
&'Once the request is approved, the request will flow to ICE core team.'
 to object_content-line.
    append object_content.
  endif.
  if ZMM_PREP_ROLEREQ-STATUS = 'IR'.
      Move 'Please go through the correspondence in the request & reply '
&'to the query raised by ICE core team. You need to save the request after'
 &'giving reply in correspondence(In display mode only). Once the request'
&'is saved, the request will flow to ICE core team.'
to object_content-line.
    append object_content.
     Move 'No re-release or approvals are required in this case & user'
&'will not be able to open the request in change mode.'
to object_content-line.
    append object_content.
  endif.
  if ZMM_PREP_ROLEREQ-STATUS = 'PC'.
      Move 'Your request is still under process with ICE core team. Only'
 &'partial roles have been assigned. You will get the next message for'
&'completion or return of request soon.'
to object_content-line.
    append object_content.
  endif.
********************************************************************
  move space to object_content-line.
  append object_content.

  object_content-line = 'ICE Core Team'.
  append object_content.

  call function 'SO_NEW_DOCUMENT_SEND_API1'
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

  case sy-subrc.
    when 0.

      message i060(zhelp) with zmm_prep_rolereq-useridcr.
    when '01'.
      raise too_many_receivers.
    when '02'.
      raise document_not_sent.
    when '03'.
      raise document_type_not_exist.
    when '04'.
      raise operation_no_authorization.
    when '05'.
      raise parameter_error.
    when '06'.
      raise x_error.
    when '07'.
      raise enqueue_error.
  endcase.

********************************************
********************************************
ENDFORM.                    " send_sapmail
*&---------------------------------------------------------------------*
*&      Form  create_roles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_roles.

  clear it_roles0.
  clear it_roles1.

  LOOP AT it_roles into WA_ROLES.

    PERFORM check_mum.
    APPEND WA_ROLES to it_roles0.

  ENDLOOP.

  ClEAR wa_roles.
  LOOP AT it_roles0 INTO wa_roles.

    if not wa_roles-role_type is initial.

      loop at g_TABCTRL100_itab into wa_rolesz.
        if wa_roles-role_type = wa_rolesz-role_name and
                                wa_rolesz-rej_fl = '' and
                                wa_rolesz-status = '' and
                                wa_rolesz-role_request = ''.
          PERFORM insert_data.
        endif.
      endloop.

    endif.

  ENDLOOP.

  sort it_roles1.

**** Deleting tempelate as it gets added in logic

  loop at it_roles1 into wa_role_del_data.

    if wa_role_del_data-role_name = 'D:MM_SRV_IND_APPROVE_XX'
     or wa_role_del_data-role_name = 'D:MM_PUR_PO_APPROVE_XX'.
      DELETE it_roles1.
    endif.
  endloop.

  DELETE ADJACENT DUPLICATES FROM it_roles1.

  loop at it_roles1 into wa_roles1.

    WRITE zmm_prep_rolereq-fr_date_auth to wa_dat1 dd/mm/yyyy.

    WRITE zmm_prep_rolereq-to_date_auth to wa_dat2 dd/mm/yyyy.

    wa_roles1-fr_date_auth = wa_dat1.
    wa_roles1-to_date_auth = wa_dat2.
    modify it_roles1 from wa_roles1.
    clear wa_roles1.
  endloop.

  PERFORM DOWNLOAD_FILE.

  Perform copy_values.

  Perform confirm_step.

  if gl_ans = 'J'.
    Perform insert_record.
    Perform save_request.
  endif.

  perform list_processing.

*
  clear : flag, flag1.

ENDFORM.                    " create_roles
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
  IF zmm_prep_rolereq-ccode = 'MUM'.
    SEARCH WA_ROLES-ROLE_NAME for 'D:FM_LOGS_FFFFFFFF'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FM_LOGS_FFFFFFFF'.
    ENDIF.
    SEARCH WA_ROLES-ROLE_NAME for 'FI_AP_LOGS_DISP_CCC'.
    IF SY-SUBRC = 0.
      WA_ROLES-ROLE_NAME = 'FI_AP_LOGS_DISP_CCC_AL'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_mum
*&---------------------------------------------------------------------*
*&      Form  insert_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_data.

  SEARCH WA_ROLES-ROLE_NAME for 'INPP'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'INPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  Endif.
*
  SEARCH WA_ROLES-ROLE_NAME for 'SSPP'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    REPLACE 'SSPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'PLANT'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'PPPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'POPP'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                WA_ROLES1-ROLE_NAME.
    REPLACE 'POPP' with wa_rolesz-plant INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME for 'IGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                  WA_ROLES1-ROLE_NAME.
    REPLACE 'IGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

*
  SEARCH WA_ROLES-ROLE_NAME for 'SGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                        WA_ROLES1-ROLE_NAME.
    REPLACE 'SGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME for 'PGG'.
  IF SY-SUBRC = 0.
    Flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                    WA_ROLES1-ROLE_NAME.
    REPLACE 'PGG' with wa_rolesz-grp INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'CCC'.
  IF SY-SUBRC = 0.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    if flag <> 'X'.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'CCC' with zmm_prep_rolereq-ccode+0(3) INTO
                                    WA_ROLES1-ROLE_NAME.
*      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    FLAG = 'X'.
    if wa_roles-role_type = 'M12' or wa_roles-role_type = 'M17'.
      REPLACE 'RR' with wa_rolesz-receipt_loc+0(2) INTO
                                              WA_ROLES1-ROLE_NAME.


    endif.

    APPEND WA_ROLES1 to IT_ROLES1.

    select single * from zhelp_mmroles_rc where
                        receipt_loc = wa_rolesz-receipt_loc and
                        ccode = ZMM_PREP_ROLEREQ-ccode.
    if sy-subrc = 0.
      wa_roles1-role_name = zhelp_mmroles_rc-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.



  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'FM_LOGS'.
  IF SY-SUBRC = 0.
    flag = 'X'.

    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    if zmm_prep_rolereq-fundc1 <> '' and
          zmm_prep_rolereq-fundc_fl = 'X'.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc1 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc2 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc2 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc3 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc3 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.
    if zmm_prep_rolereq-fundc4 <> ''.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'FFFFFFFF' with zmm_prep_rolereq-fundc4 INTO
                         WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    endif.

  ENDIF.

  SEARCH WA_ROLES-ROLE_NAME for 'MM_SRV_SES_ACCEPT'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'YY' with wa_rolesz-approver INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.
*
  SEARCH WA_ROLES-ROLE_NAME for 'MM_PUR_PO_APPROVE_ZZ'.
  IF SY-SUBRC = 0.
    flag = 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    REPLACE 'ZZ' with wa_rolesz-approver INTO WA_ROLES1-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.

  IF flag <> 'X'.
    WA_ROLES1-USERID = zmm_prep_rolereq-userid.
    WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
    APPEND WA_ROLES1 to IT_ROLES1.
  ENDIF.
  CLEAR flag.

  If wa_roles-role_type = 'M13'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  If wa_roles-role_type = 'M14'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  If wa_roles-role_type = 'M16'.
    IF FLAG1 <> 'X'.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      SELECT * FROM ZMM_PREP_ROLE_SL UP TO 1 ROWS
 WHERE
 WERKS = WA_ROLESZ-PLANT AND LGORT = WA_ROLESZ-SLOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      WA_ROLES1-ROLE_NAME = zmm_prep_role_sl-role_name.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.

  IF wa_roles-role_type = 'M11S' or
     wa_roles-role_type = 'M11M' or
     wa_roles-role_type = 'M3' .

    SEARCH WA_ROLES-ROLE_NAME for 'XX'.
    IF SY-SUBRC = 0.
      WA_ROLES1-USERID = zmm_prep_rolereq-userid.
      WA_ROLES1-ROLE_NAME = WA_ROLES-ROLE_NAME.
      REPLACE 'XX' with wa_rolesz-approver INTO
                                    WA_ROLES1-ROLE_NAME.
      APPEND WA_ROLES1 to IT_ROLES1.
    ENDIF.
  ENDIF.


ENDFORM.                    " insert_data
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FILE.
  IF NOT p1_file IS INITIAL.

* Download the file on presentation server
" Begin of <RD1K960036>.
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
*
*    IF sy-subrc <> 0.
*
*      MESSAGE i061(Zhelp) WITH text-053.
*
*      EXIT.
*
*    ENDIF.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = p1_file
        FILETYPE                = 'DAT'
      TABLES
        DATA_TAB                = it_roles1
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.

          IF SY-SUBRC <> 0.
           MESSAGE i061(Zhelp) WITH text-053.
           EXIT.
   ENDIF.
" End of <RD1K960036>.

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

  if not zrolereqno is initial.
    ZMM_PREP_ROLEREQ-req_no = zrolereqno.
  endif.

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
" Begin of <RD1K960036>.


*  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*            DEFAULTOPTION = 'Y'
*            TEXTLINE1     = 'Role request being created'
*            TEXTLINE2     = 'Continue ??? '
*            TITEL         = 'Confirm'
*       IMPORTING
*            ANSWER        = gl_ans.

DATA : L_GET3(1) TYPE C.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
   TITLEBAR                    = 'Confirm '
    TEXT_QUESTION               = 'Role request being created Continue ???'
   DEFAULT_BUTTON              = '1'
   DISPLAY_CANCEL_BUTTON       = ' '
   START_COLUMN                = 25
   START_ROW                   = 6
 IMPORTING
   ANSWER                      = L_GET3
 EXCEPTIONS
   TEXT_NOT_FOUND              = 1
   OTHERS                      = 2
          .
IF SY-SUBRC = 0.
       CASE L_GET3.
         WHEN '1'.
           MOVE 'J' TO gl_ans.
           WHEN '2'.
             MOVE 'N' TO gl_ans.
             ENDCASE.
             ENDIF.
" End of <RD1K960036>.

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
*  okcode_100 = 'SAV'.
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

  if gl_ans = 'J'.
    suppress dialog.
    leave to list-processing and return to screen 100.
    PERFORM write_list.
    g_list_proc_flag = 'X'.
    clear gl_ans.
  endif.

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

  set pf-status 'STATUS_130' excluding 'SEL'.

  read table it_roles1 into wa_roles1 index 1.
  g_userid = wa_roles1-userid.
  l_color = 5.
  Loop at it_roles1 into wa_roles1.
    if g_userid = wa_roles1-userid.
      Write : / wa_roles1-userid color 1,wa_roles1-role_name color 2.
    else.
      Write : / wa_roles1-userid color 3,wa_roles1-role_name color 3.
    Endif.
    g_userid = wa_roles1-userid.
  Endloop.

ENDFORM.                    " write_list
*&---------------------------------------------------------------------*
*&      Form  change_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_status.

  Perform fill_sttab.

  if old_ok_code = 'CREATE' or old_ok_code = 'CHANGE' or
      old_ok_code = 'DISPLAY' or old_ok_code = 'DELETE'.

    SET PF-STATUS 'OPTNS1' excluding it_tab.

  else.

    SET PF-STATUS 'OPTNS'.

  endif.

  case sy-ucomm.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' with ': Change Request'.
    when 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' with ': Display Request'.
    when 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' with ': Delete Request'.
    when 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' with ': Release Request'.

    when others.
      SET TITLEBAR 'PREP_TITLE' with ''.
  endcase.

ENDFORM.                    " change_status
*&---------------------------------------------------------------------*
*&      Form  check_list_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_list_processing.

  if g_list_proc_flag = 'X'.
    leave program.
  endif.

ENDFORM.                    " check_list_processing
*&---------------------------------------------------------------------*
*&      Form  scr100_attr_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM scr100_attr_check.

  CASE old_ok_code.

    when ''.

      loop at screen.
        screen-input = 0.
        modify screen.
      endloop.

    when 'CREATE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'CHANGE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'RELEASE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'APPROVE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'TABCTRL100_DELETE'.
          screen-input = 0.
          modify screen.
        endif.

      if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
   .
          screen-input = 1.
          modify screen.
        endif.
        if ( g_user = 'IM' or g_user = 'L3' ) and
            screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'DISPLAY'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

      endloop.

    when 'DELETE'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

      endloop.


  ENDCASE.


ENDFORM.                    " scr100_attr_check
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

    select single * from zmm_prep_roledes where role_type =
                                                wa_itemtab-role_name.
    if sy-subrc = 0.

*      if zmm_prep_roledes-plant = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE') and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-plant is initial.
*          g_field = 'ZMM_PREP_ROLEREI-PLANT'.
*          message i084(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zmm_prep_roledes-p_grp = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE'  or
*                    old_ok_code = 'CREATE') and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-grp is initial.
*          g_field = 'ZMM_PREP_ROLEREI-GRP'.
*          message i085(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zmm_prep_roledes-s_loc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE') and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-sloc is initial.
*          g_field = 'ZMM_PREP_ROLEREI-SLOC'.
*          message i090(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zmm_prep_roledes-r_loc = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE' ) and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-receipt_loc is initial.
*          g_field = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.
*          message i095(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*      if zmm_prep_roledes-app_level = 'X' and
*                     ( old_ok_code = 'APPROVE' or
*                    old_ok_code = 'RELEASE' or
*                    old_ok_code = 'CHANGE' or
*                    old_ok_code = 'CREATE') and
*                    not wa_itemtab-role_name is initial.
*
*        if wa_itemtab-approver is initial.
*          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
*          message i096(zhelp) with g_i.
*          clear okcode_100.
*          call screen 100.
*        endif.
*      endif.
*
*
*
    endif.
  endif.
ENDFORM.                    " check_items_save
*&---------------------------------------------------------------------*
*&      Form  check_tel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tel.
  if ( old_ok_code = 'DISPLAY' or old_ok_code = 'CHANGE' or
         old_ok_code = 'DELETE' or old_ok_code = 'CREATE'
         or old_ok_code = 'RELEASE' or OLD_OK_CODE = 'APPROVE' )
         and g_hd_copied = 'X'.
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
*&      Form  status_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM status_update.
  loop at g_TABCTRL100_itab into wa_rolesz.

    if wa_rolesz-rej_fl = '' and
       wa_rolesz-status = '' and
       wa_rolesz-role_request = ''.
      g_status_update_flag = 'X'.
    else.
      if wa_rolesz-role_request <> ''.
        g_status_update_rolereq = 'X'.
      endif.
    endif.
  endloop.
ENDFORM.                    " status_update
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
            ATTACHMENT_DATA     = ''
            ATTACHMENT_TYPE     = 'DOC'
       TABLES
            APPLICATION_OBJECTS = g_att_files.
ENDFORM.                    " attach_files
*&---------------------------------------------------------------------*
*&      Form  auth_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM auth_check.
  select single * from zmm_prep_usrcont where
             bname = sy-uname.
  if sy-subrc <> 0.
    message i104(zhelp).
    old_ok_code = 'DISPLAY'.
  else.
    perform auth_check1.
*   old_ok_code = 'CHANGE'.
  endif.

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

  if zmm_prep_rolereq-crc_fl = 'X' and
     zmm_prep_usrcont-crc_app = 'X'.
*     old_ok_code = 'CHANGE'.
  elseif
     zmm_prep_rolereq-crossco_fl = 'X' and
     zmm_prep_usrcont-crossco_app = 'X'.
*     old_ok_code = 'CHANGE'.
  else.
    if  zmm_prep_usrcont-gen_app = 'X' and
        zmm_prep_rolereq-crc_fl <> 'X' and
          zmm_prep_rolereq-crossco_fl <> 'X' .
*         old_ok_code = 'CHANGE'.
    else.
      message i104(zhelp).
      old_ok_code = 'DISPLAY'.
    endif.
  endif.


ENDFORM.                    " auth_check1
*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_auth.

 AUTHORITY-CHECK OBJECT 'ZMMARMSADM'
                     ID 'ACTVT' FIELD : '01'.

  if sy-subrc <> 0.
    message e141(zhelp).
  endif.

ENDFORM.                    " check_auth
