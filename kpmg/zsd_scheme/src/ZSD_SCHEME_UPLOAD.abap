*&---------------------------------------------------------------------*
*& Report        ZSD_SCHEME_UPLOAD
*& Transaction   ZSCHM_UPL
*& Package       ZSD_SCHEME
*& Description   Scheme (Pipes) - mass create and change
*&
*& Created by    Arnav Johri
*& Reference     FS "Scheme - Pipes" V.01 10.08.2026, assumptions A38-A40
*&
*& Two linked tab-delimited files (A38). A single flat row cannot carry
*& "multiple material groups with include / exclude", so the header file
*& and the range file are joined on a reference key supplied by the user.
*&
*&   Header file   REFKEY | SCHEME_NO | TYPE | VKORG | VTWEG | SPART |
*&                 CAT | VALID_FROM | VALID_TO | EARLY_BIRD | CASCADING |
*&                 DESCR | TARGET_VAL | TARGET_QTY | MEINS | SCHEME_PCT |
*&                 PAR_CHILD | EB_DATE_FR | EB_DATE_TO | EB_TGT_TYP |
*&                 EB_TARGET | EB_PCT | TEXT
*&
*&   Range file    REFKEY | FIELDNAME | SIGN | OPTI | LOW | HIGH
*&
*& SCHEME_NO is left blank to create; filled to change an existing scheme.
*& All validation is delegated to ZCL_SD_SCHEME so that the upload and the
*& online transaction can never diverge (A39). Uploaded schemes are always
*& created in status New - release stays a manual action (A40).
*&---------------------------------------------------------------------*
REPORT zsd_scheme_upload MESSAGE-ID zsd_scheme.

TYPES: BEGIN OF ty_head_file,
         refkey     TYPE char10,
         scheme_no  TYPE char10,
         type       TYPE char1,
         vkorg      TYPE char4,
         vtweg      TYPE char2,
         spart      TYPE char2,
         cat        TYPE char1,
         valid_from TYPE char10,
         valid_to   TYPE char10,
         early_bird TYPE char1,
         cascading  TYPE char1,
         descr      TYPE char60,
         target_val TYPE char20,
         target_qty TYPE char20,
         meins      TYPE char3,
         scheme_pct TYPE char10,
         par_child  TYPE char1,
         eb_date_fr TYPE char10,
         eb_date_to TYPE char10,
         eb_tgt_typ TYPE char1,
         eb_target  TYPE char20,
         eb_pct     TYPE char10,
         text       TYPE char255,
       END OF ty_head_file,

       BEGIN OF ty_rng_file,
         refkey    TYPE char10,
         fieldname TYPE char20,
         sign      TYPE char1,
         opti      TYPE char2,
         low       TYPE char40,
         high      TYPE char40,
       END OF ty_rng_file,

       BEGIN OF ty_log,
         refkey    TYPE char10,
         scheme_no TYPE zde_schm_no,
         type      TYPE bapi_mtype,
         light     TYPE char1,
         message   TYPE char220,
       END OF ty_log.

DATA: gt_head TYPE STANDARD TABLE OF ty_head_file,
      gt_rng  TYPE STANDARD TABLE OF ty_rng_file,
      gt_log  TYPE STANDARD TABLE OF ty_log.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_fileh TYPE localfile OBLIGATORY,
            p_filer TYPE localfile OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_head  AS CHECKBOX DEFAULT abap_true,   "files contain a header row
            p_test  AS CHECKBOX DEFAULT abap_true.   "validate only, save nothing
SELECTION-SCREEN END OF BLOCK b2.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fileh.
  PERFORM f4_file CHANGING p_fileh.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filer.
  PERFORM f4_file CHANGING p_filer.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM upload_files.
  IF gt_head IS INITIAL.
    MESSAGE s029 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  PERFORM process.
  PERFORM display_log.


*&---------------------------------------------------------------------*
FORM f4_file CHANGING cv_file TYPE localfile.

  DATA: lt_file TYPE filetable,
        lv_rc   TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING  file_filter  = |Text (*.txt)\|*.txt\|CSV (*.csv)\|*.csv\|All (*.*)\|*.*\||
    CHANGING   file_table   = lt_file
               rc           = lv_rc
    EXCEPTIONS OTHERS       = 1 ).

  IF sy-subrc = 0 AND lv_rc > 0.
    cv_file = VALUE #( lt_file[ 1 ]-filename OPTIONAL ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM upload_files.

  CLEAR: gt_head, gt_rng.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING  filename                = CONV string( p_fileh )
               filetype                = 'ASC'
               has_field_separator     = abap_true
    CHANGING   data_tab                = gt_head
    EXCEPTIONS file_open_error         = 1
               file_read_error         = 2
               OTHERS                  = 3 ).

  IF sy-subrc <> 0.
    MESSAGE e030 WITH p_fileh.
  ENDIF.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING  filename                = CONV string( p_filer )
               filetype                = 'ASC'
               has_field_separator     = abap_true
    CHANGING   data_tab                = gt_rng
    EXCEPTIONS file_open_error         = 1
               file_read_error         = 2
               OTHERS                  = 3 ).

  IF sy-subrc <> 0.
    MESSAGE e030 WITH p_filer.
  ENDIF.

  IF p_head = abap_true.
    DELETE gt_head INDEX 1.
    DELETE gt_rng  INDEX 1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& One scheme per header row. Ranges are attached by reference key.
*&---------------------------------------------------------------------*
FORM process.

  DATA: lv_ok  TYPE i,
        lv_err TYPE i.

  SORT gt_rng BY refkey.

  LOOP AT gt_head INTO DATA(ls_head).

    DATA(lv_row) = sy-tabix.

    IF ls_head-refkey IS INITIAL.
      PERFORM add_log USING ls_head-refkey space 'E'
                            |Row { lv_row }: reference key is missing|.
      lv_err = lv_err + 1.
      CONTINUE.
    ENDIF.

    DATA(lo_scheme) = NEW zcl_sd_scheme(
      iv_mode = COND #( WHEN ls_head-scheme_no IS INITIAL
                        THEN zcl_sd_scheme=>gc_mode-create
                        ELSE zcl_sd_scheme=>gc_mode-change ) ).

    DATA lt_msg TYPE bapiret2_t.
    CLEAR lt_msg.

    " External values converted once, up front
    DATA: lv_val_fr TYPE dats,
          lv_val_to TYPE dats,
          lv_eb_fr  TYPE dats,
          lv_eb_to  TYPE dats,
          lv_tgt_v  TYPE zsdt_schm_hdr-target_val,
          lv_tgt_q  TYPE zsdt_schm_hdr-target_qty,
          lv_pct    TYPE zsdt_schm_hdr-scheme_pct,
          lv_eb_tgt TYPE zsdt_schm_hdr-eb_target,
          lv_eb_pct TYPE zsdt_schm_hdr-eb_pct.

    PERFORM date_conv   USING ls_head-valid_from CHANGING lv_val_fr.
    PERFORM date_conv   USING ls_head-valid_to   CHANGING lv_val_to.
    PERFORM date_conv   USING ls_head-eb_date_fr CHANGING lv_eb_fr.
    PERFORM date_conv   USING ls_head-eb_date_to CHANGING lv_eb_to.
    PERFORM amount_conv USING ls_head-target_val CHANGING lv_tgt_v.
    PERFORM amount_conv USING ls_head-target_qty CHANGING lv_tgt_q.
    PERFORM amount_conv USING ls_head-scheme_pct CHANGING lv_pct.
    PERFORM amount_conv USING ls_head-eb_target  CHANGING lv_eb_tgt.
    PERFORM amount_conv USING ls_head-eb_pct     CHANGING lv_eb_pct.

    "--- create or read ------------------------------------------------
    IF ls_head-scheme_no IS INITIAL.

      lt_msg = lo_scheme->create_new(
        VALUE zsds_schm_ini( scheme_type = ls_head-type
                             vkorg       = ls_head-vkorg
                             vtweg       = ls_head-vtweg
                             spart       = ls_head-spart
                             scheme_cat  = ls_head-cat
                             valid_from  = lv_val_fr
                             valid_to    = lv_val_to
                             early_bird  = ls_head-early_bird
                             cascading   = ls_head-cascading ) ).
    ELSE.

      lt_msg = lo_scheme->read(
                 iv_scheme_no = CONV #( |{ ls_head-scheme_no ALPHA = IN }| )
                 iv_lock      = abap_true ).
    ENDIF.

    IF line_exists( lt_msg[ type = 'E' ] ).
      PERFORM add_log_msg USING ls_head-refkey ls_head-scheme_no lt_msg.
      lv_err = lv_err + 1.
      CONTINUE.
    ENDIF.

    "--- header detail --------------------------------------------------
    DATA(ls_hdr) = lo_scheme->get_header( ).
    ls_hdr-descr      = ls_head-descr.
    ls_hdr-target_val = lv_tgt_v.
    ls_hdr-target_qty = lv_tgt_q.
    ls_hdr-meins      = ls_head-meins.
    ls_hdr-scheme_pct = lv_pct.
    ls_hdr-par_child  = ls_head-par_child.
    ls_hdr-eb_date_fr = lv_eb_fr.
    ls_hdr-eb_date_to = lv_eb_to.
    ls_hdr-eb_tgt_typ = ls_head-eb_tgt_typ.
    ls_hdr-eb_target  = lv_eb_tgt.
    ls_hdr-eb_pct     = lv_eb_pct.
    ls_hdr-schm_text  = ls_head-text.

    lo_scheme->set_header( ls_hdr ).

    "--- ranges ---------------------------------------------------------
    DATA lt_rng TYPE zcl_sd_scheme=>tt_rng.
    CLEAR lt_rng.

    LOOP AT gt_rng INTO DATA(ls_r) WHERE refkey = ls_head-refkey.
      APPEND VALUE zsdt_schm_rng(
        fieldname = to_upper( ls_r-fieldname )
        sign      = COND #( WHEN ls_r-sign IS INITIAL THEN 'I' ELSE to_upper( ls_r-sign ) )
        opti      = COND #( WHEN ls_r-opti IS INITIAL
                            THEN COND #( WHEN ls_r-high IS NOT INITIAL THEN 'BT'
                                         WHEN ls_r-low CS '*'         THEN 'CP'
                                         ELSE                              'EQ' )
                            ELSE to_upper( ls_r-opti ) )
        low       = ls_r-low
        high      = ls_r-high ) TO lt_rng.
    ENDLOOP.

    IF lt_rng IS INITIAL.
      PERFORM add_log USING ls_head-refkey ls_head-scheme_no 'E'
                            |Reference key { ls_head-refkey } has no selection criteria|.
      lo_scheme->dequeue( ).
      lv_err = lv_err + 1.
      CONTINUE.
    ENDIF.

    lo_scheme->set_ranges( lt_rng ).

    "--- save (same validation as the transaction, A39) ------------------
    lt_msg = lo_scheme->save( iv_test = p_test ).

    IF line_exists( lt_msg[ type = 'E' ] ).
      PERFORM add_log_msg USING ls_head-refkey ls_head-scheme_no lt_msg.
      lv_err = lv_err + 1.
    ELSE.
      DATA(lv_no) = lo_scheme->get_header( )-scheme_no.
      PERFORM add_log USING ls_head-refkey lv_no 'S'
                            COND #( WHEN p_test = abap_true
                                    THEN |Validated - not saved (test run)|
                                    ELSE |Scheme { lv_no } created| ).
      lv_ok = lv_ok + 1.
    ENDIF.

    lo_scheme->dequeue( ).

  ENDLOOP.

  MESSAGE s032 WITH lv_ok lv_err.

ENDFORM.

*&---------------------------------------------------------------------*
*& Convert an external date (DD.MM.YYYY or YYYYMMDD) to DATS
*&---------------------------------------------------------------------*
FORM date_conv USING pv_in TYPE any CHANGING pv_out TYPE dats.

  CLEAR pv_out.
  DATA(lv_in) = condense( CONV string( pv_in ) ).
  CHECK lv_in IS NOT INITIAL.

  IF lv_in CA '.' OR lv_in CA '/' OR lv_in CA '-'.
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING  date_external            = lv_in
      IMPORTING  date_internal            = pv_out
      EXCEPTIONS date_external_is_invalid = 1
                 OTHERS                   = 2.
  ELSE.
    pv_out = lv_in.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM amount_conv USING pv_in TYPE any CHANGING pv_out TYPE p.

  CLEAR pv_out.
  DATA(lv_in) = condense( CONV string( pv_in ) ).
  CHECK lv_in IS NOT INITIAL.

  REPLACE ALL OCCURRENCES OF ',' IN lv_in WITH ''.

  TRY.
      pv_out = lv_in.
    CATCH cx_sy_conversion_no_number.
      CLEAR pv_out.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
FORM add_log USING pv_refkey TYPE any
                   pv_scheme TYPE any
                   pv_type   TYPE bapi_mtype
                   pv_text   TYPE any.

  APPEND VALUE ty_log( refkey    = pv_refkey
                       scheme_no = pv_scheme
                       type      = pv_type
                       light     = COND #( WHEN pv_type = 'E' THEN '1'
                                           WHEN pv_type = 'W' THEN '2'
                                           ELSE                    '3' )
                       message   = pv_text ) TO gt_log.

ENDFORM.

*&---------------------------------------------------------------------*
FORM add_log_msg USING pv_refkey TYPE any
                       pv_scheme TYPE any
                       pt_msg    TYPE bapiret2_t.

  LOOP AT pt_msg INTO DATA(ls_msg).
    PERFORM add_log USING pv_refkey pv_scheme ls_msg-type ls_msg-message.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
FORM display_log.

  DATA lo_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_log ).

      lo_alv->get_functions( )->set_all( ).
      lo_alv->get_columns( )->set_optimize( ).

      DATA(lo_cols) = lo_alv->get_columns( ).
      lo_cols->set_exception_column( value = 'LIGHT' ).

      lo_alv->get_display_settings( )->set_list_header(
        COND #( WHEN p_test = abap_true
                THEN 'Scheme Upload - Test Run'
                ELSE 'Scheme Upload - Result' ) ).

      lo_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error.
      MESSAGE e030 WITH 'ALV'.
  ENDTRY.

ENDFORM.
