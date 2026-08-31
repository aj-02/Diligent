*&---------------------------------------------------------------------*
*& Report  ZPP_FORECAST_UPLOAD   Transaction  ZFCST_UPL
*& ZFORECAST (Adhesive) - all uploads in one program
*&
*& Eight upload types selected by radio button. For each the user can
*& download a ready made template, fill it in, upload it, and see a
*& result list saying exactly what was created, what was changed and
*& what was rejected and why.
*&
*& Built to Forecast Template-Adhesive.xlsx dated 20.08.2026
*&
*& 31.08.2026  Arnav  Corrections: file row numbers in the log, plant
*&                    cell condensed before it is cut to four
*&                    characters, non numeric cells rejected instead of
*&                    loaded as zero, product category length, unit of
*&                    measure validated, excluded materials refused on
*&                    the two forecast uploads, plant locked for the
*&                    run, MARC and the authorisation check read once
*&                    for the file, own messages 022 and 023, example
*&                    row in the template written commented out
*&---------------------------------------------------------------------*
REPORT zpp_forecast_upload MESSAGE-ID zpp_fcst.

TABLES sscrfields.

TYPES: BEGIN OF ty_raw,
         f01 TYPE char40, f02 TYPE char40, f03 TYPE char40, f04 TYPE char40,
         f05 TYPE char40, f06 TYPE char40, f07 TYPE char40, f08 TYPE char40,
         f09 TYPE char40, f10 TYPE char40, f11 TYPE char40, f12 TYPE char40,
         f13 TYPE char40, f14 TYPE char40, f15 TYPE char40, f16 TYPE char40,
       END OF ty_raw,

       BEGIN OF ty_log,
         row     TYPE i,
         werks   TYPE werks_d,
         matnr   TYPE matnr,
         period  TYPE char12,
         action  TYPE char14,
         light   TYPE char1,
         message TYPE char200,
       END OF ty_log,

*BOC By Arnav on 31/08/26
*      Every row keeps the line number it has in the file the user is
*      looking at, so the log points at the right line even though the
*      heading, the blank rows and the commented rows are dropped
*      before processing
       BEGIN OF ty_row,
         srow TYPE i,
         data TYPE ty_raw,
       END OF ty_row,

*      Plant and material existence, the authorisation check and the
*      exclusion list are read once for the whole file instead of once
*      per row
       BEGIN OF ty_key,
         werks TYPE werks_d,
         matnr TYPE matnr,
       END OF ty_key,

       BEGIN OF ty_auth,
         werks TYPE werks_d,
         ok    TYPE abap_bool,
       END OF ty_auth,

       BEGIN OF ty_lock,
         tabname TYPE rstable-tabname,
         varkey  TYPE rstable-varkey,
         ok      TYPE abap_bool,
       END OF ty_lock.
*EOC By Arnav on 31/08/26

CONSTANTS: gc_new  TYPE char14 VALUE 'Created',
           gc_chg  TYPE char14 VALUE 'Changed',
           gc_err  TYPE char14 VALUE 'Rejected',
           gc_tnew TYPE char14 VALUE 'Would create',
           gc_tchg TYPE char14 VALUE 'Would change'.

DATA: gt_raw TYPE STANDARD TABLE OF ty_raw,
      gt_log TYPE STANDARD TABLE OF ty_log,
      g_new  TYPE i,
      g_chg  TYPE i,
      g_err  TYPE i,
      g_tab  TYPE c LENGTH 1.

*BOC By Arnav on 31/08/26
DATA: gt_row  TYPE STANDARD TABLE OF ty_row,
      gt_marc TYPE HASHED TABLE OF ty_key WITH UNIQUE KEY werks matnr,
      gt_excl TYPE HASHED TABLE OF ty_key WITH UNIQUE KEY werks matnr,
      gt_auth TYPE SORTED TABLE OF ty_auth WITH UNIQUE KEY werks,
      gt_lock TYPE SORTED TABLE OF ty_lock WITH UNIQUE KEY tabname varkey.
*EOC By Arnav on 31/08/26

*&---------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_cat  RADIOBUTTON GROUP typ DEFAULT 'X',
            p_trk  RADIOBUTTON GROUP typ,
            p_exc  RADIOBUTTON GROUP typ,
            p_hist RADIOBUTTON GROUP typ,
            p_busq RADIOBUTTON GROUP typ,
            p_busm RADIOBUTTON GROUP typ,
            p_chgq RADIOBUTTON GROUP typ,
            p_chgm RADIOBUTTON GROUP typ.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_file TYPE localfile,
            p_head AS CHECKBOX DEFAULT 'X',
            p_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.


*&---------------------------------------------------------------------*
INITIALIZATION.

* The file name is deliberately not OBLIGATORY. A mandatory field is
* checked before AT SELECTION-SCREEN runs, which would stop the user
* pressing Download Template before they have a file to name.
  sscrfields-functxt_01 = 'Download Template'.
  g_tab = cl_abap_char_utilities=>horizontal_tab.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM f4_file.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF sscrfields-ucomm = 'FC01'.
    PERFORM download_template.
  ELSEIF sscrfields-ucomm = 'ONLI' AND p_file IS INITIAL.
*BOC By Arnav on 31/08/26
*    MESSAGE e013 WITH 'no file name entered'.
*   013 reads "Upload file could not be read", which is not what
*   happened - no file was named at all. 022 says that.
    MESSAGE e022.
*EOC By Arnav on 31/08/26
  ENDIF.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

*BOC By Arnav on 31/08/26
*  CLEAR: gt_raw, gt_log, g_new, g_chg, g_err.
  CLEAR: gt_raw, gt_row, gt_log, gt_marc, gt_excl, gt_auth, gt_lock,
         g_new, g_chg, g_err.
*EOC By Arnav on 31/08/26

  PERFORM upload_file.

*BOC By Arnav on 31/08/26
*  IF gt_raw IS INITIAL.
  IF gt_row IS INITIAL.
*EOC By Arnav on 31/08/26
    MESSAGE s008 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  CASE 'X'.
    WHEN p_cat.  PERFORM do_category.
    WHEN p_trk.  PERFORM do_tracking.
    WHEN p_exc.  PERFORM do_exclusion.
    WHEN p_hist. PERFORM do_history.
    WHEN p_busq. PERFORM do_business USING 'Q'.
    WHEN p_busm. PERFORM do_business USING 'M'.
    WHEN p_chgq. PERFORM do_change   USING 'Q'.
    WHEN p_chgm. PERFORM do_change   USING 'M'.
  ENDCASE.

* Nothing is committed on a test run. On a real run the good rows are
* committed even when other rows failed, so a partly correct file loads
* what it can and the log says exactly what it did not.
  IF p_test = abap_false AND ( g_new > 0 OR g_chg > 0 ).
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

*BOC By Arnav on 31/08/26
* The locks are taken with _SCOPE 1, which survives the COMMIT, so they
* are given back explicitly once the work is written
  PERFORM unlock_all.
*EOC By Arnav on 31/08/26

  PERFORM display_log.


*&---------------------------------------------------------------------*
*& Template definition - one place, used by the download button and
*& matching the layouts documented for the functional team
*&---------------------------------------------------------------------*
FORM template_columns CHANGING ct_head TYPE string_table
                               ct_demo TYPE string_table
                               cv_name TYPE string.

  CLEAR: ct_head, ct_demo, cv_name.

  IF p_cat = 'X'.
    cv_name = 'ZFCST_Product_Category'.
    ct_head = VALUE #( ( 'PLANT' ) ( 'MATERIAL' ) ( 'CATEGORY' )
                       ( 'LOAD FACTOR' ) ( 'MTS OR MTO' ) ).
    ct_demo = VALUE #( ( '1001' ) ( 'FG00000000001' ) ( 'A' )
                       ( '1.300' ) ( 'MTS' ) ).

  ELSEIF p_trk = 'X'.
    cv_name = 'ZFCST_Material_Tracking'.
    ct_head = VALUE #( ( 'PLANT' ) ( 'NEW MATERIAL' )
                       ( 'OLD MATERIAL 1' ) ( 'OLD MATERIAL 2' ) ).
    ct_demo = VALUE #( ( '1001' ) ( 'FG00000000002' )
                       ( 'FG00000000001' ) ( '' ) ).

  ELSEIF p_exc = 'X'.
    cv_name = 'ZFCST_Material_Exclusion'.
    ct_head = VALUE #( ( 'PLANT' ) ( 'MATERIAL' ) ).
    ct_demo = VALUE #( ( '1001' ) ( 'FG00000000001' ) ).

  ELSEIF p_hist = 'X'.
    cv_name = 'ZFCST_Legacy_Sales_History'.
    ct_head = VALUE #( ( 'PLANT' ) ( 'MATERIAL' ) ( 'YEAR' )
                       ( 'M1 APR' ) ( 'M2 MAY' ) ( 'M3 JUN' ) ( 'M4 JUL' )
                       ( 'M5 AUG' ) ( 'M6 SEP' ) ( 'M7 OCT' ) ( 'M8 NOV' )
                       ( 'M9 DEC' ) ( 'M10 JAN' ) ( 'M11 FEB' ) ( 'M12 MAR' )
                       ( 'UOM' ) ).
    ct_demo = VALUE #( ( '1001' ) ( 'FG00000000001' ) ( '2025' )
                       ( '100' ) ( '120' ) ( '90' ) ( '110' )
                       ( '95' ) ( '130' ) ( '105' ) ( '115' )
                       ( '125' ) ( '85' ) ( '100' ) ( '140' )
                       ( 'EA' ) ).

  ELSEIF p_busq = 'X'.
    cv_name = 'ZFCST_Business_Forecast_Quarterly'.
    ct_head = VALUE #( ( 'MATERIAL' ) ( 'PLANT' ) ( 'QUARTER' )
                       ( 'YEAR' ) ( 'SALES FORECAST' ) ).
    ct_demo = VALUE #( ( 'FG00000000001' ) ( '1001' ) ( '2' )
                       ( '2026' ) ( '12000' ) ).

  ELSEIF p_busm = 'X'.
    cv_name = 'ZFCST_Business_Forecast_Monthly'.
    ct_head = VALUE #( ( 'MATERIAL' ) ( 'PLANT' ) ( 'MONTH' )
                       ( 'YEAR' ) ( 'SALES FORECAST' ) ).
    ct_demo = VALUE #( ( 'FG00000000001' ) ( '1001' ) ( '1' )
                       ( '2026' ) ( '4000' ) ).

  ELSEIF p_chgq = 'X'.
    cv_name = 'ZFCST_Forecast_Change_Quarterly'.
    ct_head = VALUE #( ( 'MATERIAL' ) ( 'PLANT' ) ( 'QUARTER' )
                       ( 'YEAR' ) ( 'CHANGE QTY' ) ( 'REASON' ) ).
    ct_demo = VALUE #( ( 'FG00000000001' ) ( '1001' ) ( '2' )
                       ( '2026' ) ( '10' ) ( 'Additional plan' ) ).

  ELSEIF p_chgm = 'X'.
    cv_name = 'ZFCST_Forecast_Change_Monthly'.
    ct_head = VALUE #( ( 'MATERIAL' ) ( 'PLANT' ) ( 'MONTH' )
                       ( 'YEAR' ) ( 'CHANGE QTY' ) ( 'REASON' ) ).
    ct_demo = VALUE #( ( 'FG00000000001' ) ( '1001' ) ( '1' )
                       ( '2026' ) ( '-10' ) ( 'Reduced plan' ) ).
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
FORM download_template.

  DATA: lt_head TYPE string_table,
        lt_demo TYPE string_table,
        lt_out  TYPE string_table,
        lv_name TYPE string,
        lv_line TYPE string,
        lv_path TYPE string,
        lv_full TYPE string,
        lv_file TYPE string,
        lv_msg  TYPE string.

  PERFORM template_columns CHANGING lt_head lt_demo lv_name.

  CHECK lt_head IS NOT INITIAL.

* Row 1 the column headings, row 2 one example line the user overwrites
  PERFORM join_row USING lt_head CHANGING lv_line.
  APPEND lv_line TO lt_out.

*BOC By Arnav on 31/08/26
*  PERFORM join_row USING lt_demo CHANGING lv_line.
*  APPEND lv_line TO lt_out.
* The example row is written commented out. A user who fills the sheet
* in underneath it and forgets to delete it used to get a spurious
* rejected row on every run. UPLOAD_FILE ignores any row whose first
* cell starts with an asterisk, which also lets a user park a row he
* does not want to load yet.
  PERFORM join_row USING lt_demo CHANGING lv_line.
  CONCATENATE '*' lv_line INTO lv_line.
  APPEND lv_line TO lt_out.
*EOC By Arnav on 31/08/26

  CONCATENATE lv_name '.txt' INTO lv_file.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING  default_file_name = lv_file
               default_extension = 'txt'
    CHANGING   filename          = lv_file
               path              = lv_path
               fullpath          = lv_full
    EXCEPTIONS OTHERS            = 1 ).

  IF sy-subrc <> 0 OR lv_full IS INITIAL.
    RETURN.
  ENDIF.

  cl_gui_frontend_services=>gui_download(
    EXPORTING  filename         = lv_full
               filetype         = 'ASC'
    CHANGING   data_tab         = lt_out
    EXCEPTIONS file_write_error = 1
               OTHERS           = 2 ).

  IF sy-subrc = 0.
    CONCATENATE 'Template saved to' lv_full INTO lv_msg SEPARATED BY space.
    MESSAGE lv_msg TYPE 'S'.
  ELSE.
*BOC By Arnav on 31/08/26
*    MESSAGE e013 WITH lv_full.
*   013 is about reading an upload file. This is a failed template
*   download, which is 023.
    MESSAGE e023 WITH lv_full.
*EOC By Arnav on 31/08/26
  ENDIF.

ENDFORM.


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
FORM f4_file.

  DATA: lt_files TYPE filetable,
        ls_file  TYPE file_table,
        lv_rc    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    CHANGING   file_table = lt_files
               rc         = lv_rc
    EXCEPTIONS OTHERS     = 1 ).

  IF sy-subrc = 0 AND lv_rc > 0.
    READ TABLE lt_files INTO ls_file INDEX 1.
    IF sy-subrc = 0.
      p_file = ls_file-filename.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
FORM upload_file.

*BOC By Arnav on 31/08/26
*  DATA lv_name TYPE string.
  DATA: lv_name TYPE string,
        ls_raw  TYPE ty_raw,
        ls_row  TYPE ty_row,
        lv_tmp  TYPE char40.
*EOC By Arnav on 31/08/26

  lv_name = p_file.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING  filename            = lv_name
               filetype            = 'ASC'
               has_field_separator = 'X'
    CHANGING   data_tab            = gt_raw
    EXCEPTIONS file_open_error     = 1
               file_read_error     = 2
               OTHERS              = 3 ).

  IF sy-subrc <> 0.
    MESSAGE e013 WITH lv_name.
  ENDIF.

*BOC By Arnav on 31/08/26
*  IF p_head = 'X'.
*    DELETE gt_raw INDEX 1.
*  ENDIF.
*
** Trailing blank lines at the end of a spreadsheet export are ignored
** rather than reported as errors
*  DELETE gt_raw WHERE f01 IS INITIAL AND f02 IS INITIAL AND f03 IS INITIAL.
*
* Deleting the heading and the blank rows out of GT_RAW left SY-TABIX in
* the processing loops one or more lines adrift of the line the user is
* looking at, so every rejection was reported against the wrong row. The
* rows to process are copied into GT_ROW instead, each carrying the line
* number it really has in the file.
  CLEAR gt_row.

  LOOP AT gt_raw INTO ls_raw.

*   The heading is line 1 when the checkbox says the file has one
    IF p_head = 'X' AND sy-tabix = 1.
      CONTINUE.
    ENDIF.

*   Blank lines, trailing ones from a spreadsheet export and any left
*   in the middle, are skipped rather than reported as errors
    IF ls_raw-f01 IS INITIAL AND ls_raw-f02 IS INITIAL
                             AND ls_raw-f03 IS INITIAL.
      CONTINUE.
    ENDIF.

*   A row whose first cell starts with an asterisk is a comment
    lv_tmp = ls_raw-f01.
    CONDENSE lv_tmp.
    IF lv_tmp(1) = '*'.
      CONTINUE.
    ENDIF.

    CLEAR ls_row.
    ls_row-srow = sy-tabix.
    ls_row-data = ls_raw.
    APPEND ls_row TO gt_row.

  ENDLOOP.
*EOC By Arnav on 31/08/26

ENDFORM.


*&---------------------------------------------------------------------*
*& 1 - Product category, load factor, MTS / MTO
*&---------------------------------------------------------------------*
FORM do_category.

  DATA: ls_raw   TYPE ty_raw,
        ls_cat   TYPE zppt_prod_cat,
        ls_old   TYPE zppt_prod_cat,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_matnr TYPE matnr,
        lv_cat   TYPE zde_prod_cat,
        lv_mts   TYPE zde_mts_mto,
        lv_load  TYPE zde_load_fct,
        lv_ex    TYPE abap_bool,
        lv_err   TYPE string,
        lv_txt   TYPE string,
        lv_tmp   TYPE char40,
        lv_blank TYPE char12.

*BOC By Arnav on 31/08/26
  DATA: ls_row TYPE ty_row,
        lv_ok  TYPE abap_bool.

* Plant, material and authorisation for the whole file, in one read
  PERFORM prefetch USING 1 2 abap_false.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_plant    USING ls_raw-f01 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_matnr, lv_err.

    PERFORM to_plant USING ls_raw-f01 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM to_material USING ls_raw-f02 CHANGING lv_matnr.

    PERFORM check_marc USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

    lv_tmp = ls_raw-f03.
    CONDENSE lv_tmp.
*BOC By Arnav on 31/08/26
*    lv_cat = to_upper( lv_tmp ).
*   ZDE_PROD_CAT is two characters wide. A longer entry was assigned to
*   it, kept its first two characters and loaded without a word, so
*   "AB1" went in as "AB". It is refused now.
    IF strlen( lv_tmp ) > 2.
      lv_err = 'Product category is longer than the two characters the field holds'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
    lv_cat = to_upper( lv_tmp ).
*EOC By Arnav on 31/08/26
    IF lv_cat IS INITIAL.
      lv_err = 'Product category is mandatory'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*    PERFORM to_dec USING ls_raw-f04 CHANGING lv_load.
*   A cell that is not a number used to come back as zero and be
*   reported as "must be greater than zero", which reads like an empty
*   cell. The two are told apart now.
    PERFORM to_dec USING ls_raw-f04 CHANGING lv_load lv_ok.
    IF lv_ok = abap_false.
      lv_err = 'Load factor is not a number'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    IF lv_load <= 0.
      lv_err = 'Load factor must be a number greater than zero'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

    lv_tmp = ls_raw-f05.
    CONDENSE lv_tmp.
    lv_mts = to_upper( lv_tmp ).
    IF lv_mts IS NOT INITIAL AND lv_mts <> 'MTS' AND lv_mts <> 'MTO'.
      lv_err = 'MTS or MTO column must contain MTS, MTO or nothing'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*   Nothing stopped two users, or an upload and the forecast screen,
*   reading the same row and writing it back over one another. The
*   plant is locked for the length of the run before the row is read.
    PERFORM lock_row USING 'ZPPT_PROD_CAT' lv_werks CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

*   The existing row is read first so the original created by and
*   created on are carried forward instead of being wiped by the MODIFY
    CLEAR: ls_cat, ls_old, lv_ex.
    SELECT SINGLE * FROM zppt_prod_cat INTO @ls_old
      WHERE werks = @lv_werks AND matnr = @lv_matnr.
    IF sy-subrc = 0.
      lv_ex  = abap_true.
      ls_cat = ls_old.
    ENDIF.

    ls_cat-werks    = lv_werks.
    ls_cat-matnr    = lv_matnr.
    ls_cat-prod_cat = lv_cat.
    ls_cat-load_fct = lv_load.
    ls_cat-mts_mto  = lv_mts.
    PERFORM stamp USING lv_ex CHANGING ls_cat-ernam ls_cat-erdat
                                       ls_cat-aenam ls_cat-aedat.

    IF p_test = abap_false.
      MODIFY zppt_prod_cat FROM @ls_cat.
      IF sy-subrc <> 0.
        lv_err = 'Database update failed'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
        CONTINUE.
      ENDIF.
    ENDIF.

    lv_txt = |Category { lv_cat }, load factor { lv_load }, { lv_mts }|.
    PERFORM log_ok USING lv_row lv_werks lv_matnr lv_blank lv_ex lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& 2 - Material code tracking, old code to new code
*&---------------------------------------------------------------------*
FORM do_tracking.

  DATA: ls_raw   TYPE ty_raw,
        ls_trk   TYPE zppt_mat_track,
        ls_old   TYPE zppt_mat_track,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_new   TYPE matnr,
        lv_old1  TYPE matnr,
        lv_old2  TYPE matnr,
        lv_ex    TYPE abap_bool,
        lv_err   TYPE string,
        lv_txt   TYPE string,
        lv_blank TYPE char12.

*BOC By Arnav on 31/08/26
  DATA ls_row TYPE ty_row.

  PERFORM prefetch USING 1 2 abap_false.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_plant    USING ls_raw-f01 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_new, lv_err.

    PERFORM to_plant USING ls_raw-f01 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM to_material USING ls_raw-f02 CHANGING lv_new.
    PERFORM to_material USING ls_raw-f03 CHANGING lv_old1.
    PERFORM to_material USING ls_raw-f04 CHANGING lv_old2.

    PERFORM check_marc USING lv_werks lv_new CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

    IF lv_old1 IS INITIAL AND lv_old2 IS INITIAL.
      lv_err = 'At least one old material code must be given'.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

    IF lv_old1 = lv_new OR lv_old2 = lv_new.
      lv_err = 'The old material code must be different from the new code'.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

    IF lv_old1 IS NOT INITIAL AND lv_old1 = lv_old2.
      lv_err = 'Old material 1 and old material 2 are the same code'.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

*   An old code that is itself a successor would make the chain
*   ambiguous, so it is refused rather than silently mis-added
    PERFORM check_chain USING lv_werks lv_old1 lv_old2 CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
    PERFORM lock_row USING 'ZPPT_MAT_TRACK' lv_werks CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

    CLEAR: ls_trk, ls_old, lv_ex.
    SELECT SINGLE * FROM zppt_mat_track INTO @ls_old
      WHERE werks = @lv_werks AND new_matnr = @lv_new.
    IF sy-subrc = 0.
      lv_ex  = abap_true.
      ls_trk = ls_old.
    ENDIF.

    ls_trk-werks      = lv_werks.
    ls_trk-new_matnr  = lv_new.
    ls_trk-old_matnr1 = lv_old1.
    ls_trk-old_matnr2 = lv_old2.
    PERFORM stamp USING lv_ex CHANGING ls_trk-ernam ls_trk-erdat
                                       ls_trk-aenam ls_trk-aedat.

    IF p_test = abap_false.
      MODIFY zppt_mat_track FROM @ls_trk.
      IF sy-subrc <> 0.
        lv_err = 'Database update failed'.
        PERFORM log USING lv_row lv_werks lv_new lv_blank gc_err lv_err.
        CONTINUE.
      ENDIF.
    ENDIF.

    lv_txt = |History of { lv_old1 } { lv_old2 } will now be reported under { lv_new }|.
    PERFORM log_ok USING lv_row lv_werks lv_new lv_blank lv_ex lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*BOC By Arnav on 31/08/26
* The two reads below stay inside the row loop on purpose. They have to
* see the rows written earlier in this same file, so they cannot be
* pre-read with FOR ALL ENTRIES the way MARC is.
*EOC By Arnav on 31/08/26
FORM check_chain USING pv_werks TYPE werks_d
                       pv_old1  TYPE matnr
                       pv_old2  TYPE matnr
                 CHANGING pv_err TYPE string.

  DATA lv_hit TYPE matnr.

  CLEAR pv_err.

  IF pv_old1 IS NOT INITIAL.
    SELECT SINGLE new_matnr FROM zppt_mat_track INTO @lv_hit
      WHERE werks = @pv_werks AND new_matnr = @pv_old1.
    IF sy-subrc = 0.
      pv_err = |{ pv_old1 } is already a new code in this table, a chain is not supported|.
      RETURN.
    ENDIF.
  ENDIF.

  IF pv_old2 IS NOT INITIAL.
    SELECT SINGLE new_matnr FROM zppt_mat_track INTO @lv_hit
      WHERE werks = @pv_werks AND new_matnr = @pv_old2.
    IF sy-subrc = 0.
      pv_err = |{ pv_old2 } is already a new code in this table, a chain is not supported|.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& 3 - Material exclusion
*&---------------------------------------------------------------------*
FORM do_exclusion.

  DATA: ls_raw   TYPE ty_raw,
        ls_exc   TYPE zppt_mat_excl,
        ls_old   TYPE zppt_mat_excl,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_matnr TYPE matnr,
        lv_ex    TYPE abap_bool,
        lv_err   TYPE string,
        lv_txt   TYPE string,
        lv_blank TYPE char12.

*BOC By Arnav on 31/08/26
  DATA ls_row TYPE ty_row.

  PERFORM prefetch USING 1 2 abap_false.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_plant    USING ls_raw-f01 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_matnr, lv_err.

    PERFORM to_plant USING ls_raw-f01 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM to_material USING ls_raw-f02 CHANGING lv_matnr.

    PERFORM check_marc USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
    PERFORM lock_row USING 'ZPPT_MAT_EXCL' lv_werks CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

    CLEAR: ls_exc, ls_old, lv_ex.
    SELECT SINGLE * FROM zppt_mat_excl INTO @ls_old
      WHERE werks = @lv_werks AND matnr = @lv_matnr.
    IF sy-subrc = 0.
      lv_ex  = abap_true.
      ls_exc = ls_old.
    ENDIF.

    ls_exc-werks = lv_werks.
    ls_exc-matnr = lv_matnr.
    PERFORM stamp USING lv_ex CHANGING ls_exc-ernam ls_exc-erdat
                                       ls_exc-aenam ls_exc-aedat.

    IF p_test = abap_false.
      MODIFY zppt_mat_excl FROM @ls_exc.
      IF sy-subrc <> 0.
        lv_err = 'Database update failed'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_blank gc_err lv_err.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF lv_ex = abap_true.
      lv_txt = 'Already excluded, entry refreshed'.
    ELSE.
      lv_txt = 'Excluded from forecasting'.
    ENDIF.
    PERFORM log_ok USING lv_row lv_werks lv_matnr lv_blank lv_ex lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& 4 - Legacy sales history, twelve months on one row
*&---------------------------------------------------------------------*
FORM do_history.

  DATA: ls_raw   TYPE ty_raw,
        ls_hist  TYPE zppt_sls_hist,
        ls_old   TYPE zppt_sls_hist,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_matnr TYPE matnr,
        lv_year  TYPE i,
        lv_gjahr TYPE gjahr,
        lv_meins TYPE meins,
        lv_qty   TYPE zde_fcst_qty,
        lv_tot   TYPE zde_fcst_qty,
        lv_ex    TYPE abap_bool,
        lv_err   TYPE string,
        lv_txt   TYPE string,
*BOC By Arnav on 31/08/26
*        lv_tmp   TYPE char40,
*       Its only use, the unit of measure cell, is now done by TO_UOM
*EOC By Arnav on 31/08/26
        lv_per   TYPE char12,
        lv_i     TYPE i,
        lv_src   TYPE i,
        lv_fld   TYPE char3.

  FIELD-SYMBOLS: <lv_in>  TYPE any,
                 <lv_out> TYPE any.

*BOC By Arnav on 31/08/26
  DATA: ls_row TYPE ty_row,
        lv_ok  TYPE abap_bool,
        lv_bad TYPE i.

  PERFORM prefetch USING 1 2 abap_false.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_plant    USING ls_raw-f01 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_matnr, lv_err, lv_per.

    PERFORM to_plant USING ls_raw-f01 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM to_material USING ls_raw-f02 CHANGING lv_matnr.

    lv_per = ls_raw-f03.
    CONDENSE lv_per.

    PERFORM check_marc USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*    PERFORM to_int USING ls_raw-f03 CHANGING lv_year.
    PERFORM to_int USING ls_raw-f03 CHANGING lv_year lv_ok.
*EOC By Arnav on 31/08/26
    IF lv_year < 1900 OR lv_year > 2999.
      lv_err = 'Year must be the four digit year the financial year starts in'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
    lv_gjahr = lv_year.

*BOC By Arnav on 31/08/26
*    lv_tmp = ls_raw-f16.
*    CONDENSE lv_tmp.
*    lv_meins = to_upper( lv_tmp ).
*   A unit that does not exist was stored exactly as typed and only
*   showed up later, as a wrong or failed tonnage conversion. It is
*   checked, and converted from its external form, here.
    PERFORM to_uom USING ls_raw-f16 CHANGING lv_meins lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

    PERFORM lock_row USING 'ZPPT_SLS_HIST' lv_werks CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

    CLEAR: ls_hist, ls_old, lv_ex.
    SELECT SINGLE * FROM zppt_sls_hist INTO @ls_old
      WHERE werks = @lv_werks AND matnr = @lv_matnr AND gjahr = @lv_gjahr.
    IF sy-subrc = 0.
      lv_ex   = abap_true.
      ls_hist = ls_old.
    ENDIF.

    ls_hist-werks = lv_werks.
    ls_hist-matnr = lv_matnr.
    ls_hist-gjahr = lv_gjahr.
    ls_hist-meins = lv_meins.

*   Columns 4 to 15 of the file hold M01 to M12, April first
    CLEAR lv_tot.
*BOC By Arnav on 31/08/26
    CLEAR lv_bad.
*EOC By Arnav on 31/08/26
    lv_i = 1.
    WHILE lv_i <= 12.

      lv_src = lv_i + 3.
      lv_fld = |M{ lv_i WIDTH = 2 PAD = '0' }|.

      UNASSIGN: <lv_in>, <lv_out>.
      ASSIGN COMPONENT lv_src OF STRUCTURE ls_raw  TO <lv_in>.
      ASSIGN COMPONENT lv_fld OF STRUCTURE ls_hist TO <lv_out>.

*BOC By Arnav on 31/08/26
*      IF <lv_in> IS ASSIGNED AND <lv_out> IS ASSIGNED.
*        PERFORM to_dec USING <lv_in> CHANGING lv_qty.
*        <lv_out> = lv_qty.
*        lv_tot   = lv_tot + lv_qty.
*      ENDIF.
*     A month cell that was not a number was loaded as a zero without a
*     word to the user. The row is rejected now and the column named.
      IF <lv_in> IS ASSIGNED AND <lv_out> IS ASSIGNED.
        PERFORM to_dec USING <lv_in> CHANGING lv_qty lv_ok.
        IF lv_ok = abap_false.
          lv_bad = lv_i.
          EXIT.
        ENDIF.
        <lv_out> = lv_qty.
        lv_tot   = lv_tot + lv_qty.
      ENDIF.
*EOC By Arnav on 31/08/26

      lv_i = lv_i + 1.
    ENDWHILE.

*BOC By Arnav on 31/08/26
    IF lv_bad > 0.
      lv_err = |Month column M{ lv_bad } is not a number|.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

    IF lv_tot = 0.
*BOC By Arnav on 31/08/26
*      lv_err = 'All twelve monthly figures are zero or not numeric'.
*     Not a number is reported on its own now, so this is only the
*     all zero case
      lv_err = 'All twelve monthly figures are zero'.
*EOC By Arnav on 31/08/26
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

    PERFORM stamp USING lv_ex CHANGING ls_hist-ernam ls_hist-erdat
                                       ls_hist-aenam ls_hist-aedat.

    IF p_test = abap_false.
      MODIFY zppt_sls_hist FROM @ls_hist.
      IF sy-subrc <> 0.
        lv_err = 'Database update failed'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
        CONTINUE.
      ENDIF.
    ENDIF.

    lv_txt = |Twelve months loaded, year total { lv_tot } { lv_meins }|.
    PERFORM log_ok USING lv_row lv_werks lv_matnr lv_per lv_ex lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& 5 and 6 - Business forecast given by sales, quarterly or monthly
*&---------------------------------------------------------------------*
FORM do_business USING pv_mode TYPE char1.

  DATA: ls_raw   TYPE ty_raw,
        ls_qt    TYPE zppt_fcst_qt,
        ls_mn    TYPE zppt_fcst_mn,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_matnr TYPE matnr,
        lv_pi    TYPE i,
        lv_year  TYPE i,
        lv_gjahr TYPE gjahr,
        lv_qtr   TYPE zde_quarter,
        lv_poper TYPE poper,
        lv_qty   TYPE zde_fcst_qty,
        lv_total TYPE zde_fcst_qty,
        lv_ex    TYPE abap_bool,
        lv_err   TYPE string,
        lv_txt   TYPE string,
        lv_per   TYPE char12.

*BOC By Arnav on 31/08/26
  DATA: ls_row  TYPE ty_row,
        lv_ok   TYPE abap_bool,
        lv_ltab TYPE rstable-tabname,
        lv_lkey TYPE rstable-varkey.

* The material is column 1 and the plant column 2 in these two layouts
  PERFORM prefetch USING 2 1 abap_true.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_material USING ls_raw-f01 CHANGING lv_matnr.
*    PERFORM to_plant    USING ls_raw-f02 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_matnr, lv_err, lv_per.

    PERFORM to_material USING ls_raw-f01 CHANGING lv_matnr.
    PERFORM to_plant    USING ls_raw-f02 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM period_text USING pv_mode ls_raw-f03 CHANGING lv_per.

    PERFORM check_marc USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*   A material taken out of forecasting still accepted a business
*   forecast, which the generation run then ignored
    PERFORM check_excl USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*    PERFORM to_int USING ls_raw-f03 CHANGING lv_pi.
    PERFORM to_int USING ls_raw-f03 CHANGING lv_pi lv_ok.
*EOC By Arnav on 31/08/26
    PERFORM check_period USING pv_mode lv_pi CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*    PERFORM to_int USING ls_raw-f04 CHANGING lv_year.
    PERFORM to_int USING ls_raw-f04 CHANGING lv_year lv_ok.
*EOC By Arnav on 31/08/26
    IF lv_year < 1900 OR lv_year > 2999.
      lv_err = 'Year must be the four digit year the financial year starts in'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
    lv_gjahr = lv_year.

*BOC By Arnav on 31/08/26
*    PERFORM to_dec USING ls_raw-f05 CHANGING lv_qty.
*   An empty cell, or a cell that was not a number, was written as a
*   zero business forecast and reported back as created
    IF ls_raw-f05 IS INITIAL.
      lv_err = 'Sales forecast quantity is mandatory'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

    PERFORM to_dec USING ls_raw-f05 CHANGING lv_qty lv_ok.
    IF lv_ok = abap_false.
      lv_err = 'Sales forecast quantity is not a number'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    IF lv_qty < 0.
      lv_err = 'Sales forecast quantity cannot be negative'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*   The plant and year are locked for the run before the row is read,
*   so an upload and a second upload cannot read the same row and write
*   it back over one another
    IF pv_mode = 'Q'.
      lv_ltab = 'ZPPT_FCST_QT'.
    ELSE.
      lv_ltab = 'ZPPT_FCST_MN'.
    ENDIF.
    CONCATENATE lv_werks lv_gjahr INTO lv_lkey SEPARATED BY '/'.

    PERFORM lock_row USING lv_ltab lv_lkey CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

    CLEAR lv_ex.

    IF pv_mode = 'Q'.

      lv_qtr = lv_pi.

*     The whole row is read and written back, so a business forecast
*     loaded onto an already generated forecast changes only that one
*     column and leaves the calculated figures untouched
      CLEAR ls_qt.
      SELECT SINGLE * FROM zppt_fcst_qt INTO @ls_qt
        WHERE werks = @lv_werks AND matnr = @lv_matnr
          AND gjahr = @lv_gjahr AND quarter = @lv_qtr.
      IF sy-subrc = 0.
        lv_ex = abap_true.
      ELSE.
        CLEAR ls_qt.
        ls_qt-werks   = lv_werks.
        ls_qt-matnr   = lv_matnr.
        ls_qt-gjahr   = lv_gjahr.
        ls_qt-quarter = lv_qtr.
      ENDIF.

      ls_qt-bus_fcst = lv_qty.
      PERFORM final_qty CHANGING ls_qt-fcst_qty ls_qt-bus_fcst
                                 ls_qt-bus_fcst_add ls_qt-final_qty.
      PERFORM stamp USING lv_ex CHANGING ls_qt-ernam ls_qt-erdat
                                         ls_qt-aenam ls_qt-aedat.

      IF p_test = abap_false.
        MODIFY zppt_fcst_qt FROM @ls_qt.
        IF sy-subrc <> 0.
          lv_err = 'Database update failed'.
          PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
          CONTINUE.
        ENDIF.
      ENDIF.

      lv_total = ls_qt-final_qty + ls_qt-bus_fcst_add.
      lv_txt = |Business forecast { lv_qty }, final quantity now { lv_total }|.

    ELSE.

      lv_poper = lv_pi.

      CLEAR ls_mn.
      SELECT SINGLE * FROM zppt_fcst_mn INTO @ls_mn
        WHERE werks = @lv_werks AND matnr = @lv_matnr
          AND gjahr = @lv_gjahr AND period = @lv_poper.
      IF sy-subrc = 0.
        lv_ex = abap_true.
      ELSE.
        CLEAR ls_mn.
        ls_mn-werks  = lv_werks.
        ls_mn-matnr  = lv_matnr.
        ls_mn-gjahr  = lv_gjahr.
        ls_mn-period = lv_poper.
      ENDIF.

      ls_mn-bus_fcst = lv_qty.
      PERFORM final_qty CHANGING ls_mn-fcst_qty ls_mn-bus_fcst
                                 ls_mn-bus_fcst_add ls_mn-final_qty.
      PERFORM stamp USING lv_ex CHANGING ls_mn-ernam ls_mn-erdat
                                         ls_mn-aenam ls_mn-aedat.

      IF p_test = abap_false.
        MODIFY zppt_fcst_mn FROM @ls_mn.
        IF sy-subrc <> 0.
          lv_err = 'Database update failed'.
          PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
          CONTINUE.
        ENDIF.
      ENDIF.

      lv_total = ls_mn-final_qty + ls_mn-bus_fcst_add.
      lv_txt = |Business forecast { lv_qty }, final quantity now { lv_total }|.

    ENDIF.

    PERFORM log_ok USING lv_row lv_werks lv_matnr lv_per lv_ex lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& 7 and 8 - Additional or reduced quantity with a reason
*&---------------------------------------------------------------------*
FORM do_change USING pv_mode TYPE char1.

  DATA: ls_raw   TYPE ty_raw,
        ls_qt    TYPE zppt_fcst_qt,
        ls_mn    TYPE zppt_fcst_mn,
        lv_row   TYPE i,
        lv_werks TYPE werks_d,
        lv_matnr TYPE matnr,
        lv_pi    TYPE i,
        lv_year  TYPE i,
        lv_gjahr TYPE gjahr,
        lv_qtr   TYPE zde_quarter,
        lv_poper TYPE poper,
        lv_qty   TYPE zde_fcst_qty,
        lv_total TYPE zde_fcst_qty,
        lv_rsn   TYPE zde_fcst_reason,
        lv_err   TYPE string,
        lv_txt   TYPE string,
        lv_tmp   TYPE char40,
        lv_per   TYPE char12,
        lv_yes   TYPE abap_bool.

*BOC By Arnav on 31/08/26
  DATA: ls_row  TYPE ty_row,
        lv_ok   TYPE abap_bool,
        lv_prev TYPE string,
        lv_ltab TYPE rstable-tabname,
        lv_lkey TYPE rstable-varkey.

  PERFORM prefetch USING 2 1 abap_true.
*EOC By Arnav on 31/08/26

  lv_yes = abap_true.

*BOC By Arnav on 31/08/26
*  LOOP AT gt_raw INTO ls_raw.
*
*    lv_row = sy-tabix.
*    PERFORM to_material USING ls_raw-f01 CHANGING lv_matnr.
*    PERFORM to_plant    USING ls_raw-f02 CHANGING lv_werks.
  LOOP AT gt_row INTO ls_row.

    lv_row = ls_row-srow.
    ls_raw = ls_row-data.
    CLEAR: lv_matnr, lv_err, lv_per.

    PERFORM to_material USING ls_raw-f01 CHANGING lv_matnr.
    PERFORM to_plant    USING ls_raw-f02 CHANGING lv_werks lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26
    PERFORM period_text USING pv_mode ls_raw-f03 CHANGING lv_per.

    PERFORM check_marc USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
    PERFORM check_excl USING lv_werks lv_matnr CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

*BOC By Arnav on 31/08/26
*    PERFORM to_int USING ls_raw-f03 CHANGING lv_pi.
    PERFORM to_int USING ls_raw-f03 CHANGING lv_pi lv_ok.
*EOC By Arnav on 31/08/26
    PERFORM check_period USING pv_mode lv_pi CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*    PERFORM to_int USING ls_raw-f04 CHANGING lv_year.
    PERFORM to_int USING ls_raw-f04 CHANGING lv_year lv_ok.
*EOC By Arnav on 31/08/26
    IF lv_year < 1900 OR lv_year > 2999.
      lv_err = 'Year must be the four digit year the financial year starts in'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
    lv_gjahr = lv_year.

    lv_tmp = ls_raw-f06.
    CONDENSE lv_tmp.
    lv_rsn = lv_tmp.
    IF lv_rsn IS INITIAL.
      lv_err = 'Reason is mandatory when the forecast is changed'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
*    PERFORM to_dec USING ls_raw-f05 CHANGING lv_qty.
*    IF lv_qty = 0.
*      lv_err = 'Change quantity is zero or not numeric, nothing to apply'.
*   Not a number and a genuine zero were reported with the same
*   sentence, which sent the user looking for the wrong thing
    PERFORM to_dec USING ls_raw-f05 CHANGING lv_qty lv_ok.
    IF lv_ok = abap_false.
      lv_err = 'Change quantity is not a number'.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

    IF lv_qty = 0.
      lv_err = 'Change quantity is zero, there is nothing to apply'.
*EOC By Arnav on 31/08/26
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.

*BOC By Arnav on 31/08/26
    IF pv_mode = 'Q'.
      lv_ltab = 'ZPPT_FCST_QT'.
    ELSE.
      lv_ltab = 'ZPPT_FCST_MN'.
    ENDIF.
    CONCATENATE lv_werks lv_gjahr INTO lv_lkey SEPARATED BY '/'.

    PERFORM lock_row USING lv_ltab lv_lkey CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
      CONTINUE.
    ENDIF.
*EOC By Arnav on 31/08/26

*   A change adjusts a forecast that already exists. If it is not there
*   the row is rejected rather than a bare change record being created.
    IF pv_mode = 'Q'.

      lv_qtr = lv_pi.

      CLEAR ls_qt.
      SELECT SINGLE * FROM zppt_fcst_qt INTO @ls_qt
        WHERE werks = @lv_werks AND matnr = @lv_matnr
          AND gjahr = @lv_gjahr AND quarter = @lv_qtr.
      IF sy-subrc <> 0.
        lv_err = 'No quarterly forecast has been saved for this plant, material and quarter'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
        CONTINUE.
      ENDIF.

*BOC By Arnav on 31/08/26
*     A change REPLACES the additional quantity, it does not add to it,
*     so loading the same file twice is harmless. That also means a
*     change already standing against the period is overwritten, which
*     used to happen silently. The log says so now.
* ASSUMPTION: replace, not accumulate. Two separate changes for one
* period therefore keep only the last quantity and reason. Confirm with
* the functional team before the first live load.
      CLEAR lv_prev.
      IF ls_qt-bus_fcst_add <> 0 AND ls_qt-bus_fcst_add <> lv_qty.
        lv_prev = |, previous change { ls_qt-bus_fcst_add } replaced|.
      ENDIF.
*EOC By Arnav on 31/08/26

      ls_qt-bus_fcst_add = lv_qty.
      ls_qt-reason       = lv_rsn.
      PERFORM final_qty CHANGING ls_qt-fcst_qty ls_qt-bus_fcst
                                 ls_qt-bus_fcst_add ls_qt-final_qty.

*     FINAL_QTY no longer carries the change, so the guard tests the
*     total the change actually moves
      lv_total = ls_qt-final_qty + ls_qt-bus_fcst_add.
      IF lv_total < 0.
        lv_err = 'The reduction is larger than the forecast, the final quantity would be negative'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
        CONTINUE.
      ENDIF.

      PERFORM stamp USING lv_yes CHANGING ls_qt-ernam ls_qt-erdat
                                          ls_qt-aenam ls_qt-aedat.

      IF p_test = abap_false.
        MODIFY zppt_fcst_qt FROM @ls_qt.
        IF sy-subrc <> 0.
          lv_err = 'Database update failed'.
          PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
          CONTINUE.
        ENDIF.
      ENDIF.

*BOC By Arnav on 31/08/26
*      lv_txt = |Change { lv_qty }, final quantity now { lv_total }, reason { lv_rsn }|.
      lv_txt = |Change { lv_qty }, final quantity now { lv_total }, | &&
               |reason { lv_rsn }{ lv_prev }|.
*EOC By Arnav on 31/08/26

    ELSE.

      lv_poper = lv_pi.

      CLEAR ls_mn.
      SELECT SINGLE * FROM zppt_fcst_mn INTO @ls_mn
        WHERE werks = @lv_werks AND matnr = @lv_matnr
          AND gjahr = @lv_gjahr AND period = @lv_poper.
      IF sy-subrc <> 0.
        lv_err = 'No monthly forecast has been saved for this plant, material and month'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
        CONTINUE.
      ENDIF.

*BOC By Arnav on 31/08/26
      CLEAR lv_prev.
      IF ls_mn-bus_fcst_add <> 0 AND ls_mn-bus_fcst_add <> lv_qty.
        lv_prev = |, previous change { ls_mn-bus_fcst_add } replaced|.
      ENDIF.
*EOC By Arnav on 31/08/26

      ls_mn-bus_fcst_add = lv_qty.
      ls_mn-reason       = lv_rsn.
      PERFORM final_qty CHANGING ls_mn-fcst_qty ls_mn-bus_fcst
                                 ls_mn-bus_fcst_add ls_mn-final_qty.

      lv_total = ls_mn-final_qty + ls_mn-bus_fcst_add.
      IF lv_total < 0.
        lv_err = 'The reduction is larger than the forecast, the final quantity would be negative'.
        PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
        CONTINUE.
      ENDIF.

      PERFORM stamp USING lv_yes CHANGING ls_mn-ernam ls_mn-erdat
                                          ls_mn-aenam ls_mn-aedat.

      IF p_test = abap_false.
        MODIFY zppt_fcst_mn FROM @ls_mn.
        IF sy-subrc <> 0.
          lv_err = 'Database update failed'.
          PERFORM log USING lv_row lv_werks lv_matnr lv_per gc_err lv_err.
          CONTINUE.
        ENDIF.
      ENDIF.

*BOC By Arnav on 31/08/26
*      lv_txt = |Change { lv_qty }, final quantity now { lv_total }, reason { lv_rsn }|.
      lv_txt = |Change { lv_qty }, final quantity now { lv_total }, | &&
               |reason { lv_rsn }{ lv_prev }|.
*EOC By Arnav on 31/08/26

    ENDIF.

*   A change always adjusts an existing forecast, so it is never a create
    PERFORM log_ok USING lv_row lv_werks lv_matnr lv_per lv_yes lv_txt.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& FINAL_QTY must be worked out exactly as the report works it out, or
*& an uploaded row and a generated row would disagree.
*&
*& The FS compares the generated forecast with the business forecast and
*& takes the higher of the two - "Compare forecast and business
*& forecast", sheet 3 row 57, confirmed by the worked example where
*& 1200 against 4000 gives 4000. The additional plan quantity is NOT
*& part of it; it is added afterwards to give the second final column.
*&
*& This previously added all three together, which inflated every
*& uploaded row.
*&---------------------------------------------------------------------*
FORM final_qty CHANGING cv_gen TYPE zde_fcst_qty
                        cv_bus TYPE zde_fcst_qty
                        cv_add TYPE zde_fcst_qty
                        cv_fin TYPE zde_fcst_qty.

  cv_fin = nmax( val1 = cv_gen val2 = cv_bus ).

ENDFORM.


*&---------------------------------------------------------------------*
FORM stamp USING pv_exists TYPE abap_bool
           CHANGING cv_ernam TYPE any
                    cv_erdat TYPE any
                    cv_aenam TYPE any
                    cv_aedat TYPE any.

  IF pv_exists = abap_false OR cv_ernam IS INITIAL.
    cv_ernam = sy-uname.
    cv_erdat = sy-datum.
  ENDIF.

  cv_aenam = sy-uname.
  cv_aedat = sy-datum.

ENDFORM.


*&---------------------------------------------------------------------*
FORM check_period USING pv_mode TYPE char1
                        pv_per  TYPE i
                  CHANGING pv_err TYPE string.

  CLEAR pv_err.

  IF pv_mode = 'Q'.
    IF pv_per < 1 OR pv_per > 4.
      pv_err = 'Quarter must be 1 to 4, where 1 is April to June'.
    ENDIF.
  ELSE.
    IF pv_per < 1 OR pv_per > 12.
      pv_err = 'Month must be 1 to 12, where 1 is April and 12 is March'.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& The period is shown on the log in words so the user is not left
*& working out why month 1 means April
*&---------------------------------------------------------------------*
FORM period_text USING pv_mode TYPE char1
                       pv_in   TYPE any
                 CHANGING cv_txt TYPE char12.

  CONSTANTS lc_mon TYPE char36
    VALUE 'AprMayJunJulAugSepOctNovDecJanFebMar'.

  DATA: lv_i   TYPE i,
        lv_off TYPE i,
        lv_nam TYPE char3,
        lv_num TYPE char2.

*BOC By Arnav on 31/08/26
  DATA lv_ok TYPE abap_bool.
*EOC By Arnav on 31/08/26

  CLEAR cv_txt.

*BOC By Arnav on 31/08/26
*  PERFORM to_int USING pv_in CHANGING lv_i.
* An unreadable period simply leaves the heading blank here, the row
* itself is rejected by CHECK_PERIOD
  PERFORM to_int USING pv_in CHANGING lv_i lv_ok.
*EOC By Arnav on 31/08/26

  IF pv_mode = 'Q'.
    IF lv_i >= 1 AND lv_i <= 4.
      lv_num = lv_i.
      CONDENSE lv_num.
      CONCATENATE 'Q' lv_num INTO cv_txt.
    ENDIF.
    RETURN.
  ENDIF.

  IF lv_i >= 1 AND lv_i <= 12.
    lv_off = ( lv_i - 1 ) * 3.
    lv_nam = lc_mon+lv_off(3).
    lv_num = lv_i.
    CONDENSE lv_num.
    CONCATENATE 'M' lv_num '-' lv_nam INTO cv_txt.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
FORM check_marc USING pv_werks TYPE werks_d
                      pv_matnr TYPE matnr
                CHANGING pv_err TYPE string.

*BOC By Arnav on 31/08/26
*  DATA: lv_hit TYPE matnr,
*        lv_ok  TYPE abap_bool.
*EOC By Arnav on 31/08/26

  CLEAR pv_err.

  IF pv_werks IS INITIAL OR pv_matnr IS INITIAL.
    pv_err = 'Plant and material are both mandatory'.
    RETURN.
  ENDIF.

*BOC By Arnav on 31/08/26
*  SELECT SINGLE matnr FROM marc INTO @lv_hit
*    WHERE werks = @pv_werks AND matnr = @pv_matnr.
*
*  IF sy-subrc <> 0.
*    pv_err = |Material { pv_matnr } is not extended to plant { pv_werks }|.
*    RETURN.
*  ENDIF.
*
*  lv_ok = zcl_pp_fcst_util=>check_authority( iv_werks = pv_werks
*                                             iv_actvt = '02' ).
*  IF lv_ok = abap_false.
*    pv_err = |No authorisation to maintain forecast data for plant { pv_werks }|.
*  ENDIF.
*
* MARC was read once per row and the authorisation object was checked
* once per row as well, for what is in practice a handful of plants.
* Both now come out of the buffers PREFETCH fills in one pass.
  READ TABLE gt_marc TRANSPORTING NO FIELDS
       WITH TABLE KEY werks = pv_werks matnr = pv_matnr.
  IF sy-subrc <> 0.
    pv_err = |Material { pv_matnr } is not extended to plant { pv_werks }|.
    RETURN.
  ENDIF.

  PERFORM check_auth USING pv_werks CHANGING pv_err.
*EOC By Arnav on 31/08/26

ENDFORM.


*&---------------------------------------------------------------------*
*BOC By Arnav on 31/08/26
*FORM to_plant USING pv_in TYPE any CHANGING cv_werks TYPE werks_d.
*
** Plant carries no conversion exit, so it is taken as typed
*  CLEAR cv_werks.
*  cv_werks = pv_in.
*  CONDENSE cv_werks.
*
*ENDFORM.
*
* The 40 character cell was assigned straight to the 4 character plant,
* so it was cut to four characters BEFORE the CONDENSE ran. A cell
* holding " 1001" became " 100" and then "100", and the row was
* rejected against a plant the user never typed. The cell is condensed
* at full width first, and one longer than a plant code is refused
* rather than silently shortened.
FORM to_plant USING pv_in TYPE any
              CHANGING cv_werks TYPE werks_d
                       cv_err   TYPE string.

  DATA lv_in TYPE char40.

* Plant carries no conversion exit, so it is taken as typed
  CLEAR: cv_werks, cv_err.

  lv_in = pv_in.
  CONDENSE lv_in.

  IF lv_in IS INITIAL.
    RETURN.
  ENDIF.

  IF strlen( lv_in ) > 4.
    cv_err = |{ lv_in } is longer than a plant code|.
    RETURN.
  ENDIF.

  cv_werks = lv_in.

ENDFORM.
*EOC By Arnav on 31/08/26


*&---------------------------------------------------------------------*
FORM to_material USING pv_in TYPE any CHANGING cv_matnr TYPE matnr.

  DATA lv_in TYPE char40.

  CLEAR cv_matnr.

  lv_in = pv_in.
  CONDENSE lv_in.
  CHECK lv_in IS NOT INITIAL.

* Entered without leading zeros in the spreadsheet, stored padded
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING  input        = lv_in
    IMPORTING  output       = cv_matnr
    EXCEPTIONS length_error = 1
               OTHERS       = 2.

  IF sy-subrc <> 0.
    cv_matnr = lv_in.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*BOC By Arnav on 31/08/26
*FORM to_dec USING pv_in TYPE any CHANGING cv_out TYPE any.
*
*  DATA lv_in TYPE string.
*
*  CLEAR cv_out.
*
*  lv_in = pv_in.
*  CONDENSE lv_in NO-GAPS.
*  CHECK lv_in IS NOT INITIAL.
*
** Thousand separators from a spreadsheet export are dropped
*  REPLACE ALL OCCURRENCES OF ',' IN lv_in WITH ''.
*
*  TRY.
*      cv_out = lv_in.
*    CATCH cx_sy_conversion_no_number.
*      CLEAR cv_out.
*  ENDTRY.
*
*ENDFORM.
*
* A cell that was not a number came back as a silent zero, was written
* to the database as a zero quantity and reported to the user as a
* successful load. The caller is told now whether the cell could be
* read. An empty cell is a valid zero and is reported as readable - the
* callers that need a figure check the cell for empty themselves.
FORM to_dec USING pv_in TYPE any
            CHANGING cv_out TYPE any
                     cv_ok  TYPE abap_bool.

  DATA lv_in TYPE string.

  CLEAR: cv_out, cv_ok.

  lv_in = pv_in.
  CONDENSE lv_in NO-GAPS.

  IF lv_in IS INITIAL.
    cv_ok = abap_true.
    RETURN.
  ENDIF.

* Thousand separators from a spreadsheet export are dropped
  REPLACE ALL OCCURRENCES OF ',' IN lv_in WITH ''.

  TRY.
      cv_out = lv_in.
      cv_ok  = abap_true.
    CATCH cx_sy_conversion_no_number.
      CLEAR cv_out.
      cv_ok = abap_false.
  ENDTRY.

ENDFORM.
*EOC By Arnav on 31/08/26


*&---------------------------------------------------------------------*
*BOC By Arnav on 31/08/26
*FORM to_int USING pv_in TYPE any CHANGING cv_out TYPE i.
*
*  DATA lv_in TYPE string.
*
*  CLEAR cv_out.
*
*  lv_in = pv_in.
*  CONDENSE lv_in NO-GAPS.
*  CHECK lv_in IS NOT INITIAL.
*
*  TRY.
*      cv_out = lv_in.
*    CATCH cx_sy_conversion_no_number.
*      CLEAR cv_out.
*  ENDTRY.
*
*ENDFORM.
FORM to_int USING pv_in TYPE any
            CHANGING cv_out TYPE i
                     cv_ok  TYPE abap_bool.

  DATA lv_in TYPE string.

  CLEAR: cv_out, cv_ok.

  lv_in = pv_in.
  CONDENSE lv_in NO-GAPS.

  IF lv_in IS INITIAL.
    cv_ok = abap_true.
    RETURN.
  ENDIF.

  TRY.
      cv_out = lv_in.
      cv_ok  = abap_true.
    CATCH cx_sy_conversion_no_number.
      CLEAR cv_out.
      cv_ok = abap_false.
  ENDTRY.

ENDFORM.
*EOC By Arnav on 31/08/26


*&---------------------------------------------------------------------*
FORM log USING pv_row    TYPE i
               pv_werks  TYPE any
               pv_matnr  TYPE any
               pv_period TYPE any
               pv_action TYPE char14
               pv_text   TYPE any.

  DATA ls_log TYPE ty_log.

  CLEAR ls_log.
  ls_log-row     = pv_row.
  ls_log-werks   = pv_werks.
  ls_log-matnr   = pv_matnr.
  ls_log-period  = pv_period.
  ls_log-action  = pv_action.
  ls_log-message = pv_text.

  IF pv_action = gc_err.
    ls_log-light = '1'.
    g_err = g_err + 1.
  ELSEIF pv_action = gc_chg OR pv_action = gc_tchg.
    ls_log-light = '2'.
    g_chg = g_chg + 1.
  ELSE.
    ls_log-light = '3'.
    g_new = g_new + 1.
  ENDIF.

  APPEND ls_log TO gt_log.

ENDFORM.


*&---------------------------------------------------------------------*
FORM log_ok USING pv_row    TYPE i
                  pv_werks  TYPE any
                  pv_matnr  TYPE any
                  pv_period TYPE any
                  pv_exists TYPE abap_bool
                  pv_text   TYPE any.

  DATA: lv_action TYPE char14,
        lv_text   TYPE string.

  IF p_test = 'X'.
    IF pv_exists = abap_true.
      lv_action = gc_tchg.
    ELSE.
      lv_action = gc_tnew.
    ENDIF.
  ELSE.
    IF pv_exists = abap_true.
      lv_action = gc_chg.
    ELSE.
      lv_action = gc_new.
    ENDIF.
  ENDIF.

  lv_text = pv_text.

  PERFORM log USING pv_row pv_werks pv_matnr pv_period lv_action lv_text.

ENDFORM.


*&---------------------------------------------------------------------*
FORM display_log.

  DATA: lo_alv  TYPE REF TO cl_salv_table,
        lo_cols TYPE REF TO cl_salv_columns_table,
        lv_head TYPE string,
        lv_n    TYPE char10,
        lv_c    TYPE char10,
        lv_e    TYPE char10,
        lv_ttl  TYPE lvc_title.

  lv_n = g_new. CONDENSE lv_n.
  lv_c = g_chg. CONDENSE lv_c.
  lv_e = g_err. CONDENSE lv_e.

  IF p_test = 'X'.
    CONCATENATE 'Test run, nothing saved:' lv_n 'would be created,' lv_c
                'would be changed,' lv_e 'rejected'
           INTO lv_head SEPARATED BY space.
  ELSE.
    CONCATENATE 'Upload finished:' lv_n 'created,' lv_c 'changed,' lv_e
                'rejected'
           INTO lv_head SEPARATED BY space.
  ENDIF.

  MESSAGE lv_head TYPE 'S'.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
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
      PERFORM txt USING lo_cols 'PERIOD'  'Period'.
      PERFORM txt USING lo_cols 'ACTION'  'Result'.
      PERFORM txt USING lo_cols 'MESSAGE' 'Detail'.

*     The detail column carries a whole sentence, so it is given room
*     up front instead of the user dragging it wider on every run
      TRY.
          lo_cols->get_column( 'MESSAGE' )->set_output_length( 60 ).
        CATCH cx_salv_not_found.
      ENDTRY.

      lv_ttl = lv_head.
      lo_alv->get_display_settings( )->set_list_header( lv_ttl ).

      lo_alv->display( ).

    CATCH cx_salv_msg.
      MESSAGE lv_head TYPE 'I'.
  ENDTRY.

ENDFORM.


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

* ALV picks WHICH of the three heading texts to draw from the column
* output length - the short one below 10 characters, the medium one
* below 20, the long one above that. A long heading on a narrow numeric
* column was therefore drawn from the short text and cut off. The width
* is set from the heading so the long text is chosen, and set_optimize
* then widens further where the data needs it.
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


*BOC By Arnav on 31/08/26
*&---------------------------------------------------------------------*
*& New routines added with the corrections of 31/08/26
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Plant and material existence, and the exclusion list, were read one
*& row at a time inside the processing loops. They are read once for the
*& whole file here instead. The plant and the material sit in different
*& columns depending on the upload type, so the caller says which.
*&---------------------------------------------------------------------*
FORM prefetch USING pv_pcol TYPE i
                    pv_mcol TYPE i
                    pv_excl TYPE abap_bool.

  DATA: ls_row TYPE ty_row,
        ls_key TYPE ty_key,
        lt_key TYPE STANDARD TABLE OF ty_key,
        lv_dum TYPE string.

  FIELD-SYMBOLS: <lv_p> TYPE any,
                 <lv_m> TYPE any.

  CLEAR: gt_marc, gt_excl, gt_auth, lt_key.

  LOOP AT gt_row INTO ls_row.

    UNASSIGN: <lv_p>, <lv_m>.
    ASSIGN COMPONENT pv_pcol OF STRUCTURE ls_row-data TO <lv_p>.
    ASSIGN COMPONENT pv_mcol OF STRUCTURE ls_row-data TO <lv_m>.
    CHECK <lv_p> IS ASSIGNED AND <lv_m> IS ASSIGNED.

*   Normalised exactly as the processing loop will normalise it, or the
*   buffer would be read with a key it does not hold
    CLEAR ls_key.
    PERFORM to_plant    USING <lv_p> CHANGING ls_key-werks lv_dum.
    PERFORM to_material USING <lv_m> CHANGING ls_key-matnr.

    CHECK ls_key-werks IS NOT INITIAL AND ls_key-matnr IS NOT INITIAL.
    APPEND ls_key TO lt_key.

  ENDLOOP.

* The SORT sits outside the loop and compares exactly the two fields
* the DELETE compares
  SORT lt_key BY werks matnr.
  DELETE ADJACENT DUPLICATES FROM lt_key COMPARING werks matnr.

  CHECK lt_key IS NOT INITIAL.

  SELECT werks, matnr FROM marc
    FOR ALL ENTRIES IN @lt_key
    WHERE werks = @lt_key-werks
      AND matnr = @lt_key-matnr
    INTO TABLE @gt_marc.

* Only the two forecast uploads care about the exclusion list. A
* category, a code change or a history row is still allowed for a
* material that is out of forecasting.
  CHECK pv_excl = abap_true.

  SELECT werks, matnr FROM zppt_mat_excl
    FOR ALL ENTRIES IN @lt_key
    WHERE werks = @lt_key-werks
      AND matnr = @lt_key-matnr
    INTO TABLE @gt_excl.

ENDFORM.


*&---------------------------------------------------------------------*
*& The authorisation object is checked once per plant, not once per row
*&---------------------------------------------------------------------*
FORM check_auth USING pv_werks TYPE werks_d
                CHANGING pv_err TYPE string.

  DATA ls_auth TYPE ty_auth.

  CLEAR pv_err.

  READ TABLE gt_auth INTO ls_auth WITH TABLE KEY werks = pv_werks.
  IF sy-subrc <> 0.
    CLEAR ls_auth.
    ls_auth-werks = pv_werks.
    ls_auth-ok    = zcl_pp_fcst_util=>check_authority( iv_werks = pv_werks
                                                       iv_actvt = '02' ).
    INSERT ls_auth INTO TABLE gt_auth.
  ENDIF.

  IF ls_auth-ok = abap_false.
    pv_err = |No authorisation to maintain forecast data for plant { pv_werks }|.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& A material taken out of forecasting still accepted a business
*& forecast and a forecast change, both of which the generation run then
*& ignored - the figures sat in the table doing nothing
*&---------------------------------------------------------------------*
FORM check_excl USING pv_werks TYPE werks_d
                      pv_matnr TYPE matnr
                CHANGING pv_err TYPE string.

  CLEAR pv_err.

  READ TABLE gt_excl TRANSPORTING NO FIELDS
       WITH TABLE KEY werks = pv_werks matnr = pv_matnr.
  IF sy-subrc = 0.
    pv_err = |Material { pv_matnr } is excluded from forecasting|.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& The unit of measure was stored exactly as typed. An entry that is not
*& a unit at all went in and only showed up later as a wrong or failed
*& tonnage conversion. The standard conversion exit both validates it
*& and turns the external entry into the internal code.
*&---------------------------------------------------------------------*
FORM to_uom USING pv_in TYPE any
            CHANGING cv_meins TYPE meins
                     cv_err   TYPE string.

  DATA lv_in TYPE char40.

  CLEAR: cv_meins, cv_err.

  lv_in = pv_in.
  CONDENSE lv_in.
  lv_in = to_upper( lv_in ).

  IF lv_in IS INITIAL.
    cv_err = 'Unit of measure is mandatory'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING  input          = lv_in
               language       = sy-langu
    IMPORTING  output         = cv_meins
    EXCEPTIONS unit_not_found = 1
               OTHERS         = 2.

  IF sy-subrc <> 0.
    CLEAR cv_meins.
    cv_err = |Unit of measure { lv_in } is not defined|.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Nothing locked anything. Two uploads, or an upload and the forecast
*& screen, could read the same row and write it back over each other.
*& The generic table lock is used so no new lock object is needed, at
*& plant level for the master data tables and at plant and year level
*& for the forecast tables.
*&
*& " ASSUMPTION: ZCL_PP_FCST does not take this lock yet, so this
*& protects one upload against another but not against a save from
*& ZFCST. The same call has to go into the class save for the cover to
*& be complete.
*&---------------------------------------------------------------------*
FORM lock_row USING pv_tab TYPE any
                    pv_key TYPE any
              CHANGING pv_err TYPE string.

  DATA: ls_lock TYPE ty_lock,
        lv_tab  TYPE rstable-tabname,
        lv_key  TYPE rstable-varkey.

  CLEAR pv_err.

* A test run writes nothing, so it takes nothing away from anybody else
  IF p_test = 'X'.
    RETURN.
  ENDIF.

  lv_tab = pv_tab.
  lv_key = pv_key.

* The lock is taken once per table and key for the whole run. The same
* key appears on many rows of one file and the lock table is a limited
* resource, so the outcome is remembered instead of the enqueue server
* being asked again.
  READ TABLE gt_lock INTO ls_lock
       WITH TABLE KEY tabname = lv_tab varkey = lv_key.
  IF sy-subrc = 0.
    IF ls_lock-ok = abap_false.
      CONCATENATE 'Being loaded by another user:' lv_key
             INTO pv_err SEPARATED BY space.
    ENDIF.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING  mode_rstable   = 'E'
               tabname        = lv_tab
               varkey         = lv_key
               _scope         = '1'
    EXCEPTIONS foreign_lock   = 1
               system_failure = 2
               OTHERS         = 3.

  CLEAR ls_lock.
  ls_lock-tabname = lv_tab.
  ls_lock-varkey  = lv_key.

  IF sy-subrc = 0.
    ls_lock-ok = abap_true.
  ELSE.
    ls_lock-ok = abap_false.
    CONCATENATE 'Being loaded by another user:' lv_key
           INTO pv_err SEPARATED BY space.
  ENDIF.

  INSERT ls_lock INTO TABLE gt_lock.

ENDFORM.


*&---------------------------------------------------------------------*
*& _SCOPE 1 keeps the lock past COMMIT WORK, so it is given back here.
*& This report holds no other lock, so releasing all of them is safe.
*&---------------------------------------------------------------------*
FORM unlock_all.

  IF p_test = 'X'.
    RETURN.
  ENDIF.

  CHECK gt_lock IS NOT INITIAL.

  CALL FUNCTION 'DEQUEUE_ALL'.

  CLEAR gt_lock.

ENDFORM.
*EOC By Arnav on 31/08/26
