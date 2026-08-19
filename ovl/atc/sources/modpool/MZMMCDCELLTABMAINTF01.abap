*--- MAIN PROGRAM: MZMMCDCELLTABMAINTF01 ---*
***INCLUDE MZMMCDCELLTABMAINTF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

************************************************************************
*  Date            Transport      USERID        Description
* 25/09/2008      <RD1K960036>    SAB_SUMODH
*
*      1) Literal Error Resolved in Line 348
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
      IF tabscr_cd-activetab = 'CDF'.
          g_sav110 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'MDF'.
             g_sav120 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'DIC'.
             g_sav130 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'MDL'.
             g_sav140 = 'Y'.
      ENDIF.
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                         P_TABLE_NAME.
      CLEAR P_OK.

     WHEN 'DELE'.                     "delete row
      IF tabscr_cd-activetab = 'CDF'.
         perform add_delitem_cdf.
         g_sav110 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'MDF'.
         perform add_delitem_mdf.
         g_sav120 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'DIC'.
         perform add_delitem_dic.
         g_sav130 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'MDL'.
         perform add_delitem_mdl.
         g_sav140 = 'Y'.
      ENDIF.
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
     WHEN 'CP'.
       IF tabscr_cd-activetab = 'CDF'.
         perform add_cpitem_cdf.
         g_sav110 = 'Y'.
        if not g_itab_cp110 is initial.
          append lines of g_itab_cp110 to g_tct110_itab.
        endif.
      ELSEIF tabscr_cd-activetab = 'MDF'.
         perform add_cpitem_mdf.
         g_sav120 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'DIC'.
         perform add_cpitem_dic.
         g_sav130 = 'Y'.
      ELSEIF tabscr_cd-activetab = 'MDL'.
         perform add_cpitem_mdl.
         g_sav140 = 'Y'.
      ENDIF.
      CLEAR P_OK.
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
*&      Form  make_select_statement
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM make_select_statement.
 " Begin of <RD1K960036>.

*  Concatenate 'Select * from ZMM_MODIFIER into corresponding fields of
*  table g_TCT120_itab' '' into g_selstr.

 Concatenate 'Select * from ZMM_MODIFIER into corresponding fields of table g_TCT120_itab' '' into g_selstr.
  "End of <RD1K960036>.

 If not zmm_modifier_st-matgrp is initial.
   concatenate g_selstr ' where matgrp = zmm_modifier_st-matgrp'
   into g_selstr.
 elseif not zmm_modifier_st-desc1 is initial.
   search g_selstr for 'where'.
   if sy-subrc = 0.
     concatenate g_selstr ' and desc1 = zmm_modifier_st-desc1'
     into g_selstr.
   else.
     concatenate g_selstr ' where desc1 = zmm_modifier_st-desc1'
     into g_selstr.
   endif.
 elseif not zmm_modifier_st-desc2 is initial.
   search g_selstr for 'where'.
   if sy-subrc = 0.
     concatenate g_selstr ' and desc2 = zmm_modifier_st-desc2'
     into g_selstr.
   else.
     concatenate g_selstr ' where desc2 = zmm_modifier_st-desc2'
     into g_selstr.
   endif.
 elseif not zmm_modifier_st-desc3 is initial.
   search g_selstr for 'where'.
   if sy-subrc = 0.
     concatenate g_selstr ' and desc3 = zmm_modifier_st-desc3'
     into g_selstr.
   else.
     concatenate g_selstr ' where desc3 = zmm_modifier_st-desc3'
     into g_selstr.
   endif.
 elseif not zmm_modifier_st-desc4 is initial.
   search g_selstr for 'where'.
   if sy-subrc = 0.
     concatenate g_selstr ' and desc4 = zmm_modifier_st-desc4'
     into g_selstr.
   else.
     concatenate g_selstr ' where desc4 = zmm_modifier_st-desc4'
     into g_selstr.
   endif.
 endif.
 concatenate g_selstr '.' into g_selstr.


ENDFORM.                    " make_select_statement
*&---------------------------------------------------------------------*
*&      Form  add_delitem_mdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_delitem_mdf.
   loop at g_TCT120_itab into g_TCT120_wa.
     if g_TCT120_wa-flag = 'X'.
       append g_TCT120_wa to g_itab_del120.
     endif.
   endloop.
   clear g_TCT120_wa.
ENDFORM.                    " add_delitem_mdf
*&---------------------------------------------------------------------*
*&      Form  add_delitem_dic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_delitem_dic.
  loop at g_TCT130_itab into g_TCT130_wa.
     if g_TCT130_wa-flag = 'X'.
       append g_TCT130_wa to g_itab_del130.
     endif.
   endloop.
   clear g_TCT130_wa.
ENDFORM.                    " add_delitem_dic

FORM add_delitem_cdf.
  loop at g_TCT110_itab into g_TCT110_wa.
     if g_TCT110_wa-flag = 'X'.
       append g_TCT110_wa to g_itab_del110.
     endif.
   endloop.
   clear g_TCT110_wa.
ENDFORM.                    " add_delitem_cdf
*&---------------------------------------------------------------------*
*&      Form  add_delitem_mdl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_delitem_mdl.
  loop at g_TCT140_itab into g_TCT140_wa.
     if g_TCT140_wa-flag = 'X'.
       append g_TCT140_wa to g_itab_del140.
     endif.
  endloop.
  clear g_TCT140_wa.
ENDFORM.                    " add_delitem_mdl
*&---------------------------------------------------------------------*
*&      Form  add_cpitem_cdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cpitem_cdf.
 refresh g_itab_cp110[].
 loop at g_TCT110_itab into g_TCT110_wa.
     if g_TCT110_wa-flag = 'X'.
       append g_TCT110_wa to g_itab_cp110.
     endif.
   endloop.
   clear g_TCT110_wa.
ENDFORM.                    " add_cpitem_cdf
*&---------------------------------------------------------------------*
*&      Form  add_cpitem_mdf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cpitem_mdf.
 refresh g_itab_cp120[].
 loop at g_TCT120_itab into g_TCT120_wa.
     if g_TCT120_wa-flag = 'X'.
       append g_TCT120_wa to g_itab_cp120.
     endif.
   endloop.
   clear g_TCT120_wa.
ENDFORM.                    " add_cpitem_mdf
*&---------------------------------------------------------------------*
*&      Form  add_cpitem_dic
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cpitem_dic.
 loop at g_TCT130_itab into g_TCT130_wa.
     if g_TCT110_wa-flag = 'X'.
       append g_TCT130_wa to g_itab_cp130.
     endif.
   endloop.
   clear g_TCT130_wa.
ENDFORM.                    " add_cpitem_dic
*&---------------------------------------------------------------------*
*&      Form  add_cpitem_mdl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_cpitem_mdl.
 loop at g_TCT140_itab into g_TCT140_wa.
     if g_TCT140_wa-flag = 'X'.
       append g_TCT140_wa to g_itab_cp140.
     endif.
   endloop.
   clear g_TCT140_wa.
ENDFORM.                    " add_cpitem_mdl
