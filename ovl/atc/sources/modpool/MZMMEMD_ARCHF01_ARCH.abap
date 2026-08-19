*--- MAIN PROGRAM: MZMMEMD_ARCHF01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDF01                                                 *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With POPUP_TO_CONFIRM.
************************************************************************
*           Modification Log
************************************************************************
*  Date            Transport      USERID        Description
* 08/04/2009      <RD1K963111>    SAB_SARVANAN  Added radio button for EMD
*
* 1) Replaced Function Module K_KKB_POPUP_RADIO2 with K_KKB_POPUP_RADIO3
*    to give third radio button for EMD
* 12/06/2009      <RD1K964254>    SAB_SARVANAN  Added FM(ZMM_EMD_GET_STATUS_DETAILS)
*                                               to update & find the Header Status
************************************************************************

*&---------------------------------------------------------------------*
*&      Form  clear_screen_0105
*&---------------------------------------------------------------------*
*      Clear Data from screen 105.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_screen_0105.
  REFRESH : ist_emddtl,
            ist_emddtl01,
            ist_emdhdr  ,
            ist_emddtl_t01.
  CLEAR : ok_code, prev_okcode , g_okhdr, g_reset, g_hstatus.
  CLEAR:
         zmm_emdhdr-trans    ,
         zmm_emdhdr-ebeln    ,
         zmm_emdhdr-ekgrp    ,
         zmm_emdhdr-currency ,
         zmm_emdhdr-amount   ,
         zmm_emdhdr-place    ,
         zmm_emdhdr-co_code  ,
         zmm_emdhdr-docno    ,
         zmm_emdhdr-ebidno   ,
         zmm_emdhdr-vendorno .

  CLEAR g_locname.
  CLEAR   ist_emddtl.
  CLEAR   wa_tc105  .
  CLEAR   wa_emddtl .
  CLEAR   wa_emddtl01.
  CLEAR : g_vcode  ,
          g_tendno ,
          g_ekgrp  ,
          g_vname  ,
          g_ans    ,
          g_sc_ans ,
          g_ttype   .
  CLEAR   g_amount .
  CLEAR   g_locname.
  CLEAR:   g_idocno .

  CLEAR:   g_mmret ,
          g_firet .

  CLEAR : zmm_emdhdr,
          wa_emdhdr.                          "+007
ENDFORM.                    " clear_screen_0105
*&---------------------------------------------------------------------*
*&      Form  GET_VENDORNO_TENDERNO
*&---------------------------------------------------------------------*
*       Get Vendorno and Tender no from table EKKO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_vendorno_tenderno.
  DATA: wa_ekpa  TYPE ekpa,
        l_lifnr  TYPE ekpa-lifn2 .
  CLEAR:  wa_ekpa,l_lifnr.


*+004
* Partner Fuction 'OA' is represented by 'BA' in table EKPA Hence
*checcking for partner fuction 'BA' in below Query
  IF  prev_okcode NE 'ECREA'.
    SELECT * FROM EKPA INTO WA_EKPA UP TO 1 ROWS
 WHERE EBELN = ZMM_EMDHDR-EBELN AND PARVW = 'BA'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.

      l_lifnr = wa_ekpa-lifn2 .

    ENDIF.
  ENDIF.

*+004
  IF NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE * FROM ekko INTO wa_ekko
    WHERE ebeln = zmm_emdhdr-ebeln   .
********************************** Data From Open Text Server*******************************
    IF sy-subrc <> 0.
      PERFORM mm_ekko_arch.
      READ TABLE it_ekko_arch INTO wa_ekko_arch INDEX 1.
      IF sy-subrc EQ 0.
        wa_ekko-submi = wa_ekko_arch-submi.
        wa_ekko-lifnr = wa_ekko_arch-lifnr.
        wa_ekko-ekgrp = wa_ekko_arch-ekgrp.
      ENDIF.
      IF it_ekko_arch IS NOT INITIAL.
        MESSAGE 'PO is Already Archived' TYPE 'S'.
      ENDIF.
    ENDIF.
********************************** Data From Open Text Server*******************************

    IF sy-subrc NE 0.
      MESSAGE e275(zmm).
    ELSE.

*&--> Check whether COLLECTIVE no and VENDOR CODE exist in RFQ for TFS
      IF zmm_emdhdr-trans = 'TFS'.
        IF wa_ekko-submi IS INITIAL .
          MESSAGE e402(zmm) .
        ELSEIF wa_ekko-lifnr IS INITIAL.
          MESSAGE e403(zmm) .
        ENDIF.
*&--<
*&--> Check whether   VENDOR CODE exist in PO for EMD/SD

      ELSEIF zmm_emdhdr-trans = 'EMD' OR zmm_emdhdr-trans = 'SDT' .
        IF wa_ekko-lifnr IS INITIAL.
          MESSAGE e403(zmm) .
        ENDIF.
      ENDIF.
*&--<

*+004
      IF NOT l_lifnr IS INITIAL.
        wa_ekko-lifnr = l_lifnr .
      ENDIF.
*+004
      MOVE:
            wa_ekko-submi    TO zmm_emdhdr-tenderno,
            wa_ekko-lifnr    TO zmm_emdhdr-vendorno,
            wa_ekko-ekgrp    TO zmm_emdhdr-ekgrp   .
      MOVE:
            wa_ekko-lifnr    TO g_vcode   ,
            wa_ekko-submi    TO g_tendno  ,
            wa_ekko-ekgrp    TO g_ekgrp .

*&--> Get Vendor name from table LFB1.
      SELECT SINGLE * FROM lfa1 INTO wa_lfa1
            WHERE lifnr = wa_ekko-lifnr.
      MOVE wa_lfa1-name1  TO g_vname .
*&--<
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_VENDORNO_TENDERNO
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBELN
*&---------------------------------------------------------------------*
*       Check EBELN
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebeln.
  DATA: l_ebeln LIKE ekko-ebeln,
        l_bstyp LIKE ekko-bstyp.

*&--> Check for PO Document no if Tender fee select doc.with BSTYP =
*'A' Otherwise select doc. with  BSTYP = 'F'

  IF NOT zmm_emdhdr-trans IS INITIAL AND
    NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE ebeln bstyp FROM ekko INTO (l_ebeln,l_bstyp)
           WHERE  ebeln = zmm_emdhdr-ebeln .

    IF sy-subrc NE 0.
      MESSAGE e468(zmm).
    ELSE.
      PERFORM check_document_type USING zmm_emdhdr-trans l_bstyp  .
    ENDIF.
  ENDIF.
*&--<
ENDFORM.                    " CHECK_EBELN
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
*       Check Document Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_document_type USING p_trans p_bstyp.
  IF p_trans = 'TFS' OR p_trans = 'EMD'.
    IF p_bstyp NE 'A'.
      MESSAGE e400(zmm) WITH p_trans..
    ENDIF.
  ELSEIF  p_trans = 'SDT'.
    IF p_bstyp = 'F' OR p_bstyp = 'K' . "PO / Contract no
    ELSE.
      MESSAGE e401(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
*&      Form  insert_record
*&---------------------------------------------------------------------*
*      Insert Record in Table Control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_record.
  DATA: l_next_line  TYPE i,
        l_lines      TYPE i  .
  CLEAR : l_next_line ,l_lines .
*& find total no of rec. in table control .
  DESCRIBE TABLE ist_emddtl LINES l_lines.
  l_next_line = l_lines + 1.
  IF NOT l_next_line IS INITIAL.
    INSERT INITIAL LINE INTO ist_emddtl  INDEX  l_next_line .
    READ TABLE ist_emddtl INTO wa_emddtl INDEX  l_next_line .
* Begin of <RD1K963111>
    wa_emddtl-rscode = wa_tc105-rscode.
* End of <RD1K963111>
    wa_emddtl-item_no = l_lines + 1.
    MODIFY ist_emddtl FROM wa_emddtl     INDEX  l_next_line .
    tc_105-lines = l_lines + 1 .
  ENDIF.
  SET CURSOR FIELD 'WA_TC105-INST_TYPE' LINE  tc_105-lines .
  CLEAR ok_code.
ENDFORM.                    " insert_record
*&---------------------------------------------------------------------*
*&      Form  delete_record
*&---------------------------------------------------------------------*
*      Delete Record from Table Control
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_record.
  DATA:  l_curr_line ,
         l_next_line ,
         l_tabix LIKE sy-tabix .
  DATA l_lines TYPE i .
  CLEAR : l_curr_line,
          l_next_line,
          l_tabix    .
  REFRESH ist_del_emddtl .
  DESCRIBE TABLE ist_emddtl LINES g_line .
*  IF g_line = 1.
*    MESSAGE e414(zmm).
*  ENDIF.
** Changes 1.11.04

  LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
    l_lines = l_lines + 1.
  ENDLOOP.

  IF l_lines = 1 AND g_line = 1.
    LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
      wa_emddtl-sel = space.
      MODIFY ist_emddtl FROM wa_emddtl .
    ENDLOOP.

    MESSAGE e414(zmm).
  ENDIF.

  IF g_line = l_lines.
    LOOP AT ist_emddtl INTO wa_emddtl  WHERE sel = 'X'.
      wa_emddtl-sel = space.
      MODIFY ist_emddtl FROM wa_emddtl .
    ENDLOOP.
    MESSAGE e508(zmm).
  ENDIF.
*** end of change -----------------------------------------

  LOOP AT ist_emddtl INTO wa_emddtl
  WHERE sel = 'X' .
    APPEND wa_emddtl TO ist_del_emddtl.
  ENDLOOP.

  IF  NOT ist_emddtl IS INITIAL.
*&--< if user has selected multiple lines.
    LOOP AT ist_del_emddtl  INTO wa_emddtl.
      DELETE ist_emddtl  WHERE item_no = wa_emddtl-item_no.
      IF g_line > 1.
        tc_105-lines = tc_105-lines - 1.
      ELSE.
        CLEAR ist_emddtl .
        CLEAR wa_emddtl .
        wa_emddtl-item_no = '01'.
        APPEND wa_emddtl TO ist_emddtl .
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--< Reassign Item no
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_emddtl-item_no = sy-tabix .
    MODIFY ist_emddtl FROM wa_emddtl.
  ENDLOOP.
*&--<
  PERFORM calc_total_amount .
  CLEAR ok_code .
ENDFORM.                    " delete_record
*&---------------------------------------------------------------------*
*&      Form  fill_ist_emddtl
*&---------------------------------------------------------------------*
*       Append Item-no initaily into internal table ist_emddtl
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_ist_emddtl.
  REFRESH ist_emddtl.
  CLEAR ist_emddtl.
  CLEAR wa_emddtl.
  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.         "+002
    wa_emddtl-item_no = '01'.
    APPEND wa_emddtl TO ist_emddtl.
  ENDIF.
ENDFORM.                    " fill_ist_emddtl
*&---------------------------------------------------------------------*
*&      Form  MODIFY_ISTTAB
*&---------------------------------------------------------------------*
*       Modify Internal table ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_isttab.
  REFRESH ist_tab .
  CLEAR ist_tab   .
  CLEAR wa_tab    .

  IF ( prev_okcode = 'CREA' OR prev_okcode = 'ECREA' ) AND g_okhdr = 'X'.
    "+002
    MOVE 'DELT'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'    TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab     .
    MOVE 'HEAD'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'DOCU'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'IDTL'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'.
    MOVE 'SAVE'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE  'RESET'  TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'REST'.
    REFRESH ist_tab .
    MOVE 'SAVE'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.

  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA' OR       "+002
     prev_okcode = 'CHAN' OR
    prev_okcode = 'DISP'.
    MOVE  'RESET'  TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DELE' .
    MOVE 'RESET'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'DELE' AND ok_code = 'DELT'.
    MOVE 'DELE'    TO  wa_tab-fcode  .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.
  IF prev_okcode = 'CHAN'.
    IF g_reset  = 0.
      MOVE 'RESET'   TO  wa_tab-fcode .
      APPEND wa_tab  TO  ist_tab      .
      MOVE 'DELT'    TO  wa_tab-fcode .
      APPEND wa_tab  TO  ist_tab      .
    ENDIF.
  ENDIF.
  IF  zmm_emdhdr-ebeln IS INITIAL.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'    TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'ME43'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ELSE.
  ENDIF.
  IF prev_okcode = 'REST'.
    MOVE 'SAVE'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
    MOVE 'DELT'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab      .
  ENDIF.

  IF ( zmm_emdhdr-trans = 'TFS' OR  zmm_emdhdr-trans = 'EMD' ) AND NOT
zmm_emdhdr-ebeln IS INITIAL .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'   TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
  ELSEIF (  zmm_emdhdr-trans = 'SDT' )
  AND NOT zmm_emdhdr-ebeln IS INITIAL.
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
ENDFORM.                    " MODIFY_ISTTAB
*&---------------------------------------------------------------------*
*&      Form  APPEND_ISTTAB_100
*&---------------------------------------------------------------------*
*      Append Function codes into table ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_100.
*&--> To Enable/Disable Icons in Application Tool bar

  REFRESH ist_tab .
  CLEAR wa_tab    .

  IF ok_code = 'CHAN' OR
     ok_code = 'DISP' OR
     ok_code = 'DELE' OR
     ok_code = 'REST' OR
     ok_code = 'BGLC' OR
     ok_code = 'AMEND'  .
    MOVE 'CHAN' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'CREA' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'ECREA' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DISP' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'REF' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'REST' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RELS' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'BGLC' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'AMEND' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELP' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ENDIF.
ENDFORM.                    " APPEND_ISTTAB_100
*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*       Save Header  Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data.
  CLEAR wa_emdhdr.
  CLEAR g_save_h .
  CLEAR g_save_i .
  DATA: l_bstyp LIKE ekko-bstyp.
  IF g_sc_ans = '1'  OR prev_okcode = 'CREA'.
*&--> Check Key Fields before Save.
    PERFORM check_key.
    wa_emdhdr-crby = sy-uname .
    wa_emdhdr-cron = sy-datum .
* Begin of <RD1K963113>
    IF prev_okcode = 'CHAN'.
      wa_emdhdr-chby = sy-uname .
      wa_emdhdr-chon = sy-datum .
    ENDIF.
* End of <RD1K963113>
*&--> Update Document Category and Status at Header Level.
    IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN'.
      IF zmm_emdhdr-trans = 'TFS'  OR zmm_emdhdr-trans = 'EMD' .
        MOVE  'A' TO  wa_emdhdr-bstyp  .
      ELSEIF   zmm_emdhdr-trans = 'SDT' .
        CLEAR l_bstyp .

        SELECT SINGLE bstyp FROM ekko INTO l_bstyp
          WHERE ebeln = zmm_emdhdr-ebeln.
        MOVE  l_bstyp TO wa_emdhdr-bstyp .

*+007 : Start
        MOVE zmm_emdhdr-loa_no         TO wa_emdhdr-loa_no.
        MOVE zmm_emdhdr-loa_dt         TO wa_emdhdr-loa_dt.
        MOVE zmm_emdhdr-sd_pbg_dt      TO wa_emdhdr-sd_pbg_dt.
        MOVE zmm_emdhdr-sd_pbg_rcpt_dt TO wa_emdhdr-sd_pbg_rcpt_dt.
        MOVE zmm_emdhdr-apprv_chk      TO wa_emdhdr-apprv_chk.

        IF zmm_emdhdr-apprv_chk = 'Y'.
          MOVE zmm_emdhdr-apprv_by       TO wa_emdhdr-apprv_by.
          MOVE zmm_emdhdr-apprv_on       TO wa_emdhdr-apprv_on.
          MOVE zmm_emdhdr-remarks        TO wa_emdhdr-remarks.
        ENDIF.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ENDIF.

        ENDIF.
*+007 : End

      ENDIF.
    ENDIF.
*&--<
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.       "+002

*+007 : Start
      IF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'SDT'.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ELSE.

            MOVE 'N'  TO  wa_emdhdr-status .

          ENDIF.

        ELSE.

          MOVE 'N'  TO  wa_emdhdr-status .

        ENDIF.

      ELSE.

*+007 : End

        MOVE 'N'  TO  wa_emdhdr-status .

      ENDIF.                                        "+007

    ELSEIF prev_okcode = 'CHAN'.
**---------- Update  Header Level Status -----------------------*

*+007 : Start
      IF zmm_emdhdr-trans = 'SDT'.

        IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
           NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

          IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'N'.

            MOVE '0'  TO  wa_emdhdr-status .

          ELSE.

            PERFORM update_header_status .
            MOVE g_h_status  TO  wa_emdhdr-status .
            CLEAR g_h_status.

          ENDIF.

        ELSE.

          PERFORM update_header_status .
          MOVE g_h_status  TO  wa_emdhdr-status .
          CLEAR g_h_status.

        ENDIF.

      ELSE.
*+007 : End
        PERFORM update_header_status .
        MOVE g_h_status  TO  wa_emdhdr-status .
        CLEAR g_h_status.
      ENDIF. "+007

    ENDIF.
    MOVE zmm_emdhdr-co_code  TO  wa_emdhdr-co_code  .
    MOVE zmm_emdhdr-currency TO  wa_emdhdr-currency .
    MOVE zmm_emdhdr-place    TO  wa_emdhdr-place    .
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.       "+002
      MOVE g_docno             TO  wa_emdhdr-docno    .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno             TO  wa_emdhdr-docno    .
    ENDIF.
    MOVE g_amount            TO  wa_emdhdr-amount   .
    MOVE zmm_emdhdr-trans    TO  wa_emdhdr-trans    .
    MOVE zmm_emdhdr-ebeln    TO  wa_emdhdr-ebeln    .
    MOVE g_ekgrp             TO  wa_emdhdr-ekgrp    .
***SRM Changes  +002
    IF zmm_emdhdr-vendorno IS INITIAL.
      MOVE g_vcode            TO  wa_emdhdr-vendorno .
    ELSE.
      MOVE zmm_emdhdr-vendorno  TO  wa_emdhdr-vendorno .
      g_vcode =  zmm_emdhdr-vendorno .
    ENDIF.
***End of SRM Change
    MOVE g_tendno            TO  wa_emdhdr-tenderno .
    MOVE zmm_emdhdr-ebidno   TO  wa_emdhdr-ebidno .         "+002

    IF prev_okcode = 'CREA'.
      MOVE g_docno             TO  wa_emdhdr-docno    .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno             TO  wa_emdhdr-docno    .
* Begin of <RD1K963113>
      wa_emdhdr-chby = sy-uname .
      wa_emdhdr-chon = sy-datum .
* End of <RD1K963113>
    ENDIF.
*-------------------------------------------------------------*
** SRM Changes
    IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
      MOVE 'SRM' TO wa_emdhdr-trtyp.
    ELSEIF prev_okcode = 'CREA' OR g_ttype = 'R3'.
      MOVE 'R3' TO wa_emdhdr-trtyp.
    ENDIF.
*-------------------------------------------------------------*

    MODIFY  zmm_emdhdr FROM wa_emdhdr.
    PERFORM pass_to_srm.
    IF sy-subrc = 0.
      g_save_h = 0.
    ELSE.
      g_save_h = 1.
    ENDIF.
    IF prev_okcode = 'CHAN'.
      wa_emdhdr-docno = g_idocno.
      SORT ist_del_emddtl BY item_no .
    ENDIF.
    REFRESH: ist_del_emddtl .
    IF NOT ist_emddtl01 IS INITIAL.
      MODIFY zmm_emddtl FROM TABLE ist_emddtl01.
      IF sy-subrc = 0.
        g_save_i = 0.
      ELSE.
        g_save_i = 1.
      ENDIF.
    ELSE.
      g_save_i = 1.
    ENDIF.
  ENDIF.


ENDFORM.                    " save_data
*&---------------------------------------------------------------------*
*&      Form  insert_itemdtl
*&---------------------------------------------------------------------*
*    Insert Item Data into Internal Table ist_emddtl01
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM insert_itemdtl.
  REFRESH ist_emddtl01.
  CLEAR  wa_emddtl01  .
  CLEAR  g_amount .
  DATA : l_bstyp .
  "commented by lipsy on 09.08.2012 for addition of etender
                                                            "RD1K981279
*  IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN'.
                                                            "RD1K981279
  "end of comment by lipsy on 09.08.2012 for addition of etender
  ""added by lipsy on 09.08.2012 for addition of etender
                                                            "RD1K981279
  IF prev_okcode =  'CREA' OR  prev_okcode = 'CHAN' OR prev_okcode =  'ECREA'.
                                                            "RD1K981279
    "end of addition  by lipsy on 09.08.2012 for addition of etender
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD' .
      MOVE  'A' TO  wa_emdhdr-bstyp  .
    ELSEIF  zmm_emdhdr-trans = 'SDT' .
      SELECT SINGLE bstyp FROM ekko INTO l_bstyp
       WHERE ebeln = zmm_emdhdr-ebeln.
      MOVE l_bstyp  TO wa_emdhdr-bstyp .
    ENDIF.
  ENDIF.
  IF prev_okcode =  'CREA' .
    MOVE 'N'  TO  wa_emdhdr-status .
  ENDIF.
  LOOP AT ist_emddtl INTO wa_emddtl .
    g_amount  = g_amount + wa_emddtl-amount    .
    MOVE-CORRESPONDING wa_emddtl TO    wa_emddtl01           .
    IF wa_emddtl-status IS INITIAL.
      MOVE 'N'                  TO    wa_emddtl01-status    .
    ELSE.
      MOVE wa_emddtl-status     TO   wa_emddtl01-status  .
    ENDIF.
    MOVE g_docno                 TO    wa_emddtl01-docno     .
    MOVE zmm_emdhdr-trans        TO    wa_emddtl01-trans     .
    MOVE zmm_emdhdr-ebeln        TO    wa_emddtl01-ebeln     .
    MOVE zmm_emdhdr-vendorno     TO    wa_emddtl01-vendno    .
    MOVE zmm_emdhdr-tenderno     TO    wa_emddtl01-tendno    .
    MOVE wa_emdhdr-bstyp         TO    wa_emddtl01-bstyp      .
    MOVE space                   TO    wa_emddtl01-fi_parkno  .
    MOVE zmm_emdhdr-currency     TO    wa_emddtl01-currency   .
    MOVE zmm_emdhdr-ebidno       TO    wa_emddtl01-ebidno . "+002
* Begin of <RD1K973923> on 20102010
    MOVE zmm_emdhdr-co_code      TO    wa_emddtl01-co_code .
* End of <RD1K973923>
    wa_emddtl01-crby = sy-uname .
    wa_emddtl01-cron = sy-datum .
*-------------------------------------------------------------*
** SRM Changes +001
    IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
      MOVE 'SRM' TO wa_emddtl01-trtyp.
    ELSEIF prev_okcode = 'CREA'.
      MOVE 'R3' TO wa_emddtl01-trtyp.
    ENDIF.
*-------------------------------------------------------------*
    IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.
      MOVE g_docno               TO    wa_emddtl01-docno   .
    ELSEIF prev_okcode = 'CHAN'.
      MOVE g_idocno              TO    wa_emddtl01-docno  .
    ENDIF.
    IF prev_okcode = 'CHAN'.
      wa_emddtl01-chby = sy-uname.
      wa_emddtl01-chon = sy-datum.
      wa_emddtl01-docno = g_idocno.
    ENDIF.
    APPEND  wa_emddtl01 TO ist_emddtl01 .
  ENDLOOP.
ENDFORM.                    " insert_itemdtl
*&---------------------------------------------------------------------*
*&      Form  calc_total_amount
*&---------------------------------------------------------------------*
*      Claculate  Total Amount at Header Level

*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM calc_total_amount.
  CLEAR wa_emddtl.
  CLEAR g_amount .
  LOOP AT ist_emddtl INTO wa_emddtl.
    g_amount =  g_amount +  wa_emddtl-amount .
  ENDLOOP.
  MOVE g_amount TO zmm_emdhdr-amount  .
  MOVE g_amount TO wa_emdhdr-amount   .
  MOVE zmm_emdhdr-place TO wa_emdhdr-place .
ENDFORM.                    " calc_total_amount
*&---------------------------------------------------------------------*
*&      Form  GET_DONONO
*&---------------------------------------------------------------------*
*      Get Document no using number range Obj. ZMM_EMDDOC.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_docno.
  CLEAR g_docno .

  IF g_okhdr IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZMM_EMDDOC'
        quantity                = '1'
        toyear                  = sy-datum+0(4)
      IMPORTING
        number                  = g_docno
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_DOCNO
*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRM
*&---------------------------------------------------------------------*
*    Popup Message When 'SAVE' or 'CHANGE'.
*----------------------------------------------------------------------*
*      -->P_TEXT_005  text
*      -->P_TEXT_004  text
*      -->P_ENDIF  text
*----------------------------------------------------------------------*
FORM popup_confirm USING    p_text_01
                            p_text_02 .

  CLEAR g_ans.
  " Begin of <RD1K960036>.
*  call function 'POPUP_TO_CONFIRM_STEP'
*       exporting
*            defaultoption = 'Y'
*            textline1     = p_text_02
*            titel         = p_text_01
*            start_column  = 20
*            start_row     = 6
*       importing
*            answer        = g_ans.
  DATA : l_answer(1) TYPE c.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = p_text_01
      text_question  = p_text_02
      default_button = '1'
      start_column   = 20
      start_row      = 6
    IMPORTING
      answer         = l_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    CASE l_answer.
      WHEN '1'.
        MOVE 'J' TO g_ans.
      WHEN '2'.
        MOVE 'N' TO g_ans.
    ENDCASE.
  ENDIF.
  " End of <RD1K960036>.
ENDFORM.                    " POPUP_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       Get Data for Display,Change & Delete
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.
  REFRESH  ist_emddtl    .
  CLEAR :  ist_emddtl    ,
           wa_emdhdr     ,
           wa_emddtl01   ,
           g_status      ,
           g_reset       ,
           g_dansw       ,
           g_reset       .
  IF NOT zmm_emdhdr-docno IS INITIAL.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
*&--> Display Status using variable g_status.
      IF wa_emdhdr-status = 'N'.
        g_status  = 'Created'.
      ELSEIF wa_emdhdr-status = 'D'.
        IF prev_okcode = 'DELE'.
          MESSAGE e425(zmm).
        ELSE.
          g_status  = 'Deleted'.
        ENDIF.
      ELSE.
        g_reset   = 0.
      ENDIF.
*&--<
      IF wa_emdhdr-status = 'D'.
        MESSAGE w416(zmm) WITH  wa_emdhdr-docno.
        g_reset = 1.
      ENDIF.
*&-----> Get Place NAme from table zmm_location
      SELECT SINGLE locds FROM zmm_location INTO g_locname
             WHERE loccd  = wa_emdhdr-place .
*&-------> Get Item Details  based on Docno and transaction.
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr .
      SELECT * FROM zmm_emddtl INTO TABLE ist_emddtl01
               WHERE docno = wa_emdhdr-docno  AND
                     trans = wa_emdhdr-trans  ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
*&--> Append EMD Item data into table control internal table ist_emddtl.
        LOOP AT ist_emddtl01 INTO wa_emddtl01.
          MOVE-CORRESPONDING wa_emddtl01 TO wa_emddtl.
          APPEND wa_emddtl TO ist_emddtl.
        ENDLOOP.
*&--<
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  save_change_popup
*&---------------------------------------------------------------------*
*     Popup message when Changes made
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_change_popup USING p_quest.
  DATA lv_doc_info TYPE zmm_emdhdr.
  DATA lv_popup_text TYPE string.

"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*  lv_doc_info = p_quest.
     lv_doc_info = p_quest.     "#EC CI_FLDEXT_OK[2610650]
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  CLEAR g_sc_ans.

  IF lv_doc_info-trans = 'TFS'.
lv_popup_text = `You are going to Exempt Tender Fee for Vendor` && ` ` && lv_doc_info-vendorno && ` ` && g_vname && ` ` && `for        E-Tender` && ` ` && lv_doc_info-ebidno && `.` && ` ` &&
                `Tender Fees Once Waived Cannot be, Reverted back !.` && ` ` && `Are you Sure to Exempt ?.`.
  ELSE.
    lv_popup_text = text-084.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-050
      text_question  = lv_popup_text
      text_button_1  = 'Yes'
      icon_button_1  = ' '
      text_button_2  = 'No'
      default_button = '1'
      start_column   = 25
      start_row      = 6
    IMPORTING
      answer         = g_sc_ans.
ENDFORM.                    " save_change_popup
*&---------------------------------------------------------------------*
*&      Form  CHECK_KEY
*&---------------------------------------------------------------------*
*       Check Key Fields before Save.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_key.
  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-ebeln    IS  INITIAL   OR
       zmm_emdhdr-trans    IS  INITIAL   OR
       zmm_emdhdr-co_code  IS  INITIAL   OR
       zmm_emdhdr-currency IS  INITIAL.
      MESSAGE e476(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_KEY
*&---------------------------------------------------------------------*
*&      Form  mark_for_delete
*&---------------------------------------------------------------------*
*     Mark for Deletion if the Status of the Document is 'N'.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_for_delete.

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0 AND                                 " Tender Document
     wa_emdhdr-ebidno IS INITIAL AND
     wa_emdhdr-tenderno IS NOT INITIAL.

    IF wa_emdhdr-status = 'N'.
      UPDATE zmm_emdhdr
      SET status = 'D'
      WHERE docno = wa_emdhdr-docno  AND
            trans = wa_emdhdr-trans  .

      IF sy-subrc = 0.
        UPDATE zmm_emddtl
           SET status = 'D'
           WHERE docno = wa_emdhdr-docno  AND
            trans = wa_emdhdr-trans  .
        IF sy-subrc = 0.
          PERFORM clear_screen_0105.
          MESSAGE i415(zmm) WITH g_idocno.
          LEAVE TO  SCREEN '0100'.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e479(zmm).
    ENDIF.
  ENDIF.

*ELSEIF SY-SUBRC = 0 AND                           " ETender Document
*       WA_EMDHDR-EBIDNO IS NOT INITIAL AND
*       WA_EMDHDR-TENDERNO IS INITIAL.
** Start of Change - By Manikandan
*  SELECT SINGLE LOGSYS FROM ZMM_LOGSYS INTO L_LOGSYS
*                WHERE  APPL = 'SRM'.
*
*  IF L_LOGSYS IS NOT INITIAL AND
*     WA_EMDHDR-EBIDNO IS NOT INITIAL AND
*     WA_EMDHDR-VENDORNO IS NOT INITIAL.
*
*    CALL FUNCTION 'Z_UPDATE_TDPD_INDI' DESTINATION L_LOGSYS
*      EXPORTING
*        IV_BID_NO            = WA_EMDHDR-EBIDNO               "'char10
*        IV_VENDOR_NO         = WA_EMDHDR-VENDORNO             "'char10
*      IMPORTING
*        EV_SUCCESS           = LV_SRM_UPDATE_STATUS
*      EXCEPTIONS
*        TENDER_NOT_PUBLISHED = 1
*        TF_DEADLINE_REACHED  = 2
*        OTHERS               = 3.
*  ENDIF.
*
*  IF LV_SRM_UPDATE_STATUS EQ ABAP_TRUE. " Update in SRM TDPD Table is success, so can update ECC Tables now.
*    IF WA_EMDHDR-STATUS = 'N'.
*      UPDATE ZMM_EMDHDR
*      SET STATUS = 'D'
*      WHERE DOCNO = WA_EMDHDR-DOCNO  AND
*            TRANS = WA_EMDHDR-TRANS  .
*      IF SY-SUBRC = 0.
*        UPDATE ZMM_EMDDTL
*           SET STATUS = 'D'
*           WHERE DOCNO = WA_EMDHDR-DOCNO  AND
*            TRANS = WA_EMDHDR-TRANS  .
*        IF SY-SUBRC = 0.
*          PERFORM CLEAR_SCREEN_0105.
*          MESSAGE I415(ZMM) WITH G_IDOCNO.
*          LEAVE TO  SCREEN '0100'.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      MESSAGE E479(ZMM).
*    ENDIF.
*  ELSEIF LV_SRM_UPDATE_STATUS EQ 'E'. " Response Already Created by the Vendor for the ETender Document
*    MESSAGE E009(ZMM_EMD) WITH G_IDOCNO.
*  ELSEIF LV_SRM_UPDATE_STATUS NE ABAP_TRUE. "Please Check the Status on both ECC & SRM System
*    PERFORM CLEAR_SCREEN_0105.
*    MESSAGE I010(ZMM_EMD) WITH G_IDOCNO.
*    LEAVE TO  SCREEN '0100'.
*  ENDIF.
** End of Change   - By Manikandan
*ENDIF.
ENDFORM.                    " mark_for_delete
*&---------------------------------------------------------------------*
*&      Form  popup_for_delete
*&---------------------------------------------------------------------*
*     Popup Message for Delete Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_for_delete.
  CLEAR g_dansw.
  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = text-007
      titel         = text-008
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_dansw.
ENDFORM.                    " popup_for_delete
*&---------------------------------------------------------------------*
*&      Form  check_rfq
*&---------------------------------------------------------------------*
*       Check RFQ number and Currency.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfq.
  CLEAR wa_emdhdr .
  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE EBELN = ZMM_EMDHDR-EBELN AND CURRENCY = ZMM_EMDHDR-CURRENCY
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
    MESSAGE w419(zmm) WITH wa_emdhdr-ebeln wa_emdhdr-currency.
  ENDIF.
ENDFORM.                    " check_rfq
*&---------------------------------------------------------------------*
*&      Form  check_loc
*&---------------------------------------------------------------------*
*       Check Location
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_loc.
  DATA wa_loc  LIKE zmm_location.
*-------- Check location code in table zmm_location.
  SELECT SINGLE * FROM zmm_location INTO wa_loc
            WHERE loccd = zmm_emdhdr-place  AND
                  loccg = 'TF' .   "Tender Fee

  IF sy-subrc NE 0.
    MESSAGE e420(zmm).
  ENDIF.
ENDFORM.                    " check_loc
*&---------------------------------------------------------------------*
*&      Form  CHECK_VALID_INSTNO
*&---------------------------------------------------------------------*
*       Check for the Valid Instrument no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_valid_instno USING p_ebeln p_instno.

  SELECT * FROM ZMM_EMDDTL UP TO 1 ROWS

 WHERE EBELN = P_EBELN AND INSTNO = P_INSTNO AND INST_TYPE = WA_TC105-INST_TYPE AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.                  "+007

  IF sy-subrc = 0.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'.
      MESSAGE e421(zmm) WITH p_ebeln zmm_emddtl-docno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      MESSAGE e422(zmm) WITH p_ebeln zmm_emddtl-docno .
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_VALID_INSTNO
*&---------------------------------------------------------------------*
*&      Form  CHECK_INST_TYPE
*&---------------------------------------------------------------------*
*      Check Instrurment Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_type USING p_inst_type.
* +004 Payment Gateway SRM Changes.
  IF prev_okcode NE 'ECREA' AND  p_inst_type = 'OP' .
*Begin of <RD1K963111>
    CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
    MESSAGE e589(zmm).
  ENDIF.

  IF prev_okcode = 'ECREA' AND p_inst_type = 'OP'.
    IF zmm_emdhdr-trans NE 'TFS'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e590(zmm).
    ENDIF.
  ENDIF.
*--+004
*&--> Instrument IP is not allowed for EMD AND SD

  IF zmm_emdhdr-trans = 'EMD' OR zmm_emdhdr-trans = 'SDT'.
    IF p_inst_type = 'IP'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e423(zmm) WITH zmm_emdhdr-trans .
    ENDIF.
  ENDIF.
*---- Instrument type BG/LC is not allowed in case of Tender Fee
  IF zmm_emdhdr-trans = 'TFS'.
    IF p_inst_type = 'BG' OR
       p_inst_type = 'LC'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e550(zmm).
    ENDIF.
  ENDIF.

  IF zmm_emdhdr-trans =  'EMD' OR
     zmm_emdhdr-trans = 'TFS'.
    IF p_inst_type = 'IV'.
*Begin of <RD1K963111>
      CLEAR wa_tc105-inst_type.
*End of <RD1K963111>
      MESSAGE e481(zmm).
    ENDIF.
  ENDIF.
*Begin of <RD1K963111>
  IF prev_okcode = 'ECREA' AND wa_tc105-inst_type = 'IP'.
    CLEAR wa_tc105-inst_type.
    MESSAGE e865(zmm).
  ENDIF.
*&--<
  DATA lv_index TYPE i.
  DATA lv_ins_type TYPE zmm_emddtl-inst_type.
  DATA lv_mesg TYPE string.
  DESCRIBE TABLE ist_emddtl LINES lv_index.
  IF lv_index > 1.
    READ TABLE ist_emddtl INTO wa_emddtl INDEX 1.
    lv_ins_type = wa_emddtl-inst_type.
    IF lv_ins_type NE wa_tc105-inst_type.
      IF lv_ins_type = 'CC'.
        IF wa_tc105-inst_type EQ 'CC' OR wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'DD'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.
      ELSEIF lv_ins_type = 'BC'.
        IF wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'CC' OR wa_tc105-inst_type EQ 'DD'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.

      ELSEIF lv_ins_type = 'DD'.
        IF wa_tc105-inst_type EQ 'DD' OR wa_tc105-inst_type EQ 'BC' OR wa_tc105-inst_type EQ 'CC'.
        ELSE.
          MESSAGE i426(zmm).
        ENDIF.

      ELSEIF lv_ins_type = 'IP' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ELSEIF lv_ins_type = 'BG' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ELSEIF lv_ins_type = 'LC' AND lv_ins_type NE wa_tc105-inst_type.
        MESSAGE i426(zmm).

      ENDIF.
    ENDIF.
  ENDIF.
*End of <RD1K963111>
* End of modification by SAB_SARVANAN on 09/04/2009 - RD1K963111
ENDFORM.                    " CHECK_INST_TYPE
*&---------------------------------------------------------------------*
*&      Form  popup_for_reset
*&---------------------------------------------------------------------*
*       Popup for Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_for_reset.
  CLEAR g_ransw.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = text-011
      titel         = text-027
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_ransw.
ENDFORM.                    " popup_for_reset
*&---------------------------------------------------------------------*
*&      Form  RESET_DOCU
*&---------------------------------------------------------------------*
*       Update Status /Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_docu.
  DATA: l_ok_h,
        l_ok_i .
  UPDATE zmm_emdhdr
     SET status  = 'N'
     WHERE docno = g_idocno .

  IF  sy-subrc = 0.
    l_ok_h  = 0.
  ELSE.
    l_ok_h  = 1.
  ENDIF.
*----------------------------------------------------------------------*
*  Reset Item Document status   and Fiparkno and date                  *
*----------------------------------------------------------------------*
  UPDATE zmm_emddtl
       SET status  = 'N'
           fi_parkno = space
           fi_parkdt = space
       WHERE docno = g_idocno .

  IF sy-subrc = 0.
    l_ok_i = 0.
  ELSE.
    l_ok_i = 1.
  ENDIF.

  IF l_ok_h = 0 AND l_ok_i = 0.
    g_reset  = 0.
    MESSAGE  i424(zmm) .
    PERFORM clear_screen_0105.
    LEAVE TO SCREEN '0100'.
  ENDIF.
ENDFORM.                    " RESET_DOCU
*&---------------------------------------------------------------------*
*&      Form  copy_line
*&---------------------------------------------------------------------*
*     Copy Line Item Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_line.
  REFRESH : ist_emddtl_t01 .
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    MOVE space  TO wa_emddtl-sel .
    APPEND  wa_emddtl  TO ist_emddtl_t01 .
    wa_emddtl-sel = space.
    MODIFY ist_emddtl FROM wa_emddtl.
  ENDLOOP.
  CLEAR ok_code.
ENDFORM.                    " copy_line
*&---------------------------------------------------------------------*
*&      Form  PASTE_LINE
*&---------------------------------------------------------------------*
*       Paste Selected Line Item.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM paste_line.

  DATA: l_line LIKE zmm_emddtl-item_no.
  DESCRIBE TABLE ist_emddtl LINES l_line .
  LOOP AT ist_emddtl_t01 INTO wa_emddtl  .
    l_line = l_line + 1.
    MOVE l_line  TO  wa_emddtl-item_no.
    MOVE 'N' TO wa_emddtl-status .
    MOVE space TO wa_emddtl-sel   .
    APPEND  wa_emddtl  TO ist_emddtl  .
  ENDLOOP.

  DESCRIBE TABLE ist_emddtl LINES l_line .
  tc_105-lines = l_line .
  REFRESH ist_emddtl_t01.
  CLEAR ok_code.
ENDFORM.                    " PASTE_LINE
*&---------------------------------------------------------------------*
*&      Form  check_valid_instno_CHNG
*&---------------------------------------------------------------------*
*      Check Valid Instrument in Change Mode
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_EBELN  text
*      -->P_WA_TC105_INSTNO  text
*----------------------------------------------------------------------*
FORM check_valid_instno_chng USING    p_ebeln
                                      p_instno.

  SELECT * FROM ZMM_EMDDTL UP TO 1 ROWS

 WHERE EBELN = P_EBELN AND INSTNO = P_INSTNO AND DOCNO <> G_IDOCNO AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.                      "+007

  IF sy-subrc = 0.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'.
      MESSAGE e421(zmm) WITH p_ebeln zmm_emddtl-docno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      MESSAGE e422(zmm) WITH p_ebeln zmm_emddtl-docno.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_valid_instno_CHNG
*&---------------------------------------------------------------------*
*&      Form  check_inst_group
*&---------------------------------------------------------------------*
*    Check Instrurment Group
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_group.
  DATA: ist_emddtl_temp LIKE TABLE OF wa_emddtl.
*&--> Check Whether Instrument Type entered is from same Group or not
*&--> G1- DD,BC,CC G2-LC , G3-BG , G4-IP

**** check for Instrument type. This logic is laid for the reason
***** that no
***** (1) If Instrument type is DD then only BC and CC is permitted
***** (2) If Instrument is BG then only BG is permitted.
****  (3) IF Instrument is IV then only IV is permitted.

** New Logic for Instrument Group added on 09.03.05 *********


** End of Addition ******************************************

  DATA: ist_instgrp TYPE TABLE OF zmm_emddtl-inst_type.
  DATA:  wa_instgrp TYPE zmm_emddtl-inst_type.
  DATA: l_inst(20).
  DATA: l_fd  .
  REFRESH ist_instgrp.
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_instgrp  = wa_emddtl-inst_type.
    APPEND wa_instgrp  TO ist_instgrp.
  ENDLOOP.
  SORT ist_instgrp .
  DELETE ADJACENT DUPLICATES FROM ist_instgrp .
  LOOP AT ist_instgrp INTO wa_instgrp .
    CONCATENATE  l_inst
   wa_instgrp  INTO l_inst .
  ENDLOOP.

  IF NOT l_inst IS INITIAL.

    IF l_inst  = 'BCCCDD'  OR
       l_inst  = 'BCCC'    OR
       l_inst  = 'CCDD'    OR
       l_inst  = 'CCBC'    OR
       l_inst  = 'BCDD'    OR
       l_inst  = 'DD'      OR
       l_inst  = 'CC'      OR
       l_inst  = 'BC'      OR
       l_inst  = 'BG'      OR
       l_inst  = 'IP'      OR
       l_inst  = 'IV'      OR
       l_inst   = 'LC' .
      l_fd = 'X'.
      g_error = 1 .
    ELSE.
      g_error = 0.
      MESSAGE i426(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_inst_group
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_110
*&---------------------------------------------------------------------*
*       Save Data in screen 110. REFUND/FORFEIT/EMD-SD CONVERSION
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data_110.
  g_save_h = 1.
  g_save_i = 1.

*  data l_status .
  DATA: l_tot_item LIKE sy-tabix.
  DATA: ist_emdref_tmp TYPE TABLE OF  zmm_emdref.
* Begin of <RD1K963111>
  DATA: its_emddtl TYPE TABLE OF zmm_emddtl,
        wa_emddtl_01 TYPE zmm_emddtl.
* End of <RD1K963111>
  IF sy-subrc = 0.
    g_save_h = 0.
  ELSE.
    g_save_h = 1.
  ENDIF.
*&--<
  l_tot_item  = 1.
  MOVE-CORRESPONDING zmm_emdref TO wa_emdref   .
  IF g_docstat = 'C'.
    zmm_emdhdr-trans = 'SDT'.
  ENDIF.
  MOVE zmm_emdhdr-docno  TO wa_emdref-refdoc   .
  MOVE zmm_emdhdr-trans  TO wa_emdref-trans    .
  IF  g_docstat =  'C'.
    MOVE zmm_emdref-ebeln  TO wa_emdref-ebeln    .
  ELSE.
    MOVE zmm_emdhdr-ebeln  TO wa_emdref-ebeln    .
  ENDIF.
  IF NOT  g_ebeln IS INITIAL .
    MOVE g_ebeln  TO wa_emdref-ebeln    .
  ENDIF.
* Begin of <RD1K963111>
  SELECT * FROM zmm_emddtl INTO TABLE its_emddtl WHERE docno = zmm_emdhdr-docno AND ebeln = wa_emdref-ebeln.
  LOOP AT its_emddtl INTO wa_emddtl_01.
    IF g_docstat = 'R'.
      wa_emddtl_01-refdt = sy-datum.
    ELSEIF g_docstat = 'C'.
      wa_emddtl_01-candt = sy-datum.
    ELSEIF g_docstat = 'F'.
      wa_emddtl_01-fofdt = sy-datum.
    ENDIF.
    MODIFY zmm_emddtl FROM wa_emddtl_01.
  ENDLOOP.
* End of <RD1K963111>
  MOVE zmm_emdhdr-docno  TO wa_emdref-refdoc   .
  MOVE g_docstat         TO wa_emdref-status   .
  MOVE sy-uname          TO wa_emdref-rfccrby  .
  MOVE sy-datum          TO wa_emdref-rfccron  .
  MOVE g_docno           TO wa_emdref-docno    .
  MOVE l_tot_item        TO wa_emdref-itemno   .
  MOVE space             TO wa_emdref-fi_parkno .
  MOVE zmm_emdhdr-currency TO wa_emdref-currency.
  MODIFY zmm_emdref FROM wa_emdref.
* Begin of <RD1K963111>
  zmm_emdhdr-ref_doc = g_docno.
  MODIFY zmm_emdhdr.
* End of <RD1K963111>
  IF sy-subrc NE 0.
    g_save_h = 1.
    MESSAGE e427(zmm).
  ELSE.
    g_save_h = 0.
  ENDIF.
ENDFORM.                    " SAVE_DATA_110
*&---------------------------------------------------------------------*
*&      Form  CLEAR_GLOBAL_110
*&---------------------------------------------------------------------*
*      Clear Global Variable
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_110.
  CLEAR:
         wa_emdhdr.
  CLEAR: zmm_emdhdr ,
         zmm_emdref .
  CLEAR : g_status,
          g_lines .

  CLEAR g_locname.

  CLEAR ist_tab .
  g_ref = 1.
  CLEAR:
         g_ans,
         g_sc_ans ,
         g_rfc    ,
         g_rfc_chk.
  CLEAR: g_save_h ,
         g_save_i .
  CLEAR: g_doccat .
  CLEAR: g_balamt .
  CLEAR: g_tot_ref.
  g_okhdr = 1.
  CLEAR g_docno .
ENDFORM.                    " CLEAR_GLOBAL_110
*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCNO
*&---------------------------------------------------------------------*
*       Validate input Docno
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_docno.
  DATA :  wa_emdhdr_tmp  LIKE zmm_emdhdr,
          wa_emdref_t01  LIKE zmm_emdref.
  CLEAR g_ref.
  CLEAR wa_emdhdr .

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_T02 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc NE 0.
    SELECT * FROM ZMM_EMDREF
 INTO WA_EMDREF_T01 UP TO 1 ROWS WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc NE 0.
      g_ref =  1.
      MESSAGE e411(zmm).
    ELSE.

      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_TMP UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_T01-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      MOVE wa_emdref_t01-amount TO wa_emdhdr_tmp-amount.
      MOVE  wa_emdref_t01-trans TO wa_emdhdr_tmp-trans .
      MOVE  zmm_emdhdr-docno           TO wa_emdhdr_tmp-docno.
      MOVE-CORRESPONDING wa_emdhdr_tmp TO zmm_emdhdr.
      g_ref = 0.
    ENDIF.
  ELSE.
    g_ref = 0.
    IF wa_emdhdr_t02-status = 'O'.
      MESSAGE e230(zmm).
    ENDIF.
    MOVE wa_emdhdr_t02-currency       TO zmm_emdref-currency .
  ENDIF.

  IF zmm_emdhdr-trans = 'TFS' AND zmm_emdref-rscode = '120' AND sy-dynnr = '0110'.
    zmm_emdref-amount = zmm_emdhdr-amount.
  ENDIF.


ENDFORM.                    " CHECK_DOCNO
*&---------------------------------------------------------------------*
*&      Form  popup_conf_110
*&---------------------------------------------------------------------*
*   Popup Confirmation before Refund/Forfeit/EMD-SD Conversion
*----------------------------------------------------------------------*
*      -->P_G_TITLE  text
*      -->P_G_TEXT  text
*----------------------------------------------------------------------*
FORM popup_conf_110 USING     p_titel p_text.
  CLEAR g_rfc.

  CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
    EXPORTING
      defaultoption = 'Y'
      textline1     = p_text
      titel         = p_titel
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = g_rfc.
ENDFORM.                    " popup_conf_110
*&---------------------------------------------------------------------*
*&      Form  append_isttab_110
*&---------------------------------------------------------------------*
*     Append Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_110.
  IF g_ref = 1.
    REFRESH ist_tab  .
    MOVE 'SAVE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ELSEIF g_ref = 0.
    REFRESH ist_tab  .
    MOVE 'CHNG'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'CRET'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'DISP'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'DELE'   TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'UNDEL'  TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
    MOVE 'SUBFI'  TO  wa_tab-fcode.
    APPEND wa_tab TO  ist_tab  .
  ENDIF.

  IF ok_code = 'CRET' AND g_ref = 0.
    REFRESH: ist_tab.
    MOVE 'CHNG'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'CRET'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DISP'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'UNDEL'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SUBFI'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ELSEIF ok_code = 'CRET' AND g_ref = 1.
    REFRESH: ist_tab.
    MOVE 'CHNG'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'CRET'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DISP'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'UNDEL'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SUBFI'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ELSEIF ok_code = 'CHNG'.
    REFRESH ist_tab .
    MOVE 'CRET' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
  ENDIF.

  IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL.
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'HEAD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
  ENDIF.
*&--<
ENDFORM.                    " append_isttab_110
*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*       Get Vendor name
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_vendor_name.
  CLEAR wa_lfa1.

  SELECT SINGLE * FROM lfa1 INTO wa_lfa1
             WHERE lifnr = zmm_emdhdr-vendorno.

  IF sy-subrc = 0.
    MOVE wa_lfa1-name1 TO g_vname.
  ENDIF.
ENDFORM.                    " GET_VENDOR_NAME
*&---------------------------------------------------------------------*
*&      Form  get_RFC_DOCNO
*&---------------------------------------------------------------------*
*      Get Document no for REFUND/FORFEIT/EMD-SD CONVERTION
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rfc_docno USING p_nr.

  CLEAR g_docno.
  IF g_okhdr IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = p_nr
        object                  = 'ZMM_EMDDOC'
        quantity                = '1'
        toyear                  = sy-datum+0(4)
      IMPORTING
        number                  = g_docno
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    " get_RFC_DOCNO
*&---------------------------------------------------------------------*
*&      Form  set_values
*&---------------------------------------------------------------------*
*      Populate Values in List Box
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_values.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_task_cd
      values = g_task_list.

ENDFORM.                    " set_values
*&---------------------------------------------------------------------*
*&      Form  append_isttab_115
*&---------------------------------------------------------------------*
*       Append F-code into internal table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_115.

  REFRESH  ist_tab   .
  IF prev_okcode = 'CRET' OR
     prev_okcode = 'CHNG' OR
     prev_okcode = 'DISP' OR
     prev_okcode = 'DELE' OR
     prev_okcode = 'UNDEL'.
    REFRESH  ist_tab .
    MOVE 'CRET'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'CHNG'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DISP'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'DELE'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD'   TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RESET'  TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'    TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
    MOVE 'ME43'    TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab    .
    MOVE 'ENMT'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE' .
    REFRESH  ist_tab .
    MOVE 'SAVE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'HEAD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'RFCD' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab  .
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'      TO  wa_tab-fcode .
    MOVE 'ME23N'      TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab.
    MOVE 'ENMT'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
    MOVE 'RESET'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF prev_okcode = 'UNDEL'.
    DELETE  ist_tab WHERE fcode = 'RESET'.
  ENDIF.
  IF g_rfc_chk = 1.
    REFRESH  ist_tab .
    MOVE 'DELE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'SAVE'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'HEAD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'RFCD'    TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'RESET'   TO   wa_tab-fcode.
    APPEND wa_tab  TO   ist_tab  .
    MOVE 'ME43'    TO   wa_tab-fcode .
    APPEND wa_tab  TO   ist_tab.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO   wa_tab-fcode .
    MOVE 'ME23N'    TO   wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO   ist_tab.
    MOVE 'ENMT'    TO   wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ELSEIF ( g_rfc_chk = 0 ) AND
    prev_okcode = 'DISP' OR    prev_okcode = 'UNDEL'.
    MOVE 'SAVE'   TO    wa_tab-fcode.
    APPEND wa_tab TO    ist_tab  .
    MOVE 'DELE'   TO    wa_tab-fcode.
    APPEND wa_tab TO    ist_tab  .
  ENDIF.

  IF g_rfc_chk = 0   AND
       prev_okcode = 'DELE'.
    REFRESH  ist_tab .
    MOVE 'SAVE'    TO  wa_tab-fcode.
    APPEND wa_tab  TO  ist_tab  .
    MOVE 'RESET'   TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
  IF ( zmm_emdhdr-trans = 'TFS' OR  zmm_emdhdr-trans = 'EMD' ) AND NOT
zmm_emdhdr-ebeln IS INITIAL .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'    TO  wa_tab-fcode .
     MOVE 'ME23N'   TO  wa_tab-fcode .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
    APPEND wa_tab  TO  ist_tab    .
  ELSEIF (  zmm_emdhdr-trans = 'SDT' )
  AND NOT zmm_emdhdr-ebeln IS INITIAL.
    MOVE 'ME43'      TO  wa_tab-fcode .
    APPEND wa_tab  TO  ist_tab.
  ENDIF.
ENDFORM.                    " append_isttab_115
*&---------------------------------------------------------------------*
*&      Form  change_docu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_docu.
  DATA : ist_cdpos TYPE TABLE OF cdpos WITH HEADER LINE .
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0105.
  SELECT * INTO TABLE ist_cdpos FROM cdpos WHERE objectid =
   wa_emdhdr-docno .
ENDFORM.                    " change_docu
*&---------------------------------------------------------------------*
*&      Form  save_chg_docu
*&---------------------------------------------------------------------*
*       Subroutine being used for saving change document iinformation
*       in CDPOS and CDHDR
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_chg_docu.

  DATA  : l_objectid LIKE cdhdr-objectid .
  DATA  : old_emdhdr LIKE zmm_emdhdr .
  DATA  : BEGIN OF l_place OCCURS 0 .
          INCLUDE STRUCTURE cdtxt.
  DATA  : END OF l_place .

  old_emdhdr = wa_emdhdr .
  wa_emdhdr-place = zmm_emdhdr-place .

  l_objectid = wa_emdhdr-docno .

  CALL FUNCTION 'ZPLACE_WRITE_DOCUMENT'
    EXPORTING
      objectid       = l_objectid
      tcode          = sy-tcode
      utime          = sy-uzeit
      udate          = sy-datum
      username       = sy-uname
      n_zmm_emdhdr   = wa_emdhdr
      o_zmm_emdhdr   = old_emdhdr
      upd_zmm_emdhdr = 'U'
    TABLES
      icdtxt_zplace  = l_place.
ENDFORM.                    " save_chg_docu
*&---------------------------------------------------------------------*
*&      Form  check_docno_rfc
*&---------------------------------------------------------------------*
*      Get Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_docno_rfc.

  CLEAR g_rfc_chk.
  CLEAR wa_emdhdr .
  CLEAR g_docno .
  DATA: l_tendno  LIKE zmm_emddtl-tendno,
        l_vendno  LIKE zmm_emddtl-vendno,
        l_ekgrp   LIKE zmm_emdhdr-ekgrp.

  SELECT * FROM ZMM_EMDREF UP TO 1 ROWS

 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
*&----->  Raise Error Message if Document is deleted.

    IF  ( zmm_emdref-status = 'D' ) AND ( prev_okcode = 'CHNG' OR
        prev_okcode = 'DELE' ).
      g_rfc_chk = '1'.

      MESSAGE e425(zmm).
    ELSE.
      g_rfc_chk = 0.
    ENDIF.
*-----------------------------------------------------------*
* Check whether Document Submitted to FI . If the raise error.
*-----------------------------------------------------------*
    IF prev_okcode  NE 'DISP'.
      IF zmm_emdref-status = 'S' .
        g_rfc_chk = '1'.
        MESSAGE e488(zmm).
      ENDIF.
    ENDIF.
*----- If Document status is 'C' Don;t allow to Reset.*------
    IF ok_code = 'UNDEL'.
      IF zmm_emdref-status = 'R' OR
         zmm_emdref-status = 'F' OR
         zmm_emdref-status = 'C'.
        g_rfc_chk = '1'.
        MESSAGE e483(zmm).
      ENDIF.
    ENDIF.
*-----------------------------------------------------------*
    IF ok_code = 'UNDEL'.
      PERFORM check_doc_status  USING zmm_emdref-docno.
    ENDIF.
*&------<
    g_amt = zmm_emdref-amount .
    g_docno = zmm_emdref-docno.

    g_rfc_chk = 0.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR_T02 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING wa_emdhdr_t02 TO zmm_emdhdr .
*      MOVE zmm_emdhdr-balamt TO g_balamt .
*----------------------------------------------------------------*
* if Ref. document is not in header then go for ZMM_EMDREF TABLE
*  COMPARE docno with refdoc no in same table and status = 'C'.
*  This is for getting Receipt total amount of Converted Document.
*----------------------------------------------------------------*
    ELSE.

      SELECT * FROM ZMM_EMDREF INTO CORRESPONDING
 FIELDS OF WA_EMDHDR_T02 UP TO 1 ROWS WHERE DOCNO = ZMM_EMDREF-REFDOC AND RFCSTAT = 'C'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      MOVE-CORRESPONDING wa_emdhdr_t02 TO zmm_emdhdr .
      PERFORM get_tendno_vendno USING wa_emdhdr_t02-ebeln
    CHANGING l_tendno l_vendno l_ekgrp  .

      MOVE l_tendno TO zmm_emdhdr-tenderno.
      MOVE l_vendno TO zmm_emdhdr-vendorno.
      MOVE l_ekgrp    TO zmm_emdhdr-ekgrp .
    ENDIF.
  ELSE.
    g_rfc_chk = 1.
    MESSAGE e411(zmm).
  ENDIF.
  MOVE zmm_emdhdr-currency   TO zmm_emdref-currency .
ENDFORM.                    " check_docno_rfc
*&---------------------------------------------------------------------*
*&      Form  save_data_115
*&---------------------------------------------------------------------*
*      Save Modified Data of Screen - 0115
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_data_115.
  CLEAR: g_save_h    ,
         g_save_i    .
  CLEAR wa_emdref_t01.
  MOVE-CORRESPONDING zmm_emdref TO wa_emdref .
  wa_emdref-rfcchby = sy-uname .
  wa_emdref-rfcchon = sy-datum .
  MOVE wa_emdhdr_t02-ebeln TO wa_emdref-ebeln .
  MODIFY zmm_emdref FROM wa_emdref.
  IF sy-subrc = 0.
    g_save_i = 0.
  ELSE.
    g_save_i = 1.
  ENDIF.
ENDFORM.                    " save_data_115
*&---------------------------------------------------------------------*
*&      Form  check_rfc_amount
*&---------------------------------------------------------------------*
*       Check Amount Entered for Refund/Forfeit/EMD-SD Conv.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_amount.

  DATA: l_tamt LIKE zmm_emdhdr-amount .
  DATA: l_act_bal LIKE zmm_emdhdr-amount .
*&---> Check Refund Amount
  PERFORM get_total_ref  .
*&---<
  CLEAR : g_balamt.
  g_balamt = zmm_emdhdr-amount  -  g_tot_ref .

  l_act_bal = zmm_emdhdr-amount -  g_tot_ref .

  IF prev_okcode = 'CREA'.
    g_amt = 0.
  ENDIF.
*----------------------------------------------*
  IF g_rfc  = 0  AND g_amt NE zmm_emdref-amount .

*&----> If Amount Entered is less than Doc. amount Add diff. amt to
* Balance amount .
    IF zmm_emdref-amount < g_amt .
      g_balamt =  g_amt -  zmm_emdref-amount + g_balamt.
    ELSEIF  zmm_emdref-amount > g_amt.
      l_tamt = zmm_emdref-amount - g_amt .
      IF   l_tamt > l_act_bal.
        MESSAGE e429(zmm).
      ELSE.
        g_balamt = g_balamt - ( zmm_emdref-amount - g_amt ) .
      ENDIF.
    ELSE.
      g_balamt    =  g_balamt   - zmm_emdref-amount.
    ENDIF.
  ENDIF.                                                    "20.02.2004
*&--<
ENDFORM.                    " check_rfc_amount
*&---------------------------------------------------------------------*
*&      Form  get_total_balamt
*&---------------------------------------------------------------------*
*      Get Total Balance Amount from Refund Table ZMM_EMDREF
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_total_ref .
  g_tot_ref  =  0.
  CLEAR g_tot_ref .
  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
             WHERE     refdoc  = zmm_emdhdr-docno AND
                      status IN ('R','F','C','I','S').

  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.
      g_tot_ref = g_tot_ref + wa_emdref-amount.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " get_total_balamt
*&---------------------------------------------------------------------*
*&      Form  disp_head
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_head USING l_docno
                     l_cron
                     l_trans .

  CLEAR g_status.

  CALL FUNCTION 'Z_MM_EMD_DISPLAY_HEADER'
    EXPORTING
      docu_no            = l_docno
      docu_type          = l_trans
      docu_date          = l_cron
    IMPORTING
      created_by         = g_crea_by
      created_on         = g_crea_on
      changed_by         = g_chan_by
      changed_on         = g_chan_on
      status             = g_stat
    EXCEPTIONS
      document_not_found = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  PERFORM get_head_status USING g_stat.
  CALL SCREEN 0125 STARTING AT 10 5  ENDING AT 60 12 .
ENDFORM.                    " disp_head
*&---------------------------------------------------------------------*
*&      Form  delete_rfc_doc
*&---------------------------------------------------------------------*
*       Delete RFC Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_rfc_doc.

*&---> Mark for deletion Set Status Flag = 'S'.

  UPDATE zmm_emdref
         SET status  = 'D'
         rfcchby = sy-uname
         rfcchon = sy-datum
         WHERE docno = g_docno    AND
               status NE 'D'.
  IF sy-subrc = 0.
    PERFORM clear_global_115.
    MESSAGE i415(zmm) WITH g_docno.

  ENDIF.
*&---<
ENDFORM.                    " delete_rfc_doc

*&---------------------------------------------------------------------*
*&      Form  clear_global_115
*&---------------------------------------------------------------------*
*       Clear Global Varibales in screen 115
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_115.
  CLEAR g_locname.

  CLEAR : zmm_emdhdr,
          zmm_emdref .
  CLEAR: ok_code ,
         prev_okcode .
ENDFORM.                    " clear_global_115
*&---------------------------------------------------------------------*
*&      Form  clear_global_100
*&---------------------------------------------------------------------*
*     Clear Global variable used in screen 0105.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_100.

  CLEAR: zmm_emdhdr,
         zmm_emddtl.
  CLEAR g_locname.

  REFRESH : ist_emddtl,
            ist_emddtl01,
            ist_emddtl_t01,
            ist_del_emddtl.
ENDFORM.                    " clear_global_100
*&---------------------------------------------------------------------*
*&      Form  check_instno
*&---------------------------------------------------------------------*
*      Check Instrument no
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_instno.
  CLEAR wa_emddtl.
  DATA: l_prev_instno    TYPE   zmm_emddtl-instno ,
        l_prev_inst_type TYPE   zmm_emddtl-inst_type.
  DATA: ist_emddtl_srt  LIKE TABLE OF wa_emddtl.

  g_error = 0.
  REFRESH ist_emddtl_srt .
  LOOP AT ist_emddtl INTO wa_emddtl.
    APPEND wa_emddtl TO ist_emddtl_srt.
  ENDLOOP.
  SORT  ist_emddtl_srt BY inst_type instno.
*&---> Check Whether same instrument no entered in Same Document
* If entered raise Message
  LOOP AT ist_emddtl_srt INTO wa_emddtl.
    IF sy-tabix = 1.
      l_prev_instno = wa_emddtl-instno.
      l_prev_inst_type = wa_emddtl-inst_type.
    ENDIF.

    IF sy-tabix > 1.
      IF  wa_emddtl-instno   = l_prev_instno AND
          wa_emddtl-inst_type = l_prev_inst_type .
        g_error = 1.
        MESSAGE i430(zmm) .
        EXIT.
      ELSE.
        g_error = 0.
        l_prev_instno = wa_emddtl-instno .
        l_prev_inst_type =   wa_emddtl-inst_type .
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR wa_emddtl.
  REFRESH ist_emddtl_srt .
ENDFORM.                    " check_instno
*&---------------------------------------------------------------------*
*&      Form  GET_HEADER
*&---------------------------------------------------------------------*
*       Get Header Information for RFC
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_header.

  MOVE zmm_emdref-rfccron TO zmm_emdhdr-cron.
  MOVE zmm_emdref-rfccrby TO zmm_emdhdr-crby.
  MOVE zmm_emdref-rfcchon TO wa_emdref-rfcchon .
  MOVE zmm_emdref-rfcchby TO wa_emdref-rfcchby.
  IF  zmm_emdref-status = 'R'.
    MOVE text-015 TO g_status.
  ELSEIF zmm_emdref-status = 'F'.
    MOVE text-016 TO g_status.
  ELSEIF zmm_emdref-status = 'C'.
    MOVE text-017 TO g_status.
  ENDIF.
  CALL SCREEN 0125 STARTING AT 10 5  ENDING AT 60 12 .
ENDFORM.                    " GET_HEADER
*&---------------------------------------------------------------------*
*&      Form  GET_RFC_DATA
*&---------------------------------------------------------------------*
*      Get Refund/Forfeit/EMD-SD Converted Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_rfc_data.

  CLEAR wa_emdref_01..
  REFRESH ist_emdref_01.

  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
           WHERE refdoc   = zmm_emdhdr-docno  AND
                 status  IN ('R','F','C','I','S').

  CLEAR wa_emdref_01.
  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.

      MOVE-CORRESPONDING wa_emdref TO wa_emdref_01.
      MOVE zmm_emdhdr-currency   TO wa_emdref_01-currency .
      APPEND  wa_emdref_01 TO ist_emdref_01.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_RFC_DATA
*&---------------------------------------------------------------------*
*&      Form  check_pono
*&---------------------------------------------------------------------*
*   Check PO no Incase of EMD-SD Conversion
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_pono.
  DATA: l_ebeln LIKE ekko-ebeln,
        l_bstyp LIKE ekko-bstyp.

*&--> Check for PO Document no if Tender fee select doc.with BSTYP =
*'A' Otherwise select doc. with  BSTYP = 'F'

  IF NOT zmm_emdhdr-trans IS INITIAL AND
    NOT zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE ebeln bstyp FROM ekko INTO (l_ebeln,l_bstyp)
           WHERE  ebeln = zmm_emdref-ebeln .
    IF sy-subrc NE 0.
      MESSAGE e275(zmm).
    ELSE.
      PERFORM check_document_type USING 'SDT'  l_bstyp  .
    ENDIF.
  ENDIF.
ENDFORM.                    " check_pono
*&---------------------------------------------------------------------*
*&      Form  check_company_code
*&---------------------------------------------------------------------*
*      Validate Company Code.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_company_code.

  SELECT SINGLE  * FROM t001
        WHERE  bukrs = zmm_emdhdr-co_code.
  IF sy-subrc NE 0.
    MESSAGE e431(zmm).
  ENDIF.
ENDFORM.                    " check_company_code
*&---------------------------------------------------------------------*
*&      Form  CLEAR_GLOBAL_135
*&---------------------------------------------------------------------*
*     Clear Global variables
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_global_135.

  CLEAR: zmm_emdhdr,
         zmm_emddtl,
         wa_emdhdr,
         wa_emddtl,
         zmm_emdhdr.

  REFRESH: ist_emddtl01,
           ist_emddtl.

  CLEAR :  ist_emddtl01,
           ist_emddtl.
  CLEAR g_idocno.
ENDFORM.                    " CLEAR_GLOBAL_135
*&---------------------------------------------------------------------*
*&      Form  update_for_bankconf
*&---------------------------------------------------------------------*
*     Update Line  Item Data Status .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_for_bankconf.

*&-----> Send for Bank Confirmation

  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE check = 'X'.

    UPDATE zmm_emddtl
           SET status = 'B'
     WHERE docno      = wa_emddtl-docno AND
           trans      = wa_emddtl-trans AND
           item_no    = wa_emddtl-item_no AND
           status    NE 'B'.
  ENDLOOP.
ENDFORM.                    " update_for_bankconf
*&---------------------------------------------------------------------*
*&      Form  check_item_select
*&---------------------------------------------------------------------*
*      Check Any Item selected or not
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_item_select.
  DATA: l_cnt LIKE sy-tabix.
  CLEAR g_ans.
  l_cnt = 0.
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE check = 'X'.
    IF wa_emddtl-check  = 'X' .
      l_cnt      = 1.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF l_cnt NE 1.

    g_ans  = 'K'.
    MESSAGE i433(zmm).
  ELSE.
    g_ans  = '0'.
  ENDIF.
ENDFORM.                    " check_item_select
*&---------------------------------------------------------------------*
*&      Form  append_isttab_135
*&---------------------------------------------------------------------*
*      Append F-code to ist_tab.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_isttab_135.
  DATA: wa_dtl  LIKE wa_emddtl.
  REFRESH ist_tab .
  DATA: l_found LIKE sy-tabix.
  DATA l_lines LIKE sy-tabix .
  DATA : l_bstyp TYPE zmm_emdhdr-bstyp.

  SELECT SINGLE  bstyp FROM ekko INTO l_bstyp
           WHERE  ebeln = zmm_emdhdr-ebeln .

  IF l_bstyp = 'F' OR l_bstyp = 'K'.
    MOVE 'ME43'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
  ELSEIF l_bstyp = 'A'.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    MOVE 'ME23'        TO  wa_tab-fcode .
    MOVE 'ME23N'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  ENDIF.

  MOVE 'SAVE'        TO  wa_tab-fcode .
  APPEND wa_tab      TO  ist_tab      .
  IF prev_okcode = 'RESET'  .
    MOVE 'BCONF'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
    MOVE 'SAVE'      TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .

  ELSEIF prev_okcode =   'BCONF'.
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
    MOVE 'SAVE'      TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
  ENDIF.

*---- If instrument type is 'LC' Disable icon "SND TO BNK" & "POST CNF".
  IF set_okcode = 'BGLC'.
    IF NOT ist_emddtl IS INITIAL.
      READ TABLE ist_emddtl INTO wa_dtl  INDEX 1.
    ENDIF.
    IF wa_dtl-inst_type = 'LC'.
      MOVE 'BCONF'     TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
      MOVE 'SAVE'      TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
      MOVE 'PCONF'      TO  wa_tab-fcode .
      APPEND wa_tab    TO  ist_tab      .
    ENDIF.
  ENDIF.
*&---------<
  IF g_ans = 'N'.
    MOVE 'SAVE'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
  ENDIF.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE status = 'B'.
    l_found = l_found + 1 .
  ENDLOOP.
  DESCRIBE TABLE ist_emddtl LINES l_lines.
  IF l_lines = l_found.
    MOVE 'SAVE'        TO  wa_tab-fcode .
    APPEND wa_tab      TO  ist_tab      .
    MOVE 'BCONF'     TO  wa_tab-fcode .
    APPEND wa_tab    TO  ist_tab      .
  ENDIF.
ENDFORM.                    " append_isttab_135
*&---------------------------------------------------------------------*
*&      Form  reset_bank_conf_doc
*&---------------------------------------------------------------------*
*       Reset Document.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_bank_conf_doc USING p_docno p_itemno p_reset_status.

  UPDATE zmm_emddtl
          SET status  = p_reset_status
          WHERE docno = p_docno AND
          trans       = zmm_emdhdr-trans AND
          item_no     = p_itemno.

*& --->> +003
* If document is reset , then update status of request for Return/Invoke
*  if sy-subrc = 0.
*    update zmm_emddtl
*          set ri_stat   = space
*              ri_crby   = sy-uname
*              ri_cron   = sy-datum
*              ri_reqno  =  space
*   where docno          = p_docno and
*          trans         =  zmm_emdhdr-trans   and
*          item_no       =  p_itemno  .
*  endif.
*& ----<< +003
ENDFORM.                    " reset_bank_conf_doc
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM
*&---------------------------------------------------------------------*
*       Check Whether any line item selected or not
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item.
  DATA l_found .
  l_found = 1.
  g_error = 0.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    IF  wa_emddtl-status = 'A' OR
        wa_emddtl-status = 'Y'.
      MESSAGE i440(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'V'.
      MESSAGE i443(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'E'.
      g_ans = 1.
      g_error = 1.
      MESSAGE i452(zmm).
    ELSEIF  wa_emddtl-status = 'S'.
      MESSAGE i446(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF  wa_emddtl-status = 'P'.
      MESSAGE i495(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status NE 'B'.
      MESSAGE i497(zmm).
      g_ans = 1.
      g_error = 1.

    ENDIF.
  ENDLOOP.
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i436(zmm).
  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM
*&---------------------------------------------------------------------*
*&      Form  check_sel_reset_item
*&---------------------------------------------------------------------*
*     Check Whether Any line item selected for Reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_reset_item.

  DATA l_found .
  l_found = 1.
  g_error = 0.
  CLEAR g_status .
  CLEAR g_itemno.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    g_itemno = wa_emddtl-item_no.

    IF wa_emddtl-status = 'N'.
      g_ans = 1.
      g_error = 1.
      MESSAGE i568(zmm).
    ENDIF.
*+004
    IF NOT wa_emddtl-ri_reqno IS INITIAL.
      IF wa_emddtl-ri_reqno+14(1) = 'R'.
        IF NOT ( wa_emddtl-status = 'E' OR wa_emddtl-status = 'V' ).
          g_ans = 1.
          g_error = 1.
          MESSAGE i511(zmm).
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
*+004
    CASE wa_emddtl-inst_type.

      WHEN 'BG'.

        IF  wa_emddtl-status = 'D' .
          g_reset_status   = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'B' .   " send to bank
          g_reset_status   = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'A' OR wa_emddtl-status = 'Y'.
          g_reset_status   = 'B' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'S' .   "Submit to FI
          g_reset_status      = 'A' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'P' .   "Accepted by FI
          g_reset_status     = 'S' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'V' .    "Invoke
          g_reset_status     = 'P' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'E' .   "Return.
          g_reset_status     = 'B' .
          EXIT.
        ENDIF.
      WHEN 'LC'.
        IF  wa_emddtl-status = 'S' .   "Submit to FI
          g_reset_status      = 'N' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'P' .   "Accepted by FI
          g_reset_status     = 'S' .
          EXIT.
        ELSEIF  wa_emddtl-status = 'V' OR
                wa_emddtl-status = 'E' .   "Invoke/Return.
          g_reset_status     = 'P' .
          EXIT.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i438(zmm).
  ENDIF.
ENDFORM.                    " check_sel_reset_item
*&---------------------------------------------------------------------*
*&      Form  update_post_conf
*&---------------------------------------------------------------------*
*       Update Status when Post Confirmation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_post_conf USING p_ad.
  DATA l_status .
  IF p_ad = 1.
    l_status = 'A'.  "Accepted By the bank
  ELSEIF p_ad = 2.
    l_status = 'Y'.  "Denied  By the  Bnak
  ELSE.
  ENDIF.
*&----> Flag 'A' is set for post Confirmation accepted
*----  other wise 'Y' for deny
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE status = 'B' AND
           sel = 'X'.

    UPDATE zmm_emddtl
           SET status = l_status
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'B'.
  ENDLOOP.
ENDFORM.                    " update_post_conf
*&---------------------------------------------------------------------*
*&      Form  get_item_details
*&---------------------------------------------------------------------*
*      Get Item Details
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_item_details.
  DATA l_found .
  CLEAR g_status.
  CLEAR g_reqno .
  CLEAR g_reqtext .
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 'X'.
    CASE wa_emddtl-status .
      WHEN 'N'.
        g_status        = text-040.  "Receipt
      WHEN 'B'.
        g_status        = text-036.  "Send for Bank Confirmation' .
      WHEN 'A'.
        g_status        = text-037 . "'Acceped By Bank'.
      WHEN  'Y'.
        g_status        = text-038 . " 'Denied  By Bank'.
      WHEN  'V'.
        g_status       =  text-039 . "'Invoked'.
      WHEN 'S'.
        g_status       =  text-043 .
      WHEN 'I'.
        g_status       =  text-054 .
      WHEN 'D'.
        g_status       =  text-047 .
      WHEN 'E'.
        g_status       =  text-058 .
      WHEN 'P'.
        g_status      = text-061.
    ENDCASE.
*+003
    IF wa_emddtl-ri_stat = '1'.
      g_reqtext   = text-058.
    ELSEIF wa_emddtl-ri_stat = '2'.
      g_reqtext   = text-078.
    ELSEIF wa_emddtl-ri_stat = '3'.
      g_reqtext  = text-080.
    ELSE.
      g_reqtext = 'Nill'.
    ENDIF.
  ENDLOOP.

  IF NOT wa_emddtl-ri_reqno IS INITIAL. "AND wa_emddtl-ri_stat NE '3' .
    g_reqno = wa_emddtl-ri_reqno.
  ELSE.
    g_reqno = 'Nill'.
  ENDIF.
*+003

  MOVE wa_emddtl-amount  TO zmm_emddtl-amount.
  IF l_found = 'X'.
    CALL SCREEN 0140 STARTING AT 10 5  ENDING AT 65 15 .
  ELSE.
    MESSAGE i442(zmm).
  ENDIF.
ENDFORM.                    " get_item_details
*&---------------------------------------------------------------------*
*&      Form  get_bglc_data
*&---------------------------------------------------------------------*
*   Get BG/LC Data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bglc_data.
  REFRESH  ist_emddtl    .
  CLEAR:   ist_emddtl    ,
           wa_emdhdr     ,
           wa_emddtl01   ,
           g_status      ,
           g_reset       ,
           g_dansw       ,
           g_reset       .


  IF NOT zmm_emdhdr-docno IS INITIAL.
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = G_IDOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
*&--> Display Status using variable g_status.
      IF wa_emdhdr-status = 'N'.
        g_status  = 'Created'.
      ELSEIF wa_emdhdr-status = 'D'.
        IF prev_okcode = 'DELE'.
          MESSAGE e425(zmm).
        ELSE.
          g_status  = 'Deleted'.
        ENDIF.
      ELSE.
        g_reset   = 0.
      ENDIF.
*&--<
      IF wa_emdhdr-status = 'D'.
        MESSAGE w416(zmm) WITH  wa_emdhdr-docno.
*       perform popup_for_reset  .
        g_reset = 1.
      ENDIF.

*&-----> Get Place NAme from table zmm_emdloc  .

      SELECT SINGLE locname FROM zmm_emdloc INTO g_locname
             WHERE locid = wa_emdhdr-place .
*&-----<
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr .
      SELECT * FROM zmm_emddtl INTO TABLE ist_emddtl01
               WHERE docno = wa_emdhdr-docno  AND
                     trans = wa_emdhdr-trans  AND
                     inst_type IN ('BG','LC') ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
*&--> Append EMD Item data into table control internal table ist_emddtl.
*Start of addition by SAB_SARVANAN on 12/06/2009
        CLEAR wa_emddtl.
*End of addition by SAB_SARVANAN on 12/06/2009
        LOOP AT ist_emddtl01 INTO wa_emddtl01.
          MOVE-CORRESPONDING wa_emddtl01 TO wa_emddtl.
          APPEND wa_emddtl TO ist_emddtl.
*Start of addition by SAB_SARVANAN on 12/06/2009
          CLEAR wa_emddtl01.
          CLEAR wa_emddtl.
*End of addition by SAB_SARVANAN on 12/06/2009
        ENDLOOP.
*&--<
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " get_bglc_data
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM_INNOKE
*&---------------------------------------------------------------------*
*      Check Selected Items before Invoke
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_invoke.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i445(zmm).
  ENDIF.

*+003
  IF zmm_emdhdr-trans = 'SDT'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF wa_emddtl-ri_stat  = '1'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i579(zmm).
        EXIT.
      ELSEIF  wa_emddtl-ri_stat = '1' AND
          wa_emddtl-status = 'S' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  i575(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat NE '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i577(zmm).
        EXIT.
      ENDIF.

      IF  wa_emddtl-status = 'V'.
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status =   'Y'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i498(zmm).
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i496(zmm).
        g_ans = 1.
        g_error = 1.
      ENDIF.
    ENDLOOP.
*+003

  ELSE.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
* +003
      IF wa_emddtl-ri_stat = '1' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  i586(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat NE '2' AND wa_emddtl-status NE 'E'.
        g_ans = 1.
        g_error = 1.
        MESSAGE  i585(zmm).
        EXIT.
      ENDIF.


* +003
      IF  wa_emddtl-status = 'V'.
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status =   'Y'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i498(zmm).
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i496(zmm).
        g_ans = 1.
        g_error = 1.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM_INNOKE
*&---------------------------------------------------------------------*
*&      Form  invoke_docu
*&---------------------------------------------------------------------*
*       Invoke Document after Confirmation
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM invoke_docu.
*&----> Flag 'S' is set for post Confirmation
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE  sel = 'X'.

    UPDATE zmm_emddtl
           SET status = 'V' ridate = sy-datum riuname = sy-uname
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'P'.
  ENDLOOP.
ENDFORM.                    " invoke_docu
*&---------------------------------------------------------------------*
*&      Form  set_lock
*&---------------------------------------------------------------------*
*      Set Lock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_lock.
  IF zmm_emdhdr-trans IS INITIAL.
    zmm_emdhdr-trans = wa_emdhdr-trans .
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZMM_ZMMEMDHDR'
    EXPORTING
      mode_zmm_emdhdr = 'E'
      mandt           = sy-mandt
      trans           = zmm_emdhdr-trans
      docno           = g_idocno
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_lock
*&---------------------------------------------------------------------*
*&      Form  release_lock
*&---------------------------------------------------------------------*
*       Release Lock
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock.
  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDHDR'
    EXPORTING
      mode_zmm_emdhdr = 'E'
      mandt           = sy-mandt
      trans           = zmm_emdhdr-trans
      docno           = zmm_emdhdr-docno.

ENDFORM.                    " release_lock

*&---------------------------------------------------------------------*
*&      Form  RELEASE_LOCK_REF
*&---------------------------------------------------------------------*
*       Release Lock - REFUND/FORFEIT/EMD-SD CONVERT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock_ref.

  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = zmm_emdref-docno.
ENDFORM.                    " RELEASE_LOCK_REF
*&---------------------------------------------------------------------*
*&      Form  popup_deny_accept
*&---------------------------------------------------------------------*
*       Popup for Bank Accept/Deny if 'Post Confirmation'
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_deny_accept.
  CLEAR g_ans_ad  .
  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
      textline1    = text-035
      text_option1 = text-032
      text_option2 = text-033
      titel        = text-034
      start_column = 25
      start_row    = 6
    IMPORTING
      answer       = g_ans_ad.

*CALL FUNCTION 'POPUP_TO_CONFIRM'
*  EXPORTING
*   TITLEBAR                    = text-034
*    TEXT_QUESTION               = text-035
*   TEXT_BUTTON_1               =  'Accepted by Bank'(032)"text-032
*   TEXT_BUTTON_2               = 'Denied by Bank'(033)"text-033
*   START_COLUMN                = 25
*   START_ROW                   = 6
* IMPORTING
*   ANSWER                      = g_ans_ad
* EXCEPTIONS
*   TEXT_NOT_FOUND              = 1
*   OTHERS                      = 2.
ENDFORM.                    " popup_deny_accept
*&---------------------------------------------------------------------*
*&      Form  check_sel_item_sndfi
*&---------------------------------------------------------------------*
*      Check Selected Line Item for Sending to FI
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_sndfi.
  DATA l_found .
  l_found = 1.
  g_error = 0.
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i448(zmm).
  ENDIF.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.

    CASE wa_emddtl-inst_type .

      WHEN 'BG'.
        IF  wa_emddtl-status = 'S'.
          MESSAGE i446(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'V'.
          MESSAGE i443(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'E'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i452(zmm).
        ELSEIF wa_emddtl-status = 'P'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i495(zmm).
        ELSEIF wa_emddtl-status =  'Y'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i498(zmm).
        ELSEIF wa_emddtl-status NE  'A'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i447(zmm).
        ENDIF.
      WHEN  'LC'.
        IF wa_emddtl-status = 'S'.
          MESSAGE i446(zmm).
          g_ans = 1.
          g_error = 1.
        ELSEIF wa_emddtl-status = 'P'.
          g_ans = 1.
          g_error = 1.
          MESSAGE i495(zmm).
        ELSEIF wa_emddtl-status = 'V'.
          MESSAGE i443(zmm).
          g_ans = 1.
          g_error = 1.
        ELSE.
          g_ans = '0' .
          g_error = 0.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " check_sel_item_sndfi
*&---------------------------------------------------------------------*
*&      Form  update_status_subfi
*&---------------------------------------------------------------------*
*      Update Document Status after sending to FI
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_status_subfi.

*&-----> Update Status Flag with 'S'   "send to FI
  LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE
            sel = 'X'.
*where status = 'A'
    UPDATE zmm_emddtl
           SET status = 'S'
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no .
  ENDLOOP.
ENDFORM.                    " update_status_subfi
*&---------------------------------------------------------------------*
*&      Form  check_sel_item_RETN
*&---------------------------------------------------------------------*
*       Check selected items before Return
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_retn   .

  DATA l_found .
  l_found = 1.
  g_error = 0.
*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i451(zmm).
  ENDIF.

*&-->+003
  IF zmm_emdhdr-trans = 'SDT'.

    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-ri_stat = '1' AND
           wa_emddtl-status = 'S' .
        g_ans = 1.
        g_error = 1.
        MESSAGE  e575(zmm).
        EXIT.
      ELSEIF wa_emddtl-ri_stat  = '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e578(zmm).
      ENDIF.

      IF  wa_emddtl-status = 'E'.
        MESSAGE e452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE e443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'N'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e497(zmm).
      ELSEIF wa_emddtl-status = 'B'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e447(zmm).

      ELSEIF  wa_emddtl-status = 'Y'   AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          g_ans = 1.
          g_error = 1.
          MESSAGE e515(zmm).
        ELSE.
          g_ans = 1.
          g_error = 1.
          MESSAGE e505(zmm).
        ENDIF.
      ELSEIF wa_emddtl-ri_stat NE '1' AND g_mmret NE 'X'.
        g_ans = 1.
        g_error = 1.
        MESSAGE e576(zmm).
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.

      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
      ELSEIF wa_emddtl-status = 'N'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i497(zmm).
      ELSEIF wa_emddtl-status = 'B'.
        g_ans = 1.
        g_error = 1.
        MESSAGE i447(zmm).
      ELSEIF  wa_emddtl-status = 'Y'   AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          MESSAGE e515(zmm).
        ELSE.
          MESSAGE e505(zmm).
        ENDIF.
      ELSEIF wa_emddtl-status = 'A'  AND g_mmret NE 'X' .
*+004
        AUTHORITY-CHECK OBJECT 'ZMMBGLC'
             ID 'ACTVT' FIELD  '16'   .
        IF sy-subrc = 0 .
          MESSAGE e516(zmm).
        ELSE.
          MESSAGE e505(zmm).
        ENDIF.
*+004
*-004
*        g_ans = 1.
*        g_error = 1.
*        message i498(zmm).
*
      ENDIF.
* +003
      IF wa_emddtl-ri_stat = '2'.
        g_ans = 1.
        g_error = 1.
        MESSAGE  e587(zmm).
      ELSEIF  ( wa_emddtl-ri_stat = space OR wa_emddtl-ri_stat = '3' ) AND
                               g_mmret NE 'X'  .
        g_ans = 1.
        g_error = 1.
        MESSAGE  e588(zmm).
      ENDIF.

*
*      if  wa_emddtl-ri_reqno+14(1) ne  'R' AND g_MMRET NE 'X' .
*        g_ans = 1.
*        g_error = 1.
*        message  i588(zmm).
*      endif.
* +003


*+004
*      if p_stat ne 'X'.
*        if wa_emddtl-status = 'S'.
*          g_ans = 1.
*          g_error = 1.
*          message i496(zmm).
*        elseif wa_emddtl-status = 'A'.
*          g_ans = 1.
*          g_error = 1.
*          message i450(zmm).
*        endif.
*+004
*     endif.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_sel_item_RETN
*&---------------------------------------------------------------------*
*&      Form  retrun_docu
*&---------------------------------------------------------------------*
*     Update status of return Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM retrun_docu.

*&----> Flag 'E' is set for post Confirmation
  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE sel = 'X' .
    UPDATE zmm_emddtl
           SET status = 'E' ridate = sy-datum riuname = sy-uname
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status    IN ('P','Y','A').
  ENDLOOP.
ENDFORM.                    " retrun_docu
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_S145
*&---------------------------------------------------------------------*
*     Save Data of screen 145
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_data_s145.

  CLEAR   : ist_dtl, ist_scrdtl .
  REFRESH : ist_scrdtl .
  REFRESH  ist_emddtl01.
  CLEAR:   wa_emddtl,
           wa_emddtl01.
  CLEAR    g_amount.
  LOOP AT ist_emddtl INTO wa_emddtl .
    g_amount  = g_amount + wa_emddtl-amount    .

    MOVE-CORRESPONDING wa_emddtl  TO    wa_emddtl01           .
    MOVE wa_emddtl-status         TO    wa_emddtl01-status    .
    MOVE g_docno                  TO    wa_emddtl01-docno     .
    MOVE zmm_emdhdr-trans         TO    wa_emddtl01-trans     .
    MOVE zmm_emdhdr-ebeln         TO    wa_emddtl01-ebeln     .
    MOVE zmm_emdhdr-vendorno      TO    wa_emddtl01-vendno    .
    MOVE zmm_emdhdr-tenderno      TO    wa_emddtl01-tendno    .
    MOVE wa_emdhdr-bstyp          TO    wa_emddtl01-bstyp      .
    MOVE space                    TO   wa_emddtl01-fi_parkno  .
    wa_emddtl01-crby = sy-uname .
    wa_emddtl01-cron = sy-datum .
    MOVE g_idocno             TO  wa_emddtl01-docno  .
    APPEND  wa_emddtl01 TO ist_emddtl01 .
  ENDLOOP.
  IF NOT g_amount IS INITIAL.
    UPDATE zmm_emdhdr
         SET amount  = g_amount
         WHERE trans = zmm_emdhdr-trans  AND
               docno = g_idocno.
    IF sy-subrc = 0.
      g_save_h = 0.
    ELSE.
      g_save_h = 1.
    ENDIF.
  ENDIF.

  IF NOT ist_emddtl01 IS INITIAL.

    MODIFY zmm_emddtl FROM TABLE ist_emddtl01.
    IF sy-subrc = 0.
      g_save_i = 0.
    ELSE.
      g_save_i = 1.
    ENDIF.
  ENDIF.
* Update CDPOS and CDHDR table - Change document for fields
* RSCODE, AMOUNT and INST_VDT (table ZMM_EMDDTL).

  ist_scrdtl[] = ist_emddtl[] ." screen fields
  LOOP AT ist_scrdtl .

    READ TABLE ist_dtl WITH KEY docno   = ist_scrdtl-docno
                                item_no = ist_scrdtl-item_no.

    IF ist_dtl-rscode <> ist_scrdtl-rscode .
      PERFORM chg_docu_rscode .
    ENDIF .
    READ TABLE ist_dtl WITH KEY docno = ist_scrdtl-docno
                                item_no = ist_scrdtl-item_no.

    IF ist_dtl-amount <> ist_scrdtl-amount .
      PERFORM chg_docu_amount .
    ENDIF .
    READ TABLE ist_dtl WITH KEY docno = ist_scrdtl-docno
                              item_no = ist_scrdtl-item_no.

    IF ist_dtl-inst_vdt <> ist_scrdtl-inst_vdt .
      PERFORM chg_docu_validity .
    ENDIF .
  ENDLOOP .
ENDFORM.                    " MODIFY_DATA_S145
*&---------------------------------------------------------------------*
*&      Form  CHECK_BGLC_DOC
*&---------------------------------------------------------------------*
*       Cehck BG/LC Document
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bglc_doc.

  SELECT SINGLE  * FROM zmm_emddtl
         WHERE docno  = zmm_emdhdr-docno AND
                 inst_type IN ('BG','LC').

  IF sy-subrc = 0.
  ELSE.
    MESSAGE e461(zmm).
  ENDIF.
ENDFORM.                    " CHECK_BGLC_DOC
*&---------------------------------------------------------------------*
*&      Form  check_valid_docno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_valid_docno.
  DATA: l_inst_type LIKE zmm_emddtl-inst_type .
  CLEAR wa_emdhdr.
  CLEAR g_ebeln  .

  SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
    CLEAR g_ebeln  .
*---------------------------------------------------------------------*
*  If instrument BG/LC exist in Doc. then don't allow for*
*  Refund/forfeit/Conversion.
    SELECT INST_TYPE FROM ZMM_EMDDTL INTO L_INST_TYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc = 0.
      IF l_inst_type = 'BG' OR l_inst_type = 'LC'.
        MESSAGE e560(zmm).
      ENDIF.
    ENDIF.
*---------------------------------------------------------------------*
*&-- Check whether transaction is Tender Fee.
*& If tender fee no Forfeit Allowed.
    IF g_doccat = text-016 AND wa_emdhdr-trans = 'TFS'.
      MESSAGE e555(zmm).
    ENDIF.

    IF g_doccat = 'EMD-SD CNV' AND wa_emdhdr-trans = 'TFS'.
      MESSAGE e558(zmm).
    ENDIF.

    IF g_doccat = 'EMD-SD CNV' AND wa_emdhdr-trans = 'SDT'.
      MESSAGE e559(zmm).
    ENDIF.
    MOVE wa_emdhdr TO zmm_emdhdr.
*Deleted
    IF wa_emdhdr-status = 'D'.
      MESSAGE e425(zmm).
* Partially Parked
    ELSEIF  wa_emdhdr-status = 'K'.
      MESSAGE e462(zmm).
*   Fully Parked
    ELSEIF wa_emdhdr-status = 'U'.
    ELSEIF wa_emdhdr-status = 'N'.
      MESSAGE e478(zmm).
    ENDIF.
  ELSE.
    SELECT * FROM ZMM_EMDREF INTO WA_EMDREF UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      CLEAR g_ebeln .
*------ For EMD- SD converted documents further conversion is not *  *
* possible.

      IF wa_emdref-rfcstat = 'C' AND  g_doccat = 'EMD-SD CNV' .
        MESSAGE e564(zmm).
      ENDIF.

*--------<
*-------> Raise error if document status is 'R' OR 'F' in create mode.
      IF ok_code = 'CRET'.
        IF  wa_emdref-rfcstat NE  'C'.
          MESSAGE e565(zmm).
        ENDIF.
      ENDIF.
*-------<

      IF wa_emdref-status = 'D'.
        MESSAGE e425(zmm).
      ELSEIF  wa_emdref-status NE 'S'.
        MESSAGE e450(zmm).
      ENDIF.
*---- IF valid docno then select header details from table zmm_emdhdr
* based on refdocno.
      SELECT SINGLE * FROM zmm_emdhdr INTO wa_emdhdr
           WHERE docno  = wa_emdref-refdoc .

      MOVE wa_emdref-amount TO zmm_emdhdr-amount.
      MOVE wa_emdref-currency TO zmm_emdref-currency.
      MOVE wa_emdref-ebeln TO g_ebeln  .
    ELSE.
      MESSAGE e411(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_valid_docno

*&---------------------------------------------------------------------*
*&      Form  check_reason_code
*&---------------------------------------------------------------------*
*       Check Reason code.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_reason_code USING p_rscode.

*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF wa_tc105-rscode < 100 OR wa_tc105-rscode > 199 .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF wa_tc105-rscode < 200 OR wa_tc105-rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF wa_tc105-rscode <  300  OR wa_tc105-rscode >  399   .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code
*&---------------------------------------------------------------------*
*&      Form  rest_rfc_doc
*&---------------------------------------------------------------------*
*      Reset Refund/Forfeit/EMD-SD Convert Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rest_rfc_doc USING p_docno.

  DATA: l_rfc_stat.

  SELECT RFCSTAT INTO L_RFC_STAT
 FROM ZMM_EMDREF UP TO 1 ROWS WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  UPDATE zmm_emdref
      SET status = l_rfc_stat
       rfcchby = sy-uname
       rfcchon = sy-datum
      WHERE docno = p_docno  .
  IF sy-subrc = 0.
    MESSAGE s471(zmm).
  ENDIF.
ENDFORM.                    " rest_rfc_doc
*&---------------------------------------------------------------------*
*&      Form  CLEAR_TABLE
*&---------------------------------------------------------------------*
*   Clear Internal Table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_table.
  REFRESH: ist_emddtl01,
           ist_emddtl   .
ENDFORM.                    " CLEAR_TABLE
*&---------------------------------------------------------------------*
*&      Form  DEL_LINE_ITEM
*&---------------------------------------------------------------------*
*      Delete Line Item from table ZMM_EMDDTL USING Internal table
*      ist_del_emddtl.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM del_line_item.

  LOOP AT ist_del_emddtl INTO wa_emddtl.
    DELETE  FROM zmm_emddtl
            WHERE item_no = wa_emddtl-item_no AND
                  trans   = wa_emddtl-trans   AND
                  docno   = wa_emddtl-docno   .

  ENDLOOP.
*&--------------------------------------------------------------*
*  Delete all Line item for the corresponding Docno and Item no
*  from table zmm_emddtl.

  DELETE FROM zmm_emddtl WHERE  trans   = wa_emddtl-trans   AND
                    docno   = wa_emddtl-docno   .


  REFRESH ist_del_emddtl .
  CLEAR wa_emddtl.
ENDFORM.                    " DEL_LINE_ITEM
*&---------------------------------------------------------------------*
*&      Form  check_rfc_amount_receipt
*&---------------------------------------------------------------------*
*       Check Balance amount at the time of creation. Refund/Forfeit/
*        EMD-SD Convert
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_amount_receipt.

*&---> Check Refund Amount
  PERFORM get_total_ref  .
*&---<
  IF   g_tot_ref IS INITIAL.
    g_balamt = zmm_emdhdr-amount .
  ELSE.
    g_balamt = zmm_emdhdr-amount - g_tot_ref.
  ENDIF.

  IF zmm_emdref-amount <  g_balamt AND NOT zmm_emdref-amount IS INITIAL.
    g_balamt  =  g_balamt - zmm_emdref-amount   .
  ELSEIF  zmm_emdref-amount > g_balamt .
    MESSAGE e429(zmm) WITH g_doccat .
  ELSEIF   zmm_emdref-amount IS INITIAL.
    g_balamt  = zmm_emdhdr-amount - g_tot_ref.
  ELSEIF zmm_emdref-amount =  g_balamt AND NOT zmm_emdref-amount IS
     INITIAL.
    g_balamt  =  g_balamt - zmm_emdref-amount   .
  ENDIF.

ENDFORM.                    " check_rfc_amount_receipt
*&---------------------------------------------------------------------*
*&      Form  get_head_status
*&---------------------------------------------------------------------*
*      Get Header Status using g_status
*----------------------------------------------------------------------*
*      -->P_G_STAT  text
*----------------------------------------------------------------------*
FORM get_head_status USING    p_stat.

  CLEAR :
          g_status  ,
          g_hstatus .
  IF  p_stat    = 'N'.
    g_status    = text-040.
    g_hstatus   = text-040.
  ELSEIF p_stat = 'U'.
    g_status    = text-049.
    g_hstatus   = text-049.
  ELSEIF p_stat = 'D'.
    g_status    = text-047.
    g_hstatus   = text-047.
  ELSEIF p_stat = 'K'.
    g_status    = text-055.
    g_hstatus   = text-055.
  ELSEIF p_stat = 'X'.
    g_status    = text-057.
    g_hstatus   = text-057.
  ELSEIF p_stat = 'J'.
    g_status    = text-062.
    g_hstatus   = text-062.
  ELSEIF p_stat = 'Q'.
    g_status    = text-063.
    g_hstatus   = text-063.
  ELSEIF p_stat = 'O'.
    g_status    = text-065.
    g_hstatus   = text-065.
  ELSEIF p_stat = 'T'.
    g_status    = text-066.
    g_hstatus   = text-066.
  ELSEIF p_stat = 'X'.
    g_status    = text-067.
    g_hstatus   = text-067.
* Begin of <RD1K963111>
  ELSEIF p_stat = 'R'.
    g_status    = text-015.
    g_hstatus   = text-015.
  ELSEIF p_stat = 'I'.
    g_status    = text-054.
    g_hstatus   = text-054.
  ELSEIF p_stat = 'G'.
    g_status    = text-083.
    g_hstatus   = text-083.
* End of <RD1K963111>
*+007 : Status
  ELSEIF p_stat = '0'.

    PERFORM get_status USING    p_stat
                       CHANGING g_status.

    MOVE g_status TO g_hstatus.
*+007 : End

  ENDIF.
ENDFORM.                    " get_head_status
*&---------------------------------------------------------------------*
*&      Form  get_item_status
*&---------------------------------------------------------------------*
*      Get Item status.
*----------------------------------------------------------------------*
*      -->P_WA_EMDDTL_STATUS  text
*----------------------------------------------------------------------*
FORM get_item_status USING    p_status.

  CLEAR g_status.
  CASE p_status .
    WHEN 'N'.
      g_status        = text-040.  "Receipt
    WHEN 'B'.
      g_status        = text-036.  "Send for Bank Confirmation' .
    WHEN 'A'.
      g_status        = text-037 . "'Acceped By Bank'.
    WHEN  'Y'.
      g_status        = text-038 . " 'Denied  By Bank'.
    WHEN  'V'.
      g_status       =  text-039 . "'Invoked'.
    WHEN 'S'.
      g_status       =  text-043 .  "Submitted to FI
    WHEN 'I'.
      g_status       =  text-054 .  "Parked to FI
    WHEN 'D'.
      g_status       =  text-047 .   "Deleted
    WHEN 'R'.
      g_status       =  text-015.    "Refund
    WHEN 'F'.
      g_status       =  text-016.    "Forfeit
    WHEN 'C'.
      g_status       =  text-017.    "Convert
    WHEN 'P'.
      g_status      =  text-061.    "Accepted by FI
    WHEN 'E'.
      g_status      =  text-058.    "Return BG/LC Document.
  ENDCASE.

ENDFORM.                    " get_item_status
*&---------------------------------------------------------------------*
*&      Form  get_ref_doc_stat
*&---------------------------------------------------------------------*
*      Get Refund/Forfeit/EMd-Sd Conv. Doc. Status
*----------------------------------------------------------------------*
*      -->P_G_DOCNO  text
*----------------------------------------------------------------------*
FORM get_ref_doc_stat USING    p_docno.
  DATA:l_stat.
  SELECT STATUS FROM ZMM_EMDREF INTO L_STAT UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.
    PERFORM get_item_status USING l_stat.
  ENDIF.
ENDFORM.                    " get_ref_doc_stat

*&---------------------------------------------------------------------*
*&      Form  check_doc_status
*&---------------------------------------------------------------------*
*       Check Document Status before reset
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_doc_status USING p_docno.

  DATA: wa_emdref_temp LIKE zmm_emdref.
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_TEMP UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0.
    IF wa_emdref_temp-status = 'N'.
      MESSAGE e472(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_doc_status
*&---------------------------------------------------------------------*
*&      Form  check_header_docu
*&---------------------------------------------------------------------*
*      Check Document before deletion.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_header_docu.
  PERFORM get_total_ref .
  IF  g_tot_ref NE 0.
    IF  g_tot_ref NE zmm_emdhdr-amount.
      MESSAGE e480(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_header_docu
*&---------------------------------------------------------------------*
*&      Form  update_head_status_105
*&---------------------------------------------------------------------*
*       Update header stsatus
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_head_status_105.
  DATA: l_prev_stat.
  DATA: l_found .
  LOOP AT ist_emddtl INTO wa_emddtl.
    IF sy-tabix = 1.
      l_prev_stat = wa_emddtl-status.
    ENDIF.
    IF wa_emddtl-status NE l_prev_stat.
      l_found = 'X'.
    ELSE.
      l_found = space.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " update_head_status_105
*&---------------------------------------------------------------------*
*&      Form  UPDATE_HEADER_STATUS
*&---------------------------------------------------------------------*
*     Update Status at Header Level.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_header_status  .
*using p_docno.
  DATA: wa_emddtl_tmp LIKE wa_emddtl.
  DATA: l_h_stat.
  DATA: l_found .
  CLEAR g_h_status.
*----------------------------------------------------------------------*
* Before Save Update Header Status based on the the document status at
* Item level.
* Eg. If All line items are parked then update Header status as Fully *
* parked.
*----------------------------------------------------------------------*

  LOOP AT ist_emddtl INTO wa_emddtl_tmp.
    IF sy-tabix = 1.
      l_h_stat = wa_emddtl_tmp-status.
    ENDIF.

    IF l_h_stat NE wa_emddtl_tmp-status.
      l_found = 'X'.
      EXIT.
    ELSE.
      l_found = '0'.
    ENDIF.
  ENDLOOP.

  IF l_found NE 'X'.
    IF l_h_stat = 'I'.
      g_h_status = 'U'.
    ELSEIF l_h_stat = 'N'.
      g_h_status = 'N'.
    ENDIF.
  ELSE.
  ENDIF.
ENDFORM.                    " UPDATE_HEADER_STATUS
*&---------------------------------------------------------------------*
*&      Form  check_rfc_docu_status
*&---------------------------------------------------------------------*
*      Check Refund/Forfeit/Convert Document Status
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_rfc_docu_status.
*--------- Check ZMM_EMDREF ----------------------------*
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF prev_okcode = 'DELE'.
    IF wa_emdref-status = 'R' OR
       wa_emdref-status =  'F'.
    ELSE.
      IF wa_emdref-status = 'D'.
        MESSAGE e425(zmm).
      ELSEIF wa_emdref-status = 'I'.
        MESSAGE e482(zmm)   .
      ENDIF.
    ENDIF.
  ELSEIF prev_okcode = 'UNDEL'.
    IF wa_emdref-status =  'R' OR
     wa_emdref-status   =  'F' OR
     wa_emdref-status   = 'I'.
      MESSAGE e483(zmm).
    ELSE.
    ENDIF.
  ENDIF.
ENDFORM.                    " check_rfc_docu_status
*&---------------------------------------------------------------------*
*&      Form  CHECK_AMOUNT_BF_RESET
*&---------------------------------------------------------------------*
*      Check Balance amount before Reset.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_amount_bf_reset.
  PERFORM get_total_rfc_amt  .
ENDFORM.                    " CHECK_AMOUNT_BF_RESET
*&---------------------------------------------------------------------*
*&      Form  get_total_rfc_amt
*&---------------------------------------------------------------------*
*    This subroutine is being used for  getting tot Refund/Forfeit/
*    EMD-SD Conv. at the time of RESET
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_total_rfc_amt .
  DATA: wa_emdref_temp  LIKE zmm_emdref.
  DATA: wa_emdref_t001  LIKE zmm_emdref.
  DATA: l_h_amt LIKE    zmm_emdhdr-amount.
  DATA: l_bal_amt       LIKE zmm_emdhdr-amount .
  CLEAR l_h_amt .
  CLEAR : wa_emdref_temp ,
          wa_emdref_t001 .
*---------------------------------------------------------------------*
*  Get Ref docno.
  SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_TEMP UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

* Check total amount at header level.
  IF sy-subrc = 0.
    SELECT AMOUNT INTO L_H_AMT FROM ZMM_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_TEMP-REFDOC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

*-- Check in case of converted Document. search in table ZMM_EMDREF.
    IF  sy-subrc NE 0.
      SELECT * FROM ZMM_EMDREF INTO WA_EMDREF_T001 UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDREF-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.

        SELECT AMOUNT INTO L_H_AMT FROM ZMM_EMDREF UP TO 1 ROWS
 WHERE DOCNO = WA_EMDREF_T001-REFDOC AND RFCSTAT = 'C'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      ENDIF.
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
  g_tot_ref  =  0.
  CLEAR g_tot_ref .

  SELECT * FROM zmm_emdref INTO TABLE ist_emdref
             WHERE     refdoc  = wa_emdref_temp-refdoc AND
                       status IN ('R','F','C','I','S').

  IF sy-subrc = 0.
    LOOP AT ist_emdref INTO wa_emdref.
      g_tot_ref = g_tot_ref + wa_emdref-amount.
    ENDLOOP.
  ENDIF.
*----------------------------------------------------------------------*
* Check whether the RFC amount is greater than or equal to Header amt
* then don't allow to RESET Document .

  l_bal_amt  =  l_h_amt - g_tot_ref .

  IF NOT g_tot_ref IS  INITIAL.
    IF  wa_emdref_temp-amount  > l_bal_amt.
      MESSAGE e484(zmm) WITH  wa_emdref_temp-amount  .
    ENDIF.
  ENDIF.
ENDFORM.                    " get_total_rfc_amt
*&---------------------------------------------------------------------*
*&      Form  check_EMDCONV_DOC
*&---------------------------------------------------------------------*
*     Check whether any document exist correspoding to EMD-SD COnv.
*     Document or not  . If it is there then Don't allow to edit/Delete
*     main receipt Document (EMD-SD CONVERTED Document.)
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_DOCNO  text
*----------------------------------------------------------------------*
FORM check_emdconv_doc USING    p_docno.
  DATA: wa_ref LIKE zmm_emdref.
  SELECT SINGLE * FROM zmm_emdref INTO wa_ref
        WHERE refdoc = p_docno  AND
              status IN ('R','I').

  IF sy-subrc = 0.
    MESSAGE e489(zmm).
  ENDIF.
ENDFORM.                    " check_EMDCONV_DOC

*&---------------------------------------------------------------------*
*&      Form  check_comp_code
*&---------------------------------------------------------------------*
*      Check Whether Vendor exist in entered company code or not
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_CO_CODE  text
*----------------------------------------------------------------------*
FORM check_comp_code USING    p_vcode p_co_code.
  DATA: ist_bukrs LIKE TABLE OF lfb1-bukrs.
  SELECT bukrs  FROM lfb1 INTO TABLE ist_bukrs
     WHERE lifnr = p_vcode        AND
           bukrs = p_co_code      AND
           loevm = space.
  IF sy-subrc NE 0.
    MESSAGE e491(zmm) WITH p_vcode p_co_code .
  ENDIF.
ENDFORM.                    " check_comp_code
*&---------------------------------------------------------------------*
*&      Form  CHECK_VENDOR_PO
*&---------------------------------------------------------------------*
*     Check Vendor no in PO no which is entered.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_vendor_po USING  p_docno.
*p_ebeln
  DATA: wa_hdr_t001  LIKE zmm_emdhdr.
  DATA: l_lifnr LIKE ekko-lifnr.


  SELECT * FROM ZMM_EMDHDR INTO WA_HDR_T001 UP TO 1 ROWS
 WHERE DOCNO = P_DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  IF sy-subrc = 0.

    SELECT SINGLE lifnr FROM ekko INTO l_lifnr
           WHERE  ebeln = zmm_emdref-ebeln.

    IF wa_hdr_t001-vendorno NE  l_lifnr.
      MESSAGE e492(zmm) WITH  wa_hdr_t001-vendorno .
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_VENDOR_PO
*&---------------------------------------------------------------------*
*&      Form  cehck_sel_item_accept
*&---------------------------------------------------------------------*
*       Check selected item before Accept by Finance
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cehck_sel_item_accept.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i493(zmm).
  ENDIF.

  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    IF  wa_emddtl-status = 'E'.
      MESSAGE i452(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF wa_emddtl-status = 'V' .
      MESSAGE i443(zmm).
      g_ans = 1.
      g_error = 1.
    ELSEIF  wa_emddtl-status = 'P'.
      MESSAGE i495(zmm).
      g_ans = 1.
      g_error = 1.

    ELSEIF wa_emddtl-status NE 'S' .
      MESSAGE i450(zmm).
      g_ans   = 1.
      g_error = 1.
    ELSE.
      g_ans   = 0.
      g_error = 0.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " cehck_sel_item_accept
*&---------------------------------------------------------------------*
*&      Form  accept_docu
*&---------------------------------------------------------------------*
*    Accept Document by
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM accept_docu.

*&----> Flag 'P' is set FOR Accept by FI.
*------- Before this updation the status of the line item must be 'S' ie
* Submitted by FI.

  LOOP AT  ist_emddtl  INTO wa_emddtl WHERE sel = 'X' .

    UPDATE zmm_emddtl
           SET status = 'P'
     WHERE docno      = wa_emdhdr-docno   AND
           trans      = wa_emdhdr-trans   AND
           item_no    = wa_emddtl-item_no AND
           status     = 'S'.
  ENDLOOP.

  IF sy-subrc = 0.
    MESSAGE s494(zmm).
  ENDIF.
ENDFORM.                    " accept_docu
*&---------------------------------------------------------------------*
*&      Form  disp_chg_hstry
*&---------------------------------------------------------------------*
*       Sub routine being used to display change history for the fields
*       RSCODE, AMOUNT, INST_VDT.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_chg_hstry.
  DATA :   i_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE  .
  DATA : ist_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE .
  DATA : l_objid LIKE cdhdr-objectid .
  DATA : BEGIN  OF ist_editpos OCCURS 0 .
          INCLUDE STRUCTURE cdshw .
  DATA :  user LIKE sy-uname ,
          date LIKE sy-datum ,
  END OF ist_editpos .
  DATA :   i_editpos TYPE TABLE OF cdshw WITH HEADER LINE .
  DATA : wa_header LIKE cdhdr .
  l_objid = wa_emddtl-docno .

  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZRSCODE'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.
    CLEAR : i_cdhdr .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      REFRESH i_editpos .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'RSCODE' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .
  REFRESH i_cdhdr .
  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZAMOUNT'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr, i_editpos  .
    REFRESH : i_editpos .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'AMOUNT' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .

  REFRESH i_cdhdr .
  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZVALIDITY'
      objectid                   = l_objid
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr, i_editpos  .
    REFRESH i_editpos .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.
      IF sy-subrc =  0.
        LOOP AT i_editpos WHERE fname = 'INST_VDT' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP .
  ENDIF .

  WRITE : /5 'Document No. ' , 20 'Field Name', 35 'Old Value',
           50 'New value' , 75 'changed by' , 90 ' changed on' .

  WRITE : /5 sy-uline(95).
  LOOP AT ist_editpos .

    WRITE :/5 wa_emddtl-docno(10), 20 ist_editpos-fname(15) ,
           35 ist_editpos-f_old(10) , 50 ist_editpos-f_new(10) ,
           75 ist_editpos-user(12) , 90 ist_editpos-date  .

  ENDLOOP .

  CLEAR ist_editpos .
  REFRESH ist_editpos .
  CLEAR ok_code .
ENDFORM.                    " disp_chg_hstry
*&---------------------------------------------------------------------*
*&      Form  chg_docu_rscode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_rscode.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .
  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_dtl-rscode .
  ist_oemddtl-amount = ist_scrdtl-amount .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZRSCODE_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zrscode          = ist_chngind.
ENDFORM.                    " chg_docu_rscode
*&---------------------------------------------------------------------*
*&      Form  chg_docu_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_amount.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .

  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_scrdtl-rscode .
  ist_oemddtl-amount = ist_dtl-amount .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZAMOUNT_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zamount          = ist_chngind.

ENDFORM.                    " chg_docu_amount
*&---------------------------------------------------------------------*
*&      Form  chg_docu_validity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM chg_docu_validity.
  DATA : l_objid LIKE cdhdr-objectid .
  l_objid = wa_emddtl-docno .

  ist_nemddtl-docno = ist_scrdtl-docno .
  ist_nemddtl-trans = ist_scrdtl-trans .
  ist_nemddtl-item_no = ist_scrdtl-item_no .
  ist_nemddtl-ebeln = ist_scrdtl-ebeln .
  ist_nemddtl-status = ist_scrdtl-status .
  ist_nemddtl-rscode = ist_scrdtl-rscode .
  ist_nemddtl-amount = ist_scrdtl-amount .
  ist_nemddtl-inst_vdt = ist_scrdtl-inst_vdt .
  ist_nemddtl-currency = ist_scrdtl-currency .

  ist_oemddtl-docno = ist_scrdtl-docno .
  ist_oemddtl-trans = ist_scrdtl-trans .
  ist_oemddtl-item_no = ist_scrdtl-item_no .
  ist_oemddtl-ebeln = ist_scrdtl-ebeln .
  ist_oemddtl-status = ist_scrdtl-status .
  ist_oemddtl-rscode = ist_scrdtl-rscode .
  ist_oemddtl-amount = ist_scrdtl-amount .
  ist_oemddtl-inst_vdt = ist_dtl-inst_vdt .
  ist_oemddtl-currency = ist_scrdtl-currency .

  CALL FUNCTION 'ZVALIDITY_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_emddtl            = ist_nemddtl
      o_zmm_emddtl            = ist_oemddtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zvalidity        = ist_chngind.

ENDFORM.                    " chg_docu_validity
*&---------------------------------------------------------------------*
*&      Form  update_header_status_bglc
*&---------------------------------------------------------------------*
*     This subroutine is to Update Header level status for BG/LC
*     Line Items.
*----------------------------------------------------------------------*
*      -->P_G_IDOCNO  text
*      -->P_2616   text
*----------------------------------------------------------------------*
FORM update_header_status_bglc USING    p_docno
                                        p_stat .

  UPDATE zmm_emdhdr
        SET status = p_stat
    WHERE docno    = p_docno.
ENDFORM.                    " update_header_status_bglc
*&---------------------------------------------------------------------*
*&      Form  update_header_status_bglc_main
*&---------------------------------------------------------------------*
*       Update header status.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_header_status_bglc_main.

  PERFORM get_bglc_data.

  DATA: wa_dtl_t001 TYPE zmm_emd_status.
  DATA: l_stat,
        l_found.
*---------------------------------------------------------------------------*
* Start of modification by SAB_SARVANAN on 12/06/2009 - RD1K964254
*BREAK-POINT.
*if prev_okcode = 'RESET'.
*  loop at ist_emddtl into wa_dtl_t001.
*    if sy-tabix = 1.
*      l_stat    =  wa_dtl_t001-status.
*    endif.
*
*    if l_stat   ne  wa_dtl_t001-status.
*      l_found   =  'X'.
*      exit.
*    else.
*      l_found   =  '0'.
*    endif.
*  endloop.

*  if l_found = '0' and not l_stat is initial.
*    if l_stat ='N'.
*      perform update_header_status_bglc using g_idocno 'N'.
*    elseif l_stat = 'P'.
*      perform update_header_status_bglc using g_idocno 'J'.
*    endif.
*
*  elseif l_found = 'X'.
*    perform update_header_status_bglc using g_idocno 'Q'.
*  endif.

*  else.

  CALL FUNCTION 'ZMM_EMD_GET_STATUS_DETAILS'
    EXPORTING
      docno     = g_idocno
    IMPORTING
      output    = l_stat
    TABLES
      input_tab = ist_emddtl.

  PERFORM update_header_status_bglc USING g_idocno l_stat.

*    endif.
* End of modification by SAB_SARVANAN on 12/06/2009 - RD1K964254
ENDFORM.                    " update_header_status_bglc_main
*&---------------------------------------------------------------------*
*&      Form  check_reason_code_rfc
*&---------------------------------------------------------------------*
*      Check reason code at the time of Refund/forfeit/Convert.
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_RSCODE  text
*----------------------------------------------------------------------*
FORM check_reason_code_rfc USING   p_rscode.
*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF p_rscode < 100 OR p_rscode > 199  .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF p_rscode < 200 OR p_rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF p_rscode < 300 OR p_rscode > 399  .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code_rfc
*&---------------------------------------------------------------------*
*&      Form  CHECK_BGLC
*&---------------------------------------------------------------------*
*       Check BG/LC Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bglc.
  IF prev_okcode = 'BGLC' OR prev_okcode = 'AMEND' .

    IF NOT zmm_emdhdr-docno  IS INITIAL.

      SELECT SINGLE * FROM zmm_emdhdr INTO wa_emdhdr
                 WHERE docno = zmm_emdhdr-docno.
      IF sy-subrc = 0.

        PERFORM check_bglc_doc.
      ELSE.
        MESSAGE e411(zmm).

      ENDIF.
    ENDIF.
  ELSE.
    IF NOT zmm_emdhdr-docno  IS INITIAL.
      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF  sy-subrc = 0.
        IF prev_okcode = 'AMEND'.
          IF wa_emdhdr-trans = 'TFS'.
            MESSAGE e460(zmm).
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_BGLC
*&---------------------------------------------------------------------*
*&      Form  get_tendno_vendno
*&---------------------------------------------------------------------*
*      Get tenderno and vendor no.
*----------------------------------------------------------------------*
*      -->P_WA_EMDHDR_T02_EBELN  text
*      <--P_L_TENDNO  text
*      <--P_L_VENDNO  text
*      <--P_L_EKGRP  text
*----------------------------------------------------------------------*
FORM get_tendno_vendno USING    p_ebeln
                       CHANGING p_tendno
                                p_vendno
                                p_ekgrp.

  SELECT SINGLE submi lifnr ekgrp FROM ekko INTO (p_tendno,
                            p_vendno,
                            p_ekgrp)
WHERE ebeln = p_ebeln   .
ENDFORM.                    " get_tendno_vendno
*&---------------------------------------------------------------------*
*&      Form  check_reason_code_amend
*&---------------------------------------------------------------------*
*  Check reason code at the time of amendment.
*----------------------------------------------------------------------*
*      -->P_WA_TC145_RSCODE  text
*----------------------------------------------------------------------*
FORM check_reason_code_amend USING   p_rscode .

*----------------------------------------------------------------------*
  SELECT SINGLE * FROM zmm_emdrscode
    WHERE rscode =  p_rscode.
  IF sy-subrc NE 0.
    MESSAGE e467(zmm).
  ENDIF.
*----------------------------------------------------------------------*
  IF zmm_emdhdr-trans = 'TFS'.
    IF  p_rscode < 100 OR  p_rscode > 199  .
      MESSAGE e464(zmm).
    ENDIF.
  ELSEIF  zmm_emdhdr-trans = 'EMD' .
    IF p_rscode < 200 OR   p_rscode > 299  .
      MESSAGE e465(zmm).
    ENDIF.
  ELSEIF zmm_emdhdr-trans = 'SDT'.
    IF   p_rscode < 300 OR   p_rscode > 399  .
      MESSAGE e466(zmm).
    ENDIF.
*-------  < Check Reason code > ---------------------------------------*
  ENDIF.
ENDFORM.                    " check_reason_code_amend
*&---------------------------------------------------------------------*
*&      Form  status_message
*&---------------------------------------------------------------------*
*       Dynamic message after Reset document.
*----------------------------------------------------------------------*
*      -->P_G_RESET_STATUS  text
*----------------------------------------------------------------------*
FORM status_message USING    p_status.
  DATA: l_msg(40).
  IF p_status = 'N'.
    l_msg = text-040.
  ELSEIF p_status = 'B'.
    l_msg  = text-024.
  ELSEIF p_status = 'S'.
    l_msg  = text-048.
  ELSEIF p_status = 'P'.
    l_msg  = text-059.
  ELSEIF p_status = 'A'.
    l_msg  = text-064.
  ENDIF.
  MESSAGE s434(zmm) WITH l_msg.
ENDFORM.                    " status_message
*&---------------------------------------------------------------------*
*&      Form  SET_LOC_RFC
*&---------------------------------------------------------------------*
*   Set lock at the time of Refund/Forfeit/Conv. Change/Display/Delete
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDREF_DOCNO  text
*----------------------------------------------------------------------*
FORM set_loc_rfc USING    p_docno.
  CALL FUNCTION 'ENQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = p_docno
    EXCEPTIONS
      foreign_lock    = 1
      system_failure  = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SET_LOC_RFC
*&---------------------------------------------------------------------*
*&      Form  relase_lock_rfc
*&---------------------------------------------------------------------*
*       Release Lock in Refund/Forfiet/Convert
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM release_lock_rfc  USING p_docno .

  CALL FUNCTION 'DEQUEUE_EZMM_ZMMEMDREF'
    EXPORTING
      mode_zmm_emdref = 'E'
      mandt           = sy-mandt
      docno           = p_docno.

ENDFORM.                    " relase_lock_rfc
*&---------------------------------------------------------------------*
*&      Form  check_auth
*&---------------------------------------------------------------------*
*  Authority check at the time of Invoke/Return/Accept by FI
*----------------------------------------------------------------------*
*      -->P_1988   text
*----------------------------------------------------------------------*
FORM check_auth .
  DATA: wa_dtl TYPE zmm_emd_status.

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = zmm_emdhdr-docno
                                             sel   = 'X'.

  AUTHORITY-CHECK OBJECT 'ZMMBGLC'
         ID 'ACTVT' FIELD  '16'   .

  IF sy-subrc NE 0 .
*   if wa_dtl-ri_stat ne '3'.
    MESSAGE  e505(zmm).
*    endif.
  ENDIF.
ENDFORM.                    " check_auth
*&---------------------------------------------------------------------*
*&      Form  CHECK_VENDOR
*&---------------------------------------------------------------------*
*       Check Vendor no based on screen i/p. This is only Applicable
*  for SRM Tednders
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_vendor USING p_lifnr.
  DATA l_lifnr LIKE lfb1-lifnr .
  SELECT SINGLE lifnr FROM lfb1 INTO l_lifnr
         WHERE lifnr = p_lifnr .
  IF sy-subrc NE 0.
    MESSAGE e572(zmm).
  ELSE.
** Get Vendor name from table LFA1
    SELECT SINGLE name1 FROM lfa1 INTO g_vname
              WHERE lifnr = p_lifnr.
  ENDIF.
ENDFORM.                    " CHECK_VENDOR
*&---------------------------------------------------------------------*
*&      Form  get_trasn_type
*&---------------------------------------------------------------------*
*     Get Transaction Type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_trasn_type  .

  SELECT TRTYP FROM ZMM_EMDHDR INTO G_TTYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  IF sy-subrc = 0 AND g_ttype IS INITIAL .
    MOVE 'R3' TO  g_ttype.
  ENDIF.
ENDFORM.                    " get_trasn_type
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBIDNO
*&---------------------------------------------------------------------*
*       Validate Input EBID No using RFC Call to SRM SERVER
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebidno.
  DATA: ist_crmd(2000) OCCURS 0.
  DATA: l_logsys(32).
*----------------------------------------------------------------------*
* Get Logical system name from table ZMM_LOGSYS
*----------------------------------------------------------------------*

  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                WHERE  appl = 'SRM'.

*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Call RFC in SRM server to get Bid Invitation No.
*----------------------------------------------------------------------*
  IF NOT l_logsys IS INITIAL.
    CALL FUNCTION 'Z_GET_CRMD_ORDERADM_H' DESTINATION l_logsys
      EXPORTING
        obj_type = 'BUS2200'
        ebidno   = zmm_emdhdr-ebidno
      TABLES
        ist_crmd = ist_crmd.
    IF  ist_crmd[] IS INITIAL.
      MESSAGE e573(zmm).
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*

ENDFORM.                    " CHECK_EBIDNO
*&---------------------------------------------------------------------*
*&      Form  GET_OPTIONS
*&---------------------------------------------------------------------*
*       Get Option from user input
*  Whether Exempted from Tender Fee or normal Tender Fee
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_options CHANGING p_result.
* Start of addition by Saravanan M on 08/04/2009
  CALL FUNCTION 'K_KKB_POPUP_RADIO3'
    EXPORTING
      i_title   = text-071
      i_text1   = text-069
      i_text2   = text-070
      i_text3   = text-081
      i_default = 1
    IMPORTING
      i_result  = p_result
    EXCEPTIONS
      cancel    = 1
      OTHERS    = 2.
*  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
* End of addition by Saravanan M on 08/04/2009
* Start of comment by Saravanan M on 08/04/2009
*  call function 'K_KKB_POPUP_RADIO2'
*    exporting
*      i_title   = text-071
*      i_text1   = text-069
*      i_text2   = text-070
*      i_default = 1
*    importing
*      i_result  = p_result
*    exceptions
*      cancel    = 1
*      others    = 2.
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
* End of comment by Saravanan M on 08/04/2009
ENDFORM.                    " GET_OPTIONS
*&---------------------------------------------------------------------*
*&      Form  SAVE_SRM_HEADER_DOC
*&---------------------------------------------------------------------*
*   Incase of Tender Fee Exempted Vendors  Save only Header Doc.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_srm_header_doc.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr .
  MOVE g_docno TO wa_emdhdr-docno .
  MOVE 'SRM' TO  wa_emdhdr-trtyp .
  MOVE sy-uname TO wa_emdhdr-crby.
  MOVE sy-datum TO wa_emdhdr-cron .
*  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF wa_emdhdr-vendorno IS NOT INITIAL AND
     wa_emdhdr-ebidno IS NOT INITIAL.
    PERFORM send_to_srm.
* Update the ECC table for Tender Fee Exemption based on the SRM TFee Update FM return Parameter
    IF lv_srm_update_status EQ abap_true. " LV_SRM_UPDATE_STATUS, Indicates whether it updates the SRM TDPD Table successfully or not.
      MODIFY zmm_emdhdr FROM wa_emdhdr . " Modify ZMM_EMDHDR ECC Table only after SRM TDPD Table Successful Updation.
      MESSAGE s410(zmm) WITH g_docno .
    ENDIF.
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ELSE.
    MESSAGE e270(zmm).
  ENDIF.

ENDFORM.                    " SAVE_SRM_HEADER_DOC
*&---------------------------------------------------------------------*
*&      Form  get_document_cat
*&---------------------------------------------------------------------*
*      Get Document Category.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_document_cat USING p_docno CHANGING p_srm_tfs.
  DATA: l_docno LIKE zmm_emdhdr-docno .

  SELECT SINGLE *  FROM zmm_emdhdr INTO zmm_emdhdr
    WHERE  docno = p_docno AND
           trtyp = 'SRM'.
  IF sy-subrc = 0.
    SELECT SINGLE  docno INTO l_docno FROM zmm_emddtl
     WHERE docno = p_docno .
    IF sy-subrc NE  0.
      p_srm_tfs = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_document_cat
*&---------------------------------------------------------------------*
*&      Form  clear_screen_160
*&---------------------------------------------------------------------*
*      Clear Screen 160.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_screen_160.
  CLEAR: zmm_emdhdr,
         g_vname   ,
         g_hstatus ,
         g_locname ,
         g_docno   ,
         g_idocno  .
  CLEAR : ok_code, prev_okcode , g_okhdr, g_reset, g_hstatus.

ENDFORM.                    " clear_screen_160
*&---------------------------------------------------------------------*
*&      Form  APPEND_ITAB_S160
*&---------------------------------------------------------------------*
*      Append OKCODE to ist_tab
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_itab_s160.

  REFRESH ist_tab .
  CLEAR ist_tab   .
  CLEAR wa_tab    .

  IF ( prev_okcode = 'DISP' )  .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'DELE' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'CHAN' OR prev_okcode = 'ECREA' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'RESET'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ELSEIF ( prev_okcode = 'REST' )  .
    REFRESH ist_tab .
    CLEAR ist_tab   .
    CLEAR wa_tab    .
    MOVE 'DELE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
    MOVE 'SAVE'     TO  wa_tab-fcode .
    APPEND wa_tab   TO  ist_tab      .
  ENDIF.


ENDFORM.                    " APPEND_ITAB_S160
*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGES
*&---------------------------------------------------------------------*
*       Save Changes for SRM Screen 160.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_changes.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr .
  MOVE g_idocno TO wa_emdhdr-docno .
  MOVE 'SRM'    TO  wa_emdhdr-trtyp .
  MOVE sy-uname TO wa_emdhdr-chby  .
  MOVE sy-datum TO wa_emdhdr-chon .
  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF sy-subrc = 0.
    MESSAGE i412(zmm) WITH g_idocno .
    PERFORM release_lock .
    PERFORM clear_screen_160 .
    LEAVE TO SCREEN '0100'.
  ELSE.
    MESSAGE e270(zmm).
  ENDIF.
ENDFORM.                    " SAVE_CHANGES
*&---------------------------------------------------------------------*
*&      Form  MARK_FOR_DELE_EDOC
*&---------------------------------------------------------------------*
*       Make Document Mark for Deletion : Only for SRM Trender Fee
*       exempted vendors
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mark_for_dele_edoc.
  CLEAR wa_emdhdr.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr.
* Start of Change - By Manikandan
  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                WHERE  appl = 'SRM'.

  IF l_logsys IS NOT INITIAL AND
     wa_emdhdr-ebidno IS NOT INITIAL AND
     wa_emdhdr-vendorno IS NOT INITIAL.

    CALL FUNCTION 'Z_UPDATE_TDPD_INDI' DESTINATION l_logsys
      EXPORTING
        iv_bid_no            = wa_emdhdr-ebidno               "'char10
        iv_vendor_no         = wa_emdhdr-vendorno             "'char10
      IMPORTING
        ev_success           = lv_srm_update_status
      EXCEPTIONS
        tender_not_published = 1
        tf_deadline_reached  = 2
        OTHERS               = 3.
  ENDIF.

  IF lv_srm_update_status EQ abap_true. " Update in SRM TDPD Table is success, so can update ECC Tables now.
    MOVE 'D'  TO wa_emdhdr-status.
    MODIFY zmm_emdhdr FROM wa_emdhdr .
    IF sy-subrc = 0.
      MESSAGE i415(zmm) WITH g_idocno.
      PERFORM release_lock .
      PERFORM clear_screen_160.
      LEAVE TO SCREEN '0100'.
    ENDIF.
  ELSEIF lv_srm_update_status EQ 'E'. " Response Already Created by the Vendor for the ETender Document
    MESSAGE e009(zmm_emd) WITH g_idocno.
    PERFORM release_lock .
    PERFORM clear_screen_160.
  ELSEIF lv_srm_update_status NE abap_true. "Please Check the Status on both ECC & SRM System
    MESSAGE i010(zmm_emd) WITH g_idocno.
    PERFORM release_lock .
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ENDIF.
* End of Change   - By Manikandan
ENDFORM.                    " MARK_FOR_DELE_EDOC
*&---------------------------------------------------------------------*
*&      Form  RESET_EDOC
*&---------------------------------------------------------------------*
*      Reset Deleted E-Tender Fee Document
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reset_edoc.
  CLEAR wa_emdhdr.
  MOVE-CORRESPONDING zmm_emdhdr TO wa_emdhdr.
  MOVE 'N'  TO wa_emdhdr-status.
  MODIFY zmm_emdhdr FROM wa_emdhdr .
  IF sy-subrc = 0.
    MESSAGE i424(zmm) .
    PERFORM release_lock .
    PERFORM clear_screen_160.
    LEAVE TO SCREEN '0100'.
  ENDIF.
ENDFORM.                    " RESET_EDOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_ITEM_RQRI
*&---------------------------------------------------------------------*
*  Check whether the selected document is send to FI/Accepted by FI
*  If no Raise Error Message
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_sel_item_rqri.

  DATA l_found .
  DATA : wa_dtl TYPE zmm_emd_status,
       wa_emddtl01  LIKE wa_emddtl..

  l_found = 1.
  g_error = 0.
*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i451(zmm).
  ENDIF.
  CLEAR wa_emddtl.

  IF zmm_emdhdr-trans = 'SDT' OR zmm_emdhdr-trans = 'EMD'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF NOT ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        MESSAGE i510(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ENDIF.

      IF  wa_emddtl-ri_stat = '1' AND
        ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        g_ans = 1.
        g_error = 1.
        MESSAGE i574(zmm) WITH 'Return'.
      ELSEIF  wa_emddtl-ri_stat = '2' AND
     ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        g_ans = 1.
        g_error = 1.
        MESSAGE i574(zmm) WITH 'Invoke'.
      ENDIF.
    ENDLOOP.
*  ELSEIF zmm_emdhdr-trans = 'EMD'.                          "+003
*    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
*      IF  wa_emddtl-status = 'E'.
*        MESSAGE i452(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ELSEIF wa_emddtl-status = 'V' .
*        MESSAGE i443(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ELSEIF wa_emddtl-status NE 'P'.
*        MESSAGE i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        EXIT.
*      ENDIF.
*  ENDLOOP.

  ENDIF.
ENDFORM.                    " CHECK_SEL_ITEM_RQRI
*&---------------------------------------------------------------------*
*&      Form  popup_req_ret_invk
*&---------------------------------------------------------------------*
*       Popup message showing request for Return or Invoke
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM popup_req_ret_invk.
  CLEAR g_ans_ad.

  CALL FUNCTION 'POPUP_TO_DECIDE'
    EXPORTING
      textline1    = text-075
      text_option1 = text-076
      text_option2 = text-077
      titel        = text-075
      start_column = 25
      start_row    = 6
    IMPORTING
      answer       = g_ans_ad.

ENDFORM.                    " popup_req_ret_invk
*&---------------------------------------------------------------------*
*&      Form  update_req_ret_inv
*&---------------------------------------------------------------------*
*     Update Document status for Request for Return/Invoke
*----------------------------------------------------------------------*
*      -->P_G_ANS_AD  text
*----------------------------------------------------------------------*
FORM update_req_ret_inv USING    p_ad  .
  DATA: l_status,
        l_text(15).
  CLEAR: l_text , l_status, g_reqno..
  DATA l_reqno  TYPE zmm_emddtl-ri_reqno.
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
  DATA lv_status.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
  IF p_ad = 1.
    l_text = 'Return'.
    l_status = '1'.  "Request for Return
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
    lv_status = 'G'.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
    CONCATENATE g_idocno  wa_emddtl-item_no  'RR' INTO l_reqno .
  ELSEIF p_ad = 2.
    l_text = 'Invoke'.
    l_status = '2'.  "Request for Invoke
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
    lv_status = 'H'.
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
    CONCATENATE g_idocno  wa_emddtl-item_no 'IR' INTO l_reqno .
  ENDIF.
* Begin of <RD1K963111>
  zmm_emddtl-ri_crby = sy-uname.
  zmm_emddtl-ri_cron = sy-datum.
* End of <RD1K963111>
  IF zmm_emdhdr-trans = 'SDT'.
    LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE sel = 'X'.

      UPDATE zmm_emddtl
             SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
                 ri_crby   = sy-uname
                 ri_cron   = sy-datum
                  ri_reqno =  l_reqno
      WHERE docno          = wa_emdhdr-docno   AND
             trans         = wa_emdhdr-trans   AND
             item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDLOOP.

  ELSEIF zmm_emdhdr-trans = 'EMD' AND p_ad = '1'.
    "+003
*    loop at ist_emddtl into wa_emddtl where sel = 'X'.
*      if  wa_emddtl-status = 'E'.
*        message i452(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      elseif wa_emddtl-status = 'V' .
*        message i443(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      elseif wa_emddtl-status ne 'P'.
*        message i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
*      else.
*        g_ans = 0.
*        g_error = 0.
*      endif.
*    endloop.
*
    IF g_ans = '0' AND g_error = '0'.
      UPDATE zmm_emddtl
           SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
               ri_crby   = sy-uname
               ri_cron   = sy-datum
                ri_reqno =  l_reqno
    WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans   AND
           item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDIF.

  ELSEIF  zmm_emdhdr-trans = 'EMD' AND p_ad = '2'.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF NOT ( wa_emddtl-status = 'S' OR wa_emddtl-status = 'P' ).
        MESSAGE i510(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
*        message i584(zmm).
*        g_ans = 1.
*        g_error = 1.
*        exit.
      ELSE.
        g_ans = 0.
        g_error = 0.
      ENDIF.
    ENDLOOP.

    IF g_ans = '0' AND g_error = '0'.
      UPDATE zmm_emddtl
           SET ri_stat   = l_status
** Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
*                 status    = lv_status
** End of addition by Saravanan M on 10/06/2009 - RD1K964254
               ri_crby   = sy-uname
               ri_cron   = sy-datum
                ri_reqno =  l_reqno
    WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans   AND
           item_no       = wa_emddtl-item_no  .

      IF sy-subrc = 0.
        MESSAGE s582(zmm) WITH l_text.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " update_req_ret_inv
*&---------------------------------------------------------------------*
*&      Form  MODIFY_TABLE_EMDDTL
*&---------------------------------------------------------------------*
*  Modify Internal table ist_emddtl for updating Requst for return/
*  Invoke field value
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_table_emddtl.


  DATA: ist_dtl TYPE TABLE OF zmm_emd_status WITH HEADER LINE.
  DATA : wa_dtl TYPE zmm_emd_status.
  SELECT * FROM zmm_emddtl INTO CORRESPONDING FIELDS OF TABLE ist_dtl
                   WHERE docno = g_idocno .

  IF sy-subrc  = 0.

    LOOP AT ist_dtl INTO wa_dtl.
      MODIFY ist_emddtl FROM wa_dtl TRANSPORTING
                        ri_stat ri_reqno status
                        WHERE docno = wa_dtl-docno AND
                        item_no = wa_dtl-item_no .
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MODIFY_TABLE_EMDDTL
*&---------------------------------------------------------------------*
*&      Form  check_Req_status
*&---------------------------------------------------------------------*
*       Check request for Return/Invoke exists.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_req_status.
  DATA l_found .
  l_found = 1.
  g_error = 0.

*&---> Check whether any line Item  selected or Not
  LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
    l_found = 0.
    EXIT.
  ENDLOOP.
*&----<
  IF l_found = 0.
    g_ans = 0.
  ELSE.
    g_ans = 1.
    MESSAGE i580(zmm).
  ENDIF.

  IF g_ans = 0.
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF NOT ( wa_emddtl-ri_stat = '1'
              OR wa_emddtl-ri_stat = '2' ) .
        g_ans = '1' .
        g_error = '1'.
        MESSAGE i581(zmm).
      ENDIF.

*+003
      IF NOT wa_emddtl-ri_reqno IS INITIAL AND
          wa_emddtl-ri_stat NE '3' .
        IF wa_emddtl-status = 'E'.
          g_ans = '1'.
          g_error = '1'.
          MESSAGE i591(zmm) WITH 'Return'.
        ELSEIF wa_emddtl-status = 'V'.
          g_ans = '1'.
          g_error = '1'.
          MESSAGE i592(zmm) WITH 'Invoke'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " check_Req_status
*&---------------------------------------------------------------------*
*&      Form  update_req_status
*&---------------------------------------------------------------------*
*       Update RI_STATUS , RI_REQNO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_req_status.

  LOOP AT  ist_emddtl  INTO wa_emddtl  WHERE sel = 'X'.
    UPDATE zmm_emddtl
           SET ri_stat   = '3'
               ri_reqno  = g_reqno
     WHERE docno          = wa_emdhdr-docno   AND
           trans         = wa_emdhdr-trans    AND
           item_no       = wa_emddtl-item_no  .

    IF sy-subrc = 0.
      MESSAGE s583(zmm) .
    ENDIF.

  ENDLOOP.
  CLEAR g_reqno.
ENDFORM.                    " update_req_status
*&---------------------------------------------------------------------*
*&      Form  change_doc_reqno
*&---------------------------------------------------------------------*
*      Maintain Change document on field ZRI_REQNO .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_doc_reqno.

  DATA: wa_ndtl TYPE zmm_emddtl ,
        wa_odtl TYPE zmm_emddtl ,
        wa_dtl  TYPE zmm_emd_status ,
        wa_tdtl TYPE zmm_emd_status ,
        l_objid TYPE cdhdr-objectid.
  DATA: l_obj(13).
  DATA : ist_cdtxt    TYPE TABLE OF cdtxt WITH HEADER LINE .

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = g_idocno sel = 'X'.

  MOVE-CORRESPONDING wa_dtl TO wa_ndtl.
  wa_ndtl-ri_reqno  = g_reqno.
  IF sy-subrc = 0.
    SELECT * FROM ZMM_EMDDTL INTO CORRESPONDING FIELDS OF WA_ODTL UP TO 1 ROWS
 WHERE DOCNO = WA_NDTL-DOCNO AND ITEM_NO = WA_NDTL-ITEM_NO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  ENDIF.
  l_objid = g_idocno .
  CALL FUNCTION 'ZRI_REQNO_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
*     OBJECT_CHANGE_INDICATOR = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZRI_REQNO    = ' '
      n_zmm_emddtl            = wa_ndtl
      o_zmm_emddtl            = wa_odtl
      upd_zmm_emddtl          = 'U'
    TABLES
      icdtxt_zri_reqno        = ist_cdtxt.


ENDFORM.                    " change_doc_reqno
*&---------------------------------------------------------------------*
*&      Form  display_chng_ri_history
*&---------------------------------------------------------------------*
*      Change History display for Return/Invoke Document.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_chng_ri_history.

  DATA :   i_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE   ,
           i_editpos TYPE TABLE OF cdshw WITH HEADER LINE ,
           ist_cdhdr TYPE TABLE OF cdhdr WITH HEADER LINE ,
           l_objid LIKE cdhdr-objectid ,
           l_obj(13).

  DATA : wa_header LIKE cdhdr ,
         wa_dtl TYPE zmm_emd_status.
  DATA : BEGIN  OF ist_editpos OCCURS 0 .
          INCLUDE STRUCTURE cdshw .
  DATA :  user LIKE sy-uname ,
          date LIKE sy-datum ,
          time LIKE sy-uzeit ,
  END OF ist_editpos .

  l_objid =  g_idocno.

  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass                = 'ZRI_REQNO'
      objectid                   = l_objid
      username                   = space
    TABLES
      i_cdhdr                    = i_cdhdr
    EXCEPTIONS
      no_position_found          = 1
      wrong_access_to_archive    = 2
      time_zone_conversion_error = 3
      OTHERS                     = 4.
  IF sy-subrc =  0.

    CLEAR : i_cdhdr .
    LOOP AT i_cdhdr .
      CLEAR : i_editpos, ist_editpos , wa_header .
      REFRESH i_editpos .
      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
        EXPORTING
          changenumber            = i_cdhdr-changenr
        IMPORTING
          header                  = wa_header
        TABLES
          editpos                 = i_editpos
        EXCEPTIONS
          no_position_found       = 1
          wrong_access_to_archive = 2
          OTHERS                  = 3.

      IF sy-subrc = 0.
        LOOP AT i_editpos WHERE fname = 'RI_REQNO' .
          MOVE-CORRESPONDING i_editpos TO ist_editpos.
          ist_editpos-user = wa_header-username .
          ist_editpos-date = wa_header-udate .
          ist_editpos-time = wa_header-utime .
          APPEND ist_editpos .
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

  WRITE : /5 'Document No. ' , 20 'Item no' ,
          25 'Request Number' , 45 'changed by' , 60 ' Date' ,
          75 ' Time'.

  WRITE : /5 sy-uline(95).
  LOOP AT ist_editpos .

    WRITE :/5 wa_emddtl-docno(10),
            20 ist_editpos-f_new+10(3) ,
            25 ist_editpos-f_new(16) ,
            45 ist_editpos-user(12)  ,
            60 ist_editpos-date(8)   ,
            75 ist_editpos-time(6).

  ENDLOOP.
ENDFORM.                    " display_chng_ri_history
*&---------------------------------------------------------------------*
*&      Form  check_inst_group_etend
*&---------------------------------------------------------------------*
*      Check Instrument Group Incase of e-Tenders
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_inst_group_etend.
*+004

  DATA: ist_emddtl_temp LIKE TABLE OF wa_emddtl.
*&--> Check Whether Instrument Type entered is from same Group or not
*&--> G1- DD,BC,CC G2-LC , G3-BG , G4-IP G5-IV G6-OP

**** check for Instrument type. This logic is laid for the reason
***** that no
***** (1) If Instrument type is DD then only BC and CC is permitted
***** (2) If Instrument is BG then only BG is permitted.
****  (3) IF Instrument is IV then only IV is permitted.

  DATA: ist_instgrp TYPE TABLE OF zmm_emddtl-inst_type.
  DATA:  wa_instgrp TYPE zmm_emddtl-inst_type.
  DATA: l_inst(20).
  DATA: l_fd  .
  REFRESH ist_instgrp.
  LOOP AT ist_emddtl INTO wa_emddtl.
    wa_instgrp  = wa_emddtl-inst_type.
    APPEND wa_instgrp  TO ist_instgrp.
  ENDLOOP.
  SORT ist_instgrp .
  DELETE ADJACENT DUPLICATES FROM ist_instgrp .
  LOOP AT ist_instgrp INTO wa_instgrp .
    CONCATENATE  l_inst
   wa_instgrp  INTO l_inst .
  ENDLOOP.

  IF NOT l_inst IS INITIAL.

    IF l_inst  = 'BCCCDD'  OR
       l_inst  = 'BCCC'    OR
       l_inst  = 'CCDD'    OR
       l_inst  = 'CCBC'    OR
       l_inst  = 'BCDD'    OR
       l_inst  = 'DD'      OR
       l_inst  = 'CC'      OR
       l_inst  = 'BC'      OR
       l_inst  = 'BG'      OR
       l_inst  = 'IP'      OR
       l_inst  = 'IV'      OR
       l_inst  = 'LC'     OR
       l_inst  = 'OP'.
      l_fd = 'X'.
      g_error = 1 .
    ELSE.
      g_error = 0.
      MESSAGE i426(zmm).
    ENDIF.
  ENDIF.
ENDFORM.                    " check_inst_group_etend
*&---------------------------------------------------------------------*
*&      Form  get_reqno
*&---------------------------------------------------------------------*
*       Get Request no.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_reqno.

  DATA: wa_dtl TYPE zmm_emddtl.
  CLEAR: wa_dtl,g_reqno.
* Start of change by SAB_SARVANAN 0n 12/06/2009
  SELECT * FROM ZMM_EMDDTL INTO WA_DTL UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO AND RI_REQNO NE ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT.
* End of change by SAB_SARVANAN 0n 12/06/2009
  IF sy-subrc = 0.
    IF NOT wa_dtl-ri_reqno IS INITIAL.
      IF  wa_dtl-ri_reqno+13(1) = 'R'.
        CONCATENATE g_idocno  wa_emddtl-item_no  'RC' INTO g_reqno .
      ELSEIF  wa_dtl-ri_reqno+13(1) = 'I'.
        CONCATENATE g_idocno  wa_emddtl-item_no  'IC' INTO g_reqno .
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_reqno
*&---------------------------------------------------------------------*
*&      Form  get_reqno_save
*&---------------------------------------------------------------------*
*       Get Request no at the time of creating request .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_reqno_save USING p_ad.
  DATA: l_status,
        l_text(15).
  CLEAR: l_text , l_status, g_reqno..
  DATA l_reqno  TYPE zmm_emddtl-ri_reqno.
  IF p_ad = 1.
    l_text = 'Return'.
    l_status = '1'.  "Request for Return
    CONCATENATE g_idocno  wa_emddtl-item_no  'RR' INTO g_reqno .
  ELSEIF p_ad = 2.
    l_text = 'Invoke'.
    l_status = '2'.  "Request for Invoke
    CONCATENATE g_idocno  wa_emddtl-item_no 'IR' INTO g_reqno .
  ENDIF.
ENDFORM.                    " get_reqno_save
*&---------------------------------------------------------------------*
*&      Form  get_bstyp
*&---------------------------------------------------------------------*
*       Get Document type
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bstyp.
  IF NOT  zmm_emdhdr-ebeln IS INITIAL.
    SELECT SINGLE  bstyp FROM ekko INTO g_bstyp
              WHERE  ebeln = zmm_emdhdr-ebeln .
  ENDIF.
ENDFORM.                    " get_bstyp
*&---------------------------------------------------------------------*
*&      Form  check_auth_RETURN
*&---------------------------------------------------------------------*
*       Authority Check at the time of EMD/SD BG Return
*----------------------------------------------------------------------*
*      -->P_ZMM_EMDHDR_TRANS  text
*----------------------------------------------------------------------*
FORM check_auth_return USING    p_trans   .
  CLEAR : g_firet,g_mmret .
  DATA: wa_dtl TYPE zmm_emd_status.
  DATA: l_msg(30).

  READ TABLE ist_emddtl INTO wa_dtl WITH KEY docno = zmm_emdhdr-docno
                                         sel = 'X'.
* IF status = 'Accepted by Bank or Denied by Bank , then allow Retur
* of BG of EMD Document. This Authorisation is with 'MM' under having
*Activity '02'.
  IF ( wa_dtl-status = 'A'  OR wa_dtl-status = 'Y' ) AND
       wa_dtl-trans = 'EMD' .
    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
           ID 'ACTVT' FIELD  '02'   .
    IF sy-subrc = 0 .
      g_mmret = 'X'.
    ENDIF.

*  ELSEIF wa_dtl-ri_stat = space OR wa_dtl-ri_stat = '3'  .
*    MESSAGE i588(zmm).
*    g_mmret = space .
*    MESSAGE e505(zmm).

  ELSEIF wa_dtl-status  = 'E'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e452(zmm).
  ELSEIF wa_dtl-status = 'V' .
    MESSAGE e443(zmm).
    g_ans = 1.
    g_error = 1.
  ELSEIF wa_dtl-status = 'N'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e497(zmm).
  ELSEIF wa_dtl-status = 'B'.
    g_ans = 1.
    g_error = 1.
    MESSAGE e447(zmm).
  ELSEIF wa_dtl-status = 'S' OR wa_dtl-status = 'P' OR
      wa_dtl-ri_stat = '1'.
    IF wa_dtl-status = 'S'.
      l_msg = 'Submitetd to FI'.
    ELSEIF  wa_dtl-status = 'P'.
      l_msg = 'Accepted by FI'.
    ELSEIF  wa_dtl-ri_stat = '1'.
      l_msg = 'Request for Return'.
    ENDIF.

    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
    ID 'ACTVT' FIELD  '16'   .
    IF sy-subrc = 0.
      g_firet = 'X'.
    ELSE.
      g_firet = space .
      g_ans = 1.
      g_error = 1.
      MESSAGE i513(zmm) WITH l_msg .
      MESSAGE e514(zmm) WITH l_msg .
    ENDIF.

  ELSEIF wa_dtl-status = 'Y'  AND
         wa_dtl-trans = 'SDT'.
    AUTHORITY-CHECK OBJECT 'ZMMBGLC'
    ID 'ACTVT' FIELD  '02'   .
    IF sy-subrc = 0 .
      g_mmret = 'X'.
    ELSE.
      PERFORM check_fi_athority.
    ENDIF.

  ELSE.
    g_mmret = space .
    MESSAGE e505(zmm).
  ENDIF.


* If Status is "Submitted to FI" or "Accepted by FI"  or ri_status =
*'1' or '2' then allow only FI person to Do Return.
*
* if wa_dtl-status = 'Y'  and
*         wa_dtl-trans = 'SDT'.
*    authority-check object 'ZMMBGLC'
*    id 'ACTVT' field  '02'   .
*    if sy-subrc = 0 .
*      g_mmret = 'X'.
*    else.
*      perform check_fi_athority.
*    endif.
*endif.


  IF wa_dtl-ri_reqno+14(1) = 'R' AND wa_dtl-status = 'P'.
*    authority-check object 'ZMMBGLC'
*            id 'ACTVT' field  '16'   .
    IF sy-subrc NE 0 .
      MESSAGE e512(zmm).
    ELSE.
      g_firet = 'X'.
    ENDIF.
  ENDIF.


*     if p_stat ne 'X'.
*        if wa_emddtl-status = 'S'.
*          g_ans = 1.
*          g_error = 1.
*          message i496(zmm).
*        elseif wa_emddtl-status = 'A'.
*          g_ans = 1.
*          g_error = 1.
*          message i450(zmm).
*        endif.


* if wa_dtl-inst_type = 'BG' and ( p_trans = 'EMD' or p_trans = 'SDT' )
*.
*    authority-check object 'ZMMBGLC'
*           id 'ACTVT' field  '16'   .
**
*    if sy-subrc ne 0 .
*      if wa_dtl-ri_stat ne '3' and wa_dtl-ri_reqno ne space.
*        if not ( wa_dtl-status = 'A' or wa_dtl-status = 'Y' ) .
*          message  e505(zmm).
*          elseif ( wa_dtl-status = 'A' ).
*             l_stat = space .
*           else.
*             l_stat = 'X'.
*        endif.
*      endif.
*    endif.
*  endif.
ENDFORM.                    " check_auth_RETURN
*&---------------------------------------------------------------------*
*&      Form  check_fI_athority
*&---------------------------------------------------------------------*
*       Check FI Authorization
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_fi_athority.
  AUTHORITY-CHECK OBJECT 'ZMMBGLC'
         ID 'ACTVT' FIELD  '16'   .
  IF sy-subrc = 0 .
    g_firet = 'X'.
  ELSE.
    MESSAGE e505(zmm).
  ENDIF.

ENDFORM.                    " check_fI_athority
*&---------------------------------------------------------------------*
*&      Form  CHECK_STATUS_BEFORE_UPDATE
*&---------------------------------------------------------------------*
*       cHECK Document Status before Request status Update
* Applicable for EMD BG/Lc .
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_status_before_update USING p_ad .

  IF zmm_emdhdr-trans = 'EMD' AND p_ad = '1'.
    "+003
    LOOP AT ist_emddtl INTO wa_emddtl WHERE sel = 'X'.
      IF  wa_emddtl-status = 'E'.
        MESSAGE i452(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status = 'V' .
        MESSAGE i443(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSEIF wa_emddtl-status NE 'P'.
        MESSAGE i584(zmm).
        g_ans = 1.
        g_error = 1.
        EXIT.
      ELSE.
        g_ans = 0.
        g_error = 0.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECK_STATUS_BEFORE_UPDATE
*&---------------------------------------------------------------------*
*&      Form  SEND_TO_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_to_srm .
  DATA l_logsys(32) TYPE c.
  IF zallow = 'Y'.
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
              WHERE  appl = 'SRM'.
    IF NOT l_logsys IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zmm_emdhdr-vendorno
        IMPORTING
          output = zmm_emdhdr-vendorno.

      CALL FUNCTION 'Z_UPDATE_TF_ERP' DESTINATION l_logsys
        EXPORTING
          iv_bid_no            = zmm_emdhdr-ebidno               "'char10
          iv_changed_by        = sy-uname
          iv_vendor_no         = zmm_emdhdr-vendorno             "'char10
          iv_amount            = zmm_emdhdr-amount
          iv_currency          = zmm_emdhdr-currency
          iv_payment_date      = sy-datum
          iv_payment_time      = sy-uzeit
        IMPORTING
          ev_success           = lv_srm_update_status
        EXCEPTIONS
          tender_not_published = 1
          tf_deadline_reached  = 2
          OTHERS               = 3.
    ENDIF.
  ENDIF.
ENDFORM.                    " SEND_TO_SRM
*&---------------------------------------------------------------------*
*&      Form  PASS_TO_SRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pass_to_srm .
  DATA l_logsys(32) TYPE c.
* Checking the valid E-bid & Vendor
  IF zallow = 'Y' AND prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'TFS'.
* Fetching the Logical system name from the table ZMM_LOGSYS
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
              WHERE  appl = 'SRM'.
* Checking value is initial
    IF NOT l_logsys IS INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zmm_emdhdr-vendorno
        IMPORTING
          output = zmm_emdhdr-vendorno.
* Function Module from SRM to pass the value
      CALL FUNCTION 'Z_UPDATE_TF_ERP' DESTINATION l_logsys
        EXPORTING
          iv_bid_no       = zmm_emdhdr-ebidno               "'char10
          iv_changed_by   = sy-uname
          iv_vendor_no    = zmm_emdhdr-vendorno             "'char10
          iv_amount       = zmm_emdhdr-amount
          iv_currency     = zmm_emdhdr-currency
          iv_payment_date = sy-datum
          iv_payment_time = sy-uzeit.
* IMPORTING
*   EV_SUCCESS                 =
* EXCEPTIONS
*   TENDER_NOT_PUBLISHED       = 1
*   TF_DEADLINE_REACHED        = 2
*   OTHERS                     = 3
    ENDIF.
  ENDIF.
ENDFORM.                    " PASS_TO_SRM

*&---------------------------------------------------------------------*
*&      Module  CHECK_APRV_STATUS  INPUT
*&---------------------------------------------------------------------*
* To check SD/PBG approval status
*----------------------------------------------------------------------*
MODULE check_aprv_status INPUT.

  IF zmm_emdhdr-trans = 'SDT'.

*Future date validation : LOA
    IF NOT zmm_emdhdr-loa_dt IS INITIAL.

      IF zmm_emdhdr-loa_dt GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-LOA_DT'.
        MESSAGE e981(zmm) WITH text-085.

      ENDIF.

    ENDIF.

* SD / PBG submission date > LOA date
    IF NOT zmm_emdhdr-loa_dt    IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-loa_dt.
        MESSAGE e979(zmm).
      ENDIF.

    ENDIF.

* Actual date of rcpt > LOA date
    IF NOT zmm_emdhdr-loa_dt    IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_rcpt_dt LT zmm_emdhdr-loa_dt.
        MESSAGE e980(zmm).
      ENDIF.

    ENDIF.

*Future date validation : Actual date of receipt
    IF NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_rcpt_dt GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-SD_PBG_RCPT_DT'.
        MESSAGE e981(zmm) WITH text-086.

      ENDIF.

    ENDIF.

*Future date validation : Date of approval
    IF NOT zmm_emdhdr-apprv_on IS INITIAL.

      IF zmm_emdhdr-apprv_on GT sy-datum.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_ON'.
        MESSAGE e981(zmm) WITH text-087.

      ENDIF.

    ENDIF.

    IF prev_okcode = 'CHAN'.
      MOVE zmm_emdhdr-loa_no         TO wa_emdhdr-loa_no.
      MOVE zmm_emdhdr-loa_dt         TO wa_emdhdr-loa_dt.
      MOVE zmm_emdhdr-sd_pbg_dt      TO wa_emdhdr-sd_pbg_dt.
      MOVE zmm_emdhdr-sd_pbg_rcpt_dt TO wa_emdhdr-sd_pbg_rcpt_dt.
      MOVE zmm_emdhdr-apprv_chk      TO wa_emdhdr-apprv_chk.
      MOVE zmm_emdhdr-apprv_by       TO wa_emdhdr-apprv_by.
      MOVE zmm_emdhdr-apprv_on       TO wa_emdhdr-apprv_on.
      MOVE zmm_emdhdr-remarks        TO wa_emdhdr-remarks.
    ENDIF.

    IF NOT zmm_emdhdr-sd_pbg_dt      IS INITIAL AND
       NOT zmm_emdhdr-sd_pbg_rcpt_dt IS INITIAL.

      IF zmm_emdhdr-sd_pbg_dt LT zmm_emdhdr-sd_pbg_rcpt_dt.

        PERFORM check_aprv_status USING g_pmc
                                        zmm_emdhdr-sd_pbg_dt
                                        zmm_emdhdr-sd_pbg_rcpt_dt
                                        zmm_emdhdr-apprv_chk
                                        zmm_emdhdr-apprv_by
                                        zmm_emdhdr-apprv_on
                                        zmm_emdhdr-remarks.

      ELSEIF zmm_emdhdr-sd_pbg_dt GE zmm_emdhdr-sd_pbg_rcpt_dt AND
             zmm_emdhdr-apprv_chk = 'Y'.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_CHK'.
        MESSAGE e011(zmm_emd).

      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CHECK_APRV_STATUS  INPUT

*&---------------------------------------------------------------------*
*&      Form  CHECK_APRV_STATUS
*&---------------------------------------------------------------------*
* To validate SD/PBG approval details
*----------------------------------------------------------------------*
*      -->P_PMC        PMC Flag('X' -Do validation/ ' ' - No Validation)
*      -->P_SD_PBG_DT  SD/PBG Submission deadline
*      -->P_RCPT_DT    Actual date of Receipt of SD/PBG
*      -->P_APPRV_CHK  Approved by competent authority Y / N
*      -->P_APPRV_BY   Approver
*      -->P_APPRV_ON   Approval date
*      -->P_REMARKS    Reason for Delay
*----------------------------------------------------------------------*
FORM check_aprv_status  USING    p_pmc
                                 p_sd_pbg_dt
                                 p_rcpt_dt
                                 p_apprv_chk
                                 p_apprv_by
                                 p_apprv_on
                                 p_remarks.
  DATA : l_days TYPE sy-tabix.

  l_days = p_rcpt_dt - p_sd_pbg_dt.

  IF l_days GT 0.

    IF p_apprv_chk IS INITIAL.

      SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_CHK'.
      MESSAGE e975(zmm).

    ENDIF.

    IF p_apprv_chk = 'Y' AND p_pmc = 'X'.

*Approver
      IF p_apprv_by IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_BY'.
        MESSAGE e976(zmm).

      ELSE.

        IF l_days LE 28.
          PERFORM chk_authority USING zmm_emdhdr-apprv_by
                                      'L1'.
        ELSE.
          PERFORM chk_authority USING zmm_emdhdr-apprv_by
                                      'DI'.
        ENDIF.

      ENDIF.

*Approval date
      IF p_apprv_on IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_ON'.
        MESSAGE e977(zmm).

      ENDIF.
*Reason for Delay
      IF p_remarks IS INITIAL.

        SET CURSOR FIELD 'ZMM_EMDHDR-REMARKS'.
        MESSAGE e978(zmm).

      ENDIF.

      zmm_emdhdr-status = 'N'.

    ELSE.

      zmm_emdhdr-status = '0'.

    ENDIF.

  ENDIF.

ENDFORM.                    " CHECK_APRV_STATUS

*&---------------------------------------------------------------------*
*&      Form  CHK_AUTHORITY
*&---------------------------------------------------------------------*
* To check User authorization
*----------------------------------------------------------------------*
*      -->P_USER   User ID
*      -->P_AUTH   L1/DI
*----------------------------------------------------------------------*
FORM chk_authority  USING   p_user
                            p_auth.

  AUTHORITY-CHECK OBJECT 'M_BANF_FRG' FOR USER p_user
           ID 'FRGCD' FIELD p_auth.

  IF sy-subrc NE 0.
    SET CURSOR FIELD 'ZMM_EMDHDR-APPRV_BY'.
    MESSAGE e976(zmm) WITH p_auth.
  ENDIF.

ENDFORM.                    " CHK_AUTHORITY

*&---------------------------------------------------------------------*
*&      Form  GET_STATUS
*&---------------------------------------------------------------------*
* Get Status text
*----------------------------------------------------------------------*
*      -->P_STAT    Status value
*      -->P_STATUS  Status text
*----------------------------------------------------------------------*
FORM get_status  USING    p_stat
                          p_status.

  DATA : l_domname  TYPE  dd07v-domname,
         l_domvalue TYPE  dd07v-domvalue_l,
         l_langu    TYPE  sy-langu,
         l_status   TYPE  dd07v-ddtext.

  l_domname  = 'ZCFLAG'.
  l_domvalue = p_stat.
  l_langu    = 'EN'.

  CALL FUNCTION 'GET_TEXT_DOMVALUE'
    EXPORTING
      domname         = l_domname
      domvalue        = l_domvalue
      langu           = l_langu
   IMPORTING
     txt             = l_status
* EXCEPTIONS
*   NOT_FOUND       = 1
*   OTHERS          = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE l_status TO p_status.

ENDFORM.                    " GET_STATUS

*&---------------------------------------------------------------------*
*&      Form  GET_LOV_APPROVE_BY
*&---------------------------------------------------------------------*
* Serach help on Approved by Competent Authority
*----------------------------------------------------------------------*
FORM get_lov_approve_by .

  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
                                         WITH  HEADER LINE.

  DATA : ist_field_tab LIKE STANDARD TABLE OF dfies
                                           WITH  HEADER LINE.
  DATA : BEGIN OF wa_object,
             apprv_by  TYPE agr_users-uname,
             ename     TYPE pa0001-ename,
           END OF wa_object.

  DATA : ist_object_f4 LIKE STANDARD TABLE OF wa_object
                            INITIAL SIZE 100.
  DATA : BEGIN OF wa_users,
               uname  TYPE pa0001-uname,
             END OF wa_users.

  DATA : ist_users LIKE TABLE OF wa_users.

  DATA : l_agr_name_1 TYPE agr_users-agr_name VALUE '%SRV%IND%1%',
         l_agr_name_2 TYPE agr_users-agr_name VALUE '%SRV%IND%DI'.

  DATA : l_pernr  TYPE pa0001-pernr.

  REFRESH : ist_object_f4,
            ist_return_tab,
            ist_users.

  SELECT uname FROM agr_users INTO TABLE ist_users
          WHERE agr_name LIKE l_agr_name_1 OR
                agr_name LIKE l_agr_name_2.

  SORT ist_users BY uname.

  DELETE ADJACENT DUPLICATES FROM ist_users COMPARING uname.

  LOOP AT ist_users INTO wa_users.

    CLEAR wa_object.

    MOVE wa_users-uname TO wa_object-apprv_by.
    MOVE wa_users-uname TO l_pernr.

    SELECT ENAME FROM PA0001 INTO WA_OBJECT-ENAME UP TO 1 ROWS
 WHERE PERNR = L_PERNR AND ENDDA GE SY-DATUM
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc EQ 0.
      APPEND wa_object TO ist_object_f4.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'APPRV_BY'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_EMDHDR-APPRV_BY'
      value_org       = 'S'
*     callback_form   = 'F4CALLBACK'
    TABLES
      value_tab       = ist_object_f4
      field_tab       = ist_field_tab
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  zmm_emdhdr-apprv_by =  ist_return_tab-fieldval.

ENDFORM.                    " GET_LOV_APPROVE_BY
*&---------------------------------------------------------------------*
*&      Form  MM_EKKO_ARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mm_ekko_arch .

  RANGES  : r_ebeln FOR ekko-ebeln.
  REFRESH :g_t_frange ,g_t_all_fields ,g_t_aind_str1_ais,l_t_as_key, it_ekko_arch.
  CLEAR :g_s_aind_str1_ais,g_s_all_fields,g_s_frange,g_s_as_key, it_ekko_arch.

  SELECT aind_str1~archindex aind_str1~itype aind_str1~skey
    INTO TABLE g_t_aind_str1_ais
    FROM aind_str1 JOIN aind_str2 ON aind_str1~archindex = aind_str2~archindex
    WHERE itype  = 'I'
      AND object = 'MM_EKKO'
      AND active = 'X'.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*  READ TABLE g_t_aind_str1_ais INTO g_s_aind_str1_ais  INDEX 2.
      READ TABLE g_t_aind_str1_ais INTO g_s_aind_str1_ais  INDEX 2.   "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
  IF sy-subrc NE 0.
    MESSAGE 'No Active Info Structure Found !' TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'AS_API_INFOSTRUC_FIND'
    EXPORTING
      i_fieldcat         = g_s_aind_str1_ais-skey
    IMPORTING
      e_all_fields       = g_t_all_fields
    EXCEPTIONS
      no_infostruc_found = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'No Info Structure Found !'           TYPE 'E'.
      WHEN 2. MESSAGE 'Info Structure Find - Error Other !' TYPE 'E'.
    ENDCASE.
  ENDIF.
  SORT g_t_all_fields.

  " Purchasing Document  zmm_emdhdr-ebeln
  IF zmm_emdhdr-ebeln IS NOT INITIAL.
    READ TABLE g_t_all_fields INTO g_s_all_fields WITH KEY fieldname = 'EBELN' BINARY SEARCH.
    IF sy-subrc EQ 0.
      REFRESH  g_s_frange-selopt_t.
      MOVE 'EBELN' TO g_s_frange-fieldname.
      r_ebeln-sign = 'I'.
      r_ebeln-option = 'EQ'.
      r_ebeln-high = zmm_emdhdr-ebeln.
      r_ebeln-low = zmm_emdhdr-ebeln.
      MOVE-CORRESPONDING r_ebeln TO g_s_selopt.
      APPEND  g_s_selopt  TO  g_s_frange-selopt_t.
      APPEND  g_s_frange   TO  g_t_frange.
      CLEAR g_s_frange.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'AS_API_READ'
    EXPORTING
      i_fieldcat                = g_s_aind_str1_ais-skey
      i_selections              = g_t_frange
    IMPORTING
      e_result                  = l_t_as_key[]
    EXCEPTIONS
      parameters_invalid        = 1
      no_infostruc_found        = 2
      field_missing_in_fieldcat = 3
      OTHERS                    = 4.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1. MESSAGE 'Paramaters Invalid !'             TYPE 'E'.
      WHEN 2. MESSAGE 'No Info Structure Found !'        TYPE 'E'.
      WHEN 3. MESSAGE 'Field Missing in Field Catelog !' TYPE 'E'.
      WHEN 4. MESSAGE 'Archive Read Error'               TYPE 'E'.
    ENDCASE.
  ENDIF.

  SORT l_t_as_key BY archivekey archiveofs .
  DELETE ADJACENT DUPLICATES FROM l_t_as_key COMPARING ALL FIELDS.

  LOOP AT l_t_as_key INTO g_s_as_key.
* read information from archive
    CALL FUNCTION 'ARCHIVE_READ_OBJECT'
      EXPORTING
        object         = 'MM_EKKO'
        archivkey      = g_s_as_key-archivekey
        offset         = g_s_as_key-archiveofs
      IMPORTING
        archive_handle = l_handle
      EXCEPTIONS
        OTHERS         = 1.

    IF sy-subrc <> 0.
      MESSAGE 'No Suitable Data Found in Archive !' TYPE 'E'.
    ELSE.
      CALL FUNCTION 'ARCHIVE_GET_TABLE'                     "#EC *
        EXPORTING
          archive_handle          = l_handle
          record_structure        = 'EKKO'
          all_records_of_object   = 'X'
          automatic_conversion    = 'X'
        TABLES
          table                   = ct_ekko
        EXCEPTIONS
          end_of_object           = 1
          internal_error          = 2
          wrong_access_to_archive = 3
          OTHERS                  = 4.

      APPEND LINES OF ct_ekko TO it_ekko_arch.

      REFRESH:  ct_ekko .
      CLEAR  :  ct_ekko .
    ENDIF.
  ENDLOOP.
  " MM_EKKO_RET

ENDFORM.                    " MM_EKKO_ARCH
