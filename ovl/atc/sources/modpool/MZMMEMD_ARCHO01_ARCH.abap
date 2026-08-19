*--- MAIN PROGRAM: MZMMEMD_ARCHO01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDO01                                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Status of screen 100.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  PERFORM   append_isttab_100.
  SET PF-STATUS 'S100' EXCLUDING ist_tab.
  SET TITLEBAR 'T100_01'.
  IF sy-ucomm = 'BACK'.
    PERFORM release_lock.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen element Attributes of Screen 100.
*----------------------------------------------------------------------*
MODULE set_screen_100 OUTPUT.

*&--> disable document field.
  LOOP AT SCREEN.
    IF screen-group1 = '001'.
      screen-active  = '0' .
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  IF ok_code = 'CHAN' OR ok_code = 'DISP' OR ok_code   = 'DELE' OR
     ok_code = 'REST' OR ok_code = 'BGLC' OR ok_code   = 'AMEND'.
    LOOP AT SCREEN.
      IF screen-group1    = '001'.
        screen-invisible = '0'  .
        screen-active    = '1'    .
        screen-input     = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
ENDMODULE.                 " set_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0105  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen element in Screen - 0105.
*----------------------------------------------------------------------*
MODULE set_screen_0105 OUTPUT.
*&--> Make  Table Control invisible in screen 105 IF Header data not *&
* entered.

  IF g_okhdr = 'X' OR g_tfxm = 'X'.
    tc_105-invisible = 0.
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS' OR screen-name = 'INSERT' OR
         screen-name = 'DELET' OR screen-name = 'COPY' OR
         screen-name = 'PASTE'.
        IF screen-group1 = 'I01'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR tc_105-invisible .

    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*&----------------------------------------------------------&*
* SRM Changes +002
*&----------------------------------------------------------&*

  IF sy-ucomm = 'TFEXM' AND g_okhdr NE 'X' AND g_tfxm NE 'X'.
    CLEAR tc_105-invisible .
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*&-- End of Change
*&----------------------------------------------------------&*


*&--< Make Input Field disable When Action is Display or
*   Delete or Reset
*&-->
  IF prev_okcode = 'DISP' OR g_reset = 1 OR
    prev_okcode  = 'DELE' OR ok_code = 'DELT'
    OR prev_okcode = 'REST'.
    CLEAR tc_105-invisible .

    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02' OR tc_col-screen-group2 = 'C02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
  IF  g_reset = '1'.                                        "27.01.04
    CLEAR tc_105-invisible .
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDHDR-CURRENCY'.
        CLEAR screen-input .
        CLEAR screen-active .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&-->  Disable input fields if trans is initial.

  LOOP AT SCREEN.
    IF  zmm_emdhdr-trans IS INITIAL .
      IF screen-group2 = 'G02'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE .
      IF screen-group2 = 'G02'.
        screen-input  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
*&--<

*&--<  Make  Insert and Delete button invisible if prev_okcode = 'DEL'.
*  OR Reset
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'
    OR prev_okcode = 'REST'  .
    LOOP AT SCREEN.
      IF screen-group2 = 'I02'.
        screen-invisible = 1.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.

*&--<  Make  Insert and Delete button Enable  if prev_okcode = 'CHAN'.
  IF prev_okcode = 'CHAN' AND  g_reset = 0.
    LOOP AT SCREEN.
      IF screen-group2 = 'I02'.
        screen-active = 1 .
        screen-input  = 1 .
        screen-invisible = 0.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--< Enable Field Created by&Created on active when disp,change,delete.
  IF prev_okcode = 'CHAN' OR
     prev_okcode = 'DISP' OR
     prev_okcode = 'DELE' .
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF  prev_okcode = 'CREA'.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&--> Enable filed zmm_emdhdr-place only when trans = 'TFS'.
  IF zmm_emdhdr-trans = 'TFS' .
    LOOP AT SCREEN .
      IF screen-name = 'PLACE' OR screen-name = 'ZMM_EMDHDR-PLACE' .
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN .
      IF screen-name = 'PLACE' OR screen-name = 'ZMM_EMDHDR-PLACE' .
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

*&----------------------------------------------------------------*&
* SRM Changes +002 1.11.2004
*This is applicable only to Tender Fee. Few vendors are exempted from
*Tender Fee. However, these vendors also should obtain a transaction
*number from tender fee application.

    CLEAR g_tfxm .
    LOOP AT SCREEN.
      IF screen-group4   = 'GTF'.
*         screen-invisible = 0.
        screen-active   = 0 .
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*&-------------------------------------------------------------*&
  ENDIF.
*&--<
*+007 : Start
  IF zmm_emdhdr-trans = 'SDT' AND
     ( prev_okcode = 'CREA' OR prev_okcode = 'CHAN' ).

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    IF zmm_emdhdr-apprv_chk = 'Y' AND prev_okcode = 'CHAN'.

      LOOP AT SCREEN.
        IF screen-group2 = 'SDT'.
          screen-input    = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ENDIF.

    IF prev_okcode = 'CREA'     OR
       ( prev_okcode = 'CHAN' AND
         ( zmm_emdhdr-status = 'N' OR zmm_emdhdr-status = '0' ) ).

      IF zmm_emdhdr-apprv_chk = 'N' OR
         zmm_emdhdr-apprv_chk IS INITIAL.

        LOOP AT SCREEN.
          IF screen-group3 = 'SDT'.
            screen-input     = '0'.
            screen-invisible = '1'.
            MODIFY SCREEN.
            CLEAR g_pmc.
          ENDIF.
        ENDLOOP.

      ELSEIF zmm_emdhdr-apprv_chk = 'Y'.

        LOOP AT SCREEN.
          IF screen-group3 = 'SDT'.
            screen-input     = '1'.
            screen-invisible = '0'.
            MODIFY SCREEN.
            g_pmc = 'X'.
          ENDIF.
        ENDLOOP.

      ENDIF.

    ELSE.

      LOOP AT SCREEN.
        IF screen-group4 = 'SDT'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ENDIF.
*    ELSEIF zmm_emdhdr-apprv_chk = 'Y'.
*
*      LOOP AT SCREEN.
*        IF screen-group2 = 'SDT'.
*          screen-input    = '1'.
*          screen-required = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.
*
*    ENDIF.

  ELSEIF zmm_emdhdr-trans = 'SDT' AND
         prev_okcode = 'DISP'.

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSE.

    LOOP AT SCREEN.
      IF screen-group1 = 'SDT'.
        screen-input     = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.
*+007 : End

ENDMODULE.                 " set_screen_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*     PF Status of Screen 0105
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  PERFORM modify_isttab.
  SET PF-STATUS 'S105' EXCLUDING ist_tab .
  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T105_01' WITH g_action  text-001  .
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T105_01' WITH  g_action text-002   .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T105_01' WITH  g_action text-003  .
    ENDIF.
  ELSE.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T105' WITH g_action  text-001 text-010 g_idocno.
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T105' WITH  g_action text-002 text-010 g_idocno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T105' WITH  g_action text-003 text-010 g_idocno.
    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc105_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move Data from Work area to Table Control
*----------------------------------------------------------------------*
MODULE tc105_move_data OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
  PERFORM get_item_status USING wa_emddtl-status .
  MOVE g_status TO  wa_emddtl-stat_desc.
  MOVE-CORRESPONDING wa_emddtl TO wa_tc105 .
  CLEAR g_status.
  LOOP AT SCREEN.
*&------> If the document status is N then only activate entire row
    IF prev_okcode = 'CHAN'  .
      IF  wa_emddtl-status NE 'N' AND  wa_emddtl-status NE space.
        IF screen-name NE 'WA_TC105-SEL' .
          screen-input = 0.
        ELSE.
          screen-input = 1.
        ENDIF.
      ELSE.
        screen-input = 1.
      ENDIF.
      IF    screen-name = 'WA_TC105-SEL' AND
          wa_tc105-status NE 'N'.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
*&------<
    IF screen-name = 'WA_TC105-STATUS'.
      screen-invisible = 1.
      MODIFY SCREEN.
    ELSE.
      screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*-------- Disable field BANK,BRANCH,ADDR1,ADDR2 when instrument is IV.
  LOOP AT SCREEN.
    IF wa_tc105-inst_type = 'IV'.
      IF screen-group1 = 'IV1'  .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
* Start of addition by Saravanan M on 08/04/2009
  IF l_result = '1' AND prev_okcode = 'ECREA'.
    zmm_emdhdr-trans = 'TFS'.
  ELSEIF l_result = '3' AND prev_okcode = 'ECREA'.
    zmm_emdhdr-trans = 'EMD'.
  ENDIF.
* End of addition by Saravanan M on 08/04/2009
ENDMODULE.                 " tc105_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_HEADER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*      Get Header Data
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.
  DESCRIBE TABLE ist_emddtl LINES tc_105-lines.

*---SRM CHANGES   +002
*--- Assign transaction as 'TFS' incase of E-Tender Receipt creation
*  if prev_okcode = 'ECREA'.
*    zmm_emdhdr-trans = 'TFS'.
*    loop at screen.
*      if screen-group2 = 'G02'.
*        screen-input  = 1.
*        modify screen.
*      endif.
*    endloop.
*  endif.
*----END OF CHANGES

  IF zmm_emdhdr-trans IS INITIAL.
    g_rfqpo      = 'RFQ/PO No'.
  ENDIF.
  IF zmm_emdhdr-trans = 'SDT'.
    g_rfqpo      = 'PO No.'.
  ELSE.
    g_rfqpo      = 'RFQ No'.
  ENDIF.
*---- get location name.
  SELECT SINGLE locds FROM zmm_location INTO g_locname
              WHERE loccd  = wa_emdhdr-place .

*&--> Get Header Data from subroutine get_data in PAI screen 100.
*&--< For Display,Change,Delete
  IF prev_okcode  = 'DISP' OR prev_okcode = 'CHAN' OR
     prev_okcode  = 'DELE' OR prev_okcode = 'REST'.
    MOVE zmm_emdhdr-currency TO wa_emdhdr-currency.
    MOVE zmm_emdhdr-place   TO  wa_emdhdr-place   .
    wa_emdhdr-trans = zmm_emdhdr-trans.
    wa_emdhdr-ebeln = zmm_emdhdr-ebeln .
*---SRM Changes
    IF g_ttype = 'R3' OR g_ttype IS INITIAL.
      MOVE-CORRESPONDING wa_emdhdr TO zmm_emdhdr    .
    ENDIF.
    IF g_ttype = 'SRM'.
      PERFORM get_vendor_name .
    ENDIF.
*-------End of SRM Changes -----------------------------------*
    PERFORM get_vendorno_tenderno.
*&----> Get Status descr of Header.

* Begin of <RD1K963111>
    DATA lv_status TYPE zmm_emdref-status.
    DATA lv_index TYPE i.
    DATA g_hstatus_text TYPE text.
    DATA lv_lines TYPE i.
    DATA lv_status1 TYPE zmm_emddtl-status.
    DATA lv_status2 TYPE zmm_emddtl-status.
    DATA ref_status  TYPE text.
    DATA g_hstatus_doc TYPE zdoc_no.
    DATA ref_value TYPE zdoc_no.
    DATA g_hdate(10) TYPE c.
    DATA ref_date(10) TYPE c.

    CLEAR ref_value.
    CLEAR g_hstatus_doc.
    CLEAR ref_status.
    CLEAR lv_status2.
    CLEAR lv_status1.
    CLEAR lv_lines.
    CLEAR g_hstatus_text.
    CLEAR lv_index.
    CLEAR lv_status.
    CLEAR g_hdate.
    CLEAR ref_date.

    SELECT  * FROM zmm_emdref INTO TABLE lt_emdref
                 WHERE refdoc = zmm_emdhdr-docno ORDER BY PRIMARY KEY.

    DESCRIBE TABLE lt_emdref LINES lv_index.
    IF lv_index = 1.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 1.
      IF wa_emdref-rfcstat = 'R'.
        g_hstatus_text = 'Refund'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        g_hstatus_text = 'Forfeiture'.
        wa_emdhdr-status = wa_emdref-status.
        g_hstatus_doc = wa_emdref-docno.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        g_hstatus_text = 'SD Conversion'.
        wa_emdhdr-status = wa_emdref-status.
        g_hstatus_doc = wa_emdref-docno.
        g_hdate = wa_emdref-rfccron.
      ENDIF.

    ELSEIF lv_index > 1.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 1.
*      loop at lt_emdref into wa_emdref.
      IF wa_emdref-rfcstat = 'R'.
        g_hstatus_text = 'Refund'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        g_hstatus_text = 'Forfeiture'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        g_hstatus_text = 'SD Conversion'.
        g_hstatus_doc = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        g_hdate = wa_emdref-rfccron.
      ENDIF.
*      endloop.
      CLEAR wa_emdref.
      READ TABLE lt_emdref INTO wa_emdref INDEX 2.
      IF wa_emdref-rfcstat = 'R'.
        ref_status = 'Refund'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'F'.
        ref_status = 'Forfeiture'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ELSEIF wa_emdref-rfcstat = 'C'.
        ref_status = 'SD Conversion'.
        ref_value = wa_emdref-docno.
        wa_emdhdr-status = wa_emdref-status.
        ref_date = wa_emdref-rfccron.
      ENDIF.

    ELSEIF lv_index = 0.
      SELECT * FROM zmm_emddtl INTO TABLE lt_emddtl WHERE docno = zmm_emdhdr-docno ORDER BY PRIMARY KEY.
      DESCRIBE TABLE lt_emddtl LINES lv_lines.
      IF lv_lines > 1.
        READ TABLE lt_emddtl INTO wa_emddtl1 INDEX 1.
        lv_status1 = wa_emddtl1-status.
        CLEAR wa_emddtl1.
        LOOP AT lt_emddtl INTO wa_emddtl1 WHERE status = lv_status1.
          lv_status2 = wa_emddtl1-status.
          IF lv_status1 = lv_status2.
            CLEAR lv_status2.
            CONTINUE.
          ELSEIF lv_status1 <> lv_status2.
            CLEAR lv_status1.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_status2 IS NOT INITIAL.
          IF wa_emddtl-status = 'R'.
            ref_status = 'Refund'.
            wa_emdhdr-status = wa_emddtl1-status.
          ELSEIF wa_emddtl-status = 'F'.
            ref_status = 'Forfeiture'.
            wa_emdhdr-status = wa_emddtl1-status.
          ELSEIF wa_emddtl-status = 'C'.
            ref_status = 'SD Conversion'.
            wa_emdhdr-status = wa_emddtl1-status.
          ENDIF.
        ELSEIF lv_status2 IS INITIAL.
          CLEAR ref_status.
          CASE wa_emdhdr-status..
            WHEN 'N'.
              ref_status        = text-040.  "Receipt
            WHEN 'B'.
              ref_status        = text-036.  "Send for Bank Confirmation' .
            WHEN 'A'.
              ref_status        = text-037 . "'Acceped By Bank'.
            WHEN  'Y'.
              ref_status        = text-038 . " 'Denied  By Bank'.
            WHEN  'V'.
              ref_status       =  text-039 . "'Invoked'.
            WHEN 'S'.
              ref_status       =  text-043 .  "Submitted to FI
            WHEN 'I'.
              ref_status       =  text-054 .  "Parked to FI
            WHEN 'D'.
              ref_status       =  text-047 .   "Deleted
            WHEN 'R'.
              ref_status      =  text-015.    "Refund
            WHEN 'F'.
              ref_status       =  text-016.    "Forfeit
            WHEN 'C'.
              ref_status       =  text-017.    "Convert
            WHEN 'P'.
              ref_status      =  text-061.    "Accepted by FI
            WHEN 'E'.
              ref_status      =  text-058.    "Return BG/LC Document.
            WHEN 'U'.
              ref_status      = text-049. " Fully parked
            WHEN 'K'.
              ref_status     = text-055.
          ENDCASE.
        ENDIF.
      ELSEIF lv_lines = 1.
        CLEAR wa_emddtl1.
        READ TABLE lt_emddtl INTO wa_emddtl1 INDEX 1.
*        ref_status = wa_emddtl-status.
        CLEAR ref_status.
        CASE wa_emddtl1-status.
          WHEN 'N'.
            ref_status        = text-040.  "Receipt
          WHEN 'B'.
            ref_status        = text-036.  "Send for Bank Confirmation' .
          WHEN 'A'.
            ref_status        = text-037 . "'Acceped By Bank'.
          WHEN  'Y'.
            ref_status        = text-038 . " 'Denied  By Bank'.
          WHEN  'V'.
            ref_status       =  text-039 . "'Invoked'.
          WHEN 'S'.
            ref_status       =  text-043 .  "Submitted to FI
          WHEN 'I'.
            ref_status       =  text-054 .  "Parked to FI
            ref_value = wa_emddtl1-fi_parkno.
            ref_date  = wa_emddtl1-fi_parkdt.
          WHEN 'D'.
            ref_status       =  text-047 .   "Deleted
          WHEN 'R'.
            ref_status      =  text-015.    "Refund
          WHEN 'F'.
            ref_status       =  text-016.    "Forfeit
          WHEN 'C'.
            ref_status       =  text-017.    "Convert
          WHEN 'P'.
            ref_status      =  text-061.    "Accepted by FI
          WHEN 'E'.
            ref_status      =  text-058.    "Return BG/LC Document.
          WHEN 'U'.
            ref_status      = text-049. " Fully parked
          WHEN 'K'.
            ref_status     = text-055.
        ENDCASE.
      ENDIF.
    ENDIF.

    IF ref_date IS NOT INITIAL.
      CONCATENATE ref_date+6(2) '/' ref_date+4(2) '/' ref_date+0(4) INTO ref_date.
    ENDIF.
    IF g_hdate IS NOT INITIAL.
      CONCATENATE g_hdate+6(2) '/' g_hdate+4(2) '/' g_hdate+0(4) INTO g_hdate.
    ENDIF.
*g_hdate
* End of <RD1K963111>

    PERFORM get_head_status USING wa_emdhdr-status.
*&-----<
    LOOP AT SCREEN.
      IF screen-group2 = 'G02' OR screen-group2 = 'DT2'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 0.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&-->  Make Item Detail Frame Enable when Display/Change or Delete
  IF prev_okcode  = 'DISP' OR prev_okcode = 'CHAN' OR
      prev_okcode  = 'DELE'.
    LOOP AT SCREEN.
      IF screen-name = 'ITEMDTLS'.
        IF screen-group1 = 'I01'.
          screen-active  = 1.
          screen-invisible   = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*&--> Make Fields CURRENCY AND PLACE enable AT Header Level IF
*& WHEN 'CHANGE' MODE .
  IF prev_okcode = 'CHAN' AND g_reset NE 1.
    CLEAR tc_105-invisible .
    LOOP AT SCREEN.
      IF screen-group3 = 'G03'.
        screen-input   = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT tc_105-cols INTO tc_col.
      IF tc_col-screen-group2 = 'G02'.
        tc_col-screen-input = 1.
        MODIFY tc_105-cols FROM tc_col.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&--<
*----------------------------------------------------------------*
*  IF Status at header level is Full Refund/Forfeit/EMD-SD Conv ..
* the don't allow for change in Change Mode.
  IF prev_okcode = 'CHAN' .
    IF wa_emdhdr-status = 'K' OR
       wa_emdhdr-status = 'Q' OR
       wa_emdhdr-status = space.    "Document Completed.
      LOOP AT SCREEN.
        IF screen-group3 = 'G03'.
          screen-input   = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

*  Changes by SAB_RAHUL on 15.04.2006
  IF prev_okcode = 'CHAN' .
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDHDR-TRANS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*  End Changes by SAB_RAHUL RD1K935395

* Start of Addition by SAB_SARVANAN on 18/06/2009
  DATA g_header_text TYPE string.
  CLEAR g_header_text.
  CASE wa_emdhdr-status.
    WHEN 'A'.
      g_header_text = 'Accepted by Bank'.
    WHEN 'B'.
      g_header_text = 'Send to Bank For Confirmation (BG/LC)'.
    WHEN 'C'.
      g_header_text = 'EMD to SD Conversion'.
    WHEN 'D'.
      g_header_text = 'Delete'.
    WHEN 'E'.
      g_header_text = 'Return (BG/LC)'.
    WHEN 'F'.
      g_header_text = 'Forfeiture'.
    WHEN 'G'.
      g_header_text = 'Request for BG/LC Return'.
    WHEN 'H'.
      g_header_text = 'Request for BG/LC Invoke'.
    WHEN 'I'.
      g_header_text = 'Document parked in FI'.
    WHEN 'J'.
      g_header_text = 'Document completed'.
    WHEN 'K'.
      g_header_text = 'Partially  Parked'.
    WHEN 'L'.
      g_header_text = 'Partial Refund'.
    WHEN 'M'.
      g_header_text = 'Partial Forfeit'.
    WHEN 'N'.
      g_header_text = 'Receipt/Deposit'.
    WHEN 'O'.
      g_header_text = 'Full Refund'.
    WHEN 'P'.
      g_header_text = 'Accepted by FI BG/LC'.
    WHEN 'Q'.
      g_header_text = 'Document in process'.
    WHEN 'R'.
      g_header_text = 'Refund'.
    WHEN 'S'.
      g_header_text = 'Submitted to FI (BG/LC)'.
    WHEN 'T'.
      g_header_text = 'Fully Forfeit'.
    WHEN 'U'.
      g_header_text = 'Fully Parked'.
    WHEN 'V'.
      g_header_text = 'Invoke'.
    WHEN 'W'.
      g_header_text = 'Request for BG/LC  Return & Invoke'.
    WHEN 'X'.
      g_header_text = 'Fully Converted to SD'.
    WHEN 'Y'.
      g_header_text = 'Deny by Bank'.
    WHEN 'Z'.
      g_header_text = 'Partial Return / Invoke (BG/LC)'.
  ENDCASE.
* End of Addition by SAB_SARVANAN on 18/06/2009
ENDMODULE.                 " GET_HEADER_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0106  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  PERFORM   append_isttab_110.
  SET PF-STATUS 'S110' EXCLUDING ist_tab.
  SET TITLEBAR 'T110_01' WITH text-019 zmm_emdhdr-docno.
  IF g_doccat =  text-015.
    SET TITLEBAR 'T110_01' WITH text-015 zmm_emdhdr-docno.
  ELSEIF g_doccat = text-016.
    SET TITLEBAR 'T110_01' WITH text-016 zmm_emdhdr-docno.
  ELSEIF g_doccat =  text-018.
    SET TITLEBAR 'T110_01' WITH text-017 zmm_emdhdr-docno.
  ENDIF.
ENDMODULE.                 " status_0106  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0110  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen - 0110.
*----------------------------------------------------------------------*
MODULE set_screen_0110 OUTPUT.
*&-----> iF INPUT is valid  Document the set amount field Active
  IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL   .
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' OR  screen-group2 = 'G02' OR
         screen-group1 = 'D01'.
        screen-invisible   = 1.
        screen-active     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' OR  screen-group2 = 'G02' OR
         screen-group1 = 'D01'.
        screen-invisible   = 0.
        screen-active     = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF ok_code NE 'CRET'.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-invisible = 1.
        screen-active   = 0 .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-invisible = 0.
        screen-active   = 1 .
        screen-input    = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_ref =  1.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-invisible = 1.
        screen-active   = 0 .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&-------<
  IF g_ref = 0 AND g_doccat = text-018.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-invisible = 0.
        screen-active   = 1 .
        screen-input    = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-invisible = 1.
        screen-active   = 0 .
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&-------<

* Start of Addition by SAB_SARVANAN on 18/06/2009
  IF zmm_emdhdr-trans = 'TFS' AND sy-dynnr = '0110' AND zmm_emdref-rscode = 120.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_EMDREF-AMOUNT'.
        screen-active   = 1.
        screen-input   = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
* End of addition by SAB_SARVANAN on 18/06/2009
ENDMODULE.                 " set_screen_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  lov_values  OUTPUT
*&---------------------------------------------------------------------*
*       List of Values in List Box
*----------------------------------------------------------------------*
MODULE lov_values OUTPUT.
  REFRESH : g_task_list.
  g_task_cd = 'G_DOCCAT'.
  g_task_value = text-015.
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  g_task_value = text-016 .
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  g_task_value = text-018 .
  APPEND g_task_value TO g_task_list.
  CLEAR g_task_value.
  PERFORM set_values.
  CLEAR g_task_value.
ENDMODULE.                 " lov_values  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0115  OUTPUT
*&---------------------------------------------------------------------*
*       Status of screen 0115.
*----------------------------------------------------------------------*
MODULE status_0115 OUTPUT.
  DATA: l_stext(30).
  PERFORM   append_isttab_115.
  IF zmm_emdref-rfcstat = 'N'.
    l_stext = text-040.
  ELSEIF zmm_emdref-rfcstat = 'R'.
    l_stext = text-015.
  ELSEIF zmm_emdref-rfcstat = 'F'.
    l_stext = text-016.
  ELSEIF zmm_emdref-rfcstat = 'C'.
    l_stext = text-017.
  ENDIF.
  g_docno = zmm_emdref-docno .
  SET PF-STATUS 'S115' EXCLUDING ist_tab.
  SET TITLEBAR 'T115_01' WITH text-020.
  IF  prev_okcode = 'CHNG'.
    SET TITLEBAR 'T110_01' WITH text-020 g_docno l_stext.
  ELSEIF prev_okcode = 'DISP'.
    SET TITLEBAR 'T110_01' WITH text-021  g_docno l_stext.
  ELSEIF prev_okcode  = 'DELE'.
    SET TITLEBAR 'T110_01' WITH text-022  g_docno l_stext.
  ELSEIF prev_okcode = 'UNDEL'.
    SET TITLEBAR 'T110_01' WITH text-053 g_docno l_stext .
  ENDIF.
ENDMODULE.                 " status_0115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0115  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes depending upon action
*----------------------------------------------------------------------*
MODULE set_screen_0115 OUTPUT.
*&---> Make All fields in Display mode When 'Disp' option selected.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE' OR
     prev_okcode = 'UNDEL  '.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-input     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_rfc_chk = 1.
    LOOP AT SCREEN.
      IF screen-group2 = 'G02'.
        screen-active    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF g_rfc_chk = 0.
    LOOP AT SCREEN.
      IF screen-group1 = 'D01'.
        screen-active    = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*&----<
  PERFORM get_ref_doc_stat USING g_docno .
* Begin of <RD1K963111> on 05/05/2009 - Solman Call No : 30000998
  IF zmm_emdref-rscode IS NOT INITIAL.
    DATA lv_text TYPE zrcdesc.
    SELECT * FROM ZMM_EMDRSCODE UP TO 1 ROWS

 WHERE RSCODE = ZMM_EMDREF-RSCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    lv_text = zmm_emdrscode-descr.
  ENDIF.
* End of <RD1K963111> on 05/05/2009 - Solman Call No : 30000998
ENDMODULE.                 " set_screen_0115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_data OUTPUT.
  IF sy-dynnr = '0105'.
    zmm_emdhdr-cron = g_crea_on .
    zmm_emdhdr-crby = g_crea_by .
    zmm_emdref-rfcchby = g_chan_by .
    zmm_emdref-rfcchon = g_chan_on .
    g_status = g_stat .
  ENDIF.
ENDMODULE.                 " DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0125 OUTPUT.
  SET PF-STATUS 'S0125'.
ENDMODULE.                 " STATUS_0125  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc115_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move Data
*----------------------------------------------------------------------*
MODULE tc120_move_data OUTPUT.
  PERFORM get_item_status USING wa_emdref_02-status .
  MOVE g_status TO  wa_emdref_02-stat_desc.
  g_lines = g_lines + 1.
  IF NOT   wa_emdref_02-refdoc IS INITIAL.
    wa_emdref_02-itemno = g_lines   .
  ENDIF.
  IF  wa_emdref_02-docno IS INITIAL.
    CLEAR  wa_emdref_02.
  ENDIF.
  MOVE-CORRESPONDING wa_emdref_02 TO wa_emdref_01.
  CLEAR g_status.
ENDMODULE.                 " tc115_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*       PF STATUS OF  SCREEN 120.
*----------------------------------------------------------------------*
MODULE status_0120 OUTPUT.
  MOVE 'SAVE' TO wa_tab-fcode.
  APPEND wa_tab   TO ist_tab .
  SET PF-STATUS 'S120'  EXCLUDING ist_tab.
  SET TITLEBAR 'T120'.
ENDMODULE.                 " STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_0115_TS  OUTPUT
*&---------------------------------------------------------------------*
*      DISABLE TAB STRIP CONTROL INITIALLY
*----------------------------------------------------------------------*
MODULE set_screen_0115_ts OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'SUB_RFC'.
      screen-invisible  = 1.
      screen-active = 0.
      ts_115-invisible = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " SET_SCREEN_0115_TS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_135  OUTPUT
*&---------------------------------------------------------------------*
*      Status of Screen
*----------------------------------------------------------------------*
MODULE status_135 OUTPUT.
  PERFORM  append_isttab_135.
  SET PF-STATUS 'S135' EXCLUDING ist_tab.
  SET TITLEBAR  'T135' WITH g_idocno.
ENDMODULE.                 " status_135  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_135  OUTPUT
*&---------------------------------------------------------------------*
*       Set Screen Attributes OF screen 135
*----------------------------------------------------------------------*
MODULE set_screen_135 OUTPUT.
  LOOP AT SCREEN.
    IF screen-group2 = 'G02' OR screen-group2 = 'DT2'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " set_screen_135  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_HEADER_INFO  OUTPUT
*&---------------------------------------------------------------------*
*      Get Header Information on screen 0135.
*----------------------------------------------------------------------*
MODULE get_header_info OUTPUT.
  PERFORM get_vendorno_tenderno.
ENDMODULE.                 " GET_HEADER_INFO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc135_move_data  OUTPUT
*&---------------------------------------------------------------------*
*      Move data into Table control
*----------------------------------------------------------------------*
MODULE tc135_move_data OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
*&------> If Status is B disable Sel Check box in disable mode.
*-------> Already send for Bank Confirmation
  LOOP AT SCREEN.
    IF screen-name = 'WA_TC135-CHECK'.
      IF wa_emddtl-status    =  'B' OR
         wa_emddtl-status    =  'A' OR
         wa_emddtl-status    =  'V' OR
         wa_emddtl-status    =  'Y' OR
         wa_emddtl-status    =  'S' OR
         wa_emddtl-status    =  'E' OR
         wa_emddtl-status    =  'P' OR
         wa_emddtl-inst_type = 'LC'.
        IF wa_emddtl-check NE 'X' OR wa_emddtl-check = space  .
          screen-input = '0'.
        ENDIF.
      ELSE.
        screen-input = '1' .
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'WA_TC135-STATUS'.
      screen-invisible  = 1.
      MODIFY SCREEN.
    ENDIF.
*+004
*    IF screen-name = 'WA_TC135-CHECK'.
*      IF wa_emddtl-status    =  'B' .
*        screen-input = '0'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDIF.
*+004

  ENDLOOP.
*&------<
  MOVE-CORRESPONDING wa_emddtl TO wa_tc135 .
ENDMODULE.                 " tc135_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_140  OUTPUT
*&---------------------------------------------------------------------*
*       GUI status of Dialog screen 140
*----------------------------------------------------------------------*
MODULE status_140 OUTPUT.
  SET PF-STATUS 'S140'.
  SET TITLEBAR  'T140'.
ENDMODULE.                 " status_140  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0145  OUTPUT
*&---------------------------------------------------------------------*
*       Status of screen 145
*----------------------------------------------------------------------*
MODULE status_0145 OUTPUT.
  SET PF-STATUS 'S145'.
  SET TITLEBAR  'T145' WITH zmm_emdhdr-docno.
ENDMODULE.                 " status_0145  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  tc105_move_data_S145  OUTPUT
*&---------------------------------------------------------------------*
*      move Internal table data into table control
*----------------------------------------------------------------------*
MODULE tc145_move_data_s145 OUTPUT.
  wa_emddtl-currency = zmm_emdhdr-currency .
  MOVE-CORRESPONDING wa_emddtl TO wa_tc145 .
*&-----> Make field STATUS Invisible
  LOOP AT SCREEN.
    IF screen-name  = 'WA_TC145-STATUS' .
      screen-invisible = 1.
    ELSE.
      screen-invisible = 0.
    ENDIF.
    IF NOT ( wa_tc145-status = 'P' OR wa_tc145-status = 'A' )
       AND  screen-name  NE 'WA_TC145-STATUS' .
      screen-input = 0.
    ELSE.
      screen-input = 1.
    ENDIF.
    MODIFY SCREEN.
    IF screen-name = 'WA_TC145-SEL'.
      screen-input = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " tc105_move_data_S145  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BALANCE_AMT  OUTPUT
*&---------------------------------------------------------------------*
*      Check Balance Amount.
*----------------------------------------------------------------------*
MODULE check_balance_amt OUTPUT.
  PERFORM check_rfc_amount  .
ENDMODULE.                 " CHECK_BALANCE_AMT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0150 OUTPUT.
  SET PF-STATUS 'S150' EXCLUDING ist_tab.
  SET TITLEBAR 'T150'.
ENDMODULE.                 " STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_parameter  OUTPUT
*&---------------------------------------------------------------------*
*      Get parameter for TFS/EMD/SD Documents.
*----------------------------------------------------------------------*
MODULE get_parameter OUTPUT.
  IF zmm_emdhdr-docno IS INITIAL.
    GET PARAMETER ID 'ZMMTESDOC' FIELD  zmm_emdhdr-docno.
  ENDIF.
  UNPACK zmm_emdhdr-docno TO zmm_emdhdr-docno.
ENDMODULE.                 " get_parameter  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0155  OUTPUT
*&---------------------------------------------------------------------*
*       PF Status of Screen 155
*----------------------------------------------------------------------*
MODULE status_0155 OUTPUT.
  PERFORM modify_isttab.
  SET PF-STATUS 'S155' EXCLUDING ist_tab.
* set titlebar 'T155'.

  IF prev_okcode = 'CREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T155_01' WITH g_action  text-001  .
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T155_01' WITH  g_action text-002   .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T155_01' WITH  g_action text-003  .
    ENDIF.
  ELSE.
    IF zmm_emdhdr-trans = 'TFS'.
      SET TITLEBAR 'T155' WITH g_action  text-068 text-010 g_idocno.
    ELSEIF zmm_emdhdr-trans = 'EMD'.
      SET TITLEBAR 'T155' WITH  g_action text-002 text-010 g_idocno .
    ELSEIF zmm_emdhdr-trans = 'SDT'.
      SET TITLEBAR 'T155' WITH  g_action text-003 text-010 g_idocno.
    ENDIF.
  ENDIF.
ENDMODULE.                 " status_0155  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_SRM  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes for SRM Screen 0155.
*----------------------------------------------------------------------*
MODULE set_screen_srm OUTPUT.
  LOOP AT SCREEN.
    IF screen-group4 =  'SR1' .
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " SET_SCREEN_SRM  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  status_0160  OUTPUT
*&---------------------------------------------------------------------*
*      PF Status of Screen 0160
*----------------------------------------------------------------------*
MODULE status_0160 OUTPUT.
  PERFORM append_itab_s160.
  SET PF-STATUS 'S160' EXCLUDING ist_tab .
  IF prev_okcode = 'ECREA'.
    SET TITLEBAR 'T160_A' WITH text-073.
  ELSEIF prev_okcode = 'CHAN'.
    SET TITLEBAR 'T160' WITH text-020 text-074 g_idocno.
  ELSEIF prev_okcode = 'DISP'.
    SET TITLEBAR 'T160' WITH text-021 text-074 g_idocno.
  ELSEIF prev_okcode = 'DELE'.
    SET TITLEBAR 'T160' WITH text-022 text-074 g_idocno.
  ELSEIF prev_okcode = 'REST'.
    SET TITLEBAR 'T160' WITH text-026 text-074 g_idocno.
  ENDIF.
ENDMODULE.                 " status_0160  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_0160  OUTPUT
*&---------------------------------------------------------------------*
*      Set Screen Attributes
*----------------------------------------------------------------------*
MODULE set_screen_0160 OUTPUT.
  zmm_emdhdr-trans = 'TFS'.
  IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01'.
        screen-input = 1.
        MODIFY SCREEN .
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " set_screen_0160  OUTPUT
