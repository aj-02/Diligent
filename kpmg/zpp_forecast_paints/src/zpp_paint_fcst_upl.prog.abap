*&---------------------------------------------------------------------*
*& Report  ZPP_PAINT_FCST_UPL
*&---------------------------------------------------------------------*
*& Title       : ZFORECAST Paints - Uploads
*& Transaction : ZPFCST_UPL
*& Package     : ZPP_PNT_FCST
*& Message cl. : ZPP_PFCST
*& Author      : Arnav
*& Created on  : 31.08.2026
*& Reference   : CR-2C Forecast Paints, Forecast Template-Paints.xlsx
*&---------------------------------------------------------------------*
*& Purpose
*&   One upload program for the whole ZFORECAST Paints solution. The user
*&   picks an upload type on the radio button group, picks a file, and
*&   the program either writes a blank template for that type or reads
*&   the filled in file and loads it.
*&
*&   Six upload types - the four WRICEF upload items plus the two tables
*&   the FS lists under "custom table maitainance":
*&
*&     1  Product category      ZPPT_PNT_PCAT
*&     2  Material tracking     ZPPT_PNT_MTRK
*&     3  Material exclusion    ZPPT_PNT_MEXC
*&     4  Legacy sales history  ZPPT_PNT_SHIST
*&     5  Sales forecast        ZPPT_PNT_FQT-BUS_FCST
*&     6  Forecast change       ZPPT_PNT_FQT-BUS_FCST_ADD and REASON
*&
*& How it works
*&   The file is read whole into a table of strings and every row is
*&   split at the tab character. Row 1 is the heading row and is skipped,
*&   but the row numbers quoted in the log are the row numbers IN THE
*&   FILE - heading counted - so a rejected row can be found in the
*&   spreadsheet without counting.
*&
*&   Nothing is validated with a database read inside the row loop. The
*&   rows are parsed first, the keys are collected, the master data is
*&   read once with guarded FOR ALL ENTRIES, and only then is each row
*&   judged. The accepted rows are written with a single MODIFY of the
*&   whole set under an ENQUEUE_E_TABLE lock on the target table.
*&
*&   Existing key -> the row is overwritten and stamped AENAM / AEDAT,
*&   the original ERNAM / ERDAT are carried forward. New key -> inserted
*&   and stamped ERNAM / ERDAT. That is the FS rule "IF THE PLANT AND
*&   MATERIAL IS EXIST IN THE TABLE, THEN OVERWRITE THE ENTRY OR ELSE
*&   NEW ENTRY".
*&
*&   Screen free by design - the result list is a full screen
*&   CL_SALV_TABLE. No CALL SCREEN, no MODULE, no SET PF-STATUS, no
*&   custom container, so the program stays abapGit shippable.
*&---------------------------------------------------------------------*
REPORT zpp_paint_fcst_upl MESSAGE-ID zpp_pfcst.

*&---------------------------------------------------------------------*
*& Types
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_key,
         werks TYPE werks_d,
         matnr TYPE matnr,
       END OF ty_key,

       BEGIN OF ty_hkey,
         werks TYPE werks_d,
         matnr TYPE matnr,
         gjahr TYPE gjahr,
       END OF ty_hkey,

       BEGIN OF ty_fkey,
         werks   TYPE werks_d,
         matnr   TYPE matnr,
         gjahr   TYPE gjahr,
         quarter TYPE zde_pnt_quarter,
       END OF ty_fkey,

       BEGIN OF ty_mara,
         matnr TYPE matnr,
         meins TYPE meins,
       END OF ty_mara,

*      Only the creation stamp of an existing row is needed, so that an
*      overwrite does not wipe who created the entry and when
       BEGIN OF ty_adm,
         werks TYPE werks_d,
         matnr TYPE matnr,
         ernam TYPE ernam,
         erdat TYPE erdat,
       END OF ty_adm,

       BEGIN OF ty_admh,
         werks TYPE werks_d,
         matnr TYPE matnr,
         gjahr TYPE gjahr,
         ernam TYPE ernam,
         erdat TYPE erdat,
       END OF ty_admh,

*      One parsed row. Only the columns of the selected upload type are
*      ever filled - a single shape keeps one validation path for all
*      six types instead of six near identical ones.
       BEGIN OF ty_row,
         row      TYPE i,
         werks    TYPE werks_d,
         matnr    TYPE matnr,
         old1     TYPE matnr,
         old2     TYPE matnr,
         prod_cat TYPE zde_pnt_prod_cat,
         load_fct TYPE zde_pnt_load_fct,
         mts_mto  TYPE zde_pnt_mts_mto,
         fyear    TYPE zde_pnt_fyear,
         gjahr    TYPE gjahr,
         quarter  TYPE zde_pnt_quarter,
         meins    TYPE meins,
         qty      TYPE zde_pnt_fcst_qty,
         reason   TYPE zde_pnt_reason,
         m01      TYPE zde_pnt_fcst_qty,
         m02      TYPE zde_pnt_fcst_qty,
         m03      TYPE zde_pnt_fcst_qty,
         m04      TYPE zde_pnt_fcst_qty,
         m05      TYPE zde_pnt_fcst_qty,
         m06      TYPE zde_pnt_fcst_qty,
         m07      TYPE zde_pnt_fcst_qty,
         m08      TYPE zde_pnt_fcst_qty,
         m09      TYPE zde_pnt_fcst_qty,
         m10      TYPE zde_pnt_fcst_qty,
         m11      TYPE zde_pnt_fcst_qty,
         m12      TYPE zde_pnt_fcst_qty,
       END OF ty_row,

       BEGIN OF ty_log,
         row     TYPE i,
         werks   TYPE werks_d,
         matnr   TYPE matnr,
         gjahr   TYPE gjahr,
         quarter TYPE zde_pnt_quarter,
         light   TYPE c LENGTH 1,
         status  TYPE c LENGTH 14,
         message TYPE c LENGTH 200,
       END OF ty_log.

*&---------------------------------------------------------------------*
*& Constants
*&---------------------------------------------------------------------*
CONSTANTS: gc_msgid  TYPE symsgid VALUE 'ZPP_PFCST',
           gc_red    TYPE c LENGTH 1 VALUE '1',
           gc_yellow TYPE c LENGTH 1 VALUE '2',
           gc_green  TYPE c LENGTH 1 VALUE '3',
           gc_ins    TYPE c LENGTH 14 VALUE 'Created',
           gc_upd    TYPE c LENGTH 14 VALUE 'Overwritten',
           gc_tst    TYPE c LENGTH 14 VALUE 'Test only',
           gc_rej    TYPE c LENGTH 14 VALUE 'Rejected'.

*&---------------------------------------------------------------------*
*& Global data
*&---------------------------------------------------------------------*
DATA: gt_file TYPE string_table,
      gt_row  TYPE STANDARD TABLE OF ty_row,
      gt_log  TYPE STANDARD TABLE OF ty_log,
      gt_key  TYPE STANDARD TABLE OF ty_key,
      gt_hkey TYPE STANDARD TABLE OF ty_hkey,
      gt_fkey TYPE STANDARD TABLE OF ty_fkey,
      gt_marc TYPE STANDARD TABLE OF ty_key,
      gt_mexc TYPE STANDARD TABLE OF ty_key,
      gt_mara TYPE STANDARD TABLE OF ty_mara,
      gt_adm  TYPE STANDARD TABLE OF ty_adm,
      gt_admh TYPE STANDARD TABLE OF ty_admh,
      gt_fqt  TYPE STANDARD TABLE OF zppt_pnt_fqt.

*&---------------------------------------------------------------------*
*& Write sets - sorted with a unique key so that two rows carrying the
*& same key in one file collapse to the last one instead of reaching
*& MODIFY twice
*&---------------------------------------------------------------------*
DATA: gt_wpcat  TYPE SORTED TABLE OF zppt_pnt_pcat
                     WITH UNIQUE KEY werks matnr,
      gt_wmtrk  TYPE SORTED TABLE OF zppt_pnt_mtrk
                     WITH UNIQUE KEY werks new_matnr,
      gt_wmexc  TYPE SORTED TABLE OF zppt_pnt_mexc
                     WITH UNIQUE KEY werks matnr,
      gt_wshist TYPE SORTED TABLE OF zppt_pnt_shist
                     WITH UNIQUE KEY werks matnr gjahr,
      gt_wfqt   TYPE SORTED TABLE OF zppt_pnt_fqt
                     WITH UNIQUE KEY werks matnr gjahr quarter.

DATA: g_type TYPE n LENGTH 1,
      g_tabn TYPE tabname,
      g_tab  TYPE c LENGTH 1,
      g_ok   TYPE i,
      g_bad  TYPE i.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_pcat  RADIOBUTTON GROUP typ DEFAULT 'X',
            p_mtrk  RADIOBUTTON GROUP typ,
            p_mexc  RADIOBUTTON GROUP typ,
            p_shist RADIOBUTTON GROUP typ,
            p_sfcst RADIOBUTTON GROUP typ,
            p_fchg  RADIOBUTTON GROUP typ.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_file  TYPE rlgrap-filename,
            p_templ AS CHECKBOX,
            p_test  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
INITIALIZATION.

  g_tab = cl_abap_char_utilities=>horizontal_tab.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM f4_file.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

* The file name is not OBLIGATORY on the screen, because the template
* download needs a target path and not an existing file. It is checked
* here instead, so both paths get the same clear message.
  IF p_file IS INITIAL.
    MESSAGE 'Enter a file name' TYPE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM init_run.

* Template only - write the heading row for the selected type and stop.
* The file is deliberately not read on this path.
  IF p_templ = abap_true.
    PERFORM download_template.
    RETURN.
  ENDIF.

  PERFORM read_file.
  PERFORM parse_file.
  PERFORM read_master.
  PERFORM validate_rows.
  PERFORM write_data.
  PERFORM display_log.
  PERFORM final_message.


*&---------------------------------------------------------------------*
*& INIT_RUN - translate the radio button into a type number and the
*&            name of the table that is going to be locked and written
*&---------------------------------------------------------------------*
FORM init_run.

  CLEAR: gt_file, gt_row, gt_log, gt_key, gt_hkey, gt_fkey,
         gt_marc, gt_mexc, gt_mara, gt_adm, gt_admh, gt_fqt,
         gt_wpcat, gt_wmtrk, gt_wmexc, gt_wshist, gt_wfqt,
         g_ok, g_bad.

  CASE abap_true.
    WHEN p_pcat.
      g_type = 1.
      g_tabn = 'ZPPT_PNT_PCAT'.
    WHEN p_mtrk.
      g_type = 2.
      g_tabn = 'ZPPT_PNT_MTRK'.
    WHEN p_mexc.
      g_type = 3.
      g_tabn = 'ZPPT_PNT_MEXC'.
    WHEN p_shist.
      g_type = 4.
      g_tabn = 'ZPPT_PNT_SHIST'.
    WHEN p_sfcst.
      g_type = 5.
      g_tabn = 'ZPPT_PNT_FQT'.
    WHEN p_fchg.
      g_type = 6.
      g_tabn = 'ZPPT_PNT_FQT'.
  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*& F4_FILE - file open dialogue on the presentation server
*&---------------------------------------------------------------------*
FORM f4_file.

  DATA: lt_files TYPE filetable,
        ls_file  TYPE file_table,
        lv_rc    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING  multiselection = abap_false
    CHANGING   file_table     = lt_files
               rc             = lv_rc
    EXCEPTIONS OTHERS         = 1 ).

  IF sy-subrc <> 0 OR lv_rc < 1.
    RETURN.
  ENDIF.

  READ TABLE lt_files INTO ls_file INDEX 1.
  IF sy-subrc = 0.
    p_file = ls_file-filename.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& TEMPLATE_HEAD - the column headings of the selected upload type.
*&                 One definition, used by the download and documented
*&                 for the functional team.
*&---------------------------------------------------------------------*
FORM template_head CHANGING ct_head TYPE string_table.

  CLEAR ct_head.

  CASE g_type.

    WHEN 1.
      ct_head = VALUE #( ( 'Plant' ) ( 'Material' ) ( 'Category' )
                         ( 'Load Factor' ) ( 'MTS or MTO' ) ).

    WHEN 2.
      ct_head = VALUE #( ( 'Plant' ) ( 'New Material' )
                         ( 'Old Material 1' ) ( 'Old Material 2' ) ).

    WHEN 3.
      ct_head = VALUE #( ( 'Plant' ) ( 'Material' ) ).

    WHEN 4.
*     M01 is April - the financial year of this solution starts in April
      ct_head = VALUE #( ( 'Plant' ) ( 'Material' ) ( 'Financial Year' )
                         ( 'Unit' )
                         ( 'April' ) ( 'May' ) ( 'June' )
                         ( 'July' ) ( 'August' ) ( 'September' )
                         ( 'October' ) ( 'November' ) ( 'December' )
                         ( 'January' ) ( 'February' ) ( 'March' ) ).

    WHEN 5.
      ct_head = VALUE #( ( 'Plant' ) ( 'Material' ) ( 'Quarter' )
                         ( 'Financial Year' ) ( 'Sales Forecast Qty' ) ).

    WHEN 6.
      ct_head = VALUE #( ( 'Plant' ) ( 'Material' ) ( 'Quarter' )
                         ( 'Financial Year' ) ( 'Qty' ) ( 'Reason' ) ).

  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*& DOWNLOAD_TEMPLATE - tab delimited text, heading row only
*&---------------------------------------------------------------------*
FORM download_template.

  DATA: lt_head TYPE string_table,
        lt_out  TYPE string_table,
        lv_line TYPE string,
        lv_name TYPE string,
        lv_msg  TYPE string.

  PERFORM template_head CHANGING lt_head.

  IF lt_head IS INITIAL.
    MESSAGE 'No template is defined for the selected upload type' TYPE 'E'.
  ENDIF.

  PERFORM join_row USING lt_head CHANGING lv_line.
  APPEND lv_line TO lt_out.

  lv_name = p_file.

  cl_gui_frontend_services=>gui_download(
    EXPORTING  filename         = lv_name
               filetype         = 'ASC'
               write_field_separator = space
    CHANGING   data_tab         = lt_out
    EXCEPTIONS file_write_error = 1
               not_supported_by_gui = 2
               OTHERS           = 3 ).

  IF sy-subrc <> 0.
    MESSAGE e013 WITH lv_name.
  ENDIF.

  CONCATENATE 'Template written to' lv_name INTO lv_msg SEPARATED BY space.
  MESSAGE lv_msg TYPE 'S'.

ENDFORM.


*&---------------------------------------------------------------------*
*& JOIN_ROW - one output line, cells separated by the tab character
*&---------------------------------------------------------------------*
FORM join_row USING pt_val TYPE string_table
           CHANGING cv_line TYPE string.

  DATA lv_val TYPE string.

  CLEAR cv_line.

  LOOP AT pt_val INTO lv_val.
    IF sy-tabix = 1.
      cv_line = lv_val.
    ELSE.
      CONCATENATE cv_line g_tab lv_val INTO cv_line.
    ENDIF.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& READ_FILE - the whole file into a table of strings
*&---------------------------------------------------------------------*
FORM read_file.

  DATA lv_name TYPE string.

  lv_name = p_file.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING  filename            = lv_name
               filetype            = 'ASC'
    CHANGING   data_tab            = gt_file
    EXCEPTIONS file_open_error     = 1
               file_read_error     = 2
               no_authority        = 3
               OTHERS              = 4 ).

  IF sy-subrc <> 0.
    MESSAGE e013 WITH lv_name.
  ENDIF.

* Row 1 is the heading row, so a file with fewer than two rows carries
* no data at all
  IF lines( gt_file ) < 2.
    MESSAGE e014.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& CELL - one cell of a split row, blank when the row is short
*&---------------------------------------------------------------------*
FORM cell USING pt_cell TYPE string_table
                pv_ix   TYPE i
       CHANGING cv_val  TYPE string.

  CLEAR cv_val.

  READ TABLE pt_cell INTO cv_val INDEX pv_ix.
  IF sy-subrc <> 0.
    CLEAR cv_val.
    RETURN.
  ENDIF.

  CONDENSE cv_val.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_FILE - split every data row and turn the cells into typed
*&              fields. Everything that can be judged from the cell
*&              alone is judged here; anything needing the database
*&              waits for VALIDATE_ROWS.
*&---------------------------------------------------------------------*
FORM parse_file.

  DATA: lt_cell TYPE string_table,
        lv_line TYPE string.

  LOOP AT gt_file INTO lv_line FROM 2.

    DATA(lv_row) = sy-tabix.

    CLEAR lt_cell.
    SPLIT lv_line AT g_tab INTO TABLE lt_cell.

*   A spreadsheet export usually ends with a run of empty lines. They
*   are not data and are not reported as errors.
    IF lv_line IS INITIAL.
      CONTINUE.
    ENDIF.

    CASE g_type.
      WHEN 1. PERFORM parse_pcat  USING lt_cell lv_row.
      WHEN 2. PERFORM parse_mtrk  USING lt_cell lv_row.
      WHEN 3. PERFORM parse_mexc  USING lt_cell lv_row.
      WHEN 4. PERFORM parse_shist USING lt_cell lv_row.
      WHEN 5. PERFORM parse_fqt   USING lt_cell lv_row.
      WHEN 6. PERFORM parse_fqt   USING lt_cell lv_row.
    ENDCASE.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_KEY - plant and material, common to every upload type
*&---------------------------------------------------------------------*
FORM parse_key USING pt_cell TYPE string_table
            CHANGING cs_row  TYPE ty_row
                     cv_ok   TYPE abap_bool.

  DATA: lv_c    TYPE string,
        lv_rowc TYPE c LENGTH 10.

  cv_ok   = abap_true.
  lv_rowc = cs_row-row.
  CONDENSE lv_rowc.

  PERFORM cell USING pt_cell 1 CHANGING lv_c.
  PERFORM to_plant USING lv_c CHANGING cs_row-werks.
  IF cs_row-werks IS INITIAL.
    PERFORM reject USING cs_row '015' lv_rowc space space.
    cv_ok = abap_false.
    RETURN.
  ENDIF.

  PERFORM cell USING pt_cell 2 CHANGING lv_c.
  PERFORM to_matnr USING lv_c CHANGING cs_row-matnr.
  IF cs_row-matnr IS INITIAL.
    PERFORM reject USING cs_row '016' lv_rowc space space.
    cv_ok = abap_false.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_PCAT - 1  Plant | Material | Category | Load Factor | MTS/MTO
*&---------------------------------------------------------------------*
FORM parse_pcat USING pt_cell TYPE string_table
                      pv_row  TYPE i.

  DATA: ls_row  TYPE ty_row,
        lv_c    TYPE string,
        lv_ok   TYPE abap_bool,
        lv_txt  TYPE string,
        lv_rowc TYPE c LENGTH 10.

  ls_row-row = pv_row.
  lv_rowc    = pv_row.
  CONDENSE lv_rowc.

  PERFORM parse_key USING pt_cell CHANGING ls_row lv_ok.
  CHECK lv_ok = abap_true.

* Category is a short field. A value that does not fit is an error -
* a silently truncated category would quietly select the wrong growth
* factor for the rest of the financial year.
  PERFORM cell USING pt_cell 3 CHANGING lv_c.
  PERFORM fits USING lv_c ls_row-prod_cat CHANGING lv_ok.
  IF lv_ok = abap_false.
    CONCATENATE 'Row' lv_rowc '- category' lv_c
                'is longer than the field allows'
           INTO lv_txt SEPARATED BY space.
    PERFORM reject_txt USING ls_row lv_txt.
    RETURN.
  ENDIF.
  ls_row-prod_cat = lv_c.

  PERFORM cell USING pt_cell 4 CHANGING lv_c.
  IF lv_c IS NOT INITIAL.
    PERFORM to_dec USING lv_c CHANGING ls_row-load_fct lv_ok.
    IF lv_ok = abap_false.
      PERFORM reject USING ls_row '017' lv_rowc 'Load Factor' space.
      RETURN.
    ENDIF.
  ENDIF.

  PERFORM cell USING pt_cell 5 CHANGING lv_c.
  TRANSLATE lv_c TO UPPER CASE.
  PERFORM fits USING lv_c ls_row-mts_mto CHANGING lv_ok.
  IF lv_ok = abap_false.
    CONCATENATE 'Row' lv_rowc '- MTS/MTO value' lv_c
                'is longer than the field allows'
           INTO lv_txt SEPARATED BY space.
    PERFORM reject_txt USING ls_row lv_txt.
    RETURN.
  ENDIF.
  ls_row-mts_mto = lv_c.

  APPEND ls_row TO gt_row.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_MTRK - 2  Plant | New Material | Old Material 1 | Old Mat. 2
*&---------------------------------------------------------------------*
FORM parse_mtrk USING pt_cell TYPE string_table
                      pv_row  TYPE i.

  DATA: ls_row TYPE ty_row,
        lv_c   TYPE string,
        lv_ok  TYPE abap_bool.

  ls_row-row = pv_row.

  PERFORM parse_key USING pt_cell CHANGING ls_row lv_ok.
  CHECK lv_ok = abap_true.

* ASSUMPTION: the two old material codes are NOT checked against MARC.
* They are the codes a material was replaced from, so they are exactly
* the ones likely to have been de-extended or flagged for deletion, and
* the engine only ever reads MATDOC history for them.
  PERFORM cell USING pt_cell 3 CHANGING lv_c.
  PERFORM to_matnr USING lv_c CHANGING ls_row-old1.

  PERFORM cell USING pt_cell 4 CHANGING lv_c.
  PERFORM to_matnr USING lv_c CHANGING ls_row-old2.

  APPEND ls_row TO gt_row.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_MEXC - 3  Plant | Material
*&---------------------------------------------------------------------*
FORM parse_mexc USING pt_cell TYPE string_table
                      pv_row  TYPE i.

  DATA: ls_row TYPE ty_row,
        lv_ok  TYPE abap_bool.

  ls_row-row = pv_row.

  PERFORM parse_key USING pt_cell CHANGING ls_row lv_ok.
  CHECK lv_ok = abap_true.

  APPEND ls_row TO gt_row.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_SHIST - 4  Plant | Material | Financial Year | Unit | M01..M12
*&                  M01 is April
*&---------------------------------------------------------------------*
FORM parse_shist USING pt_cell TYPE string_table
                       pv_row  TYPE i.

  DATA: ls_row  TYPE ty_row,
        lt_mon  TYPE string_table,
        lv_c    TYPE string,
        lv_ok   TYPE abap_bool,
        lv_bad  TYPE abap_bool,
        lv_mon  TYPE string,
        lv_comp TYPE string,
        lv_ix   TYPE i,
        lv_i    TYPE i,
        lv_rowc TYPE c LENGTH 10.

  FIELD-SYMBOLS <lv_qty> TYPE any.

  ls_row-row = pv_row.
  lv_rowc    = pv_row.
  CONDENSE lv_rowc.

  PERFORM parse_key USING pt_cell CHANGING ls_row lv_ok.
  CHECK lv_ok = abap_true.

  PERFORM cell USING pt_cell 3 CHANGING lv_c.
  PERFORM to_fyear USING lv_c CHANGING ls_row-fyear ls_row-gjahr lv_ok.
  IF lv_ok = abap_false.
    PERFORM reject USING ls_row '019' lv_rowc lv_c space.
    RETURN.
  ENDIF.

  PERFORM cell USING pt_cell 4 CHANGING lv_c.
  TRANSLATE lv_c TO UPPER CASE.
  ls_row-meins = lv_c.

  lt_mon = VALUE #( ( 'April' ) ( 'May' ) ( 'June' )
                    ( 'July' ) ( 'August' ) ( 'September' )
                    ( 'October' ) ( 'November' ) ( 'December' )
                    ( 'January' ) ( 'February' ) ( 'March' ) ).

  CLEAR lv_bad.

  DO 12 TIMES.

    lv_i  = sy-index.
    lv_ix = lv_i + 4.

    PERFORM cell USING pt_cell lv_ix CHANGING lv_c.

*   A blank month cell means no sale in that month, which is zero and
*   not an error
    IF lv_c IS INITIAL.
      CONTINUE.
    ENDIF.

    lv_comp = |M{ lv_i WIDTH = 2 PAD = '0' }|.
    ASSIGN COMPONENT lv_comp OF STRUCTURE ls_row TO <lv_qty>.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    PERFORM to_dec USING lv_c CHANGING <lv_qty> lv_ok.
    IF lv_ok = abap_false.
      CLEAR lv_mon.
      READ TABLE lt_mon INTO lv_mon INDEX lv_i.
      PERFORM reject USING ls_row '017' lv_rowc lv_mon space.
      lv_bad = abap_true.
      EXIT.
    ENDIF.

  ENDDO.

  IF lv_bad = abap_true.
    RETURN.
  ENDIF.

  APPEND ls_row TO gt_row.

ENDFORM.


*&---------------------------------------------------------------------*
*& PARSE_FQT - 5  Plant | Material | Quarter | Financial Year | Qty
*&             6  Plant | Material | Quarter | Financial Year | Qty |
*&                Reason
*&---------------------------------------------------------------------*
FORM parse_fqt USING pt_cell TYPE string_table
                     pv_row  TYPE i.

  DATA: ls_row  TYPE ty_row,
        lv_c    TYPE string,
        lv_ok   TYPE abap_bool,
        lv_txt  TYPE string,
        lv_int  TYPE i,
        lv_rowc TYPE c LENGTH 10,
        lv_qtrc TYPE c LENGTH 10.

  ls_row-row = pv_row.
  lv_rowc    = pv_row.
  CONDENSE lv_rowc.

  PERFORM parse_key USING pt_cell CHANGING ls_row lv_ok.
  CHECK lv_ok = abap_true.

  PERFORM cell USING pt_cell 3 CHANGING lv_c.
  PERFORM to_int USING lv_c CHANGING lv_int lv_ok.
  IF lv_ok = abap_false OR lv_int < 1 OR lv_int > 4.
    lv_qtrc = lv_c.
    CONDENSE lv_qtrc.
    PERFORM reject USING ls_row '018' lv_rowc lv_qtrc space.
    RETURN.
  ENDIF.
  ls_row-quarter = lv_int.

  PERFORM cell USING pt_cell 4 CHANGING lv_c.
  PERFORM to_fyear USING lv_c CHANGING ls_row-fyear ls_row-gjahr lv_ok.
  IF lv_ok = abap_false.
    PERFORM reject USING ls_row '019' lv_rowc lv_c space.
    RETURN.
  ENDIF.

* Quantity is mandatory on both types, so a blank cell fails the number
* check rather than defaulting to zero
  PERFORM cell USING pt_cell 5 CHANGING lv_c.
  PERFORM to_dec USING lv_c CHANGING ls_row-qty lv_ok.
  IF lv_ok = abap_false.
    IF g_type = 5.
      PERFORM reject USING ls_row '017' lv_rowc 'Sales Forecast Qty' space.
    ELSE.
      PERFORM reject USING ls_row '017' lv_rowc 'Qty' space.
    ENDIF.
    RETURN.
  ENDIF.

  IF g_type = 6.

    PERFORM cell USING pt_cell 6 CHANGING lv_c.
    IF lv_c IS INITIAL.
      PERFORM reject USING ls_row '024' lv_rowc space space.
      RETURN.
    ENDIF.

    PERFORM fits USING lv_c ls_row-reason CHANGING lv_ok.
    IF lv_ok = abap_false.
      CONCATENATE 'Row' lv_rowc '- the reason text is longer than'
                  'the field allows'
             INTO lv_txt SEPARATED BY space.
      PERFORM reject_txt USING ls_row lv_txt.
      RETURN.
    ENDIF.
    ls_row-reason = lv_c.

  ENDIF.

  APPEND ls_row TO gt_row.

ENDFORM.


*&---------------------------------------------------------------------*
*& READ_MASTER - every database read of the run happens here, once, on
*&               the collected keys. Nothing below this form selects.
*&---------------------------------------------------------------------*
FORM read_master.

  DATA: ls_row  TYPE ty_row,
        ls_key  TYPE ty_key,
        ls_hkey TYPE ty_hkey,
        ls_fkey TYPE ty_fkey.

  CHECK gt_row IS NOT INITIAL.

  LOOP AT gt_row INTO ls_row.

    CLEAR ls_key.
    ls_key-werks = ls_row-werks.
    ls_key-matnr = ls_row-matnr.
    APPEND ls_key TO gt_key.

    IF g_type = 4.
      CLEAR ls_hkey.
      ls_hkey-werks = ls_row-werks.
      ls_hkey-matnr = ls_row-matnr.
      ls_hkey-gjahr = ls_row-gjahr.
      APPEND ls_hkey TO gt_hkey.
    ENDIF.

    IF g_type = 5 OR g_type = 6.
      CLEAR ls_fkey.
      ls_fkey-werks   = ls_row-werks.
      ls_fkey-matnr   = ls_row-matnr.
      ls_fkey-gjahr   = ls_row-gjahr.
      ls_fkey-quarter = ls_row-quarter.
      APPEND ls_fkey TO gt_fkey.
    ENDIF.

  ENDLOOP.

  SORT gt_key BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM gt_key COMPARING werks matnr.

  SORT gt_hkey BY werks matnr gjahr.
  DELETE ADJACENT DUPLICATES FROM gt_hkey COMPARING werks matnr gjahr.

  SORT gt_fkey BY werks matnr gjahr quarter.
  DELETE ADJACENT DUPLICATES FROM gt_fkey
                         COMPARING werks matnr gjahr quarter.

  CHECK gt_key IS NOT INITIAL.

* Plant / material existence, for every upload type
  SELECT werks, matnr
    FROM marc
    FOR ALL ENTRIES IN @gt_key
   WHERE werks = @gt_key-werks
     AND matnr = @gt_key-matnr
    INTO TABLE @gt_marc.

  SORT gt_marc BY werks matnr.

* Base unit of measure, needed only where the file carries a unit
  IF g_type = 4.
    SELECT matnr, meins
      FROM mara
      FOR ALL ENTRIES IN @gt_key
     WHERE matnr = @gt_key-matnr
      INTO TABLE @gt_mara.

    SORT gt_mara BY matnr.
  ENDIF.

* A material that is excluded from the forecast must not receive a
* business forecast or a forecast change
  IF g_type = 5 OR g_type = 6.
    SELECT werks, matnr
      FROM zppt_pnt_mexc
      FOR ALL ENTRIES IN @gt_key
     WHERE werks = @gt_key-werks
       AND matnr = @gt_key-matnr
      INTO TABLE @gt_mexc.

    SORT gt_mexc BY werks matnr.
  ENDIF.

  PERFORM read_existing.

ENDFORM.


*&---------------------------------------------------------------------*
*& READ_EXISTING - the rows already in the target table. Their creation
*&                 stamp is carried forward on an overwrite, and for the
*&                 forecast quantity table the whole row is kept so that
*&                 an upload changes only its own columns and leaves the
*&                 calculated figures alone.
*&---------------------------------------------------------------------*
FORM read_existing.

  CASE g_type.

    WHEN 1.
      SELECT werks, matnr, ernam, erdat
        FROM zppt_pnt_pcat
        FOR ALL ENTRIES IN @gt_key
       WHERE werks = @gt_key-werks
         AND matnr = @gt_key-matnr
        INTO TABLE @gt_adm.

    WHEN 2.
      SELECT werks, new_matnr, ernam, erdat
        FROM zppt_pnt_mtrk
        FOR ALL ENTRIES IN @gt_key
       WHERE werks     = @gt_key-werks
         AND new_matnr = @gt_key-matnr
        INTO TABLE @gt_adm.

    WHEN 3.
      SELECT werks, matnr, ernam, erdat
        FROM zppt_pnt_mexc
        FOR ALL ENTRIES IN @gt_key
       WHERE werks = @gt_key-werks
         AND matnr = @gt_key-matnr
        INTO TABLE @gt_adm.

    WHEN 4.
      IF gt_hkey IS NOT INITIAL.
        SELECT werks, matnr, gjahr, ernam, erdat
          FROM zppt_pnt_shist
          FOR ALL ENTRIES IN @gt_hkey
         WHERE werks = @gt_hkey-werks
           AND matnr = @gt_hkey-matnr
           AND gjahr = @gt_hkey-gjahr
          INTO TABLE @gt_admh.

        SORT gt_admh BY werks matnr gjahr.
      ENDIF.

    WHEN 5 OR 6.
      IF gt_fkey IS NOT INITIAL.
        SELECT *
          FROM zppt_pnt_fqt
          FOR ALL ENTRIES IN @gt_fkey
         WHERE werks   = @gt_fkey-werks
           AND matnr   = @gt_fkey-matnr
           AND gjahr   = @gt_fkey-gjahr
           AND quarter = @gt_fkey-quarter
          INTO TABLE @gt_fqt.

        SORT gt_fqt BY werks matnr gjahr quarter.
      ENDIF.

  ENDCASE.

  IF g_type <= 3.
    SORT gt_adm BY werks matnr.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& VALIDATE_ROWS - the checks that need master data, and the build of
*&                 the write set
*&---------------------------------------------------------------------*
FORM validate_rows.

  DATA: ls_row  TYPE ty_row,
        ls_mara TYPE ty_mara,
        lv_rowc TYPE c LENGTH 10,
        lv_matc TYPE c LENGTH 40.

  LOOP AT gt_row INTO ls_row.

    lv_rowc = ls_row-row.
    CONDENSE lv_rowc.

    lv_matc = ls_row-matnr.
    CONDENSE lv_matc.

*   Plant / material must exist in MARC. FS: "Pass plant and material to
*   marc-werks and plant and check entry is exist. If not, error
*   message: Material is not created in the Plant".
    READ TABLE gt_marc TRANSPORTING NO FIELDS
         WITH KEY werks = ls_row-werks
                  matnr = ls_row-matnr
         BINARY SEARCH.
    IF sy-subrc <> 0.
      PERFORM reject USING ls_row '009' lv_matc ls_row-werks space.
      CONTINUE.
    ENDIF.

*   The unit in the file has to be the base unit of the material,
*   because the month columns are stored against that unit and nothing
*   converts them later.
*   ASSUMPTION: the template asks for the SAP base unit code as it is
*   stored in MARA-MEINS. No CUNIT conversion exit is applied, so a
*   language dependent external unit text is rejected rather than
*   silently mapped.
    IF g_type = 4 AND ls_row-meins IS NOT INITIAL.
      CLEAR ls_mara.
      READ TABLE gt_mara INTO ls_mara
           WITH KEY matnr = ls_row-matnr
           BINARY SEARCH.
      IF sy-subrc = 0 AND ls_mara-meins <> ls_row-meins.
        PERFORM reject USING ls_row '028' lv_rowc ls_row-meins lv_matc.
        CONTINUE.
      ENDIF.
    ENDIF.

*   A blank unit takes the base unit of the material, so the stored row
*   always carries a unit
    IF g_type = 4 AND ls_row-meins IS INITIAL.
      CLEAR ls_mara.
      READ TABLE gt_mara INTO ls_mara
           WITH KEY matnr = ls_row-matnr
           BINARY SEARCH.
      IF sy-subrc = 0.
        ls_row-meins = ls_mara-meins.
      ENDIF.
    ENDIF.

    IF g_type = 5 OR g_type = 6.
      READ TABLE gt_mexc TRANSPORTING NO FIELDS
           WITH KEY werks = ls_row-werks
                    matnr = ls_row-matnr
           BINARY SEARCH.
      IF sy-subrc = 0.
        PERFORM reject USING ls_row '022' lv_matc ls_row-werks space.
        CONTINUE.
      ENDIF.
    ENDIF.

    CASE g_type.
      WHEN 1. PERFORM build_pcat  USING ls_row.
      WHEN 2. PERFORM build_mtrk  USING ls_row.
      WHEN 3. PERFORM build_mexc  USING ls_row.
      WHEN 4. PERFORM build_shist USING ls_row.
      WHEN 5. PERFORM build_fqt   USING ls_row.
      WHEN 6. PERFORM build_fqt   USING ls_row.
    ENDCASE.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& BUILD_PCAT - 1  ZPPT_PNT_PCAT
*&---------------------------------------------------------------------*
FORM build_pcat USING ps_row TYPE ty_row.

  DATA: ls_out TYPE zppt_pnt_pcat,
        ls_adm TYPE ty_adm,
        lv_ex  TYPE abap_bool.

  ls_out-werks    = ps_row-werks.
  ls_out-matnr    = ps_row-matnr.
  ls_out-prod_cat = ps_row-prod_cat.
  ls_out-load_fct = ps_row-load_fct.
  ls_out-mts_mto  = ps_row-mts_mto.

  READ TABLE gt_adm INTO ls_adm
       WITH KEY werks = ps_row-werks
                matnr = ps_row-matnr
       BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ex = abap_true.
  ENDIF.

  PERFORM stamp USING lv_ex ls_adm-ernam ls_adm-erdat
             CHANGING ls_out-ernam ls_out-erdat
                      ls_out-aenam ls_out-aedat.

  PERFORM put_pcat USING ls_out.
  PERFORM accept USING ps_row lv_ex.

ENDFORM.


*&---------------------------------------------------------------------*
*& BUILD_MTRK - 2  ZPPT_PNT_MTRK
*&---------------------------------------------------------------------*
FORM build_mtrk USING ps_row TYPE ty_row.

  DATA: ls_out TYPE zppt_pnt_mtrk,
        ls_adm TYPE ty_adm,
        lv_ex  TYPE abap_bool.

  ls_out-werks      = ps_row-werks.
  ls_out-new_matnr  = ps_row-matnr.
  ls_out-old_matnr1 = ps_row-old1.
  ls_out-old_matnr2 = ps_row-old2.

  READ TABLE gt_adm INTO ls_adm
       WITH KEY werks = ps_row-werks
                matnr = ps_row-matnr
       BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ex = abap_true.
  ENDIF.

  PERFORM stamp USING lv_ex ls_adm-ernam ls_adm-erdat
             CHANGING ls_out-ernam ls_out-erdat
                      ls_out-aenam ls_out-aedat.

  PERFORM put_mtrk USING ls_out.
  PERFORM accept USING ps_row lv_ex.

ENDFORM.


*&---------------------------------------------------------------------*
*& BUILD_MEXC - 3  ZPPT_PNT_MEXC
*&---------------------------------------------------------------------*
FORM build_mexc USING ps_row TYPE ty_row.

  DATA: ls_out TYPE zppt_pnt_mexc,
        ls_adm TYPE ty_adm,
        lv_ex  TYPE abap_bool.

  ls_out-werks = ps_row-werks.
  ls_out-matnr = ps_row-matnr.

  READ TABLE gt_adm INTO ls_adm
       WITH KEY werks = ps_row-werks
                matnr = ps_row-matnr
       BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ex = abap_true.
  ENDIF.

  PERFORM stamp USING lv_ex ls_adm-ernam ls_adm-erdat
             CHANGING ls_out-ernam ls_out-erdat
                      ls_out-aenam ls_out-aedat.

  PERFORM put_mexc USING ls_out.
  PERFORM accept USING ps_row lv_ex.

ENDFORM.


*&---------------------------------------------------------------------*
*& BUILD_SHIST - 4  ZPPT_PNT_SHIST
*&---------------------------------------------------------------------*
FORM build_shist USING ps_row TYPE ty_row.

  DATA: ls_out  TYPE zppt_pnt_shist,
        ls_admh TYPE ty_admh,
        lv_ex   TYPE abap_bool.

  ls_out-werks = ps_row-werks.
  ls_out-matnr = ps_row-matnr.
  ls_out-gjahr = ps_row-gjahr.
  ls_out-meins = ps_row-meins.
  ls_out-m01   = ps_row-m01.
  ls_out-m02   = ps_row-m02.
  ls_out-m03   = ps_row-m03.
  ls_out-m04   = ps_row-m04.
  ls_out-m05   = ps_row-m05.
  ls_out-m06   = ps_row-m06.
  ls_out-m07   = ps_row-m07.
  ls_out-m08   = ps_row-m08.
  ls_out-m09   = ps_row-m09.
  ls_out-m10   = ps_row-m10.
  ls_out-m11   = ps_row-m11.
  ls_out-m12   = ps_row-m12.

  READ TABLE gt_admh INTO ls_admh
       WITH KEY werks = ps_row-werks
                matnr = ps_row-matnr
                gjahr = ps_row-gjahr
       BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ex = abap_true.
  ENDIF.

  PERFORM stamp USING lv_ex ls_admh-ernam ls_admh-erdat
             CHANGING ls_out-ernam ls_out-erdat
                      ls_out-aenam ls_out-aedat.

  PERFORM put_shist USING ls_out.
  PERFORM accept USING ps_row lv_ex.

ENDFORM.


*&---------------------------------------------------------------------*
*& BUILD_FQT - 5  ZPPT_PNT_FQT-BUS_FCST
*&             6  ZPPT_PNT_FQT-BUS_FCST_ADD and REASON
*&
*& The whole existing row is taken and written back, so an upload onto
*& an already generated forecast changes only its own columns and leaves
*& every calculated figure untouched. FINAL_QTY is deliberately NOT
*& recalculated here - the engine ZCL_PP_PFCST owns that formula and
*& recomputes it on the next run of the generation report.
*&---------------------------------------------------------------------*
FORM build_fqt USING ps_row TYPE ty_row.

  DATA: ls_out TYPE zppt_pnt_fqt,
        lv_ex  TYPE abap_bool.

  READ TABLE gt_fqt INTO ls_out
       WITH KEY werks   = ps_row-werks
                matnr   = ps_row-matnr
                gjahr   = ps_row-gjahr
                quarter = ps_row-quarter
       BINARY SEARCH.
  IF sy-subrc = 0.
    lv_ex = abap_true.
  ELSE.
    CLEAR ls_out.
    ls_out-werks   = ps_row-werks.
    ls_out-matnr   = ps_row-matnr.
    ls_out-gjahr   = ps_row-gjahr.
    ls_out-quarter = ps_row-quarter.
  ENDIF.

  IF g_type = 5.
    ls_out-bus_fcst = ps_row-qty.
  ELSE.
    ls_out-bus_fcst_add = ps_row-qty.
    ls_out-reason       = ps_row-reason.
  ENDIF.

  PERFORM stamp USING lv_ex ls_out-ernam ls_out-erdat
             CHANGING ls_out-ernam ls_out-erdat
                      ls_out-aenam ls_out-aedat.

  PERFORM put_fqt USING ls_out.
  PERFORM accept USING ps_row lv_ex.

ENDFORM.


*&---------------------------------------------------------------------*
*& PUT_* - add one row to the write set. A key that appears twice in one
*&         file keeps the last row, so the set that reaches MODIFY holds
*&         each key exactly once.
*&---------------------------------------------------------------------*
FORM put_pcat USING ps_out TYPE zppt_pnt_pcat.

  MODIFY TABLE gt_wpcat FROM ps_out.
  IF sy-subrc <> 0.
    INSERT ps_out INTO TABLE gt_wpcat.
  ENDIF.

ENDFORM.

FORM put_mtrk USING ps_out TYPE zppt_pnt_mtrk.

  MODIFY TABLE gt_wmtrk FROM ps_out.
  IF sy-subrc <> 0.
    INSERT ps_out INTO TABLE gt_wmtrk.
  ENDIF.

ENDFORM.

FORM put_mexc USING ps_out TYPE zppt_pnt_mexc.

  MODIFY TABLE gt_wmexc FROM ps_out.
  IF sy-subrc <> 0.
    INSERT ps_out INTO TABLE gt_wmexc.
  ENDIF.

ENDFORM.

FORM put_shist USING ps_out TYPE zppt_pnt_shist.

  MODIFY TABLE gt_wshist FROM ps_out.
  IF sy-subrc <> 0.
    INSERT ps_out INTO TABLE gt_wshist.
  ENDIF.

ENDFORM.

FORM put_fqt USING ps_out TYPE zppt_pnt_fqt.

  MODIFY TABLE gt_wfqt FROM ps_out.
  IF sy-subrc <> 0.
    INSERT ps_out INTO TABLE gt_wfqt.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& STAMP - creation stamp on a new row, change stamp on an overwrite.
*&         The original creator is carried forward.
*&---------------------------------------------------------------------*
FORM stamp USING pv_exists TYPE abap_bool
                 pv_ernam  TYPE any
                 pv_erdat  TYPE any
        CHANGING cv_ernam  TYPE any
                 cv_erdat  TYPE any
                 cv_aenam  TYPE any
                 cv_aedat  TYPE any.

  IF pv_exists = abap_true.
    cv_ernam = pv_ernam.
    cv_erdat = pv_erdat.
    cv_aenam = sy-uname.
    cv_aedat = sy-datum.
  ELSE.
    cv_ernam = sy-uname.
    cv_erdat = sy-datum.
    CLEAR: cv_aenam, cv_aedat.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& WRITE_DATA - lock, one MODIFY of the whole set, unlock
*&---------------------------------------------------------------------*
FORM write_data.

  DATA: lv_lock TYPE abap_bool,
        lv_subrc TYPE sy-subrc,
        lv_txt  TYPE string.

  IF g_ok = 0.
    RETURN.
  ENDIF.

* A test run does everything except the database write
  IF p_test = abap_true.
    RETURN.
  ENDIF.

  PERFORM lock_table CHANGING lv_lock.
  IF lv_lock = abap_false.
    CONCATENATE 'Table' g_tabn 'is locked by another user,'
                'nothing was written'
           INTO lv_txt SEPARATED BY space.
    PERFORM fail_all USING lv_txt.
    RETURN.
  ENDIF.

  CLEAR lv_subrc.

  CASE g_type.
    WHEN 1.
      MODIFY zppt_pnt_pcat FROM TABLE @gt_wpcat.
      lv_subrc = sy-subrc.
    WHEN 2.
      MODIFY zppt_pnt_mtrk FROM TABLE @gt_wmtrk.
      lv_subrc = sy-subrc.
    WHEN 3.
      MODIFY zppt_pnt_mexc FROM TABLE @gt_wmexc.
      lv_subrc = sy-subrc.
    WHEN 4.
      MODIFY zppt_pnt_shist FROM TABLE @gt_wshist.
      lv_subrc = sy-subrc.
    WHEN 5 OR 6.
      MODIFY zppt_pnt_fqt FROM TABLE @gt_wfqt.
      lv_subrc = sy-subrc.
  ENDCASE.

  IF lv_subrc = 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    CONCATENATE 'The database update of table' g_tabn 'failed,'
                'nothing was written'
           INTO lv_txt SEPARATED BY space.
    PERFORM fail_all USING lv_txt.
  ENDIF.

  PERFORM unlock_table.

ENDFORM.


*&---------------------------------------------------------------------*
*& LOCK_TABLE / UNLOCK_TABLE - ENQUEUE_E_TABLE on the target table
*&---------------------------------------------------------------------*
FORM lock_table CHANGING cv_ok TYPE abap_bool.

  CLEAR cv_ok.

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      mode_rstable   = 'E'
      tabname        = g_tabn
      _scope         = '2'
      _wait          = abap_true
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc = 0.
    cv_ok = abap_true.
  ENDIF.

ENDFORM.

FORM unlock_table.

  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      mode_rstable = 'E'
      tabname      = g_tabn
      _scope       = '3'.

ENDFORM.


*&---------------------------------------------------------------------*
*& FAIL_ALL - the write did not happen. Every row that had been accepted
*&            is turned back into a rejection with the reason, so the log
*&            never shows a row as loaded when it is not in the table.
*&---------------------------------------------------------------------*
FORM fail_all USING pv_text TYPE string.

  FIELD-SYMBOLS <ls_log> TYPE ty_log.

  LOOP AT gt_log ASSIGNING <ls_log> WHERE light <> gc_red.
    <ls_log>-light   = gc_red.
    <ls_log>-status  = gc_rej.
    <ls_log>-message = pv_text.
    g_ok  = g_ok - 1.
    g_bad = g_bad + 1.
  ENDLOOP.

  MESSAGE pv_text TYPE 'S' DISPLAY LIKE 'E'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Conversion helpers
*&---------------------------------------------------------------------*
FORM to_plant USING pv_in TYPE any
           CHANGING cv_werks TYPE werks_d.

* Plant carries no conversion exit, so it is taken as typed, condensed
  CLEAR cv_werks.
  cv_werks = pv_in.
  CONDENSE cv_werks.

ENDFORM.


FORM to_matnr USING pv_in TYPE any
           CHANGING cv_matnr TYPE matnr.

  DATA lv_in TYPE c LENGTH 40.

  CLEAR cv_matnr.

  lv_in = pv_in.
  CONDENSE lv_in.

  IF lv_in IS INITIAL.
    RETURN.
  ENDIF.

* A spreadsheet drops leading zeros, the table stores them, so the file
* value is padded before it is used as a key or matched against MARC
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = lv_in
    IMPORTING
      output       = cv_matnr
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    cv_matnr = lv_in.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& CLEAN_NUM - turn a spreadsheet cell into a string that ABAP can
*&             convert to a number, and say whether it is a number at
*&             all. Nothing is handed to a numeric target uncleaned.
*&
*& Spaces and thousands separators are removed. A comma is accepted as
*& a decimal separator - "1,5" loads as 1.5 and never as 15.
*&
*& ASSUMPTION: where a single comma is followed by exactly three digits
*& the cell is ambiguous ("1,500" is one thousand five hundred in an
*& Indian or English sheet and one and a half in a European one). The
*& grouping reading is taken, because that is what Excel writes by
*& default on this landscape. Any other single comma is the decimal
*& point. When both separators appear, the one that comes last is the
*& decimal point.
*&---------------------------------------------------------------------*
FORM clean_num USING pv_in TYPE any
            CHANGING cv_out TYPE string
                     cv_ok  TYPE abap_bool.

  DATA: lv_s    TYPE string,
        lv_dot  TYPE i,
        lv_com  TYPE i,
        lv_pd   TYPE i,
        lv_pc   TYPE i,
        lv_len  TYPE i,
        lv_tail TYPE i.

  CLEAR: cv_out, cv_ok.

  lv_s = pv_in.
  REPLACE ALL OCCURRENCES OF g_tab IN lv_s WITH ''.
  CONDENSE lv_s NO-GAPS.

  IF lv_s IS INITIAL.
    RETURN.
  ENDIF.

  FIND ALL OCCURRENCES OF '.' IN lv_s MATCH COUNT lv_dot.
  FIND ALL OCCURRENCES OF ',' IN lv_s MATCH COUNT lv_com.

  IF lv_dot > 0 AND lv_com > 0.

    FIND LAST OCCURRENCE OF '.' IN lv_s MATCH OFFSET lv_pd.
    FIND LAST OCCURRENCE OF ',' IN lv_s MATCH OFFSET lv_pc.

    IF lv_pc > lv_pd.
      REPLACE ALL OCCURRENCES OF '.' IN lv_s WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN lv_s WITH '.'.
    ELSE.
      REPLACE ALL OCCURRENCES OF ',' IN lv_s WITH ''.
    ENDIF.

  ELSEIF lv_com = 1.

    FIND FIRST OCCURRENCE OF ',' IN lv_s MATCH OFFSET lv_pc.
    lv_len  = strlen( lv_s ).
    lv_tail = lv_len - lv_pc - 1.

    IF lv_tail = 3.
      REPLACE ALL OCCURRENCES OF ',' IN lv_s WITH ''.
    ELSE.
      REPLACE ALL OCCURRENCES OF ',' IN lv_s WITH '.'.
    ENDIF.

  ELSEIF lv_com > 1.

    REPLACE ALL OCCURRENCES OF ',' IN lv_s WITH ''.

  ENDIF.

* Only after the cleaning is the cell allowed near a numeric target
  FIND REGEX '^[+-]?([0-9]+|[0-9]*[.][0-9]+)[-]?$' IN lv_s.
  IF sy-subrc = 0.
    cv_out = lv_s.
    cv_ok  = abap_true.
  ENDIF.

ENDFORM.


FORM to_dec USING pv_in TYPE any
         CHANGING cv_out TYPE any
                  cv_ok  TYPE abap_bool.

  DATA lv_s TYPE string.

  CLEAR cv_out.

  PERFORM clean_num USING pv_in CHANGING lv_s cv_ok.

  CHECK cv_ok = abap_true.

  TRY.
      cv_out = lv_s.
    CATCH cx_sy_conversion_no_number.
      CLEAR: cv_out, cv_ok.
  ENDTRY.

ENDFORM.


FORM to_int USING pv_in TYPE any
         CHANGING cv_out TYPE i
                  cv_ok  TYPE abap_bool.

  DATA lv_s TYPE string.

  CLEAR cv_out.

  PERFORM clean_num USING pv_in CHANGING lv_s cv_ok.

  CHECK cv_ok = abap_true.

  TRY.
      cv_out = lv_s.
    CATCH cx_sy_conversion_no_number cx_sy_conversion_overflow.
      CLEAR: cv_out, cv_ok.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& TO_FYEAR - the financial year cell. The format is checked by the
*&            utility class, not by a pattern repeated here.
*&
*& ASSUMPTION: the file carries the financial year as YYYY-YYYY, which
*& is what ZDE_PNT_FYEAR holds and what ZCL_PP_PFCST_UTIL validates. The
*& target key field on every upload table is GJAHR, so the first of the
*& two years is stored - financial year 2026-2027 is GJAHR 2026, which
*& is the same convention the generation report uses.
*&---------------------------------------------------------------------*
FORM to_fyear USING pv_in TYPE any
           CHANGING cv_fyear TYPE zde_pnt_fyear
                    cv_gjahr TYPE gjahr
                    cv_ok    TYPE abap_bool.

  DATA lv_s TYPE string.

  CLEAR: cv_fyear, cv_gjahr, cv_ok.

  lv_s = pv_in.
  CONDENSE lv_s NO-GAPS.

  IF lv_s IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM fits USING lv_s cv_fyear CHANGING cv_ok.
  IF cv_ok = abap_false.
    RETURN.
  ENDIF.

  cv_fyear = lv_s.

  cv_ok = zcl_pp_pfcst_util=>is_fyear_valid( iv_fyear = cv_fyear ).
  IF cv_ok = abap_false.
    CLEAR cv_fyear.
    RETURN.
  ENDIF.

  cv_gjahr = cv_fyear(4).

ENDFORM.


*&---------------------------------------------------------------------*
*& FITS - does the cell fit the target field without truncation. The
*&        length is taken from the field itself, so no field length is
*&        repeated in the code.
*&---------------------------------------------------------------------*
FORM fits USING pv_val TYPE any
                pv_fld TYPE any
       CHANGING cv_ok  TYPE abap_bool.

  DATA: lv_flen TYPE i,
        lv_vlen TYPE i,
        lv_s    TYPE string.

  lv_s = pv_val.

  DESCRIBE FIELD pv_fld LENGTH lv_flen IN CHARACTER MODE.

  lv_vlen = strlen( lv_s ).

  IF lv_vlen > lv_flen.
    cv_ok = abap_false.
  ELSE.
    cv_ok = abap_true.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Result log
*&---------------------------------------------------------------------*
FORM reject USING ps_row TYPE ty_row
                  pv_num TYPE any
                  pv_p1  TYPE any
                  pv_p2  TYPE any
                  pv_p3  TYPE any.

  DATA: lv_num TYPE symsgno,
        lv_txt TYPE string.

  lv_num = pv_num.

  MESSAGE ID gc_msgid TYPE 'E' NUMBER lv_num
          WITH pv_p1 pv_p2 pv_p3 INTO lv_txt.

  PERFORM reject_txt USING ps_row lv_txt.

ENDFORM.


FORM reject_txt USING ps_row TYPE ty_row
                      pv_txt TYPE any.

  DATA ls_log TYPE ty_log.

  ls_log-row     = ps_row-row.
  ls_log-werks   = ps_row-werks.
  ls_log-matnr   = ps_row-matnr.
  ls_log-gjahr   = ps_row-gjahr.
  ls_log-quarter = ps_row-quarter.
  ls_log-light   = gc_red.
  ls_log-status  = gc_rej.
  ls_log-message = pv_txt.

  APPEND ls_log TO gt_log.

  g_bad = g_bad + 1.

ENDFORM.


FORM accept USING ps_row TYPE ty_row
                  pv_ex  TYPE abap_bool.

  DATA: ls_log TYPE ty_log,
        lv_txt TYPE string.

  ls_log-row     = ps_row-row.
  ls_log-werks   = ps_row-werks.
  ls_log-matnr   = ps_row-matnr.
  ls_log-gjahr   = ps_row-gjahr.
  ls_log-quarter = ps_row-quarter.

  IF pv_ex = abap_true.
    lv_txt = 'The existing entry is overwritten'.
  ELSE.
    lv_txt = 'A new entry is created'.
  ENDIF.

  IF p_test = abap_true.
    ls_log-light  = gc_yellow.
    ls_log-status = gc_tst.
    CONCATENATE 'Test run, nothing written -' lv_txt
           INTO lv_txt SEPARATED BY space.
  ELSEIF pv_ex = abap_true.
    ls_log-light  = gc_green.
    ls_log-status = gc_upd.
  ELSE.
    ls_log-light  = gc_green.
    ls_log-status = gc_ins.
  ENDIF.

  ls_log-message = lv_txt.

  APPEND ls_log TO gt_log.

  g_ok = g_ok + 1.

ENDFORM.


*&---------------------------------------------------------------------*
*& DISPLAY_LOG - full screen CL_SALV_TABLE, one line per file row
*&---------------------------------------------------------------------*
FORM display_log.

  DATA: lo_alv  TYPE REF TO cl_salv_table,
        lo_cols TYPE REF TO cl_salv_columns_table,
        lv_ttl  TYPE lvc_title,
        lv_head TYPE string.

  IF gt_log IS INITIAL.
    MESSAGE s014 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  SORT gt_log BY row.

  PERFORM head_text CHANGING lv_head.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = lo_alv
        CHANGING  t_table      = gt_log ).

      lo_alv->get_functions( )->set_all( ).

      lo_cols = lo_alv->get_columns( ).
      lo_cols->set_optimize( ).

      TRY.
          lo_cols->set_exception_column( 'LIGHT' ).
        CATCH cx_salv_data_error.
      ENDTRY.

      PERFORM txt USING lo_cols 'ROW'     'File Row'.
      PERFORM txt USING lo_cols 'WERKS'   'Plant'.
      PERFORM txt USING lo_cols 'MATNR'   'Material'.
      PERFORM txt USING lo_cols 'GJAHR'   'Financial Year'.
      PERFORM txt USING lo_cols 'QUARTER' 'Quarter'.
      PERFORM txt USING lo_cols 'STATUS'  'Result'.
      PERFORM txt USING lo_cols 'MESSAGE' 'Message'.

*     The year and the quarter belong to three of the six upload types,
*     so they are hidden where the file does not carry them
      IF g_type <= 3.
        PERFORM hide USING lo_cols 'GJAHR'.
        PERFORM hide USING lo_cols 'QUARTER'.
      ELSEIF g_type = 4.
        PERFORM hide USING lo_cols 'QUARTER'.
      ENDIF.

      TRY.
          lo_cols->get_column( 'MESSAGE' )->set_output_length( 70 ).
        CATCH cx_salv_not_found.
      ENDTRY.

      lv_ttl = lv_head.
      lo_alv->get_display_settings( )->set_list_header( lv_ttl ).

      lo_alv->display( ).

    CATCH cx_salv_msg.
*     The list could not be built. The counts still have to reach the
*     user, so they are shown as an information message instead of the
*     run ending silently.
      MESSAGE lv_head TYPE 'I'.
  ENDTRY.

ENDFORM.


FORM head_text CHANGING cv_head TYPE string.

  DATA lv_tab TYPE string.

  lv_tab = g_tabn.

  IF p_test = abap_true.
    CONCATENATE 'Test run against table' lv_tab '- nothing was written'
           INTO cv_head SEPARATED BY space.
  ELSE.
    CONCATENATE 'Upload into table' lv_tab
           INTO cv_head SEPARATED BY space.
  ENDIF.

ENDFORM.


FORM hide USING po_cols TYPE REF TO cl_salv_columns_table
                pv_name TYPE any.

  DATA lv_nam TYPE lvc_fname.

  lv_nam = pv_name.

  TRY.
      po_cols->get_column( lv_nam )->set_technical( abap_true ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& TXT - readable column heading. ALV picks which of the three heading
*&       texts it draws from the output length, so the width is set from
*&       the heading and set_optimize widens further where the data
*&       needs it. Without this a long heading on a narrow column is
*&       drawn from the short text and cut off.
*&---------------------------------------------------------------------*
FORM txt USING po_cols TYPE REF TO cl_salv_columns_table
               pv_name TYPE any
               pv_text TYPE any.

  DATA: lo_col TYPE REF TO cl_salv_column,
        lv_nam TYPE lvc_fname,
        lv_txt TYPE string,
        lv_len TYPE lvc_outlen,
        lv_s   TYPE scrtext_s,
        lv_m   TYPE scrtext_m,
        lv_l   TYPE scrtext_l.

  lv_nam = pv_name.
  lv_txt = pv_text.
  lv_s   = lv_txt.
  lv_m   = lv_txt.
  lv_l   = lv_txt.

  lv_len = strlen( lv_txt ).
  IF lv_len < 10.
    lv_len = 10.
  ELSEIF lv_len > 40.
    lv_len = 40.
  ENDIF.

  TRY.
      lo_col = po_cols->get_column( lv_nam ).
      lo_col->set_short_text( lv_s ).
      lo_col->set_medium_text( lv_m ).
      lo_col->set_long_text( lv_l ).
      lo_col->set_output_length( lv_len ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*& FINAL_MESSAGE - 020  &1 rows uploaded, &2 rows rejected
*&---------------------------------------------------------------------*
FORM final_message.

  DATA: lv_ok  TYPE c LENGTH 10,
        lv_bad TYPE c LENGTH 10.

  lv_ok = g_ok.
  CONDENSE lv_ok.

  lv_bad = g_bad.
  CONDENSE lv_bad.

  IF g_bad > 0.
    MESSAGE s020 WITH lv_ok lv_bad DISPLAY LIKE 'W'.
  ELSE.
    MESSAGE s020 WITH lv_ok lv_bad.
  ENDIF.

ENDFORM.
