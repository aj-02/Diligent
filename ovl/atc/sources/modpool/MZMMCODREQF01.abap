*--- MAIN PROGRAM: MZMMCODREQF01 ---*
*INCLUDE MZMMCODREQF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM Ws_Download Replaced With 'GUI_DOWNLOAD'.
*2) Obsolete FM Ws_Upload Replaced With 'GUI_UPLOAD'.
*3) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
*4) Obsolete FM WS_FILENAME_GET Replaced with  Method .
************************************************************************
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
   DATA L_110ITAB TYPE TABLE OF T_TABCTRL110.
   DATA X(80).
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
       PERFORM CHECK_TABROWS.
       IF G_MODE = 'CRE'.
         IF G_INSRFLG = 'Y'.
           PERFORM FCODE_INSERT_ROW
            USING P_TC_NAME P_TABLE_NAME.
           CLEAR P_OK.
         ENDIF.
       ELSE.
         PERFORM FCODE_INSERT_ROW
          USING P_TC_NAME P_TABLE_NAME.
         CLEAR: P_OK,L_OK,SY-UCOMM.
       ENDIF.
     WHEN 'DELE'.                      "delete row
*
       CASE ZMM_CDHD_ST-MTART.
         WHEN 'ZSTO'.
           PERFORM ADD_DELITEM110.
         WHEN 'ZSPR'.
           PERFORM ADD_DELITEM120.
         WHEN 'ZCAP'.
           PERFORM ADD_DELITEM130.
         WHEN 'ZDIS'.
           PERFORM ADD_DELITEM140.
       ENDCASE.
*
       IF G_DELFLAG <> 'N'.
*
         PERFORM CONFIRM_DELETION.
         IF G_CONFDEL = 'J'.
           PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                            P_TABLE_NAME
                                            P_MARK_NAME.
           CLEAR G_CONFDEL.
         ENDIF.
       ENDIF.
       CLEAR G_DELFLAG.
       CLEAR P_OK.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                             L_OK.
       CLEAR P_OK.
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

*
     WHEN 'FILTER'.
       READ  TABLE TABCTRL110-COLS WITH  KEY SELECTED = 'X' INTO
           WA_TABCTRL110_COLS .
       IF SY-SUBRC <> 0.
         MESSAGE I030(ZMM_OTH).
       ENDIF.
       G_FILNAME = WA_TABCTRL110_COLS-SCREEN-NAME.
       CALL SCREEN 150 STARTING AT 20 05 ENDING AT 80 10.
*
       CLEAR: P_OK,WA_TABLCTRL120_COLS.

     WHEN 'SORTU'.
       G_ORDER = 'ASCENDING'.
       CASE ZMM_CDHD_ST-MTART.
         WHEN 'ZSTO'.
           PERFORM SORT_STO USING G_ORDER.
           CLEAR: P_OK,WA_TABCTRL110_COLS.
         WHEN 'ZSPR'.
           PERFORM SORT_SPR USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL120_COLS.
         WHEN 'ZCAP'.
           PERFORM SORT_CAP USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL130_COLS.
         WHEN 'ZDIS'.
           PERFORM SORT_DIS USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL140_COLS.
       ENDCASE.
     WHEN 'SORTD'.
       G_ORDER = 'DESCENDING'.
       CASE ZMM_CDHD_ST-MTART.
         WHEN 'ZSTO'.
           PERFORM SORT_STO USING G_ORDER.
           CLEAR: P_OK,WA_TABCTRL110_COLS.
         WHEN 'ZSPR'.
           PERFORM SORT_SPR USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL120_COLS.
         WHEN 'ZCAP'.
           PERFORM SORT_CAP USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL130_COLS.
         WHEN 'ZDIS'.
           PERFORM SORT_DIS USING G_ORDER.
           CLEAR: P_OK,WA_TABLCTRL140_COLS.
       ENDCASE.
   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_INSERT_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA: L_ITAB110 LIKE G_TABCTRL110_WA OCCURS 0,
         L_ITAB120 LIKE G_TABLCTRL120_WA OCCURS 0,
         L_ITAB130 LIKE G_TABLCTRL130_WA OCCURS 0,
         L_ITAB140 LIKE G_TABLCTRL140_WA OCCURS 0.

   DATA L_LINES_NAME       LIKE FELD-NAME.
   DATA L_SELLINE          LIKE SY-STEPL.
   DATA L_LASTLINE         TYPE I.
   DATA L_LINE             TYPE I.
   DATA L_TABLE_NAME       LIKE FELD-NAME.
   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <LINES>  TYPE I.                           "#EC *
**-END OF LOCAL
*
   CLEAR L_SELLINE.
   REFRESH:L_ITAB110,L_ITAB120,L_ITAB130,L_ITAB140.
   ASSIGN (P_TC_NAME) TO <TC>.
   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
   ASSIGN (L_TABLE_NAME) TO <TABLE>.
*
   APPEND INITIAL LINE TO <TABLE>.
   <TC>-LINES = <TC>-LINES + 1.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM FCODE_DELETE_ROW
               USING    P_TC_NAME           TYPE DYNFNAM
                        P_TABLE_NAME
                        P_MARK_NAME   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   DATA L_TABLE_NAME       LIKE FELD-NAME.

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
   FIELD-SYMBOLS <LINES>      TYPE I.
   DATA L_TC_ITAB_NAME        LIKE FELD-NAME.
   DATA L_TOTLN               TYPE I.
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
*   no, ...
****Addition
     CASE ZMM_CDHD_ST-MTART.
       WHEN 'ZSTO'.
         DESCRIBE TABLE G_TABCTRL110_ITAB LINES L_TOTLN.
       WHEN 'ZSPR'.
         DESCRIBE TABLE G_TABLCTRL120_ITAB LINES L_TOTLN.
       WHEN 'ZCAP'.
         DESCRIBE TABLE G_TABLCTRL130_ITAB LINES L_TOTLN.
       WHEN 'ZDIS'.
         DESCRIBE TABLE G_TABLCTRL140_ITAB LINES L_TOTLN.
     ENDCASE.
****End
     IF <TC> = TABCTRL100.
       CALL FUNCTION 'SCROLLING_IN_TABLE'
            EXPORTING
                 ENTRY_ACT             = <TC>-TOP_LINE
                 ENTRY_FROM            = 1
                 ENTRY_TO              = <TC>-LINES
*               ENTRY_TO              = l_totln
*               LAST_PAGE_FULL        = ''
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
     ELSE.
       CALL FUNCTION 'SCROLLING_IN_TABLE'
            EXPORTING
                 ENTRY_ACT             = <TC>-TOP_LINE
                 ENTRY_FROM            = 1
*               ENTRY_TO              = <TC>-LINES
                 ENTRY_TO              = L_TOTLN
                 LAST_PAGE_FULL        = ''
*               LAST_PAGE_FULL        = 'X'
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

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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

   FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
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
 FORM FILL_STTAB.
   REFRESH IT_TAB1.
   IF SY-TCODE <> 'ZCODG'.
     IF  DYNNR IS INITIAL.
       MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'CHECK' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.

      "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'LIST' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     "END OF ADDITION BY LIPSY ON 31.08.2012

     ELSE.
       MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
      "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
       IF SY-UCOMM = 'HELP'.
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'LIST' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHECK' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     ENDIF.
     "END OF ADDITION BY LIPSY ON 31.08.2012

     ENDIF.
   ENDIF.

"START OF COMMENT BY LIPSY ON 31.08.2012 <RD1K979105> for attaching files
*   IF G_MODE =  'CRE' OR
*      G_MODE =  'CHA' OR
*      G_MODE =  'REL' OR
*      G_MODE =  'APR' .
*     MOVE 'CREATE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'CHANGE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'DELETE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'DISPLAY' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'RELEASE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
*     MOVE 'APPROVE' TO WA_TAB-FCODE.
*     APPEND WA_TAB TO IT_TAB1.
"END OF COMMENT BY LIPSY ON 31.08.2012

     "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
      IF G_MODE =  'CRE' .
     MOVE 'CREATE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHANGE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DELETE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DISPLAY' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'RELEASE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'APPROVE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'LIST' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.

     ELSEIF  G_MODE =  'REL' OR
      G_MODE =  'APR' .
     MOVE 'CREATE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHANGE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DELETE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DISPLAY' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'RELEASE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'APPROVE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.


   ELSEIF   G_MODE =  'CHA' .
     MOVE 'CREATE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHANGE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DELETE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DISPLAY' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'RELEASE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'APPROVE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.




     "END OF ADDITION BY LIPSY
*   elseif g_mode = 'CHA' .
*     move 'CREATE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CHANGE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DELETE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DISPLAY' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'RELEASE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'APPROVE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CR_MATCODE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     if dynnr = '0101'.
*       move 'CR_MATCODE' to wa_tab-fcode.
*       append wa_tab to it_tab1.
*       move 'CHECK' to wa_tab-fcode.
*       append wa_tab to it_tab1.
*     endif.
"start of comment by lipsy on 17.10.2012 <RD1K979105> for attaching files
*   ELSEIF G_MODE = 'DEL' OR
*          G_MODE = 'DIS'.
 "end of comment by lipsy on 17.10.2012

  "start of addition by lipsy on 17.10.2012 <RD1K979105> for attaching files

      ELSEIF G_MODE = 'DEL' .

  "end of addition by lipsy on 17.10.2012
     MOVE 'CREATE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHANGE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DISPLAY' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DELETE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'RELEASE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'APPROVE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHECK' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.


     "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'LIST' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.


     elseif G_MODE = 'DIS'.

        MOVE 'CREATE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHANGE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DISPLAY' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'DELETE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'RELEASE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'APPROVE' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'CHECK' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.


     "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     "END OF ADDITION BY LIPSY ON 31.08.2012

*   elseif g_mode = 'REL'.
*     move 'CREATE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CHANGE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DELETE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DISPLAY' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'RELEASE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CR_MATCODE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'APPROVE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*   elseif g_mode = 'APR'.
*     move 'CREATE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CHANGE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DELETE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'DISPLAY' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'CR_MATCODE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'RELEASE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
*     move 'APPROVE' to wa_tab-fcode.
*     append wa_tab to it_tab1.
   ENDIF.

   IF SY-TCODE = 'ZCODG'.
     CLEAR WA_TAB.
     REFRESH IT_TAB1.
     IF G_MODE = 'COD'.
       MOVE 'CREATE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'CHANGE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'DELETE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'DISPLAY' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'APPROVE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'RELEASE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.

     "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     "END OF ADDITION BY LIPSY ON 31.08.2012

     ELSEIF G_MODE = 'DIS'.
       MOVE 'CREATE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'CHANGE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'DELETE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'APPROVE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'RELEASE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.
       MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
       APPEND WA_TAB TO IT_TAB1.

       "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
     MOVE 'ATTACH' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     MOVE 'HELP' TO WA_TAB-FCODE.
     APPEND WA_TAB TO IT_TAB1.
     "END OF ADDITION BY LIPSY ON 31.08.2012
     ENDIF.
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
 FORM FILL_MATTYP_ITEMDT.

   DATA L_CDHD LIKE ZMM_CDHD.

   IF G_MODE = 'CRE'.
     PERFORM SET_DYNNR USING ZMM_CDHD_ST-MTART.
   ELSE.
     SELECT SINGLE * INTO L_CDHD FROM ZMM_CDHD
            WHERE REQNO = ZMM_CDHD_ST-REQNO.
     IF SY-SUBRC = 0.
       PERFORM SET_DYNNR USING L_CDHD-MTART.
     ELSE.
*       message e003(zmm_oth) with zmm_cdhd_st-reqno.
     ENDIF.
*
     IF L_CDHD-MTART = 'ZSTO'.
       SELECT SINGLE * FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO
          AND   OTH1  = 'X'.
       IF SY-SUBRC = 0.
         G_TECHAPR_VISIBLE = 'Y'.
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
 FORM CHNG_ATTR_100.
   IF G_MODE = 'CRE'.
     LOOP AT SCREEN.
       IF SCREEN-NAME = 'ZMM_CDHD_ST-REQNO'.
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " chng_attr_100
*&---------------------------------------------------------------------*
*&      Form  SELECT_HELP_DATA
*&---------------------------------------------------------------------*
 FORM SELECT_MAT_DATA USING
                      PARTNO LIKE ZMM_CDITEM-USER_DESC
                      MATGP LIKE ZMM_MODIFIER-MATGRP
                      MTART LIKE MARA-MTART
                      CHANGING SEL_FLAG.

   DATA : L_LINES LIKE SY-INDEX.
   DATA : L_SRNO  LIKE SY-INDEX.
   DATA : L_LEN   LIKE SY-INDEX.
   DATA : L_LEN1  LIKE SY-INDEX.
   DATA : L_LEN2  LIKE SY-INDEX.
   DATA : L_CHECK.
   DATA : G_PARTNO1 LIKE ZMM_CDITEM-USER_DESC.
   DATA : G_PARTNO2 LIKE ZMM_CDITEM-USER_DESC.

   DATA : G_CAPCODE_NO   LIKE AUSP-ATINN.
   DATA : G_MODELCODE_NO LIKE AUSP-ATINN.
**
   DATA : L_120HITS TYPE T_TABLCTRL120.
   DATA : L_HITS TYPE I.
**
   DESCRIBE TABLE IST_SRCHLP LINES L_LINES.

*
   TRANSLATE DESC TO UPPER CASE.

   IF MTART = 'ZSPR'.

     IF  L_LINES = 0  OR FIELD1 = 'ZMM_CDITEM-PARTNO'.

       SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST B~ZZCAP_CODE B~ZZMODELNO B~ZZOEM_NAME B~ZZCAP_NAME
              INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
              FROM MAKT AS A JOIN MARA AS B
              ON    A~MATNR = B~MATNR
              WHERE B~MFRPN LIKE PARTNO
              AND ( B~MTART = MTART OR B~MTART = 'ZMPN' )
              AND B~MSTAE = ''.
*start of change by yogesh

*       if sy-subrc = 0.
******get capital code and model no in spares running search help
*         select single atinn from CABN into g_capcode_no
*                where atnam = 'Z_ONGC_CAPCODE'.
*         if sy-subrc <> 0.
*           g_capcode_no = ''.
*         Endif.
*         select single atinn from CABN into g_modelcode_no
*                where atnam = 'Z_ONGC_MODELCODE'.
*         if sy-subrc <> 0.
*           g_modelcode_no = ''.
*         Endif.
*         Loop at ist_srchlp into wa_srchlp.
*           if g_capcode_no <> ''.
*             select single atwrt from ausp into wa_srchlp-atwrt
*                   where objek = wa_srchlp-matnr
*                   and atinn = g_capcode_no.
*
*             modify  ist_srchlp from wa_srchlp index sy-tabix
*             transporting atwrt.
*           endif.
*           if g_modelcode_no <> ''.
*             select single atwrt from ausp into wa_srchlp-mdlno
*                   where objek = wa_srchlp-matnr
*                   and atinn = g_modelcode_no.
*
*             modify ist_srchlp from wa_srchlp index sy-tabix
*             transporting mdlno.
*           endif.
*         Endloop.
*
*       Endif.  "For sy-subrc = 0.
*end of change by yogesh


     ELSEIF FIELD1 = 'ZMM_CDITEM-DESC1'.

       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST B~ZZCAP_CODE B~ZZMODELNO B~ZZOEM_NAME B~ZZCAP_NAME
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE A~MAKTG LIKE DESC
       AND   B~MTART = MTART
       AND   B~MFRPN LIKE PARTNO
*
       AND B~MSTAE = ''.
*
       IF SY-SUBRC = 0.
*       sel_flag = '0'.
       ENDIF.
     ENDIF.

     FIELD-SYMBOLS <WA_SRCHLP> TYPE TY_SRCHLP.

     LOOP AT IST_SRCHLP ASSIGNING <WA_SRCHLP>.
       <WA_SRCHLP>-ATWRT = <WA_SRCHLP>-ZZCAP_CODE.
       <WA_SRCHLP>-MDLNO = <WA_SRCHLP>-ZZMODELNO.
     ENDLOOP.



*
     PERFORM CHANGE_PARTNO1 CHANGING G_PARTNO1 G_PARTNOC.
     L_LEN1 = STRLEN( G_PARTNO1 ).
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       PERFORM CHANGE_PARTNO2 CHANGING G_PARTNO2 WA_SRCHLP-MFRPN.
       L_LEN2 = STRLEN( G_PARTNO2 ).
       SEARCH G_PARTNO2 FOR G_PARTNO1.
       IF SY-SUBRC = 0 AND L_LEN1 = L_LEN2.
       ELSE.
         DELETE IST_SRCHLP.
       ENDIF.
     ENDLOOP.
   ENDIF.                " For matty = ZSPR


***For Store items
   IF MTART = 'ZSTO'.

     IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
                   OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
             AND B~MTART = MTART
             AND B~MSTAE = ''.
     ENDIF.

     IF SY-SUBRC = 0.
       SEL_FLAG = '1'.
     ENDIF.

   ENDIF.
***For Capital Items.
   IF MTART = 'ZCAP'.

     IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
                   OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
       AND B~MTART = MTART
       AND B~MSTAE = ''.
     ENDIF.

     IF SY-SUBRC = 0.
       SEL_FLAG = '1'.
     ENDIF.

   ENDIF.
**For disposal items.
   IF MTART = 'ZDIS'.
     IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
                    OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE ( A~MAKTG LIKE DESC OR B~WRKST LIKE DESC )
       AND B~MTART = MTART
       AND B~MSTAE = ''.
     ENDIF.

     IF SY-SUBRC = 0.
       SEL_FLAG = '1'.
     ENDIF.
   ENDIF.

   LOOP AT IST_SRCHLP INTO WA_SRCHLP.

*
     L_LEN = STRLEN( WA_SRCHLP-MAKTG ).
*
     L_LEN = L_LEN - 1.
     L_CHECK = WA_SRCHLP-MAKTG+L_LEN(1).
     IF L_CHECK = '*'.
       CONCATENATE WA_SRCHLP-MAKTG+0(L_LEN) WA_SRCHLP-WRKST INTO
       WA_SRCHLP-MAKTX.
     ELSE.
       MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
     ENDIF.

     TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.

     IF NOT DESC11 IS INITIAL.

       SEARCH WA_SRCHLP-MAKTX FOR DESC11.

       IF SY-SUBRC = 0.

         L_SRNO = L_SRNO + 1.

         WA_SRCHLP-SRNO = L_SRNO.

         MODIFY IST_SRCHLP FROM WA_SRCHLP.

       ELSE.

         DELETE IST_SRCHLP.

       ENDIF.

     ELSE.

       L_SRNO = L_SRNO + 1.

       WA_SRCHLP-SRNO = L_SRNO.

       MODIFY IST_SRCHLP FROM WA_SRCHLP.

     ENDIF.

   ENDLOOP.

 ENDFORM.                    "SELECT_MAT_DATA

***********************************
* Form SELECT_HELP_DATA
***********************************

 FORM SELECT_HELP_DATA USING VALUE(PARTNO) LIKE ZMM_CDITEM-USER_DESC
                             VALUE(DESC1) LIKE ZMM_CDITEM-DESC1
                             VALUE(DESC2) LIKE ZMM_CDITEM-DESC2
                             VALUE(DESC3) LIKE ZMM_CDITEM-DESC3
                             VALUE(DESC4) LIKE ZMM_CDITEM-DESC4
*{   INSERT         OCPK900087                                        1
**********************************************************************
*                             VALUE(STEUC) LIKE ZMM_CDITEM-STEUC
**********************************************************************
*}   INSERT
                             VALUE(DESC5) LIKE ZMM_CDITEM-USER_DESC
                             VALUE(MATGP) LIKE ZMM_MODIFIER-MATGRP
                             VALUE(MATTY) LIKE ZMM_CDHD_ST-MTART
                             CHANGING SEL_FLAG.

*{   INSERT         OCPK900087                                        3
*DATA: BEGIN OF WA_T604F,
*      LAND1 TYPE LAND1,
*      STEUC TYPE STEUC,
*  END OF WA_T604F,
*  ZMSG110 TYPE STRING.
**LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
*
* SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = STEUC.
*ENDSELECT.
*
*IF WA_T604F IS INITIAL.
*
* CONCATENATE STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
* MESSAGE ZMSG110 TYPE 'S' DISPLAY LIKE 'E'.
*ENDIF.
*}   INSERT

   DATA : L_SRNO TYPE I.

   IF NOT DESC1 IS INITIAL OR NOT PARTNO IS INITIAL.
     CONCATENATE '%' DESC1 '%' INTO DESC.
     PERFORM SELECT_MAT_DATA USING PARTNO MATGP MATTY CHANGING SEL_FLAG.
     CLEAR : WA_SRCHLP.
   ENDIF.

   CLEAR L_SRNO.
   IF NOT DESC2 IS INITIAL.

     LOOP AT IST_SRCHLP INTO WA_SRCHLP.

       TRANSLATE DESC2 TO UPPER CASE.

       SEARCH WA_SRCHLP-MAKTX FOR DESC2.

       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ELSE.
         L_SRNO = L_SRNO + 1.
         WA_SRCHLP-SRNO = L_SRNO.
         MODIFY IST_SRCHLP FROM WA_SRCHLP.
       ENDIF.

     ENDLOOP.

     SEL_FLAG = '2'.

   ENDIF.

   CLEAR L_SRNO.

   IF NOT DESC3 IS INITIAL.

     LOOP AT IST_SRCHLP INTO WA_SRCHLP.

       TRANSLATE DESC3 TO UPPER CASE.

       SEARCH WA_SRCHLP-MAKTX FOR DESC3.

       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ELSE.
         L_SRNO = L_SRNO + 1.
         WA_SRCHLP-SRNO = L_SRNO.
         MODIFY IST_SRCHLP FROM WA_SRCHLP.

       ENDIF.

     ENDLOOP.

     SEL_FLAG = '3'.

   ENDIF.

   CLEAR L_SRNO.

   IF NOT DESC4 IS INITIAL.

     LOOP AT IST_SRCHLP INTO WA_SRCHLP.

       TRANSLATE DESC4 TO UPPER CASE.

       SEARCH WA_SRCHLP-MAKTX FOR DESC4.

       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ELSE.
         L_SRNO = L_SRNO + 1.
         WA_SRCHLP-SRNO = L_SRNO.
         MODIFY IST_SRCHLP FROM WA_SRCHLP.

       ENDIF.

     ENDLOOP.

     SEL_FLAG = '4'.

   ENDIF.

   CLEAR L_SRNO.

   IF NOT DESC5 IS INITIAL.

     LOOP AT IST_SRCHLP INTO WA_SRCHLP.

       TRANSLATE DESC5 TO UPPER CASE.

       SEARCH WA_SRCHLP-MAKTX FOR DESC5.

       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ELSE.
         L_SRNO = L_SRNO + 1.
         WA_SRCHLP-SRNO = L_SRNO.
         MODIFY IST_SRCHLP FROM WA_SRCHLP.

       ENDIF.

     ENDLOOP.

     SEL_FLAG = '5'.

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
 FORM SAVE_REQUEST.
   PERFORM CHECK_OTHER.
   IF G_MODE = 'CRE'.
     PERFORM GEN_REQUEST.
     CASE  ZMM_CDHD_ST-MTART.
       WHEN 'ZSTO'.
         L_MATTYPE = 'S'.
       WHEN 'ZSPR'.
         L_MATTYPE = 'P'.
       WHEN 'ZCAP'.
         L_MATTYPE = 'C'.
       WHEN 'ZDIS'.
         L_MATTYPE = 'D'.
     ENDCASE.
*
     ZMM_CDHD_ST-REQNO = G_REQNO.
     G_REQUEST_NO = G_REQNO.
     PERFORM INSERT_INTO_TAB.
     MESSAGE I005(ZMM_OTH) WITH G_REQUEST_NO.
   ELSEIF G_MODE = 'CHA'.     "OR  g_mode = 'APR'.
     G_REQUEST_NO = ZMM_CDHD_ST-REQNO.
     PERFORM PREPARE_UPDATE."on commit.
     COMMIT WORK.
     MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
     IF G_LOCK = 'Y'.
       PERFORM UNLOCK_REQ.
       CLEAR G_LOCK.
     ENDIF.
     PERFORM CLEAR_VAR.
   ELSEIF G_MODE = 'DEL'.
     PERFORM PREPARE_DELETE .
     PERFORM CLEAR_VAR.
   ELSEIF G_MODE = 'REL'.
     IF ZMM_CDHD_ST-STATUS_FLAG = ''.
       MESSAGE I024(ZMM_OTH) WITH 'Release'.
     ELSE.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
     ENDIF.
*    Perform update_release.
   ELSEIF G_MODE = 'APR'.
**Note - Status flag is not pertaining to Request status, for that
**purpose flag is Reqcl ( Request Status ).
     IF ZMM_CDHD_ST-STATUS_FLAG = ' '.
       MESSAGE I026(ZMM_OTH).
       LEAVE TO SCREEN 0.
     ELSEIF ZMM_CDHD_ST-APPROVE_MRP = ''.
       MESSAGE I024(ZMM_OTH) WITH 'APPROVAL MRP CTRL'.
     ELSEIF  G_USER = ''.
       MESSAGE I043(ZMM_OTH).
       PERFORM CLEAR_VAR.
       LEAVE TO SCREEN 100.
     ELSEIF G_USER = 'M'.
       CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
     ELSEIF ZMM_CDHD_ST-APPROVE_L2 = '' AND G_USER = 'L'.
       MESSAGE I024(ZMM_OTH) WITH 'L2 APPROVAL'.
     ELSEIF ZMM_CDHD_ST-APPROVE_L2 = 'X' AND G_USER = 'L'.
       PERFORM UPDATE_APPROVAL.
     ENDIF.
   ELSEIF G_MODE = 'CRC'.
     G_REQUEST_NO = ZMM_CDHD_ST-REQNO.
     PERFORM UPDATE_CODES.
     IF ZMM_CDHD_ST-MTART = 'ZCAP'.
       READ TABLE IST_ZMM_CDITEM WITH KEY SPA_GRP = ''.
       IF SY-SUBRC = 0.
         MESSAGE I083(ZMM_OTH).
         CLEAR OKCODE_100.
         EXIT.
       ENDIF.
     ENDIF.
     COMMIT WORK.
     IF ZMM_CDHD_ST-REQCL <> 'C'.
       PERFORM CHECK_REQSTATUS.
     ENDIF.
     MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
     MODIFY ZMM_CDHD FROM ZMM_CDHD.
     COMMIT WORK.
     IF ZMM_CDHD_ST-REQCL = 'C'.
       PERFORM SEND_MAIL_TO_REQN.

     """"""""""""""""""""""""""""""""""""""""
      """""""""""""""""""""""""""""""""""""""""""""""""""
       """"""added by lipsy on 10.09.2013 for sending  sms to requisitioner
       "in case of status RD1K982397


       PERFORM SEND_SMS_TO_REQN.


       "end of add by lipsy on 10.09.2013 for sending  sms to requisitioner
       "in case of status RD1K982397
      """"""""""""""""""""""""""""""""""""""""""""""""""""""

     """""""""""""""""""""""""""""""""""""""""""""""""

     ENDIF.
     MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
   ENDIF.
*
   IF G_MODE = 'COD'.
     CLEAR G_MODE.
   ENDIF.
*
   IF SY-TCODE = 'ZCODG'.
     IF G_MODE = ''.
       PERFORM UPDATE_CODES.
       PERFORM CHECK_REQSTATUS.
*
       IF ZMM_CDHD_ST-REQCL = 'IR'.
         SELECT SINGLE * FROM ZMM_CDHD
             WHERE REQNO = ZMM_CDHD_ST-REQNO.
         IF ZMM_CDHD-IR_DATE IS INITIAL.
           ZMM_CDHD_ST-IR_DATE = SY-DATUM.
         ENDIF.
       ELSE.
         CLEAR ZMM_CDHD_ST-IR_DATE.
       ENDIF.
*
       MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
       MODIFY ZMM_CDHD FROM ZMM_CDHD.
*       Perform update_codes.
       COMMIT WORK.
       IF ZMM_CDHD_ST-REQCL = 'C' OR
          ZMM_CDHD_ST-REQCL = 'IR'.
         PERFORM SEND_MAIL_TO_REQN.
   """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""
       """"""added by lipsy on 10.09.2013 for sending  sms to requisitioner
       "in case of status RD1K982397


       PERFORM SEND_SMS_TO_REQN.


       "end of add by lipsy on 10.09.2013 for sending  sms to requisitioner
       "in case of status RD1K982397
      """"""""""""""""""""""""""""""""""""""""""""""""""""""
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
       ENDIF.
       PERFORM CLEAR_VAR.
       MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
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
 FORM GEN_REQUEST.

   CALL FUNCTION 'NUMBER_GET_NEXT'
     EXPORTING
       NR_RANGE_NR = '01'
       OBJECT      = 'ZMMCODREQ'
     IMPORTING
       NUMBER      = G_REQNO.
   IF SY-SUBRC <> 0.
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
 FORM INSERT_INTO_TAB.

   DATA L_CLOSE_REQ VALUE 'Y'.
   IF G_MODE = 'CRE'.
     MOVE SY-DATUM TO ZMM_CDHD_ST-REQDATE.
     MOVE SY-UNAME TO ZMM_CDHD_ST-REQCPF.
     MOVE 'N' TO ZMM_CDHD_ST-REQCL.
     MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
     INSERT INTO ZMM_CDHD VALUES ZMM_CDHD.
     IF SY-SUBRC = 0.
       MESSAGE I001(ZMM_OTH) WITH ZMM_CDHD-REQNO.
     ENDIF.
   ELSEIF G_MODE = 'CHA'.
     IF MATGEN_FLAG = 'X'.
       MOVE MATGEN_FLAG TO ZMM_CDHD_ST-MATGEN_FLAG.
       MOVE SY-DATUM TO ZMM_CDHD_ST-MATGEN_DATE.
     ENDIF.
*
     CASE L_MATTYPE.
       WHEN 'S'.
         LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
           IF G_TABCTRL110_WA-MATCODE IS INITIAL.
             L_CLOSE_REQ = 'N'.
           ENDIF.
         ENDLOOP.
       WHEN 'P'.
         LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
           IF  G_TABLCTRL120_WA-MATCODE IS INITIAL.
             L_CLOSE_REQ = 'N'.
           ENDIF.
         ENDLOOP.
       WHEN 'C'.
         LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
           IF G_TABLCTRL130_WA-MATCODE IS INITIAL.
             L_CLOSE_REQ = 'N'.
           ENDIF.
         ENDLOOP.
     ENDCASE.
     IF L_CLOSE_REQ = 'Y'.
       MOVE 'C' TO ZMM_CDHD_ST-REQCL.
     ENDIF.
*
     MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
     MODIFY ZMM_CDHD FROM ZMM_CDHD.
   ENDIF.
*
   REFRESH IST_ZMM_CDITEM.
   CASE L_MATTYPE.
     WHEN 'S'.
       LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
         IF NOT G_TABCTRL110_WA-DESC_FIN IS INITIAL.
           IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
                  ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
             PERFORM GET_NOOFHITS.
           ENDIF.
           MOVE-CORRESPONDING G_TABCTRL110_WA TO WA_ZMM_CDITEM.
           MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
           MOVE G_TABCTRL110_WA-MATGP TO WA_ZMM_CDITEM-MATGP.
           PERFORM CHABY_CHADT.
           CLEAR WA_ZMM_CDITEM-DESC_CDCELL.
           APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'P'.
       LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
         IF NOT G_TABLCTRL120_WA-DESC_FIN IS INITIAL.
           IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
                  ZMM_CDHD_ST-APPROVE_MRP IS INITIAL .
             PERFORM GET_NOOFHITS.
           ENDIF.
           MOVE-CORRESPONDING G_TABLCTRL120_WA TO WA_ZMM_CDITEM.
           MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
           MOVE G_TABLCTRL120_WA-MATGP TO WA_ZMM_CDITEM-MATGP.
           PERFORM CHABY_CHADT.
           APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'C'.
       LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
         IF NOT G_TABLCTRL130_WA-DESC_FIN IS INITIAL.
           IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
                  ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
             PERFORM GET_NOOFHITS.
           ENDIF.
           MOVE-CORRESPONDING G_TABLCTRL130_WA TO WA_ZMM_CDITEM.
           MOVE '0C' TO WA_ZMM_CDITEM-MATGP.
           MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
           PERFORM CHABY_CHADT.
           APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
     WHEN 'D'.
       LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
         IF NOT G_TABLCTRL140_WA-DESC_FIN IS INITIAL.
           MOVE-CORRESPONDING G_TABLCTRL140_WA TO WA_ZMM_CDITEM.
           MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
           MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
           MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
           APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         ELSE.
           EXIT.
         ENDIF.
       ENDLOOP.
   ENDCASE.

   INSERT ZMM_CDITEM FROM TABLE IST_ZMM_CDITEM.
************************************************************
****Saving the long text.                              *****
************************************************************
******Header(Correspondence)********************************
   IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
      ( G_MODE = 'APR' ) OR ( G_MODE = 'MRP' ) OR
        SY-TCODE = 'ZCODG'.
     PERFORM SAVE_CORS_TEXT.
   ENDIF.
******Items*************************************************
   IF G_MODE = 'CRE'.
     DELETE ADJACENT DUPLICATES FROM IST_TEXTID_ITEMS.
     LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
       REFRESH : IST_DTSPECS.
       PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING WA_TEXTID.
       CONCATENATE 'CDDS'
                    ZMM_CDHD_ST-REQNO
                    WA_TEXTID-TDNAME+14(3)
              INTO  WA_TEXTID-TDNAME.
       PERFORM SAVE_TEXT.
     ENDLOOP.
     CLEAR WA_TEXTID.
*****Delete temporarily saved long text*******************************
     LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
       SELECT SINGLE * INTO G_STXL FROM STXL
                  WHERE TDOBJECT = WA_TEXTID-TDOBJECT
                   AND  TDID     = WA_TEXTID-TDID
                   AND  TDNAME   = WA_TEXTID-TDNAME.
       IF SY-SUBRC = 0.
         PERFORM DELETE_TEXT.
       ENDIF.
     ENDLOOP.
     REFRESH IST_TEXTID_ITEMS.
   ENDIF.
*************End of Long Text Save************************************
   PERFORM CLEAR_VAR.

 ENDFORM.                    " Insert_into_tab
*&---------------------------------------------------------------------*
*&      Form  clear_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CLEAR_VAR.
   IF NOT GV_TEXT_EDITOR1 IS INITIAL.
     PERFORM DESTROY_CTRL.
   ENDIF.
   CLEAR ZMM_CDHD_ST.

   REFRESH G_TABCTRL110_ITAB.
   REFRESH CONTROL 'TABCTRL110' FROM SCREEN '0110'.

   REFRESH G_TABLCTRL120_ITAB.
   REFRESH CONTROL 'TABLCTRL120' FROM SCREEN '0120'.

   REFRESH G_TABLCTRL130_ITAB.
   REFRESH CONTROL 'TABLCTRL130' FROM SCREEN '0130'.

   REFRESH G_TABLCTRL140_ITAB.
   REFRESH CONTROL 'TABLCTRL140' FROM SCREEN '0140'.

   IF G_LOCK = 'Y'.
     PERFORM UNLOCK_REQ.
     CLEAR G_LOCK.
   ENDIF.
   CLEAR: ZMM_CDHD_ST-REQCPF, ZMM_CDHD_ST-REQDATE, ZMM_CDHD_ST-APPCPF,
          ZMM_CDHD_ST-APPDATE, ZMM_CDHD_ST-ADDR1, ZMM_CDHD_ST-ADDR2,
          ZMM_CDHD_ST-ADDR3,ZMM_CDHD_ST-REQLOC,
          G_TABCTRL110_WA, G_TABLCTRL120_WA, G_TABLCTRL130_WA,
          G_TABLCTRL140_WA,G_LINENO,G_MODE,G_HD_COPIED,G_CDITEM,
          L_MATTYPE,G_SAVEFLAG,G_CHECK_FLAG,G_TECHAPR_VISIBLE,
          G_USER_FOUND.  "<< TAA+MRP check 03/10/05
   CLEAR  G_CORS.
   REFRESH: IST_SRCHLP,TLINETAB1,TLINETAB2,LINES_CORS.
   REFRESH:LT_TEXT_TABLE1,LT_TEXT_TABLE2.
*****Assigning constants and status*************************************
   DYNNR = ''.
   REFRESH IT_TAB1.
   G_TABCTRL110_COPIED = ''.
   G_TABLCTRL120_COPIED = ''.
   G_TABLCTRL130_COPIED = ''.
   G_TABLCTRL140_COPIED = ''.
*
 ENDFORM.                    " clear_var

*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_desc1_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM TABCTRL110_DESC1_CHECK .

   IF NOT G_TABCTRL110_WA-MATGP IS INITIAL AND
         TABCTRL110_CHECK_FLAG <> 'X'.
*
     MATGRP_CHANGE_FLAG = 'X'.
     MATGRP_ORIG = G_TABCTRL110_WA-MATGP.
   ENDIF.

   SELECT * FROM ZMM_MODIFIER INTO TABLE IST_MODIFIER_CHECK_LIST
             WHERE DESC1 = ZMM_CDITEM-DESC1 .
*
   IF SY-SUBRC = 0.

     DELETE ADJACENT DUPLICATES FROM IST_MODIFIER_CHECK_LIST COMPARING
                     DESC1 MATGRP.
     LOOP AT IST_MODIFIER_CHECK_LIST INTO WA_MODIFIER_CHECK_LIST.

       IF      WA_MODIFIER_CHECK_LIST-MATGRP = '01'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '02'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '03'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '04'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '05'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '06'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '07'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '08'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '09'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '10'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '11'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '12'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '13'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '14'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '15'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = '16'
            OR WA_MODIFIER_CHECK_LIST-MATGRP = 'XX'.
       ELSE.
         DELETE IST_MODIFIER_CHECK_LIST.
       ENDIF.

     ENDLOOP.

     DESCRIBE TABLE IST_MODIFIER_CHECK_LIST LINES CHECK_LIST_LINES.

     IF CHECK_LIST_LINES > 1 AND TABCTRL110_CHECK_FLAG ='X'.
*
       CALL SCREEN 104 STARTING AT 40 2
                       ENDING   AT 80 18.
       G_MATGP_SELECTED = 'X'.
       CLEAR CHECK_LIST_LINES.
     ELSE.
       READ TABLE IST_MODIFIER_CHECK_LIST
       INTO WA_MODIFIER_CHECK_LIST INDEX 1.  "#EC CI_NOORDER
     ENDIF.

     IF MATGRP_CHANGE_FLAG = 'X'.
       CLEAR G_MATGP_SELECTED.
       ZMM_CDITEM-MATGP = MATGRP_ORIG.
       G_TABCTRL110_WA-MATGP = MATGRP_ORIG.
       CLEAR : MATGRP_ORIG, MATGRP_CHANGE_FLAG.
     ELSE.
       ZMM_CDITEM-MATGP = WA_MODIFIER_CHECK_LIST-MATGRP.
       G_TABCTRL110_WA-MATGP = WA_MODIFIER_CHECK_LIST-MATGRP.
     ENDIF.

*
     CLEAR ZMM_CDITEM-OTH1.
     CLEAR CHECK_LIST_LINES.
   ELSE.
     IF ZMM_CDITEM-OTH1 <> 'X'.
*
       MESSAGE I002(ZMM_OTH).
     ENDIF.
   ENDIF.

 ENDFORM.                 " TABCTRL110_desc1_check

*---------------------------------------------------------------------*
*       FORM TABCTRL110_desc2_check                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABCTRL110_DESC2_CHECK .

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                           DESC2 = ZMM_CDITEM-DESC2 .

   IF SY-SUBRC = 0.
     CLEAR G_TABCTRL110_WA-OTH2.
     CLEAR ZMM_CDITEM-OTH2.
   ELSE.
     IF ZMM_CDITEM-OTH2 <> 'X'.
       G_PARNO = 2.
       MESSAGE I002(ZMM_OTH).
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
 FORM TABCTRL110_DESC3_CHECK.

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                           DESC2 = ZMM_CDITEM-DESC2 AND
                                           DESC3 = ZMM_CDITEM-DESC3 .

   IF SY-SUBRC = 0.
     CLEAR G_TABCTRL110_WA-OTH3.
     CLEAR ZMM_CDITEM-OTH3.
   ELSE.
     IF ZMM_CDITEM-OTH3 <> 'X'.
       G_PARNO = 3.
       MESSAGE I002(ZMM_OTH).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABCTRL110_desc3_check
*---------------------------------------------------------------------*
*       FORM TABCTRL110_desc4_check                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABCTRL110_DESC4_CHECK.

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                           DESC2 = ZMM_CDITEM-DESC2 AND
                                           DESC3 = ZMM_CDITEM-DESC3 AND
                                           DESC4 = ZMM_CDITEM-DESC4 .
   IF SY-SUBRC = 0.
     CLEAR G_TABCTRL110_WA-OTH4.
     CLEAR ZMM_CDITEM-OTH4.
   ELSE.
     IF ZMM_CDITEM-OTH4 <> 'X'.
       G_PARNO = 4.
       MESSAGE I002(ZMM_OTH).
     ENDIF.
   ENDIF.

 ENDFORM.                    " TABCTRL110_desc4_check

****************************************************
 FORM POPUP_USERDESC1.
   REFRESH : IST_SVAL1.
   CLEAR : IST_SVAL1.
   MOVE : 'ZMM_CDITEM'  TO IST_SVAL1-TABNAME,
          'USER_DESC'   TO IST_SVAL1-FIELDNAME,
          'X'           TO IST_SVAL1-FIELD_OBL.
   APPEND IST_SVAL1.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       POPUP_TITLE     = 'USER DESCRIPTION'
       START_COLUMN    = '5'
       START_ROW       = '5'
     TABLES
       FIELDS          = IST_SVAL1
     EXCEPTIONS
       ERROR_IN_FIELDS = 1
       OTHERS          = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   READ TABLE IST_SVAL1 INDEX 1.
   G_TABCTRL110_WA-USER_DESC = IST_SVAL1-VALUE.

 ENDFORM.                    " popup_userdesc1

*---------------------------------------------------------------------*
*       FORM popup_userdesc2                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM POPUP_USERDESC2.
   REFRESH : IST_SVAL2.
   CLEAR : IST_SVAL2.
   MOVE : 'ZMM_CDITEM'  TO IST_SVAL2-TABNAME,
          'USER_DESC'   TO IST_SVAL2-FIELDNAME,
          'X'           TO IST_SVAL2-FIELD_OBL.
   APPEND IST_SVAL2.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       POPUP_TITLE     = 'USER DESCRIPTION'
       START_COLUMN    = '5'
       START_ROW       = '5'
     TABLES
       FIELDS          = IST_SVAL2
     EXCEPTIONS
       ERROR_IN_FIELDS = 1
       OTHERS          = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   READ TABLE IST_SVAL2 INDEX 1.
   G_TABCTRL110_WA-USER_DESC = IST_SVAL2-VALUE.

 ENDFORM.                    " popup_userdesc2

*---------------------------------------------------------------------*
*       FORM popup_userdesc3                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM POPUP_USERDESC3.
   REFRESH : IST_SVAL3.
   CLEAR : IST_SVAL3.
   MOVE : 'ZMM_CDITEM'  TO IST_SVAL3-TABNAME,
          'USER_DESC'   TO IST_SVAL3-FIELDNAME,
          'X'           TO IST_SVAL3-FIELD_OBL.
   APPEND IST_SVAL3.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       POPUP_TITLE     = 'USER DESCRIPTION'
       START_COLUMN    = '5'
       START_ROW       = '5'
     TABLES
       FIELDS          = IST_SVAL3
     EXCEPTIONS
       ERROR_IN_FIELDS = 1
       OTHERS          = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   READ TABLE IST_SVAL3 INDEX 1.
   G_TABCTRL110_WA-USER_DESC = IST_SVAL3-VALUE.

 ENDFORM.                    " popup_userdesc3

*---------------------------------------------------------------------*
*       FORM popup_userdesc4                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM POPUP_USERDESC4.
   REFRESH : IST_SVAL4.
   CLEAR : IST_SVAL4.
   MOVE : 'ZMM_CDITEM'  TO IST_SVAL4-TABNAME,
          'USER_DESC'   TO IST_SVAL4-FIELDNAME,
          'X'           TO IST_SVAL4-FIELD_OBL.
   APPEND IST_SVAL4.

   CALL FUNCTION 'POPUP_GET_VALUES'
     EXPORTING
       POPUP_TITLE     = 'USER DESCRIPTION'
       START_COLUMN    = '5'
       START_ROW       = '5'
     TABLES
       FIELDS          = IST_SVAL4
     EXCEPTIONS
       ERROR_IN_FIELDS = 1
       OTHERS          = 2.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.
   READ TABLE IST_SVAL4 INDEX 1.
   G_TABCTRL110_WA-USER_DESC = IST_SVAL4-VALUE.

 ENDFORM.                    " popup_userdesc4

*---------------------------------------------------------------------*
*       FORM TABLCTRL120_desc1_check                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM TABLCTRL120_DESC1_CHECK .

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .

   IF SY-SUBRC = 0.
     CLEAR G_TABLCTRL120_WA-OTH1.
     CLEAR ZMM_CDITEM-OTH1.
   ELSE.
     IF ZMM_CDITEM-OTH1 <> 'X'.
       G_PARNO = 1.
       MESSAGE I002(ZMM_OTH).
     ENDIF.
   ENDIF.

 ENDFORM.                 " TABLCTRL120_desc1_check
*&---------------------------------------------------------------------*
*&      Form  CHANGE_PARTNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_G_PARTNO  text
*----------------------------------------------------------------------*
 FORM CHANGE_PARTNO CHANGING P_G_PARTNO LIKE ZMM_CDITEM-USER_DESC
                             P_G_PARTNOC LIKE ZMM_CDITEM-PARTNO.

   DATA : L_LEN TYPE I.
   DATA : L_CTR TYPE I.
   DATA : L_CTR1 TYPE I.
   DATA : L_ADD TYPE I.
   DATA : L_SUB TYPE I.
   DATA : L_CTRF TYPE I.
   DATA : L_P_G_PARTNOC LIKE ZMM_CDITEM-PARTNO.

   CLEAR : P_G_PARTNO.
   CLEAR : CHECK_FLAG2.

   L_LEN = STRLEN( P_G_PARTNOC ).

   L_P_G_PARTNOC = P_G_PARTNOC.

   DO L_LEN TIMES.

*     l_ctr = l_ctr + 1.

     WA_CHAR = L_P_G_PARTNOC+L_CTR(1).
     TRANSLATE WA_CHAR TO UPPER CASE.
*
     L_CTR = L_CTR + 1.
*
     LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.

       IF WA_CHAR = WA_ALPHANUM.
         CHECK_FLAG1 = 'X'.
         EXIT.
       ELSEIF WA_CHAR = '*'.
         CHECK_FLAG2 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF CHECK_FLAG1 = 'X'.
       CLEAR CHECK_FLAG1.
     ELSE.
       L_ADD = L_CTR + 1.
       L_SUB = L_LEN - L_ADD + 1.
       IF L_ADD > L_LEN.
       ELSE.
         CONCATENATE L_P_G_PARTNOC+0(L_CTR) '%' L_P_G_PARTNOC+L_ADD(L_SUB)
                                                        INTO L_P_G_PARTNOC.
       ENDIF.
     ENDIF.

   ENDDO.
   CLEAR L_CTR.
   L_CTRF = L_LEN - 1.
   DO L_LEN TIMES.
     WA_ALPHANUM = L_P_G_PARTNOC+L_CTR(1).
     IF L_CTR = L_CTRF.
       CONCATENATE P_G_PARTNO WA_ALPHANUM INTO P_G_PARTNO.
     ELSEIF WA_ALPHANUM <> '%'.
       CONCATENATE P_G_PARTNO WA_ALPHANUM '%' INTO P_G_PARTNO.
     ENDIF.

     L_CTR = L_CTR + 1.
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
 FORM CHANGE_PARTNO1 CHANGING P_G_PARTNOO LIKE ZMM_CDITEM-USER_DESC
                             P_G_PARTNOCC LIKE ZMM_CDITEM-PARTNO.

   DATA : L_LEN TYPE I.
   DATA : L_CTR TYPE I.

   CLEAR : P_G_PARTNOO.

   L_LEN = STRLEN( P_G_PARTNOCC ).

   CLEAR CHECK_FLAG1.

   DO L_LEN TIMES.

     WA_CHAR = P_G_PARTNOCC+L_CTR(1).
     TRANSLATE WA_CHAR TO UPPER CASE.
     L_CTR = L_CTR + 1.

     LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.

       IF WA_CHAR = WA_ALPHANUM.
         CHECK_FLAG1 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF CHECK_FLAG1 = 'X'.
       CLEAR CHECK_FLAG1.
       CONCATENATE P_G_PARTNOO WA_CHAR INTO P_G_PARTNOO.
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
 FORM CHANGE_PARTNO2 CHANGING P_G_PARTNOO LIKE ZMM_CDITEM-USER_DESC
                             P_G_PARTNOCC LIKE ZMM_CDITEM-PARTNO.

   DATA : L_LEN TYPE I.
   DATA : L_CTR TYPE I.

   CLEAR : P_G_PARTNOO.

   L_LEN = STRLEN( P_G_PARTNOCC ).

   CLEAR CHECK_FLAG1.

   DO L_LEN TIMES.

     WA_CHAR = P_G_PARTNOCC+L_CTR(1).
     TRANSLATE WA_CHAR TO UPPER CASE.
     L_CTR = L_CTR + 1.

     LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.

       IF WA_CHAR = WA_ALPHANUM.
         CHECK_FLAG1 = 'X'.
         EXIT.
       ENDIF.

     ENDLOOP.

     IF CHECK_FLAG1 = 'X'.
       CLEAR CHECK_FLAG1.
       CONCATENATE P_G_PARTNOO WA_CHAR INTO P_G_PARTNOO.
     ENDIF.

   ENDDO.

 ENDFORM.                    " CHANGE_PARTNO

*---------------------------------------------------------------------*
*       FORM attrib_parno                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM ATTRIB_PARNO.


   SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
 WHERE DESC1 = G_TABCTRL110_WA-DESC1
 AND MATGRP = G_TABCTRL110_WA-MATGP
 ORDER BY PRIMARY KEY .
 ENDSELECT.
   IF SY-SUBRC <> 0.
     G_PARNO = '1'.
   ENDIF.

   IF SY-SUBRC = 0.

     IF  ZMM_MODIFIER-DESC2 IS INITIAL.
       G_PARNO = '1'.
     ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
       G_PARNO = '2'.
     ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
       G_PARNO = '3'.
     ELSE.
       G_PARNO = '4'.
     ENDIF.

   ENDIF.

 ENDFORM.                    "attrib_parno
*&---------------------------------------------------------------------*
*&      Form  TABLCTRL140_desc1_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM TABLCTRL140_DESC1_CHECK.

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .

   IF SY-SUBRC = 0.
     CLEAR G_TABLCTRL140_WA-OTH1.
     CLEAR ZMM_CDITEM-OTH1.
   ELSE.
     IF ZMM_CDITEM-OTH1 <> 'X'.
       G_PARNO = 1.
       MESSAGE I002(ZMM_OTH).
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
 FORM TABLCTRL130_DESC1_CHECK.

   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .

   IF SY-SUBRC = 0.
     CLEAR G_TABLCTRL130_WA-OTH1.
     CLEAR ZMM_CDITEM-OTH1.
   ELSE.
     IF ZMM_CDITEM-OTH1 <> 'X'.
       G_PARNO = 1.
       MESSAGE I002(ZMM_OTH).
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
 FORM ADD_DELITEM110.
   LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
     IF G_TABCTRL110_WA-FLAG = 'X'.
       IF G_TABCTRL110_WA-MATCODE IS INITIAL.
         APPEND G_TABCTRL110_WA TO G_ITAB_DEL110.
       ELSE.
         MESSAGE I031(ZMM_OTH).
         G_TABCTRL110_WA-FLAG = ''.
         G_DELFLAG = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR G_TABCTRL110_WA.
 ENDFORM.                    "add_delitem110

*&---------------------------------------------------------------------*
*&      Form  add_delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ADD_DELITEM120.
   LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
     IF G_TABLCTRL120_WA-FLAG = 'X'.
       IF G_TABLCTRL120_WA-MATCODE IS INITIAL.
         APPEND G_TABLCTRL120_WA TO G_ITAB_DEL120.
       ELSE.
         MESSAGE I031(ZMM_OTH).
         G_TABLCTRL120_WA-FLAG = ''.
         G_DELFLAG = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR G_TABLCTRL120_WA.

 ENDFORM.                    " add_delitem120
*&---------------------------------------------------------------------*
*&      Form  add_delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ADD_DELITEM130.
   LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
     IF G_TABLCTRL130_WA-FLAG = 'X'.
       IF G_TABLCTRL130_WA-MATCODE IS INITIAL.
         APPEND G_TABLCTRL130_WA TO G_ITAB_DEL130.
       ELSE.
         MESSAGE I031(ZMM_OTH).
         G_TABLCTRL130_WA-FLAG = ''.
         G_DELFLAG = 'N'.
       ENDIF.
     ENDIF.
   ENDLOOP.
   CLEAR G_TABLCTRL130_WA.

 ENDFORM.                    " add_delitem130
*&---------------------------------------------------------------------*
*&      Form  add_delitem140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ADD_DELITEM140.
   LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
     IF G_TABLCTRL140_WA-FLAG = 'X'.
       APPEND G_TABLCTRL140_WA TO G_ITAB_DEL140.
     ENDIF.
   ENDLOOP.
   CLEAR G_TABLCTRL140_WA.

 ENDFORM.                    " add_delitem140

*&      Form  prepare_update
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM PREPARE_UPDATE.

***To delete the 'DELETED' marked item from the DB table.
***Select statement to store the previus CODBY/CODDT.
   CLEAR G_CDITEM.
   SELECT SINGLE * INTO G_CDITEM FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO.
*
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
       L_MATTYPE = 'S'.
       PERFORM DELITEM110.
     WHEN 'ZSPR'.
       L_MATTYPE = 'P'.
       PERFORM DELITEM120.
     WHEN 'ZCAP'.
       L_MATTYPE = 'C'.
       PERFORM DELITEM130.
     WHEN 'ZDIS'.
       L_MATTYPE = 'D'.
       PERFORM DELITEM140.
   ENDCASE.
   PERFORM INSERT_INTO_TAB.

 ENDFORM.                    " prepare_update

*&---------------------------------------------------------------------*
*&      Form  delitem110
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELITEM110.
*
   DELETE FROM ZMM_CDITEM
   WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
*
   REFRESH G_ITAB_DEL110.
*
 ENDFORM.                    " delitem110

*&---------------------------------------------------------------------*
*&      Form  delitem120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELITEM120.
*
   DELETE FROM ZMM_CDITEM
   WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
*
   REFRESH G_ITAB_DEL120.
*
 ENDFORM.                    " delitem120

*&---------------------------------------------------------------------*
*&      Form  delitem130
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELITEM130.
*
   DELETE FROM ZMM_CDITEM
   WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
*
   REFRESH G_ITAB_DEL130.
*
 ENDFORM.                    " delitem130
*&---------------------------------------------------------------------*
*&      Form  delitem140
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELITEM140.
*
   DELETE FROM ZMM_CDITEM
   WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
*
   REFRESH G_ITAB_DEL140.
*
 ENDFORM.                    " delitem140

*&---------------------------------------------------------------------*
*&      Form  prepare_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM PREPARE_DELETE.

   PERFORM CONFIRM_DEL.

   IF G_CHOICE = 'J'.

     DELETE FROM ZMM_CDHD
     WHERE REQNO = ZMM_CDHD_ST-REQNO.
     IF SY-SUBRC <> 0.
       MESSAGE E007(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
     ENDIF.
*
     SELECT TDOBJECT TDNAME TDID FROM STXL
      INTO CORRESPONDING FIELDS OF TABLE IST_TEXTID_ITEMS
      WHERE TDID = 'CDDS'.
     IF SY-SUBRC = 0.
       DELETE IST_TEXTID_ITEMS
          WHERE TDNAME+4(10) <> ZMM_CDHD_ST-REQNO.
       LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
         PERFORM DELETE_TEXT.
       ENDLOOP.
       REFRESH IST_TEXTID_ITEMS.
     ENDIF.

     DELETE FROM ZMM_CDITEM
     WHERE REQNO = ZMM_CDHD_ST-REQNO.
     IF SY-SUBRC = 0.
       MESSAGE I004(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
     ENDIF.
     CLEAR G_CHOICE.
   ENDIF.
*
 ENDFORM.                    " prepare_delete
*&---------------------------------------------------------------------*
*&      Form  bac_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MATCODE_CONFIRM.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*             DEFAULTOPTION  = 'N'
*             TEXTLINE1      = 'The details in the request have been'
*               TEXTLINE2      = 'checked. Please generate new Material Codes '
*             TITEL          = 'CONFIRM'
*             START_COLUMN   = 25
*             START_ROW      = 6
*             CANCEL_DISPLAY = ''
*        IMPORTING
*             ANSWER         = a_choice.

   DATA : L_GET5(5) TYPE C.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
      TITLEBAR                    = 'CONFIRM '
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = 'The details in the request have been checked.'
                                     &' Please generate new Material Codes.'
*      TEXT_BUTTON_1               = 'Ja'(001)
*      ICON_BUTTON_1               = ' '
*      TEXT_BUTTON_2               = 'Nein'(002)
*      ICON_BUTTON_2               = ' '
      DEFAULT_BUTTON              = '2'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
      START_COLUMN                = 25
      START_ROW                   = 6
*      POPUP_TYPE                  =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER                      = L_GET5
*    TABLES
*      PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .

   IF SY-SUBRC = 0.
     CASE L_GET5.
       WHEN '1'.
         MOVE 'J' TO A_CHOICE.
       WHEN '2'.
         MOVE 'N' TO A_CHOICE.
     ENDCASE.
   ENDIF.
   " End of <RD1K960036>.
 ENDFORM.                    " matcode_confirm

*---------------------------------------------------------------------*
*       FORM bac_confirm                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM BAC_CONFIRM.
   DATA L_CHOICE.
   CLEAR L_CHOICE.
   IF G_MODE <> 'DIS'.
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
     DATA : L_GET6(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'BACK'
*        DIAGNOSE_OBJECT             = ' '
         TEXT_QUESTION               = 'Data will be lost, Want to quit? '
*        TEXT_BUTTON_1               = 'Ja'(001)
*        ICON_BUTTON_1               = ' '
*        TEXT_BUTTON_2               = 'Nein'(002)
*        ICON_BUTTON_2               = ' '
*        DEFAULT_BUTTON              = '1'
*        DISPLAY_CANCEL_BUTTON       = 'X'
*        USERDEFINED_F1_HELP         = ' '
        START_COLUMN                = 25
        START_ROW                   = 6
*        POPUP_TYPE                  =
*        IV_QUICKINFO_BUTTON_1       = ' '
*        IV_QUICKINFO_BUTTON_2       = ' '
      IMPORTING
        ANSWER                      = L_GET6
*      TABLES
*        PARAMETER                   =
      EXCEPTIONS
        TEXT_NOT_FOUND              = 1
        OTHERS                      = 2
               .
     IF SY-SUBRC = 0.
       CASE L_GET6.
         WHEN '1'.
           MOVE 'J' TO L_CHOICE.
         WHEN '2'.
           MOVE 'N' TO L_CHOICE.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.

     IF L_CHOICE = 'J'.
       PERFORM UNDO_LONGTEXT.
       PERFORM CLEAR_VAR.
       CLEAR L_CHOICE.
     ENDIF.
   ELSE.
     PERFORM CLEAR_VAR.
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
 FORM CHECK_DELREQ.
   DATA L_ZMM_CDHD LIKE ZMM_CDHD.
   IF G_MODE = 'DEL'.
     SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
           WHERE REQNO = ZMM_CDHD_ST-REQNO
           AND   LVORM = 'D'.
     IF SY-SUBRC = 0.
       MESSAGE E004(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
     ENDIF.

     SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
           WHERE REQNO = ZMM_CDHD_ST-REQNO
           AND   REQCL IN ('C','AC','IC','IR').
     IF SY-SUBRC = 0.
       MESSAGE E056(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
     ENDIF.

   ENDIF.
*
   IF G_MODE = 'CHA' OR
      G_MODE = 'APR' OR
      G_MODE = 'REL'.
     SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
            WHERE REQNO = ZMM_CDHD_ST-REQNO.
     IF SY-SUBRC = 0.
       IF L_ZMM_CDHD-REQCL = 'AC' OR
          L_ZMM_CDHD-REQCL = 'C'.
         MESSAGE E053(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
       ELSEIF L_ZMM_CDHD-REQCL = 'IC'.
         MESSAGE E054(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
       ENDIF.
     ENDIF.
   ENDIF.
*
   IF G_MODE = 'APR' AND G_USER = 'L'.
***To check , if Tech Auth Appr is reqired.
     SELECT SINGLE * FROM ZMM_CDITEM
           WHERE REQNO = ZMM_CDHD_ST-REQNO
           AND   OTH1  = 'X'.
     IF SY-SUBRC <> 0.
       MESSAGE E055(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
     ENDIF.
   ENDIF.
*
   PERFORM CHANGE_RESTRICT.

 ENDFORM.                    " check_delreq
*&---------------------------------------------------------------------*
*&      Form  confirm_del
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CONFIRM_DEL.
   " Begin of <RD1K960036>.
*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*    EXPORTING
*    TEXTLINE1   = 'Data will be lost, No recovery possible, Are you sure ? '
*     TITEL       = 'BACK'
*     START_COLUMN     = 25
*     START_ROW        = 6
*     CANCEL_DISPLAY   = ''
*    IMPORTING
*     ANSWER           = g_choice.

   DATA : L_GET7(1) TYPE C.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
      TITLEBAR                    = 'BACK'
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = 'Data will be lost, No recovery possible, Are you sure ? '
*      TEXT_BUTTON_1               = 'Ja'(001)
*      ICON_BUTTON_1               = ' '
*      TEXT_BUTTON_2               = 'Nein'(002)
*      ICON_BUTTON_2               = ' '
*      DEFAULT_BUTTON              = '1'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
      START_COLUMN                = 25
      START_ROW                   = 6
*      POPUP_TYPE                  =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER                      = L_GET7
*    TABLES
*      PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .

   IF SY-SUBRC = 0.
     CASE L_GET7.
       WHEN '1'.
         MOVE 'J' TO G_CHOICE.
       WHEN '2'.
         MOVE 'N' TO G_CHOICE.
     ENDCASE.
   ENDIF.
   " End of <RD1K960036>.
 ENDFORM.                    " confirm_del
*&---------------------------------------------------------------------*
*&      Form  check_tabrows
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_TABROWS.
   DATA: WA_ITAB110 TYPE T_TABCTRL110,
         WA_ITAB120 TYPE T_TABLCTRL120,
         WA_ITAB130 TYPE T_TABLCTRL130,
         WA_ITAB140 TYPE T_TABLCTRL140.
   CLEAR G_INSRFLG.
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
       READ TABLE G_TABCTRL110_ITAB INTO WA_ITAB110
            WITH KEY SRNO = 10.
       IF SY-SUBRC = 0.
         G_INSRFLG = 'Y'.
       ENDIF.
     WHEN 'ZSPR'.
       READ TABLE G_TABLCTRL120_ITAB INTO WA_ITAB120
            WITH KEY SRNO = 10.
       IF SY-SUBRC = 0.
         G_INSRFLG = 'Y'.
       ENDIF.
     WHEN 'ZCAP'.
       READ TABLE G_TABLCTRL130_ITAB INTO WA_ITAB130
            WITH KEY SRNO = 10.
       IF SY-SUBRC = 0.
         G_INSRFLG = 'Y'.
       ENDIF.
     WHEN 'ZDIS'.
       READ TABLE G_TABLCTRL140_ITAB INTO WA_ITAB140
            WITH KEY SRNO = 10.
       IF SY-SUBRC = 0.
         G_INSRFLG = 'Y'.
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
 FORM SET_DYNNR USING P_MTART.
   CASE P_MTART.
     WHEN 'ZSTO'.
       DYNNR = '0110'.
     WHEN 'ZSPR'.
       DYNNR = '0120'.
     WHEN 'ZCAP'.
       DYNNR = '0130'.
     WHEN 'ZDIS'.
       DYNNR = '0140'.
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
 FORM LTXTDTSP.
*************Local Data*******************************
   DATA: L_SRNO LIKE ZMM_CDITEM-SRNO,
          L_CURS_LN TYPE I,
          L_ITAB110 TYPE T_TABCTRL110,
          L_ITAB120 TYPE T_TABLCTRL120,
          L_ITAB130 TYPE T_TABLCTRL130,
          L_ITAB140 TYPE T_TABLCTRL140.
*
   CLEAR IST_TEXTID.

********************************************************
***To get the proper serial no of line item against the
***cursor position
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
*
       L_CURS_LN = G_CURR_LINE_110.
       READ TABLE G_TABCTRL110_ITAB INTO L_ITAB110
                                   INDEX L_CURS_LN.
       L_SRNO = L_ITAB110-SRNO.
     WHEN 'ZSPR'.
*
       L_CURS_LN = G_CURR_LINE_120.
       READ TABLE G_TABLCTRL120_ITAB INTO L_ITAB120
                                   INDEX L_CURS_LN.
       L_SRNO = L_ITAB120-SRNO.
     WHEN 'ZCAP'.
       L_CURS_LN = G_CURR_LINE_130.
*       move tablctrl130-current_line to l_curs_ln.
       READ TABLE G_TABLCTRL130_ITAB INTO L_ITAB130
                                   INDEX L_CURS_LN.
       L_SRNO = L_ITAB130-SRNO.
     WHEN 'ZDIS'.
*       l_curs_ln = g_curr_line_140.
       MOVE TABLCTRL140-CURRENT_LINE TO L_CURS_LN.
       READ TABLE G_TABLCTRL140_ITAB INTO L_ITAB140
                                   INDEX L_CURS_LN.
       L_SRNO = L_ITAB140-SRNO.
   ENDCASE.

*
   IF G_MODE = 'CRE'.
     PERFORM GET_DUMMYNO.
     CONCATENATE 'CDDS' G_USER_LOGGED L_SRNO
     INTO IST_TEXTID-TDNAME.
   ELSE.
     CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
     INTO IST_TEXTID-TDNAME.
   ENDIF.

   IST_TEXTID-TDOBJECT   = 'ZMMCD'.
   IST_TEXTID-TDID       = 'CDDS'.
   IST_TEXTID-TDSPRAS    =  SY-LANGU.
   IST_TEXTID-TDLINESIZE =  72.
***Appending to internal table for all textid/name.
   APPEND IST_TEXTID TO IST_TEXTID_ITEMS.
*
   PERFORM READ_TEXT_DTSPECS.
*
 ENDFORM.                    " ltxtdtsp
*&---------------------------------------------------------------------*
*&      Form  read_text_dtspecs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM READ_TEXT_DTSPECS.
   CLEAR   : IST_DTSPECS.
   REFRESH : IST_DTSPECS.
   PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
   PERFORM EDIT_TEXT.
*****To save temporarily in the stxl table with [CDDS9999999999(srno)]
**** for Creation and with [CDDS(reqno)(srno)] for Change
   IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ).
     WA_TEXTID = IST_TEXTID.
     PERFORM SAVE_TEXT.
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
 FORM READ_TEXT_DATA TABLES   P_IST_DTSPECS STRUCTURE  TLINE
                     USING    P_IST_TEXTID  STRUCTURE  THEAD.

   CALL FUNCTION 'READ_TEXT'
     EXPORTING
       CLIENT                  = SY-MANDT
       ID                      = P_IST_TEXTID-TDID
       LANGUAGE                = SY-LANGU
       NAME                    = P_IST_TEXTID-TDNAME
       OBJECT                  = P_IST_TEXTID-TDOBJECT
     IMPORTING
       HEADER                  = P_IST_TEXTID
     TABLES
       LINES                   = P_IST_DTSPECS
     EXCEPTIONS
       ID                      = 1
       LANGUAGE                = 2
       NAME                    = 3
       NOT_FOUND               = 4
       OBJECT                  = 5
       REFERENCE_CHECK         = 6
       WRONG_ACCESS_TO_ARCHIVE = 7
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
 FORM EDIT_TEXT.

   DATA: L_DISPLAY,
         L_USERTITLE,
         L_ITCED LIKE ITCED.
   L_USERTITLE       = 'X'.
   L_ITCED-USERTITLE = L_USERTITLE.

   IF ( G_MODE = 'CRE' ) OR  ( G_MODE = 'CHA' ).
     L_DISPLAY = ''.
   ELSE.
     L_DISPLAY = 'X'.
   ENDIF.
   CALL FUNCTION 'EDIT_TEXT'
         EXPORTING
              DISPLAY       = L_DISPLAY
              HEADER        = IST_TEXTID
*************************************************************
              CONTROL       = L_ITCED
*************************************************************
         TABLES
              LINES         = IST_DTSPECS
         EXCEPTIONS
              ID            = 1
              LANGUAGE      = 2
              LINESIZE      = 3
              NAME          = 4
              OBJECT        = 5
              TEXTFORMAT    = 6
              COMMUNICATION = 7
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
 FORM SAVE_TEXT.

   DATA : L_DTSPECS LIKE TLINE.

   LOOP AT IST_DTSPECS INTO L_DTSPECS.
     TRANSLATE L_DTSPECS TO UPPER CASE.
     MODIFY IST_DTSPECS FROM L_DTSPECS INDEX SY-TABIX.
   ENDLOOP.

   CALL FUNCTION 'SAVE_TEXT'
     EXPORTING
       CLIENT          = SY-MANDT
       HEADER          = WA_TEXTID
       SAVEMODE_DIRECT = 'X'
     TABLES
       LINES           = IST_DTSPECS
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

 ENDFORM.                    " SAVE_TEXT
*&---------------------------------------------------------------------*
*&      Form  delete_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DELETE_TEXT.
   CALL FUNCTION 'DELETE_TEXT'
     EXPORTING
       CLIENT          = SY-MANDT
       ID              = WA_TEXTID-TDID
       LANGUAGE        = SY-LANGU
       NAME            = WA_TEXTID-TDNAME
       OBJECT          = WA_TEXTID-TDOBJECT
       SAVEMODE_DIRECT = 'X'
     EXCEPTIONS
       NOT_FOUND       = 1
       OTHERS          = 2.

   IF SY-SUBRC <> 0.
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
 FORM DELETE_ADDEDTEXT.
   TYPES: BEGIN OF L_ITEMS,
           REQNO LIKE ZMM_CDHD-REQNO,
           SRNO LIKE ZMM_CDITEM-SRNO,
          END OF L_ITEMS.
   DATA: L_ITEMS_ITAB TYPE TABLE OF L_ITEMS WITH HEADER LINE.
**************************************************************
****To get the original items for a reqno
   REFRESH L_ITEMS_ITAB.
*
   SELECT REQNO SRNO FROM ZMM_CDITEM
    INTO CORRESPONDING FIELDS OF TABLE L_ITEMS_ITAB[]
                    WHERE REQNO = ZMM_CDHD_ST-REQNO.
   IF SY-SUBRC = 0.

****To delete these numbers from internal table ist_textid_items
****if found in original items list.
     LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
       READ TABLE L_ITEMS_ITAB WITH KEY
                  REQNO = WA_TEXTID-TDNAME+4(10)
                  SRNO  = WA_TEXTID-TDNAME+14(3).
       IF SY-SUBRC = 0.
         DELETE IST_TEXTID_ITEMS
                WHERE TDOBJECT = WA_TEXTID-TDOBJECT
                AND   TDID     = WA_TEXTID-TDID
                AND   TDNAME   = WA_TEXTID-TDNAME.
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
 FORM UNDO_LONGTEXT.
   IF NOT IST_TEXTID_ITEMS IS INITIAL.
     IF G_MODE = 'CRE'.
       LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
         PERFORM DELETE_TEXT.
       ENDLOOP.
       REFRESH IST_TEXTID_ITEMS.
     ELSEIF G_MODE = 'CHA'.
       PERFORM DELETE_ADDEDTEXT.
       LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
         PERFORM DELETE_TEXT.
       ENDLOOP.
       REFRESH IST_TEXTID_ITEMS.
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
 FORM TEXT_CONTROL_EINGABEBEREIT1.
   CALL METHOD GV_TEXT_EDITOR1->SET_READONLY_MODE
     EXPORTING
       READONLY_MODE          = GV_TEXT_EDITOR1->TRUE
     EXCEPTIONS
       ERROR_CNTL_CALL_METHOD = 1
       INVALID_PARAMETER      = 2
       OTHERS                 = 3.
   IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
      ( G_MODE = 'REL' ) OR ( G_MODE = 'MRP' ) OR
      ( G_MODE = 'APR' ) OR SY-TCODE = 'ZCODG'.

     CALL METHOD GV_TEXT_EDITOR2->SET_READONLY_MODE
       EXPORTING
         READONLY_MODE          = GV_TEXT_EDITOR2->FALSE
       EXCEPTIONS
         ERROR_CNTL_CALL_METHOD = 1
         INVALID_PARAMETER      = 2
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
 FORM TEXT_CONTROL_SET_TEXT_TABLE1.
*
   REFRESH: TLINETAB1,G_LINEFRTO_ITAB.
   IF G_MODE <> 'CRE'.
     APPEND LINES OF LINES_CORS TO TLINETAB1[].
   ENDIF.
*
   LOOP AT TLINETAB1[] INTO G_LINE132.
     IF ( G_LINE132+0(7) = '* Reply' ) OR
        ( G_LINE132+0(7) = '**Reply' ).
       G_LINEFRTO-LINE_FR = SY-TABIX.
       G_LINEFRTO-LINE_TO = SY-TABIX.
       APPEND G_LINEFRTO TO G_LINEFRTO_ITAB.
       CLEAR: G_LINEFRTO.
     ENDIF.
   ENDLOOP.
*
   CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
     TABLES
       ITF_TEXT    = TLINETAB1[]
       TEXT_STREAM = LT_TEXT_TABLE1.

   CALL METHOD GV_TEXT_EDITOR1->SET_TEXT_AS_STREAM
     EXPORTING
       TEXT            = LT_TEXT_TABLE1
     EXCEPTIONS
       ERROR_DP        = 1
       ERROR_DP_CREATE = 2
       OTHERS          = 3.
********************highlight**************************************
   CLEAR G_LINEFRTO.
   LOOP AT G_LINEFRTO_ITAB INTO G_LINEFRTO.
     CALL METHOD GV_TEXT_EDITOR1->HIGHLIGHT_LINES
       EXPORTING
         FROM_LINE      = G_LINEFRTO-LINE_FR
         TO_LINE        = G_LINEFRTO-LINE_TO
         HIGHLIGHT_MODE = 1.
   ENDLOOP.
********************************************************************

   IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
      ( G_MODE = 'REL' ) OR ( G_MODE = 'MRP' ) OR
      ( G_MODE = 'APR' ) OR SY-TCODE = 'ZCODG'.

     CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
       TABLES
         ITF_TEXT    = TLINETAB2
         TEXT_STREAM = LT_TEXT_TABLE2.

     CALL METHOD GV_TEXT_EDITOR2->SET_TEXT_AS_STREAM
       EXPORTING
         TEXT            = LT_TEXT_TABLE2
       EXCEPTIONS
         ERROR_DP        = 1
         ERROR_DP_CREATE = 2
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
 FORM GET_CORRESPONDENSE.

   DATA : L_CORS LIKE THEAD-TDNAME.

   IF G_MODE <> 'CRE'.
     CONCATENATE 'CORS' ZMM_CDHD_ST-REQNO INTO L_CORS.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         CLIENT                  = SY-MANDT
         ID                      = 'CORS'
         LANGUAGE                = SY-LANGU
         NAME                    = L_CORS
         OBJECT                  = 'ZMMCD'
       TABLES
         LINES                   = LINES_CORS
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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       G_CORS = ''.
     ELSE.
       G_CORS = 'X'.
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
 FORM SAVE_CORS_TEXT.
   DATA: L_THEADER LIKE THEAD.
   DATA: L_DATECH(10) TYPE C.
***********Assignments***********************
   CLEAR L_THEADER.
   L_THEADER-TDOBJECT   = 'ZMMCD'.
   L_THEADER-TDID       = 'CORS'.
   L_THEADER-TDSPRAS    =  SY-LANGU.
   L_THEADER-TDLINESIZE =  72.
   CONCATENATE 'CORS' ZMM_CDHD_ST-REQNO INTO L_THEADER-TDNAME.
   APPEND LINES OF TLINETAB2 TO TLINETAB1.
*********************************************
   IF NOT TLINETAB1[] IS INITIAL.
     CLEAR G_CORES_SENDER.
     CONCATENATE SY-DATUM+6(2) '/'
                 SY-DATUM+4(2) '/'
                 SY-DATUM+0(4) INTO L_DATECH.
     CONCATENATE '**Reply' L_DATECH SY-UNAME INTO G_CORES_SENDER
      SEPARATED BY '          '.
     IF NOT TLINETAB2[] IS INITIAL.
       APPEND G_CORES_SENDER TO TLINETAB1.
     ENDIF.
     CLEAR G_CORES_SENDER.
     CALL FUNCTION 'SAVE_TEXT'
       EXPORTING
         CLIENT          = SY-MANDT
         HEADER          = L_THEADER
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
*&      Form  destroy_ctrl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM DESTROY_CTRL.
   CASE G_MODE.
     WHEN 'CRE' OR 'CHA' OR 'REL' OR 'MRP' OR 'APR'.
       CALL METHOD GV_TEXT_EDITOR1->FREE.
       CALL METHOD GV_TEXT_EDITOR2->FREE.
     WHEN 'DIS' OR 'DEL'.
       CALL METHOD GV_TEXT_EDITOR1->FREE.
   ENDCASE.
   CLEAR:GV_TEXT_EDITOR1,GV_TEXT_EDITOR2.

 ENDFORM.                    " destroy_ctrl
*&---------------------------------------------------------------------*
*&      Form  check_items
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_ITEMS.
   DATA : L_T110 TYPE T_TABCTRL110,
          L_T120 TYPE T_TABLCTRL120,
          L_T130 TYPE T_TABLCTRL130.
   CLEAR G_SAVEFLAG.
*
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
       READ TABLE G_TABCTRL110_ITAB INTO L_T110 INDEX 1.
       IF SY-SUBRC = 0.
         IF NOT L_T110-UOM IS INITIAL.
           G_SAVEFLAG = 'Y'.
         ELSE.
           G_SAVEFLAG = 'N'.
         ENDIF.
       ELSE.
         G_SAVEFLAG = 'N'.
       ENDIF.
*       If G_duplicate_rec = 'X'.
*         g_saveflag = 'N'.
*         G_duplicate_rec = ''.
*       Endif.
     WHEN 'ZSPR'.
       READ TABLE G_TABLCTRL120_ITAB INTO L_T120 INDEX 1.
       IF SY-SUBRC = 0.
         IF NOT L_T120-MANU IS INITIAL.
           G_SAVEFLAG = 'Y'.
         ELSE.
           G_SAVEFLAG = 'N'.
         ENDIF.
       ELSE.
         G_SAVEFLAG = 'N'.
       ENDIF.
     WHEN 'ZCAP'.
       READ TABLE G_TABLCTRL130_ITAB INTO L_T130 INDEX 1.
       IF SY-SUBRC = 0.
         IF NOT L_T130-UOM IS INITIAL.
           G_SAVEFLAG = 'Y'.
         ELSE.
           G_SAVEFLAG = 'N'.
         ENDIF.
       ELSE.
         G_SAVEFLAG = 'N'.
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
 FORM CHECK_LT_EXIST USING    P_TDNAME.

   REFRESH G_LINES.
   CALL FUNCTION 'READ_TEXT'
     EXPORTING
       CLIENT                  = SY-MANDT
       ID                      = 'CDDS'
       LANGUAGE                = SY-LANGU
       NAME                    = P_TDNAME
       OBJECT                  = 'ZMMCD'
     TABLES
       LINES                   = G_LINES
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
 FORM LOCK_REQHD.
   CALL FUNCTION 'ENQUEUE_EZ_MM_CDHD'
     EXPORTING
       MODE_ZMM_CDHD  = 'E'
       MANDT          = SY-MANDT
       REQNO          = ZMM_CDHD_ST-REQNO
     EXCEPTIONS
       FOREIGN_LOCK   = 1
       SYSTEM_FAILURE = 2
       OTHERS         = 3.

   IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
     MOVE 'Y' TO G_LOCK.
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
 FORM UNLOCK_REQ .
*********Header*******************************
   CALL FUNCTION 'DEQUEUE_EZ_MM_CDHD'
     EXPORTING
       MODE_ZMM_CDHD = 'E'
       MANDT         = SY-MANDT
       REQNO         = ZMM_CDHD_ST-REQNO.

 ENDFORM.                    " unlock_req
***************************************************
*****  AT USER COMMAND IN LIST PROCESSING
***************************************************
 AT USER-COMMAND.
   IF OKCODE_100 = 'INS_MODI'.
     LEAVE TO SCREEN 0.
   ENDIF.
   IF SY-UCOMM = 'AGREE'.
     IF G_MODE = 'REL'.
       PERFORM UPDATE_RELEASE.
*       perform update_noofhits.
       PERFORM CLEAR_VAR.
     ELSEIF G_MODE = 'APR'.
       PERFORM UPDATE_APPROVAL.
     ENDIF.
     PERFORM CLEAR_VAR.
   ENDIF.
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
 FORM OTHER_SECTIME.
   IF SY-TCODE <> 'ZCODG'.
     IF ZMM_CDITEM-DESC1 = 'OTHER'.
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
                              SCREEN-NAME = 'G_DESC4' ).
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SCREEN-NAME = 'G_DESC3' OR SCREEN-NAME = 'G_DESC4'.
           SCREEN-REQUIRED = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
     ELSEIF ZMM_CDITEM-OTH1 = '' AND
*          ZMM_CDITEM-OTH2 = 'X'.
            ZMM_CDITEM-DESC2 = 'OTHER'.


       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'    OR
            SCREEN-NAME = 'G_MATGP'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
                              SCREEN-NAME = 'G_DESC4' ).
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.
     ELSEIF ZMM_CDITEM-OTH1 = '' AND
            ZMM_CDITEM-OTH2 = '' AND
*          ZMM_CDITEM-OTH3 = 'X' AND
            ZMM_CDITEM-DESC3 = 'OTHER'.

       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'     OR
            SCREEN-NAME = 'G_DESC2'     OR
            SCREEN-NAME = 'G_MATGP'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
                              SCREEN-NAME = 'G_DESC4' ).
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.

     ELSEIF ZMM_CDITEM-OTH1 = '' AND
            ZMM_CDITEM-OTH2 = '' AND
            ZMM_CDITEM-OTH3 = '' AND
*          ZMM_CDITEM-OTH4 = 'X'.
           ZMM_CDITEM-DESC4 = 'OTHER'.

       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'     OR
            SCREEN-NAME = 'G_DESC2'     OR
            SCREEN-NAME = 'G_DESC3'     OR
            SCREEN-NAME = 'G_MATGP'.

           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
                              SCREEN-NAME = 'G_DESC4' ).
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
     ENDIF.

   ELSE.

*     If screen-name = 'ADNL_DESC'.
*        screen = 0.
*        modify screen.
*     Endif.
     IF ZMM_CDITEM-DESC1 = 'OTHER'.
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC4 IS INITIAL
            AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC3 IS INITIAL
            AND SCREEN-NAME = 'G_DESC3'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF SCREEN-NAME = 'G_DESC3' OR SCREEN-NAME = 'G_DESC4'.
           SCREEN-REQUIRED = 0.
           MODIFY SCREEN.
         ENDIF.

         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.

     ELSEIF ZMM_CDITEM-DESC2 = 'OTHER'.
*           ZMM_CDITEM-OTH1 = 'X' AND
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'    OR
            SCREEN-NAME = 'G_MATGP'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC4 IS INITIAL
            AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC3 IS INITIAL
            AND SCREEN-NAME = 'G_DESC3'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
     ELSEIF ZMM_CDITEM-DESC3 = 'OTHER'.
*     ZMM_CDITEM-OTH2 = 'X' AND


       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'     OR
            SCREEN-NAME = 'G_DESC2'     OR
            SCREEN-NAME = 'G_MATGP'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC4 IS INITIAL
            AND SCREEN-NAME = 'G_DESC4'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF ZMM_CDITEM-DESC3 IS INITIAL
            AND SCREEN-NAME = 'G_DESC3'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.

     ELSEIF  ZMM_CDITEM-DESC4 = 'OTHER'.

*     ZMM_CDITEM-OTH3 = 'X' AND

       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_USER_DESC' OR
            SCREEN-NAME = 'G_DESC1'     OR
            SCREEN-NAME = 'G_DESC2'     OR
            SCREEN-NAME = 'G_DESC3'     OR
            SCREEN-NAME = 'G_MATGP'.

           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

         IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
     ENDIF.
   ENDIF.
 ENDFORM.                    " other_sectime
*&---------------------------------------------------------------------*
*&      Form  sort_sto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM SORT_STO USING P_ORDER.
   READ  TABLE TABCTRL110-COLS WITH  KEY SELECTED = 'X' INTO
         WA_TABCTRL110_COLS.
   IF SY-SUBRC <> 0.
     MESSAGE I084(ZMM_OTH).
   ENDIF.
   G_SEL_COLSORT = WA_TABCTRL110_COLS-SCREEN-NAME.
   IF P_ORDER = 'ASCENDING'.
     SORT G_TABCTRL110_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
   ELSEIF P_ORDER = 'DESCENDING'.
     SORT G_TABCTRL110_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_sto
*&---------------------------------------------------------------------*
*&      Form  sort_spr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM SORT_SPR USING    P_ORDER.
   READ  TABLE TABLCTRL120-COLS WITH  KEY SELECTED = 'X' INTO
         WA_TABLCTRL120_COLS.
   IF SY-SUBRC <> 0.
     MESSAGE I084(ZMM_OTH).
   ENDIF.
   G_SEL_COLSORT = WA_TABLCTRL120_COLS-SCREEN-NAME.
   IF P_ORDER = 'ASCENDING'.
     SORT G_TABLCTRL120_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
   ELSEIF P_ORDER = 'DESCENDING'.
     SORT G_TABLCTRL120_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_spr
*&---------------------------------------------------------------------*
*&      Form  sort_cap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM SORT_CAP USING    P_ORDER.
   READ  TABLE TABLCTRL130-COLS WITH  KEY SELECTED = 'X' INTO
         WA_TABLCTRL130_COLS.
   IF SY-SUBRC <> 0.
     MESSAGE I084(ZMM_OTH).
   ENDIF.
   G_SEL_COLSORT = WA_TABLCTRL130_COLS-SCREEN-NAME.
   IF P_ORDER = 'ASCENDING'.
     SORT G_TABLCTRL130_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
   ELSEIF P_ORDER = 'DESCENDING'.
     SORT G_TABLCTRL130_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
   ENDIF.
 ENDFORM.                    " sort_cap
*&---------------------------------------------------------------------*
*&      Form  sort_dis
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_ORDER  text
*----------------------------------------------------------------------*
 FORM SORT_DIS USING    P_ORDER.
   READ  TABLE TABLCTRL140-COLS WITH  KEY SELECTED = 'X' INTO
          WA_TABLCTRL140_COLS.
   IF SY-SUBRC <> 0.
     MESSAGE I084(ZMM_OTH).
   ENDIF.
   G_SEL_COLSORT = WA_TABLCTRL140_COLS-SCREEN-NAME.
   IF P_ORDER = 'ASCENDING'.
     SORT G_TABLCTRL140_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
   ELSEIF P_ORDER = 'DESCENDING'.
     SORT G_TABLCTRL140_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
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
 FORM SRCHLP_SPR_DEL.

   CLEAR G_SPR_PAR.

   IF G_SH_CAPEQT = 'X' AND G_SH_MFR = '' AND G_SH_MDLNO = ''.
     G_SPR_PAR   = '100'.
   ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = 'X' AND G_SH_MDLNO = ''.
     G_SPR_PAR   = '120'.
   ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = 'X' AND G_SH_MDLNO = 'X'.
     G_SPR_PAR   = '123'.
   ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = '' AND G_SH_MDLNO = 'X'.
     G_SPR_PAR   = '103'.
   ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = 'X' AND G_SH_MDLNO = ''.
     G_SPR_PAR   = '020'.
   ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = 'X' AND G_SH_MDLNO = 'X'.
     G_SPR_PAR   = '023'.
   ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = '' AND G_SH_MDLNO = 'X'.
     G_SPR_PAR   = '003'.
   ENDIF.

   CASE G_SPR_PAR.
     WHEN '100'.
       DELETE IST_SRCHLP_CP
       WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
     WHEN '120'.
       DELETE IST_SRCHLP_CP
       WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
       DELETE IST_SRCHLP_CP
       WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
     WHEN '123'.
       DELETE IST_SRCHLP_CP
       WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
       DELETE IST_SRCHLP_CP
       WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
       DELETE IST_SRCHLP_CP
       WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
     WHEN '103'.
       DELETE IST_SRCHLP_CP
       WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
       DELETE IST_SRCHLP_CP
       WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
     WHEN '020'.
       DELETE IST_SRCHLP_CP
       WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
     WHEN '023'.
       DELETE IST_SRCHLP_CP
       WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
       DELETE IST_SRCHLP_CP
       WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
     WHEN '003'.
       DELETE IST_SRCHLP_CP
       WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
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
 FORM TCODE_ZCODG_ATTR.
   IF SY-TCODE = 'ZCODG' AND G_MODE <> 'DIS'.
     LOOP AT SCREEN.
       IF SCREEN-GROUP3 = 'GC'.
         IF SCREEN-NAME = 'ZMM_CDHD_ST-REQCL'.
           PERFORM CHECK_MORETHANONEGRP.
           IF G_CODUSER <> 'A'.
             IF G_GRPCOUNT > 1.
               SCREEN-INPUT = 0.
               MODIFY SCREEN.
             ELSEIF G_GRPCOUNT = 1.
               SCREEN-INPUT = 1.
               MODIFY SCREEN.
             ENDIF.
           ELSE.
             SCREEN-INPUT = 1.
             MODIFY SCREEN.
           ENDIF.
         ELSE.
           SCREEN-INPUT = 1.
           MODIFY SCREEN.
         ENDIF.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC1'.
         IF ZMM_CDITEM-OTH1 = 'X'.
           SCREEN-INPUT = 1.
         ELSE.
           SCREEN-INPUT = 0.
         ENDIF.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC2'.
         IF ZMM_CDITEM-OTH1 = 'X' OR
            ZMM_CDITEM-OTH2 = 'X'.
           SCREEN-INPUT = 1.
         ELSE.
           SCREEN-INPUT = 0.
         ENDIF.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC3'.
         IF ZMM_CDITEM-OTH1 = 'X' OR
            ZMM_CDITEM-OTH2 = 'X' OR
            ZMM_CDITEM-OTH3 = 'X'.
           IF NOT ZMM_CDITEM-DESC3 IS INITIAL.
             SCREEN-INPUT = 1.
           ENDIF.
         ELSE.
           SCREEN-INPUT = 0.
         ENDIF.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC4'.
         IF ZMM_CDITEM-OTH1 = 'X' OR
            ZMM_CDITEM-OTH2 = 'X' OR
            ZMM_CDITEM-OTH3 = 'X' OR
            ZMM_CDITEM-OTH4 = 'X'.
           IF NOT ZMM_CDITEM-DESC4 IS INITIAL.
             SCREEN-INPUT = 1.
           ENDIF.
         ELSE.
           SCREEN-INPUT = 0.
         ENDIF.
         MODIFY SCREEN.
*       elseif screen-name = 'ZMM_CDITEM-USER_DESC'.
*         if not ZMM_CDITEM-USER_DESC is initial.
*           screen-input = 1.
*           modify screen.
*         endif.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-MDLNO'  OR
              SCREEN-NAME = 'ZMM_CDITEM-PARTNO' OR
              SCREEN-NAME = 'ZMM_CDITEM-MANU'.
*         if ZMM_CDITEM-OTH_MDL = 'X'.
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
*         else.
*           screen-input = 0.
*           modify screen.
*         endif.
       ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC_CDCELL'.
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'WA_SRCHLP-MARK' OR
              SCREEN-NAME = 'DD' OR
              SCREEN-NAME = 'PB_ADNL_DESC'.
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'G_TABCTRL110_WA-FLAG'. "ZSTO
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME  = 'G_TABLCTRL120_WA-FLAG'. "ZSPR
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME  = 'G_TABLCTRL130_WA-FLAG'. "ZCAP
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'G_TABCTRL110_WA-FLAG'.
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ELSE.
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ENDIF.
       IF NOT G_TABCTRL110_WA-MATCODE IS INITIAL OR
          NOT G_TABLCTRL120_WA-MATCODE IS INITIAL OR
          NOT G_TABLCTRL130_WA-MATCODE IS INITIAL.
         IF SCREEN-GROUP4 = 'MC'.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDIF.
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
 FORM UPDATE_CODES.
   REFRESH IST_ZMM_CDITEM.
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
       LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
         MOVE-CORRESPONDING G_TABCTRL110_WA TO WA_ZMM_CDITEM.
         MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
         IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
           MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
         ENDIF.
         IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
           MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
         ENDIF.
         APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         CLEAR WA_ZMM_CDITEM.
       ENDLOOP.
     WHEN 'ZSPR'.
       LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
         MOVE-CORRESPONDING G_TABLCTRL120_WA TO WA_ZMM_CDITEM.
         MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
         IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
           MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
         ENDIF.
         IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
           MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
         ENDIF.
         APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         CLEAR WA_ZMM_CDITEM.
       ENDLOOP.
     WHEN 'ZCAP'.
       LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
         MOVE-CORRESPONDING G_TABLCTRL130_WA TO WA_ZMM_CDITEM.
         MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
         IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
           MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
         ENDIF.
         IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
           MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
         ENDIF.
         APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         CLEAR WA_ZMM_CDITEM.
       ENDLOOP.

     WHEN 'ZDIS'.
       LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
         MOVE-CORRESPONDING G_TABLCTRL140_WA TO WA_ZMM_CDITEM.
         MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
         IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
           MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
         ENDIF.
         IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
           MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
         ENDIF.
         APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
         CLEAR WA_ZMM_CDITEM.
       ENDLOOP.
   ENDCASE.
   MODIFY ZMM_CDITEM FROM TABLE IST_ZMM_CDITEM.
************************************************************
****Saving the long text.                              *****
************************************************************
******Header(Correspondence)********************************
   PERFORM SAVE_CORS_TEXT.

 ENDFORM.                    " update_codes
*&---------------------------------------------------------------------*
*&      Form  check_reqstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_REQSTATUS.
   DATA : L_110_ITAB TYPE TABLE OF T_TABCTRL110,
          L_120_ITAB TYPE TABLE OF T_TABLCTRL120,
          L_130_ITAB TYPE TABLE OF T_TABLCTRL130,
          L_140_ITAB TYPE TABLE OF T_TABLCTRL140.
   DATA : L_TITEM TYPE I,
          L_CITEM TYPE I,
          L_DCITEM TYPE I,
          L_RAITEM TYPE I,
          L_ITEM   TYPE I.
   CLEAR: L_TITEM,L_CITEM,L_DCITEM,L_RAITEM.

   SELECT COUNT(*) INTO L_TITEM FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO.
*
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
       REFRESH L_110_ITAB.
       APPEND LINES OF G_TABCTRL110_ITAB TO L_110_ITAB.
       DELETE L_110_ITAB WHERE MATCODE = ''.
       DESCRIBE TABLE L_110_ITAB LINES L_CITEM.
     WHEN 'ZSPR'.
       REFRESH L_120_ITAB.
       APPEND LINES OF G_TABLCTRL120_ITAB TO L_120_ITAB.
       DELETE L_120_ITAB WHERE MATCODE = ''.
       DESCRIBE TABLE L_120_ITAB LINES L_CITEM.
     WHEN 'ZCAP'.
       REFRESH L_130_ITAB.
       APPEND LINES OF G_TABLCTRL130_ITAB TO L_130_ITAB.
       DELETE L_130_ITAB WHERE MATCODE = ''.
       DESCRIBE TABLE L_130_ITAB LINES L_CITEM.
     WHEN 'ZDIS'.
       REFRESH L_140_ITAB.
       APPEND LINES OF G_TABLCTRL140_ITAB TO L_140_ITAB.
       DELETE L_140_ITAB WHERE MATCODE = ''.
       DESCRIBE TABLE L_140_ITAB LINES L_CITEM.
   ENDCASE.
***
   IF L_CITEM = L_TITEM.
     MOVE 'C' TO ZMM_CDHD_ST-REQCL.
   ELSEIF L_CITEM < L_TITEM.
     IF ZMM_CDHD_ST-REQCL <> 'IR'.
       MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
     ENDIF.
   ENDIF.
***
   SELECT COUNT(*) INTO L_DCITEM FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO
          AND   MATCODE <> ''.
   SELECT COUNT(*) INTO L_RAITEM FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO
          AND   REJ_FLG IN ('RM','RT').
***

   IF ZMM_CDHD_ST-REQCL = 'N' OR
      ZMM_CDHD_ST-REQCL = 'IC'.
     L_ITEM = L_DCITEM + L_RAITEM.
     IF L_TITEM = L_ITEM.
       MOVE 'C' TO ZMM_CDHD_ST-REQCL.
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
 FORM SEND_MAIL_TO_CDCELL.
   DATA: L_TEXT  TYPE SOLI,
         L_NAME  LIKE SOOD1-OBJNAM,
         L_TITLE LIKE SOOD1-OBJDES,
         L_USER  LIKE SY-UNAME.
   DATA  L_TEXT_ITAB LIKE TABLE OF L_TEXT.
   CLEAR : L_NAME,L_TITLE,L_TEXT,L_USER.
   REFRESH L_TEXT_ITAB.
**Assignments.....
   L_NAME   = ZMM_CDHD_ST-REQNO.
   CONCATENATE 'New MatCode Request for' ZMM_CDHD_ST-REQNO
               INTO L_TITLE SEPARATED BY SPACE.
   L_TEXT = 'Please check the Request and provide the new material codes.'
            &'This is a system generated mail, please do not reply.'.
   APPEND L_TEXT TO L_TEXT_ITAB.

   L_USER = 'CODIFICATION'.

***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       MAILNAME          = L_NAME
       MAILTITEL         = L_TITLE
       USER              = L_USER
    TABLES
      TEXT              =  L_TEXT_ITAB.

   IF SY-SUBRC <> 0.
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
 FORM SEND_MAIL_TO_REQN.
   DATA:  R_TEXT  TYPE SOLI,
          R_NAME  LIKE SOOD1-OBJNAM,
          R_TITLE LIKE SOOD1-OBJDES,
          R_USER  TYPE SY-UNAME.
   DATA:  R_TEXT_ITAB LIKE TABLE OF R_TEXT.
   CLEAR : R_NAME,R_TITLE,R_TEXT.
   REFRESH R_TEXT_ITAB.
**Assignments.....
   R_NAME   = ZMM_CDHD_ST-REQNO.
   CONCATENATE 'Request' ZMM_CDHD_ST-REQNO 'Status'
               INTO R_TITLE SEPARATED BY SPACE.
   IF ZMM_CDHD_ST-REQCL = 'C'.
     R_TEXT = 'Request has been updated.Please check the Request,Request'
   &'status and Correspondence within it.This is a system generated mail,'
   &'please do not reply. - Codification Cell'.
     APPEND R_TEXT TO R_TEXT_ITAB.
   ELSEIF ZMM_CDHD_ST-REQCL = 'IR'.
     R_TEXT = 'Please go through the correspondence comments if any & the'
   &'request. After changes, the request should be re-released, re-approved'
   &'by the MRP controller and re-approved by Technical Approving'.
     APPEND R_TEXT TO R_TEXT_ITAB.
     CLEAR R_TEXT.
     R_TEXT = 'Authority(L2 or above) if required as per release strategy.'
   &'All the actions taken should be recorded only in correspondence. No'
   &'separate communication will be entertained. This is a system generated'
   &'mail.Please do not reply'.
     APPEND R_TEXT TO R_TEXT_ITAB.
   ENDIF.

*   append r_text to r_text_itab.
   SELECT SINGLE REQCPF INTO R_USER FROM ZMM_CDHD
          WHERE REQNO = ZMM_CDHD_ST-REQNO.
***Function
   CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
     EXPORTING
*
       MAILNAME          = R_NAME
       MAILTITEL         = R_TITLE
       USER              = R_USER
    TABLES
      TEXT              =  R_TEXT_ITAB
    EXCEPTIONS
      ERROR             = 1
      OTHERS            = 2.
   IF SY-SUBRC <> 0.
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
 FORM CONFIRM_DELETION.
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
   DATA : L_GET8(1) TYPE C.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
      TITLEBAR                    = 'Confirm Deletion'
*      DIAGNOSE_OBJECT             = ' '
       TEXT_QUESTION               = 'Once deleted can not be restore, Continue?'
*      TEXT_BUTTON_1               = 'Ja'(001)
*      ICON_BUTTON_1               = ' '
*      TEXT_BUTTON_2               = 'Nein'(002)
*      ICON_BUTTON_2               = ' '
*      DEFAULT_BUTTON              = '1'
*      DISPLAY_CANCEL_BUTTON       = 'X'
*      USERDEFINED_F1_HELP         = ' '
      START_COLUMN                = 25
      START_ROW                   = 6
*      POPUP_TYPE                  =
*      IV_QUICKINFO_BUTTON_1       = ' '
*      IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      ANSWER                      = L_GET8
*    TABLES
*      PARAMETER                   =
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2
             .
   IF SY-SUBRC = 0.
     CASE L_GET8.
       WHEN '1'.
         MOVE 'J' TO G_CONFDEL.
       WHEN '2'.
         MOVE 'N' TO G_CONFDEL.
     ENDCASE.
   ENDIF.

   " End of <RD1K960036>.
 ENDFORM.                    " confirm_deletion

*----------------------------------------------------------------------*
*&      Form  GC_FIELDS_115
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GC_FIELDS_115.
   IF G_OK_CODE115 = 'OK115'.
     IF G_OK_CODE110 = 'PB_AD'.
       G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
       CONCATENATE G_TABCTRL110_WA-DESC_FIN
                  G_TABCTRL110_WA-USER_DESC
             INTO G_TABCTRL110_WA-DESC_FIN
             SEPARATED BY SPACE.
       CONDENSE G_TABCTRL110_WA-DESC_FIN.
       G_OTH = ''.
       G_USER_DESC = ''.
     ELSE.
*     case 'X'.
       CASE 'OTHER'.
*       when g_TABCTRL110_wa-oth1.
         WHEN ZMM_CDITEM-DESC1.
           G_TABCTRL110_WA-DESC1 = G_DESC1.
           G_TABCTRL110_WA-DESC2 = G_DESC2.
           G_TABCTRL110_WA-DESC3 = G_DESC3.
           G_TABCTRL110_WA-DESC4 = G_DESC4.
           G_TABCTRL110_WA-MATGP = G_MATGP.
           CLEAR : G_DESC1,G_DESC2,G_DESC3,G_DESC4.
*         move : 'X' to g_TABCTRL110_wa-oth2.
           G_TABCTRL110_WA-OTH1 = 'X'.
           G_TABCTRL110_WA-OTH2 = 'X'.

*+
           IF G_TABCTRL110_WA-DESC3 <> ''.
             G_TABCTRL110_WA-OTH3 = 'X'.
           ELSE.
             G_TABCTRL110_WA-OTH3 = ''.
           ENDIF.

           IF G_TABCTRL110_WA-DESC4 <> ''.
             G_TABCTRL110_WA-OTH4 = 'X'.
           ELSE.
             G_TABCTRL110_WA-OTH4 = ''.
           ENDIF.
*-
           G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
           LOOP AT SCREEN.
             IF SCREEN-NAME = 'ZMM_CDITEM-DESC1' OR
                SCREEN-NAME = 'ZMM_CDITEM-DESC2' OR
                SCREEN-NAME = 'ZMM_CDITEM-DESC3' OR
                SCREEN-NAME = 'ZMM_CDITEM-DESC4'.
               SCREEN-INTENSIFIED = 1.
               MODIFY SCREEN.
             ENDIF.
           ENDLOOP.
*       when g_TABCTRL110_wa-oth2.
         WHEN ZMM_CDITEM-DESC2.
           G_TABCTRL110_WA-DESC2 = G_DESC2.    "+
           G_TABCTRL110_WA-DESC3 = G_DESC3.    "+
           G_TABCTRL110_WA-DESC4 = G_DESC4.    "+
*+
           G_TABCTRL110_WA-OTH2 = 'X'.

           IF G_TABCTRL110_WA-DESC3 <> ''.
             G_TABCTRL110_WA-OTH3 = 'X'.
           ELSE.
             G_TABCTRL110_WA-OTH3 = ''.
           ENDIF.
           IF G_TABCTRL110_WA-DESC4 <> ''.
             G_TABCTRL110_WA-OTH4 = 'X'.
           ELSE.
             G_TABCTRL110_WA-OTH4 = ''.
           ENDIF.
*-
           CLEAR : G_DESC2,G_DESC3,G_DESC4.
           G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
           IF G_MODE = 'CHA'.
             MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX
             G_CURR_LINE_110.
           ENDIF.
         WHEN ZMM_CDITEM-DESC3.
           G_TABCTRL110_WA-DESC3 = G_DESC3.    "+
           G_TABCTRL110_WA-DESC4 = G_DESC4.    "+
           G_TABCTRL110_WA-OTH3 = 'X'.

           IF G_TABCTRL110_WA-DESC4 <> ''.
             MOVE 'X' TO G_TABCTRL110_WA-OTH4.
           ELSE.
             MOVE '' TO G_TABCTRL110_WA-OTH4.
           ENDIF.

           G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
           IF G_MODE = 'CHA'.
             MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX
             G_CURR_LINE_110.
           ENDIF.

           CLEAR : G_DESC3,G_DESC4.
         WHEN ZMM_CDITEM-DESC4.
           G_TABCTRL110_WA-DESC4 = G_DESC4.     "+
           G_TABCTRL110_WA-OTH4 = 'X'.
           G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
           CLEAR : G_DESC4.
       ENDCASE.
     ENDIF.
   ELSE.

   ENDIF.

   CLEAR : G_DESC1,G_DESC2,G_DESC3,G_DESC4,G_OK_CODE110,G_USER_DESC,
           G_MATGP.
   CLEAR : G_OK_CODE115. "+



 ENDFORM.                    " GC_FIELDS_115
*&---------------------------------------------------------------------*
*&      Form  GC_input_keywords
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GC_INPUT_KEYWORDS.
   CASE 'X'.
     WHEN G_TABCTRL110_WA-OTH2.
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_DESC1'.
           SCREEN-INPUT = 0.
           SCREEN-INTENSIFIED = 1.
           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.
       G_DESC1 = G_TABCTRL110_WA-DESC1.
     WHEN G_TABCTRL110_WA-OTH3.
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_DESC1' OR SCREEN-NAME = 'G_DESC2'.
           SCREEN-INPUT = 0.
           SCREEN-INTENSIFIED = 1.

           MODIFY SCREEN.
         ENDIF.
       ENDLOOP.
       G_DESC1 = G_TABCTRL110_WA-DESC1.
       G_DESC2 = G_TABCTRL110_WA-DESC2.

     WHEN G_TABCTRL110_WA-OTH4.
       LOOP AT SCREEN.
         IF SCREEN-NAME = 'G_DESC1' OR SCREEN-NAME = 'G_DESC2' OR
            SCREEN-NAME = 'G_DESC3'.
           SCREEN-INPUT = 0.
           SCREEN-INTENSIFIED = 1.

           MODIFY SCREEN.
         ENDIF.

       ENDLOOP.
       G_DESC1 = G_TABCTRL110_WA-DESC1.
       G_DESC2 = G_TABCTRL110_WA-DESC2.
       G_DESC3 = G_TABCTRL110_WA-DESC3.
   ENDCASE.
 ENDFORM.                    " GC_input_keywords
*&---------------------------------------------------------------------*
*&      Module  GC_CURSOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE GC_CURSOR INPUT.
 ENDMODULE.                 " GC_CURSOR  INPUT
*&---------------------------------------------------------------------*
*&      Form  SELECT_MATERIAL_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SELECT_MATERIAL_DETAILS.

   CLEAR DO_NOT_CHANGE_FLAG.

   IF G_MODE = 'CRE' OR G_MODE = 'CHA'.

     CASE G_HITS_PAR.

       WHEN '0'.
         G_MAT_FND = '0'.
       WHEN '1'.
         IF CHECK_POS = 1
            AND DESC22 IS INITIAL
            AND DESC33 IS INITIAL
            AND DESC44 IS INITIAL.
           DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
           IF G_MAT_FND = 0.
             G_MAT_FND_FLAG = 'X'.
           ENDIF.
         ENDIF.
       WHEN '2'.
         IF CHECK_POS = 2
            AND DESC33 IS INITIAL
            AND DESC44 IS INITIAL.
           DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
           IF G_MAT_FND = 0.
             G_MAT_FND_FLAG = 'X'.
           ENDIF.
         ENDIF.
       WHEN '3'.
         IF CHECK_POS = 3
            AND DESC44 IS INITIAL.
           DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
           IF G_MAT_FND = 0.
             G_MAT_FND_FLAG = 'X'.
           ENDIF.
         ENDIF.
       WHEN '4'.
         IF CHECK_POS = 4. .
           DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
           IF G_MAT_FND = 0.
             G_MAT_FND_FLAG = 'X'.
           ENDIF.
         ENDIF.
         IF G_HITS_PAR_OTH = 'X'.
           DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
           IF G_MAT_FND = 0.
             G_MAT_FND_FLAG = 'X'.
           ENDIF.
           CLEAR G_HITS_PAR_OTH.
         ENDIF.
       WHEN OTHERS.
         CLEAR G_MAT_FND.

     ENDCASE.

     IF G_LINENO_OLD <> G_LINENO.
*     clear g_mat_fnd.
       DO_NOT_CHANGE_FLAG = 'X'.
     ENDIF.

     CLEAR G_HITS_PAR.

   ENDIF.

   LOOP AT IST_SRCHLP INTO WA_SRCHLP.

     DATA : L_MATNR LIKE THEAD-TDNAME.
     L_MATNR = WA_SRCHLP-MATNR.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*
         ID                            = 'BEST'
         LANGUAGE                      = 'E'
         NAME                          =  L_MATNR
         OBJECT                        = 'MATERIAL'
       TABLES
         LINES                         = LINES
       EXCEPTIONS
          ID                            = 1
          LANGUAGE                      = 2
          NAME                          = 3
          NOT_FOUND                     = 4
          OBJECT                        = 5
          REFERENCE_CHECK               = 6
          WRONG_ACCESS_TO_ARCHIVE       = 7
          OTHERS                        = 8.

     IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       WA_SRCHLP-MARK = '1'.
       MODIFY IST_SRCHLP FROM WA_SRCHLP.
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
 FORM DISPLAY_TEXT.

   DATA : L_MATNR LIKE THEAD-TDNAME.
   DATA : L_HEADER LIKE THEAD.
   DATA : I LIKE SY-TABIX.
   READ TABLE IST_SRCHLP INTO WA_SRCHLP INDEX G_CURR_LINE_100.
   L_MATNR = WA_SRCHLP-MATNR.

*
   IF NOT L_MATNR IS INITIAL AND
     G_CURR_LINE_100 <> 0.
     CALL FUNCTION 'READ_TEXT'
       EXPORTING
*
         ID                            = 'BEST'
         LANGUAGE                      = 'E'
         NAME                          = L_MATNR
         OBJECT                        = 'MATERIAL'
*
       TABLES
         LINES                         = TLINETAB
  EXCEPTIONS
    ID                            = 1
    LANGUAGE                      = 2
    NAME                          = 3
    NOT_FOUND                     = 4
    OBJECT                        = 5
    REFERENCE_CHECK               = 6
    WRONG_ACCESS_TO_ARCHIVE       = 7
    OTHERS                        = 8
               .
     IF SY-SUBRC <> 0.

       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
 FORM TEXT_CONTROL_EINGABEBEREIT.

   CALL METHOD GV_TEXT_EDITOR->SET_READONLY_MODE
     EXPORTING
       READONLY_MODE          = GV_TEXT_EDITOR->TRUE
     EXCEPTIONS
       ERROR_CNTL_CALL_METHOD = 1
       INVALID_PARAMETER      = 2
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
 FORM TEXT_CONTROL_SET_TEXT_TABLE.

   CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
     TABLES
       ITF_TEXT    = TLINETAB
       TEXT_STREAM = LT_TEXT_TABLE.

   CALL METHOD GV_TEXT_EDITOR->SET_TEXT_AS_STREAM
     EXPORTING
       TEXT            = LT_TEXT_TABLE
     EXCEPTIONS
       ERROR_DP        = 1
       ERROR_DP_CREATE = 2
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
 FORM CLEAR_SRCHLP_PARMS.

   CLEAR : DESC11, DESC22, DESC33, DESC44, DESC55, G_PARTNO, G_MATGP,
           G_MATTY, SEL_FLAG.

 ENDFORM.                    " clear_srchlp_parms
*&---------------------------------------------------------------------*
*&      Form  Create_matcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CREATE_MATCODE.

   DATA : L_NUM1 TYPE SY-INDEX.
   DATA : L_NUM2(3) TYPE C.
   DATA : L_CAP130 TYPE T_TABLCTRL130.


   IF ZMM_CDHD_ST-MTART = 'ZCAP'.
     READ TABLE G_TABLCTRL130_ITAB INTO L_CAP130
          WITH KEY SPA_GRP = ''.
     IF SY-SUBRC = 0.
       MESSAGE I083(ZMM_OTH).
       CLEAR OKCODE_100.
       EXIT.
     ENDIF.
   ENDIF.


   IF G_NEW_CAP_RANGE <> 'X'.
     PERFORM MATCODE_CONFIRM.
     CHECK A_CHOICE = 'J'.
   ELSE.
     CLEAR G_NEW_CAP_RANGE.
   ENDIF.

   DO 26 TIMES.

     IT_ALPHA_NUM1-ALPHA = ALPHA+L_NUM1(1).
     L_NUM2 = L_NUM2 + 10.

     IF L_NUM2 < 100.
       CONCATENATE '0' L_NUM2 INTO L_NUM2.
     ENDIF.
     IT_ALPHA_NUM1-NUMBER = L_NUM2.
     L_NUM1 = L_NUM1 + 1.
     APPEND IT_ALPHA_NUM1.
   ENDDO.

   CASE ZMM_CDHD_ST-MTART.

     WHEN 'ZSTO'.

       DATA : L_MAT_LEN LIKE SY-INDEX.
       DATA : L_DESC(87) TYPE C.
       DATA : L_DESC1(40) TYPE C, L_DESC2(48) TYPE C.

       LOOP AT G_TABCTRL110_ITAB
              INTO G_TABCTRL110_WA.

         IF ( G_TABCTRL110_WA-MATCODE IS INITIAL
                 OR G_TABCTRL110_WA-MATCODE = '000000000' )
*
                 AND G_TABCTRL110_WA-COMP_FLG IS INITIAL
                 AND G_TABCTRL110_WA-REJ_FLG  IS INITIAL.

           L_DESC = G_TABCTRL110_WA-DESC_FIN.
           L_MAT_LEN = STRLEN( L_DESC ).

           IF L_MAT_LEN <= 40 .

             L_DESC1 = L_DESC.

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             CLEAR L_DESC2.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ELSE.

             L_DESC1 = L_DESC+0(39).
             IF L_DESC+38(1) = ' '.
               L_DESC1 = L_DESC+0(38).
               CONCATENATE L_DESC1 '*' INTO L_DESC1 SEPARATED BY SPACE.
               L_DESC2 = L_DESC+39(48).
             ELSE.
               CONCATENATE L_DESC1 '*' INTO L_DESC1.
               L_DESC2 = L_DESC+39(48).
             ENDIF.

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ENDIF.

           SELTAB-SELNAME = 'P_UOM'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABCTRL110_WA-UOM.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATKL'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABCTRL110_WA-MATGP.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MTART'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = ZMM_CDHD_ST-MTART.
           APPEND SELTAB TO IST_SELTAB.


           SELTAB-SELNAME = 'P_SRNO'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABCTRL110_WA-SRNO.
           APPEND SELTAB TO IST_SELTAB.


           SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
           RETURN.
           GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABCTRL110_WA-MATCODE.
           IF G_TABCTRL110_WA-MATCODE IS INITIAL
              OR G_TABCTRL110_WA-MATCODE = '000000000'.
             G_TABCTRL110_WA-COMP_FLG = 'E'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'E'.
             G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
           ELSE.
             MATGEN_FLAG = 'X'.
             G_TABCTRL110_WA-COMP_FLG = 'N'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'N'.
             G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
***********************************************************************
             DATA: L_SRNO LIKE ZMM_CDITEM-SRNO.
             CLEAR IST_TEXTID.
             MOVE G_TABCTRL110_WA-SRNO TO L_SRNO.
             CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
             INTO IST_TEXTID-TDNAME.

             IST_TEXTID-TDOBJECT   = 'ZMMCD'.
             IST_TEXTID-TDID       = 'CDDS'.
             IST_TEXTID-TDSPRAS    =  SY-LANGU.
             IST_TEXTID-TDLINESIZE =  72.
***Appending to internal table for all textid/name.
             APPEND IST_TEXTID TO IST_TEXTID_ITEMS.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

             PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.

             CLEAR : WA_TEXTID.

             WA_TEXTID-TDNAME   = G_TABCTRL110_WA-MATCODE.
             WA_TEXTID-TDID     = 'BEST'.
             WA_TEXTID-TDSPRAS  = 'E'.
             WA_TEXTID-TDOBJECT = 'MATERIAL'.

             PERFORM SAVE_TEXT.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

**********************************************************************

           ENDIF.
           MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA.
           CLEAR G_TABCTRL110_WA-COMP_FLG.

           CLEAR SELTAB.
           REFRESH IST_SELTAB.
         ENDIF.

*
         CLEAR : G_TABCTRL110_WA-COMP_FLG,
                 G_TABCTRL110_WA-RSN.
       ENDLOOP.

     WHEN 'ZSPR'.

       DATA : L_MPARTNO_LEN LIKE SY-INDEX.
       DATA : L_MPARTNO LIKE G_TABLCTRL120_WA-PARTNO.
       DATA : L_MPARTNO1(30) TYPE C.
       DATA : L_MPARTNO2(10) TYPE C.
       DATA : L_MFGNAME(30) TYPE C.

       LOOP AT G_TABLCTRL120_ITAB
                INTO G_TABLCTRL120_WA.

**  Added for group initialisation problems

         IF  G_TABLCTRL120_WA-MATGP IS INITIAL.

           G_TABLCTRL120_WA-COMP_FLG = 'E'.

           MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
                  INDEX SY-TABIX.
           CONTINUE.
         ENDIF.

         IF ( G_TABLCTRL120_WA-MATCODE IS INITIAL
                   OR G_TABLCTRL120_WA-MATCODE = '000000000' )
*
                   AND G_TABLCTRL120_WA-COMP_FLG IS INITIAL
                   AND G_TABLCTRL120_WA-REJ_FLG  IS INITIAL.

           L_MPARTNO = G_TABLCTRL120_WA-PARTNO.
           L_DESC = G_TABLCTRL120_WA-DESC_FIN.
           L_MPARTNO_LEN = STRLEN( L_MPARTNO ).
           L_MAT_LEN = STRLEN( L_DESC ).

           IF L_MAT_LEN <= 40 .

             L_DESC1 = L_DESC.

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             CLEAR L_DESC2.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ELSE.

             L_DESC1 = L_DESC+0(39).
             IF L_DESC+38(1) = ' '.
               L_DESC1 = L_DESC+0(38).
               CONCATENATE L_DESC1 '*' INTO L_DESC1 SEPARATED BY SPACE.
               L_DESC2 = L_DESC+39(48).
             ELSE.
               CONCATENATE L_DESC1 '*' INTO L_DESC1.
               L_DESC2 = L_DESC+39(48).
             ENDIF.

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ENDIF.

           SELTAB-SELNAME = 'P_UOM'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-UOM.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATKL'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-MATGP.
           APPEND SELTAB TO IST_SELTAB.

           SELECT SINGLE NAME1 FROM LFA1 INTO L_MFGNAME
                  WHERE LIFNR = G_TABLCTRL120_WA-MANU.

           SELTAB-SELNAME = 'P_MFGNME'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = L_MFGNAME.
           APPEND SELTAB TO IST_SELTAB.
*
           SELTAB-SELNAME = 'P_MFGCDE'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-MANU.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_CPCDE'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-CAP_CODE.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_CPCDED'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-CAP_NAME.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MDLCDE'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-MDLNO.
           APPEND SELTAB TO IST_SELTAB.


           IF L_MPARTNO_LEN <= 30.

             L_MPARTNO1 = L_MPARTNO.

             SELTAB-SELNAME = 'P_MPRTN1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_MPARTNO1.
             APPEND SELTAB TO IST_SELTAB.

             L_MPARTNO2 = ''.

           ELSE.

             L_MPARTNO1 = L_MPARTNO.

             SELTAB-SELNAME = 'P_MPRTN1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_MPARTNO1.
             APPEND SELTAB TO IST_SELTAB.

             L_MPARTNO2 = L_MPARTNO+30(10).

             SELTAB-SELNAME = 'P_MPRTN2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_MPARTNO2.
             APPEND SELTAB TO IST_SELTAB.

           ENDIF.

           SELTAB-SELNAME = 'P_MPRTN'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = L_MPARTNO.
           APPEND SELTAB TO IST_SELTAB.

*
           SELTAB-SELNAME = 'P_DESC'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-DESC_FIN.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MTART'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = ZMM_CDHD_ST-MTART.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_EQDESC'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-SUBASS.
           APPEND SELTAB TO IST_SELTAB.


           SELTAB-SELNAME = 'P_SRNO'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL120_WA-SRNO.
           APPEND SELTAB TO IST_SELTAB.

           SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
RETURN.
           GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABLCTRL120_WA-MATCODE.
           IF G_TABLCTRL120_WA-MATCODE IS INITIAL
              OR G_TABLCTRL120_WA-MATCODE = '000000000'.
             G_TABLCTRL120_WA-COMP_FLG = 'E'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'E'.
             G_TABLCTRL120_WA-RSN = WA_RSN-DESCRIPTION.
           ELSE.
             MATGEN_FLAG = 'X'.
             G_TABLCTRL120_WA-COMP_FLG = 'N'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'N'.
             G_TABLCTRL120_WA-RSN = WA_RSN-DESCRIPTION.
***********************************************************************
*
             CLEAR IST_TEXTID.
             MOVE G_TABLCTRL120_WA-SRNO TO L_SRNO.
             CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
             INTO IST_TEXTID-TDNAME.

             IST_TEXTID-TDOBJECT   = 'ZMMCD'.
             IST_TEXTID-TDID       = 'CDDS'.
             IST_TEXTID-TDSPRAS    =  SY-LANGU.
             IST_TEXTID-TDLINESIZE =  72.
***Appending to internal table for all textid/name.
             APPEND IST_TEXTID TO IST_TEXTID_ITEMS.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

             PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
             CLEAR : WA_TEXTID.

             WA_TEXTID-TDNAME   = G_TABLCTRL120_WA-MATCODE.
             WA_TEXTID-TDID     = 'BEST'.
             WA_TEXTID-TDSPRAS  = 'E'.
             WA_TEXTID-TDOBJECT = 'MATERIAL'.

             PERFORM SAVE_TEXT.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

**********************************************************************

           ENDIF.
           MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA.
           CLEAR G_TABLCTRL120_WA-COMP_FLG.

           CLEAR SELTAB.
           REFRESH IST_SELTAB.
         ENDIF.
         CLEAR : G_TABLCTRL120_WA-COMP_FLG,
         G_TABLCTRL120_WA-RSN.
       ENDLOOP.

     WHEN 'ZCAP'.

       DATA : L_MATCOST(15) TYPE C.

       LOOP AT G_TABLCTRL130_ITAB
                INTO G_TABLCTRL130_WA.

**  Added for group initialisation problems

         IF  G_TABLCTRL130_WA-SPA_GRP IS INITIAL.

           G_TABLCTRL130_WA-COMP_FLG = 'E'.

           MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
                  INDEX SY-TABIX.
           CONTINUE.
         ENDIF.

         IF ( G_TABLCTRL130_WA-MATCODE IS INITIAL
                   OR G_TABLCTRL130_WA-MATCODE = '000000000' )
*
                   AND G_TABLCTRL130_WA-COMP_FLG IS INITIAL
                   AND G_TABLCTRL130_WA-REJ_FLG  IS INITIAL.

           L_DESC = G_TABLCTRL130_WA-DESC_FIN.
           L_MAT_LEN = STRLEN( L_DESC ).

           IF L_MAT_LEN <= 40 .

             L_DESC1 = L_DESC.

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             CLEAR L_DESC2.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ELSE.

             L_DESC1 = L_DESC+0(39).
             CONCATENATE L_DESC1 '*' INTO L_DESC1.
             L_DESC2 = L_DESC+39(48).

             SELTAB-SELNAME = 'P_DESC1'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC1.
             APPEND SELTAB TO IST_SELTAB.

             SELTAB-SELNAME = 'P_DESC2'.
             SELTAB-SIGN    = 'I'.
             SELTAB-OPTION = 'EQ'.
             SELTAB-LOW   = L_DESC2.
             APPEND SELTAB TO IST_SELTAB.

             SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.

           ENDIF.

           SELTAB-SELNAME = 'P_UOM'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-UOM.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATKL'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = '0C'.
           APPEND SELTAB TO IST_SELTAB.


           L_MATCOST = G_TABLCTRL130_WA-MATCOST.

           SELTAB-SELNAME = 'P_MATCOS'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = L_MATCOST.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATCAT'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-MATCATG.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATLOC'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-MATLOC.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_WKLIFE'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-WRKNG_LIFE.

           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MATGP'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-SPA_GRP.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_DESC'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-DESC_FIN.
           APPEND SELTAB TO IST_SELTAB.

           SELTAB-SELNAME = 'P_MTART'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = ZMM_CDHD_ST-MTART.
           APPEND SELTAB TO IST_SELTAB.

           DATA : L_MATNR(8) TYPE C.
           DATA : RCODE_NUMBER_GET LIKE INRI-RETURNCODE.
           DATA : MATNR LIKE MARA-MATNR.
           DATA : L_NUMBER_RANGE LIKE IT_CAP_GROUP1-NUMBER_RANGE.

           SELECT * FROM ZMM_CAP_GROUP INTO TABLE IT_CAP_GROUP1
                  WHERE DESCRIPTION = G_TABLCTRL130_WA-MATCATG.

           IF SY-SUBRC = 0.
             SORT IT_CAP_GROUP1 BY NUMBER_RANGE DESCRIPTION ASCENDING.
             LOOP AT IT_CAP_GROUP1.
               IF IT_CAP_GROUP1-USED_FLAG = 'X'.
                 CONTINUE.
               ELSE.
                 EXIT.
               ENDIF.
             ENDLOOP.
           ENDIF.

           L_NUMBER_RANGE = IT_CAP_GROUP1-NUMBER_RANGE.

           DO.

             CALL FUNCTION 'NUMBER_GET_NEXT'
               EXPORTING
                 NR_RANGE_NR             = L_NUMBER_RANGE
                 OBJECT                  = 'ZMATERIALC'
               IMPORTING
                 NUMBER                  = L_MATNR
                 RETURNCODE              = RCODE_NUMBER_GET
               EXCEPTIONS
                 INTERVAL_NOT_FOUND      = 1
                 NUMBER_RANGE_NOT_INTERN = 2
                 OBJECT_NOT_FOUND        = 3
                 QUANTITY_IS_0           = 4
                 QUANTITY_IS_NOT_1       = 5
                 INTERVAL_OVERFLOW       = 6
                 BUFFER_OVERFLOW         = 7
                 OTHERS                  = 8.
             IF SY-SUBRC = 6.
               IT_CAP_GROUP1-USED_FLAG = 'X'.
               MODIFY IT_CAP_GROUP1 INDEX SY-INDEX.
               MODIFY ZMM_CAP_GROUP FROM TABLE IT_CAP_GROUP1.
               G_NEW_CAP_RANGE = 'X'.
               EXIT.
             ENDIF.

             DATA : L_ALPHAA TYPE C.
             DATA : L_CHAR2(2) TYPE C.
             DATA : L_CHAR3(3) TYPE C.

             L_CHAR3 = L_MATNR+2(3).

             READ TABLE IT_ALPHA_NUM1 WITH KEY NUMBER = L_CHAR3.
             L_ALPHAA = IT_ALPHA_NUM1-ALPHA.

             L_CHAR2 = L_MATNR+2(2).

             IF L_CHAR2 EQ '00'.

               CONCATENATE '0C' L_MATNR+4(4) '000' INTO MATNR.

             ELSE.

               CONCATENATE '0C' L_ALPHAA L_MATNR+5(3) '000' INTO MATNR.

             ENDIF.

             CALL FUNCTION 'MARA_SINGLE_READ'
               EXPORTING
                 MATNR      = MATNR
                 SPERRMODUS = ' '
               IMPORTING
                 WMARA      = MARA
               EXCEPTIONS
                 NOT_FOUND  = 4
                 OTHERS     = 5.

             IF SY-SUBRC EQ 0.
               CONTINUE.
             ELSE.
               EXIT.
             ENDIF.

           ENDDO.

           IF G_NEW_CAP_RANGE  = 'X'.
             PERFORM CREATE_MATCODE.
           ENDIF.

           SELTAB-SELNAME = 'P_MATNR'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = MATNR.
           APPEND SELTAB TO IST_SELTAB.



           SELTAB-SELNAME = 'P_SRNO'.
           SELTAB-SIGN    = 'I'.
           SELTAB-OPTION = 'EQ'.
           SELTAB-LOW   = G_TABLCTRL130_WA-SRNO.
           APPEND SELTAB TO IST_SELTAB.


           SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
RETURN.

           GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABLCTRL130_WA-MATCODE
           .
           IF G_TABLCTRL130_WA-MATCODE IS INITIAL
              OR G_TABLCTRL130_WA-MATCODE = '000000000'.
             G_TABLCTRL130_WA-COMP_FLG = 'E'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'E'.
             G_TABLCTRL130_WA-RSN = WA_RSN-DESCRIPTION.
           ELSE.
             MATGEN_FLAG = 'X'.
             G_TABLCTRL130_WA-COMP_FLG = 'N'.
             SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
             WHERE REASON = 'N'.
             G_TABLCTRL130_WA-RSN = WA_RSN-DESCRIPTION.
***********************************************************************
             CLEAR IST_TEXTID.
             MOVE G_TABLCTRL130_WA-SRNO TO L_SRNO.
             CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
             INTO IST_TEXTID-TDNAME.

             IST_TEXTID-TDOBJECT   = 'ZMMCD'.
             IST_TEXTID-TDID       = 'CDDS'.
             IST_TEXTID-TDSPRAS    =  SY-LANGU.
             IST_TEXTID-TDLINESIZE =  72.
***Appending to internal table for all textid/name.
             APPEND IST_TEXTID TO IST_TEXTID_ITEMS.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

             PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
             CLEAR : WA_TEXTID.

             WA_TEXTID-TDNAME   = G_TABLCTRL130_WA-MATCODE.
             WA_TEXTID-TDID     = 'BEST'.
             WA_TEXTID-TDSPRAS  = 'E'.
             WA_TEXTID-TDOBJECT = 'MATERIAL'.

             PERFORM SAVE_TEXT.

             CLEAR   : IST_DTSPECS.
             REFRESH : IST_DTSPECS.

**********************************************************************

           ENDIF.
           MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA.
           CLEAR G_TABLCTRL130_WA-COMP_FLG.

           CLEAR SELTAB.
           REFRESH IST_SELTAB.
         ENDIF.
         CLEAR : G_TABLCTRL130_WA-COMP_FLG,
         G_TABLCTRL130_WA-RSN.
       ENDLOOP.

   ENDCASE.

   PERFORM SAVE_REQUEST.

 ENDFORM.                    " Create_matcode
*&---------------------------------------------------------------------*
*&      Form  update_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UPDATE_RELEASE.
   UPDATE ZMM_CDHD SET STATUS_FLAG = 'X'
   WHERE REQNO = ZMM_CDHD_ST-REQNO.
   PERFORM UPDATE_NOOFHITS.
   PERFORM SAVE_CORS_TEXT.
   MESSAGE I019(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.

 ENDFORM.                    " update_approval
*&---------------------------------------------------------------------*
*&      Form  Insert_modif
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM INSERT_MODIF.
   DATA L_TAB_INDEX LIKE SY-TABIX.
   CLEAR ZMM_MODIFIER.
   READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY FLAG = 'X'.
   IF SY-SUBRC = 0.
     PERFORM GET_PARNO.     "+
     CASE G_PARNO.
       WHEN '4'.
         IF G_TABCTRL110_WA-DESC4 IS INITIAL.
           MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
                                      G_PARNO.
           CHECK 1 = 2.
         ENDIF.
       WHEN '3'.
         IF G_TABCTRL110_WA-DESC3 IS INITIAL .
           MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
                                      G_PARNO.
           CHECK 1 = 2.
         ELSEIF G_TABCTRL110_WA-DESC4 <> ''.
           MESSAGE I070(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
                                      G_PARNO.

           CHECK 1 = 2.
         ENDIF.
       WHEN '2'.
         IF G_TABCTRL110_WA-DESC2 IS INITIAL.
           MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
                                      G_PARNO.
           CHECK 1 = 2.
         ELSEIF G_TABCTRL110_WA-DESC3 <> ''.
           MESSAGE I070(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
                                      G_PARNO.
           CHECK 1 = 2.
         ENDIF.
*
*       when '1'.
*         if g_tabctrl110_wa-desc4 is initial.
*           message i069(zmm_oth) with g_tabctrl110_wa-desc1.
*           check 1 = 2.
*         Endif.
     ENDCASE.

     IF ( G_TABCTRL110_WA-OTH1 = 'X' OR
          G_TABCTRL110_WA-OTH2 = 'X' OR
          G_TABCTRL110_WA-OTH3 = 'X' OR
          G_TABCTRL110_WA-OTH4 = 'X' ) AND
          G_TABCTRL110_WA-COMP_FLG+0(1) <> 'S'.

       MOVE: G_TABCTRL110_WA-MATGP TO ZMM_MODIFIER-MATGRP,
             G_TABCTRL110_WA-DESC1 TO ZMM_MODIFIER-DESC1,
             G_TABCTRL110_WA-DESC2 TO ZMM_MODIFIER-DESC2,
             G_TABCTRL110_WA-DESC3 TO ZMM_MODIFIER-DESC3,
             G_TABCTRL110_WA-DESC4 TO ZMM_MODIFIER-DESC4,
             SY-UNAME              TO ZMM_MODIFIER-CREATED_BY,
             SY-DATUM              TO ZMM_MODIFIER-CREATE_DATE.
       L_TAB_INDEX = SY-TABIX.
       CALL SCREEN 103 STARTING AT 40 2 ENDING AT 80 8.
       IF SY-UCOMM = 'AGREE'.
         INSERT INTO ZMM_MODIFIER VALUES ZMM_MODIFIER.
         REPLACE 'M' WITH '' INTO G_TABCTRL110_WA-COMP_FLG .
         MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX L_TAB_INDEX
          TRANSPORTING COMP_FLG FLAG.
         CLEAR SY-UCOMM.
       ELSE.
         MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX L_TAB_INDEX
          TRANSPORTING FLAG.
         CLEAR SY-UCOMM.
       ENDIF.
     ELSE.
       MESSAGE I035(ZMM_OTH).
     ENDIF.
   ELSE.
     MESSAGE I040(ZMM_OTH).
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
 FORM RESET_OTHER.
   IF G_OK_CODE115 <> 'CANC'.
     CASE 'OTHER'.
       WHEN G_TABCTRL110_WA-DESC1.
         CLEAR : G_TABCTRL110_WA-DESC1,
                 G_TABCTRL110_WA-OTH1,
                 G_TABCTRL110_WA-MATGP.

       WHEN G_TABCTRL110_WA-DESC2.
         CLEAR: G_TABCTRL110_WA-DESC2,
                G_TABCTRL110_WA-OTH2.

       WHEN G_TABCTRL110_WA-DESC3.
         CLEAR: G_TABCTRL110_WA-DESC3,
                G_TABCTRL110_WA-OTH3.

       WHEN G_TABCTRL110_WA-DESC4.
         CLEAR: G_TABCTRL110_WA-DESC4,
                G_TABCTRL110_WA-OTH2 .
     ENDCASE.
*
   ELSE.
     CASE 'OTHER'.
       WHEN G_TABCTRL110_WA-DESC1.
         CLEAR : G_TABCTRL110_WA-DESC1,
                 G_TABCTRL110_WA-OTH1.
       WHEN G_TABCTRL110_WA-DESC2.
         CLEAR: G_TABCTRL110_WA-DESC2,
                G_TABCTRL110_WA-OTH2.

       WHEN G_TABCTRL110_WA-DESC3.
         CLEAR: G_TABCTRL110_WA-DESC3,
                G_TABCTRL110_WA-OTH3.

       WHEN G_TABCTRL110_WA-DESC4.
         CLEAR: G_TABCTRL110_WA-DESC4,
                G_TABCTRL110_WA-OTH2 .
     ENDCASE.
*
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
 FORM OTHER_CHECK.
   IF SY-UCOMM <> 'CANC' . "X in toolbar of modal screen
     CASE 'X'.
       WHEN G_TABCTRL110_WA-OTH1.
         IF G_DESC1 = '' OR
            G_DESC2 = ''.
           MESSAGE E007(ZMM_OTH) WITH 'DESC1' 'DESC2'.
*
         ENDIF.
         IF G_DESC4 <> ''.
           IF G_DESC3 = ''.
             MESSAGE E007(ZMM_OTH).
           ENDIF.
         ENDIF.

       WHEN G_TABCTRL110_WA-OTH2.
         IF G_DESC2 IS INITIAL.
           MESSAGE E007(ZMM_OTH) WITH 'DESC2'.
         ENDIF.
         IF G_DESC4 <> ''.
           IF G_DESC3 = ''.
             MESSAGE E007(ZMM_OTH).
           ENDIF.
         ENDIF.
       WHEN G_TABCTRL110_WA-OTH3.
         IF G_DESC3 IS INITIAL.
           MESSAGE E007(ZMM_OTH) WITH 'DESC3'.
         ENDIF.
       WHEN G_TABCTRL110_WA-OTH4.
         IF G_DESC4 IS INITIAL.
           MESSAGE E007(ZMM_OTH) WITH 'DESC4'.
         ENDIF.
     ENDCASE.
   ENDIF.


 ENDFORM.                    " other_check
*****************************************************
 FORM FIND_USER.
*****************************************************
   DATA : G_TTA_AUTH.
   DATA : G_MRP_AUTH.

   CLEAR : G_TTA_AUTH, G_MRP_AUTH.

   IF SY-TCODE = 'ZCODG'.
     G_USER = 'X'.  "Codifier.
   ELSE.
* MRP CONTROLLER AUTH CHECK.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'L1'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'L2'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'HS'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'HO'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'HL'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'HC'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1A'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1B'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1C'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.

     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1D'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1E'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : '1F'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'DI'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'DF'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'CI'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'CS'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'BO'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'MD'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD : 'EC'.
     IF SY-SUBRC = 0.
       G_TTA_AUTH = 'X'.
     ENDIF.

     IF G_TTA_AUTH = 'X'.
       G_USER = 'L'.         "TAA
       AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD '02'
                        ID 'FRGGR' FIELD 'IM'.
       IF SY-SUBRC = 0.
         G_USER = 'Z'.  "MRP CONTROLLER+TAA
       ENDIF.
* ------- Find if user is MRP Controller
     ELSE.
       AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                        ID 'FRGCO' FIELD '02'
                        ID 'FRGGR' FIELD 'IM'.
       IF SY-SUBRC = 0.
         G_USER = 'M'.  "MRP CONTROLLER
       ELSE.
         G_USER = ''.
       ENDIF.
     ENDIF.
   ENDIF.
*
   G_USER_FOUND = 'X'.
*
 ENDFORM.                    " find_user
*********************************************************************
 FORM CHECK_MODI.
* Check for existing modifiers
   SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1.
   IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC1 = 'OTHER' OR
                         G_TABCTRL110_WA-OTH1 = 'X' ) .
     LOOP AT SCREEN.
       SCREEN-INPUT = 0.
       MODIFY SCREEN.
     ENDLOOP.
     G_MODI_EXISTS = 'X'.
     MESSAGE E010(ZMM_OTH)  .
   ELSE.
     SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND DESC2 =
                 G_DESC2.
     IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC2 = 'OTHER'  OR
                          G_TABCTRL110_WA-OTH2 = 'X' ) .

       LOOP AT SCREEN.
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ENDLOOP.

       MESSAGE E010(ZMM_OTH) .
     ELSE.
       SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND DESC2 =
                                               G_DESC2 AND DESC3 = G_DESC3.
       IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC3 = 'OTHER' OR
                             G_TABCTRL110_WA-OTH3 = 'X' ) .

         LOOP AT SCREEN.
           SCREEN-INPUT = 0.
           MODIFY SCREEN.
         ENDLOOP.
         MESSAGE E010(ZMM_OTH)  .
       ELSE.
         SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND
         DESC2 = G_DESC2 AND DESC3 = G_DESC3 AND DESC4 = G_DESC4.
         IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC4 = 'OTHER'  OR
                               G_TABCTRL110_WA-OTH4 = 'X' ) .

           LOOP AT SCREEN.
             SCREEN-INPUT = 0.
             MODIFY SCREEN.
           ENDLOOP.
           MESSAGE E010(ZMM_OTH)  .
         ENDIF.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    "check_modi
*&---------------------------------------------------------------------*
*&      Form  Spell_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SPELL_CHECK.
   DATA : L_ANS.
*
   IF NOT IST_SPELL_LINE[] IS INITIAL.
     EXPORT G_USER TO MEMORY ID 'G_USER1' .
     EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.

     CALL FUNCTION 'ZSPELL_CHECK'
       EXPORTING
         SPRACHE = 'EN'
       TABLES
         ILINE   = IST_SPELL_LINE.
     IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB'ACCEPTING TRUNCATION.
     IF NOT CHECKTAB[] IS INITIAL.

       MESSAGE I017(ZMM_OTH).
       PERFORM SPELL_ERROR_LINES.
     ELSE.
       MESSAGE I008(ZMM_OTH).
       LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
         IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
           REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
           G_TABCTRL110_WA-RSN      = ''.
           MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
             TRANSPORTING COMP_FLG RSN.
         ENDIF.
       ENDLOOP.


     ENDIF.

     IF G_USER = ' '.
       IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
       IF NOT CHECKTAB[] IS INITIAL.
         " Begin of <RD1K960036>.
*         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*            EXPORTING
**
*    TEXTLINE1 = 'There are spelling errors in description(s)'
*           TEXTLINE2            = 'Proceed with errors? '
*            TITEL                = 'Spelling Errors'
**
*           IMPORTING
*              ANSWER               = l_ans.
         DATA : L_GET9(1) TYPE C.
         CALL FUNCTION 'POPUP_TO_CONFIRM'
           EXPORTING
            TITLEBAR                    = 'Spelling Errors '
*            DIAGNOSE_OBJECT             = ' '
             TEXT_QUESTION               = 'There are spelling errors in description(s) Proceed with errors?'
*            TEXT_BUTTON_1               = 'Ja'(001)
*            ICON_BUTTON_1               = ' '
*            TEXT_BUTTON_2               = 'Nein'(002)
*            ICON_BUTTON_2               = ' '
*            DEFAULT_BUTTON              = '1'
*            DISPLAY_CANCEL_BUTTON       = 'X'
*            USERDEFINED_F1_HELP         = ' '
            START_COLUMN                = 25
            START_ROW                   = 6
*            POPUP_TYPE                  =
*            IV_QUICKINFO_BUTTON_1       = ' '
*            IV_QUICKINFO_BUTTON_2       = ' '
          IMPORTING
            ANSWER                      = L_GET9
*          TABLES
*            PARAMETER                   =
          EXCEPTIONS
            TEXT_NOT_FOUND              = 1
            OTHERS                      = 2
                   .
         IF SY-SUBRC = 0.
           CASE L_GET9.
             WHEN '1'.
               MOVE 'J' TO L_ANS.
             WHEN '2'.
               MOVE 'N' TO L_ANS.
           ENDCASE.
         ENDIF.
         " End of <RD1K960036>.
         IF L_ANS = 'J'.
           PERFORM SPELL_ERROR_LINES.
           CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
           G_OTHER = 'X'.
           G_SPELLERROR = ''.
*
           G_MODI_EXISTS = ''.
           LEAVE TO SCREEN 0.
         ELSE.
           LOOP AT SCREEN.
*
           ENDLOOP.
         ENDIF.
       ELSE.
         CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
         G_OTHER = 'X'.
         G_SPELLERROR = ''.
         G_MODI_EXISTS = ''.
*
         LEAVE TO SCREEN 0.
       ENDIF.
     ENDIF.
   ELSE.
     MESSAGE I008(ZMM_OTH).
     LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
       IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
         G_TABCTRL110_WA-RSN      = ''.
         MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
           TRANSPORTING COMP_FLG RSN.
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
 FORM SPELL_CHECK1.
*
   DATA : OK_CODE110 LIKE SY-UCOMM.
*
   OK_CODE110 = SY-UCOMM.
   CLEAR SY-UCOMM.
   CLEAR IST_SPELL_LINE.
   REFRESH IST_SPELL_LINE.
*
   IF OK_CODE110 = 'SPELL' OR
      CHECK_CODE = 'CHECK'.
     READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY
     FLAG = 'X' .
     IF SY-SUBRC = 0.
       G_CURR_LINE1 = SY-TABIX.
       IF  G_TABCTRL110_WA-OTH1  = 'X'.

         CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
         G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
         BY SPACE.

       ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
         CONCATENATE G_TABCTRL110_WA-DESC2
         G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
         BY SPACE.

       ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
         CONCATENATE G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
         BY SPACE.


       ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
         CONCATENATE G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
         BY SPACE.

       ELSE.
         IST_SPELL_LINE-TDLINE = G_TABCTRL110_WA-USER_DESC.
       ENDIF.

       APPEND IST_SPELL_LINE.
       PERFORM SPELL_CHECK.
       CLEAR:SY-UCOMM,OK_CODE110.
     ELSE.
       LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
         CASE 'X'.
           WHEN G_TABCTRL110_WA-OTH1.
             CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
             G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
             BY SPACE.
             IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
             APPEND IST_SPELL_LINE.
             CONTINUE.
           WHEN G_TABCTRL110_WA-OTH2.
             CONCATENATE G_TABCTRL110_WA-DESC2
             G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
             BY SPACE.
             IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
             APPEND IST_SPELL_LINE.
             CONTINUE.

           WHEN G_TABCTRL110_WA-OTH3.
             CONCATENATE G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
             BY SPACE.
             IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
             APPEND IST_SPELL_LINE.
             CONTINUE.

           WHEN G_TABCTRL110_WA-OTH4.
             CONCATENATE G_TABCTRL110_WA-DESC4
         G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
             BY SPACE.
             IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
             APPEND IST_SPELL_LINE.
             CONTINUE.

           WHEN OTHERS.
             IF NOT G_TABCTRL110_WA-USER_DESC IS INITIAL.
               IST_SPELL_LINE-TDLINE = G_TABCTRL110_WA-USER_DESC .
               IST_SPELL_LINE-SRNO   = G_TABCTRL110_WA-SRNO.
               APPEND IST_SPELL_LINE.
             ENDIF.
             CONTINUE.
         ENDCASE.
       ENDLOOP.
       CLEAR:SY-UCOMM,OK_CODE110.

*     Export ist_spell_line to memory id 'SPELL'.
       IST_SPELL_LINE1[] = IST_SPELL_LINE[].
       PERFORM SPELL_CHECK.
*      .
     ENDIF.
   ELSE.

   ENDIF.

 ENDFORM.                    "spell_check1
*ENDMODULE.                 " spell_check1  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_Other  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHANGE_OTHER INPUT.
   IF SY-UCOMM = 'DBCLICK' AND G_MODE = 'CHA'.
*   Read table tabctrl110_itab index g_currline.
   ENDIF.
 ENDMODULE.                 " change_Other  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_user  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE GET_USER OUTPUT.
   DATA: L_REQNO LIKE ZMM_CDHD-REQNO.

   IF SY-TCODE = 'ZCODG'.
     GET PARAMETER ID 'ZREQNO' FIELD L_REQNO.
     SELECT SINGLE * FROM ZMM_CDHD
           WHERE REQNO = L_REQNO.
     IF SY-UNAME <> 'CODIFICATION' AND
        ZMM_CDHD-REQCL = 'IR'.
       G_MODE = 'DIS'.
     ELSEIF SY-UNAME <> 'CODIFICATION' AND
        ZMM_CDHD-REQCL <> 'IR' .
       G_MODE = 'COD'.
     ELSEIF SY-UNAME = 'CODIFICATION'.
       G_MODE = 'COD'.
     ENDIF.
   ENDIF.

   IF G_USER_FOUND = ''.
     PERFORM FIND_USER.
   ENDIF.
   IF  ZMM_CDHD_ST-REQNO <> ''.
     IF G_MODE = 'APR'.
       IF G_USER = 'M' OR
          G_USER = 'L'.
*       do nothing.
       ELSE.
*        message e057(zmm_oth).  << GC100805>>
       ENDIF.
     ENDIF.
   ENDIF.
*
   IF SY-TCODE = 'ZCODG'.
     GET PARAMETER ID 'ZREQNO' FIELD ZMM_CDHD_ST-REQNO.
     IF IST_ALPHANUM IS INITIAL.
       PERFORM ALPHANUM.
     ENDIF.
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
 FORM CHANGE_REL.
   DATA : L_ANS.
   IF ZMM_CDHD_ST-STATUS_FLAG = 'X' AND G_MODE = 'CHA'.
     " Begin of <RD1k960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*        DEFAULTOPTION        = 'N'
*         TEXTLINE1            = 'Release will be reset. Proceed ?'
**         TEXTLINE2            = ' '
*         TITEL                = 'Release Reset'
**
*    IMPORTING
*        ANSWER               = l_ans.

     DATA : L_GET10(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR       = 'Release Reset'
         TEXT_QUESTION  = 'Release will be reset. Proceed ?'
         DEFAULT_BUTTON = '2'
         START_COLUMN   = 25
         START_ROW      = 6
       IMPORTING
         ANSWER         = L_GET10
       EXCEPTIONS
         TEXT_NOT_FOUND = 1
         OTHERS         = 2.
     IF SY-SUBRC = 0.
       CASE L_GET10.
         WHEN '1'.
           MOVE 'J' TO L_ANS.
         WHEN '2'.
           MOVE 'N' TO L_ANS.
       ENDCASE.
     ENDIF.
     " End of <RD1k960036>.

     IF L_ANS = 'J'.
       ZMM_CDHD_ST-STATUS_FLAG = ''.
       ZMM_CDHD_ST-APPROVE_MRP = ''.
       ZMM_CDHD_ST-APPROVE_L2 = ''.
     ELSE.
       PERFORM CLEAR_VAR.
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
 FORM CHANGE_RESTRICT1.
   DATA : L_ANS.
   IF SY-UNAME <> ZMM_CDHD_ST-REQCPF AND G_USER = ''.
     CASE G_MODE.
       WHEN 'CHA' OR 'REL'.
         MESSAGE I020(ZMM_OTH).
         PERFORM CLEAR_VAR.
         LEAVE TO SCREEN 100.
     ENDCASE.
   ENDIF.
*
   IF ZMM_CDHD_ST-STATUS_FLAG = 'X' AND G_MODE = 'CHA'..
     " Begin of <RD1K960036>.

*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*       EXPORTING
*        DEFAULTOPTION        = 'N'
*         TEXTLINE1            = 'Release will be reset. Proceed ?'
**         TEXTLINE2            = ' '
*         TITEL                = 'Release Reset'
**
*    IMPORTING
*        ANSWER               = l_ans.

     DATA : L_GET11(1) TYPE C.

     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TEXT_QUESTION  = 'Release will be reset. Proceed ?'
         DEFAULT_BUTTON = '2'
         START_COLUMN   = 25
         START_ROW      = 6
       IMPORTING
         ANSWER         = L_GET11
       EXCEPTIONS
         TEXT_NOT_FOUND = 1
         OTHERS         = 2.

     IF SY-SUBRC = 0.
       CASE L_GET11.
         WHEN '1'.
           MOVE 'J' TO L_ANS.
         WHEN '2'.
           MOVE 'N' TO L_ANS.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.

     IF L_ANS = 'J'.
       ZMM_CDHD_ST-STATUS_FLAG = ''.
       ZMM_CDHD_ST-APPROVE_MRP = ''.
       ZMM_CDHD_ST-APPROVE_L2 = ''.
     ELSE.
       PERFORM CLEAR_VAR.
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
 FORM UPDATE_APPROVAL.
   DATA : L_110ITAB TYPE T_TABCTRL110.
   CASE G_USER.
     WHEN 'M'.
       IF ZMM_CDHD_ST-APPROVE_MRP <> ''.
         UPDATE ZMM_CDHD SET APPROVE_MRP = 'X'
                             APPDATE     = SY-DATUM
                             APPCPF      = SY-UNAME
                             WHERE REQNO = ZMM_CDHD_ST-REQNO.
**To check, if the mail has to be send after Tech Auth Approval.
         IF ZMM_CDHD_ST-MTART = 'ZSTO'.
           READ TABLE G_TABCTRL110_ITAB INTO L_110ITAB
                WITH KEY OTH1 = 'X'.
           IF SY-SUBRC <> 0.
             PERFORM SEND_MAIL_TO_CDCELL.
             IF ZMM_CDHD_ST-REQCL <> 'N'.
               MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
               UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
                            WHERE REQNO = ZMM_CDHD_ST-REQNO.
             ENDIF.
           ENDIF.
         ELSE.
           PERFORM SEND_MAIL_TO_CDCELL.
           IF ZMM_CDHD_ST-REQCL <> 'N'.
             MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
             UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
                          WHERE REQNO = ZMM_CDHD_ST-REQNO.
           ENDIF.
         ENDIF.
*
         PERFORM PREPARE_UPDATE.
         MESSAGE I022(ZMM_OTH).
       ELSE.
         MESSAGE I024(ZMM_OTH) WITH 'MRP APPROVAL'.
       ENDIF.
     WHEN 'L'.
       IF ZMM_CDHD_ST-APPROVE_L2 <> ''.
         UPDATE ZMM_CDHD SET APPROVE_L2 = 'X'
                             APPDATE    = SY-DATUM
                             APPCPF     = SY-UNAME
         WHERE REQNO = ZMM_CDHD_ST-REQNO.
*
         PERFORM SEND_MAIL_TO_CDCELL.
         IF ZMM_CDHD_ST-REQCL <> 'N'.
           MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
           UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
                          WHERE REQNO = ZMM_CDHD_ST-REQNO.
         ENDIF.

*
         PERFORM PREPARE_UPDATE.
         MESSAGE I023(ZMM_OTH).
       ELSE.
         MESSAGE I024(ZMM_OTH) WITH 'L2 APPROVAL'.
       ENDIF.
   ENDCASE.
   PERFORM CLEAR_VAR.

 ENDFORM.                    " update_approval

*&---------------------------------------------------------------------*
*&      Form  move_descriptions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MOVE_DESCRIPTIONS.

   DESCP1 = G_TABCTRL110_WA-DESC1.
   DESCP2 = G_TABCTRL110_WA-DESC2.
   DESCP3 = G_TABCTRL110_WA-DESC3.
   DESCP4 = G_TABCTRL110_WA-DESC4.

 ENDFORM.                    " move_descriptions
*&---------------------------------------------------------------------*
*&      Form  REL_APR_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM REL_APR_STATUS.
   IF ZMM_CDHD_ST-STATUS_FLAG IS INITIAL. "Req not released
     MESSAGE I026(ZMM_OTH).
     PERFORM CLEAR_VAR.
     LEAVE TO SCREEN 100.
   ENDIF.

   IF G_USER = 'L' AND ZMM_CDHD_ST-APPROVE_MRP = ''.
     MESSAGE I027(ZMM_OTH) WITH 'MRP CONTROLLER'.
     PERFORM CLEAR_VAR.
     LEAVE TO SCREEN 100.
   ENDIF.

 ENDFORM.                    " REL_APR_STATUS
**********************************************************
 FORM POPUP_USERDESC.
   DATA L_ANS.
   IF G_TABCTRL110_WA-DESC1 = 'OTHER' AND SY-TCODE <> 'ZCODG'.
     " Begin of <RD1K960036>.
*     CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
*          EXPORTING
*           DEFAULTOPTION        = 'N'
*      DIAGNOSETEXT1        = 'Use of "OTHER" in Main Material Attribute  will  change the release'
*           DIAGNOSETEXT2        = 'strategy to: '
*           DIAGNOSETEXT3        =  '(1) Creator (2) MRP controller (3) Tech.Appr.Authority(L2 or above)'
*      TEXTLINE1            = 'The request will be posted to Codification  cell only after'
*           TEXTLINE2            =
*           'approval of  TECH.APPR.AUTHORITY(L2 or above)   Continue? '
*           TITEL                = 'Approval'
**                        START_COLUMN         = 25
**                        START_ROW            = 6
*          CANCEL_DISPLAY       = ''
*           IMPORTING
*              ANSWER               = l_ans

     DATA : L_GET1(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'Approva '
        DIAGNOSE_OBJECT             = 'ZHR1'
         TEXT_QUESTION               = 'The request will be posted to Codification  cell only after'
                                       &' approval of TECH.APPR.AUTHORITY(L2 or above)   Continue?.'
        DEFAULT_BUTTON              = '2'
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
           MOVE 'J' TO L_ANS.
         WHEN '2'.
           MOVE 'N' TO L_ANS.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.
     .
     IF L_ANS = 'J'.
       CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
     ELSE.
       G_TABCTRL110_WA-DESC1 = ''.
       G_TABCTRL110_WA-OTH1 = ''.

     ENDIF.
   ELSE.
     IF G_OK_CODE110 = 'PB_AD'.
       CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
                   G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
                   INTO G_DESC1_4 SEPARATED BY SPACE.
       CONDENSE G_DESC1_4.
       USER_DESC_LEN = STRLEN( G_DESC1_4 ).
       IF USER_DESC_LEN >= 86.
         MESSAGE I076(ZMM_OTH).
       ELSE.
         CLEAR USER_DESC_LEN.
         CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
       ENDIF.
     ELSE.     " OTHER at subattrib 1/2/3
       CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
     ENDIF.
   ENDIF.
 ENDFORM.                    " popup_userdesc

**********************************************************
 FORM CHECK_OTHER.
*
   LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
     IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR
        G_TABCTRL110_WA-DESC2 = 'OTHER' OR
        G_TABCTRL110_WA-DESC3 = 'OTHER' OR
        G_TABCTRL110_WA-DESC4 = 'OTHER'.
       MESSAGE I029(ZMM_OTH).
       LEAVE TO SCREEN 100.
     ENDIF.
   ENDLOOP.
*
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
 FORM SPELL_ERROR_LINES.
   DATA :Z TYPE I, CT_IDX TYPE I.
   DATA : L_STATUS(2).
*
   TYPES: BEGIN OF ITAB_TYPE,
           WORD(60),
           SRNO(3),
         END   OF ITAB_TYPE.

   DATA: BEGIN OF CHECKTAB1 OCCURS 0,
          BEGRIFF(60),
          SRNO(3) TYPE N,
         END OF CHECKTAB1.

   DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
   DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.

   IF CHECKTAB[] IS INITIAL.
     LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
       IF G_TABCTRL110_WA-COMP_FLG = 'S'.
         REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
         G_TABCTRL110_WA-RSN      = ''.
         MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX Z
            TRANSPORTING COMP_FLG RSN.
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT CHECKTAB[] IS INITIAL.
*
   CHECKTAB1[] = CHECKTAB[].
   LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
     Z = SY-TABIX.
     SPLIT  G_TABCTRL110_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
     LOOP AT ITAB.
       MOVE Z TO ITAB-SRNO.
       MODIFY ITAB INDEX SY-TABIX.
     ENDLOOP.
     APPEND LINES OF ITAB TO ITAB1.
     CLEAR Z.
   ENDLOOP.
*
   CLEAR Z.
   LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
     IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
       CONCATENATE '' G_TABCTRL110_WA-COMP_FLG+1(1) INTO
              G_TABCTRL110_WA-COMP_FLG.
       G_TABCTRL110_WA-RSN      = ''.

       MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
               TRANSPORTING COMP_FLG RSN.
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT CHECKTAB1.
     CT_IDX = SY-TABIX.
     READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
     IF SY-SUBRC = 0.
       CHECKTAB1-SRNO = ITAB1-SRNO.
       MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
       IF G_TABCTRL110_WA-COMP_FLG+1(1) = ''.
         G_TABCTRL110_WA-COMP_FLG = 'S'.
         G_TABCTRL110_WA-RSN      = 'Spelling Mistake'.
       ELSE.
         CONCATENATE 'S' G_TABCTRL110_WA-COMP_FLG+1(1) INTO L_STATUS.
         G_TABCTRL110_WA-COMP_FLG = L_STATUS.
       ENDIF.
       Z = ITAB1-SRNO.
       MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX Z
            TRANSPORTING COMP_FLG RSN.
     ENDIF.
   ENDLOOP.
*
   CLEAR SY-UCOMM.
 ENDFORM.                    " SPELL_ERROR_LINES
*&---------------------------------------------------------------------*
*&      Form  modi_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM MODI_CHECK.
   DATA : L_STATUS(2).
   LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
     IF G_TABCTRL110_WA-OTH1 = 'X' OR
        G_TABCTRL110_WA-OTH2 = 'X' OR
        G_TABCTRL110_WA-OTH3 = 'X' OR
        G_TABCTRL110_WA-OTH4 = 'X' .

       SELECT SINGLE * FROM ZMM_MODIFIER WHERE
          DESC1 = G_TABCTRL110_WA-DESC1 AND
          DESC2 = G_TABCTRL110_WA-DESC2 AND
          DESC3 = G_TABCTRL110_WA-DESC3 AND
          DESC4 = G_TABCTRL110_WA-DESC4.
       IF SY-SUBRC <> 0.
         IF G_TABCTRL110_WA-COMP_FLG+1(1) = 'M'.
           CONTINUE.
         ELSE.
           IF G_TABCTRL110_WA-COMP_FLG+0(1) <> 'M'.
             CONCATENATE G_TABCTRL110_WA-COMP_FLG 'M' INTO
             G_TABCTRL110_WA-COMP_FLG.
             MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
                                        TRANSPORTING COMP_FLG.
           ENDIF.
         ENDIF.
       ELSE.
*
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
 FORM SELECT_MATERIAL_DETAILS1.

   CLEAR DO_NOT_CHANGE_FLAG.

   IF G_MODE = 'CRE' OR G_MODE = 'CHA'.

     IF CHECK_POS = 0.
       DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
     ENDIF.
*
     CLEAR G_HITS_PAR.

   ENDIF.

   LOOP AT IST_SRCHLP INTO WA_SRCHLP.

     DATA : L_MATNR LIKE THEAD-TDNAME.
     L_MATNR = WA_SRCHLP-MATNR.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         CLIENT                  = SY-MANDT
         ID                      = 'BEST'
         LANGUAGE                = 'E'
         NAME                    = L_MATNR
         OBJECT                  = 'MATERIAL'
       TABLES
         LINES                   = LINES
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       WA_SRCHLP-MARK = '1'.
       MODIFY IST_SRCHLP FROM WA_SRCHLP.
     ENDIF.

   ENDLOOP.


 ENDFORM.                    " SELECT_MATERIAL_DETAILS1
*&---------------------------------------------------------------------*
*&      Module  CHECK_SPELL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE CHECK_SPELL INPUT.
   DATA : L_DESC87 TYPE I.
   L_DESC87 = STRLEN( ZMM_CDITEM-DESC_FIN ).
   IF L_DESC87 > 87.
     MESSAGE E065(ZMM_OTH).
   ENDIF.
   IF SY-UCOMM <> 'SPELL'.
     CLEAR IST_SPELL_LINE.
     REFRESH IST_SPELL_LINE.
     IST_SPELL_LINE-TDLINE = ZMM_CDITEM-DESC_FIN.
     APPEND IST_SPELL_LINE.
     EXPORT G_USER TO MEMORY ID 'G_USER1'.
     EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
     CALL FUNCTION 'ZSPELL_CHECK'
       EXPORTING
         SPRACHE = 'EN'
       TABLES
         ILINE   = IST_SPELL_LINE.
     IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
     IF NOT CHECKTAB[] IS INITIAL.
       MESSAGE I016(ZMM_OTH).
       REPLACE ZMM_CDITEM-COMP_FLG+0(1) WITH 'S' INTO ZMM_CDITEM-COMP_FLG
                         .
     ELSE.
       REPLACE ZMM_CDITEM-COMP_FLG+0(1) WITH '' INTO ZMM_CDITEM-COMP_FLG.
     ENDIF.
   ENDIF.
 ENDMODULE.                 " CHECK_SPELL  INPUT
*{   INSERT         OCPK900087                                        1
MODULE CHECK_STEUC INPUT.
  DATA: HSN1 TYPE T604F-STEUC.

        IF ZMM_CDITEM-STEUC IS NOT INITIAL.
          CLEAR : HSN1 .
          SELECT SINGLE STEUC
            INTO HSN1
            FROM T604F
            WHERE STEUC = ZMM_CDITEM-STEUC.
            IF HSN1  IS INITIAL.
              MESSAGE E503(ZMM_OTH).


            ENDIF.



        ENDIF.



ENDMODULE.

*}   INSERT

*---------------------------------------------------------------------*
*       FORM insert_mdlno                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
 FORM INSERT_MDLNO.
   DATA L_ANS1.
   DATA L_INDEX LIKE SY-TABIX.
   DATA L_MDLNO LIKE ZMM_MDL-MDLNO.
***   read table g_tablctrl120_itab into g_tablctrl120_wa index
***    g_curr_line_120.
*  read table g_tablctrl120_itab into g_tablctrl120_wa "added on 20.12.
*05
*    with key flag = 'X'.
*  If sy-subrc = 0 .
*
   " Begin of <RD1K960036>.

*   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*            DEFAULTOPTION        = 'Y'
*             TEXTLINE1            = 'Model No. of selected lines will be '
*                                     &'inserted. Continue?'
*            TITEL                = 'Insert OTHER Models'
*
*         IMPORTING
*           ANSWER               = l_ans1
   DATA : L_GET2(1) TYPE C.
   CALL FUNCTION 'POPUP_TO_CONFIRM'
     EXPORTING
       TITLEBAR       = 'Insert OTHER Models '
       TEXT_QUESTION  = 'Model No. of selected lines will be inserted. Continue?'
       DEFAULT_BUTTON = '1'
       START_COLUMN   = 25
       START_ROW      = 6
     IMPORTING
       ANSWER         = L_GET2
     EXCEPTIONS
       TEXT_NOT_FOUND = 1
       OTHERS         = 2.
   IF SY-SUBRC = 0.
     CASE L_GET2.
       WHEN '1'.
         MOVE 'J' TO L_ANS1.
       WHEN '2'.
         MOVE 'N' TO L_ANS1.
     ENDCASE.
   ENDIF.
   " End of <RD1K960036>.
   .
   IF L_ANS1 = 'J'.

     LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
       L_INDEX = SY-TABIX.
       IF G_TABLCTRL120_WA-FLAG = 'X'.
         IF G_TABLCTRL120_WA-OTH_MDL = 'X'.
           ZMM_MDL-MDLNO = G_TABLCTRL120_WA-MDLNO.
           ZMM_MDL-CREBY = SY-UNAME.
           ZMM_MDL-CREDT = SY-DATUM.
           TRANSLATE ZMM_MDL-MDLNO TO UPPER CASE.
*         modify zmm_mdl from zmm_mdl.
           INSERT INTO ZMM_MDL VALUES ZMM_MDL.
           COMMIT WORK.
           REPLACE 'L' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
           MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX
            SY-TABIX TRANSPORTING COMP_FLG.
           CLEAR ZMM_MDL-MDLNO.
         ENDIF.
       ELSE.
         SELECT SINGLE MDLNO FROM ZMM_MDL INTO L_MDLNO WHERE MDLNO =
             G_TABLCTRL120_WA-MDLNO.
         IF SY-SUBRC = 0 AND G_TABLCTRL120_WA-OTH_MDL = 'X'.
           REPLACE 'L' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
           MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX
            L_INDEX TRANSPORTING COMP_FLG.
         ENDIF.
       ENDIF.
     ENDLOOP.
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
 FORM SPELL_CHECK2.
*
   CLEAR IST_SPELL_LINE.
   REFRESH IST_SPELL_LINE.
   CLEAR SY-UCOMM.

   LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
     IST_SPELL_LINE-TDLINE = G_TABLCTRL120_WA-DESC_FIN.
     IST_SPELL_LINE-SRNO =   G_TABLCTRL120_WA-SRNO.
     APPEND IST_SPELL_LINE.
   ENDLOOP.
   EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
   EXPORT G_USER TO MEMORY ID 'G_USER1'.
   CALL FUNCTION 'ZSPELL_CHECK'
     EXPORTING
       SPRACHE = 'EN'
     TABLES
       ILINE   = IST_SPELL_LINE.

   IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
   IF NOT CHECKTAB[] IS INITIAL.

     MESSAGE I017(ZMM_OTH).
     PERFORM SPELL_ERROR_LINES_ZSPR.
   ELSE.
     MESSAGE I008(ZMM_OTH).
     LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
*
       REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
       MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX SY-TABIX
         TRANSPORTING COMP_FLG .
*
     ENDLOOP.
   ENDIF.
*
 ENDFORM.                    " spell_check2
*********************************************************************
 AT LINE-SELECTION.
*

   IF ZMM_CDHD_ST-MTART = 'ZSTO'.
     READ CURRENT LINE .
     WA_MODIFIER_CHECK_LIST = IST_MODIFIER_CHECK_LIST.
     SET PARAMETER ID 'S_MATGP' FIELD WA_MODIFIER_CHECK_LIST-MATGRP.
   ENDIF.

   IF SY-DYNNR = '0120'.
     READ CURRENT LINE .
     ZMM_CDITEM-MDLNO = SY-LISEL.
     ZMM_CDITEM-OTH_MDL = ''.
     REPLACE 'L' WITH '' INTO ZMM_CDITEM-COMP_FLG.
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
 FORM SPELL_ERROR_LINES_ZSPR.
   DATA :Z TYPE I, CT_IDX TYPE I.
   DATA : L_STATUS(2).
*
   TYPES: BEGIN OF ITAB_TYPE,
           WORD(60),
           SRNO(3),
         END   OF ITAB_TYPE.

   DATA: BEGIN OF CHECKTAB1 OCCURS 0,
          BEGRIFF(60),
          SRNO(3) TYPE N,
         END OF CHECKTAB1.

   DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
   DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.

*
   IF CHECKTAB[] IS INITIAL.
     LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
       IF G_TABLCTRL120_WA-COMP_FLG+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
         MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX Z
            TRANSPORTING COMP_FLG .
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT CHECKTAB[] IS INITIAL.

*
   CHECKTAB1[] = CHECKTAB[].
   LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
     Z = SY-TABIX.
     SPLIT  G_TABLCTRL120_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
     LOOP AT ITAB.
       MOVE Z TO ITAB-SRNO.
       MODIFY ITAB INDEX SY-TABIX.
     ENDLOOP.
     APPEND LINES OF ITAB TO ITAB1.
     CLEAR Z.
   ENDLOOP.

*
   CLEAR Z.
   LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
     IF G_TABLCTRL120_WA-COMP_FLG+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
       MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX SY-TABIX
               TRANSPORTING COMP_FLG .
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT CHECKTAB1.
     CT_IDX = SY-TABIX.
     READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
     IF SY-SUBRC = 0.
       CHECKTAB1-SRNO = ITAB1-SRNO.
       MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
       READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA INDEX
       ITAB1-SRNO.
       IF G_TABLCTRL120_WA-COMP_FLG+1(1) = ''.
         G_TABLCTRL120_WA-COMP_FLG = 'S'.
       ELSE.
         CONCATENATE 'S' G_TABLCTRL120_WA-COMP_FLG+1(1) INTO L_STATUS.
         G_TABLCTRL120_WA-COMP_FLG = L_STATUS.
       ENDIF.
       Z = ITAB1-SRNO.
       MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX Z
            TRANSPORTING COMP_FLG .
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
 FORM GET_SRCHLP_ZCAP.
   DATA : L_SRNO  LIKE SY-INDEX.
   DATA : L_LEN   LIKE SY-INDEX.
   DATA : L_CHECK.
   DATA : BEGIN OF WA_PARTDESC,
            PART(40),
          END OF WA_PARTDESC.
   DATA : IST_PARTDESC LIKE TABLE OF WA_PARTDESC.
   DATA : L_DESC(100).
   DATA : PART1(40),PART2(40),PART3(40),PART4(40).
   DATA : L_MATNR LIKE THEAD-TDNAME.
   DATA : IST_PARTDESC_LINES TYPE I.

*
*   CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_FIN' .
   IF G_CURSOR_FLD130 = 'ZMM_CDITEM-DESC_FIN' .
*
     READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
     G_CURR_LINE_130.
****To change desc_fin and SAVE without pressing ENTER
     IF G_DESC_FIN_CHNG = 'X' AND ZMM_CDITEM-DESC_FIN <>
                                  G_TABLCTRL130_WA-DESC_FIN.
       G_TABLCTRL130_WA-DESC_FIN = ZMM_CDITEM-DESC_FIN.
     ENDIF.
****To change desc_fin and SAVE without pressing ENTER

     IF NOT G_TABLCTRL130_WA-DESC_FIN  IS INITIAL.
       TRANSLATE G_TABLCTRL130_WA-DESC_FIN TO UPPER CASE.
       SPLIT G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE IST_PARTDESC.
*
       DESCRIBE TABLE IST_PARTDESC LINES IST_PARTDESC_LINES.
       IF IST_PARTDESC_LINES > 2.
         DELETE IST_PARTDESC FROM 3 TO IST_PARTDESC_LINES.
       ENDIF.
       READ TABLE IST_PARTDESC INTO WA_PARTDESC INDEX 1.

       CONCATENATE '%' WA_PARTDESC-PART '%' INTO L_DESC .
       CONDENSE L_DESC NO-GAPS.
*
       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE B~MTART = 'ZCAP'  AND
       ( A~MAKTG LIKE L_DESC OR B~WRKST LIKE L_DESC )
* Added on 29.12.05
       AND B~MSTAE = ''.
* End addition.
       LOOP AT IST_PARTDESC INTO WA_PARTDESC.
         IF SY-TABIX = 1.
           PART1 = WA_PARTDESC-PART.
           CONDENSE PART1 NO-GAPS.
         ELSEIF SY-TABIX = 2.
           PART2 = WA_PARTDESC-PART.
           CONDENSE PART1 NO-GAPS.
*
         ENDIF.
       ENDLOOP.

       LOOP AT IST_SRCHLP INTO WA_SRCHLP.
         IF WA_SRCHLP-MAKTG+39(1) = '*'.
           CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
           WA_SRCHLP-MAKTX.
         ELSE.
           MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
         ENDIF.

         TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
         CHECK PART2 <> ''.
         SEARCH WA_SRCHLP-MAKTX FOR PART2.
         IF SY-SUBRC = 0.
*
         ELSE.
           DELETE  IST_SRCHLP INDEX SY-TABIX.
         ENDIF.
       ENDLOOP.
     ENDIF.
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       IF WA_SRCHLP-MAKTG+39(1) = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.
       L_SRNO         = L_SRNO + 1.
       WA_SRCHLP-SRNO = L_SRNO.
       L_MATNR = WA_SRCHLP-MATNR.

       CALL FUNCTION 'READ_TEXT'
         EXPORTING
           ID                      = 'BEST'
           LANGUAGE                = 'E'
           NAME                    = L_MATNR
           OBJECT                  = 'MATERIAL'
         TABLES
           LINES                   = LINES
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         WA_SRCHLP-MARK = '1'.
       ENDIF.
       MODIFY IST_SRCHLP FROM WA_SRCHLP.
     ENDLOOP.
     DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
*********************************************************************
***********************Date : 01.12.2005*****************************
** Addition for Search on Sugested Capital Code
*  CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_CDCELL' .
*
   ELSEIF G_CURSOR_FLD130 = 'ZMM_CDITEM-DESC_CDCELL' .

     READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
     G_CURR_LINE_130.
*****To change desc_fin and SAVE without pressing ENTER
*   if G_desc_fin_chng = 'X' and zmm_cditem-desc_fin <>
*                                g_TABLCTRL130_wa-desc_fin.
*     g_TABLCTRL130_wa-desc_fin = zmm_cditem-desc_fin.
*   Endif.
*****To change desc_fin and SAVE without pressing ENTER

     IF NOT G_TABLCTRL130_WA-DESC_CDCELL  IS INITIAL.
       TRANSLATE G_TABLCTRL130_WA-DESC_CDCELL TO UPPER CASE.
       SPLIT G_TABLCTRL130_WA-DESC_CDCELL AT ' ' INTO TABLE IST_PARTDESC.
*
       DESCRIBE TABLE IST_PARTDESC LINES IST_PARTDESC_LINES.
       IF IST_PARTDESC_LINES > 2.
         DELETE IST_PARTDESC FROM 3 TO IST_PARTDESC_LINES.
       ENDIF.
       READ TABLE IST_PARTDESC INTO WA_PARTDESC INDEX 1.

       CONCATENATE '%' WA_PARTDESC-PART '%' INTO L_DESC .
       CONDENSE L_DESC NO-GAPS.
*
       SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE B~MTART = 'ZCAP'  AND
       ( A~MAKTG LIKE L_DESC OR B~WRKST LIKE L_DESC )
       AND B~MSTAE = ''.
*
       LOOP AT IST_PARTDESC INTO WA_PARTDESC.
         IF SY-TABIX = 1.
           PART1 = WA_PARTDESC-PART.
           CONDENSE PART1 NO-GAPS.
         ELSEIF SY-TABIX = 2.
           PART2 = WA_PARTDESC-PART.
           CONDENSE PART1 NO-GAPS.
*
         ENDIF.
       ENDLOOP.

       LOOP AT IST_SRCHLP INTO WA_SRCHLP.
         IF WA_SRCHLP-MAKTG+39(1) = '*'.
           CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
           WA_SRCHLP-MAKTX.
         ELSE.
           MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
         ENDIF.

         TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
         CHECK PART2 <> ''.
         SEARCH WA_SRCHLP-MAKTX FOR PART2.
         IF SY-SUBRC = 0.
*
         ELSE.
           DELETE  IST_SRCHLP INDEX SY-TABIX.
         ENDIF.
       ENDLOOP.
     ENDIF.
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       IF WA_SRCHLP-MAKTG+39(1) = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.
       L_SRNO         = L_SRNO + 1.
       WA_SRCHLP-SRNO = L_SRNO.
       L_MATNR = WA_SRCHLP-MATNR.

       CALL FUNCTION 'READ_TEXT'
         EXPORTING
           ID                      = 'BEST'
           LANGUAGE                = 'E'
           NAME                    = L_MATNR
           OBJECT                  = 'MATERIAL'
         TABLES
           LINES                   = LINES
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         WA_SRCHLP-MARK = '1'.
       ENDIF.
       MODIFY IST_SRCHLP FROM WA_SRCHLP.
     ENDLOOP.
     DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
   ENDIF.
 ENDFORM.                    " get_srchlp_zcap
*&---------------------------------------------------------------------*
*&      Form  spell_check3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SPELL_CHECK3.
   CLEAR IST_SPELL_LINE.
   REFRESH IST_SPELL_LINE.
   CLEAR SY-UCOMM.

   LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
     IST_SPELL_LINE-TDLINE = G_TABLCTRL130_WA-DESC_FIN.
     IST_SPELL_LINE-SRNO =   G_TABLCTRL130_WA-SRNO.
     APPEND IST_SPELL_LINE.
   ENDLOOP.
   EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
   EXPORT G_USER TO MEMORY ID 'G_USER1'.
   CALL FUNCTION 'ZSPELL_CHECK'
     EXPORTING
       SPRACHE = 'EN'
     TABLES
       ILINE   = IST_SPELL_LINE.

   IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
   IF NOT CHECKTAB[] IS INITIAL.

     MESSAGE I017(ZMM_OTH).
     PERFORM SPELL_ERROR_LINES_ZCAP.
   ELSE.
     MESSAGE I008(ZMM_OTH).
     LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
*
       REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
       MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX SY-TABIX
         TRANSPORTING COMP_FLG .
*
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
 FORM SPELL_ERROR_LINES_ZCAP.
   DATA :Z TYPE I, CT_IDX TYPE I.
   DATA : L_STATUS(2).
* .
   TYPES: BEGIN OF ITAB_TYPE,
           WORD(60),
           SRNO(3),
         END   OF ITAB_TYPE.

   DATA: BEGIN OF CHECKTAB1 OCCURS 0,
          BEGRIFF(60),
          SRNO(3) TYPE N,
         END OF CHECKTAB1.

   DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
   DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.

*
   IF CHECKTAB[] IS INITIAL.
     LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
       IF G_TABLCTRL130_WA-COMP_FLG+0(1) = 'S'.
         REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
         MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX Z
            TRANSPORTING COMP_FLG .
       ENDIF.
     ENDLOOP.
   ENDIF.
   CHECK NOT CHECKTAB[] IS INITIAL.

*
   CHECKTAB1[] = CHECKTAB[].
   LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
     Z = SY-TABIX.
     SPLIT  G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
     LOOP AT ITAB.
       MOVE Z TO ITAB-SRNO.
       MODIFY ITAB INDEX SY-TABIX.
     ENDLOOP.
     APPEND LINES OF ITAB TO ITAB1.
     CLEAR Z.
   ENDLOOP.

*
   CLEAR Z.
   LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
     IF G_TABLCTRL130_WA-COMP_FLG+0(1) = 'S'.
       REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
       MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX SY-TABIX
               TRANSPORTING COMP_FLG .
     ELSE.
       CONTINUE.
     ENDIF.
   ENDLOOP.

   LOOP AT CHECKTAB1.
     CT_IDX = SY-TABIX.
     READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
     IF SY-SUBRC = 0.
       CHECKTAB1-SRNO = ITAB1-SRNO.
       MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
       READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
       ITAB1-SRNO.
       IF G_TABLCTRL130_WA-COMP_FLG+1(1) = ''.
         G_TABLCTRL130_WA-COMP_FLG = 'S'.
       ELSE.
         CONCATENATE 'S' G_TABLCTRL130_WA-COMP_FLG+1(1) INTO L_STATUS.
         G_TABLCTRL130_WA-COMP_FLG = L_STATUS.
       ENDIF.
       Z = ITAB1-SRNO.
       MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX Z
            TRANSPORTING COMP_FLG .
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
 FORM CP_MATCODE.
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
 FORM GET_SRNO.
*
***To get the proper serial no of line item against the
***Cursor position
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSTO'.
*
       G_CURS_LN = G_CURR_LINE_110.
       READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
                                   INDEX G_CURS_LN.
       G_SRNO = G_TABCTRL110_WA-SRNO.
     WHEN 'ZSPR'.
*
       G_CURS_LN = G_CURR_LINE_120.
       READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
                     INDEX G_CURS_LN.
       G_SRNO = G_TABLCTRL120_WA-SRNO.
     WHEN 'ZCAP'.
       MOVE TABLCTRL130-CURRENT_LINE TO G_CURS_LN.
       READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
                     INDEX G_CURS_LN.
       G_SRNO = G_TABLCTRL130_WA-SRNO.
     WHEN 'ZDIS'.
       MOVE TABLCTRL140-CURRENT_LINE TO G_CURS_LN.
       READ TABLE G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA
                                   INDEX G_CURS_LN.
       G_SRNO = G_TABLCTRL140_WA-SRNO.
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
 FORM CHANGE_MRP.
   IF  G_MODE = 'CHA' OR G_MODE = 'REL' OR G_MODE = 'APR'.
*
     AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                    ID 'M_BANF_WRK' FIELD ZMM_CDHD_ST-WERKS
                    ID 'ACTVT' FIELD '01'.
     IF SY-SUBRC = 0.
       G_CHANGE_AUTH = 'X'.
     ELSE.
       G_CHANGE_AUTH = ''.
     ENDIF.

   ENDIF.
 ENDFORM.                    " CHANGE_MRP
*&---------------------------------------------------------------------*
*&      Form  exit_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXIT_CONFIRM.
   DATA L_CHOICE1.
   CLEAR L_CHOICE1.
   IF G_MODE <> 'DIS'.
     " Begin of <RD1K960036>.

*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               TEXTLINE1      = 'Data will be lost, Want to quit? '
*               TITEL          = 'EXIT'
*               START_COLUMN   = 25
*               START_ROW      = 6
*               CANCEL_DISPLAY = ''
*          IMPORTING
*               ANSWER         = l_choice1.
     DATA : L_GET3(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR       = 'EXIT '
         TEXT_QUESTION  = 'Data will be lost, Want to quit? '
         START_COLUMN   = 25
         START_ROW      = 6
       IMPORTING
         ANSWER         = L_GET3
       EXCEPTIONS
         TEXT_NOT_FOUND = 1
         OTHERS         = 2.
     IF SY-SUBRC = 0.
       CASE L_GET3.
         WHEN '1'.
           MOVE 'J' TO L_CHOICE1.
         WHEN '2'.
           MOVE 'N' TO L_CHOICE1.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.

     IF L_CHOICE1 = 'J'.
       CLEAR L_CHOICE1.
       PERFORM UNDO_LONGTEXT.
       PERFORM CLEAR_VAR.
       PERFORM UNLOCK_REQ.
       IF OKCODE_100 = 'BAC'.
         LEAVE TO SCREEN 100.
       ELSE.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ELSE.
     " Begin of <RD1K960036>.

*     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*               TEXTLINE1      = 'Want to quit? '
*               TITEL          = 'EXIT'
*               START_COLUMN   = 25
*               START_ROW      = 6
*               CANCEL_DISPLAY = ''
*          IMPORTING
*               ANSWER         = l_choice1.

     DATA : L_GET4(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
         TITLEBAR       = 'EXIT '
         TEXT_QUESTION  = 'Want to quit? '
         START_COLUMN   = 25
         START_ROW      = 6
       IMPORTING
         ANSWER         = L_GET4
       EXCEPTIONS
         TEXT_NOT_FOUND = 1
         OTHERS         = 2.
     IF SY-SUBRC = 0.
       CASE L_GET4.
         WHEN '1'.
           MOVE 'J' TO L_CHOICE1.
         WHEN '2'.
           MOVE 'N' TO L_CHOICE1.
       ENDCASE.
     ENDIF.
     " End of <RD1K960036>.

     IF L_CHOICE1 = 'J'.
       PERFORM CLEAR_VAR.
       IF OKCODE_100 = 'BAC'.
         LEAVE TO SCREEN 100.
       ELSE.
         LEAVE PROGRAM.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " exit_confirm
*
*&---------------------------------------------------------------------*
*&      Form  get_dummyno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_DUMMYNO.
   DATA:  X TYPE I,
          Y TYPE I,
          L_USER LIKE SY-UNAME.
   CLEAR: L_USER, G_USER_LOGGED.
   L_USER = SY-UNAME.
   X = STRLEN( SY-UNAME ).
   Y = 10 - X.
   IF X < 10.
     DO Y TIMES.
       CONCATENATE L_USER '0' INTO L_USER.
     ENDDO.
     G_USER_LOGGED = L_USER.
   ELSEIF X > 10.
     G_USER_LOGGED = SY-UNAME+0(10).
   ELSE.
     G_USER_LOGGED = SY-UNAME.
   ENDIF.
 ENDFORM.                    " get_dummyno
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_spr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_NEXTSRNO_SPR.
   DATA : G_120ITAB TYPE TABLE OF T_TABLCTRL120.
*  Data:  l_itab120 type table of t_tablctrl120.
   REFRESH G_120ITAB.
   APPEND LINES OF G_TABLCTRL120_ITAB TO G_120ITAB.
   SORT G_120ITAB BY SRNO DESCENDING.
   READ TABLE G_120ITAB INTO L_ITAB120 INDEX 1.
   L_SRNO = L_ITAB120-SRNO + 1.
 ENDFORM.                    " get_nextsrno_spr
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_sto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_NEXTSRNO_STO.
   DATA : G_110ITAB TYPE TABLE OF T_TABCTRL110.
   DATA : L_110ITAB TYPE T_TABCTRL110.
   CLEAR L_110ITAB.
   REFRESH G_110ITAB.

   APPEND LINES OF G_TABCTRL110_ITAB TO G_110ITAB.
   SORT G_110ITAB BY SRNO DESCENDING.
   READ TABLE G_110ITAB INTO L_110ITAB INDEX 1.
   L_SRNO = L_110ITAB-SRNO + 1.

 ENDFORM.                    " get_nextsrno_sto
*&---------------------------------------------------------------------*
*&      Form  get_cursor120
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_CURSOR120.

   GET CURSOR LINE G_CURSOR_LINE.
   G_CURR_LINE = G_CURSOR_LINE.
   G_CURR_LINE = TABLCTRL120-TOP_LINE + G_CURSOR_LINE - 1.
   G_CURR_LINE_120 = G_CURR_LINE .

 ENDFORM.                    " get_cursor120
*&---------------------------------------------------------------------*
*&      Form  alphanum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM ALPHANUM.
   G_LINENO = '1'.
   IF CHECK_FLAG = 'X'.
     EXIT.
   ENDIF.
   CHECK_FLAG = 'X'.
   DATA : L_NUM TYPE I.
   DO 10 TIMES.
     WA_ALPHANUM = L_NUM.
     APPEND WA_ALPHANUM TO IST_ALPHANUM.
     L_NUM = L_NUM + 1.
   ENDDO.
   CLEAR L_NUM.
   DO 26 TIMES.
     WA_ALPHANUM = ALPHA+L_NUM(1).
*translate wa_alphanum to upper case.
     APPEND WA_ALPHANUM TO IST_ALPHANUM.
     L_NUM = L_NUM + 1.
   ENDDO.

 ENDFORM.                    " alphanum
*&---------------------------------------------------------------------*
*&      Form  get_nextsrno_cap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_NEXTSRNO_CAP.
   DATA : G_130ITAB TYPE TABLE OF T_TABLCTRL130.
*
   REFRESH G_130ITAB.
   APPEND LINES OF G_TABLCTRL130_ITAB TO G_130ITAB.
   SORT G_130ITAB BY SRNO DESCENDING.
   READ TABLE G_130ITAB INTO L_ITAB130 INDEX 1.
   L_SRNO = L_ITAB130-SRNO + 1.

 ENDFORM.                    " get_nextsrno_cap
*&---------------------------------------------------------------------*
*&      Form  get_mat_find
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_MAT_FIND.

   IF FIELD1 = 'ZMM_CDITEM-PARTNO' .

     G_MATTY1 = ZMM_CDHD_ST-MTART.

     PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
     CLEAR : DESC11, DESC22 ,DESC33 , DESC44.
     PERFORM SELECT_HELP_DATA USING
                   G_PARTNO
                   DESC11
                   DESC22
                   DESC33
                   DESC44
*{   INSERT         OCPK900087                                        1
*STEUC
*}   INSERT
                   DESC55
                   G_MATGP
                   G_MATTY1
                CHANGING SEL_FLAG.
   ENDIF.

   DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.

   READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA INDEX
G_LINENO.

   G_TABLCTRL120_WA-MAT_FND = G_MAT_FND .

   MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX G_LINENO.

   CLEAR G_MATTY1.

 ENDFORM.                    " get_mat_find
*&---------------------------------------------------------------------*
*&      Form  validate_capcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM VALIDATE_CAPCODE.

   DATA : L_CAPCODE LIKE MARA-MATNR.
*
   IF NOT ZMM_CDITEM-CAP_CODE IS INITIAL.

     SELECT * FROM CABN UP TO 1 ROWS
 WHERE ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     SELECT SINGLE A~MATNR INTO L_CAPCODE
                         FROM MARA AS A  INNER JOIN AUSP AS B
                         ON A~MATNR = B~OBJEK
                         WHERE B~ATINN = CABN-ATINN AND
                         B~ATWRT <> '' AND
                         A~MATNR = ZMM_CDITEM-CAP_CODE.

     IF SY-SUBRC <> 0.
       MESSAGE E067(ZMM_OTH).
     ENDIF.

   ENDIF.

 ENDFORM.                    " validate_capcode
*&---------------------------------------------------------------------*
*&      Form  check_morethanonegrp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_MORETHANONEGRP.
   DATA : BEGIN OF L_MATGP_ITAB OCCURS 0,
          MATGP LIKE ZMM_CDITEM-MATGP,
         END   OF L_MATGP_ITAB.

   CLEAR: G_GRPCOUNT,G_CODUSER.
   REFRESH L_MATGP_ITAB.

   SELECT MATGP INTO TABLE L_MATGP_ITAB
          FROM ZMM_CDITEM
          WHERE REQNO = ZMM_CDHD_ST-REQNO.
   SORT L_MATGP_ITAB ASCENDING BY MATGP.
   DELETE ADJACENT DUPLICATES FROM L_MATGP_ITAB.
   DESCRIBE TABLE L_MATGP_ITAB LINES G_GRPCOUNT.

   SELECT SINGLE * FROM ZMM_CDCODIFIER
        WHERE CODIFIER = SY-UNAME
        AND   MATGP    = ''
        AND   STATUS   = 'A'.
   IF SY-SUBRC = 0.
     G_CODUSER = 'A'.
   ENDIF.
 ENDFORM.                    " check_morethanonegrp

*&---------------------------------------------------------------------*
*&      Form  GET_PARNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_PARNO.
   SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
 WHERE DESC1 = G_TABCTRL110_WA-DESC1
 AND MATGRP = G_TABCTRL110_WA-MATGP
 ORDER BY PRIMARY KEY .
 ENDSELECT.
   IF SY-SUBRC <> 0.
     G_PARNO = '1'.
   ELSE.
     IF  ZMM_MODIFIER-DESC2 IS INITIAL.
       G_PARNO = '1'.
     ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
       G_PARNO = '2'.
     ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
       G_PARNO = '3'.
     ELSE.
       G_PARNO = '4'.
     ENDIF.
   ENDIF.
 ENDFORM.                    " GET_PARNO
*&---------------------------------------------------------------------*
*&      Form  set_addnl_desc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_ADDNL_DESC.

   IF SY-TCODE <> 'ZCODG'.
     LOOP AT SCREEN.
       IF SCREEN-NAME = 'G_DESC1'     OR
          SCREEN-NAME = 'G_DESC2'     OR
          SCREEN-NAME = 'G_DESC3'     OR
          SCREEN-NAME = 'G_DESC4'     OR
          SCREEN-NAME = 'G_MATGP'.
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ELSEIF SCREEN-NAME = 'G_USER_DESC' AND USER_DESC_LEN > 0.
         SCREEN-LENGTH = USER_DESC_LEN.
         SCREEN-INPUT = 1.
         MODIFY SCREEN.
       ENDIF.
       IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ENDIF.
       IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
                            SCREEN-NAME = 'G_DESC4' ).
         SCREEN-INPUT = 0.
         MODIFY SCREEN.
       ENDIF.

     ENDLOOP.
   ENDIF.
 ENDFORM.                    " set_addnl_desc
*&---------------------------------------------------------------------*
*&      Form  check_length
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_LENGTH.
   DATA L_TOTAL_LEN TYPE I.
   DATA G_DESC_FIN(150).
*   if sy-tcode = 'ZCODG'.
   CONCATENATE G_DESC1 G_DESC2
   G_DESC3
   G_DESC4 G_USER_DESC INTO G_DESC_FIN
  SEPARATED BY SPACE.
   CONDENSE G_DESC_FIN.
   L_TOTAL_LEN = STRLEN( G_DESC_FIN ).
   IF L_TOTAL_LEN > 87.
     G_LEN_EX87 = 'X'.
     MESSAGE I063(ZMM_OTH).
     LEAVE TO SCREEN 115.
   ENDIF.
*   Endif.

 ENDFORM.                    " check_length
*&---------------------------------------------------------------------*
*&      Form  get_attrib_115
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_ATTRIB_115.
   DATA : L_DESC1_ATTRIB , L_DESC2_ATTRIB, L_DESC3_ATTRIB, L_DESC4_ATTRIB,
                     L_ADESC_ATTRIB.
   LOOP AT SCREEN.
     IF SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC1'.
       L_DESC1_ATTRIB = 'X'.
     ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC2'.
       L_DESC2_ATTRIB = 'X'.
     ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC3'.
       L_DESC3_ATTRIB = 'X'.
     ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC4'.
       L_DESC4_ATTRIB = 'X'.
     ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'A_DESC'.
       L_ADESC_ATTRIB = 'X'.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " get_attrib_115
*&---------------------------------------------------------------------*
*&      Form  get_parno1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_PARNO1.
   READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA INDEX
   G_CURR_LINE_110.
   IF SY-SUBRC = 0.

     SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
 WHERE DESC1 =
 G_TABCTRL110_WA-DESC1 AND MATGRP = G_TABCTRL110_WA-MATGP
 ORDER BY PRIMARY KEY .
 ENDSELECT.
     IF SY-SUBRC <> 0.
       G_PARNO = '1'.
     ELSE.
       IF  ZMM_MODIFIER-DESC2 IS INITIAL.
         G_PARNO = '1'.
       ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
         G_PARNO = '2'.
       ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
         G_PARNO = '3'.
       ELSE.
         G_PARNO = '4'.
       ENDIF.
     ENDIF.
   ENDIF.
 ENDFORM.                    " get_parno1
*&---------------------------------------------------------------------*
*&      Form  chaby_chadt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHABY_CHADT.
   IF G_MODE = 'APR'.
     IF G_USER = 'M'.
       IF WA_ZMM_CDITEM-REJ_FLG = 'RM'.
         MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
         MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
       ELSE.
         MOVE G_CDITEM-CODDT TO WA_ZMM_CDITEM-CODDT.
         MOVE G_CDITEM-CODBY TO WA_ZMM_CDITEM-CODBY.
       ENDIF.
     ELSEIF G_USER = 'L'.
       IF WA_ZMM_CDITEM-REJ_FLG = 'RT'.
         MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
         MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
       ELSE.
         MOVE G_CDITEM-CODDT TO WA_ZMM_CDITEM-CODDT.
         MOVE G_CDITEM-CODBY TO WA_ZMM_CDITEM-CODBY.
       ENDIF.
     ENDIF.
   ENDIF.
   IF G_MODE <> 'APR'.
     IF SY-TCODE <> 'ZCODG'.
       MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
       MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
     ENDIF.
   ENDIF.
 ENDFORM.                    " chaby_chadt
*&---------------------------------------------------------------------*
*&      Form  Check_dupl_rec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM CHECK_DUPL_REC.
   DATA:L_110 TYPE TABLE OF T_TABCTRL110,
        L_120 TYPE TABLE OF T_TABLCTRL120,
        L_130 TYPE TABLE OF T_TABLCTRL130,
        L_140 TYPE TABLE OF T_TABLCTRL140,
        L_CDITEM   LIKE  ZMM_CDITEM.
   CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN.
   REFRESH: L_110,L_120,L_130,L_140.
**Addition-Duplicate Check*******************=
   .
   IF G_MODE = 'CHA' OR G_MODE = 'CRE'.

     CASE ZMM_CDHD_ST-MTART.
       WHEN 'ZSTO'.
         IF G_MODE = 'CRE'.
           SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN AND UOM = G_TABCTRL110_WA-UOM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
           IF SY-SUBRC = 0.
             G_DUPLICATE_REC = 'X'.
             MESSAGE I074(ZMM_OTH) WITH L_CDITEM-REQNO
                                G_TABCTRL110_WA-SRNO .
           ENDIF.
         ELSEIF G_MODE = 'CHA'.
           SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN AND UOM = G_TABCTRL110_WA-UOM AND REQNO <> ZMM_CDHD_ST-REQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
           IF SY-SUBRC = 0.
             G_DUPLICATE_REC = 'X'.
             MESSAGE I074(ZMM_OTH) WITH L_CDITEM-REQNO
                                 G_TABCTRL110_WA-SRNO .
           ENDIF.
         ENDIF.
         APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
         SORT L_110 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZSPR'.
         SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE PARTNO = G_TABLCTRL120_WA-PARTNO AND DESC_FIN = G_TABLCTRL120_WA-DESC_FIN AND UOM = G_TABLCTRL120_WA-UOM AND CAP_CODE = G_TABLCTRL120_WA-CAP_CODE AND MDLNO = G_TABLCTRL120_WA-MDLNO AND MANU = G_TABLCTRL120_WA-MANU
 ORDER BY PRIMARY KEY .
 ENDSELECT.
         IF SY-SUBRC = 0.
           MESSAGE E074(ZMM_OTH) WITH L_CDITEM-REQNO.
         ENDIF.

         APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
         SORT L_120 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_120
                COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZCAP'.
         SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

         IF SY-SUBRC = 0.
           MESSAGE E074(ZMM_OTH) WITH L_CDITEM-REQNO.
         ENDIF.
         APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
         SORT L_130 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZDIS'.
         APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
         SORT L_140 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " Check_dupl_rec
*******************************************************************
 FORM CHECK_DUPL_REC1.
   DATA:L_110 TYPE TABLE OF T_TABCTRL110,
        L_120 TYPE TABLE OF T_TABLCTRL120,
        L_130 TYPE TABLE OF T_TABLCTRL130,
        L_140 TYPE TABLE OF T_TABLCTRL140,
        L_CDITEM   LIKE  ZMM_CDITEM.
   DATA :  L_CURR_SRNO TYPE N.
   CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN,L_CDITEM , G_CDITEM_ITAB.
   REFRESH: L_110,L_120,L_130,L_140, G_CDITEM_ITAB.
**
   IF G_MODE = 'CHA' OR G_MODE = 'CRE'.
     CASE ZMM_CDHD_ST-MTART.
       WHEN 'ZSTO'.
**Addition-Duplicate Check*for other request****
         LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
           IF G_MODE = 'CRE'.
             SELECT  REQNO SRNO DESC_FIN
                   APPENDING CORRESPONDING FIELDS OF
                   TABLE G_CDITEM_ITAB
                   FROM ZMM_CDITEM
                   WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN
                   AND   UOM      = G_TABCTRL110_WA-UOM ORDER BY PRIMARY KEY.
           ELSEIF G_MODE = 'CHA'.
             SELECT  REQNO SRNO DESC_FIN
                   APPENDING CORRESPONDING FIELDS OF
                   TABLE G_CDITEM_ITAB
                   FROM ZMM_CDITEM
                   WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN
                   AND   UOM      = G_TABCTRL110_WA-UOM
                   AND   REQNO    <> ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
           ENDIF.
           LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
             IF G_CDITEM-MAT_FND IS INITIAL.
*****Mat_fnd is used as place holder for exsiting srno.
               G_CDITEM-MAT_FND = G_TABCTRL110_WA-SRNO.
               MODIFY G_CDITEM_ITAB FROM G_CDITEM
                                    INDEX SY-TABIX
                                    TRANSPORTING MAT_FND.
             ENDIF.
           ENDLOOP.
         ENDLOOP.
         IF NOT G_CDITEM_ITAB IS INITIAL.
           G_DUPLICATE_REC = 'X'.
           CALL SCREEN 102.
         ENDIF.
****Duplicate check for same request
         APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
         SORT L_110 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZSPR'.
****Duplicate entry check in other requests.
         LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
           IF G_MODE = 'CRE'.
             SELECT  REQNO SRNO DESC_FIN
               APPENDING CORRESPONDING FIELDS OF
               TABLE G_CDITEM_ITAB
               FROM ZMM_CDITEM
               WHERE PARTNO   = G_TABLCTRL120_WA-PARTNO
               AND   DESC_FIN = G_TABLCTRL120_WA-DESC_FIN
               AND   UOM      = G_TABLCTRL120_WA-UOM
               AND   CAP_CODE = G_TABLCTRL120_WA-CAP_CODE
               AND   MDLNO    = G_TABLCTRL120_WA-MDLNO
               AND   MANU     = G_TABLCTRL120_WA-MANU.
           ELSEIF G_MODE = 'CHA'.
             SELECT  REQNO SRNO DESC_FIN
               APPENDING CORRESPONDING FIELDS OF
               TABLE G_CDITEM_ITAB
               FROM ZMM_CDITEM
               WHERE PARTNO   = G_TABLCTRL120_WA-PARTNO
               AND   DESC_FIN = G_TABLCTRL120_WA-DESC_FIN
               AND   UOM      = G_TABLCTRL120_WA-UOM
               AND   CAP_CODE = G_TABLCTRL120_WA-CAP_CODE
               AND   MDLNO    = G_TABLCTRL120_WA-MDLNO
               AND   MANU     = G_TABLCTRL120_WA-MANU
               AND   REQNO    <> ZMM_CDHD_ST-REQNO.
           ENDIF.
           LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
             IF G_CDITEM-MAT_FND IS INITIAL.
*****Mat_fnd is used as place holder for exsiting srno.
               G_CDITEM-MAT_FND = G_TABLCTRL120_WA-SRNO.
               MODIFY G_CDITEM_ITAB FROM G_CDITEM
                                    INDEX SY-TABIX
                                    TRANSPORTING MAT_FND.
             ENDIF.
           ENDLOOP.
         ENDLOOP.
         IF NOT G_CDITEM_ITAB IS INITIAL.
           G_DUPLICATE_REC = 'X'.
           CALL SCREEN 102.
         ENDIF.
******Duplicate entry check in the same request.
         APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
         SORT L_120 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_120
                COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZCAP'.
****Duplicate entry check in other requests.
         LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
           IF G_MODE = 'CRE'.
             SELECT  REQNO SRNO DESC_FIN
               APPENDING CORRESPONDING FIELDS OF
               TABLE G_CDITEM_ITAB
               FROM ZMM_CDITEM
               WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN.
           ELSEIF G_MODE = 'CHA'.
             SELECT  REQNO SRNO DESC_FIN
               APPENDING CORRESPONDING FIELDS OF
               TABLE G_CDITEM_ITAB
               FROM ZMM_CDITEM
               WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN
               AND   REQNO    <> ZMM_CDHD_ST-REQNO.
           ENDIF.
           LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
             IF G_CDITEM-MAT_FND IS INITIAL.
*****Mat_fnd is used as place holder for exsiting srno.
               G_CDITEM-MAT_FND = G_TABLCTRL130_WA-SRNO.
               MODIFY G_CDITEM_ITAB FROM G_CDITEM
                                    INDEX SY-TABIX
                                    TRANSPORTING MAT_FND.
             ENDIF.
           ENDLOOP.
         ENDLOOP.
         IF NOT G_CDITEM_ITAB IS INITIAL.
           G_DUPLICATE_REC = 'X'.
           CALL SCREEN 102.
         ENDIF.
******Duplicate entry check in the same request.
         APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
         SORT L_130 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
       WHEN 'ZDIS'.
         APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
         SORT L_140 BY DESC_FIN ASCENDING.
         DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
         IF SY-SUBRC = 0.
           MESSAGE I072(ZMM_OTH).
           IF OKCODE_100 = 'SAV'.
             CLEAR OKCODE_100.
           ENDIF.
         ENDIF.
     ENDCASE.
   ENDIF.

 ENDFORM.                    " Check_dupl_rec1
*&---------------------------------------------------------------------*
*&      Form  set_g_user
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SET_G_USER.
   IF ZMM_CDHD_ST-APPROVE_MRP = 'X'.
     G_USER = 'L'.
   ELSE.
     G_USER = 'M'.
   ENDIF.
 ENDFORM.                    " set_g_user
*&---------------------------------------------------------------------*
*&      Form  get_noofhits
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_NOOFHITS.
   DATA : G_PARTNO11 LIKE ZMM_CDITEM-USER_DESC.
   DATA : G_PARTNO22 LIKE ZMM_CDITEM-USER_DESC.

   DATA : L_LEN11 TYPE I,
          L_LEN22 TYPE I.
   REFRESH :IST_SRCHLP.
************
   CASE ZMM_CDHD_ST-MTART.
     WHEN 'ZSPR'.
       G_PARTNOC = G_TABLCTRL120_WA-PARTNO.

       PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.

       SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST
                  INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
                  FROM MAKT AS A JOIN MARA AS B
                  ON    A~MATNR = B~MATNR
                  WHERE B~MFRPN LIKE G_PARTNO
                  AND ( B~MTART = 'ZSPR' OR B~MTART = 'ZMPN' )
                  AND B~MSTAE = ''.

       PERFORM CHANGE_PARTNO1 CHANGING G_PARTNO11 G_PARTNOC.
       L_LEN11 = STRLEN( G_PARTNO11 ).

       LOOP AT IST_SRCHLP INTO WA_SRCHLP.
         PERFORM CHANGE_PARTNO2 CHANGING G_PARTNO22 WA_SRCHLP-MFRPN.
         L_LEN22 = STRLEN( G_PARTNO22 ).
         SEARCH G_PARTNO22 FOR G_PARTNO11.
         IF SY-SUBRC = 0 AND L_LEN11 = L_LEN22.
         ELSE.
           DELETE IST_SRCHLP.
         ENDIF.
       ENDLOOP.

       DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
       G_TABLCTRL120_WA-MAT_FND = G_MAT_FND.

     WHEN 'ZSTO'.
       IF G_TABCTRL110_WA-OTH1 = 'X'.
         G_TABCTRL110_WA-MAT_FND = 0.
       ELSEIF G_TABCTRL110_WA-OTH2 = 'X' AND
              G_TABCTRL110_WA-OTH1 = ''.
         PERFORM GET_STO_HITCNT.
         DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
         G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
       ELSEIF G_TABCTRL110_WA-OTH3 = 'X' AND
              G_TABCTRL110_WA-OTH2 = ''  AND
              G_TABCTRL110_WA-OTH1 = ''.
         PERFORM GET_STO_HITCNT.
         PERFORM GET_STO_HITCNT_DEL2.
         DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
         G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
       ELSEIF G_TABCTRL110_WA-OTH4 = 'X' AND
              G_TABCTRL110_WA-OTH3 = ''  AND
              G_TABCTRL110_WA-OTH2 = ''  AND
              G_TABCTRL110_WA-OTH1 = ''.
         PERFORM GET_STO_HITCNT.
         PERFORM GET_STO_HITCNT_DEL23.
         DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
         G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
       ELSEIF G_TABCTRL110_WA-OTH4 = ''  AND
              G_TABCTRL110_WA-OTH3 = ''  AND
              G_TABCTRL110_WA-OTH2 = ''  AND
              G_TABCTRL110_WA-OTH1 = ''.
         PERFORM GET_STO_HITCNT.
         PERFORM GET_STO_HITCNT_DEL234.
         DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
         G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
       ENDIF.

     WHEN 'ZCAP'.

       PERFORM GET_CAP_HITCNT.
       DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
*       break cab_subodhk.
       G_TABLCTRL130_WA-MAT_FND = G_MAT_FND.
   ENDCASE.
 ENDFORM.                    " get_noofhits
*&---------------------------------------------------------------------*
*&      Form  get_sto_hitcnt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STO_HITCNT.
   DATA:  L_LEN3  TYPE I,
          L_SRNO3 TYPE I,
          L_CHECK3 .

   REFRESH IST_SRCHLP.
   CONCATENATE '%' G_TABCTRL110_WA-DESC1 '%' INTO DESC.
   SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
       INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
       FROM MAKT AS A
       JOIN MARA AS B
       ON A~MATNR = B~MATNR
       WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
             AND B~MTART = 'ZSTO'
             AND B~MSTAE = ''.

   LOOP AT IST_SRCHLP INTO WA_SRCHLP.
     L_LEN3 = STRLEN( WA_SRCHLP-MAKTG ).
     L_LEN3 = L_LEN3 - 1.
     L_CHECK3 = WA_SRCHLP-MAKTG+L_LEN3(1).
     IF L_CHECK3 = '*'.
       CONCATENATE WA_SRCHLP-MAKTG+0(L_LEN3) WA_SRCHLP-WRKST INTO
       WA_SRCHLP-MAKTX.
     ELSE.
       MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
     ENDIF.
     TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
     IF NOT DESC11 IS INITIAL.
       SEARCH WA_SRCHLP-MAKTX FOR DESC11.
       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                    " get_sto_hitcnt
*&---------------------------------------------------------------------*
*&      Form  get_sto_hitcnt_del234
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STO_HITCNT_DEL234.

   DATA: L4_LEN TYPE I,
         L4_CHECK TYPE C.

*  if not g_tabctrl110_wa-desc2 is initial.
*     loop at ist_srchlp into wa_srchlp.
*       move wa_srchlp-maktg to wa_srchlp-maktx.
*       TRANSLATE g_tabctrl110_wa-desc2 to upper case.
*       search wa_srchlp-maktx for g_tabctrl110_wa-desc2.
*       if sy-subrc <> 0.
*         delete ist_srchlp .
*       endif.
*     endloop.
*  endif.
*  if not g_tabctrl110_wa-desc3 is initial.
*     loop at ist_srchlp into wa_srchlp.
*       move wa_srchlp-maktg to wa_srchlp-maktx.
*       TRANSLATE g_tabctrl110_wa-desc3 to upper case.
*       search wa_srchlp-maktx for g_tabctrl110_wa-desc3.
*       if sy-subrc <> 0.
*         delete ist_srchlp .
*       endif.
*     endloop.
*   endif.
   PERFORM GET_STO_HITCNT_DEL23.
   IF NOT G_TABCTRL110_WA-DESC4 IS INITIAL.
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       L4_LEN = STRLEN( WA_SRCHLP-MAKTG ).
       L4_LEN = L4_LEN - 1.
       L4_CHECK = WA_SRCHLP-MAKTG+L4_LEN(1).
       IF L4_CHECK = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(L4_LEN) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.
       TRANSLATE G_TABCTRL110_WA-DESC4 TO UPPER CASE.
       SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC4.
       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " get_sto_hitcnt_del234
*&---------------------------------------------------------------------*
*&      Form  get_sto_hitcnt_del2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STO_HITCNT_DEL2.
   DATA: L2_LEN TYPE I,
         L2_CHECK TYPE C.

   IF NOT G_TABCTRL110_WA-DESC2 IS INITIAL.
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       L2_LEN = STRLEN( WA_SRCHLP-MAKTG ).
       L2_LEN = L2_LEN - 1.
       L2_CHECK = WA_SRCHLP-MAKTG+L2_LEN(1).
       IF L2_CHECK = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(L2_LEN) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.
       TRANSLATE G_TABCTRL110_WA-DESC2 TO UPPER CASE.
       SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC2.
       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ENDIF.
     ENDLOOP.
   ENDIF.

 ENDFORM.                    " get_sto_hitcnt_del2
*&---------------------------------------------------------------------*
*&      Form  get_sto_hitcnt_del23
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_STO_HITCNT_DEL23.
   DATA: L3_LEN TYPE I,
         L3_CHECK TYPE C.

* if not g_tabctrl110_wa-desc2 is initial.
*     loop at ist_srchlp into wa_srchlp.
*       move wa_srchlp-maktg to wa_srchlp-maktx.
*       TRANSLATE g_tabctrl110_wa-desc2 to upper case.
*       search wa_srchlp-maktx for g_tabctrl110_wa-desc2.
*       if sy-subrc <> 0.
*         delete ist_srchlp .
*       endif.
*     endloop.
*  endif.
   PERFORM GET_STO_HITCNT_DEL2.
   IF NOT G_TABCTRL110_WA-DESC3 IS INITIAL.
     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       L3_LEN = STRLEN( WA_SRCHLP-MAKTG ).
       L3_LEN = L3_LEN - 1.
       L3_CHECK = WA_SRCHLP-MAKTG+L3_LEN(1).
       IF L3_CHECK = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(L3_LEN) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.
       TRANSLATE G_TABCTRL110_WA-DESC3 TO UPPER CASE.
       SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC3.
       IF SY-SUBRC <> 0.
         DELETE IST_SRCHLP .
       ENDIF.
     ENDLOOP.
   ENDIF.
 ENDFORM.                    " get_sto_hitcnt_del23
*&---------------------------------------------------------------------*
*&      Form  update_noofhits
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM UPDATE_NOOFHITS.
   CASE ZMM_CDHD_ST-MTART.
       REFRESH IST_ZMM_CDITEM.
     WHEN 'ZSTO'.
       LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
         IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
              ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
           DESC11 = G_TABCTRL110_WA-DESC1.
           PERFORM GET_NOOFHITS.
         ENDIF.
         UPDATE ZMM_CDITEM
           SET MAT_FND = G_TABCTRL110_WA-MAT_FND
           WHERE REQNO = ZMM_CDHD_ST-REQNO
           AND   SRNO  = G_TABCTRL110_WA-SRNO.
       ENDLOOP.
     WHEN 'ZSPR'.
       LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
         IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
              ZMM_CDHD_ST-APPROVE_MRP IS INITIAL .
           PERFORM GET_NOOFHITS.
         ENDIF.
         UPDATE ZMM_CDITEM
          SET MAT_FND = G_TABLCTRL120_WA-MAT_FND
          WHERE REQNO  = ZMM_CDHD_ST-REQNO
          AND   SRNO  = G_TABLCTRL120_WA-SRNO.
       ENDLOOP.
     WHEN 'ZCAP'.
       LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
         IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
              ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
           PERFORM GET_NOOFHITS.
         ENDIF.
         UPDATE ZMM_CDITEM
         SET MAT_FND = G_TABLCTRL130_WA-MAT_FND
         WHERE REQNO  = ZMM_CDHD_ST-REQNO
         AND   SRNO  = G_TABLCTRL130_WA-SRNO.
       ENDLOOP.

   ENDCASE.

 ENDFORM.                    " update_noofhits
*&---------------------------------------------------------------------*
*&      Form  get_cap_hitcnt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM GET_CAP_HITCNT.
   DATA : L_SRNO1  LIKE SY-INDEX.
   DATA : L_LEN1   LIKE SY-INDEX.
   DATA : L_CHECK1.
   DATA : BEGIN OF WA_PARTDESC1,
            PART(40),
          END OF WA_PARTDESC1.
   DATA : IST_PARTDESC1 LIKE TABLE OF WA_PARTDESC1.
   DATA : L_DESC1(100).
   DATA : PART11(40),PART21(40),PART31(40),PART41(40).
   DATA : L_MATNR1 LIKE THEAD-TDNAME.
   DATA : IST_PARTDESC_LINES1 TYPE I.

*

   IF NOT G_TABLCTRL130_WA-DESC_FIN  IS INITIAL.
     TRANSLATE G_TABLCTRL130_WA-DESC_FIN TO UPPER CASE.
     SPLIT G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE IST_PARTDESC1.
*
     DESCRIBE TABLE IST_PARTDESC1 LINES IST_PARTDESC_LINES1.
     IF IST_PARTDESC_LINES1 > 2.
       DELETE IST_PARTDESC1 FROM 3 TO IST_PARTDESC_LINES1.
     ENDIF.
     READ TABLE IST_PARTDESC1 INTO WA_PARTDESC1 INDEX 1.

     CONCATENATE '%' WA_PARTDESC1-PART '%' INTO L_DESC1.
     CONDENSE L_DESC1 NO-GAPS.
*
     SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
     INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
     FROM MAKT AS A
     JOIN MARA AS B
     ON A~MATNR = B~MATNR
     WHERE B~MTART = 'ZCAP'  AND
     ( A~MAKTG LIKE L_DESC1 OR B~WRKST LIKE L_DESC1 ).
*
     LOOP AT IST_PARTDESC1 INTO WA_PARTDESC1.
       IF SY-TABIX = 1.
         PART11 = WA_PARTDESC1-PART.
         CONDENSE PART11 NO-GAPS.
       ELSEIF SY-TABIX = 2.
         PART21 = WA_PARTDESC1-PART.
         CONDENSE PART11 NO-GAPS.
*
       ENDIF.
     ENDLOOP.

     LOOP AT IST_SRCHLP INTO WA_SRCHLP.
       IF WA_SRCHLP-MAKTG+39(1) = '*'.
         CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
         WA_SRCHLP-MAKTX.
       ELSE.
         MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
       ENDIF.

       TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
       CHECK PART21 <> ''.
       SEARCH WA_SRCHLP-MAKTX FOR PART21.
       IF SY-SUBRC = 0.
*
       ELSE.
         DELETE  IST_SRCHLP INDEX SY-TABIX.
       ENDIF.
     ENDLOOP.
   ENDIF.
   LOOP AT IST_SRCHLP INTO WA_SRCHLP.
     IF WA_SRCHLP-MAKTG+39(1) = '*'.
       CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
       WA_SRCHLP-MAKTX.
     ELSE.
       MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
     ENDIF.
     L_SRNO1         = L_SRNO1 + 1.
     WA_SRCHLP-SRNO = L_SRNO1.
     L_MATNR1 = WA_SRCHLP-MATNR.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         ID                      = 'BEST'
         LANGUAGE                = 'E'
         NAME                    = L_MATNR1
         OBJECT                  = 'MATERIAL'
       TABLES
         LINES                   = LINES
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       WA_SRCHLP-MARK = '1'.
     ENDIF.
     MODIFY IST_SRCHLP FROM WA_SRCHLP.
   ENDLOOP.
   DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.

 ENDFORM.                    " get_cap_hitcnt
*&---------------------------------------------------------------------*
*&      Form  search_copyofdesc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM SEARCH_COPYOFDESC.
   DATA : LSTO_SRNO  LIKE SY-INDEX.
   DATA : L_LEN   LIKE SY-INDEX.
   DATA : LSTO_DESC(100).
   DATA : LSTO_MATNR LIKE THEAD-TDNAME.

   READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA INDEX
   G_CURR_LINE_110.

   IF NOT G_TABCTRL110_WA-DESC_CDCELL  IS INITIAL.

     TRANSLATE G_TABCTRL110_WA-DESC_CDCELL TO UPPER CASE.

     CONCATENATE '%' G_TABCTRL110_WA-DESC_CDCELL '%'
                 INTO LSTO_DESC .
     CONDENSE LSTO_DESC.
*
     SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST
     INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
     FROM MAKT AS A
     JOIN MARA AS B
     ON A~MATNR = B~MATNR
     WHERE            "b~mtart = 'ZSTO'  and
     ( A~MAKTG LIKE LSTO_DESC OR B~WRKST LIKE LSTO_DESC ).
*
   ENDIF.
   LOOP AT IST_SRCHLP INTO WA_SRCHLP.
     IF WA_SRCHLP-MAKTG+39(1) = '*'.
       CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
       WA_SRCHLP-MAKTX.
     ELSE.
       MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
     ENDIF.
     LSTO_SRNO      = LSTO_SRNO + 1.
     WA_SRCHLP-SRNO = LSTO_SRNO.
     LSTO_MATNR     = WA_SRCHLP-MATNR.

     CALL FUNCTION 'READ_TEXT'
       EXPORTING
         ID                      = 'BEST'
         LANGUAGE                = 'E'
         NAME                    = LSTO_MATNR
         OBJECT                  = 'MATERIAL'
       TABLES
         LINES                   = LINES
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
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       WA_SRCHLP-MARK = '1'.
     ENDIF.
     MODIFY IST_SRCHLP FROM WA_SRCHLP.
   ENDLOOP.
   DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.

 ENDFORM.                    " search_copyofdesc
*&---------------------------------------------------------------------*
*&      Form  export_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM EXPORT_DATA.

   PERFORM GET_FILENAME USING P1_FILE.

   IF G_FILE_FLAG <> 'X'.

     DATA : G_CHECK_ITAB TYPE T_TABCTRL110_A OCCURS 0.

     DATA : G_TABCTRL110_ITAB_HDR TYPE T_TABCTRL110_A OCCURS 0.
     DATA : G_TABCTRL110_ITAB_ITEM TYPE T_TABCTRL110_A OCCURS 0.
     DATA : G_TABCTRL110_WA_A TYPE T_TABCTRL110_A.

     DATA : G_TABCTRL120_ITAB_HDR TYPE T_TABCTRL120_A OCCURS 0.
     DATA : G_TABCTRL120_ITAB_ITEM TYPE T_TABCTRL120_A OCCURS 0.
     DATA : G_TABCTRL120_WA_A TYPE T_TABCTRL120_A.

     DATA : G_TABCTRL130_ITAB_HDR TYPE T_TABCTRL130_A OCCURS 0.
     DATA : G_TABCTRL130_ITAB_ITEM TYPE T_TABCTRL130_A OCCURS 0.
     DATA : G_TABCTRL130_WA_A TYPE T_TABCTRL130_A.

     G_TABCTRL110_WA_A-SRNO     = 'Srno'.
     G_TABCTRL110_WA_A-REJ_FLG  = 'Rejflg'.
     G_TABCTRL110_WA_A-COMP_FLG = 'Errflg'.
     G_TABCTRL110_WA_A-MAT_FND  = 'Hits'.
     G_TABCTRL110_WA_A-OTH1  = 'Oth1'.
     G_TABCTRL110_WA_A-OTH2  = 'Oth2'.
     G_TABCTRL110_WA_A-OTH3  = 'Oth3'.
     G_TABCTRL110_WA_A-OTH4  = 'Oth4'.

     G_TABCTRL110_WA_A-DESC2  = 'Sub attr 1'.
     G_TABCTRL110_WA_A-DESC3  = 'Sub attr 2'.
     G_TABCTRL110_WA_A-DESC4  = 'Sub attr 3'.
     G_TABCTRL110_WA_A-USER_DESC  = 'Addl Description'.
     G_TABCTRL110_WA_A-DESC_FIN   = 'Material Description'.
     G_TABCTRL110_WA_A-UOM     = 'UOM'.
     G_TABCTRL110_WA_A-HAZ_FLG = 'Hazardous'.
     G_TABCTRL110_WA_A-GRWGT   = 'Gross Wt'.

     G_TABCTRL110_WA_A-WTUNIT  = 'Wt Unit'.
     G_TABCTRL110_WA_A-GRVOL   = 'Gross Vol'.
     G_TABCTRL110_WA_A-VOLUNIT = 'Vol Unit'.
     G_TABCTRL110_WA_A-SHLF_LIFE1 = 'Shelf life'.
     G_TABCTRL110_WA_A-ENVMAT     = 'Env Mat'.

     G_TABCTRL110_WA_A-DMS    = 'DMS'.
     G_TABCTRL110_WA_A-CODBY  = 'Changed by'.
     G_TABCTRL110_WA_A-CODDT  = 'Changed date'.

     G_TABCTRL110_WA_A-CODCRBY  = 'Codified by'.
     G_TABCTRL110_WA_A-CODCRDT  = 'Codified date'.
     G_TABCTRL110_WA_A-MATGP  = 'Mat Group'.
     G_TABCTRL110_WA_A-DSFLAG = 'Det spec flag'.

     G_TABCTRL110_WA_A-MATCODE = 'Matcode'.
     G_TABCTRL110_WA_A-DESC1   = 'Main Mat Attribute'.

     APPEND G_TABCTRL110_WA_A TO G_TABCTRL110_ITAB_HDR.

     G_TABCTRL120_WA_A-SRNO     = 'Srno'.
     G_TABCTRL120_WA_A-MATCODE = 'Matcode'.
     G_TABCTRL120_WA_A-REJ_FLG  = 'Rejflg'.
     G_TABCTRL120_WA_A-COMP_FLG = 'Errflg'.
     G_TABCTRL120_WA_A-MAT_FND  = 'Hits'.

     G_TABCTRL120_WA_A-DESC_FIN  = 'Material Description'.
     G_TABCTRL120_WA_A-UOM  = 'UOM'.
     G_TABCTRL120_WA_A-CAP_CODE  = 'Capital code'.
     G_TABCTRL120_WA_A-CAP_NAME  = 'Capital item desc'.
     G_TABCTRL120_WA_A-SUBASS  = 'Sub Ass'.
     G_TABCTRL120_WA_A-OTH_MDL  = 'Oth model'.
     G_TABCTRL120_WA_A-MDLNO  = 'Model No'.
     G_TABCTRL120_WA_A-MANU  = 'Orig eqpt mnfr'.

     G_TABCTRL120_WA_A-HAZ_FLG  = 'Hazardous'.
     G_TABCTRL120_WA_A-GRWGT  = 'Gross Wt'.

     G_TABCTRL120_WA_A-GRWGT  = 'Gross Wt'.
     G_TABCTRL120_WA_A-WTUNIT  = 'Wt Unit'.
     G_TABCTRL120_WA_A-GRVOL  = 'Gross Vol'.
     G_TABCTRL120_WA_A-VOLUNIT  = 'Vol unit'.
     G_TABCTRL120_WA_A-ENVMAT  = 'Env Mat'.
     G_TABCTRL120_WA_A-SHLF_LIFE1  = 'Shelf life'.

     G_TABCTRL120_WA_A-DMS  = 'DMS'.
     G_TABCTRL120_WA_A-CODBY  = 'Changed by'.
     G_TABCTRL120_WA_A-CODDT  = 'Changed date'.

     G_TABCTRL120_WA_A-CODCRBY  = 'Codified by'.
     G_TABCTRL120_WA_A-CODCRDT  = 'Codified date'.
     G_TABCTRL120_WA_A-MATGP  = 'Mat Group'.
     G_TABCTRL120_WA_A-DSFLAG = 'Det spec flag'.

     G_TABCTRL120_WA_A-PARTNO = 'Manu Part No'.

     APPEND G_TABCTRL120_WA_A TO G_TABCTRL120_ITAB_HDR.

     G_TABCTRL130_WA_A-SRNO     = 'Srno'.
     G_TABCTRL130_WA_A-MATCODE = 'Matcode'.
     G_TABCTRL130_WA_A-REJ_FLG  = 'Rejflg'.
     G_TABCTRL130_WA_A-COMP_FLG = 'Errflg'.
     G_TABCTRL130_WA_A-MAT_FND  = 'Hits'.

     G_TABCTRL130_WA_A-DESC_FIN  = 'Capital Item Description'.
     G_TABCTRL130_WA_A-DESC_CDCELL  = 'Suggested Description'.

     G_TABCTRL130_WA_A-UOM  = 'UOM'.
     G_TABCTRL130_WA_A-MATCOST  = 'Appx matcost Rs'.
     G_TABCTRL130_WA_A-MATCATG  = 'User/Group'.
     G_TABCTRL130_WA_A-MATLOC  = 'Place of use'.
     G_TABCTRL130_WA_A-WRKNG_LIFE  = 'Life in years'.
     G_TABCTRL130_WA_A-SPA_GRP  = 'Spare grp'.

     G_TABCTRL130_WA_A-HAZ_FLG  = 'Hazardous'.
     G_TABCTRL130_WA_A-GRWGT  = 'Gross Wt'.

     G_TABCTRL130_WA_A-GRWGT  = 'Gross Wt'.
     G_TABCTRL130_WA_A-WTUNIT  = 'Wt Unit'.
     G_TABCTRL130_WA_A-GRVOL  = 'Gross Vol'.
     G_TABCTRL130_WA_A-VOLUNIT  = 'Vol unit'.
     G_TABCTRL130_WA_A-ENVMAT  = 'Env Mat'.
     G_TABCTRL130_WA_A-SHLF_LIFE1  = 'Shelf life'.

     G_TABCTRL130_WA_A-DMS  = 'DMS'.
     G_TABCTRL130_WA_A-CODBY  = 'Changed by'.
     G_TABCTRL130_WA_A-CODDT  = 'Changed date'.

     G_TABCTRL130_WA_A-CODCRBY  = 'Codified by'.
     G_TABCTRL130_WA_A-CODCRDT  = 'Codified date'.
     G_TABCTRL130_WA_A-DSFLAG = 'Det spec flag'.

     APPEND G_TABCTRL130_WA_A TO G_TABCTRL130_ITAB_HDR.

***************************************************
     " Begin of <RD1K960036>.
*CALL FUNCTION 'WS_UPLOAD'
* EXPORTING
**   CODEPAGE                      = ' '
*   FILENAME                      = p1_file
*   FILETYPE                      = 'DAT'
**   HEADLEN                       = ' '
**   LINE_EXIT                     = ' '
**   TRUNCLEN                      = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   DAT_D_FORMAT                  = ' '
** IMPORTING
**   FILELENGTH                    =
*  TABLES
*    DATA_TAB                      = g_check_itab
* EXCEPTIONS
*   CONVERSION_ERROR              = 1
*   FILE_OPEN_ERROR               = 2
*   FILE_READ_ERROR               = 3
*   INVALID_TYPE                  = 4
*   NO_BATCH                      = 5
*   UNKNOWN_ERROR                 = 6
*   INVALID_TABLE_WIDTH           = 7
*   GUI_REFUSE_FILETRANSFER       = 8
*   CUSTOMER_ERROR                = 9
*   OTHERS                        = 10
*          .
     CONSTANTS: G_C_ASC TYPE CHAR10 VALUE 'ASC'.

     DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
            L_FILETABLE  TYPE  FILE_TABLE,
            L_RC         TYPE  I,
            L_P_DEF_FILE TYPE  STRING,
            L_P_FILE     TYPE  STRING,
            L_USR_ACT    TYPE  I.
     L_P_FILE = P1_FILE.

     CALL FUNCTION 'GUI_UPLOAD'
       EXPORTING
         FILENAME                = L_P_FILE
         FILETYPE                = G_C_ASC
         HAS_FIELD_SEPARATOR     = 'X'
       TABLES
         DATA_TAB                = G_CHECK_ITAB
       EXCEPTIONS
         FILE_OPEN_ERROR         = 1
         FILE_READ_ERROR         = 2
         NO_BATCH                = 3
         GUI_REFUSE_FILETRANSFER = 4
         INVALID_TYPE            = 5
         NO_AUTHORITY            = 6
         UNKNOWN_ERROR           = 7
         BAD_DATA_FORMAT         = 8
         HEADER_NOT_ALLOWED      = 9
         SEPARATOR_NOT_ALLOWED   = 10
         HEADER_TOO_LONG         = 11
         UNKNOWN_DP_ERROR        = 12
         ACCESS_DENIED           = 13
         DP_OUT_OF_MEMORY        = 14
         DISK_FULL               = 15
         DP_TIMEOUT              = 16
         OTHERS                  = 17.
     " End of <RD1K960036>.
     IF SY-SUBRC = 0.
       MESSAGE I089(ZMM_OTH) WITH P1_FILE.
     ELSE.

***************************************************

       CASE ZMM_CDHD_ST-MTART.

           DATA : L_FILE1 TYPE STRING.
           L_FILE1 = L_P_FILE.

         WHEN 'ZSTO'.

           LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.

             MOVE-CORRESPONDING G_TABCTRL110_WA TO G_TABCTRL110_WA_A.

             APPEND G_TABCTRL110_WA_A TO G_TABCTRL110_ITAB_ITEM.

           ENDLOOP.
           " Begin of <RD1K960036>.


*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
**       MODE                          = ' '
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*
*      TABLES
*        DATA_TAB                      = g_TABCTRL110_itab_hdr
*
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
*       OTHERS                        = 10.

           CALL FUNCTION 'GUI_DOWNLOAD'
             EXPORTING
               FILENAME                = L_FILE1
               FILETYPE                = 'DAT'
             TABLES
               DATA_TAB                = G_TABCTRL110_ITAB_HDR
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

           " End of <RD1K960036>.

           IF SY-SUBRC = 0.
             " Begin of <RD1K960036>.
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
*       MODE                          = 'A'
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = g_TABCTRL110_itab_item
**       FIELDNAMES                    =
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
*              .

             CALL FUNCTION 'GUI_DOWNLOAD'
               EXPORTING
                 FILENAME                = L_FILE1
                 FILETYPE                = 'DAT'
                 APPEND                  = 'X'
               TABLES
                 DATA_TAB                = G_TABCTRL110_ITAB_ITEM
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

             " End of <RD1k960036>.
             IF SY-SUBRC = 0.
               MESSAGE I085(ZMM_OTH) WITH P1_FILE.
             ENDIF.

           ELSE.

             IF SY-SUBRC = 1.
               MESSAGE I086(ZMM_OTH) WITH 'File open error'.
             ELSEIF SY-SUBRC = 2.
               MESSAGE I086(ZMM_OTH) WITH 'File write error'.
             ELSE.
               MESSAGE I086(ZMM_OTH).
             ENDIF.

           ENDIF.

           CLEAR : G_TABCTRL110_WA_A, G_TABCTRL110_ITAB_ITEM.
           REFRESH G_TABCTRL110_ITAB_ITEM.

         WHEN 'ZSPR'.

           LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.

             MOVE-CORRESPONDING G_TABLCTRL120_WA TO G_TABCTRL120_WA_A.

             APPEND G_TABCTRL120_WA_A TO G_TABCTRL120_ITAB_ITEM.

           ENDLOOP.
           " Begin of <RD1K960036>.
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
**       MODE                          = ' '
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = g_TABCTRL120_itab_hdr
*
*      EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       NO_BATCH                      = 5
*       UNKNOWN_ERROR                 = 6
*       INVALID_TABLE_WIDTH           = 7
*       GUI_REFUSE_FILETRANSFER       = 8
*       CUSTOMER_ERROR                = 9
*       OTHERS                        = 10.

           CALL FUNCTION 'GUI_DOWNLOAD'
             EXPORTING
               FILENAME                = L_FILE1
               FILETYPE                = 'DAT'
*        APPEND                  = 'X'
             TABLES
               DATA_TAB                = G_TABCTRL120_ITAB_HDR
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
           .
           " End of <RD1K960036>.
           IF SY-SUBRC = 0.
             " Begin of <RD1K960036>.
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
*       MODE                          = 'A'
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = g_TABCTRL120_itab_item
**       FIELDNAMES                    =
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
*              .
             CALL FUNCTION 'GUI_DOWNLOAD'
               EXPORTING
                 FILENAME                = L_FILE1
                 FILETYPE                = 'DAT'
                 APPEND                  = 'X'
               TABLES
                 DATA_TAB                = G_TABCTRL120_ITAB_ITEM
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
             .
             " End of <RD1K960036>.
             IF SY-SUBRC = 0.
               MESSAGE I085(ZMM_OTH) WITH P1_FILE.
             ENDIF.

           ELSE.

             IF SY-SUBRC = 1.
               MESSAGE I086(ZMM_OTH) WITH 'File open error'.
             ELSEIF SY-SUBRC = 2.
               MESSAGE I086(ZMM_OTH) WITH 'File write error'.
             ELSE.
               MESSAGE I086(ZMM_OTH).
             ENDIF.

           ENDIF.

           CLEAR : G_TABCTRL120_WA_A, G_TABCTRL120_ITAB_ITEM.
           REFRESH G_TABCTRL120_ITAB_ITEM.


         WHEN 'ZCAP'.

           LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.

             MOVE-CORRESPONDING G_TABLCTRL130_WA TO G_TABCTRL130_WA_A.

             APPEND G_TABCTRL130_WA_A TO G_TABCTRL130_ITAB_ITEM.

           ENDLOOP.
           " Begin of <RD1K960036>.
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
**       MODE                          = ' '
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = g_TABCTRL130_itab_hdr
*
*      EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       NO_BATCH                      = 5
*       UNKNOWN_ERROR                 = 6
*       INVALID_TABLE_WIDTH           = 7
*       GUI_REFUSE_FILETRANSFER       = 8
*       CUSTOMER_ERROR                = 9
*       OTHERS                        = 10.
*  .
           CALL FUNCTION 'GUI_DOWNLOAD'
                 EXPORTING
                   FILENAME                = L_FILE1
                   FILETYPE                = 'DAT'
*        APPEND                  = 'X'
                 TABLES
                   DATA_TAB                = G_TABCTRL130_ITAB_HDR
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
           .
           " End of <RD1K960036>.
           IF SY-SUBRC = 0.
             " Begin of <RD1K960036>.
*    CALL FUNCTION 'WS_DOWNLOAD'
*     EXPORTING
**       BIN_FILESIZE                  = ' '
**       CODEPAGE                      = ' '
*       FILENAME                      = p1_file
*       FILETYPE                      = 'DAT'
*       MODE                          = 'A'
**       WK1_N_FORMAT                  = ' '
**       WK1_N_SIZE                    = ' '
**       WK1_T_FORMAT                  = ' '
**       WK1_T_SIZE                    = ' '
**       COL_SELECT                    = ' '
**       COL_SELECTMASK                = ' '
**       NO_AUTH_CHECK                 = ' '
**     IMPORTING
**       FILELENGTH                    =
*      TABLES
*        DATA_TAB                      = g_TABCTRL130_itab_item
**       FIELDNAMES                    =
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
*              .
             CALL FUNCTION 'GUI_DOWNLOAD'
               EXPORTING
                 FILENAME                = L_FILE1
                 FILETYPE                = 'DAT'
                 APPEND                  = 'X'
               TABLES
                 DATA_TAB                = G_TABCTRL130_ITAB_ITEM
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
             .
             " End of <RD1K960036>.
             IF SY-SUBRC = 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*               MESSAGE I085(ZMM_OTH) WITH P1_FILE.

               CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                 EXPORTING
                   TITEL     = 'Information'
                   TEXTLINE1 = 'Data copied to file'
                   TEXTLINE2 = P1_FILE.


             ENDIF.

           ELSE.

             IF SY-SUBRC = 1.
               MESSAGE I086(ZMM_OTH) WITH 'File open error'.
             ELSEIF SY-SUBRC = 2.
               MESSAGE I086(ZMM_OTH) WITH 'File write error'.
             ELSE.
               MESSAGE I086(ZMM_OTH).
             ENDIF.

           ENDIF.

           CLEAR : G_TABCTRL130_WA_A, G_TABCTRL130_ITAB_ITEM.
           REFRESH G_TABCTRL130_ITAB_ITEM.

       ENDCASE.

     ENDIF.

   ELSE.
     CLEAR G_FILE_FLAG.
   ENDIF.

 ENDFORM.                    " export_data
*&---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P1_FILE  text
*----------------------------------------------------------------------*
 FORM GET_FILENAME USING   L_FILE1.
*Begin of <RD1K960036>.
*CALL FUNCTION 'WS_FILENAME_GET'
*       EXPORTING
*            DEF_PATH         = 'C:\'
*            MASK             = ',*.txt.'
*       IMPORTING
*            FILENAME         = l_file1
*       EXCEPTIONS
*            INV_WINSYS       = 1
*            NO_BATCH         = 2
*            SELECTION_CANCEL = 3
*            SELECTION_ERROR  = 4
*            OTHERS           = 5.
*
*         IF SY-SUBRC <> 0.
*      message i107(zhelp).
*      g_file_flag = 'X'.
*  ENDIF.

*DATA:lt_files TYPE filetable,
*     l_file  TYPE file_table,
*     l_title TYPE string,
*     l_subrc TYPE i,
*     l_def_file TYPE string.
*
*l_def_file = ' '.
*
*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*         window_title     = l_title
*         default_filename = l_def_file
*         file_filter      = ' '
*         initial_directory = 'C: \'
*    CHANGING
*         File_table = lt_files
*         rc = l_subrc
* EXCEPTIONS
*  file_open_dialog_failed = 1
*  cntl_error              = 2
*  error_no_gui            = 3
*  OTHERS                  = 4.
*  CHECK sy-subrc = 0.
*
*  LOOP AT lt_files INTO l_file.
*   l_file1 = l_file.
*    EXIT.
*  ENDLOOP.
*
*
*IF SY-SUBRC <> 0.
*      message i107(zhelp).
*      g_file_flag = 'X'.
*  ENDIF.

*End of <RD1K960036>.



   DATA: L_DEFAULT_FILE_NAME TYPE STRING,
       L_INITIAL_DIRECTORY TYPE STRING,
       L_FILENAME          TYPE STRING,
       L_PATH              TYPE STRING,
       L_FULL_PATH         TYPE STRING,
       L_USER_ACTION       TYPE I.

   CLEAR: L_DEFAULT_FILE_NAME,
          L_INITIAL_DIRECTORY.

*   L_DEFAULT_FILE_NAME = 'C:\Output'.
*   L_INITIAL_DIRECTORY = 'C:\'.

   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
     EXPORTING
       DEFAULT_FILE_NAME    = L_DEFAULT_FILE_NAME
       INITIAL_DIRECTORY    = L_INITIAL_DIRECTORY
     CHANGING
       FILENAME             = L_FILENAME
       PATH                 = L_PATH
       FULLPATH             = L_FULL_PATH
       USER_ACTION          = L_USER_ACTION
     EXCEPTIONS
       CNTL_ERROR           = 1
       ERROR_NO_GUI         = 2
       NOT_SUPPORTED_BY_GUI = 3
       OTHERS               = 4.
   L_FILE1 = L_FULL_PATH.

 ENDFORM.                    " get_filename
*&---------------------------------------------------------------------*
*&      Form  ATTACH_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ATTACH_FILES .

*  IF ZMM_CDHD_ST-REQNO IS INITIAL.
*   MESSAGE 'enter request no' TYPE 'E'.
*   ENDIF.

clear g_att_files_wa.
refresh g_att_files.

   g_att_files_wa-LOGSYS  = ZMM_CDHD_ST-REQNO.
   g_att_files_wa-objtype = 'IMAC'.
   g_att_files_wa-objkey  = '01'.

   append g_att_files_wa to g_att_files.

   CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
     EXPORTING
       ATTACHMENT_DATA     = ''
       ATTACHMENT_TYPE     = 'DOC'
     TABLES
       APPLICATION_OBJECTS = g_att_files.
ENDFORM.                    " ATTACH_FILES
*&---------------------------------------------------------------------*
*&      Form  LIST_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LIST_FILES .
  clear g_att_files_wa.

   g_att_files_wa-LOGSYS = ZMM_CDHD_ST-REQNO.
   g_att_files_wa-objtype = 'IMAC'.
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
   FUNCTION                 = ' '
  TABLES
      FUNC_EXCLUDE              = exclude_tab.
ENDFORM.                    " LIST_FILES
*&---------------------------------------------------------------------*
*&      Form  DISP_PROCESS_GUIDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISP_PROCESS_GUIDE .

*  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
*  DATA : wa_att_files LIKE swotobjid.
*  DATA L_OBJ TYPE SOOD4-OBJNO.

  wa_att_files-logsys  = 'AC'        .
  wa_att_files-objtype = 'IMAC'.
  wa_att_files-objkey  = 'AC921'.

  REFRESH ist_exclude_tab[].
  MOVE 'ENTR' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CHNG' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CREA' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'DELE' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'IMPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'EXPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'OLNK' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'PRIN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'COPY' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'HGEN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'REFL' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'MOVE' TO ist_exclude_tab. APPEND ist_exclude_tab.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files
    TABLES
      func_exclude       = ist_exclude_tab.
ENDFORM.                    " DISP_PROCESS_GUIDE
*&---------------------------------------------------------------------*
*&      Form  DETAILS_ONDBLCLK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DETAILS_ONDBLCLK .
 CALL FUNCTION 'SO_ADDRESS_SHOW'
   EXPORTING
*     DLI_OWNER                        = ' '
*     OWNER                            = ' '
     user                             = l_user_dblclk
   EXCEPTIONS
     parameter_error                  = 1
     user_not_exist                   = 2
     x_error                          = 3
     operation_no_authorization       = 4
     OTHERS                           = 5
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DETAILS_ONDBLCLK
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS_TO_REQN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEND_SMS_TO_REQN .
""""""""code added by lipsy on 10.09.2013 for sending sms to requisitioner.
   REFRESH :IT_9205.

    CLEAR:R_USER_SMS.
    SELECT SINGLE REQCPF INTO R_USER_SMS FROM ZMM_CDHD
    WHERE REQNO = ZMM_CDHD_ST-REQNO.


 SELECT * FROM  PA9205 APPENDING
      CORRESPONDING FIELDS OF TABLE IT_9205
      WHERE Pernr = R_USER_SMS AND
            Subty = '01' AND
            Endda = '99991231' .

IF SY-SUBRC = 0.          ""  PHONE NO. OF REQUIRED requisitioner HAS BEEN FOUND

  SORT  IT_9205 By Begda DESCENDING  .
  CLEAR   :Wa_9205 .
  READ TABLE It_9205 INTO Wa_9205 INDEX 1  .

  clear MOB_NO.
  CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO  MOB_NO .
******END OF FINDING PHONE NO. OF Requistioner***********************************

****SENDING SMS TO requisitioner**************************************************************************
   CLEAR: wf_string ,  L_TEXT1 ,L_TEXT2 , L_TEXT3 , L_TEXT4 ,  L_TEXT5 .

    L_TEXT1 = 'Material Code Request Number :'.
    L_TEXT2 =  ZMM_CDHD_ST-REQNO.
    L_TEXT3 = 'is completed.'.
    L_TEXT4 = 'Please'.
    L_TEXT5 = 'Check the request for further details. '.


       CONCATENATE L_TEXT1 L_TEXT2  L_TEXT3 L_TEXT4 L_TEXT5 INTO sms_text SEPARATED BY space.
    CONCATENATE
    'http://10.205.48.190:13013/cgi-bin/sendsms?'
    'username=ongc&password=ongc12&from=ONGC&to='
*  919968282246+919968282468&text=Hellow+Test+4&remLen=147
* 'http://www.webservicex.net/SendSMS.asmx/SendSMSToIndia?MobileNumber='
    mob_no "m_no
   '&text='
   sms_text
   '&remLen=180'
    INTO
    wf_string .

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

    REFRESH result_tab .
   SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab.
****END OF SENDING SMS TO requistioner**************************************************************
***Added for memory overflow problem
   CALL METHOD http_client->close( ).
ELSE.
  ENDIF.

  """""""" end of addition  by lipsy on 10.09.2013 for sending sms to requisitioner RD1K982397.
ENDFORM.                    " SEND_SMS_TO_REQN
*&---------------------------------------------------------------------*
*&      Form  GET_TEL_CREATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TEL_CREATION .

"""""""""added by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.

 if sy-tcode = 'ZMM_IMAC'.
 case g_mode.

    when 'CRE'.

      loop at screen.
        if screen-name = 'ZMM_CDHD_ST-TEL' .
          screen-input = 0.
          modify screen.
         ENDIF.
     ENDLOOP.


refresh:IT_9205.
  SELECT * FROM  PA9205 INTO
   CORRESPONDING FIELDS OF TABLE IT_9205
   WHERE Pernr = sy-uname  AND
         Subty = '01' AND
         Endda = '99991231' .

       IF SY-SUBRC = 0.          "" It means PHONE NO. has been found

    SORT  IT_9205 By Begda DESCENDING .

    CLEAR:Wa_9205.
    READ TABLE It_9205 INTO Wa_9205 INDEX 1  .
    zmm_cdhd_st-tel = Wa_9205-ZPHONE+1(10).

     endif.


 ENDCASE.

  endif.

  """"""""""""END OF addition  by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.

ENDFORM.                    " GET_TEL_CREATION
