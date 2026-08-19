*--- MAIN PROGRAM: MZMMUOMF01 ---*
***INCLUDE MZMMMERF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID     Description
* 13/09/2008  <RD1K960036>  SAB_PUNIT  1) Replaced obsolete FM 'UPLOAD'
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 form user_ok_tc using    p_tc_name type dynfnam
                          p_table_name
                          p_mark_name
                 changing p_ok      like sy-ucomm.

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data: l_ok              type sy-ucomm,
         l_offset          type i.
*-END OF LOCAL DATA----------------------------------------------------*

* Table control specific operations                                    *
*   evaluate TC name and operations                                    *
   search p_ok for p_tc_name.
   if sy-subrc <> 0.
     exit.
   endif.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.

* execute general and TC specific operations                           *
   case l_ok.
     when 'INSR'.                      "insert row
       perform fcode_insert_row using    p_tc_name
                                         p_table_name.
       clear p_ok.

     when 'DELE'.                      "delete row
       perform fcode_move_row using    p_tc_name
                                         p_table_name
                                         p_mark_name.

       perform fcode_delete_row using    p_tc_name
                                         p_table_name
                                         p_mark_name.
       clear p_ok.

     when 'P--' or                     "top of list
          'P-'  or                     "previous page
          'P+'  or                     "next page
          'P++'.                       "bottom of list
       perform compute_scrolling_in_tc using p_tc_name
                                             l_ok.
       clear p_ok.

     when 'MARK'.                      "mark all filled lines
       perform fcode_tc_mark_lines using p_tc_name
                                         p_table_name
                                         p_mark_name   .
       clear p_ok.

     when 'DMRK'.                      "demark all filled lines
       perform fcode_tc_demark_lines using p_tc_name
                                           p_table_name
                                           p_mark_name .
       clear p_ok.

     when 'SASCEND'.
       perform fcode_sort_as using p_tc_name
                                   p_table_name
                                   l_ok.
       clear p_ok.

     when 'SDESCEND'.
       perform fcode_sort_ds using p_tc_name
                                   p_table_name
                                   l_ok.
       clear p_ok.

     when 'FILTER'.
       perform fcode_filter_tc using p_tc_name
                                     p_table_name
                                     l_ok.
       clear p_ok.
     when 'IMPORT'.
       perform fcode_import_tc using p_tc_name
                                     p_table_name
                                     l_ok.
       clear p_ok.

*     WHEN 'CHECK'.
*       PERFORM fcode_check_tc USING p_tc_name
*                                    p_table_name
*                                    l_ok.
*       CLEAR p_ok.

     when 'COPY'.                      "copy row
       perform fcode_copy_row using      p_tc_name
                                         p_table_name
                                         p_mark_name.
       clear p_ok.


   endcase.

 endform.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 form fcode_insert_row
               using    p_tc_name           type dynfnam
                        p_table_name             .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_lines_name       like feld-name.
   data l_selline          like sy-stepl.
   data l_lastline         type i.
   data l_line             type i.
*   DATA l_actual           TYPE i.
   data l_table_name       like feld-name.
   field-symbols <tc>                 type cxtab_control.
   field-symbols <table>              type standard table.
   field-symbols <lines>              type i.
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* get looplines of TableControl
   concatenate 'G_' p_tc_name '_LINES' into l_lines_name.
   assign (l_lines_name) to <lines>.

* get current line
*   DESCRIBE TABLE <table> LINES l_actual.
   get cursor line l_selline.
   if sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line
     if l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     else.
       <tc>-top_line = 1.
     endif.
   else.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   endif.

*&SPWIZARD: set new cursor line
   l_line = l_selline - <tc>-top_line + 1.
* insert initial line

*   l_selline = l_actual + 1.
   insert initial line into <table> index l_selline.
*   <tc>-lines = <tc>-lines + 1.
   <tc>-lines = 999.

* set cursor
   set cursor line l_line.
*   SET CURSOR LINE l_selline.
 endform.                              " FCODE_INSERT_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 form fcode_move_row
               using    p_tc_name           type dynfnam
                        p_table_name
                        p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.

   data: l_wa type t_tc_81.
   clear : ist_del.                                         "+rk001
   refresh ist_del.                                         "+rk001
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* delete marked lines                                                  *
   describe table <table> lines <tc>-lines.

   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     if <mark_field> = 'X'.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
       read table <table> index syst-tabix into l_wa.    "#EC CI_FLDEXT_OK[2215424]
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
       move-corresponding l_wa to ist_del.
       move wa_zmm_uom_d-docno  to ist_del-docno.
       append ist_del.

     endif.
     clear ist_del.                                         "+rk002
   endloop.

 endform.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 form fcode_delete_row
               using    p_tc_name           type dynfnam
                        p_table_name
                        p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.

   data: l_wa type t_tc_81.

*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* delete marked lines                                                  *
   describe table <table> lines <tc>-lines.

   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     if <mark_field> = 'X'.

       delete <table> index syst-tabix.

       if sy-subrc = 0.
*         <tc>-lines = <tc>-lines - 1.
         <tc>-lines = 999.
       endif.
     endif.
   endloop.

 endform.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 form compute_scrolling_in_tc using    p_tc_name
                                       p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_tc_new_top_line     type i.
   data l_tc_name             like feld-name.
   data l_tc_lines_name       like feld-name.
   data l_tc_field_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <lines>      type i.
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get looplines of TableControl

   concatenate 'G_' p_tc_name '_LINES' into l_tc_lines_name.

   assign (l_tc_lines_name) to <lines>.


* is no line filled?
*
   if <tc>-lines = 0.
*   yes, ...
*
     l_tc_new_top_line = 1.
   else.
*   no, ...
*
     call function 'SCROLLING_IN_TABLE'
          exporting
               entry_act             = <tc>-top_line
               entry_from            = 1
               entry_to              = <tc>-lines
               last_page_full        = 'X'
               loops                 = <lines>
               ok_code               = p_ok
               overlapping           = 'X'
          importing
               entry_new             = l_tc_new_top_line
          exceptions
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
               others                = 0.
   endif.

* get actual tc and column                                             *
   get cursor field l_tc_field_name
              area  l_tc_name.

   if syst-subrc = 0.
     if l_tc_name = p_tc_name.
*     set actual column                                                *
       set cursor field l_tc_field_name line 1.
     endif.
   endif.

* set the new top line                                                 *
   <tc>-top_line = l_tc_new_top_line.


 endform.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 form fcode_tc_mark_lines using p_tc_name
                                p_table_name
                                p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* mark all filled lines                                                *
   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     <mark_field> = 'X'.
   endloop.
 endform.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 form fcode_tc_demark_lines using p_tc_name
                                  p_table_name
                                  p_mark_name .
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* demark all filled lines                                              *
   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     <mark_field> = space.
   endloop.
 endform.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_document_number .

   if g_ok_80 eq 'CREATE'.
     select max( docno ) into wa_zmm_uom_h-docno from zmm_uom_h .
     add 1 to wa_zmm_uom_h-docno.
*     CALL FUNCTION 'NUMBER_GET_NEXT'
*          EXPORTING
*               nr_range_nr             = '01'
*               object                  = 'ZMM_MUOM'
*               quantity                = '1'
*               toyear                  = '2005'
*          IMPORTING
*               number                  = number
*               returncode              = rc
*          EXCEPTIONS
*               interval_not_found      = 1
*               number_range_not_intern = 2
*               object_not_found        = 3
*               quantity_is_0           = 4
*               quantity_is_not_1       = 5
*               interval_overflow       = 6
*               buffer_overflow         = 7
*               OTHERS                  = 8.
*     IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     ENDIF.
   endif.
 endform.                    " GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form assign_sy_values.
*   CLEAR zmm_uom_h.
   move sy-datum to wa_zmm_uom_h-ersda .
   move sy-datum to wa_zmm_uom_h-reqdt.

   move sy-uname to wa_zmm_uom_h-ernam .

   select  single a~bukrs  into wa_zmm_uom_h-bukrs
       from ( ( pa0001 as a inner join pa9930 as c
             on a~pernr = c~pernr ) inner join zdesignation_rev as d
                on c~designo = d~desig_code and
                    c~r_p_cd  = d~r_p_cd and
                    c~version = d~version )
                 where a~pernr = sy-uname.


 endform.                    " ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*&      Form  FCODE_SORT_as
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_sort_as using    p_tc_name
                             p_table_name
                             p_ok.

   data l_table_name  like feld-name.
   data cols          like line of tc_81-cols.

   field-symbols <table>      type standard table.

   concatenate p_table_name '[]' into l_table_name. "table body

   assign (l_table_name) to <table>.                "not headerline

   read table tc_81-cols into cols with key selected = 'X'.
   if sy-subrc = 0.
     sort <table> by (cols-screen-name+9) ascending .
     cols-selected = ' '.
     modify tc_81-cols from cols index sy-tabix.
   endif.


 endform.                    " FCODE_SORT_TC
*&---------------------------------------------------------------------
*
*&      Form  FCODE_SORT_ds
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_sort_ds using    p_tc_name
                             p_table_name
                             p_ok.

   data l_table_name  like feld-name.
   data cols          like line of tc_81-cols.

   field-symbols <table>      type standard table.

   concatenate p_table_name '[]' into l_table_name. "table body

   assign (l_table_name) to <table>.                "not headerline

   read table tc_81-cols into cols with key selected = 'X'.
   if sy-subrc = 0.
     sort <table> by (cols-screen-name+9) descending .
     cols-selected = ' '.
     modify tc_81-cols from cols index sy-tabix.
   endif.


 endform.                    " FCODE_SORT_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_filter_tc using    p_tc_name
                               p_table_name
                               p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_filt_no_change.
   data l_table_name          like feld-name.
   field-symbols <table>      type standard table.
*-END OF LOCAL DATA----------------------------------------------------*
* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

 endform.                    " FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*&      Form  FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
 form fcode_import_tc using    p_tc_name
                               p_table_name
                               p_ok.

   data: l_filename like rlgrap-filename.
   data: l_tc_81_itab type t_tc_81 occurs 0.
* begin of <RD1K960036>
* Replaced obsolete FM 'UPLOAD'
  DATA : L_T_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
         L_FILETABLE  TYPE  FILE_TABLE,
         l_RC         TYPE  I,
         l_P_DEF_FILE TYPE  STRING,
         l_P_FILE     TYPE  STRING,
         l_usr_act    TYPE  I.

*   call function 'UPLOAD'
*        exporting
*             filename                = l_filename
*             filetype                = 'DAT'
*             item                    = ' '
*             filemask_mask           = ' '
*             filemask_text           = ' '
*             filetype_no_change      = ' '
*             filemask_all            = ' '
*             filetype_no_show        = ' '
*             line_exit               = ' '
*             user_form               = ' '
*             user_prog               = ' '
*             silent                  = 'S'
*        tables
*             data_tab                = l_tc_81_itab
*        exceptions
*             conversion_error        = 1
*             invalid_table_width     = 2
*             invalid_type            = 3
*             no_batch                = 4
*             unknown_error           = 5
*             gui_refuse_filetransfer = 6
*             others                  = 7.

     l_P_DEF_FILE = l_filename.

     CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
       EXPORTING
*         WINDOW_TITLE            =
*         DEFAULT_EXTENSION       =
          DEFAULT_FILENAME        = l_P_DEF_FILE
*         FILE_FILTER             =
*         WITH_ENCODING           =
*         INITIAL_DIRECTORY       =
*         MULTISELECTION          =
       CHANGING
          FILE_TABLE              = l_t_FILE_TABLE
          RC                      = l_RC
          USER_ACTION             = l_usr_act
*         FILE_ENCODING           =
       EXCEPTIONS
         FILE_OPEN_DIALOG_FAILED = 1
         CNTL_ERROR              = 2
         ERROR_NO_GUI            = 3
         NOT_SUPPORTED_BY_GUI    = 4
         others                  = 5      .

   IF sy-subrc = 0
      AND l_usr_act <>
      CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.


     LOOP AT L_t_FILE_TABLE  INTO l_FILETABLE.
        l_P_FILE = l_FILETABLE.
        EXIT.
      ENDLOOP.


    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                      = l_P_FILE
        FILETYPE                      = 'ASC'
        HAS_FIELD_SEPARATOR           = 'X'
      TABLES
        DATA_TAB                      = l_tc_81_itab    "#EC CI_FLDEXT_OK[2215424]
     EXCEPTIONS
       FILE_OPEN_ERROR               = 1
       FILE_READ_ERROR               = 2
       NO_BATCH                      = 3
       GUI_REFUSE_FILETRANSFER       = 4
       INVALID_TYPE                  = 5
       NO_AUTHORITY                  = 6
       UNKNOWN_ERROR                 = 7
       BAD_DATA_FORMAT               = 8
       HEADER_NOT_ALLOWED            = 9
       SEPARATOR_NOT_ALLOWED         = 10
       HEADER_TOO_LONG               = 11
       UNKNOWN_DP_ERROR              = 12
       ACCESS_DENIED                 = 13
       DP_OUT_OF_MEMORY              = 14
       DISK_FULL                     = 15
       DP_TIMEOUT                    = 16
       OTHERS                        = 17
            .
    IF SY-SUBRC <> 0.
     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

* end of <RD1K960036>
   if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   endif.

   if sy-subrc eq 0.
     if g_tc_81_itab[] is initial.
       g_tc_81_itab[] = l_tc_81_itab[].
     else.
       append lines of l_tc_81_itab to g_tc_81_itab.
       refresh l_tc_81_itab.
     endif.
   endif.

   refresh control 'TC_81' from screen '9081'.
   tc_81-lines = 999.


 endform.                    " FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*&      Form  SAVE_9081
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form save_9081.
   data: l_ans.
   if g_tc_81_itab is initial.
     clear sy-ucomm.
     message e354.
   endif.

   if g_ok_80 = 'DELETE'.

     call function 'POPUP_CONTINUE_YES_NO'
          exporting
               defaultoption = 'Y'
               textline1     = 'Delete the Document'
               textline2     = 'You will lose the Document data'
               titel         = 'Confirmation'
               start_column  = 25
               start_row     = 6
          importing
               answer        = l_ans.

     if l_ans eq 'J'.

       delete from zmm_uom_h where docno = g_docno.
       delete zmm_uom_d from table l_itab.
       leave to screen 9080.
     endif.

   else.

     perform get_document_number.

     perform delete_data_base on commit .
     perform commit_rollback.
     perform update_workareas.
     perform modify_data_base on commit .
     perform commit_rollback.
     perform user_message.
   endif.
 endform.                                                   " SAVE_9081
*&---------------------------------------------------------------------*
*&      Form  modify_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form modify_data_base.

   modify zmm_uom_h from wa_zmm_uom_h.
   modify zmm_uom_d from table ist_zmm_uom_d.
   loop at ist_zmm_uom_d into wa_zmm_uom_d.
    If wa_zmm_uom_d-UOM_STR1 = 'NON CONVERTIBLE UOM'.
    else.
     update mara set  vabme = '1'
        where matnr = wa_zmm_uom_d-matnr.
    endif.
   endloop.

 endform.                    " modify_data_base
*&---------------------------------------------------------------------*
*&      Form  commit_rollback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form commit_rollback.

   case sy-subrc.
     when 0 .
       commit work.
     when others .
       rollback work .
       message e671(zps).
   endcase .

 endform.                    " commit_rollback
*&---------------------------------------------------------------------*
*&      Form  user_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form user_message.

   case g_ok_80.
     when 'CREATE'.
       message i359 with wa_zmm_uom_h-docno.
       leave to screen 9080.
     when 'CHANGE'.
       message i352 with wa_zmm_uom_h-docno.
       leave to screen 9080.
   endcase.

 endform.                    " user_message
*&---------------------------------------------------------------------*
*&      Form  update_workareas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form update_workareas.
   clear ist_zmm_uom_d.
   if g_ok_80 eq 'CREATE'.
     wa_zmm_uom_d-docno = wa_zmm_uom_h-docno.
*     zmm_uom_d-sflag = 'N'.
   endif.

   loop at g_tc_81_itab into g_tc_81_wa.

     move-corresponding g_tc_81_wa to wa_zmm_uom_d.

     if g_ok_80 eq 'CREATE'.
       move sy-uname to wa_zmm_uom_h-userid.
       move sy-datum to wa_zmm_uom_d-ersda.
       move sy-uname to wa_zmm_uom_d-ernam.
*       MOVE 'N'      TO wa_zmm_mecs-sflag.
     elseif g_ok_80 eq 'CHANGE'.
       move g_docno to wa_zmm_uom_d-docno.
       move sy-datum to wa_zmm_uom_d-ersda.
       move sy-uname to wa_zmm_uom_d-ernam.
       move sy-datum to wa_zmm_uom_d-laeda.
       move sy-uname to wa_zmm_uom_d-aenam.
*       MOVE 'N'      TO wa_zmm_mecs-sflag.
     endif.

     append wa_zmm_uom_d to ist_zmm_uom_d.

   endloop.

   sort ist_zmm_uom_d by docno matnr  .

*   DELETE ADJACENT DUPLICATES FROM ist_zmm_uom_d.


 endform.                    " update_workareas
*&---------------------------------------------------------------------*
*&      Form  FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
* FORM fcode_check_tc USING    p_tc_name
*                              p_table_name
*                              p_ok.
*
*   DATA l_table_name       LIKE feld-name.
*
*   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
*   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
*   FIELD-SYMBOLS <wa>         TYPE t_tc_81.
*
*   DATA: l_mecs      TYPE zmm_mecs.
*   DATA: l_remrk(60) TYPE c.
*   DATA: l_matnr     LIKE mara-matnr.
*   DATA: l_value(2)  TYPE  c.
*   DATA: l_trip(3)   TYPE  c.
*   DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
*   DATA: l_tabix     LIKE sy-tabix.
*   DATA: l_msgt      TYPE LINE OF zmm_msgt.
*   DATA: l_mstae     TYPE mara-mstae.
*   DATA: l_agr_users TYPE agr_users.
*   DATA: general_data LIKE bapimatdoa.
*   DATA: return LIKE bapireturn.
*   DATA: plantdata LIKE bapimatdoc.
*   DATA: valuationdata LIKE bapimatdobew.
*   DATA: l_bwtar TYPE bwtar_d.
*   DATA: l_views(1) type n.                                 "+rk003
*
*   CLEAR l_views.
*   DATA: ans.
**-END OF LOCAL
*DATA----------------------------------------------------*
*   ASSIGN (p_tc_name) TO <tc>.
** get the table, which belongs to the tc
**
*   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
*   ASSIGN (l_table_name) TO <table>.                "not headerline
*
*   LOOP AT <table> ASSIGNING <wa>.
*
*     IF <wa>-matnr EQ space.
*       EXIT.
*     ENDIF.
*
*     l_tabix = sy-tabix.
*
*     IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
*
*       IF NOT <wa>-werks IS INITIAL.
*         CALL FUNCTION 'GET_PLANT_DETAILS'
*              EXPORTING
*                   i_werks         = <wa>-werks
*              IMPORTING
*                   e_t001w         = t001w
*              EXCEPTIONS
*                   not_found       = 1
*                   parameter_error = 2
*                   OTHERS          = 3.
*
*         IF sy-subrc EQ 0.
*
*           IF NOT <wa>-bwtar IS INITIAL.
*
*             l_bwtar = <wa>-bwtar.
*
*             IF l_bwtar EQ 'BATCH_MNGD'.
*               CLEAR l_bwtar.
*             ENDIF.
*
*             IF NOT <wa>-matnr IS INITIAL.
*               CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
*                    EXPORTING
*                         material              = <wa>-matnr
*                         plant                 = <wa>-werks
*                         valuationarea         = t001w-bwkey
*                         valuationtype         = l_bwtar
*                    IMPORTING
*                         material_general_data = general_data
*                         return                = return
*                         materialplantdata     = plantdata
*                         materialvaluationdata = valuationdata.
*
*               IF return-type EQ 'S'.
*
*                 DATA : plants TYPE TABLE OF marc_werk WITH HEADER LINE
*.
*                 DATA : l_strlen TYPE i.
*
*                 REFRESH plants.
*                 CLEAR l_strlen.
*
*                 CALL FUNCTION 'MATERIAL_READ_PLANTS'
*                      EXPORTING
*                           matnr  = <wa>-matnr
*                      TABLES
*                           plants = plants.
*
*                 READ TABLE plants  WITH KEY werks = <wa>-werks.
*                 l_strlen = strlen( plants-pstat ).
**--------start of changes by rk003------------------------------------*
*
*                 SELECT SINGLE * FROM t320 WHERE
*                                 werks EQ <wa>-werks.
*                 if sy-subrc is initial.
*                   l_views = 7.
*                 else.
*                   l_views = 6.
*                 endif.
*
**--------end of changes by rk003------------------------------------*
*
**                 IF l_strlen GE 6.        "-rk002
*                 IF l_strlen = l_views.                     "+RK003
*                   <wa>-remrk = text-010.  "Already extended
*                   EXIT.
*                 ENDIF.
*               ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
*                 <wa>-remrk = return-message_v1.
*                 EXIT.
*               ENDIF.
*             ENDIF.
*           ENDIF.
*           CLEAR l_bwtar.
*         ENDIF.
*       ENDIF.
*
*
*
*       CLEAR l_matnr.
*       SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
*                           FROM mara
*                           WHERE matnr = <wa>-matnr.
*       IF sy-subrc NE 0.
*         CONCATENATE 'Material'
*                      <wa>-matnr
*                     'does not exist - check your entry'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
*       ELSEIF sy-subrc EQ 0.
*         IF NOT ( l_mstae IS INITIAL ).
*           SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
*                                        AND spras = 'E'.
*           <wa>-remrk = t141t-mtstb.
*         ENDIF.
*       ENDIF.
*       CLEAR t001w.
*       SELECT SINGLE * FROM t001w WHERE werks = <wa>-werks.
*       IF sy-subrc NE 0.
*         CONCATENATE 'Plant'
*                     <wa>-werks
*                     'does not exist - check your entry'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
**       ELSE.
**         SELECT SINGLE * FROM t001k WHERE bwkey = <wa>-werks
**                                      AND bukrs = zmm_mems-bukrs.
**         IF sy-subrc NE 0.
**           CONCATENATE 'Plant'
**                       <wa>-werks
**                     'does not belong to Company code' zmm_mems-bukrs
**                       INTO l_remrk SEPARATED BY space.
**           MOVE l_remrk TO <wa>-remrk.
**           CLEAR l_remrk.
**         ENDIF.
*       ENDIF.
*
**       CLEAR l_agr_users.
**       SELECT SINGLE * FROM agr_users
**                    INTO l_agr_users
**                    WHERE agr_name = 'D:MM_MAT_IND_APPROVE_02'
**                      AND uname    = <wa>-bname.
**
**       IF sy-subrc NE 0.
**         CONCATENATE 'User'
**                     <wa>-bname
**                   'does not have MRP role'
**                     INTO l_remrk SEPARATED BY space.
**         MOVE l_remrk TO <wa>-remrk.
**         CLEAR l_remrk.
**       ENDIF.
*
*       CLEAR l_value.
*       l_value = <wa>-matnr+0(2).
*       IF l_value NE '0C'.
*         CLEAR t149d.
*         SELECT SINGLE * FROM t149d WHERE bwtar = <wa>-bwtar.
*         IF sy-subrc NE 0.
*           CONCATENATE 'Valuation type'
*                        <wa>-bwtar
*                       'does not exist - check your entry'
*                       INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO <wa>-remrk.
*           CLEAR l_remrk.
*         ENDIF.
*
*         CLEAR l_trip.
*         l_trip = <wa>-bwtar+0(3).
*         IF l_value GE '01' AND l_value LE '16'.
*           IF l_trip NE 'STI'.
*             <wa>-remrk = text-012.
*           ENDIF.
*         ELSEIF l_value GE '21' AND l_value LE '42'.
*           IF l_trip NE 'SPI'.
*             <wa>-remrk = text-013.
*           ENDIF.
*         ENDIF.
*       ELSE.
*         IF l_value EQ '0C'.
*           IF <wa>-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
*             <wa>-remrk = text-011.
*           ENDIF.
*         ENDIF.
*       ENDIF.
*     ENDIF.
*     MODIFY <table> FROM <wa> INDEX l_tabix.
*   ENDLOOP.
*
*   DATA : answer.
*   REFRESH temp.
*   CLEAR temp.
*
*   LOOP AT <table> ASSIGNING <wa>.
*     temp-remrk = <wa>-remrk.
*     APPEND temp.
*     CLEAR temp.
*   ENDLOOP.
*
*   DELETE temp WHERE remrk EQ space.
*
*   IF temp[] IS INITIAL.
*
*
*     CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
*          EXPORTING
*               defaultoption = 'Y'
*               textline1     = 'Do you want to save the request?'
*               titel         = 'Information'
*               start_column  = 25
*               start_row     = 6
*          IMPORTING
*               answer        = ans.
*     CASE ans.
*       WHEN 'J'.
*         PERFORM save_9081.
*       WHEN 'N'.
** do nothing
*     ENDCASE.
*
*   ELSE.
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Information'
*               textline1 = text-016.
**     IF sy-subrc EQ 0.
**       CLEAR fcode.
**     ENDIF.
*
*   ENDIF.
*
* ENDFORM.                    " FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*&      Form  validate_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form validate_records.

*   DATA: l_mecs      TYPE zmm_uom_d.
*   DATA: l_remrk(60) TYPE c.
*   DATA: l_matnr     LIKE mara-matnr.
*   DATA: l_value(2)  TYPE  c.
*   DATA: l_trip(3)   TYPE  c.
*   DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
*   DATA: l_mstae     TYPE mara-mstae.
*   DATA: l_agr_users TYPE agr_users.
*   DATA: zseqwrk TYPE TABLE OF zseqwrk WITH HEADER LINE.
*   DATA: l_bwtar TYPE bwtar_d.
*   DATA: t001w   LIKE  t001w.
*   DATA: plants TYPE marc_werk OCCURS 0 WITH HEADER LINE.
*   DATA: general_data LIKE bapimatdoa.
*   DATA: return LIKE bapireturn.
*   DATA: plantdata LIKE bapimatdoc.
*   DATA: valuationdata LIKE bapimatdobew.
*   DATA: l_views(1) type n.                                 "+rk003
*
*   clear l_views.
*   IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
*
*     IF g_ok_80 EQ 'CREATE'.
*       SELECT SINGLE * FROM zmm_uom_d INTO l_mecs
*                       WHERE matnr = wa_zmm_uom_d-matnr
*                         AND werks = wa_zmm_uom_d-werks.
**                         AND bwtar = zmm_mecs-bwtar.
*       IF sy-subrc EQ 0.
*         IF l_mecs-sflag EQ 'C'.
*           wa_zmm_uom_d-remrk = text-010.  "Already extended
*           EXIT.
**         ELSEIF l_mecs-sflag EQ 'N'.   "-RK002
*         ELSEIF l_mecs-sflag EQ 'N' OR l_mecs-sflag EQ 'P'.
*           CONCATENATE 'Material is already included in request no '
*                        l_mecs-docno  INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO wa_zmm_uom_d-remrk.
*           CLEAR l_remrk.
*           EXIT.
**         ENDIF.
**       ENDIF.
**     ENDIF.

 endform.                    " validate_records
*&---------------------------------------------------------------------*
*&      Form  GET_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_itab_data.

*   DATA: l_itab TYPE TABLE OF zmm_uom_d WITH HEADER LINE..

*   CLEAR ZMM_MEMS.
*   SELECT SINGLE * FROM zmm_uom_h into wa_zmm_uom_h
*       WHERE docno = g_docno.
*
*   IF g_ok_80 EQ 'CHANGE'.
*
*     IF wa_zmm_uom_h-sflag EQ 'C'.
*
*       CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*            EXPORTING
*                 titel     = 'Error'
*                 textline1 = 'Request cannot be changed at this stage'
*                 textline2 = 'The request has been completed'.
*
*       SET SCREEN 9080.
*
*     ELSEIF wa_zmm_uom_h-sflag EQ 'P'.
*
*       CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*            EXPORTING
*                 titel     = 'Error'
*                 textline1 = 'Request cannot be changed at this stage.'
*                 textline2 = 'The request is under process.'.
*
*       SET SCREEN 9080.
*
*
*     ELSE.
*
*       CLEAR : l_itab.
*       SELECT * FROM zmm_uom_d INTO CORRESPONDING FIELDS OF TABLE
*                l_itab  WHERE docno = g_docno.
*
*       LOOP AT l_itab.
*         MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
*         APPEND g_tc_81_wa TO g_tc_81_itab.
*       ENDLOOP.
*
*       SET SCREEN 9081.
*
*     ENDIF.
*
*   ELSE.

   clear : l_itab.
   select * from zmm_uom_d into corresponding fields of table
            l_itab  where docno = g_docno.

   loop at l_itab.
     move-corresponding l_itab to g_tc_81_wa.
     append g_tc_81_wa to g_tc_81_itab.
   endloop.

*     SET SCREEN 9081.

*   ENDIF.


 endform.                    " GET_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form check_user.

   data: l_uom_h type zmm_uom_h.

   if not ( wa_zmm_uom_h-docno is initial ).

     select single * from zmm_uom_h into l_uom_h
                where docno = wa_zmm_uom_h-docno.

     if sy-uname <> l_uom_h-ernam.
       if g_ok_80 eq 'CHANGE'.
         message s353.
         leave to screen 9080.
       elseif g_ok_80 eq 'DELETE'.
         message s358.
         leave to screen 9080.
       endif.
     endif.
   endif.
 endform.                    " CHECK_USER
*&---------------------------------------------------------------------*
*&      Form  get_commitment_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_commitment_number.

*   DATA: l_valclass  TYPE zmm_valclass.
*   DATA: l_konts     TYPE t030-konts.
*   DATA: l_fipos     TYPE skb1-fipos.
*
*
*   CLEAR l_valclass.
*   CLEAR zmm_mecs-fipos.
*
*   SELECT SINGLE * FROM zmm_valclass
*                   INTO l_valclass
*       WHERE matnr_from LE zmm_mecs-matnr AND
*             matnr_to   GE zmm_mecs-matnr AND
*             val_type   EQ space.
*
*   IF sy-subrc EQ 0.
*     CLEAR l_konts.
*     SELECT SINGLE konts INTO l_konts
*     FROM t030 WHERE ktosl = 'BSX'
*                 AND bwmod = 'ONGC'
*                 AND bklas  = l_valclass-val_class.
*     IF sy-subrc EQ 0.
*       CLEAR l_fipos.
*       SELECT SINGLE fipos INTO l_fipos
*       FROM skb1 WHERE saknr = l_konts
*                   AND bukrs = zmm_mems-bukrs.
*       IF sy-subrc EQ 0.
*         MOVE l_fipos TO zmm_mecs-fipos.
*         CLEAR l_fipos.
*       ENDIF.
*     ENDIF.
*   ENDIF.

 endform.                    " get_commitment_number
*&---------------------------------------------------------------------*
*&      Form  GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form get_delete_itab_data.

   data: l_delete type table of zmm_uom_d with header line.
   data: l_ans.

*   SELECT SINGLE * FROM zmm_uom_h into wa_zmm_uom_h
*   WHERE docno = g_docno.
*
*   IF wa_zmm_uom_h-sflag EQ 'C'.
*
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Error'
*               textline1 = 'Request cannot be deleted.'
*               textline2 = 'The request has been completed'.
*
*     SET SCREEN 9080.
*
*   ELSEIF wa_zmm_uom_h-sflag EQ 'P'.
*
*     CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*               titel     = 'Error'
*               textline1 = 'Request cannot be deleted at this stage.'
*               textline2 = 'The request is under process.'.
*
*     SET SCREEN 9080.
*
*   ELSE.

*     CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
*          EXPORTING
*               defaultoption = 'Y'
*               textline1     = 'Delete the Document'
*               textline2     = 'You will lose the Document data'
*               titel         = 'Confirmation'
*               start_column  = 25
*               start_row     = 6
*          IMPORTING
*               answer        = l_ans.
*
*     IF l_ans EQ 'J'.

*       CLEAR : l_delete.
*
*       SELECT * FROM zmm_uom_d INTO CORRESPONDING FIELDS OF TABLE
*             l_delete  WHERE docno = g_docno.
*
*       IF sy-subrc EQ 0.
*
*         READ TABLE l_delete WITH KEY sflag = 'P'.
*
*         IF sy-subrc NE 0.
*
*           DELETE FROM zmm_uom_h WHERE docno = g_docno.
*
*           DELETE zmm_uom_d FROM TABLE l_delete.
*
*           IF sy-subrc EQ 0.
*             MESSAGE s356(zmm).
*           ENDIF.
*         ELSE.
*           MESSAGE s357(zmm).
*         ENDIF.
*
*       ENDIF.


*     SET SCREEN 9080.





 endform.                    " GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  fcode_copy_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
 form fcode_copy_row using    p_tc_name
                              p_table_name
                              p_mark_name.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
   data l_table_name       like feld-name.

   field-symbols <tc>         type cxtab_control.
   field-symbols <table>      type standard table.
   field-symbols <wa>.
   field-symbols <mark_field>.
*-END OF LOCAL DATA----------------------------------------------------*

   assign (p_tc_name) to <tc>.

* get the table, which belongs to the tc                               *
   concatenate p_table_name '[]' into l_table_name. "table body
   assign (l_table_name) to <table>.                "not headerline

* delete marked lines                                                  *
   describe table <table> lines <tc>-lines.

   loop at <table> assigning <wa>.

*   access to the component 'FLAG' of the table header                 *
     assign component p_mark_name of structure <wa> to <mark_field>.

     if <mark_field> = 'X'.
       clear <mark_field>.
       append  <wa> to <table>. "INDEX syst-tabix.
       clear <mark_field>.
       if sy-subrc = 0.
         <tc>-lines = <tc>-lines + 1.
       endif.
     endif.
   endloop.
 endform.                    " fcode_copy_row
*&---------------------------------------------------------------------*
*&      Form  confirm_user_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form confirm_user_action.

   data : ans.

   if g_ok_80 eq 'CREATE' or g_ok_80 eq 'CHANGE'.
     if not ( g_tc_81_itab is initial ).
       call function 'POPUP_TO_CONFIRM'
            exporting
                 titlebar              = 'Confirmation '
                 diagnose_object       = ' '
                 text_question         = 'Do you really want to exit?'
                 text_button_1         = 'Yes'
                 icon_button_1         = ' '
                 text_button_2         = 'No'
                 icon_button_2         = ' '
                 default_button        = '1'
                 display_cancel_button = 'X'
                 userdefined_f1_help   = ' '
                 start_column          = 25
                 start_row             = 6
                 popup_type            = 'ICON_MESSAGE_QUESTION'
            importing
                 answer                = ans
            exceptions
                 text_not_found        = 1
                 others                = 2.
       if sy-subrc <> 0.
         message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       endif.

       case ans.
         when '1'.
           leave to screen 9080.
       endcase.
     else.
       leave to screen 9080.
     endif.
   else.
     leave to screen 9080.
   endif.
 endform.                    " confirm_user_action
*&---------------------------------------------------------------------*
*&      Form  pfstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form pfstatus.

*   CASE g_ok_80.
*
*     WHEN 'DELETE'.
*       CLEAR tab.
*       MOVE 'CHANGE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'DISPLAY' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*     WHEN 'CHANGE'.
*       CLEAR tab.
*       MOVE 'DELETE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'DISPLAY' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*     WHEN 'DISPLAY'.
*       CLEAR tab.
*       MOVE 'DELETE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*       MOVE 'CHANGE' TO wa_tab-fcode.
*       APPEND wa_tab TO tab.
*   ENDCASE.

   set pf-status 'ZMM03'  .

 endform.                    " pfstatus
*&---------------------------------------------------------------------*
*&      Form  delete_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 form delete_data_base.
   delete zmm_uom_d  from table ist_del.
 endform.                    " delete_data_base
*&---------------------------------------------------------------------*
*&      Form  get_matnr_desc
*&---------------------------------------------------------------------*
*       FETCH MATERIAL DESC ROUTINE
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
 form get_matnr_desc using p_matnr.
   clear :wa_makt.

   if not p_matnr is initial.

     call function 'MAKT_SINGLE_READ'
          exporting
               matnr      = p_matnr
               spras      = 'E'
          importing
               wmakt      = wa_makt
          exceptions
               wrong_call = 1
               not_found  = 2
               others     = 3.
     if sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
     endif.
   endif.
 endform.                    " get_matnr_desc
*&---------------------------------------------------------------------*
*&      Form  get_uom_conv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC_81_WA_MEINS  text
*----------------------------------------------------------------------*
 form get_uom_conv using    p_g_tc_81_wa_meins.
   types: begin of  ty_t006,
           msehi type t006-msehi,
           zaehl type t006-zaehl,
           nennr type t006-nennr,
           exp10 type t006-exp10,
           addko type t006-addko,
           mseh3 type t006a-mseh3,
          end   of  ty_t006.

   data: itab_uom  type table of ty_t006.

   data: wa_uom type  ty_t006.
   data: l_factor  type f.
   data: l_dimid type t006-dimid.
   data: l_mssie type t006d-mssie.

*break cab_mansuri.
   data: l_val1 type p decimals 4 value '10000'.
   data: l_val2 type p decimals 4 value '.0001'.
   data: l_zaehl type t006-zaehl.
   data: l_nennr type t006-nennr.
   data: wa_zaehl type t006-zaehl.
   data: wa_nennr type t006-nennr.
   data: wa_exp10 type t006-exp10.
   data: wa_addko type t006-addko.

   data: l_exp10 type t006-exp10.
   data: l_addko type t006-addko.

   data: l_conv_factor  type f ."p DECIMALS 4.
   data: l_len  type i.
   check not  p_g_tc_81_wa_meins is initial.

   refresh itab_uom.
*break cab_mansuri.

   select single dimid into l_dimid from t006 where
       msehi = p_g_tc_81_wa_meins.


   if sy-subrc = 0.

     select single mssie into l_mssie from t006d where
        dimid = l_dimid.
     if sy-subrc = 0.

       select  msehi zaehl nennr exp10 addko into
       corresponding fields of  table itab_uom
       from t006
       where  dimid =  l_dimid.

       read table itab_uom into wa_uom with key
       msehi = p_g_tc_81_wa_meins.
       wa_zaehl = wa_uom-zaehl.
       wa_nennr = wa_uom-nennr.
       wa_exp10 = wa_uom-exp10.
       wa_addko = wa_uom-addko.
*

       clear: wa_zmm_uom_d-uom_str1,wa_zmm_uom_d-uom_str2,l_len.
       delete itab_uom where msehi = p_g_tc_81_wa_meins.


       loop at itab_uom into wa_uom  .

         clear: l_zaehl, l_nennr,l_exp10, l_addko, l_conv_factor.

         select single  zaehl nennr exp10 addko  into
           (l_zaehl, l_nennr, l_exp10, l_addko)
           from t006
           where msehi = wa_uom-msehi and  dimid =  l_dimid.
         break cab_mansuri.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
*           select single mseh3 into wa_uom-mseh3 from t006a
*              where msehi = wa_uom-msehi.
          select mseh3 into wa_uom-mseh3 UP TO 1 ROWS from t006a
              where msehi = wa_uom-msehi ORDER BY PRIMARY KEY.
            ENDSELECT.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
           l_conv_factor =
           ( l_zaehl / l_nennr ) * 10 ** l_exp10  + l_addko.

           l_factor =
           ( ( wa_zaehl / wa_nennr ) * 10 ** wa_exp10 + wa_addko )
            / l_conv_factor  .
*.


         if l_factor > l_val1 .
         else.
           if l_factor < l_val2 and l_factor > 0.
           else.
             l_len = strlen(  wa_zmm_uom_d-uom_str1 )  .
             if l_len < 120.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
               concatenate wa_uom-mseh3  wa_zmm_uom_d-uom_str1  "#EC CI_NOORDER
               into wa_zmm_uom_d-uom_str1 separated by ',' .
             else.
               concatenate wa_uom-mseh3 wa_zmm_uom_d-uom_str2    "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
               into wa_zmm_uom_d-uom_str2 separated by ',' .
             endif.
           endif.
         endif.
       endloop.
     endif.
   endif.
 endform.                    " get_uom_conv
