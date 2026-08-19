*&---------------------------------------------------------------------*
*& Report  ZF_CORR_PSWSL                                               *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zf_corr_pswsl line-size 150   .

************************************************************************
* This program is not intended to run DIRECTLY. This program is used
* to clear entries in FI related tables.
* DO NOT EXECUTE THIS PROGRAM.
************************************************************************
*Change History
***********************************************************************
*  Date        Transport    USERID       Description                  *
* 03/09/2008   RD1K960036   SAB_SRIDHAR  To resolved the Obsolete Stmt*
*                                        Error added SAPCE            *
***********************************************************************

TABLES: bkpf, bseg, bsis, bsas, t001, skb1.

TYPES: BEGIN OF header,
       bukrs TYPE bkpf-bukrs,
       belnr TYPE bkpf-belnr,
       gjahr TYPE bkpf-gjahr,
       monat TYPE bkpf-monat,
       END OF header.

TYPES: BEGIN OF accounts,
       bukrs TYPE skb1-bukrs,
       saknr TYPE skb1-saknr,
       xsalh TYPE skb1-xsalh,
       END OF accounts.

TYPES: BEGIN OF items,
       bukrs TYPE bseg-bukrs,
       belnr TYPE bseg-belnr,
       gjahr TYPE bseg-gjahr,
       buzei TYPE bseg-buzei,
       augdt TYPE bseg-augdt,
       augbl TYPE bseg-augbl,
       dmbtr TYPE bseg-dmbtr,
       wrbtr TYPE bseg-wrbtr,
       pswbt TYPE bseg-pswbt,
       pswsl TYPE bseg-pswsl,
       hkont TYPE bseg-hkont,
       new_pswbt TYPE bseg-pswbt,
       new_pswsl TYPE bseg-pswsl,
       END OF items.

DATA: wa_bkpf TYPE header,
      it_bkpf TYPE TABLE OF header,
      wa_skb1 TYPE accounts,
      it_skb1 TYPE TABLE OF accounts,
      wa_items TYPE items,
      it_items TYPE TABLE OF items.

DATA: cnt TYPE i,
      x_waers TYPE t001-waers.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
SELECT-OPTIONS: so_hkont FOR bseg-hkont OBLIGATORY.
PARAMETERS:     p_bukrs TYPE bkpf-bukrs OBLIGATORY.
SELECT-OPTIONS: so_belnr FOR bkpf-belnr,
                so_gjahr FOR bkpf-gjahr,
                so_monat FOR bkpf-monat.
SELECTION-SCREEN SKIP.
PARAMETERS: p_update AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK 001.

START-OF-SELECTION.

*** determine local currency of the company code
  SELECT SINGLE waers FROM t001 INTO x_waers
    WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    FORMAT COLOR 6.
    WRITE:/ 'Company code', p_bukrs, 'does not exist.'.
    FORMAT COLOR OFF.
    EXIT.
  ENDIF.

*** G/L account master data
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*  SELECT bukrs saknr xsalh FROM skb1 INTO wa_skb1
*    WHERE bukrs = p_bukrs
*      AND saknr IN so_hkont.
  SELECT CompanyCode             AS bukrs,
         GLAccount               AS saknr,
         BalanceHasLocalCurrency AS xsalh
    FROM i_glaccountincompanycode
    WHERE CompanyCode = @p_bukrs
      AND GLAccount  IN @so_hkont
    INTO CORRESPONDING FIELDS OF @wa_skb1.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    APPEND wa_skb1 TO it_skb1.
  ENDSELECT.

*** select affected line items
  SELECT
  bukrs belnr gjahr
  FROM bkpf INTO TABLE it_bkpf
    WHERE bukrs = p_bukrs
      AND belnr IN so_belnr
      AND gjahr IN so_gjahr
      AND monat IN so_monat.

  LOOP AT it_bkpf INTO wa_bkpf.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT
*    bukrs belnr gjahr buzei augdt augbl dmbtr wrbtr pswbt pswsl hkont
*    FROM bseg INTO wa_items
*      WHERE bukrs = wa_bkpf-bukrs
*        AND belnr = wa_bkpf-belnr
*        AND gjahr = wa_bkpf-gjahr
*        AND hkont IN so_hkont
*        AND pswsl NE x_waers ORDER BY PRIMARY KEY.
    SELECT CompanyCode                 AS bukrs,
           AccountingDocument          AS belnr,
           FiscalYear                  AS gjahr,
           AccountingDocumentItem      AS buzei,
           ClearingDate                AS augdt,
           ClearingJournalEntry        AS augbl,
           AmountInCompanyCodeCurrency AS dmbtr,
           AmountInTransactionCurrency AS wrbtr,
           AmountInBalanceTransacCrcy  AS pswbt,
           BalanceTransactionCurrency  AS pswsl,
           GLAccount                   AS hkont
      FROM i_operationalacctgdocitem
      WHERE CompanyCode                 = @wa_bkpf-bukrs
        AND AccountingDocument          = @wa_bkpf-belnr
        AND FiscalYear                  = @wa_bkpf-gjahr
        AND GLAccount                  IN @so_hkont
        AND BalanceTransactionCurrency <> @x_waers
      ORDER BY CompanyCode, AccountingDocument, FiscalYear, AccountingDocumentItem
      INTO CORRESPONDING FIELDS OF @wa_items.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF sy-subrc = 0.
        APPEND wa_items TO it_items.
        ADD 1 TO cnt.
      ENDIF.
    ENDSELECT.
  ENDLOOP.

*** output
  IF cnt > 0.

    FORMAT COLOR COL_TOTAL.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    ULINE AT /0(116).  "#EC CI_FLDEXT_OK[2610650]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    WRITE:/ sy-vline NO-GAP, 'Affected line items:'.
    WRITE: 116 sy-vline NO-GAP.
    FORMAT COLOR OFF.
    ULINE AT /0(116).
    FORMAT COLOR COL_HEADING.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    WRITE:/ sy-vline NO-GAP,
            (5) 'BUKRS', sy-vline NO-GAP,
           (10) 'BELNR', sy-vline NO-GAP,
            (5) 'GJAHR', sy-vline NO-GAP,
            (5) 'BUZEI', sy-vline NO-GAP,
           (15) 'PSWBT', sy-vline NO-GAP,
            (5) 'PSWSL', sy-vline NO-GAP,  "#EC CI_FLDEXT_OK[2610650]
           (10) 'HKONT', sy-vline NO-GAP,
           (15) 'new PSWBT', sy-vline NO-GAP,
            (5) 'new PSWSL', sy-vline NO-GAP,
*Begin of <RD1K960036>
*           (20)'Updated:', sy-vline NO-GAP.
           (20) 'Updated:', sy-vline NO-GAP.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*End of <RD1K960036>
    ULINE AT /0(116).
    FORMAT COLOR OFF.

    SORT it_items BY hkont belnr buzei.
    LOOP AT it_items INTO wa_items.
      WRITE:/ sy-vline NO-GAP,
              (5) wa_items-bukrs, sy-vline NO-GAP,
             (10) wa_items-belnr, sy-vline NO-GAP,
              (5) wa_items-gjahr, sy-vline NO-GAP,
              (5) wa_items-buzei, sy-vline NO-GAP,
             (15) wa_items-pswbt, sy-vline NO-GAP,  "#EC CI_FLDEXT_OK[2610650]
              (5) wa_items-pswsl, sy-vline NO-GAP,
             (10) wa_items-hkont, sy-vline NO-GAP.  "#EC CI_FLDEXT_OK[2610650]
*** PSWSL has to be eq T001-waers (XSALH = 'X')
      READ TABLE it_skb1 WITH KEY
      bukrs = wa_items-bukrs
      saknr = wa_items-hkont
      INTO wa_skb1.

      IF wa_skb1-xsalh = 'X'.
        wa_items-new_pswbt = wa_items-dmbtr.
        wa_items-new_pswsl = x_waers.
        WRITE: (15) wa_items-new_pswbt, sy-vline NO-GAP,   "#EC CI_FLDEXT_OK[2610650]
                (5) wa_items-new_pswsl, sy-vline NO-GAP.  "#EC CI_FLDEXT_OK[2610650]
        IF p_update = 'X'.
          PERFORM update_item.
        ENDIF.
      ELSE.
        WRITE: 'no XSALH' COLOR 3.
      ENDIF.
      WRITE: 116 sy-vline NO-GAP.
    ENDLOOP.
    ULINE AT /0(116).
  ELSE.
    FORMAT COLOR 3.
    WRITE:/ 'No affetced line item found in company code', p_bukrs.
    FORMAT COLOR OFF.
  ENDIF.



*&---------------------------------------------------------------------*
*&      Form  update_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_item.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: PSWSL/PSWBT (amount and update currency) cannot be changed on a posted document in S/4HANA (Note 3484729).
*  UPDATE bseg
*  SET pswsl   = wa_items-new_pswsl
*      pswbt   = wa_items-new_pswbt
*  WHERE bukrs = wa_items-bukrs
*    AND belnr = wa_items-belnr
*    AND gjahr = wa_items-gjahr
*    AND buzei = wa_items-buzei.
  MESSAGE 'Document not updated. Amount/currency (PSWSL/PSWBT) cannot be changed on posted document - reverse and repost. Refer SAP Note 3484729' TYPE 'E'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
  IF sy-subrc = 0.
    WRITE: 'BSEG' COLOR 5.
  ENDIF.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*  IF wa_items-augbl IS INITIAL.
*    UPDATE bsis
*    SET pswsl   = wa_items-new_pswsl
*        pswbt   = wa_items-new_pswbt
*    WHERE bukrs = wa_items-bukrs
*      AND hkont = wa_items-hkont
*      AND gjahr = wa_items-gjahr
*      AND belnr = wa_items-belnr
*      AND buzei = wa_items-buzei.
*    IF sy-subrc = 0.
*      WRITE: 'BSIS' COLOR 5.
*    ELSE.
*      WRITE: 'no BSIS found' COLOR 6.
*    ENDIF.
*  ELSE.
*    UPDATE bsas
*    SET pswsl   = wa_items-new_pswsl
*        pswbt   = wa_items-new_pswbt
*    WHERE bukrs = wa_items-bukrs
*      AND hkont = wa_items-hkont
*      AND augdt = wa_items-augdt
*      AND augbl = wa_items-augbl
*      AND gjahr = wa_items-gjahr
*      AND belnr = wa_items-belnr
*      AND buzei = wa_items-buzei.
*    IF sy-subrc = 0.
*      WRITE: 'BSAS' COLOR 5.
*    ELSE.
*      WRITE: 'no BSAS found' COLOR 6.
*    ENDIF.
*  ENDIF.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
ENDFORM.                    " update_item
