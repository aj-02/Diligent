*----------------------------------------------------------------------*
***INCLUDE MZPSJVCCFCFORMS_USER_COMMANI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0130 INPUT.

  SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno.

  SELECT SINGLE * FROM zjvc_cc_astblk INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin.
  IF sy-subrc EQ 0.



  ENDIF.

  IF zjvc_cc_fcforms-bukrs IS NOT INITIAL .
    SELECT SINGLE * FROM zjvc_ovl_ob INTO @DATA(ob_ovl) WHERE bukrs =  @zjvc_cc_fcforms-bukrs .
  ELSE.
    SELECT SINGLE * FROM zjvc_ovl_ob INTO ob_ovl WHERE bukrs =  'OVL' .

  ENDIF.
*  IF sy-subrc EQ 0.

  IF g_tcode NE 'ZJVCCFC2'  AND g_tcode NE 'ZJVCCFC3' AND g_tcode NE 'ZJVCCFC5'.


    SELECT * FROM zjvc_cc_fcforms INTO TABLE @DATA(lt_tran) WHERE ei_forgnenty_uin EQ @zjvc_cc_fcforms-ei_forgnenty_uin .

    LOOP AT lt_tran INTO DATA(ls_tran).

      total_equity_usd  = total_equity_usd  + ls_tran-forgn_fincommitusd_eqt.
      total_equity_euro = total_equity_euro + ls_tran-forgn_fincommiteur_eqt.
      total_equity_gbp = total_equity_gbp + ls_tran-forgn_fincommitgbp_eqt.
      total_equity_eq_usd = total_equity_eq_usd + ls_tran-forgn_fincommitfcy_eqt.
      total_equity_eq_inr = total_equity_eq_inr + ls_tran-forgn_fincommitinr_eqt.

      total_loan_usd = total_loan_usd + ls_tran-forgn_fincommitusd_loan.
      total_loan_euro  =  total_loan_euro  + ls_tran-forgn_fincommiteur_loan.
      total_loan_gbp  = total_loan_gbp  + ls_tran-forgn_fincommitgbp_loan.
      total_loan_eq_usd  = total_loan_eq_usd  + ls_tran-forgn_fincommitfcy_loan.
      total_loan_eq_inr  = total_loan_eq_inr  + ls_tran-forgn_fincommitinr_loan.

      total_pg_eq_usd = total_pg_eq_usd + ls_tran-forgn_fincommitfcy_pfgrnt.
      total_pg_eq_inr = total_pg_eq_inr + ls_tran-forgn_fincommitinr_pfgrnt.

      total_cg_eq_usd = total_cg_eq_usd + ls_tran-forgn_fincommitfcy_corgrnt.
      total_cg_eq_inr = total_cg_eq_inr + ls_tran-forgn_fincommitinr_corgrnt.

    ENDLOOP.

  ELSE.

    CLEAR lt_tran.

    SELECT * FROM zjvc_cc_fcforms INTO TABLE @lt_tran WHERE ei_forgnenty_uin EQ @zjvc_cc_fcforms-ei_forgnenty_uin
       AND doc_no LT  @zjvc_cc_fcforms-doc_no .
**    DELETE lt_tran WHERE doc_no EQ zjvc_cc_fcforms-doc_no.
    LOOP AT lt_tran INTO ls_tran.
      total_equity_usd  = total_equity_usd  + ls_tran-forgn_fincommitusd_eqt.
      total_equity_euro = total_equity_euro + ls_tran-forgn_fincommiteur_eqt.
      total_equity_gbp = total_equity_gbp + ls_tran-forgn_fincommitgbp_eqt.
      total_equity_eq_usd = total_equity_eq_usd + ls_tran-forgn_fincommitfcy_eqt.
      total_equity_eq_inr = total_equity_eq_inr + ls_tran-forgn_fincommitinr_eqt.

      total_loan_usd = total_loan_usd + ls_tran-forgn_fincommitusd_loan.
      total_loan_euro  =  total_loan_euro  + ls_tran-forgn_fincommiteur_loan.
      total_loan_gbp  = total_loan_gbp  + ls_tran-forgn_fincommitgbp_loan.
      total_loan_eq_usd  = total_loan_eq_usd  + ls_tran-forgn_fincommitfcy_loan.
      total_loan_eq_inr  = total_loan_eq_inr  + ls_tran-forgn_fincommitinr_loan.

      total_pg_eq_usd = total_pg_eq_usd + ls_tran-forgn_fincommitfcy_pfgrnt.
      total_pg_eq_inr = total_pg_eq_inr + ls_tran-forgn_fincommitinr_pfgrnt.

      total_cg_eq_usd = total_cg_eq_usd + ls_tran-forgn_fincommitfcy_corgrnt.
      total_cg_eq_inr = total_cg_eq_inr + ls_tran-forgn_fincommitinr_corgrnt.
    ENDLOOP.
*      SELECT SINGLE * FROM zjvc_total INTO @DATA(total) WHERE doc_no EQ @zjvc_cc_fcforms-doc_no.
*      IF sy-subrc EQ 0.
*
*        total_equity_usd  = total-equity_usd.
*        total_equity_euro = total-equity_euro.
*        total_equity_gbp = total-equity_gbp.
*        total_equity_eq_usd = total-equity_equivalent_usd.
*        total_equity_eq_inr = zjvc_total-equity_equivalent_inr.
*
*        total_loan_usd = total-loan_usd.
*        total_loan_euro = total-equity_euro.
*        total_loan_gbp = total-loan_gbp.
*        total_loan_eq_usd = total-equity_equivalent_usd.
*        total_loan_eq_inr = total-equity_equivalent_inr.
*
*        total_pg_eq_usd  = total-pg_equivalent_usd.
*        total_pg_eq_inr = total-pg_equivalent_inr.
*        total_cg_eq_usd = total-cg_equivalent_usd.
*        total_cg_eq_inr = total-cg_equivalent_inr.

*    ENDIF.
  ENDIF.
*  ENDIF.


*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT SINGLE * FROM bseg INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr .  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  IF sy-subrc EQ 0 .




  ENDIF.

  IF  zjvc_cc_fcforms-forgn_fincommitusd_eqt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_eqt IS NOT INITIAL
    OR zjvc_cc_fcforms-forgn_fincommitgbp_eqt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitusd_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_loan  IS NOT INITIAL OR
    zjvc_cc_fcforms-forgn_fincommitgbp_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitfcy_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitinr_loan IS NOT INITIAL
    OR zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt IS NOT INITIAL
    OR zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitusd_corgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_corgrnt IS NOT INITIAL
    OR zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitinr_corgrnt IS NOT INITIAL .
    " for equity calculation .""""""""""""""
    zjvc_total-equity_usd = temp-equity_usd +  zjvc_cc_fcforms-forgn_fincommitusd_eqt + total_equity_usd .
    zjvc_total-equity_euro = temp-equity_euro + zjvc_cc_fcforms-forgn_fincommiteur_eqt + total_equity_euro.
    zjvc_total-equity_gbp = temp-equity_gbp +  zjvc_cc_fcforms-forgn_fincommitgbp_eqt + total_equity_gbp.
    zjvc_total-equity_equivalent_usd = temp-equity_equivalent_usd +  zjvc_cc_fcforms-forgn_fincommitfcy_eqt + total_equity_eq_usd ."equivalent_usd
    zjvc_total-equity_equivalent_inr = temp-equity_equivalent_inr +  zjvc_cc_fcforms-forgn_fincommitinr_eqt +  total_equity_eq_inr."equivalent_inr

    " for loan calculation """""""""""""

    zjvc_total-loan_usd = temp-loan_usd + zjvc_cc_fcforms-forgn_fincommitusd_loan + total_loan_usd.
    zjvc_total-loan_euro = temp-loan_euro + zjvc_cc_fcforms-forgn_fincommiteur_loan + total_loan_euro .
    zjvc_total-loan_gbp = temp-loan_gbp + zjvc_cc_fcforms-forgn_fincommitgbp_loan + total_loan_gbp.
    zjvc_total-loan_equivalent_usd = temp-loan_equivalent_usd + zjvc_cc_fcforms-forgn_fincommitfcy_loan  +  total_loan_eq_usd .
    zjvc_total-loan_equivalent_inr = temp-loan_equivalent_inr + zjvc_cc_fcforms-forgn_fincommitinr_loan + total_loan_eq_inr.

    " PG
    zjvc_total-pg_equivalent_usd = temp-pg_usd  + zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt / 2 + total_pg_eq_usd  .
    zjvc_total-pg_equivalent_inr = temp-pg_inr + zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt / 2 +  total_pg_eq_inr.
    zjvc_total-cg_equivalent_usd = temp-cg_usd + zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt + total_cg_eq_usd .
    zjvc_total-cg_equivalent_inr = temp-cg_inr + zjvc_cc_fcforms-forgn_fincommitinr_corgrnt +  total_cg_eq_inr.


    CLEAR : zjvc_cc_fcforms-forgn_fincommitusd_ovltot , zjvc_cc_fcforms-forgn_fincommitinr_ovltot.


    IF g_tcode NE 'ZJVCCFC2'  AND g_tcode NE 'ZJVCCFC3'AND g_tcode NE 'ZJVCCFC5'.
      SELECT * FROM zjvc_cc_fcforms INTO TABLE @DATA(lt_tran1) .

      LOOP AT lt_tran1 INTO DATA(ls_tran1).

        total_equity_eq_usd1 = total_equity_eq_usd1 + ls_tran1-forgn_fincommitfcy_eqt + ls_tran1-forgn_fincommitfcy_loan + ls_tran1-forgn_fincommitfcy_pfgrnt / 2 + ls_tran1-forgn_fincommitfcy_corgrnt..
        total_equity_eq_inr1 = total_equity_eq_inr1 + ls_tran1-forgn_fincommitinr_eqt + ls_tran1-forgn_fincommitinr_loan + ls_tran1-forgn_fincommitinr_pfgrnt / 2 + ls_tran1-forgn_fincommitinr_corgrnt..

      ENDLOOP.


    ELSE .
      CLEAR: lt_tran1 , ls_tran1.
      SELECT * FROM zjvc_cc_fcforms INTO TABLE @lt_tran1 WHERE doc_no LT  @zjvc_cc_fcforms-doc_no . .

      LOOP AT lt_tran1 INTO ls_tran1.

        total_equity_eq_usd1 = total_equity_eq_usd1 + ls_tran1-forgn_fincommitfcy_eqt + ls_tran1-forgn_fincommitfcy_loan + ls_tran1-forgn_fincommitfcy_pfgrnt / 2 + ls_tran1-forgn_fincommitfcy_corgrnt.
        total_equity_eq_inr1 = total_equity_eq_inr1 + ls_tran1-forgn_fincommitinr_eqt + ls_tran1-forgn_fincommitinr_loan + ls_tran1-forgn_fincommitinr_pfgrnt / 2 + ls_tran1-forgn_fincommitinr_corgrnt.

      ENDLOOP.

    ENDIF.
    zjvc_cc_fcforms-forgn_fincommitusd_ovltot = total_equity_eq_usd1 + ob_ovl-equivalent_usd + zjvc_cc_fcforms-forgn_fincommitfcy_eqt  + zjvc_cc_fcforms-forgn_fincommitfcy_loan + zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt / 2 +
zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt.
    zjvc_cc_fcforms-forgn_fincommitinr_ovltot = total_equity_eq_inr1 + ob_ovl-equivalent_inr + zjvc_cc_fcforms-forgn_fincommitinr_eqt + zjvc_cc_fcforms-forgn_fincommitinr_loan + zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt / 2 +
zjvc_cc_fcforms-forgn_fincommitinr_corgrnt.

    CLEAR :  total_equity_usd , total_equity_euro ,total_equity_gbp, total_equity_eq_usd , total_equity_eq_inr ,
    total_loan_usd,total_loan_euro , total_loan_gbp ,total_loan_eq_usd ,total_loan_eq_inr , total_pg_eq_usd,total_pg_eq_inr,
    total_cg_eq_usd ,total_cg_eq_inr,total_equity_eq_usd1 ,total_equity_eq_inr1 .

  ENDIF.



ENDMODULE.
