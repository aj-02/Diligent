*&---------------------------------------------------------------------*
*& Report  ZJVC_LOG_REPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zjvc_log_report.



INCLUDE zjvccfc_top11.

CLASS lcl_tax_credit DEFINITION.

  PUBLIC SECTION.
    METHODS display_data.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_tax_credit IMPLEMENTATION.

  METHOD display_data.

    PERFORM process_data.
    PERFORM process_print.

  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  DATA(lo_obj) = NEW lcl_tax_credit( ).
  lo_obj->display_data( ).






FORM process_data.

  SELECT * FROM zjvc_cc_fcforms INTO TABLE @lt_tran  WHERE ccreqno IN @req_no  AND ei_forgnenty_uin IN @uin AND vname IN @jv
                                                        AND erfdt IN @creat_on AND ernam IN @creat_by.




  IF lt_tran IS NOT   INITIAL.


*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT belnr, augbl, lifnr,shkzg ,wrbtr  FROM bseg INTO TABLE @DATA(lt_bseg)
*  FOR ALL ENTRIES IN @lt_tran WHERE belnr = @lt_tran-belnr
*                                 AND bukrs = 'OVL'
*                                 AND koart = 'K'.
    SELECT AccountingDocument          AS belnr,
           ClearingJournalEntry        AS augbl,
           Supplier                    AS lifnr,
           DebitCreditCode             AS shkzg,
           AmountInTransactionCurrency AS wrbtr
      FROM i_operationalacctgdocitem
      FOR ALL ENTRIES IN @lt_tran
      WHERE AccountingDocument   = @lt_tran-belnr
        AND CompanyCode          = 'OVL'
        AND FinancialAccountType = 'K'
      INTO TABLE @DATA(lt_bseg).
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---


    SELECT lifnr ,name1 FROM lfa1 INTO TABLE @DATA(lt_lfa1)  FOR ALL ENTRIES IN @lt_bseg
       WHERE lifnr = @lt_bseg-lifnr.

  ENDIF.


  LOOP AT lt_tran INTO DATA(ls_data).


    ls_final-doc_no = ls_data-doc_no.
    ls_final-uin = ls_data-ei_forgnenty_uin.
    ls_final-jv = ls_data-vname.
    ls_final-currency = ls_data-waers.
    ls_final-subdry_rcomp = ls_data-subdry_rcomp.

*    IF ls_data-waers = 'USD'.
*      ls_final-amount = ls_data-forgn_fincommitusd_eqt.
*    ELSEIF ls_data-waers = 'EUR'.
*      ls_final-amount = ls_data-forgn_fincommiteur_eqt.
*    ELSEIF ls_data-waers = 'GBP'.
*      ls_final-amount = ls_data-forgn_fincommitgbp_eqt.
*    ENDIF.

    ls_final-created_on = ls_data-erfdt.
    ls_final-created_by = ls_data-ernam.


    SELECT SINGLE * FROM zjvc_approve INTO @DATA(app) WHERE doc_no EQ @ls_data-doc_no AND ei_forgnenty_uin EQ @ls_data-ei_forgnenty_uin.
    IF sy-subrc EQ 0.
      ls_final-apprpved_on = app-aedtm.
      ls_final-apprpved_by = app-aeusn.
    ENDIF.



    ls_final-changed_on = ls_data-aedtm.
    ls_final-changed_by = ls_data-aeusn.





    ls_final-cc_req = ls_data-ccreqno.
    ls_final-fi_document_no = ls_data-belnr.

    READ TABLE lt_bseg INTO DATA(ls_bseg) WITH KEY belnr = ls_data-belnr  .
    IF  sy-subrc EQ 0.
      ls_final-vendor_code = ls_bseg-lifnr.
      ls_final-amount =  ls_bseg-wrbtr .
      READ TABLE lt_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_bseg-lifnr.
      ls_final-vendor_name = ls_lfa1-name1.
    ENDIF .


    READ TABLE lt_bseg INTO DATA(ls_bseg1) WITH KEY belnr = ls_data-belnr shkzg = 'H'.
    IF  sy-subrc EQ 0.
      ls_final-clearing_document_no = ls_bseg1-augbl.


    ENDIF .



    APPEND ls_final TO lt_final.
    CLEAR :ls_final , ls_bseg , ls_lfa1 , app.

  ENDLOOP.


  SELECT  * FROM bkpf INTO TABLE  @DATA(wa_bkpf1)  FOR ALL ENTRIES IN @lt_final  WHERE bukrs =  'OVL' AND belnr  EQ @lt_final-fi_document_no.

  LOOP AT  lt_final INTO ls_final .
    READ TABLE wa_bkpf1 INTO DATA(ls_temp) WITH KEY belnr = ls_final-fi_document_no.
    IF sy-subrc EQ 0.
      ls_final-currency = ls_temp-waers.
    ENDIF.

    MODIFY lt_final FROM ls_final.
    CLEAR : ls_final , ls_temp.
  ENDLOOP.

  SORT lt_final BY uin doc_no.
*  ENDIF.

ENDFORM.




FORM process_print.


  " Build Field Catalog
  CLEAR it_fcat.


  wa_fcat-col_pos    = '1'.
  wa_fcat-fieldname  = 'DOC_NO'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Document Number'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '2'.
  wa_fcat-fieldname  = 'UIN'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'UIN'.
  wa_fcat-key        = 'X'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.



  wa_fcat-col_pos    = '3'.
  wa_fcat-fieldname  = 'JV'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'JV'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.




    wa_fcat-col_pos    = '4'.
  wa_fcat-fieldname  = 'SUBDRY_RCOMP'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Subsidiary'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '5'.
  wa_fcat-fieldname  = 'CURRENCY'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Currency'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '6'.
  wa_fcat-fieldname  = 'AMOUNT'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Amount'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '7'.
  wa_fcat-fieldname  = 'CREATED_ON'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Created on'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '8'.
  wa_fcat-fieldname  = 'CREATED_BY'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Created By'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '9'.
  wa_fcat-fieldname  = 'CHANGED_ON'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Changed on'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '10'.
  wa_fcat-fieldname  = 'CHANGED_BY'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Changed By'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '11'.
  wa_fcat-fieldname  = 'APPRPVED_ON'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Approved On'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '12'.
  wa_fcat-fieldname  = 'APPRPVED_BY'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Approved By'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '13'.
  wa_fcat-fieldname  = 'CC_REQ'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Request No'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '14'.
  wa_fcat-fieldname  = 'VENDOR_CODE'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Vendor Code'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '15'.
  wa_fcat-fieldname  = 'VENDOR_NAME'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Vendor Name'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.


  wa_fcat-col_pos    = '16'.
  wa_fcat-fieldname  = 'FI_DOCUMENT_NO'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'FI Document No'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.

  wa_fcat-col_pos    = '17'.
  wa_fcat-fieldname  = 'CLEARING_DOCUMENT_NO'.
  wa_fcat-tabname    = 'LT_FINAL'.
  wa_fcat-seltext_m  = 'Clearing Doc No'.
  APPEND wa_fcat TO it_fcat. CLEAR wa_fcat.




  " Call ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = it_fcat
    TABLES
      t_outtab           = lt_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE 'ALV Display failed' TYPE 'E'.
  ENDIF.

ENDFORM.
