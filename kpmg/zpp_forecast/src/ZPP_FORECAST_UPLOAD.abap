*&---------------------------------------------------------------------*
*& Report        ZPP_FORECAST_UPLOAD
*& Transaction   ZFCST_UPL
*& Package       ZPP_FORECAST
*& Description   ZFORECAST (Adhesive) - all three uploads in one program
*&               selected by a mode radio button (B38):
*&                 1  Last 3 years sales history      (BRD 1.2 req. J)
*&                 2  Sales / business forecast       (BRD 1.2 req. G)
*&                 3  Additional or subtraction       (BRD 1.2 req. I)
*&
*& Created by    Arnav Johri
*& Reference     WRICEF ID-2A Forecast Template-Adhesive.xlsx, 14.08.2026
*&
*& File layouts - tab delimited (B39). The BRD gives inconsistent layouts
*& for the same upload in different sections; the layouts below are the
*& reconciled versions, pending Query Q10.
*&
*&   1 Sales history      PLANT | MATERIAL | FIN.YEAR | PERIOD | QTY | UOM
*&   2 Sales forecast     PLANT | MATERIAL | FIN.YEAR | TYPE(Q/M) | PERIOD | QTY
*&   3 Adjustment         PLANT | MATERIAL | FIN.YEAR | TYPE(A/Q/M) | PERIOD | QTY | REASON
*&
*& PERIOD is the financial period 01 = April for type M, the quarter 1-4
*& for type Q, and 00 for type A. Quantity on layout 3 may be negative -
*& that is the subtraction case (B25).
*&---------------------------------------------------------------------*
REPORT zpp_forecast_upload MESSAGE-ID zpp_forecast.

TYPES: BEGIN OF ty_file,
         werks  TYPE char4,
         matnr  TYPE char18,
         fyear  TYPE char9,
         f4     TYPE char10,     "period / type depending on mode
         f5     TYPE char20,     "period / quantity
         f6     TYPE char20,     "quantity / uom
         f7     TYPE char100,    "reason
       END OF ty_file,

       BEGIN OF ty_log,
         row     TYPE i,
         werks   TYPE werks_d,
         matnr   TYPE matnr,
         type    TYPE bapi_mtype,
         light   TYPE char1,
         message TYPE char220,
       END OF ty_log.

DATA: gt_file TYPE STANDARD TABLE OF ty_file,
      gt_log  TYPE STANDARD TABLE OF ty_log,
      g_ok    TYPE i,
      g_err   TYPE i.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-b00.
PARAMETERS: p_hist RADIOBUTTON GROUP typ DEFAULT 'X',
            p_bus  RADIOBUTTON GROUP typ,
            p_adj  RADIOBUTTON GROUP typ.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
PARAMETERS: p_file TYPE localfile OBLIGATORY,
            p_head AS CHECKBOX DEFAULT abap_true,
            p_test AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: lt_files TYPE filetable,
        lv_rc    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING  file_filter = |Text (*.txt)\|*.txt\|CSV (*.csv)\|*.csv\|All\|*.*\||
    CHANGING   file_table  = lt_files
               rc          = lv_rc
    EXCEPTIONS OTHERS      = 1 ).

  IF sy-subrc = 0 AND lv_rc > 0.
    p_file = VALUE #( lt_files[ 1 ]-filename OPTIONAL ).
  ENDIF.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM upload_file.

  IF gt_file IS INITIAL.
    MESSAGE s009 DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  CASE abap_true.
    WHEN p_hist. PERFORM process_history.
    WHEN p_bus.  PERFORM process_business.
    WHEN p_adj.  PERFORM process_adjustment.
  ENDCASE.

  IF p_test = abap_false AND g_ok > 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

  MESSAGE s017 WITH g_ok g_err.
  PERFORM display_log.


*&---------------------------------------------------------------------*
FORM upload_file.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING  filename            = CONV string( p_file )
               filetype            = 'ASC'
               has_field_separator = abap_true
    CHANGING   data_tab            = gt_file
    EXCEPTIONS file_open_error     = 1
               file_read_error     = 2
               OTHERS              = 3 ).

  IF sy-subrc <> 0.
    MESSAGE e015 WITH p_file.
  ENDIF.

  IF p_head = abap_true.
    DELETE gt_file INDEX 1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& 1 - Sales history (B12). Loaded once at cutover so that forecasts can
*& be run for periods that pre-date go-live.
*&---------------------------------------------------------------------*
FORM process_history.

  LOOP AT gt_file INTO DATA(ls_file).

    DATA(lv_row) = sy-tabix.
    DATA lv_err  TYPE string.

    PERFORM check_common USING ls_file lv_row CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM add_log USING lv_row ls_file 'E' lv_err.
      CONTINUE.
    ENDIF.

    DATA(lv_period) = CONV numc2( condense( ls_file-f4 ) ).
    IF lv_period < '01' OR lv_period > '12'.
      PERFORM add_log USING lv_row ls_file 'E' |Period { ls_file-f4 } is not 01 to 12|.
      CONTINUE.
    ENDIF.

    DATA lv_qty TYPE zde_fcst_qty.
    PERFORM to_qty USING ls_file-f5 CHANGING lv_qty.

    zcl_pp_forecast_util=>split_fyear( EXPORTING iv_fyear     = CONV #( ls_file-fyear )
                                       IMPORTING ev_year_from = DATA(lv_yr_from) ).

    " History is stored against the calendar year in which the financial
    " period actually falls
    zcl_pp_forecast_util=>period_to_yearmonth(
      EXPORTING iv_fyear  = CONV #( ls_file-fyear )
                iv_period = lv_period
      IMPORTING ev_gjahr  = DATA(lv_gjahr) ).

    DATA(ls_hist) = VALUE zppt_sls_hist(
      werks   = |{ condense( ls_file-werks ) ALPHA = IN }|
      matnr   = |{ condense( ls_file-matnr ) ALPHA = IN }|
      gjahr   = lv_gjahr
      period  = lv_period
      sls_qty = lv_qty
      meins   = condense( ls_file-f6 )
      ernam   = sy-uname
      erdat   = sy-datum
      erzet   = sy-uzeit ).

    IF p_test = abap_false.
      MODIFY zppt_sls_hist FROM @ls_hist.
    ENDIF.

    PERFORM add_log USING lv_row ls_file 'S'
                          COND #( WHEN p_test = abap_true
                                  THEN 'Validated - not saved'
                                  ELSE 'History loaded' ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& 2 - Sales (business) forecast. Feeds BUS_FCST, which competes with the
*& calculated figure through the max rule (B18, B24).
*&---------------------------------------------------------------------*
FORM process_business.

  LOOP AT gt_file INTO DATA(ls_file).

    DATA(lv_row) = sy-tabix.
    DATA lv_err  TYPE string.

    PERFORM check_common USING ls_file lv_row CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM add_log USING lv_row ls_file 'E' lv_err.
      CONTINUE.
    ENDIF.

    DATA(lv_type) = CONV zde_fcst_type( to_upper( condense( ls_file-f4 ) ) ).
    IF lv_type NA 'QM'.
      PERFORM add_log USING lv_row ls_file 'E' |Type must be Q or M|.
      CONTINUE.
    ENDIF.

    DATA(lv_period) = CONV numc2( condense( ls_file-f5 ) ).
    IF ( lv_type = 'Q' AND ( lv_period < '01' OR lv_period > '04' ) )
    OR ( lv_type = 'M' AND ( lv_period < '01' OR lv_period > '12' ) ).
      PERFORM add_log USING lv_row ls_file 'E' |Period { lv_period } invalid for type { lv_type }|.
      CONTINUE.
    ENDIF.

    DATA lv_qty TYPE zde_fcst_qty.
    PERFORM to_qty USING ls_file-f6 CHANGING lv_qty.

    DATA(ls_bus) = VALUE zppt_fcst_bus(
      werks     = |{ condense( ls_file-werks ) ALPHA = IN }|
      matnr     = |{ condense( ls_file-matnr ) ALPHA = IN }|
      fyear     = condense( ls_file-fyear )
      fcst_type = lv_type
      period    = lv_period
      bus_qty   = lv_qty
      ernam     = sy-uname
      erdat     = sy-datum
      erzet     = sy-uzeit ).

    IF p_test = abap_false.
      MODIFY zppt_fcst_bus FROM @ls_bus.
    ENDIF.

    PERFORM add_log USING lv_row ls_file 'S'
                          COND #( WHEN p_test = abap_true
                                  THEN 'Validated - not saved'
                                  ELSE 'Business forecast loaded' ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& 3 - Additional or subtraction (B25 - B27). Stored as its own record so
*& the calculated figure is never overwritten, and a reason is mandatory.
*&---------------------------------------------------------------------*
FORM process_adjustment.

  LOOP AT gt_file INTO DATA(ls_file).

    DATA(lv_row) = sy-tabix.
    DATA lv_err  TYPE string.

    PERFORM check_common USING ls_file lv_row CHANGING lv_err.
    IF lv_err IS NOT INITIAL.
      PERFORM add_log USING lv_row ls_file 'E' lv_err.
      CONTINUE.
    ENDIF.

    DATA(lv_type) = CONV zde_fcst_type( to_upper( condense( ls_file-f4 ) ) ).
    IF lv_type NA 'AQM'.
      PERFORM add_log USING lv_row ls_file 'E' |Type must be A, Q or M|.
      CONTINUE.
    ENDIF.

    IF condense( ls_file-f7 ) IS INITIAL.
      PERFORM add_log USING lv_row ls_file 'E' 'Reason is mandatory'.
      CONTINUE.
    ENDIF.

    DATA lv_qty TYPE zde_fcst_qty.
    PERFORM to_qty USING ls_file-f6 CHANGING lv_qty.

    IF lv_qty = 0.
      PERFORM add_log USING lv_row ls_file 'E' 'Adjustment quantity is zero'.
      CONTINUE.
    ENDIF.

    DATA(lv_werks)  = CONV werks_d( |{ condense( ls_file-werks ) ALPHA = IN }| ).
    DATA(lv_matnr)  = CONV matnr( |{ condense( ls_file-matnr ) ALPHA = IN }| ).
    DATA(lv_fyear)  = CONV zde_fyear( condense( ls_file-fyear ) ).
    DATA(lv_period) = CONV numc2( condense( ls_file-f5 ) ).

    " Next sequence number for this key - adjustments accumulate rather
    " than replace, so the history of changes survives (B26)
    SELECT MAX( seqnr ) FROM zppt_fcst_adj INTO @DATA(lv_seq)
      WHERE werks = @lv_werks AND matnr = @lv_matnr AND fyear = @lv_fyear
        AND fcst_type = @lv_type AND period = @lv_period.

    DATA(ls_adj) = VALUE zppt_fcst_adj(
      werks     = lv_werks
      matnr     = lv_matnr
      fyear     = lv_fyear
      fcst_type = lv_type
      period    = lv_period
      seqnr     = lv_seq + 1
      adj_qty   = lv_qty
      reason    = condense( ls_file-f7 )
      ernam     = sy-uname
      erdat     = sy-datum
      erzet     = sy-uzeit ).

    IF p_test = abap_false.
      INSERT zppt_fcst_adj FROM @ls_adj.
    ENDIF.

    PERFORM add_log USING lv_row ls_file 'S'
                          COND #( WHEN p_test = abap_true
                                  THEN 'Validated - not saved'
                                  ELSE |Adjustment { lv_qty } recorded| ).
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
FORM check_common USING ps_file TYPE ty_file
                        pv_row  TYPE i
                  CHANGING pv_err TYPE string.

  CLEAR pv_err.

  DATA(lv_werks) = CONV werks_d( |{ condense( ps_file-werks ) ALPHA = IN }| ).
  DATA(lv_matnr) = CONV matnr( |{ condense( ps_file-matnr ) ALPHA = IN }| ).

  IF lv_werks IS INITIAL OR lv_matnr IS INITIAL.
    pv_err = 'Plant and material are mandatory'.
    RETURN.
  ENDIF.

  SELECT SINGLE @abap_true FROM marc INTO @DATA(lv_ok)
    WHERE werks = @lv_werks AND matnr = @lv_matnr.
  IF lv_ok <> abap_true.
    pv_err = |Plant { lv_werks } material { lv_matnr } does not exist|.
    RETURN.
  ENDIF.

  IF zcl_pp_forecast_util=>split_fyear( CONV #( condense( ps_file-fyear ) ) ) = abap_false.
    pv_err = |Financial year { ps_file-fyear } is not in the format YYYY-YYYY|.
    RETURN.
  ENDIF.

  IF zcl_pp_forecast_util=>check_authority( iv_werks = lv_werks
                                            iv_actvt = '02' ) = abap_false.
    pv_err = |No authorisation for plant { lv_werks }|.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM to_qty USING pv_in TYPE any CHANGING pv_qty TYPE zde_fcst_qty.

  CLEAR pv_qty.
  DATA(lv_in) = condense( CONV string( pv_in ) ).
  CHECK lv_in IS NOT INITIAL.

  REPLACE ALL OCCURRENCES OF ',' IN lv_in WITH ''.

  TRY.
      pv_qty = lv_in.
    CATCH cx_sy_conversion_no_number.
      CLEAR pv_qty.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
FORM add_log USING pv_row  TYPE i
                   ps_file TYPE ty_file
                   pv_type TYPE bapi_mtype
                   pv_text TYPE any.

  APPEND VALUE ty_log( row     = pv_row
                       werks   = |{ condense( ps_file-werks ) ALPHA = IN }|
                       matnr   = |{ condense( ps_file-matnr ) ALPHA = IN }|
                       type    = pv_type
                       light   = COND #( WHEN pv_type = 'E' THEN '1' ELSE '3' )
                       message = pv_text ) TO gt_log.

  IF pv_type = 'E'.
    g_err = g_err + 1.
  ELSE.
    g_ok = g_ok + 1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
FORM display_log.

  DATA lo_alv TYPE REF TO cl_salv_table.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_log ).

      lo_alv->get_functions( )->set_all( ).
      lo_alv->get_columns( )->set_optimize( ).
      lo_alv->get_columns( )->set_exception_column( value = 'LIGHT' ).
      lo_alv->get_display_settings( )->set_list_header(
        COND #( WHEN p_test = abap_true
                THEN 'Forecast Upload - Test Run'
                ELSE 'Forecast Upload - Result' ) ).
      lo_alv->display( ).

    CATCH cx_salv_msg cx_salv_not_found cx_salv_data_error.
      MESSAGE e015 WITH 'ALV'.
  ENDTRY.

ENDFORM.
