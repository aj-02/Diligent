*&---------------------------------------------------------------------*
*&  Include           ZFI_TAX_CAPEX_POSTING_F01
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*  FORMS
*---------------------------------------------------------------------*

FORM fetch_data.

*  SELECT SINGLE *
*    FROM zfi_tax_sec42_5
*    INTO gs_amort_sch
*    WHERE bukrs = p_bukrs
*      AND venture = p_jv
*      AND gjahr = p_gjahr.
*
*  IF sy-subrc IS INITIAL.
*    SELECT SINGLE *
*      FROM zfi_tax_glpost
*      INTO gs_gl
*      WHERE hkont = gs_amort_sch-hkont.
*  ENDIF.

  SELECT SINGLE prctr
    FROM zfi_tax_jv_pc
    INTO gv_prctr
    WHERE venture = p_jv.

ENDFORM.

*---------------------------------------------------------------------*
FORM prepare_date.

  DATA lv_gjahr TYPE numc4.

  lv_gjahr = p_gjahr + 1.
  CONCATENATE lv_gjahr '0331' INTO gv_date.

ENDFORM.

*---------------------------------------------------------------------*
FORM build_header USING iv_text TYPE char25.

  CLEAR ls_header.

  ls_header-username   = sy-uname.
  ls_header-comp_code  = p_bukrs.
  ls_header-doc_date   = gv_date.
  ls_header-pstng_date = gv_date.
  ls_header-trans_date = gv_date.
  ls_header-doc_type   = 'CO'.
  ls_header-fisc_year  = p_gjahr.
  ls_header-fis_period = '16'.
  ls_header-header_txt = iv_text.

ENDFORM.

*---------------------------------------------------------------------*
FORM add_gl_line USING iv_item iv_gl iv_amt iv_dc iv_text.

  CLEAR ls_accountgl.
  ls_accountgl-itemno_acc = iv_item.
  ls_accountgl-gl_account = iv_gl.
  ls_accountgl-item_text  = iv_text.
  ls_accountgl-comp_code  = p_bukrs.
  ls_accountgl-fis_period = '16'.
  ls_accountgl-fisc_year  = p_gjahr.
  ls_accountgl-pstng_date = gv_date.
  ls_accountgl-profit_ctr = gv_prctr.
  ls_accountgl-de_cre_ind = iv_dc.
  ls_accountgl-doc_type = 'CO'.
  ls_accountgl-bus_area = 'JV'.
  ls_accountgl-func_area = '0001'.
  ls_accountgl-value_date = gv_date.
  ls_accountgl-tr_part_ba  = 'JV'.
  ls_accountgl-cs_trans_t  = '305'.
  APPEND ls_accountgl TO lt_accountgl.

  CLEAR ls_currency.
  ls_currency-itemno_acc = iv_item.
  ls_currency-currency   = 'INR'.
  ls_currency-amt_doccur = iv_amt.
  APPEND ls_currency TO lt_currency.

ENDFORM.

*---------------------------------------------------------------------*
FORM post_document.

  DATA: lt_return_local TYPE TABLE OF bapiret2,
        ls_return_local TYPE bapiret2.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
"#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader = ls_header
    TABLES
      accountgl      = lt_accountgl
      currencyamount = lt_currency
      return         = lt_return_local.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2628704]
"#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader = ls_header
    IMPORTING
      obj_type       = gv_obj_type
      obj_key        = gv_obj_key
      obj_sys        = gv_obj_sys
    TABLES
      accountgl      = lt_accountgl
      currencyamount = lt_currency
      return         = lt_return_local.

  LOOP AT lt_return_local INTO ls_return_local.
    APPEND ls_return_local TO gt_final_return.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
FORM display_result.
  DATA: lv_msg TYPE bapi_msg.
  gv_error = abap_false.
  IF gt_final_return IS INITIAL.
    MESSAGE: 'No Data available for Posting' TYPE 'E'.
  ENDIF.
  LOOP AT gt_final_return INTO gs_final_return
       WHERE type = 'E' OR type = 'A'.
    gv_error = abap_true.
  ENDLOOP.

  IF gv_error = abap_true.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE gt_final_return INTO gs_final_return WITH KEY type = 'E' row = '1'.
    MESSAGE: gs_final_return-message TYPE 'E'.

  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    LOOP AT gt_final_return INTO gs_final_return.
      IF lv_msg IS INITIAL.
        lv_msg = gs_final_return-message.
      ELSE.
        CONCATENATE lv_msg
                    gs_final_return-message
               INTO lv_msg
               SEPARATED BY ','.
      ENDIF.
    ENDLOOP.
    MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'I'.

  ENDIF.

ENDFORM.

FORM calculate_jv_amort.

  DATA: lv_saknr      TYPE saknr,
        lv_instl_year TYPE gjahr,
        lv_instl_amt  TYPE wrbtr.

  CLEAR gt_amort_sch.

* Fetch Block Master
  SELECT *
    FROM zfi_tax_sec42_1
    INTO TABLE gt_block_master
    WHERE venture_code = p_jv
      AND bukrs        = p_bukrs.

  LOOP AT gt_block_master INTO gs_block_master.

    IF gs_block_master-claim_type = 'P'.

* Fetch GL mapping
      SELECT *
        FROM zfi_tax_sec42_2
        INTO TABLE gt_gl_post_comm
        WHERE bukrs = p_bukrs.

      IF gt_gl_post_comm IS INITIAL.
        CONTINUE.
      ENDIF.

      LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.

* Year Logic
*        IF gs_block_master-prod_date+4(2) <= '03'.
*          lv_instl_year = gs_block_master-prod_date+0(4) - 1.
*        ELSE.
*          lv_instl_year = gs_block_master-prod_date+0(4).
*        ENDIF.
        lv_instl_year = p_gjahr.

* Validate GL
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*        SELECT SINGLE saknr
*          INTO lv_saknr
*          FROM skb1
*          WHERE bukrs = p_bukrs
*            AND saknr = gs_gl_post_comm-hkont.
        SELECT SINGLE GLAccount AS saknr
          FROM i_glaccountincompanycode
          WHERE CompanyCode = @p_bukrs
            AND GLAccount   = @gs_gl_post_comm-hkont
          INTO @lv_saknr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

* Get JV Balance
        PERFORM get_jv_total
          USING    gs_block_master-venture_code
                   gs_gl_post_comm-hkont
                   gs_gl_post_comm-flow_type
                   p_bukrs
                   gs_block_master-prod_date
          CHANGING gv_total_balance.

* Installment Calculation
        lv_instl_amt = gv_total_balance .

* Fill amort table
*        CLEAR gs_amort_sch.
        IF gs_amort_sch IS INITIAL.
          gs_amort_sch-bukrs   = p_bukrs.
          gs_amort_sch-venture = gs_block_master-venture_code.
          gs_amort_sch-gjahr   = lv_instl_year.
          gs_amort_sch-hkont   = gs_gl_post_comm-hkont.

          IF gs_block_master-surr_date IS NOT INITIAL.
            gs_amort_sch-surr_date = gs_block_master-surr_date.
          ENDIF.

*        gs_amort_sch-total_amt = gv_total_balance.
          gs_amort_sch-instl_amt = lv_instl_amt.
          gs_amort_sch-reversed  = space.
        ELSE.
          gs_amort_sch-instl_amt = gs_amort_sch-instl_amt + lv_instl_amt.

        ENDIF.


      ENDLOOP.
      APPEND gs_amort_sch TO gt_amort_sch.
    ENDIF.
    IF gs_block_master-claim_type = 'E'.
      SELECT *
          FROM zfi_tax_sec42_3
          INTO TABLE gt_gl_post_comm
          WHERE bukrs = p_bukrs.

      IF gt_gl_post_comm IS INITIAL.
        CONTINUE.
      ENDIF.

      LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.

* Year Logic
        IF gs_block_master-prod_date+4(2) <= '03'.
          lv_instl_year = gs_block_master-prod_date+0(4) - 1.
        ELSE.
          lv_instl_year = gs_block_master-prod_date+0(4).
        ENDIF.

* Validate GL
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*        SELECT SINGLE saknr
*          INTO lv_saknr
*          FROM skb1
*          WHERE bukrs = p_bukrs
*            AND saknr = gs_gl_post_comm-hkont.
        SELECT SINGLE GLAccount AS saknr
          FROM i_glaccountincompanycode
          WHERE CompanyCode = @p_bukrs
            AND GLAccount   = @gs_gl_post_comm-hkont
          INTO @lv_saknr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

* Get JV Balance
        PERFORM get_jv_total
          USING    gs_block_master-venture_code
                   gs_gl_post_comm-hkont
                   gs_gl_post_comm-flow_type
                   p_bukrs
                   gs_block_master-prod_date
          CHANGING gv_total_balance.

* Installment Calculation
        lv_instl_amt = gv_total_balance / 10.

* Fill amort table
        CLEAR gs_amort_sch.
        IF gt_amort_sch IS INITIAL.
          gs_amort_sch-bukrs   = p_bukrs.
          gs_amort_sch-venture = gs_block_master-venture_code.
          gs_amort_sch-gjahr   = lv_instl_year.
          gs_amort_sch-hkont   = gs_gl_post_comm-hkont.

          IF gs_block_master-surr_date IS NOT INITIAL.
            gs_amort_sch-surr_date = gs_block_master-surr_date.
          ENDIF.

*        gs_amort_sch-total_amt = gv_total_balance.
          gs_amort_sch-instl_amt = lv_instl_amt.
          gs_amort_sch-reversed  = space.
        ELSE.
          gs_amort_sch-instl_amt = gs_amort_sch-instl_amt + lv_instl_amt.

        ENDIF.


      ENDLOOP.
      APPEND gs_amort_sch TO gt_amort_sch.
    ENDIF.
  ENDLOOP.

* Remove zero entries
  DELETE gt_amort_sch WHERE instl_amt IS INITIAL.

ENDFORM.

FORM get_jv_total
  USING    iv_venture   TYPE char6
           iv_hkont     TYPE hkont
           iv_flow_type TYPE char3
           iv_bukrs     TYPE bukrs
           iv_date TYPE datum
  CHANGING cv_total     TYPE wrbtr.

  DATA: iv_gjahr TYPE int4.
  DATA: lv_count     TYPE numc2,
        lv_fieldname TYPE string,
        lv_loop      TYPE i.

  TYPES: BEGIN OF ty_total,
           hslvt TYPE jvto1-hslvt,
           hsl01 TYPE jvto1-hsl01,
           hsl02 TYPE jvto1-hsl02,
           hsl03 TYPE jvto1-hsl03,
           hsl04 TYPE jvto1-hsl04,
           hsl05 TYPE jvto1-hsl05,
           hsl06 TYPE jvto1-hsl06,
           hsl07 TYPE jvto1-hsl07,
           hsl08 TYPE jvto1-hsl08,
           hsl09 TYPE jvto1-hsl09,
           hsl10 TYPE jvto1-hsl10,
           hsl11 TYPE jvto1-hsl11,
           hsl12 TYPE jvto1-hsl12,
           hsl13 TYPE jvto1-hsl13,
           hsl14 TYPE jvto1-hsl14,
           hsl15 TYPE jvto1-hsl15,
           hsl16 TYPE jvto1-hsl16,
         END OF ty_total.
  DATA: ls_total TYPE ty_total.
  FIELD-SYMBOLS: <fs_value> TYPE any.

  iv_gjahr = iv_date+0(4).
  IF iv_date+4(2) < '4'.
    iv_gjahr = iv_gjahr - 1.
  ENDIF.
  cv_total = 0.

  " Read JV transaction totals from JVTO1
  SELECT
    SUM( hslvt ) AS hslvt,
    SUM( hsl01 ) AS hsl01,
    SUM( hsl02 ) AS hsl02,
    SUM( hsl03 ) AS hsl03,
    SUM( hsl04 ) AS hsl04,
    SUM( hsl05 ) AS hsl05,
    SUM( hsl06 ) AS hsl06,
    SUM( hsl07 ) AS hsl07,
    SUM( hsl08 ) AS hsl08,
    SUM( hsl09 ) AS hsl09,
    SUM( hsl10 ) AS hsl10,
    SUM( hsl11 ) AS hsl11,
    SUM( hsl12 ) AS hsl12,
    SUM( hsl13 ) AS hsl13,
    SUM( hsl14 ) AS hsl14,
    SUM( hsl15 ) AS hsl15,
    SUM( hsl16 ) AS hsl16
  INTO CORRESPONDING FIELDS OF @ls_total
  FROM jvto1
  WHERE rbukrs = @iv_bukrs
  AND rjvnam = @iv_venture
  AND racct  = @iv_hkont
  AND ryear  = @p_gjahr
  AND ranbwa = @iv_flow_type
  AND rldnr = '4A'.


  IF iv_date+4(2) > '03'.
    lv_loop = iv_date+4(2) - 3.
  ELSE.
    lv_loop = iv_date+4(2) + 9.
  ENDIF.

  IF  iv_gjahr <> p_gjahr.
    lv_count = 1.
    DO 16 TIMES.
      lv_fieldname = |HSL{ lv_count }|.

      ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
      IF sy-subrc = 0.
        cv_total = cv_total + <fs_value>.
      ENDIF.
      lv_count = lv_count + 1.
    ENDDO.
  ELSE.
    lv_count = lv_loop + 1.
    DO 12 - lv_loop + 4 TIMES.
      lv_fieldname = |HSL{ lv_count }|.

      ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
      IF sy-subrc = 0.
        cv_total = cv_total + <fs_value>.
      ENDIF.
      lv_count = lv_count + 1.
    ENDDO.
  ENDIF.
ENDFORM.
