*--- MAIN PROGRAM: SAPMZMMMEE ---*
***********************************************************************
* Program    : SAPMZMMMER                                             *
* Title      : Material Extension requests Execution                  *
*                                                                     *
* Functional Specification No.: FS-MM-MAT-003 (Input Form)            *
*                                                                     *
* Author     : Nandini Bakre                 Date : 19-MAY-2005       *
* Login Id   : CAB_NANDINIB                                           *
*                                                                     *
* Functional Specification No.: FS-MM-MAT-003 (Material Extn Form)    *
*                                                                     *
* Author     : Biswajeet Basumatary         Date : 15/06/2005         *
* Login Id   : cab_basu                                               *
*                                                                     *
* Desciption : To generate the daily Production report at BPA/BPB.    *
* Plant specific fields from the system as well as ZTables are to be  *
* Grouped together to form the report                                 *
* Transaction Code :  ZMM_MATEXE
*
***********************************************************************
* CHANGE HISTORY                                                      *
* 29/08/2005  cab_kartik    bug fix             rk001                 *
* 02/09/2005                                    rk002(RD1K928632)     *
* 05/09/2005                                    rk003(RD1K928686)     *
* 08/09/2005                                    rk004(RD1K928792)     *
* 09/09/2005                                    rk005(RD1K928798)     *
* 20/10/2005                add comp code       rk006(RD1K929720)     *
*                           in scr 7000                               *
*30/09/2008   CAB_SUDHA     additional bdc for extending material QM st
*                                               +007
*2.1.2009     CAB_SUDHA     BDC QA08 changed    +008
***********************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Change in INCLUDE MZMMMEEF01
*
************************************************************************
PROGRAM  sapmzmmmee .

INCLUDE mzmmmeetop.
INCLUDE mzmmmeeo01.
INCLUDE mzmmmeei01.
INCLUDE mzmmmeef01.
*INCLUDE BDCRECX1.

*&---------------------------------------------------------------------*
*& Starting of Selection Screen                                        *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS p_newr RADIOBUTTON GROUP radi .
PARAMETERS p_pend RADIOBUTTON GROUP radi .
PARAMETERS p_comp RADIOBUTTON GROUP radi .
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
SELECT-OPTIONS s_reqn FOR zmm_mems-docno MATCHCODE OBJECT zmm_shlp_doknr
.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
SELECT-OPTIONS s_date FOR sy-datum.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
*----start of changes by rk004 --------------------------*
*SELECT-OPTIONS s_bukrs FOR zmm_mems-bukrs NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS s_bukrs FOR zmm_mems-bukrs obligatory.
*----end of changes by rk004 --------------------------*
SELECTION-SCREEN END OF BLOCK b4.

*AT SELECTION-SCREEN.

INITIALIZATION.

  PERFORM clear_flags.

START-OF-SELECTION.

  clear : g_pend, G_NEWR, G_COMP.
  IF p_pend EQ 'X'.

    SELECT * FROM zmm_mems
               INTO CORRESPONDING FIELDS OF TABLE g_tc_parent_itab
               WHERE docno    IN s_reqn  AND
                     ersda    IN s_date  AND
                     bukrs    IN s_bukrs AND
                     sflag = 'P' .
    g_pend = 'X'.   "+rk003
  ELSEIF p_newr EQ 'X'.

    SELECT * FROM zmm_mems
               INTO CORRESPONDING FIELDS OF TABLE g_tc_parent_itab
               WHERE docno    IN s_reqn  AND
                     ersda    IN s_date  AND
                     bukrs    IN s_bukrs AND
                     sflag = 'N' .
    G_NEWR = 'X'.    "+rk003
  ELSEIF p_comp EQ 'X'.

    SELECT * FROM zmm_mems
              INTO CORRESPONDING FIELDS OF TABLE g_tc_parent_itab
              WHERE docno    IN s_reqn  AND
                    ersda    IN s_date  AND
                    bukrs    IN s_bukrs AND
                    sflag = 'C' .
    G_COMP = 'X' .  "+rk003
  ENDIF.

  SORT g_tc_parent_itab.

END-OF-SELECTION.

  CALL SCREEN '7000'.

*--- INCLUDE: %_CCXTAB ---*
TYPE-POOL CXTAB .

TYPES:
       CXTAB_COLUMN type scxtab_column,
       CXTAB_CONTROL type scxtab_control,
       CXTAB_TABSTRIP type scxtab_tabstrip.

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL

*--- INCLUDE: MZMMMEEF01 ---*
***INCLUDE MZMMMEEF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Literal error Changed in Line 779.
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
   DATA: l_ok              TYPE sy-ucomm,
         l_offset          TYPE i.
*-END OF LOCAL DATA----------------------------------------------------*

   SEARCH p_ok FOR p_tc_name. "#EC CI_NOORDER
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.

   CASE l_ok.
*----- START OF ADD BY RK003 -------------------*
     WHEN 'ASC'.
       if not ist_msg[] is initial.
         sort ist_msg by docno msgtyp.
       endif.
     WHEN 'DSC'.
       if not ist_msg[] is initial.
         sort ist_msg DESCENDING by docno msgtyp.
       endif.
*----- END OF ADD BY RK003 -------------------*
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

     WHEN 'MAIL'.                      "demark all filled lines


       PERFORM fcode_tc_mail       USING p_tc_name
                                         p_table_name
                                         p_mark_name .
       CLEAR p_ok.


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
*&      Form  CLEAR_FLAGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM clear_flags.

   CLEAR: g_check_flag, g_extnd_flag, g_reprt_flag.

 ENDFORM.                    " CLEAR_FLAGS
*&---------------------------------------------------------------------*
*&      Form  POPULATE_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM populate_record.

   DATA: zmm_me01_wa       TYPE   zmm_me01.
   DATA: zmm_me02_wa       TYPE   zmm_me02.
   DATA: l_valclass        TYPE   zmm_valclass.
*   DATA: g_mm01_ist        TYPE   t_mm01 OCCURS 0.
*   DATA: g_mm01_wa         TYPE   t_mm01.
   DATA: t001w         LIKE t001w.
   DATA: l_views(1) type n.                                 "+rk004

   DATA: general_data LIKE bapimatdoa.
   DATA: return LIKE bapireturn.
   DATA: plantdata LIKE bapimatdoc.
   DATA: valuationdata LIKE bapimatdobew.
   DATA: plants TYPE TABLE OF marc_werk WITH HEADER LINE.

   CLEAR g_tc_child_wa.

   REFRESH g_mm01_ist.

   LOOP AT g_tc_child_itab INTO g_tc_child_wa.

     CLEAR:  return, g_mm01_wa, general_data, t001w, g_exist.

     CALL FUNCTION 'GET_PLANT_DETAILS'
       EXPORTING
         i_werks         = g_tc_child_wa-werks
       IMPORTING
         e_t001w         = t001w
       EXCEPTIONS
         not_found       = 1
         parameter_error = 2
         OTHERS          = 3.


     IF sy-subrc EQ 0.

       IF g_tc_child_wa-bwtar EQ 'BATCH_MNGD'.
         CLEAR g_tc_child_wa-bwtar.
       ENDIF.

       CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'   "#EC CI_USAGE_OK[2438131]
         EXPORTING
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*           material              = g_tc_child_wa-matnr
           material_long              = g_tc_child_wa-matnr
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
           plant                 = g_tc_child_wa-werks
           valuationarea         = t001w-bwkey
           valuationtype         = g_tc_child_wa-bwtar
         IMPORTING
           material_general_data = general_data
           return                = return
           materialplantdata     = plantdata
           materialvaluationdata = valuationdata.


       CASE return-type.
*----------------------------------------------------------------------*
* The material does not exists in valuation area, only second part
*----------------------------------------------------------------------*
         WHEN 'W'.
           IF return-code EQ 'MM363' OR return-code EQ 'MM361'.
             PERFORM search_views_extended USING g_tc_child_wa-matnr
                                                 g_tc_child_wa-werks
                                           CHANGING g_all
                                                    g_only_second.
           ENDIF.
*----------------------------------------------------------------------*
* First create the valuation-type-independent data, do entire
* The material does not exist or not activated cannot be done
*----------------------------------------------------------------------*
         WHEN 'E'.

           IF return-code EQ 'M3192'.
             CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
               EXPORTING
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*                 material              = g_tc_child_wa-matnr
                 material_long             = g_tc_child_wa-matnr
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
               IMPORTING
                 material_general_data = general_data
                 return                = return.

             g_all = space.
             g_only_second = space.
           ELSEIF return-code EQ 'M3305'.
             wa_msg-docno = g_tc_child_wa-docno.            "+rk003
             wa_msg-matnr = g_tc_child_wa-matnr.
             wa_msg-msgtyp = 'E'.
             wa_msg-bwtar = g_tc_child_wa-bwtar.
             wa_msg-msgv1 = return-message_v1.
             APPEND wa_msg TO ist_msg.
             CLEAR g_mm01_del.
             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
             g_mm01_del-matnr = g_tc_child_wa-matnr.
             g_mm01_del-bwtar = g_tc_child_wa-bwtar.
             APPEND g_mm01_del.
           ENDIF.

         WHEN 'S'.

           CALL FUNCTION 'MATERIAL_READ_PLANTS'
             EXPORTING
               matnr  = g_tc_child_wa-matnr
             TABLES
               plants = plants.

           READ TABLE plants WITH KEY werks = g_tc_child_wa-werks.

           DATA : l_strlen TYPE i.

           l_strlen = strlen( plants-pstat ).
*--------start of changes by rk004------------------------------------*

*           IF l_strlen < 6.                               "-rk004
           CLEAR t320.                                      "+rk001
           clear l_views.
           SELECT * FROM T320 UP TO 1 ROWS
 WHERE WERKS EQ G_TC_CHILD_WA-WERKS
 ORDER BY PRIMARY KEY .
 ENDSELECT.
           if sy-subrc is initial.
             l_views = 7.
           else.
             l_views = 6.
           endif.

           IF l_strlen < l_views.                           "+rk004
*----------end of changes by rk004------------------------------------*

             PERFORM search_views_extended USING g_tc_child_wa-matnr
                                                  g_tc_child_wa-werks
                                            CHANGING g_all
                                                     g_only_second.

           ENDIF.


         WHEN OTHERS.

       ENDCASE.

       CLEAR g_mm01_wa.
       g_mm01_wa-docno = g_tc_child_wa-docno.               "+rk003
       g_mm01_wa-matnr = g_tc_child_wa-matnr.  " Material
       g_mm01_wa-werks = g_tc_child_wa-werks.  " Plant
*----------------------------------------------------------------------*
* Find Sales Organization
*----------------------------------------------------------------------*
       IF t001w-vkorg NE space.
         g_mm01_wa-vkorg = t001w-vkorg.  " Sales org
       ELSE.
         CLEAR zmm_me01_wa.
         SELECT SINGLE * FROM zmm_me01 INTO zmm_me01_wa
                         WHERE werks EQ g_tc_child_wa-werks.
         IF sy-subrc EQ 0.
           IF zmm_me01_wa-vkorg NE space.
             g_mm01_wa-vkorg = zmm_me01_wa-vkorg.  " Sales Org
           ELSE.
             wa_msg-docno = g_tc_child_wa-docno.
             wa_msg-matnr = g_tc_child_wa-matnr.
             wa_msg-msgtyp = 'E'.
             wa_msg-bwtar = g_tc_child_wa-bwtar.
             CONCATENATE 'Sales Org does not exit for plant'
                          g_tc_child_wa-werks INTO wa_msg-msgv1
                          SEPARATED BY space.
             APPEND wa_msg TO ist_msg.
             CLEAR g_mm01_del.
             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
             g_mm01_del-matnr = g_tc_child_wa-matnr.
             g_mm01_del-bwtar = g_tc_child_wa-bwtar.
             APPEND g_mm01_del.
           ENDIF.
         ELSE.
           wa_msg-docno = g_tc_child_wa-docno.
           wa_msg-matnr = g_tc_child_wa-matnr.
           wa_msg-msgtyp = 'E'.
           wa_msg-bwtar = g_tc_child_wa-bwtar.
           CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                       'does not exist in table ZMM_ME01'
                       INTO wa_msg-msgv1
                       SEPARATED BY space.
           APPEND wa_msg TO ist_msg.
           CLEAR g_mm01_del.
           g_mm01_del-docno = g_tc_child_wa-docno.          "+rk003
           g_mm01_del-matnr = g_tc_child_wa-matnr.
           g_mm01_del-bwtar = g_tc_child_wa-bwtar.
           APPEND g_mm01_del.
         ENDIF.
       ENDIF.
*----------------------------------------------------------------------*
* Find Warehouse number                                                *
*----------------------------------------------------------------------*
       CLEAR t320.
       SELECT * FROM T320 UP TO 1 ROWS
 WHERE WERKS EQ G_TC_CHILD_WA-WERKS
 ORDER BY PRIMARY KEY .
 ENDSELECT.

       IF sy-subrc EQ 0.
         g_mm01_wa-lgnum = t320-lgnum.
       ENDIF.
*----------------------------------------------------------------------*
* Get Profit center for plant
*----------------------------------------------------------------------*
       CLEAR zmm_me01_wa.
       SELECT SINGLE * FROM zmm_me01
                       INTO zmm_me01_wa
                       WHERE werks EQ g_tc_child_wa-werks.

       IF sy-subrc EQ 0.
         IF zmm_me01_wa-prctr NE space.
           g_mm01_wa-prctr = zmm_me01_wa-prctr.  " Profit Center
         ELSE.
           wa_msg-docno = g_tc_child_wa-docno.              "+rk003
           wa_msg-matnr = g_tc_child_wa-matnr.
           wa_msg-msgtyp = 'E'.
           wa_msg-bwtar = g_tc_child_wa-bwtar.
           CONCATENATE 'Profit Center does not exit for plant'
                        g_tc_child_wa-werks INTO wa_msg-msgv1
                        SEPARATED BY space.
           APPEND wa_msg TO ist_msg.
           CLEAR g_mm01_del.
           g_mm01_del-docno = g_tc_child_wa-docno.          "+rk003
           g_mm01_del-matnr = g_tc_child_wa-matnr.
           g_mm01_del-bwtar = g_tc_child_wa-bwtar.
           APPEND g_mm01_del.
         ENDIF.
       ELSE.
         wa_msg-docno = g_tc_child_wa-docno.                "+rk003
         wa_msg-matnr = g_tc_child_wa-matnr.
         wa_msg-msgtyp = 'E'.
         wa_msg-bwtar = g_tc_child_wa-bwtar.
         CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                'does not exist in table ZMM_ME01'  INTO wa_msg-msgv1
                     SEPARATED BY space.
         APPEND wa_msg TO ist_msg.
         CLEAR g_mm01_del.
         g_mm01_del-docno = g_tc_child_wa-docno.            "+rk003
         g_mm01_del-matnr = g_tc_child_wa-matnr.
         g_mm01_del-bwtar = g_tc_child_wa-bwtar.
         APPEND g_mm01_del.
       ENDIF.

       g_mm01_wa-prodh = general_data-prod_hier.  " Product hier
       g_mm01_wa-mtart = general_data-matl_type.  " Material type

*----------------------------------------------------------------------*
* Find MRP Controller
*----------------------------------------------------------------------*
       CLEAR zmm_me02_wa.
       SELECT * FROM ZMM_ME02
 INTO ZMM_ME02_WA UP TO 1 ROWS WHERE WERKS EQ G_TC_CHILD_WA-WERKS AND MTART EQ GENERAL_DATA-MATL_TYPE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
       IF sy-subrc EQ 0.
         g_mm01_wa-dispo = zmm_me02_wa-dispo.   " MRP Controller
       ELSE.
         wa_msg-docno = g_tc_child_wa-docno.                "+rk003
         wa_msg-matnr = g_tc_child_wa-matnr.
         wa_msg-msgtyp = 'E'.
         wa_msg-bwtar = g_tc_child_wa-bwtar.
         CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                     'does not exist in table ZMM_ME02'
                     INTO wa_msg-msgv1 SEPARATED BY space.
         APPEND wa_msg TO ist_msg.
         CLEAR g_mm01_del.
         g_mm01_del-docno = g_tc_child_wa-docno.            "+rk003
         g_mm01_del-matnr = g_tc_child_wa-matnr.
         g_mm01_del-bwtar = g_tc_child_wa-matnr.
         APPEND g_mm01_del.
       ENDIF.
*----------------------------------------------------------------------*
* Valuation Class
*----------------------------------------------------------------------*
       IF general_data-prod_hier EQ '0C'.
         g_mm01_wa-bwtty = 'X'.
         CLEAR l_valclass.
         SELECT * FROM ZMM_VALCLASS
 INTO L_VALCLASS UP TO 1 ROWS WHERE MATNR_FROM LE G_TC_CHILD_WA-MATNR AND MATNR_TO GE G_TC_CHILD_WA-MATNR AND VAL_TYPE EQ SPACE
 ORDER BY PRIMARY KEY .
 ENDSELECT.

         IF sy-subrc EQ 0.
           g_mm01_wa-bklas = l_valclass-val_class.   " Valuation Class
         ELSE.
           wa_msg-docno = g_tc_child_wa-docno.              "+rk003
           wa_msg-matnr = g_tc_child_wa-matnr.
           wa_msg-msgtyp = 'E'.
           wa_msg-bwtar = g_tc_child_wa-bwtar.
           CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                       'does not exist in table ZMM_VALCLASS'
                       INTO wa_msg-msgv1 SEPARATED BY space.
           APPEND wa_msg TO ist_msg.
           CLEAR g_mm01_del.
           g_mm01_del-docno = g_tc_child_wa-docno.          "+rk003
           g_mm01_del-matnr = g_tc_child_wa-matnr.
           g_mm01_del-bwtar = g_tc_child_wa-bwtar.
           APPEND g_mm01_del.
         ENDIF.
*----------------------------------------------------------------------*
* Populate view table.
*----------------------------------------------------------------------*
         PERFORM populate_view_table USING general_data-matl_type
                                           g_mm01_wa-lgnum
                                           g_tc_child_wa-werks
                                     CHANGING g_mm01_wa-zksel .
         IF g_all NE 'X'.
           PERFORM modify_zksel CHANGING g_mm01_wa-zksel.
         ENDIF.

         APPEND g_mm01_wa TO g_mm01_ist.

       ELSE.

         CASE general_data-prod_hier.

           WHEN '01' OR '02' OR '03' OR '04' OR '05' OR '06' OR '07' OR
                '08' OR '09' OR '10' OR '11' OR '12' OR '13' OR '14' OR
                '15' OR '16'.
             g_mm01_wa-bwtty = 'O'.

           WHEN '21' OR '22' OR '23' OR '24' OR '25' OR '26' OR '27' OR
                '28' OR '29' OR '30' OR '31' OR '32' OR '33' OR '34' OR
                '35' OR '36' OR '37' OR '38' OR '39' OR '40' OR '41' OR
                '42'.
             g_mm01_wa-bwtty = 'P'.
         ENDCASE.

*----------------------------------------------------------------------*
* Populate view table.
*----------------------------------------------------------------------*
         PERFORM populate_view_table USING general_data-matl_type
                                           g_mm01_wa-lgnum
                                           g_tc_child_wa-werks
                                     CHANGING g_mm01_wa-zksel .
         IF g_all NE 'X'.
           PERFORM modify_zksel CHANGING g_mm01_wa-zksel.
         ENDIF.

         IF g_only_second NE 'X'.

           CLEAR l_valclass.
           SELECT * FROM ZMM_VALCLASS INTO L_VALCLASS UP TO 1 ROWS
 WHERE MATNR_FROM LE G_TC_CHILD_WA-MATNR AND MATNR_TO GE G_TC_CHILD_WA-MATNR AND VAL_TYPE EQ SPACE
 ORDER BY PRIMARY KEY .
 ENDSELECT.

           IF sy-subrc EQ 0.
             g_mm01_wa-bklas = l_valclass-val_class.
           ELSE.
             wa_msg-docno = g_tc_child_wa-docno.            "+rk003
             wa_msg-matnr = g_tc_child_wa-matnr.
             wa_msg-msgtyp = 'E'.
             wa_msg-bwtar = g_tc_child_wa-bwtar.
             CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                         'does not exist in table ZMM_VALCLASS'
                         INTO wa_msg-msgv1 SEPARATED BY space.
             APPEND wa_msg TO ist_msg.
             CLEAR g_mm01_del.
             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
             g_mm01_del-matnr = g_tc_child_wa-matnr.
             g_mm01_del-bwtar = g_tc_child_wa-bwtar.
             APPEND g_mm01_del.
           ENDIF.

           APPEND g_mm01_wa TO g_mm01_ist.  "First line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
           CLEAR l_valclass.
           SELECT * FROM ZMM_VALCLASS INTO L_VALCLASS UP TO 1 ROWS
 WHERE MATNR_FROM LE G_TC_CHILD_WA-MATNR AND MATNR_TO GE G_TC_CHILD_WA-MATNR AND VAL_TYPE EQ G_TC_CHILD_WA-BWTAR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

           IF sy-subrc EQ 0.
             g_mm01_wa-bklas = l_valclass-val_class.
           ELSE.
             wa_msg-docno = g_tc_child_wa-docno.            "+rk003
             wa_msg-matnr = g_tc_child_wa-matnr.
             wa_msg-msgtyp = 'E'.
             wa_msg-bwtar = g_tc_child_wa-bwtar.
             CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                         'does not exist in table ZMM_VALCLASS'
                         INTO wa_msg-msgv1 SEPARATED BY space.
             APPEND wa_msg TO ist_msg.
             CLEAR g_mm01_del.
             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
             g_mm01_del-matnr = g_tc_child_wa-matnr.
             g_mm01_del-bwtar = g_tc_child_wa-bwtar.
             APPEND g_mm01_del.
           ENDIF.

           g_mm01_wa-bwtar = g_tc_child_wa-bwtar.

           APPEND g_mm01_wa TO g_mm01_ist.  " Second Line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
         ELSE.

           CLEAR l_valclass.

           SELECT * FROM ZMM_VALCLASS INTO L_VALCLASS UP TO 1 ROWS
 WHERE MATNR_FROM LE G_TC_CHILD_WA-MATNR AND MATNR_TO GE G_TC_CHILD_WA-MATNR AND VAL_TYPE EQ G_TC_CHILD_WA-BWTAR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

           IF sy-subrc EQ 0.
             g_mm01_wa-bklas = l_valclass-val_class.
           ELSE.
             wa_msg-docno = g_tc_child_wa-docno.            "+rk003
             wa_msg-matnr = g_tc_child_wa-matnr.
             wa_msg-msgtyp = 'E'.
             wa_msg-bwtar = g_tc_child_wa-bwtar.
             CONCATENATE 'Entry for plant' g_tc_child_wa-werks
                         'does not exist in table ZMM_VALCLASS'
                         INTO wa_msg-msgv1 SEPARATED BY space.
             APPEND wa_msg TO ist_msg.
             CLEAR g_mm01_del.
             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
             g_mm01_del-matnr = g_tc_child_wa-matnr.
             g_mm01_del-bwtar = g_tc_child_wa-bwtar.
             APPEND g_mm01_del.
           ENDIF.

           g_mm01_wa-bwtar = g_tc_child_wa-bwtar.
           APPEND g_mm01_wa TO g_mm01_ist.  " Only second line
         ENDIF.
       ENDIF.
       CLEAR: g_all, g_only_second, g_tc_child_wa, plants.
       REFRESH plants.
     ELSE.
*----------------------------------------------------------------------*
* The plant does not exist
*----------------------------------------------------------------------*
     ENDIF.

*     REFRESH it_views.         "-RK001

   ENDLOOP.

*----------------------------------------------------------------------*
* Sort and delete the del in-table
*----------------------------------------------------------------------*
   SORT g_mm01_del.
   DELETE ADJACENT DUPLICATES FROM g_mm01_del.

   CLEAR g_mm01_del.
   LOOP AT g_mm01_del.
     DELETE g_mm01_ist WHERE matnr EQ g_mm01_del-matnr
                      AND bwtar EQ g_mm01_del-bwtar.

     IF sy-subrc EQ 0.
       wa_msg-docno = g_mm01_del-docno.                     "+rk003
       wa_msg-matnr = g_mm01_del-matnr.
       wa_msg-msgtyp = 'I'.
       wa_msg-bwtar = g_mm01_del-bwtar.

       " Begin of <RD1K960036>.
*       CONCATENATE 'Material' g_mm01_del-matnr ','g_mm01_del-bwtar
*                   'is deleted from the extension list.'
*                    INTO wa_msg-msgv1 SEPARATED BY space.
       CONCATENATE 'Material' g_mm01_del-matnr ',' g_mm01_del-bwtar
                  'is deleted from the extension list.'
                   INTO wa_msg-msgv1 SEPARATED BY space.
       APPEND wa_msg TO ist_msg.
       " End of <RD1K960036>.
     ENDIF.
     CLEAR g_mm01_del.

   ENDLOOP.

   SORT ist_msg.
   DELETE ADJACENT DUPLICATES FROM ist_msg.

*----------------------------------------------------------------------*
* Populate the BDCDATA table
*----------------------------------------------------------------------*
**Begin of <RD1K960036>.
*   DATA: l_index TYPE sy-index.
*   DATA: l_tragr TYPE mara-tragr.
*   DATA: l_qmpur TYPE mara-qmpur.
*   DATA: l_prctr like marc-prctr.                           "+rk001
*
*
*   clear l_prctr.                                           "+rk001
*   LOOP AT g_mm01_ist INTO g_mm01_wa.
*
*     SELECT SINGLE tragr qmpur FROM mara INTO (l_tragr, l_qmpur)
*           WHERE matnr EQ g_mm01_wa-matnr.
*
*     PERFORM bdc_dynpro USING 'SAPLMGMM'   '0060'.
*     PERFORM bdc_field  USING 'BDC_CURSOR'    'RMMG1-MATNR'.
*     PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
*     PERFORM bdc_field  USING 'RMMG1-MATNR'   g_mm01_wa-matnr.
*
*     PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
*     PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(16)'.
*     PERFORM bdc_field  USING 'BDC_OKCODE'  '=P+'.
*
*     IF g_mm01_wa-bwtar EQ space .
*
*       CLEAR: l_index, msichtausw.
*       l_index = 1.
*       IF g_mm01_wa-mtart EQ 'ZCAP'.
*
*         DO 10 TIMES.
*           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
*           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
*           l_index = l_index + 1.
*         ENDDO.
*       ELSEIF g_mm01_wa-mtart EQ 'ZSTO' OR g_mm01_wa-mtart EQ 'ZSPR'.
*         DO 9 TIMES.
*           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
*           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
*           l_index = l_index + 1.
*         ENDDO.
*       ENDIF.
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(08)'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
*
*       IF g_mm01_wa-mtart EQ 'ZCAP'.
*         DO 6 TIMES.
*           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
*           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
*           l_index = l_index + 1.
*         ENDDO.
*       ELSEIF g_mm01_wa-mtart EQ 'ZSTO' OR g_mm01_wa-mtart EQ 'ZSPR'.
*         DO 7 TIMES.
*           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
*           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
*           l_index = l_index + 1.
*         ENDDO.
*       ENDIF.
*
*       IF g_mm01_wa-werks NE  '90R1'.
**
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '0080'.
*         read table it_views with key text = 'V'.           "+rk001
*         if sy-subrc <> 0.                                  "+rk001
*           PERFORM bdc_field  USING 'BDC_CURSOR'   'RMMG1-VTWEG'.
*         endif.                                             "+rk001
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTR'.
*         PERFORM bdc_field  USING 'RMMG1-WERKS'   g_mm01_wa-werks.
*         if not it_views-text eq 'V'.                       "+rk001
*           PERFORM bdc_field  USING 'RMMG1-VKORG'   g_mm01_wa-vkorg .
*           PERFORM bdc_field  USING 'RMMG1-VTWEG'   'ST'.
*         endif.                                             "rk001
*         IF g_mm01_wa-lgnum NE space.
*           PERFORM bdc_field  USING 'RMMG1-LGNUM'   g_mm01_wa-lgnum.
*         ENDIF.
*
*         CLEAR msichtausw.
*         READ TABLE g_mm01_wa-zksel INTO msichtausw  INDEX 1.
**           WITH KEY dytxt = 'MSICHTAUSW-KZSEL(05)' . "Sales Org 1
*         IF msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X'.
*
*           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
**           PERFORM bdc_field  USING 'MVKE-SKTOF'  'X'.         "-rk002
*          PERFORM bdc_field  USING 'BDC_CURSOR'  'MG03STEUER-TAXKM(02)'.
*           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(01)'  '1'.
*           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(02)'  '1'.
*
*           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4200'.
*           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*          PERFORM bdc_field  USING 'BDC_CURSOR'  'MG03STEUER-TAXKM(04)'.
*           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(03)'  '1'.
*           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(04)'  '1'.
*
*           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*           PERFORM bdc_field  USING 'BDC_CURSOR'  'MARA-SPART'.
**           PERFORM bdc_field  USING 'MVKE-SKTOF'  'X'.        "-rk002
*
*         ENDIF.
*
*         CLEAR msichtausw.
*
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 2.
**           WITH KEY dytxt = 'MSICHTAUSW-KZSEL(06)'. " Sales Org 2
*
*         IF msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X'.
*
*           PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
*           PERFORM bdc_field  USING 'BDC_CURSOR'   'MVKE-VERSG'.
*           PERFORM bdc_field  USING 'MVKE-VERSG'   '1'.
*           PERFORM bdc_field  USING 'MVKE-MTPOS'   'NORM'.
*           PERFORM bdc_field  USING 'MVKE-PRODH'   g_mm01_wa-prodh.
*
*         ENDIF.
*
*         CLEAR msichtausw.
*
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 3.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(07)'. " Sales: General/Plant
*
*         IF msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X'.
*
*           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
**         PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.        "-rk001
*
**--------code add by rk001 --------------------------------------*
*
*           select single * from marc where matnr = g_mm01_wa-matnr
*                                     and werks = g_mm01_wa-werks
*                                     and mtvfp <> ' '.
*           if not sy-subrc is initial.
*             PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.
*           endif.
**           IF g_mm01_wa-mtart EQ 'ZCAP'.   "-rk001
**               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
**           ENDIF.                          "-rk001
*
*           IF g_mm01_wa-mtart EQ 'ZCAP'.
*            select single * from marc where matnr = g_mm01_wa-matnr AND
*                                            WERKS = g_mm01_wa-werks and
*                                              XCHPF = ' '.
*             if sy-subrc is initial.
*               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.
*             endif.
*           ENDIF.
**-------end of code add by rk001---------------------------------*
*           IF l_tragr IS INITIAL.
*             PERFORM bdc_field  USING 'MARA-TRAGR'  '0001'.
*           ENDIF.
*
*           PERFORM bdc_field  USING 'MARC-LADGR'  'STK'.
**------START OF ADD BY RK001----------------------------------*
*
*           SELECT SINGLE PRCTR FROM MARC INTO L_PRCTR WHERE
*                                       MATNR = g_mm01_wa-matnr AND
*                                       WERKS = g_mm01_wa-werks.
*           IF L_PRCTR IS INITIAL.
*             PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PRCTR'.
*             PERFORM bdc_field  USING 'MARC-PRCTR'  g_mm01_wa-prctr.
*           ENDIF.
**           PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PRCTR'. "-RK001
**           PERFORM bdc_field  USING 'MARC-PRCTR'  g_mm01_wa-prctr. *
**"-RK001
**-------END OF ADD BY RK001-----------------------------------*
*         ENDIF.
*
*       ELSE.
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '0080'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'RMMG1-WERKS'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTR'.
*         PERFORM bdc_field  USING 'RMMG1-WERKS'   g_mm01_wa-werks.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 4.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(10)'. " Purchasing
*
*       IF msichtausw-dytxt+17(2) EQ '10' AND msichtausw-kzsel EQ 'X'.
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARA-BSTME'.
**--------start of comment by rk001 -----------------------------*
**           IF g_mm01_wa-mtart EQ 'ZCAP'.                     "-rk001
**               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
**           ENDIF.                                            "-rk001
*
**--------end of code comment by rk001 -----------------------------*
*
*       ENDIF.
*
*       CLEAR msichtausw.
*
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 5.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(12)'. " Purchase order text
*
*       IF msichtausw-dytxt+17(2) EQ '12' AND msichtausw-kzsel EQ 'X'.
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'   '4040'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'RMMG1-MATNR'.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 6.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(13)'. " MRP 1
*
*       IF msichtausw-dytxt+17(2) EQ '13' AND msichtausw-kzsel EQ 'X'.
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-DISPO'.
*         PERFORM bdc_field  USING 'MARC-DISMM'  'ND'.
*         PERFORM bdc_field  USING 'MARC-DISPO'  g_mm01_wa-dispo.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 7.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(14)'. " MRP 2
*
*       IF msichtausw-dytxt+17(2) EQ '14' AND msichtausw-kzsel EQ 'X'.
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'MARC-BESKZ'  'F'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-FHORI'.
*         PERFORM bdc_field  USING 'MARC-FHORI'  '000'.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 8.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(15)'. " MRP 3
*       IF msichtausw-dytxt+17(2) EQ '15' AND msichtausw-kzsel EQ 'X'.
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PERKZ'.
*         PERFORM bdc_field  USING 'MARC-PERKZ'  'M'.
**--------code add by rk001 --------------------------------------*
*
*         select single * from marc where matnr = g_mm01_wa-matnr
*                                   and werks = g_mm01_wa-werks
*                                   and mtvfp <> ' '.
*         if not sy-subrc is initial.
*           PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.
*         endif.
**-------end of code add by rk001---------------------------------*
*
**         PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.        "-rk001
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 9.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " MRP 4
*       IF msichtausw-dytxt+17(2) EQ '16' AND msichtausw-kzsel EQ 'X'.
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-ALTSL'.
*         endif.
*
*
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 10.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 1
*      IF ( msichtausw-dytxt+17(2) EQ '18' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-AUSME'.
*
**--------start of code comment by rk001 -----------------------------*
**           IF g_mm01_wa-mtart EQ 'ZCAP'.                     "-rk001
**               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
**           ENDIF.                                            "-rk001
**--------end of code comment by rk001 -----------------------------*
*
**         PERFORM bdc_field  USING 'MARA-IPRKZ'   'D'.
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 11.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 2
*      IF ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
**         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'.  "-RK001
*         IF g_mm01_wa-mtart EQ 'ZCAP'.
*           PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'."+RK001
*           PERFORM bdc_field  USING 'MARC-SERNP'   '0001'.
*         ENDIF.
**------START OF ADD BY RK001----------------------------------*
*         CLEAR L_PRCTR.
*         SELECT SINGLE PRCTR FROM MARC INTO L_PRCTR WHERE
*                                     MATNR = g_mm01_wa-matnr AND
*                                     WERKS = g_mm01_wa-werks.
*         IF L_PRCTR IS INITIAL.
*           PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.
*         ENDIF.
*
**      PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.  "-RK001
**------END OF ADD BY RK001----------------------------------*
*
*       ENDIF.
*
*
*       IF g_mm01_wa-lgnum NE space.
*         CLEAR msichtausw.
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 12.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 1
*      IF ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' ).
*           PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**          PERFORM bdc_field  USING 'BDC_CURSOR' 'RMMG1-LGNUM'.  "-RK001
*         ENDIF.
*
*         CLEAR msichtausw.
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 13.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 2
*      IF ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' ).
*           PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
*           PERFORM bdc_field  USING 'BDC_CURSOR' 'MLGN-LHMG1'.
*         ENDIF.
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 14.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. "  Quality Mgt
*      IF ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*
*         IF g_mm01_wa-prodh EQ '10'.
*           PERFORM bdc_field  USING 'MARC-QMATA'  '000002'.
*         ELSE.
*           PERFORM bdc_field  USING 'MARC-QMATA'  '000001'.
*         ENDIF.
*
*         PERFORM bdc_field  USING 'MARC-KZDKZ'  'X'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-SSQSS'.
*
*         IF l_qmpur IS INITIAL.
*           PERFORM bdc_field  USING 'MARA-QMPUR'  'X'.
*         ENDIF.
*
*         PERFORM bdc_field  USING 'MARC-SSQSS'  '0000'.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 15.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 1
*      IF ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BWTTY'.
*         PERFORM bdc_field  USING 'MBEW-BWTTY'   g_mm01_wa-bwtty.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BKLAS'.
*         PERFORM bdc_field  USING 'MBEW-BKLAS'   g_mm01_wa-bklas.
**         IF g_mm01_wa-mtart EQ 'ZCAP'.
**           PERFORM bdc_field  USING 'MBEW-VPRSV'   'V'.
**         ENDIF.
*         PERFORM bdc_field  USING 'MBEW-PEINH'   '1'.
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 16.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 2
*      IF ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BWPRS'.
*       ENDIF.
*
*     ELSEIF g_mm01_wa-bwtar NE space AND g_mm01_wa-mtart NE 'ZCAP' .
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(15)'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
*
*       IF g_mm01_wa-mtart EQ 'ZSTO'.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(07)' 'X'.
*       ELSEIF g_mm01_wa-mtart EQ 'ZSPR'.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(06)' 'X'.
*       ENDIF.
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0080'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'RMMG1-BWTAR'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
*       PERFORM bdc_field  USING 'RMMG1-WERKS'  g_mm01_wa-werks.
*       PERFORM bdc_field  USING 'RMMG1-BWTAR'  g_mm01_wa-bwtar.
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BKLAS'.
*       PERFORM bdc_field  USING 'MBEW-BKLAS'  g_mm01_wa-bklas.
*       PERFORM bdc_field  USING 'MBEW-PEINH'  '1'.
*
*     ENDIF.
*
*     PERFORM bdc_dynpro USING 'SAPLSPO1'    '0300'.
*     PERFORM bdc_field  USING 'BDC_OKCODE'  '=YES'.
*
*
*     PERFORM bdc_transaction USING 'MM01'
*                                    g_mm01_wa.
*
*
*     CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 10.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 1
*      IF ( msichtausw-dytxt+17(2) EQ '18' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
*        OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' ) .
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-AUSME'.
*
**--------start of code comment by rk001 -----------------------------*
**           IF g_mm01_wa-mtart EQ 'ZCAP'.                     "-rk001
**               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
**           ENDIF.                                            "-rk001
**--------end of code comment by rk001 -----------------------------*
*
**         PERFORM bdc_field  USING 'MARA-IPRKZ'   'D'.
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 11.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 2
*      IF ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
*       OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )  .
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
**         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'.  "-RK001
*         IF g_mm01_wa-mtart EQ 'ZCAP'.
*           PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'."+RK001
*           PERFORM bdc_field  USING 'MARC-SERNP'   '0001'.
*         ENDIF.
**------START OF ADD BY RK001----------------------------------*
*         CLEAR L_PRCTR.
*         SELECT SINGLE PRCTR FROM MARC INTO L_PRCTR WHERE
*                                     MATNR = g_mm01_wa-matnr AND
*                                     WERKS = g_mm01_wa-werks.
*         IF L_PRCTR IS INITIAL.
*           PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.
*         ENDIF.
*
**      PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.  "-RK001
**------END OF ADD BY RK001----------------------------------*
*
*       ENDIF.
*
*
*       IF g_mm01_wa-lgnum NE space.
*         CLEAR msichtausw.
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 12.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 1
*      IF ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
*       OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )  .
*           PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**          PERFORM bdc_field  USING 'BDC_CURSOR' 'RMMG1-LGNUM'.  "-RK001
*         ENDIF.
*
*         CLEAR msichtausw.
*         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 13.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 2
*      IF ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
*        OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' ) .
*           PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
*           PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
*           PERFORM bdc_field  USING 'BDC_CURSOR' 'MLGN-LHMG1'.
*         ENDIF.
*
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 14.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. "  Quality Mgt
*      IF ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' ).
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*
*         IF g_mm01_wa-prodh EQ '10'.
*           PERFORM bdc_field  USING 'MARC-QMATA'  '000002'.
*         ELSE.
*           PERFORM bdc_field  USING 'MARC-QMATA'  '000001'.
*         ENDIF.
*
*         PERFORM bdc_field  USING 'MARC-KZDKZ'  'X'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-SSQSS'.
*
*         IF l_qmpur IS INITIAL.
*           PERFORM bdc_field  USING 'MARA-QMPUR'  'X'.
*         ENDIF.
*
*         PERFORM bdc_field  USING 'MARC-SSQSS'  '0000'.
*
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 15.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 1
*      IF ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' ).
*
*         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BWTTY'.
*         PERFORM bdc_field  USING 'MBEW-BWTTY'   g_mm01_wa-bwtty.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BKLAS'.
*         PERFORM bdc_field  USING 'MBEW-BKLAS'   g_mm01_wa-bklas.
**         IF g_mm01_wa-mtart EQ 'ZCAP'.
**           PERFORM bdc_field  USING 'MBEW-VPRSV'   'V'.
**         ENDIF.
*         PERFORM bdc_field  USING 'MBEW-PEINH'   '1'.
*       ENDIF.
*
*       CLEAR msichtausw.
*       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 16.
**        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 2
*      IF ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
*      OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' )
*            OR ( msichtausw-dytxt+17(2) EQ '09' AND msichtausw-kzsel EQ 'X' ) .
*         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BWPRS'.
*       ENDIF.
*
*     ELSEIF g_mm01_wa-bwtar NE space AND g_mm01_wa-mtart NE 'ZCAP' .
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(15)'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
*
*       IF g_mm01_wa-mtart EQ 'ZSTO'.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(07)' 'X'.
*       ELSEIF g_mm01_wa-mtart EQ 'ZSPR'.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(06)' 'X'.
*       ENDIF.
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0080'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'RMMG1-BWTAR'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
*       PERFORM bdc_field  USING 'RMMG1-WERKS'  g_mm01_wa-werks.
*       PERFORM bdc_field  USING 'RMMG1-BWTAR'  g_mm01_wa-bwtar.
*
*       PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
*       PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*       PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BKLAS'.
*       PERFORM bdc_field  USING 'MBEW-BKLAS'  g_mm01_wa-bklas.
*       PERFORM bdc_field  USING 'MBEW-PEINH'  '1'.
*
*     ENDIF.
*
*     PERFORM bdc_dynpro USING 'SAPLSPO1'    '0300'.
*     PERFORM bdc_field  USING 'BDC_OKCODE'  '=YES'.
*
*
*     PERFORM bdc_transaction USING 'MM01'
*                                    g_mm01_wa.




***New one
   DATA: l_index TYPE sy-index.
   DATA: l_tragr TYPE mara-tragr.
   DATA: l_qmpur TYPE mara-qmpur.
   DATA: l_prctr like marc-prctr.                           "+rk001


   clear l_prctr.                                           "+rk001
   LOOP AT g_mm01_ist INTO g_mm01_wa.

     SELECT SINGLE tragr qmpur FROM mara INTO (l_tragr, l_qmpur)
           WHERE matnr EQ g_mm01_wa-matnr.

     PERFORM bdc_dynpro USING 'SAPLMGMM'   '0060'.
     PERFORM bdc_field  USING 'BDC_CURSOR'    'RMMG1-MATNR'.
     PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
     PERFORM bdc_field  USING 'RMMG1-MATNR'   g_mm01_wa-matnr.

     PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
     PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(16)'.
     PERFORM bdc_field  USING 'BDC_OKCODE'  '=P+'.

     IF g_mm01_wa-bwtar EQ space .

       CLEAR: l_index, msichtausw.
       l_index = 1.
       IF g_mm01_wa-mtart EQ 'ZCAP'.
         DO 9 TIMES.
           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
           l_index = l_index + 1.
         ENDDO.
       ELSEIF g_mm01_wa-mtart EQ 'ZSTO' OR g_mm01_wa-mtart EQ 'ZSPR'.
         DO 9 TIMES.
           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
           l_index = l_index + 1.
         ENDDO.
       ENDIF.

       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
       PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(08)'.
       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.

       IF g_mm01_wa-mtart EQ 'ZCAP'.
         DO 7 TIMES.
           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
           l_index = l_index + 1.
         ENDDO.
       ELSEIF g_mm01_wa-mtart EQ 'ZSTO' OR g_mm01_wa-mtart EQ 'ZSPR'.
         DO 7 TIMES.
           READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX l_index.
           PERFORM bdc_field  USING msichtausw-dytxt msichtausw-kzsel.
           l_index = l_index + 1.
         ENDDO.
       ENDIF.

       IF g_mm01_wa-werks NE  '90R1'.
         PERFORM bdc_dynpro USING 'SAPLMGMM'     '0080'.
         read table it_views with key text = 'V'.           "+rk001
         if sy-subrc <> 0.                                  "+rk001
           PERFORM bdc_field  USING 'BDC_CURSOR'   'RMMG1-VTWEG'.
         endif.                                             "+rk001
         PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTR'.
         PERFORM bdc_field  USING 'RMMG1-WERKS'   g_mm01_wa-werks.
         if not it_views-text eq 'V'.                       "+rk001
           PERFORM bdc_field  USING 'RMMG1-VKORG'   g_mm01_wa-vkorg .
           PERFORM bdc_field  USING 'RMMG1-VTWEG'   'ST'.
         endif.                                             "rk001
         IF g_mm01_wa-lgnum NE space.
           PERFORM bdc_field  USING 'RMMG1-LGNUM'   g_mm01_wa-lgnum.
         ENDIF.


         CLEAR msichtausw.
         READ TABLE g_mm01_wa-zksel INTO msichtausw  INDEX 1.
*           WITH KEY dytxt = 'MSICHTAUSW-KZSEL(05)' . "Sales Org 1
         IF msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X'.

           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*           PERFORM bdc_field  USING 'MVKE-SKTOF'  'X'.         "-rk002
           PERFORM bdc_field  USING 'BDC_CURSOR'  'MG03STEUER-TAXKM(02)'.
           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(01)'  '1'.
           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(02)'  '1'.

           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4200'.
           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
           PERFORM bdc_field  USING 'BDC_CURSOR'  'MG03STEUER-TAXKM(04)'.
           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(03)'  '1'.
           PERFORM bdc_field  USING 'MG03STEUER-TAXKM(04)'  '1'.

           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
           PERFORM bdc_field  USING 'BDC_CURSOR'  'MARA-SPART'.
*           PERFORM bdc_field  USING 'MVKE-SKTOF'  'X'.        "-rk002

         ENDIF.

         CLEAR msichtausw.

         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 2.
*           WITH KEY dytxt = 'MSICHTAUSW-KZSEL(06)'. " Sales Org 2

         IF msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X'.

           PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
           PERFORM bdc_field  USING 'BDC_OKCODE'    '/00'.
           PERFORM bdc_field  USING 'BDC_CURSOR'   'MVKE-VERSG'.
           PERFORM bdc_field  USING 'MVKE-VERSG'   '1'.
           PERFORM bdc_field  USING 'MVKE-MTPOS'   'NORM'.
           PERFORM bdc_field  USING 'MVKE-PRODH'   g_mm01_wa-prodh.

         ENDIF.

         CLEAR msichtausw.

         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 3.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(07)'. " Sales: General/Plant

         IF msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X'.

           PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
           PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*         PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.        "-rk001

*--------code add by rk001 --------------------------------------*

           select single * from marc where matnr = g_mm01_wa-matnr
                                     and werks = g_mm01_wa-werks
                                     and mtvfp <> ' '.
           if not sy-subrc is initial.
             PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.
           endif.
*           IF g_mm01_wa-mtart EQ 'ZCAP'.   "-rk001
*               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
*           ENDIF.                          "-rk001

           IF g_mm01_wa-mtart EQ 'ZCAP'.
             select single * from marc where matnr = g_mm01_wa-matnr AND
                                             WERKS = g_mm01_wa-werks and
                                               XCHPF = ' '.
             if sy-subrc is initial.
               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.
             endif.
           ENDIF.
*-------end of code add by rk001---------------------------------*
           IF l_tragr IS INITIAL.
             PERFORM bdc_field  USING 'MARA-TRAGR'  '0001'.
           ENDIF.

           PERFORM bdc_field  USING 'MARC-LADGR'  'STK'.
*------START OF ADD BY RK001----------------------------------*

           SELECT SINGLE PRCTR FROM MARC INTO L_PRCTR WHERE
                                       MATNR = g_mm01_wa-matnr AND
                                       WERKS = g_mm01_wa-werks.
           IF L_PRCTR IS INITIAL.
             PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PRCTR'.
             PERFORM bdc_field  USING 'MARC-PRCTR'  g_mm01_wa-prctr.
           ENDIF.
*           PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PRCTR'. "-RK001
*           PERFORM bdc_field  USING 'MARC-PRCTR'  g_mm01_wa-prctr. *
*"-RK001
*-------END OF ADD BY RK001-----------------------------------*
         ENDIF.

       ELSE.

         PERFORM bdc_dynpro USING 'SAPLMGMM'     '0080'.
         PERFORM bdc_field  USING 'BDC_CURSOR'   'RMMG1-WERKS'.
         PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTR'.
         PERFORM bdc_field  USING 'RMMG1-WERKS'   g_mm01_wa-werks.

       ENDIF.

       CLEAR msichtausw.

       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 4.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(10)'. " Purchasing

       IF msichtausw-dytxt+17(2) EQ '10' AND msichtausw-kzsel EQ 'X'.

         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARA-BSTME'.
*--------start of comment by rk001 -----------------------------*
*           IF g_mm01_wa-mtart EQ 'ZCAP'.                     "-rk001
*               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
*           ENDIF.                                            "-rk001

*--------end of code comment by rk001 -----------------------------*

       ENDIF.

       CLEAR msichtausw.

       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 5.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(12)'. " Purchase order text

       IF msichtausw-dytxt+17(2) EQ '12' AND msichtausw-kzsel EQ 'X'.

         PERFORM bdc_dynpro USING 'SAPLMGMM'   '4040'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'RMMG1-MATNR'.

       ENDIF.

       CLEAR msichtausw.

       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 6.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(13)'. " MRP 1

       IF msichtausw-dytxt+17(2) EQ '13' AND msichtausw-kzsel EQ 'X'.

         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-DISPO'.
         PERFORM bdc_field  USING 'MARC-DISMM'  'ND'.
         PERFORM bdc_field  USING 'MARC-DISPO'  g_mm01_wa-dispo.

       ENDIF.

       CLEAR msichtausw.

       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 7.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(14)'. " MRP 2

       IF msichtausw-dytxt+17(2) EQ '14' AND msichtausw-kzsel EQ 'X'.

         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'MARC-BESKZ'  'F'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-FHORI'.
         PERFORM bdc_field  USING 'MARC-FHORI'  '000'.

       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 8.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(15)'. " MRP 3
       IF msichtausw-dytxt+17(2) EQ '15' AND msichtausw-kzsel EQ 'X'.
         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-PERKZ'.
         PERFORM bdc_field  USING 'MARC-PERKZ'  'M'.
*--------code add by rk001 --------------------------------------*

         select single * from marc where matnr = g_mm01_wa-matnr
                                   and werks = g_mm01_wa-werks
                                   and mtvfp <> ' '.
         if not sy-subrc is initial.
           PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.
         endif.
*-------end of code add by rk001---------------------------------*

*         PERFORM bdc_field  USING 'MARC-MTVFP'  '02'.        "-rk001
       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 9.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " MRP 4
       IF msichtausw-dytxt+17(2) EQ '16' AND msichtausw-kzsel EQ 'X'.
         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-ALTSL'.
       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 10.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 1
       IF ( msichtausw-dytxt+17(2) EQ '18' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-AUSME'.

*--------start of code comment by rk001 -----------------------------*
*           IF g_mm01_wa-mtart EQ 'ZCAP'.                     "-rk001
*               PERFORM bdc_field  USING 'MARC-XCHPF'   'X'.  "-rk001
*           ENDIF.                                            "-rk001
*--------end of code comment by rk001 -----------------------------*

*         PERFORM bdc_field  USING 'MARA-IPRKZ'   'D'.
       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 11.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Plant data/store 2
       IF ( msichtausw-dytxt+17(2) EQ '01' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
*         PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'.  "-RK001
         IF g_mm01_wa-mtart EQ 'ZCAP'.
           PERFORM bdc_field  USING 'BDC_CURSOR'   'MARC-SERNP'. "+RK001
           PERFORM bdc_field  USING 'MARC-SERNP'   '0001'.
         ENDIF.
*------START OF ADD BY RK001----------------------------------*
         CLEAR L_PRCTR.
         SELECT SINGLE PRCTR FROM MARC INTO L_PRCTR WHERE
                                     MATNR = g_mm01_wa-matnr AND
                                     WERKS = g_mm01_wa-werks.
         IF L_PRCTR IS INITIAL.
           PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.
         ENDIF.

*      PERFORM bdc_field  USING 'MARC-PRCTR'   g_mm01_wa-prctr.  "-RK001
*------END OF ADD BY RK001----------------------------------*

       ENDIF.


       IF g_mm01_wa-lgnum NE space.

         CLEAR msichtausw.
         READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 12.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 1
         IF ( msichtausw-dytxt+17(2) EQ '02' AND msichtausw-kzsel EQ 'X' )
         OR ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
         OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
         OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )  .
           PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
           PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RMMG1-LGNUM'.  "-RK001
         ENDIF.
       endif.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 13.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Warehouse 2
       IF ( msichtausw-dytxt+17(2) EQ '03' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'   '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR' 'MLGN-LHMG1'.
       ENDIF.




       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 14.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. "  Quality Mgt
       IF ( msichtausw-dytxt+17(2) EQ '04' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.

         IF g_mm01_wa-prodh EQ '10'.
           PERFORM bdc_field  USING 'MARC-QMATA'  '000002'.
         ELSE.
           PERFORM bdc_field  USING 'MARC-QMATA'  '000001'.
         ENDIF.

         PERFORM bdc_field  USING 'MARC-KZDKZ'  'X'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MARC-SSQSS'.

         IF l_qmpur IS INITIAL.
           PERFORM bdc_field  USING 'MARA-QMPUR'  'X'.
         ENDIF.

         PERFORM bdc_field  USING 'MARC-SSQSS'  '0000'.

       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 15.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 1
       IF ( msichtausw-dytxt+17(2) EQ '05' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'     '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'   '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BWTTY'.
         PERFORM bdc_field  USING 'MBEW-BWTTY'   g_mm01_wa-bwtty.
         PERFORM bdc_field  USING 'BDC_CURSOR'   'MBEW-BKLAS'.
         PERFORM bdc_field  USING 'MBEW-BKLAS'   g_mm01_wa-bklas.
*         IF g_mm01_wa-mtart EQ 'ZCAP'.
*           PERFORM bdc_field  USING 'MBEW-VPRSV'   'V'.
*         ENDIF.
         PERFORM bdc_field  USING 'MBEW-PEINH'   '1'.
       ENDIF.

       CLEAR msichtausw.
       READ TABLE g_mm01_wa-zksel INTO msichtausw INDEX 16.
*        WITH KEY dytxt = 'MSICHTAUSW-KZSEL(16)'. " Accounting 2
       IF ( msichtausw-dytxt+17(2) EQ '06' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '07' AND msichtausw-kzsel EQ 'X' )
       OR ( msichtausw-dytxt+17(2) EQ '08' AND msichtausw-kzsel EQ 'X' )
        OR ( msichtausw-dytxt+17(2) EQ '09' AND msichtausw-kzsel EQ 'X' )  .
         PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
         PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
         PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BWPRS'.
       ENDIF.

     ELSEIF g_mm01_wa-bwtar NE space AND g_mm01_wa-mtart NE 'ZCAP' .

       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0070'.
       PERFORM bdc_field  USING 'BDC_CURSOR'  'MSICHTAUSW-DYTXT(15)'.
       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.

       IF g_mm01_wa-mtart EQ 'ZSTO'.
*Begin of <RD1K960618>.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(07)' 'X'.
*End of <RD1K960618>.
         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(08)' 'X'.
       ELSEIF g_mm01_wa-mtart EQ 'ZSPR'.
*Begin of <RD1K960618>.
*         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(06)' 'X'.
*End of <RD1K960618>.
         PERFORM bdc_field  USING 'MSICHTAUSW-KZSEL(07)' 'X'.
       ENDIF.

       PERFORM bdc_dynpro USING 'SAPLMGMM'    '0080'.
       PERFORM bdc_field  USING 'BDC_CURSOR'  'RMMG1-BWTAR'.
       PERFORM bdc_field  USING 'BDC_OKCODE'  '=ENTR'.
       PERFORM bdc_field  USING 'RMMG1-WERKS'  g_mm01_wa-werks.
       PERFORM bdc_field  USING 'RMMG1-BWTAR'  g_mm01_wa-bwtar.

       PERFORM bdc_dynpro USING 'SAPLMGMM'    '4000'.
       PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
       PERFORM bdc_field  USING 'BDC_CURSOR'  'MBEW-BKLAS'.
       PERFORM bdc_field  USING 'MBEW-BKLAS'  g_mm01_wa-bklas.
       PERFORM bdc_field  USING 'MBEW-PEINH'  '1'.

     ENDIF.

     PERFORM bdc_dynpro USING 'SAPLSPO1'    '0300'.
     PERFORM bdc_field  USING 'BDC_OKCODE'  '=YES'.


     PERFORM bdc_transaction USING 'MM01'
                                    g_mm01_wa.

*End of <RD1K960036>.

*                +007
     perform  mat_ext_insp.
*           007
     CLEAR g_mm01_wa.

     CLEAR g_mm01_wa.

     CLEAR : l_tragr, l_qmpur.

   ENDLOOP.

   DATA : BEGIN OF ist_flag OCCURS 0,
         sflag LIKE zmm_mems-sflag,
         END OF ist_flag.

   DATA : BEGIN OF ist_docno OCCURS 0,
         docno LIKE zmm_mems-docno,
         END OF ist_docno.

   CLEAR ist_docno.
   LOOP AT g_tc_child_itab INTO g_tc_child_wa.
     ist_docno-docno = g_tc_child_wa-docno.
     APPEND ist_docno.
   ENDLOOP.

   SORT ist_docno.
   DELETE ADJACENT DUPLICATES FROM ist_docno.

   CLEAR ist_docno. clear ist_flag. refresh ist_flag.
   LOOP AT ist_docno.
     CLEAR zmm_mecs.
     SELECT * FROM zmm_mecs WHERE docno = g_tc_child_wa-docno.
       ist_flag-sflag = zmm_mecs-sflag.
       APPEND ist_flag.
     ENDSELECT.

     CLEAR zmm_mems.

     SELECT SINGLE * FROM zmm_mems WHERE docno = ist_docno-docno.

     DELETE ist_flag WHERE sflag = 'C'.

     DATA : n TYPE i.

     DESCRIBE TABLE ist_flag LINES n.

     IF n LE 0.
       zmm_mems-sflag = 'C'.
       zmm_mems-laeda = sy-datum.
       zmm_mems-aenam = sy-uname.
       MODIFY zmm_mems.
     ELSEIF n GT 0.
       zmm_mems-sflag = 'P'.
       zmm_mems-laeda = sy-datum.
       zmm_mems-aenam = sy-uname.
       MODIFY zmm_mems.
       SELECT * FROM zmm_mecs WHERE sflag NE 'C'.
         zmm_mecs-sflag = 'P'.
         MODIFY zmm_mecs.
       ENDSELECT.
     ENDIF.
     CLEAR n.
   ENDLOOP.

   IF NOT g_tc_child_itab[] IS INITIAL.
     DATA: l_count TYPE i VALUE 0.
     LOOP AT ist_msg INTO wa_msg.
       IF wa_msg-msgtyp EQ 'E'.
         l_count = l_count + 1.
       ENDIF.
     ENDLOOP.
     MESSAGE s749(zmm) WITH l_count.
     CLEAR l_count.
   ENDIF.

*   DELETE ist_msg WHERE msgv1 CS 'type'.
*   DELETE ist_msg WHERE msgv1 CS 'exists'.
*   DELETE ist_msg WHERE msgv1 CS 'Field'.
*   DELETE ist_msg WHERE msgv1 CS 'text'.
*   DELETE ist_msg WHERE msgv1 CS 'tax'.
*   DELETE ist_msg WHERE msgv1 CS 'price'.

 ENDFORM.                    " POPULATE_RECORD
*----------------------------------------------------------------------
*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
 FORM bdc_transaction USING tcode
                            p_wa TYPE t_mm01.

*Comment by SAB_NITIN
*   DATA: plants LIKE marc_werk OCCURS 0 WITH HEADER LINE.
*   DATA: l_mstring(480).
*   DATA: l_subrc LIKE sy-subrc.
*   DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
*   DATA: cupdate LIKE ctu_params-updmode VALUE 'S'.
*   DATA: smalllog TYPE c." VALUE 'X'.
*Comment by SAB_NITIN

   REFRESH messtab.

   CALL TRANSACTION tcode USING bdcdata
                    MODE   ctumode
                    UPDATE cupdate
                    MESSAGES INTO messtab.


   LOOP AT messtab.

     SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
                               AND   arbgb = messtab-msgid
                               AND   msgnr = messtab-msgnr.
     IF sy-subrc = 0.

       l_mstring = t100-text.

       IF l_mstring CS '&1'.

         REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
         REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
         REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
         REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.

       ELSE.

         REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
         REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
         REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
         REPLACE '&' WITH messtab-msgv4 INTO l_mstring.

       ENDIF.

       CONDENSE l_mstring.

       IF p_wa-mtart EQ 'ZCAP'.
         p_wa-bwtar = 'BATCH_MNGD'.
       ENDIF.
       MOVE p_wa-docno  TO wa_msg-docno.                    "+rk003
       MOVE p_wa-matnr  TO wa_msg-matnr.
       MOVE p_wa-bwtar  TO wa_msg-bwtar.
       MOVE messtab-msgtyp   TO wa_msg-msgtyp.
       MOVE l_mstring        TO wa_msg-msgv1.
       APPEND wa_msg TO ist_msg.

*----comment line 1356 by rk005
*       IF messtab-msgid EQ 'M3' AND messtab-msgnr EQ '800'.
       CLEAR plants.
       CALL FUNCTION 'MATERIAL_READ_PLANTS'
         EXPORTING
           matnr  = p_wa-matnr
         TABLES
           plants = plants.

       READ TABLE plants WITH KEY matnr = p_wa-matnr
                                  werks = p_wa-werks.
       IF sy-subrc EQ 0.
*------------code change by rk005 -----------------------*
*           SELECT SINGLE * FROM zmm_mecs
*                            WHERE matnr = p_wa-matnr
*                              AND werks = p_wa-werks
*                              AND bwtar = p_wa-bwtar
*                              AND sflag = 'N'.
         SELECT  * FROM zmm_mecs WHERE matnr = p_wa-matnr
                                 AND werks = p_wa-werks
                                 AND bwtar = p_wa-bwtar.
*                                   AND sflag = 'N'.  "-rk005
*------------code change by rk005 -----------------------*

           IF sy-subrc EQ 0.
             zmm_mecs-pstat = plants-pstat.
             zmm_mecs-sflag = 'C'.
             zmm_mecs-laeda = sy-datum.
             zmm_mecs-aenam = sy-uname.
             CONCATENATE 'Material' p_wa-matnr 'extended' INTO
             zmm_mecs-remrk SEPARATED BY space.
             MODIFY zmm_mecs.
           ENDIF.
         ENDSELECT.                                         "+rk005
       ENDIF.
*       ENDIF.                "-rk005

     ENDIF.
   ENDLOOP.
*    +007
    g_tmp_wa =   g_mm01_wa.
*    +007
   CLEAR p_wa.

   REFRESH bdcdata.

 ENDFORM.                    "bdc_transaction
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
 FORM bdc_dynpro USING program dynpro.
   CLEAR bdcdata.
   bdcdata-program  = program.
   bdcdata-dynpro   = dynpro.
   bdcdata-dynbegin = 'X'.
   APPEND bdcdata.
 ENDFORM.                    "bdc_dynpro
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
 FORM bdc_field USING fnam fval.
   IF fval <> nodata.
     CLEAR bdcdata.
     bdcdata-fnam = fnam.
     bdcdata-fval = fval.
     APPEND bdcdata.
   ENDIF.
 ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  CHECK_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM check_record.

   REFRESH ist_msg.

   DATA: general_data LIKE bapimatdoa.
   DATA: return LIKE bapireturn.
   DATA: plantdata LIKE bapimatdoc.
   DATA: valuationdata LIKE bapimatdobew.
   DATA: plants TYPE TABLE OF marc_werk WITH HEADER LINE.
   DATA: l_views(1) type n.                                 "+rk001
   DATA: l_mstae like mara-mstae.                           "+rk001
   DATA: l_mtstb like t141t-mtstb.                          "+rk001

   LOOP AT g_tc_child_itab INTO g_tc_child_wa.

*--------start of changes by rk001------------------------------------*
     clear :l_mstae, l_mtstb.
     select single mstae from mara into l_mstae where
                                       matnr = g_tc_child_wa-matnr.
     if not l_mstae is initial.
       select single mtstb from t141t into l_mtstb where
                                      mmsta = l_mstae and
                                      spras = 'E'.
       MOVE g_tc_child_wa-docno TO wa_msg-docno.
       MOVE g_tc_child_wa-matnr TO wa_msg-matnr.
       MOVE g_tc_child_wa-bwtar TO wa_msg-bwtar.
       MOVE 'E' TO wa_msg-msgtyp.
       MOVE g_tc_child_wa-werks TO wa_msg-werks.
       concatenate 'Material' wa_msg-matnr 'BLOCKED,' l_mtstb into
                              wa_msg-msgv1 separated by space.
       APPEND wa_msg TO ist_msg.
       continue.
     endif.
*----------end of changes by rk001------------------------------------*


     CALL FUNCTION 'GET_PLANT_DETAILS'
       EXPORTING
         i_werks         = g_tc_child_wa-werks
       IMPORTING
         e_t001w         = t001w
       EXCEPTIONS
         not_found       = 1
         parameter_error = 2
         OTHERS          = 3.

     IF sy-subrc EQ 0.

       IF g_tc_child_wa-bwtar EQ 'BATCH_MNGD'.
         CLEAR g_tc_child_wa-bwtar.
       ENDIF.

       CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'   "#EC CI_USAGE_OK[2438131]
         EXPORTING
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*           material              = g_tc_child_wa-matnr
           material_long             = g_tc_child_wa-matnr
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
           plant                 = g_tc_child_wa-werks
           valuationarea         = t001w-bwkey
           valuationtype         = g_tc_child_wa-bwtar
         IMPORTING
           material_general_data = general_data
           return                = return
           materialplantdata     = plantdata
           materialvaluationdata = valuationdata.

       IF return-type EQ 'S'.

         CALL FUNCTION 'MATERIAL_READ_PLANTS'
           EXPORTING
             matnr  = g_tc_child_wa-matnr
           TABLES
             plants = plants.
*       READ TABLE plants WITH KEY werks = g_tc_child_wa-werks.  "-rk001

         READ TABLE plants WITH KEY werks = g_tc_child_wa-werks "+rk001
                                    matnr = g_tc_child_wa-matnr. "rk001

         IF sy-subrc EQ 0.
           DATA : l_strlen TYPE i.
           l_strlen = strlen( plants-pstat ).
*--------start of changes by rk001------------------------------------*

*           IF l_strlen < 6.                      "-rk001
           CLEAR t320.                                      "+rk001
           clear l_views.
           SELECT SINGLE * FROM t320 WHERE werks EQ g_tc_child_wa-werks.
           if sy-subrc is initial.
             l_views = 7.
           else.
             l_views = 6.
           endif.

           IF l_strlen = l_views.                           "+rk001
*----------end of changes by rk001------------------------------------*
             MOVE g_tc_child_wa-docno TO wa_msg-docno.
             MOVE g_tc_child_wa-matnr TO wa_msg-matnr.
             IF general_data-matl_type EQ 'ZCAP'.
               g_tc_child_wa-bwtar = 'BATCH_MNGD'.
             ENDIF.
             MOVE g_tc_child_wa-bwtar TO wa_msg-bwtar.
*             MOVE 'E'                 TO wa_msg-msgtyp.    "-rk003
             MOVE 'W'                 TO wa_msg-msgtyp.     "+RK003
             MOVE g_tc_child_wa-werks TO wa_msg-werks.      "+rk001
             CONCATENATE 'Valuation type' g_tc_child_wa-bwtar
                         'for material' g_tc_child_wa-matnr
                         'and plant' g_tc_child_wa-werks
                         'already maintained.' INTO wa_msg-msgv1
                          SEPARATED BY space.
             APPEND wa_msg TO ist_msg.
             CLEAR wa_msg-msgv1.
           ENDIF.
           CLEAR l_strlen.
         ENDIF.
       ENDIF.

     ENDIF.
     CLEAR: t001w, g_tc_child_wa, general_data, return.
     CLEAR plants.
   ENDLOOP.

   IF ist_msg IS INITIAL.
     g_check_flag = 'X'.
   ELSE.
     LOOP AT ist_msg INTO wa_msg.
       IF wa_msg-msgtyp = 'E' OR wa_msg-msgtyp = 'W' .
         read table g_tc_child_itab into g_tc_child_wa with key
                                           docno = wa_msg-docno "+rk003
                                           matnr = wa_msg-matnr
                                           werks = wa_msg-werks
                                           bwtar = wa_msg-bwtar.
         if sy-subrc is initial.
           delete g_tc_child_itab index sy-tabix.
         endif.
*         DELETE g_tc_child_itab WHERE matnr EQ wa_msg-matnr    "-rk001
*                                  AND bwtar EQ wa_msg-bwtar.   "-rk001

       ENDIF.
     ENDLOOP.
     g_check_flag = 'X'.
   ENDIF.
*------------rk003
*   DATA : BEGIN OF ist_flag OCCURS 0,
*           sflag LIKE zmm_mems-sflag,
*          END OF ist_flag.
*
*   DATA : BEGIN OF ist_docno OCCURS 0,
*           docno LIKE zmm_mems-docno,
*          END OF ist_docno.
*
*   CLEAR ist_docno.
*   LOOP AT g_tc_parent_itab INTO g_tc_parent_wa WHERE flag = 'X'.
*     ist_docno-docno = g_tc_parent_wa-docno.
*     APPEND ist_docno.
*   ENDLOOP.
*
*   CLEAR ist_docno.
*   LOOP AT ist_docno.
*
*     READ TABLE g_tc_child_itab
*     INTO g_tc_child_wa WITH KEY docno =  ist_docno-docno.
*
*     IF sy-subrc NE 0.
*
*       SELECT * FROM zmm_mecs WHERE sflag NE 'C'.
*         zmm_mecs-sflag = 'C'.
*         zmm_mecs-pstat = 'VEDLSQB'.
*         zmm_mecs-laeda = sy-datum.
*         zmm_mecs-aenam = sy-uname.
*         CONCATENATE 'Material' zmm_mecs-matnr 'extended.'
*         INTO zmm_mecs-remrk SEPARATED BY space.
*         MODIFY zmm_mecs.
*       ENDSELECT.
*
*       CLEAR zmm_mems.
*
*       SELECT SINGLE * FROM zmm_mems WHERE docno = ist_docno-docno.
*       zmm_mems-sflag = 'C'.
*       zmm_mems-laeda = sy-datum.
*       zmm_mems-aenam = sy-uname.
*       MODIFY zmm_mems.
*
*     ENDIF.
*
*   ENDLOOP.
*-----rk003
 ENDFORM.                    " CHECK_RECORD
*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
 FORM fcode_tc_mail USING    p_tc_name
                             p_table_name
                             p_mark_name.


*   DELETE ADJACENT DUPLICATES FROM receivers.
*   IF NOT ( ist_msg IS INITIAL ).
*
*     LOOP AT ist_msg INTO wa_msg.
*       CLEAR object_content-line.
*       CONCATENATE wa_msg-matnr
*                   wa_msg-msgtyp
*                   wa_msg-bwtar
*                   wa_msg-msgv1
*                   INTO object_content-line SEPARATED BY space.
*       APPEND object_content.
*     ENDLOOP.
*
*   ENDIF.

 ENDFORM.                    " FCODE_TC_MAIL
*&---------------------------------------------------------------------*
*&      Form  search_views_extended
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC_CHILD_WA_MATNR  text
*      <--P_G_ALL  text
*      <--P_G_ONLY_SECOND  text
*----------------------------------------------------------------------*
 FORM search_views_extended USING    p_matnr
                                     p_werks
                            CHANGING p_all
                                     p_only_second.

   DATA: l_pstat(7).
   DATA: plants LIKE marc_werk OCCURS 0 WITH HEADER LINE.

   CLEAR p_only_second.

   CALL FUNCTION 'MATERIAL_READ_PLANTS'
     EXPORTING
       matnr  = p_matnr
     TABLES
       plants = plants.

   READ TABLE plants WITH KEY werks = p_werks.

   IF sy-subrc EQ 0.

     CLEAR l_pstat.

     IF plants-pstat NE 'VEDLSQB'.

       SEARCH plants-pstat FOR 'V'. "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'V'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'E'.  "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'E'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'D'.   "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'D'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'L'. "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'L'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'S'. "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'S'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'B'.  "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'B'.
         APPEND it_views.
       ENDIF.
       SEARCH plants-pstat FOR 'Q'. "#EC CI_NOORDER
       IF sy-subrc EQ 0.
         it_views-text = 'Q'.
         APPEND it_views.
       ENDIF.

     ELSEIF plants-pstat EQ 'VEDLSQB'.
       p_only_second = 'X'.
     ENDIF.

   ELSE.
     p_all = 'X'.
   ENDIF.


 ENDFORM.                    " search_views_extended
*&---------------------------------------------------------------------*
*&      Form  populate_view_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GENERAL_DATA_MATL_TYPE  text
*      -->P_G_ALL  text
*      -->P_G_ONLY_SECOND  text
*      <--P_G_MM01_WA_ZKSEL  text
*      <--P_ELSE  text
*----------------------------------------------------------------------*
 FORM populate_view_table USING    p_type
                                   p_lgnum
                                   p_werks
                          CHANGING p_zksel TYPE zksel.


   IF p_type EQ 'ZCAP'.

     IF p_werks EQ '90R1'.
       msichtausw-kzsel = ''.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(10)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(12)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(13)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(14)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(15)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(16)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(18)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(01)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.

     IF p_lgnum EQ space.
       msichtausw-kzsel = ' '.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(01)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(02)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(03)'.
     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(04)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(08)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.

   ELSEIF p_type EQ 'ZSTO'.

     IF p_werks EQ '90R1'.
       msichtausw-kzsel = ''.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(10)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(12)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(13)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(14)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(15)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(16)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
*960036
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(02)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(03)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*
*     IF p_lgnum EQ space.
*       msichtausw-kzsel = ''.
*     ELSE.
*       msichtausw-kzsel = 'X'.
*     ENDIF.
*
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(04)'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
*     APPEND msichtausw TO p_zksel.
*
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(08)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(03)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(04)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.

     IF p_lgnum EQ space.
       msichtausw-kzsel = ''.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(08)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(09)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.



   ELSEIF p_type EQ 'ZSPR'.
     IF p_werks EQ '90R1'.
       msichtausw-kzsel = ''.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(10)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(12)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(13)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(14)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(15)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(16)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
*Begin of <RD1K960036>.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(01)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(02)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*
*     IF p_lgnum EQ space.
*       msichtausw-kzsel = ''.
*     ELSE.
*       msichtausw-kzsel = 'X'.
*     ENDIF.
*
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(03)'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(04)'.
*     APPEND msichtausw TO p_zksel.
*
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
*     msichtausw-kzsel = 'X'.
*     APPEND msichtausw TO p_zksel.
*   ENDIF.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(02)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(03)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.

     IF p_lgnum EQ space.
       msichtausw-kzsel = ''.
     ELSE.
       msichtausw-kzsel = 'X'.
     ENDIF.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(04)'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(05)'.
     APPEND msichtausw TO p_zksel.

     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(06)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(07)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
     msichtausw-dytxt = 'MSICHTAUSW-KZSEL(08)'.
     msichtausw-kzsel = 'X'.
     APPEND msichtausw TO p_zksel.
   ENDIF.
*Begin of <RD1K960036>.
 ENDFORM.                    " populate_view_table
*&---------------------------------------------------------------------*
*&      Form  send_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM send_mail.

   TABLES: ttxob.
   DATA: zdocument_data LIKE sodocchgi1.
   DATA: zsend_to_all(1).
   DATA: BEGIN OF objhead OCCURS 5.
           INCLUDE STRUCTURE solisti1.
   DATA: END OF objhead.
   DATA: ztime(30).
   DATA: BEGIN OF $objhead.
           INCLUDE STRUCTURE thead.
   DATA: END OF $objhead.
   DATA: ztime1(20),ztime2(20).
   DATA object_content LIKE solisti1  OCCURS 0 WITH HEADER LINE.
   DATA: receivers LIKE somlreci1 OCCURS 0 WITH HEADER LINE.

   DATA : l_cnt(6) TYPE n.
   DATA : l_tot_astno     TYPE sy-tabix,
          l_tot_astno_ind TYPE sy-tabix.
   DATA : l_date(10).

   DATA:  BEGIN OF i_msg OCCURS 0,
          docno LIKE zmm_mems-docno,
          END OF i_msg.

   DATA:  BEGIN OF users OCCURS 0,
          ernam TYPE ernam,
          END OF users.

   DATA: i_done TYPE TABLE OF zmm_mecs.
   DATA: i_fail TYPE TABLE OF zmm_mecs.
   DATA: wa TYPE zmm_mecs.

   zdocument_data-obj_name   = 'MAIL'.
   zdocument_data-obj_langu  = sy-langu .
   zdocument_data-obj_expdat = sy-datum + 10 .
   zdocument_data-obj_prio   = '1'.
   zdocument_data-no_change  = 'X'.
   zdocument_data-priority   = '1'.
*  zdocument_data-expiry_dat = sy-datum + 10.
*   zdocument_data-proc_syst  = 'RD1CLNT100'.    "-RK003
*   zdocument_data-proc_syst  = 'RP1CLNT500'.
*   zdocument_data-proc_clint = '100'.           "-RK003
   zdocument_data-obj_descr  = text-008.

   CLEAR: $objhead.
   SELECT SINGLE * FROM ttxob WHERE tdobject EQ 'APP-MAIL'.
   IF sy-subrc = 0.
     $objhead-tdform  = ttxob-tdform.
     $objhead-tdstyle = ttxob-tdstyle.
   ENDIF.
   objhead = $objhead.
   APPEND objhead.

   SORT g_tc_parent_itab BY ernam.
   LOOP AT g_tc_parent_itab INTO g_tc_parent_wa WHERE flag EQ 'X'.
     MOVE g_tc_parent_wa-ernam TO users-ernam.
     APPEND users.
   ENDLOOP.

   SORT users.
   DELETE ADJACENT DUPLICATES FROM users.

   LOOP AT users.

     REFRESH receivers.
     CLEAR receivers.
     receivers-receiver = users-ernam.
     receivers-rec_type = 'B'.
     receivers-express  = 'X'.
     APPEND receivers.

     CLEAR object_content-line.
     object_content-line = 'Dear Sir/Madame,'.
     APPEND object_content.
     CLEAR object_content-line.
     APPEND object_content.
     APPEND object_content.

     LOOP AT g_tc_parent_itab INTO g_tc_parent_wa
                             WHERE ernam EQ users-ernam
                               AND flag EQ 'X'.
       CLEAR object_content-line.
       CONCATENATE 'Kindly note your material extension request no'
                    g_tc_parent_wa-docno
                   'has been updated. Kindly check the request.'
                    INTO object_content-line SEPARATED BY space.

       APPEND object_content.
       CLEAR object_content-line.
       APPEND object_content.
       APPEND object_content.

       CLEAR object_content-line.
       object_content-line = 'Extension Log:-'.
       APPEND object_content.
       CLEAR object_content-line.
       APPEND object_content.

       REFRESH i_done.
       SELECT * FROM zmm_mecs INTO TABLE i_done
         WHERE docno = g_tc_parent_wa-docno
           AND sflag = 'C'.
       REFRESH i_fail.
       SELECT * FROM zmm_mecs INTO TABLE i_fail
              WHERE docno = g_tc_parent_wa-docno
                AND sflag <> 'C'.

       CLEAR wa.

       IF NOT i_done[] IS INITIAL.
         LOOP AT i_done INTO wa.
           CLEAR object_content-line.
           CONCATENATE wa-matnr wa-werks wa-bwtar wa-remrk
           INTO object_content-line SEPARATED BY space.
           APPEND object_content.
           CLEAR wa.
         ENDLOOP.
       ENDIF.

       IF NOT i_fail[] IS INITIAL.
         CLEAR wa.
         LOOP AT i_fail INTO wa.
           CLEAR object_content-line.
           CONCATENATE  wa-matnr wa-werks wa-bwtar wa-remrk
                        "error occured, kindly ckeck."
                        INTO object_content-line SEPARATED BY space.
           APPEND object_content.
         ENDLOOP.
       ENDIF.

     ENDLOOP.

     CLEAR object_content-line.
     APPEND object_content.
     APPEND object_content.

     CLEAR object_content-line.
     object_content-line = 'Regards.'.
     APPEND object_content.

     CLEAR object_content-line.
     object_content-line = 'Extension Team.'.
     APPEND object_content.

     CLEAR object_content-line.
     APPEND object_content.
     APPEND object_content.

     CLEAR object_content-line.
     object_content-line = text-009.
     APPEND object_content.

     IF NOT ( object_content IS INITIAL ).
       CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
         EXPORTING
           document_data              = zdocument_data
           document_type              = 'RAW'
         IMPORTING
           sent_to_all                = zsend_to_all
         TABLES
           object_header              = objhead
           object_content             = object_content
           receivers                  = receivers
         EXCEPTIONS
           too_many_receivers         = 1
           document_not_sent          = 2
           document_type_not_exist    = 3
           operation_no_authorization = 4
           parameter_error            = 5
           x_error                    = 6
           enqueue_error              = 7.

       CASE sy-subrc.
         WHEN 0.
*           MESSAGE s355(zmm).
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
     ENDIF.

     CLEAR object_content.                                  "+RK003
     REFRESH object_content.                                "+RK003

   ENDLOOP.

 ENDFORM.                    " send_mail
*&---------------------------------------------------------------------*
*&      Form  modify_zksel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM modify_zksel CHANGING p_zksel TYPE zksel.

   DATA : l_zksel TYPE msichtausw.

   CLEAR it_views.

   READ TABLE it_views WITH KEY text = 'V'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 1.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 1 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 2.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 2 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 3.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 3 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'E'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 4.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 4 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 5.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 5 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'D'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 6.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 6 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 7.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 7 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 8.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 8 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 9.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 9 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'L'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 10.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 10 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 11.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 11 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'S'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 12.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 12 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 13.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 13 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'Q'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 14.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 14 TRANSPORTING kzsel.

   ENDIF.

   READ TABLE it_views WITH KEY text = 'B'.

   IF sy-subrc EQ 0.

     READ TABLE p_zksel INTO l_zksel INDEX 15.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 15 TRANSPORTING kzsel.

     READ TABLE p_zksel INTO l_zksel INDEX 16.
     l_zksel-kzsel = space.
     MODIFY p_zksel FROM l_zksel INDEX 16 TRANSPORTING kzsel.

   ENDIF.

 ENDFORM.                    " modify_zksel
*----start of addition +007
*&---------------------------------------------------------------------*
*&      Form  mat_ext_insp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form mat_ext_insp.
ranges : r_matnr1 for qmat-matnr,
r_matnr2 for qmat-matnr.
r_matnr1-low = '01'.
r_matnr1-high = '17'.
r_matnr1-sign = 'I'.
r_matnr1-option = 'BT'.
append r_matnr1 .
clear r_matnr1.

r_matnr1-low = '0C'.
r_matnr1-high = '0C'.
r_matnr1-sign = 'I'.
r_matnr1-option = 'EQ'.
append r_matnr1 .
clear r_matnr1.

r_matnr2-low = '21'.
r_matnr2-high = '39'.
r_matnr2-sign = 'I'.
r_matnr2-option = 'BT'.
append r_matnr2 .
clear r_matnr2.

clear g_qmatnr .
clear g_qwerks.
clear g_qart .

g_qmatnr = g_tmp_wa-matnr .
g_qwerks = g_tmp_wa-werks.
if  g_qmatnr+0(2) in r_matnr1 .
    g_qart = '0101'.
elseif  g_qmatnr+0(2) in r_matnr2.
    g_qart = '0130'.
else.
      move 'inspectiontype not valid' to l_mstring.
      move g_tmp_wa-docno  to wa_msg-docno.                    "+rk003
       move g_tmp_wa-matnr to wa_msg-matnr.
       move l_mstring to wa_msg-msgv1.
       append wa_msg to ist_msg.
       clear wa_msg.
  exit.
endif.

select single  * from qmat into wa_qmat where
           art = g_qart
      and matnr = g_qmatnr
      and werks = g_qwerks.
if sy-subrc = 0.
  exit.
elseif sy-subrc <> 0.
 perform bdc_qa08.
endif.

endform.                    " mat_ext_insp
*&---------------------------------------------------------------------*
*&      Form  bdc_qa08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form bdc_qa08.
*refresh bdcdata.

*perform bdc_dynpro      using 'RQMQMM00' '1000'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'G_MATNR-LOW'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=MOD4'.
*perform bdc_field       using 'G_WERKS-LOW'
*                               g_qwerks.
*perform bdc_field       using 'G_MATNR-LOW'
*                               g_qmatnr.
*perform bdc_dynpro      using 'RQMQMM00' '1000'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '/00'.
*perform bdc_field       using 'G_WERKS-LOW'
*                               g_qwerks.
*perform bdc_field       using 'G_MATNR-LOW'
*                              g_qmatnr.
*perform bdc_field       using 'BDC_CURSOR'
*                              'G_ART4'.
*perform bdc_field       using 'G_AKT4'
*                              'X'.
*perform bdc_field       using 'G_ART4'
*                               g_qart.
*perform bdc_dynpro      using 'RQMQMM00' '1000'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=ONLI'.
*perform bdc_field       using 'G_WERKS-LOW'
*                               g_qwerks.
*perform bdc_field       using 'G_MATNR-LOW'
*                               g_qmatnr.
*perform bdc_field       using 'BDC_CURSOR'
*                              'G_ART4'.
*perform bdc_field       using 'G_AKT4'
*                              'X'.
*perform bdc_field       using 'G_ART4'
*                               g_qart.
*
*perform bdc_dynpro      using 'SAPLQPLS' '0100'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RMQAM-ARGUMENT'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=WEIT'.
*perform bdc_field       using 'RMQAM-EIN'
*                              'X'.
*perform bdc_field       using 'RMQAM-QKZVERF'
*                              '06'.
*perform bdc_field       using 'RMQAM-PPL'
*                              'X'.
*perform bdc_field       using 'RMQAM-DYN'
*                              'X'.
*perform bdc_field       using 'RMQAM-MER'
*                              'X'.
*perform bdc_field       using 'RMQAM-AVE'
*                              'X'.
**Begin of <RD1K960618>.
**perform bdc_dynpro      using 'SAPLSLVC_FULLSCREEN' '0500'.
**perform bdc_field       using 'BDC_OKCODE'
**                              '=&ALL'.
**
**perform bdc_dynpro      using 'SAPLSLVC_FULLSCREEN' '0500'.
**perform bdc_field       using 'BDC_OKCODE'
**                              '=BEAR'.
**End of <RD1K960618>.
*perform bdc_dynpro      using 'SAPMSSY0' '0120'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=&ALL'.
*
*perform bdc_dynpro      using 'SAPMSSY0' '0120'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=BEAR'.
*perform bdc_transaction_qa08 using 'QA08'   g_tmp_wa.



*----------Start +008
refresh bdcdata.

perform bdc_dynpro      using 'RQMQMM00' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_field       using 'G_WERKS-LOW'
                                g_qwerks.
perform bdc_field       using 'G_MATNR-LOW'
                              g_qmatnr.
perform bdc_field       using 'BDC_CURSOR'
                              'G_ART1'.
perform bdc_field       using 'G_NEU1'
                              'X'.
perform bdc_field       using 'G_AKT1'
                              'X'.
perform bdc_field       using 'G_ART1'
                               g_qart.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=&ALL'.
perform bdc_dynpro      using 'SAPMSSY0' '0120'.
perform bdc_field       using 'BDC_CURSOR'
                              '04/03'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BEAR'.
perform bdc_transaction_qa08 using 'QA08'  g_tmp_wa.


*----+End 008


endform.                    " bdc_qa08
*&---------------------------------------------------------------------*
*&      Form  bdc_transaction_qa08
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5740   text
*----------------------------------------------------------------------*
form bdc_transaction_qa08 using  tcode
 p_wa type t_mm01.

   refresh messtab.

   call transaction tcode using bdcdata
                    mode   ctumode
                    update cupdate
                    messages into messtab.


   loop at messtab.

     select single * from t100 where sprsl = messtab-msgspra
                               and   arbgb = messtab-msgid
                               and   msgnr = messtab-msgnr.
     if sy-subrc = 0.

       l_mstring = t100-text.

       if l_mstring cs '&1'.

         replace '&1' with messtab-msgv1 into l_mstring.
         replace '&2' with messtab-msgv2 into l_mstring.
         replace '&3' with messtab-msgv3 into l_mstring.
         replace '&4' with messtab-msgv4 into l_mstring.

       else.

         replace '&' with messtab-msgv1 into l_mstring.
         replace '&' with messtab-msgv2 into l_mstring.
         replace '&' with messtab-msgv3 into l_mstring.
         replace '&' with messtab-msgv4 into l_mstring.

       endif.

       condense l_mstring.

       move p_wa-docno  to wa_msg-docno.                    "+rk003
       move p_wa-matnr  to wa_msg-matnr.
       move l_mstring        to wa_msg-msgv1.
       append wa_msg to ist_msg.
     endif.
   refresh bdcdata.
  endloop.
endform.                    " bdc_transaction_qa08

*------------end of addition +007

*--- INCLUDE: MZMMMEEI01 ---*
***INCLUDE MZMMMEEI01 .
*---------------------------------------------------------------------*
*       MODULE TC_PARENT_MARK INPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_mark INPUT.


  IF tc_parent-line_sel_mode = 1 AND g_tc_parent_wa-flag = 'X'.
    LOOP AT g_tc_parent_itab INTO g_tc_parent_wa WHERE flag = 'X'.
      g_tc_parent_wa-flag = ''.
      MODIFY g_tc_parent_itab FROM g_tc_parent_wa TRANSPORTING flag.
    ENDLOOP.
    g_tc_parent_wa-flag = 'X'.
  ENDIF.

  MODIFY g_tc_parent_itab
    FROM g_tc_parent_wa
    INDEX tc_parent-current_line
    TRANSPORTING flag.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_USER_COMMAND INPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_user_command INPUT.

  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_PARENT'
                              'G_TC_PARENT_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  EXIT  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*---------------------------------------------------------------------*
*       MODULE TAB_CHILD_ACTIVE_TAB_GET INPUT                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tab_child_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_tab_child-tab1.
      g_tab_child-pressed_tab = c_tab_child-tab1.
    WHEN c_tab_child-tab2.
      g_tab_child-pressed_tab = c_tab_child-tab2.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE user_command_7000 INPUT.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MODIFY INPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_modify INPUT.
  MOVE-CORRESPONDING zmm_mecs TO g_tc_child_wa.
  MODIFY g_tc_child_itab
    FROM g_tc_child_wa
    INDEX tc_child-current_line.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MARK INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_mark INPUT.

  MODIFY g_tc_child_itab FROM g_tc_child_wa
                         INDEX tc_child-current_line
                         TRANSPORTING flag.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_USER_COMMAND INPUT                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_CHILD'
                              'G_TC_CHILD_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  CASE sy-ucomm.
    WHEN 'CHECK'.
      PERFORM check_record.
    WHEN 'EXTND'.
      PERFORM populate_record.
      g_extnd_flag = 'X'.
*      PERFORM send_mail.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT

*---------------------------------------------------------------------*
*       MODULE TC_MSG_user_command INPUT                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_MSG'
                              'IST_MSG'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

*--- INCLUDE: MZMMMEEO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMMEEO01                                                 *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_INIT OUTPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_init OUTPUT.
  IF g_tc_parent_copied IS INITIAL.
    g_tc_parent_copied = 'X'.
    REFRESH CONTROL 'TC_PARENT' FROM SCREEN '7000'.
  ENDIF.

  DESCRIBE TABLE g_tc_parent_itab LINES tc_parent_lines.  "+rk004

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_MOVE OUTPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_move OUTPUT.
  MOVE-CORRESPONDING g_tc_parent_wa TO zmm_mems.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_GET_LINES OUTPUT                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_get_lines OUTPUT.
  g_tc_parent_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE status_7000 OUTPUT.
  SET PF-STATUS 'ZMME01'.
  IF G_NEWR = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-006 .
  ELSEIF G_PEND = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-010 .
  ELSEIF G_COMP = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-011 .
  ENDIF.
ENDMODULE.                 " STATUS_7000  OUTPUT

*---------------------------------------------------------------------*
*       MODULE TAB_CHILD_ACTIVE_TAB_SET OUTPUT                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tab_child_active_tab_set OUTPUT.
  tab_child-activetab = g_tab_child-pressed_tab.
  CASE g_tab_child-pressed_tab.
    WHEN c_tab_child-tab1.
      g_tab_child-subscreen = '7001'.
    WHEN c_tab_child-tab2.
      g_tab_child-subscreen = '7002'.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_INIT OUTPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_init OUTPUT.

  IF NOT g_tc_parent_itab[] IS INITIAL.
    REFRESH g_tc_parent_istb.
    LOOP AT g_tc_parent_itab INTO g_tc_parent_wa  WHERE flag = 'X'.
      APPEND g_tc_parent_wa TO g_tc_parent_istb.

    ENDLOOP.
  ENDIF.
  IF g_tc_parent_copy[] <> g_tc_parent_istb[].
    IF NOT g_tc_parent_istb[] IS INITIAL.
      SELECT * FROM zmm_mecs
               INTO CORRESPONDING FIELDS OF TABLE g_tc_child_itab
               FOR ALL ENTRIES IN g_tc_parent_istb
               WHERE docno  EQ g_tc_parent_istb-docno. "AND -rk006
*                     ernam  EQ g_tc_parent_istb-ernam  AND -rk006
*                     ersda  EQ g_tc_parent_istb-ersda. "-rk006
      SORT g_tc_child_itab.
      g_tc_parent_copy[] = g_tc_parent_istb[].
    ELSE.
      REFRESH : g_tc_child_itab, g_tc_parent_copy, g_tc_parent_istb .
      REFRESH : ist_msg.
      CLEAR : g_check_flag, g_extnd_flag, g_reprt_flag.
    ENDIF.
    REFRESH CONTROL 'TC_CHILD' FROM SCREEN '7001'.
  ENDIF.

  DESCRIBE TABLE g_tc_child_itab LINES tc_child_lines.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MOVE OUTPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_move OUTPUT.
  MOVE-CORRESPONDING g_tc_child_wa TO zmm_mecs.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_GET_LINES OUTPUT                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_get_lines OUTPUT.
  g_tc_child_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  SET_BUTTON_ATTRIBUTE  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE set_button_attribute OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'PB_CHECK'.
      IF NOT g_tc_child_itab[] IS INITIAL.
        screen-invisible = '0'.
      ELSE.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    IF screen-name EQ 'PB_EXTND'.
      IF NOT g_tc_child_itab[] IS INITIAL.
        IF g_check_flag = 'X'.
          screen-invisible = '0'.
        ELSE.
          screen-invisible = '1'.
        ENDIF.
      ELSE.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_BUTTON_ATTRIBUTE  OUTPUT

*---------------------------------------------------------------------*
*       MODULE TC_MSG_change_tc_attr OUTPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_change_tc_attr OUTPUT.
  DESCRIBE TABLE ist_msg LINES tc_msg-lines.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_MSG_get_lines OUTPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_get_lines OUTPUT.
  g_tc_msg_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  delete_ist_message  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_ist_message OUTPUT.

*  DELETE ist_msg WHERE msgv1 CS 'type'.
*  DELETE ist_msg WHERE msgv1 CS 'exists'.
*  DELETE ist_msg WHERE msgv1 CS 'Field'.
*  DELETE ist_msg WHERE msgv1 CS 'text'.
*  DELETE ist_msg WHERE msgv1 CS 'tax'.
*  DELETE ist_msg WHERE msgv1 CS 'price'.


ENDMODULE.                 " delete_ist_message  OUTPUT

*--- INCLUDE: MZMMMEETOP ---*
*&---------------------------------------------------------------------*
*& INCLUDE MZMMMEETOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
TABLES:
 t001, t100, zmm_mems, zmm_mecs, msichtausw, t320, t141t, marc, makt.

TYPES: BEGIN OF t_tc_parent,
        docno LIKE zmm_mems-docno,
        bukrs LIKE zmm_mems-bukrs,    "+rk006
        ersda LIKE zmm_mems-ersda,
        ernam LIKE zmm_mems-ernam,
        laeda LIKE zmm_mems-laeda,
        aenam LIKE zmm_mems-aenam ,
        flag,       "FLAG FOR MARK COLUMN
       END OF t_tc_parent.

TYPES: BEGIN OF t_tc_child,
         docno LIKE zmm_mecs-docno,
         matnr LIKE zmm_mecs-matnr,
         werks LIKE zmm_mecs-werks,
         bwtar LIKE zmm_mecs-bwtar,
         dismm LIKE zmm_mecs-dismm,
         flag,       "FLAG FOR MARK COLUMN
       END OF t_tc_child.

TYPES: BEGIN OF tab_type,
        fcode LIKE rsmpe-func,
      END OF tab_type.

CONSTANTS: BEGIN OF c_tab_child,
             tab1 LIKE sy-ucomm VALUE 'TAB_CHILD_FC1',
             tab2 LIKE sy-ucomm VALUE 'TAB_CHILD_FC2',
           END OF c_tab_child.

CONTROLS: tc_parent TYPE TABLEVIEW USING SCREEN 7000.
CONTROLS: tab_child TYPE TABSTRIP.
CONTROLS: tc_child TYPE TABLEVIEW USING SCREEN 7001.
CONTROLS: tc_msg TYPE TABLEVIEW USING SCREEN 7002.


DATA:      BEGIN OF g_tab_child,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPMZMMMEE',
             pressed_tab LIKE sy-ucomm VALUE c_tab_child-tab1,
           END OF g_tab_child.

DATA:     g_tc_parent_itab   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_istb   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_copy   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_wa     TYPE t_tc_parent.           "WORK AREA
DATA:     g_tc_parent_copied.                            "COPY FLAG
DATA:     g_tc_parent_lines  LIKE sy-loopc,
            tc_parent_lines  LIKE sy-loopc.              "+rk004

DATA:     g_tc_child_itab   TYPE t_tc_child OCCURS 0,
          g_tc_child_wa     TYPE t_tc_child.             "WORK AREA
DATA:     g_tc_child_copied.                             "COPY FLAG
DATA:     g_tc_child_lines  LIKE sy-loopc,
            tc_child_lines  LIKE sy-loopc.
DATA:     tab TYPE STANDARD TABLE OF tab_type WITH
          NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
          wa_tab TYPE tab_type.

DATA:     g_check_flag,
          g_extnd_flag,
          g_reprt_flag.

DATA:     ok_code LIKE sy-ucomm.

TABLES : t001w.

*----------------------------------------------------------------------*

TYPES : BEGIN OF t_mm01,
          docno LIKE zmm_mems-docno,     "+rk003
          matnr LIKE rmmg1-matnr, "Material Code
          werks LIKE rmmg1-werks, "Plant
          bwtar LIKE rmmg1-bwtar, "Valuation Type
          lgnum LIKE rmmg1-lgnum, "Warehouse number
          vkorg LIKE rmmg1-vkorg, "Sales Org
          prodh LIKE mvke-prodh,  "Product hierarchy
          mtart LIKE rmmg1-mtart, "Material type
          prctr LIKE marc-prctr,  "Profit Center
          dispo LIKE marc-dispo,  "MRP controller
          bwtty LIKE mbew-bwtty,  "Valuation category
          bklas LIKE mbew-bklas,  "Valuation Class
          zksel TYPE zksel,
        END OF t_mm01.

TYPES:  BEGIN OF t_msg,
          docno LIKE zmm_mems-docno,     "+rk003
          matnr  LIKE mara-matnr,
          werks  LIKE marc-werks,        "+rk001
          msgtyp LIKE bdcmsgcoll-msgtyp,
          bwtar  LIKE rmmg1-bwtar,
          msgv1  LIKE bdcmsgcoll-msgv1,
        END OF t_msg.

TYPES: BEGIN OF t_check,
          matnr LIKE mara-matnr,
          laeda LIKE mara-laeda,
          aenam LIKE mara-aenam,
          vpsta LIKE mara-vpsta,
          pstat LIKE mara-pstat,
       END OF t_check.


DATA: ist_msg TYPE t_msg OCCURS 0.
DATA: wa_msg  TYPE t_msg.

DATA: BEGIN OF g_mm01_del OCCURS 0,
      docno LIKE zmm_mecs-docno,          "+rk003
      matnr LIKE rmmg1-matnr,             "Material Code
      bwtar LIKE rmmg1-bwtar,
      END OF g_mm01_del.

DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: nodata VALUE '/'.
DATA:     g_tc_msg_lines  LIKE sy-loopc.

DATA: wa_check TYPE t_check.
DATA: ist_zksel TYPE zksel.
DATA: g_exist,  g_all, g_only_second, g_mail.

DATA: BEGIN OF it_views OCCURS 0,
      text  TYPE c,
      END OF it_views.

DATA: G_NEWR, G_PEND, G_COMP.        "+rk003

data :g_qmatnr like qmat-matnr,
      g_qwerks like qmat-werks,
      g_qart like  qmat-art.

data : wa_qmat like qmat.


DATA: g_mm01_ist        TYPE   t_mm01 OCCURS 0.
DATA: g_mm01_wa         TYPE   t_mm01.
data : g_tmp_wa type t_mm01.

   DATA: plants LIKE marc_werk OCCURS 0 WITH HEADER LINE.
   DATA: l_mstring(480).
   DATA: l_subrc LIKE sy-subrc.
   DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
   DATA: cupdate LIKE ctu_params-updmode VALUE 'S'.
   DATA: smalllog TYPE c." VALUE 'X'.
