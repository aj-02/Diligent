CLASS lhc_dpr_excel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS:
      download_production FOR MODIFY
        IMPORTING it_action_import FOR ACTION
                  dprexceldownload~downloadproduction RESULT et_action_result,

      download_targets FOR MODIFY
        IMPORTING it_action_import FOR ACTION
                  dprexceldownload~downloadtargets RESULT et_action_result,

      download_dpr_summary FOR MODIFY
        IMPORTING it_action_import FOR ACTION
                  dprexceldownload~downloaddprsummary RESULT et_action_result,

      download_pdf_production FOR MODIFY
        IMPORTING it_action_import FOR ACTION
                  dprexceldownload~downloadpdfproduction RESULT et_action_result,

      download_pdf_targets FOR MODIFY
        IMPORTING it_action_import FOR ACTION
                  dprexceldownload~downloadpdftargets RESULT et_action_result.

ENDCLASS.

CLASS lhc_dpr_excel IMPLEMENTATION.

  METHOD download_production.
    DATA: ls_result TYPE STRUCTURE FOR ACTION RESULT zpra_i_dpr_excel_dl~downloadProduction,
          lv_xdata  TYPE xstring.

    READ TABLE it_action_import INTO DATA(ls_param) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_xdata = zcl_zpra_dpr_excel=>fetch_and_export_production(
      iv_date_from = ls_param-%param-date_from
      iv_date_to   = ls_param-%param-date_to ).

    ls_result-%param-excel_base64 = cl_http_utility=>encode_x_base64( lv_xdata ).
    ls_result-%param-file_name    =
      |DPR_Production_{ ls_param-%param-date_from DATE = RAW }_{ ls_param-%param-date_to DATE = RAW }.csv|.
    ls_result-%param-mime_type    = 'text/csv'.
    ls_result-%param-message      = 'File generated successfully'.
    APPEND ls_result TO et_action_result.
  ENDMETHOD.

  METHOD download_targets.
    DATA: ls_result TYPE STRUCTURE FOR ACTION RESULT zpra_i_dpr_excel_dl~downloadTargets,
          lv_xdata  TYPE xstring,
          lv_tcode  TYPE zpra_t_prd_tar-tar_code.

    READ TABLE it_action_import INTO DATA(ls_param) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_tcode = ls_param-%param-target_code.

    lv_xdata = zcl_zpra_dpr_excel=>fetch_and_export_targets(
      iv_fiscal_year = ls_param-%param-fiscal_year
      iv_target_code = lv_tcode ).

    ls_result-%param-excel_base64 = cl_http_utility=>encode_x_base64( lv_xdata ).
    ls_result-%param-file_name    =
      |DPR_Targets_{ ls_param-%param-fiscal_year }_{ lv_tcode }.csv|.
    ls_result-%param-mime_type    = 'text/csv'.
    ls_result-%param-message      = 'File generated successfully'.
    APPEND ls_result TO et_action_result.
  ENDMETHOD.

  METHOD download_dpr_summary.
    DATA: ls_result TYPE STRUCTURE FOR ACTION RESULT zpra_i_dpr_excel_dl~downloadDprSummary,
          lv_xdata  TYPE xstring.

    READ TABLE it_action_import INTO DATA(ls_param) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_xdata = zcl_zpra_dpr_excel=>fetch_and_export_dpr_summary(
      iv_date_from = ls_param-%param-date_from
      iv_date_to   = ls_param-%param-date_to ).

    ls_result-%param-excel_base64 = cl_http_utility=>encode_x_base64( lv_xdata ).
    ls_result-%param-file_name    =
      |DPR_Summary_{ ls_param-%param-date_from DATE = RAW }_{ ls_param-%param-date_to DATE = RAW }.csv|.
    ls_result-%param-mime_type    = 'text/csv'.
    ls_result-%param-message      = 'DPR summary generated successfully'.
    APPEND ls_result TO et_action_result.
  ENDMETHOD.

  METHOD download_pdf_production.
    DATA: ls_result TYPE STRUCTURE FOR ACTION RESULT zpra_i_dpr_excel_dl~downloadPdfProduction,
          lv_xdata  TYPE xstring,
          lv_pages  TYPE i.

    READ TABLE it_action_import INTO DATA(ls_param) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    zcl_zpra_dpr_pdf=>fetch_and_export_production(
      EXPORTING iv_date_from = ls_param-%param-date_from
                iv_date_to   = ls_param-%param-date_to
      IMPORTING ev_pdf       = lv_xdata
                ev_pages     = lv_pages ).

    ls_result-%param-pdf_base64 = cl_http_utility=>encode_x_base64( lv_xdata ).
    ls_result-%param-file_name  =
      |DPR_Production_{ ls_param-%param-date_from DATE = RAW }_{ ls_param-%param-date_to DATE = RAW }.pdf|.
    ls_result-%param-mime_type  = 'application/pdf'.
    ls_result-%param-page_count = lv_pages.
    ls_result-%param-message    = COND #( WHEN lv_xdata IS INITIAL
                                          THEN 'PDF not available - Adobe form not configured'
                                          ELSE |PDF generated ({ lv_pages } page(s))| ).
    APPEND ls_result TO et_action_result.
  ENDMETHOD.

  METHOD download_pdf_targets.
    DATA: ls_result TYPE STRUCTURE FOR ACTION RESULT zpra_i_dpr_excel_dl~downloadPdfTargets,
          lv_xdata  TYPE xstring,
          lv_pages  TYPE i,
          lv_tcode  TYPE zpra_t_prd_tar-tar_code.

    READ TABLE it_action_import INTO DATA(ls_param) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_tcode = ls_param-%param-target_code.

    zcl_zpra_dpr_pdf=>fetch_and_export_targets(
      EXPORTING iv_fiscal_year = ls_param-%param-fiscal_year
                iv_target_code = lv_tcode
      IMPORTING ev_pdf         = lv_xdata
                ev_pages       = lv_pages ).

    ls_result-%param-pdf_base64 = cl_http_utility=>encode_x_base64( lv_xdata ).
    ls_result-%param-file_name  =
      |DPR_Targets_{ ls_param-%param-fiscal_year }_{ lv_tcode }.pdf|.
    ls_result-%param-mime_type  = 'application/pdf'.
    ls_result-%param-page_count = lv_pages.
    ls_result-%param-message    = COND #( WHEN lv_xdata IS INITIAL
                                          THEN 'PDF not available - Adobe form not configured'
                                          ELSE |PDF generated ({ lv_pages } page(s))| ).
    APPEND ls_result TO et_action_result.
  ENDMETHOD.

ENDCLASS.
