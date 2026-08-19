*&---------------------------------------------------------------------*
*&  Include           ZFI_TAX_SEC42_AMORT_SCH_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

**&---------------------------------------------------------------------*
**& Form VALIDATE_INPUT
**&---------------------------------------------------------------------*
**& Validates selection screen input parameters
**&---------------------------------------------------------------------*
FORM validate_input.

  DATA: lv_bukrs TYPE bukrs.

  " Validate Company Code
  SELECT SINGLE bukrs FROM t001
    INTO lv_bukrs
    WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
*    MESSAGE e001(zfi_sec42) WITH p_bukrs.
    MESSAGE: |Company code { p_BUKRS } does not exist| type 'E'.
    " Company code &1 does not exist
  ENDIF.

  " Validate Joint Venture exists in Block Master
  SELECT SINGLE * FROM zfi_tax_sec42_1
    INTO gs_block_master
    WHERE venture_code = p_jv
      AND bukrs        = p_bukrs.
  IF sy-subrc <> 0.
*    MESSAGE e002(zfi_sec42) WITH p_jv p_bukrs.
    MESSAGE: |Joint Venture { P_JV } not found in Block Master for company code { P_BUKRS }| TYPE 'E'.
    " Joint Venture &1 not found in Block Master for company code &2
  ENDIF.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_AMORTIZATION
**&---------------------------------------------------------------------*
**& Main processing logic for amortization computation
**&---------------------------------------------------------------------*
FORM process_amortization.

  " Read Block Master entries for the given JV and Company Code
  SELECT * FROM zfi_tax_sec42_1
    INTO TABLE gt_block_master
    WHERE venture_code = p_jv
      AND bukrs        = p_bukrs.

  IF gt_block_master IS INITIAL.
*    MESSAGE s003(zfi_sec42) WITH p_jv.
    MESSAGE: |No Block Master entries found for Joint Venture { p_JV }| type 'S'.
    " No Block Master entries found for Joint Venture &1
    RETURN.
  ENDIF.

  LOOP AT gt_block_master INTO gs_block_master.

    CASE gs_block_master-claim_type.

      WHEN 'E'.  " Exploration
        PERFORM process_status_e.

      WHEN 'P'.  " Post Commercial Production
        PERFORM process_status_p.

      WHEN OTHERS.
*        MESSAGE w004(zfi_sec42) WITH gs_block_master-venture_code
*                                     gs_block_master-claim_type.
        MESSAGE: |Unknown claim type { gs_block_master-claim_type } for venture { gs_block_master-venture_code }| TYPE 'W'.
        " Unknown claim type &2 for venture &1
        CONTINUE.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_STATUS_E
**&---------------------------------------------------------------------*
**& Process ventures with Status E (Exploration)
**& Check if surrendered: if NO, skip. If YES, process.
**&---------------------------------------------------------------------*
FORM process_status_e.

  DATA: lv_saknr TYPE saknr.

  " If not surrendered, close the loop (skip)
  IF gs_block_master-surrendered <> 'X'.
    RETURN.
  else.
    PERFORM process_surrendered_venture.
  ENDIF.
*
**   Venture is surrendered - read GL accounts from Table-2 (Post Commercial)
*  SELECT * FROM ZFI_TAX_SEC42_2
*    INTO TABLE gt_gl_post_comm
*    WHERE bukrs = p_bukrs.
*
*  IF gt_gl_post_comm IS INITIAL.
*    MESSAGE w005(zfi_sec42) WITH p_bukrs.
*    " No GL accounts found in Post Commercial table for company code &1
*    RETURN.
*  ENDIF.
*
*  " For each GL account, get balance using FAGLB03 logic
*  LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
*
*    " Validate GL account exists in SKB1
*    SELECT SINGLE saknr FROM skb1
*      INTO lv_saknr
*      WHERE bukrs = p_bukrs
*        AND saknr = gs_gl_post_comm-hkont.
*    IF sy-subrc <> 0.
*      MESSAGE w006(zfi_sec42) WITH gs_gl_post_comm-hkont p_bukrs.
*      " GL account &1 not valid in company code &2
*      CONTINUE.
*    ENDIF.
*
*    " Read GL balance from FAGLB03 (FAGLFLEXT)
*    PERFORM get_gl_balance
*      USING    gs_block_master-venture_code
*               gs_gl_post_comm-hkont
*               p_bukrs
*               p_gjahr
*               p_monat
*      CHANGING gv_total_balance.
*
*    " Store current year deduction in temp table
*    CLEAR gs_current_ded.
*    gs_current_ded-bukrs      = p_bukrs.
*    gs_current_ded-venture    = gs_block_master-venture_code.
*    gs_current_ded-gjahr      = p_gjahr.
*    gs_current_ded-hkont      = gs_gl_post_comm-hkont.
*    gs_current_ded-amount     = gv_total_balance.
*    gs_current_ded-description = 'Status E - Post Commercial GL Balance'.
*    APPEND gs_current_ded TO gt_current_ded.
*
*  ENDLOOP.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_STATUS_P
**&---------------------------------------------------------------------*
**& Process ventures with Status P (Post Commercial Production)
**& If surrendered YES -> Table-3 (Installments), compute amort schedule
**& If surrendered NO  -> Table-2 (Post Commercial), get GL balances
**&---------------------------------------------------------------------*
FORM process_status_p.

  IF gs_block_master-surrendered = 'X'.
    " Surrendered: Use Table-3 GL Installments
    PERFORM process_active_venture.

*    PERFORM process_surrendered_venture.
  ELSE.
    " Not surrendered: Use Table-2 GL Post Commercial
    PERFORM process_active_venture.
  ENDIF.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_SURRENDERED_VENTURE
**&---------------------------------------------------------------------*
**& For surrendered ventures: compute amortization schedule
**& Installment = Total Amount / 10, spread over 10 years
**&---------------------------------------------------------------------*
FORM process_surrendered_venture.

  DATA: lv_instl_year TYPE gjahr,
        lv_instl_no   TYPE numc2,
        lv_instl_amt  TYPE wrbtr,
        lv_saknr      TYPE saknr.

      IF gs_block_master-surr_date+4(2) <= '03'.
     lv_instl_year = gs_block_master-surr_date+0(4) - 1.  " Year from surrender date
    else.
     lv_instl_year = gs_block_master-surr_date+0(4).  " Year from surrender date
    ENDIF.

  " Read GL accounts from Table-3 (Installments)
  SELECT * FROM zfi_tax_sec42_3
    INTO TABLE gt_gl_instl
    WHERE bukrs = p_bukrs.

  IF gt_gl_instl IS INITIAL.
*    MESSAGE w007(zfi_sec42) WITH p_bukrs.
    MESSAGE: |No GL accounts in installment table for company code { P_BUKRS }| TYPE 'W'.
    " No GL accounts in installment table for company code &1
    RETURN.
  ENDIF.

  " Check if amortization schedule already exists
*  SELECT * FROM zfi_tax_sec42_4
*    INTO TABLE gt_amort_sch
*    WHERE venture = p_jv
*      AND bukrs   = p_bukrs.

  " Check Date of Creation of schedule in Block Master
*  IF gs_block_master-sched_date IS INITIAL.

  " Schedule does not exist - need to create it
  select HKONT
    from ZFI_TAX_SEC42_4
    into table @data(lt_check)
    where bukrs = @p_bukrs
    and venture = @p_jv.

LOOP AT LT_CHECK INTO DATA(LS_CHECK).
  DELETE GT_GL_INSTL WHERE HKONT = LS_CHECK-HKONT.
ENDLOOP.

  LOOP AT gt_gl_instl INTO gs_gl_instl.
 IF gs_block_master-surr_date+4(2) <= '03'.
     lv_instl_year = gs_block_master-surr_date+0(4) - 1.  " Year from surrender date
    else.
     lv_instl_year = gs_block_master-surr_date+0(4).  " Year from surrender date
    ENDIF.
    " Validate GL in SKB1
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE saknr FROM skb1
*      INTO lv_saknr
*      WHERE bukrs = p_bukrs
*        AND saknr = gs_gl_instl-hkont.
    SELECT SINGLE GLAccount AS saknr
      FROM i_glaccountincompanycode
      WHERE CompanyCode = @p_bukrs
        AND GLAccount   = @gs_gl_instl-hkont
      INTO @lv_saknr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    " Get total amount from JVTO1 (JV Transaction sub-totals)
    PERFORM get_jv_total
      USING    gs_block_master-venture_code
               gs_gl_instl-hkont
               gs_gl_instl-flow_type
               p_bukrs
               gs_block_master-surr_date
      CHANGING gv_total_balance.

    " Compute installment: Total / 10
    lv_instl_amt = gv_total_balance / 10.

    " Create Amortization Schedule entry
    CLEAR gs_amort_sch.
    gs_amort_sch-bukrs     = p_bukrs.
    gs_amort_sch-venture   = p_jv.
    gs_amort_sch-gjahr     = lv_instl_year.
    gs_amort_sch-hkont     = gs_gl_instl-hkont.
    gs_amort_sch-surr_date = gs_block_master-surr_date.
    gs_amort_sch-total_amt = gv_total_balance.
    gs_amort_sch-instl_amt = lv_instl_amt.
    gs_amort_sch-reversed  = ' '.
    APPEND gs_amort_sch TO gt_amort_sch.
*      MODIFY ZFI_TAX_SEC42_4 FROM gs_amort_sch.

    " Create 10 yearly installment entries


    DO 10 TIMES.
      lv_instl_no = sy-index.

      CLEAR gs_amort_instl.
      gs_amort_instl-bukrs     = p_bukrs.
      gs_amort_instl-venture   = p_jv.
      gs_amort_instl-gjahr     = lv_instl_year.
      gs_amort_instl-hkont     = gs_gl_instl-hkont.
      gs_amort_instl-surr_date = gs_block_master-surr_date.
      gs_amort_instl-instl_amt = lv_instl_amt.
      gs_amort_instl-instl_no  = lv_instl_no.
      gs_amort_instl-executed  = ' '.
      gs_amort_instl-reversed  = ' '.
      gs_amort_instl-acct_upd  = ' '.

      APPEND gs_amort_instl TO gt_amort_instl.
*        MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.

      lv_instl_year = lv_instl_year + 1.
    ENDDO.

    data: lt_amort type table of ZFI_TAX_SEC42_5.

  LOOP AT gt_amort_instl into gs_amort_instl.
   READ TABLE lt_amort into data(ls_amort) with key instl_no = gs_amort_instl-instl_no hkont = gs_amort_instl-hkont.
   IF sy-subrc is INITIAL.
     ls_amort-instl_amt = ls_amort-instl_amt + gs_amort_instl-instl_amt.
          modify lt_amort from ls_amort TRANSPORTING instl_amt where bukrs = gs_amort_instl-bukrs and gjahr = gs_amort_instl-gjahr and hkont = gs_amort_instl-hkont .
   else.
     MOVE-CORRESPONDING gs_amort_instl to ls_amort.
     append ls_amort to lt_amort.
   ENDIF.


  ENDLOOP.

  clear: gt_amort_instl.

  ENDLOOP.


    gt_amort_instl = lt_amort.





*    " Update Block Master with schedule creation date
*    gs_block_master-sched_date = sy-datum.
*    MODIFY ZFI_TAX_SEC42_1 FROM gs_block_master.
*    IF sy-subrc is INITIAL.
*      MESSAGE: 'Program Succesfully executed' type 'S'.
*    ENDIF.

*  ENDIF.

*   Pick current year installment for deduction
*  SELECT SINGLE * FROM zfi_tax_sec42_5
*    INTO gs_amort_instl
*    WHERE venture  = p_jv
*      AND bukrs    = p_bukrs
*      AND gjahr    = gs_block_master-sched_date+0(4)
*      AND executed = ' '
*      AND reversed = ' '.

*  IF sy-subrc = 0.
**     Store deduction
*    CLEAR gs_current_ded.
*    gs_current_ded-bukrs      = p_bukrs.
*    gs_current_ded-venture    = gs_block_master-venture_code.
*    gs_current_ded-gjahr      = p_gjahr.
*    gs_current_ded-hkont      = gs_amort_instl-hkont.
*    gs_current_ded-amount     = gs_amort_instl-instl_amt.
*    gs_current_ded-description = 'Status P - Surrendered Installment'.
*    APPEND gs_current_ded TO gt_current_ded.
*
**     Mark installment as executed
*    gs_amort_instl-executed = 'X'.
**    MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.
*  ENDIF.

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_ACTIVE_VENTURE
**&---------------------------------------------------------------------*
**& For active (not surrendered) Status P ventures
**& Read from Table-2 and get GL balances
**&---------------------------------------------------------------------*
FORM process_active_venture.

  DATA: lv_saknr TYPE saknr.
  DATA: lv_instl_year TYPE gjahr,
        lv_instl_no   TYPE numc2,
        lv_instl_amt  TYPE wrbtr.

  " Read GL accounts from Table-2 (Post Commercial Production)
  SELECT * FROM zfi_tax_sec42_2
    INTO TABLE gt_gl_post_comm
    WHERE bukrs = p_bukrs.

  IF gt_gl_post_comm IS INITIAL.
    RETURN.
  ENDIF.

    select HKONT
    from ZFI_TAX_SEC42_4
    into table @data(lt_check)
    where bukrs = @p_bukrs
    and venture = @p_jv.

LOOP AT LT_CHECK INTO DATA(LS_CHECK).
  DELETE GT_GL_POST_COMM WHERE HKONT = LS_CHECK-HKONT.
ENDLOOP.

  LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
    IF gs_block_master-prod_date+4(2) <= '03'.
     lv_instl_year = gs_block_master-prod_date+0(4) - 1.  " Year from surrender date
    else.
     lv_instl_year = gs_block_master-prod_date+0(4).  " Year from surrender date
    ENDIF.
    " Validate GL in SKB1
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE saknr FROM skb1
*      INTO lv_saknr
*      WHERE bukrs = p_bukrs
*        AND saknr = gs_gl_post_comm-hkont.
    SELECT SINGLE GLAccount AS saknr
      FROM i_glaccountincompanycode
      WHERE CompanyCode = @p_bukrs
        AND GLAccount   = @gs_gl_post_comm-hkont
      INTO @lv_saknr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    PERFORM get_jv_total
      USING    gs_block_master-venture_code
               gs_gl_post_comm-hkont
               gs_gl_post_comm-flow_type
               p_bukrs
               gs_block_master-prod_date
      CHANGING gv_total_balance.


*    DATA: LV_DATE TYPE DATS.
*    DATA(LV_MONTH) = GS_BLOCK_MASTER-prod_date+4(2).
*    LV_MONTH = LV_MONTH + 1.
*    CONCATENATE GS_BLOCK_MASTER-prod_date+0(4) LV_MONTH '01' INTO LV_DATE.
*    SELECT SUM( hsl ) AS HSL
*      FROM JVSO1
*      INTO @GV_TOTAL_BALANCE
*      WHERE rbukrs = @P_bukrs
*AND rjvnam = @p_jv
*AND racct  = @gs_gl_post_comm-hkont
*AND BUDAT  < @LV_DATE
*AND ranbwa = @gs_gl_post_comm-flow_type
*      AND RLDNR = '4A'
*      AND ryear = @lv_instl_year.
*
*        SELECT
*    sum( hslvt ) as hslvt
*          INTO @DATA(lv_total_balance)
*FROM jvto1
*WHERE rbukrs = @p_bukrs
*AND rjvnam = @p_jv
*AND racct  = @gs_gl_post_comm-hkont
*AND ryear  = @lv_instl_year
*AND ranbwa = @gs_gl_post_comm-flow_type
*    and RLDNR = '4A' and
*          ryear = @lv_instl_year.
*
*          gv_total_balance = gv_total_balance + lv_total_balance.
          lv_instl_amt = gv_total_balance / 10.

          CLEAR gs_amort_sch.
    gs_amort_sch-bukrs     = p_bukrs.
    gs_amort_sch-venture   = gs_block_master-venture_code.
    gs_amort_sch-gjahr     = GS_BLOCK_MASTER-prod_date+0(4).
    gs_amort_sch-hkont     = gs_gl_post_comm-hkont.
    IF GS_BLOCK_MASTER-surr_date IS NOT INITIAL.
    gs_amort_sch-surr_date = gs_block_master-surr_date.
    ENDIF.
    gs_amort_sch-total_amt = gv_total_balance.
    gs_amort_sch-instl_amt = lv_instl_amt.
    gs_amort_sch-reversed  = ' '.
    APPEND gs_amort_sch TO gt_amort_sch.



     DO 10 TIMES.
      lv_instl_no = sy-index.

      CLEAR gs_amort_instl.
      gs_amort_instl-bukrs     = p_bukrs.
      gs_amort_instl-venture   = gs_block_master-venture_code.
      gs_amort_instl-gjahr     = lv_instl_year.
      gs_amort_instl-hkont     = gs_gl_post_comm-hkont.
    IF GS_BLOCK_MASTER-surr_date IS NOT INITIAL.
      gs_amort_instl-surr_date = gs_block_master-surr_date.
    ENDIF.
      gs_amort_instl-instl_amt = lv_instl_amt.
      gs_amort_instl-instl_no  = lv_instl_no.
      gs_amort_instl-executed  = ' '.
      gs_amort_instl-reversed  = ' '.
      gs_amort_instl-acct_upd  = ' '.

      APPEND gs_amort_instl TO gt_amort_instl.
*        MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.

      lv_instl_year = lv_instl_year + 1.
    ENDDO.

    " Get GL balance via JVTO1
*    PERFORM get_jv_total
*      USING    gs_block_master-venture_code
*               gs_gl_post_comm-hkont
*               gs_gl_post_comm-flow_type
*               p_bukrs
*               gs_block_master-surr_date
*               p_gjahr
*               p_monat
*      CHANGING gv_total_balance.

    " Store current year deduction
      data: lt_amort type table of ZFI_TAX_SEC42_5.

  LOOP AT gt_amort_instl into gs_amort_instl.
   READ TABLE lt_amort into data(ls_amort) with key instl_no = gs_amort_instl-instl_no hkont = gs_amort_instl-hkont.
   IF sy-subrc is INITIAL.
     ls_amort-instl_amt = ls_amort-instl_amt + gs_amort_instl-instl_amt.
     modify lt_amort from ls_amort TRANSPORTING instl_amt where bukrs = gs_amort_instl-bukrs and gjahr = gs_amort_instl-gjahr and hkont = gs_amort_instl-hkont .
   else.
     MOVE-CORRESPONDING gs_amort_instl to ls_amort.
     append ls_amort to lt_amort.
   ENDIF.
  ENDLOOP.

  clear:  gt_amort_instl.




    CLEAR gs_current_ded.
    gs_current_ded-bukrs      = p_bukrs.
    gs_current_ded-venture    = gs_block_master-venture_code.
    gs_current_ded-gjahr      = gs_block_master-prod_date+0(4).
    gs_current_ded-hkont      = gs_gl_post_comm-hkont.
    gs_current_ded-amount     = gv_total_balance.
    gs_current_ded-description = 'Status P - Active GL Balance'.
    APPEND gs_current_ded TO gt_current_ded.

  ENDLOOP.
  gt_amort_instl = lt_amort.
ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form PROCESS_REVERSAL
**&---------------------------------------------------------------------*
**& Reversal of ZFI_CIT_AMORT entries
**& Marks installment rows as reversed and resets executed flags
**&---------------------------------------------------------------------*
FORM process_reversal.

  DATA: lt_amort_instl TYPE TABLE OF zfi_tax_sec42_5.

  " Read all installment entries for the venture/year
  SELECT * FROM zfi_tax_sec42_5
    INTO TABLE lt_amort_instl
    WHERE venture = p_jv
      AND bukrs   = p_bukrs.

  IF lt_amort_instl IS INITIAL.
    MESSAGE s008(zfi_sec42) WITH p_jv.
    MESSAGE: |No amortization entries found for venture { P_JV }| TYPE 'S'.
    " No amortization entries found for venture &1
    RETURN.
  ENDIF.

  " Mark all rows as reversed, reset executed flag
  LOOP AT lt_amort_instl INTO gs_amort_instl.
    gs_amort_instl-reversed = 'X'.
    gs_amort_instl-executed = ' '.
    MODIFY zfi_tax_sec42_5 FROM gs_amort_instl.
  ENDLOOP.

  " Update Amortization Schedule - mark as reversed
  SELECT * FROM zfi_tax_sec42_4
    INTO TABLE gt_amort_sch
    WHERE venture = p_jv
      AND bukrs   = p_bukrs.

  LOOP AT gt_amort_sch INTO gs_amort_sch.
    gs_amort_sch-reversed = 'X'.
    MODIFY zfi_tax_sec42_4 FROM gs_amort_sch.
  ENDLOOP.

*  MESSAGE s009(zfi_sec42) WITH p_jv  gs_block_master-surr_date+0(4).
  MESSAGE: |Reversal completed for venture { P_JV } fiscal year { gs_block_master-surr_date+0(4) }| TYPE 'S'.
  " Reversal completed for venture &1 fiscal year &2

ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form GET_GL_BALANCE
**&---------------------------------------------------------------------*
**& Read GL account balance (FAGLB03 equivalent)
**& Uses FAGLFLEXT for balance retrieval (ECC 6.0 New GL)
**&---------------------------------------------------------------------*
*FORM get_gl_balance
*  USING    iv_venture  TYPE char6
*           iv_hkont    TYPE hkont
*           iv_bukrs    TYPE bukrs
*           iv_gjahr    TYPE gjahr
*           iv_monat    TYPE monat
*  CHANGING cv_balance  TYPE wrbtr.
*
*  cv_balance = 0.
*
*  " Read from FAGLFLEXT (New GL totals table - ECC 6.0)
*  " Sum period columns up to the requested period
*  DATA: lv_hsl01 TYPE wrbtr, lv_hsl02 TYPE wrbtr,
*        lv_hsl03 TYPE wrbtr, lv_hsl04 TYPE wrbtr,
*        lv_hsl05 TYPE wrbtr, lv_hsl06 TYPE wrbtr,
*        lv_hsl07 TYPE wrbtr, lv_hsl08 TYPE wrbtr,
*        lv_hsl09 TYPE wrbtr, lv_hsl10 TYPE wrbtr,
*        lv_hsl11 TYPE wrbtr, lv_hsl12 TYPE wrbtr.
*
*  cv_balance = 0.
*
*  SELECT SUM( hsl01 ) SUM( hsl02 ) SUM( hsl03 )
*         SUM( hsl04 ) SUM( hsl05 ) SUM( hsl06 )
*         SUM( hsl07 ) SUM( hsl08 ) SUM( hsl09 )
*         SUM( hsl10 ) SUM( hsl11 ) SUM( hsl12 )
*    INTO (lv_hsl01, lv_hsl02, lv_hsl03,
*          lv_hsl04, lv_hsl05, lv_hsl06,
*          lv_hsl07, lv_hsl08, lv_hsl09,
*          lv_hsl10, lv_hsl11, lv_hsl12)
*    FROM faglflext
*    WHERE rbukrs = iv_bukrs
*      AND racct  = iv_hkont
*      AND gjahr  = iv_gjahr.
*
*  " Sum up to the requested period
*  IF iv_monat >= '01'. cv_balance = cv_balance + lv_hsl01. ENDIF.
*  IF iv_monat >= '02'. cv_balance = cv_balance + lv_hsl02. ENDIF.
*  IF iv_monat >= '03'. cv_balance = cv_balance + lv_hsl03. ENDIF.
*  IF iv_monat >= '04'. cv_balance = cv_balance + lv_hsl04. ENDIF.
*  IF iv_monat >= '05'. cv_balance = cv_balance + lv_hsl05. ENDIF.
*  IF iv_monat >= '06'. cv_balance = cv_balance + lv_hsl06. ENDIF.
*  IF iv_monat >= '07'. cv_balance = cv_balance + lv_hsl07. ENDIF.
*  IF iv_monat >= '08'. cv_balance = cv_balance + lv_hsl08. ENDIF.
*  IF iv_monat >= '09'. cv_balance = cv_balance + lv_hsl09. ENDIF.
*  IF iv_monat >= '10'. cv_balance = cv_balance + lv_hsl10. ENDIF.
*  IF iv_monat >= '11'. cv_balance = cv_balance + lv_hsl11. ENDIF.
*  IF iv_monat >= '12'. cv_balance = cv_balance + lv_hsl12. ENDIF.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**& Form GET_JV_TOTAL
**&---------------------------------------------------------------------*
**& Get JV transaction sub-totals from JVTO1
**&---------------------------------------------------------------------*
FORM get_jv_total
  USING    iv_venture   TYPE char6
           iv_hkont     TYPE hkont
           iv_flow_type TYPE char3
           iv_bukrs     TYPE bukrs
           iv_date TYPE datum
  CHANGING cv_total     TYPE wrbtr.
data: iv_gjahr type int4.
  TYPES: BEGIN OF ty_total,
    hslvt type jvto1-hslvt,
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
  iv_gjahr = iv_date+0(4).
  IF iv_date+4(2) < '4'.
    iv_gjahr = iv_gjahr - 1.
  ENDIF.

  DATA: ls_total TYPE ty_total.
  cv_total = 0.

  " Read JV transaction totals from JVTO1

  SELECT
    sum( hslvt ) as hslvt,
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
AND ryear  = @iv_gjahr
AND ranbwa = @iv_flow_type
    and RLDNR = '4A'.

  DATA: lv_count     TYPE numc2,
        lv_fieldname TYPE string,
        lv_loop type i.
  FIELD-SYMBOLS: <fs_value> TYPE any.
  lv_count = '01'.
  lv_fieldname = |HSLVT|.

    ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
    IF sy-subrc = 0.
      cv_total = cv_total + <fs_value>.
    ENDIF.

    IF iv_date+4(2) > '03'.
      lv_loop = iv_date+4(2) - 3.
    else.
      lv_loop = iv_date+4(2) + 9.
    ENDIF.

  DO lv_loop TIMES.
    lv_fieldname = |HSL{ lv_count }|.

    ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
    IF sy-subrc = 0.
      cv_total = cv_total + <fs_value>.
    ENDIF.
    lv_count = lv_count + 1.
  ENDDO.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& Display Section 42 deduction results using ALV
*&---------------------------------------------------------------------*
FORM display_output.

  DATA: lo_alv       TYPE REF TO cl_salv_table,
        lo_columns   TYPE REF TO cl_salv_columns_table,
        lo_column    TYPE REF TO cl_salv_column,
        lo_functions TYPE REF TO cl_salv_functions_list,
        lo_display   TYPE REF TO cl_salv_display_settings,
        lx_msg       TYPE REF TO cx_salv_msg.

  IF gt_amort_instl IS INITIAL.
*    MESSAGE s010(zfi_sec42).
    MESSAGE: |No Section 42 deductions found for the given selection| TYPE 'S' DISPLAY LIKE 'E'.
    " No Section 42 deductions found for the given selection
    RETURN.
  ELSE.
    DELETE gt_amort_sch WHERE total_amt IS INITIAL.
    DELETE gt_amort_instl WHERE instl_amt IS INITIAL.
    MOVE-CORRESPONDING gt_amort_instl TO gt_alv.
  ENDIF.
  IF gt_amort_instl is INITIAL.
    MESSAGE: |No Section 42 deductions found for the given selection| TYPE 'S' DISPLAY LIKE 'E'.
    return.
  ENDIF.

  PERFORM build_fieldcat.

*--- Layout
*  gs_layout-zebra = 'X'.
*  gs_layout-colwidth_optimize = 'X'.

*--- Display ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
*     i_callback_top_of_page   = 'TOP_OF_PAGE'
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
*     is_layout                = g_layout
      it_fieldcat              = gt_fieldcat
*     it_events                = it_events
      i_save                   = 'X'
*     is_variant               = l_wrk_variant
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
* FORM BUILD FIELDCAT
*---------------------------------------------------------------------*
FORM build_fieldcat.

  DEFINE add_field.
    gs_fieldcat-fieldname = &1.
    gs_fieldcat-seltext_m = &2.
    APPEND gs_fieldcat TO gt_fieldcat.
    CLEAR gs_fieldcat.
  END-OF-DEFINITION.

  add_field 'BUKRS'     'Company Code'.
  add_field 'VENTURE'   'Joint Venture'.
  add_field 'GJAHR'     'Fiscal Year'.
  add_field 'HKONT'     'GL Account'.
  add_field 'SURR_DATE' 'Date of Surrender'.
  add_field 'INSTL_AMT' 'Installment Amount'.

ENDFORM.

*---------------------------------------------------------------------*
* FORM PF STATUS
*---------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZALV_STATUS'.
ENDFORM.

*---------------------------------------------------------------------*
* FORM USER COMMAND
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN 'APPROVE'.
*      MESSAGE 'Custom Button Clicked!' TYPE 'I'.
      IF gs_block_master-sched_date IS NOT INITIAL.
        MESSAGE: 'Venture already processed' TYPE 'E'.
      ENDIF.

      gs_block_master-sched_date = sy-datum.
      MODIFY zfi_tax_sec42_1 FROM gs_block_master.
      IF sy-subrc IS INITIAL.
        MESSAGE: 'Program Succesfully executed' TYPE 'S'.
      ENDIF.

      MODIFY zfi_tax_sec42_5 FROM TABLE gt_amort_instl.
      MODIFY zfi_tax_sec42_4 FROM TABLE gt_amort_sch.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
* FORM DUMMY DATA (REMOVE IN REAL CODE)
*---------------------------------------------------------------------*


*
*  TRY.
*      cl_salv_table=>factory(
*        IMPORTING r_salv_table = lo_alv
*        CHANGING  t_table      = gt_alv ).
*
**       Enable ALV functions (sort, filter, export)
*      lo_functions = lo_alv->get_functions( ).
*      lo_functions->set_all( abap_true ).
*
**       Set column texts
*      lo_columns = lo_alv->get_columns( ).
*      lo_columns->set_optimize( abap_true ).
*
*      lo_column = lo_columns->get_column( 'BUKRS' ).
*      lo_column->set_short_text( 'CoCd' ).
*      lo_column->set_medium_text( 'Company Code' ).
*
*      lo_column = lo_columns->get_column( 'VENTURE' ).
*      lo_column->set_short_text( 'JV' ).
*      lo_column->set_medium_text( 'Joint Venture' ).
*
*      lo_column = lo_columns->get_column( 'GJAHR' ).
*      lo_column->set_short_text( 'FY' ).
*      lo_column->set_medium_text( 'Fiscal Year' ).
*
*      lo_column = lo_columns->get_column( 'HKONT' ).
*      lo_column->set_short_text( 'GL Acct' ).
*      lo_column->set_medium_text( 'GL Account' ).
*
*      lo_column = lo_columns->get_column( 'SURR_DATE' ).
*      lo_column->set_short_text( 'Surr Date' ).
*      lo_column->set_medium_text( 'Date of Surrender' ).
*
*      lo_column = lo_columns->get_column( 'INSTL_AMT' ).
*      lo_column->set_short_text( 'Amount' ).
*      lo_column->set_medium_text( 'Installment Amount' ).
**       Set display title
*      lo_display = lo_alv->get_display_settings( ).
*      lo_display->set_list_header( 'Section 42 Deductions - Current Year' ).
*      lo_display->set_striped_pattern( abap_true ).
*
*      lo_alv->display( ).
*
*    CATCH cx_salv_msg INTO lx_msg.
*      MESSAGE lx_msg TYPE 'E'.
*  ENDTRY.

*ENDFORM.







*FORM f_fetch_data .
*
*  DATA: lt_sec42_1 TYPE TABLE OF zfi_tax_sec42_1,
*        lt_sec42_3 TYPE TABLE OF zfi_tax_sec42_3,
*        lt_jvto1   TYPE TABLE OF jvto1,
*        lt_amort   TYPE TABLE OF zfi_tax_sec42_4,
*        ls_amort   TYPE zfi_tax_sec42_4.
*
*  "--- Fetch master tables
*  SELECT *
*    FROM zfi_tax_sec42_1
*    INTO TABLE @lt_sec42_1
*    WHERE vname = @p_jv
*      AND bukrs = @p_bukrs.
*
*  SELECT *
*    FROM zfi_tax_sec42_3
*    INTO TABLE @lt_sec42_3
*    WHERE bukrs = @p_bukrs.
*
*    IF lt_sec42_3 IS NOT INITIAL.
*
*  SELECT rldnr, ranbwa, tsl01, ryear, rpmax, rjvnam
*    FROM jvto1
*    INTO TABLE @data(lt_jvto1_tmp)
*    FOR ALL ENTRIES IN @lt_sec42_3
*    WHERE rldnr = @lt_sec42_3-saknr
*      AND ranbwa = @lt_sec42_3-flow_type
*      AND rpmax <= @p_rpmax.
*
*ENDIF.
*
*  IF lt_sec42_1 IS INITIAL.
*    RETURN.
*  ENDIF.
*
*  LOOP AT lt_sec42_1 INTO DATA(ls_sec42_1).
*
*    "-------------------------------
*    " CASE 1: STATUS = E
*    "-------------------------------
*    IF ls_sec42_1-claim_type = 'E'.
*
*      IF ls_sec42_1-status IS INITIAL.
*        " Close loop
*        CONTINUE.
*      ENDIF.
*
*    "-------------------------------
*    " CASE 2: STATUS = P
*    "-------------------------------
*    ELSEIF ls_sec42_1-claim_type = 'P'.
*
*      IF ls_sec42_1-status = 'X'.
*
*        " Fetch JVTO1 data once per GL + Flow type
*        LOOP AT lt_sec42_3 INTO DATA(ls_sec42_3).
**
**          SELECT rldnr, ranbwa, TSL01, ryear, rpmax, RJVNAM
**            FROM jvto1
**            INTO TABLE @DATA(lt_jvto1_tmp)
**            WHERE rldnr = @ls_sec42_3-saknr
**              AND ranbwa = @ls_sec42_3-flow_type
**              and rpmax <= @p_rpmax.
*
*          " Filter up to surrender period
*          LOOP AT lt_jvto1_tmp INTO DATA(ls_jvto1)
*               WHERE rpmax <= p_rpmax.
*
*            CLEAR ls_amort.
*            ls_amort-bukrs      = p_bukrs.
*            ls_amort-VNAME         = lS_jvto1-rjvnam.
*            ls_amort-RYEAR      = p_gjahr.
*            ls_amort-RLDNR      = ls_jvto1-rldnr.
*            ls_amort-surrENDER_date  = ls_sec42_1-surrender_date.
*            ls_amort-tot_amnt    = ls_jvto1-TSL01.
*            APPEND ls_amort TO lt_amort.
*          ENDLOOP.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*  "-----------------------------------
*  " AGGREGATION (SUBTOTAL)
*  "-----------------------------------
*  SORT lt_amort BY bukrs VNAME.
*  DATA: lt_final TYPE TABLE OF ZFI_TAX_SEC42_4.
*  DATA: ls_final TYPE ZFI_TAX_SEC42_4.
**
*  LOOP AT lt_amort INTO DATA(ls_data).
*    ls_final-bukrs     = ls_data-bukrs.
*    ls_final-vname        = ls_data-VNAME.
*    ls_final-ryear     = ls_data-RYEAR.
*    ls_final-rldnr     = ls_data-RLDNR.
*    ls_final-surrender_date = ls_data-surrender_date.
*
*    READ TABLE lt_final TRANSPORTING NO FIELDS with key bukrs = ls_final-bukrs vname = ls_final-vname.
*    IF sy-subrc is INITIAL.
*      ls_final-tot_amnt = ls_final-tot_amnt + ls_data-RLDNR.
*      ls_final-installment = ls_final-tot_amnt / 10.
*      modify lt_final from ls_final.
*    else.
*      ls_final-tot_amnt = ls_data-RLDNR.
*      ls_final-installment = ls_final-tot_amnt / 10.
*      append ls_final to lt_final.
*
*    ENDIF.
*  ENDLOOP.
*
**  "-----------------------------------
**  " INSERT INTO FINAL TABLE
**  "-----------------------------------
*  IF lt_final IS NOT INITIAL.
*
*    MODIFY ZFI_TAX_SEC42_4 FROM TABLE lt_final.
*
*    COMMIT WORK.
*
*  ENDIF.
**
*
*
*
*
*
**select *
**  from ZFI_TAX_SEC42_1
**  into table @data(lt_sec42_1)
**  where VNAME = @p_jv and bukrs = p_bukrs.
**
**select *
**  from ZFI_TAX_SEC42_3
**  into table @data(lt_sec42_3)
**  where bukrs = p_bukrs.
**
**  LOOP AT lt_sec42_1 into data(ls_sec42_1).
**    IF ls_sec42_1-claim_type = 'E'.
**      IF ls_sec42_1-status = ' '.
**        EXIT.
**      ENDIF.
**    ELSEIF ls_sec42_1-claim_type = 'P'.
**      IF ls_sec42_1-status = 'x'.
**        LOOP AT lt_sec42_3 into data(ls_sec42_3).
**          select *
**            from jvto1
**            into table @data(lt_jvto1)
**            where rldnr = ls_sec42_3-saknr and
**            RANBWA = ls_sec42_3-flow_type.
**
**        ENDLOOP.
**      ENDIF.
**    ENDIF.
**  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  F_MANIPULATE_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM f_manipulate_data .
*
*ENDFORM.
