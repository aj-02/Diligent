*--- MAIN PROGRAM: MZMMMERF01 ---*
***INCLUDE MZMMMERF01 .
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM UPLOAD Replaced with GUI_UPLOAD.
*
*
************************************************************************
" Begin of <RD1K960036>.
CONSTANTS: g_c_asc TYPE char10 VALUE 'ASC'.
" End of <RD1K960036>.

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

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_move_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.

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

    WHEN 'SASCEND'.
      PERFORM fcode_sort_as USING p_tc_name
                                  p_table_name
                                  l_ok.
      CLEAR p_ok.

    WHEN 'SDESCEND'.
      PERFORM fcode_sort_ds USING p_tc_name
                                  p_table_name
                                  l_ok.
      CLEAR p_ok.

    WHEN 'FILTER'.
      PERFORM fcode_filter_tc USING p_tc_name
                                    p_table_name
                                    l_ok.
      CLEAR p_ok.
    WHEN 'IMPORT'.
      PERFORM fcode_import_tc USING p_tc_name
                                    p_table_name
                                    l_ok.
      CLEAR p_ok.

    WHEN 'CHECK'.
      PERFORM fcode_check_tc USING p_tc_name
                                   p_table_name
                                   l_ok.
      CLEAR p_ok.

    WHEN 'COPY'.                      "copy row
      PERFORM fcode_copy_row USING      p_tc_name
                                        p_table_name
                                        p_mark_name.
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
*   DATA l_actual           TYPE i.
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
*   DESCRIBE TABLE <table> LINES l_actual.
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line and new cursor line
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.

*&SPWIZARD: set new cursor line
  l_line = l_selline - <tc>-top_line + 1.
* insert initial line

*   l_selline = l_actual + 1.
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
*   <tc>-lines = <tc>-lines + 1.
  <tc>-lines = 999.

* set cursor
  SET CURSOR LINE l_line.
*   SET CURSOR LINE l_selline.
ENDFORM.                              " FCODE_INSERT_ROW
*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_move_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.

  DATA: l_wa TYPE t_tc_81.
  CLEAR : ist_del.                                          "+rk001
  REFRESH ist_del.                                          "+rk001
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

      READ TABLE <table> INDEX syst-tabix INTO l_wa. "#EC CI_FLDEXT_OK[2215424]
      MOVE-CORRESPONDING l_wa TO ist_del.
      MOVE zmm_mems-docno  TO ist_del-docno.
      APPEND ist_del.

    ENDIF.
    CLEAR ist_del.                                          "+rk002
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

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

  DATA: l_wa TYPE t_tc_81.

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
*         <tc>-lines = <tc>-lines - 1.
        <tc>-lines = 999.
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


* is no line filled?
*
  IF <tc>-lines = 0.
*   yes, ...
*
    l_tc_new_top_line = 1.
  ELSE.
*   no, ...
*
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
*&      Form  GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_document_number .

  IF g_ok_80 EQ 'CREATE'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZMM_ME1'   "'ZMM_ME'
        quantity                = '1'
*       toyear                  = '2005'
      IMPORTING
        number                  = number
        returncode              = rc
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DOCUMENT_NUMBER
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM assign_sy_values.
  CLEAR zmm_mems.
  MOVE sy-datum TO zmm_mems-ersda .
  MOVE sy-uname TO zmm_mems-ernam .
ENDFORM.                    " ASSIGN_SY_VALUES
*&---------------------------------------------------------------------*
*&      Form  FCODE_SORT_as
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_sort_as USING    p_tc_name
                            p_table_name
                            p_ok.

  DATA l_table_name  LIKE feld-name.
  DATA cols          LIKE LINE OF tc_81-cols.

  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body

  ASSIGN (l_table_name) TO <table>.                "not headerline

  READ TABLE tc_81-cols INTO cols WITH KEY selected = 'X'.
  IF sy-subrc = 0.
    SORT <table> BY (cols-screen-name+9) ASCENDING .
    cols-selected = ' '.
    MODIFY tc_81-cols FROM cols INDEX sy-tabix.
  ENDIF.


ENDFORM.                    " FCODE_SORT_TC
*&---------------------------------------------------------------------
*
*&      Form  FCODE_SORT_ds
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_sort_ds USING    p_tc_name
                            p_table_name
                            p_ok.

  DATA l_table_name  LIKE feld-name.
  DATA cols          LIKE LINE OF tc_81-cols.

  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body

  ASSIGN (l_table_name) TO <table>.                "not headerline

  READ TABLE tc_81-cols INTO cols WITH KEY selected = 'X'.
  IF sy-subrc = 0.
    SORT <table> BY (cols-screen-name+9) DESCENDING .
    cols-selected = ' '.
    MODIFY tc_81-cols FROM cols INDEX sy-tabix.
  ENDIF.


ENDFORM.                    " FCODE_SORT_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_filter_tc USING    p_tc_name
                              p_table_name
                              p_ok.
*-BEGIN OF LOCAL DATA--------------------------------------------------*
  DATA l_filt_no_change.
  DATA l_table_name          LIKE feld-name.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
*-END OF LOCAL DATA----------------------------------------------------*
* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

ENDFORM.                    " FCODE_FILTER_TC
*&---------------------------------------------------------------------*
*&      Form  FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_import_tc USING    p_tc_name
                              p_table_name
                              p_ok.

  DATA: l_filename LIKE rlgrap-filename.
  DATA: l_tc_81_itab TYPE t_tc_81 OCCURS 0.
  DATA: wa_tc_81_itab TYPE t_tc_81.

  " Begin of <RD1K960036>.

*   CALL FUNCTION 'UPLOAD'
*        EXPORTING
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
*        TABLES
*             data_tab                = l_tc_81_itab
*        EXCEPTIONS
*             conversion_error        = 1
*             invalid_table_width     = 2
*             invalid_type            = 3
*             no_batch                = 4
*             unknown_error           = 5
*             gui_refuse_filetransfer = 6
*             OTHERS                  = 7.
*   IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*   ENDIF.



  DATA : i_file_table TYPE  TABLE OF file_table,
         l_filetable  TYPE  file_table,
         l_rc         TYPE  i,
         l_p_def_file TYPE  string,
         l_p_file     TYPE  string,
         l_usr_act    TYPE  i.

  l_p_def_file = l_filename.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     WINDOW_TITLE            =
*     DEFAULT_EXTENSION       =
      default_filename        = l_p_def_file
*     FILE_FILTER             =
*     WITH_ENCODING           =
*     INITIAL_DIRECTORY       =
*     MULTISELECTION          =
    CHANGING
      file_table              = i_file_table
      rc                      = l_rc
      user_action             = l_usr_act
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND
     l_usr_act <>
     cl_gui_frontend_services=>action_cancel.

    LOOP AT i_file_table  INTO l_filetable.
      l_p_file = l_filetable.
      EXIT.
    ENDLOOP.

    CALL FUNCTION 'GUI_UPLOAD'   "#EC CI_FLDEXT_OK[2215424]
      EXPORTING
        filename                = l_p_file
        filetype                = g_c_asc
        has_field_separator     = 'X'
      TABLES
        data_tab                = l_tc_81_itab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.
  DATA line TYPE p.
  DATA line1 TYPE p.
  DATA line2 TYPE p.
  DESCRIBE TABLE l_tc_81_itab LINES line.
  DESCRIBE TABLE g_tc_81_itab LINES line1.
  line2 = line + line1.
  IF line2 > 100.
    MESSAGE e867.
    EXIT.
  ELSE.
    " End of <RD1K960036>.

*-----start of add by rk004 --------------------------*
*matcode validation durin text file data upload
    IF NOT l_tc_81_itab[] IS INITIAL.
      LOOP AT l_tc_81_itab[] INTO wa_tc_81_itab.
        PERFORM validate_matnr USING wa_tc_81_itab-matnr
*{   INSERT         OCPK900065                                        1
**********************************************************************
wa_tc_81_itab-steuc
**********************************************************************
*}   INSERT
                               CHANGING wa_tc_81_itab-remrk.
        IF NOT wa_tc_81_itab-remrk IS INITIAL.
          MODIFY l_tc_81_itab[] FROM wa_tc_81_itab.
        ENDIF.
      ENDLOOP.
    ENDIF.
*-----end of add by rk004 --------------------------*

    IF sy-subrc EQ 0.
      IF g_tc_81_itab[] IS INITIAL.
        g_tc_81_itab[] = l_tc_81_itab[].
      ELSE.
        APPEND LINES OF l_tc_81_itab TO g_tc_81_itab.
        REFRESH l_tc_81_itab.
      ENDIF.
    ENDIF.

    REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
    tc_81-lines = 100.
  ENDIF.

ENDFORM.                    " FCODE_IMPORT_TC
*&---------------------------------------------------------------------*
*&      Form  SAVE_9081
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_9081.
*   IF g_button_check NE 'X'.
*     MESSAGE e748.
*     EXIT.
*   ENDIF.

  IF g_tc_81_itab IS INITIAL.
    CLEAR sy-ucomm.
    MESSAGE e354.
  ENDIF.

  PERFORM check_material.
  PERFORM extend_material.
*{   INSERT         OCPK900065                                        1
  LOOP AT g_tc_81_itab INTO G_TC_81_wa.

  ENDLOOP.
*}   INSERT
  IF g_mm01_ist[] IS NOT INITIAL.
    PERFORM get_document_number.

    PERFORM delete_data_base ON COMMIT .
    PERFORM commit_rollback.
    PERFORM update_workareas.
    PERFORM modify_data_base ON COMMIT .
    PERFORM commit_rollback.
    IF sy-subrc EQ 0.
      PERFORM extend.
    ENDIF.
    PERFORM user_message.
  ENDIF.
*  PERFORM DISPLAY_MESG.
ENDFORM.                                                    " SAVE_9081
*&---------------------------------------------------------------------*
*&      Form  modify_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data_base.

  MODIFY zmm_mems FROM zmm_mems.
  MODIFY zmm_mecs FROM TABLE ist_zmm_mecs.

ENDFORM.                    " modify_data_base
*&---------------------------------------------------------------------*
*&      Form  commit_rollback
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM commit_rollback.

  CASE sy-subrc.
    WHEN 0 .
      COMMIT WORK.
    WHEN OTHERS .
      ROLLBACK WORK .
      MESSAGE e671(zps).
  ENDCASE .

ENDFORM.                    " commit_rollback
*&---------------------------------------------------------------------*
*&      Form  user_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_message.
  DATA: var(140) TYPE c.
  CASE g_ok_80.
    WHEN 'CREATE'.

      CONCATENATE 'for the request number' number INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
*      MESSAGE S351 WITH NUMBER.
*{   INSERT         OCPK900065                                        1
    WHEN 'UPDATE'.

      CONCATENATE 'for the request number' number INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
*}   INSERT

    WHEN 'CHANGE'.
      CONCATENATE 'for the request number' zmm_mems-docno INTO  var SEPARATED BY space.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = TEXT-020
          textline2 = var.
      LEAVE TO SCREEN 9080.
  ENDCASE.

ENDFORM.                    " user_message
*&---------------------------------------------------------------------*
*&      Form  update_workareas
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_workareas.
  CLEAR ist_zmm_mecs.                                       "+RK002
  IF g_ok_80 EQ 'CREATE'.
    zmm_mems-docno = number.
    zmm_mems-sflag = 'N'.
  ENDIF.

  LOOP AT g_tc_81_itab INTO g_tc_81_wa.

    MOVE-CORRESPONDING g_tc_81_wa TO wa_zmm_mecs.

    IF g_ok_80 EQ 'CREATE'.
      MOVE number TO wa_zmm_mecs-docno.
      MOVE sy-datum TO wa_zmm_mecs-ersda.
      MOVE sy-uname TO wa_zmm_mecs-ernam.
      MOVE 'N'      TO wa_zmm_mecs-sflag.
    ELSEIF g_ok_80 EQ 'CHANGE'.
      MOVE zmm_mems-docno TO wa_zmm_mecs-docno.
      MOVE sy-datum TO wa_zmm_mecs-ersda.
      MOVE sy-uname TO wa_zmm_mecs-ernam.
      MOVE sy-datum TO wa_zmm_mecs-laeda.
      MOVE sy-uname TO wa_zmm_mecs-aenam.
      MOVE 'N'      TO wa_zmm_mecs-sflag.
    ENDIF.

    APPEND wa_zmm_mecs TO ist_zmm_mecs.

  ENDLOOP.

  SORT ist_zmm_mecs BY docno matnr werks bwtar.

  DELETE ADJACENT DUPLICATES FROM ist_zmm_mecs.


ENDFORM.                    " update_workareas
*&---------------------------------------------------------------------*
*&      Form  FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_L_OK  text
*----------------------------------------------------------------------*
FORM fcode_check_tc USING    p_tc_name
                             p_table_name
                             p_ok.

  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>         TYPE t_tc_81.

  DATA: l_mecs      TYPE zmm_mecs.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

*  DATA: l_remrk(60) TYPE c.
  DATA: l_remrk(61) TYPE c.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
  DATA: l_matnr     LIKE mara-matnr.
  DATA: l_value(2)  TYPE  c.
  DATA: l_trip(3)   TYPE  c.
  DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
  DATA: l_tabix     LIKE sy-tabix.
  DATA: l_msgt      TYPE LINE OF zmm_msgt.
  DATA: l_mstae     TYPE mara-mstae.
  DATA: l_agr_users TYPE agr_users.
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: l_bwtar TYPE bwtar_d.
  DATA: l_views(1) TYPE n.                                  "+rk003

  CLEAR l_views.
  DATA: ans.
*-END OF LOCAL DATA----------------------------------------------------*
  ASSIGN (p_tc_name) TO <tc>.
* get the table, which belongs to the tc                               *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  LOOP AT <table> ASSIGNING <wa>.

    IF <wa>-matnr EQ space.
      EXIT.
    ENDIF.

    l_tabix = sy-tabix.

    IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.

      IF NOT <wa>-werks IS INITIAL.
        CALL FUNCTION 'GET_PLANT_DETAILS'
          EXPORTING
            i_werks         = <wa>-werks
          IMPORTING
            e_t001w         = t001w
          EXCEPTIONS
            not_found       = 1
            parameter_error = 2
            OTHERS          = 3.

        IF sy-subrc EQ 0.

          IF NOT <wa>-bwtar IS INITIAL.

            l_bwtar = <wa>-bwtar.

            IF l_bwtar EQ 'BATCH_MNGD'.
              CLEAR l_bwtar.
            ENDIF.

            IF NOT <wa>-matnr IS INITIAL.
              "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

              DATA: lv_matnr TYPE bapimatdet-material.
              lv_matnr = <wa>-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*              CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
              CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
                EXPORTING
*                 material              = <wa>-matnr
                  material              = lv_matnr
                  plant                 = <wa>-werks
                  valuationarea         = t001w-bwkey
                  valuationtype         = l_bwtar
                IMPORTING
                  material_general_data = general_data
                  return                = return
                  materialplantdata     = plantdata
                  materialvaluationdata = valuationdata.
              "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
              IF return-type EQ 'S'.

                DATA : plants TYPE TABLE OF marc_werk WITH HEADER LINE.
                DATA : l_strlen TYPE i.

                REFRESH plants.
                CLEAR l_strlen.

                CALL FUNCTION 'MATERIAL_READ_PLANTS'
                  EXPORTING
                    matnr  = <wa>-matnr
                  TABLES
                    plants = plants.

                READ TABLE plants  WITH KEY werks = <wa>-werks.
                l_strlen = strlen( plants-pstat ).
*--------start of changes by rk003------------------------------------*

                SELECT SINGLE * FROM t320 WHERE
                                werks EQ <wa>-werks.
                IF sy-subrc IS INITIAL.
                  l_views = 7.
                ELSE.
                  l_views = 6.
                ENDIF.

*--------end of changes by rk003------------------------------------*

*                 IF l_strlen GE 6.        "-rk002
                IF l_strlen = l_views.                      "+RK003
                  <wa>-remrk = TEXT-010.  "Already extended
                  EXIT.
                ENDIF.
              ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
                <wa>-remrk = return-message_v1.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR l_bwtar.
        ENDIF.
      ENDIF.



      CLEAR l_matnr.
      SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
                          FROM mara
                          WHERE matnr = <wa>-matnr.
      IF sy-subrc NE 0.
        CONCATENATE 'Material'
                     <wa>-matnr
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        MOVE l_remrk TO <wa>-remrk.
        CLEAR l_remrk.
      ELSEIF sy-subrc EQ 0.
        IF NOT ( l_mstae IS INITIAL ).
          SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
                                       AND spras = 'E'.
          <wa>-remrk = t141t-mtstb.
        ENDIF.
      ENDIF.
      CLEAR t001w.
      SELECT SINGLE * FROM t001w WHERE werks = <wa>-werks.
      IF sy-subrc NE 0.
        CONCATENATE 'Plant'
                    <wa>-werks
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        MOVE l_remrk TO <wa>-remrk.
        CLEAR l_remrk.
*       ELSE.
*         SELECT SINGLE * FROM t001k WHERE bwkey = <wa>-werks
*                                      AND bukrs = zmm_mems-bukrs.
*         IF sy-subrc NE 0.
*           CONCATENATE 'Plant'
*                       <wa>-werks
*                     'does not belong to Company code' zmm_mems-bukrs
*                       INTO l_remrk SEPARATED BY space.
*           MOVE l_remrk TO <wa>-remrk.
*           CLEAR l_remrk.
*         ENDIF.
      ENDIF.

*       CLEAR l_agr_users.
*       SELECT SINGLE * FROM agr_users
*                    INTO l_agr_users
*                    WHERE agr_name = 'D:MM_MAT_IND_APPROVE_02'
*                      AND uname    = <wa>-bname.
*
*       IF sy-subrc NE 0.
*         CONCATENATE 'User'
*                     <wa>-bname
*                   'does not have MRP role'
*                     INTO l_remrk SEPARATED BY space.
*         MOVE l_remrk TO <wa>-remrk.
*         CLEAR l_remrk.
*       ENDIF.

      CLEAR l_value.
      l_value = <wa>-matnr+0(2).
      IF l_value NE '0C'.
        CLEAR t149d.
        SELECT SINGLE * FROM t149d WHERE bwtar = <wa>-bwtar.
        IF sy-subrc NE 0.
          CONCATENATE 'Valuation type'
                       <wa>-bwtar
                      'does not exist - check your entry'
                      INTO l_remrk SEPARATED BY space.
          MOVE l_remrk TO <wa>-remrk.
          CLEAR l_remrk.
        ENDIF.

        CLEAR l_trip.
*         l_trip = <wa>-bwtar+0(3).                        "-rk006
        l_trip = <wa>-bwtar+0(2).                           "+rk006
        IF l_value GE '01' AND l_value LE '16'.
*           IF l_trip NE 'STI'.                             "-RK006
          IF l_trip NE 'ST'.                                "+RK006
*             <wa>-remrk = text-012.                        "-RK006
            <wa>-remrk = TEXT-019.                          "+RK006
          ENDIF.
        ELSEIF l_value GE '21' AND l_value LE '42'.
*           IF l_trip NE 'SPI'.                             "-RK006
          IF l_trip NE 'SP'.                                "+RK006
*             <wa>-remrk = text-013.                        "-RK006
            <wa>-remrk = TEXT-018.                          "+RK006
          ENDIF.
        ENDIF.
      ELSE.
        IF l_value EQ '0C'.
          IF <wa>-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
            <wa>-remrk = TEXT-011.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY <table> FROM <wa> INDEX l_tabix.
  ENDLOOP.

  DATA : answer.
  REFRESH temp.
  CLEAR temp.

  LOOP AT <table> ASSIGNING <wa>.
    temp-remrk = <wa>-remrk.
    APPEND temp.
    CLEAR temp.
  ENDLOOP.

  DELETE temp WHERE remrk EQ space.

  IF temp[] IS INITIAL.


    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-021
        titel         = 'Information'
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = ans.
    CASE ans.
      WHEN 'J'.
        PERFORM save_9081.
      WHEN 'N'.
* do nothing
    ENDCASE.

  ELSE.
    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Information'
        textline1 = TEXT-016.
*     IF sy-subrc EQ 0.
*       CLEAR fcode.
*     ENDIF.

  ENDIF.

ENDFORM.                    " FCODE_CHECK_TC
*&---------------------------------------------------------------------*
*&      Form  validate_records
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_records.

  DATA: l_mecs      TYPE zmm_mecs.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
*  DATA: l_remrk(60) TYPE c.
  DATA: l_remrk(61) TYPE c.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
  DATA: l_matnr     LIKE mara-matnr.
  DATA: l_value(2)  TYPE  c.
  DATA: l_trip(3)   TYPE  c.
  DATA: l_seqwrk    TYPE TABLE OF zseqwrk.
  DATA: l_mstae     TYPE mara-mstae.
  DATA: l_agr_users TYPE agr_users.
  DATA: zseqwrk TYPE TABLE OF zseqwrk WITH HEADER LINE.
  DATA: l_bwtar TYPE bwtar_d.
  DATA: t001w    LIKE  t001w.
  DATA: plants TYPE marc_werk OCCURS 0 WITH HEADER LINE.
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: l_views(1) TYPE n.                                  "+rk003

  CLEAR l_views.
  IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.

*------------------------------------------------------*
*rk004- only if the material is valid for extn, perform
* other validations

    PERFORM validate_matnr USING zmm_mecs-matnr
*{   INSERT         OCPK900065                                        1
zmm_mecs-steuc
*}   INSERT
                       CHANGING zmm_mecs-remrk.

    IF NOT zmm_mecs-remrk IS INITIAL.
      EXIT.
    ENDIF.
*end of code add by rk004
*------------------------------------------------------*
    IF g_ok_80 EQ 'CREATE'.
      SELECT * FROM zmm_mecs INTO l_mecs UP TO 1 ROWS
 WHERE matnr = zmm_mecs-matnr AND werks = zmm_mecs-werks AND bwtar = zmm_mecs-bwtar
 ORDER BY PRIMARY KEY .
      ENDSELECT.
      IF sy-subrc EQ 0.
        IF l_mecs-sflag EQ 'C'.
          zmm_mecs-remrk = TEXT-010.  "Already extended
          EXIT.
*         ELSEIF l_mecs-sflag EQ 'N'.   "-RK002
        ELSEIF l_mecs-sflag EQ 'N' OR l_mecs-sflag EQ 'P'.  "+RK002
          CONCATENATE 'Material is already included in request no '
                       l_mecs-docno  INTO l_remrk SEPARATED BY space.
          MOVE l_remrk TO zmm_mecs-remrk.
          CLEAR l_remrk.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT zmm_mecs-werks IS INITIAL.

      CALL FUNCTION 'GET_PLANT_DETAILS'
        EXPORTING
          i_werks         = zmm_mecs-werks
        IMPORTING
          e_t001w         = t001w
        EXCEPTIONS
          not_found       = 1
          parameter_error = 2
          OTHERS          = 3.

      IF sy-subrc EQ 0.

        IF NOT zmm_mecs-bwtar IS INITIAL.

          l_bwtar = zmm_mecs-bwtar.

          IF l_bwtar EQ 'BATCH_MNGD'.
            CLEAR l_bwtar.
          ENDIF.

          IF NOT zmm_mecs-matnr IS INITIAL.
            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

            DATA: lv_matnr TYPE bapimatdet-material.
            lv_matnr = zmm_mecs-matnr.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
              EXPORTING
*               material              = zmm_mecs-matnr
                material              = lv_matnr
                plant                 = zmm_mecs-werks
                valuationarea         = t001w-bwkey
                valuationtype         = l_bwtar
              IMPORTING
                material_general_data = general_data
                return                = return
                materialplantdata     = plantdata
                materialvaluationdata = valuationdata.
            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
            IF return-type EQ 'S'.

              CALL FUNCTION 'MATERIAL_READ_PLANTS'
                EXPORTING
                  matnr  = zmm_mecs-matnr
                TABLES
                  plants = plants.

              READ TABLE plants WITH KEY werks =  zmm_mecs-werks.

              IF sy-subrc EQ 0.
                DATA : l_strlen TYPE i.
                l_strlen = strlen( plants-pstat ).
*--------start of changes by rk003------------------------------------*

                SELECT SINGLE * FROM t320 WHERE
                                werks EQ zmm_mecs-werks.
                IF sy-subrc IS INITIAL.
                  l_views = 7.
                ELSE.
                  l_views = 6.
                ENDIF.

*--------end of changes by rk003------------------------------------*

*                 IF l_strlen GE 6.                   "-RK001
                IF l_strlen = l_views.                      "+RK003
                  zmm_mecs-remrk = TEXT-010.  "Alreadyextended
                  EXIT.
                ENDIF.
              ENDIF.
            ELSEIF return-type EQ 'E' AND return-code EQ 'M3305'.
              zmm_mecs-remrk = return-message.
              EXIT.
            ENDIF.

          ENDIF.
          CLEAR l_bwtar.
        ENDIF.

      ENDIF.

    ENDIF.


    CLEAR l_matnr.
    SELECT SINGLE matnr mstae  INTO (l_matnr, l_mstae)
                        FROM mara
                        WHERE matnr = zmm_mecs-matnr.
    IF sy-subrc NE 0.
      CONCATENATE 'Material'
                   zmm_mecs-matnr
                  'does not exist - check your entry'
                  INTO l_remrk SEPARATED BY space.
      MOVE l_remrk TO zmm_mecs-remrk.
      CLEAR l_remrk.
      EXIT.
    ELSEIF sy-subrc EQ 0.
      IF NOT ( l_mstae IS INITIAL ).
        SELECT SINGLE * FROM t141t WHERE mmsta = l_mstae
                                     AND spras = 'E'.
        zmm_mecs-remrk = t141t-mtstb.
        EXIT.
      ENDIF.
    ENDIF.

    CLEAR t001w.
    SELECT SINGLE * FROM t001w INTO t001w WHERE werks = zmm_mecs-werks.

    IF sy-subrc NE 0.
      CONCATENATE 'Plant'
                  zmm_mecs-werks
                  'does not exist - check your entry'
                  INTO l_remrk SEPARATED BY space.
      IF zmm_mecs-remrk IS INITIAL.                         "+rk004
        MOVE l_remrk TO zmm_mecs-remrk.
      ENDIF.                                                "+rk004
      CLEAR l_remrk.
      EXIT.
    ENDIF.

    CLEAR l_value.
    l_value = zmm_mecs-matnr+0(2).
    IF l_value NE '0C'.
      CLEAR t149d.
      SELECT SINGLE * FROM t149d WHERE bwtar = zmm_mecs-bwtar.
      IF sy-subrc NE 0.
        CONCATENATE 'Valuation type'
                     zmm_mecs-bwtar
                    'does not exist - check your entry'
                    INTO l_remrk SEPARATED BY space.
        IF zmm_mecs-remrk IS INITIAL.                       "+rk004
          MOVE l_remrk TO zmm_mecs-remrk.
        ENDIF.                                              "+rk004
        CLEAR l_remrk.
        EXIT.
      ENDIF.

      CLEAR l_trip.
*       l_trip = zmm_mecs-bwtar+0(3).                       "-rk006
      l_trip = zmm_mecs-bwtar+0(2).                         "+rk006
      IF l_value GE '01' AND l_value LE '16'.
*{-RK006
*         IF l_trip NE 'STI'.
*           zmm_mecs-remrk = text-012.
*           EXIT.
*         ENDIF.
*       ELSEIF l_value GE '21' AND l_value LE '42'.
*         IF l_trip NE 'SPI'.
*           zmm_mecs-remrk = text-013.
*           EXIT.
*         ENDIF.
*       ENDIF.
*}-RK006
*{+RK006
        IF l_trip NE 'ST'.
          zmm_mecs-remrk = TEXT-019.
          EXIT.
        ENDIF.
      ELSEIF l_value GE '21' AND l_value LE '42'.
        IF l_trip NE 'SP'.
          zmm_mecs-remrk = TEXT-018.
          EXIT.
        ENDIF.
      ENDIF.
*}+RK006
    ELSE.
      IF l_value EQ '0C'.
        IF zmm_mecs-bwtar NE 'BATCH_MNGD'."'Batch Managed'.
          zmm_mecs-remrk = TEXT-011.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF sy-subrc EQ 0.
    CLEAR zmm_mecs-remrk.
  ENDIF.

ENDFORM.                    " validate_records
*&---------------------------------------------------------------------*
*&      Form  GET_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_itab_data.

  DATA: l_itab TYPE TABLE OF zmm_mecs WITH HEADER LINE..

*   CLEAR ZMM_MEMS.
  SELECT SINGLE * FROM zmm_mems WHERE docno = g_docno.

  IF g_ok_82 EQ 'CHANGE'.

    IF zmm_mems-sflag EQ 'C'.

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Error'
          textline1 = 'Request cannot be changed at this stage'
          textline2 = 'The request has been completed'.

      SET SCREEN 9080.

    ELSEIF zmm_mems-sflag EQ 'P'.

      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Error'
          textline1 = 'Request cannot be changed at this stage.'
          textline2 = 'The request is under process.'.

      SET SCREEN 9080.


    ELSE.

      CLEAR : l_itab.
      SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
               l_itab  WHERE docno = g_docno.

      LOOP AT l_itab.
        MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
        APPEND g_tc_81_wa TO g_tc_81_itab.
      ENDLOOP.

      SET SCREEN 9081.

    ENDIF.

  ELSE.

    CLEAR : l_itab.
    SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
             l_itab  WHERE docno = g_docno.

    LOOP AT l_itab.
      MOVE-CORRESPONDING l_itab TO g_tc_81_wa.
      APPEND g_tc_81_wa TO g_tc_81_itab.
    ENDLOOP.

    SET SCREEN 9081.

  ENDIF.


ENDFORM.                    " GET_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_user.

  DATA: l_mems TYPE zmm_mems.

  IF NOT ( zmm_mems-docno IS INITIAL ).

    SELECT SINGLE * FROM zmm_mems INTO l_mems
                    WHERE docno = zmm_mems-docno.

    IF sy-uname <> l_mems-ernam.
      IF g_ok_80 EQ 'CHANGE'.
        MESSAGE s353.
        LEAVE TO SCREEN 9080.
      ELSEIF g_ok_80 EQ 'DELETE'.
        MESSAGE s358.
        LEAVE TO SCREEN 9080.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_USER
*&---------------------------------------------------------------------*
*&      Form  get_commitment_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_commitment_number.

  DATA: l_valclass  TYPE zmm_valclass.
  DATA: l_konts     TYPE t030-konts.
  DATA: l_fipos     TYPE skb1-fipos.


  CLEAR l_valclass.
  CLEAR zmm_mecs-fipos.

  SELECT * FROM zmm_valclass
 INTO l_valclass UP TO 1 ROWS WHERE matnr_from LE zmm_mecs-matnr AND matnr_to GE zmm_mecs-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
  ENDSELECT.

  IF sy-subrc EQ 0.
    CLEAR l_konts.
    SELECT konts INTO l_konts
 FROM t030 UP TO 1 ROWS WHERE ktosl = 'BSX' AND bwmod = 'ONGC' AND bklas = l_valclass-val_class
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc EQ 0.
      CLEAR l_fipos.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

*      SELECT SINGLE fipos INTO l_fipos
*      FROM skb1 WHERE saknr = l_konts
*                  AND bukrs = zmm_mems-bukrs.
      SELECT SINGLE CommitmentItem AS fipos
  FROM I_GLAccountInCompanyCode
  INTO @l_fipos
  WHERE GLAccount   = @l_konts
    AND CompanyCode = @zmm_mems-bukrs.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
      IF sy-subrc EQ 0.
        MOVE l_fipos TO zmm_mecs-fipos.
        CLEAR l_fipos.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_commitment_number
*&---------------------------------------------------------------------*
*&      Form  GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_delete_itab_data.

  DATA: l_delete TYPE TABLE OF zmm_mecs WITH HEADER LINE.
  DATA: l_ans.

  SELECT SINGLE * FROM zmm_mems WHERE docno = g_docno.

  IF zmm_mems-sflag EQ 'C'.

    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Error'
        textline1 = 'Request cannot be deleted.'
        textline2 = 'The request has been completed'.

    SET SCREEN 9080.

  ELSEIF zmm_mems-sflag EQ 'P'.

    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
      EXPORTING
        titel     = 'Error'
        textline1 = 'Request cannot be deleted at this stage.'
        textline2 = 'The request is under process.'.

    SET SCREEN 9080.

  ELSE.

    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'Y'
        textline1     = 'Delete the Document'
        textline2     = 'You will lose the Document data'
        titel         = 'Confirmation'
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = l_ans.

    IF l_ans EQ 'J'.

      CLEAR : l_delete.

      SELECT * FROM zmm_mecs INTO CORRESPONDING FIELDS OF TABLE
            l_delete  WHERE docno = g_docno.

      IF sy-subrc EQ 0.

        READ TABLE l_delete WITH KEY sflag = 'P'.

        IF sy-subrc NE 0.

          DELETE FROM zmm_mems WHERE docno = g_docno.

          DELETE zmm_mecs FROM TABLE l_delete.

          IF sy-subrc EQ 0.
            MESSAGE s356(zmm).
          ENDIF.
        ELSE.
          MESSAGE s357(zmm).
        ENDIF.

      ENDIF.

    ELSEIF l_ans EQ 'N'.

*     EXIT.

    ENDIF.

    SET SCREEN 9080.

  ENDIF.



ENDFORM.                    " GET_DELETE_ITAB_DATA
*&---------------------------------------------------------------------*
*&      Form  fcode_copy_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TC_NAME  text
*      -->P_P_TABLE_NAME  text
*      -->P_P_MARK_NAME  text
*----------------------------------------------------------------------*
FORM fcode_copy_row USING    p_tc_name
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

* delete marked lines                                                  *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*   access to the component 'FLAG' of the table header                 *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      CLEAR <mark_field>.
      APPEND  <wa> TO <table>. "INDEX syst-tabix.
      CLEAR <mark_field>.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " fcode_copy_row
*&---------------------------------------------------------------------*
*&      Form  confirm_user_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_user_action.

  DATA : ans.

  IF g_ok_80 EQ 'CREATE' OR g_ok_80 EQ 'CHANGE'.
    IF NOT ( g_tc_81_itab IS INITIAL ).
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
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
        IMPORTING
          answer                = ans
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CASE ans.
        WHEN '1'.
          LEAVE TO SCREEN 9080.
      ENDCASE.
    ELSE.
      LEAVE TO SCREEN 9080.
    ENDIF.
  ELSE.
    LEAVE TO SCREEN 9080.
  ENDIF.
ENDFORM.                    " confirm_user_action
*&---------------------------------------------------------------------*
*&      Form  pfstatus
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pfstatus.

  CASE g_ok_80.

    WHEN 'DELETE'.
      CLEAR tab.
      MOVE 'CHANGE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPLAY' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
    WHEN 'CHANGE'.
      CLEAR tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPLAY' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
    WHEN 'DISPLAY'.
      CLEAR tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHANGE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
  ENDCASE.

  SET PF-STATUS 'ZMM03' EXCLUDING tab.

ENDFORM.                    " pfstatus
*&---------------------------------------------------------------------*
*&      Form  delete_data_base
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_data_base.
  DELETE zmm_mecs  FROM TABLE ist_del.
ENDFORM.                    " delete_data_base
*&---------------------------------------------------------------------*
*&      Form  get_matnr_desc
*&---------------------------------------------------------------------*
*       FETCH MATERIAL DESC ROUTINE
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
FORM get_matnr_desc USING p_matnr.
  CLEAR :wa_makt.

  IF NOT p_matnr IS INITIAL.

    CALL FUNCTION 'MAKT_SINGLE_READ'
      EXPORTING
        matnr      = p_matnr
        spras      = 'E'
      IMPORTING
        wmakt      = wa_makt
      EXCEPTIONS
        wrong_call = 1
        not_found  = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_matnr_desc
*&---------------------------------------------------------------------*
*&      Form  validate_matnr
*&---------------------------------------------------------------------*
*       validation of matcode
*----------------------------------------------------------------------*
*      -->P_ZMM_MECS_MATNR  text
*----------------------------------------------------------------------*
FORM validate_matnr USING  matnr
*{   INSERT         OCPK900065                                        1
steuc
*}   INSERT
                    CHANGING remrk.

  CALL FUNCTION 'MARA_READ'
    EXPORTING
      i_matnr  = matnr
    EXCEPTIONS
      no_entry = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    msg_log-msgno = sy-msgno.
    msg_log-msgty = sy-msgty.
    msg_log-msgid = sy-msgid.

    CALL FUNCTION 'MESSAGE_TEXTS_READ'
      EXPORTING
        msg_log_imp  = msg_log
      IMPORTING
        msg_text_exp = msg_text
      EXCEPTIONS
        OTHERS       = 1.

    MOVE msg_text-msgtx TO remrk.
  ELSE.
    CLEAR remrk.
  ENDIF.

*----start of addition rk004 -------*
  IF NOT matnr+0(2) IN r_mat_grp.                           "+rk004
    IF remrk IS INITIAL.
      MOVE TEXT-017 TO remrk.
    ENDIF.
  ELSE.
    CLEAR remrk.
  ENDIF.
*----end of addition rk004 -------*
*{   INSERT         OCPK900065                                        2
**********************************************************************
  DATA: BEGIN OF wa_t604f,
          land1 TYPE land1,
          steuc TYPE steuc,
        END OF wa_t604f.

  SELECT land1 steuc FROM t604f INTO wa_t604f WHERE land1 = 'IN' AND steuc = steuc.
  ENDSELECT.

  IF wa_t604f IS INITIAL.

    MESSAGE ID '00' TYPE 'E' NUMBER '058' WITH steuc '' '' 'T604F'.

  ENDIF.
**********************************************************************
*}   INSERT

ENDFORM.                    " validate_matnr
*&---------------------------------------------------------------------*
*&      Form  get_valid_cocodes
*&---------------------------------------------------------------------*
*       Valid company codes routine
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_valid_cocodes.

  SELECT bukrs butxt FROM t001 INTO TABLE ist_t001 WHERE
                          land1 = 'IN' AND spras = 'E' AND
                          ktopl = 'ONGC' AND bukrs <> 'RNT' .

  DELETE ist_t001 WHERE bukrs = 'JVA'.

ENDFORM.                    " get_valid_cocodes
*&---------------------------------------------------------------------*
*&      Form  EXTEND_MATERIAL
*&---------------------------------------------------------------------*
* Extend Material For Plant
*----------------------------------------------------------------------*
FORM extend_material .
  DATA: zmm_me01_wa       TYPE   zmm_me01.
  DATA: zmm_me02_wa       TYPE   zmm_me02.
  DATA: l_valclass        TYPE   zmm_valclass.
  DATA: t001w         LIKE t001w.
  DATA: l_views(1) TYPE n.

  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: plants TYPE STANDARD TABLE OF marc_werk.
  FIELD-SYMBOLS: <plants> TYPE marc_werk.
  TYPES: BEGIN OF ty_mm01_del,
           matnr LIKE rmmg1-matnr,             "Material Code
           bwtar LIKE rmmg1-bwtar,
         END OF ty_mm01_del.
  DATA: lt_mm01_del TYPE STANDARD TABLE OF ty_mm01_del,
        ls_mm01_del TYPE ty_mm01_del.

  CLEAR g_tc_81_wa.

  REFRESH g_mm01_ist.
  LOOP AT g_tc_81_itab INTO g_tc_81_wa WHERE flag NE 'X'.
    CLEAR:  return, g_mm01_wa, general_data, t001w, g_exist, ls_headdata.
    CALL FUNCTION 'GET_PLANT_DETAILS'
      EXPORTING
        i_werks         = g_tc_81_wa-werks
      IMPORTING
        e_t001w         = t001w
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        OTHERS          = 3.

    IF sy-subrc EQ 0.
      IF g_tc_81_wa-bwtar EQ 'BATCH_MNGD'.
        CLEAR g_tc_81_wa-bwtar.
      ENDIF.
      "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026


      DATA: lv_matnr TYPE bapimatdet-material.
      lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
        EXPORTING
*         material              = g_tc_81_wa-matnr
          material              = lv_matnr
          plant                 = g_tc_81_wa-werks
          valuationarea         = t001w-bwkey
          valuationtype         = g_tc_81_wa-bwtar
        IMPORTING
          material_general_data = general_data
          return                = return
          materialplantdata     = plantdata
          materialvaluationdata = valuationdata.
      "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
      CASE return-type.
        WHEN 'W'.
          IF return-code EQ 'MM363' OR return-code EQ 'MM361'.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.

          ENDIF.
        WHEN 'E'.
          IF return-code EQ 'M3192'.
            "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026
            CLEAR:lv_matnr.
            lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
            CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
              EXPORTING
*               MATERIAL              = G_TC_81_WA-MATNR
                material              = lv_matnr
              IMPORTING
                material_general_data = general_data
                return                = return.
            g_all = space.
            g_only_second = space.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.
            "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026

          ELSEIF return-code EQ 'M3305'.
*             wa_msg-docno = g_tc_81_wa-docno.            "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-msgv1 = return-message_v1.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.

          ENDIF.

        WHEN 'S'.

          CALL FUNCTION 'MATERIAL_READ_PLANTS'
            EXPORTING
              matnr  = g_tc_81_wa-matnr
            TABLES
              plants = plants.

          READ TABLE plants ASSIGNING <plants> WITH KEY werks = g_tc_81_wa-werks.

          DATA : l_strlen TYPE i.

          l_strlen = strlen( <plants>-pstat ).
*--------start of changes by rk004------------------------------------*

*           IF l_strlen < 6.                               "-rk004
          CLEAR t320.                                       "+rk001
          CLEAR l_views.
          SELECT * FROM t320 UP TO 1 ROWS
 WHERE werks EQ g_tc_81_wa-werks
 ORDER BY PRIMARY KEY .
          ENDSELECT.
          IF sy-subrc IS INITIAL.
            l_views = 7.
          ELSE.
            l_views = 6.
          ENDIF.

          IF l_strlen < l_views.
            PERFORM view_to_extend USING g_tc_81_wa-matnr g_tc_81_wa-werks.
          ENDIF.
      ENDCASE.


      IF ls_headdata IS INITIAL.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        APPEND ls_headdata TO lt_headdata.

      ENDIF.

      CLEAR g_mm01_wa.
*      G_MM01_WA-DOCNO = G_TC_81_WA-DOCNO.
      g_mm01_wa-matnr = g_tc_81_wa-matnr.  " Material
*{   INSERT         OCPK900065                                        1
      g_mm01_wa-steuc = g_tc_81_wa-steuc.
      g_mm01_wa-taxim = g_tc_81_wa-taxim.
*}   INSERT
      g_mm01_wa-werks = g_tc_81_wa-werks.  " Plant
*----------------------------------------------------------------------*
* Find Sales Organization
*----------------------------------------------------------------------*


      IF t001w-vkorg NE space.
        g_mm01_wa-vkorg = t001w-vkorg.  " Sales org
      ELSE.
        CLEAR zmm_me01_wa.
        SELECT SINGLE * FROM zmm_me01 INTO zmm_me01_wa
                        WHERE werks EQ g_tc_81_wa-werks.
        IF sy-subrc EQ 0.
          IF zmm_me01_wa-vkorg NE space.
            g_mm01_wa-vkorg = zmm_me01_wa-vkorg.  " Sales Org
          ELSE.
*            WA_MSG-DOCNO = NUMBER.
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Sales Org does not exit for plant'
                         g_tc_81_wa-werks INTO wa_msg-msgv1
                         SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.

            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.
        ELSE.
*          WA_MSG-DOCNO = G_TC_81_WA-DOCNO.
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                      'does not exist in table ZMM_ME01'
                      INTO wa_msg-msgv1
                      SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
        ENDIF.
      ENDIF.

*----------------------------------------------------------------------*
* Find Warehouse number                                                *
*----------------------------------------------------------------------*
      CLEAR t320.
      SELECT * FROM t320 UP TO 1 ROWS
 WHERE werks EQ g_tc_81_wa-werks
 ORDER BY PRIMARY KEY .
      ENDSELECT.

      IF sy-subrc EQ 0.

        """""""""""""""""""""""""""""""""""""""
        "added  by lipsy
        IF g_tc_81_wa-werks = '61H2' OR g_tc_81_wa-werks = '61A2' OR g_tc_81_wa-werks = '61E2' OR
          g_tc_81_wa-werks = '61B2' OR g_tc_81_wa-werks = '61D2' OR g_tc_81_wa-werks = '61L2' OR g_tc_81_wa-werks = '61W2'.

          t320-lgnum = 'BKO'.

        ENDIF.
        "eadd by lipsy
        """"""""""""""""""""""""""""""""""""""""""""

        g_mm01_wa-lgnum = t320-lgnum.
      ENDIF.
*----------------------------------------------------------------------*
* Get Profit center for plant
*----------------------------------------------------------------------*
      CLEAR zmm_me01_wa.
      SELECT SINGLE * FROM zmm_me01
                      INTO zmm_me01_wa
                      WHERE werks EQ g_tc_81_wa-werks.

      IF sy-subrc EQ 0.
        IF zmm_me01_wa-prctr NE space.
          g_mm01_wa-prctr = zmm_me01_wa-prctr.  " Profit Center
        ELSE.
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Profit Center does not exit for plant'
                       g_tc_81_wa-werks INTO wa_msg-msgv1
                       SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
*           g_mm01_del-docno = g_tc_child_wa-docno.          "+rk003
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
        ENDIF.
      ELSE.
*        WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.                 "+rk003
        wa_msg-matnr = g_tc_81_wa-matnr.
        wa_msg-msgtyp = 'E'.
        wa_msg-bwtar = g_tc_81_wa-bwtar.
        wa_msg-werks = g_tc_81_wa-werks.
        CONCATENATE 'Entry for plant' g_tc_81_wa-werks
               'does not exist in table ZMM_ME01'  INTO wa_msg-msgv1
                    SEPARATED BY space.
        APPEND wa_msg TO ist_msg.
        CLEAR ls_mm01_del.
*        G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.             "+rk003
        ls_mm01_del-matnr = g_tc_81_wa-matnr.
        ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
        APPEND ls_mm01_del TO lt_mm01_del.
      ENDIF.

      g_mm01_wa-prodh = general_data-prod_hier.  " Product hier
      g_mm01_wa-mtart = general_data-matl_type.  " Material type

*----------------------------------------------------------------------*
* Find MRP Controller
*----------------------------------------------------------------------*
      CLEAR zmm_me02_wa.
      SELECT * FROM zmm_me02
 INTO zmm_me02_wa UP TO 1 ROWS WHERE werks EQ g_tc_81_wa-werks AND mtart EQ general_data-matl_type
 ORDER BY PRIMARY KEY .
      ENDSELECT.
      IF sy-subrc EQ 0.
        g_mm01_wa-dispo = zmm_me02_wa-dispo.   " MRP Controller
      ELSE.
*         wa_msg-docno = g_tc_child_wa-docno.                "+rk003
        wa_msg-matnr = g_tc_81_wa-matnr.
        wa_msg-msgtyp = 'E'.
        wa_msg-bwtar = g_tc_81_wa-bwtar.
        wa_msg-werks = g_tc_81_wa-werks.
        CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                    'does not exist in table ZMM_ME02'
                    INTO wa_msg-msgv1 SEPARATED BY space.
        APPEND wa_msg TO ist_msg.
        CLEAR ls_mm01_del.
*        G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.             "+rk003
        ls_mm01_del-matnr = g_tc_81_wa-matnr.
        ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
        APPEND ls_mm01_del TO lt_mm01_del.
      ENDIF.

*----------------------------------------------------------------------*
* Valuation Class
*----------------------------------------------------------------------*
      IF general_data-prod_hier EQ '0C'.
        g_mm01_wa-bwtty = 'X'.
        CLEAR l_valclass.
        SELECT * FROM zmm_valclass
 INTO l_valclass UP TO 1 ROWS WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
        ENDSELECT.

        IF sy-subrc EQ 0.
          g_mm01_wa-bklas = l_valclass-val_class.   " Valuation Class
        ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
          wa_msg-matnr = g_tc_81_wa-matnr.
          wa_msg-msgtyp = 'E'.
          wa_msg-bwtar = g_tc_81_wa-bwtar.
          wa_msg-werks = g_tc_81_wa-werks.
          CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                      'does not exist in table ZMM_VALCLASS'
                      INTO wa_msg-msgv1 SEPARATED BY space.
          APPEND wa_msg TO ist_msg.
          CLEAR ls_mm01_del.
*          G_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
          ls_mm01_del-matnr = g_tc_81_wa-matnr.
          ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
          APPEND ls_mm01_del TO lt_mm01_del.
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


        IF g_only_second NE 'X'.


          CLEAR l_valclass.
          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ space
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*             wa_msg-docno = g_tc_81_wa-docno.            "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*             g_mm01_del-docno = g_tc_child_wa-docno.        "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          APPEND g_mm01_wa TO g_mm01_ist.  "First line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
          CLEAR l_valclass.
          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ g_tc_81_wa-bwtar
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*          LS_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          g_mm01_wa-bwtar = g_tc_81_wa-bwtar.

          APPEND g_mm01_wa TO g_mm01_ist.  " Second Line
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
        ELSE.

          CLEAR l_valclass.

          SELECT * FROM zmm_valclass INTO l_valclass UP TO 1 ROWS
 WHERE matnr_from LE g_tc_81_wa-matnr AND matnr_to GE g_tc_81_wa-matnr AND val_type EQ g_tc_81_wa-bwtar
 ORDER BY PRIMARY KEY .
          ENDSELECT.

          IF sy-subrc EQ 0.
            g_mm01_wa-bklas = l_valclass-val_class.
          ELSE.
*          WA_MSG-DOCNO = G_TC_CHILD_WA-DOCNO.               "+rk003
            wa_msg-matnr = g_tc_81_wa-matnr.
            wa_msg-msgtyp = 'E'.
            wa_msg-bwtar = g_tc_81_wa-bwtar.
            wa_msg-werks = g_tc_81_wa-werks.
            CONCATENATE 'Entry for plant' g_tc_81_wa-werks
                        'does not exist in table ZMM_VALCLASS'
                        INTO wa_msg-msgv1 SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR ls_mm01_del.
*          LS_MM01_DEL-DOCNO = G_TC_CHILD_WA-DOCNO.           "+rk003
            ls_mm01_del-matnr = g_tc_81_wa-matnr.
            ls_mm01_del-bwtar = g_tc_81_wa-bwtar.
            APPEND ls_mm01_del TO lt_mm01_del.
          ENDIF.

          g_mm01_wa-bwtar = g_tc_81_wa-bwtar.
          APPEND g_mm01_wa TO g_mm01_ist.  " Only second line
        ENDIF.
      ENDIF.
      CLEAR: g_all, g_only_second, g_tc_81_wa, plants.
      REFRESH plants.
    ELSE.

    ENDIF.
  ENDLOOP.




*----------------------------------------------------------------------*
* Sort and delete the del in-table
*----------------------------------------------------------------------*
  SORT lt_mm01_del.
  DELETE ADJACENT DUPLICATES FROM lt_mm01_del.

  CLEAR ls_mm01_del.
  LOOP AT lt_mm01_del INTO ls_mm01_del.
    DELETE g_mm01_ist WHERE matnr EQ ls_mm01_del-matnr
                     AND bwtar EQ ls_mm01_del-bwtar.

    IF sy-subrc EQ 0.
*      WA_MSG-DOCNO = G_MM01_DEL-DOCNO.                      "+rk003
      wa_msg-matnr = ls_mm01_del-matnr.
      wa_msg-msgtyp = 'I'.
      wa_msg-bwtar = ls_mm01_del-bwtar.
      CONCATENATE 'Material' ls_mm01_del-matnr ',' ls_mm01_del-bwtar
                 'is deleted from the extension list.'
                  INTO wa_msg-msgv1 SEPARATED BY space.
      APPEND wa_msg TO ist_msg.
      " End of <RD1K960036>.
    ENDIF.
    CLEAR ls_mm01_del.

  ENDLOOP.

  SORT ist_msg.
  DELETE ADJACENT DUPLICATES FROM ist_msg.

ENDFORM.                    " EXTEND_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_material .
  DATA: general_data LIKE bapimatdoa.
  DATA: return LIKE bapireturn.
  DATA: plantdata LIKE bapimatdoc.
  DATA: valuationdata LIKE bapimatdobew.
  DATA: plants TYPE TABLE OF marc_werk WITH HEADER LINE.
  DATA: l_views(1) TYPE n.
  DATA: l_mstae LIKE mara-mstae.
  DATA: l_mtstb LIKE t141t-mtstb.

  CLEAR ist_msg[].
  LOOP AT g_tc_81_itab INTO g_tc_81_wa.
    CLEAR :l_mstae, l_mtstb.
    SELECT SINGLE mstae FROM mara INTO l_mstae WHERE
                                      matnr = g_tc_81_wa-matnr.
    IF NOT l_mstae IS INITIAL.
      SELECT SINGLE mtstb FROM t141t INTO l_mtstb WHERE
                                     mmsta = l_mstae AND
                                     spras = 'E'.
*      MOVE NUMBER TO WA_MSG-DOCNO.
      MOVE g_tc_81_wa-matnr TO wa_msg-matnr.
      MOVE g_tc_81_wa-bwtar TO wa_msg-bwtar.
      MOVE 'E' TO wa_msg-msgtyp.
      MOVE g_tc_81_wa-werks TO wa_msg-werks.
      CONCATENATE 'Material' wa_msg-matnr 'BLOCKED,' l_mtstb INTO
                             wa_msg-msgv1 SEPARATED BY space.
      APPEND wa_msg TO ist_msg.
      CONTINUE.
    ENDIF.
    CALL FUNCTION 'GET_PLANT_DETAILS'
      EXPORTING
        i_werks         = g_tc_81_wa-werks
      IMPORTING
        e_t001w         = t001w
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        OTHERS          = 3.

    IF sy-subrc EQ 0.

      IF g_tc_81_wa-bwtar EQ 'BATCH_MNGD'.
        CLEAR g_tc_81_wa-bwtar.
      ENDIF.
      DATA: lv_matnr TYPE bapimatdet-material.
      lv_matnr = g_tc_81_wa-matnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL'
      CALL FUNCTION 'BAPI_MATERIAL_GET_DETAIL' "#EC CI_USAGE_OK[2438131]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
        EXPORTING
*         material              = g_tc_81_wa-matnr
          material              = lv_matnr
          plant                 = g_tc_81_wa-werks
          valuationarea         = t001w-bwkey
          valuationtype         = g_tc_81_wa-bwtar
        IMPORTING
          material_general_data = general_data
          return                = return
          materialplantdata     = plantdata
          materialvaluationdata = valuationdata.

      IF return-type EQ 'S'.

        CALL FUNCTION 'MATERIAL_READ_PLANTS'
          EXPORTING
            matnr  = g_tc_81_wa-matnr
          TABLES
            plants = plants.


        READ TABLE plants WITH KEY werks = g_tc_81_wa-werks
                                   matnr = g_tc_81_wa-matnr.

        IF sy-subrc EQ 0.
          DATA : l_strlen TYPE i.
          l_strlen = strlen( plants-pstat ).

          CLEAR t320.
          CLEAR l_views.
          SELECT SINGLE * FROM t320 WHERE werks EQ g_tc_81_wa-werks.
          IF sy-subrc IS INITIAL.
            l_views = 7.
          ELSE.
            l_views = 6.
          ENDIF.

          IF l_strlen = l_views.

*            MOVE NUMBER TO WA_MSG-DOCNO.
            MOVE g_tc_81_wa-matnr TO wa_msg-matnr.
            IF general_data-matl_type EQ 'ZCAP'.
              g_tc_81_wa-bwtar = 'BATCH_MNGD'.
            ENDIF.
            MOVE g_tc_81_wa-bwtar TO wa_msg-bwtar.
*             MOVE 'E'                 TO wa_msg-msgtyp.
            MOVE 'W'                 TO wa_msg-msgtyp.
            MOVE g_tc_81_wa-werks TO wa_msg-werks.
            CONCATENATE 'Valuation type' g_tc_81_wa-bwtar
                        'for material' g_tc_81_wa-matnr
                        'and plant' g_tc_81_wa-werks
                        'already maintained.' INTO wa_msg-msgv1
                         SEPARATED BY space.
            APPEND wa_msg TO ist_msg.
            CLEAR wa_msg-msgv1.
          ENDIF.
          CLEAR l_strlen.
        ENDIF.
      ENDIF.

    ENDIF.
    CLEAR: t001w, g_tc_81_wa, general_data, return.
    CLEAR plants.
  ENDLOOP.

  IF ist_msg IS INITIAL.
    g_check_flag = 'X'.
  ELSE.
    LOOP AT ist_msg INTO wa_msg.
      IF wa_msg-msgtyp = 'E' OR wa_msg-msgtyp = 'W' .
        READ TABLE g_tc_81_itab INTO g_tc_81_wa WITH KEY
*                                          DOCNO = WA_MSG-DOCNO
                                          matnr = wa_msg-matnr
                                          werks = wa_msg-werks
                                          bwtar = wa_msg-bwtar.
        IF sy-subrc IS INITIAL.
*          DELETE G_TC_81_ITAB INDEX SY-TABIX.
          MOVE wa_msg-msgv1 TO g_tc_81_wa-remrk.
          MOVE 'X' TO g_tc_81_wa-flag.
        ENDIF.
      ENDIF.
    ENDLOOP.
    g_check_flag = 'X'.
  ENDIF.
ENDFORM.                    " CHECK_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  EXTEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM extend .
  DATA: ls_rmmg1              TYPE rmmg1,
        ls_mvke               TYPE mvke,
        ls_marc               TYPE marc,
*{   INSERT         OCPK900065                                        2
        ls_TAXCLASSIFICATIONS TYPE bapi_mlan,
*}   INSERT
        ls_mbew               TYPE mbew,
        return2               TYPE bapiret2.
  DATA: t_plant TYPE STANDARD TABLE OF marc_werk.
  DATA: lv_mtart TYPE mara-mtart,
        lv_bwtar TYPE rmmg1-bwtar.

  FIELD-SYMBOLS: <wa_plant> TYPE marc_werk.


*  DATA: T_RETURN TYPE STANDARD TABLE OF BAPIRET2.
  FIELD-SYMBOLS: <g_mm01_wa>   TYPE t_mm01,
                 <ls_headdata> TYPE bapimathead.

  DATA: g_mm01_tmp TYPE STANDARD TABLE OF t_mm01.
  FIELD-SYMBOLS <g_mm01_tmp> TYPE t_mm01.
  DATA lv_prevmatnr TYPE mara-matnr.

  DATA lv_head TYPE bapimathead.
  DATA: lv_syuname TYPE sy-uname.
  DATA: lv_str(50) TYPE c.
*  SORT G_MM01_IST BY MATNR.

*  LOOP AT G_MM01_IST ASSIGNING <G_MM01_WA>.
*    IF <G_MM01_WA>-BWTAR IS NOT INITIAL.
*       APPEND <G_MM01_WA> TO G_MM01_TMP.
*       DELETE TABLE G_MM01_IST FROM <G_MM01_WA>.
*     ENDIF.
*  ENDLOOP.
*APPEND LINES OF G_MM01_TMP TO G_MM01_IST.

*  LOOP AT G_MM01_TMP ASSIGNING <G_MM01_TMP>.
*    APPEND <G_MM01_TMP> TO G_MM01_IST.
*  ENDLOOP.

  lv_syuname = sy-uname.
  SORT lt_headdata BY material.

  SELECT SINGLE * FROM agr_users INTO w_agr_users WHERE uname = lv_syuname.
  w_agr_users-agr_name = 'D:MM_BAPI_MATEXTN_RUN'.
  w_agr_users-from_dat = sy-datum - 1.
  w_agr_users-to_dat = sy-datum + 1.
  PERFORM update_agrname ON COMMIT.
  PERFORM commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.
****Start of changes for message 403030
*  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFS'
*      EXPORTING
*        ACTIVITY_GROUP             = 'D:MM_BAPI_MATEXTN_RUN'
*        DISPLAY_MESSAGES           = SPACE
*        AUTHORITY_CHECK            = SPACE
**        CHANGING
**          return_tab                 = it_return_tab
*      EXCEPTIONS
*        AUTHORITY_INCOMPLETE       = 1
*        AT_LEAST_ONE_USER_ENQUEUED = 2
*        NO_PROFILES_AVAILABLE      = 3
*        TOO_MANY_PROFILES_IN_USER  = 4
*        OTHERS                     = 5.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFC'
    EXPORTING
      activity_group                = 'D:MM_BAPI_MATEXTN_RUN'
      display_messages              = space
      collective_role               = Space
*     DB_UPDATE                     = 'X'
* IMPORTING
*     MESSAGES                      =
* TABLES
*     PROCESSED_SINGLE_ROLES        =
*     SGLS_IN_COLL                  =
* CHANGING
*     RETURN_TAB                    =
    EXCEPTIONS
      no_authority_for_user_compare = 1
      authority_incomplete          = 2
      child_agr_enqueued            = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

****End of changes for message 403030
  COMMIT WORK.
  sy-uname = lv_syuname.
  CLEAR: w_agr_users.

  """"""""""""""""""
  ""added by lipsy on 20.08.2015  RD1K998283

  IF zmm_mems-lgnum IS NOT INITIAL.
    REFRESH:G_MM01_sec[].
    CLEAR:G_MM01_sec[].
    G_MM01_sec[] = g_mm01_ist[].
    CLEAR g_mm01_wa.
    LOOP AT G_MM01_sec ASSIGNING <g_mm01_wa>.
      <g_mm01_wa>-lgnum = zmm_mems-lgnum.
      APPEND   <g_mm01_wa> TO G_MM01_ist.
      CLEAR g_mm01_wa.
    ENDLOOP.
    CLEAR g_mm01_wa.
  ENDIF.
  ""end of addition by lipsy on 20.08.2015  RD1K998283
  """"""""""""""""""""""

  LOOP AT g_mm01_ist ASSIGNING <g_mm01_wa>.
    ls_rmmg1-matnr = <g_mm01_wa>-matnr.
    ls_rmmg1-werks = <g_mm01_wa>-werks.
    ls_rmmg1-bwtar = <g_mm01_wa>-bwtar.
    ls_rmmg1-lgnum = <g_mm01_wa>-lgnum.
    ls_rmmg1-vkorg = <g_mm01_wa>-vkorg.
    ls_rmmg1-mtart = <g_mm01_wa>-mtart.
    ls_mvke-prodh  = <g_mm01_wa>-prodh.
*{   INSERT         OCPK900065                                        1
    ls_marc-steuc = <g_mm01_wa>-steuc.
    ls_TAXCLASSIFICATIONS-depcountry = 'IN'.
    ls_TAXCLASSIFICATIONS-tax_ind = <g_mm01_wa>-taxim.
*}   INSERT
    ls_marc-prctr  = <g_mm01_wa>-prctr.
    ls_marc-dispo  = <g_mm01_wa>-dispo.
    ls_mbew-bwtty  = <g_mm01_wa>-bwtty.
    ls_mbew-bklas  = <g_mm01_wa>-bklas.
*{   INSERT         OCDK902682                                        7

    IF fcode EQ 'UPD'.
      SELECT bklas
   INTO ls_mbew-bklas FROM mbew UP TO 1 ROWS WHERE matnr = ls_rmmg1-matnr
   ORDER BY PRIMARY KEY .
      ENDSELECT.
    ENDIF.
*}   INSERT

    READ TABLE lt_headdata ASSIGNING <ls_headdata>
    WITH KEY material  = <g_mm01_wa>-matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'ZMM_MATERIAL_EXTEND'
        EXPORTING
          ls_rmmg1              = ls_rmmg1
          ls_mathead            = <ls_headdata>
          ls_mvke               = ls_mvke
          ls_marc               = ls_marc
*{   INSERT         OCPK900065                                        3
          ls_TAXCLASSIFICATIONS = ls_taxclassifications
*}   INSERT
          ls_mbew               = ls_mbew
        IMPORTING
          return                = return2
        TABLES
          returnmessages        = returnmessages.
    ELSE.
      lv_head-material = <g_mm01_wa>-matnr.
      lv_head-matl_type = <g_mm01_wa>-mtart.
      lv_head-sales_view = 'X'.
      lv_head-purchase_view = 'X'.
      lv_head-mrp_view = 'X'.
      lv_head-storage_view = 'X'.
      lv_head-warehouse_view = 'X'.
      lv_head-account_view = 'X'.
      lv_head-quality_view = 'X'.

      CALL FUNCTION 'ZMM_MATERIAL_EXTEND'
        EXPORTING
          ls_rmmg1              = ls_rmmg1
          ls_mathead            = lv_head
          ls_mvke               = ls_mvke
*{   INSERT         OCPK900065                                        4
          ls_TAXCLASSIFICATIONS = ls_taxclassifications
*}   INSERT
          ls_marc               = ls_marc
          ls_mbew               = ls_mbew
        IMPORTING
          return                = return2
        TABLES
          returnmessages        = returnmessages.
    ENDIF.


*    LV_PREVMATNR = LS_RMMG1-MATNR.

    MOVE <g_mm01_wa>-bwtar TO lv_bwtar.
    SELECT SINGLE mtart FROM mara INTO (lv_mtart) WHERE matnr = <g_mm01_wa>-matnr.
    IF lv_mtart EQ 'ZCAP'.
      MOVE 'BATCH_MNGD' TO lv_bwtar.
    ENDIF.
    CASE return2-type.
      WHEN 'S'.
*{   INSERT         OCPK900065                                        5
        IF g_ok_80 EQ 'UPDATE'.
          CLEAR:  ls_zmm_mecs.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                WHERE docno = number
                  AND matnr = <g_mm01_wa>-matnr
                  AND werks = <g_mm01_wa>-werks
                  AND bwtar = lv_bwtar.
          IF ls_zmm_mecs IS NOT INITIAL.
            ls_zmm_mecs-steuc =  ls_marc-steuc.
            ls_zmm_mecs-taxim = ls_TAXCLASSIFICATIONS-tax_ind.

            MODIFY zmm_mecs FROM ls_zmm_mecs.

            CONCATENATE 'Material' <g_mm01_wa>-matnr 'extended' INTO
           ls_zmm_mecs-remrk SEPARATED BY space.


            APPEND ls_zmm_mecs TO lt_zmm_mecs.

            MOVE number TO wa_msg-docno.
            MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
            MOVE <g_mm01_wa>-werks TO wa_msg-werks.
            MOVE lv_bwtar TO wa_msg-bwtar.
            MOVE return2-type TO wa_msg-msgtyp.
            MOVE ls_zmm_mecs-remrk TO wa_msg-msgv1.
          ENDIF.
*break-point.
*          READ TABLE    G_TC_81_ITAB INTO G_TC_81_wa with KEY MATNR =  WA_MSG-MATNR.
*          IF sy-subrc eq 0.
*              G_TC_81_wa-REMRK = WA_MSG-MSGV1.
*              modify G_TC_81_ITAB from G_TC_81_wa.
*          ENDIF.

        ELSE.



*}   INSERT
          IF lv_bwtar IS NOT INITIAL.
            SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                   WHERE docno = number
                     AND matnr = <g_mm01_wa>-matnr
                     AND werks = <g_mm01_wa>-werks
                     AND bwtar = lv_bwtar.
            CALL FUNCTION 'MATERIAL_READ_PLANTS'
              EXPORTING
                matnr  = <g_mm01_wa>-matnr
              TABLES
                plants = t_plant.

            READ TABLE t_plant ASSIGNING <wa_plant> WITH KEY matnr = <g_mm01_wa>-matnr
                                       werks = <g_mm01_wa>-werks.

            IF sy-subrc EQ 0.
              MOVE <wa_plant>-pstat TO ls_zmm_mecs-pstat.
            ENDIF.
            MOVE 'C' TO ls_zmm_mecs-sflag.
            CONCATENATE 'Material' <g_mm01_wa>-matnr 'extended' INTO
               ls_zmm_mecs-remrk SEPARATED BY space.
            APPEND ls_zmm_mecs TO lt_zmm_mecs.
            MOVE number TO wa_msg-docno.
            MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
            MOVE <g_mm01_wa>-werks TO wa_msg-werks.
            MOVE lv_bwtar TO wa_msg-bwtar.
            MOVE return2-type TO wa_msg-msgtyp.
            MOVE ls_zmm_mecs-remrk TO wa_msg-msgv1.

          ENDIF.
*{   INSERT         OCPK900065                                        6



        ENDIF.
*}   INSERT
      WHEN 'E'.
        IF lv_bwtar IS NOT INITIAL.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                WHERE docno = number
                  AND matnr = <g_mm01_wa>-matnr
                  AND werks = <g_mm01_wa>-werks
                  AND bwtar = lv_bwtar.
          CONCATENATE '(' return2-message ')' INTO lv_str.
          CONCATENATE <g_mm01_wa>-matnr 'not extended' lv_str INTO ls_zmm_mecs-remrk SEPARATED BY space.  "#EC CI_FLDEXT_OK[2215424]
          CLEAR: lv_str.
          APPEND ls_zmm_mecs TO lt_zmm_mecs.
          MOVE number TO wa_msg-docno.
          MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
          MOVE <g_mm01_wa>-werks TO wa_msg-werks.
          MOVE lv_bwtar TO wa_msg-bwtar.
          MOVE return2-type TO wa_msg-msgtyp.
          MOVE return2-message TO wa_msg-msgv1.
        ENDIF.

      WHEN OTHERS.
        IF lv_bwtar IS NOT INITIAL.
          SELECT SINGLE * FROM zmm_mecs INTO ls_zmm_mecs
                   WHERE docno = number
                     AND matnr = <g_mm01_wa>-matnr
                     AND werks = <g_mm01_wa>-werks
                     AND bwtar = lv_bwtar.
          MOVE return2-message TO ls_zmm_mecs-remrk.
          APPEND ls_zmm_mecs TO lt_zmm_mecs.
          MOVE number TO wa_msg-docno.
          MOVE <g_mm01_wa>-matnr TO wa_msg-matnr.
          MOVE <g_mm01_wa>-werks TO wa_msg-werks.
          MOVE lv_bwtar TO wa_msg-bwtar.
          MOVE return2-type TO wa_msg-msgtyp.
          MOVE return2-message TO wa_msg-msgv1.
        ENDIF.
    ENDCASE.
    IF wa_msg IS NOT INITIAL.
      APPEND wa_msg TO ist_msg.
    ENDIF.

    IF returnmessages[] IS NOT INITIAL.
      READ TABLE returnmessages INTO wa_mesg INDEX 1.
      MOVE wa_mesg-type TO wa_msg-msgtyp.
      MOVE wa_mesg-message TO wa_msg-msgv1.
      APPEND wa_msg TO ist_msg.
    ENDIF.


    CLEAR: ls_zmm_mecs, ls_zmm_mems, wa_msg, lv_bwtar, lv_mtart, return2, wa_mesg, returnmessages[].
  ENDLOOP.

  SELECT SINGLE * FROM agr_users INTO w_agr_users WHERE agr_name = 'D:MM_BAPI_MATEXTN_RUN'
  AND uname = lv_syuname.
  PERFORM update_agr ON COMMIT.
  PERFORM commit_rollback.

  sy-uname = 'ROLE_ASN_USR'.
****Start of changes for message 403030
*  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFS'
*      EXPORTING
*        ACTIVITY_GROUP             = 'D:MM_BAPI_MATEXTN_RUN'
*        DISPLAY_MESSAGES           = SPACE
*        AUTHORITY_CHECK            = SPACE
**        CHANGING
**          return_tab                 = it_return_tab
*      EXCEPTIONS
*        AUTHORITY_INCOMPLETE       = 1
*        AT_LEAST_ONE_USER_ENQUEUED = 2
*        NO_PROFILES_AVAILABLE      = 3
*        TOO_MANY_PROFILES_IN_USER  = 4
*        OTHERS                     = 5.
  CALL FUNCTION 'PRGN_ACTIVITY_GROUP_USERPROFC'
    EXPORTING
      activity_group                = 'D:MM_BAPI_MATEXTN_RUN'
      display_messages              = space
      collective_role               = Space
*     DB_UPDATE                     = 'X'
* IMPORTING
*     MESSAGES                      =
* TABLES
*     PROCESSED_SINGLE_ROLES        =
*     SGLS_IN_COLL                  =
* CHANGING
*     RETURN_TAB                    =
    EXCEPTIONS
      no_authority_for_user_compare = 1
      authority_incomplete          = 2
      child_agr_enqueued            = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
****End of changes for message 403030

  COMMIT WORK.

  sy-uname = lv_syuname.

  SORT ist_msg BY matnr.
*  DELETE ADJACENT DUPLICATES FROM IST_MSG COMPARING MATNR.

  PERFORM update_zmm_mecs ON COMMIT.
  PERFORM commit_rollback.
  PERFORM update_zmm_mems ON COMMIT.
  PERFORM commit_rollback.

ENDFORM.                    " EXTEND
*&---------------------------------------------------------------------*
*&      Form  VIEW_TO_EXTEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_TC_81_WA_MATNR  text
*      -->P_G_TC_81_WA_WERKS  text
*----------------------------------------------------------------------*
FORM view_to_extend  USING    p_g_tc_81_wa_matnr
                              p_g_tc_81_wa_werks.
  DATA: l_pstat(7).
  DATA: plants TYPE STANDARD TABLE OF marc_werk.
  FIELD-SYMBOLS <plants> TYPE marc_werk.
*  DATA: LV_MTART TYPE MARA-MTART.
*   clear p_only_second.
  SELECT SINGLE mtart INTO (ls_headdata-matl_type) FROM mara WHERE matnr = p_g_tc_81_wa_matnr.
  ls_headdata-material = p_g_tc_81_wa_matnr.

  CALL FUNCTION 'MATERIAL_READ_PLANTS'
    EXPORTING
      matnr  = p_g_tc_81_wa_matnr
    TABLES
      plants = plants.

  READ TABLE plants ASSIGNING <plants> WITH KEY werks = p_g_tc_81_wa_werks.
  IF sy-subrc EQ 0.
*    IF <PLANTS>-WERKS  = '90R1'.
**    CLEAR L_PSTAT.
**      LS_HEADDATA-SALES_VIEW = 'X'.
*      LS_HEADDATA-PURCHASE_VIEW = 'X'.
*      LS_HEADDATA-MRP_VIEW = 'X'.
*      LS_HEADDATA-STORAGE_VIEW = 'X'.
**      LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*      LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*      LS_HEADDATA-QUALITY_VIEW = 'X'.
*    ELSEIF  <PLANTS>-WERKS  NE '90R1'. .

    CASE <plants>-pstat.

      WHEN 'VEDLSQB'.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        g_only_second = 'X'.
      WHEN 'DELBSVQ'.
        ls_headdata-sales_view = 'X'.
        ls_headdata-purchase_view = 'X'.
        ls_headdata-mrp_view = 'X'.
        ls_headdata-storage_view = 'X'.
        ls_headdata-warehouse_view = 'X'.
        ls_headdata-account_view = 'X'.
        ls_headdata-quality_view = 'X'.
        g_only_second = 'X'.
      WHEN OTHERS.
        SEARCH <plants>-pstat FOR 'V'.
        IF sy-subrc EQ 0.
          ls_headdata-sales_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'E'.
        IF sy-subrc EQ 0.
          ls_headdata-purchase_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'D'.
        IF sy-subrc EQ 0.
          ls_headdata-mrp_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'L'.
        IF sy-subrc EQ 0.
          ls_headdata-storage_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'S'.
        IF sy-subrc EQ 0.
          ls_headdata-warehouse_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'B'.
        IF sy-subrc EQ 0.
          ls_headdata-account_view = 'X'.
        ENDIF.
        SEARCH <plants>-pstat FOR 'Q'.
        IF sy-subrc EQ 0.
          ls_headdata-quality_view = 'X'.
        ENDIF.

    ENDCASE.
*      IF <PLANTS>-PSTAT NE 'VEDLSQB'.
**        DELBSVQ
*        SEARCH <PLANTS>-PSTAT FOR 'V'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-SALES_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'E'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-PURCHASE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'D'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-MRP_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'L'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-STORAGE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'S'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'B'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*        ENDIF.
*        SEARCH <PLANTS>-PSTAT FOR 'Q'.
*        IF SY-SUBRC EQ 0.
*          LS_HEADDATA-QUALITY_VIEW = 'X'.
*        ENDIF.
*      ELSEIF <PLANTS>-PSTAT EQ 'VEDLSQB'.
*        LS_HEADDATA-SALES_VIEW = 'X'.
*        LS_HEADDATA-PURCHASE_VIEW = 'X'.
*        LS_HEADDATA-MRP_VIEW = 'X'.
*        LS_HEADDATA-STORAGE_VIEW = 'X'.
*        LS_HEADDATA-WAREHOUSE_VIEW = 'X'.
*        LS_HEADDATA-ACCOUNT_VIEW = 'X'.
*        LS_HEADDATA-QUALITY_VIEW = 'X'.
*        G_ONLY_SECOND = 'X'.
*      ENDIF.
*    ENDIF.
  ELSE.
    ls_headdata-sales_view = 'X'.
    ls_headdata-purchase_view = 'X'.
    ls_headdata-mrp_view = 'X'.
    ls_headdata-storage_view = 'X'.
    ls_headdata-warehouse_view = 'X'.
    ls_headdata-account_view = 'X'.
    ls_headdata-quality_view = 'X'.
  ENDIF.

  IF p_g_tc_81_wa_werks = '90R1'.
    ls_headdata-sales_view = ' '.
    ls_headdata-warehouse_view = ' '.
  ENDIF.
  APPEND ls_headdata TO lt_headdata.
ENDFORM.                    " VIEW_TO_EXTEND
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_MECS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_mecs .
  SORT lt_zmm_mecs BY docno matnr.
*  DELETE ADJACENT DUPLICATES FROM LT_ZMM_MECS COMPARING DOCNO MATNR.
  DELETE lt_zmm_mecs WHERE bwtar = ' '.
  IF lt_zmm_mecs[] IS NOT INITIAL.
    MODIFY zmm_mecs FROM TABLE lt_zmm_mecs.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_MECS
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_MEMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_mems .
  DATA: lt_mecs TYPE STANDARD TABLE OF zmm_mecs.
  FIELD-SYMBOLS    <wa_mecs> TYPE zmm_mecs.
  DATA: flag(1) TYPE c.
  SELECT SINGLE * FROM zmm_mems INTO ls_zmm_mems
                 WHERE docno = number.
  IF sy-subrc EQ 0.
    SELECT * FROM zmm_mecs INTO TABLE lt_mecs WHERE docno = number.
    IF sy-subrc EQ 0.
      LOOP AT lt_mecs ASSIGNING <wa_mecs>.
        IF <wa_mecs>-sflag = 'N'.
          flag = 'X'.
        ENDIF.
      ENDLOOP.
      IF flag EQ 'X'.
        MOVE 'N' TO ls_zmm_mems-sflag.
      ELSE.
        MOVE 'C' TO ls_zmm_mems-sflag.
      ENDIF.

      MODIFY zmm_mems FROM ls_zmm_mems.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_MEMS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_MESG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_mesg .
  PERFORM field_catalog.
  PERFORM show_list.

*  LEAVE TO LIST-PROCESSING.
*  LOOP AT IST_MSG INTO WA_MSG.
*    WRITE:/ WA_MSG.
*  ENDLOOP.

ENDFORM.                    " DISPLAY_MESG
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_catalog .
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-fieldname = 'DOCNO'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-001.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-002.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 13.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-003.
  wa_fieldcat-key       = 'X'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-fieldname = 'MSGTYP'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-004.
  wa_fieldcat-outputlen = 4.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-fieldname = 'BWTAR'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-005.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-fieldname = 'MSGV1'.
  wa_fieldcat-tabname = 'IST_MSG'.
  wa_fieldcat-seltext_m = TEXT-006.
  wa_fieldcat-outputlen = 75.
  APPEND wa_fieldcat TO id_fieldcat.
  CLEAR wa_fieldcat.
ENDFORM.                    " FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  SHOW_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_list .
  DATA ltmecs TYPE STANDARD TABLE OF zmm_mecs.
  FIELD-SYMBOLS <ltmecs> TYPE zmm_mecs.
  v_repid = sy-repid.

  DATA: ltmsg TYPE STANDARD TABLE OF t_msg,
        wamsg TYPE t_msg.
*  LOOP AT G_TC_81_ITAB INTO G_TC_81_WA.
*    READ TABLE IST_MSG INTO WA_MSG WITH KEY DOCNO = NUMBER
*                                            MATNR = G_TC_81_WA-MATNR.
*    IF SY-SUBRC EQ 0.
*     MOVE WA_MSG TO WAMSG.
*     APPEND WAMSG TO LTMSG.
*     ENDIF.
*     DELETE TABLE IST_MSG FROM WA_MSG.
*     CLEAR: WA_MSG, WAMSG.
*  ENDLOOP.
*
*  DELETE IST_MSG WHERE DOCNO NE ' '.
*  LOOP AT IST_MSG INTO WA_MSG.
*    APPEND WA_MSG TO LTMSG.
*  ENDLOOP.
*  CLEAR IST_MSG[].

  IF ist_msg IS INITIAL.
    SELECT * FROM zmm_mecs INTO TABLE ltmecs
      FOR ALL ENTRIES IN g_tc_81_itab
           WHERE matnr = g_tc_81_itab-matnr
             AND werks = g_tc_81_itab-werks
             AND bwtar = g_tc_81_itab-bwtar.
    LOOP AT ltmecs ASSIGNING <ltmecs>.
      MOVE <ltmecs>-docno TO wa_msg-docno.
      MOVE <ltmecs>-matnr TO wa_msg-matnr.
      MOVE <ltmecs>-werks TO wa_msg-werks.
      MOVE <ltmecs>-bwtar TO wa_msg-bwtar.
      MOVE <ltmecs>-remrk TO wa_msg-msgv1.
      APPEND wa_msg TO ist_msg.
      CLEAR wa_msg.
    ENDLOOP.
  ENDIF.
  LEAVE TO LIST-PROCESSING.

  DELETE ist_msg WHERE matnr = ' '.
  LOOP AT ltmsg INTO wamsg.
    APPEND wamsg TO ist_msg.
  ENDLOOP.

  SORT ist_msg BY matnr.
*  DELETE ADJACENT DUPLICATES FROM IST_MSG COMPARING MATNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = v_repid
      i_grid_title       = TEXT-007
      it_fieldcat        = id_fieldcat
    TABLES
      t_outtab           = ist_msg.

  CLEAR id_fieldcat[].
  CLEAR ist_msg[].
ENDFORM.                    " SHOW_LIST
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agrname .
  INSERT agr_users FROM w_agr_users.
ENDFORM.                    " UPDATE_AGRNAME
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_agr .
  DELETE agr_users FROM w_agr_users.
ENDFORM.                    " UPDATE_AGR
