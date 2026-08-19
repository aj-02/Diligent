REPORT zfi_update_kidno.
*-----  PROGRAM FOR Updating payemnt reference in  the old documents ***
***********************************************************************
* Program    :                                                        *
*                                                                     *
* Author     : S.R.Sudha                     Date : 8.11.2007
*
* Login Id   : CAB_SUDHA                                              *
*                                                                      *
* Description: ONE TIME EXERCISE FOR CHANGING PAYEMNT REFERAENCE
*             IN   All old  DOCUEMNTs
*
*Tcode       :ZFIUPDATEPAYREF
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                       *
*                                                                      *
* Date       TransportUSERID     Description
* 06.12.2010 RD1K974367 CAB_ALOK CR 30004997, 1.update the payment ref
*                                field in customer line item with Pay
*                                ref value in vendor line item.
*                                2. Erroneous blank line being appended to BSEG.
*                                3. Posting key logic applied for BSEG.
*                                4. Messages made more elaborate.
*16.05.2011 RD1K976379 CAB_ALOK CR 30005636- Update Pay ref in LIV Doc.
*17.10.2011 RD1K978209 CAB_ALOK CR 30006282- Change in Posting key logic
*07.05.2012 RD1K980333 CAB_ALOK CR 30007193- Program changes ZFI_UDATE_KIDNO

***********************************************************************
*                                                                     *
* Mod Date    Changed by    Description                     Chng ID   *
*                                                                     *
* 20/03/2014  CAB_SPYADAV   Changes as per CR No 30010505    005      *
*                           (Ref Cr No. 30010493)                     *
***********************************************************************
*16.07.2014 RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*5.08.2015  RD1K997925      CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30013088
*4.8.2021   OCDK905553      Shaifali     Change in ZFI_UDATE_KIDNO

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
TABLES : bsak ,bsik , bseg.

DATA : wa_bsik LIKE bsik.
DATA : wa_bseg LIKE bseg.
DATA : wa_bsak LIKE bsak.
*begin RD1K976379 CAB_ALOK CR 30005636
DATA: wa_bkpf LIKE bkpf,
      wa_rbkp LIKE rbkp.
*end RD1K976379 CAB_ALOK CR 30005636
DATA : wa_log      TYPE zfi_kidno_log,
       g_timestamp TYPE oifbbp1-ftmstm.
PARAMETERS:  p_belnr LIKE bsik-belnr
"""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 3.8.2015 RD1K997925
OBLIGATORY
             "end of addition by lipsy on 3.8.2015 RD1K997925
             """"""""""""""""""""""""""""""""""""""
             ,
             p_year  LIKE bsik-gjahr
 """""""""""""""""""""""""""""""""""""""""
"added by lipsy on 3.8.2015 RD1K997925
OBLIGATORY
             "end of addition by lipsy on 3.8.2015 RD1K997925
             """""""""""""""""""""""""""""""""""""
             ,
             p_bukrs LIKE bsik-bukrs
 "
 "added by lipsy on 3.8.2015 RD1K997925
OBLIGATORY
             "end of addition by lipsy on 3.8.2015 RD1K997925
             "

             ,
             p_buzei LIKE bsik-buzei OBLIGATORY,
             p_kidno LIKE bsik-kidno
 "
 "added by lipsy on 3.8.2015 RD1K997925
OBLIGATORY
             "end of addition by lipsy on 3.8.2015 RD1K997925
             "
             .
""""""""""""""""""""""""""""
"ADDED BY LIPSY  on 3.8.2015 RD1K997925

DATA: wa_zmm_ims_doc TYPE zmm_ims_status,
      p_cldocno      TYPE zmm_ims_status-mblnr_inv,
      p_cldocdt      TYPE zmm_ims_status-mblnr_invdt,
      t_lifnr        TYPE bseg-lifnr.

"end of addition by lipsy on 3.8.2015 RD1K997925
""""""""""""""""""""""""""""""


DATA  :g_ernam TYPE zfi_kidno_log-ernam,
       g_erdat TYPE zfi_kidno_log-erfdt.

*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
TYPES  : BEGIN OF ty_trackno,
           trackno TYPE zmm_ims_payref-trackno,
         END OF ty_trackno.
DATA: ist_trackno TYPE STANDARD TABLE OF ty_trackno.
DATA: ist_return_tab LIKE STANDARD TABLE OF ddshretval
                                        WITH  HEADER LINE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_kidno .
  PERFORM lov_kidno.

*End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*------------------------------------------------------*
START-OF-SELECTION.
*------------------------------------------------------*
*  PERFORM UPD_BSEG.
*
*    PERFORM UPD_BSIK.
*
*    PERFORM UPD_BSAK.
**begin RD1K976379 CAB_ALOK CR 30005636
*    PERFORM UPD_RBKP.
************************************************************************}CR
*  DATA : l_waers      TYPE zmm_ims-waers.
  DATA : l_date      TYPE sy-datum,
         l_waers_loc TYPE zmm_ims-waers VALUE 'INR'.
*      l_wrbtr TYPE bseg-wrbtr.
  DATA  : wa_exchange_rate TYPE bapi1093_0,
          wa_return        TYPE bapiret1.

  DATA : BEGIN OF wa_inv_dtl,
           trackno     TYPE zmm_ims-trackno,
           invoiceval  TYPE zmm_ims-invoiceval,
*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
           invoiceval1 TYPE zmm_ims-invoiceval,
           trackdt     TYPE zmm_ims_status-trackdt,
*End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
         END OF wa_inv_dtl.
  DATA :  g_invoiceval TYPE zmm_ims-invoiceval.
  DATA : ist_inv_dtl LIKE TABLE OF wa_inv_dtl.
  DATA : l_trackno TYPE zmm_ims_payref-trackno.




*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*  SELECT SINGLE trackno FROM zmm_ims_payref INTO l_trackno
*             WHERE  trackno = p_kidno AND
*                    liv_flg = 'X'.



  IF p_kidno IS NOT INITIAL.
    SELECT SINGLE * FROM bkpf INTO @DATA(w_bkpf)
      WHERE bukrs = @p_bukrs
      AND   belnr = @p_belnr
      AND   gjahr = @p_year.
    IF w_bkpf-stblg IS NOT INITIAL.
      MESSAGE 'You cannot update IMS no. in cancelled Invoices' TYPE 'E'.
      EXIT.
    ENDIF.

    SELECT SINGLE * FROM zmm_ims INTO @DATA(w_ims)
      WHERE trackno = @p_kidno.  "#EC CI_NOORDER
    IF sy-subrc = 0.
      IF w_ims-created_on GT '20191206' AND w_ims-status NE 'X' AND w_ims-tracktyp = 'F'.
        MESSAGE 'Please forward the invoice to finance department' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDIF.

    IF w_bkpf-blart EQ 'KS' AND ( w_ims-tracktyp  = 'F' OR w_ims-tracktyp  = 'M' ).
      MESSAGE 'Incorrect IMS No.' TYPE 'E'.
      EXIT.
    ENDIF.

    IF w_bkpf-blart EQ 'KR' AND ( w_ims-tracktyp  = 'F' OR w_ims-tracktyp  = 'S' ).
      MESSAGE 'Incorrect IMS No.' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ( w_bkpf-blart NE 'KS' AND w_bkpf-blart NE 'KR' AND w_bkpf-blart NE 'KC' ) AND ( w_ims-tracktyp  = 'M' OR w_ims-tracktyp  = 'S' ).
      MESSAGE 'Incorrect IMS No.' TYPE 'E'.
      EXIT.
    ENDIF.

    IF w_bkpf-blart EQ 'KS' or w_bkpf-blart EQ 'KR'.
*     SELECT SINGLE ebeln FROM bseg INTO @data(v_ebeln)
*       WHERE bukrs = @w_bkpf-bukrs
*       and   belnr = @w_bkpf-belnr
*       and   gjahr = @w_bkpf-gjahr
*       and   ebeln ne ' '.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*     SELECT ebeln FROM bseg UP TO 1 rows INTO @data(v_ebeln)
*       WHERE bukrs = @w_bkpf-bukrs
*       and   belnr = @w_bkpf-belnr
*       and   gjahr = @w_bkpf-gjahr
*       and   ebeln ne ' ' ORDER BY PRIMARY KEY. ENDSELECT.
     SELECT PurchasingDocument AS ebeln
       FROM i_operationalacctgdocitem
       WHERE CompanyCode         = @w_bkpf-bukrs
         AND AccountingDocument  = @w_bkpf-belnr
         AND FiscalYear          = @w_bkpf-gjahr
         AND PurchasingDocument <> ' '
       ORDER BY CompanyCode, AccountingDocument, FiscalYear, AccountingDocumentItem
       INTO @DATA(v_ebeln) UP TO 1 ROWS.
     ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
       IF v_ebeln ne w_ims-EBELN.
      MESSAGE 'Purchase order of IMS No. and accounting document should be matched' TYPE 'E'.
       ENDIF.
    ENDIF.



  ENDIF.





  SELECT SINGLE trackno FROM zmm_ims_payref INTO l_trackno   " LSC/LC etc
             WHERE  trackno = p_kidno AND
                    ( liv_flg = 'X' OR  pay_flg = 'X' ).
*End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371



  IF sy-subrc = 0.
*    PERFORM upd_bseg.
*
*    PERFORM upd_bsik.
*
*    PERFORM upd_bsak.
**begin RD1K976379 CAB_ALOK CR 30005636
*    PERFORM upd_rbkp.
    PERFORM update_tables.

  ELSE.
*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
    PERFORM validate_vendor.
*end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371

** IMS currency
    DATA : l_ims_waers      TYPE zmm_ims-waers.
    SELECT SINGLE waers FROM zmm_ims INTO l_ims_waers
                       WHERE trackno = p_kidno.  "#EC CI_NOORDER
*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371

** IMS Amt, Date
*    SELECT trackno invoiceval
    SELECT trackno invoiceval trackdt   "IMS date
*End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
      FROM zmm_ims_status
         INTO CORRESPONDING FIELDS OF TABLE ist_inv_dtl
           WHERE trackno = p_kidno.

    IF sy-subrc = 0.

      READ TABLE ist_inv_dtl INTO wa_inv_dtl INDEX 1.  "#EC CI_NOORDER
      IF sy-subrc = 0.
*        MOVE wa_inv_dtl-trackno    to g_kidno.
        MOVE wa_inv_dtl-invoiceval TO g_invoiceval.
      ENDIF.

    ENDIF.

*Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
*****    IF NOT l_waers IS INITIAL AND l_waers <> 'INR'.
*****
*****      CLEAR : wa_exchange_rate,
*****              wa_return.
*****
*****      l_date = sy-datum.
*****
*****      CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
*****        EXPORTING
*****          rate_type  = 'BCS'
*****          from_curr  = l_waers
*****          to_currncy = l_waers_loc
*****          date       = l_date
*****        IMPORTING
*****          exch_rate  = wa_exchange_rate
*****          return     = wa_return.
*****
******-005 : Start
******      g_invoiceval = ( g_invoiceval * wa_exchange_rate-exch_rate ) * 105
******                      / 10000000.
******-005 : End
*****
******+005 : Start
******Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
******      g_invoiceval = ( g_invoiceval * wa_exchange_rate-exch_rate ) * 105
******                      / 100.
******End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
******+005 : End
*****
******Start : CR No. 30005826 - 27.06.2011
****** To make tolerance level of 12% over the tracking number amount to cover the
****** service tax while making payment.
*****    ELSE.
******Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
******      g_invoiceval = g_invoiceval * 112 / 100.
******End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*****
******End : CR No. 30005826 - 27.06.2011
*****    ENDIF.
******End   : Added as per CR No. 30005327
*End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
*Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
*    CLEAR l_wrbtr.
*    SELECT SINGLE wrbtr FROM bseg
*      INTO l_wrbtr
*      WHERE belnr = p_belnr
*        AND gjahr = p_year
*        AND bukrs = p_bukrs
*        AND buzei = p_buzei.

* get LIV date, LIV Currency, DOC type
    DATA : l_budat TYPE bkpf-budat.
    DATA : l_bkpf_waers TYPE bkpf-waers.
    DATA : l_blart TYPE bkpf-blart.

    SELECT SINGLE blart budat waers
      FROM bkpf
        INTO (l_blart, l_budat , l_bkpf_waers )
          WHERE bukrs = p_bukrs
            AND belnr = p_belnr
            AND gjahr = p_year      .

* get Amt Doc curr, Amt Loc Curr, Ac type, Debit/Credit Indicator
    DATA : l_koart   TYPE bseg-koart,
           l_shkzg   TYPE bseg-shkzg,
           l_wrbtr   TYPE bseg-wrbtr,
           l_dmbtr   TYPE bseg-dmbtr,
           l_liv_amt TYPE bseg-dmbtr.

    CLEAR: l_koart,l_shkzg, l_dmbtr, l_wrbtr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE koart shkzg dmbtr wrbtr
*      FROM bseg
*        INTO (l_koart, l_shkzg, l_dmbtr, l_wrbtr )
*          WHERE bukrs = p_bukrs
*          AND belnr = p_belnr
*          AND gjahr = p_year
*          AND buzei = p_buzei.
    SELECT SINGLE FinancialAccountType        AS koart,
                  DebitCreditCode             AS shkzg,
                  AmountInCompanyCodeCurrency AS dmbtr,
                  AmountInTransactionCurrency AS wrbtr
      FROM i_operationalacctgdocitem
      WHERE CompanyCode            = @p_bukrs
        AND AccountingDocument     = @p_belnr
        AND FiscalYear             = @p_year
        AND AccountingDocumentItem = @p_buzei
      INTO ( @l_koart, @l_shkzg, @l_dmbtr, @l_wrbtr ).
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

    IF l_bkpf_waers =  l_ims_waers. "FI:INR = IMS:INR OR FI:JPY = IMS:JPY
      IF l_bkpf_waers = 'JPY'. "  JPY: WRBTR 4,740.00 / PSWBT  474,000 / PSWSL JPY
        l_liv_amt = l_wrbtr * 100.
      ELSE.
        l_liv_amt = l_wrbtr.
      ENDIF.
    ELSEIF ( l_bkpf_waers <>  l_ims_waers ) AND  l_ims_waers = 'INR' .   " FI:JPY <> IMS:INR
      l_liv_amt = l_dmbtr.  " DMBTR: loc curr (INR)

    ELSEIF ( l_bkpf_waers <>  l_ims_waers ) AND  l_bkpf_waers = 'INR' .  " FI: INR <> IMS: JPY
*      MESSAGE e544(zfi).
* get xchg rate using CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL' for IMS curr l_ims_waers on L_BUDAT date
* L_LIV_AMT = L_WRBTR. " FI
* g_invoiceval  =  g_invoiceval * xchg rate      " IMS value in INR

      CLEAR : wa_exchange_rate,
              wa_return.

      DATA: l_rate_type TYPE bapi1093_1-rate_type.

      SELECT SINGLE kurst FROM t003
        INTO l_rate_type
             WHERE blart = l_blart.

      IF l_rate_type IS INITIAL.
        l_rate_type = 'M'.
      ENDIF.

      CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
        EXPORTING
          rate_type  = l_rate_type
          from_curr  = l_ims_waers
          to_currncy = l_bkpf_waers
          date       = l_budat
        IMPORTING
          exch_rate  = wa_exchange_rate
          return     = wa_return.

      g_invoiceval  =  g_invoiceval * wa_exchange_rate-exch_rate * wa_exchange_rate-to_factor /  wa_exchange_rate-from_factor.
      l_liv_amt = l_wrbtr.

    ENDIF.

*End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687

** for Parked docs - BKPF and vbsegk
    IF l_wrbtr IS INITIAL.
      SELECT SINGLE wrbtr FROM vbsegk
        INTO l_wrbtr
          WHERE bukrs = p_bukrs
            AND belnr = p_belnr
            AND gjahr = p_year
            AND buzei = p_buzei.
    ENDIF.

**Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
** get LIV date
*    DATA : L_BUDAT TYPE BKPF-BUDAT.
*    select SINGLE BUDAT
*      from bkpf
*        into L_BUDAT
*          WHERE belnr = p_belnr
*            AND gjahr = p_year
*            AND bukrs = p_bukrs.
**End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371


* if line item  is related to vendor debit, don't check LIV-IMS condition.
    IF l_koart <> 'K' OR  l_shkzg <>  'S'.
*Case : IMS No 107291007649787  IMS for Less Amount
*       7114000024  2014   MUM  LIV for Graeter value
*system doesn't allow to update in this case .....
*now, Such case will be allowed when LIV is done Prior to IMS No : L_BUDAT  < wa_inv_dtl-TRACKDT
*wa_inv_dtl-TRACKDT : IMS date
*L_BUDAT  : LIV date
      g_invoiceval = g_invoiceval * 128 / 100.
*Begin RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
*    IF ( L_BUDAT =>  wa_inv_dtl-TRACKDT ) AND ( l_wrbtr > g_invoiceval ).
      IF ( l_budat =>  wa_inv_dtl-trackdt ) AND ( l_liv_amt > g_invoiceval ).
*End RD1K994519       CAB_ALOK  Change PAYREF Update Prog for Currency JPY - CR 30011687
        MESSAGE e372(zfi).
*    ELSEIF ( L_BUDAT < wa_inv_dtl-TRACKDT ) AND ( l_wrbtr < g_invoiceval ).
*      MESSAGE e527(zfi).
      ENDIF.
*End RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
    ENDIF.

* BEGIN CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
    PERFORM update_tables.
*      PERFORM upd_bseg.
*      PERFORM upd_bsik.
*      PERFORM upd_bsak.
**begin RD1K976379 CAB_ALOK CR 30005636
*      PERFORM upd_rbkp.
**end RD1K976379 CAB_ALOK CR 30005636
* END CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371


  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  UPD_BSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upd_bseg.
  CLEAR wa_log.
  IF g_ernam IS INITIAL.
    PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
  ENDIF.

  SELECT SINGLE *   FROM bseg INTO  wa_bseg WHERE
                 bukrs  =  p_bukrs
                 AND gjahr = p_year
                 AND belnr = p_belnr
*begin <RD1K974367> CAB_ALOK CR 30004997
*               AND buzei =  p_buzei.
* begin RD1K978209 CAB_ALOK CR 30006282
*               AND ( BSCHL = '21' or BSCHL = '31' ) .
                 AND buzei =  p_buzei
*begin RD1K980333 CAB_ALOK CR 30007193
*               AND ( BSCHL = '21' or BSCHL = '31' or BSCHL = '29' or BSCHL = '39') .
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                  AND ( bschl = '21' OR bschl = '31' OR bschl = '29' OR bschl = '39' OR bschl = '26' OR bschl = '36' ).  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*end RD1K980333 CAB_ALOK CR 30007193
* end RD1K978209 CAB_ALOK CR 30006282
  IF sy-subrc = 0.
*end <RD1K974367> CAB_ALOK CR 30004997
    wa_log-kidno_bseg = wa_bseg-kidno.
    wa_bseg-kidno = p_kidno.
    wa_log-kidno = wa_bseg-kidno.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG KIDNO via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
*    MODIFY  bseg FROM wa_bseg.
    DATA: lt_acg TYPE STANDARD TABLE OF accchg, ls_acg TYPE accchg.
    REFRESH lt_acg. CLEAR ls_acg.
    ls_acg-fdname = 'KIDNO'. ls_acg-newval = wa_bseg-kidno.
    APPEND ls_acg TO lt_acg.
    CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = wa_bseg-bukrs i_belnr = wa_bseg-belnr
         i_gjahr = wa_bseg-gjahr i_buzei = wa_bseg-buzei TABLES t_acchg = lt_acg EXCEPTIONS OTHERS = 0.
    COMMIT WORK.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
    IF sy-subrc = 0.
      MESSAGE  i303(zfi) WITH 'BSEG'.
*{"CR 30008286
      PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
      IF wa_log-kidno <> wa_log-kidno_bseg.
        wa_log-ernam = g_ernam.
        wa_log-erfdt = g_erdat.
        wa_log-timestamp = g_timestamp.
*}"CR 30008286
        MODIFY zfi_kidno_log FROM wa_log .                              "CR 30008286
      ENDIF.
    ENDIF.
*begin <RD1K974367> CAB_ALOK CR 30004997
  ENDIF.
*end <RD1K974367> CAB_ALOK CR 30004997
ENDFORM.                    " UPD_BSEG

*&---------------------------------------------------------------------*
*&      Form  UPD_BSIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upd_bsik.

  IF g_ernam IS INITIAL.
    PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
  ENDIF.

  SELECT SINGLE * FROM bsik INTO wa_bsik WHERE
               bukrs  =  p_bukrs
               AND gjahr = p_year
               AND belnr = p_belnr
               AND buzei =  p_buzei.  "#EC CI_NOORDER
  IF sy-subrc = 0.
    wa_log-kidno_bsik = wa_bsik-kidno.
    wa_bsik-kidno = p_kidno.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*    MODIFY  bsik FROM wa_bsik.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    IF sy-subrc = 0.
*begin <RD1K974367> CAB_ALOK CR 30004997
*      MESSAGE  i303(zfi)
*{"CR 30008286
      wa_log-kidno_bsik =  wa_bsik-kidno.
      wa_log-ernam = g_ernam.
      wa_log-erfdt = g_erdat.
      wa_log-timestamp = g_timestamp.
*}"CR 30008286
      MESSAGE  i303(zfi) WITH 'BSIK'.
      IF wa_log-kidno <> wa_log-kidno_bsik.
        MODIFY zfi_kidno_log FROM wa_log .                                  "CR 30008286
      ENDIF.
*End <RD1K974367> CAB_ALOK CR 30004997
    ENDIF.
  ENDIF.
ENDFORM.                    " UPD_BSIK
*&---------------------------------------------------------------------*
*&      Form  UPD_BSAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upd_bsak.

  IF g_ernam IS INITIAL.
    PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
  ENDIF.

  SELECT SINGLE *   FROM bsak INTO  wa_bsak WHERE
                bukrs  =  p_bukrs
                AND gjahr = p_year
                AND belnr = p_belnr
                AND buzei =  p_buzei.  "#EC CI_NOORDER
  IF sy-subrc = 0.
    wa_log-kidno_bsak = wa_bsak-kidno.
    wa_bsak-kidno = p_kidno.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*    MODIFY  bsak FROM wa_bsak.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
    IF sy-subrc = 0.
*{"CR 30008286
      PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
      wa_log-kidno =  wa_bsak-kidno.
      wa_log-ernam = g_ernam.
      wa_log-erfdt = g_erdat.
      wa_log-timestamp = g_timestamp.
*}"CR 30008286
*begin <RD1K974367> CAB_ALOK CR 30004997
*      MESSAGE  i303(zfi)
      MESSAGE  i303(zfi) WITH 'BSAK'.
      IF wa_log-kidno <> wa_log-kidno_bsak.
        MODIFY zfi_kidno_log FROM wa_log .                              "CR 30008286
      ENDIF.
*End <RD1K974367> CAB_ALOK CR 30004997
    ENDIF.
  ENDIF.
ENDFORM.                    " UPD_BSAK
*&---------------------------------------------------------------------*
*&      Form  UPD_RBKP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin RD1K976379 CAB_ALOK CR 30005636
FORM upd_rbkp .
  DATA: rbkp_belnr TYPE re_belnr,
        rbkp_year  TYPE gjahr.
  CLEAR:  rbkp_belnr, rbkp_year.
  IF g_ernam IS INITIAL.
    PERFORM log_update CHANGING g_ernam g_erdat g_timestamp.
  ENDIF.

*get LIV doc data corresponding to input screen data
  SELECT SINGLE * FROM bkpf INTO wa_bkpf
           WHERE bukrs  =  p_bukrs
             AND belnr = p_belnr
             AND gjahr = p_year.

  IF wa_bkpf-awkey IS NOT INITIAL.
    rbkp_belnr  =  wa_bkpf-awkey+0(10).
    rbkp_year   =  wa_bkpf-awkey+10(4).
*find LIV line in RBKP
    SELECT SINGLE * FROM rbkp INTO wa_rbkp
           WHERE belnr = rbkp_belnr
             AND gjahr = rbkp_year.
    IF sy-subrc = 0.
* update rbkp  with KIDNO
      PERFORM log_header CHANGING wa_log-belnr wa_log-gjahr wa_log-bukrs wa_log-buzei.
      wa_log-kidno_rbkp = wa_rbkp-kidno.
      wa_rbkp-kidno = p_kidno.
      MODIFY  rbkp FROM wa_rbkp.
      IF sy-subrc = 0.
*{"CR 30008286
        wa_log-kidno =  wa_rbkp-kidno.
        wa_log-ernam = g_ernam.
        wa_log-erfdt = g_erdat.
        wa_log-timestamp = g_timestamp.
*}"CR 30008286
        MESSAGE  i407(zfi) WITH wa_rbkp-belnr wa_rbkp-gjahr 'RBKP'. "Corresponding LIV doc &, & updated successfully in Table &.
        IF wa_log-kidno <> wa_log-kidno_rbkp.
          MODIFY zfi_kidno_log FROM wa_log .                   "CR 30008286
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF. " /WA_BKPF-AWKEY

ENDFORM.                    " UPD_RBKP
*end RD1K976379 CAB_ALOK CR 30005636
*&---------------------------------------------------------------------*
*&      Form  LOG_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_LOG_TIMESTAMP  text
*----------------------------------------------------------------------*
FORM log_update  CHANGING p_ernam TYPE zfi_kidno_log-ernam
                          p_erdat TYPE zfi_kidno_log-erfdt
                          p_timestamp TYPE oifbbp1-ftmstm.
  g_ernam = sy-uname.
  g_erdat = sy-datum.
  CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
    EXPORTING
      i_datum           = sy-datum
      i_time            = sy-uzeit
*     I_NO_DATE_OK      = ' '
    IMPORTING
      e_timestamp       = g_timestamp
    EXCEPTIONS
      date_not_received = 1
      time_not_received = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  p_timestamp = g_timestamp.
ENDFORM.                    " LOG_UPDATE
*&---------------------------------------------------------------------*
*&      Form  LOG_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_LOG_BELNR  text
*      <--P_WA_LOG_GJAHR  text
*      <--P_WA_LOG_BUKRS  text
*      <--P_WA_LOG_BUZEI  text
*----------------------------------------------------------------------*
FORM log_header  CHANGING p_wa_log_belnr
                          p_wa_log_gjahr
                          p_wa_log_bukrs
                          p_wa_log_buzei.

  p_wa_log_belnr = p_belnr.
  p_wa_log_gjahr = p_year.
  p_wa_log_bukrs = p_bukrs.
  p_wa_log_buzei = p_buzei.

ENDFORM.                    " LOG_HEADER

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_VENDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
FORM validate_vendor .
*  when we are updating the IMS no in KIDNO
*field  in the FI Doc, system should check the Vendor Code (LIFNR) of FI
*doc should match with the tracking No first Six Digit as (Vendor Code )
*Both the value should be same .
* BUKRS BELNR      GJAHR BUZEI LIFNR
  ""
  "commented by lipsy on 3.8.2015

*  data: t_lifnr TYPE bseg-lifnr.

  "end of comment by lipsy  on 3.8.2015


*  t_lifnr = p_kidno+0(6).   ""Commneted by ss on 4.8.2021

**BOC by ss on 4.8.2021
SELECT SINGLE lifnr from zmm_ims into  t_lifnr where trackno eq P_KIDNO.  "#EC CI_NOORDER
**EOC by ss on 4.8.2021

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = t_lifnr
    IMPORTING
      output = t_lifnr.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT SINGLE * FROM bseg
    WHERE bukrs = p_bukrs
    AND belnr  = p_belnr
    AND   gjahr = p_year
    AND buzei = p_buzei
    AND lifnr = t_lifnr.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

  IF  sy-subrc <> 0.
    MESSAGE e542(zfi).
  ENDIF.

ENDFORM.                    " VALIDATE_VENDOR
*end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*&---------------------------------------------------------------------*
*&      Form  LOV_KIDNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*begin RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
FORM lov_kidno .

  REFRESH: ist_trackno, ist_return_tab.
  CLEAR: ist_trackno, ist_return_tab.
  SELECT trackno
    FROM zmm_ims_payref
      INTO CORRESPONDING FIELDS OF TABLE ist_trackno
        WHERE ( liv_flg = 'X' OR pay_flg = 'X' ).  "#EC CI_NOORDER

  SORT ist_trackno BY trackno ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ist_trackno COMPARING trackno.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TRACKNO'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = ist_trackno
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  p_kidno =  ist_return_tab-fieldval.

ENDFORM.                    " LOV_KIDNO
*end RD1K993750       CAB_ALOK     Change in ZFIUPDATEPAYREF Prog - CR 30011371
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_tables .
  PERFORM upd_bseg.
  PERFORM upd_bsik.
  PERFORM upd_bsak.
  PERFORM upd_rbkp.
  """""""""""""""""""""""""
  "added by lipsy on 3.8.2015 RD1K997925
*  PERFORM upd_ims. " commented by hiren
  "end of addition by lipsy on 3.8.2015 RD1K997925
  """""""""""""""""""""""""""""""""
ENDFORM.                    " UPDATE_TABLES
*&---------------------------------------------------------------------*
*&      Form  UPD_IMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upd_ims .
  CLEAR:wa_zmm_ims_doc.
  SELECT SINGLE *
   FROM  zmm_ims_status
   INTO wa_zmm_ims_doc
  WHERE trackno  = p_kidno.  "#EC CI_NOORDER

  IF sy-subrc = 0.

    IF  wa_zmm_ims_doc-mblnr_liv IS INITIAL.

      UPDATE zmm_ims_status SET
      mblnr_liv = p_belnr
      mbll_stat = 'G'
      mblnr_livdt = wa_bkpf-budat
      WHERE
     trackno  = p_kidno.
      IF sy-subrc = 0.
        MESSAGE 'LIV Updated in IMS table ' TYPE 'I'.
      ENDIF.
    ENDIF.
    IF wa_zmm_ims_doc-mblnr_inv IS INITIAL.
      CLEAR:p_cldocno,p_cldocdt.
      SELECT SINGLE augbl augdt FROM bsak
                           INTO (p_cldocno,p_cldocdt)
                                   WHERE bukrs = p_bukrs AND
                                         lifnr = t_lifnr AND
                                         buzei = p_buzei AND
                                         kidno = p_kidno AND
                                         bschl = '31'.  "#EC CI_NOORDER

      IF sy-subrc = 0.
        IF  p_cldocno IS NOT INITIAL AND p_cldocdt IS NOT INITIAL.
          UPDATE zmm_ims_status SET
          mblnr_inv = p_cldocno
          mbli_stat = 'G'
          mblnr_invdt = p_cldocdt
          WHERE
         trackno  = p_kidno.
          IF sy-subrc = 0.
            MESSAGE 'Payment Document Updated in IMS table ' TYPE 'I'.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDIF.



ENDFORM.                    " UPD_IMS
