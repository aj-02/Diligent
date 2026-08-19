*&---------------------------------------------------------------------*
*& Report  ZF_CHECK_OI_BALANCE_EXT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

*REPORT  ZF_CHECK_OI_BALANCE_EXT.
*&---------------------------------------------------------------------*
*& Report  ZF_CHECK_OI_BALANCE_EXT
*&
*&---------------------------------------------------------------------*
*& GLT0: cumulated balances via
*& G_TOTALS_SELECT_WITH_CURRENCY
*& Change Log : ZF_CHECK_OI_BALANCE with extended collect amount fields to
*& avoid dump in collect !!
*&---------------------------------------------------------------------*

REPORT  zf_check_oi_balance_ext LINE-SIZE 150 NO STANDARD PAGE HEADING.

TYPES: BEGIN OF coll,
       bukrs         TYPE bseg-bukrs,
       koart         TYPE bseg-koart,
       hkont         TYPE bseg-hkont,
       gsber         TYPE bseg-gsber,
       pswsl         TYPE bseg-pswsl,
       dmbtr         TYPE glt0-HSLVT, " Sushil
       dmbe2         TYPE glt0-KSLVT, " Sushil
       dmbe3         TYPE glt0-KSLVT, " Sushil
       pswbt         TYPE glt0-TSLVT, " Sushil
       hsl           TYPE glu1-hsl,
       ksl           TYPE glu1-ksl,
       osl           TYPE glu1-osl,
       tsl           TYPE glu1-tsl,
       d_dmbtr       TYPE bseg-dmbtr,
       d_dmbe2       TYPE bseg-dmbe2,
       d_dmbe3       TYPE bseg-dmbe3,
       d_pswbt       TYPE bseg-pswbt,
       cnt           TYPE i,
       xsalh         TYPE skb1-xsalh,
       END OF coll.

DATA: it_coll TYPE TABLE OF coll WITH HEADER LINE,
      it_corr TYPE SORTED TABLE OF coll WITH HEADER LINE
      WITH UNIQUE KEY bukrs koart hkont gsber pswsl.

TYPES: BEGIN OF sum1,
       bukrs   TYPE bseg-bukrs,
       koart   TYPE bseg-koart,
       hkont   TYPE bseg-hkont,
       pswsl   TYPE bseg-pswsl,
       d_dmbtr TYPE bseg-dmbtr,
       d_dmbe2 TYPE bseg-dmbe2,
       d_dmbe3 TYPE bseg-dmbe3,
       d_pswbt TYPE bseg-pswbt,
       END OF sum1.
DATA: it_sum1 TYPE TABLE OF sum1 WITH HEADER LINE.

TYPES: BEGIN OF sum2,
       bukrs   TYPE bseg-bukrs,
       koart   TYPE bseg-koart,
       hkont   TYPE bseg-hkont,
       gsber   TYPE bseg-gsber,
       d_dmbtr TYPE bseg-dmbtr,
       d_dmbe2 TYPE bseg-dmbe2,
       d_dmbe3 TYPE bseg-dmbe3,
       END OF sum2.
DATA: it_sum2 TYPE TABLE OF sum2 WITH HEADER LINE.

TYPES: BEGIN OF sum3,
       bukrs   TYPE bseg-bukrs,
       koart   TYPE bseg-koart,
       hkont   TYPE bseg-hkont,
       d_dmbtr TYPE bseg-dmbtr,
       d_dmbe2 TYPE bseg-dmbe2,
       d_dmbe3 TYPE bseg-dmbe3,
       END OF sum3.
DATA: it_sum3 TYPE TABLE OF sum3 WITH HEADER LINE.

TYPES: BEGIN OF gltab,
       rldnr    TYPE glt0-rldnr,
       curr(1)  TYPE c,
       curtp    TYPE t001a-curtp,
       curt1    TYPE curt_hsl,
       curt2    TYPE curt_ksl,
       curt3    TYPE curt_osl,
       fg_curt1 TYPE fg_curt,
       fg_curt2 TYPE fg_curt,
       fg_curt3 TYPE fg_curt,
       END OF gltab.
DATA: it_ldglt0 TYPE SORTED TABLE OF gltab WITH HEADER LINE
      WITH UNIQUE KEY rldnr curr.

TYPES: BEGIN OF skb1_change,
       bukrs TYPE skb1-bukrs,
       hkont TYPE skb1-saknr,
       xsalh TYPE skb1-xsalh,
       xloeb TYPE skb1-xloeb,
       xspeb TYPE skb1-xspeb,
       END OF skb1_change.
DATA: it_skb1_change TYPE TABLE OF skb1_change WITH HEADER LINE.

TYPES: BEGIN OF ska1_change,
       ktopl TYPE ska1-ktopl,
       hkont TYPE ska1-saknr,
       xloev TYPE ska1-xloev,
       xspeb TYPE ska1-xspeb,
       END OF ska1_change.
DATA: it_ska1_change TYPE TABLE OF ska1_change WITH HEADER LINE,
      wa_ska1 TYPE ska1.

DATA: it_org_info LIKE glx_org_info OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF xskb1.
        INCLUDE STRUCTURE skb1.
TYPES: mult_umskz(1) TYPE c,
       umskz(1) TYPE c,
       END OF xskb1.
DATA: it_skb1 TYPE TABLE OF xskb1 WITH HEADER LINE,
      it_skb1_corr TYPE TABLE OF xskb1 WITH HEADER LINE.

DATA: it_ledtab TYPE TABLE OF gledtab WITH HEADER LINE,
      wa_t001a TYPE t001a,
      wa_t001 TYPE t001,
      wa_bsas TYPE bsas,
      wa_bsad TYPE bsad,
      wa_bsak TYPE bsak,
      cnt TYPE p,
      head(1) TYPE c,
      wa_koart TYPE bseg-koart.

DATA: x_gjahr TYPE bkpf-gjahr,
      x_monat TYPE bkpf-monat.

DATA: key_date TYPE bkpf-budat,
      wa_fday  TYPE budat.

*** RFDT_KEY for data export of IT_CORR to RFDT
DATA: exp_key(22) TYPE c.
DATA: BEGIN OF rfdt_key,
      key1(7) TYPE c,
      date    LIKE sy-datlo,
      time    LIKE sy-timlo,
      END OF rfdt_key.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
PARAMETERS: p_bukrs  TYPE bsas-bukrs OBLIGATORY,
            p_year TYPE bsas-gjahr OBLIGATORY DEFAULT '2009'.
SELECTION-SCREEN SKIP.
PARAMETERS: koart_s RADIOBUTTON GROUP inc DEFAULT 'X',
            koart_d RADIOBUTTON GROUP inc,
            koart_k RADIOBUTTON GROUP inc.
SELECTION-SCREEN SKIP.
PARAMETERS: c_single AS CHECKBOX,
            p_hkont TYPE bsis-hkont.
PARAMETERS: wr_rfdt AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK 001.

START-OF-SELECTION.

*** get company code master data
  SELECT SINGLE * FROM t001 INTO wa_t001
    WHERE bukrs = p_bukrs.

*** determine key date for reconsiliation
  PERFORM set_keydate.
*** get GLT0 ledgers
  PERFORM get_ledgers.
  PERFORM output_ledgers.
*** select G/L master data
  PERFORM select_skb1.
*** process reconsiliation
  IF koart_s EQ 'X'.
    PERFORM collect_s.
  ELSEIF koart_d EQ 'X'.
    PERFORM collect_d.
  ELSEIF koart_k EQ 'X'.
    PERFORM collect_k.
  ENDIF.
*** output results
  IF cnt = 0.
    WRITE:/ 'No differences found' COLOR 3.
  ELSE.
    PERFORM output.
  ENDIF.

TOP-OF-PAGE.
  PERFORM top.

*&---------------------------------------------------------------------*
*&      Form  COLLECT_S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_s .
  DATA: save_index TYPE sy-tabix.
*** set KOART for GLT0 collect
  wa_koart = 'S'.

  LOOP AT it_skb1.
*** BSIS
    SELECT * FROM bsis INTO wa_bsas
      WHERE bukrs EQ p_bukrs
        AND hkont EQ it_skb1-saknr
        AND budat LE key_date
        AND bstat EQ space.
      IF wa_bsas-shkzg = 'H'.
        wa_bsas-dmbtr = wa_bsas-dmbtr * -1.
        wa_bsas-dmbe2 = wa_bsas-dmbe2 * -1.
        wa_bsas-dmbe3 = wa_bsas-dmbe3 * -1.
        wa_bsas-pswbt = wa_bsas-pswbt * -1.
      ENDIF.
      CLEAR it_coll.
      MOVE-CORRESPONDING wa_bsas TO it_coll.
      it_coll-koart = 'S'.
      COLLECT it_coll.
    ENDSELECT.
*** BSAS
    SELECT * FROM bsas INTO wa_bsas
      WHERE bukrs EQ p_bukrs
        AND hkont EQ it_skb1-saknr
        AND augdt GT key_date
        AND budat LE key_date
        AND bstat EQ space.
      IF wa_bsas-shkzg = 'H'.
        wa_bsas-dmbtr = wa_bsas-dmbtr * -1.
        wa_bsas-dmbe2 = wa_bsas-dmbe2 * -1.
        wa_bsas-dmbe3 = wa_bsas-dmbe3 * -1.
        wa_bsas-pswbt = wa_bsas-pswbt * -1.
      ENDIF.
      CLEAR it_coll.
      MOVE-CORRESPONDING wa_bsas TO it_coll.
      it_coll-koart = 'S'.
      COLLECT it_coll.
    ENDSELECT.
*** GLT0
    PERFORM get_glt0.
  ENDLOOP.
*** build-up DELTA
  LOOP AT it_coll.
    it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
    it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
    it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
    it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
    MODIFY it_coll.
  ENDLOOP.
*** error case: balance ne 0
  CLEAR cnt.
  LOOP AT it_coll
    WHERE ( d_dmbtr NE 0 OR
            d_dmbe2 NE 0 OR
            d_dmbe3 NE 0 OR
            d_pswbt NE 0 ).
    ADD 1 TO cnt.
    it_coll-cnt = cnt.
*** get XSALH
    CLEAR it_skb1.
    READ TABLE it_skb1 WITH KEY
      saknr = it_coll-hkont.
    it_coll-xsalh = it_skb1-xsalh.
*** write IT_CORR
    INSERT it_coll INTO TABLE it_corr.
*** change XSALH if D_DMBTR ne D_PSWBT in case of XSALH = X
    IF ( it_coll-xsalh = 'X' AND
         it_coll-d_dmbtr NE it_coll-d_pswbt ).
      CLEAR it_skb1_change.
      MOVE-CORRESPONDING it_coll TO it_skb1_change.
      COLLECT it_skb1_change.
    ENDIF.
*** check XSPEB and XLOEB for G/L account in SKB1
    IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
      READ TABLE it_skb1_change WITH KEY
        bukrs = it_skb1-bukrs
        hkont = it_skb1-saknr.
      IF sy-subrc = 0.
        save_index = sy-tabix.
        it_skb1_change-xspeb = it_skb1-xspeb.
        it_skb1_change-xloeb = it_skb1-xloeb.
        MODIFY it_skb1_change INDEX save_index.
      ELSE.
        CLEAR it_skb1_change.
        it_skb1_change-hkont = it_skb1-saknr.
        MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
        APPEND it_skb1_change.
      ENDIF.
    ENDIF.
*** check XLOEV and XSPEB for G/L account in SKA1
    CLEAR wa_ska1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM ska1 INTO wa_ska1
      WHERE ktopl = wa_t001-ktopl
        AND saknr = it_coll-hkont.  "#EC CI_DB_OPERATION_OK[2389136]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
      READ TABLE it_ska1_change WITH KEY
        ktopl = wa_ska1-ktopl
        hkont = wa_ska1-saknr.
      IF sy-subrc NE 0.
        CLEAR it_ska1_change.
        it_ska1_change-hkont = wa_ska1-saknr.
        MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
        APPEND it_ska1_change.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " COLLECT_S
*&---------------------------------------------------------------------*
*&      Form  COLLECT_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_d .
  DATA: save_index TYPE sy-tabix.
*** set KOART for GLT0 collect
  wa_koart = 'D'.
*** BSID
  SELECT * FROM bsid INTO wa_bsad
    WHERE bukrs EQ p_bukrs
      AND budat LE key_date
      AND bstat EQ space.
    IF wa_bsad-shkzg = 'H'.
      wa_bsad-dmbtr = wa_bsad-dmbtr * -1.
      wa_bsad-dmbe2 = wa_bsad-dmbe2 * -1.
      wa_bsad-dmbe3 = wa_bsad-dmbe3 * -1.
      wa_bsad-pswbt = wa_bsad-pswbt * -1.
    ENDIF.
    CLEAR it_coll.
    MOVE-CORRESPONDING wa_bsad TO it_coll.
    it_coll-koart = 'D'.
    COLLECT it_coll.
  ENDSELECT.
*** BSAD
  SELECT * FROM bsad INTO wa_bsad
    WHERE bukrs EQ p_bukrs
      AND augdt GT key_date
      AND budat LE key_date
      AND bstat EQ space.
    IF wa_bsad-shkzg = 'H'.
      wa_bsad-dmbtr = wa_bsad-dmbtr * -1.
      wa_bsad-dmbe2 = wa_bsad-dmbe2 * -1.
      wa_bsad-dmbe3 = wa_bsad-dmbe3 * -1.
      wa_bsad-pswbt = wa_bsad-pswbt * -1.
    ENDIF.
    CLEAR it_coll.
    MOVE-CORRESPONDING wa_bsad TO it_coll.
    it_coll-koart = 'D'.
    COLLECT it_coll.
  ENDSELECT.
*** get GLT0 balance
  LOOP AT it_skb1.
    PERFORM get_glt0.
  ENDLOOP.
*** build-up DELTA
  LOOP AT it_coll.
    it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
    it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
    it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
    it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
    MODIFY it_coll.
  ENDLOOP.
*** error case: balance ne 0
  CLEAR cnt.
  LOOP AT it_coll
    WHERE ( d_dmbtr NE 0 OR
            d_dmbe2 NE 0 OR
            d_dmbe3 NE 0 OR
            d_pswbt NE 0 ).
    ADD 1 TO cnt.
    it_coll-cnt = cnt.
    INSERT it_coll INTO TABLE it_corr.
    READ TABLE it_skb1 WITH KEY
      bukrs = it_coll-bukrs
      saknr = it_coll-hkont.
*** check XSPEB and XLOEB for G/L account
    IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
      READ TABLE it_skb1_change WITH KEY
        bukrs = it_skb1-bukrs
        hkont = it_skb1-saknr.
      IF sy-subrc NE 0.
        CLEAR it_skb1_change.
        it_skb1_change-hkont = it_skb1-saknr.
        MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
        APPEND it_skb1_change.
      ENDIF.
    ENDIF.
*** check XLOEV and XSPEB for G/L account in SKA1
    CLEAR wa_ska1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM ska1 INTO wa_ska1
      WHERE ktopl = wa_t001-ktopl
        AND saknr = it_coll-hkont.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
      READ TABLE it_ska1_change WITH KEY
        ktopl = wa_ska1-ktopl
        hkont = wa_ska1-saknr.
      IF sy-subrc NE 0.
        CLEAR it_ska1_change.
        it_ska1_change-hkont = wa_ska1-saknr.
        MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
        APPEND it_ska1_change.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " COLLECT_D
*&---------------------------------------------------------------------*
*&      Form  COLLECT_K
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_k .
  DATA: save_index TYPE sy-tabix.
*** set KOART for GLT0 collect
  wa_koart = 'K'.
*** BSIK
  SELECT * FROM bsik INTO wa_bsak
    WHERE bukrs EQ p_bukrs
      AND budat LE key_date
      AND bstat EQ space.
    IF wa_bsak-shkzg = 'H'.
      wa_bsak-dmbtr = wa_bsak-dmbtr * -1.
      wa_bsak-dmbe2 = wa_bsak-dmbe2 * -1.
      wa_bsak-dmbe3 = wa_bsak-dmbe3 * -1.
      wa_bsak-pswbt = wa_bsak-pswbt * -1.
    ENDIF.
    CLEAR it_coll.
    MOVE-CORRESPONDING wa_bsak TO it_coll.
    it_coll-koart = 'K'.
    COLLECT it_coll.
  ENDSELECT.
*** BSAK
  SELECT * FROM bsak INTO wa_bsak
    WHERE bukrs EQ p_bukrs
      AND augdt GT key_date
      AND budat LE key_date
      AND bstat EQ space.
    IF wa_bsak-shkzg = 'H'.
      wa_bsak-dmbtr = wa_bsak-dmbtr * -1.
      wa_bsak-dmbe2 = wa_bsak-dmbe2 * -1.
      wa_bsak-dmbe3 = wa_bsak-dmbe3 * -1.
      wa_bsak-pswbt = wa_bsak-pswbt * -1.
    ENDIF.
    CLEAR it_coll.
    MOVE-CORRESPONDING wa_bsak TO it_coll.
    it_coll-koart = 'K'.
    COLLECT it_coll.
  ENDSELECT.
*** get GLT0
  LOOP AT it_skb1.
    PERFORM get_glt0.
  ENDLOOP.
*** build-up DELTA
  LOOP AT it_coll.
    it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
    it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
    it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
    it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
    MODIFY it_coll.
  ENDLOOP.
*** error case: balance ne 0
  CLEAR cnt.
  LOOP AT it_coll
    WHERE ( d_dmbtr NE 0 OR
            d_dmbe2 NE 0 OR
            d_dmbe3 NE 0 OR
            d_pswbt NE 0 ).
    ADD 1 TO cnt.
    it_coll-cnt = cnt.
    INSERT it_coll INTO TABLE it_corr.
    READ TABLE it_skb1 WITH KEY
      bukrs = it_coll-bukrs
      saknr = it_coll-hkont.
*** check XSPEB and XLOEB for G/L account
    IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
      READ TABLE it_skb1_change WITH KEY
        bukrs = it_skb1-bukrs
        hkont = it_skb1-saknr.
      IF sy-subrc NE 0.
        CLEAR it_skb1_change.
        it_skb1_change-hkont = it_skb1-saknr.
        MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
        APPEND it_skb1_change.
      ENDIF.
    ENDIF.
*** check XLOEV and XSPEB for G/L account in SKA1
    CLEAR wa_ska1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM ska1 INTO wa_ska1
      WHERE ktopl = wa_t001-ktopl
        AND saknr = it_coll-hkont.  "#EC CI_DB_OPERATION_OK[2389136]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
      READ TABLE it_ska1_change WITH KEY
        ktopl = wa_ska1-ktopl
        hkont = wa_ska1-saknr.
      IF sy-subrc NE 0.
        CLEAR it_ska1_change.
        it_ska1_change-hkont = wa_ska1-saknr.
        MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
        APPEND it_ska1_change.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " COLLECT_K
*&---------------------------------------------------------------------*
*&      Form  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM output .
  NEW-PAGE.
  head = 'C'.
  LOOP AT it_corr.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
        (5) it_corr-bukrs,
        (5) it_corr-koart,
       (10) it_corr-hkont,
        (5) it_corr-gsber,
        (5) it_corr-pswsl,
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_corr-d_dmbtr,
       (15) it_corr-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_corr-d_dmbe2,
       (15) it_corr-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_corr-d_dmbe3,
       (15) it_corr-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_corr-d_pswbt,
       (15) it_corr-d_pswbt, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
       (10) it_corr-cnt,
        130 sy-vline NO-GAP.
  ENDLOOP.
  NEW-LINE.
  ULINE (130).
*** summarization level 1: eliminate GSBER
  NEW-PAGE.
  head = '1'.
  LOOP AT it_corr.
    CLEAR it_sum1.
    MOVE-CORRESPONDING it_corr TO it_sum1.
    COLLECT it_sum1.
  ENDLOOP.
  LOOP AT it_sum1.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
        (5) it_sum1-bukrs,
        (5) it_sum1-koart,
       (10) it_sum1-hkont,
        (5) '*****',
        (5) it_sum1-pswsl,
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum1-d_dmbtr,
       (15) it_sum1-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum1-d_dmbe2,
       (15) it_sum1-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum1-d_dmbe3,
       (15) it_sum1-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum1-d_pswbt,
       (15) it_sum1-d_pswbt, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
        130 sy-vline NO-GAP.
  ENDLOOP.
  NEW-LINE.
  ULINE (130).
*** summarization level 2: eliminate PSWSL
  NEW-PAGE.
  head = '2'.
  LOOP AT it_corr.
    CLEAR it_sum2.
    MOVE-CORRESPONDING it_corr TO it_sum2.
    COLLECT it_sum2.
  ENDLOOP.
  LOOP AT it_sum2.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
        (5) it_sum2-bukrs,
        (5) it_sum2-koart,
       (10) it_sum2-hkont,
        (5) it_sum2-gsber,
        (5) '*****',
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum2-d_dmbtr,
       (15) it_sum2-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum2-d_dmbe2,
       (15) it_sum2-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum2-d_dmbe3,
       (15) it_sum2-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
       (15) '***************',
        130 sy-vline NO-GAP.
  ENDLOOP.
  NEW-LINE.
  ULINE (130).
*** summarization level 3: eliminate GSBER and PSWSL
  NEW-PAGE.
  head = '3'.
  LOOP AT it_corr.
    CLEAR it_sum3.
    MOVE-CORRESPONDING it_corr TO it_sum3.
    COLLECT it_sum3.
  ENDLOOP.
  LOOP AT it_sum3.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
        (5) it_sum3-bukrs,
        (5) it_sum3-koart,
       (10) it_sum3-hkont,
        (5) '*****',
        (5) '*****',
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum3-d_dmbtr,
       (15) it_sum3-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum3-d_dmbe2,
       (15) it_sum3-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
*        (15) it_sum3-d_dmbe3,
       (15) it_sum3-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
       (15) '***************',
        130 sy-vline NO-GAP.
  ENDLOOP.
  NEW-LINE.
  ULINE (130).
*** output IT_SKB1_change
  DESCRIBE TABLE it_skb1_change LINES sy-tfill.
  IF sy-tfill > 0.
    NEW-PAGE.
    head = '4'.
    LOOP AT it_skb1_change.
      FORMAT COLOR 2 INTENSIFIED OFF.
      WRITE:/ sy-vline NO-GAP,
          (5) it_skb1_change-bukrs,
         (10) it_skb1_change-hkont,
          (5) it_skb1_change-xsalh,
          130 sy-vline NO-GAP.
    ENDLOOP.
    NEW-LINE.
    ULINE (130).
  ENDIF.
*** write entries to rfdt
  IF wr_rfdt = 'X' AND c_single EQ space.
    PERFORM write_to_db.
  ENDIF.
ENDFORM.                    " OUTPUT
*&---------------------------------------------------------------------*
*&      Form  TOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top .
  CASE head.
    WHEN 'C'.
      FORMAT COLOR 1.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'Differences in totals of open items vs. account balance:',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'BUKRS',
          (5) 'KOART',
         (10) 'HKONT',
          (5) 'GSBER',
          (5) 'PSWSL',
         (15) 'delta DMBTR',
         (15) 'delta DMBE2',
         (15) 'delta DMBE3',
         (15) 'delta PSWBT',
         (10) 'COUNTER',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
      FORMAT COLOR OFF.
    WHEN '1'.
      FORMAT COLOR 3.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'Summarization level 1: GSBER',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'BUKRS',
          (5) 'KOART',
         (10) 'HKONT',
          (5) 'GSBER',
          (5) 'PSWSL',
         (15) 'delta DMBTR',
         (15) 'delta DMBE2',
         (15) 'delta DMBE3',
         (15) 'delta PSWBT',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
      FORMAT COLOR OFF.
    WHEN '2'.
      FORMAT COLOR 3.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'Summarization level 2: PSWSL',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'BUKRS',
          (5) 'KOART',
         (10) 'HKONT',
          (5) 'GSBER',
          (5) 'PSWSL',
         (15) 'delta DMBTR',
         (15) 'delta DMBE2',
         (15) 'delta DMBE3',
         (15) 'delta PSWBT',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
      FORMAT COLOR OFF.
    WHEN '3'.
      FORMAT COLOR 3.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'Summarization level 3: PSWSL and GSBER',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'BUKRS',
          (5) 'KOART',
         (10) 'HKONT',
          (5) 'GSBER',
          (5) 'PSWSL',
         (15) 'delta DMBTR',
         (15) 'delta DMBE2',
         (15) 'delta DMBE3',
         (15) 'delta PSWBT',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
      FORMAT COLOR OFF.
    WHEN '4'.
      FORMAT COLOR 6.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'G/L accounts for which XSALH needs to be deactivated:',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'BUKRS',
         (10) 'HKONT',
          (5) 'XSALH',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
      FORMAT COLOR OFF.
    WHEN 'L'.
      FORMAT COLOR 1.
      ULINE (130).
      WRITE:/ sy-vline NO-GAP,
              'Involved GLT0 ledgers and currencies:',
          130 sy-vline NO-GAP.
      WRITE:/ sy-vline NO-GAP,
          (5) 'RLDNR',
          (5) 'CURno',
          (5) 'CURTP',
          (5) 'CURT1',
          (5) 'CURT2',
          (5) 'CURT3',
          (5) 'FG_1',
          (5) 'FG_2',
          (5) 'FG_3',
          130 sy-vline NO-GAP.
      NEW-LINE.
      ULINE (130).
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " TOP
*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_to_db .
  DATA: x_acct(1) TYPE c.

  CLEAR x_acct.
  IF koart_s = 'X'.
    x_acct = 'S'.
  ELSEIF koart_d = 'X'.
    x_acct = 'D'.
  ELSEIF koart_k = 'X'.
    x_acct = 'K'.
  ENDIF.
  CONCATENATE 'KOART_' x_acct INTO rfdt_key-key1.
  rfdt_key-date = sy-datlo.
  rfdt_key-time = sy-timlo.
  EXPORT
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
*    it_corr
    it_corr "#EC CI_FLDEXT_OK[2610650]
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
    it_skb1_corr
    it_skb1_change
    it_ska1_change
  TO DATABASE rfdt(eu) ID rfdt_key.
  IF sy-subrc = 0.
    CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO exp_key.
    SKIP 2.
    NEW-LINE.
    ULINE (50).
    FORMAT COLOR 3.
    WRITE:/ sy-vline NO-GAP,
            'TABLE RFDT EXPORT FILE KEY:',
         50 sy-vline NO-GAP.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
            exp_key,
         50 sy-vline NO-GAP.
    NEW-LINE.
    ULINE (50).
    FORMAT COLOR 2 INTENSIFIED ON.
  ENDIF.
ENDFORM.                    " WRITE_TO_DB
*&---------------------------------------------------------------------*
*&      Form  GET_GLT0
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_glt0 .
  DATA: lt_glt0 TYPE TABLE OF glt0 WITH HEADER LINE,
        ls_pswbt TYPE bseg-pswbt,
        ls_dmbtr TYPE bseg-dmbtr,
        ls_dmbe2 TYPE bseg-dmbe2,
        ls_dmbe3 TYPE bseg-dmbe3.

*** process ledger '00': TSL, HSL
  READ TABLE it_ldglt0 WITH KEY
    rldnr = '00'.
*** TSL and HSL in ledger '00' are always involved
  REFRESH lt_glt0.
  SELECT * FROM glt0 INTO TABLE lt_glt0
    WHERE rrcty = '0'
      AND rvers = '001'
      AND bukrs = p_bukrs
      AND ryear = p_year
      AND racct = it_skb1-saknr.
*** check PSWBT and DMBTR
  LOOP AT lt_glt0
    WHERE rldnr = '00'.
*** build-up IT_COLL from GLT0
    CLEAR it_coll.
    it_coll-bukrs = lt_glt0-bukrs.
    it_coll-koart = wa_koart.
    it_coll-hkont = lt_glt0-racct.
    it_coll-gsber = lt_glt0-rbusa.
    it_coll-pswsl = lt_glt0-rtcur.
    MOVE lt_glt0-tslvt TO it_coll-tsl.
    MOVE lt_glt0-hslvt TO it_coll-hsl.
    COLLECT it_coll.
  ENDLOOP.
*** optional: check DMBE2
  CLEAR it_ldglt0.
  READ TABLE it_ldglt0 WITH KEY
    curr = '2'.
  IF sy-subrc = 0.
    CLEAR: ls_dmbe2.
    LOOP AT lt_glt0
      WHERE rldnr = it_ldglt0-rldnr.
*** build-up IT_COLL from GLT0
      CLEAR it_coll.
      it_coll-bukrs = lt_glt0-bukrs.
      it_coll-koart = wa_koart.
      it_coll-hkont = lt_glt0-racct.
      it_coll-gsber = lt_glt0-rbusa.
      it_coll-pswsl = lt_glt0-rtcur.
      IF it_ldglt0-curtp = it_ldglt0-curt1.
        IF it_ldglt0-fg_curt1 = 'KSL'.
          MOVE lt_glt0-kslvt TO it_coll-ksl.
        ELSEIF it_ldglt0-fg_curt1 = 'HSL'.
          MOVE lt_glt0-hslvt TO it_coll-ksl.
        ENDIF.
      ELSEIF it_ldglt0-curtp = it_ldglt0-curt2.
        IF it_ldglt0-fg_curt2 = 'KSL'.
          MOVE lt_glt0-kslvt TO it_coll-ksl.
        ELSEIF it_ldglt0-fg_curt2 = 'HSL'.
          MOVE lt_glt0-hslvt TO it_coll-ksl.
        ENDIF.
      ENDIF.
      COLLECT it_coll.
    ENDLOOP.
  ENDIF.
*** optional: check DMBE3
  CLEAR it_ldglt0.
  READ TABLE it_ldglt0 WITH KEY
    curr = '3'.
  IF sy-subrc = 0.
    LOOP AT lt_glt0
      WHERE rldnr = it_ldglt0-rldnr.
*** build-up IT_COLL from GLT0
      CLEAR it_coll.
      it_coll-bukrs = lt_glt0-bukrs.
      it_coll-koart = wa_koart.
      it_coll-hkont = lt_glt0-racct.
      it_coll-gsber = lt_glt0-rbusa.
      it_coll-pswsl = lt_glt0-rtcur.
      IF it_ldglt0-curtp = it_ldglt0-curt1.
        IF it_ldglt0-fg_curt1 = 'KSL'.
          MOVE lt_glt0-kslvt TO it_coll-osl.
        ELSEIF it_ldglt0-fg_curt1 = 'HSL'.
          MOVE lt_glt0-hslvt TO it_coll-osl.
        ENDIF.
      ELSEIF it_ldglt0-curtp = it_ldglt0-curt2.
        IF it_ldglt0-fg_curt2 = 'KSL'.
          MOVE lt_glt0-kslvt TO  it_coll-osl.
        ELSEIF it_ldglt0-fg_curt2 = 'HSL'.
          MOVE lt_glt0-hslvt TO  it_coll-osl.
        ENDIF.
      ENDIF.
      COLLECT it_coll.
    ENDLOOP.
  ENDIF.
ENDFORM.                                                    " GET_GLT0
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_LEDGERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM output_ledgers .
  NEW-PAGE.
  head = 'L'.

  LOOP AT it_ldglt0.
    FORMAT COLOR 2 INTENSIFIED OFF.
    WRITE:/ sy-vline NO-GAP,
        (5) it_ldglt0-rldnr,
        (5) it_ldglt0-curr,
        (5) it_ldglt0-curtp,
        (5) it_ldglt0-curt1,
        (5) it_ldglt0-curt2,
        (5) it_ldglt0-curt3,
        (5) it_ldglt0-fg_curt1,
        (5) it_ldglt0-fg_curt2,
        (5) it_ldglt0-fg_curt3,
        130 sy-vline NO-GAP.
  ENDLOOP.
  NEW-LINE.
  ULINE (130).
ENDFORM.                    " OUTPUT_LEDGERS
*&---------------------------------------------------------------------*
*&      Form  SELECT_SKB1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_skb1 .
  DATA: it_t074 TYPE TABLE OF t074 WITH HEADER LINE.
*** KOART S
  IF koart_s = 'X'.
*** check all OI managed G/L accounts
    IF c_single EQ space.
*** only open item managed accounts
      REFRESH it_skb1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
      SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
        WHERE bukrs EQ p_bukrs
          AND xkres EQ 'X'
          AND xopvw EQ 'X'.
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    ELSE.
*** check single G/L account
      IF p_hkont EQ space.
        WRITE:/ 'HKONT required!' COLOR 6.
        EXIT.
      ENDIF.
*** only open item managed account
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
      SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
        WHERE bukrs EQ p_bukrs
          AND saknr EQ p_hkont
          AND xkres EQ 'X'
          AND xopvw EQ 'X'.
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
      DESCRIBE TABLE it_skb1 LINES sy-tfill.
      IF sy-tfill = 0.
        WRITE:/ 'No G/L account selected' COLOR 6.
        EXIT.
      ENDIF.
    ENDIF.
*** store IT_SKB1_CORR
    APPEND LINES OF it_skb1 TO it_skb1_corr.
  ENDIF.
*** KOART D
  IF koart_d = 'X'.
    REFRESH it_skb1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
    SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
      WHERE bukrs EQ p_bukrs
        AND mitkz EQ 'D'.
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    LOOP AT it_skb1.
*** check if special G/L account
      REFRESH it_t074.
      SELECT * FROM t074 INTO TABLE it_t074
        WHERE ktopl = wa_t001-ktopl
          AND koart = 'D'
          AND skont = it_skb1-saknr.
      DESCRIBE TABLE it_t074 LINES sy-tfill.
*** no special G/L
      IF sy-tfill = 0.
        CONTINUE.
*** special G/L for single UMSKZ
      ELSEIF sy-tfill = 1.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        it_skb1-umskz = it_t074-umskz.
        MODIFY it_skb1.
*** special G/L for multiple UMSKZ
      ELSE.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        it_skb1-umskz = it_t074-umskz.
        it_skb1-mult_umskz = 'X'.
        MODIFY it_skb1.
      ENDIF.
    ENDLOOP.
*** store IT_SKB1_CORR
    APPEND LINES OF it_skb1 TO it_skb1_corr.
  ENDIF.
*** KOART K
  IF koart_k = 'X'.
    REFRESH it_skb1.
" " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
    SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
      WHERE bukrs EQ p_bukrs
        AND mitkz EQ 'K'.
" " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
    LOOP AT it_skb1.
*** check if special G/L account
      REFRESH it_t074.
      SELECT * FROM t074 INTO TABLE it_t074
        WHERE ktopl = wa_t001-ktopl
          AND koart = 'K'
          AND skont = it_skb1-saknr.
      DESCRIBE TABLE it_t074 LINES sy-tfill.
*** no special G/L
      IF sy-tfill = 0.
        CONTINUE.
*** special G/L for single UMSKZ
      ELSEIF sy-tfill = 1.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        it_skb1-umskz = it_t074-umskz.
        MODIFY it_skb1.
*** special G/L for multiple UMSKZ
      ELSE.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
        it_skb1-umskz = it_t074-umskz.
        it_skb1-mult_umskz = 'X'.
        MODIFY it_skb1.
      ENDIF.
    ENDLOOP.
*** store IT_SKB1_CORR
    APPEND LINES OF it_skb1 TO it_skb1_corr.
  ENDIF.
ENDFORM.                    " SELECT_SKB1
*&---------------------------------------------------------------------*
*&      Form  SET_KEYDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_keydate .
*** create KEY_DATE
  CLEAR key_date.
  CLEAR wa_fday.
  CALL FUNCTION 'PERIOD_DAY_DETERMINE'
    EXPORTING
      i_gjahr                    = p_year
      i_monat                    = '01'
      i_periv                    = wa_t001-periv
    IMPORTING
      e_fday                     = wa_fday
*   E_LDAY                     =
*   E_SPERIOD                  =
* EXCEPTIONS
*   ERROR_PERIOD               = 1
*   ERROR_PERIOD_VERSION       = 2
*   FIRSTDAY_NOT_DEFINED       = 3
*   PERIOD_NOT_DEFINED         = 4
*   YEAR_INVALID               = 5
*   OTHERS                     = 6
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*** KEY_DATE
  key_date = wa_fday - 1.
ENDFORM.                    " SET_KEYDATE
*&---------------------------------------------------------------------*
*&      Form  GET_LEDGERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_ledgers .
  SELECT SINGLE * FROM t001a INTO wa_t001a
    WHERE bukrs = p_bukrs.
  IF sy-subrc = 0.
*** LC2 active?
    IF wa_t001a-curtp NE space.
      REFRESH it_ledtab.
      CALL FUNCTION 'G_GIVE_LEDGERS_FOR_GLT0'
        EXPORTING
          bukrs                          = wa_t001a-bukrs
          curtp                          = wa_t001a-curtp
*   JOIN_OF_VALUTYP_AND_CURT       = 'X'
        TABLES
          ledtab                         = it_ledtab
                .
      READ TABLE it_ledtab INDEX 1.
      CLEAR it_ldglt0.
      MOVE-CORRESPONDING it_ledtab TO it_ldglt0.
      it_ldglt0-curtp = wa_t001a-curtp.
      it_ldglt0-curr = '2'.
      INSERT it_ldglt0 INTO TABLE it_ldglt0.
    ENDIF.
*** LC3 active?
    IF wa_t001a-curtp2 NE space.
      REFRESH it_ledtab.
      CALL FUNCTION 'G_GIVE_LEDGERS_FOR_GLT0'
        EXPORTING
          bukrs                          = wa_t001a-bukrs
          curtp                          = wa_t001a-curtp2
*   JOIN_OF_VALUTYP_AND_CURT       = 'X'
        TABLES
          ledtab                         = it_ledtab
                .
      READ TABLE it_ledtab INDEX 1.
      CLEAR it_ldglt0.
      MOVE-CORRESPONDING it_ledtab TO it_ldglt0.
      it_ldglt0-curtp = wa_t001a-curtp2.
      it_ldglt0-curr = '3'.
      INSERT it_ldglt0 INTO TABLE it_ldglt0.
    ENDIF.
*** no parallel currencies defined
  ELSE.
    CLEAR it_ldglt0.
    it_ldglt0-rldnr = '00'.
    it_ldglt0-curtp = '10'.
    it_ldglt0-curr = '1'.
    INSERT it_ldglt0 INTO TABLE it_ldglt0.
  ENDIF.
*** get update fields for ledgers
  LOOP AT it_ldglt0.
    CALL FUNCTION 'G_GET_ORGANIZATIONAL_DATA'
      EXPORTING
        i_rldnr                        = it_ldglt0-rldnr
        i_orgunit                      = p_bukrs
*     JOIN_OF_VALUTYP_AND_CURT       = 'X'
*     SEND_ERROR_WHEN_DEPLD          = ' '
      IMPORTING
        organizational_info            = it_org_info
*   EXCEPTIONS
*     NO_INFO_FOUND                  = 1
*     ERROR_IN_SETUP                 = 2
*     ERROR_IN_DEPLD                 = 3
*     OTHERS                         = 4
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    READ TABLE it_org_info INDEX 1.
    MOVE-CORRESPONDING it_org_info TO it_ldglt0.
    MODIFY it_ldglt0.
  ENDLOOP.

ENDFORM.                    " GET_LEDGERS
