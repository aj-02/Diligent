REPORT zsd_invoice_vapexp_dp  LINE-COUNT 100 MESSAGE-ID vn.
*----------------------------------------------------------------------*
*              Print of an invoice by SAPscript                        *
*----------------------------------------------------------------------*


**************************************************************
*PROGRAM: ZSD_INVOICE_VAPEXP_DP
*
*TITLE:Value added products driver program( invoice for foreign
*customers )
*
*FS No: FS-SD-OUT-016
*
*Author: Madhukar   Date :21.12.2004
*
*Description:
*
*This Driver program ZSD_INVOICE_VAPEXP_DP is to print the Invoice for
*foriegn customers,for the given Billing Document no through
*Tcode VF03 using SAP script ZSD_INVC_VAP_EXP
*
*Tran Code :VF03
**************************************************************
*
*Change History
*
*Mod Date     Changed By     Description           Chng ID
*28.01.2005   Sudhir Sharma  Change for USD curr.  CAB_SUHDIR
*
**************************************************************
***********************************************************************
* Date        Transport     USERID          Description
* 24/11/2008  <RD1K960611>  SAB_SURJIT    1) Commented Break Statements
***********************************************************************
***********************************************************************
* Definition of tables                                                *
***********************************************************************

INCLUDE zsd_invoice_vapexp_dp_invdclr.
*INCLUDE zsd_invoice_vap_dp_invdclr.

***********************************************************************
* Definition of internal tables                                       *
***********************************************************************

DATA: BEGIN OF tvbdpr OCCURS 100.      "Internal table for items
        INCLUDE STRUCTURE vbdpr.
DATA: END OF tvbdpr.

DATA: BEGIN OF tkomv OCCURS 50.
        INCLUDE STRUCTURE komv.
DATA: END OF tkomv.

DATA: BEGIN OF tkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF tkomvd.

DATA: BEGIN OF hkomvd OCCURS 50.
        INCLUDE STRUCTURE komvd.
DATA: END OF hkomvd.

DATA: BEGIN OF tkomcon OCCURS 50.
        INCLUDE STRUCTURE conf_out.
DATA: END   OF tkomcon.

TYPES: BEGIN OF intab1 .
        INCLUDE STRUCTURE tline.
TYPES: END OF intab1.
DATA BEGIN OF it_name OCCURS 0 .
        INCLUDE STRUCTURE tline.
DATA END OF it_name.

DATA: intab      TYPE intab1 OCCURS 10  WITH HEADER LINE,
      it_supply  TYPE intab1 OCCURS 10  WITH HEADER LINE,
      it_sign    TYPE intab1 OCCURS 10  WITH HEADER LINE,
      it_vessel  TYPE intab1 OCCURS 10  WITH HEADER LINE,
      it_comment TYPE intab1 OCCURS 10  WITH HEADER LINE,
      textab     TYPE intab1 OCCURS 10  WITH HEADER LINE,
      ist_lipso2 LIKE lipso2 OCCURS 0 WITH HEADER LINE.

***********************************************************************
* Definition of internal variables                                    *
***********************************************************************

DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: repeat(1) TYPE c.
DATA: xscreen(1) TYPE c.               "Output on printer or screen
DATA: pr_kappl(01)   TYPE c VALUE 'V'. "Application for pricing
DATA: print_mwskz.                     "Mehrwertsteuer-Kz drucken

***********************************************************************
* Definition of variables for calling customer subroutines dynamically*
***********************************************************************

DATA : header_userexit       LIKE tnapr-ronam,
       item_userexit         LIKE tnapr-ronam,
       header_print_userexit LIKE tnapr-ronam,
       item_print_userexit   LIKE tnapr-ronam,
       get_data_userexit     LIKE tnapr-ronam.



**********************************************************************
*TYPES
**********************************************************************
DATA print_local_curr_ch.
DATA: komvdk_ch LIKE komvd OCCURS 10 WITH HEADER LINE.
DATA: komvdp_ch LIKE komvd OCCURS 10 WITH HEADER LINE.
counter1 = 0.
tabix = 0.
DATA:  total1        LIKE tkomvd-kwert,
       t_fkimg       LIKE vbdpr-fkimg,
       zocr(1),
       jmod(1),
       zin1(1),
       zin2(1),
       zin4(1),
       zin5(1),
       zin6(1),
       zscg(1),
       zfrt(1),
       zasv(1),
       zaed(1),
       zedc(1),
       jecx(1),
       jces(1),
       jmod_kbetr    LIKE komvd-kbetr , "(6) type p decimals 3,
       zocr_kbetr(6) TYPE p DECIMALS 2,
       g_cmpre(8)    TYPE p DECIMALS 3,
       g_cmpre1(8)   TYPE p DECIMALS 3,
       g_fk_mg       LIKE vbrp-fkimg,
       g_br_mg       LIKE vbrp-brgew,  "MGO Qty
       g_flg_mg,                   "MGO Flag
       zin1_kbetr    LIKE  jmod_kbetr,
       zin2_kbetr    LIKE  jmod_kbetr,
       zin4_kbetr    LIKE  jmod_kbetr,
       zin5_kbetr    LIKE  jmod_kbetr,
       zin6_kbetr    LIKE  jmod_kbetr,
       cess_kbetr    LIKE  jmod_kbetr,
       excise_kbetr  LIKE  jmod_kbetr,
       educess_kbetr LIKE  jmod_kbetr,
       zintotal      LIKE tkomv-kwert,
       zdif          LIKE tkomv-kwert,
       jmodtotal     LIKE tkomv-kwert,
       tot_zasv      LIKE tkomvd-kwert,
       tot_zfrt      LIKE tkomvd-kwert,
       tot_zscg      LIKE tkomvd-kwert,
       total2        LIKE tkomvd-kwert,
       tot_edr       LIKE tkomvd-kwert,
       tot_ocr       LIKE tkomvd-kwert,
       tot_zin       LIKE tkomvd-kwert,
       val_zin1      LIKE tkomvd-kwert,
       val_zin4      LIKE tkomvd-kwert,
       val_zin5      LIKE tkomvd-kwert,
       val_zin6      LIKE tkomvd-kwert,
       val_zin2      LIKE tkomvd-kwert,
       val_cess      LIKE tkomvd-kwert,
       val_excise    LIKE tkomvd-kwert,
       val_educess   LIKE tkomvd-kwert,
       poscnt1       TYPE i VALUE 0,
       wrk_tabix     LIKE sy-tabix,
       g_fkimg       LIKE tvbdpr-fkimg,
       g_kzwi1       LIKE tvbdpr-kzwi1,
       g_volum       LIKE tvbdpr-volum,
       g_pr01flag.


DATA:  period(38),
       count1(3),
       count2(3),
       count3(3),
       count4(3),
       count5(3),
       count6(3),
       sign(30),
       vessel(30),
       iecno(30),
       refno(30),
       count7(3),
       count8(3),
       count9(3),
       count10(3),
       count11(3),
       count12(3),
       count13(3),
       comments(30),
       text6(40),
       text7(40),
       text8(40),
       text9(40),
       text10(40),
       text11(35),
       countsko(3),
       roundoff     LIKE komv-kwert,
       tempdate     LIKE sy-datum,
       dtyp         LIKE vbdkr-vbtyp,
       kls          LIKE lipso2-adqntp,
       kln          LIKE lipso2-adqntp,
       lto          LIKE lipso2-adqntp,
       bb6          LIKE lipso2-adqntp,
       ug6          LIKE lipso2-adqntp,
       g_hzr_flg,
       region       LIKE t005u-bezei,
       street2,
       street3,
       street4,
       g_ocountry   LIKE t005t-landx,
       g_ocountry1  LIKE t005t-landx,
       dest(20),
       sorg(10),
       len(3),
       len1(3),
       word1(36),
       word2(36),
       wordcurr(12),
       l_kpein      LIKE komv-kpein.


***********************************************************************
*
*                                                                     *
* Standard Routine ENTRY                                              *
*                                                                     *
***********************************************************************
TABLES: t685t,
        t005u,
        lipso2,
        adrc,
        j_1imocomp,
        eikp,  "#EC CI_USAGE_OK[2223144]
        eipo,  "#EC CI_USAGE_OK[2223144]
        t005t,
        t615t.
*---------------------------------------------------------------------*
*       FORM entry                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RETURN_CODE                                                   *
*  -->  US_SCREEN                                                     *
*---------------------------------------------------------------------*
FORM entry USING return_code us_screen.
  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing USING us_screen.
  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_ESR                                          *
*                                                                     *
***********************************************************************

FORM entry_esr USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing_esr USING us_screen.
  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_ITALY                                        *
*                                                                     *
***********************************************************************

FORM entry_italy USING return_code us_screen.

  CLEAR retcode.
  xscreen = us_screen.
  PERFORM processing_italy USING us_screen.
  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.

ENDFORM.

***********************************************************************
*                                                                     *
* Standard Routine ENTRY_CH                                           *
*                                                                     *
***********************************************************************

FORM entry_ch USING return_code us_screen.
  CLEAR retcode.
  xscreen = us_screen.
  header_userexit = 'HEADER_CH'.
  item_userexit = 'ITEM_CH'.
  header_print_userexit = 'HEADER_PRINT_CH'.
  item_print_userexit = 'ITEM_PRINT_CH'.
  PERFORM processing USING us_screen.
  CASE retcode.
    WHEN 0.
      return_code = 0.
    WHEN 3.
      return_code = 3.
    WHEN OTHERS.
      return_code = 1.
  ENDCASE.
ENDFORM.

***********************************************************************
*                                                                     *
* Customer Entry-Routines                                             *
*                                                                     *
***********************************************************************



***********************************************************************
*                                                                     *
* Standard Routine PROCESSING                                         *
*                                                                     *
***********************************************************************

FORM processing USING proc_screen.
  PERFORM get_data.
  CHECK retcode = 0.
  SELECT * FROM lipso2 INTO TABLE ist_lipso2 WHERE vbeln =
vbdkr-vbeln_vl.
          DATA lv_exnum TYPE exnum.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

      SELECT SINGLE exnum
        FROM vbrk
        INTO @lv_exnum
        WHERE vbeln = @vbdkr-vbeln.

*  SELECT SINGLE * FROM eikp WHERE exnum = vbdkr-exnum.
  SELECT SINGLE * FROM eikp WHERE exnum = lv_exnum. "#EC CI_USAGE_OK[2223144]
  SELECT SINGLE * FROM t005t WHERE land1 = eikp-stgbe "#EC CI_USAGE_OK[2223144]
                               AND spras = 'EN'.
  CONCATENATE eikp-kzgbe ' ' t005t-landx INTO dest. "#EC CI_USAGE_OK[2223144]
  SELECT SINGLE * FROM t005t WHERE land1 = eikp-aland  "#EC CI_USAGE_OK[2223144]
                               AND spras = 'EN'.
  g_ocountry = t005t-landx.
*  SELECT SINGLE * FROM eipo WHERE exnum = vbdkr-exnum.
  SELECT SINGLE * FROM eipo WHERE exnum = lv_exnum. "#EC CI_USAGE_OK[2223144]
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
  SELECT SINGLE * FROM t005t WHERE land1 = eikp-lazl1 "#EC CI_USAGE_OK[2223144]
                               AND spras = 'EN'.
  g_ocountry1 = t005t-landx.
  SELECT SINGLE * FROM t615t WHERE spras = 'EN'
                               AND land1 = 'IN'
                               AND zolla = eikp-zolla. "#EC CI_USAGE_OK[2223144]

  LOOP AT ist_lipso2.
    CASE ist_lipso2-msehi.
      WHEN 'KLS'.
        kls = ist_lipso2-adqntp.
      WHEN 'KLN'.
        kln = ist_lipso2-adqntp.
      WHEN 'LTO'.
        lto = ist_lipso2-adqntp.
      WHEN 'BB6'.
        bb6 = ist_lipso2-adqntp.
      WHEN 'UG6'.
        ug6 = ist_lipso2-adqntp.
    ENDCASE.
  ENDLOOP.
  pname = vbdkr-vbeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ZSHP'
      language                = sy-langu
      name                    = pname
      object                  = 'VBBK'
    TABLES
      lines                   = it_vessel
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


  IF sy-subrc = 0.
    READ TABLE it_vessel INDEX 1.
    IF sy-subrc = 0.
      vessel = it_vessel-tdline.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'Z002'
      language                = sy-langu
      name                    = pname
      object                  = 'VBBK'
    TABLES
      lines                   = it_sign
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


  IF sy-subrc = 0.
    READ TABLE it_sign INDEX 1.
    IF sy-subrc = 0.
      iecno = it_sign-tdline.
    ENDIF.
  ENDIF.

  REFRESH it_sign.
  CLEAR pname.
  PERFORM form_open USING proc_screen vbdkr-land1.
  CHECK retcode = 0.
  PERFORM form_title_print.
  CHECK retcode = 0.
  PERFORM header_consgnee.
  CHECK retcode = 0.
  PERFORM reference_number.
  CHECK retcode = 0.
  PERFORM get_fkwrt.

  IF vbdkr-vkorg = 'URNS'.
    READ TABLE tkomv WITH KEY kschl = 'PR01'.
    IF sy-subrc = 0.
      g_pr01flag = 'X'.
      fkwrt = komk-fkwrt.
      WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
      CONDENSE fkwrt1.
    ELSE.
      IF vbdkr-vtweg = 'RD'.
        komk-fkwrt = komk-fkwrt - zintotal.
        fkwrt = komk-fkwrt.

        WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
        CONDENSE fkwrt1.
      ELSE.
        fkwrt = komk-fkwrt.
        WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
        CONDENSE fkwrt1.
      ENDIF.
    ENDIF.
  ELSE.
    fkwrt = komk-fkwrt.
    WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
    CONDENSE fkwrt1.
  ENDIF.

  CALL FUNCTION 'ZFI_AMT_WRDS_CONVERT'
    EXPORTING
      amt    = fkwrt1
      curren = komk-waerk
    IMPORTING
      word   = word
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CONDENSE word.
  TRANSLATE word TO LOWER CASE.


  len1 = strlen( word ).
  IF komk-waerk = 'INR'.
    wordcurr = word+0(7).
    len1 = len1 - 7.
    word = word+7(len1).
    TRANSLATE word+6(1) TO UPPER CASE.
  ELSEIF komk-waerk = 'USD'.
    TRANSLATE word+10(1) TO UPPER CASE.
    wordcurr = word+0(10).
    len1 = len1 - 10.
    word = word+10(len1).
  ENDIF.

  TRANSLATE wordcurr TO UPPER CASE.
  CONCATENATE wordcurr ':' word INTO word.
*  len = strlen( word ).
*  if len > 35.
*    word1 = word+37(36).
*    endif.
*  if len > 74.
*    word2 = word+73(len).
*  endif.


  CONDENSE word.
  SELECT SINGLE * FROM stxh WHERE tdobject = 'VBBK'
         AND tdid = '0002' AND
         tdspras = 'E' AND
         tdname = vbdkr-vbeln.
  GET PARAMETER ID 'VF' FIELD vbeln.
  SELECT SINGLE * FROM vbrk WHERE vbeln = vbeln.
  pname = vbrk-vbeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = '0001'
      language                = stxh-tdspras
      name                    = pname
      object                  = 'VBBK'
    IMPORTING
      header                  = phead
    TABLES
      lines                   = intab
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CLEAR pname.
  CONCATENATE vbdkr-vbeln tvbdpr-posnr INTO pname.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = '0001'
      language                = sy-langu
      name                    = pname
      object                  = 'VBBP'
    TABLES
      lines                   = it_supply
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


  IF sy-subrc = 0.
    READ TABLE it_supply INDEX 1.
    IF sy-subrc = 0.
      period = it_supply-tdline.
    ENDIF.
  ENDIF.
  pname = vbdkr-vbeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ZPTT'
      language                = sy-langu
      name                    = pname
      object                  = 'VBBK'
    IMPORTING
      header                  = phead
    TABLES
      lines                   = textab
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  IF sy-subrc = 0.
    READ TABLE textab INDEX 1.
    IF sy-subrc = 0.
      text6 = textab-tdline.
    ENDIF.
    READ TABLE textab INDEX 2.
    IF sy-subrc = 0.
      text7 = textab-tdline.
    ENDIF.
    READ TABLE textab INDEX 3.
    IF sy-subrc = 0.
      text8 = textab-tdline.
    ENDIF.
    READ TABLE textab INDEX 4.
    IF sy-subrc = 0.
      text9 = textab-tdline.
    ENDIF.
    READ TABLE textab INDEX 5.
    IF sy-subrc = 0.
      text10 = textab-tdline.
    ENDIF.

    READ TABLE textab INDEX 6.
    IF sy-subrc = 0.
      text11 = textab-tdline.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ZREF'
      language                = sy-langu
      name                    = pname
      object                  = 'VBBK'
    TABLES
      lines                   = it_sign
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


  IF sy-subrc = 0.
    READ TABLE it_sign INDEX 1.
    IF sy-subrc = 0.
      refno = it_sign-tdline.
    ENDIF.
  ENDIF.
  dtyp = vbdkr-vbtyp.
  TRANSLATE dtyp TO UPPER CASE.
  IF dtyp = 'O'.
    text_element = 'CREDIT_MEMO'.
  ELSEIF dtyp = 'P'.
    text_element = 'DEBIT_MEMO'.
  ELSEIF dtyp = 'M'.
    text_element = 'INVOICE'.
  ENDIF.
  SELECT SINGLE * FROM vbrp WHERE vbeln = vbeln
                              AND posnr = tvbdpr-posnr.
  augru = vbrp-augru_auft.
  mdesc = vbrp-arktx.
  SELECT SINGLE * FROM t001w WHERE werks = vbrp-werks.   "plants
  SELECT SINGLE * FROM vbak WHERE vbeln = vbrp-vbeln.
  SELECT SINGLE * FROM tvtwt WHERE vtweg = vbdkr-vtweg AND spras = 'EN'.
  " ditribution channel
  SELECT SINGLE * FROM t005u WHERE spras = 'EN' AND land1 = 'IN' AND
  bland = vbdkr-regio_we.
  region = t005u-bezei.
  SELECT SINGLE * FROM t005u WHERE spras = 'EN' AND land1 = 'IN' AND
  bland = vbdkr-regio.
  SELECT SINGLE * FROM tvaut WHERE augru = augru
  AND spras = 'EN'.                     "order reason
  PERFORM tax_text_print USING text_element.
  CHECK retcode = 0.
  PERFORM header_data_print.
  CHECK retcode = 0.
  SELECT SINGLE * FROM vbrk WHERE vbeln = vbeln.
  zterm = vbrk-zterm.
  SELECT SINGLE * FROM t052 WHERE zterm = zterm.  " payment terms
  SELECT SINGLE * FROM j_1imocomp WHERE bukrs = vbdkr-bukrs
                                    AND werks = vbrp-werks.

  PERFORM header_text_print.
  CHECK retcode = 0.
  tempdate = vbdkr-fkdat.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.

***********************************************************************
*                                                                     *
* Standard Routine PROCESSING_ESR                                     *
*                                                                     *
***********************************************************************

FORM processing_esr USING proc_screen.

  PERFORM get_data.
  PERFORM get_data_esr.
  CHECK retcode = 0.
  PERFORM form_open USING proc_screen vbdkr-land1.
  CHECK retcode = 0.
  PERFORM start_form.
  CHECK retcode = 0.
  CHECK retcode = 0.
  CHECK retcode = 0.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.

***********************************************************************
*                                                                     *
* Standard Routine PROCESSING_ITALY                                   *
*                                                                     *
***********************************************************************

FORM processing_italy USING proc_screen.

  PERFORM get_data.
  PERFORM get_data_italy USING proc_screen.
  CHECK retcode = 0.
  PERFORM form_open USING proc_screen vbdkr-land1.
  CHECK retcode = 0.
  PERFORM form_title_print.
  CHECK retcode = 0.
  PERFORM header_consgnee.
  CHECK retcode = 0.
  PERFORM reference_number.
  CHECK retcode = 0.
  PERFORM tax_text_print USING text_element.
  CHECK retcode = 0.
  PERFORM header_data_print.
  CHECK retcode = 0.
  PERFORM header_text_print.
  CHECK retcode = 0.
  PERFORM item_print.
  CHECK retcode = 0.
  PERFORM end_print.
  CHECK retcode = 0.
  PERFORM form_close.
  CHECK retcode = 0.

ENDFORM.

***********************************************************************
*       SAP STANDARD-SUBROUTINES                                      *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM AMOUNT_FOR_CASH_DISCOUNT                                 *
*---------------------------------------------------------------------*
*       This routine prints the amount qualifying for cash discount.  *
*---------------------------------------------------------------------*

FORM amount_for_cash_discount.

  CHECK vbdkr-skfbk NE 0.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'AMOUNT_QUALIFYING_FOR_CASH_DISCOUNT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PAYMENT_SPLIT                                            *
*---------------------------------------------------------------------*
*       This routine prints the payment split                         *
*---------------------------------------------------------------------*
FORM payment_split.

  DATA: h_skfbt LIKE acccr-skfbt.
  DATA: h_fkdat LIKE vbrk-fkdat.
  DATA: h_fkwrt LIKE acccr-wrbtr.
  DATA : BEGIN OF payment_split OCCURS 3.
          INCLUDE STRUCTURE vtopis.
  DATA : END OF payment_split.


  CHECK vbdkr-zterm NE space.

  h_skfbt = vbdkr-skfbk.
  h_fkwrt = komk-fkwrt.
  h_fkdat = vbdkr-fkdat.
  IF vbdkr-valdt NE 0.
    h_fkdat = vbdkr-valdt.
  ENDIF.
  IF vbdkr-valtg NE 0.
    h_fkdat = vbdkr-fkdat + vbdkr-valtg.
  ENDIF.
  CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT_SPLI'
    EXPORTING
      bldat                         = vbdkr-fkdat
      budat                         = h_fkdat
      cpudt                         = vbdkr-erdat
      language                      = vbco3-spras
      terms_of_payment              = vbdkr-zterm
      wert                          = h_fkwrt  "Warenwert + Tax
      waerk                         = vbdkr-waerk
      fkdat                         = vbdkr-fkdat
      skfbt                         = h_skfbt
    TABLES
      top_text_split                = payment_split
    EXCEPTIONS
      terms_of_payment_not_in_t052  = 01
      terms_of_payment_not_in_t052s = 02.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


  LOOP AT payment_split.

    AT FIRST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'PROTECT'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TERMS_OF_PAYMENT_SPLIT_HEADER'.
    ENDAT.

    vbdkr-text = payment_split-line.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'TERMS_OF_PAYMENT_SPLIT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.

    AT LAST.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'ENDPROTECT'.
    ENDAT.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM CHECK_REPEAT                                             *
*---------------------------------------------------------------------*
*       A text is printed, if it is a repeat print for the document.  *
*---------------------------------------------------------------------*

FORM check_repeat.

  CLEAR repeat.
  SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
                                AND   objky = nast-objky
                                AND   kschl = nast-kschl
                                AND   spras = nast-spras
                                AND   parnr = nast-parnr
                                AND   parvw = nast-parvw
                                AND   nacha BETWEEN '1' AND '4'.
    CHECK *nast-vstat = '1'.
    repeat = 'X'.
    EXIT.   "#EC CI_NOORDER
  ENDSELECT.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_CONSIGNEE                                      *
*---------------------------------------------------------------------*
*       If the consignee in the item is different to the header con-  *
*       signee, it is printed by this routine.                        *
*---------------------------------------------------------------------*

FORM different_consignee.

  CHECK vbdkr-name1_we NE vbdpr-name1_we
    OR  vbdkr-name2_we NE vbdpr-name2_we
    OR  vbdkr-name3_we NE vbdpr-name3_we
    OR  vbdkr-name4_we NE vbdpr-name4_we.
  CHECK vbdpr-name1_we NE space
    OR  vbdpr-name2_we NE space
    OR  vbdpr-name3_we NE space
    OR  vbdpr-name4_we NE space.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_CONSIGNEE'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_DELIVERY_NO                                    *
*---------------------------------------------------------------------*
*       If the delivery number is different to number in the header,  *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_delivery_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdpr-vbeln_vl NE vbdpr-vbeln_vauf.
  CHECK vbdkr-vbeln_vl NE vbdpr-vbeln_vl.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_DELIVERY_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_ORDER_NO                                       *
*---------------------------------------------------------------------*
*       If the order number is different to number in the header,     *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_order_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdkr-vbeln_vauf NE vbdpr-vbeln_vauf.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_ORDER_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM DIFFERENT_EXTERN_NO                                      *
*---------------------------------------------------------------------*
*       If the extern number is different to number in the header,    *
*       it is printed by this routine.                                *
*---------------------------------------------------------------------*

FORM different_extern_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdkr-vbeln_vauf EQ space.
  CHECK vbdkr-vbeln_vl   EQ space.
  CHECK vbdpr-vbeln_vauf EQ space.
  CHECK vbdpr-vbeln_vl   EQ space.
  CHECK vbdkr-vgbel NE vbdpr-vgbel.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_EXTERN_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM DIFFERENT_PURCHASE_ORDER_NO                              *
*---------------------------------------------------------------------*
*       If the purchase order number is different to number in the    *
*       header, it is printed by this routine.                        *
*---------------------------------------------------------------------*

FORM different_purchase_order_no.

  CHECK vbdkr-vbtyp CA 'MUN'.
  CHECK vbdkr-bstnk NE vbdpr-bstnk
    OR  vbdkr-bstdk NE vbdpr-bstdk.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_PURCHASE_ORDER_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM END_PRINT                                                *
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*

FORM end_print.

  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'PROTECT'.
  PERFORM header_price_print.
* Begin of  <RD1K960611>
*  break cab_sudhir.
* End of    <RD1K960611>
  fkwrt = g_pp1_kwert + komk-fkwrt .
  CALL FUNCTION 'Y_FI_AMT_WRDS_CONVERT'
    EXPORTING
      amt    = fkwrt
    IMPORTING
      word   = word
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = 'ENDPROTECT'.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM FORM_CLOSE                                               *
*---------------------------------------------------------------------*
*       End of printing the form                                      *
*---------------------------------------------------------------------*

FORM form_close.

  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.
  CLEAR g_fkimg.
  CLEAR : g_hzr_flg,g_kzwi1.
  CLEAR vbdkr-vbeln.
* Change on dated 10 October 2003 at 6 PM
  REFRESH :  tvbdpr.
  CLEAR : vbdpr,
          g_fk_mg,
          g_br_mg.

  REFRESH :             tkomv.
  REFRESH :             tkomvd.
  REFRESH :             hkomvd.
  REFRESH :             tkomcon.
  SET COUNTRY space.

ENDFORM.

*----------------------------------------------------?----------------*
*       FORM FORM_OPEN                                                *
*---------------------------------------------------------------------*
*       Start of printing the form                                    *
*---------------------------------------------------------------------*
*  -->  US_SCREEN  Output on screen                                   *
*                  ' ' = Printer                                      *
*                  'X' = Screen                                       *
*  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
*---------------------------------------------------------------------*

FORM form_open USING us_screen us_country.

  INCLUDE zsd_invoice_vaexpp_dp_rvadopg.
*  INCLUDE zsd_invoice_vap_dp_rvadopg.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM FORM_TITLE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printing of the form title depending of the field VBTYP       *
*---------------------------------------------------------------------*

FORM form_title_print.
  dtyp = vbdkr-vbtyp.
  CASE dtyp.
    WHEN 'M'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_M'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'N'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_N'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'O'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_O'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'P'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_P'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN 'S'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_S'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.

    WHEN 'U'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_U'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    WHEN OTHERS.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TITLE_M'
          window  = 'TITLE'
        EXCEPTIONS
          element = 1
          window  = 2.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
  ENDCASE.
  IF repeat NE space.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'REPEAT'
        window  = 'REPEAT'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM GET_DATA                                                 *
*---------------------------------------------------------------------*
*       General provision of data for the form                        *
*---------------------------------------------------------------------*

FORM get_data.

  CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
    TABLES
      tkomv = tkomv.
  CLEAR komk.
  CLEAR komp.

  IF nast-objky+10(6) NE space.
    vbco3-vbeln = nast-objky+16(10).
  ELSE.
    vbco3-vbeln = nast-objky.
  ENDIF.

  vbco3-mandt = sy-mandt.
  vbco3-spras = nast-spras.
  vbco3-kunde = nast-parnr.
  vbco3-parvw = nast-parvw.


  CALL FUNCTION 'RV_BILLING_PRINT_VIEW'
    EXPORTING
      comwa                        = vbco3
    IMPORTING
      kopf                         = vbdkr
    TABLES
      pos                          = tvbdpr
    EXCEPTIONS
      terms_of_payment_not_in_t052 = 1
      error_message                = 5
      OTHERS                       = 4.
  IF NOT sy-subrc IS INITIAL.
    IF sy-subrc = 1.
      syst-msgty = 'I'.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM vbrp WHERE vbeln = vbdkr-vbeln.
  PERFORM sender.
  PERFORM check_repeat.
  PERFORM get_header_prices.

  LOOP AT tkomv.
    CASE tkomv-kschl.
*&------- Begin of TR ---------&*
*  break cab_sudhir.
*&------- End of TR ---------&*
      WHEN 'PR00' OR 'ZPP1' OR 'ZDP1'.                      "080708
        IF tkomv-kschl = 'PR00'.
          l_kpein = tkomv-kpein.
        ENDIF.
        IF tkomv-kschl = 'ZPP1' OR tkomv-kschl = 'ZDP1'.
          g_pp1_kwert = g_pp1_kwert + tkomv-kwert.
        ENDIF.
        g_cmpre = g_cmpre + tkomv-kbetr .
    ENDCASE.
  ENDLOOP.
  g_cmpre = g_cmpre / l_kpein.

*  read table tkomv with key kschl = 'PR00'.
*  g_cmpre = tkomv-kbetr / tkomv-kpein.

  IF tvbdpr-brgew > 0.
    g_flg_mg = 'X'.
    READ TABLE tkomv WITH KEY kschl = 'ZMGG'.
    g_cmpre1 = tkomv-kbetr / tkomv-kpein.
    g_br_mg = tvbdpr-brgew - tvbdpr-ntgew.
    g_fk_mg = tkomv-kwert.

  ENDIF.
* Calling customer subroutine dynamically for additional data transfer
  IF NOT get_data_userexit IS INITIAL.
    PERFORM (get_data_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.
*  SELECT SINGLE * FROM adrc WHERE addrnumber = vbdkr-adrnr.
    SELECT * FROM adrc UP TO 1 rows WHERE addrnumber = vbdkr-adrnr ORDER BY PRIMARY KEY. ENDSELECT.
  IF NOT adrc-str_suppl1 IS INITIAL.
    street2 = 'X'.
  ENDIF.
  IF NOT adrc-str_suppl2 IS INITIAL.
    street3 = 'X'.
  ENDIF.
  IF NOT adrc-str_suppl3 IS INITIAL.
    street4 = 'X'.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM GET_ITEM_CHARACTERISTICS                                 *
*---------------------------------------------------------------------*
*       In this routine the configuration da?a item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_characteristics.

  REFRESH tkomcon.
  CHECK NOT vbdpr-cuobj IS INITIAL.

  CALL FUNCTION 'CUD0_GET_CONFIGURATION'
    EXPORTING
      instance      = vbdpr-cuobj
      language      = nast-spras
    TABLES
      configuration = tkomcon
    EXCEPTIONS
      OTHERS        = 4.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM GET_ITEM_PRICES                                          *
*---------------------------------------------------------------------*
*       In this routine the price data for the item is fetched from   *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_item_prices.

  CLEAR: komp,
         tkomv.
  IF komk-knumv NE vbdkr-knumv.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkr-kalsm.
    komk-fkart = vbdkr-fkart.
    komk-kappl = pr_kappl.
    IF vbdkr-kappl NE space.
      komk-kappl = vbdkr-kappl.
    ENDIF.
    komk-waerk = vbdkr-waerk.
    komk-knumv = vbdkr-knumv.
    komk-vbtyp = vbdkr-vbtyp.
  ENDIF.
  komp-kposn = vbdpr-posnr.

  CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
    EXPORTING
      comm_head_i = komk
      comm_item_i = komp
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_item_e = komp
    TABLES
      tkomv       = tkomv
      tkomvd      = tkomvd.

* Calling customer subroutine dynamically for handling item prices
  IF NOT item_userexit IS INITIAL.
    PERFORM (item_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM GET_HEADER_PRICES                                        *
*---------------------------------------------------------------------*
*       In this routine the price data for the header is fetched from *
*       the database.                                                 *
*---------------------------------------------------------------------*

FORM get_header_prices.

  IF komk-knumv NE vbdkr-knumv.
    CLEAR komk.
    komk-mandt = sy-mandt.
    komk-kalsm = vbdkr-kalsm.
    komk-fkart = vbdkr-fkart.
    komk-kappl = pr_kappl.
    IF vbdkr-kappl NE space.
      komk-kappl = vbdkr-kappl.
    ENDIF.
    komk-waerk = vbdkr-waerk.
    komk-knumv = vbdkr-knumv.
    komk-vbtyp = vbdkr-vbtyp.
    komk-knuma = vbdkr-knuma.
  ENDIF.
  CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
    EXPORTING
      comm_head_i = komk
      language    = nast-spras
    IMPORTING
      comm_head_e = komk
      comm_mwskz  = print_mwskz
    TABLES
      tkomv       = tkomv
      tkomvd      = hkomvd.
* Calling customer subroutine dynamically for handling header prices
  IF NOT header_userexit IS INITIAL.
    PERFORM (header_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM HEADER_PRICE_PRINT                                       *
*---------------------------------------------------------------------*
*       Printout of the header prices                                 *
*---------------------------------------------------------------------*

FORM header_price_print.

  LOOP AT hkomvd.

    AT FIRST.
      IF komk-supos NE 0.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_SUM'.
      ELSE.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDAT.

    komvd = hkomvd.
    IF print_mwskz = space.
      CLEAR komvd-mwskz.
    ENDIF.
  ENDLOOP.
  DESCRIBE TABLE hkomvd LINES sy-tfill.
  IF sy-tfill = 0.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.
  ENDIF.
* Calling customer subroutine dynamic0ally for handling header price
* printing
  IF NOT header_print_userexit IS INITIAL.
    PERFORM (header_print_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM HEADER_TEXT_PRINT                                        *
*---------------------------------------------------------------------*
*       Printout of the headertexts                                   *
*---------------------------------------------------------------------*

FORM header_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_CHARACERISTICS_PRINT                                *
*---------------------------------------------------------------------*
*       Printout of the item characteristics -> configuration         *
*---------------------------------------------------------------------*

FORM item_characteristics_print.

  LOOP AT tkomcon.
    conf_out = tkomcon.
    IF sy-tabix = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION_HEADER'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'ITEM_LINE_CONFIGURATION'
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc NE 0.
        PERFORM protocol_update.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_PRICE_PRINT                                         *
*---------------------------------------------------------------------*
*       Printout of the item prices                                   *
*---------------------------------------------------------------------*

FORM item_price_print.
*  read table tkomv with key kschl = 'PR01'.
  IF g_pr01flag = 'X'.
    READ TABLE tkomv WITH KEY kschl = 'PR01' kposn = vbdpr-posnr.
    total1 = total1 + tkomv-kwert.
  ELSE.
    READ TABLE tkomv WITH KEY kschl = 'PR00'.
    total1 = total1 + vbdpr-kzwi1.
  ENDIF.
  t_fkimg = t_fkimg + vbdpr-fkimg.


  CLEAR pname.
  CONCATENATE vbrk-vbeln vbdpr-posnr INTO pname.
*  CALL FUNCTION 'READ_TEXT'
*       EXPORTING
*            client                  = sy-mandt
*            id                      = '0006'
*            language                = sy-langu
*            name                    = pname
*            object                  = 'VBBP'
*       TABLES
*            lines                   = it_name
*       EXCEPTIONS
*            id                      = 1
*            language                = 2
*            name                    = 3
*            not_found               = 4
*            object                  = 5
*            reference_check         = 6
*            wrong_access_to_archive = 7
*            OTHERS                  = 8.
*  IF sy-subrc NE 0.
*    PERFORM protocol_update.
*  ENDIF.


  IF sy-subrc = 0.
    READ TABLE it_name INDEX 1.
    IF sy-subrc = 0.
      vbdkr-fkdat = it_name-tdline.
    ENDIF.
  ENDIF.


  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_LINE_PRICE_QUANTITY'.

  g_hzr_flg = 'X'.


  DATA: BEGIN OF tkomv_1 OCCURS 50.
          INCLUDE STRUCTURE komv.
  DATA: END OF tkomv_1.
  REFRESH tkomv_1.
  CLEAR   tkomv_1.
  tkomv_1[] = tkomv[].
* Calling customer subroutine dynamically for handling item price
* printing
  IF NOT item_print_userexit IS INITIAL.
    PERFORM (item_print_userexit) IN PROGRAM rvadin01 IF FOUND.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT                                               *
*---------------------------------------------------------------------*
*       Printout of the items                                         *
*---------------------------------------------------------------------*

FORM item_print.


  CALL FUNCTION 'WRITE_FORM'           "First header
    EXPORTING
      element = 'ITEM_HEADER'
    EXCEPTIONS
      OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'           "Activate header
    EXPORTING
      element = 'ITEM_HEADER'
      type    = 'TOP'
    EXCEPTIONS
      OTHERS  = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
* Change on dated 9 October 2003
  LOOP AT tvbdpr.

    g_fkimg = g_fkimg + tvbdpr-fkimg.
    g_kzwi1 = g_kzwi1 + tvbdpr-kzwi1.
* Change on dated 10 Octber 2003
    g_volum = g_volum + tvbdpr-volum.
* end of change
  ENDLOOP.


* End of Change
  LOOP AT tvbdpr.

    vbdpr = tvbdpr.
**************For ISOIL DATA Added on 19/09/03
    SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl
                                  AND msehi = 'KLN'
                                  AND posnr = vbdpr-posnr.
    kln = kln + lipso2-adqntp.

**********************************

    IF tvbdpr-uecha EQ vbdpr-posnr OR
       tvbdpr-uecha IS INITIAL.
      PERFORM get_item_prices.
      PERFORM get_item_characteristics.
      fkimg =   vbdpr-fkimg + fkimg.   " QUANTITY TOTAL

      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'PROTECT'.
      IF counter1 = 0.
        IF sy-tabix > 1.
          sy-tabix = 1.
          tabix = sy-tabix.
        ENDIF.
      ELSE.
        sy-tabix = tabix .
        sy-tabix = sy-tabix + 1.
      ENDIF.
      counter1 = counter1 + 1.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'ENDPROTECT'.
    ELSE.
      IF NOT tvbdpr-fkimg IS INITIAL.
        PERFORM get_item_prices.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_BATCH'
          EXCEPTIONS
            OTHERS  = 1.
        IF sy-subrc NE 0.
          PERFORM protocol_update.
        ENDIF.
      ENDIF.
    ENDIF.
    PERFORM item_price_print.
    IF counter1 = 1.
      LOOP AT tkomv.
****    Start of UCCheck change 17.06.2016
*              KOMVD = TKOMV.
        MOVE-CORRESPONDING komvd TO tkomv.
****    End of UCCheck change 17.06.2016

        IF print_mwskz EQ space.
          CLEAR komvd-mwskz.
        ENDIF.
        IF tkomvd-kstat EQ space.
          kwert = tkomv-kwert + kwert.
        ENDIF.

        CASE  tkomv-kschl.

          WHEN 'ZASV'.
            tot_zasv =  tkomv-kbetr.
          WHEN 'ZFRT'.
            tot_zfrt =  tkomv-kbetr.
          WHEN 'ZSCG'.
            tot_zscg =  tkomv-kbetr.
          WHEN 'JMOD'.
            jmod_kbetr = tkomv-kbetr / 10.
            tot_edr =  tot_edr + tkomv-kwert.
          WHEN 'ZOCR'.
            zocr_kbetr = tkomv-kbetr / 10.
            tot_ocr = tot_ocr + tkomv-kwert.

          WHEN 'JIN1'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_zin1 = val_zin1 + tkomv-kwert.
            zin1_kbetr = tkomv-kbetr / 10.

          WHEN 'JIN2'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_zin2 = val_zin2 + tkomv-kwert.
            zin2_kbetr = tkomv-kbetr / 10.

          WHEN 'JIN4'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_zin4 = val_zin4 + tkomv-kwert.
            zin4_kbetr = tkomv-kbetr / 10.
          WHEN 'JIN5'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_zin5 = val_zin5 + tkomv-kwert.
            zin5_kbetr = tkomv-kbetr / 10.
          WHEN 'JIN6'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_zin6 = val_zin6 + tkomv-kwert.
            zin6_kbetr = tkomv-kbetr / 10.
          WHEN 'JCES'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_cess = val_cess + tkomv-kwert.
            cess_kbetr = tkomv-kbetr / 10.
          WHEN 'ZAED'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_excise = val_excise + tkomv-kwert.
            .
            excise_kbetr = tkomv-kbetr.
          WHEN 'ZEDC' OR 'JECX'.
            poscnt1 = poscnt1 + 1.
            tot_zin = tot_zin + tkomv-kwert.
            val_educess = val_educess + tkomv-kwert.
            .
            educess_kbetr = 2. "tkomv-kbetr.
        ENDCASE.
        wrk_tabix = sy-tabix.
      ENDLOOP.
    ENDIF.
    PERFORM end_print.
    AT LAST.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = 'TOTAL_TEST1'.

    ENDAT.

  ENDLOOP.
  CLEAR total1.
  LOOP AT tkomv.
***    UC Check Start of change 17.06.2016
*    komvd = tkomv.
    MOVE-CORRESPONDING komvd TO tkomv.
***    End of Change UCCheck

    IF vbdkr-spart = 'SK' OR vbdkr-spart = 'HS' OR vbdkr-spart = 'LS'.
      countsko = countsko + 1.
      IF countsko = 1.
        SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl
                                      AND msehi = 'KLN'
                                      AND posnr = vbdpr-posnr.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'ITEM_LINE_PRICE_ZSKO'.

      ENDIF.
    ENDIF.
    IF tkomv-kschl = 'ZASV'.
      count1 = count1 + 1.
      IF zasv <> 'X'.
        zasv = 'X'.
        IF count1 = 1.
          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                      AND   kschl = tkomv-kschl
                                      AND   kvewe = 'A'
                                       AND   kappl = 'V'.


          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZASV'.

        ENDIF.
      ENDIF.

    ENDIF.
    IF tkomv-kschl = 'ZFRT'.
      count2 = count2 + 1.
      IF zfrt <> 'X'.
        zfrt = 'X'.
        IF count2 = 1.
          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kschl = tkomv-kschl
                                      AND   kvewe = 'A'
                                       AND   kappl = 'V'.


          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZFRT'.

        ENDIF.
      ENDIF.

    ENDIF.
    IF tkomv-kschl = 'ZSCG'.
      count3 = count3 + 1.
      IF zscg <> 'X'.
        zscg = 'X'.
        IF tkomv-kschl = 'ZASV' OR tkomv-kschl = 'ZFRT' OR
        tkomv-kschl = 'ZSCG'.
          IF count3 = 1 .
            SELECT SINGLE * FROM t685t WHERE spras = sy-langu
                                          AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                          AND   kappl = 'V'.


            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_LINE_PRICE_ZSCG'.

            total1 = tot_zasv + tot_zfrt + tot_zscg.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'TOTAL_TEST'.

          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.


    IF tkomv-kschl = 'JMOD'.
      count4 = count4 + 1.
      IF jmod <> 'X'.
        jmod = 'X'.
        IF count4 = 1 AND tot_edr > 0.

          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                       AND   kappl = 'V'.


          jmod_kbetr = tkomv-kbetr / 10.

          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZEDR'.

        ENDIF.
      ENDIF.
    ENDIF.



    IF tkomv-kschl = 'ZAED'.
      count5 = count5 + 1.
      IF zaed <> 'X'.
        zaed = 'X'.
        IF count5 = 1 AND val_excise > 0.

          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                       AND   kappl = 'V'.



          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZAED'.

        ENDIF.
      ENDIF.
    ENDIF.



    IF tkomv-kschl = 'JCES'.
      count6 = count6 + 1.
      IF jces <> 'X'.
        jces = 'X'.
        IF count6 = 1 AND val_cess > 0.

          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                       AND   kappl = 'V'.



          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_JCES'.

        ENDIF.
      ENDIF.
    ENDIF.

    IF tkomv-kschl = 'ZOCR'.
      count7 = count7 + 1.
      IF zocr <> 'X'.
        zocr = 'X'.
        IF count7 = 1.
          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kvewe = 'A'
                                      AND   kappl = 'V'
                                       AND   kschl = tkomv-kschl.

          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZOCR'.

        ENDIF.
      ENDIF.

    ENDIF.

    SELECT SINGLE * FROM vbrp WHERE vbeln = vbdkr-vbeln
                                AND posnr = vbdpr-posnr.
    IF vbdkr-vkorg <> 'URNS' OR vbrp-werks <> '10K2'.
      IF tkomv-kschl = 'JIN1'.
        count8 = count8 + 1.
        IF zin1 <> 'X'.
          zin1 = 'X'.
          IF count8 = 1 AND val_zin1 > 0.
            SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                         AND   kvewe = 'A'
                                        AND   kappl = 'V'
                                         AND   kschl = tkomv-kschl.

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_ZIN1'.

          ENDIF.
        ENDIF.
      ENDIF.
      IF tkomv-kschl = 'JIN2'.
        count9 = count9 + 1.
        IF zin2 <> 'X'.
          zin2 = 'X'.
          IF count9 = 1 AND val_zin2 > 0.
            SELECT SINGLE * FROM t685t WHERE   spras = 'EN'
                                         AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                         AND   kappl = 'V'.

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_ZIN2'.

          ENDIF.
        ENDIF.
      ENDIF.
      IF tkomv-kschl = 'JIN4'.
        count10 = count10 + 1.
        IF zin4 <> 'X'.
          zin4 = 'X'.
          IF count10 = 1 AND val_zin4 > 0.
            SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                         AND   kvewe = 'A'
                                         AND   kappl = 'V'
                                         AND   kschl = tkomv-kschl.

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_ZIN4'.

          ENDIF.
        ENDIF.
      ENDIF.
      IF tkomv-kschl = 'JIN5'.
        count11 = count11 + 1.
        IF zin5 <> 'X'.
          zin5 = 'X'.
          IF count11 = 1 AND val_zin5 > 0.
            SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                         AND   kvewe = 'A'
                                         AND   kappl = 'V'
                                         AND   kschl = tkomv-kschl.

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_ZIN5'.

          ENDIF.
        ENDIF.
      ENDIF.
      IF tkomv-kschl = 'JIN6'.
        count12 = count12 + 1.
        IF zin6 <> 'X'.
          zin6 = 'X'.
          IF count12 = 1 AND val_zin6 > 0.
            SELECT SINGLE * FROM t685t WHERE   spras = 'EN'
                                         AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                         AND   kappl = 'V'.


            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = 'ITEM_ZIN6'.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF tkomv-kschl = 'ZEDC' OR tkomv-kschl = 'JECX' .
      count13 = count13 + 1.
      IF zedc <> 'X'.
        zedc = 'X'.
        IF count13 = 1 AND val_educess > 0.

          SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
                                       AND   kschl = tkomv-kschl
                                          AND   kvewe = 'A'
                                       AND   kappl = 'V'.



          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'ITEM_LINE_PRICE_ZEDC'.

        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF g_pr01flag = 'X'.
    LOOP AT tkomv WHERE kschl = 'PR01'.
      total1 = total1 + tkomv-kwert .
    ENDLOOP.
    IF vbdkr-vtweg  = 'RD'.
      total1 = total1 - zintotal.
    ENDIF.
  ELSE.
    total1 = g_kzwi1.
  ENDIF.

  LOOP AT tkomv WHERE kschl = 'ZDIF'.
    roundoff = roundoff + tkomv-kwert.
  ENDLOOP.
**Total2 contains Invoice final value komk-fkwrt
  IF vbdkr-vkorg = 'HZRS'.
    total2 = tot_zin + tot_edr + tot_ocr + g_kzwi1 + roundoff.
  ELSE.
    total2 = tot_zin + tot_edr + tot_ocr + total1 + roundoff.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'TOTAL_TEST_TAX'.
  CALL FUNCTION 'Y_FI_AMT_WRDS_CONVERT'
    EXPORTING
      amt    = fkwrt
    IMPORTING
      word   = word
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'END_VALUES'.
  CALL FUNCTION 'WRITE_FORM'           "Deactivate Header
    EXPORTING
      element  = 'ITEM_HEADER'
      function = 'DELETE'
      type     = 'TOP'
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'SUPPLEMENT_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.
  CLEAR roundoff.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_TEXT_PRINT                                          *
*---------------------------------------------------------------------*
*       Printout of the item texts                                    *
*---------------------------------------------------------------------*

FORM item_text_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_TEXT'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM REFERENCE_NUMBER                                         *
*---------------------------------------------------------------------*
*       Printing of the reference numbers                             *
*---------------------------------------------------------------------*

FORM reference_number.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'REFERENCE_NUMBER'
      window  = 'REFNUMB'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM SENDER                                                   *
*---------------------------------------------------------------------*
*       This routine determines the address of the sender (Table VKO) *
*---------------------------------------------------------------------*

FORM sender.

  SELECT SINGLE * FROM tvko  WHERE vkorg = vbdkr-vkorg.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'TVKO'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
    EXIT.
  ENDIF.
*  SELECT SINGLE * FROM sadr WHERE adrnr = tvko-adrnr
*                            AND   natio = space.
  vbdkr-sland = sadr-land1.
  IF sy-subrc NE 0.
    syst-msgid = 'VN'.
    syst-msgno = '203'.
    syst-msgty = 'E'.
    syst-msgv1 = 'SADR'.
    syst-msgv2 = syst-subrc.
    PERFORM protocol_update.
  ENDIF.

  IF vbdkr-vbtyp CA '56'.
    CLEAR t001g.
    SELECT SINGLE * FROM t001g WHERE bukrs = vbdkr-bukrs
                                 AND programm EQ sy-repid
                                 AND txtid EQ 'SD'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  HEADER_CONSGNEE
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_consgnee.

  IF vbdkr-name1 NE vbdkr-name1_we OR
     vbdkr-name2 NE vbdkr-name2_we OR
     vbdkr-name3 NE vbdkr-name3_we OR
     vbdkr-name4 NE vbdkr-name4_we   .
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_CONSGNEE'
        window  = 'CONSGNEE'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'HEADER_CONSGNEE'
        window  = 'INFO1'
      EXCEPTIONS
        element = 1
        window  = 2.
    IF sy-subrc NE 0.
      PERFORM protocol_update.
    ENDIF.

  ENDIF.
ENDFORM.                               " HEADER_CONSGNEE
*&---------------------------------------------------------------------*
*&      Form  DIFFERENT_REFERENCE_NO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM different_reference_no.

  CHECK vbdkr-vbtyp CA 'OP'.
  CHECK vbdkr-vbeln_vg2 NE vbdpr-vbeln_vg2.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'ITEM_REFERENCE_NO'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " DIFFERENT_REFERENCE_NO
*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM header_data_print.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'HEADER_DATA'
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " HEADER_DATA_PRINT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ESR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_esr.

  CALL FUNCTION 'SD_ESR_GET_DATA'
    EXPORTING
      vbdkr_bukrs                   = vbdkr-bukrs
      vbdkr_vkorg                   = vbdkr-vkorg
      komk_fkwrt                    = komk-fkwrt
      vbdkr_vbeln                   = vbdkr-vbeln
      vbdkr_kunrg                   = vbdkr-kunrg
      vbdkr_waerk                   = vbdkr-waerk
    CHANGING
      ivbdre                        = vbdre
    EXCEPTIONS
      t049e_no_entry                = 1
      t001_no_entry                 = 2
      bnka_no_entry                 = 3
      sadr_no_entry                 = 4
      fkwrt_not_valid               = 5
      esr_digits_to_check_not_valid = 6
      esr_check_method_not_valid    = 7
      OTHERS                        = 8.

  IF sy-subrc NE 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " GET_DATA_ESR

*----------------------------------------------------------------------*
*       Form  GET_DATA_ITALY
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
*
*
*----------------------------------------------------------------------*
FORM get_data_italy USING proc_screen.

  CLEAR konh.
  CLEAR tlic.
  LOOP AT tkomv WHERE koaid = 'D'
                AND   kntyp ='+'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE * FROM konh WHERE knumh = tkomv-knumh.
    SELECT * FROM konh UP TO 1 ROWS WHERE knumh = tkomv-knumh ORDER BY PRIMARY KEY.
    ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc EQ 0.
      IF NOT konh-licno IS INITIAL AND NOT konh-licdt IS INITIAL.
*        SELECT SINGLE * FROM tlic WHERE licno = konh-licno.
        SELECT * FROM tlic UP TO 1 rows WHERE licno = konh-licno ORDER BY PRIMARY KEY. ENDSELECT.
        IF sy-subrc EQ 0.
          IF NOT tlic-prnum_nr IS INITIAL AND
             NOT tlic-prnum_dt IS INITIAL.
            MOVE:
              konh-licno TO vbdkr-licno,
              konh-licdt TO vbdkr-licdt.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF vbdkr-licno     IS INITIAL OR
       vbdkr-licdt     IS INITIAL OR
       tlic-prnum_nr   IS INITIAL OR
       tlic-prnum_dt   IS INITIAL.
      IF proc_screen = space.
        retcode = 3.
        syst-msgno = '205'.
        syst-msgid = 'VN'.
        syst-msgty = 'I'.
        PERFORM protocol_update.
      ELSE.
        MESSAGE i205.
      ENDIF.
    ENDIF.
    EXIT.
  ENDLOOP.



ENDFORM.                               " get_data_italy

*&---------------------------------------------------------------------*
*&      Form  START_FORM
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_form.

  DATA : startseite(8)  VALUE 'FIRSTBSR'.
  DATA : sprache LIKE sy-langu.

  IF vbdre-verfa = '04' OR vbdre-verfa = '08'.

    CALL FUNCTION 'START_FORM'
      EXPORTING
        startpage = startseite
      IMPORTING
        language  = sprache
      EXCEPTIONS
        form      = 1
        format    = 2
        unended   = 3
        unopened  = 4
        unused    = 5
        OTHERS    = 6.
    IF sy-subrc NE 0.
      retcode = sy-subrc.
      PERFORM protocol_update.
    ENDIF.

  ENDIF.

ENDFORM.                               " START_OPEN
*&---------------------------------------------------------------------*
*&      Form  TAX_TEXT_PRINT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tax_text_print USING text_element.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = text_element
    EXCEPTIONS
      element = 1
      window  = 2.
  IF sy-subrc NE 0.
    PERFORM protocol_update.
  ENDIF.

ENDFORM.                               " TAX_TEXT_PRINT

***********************************************************************
*                SUBROUTINES OF ENTRY_CH                              *
***********************************************************************

FORM header_ch.
  CLEAR print_local_curr_ch.
  SELECT SINGLE * FROM t001 WHERE bukrs EQ vbdkr-bukrs.
  CHECK sy-subrc = 0.
  CHECK t001-waers <> vbdkr-waerk.
  MOVE 'X' TO print_local_curr_ch.
  REFRESH komvdk_ch.
  LOOP AT hkomvd WHERE koaid = 'D'.
    CLEAR komvdk_ch.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = vbdkr-fkdat
        foreign_amount   = hkomvd-kwert
        foreign_currency = vbdkr-waerk
        local_currency   = t001-waers
        rate             = vbdkr-kurrf
      IMPORTING
        local_amount     = komvdk_ch-kwert
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        OTHERS           = 5.
    CHECK sy-subrc = 0.
    MOVE: t001-waers TO komvdk_ch-awein,
          t001-waers TO komvdk_ch-awei1,
          hkomvd-vtext TO komvdk_ch-vtext,
          vbdkr-kurrf TO hkomvd-kkurs.
    APPEND komvdk_ch.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_CH                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM item_ch.
  CHECK print_local_curr_ch EQ 'X'.
  REFRESH komvdp_ch.
  LOOP AT tkomvd WHERE koaid = 'D'.
    CLEAR komvdp_ch.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = vbdkr-fkdat
        foreign_amount   = tkomvd-kwert
        foreign_currency = vbdkr-waerk
        local_currency   = t001-waers
        rate             = vbdkr-kurrf
      IMPORTING
        local_amount     = komvdp_ch-kwert
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        OTHERS           = 5.
    CHECK sy-subrc = 0.
    MOVE: t001-waers TO komvdp_ch-awein,
          t001-waers TO komvdp_ch-awei1,
          tkomvd-vtext TO komvdp_ch-vtext,
          vbdkr-kurrf TO komvdp_ch-kkurs.
    APPEND komvdp_ch.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM ITEM_PRINT_CH                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM item_print_ch.
  LOOP AT komvdp_ch.
    komvd = komvdp_ch.
    IF print_mwskz EQ space.
      CLEAR komvd-mwskz.


    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'ITEM_LINE_TAX_HAUSWAEHRUNG'.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM HEADER_PRINT_CH                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM header_print_ch.
  LOOP AT komvdk_ch.
    komvd = komvdk_ch.
    IF print_mwskz = space.
      CLEAR komvd-mwskz.
    ENDIF.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = 'SUM_LINE_TAX_HAUSWAEHRUNG'.
  ENDLOOP.
ENDFORM.

***********************************************************************
*       CUSTOMER SUBROUTINES                                          *
***********************************************************************
*&---------------------------------------------------------------------*
*&      Form  get_fkwrt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Form  get_fkwrt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_fkwrt.
  LOOP AT tkomv.
    CASE  tkomv-kschl.
      WHEN 'JIN1'.
        zintotal =  zintotal + tkomv-kwert.
      WHEN 'JIN2'.
        zintotal = zintotal + tkomv-kwert.
      WHEN 'JIN4'.
        zintotal = zintotal + tkomv-kwert.
      WHEN 'JIN5'.
        zintotal = zintotal + tkomv-kwert.
      WHEN 'JIN6'.
        zintotal = zintotal + tkomv-kwert.
      WHEN 'JMOD'.
        jmodtotal = jmodtotal + tkomv-kwert.
      WHEN 'ZDIF'.
        zdif = zdif + tkomv-kwert.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " get_fkwrt
*
