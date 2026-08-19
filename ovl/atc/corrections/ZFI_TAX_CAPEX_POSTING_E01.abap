*&---------------------------------------------------------------------*
*&  Include           ZFI_TAX_CAPEX_POSTING_E01
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  DATA: lv_capex_gl   TYPE saknr,
        lv_credit_amt TYPE wrbtr.
  DATA: lv_gjahr1 TYPE numc2,
        lv_gjahr2 TYPE numc2.

* Fetch data
  PERFORM fetch_data.

*  IF gs_amort_sch IS INITIAL.
*    MESSAGE: 'No data found to process' TYPE 'E'.
*    RETURN.
*  ENDIF.


  SELECT *
    FROM zfi_tax_sec42_2
    INTO TABLE @DATA(lt_2).

  SELECT racct
    INTO TABLE @DATA(lt_act)
    FROM jvto1
    FOR ALL ENTRIES IN @lt_2
WHERE rbukrs = @p_bukrs
AND rjvnam = @p_jv
AND ryear  = @p_gjahr
AND rldnr = '4A'
AND racct = @lt_2-hkont.


*     gs_gl.
*LOOP AT lt_act into data(ls_act).
  READ TABLE lt_act INTO DATA(ls_act) INDEX 1. "#EC CI_NOORDER
  SELECT SINGLE *
     FROM zfi_tax_glpost
     INTO gs_gl
    WHERE hkont = ls_act-racct.

  PERFORM prepare_date.
  lv_capex_gl = gs_gl-capex_gl.
  lv_credit_amt = gs_amort_sch-instl_amt * -1.

  CLEAR: lt_accountgl, lt_currency.
  gv_gjahr = gv_date+2(2).
  lv_gjahr1 = gv_gjahr.
  lv_gjahr2 = gv_gjahr + 1.
  CONCATENATE 'CIT-Capex Allow-AY' lv_gjahr1 '-' lv_gjahr2 INTO gv_heading.
  PERFORM build_header USING gv_heading.

  PERFORM calculate_jv_amort.
  IF gt_amort_sch IS INITIAL.
    MESSAGE: 'No Data available for Posting' TYPE 'E'.
  ENDIF.
*
*  READ TABLE gt_amort_sch INTO gs_amort_sch INDEX 1.
*  IF sy-subrc <> 0.
*    MESSAGE: 'No Transactions for current Year' TYPE 'E'.
*    RETURN.
*  ENDIF.

  gv_item = 1.

  PERFORM add_gl_line USING gv_item
        lv_capex_gl
        gs_amort_sch-instl_amt
        'H'
        'Current Capex Allow - Drilling exploration for production'.

  gv_item = gv_item + 1.
  lv_credit_amt = gs_amort_sch-instl_amt * -1.

  PERFORM add_gl_line USING gv_item
        gs_gl-off_capex_gl
        lv_credit_amt
        'S'
        'Current Capex Allow - Drilling exploration for production'.
  DATA: lt_bkpf TYPE TABLE OF bkpf,
        lt_bseg TYPE TABLE OF bseg,
        ls_bkpf TYPE bkpf,
        ls_bseg TYPE bseg.
  CLEAR: lt_bkpf, lt_bseg, ls_bkpf, ls_bseg.

* Step 1: Get headers
  SELECT *
    INTO TABLE lt_bkpf
    FROM bkpf
   WHERE blart = 'CO'
     AND bukrs = p_bukrs
     AND gjahr = p_gjahr.

  IF lt_bkpf IS NOT INITIAL.

* Step 2: Get line items from BSEG
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT *
      INTO TABLE lt_bseg
      FROM bseg
      FOR ALL ENTRIES IN lt_bkpf
     WHERE belnr = lt_bkpf-belnr
      AND vname = p_jv
      AND bukrs = p_bukrs
      AND gjahr = p_gjahr ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  ENDIF.

* Step 3: Check duplicate
  LOOP AT lt_bseg INTO ls_bseg.

    READ TABLE lt_bkpf INTO ls_bkpf
         WITH KEY belnr = ls_bseg-belnr.

    IF sy-subrc = 0.

* If reversed with reason 01 allow
      IF ls_bkpf-stgrd = '01' AND ls_bseg-sgtxt = 'Current Capex Allow - Drilling exploration for production'.
        CONTINUE.
      ELSEIF ls_bseg-sgtxt = 'Current Capex Allow - Drilling exploration for production'.
        MESSAGE 'Duplicate document exists. Posting not allowed'
        TYPE 'E'.
      ENDIF.

    ENDIF.

  ENDLOOP.
  PERFORM post_document.
*ENDLOOP.

*---------------------------------------------------------------------*
* FINAL RESULT
*---------------------------------------------------------------------*
  PERFORM display_result.
