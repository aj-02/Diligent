*--- MAIN PROGRAM: MZMMEMD_ARCHI01_ARCH ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMEMDI01                                                 *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*               Modification Log
*----------------------------------------------------------------------*
*  Date          Transport Request     User ID              Description
* 08/04/2009       RD1K963111          SAB_SARVANAN
* Description : Added EMD Radio Button in the pop-up and written the logic
*               for the same
* 28.01.2014  Sudhir Sharma   CR 30010442
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*      User command of Screen - 100
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
*  data: l_result .
  DATA: l_srm_tfs    .
  g_error = 1.
  g_okhdr = 'X'.
  CLEAR l_result.
  ok_code = sy-ucomm .
  PERFORM clear_table.
  CLEAR g_hstatus .
  CASE ok_code.
    WHEN 'CREA'.
      prev_okcode = ok_code      .
      CLEAR ok_code .
      g_action     = 'Create'     .
      PERFORM fill_ist_emddtl     .
      CALL SCREEN '0105'.
    WHEN 'ECREA'.
      prev_okcode = ok_code      .
      CLEAR ok_code .
      g_action     = 'Create'     .
      PERFORM fill_ist_emddtl     .
*&-- SRM Changes 1.11.04
      PERFORM get_options CHANGING l_result.
      IF l_result = '1'.
        CALL SCREEN '0155'.
      ELSEIF l_result = 2.
        CALL SCREEN '0160'.
      ELSEIF l_result = 3.
* Start of Comment by Saravanan M on 08/04/2009
*        leave to screen '0100'.
* End of Comment by Saravanan M on 08/04/2009
        CALL SCREEN '0155'.
      ELSE.
        LEAVE TO SCREEN '0100'.
      ENDIF.
*&-- End OF Change --------
    WHEN  'CHAN'                  .
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action     = 'Change'     .
      prev_okcode  = ok_code      .

    WHEN   'DISP'       .
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action = 'Display'        .
      prev_okcode = ok_code       .
    WHEN  'DELE'.
      CLEAR zmm_emdhdr-docno .                              "15.03.04
      g_action     = 'Delete'.
      prev_okcode  =  ok_code .
    WHEN 'REST'.
      g_action     = 'Reset'.
      prev_okcode  =  ok_code .
      CLEAR zmm_emdhdr-docno.
    WHEN 'BGLC'.
      set_okcode = 'BGLC'.
      prev_okcode  = ok_code.
      IF zmm_emdhdr-docno IS INITIAL.
        LEAVE TO SCREEN '0100'.
      ENDIF.
      CLEAR zmm_emdhdr-docno.
    WHEN 'REF'.
      g_ref =  1.
      PERFORM clear_global_100.
      CALL SCREEN '0110'.
    WHEN 'AMEND'.
      prev_okcode = ok_code .
*&------> Park Document ----------------------------------------*
    WHEN 'RELS'.
      CALL TRANSACTION 'ZMMFIPARKDOC'.
*&------<-------------------------------------------------------*
    WHEN 'BGCNF'.
      CALL TRANSACTION 'ZMMBGCNF' .
    WHEN 'BGAMD'.
      CALL TRANSACTION 'ZMMBGAMD' .
    WHEN 'RFCR'.
      CALL TRANSACTION 'ZMMRFC' .
    WHEN 'HDRR'.
      CALL TRANSACTION 'ZMMHDRRFC'.
    WHEN 'DTLR'.
      CALL TRANSACTION 'ZMMDTLRFC'.
    WHEN 'DELP'.
      CALL TRANSACTION 'ZMMDELDOC'.
    WHEN 'INVK'.
      CALL TRANSACTION 'ZMMBGIV'.
    WHEN 'RCPT'.
      CALL TRANSACTION 'ZMMRCPT'.
    WHEN  'BGRET'.
      CALL TRANSACTION 'ZMMBGRET'.
    WHEN 'CRF'.
      CALL TRANSACTION 'ZMMCRF'.
    WHEN 'BGREQ'.
      CALL TRANSACTION 'ZMMBGREQ'.
  ENDCASE.
  IF prev_okcode = 'DISP' OR
     prev_okcode = 'CHAN' OR
     prev_okcode = 'DELE' OR
     prev_okcode = 'REST' OR
     prev_okcode = 'BGLC' OR
     prev_okcode = 'AMEND'.
    IF NOT zmm_emdhdr-docno IS INITIAL.
      g_idocno = zmm_emdhdr-docno .
*---------------------------------------------------------------*
*SRM Changes 1.11.04.
* Check Document Before any Actions; If document doesn't contain
* any line item. then call screen 160 .
      CLEAR l_srm_tfs .
      PERFORM get_document_cat USING zmm_emdhdr-docno CHANGING l_srm_tfs.
      IF  l_srm_tfs = 'X'.
        IF   prev_okcode = 'CHAN' OR
             prev_okcode = 'DELE' OR
             prev_okcode = 'REST'.
          PERFORM set_lock        .
        ENDIF.
        CALL SCREEN '0160'.
      ENDIF.
*-----End of Changes -------------------------------------------*

* Get Header/Item Data
      IF prev_okcode NE 'BGLC'.
        IF   l_srm_tfs NE 'X'.
          PERFORM get_data.
        ENDIF.
      ENDIF.
*---------------------------------------------------------------*
      CLEAR g_okhdr .
**&--> Refresh Table Control Data
      IF prev_okcode = 'AMEND'.
        REFRESH CONTROL 'TC_145' FROM SCREEN '0145'.
      ELSEIF prev_okcode NE 'BGLC'.
        REFRESH CONTROL 'TC_105' FROM SCREEN '0105'.
      ELSEIF prev_okcode = 'BGLC' AND zmm_emdhdr-docno IS INITIAL.
        REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
      ENDIF.
**&--<
      IF prev_okcode = 'BGLC'.
        IF NOT zmm_emdhdr-docno IS INITIAL.
          PERFORM set_lock    .
        ENDIF.
        PERFORM get_bglc_data.
        REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
        CALL SCREEN '0135'.
      ELSEIF prev_okcode NE 'AMEND'.
*&-----> SET    Lock  -------------------------------------------*
        IF prev_okcode = 'CHAN' OR
           prev_okcode = 'DELE' OR
           prev_okcode = 'REST'.
          PERFORM set_lock        .
        ENDIF.
*&----------------------------------------------------------------*
* SRM Changes.
* Check whether i/p doc is SRM or R3. If R3 then call screen 0105.
* Otherwise call screen 155.
        CLEAR g_ttype .
        PERFORM get_trasn_type .
        IF g_ttype = 'R3'  .
          CALL SCREEN '0105'.
        ELSEIF g_ttype = 'SRM'.
          CALL SCREEN '0155'.
        ENDIF.
*&----------------------------------------------------------------*
      ENDIF.
      IF prev_okcode = 'AMEND'.
        PERFORM set_lock    .
        PERFORM get_data.
        PERFORM get_vendorno_tenderno.
        CALL SCREEN '0145'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0105  INPUT
*&---------------------------------------------------------------------*
*       Exit command BACK,EXIT,CANCEL for screen 105
*----------------------------------------------------------------------*
MODULE   exit_command_0105 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code  .
    WHEN  'BACK' OR 'EXIT' OR 'CANCEL'.
*&--> If no Value Entered at Header Level Then Leave Screen to 100
      IF g_okhdr = 'X'.
        PERFORM clear_screen_0105.
        LEAVE TO SCREEN '0100'.
      ENDIF.
*&--<
      IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN' OR
         prev_okcode = 'ECREA'.                             "+002
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM release_lock.
          PERFORM clear_screen_0105.
          LEAVE TO SCREEN '0100'.
        ENDIF.
      ENDIF.
      IF prev_okcode = 'DISP' OR prev_okcode = 'DELE'
           OR prev_okcode = 'REST'.
        PERFORM release_lock.
        PERFORM clear_screen_0105.
        LEAVE TO SCREEN '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       User Commands for the screen 105
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  IF zmm_emdhdr-trans = 'SDT'.
    g_rfqpo      = 'PO No.'.
  ELSE.
    g_rfqpo      = 'RFQ No'.
  ENDIF.
  ok_code = sy-ucomm .
  CASE ok_code .
    WHEN 'SAVE'.
      IF g_error = 1.
*&----> Check Instrument no Before SAVE.
        PERFORM check_instno .
*&----<
        IF prev_okcode = 'CREA'.                            "+002
          PERFORM check_key.
        ENDIF.
*&--> Get Document no .
        IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'.
          PERFORM get_docno   .
        ENDIF.
*&--<
*&--> Popup message when Save Changes "Change Mode"
        IF prev_okcode = 'CHAN' AND g_error = 0 .
          PERFORM save_change_popup USING text-006.
        ENDIF.
*&--<
*&--> Popup message when Save Changes "Change Mode"
        IF ( prev_okcode = 'CREA' OR prev_okcode = 'ECREA' )
             AND g_error = 0 .
          PERFORM save_change_popup USING text-050.
        ENDIF.
*&-----<
        IF g_sc_ans = '1' AND
          ( prev_okcode = 'CREA' OR
            prev_okcode = 'ECREA' OR
            prev_okcode = 'CHAN' ).
          IF g_error = 0.
            PERFORM insert_itemdtl               .
            IF prev_okcode = 'CHAN' AND NOT  ist_del_emddtl IS INITIAL.
              PERFORM del_line_item ON COMMIT.
              IF sy-subrc = 0.
                COMMIT WORK.
              ENDIF.
            ENDIF.
            PERFORM save_data ON COMMIT .
**** start of change on 30/1/2004 for saving change documents
**** CDPOS & CDHDR.
            IF zmm_emdhdr-place <> wa_emdhdr-place .
              PERFORM save_chg_docu ON COMMIT .
            ENDIF .
**** end of change on 30/1/2004
            IF g_save_h = 0 AND g_save_i = 0.
              COMMIT WORK.
              IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'. "+002
                PERFORM clear_screen_0105 .
                CLEAR g_ans .
                MESSAGE s410(zmm) WITH g_docno .
                CLEAR g_docno .                             "+004
*---- set parameter for TFS/EMD/SD Document   ----------------------*
*                set parameter id 'ZMMTESDOC' field g_docno.
*-------------------------------------------------------------------*
              ELSEIF prev_okcode = 'CHAN'    .
                PERFORM clear_screen_0105 .
                MESSAGE i412(zmm).
                CLEAR g_sc_ans .
              ENDIF.
              PERFORM clear_screen_0105 .
              LEAVE TO SCREEN '0100'.
            ELSE.
              PERFORM clear_screen_0105 .
              ROLLBACK WORK.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'COPY'.
      PERFORM copy_line    .
    WHEN 'PASTE'.
      PERFORM paste_line   .
    WHEN 'INS'.
      PERFORM insert_record.
    WHEN 'DEL'.
      PERFORM delete_record.
    WHEN 'DELT'.
      PERFORM check_header_docu.
      PERFORM popup_for_delete.
      IF g_dansw = 'J'.
        PERFORM mark_for_delete.
      ENDIF.
    WHEN 'RESET'.
      PERFORM popup_for_reset .
      IF g_ransw = 'J'.
        PERFORM reset_docu.
      ENDIF.
    WHEN 'DOCU' .
      PERFORM change_docu .
    WHEN 'IDTL'.
      PERFORM get_item_details.
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
     WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*+004
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0100  INPUT
*&---------------------------------------------------------------------*
*       Exit command BACK,EXIT,CANCEL FOR SCREEN 100
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
*    when 'BACK' or 'EXIT'  or 'CANCEL' .
    WHEN 'EXIT'  OR 'CANCEL' .
      PERFORM release_lock.
      LEAVE PROGRAM.
    WHEN 'BACK'.
* Begin of addition by Saravanan M on 10/06/2009 - RD1K964254
      LEAVE PROGRAM.
*      clear zmm_emdhdr-docno.
*      loop at screen.
*        if screen-group1    = '001'.
*          screen-invisible = '1'  .
*          screen-active    = '0'    .
*          screen-input     = '0'.
*          modify screen.
*        endif.
*      endloop.*
* End of addition by Saravanan M on 10/06/2009 - RD1K964254
  ENDCASE.
ENDMODULE.                 " exit_command_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc105  INPUT
*&---------------------------------------------------------------------*
*      ModifyInternal table Data from Table Control                    *
*----------------------------------------------------------------------*
MODULE modify_tc105 INPUT.
* Begin of <RD1K963111>
  IF prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'TFS'.
    wa_tc105-rscode = '100'.
  ELSEIF prev_okcode = 'ECREA' AND zmm_emdhdr-trans = 'EMD'.
    wa_tc105-rscode = '200'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'EMD'.
    wa_tc105-rscode = '200'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'TFS'.
    wa_tc105-rscode = '100'.
  ELSEIF prev_okcode = 'CREA' AND zmm_emdhdr-trans = 'SDT'.
    wa_tc105-rscode = '340'.
  ENDIF.
* End of <RD1K963111>
  MOVE-CORRESPONDING wa_tc105 TO wa_emddtl.
  MODIFY ist_emddtl FROM wa_emddtl INDEX tc_105-current_line.
ENDMODULE.                 " modify_tc105  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_instrument  INPUT
*&---------------------------------------------------------------------*
*       Check Instrurment Type,No,Date
*----------------------------------------------------------------------*
MODULE check_instrument INPUT.
  CHECK NOT g_tfxm = 'X'.
  DATA: l_vdate LIKE sy-datum.
  CLEAR l_vdate .
*----- insterted on 24.02.2004 -------------------------*
  IF sy-dynnr = '0105'.                                     "+002
    IF g_okhdr = 'X'.
      REFRESH CONTROL 'TC_105' FROM SCREEN '0105' .
    ENDIF.
  ELSEIF sy-dynnr = '0155'.
    IF g_okhdr = 'X'.
      REFRESH CONTROL 'TC_105' FROM SCREEN '0155' .
    ENDIF.
  ENDIF.
*-------------------------------------------------------*
  IF prev_okcode = 'CREA' OR prev_okcode = 'ECREA'
     OR prev_okcode = 'CHAN'.
    IF g_okhdr NE 'X'.
      IF wa_tc105-inst_type IS INITIAL.
        MESSAGE e404(zmm).
      ELSE.
        PERFORM check_inst_type USING wa_tc105-inst_type .
*&--->  Check Instrument
        IF zmm_emdhdr-trans = 'EMD'.
          IF wa_tc105-inst_type = 'BG'.
            wa_tc105-rscode = '200'.
          ENDIF.
        ENDIF.
      ENDIF.
      IF wa_tc105-instno IS INITIAL.
        MESSAGE e405(zmm).
      ELSEIF prev_okcode = 'CREA' .
        PERFORM check_valid_instno USING zmm_emdhdr-ebeln wa_tc105-instno.
      ELSEIF prev_okcode = 'CHAN'.
        PERFORM check_valid_instno_chng USING zmm_emdhdr-ebeln
        wa_tc105-instno.
      ENDIF.
      IF  wa_tc105-instdt IS INITIAL .
        MESSAGE e406(zmm).
      ELSE.
        IF NOT ( wa_tc105-inst_type = 'IP' ) .
          IF  wa_tc105-inst_vdt IS INITIAL.
*-- If Validity Date is initial Add 180 days to Inst.date
            l_vdate =  wa_tc105-instdt + 180 .
            MOVE l_vdate TO wa_tc105-inst_vdt .
          ELSE.
            IF wa_tc105-instdt NE l_vdate .
*-- If Validty date is entered by user then take input value as Vall.*
*date
            ELSE.
              l_vdate =  wa_tc105-instdt + 180 .
              MOVE l_vdate TO wa_tc105-inst_vdt .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*----WHEN create/change  mode check validity date.
* Begin of <RD1K973923> on 201010
*      if not (  wa_tc105-inst_type = 'IV' ) .
      IF NOT (  wa_tc105-inst_type = 'IV' OR wa_tc105-inst_type = 'OP' ) .
* End of <RD1K973923>
        IF wa_tc105-inst_vdt <= sy-datum.
* Begin of <RD1K963111
          MESSAGE e866(zmm_emd).
* End of <RD1K963111
        ENDIF.
*----- end of check V.date-----------------------
*      IF wa_tc105-inst_type NE 'IP'.
        IF wa_tc105-inst_vdt IS INITIAL .
          MESSAGE e407(zmm).
        ENDIF.
        IF  wa_tc105-instdt > sy-datum .
          MESSAGE e469(zmm).
        ENDIF.
        IF wa_tc105-inst_vdt <  wa_tc105-instdt .
          MESSAGE e408(zmm).
        ENDIF.
      ENDIF.
      IF wa_tc105-amount IS INITIAL..
        MESSAGE e409(zmm).
      ENDIF.
*--------------------------------------------------------------------*
*     Check Reason code
*--------------------------------------------------------------------*
      IF wa_tc105-rscode IS INITIAL.
        MESSAGE e463(zmm).
      ELSE.
        PERFORM check_reason_code USING wa_tc105-rscode.
      ENDIF.
*--------------------------------------------------------------------*
*     End of Check Reason code
*--------------------------------------------------------------------*
      IF NOT ( wa_tc105-inst_type = 'IP' OR
               wa_tc105-inst_type = 'IV' ).
        IF wa_tc105-bank IS INITIAL  .
          MESSAGE e417(zmm).
        ENDIF.
        IF wa_tc105-branch  IS INITIAL AND ( wa_tc105-inst_type NE 'IP' OR
                                             wa_tc105-inst_type NE 'IV' ) .
          MESSAGE e418(zmm).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_instrument  INPUT
*&---------------------------------------------------------------------*
*&      Module  EMDHDR_AMOUNT  INPUT
*&---------------------------------------------------------------------*
*       Calculte Total Amount in EMD Header
*----------------------------------------------------------------------*
MODULE emdhdr_amount_instno INPUT.
  PERFORM check_instno .
  PERFORM calc_total_amount .
ENDMODULE.                 " EMDHDR_AMOUNT  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0110  INPUT
*&---------------------------------------------------------------------*
*       EXIT COMMANDS
*----------------------------------------------------------------------*
MODULE exit_command_0110 INPUT.
  CLEAR g_ans.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL'.
      IF zmm_emdhdr-docno IS INITIAL AND g_doccat IS INITIAL.
        LEAVE TO SCREEN '0100'.
      ENDIF.
      IF g_ref = 0.
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0110'.
        ENDIF.
      ELSE.
        PERFORM clear_global_110.
        LEAVE TO SCREEN '0110'.
      ENDIF.
    WHEN  'EXIT' .
      IF g_ref = 0.
        PERFORM popup_confirm USING text-005 text-004 .
        IF g_ans = 'J'.
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0100'.
        ENDIF.
      ELSE.
        PERFORM clear_global_110.
        LEAVE TO SCREEN '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0110  INPUT
*&---------------------------------------------------------------------*
*       User Commands in Screen - 0110
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.
  DATA: l_nr LIKE inri-nrrangenr.
  CLEAR wa_emdhdr_t02 .
  DATA: lv_code LIKE sy-ucomm.
  ok_code = sy-ucomm.
* Begin of <RD1K963111>
  IF NOT sy-ucomm IS INITIAL.
    lv_code = sy-ucomm.
  ENDIF.

  IF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'TFS'.
    zmm_emdref-rscode = '120'.
  ELSEIF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '220'.
  ELSEIF g_doccat = 'REFUND' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'SDT'.
    zmm_emdref-rscode = '350'.
  ELSEIF g_doccat = 'FORFEIT' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '230'.
  ELSEIF g_doccat = 'FORFEIT' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'SDT'.
    zmm_emdref-rscode = '360'.
  ELSEIF g_doccat = 'EMD-SD CNV' AND ( lv_code = 'CRET' OR lv_code = 'CHNG' ) AND g_balamt IS NOT INITIAL AND wa_emdhdr-trans = 'EMD'.
    zmm_emdref-rscode = '210'.
  ENDIF.

  IF zmm_emdhdr-trans = 'TFS' AND zmm_emdref-rscode = '120' AND sy-dynnr = '0110'.
    g_balamt = '0.00'.
  ENDIF.

* End of <RD1K963111>
  IF NOT zmm_emdhdr-docno IS INITIAL AND g_ref = 1.         "07.02.04
    PERFORM check_docno.
    PERFORM get_vendor_name.
  ENDIF.
  IF g_ref = 0.
  ENDIF.
  CASE ok_code.
    WHEN 'SAVE'.
      CLEAR l_nr.
      IF g_doccat   = text-015.   "Refund
        l_nr = '02'.
        MOVE:  'R' TO g_docstat  ,
               'R' TO zmm_emdref-rfcstat.

        g_titel     = text-015 .
        g_text      = text-012 .
      ELSEIF g_doccat = text-016. "Forfeit
        l_nr = '03'.
        MOVE: 'F'  TO  g_docstat  ,
              'F'  TO zmm_emdref-rfcstat.

        g_titel     = text-016.
        g_text      = text-013 .
      ELSEIF g_doccat  = text-018. "EMD-SD Conversion
        l_nr = '04'.
        MOVE : 'C' TO  g_docstat  ,
               'C' TO  zmm_emdref-rfcstat.

        zmm_emdref-trans = 'SDT'.
        g_titel     = text-017.
        g_text      = text-014 .
      ENDIF.
      PERFORM popup_conf_110 USING g_titel g_text.
      IF g_rfc = 'J'.
        CLEAR g_okhdr .
        PERFORM get_rfc_docno USING l_nr.
        PERFORM save_data_110 ON COMMIT.
        IF g_save_h = 0 AND g_save_i = 0.
          COMMIT WORK.
          MESSAGE s428(zmm) WITH g_titel g_docno  .
          PERFORM clear_global_110.
          CLEAR g_docno.
        ENDIF.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'CHNG' OR 'DISP' OR 'DELE' OR 'UNDEL'.
      PERFORM clear_global_110.
      prev_okcode = ok_code .
      g_rfc_chk = 1.
      CALL SCREEN '0150'.
    WHEN 'HEAD' .
      MOVE  wa_emdhdr_t02-docno  TO  wa_emdhdr-docno.
      MOVE  wa_emdhdr_t02-cron   TO  wa_emdhdr-cron .
      MOVE  wa_emdhdr_t02-trans  TO  wa_emdhdr-trans .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN 'SUBFI'.
      CALL TRANSACTION 'ZMMRFCSUB'.
    WHEN 'RFCR'.
      CALL TRANSACTION 'ZMMRFC' .
  ENDCASE.
ENDMODULE.                 " user_command_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0115  INPUT
*&---------------------------------------------------------------------*
*     Exit Command - screen 115
*----------------------------------------------------------------------*
MODULE exit_command_0115 INPUT.
  CLEAR g_ans.
  ok_code = sy-ucomm.
  REFRESH ist_emdref_01.
  REFRESH CONTROL 'TC_120' FROM SCREEN '0120'.
  ts_115-activetab = 'RFCHD' .
  g_dynnr = '0130'.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      IF prev_okcode = 'CRET' OR prev_okcode = 'CHNG' OR
        prev_okcode  = 'UNDEL'.
        IF g_rfc_chk = 0.
          PERFORM popup_confirm USING text-005 text-004 .
          IF g_ans = 'J'.
            PERFORM release_lock_rfc USING zmm_emdref-docno .
            PERFORM clear_global_110.
            LEAVE TO SCREEN '0110'.
          ENDIF.
        ELSE.
          PERFORM release_lock_rfc USING zmm_emdref-docno .
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0110'.
        ENDIF.
      ELSE.
        PERFORM release_lock_ref .
        PERFORM clear_global_110.
        LEAVE TO  SCREEN '0110'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0115  INPUT
*&---------------------------------------------------------------------*
*       User Commands Screen - 0115
*----------------------------------------------------------------------*
MODULE user_command_0115 INPUT.
  IF  zmm_emdref-docno IS INITIAL.
    REFRESH CONTROL 'TC_120' FROM SCREEN '0120'.
  ENDIF.
  ok_code = sy-ucomm .
  CASE ok_code .
    WHEN 'SAVE'.
      PERFORM save_change_popup USING text-006.
      IF g_sc_ans = '1'.
        PERFORM save_data_115 ON COMMIT.
        IF  g_save_i = 0.
          COMMIT WORK.
          MESSAGE i412(zmm).
          PERFORM clear_global_115.
          LEAVE TO SCREEN '0110'.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    WHEN 'DELE'.
      PERFORM popup_confirm USING text-022 text-023 .
      IF g_ans = 'J'.
        PERFORM delete_rfc_doc.
        PERFORM clear_global_115.
        LEAVE TO SCREEN '0110'.
      ENDIF.
*----------- Reset RFC Document
    WHEN 'RESET'.
      PERFORM popup_confirm USING text-051 text-053 .
      IF g_ans = 'J'.
        PERFORM rest_rfc_doc USING zmm_emdref-docno.
        PERFORM clear_global_115.
        LEAVE TO SCREEN '0110'.
      ENDIF.
    WHEN 'HEAD' .
      PERFORM get_header.
    WHEN  'RFCHD'.
      ts_115-activetab = ok_code .
      g_dynnr = '0130'.
    WHEN  'RFC'.
      ts_115-activetab = ok_code .
      g_dynnr = '0120'.
*&---> Get Refund/Forfeit/EMD-SD Converted Data
      PERFORM get_rfc_data.
*&---<
    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
     WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*+004
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
    WHEN  'ENMT' .
      IF zmm_emdhdr-trans = 'TFS' OR
         zmm_emdhdr-trans = 'EMD'.
        SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
        CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
        CLEAR ok_code .
      ELSE.
        CLEAR g_bstyp .
        PERFORM get_bstyp.
        IF g_bstyp = 'F'.
          SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ELSEIF g_bstyp = 'K'.
          SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
        ENDIF.
        CLEAR ok_code .
      ENDIF.
  ENDCASE.
ENDMODULE.                 " user_command_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0125  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0125 INPUT.
  CASE sy-ucomm  .
    WHEN 'BACK' OR '%EX' OR 'RW' .
      LEAVE  SCREEN  .
  ENDCASE .
ENDMODULE.                 " USER_COMMAND_0125  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tc120 INPUT.
  CLEAR g_lines.
  MOVE-CORRESPONDING wa_emdref_01 TO wa_emdref_02  .
  MODIFY ist_emdref_01 FROM wa_emdref_02   INDEX tc_120-current_line.
ENDMODULE.                 " modify_tc120  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_120  INPUT
*&---------------------------------------------------------------------*
*      Exit Command for Screen 120.
*----------------------------------------------------------------------*
MODULE exit_command_120 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM clear_global_110.
      LEAVE TO SCREEN '0100'.
  ENDCASE.
ENDMODULE.                 " EXIT_COMMAND_120  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PONO  INPUT
*&---------------------------------------------------------------------*
*      Check PO no
*----------------------------------------------------------------------*
MODULE check_docno_pono INPUT.
*&----> Check PO no
*&---> EMD-SD CNV text-018
  IF g_doccat  = 'EMD-SD CNV' AND NOT zmm_emdref-ebeln IS INITIAL.
    PERFORM check_pono.
    PERFORM check_vendor_po USING  zmm_emdhdr-docno.
  ENDIF.
*&-----<
  IF NOT zmm_emdhdr-docno IS INITIAL.
    PERFORM check_valid_docno.
  ENDIF.
  PERFORM get_total_ref  .
*---------------------------------------------------------------*
*Check whether RFC AMOUNT is equal to Receipt Amount.
* If then raise error message.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    IF g_tot_ref = zmm_emdhdr-amount.
      MESSAGE e474(zmm).
    ENDIF.
  ENDIF.
*----------------------------------------------*
ENDMODULE.                 " CHECK_PONO  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_header  INPUT
*&---------------------------------------------------------------------*
*       Check Header Data  of screen 105
*----------------------------------------------------------------------*
MODULE check_header INPUT.

  IF   zmm_emdhdr-trans    IS INITIAL    OR
       zmm_emdhdr-ebeln    IS INITIAL    OR
       zmm_emdhdr-currency IS INITIAL    OR
       zmm_emdhdr-co_code  IS INITIAL .
    g_okhdr = 'X'.
  ELSE.
    CLEAR g_okhdr .
  ENDIF.

*---------------------------------------------------------------------*
* SRM Changes +002  29.09.2004
  IF prev_okcode = 'ECREA' OR g_ttype = 'SRM'.
    IF   zmm_emdhdr-trans    IS INITIAL    OR
         zmm_emdhdr-currency IS INITIAL    OR
         zmm_emdhdr-co_code  IS INITIAL    OR
         zmm_emdhdr-vendorno IS INITIAL    OR
         zmm_emdhdr-ebidno   IS INITIAL.
      g_okhdr = 'X'.
    ELSE.
      CLEAR g_okhdr .
    ENDIF.
** For SRM Bid Only Trasaction type TFS and EMD is Allowed.
** Otherwise raise error message
    IF NOT ( zmm_emdhdr-trans = 'TFS' OR
             zmm_emdhdr-trans =  'EMD' ).
      MESSAGE e507(zmm).
    ENDIF.
  ENDIF.
*&--->
  IF prev_okcode = 'ECREA' OR prev_okcode = 'CHAN'.
    IF NOT zmm_emdhdr-vendorno IS INITIAL.
      PERFORM check_vendor USING zmm_emdhdr-vendorno .
    ENDIF.
    IF NOT zmm_emdhdr-ebidno IS INITIAL.
      PERFORM check_ebidno .
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------*

*&------> Check INR incase of intrument 'IP'.
  IF wa_tc105-inst_type = 'IP' AND
    zmm_emdhdr-currency NE 'INR'.
    MESSAGE e554(zmm).
  ENDIF.
* Begin of <RD1K963111>
* To validate the Vendor & E-Bid No passing to SRM system
  IF zmm_emdhdr-trans = 'TFS' AND ( prev_okcode = 'ECREA' OR prev_okcode = 'CHAN' ).
    IF NOT zmm_emdhdr-vendorno IS INITIAL AND NOT zmm_emdhdr-ebidno IS INITIAL.
      PERFORM check_ebid_vednor.
    ENDIF.
  ENDIF.
* Begin of <RD1K963111>
*&------<
*&--> Check Document no When Create Mode
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'.
    PERFORM check_ebeln.
  ENDIF.
*&--<
*&--> Get Vendor code and Tender no
  PERFORM get_vendorno_tenderno.
*&--<
*&--> Check Location
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'
     OR prev_okcode = 'ECREA'.
    IF zmm_emdhdr-trans = 'TFS'.
      IF NOT zmm_emdhdr-place IS INITIAL.
        PERFORM check_loc.
      ENDIF.
    ENDIF.
  ENDIF.
*&--<
*&--> Check  TFS doc. same RFQ and Currency Exist or not.
  IF prev_okcode = 'CREA' AND wa_tc105-inst_type IS INITIAL.
    IF zmm_emdhdr-trans = 'TFS' OR zmm_emdhdr-trans = 'EMD'
       OR  zmm_emdhdr-trans = 'SDT'.
      PERFORM check_rfq .
    ENDIF.
  ENDIF.
*&--<
*&----->  Check Company code.
  IF NOT zmm_emdhdr-co_code IS INITIAL.
    PERFORM check_company_code .
  ENDIF.
*------<
*&---> Check whether Vendor code exist in Entered Company code or not
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHAN'.
    IF NOT g_vcode IS INITIAL AND NOT zmm_emdhdr-co_code IS INITIAL.
      PERFORM check_comp_code USING g_vcode zmm_emdhdr-co_code .
    ENDIF.
  ENDIF.
*&-----<
ENDMODULE.                 " check_header  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_docno  INPUT
*&---------------------------------------------------------------------*
*       Check Docuement no
*----------------------------------------------------------------------*
MODULE check_docno INPUT.

*-----------------------------------------------------------------*
** Check Document *---* If Document is Converted from EMD TO SD
*  Don't allow to  Edit.
*-----------------------------------------------------------------*
*&--> Get Header Data
  IF NOT zmm_emdref-docno IS INITIAL AND g_rfc_chk = 1.
    PERFORM check_docno_rfc.
    PERFORM get_vendor_name.
  ENDIF.
*&--<
*----------------------------------------------------------------*
*  Check whether any document exist in system                    *
*  corresponding to  EMD-SD Converted document  . If then
*  Don't allow for Delete                                       *
*----------------------------------------------------------------*
  IF prev_okcode NE 'DISP'.
    PERFORM  check_emdconv_doc USING zmm_emdref-docno.
  ENDIF.
*----------------------------------------------------------------*
*------- Check Document Status *---------------------------------*
  PERFORM check_rfc_docu_status.
*-----------------------------------------------------------------*
*------   Check Balace amount when 'RESET'    --------------------*
  IF prev_okcode = 'UNDEL'.
    PERFORM check_amount_bf_reset.
  ENDIF.
*-----------------------------------------------------------------*
  PERFORM check_rfc_amount  .
*&-->  Check Amount
  IF prev_okcode = 'CREA' OR prev_okcode = 'CHNG' OR
     prev_okcode = 'DISP' OR prev_okcode = 'UNDEL' .
  ENDIF.
*&--<
ENDMODULE.                 " check_docno  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_135  INPUT
*&---------------------------------------------------------------------*
*      Exit command of screen 135
*----------------------------------------------------------------------*
MODULE exit_command_135 INPUT.
  ok_code =  sy-ucomm.
  CASE ok_code .
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' .
      REFRESH CONTROL 'TC_135' FROM SCREEN '0135'.
      PERFORM release_lock.
      PERFORM clear_screen_0105.
      CLEAR ok_code .
      CLEAR prev_okcode .
      LEAVE TO SCREEN '0100'.
  ENDCASE.
ENDMODULE.                 " exit_command_135  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_135  INPUT
*&---------------------------------------------------------------------*
*      User command of screen - 135
*----------------------------------------------------------------------*
MODULE user_command_135 INPUT.
  DATA: l_no(2).

  CLEAR: g_firet, g_mmret.

  PERFORM modify_table_emddtl .
  CLEAR g_status.
  CASE ok_code.
*&-----> Header Detail
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
      prev_okcode = ok_code .
      CLEAR ok_code.
*&-----> Send to Bank for Confirmation
    WHEN 'BCONF'.
      PERFORM check_item_select  .
      IF g_ans = '0'.
        PERFORM popup_confirm USING    text-024 text-025.
      ENDIF.
      IF g_ans = 'J'.
        PERFORM update_for_bankconf .
        PERFORM update_header_status_bglc_main.
        MESSAGE s435(zmm).
        PERFORM clear_global_135.                           "-004
        LEAVE TO SCREEN '0100'.                             "-004
      ENDIF.
      prev_okcode = ok_code .
      CLEAR ok_code.
*&-----> Reset Document
    WHEN 'RESET'.
      prev_okcode = ok_code .
      CLEAR ok_code.
      PERFORM check_sel_reset_item .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-026 text-027.
        IF g_ans = 'J'.
          PERFORM reset_bank_conf_doc USING g_idocno g_itemno
          g_reset_status  .
          PERFORM update_header_status_bglc_main.
          PERFORM status_message USING g_reset_status.
*          perform release_lock.  -004
*          perform clear_global_135. -004
*          leave to screen '0100'.  -004
        ENDIF.
      ENDIF.
*&------> Post Confirmation
    WHEN 'PCONF'.
      PERFORM check_sel_item .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-028 text-029.
        IF g_ans = 'J'.
*-----------------------------------------------------------*
* Popup for Bank Deny/Confirm                               *
          PERFORM popup_deny_accept.
          IF g_ans_ad = '1' OR g_ans_ad = '2'.
            PERFORM update_post_conf USING g_ans_ad.
            PERFORM update_header_status_bglc_main.
            MESSAGE s439(zmm).
*           perform release_lock.      -004
*            perform clear_global_135. -004
*            leave to screen '0100'.   -004
          ENDIF.
        ENDIF.
      ENDIF.
*&-------> Send Document to FI
    WHEN 'SNDFI'.
      PERFORM check_sel_item_sndfi .
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-041 text-042.
        IF g_ans = 'J'.
          PERFORM update_status_subfi.
          PERFORM update_header_status_bglc_main.
          MESSAGE s449(zmm).
*          perform release_lock.
*          perform clear_global_135. -004
*          leave to screen '0100'.   -004
        ENDIF.
      ENDIF.
*&-----> Document Amend
    WHEN 'AMEND'.
      IF NOT zmm_emdhdr-docno IS INITIAL.
        CALL SCREEN '0145'.
      ENDIF.
*&-------> Item Details
    WHEN 'IDTL'.
      PERFORM get_item_details.
*&------->  Invoke
    WHEN 'INVOK'.
* Authorization Check  for INVOKING BG/ LC
      PERFORM  check_auth .
      PERFORM check_sel_item_invoke.
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-030 text-031.
        IF g_ans = 'J'.
          PERFORM invoke_docu.
          MESSAGE s454(zmm).
*          perform release_lock.     -004
*          perform clear_global_135. -004
*          leave to screen '0100'.   -004
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009

*&------>  Return BG/LC Document
    WHEN 'RETN'.

* Authorization Check for RETURN of BG/ LC
      IF zmm_emdhdr-trans = 'SDT' OR zmm_emdhdr-trans = 'EMD'.
        PERFORM  check_auth_return USING zmm_emdhdr-trans   .
      ENDIF.
*      PERFORM modify_table_emddtl .
      PERFORM check_sel_item_retn .

      IF zmm_emdhdr-trans = 'EMD'.
        IF g_ans = '0' AND g_error = 0 AND
        ( g_mmret = 'X' OR g_firet = 'X' ).
          PERFORM popup_confirm USING    text-044 text-045.
        ENDIF.
      ELSEIF zmm_emdhdr-trans = 'SDT'.
        IF g_ans = '0' AND g_error = 0 .
          PERFORM popup_confirm USING    text-044 text-045.
        ENDIF.
      ENDIF.
      IF g_ans = 'J'.
        PERFORM retrun_docu.
        MESSAGE s453(zmm).
*        perform release_lock.     -004
*        perform clear_global_135. -004
*        leave to screen '0100'.   -004
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
*&-------<
*------------------------------------------------------------*
*  Document Accept by FI
* Before document accept in FI the status of the document must be
* 'S'- ie Submitted to FI.
    WHEN 'ACCFI'.
* Authorization Check  for ACCEPTED BY FI
      PERFORM  check_auth .
      PERFORM cehck_sel_item_accept.
      IF g_ans = '0' AND g_error = 0.
        PERFORM popup_confirm USING    text-059 text-060.
        IF g_ans = 'J'.
          PERFORM accept_docu.
          PERFORM update_header_status_bglc_main.
*          perform release_lock.      -004
*          perform clear_global_135.  -004
*          leave to screen '0100'.    -004
        ENDIF.
      ENDIF.
*------------------------------------------------------------*
*-----start of addition 02.02.05   +003 --------------------*
    WHEN 'RQIR'.
*      PERFORM modify_table_emddtl .
      PERFORM check_sel_item_rqri.
      IF g_ans = '0' AND g_error = '0'.
        PERFORM popup_req_ret_invk.
        IF g_ans_ad = '1' OR g_ans_ad = '2'.
*          perform get_reqslno changing l_no .
          PERFORM get_reqno_save  USING g_ans_ad.
          PERFORM check_status_before_update USING g_ans_ad.
          IF g_error = '0' AND g_ans = '0'.
            PERFORM change_doc_reqno .
          ENDIF.
          PERFORM update_req_ret_inv USING g_ans_ad .
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
    WHEN 'RSTIR'.
      PERFORM check_req_status.
      IF g_ans = '0' AND g_error = '0'.
        PERFORM popup_confirm USING    text-044 text-079.
        IF g_ans = 'J'.
* Change Document for Reqno starts here
          PERFORM get_reqno .
          PERFORM change_doc_reqno .
          PERFORM update_req_status.
        ENDIF.
      ENDIF.
* Start of addition by SAB_SARVANAN on 12/06/2009
      PERFORM  update_header_status_bglc_main.
* End of addition by SAB_SARVANAN on 12/06/2009
    WHEN 'CGHIS'.
      LEAVE TO LIST-PROCESSING  AND RETURN TO SCREEN 0135 .
      PERFORM display_chng_ri_history.
    WHEN 'BGREQ'.
      CALL TRANSACTION 'ZMMBGREQ'.
*------------------------------------------------------------*

    WHEN 'ME43'.
      SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
      CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
      CLEAR ok_code .
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*    WHEN 'ME23'.
      WHEN 'ME23N'.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      CLEAR g_bstyp .
      PERFORM get_bstyp.
      IF g_bstyp = 'F'.
        SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF g_bstyp = 'K'.
        SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
        CALL TRANSACTION 'ME33K'      AND SKIP FIRST SCREEN.
      ENDIF.
      CLEAR ok_code .
    WHEN 'BGCNF'.
      CALL TRANSACTION 'ZMMBGCNF' .
    WHEN 'BGAMD'.
      CALL TRANSACTION 'ZMMBGAMD' .
    WHEN 'INVK'.
      CALL TRANSACTION 'ZMMBGIV'.
    WHEN  'BGRET'.
      CALL TRANSACTION 'ZMMBGRET'.
  ENDCASE.
  prev_okcode = ok_code .
  CLEAR ok_code .
ENDMODULE.                 " user_command_135  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc135  INPUT
*&---------------------------------------------------------------------*
*       move table control data into internal table
*----------------------------------------------------------------------*
MODULE modify_tc135 INPUT.
  MOVE-CORRESPONDING wa_tc135 TO wa_emddtl  .
  MODIFY ist_emddtl FROM wa_emddtl   INDEX tc_135-current_line.
ENDMODULE.                 " modify_tc135  INPUT
*&---------------------------------------------------------------------*
*&      Module  ext_140  INPUT
*&---------------------------------------------------------------------*
*      Exit Command of Screen 140
*----------------------------------------------------------------------*
MODULE ext_140 INPUT.
  CASE sy-ucomm  .
    WHEN 'BACK' OR '%EX' OR 'RW' .
      CLEAR: g_status, g_reqtext.
      LEAVE  SCREEN  .
  ENDCASE .
ENDMODULE.                 " ext_140  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0145  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0145 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM popup_confirm USING text-005 text-004 .
      IF g_ans = 'J'.
        PERFORM release_lock.
        PERFORM clear_screen_0105.
        SET SCREEN  '0100'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " exit_command_0145  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0145  INPUT
*&---------------------------------------------------------------------*
*      User Command of screen 0145.
*----------------------------------------------------------------------*
MODULE user_command_0145 INPUT.
  CASE ok_code .
    WHEN  'SAVE'.
      PERFORM save_change_popup USING text-006.
      IF g_sc_ans = '1' .
* Select record for the given document no. from DB table
        SELECT * INTO TABLE ist_dtl FROM zmm_emddtl WHERE
                                   docno = wa_emddtl-docno  .

        PERFORM modify_data_s145  ON COMMIT  .
        IF g_save_h = 0 AND g_save_i = 0.
          COMMIT WORK.
          MESSAGE s455(zmm).
          PERFORM clear_global_110.
          LEAVE TO SCREEN '0100' .
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
*&-------> Item Details
    WHEN 'IDTL'.
      PERFORM get_item_details.
    WHEN 'HEAD' .
      PERFORM disp_head USING wa_emdhdr-docno
                              wa_emdhdr-cron
                              wa_emdhdr-trans.
    WHEN  'ENMT' .

      IF zmm_emdhdr-trans = 'TFS' OR
         zmm_emdhdr-trans = 'EMD'.
        SET PARAMETER ID 'ANF' FIELD zmm_emdhdr-ebeln.
        CALL TRANSACTION 'ME43' AND SKIP FIRST SCREEN.
        CLEAR ok_code .
      ELSE.

        CLEAR g_bstyp .
        PERFORM get_bstyp.
        IF g_bstyp = 'F'.
          SET PARAMETER ID 'BES' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ELSEIF g_bstyp = 'K'.
          SET PARAMETER ID 'CTR' FIELD zmm_emdhdr-ebeln .
          CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
        ENDIF.
        CLEAR ok_code .
      ENDIF.
    WHEN 'HSTRY' .
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0145 .
      PERFORM disp_chg_hstry .
* End of logic for changed document .
  ENDCASE.
ENDMODULE.                 " user_command_0145  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_instrument_S140  INPUT
*&---------------------------------------------------------------------*
*    Check Instrument details in screen 140
*----------------------------------------------------------------------*
MODULE check_instrument_s145 INPUT.
  IF wa_tc145-inst_vdt IS INITIAL .
    MESSAGE e407(zmm).
  ENDIF.
  IF wa_tc145-inst_vdt <  wa_tc145-instdt .
    MESSAGE e408(zmm).
  ENDIF.
  IF wa_tc145-amount IS INITIAL..
    MESSAGE e409(zmm).
  ENDIF.
  IF wa_tc145-rscode IS INITIAL.
    MESSAGE e456(zmm).
  ELSE.
    PERFORM check_reason_code_amend USING wa_tc145-rscode.
  ENDIF.
ENDMODULE.                 " check_instrument_S140  INPUT
*&---------------------------------------------------------------------*
*&      Module  emdhdr_amount_s145  INPUT
*&---------------------------------------------------------------------*
*       Check Header Amount
*----------------------------------------------------------------------*
MODULE emdhdr_amount_s145 INPUT.
  PERFORM calc_total_amount .
ENDMODULE.                 " emdhdr_amount_s145  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_docno_s100  INPUT
*&---------------------------------------------------------------------*
*      Check Document No entered in screen 100.
*----------------------------------------------------------------------*
MODULE check_docno_s100 INPUT.
  DATA l_msg_text(20).
  DATA l_inst_type LIKE zmm_emddtl-inst_type .
  CLEAR wa_emdhdr .
  IF   ok_code   = 'CHAN'.
    l_msg_text   = 'Change'.
  ELSEIF ok_code = 'DELE'.
    l_msg_text   = 'Delete'.
  ELSEIF ok_code = 'REST'.
    l_msg_text   = 'Reset'.
  ENDIF.

  IF ok_code  = 'CHAN' OR
     ok_code  = 'DELE' OR
     ok_code  = 'BGLC' OR
     ok_code  = 'AMEND' .
    PERFORM check_bglc .
    IF NOT zmm_emdhdr-docno  IS INITIAL.
      SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0.
*-----------------------------------------------------------------*
*  For BG/LC header level Doc. complete validation is not applicable.
        SELECT INST_TYPE FROM ZMM_EMDDTL INTO L_INST_TYPE UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*-----------------------------------------------------------------*
*---> Check If the Document is Parked/Deleted.
        IF wa_emdhdr-status = 'D'.
          MESSAGE e425(zmm).
        ELSEIF wa_emdhdr-status = 'U'.
          MESSAGE e470(zmm) WITH   l_msg_text .
*-- BG/LC doc. accepted by FI
        ELSEIF  wa_emdhdr-status = 'J' .
          IF ( l_inst_type = 'BG' OR  l_inst_type = 'LC' ) .
          ELSE.
            MESSAGE e499(zmm) .
          ENDIF.
*--- partially parked.
        ELSEIF   wa_emdhdr-status = 'K' .
          IF prev_okcode = 'CHAN' OR
             prev_okcode = 'BGLC'.
          ELSE.
            MESSAGE e556(zmm).
          ENDIF.
*----- BG/LC Inprocess
        ELSEIF   wa_emdhdr-status = 'Q' .
          IF  ( l_inst_type NE 'BG' OR  l_inst_type NE 'LC' ) .
          ELSE.
            MESSAGE e557(zmm).
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e411(zmm).
      ENDIF.
*------< End of check --------------------------------------*
    ENDIF.
  ENDIF.
  IF NOT zmm_emdhdr-docno  IS INITIAL AND NOT ok_code = 'BACK' .
    SELECT * FROM ZMM_EMDHDR INTO WA_EMDHDR UP TO 1 ROWS
 WHERE DOCNO = ZMM_EMDHDR-DOCNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc NE 0.                                       "+002
      MESSAGE e411(zmm).
    ENDIF.                                                  "+002
  ENDIF.
  IF ok_code = 'REST'.
    IF NOT zmm_emdhdr-docno IS INITIAL.
      IF wa_emdhdr-status = 'N'.
        l_msg_text = text-040.
        MESSAGE e472(zmm).
      ELSEIF wa_emdhdr-status NE  'D'.
        MESSAGE e561(zmm).
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    IF prev_okcode = 'AMEND'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_docno_s100  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc145  INPUT
*&---------------------------------------------------------------------*
*      Modify table control Data
*----------------------------------------------------------------------*
MODULE modify_tc145 INPUT.
  MOVE-CORRESPONDING wa_tc145 TO wa_emddtl  .
  MODIFY ist_emddtl FROM wa_emddtl      INDEX tc_145-current_line.
ENDMODULE.                 " modify_tc145  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_COMBI_INST_TYPE  INPUT
*&---------------------------------------------------------------------*
*      Check Instrument Group
*----------------------------------------------------------------------*
MODULE check_combi_inst_type INPUT.
  PERFORM check_inst_group.
ENDMODULE.                 " CHECK_COMBI_INST_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_balance_amt  INPUT
*&---------------------------------------------------------------------*
*      Check Balace amt
*----------------------------------------------------------------------*
MODULE chk_balance_amt .
  PERFORM check_rfc_amount  .
ENDMODULE.                 " chk_balance_amt  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_balance_amt_receipt  INPUT
*&---------------------------------------------------------------------*
*     Check Balace amount.
*----------------------------------------------------------------------*
MODULE chk_balance_amt_receipt INPUT.
  IF NOT zmm_emdhdr-docno IS INITIAL.
    PERFORM check_rfc_amount_receipt  .
  ENDIF.
ENDMODULE.                 " chk_balance_amt_receipt  INPUT
*&---------------------------------------------------------------------*
*&      Module  update_status  INPUT
*&---------------------------------------------------------------------*
*    Update Header Status.
*----------------------------------------------------------------------*
MODULE update_status INPUT.
*&----> If all line item are PARKED/REFUND/FORFEIT/EMD-SD CONV..
** the update header level status.
  PERFORM update_head_status_105.
ENDMODULE.                 " update_status  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       User Command of screen 150.
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.
  IF ok_code = 'CHNG'   OR
     ok_code = 'DELE'   OR
     ok_code =  'UNDEL' .
    IF NOT zmm_emdref-docno IS INITIAL.
      PERFORM set_loc_rfc USING zmm_emdref-docno.
    ENDIF.
  ENDIF.
  IF g_rfc_chk = 0.
    CALL SCREEN '115'.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_150  INPUT
*&---------------------------------------------------------------------*
*       Exit Command of screen 150.
*----------------------------------------------------------------------*
MODULE exit_150 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM release_lock_rfc USING  zmm_emdref-docno.
      PERFORM clear_global_115.
      LEAVE TO SCREEN '0110'.
  ENDCASE.
ENDMODULE.                 " exit_150  INPUT
*&---------------------------------------------------------------------*
*&       UPDATE_HEADER_STATUS_BGLC  INPUT
*&---------------------------------------------------------------------*
*     Update Header Status based on BG/LC Doc. Actions.
*   Eg. If all documents ar accepted by FI the Update Header status with
*   Complete.
*----------------------------------------------------------------------*
MODULE update_header_status_bglc INPUT.
  DATA: wa_dtl_t001 TYPE zmm_emd_status.
  DATA: l_stat,
        l_found.
  LOOP AT ist_emddtl INTO wa_dtl_t001.
    IF sy-tabix = 1.
      l_stat    =  wa_dtl_t001-status.
    ENDIF.
    IF l_stat   NE  wa_dtl_t001-status.
      l_found   =  'X'.
      EXIT.
    ELSE.
      l_found   =  '0'.
    ENDIF.
  ENDLOOP.
  IF l_found = '0' AND NOT l_stat IS INITIAL.
    IF l_stat ='N'.
      PERFORM update_header_status_bglc USING g_idocno 'N'.
    ELSEIF l_stat = 'P'.
      PERFORM update_header_status_bglc USING g_idocno 'J'.
    ENDIF.
  ELSEIF l_found = 'X'.
    PERFORM update_header_status_bglc USING g_idocno 'Q'.
  ENDIF.
ENDMODULE.                 " UPDATE_HEADER_STATUS_BGLC  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_rscode  INPUT
*&---------------------------------------------------------------------*
*    Check reason code.
*----------------------------------------------------------------------*
MODULE check_rscode INPUT.
  IF NOT zmm_emdref-rscode IS INITIAL.
    PERFORM check_reason_code_rfc USING zmm_emdref-rscode.
  ENDIF.
ENDMODULE.                 " check_rscode  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_command_0160  INPUT
*&---------------------------------------------------------------------*
*       Exit Command for Screen 160
*----------------------------------------------------------------------*
MODULE exit_command_0160 INPUT.

  IF sy-ucomm = 'BACK' OR sy-ucomm = 'EXIT' OR sy-ucomm = 'CANCEL'.
    IF prev_okcode = 'CHAN'.
      PERFORM popup_confirm USING text-005 text-004 .
      IF g_ans = 'J'.
        PERFORM release_lock .
        PERFORM clear_screen_160.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    ELSE.
      PERFORM release_lock .
      PERFORM clear_screen_160.
      LEAVE TO SCREEN '0100'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " exit_command_0160  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_0160  INPUT
*&---------------------------------------------------------------------*
*      User Command for screen 160
*----------------------------------------------------------------------*
MODULE user_command_0160 INPUT.
  CASE ok_code .
    WHEN 'SAVE'.
      IF prev_okcode = 'ECREA'.
        PERFORM save_change_popup USING zmm_emdhdr. "TEXT-050.
        IF  g_sc_ans = '1'.
          PERFORM get_docno   .
          PERFORM save_srm_header_doc .
        ENDIF.
      ELSEIF prev_okcode = 'CHAN'.
        PERFORM save_change_popup USING text-006.
        IF g_sc_ans = '1'.
          PERFORM save_changes.
        ENDIF.
      ENDIF.
    WHEN 'DELE'.
      CLEAR g_dansw .
      PERFORM popup_for_delete.
      IF g_dansw = 'J'.
        PERFORM mark_for_dele_edoc   .
      ENDIF.
    WHEN 'RESET'.
      CLEAR g_dansw .
      PERFORM popup_for_reset .
      IF g_ransw = 'J'.
        PERFORM reset_edoc  .
      ENDIF.
  ENDCASE.
ENDMODULE.                 " user_command_0160  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_combi_inst_type_etend  INPUT
*&---------------------------------------------------------------------*
*     Check Instrument Type incase of E-Tenders
*----------------------------------------------------------------------*
MODULE check_combi_inst_type_etend INPUT.
*+004
  PERFORM check_inst_group_etend.

ENDMODULE.                 " check_combi_inst_type_etend  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_EBID_VEDNOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_ebid_vednor .
  DATA: l_logsys(32).
  DATA lv_logsys TYPE string.
  DATA lv_rfcsi_export LIKE  rfcsi.

  TYPES: BEGIN OF ls_srmpay,
         mandt TYPE mandt,
         ebidno(10) TYPE c,
         vendorno(10) TYPE c,
         epgtxnid(15) TYPE c,
         paytyp,
         usr(12) TYPE c,
         amount TYPE wert8,   "ZMM_EMDDTL-AMOUNT,  28012014 BY SUDHIR SHARMA
         currency TYPE waers,
         paydate TYPE datum,
         remakrs(60) TYPE c,
         c_date(8) TYPE c,
         c_time(6),
         timestamp TYPE timestamp,
         END OF ls_srmpay.

  DATA: ist_srmpay TYPE TABLE OF ls_srmpay,
        wa_srmpay TYPE ls_srmpay.

  DATA: lv_remarks(60) TYPE c.

  IMPORT ist_srmpay FROM MEMORY ID 'TENDER_FEE'.
  CLEAR wa_srmpay.
  READ TABLE ist_srmpay INTO wa_srmpay WITH KEY ebidno = zmm_emdhdr-ebidno
                                                vendorno = zmm_emdhdr-vendorno.
  lv_remarks = 'Online payment. Transaction Successful'.
  IF wa_srmpay-epgtxnid IS INITIAL AND wa_srmpay-remakrs <> lv_remarks.
* Get Logical system name from table ZMM_LOGSYS
    SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
                  WHERE  appl = 'SRM'.
    IF NOT l_logsys IS INITIAL.
      lv_logsys =  l_logsys.
* Function module to check the RFC Connection
      CALL FUNCTION 'ZRFC_GET_SYSTEM_INFO'
        EXPORTING
          destination  = lv_logsys
        IMPORTING
          rfcsi_export = lv_rfcsi_export.

      IF lv_rfcsi_export IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = zmm_emdhdr-vendorno
          IMPORTING
            output = zmm_emdhdr-vendorno.

        CALL FUNCTION 'Z_CHECK_BIDDER_REGISTERED' DESTINATION l_logsys
          EXPORTING
            iv_bid_no    = zmm_emdhdr-ebidno                "char10
            iv_vendor_no = zmm_emdhdr-vendorno              "char10
          IMPORTING
            allow        = zallow.                          "char1

        IF zallow = 'C'.
*          if sy-uname(3) <> 'CMM'.
*         Vendor should be registered for the document before running this report
          MESSAGE e001(zmm_emd) WITH zmm_emdhdr-vendorno zmm_emdhdr-ebidno.
*          endif.
        ELSEIF zallow = 'A'.
          MESSAGE e003(zmm_emd) WITH zmm_emdhdr-ebidno.
        ELSEIF zallow = 'B'.
          IF sy-uname(3) <> 'CMM'.
            MESSAGE e004(zmm_emd) WITH zmm_emdhdr-ebidno.
          ENDIF.
        ELSEIF zallow = 'D'.
          IF sy-uname(3) <> 'CMM'.
            MESSAGE e004(zmm_emd) WITH zmm_emdhdr-ebidno.
          ENDIF.
        ENDIF.

      ELSE.
        MESSAGE e002(zmm_emd).
      ENDIF.
    ENDIF.
  ENDIF.
* Begin of <RD1K973923> on 20102010
  SELECT VENDORNO EBIDNO TRTYP TRANS FROM ZMM_EMDHDR INTO
 ( ZMM_EMDHDR-VENDORNO , ZMM_EMDHDR-EBIDNO , ZMM_EMDHDR-TRTYP , ZMM_EMDHDR-TRANS ) UP TO 1 ROWS WHERE VENDORNO = ZMM_EMDHDR-VENDORNO AND EBIDNO = ZMM_EMDHDR-EBIDNO AND TRTYP = 'SRM' AND TRANS = ZMM_EMDHDR-TRANS AND STATUS NE 'D'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
*  select single vendorno ebidno trtyp from zmm_emdhdr into
*      (zmm_emdhdr-vendorno, zmm_emdhdr-ebidno, zmm_emdhdr-trtyp) where vendorno = zmm_emdhdr-vendorno
*                                                and ebidno = zmm_emdhdr-ebidno
*                                                and trtyp = 'SRM'.
* End of <RD1K973923>
  IF sy-subrc = 0.
    MESSAGE e006(zmm_emd) WITH zmm_emdhdr-vendorno zmm_emdhdr-ebidno.
  ENDIF.

ENDFORM.                    " CHECK_EBID_VEDNOR
*&---------------------------------------------------------------------*
*&      Module  GET_LOV_APPRV_BY  INPUT
*&---------------------------------------------------------------------*
* Serach help on Approved by Competent Authority
*----------------------------------------------------------------------*
MODULE get_lov_apprv_by INPUT.
  PERFORM get_lov_approve_by.
ENDMODULE.                 " GET_LOV_APPRV_BY  INPUT
