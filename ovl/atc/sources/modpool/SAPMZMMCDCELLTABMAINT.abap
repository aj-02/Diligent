*--- MAIN PROGRAM: SAPMZMMCDCELLTABMAINT ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMMCDCELLTABMAINT                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 25/09/2008      <RD1K960036>    SAB_SUMODH
*
*      1)Literals Error Corrected in INCLUDE MZMMCDCELLTABMAINTF01
************************************************************************


INCLUDE MZMMCDCELLTABMAINTTOP                   .                      "

* INCLUDE MZMMCDCELLTABMAINTO01                   .                    *
* INCLUDE MZMMCDCELLTABMAINTI01                   .                    *
* INCLUDE MZMMCDCELLTABMAINTF01                   .                    *

* Includes inserted by Screen Painter Wizard. DO NOT CHANGE THIS LINE!
INCLUDE MZMMCDCELLTABMAINTO01 .
INCLUDE MZMMCDCELLTABMAINTI01 .
INCLUDE MZMMCDCELLTABMAINTF01 .

*--- INCLUDE: %_CCXTAB ---*
TYPE-POOL CXTAB .

TYPES:
       CXTAB_COLUMN type scxtab_column,
       CXTAB_CONTROL type scxtab_control,
       CXTAB_TABSTRIP type scxtab_tabstrip.

*--- INCLUDE: MZMMCDCELLTABMAINTF01 ---*
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

*--- INCLUDE: MZMMCDCELLTABMAINTI01 ---*
***INCLUDE MZMMCDCELLTABMAINTI01 .
*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: modify table
module TCT110_modify input.
  move-corresponding ZMM_CDCODIFIER to g_TCT110_wa.
  modify g_TCT110_itab
    from g_TCT110_wa
    index TCT110-current_line.
  if sy-subrc <> 0.
    append g_TCT110_wa to g_TCT110_itab.
  endif.
  g_sav110 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: mark table
module TCT110_mark input.
  if TCT110-line_sel_mode = 1 and
     g_TCT110_wa-flag = 'X'.
     loop at g_TCT110_itab into g_TCT110_wa
       where flag = 'X'.
       g_TCT110_wa-flag = ''.
       modify g_TCT110_itab
         from g_TCT110_wa
         transporting flag.
     endloop.
     g_TCT110_wa-flag = 'X'.
  endif.
  modify g_TCT110_itab
    from g_TCT110_wa
    index TCT110-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: process user command
module TCT110_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT110'
                              'G_TCT110_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: modify table
module TCT120_modify input.
  move-corresponding ZMM_MODIFIER to g_TCT120_wa.
  move sy-uname to g_tct120_wa-created_by.
  move sy-datum to g_tct120_wa-create_date.
  modify g_TCT120_itab
    from g_TCT120_wa
    index TCT120-current_line.
  if sy-subrc <> 0.
    append g_TCT120_wa to g_TCT120_itab.
  endif.
  g_sav120 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: mark table
module TCT120_mark input.
  if TCT120-line_sel_mode = 1 and
     g_TCT120_wa-flag = 'X'.
     loop at g_TCT120_itab into g_TCT120_wa
       where flag = 'X'.
       g_TCT120_wa-flag = ''.
       modify g_TCT120_itab
         from g_TCT120_wa
         transporting flag.
     endloop.
     g_TCT120_wa-flag = 'X'.
  endif.
  modify g_TCT120_itab
    from g_TCT120_wa
    index TCT120-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: process user command
module TCT120_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT120'
                              'G_TCT120_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: modify table
module TCT130_modify input.
  move-corresponding TER15 to g_TCT130_wa.
  move sy-uname to g_tct130_wa-cr_user.
  move sy-datum to g_tct130_wa-datemod.
  modify g_TCT130_itab
    from g_TCT130_wa
    index TCT130-current_line.
  if sy-subrc <> 0.
    append g_TCT130_wa to g_TCT130_itab.
  endif.
  g_sav130 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: mark table
module TCT130_mark input.
  if TCT130-line_sel_mode = 1 and
     g_TCT130_wa-flag = 'X'.
     loop at g_TCT130_itab into g_TCT130_wa
       where flag = 'X'.
       g_TCT130_wa-flag = ''.
       modify g_TCT130_itab
         from g_TCT130_wa
         transporting flag.
     endloop.
     g_TCT130_wa-flag = 'X'.
  endif.
  modify g_TCT130_itab
    from g_TCT130_wa
    index TCT130-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: process user command
module TCT130_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT130'
                              'G_TCT130_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
 Case okcode100.
   When 'BAC' or 'CAN' or 'EXT'.
   clear: g_sav110,g_sav120,g_sav130,g_sav140.
    set screen 0.
    leave screen.
   When 'SAV'.
***
    delete from zmm_cdcodifier
           where codifier is null.
    delete from zmm_modifier
           where matgrp is null and
                 desc1  is null and
                 desc2  is null.
    delete from zmm_mdl
           where mdlno is null.
    delete from ter15
           where begriff is null and
                 spras = sy-langu.
***
    if not g_itab_del110 is initial.
      loop at g_itab_del110 into g_wa_del110.
        delete from zmm_cdcodifier
        where codifier = g_wa_del110-codifier and
              matgp    = g_wa_del110-matgp  and
              status   = g_wa_del110-status.
      endloop.
    endif.

    if not g_itab_del120 is initial.
      loop at g_itab_del120 into g_wa_del120.
        delete from zmm_modifier
        where matgrp = g_wa_del120-matgrp and
              desc1  = g_wa_del120-desc1 and
              desc2  = g_wa_del120-desc2 and
              desc3  = g_wa_del120-desc3 and
              desc4  = g_wa_del120-desc4.
      endloop.
    endif.

    if not g_itab_del130 is initial.
      loop at g_itab_del130 into g_wa_del130.
        delete from ter15
        where begriff  = g_wa_del130-begriff and
              spras    = sy-langu.
      endloop.
    endif.

    if not g_itab_del140 is initial.
      loop at g_itab_del140 into g_wa_del140.
        delete from zmm_mdl
        where mdlno  = g_wa_del140-mdlno.
      endloop.
    endif.
*Saving Codifier table changes.
   IF g_sav110 = 'Y'.
    loop at g_tct110_itab into g_tct110_wa
         where not codifier is initial.
     move-corresponding g_tct110_wa to g_cdcodifier_wa.
     append g_cdcodifier_wa to g_cdcodifier_itab.
    endloop.
    modify  zmm_cdcodifier from table g_cdcodifier_itab.
   ENDIF.
*Saving Modifier table changes.
   IF g_sav120 = 'Y'.
    loop at g_tct120_itab into g_tct120_wa
         where not desc1 is initial and
               not desc2 is initial.
     move-corresponding g_tct120_wa to g_modifier_wa.
*     move sy-uname to g_modifier_wa-created_by.
*     move sy-datum to g_modifier_wa-create_date.
     append g_modifier_wa to g_modifier_itab.
    endloop.
    modify  zmm_modifier from  table g_modifier_itab.
   ENDIF.
*Saving Dictionary table changes.
   IF g_sav130 = 'Y'.
    loop at g_tct130_itab into g_tct130_wa
         where not begriff is initial.
     move-corresponding g_tct130_wa to g_ter15_wa.
*     move sy-uname to g_ter15_wa-cr_user.
*     move sy-datum to g_ter15_wa-datemod.
     move sy-langu to g_ter15_wa-spras.
     append g_ter15_wa to g_ter15_itab.
    endloop.
    modify  ter15 from table g_ter15_itab.
   ENDIF.

   IF g_sav140 = 'Y'.
    loop at g_tct140_itab into g_tct140_wa
         where not mdlno is initial..
     move-corresponding g_tct140_wa to g_mdl_wa.
*     move sy-uname to g_ter15_wa-cr_user.
*     move sy-datum to g_ter15_wa-datemod.
     append g_mdl_wa to g_mdl_itab.
    endloop.
    modify  zmm_mdl from table g_mdl_itab.
   ENDIF.

   commit work.
   message i080(zmm_oth).
   set screen 0.
   leave screen.

   when 'CDF' or 'MDF' or 'DIC' or 'MDL'.
     tabscr_cd-activetab = okcode100.
 Endcase.
*
 IF tabscr_cd-activetab = 'MDF'.
    OK_CODE = sy-ucomm.

    perform user_ok_tc using  'TCT120'
                              'G_TCT120_ITAB'
                              'FLAG'
                     changing OK_CODE.
*    clear ok_code.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'CDF'.
    OK_CODE = sy-ucomm.
    perform user_ok_tc using  'TCT110'
                              'G_TCT110_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'DIC'.
    OK_CODE = sy-ucomm.

    perform user_ok_tc using  'TCT130'
                              'G_TCT130_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'MDL'.
    OK_CODE = sy-ucomm.
    perform user_ok_tc using  'TCT140'
                              'G_TCT140_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
*    clear ok_code.
 ENDIF.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_desc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_desc INPUT.
 IF not zmm_modifier_st-desc1 is initial.
   translate zmm_modifier_st-desc1 using '*%'.
   condense zmm_modifier_st-desc1. " no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc2 is initial.
   translate zmm_modifier_st-desc2 using '*%'.
   condense zmm_modifier_st-desc2. " no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc3 is initial.
   translate zmm_modifier_st-desc3 using '*%'.
   condense zmm_modifier_st-desc3. "  no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc4 is initial.
   translate zmm_modifier_st-desc4 using '*%'.
   condense zmm_modifier_st-desc4." no-gaps.
 ENDIF.

 if    zmm_modifier_st-desc1 is initial
   and zmm_modifier_st-matgrp is initial
   and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab.
 elseif not zmm_modifier_st-matgrp is initial
        and zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp.
 elseif not zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp
       and   desc1  like zmm_modifier_st-desc1.
 elseif not zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and not zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp
       and   desc1  like zmm_modifier_st-desc1
       and   desc2  like zmm_modifier_st-desc2.
 elseif zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1  like zmm_modifier_st-desc1.
 elseif zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and not zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1  like zmm_modifier_st-desc1
       and   desc2  like zmm_modifier_st-desc2.
 endif.
   refresh control 'TCT120' from screen '0120'.

ENDMODULE.                 " check_desc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_word  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_word INPUT.
   data: l_word like ter15-begriff,
         l_len type i.
 IF not g_word is initial.
   translate g_word using '*%'.
   condense g_word."no-gaps.
 ENDIF.
 IF g_word is initial.
    select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu.
 ELSE.
*   l_len = strlen( g_word ).
   select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu
    and begriff like g_word.
*    delete g_tct130_itab where begriff+0(l_len) <> g_word.
 ENDIF.
ENDMODULE.                 " check_word  INPUT

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: modify table
module TCT140_modify input.
  translate zmm_mdl-mdlno to upper case.
  move-corresponding ZMM_MDL to g_TCT140_wa.
  translate g_TCT140_wa-mdlno to upper case.
  move sy-uname to g_tct140_wa-creby.
  move sy-datum to g_tct140_wa-credt.
  modify g_TCT140_itab
    from g_TCT140_wa
    index TCT140-current_line.
  if sy-subrc <> 0.
    append g_TCT140_wa to g_TCT140_itab.
  endif.
  g_sav140 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: mark table
module TCT140_mark input.
  if TCT140-line_sel_mode = 1 and
     g_TCT140_wa-flag = 'X'.
     loop at g_TCT140_itab into g_TCT140_wa
       where flag = 'X'.
       g_TCT140_wa-flag = ''.
       modify g_TCT140_itab
         from g_TCT140_wa
         transporting flag.
     endloop.
     g_TCT140_wa-flag = 'X'.
  endif.
  modify g_TCT140_itab
    from g_TCT140_wa
    index TCT140-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: process user command
module TCT140_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT140'
                              'G_TCT140_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  check_mdlno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mdlno INPUT.
  Data: l_mdlno like zmm_mdl-mdlno.

 IF not g_mdlno is initial.
   translate g_mdlno to upper case.
   translate g_mdlno using '*%'.
   condense g_mdlno." no-gaps.
 ENDIF.

 IF g_mdlno is initial.
    select * from zmm_mdl
       into corresponding fields
       of table g_TCT140_itab.
 ELSE.
*   l_len = strlen( g_word ).
   select * from zmm_mdl
       into corresponding fields
       of table g_TCT140_itab
    where mdlno like g_mdlno.
 ENDIF.

ENDMODULE.                 " check_mdlno  INPUT

*--- INCLUDE: MZMMCDCELLTABMAINTO01 ---*
***INCLUDE MZMMCDCELLTABMAINTO01 .
*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT110_init output.
  if g_TCT110_copied is initial.
*&spwizard: copy ddic-table 'ZMM_CDCODIFIER'
*&spwizard: into internal table 'g_TCT110_itab'
   select * from ZMM_CDCODIFIER
       into corresponding fields
       of table g_TCT110_itab.

    g_TCT110_copied = 'X'.
    refresh control 'TCT110' from screen '0110'.
  endif.
*  if not g_itab_cp110[] is initial.
*   refresh control 'TCT110' from screen '0110'.
*  endif.
endmodule.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: move itab to dynpro
module TCT110_move output.
  move-corresponding g_TCT110_wa to ZMM_CDCODIFIER.
endmodule.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT110_get_lines output.
  g_TCT110_lines = sy-loopc.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT120_init output.
*  clear g_modifier.
*  refresh g_tct120_itab.
  if g_TCT120_copied is initial.
*&spwizard: copy ddic-table 'ZMM_MODIFIER'
*&spwizard: into internal table 'g_TCT120_itab'
*   perform make_select_statement.
   if zmm_modifier_st-desc1 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab.
   else.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1 = zmm_modifier_st-desc1.
   endif.
    g_TCT120_copied = 'X'.
    refresh control 'TCT120' from screen '0120'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: move itab to dynpro
module TCT120_move output.
  move-corresponding g_TCT120_wa to ZMM_MODIFIER.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT120_get_lines output.
  g_TCT120_lines = sy-loopc.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT130_init output.
  if g_TCT130_copied is initial.
*&spwizard: copy ddic-table 'TER15'
*&spwizard: into internal table 'g_TCT130_itab'
    select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu.
    g_TCT130_copied = 'X'.
    refresh control 'TCT130' from screen '0130'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: move itab to dynpro
module TCT130_move output.
  move-corresponding g_TCT130_wa to TER15.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT130_get_lines output.
  g_TCT130_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  fill_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_dynnr OUTPUT.
  case tabscr_cd-activetab.
    when 'CDF'.
      dynnr = '0110'.
    when 'MDF'.
      dynnr = '0120'.
    when 'DIC'.
      dynnr = '0130'.
    when 'MDL'.
      dynnr = '0140'.
    when others.
      dynnr = '0110'.
      tabscr_cd-activetab = 'CDF'.
   endcase.

ENDMODULE.                 " fill_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'OPTNS'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT140_init output.
  if g_TCT140_copied is initial.
*&spwizard: copy ddic-table 'ZMM_MDL'
*&spwizard: into internal table 'g_TCT140_itab'
    select * from ZMM_MDL
       into corresponding fields
       of table g_TCT140_itab.
    g_TCT140_copied = 'X'.
    refresh control 'TCT140' from screen '0140'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: move itab to dynpro
module TCT140_move output.
  move-corresponding g_TCT140_wa to ZMM_MDL.
endmodule.

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT140_get_lines output.
  g_TCT140_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TCT140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT140_change_field_attr OUTPUT.
  loop at screen.
    if screen-name = 'ZMM_MDL-MDLNO'.
      if not g_TCT140_wa-mdlno is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
  endloop.
ENDMODULE.                 " TCT140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT130_change_field_attr OUTPUT.
 loop at screen.
    if screen-name = 'TER15-BEGRIFF'.
      if not g_TCT130_wa-begriff is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
  endloop.

ENDMODULE.                 " TCT130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT120_change_field_attr OUTPUT.
  loop at screen.
    if screen-name = 'ZMM_MODIFIER-MATGRP'.
       if not g_tct120_wa-matgrp is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC1'.
       if not g_tct120_wa-desc1 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC2'.
       if not g_tct120_wa-desc2 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC3'.
       if not g_tct120_wa-desc3 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC4'.
       if not g_tct120_wa-desc4 is initial.
         screen-input = 0.
        modify screen.
       endif.
    endif.
  endloop.
ENDMODULE.                 " TCT120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT110_change_field_attr OUTPUT.
 loop at screen.
    if screen-name = 'ZMM_CDCODIFIER-CODIFIER'.
       if not g_tct110_wa-codifier is initial.
        screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_CDCODIFIER-MATGP'.
      if not g_tct110_wa-matgp is initial.
        screen-input = 0.
        modify screen.
      endif.
    elseif screen-name = 'ZMM_CDCODIFIER-STATUS'.
      if not g_tct110_wa-status is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
 endloop.
ENDMODULE.                 " TCT110_change_field_attr  OUTPUT

*--- INCLUDE: MZMMCDCELLTABMAINTTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCDCELLTABMAINTTOP                                       *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMCDCELLTABMAINT         .

***&spwizard: data declaration for tablecontrol 'TCT110'
*&spwizard: definition of ddic-table
tables:   ZMM_CDCODIFIER.
Controls: tabscr_cd type tabstrip.

*&spwizard: type for the data of tablecontrol 'TCT110'
types: begin of t_TCT110,
         CODIFIER like ZMM_CDCODIFIER-CODIFIER,
         MATGP like ZMM_CDCODIFIER-MATGP,
         STATUS like ZMM_CDCODIFIER-STATUS,
         flag,       "flag for mark column
       end of t_TCT110.

*&spwizard: internal table for tablecontrol 'TCT110'
data:     g_TCT110_itab   type t_TCT110 occurs 0,
          g_TCT110_wa     type t_TCT110. "work area
data:     g_TCT110_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT110' itself
controls: TCT110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TCT110'
data:     g_TCT110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm,
          OKCODE100 like sy-ucomm.

***&spwizard: data declaration for tablecontrol 'TCT120'
*&spwizard: definition of ddic-table
tables:   ZMM_MODIFIER.

*&spwizard: type for the data of tablecontrol 'TCT120'
types: begin of t_TCT120,
         MATGRP like ZMM_MODIFIER-MATGRP,
         DESC1 like ZMM_MODIFIER-DESC1,
         DESC2 like ZMM_MODIFIER-DESC2,
         DESC3 like ZMM_MODIFIER-DESC3,
         DESC4 like ZMM_MODIFIER-DESC4,
         CREATED_BY like ZMM_MODIFIER-CREATED_BY,
         CREATE_DATE like ZMM_MODIFIER-CREATE_DATE,
         flag,       "flag for mark column
       end of t_TCT120.

*&spwizard: internal table for tablecontrol 'TCT120'
data:     g_TCT120_itab   type t_TCT120 occurs 0,
          g_TCT120_wa     type t_TCT120. "work area
data:     g_TCT120_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT120' itself
controls: TCT120 type tableview using screen 0120.

*&spwizard: lines of tablecontrol 'TCT120'
data:     g_TCT120_lines  like sy-loopc.

***&spwizard: data declaration for tablecontrol 'TCT130'
*&spwizard: definition of ddic-table
tables:   TER15.

*&spwizard: type for the data of tablecontrol 'TCT130'
types: begin of t_TCT130,
         BEGRIFF like TER15-BEGRIFF,
         CR_USER like TER15-CR_USER,
         DATEMOD like TER15-DATEMOD,
         flag,       "flag for mark column
       end of t_TCT130.

*&spwizard: internal table for tablecontrol 'TCT130'
data:     g_TCT130_itab   type t_TCT130 occurs 0,
          g_TCT130_wa     type t_TCT130. "work area
data:     g_TCT130_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT130' itself
controls: TCT130 type tableview using screen 0130.

*&spwizard: lines of tablecontrol 'TCT130'
data:     g_TCT130_lines  like sy-loopc.

***&spwizard: data declaration for tablecontrol 'TCT140'
*&spwizard: definition of ddic-table
tables:   ZMM_MDL.

*&spwizard: type for the data of tablecontrol 'TCT140'
types: begin of t_TCT140,
         MDLNO like ZMM_MDL-MDLNO,
         CREBY like ZMM_MDL-CREBY,
         CREDT like ZMM_MDL-CREDT,
         flag,       "flag for mark column
       end of t_TCT140.

*&spwizard: internal table for tablecontrol 'TCT140'
data:     g_TCT140_itab   type t_TCT140 occurs 0,
          g_TCT140_wa     type t_TCT140. "work area
data:     g_TCT140_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT140' itself
controls: TCT140 type tableview using screen 0140.

*&spwizard: lines of tablecontrol 'TCT140'
data:     g_TCT140_lines  like sy-loopc.
**
DATA:  dynnr like sy-dynnr value '0110',
       zmm_modifier_st like zmm_modifier,
       g_word like ter15-begriff,
       g_mdlno like zmm_mdl-mdlno,
       g_init type c,
       g_sav110 type c,
       g_sav120 type c,
       g_sav130 type c,
       g_sav140 type c.
Data : g_selstr(300) type c.
Data : g_wa_del110 type t_tct110,
       g_wa_del120 type t_tct120,
       g_wa_del130 type t_tct130,
       g_wa_del140 type t_tct140.
DATA : g_itab_del110 type table of t_tct110,
       g_itab_cp110 type table of t_tct110,
       g_itab_del120 type table of t_tct120,
       g_itab_cp120 type table of t_tct120,
       g_itab_del130 type table of t_tct130,
       g_itab_cp130 type table of t_tct130,
       g_itab_del140 type table of t_tct140,
       g_itab_cp140 type table of t_tct140.
DATA: g_cdcodifier_wa like zmm_cdcodifier,
      g_cdcodifier_itab like zmm_cdcodifier occurs 0.
Data: g_modifier_wa like zmm_modifier,
      g_modifier_itab like zmm_modifier occurs 0.
Data: g_ter15_wa like ter15,
      g_ter15_itab like ter15 occurs 0.
Data: g_mdl_wa    like zmm_mdl,
      g_mdl_itab  like zmm_mdl occurs 0.
