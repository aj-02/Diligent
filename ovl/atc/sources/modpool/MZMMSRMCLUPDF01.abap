*--- MAIN PROGRAM: MZMMSRMCLUPDF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDF01                                            *
*----------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Replaced obsolte FM
*                                           'UPLOAD'
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  GET_USR_DATE
*&---------------------------------------------------------------------*
*       Show User name and PassWord
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_usr_date.
  if ok_code_90 = 'CREA'.
    move sy-uname to g_uname .
    write sy-datum to g_sydate dd/mm/yyyy.
  endif.
endform.                    " GET_USR_DATE
*&---------------------------------------------------------------------*
*&      Form  check_table_initial
*&---------------------------------------------------------------------*
*       Check whether the table ist_tc100 is initial or not
* If initial then add slno .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_table_initial.


endform.                    " check_table_initial

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

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

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

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
  get cursor line l_selline.
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
  insert initial line into <table> index l_selline.
  <tc>-lines = <tc>-lines + 1.
* set cursor
  set cursor line l_line.

endform.                              " FCODE_INSERT_ROW

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
        <tc>-lines = <tc>-lines - 1.
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


* is no line filled?                                                   *
  if <tc>-lines = 0.
*   yes, ...                                                           *
    l_tc_new_top_line = 1.
  else.
*   no, ...                                                            *
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
*&      Form  create_icon
*&---------------------------------------------------------------------*
*       Create Icon
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_icon.

*  CALL FUNCTION 'ICON_CREATE'
*    EXPORTING
*      name                        = 'ICON_LED_RED'
**   TEXT                        = ' '
**   INFO                        = ' '
**   ADD_STDINF                  = 'X'
*   IMPORTING
*     result                      = icon
** EXCEPTIONS
**   ICON_NOT_FOUND              = 1
**   OUTPUTFIELD_TOO_SHORT       = 2
**   OTHERS                      = 3
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


endform.                    " create_icon
*&---------------------------------------------------------------------*
*&      Form  get_maktx
*&---------------------------------------------------------------------*
*      Get Material Description
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_maktx.

  loop at ist_tc100 into wa_100.
    if not wa_100-matnr is initial.
      select single maktx from makt into wa_100-maktx where
        matnr = wa_100-matnr and
        spras = 'EN'.
      modify ist_tc100 from wa_100 index sy-tabix.
    endif.

  endloop.

endform.                    " get_maktx
*&---------------------------------------------------------------------*
*&      Form  append_lines
*&---------------------------------------------------------------------*
*      Append Lines to internal Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form append_lines.
  data: l_lines type n .
  data: l_do type n.
  describe table ist_tc100 lines l_lines.
  l_do = 1000 - l_lines.

  do l_do times.
    move space to wa_100. "#EC CI_FLDEXT_OK[2215424]
    append wa_100 to ist_tc100.
  enddo.
endform.                    " append_lines
*&---------------------------------------------------------------------*
*&      Form  get_request_no
*&---------------------------------------------------------------------*
*       Get Request number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_request_no.

  call function 'NUMBER_GET_NEXT'
    exporting
      nr_range_nr                   = '01'
      object                        = 'ZMM_SRMUPD'
      quantity                      = '1'
    importing
     number                        = g_reqno.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


endform.                    " get_request_no
*&---------------------------------------------------------------------*
*&      Form  check_srm_class
*&---------------------------------------------------------------------*
*       Check SRM Class
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_srm_class.
  data: l_atwrt like ausp-atwrt.
  data: l_err(70) .
  data: l_objek like ausp-objek,
        l_atinn like ausp-atinn.
  clear: l_atwrt,
         l_err .

  if ok_code_90 = 'CREA'.
    l_objek = wa_tc100-matnr .
    call function 'CONVERSION_EXIT_ATINN_INPUT'
         exporting
              input  = 'MAT_TYPE'
         importing
              output = l_atinn.

    SELECT ATWRT FROM AUSP INTO L_ATWRT UP TO 1 ROWS
 WHERE OBJEK = L_OBJEK AND ATINN = L_ATINN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if l_atwrt = 'A' or
       l_atwrt = 'B' or
       l_atwrt = 'C'.

** Modify Internal Table
      wa_tc100-dclass = l_atwrt.
      modify ist_tc100 from wa_tc100 transporting dclass where
                          matnr = wa_tc100-matnr .
DATA lv_err TYPE string.

lv_err = |{ text-001 } - "{ l_atwrt }" - Assigned to this Material|.
l_err  = lv_err.
*     concatenate text-001 '-"' l_atwrt '"-' 'Assigned to this Material'
*                        into l_err.
      wa_tc100-errtext = l_err.

      call function 'ICON_CREATE'
        exporting
          name                        = 'ICON_LED_YELLOW'
*   TEXT                        = ' '
*   INFO                        = ' '
*   ADD_STDINF                  = 'X'
       importing
         result                      = icon  .
* EXCEPTIONS
*   ICON_NOT_FOUND              = 1
*   OUTPUTFIELD_TOO_SHORT       = 2
*   OTHERS                      = 3

    else.
      wa_tc100-errtext = space .
    endif.
  endif.
endform.                    " check_srm_class
*&---------------------------------------------------------------------*
*&      Form  vlidate_srm_class
*&---------------------------------------------------------------------*
*       Validate SRM Class
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form vlidate_srm_class.
  data: l_atwrt like ausp-atwrt.
  data: l_err(70) .
  data: l_objek like ausp-objek,
        l_atinn like ausp-atinn.
  clear: l_atwrt,
         l_err .
  if ok_code_90 = 'CREA'.
    if not  wa_tc100-srmclass is initial.
      if not ( wa_tc100-srmclass = 'A' or
               wa_tc100-srmclass = 'B' or
               wa_tc100-srmclass = 'C' ) .
        message e216(zmm).

      else.

        l_objek = wa_tc100-matnr .
        call function 'CONVERSION_EXIT_ATINN_INPUT'
             exporting
                  input  = 'MAT_TYPE'
             importing
                  output = l_atinn.

        SELECT ATWRT FROM AUSP INTO L_ATWRT UP TO 1 ROWS
 WHERE OBJEK = L_OBJEK AND ATINN = L_ATINN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if l_atwrt = 'A' or
           l_atwrt = 'B' or
           l_atwrt = 'C'.

          if l_atwrt = wa_tc100-srmclass.
            CONDENSE l_atwrt.
            message e220(zmm) with l_atwrt. "#EC CI_FLDEXT_OK[2215424]
          endif.
        endif.
      endif.
*    elseif  wa_tc100-srmclass is initial and
*           not wa_tc100-matnr is initial.
*      set cursor field 'WA_TC100-SRMCLASS'.
*      message e219(zmm).
    endif.
  endif.
endform.                    " vlidate_srm_class
*&---------------------------------------------------------------------*
*&      Form  GET_IMPORT_FILE
*&---------------------------------------------------------------------*
*       Get Import File
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_import_file.
  data: l_fname like rlgrap-filename  .
* begin of <RD1K960036>
* Replaced obsolete FM 'UPLOAD'
  DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
         L_FILETABLE  TYPE  FILE_TABLE,
         l_RC         TYPE  I,
         l_P_DEF_FILE TYPE  STRING,
         l_P_FILE     TYPE  STRING,
         l_usr_act    TYPE  I.

*  call function 'UPLOAD'
*   exporting
**   CODEPAGE                      = ' '
*     filename                      = l_fname
*     filetype                      = 'DAT'
**   ITEM                          = ' '
**   FILEMASK_MASK                 = ' '
**   FILEMASK_TEXT                 = ' '
**   FILETYPE_NO_CHANGE            = ' '
**   FILEMASK_ALL                  = ' '
**   FILETYPE_NO_SHOW              = ' '
**   LINE_EXIT                     = ' '
**   USER_FORM                     = ' '
**   USER_PROG                     = ' '
**   SILENT                        = 'S'
** IMPORTING
**   FILESIZE                      =
**   CANCEL                        =
**   ACT_FILENAME                  =
**   ACT_FILETYPE                  =
*    tables
*      data_tab                      = ist_data
** EXCEPTIONS
**   CONVERSION_ERROR              = 1
**   INVALID_TABLE_WIDTH           = 2
**   INVALID_TYPE                  = 3
**   NO_BATCH                      = 4
**   UNKNOWN_ERROR                 = 5
**   GUI_REFUSE_FILETRANSFER       = 6
**   OTHERS                        = 7
*            .
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
  l_P_DEF_FILE = l_fname.

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
          FILE_TABLE              = I_FILE_TABLE
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


     LOOP AT I_FILE_TABLE  INTO l_FILETABLE.
        l_P_FILE = l_FILETABLE.
        EXIT.
      ENDLOOP.


  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = l_P_FILE
      FILETYPE                      = 'ASC'
      HAS_FIELD_SEPARATOR           = 'X'
    TABLES
      DATA_TAB                      = ist_data "#EC CI_FLDEXT_OK[2215424]
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
endform.                    " GET_IMPORT_FILE
*&---------------------------------------------------------------------*
*&      Form  load_data_in_tc
*&---------------------------------------------------------------------*
*      Load Uload data into table control.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form load_data_in_tc.
  if not ist_data[] is initial.
    refresh ist_tc100.
    refresh ist_tc100.

    loop at ist_data into wa_data.
      select single maktx from makt into wa_100-maktx
                 where matnr = wa_data-matnr and
                       spras = 'EN'.
      move-corresponding wa_data to wa_100.
      wa_100-slno = sy-tabix.
      append wa_100 to ist_tc100.
    endloop.
  endif.

endform.                    " load_data_in_tc
*&---------------------------------------------------------------------*
*&      Form  popup_confirm
*&---------------------------------------------------------------------*
*       Popup to Confirm before Save
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form popup_confirm.
  clear g_ans .

  call function 'POPUP_TO_CONFIRM'
       exporting
            titlebar      = text-002
            text_question = text-002
            text_button_1 = 'Yes'
            text_button_2 = 'No'
       importing
            answer        = g_ans.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " popup_confirm
*&---------------------------------------------------------------------*
*&      Form  alert_before_exit
*&---------------------------------------------------------------------*
*       Message before Exit
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form alert_before_exit.
  if not ist_tc100 is initial.
    clear g_ans .

    call function 'POPUP_TO_CONFIRM'
         exporting
              titlebar      = text-003
              text_question = text-003
              text_button_1 = 'Yes'
              text_button_2 = 'No'
         importing
              answer        = g_ans.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endif.

endform.                    " alert_before_exit
*&---------------------------------------------------------------------*
*&      Form  UPDATE_REQUEST
*&---------------------------------------------------------------------*
*      Update Request
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_request.
*  data: begin of wa_upd_tab       ,
*          mandt type mandt        ,
*          reqno(10)                ,
*          werks type t001w-werks  ,
*          matnr type  mara-matnr  ,
*          srmclass type zsrmclass ,
*          ersda    type ersda     ,
*          ernam    type ernam     ,
*          remrk(60)               ,
*         end of wa_upd_tab .
*  data: ist_upd_tab like    wa_upd_tab occurs 0 with header line.
*  refresh ist_upd_tab.
*  if not g_reqno is initial.
*    loop at ist_tc100 into wa_100.
*      move-corresponding wa_100 to wa_upd_tab .
*      wa_upd_tab-reqno = g_reqno   .
*      wa_upd_tab-mandt = sy-mandt  .
*      wa_upd_tab-ersda = sy-datum  .
*      wa_upd_tab-ernam = sy-uname  .
*      wa_upd_tab-remrk = g_remarks .
*      append wa_upd_tab to ist_upd_tab .
*    endloop.
*    modify  zmm_srm_mat_clas  from table ist_upd_tab .
*  endif.
endform.                    " UPDATE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  check_reqno
*&---------------------------------------------------------------------*
*       Vlidate request number
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_reqno.
  data: l_reqno like zmm_srm_mat_clas-reqno.
  if  not zmm_srm_mat_clas-reqno is initial.
    select single reqno from zmm_srm_mat_clas into l_reqno
      where reqno = zmm_srm_mat_clas-reqno.
    if sy-subrc ne 0.
      message e218(zmm).
    endif.
  elseif zmm_srm_mat_clas-reqno is initial and sy-ucomm = 'ENTER'.
    message e221(zmm).
  endif.
endform.                    " check_reqno
*&---------------------------------------------------------------------*
*&      Form  RUN_BDC_MM02
*&---------------------------------------------------------------------*
*    BDC -   Use Transaction MM02
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form run_bdc_mm02.

  delete  ist_tc100 where matnr = space.
  loop at ist_tc100 into wa_100.

    if wa_100-dclass ne space .
      perform run_bdc_mm02i using wa_100.

    else.
      perform bdc_dynpro      using 'SAPLMGMM' '0060'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMMG1-MATNR'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.
      perform bdc_field       using 'RMMG1-MATNR'
                                    "'140103185'.
                                    wa_100-matnr.
      perform bdc_dynpro      using 'SAPLMGMM' '0070'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MSICHTAUSW-DYTXT(03)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.
      perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                                    'X'.
      perform bdc_field       using 'MSICHTAUSW-KZSEL(03)'
                                    'X'.
      perform bdc_dynpro      using 'SAPLMGMM' '4004'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ZU01'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MAKT-MAKTX'.

      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
*      perform bdc_field       using 'MARA-MEINS'
*                                    'FT2'.
*      perform bdc_field       using 'MARA-MATKL'
*                                    '14'.
*      perform bdc_field       using 'MARA-PRDHA'
*                                    '14'.
*      perform bdc_field       using 'MARA-GEWEI'
*                                    'KG'.
      perform bdc_dynpro      using 'SAPLMGMM' '4300'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ZU07'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMMG1-MATNR'.
      perform bdc_dynpro      using 'SAPLMGMM' '4300'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=MAIN'.
      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
      perform bdc_dynpro      using 'SAPLMGMM' '4004'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=SP03'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'MAKT-MAKTX'.
      perform bdc_field       using 'MAKT-MAKTX'
                                    "'VENYL FLOORING CARPET'.
                                     wa_100-maktx.
*      perform bdc_field       using 'MARA-MEINS'
*                                    'FT2'.
*      perform bdc_field       using 'MARA-MATKL'
*                                    '14'.
*      perform bdc_field       using 'MARA-PRDHA'
*                                    '14'.
*      perform bdc_field       using 'MARA-GEWEI'
*                                    'KG'.
      perform bdc_dynpro      using 'SAPLCLCA' '0602'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-KLART'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTE'.
      perform bdc_field       using 'RMCLF-KLART'
                                    '001'.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=EINT'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(02)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
      perform bdc_field       using 'RMCLF-CLASS(02)'
                                    'ZSRM_CLASS'.
      perform bdc_dynpro      using 'SAPLCTMS' '0109'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RCTMS-MWERT(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BACK'.
      perform bdc_field       using 'RCTMS-MNAME(01)'
                                    'MAT_TYPE'.
      perform bdc_field       using 'RCTMS-MWERT(01)'
                                    " 'a'.
                                     wa_100-srmclass.
      perform bdc_dynpro      using 'SAPLCLFM' '0500'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RMCLF-CLASS(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=SAVE'.
      perform bdc_field       using 'RMCLF-PAGPOS'
                                    '1'.
*perform bdc_transaction using 'MM02'.
      call transaction 'MM02' using bdcdata mode 'E'
          messages into ist_msg.

      perform update_mat_class using wa_100.
      refresh bdcdata.
      clear bdcdata .
    endif.
  endloop.
endform.                    " RUN_BDC_MM02

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
  clear bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
endform.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
form bdc_transaction using l_tcode.

  call function 'BDC_INSERT'
       exporting
            tcode     = l_tcode
       tables
            dynprotab = bdcdata.

endform.                    " bdc_trans

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*

form bdc_field using l_fnam l_fval.
  clear bdcdata.
  bdcdata-fnam = l_fnam.
  bdcdata-fval = l_fval.
  append bdcdata.
endform.
*&---------------------------------------------------------------------*
*&      Form  run_bdc_mm02i
*&---------------------------------------------------------------------*
*       BDC MM02
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form run_bdc_mm02i using wa_100 like wa_tc100.

  perform bdc_dynpro      using 'SAPLMGMM' '0060'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMMG1-MATNR'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'RMMG1-MATNR'
                                "'060000025'.
                                 wa_100-matnr .
  perform bdc_dynpro      using 'SAPLMGMM' '0070'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MSICHTAUSW-DYTXT(03)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTR'.
  perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                                'X'.
  perform bdc_field       using 'MSICHTAUSW-KZSEL(03)'
                                'X'.
  perform bdc_dynpro      using 'SAPLMGMM' '4004'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=SP03'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MAKT-MAKTX'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                  wa_100-maktx.
*  perform bdc_field       using 'MARA-MEINS'
*                                'NO'.
*  perform bdc_field       using 'MARA-MATKL'
*                                '06'.
*  perform bdc_field       using 'MARA-PRDHA'
*                                '06'.
  perform bdc_dynpro      using 'SAPLCLCA' '0602'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-KLART'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ENTE'.
  perform bdc_field       using 'RMCLF-KLART'
                                '001'.
  perform bdc_dynpro      using 'SAPLCLFM' '0500'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-CLASS(02)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '/00'.
  perform bdc_field       using 'RMCLF-PAGPOS'
                                '1'.
  perform bdc_dynpro      using 'SAPLCTMS' '0109'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BACK'.
  perform bdc_field       using 'RCTMS-MNAME(01)'
                                'MAT_TYPE'.
  perform bdc_field       using 'RCTMS-MWERT(01)'
                                "'A'.
                                 wa_100-srmclass.
  perform bdc_dynpro      using 'SAPLCLFM' '0500'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=VOBI'.
  perform bdc_field       using 'RMCLF-PAGPOS'
                                '1'.
  perform bdc_dynpro      using 'SAPLMGMM' '4004'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ZU01'.
  perform bdc_field       using 'BDC_CURSOR'
                                'MAKT-MAKTX'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                 wa_100-maktx.
*  perform bdc_field       using 'MARA-MEINS'
*                                'NO'.
*  perform bdc_field       using 'MARA-MATKL'
*                                '06'.
*  perform bdc_field       using 'MARA-PRDHA'
*                                '06'.
  perform bdc_dynpro      using 'SAPLMGMM' '4300'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=ZU07'.
  perform bdc_field       using 'BDC_CURSOR'
                                'RMMG1-MATNR'.
  perform bdc_dynpro      using 'SAPLMGMM' '4300'.
  perform bdc_field       using 'BDC_OKCODE'
                                '=BU'.
  perform bdc_field       using 'MAKT-MAKTX'
*                              'BULL LINE 1 1/8"X163FT 321111111111111'
*                            & '1*'.
                                 wa_100-maktx.
*perform bdc_transaction using 'MM02'.
  call transaction 'MM02' using bdcdata mode 'E'
                    messages into ist_msg.
  perform update_mat_class using wa_100.
  refresh bdcdata.
  clear  bdcdata .

endform.                    " run_bdc_mm02i
*&---------------------------------------------------------------------*
*&      Form  clear_global
*&---------------------------------------------------------------------*
*       Clear  Global Variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_global.
  clear: ist_tc100,
         wa_100,
         wa_tc100.
  clear: g_werks ,
         g_remarks,
         g_reqno ,
         g_dup.
  clear: ok_code_90 ,
         ok_code    .

  clear : zmm_srm_mat_clas-reqno.
  refresh: ist_tc100 ,
           ist_disp.

endform.                    " clear_global
*&---------------------------------------------------------------------*
*&      Form  assign_srlno
*&---------------------------------------------------------------------*
*       Assign Serial no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form assign_srlno.
  if not wa_tc100-matnr is initial.
    wa_tc100-slno = tc100-current_line .
  endif.
endform.                    " assign_srlno
*&---------------------------------------------------------------------*
*&      Form  update_mat_class
*&---------------------------------------------------------------------*
*       Update table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form update_mat_class using wa_tc100 like wa_100.
  data: l_txt(50).
  data: wa_srm_tab like zmm_srm_mat_clas.
  data: l_tdname like thead-tdname.
  data: l_insert.
  loop at ist_msg  .
    if ist_msg-msgtyp = 'S' and ist_msg-msgnr = '801'.

      move-corresponding wa_100 to wa_srm_tab .

      wa_srm_tab-reqno = g_reqno .
      wa_srm_tab-ersda = sy-datum .
      wa_srm_tab-ernam = sy-uname .
      wa_srm_tab-remrk = g_remarks.
      modify zmm_srm_mat_clas from wa_srm_tab .
      if sy-subrc = 0.
*Update Internal Comments
        header-tdobject = 'MATERIAL'.
        header-tdid     = 'IVER'.
        header-tdname   =  wa_100-matnr .
        header-tdspras  = 'EN'.
        header-tdform   = 'SYSTEM'.
        header-mandt    = sy-mandt .
        refresh ist_lines .
        l_tdname  = wa_100-matnr .

* Read Text

        refresh ist_lines.

        select single * from stxh
                 where tdobject = 'MATERIAL' and
                       tdname   = l_tdname and
                       tdid     = 'IVER'.
        if sy-subrc = 0.
          call function 'READ_TEXT'
               exporting
                    client   = sy-mandt
                    id       = 'IVER'
                    language = 'E'
                    name     = l_tdname
                    object   = 'MATERIAL'
               tables
                    lines    = ist_lines.

        endif.
        concatenate g_uname '-' g_sydate into l_txt .
        wa_lines-tdformat = '*'.
        wa_lines-tdline  =  l_txt .
        append wa_lines to ist_lines .
        wa_lines-tdformat = '*'.
        wa_lines-tdline = g_remarks.
        append wa_lines to ist_lines .
        wa_lines-tdformat = '*'.
        clear l_txt.
        concatenate 'Request no-' g_reqno into l_txt.
        wa_lines-tdline = l_txt.
        append wa_lines to ist_lines .

        if ist_lines[] is initial.
          l_insert = 'X'.
        else.
          l_insert =  space.
        endif.

        call function 'SAVE_TEXT'
             exporting
                  client          = sy-mandt
                  header          = header
                  insert          = l_insert
                  savemode_direct = 'X'
             tables
                  lines           = ist_lines.

        move-corresponding wa_srm_tab to wa_disp.
        append wa_disp to ist_disp.
      endif.
      exit.
    endif.
  endloop.
  clear ist_msg .
  refresh ist_msg.
  clear wa_100.
endform.                    " update_mat_class
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*      Get Data from table ZMM_SRM_MAT_CLAS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_data.
  select * from zmm_srm_mat_clas into corresponding fields of table
    ist_mat_clas
      where reqno =  zmm_srm_mat_clas-reqno ORDER BY PRIMARY KEY.

  read table ist_mat_clas  into wa_mat_clas index 1.
  move wa_mat_clas-remrk to g_remarks   .
  move wa_mat_clas-reqno  to g_reqno    .
  refresh ist_tc100.
  move wa_mat_clas-ernam to g_uname .
  write wa_mat_clas-ersda to g_sydate dd/mm/yyyy.

  loop at ist_mat_clas into wa_mat_clas.
    move-corresponding wa_mat_clas to wa_tc100.
    append wa_tc100 to ist_tc100.

  endloop.
endform.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       Display Successful Documents.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_data.
  leave to list-processing and return to screen '90'.
  data: l_tabix(4).
  if not ist_disp[] is initial.
    write:/20 text-t01.

    write:/5 sy-vline no-gap, sy-uline(47) no-gap.

    write:/5 sy-vline,'Slno',10 sy-vline,
           11 'Material' ,25 sy-vline,
           26 'SRM Class' ,  40 sy-vline,
           41 'Reqest no', 52 sy-vline .

    write:/5 sy-uline(48).
    loop at ist_disp into wa_disp.

      l_tabix = sy-tabix .
      write:/5  sy-vline ,6 l_tabix  ,10 sy-vline,
             11  wa_disp-matnr   , 25 sy-vline,
             26 wa_disp-srmclass , 40 sy-vline,
             41 wa_disp-reqno ,    52 sy-vline .
      write:/5 sy-vline no-gap, sy-uline(47) no-gap.

    endloop.
    perform clear_global.
    leave to screen '90' .
  endif.
endform.                    " display_data
*&---------------------------------------------------------------------*
*&      Form  check_duplicate
*&---------------------------------------------------------------------*
*      Check Dulicate Material.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_duplicate.
  data: ist_tc100_cp like table of wa_tc100,
        wa_100_cp  like  wa_tc100.
  data: l_matnr type matnr .
  refresh ist_tc100_cp .
  data: l_indx type i.
  ist_tc100_cp[] = ist_tc100[].
  sort ist_tc100_cp by matnr .
  loop at ist_tc100_cp into wa_100_cp where matnr ne space.
    l_indx = l_indx + 1.
    if l_indx =  1.
      l_matnr = wa_100_cp-matnr .

    else.
      if l_matnr =   wa_100_cp-matnr .
        g_dup = 'X'.
        message i366(zmm).
        exit.
      else.
        l_matnr =  wa_100_cp-matnr .
        g_dup = space.
      endif.
    endif.
  endloop.

endform.                    " check_duplicate

*&---------------------------------------------------------------------*
*&      Form  SET_CURSOR_FIELD
*&---------------------------------------------------------------------*
*       SET CURSOR.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_cursor_field.
  data: ist_tmp like table of wa_tc100 ,
         wa_tmp like wa_tc100.
  data: l_line type i.
  field-symbols: <fs> type any .
  ist_tmp[] = ist_tc100[].

  clear l_line .
  loop at ist_tmp into wa_tmp.

    if wa_tmp-matnr ne  space.
      l_line = l_line + 1.
    endif.
  endloop.

  if not g_remarks is initial and ist_tc100[] is initial.
    l_line =  1.
    set cursor field 'WA_TC100-MATNR' line l_line .
  else.
    assign ('WA_TC100-MATNR') to <fs>.
    if <fs> ne space .
      set cursor field 'WA_TC100-SRMCLASS' line l_line .
    endif.
    if <fs> ne space and wa_tc100-srmclass ne space .
      l_line = l_line + 1.
      set cursor field 'WA_TC100-MATNR' line l_line .
    endif.
  endif.
endform.                    " SET_CURSOR_FIELD
