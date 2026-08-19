*&---------------------------------------------------------------------*
*& Report  ZF_RESET_CLR
*&
*&---------------------------------------------------------------------*
*& The report will allow to reset clearings without balance-0-check.
*& Ranges of clearing documents per account type are possible. It is
*& NOT possible to run the report without entering at least one AUGBL
*& to avoid an unwanted reset of ALL clearings for an account type!
*& In update mode a change document is written for each reset line.
*&
*& If the clearing document had BSTAT 'A' this would be automatically
*& changed to 'B' in update mode.
*& 'ALE-extern' is excluded as AUGBL.
*&
*& Duplicate clearings: If one item is cleared with a different clea-
*& ring information in BSEG only the index is deleted, BSEG is kept.
*&
*& As of version 2 it is also possible to handle reversals that will
*& be automatically reset once the respective flag is set on the
*& selection screen.
*&
*& As of version 3 the report will detect exchange rate differences
*& items in the clearing documents that require a reversal in the
*& original period. The respective keys are submitted to the report
*& SAPF080 for automatic reversal.
*&
*& As of version 5 ledgergroup-specific clearing is added for releases
*& as of EHP6.03 .
*&---------------------------------------------------------------------*
*& Change log:
*& UD280411 - reset reversal added
*& UD050913 - in presence of KDF lines the report will automatically
*&            reverse the reset clearing document via SAPF080
*& UD200416 - allow to suppress reversal by special flag
*& UD281016 - legdergroup-specific clearings processing added
*&          - reversal with different period is allowed, too
*&---------------------------------------------------------------------*
*& Version 5
*&---------------------------------------------------------------------*
*& Report in Q3A
*& Author: D033001
*&---------------------------------------------------------------------*

REPORT zf_reset_clr LINE-SIZE 150 NO STANDARD PAGE HEADING.

TABLES: bseg, bkpf, t001, bsis, bsas, bsik, bsak, bsid, bsad.
*** cleared items
TYPES: BEGIN OF index,
       bukrs TYPE bseg-bukrs,
       augdt TYPE bseg-augdt,
       augbl TYPE bseg-augbl,
       auggj TYPE bseg-auggj,
       zuonr TYPE bseg-zuonr,                               "UD281016
       belnr TYPE bseg-belnr,
       gjahr TYPE bseg-gjahr,
       buzei TYPE bseg-buzei,
       xarch TYPE bsis-xarch,
       koart TYPE bseg-koart,
       konto TYPE bseg-hkont,
       xhres TYPE bseg-xhres,
       recon TYPE bseg-hkont,
       xlgclr TYPE c,                                       "UD281016
       bstat  TYPE c,                                       "UD281016
       END OF index.
DATA: gt_index TYPE TABLE OF index WITH HEADER LINE.
DATA: expert TYPE c.
DATA: exp_arc TYPE c.
DATA: x_koart TYPE c.
*** data for change documents
TYPES: BEGIN OF bsegr.
        INCLUDE STRUCTURE fbsegr.
TYPES: END OF bsegr.
DATA: gt_xbsegr TYPE TABLE OF bsegr WITH HEADER LINE.
DATA: gt_ybsegr TYPE TABLE OF bsegr WITH HEADER LINE.
DATA: upd_bsegr               TYPE c.
DATA: objectid                TYPE cdhdr-objectid.
DATA: tcode                   TYPE cdhdr-tcode.
DATA: planned_change_number   TYPE cdhdr-planchngnr.
DATA: utime                   TYPE cdhdr-utime.
DATA: udate                   TYPE cdhdr-udate.
DATA: username                TYPE cdhdr-username.
DATA: cdoc_planned_or_real    TYPE cdhdr-change_ind.
DATA: cdoc_upd_object         TYPE cdhdr-change_ind VALUE 'U'.
DATA: cdoc_no_change_pointers TYPE cdhdr-change_ind.
*** data for clearing key
TYPES: BEGIN OF key,
       bukrs    TYPE bseg-bukrs,
       augdt    TYPE bseg-augdt,
       augbl    TYPE bseg-augbl,
       auggj    TYPE bseg-auggj,
       revdate  TYPE bkpf-budat,                            "UD281016
       cnt_netb TYPE i,
       cnt_arch TYPE i,
       cl_bstat TYPE i,
       reverse  TYPE i,                                     "UD280411
       kdf      TYPE i,                                     "UD050913
       xlgclr   TYPE i,                                     "UD281016
       END OF key.
*DATA: gt_key TYPE SORTED TABLE OF KEY WITH HEADER LINE     "UD281016
*      WITH UNIQUE KEY bukrs augdt augbl auggj.             "UD281016
DATA: gt_key TYPE TABLE OF KEY WITH HEADER LINE.            "UD281016
DATA: count_clr TYPE i.
*DATA: gt_key_excl TYPE SORTED TABLE OF KEY WITH HEADER LINE"UD281016
*      WITH UNIQUE KEY bukrs augdt augbl auggj.             "UD281016
DATA: gt_key_excl TYPE TABLE OF KEY WITH HEADER LINE.       "UD281016
DATA: cnt_excl TYPE i.
*** message handling
TYPES: BEGIN OF message,
       bukrs     TYPE bkpf-bukrs,
       belnr     TYPE bkpf-belnr,
       gjahr     TYPE bkpf-gjahr,
       buzei     TYPE bseg-buzei,
       bvorg     TYPE bkpf-bvorg,
*** type 0: update, 1: E, 2: W, 3: I
       type      TYPE i,
       class(10) TYPE c,
       msg(90)   TYPE c,
       END OF message.
DATA: gt_mess TYPE TABLE OF message WITH HEADER LINE.
*** drill-down
DATA: d_bukrs TYPE bkpf-bukrs.
DATA: d_belnr TYPE bkpf-belnr.
DATA: d_gjahr TYPE bkpf-gjahr.
*** reversal processing: header information                 "UD280411
TYPES: BEGIN OF rev_key,                                    "UD280411
       bukrs   TYPE bkpf-bukrs,                             "UD280411
       belnr_2 TYPE bkpf-belnr,                             "UD280411
       gjahr_2 TYPE bkpf-gjahr,                             "UD280411
       belnr_1 TYPE bkpf-belnr,                             "UD280411
       gjahr_1 TYPE bkpf-gjahr,                             "UD280411
       END OF rev_key.                                      "UD280411
DATA: gt_rev_key TYPE SORTED TABLE OF rev_key WITH HEADER LINE"UD2804
      WITH UNIQUE KEY bukrs belnr_2 gjahr_2.                "UD280411
DATA: gt_bkpf_rev TYPE TABLE OF bkpf WITH HEADER LINE.      "UD280411


SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE text_001.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(24) text_013 FOR FIELD p_bukrs.
SELECTION-SCREEN POSITION 27.
PARAMETERS:      p_bukrs TYPE bseg-bukrs OBLIGATORY.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE text_002.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS: p_gl RADIOBUTTON GROUP 001 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(60) text_010 FOR FIELD p_gl.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS: p_cust RADIOBUTTON GROUP 001.
SELECTION-SCREEN COMMENT 3(60) text_011 FOR FIELD p_cust.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 1.
PARAMETERS: p_vend RADIOBUTTON GROUP 001.
SELECTION-SCREEN COMMENT 3(60) text_012 FOR FIELD p_vend.
SELECTION-SCREEN END OF LINE.

*************************************************************UD281016
*** add selection for ledger-specific clearing processes    "UD281016
SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
SELECTION-SCREEN POSITION 1.                                "UD281016
PARAMETERS: p_xlgclr RADIOBUTTON GROUP 001.                 "UD281016
SELECTION-SCREEN COMMENT 3(60) text_021 FOR FIELD p_xlgclr. "UD281016
SELECTION-SCREEN END OF LINE.                               "UD281016
*************************************************************UD281016

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(19) text_016 FOR FIELD s_konto.
SELECTION-SCREEN POSITION 22.
SELECT-OPTIONS:  s_konto FOR bseg-hkont.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK 002.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE text_003.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(19) text_014 FOR FIELD s_augbl.
SELECTION-SCREEN POSITION 22.
SELECT-OPTIONS:  s_augbl FOR bseg-augbl.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(19) text_015 FOR FIELD s_augdt.
SELECTION-SCREEN POSITION 22.
SELECT-OPTIONS:  s_augdt FOR bseg-augdt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK 003.

*************************************************************UD050913
SELECTION-SCREEN SKIP.                                      "UD050913
SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE text_004."UD050
                                                            "UD050913
SELECTION-SCREEN BEGIN OF LINE.                             "UD050913
SELECTION-SCREEN COMMENT 1(23) text_020 FOR FIELD p_stgrd.  "UD050913
SELECTION-SCREEN POSITION 25.                               "UD050913
PARAMETERS: p_stgrd TYPE bkpf-stgrd.                        "UD050913
SELECTION-SCREEN END OF LINE.                               "UD050913
                                                            "UD050913
*************************************************************UD281016
*** allow different reversal date                           "UD281016
SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
SELECTION-SCREEN COMMENT 1(23) text_023 FOR FIELD newdate.  "UD281016
SELECTION-SCREEN POSITION 25.                               "UD281016
PARAMETERS: newdate AS CHECKBOX.                            "UD281016
SELECTION-SCREEN END OF LINE.                               "UD281016
                                                            "UD281016
SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
SELECTION-SCREEN COMMENT 1(23) text_024 FOR FIELD revdate.  "UD281016
SELECTION-SCREEN POSITION 25.                               "UD281016
PARAMETERS: revdate TYPE bkpf-budat.                        "UD281016
SELECTION-SCREEN END OF LINE.                               "UD281016
                                                            "UD281016
*************************************************************UD281016
SELECTION-SCREEN END OF BLOCK 004.                          "UD050913
*************************************************************UD050913

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(18) text_018 FOR FIELD ign_arch
                                        MODIF ID arc.
SELECTION-SCREEN POSITION 27.
PARAMETERS: ign_arch AS CHECKBOX MODIF ID arc.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.                             "UD280411
SELECTION-SCREEN COMMENT 2(18) text_019 FOR FIELD x_revers. "UD280411
SELECTION-SCREEN POSITION 27.                               "UD280411
PARAMETERS:      x_revers AS CHECKBOX.                      "UD280411
SELECTION-SCREEN END OF LINE.                               "UD280411

*************************************************************UD200416
*** allow reset clearing without reversal                   "UD200416
SELECTION-SCREEN BEGIN OF LINE.                             "UD200416
SELECTION-SCREEN COMMENT 2(18) text_022 FOR FIELD no_rev.   "UD200416
SELECTION-SCREEN POSITION 27.                               "UD200416
PARAMETERS: no_rev AS CHECKBOX.                             "UD200416
SELECTION-SCREEN END OF LINE.                               "UD200416
*************************************************************UD200416

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(18) text_017 FOR FIELD update.
SELECTION-SCREEN POSITION 27.
PARAMETERS: update AS CHECKBOX.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK 001.

INITIALIZATION.

  text_001 = 'Clearing Document Selection'.
  text_002 = 'Account Selection'.
  text_003 = 'Clearing Details'.
  text_004 = 'Reversal Reason For Automatic Reversals'.     "UD050913
  text_010 = 'G/L Account'.
  text_011 = 'Customer Account'.
  text_012 = 'Vendor Account'.
  text_013 = 'Company Code'.
  text_014 = 'Clearing Document'.
  text_015 = 'Clearing Date'.
  text_016 = 'Account'.
  text_017 = 'Update database'.
  text_018 = 'Ignore Archiving'.
  text_019 = 'Reset Reversal'.                              "UD280411
  text_020 = 'Reversal Reason'.                             "UD050913
  text_022 = 'Suppress SAPF080'.                            "UD200416
*************************************************************UD281016
  text_021 = 'Ledgergroup-specific G/L Account (as of Release 603)'.
  text_023 = 'Different Reversal Date'.
  text_024 = 'Reversal Posting Date'.
*************************************************************UD281016

AT SELECTION-SCREEN.
  PERFORM check_input.

AT SELECTION-SCREEN OUTPUT.
  PERFORM screen.

AT LINE-SELECTION.
  SET PARAMETER ID 'BUK' FIELD d_bukrs.
  SET PARAMETER ID 'BLN' FIELD d_belnr.
  SET PARAMETER ID 'GJR' FIELD d_gjahr.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

START-OF-SELECTION.
*** verify that S_AUGBL is not initial
  PERFORM late_check_s_augbl.
*** get all involved cleared items per KOART
  IF x_koart = 'D'.
    PERFORM select_clearing_bsad.
  ENDIF.
  IF x_koart = 'K'.
    PERFORM select_clearing_bsak.
  ENDIF.
  IF x_koart EQ 'S'.
    PERFORM select_clearing_bsas.
  ENDIF.
*************************************************************UD281016
  IF x_koart EQ 'X'.                                        "UD281016
    PERFORM select_clearing_faglbsas.                       "UD281016
  ENDIF.                                                    "UD281016
*************************************************************UD281016
*** get BSTAT A headers
  PERFORM get_bstat_a.
*** identify reversals, BVORG etc.
  PERFORM check_clr_doc.
*** revise key using IGN_ARCH
  PERFORM revise_key_arch.
*** processing of cleared items
  PERFORM process_clearings.
*** output excluded cases
  PERFORM output_excl.
*** output cases to be reset
  PERFORM output.
*************************************************************UD050913
*** reverse those clearing documents containing KDF lines   "UD050913
  PERFORM reverse_reset_clr.                                "UD050913
*************************************************************UD050913

*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT
*&---------------------------------------------------------------------*
FORM check_input .

*** does BUKRS exist?
  SELECT SINGLE * FROM t001
    WHERE bukrs EQ p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e016(gu)
    WITH 'Company code' p_bukrs 'does not exist'.
  ENDIF.
*** eliminate 'ALE-extern'
  LOOP AT s_augbl
    WHERE sign EQ 'I'
      AND ( low  EQ 'ALE-EXTERN' OR
            high EQ 'ALE-EXTERN' ).
    DELETE s_augbl.
    MESSAGE i016(gu)
    WITH 'ALE-extern is not a valid clearing'.
  ENDLOOP.
*** determine KOART
  IF p_gl EQ 'X'.
    x_koart = 'S'.
*************************************************************UD281016
*** ledgergroup-specific clearing                           "UD281016
  ELSEIF p_xlgclr EQ 'X'.                                   "UD281016
*** verify that BSEG-xlgclr is existing                     "UD281016
    DATA: ls_dd03l TYPE dd03l.                              "UD281016
    SELECT SINGLE * FROM dd03l INTO ls_dd03l                "UD281016
      WHERE tabname   EQ 'BSEG'                             "UD281016
        AND fieldname EQ 'XLGCLR'.                          "UD281016
    IF NOT sy-subrc EQ 0.                                   "UD281016
      MESSAGE e016(gu)                                      "UD281016
      WITH 'Ledgergroup-specific clearing not possible'     "UD281016
           'in this release'.                               "UD281016
    ENDIF.                                                  "UD281016
    x_koart = 'X'.                                          "UD281016
*************************************************************UD281016
  ELSEIF p_cust EQ 'X'.
    x_koart = 'D'.
  ELSE.
    x_koart = 'K'.
  ENDIF.
  IF sy-ucomm EQ 'SAPONLY'. expert = 'X'. ENDIF.
  IF sy-ucomm EQ 'IGN_ARCH'. exp_arc = 'X'. ENDIF.
ENDFORM.                    " CHECK_INPUT

*&---------------------------------------------------------------------*
*&      Form  SELECT_CLEARING_BSAD
*&---------------------------------------------------------------------*
FORM select_clearing_bsad .
  DATA: ls_bsad TYPE bsad.
  DATA: ls_xhres TYPE skb1-xkres.

  SELECT * FROM bsad INTO ls_bsad
    WHERE bukrs EQ p_bukrs
      AND kunnr IN s_konto
      AND augbl IN s_augbl
      AND augdt IN s_augdt.
    CLEAR gt_index.
    MOVE-CORRESPONDING ls_bsad TO gt_index.
    gt_index-koart = 'D'.
    gt_index-konto = ls_bsad-kunnr.
*** check recon account
    gt_index-recon = ls_bsad-hkont.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE xkres FROM skb1 INTO ls_xhres
*      WHERE bukrs EQ gt_index-bukrs
*        AND saknr EQ gt_index-recon.
    SELECT SINGLE LineItemDisplayIsEnabled AS xkres
      FROM i_glaccountincompanycode
      WHERE CompanyCode = @gt_index-bukrs
        AND GLAccount   = @gt_index-recon
      INTO @ls_xhres.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc EQ 0.
      gt_index-xhres = ls_xhres.
    ENDIF.
    APPEND gt_index.
    CLEAR gt_key.
    MOVE-CORRESPONDING ls_bsad TO gt_key.
    IF ls_bsad-xarch EQ 'X'.
      gt_key-cnt_arch = 1.
    ENDIF.
    COLLECT gt_key.
  ENDSELECT.
ENDFORM.                    " SELECT_CLEARING_BSAD

*&---------------------------------------------------------------------*
*&      Form  SELECT_CLEARING_BSAK
*&---------------------------------------------------------------------*
FORM select_clearing_bsak .
  DATA: ls_bsak TYPE bsak.
  DATA: ls_netb TYPE bkpf-xnetb.
  DATA: ls_xhres TYPE skb1-xkres.

  SELECT * FROM bsak INTO ls_bsak
    WHERE bukrs EQ p_bukrs
      AND lifnr IN s_konto
      AND augbl IN s_augbl
      AND augdt IN s_augdt.
    CLEAR gt_index.
    MOVE-CORRESPONDING ls_bsak TO gt_index.
    gt_index-koart = 'K'.
    gt_index-konto = ls_bsak-lifnr.
*** check recon account
    gt_index-recon = ls_bsak-hkont.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE xkres FROM skb1 INTO ls_xhres
*      WHERE bukrs EQ gt_index-bukrs
*        AND saknr EQ gt_index-recon.
    SELECT SINGLE LineItemDisplayIsEnabled AS xkres
      FROM i_glaccountincompanycode
      WHERE CompanyCode = @gt_index-bukrs
        AND GLAccount   = @gt_index-recon
      INTO @ls_xhres.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc EQ 0.
      gt_index-xhres = ls_xhres.
    ENDIF.
    APPEND gt_index.
    CLEAR gt_key.
    MOVE-CORRESPONDING ls_bsak TO gt_key.
*** special case: XNETB
    IF ( ls_bsak-xnetb EQ 'X' OR
         ls_bsak-xzahl EQ 'X' ).
      CLEAR ls_netb.
      PERFORM select_bsas_skv USING ls_bsak
                                    ls_netb.
*** evaluate marker
      IF ls_netb EQ 'X'.
        gt_key-cnt_netb = 1.
      ENDIF.
    ENDIF.
    IF ls_bsak-xarch EQ 'X'.
      gt_key-cnt_arch = 1.
    ENDIF.
    COLLECT gt_key.
  ENDSELECT.
ENDFORM.                    " SELECT_CLEARING_BSAK

*&---------------------------------------------------------------------*
*&      Form  SELECT_CLEARING_BSAS
*&---------------------------------------------------------------------*
FORM select_clearing_bsas .
  DATA: ls_bsas TYPE bsas.

  SELECT * FROM bsas INTO ls_bsas
    WHERE bukrs EQ p_bukrs
      AND hkont IN s_konto
      AND augbl IN s_augbl
      AND augdt IN s_augdt.
    CLEAR gt_index.
    MOVE-CORRESPONDING ls_bsas TO gt_index.
    gt_index-koart = 'S'.
    gt_index-konto = ls_bsas-hkont.
    APPEND gt_index.
    CLEAR gt_key.
    MOVE-CORRESPONDING ls_bsas TO gt_key.
    IF ls_bsas-xarch EQ 'X'.
      gt_key-cnt_arch = 1.
    ENDIF.
    COLLECT gt_key.
  ENDSELECT.
ENDFORM.                    " SELECT_CLEARING_BSAS

*&---------------------------------------------------------------------*
*&      Form  SELECT_BSAS_SKV
*&---------------------------------------------------------------------*
FORM select_bsas_skv  USING ls_bsak TYPE bsak
                            ls_netb TYPE bkpf-xnetb.
  DATA: ls_bseg TYPE bseg.
  DATA: ls_bsas TYPE bsas.
  DATA: lt_t030 TYPE TABLE OF t030 WITH HEADER LINE.

  IF ls_bsak-xarch EQ space.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT * FROM bseg INTO ls_bseg
      WHERE bukrs EQ ls_bsak-bukrs
        AND belnr EQ ls_bsak-belnr
        AND gjahr EQ ls_bsak-gjahr
        AND augdt EQ ls_bsak-augdt
        AND augbl EQ ls_bsak-augbl
        AND ktosl EQ 'SKV' ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      CHECK sy-subrc EQ 0.
      SELECT SINGLE * FROM bsas INTO ls_bsas
        WHERE bukrs EQ ls_bseg-bukrs
          AND hkont EQ ls_bseg-hkont
          AND augdt EQ ls_bseg-augdt
          AND augbl EQ ls_bseg-augbl
          AND gjahr EQ ls_bseg-gjahr
          AND belnr EQ ls_bseg-belnr
          AND buzei EQ ls_bseg-buzei.  "#EC CI_NOORDER
      CLEAR gt_index.
      MOVE-CORRESPONDING ls_bsas TO gt_index.
      gt_index-koart = 'S'.
      gt_index-konto = ls_bsas-hkont.
      APPEND gt_index.
*** set flag for XNETB
      ls_netb = 'X'.
*** info message
      CLEAR gt_mess.
      MOVE-CORRESPONDING gt_index TO gt_mess.
      gt_mess-type = 3.
      gt_mess-class = 'CASH DISC'.
      CONCATENATE 'Cash discount clearing'
                  'item, automatically selected'
      INTO gt_mess-msg SEPARATED BY space.
      APPEND gt_mess.
    ENDSELECT.
*** archived cases
  ELSE.
    REFRESH lt_t030.
    SELECT * FROM t030 INTO TABLE lt_t030
      WHERE ktopl EQ t001-ktopl
        AND ktosl EQ 'SKV'.  "#EC CI_NOORDER
    LOOP AT lt_t030.
      SELECT * FROM bsas INTO ls_bsas
        WHERE bukrs EQ p_bukrs
          AND hkont EQ lt_t030-konts
          AND augbl EQ ls_bsak-augdt
          AND augdt EQ ls_bsak-augbl.
        CLEAR gt_index.
        MOVE-CORRESPONDING ls_bsas TO gt_index.
        gt_index-koart = 'S'.
        gt_index-konto = ls_bsas-hkont.
        APPEND gt_index.
*** set flag for XNETB
        ls_netb = 'X'.
*** info message
        CLEAR gt_mess.
        MOVE-CORRESPONDING gt_index TO gt_mess.
        gt_mess-type = 3.
        gt_mess-class = 'CASH DISC'.
        CONCATENATE 'Cash discount clearing'
                    'item, automatically selected'
        INTO gt_mess-msg SEPARATED BY space.
        APPEND gt_mess.
      ENDSELECT.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " SELECT_BSAS_SKV

*&---------------------------------------------------------------------*
*&      Form  PROCESS_CLEARINGS
*&---------------------------------------------------------------------*
FORM process_clearings .
*** old: YBSEGR, new: XBSEGR
  DATA: new_bseg TYPE bseg.
  DATA: old_bseg TYPE bseg.
  DATA: x_rb(1) TYPE c.
*************************************************************UD281016
*** XLGCLR cases                                            "UD281016
  DATA: x_lg TYPE c.                                        "UD281016
  DATA: table TYPE dd02l-tabname.                           "UD281016
  DATA: l_bstat TYPE c.                                     "UD281016
*************************************************************UD281016

  count_clr = LINES( gt_key ).
  CHECK count_clr GT 0.
*** processing per key
  LOOP AT gt_key.
    CLEAR: x_rb.
    LOOP AT gt_index
      WHERE augdt EQ gt_key-augdt
        AND augbl EQ gt_key-augbl
        AND auggj EQ gt_key-auggj.
*************************************************************UD281016
*** set parameters for update with XLGCLR                   "UD281016
      x_lg = gt_index-xlgclr.                               "UD281016
      l_bstat = gt_index-bstat.                             "UD281016
*** set BSTAT and table name                                "UD281016
      IF gt_index-bstat EQ 'L'.                             "UD281016
        table = 'BSEG_ADD'.                                 "UD281016
      ELSE.                                                 "UD281016
        table = 'BSEG'.                                     "UD281016
      ENDIF.                                                "UD281016
*************************************************************UD281016
*** if IGN_ARCH is set: ignore archived items
      IF ign_arch EQ 'X'.
        IF gt_index-xarch EQ 'X'.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 2.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'Archived item: no update'.
          APPEND gt_mess.
        ENDIF.
        CHECK NOT gt_index-xarch EQ 'X'.
      ENDIF.
*** select corresponding BSEG
      CLEAR: new_bseg, old_bseg.
*      SELECT SINGLE * FROM bseg INTO old_bseg              "UD281016
      SELECT SINGLE * FROM (table)                          "UD281016
      INTO CORRESPONDING FIELDS OF old_bseg                 "UD281016
        WHERE bukrs EQ gt_index-bukrs
          AND belnr EQ gt_index-belnr
          AND gjahr EQ gt_index-gjahr
          AND buzei EQ gt_index-buzei.  "#EC CI_FLDEXT_OK[2610650]
*** BSEG found                                              "UD190111
      IF sy-subrc EQ 0.                                     "UD190111
*** BSEG does contain other clearing information            "UD190111
        IF NOT ( old_bseg-augdt EQ gt_index-augdt AND       "UD190111
                 old_bseg-augbl EQ gt_index-augbl ).        "UD190111
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 2.
          gt_mess-class = 'UPDATE'.
*          gt_mess-msg = 'BSEG contains other clearing information'.
          CONCATENATE                                       "UD281016
            table 'contains other clearing information'     "UD281016
          INTO gt_mess-msg SEPARATED BY space.              "UD281016
          APPEND gt_mess.
*** delete duplicate index
*          PERFORM delete_index USING x_rb.                 "UD281016
          PERFORM delete_index USING x_rb                   "UD281016
                                     x_lg.                  "UD281016
        ELSE.                                               "UD190111
*** create new BSEG
          new_bseg = old_bseg.
          CLEAR: new_bseg-augdt, new_bseg-augcp, new_bseg-augbl,
                 new_bseg-auggj, new_bseg-agzei.
*** update BSEG
          IF update EQ 'X'.
            PERFORM update_bseg USING new_bseg
                                      old_bseg
*                                      x_rb.                "UD281016
                                      x_rb                  "UD281016
                                      table                 "UD281016
                                      x_lg.                 "UD281016
          ENDIF.
        ENDIF.                                              "UD190111
*** no BSEG found => delete index                           "UD190111
      ELSE.                                                 "UD190111
*** message handling
        CLEAR gt_mess.
        MOVE-CORRESPONDING gt_index TO gt_mess.
        gt_mess-type = 2.
        gt_mess-class = 'UPDATE'.
*        gt_mess-msg = 'BSEG not found'.                    "UD281016
        CONCATENATE                                         "UD281016
          table 'not found'                                 "UD281016
        INTO gt_mess-msg SEPARATED BY space.                "UD281016
        APPEND gt_mess.
*** delete duplicate index
*        PERFORM delete_index USING x_rb.                   "UD281016
        PERFORM delete_index USING x_rb                     "UD281016
                                   x_lg.                    "UD281016
      ENDIF.                                                "UD190111
    ENDLOOP.
*** reset reversal: update header accordingly               "UD280411
    IF gt_key-reverse GT 0.                                 "UD280411
      PERFORM update_bkpf_reversal USING x_rb.              "UD280411
    ENDIF.                                                  "UD280411
    IF update EQ 'X'.
*** check BKPF-BSTAT update
      IF gt_key-cl_bstat GT 0.
        PERFORM update_bkpf USING x_rb.
      ENDIF.
*** one commit work per key
      IF x_rb EQ 'X'.
        ROLLBACK WORK.
*** exclude KEY
        INSERT gt_key INTO TABLE gt_key_excl.
        DELETE gt_key.
*** message handling
        CLEAR gt_mess.
        MOVE-CORRESPONDING gt_key TO gt_mess.
        gt_mess-belnr = gt_key-augbl.
        gt_mess-gjahr = gt_key-auggj.
        gt_mess-type = 1.
        gt_mess-class = 'EXCLUDED'.
        CONCATENATE 'ROLLBACK WORK performed for entire'
                    'clearing because of update errors'
        INTO gt_mess-msg SEPARATED BY space.
        APPEND gt_mess.
      ELSE.
        COMMIT WORK.
*** message handling
        CLEAR gt_mess.
        MOVE-CORRESPONDING gt_key TO gt_mess.
        gt_mess-belnr = gt_key-augbl.
        gt_mess-gjahr = gt_key-auggj.
        gt_mess-type = 3.
        gt_mess-class = 'CLEARING'.
        gt_mess-msg = 'COMMIT WORK performed'.
        APPEND gt_mess.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PROCESS_CLEARINGS

*&---------------------------------------------------------------------*
*&      Form  SCREEN
*&---------------------------------------------------------------------*
FORM screen .

  IF sy-batch IS INITIAL.
    CLEAR update.
  ENDIF.
  LOOP AT SCREEN.
    IF screen-group1 = 'INC'.
      IF expert = 'X'.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'ARC'.
      IF exp_arc = 'X'.
        screen-invisible = 0.
        screen-active = 1.
      ELSE.
        screen-invisible = 1.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SCREEN

*&---------------------------------------------------------------------*
*&      Form  REVISE_KEY_ARCH
*&---------------------------------------------------------------------*
FORM revise_key_arch .

*** if flag is not set then clearings containing archived items are
*** excluded from processing
  CHECK ign_arch EQ space.
  LOOP AT gt_key
    WHERE cnt_arch GT 0.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_key TO gt_mess.
    gt_mess-belnr = gt_key-augbl.
    gt_mess-gjahr = gt_key-auggj.
    gt_mess-type = 1.
    gt_mess-class = 'EXCLUDED'.
    gt_mess-msg = 'Clearing contains archived items'.
    APPEND gt_mess.
    INSERT gt_key INTO TABLE gt_key_excl.
    DELETE gt_key.
  ENDLOOP.
ENDFORM.                    " REVISE_KEY_ARCH

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BSEG
*----------------------------------------------------------------------*
FORM update_bseg  USING    new_bseg TYPE bseg
                           old_bseg TYPE bseg
*                           x_rb     TYPE c   .             "UD281016
                           x_rb     TYPE c                  "UD281016
                           tab      TYPE dd02l-tabname      "UD281016
                           x_lg     TYPE c.                 "UD281016

*** write BSEG changes to DB
*  UPDATE bseg                                              "UD281016
  UPDATE (tab)                                              "UD281016
  SET   augdt = new_bseg-augdt
        augcp = new_bseg-augcp
        augbl = new_bseg-augbl
        auggj = new_bseg-auggj
        agzei = new_bseg-agzei
  WHERE bukrs = new_bseg-bukrs
  AND   belnr = new_bseg-belnr
  AND   gjahr = new_bseg-gjahr
  AND   buzei = new_bseg-buzei.
  IF sy-subrc NE 0.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING new_bseg TO gt_mess.
    gt_mess-type = 1.
    gt_mess-class = 'UPDATE'.
*    gt_mess-msg = 'BSEG update failed'.                    "UD281016
    CONCATENATE                                             "UD281016
      tab 'update failed'                                   "UD281016
    INTO gt_mess-msg SEPARATED BY space.                    "UD281016
    APPEND gt_mess.
*** rollback indicator
    x_rb = 'X'.
  ELSE.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING new_bseg TO gt_mess.
    gt_mess-type = 3.
    gt_mess-class = 'UPDATE'.
*    gt_mess-msg = 'BSEG updated'.                          "UD281016
    CONCATENATE                                             "UD281016
      tab 'updated'                                         "UD281016
    INTO gt_mess-msg SEPARATED BY space.                    "UD281016
    APPEND gt_mess.
*** adjust indexes accordingly
    PERFORM update_index USING new_bseg
                               old_bseg
*                               x_rb .                      "UD281016
                               x_rb                         "UD281016
                               x_lg.                        "UD281016
    PERFORM write_cd USING new_bseg
                           old_bseg
                           x_rb .
  ENDIF.
ENDFORM.                    " UPDATE_BSEG

*&---------------------------------------------------------------------*
*&      Form  UPDATE_INDEX
*&---------------------------------------------------------------------*
FORM update_index  USING    new_bseg TYPE bseg
                            old_bseg TYPE bseg
*                            x_rb     TYPE c.               "UD281016
                            x_rb     TYPE c                 "UD281016
                            x_lg     TYPE c.                "UD281016
  DATA: ls_bkpf TYPE bkpf.
  DATA: ls_bsid TYPE bsid.
  DATA: ls_bsik TYPE bsik.
  DATA: ls_bsis TYPE bsis.
  DATA: tab TYPE dd02l-tabname.                             "UD281016
  FIELD-SYMBOLS: <ls_faglbsis> TYPE ANY.                    "UD281016
  FIELD-SYMBOLS: <augdt> TYPE ANY.                          "UD281016
  FIELD-SYMBOLS: <augbl> TYPE ANY.                          "UD281016
  FIELD-SYMBOLS: <auggj> TYPE ANY.                          "UD281016
  DATA: ls_faglbsis TYPE REF TO data.                       "UD281016

  IF x_lg EQ space.                                         "UD281016
*** 1.: delete old cleared index
    CASE old_bseg-koart.
      WHEN 'D'.
*** delete BSAD
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*        DELETE FROM bsad
*          WHERE bukrs EQ old_bseg-bukrs
*            AND kunnr EQ old_bseg-kunnr
*            AND augdt EQ old_bseg-augdt
*            AND augbl EQ old_bseg-augbl
*            AND gjahr EQ old_bseg-gjahr
*            AND belnr EQ old_bseg-belnr
*            AND buzei EQ old_bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAD deletion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAD deleted'.
          APPEND gt_mess.
        ENDIF.
*** delete recon account BSAS
        IF old_bseg-xhres EQ 'X'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*          DELETE FROM bsas
*            WHERE bukrs EQ old_bseg-bukrs
*              AND hkont EQ old_bseg-hkont
*              AND augdt EQ old_bseg-augdt
*              AND augbl EQ old_bseg-augbl
*              AND gjahr EQ old_bseg-gjahr
*              AND belnr EQ old_bseg-belnr
*              AND buzei EQ old_bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
          IF sy-subrc NE 0.
*** message handling
            CLEAR gt_mess.
            MOVE-CORRESPONDING old_bseg TO gt_mess.
            gt_mess-type = 1.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSAS (recon acct) deletion failed'.
            APPEND gt_mess.
            x_rb = 'X'.
          ELSE.
            CLEAR gt_mess.
            MOVE-CORRESPONDING old_bseg TO gt_mess.
            gt_mess-type = 3.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSAS (recon acct) deleted'.
            APPEND gt_mess.
          ENDIF.
        ENDIF.
      WHEN 'K'.
*** delete BSAK
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*        DELETE FROM bsak
*          WHERE bukrs EQ old_bseg-bukrs
*            AND lifnr EQ old_bseg-lifnr
*            AND augdt EQ old_bseg-augdt
*            AND augbl EQ old_bseg-augbl
*            AND gjahr EQ old_bseg-gjahr
*            AND belnr EQ old_bseg-belnr
*            AND buzei EQ old_bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAK deletion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAK deleted'.
          APPEND gt_mess.
        ENDIF.
*** delete recon account BSAS
        IF old_bseg-xhres EQ 'X'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*          DELETE FROM bsas
*            WHERE bukrs EQ old_bseg-bukrs
*              AND hkont EQ old_bseg-hkont
*              AND augdt EQ old_bseg-augdt
*              AND augbl EQ old_bseg-augbl
*              AND gjahr EQ old_bseg-gjahr
*              AND belnr EQ old_bseg-belnr
*              AND buzei EQ old_bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
          IF sy-subrc NE 0.
*** message handling
            CLEAR gt_mess.
            MOVE-CORRESPONDING old_bseg TO gt_mess.
            gt_mess-type = 1.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSAS (recon acct) deletion failed'.
            APPEND gt_mess.
            x_rb = 'X'.
          ELSE.
            CLEAR gt_mess.
            MOVE-CORRESPONDING old_bseg TO gt_mess.
            gt_mess-type = 3.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSAS (recon acct) deleted'.
            APPEND gt_mess.
          ENDIF.
        ENDIF.
      WHEN 'S'.
*** delete BSAS
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*        DELETE FROM bsas
*          WHERE bukrs EQ old_bseg-bukrs
*            AND hkont EQ old_bseg-hkont
*            AND augdt EQ old_bseg-augdt
*            AND augbl EQ old_bseg-augbl
*            AND gjahr EQ old_bseg-gjahr
*            AND belnr EQ old_bseg-belnr
*            AND buzei EQ old_bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAS deletion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING old_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAS deleted'.
          APPEND gt_mess.
        ENDIF.
    ENDCASE.
*** 2.: build open item index
    SELECT SINGLE * FROM bkpf INTO ls_bkpf
      WHERE bukrs EQ new_bseg-bukrs
        AND belnr EQ new_bseg-belnr
        AND gjahr EQ new_bseg-gjahr.
    CASE new_bseg-koart.
      WHEN 'D'.
*** insert BSID
        CLEAR ls_bsid.
        MOVE-CORRESPONDING ls_bkpf TO ls_bsid.
        MOVE-CORRESPONDING new_bseg TO ls_bsid.
*        INSERT bsid FROM ls_bsid.
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSID insertion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSID inserted'.
          APPEND gt_mess.
        ENDIF.
***  insert recon account BSIS
        IF new_bseg-xhres EQ 'X'.
          CLEAR ls_bsis.
          MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
          MOVE-CORRESPONDING new_bseg TO ls_bsis.
          ls_bsis-zuonr = new_bseg-hzuon.
          ls_bsis-fkber = new_bseg-fkber_long.
*** recon account: no XOPVW
          CLEAR ls_bsis-xopvw.
*          INSERT bsis FROM ls_bsis.
          IF sy-subrc NE 0.
*** message handling
            CLEAR gt_mess.
            MOVE-CORRESPONDING new_bseg TO gt_mess.
            gt_mess-type = 1.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSIS (recon acct) insertion failed'.
            APPEND gt_mess.
            x_rb = 'X'.
          ELSE.
            CLEAR gt_mess.
            MOVE-CORRESPONDING new_bseg TO gt_mess.
            gt_mess-type = 3.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSIS (recon acct) inserted'.
            APPEND gt_mess.
          ENDIF.
        ENDIF.
      WHEN 'K'.
*** insert BSIK
        CLEAR ls_bsik.
        MOVE-CORRESPONDING ls_bkpf TO ls_bsik.
        MOVE-CORRESPONDING new_bseg TO ls_bsik.
*        INSERT bsik FROM ls_bsik.
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSIK insertion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSIK inserted'.
          APPEND gt_mess.
        ENDIF.
***  insert recon account BSIS
        IF new_bseg-xhres EQ 'X'.
          CLEAR ls_bsis.
          MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
          MOVE-CORRESPONDING new_bseg TO ls_bsis.
          ls_bsis-zuonr = new_bseg-hzuon.
          ls_bsis-fkber = new_bseg-fkber_long.
*** recon account: no XOPVW
          CLEAR ls_bsis-xopvw.
*          INSERT bsis FROM ls_bsis.
          IF sy-subrc NE 0.
*** message handling
            CLEAR gt_mess.
            MOVE-CORRESPONDING new_bseg TO gt_mess.
            gt_mess-type = 1.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSIS (recon acct) insertion failed'.
            APPEND gt_mess.
            x_rb = 'X'.
          ELSE.
            CLEAR gt_mess.
            MOVE-CORRESPONDING new_bseg TO gt_mess.
            gt_mess-type = 3.
            gt_mess-class = 'UPDATE'.
            gt_mess-msg = 'BSIS (recon acct) inserted'.
            APPEND gt_mess.
          ENDIF.
        ENDIF.
      WHEN 'S'.
***  insert BSIS
        CLEAR ls_bsis.
        MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
        MOVE-CORRESPONDING new_bseg TO ls_bsis.
*        INSERT bsis FROM ls_bsis.
        IF sy-subrc NE 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSIS insertion failed'.
          APPEND gt_mess.
          x_rb = 'X'.
        ELSE.
          CLEAR gt_mess.
          MOVE-CORRESPONDING new_bseg TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSIS inserted'.
          APPEND gt_mess.
        ENDIF.
    ENDCASE.
*** FAGLBSAS/FAGLBSIS handling                              "UD281016
  ELSE.                                                     "UD281016
*** select existing FAGLBSAS and delete                     "UD281016
    tab = 'FAGLBSAS'.                                       "UD281016
*** create generic work area                                "UD281016
    CREATE DATA ls_faglbsis TYPE (tab).                     "UD281016
    ASSIGN ls_faglbsis->* TO <ls_faglbsis>.                 "UD281016
    SELECT SINGLE * FROM (tab) INTO <ls_faglbsis>           "UD281016
      WHERE bukrs EQ old_bseg-bukrs                         "UD281016
        AND hkont EQ old_bseg-hkont                         "UD281016
        AND augdt EQ old_bseg-augdt                         "UD281016
        AND augbl EQ old_bseg-augbl                         "UD281016
        AND gjahr EQ old_bseg-gjahr                         "UD281016
        AND belnr EQ old_bseg-belnr                         "UD281016
        AND buzei EQ old_bseg-buzei.                        "UD281016
    DELETE (tab) FROM <ls_faglbsis>.                        "UD281016
    IF sy-subrc NE 0.                                       "UD281016
*** message handling                                        "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING old_bseg TO gt_mess.               "UD281016
      gt_mess-type = 1.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSAS deletion failed'.             "UD281016
      APPEND gt_mess.                                       "UD281016
      x_rb = 'X'.                                           "UD281016
    ELSE.                                                   "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING old_bseg TO gt_mess.               "UD281016
      gt_mess-type = 3.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSAS deleted'.                     "UD281016
      APPEND gt_mess.                                       "UD281016
    ENDIF.                                                  "UD281016
*** create FAGLBSIS and insert                              "UD281016
    tab = 'FAGLBSIS'.                                       "UD281016
    ASSIGN COMPONENT 'AUGDT'                                "UD281016
      OF STRUCTURE <ls_faglbsis> TO <augdt>.                "UD281016
    CLEAR <augdt>.                                          "UD281016
    ASSIGN COMPONENT 'AUGBL'                                "UD281016
      OF STRUCTURE <ls_faglbsis> TO <augbl>.                "UD281016
    CLEAR <augbl>.                                          "UD281016
    ASSIGN COMPONENT 'AUGGJ'                                "UD281016
      OF STRUCTURE <ls_faglbsis> TO <auggj>.                "UD281016
    CLEAR <auggj>.                                          "UD281016
    INSERT (tab) FROM <ls_faglbsis>.                        "UD281016
    IF sy-subrc NE 0.                                       "UD281016
*** message handling                                        "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING new_bseg TO gt_mess.               "UD281016
      gt_mess-type = 1.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSIS insertion failed'.            "UD281016
      APPEND gt_mess.                                       "UD281016
      x_rb = 'X'.                                           "UD281016
    ELSE.                                                   "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING new_bseg TO gt_mess.               "UD281016
      gt_mess-type = 3.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSIS inserted'.                    "UD281016
      APPEND gt_mess.                                       "UD281016
    ENDIF.                                                  "UD281016
  ENDIF.                                                    "UD281016
ENDFORM.                    " UPDATE_INDEX

*&---------------------------------------------------------------------*
*&      Form  WRITE_CD
*&---------------------------------------------------------------------*
FORM write_cd  USING    new_bseg TYPE bseg
                        old_bseg TYPE bseg
                        x_rb     TYPE c .

*** move data:
  REFRESH : gt_xbsegr, gt_ybsegr.
  CLEAR : gt_xbsegr, gt_ybsegr.
*** ... old data
  MOVE-CORRESPONDING old_bseg TO gt_ybsegr.
  APPEND gt_ybsegr.
*** ... new data
  MOVE-CORRESPONDING new_bseg TO gt_xbsegr.
  APPEND gt_xbsegr.
*** build administrational data for FM
  upd_bsegr = 'U'.
  tcode     = sy-tcode.
  utime     = sy-uzeit.
  udate     = sy-datum.
  username  = sy-uname.
  objectid  = gt_xbsegr(21).
*** call FM for writing change document in local update task
  SET UPDATE TASK LOCAL.
  CALL FUNCTION 'BELEGR_WRITE_DOCUMENT         '
    EXPORTING
      objectid                = objectid
      tcode                   = tcode
      utime                   = utime
      udate                   = udate
      username                = username
      planned_change_number   = planned_change_number
      object_change_indicator = cdoc_upd_object
      planned_or_real_changes = cdoc_planned_or_real
      no_change_pointers      = cdoc_no_change_pointers
      upd_bsegr               = upd_bsegr
    TABLES
      xbsegr                  = gt_xbsegr
      ybsegr                  = gt_ybsegr.
*** message handling
  CLEAR gt_mess.
  MOVE-CORRESPONDING new_bseg TO gt_mess.
  gt_mess-type = 3.
  gt_mess-class = 'UPDATE'.
  gt_mess-msg = 'Change document created'.
  APPEND gt_mess.
ENDFORM.                    " WRITE_CD

*&---------------------------------------------------------------------*
*&      Form  OUTPUT
*&---------------------------------------------------------------------*
FORM output .
  DATA: ls_index TYPE index.
  DATA: detail TYPE c.                                      "UD280411

  count_clr = LINES( gt_key ).
  IF count_clr EQ 0.
    WRITE:/2 'No clearing selected that could be reset' COLOR 3.
  ENDIF.
  CHECK count_clr GT 0.
  NEW-PAGE.
  PERFORM header_corr.
  LOOP AT gt_key.
*** output key data
    PERFORM header_key.
    PERFORM output_key USING gt_key.
*** check messages for key
    LOOP AT gt_mess
      WHERE   bukrs EQ gt_key-bukrs
        AND   belnr EQ gt_key-augbl
        AND   gjahr EQ gt_key-auggj
        AND ( class EQ 'CLEARING'   OR
              class EQ 'UPDATE'     OR
              class EQ 'FOREX'      OR                      "UD050913
              class EQ 'CROSS CC' ).
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      detail = 'K'.
      PERFORM header_mess.
      CLEAR ls_index.
      ls_index-bukrs = gt_key-bukrs.
      ls_index-belnr = gt_key-augbl.
      ls_index-gjahr = gt_key-auggj.
      PERFORM output_mess USING ls_index
                                detail.                     "UD280411
    ENDIF.
*** reset reversal case
    IF gt_key-reverse GT 0.                                 "UD280411
      READ TABLE gt_rev_key WITH KEY                        "UD280411
        bukrs   = gt_key-bukrs                              "UD280411
        belnr_2 = gt_key-augbl                              "UD280411
        gjahr_2 = gt_key-auggj.                             "UD280411
*** output reversal header
      READ TABLE gt_bkpf_rev WITH KEY                       "UD280411
        bukrs = gt_rev_key-bukrs                            "UD280411
        belnr = gt_rev_key-belnr_2                          "UD280411
        gjahr = gt_rev_key-gjahr_2.                         "UD280411
      PERFORM bkpf_header.                                  "UD280411
      PERFORM output_bkpf USING gt_bkpf_rev.                "UD280411
*** check for header messages for reversal doc
      LOOP AT gt_mess                                       "UD280411
        WHERE   bukrs EQ gt_rev_key-bukrs                   "UD280411
          AND   belnr EQ gt_rev_key-belnr_2                 "UD280411
          AND   gjahr EQ gt_rev_key-gjahr_2                 "UD280411
          AND ( class EQ 'BKPFUPDATE' OR                    "UD280411
                class EQ 'BKPFREVERS' ).                    "UD280411
        EXIT.                                               "UD280411
      ENDLOOP.                                              "UD280411
      IF sy-subrc EQ 0.                                     "UD280411
        detail = 'H'.                                       "UD280411
        PERFORM header_mess.                                "UD280411
        CLEAR ls_index.                                     "UD280411
        ls_index-bukrs = gt_rev_key-bukrs.                  "UD280411
        ls_index-belnr = gt_rev_key-belnr_2.                "UD280411
        ls_index-gjahr = gt_rev_key-gjahr_2.                "UD280411
        PERFORM output_mess USING ls_index                  "UD280411
                                  detail.                   "UD280411
      ENDIF.                                                "UD280411
*** output reversed header
      READ TABLE gt_bkpf_rev WITH KEY                       "UD280411
        bukrs = gt_rev_key-bukrs                            "UD280411
        belnr = gt_rev_key-belnr_1                          "UD280411
        gjahr = gt_rev_key-gjahr_1.                         "UD280411
      PERFORM bkpf_header.                                  "UD280411
      PERFORM output_bkpf USING gt_bkpf_rev.                "UD280411
*** check for header messages for reversed doc
      LOOP AT gt_mess                                       "UD280411
        WHERE   bukrs EQ gt_rev_key-bukrs                   "UD280411
          AND   belnr EQ gt_rev_key-belnr_1                 "UD280411
          AND   gjahr EQ gt_rev_key-gjahr_1                 "UD280411
          AND ( class EQ 'BKPFUPDATE' OR                    "UD280411
                class EQ 'BKPFREVERS' ).                    "UD280411
        EXIT.                                               "UD280411
      ENDLOOP.                                              "UD280411
      IF sy-subrc EQ 0.                                     "UD280411
        detail = 'H'.                                       "UD280411
        PERFORM header_mess.                                "UD280411
        CLEAR ls_index.                                     "UD280411
        ls_index-bukrs = gt_rev_key-bukrs.                  "UD280411
        ls_index-belnr = gt_rev_key-belnr_1.                "UD280411
        ls_index-gjahr = gt_rev_key-gjahr_1.                "UD280411
        PERFORM output_mess USING ls_index                  "UD280411
                                  detail.                   "UD280411
      ENDIF.                                                "UD280411
    ENDIF.                                                  "UD280411
*** output items
    LOOP AT gt_index
      WHERE bukrs EQ gt_key-bukrs
        AND augdt EQ gt_key-augdt
        AND augbl EQ gt_key-augbl
        AND auggj EQ gt_key-auggj.
      PERFORM header_index.
      PERFORM output_index USING gt_index.
*** check for messages
      READ TABLE gt_mess WITH KEY
        bukrs = gt_index-bukrs
        belnr = gt_index-belnr
        gjahr = gt_index-gjahr
        buzei = gt_index-buzei
      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        detail = 'I'.
        PERFORM header_mess.
        PERFORM output_mess USING gt_index
                                  detail.
      ENDIF.
    ENDLOOP.
    AT END OF augbl.
      NEW-LINE.
      ULINE (120).
    ENDAT.
  ENDLOOP.
ENDFORM.                    " OUTPUT

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_EXCL
*&---------------------------------------------------------------------*
FORM output_excl .
  DATA: ls_index TYPE index.
  DATA: detail TYPE c.

  cnt_excl = LINES( gt_key_excl ).
  CHECK cnt_excl GT 0.
  NEW-PAGE.
  PERFORM header_excl.
  LOOP AT gt_key_excl.
*** output key data
    PERFORM header_key.
    PERFORM output_key USING gt_key_excl.
*** check messages for key
    READ TABLE gt_mess WITH KEY
      bukrs = gt_key_excl-bukrs
      belnr = gt_key_excl-augbl
      gjahr = gt_key_excl-auggj
    TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      detail = 'K'.
      PERFORM header_mess.
      CLEAR ls_index.
      ls_index-bukrs = gt_key_excl-bukrs.
      ls_index-belnr = gt_key_excl-augbl.
      ls_index-gjahr = gt_key_excl-auggj.
      PERFORM output_mess USING ls_index
                                detail.
    ENDIF.
*** output items
    LOOP AT gt_index
      WHERE bukrs EQ gt_key_excl-bukrs
        AND augdt EQ gt_key_excl-augdt
        AND augbl EQ gt_key_excl-augbl
        AND auggj EQ gt_key_excl-auggj.
      PERFORM header_index.
      PERFORM output_index USING gt_index.
*** check for messages
      READ TABLE gt_mess WITH KEY
        bukrs = gt_index-bukrs
        belnr = gt_index-belnr
        gjahr = gt_index-gjahr
        buzei = gt_index-buzei
      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        detail = 'I'.
        PERFORM header_mess.
        PERFORM output_mess USING gt_index
                                  detail.
      ENDIF.
    ENDLOOP.
    AT END OF augbl.
      NEW-LINE.
      ULINE (120).
    ENDAT.
  ENDLOOP.
ENDFORM.                    " OUTPUT_EXCL

*&---------------------------------------------------------------------*
*&      Form  HEADER_EXCL
*&---------------------------------------------------------------------*
FORM header_excl .

  FORMAT COLOR 6 INTENSIFIED ON.
  ULINE (120).
  WRITE:/ sy-vline NO-GAP,
          'Excluded clearings:',
      120 sy-vline NO-GAP.
  ULINE (120).
  FORMAT COLOR 3 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
          'Number of cases:',
          cnt_excl,
      120 sy-vline NO-GAP.
  NEW-LINE.
  ULINE (120).
  FORMAT COLOR OFF.
ENDFORM.                    " HEADER_EXCL

*&---------------------------------------------------------------------*
*&      Form  HEADER_INDEX
*&---------------------------------------------------------------------*
FORM header_index .

  FORMAT COLOR 1 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
     (10) 'ITEM',
      (5) 'BUKRS',
     (10) 'AUGDT',
     (10) 'AUGBL',
      (5) 'AUGGJ',
     (10) 'BELNR',
      (5) 'GJAHR',
      (5) 'BUZEI',
      (5) 'XARCH',
      (5) 'KOART',
     (10) 'ACCOUNT',
      120 sy-vline NO-GAP.
ENDFORM.                    " HEADER_INDEX

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_KEY
*&---------------------------------------------------------------------*
FORM output_key  USING   p_key TYPE key.

  FORMAT COLOR 7 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
     (10) 'KEY',
      (5) p_key-bukrs,
     (10) p_key-augdt,
     (10) p_key-augbl,
      (5) p_key-auggj,
*      (5) p_key-cnt_netb,
*      (5) p_key-cnt_arch,
      120 sy-vline NO-GAP.
*** drill-down
  d_bukrs = p_key-bukrs.
  d_belnr = p_key-augbl.
  d_gjahr = p_key-auggj.
  HIDE: d_bukrs, d_belnr, d_gjahr.
ENDFORM.                    " OUTPUT_KEY

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_INDEX
*&---------------------------------------------------------------------*
FORM output_index  USING    p_index TYPE index.

  FORMAT COLOR 2 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
     (10) 'ITEM',
      (5) p_index-bukrs,
     (10) p_index-augdt,
     (10) p_index-augbl,
      (5) p_index-auggj,
     (10) p_index-belnr,
      (5) p_index-gjahr,
      (5) p_index-buzei.
  IF p_index-xarch NE space.
    WRITE: (5) p_index-xarch COLOR 6.
  ELSE.
    WRITE: (5) p_index-xarch.
  ENDIF.
  WRITE: (5) p_index-koart,
        (10) p_index-konto,
         120 sy-vline NO-GAP.
*** drill-down
  d_bukrs = p_index-bukrs.
  d_belnr = p_index-belnr.
  d_gjahr = p_index-gjahr.
  HIDE: d_bukrs, d_belnr, d_gjahr.
ENDFORM.                    " OUTPUT_INDEX

*&---------------------------------------------------------------------*
*&      Form  HEADER_KEY
*&---------------------------------------------------------------------*
FORM header_key .

  FORMAT COLOR 1 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
     (10) 'KEY',
      (5) 'BUKRS',
     (10) 'AUGDT',
     (10) 'AUGBL',
      (5) 'AUGGJ',
*      (5) 'XNETB',
*      (5) 'XARCH',
      120 sy-vline NO-GAP.
  NEW-LINE.
ENDFORM.                    " HEADER_KEY

*&---------------------------------------------------------------------*
*&      Form  HEADER_MESS
*&---------------------------------------------------------------------*
FORM header_mess .

  FORMAT COLOR 1 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
     (10) 'MESSAGE',
*      (5) 'BUZEI',
     (10) 'CLASS',
     (75) 'MSG',
      120 sy-vline NO-GAP.
ENDFORM.                    " HEADER_MESS

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_MESS
*&---------------------------------------------------------------------*
FORM output_mess  USING    p_index  TYPE index
                           p_detail TYPE c.
  DATA: class(10) TYPE c.
  DATA: r_class TYPE RANGE OF class.
  DATA: l_class LIKE LINE OF r_class.

  REFRESH r_class.
  CASE p_detail.
    WHEN 'K'.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'CLEARING'.
      APPEND l_class TO r_class.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'EXCLUDED'.
      APPEND l_class TO r_class.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'CROSS CC'.
      APPEND l_class TO r_class.
      CLEAR l_class.                                        "UD050913
      l_class-sign = 'I'.                                   "UD050913
      l_class-option = 'EQ'.                                "UD050913
      l_class-low = 'FOREX'.                                "UD050913
      APPEND l_class TO r_class.                            "UD050913
    WHEN 'H'.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'BKPFUPDATE'.
      APPEND l_class TO r_class.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'BKPFREVERS'.
      APPEND l_class TO r_class.
    WHEN 'I'.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'UPDATE'.
      APPEND l_class TO r_class.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'REVERSAL'.
      APPEND l_class TO r_class.
      CLEAR l_class.
      l_class-sign = 'I'.
      l_class-option = 'EQ'.
      l_class-low = 'CASH DISC'.
      APPEND l_class TO r_class.
  ENDCASE.
*** select relevant messages
  LOOP AT gt_mess
    WHERE bukrs EQ p_index-bukrs
      AND belnr EQ p_index-belnr
      AND gjahr EQ p_index-gjahr
      AND buzei EQ p_index-buzei
      AND class IN r_class.
*** set color
    CASE gt_mess-type.
      WHEN 0.
        FORMAT COLOR 7 INTENSIFIED OFF.
      WHEN 1.
        FORMAT COLOR 6 INTENSIFIED OFF.
      WHEN 2.
        FORMAT COLOR 3 INTENSIFIED OFF.
      WHEN 3.
        FORMAT COLOR 5 INTENSIFIED OFF.
      WHEN OTHERS.
    ENDCASE.
*** message contents
    WRITE:/ sy-vline NO-GAP,
       (10) 'MESSAGE',
*        (5) gt_mess-buzei,
       (10) gt_mess-class,
       (90) gt_mess-msg,
        120 sy-vline NO-GAP.
*** drill-down
    d_bukrs = gt_mess-bukrs.
    d_belnr = gt_mess-belnr.
    d_gjahr = gt_mess-gjahr.
    HIDE: d_bukrs, d_belnr, d_gjahr.
  ENDLOOP.
ENDFORM.                    " OUTPUT_MESS

*&---------------------------------------------------------------------*
*&      Form  HEADER_CORR
*&---------------------------------------------------------------------*
FORM header_corr .

  FORMAT COLOR 1 INTENSIFIED ON.
  ULINE (120).
  WRITE:/ sy-vline NO-GAP,
          'Clearings to be reset:',
      120 sy-vline NO-GAP.
  ULINE (120).
  FORMAT COLOR 3 INTENSIFIED OFF.
  WRITE:/ sy-vline NO-GAP,
          'Number of cases:',
          count_clr,
      120 sy-vline NO-GAP.
  NEW-LINE.
  ULINE (120).
  FORMAT COLOR OFF.
ENDFORM.                    " HEADER_CORR

*&---------------------------------------------------------------------*
*&      Form  GET_BSTAT_A
*&---------------------------------------------------------------------*
FORM get_bstat_a .
  DATA: ls_bkpf TYPE bkpf.

  LOOP AT gt_key.
    SELECT SINGLE * FROM bkpf INTO ls_bkpf
      WHERE bukrs EQ gt_key-bukrs
        AND belnr EQ gt_key-augbl
        AND gjahr EQ gt_key-auggj.
    CHECK sy-subrc EQ 0.
    CHECK ls_bkpf-bstat EQ 'A'.
    gt_key-cl_bstat = 1.
    MODIFY gt_key.
  ENDLOOP.
ENDFORM.                    " GET_BSTAT_A

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BKPF
*&---------------------------------------------------------------------*
FORM update_bkpf USING    x_rb TYPE c.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: reset clearing via standard posting interface (programmatic FBRA); direct UPDATE bkpf not allowed.
*  UPDATE bkpf
*  SET   bstat = 'B'
*  WHERE bukrs = gt_key-bukrs
*  AND   belnr = gt_key-augbl
*  AND   gjahr = gt_key-auggj.
  CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
       i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
  CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = gt_key-bukrs
       i_augbl = gt_key-augbl i_gjahr = gt_key-auggj i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
  CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
  IF sy-subrc NE 0.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_key TO gt_mess.
    gt_mess-belnr = gt_key-augbl.
    gt_mess-gjahr = gt_key-auggj.
    gt_mess-type = 1.
    gt_mess-class = 'UPDATE'.
    CONCATENATE 'BKPF-BSTAT update'
                'failed'
    INTO gt_mess-msg SEPARATED BY space.
    APPEND gt_mess.
    x_rb = 'X'.
  ELSE.
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_key TO gt_mess.
    gt_mess-belnr = gt_key-augbl.
    gt_mess-gjahr = gt_key-auggj.
    gt_mess-type = 3.
    gt_mess-class = 'UPDATE'.
    gt_mess-msg = 'BKPF-BSTAT updated with B'.
    APPEND gt_mess.
  ENDIF.
ENDFORM.                    " UPDATE_BKPF

*&---------------------------------------------------------------------*
*&      Form  CHECK_CLR_DOC
*&---------------------------------------------------------------------*
FORM check_clr_doc .
  DATA: ls_bkpf TYPE bkpf.
  DATA: table TYPE dd02l-tabname.                           "UD281016
  DATA: date(10) TYPE c.                                    "281016

  LOOP AT gt_key.
    SELECT SINGLE * FROM bkpf INTO ls_bkpf
      WHERE bukrs EQ gt_key-bukrs
        AND belnr EQ gt_key-augbl
        AND gjahr EQ gt_key-auggj.
    CHECK sy-subrc EQ 0.
    IF ls_bkpf-bstat EQ 'L'.                                "UD281016
      table = 'BSEG_ADD'.                                   "UD281016
    ELSE.                                                   "UD281016
      table = 'BSEG'.                                       "UD281016
    ENDIF.                                                  "UD281016
*** if clearing document is a reversal => exclude if X_REVERS not set
*** also exclude if reversal contains archived items
    IF ls_bkpf-stblg NE space.
      IF x_revers EQ space OR gt_key-cnt_arch GT 0.         "UD280411
        CLEAR gt_mess.
        MOVE-CORRESPONDING gt_key TO gt_mess.
        gt_mess-belnr = gt_key-augbl.
        gt_mess-gjahr = gt_key-auggj.
        gt_mess-type = 1.
        gt_mess-class = 'EXCLUDED'.
        gt_mess-msg = 'Clearing document is a reversal'.
        APPEND gt_mess.
        gt_key-reverse = 1.                                 "UD280411
*        INSERT gt_key INTO TABLE gt_key_excl.              "UD281016
        APPEND gt_key TO gt_key_excl.                       "UD281016
        DELETE gt_key.
*** process reversal                                        "UD280411
      ELSE.                                                 "UD280411
        PERFORM reset_reversal USING gt_key ls_bkpf.        "UD280411
        gt_key-reverse = 1.                                 "UD280411
        MODIFY gt_key.                                      "UD280411
        CLEAR gt_mess.                                      "UD280411
        MOVE-CORRESPONDING gt_key TO gt_mess.               "UD280411
        gt_mess-belnr = gt_key-augbl.                       "UD280411
        gt_mess-gjahr = gt_key-auggj.                       "UD280411
        gt_mess-type = 2.                                   "UD280411
        gt_mess-class = 'CLEARING'.                         "UD280411
        CONCATENATE 'Clearing document is a reversal.'      "UD280411
                    'Reversal info will be reset.'          "UD280411
                    INTO gt_mess-msg SEPARATED BY space.    "UD280411
        APPEND gt_mess.                                     "UD280411
      ENDIF.                                                "UD280411
    ENDIF.
*** if BVORG is populated => warning
    IF ls_bkpf-bvorg NE space.
      CLEAR gt_mess.
      MOVE-CORRESPONDING gt_key TO gt_mess.
      gt_mess-belnr = gt_key-augbl.
      gt_mess-gjahr = gt_key-auggj.
      gt_mess-type = 2.
      gt_mess-class = 'CROSS CC'.
      CONCATENATE 'Clearing document belongs to cross-company posting'
                  ls_bkpf-bvorg
      INTO gt_mess-msg SEPARATED BY space.
      APPEND gt_mess.
    ENDIF.
*************************************************************UD200416
*** allow to disable the KDF check                          "UD200416
    CHECK NOT no_rev EQ 'X'.                                "UD200416
*************************************************************UD200416
*************************************************************UD050913
*** check for KDF lines in payments => reversal required    "UD050913
    DATA: cnt_kdf TYPE i.                                   "UD050913
    DATA: ls_oper TYPE t001b-frpe1.                         "UD050913
    CLEAR cnt_kdf.                                          "UD050913
    CHECK gt_key-cl_bstat EQ 0.                             "UD050913
*************************************************************UD281016
*** do also check for BSTAT 'L' documents                   "UD281016
*    SELECT COUNT( * ) FROM bseg INTO cnt_kdf     "UD050913/"UD281016
    SELECT COUNT( * ) FROM (table) INTO cnt_kdf             "UD281016
*************************************************************UD281016
      WHERE bukrs EQ gt_key-bukrs                           "UD050913
        AND belnr EQ gt_key-augbl                           "UD050913
        AND gjahr EQ gt_key-auggj                           "UD050913
        AND ktosl EQ 'KDF'.                                 "UD050913
    CHECK cnt_kdf GT 0.                                     "UD050913
*** message: KDF line detected => reversal mandatory        "UD050913
    CLEAR gt_mess.                                          "UD050913
    MOVE-CORRESPONDING gt_key TO gt_mess.                   "UD050913
    gt_mess-belnr = gt_key-augbl.                           "UD050913
    gt_mess-gjahr = gt_key-auggj.                           "UD050913
    gt_mess-type = 2.                                       "UD050913
    gt_mess-class = 'FOREX'.                                "UD050913
    CONCATENATE 'Exchange rate differences line detected.'  "UD050913
                'Reversal is mandatory.'                    "UD050913
    INTO gt_mess-msg SEPARATED BY space.                    "UD050913
    APPEND gt_mess.                                         "UD050913
*** first error: no reversal reason entered                 "UD050913
    IF p_stgrd EQ space.                                    "UD050913
      CLEAR gt_mess.                                        "UD050913
      MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
      gt_mess-belnr = gt_key-augbl.                         "UD050913
      gt_mess-gjahr = gt_key-auggj.                         "UD050913
      gt_mess-type = 1.                                     "UD050913
      gt_mess-class = 'FOREX'.                              "UD050913
      CONCATENATE 'Please enter'                            "UD050913
                  'a reversal reason'                       "UD050913
      INTO gt_mess-msg SEPARATED BY space.                  "UD050913
      APPEND gt_mess.                                       "UD050913
      gt_key-kdf = 1.                                       "UD050913
*      INSERT gt_key INTO TABLE gt_key_excl.      "UD050913/"UD281016
      APPEND gt_key TO gt_key_excl.                         "UD281016
      DELETE gt_key.                                        "UD050913
      CONTINUE.                                             "UD050913
*** next error: STGRD does not exist                        "UD050913
    ELSE.                                                   "UD050913
      DATA: ls_t041c TYPE t041c.                            "UD050913
      SELECT SINGLE * FROM t041c INTO ls_t041c              "UD050913
        WHERE stgrd EQ p_stgrd.                             "UD050913
      IF NOT sy-subrc EQ 0.                                 "UD050913
        CLEAR gt_mess.                                      "UD050913
        MOVE-CORRESPONDING gt_key TO gt_mess.               "UD050913
        gt_mess-belnr = gt_key-augbl.                       "UD050913
        gt_mess-gjahr = gt_key-auggj.                       "UD050913
        gt_mess-type = 1.                                   "UD050913
        gt_mess-class = 'FOREX'.                            "UD050913
        CONCATENATE 'KDF line found but no reversal possible.'"UD0509
                    'Reversal Reason not found.'            "UD050913
        INTO gt_mess-msg SEPARATED BY space.                "UD050913
        APPEND gt_mess.                                     "UD050913
        gt_key-kdf = 1.                                     "UD050913
*        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
        APPEND gt_key TO gt_key_excl.                       "UD281016
        DELETE gt_key.                                      "UD050913
        CONTINUE.                                           "UD050913
*************************************************************UD281016
*** different reversal date?                                "UD281016
      ELSE.                                                 "UD281016
        IF newdate EQ 'X' AND NOT ls_t041c-xabwd EQ 'X'.    "UD281016
          CLEAR gt_mess.                                    "UD281016
          MOVE-CORRESPONDING gt_key TO gt_mess.             "UD281016
          gt_mess-belnr = gt_key-augbl.                     "UD281016
          gt_mess-gjahr = gt_key-auggj.                     "UD281016
          gt_mess-type = 1.                                 "UD281016
          gt_mess-class = 'FOREX'.                          "UD281016
          CONCATENATE 'Reversal reason' p_stgrd             "UD281016
                      'does not allow different date.'      "UD281016
          INTO gt_mess-msg SEPARATED BY space.              "UD281016
          APPEND gt_mess.                                   "UD281016
          gt_key-kdf = 1.                                   "UD281016
*          INSERT gt_key INTO TABLE gt_key_excl.  "UD050913/"UD281016
          APPEND gt_key TO gt_key_excl.                     "UD281016
          DELETE gt_key.                                    "UD281016
          CONTINUE.                                         "UD281016
        ENDIF.                                              "UD281016
      ENDIF.                                                "UD050913
    ENDIF.                                                  "UD050913
*** check if period is open for reversal                    "UD050913
    DATA: ls_poper TYPE glu1-poper.                         "UD050913
*** pay attention to new reversal date                      "UD281016
    DATA: ls_gjahr TYPE bkpf-gjahr.                         "UD281016
    IF newdate EQ space.                                    "UD281016
      ls_gjahr = ls_bkpf-gjahr.                             "UD281016
      ls_poper = ls_bkpf-monat.                             "UD050913
      gt_key-revdate = ls_bkpf-budat.                       "UD281016
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'           "UD050913
        EXPORTING                                           "UD050913
          input         = ls_poper                          "UD050913
        IMPORTING                                           "UD050913
          output        = ls_poper.                         "UD050913
    ELSE.                                                   "UD281016
      CALL FUNCTION 'FI_PERIOD_DETERMINE'                   "UD281016
        EXPORTING                                           "UD281016
          i_budat        = revdate                          "UD281016
          i_bukrs        = gt_key-bukrs                     "UD281016
        IMPORTING                                           "UD281016
          e_gjahr        = ls_gjahr                         "UD281016
          e_poper        = ls_poper                         "UD281016
        EXCEPTIONS                                          "UD281016
          fiscal_year    = 1                                "UD281016
          period         = 2                                "UD281016
          period_version = 3                                "UD281016
          posting_period = 4                                "UD281016
          special_period = 5                                "UD281016
          version        = 6                                "UD281016
          posting_date   = 7                                "UD281016
          OTHERS         = 8.                               "UD281016
      IF sy-subrc NE 0.                                     "UD281016
        CLEAR gt_mess.                                      "UD281016
        MOVE-CORRESPONDING gt_key TO gt_mess.               "UD281016
        gt_mess-belnr = gt_key-augbl.                       "UD281016
        gt_mess-gjahr = gt_key-auggj.                       "UD281016
        gt_mess-type = 1.                                   "UD281016
        gt_mess-class = 'FOREX'.                            "UD281016
        CONCATENATE 'Error in period'                       "UD281016
                    'determination'                         "UD281016
        INTO gt_mess-msg SEPARATED BY space.                "UD281016
        APPEND gt_mess.                                     "UD281016
        gt_key-kdf = 1.                                     "UD281016
*        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
        APPEND gt_key TO gt_key_excl.                       "UD281016
        DELETE gt_key.                                      "UD281016
        CONTINUE.                                           "UD281016
      ENDIF.                                                "UD281016
      gt_key-revdate = revdate.                             "UD281016
    ENDIF.                                                  "UD281016
    CALL FUNCTION 'FI_PERIOD_CHECK'                         "UD050913
      EXPORTING                                             "UD050913
        i_bukrs = ls_bkpf-bukrs                             "UD050913
*        i_gjahr = ls_bkpf-gjahr                  "UD050913/"UD281016
        i_gjahr = ls_gjahr                                  "UD281016
        i_koart = '+'                                       "UD050913
        i_monat = ls_poper                                  "UD050913
      IMPORTING                                             "UD050913
*        e_oper  = ls_oper.                                 "UD281016
        e_oper  = ls_oper                                   "UD281016
      EXCEPTIONS                                            "UD281016
        error_period     = 1                                "UD281016
        error_period_acc = 2                                "UD281016
        invalid_input    = 3                                "UD281016
        OTHERS           = 4.                               "UD281016
    IF sy-subrc NE 0.                                       "UD281016
*** message: error from open period check                   "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD281016
      gt_mess-belnr = gt_key-augbl.                         "UD281016
      gt_mess-gjahr = gt_key-auggj.                         "UD281016
      gt_mess-type = 1.                                     "UD281016
      gt_mess-class = 'FOREX'.                              "UD281016
      CONCATENATE 'Posting Period'                          "UD281016
                  'is not open'                             "UD281016
      INTO gt_mess-msg SEPARATED BY space.                  "UD281016
      APPEND gt_mess.                                       "UD281016
      gt_key-kdf = 1.                                       "UD281016
*        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
      APPEND gt_key TO gt_key_excl.                         "UD281016
      DELETE gt_key.                                        "UD281016
      CONTINUE.                                             "UD281016
    ENDIF.                                                  "UD281016
    IF ls_oper GT ls_bkpf-monat.                            "UD050913
*** message: KDF line but period not open => exclude        "UD050913
      CLEAR gt_mess.                                        "UD050913
      MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
      gt_mess-belnr = gt_key-augbl.                         "UD050913
      gt_mess-gjahr = gt_key-auggj.                         "UD050913
      gt_mess-type = 1.                                     "UD050913
      gt_mess-class = 'FOREX'.                              "UD050913
      CONCATENATE 'KDF line found but no reversal possible.'"UD050913
                  'Period ' ls_bkpf-monat 'is closed.'      "UD050913
      INTO gt_mess-msg SEPARATED BY space.                  "UD050913
      APPEND gt_mess.                                       "UD050913
      gt_key-kdf = 1.                                       "UD050913
*        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
      APPEND gt_key TO gt_key_excl.                         "UD281016
      DELETE gt_key.                                        "UD050913
      CONTINUE.                                             "UD050913
*** message: key is submitted to SAPF080                    "UD050913
    ELSE.                                                   "UD050913
      CLEAR gt_mess.                                        "UD050913
      MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
      gt_mess-belnr = gt_key-augbl.                         "UD050913
      gt_mess-gjahr = gt_key-auggj.                         "UD050913
      gt_mess-type = 3.                                     "UD050913
      gt_mess-class = 'FOREX'.                              "UD050913
      WRITE gt_key-revdate TO date DD/MM/YYYY.              "UD281016
      CONCATENATE 'Key is submitted to'                     "UD050913
                  'SAPF080 for automatic reversal.'         "UD050913
                  'Reversal date:' date                     "UD281016
      INTO gt_mess-msg SEPARATED BY space.                  "UD050913
      APPEND gt_mess.                                       "UD050913
      gt_key-kdf = 1.                                       "UD050913
*      MODIFY gt_key TRANSPORTING kdf.            "UD050913/"UD281016
      MODIFY gt_key TRANSPORTING kdf revdate.               "UD281016
*************************************************************UD281016
    ENDIF.                                                  "UD050913
*************************************************************UD050913
  ENDLOOP.
ENDFORM.                    " CHECK_CLR_DOC

*&---------------------------------------------------------------------*
*&      Form  DELETE_INDEX
*&---------------------------------------------------------------------*
*FORM delete_index USING    x_rb TYPE c.                    "UD281016
FORM delete_index USING    x_rb TYPE c                      "UD281016
                           x_lg TYPE c.                     "UD281016
  DATA: ls_bseg_recon TYPE bseg.
  DATA: tab TYPE dd02l-tabname VALUE 'FAGLBSAS'.            "UD281016

  CHECK update EQ 'X'.
  IF x_lg EQ space.                                         "UD281016
    CASE gt_index-koart.
      WHEN 'D'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*        DELETE FROM bsad
*          WHERE bukrs EQ gt_index-bukrs
*            AND kunnr EQ gt_index-konto
*            AND augdt EQ gt_index-augdt
*            AND augbl EQ gt_index-augbl
*            AND gjahr EQ gt_index-gjahr
*            AND belnr EQ gt_index-belnr
*            AND buzei EQ gt_index-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc EQ 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAD deleted'.
          APPEND gt_mess.
*** check recon account
          IF gt_index-xhres EQ 'X'.
            PERFORM delete_recon USING x_rb.
          ENDIF.
        ELSE.
          x_rb = 'X'.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAD deletion failed'.
          APPEND gt_mess.
        ENDIF.
      WHEN 'K'.
        "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*        DELETE FROM bsak
*          WHERE bukrs EQ gt_index-bukrs
*            AND lifnr EQ gt_index-konto
*            AND augdt EQ gt_index-augdt
*            AND augbl EQ gt_index-augbl
*            AND gjahr EQ gt_index-gjahr
*            AND belnr EQ gt_index-belnr
*            AND buzei EQ gt_index-buzei.
        "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc EQ 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAK deleted'.
          APPEND gt_mess.
*** check recon account
          IF gt_index-xhres EQ 'X'.
            PERFORM delete_recon USING x_rb.
          ENDIF.
        ELSE.
          x_rb = 'X'.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAK deletion failed'.
          APPEND gt_mess.
        ENDIF.
      WHEN 'S'.
 "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*        DELETE FROM bsas
*          WHERE bukrs EQ gt_index-bukrs
*            AND hkont EQ gt_index-konto
*            AND augdt EQ gt_index-augdt
*            AND augbl EQ gt_index-augbl
*            AND gjahr EQ gt_index-gjahr
*            AND belnr EQ gt_index-belnr
*            AND buzei EQ gt_index-buzei.
        "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        IF sy-subrc EQ 0.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 3.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAS deleted'.
          APPEND gt_mess.
        ELSE.
          x_rb = 'X'.
*** message handling
          CLEAR gt_mess.
          MOVE-CORRESPONDING gt_index TO gt_mess.
          gt_mess-type = 1.
          gt_mess-class = 'UPDATE'.
          gt_mess-msg = 'BSAS deletion failed'.
          APPEND gt_mess.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
*** XLGCLR case: delete FAGLBSAS                            "UD281016
  ELSE.                                                     "UD281016
    DELETE FROM (tab)                                       "UD281016
      WHERE bukrs EQ gt_index-bukrs                         "UD281016
        AND hkont EQ gt_index-konto                         "UD281016
        AND augdt EQ gt_index-augdt                         "UD281016
        AND augbl EQ gt_index-augbl                         "UD281016
        AND gjahr EQ gt_index-gjahr                         "UD281016
        AND belnr EQ gt_index-belnr                         "UD281016
        AND buzei EQ gt_index-buzei.                        "UD281016
    IF sy-subrc EQ 0.                                       "UD281016
*** message handling                                        "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING gt_index TO gt_mess.               "UD281016
      gt_mess-type = 3.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSAS deleted'.                     "UD281016
      APPEND gt_mess.                                       "UD281016
    ELSE.                                                   "UD281016
      x_rb = 'X'.                                           "UD281016
*** message handling                                        "UD281016
      CLEAR gt_mess.                                        "UD281016
      MOVE-CORRESPONDING gt_index TO gt_mess.               "UD281016
      gt_mess-type = 1.                                     "UD281016
      gt_mess-class = 'UPDATE'.                             "UD281016
      gt_mess-msg = 'FAGLBSAS deletion failed'.             "UD281016
      APPEND gt_mess.                                       "UD281016
    ENDIF.                                                  "UD281016
  ENDIF.                                                    "UD281016
ENDFORM.                    " DELETE_INDEX

*&---------------------------------------------------------------------*
*&      Form  DELETE_RECON
*&---------------------------------------------------------------------*
FORM delete_recon  USING    x_rb TYPE c.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*  DELETE FROM bsas
*    WHERE bukrs EQ gt_index-bukrs
*      AND hkont EQ gt_index-recon
*      AND augdt EQ gt_index-augdt
*      AND augbl EQ gt_index-augbl
*      AND gjahr EQ gt_index-gjahr
*      AND belnr EQ gt_index-belnr
*      AND buzei EQ gt_index-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
  IF sy-subrc EQ 0.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_index TO gt_mess.
    gt_mess-type = 3.
    gt_mess-class = 'UPDATE'.
    gt_mess-msg = 'BSAS(recon acct) deleted'.
    APPEND gt_mess.
  ELSE.
    x_rb = 'X'.
*** message handling
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_index TO gt_mess.
    gt_mess-type = 1.
    gt_mess-class = 'UPDATE'.
    gt_mess-msg = 'BSAS(recon acct) deletion failed'.
    APPEND gt_mess.
  ENDIF.
ENDFORM.                    " DELETE_RECON

*&---------------------------------------------------------------------*
*&      Form  LATE_CHECK_S_AUGBL
*&---------------------------------------------------------------------*
FORM late_check_s_augbl .

  LOOP AT s_augbl
    WHERE sign EQ 'I'.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    MESSAGE e016(gu)
    WITH 'Clearing document required'.
  ENDIF.
ENDFORM.                    " LATE_CHECK_S_AUGBL

*&---------------------------------------------------------------------*
*&      Form  RESET_REVERSAL
*&---------------------------------------------------------------------*
FORM reset_reversal  USING    i_key  TYPE key
                              i_bkpf TYPE bkpf.
  DATA: lt_bseg TYPE TABLE OF bseg WITH HEADER LINE.
  DATA: ls_bkpf TYPE bkpf.
  DATA: table TYPE dd02l-tabname.                           "UD281016

*************************************************************UD281016
*** ledgergroup-specific clearings                          "UD281016
  IF i_bkpf-bstat EQ 'L'.                                   "UD281016
    table = 'BSEG_ADD'.                                     "UD281016
  ELSE.                                                     "UD281016
    table = 'BSEG'.                                         "UD281016
  ENDIF.                                                    "UD281016
*************************************************************UD281016
*** select all cleared items from reversal doc
*  SELECT * FROM bseg INTO TABLE lt_bseg                    "UD281016
  SELECT * FROM (table)                                     "UD281016
  INTO CORRESPONDING FIELDS OF TABLE lt_bseg                "UD281016
    WHERE bukrs EQ i_bkpf-bukrs
      AND belnr EQ i_bkpf-belnr
      AND gjahr EQ i_bkpf-gjahr
      AND augbl EQ i_bkpf-belnr
      AND auggj EQ i_bkpf-gjahr.  "#EC CI_FLDEXT_OK[2610650]
*** add items from reversed doc
*  SELECT * FROM bseg INTO lt_bseg                          "UD281016
  SELECT * FROM (table)                                     "UD281016
  INTO CORRESPONDING FIELDS OF lt_bseg                      "UD281016
    WHERE bukrs EQ i_bkpf-bukrs
      AND belnr EQ i_bkpf-stblg
      AND gjahr EQ i_bkpf-stjah
      AND augbl EQ i_bkpf-belnr
      AND auggj EQ i_bkpf-gjahr.  "#EC CI_FLDEXT_OK[2610650]
    APPEND lt_bseg.
  ENDSELECT.
*** check if all involved cleared items are already selected
  LOOP AT lt_bseg.
    READ TABLE gt_index WITH KEY
      bukrs = lt_bseg-bukrs
      augdt = lt_bseg-augdt
      augbl = lt_bseg-augbl
      auggj = lt_bseg-auggj
      belnr = lt_bseg-belnr
      gjahr = lt_bseg-gjahr
      buzei = lt_bseg-buzei.
    CHECK NOT sy-subrc EQ 0.
*** build index if not existing yet
    CLEAR gt_index.
    MOVE-CORRESPONDING lt_bseg TO gt_index.
    CASE lt_bseg-koart.
      WHEN 'K'.
        gt_index-konto = lt_bseg-lifnr.
        gt_index-recon = lt_bseg-hkont.
      WHEN 'D'.
        gt_index-konto = lt_bseg-kunnr.
        gt_index-recon = lt_bseg-hkont.
      WHEN 'S'.
        gt_index-konto = lt_bseg-hkont.
    ENDCASE.
    APPEND gt_index.
*** info message
    CLEAR gt_mess.
    MOVE-CORRESPONDING gt_index TO gt_mess.
    gt_mess-type = 3.
    gt_mess-class = 'REVERSAL'.
    CONCATENATE 'Other cleared item,'
                'automatically selected'
    INTO gt_mess-msg SEPARATED BY space.
    APPEND gt_mess.
  ENDLOOP.
*** prepare header information for undoing reversal
  CLEAR gt_rev_key.
  gt_rev_key-bukrs = i_bkpf-bukrs.
  gt_rev_key-belnr_2 = i_bkpf-belnr.
  gt_rev_key-gjahr_2 = i_bkpf-gjahr.
  gt_rev_key-belnr_1 = i_bkpf-stblg.
  gt_rev_key-gjahr_1 = i_bkpf-stjah.
  INSERT gt_rev_key INTO TABLE gt_rev_key.
*** append BKPF for output
  APPEND i_bkpf TO gt_bkpf_rev.
*** info message
  CLEAR gt_mess.
  MOVE-CORRESPONDING i_bkpf TO gt_mess.
  gt_mess-type = 3.
  gt_mess-class = 'BKPFREVERS'.
  CONCATENATE 'Reversal information'
              'to be reset'
  INTO gt_mess-msg SEPARATED BY space.
  APPEND gt_mess.
  SELECT SINGLE * FROM bkpf INTO ls_bkpf
    WHERE bukrs EQ gt_rev_key-bukrs
      AND belnr EQ gt_rev_key-belnr_1
      AND gjahr EQ gt_rev_key-gjahr_1.
  APPEND ls_bkpf TO gt_bkpf_rev.
*** info message
  CLEAR gt_mess.
  MOVE-CORRESPONDING ls_bkpf TO gt_mess.
  gt_mess-type = 3.
  gt_mess-class = 'BKPFREVERS'.
  CONCATENATE 'Reversal information'
              'to be reset'
  INTO gt_mess-msg SEPARATED BY space.
  APPEND gt_mess.
ENDFORM.                    " RESET_REVERSAL

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BKPF_REVERSAL
*----------------------------------------------------------------------*
FORM update_bkpf_reversal  USING    x_rb TYPE c.            "UD280411
  DATA: lt_bkpf_new TYPE TABLE OF bkpf WITH HEADER LINE.    "UD280411
  DATA: lt_bkpf_old TYPE TABLE OF bkpf WITH HEADER LINE.    "UD280411
                                                            "UD280411
  CHECK update EQ 'X'.                                      "UD280411
*** get affected headers via reversal key                   "UD280411
  REFRESH: lt_bkpf_old, lt_bkpf_new.                        "UD280411
  READ TABLE gt_rev_key WITH KEY                            "UD280411
    bukrs   = gt_key-bukrs                                  "UD280411
    belnr_2 = gt_key-augbl                                  "UD280411
    gjahr_2 = gt_key-auggj.                                 "UD280411
*** select corresponding reversal BKPF                      "UD280411
  SELECT SINGLE * FROM bkpf INTO lt_bkpf_new                "UD280411
    WHERE bukrs EQ gt_rev_key-bukrs                         "UD280411
      AND belnr EQ gt_rev_key-belnr_2                       "UD280411
      AND gjahr EQ gt_rev_key-gjahr_2.                      "UD280411
  APPEND lt_bkpf_new TO lt_bkpf_old.                        "UD280411
  CLEAR: lt_bkpf_new-stblg,                                 "UD280411
         lt_bkpf_new-stjah,                                 "UD280411
         lt_bkpf_new-stgrd,                                 "UD280411
         lt_bkpf_new-xreversal.                             "UD280411
  APPEND lt_bkpf_new.                                       "UD280411
*** select corresponding reversed BKPF                      "UD280411
  SELECT SINGLE * FROM bkpf INTO lt_bkpf_new                "UD280411
    WHERE bukrs EQ gt_rev_key-bukrs                         "UD280411
      AND belnr EQ gt_rev_key-belnr_1                       "UD280411
      AND gjahr EQ gt_rev_key-gjahr_1.                      "UD280411
  APPEND lt_bkpf_new TO lt_bkpf_old.                        "UD280411
  CLEAR: lt_bkpf_new-stblg,                                 "UD280411
         lt_bkpf_new-stjah,                                 "UD280411
         lt_bkpf_new-stgrd,                                 "UD280411
         lt_bkpf_new-xreversal.                             "UD280411
  APPEND lt_bkpf_new.                                       "UD280411
*** update BKPF                                             "UD280411
  LOOP AT lt_bkpf_new.                                      "UD280411
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: removal of reversal linkage (STBLG/STJAH/STGRD/XREVERSAL) has NO standard API - a posted
*      reversal cannot be undone in S/4HANA (re-post required). Direct UPDATE bkpf not allowed.
*    UPDATE bkpf                                             "UD280411
*    SET   stblg = lt_bkpf_new-stblg                         "UD280411
*          stjah = lt_bkpf_new-stjah                         "UD280411
*          stgrd = lt_bkpf_new-stgrd                         "UD280411
*      xreversal = lt_bkpf_new-xreversal                     "UD280411
*    WHERE bukrs = lt_bkpf_new-bukrs                         "UD280411
*    AND   belnr = lt_bkpf_new-belnr                         "UD280411
*    AND   gjahr = lt_bkpf_new-gjahr.                        "UD280411
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
    IF sy-subrc EQ 0.                                       "UD280411
*** create message                                          "UD280411
      CLEAR gt_mess.                                        "UD280411
      MOVE-CORRESPONDING lt_bkpf_new TO gt_mess.            "UD280411
      gt_mess-type = 3.                                     "UD280411
      gt_mess-class = 'BKPFUPDATE'.                         "UD280411
      gt_mess-msg = 'Reversal case: BKPF updated'.          "UD280411
      APPEND gt_mess.                                       "UD280411
*** write change document                                   "UD280411
      READ TABLE lt_bkpf_old WITH KEY                       "UD280411
        bukrs = lt_bkpf_new-bukrs                           "UD280411
        belnr = lt_bkpf_new-belnr                           "UD280411
        gjahr = lt_bkpf_new-gjahr.                          "UD280411
      PERFORM write_cd_bkpf_rev USING lt_bkpf_new           "UD280411
                                      lt_bkpf_old.          "UD280411
    ELSE.                                                   "UD280411
*** create message                                          "UD280411
      CLEAR gt_mess.                                        "UD280411
      MOVE-CORRESPONDING lt_bkpf_new TO gt_mess.            "UD280411
      gt_mess-type = 1.                                     "UD280411
      gt_mess-class = 'BKPFUPDATE'.                         "UD280411
      gt_mess-msg = 'Reversal case: BKPF update failed'.    "UD280411
      APPEND gt_mess.                                       "UD280411
      x_rb = 'X'.                                           "UD280411
    ENDIF.                                                  "UD280411
  ENDLOOP.                                                  "UD280411
ENDFORM.                    " UPDATE_BKPF_REVERSAL          "UD280411

*&---------------------------------------------------------------------*
*&      Form  WRITE_CD_BKPF_REV
*&---------------------------------------------------------------------*
FORM write_cd_bkpf_rev  USING    i_bkpf_new TYPE bkpf
                                 i_bkpf_old TYPE bkpf.
  DATA: ls_objectid TYPE cdhdr-objectid.

*** create OBJECTID
  CLEAR ls_objectid.
  ls_objectid(3)    = i_bkpf_new-mandt.
  ls_objectid+3(4)  = i_bkpf_new-bukrs.
  ls_objectid+7(10) = i_bkpf_new-belnr.
  ls_objectid+17(4) = i_bkpf_new-gjahr.
*** write CD in update task
  CALL FUNCTION 'BELEG_WRITE_DOCUMENT' IN UPDATE TASK
    EXPORTING
      objectid = ls_objectid
      utime    = sy-timlo
      udate    = sy-datlo
      username = sy-uname
      tcode    = sy-tcode
      n_bkpf   = i_bkpf_new
      o_bkpf   = i_bkpf_old
      upd_bkpf = 'U'.
*** create message
  CLEAR gt_mess.
  MOVE-CORRESPONDING i_bkpf_new TO gt_mess.
  gt_mess-type = 3.
  gt_mess-class = 'BKPFUPDATE'.
  gt_mess-msg = 'Change document created for reversal BKPF'.
  APPEND gt_mess.
ENDFORM.                    " WRITE_CD_BKPF_REV

*&---------------------------------------------------------------------*
*&      Form  BKPF_HEADER
*&---------------------------------------------------------------------*
FORM bkpf_header .                                          "UD280411
                                                            "UD280411
  FORMAT COLOR 1 INTENSIFIED OFF.                           "UD280411
  WRITE:/ sy-vline NO-GAP,                                  "UD280411
     (10) 'BKPF',                                           "UD280411
      (5) 'BUKRS',                                          "UD280411
     (10) 'BELNR',                                          "UD280411
      (5) 'GJAHR',                                          "UD280411
     (10) 'BUDAT',                                          "UD280411
     (10) 'STBLG',                                          "UD280411
      (5) 'STJAH',                                          "UD280411
      (5) 'STGRD',                                          "UD280411
     (10) 'XREVERSAL',                                      "UD280411
      120 sy-vline NO-GAP.                                  "UD280411
  NEW-LINE.                                                 "UD280411
ENDFORM.                    " BKPF_HEADER

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_BKPF
*&---------------------------------------------------------------------*
FORM output_bkpf  USING    i_bkpf_rev TYPE bkpf.            "UD280411
                                                            "UD280411
  FORMAT COLOR 2 INTENSIFIED OFF.                           "UD280411
  WRITE:/ sy-vline NO-GAP,                                  "UD280411
     (10) 'BKPF',                                           "UD280411
      (5) i_bkpf_rev-bukrs,                                 "UD280411
     (10) i_bkpf_rev-belnr,                                 "UD280411
      (5) i_bkpf_rev-gjahr,                                 "UD280411
     (10) i_bkpf_rev-budat,                                 "UD280411
     (10) i_bkpf_rev-stblg,                                 "UD280411
      (5) i_bkpf_rev-stjah,                                 "UD280411
      (5) i_bkpf_rev-stgrd,                                 "UD280411
     (10) i_bkpf_rev-xreversal,                             "UD280411
      120 sy-vline NO-GAP.                                  "UD280411
*** drill-down                                              "UD280411
  d_bukrs = i_bkpf_rev-bukrs.                               "UD280411
  d_belnr = i_bkpf_rev-belnr.                               "UD280411
  d_gjahr = i_bkpf_rev-gjahr.                               "UD280411
  HIDE: d_bukrs, d_belnr, d_gjahr.                          "UD280411
ENDFORM.                    " OUTPUT_BKPF                   "UD280411

*&---------------------------------------------------------------------*
*&      Form  REVERSE_RESET_CLR                             "UD050913
*&---------------------------------------------------------------------*
FORM reverse_reset_clr .                                    "UD050913
  TYPES: BEGIN OF gjahrtab,                                 "UD050913
        bukrs TYPE bseg-bukrs,                              "UD050913
        auggj TYPE bseg-auggj,                              "UD050913
        END OF gjahrtab.                                    "UD050913
  DATA: lt_gjahrtab TYPE TABLE OF gjahrtab WITH HEADER LINE."UD050913
  RANGES: r_bukrs FOR bkpf-bukrs.                           "UD050913
  DATA: l_bukrs LIKE LINE OF r_bukrs.                       "UD050913
  RANGES: r_belnr FOR bkpf-belnr.                           "UD050913
  DATA: l_belnr LIKE LINE OF r_belnr.                       "UD050913
  RANGES: r_gjahr FOR bkpf-gjahr.                           "UD050913
  DATA: l_gjahr LIKE LINE OF r_gjahr.                       "UD050913
  DATA: spl TYPE TABLE OF abaplist WITH HEADER LINE.        "UD050913
  DATA: cnt_pack TYPE i.                                    "UD050913
  DATA: testflag TYPE c.                                    "UD050913
                                                            "UD050913
*** set TESTFLAG for SUBMIT                                 "UD050913
  IF update EQ 'X'.                                         "UD050913
    CLEAR testflag.                                         "UD050913
  ELSE.                                                     "UD050913
    testflag = 'X'.                                         "UD050913
  ENDIF.                                                    "UD050913
*** build up GJAHRTAB                                       "UD050913
  LOOP AT gt_key                                            "UD050913
    WHERE kdf GT 0.                                         "UD050913
    CLEAR lt_gjahrtab.                                      "UD050913
    MOVE-CORRESPONDING gt_key TO lt_gjahrtab.               "UD050913
    COLLECT lt_gjahrtab.                                    "UD050913
  ENDLOOP.                                                  "UD050913
*** build ranges for submit to SAPF080                      "UD050913
  LOOP AT lt_gjahrtab.                                      "UD050913
    REFRESH: r_bukrs, r_belnr, r_gjahr.                     "UD050913
*** build-up BUKRS range                                    "UD050913
    CLEAR l_bukrs.                                          "UD050913
    l_bukrs-sign = 'I'.                                     "UD050913
    l_bukrs-option = 'EQ'.                                  "UD050913
    l_bukrs-low = lt_gjahrtab-bukrs.                        "UD050913
    CLEAR l_bukrs-high.                                     "UD050913
    APPEND l_bukrs TO r_bukrs.                              "UD050913
*** build-up GJAHR range                                    "UD050913
    CLEAR l_gjahr.                                          "UD050913
    l_gjahr-sign = 'I'.                                     "UD050913
    l_gjahr-option = 'EQ'.                                  "UD050913
    l_gjahr-low = lt_gjahrtab-auggj.                        "UD050913
    CLEAR l_gjahr-high.                                     "UD050913
    APPEND l_gjahr TO r_gjahr.                              "UD050913
*** build-up BELNR range                                    "UD050913
    LOOP AT gt_key                                          "UD050913
      WHERE bukrs EQ lt_gjahrtab-bukrs                      "UD050913
        AND auggj EQ lt_gjahrtab-auggj.                     "UD050913
      CLEAR l_belnr.                                        "UD050913
      l_belnr-sign = 'I'.                                   "UD050913
      l_belnr-option = 'EQ'.                                "UD050913
      l_belnr-low = gt_key-augbl.                           "UD050913
      CLEAR l_belnr-high.                                   "UD050913
      APPEND l_belnr TO r_belnr.                            "UD050913
***********************************************************************
*** package-wise SUBMIT to SAPF080                          "UD050913
      ADD 1 TO cnt_pack.                                    "UD050913
      IF cnt_pack EQ 100.                                   "UD050913
*** submit SAPF080                                          "UD050913
*************************************************************UD281016
*** allow different reversal date                           "UD281016
        IF newdate EQ space.                                "UD281016
          SUBMIT sapf080                                    "UD050913
             WITH br_bukrs IN r_bukrs                       "UD050913
             WITH br_gjahr IN r_gjahr                       "UD050913
             WITH br_belnr IN r_belnr                       "UD050913
             WITH stogrd   EQ p_stgrd                       "UD050913
             WITH testlauf EQ testflag                      "UD050913
             EXPORTING LIST TO MEMORY                       "UD050913
             AND RETURN.                                    "UD050913
        ELSE.                                               "UD281016
          SUBMIT sapf080                                    "UD281016
             WITH br_bukrs IN r_bukrs                       "UD281016
             WITH br_gjahr IN r_gjahr                       "UD281016
             WITH br_belnr IN r_belnr                       "UD281016
             WITH stogrd   EQ p_stgrd                       "UD281016
*** submit new reversal date                                "UD281016
             WITH stodat   EQ revdate                       "UD281016
             WITH testlauf EQ testflag                      "UD281016
             EXPORTING LIST TO MEMORY                       "UD281016
             AND RETURN.                                    "UD281016
        ENDIF.                                              "UD281016
*** get spool                                               "UD050913
        REFRESH spl.                                        "UD050913
        CALL FUNCTION 'LIST_FROM_MEMORY'                    "UD050913
          TABLES                                            "UD050913
            listobject = spl                                "UD050913
          EXCEPTIONS                                        "UD050913
            not_found  = 1.                                 "UD050913
        IF sy-subrc = 0.                                    "UD050913
          CALL FUNCTION 'WRITE_LIST'                        "UD050913
            TABLES                                          "UD050913
              listobject = spl.                             "UD050913
        ENDIF.                                              "UD050913
        REFRESH r_belnr.                                    "UD050913
        CLEAR cnt_pack.                                     "UD050913
      ENDIF.                                                "UD050913
    ENDLOOP.                                                "UD050913
*** process residuals                                       "UD050913
    CHECK cnt_pack GT 0.                                    "UD050913
***********************************************************************
*** submit SAPF080                                          "UD050913
    IF newdate EQ space.                                    "UD281016
      SUBMIT sapf080                                        "UD050913
         WITH br_bukrs IN r_bukrs                           "UD050913
         WITH br_gjahr IN r_gjahr                           "UD050913
         WITH br_belnr IN r_belnr                           "UD050913
         WITH stogrd   EQ p_stgrd                           "UD050913
         WITH testlauf EQ testflag                          "UD050913
         EXPORTING LIST TO MEMORY                           "UD050913
         AND RETURN.                                        "UD050913
    ELSE.                                                   "UD281016
      SUBMIT sapf080                                        "UD281016
         WITH br_bukrs IN r_bukrs                           "UD281016
         WITH br_gjahr IN r_gjahr                           "UD281016
         WITH br_belnr IN r_belnr                           "UD281016
         WITH stogrd   EQ p_stgrd                           "UD281016
*** submit new reversal date                                "UD281016
         WITH stodat   EQ revdate                           "UD281016
         WITH testlauf EQ testflag                          "UD281016
         EXPORTING LIST TO MEMORY                           "UD281016
         AND RETURN.                                        "UD281016
    ENDIF.                                                  "UD281016
*************************************************************UD281016
*** get spool                                               "UD050913
    REFRESH spl.                                            "UD050913
    CALL FUNCTION 'LIST_FROM_MEMORY'                        "UD050913
      TABLES                                                "UD050913
        listobject = spl                                    "UD050913
      EXCEPTIONS                                            "UD050913
        not_found  = 1.                                     "UD050913
    IF sy-subrc = 0.                                        "UD050913
      CALL FUNCTION 'WRITE_LIST'                            "UD050913
        TABLES                                              "UD050913
          listobject = spl.                                 "UD050913
    ENDIF.                                                  "UD050913
  ENDLOOP.                                                  "UD050913
ENDFORM.                    " REVERSE_RESET_CLR             "UD050913

*&---------------------------------------------------------------------*
*&      Form  SELECT_CLEARING_FAGLBSAS
*&---------------------------------------------------------------------*
FORM select_clearing_faglbsas .                             "UD281016
  DATA: ls_bsas TYPE bsas.                                  "UD281016
  DATA: tab TYPE dd03l-tabname VALUE 'FAGLBSAS'.            "UD281016
                                                            "UD281016
  SELECT * FROM (tab) INTO CORRESPONDING FIELDS OF ls_bsas  "UD281016
    WHERE bukrs EQ p_bukrs                                  "UD281016
      AND hkont IN s_konto                                  "UD281016
      AND augbl IN s_augbl                                  "UD281016
      AND augdt IN s_augdt.  "#EC CI_FLDEXT_OK[2610650]  "UD281016
    CLEAR gt_index.                                         "UD281016
    MOVE-CORRESPONDING ls_bsas TO gt_index.                 "UD281016
    gt_index-koart = 'S'.                                   "UD281016
    gt_index-konto = ls_bsas-hkont.                         "UD281016
    gt_index-xlgclr = 'X'.                                  "UD281016
    APPEND gt_index.                                        "UD281016
    CLEAR gt_key.                                           "UD281016
    MOVE-CORRESPONDING ls_bsas TO gt_key.                   "UD281016
    gt_key-xlgclr = 1.                                      "UD281016
    IF ls_bsas-xarch EQ 'X'.                                "UD281016
      gt_key-cnt_arch = 1.                                  "UD281016
    ENDIF.                                                  "UD281016
    COLLECT gt_key.                                         "UD281016
  ENDSELECT.                                                "UD281016
ENDFORM.                    " SELECT_CLEARING_FAGLBSAS      "UD281016
