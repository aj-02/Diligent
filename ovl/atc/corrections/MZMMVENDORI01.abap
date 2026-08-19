*----------------------------------------------------------------------*
***INCLUDE MZMMVENDORI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       PAI modules for screen 100 - initial screen
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CLEAR zmm_hvencrt.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'CREA'.
      g_trans_mode = 'N'.
      CLEAR save_ok.
      CALL SCREEN 0200.
    WHEN 'CHAN'.
      g_trans_mode = 'M'.
      CLEAR save_ok.
      CALL SCREEN 0200.
    WHEN 'DISP'.
      g_trans_mode = 'D'.
      CLEAR zmm_hvencrt.
      CALL SCREEN 0200.
    WHEN 'DELE'.
      g_trans_mode = 'X'.
      CALL SCREEN 0200.
    WHEN  'RELS'.
      g_trans_mode = 'R'.
      CALL SCREEN 0200.
    WHEN  'ASSN'.
      g_trans_mode = 'A'.
      CLEAR ist_req-reqno.
      SUBMIT zmm_vendor_code_report VIA SELECTION-SCREEN AND RETURN.
      PERFORM disp_list.
      CLEAR save_ok.
    WHEN  'EXTN'.
      g_trans_mode = 'E'.
      """"""""""""""""""""""""""""""""""
      "ADDED BY LIPSY ON 2.07.2015 RD1K997727
      save_ok_ext = 'EXTN'.
      "END OF ADDITION BY LIPSY ON 2.07.2015  RD1K997727
      """"""""""""""""""""""""""""""""""""""""
      CALL SCREEN 0400.
    WHEN  'UNBL'.
      g_trans_mode = 'U'.
      CALL SCREEN 0400.
*    WHEN  'ADDC'.  "Uncomment this code for vendor address change
*      g_trans_mode = 'C'.
*      CLEAR save_ok.
*      PERFORM call_vendor_maintenance_screen.
    WHEN 'REPO'.
      SUBMIT zmm_vendor_request_status VIA SELECTION-SCREEN AND RETURN.
    WHEN 'SINP'.
      CLEAR save_ok.
      SUBMIT zmm_vms_autoclose VIA SELECTION-SCREEN AND RETURN.
    WHEN 'UPDTADDR'.
      CLEAR save_ok.
      CALL TRANSACTION 'ZMMVENDUPDT' .
* Begin of <> on 14102011
    WHEN 'HELP'.
      PERFORM disp_process_guide.
* End of  <> obn 14102011
*+SP009 - Start
    WHEN 'UPDTBANK'.
      CLEAR save_ok.
* Begin of <> on 11-05-10
* Begin of <RD1K968710> on 19-11-09 by Sudhir Sharma
*      CALL TRANSACTION 'ZMMVENUPDBNK' .
**+SP009 - End
*      DATA : uname TYPE sy-UNAME.
*      uname = sy-UNAME.
*      SELECT * FROM AGR_USERS
*              INTO CORRESPONDING FIELDS OF TABLE it_arg_user
*              WHERE UNAME = uname
*              AND ( AGR_NAME = 'D:FI_VEM_BANKDETAILS_PREAUDIT'
*                     or AGR_NAME = 'D:FI_FM_PR_RELEASE_C1'
*                     or AGR_NAME = 'D:FI_VEM_MASTER_MAINTAIN' ).
*        IF sy-SUBRC = 0.
      CALL SCREEN 0931.
*        ELSE.
*          MESSAGE e505(zmm).
*        ENDIF.

* End of <RD1K968710>
* End of <>
* Begin of <> on 111010

*+SP015 : Start
    WHEN 'URP'. "Update Related Partner
      CALL SCREEN 0700.
*+SP015 : End

    WHEN  'BLOC'.
      g_trans_mode = 'B'.
      CALL SCREEN 0430.
    WHEN 'SEARCH'.
      CALL TRANSACTION 'ZMMVENDHELP' .
* End of <>
    WHEN 'EXIT' OR 'CANC' OR 'BACK' .
*      LEAVE TO SCREEN 0.
      LEAVE PROGRAM.     "130510 by Sudhir Sharma
    WHEN 'GST'.
      SUBMIT zmm_vendor_gst_update VIA SELECTION-SCREEN AND RETURN .

    WHEN 'WITHOLD'.

      CALL TRANSACTION 'ZMM_WH'.

    WHEN 'IND_UPD'.

      CALL SCREEN 9100.

*** Added by ss on 31.5.21
*    WHEN 'TDS'.
*
**      CALL SCREEN 9110.
*      CALL TRANSACTION 'ZTDS_D'.
***      EOC by ss on 31.5.21

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       PAI for screen 200
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  DATA : fnd_flg.
*  save_ok = ok_code.
*  CLEAR ok_code.
  READ TABLE ist_vend INTO DATA(wa_vend1) INDEX 1.
  SELECT SINGLE  brsch , udyog_aadhaar_no FROM zmm_vms_industry INTO @DATA(ls_vms) WHERE   " ADD BY ROHIT ON 12/03/2025
 udyog_aadhaar_no EQ 'X' AND brsch EQ @wa_vend1-vend-brsch.
  IF sy-subrc EQ 0.
    udm = 'UDYAM'.

  ENDIF.
  IF udm  IS NOT INITIAL AND state IS NOT INITIAL AND code IS NOT INITIAL AND number IS NOT INITIAL  .
    CLEAR zmm_hvencrt-udyog_aadhaar.

    CONCATENATE udm state code number
        INTO zmm_hvencrt-udyog_aadhaar
        SEPARATED BY '-'.

    ud_no = zmm_hvencrt-udyog_aadhaar.
  ENDIF.

  IF zmm_hvencrt-udyog_aadhaar IS NOT INITIAL.
    SPLIT zmm_hvencrt-udyog_aadhaar
           AT '-'
           INTO udm state code number.
    ud_no = zmm_hvencrt-udyog_aadhaar.
  ENDIF.

  CASE save_ok.
    WHEN 'SAVE'.
      IF g_trans_mode = 'N'.
        PERFORM create_request.
      ELSEIF g_trans_mode = 'M'.
        PERFORM change_request.
      ENDIF.
      IF flag_gst EQ 0.
        IF g_ans = '1'.
          PERFORM clear_scr_210.

          PERFORM clear_scr_220.                              "+SP007

          REFRESH CONTROL 'TAB_CTL' FROM SCREEN 220.  "GCU 25.01.2006
          LEAVE TO SCREEN 0.
        ENDIF.
        """""""""""""""""""""""""""
        "added by lipsy on
        IF v_user_comm = 'CHNGREPL'.

          IF zmm_hvencrt-reqcl = 'R'.
            SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
              WHERE  appl = 'SRM'.

            """"""calling srm

*BREAK-POINT.
            IF NOT l_logsys  IS INITIAL.



              CALL FUNCTION 'ZSRM_VENDOR_ECC_REJECT'
                DESTINATION l_logsys
                EXPORTING
                  v_ptner = zmm_hvencrt-srmid
                IMPORTING
                  return  = return_reject.

              IF return_reject = 'Y'.

                PERFORM save_text.

                IF ist_linetab[] IS NOT INITIAL.
                  UPDATE zmm_hvencrt SET
                  rejected_by = sy-uname
                  rejected_on = sy-datum
                  reqcl = 'R'
                  WHERE reqno = zmm_hvencrt-reqno.


                  PERFORM clear_scr_210.

                  PERFORM clear_scr_220.
                  CLEAR: v_user_comm.
                  MESSAGE s247(zmm_oth) .
                  LEAVE TO SCREEN 0.
                ELSE.
                  MESSAGE s248(zmm_oth).
                  LEAVE TO SCREEN 200.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF zmm_hvencrt-reqcl = 'MS'.
            """"""""""""""
            "add by lipsy

            v_reqcl_srm = zmm_hvencrt-reqcl.

            "eadd by lipsy
            """"""""""""""""""""""""""
            IF zmm_hvencrt-srmid  IS NOT INITIAL.

              PERFORM save_text.
*PERFORM SEND_MAIL_MV.

              IF ist_linetab[] IS NOT INITIAL.
                PERFORM send_mail_mv.
                UPDATE zmm_hvencrt SET
           aeusn = sy-uname
           aedtm = sy-datum
           reqcl = 'MS'
           WHERE reqno = zmm_hvencrt-reqno.
                MESSAGE s249(zmm_oth) .
                LEAVE TO SCREEN 0.
              ELSE.
                MESSAGE s248(zmm_oth).
                LEAVE TO SCREEN 200.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
        "eadd by lipsy
        """""""""""""""""""""""""""""""
      ENDIF.
    WHEN 'DELE'.
      PERFORM delete_request.
      IF g_ans = '1'.
        PERFORM clear_scr_210.

        PERFORM clear_scr_220.                              "+SP007

        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'RELS'.
      PERFORM check_att .
      PERFORM release_request.
      CHECK g_ok_9000 <> 'DAGR'.
      PERFORM clear_scr_210.

      PERFORM clear_scr_220.                                "+SP007

      LEAVE TO SCREEN 0.
    WHEN 'ASSN'.
      IF g_analyse <> '1'.
        MESSAGE w735(zmm) WITH text-080.
        EXIT.
      ENDIF.


      PERFORM bdc_mk01.
      IF g_ans = '1'. "AND g_vend_err <> '1'.
        READ TABLE ist_bdcstatus WITH KEY msgtyp = 'S'.
* Begin of <> on 17122010
*                                          dynumb = '0320'.
* End of <> on 17122010
        IF sy-subrc = 0.
          PERFORM block_other_vendors.
*          PERFORM vendor_excise_details_update.
        ELSE.
          MESSAGE i735(zmm) WITH text-021.
        ENDIF.
*      ENDIF.
        PERFORM disp_status .
        LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
        PERFORM send_mail.
        PERFORM save_text.
        PERFORM clear_scr_210.

        PERFORM clear_scr_220.                              "+SP007

        LEAVE TO SCREEN 0.
      ENDIF.



    WHEN 'CLEA'.     "vendor found in search
      fnd_flg = 'Y'.  "vend found in search
      PERFORM update_vendor_flg TABLES ist_vend USING fnd_flg.
      CLEAR : wa_vend,g_vend.
      CLEAR ist_vend. DELETE ist_vend WHERE fnd_flg = 'Y'.
      CLEAR ist_lfa1. REFRESH ist_lfa1.
    WHEN 'RETI'.     "vendor not found in search
      g_src_button = 'X'.
      IF g_trans_mode = 'N'.
        g_opn_flg = 'X'.
      ELSEIF g_trans_mode = 'M'.
        g_opn_flg = 'M'.
      ENDIF.
      fnd_flg = g_opn_flg.  "vendor not found in search
      PERFORM search_zmm_dvencrt.
      IF g_ok_9000 = 'USE'.
        CLEAR :
          g_src_button,
          g_opn_flg,
          g_ok_9000,
          ist_lfa1.
        REFRESH ist_lfa1.
        IF NOT g_vend IS INITIAL.
          DELETE ist_vend INDEX g_vend. "tab_ctl-current_line.
        ENDIF.
        EXIT.
      ELSE.
        CLEAR g_ok_9000.
        PERFORM fine_search_lfa1 USING ' '.
        IF g_ok_9000 = 'USE'.
          CLEAR : g_src_button, g_opn_flg, g_ok_9000, ist_lfa1.
          REFRESH ist_lfa1.
          IF NOT g_vend IS INITIAL.
            DELETE ist_vend INDEX g_vend. "tab_ctl-current_line.
          ENDIF.
          EXIT.
        ELSE.
          CLEAR g_ok_9000.
          PERFORM update_vendor_flg TABLES ist_vend USING fnd_flg.
        ENDIF.
      ENDIF.
    WHEN 'HEAD'.
      g_ok_code_9010 = save_ok.
      CLEAR save_ok.

      """"""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 2.07.2015
    WHEN 'ATCH'.
      PERFORM attach_files_change.

    WHEN 'LIST'.
      PERFORM list_files_change.
      "end of addition by lipsy on 2.07.2015
      """""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 23.11.2015 RD1K999141

    WHEN 'REPLI'."replicate previous similar vendor

      READ TABLE ist_lfa1 INDEX g_linno .

      IF sy-uname+0(3) = 'CMM'.

        IF count_srm_replicate = 1.

          "add by lipsy

          SELECT SINGLE * FROM zmm_hvencrt
           INTO wa_hvencrt_reqstat
            WHERE reqno  = zmm_hvencrt-reqno.  "#EC CI_NOORDER

          IF wa_hvencrt_reqstat-reqcl  = 'AC'.

            MESSAGE s250(zmm_oth) .

          ELSE.

            IF zmm_hvencrt-srmid IS NOT INITIAL.

              PERFORM replicate_vendors_srm_cmm.
            ENDIF.
          ENDIF.

        ELSE.
          MESSAGE s189(zmm_oth) .
        ENDIF.

      ENDIF.

    WHEN 'COMPV'."replicate previous similar vendor
      IF sy-uname+0(3) = 'CMM'.

        IF count_srm_replicate = 1.


          IF zmm_hvencrt-srmid IS NOT INITIAL.



            CLEAR: wa_lfa1_compare,wa_adrc_compare,wa_adr6_compare,wa_pan_compare,
             v_lfa1_name, v_lfa1_city,v_lfa1_street1,v_lfa1_street2,v_lfa1_street3,v_lfa1_country,v_lfa1_pan,v_lfa1_mail.

            SELECT  SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF wa_lfa1_compare
            WHERE lifnr = ist_lfa1-lifnr.


            SELECT  SINGLE * FROM adrc INTO CORRESPONDING FIELDS OF wa_adrc_compare
            WHERE addrnumber = wa_lfa1_compare-adrnr.  "#EC CI_NOORDER



            SELECT  SINGLE * FROM adr6 INTO CORRESPONDING FIELDS OF wa_adr6_compare
            WHERE addrnumber = wa_lfa1_compare-adrnr.  "#EC CI_NOORDER

            v_lfa1_vendor = ist_lfa1-lifnr.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ist_lfa1-lifnr
              IMPORTING
                output = ist_lfa1-lifnr.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*            SELECT SINGLE * FROM j_1imovend
*            INTO CORRESPONDING FIELDS OF
*            wa_pan_compare
*             WHERE lifnr = ist_lfa1-lifnr.
            SELECT SINGLE * FROM lfa1
            INTO CORRESPONDING FIELDS OF
            wa_pan_compare
             WHERE lifnr = ist_lfa1-lifnr.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

            v_lfa1_name = wa_lfa1_compare-name1.
            v_lfa1_city = wa_lfa1_compare-ort01.

            v_lfa1_street1 = wa_lfa1_compare-stras.
            v_lfa1_street2 = wa_adrc_compare-str_suppl1 .
            v_lfa1_street3 = wa_adrc_compare-str_suppl2.
            v_lfa1_country = wa_lfa1_compare-land1.
            v_lfa1_pan =  wa_pan_compare-j_1ipanno.
            v_lfa1_mail = wa_adr6_compare-smtp_addr.

            v_lfa1_loevm = wa_lfa1_compare-loevm.
            v_lfa1_sperr = wa_lfa1_compare-sperr.
            v_lfa1_sperm = wa_lfa1_compare-sperm.
            v_lfa1_sperq = wa_lfa1_compare-sperq.
            v_lfa1_sperz   = wa_lfa1_compare-sperz.

*          call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
*        exporting
*          input  = ist_lfa1-LIFNR
*        importing
*          output = ist_lfa1-LIFNR.

            READ TABLE ist_vend INTO wa_vend INDEX 1.

            CLEAR:v_ros_name,v_ros_city,v_ros_street1,v_ros_street2,v_ros_country,v_ros_pan,v_ros_mail.

            v_ros_name =  wa_vend-vend-name1.
            v_ros_city = wa_vend-vend-ort01.
            v_ros_street1 = wa_vend-vend-stras1.
            v_ros_street2 = wa_vend-vend-suppl1.
            v_ros_street3 = wa_vend-vend-suppl2.
            v_ros_country = wa_vend-vend-land1.
            v_ros_pan = wa_vend-vend-j_1ipanno.
            v_ros_mail = wa_vend-vend-email.

            CALL SCREEN 240.

            CLEAR:count_srm_replicate.

          ENDIF.

        ELSE.
          MESSAGE s189(zmm_oth) .

        ENDIF.


      ENDIF.

      "end of addition by lipsy on 23.11.2015 RD1K999141
      """""""""""""""""""""""""""""""""""""""""
      """""""""""""
      "ADDED BY LIPSY ON 6.1.2016
    WHEN 'RELREPT'.
*BREAK-POINT.
      PERFORM release_request.

      CHECK g_ok_9000 <> 'DAGR'.
      PERFORM clear_scr_210.

      PERFORM clear_scr_220.
      CLEAR:g_report_flag.

    WHEN 'CHNGREPL'.

      v_user_comm = 'CHNGREPL'.




*      if g_ans = '1'.
*        perform clear_scr_210.
*
*        perform clear_scr_220.                              "+SP007
*
*        refresh control 'TAB_CTL' from screen 220.  "GCU 25.01.2006
*        leave to screen 0.
*      endif.


      "END OF ADD BY LIPSY 6.01.2016
      """"""""""""""""""""""
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  fill_ekorg  INPUT
*&---------------------------------------------------------------------*
*       check acc. grp, pur. grp & populate pur. org
*----------------------------------------------------------------------*
MODULE fill_ekorg INPUT.
  DATA l_ekgrp LIKE t024-ekgrp.
  CLEAR l_ekgrp.
  CASE g_trans_mode.
    WHEN 'N'.
      CASE zmm_hvencrt-ktokk.
        WHEN 'SVWF' OR 'SVWI'.
          IF zmm_hvencrt-bukrs = 'OBV'.
            zmm_hvencrt-ekorg = 'POBV'.
          ELSE.
            zmm_hvencrt-ekorg = 'PSRV'.
          ENDIF.
        WHEN 'IMMI' OR 'IMMF'.
          IF zmm_hvencrt-bukrs = 'OBV'.
            zmm_hvencrt-ekorg = 'POBV'.
          ELSE.
            zmm_hvencrt-ekorg = 'PMAT'.
          ENDIF.

* Begin of <> 14122010
        WHEN 'LEA1' OR 'LEA2' OR 'CONT' OR 'GOVT' OR 'LAQ1' OR 'INVT' OR 'SUBD' OR 'UTLT' OR 'ZJVC'. "131212
* Begin of <> on 16122010

*          IF zmm_hvencrt-bukrs = 'OBV'.
*             zmm_hvencrt-ekorg = 'POBV'.
*          ELSE.
*             zmm_hvencrt-ekorg = 'PSRV'.
*          ENDIF.
* End of <> 16122010
* End of <> 14122010

*Begin RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919
        WHEN 'NOMI'.
*End RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
        WHEN 'SHYG'.
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*        WHEN 'TRNI'.  "Added by Manisha bh.Dt:19.09.2018
        WHEN 'TRNI'.
        WHEN OTHERS.
          SET CURSOR FIELD zmm_hvencrt-ktokk.
          MESSAGE e729(zmm).
      ENDCASE.

  ENDCASE.
ENDMODULE.                 " fill_ekorg  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_BROWSER  INPUT
*&---------------------------------------------------------------------*
*       populate table control value into ist_vend int. table
*----------------------------------------------------------------------*
MODULE fill_browser INPUT.
  CLEAR g_rec_found.
  DATA : l_str_len(2) TYPE n.
  DATA : l_search_string(200),l_name1(40),l_name2(40),l_ort01(35).
  DATA : l_search_string_rev(200).

*  CHECK NOT sy-ucomm EQ 'PREV'.
  CHECK NOT save_ok EQ 'PREV'.

  DESCRIBE TABLE ist_vend LINES g_vend.
  CLEAR :ist_vend,l_name1,l_name2,l_ort01.
  IF NOT ist_vend[] IS INITIAL.
    READ TABLE ist_vend INDEX tab_ctl-current_line.
  ENDIF.

  CASE g_trans_mode.
    WHEN 'N'.
      PERFORM chk_for_duplicate_entry.
    WHEN 'M'.
      IF sy-subrc IS INITIAL.
        IF   ( ist_vend-vend-name1 <> wa_vend-vend-name1 OR
               ist_vend-vend-name2 <> wa_vend-vend-name2 OR
               ist_vend-vend-ort01 <> wa_vend-vend-ort01  ) AND
               ist_vend-fnd_flg = 'X' .
          PERFORM confirm_user_action USING text-009 text-010.
          IF g_ans = '1'.
            wa_vend-fnd_flg = 'M'.
            MODIFY ist_vend FROM wa_vend INDEX tab_ctl-current_line.
          ELSE.
            wa_vend = ist_vend. "org rec retained
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF ( g_trans_mode = 'N' OR g_trans_mode = 'M' ) AND
       NOT wa_vend-vend-ort01 IS INITIAL.
    l_str_len = strlen( wa_vend-vend-ort01 ).
    IF ist_cities[] IS INITIAL.
      SELECT ort01 FROM zmm_cities INTO TABLE ist_cities.  "#EC CI_NOORDER
    ENDIF.
    IF NOT ist_cities[] IS INITIAL.
      READ TABLE ist_cities WITH KEY ort01 = wa_vend-vend-ort01 .
      IF sy-subrc <> 0.
        MESSAGE e780(zmm) WITH text-057.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ist_vend-fnd_flg IS INITIAL.
    CLEAR g_src_button.
  ENDIF.
  IF NOT ist_vend-fnd_flg = 'X'.
*---start of check decision has been made on previous rec-----*
    IF NOT g_vend IS INITIAL AND
       g_vend LT tab_ctl-current_line.
      READ TABLE ist_vend INDEX g_vend.
      IF sy-subrc IS INITIAL AND ist_vend-fnd_flg = ' '.
        MESSAGE i734(zmm).
        CLEAR wa_vend.
      ENDIF.
    ENDIF.
  ENDIF.
*---end of check decision has been made on previous rec--*
  IF NOT wa_vend IS INITIAL AND
*     NOT save_ok = 'VADD' AND
     NOT save_ok = 'MODF'.
    PERFORM hit_lfa1 USING wa_vend-vend-name1 wa_vend-vend-name2
                           wa_vend-vend-ort01.
    PERFORM update_rec_found.
  ENDIF.

ENDMODULE.                 " FILL_BROWSER  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0230  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0230 INPUT.
  CASE save_ok.
    WHEN 'VADD'.
      CLEAR save_ok.
      PERFORM disp_address.

      """""""""
      "ADDED BY LIPSY
    WHEN OTHERS.

      """"""""""""""""""
      "add by lipsy

      IF g_fname = 'IST_LFA1-LIFNR'.
        IF sy-ucomm = '/CS'.
          IF  g_report_flag <> 'X'.
            SET PARAMETER ID 'LIF' FIELD ist_lfa1-lifnr.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor MK03 not available (Business Partner). Open vendor BP in display via BP navigation.
*            CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN .
            PERFORM zz_s4_show_vendor_bp USING ist_lfa1-lifnr.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
          ENDIF.
        ENDIF.
      ENDIF.

      "eadd by lipsy
      """""""""""
*        IF v_called = 'X'.
*
*  SET PARAMETER ID 'LIF' FIELD   '100'.
* CALL TRANSACTION 'MK03' .
*
*          ENDIF.

      "EADD BY LIPSY

      """"""""""""

  ENDCASE.
*  CLEAR save_ok.
ENDMODULE.                 " USER_COMMAND_0230  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0220 INPUT.
  DATA : g_fld(20).
*  FIELD-SYMBOLS : <fs_fld> TYPE ANY.
  CLEAR : g_fld.
  CASE save_ok.
    WHEN 'DELR'.
      CLEAR save_ok.
      IF g_trans_mode = 'M'.
        DESCRIBE TABLE ist_vend[] LINES g_vend.
        IF g_vend EQ 1.
          MESSAGE e735(zmm) WITH text-028.
        ENDIF.

        PERFORM chk_unbl_del_flg USING 'DELR'.              "+SP005

        PERFORM mark_rec_del.
      ELSEIF g_trans_mode = 'N'.
        PERFORM del_row.
      ELSEIF g_trans_mode = 'A' .
        DELETE ist_vend WHERE mark = 'X'.
        CLEAR : save_ok,wa_vend,ist_vend,ist_lfa1.
        REFRESH ist_lfa1.
      ENDIF.
    WHEN 'MODF'.
      CLEAR save_ok.
      READ TABLE ist_vend WITH KEY mark = 'X' TRANSPORTING
                                   NO FIELDS.
      IF sy-subrc <> 0.
        MESSAGE i270(me).
        EXIT.
      ENDIF.
      g_mod_button = 'X'.
    WHEN 'UNDO'.
      CLEAR save_ok.
      IF g_trans_mode = 'M'.
        PERFORM undo_rec_del.
      ENDIF.
    WHEN 'PREV'.
      CLEAR save_ok.
      GET CURSOR LINE g_linno.
      g_linno = g_linno + tab_ctl-top_line - 1 .
      CHECK NOT g_linno IS INITIAL.
      PERFORM print_preview.
    WHEN 'ADVS'.
      CLEAR save_ok.
*      GET CURSOR LINE g_linno.
*      CHECK NOT g_linno IS INITIAL.
      PERFORM call_adv_search.
    WHEN 'ANAL'.
      CLEAR save_ok.
      g_analyse = '1'.
      PERFORM search_zmm_dvencrt.
  ENDCASE.
  DESCRIBE TABLE ist_vend LINES g_vend.
ENDMODULE.                 " USER_COMMAND_0220  INPUT
*&---------------------------------------------------------------------*
*&      Module  FETCH_DATA  INPUT
*&---------------------------------------------------------------------*
*       fetch data for request number entered in screen
*----------------------------------------------------------------------*
MODULE fetch_data INPUT.
  IF  zmm_hvencrt-reqno IS INITIAL.
    PERFORM clear_scr_210.
    EXIT.
  ENDIF.

  IF NOT g_trans_mode = 'D'.
    PERFORM lock_table.
  ENDIF.

  "
  "add by lipsy
*  break-point.
  IF v_user_comm = 'CHNGREPL'.

    v_reqcl_srm = zmm_hvencrt-reqcl.
  ENDIF.

  "


  SELECT SINGLE * FROM zmm_hvencrt WHERE reqno = zmm_hvencrt-reqno.  "#EC CI_NOORDER
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e735(zmm) WITH text-039.
  ELSE.
    IF zmm_hvencrt-reqno IS NOT INITIAL AND zmm_hvencrt-reqcl = 'R' AND g_trans_mode <> 'D'.
      MESSAGE 'This request has been rejected, No changes possible' TYPE 'E'.
    ENDIF.

    IF zmm_hvencrt-reqcl = 'AC' AND g_trans_mode <> 'D'.

      """""""""""""""""""""""""
      "added by lipsy 24.11.2015 RD1K999141
      IF sy-uname+0(3) = 'CMM'.
      ELSE.
        "eadded by lipsy 24.11.2015 RD1K999141
        """""""""""""""""""""""""""""""""""
        MESSAGE e785(zmm) WITH zmm_hvencrt-reqno.
        EXIT.

        """"""""""""""""""""""""""""""
        "added by lipsy 24.11.2015 RD1K999141
      ENDIF.
      "eadded by lipsy 24.11.2015 RD1K999141

      """"""""""""""""""""""""""""""""""""""
    ENDIF.
    CASE g_trans_mode.
      WHEN 'M'.

        IF zmm_hvencrt-rel_flag <> ' '  AND zmm_hvencrt-ass_flag = 'F'.
          MESSAGE e742(zmm) WITH zmm_hvencrt-reqno.
        ENDIF.

        SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt WHERE
                           reqno = zmm_hvencrt-reqno AND
                           ass_flag = ' '.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e425(zmm).
        ENDIF.

      WHEN 'R'.

        IF zmm_hvencrt-rel_flag <> ' ' .
          MESSAGE e736(zmm) WITH zmm_hvencrt-reqno.
        ENDIF.

        IF zmm_hvencrt-rel_flag <> ' '  AND zmm_hvencrt-ass_flag = 'F'.
          MESSAGE e742(zmm) WITH zmm_hvencrt-reqno.
        ENDIF.

        SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt WHERE
                           reqno = zmm_hvencrt-reqno AND
                           del_flag = ' ' AND ass_flag = ' '.

      WHEN 'A'.

        IF zmm_hvencrt-rel_flag <> ' '  AND zmm_hvencrt-ass_flag = 'F'.
          MESSAGE e742(zmm) WITH zmm_hvencrt-reqno.
        ENDIF.

        SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt WHERE
                           reqno = zmm_hvencrt-reqno AND
                           del_flag = ' ' AND ass_flag = ' '.

      WHEN 'D'.
        SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt WHERE
                           reqno = zmm_hvencrt-reqno.  "#EC CI_NOORDER

      WHEN 'X'.
        IF sy-uname NE zmm_hvencrt-ernam.
          """"""""""
          IF sy-uname+0(1) = 'C'.
          ELSE.
            """""""""""""""""
            MESSAGE e361(zmm).


            """"""""""""""
          ENDIF.
          """"""""""""""""""""
        ENDIF.

        IF zmm_hvencrt-rel_flag <> ' ' OR
           zmm_hvencrt-ass_flag <> ' '.
          MESSAGE e735(zmm) WITH text-023.
        ELSE.
          SELECT * FROM zmm_dvencrt INTO TABLE ist_zmm_dvencrt WHERE
                                           reqno = zmm_hvencrt-reqno.  "#EC CI_NOORDER
        ENDIF.

    ENDCASE.

  ENDIF.

  IF NOT ist_zmm_dvencrt[] IS INITIAL AND
     ist_vend[] IS INITIAL.
    LOOP AT ist_zmm_dvencrt.
      MOVE-CORRESPONDING ist_zmm_dvencrt TO wa_vend-vend.
      wa_vend-fnd_flg = 'X'.  "Vendor NF in search in creation
      IF NOT ist_zmm_dvencrt-rsn IS INITIAL.
        wa_vend-rej_flg = 'X'.
      ENDIF.
      APPEND wa_vend TO ist_vend.
      CLEAR wa_vend.
    ENDLOOP.
  ENDIF.



ENDMODULE.                 " FETCH_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  UPDATE_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_mark INPUT.
  CLEAR g_ans.

  IF NOT ist_vend[] IS INITIAL.
    READ TABLE ist_vend INDEX tab_ctl-current_line.
    IF sy-subrc IS INITIAL AND ist_vend-vend-del_flag = ' '.
      ist_vend-mark = wa_vend-mark.
*      IF sy-ucomm = 'DELR'.
*        save_ok = sy-ucomm.
      IF wa_vend-mark = 'X' AND save_ok = 'DELR'.
        PERFORM confirm_user_action USING text-009 text-058.
        IF g_ans = 1.
          MODIFY ist_vend INDEX tab_ctl-current_line TRANSPORTING mark.
        ELSE.
          CLEAR wa_vend-mark.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " UPDATE_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  UPDATE_TABLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_table INPUT.
  CHECK NOT save_ok EQ 'VADD'.

  DATA : l_name1_str(50),l_name2_str(50),l_city_str(50).
  CLEAR l_str_len.
  CLEAR l_count.
  IF NOT ist_vend[] IS INITIAL.
    READ TABLE ist_vend INDEX tab_ctl-current_line.
    IF sy-subrc IS INITIAL.
      IF ist_vend <> wa_vend AND
         ist_vend-fnd_flg = 'X' AND
         g_trans_mode = 'M' AND
         g_ans <> 2 AND
         save_ok <> 'PREV'.
        PERFORM confirm_user_action USING text-009 text-010.
        IF g_ans = '1'.
          wa_vend-fnd_flg = 'M'.
          MODIFY ist_vend FROM wa_vend INDEX tab_ctl-current_line.
        ELSE.
          wa_vend = ist_vend. "org rec retained
          CLEAR save_ok.
        ENDIF.
      ELSE.
        MOVE-CORRESPONDING  wa_vend TO ist_vend.
        MODIFY ist_vend INDEX tab_ctl-current_line.
      ENDIF.
    ENDIF.
  ENDIF.

  IF g_trans_mode = 'M'.
    EXIT.
  ENDIF.

  IF g_trans_mode = 'N' AND
     NOT wa_vend-vend-name1 IS INITIAL AND
     NOT wa_vend-vend-name2 IS INITIAL AND
     NOT wa_vend-vend-ort01 IS INITIAL AND
     sy-ucomm = 'ENTE'.

    l_name1_str = wa_vend-vend-name1.
    l_name2_str = wa_vend-vend-name2.
    l_city_str = wa_vend-vend-ort01.

    l_str_len = strlen( l_name1_str ).
    TRANSLATE l_name1_str TO UPPER CASE.

    PERFORM get_search_string USING l_str_len
                                CHANGING l_name1_str l_count.

    l_str_len = strlen( l_name2_str ).
    TRANSLATE l_name2_str TO UPPER CASE.

    PERFORM get_search_string USING l_str_len
                                CHANGING l_name2_str l_count.

    l_str_len = strlen( l_city_str ).
    TRANSLATE l_city_str TO UPPER CASE.

    PERFORM get_search_string USING l_str_len
                                CHANGING l_city_str l_count.

**********CAB_AJIT 24.01.2006  Commented to take care to remove message

*    SELECT * FROM zmm_dvencrt WHERE name1 LIKE l_name1_str AND
*                                    name2 LIKE l_name2_str AND
*                                    ort01 LIKE l_city_str AND
*                                    ( rsn = ' ' OR lifnr = ' ' ) AND
*                                    del_flag = ' '.
*      IF sy-subrc IS INITIAL.
*        MESSAGE i735(zmm) WITH text-022.
*        EXIT.
*      ENDIF.
*    ENDSELECT.

*********CAB_AJIT ******************************************************
  ENDIF.
ENDMODULE.                 " UPDATE_TABLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  COUNTRY  INPUT
*&---------------------------------------------------------------------*
*       POV for country code
*----------------------------------------------------------------------*
MODULE country INPUT.
  DATA ist_return_tab  LIKE STANDARD TABLE OF ddshretval WITH  HEADER
                                                LINE.

  SELECT land1 landx FROM t005t INTO TABLE ist_t005t WHERE
                                           spras = 'EN'.

  IF sy-subrc IS INITIAL.

    LOOP AT ist_t005t.
      IF ( zmm_hvencrt-ktokk = 'IMMF' OR zmm_hvencrt-ktokk = 'SVWF' )
           AND ist_t005t-land1 = 'IN'.
        DELETE ist_t005t INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'LAND1'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_t005t
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    wa_vend-vend-land1 = ist_return_tab-fieldval.
  ENDIF.

ENDMODULE.                 " COUNTRY  INPUT
*&---------------------------------------------------------------------*
*&      Module  REGION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE region INPUT.
  CLEAR ist_return_tab.REFRESH ist_return_tab.

  IF ( ( zmm_hvencrt-ktokk = 'IMMI' OR
         zmm_hvencrt-ktokk = 'SVWI') AND
         ( zmm_hvencrt-ekorg = 'PMAT' OR
         zmm_hvencrt-ekorg = 'PSRV' ) ).

*    BOC on 21.3.21 by ss changes for  Company Code 'OVC'
*    wa_vend-vend-land1 = 'IN'.
    IF zmm_hvencrt-bukrs = 'OVC'.
      wa_vend-vend-land1 = 'CO'.
    ELSE.
      wa_vend-vend-land1 = 'IN'.
    ENDIF.
*    EOC on 21.3.21 by ss

  ENDIF.

  PERFORM get_row_count CHANGING g_r_count.
  PERFORM read_screen_field USING 'WA_VEND-VEND-LAND1'.
  MOVE dyfields-fieldvalue TO wa_vend-vend-land1.
  SELECT bland bezei FROM t005u INTO TABLE ist_t005u WHERE
                                 spras = 'EN' AND
                                 land1 = wa_vend-vend-land1.  "#EC CI_NOORDER
  LOOP AT ist_t005u.
*    IF ist_t005u-bland+0(1) = '1' OR ist_t005u-bland+0(1) = '2' OR
*       ist_t005u-bland+0(1) = '3' OR ist_t005u-bland+0(1) = '4' OR
*       ist_t005u-bland+0(1) = '5' OR ist_t005u-bland+0(1) = '6' OR
*       ist_t005u-bland+0(1) = '7' OR ist_t005u-bland+0(1) = '8' OR
*       ist_t005u-bland+0(1) = '9' OR ist_t005u-bland+0(1) = '0'.
*      DELETE ist_t005u INDEX sy-tabix.
*    ENDIF.
    IF ist_t005u-bland+0(1) CN '0123456789'.
      DELETE ist_t005u INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BLAND'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = ist_t005u
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  wa_vend-vend-regio = ist_return_tab-fieldval.

ENDMODULE.                 " REGION  INPUT
*&---------------------------------------------------------------------*
*&      Module  INDUSTRY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE industry INPUT.
  CLEAR ist_return_tab.REFRESH ist_return_tab.

  SELECT brsch brtxt FROM t016t INTO TABLE ist_t016t WHERE
                                              spras = 'EN'.  "#EC CI_NOORDER
  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'BRSCH'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_t016t
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    wa_vend-vend-brsch = ist_return_tab-fieldval.

  ENDIF.

ENDMODULE.                 " INDUSTRY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CURRENCY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE currency INPUT.
  CLEAR ist_return_tab.REFRESH ist_return_tab.

  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
                                          spras = 'EN'.

  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'WAERS'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_tcurt
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    wa_vend-vend-waers = ist_return_tab-fieldval.

  ENDIF.

ENDMODULE.                 " CURRENCY  INPUT
*&---------------------------------------------------------------------*
*&      Module  REQNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE reqno INPUT.
  CLEAR ist_return_tab.REFRESH ist_return_tab.

  CASE g_trans_mode.
    WHEN 'M'.
      SELECT reqno rel_flag ass_flag FROM zmm_hvencrt INTO CORRESPONDING FIELDS OF TABLE ist_req
                                              WHERE ( ass_flag = 'P'  OR
                                                      ass_flag = ' '  OR
                                                        ass_flag = 'R' ).  "#EC CI_NOORDER
    WHEN 'R'.
      SELECT reqno rel_flag ass_flag FROM zmm_hvencrt INTO CORRESPONDING FIELDS OF TABLE ist_req
                                              WHERE ( ass_flag = 'P'  OR
                                                      ass_flag = 'R'  OR
                                                    ass_flag = ' ' ) AND
                                                          rel_flag = ' '.  "#EC CI_NOORDER
    WHEN 'D'.
      SELECT reqno rel_flag ass_flag FROM zmm_hvencrt INTO CORRESPONDING FIELDS OF TABLE ist_req.  "#EC CI_NOORDER

    WHEN 'X'.
      SELECT reqno rel_flag ass_flag FROM zmm_hvencrt INTO CORRESPONDING FIELDS OF TABLE ist_req
                                                    WHERE ass_flag = ' '
                                                      AND rel_flag = ' '.  "#EC CI_NOORDER
    WHEN 'A'.
      SELECT reqno rel_flag ass_flag FROM zmm_hvencrt INTO CORRESPONDING FIELDS OF TABLE ist_req
                                                   WHERE rel_flag <> ' '
                                               AND  ( ass_flag = 'P'  OR
                                                      ass_flag = 'R'  OR
                                                        ass_flag = ' ' ).  "#EC CI_NOORDER

  ENDCASE.

  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'REQNO'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_req
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    zmm_hvencrt-reqno = ist_return_tab-fieldval.

  ENDIF.
  IF ist_req[] IS INITIAL.
    IF g_trans_mode = 'A'.
      MESSAGE i309(zmm) WITH text-029 text-030.
    ELSEIF g_trans_mode = 'R'.
      MESSAGE i309(zmm) WITH text-029 text-031.
    ELSEIF g_trans_mode = 'X'.
      MESSAGE i309(zmm) WITH text-029 text-032.
    ELSEIF g_trans_mode = 'M'.
      MESSAGE i309(zmm) WITH text-029 text-033.
    ENDIF.
  ENDIF.
ENDMODULE.                 " REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  REJECT_REASON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE reject_reason INPUT.
  CLEAR : g_ans.
  IF NOT wa_vend-rej_flg IS INITIAL AND NOT zmm_hvencrt-reqno IS INITIAL
                                         AND wa_vend-vend-rsn IS INITIAL.
    PERFORM confirm_user_action USING text-017 text-018.
    IF g_ans = 1.
      MESSAGE i735(zmm) WITH text-019.
      MODIFY ist_vend FROM wa_vend INDEX tab_ctl-current_line
                           TRANSPORTING rej_flg.
    ENDIF.
  ENDIF.
ENDMODULE.                 " REJECT_REASON  INPUT
*&---------------------------------------------------------------------*
*&      Module  ADD_REASON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE add_reason INPUT.
  IF g_trans_mode = 'M' AND
     wa_vend-vend-rsn = ' ' AND
     (  zmm_hvencrt-ass_flag = 'R' OR zmm_hvencrt-ass_flag = 'P' ).
    wa_vend-fnd_flg = 'M'.
  ENDIF.
  MODIFY ist_vend FROM wa_vend INDEX tab_ctl-current_line
                               TRANSPORTING vend-rsn fnd_flg.

ENDMODULE.                 " ADD_REASON  INPUT
*&---------------------------------------------------------------------*
*&      Module  NAME1_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE name1_fld_dclk INPUT.
  PERFORM hit_lfa1 USING wa_vend-vend-name1 ' ' ' '.

ENDMODULE.                 " NAME1_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_200  INPUT
*&---------------------------------------------------------------------*
*       EXIT command
*----------------------------------------------------------------------*
MODULE exit_200 INPUT.
  CLEAR g_report_flag.
  IMPORT g_report_flag FROM MEMORY ID 'VEND'.
  IF g_report_flag = 'X'.
    FREE MEMORY ID 'VEND'.
    LEAVE PROGRAM.
  ENDIF.
  PERFORM confirm_user_action USING text-005 text-006.
  IF g_ans = '2' OR g_ans = '3'.
  ELSEIF g_ans = '1'.
    CLEAR :  udm ,state, code ,number.
    PERFORM clear_scr_210.
    REFRESH CONTROL 'tab_ctl' FROM SCREEN '220'.
    REFRESH CONTROL 'tab_SRCH' FROM SCREEN '230'.
    SET SCREEN 0.
    LEAVE TO SCREEN 0.

    EXIT.
  ENDIF.

ENDMODULE.                 " EXIT_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BUTTON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_button INPUT.
*  CLEAR save_ok.
*  save_ok = ok_code.
*  CLEAR ok_code.

  CLEAR : g_linno, g_fname.

  GET CURSOR LINE g_linno .
  g_linno = g_linno + tab_srch-top_line - 1 .
  GET CURSOR FIELD g_fname .
  READ TABLE ist_lfa1 INDEX g_linno .
  IF sy-subrc = 0 AND save_ok = 'VADD'.
    CLEAR save_ok.
    MOVE ist_lfa1-adrnr TO g_addrnumber.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'ZMM_DISPLAY_VENDOR_ADDRESS'
        EXPORTING
          addrnumber = g_addrnumber.

*      CALL SCREEN 0500 STARTING AT 10 10  ENDING AT 80 80.
    ELSE.

    ENDIF.
    """""""""""""""""""""""
    "ADDED BY LIPSY 24.11.2015 RD1K999141
  ELSE.
    CLEAR: count_srm_replicate.
    IF sy-subrc = 0 AND ( save_ok = 'REPLI' OR save_ok = 'COMPV' ) .
      count_srm_replicate =  count_srm_replicate + 1.
    ENDIF.
    "END OF ADDition BY LIPSY 24.11.2015 RD1K999141
    """""""""""""""""""""""""""""""


  ENDIF .



*  CLEAR save_ok.
ENDMODULE.                 " CHECK_BUTTON  INPUT
*&---------------------------------------------------------------------*
*&      Module  CITY  INPUT
*&---------------------------------------------------------------------*
*       city pov
*----------------------------------------------------------------------*
MODULE city INPUT.

  PERFORM get_cities_list.

ENDMODULE.                 " CITY  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
*{if unblock vendor button clicked---
  IF g_trans_mode = 'U'.
    g_unblock_vendor = 'X'.
    g_dynnr1 = '410'.
    g_dynnr2 = '420'.
    g_cursorfield = 'IST_UNBL-LIFNR'.
    g_cursorline = '1'.
  ELSEIF g_trans_mode = 'E'.
    g_dynnr1 = '310'.
    g_dynnr2 = '320'.
  ENDIF.
*}
  save_ok = ok_code.
  CASE save_ok.
    WHEN 'CREA'.
      g_trans_mode = 'N'.
      CLEAR save_ok.
      CALL SCREEN 0300.
    WHEN 'CHAN'.
      g_trans_mode = 'M'.
      CLEAR save_ok.
      CALL SCREEN 0300.
* Begin of <> on 02022012
    WHEN 'RELS'.
      g_trans_mode = 'RL'.
      CLEAR save_ok.
      CALL SCREEN 0300.
    WHEN 'APPR'.
      g_trans_mode = 'AP'.
      CLEAR save_ok.
      CALL SCREEN 0300.
* End of <> on 02022012
    WHEN 'DISP'.
      g_trans_mode = 'D'.
      CLEAR save_ok.                                        "+RK004
*      CLEAR zmm_hvencrt.                                   "-RK004
      CALL SCREEN 0300.
*{+RK004
    WHEN 'DELE'.
      g_trans_mode = 'X'.
      CLEAR save_ok.
      CALL SCREEN 0300.
*}+RK004
    WHEN  'ASSN'.
      g_trans_mode = 'A'.
      CALL SCREEN 0300.
    WHEN 'EXIT' OR 'CANC' OR 'BACK' .
      CLEAR : ist_bdcstatus[], ist_extn[], ist_vend[], g_unblock_vendor.
      REFRESH : ist_bdcstatus[], ist_extn[], ist_vend[].
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_300 INPUT.
  PERFORM confirm_user_action USING text-005 text-006.
  IF g_ans = '2' OR g_ans = '3'.
  ELSEIF g_ans = '1'.
    PERFORM clear_scr_310.
    DATA: l_return_report(1).
    IMPORT l_return_report FROM MEMORY ID 'TEST'.
    IF l_return_report IS INITIAL.
      SET SCREEN 0.
      LEAVE TO SCREEN 0.
      EXIT.
    ELSE.
      l_return_report = space.
      EXPORT l_return_report TO MEMORY ID 'TEST'.
      LEAVE PROGRAM.
    ENDIF.

  ENDIF.

ENDMODULE.                 " EXIT_300  INPUT
*&---------------------------------------------------------------------*
*&      Module  UPDATE_TC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_tc INPUT.
  DATA l_extn_flg.
  CLEAR l_extn_flg.
  IF g_bdc_flag <> ' '.
    EXIT.
  ENDIF.

  IF ist_extn-lifnr IS INITIAL.
    CLEAR ist_extn.
  ENDIF.

  CHECK g_trans_mode <> 'D'.
  PERFORM check_extn CHANGING l_extn_flg.

  IF l_extn_flg <> 'X'.
    IF ( g_trans_mode = 'N' OR g_trans_mode = 'M' ) AND
         NOT ist_extn IS INITIAL.
      ist_extn-seqno = tab_ext-current_line.
    ENDIF.

    IF NOT ist_extn[] IS INITIAL.
      READ TABLE ist_extn INTO wa_extn INDEX tab_ext-current_line.

      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ist_extn TO wa_extn.
        MODIFY ist_extn FROM wa_extn INDEX tab_ext-current_line.
      ELSE.
        APPEND ist_extn.
      ENDIF.

    ELSE.

      APPEND ist_extn.
    ENDIF.

  ENDIF.
  CLEAR l_extn_flg.
  DELETE ADJACENT DUPLICATES FROM ist_extn COMPARING lifnr ekorg .



  """"""""""""""""""""""""""""""""""""""""""


  telf1_ro = ist_extn-telf1.
  telfx_fx = ist_extn-telfx.

  IF sy-ucomm = 'SAVE'.
    IF      ist_extn-stras1 IS INITIAL.
      MESSAGE 'Please fill Street1 entry' TYPE 'E'.
    ELSEIF  ist_extn-telf1 IS INITIAL.
      MESSAGE 'Please fill Mobile No. entry' TYPE 'E'.
    ELSEIF  ist_extn-email IS INITIAL.
      MESSAGE 'Please fill EMAIL entry ' TYPE 'E'.
    ENDIF.

    """"""""""for update data in fk03

    SELECT * FROM lfa1 INTO TABLE @DATA(val_lfa1) WHERE lifnr = @ist_extn-lifnr.

    SELECT * FROM adrc INTO TABLE @DATA(val_adrc) FOR ALL ENTRIES IN @val_lfa1 WHERE addrnumber =  @val_lfa1-adrnr .
    """"""""""for update data in fk03
    LOOP AT val_adrc INTO DATA(w_adrc).
      IF sy-subrc = 0.

        UPDATE adrc SET name1 = ist_extn-name1
                        name2 = ist_extn-name2
                        sort1 = ist_extn-sortl
                        street = ist_extn-stras1
                        str_suppl1 = ist_extn-ort01
                        str_suppl2 = ist_extn-suppl2
                        str_suppl3 = ist_extn-suppl3
                        post_code1 = ist_extn-pstlz
                        country = ist_extn-land1
                        region = ist_extn-regio
*                tel_number = IST_EXTN-TELF1
                        fax_number = ist_extn-telfx
                       WHERE addrnumber = w_adrc-addrnumber.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: LFA1 BP-managed; BRSCH/STCD1/STCD2 set via VMD_EI_API central data.
*        UPDATE lfa1 SET
*                        brsch = ist_extn-brsch
*                        stcd1 = ist_extn-stcd1
*                        stcd2   = ist_extn-stcd2 WHERE lifnr = ist_extn-lifnr.
        DATA: ls_vi_main TYPE vmds_ei_main, ls_vi_ext TYPE vmds_ei_extern, ls_vi_def TYPE vmds_ei_main.
        CLEAR: ls_vi_main, ls_vi_ext, ls_vi_def.
        ls_vi_ext-header-object_instance-lifnr = ist_extn-lifnr.
        ls_vi_ext-header-object_task = 'U'.
        ls_vi_ext-central_data-central-data-brsch = ist_extn-brsch.
        ls_vi_ext-central_data-central-data-stcd1 = ist_extn-stcd1.
        ls_vi_ext-central_data-central-data-stcd2 = ist_extn-stcd2.
        ls_vi_ext-central_data-central-datax-brsch = abap_true.
        ls_vi_ext-central_data-central-datax-stcd1 = abap_true.
        ls_vi_ext-central_data-central-datax-stcd2 = abap_true.
        APPEND ls_vi_ext TO ls_vi_main-vendors.
        CALL METHOD vmd_ei_api=>maintain_bapi EXPORTING iv_test_run = space iv_collect_messages = 'X' is_master_data = ls_vi_main IMPORTING es_master_data_defective = ls_vi_def.
        IF ls_vi_def-vendors IS INITIAL. COMMIT WORK. ELSE. ROLLBACK WORK. ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

        UPDATE adr6 SET smtp_addr = ist_extn-email WHERE addrnumber = w_adrc-addrnumber.

        UPDATE adr2 SET tel_number = ist_extn-telf1 WHERE addrnumber = w_adrc-addrnumber AND home_flag = 'X'.

      ENDIF.
    ENDLOOP.
  ENDIF.
  """"""""""""""""""""""""""""""""""""""""""

ENDMODULE.                 " UPDATE_TC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CURRENCY_320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE currency_320 INPUT.
  CLEAR ist_return_tab.REFRESH ist_return_tab.

  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
                                          spras = 'EN'.

  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'WAERS'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_tcurt
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ist_extn-waers = ist_return_tab-fieldval.

  ENDIF.

ENDMODULE.                 " CURRENCY_320  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  save_ok = ok_code.
  CASE save_ok.
    WHEN 'SAVE'.
      IF g_unblock_vendor = 'X'.
        PERFORM action_unblock_request.
*        PERFORM clear_scr_310.   "13042011
*        LEAVE TO SCREEN 0.
* Begin of <> on 07122010
      ELSEIF g_block_vendor = 'X'.
        PERFORM action_block_request.
*        PERFORM clear_scr_310.    "13042011
*        LEAVE TO SCREEN 0.
* End of <> on 07122010

      ELSE.

*        IF g_trans_mode = 'X'.
*          IF
*
*        ENDIF.
        PERFORM create_ext_request.
        IF g_ans = '1'.
          CLEAR g_bdc_flag.
          PERFORM bdc_mk01_ext.
          PERFORM extn_status .
          LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
        ENDIF.
      ENDIF.
* Begin of < > on 19042011 by Sudhir Sharma
      IF ( g_trans_mode <> 'N' AND zmm_vend_unblock-reqno IS INITIAL ) OR
         ( g_trans_mode <> 'N' AND zmm_vend_block-reqno IS INITIAL ).
* End of <> on 19042011
        PERFORM clear_scr_310.
        LEAVE TO SCREEN 0.
* Begin of <> on 21042011
      ELSEIF ( g_trans_mode = 'N' AND NOT zmm_vend_unblock-reqno IS INITIAL ) OR
             ( g_trans_mode = 'N' AND NOT zmm_vend_block-reqno IS INITIAL ).
        PERFORM clear_scr_310.
        LEAVE TO SCREEN 0.
      ENDIF.
* End of <> on 21042011
    WHEN 'ASSN' OR 'UNBL' OR 'BLOC'.
      IF NOT zmm_vend_unblock-reqno IS INITIAL.
        CHECK NOT zmm_vend_unblock-reqno IS INITIAL.
        PERFORM unblock_bdc.
        PERFORM update_ztable.
        PERFORM clear_scr_310.
*        DATA: l_return_report(1).
        IMPORT l_return_report FROM MEMORY ID 'TEST'.
        IF l_return_report IS INITIAL.
          LEAVE TO SCREEN 0.
        ELSE.
          l_return_report = space.
          EXPORT l_return_report TO MEMORY ID 'TEST'.
          LEAVE PROGRAM.
        ENDIF.
        .
* Begin of <> on 08122010
      ELSEIF NOT zmm_vend_block-reqno IS INITIAL.
        PERFORM block_bdc.
        PERFORM update_bl_ztable.
        PERFORM clear_scr_310.
        LEAVE TO SCREEN 0.
      ENDIF.
* End of <> on 08122010
*+SP005 - Start - Codes for attachment
    WHEN 'ATCH'.
      IF g_unblock_vendor = 'X'.
        PERFORM process_attach_file USING g_trans_mode.
      ELSEIF g_block_vendor = 'X'.
        PERFORM process_attach_file_bl USING g_trans_mode.
      ENDIF.
    WHEN 'LIST'.
      IF g_unblock_vendor = 'X'.
        PERFORM process_list_attach_file USING g_trans_mode.
      ELSEIF g_block_vendor = 'X'.
        PERFORM process_list_attach_file_bl USING g_trans_mode.
      ENDIF.
*+SP005 - End

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  REQNO_EXT  INPUT
*&---------------------------------------------------------------------*
*       POV for requext number in vendor extension
*----------------------------------------------------------------------*
MODULE reqno_ext INPUT.
  CLEAR ist_req. REFRESH ist_req.
  CASE g_trans_mode.
    WHEN 'M'.
      SELECT reqno erfdt FROM zmm_hvenext INTO CORRESPONDING FIELDS OF TABLE ist_req
                                                  WHERE ass_flag = ' ' .  "#EC CI_NOORDER
    WHEN 'R'.
      SELECT reqno erfdt  FROM zmm_hvenext INTO CORRESPONDING FIELDS OF TABLE ist_req
                                               WHERE ass_flag = ' ' AND
                                                rel_flag = ' '.  "#EC CI_NOORDER
    WHEN 'D'.
*     SELECT reqno erfdt FROM zmm_hvenext INTO TABLE ist_req.   *"-SP006
      SELECT reqno bukrs erfdt FROM zmm_hvenext
              INTO CORRESPONDING FIELDS OF TABLE ist_req.   "+SP006

    WHEN 'X'.
      SELECT reqno erfdt  FROM zmm_hvenext INTO CORRESPONDING FIELDS OF TABLE ist_req
                                                   WHERE ass_flag = ' '
                                                     AND rel_flag = ' '.  "#EC CI_NOORDER
    WHEN 'A'.
      SELECT reqno erfdt FROM zmm_hvenext INTO CORRESPONDING FIELDS OF TABLE ist_req WHERE
                                                     rel_flag <> ' '
                                                    AND ass_flag = ' ' .  "#EC CI_NOORDER

  ENDCASE.

  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'REQNO'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_req
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    zmm_hvenext-reqno = ist_return_tab-fieldval.

  ENDIF.
  IF ist_req[] IS INITIAL.
    IF g_trans_mode = 'A'.
      MESSAGE i309(zmm) WITH text-029 text-030.
    ELSEIF g_trans_mode = 'R'.
      MESSAGE i309(zmm) WITH text-029 text-031.
    ELSEIF g_trans_mode = 'X'.
      MESSAGE i309(zmm) WITH text-029 text-032.
    ELSEIF g_trans_mode = 'M'.
      MESSAGE i309(zmm) WITH text-029 text-033.
    ENDIF.
  ENDIF.

ENDMODULE.                 " REQNO_EXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  FETCH_DATA_EXT  INPUT
*&---------------------------------------------------------------------*
*       Request number check validity & fetch data
*----------------------------------------------------------------------*
MODULE fetch_data_ext INPUT.
  CLEAR ist_extn. REFRESH ist_extn.
  CLEAR : g_loc_text, g_com_text.
  SELECT SINGLE * FROM zmm_hvenext WHERE reqno = zmm_hvenext-reqno.  "#EC CI_NOORDER
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e735(zmm) WITH text-039.
    EXIT.
  ELSE.
    SELECT * FROM zmm_dvenext INTO CORRESPONDING FIELDS OF TABLE ist_extn
                                          WHERE reqno = zmm_hvenext-reqno.  "#EC CI_NOORDER

  ENDIF.

ENDMODULE.                 " FETCH_DATA_EXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0320 INPUT.
  CLEAR : save_ok.
  MOVE ok_code TO save_ok.
  CASE save_ok.
    WHEN 'DELR'.
      IF g_trans_mode = 'M' OR g_trans_mode = 'N'.
        LOOP AT ist_extn WHERE mark = 'X'.
          DELETE ist_extn INDEX sy-tabix.
        ENDLOOP.
      ENDIF.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0320  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_land  INPUT
*&---------------------------------------------------------------------*
*       check validity of country value
*----------------------------------------------------------------------*
MODULE check_land INPUT.
  SELECT land1 landx FROM t005t INTO TABLE ist_t005t WHERE
                                             spras = 'EN' AND
                                             land1 = wa_vend-vend-land1.  "#EC CI_NOORDER
  IF sy-subrc <> 0.
    MESSAGE e780(zmm) WITH text-051.
  ENDIF.
ENDMODULE.                 " check_land  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_COUNTRY_LIST  INPUT
*&---------------------------------------------------------------------*
*       COUNTRY LIST DROP DOWN
*----------------------------------------------------------------------*
MODULE get_country_list INPUT.

  PERFORM list_box USING 'WA_VEND-VEND-LAND1'.

ENDMODULE.                 " GET_COUNTRY_LIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_region  INPUT
*&---------------------------------------------------------------------*
*       validate region
*----------------------------------------------------------------------*
MODULE check_region INPUT.

  PERFORM postal_check USING ' '
                             wa_vend-vend-land1
                             wa_vend-vend-regio.

*  SELECT bland bezei FROM t005u INTO TABLE ist_t005u WHERE
*                                   spras = 'EN' AND
*                                   bland = wa_vend-vend-regio.
*  LOOP AT ist_t005u.
*    IF ist_t005u-bland+0(1) = '1' OR ist_t005u-bland+0(1) = '2' OR
*       ist_t005u-bland+0(1) = '3' OR ist_t005u-bland+0(1) = '4' OR
*       ist_t005u-bland+0(1) = '5' OR ist_t005u-bland+0(1) = '6' OR
*       ist_t005u-bland+0(1) = '7' OR ist_t005u-bland+0(1) = '8' OR
*       ist_t005u-bland+0(1) = '9' OR ist_t005u-bland+0(1) = '0'.
*      DELETE ist_t005u INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.
*
*
*  READ TABLE ist_t005u WITH KEY bland = wa_vend-vend-regio.
*
*  IF sy-subrc <> 0.
*    MESSAGE e780(zmm) WITH text-050.
*  ENDIF.

ENDMODULE.                 " check_region  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_industry  INPUT
*&---------------------------------------------------------------------*
*       Validate industry
*----------------------------------------------------------------------*
MODULE check_industry INPUT.

  SELECT brsch brtxt FROM t016t INTO TABLE ist_t016t WHERE
                                           spras = 'EN' AND
                                           brsch = wa_vend-vend-brsch.
  IF sy-subrc <> 0.
    MESSAGE e780(zmm) WITH text-049.
  ENDIF.

ENDMODULE.                 " check_industry  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_currency  INPUT
*&---------------------------------------------------------------------*
*       Validate currency
*----------------------------------------------------------------------*
MODULE check_currency INPUT.

  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
                                           spras = 'EN' AND
                                           waers = wa_vend-vend-waers.
  IF sy-subrc <> 0.
    MESSAGE e780(zmm) WITH text-052.
  ENDIF.

ENDMODULE.                 " check_currency  INPUT


MODULE check_gst_no INPUT.

  IF wa_vend-vend-ven_class NE '0'.

    IF wa_vend-vend-gst_no+0(2) NE wa_vend-vend-regio.

      MESSAGE 'First two chars of GST No. should be Region code' TYPE 'E'.

    ELSEIF wa_vend-vend-gst_no+2(10) NE  wa_vend-vend-j_1ipanno.

      MESSAGE '3rd to 12th Chars of GST No. should be equal to Pan No.' TYPE 'E'.

    ENDIF.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  DATA:leng(16).

  IF wa_vend-vend-gst_no IS NOT INITIAL.
    leng = strlen( wa_vend-vend-gst_no ).
    IF leng NE 15.
      MESSAGE:'Please Enter Correct 15 Digit GST No.' TYPE 'E'.
    ENDIF.
  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



*  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
*                                           spras = 'EN' AND
*                                           waers = wa_vend-vend-waers.
  IF sy-subrc <> 0.
*    MESSAGE e780(zmm) WITH text-052.
  ENDIF.

ENDMODULE.
*{   INSERT         OCPK900113                                        1
MODULE f4_ven_class INPUT.

  TYPES: BEGIN OF ty_dd07v,
           domvalue_l TYPE dd07v-domvalue_l,
           ddtext     TYPE dd07v-ddtext,
         END OF ty_dd07v.
  DATA : it_dd07v TYPE TABLE OF ty_dd07v,
         wa_dd07v TYPE ty_dd07v.

  CLEAR :  it_dd07v.

  SELECT domvalue_l ddtext INTO CORRESPONDING FIELDS OF TABLE it_dd07v FROM dd07v WHERE domname = 'J_1IGTAXKD'.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DOMVALUE_L'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_VEND-VEND-VEN_CLASS'
      value_org       = 'S'
    TABLES
      value_tab       = it_dd07v
*     return_tab      = ist_return_tab1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.




ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  NAME2_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*       SEARCH NAME2 IN NAME1
*----------------------------------------------------------------------*
MODULE name2_fld_dclk INPUT.
  PERFORM hit_lfa1 USING wa_vend-vend-name1 wa_vend-vend-name2 ' '.
ENDMODULE.                 " NAME2_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*&      Module  ORT01_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*       Search city in name1 name2 combination
*----------------------------------------------------------------------*
MODULE ort01_fld_dclk INPUT.
  PERFORM hit_lfa1 USING wa_vend-vend-name1 wa_vend-vend-name2
wa_vend-vend-ort01.
ENDMODULE.                 " ORT01_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'DENT'.
      CLEAR save_ok.
      CLEAR :g_addrnumber,addr1_data,wa_addr1_complete,wa_addr1_tab.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_currency_ext  INPUT
*&---------------------------------------------------------------------*
*       validate currency
*----------------------------------------------------------------------*
MODULE check_currency_ext INPUT.
  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt WHERE
                                             spras = 'EN' AND
                                             waers = ist_extn-waers.  "#EC CI_NOORDER
  IF sy-subrc <> 0.
    MESSAGE e780(zmm) WITH text-052.
  ELSE.

  ENDIF.

ENDMODULE.                 " check_currency_ext  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_vendor  INPUT
*&---------------------------------------------------------------------*
*       validate vendor
*----------------------------------------------------------------------*
MODULE check_vendor INPUT.
  IF g_unblock_vendor = 'X'.
    g_lifnr = ist_unbl-lifnr.
  ELSE.
    g_lifnr = ist_extn-lifnr.
  ENDIF.

  SELECT SINGLE * FROM lfa1 INTO ist_lfa1 WHERE
                              lifnr = g_lifnr.

*SELECT single lifnr FROM lfa1 INTO ist_lfa1 where lifnr = g_lifnr.
  IF sy-subrc <> 0.
    MESSAGE e011(zmm) WITH g_lifnr.
    EXIT.
  ELSEIF g_unblock_vendor = 'X'.

*+SP006 - Codes for unblocking option - Purchasing/posting/RFQ
    IF ist_lfa1-sperm <> 'X' AND
       ist_lfa1-sperr <> 'X' AND
       ist_lfa1-loevm <> 'X' AND     "291010 by SS
       ist_lfa1-sperq <> '05'.
      MESSAGE e022(me) WITH 'Status Not'.
    ENDIF.

    ist_unbl-sperm = ist_lfa1-sperm.
    ist_unbl-sperr = ist_lfa1-sperr.
    ist_unbl-loevm = ist_lfa1-loevm.  "291010 by SS

    IF ist_lfa1-sperq = '05'.
      ist_unbl-blrfq = 'X'.
    ELSE.
      CLEAR ist_unbl-blrfq.
    ENDIF.
*+SP006

*    ist_unbl-sperm = ist_lfa1-sperm.                        "-SP006
*    ist_unbl-sperr = ist_lfa1-sperr.                        "-SP006

  ENDIF.

*{- commented as per finance recomm
*  IF NOT ist_lfa1-sperm IS INITIAL AND
*     NOT sy-ucomm EQ 'DELR'.
*    MESSAGE w022(me).
*    CLEAR ist_extn.
*    EXIT.
*  ENDIF.
*{+ startcode for vendor blocking as per finance

  IF NOT g_lifnr IS INITIAL AND g_unblock_vendor <> 'X'
     AND  sy-dynnr <> '0320'.
    SELECT SINGLE * FROM bsik WHERE lifnr = g_lifnr.
    IF sy-subrc <> 0.
      MESSAGE w022(me).
      CLEAR ist_extn.
      EXIT.
    ENDIF.
  ENDIF.
*{+ endcode for vendor blocking as per finance

  IF NOT g_lifnr IS INITIAL AND g_unblock_vendor <> 'X'
     AND  sy-dynnr = '0320'.
    IF NOT ist_lfa1-sperm IS INITIAL OR
       NOT ist_lfa1-sperr IS INITIAL.
      MESSAGE w022(me).
      CLEAR ist_extn.
      EXIT.
    ENDIF.
  ENDIF.
* Begin of <> on 291010
*  IF NOT ist_lfa1-loevm IS INITIAL.
*    MESSAGE w740(06) WITH g_lifnr.
*    CLEAR ist_extn.
*    EXIT.
*  ENDIF.
* End of <>
  SELECT SINGLE * FROM  lfb1
                  WHERE lifnr = ist_extn-lifnr
                  AND   bukrs = zmm_hvenext-bukrs.
  IF sy-subrc IS INITIAL.
    MESSAGE w162(f2) WITH ist_extn-lifnr zmm_hvenext-bukrs.
  ENDIF.



ENDMODULE.                 " check_vendor  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURRENCY_LIST  INPUT
*&---------------------------------------------------------------------*
*       currency lov
*----------------------------------------------------------------------*
MODULE get_currency_list INPUT.

  PERFORM list_box USING 'WA_VEND-VEND-WAERS'.

ENDMODULE.                 " GET_CURRENCY_LIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_INDUSTRY_LIST  INPUT
*&---------------------------------------------------------------------*
*       Industry LOV
*----------------------------------------------------------------------*
MODULE get_industry_list INPUT.

  PERFORM list_box USING 'WA_VEND-VEND-BRSCH'.
  PERFORM list_box USING 'WA_VEND-VEND-BRSCH2'.
  PERFORM list_box USING 'WA_VEND-VEND-BRSCH3'.

*  PERFORM list_box_industry.

ENDMODULE.                 " GET_INDUSTRY_LIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_postal  INPUT
*&---------------------------------------------------------------------*
*       postal code check
*----------------------------------------------------------------------*
MODULE check_postal INPUT.

  PERFORM postal_check USING wa_vend-vend-pstlz
                             wa_vend-vend-land1
                             wa_vend-vend-regio.

ENDMODULE.                 " check_postal  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISTRICT  INPUT
*&---------------------------------------------------------------------*
*       district pov
*----------------------------------------------------------------------*
MODULE district INPUT.
  CLEAR ist_return_tab.
  IF ( zmm_hvencrt-ktokk = 'IMMI' OR
       zmm_hvencrt-ktokk = 'SVWI' ).
    SELECT * FROM zmm_districts INTO TABLE ist_dist.  "#EC CI_NOORDER
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'ORT02'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          value_org       = 'S'
        TABLES
          value_tab       = ist_dist
          return_tab      = ist_return_tab
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      wa_vend-vend-ort02 = ist_return_tab-fieldval.
    ENDIF.
  ENDIF.

ENDMODULE.                 " DISTRICT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_sortl  INPUT
*&---------------------------------------------------------------------*
*       search term entry
*----------------------------------------------------------------------*
MODULE check_sortl INPUT.
  IF NOT wa_vend-vend-rsn IS INITIAL AND
        NOT wa_vend-vend-sortl IS INITIAL AND
        NOT g_trans_mode = 'D'.
    SET CURSOR FIELD wa_vend-vend-rsn.
    """"""""""""""""
    IF sy-uname+0(3) = 'CMM'.
    ELSE.
      """"""""""""""""""
      MESSAGE e735(zmm) WITH text-055.
      """"""""""""""""
    ENDIF.
    """""""""""""""
    EXIT.
  ENDIF.

ENDMODULE.                 " check_sortl  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_REASON_LIST  INPUT
*&---------------------------------------------------------------------*
*       reason list
*----------------------------------------------------------------------*
MODULE get_reason_list INPUT.

  PERFORM list_box USING 'WA_VEND-VEND-RSN'.

ENDMODULE.                 " GET_REASON_LIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  BUSINESS_TYPE  INPUT
*&---------------------------------------------------------------------*
*       TYPE OF BUSINESS
*----------------------------------------------------------------------*
MODULE business_type INPUT.
  DATA : ist_bus LIKE STANDARD TABLE OF bustype.
  CLEAR ist_return_tab.
  IF  zmm_hvencrt-ekorg = 'PMAT'.

    SELECT * FROM bustype INTO TABLE ist_bus.
    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield        = 'J_1KFTBUS'
          dynpprog        = sy-cprog
          dynpnr          = sy-dynnr
          value_org       = 'S'
        TABLES
          value_tab       = ist_bus
          return_tab      = ist_return_tab
        EXCEPTIONS
          parameter_error = 1
          no_values_found = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      wa_vend-vend-j_1kftbus = ist_return_tab-fieldval.
    ENDIF.
  ENDIF.

ENDMODULE.                 " BUSINESS_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TYPE_OF_BUSINESS_LIST  INPUT
*&---------------------------------------------------------------------*
*       LIST BOX FOR TYPE OF BUSINESS
*----------------------------------------------------------------------*
MODULE get_type_of_business_list INPUT.

  PERFORM list_box USING 'WA_VEND-VEND-J_1KFTBUS'.

ENDMODULE.                 " GET_TYPE_OF_BUSINESS_LIST  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_location_text  INPUT
*&---------------------------------------------------------------------*
*       populate location text on the screen
*----------------------------------------------------------------------*
MODULE get_location_text INPUT.
  IF g_unblock_vendor = 'X'.
    EXIT.
  ENDIF.

  IF NOT zmm_hvenext-reqloc IS INITIAL.
    PERFORM get_location_text USING zmm_hvenext-reqloc.
  ELSE.
    PERFORM get_location_text USING zmm_hvencrt-reqloc.
  ENDIF.

  "
  """"""""""""""""""""""""""""""""""""
  "add by lipsy

  IF v_user_comm = 'CHNGREPL'.
    IF  v_reqcl_srm = 'MS'.
      zmm_hvencrt-reqcl = v_reqcl_srm.

    ENDIF.
  ENDIF.
  "eadd by lipsy for overwriting of reqcl
  """"""""""""""""""""""""""
  "

ENDMODULE.                 " get_location_text  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*       Handle user actions for screen 210 (handle long text)
*----------------------------------------------------------------------*
MODULE user_command_0210 INPUT.
*  save_ok = ok_code.
*  IF ok_code = 'LOGG'.
*    CLEAR ok_code.
*  ENDIF.
  CASE save_ok.
    WHEN 'LOGG'.
      ""

      """""
      CALL SCREEN 0600 STARTING AT 85 05 ENDING AT 148 23.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0210  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       handle user command
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  CASE sy-ucomm.
    WHEN 'OK'.
      PERFORM get_text.
    WHEN 'CANCEL'.
*      FREE w_container.
*      CLEAR w_container.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_bukrs_text  INPUT
*&---------------------------------------------------------------------*
*       company code text
*----------------------------------------------------------------------*
MODULE get_bukrs_text INPUT.
  IF g_unblock_vendor = 'X'.
    EXIT.
  ENDIF.
  IF NOT zmm_hvenext-bukrs IS INITIAL.
    PERFORM validate_bukrs USING zmm_hvenext-bukrs.
    PERFORM get_company_code USING zmm_hvenext-bukrs.
  ELSE.
    PERFORM validate_bukrs USING zmm_hvencrt-bukrs.
    PERFORM get_company_code USING zmm_hvencrt-bukrs.
  ENDIF.

ENDMODULE.                 " get_bukrs_text  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.

  SELECT SINGLE * FROM t001w WHERE werks = ist_extn-werks.
  IF sy-subrc <> 0.
    MESSAGE e892(m7) WITH ist_extn-werks.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_OEM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_oem INPUT.
  IF wa_vend-vend-j_1kftbus = 'OEM'.
    LOOP AT SCREEN.
      IF screen-group1 = 'B2'.
        screen-input = 1.
        screen-required = 1.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR wa_vend-vend-zoem_rem.
    LOOP AT SCREEN.
      IF screen-group1 = 'B2'.
        screen-input = 0.
        screen-required = 0.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " CHECK_OEM  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_SPL_ACTIONS_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_spl_actions_0200 INPUT.
  save_ok = ok_code.
  CASE save_ok.

    WHEN 'CHAN'.
      PERFORM change_request.
      IF g_ans = '1'.
        PERFORM clear_scr_210.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_SPL_ACTIONS_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_plant INPUT.

  SELECT SINGLE * FROM  lfm1
                  WHERE lifnr = ist_extn-lifnr
                  AND   ekorg = ist_extn-ekorg.
  IF sy-subrc IS INITIAL.
    SELECT SINGLE * FROM  lfb1
                    WHERE lifnr = ist_extn-lifnr
                    AND   bukrs = zmm_hvenext-bukrs.
    IF sy-subrc IS INITIAL.

      MESSAGE w167(f2) WITH ist_extn-lifnr zmm_hvenext-bukrs
                            ist_extn-ekorg.
    ELSE.
      MESSAGE w166(f2) WITH ist_extn-lifnr ist_extn-ekorg.
    ENDIF.
  ENDIF.


  PERFORM list_box USING 'IST_EXTN-WERKS'.

ENDMODULE.                 " GET_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tab_unbl  INPUT
*&---------------------------------------------------------------------*
*       modify table control
*----------------------------------------------------------------------*
MODULE modify_tab_unbl INPUT.
  IF sy-datar = 'X'.
    g_datar = 'X'.
  ENDIF.

*-SP006
*  IF ist_unbl-sperm <> 'X' AND
*     ist_unbl-sperr <> 'X'.
*    MESSAGE w022(me) WITH 'Status Not'.
*    EXIT.
*  ENDIF.
*-SP006

  PERFORM chk_block_flg USING g_trans_mode.                 "+SP006

  ist_unbl-seqno = tab_unbl-current_line.
* Begin of <> on 19042011
  SELECT * FROM zmm_vend_unblock INTO TABLE ist_zmm_vend_unblock WHERE lifnr = g_lifnr.
  IF sy-subrc = 0.

    """"""""""
    "commented by lipsy on 29.05.2013 for considering deletion flag also
*    read table ist_zmm_vend_unblock into wa_zmm_vend_unblock with key lifnr = g_lifnr ass_flag = ''.
    "end of comment by lipsy on 29.05.2013 for considering deletion flag also


    "added by lipsy on 29.05.2013 for considering deletion flag also
    READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock WITH KEY lifnr = g_lifnr ass_flag = '' del_flag = 'X'.
    "end of add by lipsy on 29.05.2013 for considering deletion flag also

    """""""""""""""""""""
    IF sy-subrc = 0.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 29.05.2013 for considering deletion flag also

    ELSE.
      """"""" "end of add by lipsy on 29.05.2013 for considering deletion flag also


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      MESSAGE i936(zmm) WITH g_lifnr.
    ENDIF.
  ENDIF.
* End of <> on 19042011

  MOVE ist_unbl-pstlz TO ist_unbl-zpstlz.
  MODIFY ist_unbl INDEX tab_unbl-current_line.
  IF sy-subrc <> 0.
    APPEND ist_unbl.
  ENDIF.



ENDMODULE.                 " modify_tab_unbl  INPUT
*&---------------------------------------------------------------------*
*&      Module  tc_test_mark  INPUT
*&---------------------------------------------------------------------*
*       update selection
*----------------------------------------------------------------------*
MODULE tc_test_mark INPUT.
*  IF tab_unbl-line_sel_mode = 1.  "and g_TC_TEST_wa-flag = 'X'.
*    LOOP AT ist_unbl WHERE mark = 'X'.
*      ist_unbl-mark = ''.
*      MODIFY ist_unbl TRANSPORTING mark.
*    ENDLOOP.
*    IF g_trans_mode <> 'A'.
*      CLEAR ist_unbl-del_flag.
*      ist_unbl-mark = 'X'.
*    ELSE.
*      CLEAR ist_unbl-mark.
*      ist_unbl-del_flag = 'X'.
*    ENDIF.
*  ENDIF.

*+SP006 - Set del_flag if sy-ucomm have a value 'DELE'
  IF sy-ucomm = text-099.
    g_ok_code_dele = text-099.
  ENDIF.
*+SP006 - end

* IF ist_unbl-mark = 'X'.                                   "-SP006
  IF ist_unbl-mark = 'X' AND g_ok_code_dele = text-099.     "+SP006
    ist_unbl-del_flag = 'X'.
    CLEAR ist_unbl-mark.
    CLEAR g_ok_code_dele.
  ENDIF.
  MODIFY ist_unbl INDEX tab_unbl-current_line TRANSPORTING mark del_flag
                                                                        .

ENDMODULE.                 " tc_test_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  reqno_unbl  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE reqno_unbl INPUT.
  CLEAR : ist_requnbl, ist_return_tab.
  REFRESH : ist_requnbl, ist_return_tab.
* Begin of <> on 10022012
*  SELECT reqno bukrs erfdt ass_flag lifnr ernam FROM zmm_vend_unblock
*                     INTO TABLE ist_req WHERE del_flag <> 'X'.
*
*  CASE g_trans_mode.
*    WHEN 'A' OR 'M'.
*      DELETE ist_req WHERE ass_flag = 'X'.
*      DELETE ist_req WHERE reqno = ' '.
*  ENDCASE.
*
*  SORT ist_req.
*  DELETE ADJACENT DUPLICATES FROM ist_req COMPARING reqno.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'REQNO'
*      dynpprog        = sy-cprog
*      dynpnr          = sy-dynnr
*      value_org       = 'S'
*    TABLES
*      value_tab       = ist_req
*      return_tab      = ist_return_tab
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

  CASE g_trans_mode.
    WHEN 'M'.
      SELECT reqno bukrs lifnr ernam erfdt zrelease releasedby zapprove approvedby
      ass_flag assigned_by assign_date FROM zmm_vend_unblock INTO TABLE ist_requnbl
      WHERE ass_flag <> 'X'.  "#EC CI_NOORDER

    WHEN 'RL'.
      SELECT reqno bukrs lifnr ernam erfdt zrelease releasedby zapprove approvedby
      ass_flag assigned_by assign_date FROM zmm_vend_unblock INTO TABLE ist_requnbl
      WHERE zrelease <> 'X'.  "#EC CI_NOORDER

    WHEN 'AP'.
      SELECT reqno bukrs lifnr ernam erfdt zrelease releasedby zapprove approvedby
      ass_flag assigned_by assign_date FROM zmm_vend_unblock INTO TABLE ist_requnbl
      WHERE zrelease = 'X' AND zapprove <> 'X'.  "#EC CI_NOORDER

    WHEN 'A'.
      SELECT reqno bukrs lifnr ernam erfdt zrelease releasedby zapprove approvedby
      ass_flag assigned_by assign_date FROM zmm_vend_unblock INTO TABLE ist_requnbl
      WHERE zrelease = 'X' AND zapprove = 'X' AND ass_flag <> 'X'.  "#EC CI_NOORDER
    WHEN 'D'.
      SELECT reqno bukrs lifnr ernam erfdt zrelease releasedby zapprove approvedby
      ass_flag assigned_by assign_date FROM zmm_vend_unblock INTO TABLE ist_requnbl.  "#EC CI_NOORDER
  ENDCASE.

  SORT ist_requnbl.
  DELETE ADJACENT DUPLICATES FROM ist_requnbl COMPARING reqno.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'REQNO'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = ist_requnbl
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* End of <> on 10022012
  zmm_vend_unblock-reqno = ist_return_tab-fieldval.

ENDMODULE.                 " reqno_unbl  INPUT
*&---------------------------------------------------------------------*
*&      Module  fetch_data_unbl  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fetch_data_unbl INPUT.

  CLEAR ist_unbl.
  REFRESH ist_unbl.


  SELECT * FROM zmm_vend_unblock INTO CORRESPONDING FIELDS OF TABLE
                                 ist_zmm_vend_unblock WHERE
                                 reqno = zmm_vend_unblock-reqno .
  IF sy-subrc <> 0.
    MESSAGE e218(zmm).
    EXIT.
  ELSE.
    IF g_trans_mode = 'RL'.
      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock
                                        WITH KEY reqno = zmm_vend_unblock-reqno zrelease = 'X'.
      IF sy-subrc = 0.
        MESSAGE s943(zmm) WITH wa_zmm_vend_unblock-reqno.
      ENDIF.
    ELSEIF g_trans_mode = 'AP'.
      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock
         WITH KEY reqno = zmm_vend_unblock-reqno zrelease = 'X'.
      IF sy-subrc <> 0.
        MESSAGE e946(zmm) WITH zmm_vend_unblock-reqno.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE g_trans_mode.
    WHEN 'A' OR 'M'.
* Begin of <> on 15022012
      IF g_trans_mode = 'A'.
        READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock
                                        WITH KEY zapprove = 'X'.
        IF sy-subrc <> 0.
          MESSAGE e365(zmm).
          EXIT.
        ENDIF.
      ENDIF.
* End of <> on 15022012
      DELETE ist_zmm_vend_unblock WHERE ass_flag = 'X' OR
                                        del_flag = 'X'.
      IF ist_zmm_vend_unblock[] IS INITIAL.
        MESSAGE e742(zmm) WITH zmm_vend_unblock-reqno.
        EXIT.
      ENDIF.
    WHEN 'X'.
      READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock
                                      WITH KEY ass_flag = 'X'.
      IF sy-subrc = 0.
        MESSAGE e357(zmm).
        EXIT.
      ENDIF.
    WHEN 'D'.

  ENDCASE.

*  LOOP AT ist_zmm_vend_unblock INTO wa_zmm_vend_unblock.
*    SELECT SINGLE * FROM lfa1 WHERE lifnr = wa_zmm_vend_unblock-lifnr.
*    wa_zmm_vend_unblock-zpstlz = lfa1-pstlz.                "05032012
*    MOVE-CORRESPONDING wa_zmm_vend_unblock TO ist_unbl.
*    IF zmm_vend_unblock-sperq IS INITIAL.
*      zmm_vend_unblock-sperq = wa_zmm_vend_unblock-sperq.
*    ENDIF.
*
**-SP006
**    IF sy-subrc = 0.
**      ist_unbl-sperm = ist_lfa1-sperm.
**      ist_unbl-sperr = ist_lfa1-sperr.
**    ENDIF.
**-SP006
*
*    APPEND ist_unbl.
*    CLEAR ist_unbl.
*  ENDLOOP.

  IF zmm_vend_unblock-reqno IS NOT INITIAL.

    l_vend_unblock_reqno_old = zmm_vend_unblock-reqno.

  ENDIF.

ENDMODULE.                 " fetch_data_unbl  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0420  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0420 INPUT.
  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'DELE'.
*{+rk004
      IF g_trans_mode = 'N' OR g_trans_mode = 'M'.
        DELETE ist_unbl WHERE del_flag = 'X'.
        CLEAR save_ok.
        LOOP AT ist_unbl.
          ist_unbl-seqno = sy-tabix.
          MODIFY ist_unbl TRANSPORTING seqno.
        ENDLOOP.
      ELSE.
        IF NOT ist_unbl[] IS INITIAL AND
           g_cursorfield IS INITIAL.
          GET CURSOR FIELD g_cursorfield LINE g_cursorline.
        ENDIF.

*        perform chk_unbl_del_flg using save_ok.             "+SP005

      ENDIF.
*}rk004
*{-rk004
*      DELETE ist_unbl WHERE mark = 'X'.
*      CLEAR save_ok.
*      LOOP AT ist_unbl.
*        ist_unbl-seqno = sy-tabix.
*        MODIFY ist_unbl TRANSPORTING seqno.
*      ENDLOOP.
*}-rk004
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0420  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_600  INPUT
*&---------------------------------------------------------------------*
*       Exit for screen 600
*----------------------------------------------------------------------*
MODULE exit_600 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " exit_600  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_500  INPUT
*&---------------------------------------------------------------------*
*       Exit for screen 500
*----------------------------------------------------------------------*
MODULE exit_500 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " exit_500  INPUT
*&---------------------------------------------------------------------*
*&      Module  bank_key  INPUT
*&---------------------------------------------------------------------*
*       f4 help for bank key
*----------------------------------------------------------------------*
MODULE bank_key INPUT.
  PERFORM okcode_bank_suchen(sapmf02k).
ENDMODULE.                 " bank_key  INPUT
*&---------------------------------------------------------------------*
*&      Module  update_bankey  INPUT
*&---------------------------------------------------------------------*
*       bank key
*----------------------------------------------------------------------*
MODULE update_bankey INPUT.
  IF NOT lfbk-bankl IS INITIAL.
    CALL FUNCTION 'READ_BANK_ADDRESS'
      EXPORTING
        bank_country = lfbk-banks
        bank_number  = lfbk-bankl
      IMPORTING
        bnka_wa      = bnka
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE e211(bf00) WITH lfbk-banks lfbk-bankl.
      ENDCASE.
    ENDIF.
  ENDIF.
  MOVE lfbk-bankl TO wa_vend-vend-bankl.
ENDMODULE.                 " update_bankey  INPUT
*&---------------------------------------------------------------------*
*&      Module  update_bank_country  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_bank_country INPUT.
  MOVE lfbk-banks TO wa_vend-vend-banks.
ENDMODULE.                 " update_bank_country  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_9000  INPUT
*&---------------------------------------------------------------------*
*       EXIT 9000
*----------------------------------------------------------------------*
MODULE exit_9000 INPUT.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                 " exit_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       9010 PAI
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.

*  CASE g_ok_code_9010.
  CASE save_ok.
    WHEN 'HEAD'.
      IF g_call_screen = '9020'.
        g_call_screen = '210'.
      ELSEIF g_call_screen = '210'.
        g_call_screen = '9020'.
      ENDIF.
  ENDCASE.
  CLEAR g_ok_code_9010.
ENDMODULE.                 " USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*&      Module  set_subscreen  INPUT
*&---------------------------------------------------------------------*
*       SET SUBSCREEN
*----------------------------------------------------------------------*
MODULE set_subscreen INPUT.
  g_call_screen = '210'.
ENDMODULE.                 " set_subscreen  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       GET CURSOR POSITION IN TABLECONTROL 220
*----------------------------------------------------------------------*
MODULE get_cursor INPUT.

  CASE sy-dynnr.
    WHEN '0220'.
      IF NOT wa_vend IS INITIAL.
        GET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
    WHEN '0420'.
      IF NOT ist_unbl[] IS INITIAL AND
         g_cursorfield IS INITIAL.
        GET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " get_cursor  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_ok_code  INPUT
*&---------------------------------------------------------------------*
*       GET OKCODE
*----------------------------------------------------------------------*
MODULE get_ok_code INPUT.

  save_ok = ok_code.
  CLEAR ok_code.

ENDMODULE.                 " get_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       VALIDATE TEL NUMBER
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_hvencrt-tel ).
  IF  zmm_hvencrt-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_tel  INPUT
*&---------------------------------------------------------------------*
*&      Module  ernam_fld_dclk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ernam_fld_dclk INPUT.
  DATA l_user LIKE soud3.
  CLEAR g_fname.

  GET CURSOR FIELD g_fname.
  CASE g_fname.
    WHEN 'ZMM_HVENCRT-ERNAM'.
      l_user = zmm_hvencrt-ernam.
    WHEN 'ZMM_HVENCRT-RELEASED_BY'.
      l_user = zmm_hvencrt-released_by.
    WHEN 'ZMM_HVENCRT-ASSIGNED_BY'.
      l_user =  zmm_hvencrt-assigned_by.
    WHEN 'ZMM_HVENEXT-ERNAM'.
      l_user = zmm_hvenext-ernam.
    WHEN 'ZMM_VEND_UNBLOCK-ERNAM'.
      l_user = zmm_vend_unblock-ernam.
    WHEN 'ZMM_VEND_UNBLOCK-ASSIGNED_BY'.
      l_user =  zmm_vend_unblock-assigned_by.
  ENDCASE.
  CALL FUNCTION 'SO_ADDRESS_SHOW'
    EXPORTING
*     DLI_OWNER                  = ' '
*     OWNER                      = ' '
      user                       = l_user
    EXCEPTIONS
      parameter_error            = 1
      user_not_exist             = 2
      x_error                    = 3
      operation_no_authorization = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " ernam_fld_dclk  INPUT
*&---------------------------------------------------------------------*
*&      Module  cap_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cap_code INPUT.

  DATA : l_csp_code LIKE zmm_cditem-cap_code.

  DATA  :  ist_return_tab1 LIKE STANDARD TABLE OF ddshretval
                                               WITH  HEADER LINE.

  TABLES : cabn, ausp.
  TYPES  : BEGIN OF mod_mara,
             matnr LIKE mara-matnr,
             mtart LIKE mara-mtart,
             maktx LIKE makt-maktx,
           END OF mod_mara.
  DATA   : ist_mod_mara TYPE TABLE OF mod_mara WITH HEADER LINE.
  DATA   : ist_mara LIKE TABLE OF mara WITH HEADER LINE.
  DATA   : wa_mara LIKE LINE OF ist_mara.
  DATA   : l_maktx LIKE makt-maktx.

  SELECT SINGLE * FROM cabn WHERE atnam = 'Z_ONGC_GROUP_OF_SPARES'.  "#EC CI_NOORDER

  SELECT a~matnr a~mtart c~maktx  INTO CORRESPONDING FIELDS OF TABLE
                      ist_mod_mara
                      FROM mara AS a  INNER JOIN ausp AS b
                      ON a~matnr = b~objek
                      INNER JOIN makt AS c
                      ON a~matnr = c~matnr
                      WHERE b~atinn = cabn-atinn AND
                      b~atwrt <> ''.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_CDITEM-CAP_CODE'
      value_org       = 'S'
    TABLES
      value_tab       = ist_mod_mara
      return_tab      = ist_return_tab1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  REFRESH:ist_mod_mara,ist_return_tab1.
  FREE : ist_mod_mara,ist_return_tab1.

ENDMODULE.                 " cap_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_bukrs  INPUT
*&---------------------------------------------------------------------*
*       VALIDATE COMPANY CODE IN UNBLOCK SCREEN 410
*----------------------------------------------------------------------*
MODULE validate_bukrs INPUT.
  PERFORM validate_bukrs USING zmm_vend_unblock-bukrs.
  PERFORM get_company_code USING zmm_vend_unblock-bukrs.

ENDMODULE.                 " validate_bukrs  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0931  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0931 INPUT.
  g_okcode931 = sy-ucomm.

  CASE g_okcode931.
    WHEN 'CREATE'.
*      CALL SCREEN 0319. "Commented by ss on 22/2/21


**      Begin of addition by ss

      IF cb_emd = 'X'.
        READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name =  'D:FI_VEM_MAINTAIN_EMD'.
        IF sy-subrc NE 0.
          MESSAGE 'You are not authorized to create EMD Bank Accounts' TYPE 'I'.
          LEAVE TO SCREEN sy-dynnr.
        ENDIF.
      ELSEIF cb_nor = 'X'.
        READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name =  'D:FI_VEM_BANKDETAILS_PREAUDIT'.
        IF sy-subrc NE 0.
          MESSAGE 'You are not authorized to Create Normal Bank Accounts' TYPE 'I'.
          LEAVE TO SCREEN sy-dynnr.
        ENDIF.


      ENDIF.

      IF cb_nor = 'X' AND cb_emd = 'X'.
        MESSAGE 'Kindly select only one type of account' TYPE 'I' DISPLAY LIKE 'E'.

      ELSEIF cb_nor = 'X'.

        CALL SCREEN 0319.
      ELSEIF cb_emd = abap_true.
        CALL SCREEN 0321.

      ENDIF.
    WHEN ' '.
      IF cb_nor = ' ' AND cb_emd = ' '.
        MESSAGE 'Kindly select only one type of account' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
**      End of addition by added by ss on 22/2/21
    WHEN 'CHANGE' OR 'DISPLAY' OR 'DELETE'.
      CLEAR zfivmsbank.
      IF cb_nor = 'X' AND cb_emd = 'X'.
        MESSAGE 'Kindly select only one type of account' TYPE 'I' DISPLAY LIKE 'E'.

      ELSEIF   cb_nor = 'X' AND cb_emd = ' '.
        CALL SCREEN 0281.
      ELSEIF   cb_nor = ' ' AND cb_emd = 'X'.
        CALL SCREEN 0281.

      ENDIF.




    WHEN 'RELEASE' OR 'APPROVED'.

      IF g_okcode931 = 'APPROVED'.
        IF cb_emd = 'X'.
          READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name =  'D:FI_VEM_BANKDETAILS_EMD'.
          IF sy-subrc NE 0.
            MESSAGE 'You are not authorized to approve EMD Bank Accounts' TYPE 'I'.
            LEAVE TO SCREEN sy-dynnr.
          ENDIF.
        ELSEIF cb_nor = 'X'.
          READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name =  'D:FI_FM_PR_RELEASE_C1'.
          IF sy-subrc NE 0.
            MESSAGE 'You are not authorized to approve Normal Bank Accounts' TYPE 'I'.
            LEAVE TO SCREEN sy-dynnr.
          ENDIF.
        ENDIF.
      ENDIF.

* Date 29072010 sudhir sharma comment should be removed
*      select single * from zauth_user into wa_zauth_user
*                                   where bname = g_cpf
*                                     and primary_module = 'FI'.
*      if sy-subrc <> 0.
*        message e105(zfi).
*      endif.
      CALL SCREEN 0109.

    WHEN 'REPORT'  .

      SUBMIT zfi_vms_report VIA SELECTION-SCREEN AND RETURN..


    WHEN 'BNK'  .
      SELECT *  FROM setleaf INTO TABLE @DATA(it_leaf) WHERE setname = 'ZFIVMC' AND valfrom = @sy-uname.  "#EC CI_NOORDER
      IF sy-subrc = 0..
        SUBMIT zstatus_programe VIA SELECTION-SCREEN AND RETURN..
      ELSE .
        MESSAGE 'You are not Authorized' TYPE 'I'DISPLAY LIKE 'I'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0931  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_931  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_931 INPUT.
  g_okcode931 = sy-ucomm.

  CASE g_okcode931.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 100.
  ENDCASE.

ENDMODULE.                 " EXIT_931  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0319  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0319 INPUT.
  DATA : l_docno      TYPE zfivmsbank-reqno,
         l_text(100),
         l_text1(100),
         l_text2(100),
         l_text3(100),
         l_answer,
         l_already,
         l_new,
         l_newentry,
         l_line       TYPE n,
         l_line1      TYPE n.

  g_okcode319 = sy-ucomm.

  CASE g_okcode319.
* Begin fo <> on 230911
    WHEN 'ATTACH'.
      READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY sel319 = 'X'."index tc319-current_line.
      IF sy-subrc = 0.
        IF g_tc319_wa-sel319 = 'X'.
          PERFORM attach_files.
        ENDIF.
      ENDIF.
    WHEN 'LIST'.
      READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY sel319 = 'X'. "index tc319-current_line.
      IF sy-subrc = 0.
        IF g_tc319_wa-sel319 = 'X'.
          PERFORM list_files.
        ENDIF.
      ENDIF.
* End of <> on 230911
    WHEN 'SAVE'.
      CASE  g_okcode931.

        WHEN 'CREATE' OR 'BACK' .
* Begin of <> on 271211
          PERFORM check_bankl_bankn.
* End of <> on 271211
          IF g_ans <> 'N'. "2.  25012012                              "281211
            IF g_okcode931 = 'BACK'.
              l_text =  'Do You Want to Save the Data'.
              PERFORM popup_message USING l_text.
            ENDIF.

            IF l_answer    = 'J' OR
               g_okcode931 = 'CREATE' .

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              READ TABLE g_tc319_itab INTO g_tc319_wa INDEX 1.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              DESCRIBE TABLE g_tc319_itab LINES l_line.
              IF l_line > 0 AND NOT g_tc319_wa-lifnr IS INITIAL.

                IF g_new = 'X'. "l_new = 'X'.
* Begin of <> on 20072011
*                perform check_attachment.   "22072011 RD1K977234
*                if g_attachment = 'X'.      "22072011
* End of <> on 20072011
                  CALL FUNCTION 'NUMBER_GET_NEXT'
                    EXPORTING
                      nr_range_nr             = g_nrrangenr
                      object                  = g_nrobj
                    IMPORTING
                      number                  = l_docno
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
                  DELETE ADJACENT DUPLICATES FROM g_tc319_itab COMPARING lifnr.  "#EC CI_NOORDER
                  LOOP AT g_tc319_itab INTO g_tc319_wa WHERE exist IS INITIAL.
*                  shift L_DOCNO left deleting leading '0'.  "160911 290911
                    g_tc319_wa-reqno = l_docno.
*                  G_TC319_WA-srno  = sy-tabix.
* Begin of <> on 06042011
                    IF NOT g_tc319_wa-status IS INITIAL.
                      CLEAR : g_tc319_wa-status,
                              g_tc319_wa-attach,
                              g_tc319_wa-zlist,
                              g_tc319_wa-hof_cpf_no,
                              g_tc319_wa-hof_name,
                              g_tc319_wa-hof_rldate,
                              g_tc319_wa-hof_zremarks,
                              g_tc319_wa-vmc_cpf_no,
                              g_tc319_wa-vmc_name,
                              g_tc319_wa-vmc_apdate,
                              g_tc319_wa-vmc_zremarks,
                              g_tc319_wa-cvp_cpf_no,
                              g_tc319_wa-cvp_name,
                              g_tc319_wa-cvp_assdate,
                              g_tc319_wa-registration,
                              g_tc319_wa-deregistration,
                              g_tc319_wa-sel319,
                              g_tc319_wa-exist.
                    ENDIF.
* End of <> on 06042011
                    MOVE-CORRESPONDING g_tc319_wa TO zfivmsbank.
                    CLEAR : zfivmsbank-attach.              "160911 SS
                    zfivmsbank-status   = 'NEW'.
                    zfivmsbank-username = g_username. "SY-UNAME.
                    zfivmsbank-cdate    = sy-datum.
                    zfivmsbank-cputm    = sy-uzeit.
                    zfivmsbank-cpf      = g_cpf .
                    zfivmsbank-ccode    = g_ccode .
                    MODIFY zfivmsbank.
                  ENDLOOP.
                  IF sy-subrc = 0.
                    MESSAGE i302(zfi) WITH zfivmsbank-reqno.
                    REFRESH g_tc319_itab.
                    CLEAR : g_new, g_tc319_copied.
                    CALL SCREEN 931.
                  ENDIF.
* Begin of <> 20072011
*                else.                "RD1K977234  22072011
*                  message i380(zfi). "RD1K977234
*                endif.               "RD1K977234
* End of 20072011

                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        WHEN 'CHANGE'.
* Begin of <> on 271211
          PERFORM check_bankl_bankn.
* End of <> on 271211
          IF g_ans <> 'N'.       "2                             "281211
            IF g_okcode931 = 'BACK'.
              l_text =  'Do You Want to Save the Data'.
              PERFORM popup_message USING l_text.
            ENDIF.

            IF l_answer    = 'J' OR
               g_okcode931 = 'CHANGE' .

              DESCRIBE TABLE g_tc319_itab LINES l_line.
              IF l_line > 0.
                PERFORM check_attach_files.
                l_docno = zfivmsbank-reqno.
                DELETE FROM zfivmsbank WHERE reqno = zfivmsbank-reqno.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                SORT g_tc319_itab BY lifnr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                DELETE ADJACENT DUPLICATES FROM g_tc319_itab COMPARING lifnr.
* Check attachments in change mode
* Begin of <> on 160911
*              loop at G_TC319_ITAB into G_TC319_WA.
*                if not G_TC319_WA-bankl     is initial and
*                   not G_TC319_WA-bankn     is initial and
*                   not G_TC319_WA-koinh     is initial and
*                   not G_TC319_WA-bankl_new is initial and
*                   not G_TC319_WA-bankn_new is initial and
*                   not G_TC319_WA-koinh_new is initial.
*                  if G_TC319_WA-attach  is initial.
*                    message e418(zfi) with G_TC319_WA-lifnr.
*                  endif.
*                endif.
*              endloop.
* End of <> on 160911
                LOOP AT g_tc319_itab INTO g_tc319_wa WHERE exist IS INITIAL.
                  g_tc319_wa-reqno = l_docno.
*                  G_TC319_WA-srno  = sy-tabix.
                  MOVE-CORRESPONDING g_tc319_wa TO zfivmsbank.
*                if G_TC319_WA-status = 'REJECTED BY HOF'.
                  zfivmsbank-status = 'NEW'.
*                else.   "if G_TC319_WA-status = 'APPROVED BY HOF'.
*                  zfivmsbank-status = ''.
*                endif.
                  zfivmsbank-username = sy-uname.
                  zfivmsbank-cdate    = sy-datum.
                  zfivmsbank-cputm    = sy-uzeit.
                  zfivmsbank-cpf      = g_cpf .
                  zfivmsbank-ccode    = g_ccode .
                  MODIFY zfivmsbank.
                ENDLOOP.
                IF sy-subrc = 0.
                  MESSAGE i303(zfi) .
                  REFRESH g_tc319_itab.
                  CLEAR : g_tc319_copied.                   "270911
                  CALL SCREEN 931.
                ELSE.
                  MESSAGE e376(zfi).
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

*             Loop at G_TC319_ITAB into G_TC319_WA.
*                G_TC319_WA-reqno = L_DOCNO.
**                G_TC319_WA-srno  = sy-tabix.
*                MOVE-CORRESPONDING G_TC319_WA TO ZFIVMSBANK.
*                select single *  from lfa1 into wa_lfa1 where lifnr = zfivmsbank-lifnr
*                       and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK').
*                if sy-subrc = 0.
*                  select single * from bnka into wa_bnka where bankl = g_tc319_wa-bankl_new.
**                  zfivmsbank-bankl.
*                  if sy-subrc = 0.
*                    ZFIVMSBANK-USERNAME = SY-UNAME.
*                    ZFIVMSBANK-CDATE    = SY-DATUM.
*                    ZFIVMSBANK-CPUTM    = SY-uzeit.
*                    ZFIVMSBANK-srno     = sy-tabix .
*                    ZFIVMSBANK-ccode    = g_ccode .
*                    zfivmsbank-status   = 'NEW'.
*                    l_new = 'X'.
*                  else.
*                    message e305(zfi) with zfivmsbank-bankl.
*                  endif.
*                else.
*                  message e305(zfi) with zfivmsbank-lifnr.
*                endif.
*                MODIFY ZFIVMSBANK.
*                if SY-SUBRC <> 0.
*                  message e376(zfi).
*                endif.
*              endloop.
*              if sy-subrc = 0.
*                message i303(zfi).
*                call screen 931.
*              endif.
*            else.
*
*              DESCRIBE TABLE G_TC319_ITAB_temp LINES L_LINE.
*              IF L_LINE > 0.
*                delete from zfivmsbank where reqno = g_zvms_reqno.
*                MESSAGE i067(zfi).
*              ENDIF.
*            ENDIF.
*
*          endif.

        WHEN 'DELETE'.

          l_text =  'Do You Want to Delete the Data'.

          PERFORM popup_message USING l_text.
          IF l_answer = 'J'.
            DELETE FROM zfivmsbank WHERE reqno = zfivmsbank-reqno.
            MESSAGE i067(zfi).
          ENDIF.

      ENDCASE.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      REFRESH CONTROL 'TC319' FROM SCREEN '0319'.
      REFRESH : g_tc319_itab.
      CLEAR g_tc319_copied.
      CALL SCREEN 931.


*when 'create'.
* To Prevent number generation 09062010
*              loop at G_TC319_ITAB into G_TC319_WA.
*                if l_line = 1.
*                  MOVE-CORRESPONDING G_TC319_WA TO ZFIVMSBANK.
*                  select single * from zfivmsbank into wa_zfivmsbank where lifnr = zfivmsbank-lifnr
*                                                                       and ( status = 'REJECTED BY HOF'
*                                                                        or   status = ' ').
*
*                  select single * from zfivmsbank into wa_zfivmsbank where lifnr = zfivmsbank-lifnr
*                  and bankl = zfivmsbank-bankl_new
*                  and bankn = zfivmsbank-bankn_new
*                  and koinh = zfivmsbank-koinh_new.
*                  if sy-subrc <> 0.
*                    select single * from lfbk into wa_lfbk
*                    where lifnr = zfivmsbank-lifnr
*                      and bankl = zfivmsbank-bankl_new
*                      and bankn = zfivmsbank-bankn_new
*                      and koinh = zfivmsbank-koinh_new.
*                    if sy-subrc <> 0.
*                      select single * from bnka into wa_bnka where bankl = zfivmsbank-bankl_new.
*                      if sy-subrc = 0.
*                        ZFIVMSBANK-USERNAME = SY-UNAME.
*                        ZFIVMSBANK-CDATE    = SY-DATUM.
*                        ZFIVMSBANK-CPUTM    = SY-uzeit.
*                        l_new = 'X'.
*                        l_text = 'Changes affect payments from other locations. Do u wish to continue?'.
*                        PERFORM POPUP_MESSAGE USING L_TEXT.
*                        if l_answer = 'J'.
*                          if zfivmsbank-attach is initial.
*                            if g_attachment <> 'X'.
*                              if not zfivmsbank-bankl is initial or
*                                 not zfivmsbank-bankn is initial or
*                                 not zfivmsbank-koinh is initial.
*
*                                message e380(zfi) with ZFIVMSBANK-LIFNR.
*                                g_attachment = 'X'.
*                              else.
*                                message i380(zfi) with zfivmsbank-bankl.
*                                l_new = 'X'.
*                              endif.
*                            endif.
*                          else.
*                            l_new = 'X'.
*                          endif.
*
*                        endif.
*                      else.
*                        message e305(zfi) with zfivmsbank-lifnr.
*                      endif.
*                    else.
*                      message i402(zfi) with zfivmsbank-lifnr.
*                    endif.
*                  endif.
*
*                else.
**                G_TC319_WA-reqno = L_DOCNO.
*                  MOVE-CORRESPONDING G_TC319_WA TO ZFIVMSBANK.
*                  select single * from zfivmsbank into wa_zfivmsbank where lifnr = zfivmsbank-lifnr
*                                                                       and ( status = 'REJECTED BY HOF'
*                                                                        or   status = ' ').
** Begin of  < > on 10092010
**                if sy-subrc <> 0.
**                  delete g_tc319_itab where lifnr = zfivmsbank-lifnr.
**                endif.
** End of <> on 10092010
*                  select single * from zfivmsbank into wa_zfivmsbank where lifnr = zfivmsbank-lifnr
*                  and bankl = zfivmsbank-bankl_new
*                  and bankn = zfivmsbank-bankn_new
*                  and koinh = zfivmsbank-koinh_new.
*                  if sy-subrc <> 0.
*                    select single * from lfbk into wa_lfbk
*                    where lifnr = zfivmsbank-lifnr
*                      and bankl = zfivmsbank-bankl_new
*                      and bankn = zfivmsbank-bankn_new
*                      and koinh = zfivmsbank-koinh_new.
*                    if sy-subrc <> 0.
*                      select single * from bnka into wa_bnka where bankl = zfivmsbank-bankl_new.
*                      if sy-subrc = 0.
*                        ZFIVMSBANK-USERNAME = SY-UNAME.
*                        ZFIVMSBANK-CDATE    = SY-DATUM.
*                        ZFIVMSBANK-CPUTM    = SY-uzeit.
*                        l_new = 'X'.
**                       l_text = 'Changes affect payments from other locations. Do u wish to continue?'.
**                       PERFORM POPUP_MESSAGE USING L_TEXT.
**                       if l_answer = 'J'.
**                        if zfivmsbank-attach is initial.
**                          if g_attachment <> 'X'.
**                            if not zfivmsbank-bankl is initial or
**                               not zfivmsbank-bankn is initial or
**                               not zfivmsbank-koinh is initial.
**
**                               message e380(zfi) with ZFIVMSBANK-LIFNR. "zfivmsbank-bankl.
**                               g_attachment = 'X'.
**                            else.
**                               message i380(zfi) with zfivmsbank-bankl.
**                               l_new = 'X'.
**                            endif.
**                          endif.
**                        else.
**                          l_new = 'X'.
**                        endif.
**
**                      endif.
*                      else.
*                        message e305(zfi) with zfivmsbank-lifnr.
*                      endif.
*                    else.
*                      message i402(zfi) with zfivmsbank-lifnr.
*                    endif.
*                  else.
**                  message i402(zfi) with zfivmsbank-lifnr.  347 "Put the table name
*                  endif.
*                endif.
*              endloop.
*                  l_newentry = 'X'.
*                  clear : g_create , g_new.
*                  if SY-SUBRC <> 0.
*                     message e376(zfi).
*                   endif.
*                  else.
*                    l_already = 'X'.
*                    message i345(zfi).
*                  endif.
*                endloop.
*                if l_newentry = 'X'.
*                  message i302(zfi) with zfivmsbank-reqno.
*                  REFRESH G_TC319_ITAB.
*                  call screen 931.
*                endif.
*              endif..
*            endif.
*          endif.
* End
*    when 'ATTACH'.
*      perform attach_files.
*
*    when 'LIST'.
*      perform list_files.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0319  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC319'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc319_modify INPUT.
  g_okcode319 = sy-ucomm.

  CASE g_okcode931.

    WHEN  'CREATE' OR 'CHANGE'.

      IF NOT zfivmsbank-lifnr IS INITIAL.

        IF NOT zfivmsbank-bankl_new IS INITIAL.
          IF g_ccode EQ 'OVL'.  " adde by ss

            SELECT SINGLE * FROM bnka
                    INTO wa_bnka WHERE  banks = 'IN'
                                   AND bankl = zfivmsbank-bankl_new.
**   BOC by ss
          ELSEIF g_ccode EQ 'OVC'.
            SELECT SINGLE * FROM bnka
                    INTO wa_bnka WHERE banks = 'CO'
                                   AND bankl = zfivmsbank-bankl_new.
          ENDIF.
**          EOC by ss



          IF sy-subrc = 0.
            IF wa_bnka-loevm = 'X'.
              MESSAGE e350(zfi) WITH zfivmsbank-bankl_new.
            ELSE.
              PERFORM check_bank_key_entry.
              g_new = 'X'.
            ENDIF.
          ELSE.
            MESSAGE e356(zfi) WITH zfivmsbank-bankl_new.
          ENDIF.
        ENDIF.
      ENDIF.


*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

*        select single *  from lfa1 into wa_lfa1 where lifnr = zfivmsbank-lifnr
*        and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK').
*        if sy-subrc = 0.
*          select * from zfivmsbank into table ist_zfivmsbank where lifnr = zfivmsbank-lifnr.
*          if sy-subrc = 0.
*            sort ist_zfivmsbank descending by cdate cputm.
*            read table ist_zfivmsbank into wa_zfivmsbank index 1.
*            move-corresponding wa_zfivmsbank to zfivmsbank.
*          endif.
*          if zfivmsbank-status <> 'REJECTED BY HOF'.
**          select single * from zfivmsbank into wa_zfivmsbank where lifnr = zfivmsbank-lifnr
**          and status <> 'REJECTED BY HOF'.
***          and status <> 'COMPLETE'.
**          if sy-subrc <> 0.
*            if not G_TC319_WA-BANKL is initial.
*              if G_TC319_WA-BANKL <> zfivmsbank-bankl or
*                 G_TC319_WA-BANKN <> zfivmsbank-bankn or
*                 G_TC319_WA-KOINH <> zfivmsbank-koinh.
*                select single * from icon into wa_icon where name = 'ICON_IMPORT'.
*                g_attachment = 'X'.
**                zfivmsbank-attach = 'X'. "wa_icon-id. "'ATTACHMENT'.
*              endif.
*
*            else.
*              select single * from lfbk into wa_lfbk where lifnr = zfivmsbank-lifnr.
*              if sy-subrc = 0.
*                zfivmsbank-lifnr = wa_lfbk-lifnr.
*                zfivmsbank-name1 = wa_lfa1-name1.
*                zfivmsbank-bankl = wa_lfbk-bankl.
*                zfivmsbank-bankn = wa_lfbk-bankn.
*                zfivmsbank-koinh = wa_lfbk-koinh.
*              else.
*                zfivmsbank-lifnr = wa_lfa1-lifnr.
*                zfivmsbank-name1 = wa_lfa1-name1.
*              endif.
*            endif.
*          else.
*            move-corresponding wa_zfivmsbank to zfivmsbank.
*            l_exist = 'X'.
*            message s347(zfi) with zfivmsbank-lifnr.
*          endif.
*        else.
*          message e217(zfi) with zfivmsbank-lifnr.
**              message e305(zfi) with zfivmsbank-lifnr.
*        endif.
*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*        endif.                                              "04092010 "07092010
*        select * from zfivmsbank into table ist_zfivmsbank where lifnr = zfivmsbank-lifnr.
*        if sy-subrc = 0.
*          sort ist_zfivmsbank descending by cdate cputm.
*          read table ist_zfivmsbank into wa_zfivmsbank index 1.
*          move-corresponding wa_zfivmsbank to zfivmsbank.
*        else.
*          select single *  from lfa1 into wa_lfa1 where lifnr = zfivmsbank-lifnr
*          and ktokk in ('SVWI','SVWF','IMMI','IMMF','BANK').
*          if sy-subrc <> 0.
*            message e305(zfi) with zfivmsbank-lifnr.
*          else.
*            select single * from lfbk into wa_lfbk where lifnr = zfivmsbank-lifnr.
*            if sy-subrc = 0.
*              zfivmsbank-lifnr = wa_lfbk-lifnr.
*              zfivmsbank-bankl = wa_lfbk-bankl.
*              zfivmsbank-bankn = wa_lfbk-bankn.
*              zfivmsbank-koinh = wa_lfbk-koinh.
*            else.
*              if not zfivmsbank-bankl is initial
*              or not zfivmsbank-bankn is initial
*              or not zfivmsbank-koinh is initial.
*                select single * from lfbk into wa_lfbk where lifnr = zfivmsbank-lifnr
*                                                         and bankl = zfivmsbank-bankl.
*                if sy-subrc <> 0.
*                  select single * from bnka into wa_bnka where bankl = zfivmsbank-bankl.
*                  if sy-subrc <> 0.
*                    clear : g_create.
*                    message e305(zfi) with zfivmsbank-bankl.
*                    clear : zfivmsbank-bankl,
*                            zfivmsbank-bankn,
*                            zfivmsbank-koinh.
*                  else.
*                    read table G_TC319_ITAB into G_TC319_wa with key lifnr = ZFIVMSBANK-LIFNR.
*                    if sy-subrc <> 0.
*                      clear : zfivmsbank-bankl,
*                              zfivmsbank-bankn,
*                              zfivmsbank-koinh.
*                    endif.
*
*                  endif.
*                endif.
*              else.
*                clear : zfivmsbank-bankl,
*                        zfivmsbank-bankn,
*                        zfivmsbank-koinh.
*              endif.
*            endif.
*          endif.
*        endif.
* End of <> on 22062010
      IF NOT zfivmsbank-bankl IS INITIAL.
        SELECT SINGLE * FROM bnka
        INTO wa_bnka WHERE banks = 'IN' AND bankl = zfivmsbank-bankl.
        IF sy-subrc <> 0.
          MESSAGE e305(zfi) WITH zfivmsbank-bankl.
        ENDIF.
      ENDIF.

      IF g_okcode931 = 'CHANGE' .
* Begin of <> on 280911
        zfivmsbank-reqno = g_tc319_wa-reqno.
        IF NOT g_tc319_wa-bankl_new IS INITIAL AND
           NOT g_tc319_wa-bankn_new IS INITIAL AND
           NOT g_tc319_wa-koinh_new IS INITIAL.
          IF ( zfivmsbank-bankl_new  <> g_tc319_wa-bankl_new ) OR
             ( zfivmsbank-bankn_new  <> g_tc319_wa-bankn_new ) OR
             ( zfivmsbank-koinh_new  <> g_tc319_wa-koinh_new ) .
            IF g_tc319_wa-attach = 'X'.
              MOVE-CORRESPONDING zfivmsbank TO g_tc319_wa.
              g_tc319_wa-attach = 'X'.
            ENDIF.
          ENDIF.
******************************************
*        read table g_tc319_itab into g_tc319_wa index 1.
*        if sy-subrc = 0.
*          zfivmsbank-reqno = g_tc319_wa-reqno.
*        endif.
*      endif.
        ELSE.
          CLEAR : g_tc319_wa.
          MOVE-CORRESPONDING zfivmsbank TO g_tc319_wa.
        ENDIF.
      ENDIF.
      IF g_okcode931 = 'CREATE' .
        CLEAR : g_tc319_wa.
        MOVE-CORRESPONDING zfivmsbank TO g_tc319_wa.
      ENDIF.
* End of <> on 280911
  ENDCASE.



*  if zfivmsbank-bankl_new is initial.
*    case g_okcode319.
*      when 'ENTER'.
*        DESCRIBE TABLE G_TC319_ITAB LINES L_LINE.
*
*        if l_line > 1 and g_exist is initial.
*          read table g_tc319_itab into g_tc319_wa_temp with key lifnr = zfivmsbank-lifnr.
*          if sy-subrc = 0.
*            g_lifnr1 = zfivmsbank-lifnr.
*            g_exist  = 'X'.
*            message e366(zfi) with zfivmsbank-lifnr.
*          endif.
*        endif.
*    endcase.
*  endif.

  IF g_exist_ztable = 'X'.
    g_tc319_wa-exist = 'X'.
  ENDIF.
  g_tc319_wa-srno = tc319-current_line.                     "150911
  MODIFY g_tc319_itab
  FROM g_tc319_wa
  INDEX tc319-current_line.

  CLEAR g_exist_ztable.
ENDMODULE.                    "TC319_MODIFY INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC319'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc319_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC319'
                              'G_TC319_ITAB'
                              'SEL319'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC319_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_BANKL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lov_bankl INPUT.

  DATA : ist_return_tab_doc  LIKE STANDARD TABLE OF ddshretval
                                          WITH  HEADER LINE.
  DATA : ist_field_tab_doc LIKE STANDARD TABLE OF dfies
                                         WITH  HEADER LINE.
  DATA : ist_dynpfld_mapping_doc LIKE STANDARD TABLE OF dselc
                                         WITH  HEADER LINE.
*
*  CLEAR ZFIVMSBANK-BANKL.
*  REFRESH : IST_OBJECT_F4_DOC_G ,IST_RETURN_TAB_DOC.
*
*  SELECT BANKL BANKA FROM BNKA
*         INTO CORRESPONDING FIELDS OF TABLE IST_OBJECT_F4_DOC_G
*         WHERE BANKS = 'IN'.
*  SORT IST_OBJECT_F4_DOC_G BY BANKL BANKA.
*
*  DELETE ADJACENT DUPLICATES FROM IST_OBJECT_F4_DOC_G.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'BANKL'
*      DYNPPROG        = 'SAPMZMMVENDOR'  "SY-CPROG
*      DYNPNR          = '319'            "SY-DYNNR
*      DYNPROFIELD     = 'ZFIVMSBANK-BANKL'
*      VALUE_ORG       = 'S'
*    TABLES
*      VALUE_TAB       = IST_OBJECT_F4_DOC_G
*      RETURN_TAB      = IST_RETURN_TAB_DOC
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  ZFIVMSBANK-BANKL =  IST_RETURN_TAB_DOC-FIELDVAL.


  DATA: prog LIKE sy-repid,
        dynm LIKE sy-dynnr.
  DATA: loc_dynpread  LIKE dynpread   OCCURS 0 WITH HEADER LINE.

  MOVE sy-repid TO prog.
  MOVE sy-dynnr TO dynm.
  loc_dynpread-fieldname = 'BNKA-BANKS'.
  APPEND loc_dynpread.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = prog
      dynumb             = dynm
      translate_to_upper = 'X'
    TABLES
      dynpfields         = loc_dynpread
    EXCEPTIONS
      OTHERS             = 4.

  IF sy-subrc = 0.
    READ TABLE loc_dynpread WITH KEY fieldname = 'BNKA-BANKS'.
    bnka-banks = loc_dynpread-fieldvalue.
  ENDIF.

  CALL FUNCTION 'SEARCH_BANK_ADDRESS'
    EXPORTING
      i_banks = bnka-banks
    IMPORTING
      e_bnka  = bnka.

  zfivmsbank-bankl = bnka+6(12).

*  IF bnka IS INITIAL.
*    SET SCREEN sy-dynnr.
*    LEAVE SCREEN.
*  ELSE.
*    bnka = bnka.
*  ENDIF.
ENDMODULE.                 " LOV_BANKL  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0281  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0281 INPUT.
  g_okcode281 = sy-ucomm.

  CASE g_okcode281.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 931.
  ENDCASE.

ENDMODULE.                 " EXIT_0281  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0281  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0281 INPUT.
  g_okcode281 = sy-ucomm.

  CASE g_okcode281.

    WHEN 'ENTER' .
      IF cb_nor = 'X' AND cb_emd = ' '.
        CALL SCREEN 319.
      ELSEIF cb_nor = ' ' AND cb_emd = 'X'.
        CALL SCREEN 321.
*    ELSEIF  cb_nor = 'X' and cb_emd = 'X'.
*      MESSAGE 'Kindly select any one' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0281  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_REQNO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lov_reqno INPUT.

  DATA : BEGIN OF wa_object_doc_req,
           reqno    LIKE zfivmsbank-reqno,
           ccode    LIKE zfivmsbank-ccode,
           username LIKE zfivmsbank-ccode,
           cpf      LIKE zfivmsbank-cpf,
           cdate    LIKE zfivmsbank-cdate,
           status   LIKE zfivmsbank-status,
         END OF wa_object_doc_req.

  DATA   : ist_object_f4_doc_req LIKE STANDARD TABLE OF wa_object_doc_req
           INITIAL SIZE 100.

  CLEAR zfivmsbank-reqno.
  REFRESH : ist_object_f4_doc_req,ist_return_tab_doc.

  SELECT reqno ccode username cpf cdate status FROM zfivmsbank
         INTO CORRESPONDING FIELDS OF TABLE ist_object_f4_doc_req.

  SORT ist_object_f4_doc_req BY reqno .

  DELETE ADJACENT DUPLICATES FROM ist_object_f4_doc_req.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'REQNO'
      dynpprog        = 'SAPMZMMVENDOR'  "SY-CPROG
      dynpnr          = '319'            "SY-DYNNR
      dynprofield     = 'ZFIVMSBANK-REQNO'
      value_org       = 'S'
    TABLES
      value_tab       = ist_object_f4_doc_req
      return_tab      = ist_return_tab_doc
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  zfivmsbank-reqno =  ist_return_tab_doc-fieldval.
ENDMODULE.                 " LOV_REQNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_LIFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lov_lifnr INPUT.
*  DATA : IST_RETURN_TAB_DOC  LIKE STANDARD TABLE OF DDSHRETVAL
*                                          WITH  HEADER LINE.
*  DATA : IST_FIELD_TAB_DOC LIKE STANDARD TABLE OF DFIES
*                                         WITH  HEADER LINE.
*  DATA : IST_DYNPFLD_MAPPING_DOC LIKE STANDARD TABLE OF DSELC
*                                         WITH  HEADER LINE.
*  DATA : BEGIN OF WA_OBJECT_DOC_L,
*           LIFNR LIKE LFBK-LIFNR,
*           BANKL LIKE ZMM_VMS_IFSC-BANKL,
*           BANKA LIKE BNKA-BANKA,
*           KOINH LIKE LFBK-KOINH,
*         END OF WA_OBJECT_DOC_L.
*
*  DATA   : IST_OBJECT_F4_DOC_L LIKE STANDARD TABLE OF WA_OBJECT_DOC_L
*           INITIAL SIZE 100.
*
*  CLEAR ZFIVMSBANK-BANKL.
*  REFRESH : IST_OBJECT_F4_DOC_L ,IST_RETURN_TAB_DOC.
*
*  SELECT a~LIFNR b~BANKL b~BANKN b~KOINH
*         FROM lfa1 as a inner join LFBK as b
*         on b~banks = a~land1 and a~lifnr = b~lifnr
*         INTO CORRESPONDING FIELDS OF TABLE IST_OBJECT_F4_DOC_L
*         WHERE BANKS = 'IN'.
*  SORT IST_OBJECT_F4_DOC_L BY LIFNR BANKL BANKA KOINH .
*
*  DELETE ADJACENT DUPLICATES FROM IST_OBJECT_F4_DOC_G.
*
*  REFRESH : IST_DYNPFLD_MAPPING_DOC , IST_RETURN_TAB_DOC,
*            IST_FIELD_TAB_DOC.
*
*  IST_DYNPFLD_MAPPING_DOC-FLDNAME   = 'F0001'.
*  IST_DYNPFLD_MAPPING_DOC-DYFLDNAME = 'ZFIVMSBANK-LIFNR'.
*  APPEND IST_DYNPFLD_MAPPING_DOC.
*
*  IST_DYNPFLD_MAPPING_DOC-FLDNAME   = 'F0002'.
*  IST_DYNPFLD_MAPPING_DOC-DYFLDNAME = 'ZFIVMSBANK-BANKL'.
*  APPEND IST_DYNPFLD_MAPPING_DOC.
*
*  IST_DYNPFLD_MAPPING_DOC-FLDNAME   = 'F0003'.
*  IST_DYNPFLD_MAPPING_DOC-DYFLDNAME = 'ZFIVMSBANK-BANKN'.
*  APPEND IST_DYNPFLD_MAPPING_DOC.
*
*  IST_DYNPFLD_MAPPING_DOC-FLDNAME   = 'F0004'.
*  IST_DYNPFLD_MAPPING_DOC-DYFLDNAME = 'ZFIVMSBANK-KOINH'.
*  APPEND IST_DYNPFLD_MAPPING_DOC.
*
*  SORT IST_DYNPFLD_MAPPING_DOC BY FLDNAME.
*  CLEAR : IST_DYNPFLD_MAPPING_DOC , IST_RETURN_TAB_DOC.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD        = 'LIFNR'
*      DYNPPROG        = 'SAPMZMMVENDOR'
*      DYNPNR          = '319'
*      DYNPROFIELD     = 'ZFIVMSBANK-LIFNR'
*      VALUE_ORG       = 'S'
*    TABLES
*      VALUE_TAB       = IST_OBJECT_F4_DOC_L
*      FIELD_TAB       = IST_FIELD_TAB_DOC
*      RETURN_TAB      = IST_RETURN_TAB_DOC
*      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING_DOC
*    EXCEPTIONS
*      PARAMETER_ERROR = 1
*      NO_VALUES_FOUND = 2
*      OTHERS          = 3.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  READ TABLE IST_RETURN_TAB_DOC WITH KEY FIELDNAME = 'F0001'.
*  ZFIVMSBANK-LIFNR =  IST_RETURN_TAB_DOC-FIELDVAL.
ENDMODULE.                 " LOV_LIFNR  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC109'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc109_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC109'
                              'G_TC109_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC109_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0109  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0109 INPUT.
  g_okcode109 = sy-ucomm.
  CASE g_okcode109.
    WHEN 'ENTER'.
      READ TABLE g_tc109_itab INTO g_tc109_wa WITH KEY sel109 = 'X'.
      IF sy-subrc = 0.
        g_reqno = g_tc109_wa-reqno.                         "270911
        CALL SCREEN 531.
      ELSE.
        MESSAGE e018(zfi).
      ENDIF.

      "added by Anamika  on 27.01.2015  RD1K995997



    WHEN 'VASC'. "Vendor Ascending
      SORT g_tc109_itab BY reqno ASCENDING.

    WHEN 'VDES'. "Vendor Descending
      SORT g_tc109_itab BY reqno DESCENDING .


      "end of addition by Anamika on 27.01.2015  RD1K995997




    WHEN 'BACK'.
      CLEAR :  g_okcode931 , g_tc109_copied.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0109  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0531  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0531 INPUT.
  DATA : valid_characters_as TYPE string,
         valid_input_as      TYPE string,
* Begin of <> on 19062012
         l_lifnr             TYPE lfa1-lifnr,               "20062012
         l_lfbk_flag,
         l_zfivms_flag.
* End of <> on 19062012
  g_okcode531 = sy-ucomm.
  CLEAR : l_f_bdc.
  CASE g_okcode531.
    WHEN 'SAVE'.
*   if g_okcode931 = 'BACK'.
*            l_text =  'Do You Want to Save the Data'.
*            PERFORM POPUP_MESSAGE USING L_TEXT.
*          endif.
*
*          if L_ANSWER    = 'J' or
*             g_okcode931 = 'CHANGE' .

      DESCRIBE TABLE g_tc531_itab LINES l_line.
      DESCRIBE TABLE g_tc531_itab_temp LINES l_line1.

      CASE g_okcode931.
        WHEN 'APPROVED' . "'RELEASE'.  270911
          IF l_line > 0.
            PERFORM check_attach_files_531.                 "270911
* Begin of <RD1K979928> on 02042012
*            DELETE FROM ZFIVMSBANK WHERE REQNO = ZFIVMSBANK-REQNO.
* End of <RD1K979928> on 02042012
            LOOP AT g_tc531_itab INTO g_tc531_wa.
* Begin of <> on 17042012
              CLEAR : l_text, l_text1, l_text2, l_text3, l_line, wa_zfivmsbank_bankl-zflag.

              SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
              WHERE bankl = g_tc531_wa-bankl_new AND bankn = g_tc531_wa-bankn_new.
              IF sy-subrc = 0.

                SORT ist_zfivmsbank_bankl DESCENDING BY bankl bankn.
                READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
                SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
                l_lifnr = g_tc531_wa-lifnr.
                SHIFT l_lifnr LEFT DELETING LEADING '0'.
                wa_zfivmsbank_bankl-zflag = 'X'.
                MODIFY g_tc531_itab FROM g_tc531_wa.
* Begin of <> on 20062012
                CONCATENATE 'Combination of Bank Account & IFSC Code requested for Vendor:-' l_lifnr  INTO l_text1.
                CONCATENATE 'Already exists in Vendor Master :-' wa_zfivmsbank_bankl-lifnr INTO l_text2.
                CONCATENATE 'Do You Want to' ' Approve the New Request?' INTO l_text3.
*                PERFORM POPUP_INFO USING L_TEXT l_text1 l_text2 l_text3.  "20062012

*                concatenate 'Vendor code-' wa_zfivmsbank_bankl-lifnr ' already updated with same combination of '  g_tc531_wa-bankl_new ' & ' into l_text.
*                concatenate '&' g_tc531_wa-bankn_new ' in the Vendor Master'  into l_text1.
*                concatenate 'Do You Want to' ' Continue ?' into l_text2.
*                PERFORM POPUP_INFO USING L_TEXT l_text1 l_text2.
* End of <> on 20062012
              ELSE..
* End of <> on 17042012
* Begin of <> on 04042012

                SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
                WHERE bankl_new = g_tc531_wa-bankl_new AND bankn_new = g_tc531_wa-bankn_new AND reqno <> zfivmsbank-reqno.

                IF sy-subrc = 0.

                  SORT ist_zfivmsbank_bankl DESCENDING BY vmc_apdate vmc_aptime.
                  DESCRIBE TABLE ist_zfivmsbank_bankl LINES l_line.

                  IF l_line > 1.
                    READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
                    SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
                    l_lifnr = g_tc531_wa-lifnr.
                    SHIFT l_lifnr LEFT DELETING LEADING '0'.
                    wa_zfivmsbank_bankl-zflag = 'X'.
* Begin of <> on 20062012
                    CONCATENATE 'With the same Combination of Bank Account' '& IFSC Code requested for'   INTO l_text.
                    CONCATENATE 'Vendor:-'l_lifnr ' , another request for updation of Vendor :-' wa_zfivmsbank_bankl-lifnr   INTO l_text1.
                    CONCATENATE 'is' ' in process with status-' wa_zfivmsbank_bankl-status INTO l_text2.
                    CONCATENATE 'Kindly check in the Report tab using Bank Key' '/Bank Account?' INTO l_text3.

*                    concatenate 'Request with the same same combination of ' g_tc531_wa-bankl_new ' & ' g_tc531_wa-bankn_new
*                    into l_text.
*                    concatenate 'exists for the Vendor-' wa_zfivmsbank_bankl-lifnr ' of CCode-' g_ccode  into l_text1.
*                    concatenate 'Kindly check in the Report tab using Bank Key' '/Bank Account.' into l_text3.

* End of <> on 20062012
                  ENDIF.
                ENDIF.
              ENDIF.
** Begin of <RD1K979928> on 02042012
*              if g_tc531_wa-zflag = 'X'.
*                 message i426(zfi) with g_tc531_wa-lifnr g_tc531_wa-ccode.
*              endif.
** End of <RD1K979928> on 02042012
* End of <> on 04042012
              IF g_tc531_wa-approve = 'X' OR g_tc531_wa-reject = 'X'.
* Begin of <> on 24022011
*                 perform check_bank_key_entry.
* End of <> on  24022011
                IF wa_zfivmsbank_bankl-zflag = 'X'.
*                  concatenate 'Request with the same bank details exists for the Vendor-' wa_zfivmsbank_bankl-lifnr into l_text.
*                  concatenate ' of CCode-' g_ccode  into l_text1.
*                  concatenate 'Kindly check in the Report tab using Bank Key' '/Bank Account.' into l_text2.

                  PERFORM popup_info USING l_text l_text1 l_text2 l_text3.

                  IF g_ans = 'J'.
                    MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
                    zfivmsbank-hof_cpf_no = g_cpf.
                    zfivmsbank-hof_name   = sy-uname.
                    zfivmsbank-hof_rldate = sy-datum.
                    zfivmsbank-hof_rltime = sy-uzeit.
                    zfivmsbank-status = 'APPROVED BY HOF'.
                    MODIFY zfivmsbank.
                  ELSEIF g_ans = 'N'.
* Commented on 18062012 Uncommented on 171212
*                    MOVE-CORRESPONDING G_TC531_WA TO ZFIVMSBANK.
*                    ZFIVMSBANK-HOF_CPF_NO = G_CPF.
*                    ZFIVMSBANK-HOF_NAME   = SY-UNAME.
*                    ZFIVMSBANK-HOF_RLDATE = SY-DATUM.
*                    ZFIVMSBANK-HOF_RLTIME = SY-UZEIT.
*                    ZFIVMSBANK-STATUS = 'REJECTED BY HOF'.
*                    MODIFY ZFIVMSBANK.
* End of <> on 18062012
                  ENDIF.
* Begin of <> on 20042012  07052012
                ELSEIF g_tc531_wa-approve = 'X'.
                  MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
                  zfivmsbank-hof_cpf_no = g_cpf.
                  zfivmsbank-hof_name   = sy-uname.
                  zfivmsbank-hof_rldate = sy-datum.
                  zfivmsbank-hof_rltime = sy-uzeit.
                  zfivmsbank-status = 'APPROVED BY HOF'.
                  MODIFY zfivmsbank.
                ELSEIF g_tc531_wa-reject = 'X'.
                  MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
                  zfivmsbank-hof_cpf_no = g_cpf.
                  zfivmsbank-hof_name   = sy-uname.
                  zfivmsbank-hof_rldate = sy-datum.
                  zfivmsbank-hof_rltime = sy-uzeit.
                  zfivmsbank-status = 'REJECTED BY HOF'.
                  MODIFY zfivmsbank.
* End of <> on 20042012  07052012
                ENDIF.
              ENDIF.
            ENDLOOP.
            IF sy-subrc = 0.
              MESSAGE i623(zfi).
              REFRESH : g_tc109_itab.
              CLEAR   : g_tc109_wa, g_tc109_copied, g_tc531_copied .
              LEAVE TO SCREEN 0.
            ENDIF.

          ELSEIF l_line1 > 0.
            DELETE FROM zfivmsbank WHERE reqno = g_zvms_reqno.
            MESSAGE i067(zfi).
            REFRESH : g_tc109_itab .
            CLEAR   : g_tc109_wa, g_tc109_copied, g_tc531_copied.
            LEAVE TO SCREEN 0.
          ELSE.
            MESSAGE i098(zfi).
          ENDIF.

        WHEN 'RELEASE'. "'APPROVED'.    270911
          IF l_line > 0.
*            DELETE FROM ZFIVMSBANK WHERE REQNO = ZFIVMSBANK-REQNO.

            LOOP AT g_tc531_itab INTO g_tc531_wa.
* Begin of <> on 20042012
              CLEAR : l_text, l_text1, l_text2, l_text3, l_line, wa_zfivmsbank_bankl-zflag.

              SELECT * FROM lfbk INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
              WHERE bankl = g_tc531_wa-bankl_new AND bankn = g_tc531_wa-bankn_new.
              IF sy-subrc = 0.
                l_lfbk_flag = 'X'.
                SORT ist_zfivmsbank_bankl DESCENDING BY bankl bankn.
                READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
                SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
                l_lifnr = g_tc531_wa-lifnr.
                SHIFT l_lifnr LEFT DELETING LEADING '0'.

                wa_zfivmsbank_bankl-zflag = 'X'.
                MODIFY g_tc531_itab FROM g_tc531_wa.

                CONCATENATE 'Combination of Bank Account & IFSC Code requested for Vendor:-'l_lifnr  INTO l_text1.
                CONCATENATE 'Already exists in Vendor Master :-' wa_zfivmsbank_bankl-lifnr INTO l_text2.
                CONCATENATE 'Do You Want to' ' Release  New Request?' INTO l_text3.

*                concatenate 'ASame bank details exists for the Vendor-' wa_zfivmsbank_bankl-lifnr ' in the Vendor Master'  into l_text.
*                concatenate 'Do You Want to' 'Continue ?' into l_text2.

              ELSE.

                SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank_bankl
                WHERE bankl_new = g_tc531_wa-bankl_new AND bankn_new = g_tc531_wa-bankn_new AND reqno <> zfivmsbank-reqno.

                IF sy-subrc = 0.

                  l_zfivms_flag = 'X'.
                  SORT ist_zfivmsbank_bankl DESCENDING BY vmc_apdate vmc_aptime.
                  READ TABLE ist_zfivmsbank_bankl INTO wa_zfivmsbank_bankl INDEX 1.
                  SHIFT wa_zfivmsbank_bankl-lifnr LEFT DELETING LEADING '0'.
                  l_lifnr = g_tc531_wa-lifnr.
                  SHIFT l_lifnr LEFT DELETING LEADING '0'.
                  wa_zfivmsbank_bankl-zflag = 'X'.
*{CR 30007948
                  CLEAR : l_f_bdc.
                  IF wa_zfivmsbank_bankl-status = 'REGISTRATION SUCCESSFUL'.
                    l_f_bdc = 'X'.
                  ENDIF.
*}CR 30007948
* Begin of <> on 18062012
                  CONCATENATE 'With the same Combination of Bank Account' '& IFSC Code requested for'   INTO l_text.
                  CONCATENATE 'Vendor:-'l_lifnr ' , another request for updation of Vendor :-' wa_zfivmsbank_bankl-lifnr   INTO l_text1.
                  CONCATENATE 'is' ' in process with status-' wa_zfivmsbank_bankl-status INTO l_text2.
                  CONCATENATE 'Kindly check in the Report tab using Bank Key' '/Bank Account?' INTO l_text3.


*                  concatenate 'Request with the same bank details exists for the Vendor-' wa_zfivmsbank_bankl-lifnr into l_text.
*                  concatenate ' of CCode-' g_ccode  into l_text1.
*                  concatenate 'Kindly check in the Report tab using Bank Key' '/Bank Account.' into l_text2.
* End of <> on 18062012
                ENDIF.
              ENDIF.
* End of <> on 20042012
              IF g_tc531_wa-approve = 'X'.
* Begin of <> on 240220111
*                 perform check_bank_key_entry.
* End of <> on  24022011
* Begin of <> on 20042012
                IF wa_zfivmsbank_bankl-zflag = 'X'.
                  PERFORM popup_info USING l_text l_text1 l_text2 l_text3.
* End of <> on 20042012
*                else.
                  IF g_ans = 'J'.
* Begin of <> on 19062012
                    IF l_lfbk_flag = 'X'.
                      SELECT * FROM lfa1 INTO CORRESPONDING FIELDS OF TABLE ist_lfbk_lfa1 FOR ALL ENTRIES IN ist_zfivmsbank_bankl
                      WHERE lifnr = ist_zfivmsbank_bankl-lifnr.  "#EC CI_NOORDER
                      IF sy-subrc = 0.
                        READ TABLE ist_lfbk_lfa1 INTO wa_lfbk_lfa1 WITH KEY sperr = ''.
                        IF sy-subrc = 0.
                          PERFORM reg_success.
                        ELSE.
                          PERFORM reg_rel_vmc.
                        ENDIF.
                      ENDIF.

                    ELSEIF l_zfivms_flag = 'X'.
                      IF ( l_f_bdc = 'X' ).
                        PERFORM reg_success.
                      ELSE.
                        PERFORM reg_rel_vmc.
                      ENDIF.
                    ENDIF.
* End of <> on 19062012
* Begin of <> on 20062012
*                  elseif g_ans = 'N'.
*                    perform reg_reject.
* End of <> on 20062012
                  ENDIF.
                ELSE.
                  PERFORM reg_rel_vmc.
                ENDIF.
              ELSEIF g_tc531_wa-reject = 'X'.
                MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
                zfivmsbank-vmc_cpf_no = g_cpf.
                zfivmsbank-vmc_name   = sy-uname.
                zfivmsbank-vmc_apdate = sy-datum.
                zfivmsbank-vmc_aptime = sy-uzeit.
* Begin of Change on 02052011
                IF zfivmsbank-ccode = 'OVL'.
                  zfivmsbank-status = 'REJECTED BY VMC FOR OVL'.
* End of Change
                ELSE.
                  zfivmsbank-status = 'REJECTED BY VMC'.
                ENDIF.
                MODIFY zfivmsbank.
              ENDIF.
            ENDLOOP.
            IF sy-subrc = 0.
              IF NOT g_asy_reqno IS INITIAL.
                MESSAGE s591(zfi) WITH g_asy_reqno g_asy_lifnr g_asy_uname.
              ELSE.
                MESSAGE s398(zfi) WITH zfivmsbank-reqno.
              ENDIF.
              IF g_vmc = 'X'.
                REFRESH ist_zfivmsbank.

                SELECT * FROM zfivmsbank INTO CORRESPONDING FIELDS OF TABLE ist_zfivmsbank
* Begin of <> 181110
*                 where registration = 'R'.
                 WHERE reqno = zfivmsbank-reqno AND "part added on 29082011
                       registration = 'R' AND
                       status IN ('RELEASE BY VMC','RELEASE BY VMC FOR OVL','REGISTRATION SUCCESSFUL').
                "APPROVED  270911, (added 'registration successful by ss on9/3/21)
* End of <> 181110
                LOOP AT ist_zfivmsbank INTO wa_zfivmsbank.
                  CONCATENATE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                  'abcdefghijklmnopqrstuvwxyz' INTO valid_characters_as.

                  valid_input_as = wa_zfivmsbank-bankl_new.
                  CONDENSE valid_input_as.
* Begin of <> on 08122010
*                  if wa_zfivmsbank-registration   = 'R' and
*                     wa_zfivmsbank-deregistration = 'D'.
* End of <> on 08122010
                  IF wa_zfivmsbank-registration = 'R'.
* Fill in those valid characters you need to check

*                      if  valid_input_as ca valid_characters_as.
                    IF  valid_input_as(4) <> 'SBIN'.
                      PERFORM non_sbi_updation_r.
                    ELSE.
                      CONCATENATE wa_zfivmsbank-reqno wa_zfivmsbank-srno wa_zfivmsbank-registration
                      wa_zfivmsbank-lifnr INTO ist_rdata_sbi-span.
                      ist_rdata_sbi-koinh_new  = wa_zfivmsbank-koinh_new.
                      ist_rdata_sbi-bankn_new  = wa_zfivmsbank-bankn_new.
**Begin RD1K991769 CAB_ALOK     CR 30010502:Beneficiary file-digital signing, Logging
*                      ist_rdata_sbi-bankl_new  = wa_zfivmsbank-bankl_new+6(5).
                      ist_rdata_sbi-bankl_new  = wa_zfivmsbank-bankl_new.
**End RD1K991769 CAB_ALOK     CR 30010502:Beneficiary file-digital signing, Logging

                      ist_rdata_sbi-vmc_apdate = wa_zfivmsbank-vmc_apdate.
                      ist_rdata_sbi-vmc_aptime = wa_zfivmsbank-vmc_aptime.
                      ist_rdata_sbi-status     = wa_zfivmsbank-status.
*                    move-corresponding wa_zfivmsbank to ist_rdata_sbi.
                      APPEND ist_rdata_sbi.
                      MOVE-CORRESPONDING ist_rdata_sbi TO wa_zfivms_brd.
* Begin of <RD1K977143> on 13072011
                      CLEAR : wa_zfivms_brd-street,
                              wa_zfivms_brd-str_suppl1,
                              wa_zfivms_brd-tel_number,
                              wa_zfivms_brd-city1.
* End of <RD1K977143> on 13072011
                      MODIFY zfivms_brd FROM wa_zfivms_brd.
                    ENDIF.

                  ENDIF.

                  IF wa_zfivmsbank-deregistration = 'D'.
                    valid_input_as = wa_zfivmsbank-bankl.   "09022011
                    CONDENSE valid_input_as.
*                      if  valid_input_as ca valid_characters_as.

                    IF  valid_input_as(4) <> 'SBIN'.
                      PERFORM non_sbi_updation_d.
                    ELSE.
                      CONCATENATE wa_zfivmsbank-reqno wa_zfivmsbank-srno wa_zfivmsbank-deregistration
                      wa_zfivmsbank-lifnr INTO ist_ddata_sbi-span.
                      ist_ddata_sbi-koinh_new  = wa_zfivmsbank-koinh. "_new. "03122010
                      ist_ddata_sbi-bankn_new  = wa_zfivmsbank-bankn. "_new.

**Begin RD1K991769 CAB_ALOK CR 30010502:Beneficiary file-digital signing, Logging
*                      ist_ddata_sbi-bankl_new  = wa_zfivmsbank-bankl+6(5).
                      ist_ddata_sbi-bankl_new  = wa_zfivmsbank-bankl.
**End RD1K991769 CAB_ALOK CR 30010502:Beneficiary file-digital signing, Logging

                      ist_ddata_sbi-vmc_apdate = wa_zfivmsbank-vmc_apdate.
                      ist_ddata_sbi-vmc_aptime = wa_zfivmsbank-vmc_aptime.
                      ist_ddata_sbi-status     = wa_zfivmsbank-status.
                      APPEND ist_ddata_sbi.
                      MOVE-CORRESPONDING ist_ddata_sbi TO wa_zfivms_brd.
* Begin of <RD1K977143> on 13072011
                      CLEAR : wa_zfivms_brd-street,
                              wa_zfivms_brd-str_suppl1,
                              wa_zfivms_brd-tel_number,
                              wa_zfivms_brd-city1.
* End of <RD1K977143> on 13072011
                      MODIFY zfivms_brd FROM wa_zfivms_brd.
                    ENDIF.
                  ENDIF.
*                  endif.
                ENDLOOP.

*                describe table ist_rdata_sbi lines l_rsbi.
*                if l_rsbi > 0.
*                  perform rdata_download.
*                endif.
*                describe table ist_ddata_sbi lines l_dsbi.
*                if l_dsbi > 0.
*                  perform ddata_download.
*                endif.
              ENDIF.
              REFRESH : g_tc109_itab.
              CLEAR   : g_tc109_wa, g_tc109_copied, g_tc531_copied.
              CLEAR   : g_asy_reqno, g_asy_lifnr, g_asy_uname.
              LEAVE TO SCREEN 0.
            ENDIF.

          ELSEIF l_line1 > 0.
            DELETE FROM zfivmsbank WHERE reqno = g_zvms_reqno.
            MESSAGE i067(zfi).
            REFRESH : g_tc109_itab .
            CLEAR   : g_tc109_wa, g_tc109_copied, g_tc531_copied.
            LEAVE TO SCREEN 0.
          ELSE.
            MESSAGE i098(zfi).
          ENDIF.

      ENDCASE.
    WHEN 'BACK'.
      CLEAR : g_tc531_copied, g_tc109_copied, g_tc531_copied. "G_TC531_COPIED Added on 010811 at all places
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0531  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC531'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc531_modify INPUT.

  IF g_tc531_wa-attach = 'X'.
    zfivmsbank-attach = g_tc531_wa-attach .
  ELSE.
    CLEAR zfivmsbank-attach.
  ENDIF.
  MOVE-CORRESPONDING zfivmsbank TO g_tc531_wa.

  IF NOT g_reject IS INITIAL.
    CASE g_okcode931.
      WHEN 'APPROVED'. "'RELEASE'.   "270911
        IF  zfivmsbank-hof_zremarks IS INITIAL.
          MESSAGE e934(zmm).
        ENDIF.

      WHEN 'RELEASE'. "'APPROVED'.  "270911
        IF zfivmsbank-vmc_zremarks IS INITIAL.
          MESSAGE e934(zmm).
        ENDIF.
    ENDCASE.
  ENDIF.

  IF NOT g_release IS INITIAL.
    g_tc531_wa-approve = g_release.
    CLEAR g_tc531_wa-reject.
* Begin of <> on 130911
    IF NOT g_tc531_wa-bankl     IS INITIAL AND
       NOT g_tc531_wa-bankn     IS INITIAL AND
       NOT g_tc531_wa-koinh     IS INITIAL AND
       NOT g_tc531_wa-bankl_new IS INITIAL AND
       NOT g_tc531_wa-bankn_new IS INITIAL AND
       NOT g_tc531_wa-koinh_new IS INITIAL.
      IF g_tc531_wa-attach IS INITIAL.
        CLEAR g_tc531_wa-approve.
        g_tc531_wa-reject = g_release.
*        g_tc531_wa-status = 'REJECTED BY HOF'.
        SET CURSOR FIELD zfivmsbank-attach LINE tc531-current_line.
        MESSAGE w420(zfi) WITH g_tc531_wa-lifnr.
      ENDIF.
*    endif.
* End of <> on130911
* Begin of <> on 31052012
    ELSEIF     g_tc531_wa-bankl     IS INITIAL AND
           g_tc531_wa-bankn     IS INITIAL AND
           g_tc531_wa-koinh     IS INITIAL AND
       NOT g_tc531_wa-bankl_new IS INITIAL AND
       NOT g_tc531_wa-bankn_new IS INITIAL AND
       NOT g_tc531_wa-koinh_new IS INITIAL.
      IF g_tc531_wa-attach IS INITIAL.
        CLEAR g_tc531_wa-approve.
        g_tc531_wa-reject = g_release.
        SET CURSOR FIELD zfivmsbank-attach LINE tc531-current_line.
        MESSAGE w420(zfi) WITH g_tc531_wa-lifnr.
      ENDIF.
    ENDIF.
* End of <> on 31052012
  ELSEIF NOT g_reject IS INITIAL.
    g_tc531_wa-reject = g_reject.
    CLEAR g_tc531_wa-approve.
  ENDIF.
  MODIFY g_tc531_itab
  FROM g_tc531_wa
  INDEX tc531-current_line.


ENDMODULE.                    "TC531_MODIFY INPUT
*&---------------------------------------------------------------------*
*&      Module  TB_FUNC_SEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tb_func_sel INPUT.
  IF tc109-line_sel_mode = 1 AND g_tc109_wa-sel109 = 'X'.
    IF g_okcode109 = 'CHANGE'.
      g_tc109_itab[] = g_tc109_itab_temp9[].
    ENDIF.
    MODIFY g_tc109_itab FROM g_tc109_wa INDEX
    tc109-current_line TRANSPORTING sel109.
  ENDIF.
ENDMODULE.                 " TB_FUNC_SEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC531_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE TC531_USER_COMMAND INPUT.
*  OK_CODE = SY-UCOMM.
*  PERFORM USER_OK_TC USING    'TC531'
*                              'G_TC531_ITAB'
*                              'SEL531' "'FLAG'
*                     CHANGING OK_CODE.
*  SY-UCOMM = OK_CODE.
*ENDMODULE.                 " TC531_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  TB_FUNC_SEL531  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tb_func_sel531 INPUT.
  IF tc531-line_sel_mode = 1 AND g_tc531_wa-sel531 = 'X'.   "tc531-line_sel_mode = 1 290911
    IF g_okcode531 = 'CHANGE'.
      g_tc531_itab[] = g_tc531_itab_temp[].
    ENDIF.

    MODIFY g_tc531_itab FROM g_tc531_wa INDEX
    tc531-current_line TRANSPORTING sel531.
  ENDIF.
ENDMODULE.                 " TB_FUNC_SEL531  INPUT
*&---------------------------------------------------------------------*
*&      Module  TB_FUNC_SEL319  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tb_func_sel319 INPUT.
  IF tc319-line_sel_mode = 1 AND g_tc319_wa-sel319 = 'X'.

* Begin of <> on 19092011
*    g_okcode319 = sy-ucomm.
*    if G_OKCODE931 = 'CHANGE'.                              "150911
*      if g_okcode319 = 'ATTACH' or zfivmsbank-attach = 'X'.
*        case g_okcode319.
*          when 'ATTACH'.
*            perform attach_files.
*          when 'LIST'.
*            perform list_files.
*        endcase.
*      endif.

* End of <> on 19092011

    MODIFY g_tc319_itab FROM g_tc319_wa INDEX
                             tc319-current_line  TRANSPORTING sel319. "19092011 "230911
*    else.
*      case g_okcode319.
*        when 'LIST'.
*          perform list_files.
*      endcase.
*    endif.
  ENDIF.
ENDMODULE.                 " TB_FUNC_SEL319  INPUT
*&---------------------------------------------------------------------*
*&      Form  ATTACH_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files .
  DATA itab LIKE symsg OCCURS 0 WITH HEADER LINE.
  DATA l_obj TYPE sood4-objno.                              "21072011
  DATA ls_attachment_data TYPE sodocchgi1.                  "21072011

  IF g_attachment = 'X' OR g_okcode319 = 'ATTACH'.
    CLEAR g_att_files_wa.
    REFRESH g_att_files.

    CONCATENATE g_tc319_wa-srno(3) g_tc319_wa-reqno+3(7) INTO docno_lifnr.

    g_att_files_wa-logsys  = '01'.
    g_att_files_wa-objtype = 'VENDOR'.
    g_att_files_wa-objkey  = docno_lifnr.

    APPEND g_att_files_wa TO g_att_files.
    CALL FUNCTION 'ZSO_WIND_ATTACHMENT_CREAT_API1' "'SO_WIND_ATTACHMENT_CREATE_API1'
      EXPORTING
        attachment_data     = ls_attachment_data
        attachment_type     = 'DOC'
      IMPORTING
        attach_obj          = l_obj
      TABLES
        application_objects = g_att_files.

    IF NOT l_obj IS INITIAL.
      g_tc319_wa-attach = 'X'.

      MOVE-CORRESPONDING g_tc319_wa TO zfivmsbank.
      zfivmsbank-status = 'NEW'.
      zfivmsbank-username = sy-uname.
      zfivmsbank-cdate    = sy-datum.
      zfivmsbank-cputm    = sy-uzeit.
      zfivmsbank-cpf      = g_cpf .
      zfivmsbank-ccode    = g_ccode .
      MODIFY zfivmsbank.
*      select single * from icon into wa_icon where name = 'ICON_ATTACHMENT'.
*      G_TC319_WA-attach = wa_icon-id.
**        g_tc319_wa-ZVENDTIMESTAMP = docno_lifnr.
*      select single * from icon into wa_icon where name = 'ICON_LIST'.
*      G_TC319_WA-zlist = wa_icon-id.

      MODIFY g_tc319_itab  FROM g_tc319_wa INDEX g_tc319_wa-srno.  "#EC CI_NOORDER  "TC319-CURRENT_LINE.
    ELSE.
      MESSAGE i412(zfi).
    ENDIF.

  ENDIF.

ENDFORM.                    " ATTACH_FILES
*&---------------------------------------------------------------------*
*&      Form  LIST_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files .
  DATA : l_list TYPE zfivmsbank-zlist.                      "07092011
  IF g_attachment = 'X' OR g_okcode319 = 'LIST' OR g_okcode531 = 'LIST'.
    CLEAR g_att_files_wa.

* Begin of <> on 19092011 210911
    CONCATENATE g_tc319_wa-srno(3) g_tc319_wa-reqno+3(7) INTO docno_lifnr.
* End of <> on 06092011
    g_att_files_wa-logsys  = '01'.
    g_att_files_wa-objtype = 'VENDOR'.
    g_att_files_wa-objkey  = docno_lifnr.

    REFRESH exclude_tab[].
    exclude_tab-fcode = 'EXPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'IMPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'HGEN'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'OLNK'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'REFL'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'COPY'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'CHNG'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'PRIN'.
    APPEND exclude_tab.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa
        function           = ' '
      TABLES
        func_exclude       = exclude_tab.            "190911 290911
    "070911 ELSE PART ADDED
*    ENDIF.                                                  "07091
  ENDIF.

ENDFORM.                    " LIST_FILES
*&---------------------------------------------------------------------*
*&      Module  ATTACH_LIST_FILES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE attach_list_files INPUT.

  g_okcode319 = sy-ucomm.
  IF g_okcode931 = 'CHANGE'.                                "150911
    CASE g_okcode319 .
      WHEN 'ATTACH' .                                       "210911
        READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY sel319 = 'X'. "index tc319-current_line.
        IF sy-subrc = 0.

          IF NOT g_tc319_wa-bankl     IS INITIAL AND    "zfivmsbank
             NOT g_tc319_wa-bankn     IS INITIAL AND
             NOT g_tc319_wa-koinh     IS INITIAL AND
             NOT g_tc319_wa-bankl_new IS INITIAL AND
             NOT g_tc319_wa-bankn_new IS INITIAL AND
             NOT g_tc319_wa-koinh_new IS INITIAL.
            MESSAGE s419(zfi).
          ENDIF.

        ELSE.
          MESSAGE i419(zfi).
        ENDIF.
      WHEN 'LIST'.
        READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY sel319 = 'X'.
        IF sy-subrc <> 0.
          MESSAGE i419(zfi).
        ENDIF.
    ENDCASE.
  ELSEIF g_okcode931 = 'DISPLAY'.                           "270911
    CASE g_okcode319.
      WHEN 'LIST'.
        READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY sel319 = 'X'.
        IF sy-subrc <> 0.
          MESSAGE i419(zfi).
        ENDIF.
    ENDCASE.
*    if g_okcode319 = 'ATTACH' or zfivmsbank-attach = 'X'." 190911 OR G_TC319_WA-attach is initial. "RD1K977307 'ATTACH' ADDED AGAIN
*      case g_okcode319.
*        when 'ATTACH'.
*          perform attach_files.
*
**    when 'LIST'.           "251110
**      perform list_files.
*      endcase.
*
*
*      MODIFY G_TC319_ITAB
*      FROM G_TC319_WA
*      INDEX TC319-CURRENT_LINE.
*      clear : G_TC319_WA .
*    endif.
  ENDIF.

ENDMODULE.                 " ATTACH_LIST_FILES  INPUT
" NEW_VALUE_ENTRY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_NEW_ENTRY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE CHECK_NEW_ENTRY INPUT.

*  g_okcode319 = sy-ucomm.
*  case g_okcode319.
*    when 'SAVE'.
*      if zfivmsbank-bankl_new is initial or "and
*         zfivmsbank-bankn_new is initial or "and
*         zfivmsbank-koinh_new is initial.
*        message e365(zfi) with zfivmsbank-lifnr.
**        message e349(zfi).
*      else.
**         perform check_key_till_banka.
*      endif.
*
**      if not zfivmsbank-bankl_new is initial and
**         not zfivmsbank-bankn_new is initial and
**         not zfivmsbank-koinh_new is initial.
**      else.
**        message e365(zfi).
**      endif.
*  endcase.
*ENDMODULE.                 " CHECK_NEW_ENTRY  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANK_KEY_ENTRY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bank_key_entry .
* Bank Key
  DATA : l_len(2)         TYPE n,
         l_digit(2)       TYPE n,
         h_digit(2)       TYPE n,
         l_str            TYPE string,
         valid_characters TYPE string,
         invalid_char     TYPE string,
         valid_input      TYPE string.

  l_len = strlen( zfivmsbank-bankl_new ) .
  l_str = zfivmsbank-bankl_new(4).
  IF NOT zfivmsbank-koinh_new IS INITIAL.                   "25082010
* Fill in those valid characters you need to check
    CONCATENATE '0123456789' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    'abcdefghijklmnopqrstuvwxyz' INTO valid_characters.

*    concatenate '!`!@#$%^&*()_-' '{[}]\":;?/.,<>' into invalid_char.  "011210
*begin RD1K991769       CAB_ALOK     CompBeneFile gen,digsign,transfer,monitor - CR 30010502
*    concatenate '''~!`!@#$%^&*()_-' '{[}]\":;?/,<>' into invalid_char.
    CONCATENATE '''~!`!@#$%^&*()_-' '{[}]\":;?/,<>.' INTO invalid_char.   " . added
*end RD1K991769       CAB_ALOK     CompBeneFile gen,digsign,transfer,monitor - CR 30010502
    valid_input = zfivmsbank-koinh_new.
    CONDENSE valid_input.
    IF  valid_input CA invalid_char.
* Begin of <> on 05072011
      SET CURSOR FIELD 'ZFIVMSBANK-KOINH_NEW' LINE tc319-current_line.
* End of <> on 05072011
      MESSAGE e361(zfi) WITH zfivmsbank-koinh_new.
    ENDIF.
  ENDIF.

  IF l_len <> 11.
* Begin of <> on 05072011
    SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc319-current_line.
* End of <> on 05072011
    MESSAGE e351(zfi).
  ELSE.
    IF l_str CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
*     search  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' for ZFIVMSBANK-BANKL_NEW(4).
      SEARCH  '0' FOR zfivmsbank-bankl_new+4(1).
      IF sy-subrc NE 0.
* Begin of <> on 05072011
        SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc319-current_line.
* End of <> on 05072011
        MESSAGE e353(zfi).
      ENDIF.
    ELSE.
* Begin of <> on 05072011
      SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc319-current_line.
* End of <> on 05072011
      MESSAGE e352(zfi).
    ENDIF.
  ENDIF.
* Bank Account
  IF NOT zfivmsbank-bankn_new IS INITIAL.
    DATA : l_len1(2)       TYPE n,
           l_len2(2)       TYPE n,
           l_str1          TYPE string,
           l_lastdigit     TYPE string,
           l_firstdigit    TYPE string,
           wa_zmm_vms_ifsc TYPE zmm_vms_ifsc,
           l_temp(2) .

    SELECT SINGLE * FROM zmm_vms_ifsc INTO wa_zmm_vms_ifsc WHERE bankl = l_str.
    l_len1 = strlen( zfivmsbank-bankn_new ) .
    l_str1 = zfivmsbank-bankn_new(4).
    l_temp = l_len1.

    IF wa_zmm_vms_ifsc-bnkkeypos > '0'.
      " or  wa_ZMM_VMS_IFSC-bnkkeypos is initial. "31082010
      wa_zmm_vms_ifsc-bnkkeypos = wa_zmm_vms_ifsc-bnkkeypos - 1.
      wa_zmm_vms_ifsc-acntpos   = wa_zmm_vms_ifsc-acntpos - 1.
      l_lastdigit = zfivmsbank-bankl_new+wa_zmm_vms_ifsc-bnkkeypos(wa_zmm_vms_ifsc-bnkkey_digit).
      l_firstdigit = zfivmsbank-bankn_new+wa_zmm_vms_ifsc-acntpos(wa_zmm_vms_ifsc-acnt_digit).
      IF ( wa_zmm_vms_ifsc-symbol_cond = '=')  OR
         ( wa_zmm_vms_ifsc-symbol_cond = '<=') OR
         ( wa_zmm_vms_ifsc-symbol_cond = '>=') OR
         ( wa_zmm_vms_ifsc-symbol_cond = 'BT') OR
         ( wa_zmm_vms_ifsc-symbol_cond = '>')  OR
         ( wa_zmm_vms_ifsc-symbol_cond = '<').

        IF ( wa_zmm_vms_ifsc-symbol_cond = '=').
          IF l_len1 <>  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e354(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '<=').
          IF l_len1 >=  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '>=').
          IF l_len1 <=  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e360(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = 'BT').
          CONDENSE wa_zmm_vms_ifsc-symbol_digit.
          SPLIT wa_zmm_vms_ifsc-symbol_digit AT ',' INTO l_digit h_digit.
          CONDENSE l_temp.
          IF  ( l_temp > h_digit ).
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ELSEIF l_temp < l_digit .
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.
**          if l_len1 >=  wa_ZMM_VMS_IFSC-SYMBOL_DIGIT(1) or
**             l_len1 <=  wa_ZMM_VMS_IFSC-SYMBOL_DIGIT+5(2).
*          if l_digit <= l_len1." and
**             h_digit >=  l_len1.
*            message e359(zfi) with wa_ZMM_VMS_IFSC-SYMBOL_DIGIT.
*          endif.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '<').
          IF l_len1 >  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '>').
          IF l_len1 <  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ENDIF.
        IF l_lastdigit <> l_firstdigit.
* Begin of <> on 05072011
          SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
          MESSAGE e355(zfi).
        ENDIF.
      ENDIF.
    ELSE.
      IF ( wa_zmm_vms_ifsc-symbol_cond = '=')  OR
        ( wa_zmm_vms_ifsc-symbol_cond = '<=') OR
        ( wa_zmm_vms_ifsc-symbol_cond = '>=') OR
        ( wa_zmm_vms_ifsc-symbol_cond = 'BT') OR
        ( wa_zmm_vms_ifsc-symbol_cond = '>')  OR
        ( wa_zmm_vms_ifsc-symbol_cond = '<').

        IF ( wa_zmm_vms_ifsc-symbol_cond = '=').
          IF l_len1 <>  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e354(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '<=').
          IF l_len1 >  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '>=').
          IF l_len1 <  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e360(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = 'BT').
          CONDENSE wa_zmm_vms_ifsc-symbol_digit.
          SPLIT wa_zmm_vms_ifsc-symbol_digit AT ',' INTO l_digit h_digit.
          CONDENSE l_temp.
          IF  ( l_temp > h_digit ). " l_len1 >= l_digit or
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ELSEIF l_temp < l_digit .
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '<').
          IF l_len1 >  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc-symbol_cond = '>').
          IF l_len1 <  wa_zmm_vms_ifsc-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc-symbol_digit.
          ENDIF.

        ENDIF.
        IF l_lastdigit <> l_firstdigit.
* Begin of <> on 05072011
          SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc319-current_line.
* End of <> on 05072011
          MESSAGE e355(zfi).
        ENDIF.
      ENDIF.
    ENDIF.

* Begin of <> on 25082010 04092010
    IF NOT wa_zmm_vms_ifsc-cnd IS INITIAL.
      IF wa_zmm_vms_ifsc-cnd = 'BEGIN WITH'.
        CONDENSE zfivmsbank-bankn_new.
        SEARCH ',' FOR zfivmsbank-bankn_new.
        IF zfivmsbank-bankl_new(4) = 'SBIN'.
          IF zfivmsbank-bankn_new(1) <> '1' AND
             zfivmsbank-bankn_new(1) <> '2' AND
             zfivmsbank-bankn_new(1) <> '3' AND
             zfivmsbank-bankn_new(1) <> '4' AND   " added by ss on 6.7.21
             zfivmsbank-bankn_new(1) <> '5' AND
             zfivmsbank-bankn_new(1) <> '6' .
            MESSAGE e362(zfi).
          ENDIF.
        ELSEIF zfivmsbank-bankl_new(4) = 'CORP'.
          IF  zfivmsbank-bankn_new(7) = 'CCSDL01'.
*               message e363(zfi).
          ELSEIF zfivmsbank-bankn_new(6) = 'CBCA01' .
*              message e363(zfi).
          ELSEIF zfivmsbank-bankn_new(4) = 'CA01' OR
                 zfivmsbank-bankn_new(4) = 'SB01' OR
                 zfivmsbank-bankn_new(4) = 'CC01'.

          ELSE.
            MESSAGE e363(zfi).
          ENDIF.
        ENDIF.
      ELSEIF wa_zmm_vms_ifsc-cnd = 'ENDS WITH'.
        IF zfivmsbank-bankl_new(4) = 'KARB'.
          IF zfivmsbank-bankn_new+14(2) <> '01'.
            MESSAGE e364(zfi).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
* End of <>
  ENDIF.
ENDFORM.                    " CHECK_BANK_KEY_ENTRY

**&SPWIZARD: INPUT MODULE FOR TC 'TC531'. DO NOT CHANGE THIS LINE!
**&SPWIZARD: PROCESS USER COMMAND
MODULE tc531_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC531'
                              'G_TC531_ITAB'
                              'SEL531' "'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC531_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DUPLICATE_ENTRY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_entry INPUT.

*  if g_exist is initial.
*    read table g_tc319_itab into g_tc319_wa with key lifnr = zfivmsbank-lifnr.
*    if sy-subrc = 0.
*      message e366(zfi) with zfivmsbank-lifnr.
*    endif.
*  endif.
*  MOVE-CORRESPONDING ZFIVMSBANK TO G_TC319_WA.               "160911

  g_okcode319 = sy-ucomm.
  IF g_tc319_wa-exist <> 'X'.    "This part of Code added on 290911
    CASE g_okcode319.

      WHEN 'TC319_INSR' OR 'SAVE' .

        IF zfivmsbank-bankl_new IS INITIAL OR "and
           zfivmsbank-bankn_new IS INITIAL OR "and
           zfivmsbank-koinh_new IS INITIAL.
          SET CURSOR FIELD 'zfivmsbank-bankl_new' LINE sy-tabix.
          MESSAGE e365(zfi) WITH zfivmsbank-lifnr.

        ELSEIF NOT zfivmsbank-bankl     IS INITIAL AND
               NOT zfivmsbank-bankn     IS INITIAL AND
               NOT zfivmsbank-koinh     IS INITIAL AND
               NOT zfivmsbank-bankl_new IS INITIAL AND
               NOT zfivmsbank-bankn_new IS INITIAL AND
               NOT zfivmsbank-koinh_new IS INITIAL.
*        if zfivmsbank-attach  is initial.                     " G_TC319_WA-attach 160911
* Begin of <> on 160911
          IF g_okcode931 = 'CREATE'.
            IF g_tc319_wa-attach <> 'X'.
              MESSAGE i417(zfi).
*          l_text = 'Changes affect payments from other locations. Do u wish to continue?'.
*          PERFORM POPUP_MESSAGE_DISPLAY USING L_TEXT.
*          if l_answer = 'J'.
* End of <> on 160911
*            if g_attachment <> 'X'.
*               g_attachment = 'X'.            "20072011
              zfivmsbank-attach = 'X'.          "20072011   160911
              MOVE-CORRESPONDING zfivmsbank TO g_tc319_wa.  "160911
              MODIFY g_tc319_itab
              FROM g_tc319_wa
              INDEX tc319-current_line.
*            G_TC319_WA-attach = 'X'.           "160911
              MESSAGE w380(zfi) WITH zfivmsbank-lifnr.      "120911 130911
            ENDIF.
          ELSEIF g_okcode931 = 'CHANGE'.
            IF g_tc319_wa-attach <> 'X'.
              MESSAGE e418(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ENDIF.
*               g_attachment = 'X'.            "20072011
*               zfivmsbank-attach = 'X'.       "20072011
*            endif.
*          endif.
*        endif.
* Begin of <> on 31052012
        ELSEIF     zfivmsbank-bankl     IS INITIAL AND
                   zfivmsbank-bankn     IS INITIAL AND
                   zfivmsbank-koinh     IS INITIAL AND
               NOT zfivmsbank-bankl_new IS INITIAL AND
               NOT zfivmsbank-bankn_new IS INITIAL AND
               NOT zfivmsbank-koinh_new IS INITIAL.
          IF g_okcode931 = 'CREATE'.
            IF g_tc319_wa-attach <> 'X'.
              MESSAGE i417(zfi).
              zfivmsbank-attach = 'X'.
              MOVE-CORRESPONDING zfivmsbank TO g_tc319_wa.
              MODIFY g_tc319_itab
              FROM g_tc319_wa
              INDEX tc319-current_line.
              MESSAGE w380(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ELSEIF g_okcode931 = 'CHANGE'.
            IF g_tc319_wa-attach <> 'X'.
              MESSAGE e418(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ENDIF.
* End of <> on 31052012
        ENDIF.

*  WHEN 'ENTER'.
    ENDCASE.
  ENDIF.
ENDMODULE.                 " CHECK_DUPLICATE_ENTRY  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANK_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bank_flow .

  SELECT SINGLE * FROM lfb1 INTO wa_lfb1 WHERE lifnr = zfivmsbank-lifnr
                                           AND bukrs = g_ccode.
  IF sy-subrc <> 0.
    MESSAGE e367(zfi) WITH zfivmsbank-lifnr g_ccode.
  ENDIF.

  IF NOT g_lifnr1 IS INITIAL.
    IF  g_lifnr1 = zfivmsbank-lifnr.
      IF NOT g_exist IS INITIAL.
        MESSAGE e366(zfi) WITH zfivmsbank-lifnr.
      ENDIF.
    ELSE.
      CLEAR : g_exist, g_lifnr1.
    ENDIF.
  ENDIF.

  IF zfivmsbank-bankl_new IS INITIAL.
    CASE g_okcode319.
      WHEN 'ENTER'.
        DESCRIBE TABLE g_tc319_itab LINES l_line.

        IF l_line > 1 AND g_exist IS INITIAL.
          READ TABLE g_tc319_itab INTO g_tc319_wa_temp WITH KEY lifnr = zfivmsbank-lifnr.
          IF sy-subrc = 0.
            g_lifnr1 = zfivmsbank-lifnr.
            g_exist  = 'X'.
            MESSAGE e366(zfi) WITH zfivmsbank-lifnr.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

* Begin of <> on 25092010
  CASE g_okcode931.
    WHEN 'CREATE'.
      PERFORM check_lifnr_flow.
    WHEN 'CHANGE'.
      READ TABLE g_tc319_itab INTO g_tc319_wa_as INDEX tc319-current_line.  "#EC CI_NOORDER
      IF zfivmsbank-bankl_new = g_tc319_wa_as-bankl_new AND
         zfivmsbank-bankn_new = g_tc319_wa_as-bankn_new AND
         zfivmsbank-koinh_new = g_tc319_wa_as-koinh_new .
        PERFORM check_lifnr_flow.
      ENDIF.
    WHEN 'CHECK'.
      PERFORM check_existance_of_bankn.
  ENDCASE.
* End of <> on 25092010

ENDFORM.                    " CHECK_BANK_FLOW
*&---------------------------------------------------------------------*
*&      Module  CHECK_BANK_FLOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_bank_flow INPUT.
  PERFORM check_bank_flow.
ENDMODULE.                 " CHECK_BANK_FLOW  INPUT
*&---------------------------------------------------------------------*
*&      Form  NON_SBI_UPDATION_R
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM non_sbi_updation_r .
* Begin of <RD1K977563> on 29082011
  DATA : invalid_char TYPE string,
         valid_input  TYPE string,
         l_street(30),
         l_len(2)     TYPE n,
         l_len1(2)    TYPE n,
         wa_lfa1      LIKE lfa1.
* End of <RD1K977563> on 29082011
  CONCATENATE wa_zfivmsbank-reqno wa_zfivmsbank-srno wa_zfivmsbank-registration
                        wa_zfivmsbank-lifnr INTO ist_rdata_sbi-span.
  ist_rdata_sbi-koinh_new  = wa_zfivmsbank-koinh_new.
  ist_rdata_sbi-bankn_new  = wa_zfivmsbank-bankn_new.
  ist_rdata_sbi-bankl_new  = wa_zfivmsbank-bankl_new.
  ist_rdata_sbi-vmc_apdate = wa_zfivmsbank-vmc_apdate.
  ist_rdata_sbi-vmc_aptime = wa_zfivmsbank-vmc_aptime.
  ist_rdata_sbi-status     = wa_zfivmsbank-status.

  SELECT SINGLE * FROM lfa1 INTO wa_lfa1 WHERE lifnr = wa_zfivmsbank-lifnr.
  IF sy-subrc = 0.
    SELECT SINGLE * FROM adrc INTO wa_adrc WHERE addrnumber = wa_lfa1-adrnr.  "#EC CI_NOORDER
    IF sy-subrc = 0.
      IF NOT wa_adrc-street IS INITIAL.
* Begin of <RD1K977563> on 14102011
        CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,.<>'  INTO invalid_char.
        valid_input = wa_adrc-street.
        CONDENSE valid_input NO-GAPS.
        IF  valid_input CA invalid_char.
          CALL FUNCTION 'ZMM_REMOVE_STRINGS'
            EXPORTING
              i_string         = valid_input
              i_search_pattern = invalid_char
            IMPORTING
              e_string         = valid_input.
        ENDIF.

* Begin of <RD1K978300> on 221211
*        ist_rdata_sbi-STREET     = valid_input.
        CLEAR : l_len , l_len1.                             "231211
        l_len = strlen( valid_input ).
        IF l_len > 30.                                      " 231211
          l_len1 =  ( l_len - 30 ).
          ist_rdata_sbi-street = valid_input+l_len1(30).
        ELSE.
          ist_rdata_sbi-street     = valid_input.
        ENDIF.
* End of <RD1K978300> on 221211
* End of <> on 14102011
      ELSE.
        ist_rdata_sbi-street     = 'ONGC'.
      ENDIF.
* End of <> on 14102011
      IF NOT wa_adrc-str_suppl1 IS INITIAL.
* Begin of <RD1K977563> on 29092011
        CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,.<>'  INTO invalid_char.
        CONDENSE  wa_adrc-str_suppl1 NO-GAPS. "valid_input.

        valid_input = wa_adrc-str_suppl1.   "l_street.

        IF  valid_input CA invalid_char.
          CALL FUNCTION 'ZMM_REMOVE_STRINGS'
            EXPORTING
              i_string         = valid_input
              i_search_pattern = invalid_char
            IMPORTING
              e_string         = valid_input.
        ENDIF.
* Begin of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = valid_input.
        CLEAR : l_len , l_len1.
        l_len = strlen( valid_input ).
        IF l_len > 30.                                      " 231211
          l_len1 =  ( l_len - 30 ).
          ist_rdata_sbi-str_suppl1 = valid_input+l_len1(30).
        ELSE.
          ist_rdata_sbi-str_suppl1     = valid_input.
        ENDIF.
* End of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = wa_adrc-STR_SUPPL1.
* End of <> on 290911
      ELSEIF NOT wa_adrc-str_suppl2 IS INITIAL.
* Begin of <RD1K977563> on 29092011
        CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,.<>'  INTO invalid_char.
        CONDENSE wa_adrc-str_suppl2 NO-GAPS. "valid_input.
        valid_input = wa_adrc-str_suppl2.

        IF  valid_input CA invalid_char.
          CALL FUNCTION 'ZMM_REMOVE_STRINGS'
            EXPORTING
              i_string         = valid_input
              i_search_pattern = invalid_char
            IMPORTING
              e_string         = valid_input.
        ENDIF.
* Begin of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = valid_input.
        CLEAR : l_len , l_len1.
        l_len = strlen( valid_input ).
        IF l_len > 30.                                      " 231211
          l_len1 =  ( l_len - 30 ).
          ist_rdata_sbi-str_suppl1 = valid_input+l_len1(30).
        ELSE.
          ist_rdata_sbi-str_suppl1     = valid_input.
        ENDIF.
* End of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = wa_adrc-STR_SUPPL2.
* End of <> on 290911
      ELSEIF NOT wa_adrc-str_suppl3 IS INITIAL.
* Begin of <RD1K977563> on 29092011
        CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,.<>'  INTO invalid_char.
        CONDENSE wa_adrc-str_suppl3 NO-GAPS.
        valid_input = wa_adrc-str_suppl3.
*        condense valid_input.                    "27012012
        IF  valid_input CA invalid_char.
          CALL FUNCTION 'ZMM_REMOVE_STRINGS'
            EXPORTING
              i_string         = valid_input
              i_search_pattern = invalid_char
            IMPORTING
              e_string         = valid_input.
        ENDIF.
* Begin of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = valid_input.
        CLEAR : l_len , l_len1.
        l_len = strlen( valid_input ).
        IF l_len > 30.                                      " 231211
          l_len1 =  ( l_len - 30 ).
          ist_rdata_sbi-str_suppl1 = valid_input+l_len1(30).
        ELSE.
          ist_rdata_sbi-str_suppl1     = valid_input.
        ENDIF.
* End of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = wa_adrc-STR_SUPPL3.
* End of <> on 290911
      ELSE.
        ist_rdata_sbi-str_suppl1 = 'ONGC'.
      ENDIF.
* Begin of <RD1K977563> on 29082011
      CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,<>.' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     'abcdefghijklmnopqrstuvwxyz'    INTO invalid_char.
      IF wa_adrc-tel_number <> ''.
        CONDENSE wa_adrc-tel_number NO-GAPS.                "04012012
        valid_input = wa_adrc-tel_number.
*        condense valid_input.                    "03012012
*        if  valid_input ca invalid_char.
        CALL FUNCTION 'ZMM_REMOVE_STRINGS'
          EXPORTING
            i_string         = valid_input
            i_search_pattern = invalid_char
          IMPORTING
            e_string         = valid_input.
*        endif.
        CLEAR : l_len , l_len1.
        CONDENSE valid_input.                               "03012012

        l_len = strlen( valid_input ).
        IF l_len > 10.                                      "20 231211
          l_len1 =  ( l_len - 10 ).
          ist_rdata_sbi-tel_number = valid_input+l_len1(10). "wa_adrc-TEL_NUMBER(20).
        ELSE.
          ist_rdata_sbi-tel_number = valid_input.
        ENDIF.
*        ist_rdata_sbi-TEL_NUMBER = wa_adrc-TEL_NUMBER.
      ENDIF.
* End of <RD1K977563> on 29082011

      IF wa_adrc-city1 IS INITIAL .
        ist_rdata_sbi-city1      = 'MUMBAI'.
      ELSE.
        CONCATENATE '!`!@#$%^~''&*()_-' '{[}]\":;?/,<>.'  INTO invalid_char.
        CONDENSE wa_adrc-city1 NO-GAPS.
        valid_input = wa_adrc-city1.
*        condense valid_input.
        IF  valid_input CA invalid_char.
          CALL FUNCTION 'ZMM_REMOVE_STRINGS'
            EXPORTING
              i_string         = valid_input
              i_search_pattern = invalid_char
            IMPORTING
              e_string         = valid_input.
        ENDIF.
* Begin of <RD1K978300> on 221211
*        ist_rdata_sbi-STR_SUPPL1 = valid_input.
        CLEAR : l_len , l_len1.
        l_len = strlen( valid_input ).
        IF l_len > 30.                                      " 231211
          l_len1 =  ( l_len - 30 ).
          ist_rdata_sbi-city1 = valid_input+l_len1(30).
        ELSE.
          ist_rdata_sbi-city1     = valid_input.
        ENDIF.
*        ist_rdata_sbi-CITY1      = wa_adrc-CITY1(30). "<RD1K978300> on 221211 wa_adrc-CITY1
      ENDIF .
    ENDIF.
  ENDIF.
  APPEND ist_rdata_sbi.
  MOVE-CORRESPONDING ist_rdata_sbi TO wa_zfivms_brd.
  MODIFY zfivms_brd FROM wa_zfivms_brd.
ENDFORM.                    " NON_SBI_UPDATION
*&---------------------------------------------------------------------*
*&      Form  NON_SBI_UPDATION_D
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM non_sbi_updation_d .
  CONCATENATE wa_zfivmsbank-reqno wa_zfivmsbank-srno wa_zfivmsbank-deregistration
  wa_zfivmsbank-lifnr INTO ist_ddata_sbi-span.
  ist_ddata_sbi-koinh_new  = wa_zfivmsbank-koinh. "_new. 03122010
  ist_ddata_sbi-bankn_new  = wa_zfivmsbank-bankn. "_new.
  ist_ddata_sbi-bankl_new  = wa_zfivmsbank-bankl. "_new.
  ist_ddata_sbi-vmc_apdate = wa_zfivmsbank-vmc_apdate.
  ist_ddata_sbi-vmc_aptime = wa_zfivmsbank-vmc_aptime.
  ist_ddata_sbi-status     = wa_zfivmsbank-status.
  APPEND ist_ddata_sbi.
  MOVE-CORRESPONDING ist_ddata_sbi TO wa_zfivms_brd.
  MODIFY zfivms_brd FROM wa_zfivms_brd.
ENDFORM.                    " NON_SBI_UPDATION_D
*&---------------------------------------------------------------------*
*&      Module  ATTACH_LIST_FILES_0531  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE attach_list_files_0531 INPUT.
  g_okcode531 = sy-ucomm.

  CASE g_okcode531.
    WHEN 'LIST'.
      READ TABLE g_tc531_itab INTO g_tc531_wa WITH KEY sel531 = 'X'.
      IF sy-subrc <> 0.
        MESSAGE i419(zfi).
      ELSE.
        PERFORM list_files_0531.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " ATTACH_LIST_FILES_0531  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0430  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0430 INPUT.
*{if block vendor button clicked---
  IF g_trans_mode = 'B'.
    g_block_vendor = 'X'.
    """"""""""""""""""
    "added by lipsy on 30.05.2013 RD1K983016
    g_block_vendor_att = 'X'.
    "end of addition by lipsy on 30.05.2013
    """""""""""""""""""""
    g_dynnr1 = '440'.
    g_dynnr2 = '450'.
    g_cursorfield = 'IST_BL-LIFNR'.
    g_cursorline = '1'.
  ENDIF.
*}
  save_ok = ok_code.
  CASE save_ok.
    WHEN 'CREA'.
      g_trans_mode = 'N'.
      CLEAR save_ok.
      CALL SCREEN 0300.
    WHEN 'CHAN'.
      g_trans_mode = 'M'.
      CLEAR save_ok.
      CALL SCREEN 0300.
      """""""""""""""""""""""""""
      """"""""added  by lipsy on 12.06.2013 RD1K983016
    WHEN 'RELS'.
      g_trans_mode = 'RL'.
      CLEAR save_ok.
      CALL SCREEN 0300.

    WHEN 'APPR'.
      g_trans_mode = 'AP'.
      CLEAR save_ok.
      CALL SCREEN 0300.
      """"""""""end of addition by lipsy on 12.06.2013 RD1K983016
      """"""""""""""""""""""""""""""""""
    WHEN 'DISP'.
      g_trans_mode = 'D'.
      CLEAR save_ok.                                        "+RK004
*      CLEAR zmm_hvencrt.                                   "-RK004
      CALL SCREEN 0300.
*{+RK004
    WHEN 'DELE'.
      g_trans_mode = 'X'.
      CLEAR save_ok.
      CALL SCREEN 0300.
*}+RK004
    WHEN  'ASSN'.
      g_trans_mode = 'A'.
      CALL SCREEN 0300.
    WHEN 'EXIT' OR 'CANC' OR 'BACK' .
      CLEAR : ist_bdcstatus[], ist_extn[], ist_vend[], g_unblock_vendor.
      """"""""""""""""
      "added by lipsy on 30.05.2013 RD1K983016
      CLEAR:g_block_vendor_att.
      """"""end of addition by lipsy on 30.05.2013 RD1K983016
      """"""""""""""""""""
      REFRESH : ist_bdcstatus[], ist_extn[], ist_vend[].
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0430  INPUT
*&---------------------------------------------------------------------*
*&      Module  REQNO_BL_440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE reqno_bl_440 INPUT.
  CLEAR : ist_req, ist_return_tab.
  REFRESH : ist_req, ist_return_tab.

  SELECT reqno bukrs erfdt ass_flag FROM zmm_vend_block
                     INTO TABLE ist_req WHERE del_flag <> 'X'.

  CASE g_trans_mode.
    WHEN 'A' OR 'M'.
      DELETE ist_req WHERE ass_flag = 'X'.
      DELETE ist_req WHERE reqno = ' '.
  ENDCASE.

  SORT ist_req.
  DELETE ADJACENT DUPLICATES FROM ist_req COMPARING reqno.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'REQNO'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = ist_req
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  zmm_vend_block-reqno = ist_return_tab-fieldval.
ENDMODULE.                 " REQNO_BL_440  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_BUKRS_440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_bukrs_440 INPUT.
  PERFORM validate_bukrs USING zmm_vend_block-bukrs.
  PERFORM get_company_code USING zmm_vend_block-bukrs.

ENDMODULE.                 " VALIDATE_BUKRS_440  INPUT
*&---------------------------------------------------------------------*
*&      Module  FETCH_DATA_UNBL_440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fetch_data_bl_440 INPUT.
  CLEAR ist_bl.
  REFRESH ist_bl.

  SELECT * FROM zmm_vend_block INTO CORRESPONDING FIELDS OF TABLE
                                 ist_zmm_vend_block WHERE
                                 reqno = zmm_vend_block-reqno .
  IF sy-subrc <> 0.
    MESSAGE e218(zmm).
    EXIT.

    """""""""""""""""""""""""""""""""""""
    """""""""added by lipsy on 02.08.2013 for adding release strategy in block RD1K979902
  ELSE.
    IF g_trans_mode = 'RL'.
      READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block
         WITH KEY reqno = zmm_vend_block-reqno zrelease = 'X'.
      IF sy-subrc = 0.
        MESSAGE s943(zmm) WITH wa_zmm_vend_block-reqno.
      ENDIF.
    ELSEIF g_trans_mode = 'AP'.
      READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block
         WITH KEY reqno = zmm_vend_block-reqno zrelease = 'X'.
      IF sy-subrc <> 0.
        MESSAGE e946(zmm) WITH zmm_vend_block-reqno.
      ENDIF.
    ENDIF.


    """""""""""""""""end of add by lipsy on 02.08.2013 for adding release
    """"""""""' strategy in block RD1K979902

    """"""""""""""""""""""""""""""""""""""""""""
  ENDIF.

  CASE g_trans_mode.
    WHEN 'A' OR 'M'.


      """"""""""""""""""""""""
      """""""""added by lipsy on 02.08.2013 for adding release strategy in block RD1K979902
      IF g_trans_mode = 'A'.
        READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block
                                        WITH KEY zapprove = 'X'.
        IF sy-subrc <> 0.
          MESSAGE e365(zmm).
          EXIT.
        ENDIF.
      ENDIF.


      """""""""end of add by lipsy on 02.08.2013 for adding release strategy in block RD1K979902
      """""""""""""""""""""""""""""""
      DELETE ist_zmm_vend_block WHERE ass_flag = 'X' OR
                                      del_flag = 'X'.
      IF ist_zmm_vend_block[] IS INITIAL.
        MESSAGE e742(zmm) WITH zmm_vend_block-reqno.
        EXIT.
      ENDIF.
    WHEN 'X'.
      READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block
                                      WITH KEY ass_flag = 'X'.
      IF sy-subrc = 0.
        MESSAGE e357(zmm).
        EXIT.
      ENDIF.
    WHEN 'D'.

  ENDCASE.

  LOOP AT ist_zmm_vend_block INTO wa_zmm_vend_block.
    MOVE-CORRESPONDING wa_zmm_vend_block TO ist_bl.
    IF zmm_vend_block-sperq IS INITIAL.
      zmm_vend_block-sperq = wa_zmm_vend_block-sperq.
    ENDIF.

    SELECT SINGLE * FROM lfa1 WHERE lifnr = wa_zmm_vend_block-lifnr.

    APPEND ist_bl.
    CLEAR ist_bl.
  ENDLOOP.
ENDMODULE.                 " FETCH_DATA_UNBL_440  INPUT
*&---------------------------------------------------------------------*
*&      Module  ERNAM_FLD_DCLK_440  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ernam_fld_dclk_440 INPUT.
* DATA l_user LIKE soud3.
  CLEAR g_fname.

  GET CURSOR FIELD g_fname.
  CASE g_fname.
    WHEN 'ZMM_HVENCRT-ERNAM'.
      l_user = zmm_hvencrt-ernam.
    WHEN 'ZMM_HVENCRT-RELEASED_BY'.
      l_user = zmm_hvencrt-released_by.
    WHEN 'ZMM_HVENCRT-ASSIGNED_BY'.
      l_user =  zmm_hvencrt-assigned_by.
    WHEN 'ZMM_HVENEXT-ERNAM'.
      l_user = zmm_hvenext-ernam.
    WHEN 'ZMM_VEND_BLOCK-ERNAM'.
      l_user = zmm_vend_block-ernam.
    WHEN 'ZMM_VEND_BLOCK-ASSIGNED_BY'.
      l_user =  zmm_vend_block-assigned_by.
  ENDCASE.
  CALL FUNCTION 'SO_ADDRESS_SHOW'
    EXPORTING
*     DLI_OWNER                  = ' '
*     OWNER                      = ' '
      user                       = l_user
    EXCEPTIONS
      parameter_error            = 1
      user_not_exist             = 2
      x_error                    = 3
      operation_no_authorization = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDMODULE.                 " ERNAM_FLD_DCLK_440  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VENDOR_450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_vendor_450 INPUT.
  IF g_block_vendor = 'X'.
    g_lifnr = ist_bl-lifnr.
  ELSE.
    g_lifnr = ist_extn-lifnr.
  ENDIF.

  SELECT SINGLE * FROM lfa1 INTO ist_lfa1 WHERE
                              lifnr = g_lifnr.

*SELECT single lifnr FROM lfa1 INTO ist_lfa1 where lifnr = g_lifnr.
  IF sy-subrc <> 0.
    MESSAGE e011(zmm) WITH g_lifnr.
    EXIT.
  ELSEIF g_block_vendor = 'X'.


    IF ist_lfa1-sperm = 'X' AND
       ist_lfa1-sperr = 'X' AND
       ist_lfa1-loevm = 'X' AND
       ist_lfa1-sperq = '05'.
      MESSAGE e022(me) WITH 'already'.
    ENDIF.

    ist_bl-sperm = ist_lfa1-sperm.
    ist_bl-sperr = ist_lfa1-sperr.
    ist_bl-loevm = ist_lfa1-loevm.  "291010 by SS

    IF ist_lfa1-sperq = '05'.
      ist_bl-blrfq = 'X'.
    ELSE.
      CLEAR ist_bl-blrfq.
    ENDIF.
* Begin of <> on 28042011
    CONCATENATE ist_bl-sperm ist_bl-sperr ist_bl-blrfq ist_bl-loevm INTO g_strlen1.
* End of <> on 28042011
*+SP006

*    ist_unbl-sperm = ist_lfa1-sperm.                        "-SP006
*    ist_unbl-sperr = ist_lfa1-sperr.                        "-SP006

  ENDIF.

*{- commented as per finance recomm
*  IF NOT ist_lfa1-sperm IS INITIAL AND
*     NOT sy-ucomm EQ 'DELR'.
*    MESSAGE w022(me).
*    CLEAR ist_extn.
*    EXIT.
*  ENDIF.
*{+ startcode for vendor blocking as per finance
  IF NOT g_lifnr IS INITIAL AND g_block_vendor <> 'X'
     AND  sy-dynnr <> '0320'.
    SELECT SINGLE * FROM bsik WHERE lifnr = g_lifnr.
    IF sy-subrc <> 0.
      MESSAGE w022(me).
      CLEAR ist_extn.
      EXIT.
    ENDIF.
  ENDIF.
*{+ endcode for vendor blocking as per finance

  IF NOT g_lifnr IS INITIAL AND g_block_vendor <> 'X'
     AND  sy-dynnr = '0320'.
    IF NOT ist_lfa1-sperm IS INITIAL OR
       NOT ist_lfa1-sperr IS INITIAL.
      MESSAGE w022(me).
      CLEAR ist_extn.
      EXIT.
    ENDIF.
  ENDIF.
* Begin of <> on 291010
*  IF NOT ist_lfa1-loevm IS INITIAL.
*    MESSAGE w740(06) WITH g_lifnr.
*    CLEAR ist_extn.
*    EXIT.
*  ENDIF.
* End of <>
  SELECT SINGLE * FROM  lfb1
                  WHERE lifnr = ist_extn-lifnr
                  AND   bukrs = zmm_hvenext-bukrs.
  IF sy-subrc IS INITIAL.
    MESSAGE w162(f2) WITH ist_extn-lifnr zmm_hvenext-bukrs.
  ENDIF.
ENDMODULE.                 " CHECK_VENDOR_450  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAB_UNBL_450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tab_bl_450 INPUT.
  IF sy-datar = 'X'.
    g_datar = 'X'.
  ENDIF.

*  perform chk_block_flg using g_trans_mode.                 "+SP006

  ist_bl-seqno = tab_bl-current_line.
* Begin of <> on 19042011
  SELECT * FROM zmm_vend_block INTO TABLE ist_zmm_vend_block WHERE lifnr = g_lifnr.
  IF sy-subrc = 0.
    READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH KEY lifnr = g_lifnr ass_flag = ''.
    IF sy-subrc = 0.
      MESSAGE i936(zmm) WITH g_lifnr.
    ENDIF.
  ENDIF.
* End of <> on 19042011
  MODIFY ist_bl INDEX tab_bl-current_line.
  IF sy-subrc <> 0.
    APPEND ist_bl.
  ENDIF.
ENDMODULE.                 " MODIFY_TAB_UNBL_450  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_TEST_MARK_450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_test_mark_450 INPUT.
  IF sy-ucomm = text-099.
    g_ok_code_dele = text-099.
  ENDIF.
*+SP006 - end

* IF ist_unbl-mark = 'X'.                                   "-SP006
  IF ist_bl-mark = 'X' AND g_ok_code_dele = text-099.       "+SP006
    ist_bl-del_flag = 'X'.
    CLEAR ist_bl-mark.
    CLEAR g_ok_code_dele.
  ENDIF.
  MODIFY ist_bl INDEX tab_bl-current_line TRANSPORTING mark del_flag.
ENDMODULE.                 " TC_TEST_MARK_450  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_450 INPUT.
  CASE sy-dynnr.
    WHEN '0220'.
      IF NOT wa_vend IS INITIAL.
        GET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
    WHEN '0450'.
      IF NOT ist_bl[] IS INITIAL AND
         g_cursorfield IS INITIAL.
        GET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " GET_CURSOR_450  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0450 INPUT.
  save_ok = sy-ucomm.
  CASE save_ok.
    WHEN 'DELE'.
*{+rk004
      IF g_trans_mode = 'N'.
        DELETE ist_bl WHERE del_flag = 'X'.
        CLEAR save_ok.
        LOOP AT ist_bl.
          ist_bl-seqno = sy-tabix.
          MODIFY ist_bl TRANSPORTING seqno.
        ENDLOOP.
      ELSE.
        IF NOT ist_bl[] IS INITIAL AND
           g_cursorfield IS INITIAL.
          GET CURSOR FIELD g_cursorfield LINE g_cursorline.
        ENDIF.

*        perform chk_unbl_del_flg using save_ok.             "+SP005

      ENDIF.
*}rk004
*{-rk004
*      DELETE ist_unbl WHERE mark = 'X'.
*      CLEAR save_ok.
*      LOOP AT ist_unbl.
*        ist_unbl-seqno = sy-tabix.
*        MODIFY ist_unbl TRANSPORTING seqno.
*      ENDLOOP.
*}-rk004
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0450  INPUT
*&---------------------------------------------------------------------*
*&      Form  ACTION_BLOCK_REQUEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM action_block_request .
  IF g_trans_mode = 'N'.
    PERFORM check_bl_mandatory_fields.
    PERFORM confirm_bl_user_action USING text-317 text-318.
  ELSEIF g_trans_mode = 'M'.

    """"""""""""""""""""""""""""""""""
    """"""""""added for including release mode by lipsy on 12.06.2013
    CLEAR g_message.
    IF wa_zmm_vend_block-zrelease = 'X' OR wa_zmm_vend_block-zapprove = 'X'.
      CONCATENATE 'Release Strategy will be reset.'
      ' Do you still want to change the request for vendor block?' '' INTO g_message.
    ELSE.

      CONCATENATE 'Do you  want to change the request for vendor block?' '' INTO g_message.
    ENDIF.
    """""""end of addition for release mode by lipsy on 12.06.2013
    """"""""""""""""""""""""""""""""""""""""""""""

    PERFORM check_bl_mandatory_fields.

    """"""""""""""""""""""""""""""""""""""""""
    """""""commented for release mode by lipsy on 12.06.2013

*    PERFORM confirm_bl_user_action USING text-317 text-319.

    "end of comment for release mode by lipsy on 12.06.2013
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """""""""""""""""""""""""""""""""""""""
    """"""""""added for including release mode by lipsy on 12.06.2013

    PERFORM confirm_bl_user_action USING text-317 g_message.
    """""""end of addition for release mode by lipsy on 12.06.2013
    """"""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""
    """"""""""added for including release mode by lipsy on 12.06.2013
  ELSEIF g_trans_mode = 'RL'.
    CLEAR g_message.
    CONCATENATE   'You also confirm that address of the vendor and other details are correct.'
  ' Do you still want to release the request for vendor block?' INTO g_message.
    PERFORM confirm_bl_user_action USING text-317 g_message.   "text-326

  ELSEIF g_trans_mode = 'AP'.
    CLEAR g_message.
    CONCATENATE   'You also confirm that address of the vendor and other details are correct. '
  ' Do you still want to approve the request for vendor block?' INTO g_message.
    PERFORM confirm_user_action USING text-317 g_message.

    """""""end of addition for release mode by lipsy on 12.06.2013
    """""""""""""""""""
  ELSEIF g_trans_mode = 'X'.
    PERFORM confirm_bl_user_action USING text-317 text-320. "+RK004
  ENDIF.
  IF g_ans = '1'.
    PERFORM modify_db_bl.
  ENDIF.

ENDFORM.                    " ACTION_BLOCK_REQUEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_BL_MANDATORY_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bl_mandatory_fields .
  IF ist_bl[] IS INITIAL.
    MESSAGE e055(00).
    EXIT.
  ELSE.
* Begin of <> on 05012011

    LOOP AT ist_bl.
*      READ TABLE ist_bl_temp into wa_bl_temp with key lifnr = ist_bl-lifnr.
*      if sy-subrc = 0.
*        CONCATENATE wa_bl_temp-sperm wa_bl_temp-sperr wa_bl_temp-blrfq wa_bl_temp-loevm into g_strlen1.
*      endif.
      CONCATENATE ist_bl-sperm ist_bl-sperr ist_bl-blrfq ist_bl-loevm INTO g_strlen2.
      IF g_strlen1 <> ''.
        IF strlen( g_strlen1 ) < '4'.
          IF g_strlen2 <= g_strlen1.   "g_strlen2 >= g_strlen1. 19042011 28042011
            MESSAGE e215(zmm).
          ENDIF.
        ENDIF.
      ELSEIF NOT g_strlen2 IS INITIAL.

      ELSE.
        MESSAGE e215(zmm).
      ENDIF.
    ENDLOOP.
* End of <> on 05012011
    LOOP AT ist_bl.
      IF ist_bl-lifnr IS INITIAL OR ist_bl-rsn IS INITIAL.
        IF ist_bl-lifnr IS INITIAL.
          g_cursorfield = 'IST_BL-LIFNR'.
          g_cursorline = sy-tabix.
        ELSE.
          g_cursorfield = 'IST_BL-RSN'.
          g_cursorline = sy-tabix.
        ENDIF.
        MESSAGE e055(00).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECK_BL_MANDATORY_FIELDS
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DB_BL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_db_bl .
  CLEAR :g_crt1, g_req_num.

  IF g_trans_mode = 'N'.
    PERFORM generate_request USING c_nr_object1
                             CHANGING g_req_num.
  ENDIF.
  PERFORM lock_table_bl.
  PERFORM update_zmm_vend_block ON COMMIT.
  IF g_crt1 IS INITIAL.
    COMMIT WORK.
    PERFORM display_message USING g_trans_mode 'S'.
  ELSE.
*    ROLLBACK WORK.
    PERFORM display_message USING g_trans_mode 'A'.
  ENDIF.
  PERFORM unlock_table_bl.

  """""""""""""""""""""""""""""""""""""""""""""""""

  """""""added by lipsy on 27.08.2013 for notes in block
  IF g_trans_mode = 'N' OR  g_trans_mode = 'M' OR g_trans_mode = 'AP' OR g_trans_mode = 'RL'.

    PERFORM save_text.
  ENDIF.

  IF g_trans_mode = 'M' .
    DATA  :  BEGIN OF ist_linetab_read OCCURS 10.
            INCLUDE STRUCTURE tline.
    DATA  :  END OF ist_linetab_read.

    DATA  :  BEGIN OF ist_inlinetab OCCURS 10.
            INCLUDE STRUCTURE tline.
    DATA  :  END OF ist_inlinetab.

    DATA  :  BEGIN OF ist_src OCCURS 500,
               line(132),
             END  OF ist_src.
    DATA: l_theader LIKE thead.
    DATA: l_text(132).
    DATA: l_date(10).

    l_theader-tdid = 'NOTE'..
    l_theader-tdobject = 'ZMMVC'.
    l_theader-tdlinesize = '72'.
    l_theader-tdspras = 'E'.
    """""""""""""""""""""""""



    """""""""""""""""""""""""
    """""added by lipsy on 28.02.2013
    IF zmm_vend_block-reqno IS NOT INITIAL.
      CONCATENATE l_theader-tdid zmm_vend_block-reqno INTO l_theader-tdname.
    ENDIF.
    ""end of addition by lipsy on 28.02.2013
    """""""""""""""""

    """"""""""""""""
    CALL FUNCTION 'READ_TEXT_INLINE'
      EXPORTING
        id           = l_theader-tdid
        inline_count = l_theader-tdlinesize
        language     = l_theader-tdspras
        name         = l_theader-tdname
        object       = l_theader-tdobject
      TABLES
        inlines      = ist_inlinetab
        lines        = ist_linetab_read
      EXCEPTIONS
        id           = 1
        language     = 2
        name         = 3
        not_found    = 4
        object       = 5.

    CLEAR:v_lines_old,v_lines_new.


    DESCRIBE TABLE ist_inlinetab[] LINES v_lines_old.

    DESCRIBE TABLE ist_linetab_temp[] LINES v_lines_new.



    READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH  KEY reqno = zmm_vend_block-reqno.

    IF sy-subrc = 0.
      IF v_lines_new NE v_lines_old.

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """""commented by lipsy on 8.12.2014 for correct work area RD1K994952
*        IF wa_zmm_vend_unblock-REQCLU = 'IR'.
        ""end of comment by lipsy for correct work area on 8.12.2014 RD1K994952
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """""added by lipsy on 8.12.2014 for correct work area RD1K994952
        IF wa_zmm_vend_block-reqclu = 'IR'.
          ""end of addition by lipsy for correct work area on 8.12.2014 RD1K994952

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          IF sy-uname = zmm_vend_block-ernam.
            UPDATE zmm_vend_block  SET reqclu = 'IC'
                                         WHERE reqno = wa_zmm_vend_block-reqno.
          ENDIF.
        ELSEIF wa_zmm_vend_block-reqclu = 'N'.
          UPDATE zmm_vend_block  SET reqclu = 'IC'
                                       WHERE reqno = wa_zmm_vend_block-reqno.

        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.

  """"""""""added by lipsy on 28.02.2013

  """"""""""""""""""""""""""""""""""""""""










  """"""""""""""""""""""""""""""""""""""""""""""""




ENDFORM.                    " MODIFY_DB_BL
*&---------------------------------------------------------------------*
*&      Form  LOCK_TABLE_BL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_table_bl .
  CALL FUNCTION 'ENQUEUE_EZMM_VEND_BL'
    EXPORTING
      mode_zmm_vend_block = 'E'
      mandt               = sy-mandt
      reqno               = zmm_vend_block-reqno
*     SEQNO               =
*     X_REQNO             = ' '
*     X_SEQNO             = ' '
*     _SCOPE              = '2'
*     _WAIT               = ' '
*     _COLLECT            = ' '
    EXCEPTIONS
      foreign_lock        = 1
      system_failure      = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " LOCK_TABLE_BL
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ZMM_VEND_BLOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_zmm_vend_block .
  CLEAR :ist_zmm_vend_block, wa_zmm_vend_block.
  IF NOT ist_bl[] IS INITIAL.
    LOOP AT ist_bl.
      MOVE-CORRESPONDING ist_bl TO wa_zmm_vend_block.
      IF g_trans_mode = 'N'.
        wa_zmm_vend_block-reqno = zmm_vend_block-reqno.
        wa_zmm_vend_block-sperq = zmm_vend_block-sperq.
        wa_zmm_vend_block-bukrs = zmm_vend_block-bukrs.
        wa_zmm_vend_block-erfdt = sy-datum.
        wa_zmm_vend_block-ernam = sy-uname.

        """""""""""""""""""""""""""""""""""""
        "added by lipsy on 19.07.2013 for  adding request status RD1K979902

        wa_zmm_vend_block-reqclu = 'N'.

        """"""end of addition by lipsy on 19.07.2013 for adding request status RD1K979902
        """""""""""""""""""""""""""""""""""


      ELSEIF g_trans_mode = 'M'  .
        wa_zmm_vend_block-reqno = zmm_vend_block-reqno.
        wa_zmm_vend_block-sperq = zmm_vend_block-sperq.
        wa_zmm_vend_block-bukrs = zmm_vend_block-bukrs.
        wa_zmm_vend_block-erfdt = zmm_vend_block-erfdt.
        wa_zmm_vend_block-ernam = zmm_vend_block-ernam.

        """""""""""""""""""""""""""""""""""""""""""""""
        """"added by lipsy on 19.07.2013 for adding request status RD1K979902
        IF wa_zmm_vend_block-zrelease = 'X' OR wa_zmm_vend_block-zapprove = 'X'.
          CLEAR : wa_zmm_vend_block-zrelease,
                  wa_zmm_vend_block-releasedby,
                  wa_zmm_vend_block-releasedon,
                  wa_zmm_vend_block-zapprove,
                  wa_zmm_vend_block-approvedby,
                  wa_zmm_vend_block-approvedon.
        ENDIF.

        wa_zmm_vend_block-reqclu = 'N'.


      ELSEIF g_trans_mode = 'RL'  .
        wa_zmm_vend_block-reqno = zmm_vend_block-reqno.
        wa_zmm_vend_block-sperq = zmm_vend_block-sperq.
        wa_zmm_vend_block-bukrs = zmm_vend_block-bukrs.
        wa_zmm_vend_block-zrelease   = 'X'.
        wa_zmm_vend_block-releasedon = sy-datum.
        wa_zmm_vend_block-releasedby = sy-uname.
        wa_zmm_vend_block-reqclu = 'N'.


      ELSEIF g_trans_mode = 'AP'  .
        """"""""""""""""""""""""""""""""


        """""""""""""""""""""""""""""""""""""


        wa_zmm_vend_block-reqno = zmm_vend_block-reqno.
        wa_zmm_vend_block-sperq = zmm_vend_block-sperq.
        wa_zmm_vend_block-bukrs = zmm_vend_block-bukrs.
        """"""""""""""""""""""
        "added by lipsy on 04.03.2013 for rejection by approver
        IF ist_bl-rejnu = 'Rejected by Approver'.
          PERFORM send_mail_assign.
        ELSE.
          "end of add by lipsy on 04.03.2013 for rejection by approver

          """""""""""""""""""""""""""""""
          wa_zmm_vend_block-zapprove   = 'X'.
          wa_zmm_vend_block-approvedon = sy-datum.
          wa_zmm_vend_block-approvedby = sy-uname.


        ENDIF.

        """"""end of addition by lipsy on 19.07.2013 for adding request status RD1K979902
        """""""""""""""""""""""""""""""""""""""""""

      ELSEIF g_trans_mode = 'A'.

        """"""""""""""""""""""""""""""""""
        """"""""""""""""""""""""""""
        "added by lipsy on 4.03.2013
        IF ist_bl-rejnu = 'Rejected by Assigner'.
          CLEAR:wa_bl_rej.
          READ TABLE ist_bl INTO wa_bl_rej WITH  KEY  rejnu =  'Rejected by Assigner'.
          IF sy-subrc = 0.
            READ TABLE ist_bl INTO wa_bl_rej WITH  KEY  rejnu =  ''.
            IF sy-subrc = 0.
            ELSE.
              g_crt1 = 'X'.
            ENDIF.
          ENDIF.
        ELSE.


          wa_zmm_vend_block-ass_flag   = 'X'.
          "end of addition by lipsy on 4.03.2013

          """"""""""""""""""""""""""


          """""""""""""""""""""""""""""""""
          wa_zmm_vend_block-assigned_by = sy-uname.
          wa_zmm_vend_block-assign_date = sy-datum.


          """"""""""""""""""""""""""""""
          """""""""""""""""
          "added by lipsy on 4.03.2013
        ENDIF.
        "end of addition by lipsy on 4.03.2013
        """""""""""

        """"""""""""""""""""""""""""""""""""""""""


      ENDIF.
      APPEND wa_zmm_vend_block TO ist_zmm_vend_block.
    ENDLOOP.
*{+RK004
    IF g_trans_mode = 'X'.
      DELETE FROM zmm_vend_block
             WHERE reqno = zmm_vend_block-reqno.
*      ENDIF.
      IF sy-subrc <> 0.
        g_crt1 = 'X'.
      ENDIF.
      EXIT.
    ENDIF.
*}+RK004
    IF g_trans_mode = 'M'.
      DELETE FROM zmm_vend_block WHERE reqno = zmm_vend_block-reqno.
      IF sy-subrc <> 0.
        g_crt1 = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
    MODIFY zmm_vend_block FROM TABLE ist_zmm_vend_block.
    IF sy-subrc <> 0.
      g_crt1 = 'X'.

      """""""""""""""""""""""
      """"""added by lipsy on 7.08.2013 for adding
      "release strategy in block
    ELSE.
      IF g_trans_mode = 'RL'.
        MESSAGE i942(zmm) WITH zmm_vend_block-reqno.
      ELSEIF g_trans_mode = 'AP'.
        """""""""""""""""""""""""""""""
        "added by lipsy on 4.03.2013
        CLEAR:wa_bl_rej.
        READ TABLE ist_bl INTO wa_bl_rej WITH  KEY  rejnu = 'Rejected by Approver'.
        IF sy-subrc = 0.
          READ TABLE ist_bl INTO wa_bl_rej WITH  KEY  rejnu =  ''.
          IF sy-subrc = 0.


            "end of addition by lipsy on 4.03.2013

            """"""""""""""""""""""""""""""""""
            MESSAGE i944(zmm) WITH zmm_vend_block-reqno.


            """"""""""""""""""""""""""""""""
            "added by lipsy on 4.03.2013
          ELSE.
          ENDIF.
        ELSE.
          MESSAGE i944(zmm) WITH zmm_vend_block-reqno.
        ENDIF.

      ENDIF.
      "end of addition by lipsy on 4.03.2013




      "end of addition by lipsy on 7.08.2013 for adding
      "release strategy in block

      """""""""""""""""""""""""
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDATE_ZMM_VEND_BLOCK
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_TABLE_BL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unlock_table_bl .
  CALL FUNCTION 'DEQUEUE_EZMM_VEND_BL'
    EXPORTING
      mode_zmm_vend_block = 'E'
      mandt               = sy-mandt
      reqno               = zmm_vend_block-reqno
*     SEQNO               =
*     X_REQNO             = ' '
*     X_SEQNO             = ' '
*     _SCOPE              = '3'
*     _SYNCHRON           = ' '
*     _COLLECT            = ' '
    .
ENDFORM.                    " UNLOCK_TABLE_BL
*&---------------------------------------------------------------------*
*&      Form  CONFIRM_BL_USER_ACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_305  text
*      -->P_TEXT_306  text
*----------------------------------------------------------------------*
FORM confirm_bl_user_action  USING   p_title p_question.
  CLEAR g_ans.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = p_title
      text_question         = p_question
      text_button_1         = 'Yes'(003)
      text_button_2         = 'No'(004)
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = g_ans.
ENDFORM.                    " CONFIRM_BL_USER_ACTION
*&---------------------------------------------------------------------*
*&      Form  BLOCK_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM block_bdc .
  CLEAR g_ans.

  PERFORM confirm_user_action USING text-321 text-322.
  IF g_ans = '1'.
    PERFORM call_bloc_xk02 USING 'B'.
  ENDIF.
ENDFORM.                    " BLOCK_BDC
*&---------------------------------------------------------------------*
*&      Form  CALL_BLOC_XK02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_8442   text
*----------------------------------------------------------------------*
FORM call_bloc_xk02  USING p_flag.
  DATA :
    l_block_str(72),
    l_rowcount(2)   TYPE n,
    g_task_no(20).

  CLEAR :
    ist_bdcdata, ist_bdcstatus, ist_lfa1, g_index.
  REFRESH :
    ist_bdcdata.

  IF p_flag = 'B'.
    LOOP AT ist_bl WHERE del_flag = ' '.
      MOVE-CORRESPONDING ist_bl TO ist_lfa1.

      SELECT SINGLE sperq FROM lfa1 INTO (ist_lfa1-sperq)
                   WHERE lifnr = ist_bl-lifnr.

      IF ist_lfa1-sperq IS INITIAL AND
         ist_bl-blrfq = 'X'.
        ist_lfa1-sperq = '05'.
      ENDIF.
      APPEND ist_lfa1.
    ENDLOOP.
  ENDIF.

  LOOP AT ist_lfa1.

    """"""""""""""""""""""""""""""""""""
    "added by lipsy on 5.08.2013 for block
    CLEAR:wa_bl_rej.
    READ TABLE  ist_bl INTO wa_bl_rej WITH  KEY lifnr = ist_lfa1-lifnr.
    IF sy-subrc = 0.
      IF   wa_bl_rej-rejnu =  'Rejected by Assigner'
        OR wa_bl_rej-rejnu =  'Rejected by Approver'.
      ELSE.

        "end of addition by lipsy on 4.03.2013

        """""""""""""""""""""""""""""""""""""""""""

        PERFORM bdc_dynpro      USING 'SAPMF02K' '0101'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RF02K-D0110'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'RF02K-LIFNR'
                                      ist_lfa1-lifnr.
        PERFORM bdc_field       USING 'RF02K-D0110'
                                      'X'.           "record-D0110_002.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0110'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFA1-NAME1'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=0510'.
*perform bdc_field       using 'LFA1-NAME1'
*                              record-NAME1_003.
*perform bdc_field       using 'LFA1-SORTL'
*                              record-SORTL_004.
*perform bdc_field       using 'LFA1-ORT01'
*                              record-ORT01_005.
*perform bdc_field       using 'LFA1-PSTLZ'
*                              record-PSTLZ_006.
*perform bdc_field       using 'LFA1-LAND1'
*                              record-LAND1_007.
*perform bdc_field       using 'LFA1-REGIO'
*                              record-REGIO_008.
*perform bdc_field       using 'LFA1-SPRAS'
*                              record-SPRAS_009.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0510'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFA1-SPERR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=PF03'.
        PERFORM bdc_field       USING 'LFA1-SPERR'
                                      ist_lfa1-sperr.
        PERFORM bdc_field       USING 'LFA1-SPERM'
                                      ist_lfa1-sperm.
        PERFORM bdc_field       USING 'LFA1-SPERQ'
                                      ist_lfa1-sperq.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0110'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFA1-NAME1'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=0520'.
*perform bdc_field       using 'LFA1-NAME1'
*                              record-NAME1_013.
*perform bdc_field       using 'LFA1-SORTL'
*                              record-SORTL_014.
*perform bdc_field       using 'LFA1-ORT01'
*                              record-ORT01_015.
*perform bdc_field       using 'LFA1-PSTLZ'
*                              record-PSTLZ_016.
*perform bdc_field       using 'LFA1-LAND1'
*                              record-LAND1_017.
*perform bdc_field       using 'LFA1-REGIO'
*                              record-REGIO_018.
*perform bdc_field       using 'LFA1-SPRAS'
*                              record-SPRAS_019.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0520'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFA1-LOEVM'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=UPDA'.
        PERFORM bdc_field       USING 'LFA1-LOEVM'
                                      ist_lfa1-loevm.
*    perform bdc_transaction using 'XK02'.
* Begin of <> on 17022012
        PERFORM background TABLES  ist_bdcstatus2
                                           USING  'XK02'       " s_tcode
                                                  'N'    "'A'  " s_mode
                                                  'A'          " s_update
                                                  zmm_vend_block-reqno
                                                  p_flag.  "#EC CI_USAGE_OK[2226131]
* End of <> on 17022012
        CLEAR :
           ist_unbl,ist_bdcdata,tlinetab,tinlinetab.
        REFRESH :
           ist_bdcdata,tlinetab,tinlinetab.

        IF NOT ist_bdcstatus[] IS INITIAL.
          READ TABLE ist_bdcstatus INDEX 1.
          IF ist_bdcstatus-msgtyp = 'E'.
            MESSAGE e321(zmm) WITH ist_bdcstatus-msgtx.  "Message 042(F2)
          ENDIF.
        ENDIF.

        """""""""""""""""""""""""""""""
        "added by lipsy on 4.03.2013 for  release  strategy in block RD1K979902
      ENDIF.
    ENDIF.
    "end of addition  by lipsy on 4.03.2013 for
    " release strategy in block RD1K979902


    """""""""""""""""""""""""""""""""""
  ENDLOOP.

ENDFORM.                    " CALL_BLOC_XK02
*&---------------------------------------------------------------------*
*&      Form  UPDATE_BL_ZTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_bl_ztable .
  CLEAR :g_crt1.
  CHECK g_ans = 1.
  IF g_vend_err IS INITIAL.
    PERFORM lock_table_bl.
    PERFORM update_zmm_vend_block ON COMMIT.
    IF g_crt1 IS INITIAL.
      COMMIT WORK.
      MESSAGE s730(zmm) WITH zmm_vend_block-reqno.
    ELSE.
      ROLLBACK WORK.
      MESSAGE e735(zmm) WITH text-323.
    ENDIF.
    PERFORM unlock_table_bl.





    """"""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""



    """"""""added by lipsy on 02.08.2013 RD1K979902

    IF g_trans_mode = 'A' OR  g_trans_mode = 'AP' .

      PERFORM save_text.
    ENDIF.

    IF g_trans_mode = 'AP'.
      READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH  KEY  zapprove = 'X'.
      IF sy-subrc = 0.
        UPDATE zmm_vend_block  SET reqclu = 'A'
              WHERE reqno = wa_zmm_vend_block-reqno.

      ENDIF.
    ENDIF.

    IF g_trans_mode = 'A'.

      DATA  :  BEGIN OF ist_linetab_read OCCURS 10.
              INCLUDE STRUCTURE tline.
      DATA  :  END OF ist_linetab_read.

      DATA  :  BEGIN OF ist_inlinetab OCCURS 10.
              INCLUDE STRUCTURE tline.
      DATA  :  END OF ist_inlinetab.

      DATA  :  BEGIN OF ist_src OCCURS 500,
                 line(132),
               END  OF ist_src.
      DATA: l_theader LIKE thead.
      DATA: l_text(132).
      DATA: l_date(10).

      l_theader-tdid = 'NOTE'..
      l_theader-tdobject = 'ZMMVC'.
      l_theader-tdlinesize = '72'.
      l_theader-tdspras = 'E'.
      """""""""""""""""""""""""



      """""""""""""""""""""""""
      """""added by lipsy on 28.02.2013 RD1K979902

      IF zmm_vend_block-reqno IS NOT INITIAL.
        CONCATENATE l_theader-tdid zmm_vend_block-reqno INTO l_theader-tdname.
      ENDIF.
      ""end of addition by lipsy on 28.02.2013 RD1K979902

      """""""""""""""""

      """"""""""""""""
      CALL FUNCTION 'READ_TEXT_INLINE'
        EXPORTING
          id           = l_theader-tdid
          inline_count = l_theader-tdlinesize
          language     = l_theader-tdspras
          name         = l_theader-tdname
          object       = l_theader-tdobject
        TABLES
          inlines      = ist_inlinetab
          lines        = ist_linetab_read
        EXCEPTIONS
          id           = 1
          language     = 2
          name         = 3
          not_found    = 4
          object       = 5.

      DESCRIBE TABLE ist_inlinetab[] LINES v_lines_old.

      DESCRIBE TABLE ist_linetab_temp[] LINES v_lines_new.

      READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH  KEY  ass_flag = ''.

      IF sy-subrc = 0.

        READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH  KEY  ass_flag = 'X'.
* IF wa_zmm_vend_unblock-ass_flag = 'X'.
        IF sy-subrc = 0.
          IF v_lines_new NE v_lines_old.
            UPDATE zmm_vend_block  SET reqclu = 'IR'
                                         WHERE reqno = wa_zmm_vend_block-reqno.

          ELSE.
            UPDATE zmm_vend_block  SET reqclu = 'IC'
                                         WHERE reqno = wa_zmm_vend_block-reqno
                                         AND lifnr = wa_zmm_vend_block-lifnr.
          ENDIF.
        ELSE.
        ENDIF.

        READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block WITH  KEY  rejnu =  'Rejected by Assigner'.
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """""commented by lipsy on 8.12.2014 for correct table RD1K994952
*          UPDATE zmm_vend_unblock  SET REQCLU = 'IR'
*                   where REQNO = wa_zmm_vend_block-reqno.
          """""end of comment by lipsy on 8.12.2014 for correct table RD1K994952

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          """""added by lipsy on 8.12.2014 for correct table RD1K994952
          UPDATE zmm_vend_block  SET reqclu = 'IR'
                   WHERE reqno = wa_zmm_vend_block-reqno.
          """""end of addition by lipsy on 8.12.2014 for correct table RD1K994952


          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          PERFORM send_mail_assign.
        ENDIF.

      ELSE.
        UPDATE zmm_vend_block  SET reqclu = 'C'
                                     WHERE reqno = zmm_vend_block-reqno .

      ENDIF.

      IF g_crt1 IS INITIAL.
        MESSAGE s730(zmm) WITH zmm_vend_block-reqno.
      ENDIF.

    ENDIF.

    "end of addition by lipsy on 28.02.2013 RD1K979902

    """""""""""""





    """""""""""""""""""""""""""""""""""""""""""""""""""""""


  ENDIF.
ENDFORM.                    " UPDATE_BL_ZTABLE
*&---------------------------------------------------------------------*
*&      Module  RSN_BL_0420  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE rsn_unbl_0420 INPUT.
  CLEAR : ist_rsn, ist_return_tab.
  REFRESH : ist_rsn, ist_return_tab.

  SELECT zreason  FROM zmm_vms_reason   "blk_unblk   080911
                     INTO TABLE ist_rsn WHERE blk_unblk = 'U'.

  SORT ist_rsn.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'REQNO'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      value_org       = 'S'
    TABLES
      value_tab       = ist_rsn
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ist_unbl-rsn = ist_return_tab-fieldval.  "zmm_vend_unblock-rsn
ENDMODULE.                 " RSN_UNBL_0420  INPUT
*&---------------------------------------------------------------------*
*&      Module  RSN_BL_0450  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE rsn_bl_0450 INPUT.
  CLEAR : ist_rsn, ist_return_tab.
  REFRESH : ist_rsn, ist_return_tab.

  SELECT  zreason  FROM zmm_vms_reason                         "blk_unblk 06012012
                     INTO TABLE ist_rsn WHERE blk_unblk = 'B'.
  IF sy-subrc = 0.   "SS 06012012
    SORT ist_rsn.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'REQNO'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        value_org       = 'S'
      TABLES
        value_tab       = ist_rsn
        return_tab      = ist_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    ist_bl-rsn = ist_return_tab-fieldval.
  ENDIF.
ENDMODULE.                 " RSN_BL_0450  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_319  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_319 INPUT.
  g_okcode319 = sy-ucomm.
  CASE g_okcode319.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " EXIT_319  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EMAIL_ENRTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_email_enrty INPUT.

  DATA : l_mailid TYPE zmm_dvencrt-email.

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919

**Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
*if  ZMM_HVENCRT-KTOKK <> 'LAQ1'.
**END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572

  IF ( zmm_hvencrt-ktokk <> 'LAQ1' AND zmm_hvencrt-ktokk <> 'NOMI'  AND zmm_hvencrt-ktokk <> 'SHYG').

*End RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586


    IF NOT wa_vend-vend-email IS INITIAL.
      FIND FIRST OCCURRENCE OF '@' IN wa_vend-vend-email IN CHARACTER MODE.

      IF sy-subrc = 0.

        FIND FIRST OCCURRENCE OF '.' IN wa_vend-vend-email IN CHARACTER MODE.

        IF sy-subrc <> 0.

          """""""""""""""""""""""
          "add by lipsy
          IF sy-ucomm = 'MODF'.

          ELSE.
            "eadd by lipsy
            """"""""""""""""""""""
            MESSAGE e810(zmm).

            """""""""""""
            "add by lipsy
          ENDIF.
          "eadd by lipsy

          """""""""""""""""""""""""
* Check space in mail id, if found flash error.
        ELSE.

          MOVE wa_vend-vend-email  TO l_mailid.

          CONDENSE l_mailid NO-GAPS.

          IF wa_vend-vend-email NE l_mailid.

            MESSAGE e810(zmm).

          ENDIF.


        ENDIF.

      ELSE.

        MESSAGE e810(zmm).

      ENDIF.
    ENDIF.

*Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
  ENDIF.
*END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572


ENDMODULE.                 " CHECK_EMAIL_ENRTY  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0531  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0531 INPUT.
  g_okcode531 = sy-ucomm.
  CASE g_okcode531.
      CLEAR : g_tc531_copied,                               "29082011
              g_tc109_copied,
              g_okcode531, sy-ucomm.                        "270911
      g_tc531_itab[] = g_tc531_itab_temp[].
      REFRESH CONTROL 'TC531' FROM SCREEN '0531'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " EXIT_0531  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EMAIL_ENTRY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_email_entry INPUT.
*  DATA : l_mailid type ZMM_DVENCRT-email.
  CLEAR l_mailid.
  IF NOT ist_unbl-email IS INITIAL.
    FIND FIRST OCCURRENCE OF '@' IN ist_unbl-email IN CHARACTER MODE.

    IF sy-subrc = 0.

      FIND FIRST OCCURRENCE OF '.' IN ist_unbl-email IN CHARACTER MODE.

      IF sy-subrc <> 0.


        """""""""""""""""""
        "added by lipsy on 1.1.2016
        IF sy-ucomm = 'DELE'.
        ELSE.
          "eadd by lipsy on 1.1.2016
          """""""""""""""""""""""""""""""
          MESSAGE e810(zmm).


          """""""""""""""""""
          "added by lipsy on 1.1.2016
        ENDIF.

        "eadd by lipsy on 1.1.2016
        """"""""""""""""""""""""""

* Check space in mail id, if found flash error.
      ELSE.

        MOVE ist_unbl-email  TO l_mailid.

        CONDENSE l_mailid NO-GAPS.

        IF ist_unbl-email NE l_mailid.

          MESSAGE e810(zmm).

        ENDIF.


      ENDIF.

    ELSE.

      MESSAGE e810(zmm).

    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_EMAIL_ENTRY  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_0109  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0109 INPUT.
  g_okcode109 = sy-ucomm.
  CASE g_okcode109.

    WHEN 'BACK'.
      CLEAR :  g_okcode931 , g_tc109_copied.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDMODULE.                 " EXIT_0109  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_ATTACH_FILES_531
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_attach_files_531 .
  LOOP AT g_tc319_itab INTO g_tc319_wa.
    IF NOT g_tc319_wa-bankl     IS INITIAL AND    "zfivmsbank
         NOT g_tc319_wa-bankn     IS INITIAL AND
         NOT g_tc319_wa-koinh     IS INITIAL AND
         NOT g_tc319_wa-bankl_new IS INITIAL AND
         NOT g_tc319_wa-bankn_new IS INITIAL AND
         NOT g_tc319_wa-koinh_new IS INITIAL.
      IF g_tc319_wa-attach <> 'X'.
        MESSAGE w419(zfi) WITH g_tc319_wa-lifnr.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_ATTACH_FILES_531
*&---------------------------------------------------------------------*
*&      Module  HOF_REMARKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE hof_remarks INPUT.
  MOVE-CORRESPONDING zfivmsbank TO g_tc531_wa.
  IF NOT g_reject IS INITIAL.
    CASE g_okcode931.
      WHEN 'APPROVED'.
        IF  zfivmsbank-hof_zremarks IS INITIAL.
          MESSAGE e934(zmm).
        ENDIF.

      WHEN 'RELEASE'.
        IF zfivmsbank-vmc_zremarks IS INITIAL.
          MESSAGE e934(zmm).
        ENDIF.
    ENDCASE.
  ENDIF.
ENDMODULE.                 " HOF_REMARKS  INPUT
*&---------------------------------------------------------------------*
*&      Form  DISP_PROCESS_GUIDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM disp_process_guide .
  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
  DATA : wa_att_files LIKE swotobjid.
  DATA l_obj TYPE sood4-objno.

  wa_att_files-logsys  = 'AS'         ."'01'. on 07082012
  wa_att_files-objtype = 'VENDOR'.
  wa_att_files-objkey  = 'AS931'.

  REFRESH ist_exclude_tab[].
  MOVE 'ENTR' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CHNG' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'CREA' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'DELE' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'IMPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'EXPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'OLNK' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'PRIN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'COPY' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'HGEN' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'REFL' TO ist_exclude_tab. APPEND ist_exclude_tab.
  MOVE 'MOVE' TO ist_exclude_tab. APPEND ist_exclude_tab.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files
    TABLES
      func_exclude       = ist_exclude_tab.
*    docno_lifnr = 'AS931'.
*    g_att_files_wa-LOGSYS  = '01'.
*    g_att_files_wa-objtype = 'VENDOR'.
*    g_att_files_wa-objkey  = docno_lifnr.
*
*    Append g_att_files_wa to g_att_files.
*    CALL FUNCTION  'ZSO_WIND_ATTACHMENT_CREAT_API1'
*      EXPORTING
*        ATTACHMENT_DATA     = ''
*        ATTACHMENT_TYPE     = 'DOC'
*      IMPORTING
*        ATTACH_OBJ          = L_OBJ
*      TABLES
*        APPLICATION_OBJECTS = g_att_files.
ENDFORM.                    " DISP_PROCESS_GUIDE
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXISTANCE_OF_BANKN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_existance_of_bankn .
  READ TABLE g_tc319_itab INTO g_tc319_wa_as INDEX tc319-current_line.  "#EC CI_NOORDER


ENDFORM.                    " CHECK_EXISTANCE_OF_BANKN
*&---------------------------------------------------------------------*
*&      Form  UPDATE_FK02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_fk02 .
*if ZFIVMSBANK-CCODE <> 'OVC'.
  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0106'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'RF02K-D0130'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field_s       USING 'RF02K-LIFNR'
                                zfivmsbank-lifnr.  "record-LIFNR_001.
  PERFORM bdc_field_s       USING 'RF02K-D0130'
                                'X'.               "record-D0130_002.
  PERFORM bdc_dynpro_s      USING 'SAPMF02K' '0130'.
  PERFORM bdc_field_s       USING 'BDC_CURSOR'
                                'LFBK-KOINH(01)'.
  PERFORM bdc_field_s       USING 'BDC_OKCODE'
                                '=UPDA'.
*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*  perform bdc_field_s       using 'LFA1-XZEMP'
*                                'X'.                "record-XZEMP_003.

  DATA: l_ktokk TYPE lfa1-ktokk.
  SELECT SINGLE ktokk FROM lfa1
    INTO l_ktokk
      WHERE lifnr = zfivmsbank-lifnr.

  IF l_ktokk = 'NOMI' OR l_ktokk = 'SHYG'.
  ELSE.
    PERFORM bdc_field_s       USING 'LFA1-XZEMP'
                                  'X'.                "record-XZEMP_003.
  ENDIF.
*End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586

******************* 3.2.2021
  DATA: lv_count TYPE n LENGTH 2.
  TYPES: BEGIN OF ty_bank,
           bankl_new TYPE zfivmsbank-bankl_new,
           bankn_new TYPE zfivmsbank-bankn_new,
           koinh_new TYPE zfivmsbank-koinh_new,
           zbnkt     TYPE zfivmsbank-zbnkt,
         END OF ty_bank.
  DATA: lv_rec(4),
        lv_data(14).
  DATA: wa_tab  TYPE lfbk,
        it_bank TYPE TABLE OF ty_bank,
        wa_bank TYPE ty_bank.

  REFRESH it_bank[].
  IF  zfivmsbank-zbnkt EQ ' '.
    SELECT * FROM lfbk INTO TABLE @DATA(it_tab) WHERE lifnr = @zfivmsbank-lifnr.  "#EC CI_NOORDER
    IF sy-subrc = 0.

      wa_bank-bankl_new = zfivmsbank-bankl_new.
      wa_bank-bankn_new = zfivmsbank-bankn_new.
      wa_bank-koinh_new = zfivmsbank-koinh_new.
      wa_bank-zbnkt     = zfivmsbank-zbnkt.
      APPEND wa_bank TO it_bank.

      LOOP AT it_tab INTO wa_tab WHERE bvtyp IS NOT INITIAL.
        wa_bank-bankl_new = wa_tab-bankl.
        wa_bank-bankn_new = wa_tab-bankn.
        wa_bank-koinh_new = wa_tab-koinh.
        wa_bank-zbnkt     = wa_tab-bvtyp.
        APPEND wa_bank TO it_bank.
      ENDLOOP.


    ENDIF.

    IF it_bank[] IS INITIAL.
      wa_bank-bankl_new = zfivmsbank-bankl_new.
      wa_bank-bankn_new = zfivmsbank-bankn_new.
      wa_bank-koinh_new = zfivmsbank-koinh_new.
      wa_bank-zbnkt     = zfivmsbank-zbnkt.
      APPEND wa_bank TO it_bank.

    ENDIF.

*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKS(01)'
*                                       'IN'.               "record-BANKS_01_004.
*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKL(01)'
*                                  ZFIVMSBANK-BANKL_NEW.  "record-BANKL_01_005.
*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKN(01)'
*                                  ZFIVMSBANK-BANKN_NEW.   "record-BANKN_01_006.
*    PERFORM BDC_FIELD_S       USING 'LFBK-KOINH(01)'
*                                  ZFIVMSBANK-KOINH_NEW.   "record-KOINH_01_007.
*
*    PERFORM BDC_FIELD_S       USING 'LFBK-BVTYP(01)'
*                                  ZFIVMSBANK-ZBNKT.

    LOOP AT it_bank INTO wa_bank.

      lv_count = lv_count + 1.
      CONCATENATE '(' lv_count ')' INTO lv_rec.
      CLEAR lv_data.
      CONCATENATE 'LFBK-BANKS' lv_rec INTO lv_data.
      IF zfivmsbank-ccode = 'OVL'.
        PERFORM bdc_field_s       USING   lv_data    "'LFBK-BANKS'lv_rec
                                      'IN'.               "record-BANKS_01_004.
      ELSEIF zfivmsbank-ccode = 'OVC'.
        PERFORM bdc_field_s       USING   lv_data    "'LFBK-BANKS'lv_rec
                                       'CO'.               "record-BANKS_01_004.
      ENDIF.
      CLEAR lv_data.
      CONCATENATE 'LFBK-BANKL' lv_rec INTO lv_data.
      PERFORM bdc_field_s       USING lv_data   "'LFBK-BANKL'lv_rec
                                    wa_bank-bankl_new.  "record-BANKL_01_005.

      CLEAR lv_data.
      CONCATENATE 'LFBK-BANKN' lv_rec INTO lv_data.
      PERFORM bdc_field_s       USING  lv_data  "'LFBK-BANKN'lv_rec
                                    wa_bank-bankn_new.   "record-BANKN_01_006.

      CLEAR lv_data.
      CONCATENATE 'LFBK-KOINH' lv_rec INTO lv_data.
      PERFORM bdc_field_s       USING  lv_data   "'LFBK-KOINH'lv_rec
                                    wa_bank-koinh_new.   "record-KOINH_01_007.

      CLEAR lv_data.
      CONCATENATE 'LFBK-BVTYP' lv_rec INTO lv_data.
      PERFORM bdc_field_s       USING lv_data "'LFBK-BVTYP'lv_rec
                                    wa_bank-zbnkt.   "added by ss.
    ENDLOOP.
  ELSE.
    SELECT COUNT(*)  FROM lfbk INTO lv_count WHERE lifnr EQ zfivmsbank-lifnr. " BOC by SS
** BOC on 20.4.21 by ss for adding records on scroll down i.e more than 5 records.
    IF lv_count > 05.
      PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFBK-BANKS(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
*     perform bdc_field       using 'LFA1-XZEMP'
*                                   record-XZEMP_004.

      PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFBK-BANKS(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.

      lv_count = 04.
    ENDIF.
** EOC
*  IF SY-SUBRC = 0.
    lv_count = lv_count + 1.
    CONCATENATE '(' lv_count ')' INTO lv_rec.
    CLEAR lv_data.
    CONCATENATE 'LFBK-BANKS' lv_rec INTO lv_data.
    IF zfivmsbank-ccode = 'OVL'.
      PERFORM bdc_field_s       USING   lv_data    "'LFBK-BANKS'lv_rec
                                    'IN'.               "record-BANKS_01_004.
    ELSEIF zfivmsbank-ccode = 'OVC'.
      PERFORM bdc_field_s       USING   lv_data    "'LFBK-BANKS'lv_rec
                                  'CO'.               "record-BANKS_01_004.
    ENDIF.

    CLEAR lv_data.
    CONCATENATE 'LFBK-BANKL' lv_rec INTO lv_data.
    PERFORM bdc_field_s       USING lv_data   "'LFBK-BANKL'lv_rec
                                  zfivmsbank-bankl_new.  "record-BANKL_01_005.

    CLEAR lv_data.
    CONCATENATE 'LFBK-BANKN' lv_rec INTO lv_data.
    PERFORM bdc_field_s       USING  lv_data  "'LFBK-BANKN'lv_rec
                                  zfivmsbank-bankn_new.   "record-BANKN_01_006.

    CLEAR lv_data.
    CONCATENATE 'LFBK-KOINH' lv_rec INTO lv_data.
    PERFORM bdc_field_s       USING  lv_data   "'LFBK-KOINH'lv_rec
                                  zfivmsbank-koinh_new.   "record-KOINH_01_007.

    CLEAR lv_data.
    CONCATENATE 'LFBK-BVTYP' lv_rec INTO lv_data.
    PERFORM bdc_field_s       USING lv_data "'LFBK-BVTYP'lv_rec
                                  zfivmsbank-zbnkt.   "added by ss.
    "EOC by ss


  ENDIF. "" SS ... end.
*
*ELSE.
*
*PERFORM BDC_DYNPRO_S      USING 'SAPMF02K' '0106'.
*  PERFORM BDC_FIELD_S       USING 'BDC_CURSOR'
*                                'RF02K-D0130'.
*  PERFORM BDC_FIELD_S       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM BDC_FIELD_S       USING 'RF02K-LIFNR'
*                                ZFIVMSBANK-LIFNR.  "record-LIFNR_001.
*  PERFORM BDC_FIELD_S       USING 'RF02K-D0130'
*                                'X'.               "record-D0130_002.
*  PERFORM BDC_DYNPRO_S      USING 'SAPMF02K' '0130'.
*  PERFORM BDC_FIELD_S       USING 'BDC_CURSOR'
*                                'LFBK-KOINH(01)'.
*  PERFORM BDC_FIELD_S       USING 'BDC_OKCODE'
*                                '=UPDA'.
**Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
**Begin RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
**  perform bdc_field_s       using 'LFA1-XZEMP'
**                                'X'.                "record-XZEMP_003.
*
**  DATA: L_KTOKK TYPE LFA1-KTOKK.
*  SELECT SINGLE KTOKK FROM LFA1
*    INTO L_KTOKK
*      WHERE LIFNR = ZFIVMSBANK-LIFNR.
*
*  IF L_KTOKK = 'NOMI' OR L_KTOKK = 'SHYG'.
*  ELSE.
*    PERFORM BDC_FIELD_S       USING 'LFA1-XZEMP'
*                                  'X'.                "record-XZEMP_003.
*  ENDIF.
**End RD1K995096 CAB_ALOK  ZMMVMS: Modifications regarding NOMI - CR 30011919
**End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*
*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKS(01)'
*                                       'CO'.               "record-BANKS_01_004.
*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKL(01)'
*                                  ZFIVMSBANK-BANKL_NEW.  "record-BANKL_01_005.
*    PERFORM BDC_FIELD_S       USING 'LFBK-BANKN(01)'
*                                  ZFIVMSBANK-BANKN_NEW.   "record-BANKN_01_006.
*    PERFORM BDC_FIELD_S       USING 'LFBK-KOINH(01)'
*                                  ZFIVMSBANK-KOINH_NEW.   "record-KOINH_01_007.
*
*    PERFORM BDC_FIELD_S       USING 'LFBK-BVTYP(01)'
*                                  ZFIVMSBANK-ZBNKT.



*ENDIF.
  PERFORM bdc_transaction USING 'FK02'.  "#EC CI_USAGE_OK[2226131]

ENDFORM.                    " UPDATE_FK02
*&---------------------------------------------------------------------*
*&      Module  CHECK_MOBILE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mobile INPUT.
***if ZMM_HVENCRT-KTOKK  = 'IMMI' OR ZMM_HVENCRT-KTOKK  = 'SVWI' .
*** l_len_mob = strlen( WA_VEND-VEND-MOB_NUMBER ).
***
*** if l_len_mob ne 10.
***   message 'ENTER 10 digit mobile number' TYPE 'E'.
***  ENDIF.
***  ENDIF.

  DATA:  l_mob_num TYPE  zmm_dvencrt-mob_number.
  IF zmm_hvencrt-ktokk  = 'IMMI' OR zmm_hvencrt-ktokk  = 'SVWI' .
    l_len_mob = strlen( wa_vend-vend-mob_number ).
    l_mob_num =  wa_vend-vend-mob_number.

    IF l_len_mob EQ 10 AND l_mob_num CO ' 0123456789'." edited by cab_dns

    ELSE.
      MESSAGE 'ENTER 10 digit mobile number' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_MOBILE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CORRES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_corres INPUT.
  IF ok_code = 'LOGG'.
    CALL SCREEN 0600 STARTING AT 85 05 ENDING AT 148 23.
  ENDIF.

ENDMODULE.                 " GET_CORRES  INPUT
*&---------------------------------------------------------------------*
*&      Module  REJNU_UNBL_0420  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE rejnu_unbl_0420 INPUT.
  CLEAR: l_list.
  l_name = 'IST_UNBL-REJNU'.

  l_value-key  = 'Rejected by Assigner'.
*   l_value-text = 'Rupees'.
  APPEND l_value TO l_list.

  l_value-key  = 'Rejected by Approver'.
*   l_value-text = 'Dollars'.
  APPEND l_value TO l_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = l_name
      values = l_list.
ENDMODULE.                 " REJNU_UNBL_0420  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TAB_UNBL_REJ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_tab_unbl_rej INPUT.
  MODIFY ist_unbl INDEX tab_unbl-current_line.
ENDMODULE.                 " MODIFY_TAB_UNBL_REJ  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_PAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_pan INPUT.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*  DATA : l_panno  LIKE j_1imovend-j_1ipanno.
  DATA : l_panno  LIKE lfa1-j_1ipanno.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  DATA : l_len1 TYPE i .

******************** Start of comment by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*******************

*****       g_pan_wa      type j_1imovend.

******************** End of comment by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*******************
**begin of change by ss on 22.3.21
  IF zmm_hvencrt-bukrs <> 'OVC'.
    CLEAR l_panno.
    CLEAR l_len1.
    IF zmm_hvencrt-ktokk = 'IMMI' OR zmm_hvencrt-ktokk = 'SVWI'. ". OR zmm_hvencrt-ktokk = 'SVWF'."added svwf   " only if validation added on 06012015
*if save_ok = 'SAVE'  or save_ok = 'ASSN'.
      IF save_ok = 'SAVE' .
        l_panno = wa_vend-vend-j_1ipanno.
        l_len1 = strlen( l_panno ).
        IF l_len1 <> 10.
          MESSAGE e415(zfi) .
        ENDIF.
        IF l_panno+0(5) CN sy-abcde.
          MESSAGE  e414(zfi) WITH 'First 5 chars should be Alphabets'.
        ENDIF.
        IF  l_panno+5(4) CN '0123456789'.
          MESSAGE e414(zfi) WITH '6th to 9th Chars should be Numeric'.
        ENDIF.
        IF l_panno+9(1) CN sy-abcde.
          MESSAGE  e414(zfi) WITH 'Last Character should be Alphabets'.
        ENDIF.
*********************************************************************************
*      BREAK-POINT.
*     IF WA_VEND-VEND-VEN_CLASS NE '0'.
*
*      IF wa_VEND-VEND-GST_NO+0(2) NE wa_VEND-VEND-REGIO.
*
*         MESSAGE 'First two chars of GST No. should be Region code' TYPE 'E'.
*
*       ELSEIF wa_VEND-VEND-GST_NO+2(10) NE  wa_VEND-VEND-J_1IPANNO.
*
*         MESSAGE '3rd to 12th Chars of GST No. should be equal to Pan No.' TYPE 'E'.
*
*       ENDIF.
*
*     ENDIF.
*********************************************************************************
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*        SELECT SINGLE * FROM j_1imovend INTO g_pan_wa
*          WHERE  j_1ipanno =  wa_vend-vend-j_1ipanno.
        SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa
          WHERE  j_1ipanno =  wa_vend-vend-j_1ipanno.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
        IF sy-subrc = 0.


******************** Start of addition by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*****************************

          PERFORM confirm_user_pan USING text-015 text-061.
          g_ans_pan = '1'.
        ELSE.
          g_ans_pan = '3'." This is for regular working for Save.
        ENDIF.

        IF g_ans_pan = '1' OR  g_ans_pan = '3' .

*******************end of Addition by Anamika by on 25.02.2015 for Warning message for pan  RD1K996460*************************


          CLEAR:count_pan.
          LOOP AT ist_vend INTO wa_vend_pan WHERE vend-j_1ipanno =  wa_vend-vend-j_1ipanno .
            count_pan  = count_pan + 1.
          ENDLOOP.

          IF count_pan  > '1'.
            MESSAGE e161(zmm_oth).
          ENDIF.




******************** Start of addition by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*********
        ELSE.
          CALL SCREEN 0200.
        ENDIF.
******************** End of addition by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*********



*  endif.

******************** Start of addition by  Anamika on 27.02.2015 for Warning message for pan  RD1K996460*********
      ELSEIF save_ok = 'ASSN' .
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: CIN vendor master J_1IMOVEND merged into LFA1 (SAP Note 2627221) - read redirected to LFA1.
*        SELECT SINGLE * FROM j_1imovend INTO g_pan_wa
*          WHERE  j_1ipanno =  wa_vend-vend-j_1ipanno.
        SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF g_pan_wa
          WHERE  j_1ipanno =  wa_vend-vend-j_1ipanno.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
        IF sy-subrc = 0.

          PERFORM confirm_user_pan USING text-015 text-061.
        ELSE.
          g_ans_pan = '3'." This is for regular working for Save.
        ENDIF.

        IF g_ans_pan = '1' OR  g_ans_pan = '3' .
        ELSE.
          CALL SCREEN 0200.
        ENDIF.



******************** End of addition by  Anamika on 27.02.2015 for Warning message for pan  RD1K996460*********



      ENDIF.
    ENDIF.
  ENDIF. "added by ss on 22.3.21
ENDMODULE.                 " VALIDATE_PAN  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_POSTAL_UNBLOCK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_postal_unblock INPUT.

  IF ist_unbl-lifnr IS NOT INITIAL AND ist_unbl-pstlz IS NOT INITIAL
                            AND   ist_unbl-land1 IS NOT INITIAL
                              AND ist_unbl-regio IS  NOT INITIAL.
    PERFORM postal_check USING ist_unbl-pstlz
                               ist_unbl-land1
                               ist_unbl-regio.
  ENDIF.

ENDMODULE.                 " CHECK_POSTAL_UNBLOCK  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_152  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_152 INPUT.
  g_okcode152 = sy-ucomm.
  CASE g_okcode152.
    WHEN 'BACK' OR 'CANC'.

      CLEAR: g_srch_flag,
             g_okcode152.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' .

      CLEAR  g_srch_flag.
      CLEAR:  g_okcode152.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " EXIT_152  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0152  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0152 INPUT.
  CLEAR  g_srch_flag.

  CASE g_okcode152.

    WHEN 'ENTER'.
      IF zfivmsbank-reqno IS NOT INITIAL.
        g_srch_flag = 'X'.
      ENDIF.

      CLEAR: g_okcode152.
      LEAVE  TO SCREEN  0.
    WHEN 'CANC'.
      CLEAR: g_okcode152.
      LEAVE TO  SCREEN 0.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0152  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC109_REQUESTNO_SEARCH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc109_requestno_search OUTPUT.
  PERFORM tc109_request_search.
ENDMODULE.                 " TC109_REQUESTNO_SEARCH  OUTPUT

*+SP015 : Start
*&---------------------------------------------------------------------*
*&      Module  CANCEL_0700  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0700 INPUT.

  save_ok = g_ok_code_700.

  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code_700.
      LEAVE TO SCREEN 100.
  ENDCASE.

ENDMODULE.                 " CANCEL_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_GLOBAL_VAR_0700  INPUT
*&---------------------------------------------------------------------*
* To initialize global variables
*----------------------------------------------------------------------*
MODULE init_global_var_0700 INPUT.

  REFRESH CONTROL 'VMS_CTRL_TP' FROM SCREEN 0750.

  REFRESH : ist_zmm_vms_tp_set,
            ist_upd_vnd_rp_dtl.

  CLEAR : wa_zmm_vms_tp_set,
          wa_zmm_vms_tp_set_tc,
          wa_upd_vnd_rp_dtl.

ENDMODULE.                 " INIT_GLOBAL_VAR_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
* To call screen 0750
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.

  CASE g_ok_code_700.

    WHEN 'SRP'.                   "Set Related Partner

      PERFORM fetch_lifnr USING g_ok_code_700.

    WHEN 'RRP'.                   "Release Related Partner

      PERFORM fetch_lifnr USING g_ok_code_700.

    WHEN 'ARPC'.                   "Approve Related Partner (C1)

      PERFORM auth_check_l1 USING g_ok_code_700.

      PERFORM fetch_lifnr USING g_ok_code_700.

    WHEN 'ARP'.                   "Approve Related Partner(L1)

      PERFORM auth_check_l1 USING g_ok_code_700.

      PERFORM fetch_lifnr USING g_ok_code_700.

    WHEN 'RPPG'.                "Process Guide : Related Party

      PERFORM disp_rp_process_guide.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0750  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0750 INPUT.

  save_ok = ok_code.

  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code_700.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " CANCEL_0750  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control_0750  INPUT
*&---------------------------------------------------------------------*
*  Move table control table data into internal table ist_zpm_dpr_mw
*----------------------------------------------------------------------*
MODULE read_table_control_0750 INPUT.

  GET CURSOR FIELD g_curs_name VALUE g_lifnr_750.

  MOVE-CORRESPONDING wa_zmm_vms_tp_set_tc TO wa_zmm_vms_tp_set.

  MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
              INDEX vms_ctrl_tp-current_line.

ENDMODULE.                 " read_table_control_0750  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0750  INPUT
*&---------------------------------------------------------------------*
* To perform actions like commit/check/unchecked/select all/deselect
* all etc
*----------------------------------------------------------------------*
MODULE user_command_0750 INPUT.

  CASE g_ok_code_700.

    WHEN 'SRP'. "Set Related Party

      save_ok = ok_code.

      CLEAR ok_code.

      CASE save_ok.

        WHEN 'SAVE'.

          PERFORM save_rp_details USING g_ok_code_700.

        WHEN 'SEL'. "Select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            wa_zmm_vms_tp_set-sel = 'X'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'DSEL'. "De select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            CLEAR wa_zmm_vms_tp_set-sel.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'CHKA'. "Check all related party

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

*           wa_zmm_vms_tp_set-rel_partner_flg = 'X'.
            wa_zmm_vms_tp_set-rel_partner_flg = 'Y'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING rel_partner_flg.

          ENDLOOP.

        WHEN 'UCHK'. "Uncheck all related party

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

*           CLEAR wa_zmm_vms_tp_set-rel_partner_flg.
            wa_zmm_vms_tp_set-rel_partner_flg = 'N'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING rel_partner_flg.

          ENDLOOP.

        WHEN 'BLNK'. "Uncheck all related party

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            CLEAR wa_zmm_vms_tp_set-rel_partner_flg.


            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING rel_partner_flg.

          ENDLOOP.

        WHEN 'FIND'. "Find Vendor

          PERFORM get_rp_vendor.

        WHEN 'DEVC'. "Get Vendor Code Details

*Get Vendor Code Details
          IF NOT g_lifnr_750 IS INITIAL.

            READ TABLE ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set
                          WITH KEY lifnr  = g_lifnr_750.

            IF sy-subrc = 0.

              SET PARAMETER ID 'LIF' FIELD g_lifnr_750.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor MK03 not available (Business Partner). Open vendor BP in display via BP navigation.
*              CALL TRANSACTION 'MK03'.
              PERFORM zz_s4_show_vendor_bp USING g_lifnr_750.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

            ENDIF.

            CLEAR g_lifnr_750.

          ENDIF.

      ENDCASE.

    WHEN 'RRP'.  "Release Related Party

      save_ok = ok_code.

      CLEAR ok_code.

      CASE save_ok.

        WHEN 'SAVE'.

          PERFORM save_rp_details USING g_ok_code_700.

        WHEN 'SEL'. "Select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            wa_zmm_vms_tp_set-sel = 'X'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'DSEL'. "De select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            CLEAR wa_zmm_vms_tp_set-sel.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'FIND'. "Find Vendor

          PERFORM get_rp_vendor.

        WHEN 'DEVC'. "Get Vendor Code Details

*Get Vendor Code Details
          IF NOT g_lifnr_750 IS INITIAL.

            READ TABLE ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set
                          WITH KEY lifnr  = g_lifnr_750.

            IF sy-subrc = 0.

              SET PARAMETER ID 'LIF' FIELD g_lifnr_750.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor MK03 not available (Business Partner). Open vendor BP in display via BP navigation.
*              CALL TRANSACTION 'MK03'.
              PERFORM zz_s4_show_vendor_bp USING g_lifnr_750.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

            ENDIF.

            CLEAR g_lifnr_750.

          ENDIF.

      ENDCASE.

    WHEN 'ARPC'.  "Approve Related Party(C1)

      save_ok = ok_code.

      CLEAR ok_code.

      CASE save_ok.

        WHEN 'SAVE'.

          PERFORM save_rp_details USING g_ok_code_700.

        WHEN 'SEL'. "Select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            wa_zmm_vms_tp_set-sel = 'X'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'DSEL'. "De select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            CLEAR wa_zmm_vms_tp_set-sel.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'FIND'. "Find Vendor

          PERFORM get_rp_vendor.

        WHEN 'DEVC'. "Get Vendor Code Details

*Get Vendor Code Details
          IF NOT g_lifnr_750 IS INITIAL.

            READ TABLE ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set
                          WITH KEY lifnr  = g_lifnr_750.

            IF sy-subrc = 0.

              SET PARAMETER ID 'LIF' FIELD g_lifnr_750.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor MK03 not available (Business Partner). Open vendor BP in display via BP navigation.
*              CALL TRANSACTION 'MK03'.
              PERFORM zz_s4_show_vendor_bp USING g_lifnr_750.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

            ENDIF.

            CLEAR g_lifnr_750.

          ENDIF.

      ENDCASE.

    WHEN 'ARP'.  "Approve Related Party(L1)

      save_ok = ok_code.

      CLEAR ok_code.

      CASE save_ok.

        WHEN 'SAVE'.

          PERFORM save_rp_details USING g_ok_code_700.

        WHEN 'SEL'. "Select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            wa_zmm_vms_tp_set-sel = 'X'.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'DSEL'. "De select all records

          LOOP AT ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set.

            CLEAR wa_zmm_vms_tp_set-sel.

            MODIFY ist_zmm_vms_tp_set FROM wa_zmm_vms_tp_set
                       INDEX sy-tabix TRANSPORTING sel.

          ENDLOOP.

        WHEN 'FIND'. "Find Vendor

          PERFORM get_rp_vendor.

        WHEN 'DEVC'. "Get Vendor Code Details

*Get Vendor Code Details
          IF NOT g_lifnr_750 IS INITIAL.

            READ TABLE ist_zmm_vms_tp_set INTO wa_zmm_vms_tp_set
                          WITH KEY lifnr  = g_lifnr_750.

            IF sy-subrc = 0.

              SET PARAMETER ID 'LIF' FIELD g_lifnr_750.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor MK03 not available (Business Partner). Open vendor BP in display via BP navigation.
*              CALL TRANSACTION 'MK03'.
              PERFORM zz_s4_show_vendor_bp USING g_lifnr_750.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

            ENDIF.

            CLEAR g_lifnr_750.

          ENDIF.

      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0750  INPUT
*+SP015 : End
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_cst INPUT.

  IF wa_vend-vend-stcd2 IS NOT INITIAL.
    CLEAR l_cstno.
    CLEAR l_len_cst.

    l_cstno = wa_vend-vend-stcd2.
    l_len_cst = strlen( l_cstno ).
    IF l_len_cst <> 11.
      MESSAGE w183(zmm_oth).
    ENDIF.
    IF l_cstno+0(11) CN '0123456789'.
      MESSAGE w184(zmm_oth).
    ENDIF.

  ENDIF.

ENDMODULE.                 " VALIDATE_CST  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_VAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_vat INPUT.
  IF wa_vend-vend-stcd1 IS NOT INITIAL.

    CLEAR l_vatno.
    CLEAR l_len_vat.
    l_vatno = wa_vend-vend-stcd1.
    l_len_vat = strlen( l_vatno ).
    "commented by lipsy 22.03.2016
*  if l_len_vat <> 12.
    "ecommented by lipsy 22.03.2016
    "added by lipsy 22.03.2016
    IF l_len_vat = 11 OR l_len_vat = 12 .
      "eadded by lipsy 22.03.2016
    ELSE.
      MESSAGE w186(zmm_oth).
    ENDIF.
    IF l_vatno+0(11) CN '0123456789'.
      MESSAGE w187(zmm_oth).
    ENDIF.
    IF l_vatno+11(1) CN 'vV'.
      MESSAGE w188(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_VAT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0240  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0240 INPUT.
  CASE ok_code.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.

      CALL SCREEN 200.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0240  INPUT
*&---------------------------------------------------------------------*
*&      Module  MK03_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mk03_fld_dclk INPUT.
  IF NOT ist_lfa1-lifnr IS INITIAL.
    CLEAR:  v_lifnr_mk03.


    v_lifnr_mk03 = ist_lfa1-lifnr.



* SET PARAMETER ID : 'LIF'   FIELD ist_lfa3-lifnr.
*    "end of addition  by lipsy for getting correct excel on 30.08.2013 RD1K983016
*    """""""""""""""""""""""""""""""
*
**    SET parameter id : 'EKO'   FIELD ist_lfa1-ekorg.
*    CALL TRANSACTION 'MK03' .
*   SET PARAMETER ID : 'LIF' FIELD   ist_lfa1-lifnr .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = v_lifnr_mk03
      IMPORTING
        output = v_lifnr_mk03.

*
*
    v_called = 'X'.
*  SET PARAMETER ID 'LIF' FIELD   '100'.
* CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN .

*   SET PARAMETER ID 'MAT' FIELD '10001'.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.



  ENDIF.
ENDMODULE.                 " MK03_FLD_DCLK  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_UPD'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_upd_modify INPUT.
*
*MOVE-CORRESPONDING WA_UPD_ITEM TO IT_UPD_ITEM.
  IF it_upd_item IS INITIAL.

    APPEND wa_upd_item TO it_upd_item.
  ELSE.
    MODIFY it_upd_item
 FROM wa_upd_item
 INDEX tc_upd-current_line.

  ENDIF.

ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_UPD'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc_upd_mark INPUT.
  DATA: g_tc_upd_wa2 LIKE LINE OF it_upd_item.
  IF tc_upd-line_sel_mode = 1
  AND wa_upd_item-sel = 'X'.
    LOOP AT it_upd_item INTO g_tc_upd_wa2
      WHERE sel = 'X'.
      g_tc_upd_wa2-sel = ''.
      MODIFY it_upd_item
        FROM g_tc_upd_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY it_upd_item
    FROM wa_upd_item
    INDEX tc_upd-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_UPD'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_upd_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_UPD'
                              'IT_UPD_ITEM'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_GST_NO1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_gst_no1 INPUT.
  IF zmm_hvencrt-bukrs <> 'OVC' ."added by ss on 22.3.21
    IF wa_vend-vend-ort01 IS NOT INITIAL AND wa_vend-vend-gst_no IS INITIAL AND wa_vend-vend-j_1ipanno IS NOT INITIAL .
      IF wa_vend-vend-ven_class IS INITIAL.
        MESSAGE 'Please enter GST No. OR GST Vendor Classification ' TYPE 'E'.
      ENDIF.
*ENDIF.
    ENDIF.
  ENDIF. "added by ss on 22.3.21
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9100 INPUT.
  DATA: fcode   TYPE sy-ucomm, v_lfa1 TYPE lfa1, v_lfb1 TYPE lfb1, v_ind TYPE brsch, v_msg TYPE string, v_stcd5 .

  IF s_lfa1-stenr IS NOT INITIAL .
    SELECT SINGLE stenr FROM lfa1 INTO @DATA(v_tax) WHERE lifnr = @s_lfa1-lifnr." change by rohit on 07.04.2025
    IF sy-subrc  = 0.
      IF v_tax = zmm_hvencrt-udyog_aadhaar OR  zmm_hvencrt-udyog_aadhaar IS INITIAL.
        zmm_hvencrt-udyog_aadhaar =  v_tax.
      ENDIF.
    ENDIF.

  ENDIF.

  fcode = sy-ucomm.
  CLEAR : sy-ucomm .

  CASE fcode.

    WHEN 'SAVE'.
      break userabap02.
**********************code started by AD as on 24.01.2024**************
      IF udm  IS NOT INITIAL AND state IS NOT INITIAL AND code IS NOT INITIAL AND number IS NOT INITIAL  .
        CLEAR zmm_hvencrt-udyog_aadhaar.

        CONCATENATE udm state code number
            INTO zmm_hvencrt-udyog_aadhaar
            SEPARATED BY '-'.

        ud_no = zmm_hvencrt-udyog_aadhaar.
      ENDIF.
      DATA : udm_no TYPE i.
      SELECT SINGLE * FROM setleaf INTO @DATA(t_acc) WHERE setname = 'ZFI_UDYOG' AND valfrom = @s_lfa1-brsch.
      IF sy-subrc = 0 AND zmm_hvencrt-udyog_aadhaar IS INITIAL.
        DATA(flag) = abap_true.
        MESSAGE 'Udyam Number cannot be blank' TYPE 'I' DISPLAY LIKE 'E'.

      ELSE.
*       SELECT SINGLE STCD5 FROM lfa1 INTO v_STCD5  where STCD5  = s_lfa1-STCD5
        udm_no =  strlen( zmm_hvencrt-udyog_aadhaar  ).
        SELECT SINGLE * FROM setleaf INTO @t_acc WHERE setname = 'ZFI_UDYOG' AND valfrom = @s_lfa1-brsch.
        IF sy-subrc = 0 AND udm_no LT '19'.
          flag = abap_true.

          MESSAGE 'Udyam Number should be 19 digit ' TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
        DATA val1 TYPE c LENGTH 13.
        val1 = zmm_hvencrt-udyog_aadhaar+6.
*        s_lfa1-stcd5 = zmm_hvencrt-udyog_aadhaar  ." comment by rohit on 07.04.2025
        s_lfa1-stenr = val1  ."add by rohit on 07.04.2025
*        IF sy-subrc = 0.
*          MODIFY lfa1 FROM s_lfa1.
*
*        ENDIF.
      ENDIF.

      IF flag = abap_false.
        IF s_lfa1-brsch IS INITIAL.
          MESSAGE 'Industry field cannot be blank' TYPE 'E'.

        ELSE.
          SELECT SINGLE brsch FROM t016 INTO v_ind WHERE brsch = s_lfa1-brsch.
          IF sy-subrc = 0.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: vendor master is BP-managed; direct MODIFY lfa1 not allowed. Update central fields
*      (BRSCH industry, STENR Udyam no.) via VMD_EI_API. NOTE: if this screen edits other LFA1
*      fields, add them to zz_s4_update_vendor_central accordingly.
*            MODIFY lfa1 FROM s_lfa1.
            PERFORM zz_s4_update_vendor_central USING s_lfa1-lifnr s_lfa1-brsch s_lfa1-stenr.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
            IF sy-subrc = 0.
              CLEAR v_msg.
              CONCATENATE 'Master data for vendor' s_lfa1-lifnr 'updated' INTO v_msg SEPARATED BY space.
              MESSAGE v_msg TYPE 'S'.
              CLEAR: v_lfa1, s_lfa1, flag_scr, v_ccode ,   zmm_hvencrt-udyog_aadhaar.
              flag_rf = 'X'.
            ENDIF.

          ELSE.
            CLEAR s_lfa1-brsch.
            MESSAGE 'Invalid entry, Please enter correct value and try again' TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR flag.
*      **********************code Ended by AD as on 24.01.2024**************
    WHEN 'RF'.
      CLEAR: v_lfa1, s_lfa1, flag_scr, v_ccode,zmm_hvencrt-udyog_aadhaar.
      flag_rf = 'X'.

    WHEN OTHERS.
      IF v_lfa1 IS INITIAL AND s_lfa1-lifnr IS NOT INITIAL AND v_ccode IS NOT INITIAL.
        CLEAR v_lfb1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = s_lfa1-lifnr
          IMPORTING
            output = s_lfa1-lifnr.

        SELECT SINGLE * FROM lfb1 INTO v_lfb1 WHERE lifnr = s_lfa1-lifnr AND bukrs = v_ccode.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM lfa1 INTO v_lfa1 WHERE lifnr = s_lfa1-lifnr."" AND ccode = s_lfa1-ccode.
          IF sy-subrc = 0.
            CLEAR: flag_rf, s_lfa1.
            s_lfa1 = v_lfa1.
            flag_scr = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ex INPUT.
  IF sy-ucomm = 'BACK' OR sy-ucomm = 'CANCEL' OR sy-ucomm = 'EXIT'.
    CLEAR: s_lfa1, v_ccode, flag_scr, flag_rf.
    LEAVE TO SCREEN 0100..
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_DUPLICATE_ENTRY1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_entry1 INPUT.


  g_okcode321 = sy-ucomm.
  IF g_tc321_wa-exist <> 'X'.    "This part of Code added on 290911
    CASE g_okcode321.

      WHEN 'TC321_INSR' OR 'SAVE' .

        IF zfivmsbank-bankl_new IS INITIAL OR "and
           zfivmsbank-bankn_new IS INITIAL OR "and
           zfivmsbank-koinh_new IS INITIAL.
          SET CURSOR FIELD 'zfivmsbank-bankl_new' LINE sy-tabix.
          MESSAGE e365(zfi) WITH zfivmsbank-lifnr.

        ELSEIF NOT zfivmsbank-bankl    IS INITIAL AND
               NOT zfivmsbank-bankn     IS INITIAL AND
               NOT zfivmsbank-koinh     IS INITIAL AND
               NOT zfivmsbank-bankl_new IS INITIAL AND
               NOT zfivmsbank-bankn_new IS INITIAL AND
               NOT zfivmsbank-koinh_new IS INITIAL.
*        if zfivmsbank-attach  is initial.                     " G_TC319_WA-attach 160911
* Begin of <> on 160911
          IF g_okcode931 = 'CREATE'.
            IF g_tc321_wa-attach <> 'X'.
              MESSAGE i417(zfi).
*          l_text = 'Changes affect payments from other locations. Do u wish to continue?'.
*          PERFORM POPUP_MESSAGE_DISPLAY USING L_TEXT.
*          if l_answer = 'J'.
* End of <> on 160911
*            if g_attachment <> 'X'.
*               g_attachment = 'X'.            "20072011
              zfivmsbank-attach = 'X'.          "20072011   160911
              MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa.  "160911
              MODIFY g_tc321_itab
              FROM g_tc321_wa
              INDEX tc321-current_line.
*            G_TC319_WA-attach = 'X'.           "160911
              MESSAGE w380(zfi) WITH zfivmsbank-lifnr.      "120911 130911
            ENDIF.
          ELSEIF g_okcode931 = 'CHANGE'.
            IF g_tc321_wa-attach <> 'X'.
              MESSAGE e418(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ENDIF.
*               g_attachment = 'X'.            "20072011
*               zfivmsbank-attach = 'X'.       "20072011
*            endif.
*          endif.
*        endif.
* Begin of <> on 31052012
        ELSEIF     zfivmsbank-bankl     IS INITIAL AND
                   zfivmsbank-bankn     IS INITIAL AND
                   zfivmsbank-koinh     IS INITIAL AND
               NOT zfivmsbank-bankl_new IS INITIAL AND
               NOT zfivmsbank-bankn_new IS INITIAL AND
               NOT zfivmsbank-koinh_new IS INITIAL.
          IF g_okcode931 = 'CREATE'.
            IF g_tc321_wa-attach <> 'X'.
              MESSAGE i417(zfi).
              zfivmsbank-attach = 'X'.
              MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa.
              MODIFY g_tc321_itab
              FROM g_tc321_wa
              INDEX tc321-current_line.
              MESSAGE w380(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ELSEIF g_okcode931 = 'CHANGE'.
            IF g_tc321_wa-attach <> 'X'.
              MESSAGE e418(zfi) WITH zfivmsbank-lifnr.
            ENDIF.
          ENDIF.
* End of <> on 31052012
        ENDIF.

*  WHEN 'ENTER'.
    ENDCASE.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANK_FLOW1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bank_flow1 .
  SELECT SINGLE * FROM lfb1 INTO wa_lfb1 WHERE lifnr = zfivmsbank-lifnr
                                           AND bukrs = g_ccode.
  IF sy-subrc <> 0.
    MESSAGE e367(zfi) WITH zfivmsbank-lifnr g_ccode.
  ENDIF.

  IF NOT g_lifnr1 IS INITIAL.
    IF  g_lifnr1 = zfivmsbank-lifnr.
      IF NOT g_exist IS INITIAL.
        MESSAGE e366(zfi) WITH zfivmsbank-lifnr.
      ENDIF.
    ELSE.
      CLEAR : g_exist, g_lifnr1.
    ENDIF.
  ENDIF.

  IF zfivmsbank-bankl_new IS INITIAL.
    CASE g_okcode321.
      WHEN 'ENTER'.
        DESCRIBE TABLE g_tc321_itab LINES l_line.

        IF l_line > 1 AND g_exist IS INITIAL.
          READ TABLE g_tc321_itab INTO g_tc321_wa_temp WITH KEY lifnr = zfivmsbank-lifnr.
          IF sy-subrc = 0.
            g_lifnr1 = zfivmsbank-lifnr.
            g_exist  = 'X'.
            MESSAGE e366(zfi) WITH zfivmsbank-lifnr.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.

* Begin of <> on 25092010
  CASE g_okcode931.
    WHEN 'CREATE'.
      PERFORM check_lifnr_flow.
    WHEN 'CHANGE'.


      READ TABLE g_tc321_itab INTO g_tc321_wa_as INDEX tc321-current_line.  "#EC CI_NOORDER
      IF zfivmsbank-bankl_new <> g_tc321_wa_as-bankl_new OR
         zfivmsbank-bankn_new <> g_tc321_wa_as-bankn_new OR
         zfivmsbank-koinh_new <> g_tc321_wa_as-koinh_new OR
         zfivmsbank-lifnr    <> g_tc321_wa_as-lifnr OR
         zfivmsbank-zbnkt     <> g_tc321_wa_as-zbnkt .
        MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa_as.
      ENDIF.

      IF zfivmsbank-bankl_new = g_tc321_wa_as-bankl_new AND
         zfivmsbank-bankn_new = g_tc321_wa_as-bankn_new AND
         zfivmsbank-koinh_new = g_tc321_wa_as-koinh_new AND
        zfivmsbank-zbnkt = g_tc321_wa_as-zbnkt .

        PERFORM check_lifnr_flow.
      ENDIF.
      MODIFY g_tc321_itab FROM g_tc321_wa_as INDEX tc321-current_line.

    WHEN 'CHECK'.
      PERFORM check_existance_of_bankn1.
  ENDCASE.
*

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  TC321_MODIFY1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc321_modify1 INPUT.

  g_okcode321 = sy-ucomm.

  CASE g_okcode931.

    WHEN  'CREATE' OR 'CHANGE'.

      IF NOT zfivmsbank-lifnr IS INITIAL.

        IF NOT zfivmsbank-bankl_new IS INITIAL.
          IF g_ccode EQ 'OVL'.   " added by ss
            SELECT SINGLE * FROM bnka
                    INTO wa_bnka WHERE  banks = 'IN'
                                   AND bankl = zfivmsbank-bankl_new.

**              BOC by ss on 26.8.21
          ELSEIF g_ccode EQ 'OVC'.
            SELECT SINGLE * FROM bnka
              INTO wa_bnka WHERE banks = 'CO'
                             AND bankl = zfivmsbank-bankl_new.

          ENDIF.
**          EOC by ss on 26.8.21

          IF sy-subrc = 0.
            IF wa_bnka-loevm = 'X'.
              MESSAGE e350(zfi) WITH zfivmsbank-bankl_new.
            ELSE.
              PERFORM check_bank_key_entry1.
              g_new = 'X'.
            ENDIF.
          ELSE.
            MESSAGE e356(zfi) WITH zfivmsbank-bankl_new.
          ENDIF.
        ENDIF.
      ENDIF.


      IF NOT zfivmsbank-bankl IS INITIAL.
        IF  g_ccode EQ 'OVL'.
          SELECT SINGLE * FROM bnka
          INTO wa_bnka WHERE banks = 'IN' AND bankl = zfivmsbank-bankl.
        ELSEIF g_ccode EQ 'OVC'.    " added by ss on 26.8.21.
          SELECT SINGLE * FROM bnka
         INTO wa_bnka WHERE banks = 'CO' AND bankl = zfivmsbank-bankl.
        ENDIF.
        IF sy-subrc <> 0.
          MESSAGE e305(zfi) WITH zfivmsbank-bankl.
        ENDIF.
      ENDIF.

      IF g_okcode931 = 'CHANGE' .
* Begin of <> on 280911
        zfivmsbank-reqno = g_tc321_wa-reqno.
        IF NOT g_tc321_wa-bankl_new IS INITIAL AND
           NOT g_tc321_wa-bankn_new IS INITIAL AND
           NOT g_tc321_wa-koinh_new IS INITIAL AND
           NOT g_tc321_wa-zbnkt     IS INITIAL.
          IF ( zfivmsbank-bankl_new  <> g_tc321_wa-bankl_new ) OR
             ( zfivmsbank-bankn_new  <> g_tc321_wa-bankn_new ) OR
             ( zfivmsbank-koinh_new  <> g_tc321_wa-koinh_new ) OR
             ( zfivmsbank-zbnkt      <> g_tc321_wa-zbnkt ).
            IF g_tc321_wa-attach = 'X'.
              MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa.
              g_tc321_wa-attach = 'X'.
            ENDIF.
          ENDIF.

        ELSE.
          CLEAR : g_tc321_wa.
          MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa.
        ENDIF.
      ENDIF.
      IF g_okcode931 = 'CREATE' .
        CLEAR : g_tc321_wa.
        MOVE-CORRESPONDING zfivmsbank TO g_tc321_wa.
      ENDIF.
* End of <> on 280911
*      CLEAR : g_tc321_wa.
  ENDCASE.


  IF g_exist_ztable = 'X'.
    g_tc321_wa-exist = 'X'.
  ENDIF.
  g_tc321_wa-srno = tc321-current_line.                     "150911
  MODIFY g_tc321_itab
  FROM g_tc321_wa
  INDEX tc321-current_line.

  CLEAR g_exist_ztable.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TB_FUNC_SEL321  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tb_func_sel321_1 INPUT.
  IF tc321-line_sel_mode = 1 AND g_tc321_wa-sel321 = 'X'.
    MODIFY g_tc321_itab FROM g_tc321_wa INDEX
                           tc321-current_line  TRANSPORTING sel321.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ATTACH_LIST_FILES1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE attach_list_files1 INPUT.
  g_okcode321 = sy-ucomm.
  IF g_okcode931 = 'CHANGE'.                                "150911
    CASE g_okcode321 .
      WHEN 'ATTACH' .                                       "210911
        READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY sel321 = 'X'. "index tc319-current_line.
        IF sy-subrc = 0.

          IF NOT g_tc321_wa-bankl     IS INITIAL AND    "zfivmsbank
             NOT g_tc321_wa-bankn     IS INITIAL AND
             NOT g_tc321_wa-koinh     IS INITIAL AND
             NOT g_tc321_wa-bankl_new IS INITIAL AND
             NOT g_tc321_wa-bankn_new IS INITIAL AND
             NOT g_tc321_wa-koinh_new IS INITIAL.
            MESSAGE s419(zfi).
          ENDIF.

        ELSE.
          MESSAGE i419(zfi).
        ENDIF.
      WHEN 'LIST'.
        READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY sel321 = 'X'.
        IF sy-subrc <> 0.
          MESSAGE i419(zfi).
        ENDIF.
    ENDCASE.
  ELSEIF g_okcode931 = 'DISPLAY'.                           "270911
    CASE g_okcode321.
      WHEN 'LIST'.
        READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY sel321 = 'X'.
        IF sy-subrc <> 0.
          MESSAGE i419(zfi).
        ENDIF.
    ENDCASE.

  ELSEIF g_okcode931 = 'CHANGE'.
    MODIFY g_tc321_itab FROM g_tc321_wa.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_321  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_321 INPUT.

  g_okcode321 = sy-ucomm.
  CASE g_okcode321.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      REFRESH CONTROL 'TC321' FROM SCREEN '0321'.
      REFRESH : g_tc321_itab.
      CLEAR g_tc321_copied.
      CALL SCREEN 931.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC321_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc321_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc1 USING    'TC321'
                               'G_TC321_ITAB'
                               'SEL321'
                      CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0321  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0321 INPUT.


  DATA : l_docno1       TYPE zfivmsbank-reqno,
         l_text_1(100),
         l_text1_1(100),
         l_text2_1(100),
         l_text3_1(100),
         l_answer_1,
         l_already_1,
         l_new_1,
         l_newentry_1,
         l_line_1       TYPE n,
         l_line1_1      TYPE n.

  g_okcode321 = sy-ucomm.

  CASE g_okcode321.
* Begin fo <> on 230911
    WHEN 'ATTACH'.
      READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY sel321 = 'X'."index tc319-current_line.
      IF sy-subrc = 0.
        IF g_tc321_wa-sel321 = 'X'.
          PERFORM attach_files_1.
        ENDIF.
      ENDIF.
    WHEN 'LIST'.
      READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY sel321 = 'X'. "index tc319-current_line.
      IF sy-subrc = 0.
        IF g_tc321_wa-sel321 = 'X'.
          PERFORM list_files_1.
        ENDIF.
      ENDIF.
* End of <> on 230911
    WHEN 'SAVE'.
      CASE  g_okcode931.

        WHEN 'CREATE' OR 'BACK' .
* Begin of <> on 271211
          PERFORM check_bankl_bankn1.
* End of <> on 271211
          IF g_ans <> 'N'. "2.  25012012                              "281211
            IF g_okcode931 = 'BACK'.
              l_text_1 =  'Do You Want to Save the Data'.
              PERFORM popup_message USING l_text_1.
            ENDIF.

            IF l_answer_1    = 'J' OR
               g_okcode931 = 'CREATE' .

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              READ TABLE g_tc321_itab INTO g_tc321_wa INDEX 1.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
              DESCRIBE TABLE g_tc321_itab LINES l_line_1.
              IF l_line_1 > 0 AND NOT g_tc321_wa-lifnr IS INITIAL.

                IF g_new = 'X'. "l_new = 'X'.
* Begin of <> on 20072011
*                perform check_attachment.   "22072011 RD1K977234
*                if g_attachment = 'X'.      "22072011
* End of <> on 20072011


                  CALL FUNCTION 'NUMBER_GET_NEXT'
                    EXPORTING
                      nr_range_nr             = g_nrrangenr
                      object                  = g_nrobj1 "changed on 9/3/21 by ss
                    IMPORTING
                      number                  = l_docno1
                    EXCEPTIONS
                      interval_not_found      = 1
                      number_range_not_intern = 2
                      object_not_found        = 3
                      quantity_is_0           = 4
                      quantity_is_not_1       = 5
                      interval_overflow       = 6
                      buffer_overflow         = 7
                      OTHERS                  = 8.

                  IF l_docno1 IS NOT INITIAL.
                    l_docno1+0(3) = 'EMD'.
                  ENDIF.

                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF.
                  DELETE ADJACENT DUPLICATES FROM g_tc321_itab COMPARING lifnr.  "#EC CI_NOORDER
                  LOOP AT g_tc321_itab INTO g_tc321_wa WHERE exist IS INITIAL.
                    g_tc321_wa-reqno = l_docno1.
                    IF NOT g_tc321_wa-status IS INITIAL.
                      CLEAR : g_tc321_wa-status,
                              g_tc321_wa-attach,
                              g_tc321_wa-zlist,
                              g_tc321_wa-hof_cpf_no,
                              g_tc321_wa-hof_name,
                              g_tc321_wa-hof_rldate,
                              g_tc321_wa-hof_zremarks,
                              g_tc321_wa-vmc_cpf_no,
                              g_tc321_wa-vmc_name,
                              g_tc321_wa-vmc_apdate,
                              g_tc321_wa-vmc_zremarks,
                              g_tc321_wa-cvp_cpf_no,
                              g_tc321_wa-cvp_name,
                              g_tc321_wa-cvp_assdate,
                              g_tc321_wa-registration,
                              g_tc321_wa-deregistration,
                              g_tc321_wa-sel321,
                              g_tc321_wa-exist.
                    ENDIF.
* End of <> on 06042011
                    MOVE-CORRESPONDING g_tc321_wa TO zfivmsbank.
                    CLEAR : zfivmsbank-attach.              "160911 SS
                    zfivmsbank-status   = 'NEW'.
                    zfivmsbank-username = g_username. "SY-UNAME.
                    zfivmsbank-cdate    = sy-datum.
                    zfivmsbank-cputm    = sy-uzeit.
                    zfivmsbank-cpf      = g_cpf .
                    zfivmsbank-ccode    = g_ccode .
                    MODIFY zfivmsbank.
                  ENDLOOP.
                  IF sy-subrc = 0.
                    MESSAGE i302(zfi) WITH zfivmsbank-reqno.
                    REFRESH g_tc321_itab.
                    CLEAR : g_new, g_tc321_copied.
                    CALL SCREEN 931.
                  ENDIF.
* Begin of <> 20072011
*                else.                "RD1K977234  22072011
*                  message i380(zfi). "RD1K977234
*                endif.               "RD1K977234
* End of 20072011

                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        WHEN 'CHANGE'.
* Begin of <> on 271211
          PERFORM check_bankl_bankn1.
* End of <> on 271211
          IF g_ans <> 'N'.       "2                             "281211
            IF g_okcode931 = 'BACK'.
              l_text =  'Do You Want to Save the Data'.
              PERFORM popup_message USING l_text.
            ENDIF.

            IF l_answer    = 'J' OR
               g_okcode931 = 'CHANGE' .

              DESCRIBE TABLE g_tc321_itab LINES l_line.
              IF l_line > 0.
                PERFORM check_attach_files.
                l_docno = zfivmsbank-reqno.
                DELETE FROM zfivmsbank WHERE reqno = zfivmsbank-reqno.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                SORT g_tc321_itab BY lifnr.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                DELETE ADJACENT DUPLICATES FROM g_tc321_itab COMPARING lifnr.

                LOOP AT g_tc321_itab INTO g_tc321_wa WHERE exist IS INITIAL.
                  g_tc321_wa-reqno = l_docno.

                  MOVE-CORRESPONDING g_tc321_wa TO zfivmsbank.

                  zfivmsbank-status = 'NEW'.

                  zfivmsbank-username = sy-uname.
                  zfivmsbank-cdate    = sy-datum.
                  zfivmsbank-cputm    = sy-uzeit.
                  zfivmsbank-cpf      = g_cpf .
                  zfivmsbank-ccode    = g_ccode .
                  MODIFY zfivmsbank.
                ENDLOOP.
                IF sy-subrc = 0.
                  MESSAGE i303(zfi) .
                  REFRESH g_tc321_itab.
                  CLEAR : g_tc321_copied.                   "270911
                  CALL SCREEN 931.
                ELSE.
                  MESSAGE e376(zfi).
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.


        WHEN 'DELETE'.

          l_text =  'Do You Want to Delete the Data'.

          PERFORM popup_message USING l_text.
          IF l_answer = 'J'.
            DELETE FROM zfivmsbank WHERE reqno = zfivmsbank-reqno.
            MESSAGE i067(zfi).
          ENDIF.

      ENDCASE.

*    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
*      REFRESH CONTROL 'TC321' FROM SCREEN '0321'.
*      REFRESH : G_TC321_ITAB.
*      CLEAR G_TC321_COPIED.
*      CALL SCREEN 931.

  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BANK_FLOW1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_bank_flow1 INPUT.
  PERFORM check_bank_flow1.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXISTANCE_OF_BANKN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_existance_of_bankn1 .
  READ TABLE g_tc321_itab INTO g_tc321_wa_as INDEX tc321-current_line.  "#EC CI_NOORDER
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_BANK_KEY_ENTRY1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_bank_key_entry1 .

* Bank Key
  DATA : l_len_1(2)         TYPE n,
         l_digit_1(2)       TYPE n,
         h_digit_1(2)       TYPE n,
         l_str_1            TYPE string,
         valid_characters_1 TYPE string,
         invalid_char_1     TYPE string,
         valid_input_1      TYPE string.

  l_len_1 = strlen( zfivmsbank-bankl_new ) .
  l_str_1 = zfivmsbank-bankl_new(4).
  IF NOT zfivmsbank-koinh_new IS INITIAL.                   "25082010
* Fill in those valid characters you need to check
    CONCATENATE '0123456789' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    'abcdefghijklmnopqrstuvwxyz' INTO valid_characters_1.

*    concatenate '!`!@#$%^&*()_-' '{[}]\":;?/.,<>' into invalid_char.  "011210
*begin RD1K991769       CAB_ALOK     CompBeneFile gen,digsign,transfer,monitor - CR 30010502
*    concatenate '''~!`!@#$%^&*()_-' '{[}]\":;?/,<>' into invalid_char.
    CONCATENATE '''~!`!@#$%^&*()_-' '{[}]\":;?/,<>.' INTO invalid_char_1.   " . added
*end RD1K991769       CAB_ALOK     CompBeneFile gen,digsign,transfer,monitor - CR 30010502
    valid_input_1 = zfivmsbank-koinh_new.
    CONDENSE valid_input_1.
    IF  valid_input_1 CA invalid_char_1.
* Begin of <> on 05072011
      SET CURSOR FIELD 'ZFIVMSBANK-KOINH_NEW' LINE tc321-current_line.
* End of <> on 05072011
      MESSAGE e361(zfi) WITH zfivmsbank-koinh_new.
    ENDIF.
  ENDIF.

  IF l_len_1 <> 11.
* Begin of <> on 05072011
    SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc321-current_line.
* End of <> on 05072011
    MESSAGE e351(zfi).
  ELSE.
    IF l_str_1 CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
*     search  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' for ZFIVMSBANK-BANKL_NEW(4).
      SEARCH  '0' FOR zfivmsbank-bankl_new+4(1).
      IF sy-subrc NE 0.
* Begin of <> on 05072011
        SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc321-current_line.
* End of <> on 05072011
        MESSAGE e353(zfi).
      ENDIF.
    ELSE.
* Begin of <> on 05072011
      SET CURSOR FIELD 'ZFIVMSBANK-BANKL_NEW' LINE tc321-current_line.
* End of <> on 05072011
      MESSAGE e352(zfi).
    ENDIF.
  ENDIF.
* Bank Account
  IF NOT zfivmsbank-bankn_new IS INITIAL.
    DATA : l_len1_1(2)       TYPE n,
           l_len2_1(2)       TYPE n,
           l_str1_1          TYPE string,
           l_lastdigit_1     TYPE string,
           l_firstdigit_1    TYPE string,
           wa_zmm_vms_ifsc_1 TYPE zmm_vms_ifsc,
           l_temp_1(2) .

    SELECT SINGLE * FROM zmm_vms_ifsc INTO wa_zmm_vms_ifsc_1 WHERE bankl = l_str_1.
    l_len1_1 = strlen( zfivmsbank-bankn_new ) .
    l_str1_1 = zfivmsbank-bankn_new(4).
    l_temp_1 = l_len1_1.

    IF wa_zmm_vms_ifsc_1-bnkkeypos > '0'.
      " or  wa_ZMM_VMS_IFSC-bnkkeypos is initial. "31082010
      wa_zmm_vms_ifsc_1-bnkkeypos = wa_zmm_vms_ifsc_1-bnkkeypos - 1.
      wa_zmm_vms_ifsc_1-acntpos   = wa_zmm_vms_ifsc_1-acntpos - 1.
      l_lastdigit_1 = zfivmsbank-bankl_new+wa_zmm_vms_ifsc_1-bnkkeypos(wa_zmm_vms_ifsc_1-bnkkey_digit).
      l_firstdigit_1 = zfivmsbank-bankn_new+wa_zmm_vms_ifsc_1-acntpos(wa_zmm_vms_ifsc_1-acnt_digit).
      IF ( wa_zmm_vms_ifsc_1-symbol_cond = '=')  OR
         ( wa_zmm_vms_ifsc_1-symbol_cond = '<=') OR
         ( wa_zmm_vms_ifsc_1-symbol_cond = '>=') OR
         ( wa_zmm_vms_ifsc_1-symbol_cond = 'BT') OR
         ( wa_zmm_vms_ifsc_1-symbol_cond = '>')  OR
         ( wa_zmm_vms_ifsc_1-symbol_cond = '<').

        IF ( wa_zmm_vms_ifsc_1-symbol_cond = '=').
          IF l_len1_1 <>  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e354(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '<=').
          IF l_len1_1 >=  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '>=').
          IF l_len1_1 <=  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e360(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = 'BT').
          CONDENSE wa_zmm_vms_ifsc_1-symbol_digit.
          SPLIT wa_zmm_vms_ifsc_1-symbol_digit AT ',' INTO l_digit_1 h_digit_1.
          CONDENSE l_temp_1.
          IF  ( l_temp_1 > h_digit_1 ).
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ELSEIF l_temp_1 < l_digit_1 .
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.
**          if l_len1 >=  wa_ZMM_VMS_IFSC-SYMBOL_DIGIT(1) or
**             l_len1 <=  wa_ZMM_VMS_IFSC-SYMBOL_DIGIT+5(2).
*          if l_digit <= l_len1." and
**             h_digit >=  l_len1.
*            message e359(zfi) with wa_ZMM_VMS_IFSC-SYMBOL_DIGIT.
*          endif.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '<').
          IF l_len1_1 >  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '>').
          IF l_len1_1 <  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ENDIF.
        IF l_lastdigit_1 <> l_firstdigit_1.
* Begin of <> on 05072011
          SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
          MESSAGE e355(zfi).
        ENDIF.
      ENDIF.
    ELSE.
      IF ( wa_zmm_vms_ifsc_1-symbol_cond = '=')  OR
        ( wa_zmm_vms_ifsc_1-symbol_cond = '<=') OR
        ( wa_zmm_vms_ifsc_1-symbol_cond = '>=') OR
        ( wa_zmm_vms_ifsc_1-symbol_cond = 'BT') OR
        ( wa_zmm_vms_ifsc_1-symbol_cond = '>')  OR
        ( wa_zmm_vms_ifsc_1-symbol_cond = '<').

        IF ( wa_zmm_vms_ifsc_1-symbol_cond = '=').
          IF l_len1_1 <>  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e354(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '<=').
          IF l_len1_1 >  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.
        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '>=').
          IF l_len1_1 <  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e360(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = 'BT').
          CONDENSE wa_zmm_vms_ifsc_1-symbol_digit.
          SPLIT wa_zmm_vms_ifsc_1-symbol_digit AT ',' INTO l_digit_1 h_digit_1.
          CONDENSE l_temp_1.
          IF  ( l_temp_1 > h_digit_1 ). " l_len1 >= l_digit or
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ELSEIF l_temp_1 < l_digit_1 .
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '<').
          IF l_len1_1 >  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ELSEIF ( wa_zmm_vms_ifsc_1-symbol_cond = '>').
          IF l_len1_1 <  wa_zmm_vms_ifsc_1-symbol_digit.
* Begin of <> on 05072011
            SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
            MESSAGE e359(zfi) WITH wa_zmm_vms_ifsc_1-symbol_digit.
          ENDIF.

        ENDIF.
        IF l_lastdigit_1 <> l_firstdigit_1.
* Begin of <> on 05072011
          SET CURSOR FIELD 'ZFIVMSBANK-BANKN_NEW' LINE tc321-current_line.
* End of <> on 05072011
          MESSAGE e355(zfi).
        ENDIF.
      ENDIF.
    ENDIF.

* Begin of <> on 25082010 04092010
    IF NOT wa_zmm_vms_ifsc_1-cnd IS INITIAL.
      IF wa_zmm_vms_ifsc_1-cnd = 'BEGIN WITH'.
        CONDENSE zfivmsbank-bankn_new.
        SEARCH ',' FOR zfivmsbank-bankn_new.
        IF zfivmsbank-bankl_new(4) = 'SBIN'.
          IF zfivmsbank-bankn_new(1) <> '1' AND
             zfivmsbank-bankn_new(1) <> '2' AND
             zfivmsbank-bankn_new(1) <> '3' AND
             zfivmsbank-bankn_new(1) <> '5' AND
             zfivmsbank-bankn_new(1) <> '6' .
            MESSAGE e362(zfi).
          ENDIF.
        ELSEIF zfivmsbank-bankl_new(4) = 'CORP'.
          IF  zfivmsbank-bankn_new(7) = 'CCSDL01'.
*               message e363(zfi).
          ELSEIF zfivmsbank-bankn_new(6) = 'CBCA01' .
*              message e363(zfi).
          ELSEIF zfivmsbank-bankn_new(4) = 'CA01' OR
                 zfivmsbank-bankn_new(4) = 'SB01' OR
                 zfivmsbank-bankn_new(4) = 'CC01'.

          ELSE.
            MESSAGE e363(zfi).
          ENDIF.
        ENDIF.
      ELSEIF wa_zmm_vms_ifsc_1-cnd = 'ENDS WITH'.
        IF zfivmsbank-bankl_new(4) = 'KARB'.
          IF zfivmsbank-bankn_new+14(2) <> '01'.
            MESSAGE e364(zfi).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
* End of <>
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5042   text
*      -->P_5043   text
*      -->P_5044   text
*      <--P_OK_CODE  text
*----------------------------------------------------------------------*
FORM user_ok_tc1  USING p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

  DATA: l_ok1     TYPE sy-ucomm,
        l_offset1 TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset1 = strlen( p_tc_name ) + 1.
  l_ok1 = p_ok+l_offset1.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok1.
    WHEN 'INSR'.                      "insert row

      READ TABLE  g_tc321_itab INTO zfivmsbank INDEX 1.  "#EC CI_NOORDER
      DATA : l_line TYPE i.

      DESCRIBE TABLE  g_tc321_itab LINES l_line.

      l_line = l_line + 1.
      tc321-lines = l_line.
      CLEAR : g_create .
      CLEAR : g_tc321_wa,    g_exist .
      INSERT INITIAL LINE INTO g_tc321_itab INDEX l_line.
      g_tc321_wa-srno = l_line.

*      G_TC321_WA-ZBNKT = 'EM'.  "commented by ss on 3.5.21.
      MODIFY g_tc321_itab FROM g_tc321_wa INDEX l_line.  "#EC CI_NOORDER
*       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
*                                         P_TABLE_NAME.
*       CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      IF g_okcode931 = 'CHANGE' OR g_okcode531 = 'CHANGE'.  "08092010
        g_tc321_itab_temp[] = g_tc321_itab[].
        g_tc531_itab_temp[] = g_tc531_itab[].
        g_zvms_reqno   = zfivmsbank-reqno.
      ENDIF.

      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok1.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

    WHEN 'POSI'.
      PERFORM search_request.
      CLEAR p_ok.


  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LIST_FILES_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_files_1 .


  DATA : l_list TYPE zfivmsbank-zlist.                      "07092011
  IF g_attachment = 'X' OR g_okcode321 = 'LIST' OR g_okcode531 = 'LIST'.
    CLEAR g_att_files_wa.

* Begin of <> on 19092011 210911
    CONCATENATE g_tc321_wa-srno(3) g_tc321_wa-reqno+3(7) INTO docno_lifnr.
* End of <> on 06092011
    g_att_files_wa-logsys  = '01'.
    g_att_files_wa-objtype = 'VENDOR'.
    g_att_files_wa-objkey  = docno_lifnr.

    REFRESH exclude_tab[].
    exclude_tab-fcode = 'EXPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'IMPO'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'HGEN'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'OLNK'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'REFL'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'COPY'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'CHNG'.
    APPEND exclude_tab.

    exclude_tab-fcode = 'PRIN'.
    APPEND exclude_tab.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa
        function           = ' '
      TABLES
        func_exclude       = exclude_tab.            "190911 290911
    "070911 ELSE PART ADDED
*    ENDIF.                                                  "07091
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ATTACH_FILES_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM attach_files_1 .

  DATA itab LIKE symsg OCCURS 0 WITH HEADER LINE.
  DATA l_obj TYPE sood4-objno.                              "21072011
  DATA ls_attachment_data TYPE sodocchgi1.                  "21072011

  IF g_attachment = 'X' OR g_okcode321 = 'ATTACH'.
    CLEAR g_att_files_wa.
    REFRESH g_att_files.

    CONCATENATE g_tc321_wa-srno(3) g_tc321_wa-reqno+3(7) INTO docno_lifnr.

    g_att_files_wa-logsys  = '01'.
    g_att_files_wa-objtype = 'VENDOR'.
    g_att_files_wa-objkey  = docno_lifnr.

    APPEND g_att_files_wa TO g_att_files.
    CALL FUNCTION 'ZSO_WIND_ATTACHMENT_CREAT_API1' "'SO_WIND_ATTACHMENT_CREATE_API1'
      EXPORTING
        attachment_data     = ls_attachment_data
        attachment_type     = 'DOC'
      IMPORTING
        attach_obj          = l_obj
      TABLES
        application_objects = g_att_files.

    IF NOT l_obj IS INITIAL.
      g_tc321_wa-attach = 'X'.

      MOVE-CORRESPONDING g_tc321_wa TO zfivmsbank.
      zfivmsbank-status = 'NEW'.
      zfivmsbank-username = sy-uname.
      zfivmsbank-cdate    = sy-datum.
      zfivmsbank-cputm    = sy-uzeit.
      zfivmsbank-cpf      = g_cpf .
      zfivmsbank-ccode    = g_ccode .
      MODIFY zfivmsbank.
*      select single * from icon into wa_icon where name = 'ICON_ATTACHMENT'.
*      G_TC319_WA-attach = wa_icon-id.
**        g_tc319_wa-ZVENDTIMESTAMP = docno_lifnr.
*      select single * from icon into wa_icon where name = 'ICON_LIST'.
*      G_TC319_WA-zlist = wa_icon-id.

      MODIFY g_tc321_itab  FROM g_tc321_wa INDEX g_tc321_wa-srno.  "#EC CI_NOORDER  "TC319-CURRENT_LINE.
    ELSE.
      MESSAGE i412(zfi).
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check INPUT.

*  IF ZFIVMSBANK-BANKL_NEW IS NOT INITIAL AND ZFIVMSBANK-BANKN_NEW IS NOT INITIAL  .
***    Commented on 3.5.21 by ss  *******
*  IF ZFIVMSBANK-ZBNKT+0(2) <> 'EM'.
*    MESSAGE 'Partner Bank Type should start from EM' TYPE 'E'.
*
*  ELSEIF ZFIVMSBANK-ZBNKT NA '1234567890'.
*    MESSAGE 'Enter Patner Bank Type' TYPE 'E'.


*  ELSEIF ZFIVMSBANK-ZBNKT+2(2) is not INITIAL.
*    data: lv_num(2).
*    lv_num = ZFIVMSBANK-ZBNKT+2(2).
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        INPUT         = lv_num
*     IMPORTING
*       OUTPUT        = lv_num.
*
*    CONCATENATE 'EM'lv_num into ZFIVMSBANK-ZBNKT.
**  Commented by ss on 3.5.21

**  BOC by ss on 3.5.21
  DATA: lv_em(2).
  SELECT lifnr ,bvtyp FROM lfbk INTO TABLE @DATA(it_em) WHERE lifnr EQ @zfivmsbank-lifnr.  "#EC CI_NOORDER
*                                AND BVTYP EQ @ZFIVMSBANK-ZBNKT. Commented by ss on 3.5.21
  IF sy-subrc = 0.
    SORT it_em DESCENDING BY bvtyp.
*      MESSAGE 'This Partner Bank Type already exist' TYPE 'E'.  Commented by ss on 3.5.21
    READ TABLE it_em INTO DATA(wa_em) INDEX 1.
    lv_em = wa_em-bvtyp+2(2) + 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_em
      IMPORTING
        output = lv_em.

    CONCATENATE 'EM' lv_em INTO zfivmsbank-zbnkt.
**  EOC by ss on 3.5.21
  ELSE.
    CONCATENATE 'EM' '01' INTO zfivmsbank-zbnkt.
  ENDIF.

*  ENDIF.
*  ENDIF.
  IF zfivmsbank-bankl_new IS NOT INITIAL AND zfivmsbank-bankn_new IS NOT INITIAL  .

*    SELECT SINGLE * FROM lfbk INTO @data(gs_lfbk) WHERE LIFNR EQ @ZFIVMSBANK-LIFNR
*                                                    AND bankl eq @ZFIVMSBANK-BANKL_NEW.
*
*      IF sy-subrc = 0.
*        MESSAGE 'Bank key already exist' TYPE 'E'.
*      ENDIF.

    SELECT SINGLE * FROM lfbk INTO @DATA(gs_lfbk) WHERE lifnr EQ @zfivmsbank-lifnr
                                                  AND bankn EQ @zfivmsbank-bankn_new
                                                 AND  bankl EQ @zfivmsbank-bankl_new.

    IF sy-subrc = 0.
      MESSAGE 'Bank Account already exist' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LIST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list INPUT.

*  ************ BOC on 1.4.2021 by ss
  CLEAR g_list1.
  IF g_okcode931 = 'CREATE'.
    g_value1-text = 'OVL'.
    g_value1-key = 'OVL'.
    APPEND g_value1 TO g_list1.
    CLEAR g_value1.


    g_value1-text = 'OVC'.
    g_value1-key = 'OVC'.
    APPEND g_value1 TO g_list1.
    CLEAR g_value1.

    g_id1 = 'G_CCODE'.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = g_id1
        values = g_list1.

  ELSE.
    g_ccode = g_tc319_wa-ccode.
  ENDIF.

*********************** EOC on 1.4.2021


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LIST1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list1 INPUT.
** Added on 7.4.21  by ss
  CLEAR g_list1.
  IF g_okcode931 = 'CREATE'.
    g_value1-text = 'OVL'.
    g_value1-key = 'OVL'.
    APPEND g_value1 TO g_list1.
    CLEAR g_value1.


    g_value1-text = 'OVC'.
    g_value1-key = 'OVC'.
    APPEND g_value1 TO g_list1.
    CLEAR g_value1.

    g_id1 = 'G_CCODE'.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = g_id1
        values = g_list1.

  ELSE.
    g_ccode = g_tc321_wa-ccode.
  ENDIF.

*********************** EOC on 7.4.2021

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PARTNER_BANK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE partner_bank INPUT.

  DATA :i_kunnr LIKE  knbk-kunnr,
        i_lifnr LIKE  lfbk-lifnr,
        i_xshow LIKE  rfcu4-flagx,
        e_bvtyp LIKE  lfbk-bvtyp.

  DATA: lt_read1 TYPE STANDARD TABLE OF dynpread,
        ls_read1 TYPE dynpread.

  REFRESH  lt_read1[].
  CLEAR ls_read1.
  ls_read1-fieldname = 'ZFIVMSBANK-LIFNR'.
  APPEND ls_read1 TO lt_read1.
  CLEAR : ls_read1.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read1
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE lt_read1 INTO ls_read1 WITH KEY fieldname = 'ZFIVMSBANK-LIFNR'.
  IF sy-subrc = 0.
    i_lifnr = ls_read1-fieldvalue.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = i_lifnr
      IMPORTING
        output = i_lifnr.
  ENDIF.


  CALL FUNCTION 'FI_F4_BVTYP'
    EXPORTING
      i_kunnr = i_kunnr
      i_lifnr = i_lifnr
      i_xshow = i_xshow
    IMPORTING
      e_bvtyp = e_bvtyp.
  IF NOT e_bvtyp IS INITIAL.
    zfivmsbank-zbnkt = e_bvtyp.
  ENDIF.

ENDMODULE.

MODULE validate_cin INPUT.
* DATA chk_pan(1) TYPE C.
  DATA cin_len TYPE i.

  IF wa_vend-vend-j_1ipanno IS NOT INITIAL.
    CLEAR chk_pan.
    chk_pan = wa_vend-vend-j_1ipanno+3(1).
    IF chk_pan = 'C' AND  wa_vend-vend-cin_number IS INITIAL.
      MESSAGE 'Please enter 21 digit CIN number for Company vendor' TYPE 'E'.
    ENDIF.
    IF wa_vend-vend-cin_number IS NOT INITIAL.
      cin_len = strlen( wa_vend-vend-cin_number ).
      IF cin_len NE 21.
        MESSAGE 'Please enter 21 digit CIN number for Company vendor' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.

*--- S/4 helper: display vendor as Business Partner (replaces MK03) - SAP_ABAP 16.06.2026 ---
FORM zz_s4_show_vendor_bp USING p_lifnr TYPE lifnr.
  DATA lv_bp TYPE bu_partner.
  SELECT SINGLE but000~partner INTO @lv_bp FROM cvi_vend_link
    INNER JOIN but000 ON but000~partner_guid = cvi_vend_link~partner_guid
    WHERE cvi_vend_link~vendor = @p_lifnr.
  IF sy-subrc = 0.
    DATA(request) = NEW cl_bupa_navigation_request( ).
    request->set_partner_number( lv_bp ).
    request->set_bupa_activity( iv_value = request->gc_activity_display ).
    DATA(options) = NEW cl_bupa_dialog_joel_options( ).
    options->set_navigation_disabled( abap_true ).
    cl_bupa_dialog_joel=>start_with_navigation( iv_request = request iv_options = options ).
  ENDIF.
ENDFORM.
*--- S/4 helper: update vendor central data via VMD_EI_API (replaces MODIFY lfa1) SAP_ABAP 16.06.2026 ---
FORM zz_s4_update_vendor_central USING p_lifnr TYPE lifnr p_brsch TYPE lfa1-brsch p_stenr TYPE lfa1-stenr.
  DATA: ls_main TYPE vmds_ei_main, ls_ext TYPE vmds_ei_extern, ls_def TYPE vmds_ei_main.
  CLEAR: ls_main, ls_ext, ls_def.
  ls_ext-header-object_instance-lifnr = p_lifnr.
  ls_ext-header-object_task = 'U'.
  ls_ext-central_data-central-data-brsch  = p_brsch.
  ls_ext-central_data-central-datax-brsch = abap_true.
  ls_ext-central_data-central-data-stenr  = p_stenr.
  ls_ext-central_data-central-datax-stenr = abap_true.
  APPEND ls_ext TO ls_main-vendors.
  CALL METHOD vmd_ei_api=>maintain_bapi
    EXPORTING iv_test_run = space iv_collect_messages = 'X' is_master_data = ls_main
    IMPORTING es_master_data_defective = ls_def.
  IF ls_def-vendors IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.
