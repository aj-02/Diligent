*&---------------------------------------------------------------------*
*& Report  ZFI_TAX_CREDIT_REPORT
*&
*&---------------------------------------------------------------------*
*&*---------------------------------------------------------------------*
* Program      : ZFI_TAX_CREDIT
* Author       : Rohit Yadav
* TR           : OCDK908501
* Date         : 18-11-2025
* Transaction  : ZFITAX
* Description  : Tax Credit Report Program
*---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_tax_credit_report.

INCLUDE zfi_cr_top.
*
*"<<< Added : Event Handler Class for ENTER refresh
*"==========================================================
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS handle_data_changed
                  FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_data_changed.

    LOOP AT er_data_changed->mt_mod_cells INTO DATA(ls_mod).

      DATA(lv_row)   = ls_mod-row_id.
      DATA(lv_field) = ls_mod-fieldname.

      " Only when ADJ_AMOUNT changed
      IF lv_field = 'ADJ_AMOUNT'.
        READ TABLE lt_final INTO DATA(ls_final) INDEX lv_row.
        IF sy-subrc = 0.
          ls_final-adj_amount = ls_mod-value.
          ls_final-final_amount = ls_final-amount_inr + ls_final-adj_amount.
          MODIFY lt_final FROM ls_final INDEX lv_row.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF l_alv_grid IS BOUND.
      l_alv_grid->refresh_table_display( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

"==========================================================




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

  SELECT * FROM zfitax_tran INTO TABLE @lt_data1  WHERE bukrs = @c_code AND period_from EQ @period-low AND period_to EQ @period-high AND zyear = @year.
  IF sy-subrc IS INITIAL.
    MESSAGE ' Creation not allowed. Data is already maintained'TYPE 'E'.
  ENDIF .
  SELECT capex_gl
  FROM zfi_tax_glpost
  INTO TABLE @DATA(lt_gl).
SORT LT_GL.
  DELETE ADJACENT DUPLICATES FROM lt_gl.
  SELECT * FROM ztax_cr_sheet INTO TABLE @lt_data WHERE bukrs = @c_code. "AND zyear = @year.
  IF sy-subrc IS INITIAL.
    SORT lt_data BY category sl_no.

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR: ls_final.
      ls_final-category = ls_data-category.
      ls_final-sl_no = ls_data-sl_no.
      ls_final-zyear = year.
      ls_final-bukrs = ls_data-bukrs.
      ls_final-pariticulars = ls_data-pariticulars.
      ls_final-acct_grp = ls_data-acct_grp.

*boc by arnav
      IF ls_data-venture_code IS NOT INITIAL.


        LOOP AT lt_gl INTO DATA(ls_gl).
          SELECT SUM( hsl )
            FROM jvso1
            INTO @DATA(lv_amnt)
            WHERE ryear = @year
            AND rbukrs = @c_code
            AND racct = @ls_gl-capex_gl
            AND rjvnam = @ls_data-venture_code.
        ENDLOOP.

        ls_final-amount_inr = lv_amnt.


      ENDIF.
      CLEAR: lv_amnt.
*eoc by arnav




      APPEND ls_final TO lt_final.
    ENDLOOP.

    SELECT * FROM setleaf INTO TABLE @DATA(lt_setleaf) FOR ALL ENTRIES IN @lt_data WHERE setname = @lt_data-acct_grp.

    SELECT * FROM setnode INTO TABLE @DATA(lt_setnode) FOR ALL ENTRIES IN @lt_data  WHERE setname = @lt_data-acct_grp.
    IF lt_setnode IS NOT INITIAL .
      SELECT * FROM setleaf INTO TABLE @DATA(set_leaf1) FOR ALL ENTRIES IN @lt_setnode WHERE setname = @lt_setnode-subsetname.
    ENDIF.


    TYPES :BEGIN OF ls_racct,
             racct    TYPE faglflext-racct,
             acct_grp TYPE setname,
             subset   TYPE subsetname,
           END OF ls_racct.

    DATA: lt_racct   TYPE TABLE OF ls_racct.
    DATA: st_racct   TYPE ls_racct.


*    DATA(set_leaf) = COND #( WHEN lt_setleaf IS NOT INITIAL THEN lt_setleaf ELSE set_leaf1 ).
    LOOP AT set_leaf1 INTO DATA(ls_leaf).
      IF ls_leaf-valsign = 'I'.
        CASE ls_leaf-valoption.
          WHEN 'EQ'.
            READ TABLE lt_setnode INTO DATA(ls_node) WITH KEY subsetname = ls_leaf-setname.
            IF sy-subrc EQ 0.
              st_racct-acct_grp = ls_node-setname.
            ENDIF.
            st_racct-subset = ls_leaf-setname.
            st_racct-racct = ls_leaf-valfrom.
            APPEND st_racct TO lt_racct.
          WHEN 'BT'.
            " Append all accounts in the range to internal table
            DO.
              DATA(lv_acc) = ls_leaf-valfrom + sy-index - 1.
              IF lv_acc > ls_leaf-valto.
                EXIT.
              ENDIF.
              READ TABLE lt_setnode INTO DATA(ls_node1) WITH KEY subsetname = ls_leaf-setname.
              IF sy-subrc EQ 0.
                st_racct-acct_grp = ls_node1-setname.
              ENDIF.
              st_racct-subset = ls_leaf-setname.
              st_racct-racct = lv_acc.
              APPEND st_racct TO lt_racct.
            ENDDO.
        ENDCASE.
      ENDIF.
    ENDLOOP.



    LOOP AT lt_setleaf INTO DATA(ls_leaf1).  ""2 loop
      IF ls_leaf1-valsign = 'I'.
        CASE ls_leaf1-valoption.
          WHEN 'EQ'.
**        READ TABLE lt_setnode INTO DATA(ls_node2)
**             WITH KEY subsetname = ls_leaf1-setname.
**        IF sy-subrc = 0.
            st_racct-acct_grp = ls_leaf1-setname..
**        ENDIF.

            st_racct-subset = ls_leaf1-setname.
            st_racct-racct  = ls_leaf1-valfrom.
            APPEND st_racct TO lt_racct.

          WHEN 'BT'.
            DO.
              DATA(lv_acc1) = ls_leaf1-valfrom + sy-index - 1.
              IF lv_acc1 > ls_leaf1-valto.
                EXIT.
              ENDIF.

*          READ TABLE lt_setnode INTO DATA(ls_node3)
*               WITH KEY subsetname = ls_leaf1-setname.
*          IF sy-subrc = 0.
              st_racct-acct_grp = ls_leaf1-setname..
*          ENDIF.

              st_racct-subset = ls_leaf1-setname.
              st_racct-racct  = lv_acc1.
              APPEND st_racct TO lt_racct.
            ENDDO.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    break abapuser02.
*
*    LOOP AT lt_data INTO ls_data.
*
*      IF ls_data-acct_grp CP '0123456789*'.
*
*        st_racct-acct_grp = ls_data-acct_grp.
*        st_racct-racct = ls_data-acct_grp.
*        APPEND st_racct TO lt_racct.
*        CLEAR :st_racct , ls_data.
*      ENDIF.
*    ENDLOOP.

    LOOP AT lt_racct ASSIGNING FIELD-SYMBOL(<fs_racct1>).

      <fs_racct1>-racct = |{ <fs_racct1>-racct ALPHA = IN }|.

    ENDLOOP.

    SORT lt_racct BY acct_grp racct.



    DATA: it_fl TYPE TABLE OF ty_fl.

    SELECT  * FROM faglflext INTO CORRESPONDING FIELDS OF  TABLE @it_fl  FOR ALL ENTRIES IN @lt_racct WHERE racct EQ @lt_racct-racct AND ryear EQ @year AND rbukrs EQ @c_code AND rldnr EQ '0L'.

    SORT it_fl BY racct.
    SORT lt_racct BY racct.

    LOOP AT it_fl ASSIGNING FIELD-SYMBOL(<fs_fl>).
      READ TABLE lt_racct ASSIGNING FIELD-SYMBOL(<fs_racct>)
           WITH KEY racct = <fs_fl>-racct
           BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_fl>-acct_grp = <fs_racct>-acct_grp.
      ENDIF.
    ENDLOOP.


    SORT it_fl BY acct_grp racct.
*
*    DATA: lv_sum_hsl   TYPE faglflext-hsl01,
*          lv_sum_ksl   TYPE faglflext-hsl01,
*          lv_fieldname TYPE string.


*    LOOP AT it_fl INTO DATA(ls_fl).
*
*      " Initialize sum variables for this account group
**  CLEAR: lv_sum_hsl, lv_sum_ksl.
*
*      LOOP AT period INTO DATA(ls_range).
*        DATA(lv_low)  = ls_range-low.
*        DATA(lv_high) = ls_range-high.
*
*        IF lv_high IS INITIAL.
*          lv_high = lv_low.
*        ENDIF.
*
*        DO lv_high - lv_low + 1 TIMES.
*          DATA(lv_period) = lv_low + sy-index - 1.
*
*          " ---- HSL sum ----
*          DATA lv_hsl_field TYPE string.
*          IF lv_period < 10.
*            lv_hsl_field = |HSL0{ lv_period }|.
*          ELSE.
*            lv_hsl_field = |HSL{ lv_period }|.
*          ENDIF.
*
*          ASSIGN COMPONENT lv_hsl_field OF STRUCTURE ls_fl TO FIELD-SYMBOL(<fs_hsl>).
*          IF sy-subrc = 0 AND <fs_hsl> IS ASSIGNED.
*            lv_sum_hsl = lv_sum_hsl + <fs_hsl>.
*          ENDIF.
*
*          " ---- KSL sum ----
*          DATA lv_ksl_field TYPE string.
*          IF lv_period < 10.
*            lv_ksl_field = |KSL0{ lv_period }|.
*          ELSE.
*            lv_ksl_field = |KSL{ lv_period }|.
*          ENDIF.
*
*          ASSIGN COMPONENT lv_ksl_field OF STRUCTURE ls_fl TO FIELD-SYMBOL(<fs_ksl>).
*          IF sy-subrc = 0 AND <fs_ksl> IS ASSIGNED.
*            lv_sum_ksl = lv_sum_ksl + <fs_ksl>.
*          ENDIF.
*
*        ENDDO.
*      ENDLOOP.
*      " At end of account group, update total table
*      AT END OF acct_grp.
*
*        LOOP AT lt_final INTO DATA(ls_total) WHERE acct_grp = ls_fl-acct_grp.
*          ls_total-amount_inr = lv_sum_hsl. " HSL sum
*
*
*          MODIFY lt_final FROM ls_total.
*        ENDLOOP.
*
*      ENDAT.
*
*    ENDLOOP.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    SORT it_fl BY acct_grp racct.

    "------------------------------------------------------
    "  Declare sum variables and previous account group tracker
    "------------------------------------------------------
    DATA: lv_sum_hsl   TYPE faglflext-hsl01,
          lv_sum_ksl   TYPE faglflext-hsl01,
          lv_prev_acct TYPE ty_fl-acct_grp.

    FIELD-SYMBOLS: <fs_hsl> TYPE faglflext-hsl01,
                   <fs_ksl> TYPE faglflext-hsl01,
                   <tot>    TYPE st_temp.

    CLEAR: lv_sum_hsl, lv_sum_ksl, lv_prev_acct.

    "------------------------------------------------------
    "  Main LOOP over input table
    "------------------------------------------------------
    LOOP AT it_fl INTO DATA(ls_fl).

      "-------------------------------------------
      " Control break: if account group changed
      "-------------------------------------------
      IF lv_prev_acct IS NOT INITIAL AND lv_prev_acct <> ls_fl-acct_grp.

*        LOOP AT lt_total ASSIGNING <tot> WHERE acct_grp = lv_prev_acct.
*          <tot>-ecc_inr = lv_sum_hsl.
*          <tot>-ecc_usd = lv_sum_ksl.
*
*          IF <tot>-rate = 'INR_ACT'.
*            <tot>-final_inr = lv_sum_hsl.
*          ELSEIF <tot>-rate = 'AVG' AND lv_sum_hsl IS NOT INITIAL.
*            <tot>-final_inr = lv_sum_hsl * lv_ukurs.
*          ENDIF.
*        ENDLOOP.

        LOOP AT lt_final INTO DATA(ls_total) WHERE acct_grp = lv_prev_acct.
          ls_total-amount_inr = lv_sum_hsl. " HSL sum


          MODIFY lt_final FROM ls_total.
        ENDLOOP.

        " Clear sums for new account group
        CLEAR: lv_sum_hsl, lv_sum_ksl.

      ENDIF.

      "-------------------------------------------
      "  HSL / KSL summation for current row
      "-------------------------------------------
      LOOP AT period INTO DATA(ls_range).
        DATA(lv_low)  = ls_range-low.
        DATA(lv_high) = ls_range-high.
        IF lv_high IS INITIAL.
          lv_high = lv_low.
        ENDIF.

        DO lv_high - lv_low + 1 TIMES.
          DATA(lv_period) = lv_low + sy-index - 1.

          " Build HSL field name (HSL01, HSL02 ...)
          DATA lv_hsl_field TYPE string.
          IF lv_period < 10.
            lv_hsl_field = |HSL0{ lv_period }|.
          ELSE.
            lv_hsl_field = |HSL{ lv_period }|.
          ENDIF.
          ASSIGN COMPONENT lv_hsl_field OF STRUCTURE ls_fl TO <fs_hsl>.
          IF sy-subrc = 0 AND <fs_hsl> IS ASSIGNED.
            lv_sum_hsl = lv_sum_hsl + <fs_hsl>.
          ENDIF.

          " Build KSL field name (KSL01, KSL02 ...)
          DATA lv_ksl_field TYPE string.
          IF lv_period < 10.
            lv_ksl_field = |KSL0{ lv_period }|.
          ELSE.
            lv_ksl_field = |KSL{ lv_period }|.
          ENDIF.
          ASSIGN COMPONENT lv_ksl_field OF STRUCTURE ls_fl TO <fs_ksl>.
          IF sy-subrc = 0 AND <fs_ksl> IS ASSIGNED.
            lv_sum_ksl = lv_sum_ksl + <fs_ksl>.
          ENDIF.

        ENDDO.
      ENDLOOP.

      "-------------------------------------------
      "  Save current account group for next iteration
      "-------------------------------------------
      lv_prev_acct = ls_fl-acct_grp.

    ENDLOOP.

    "------------------------------------------------------
    "  Update totals for the last account group
    "------------------------------------------------------
    IF lv_prev_acct IS NOT INITIAL.
*      LOOP AT lt_total ASSIGNING <tot> WHERE acct_grp = lv_prev_acct.
*        <tot>-ecc_inr = lv_sum_hsl.
*        <tot>-ecc_usd = lv_sum_ksl.
*
*        IF <tot>-rate = 'INR_ACT'.
*          <tot>-final_inr = lv_sum_hsl.
*        ELSEIF <tot>-rate = 'AVG' AND lv_sum_hsl IS NOT INITIAL.
*          <tot>-final_inr = lv_sum_hsl * lv_ukurs.
*        ENDIF.
*      ENDLOOP.

      LOOP AT lt_final INTO DATA(ls_total2) WHERE acct_grp = lv_prev_acct.
        ls_total2-amount_inr = lv_sum_hsl. " HSL sum


        MODIFY lt_final FROM ls_total2.
      ENDLOOP.

    ENDIF.





    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''''''''''''''''''''''''''''''''''''''''''''


  ELSE .

    MESSAGE ' Record not found' TYPE 'E'.


  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''''''''''''


  EXPORT a = a TO MEMORY ID 'ALV_RETURN1'.

  SUBMIT zfitax_pbt_calc_prg
    WITH c_code = c_code
    WITH year   = year
    WITH period IN period
    AND RETURN.

  IMPORT lt_total = lt_total FROM MEMORY ID 'ALV_RETURN'.
  DATA : sum TYPE z_final_amt .
*  LOOP AT lt_total INTO DATA(ls_total1).

  READ TABLE lt_total INTO DATA(ls_tot)  WITH KEY description = 'PROFIT/(LOSS) BEFORE TAX (V - VI)'.
  IF sy-subrc EQ 0.

    sum = ls_tot-final_inr.

  ENDIF.


*  ENDLOOP.
  ls_final-pariticulars = 'PROFIT'.
*ls_final-amount_inr  = lv_profit.   " if you have calculated profit
  ls_final-adj_remark  = ''.
  sum = sum * -1.
  ls_final-amount_inr  = sum.
  ls_final-final_amount = ''.
  ls_final-sl_no = ' '.

  ls_final-period_from = period-low.
  ls_final-period_to = period-high.
  ls_final-zyear =  year.
  ls_final-bukrs = c_code.
*   ... fill only fields you need

  INSERT ls_final INTO lt_final INDEX 1.
  DATA: lv_amnt1 TYPE numc255.
  data: lv_val type zdec16_5.
  lv_amnt1 = sum.
  CLEAR: ls_final.
  LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<ls_final>).
*    IF <ls_final>-category = 'M' AND <ls_final>-sl_no = '0'.
*      lv_amnt1 = lv_amnt1 + <ls_final>-amount_inr.
*    ENDIF.
    IF <ls_final>-category = 'C' AND <ls_final>-sl_no = '20'.
      SELECT SUM( exdiff )
        FROM zfitax_dif
        INTO @DATA(lv_sum1).
      <ls_final>-amount_inr = lv_sum1.
    ENDIF.
    IF <ls_final>-category = 'A' OR <ls_final>-category = 'C'.

      IF <ls_final>-category = 'A' AND <ls_final>-sl_no = '7'.

        IF <ls_final>-amount_inr GT 0.
          DATA(lv_flag) = 'X'.
          CLEAR: <ls_final>-amount_inr.
        ENDIF.
      ENDIF.

      IF <ls_final>-category = 'A'.
        <ls_final>-amount_inr = <ls_final>-amount_inr * -1.
      ENDIF.
      lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
    ELSEIF <ls_final>-category = 'B'.
      IF <ls_final>-sl_no = '22' AND lv_flag = ' '.
        CLEAR: <ls_final>-amount_inr.
      ENDIF.
      lv_amnt1 = lv_amnt1 + <ls_final>-amount_inr.
    ELSEIF <ls_final>-category = 'D' AND <ls_final>-sl_no = '2'.
      <ls_final>-amount_inr = lv_amnt1.
    ENDIF.
  ENDLOOP.
  UNASSIGN: <ls_final>.
*  CLEAR: LV_AMNT1.

  SELECT *
    FROM zfi_cit_rates
    INTO TABLE @DATA(lt_rate1)
    WHERE gjahr = @year.

  SELECT *
    FROM zfi_ltcg_rates
    INTO TABLE @DATA(lt_rate2)
    WHERE gjahr = @year.
  SELECT *
    FROM zfitax_tran_mat
    INTO TABLE @DATA(lt_mat).

  DATA: lv_sum2   TYPE zdec16_5,
        lv_sum5   TYPE faglflexa-hsl,
        ls_final1 TYPE zfi_tax_80m.
  LOOP AT lt_final ASSIGNING <ls_final>.

    IF <ls_final>-category = 'E' .
      IF <ls_final>-sl_no = '1'.
        DATA(lv_calc) = <ls_final>-amount_inr * -1.
      lv_val = lv_val + <ls_final>-amount_inr.
      ENDIF.
      IF <ls_final>-sl_no = '2'.
        DATA(lv_calc2) = <ls_final>-amount_inr * -1.
      lv_val = lv_val + <ls_final>-amount_inr.
      ENDIF.
*      <ls_final>-amount_inr = <ls_final>-amount_inr * -1.
      lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
    ELSEIF <ls_final>-category = 'F' AND <ls_final>-sl_no = '1'.
      <ls_final>-amount_inr = lv_amnt1.
    ENDIF.
    IF <ls_final>-category = 'G' AND <ls_final>-sl_no = '1'.
      DATA: lv_date_from TYPE budat,
            lv_date_to   TYPE budat.
      lv_date_from = |{ year }0401|.           "01-Apr-FY
      lv_date_to   = |{ year + 1 }1031|.       "31-Oct next year

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*      SELECT belnr,
*             ryear,
*             rbukrs,
*             hsl
*        INTO TABLE @DATA(lt_fagl)
*        FROM faglflexa
*       WHERE racct  = '0000160203'
*         AND rbukrs = @c_code
*        AND rldnr = '0L'
*         AND rassc  = 'ONGC'
*         AND budat BETWEEN @lv_date_from AND @lv_date_to.
        SELECT AccountingDocument     AS belnr,
               FiscalYear             AS gjahr,
               CompanyCode            AS bukrs,
               AccountingDocumentItem AS buzei
          FROM i_operationalacctgdocitem
          FOR ALL ENTRIES IN @lt_fagl
          WHERE AccountingDocument = @lt_fagl-belnr
            AND FiscalYear         = @lt_fagl-ryear
            AND CompanyCode        = @lt_fagl-rbukrs
            AND Reference3IDByBusinessPartner = 'DIVIDEND'
          ORDER BY CompanyCode, AccountingDocument, FiscalYear, AccountingDocumentItem
          INTO TABLE @DATA(lt_bseg_add).
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

      IF sy-subrc IS INITIAL.
        SELECT belnr,
           gjahr,
           bukrs,
          BUZEI
      INTO TABLE @DATA(lt_bseg_add)
      FROM bseg
      FOR ALL ENTRIES IN @lt_fagl
     WHERE belnr = @lt_fagl-belnr
       AND gjahr = @lt_fagl-ryear
       AND bukrs = @lt_fagl-rbukrs
       AND xref3 = 'DIVIDEND' ORDER BY PRIMARY KEY.
        IF sy-subrc IS INITIAL.
          LOOP AT lt_fagl INTO DATA(ls_fagl).

            READ TABLE lt_bseg_add INTO DATA(ls_bseg)
                 WITH KEY belnr = ls_fagl-belnr
                          gjahr = ls_fagl-ryear
                          bukrs = ls_fagl-rbukrs.

            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            DELETE FROM zfi_tax_80m
             WHERE belnr = ls_fagl-belnr
               AND gjahr = ls_fagl-ryear
               AND bukrs = ls_fagl-rbukrs.

            CLEAR ls_final1.

            ls_final1-belnr = ls_fagl-belnr.
            ls_final1-gjahr = ls_fagl-ryear.
            ls_final1-bukrs = ls_fagl-rbukrs.
            ls_final1-amnt   = ls_fagl-hsl.
            ls_final1-claim_year = year.

            INSERT zfi_tax_80m FROM ls_final1.

            lv_sum5 = lv_sum5 + ls_fagl-hsl.

          ENDLOOP.
          <ls_final>-amount_inr = lv_sum5.
        ENDIF.
      ENDIF.


    ENDIF.
    IF <ls_final>-category = 'G' .
      lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
    ELSEIF <ls_final>-category = 'H'.
      <ls_final>-amount_inr = lv_amnt1.
    ENDIF.
    IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '1'.
      READ TABLE lt_rate1 INTO DATA(ls_rate1) INDEX 1.
      LV_AMNT1 = LV_AMNT1 + LV_VAL.
      <ls_final>-amount_inr = lv_amnt1 * ls_rate1-effective_cit / 100.
      lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
    ENDIF.
    IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '10'.
      READ TABLE lt_rate2 INTO DATA(ls_rate2) INDEX 1.
      <ls_final>-amount_inr = lv_calc * ls_rate2-ltcg_rates / 100.
      lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
    ENDIF.

    IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '20'.
      READ TABLE lt_rate2 INTO ls_rate2 INDEX 1.
      <ls_final>-amount_inr = lv_calc2 * ls_rate2-ltcg_rates_wi / 100.

      lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
    ENDIF.
    IF <ls_final>-category = 'J' AND <ls_final>-sl_no = '1'.
      <ls_final>-amount_inr = lv_sum2.
    ENDIF.
    IF <ls_final>-category = 'J' AND <ls_final>-sl_no = '10'.
      READ TABLE lt_mat INTO DATA(ls_mat) WITH KEY category = 'G' sl_no = '10'.
      <ls_final>-amount_inr = ls_mat-final_amount.
    ENDIF.
  ENDLOOP.





ENDFORM.


FORM save_data .
  DATA: lv_sum2 TYPE zdec16_5.
  DATA: lv_sum3 TYPE zdec16_5.
  DATA: lv_amnt1 TYPE numc255.
  DATA: LV_VAL TYPE zdec16_5.
*  lv_amnt1 = sum.
  SELECT *
  FROM zfi_cit_rates
  INTO TABLE @DATA(lt_rate1)
  WHERE gjahr = @year.

  SELECT *
    FROM zfi_ltcg_rates
    INTO TABLE @DATA(lt_rate2)
    WHERE gjahr = @year.
  SELECT *
    FROM zfitax_tran_mat
    INTO TABLE @DATA(lt_mat).
  IF l_alv_grid IS BOUND.
    l_alv_grid->check_changed_data(
       IMPORTING
         e_valid   = DATA(l_valid)                 " Entries are Consistent
    ).
    IF l_valid IS NOT INITIAL.
      CALL METHOD l_alv_grid->get_selected_rows
        IMPORTING
          et_index_rows = it_index                 " Indexes of Selected Rows
          et_row_no     = it_row.                " Numeric IDs of Selected Rows
      IF it_index IS NOT INITIAL.
        LOOP AT it_index INTO DATA(wa_index).
          READ TABLE lt_final INTO DATA(wa_final) INDEX wa_index-index.
          IF sy-subrc = 0.
*            IF wa_final-amount    IS INITIAL AND
*               wa_final-bukrs    IS INITIAL AND
*               wa_final-changes_amount    IS INITIAL AND
*               wa_final-gl_head   IS INITIAL AND
*               wa_final-zyear          IS INITIAL AND
*               wa_final-amount        IS INITIAL.
*
*              MESSAGE 'Please enter all details ' TYPE 'E'.
*            ENDIF.
            wa_final-final_amount = wa_final-amount_inr + wa_final-adj_amount.
            wa_final-period_from = period-low.
            wa_final-period_to = period-high.
            IF wa_final-category = 'M' AND wa_final-sl_no = '0'.
              lv_amnt1 = lv_amnt1 + wa_final-final_amount.
            ENDIF.
            IF wa_final-category = 'A' OR wa_final-category = 'C'.
*              IF wa_final-category = 'A' AND wa_final-sl_no = '7'.

*                IF wa_final-amount_inr GT 0.
*                  DATA(lv_flag) = 'X'.
*                  CLEAR: wa_final-amount_inr.
*                ENDIF.
*              ENDIF.

*              IF wa_final-category = 'A'.
*                wa_final-amount_inr = wa_final-amount_inr * -1.
*              ENDIF.
              lv_amnt1 = lv_amnt1 - wa_final-final_amount.
            ELSEIF wa_final-category = 'B'.
              lv_amnt1 = lv_amnt1 + wa_final-final_amount.
            ELSEIF wa_final-category = 'D' AND wa_final-sl_no = '2'.
              wa_final-final_amount = lv_amnt1.
            ENDIF.
            IF wa_final-category = 'C' AND wa_final-sl_no = '20'.
*              SELECT SUM( exdiff )
*          FROM zfitax_dif
*                INTO @DATA(lv_sum1).
*              wa_final-final_amount = lv_sum1.
            ENDIF.
            IF wa_final-category = 'E' .
              IF wa_final-sl_no = '1'.
                IF wa_final-final_amount < 0.
                DATA(lv_calc) = wa_final-final_amount * -1.
      lv_val = lv_val + wa_final-final_amount.
                else.
                lv_calc = wa_final-final_amount * -1.
      lv_val = lv_val + wa_final-final_amount.
                ENDIF.
              ENDIF.
              IF wa_final-sl_no = '2'.
                IF wa_final-final_amount < 0.
                DATA(lv_calc2) = wa_final-final_amount * -1.
      lv_val = lv_val + WA_FINAL-final_amount.
                else.
                lv_calc2 = wa_final-final_amount * -1.
      lv_val = lv_val + WA_FINAL-final_amount.
                ENDIF.
              ENDIF.
*              wa_final-final_amount = wa_final-final_amount * -1.
              lv_amnt1 = lv_amnt1 - wa_final-final_amount.
            ELSEIF wa_final-category = 'F' AND wa_final-sl_no = '1'.
              wa_final-final_amount = lv_amnt1.
            ENDIF.
            IF wa_final-category = 'G' .
              lv_amnt1 = lv_amnt1 - wa_final-final_amount.
            ELSEIF wa_final-category = 'H'.
              wa_final-final_amount = lv_amnt1.
            ENDIF.
            IF wa_final-category = 'I' AND wa_final-sl_no = '1'.
              READ TABLE lt_rate1 INTO DATA(ls_rate1) INDEX 1.
              LV_AMNT1 = LV_AMNT1 + LV_VAL.
              wa_final-final_amount = lv_amnt1 * ls_rate1-effective_cit / 100.
              lv_sum2 = lv_sum2 + wa_final-final_amount.
            ENDIF.
            IF wa_final-category = 'I' AND wa_final-sl_no = '10'.
              READ TABLE lt_rate2 INTO DATA(ls_rate2) INDEX 1.
              wa_final-final_amount = lv_calc * ls_rate2-ltcg_rates / 100.
              lv_sum2 = lv_sum2 + wa_final-final_amount.
            ENDIF.

            IF wa_final-category = 'I' AND wa_final-sl_no = '20'.
              READ TABLE lt_rate2 INTO ls_rate2 INDEX 1.
              wa_final-final_amount = lv_calc2 * ls_rate2-ltcg_rates_wi / 100.
              lv_sum2 = lv_sum2 + wa_final-final_amount.
            ENDIF.
            IF wa_final-category = 'J' AND wa_final-sl_no = '1'.
              wa_final-final_amount = lv_sum2.
            ENDIF.
            IF wa_final-category = 'J' AND wa_final-sl_no = '10'.
              READ TABLE lt_mat INTO DATA(ls_mat) WITH KEY category = 'G' sl_no = '10'.
              wa_final-final_amount = ls_mat-final_amount.
              lv_sum3 = wa_final-final_amount.
            ENDIF.
            IF wa_final-category = 'J' AND wa_final-sl_no = '20'.
*      READ TABLE lt_mat into data(ls_mat) with key category = 'G' sl_no = '10'.
              IF lv_sum3 > lv_sum2.
                wa_final-final_amount = lv_sum3.
              ELSE.
                wa_final-final_amount = lv_sum2.
              ENDIF.
            ENDIF.

            MODIFY zfitax_tran FROM wa_final.
            MODIFY lt_final FROM wa_final INDEX wa_index-index.
            IF sy-subrc = 0.
              COMMIT WORK AND WAIT.
              MESSAGE 'Data Saved Successfully' TYPE 'S'.
              CLEAR: wa_final, wa_index.
            ENDIF.
          ENDIF.
        ENDLOOP.
        CALL METHOD l_alv_grid->refresh_table_display
          EXCEPTIONS
            finished = 1                " Display was Ended (by Export)
            OTHERS   = 2.
      ELSE.
        MESSAGE 'Please select all the records and then click the Save button' TYPE 'E' DISPLAY LIKE'I'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.


FORM process_print.

  IMPORT original revised chng disp crea app FROM MEMORY ID 'ZFI_DATA'.

  IF original = 'X'.
    wa_fcat-fieldname = 'SL_NO'.
    wa_fcat-coltext   = 'SL No'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'SL_NO'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.


    wa_fcat-fieldname = 'PARITICULARS'.
    wa_fcat-coltext   = 'Pariticulars'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'PARITICULARS'.
    wa_fcat-outputlen = 80.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'AMOUNT_INR'.
    wa_fcat-coltext   = 'Amount(in Rs)'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'AMOUNT_INR'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'ADJ_AMOUNT'.
    wa_fcat-coltext   = 'Adj.Amount(in Rs)'.
    IF disp NE 'X' AND app NE 'X'.
      wa_fcat-edit      = 'X'.
    ENDIF.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'ADJ_AMOUNT'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'FINAL_AMOUNT'.
    wa_fcat-coltext   = 'Final.Amount(in Rs)'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'FINAL_AMOUNT'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.



**    wa_fcat-fieldname = 'ADJ_REMARK'.
**    wa_fcat-coltext   = 'Adj.Remark'.
**    IF disp NE 'X' AND app NE 'X'.
**      wa_fcat-edit      = 'X'.
**    ENDIF.
**
**    wa_fcat-ref_table = 'ZFITAX_TRAN'.
**    wa_fcat-ref_field = 'ADJ_REMARK'.
**    wa_fcat-outputlen  = 120.
**    wa_fcat-col_opt = abap_false.
**    APPEND wa_fcat TO it_fcat.
**    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'ADJ_REMARK'.
    wa_fcat-coltext   = 'Adj.Remark'.
    wa_fcat-outputlen = 60.
    IF disp NE 'X' AND app NE 'X'.
      wa_fcat-edit      = 'X'.
    ENDIF.

*    wa_fcat-ref_table = 'ZFITAX_TRAN'.
*    wa_fcat-ref_field = 'ADJ_REMARK'.
*    wa_fcat-outputlen  = 120.
    wa_fcat-col_opt = abap_false.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.




  ENDIF.



  IF revised = 'X'.
    wa_fcat-fieldname = 'SL_NO'.
    wa_fcat-coltext   = 'SL No'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'SL_NO'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.


    wa_fcat-fieldname = 'PARITICULARS'.
    wa_fcat-coltext   = 'Pariticulars'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'PARITICULARS'.
    wa_fcat-outputlen = 40.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'AMOUNT_INR'.
    wa_fcat-coltext   = 'Amount(in Rs)'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'AMOUNT_INR'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'ADJ_AMOUNT'.
    wa_fcat-coltext   = 'Adj.Amount(in Rs)'.
*    IF disp NE 'X' AND app NE 'X'.
*      wa_fcat-edit      = 'X'.
*    ENDIF.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'ADJ_AMOUNT'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

    wa_fcat-fieldname = 'FINAL_AMOUNT'.
    wa_fcat-coltext   = 'Final.Amount(in Rs)'.
*  wa_fcat-edit      = 'X'.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'FINAL_AMOUNT'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.



    wa_fcat-fieldname = 'ADJ_REMARK'.
    wa_fcat-coltext   = 'Adj.Remark'.
*    IF disp NE 'X' AND app NE 'X'.
*      wa_fcat-edit      = 'X'.
*   ENDIF.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-outputlen = 60.
    wa_fcat-ref_field = 'ADJ_REMARK'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.



    wa_fcat-fieldname = 'REVIS_AMT'.
    wa_fcat-coltext   = 'Revision Amount'.
    IF disp NE 'X' AND app NE 'X'.
      wa_fcat-edit      = 'X'.
    ENDIF.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'REVIS_AMT'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.


    wa_fcat-fieldname = 'REVIS_REMARK'.
    wa_fcat-coltext   = 'Revision Remark'.
    IF disp NE 'X' AND app NE 'X'.
      wa_fcat-edit      = 'X'.
    ENDIF.
    wa_fcat-ref_table = 'ZFITAX_TRAN'.
    wa_fcat-ref_field = 'REVIS_REMARK'.
    APPEND wa_fcat TO it_fcat.
    CLEAR  wa_fcat.

  ENDIF.

  DATA :lv_date TYPE char10.
  lv_date = sy-datum.
  lv_date = |{ lv_date+6(2) }.{ lv_date+4(2) }.{ lv_date(4) }|.

*  wa_lay-grid_title = |Fiscal Year: { year }   Period: { period-low } to { period-high }   System Date: { lv_date } |.
  wa_lay-grid_title = |Company Code: { c_code }  Fiscal Year: { year }   Period: { period-low } to { period-high }  |.



  IF lt_data IS NOT INITIAL.
    TRY.
        l_alv_grid = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen  ).
        l_alv_grid->set_table_for_first_display(
                EXPORTING
                  is_variant                    = wa_variant                 " Layout
                  i_save                        = l_alv_save_a               " Save Layout
                  i_default                     = 'X'                        " Default Display Variant
                  is_layout                     = wa_lay                     " Layout
                CHANGING
                  it_outtab                     = lt_final                  " Output Table
                  it_fieldcatalog               = it_fcat                    " Field Catalog
                EXCEPTIONS
                  invalid_parameter_combination = 1                           " Wrong Parameter
                  program_error                 = 2                           " Program Errors
                  too_many_lines                = 3                           " Too many Rows in Ready for Input Grid
                  OTHERS                        = 4
              ).


*        DATA(lo_event) = NEW lcl_event_handler( ).
*        SET HANDLER lo_event->handle_data_changed FOR l_alv_grid.


        DATA(lo_event) = NEW lcl_event_handler( ).
        SET HANDLER lo_event->handle_data_changed FOR l_alv_grid.

        l_alv_grid->register_edit_event(
          i_event_id = cl_gui_alv_grid=>mc_evt_enter
        ).
*        "******************************************************

        CALL SCREEN 100.


      CATCH cx_root.
        MESSAGE 'Error In Alv Creation' TYPE 'E'.
    ENDTRY.

  ELSE.

    MESSAGE 'Data not found ' TYPE 'E'.

  ENDIF.



ENDFORM.

INCLUDE zfi_tax_credit_report_statuo01.
