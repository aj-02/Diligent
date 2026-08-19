*----------------------------------------------------------------------*
***INCLUDE MZPSJVCCFCFORMS_GET_TOTALS_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_TOTALS_FCFORMB_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_totals_fcformb_new .
  IF zjvc_cc_fcforms-ccprntreq = 'X'.
*  break abapuser02.
*    SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno.
    SELECT * FROM bkpf UP TO 1 ROWS INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno order by primary key. endselect.
    IF sy-subrc EQ 0.

      zjvc_cc_fcforms-curr_key = wa_bkpf-waers.


    ENDIF.



*    SELECT SINGLE * FROM zjvc_cc_astblk INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin.
    SELECT * FROM zjvc_cc_astblk UP TO 1 ROWS INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin ORDER BY PRIMARY KEY. ENDSELECT.
*  IF sy-subrc EQ 0.
*
*
*
*  ENDIF.
*
*
    IF zjvc_cc_fcforms-forgn_fincommitusd_eqt  IS INITIAL AND  zjvc_cc_fcforms-forgn_fincommiteur_eqt IS INITIAL
      AND zjvc_cc_fcforms-forgn_fincommitgbp_eqt IS INITIAL.
*      SELECT SINGLE * FROM bseg INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr .
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT * FROM bseg UP TO 1 ROWS INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr ORDER BY PRIMARY KEY. ENDSELECT.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF sy-subrc EQ 0.
        IF zjvc_cc_fcforms-curr_key = 'USD'.
          zjvc_cc_fcforms-forgn_fincommitusd_eqt = wa_bseg-wrbtr.
        ELSEIF zjvc_cc_fcforms-curr_key = 'EUR'.
          zjvc_cc_fcforms-forgn_fincommiteur_eqt = wa_bseg-wrbtr.
        ELSEIF zjvc_cc_fcforms-curr_key = 'GBP'.
          zjvc_cc_fcforms-forgn_fincommitgbp_eqt = wa_bseg-wrbtr.
        ENDIF.

        zjvc_cc_fcforms-forgn_fincommitfcy_eqt =  wa_bseg-dmbe2."equivalent_usd
        zjvc_cc_fcforms-forgn_fincommitinr_eqt =  wa_bseg-dmbtr."equivalent_inr

      ENDIF.

    ENDIF.
  ENDIF.

  IF zjvc_cc_fcforms-curr_key IS  INITIAL.
*    SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf1) WHERE bukrs =  'OVL' AND belnr  EQ @zjvc_cc_fcforms-belnr.
    SELECT * FROM bkpf UP TO 1 ROWS INTO @DATA(wa_bkpf1) WHERE bukrs =  'OVL' AND belnr  EQ @zjvc_cc_fcforms-belnr ORDER BY PRIMARY KEY. ENDSELECT.
    IF sy-subrc EQ 0.

      zjvc_cc_fcforms-curr_key = wa_bkpf1-waers.


    ENDIF.


  ENDIF.

*
*  ENDIF.
*  " for equity calculation .""""""""""""""
*  zjvc_cc_fcforms-forgn_fincommitusd_eqt = temp-equity_usd.
*  zjvc_cc_fcforms-forgn_fincommiteur_eqt = temp-equity_euro + wa_bseg-wrbtr.
*  zjvc_cc_fcforms-forgn_fincommitgbp_eqt = temp-equity_gbp.
*  zjvc_cc_fcforms-forgn_fincommitfcy_eqt = temp-equity_equivalent_usd + wa_bseg-dmbe2.
*  zjvc_cc_fcforms-forgn_fincommitinr_eqt = temp-equity_equivalent_inr + wa_bseg-dmbtr.
*
*  " for loan calculation """""""""""""
*
*  zjvc_cc_fcforms-forgn_fincommitusd_loan = temp-loan_usd.
*  zjvc_cc_fcforms-forgn_fincommiteur_loan = temp-loan_euro.
*  zjvc_cc_fcforms-forgn_fincommitgbp_loan = temp-loan_gbp.
*  zjvc_cc_fcforms-forgn_fincommitfcy_loan = temp-loan_equivalent_usd.
*  zjvc_cc_fcforms-forgn_fincommitinr_loan = temp-loan_equivalent_inr.






ENDFORM.
