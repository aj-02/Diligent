***********************************************************************
* Program    : ZFI_VOUCHER_PRINT                                      *
*                                                                     *
*                                                                     *
* Title      : For VOUCHER PRINTING LAY OUT FOR the                   *
*              PAYMENTS/RECEIPTS/GENERAL DOCUMENT
* MIGRATED FROM UFSO. NO LOGIC CHANGE.                                *
*                                                                     *
* Functional Specification No. : FS-FI-PCS-016                        *
*                                                                     *
* Author     : MADHUKAR                     Date : 03-June-2003
*
*                                                                     *
* Login Id   : CAB_MADHUKAR
*
*                                                                     *
* Desciption : For VOUCHER PRINTING LAY OUT FOR the                   *
*              PAYMENTS/RECEIPTS/GENERAL DOCUMENT
* Tran.Code  : ZFIVCH                                                 *
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
* 8.04.2008   S.R.Sudha     For Payment method          +001          *
* 21.04.2008  S.R.Sudha     Paymethod from ven master   +002
*
***********************************************************************
**---------------------------------------------------------------------*
**                   Amendment History                                 *
**---------------------------------------------------------------------*
** Name   : MANESH                    *
** Date         : 21/05/09                                             *
** Change ID    : RD1K961183                                    *
** Reason       : ONGC Trust Migration to ECC 6.0                      *
**---------------------------------------------------------------------*


REPORT zfi_voucher_print NO STANDARD PAGE HEADING LINE-SIZE 170
                                           LINE-COUNT 58 MESSAGE-ID zfi.

* ---------- DATA DECLARATION SECTION --------------- *


TABLES:
  bseg,                          " Accounting document segment
  ska1,                   " G/L accounts master(chart of accounts)
  bkorm,                  " Accounting correspondence requests
  skat,                   " G/L A/C master record chart of account
  bkpf,                          " Accounting document header
  user_addr,
  lfa1,                          " Vendor master (general section)
  kna1,                          " General Data in Customer Master
  payr,                          " Payment transfer medium file
  rf05v,                         " Work fields for SAPLF040
  t001,                          " Company Codes
  anla,                          " Asset master record-segment
  vbsec,                  " Preliminary posting one-time data doc.
  usr03,                         " User address data
  bsec,                   " One-time account data document segment
  t074t,                         " Special G/L indicator names
  with_item,
  lfb1,
  lfbk,
  zfi_reconc,
  t042z.
"03.03.2003
DATA gv_wrbtr(20).
DATA gv_wrbtr_cr(20).
DATA : gv_name1 TYPE kna1-name1.
DATA : gv_name2 TYPE lfa1-name1.
DATA :v_amount_interval TYPE wmto_s-amount.
*-------- Selection Screen and Parameters------------------------------*
PARAMETERS : tbukrs LIKE bseg-bukrs OBLIGATORY,
             gjahr  LIKE bseg-gjahr  OBLIGATORY.
SELECT-OPTIONS: belnr FOR bkorm-belnr OBLIGATORY. " Doc.No.
SELECT-OPTIONS: cpudatum    FOR  bkpf-cpudt.     "  Document entry date
SELECT-OPTIONS: bu_datum    FOR  bkpf-budat.      "Document posting date


*---- Structure to Hold HEADER DATA -----------------------------------*
DATA : BEGIN OF header OCCURS 0,
         belnr  LIKE bkpf-belnr,         " Document Number
         bukrs  LIKE bkpf-bukrs,         " Company code
         gjahr  LIKE bkpf-gjahr,         " Fiscal Year
         usnam  LIKE bkpf-usnam,         " Entered by - header
         blart  LIKE bkpf-blart,         " Doc. type - header
         bldat  LIKE bkpf-bldat,         " Doc. Date - Header
         budat  LIKE bkpf-budat,         " Posting Date
         cpudt  LIKE bkpf-cpudt,         " CPU Date - Header
         name1  LIKE lfa1-name1,         " Vendor name
         name2  LIKE kna1-name1,         " Customer Name
         bktxt  LIKE bkpf-bktxt,         " Header Text
         xblnr  LIKE bkpf-xblnr,         " Ref. Doc No
         bvorg  LIKE bkpf-bvorg,
         txt20  LIKE skat-txt20,          " Account Desc - Detail
         waers  LIKE bkpf-waers,          "currency code
*       netamt LIKE bseg-wrbtr,
         netamt LIKE zfi_reconc-glamount,                     "03.03.2003
       END OF header.

*---- Structure to Hold ITEM DATA -------------------------------------*

DATA : BEGIN OF inrec OCCURS 0,
         belnr  LIKE bkpf-belnr,         " Document Number
         bukrs  LIKE bkpf-bukrs,         " Company code
         gjahr  LIKE bkpf-gjahr,         " Fiscal Year
         hkont  LIKE bseg-hkont,         " Account Code - Body(Acc.Ty S)
*        wrbtr LIKE bseg-wrbtr,         " Amount - Body "03.03.2003
*        dmbtr LIKE bseg-dmbtr,         " Local Curr    "03.03.2003
         wrbtr  LIKE zfi_reconc-glamount, " Amount - Body "03.03.2003
         dmbtr  LIKE zfi_reconc-glamount, " Local Curr    "03.03.2003
         pswsl  LIKE bseg-pswsl,         " Curr key
         kostl  LIKE bseg-kostl,         " Cost Centre - Body
         projk  LIKE bseg-projk,         " WBS Element  " Added by SB 8/12
*       projn like bseg-projn,         " WBS ELEMENT  " Comment by SB
         bldat  LIKE bkpf-bldat,         " Doc. Date - Header
         budat  LIKE bkpf-budat,         " Posting Date
         cpudt  LIKE bkpf-cpudt,         " CPU Date - Header
         txt20  LIKE skat-txt20,         " Account Desc - Detail
         shkzg  LIKE bseg-shkzg,         " Indicator
         gsber  LIKE bseg-gsber,
         chect  LIKE payr-chect,         " Check No
         laufd  LIKE payr-laufd,        " Check Date(Run date)
         sgtxt  LIKE bseg-sgtxt,         " Line Item Text
         saknr  LIKE bseg-saknr,         " Account Number
         buzei  LIKE bseg-buzei,         " Line Item No.
         bschl  LIKE bseg-bschl,         " posting Key
         aufnr  LIKE bseg-aufnr,         " Order No.
         zuonr  LIKE bseg-zuonr,         " Allocation Number
         kunnr  LIKE bseg-kunnr,         " Custmr.Account Number(Acc.Ty )
         lifnr  LIKE bseg-lifnr,         " Vendor Acct. Code(Acc.Ty. K)
         name1  LIKE lfa1-name1,         " Vendor name
         name2  LIKE kna1-name1,         " Customer Name
         qsskz  LIKE bseg-qsskz,         " Tax Type
         umskz  LIKE bseg-umskz,         " Sp. G/L indicator
         koart  LIKE bseg-koart,         " Account Type
         anln1  LIKE bseg-anln1,         " Asset No.
         matnr  LIKE bseg-matnr,         " Mat.No.
         posid  LIKE prps-posid,         " WBS Element
*-----+001
         zlsch  LIKE bseg-zlsch,         "payment method
*        netamt LIKE bseg-wrbtr,    " DOCUMENT NET BANK A/c AMOUNT 03.03
         netamt LIKE zfi_reconc-glamount,                    "03.03.2003
       END OF inrec.

*---- Internal Table to store Change document structure -----*
*---- Used in the function CALL 'PRELIMINARY_POSTING_DOC_READ' ---- *
DATA: BEGIN OF yvbkpf OCCURS 20.
        INCLUDE STRUCTURE fvbkpf.
DATA: END OF yvbkpf.

DATA: BEGIN OF yvbsec OCCURS 20.
        INCLUDE STRUCTURE fvbsec.
DATA: END OF yvbsec.

DATA: BEGIN OF yvbseg OCCURS 20.
        INCLUDE STRUCTURE fvbseg.
DATA: END OF yvbseg .

DATA: BEGIN OF yvbset OCCURS 20.
        INCLUDE STRUCTURE fvbset.
DATA: END OF yvbset.
*----------------------------------------------------------------------*
* Changed by Vinod on 18th March 2001
DATA: BEGIN OF it_bkpf OCCURS 0.
        INCLUDE STRUCTURE bkpf.
DATA: END OF it_bkpf.

DATA: BEGIN OF it_bseg OCCURS 0.
        INCLUDE STRUCTURE bseg.
DATA: END OF it_bseg .

DATA: BEGIN OF it_bset OCCURS 0.
        INCLUDE STRUCTURE bset.
DATA: END OF it_bset.

DATA  BEGIN OF it_with_item OCCURS 0.
        INCLUDE STRUCTURE  with_itemx.
DATA  END   OF it_with_item.
* End of changes
*----------------------------------------------------------------------*
* ---- Internal Table to Keep Line items with Sp. G/L Indicator ---*
DATA: BEGIN OF intspl OCCURS 10,
        umskz LIKE bseg-umskz,
        desc  LIKE t074t-ltext,
      END   OF intspl.

* ---- Working Variable Declaration ------ *
DATA : txblnr             LIKE bseg-belnr,
       tbktxt             LIKE bkpf-bktxt,
       fdate              LIKE bkpf-budat,
       tdate              LIKE bkpf-budat,
       tcdate             LIKE bkpf-cpudt,
       fcdate             LIKE bkpf-cpudt,
       acgrp              LIKE ska1-ktoks,
       cpudt(10),
       blart              LIKE bkpf-blart,
*       totamt LIKE bseg-wrbtr,   "03.03.2003
       totamt             LIKE zfi_reconc-glamount,                     "03.03.2003
       word               LIKE spell-word,
       name1(100) ,
       hkont              LIKE bseg-hkont,
       totalamt           LIKE totamt,
       flag(1),
       namex              LIKE bsec-name1,
       len(2)             TYPE n,
       alloc(10),
       totamtd            LIKE totamt,
       totamtc            LIKE totamt,
       payamt             LIKE totamt,
*       netamt LIKE bseg-wrbtr,  "03.03.2003
       netamt             LIKE zfi_reconc-glamount,                     "03.03.2203
       no_payee(3)        TYPE n,
       hdr_ln(3)          TYPE n,
       inrec_no           LIKE hdr_ln,
       old_name           LIKE name1,
       throw(1),
       banktxt(50),
       payee,
       sglno              TYPE n,
       tick,
*       net_cr LIKE bseg-wrbtr ,  "03.03.2203
*       net_cr_lc LIKE bseg-dmbtr, "03.03.2203
*       net_dr_lc LIKE bseg-dmbtr, "03.03.2203
*       net_dr LIKE bseg-wrbtr ,   "03.03.2203
       net_cr             LIKE zfi_reconc-glamount,                     "03.03.2203
       net_cr_lc          LIKE zfi_reconc-glamount,                  "03.03.2203
       net_dr_lc          LIKE zfi_reconc-glamount,                  "03.03.2203
       net_dr             LIKE zfi_reconc-glamount,                     "03.03.2203
       projk              LIKE bseg-kostl,
       temp_amount_lc(20) TYPE n,
       temp_amount_fc(20) TYPE n,
       l_aztxt            LIKE t042z-text1,                            " +001
       l_ktokk            LIKE lfa1-ktokk.


DATA : BEGIN OF it_bankkey OCCURS 0,
         lifnr   LIKE lfa1-lifnr,
         belnr   LIKE bseg-belnr,
         bankey  LIKE lfbk-bankl,
         bankacc LIKE lfbk-bankn,
       END   OF it_bankkey.
*-------------------------------------+001
DATA : BEGIN OF ist_zlsch  OCCURS 0,
         belnr LIKE bseg-belnr,
         bukrs LIKE bseg-bukrs,
         zlsch LIKE bseg-zlsch,
         text1 LIKE t042z-text1,
       END OF ist_zlsch .
DATA : l_zwels LIKE lfb1-zwels.
*-------------------------------------+001
* start of addition on 22102003 by sab_lax

RANGES : hkont_bank_range FOR bseg-hkont,
         hkont_cash_range FOR bseg-hkont.

DATA : valfrom LIKE setleaf-valfrom,
       valto   LIKE setleaf-valto.

* end of addition on 22102003 by sab_lax

DATA: wrbtr_input  TYPE wmto_s-amount,
      wrbtr_output TYPE wmto_s-amount,
      dmbtr_output TYPE wmto_s-amount,
      dmbtr_input  TYPE wmto_s-amount.  " ADD BY ROHIT ON 16.04.2026


*--- End of data selection --------------------------------------------*
*$*$-------------------------------------------------------------------*
*$*$ Code Inserted by Vinod on 5th April for changing Print Layout
*CALL FUNCTION 'SET_PRINT_PARAMETERS'
*     EXPORTING
*          layout     = 'X_65_255'
*          line_count = 255
*          line_size  = 65.
*$*$ End of Insertion -------------------------------------------------*
*---------------initialization-----------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD tbukrs.
  GET PARAMETER ID 'GJR' FIELD gjahr.

START-OF-SELECTION.

* start of addition on 22102003 by sab_lax required by  rohit

  REFRESH : hkont_bank_range,
            hkont_cash_range.

* append the BANK GL accounts

  SELECT  valfrom valto INTO  (valfrom, valto)
                        FROM  setleaf
                        WHERE setname  = 'BANK_CLG_ACCOUNTS'.

    hkont_bank_range-sign = 'I'.
    hkont_bank_range-option = 'BT'.
    hkont_bank_range-low = valfrom.
*    hkont_bank_range-high = valto.

    APPEND hkont_bank_range.
    CLEAR hkont_bank_range.

  ENDSELECT.

* append the BANK GL accounts

  SELECT  valfrom valto INTO  (valfrom, valto)
                        FROM  setleaf
                        WHERE setname  = 'BANK_MAIN_ACCOUNTS'.

    hkont_bank_range-sign = 'I'.
    hkont_bank_range-option = 'BT'.
    hkont_bank_range-low = valfrom.
    hkont_bank_range-high = valto.

    APPEND hkont_bank_range.
    CLEAR hkont_bank_range.

  ENDSELECT.

* append the CASH GL accounts

  SELECT  valfrom valto INTO  (valfrom, valto)
                        FROM  setleaf
                        WHERE setname  = 'CASH_ACCOUNTS'.

    hkont_cash_range-sign = 'I'.
    hkont_cash_range-option = 'BT'.
    hkont_cash_range-low = valfrom.
    hkont_cash_range-high = valto.

    APPEND hkont_cash_range.
    CLEAR hkont_cash_range.

  ENDSELECT.


* end of addition on 22102003

*-----Select from header data for the docs. ---------------------------*
  fcdate = cpudatum-low.
  tcdate = cpudatum-high.
  fdate =  bu_datum-low.
  tdate =  bu_datum-high.
*----Initialize internal tables  --------------------------------------*
  CLEAR : inrec, header.
  SELECT  * FROM bkpf WHERE gjahr = gjahr
                        AND belnr IN belnr
                        AND bukrs = tbukrs.
*--- Check for posting date and the cpu date of the document in the
*                                              --- selection field range
    PERFORM budat.
*------ store the header data in the internal table   -----------------*
    APPEND header.
  ENDSELECT.

*------ Invalid Document Number  --------------------------------------*
  DESCRIBE TABLE header LINES hdr_ln.
  IF hdr_ln < 1.
*  MESSAGE e162(yfi)  WITH belnr-low belnr-high. "210501
    MESSAGE i162(zfi)  WITH belnr-low belnr-high. "210501-yaseen

  ENDIF.
*------For Document line items  ---------------------------------------*

*--Select from vbsegs if document is a parked one ---------------------*
  LOOP AT header.
    rf05v-belnr = header-belnr.
    rf05v-bukrs = header-bukrs.
    rf05v-gjahr = header-gjahr.
*---Function for getting line item details of parked docs. ------------*
    CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
      EXPORTING
        belnr                   = rf05v-belnr
        bukrs                   = rf05v-bukrs
        gjahr                   = rf05v-gjahr
      TABLES
        t_vbkpf                 = yvbkpf
        t_vbsec                 = yvbsec
        t_vbseg                 = yvbseg
        t_vbset                 = yvbset
      EXCEPTIONS
        document_line_not_found = 1
        document_not_found      = 2
        OTHERS                  = 3.

    IF sy-subrc = 0.
*----------------------------------------------------------------------*
*   Changed by Vinod on 18th March 2001
*   To determine withholding tax amounts and line items for a parked
*   document
      REFRESH it_with_item.
      CLEAR   it_with_item.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE it_with_item
                                            FROM  with_item
                                           WHERE  bukrs  = header-bukrs
                                           AND    belnr  = header-belnr
                                           AND    gjahr  = header-gjahr.
      "  AND    wt_withcd <> space.
      IF sy-subrc = 0.
        REFRESH : it_bkpf,
                  it_bseg,
                  it_bset.
        CLEAR   : it_bkpf,
                  it_bseg,
                  it_bset.

        CALL FUNCTION 'FI_WT_PUT_X_WITH_ITEM'
          TABLES
            t_with_item = it_with_item.
*     Copying to internal table for passing to the function module
*     FI_WT_FB01_CALCULATE_WT
        LOOP AT yvbkpf.
          MOVE-CORRESPONDING yvbkpf TO it_bkpf.
          APPEND it_bkpf.
        ENDLOOP.
        DATA wa LIKE LINE OF yvbkpf.
        LOOP AT yvbseg.
          CLEAR wa.
          READ TABLE yvbkpf INTO wa
          WITH KEY ausbk = yvbseg-ausbk
          belnr = yvbseg-belnr
          bukrs = yvbseg-bukrs
          gjahr = yvbseg-gjahr.
          IF wa-waers = 'JPY'.
            v_amount_interval = yvbseg-wrbtr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'  "#EC CI_USAGE_OK[2340247]
              EXPORTING
                currency        = wa-waers
                amount_internal = v_amount_interval
              IMPORTING
                amount_display  = v_amount_interval
              EXCEPTIONS
                internal_error  = 1
                OTHERS          = 2.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            yvbseg-wrbtr = v_amount_interval.
          ENDIF.
          MOVE-CORRESPONDING yvbseg TO it_bseg.
          IF it_bseg-skfbt > 0.
            it_bseg-wrbtr = it_bseg-skfbt.
          ENDIF.
          APPEND it_bseg.
        ENDLOOP.
        LOOP AT yvbset.
          MOVE-CORRESPONDING yvbset TO it_bset.
          APPEND it_bset.
        ENDLOOP.

        CALL FUNCTION 'FI_WT_FB01_CALCULATE_WT'
          EXPORTING
            i_aktyp = 'H'
            i_dyncl = 'B'
          TABLES
            i_bkpf  = it_bkpf
            i_bseg  = it_bseg
            i_bset  = it_bset.

*   Get withitem data from memory .
        CALL FUNCTION 'FI_WT_GET_X_WITH_ITEM'
          TABLES
            t_with_item = it_with_item.

        DELETE it_with_item WHERE wt_qbshh = 0 OR wt_stat = 'X'.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        READ TABLE it_bkpf INDEX 1.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        PERFORM add_entries_bseg TABLES it_bseg it_with_item
                                 USING  it_bkpf.
*   Copying back to the internal table YVBSEG
        REFRESH yvbseg.
        CLEAR   yvbseg.

        LOOP AT it_bseg.
          MOVE-CORRESPONDING it_bseg TO yvbseg.
          APPEND yvbseg.
        ENDLOOP.
      ENDIF.
*   End of changes by Vinod
*----------------------------------------------------------------------*
*--validations for payment vouchers -----------------------------------*
      CLEAR: netamt , hkont.

      LOOP AT yvbseg WHERE
*                          bukrs = header-bukrs
                          belnr = header-belnr
                         AND gjahr = header-gjahr
                         AND wrbtr <> 0.
        IF yvbseg-hkont <> ' '.
          hkont = yvbseg-hkont.
        ELSE.
          hkont = yvbseg-saknr.
        ENDIF.
* commented by sab_lax on 22102003 required by rohit
*        IF ( hkont BETWEEN '0000091211' AND '0000091299'
* end of comment by sab_lax on 22102003 required by rohit

* added by sab_lax on 22102003 required by rohit
        IF ( hkont IN hkont_bank_range
* end of addtion by sab_lax on 22102003 required by rohit
           AND  hkont+9(1)  CA '02468' ) OR     " hkont = '0000091201'.
*Commented as request from Sanjay Bharti/Rajeev Kumar Dated 21.05.2002
*         ( hkont BETWEEN '0000091201' AND '0000091210' ).
* commented by sab_lax on 22102003 required by rohit
** Added Request from rajeev Kumar/Sanjay Bharti dated 21.05.2002
*            ( hkont BETWEEN '0000091201' AND '0000091205' ).
* end of comment by sab_lax on 22102003

* added by sab_lax on 22102003 required by rohit
           ( hkont IN hkont_cash_range ).
* end of addition by sab_lax on 22102003

*       above might change for Bombay implementation for > 1 cash accts
*------ Calculate net amount for bank clearing or cask accounts -------*
          IF yvbseg-shkzg = 'H'.
            netamt = netamt + yvbseg-wrbtr.
          ELSEIF yvbseg-shkzg = 'S'.
            netamt = netamt - yvbseg-wrbtr.
          ENDIF.
        ENDIF.

        MOVE-CORRESPONDING yvbseg TO inrec.
        PERFORM other_details1.
        APPEND inrec.
      ENDLOOP.
    ELSEIF sy-subrc <> 0.
*--- Validations  for receipt vouchers  -------------------------------*
      CLEAR: netamt,hkont, throw.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT  * FROM bseg WHERE bukrs = header-bukrs
                         AND belnr = header-belnr
                         AND gjahr = header-gjahr.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        IF bseg-hkont <> ' '.
          hkont = bseg-hkont.
        ELSE.
          hkont = bseg-saknr.
        ENDIF.
*----payment method   Sudha
*

* commented by sab_lax on 22102003 required by rohit
*        IF ( hkont BETWEEN '0000091211' AND '0000091299'
* end of comment by sab_lax on 22102003

* start of addition by sab_lax on 22102003 required by rohit
        IF ( hkont IN hkont_bank_range
* end of addition by sab_lax on 22102003
           AND  hkont+9(1)  CA '02468' )  OR   "  hkont = '0000091201'.
*         ( hkont BETWEEN '0000091201' AND '0000091210' ).
* commented by sab_lax on 22102003 required by rohit
*            ( hkont BETWEEN '0000091201' AND '0000091205' ).
* end of comment  by sab_lax on 22102003

* added by sab_lax on 22102003 required by rohit
           ( hkont IN hkont_cash_range ).
* end of addition by sab_lax 22102003

*        above might change for Bombay implementation for > 1 cash accts
          PERFORM calculate_net_amount.
*        elseif ( hkont between '0000091211' and '0000091299'
*         91299 is contra acct - cannot be included as actual bank acct

* start of comment on 22102003 by sab_lax required by rohit
*        ELSEIF ( hkont BETWEEN '0000091211' AND '0000091297'
* end of comment on 22102003 by sab_lax

* start of addition on 22102003 by sab_lax required by rohit
        ELSEIF ( hkont IN hkont_bank_range
* end of addition by sab_lax on 22102003
                 AND  hkont+9(1) CA '13579' ) .
*-------   General docs.  --------------------------------------------*
          throw = 'X'.
        ENDIF.
*{30007749
        DATA : l_curr TYPE bkpf-waers.
        CLEAR l_curr.
        SELECT SINGLE waers FROM bkpf
            INTO l_curr
          WHERE bukrs = bseg-bukrs
          AND belnr = bseg-belnr
          AND gjahr = bseg-gjahr  .

*        if BSEG-pswsl = 'JPY'.
        IF l_curr = 'JPY'.
*}30007749
          CLEAR v_amount_interval.
          v_amount_interval = bseg-wrbtr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'  "#EC CI_USAGE_OK[2340247]
            EXPORTING
              currency        = l_curr
              amount_internal = v_amount_interval
            IMPORTING
              amount_display  = v_amount_interval
            EXCEPTIONS
              internal_error  = 1
              OTHERS          = 2.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          bseg-wrbtr = v_amount_interval.
        ENDIF.

        MOVE-CORRESPONDING bseg TO inrec.
*{30007559
*1.BSEG-EMPFB <> '' print name1 from lfa1 for vendor BSEG-EMPFB
        DATA : l_name1 TYPE lfa1-name1,
               l_kunnr TYPE bseg-kunnr.
        CLEAR l_name1.

        IF bseg-empfb <> ''.
          SELECT SINGLE name1 FROM lfa1 INTO l_name1
            WHERE lifnr = bseg-empfb.
          IF sy-subrc = 0.
            inrec-name1 = l_name1.
          ENDIF.
        ENDIF.
        IF bseg-kunnr <> ''.
          DATA : l_ktokd TYPE kna1-ktokd,
                 l_ccnum TYPE vcnum-ccnum.
          CLEAR :l_ccnum,l_ktokd.
          SELECT SINGLE ktokd INTO l_ktokd
            FROM kna1
            WHERE kunnr = bseg-kunnr.
          IF l_ktokd = 'IMPR'.
            l_kunnr = bseg-kunnr.
            DATA :ln TYPE n.
            ln = strlen( bseg-kunnr ).
*            if l_kunnr+0(1) = '0'.
*              shift l_kunnr left deleting leading '0'.
*            endif.
            DATA : l_valfrom TYPE setleaf-valfrom.
            CLEAR l_valfrom.
            SELECT SINGLE valfrom
              INTO l_valfrom
              FROM setleaf
              WHERE setclass = '0000'
              AND setname = 'ZFIPREPAIDCARD'.

            IF NOT l_valfrom IS INITIAL.
              IF ln = '9'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                CONCATENATE l_valfrom '0' l_kunnr INTO l_ccnum.  "#EC CI_FLDEXT_OK[2215424]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              ELSE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                CONCATENATE l_valfrom l_kunnr INTO l_ccnum.  "#EC CI_FLDEXT_OK[2215424]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              ENDIF.
            ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            SELECT SINGLE ccname FROM vcnum
              INTO inrec-name1
              WHERE ccins = 'PPC'  "#EC CI_USAGE_OK[3224316]
              AND ccnum = l_ccnum.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          ENDIF.
        ENDIF.
*)30007559
        PERFORM other_details1.
        APPEND inrec.
        CLEAR inrec.
      ENDSELECT.
    ENDIF.
*------ Store net amount for Receipt/Payment Docs  --------------------*
    IF throw <> 'X'.
      header-netamt = netamt.
      MODIFY header.
      CLEAR netamt.
    ENDIF.
  ENDLOOP.
  CLEAR throw.
*$*$ Changed by Vinod on 12th April 2001 for Bank Key
  REFRESH it_bankkey.
  CLEAR   it_bankkey.

  LOOP AT inrec WHERE koart = 'K'.
    IF NOT inrec-lifnr IS INITIAL.
      SELECT SINGLE * FROM lfb1 WHERE lifnr = inrec-lifnr
                                AND   bukrs = inrec-bukrs.
      IF sy-subrc = 0.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*        SELECT SINGLE * FROM lfbk WHERE lifnr = lfb1-lifnr
*                                  AND   banks = 'IN'.
        SELECT * FROM lfbk UP TO 1 ROWS WHERE lifnr = lfb1-lifnr
                                  AND   banks = 'IN' ORDER BY PRIMARY KEY.
        ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        IF sy-subrc = 0.
          it_bankkey-belnr   = inrec-belnr.
          it_bankkey-lifnr   = lfb1-lifnr.
          it_bankkey-bankey  = lfbk-bankl.
          it_bankkey-bankacc = lfbk-bankn.
          APPEND it_bankkey.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


*--------------+001
  LOOP AT inrec WHERE koart = 'K'.
    IF NOT inrec-lifnr IS INITIAL.
      SELECT SINGLE ktokk INTO l_ktokk  FROM lfa1
                           WHERE lifnr = inrec-lifnr.
      IF sy-subrc = 0.
        IF l_ktokk = 'SVWI'  OR
        l_ktokk = 'SVWF'  OR
        l_ktokk = 'IMMI' OR
        l_ktokk = 'IMMF' OR
        l_ktokk = 'OTV ' OR
        l_ktokk = 'VEMP'.
*------------------------------------------+002
          CLEAR l_zwels.
          SELECT SINGLE zwels  INTO l_zwels  FROM  lfb1
               WHERE  lifnr = inrec-lifnr
                AND   bukrs = inrec-bukrs.
          IF sy-subrc = 0.
            IF NOT l_zwels IS  INITIAL.
              ist_zlsch-belnr = inrec-belnr .
              ist_zlsch-bukrs = inrec-bukrs.
              ist_zlsch-zlsch = l_zwels.
              APPEND ist_zlsch.
              CLEAR ist_zlsch.
            ENDIF.
          ENDIF.

*---------------------------------------------------+002
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM ist_zlsch.

  CLEAR l_aztxt.
  IF NOT ist_zlsch[] IS INITIAL.
    LOOP AT ist_zlsch.
      SELECT SINGLE text1 INTO  l_aztxt FROM t042z
                           WHERE land1 = 'IN' AND
                    zlsch = ist_zlsch-zlsch.
      ist_zlsch-text1 = l_aztxt.
      MODIFY ist_zlsch  TRANSPORTING text1.
      CLEAR ist_zlsch.
    ENDLOOP.
  ENDIF.
  SORT ist_zlsch .
  DELETE ADJACENT DUPLICATES FROM ist_zlsch.
*--------------End +001
*$*$ End of Changes by Vinod
*-----FOR WRITING OF VOUCHER IN DESIRED FORMAT ------------------------*
  PERFORM printcontrol.

*---------------------------------------------------------------------*
*       FORM OTHER_DETAILS                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM other_details.

  SELECT SINGLE * FROM lfa1 WHERE lifnr = inrec-lifnr.                 "" Added by Hrishi N on 01/07/2022

  IF  lfa1-ktokk = 'ZONT' .

*------- For Alternative payee for posted documents  ------------------*
*  SELECT SINGLE * FROM bsec WHERE bukrs = inrec-bukrs
*                          AND belnr = inrec-belnr
*                          AND gjahr = inrec-gjahr
*                          AND buzei = inrec-buzei.

*  IF sy-subrc = 0 .
*    CONCATENATE bsec-name1 bsec-name2
*                                     '( alternative party )' INTO name1.
*    WRITE: 33 '*' ,bsec-name1(28).     "sym_asterisk  as symbol.

    CONCATENATE lfa1-name1 '( alternative party )' INTO name1.
    WRITE: 33 '*' ,lfa1-name1.     "sym_asterisk  as symbol.

    tick = 'X'.
*  ENDIF.

  ELSE.

*------ For Alternative payee for parked documents  -------------------*
    SELECT SINGLE * FROM vbsec WHERE ausbk = inrec-bukrs
                            AND belnr = inrec-belnr
                            AND gjahr = inrec-gjahr
                            AND buzei = inrec-buzei.
    IF sy-subrc = 0 AND NOT vbsec-name1 IS INITIAL.
      CONCATENATE vbsec-name1 vbsec-name2
                                    ' ( Alternative Party )' INTO name1.
      WRITE: 33 '*' ,vbsec-name1(25).  "sym_asterisk  as symbol.
      tick = 'X'.
    ELSE.
*      SELECT SINGLE * FROM lfa1 WHERE lifnr = inrec-lifnr.   ""commented by Hrishi N on 01/07/2022

*      IF sy-subrc = 0 AND inrec-koart = 'K'. "Added by Madhukar 17/08/04  ""commented by Hrishi N on 05/07/2022
      IF inrec-koart = 'K'.                                                ""added by Hrishi N on 01/07/2022
*------ for employees  ------------------------------------------------*
        IF    lfa1-ktokk = 'VEMP'  OR lfa1-ktokk = 'RETD'.
*Modified as per sol mgr not No 3307 by madhukar

          MOVE lfa1-name1 TO name1.
        ELSE.
*----- For normal vendors  --------------------------------------------*
          CONCATENATE lfa1-name1 lfa1-name2 INTO name1 .
        ENDIF.
*(30007559
        CLEAR gv_name2.
        IF inrec-name1 <> ''.
          gv_name2 = inrec-name1.
          WRITE: 33 gv_name2(27) NO-GAP, '|' NO-GAP.
        ELSE.
*)30007559
          WRITE: 33 lfa1-name1(27) NO-GAP, '|' NO-GAP.
        ENDIF.                                              "*30007559
      ENDIF.
    ENDIF.
*----for  Customers  --------------------------------------------------*

    SELECT SINGLE * FROM kna1 WHERE kunnr = inrec-kunnr.
    IF sy-subrc = 0.
      CONCATENATE kna1-name1 '-' kna1-name2 INTO name1.
**(30007559
      CLEAR gv_name1.
      IF inrec-name1 <> ''.
        gv_name1 = inrec-name1.
        CONCATENATE kna1-name1 inrec-name1 INTO gv_name1 SEPARATED BY space.
        WRITE: 33  gv_name1(27) NO-GAP,'|' NO-GAP.
      ELSE.
**)30007559
        WRITE: 33  kna1-name1(27) NO-GAP,'|' NO-GAP.
      ENDIF.
    ELSE.
*---- For GL payments:from allocation field of line item --------------*
      IF inrec-hkont <> ' '.
        hkont = inrec-hkont.
      ELSE.
        hkont = inrec-saknr.
      ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT SINGLE * FROM ska1 WHERE saknr = hkont.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF sy-subrc = 0.
        acgrp = ska1-ktoks.
        IF ( acgrp = 'EMP2' OR acgrp = 'EMP4' OR acgrp = 'EMP6' ) AND
inrec-zuonr <> ' '.
          alloc = inrec-zuonr.
          len = 10 - strlen( alloc ).
          DO  len TIMES.
            CONCATENATE '0' alloc INTO alloc.
          ENDDO.

          SELECT SINGLE * FROM lfa1 WHERE lifnr =  alloc.
          IF sy-subrc = 0.
            CONCATENATE lfa1-name1 lfa1-name2 INTO name1 .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT name1 IS INITIAL.
    payee = 'X'.
    IF name1 <> old_name.
*----- Caluclate the number of payees derived from the above logic ----*
      no_payee =   no_payee + 1.
      old_name = name1.
    ENDIF.
  ENDIF.

ENDFORM.                    "other_details


************************************************************************
FORM other_details1.
* Deriving Other Details from Table Payr
************************************************************************
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*  SELECT SINGLE * FROM payr WHERE
*   vblnr = inrec-belnr AND
*   zbukr = inrec-bukrs AND
*   gjahr = inrec-gjahr.
  SELECT * FROM payr UP TO 1 ROWS WHERE
   vblnr = inrec-belnr AND
   zbukr = inrec-bukrs AND
   gjahr = inrec-gjahr ORDER BY PRIMARY KEY.
  ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  IF sy-subrc = 0.
    inrec-chect = payr-chect.          "Check No
    inrec-laufd = payr-laufd.          "Check Date
  ENDIF.
ENDFORM.                    "other_details1




************************************************************************
FORM budat.
************************************************************************
  IF fdate EQ '00000000' AND tdate EQ '00000000'. "Posting Date
    PERFORM cpudate.
  ELSEIF fdate NE '00000000' AND tdate NE '00000000'.
    IF bkpf-budat BETWEEN fdate AND tdate.
      PERFORM cpudate.
    ENDIF.
  ELSEIF fdate NE '00000000' AND tdate EQ '00000000'.
    tdate = sy-datum.
    IF bkpf-budat BETWEEN fdate AND tdate.
      PERFORM cpudate.
    ENDIF.
  ELSEIF fdate EQ '00000000' AND tdate NE '00000000'.
    IF bkpf-budat LE tdate.
      PERFORM cpudate.
    ENDIF.
  ENDIF.

ENDFORM.                    "budat
*---------------------------------------------------------------------*
*       FORM CPUDATE                                                  *
*---------------------------------------------------------------------*
FORM cpudate.
  IF fcdate EQ '00000000' AND tcdate EQ '00000000'. "CPUDate
    MOVE-CORRESPONDING bkpf TO header.
  ELSEIF fcdate NE '00000000' AND tcdate NE '00000000'.
    IF bkpf-budat BETWEEN fcdate AND tcdate.
      MOVE-CORRESPONDING bkpf TO header.
    ENDIF.
  ELSEIF fcdate NE '00000000' AND tcdate EQ '00000000'.
    tcdate = sy-datum.
    IF bkpf-budat BETWEEN fcdate AND tcdate.
      MOVE-CORRESPONDING bkpf TO header.
    ENDIF.
  ELSEIF fcdate EQ '00000000' AND tcdate NE '00000000'.
    IF bkpf-budat LE tcdate.
      MOVE-CORRESPONDING bkpf TO header.

    ENDIF.
  ENDIF.
ENDFORM.                    "cpudate

************************************************************************
FORM fm_cop. " add by rohit on 16.04.2026

  " SOC BY ROHIT ON 16.04.2026
  break abapuser02.

**  LOOP AT inrec INTO DATA(ls_rec).
**
**    IF ls_rec-pswsl = 'COP'.
**
**      wrbtr_input = ls_rec-wrbtr.
**      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
**        EXPORTING
**          currency        = 'COP'
**          amount_internal = wrbtr_input
**        IMPORTING
**          amount_display  = wrbtr_output
**        EXCEPTIONS
**          internal_error  = 1
**          OTHERS          = 2.
**      IF sy-subrc <> 0.
*** Implement suitable error handling here
**      ENDIF.
**      ls_rec-wrbtr = wrbtr_output.
**
**      dmbtr_input  = ls_rec-dmbtr.
**      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
**        EXPORTING
**          currency        = 'COP'
**          amount_internal = dmbtr_input
**        IMPORTING
**          amount_display  = dmbtr_output
**        EXCEPTIONS
**          internal_error  = 1
**          OTHERS          = 2.
**      IF sy-subrc <> 0.
*** Implement suitable error handling here
**      ENDIF.
**      ls_rec-dmbtr = dmbtr_output.
**      MODIFY : inrec FROM ls_rec.
**
**      CLEAR ls_rec.
**
**    ENDIF.
**
**  ENDLOOP.


*  IF ls_rec-pswsl = 'COP'.

*    wrbtr_input = ls_rec-wrbtr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'  "#EC CI_USAGE_OK[2340247]
    EXPORTING
      currency        = 'COP'
      amount_internal = wrbtr_input
    IMPORTING
      amount_display  = wrbtr_output
    EXCEPTIONS
      internal_error  = 1
      OTHERS          = 2.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*    ls_rec-wrbtr = wrbtr_output.


*  ENDIF.


  " EOC BY ROHIT ON 16.04.2026




ENDFORM.


FORM printcontrol.


*        Printing of the Vouchers
************************************************************************
  SELECT SINGLE * FROM t001 WHERE bukrs = bkpf-bukrs.

  SORT it_bankkey BY lifnr.
  DELETE ADJACENT DUPLICATES FROM it_bankkey
                             COMPARING lifnr belnr.

  LOOP AT header.
    REFRESH intspl.
*Added on 03/08/2001 by Madhukar
*    on change of header-belnr.
*    new-page.
*    endon.
*End of addition

    READ TABLE inrec WITH KEY bukrs = header-bukrs
                         belnr = header-belnr
                          gjahr = header-gjahr.
    IF sy-subrc = 0.
      SKIP 4.
      IF tbukrs = 'OVL' .
        WRITE: /80 'ONGC VIDESH LIMITED'.
      ELSEIF tbukrs = 'OBV'.
        WRITE: /80 'ONGC NILE GANGA B.V.'.
      ELSE .
        WRITE: /80 'OIL  &  NATURAL  GAS  CORPORATION '.
      ENDIF .
      WRITE:/80 'Project : ', t001-butxt.
      WRITE: /125 'Print Date   : ',sy-datum. "header-cpudt.
      WRITE sy-uline(190).
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE: / 'Doc.No.       : ', header-belnr.  "#EC CI_NOORDER
      WRITE: 40  'Proj.Code    : ', header-bukrs.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE: 100 'Voucher Type : '.
*------- Voucher Types  -----------------------------------------------*
      LOOP AT inrec WHERE  umskz NE space AND
                           bukrs = header-bukrs AND
                           belnr = header-belnr AND
                           gjahr = header-belnr.
        CASE inrec-umskz.
          WHEN 'F'.
            WRITE : 'Advance Payment Request'.
          WHEN 'P'.
            WRITE : 'Payment Request'.
          WHEN 'G'.
            WRITE : 'Bank Guarantee'.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
      IF sy-subrc NE 0 OR (  inrec-umskz NE 'F' AND inrec-umskz NE 'P'
                             AND  inrec-umskz NE 'G' ).
        PERFORM doctype.
      ENDIF.

*------ Print Header information  -------------------------------------*
      WRITE: / 'Doc.Pstg.Dt   : '.
      IF header-budat <> '00000000'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:  header-budat UNDER header-belnr.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      ELSE.
        WRITE: ' '.
      ENDIF.
      WRITE: 40 'Doc.Type     : '.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE: header-blart UNDER header-bukrs.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*Commented and code included to pick user name from User-ID.
*      SELECT SINGLE * FROM USR03 WHERE BNAME = HEADER-USNAM.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*      SELECT SINGLE * FROM user_addr WHERE bname = header-usnam.
      SELECT * FROM user_addr UP TO 1 ROWS WHERE bname = header-usnam ORDER BY PRIMARY KEY.
      ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      CONCATENATE user_addr-name_first user_addr-name_last INTO
                                          namex SEPARATED BY space.
*     CONCATENATE USR03-NAME1 USR03-NAME2 INTO NAMEX SEPARATED BY SPACE.
      WRITE: 100 'Entered By   : ', namex.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE:/ 'Ref.Doc.No.   : ', header-xblnr UNDER header-budat.  "#EC CI_NOORDER
      WRITE: 40 'Doc.Dt.  :', header-bldat UNDER header-blart.  "#EC CI_NOORDER
      WRITE: 100 'Header Text  : ', header-bktxt UNDER header-usnam.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF header-bvorg <> space.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:/ 'Cross Comp Doc:',header-bvorg UNDER header-xblnr.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      ENDIF.
      WRITE sy-uline(190).

*---------------------+001

      IF NOT ist_zlsch[] IS INITIAL.
        WRITE:/ 'Payment method :'.
        LOOP AT ist_zlsch WHERE belnr = header-belnr.
          IF sy-tabix = 1.
            WRITE : 17 ist_zlsch-text1 .
          ELSE.
            WRITE :/17 ist_zlsch-text1 .
          ENDIF.
        ENDLOOP.
      ENDIF.
*------------------------End-+001

*$*$ Changed by Vinod on 12th April 2001

*      LOOP AT it_bankkey.
*        READ TABLE inrec WITH KEY lifnr = it_bankkey-lifnr.
*        IF sy-subrc = 0.
*          NEW-LINE.
*          WRITE :    'Vendor : ',  it_bankkey-lifnr,
*                  30 'Bank Key:' , it_bankkey-bankey,
*                  65 'Bank Account:', it_bankkey-bankacc.
*        ENDIF.
*      ENDLOOP.

*$*$ End of changes by Vinod

*$ Changed by Madhukar on 24th May 2001
      LOOP AT it_bankkey WHERE  belnr = header-belnr.
        IF sy-subrc = 0.
          NEW-LINE.
          WRITE :    'Vendor : ',  it_bankkey-lifnr,
                  30 'Bank Key:' , it_bankkey-bankey,
                  65 'Bank Account:', it_bankkey-bankacc.
        ENDIF.
      ENDLOOP.

*$*$ End of Changes by Madhukar
      SKIP 2.
      WRITE sy-uline(190).
*---List Header for  LINE ITEMS  --------------------------------------*
      WRITE:/ '|' NO-GAP,  'Ln.' NO-GAP,  '|' NO-GAP,'Pt' NO-GAP,'|' NO-GAP,
                                                     'S' NO-GAP,  '|'NO-GAP,
                                         'Acct.          ' NO-GAP,'|'NO-GAP,
             ' BA  ' NO-GAP,'|' NO-GAP,'A/C Description            ' NO-GAP,
                                 '|'NO-GAP,'Amount                ' NO-GAP ,
                                                                  '|'NO-GAP,
                                        'Amount                ' NO-GAP,'|'
                                                                     NO-GAP,
                 'Tx' NO-GAP,  '|' NO-GAP, 'Cost       ' NO-GAP, '|' NO-GAP,
                           'Budget Item ' NO-GAP, '|' NO-GAP, 'Description'.

      WRITE:/ '|' NO-GAP, 'It.'NO-GAP, '|'NO-GAP, 'Ky' NO-GAP,'|' NO-GAP,

                          'G|' NO-GAP, 'Head           'NO-GAP,'|'NO-GAP,
                                               '    ' NO-GAP,' |' NO-GAP,
                          '                           ' NO-GAP,'|'NO-GAP,
                         'Debit                 'NO-GAP,      '|' NO-GAP,
              'Credit                'NO-GAP, '|'NO-GAP, 'Cd' NO-GAP,'|'
                                   NO-GAP,
                                               'Center/WBS '
       NO-GAP, '|' NO-GAP,'Order       'NO-GAP,'|' NO-GAP, '           '.

      WRITE sy-uline(190).
*-----Printing Line item data  ----------------------------------------*
      LOOP AT inrec WHERE belnr = header-belnr.
        CLEAR hkont.
        WRITE :/ '|' NO-GAP,inrec-buzei NO-GAP,'|'NO-GAP,inrec-bschl NO-GAP,
                                  '|' NO-GAP,inrec-umskz NO-GAP, '|' NO-GAP.
*---- Account group Logic  --------------------------------------------*
        CASE inrec-koart.
          WHEN 'D'.
*Business are included on 17-03-2001
            WRITE : inrec-kunnr NO-GAP,'     |' NO-GAP,
            inrec-gsber NO-GAP,' |' NO-GAP,
     '                          ','|' NO-GAP.
          WHEN 'K'.
*Business are included on 17-03-2001
            WRITE : inrec-lifnr NO-GAP,'     |' NO-GAP,
            inrec-gsber NO-GAP,' |' NO-GAP,
     '                          ','|' NO-GAP.
          WHEN 'S'.
            IF inrec-hkont <> ' '.
              hkont = inrec-hkont.
            ELSE.
              hkont = inrec-saknr.
            ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*            SELECT SINGLE * FROM skat WHERE saknr = hkont AND
*             ktopl = 'ONGC'.
            SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND
             ktopl = 'ONGC' ORDER BY PRIMARY KEY.
            ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
* changes made by  request to include IUT vch also
            IF inrec-bukrs <> header-bukrs.
              WRITE : hkont NO-GAP,'     |'NO-GAP,
*                  INREC-BUKRS NO-GAP,' | ' NO-GAP,
                         inrec-gsber NO-GAP,' |'
        NO-GAP,
           skat-txt20(20) NO-GAP,'         |' NO-GAP.
            ELSE.
              IF hkont = '0000120102' OR hkont = '0000120103'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs
                  AND gjahr = inrec-gjahr AND belnr = inrec-belnr
                  AND buzei = inrec-buzei AND hkont = hkont.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                IF bseg-zuonr+(4) <> inrec-bukrs.
                  WRITE : hkont NO-GAP,'     |' NO-GAP,
*                  BSEG-ZUONR+(4) NO-GAP,' |' NO-GAP,
                             inrec-gsber NO-GAP,
           ' |' NO-GAP,
               skat-txt20(20) NO-GAP,'       |' NO-GAP.
                ELSE.
                  WRITE : hkont NO-GAP,'     |'NO-GAP,
*                  '    ' NO-GAP,' |' NO-GAP,
              inrec-gsber NO-GAP,' |' NO-GAP,
               skat-txt20(20) NO-GAP,'    |' NO-GAP.
                ENDIF.
              ELSE.
                WRITE : hkont NO-GAP,'     |'NO-GAP,
*                  '    ' NO-GAP,' |' NO-GAP,
                              inrec-gsber NO-GAP,' |' NO-GAP,
             skat-txt20(20) NO-GAP,'       |' NO-GAP.
              ENDIF.
            ENDIF.
************
          WHEN 'A'.
            IF inrec-anln1 = '*'.
              IF inrec-hkont <> ' '.
                hkont = inrec-hkont.
              ELSE.
                hkont = inrec-saknr.
              ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*              SELECT SINGLE * FROM skat WHERE saknr = hkont AND
*               ktopl = 'ONGC'.
              SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND
               ktopl = 'ONGC' ORDER BY PRIMARY KEY.
              ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
* changes  for IUT voucher prn
              IF inrec-bukrs <> header-bukrs.
                WRITE : hkont NO-GAP, '  |' NO-GAP,
*INREC-BUKRS NO-GAP,'|' NO-GAP,
                   inrec-gsber NO-GAP,' |' NO-GAP,
                      skat-txt20(20) NO-GAP,'       |' NO-GAP.
                IF hkont = '0000120102' OR hkont = '0000120103'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                  SELECT SINGLE * FROM bseg WHERE bukrs = inrec-bukrs
                    AND gjahr = inrec-gjahr AND belnr = inrec-belnr
                    AND buzei = inrec-buzei AND hkont = hkont.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                  IF bseg-zuonr+(4) <> inrec-bukrs.
                    WRITE : hkont NO-GAP,'  |'NO-GAP,
*                  BSEG-ZUONR+(4) NO-GAP,' |' NO-GAP,
             inrec-gsber NO-GAP,' |' NO-GAP,
                 skat-txt20(20) NO-GAP,'       |' NO-GAP.
                  ELSE.
                    WRITE : hkont NO-GAP ,'     |'NO-GAP,
*                  '    ' NO-GAP,' |' NO-GAP,
                                  inrec-gsber NO-GAP,' |' NO-GAP,
                 skat-txt20(20) NO-GAP,'       |' NO-GAP.
                  ENDIF.
                ELSE.
                  WRITE : hkont NO-GAP, '  |' NO-GAP,
*      '    ' NO-GAP,'|' NO-GAP,
                     inrec-gsber NO-GAP,' |' NO-GAP,
                  skat-txt20(20) NO-GAP,'       |' NO-GAP.
                ENDIF.
              ENDIF.
*************************************
            ELSE.
              WRITE: inrec-anln1 NO-GAP,'   |' NO-GAP.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*              SELECT SINGLE * FROM anla WHERE anln1 = inrec-anln1 AND bukrs = tbukrs.
              SELECT * FROM anla UP TO 1 ROWS WHERE anln1 = inrec-anln1 AND bukrs = tbukrs ORDER BY PRIMARY KEY.
              ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              WRITE : anla-txt50(30) NO-GAP,'|' NO-GAP.
            ENDIF.
          WHEN 'M'.
            IF inrec-hkont <> ' '.
              hkont = inrec-hkont.
            ELSE.
              hkont = inrec-saknr.
            ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*            SELECT SINGLE * FROM skat WHERE saknr = hkont AND
*             ktopl = 'ONGC'.
            SELECT * FROM skat UP TO 1 ROWS WHERE saknr = hkont AND
             ktopl = 'ONGC' ORDER BY PRIMARY KEY.
            ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            WRITE: inrec-hkont NO-GAP,'     |' NO-GAP,inrec-gsber NO-GAP
                   , ' |' NO-GAP,
                             skat-txt20(20), '      |' NO-GAP.
*Modified as per sol mgr not No 3307 by madhukar
          WHEN OTHERS.
            REJECT.
        ENDCASE.
*----- Store the bank line item text in a variable --------------------*

* start of comment on 22102003 by sab_lax required by rohit
*        IF ( hkont BETWEEN '0000091211' AND '0000091299'
* end of comment on 22102003 by sab_lax

* start of addition on 22102003 by sab_lax required by rohit
        IF ( hkont IN hkont_bank_range
* end of addition on 22102003 by sab_lax
            AND  hkont+9(1)  CA '02468' )  OR  " hkont = '0000091201'.

* commented by sab_lax on 22102003 required by rohit
*           ( hkont BETWEEN '0000091201' AND '0000091210' ).
* end of comment by sab_lax on 22102003

* added by sab_lax on 22102003 required by rohit
          ( hkont IN hkont_cash_range ).
* end of addition by sab_lax on 22102003

* above might change for Bombay implementation for > 1 cash accts
          banktxt = inrec-sgtxt.
        ENDIF.
*--------------------For the Debit and Credit amounts------------------*
        IF inrec-shkzg = 'S'.          "debit
*   concatenate inrec-pswsl inrec-dmbtr into temp_amount_lc.
          IF header-waers = 'JPY'.
            CLEAR gv_wrbtr.
            PERFORM convert_to_nondecimal USING inrec-wrbtr CHANGING gv_wrbtr.

            IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
              wrbtr_input =  gv_wrbtr.
              PERFORM fm_cop.
              gv_wrbtr = wrbtr_output.
              CLEAR : wrbtr_input , wrbtr_output.
            ENDIF." EOC BY ROHIT ON 16.04.2026

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            WRITE : 61 header-waers NO-GAP,65 gv_wrbtr LEFT-JUSTIFIED  NO-GAP  "#EC CI_NOORDER
                                                                                ,
                                                                  83 '|' NO-GAP .
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*            WRITE : 61 header-waers NO-GAP,65 inrec-wrbtr LEFT-JUSTIFIED  NO-GAP
*                                                                                ,
*                                                                  83 '|' NO-GAP .
          ELSE.
            IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
              wrbtr_input =  inrec-wrbtr.
              PERFORM fm_cop.
              inrec-wrbtr = wrbtr_output.
              CLEAR : wrbtr_input , wrbtr_output.
            ENDIF." EOC BY ROHIT ON 16.04.2026

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            WRITE : 61 header-waers NO-GAP,65 inrec-wrbtr LEFT-JUSTIFIED  NO-GAP  "#EC CI_NOORDER
                                                                                ,
                                                                  83 '|' NO-GAP .
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          ENDIF.
**************************************************************
        ELSEIF inrec-shkzg = 'H'.      "credit
          IF header-waers = 'JPY'.
            CLEAR gv_wrbtr.
            PERFORM convert_to_nondecimal USING inrec-wrbtr CHANGING gv_wrbtr.

            IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
              wrbtr_input =  gv_wrbtr.
              PERFORM fm_cop.
              gv_wrbtr = wrbtr_output.
              CLEAR : wrbtr_input , wrbtr_output.
            ENDIF." EOC BY ROHIT ON 16.04.2026

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP  "#EC CI_NOORDER
                                                                           ,88
                                             gv_wrbtr LEFT-JUSTIFIED NO-GAP.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*            WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP
*                                                                           ,88
*                                             inrec-wrbtr LEFT-JUSTIFIED NO-GAP.
          ELSE.

            IF header-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
              wrbtr_input =   inrec-wrbtr.
              PERFORM fm_cop.
              inrec-wrbtr = wrbtr_output.
              CLEAR : wrbtr_input , wrbtr_output.
            ENDIF." EOC BY ROHIT ON 16.04.2026

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
            WRITE : '                     ','|' NO-GAP,84  header-waers NO-GAP  "#EC CI_NOORDER
                                                                           ,88
                                             inrec-wrbtr LEFT-JUSTIFIED NO-GAP.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          ENDIF.
        ENDIF.
*--------------------Tax Code------------------------------------------*
        WRITE :106 '|' NO-GAP, inrec-qsskz NO-GAP,109 '|'.
        "121 '|',134 '|'.
* --------------------Cost Center/WBS ELEMENT -------------------------*
* ---- Inrec-projn has been changed to inrec-projk by SB on 8/12-------*
        IF NOT ( inrec-projk IS INITIAL ).
          WRITE : 110 inrec-projk NO-GAP,121 '|' NO-GAP,134 '|' NO-GAP.
        ELSE.
          WRITE : 110 inrec-kostl NO-GAP, 121 '|' NO-GAP,134 '|' NO-GAP.
        ENDIF.
*--------------------Budget Item---------------------------------------*
        WRITE: 122 inrec-aufnr NO-GAP,'|' NO-GAP,134 '|' NO-GAP.
        WRITE:  inrec-sgtxt(35).
        totamt = header-netamt.
*-------------------- Net debit/credit amount -------------------------*
        PERFORM dr_cr_total.
        PERFORM  other_details.
        PERFORM spl_ind.
*donot print next line for same curr key from header
*      if header-waers <> 'INR'.
        SELECT SINGLE * FROM t001 WHERE bukrs = header-bukrs.
        IF header-waers <> t001-waers.
          IF inrec-shkzg = 'S'.        "debit
*   concatenate inrec-pswsl inrec-dmbtr into temp_amount_lc.

            IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
              wrbtr_input =   inrec-dmbtr.
              PERFORM fm_cop.
              inrec-dmbtr = wrbtr_output.
              CLEAR : wrbtr_input , wrbtr_output.
            ENDIF." EOC BY ROHIT ON 16.04.2026

            WRITE :/'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|',61
 t001-waers NO-GAP,65 inrec-dmbtr LEFT-JUSTIFIED ,83 '|' ,106 '|',109
'|'
, 121 '|',134 '|'.
          ELSEIF inrec-shkzg = 'H'.    "credit
*   concatenate inrec-pswsl inrec-dmbtr into temp_amount_fc.
            IF  t001-waers = 'JPY'.
              CLEAR gv_wrbtr.
              PERFORM convert_to_nondecimal USING inrec-dmbtr CHANGING gv_wrbtr.

              IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
                wrbtr_input =    gv_wrbtr.
                PERFORM fm_cop.
                gv_wrbtr = wrbtr_output.
                CLEAR : wrbtr_input , wrbtr_output.
              ENDIF." EOC BY ROHIT ON 16.04.2026

              WRITE : /'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|', 83 '|',
                                    84 t001-waers NO-GAP,88
           gv_wrbtr LEFT-JUSTIFIED NO-GAP ,106 '|',109 '|', 121 '|',134
           '|'.
            ELSE.

              IF  t001-waers = 'COP'. " SOC BY ROHIT ON 16.04.2026
                wrbtr_input =     inrec-dmbtr.
                PERFORM fm_cop.
                inrec-dmbtr = wrbtr_output.
                CLEAR : wrbtr_input , wrbtr_output.
              ENDIF." EOC BY ROHIT ON 16.04.2026

              WRITE : /'|',5 '|',8 '|',10 '|',26 '|',32 '|',60 '|', 83 '|',
                                    84 t001-waers NO-GAP,88
           inrec-dmbtr LEFT-JUSTIFIED NO-GAP ,106 '|',109 '|', 121 '|',134
           '|'.
            ENDIF.
          ENDIF.
        ENDIF.
*donot print next line for same curr key
      ENDLOOP.
*--------------------Total Amount in words ----------------------------*
      PERFORM convert USING totamt.

      WRITE sy-uline(190).
      net_dr = - net_dr .
      net_dr_lc = - net_dr_lc.

      IF header-waers = 'JPY'.
        CLEAR :gv_wrbtr,gv_wrbtr_cr.
        PERFORM convert_to_nondecimal USING net_dr CHANGING gv_wrbtr.
        PERFORM convert_to_nondecimal USING net_cr CHANGING gv_wrbtr_cr.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE: / 'Total' ,64 header-waers NO-GAP,68 gv_wrbtr LEFT-JUSTIFIED  "#EC CI_NOORDER
      NO-GAP,85 header-waers NO-GAP, 89  "#EC CI_NOORDER
      gv_wrbtr_cr LEFT-JUSTIFIED NO-GAP.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      ELSE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE: / 'Total' ,64 header-waers NO-GAP,68 net_dr LEFT-JUSTIFIED  "#EC CI_NOORDER
      NO-GAP,85 header-waers NO-GAP, 89  "#EC CI_NOORDER
      net_cr LEFT-JUSTIFIED NO-GAP.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      ENDIF.
*      if header-waers <> 'INR'.
      IF header-waers <> t001-waers.
        IF t001-waers = 'JPY'.
          CLEAR :gv_wrbtr,gv_wrbtr_cr.
          PERFORM convert_to_nondecimal USING net_dr_lc CHANGING gv_wrbtr.
          PERFORM convert_to_nondecimal USING net_cr_lc CHANGING gv_wrbtr_cr.
          WRITE: / 'Total' ,64 t001-waers,68 gv_wrbtr LEFT-JUSTIFIED
    NO-GAP,85 t001-waers, 89
    gv_wrbtr_cr LEFT-JUSTIFIED NO-GAP.
        ELSE.
          WRITE: / 'Total' ,64 t001-waers,68 net_dr_lc LEFT-JUSTIFIED
    NO-GAP,85 t001-waers, 89
    net_cr_lc LEFT-JUSTIFIED NO-GAP.
        ENDIF.
      ENDIF.
      WRITE sy-uline(190).
*--------------------Name of Receipient--------------------------------*
      IF totamt < 0.
*-------------------- FOR RECEIPT VOUCHERS ----------------------------*
        WRITE:/ 'Received from :: Ms./Mr./Mrs.:'.
        IF   no_payee = 1.
          WRITE : name1.
        ELSEIF no_payee > 1.
          WRITE: '   Please refer the description '.
        ELSEIF no_payee IS INITIAL.
          WRITE : banktxt.             " PRINT BANK ITEM TEXT
        ENDIF.

        WRITE sy-uline(190).
        totalamt = abs( totamt ).
        WRITE : / 'Total Amt. received : Rs.',totalamt.
        WRITE :/ 'Amount in words', word.
        SKIP 1.
      ELSEIF totamt > 0.
*--------------------FOR PAYMENT VOUCHERS -----------------------------*
        WRITE:/ 'Pay to:: Ms./Mr./Mrs.:'.
        IF   no_payee = 1.
**(30007559
          IF NOT gv_name1 IS INITIAL.
            WRITE : gv_name1.
          ELSE.
**}30007559
            WRITE : name1.
          ENDIF. "**(30007559 if part added
        ELSEIF no_payee > 1.
          WRITE: '   Please refer the description '.
        ELSEIF no_payee IS INITIAL.
          WRITE : banktxt.             " PRINT BANK ITEM TEXT
        ENDIF.
        WRITE sy-uline(190).
        totalamt = abs( totamt ).

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE : / 'Total Amt. to be Paid :', header-waers, totalamt.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*currency ' '.
        WRITE :/ 'Amount in words', word.
        SKIP 1.
      ENDIF.

      IF tick = 'X'.
        WRITE: / '*    Alternative Party '.
      ENDIF.
      SKIP 1.
      WRITE :/ 'Prepared By    : '.
*--------------------Memo No for receipts & payments only--------------*
      IF NOT totamt IS INITIAL.
        WRITE: 45 'Memorandum No.     : '.
      ENDIF.
      SKIP 1.
      WRITE :/ 'Checked By     : ' .
*--------------------Payment received----------------------------------*
      IF totamt > 0.
        WRITE : 45 'Payment Received.'.
      ENDIF.
*--------------------Cashier for receipts & payments only -------------*
      IF NOT totamt IS INITIAL.
        WRITE : 100 'Cashier  : '.
      ENDIF.
      SKIP 1.
      WRITE :/ 'Authorised By  : '.
*     payment received
      IF totamt > 0.
        WRITE : 45 'Signature of Payee : '.
      ENDIF.
*     Officer is for receipts & payments
      IF NOT totamt IS INITIAL.
        WRITE : 100 'Officer  : '.
      ENDIF.
      SKIP 1.
      DESCRIBE TABLE intspl LINES sglno.
      IF NOT sglno IS INITIAL.
        WRITE :/ 'Legend for Spl GL indicators:'.
        WRITE sy-uline(190).
        LOOP AT intspl.
          WRITE :/ intspl-umskz,':',20 intspl-desc.
        ENDLOOP.
      ENDIF.

      NEW-PAGE.
      CLEAR : totamt, word,inrec,hkont,no_payee,name1,old_name, tick,
              net_cr, net_dr,payee,banktxt,net_cr_lc,net_dr_lc.

    ENDIF.
  ENDLOOP.

ENDFORM.                    "printcontrol

************************************************************************
FORM doctype.
*    Function for checking Document Type
************************************************************************
  MOVE header-blart TO blart.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE blart TO UPPER CASE.
  CASE blart.
    WHEN 'BU' OR 'BP' OR 'EP' OR 'KZ' OR 'LB' OR 'ZP' OR 'KA'.
      WRITE: 'Bank Payment'.
    WHEN 'BR' OR 'DZ' OR 'KI' OR 'UB' .
      WRITE: 'Bank Receipt'.
    WHEN 'CP' OR 'CU' OR 'EC' OR 'LC' OR 'OC' .
      WRITE: 'Cash Payment'.
    WHEN 'CR' OR 'UC'.
      WRITE: 'Cash Receipt'.
    WHEN 'EB' OR 'OB' OR 'KC' OR 'KR' OR 'KS' OR 'RV'.
      WRITE : 'Invoice'.
    WHEN 'AB' OR 'DJ' OR 'IU' OR 'KJ' OR 'PJ' OR 'RG' OR 'SA'.
      WRITE : 'Journal Voucher'.
    WHEN 'AA' OR 'AF'.
      WRITE : 'Asset Voucher'.
    WHEN 'GR' OR 'GI' OR 'GX'.
      WRITE : 'Material Voucher'.
    WHEN 'RK' OR 'RD' OR 'RP' OR 'GL' OR 'RC' OR 'RR' OR 'ER'.
      WRITE : 'Reversal Voucher'.
    WHEN 'ES' .
      WRITE : 'Salary Voucher'.
    WHEN 'ZV' .
      WRITE : 'Clearing Document'.
    WHEN 'BG' .
      WRITE : 'Bank Guarantee'.
    WHEN 'DA'.
      WRITE : 'Customer Advance/Deposit'.
    WHEN 'TD'.
      WRITE : 'TDS Voucher'.
  ENDCASE.
ENDFORM.                    "doctype
*--------------------------------------------------------------------- *
*       FORM CONVERT                                                   *
*       Function to convert amount from figures to words               *
*--------------------------------------------------------------------- *
FORM convert USING totamt.
*FM Y_FI_CONVERT_AMOUNT was replaced by ZFI_AMOUNT_CONVERT for Currency
*for Sudan Company code as requested by Mr Rohit on 12/01/06-Madhukar
  CALL FUNCTION 'ZFI_AMT_WRDS_CONVERT'
    EXPORTING
      amt    = totamt
      curren = header-waers
    IMPORTING
      word   = word.
  CONDENSE word .
ENDFORM.                    "convert
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_NET_AMOUNT
*----------------------------------------------------------------------*
FORM calculate_net_amount.

  IF bseg-shkzg = 'H'.
*start of change 12/01/06 As requested by Rohit
*    netamt = netamt + bseg-dmbtr.      "bseg-wrbtr.
    netamt = netamt + bseg-wrbtr.      "bseg-wrbtr.
  ELSEIF bseg-shkzg = 'S'.
*    netamt = netamt - bseg-dmtr.      "bseg-wrbtr.
    netamt = netamt - bseg-wrbtr.      "bseg-wrbtr.
*end of change 12/01/06 As requested by Rohit

  ENDIF.

ENDFORM.                               " CALCULATE_NET_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  DR_CR_TOTAL
*&---------------------------------------------------------------------*
FORM dr_cr_total.
  IF inrec-shkzg = 'H'.
    net_cr_lc = net_cr_lc + inrec-dmbtr.
    net_cr = net_cr + inrec-wrbtr.
  ELSEIF inrec-shkzg = 'S'.
    net_dr_lc = net_dr_lc - inrec-dmbtr.
    net_dr = net_dr - inrec-wrbtr.
  ENDIF.

ENDFORM.                               " DR_CR_TOTAL
*&---------------------------------------------------------------------*
*&      Form  SPL_IND
*&---------------------------------------------------------------------*
FORM spl_ind.
  CHECK inrec-umskz NE space.
  READ TABLE intspl WITH KEY umskz = inrec-umskz.
  IF sy-subrc <> 0.
    intspl-umskz = inrec-umskz.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE * FROM t074t WHERE shbkz = inrec-umskz
*                              AND spras = 'E'.
    SELECT * FROM t074t UP TO 1 ROWS WHERE shbkz = inrec-umskz
                              AND spras = 'E' ORDER BY PRIMARY KEY.
    ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    intspl-desc = t074t-ltext.
    APPEND intspl.
  ENDIF.
ENDFORM.                               " SPL_IND

*&---------------------------------------------------------------------*
*&      Form  ADD_ENTRIES_BSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_entries_bseg TABLES p_it_bseg      STRUCTURE bseg
                             p_it_with_item STRUCTURE with_item
                      USING  p_it_bkpf      STRUCTURE bkpf.
*----------------------------------------------------------------------*
  DATA : wrk_lines TYPE i.

  DESCRIBE TABLE p_it_bseg LINES wrk_lines.

  LOOP AT p_it_with_item.
    CLEAR p_it_bseg.
    p_it_bseg-mandt = sy-mandt.
    p_it_bseg-bukrs = tbukrs.
*   p_it_bseg-belnr = belnr-low. "190501-yaseen - multiple doc pbm
    p_it_bseg-belnr = p_it_with_item-belnr. "190501-yaseen as above
    p_it_bseg-gjahr = gjahr.

    wrk_lines = wrk_lines + 1.
    p_it_bseg-buzei = wrk_lines.
    p_it_bseg-koart = 'S'.

    p_it_bseg-qsskz = p_it_with_item-wt_withcd.

    IF p_it_with_item-wt_qsshh < 0.
      p_it_bseg-bschl = '50'.
      p_it_bseg-shkzg = 'H'.
    ELSE.
      p_it_bseg-bschl = '40'.
      p_it_bseg-shkzg = 'S'.
    ENDIF.

    CLEAR p_it_bseg-gsber.
    READ TABLE p_it_bseg WITH KEY buzei = p_it_with_item-buzei
                              TRANSPORTING gsber.

    p_it_bseg-dmbtr = abs( p_it_with_item-wt_qbshh ).
    p_it_bseg-wrbtr = abs( p_it_with_item-wt_qbshb ).
    p_it_bseg-pswsl = p_it_bkpf-waers.

    p_it_bseg-saknr = p_it_with_item-hkont.
    p_it_bseg-hkont = p_it_with_item-hkont.

    APPEND p_it_bseg.

    IF NOT p_it_with_item-hkont_opp IS INITIAL.

      p_it_bseg-buzei = p_it_bseg-buzei + 1.

      IF p_it_bseg-bschl = '40'.
        p_it_bseg-bschl = '50'.
        p_it_bseg-shkzg = 'H'.
      ELSEIF p_it_bseg-bschl = '50'.
        p_it_bseg-bschl = '40'.
        p_it_bseg-shkzg = 'S'.
      ENDIF.

      p_it_bseg-saknr = p_it_with_item-hkont_opp.
      p_it_bseg-hkont = p_it_with_item-hkont_opp.

      APPEND p_it_bseg.
    ENDIF.
  ENDLOOP.
*----------------------------------------------------------------------*
ENDFORM.                               " ADD_ENTRIES_BSEG
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_NONDECIMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INREC_WRBTR  text
*      <--P_GV_WRBTR  text
*----------------------------------------------------------------------*
FORM convert_to_nondecimal  USING    p_inrec_wrbtr
                            CHANGING p_gv_wrbtr.
  WRITE p_inrec_wrbtr TO p_gv_wrbtr DECIMALS 0 LEFT-JUSTIFIED.
ENDFORM.                    " CONVERT_TO_NONDECIMAL
