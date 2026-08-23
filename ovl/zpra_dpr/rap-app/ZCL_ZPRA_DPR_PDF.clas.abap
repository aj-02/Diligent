CLASS zcl_zpra_dpr_pdf DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "-- Reuse the row types from the Excel class (kept for signature parity
    "   and for the real ADS implementation once the SFP forms exist).
    TYPES:
      tt_prod_rows   TYPE zcl_zpra_dpr_excel=>tt_prod_rows,
      tt_target_rows TYPE zcl_zpra_dpr_excel=>tt_target_rows.

    CLASS-METHODS:
      "! Production data -> PDF. Requires Adobe form ZPRA_FRM_DPR_PRODUCTION
      "! (SFP) + Adobe Document Services. Until those exist, returns no document.
      fetch_and_export_production
        IMPORTING iv_date_from TYPE sy-datum
                  iv_date_to   TYPE sy-datum
        EXPORTING ev_pdf       TYPE xstring
                  ev_pages     TYPE i,

      "! Target vs actual -> PDF. Requires Adobe form ZPRA_FRM_DPR_TARGETS + ADS.
      fetch_and_export_targets
        IMPORTING iv_fiscal_year TYPE gjahr
                  iv_target_code TYPE zpra_t_prd_tar-tar_code
        EXPORTING ev_pdf         TYPE xstring
                  ev_pages       TYPE i.

ENDCLASS.


CLASS zcl_zpra_dpr_pdf IMPLEMENTATION.

  METHOD fetch_and_export_production.
    " TODO: implement Adobe Forms rendering once ZPRA_FRM_DPR_PRODUCTION exists
    "       in SFP and Adobe Document Services is configured.
    CLEAR: ev_pdf, ev_pages.
  ENDMETHOD.

  METHOD fetch_and_export_targets.
    " TODO: implement Adobe Forms rendering once ZPRA_FRM_DPR_TARGETS exists
    "       in SFP and Adobe Document Services is configured.
    CLEAR: ev_pdf, ev_pages.
  ENDMETHOD.

ENDCLASS.
