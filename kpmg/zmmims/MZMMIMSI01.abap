*----------------------------------------------------------------------*
*   INCLUDE MZMMIMSI01                                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CANCEL_0100  INPUT
*&---------------------------------------------------------------------*
*   To exit from program at any time
*----------------------------------------------------------------------*
MODULE cancel_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " CANCEL_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*  To navigate to screen 0150
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  g_ok_code = ok_code.

  CLEAR ok_code.

  CASE g_ok_code.

    WHEN 'NEW'.

      PERFORM chk_user_authority USING sy-uname.            "+005

      PERFORM set_po_text_lebel.

      PERFORM set_global_val.

      CALL SCREEN '0200'.

*   WHEN 'CHNG' OR 'DISP'.                                  "-005
    WHEN 'CHNG'.                                            "+005

      PERFORM chk_user_authority USING sy-uname.            "+005

      PERFORM set_po_text_lebel.

      CALL SCREEN '0150'.

*+005 - Start
    WHEN 'DISP'.

      GET PARAMETER ID 'ZIMS' FIELD wa_zmm_ims-trackno.     "+005

      PERFORM set_po_text_lebel.

      CALL SCREEN '0150'.
*+005 - End

*+006 - Start
    WHEN 'DELE'.

      PERFORM chk_user_authority USING sy-uname.

      PERFORM set_po_text_lebel.

      CALL SCREEN '0150'.

    WHEN 'MRGE'.

*      PERFORM chk_user_authority USING sy-uname.

      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = 'MIR7'
        EXCEPTIONS
          ok     = 0
          not_ok = 1.

      IF sy-subrc <> 0.
        MESSAGE e150(00) WITH text-041.
      ENDIF.

      PERFORM set_global_val.                               "+012

      CALL SCREEN '0300'.

*+006 - End

    WHEN 'UPDI'.

*Update Vendor Invoice Status
      SUBMIT zmm_upd_ims_status AND RETURN.

*   WHEN 'MISR'.                                            "-007
    WHEN 'MISR' OR 'MIS1'.                                  "+007

      SUBMIT zmm_ims_status VIA SELECTION-SCREEN AND RETURN.

*   WHEN 'AGRE'.                                            "-007
    WHEN 'AGRE' OR 'MIS2'.                                  "+007

      SUBMIT zmm_ims_aging_report VIA SELECTION-SCREEN AND RETURN.

    WHEN 'HELP'.

*     PERFORM disp_process_guide.                           "-012
      PERFORM disp_process_guide USING 'IMSHELP'.           "+012

*+001 - Print IMS Tracking Number - Start
    WHEN 'TRAK'.

      SUBMIT zmm_ims_report VIA SELECTION-SCREEN AND RETURN.

    WHEN 'LIST'.

      SUBMIT zmm_ims_list VIA SELECTION-SCREEN AND RETURN.

    WHEN 'REPORT'.
      SUBMIT zmm_ims_rep_all VIA SELECTION-SCREEN AND RETURN.

*+001 - End

*+004 - Print IMS Tracking Number - Start

*   WHEN 'DWTR'.                                            "-007
    WHEN 'DWTR' OR 'MIS3'.                                  "+007

      SUBMIT zmm_ims_aging_status VIA SELECTION-SCREEN AND RETURN.

*+004 -End

*+012 - List of merged ims tracking number
    WHEN 'MLST'.

      SUBMIT zmm_ims_merge_list VIA SELECTION-SCREEN AND RETURN.

*List of disagree ims tracking number
    WHEN 'DLST'.

      SUBMIT zmm_ims_disagree_list VIA SELECTION-SCREEN AND RETURN.

*+012 - End

*+014 - Vendor's Invoice details
    WHEN 'MIS4'.

      SUBMIT zmm_ims_status_new VIA SELECTION-SCREEN AND RETURN.
*+014 - End

*+015 - Update IMS tracking no. with Balmer Lawrie bills
    WHEN 'BLBL'.
      CALL SCREEN 0600.
*+015 - End
    WHEN 'RIO'.
*      CALL SCREEN '0650'.
      CALL SCREEN '0700'.
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 11.11.2014  FOR  CALLING SES REPORT  RD1K994954

    WHEN 'UPDATESES'.
      SUBMIT zmm_upd_ims_ref_ses  VIA SELECTION-SCREEN AND RETURN.

    WHEN 'UPDFIDOC'.

      CALL TRANSACTION 'ZFIUPDATEPAYREF'.

      "END OF ADDITION BY LIPSY ON 11.11.2014 FOR   CALLING SES REPORT RD1K994954

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    WHEN 'SETSTATUS'.
      CALL TRANSACTION 'ZMMIMSSETSTATUS'.

    WHEN 'UPDRMK'.
*         submit ZMM_IMS_MASS_FIRMK_UPD via SELECTION-SCREEN and RETURN.
      SUBMIT zmm_ims_mass_firmk_upd_oo VIA SELECTION-SCREEN AND RETURN.

    WHEN 'UPD_LIVDT'. ""Correct the inconsistency between date of LIV doc and tracking no.

      DATA lv_ans TYPE c.  ""

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Alert'
*         DIAGNOSE_OBJECT             = ' '
          text_question  = 'Do you want to execute the update program?'
          text_button_1  = 'Yes'
*         ICON_BUTTON_1  = ' '
          text_button_2  = 'No'
*         ICON_BUTTON_2  = ' '
*         DEFAULT_BUTTON = '1'
*         DISPLAY_CANCEL_BUTTON       = 'X'
*         USERDEFINED_F1_HELP         = ' '
*         START_COLUMN   = 25
*         START_ROW      = 6
*         POPUP_TYPE     =
*         IV_QUICKINFO_BUTTON_1       = ' '
*         IV_QUICKINFO_BUTTON_2       = ' '
        IMPORTING
          answer         = lv_ans
*       TABLES
*         PARAMETER      =
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
*       Implement suitable error handling here
      ENDIF.

      IF lv_ans = '1'.
        SUBMIT zmm_ims_upd_entrydate .
      ENDIF.



  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0150  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0150 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " CANCEL_0150  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_validation  INPUT
*&---------------------------------------------------------------------*
*    Checks for input field, if input field is null, display error
*    message - screen 0150
*----------------------------------------------------------------------*
MODULE check_validation INPUT.

  CASE g_ok_code.

    WHEN 'CHNG'.

      PERFORM check_validation_150 USING wa_zmm_ims-trackno.

*   WHEN 'DISP'.                                            "-006
    WHEN 'DISP' OR 'DELE'.                                  "+006

      PERFORM check_validation_150 USING wa_zmm_ims-trackno.

  ENDCASE.

ENDMODULE.                 " check_validation  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
* To call screen 200.
* Lock the record(s) in case of change/delete before calling screen 0200
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.

  CASE g_ok_code.

    WHEN 'CHNG'.

      IF NOT wa_zmm_ims-trackno IS INITIAL AND
         NOT wa_zmm_ims-tracktyp IS INITIAL.

        PERFORM lock_record USING wa_zmm_ims-trackno
                                  wa_zmm_ims-tracktyp.

*        PERFORM lock_record_status USING wa_zmm_ims-trackno
*                                         wa_zmm_ims-tracktyp. "+003

        CALL SCREEN '0200'.

      ENDIF.

    WHEN 'DISP'.

      IF NOT wa_zmm_ims-trackno IS INITIAL AND
      NOT wa_zmm_ims-tracktyp IS INITIAL.

*+011- Start
        IF wa_zmm_ims-tracktyp = 'M' AND
           g_rb_mat IS INITIAL.

          MESSAGE w857(zmm) WITH text-045.

        ELSEIF wa_zmm_ims-tracktyp = 'S' AND
           g_rb_srv IS INITIAL.

          MESSAGE w857(zmm) WITH text-046.

        ELSEIF wa_zmm_ims-tracktyp = 'F' AND
           g_rb_fi IS INITIAL.

          MESSAGE w857(zmm) WITH text-047.

        ENDIF.
*+011- End

        CALL SCREEN '0200'.

      ENDIF.

*+006 - Start
    WHEN 'DELE'.

      IF NOT wa_zmm_ims-trackno IS INITIAL AND
         NOT wa_zmm_ims-tracktyp IS INITIAL.

        PERFORM lock_record USING wa_zmm_ims-trackno
                                  wa_zmm_ims-tracktyp.
        CALL SCREEN '0200'.

      ENDIF.
*+006 - End

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0150  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0200  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0200 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE g_ok_code.
    WHEN 'NEW'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.

          CLEAR : g_ans.

*         PERFORM confirm_input  CHANGING g_ans.            "-006
          PERFORM confirm_input  USING text-009
                                       '1'
                                 CHANGING g_ans.            "+006

          IF g_ans = '2'.
            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ELSEIF g_ans = '1'.
            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.
          ENDIF.
      ENDCASE.

    WHEN 'CHNG'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR : g_ans.

*         PERFORM confirm_input  CHANGING g_ans.            "-006
          PERFORM confirm_input  USING    text-009
                                          '1'
                                 CHANGING g_ans.            "+006

          IF g_ans = '2'.

            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.

            PERFORM unlock_record USING wa_zmm_ims-trackno
                                        wa_zmm_ims-tracktyp.

*            PERFORM unlock_record_status USING wa_zmm_ims-trackno
*                                               wa_zmm_ims-tracktyp. "+003

            LEAVE TO SCREEN 100.

          ELSEIF g_ans = '1'.

            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.

          ENDIF.
      ENDCASE.

    WHEN 'DISP'.

      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.

          IF sy-tcode = 'ZMMIMSDISP'.                       "+005
            LEAVE PROGRAM.                                  "+005
          ELSE.                                             "+005
            LEAVE TO SCREEN 100.
          ENDIF.                                            "+005

      ENDCASE.

*+006 - Start
    WHEN 'DELE'.

      CASE save_ok.

        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.

          CLEAR ok_code.
          CLEAR save_ok.

          PERFORM unlock_record USING wa_zmm_ims-trackno
                                      wa_zmm_ims-tracktyp.
          LEAVE TO SCREEN 100.

      ENDCASE.
*+006 - End

  ENDCASE.
ENDMODULE.                 " CANCEL_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*  To perform operations like save/delete record etc by pressing the
*  respective button at application tool bar & Tabstrip.
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
*  IF sy-ucomm = 'MUL'.
*    PERFORM get_range.
*  ENDIF.
  CASE g_ok_code.

    WHEN 'NEW'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.

*+010 - Validation with exiting IMS Tracking by comparing PO
* & Invoice no. : Start
          CLEAR : g_ret.

          IF g_rb_mat = 'X' OR
             g_rb_srv = 'X' OR
             g_rb_fi  = 'X'. "14.06.2013

            PERFORM chk_dup_invoice_enrty CHANGING g_ret.

          ENDIF.

          IF g_ret = '2'.
            CLEAR save_ok.
          ELSE.
*+010 - End
            PERFORM save_data.
            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.

          ENDIF.                                            "+010

      ENDCASE.

    WHEN 'CHNG'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM update_data.
          CLEAR save_ok.
          CLEAR g_ok_code.
          LEAVE TO SCREEN 100.

          """""""""""""
          """""""""""""""""""""""""""""""""
          """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history  RD1K999364

        WHEN 'HIST'.
          SUBMIT zmm_ims_log
                     WITH p_trckno = wa_zmm_ims-trackno
                     AND RETURN.

          """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history RD1K999364





          """"""""""""""""""""""""""""""""""""""""""""

          """"""""""

      ENDCASE.

    WHEN 'DISP'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.

          """""""""""
          """""""""""""""""""""""""""""""""
          """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history RD1K999364
        WHEN 'HIST'.
          SUBMIT zmm_ims_log
                   WITH p_trckno = wa_zmm_ims-trackno
                     AND RETURN.

          """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history RD1K999364

          """"""""""""""""""""""""""""""""""""""""""""
          """"""""""""""
      ENDCASE.

*+006 - Start
    WHEN 'DELE'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.

          PERFORM delete_data.
          CLEAR save_ok.
          CLEAR g_ok_code.
          LEAVE TO SCREEN 100.
          "
          """""""""""""""""""""""""""""""""
          """""added by lipsy on 14.12.2015 for invoice no,value,dt,currency history RD1K999364
        WHEN 'HIST'.
          SUBMIT zmm_ims_log
                     WITH p_trckno = wa_zmm_ims-trackno
                     AND RETURN.

          """""end of addition by lipsy on 14.12.2015 for invoice no,value,dt,currency history RD1K999364





          """"""""""""""""""""""""""""""""""""""""""""

          "
      ENDCASE.
*+006 - End



  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  valid_input_200  INPUT
*&---------------------------------------------------------------------*
* Checks for input field, if input field is null or not valid, display
* error message - screen 0200
*----------------------------------------------------------------------*
MODULE valid_input_200 INPUT.

  IF g_rb_fi = 'X'.

    IF NOT wa_zmm_ims-lifnr IS INITIAL.

      PERFORM chk_input_value USING wa_zmm_ims-lifnr
                                    wa_zmm_ims-ebeln.
    ENDIF.

  ELSE.

    IF NOT wa_zmm_ims-lifnr IS INITIAL AND
       NOT wa_zmm_ims-ebeln IS INITIAL.

      PERFORM chk_input_value USING wa_zmm_ims-lifnr
                                    wa_zmm_ims-ebeln.

    ENDIF.

    IF NOT wa_zmm_ims-werks IS INITIAL.

      READ TABLE ist_werks INTO wa_werks
                  WITH KEY werks = wa_zmm_ims-werks.

      IF sy-subrc = 0.

        MOVE wa_werks-name1 TO g_name1.

      ENDIF.

    ENDIF.

  ENDIF.

*+001 - Validation on location
* IF NOT wa_zmm_ims-reqloc IS INITIAL.                      "-006
  IF NOT wa_zmm_ims-reqloc IS INITIAL OR
         wa_zmm_ims-reqloc = '000000'.                      "+006

    PERFORM chk_location USING wa_zmm_ims-reqloc.

  ENDIF.
*+001 - End

*+005 - Validation on Invoice value & date
  IF wa_zmm_ims-invoicedt > sy-datum.

    MESSAGE e807(zmm).

  ENDIF.

  IF NOT wa_zmm_ims-email IS INITIAL.

    PERFORM chk_mailid USING wa_zmm_ims-email.

  ENDIF.
*+005 - End

*+006 - PO Created by with name
  IF NOT wa_zmm_ims-ebeln IS INITIAL.

    SELECT SINGLE ernam FROM ekko INTO g_ernam
          WHERE ebeln = wa_zmm_ims-ebeln.

    IF sy-subrc = 0.

      PERFORM get_uname USING    g_ernam
                        CHANGING g_poernam.

    ENDIF.

  ENDIF.
*+006 - End

*+019 - Start : propose the GeM Invoice No. of the PO - no F4 needed
  PERFORM get_gem_invoice_no.                               "+019
*+019 - End

*+010 - Validation with exiting IMS Tracking by comparing PO
* & Invoice no. : Start
*  IF g_rb_mat = 'X'.
*    PERFORM chk_dup_invoice_enrty.
*  ENDIF.
*+010 - End

*+011 - Validation on currency

  IF NOT wa_zmm_ims-waers IS INITIAL.

    SELECT SINGLE waers FROM tcurc INTO (tcurc-waers)
      WHERE waers = wa_zmm_ims-waers.

    IF sy-subrc NE 0.

      MESSAGE e100(f5a) WITH wa_zmm_ims-waers.

    ENDIF.

  ENDIF.
*+011 - End

*+016 : In case of direct FI, Section is mandatory
  IF wa_zmm_ims-ekgrp IS INITIAL.

    SET CURSOR FIELD 'WA_ZMM_IMS-EKGRP'.
    MESSAGE e926(zmm).

  ENDIF.
*+016 : End

*+018 : Start
  IF wa_zmm_ims-invoiceval LE 0.
    MESSAGE e543(zmm) WITH text-067.
  ENDIF.
*+018 : End

ENDMODULE.                 " valid_input_200  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
* To get F4 help on plant
*----------------------------------------------------------------------*
MODULE get_lov_werks INPUT.

  REFRESH : ist_return_tab.                                 "+006

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WERKS'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-WERKS'
      value_org       = 'S'
    TABLES
      value_tab       = ist_werks
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  wa_zmm_ims-werks =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_GLOBAL_VAR  INPUT
*&---------------------------------------------------------------------*
* To initialize global variables
*----------------------------------------------------------------------*
MODULE init_global_var INPUT.

  CLEAR : g_loctext   ,
          g_name1     ,
          g_created_by,
          g_created_on,
          g_vname,
          i_name.                                          "+003

*+006 - Start
  CLEAR : g_eknam,
          g_ernam,
          g_poernam.

  REFRESH : ist_zmm_ims_hdr,
            ist_zmm_ims_status,
            ist_trackno,
            ist_trackno_del.                     "+018

  CLEAR : wa_trackno,
          wa_zmm_ims_hdr,
          wa_zmm_ims_status,
          wa_zmm_ims_dtl,
          wa_zmm_ims.
  CLEAR : wa_zmm_ims-zzindper,
          wa_zmm_ims-zzname.

  g_first = 'X'.
  g_change = '1'.

  REFRESH CONTROL 'ZMM_IMS_CTRL' FROM SCREEN 0300.
*+006 - End

ENDMODULE.                 " INIT_GLOBAL_VAR  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_PID_0150  INPUT
*&---------------------------------------------------------------------*
* To set parameter ID - Display mode
*----------------------------------------------------------------------*
MODULE set_pid_0150 INPUT.

  IF sy-tcode =  'ZMMIMSDISP' AND g_ok_code = 'DISP'.

    SET PARAMETER ID 'ZIMS' FIELD wa_zmm_ims-trackno.

    IF wa_zmm_ims-tracktyp = 'M'.
      g_rb_mat = 'X'.
      g_po_lebel = text-007.
      g_sec_label = text-038.                               "+006
    ELSEIF wa_zmm_ims-tracktyp = 'S'.
      g_rb_srv = 'X'.
      g_po_lebel = text-026.
      g_sec_label = text-038.                               "+006
    ELSEIF wa_zmm_ims-tracktyp = 'F'.
      g_rb_fi = 'X'.
      g_sec_label = text-039.                               "+006
    ENDIF.

  ENDIF.

ENDMODULE.                 " SET_PID_0150  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_MAILID  INPUT
*&---------------------------------------------------------------------*
* To check email ID & if blank fetch mail ID from vendor master table
*----------------------------------------------------------------------*
MODULE get_mailid INPUT.

  IF g_ok_code <> 'DISP'.

    IF wa_zmm_ims-email IS INITIAL.

      PERFORM get_mailid  USING    wa_zmm_ims-lifnr
                          CHANGING wa_zmm_ims-email.


      """"""""""""""
      "eadded by lipsy
    ELSE.

      CLEAR:l_lifnr_new,l_adrnr_new,v_exist_email,v_exist_adrnr.

      l_lifnr_new = wa_zmm_ims-lifnr.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = l_lifnr_new
        IMPORTING
          output = l_lifnr_new.

      SELECT SINGLE adrnr FROM lfa1
                INTO   l_adrnr_new
                  WHERE lifnr = l_lifnr_new.

      IF sy-subrc = 0.

        SELECT SINGLE smtp_addr FROM adr6
                  INTO  v_exist_email
                    WHERE addrnumber = l_adrnr_new.

        IF sy-subrc = 0.
        ELSE.

          v_exist_email  = wa_zmm_ims-email.
          v_exist_adrnr = l_adrnr_new.
        ENDIF.

      ENDIF.
      "end of addition on 14.12.2015 for updating email
      """"""""""""""""""""""""""""""""""""""""""



      """""""""""""""
    ENDIF.

  ENDIF.

ENDMODULE.                 " GET_MAILID  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_EKGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_lov_ekgrp INPUT.

  REFRESH : ist_return_tab,
            ist_t024.

  SELECT ekgrp eknam FROM t024 INTO TABLE ist_t024.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EKGRP'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-EKGRP'
      value_org       = 'S'
    TABLES
      value_tab       = ist_t024
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  wa_zmm_ims-ekgrp =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_EKGRP  INPUT

*&---------------------------------------------------------------------*
*&      Module  cancel_0300  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0300 INPUT.

  save_ok = ok_code.

  CLEAR ok_code.

  CASE g_ok_code.

    WHEN 'MRGE'.

      CASE save_ok.

        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.

          CLEAR save_ok.

          LEAVE TO SCREEN 0.

      ENDCASE.

  ENDCASE.

ENDMODULE.                 " cancel_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  REFRESH_INT_TAB  INPUT
*&---------------------------------------------------------------------*
*       To refresh internal table ist_trackno
*----------------------------------------------------------------------*
MODULE refresh_int_tab INPUT.

  DESCRIBE TABLE ist_trackno LINES g_lines.

  IF g_lines <= 12.

    REFRESH ist_trackno.

  ENDIF.
ENDMODULE.                 " REFRESH_INT_TAB  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_TRACKNO  INPUT
*&---------------------------------------------------------------------*
* To validate tracking No.
*----------------------------------------------------------------------*
MODULE chk_trackno INPUT.

  IF NOT wa_trackno_tc-trackno IS INITIAL.

    CLEAR : wa_zmm_ims_hdr.

    SELECT SINGLE * FROM zmm_ims INTO wa_zmm_ims_hdr
       WHERE trackno  = wa_trackno_tc-trackno AND
             tracktyp = wa_zmm_ims-tracktyp.                "+012

    IF sy-subrc <> 0.

      MESSAGE e817(zmm).

    ELSE.

      IF wa_zmm_ims_hdr-trackno = wa_zmm_ims-trackno.

        MESSAGE e818(zmm).

      ENDIF.

      IF g_first = 'X'.

      ELSE.

        IF NOT ( wa_zmm_ims_hdr-tracktyp = wa_zmm_ims-tracktyp AND
                 wa_zmm_ims_hdr-lifnr    = wa_zmm_ims-lifnr    AND
                 wa_zmm_ims_hdr-ebeln    = wa_zmm_ims-ebeln ).

*+014 : While merging in services, system should allow merging tracking
*       nos.made against contract and its 506 POs.

          IF wa_zmm_ims-tracktyp = 'S' AND
             ( wa_zmm_ims_hdr-ebeln+0(3) = '506' OR
               wa_zmm_ims-ebeln+0(3)     = '506' ).

            PERFORM chk_contract USING wa_zmm_ims_hdr-ebeln
                                       wa_zmm_ims-ebeln.
*+018 : Start
          ELSEIF wa_zmm_ims-tracktyp = 'S' AND
             ( wa_zmm_ims_hdr-ebeln+0(3) = '501' OR
               wa_zmm_ims-ebeln+0(3)     = '501' ).

            PERFORM chk_contract_1 USING wa_zmm_ims_hdr-ebeln
                                         wa_zmm_ims-ebeln.
*+018 : End
          ELSE.
*+014 : End

            MESSAGE e817(zmm).

          ENDIF.                                            "+014

        ENDIF.

      ENDIF.

*-012 : Start
*      SELECT SINGLE * FROM zmm_ims_status INTO wa_zmm_ims_dtl
*             WHERE trackno = wa_trackno_tc-trackno.
*
*      IF sy-subrc = 0.
*
**       IF wa_zmm_ims_dtl-mbli_stat = 'G'.                  "-012
*        IF wa_zmm_ims_dtl-mbll_stat = 'G'.                  "+012 LIV
*
*          MESSAGE e836(zmm).
*
*        ENDIF.
*
*      ENDIF.
*-012 : End

      PERFORM chk_mrg_trackno USING wa_trackno_tc-trackno
                                    wa_zmm_ims-tracktyp.    "+012
    ENDIF.

  ENDIF.

ENDMODULE.                 " CHK_TRACKNO  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control_0300  INPUT
*&---------------------------------------------------------------------*
*  Move table control table data into internal table ist_trackno
*----------------------------------------------------------------------*
MODULE read_table_control_0300 INPUT.

  CLEAR : g_lines.

  MOVE-CORRESPONDING wa_trackno_tc TO wa_trackno.

*  IF NOT wa_trackno-trackno IS INITIAL.          "+018

*-018 : Start
*    DESCRIBE TABLE ist_trackno LINES g_lines.
*
*    IF g_lines <= 12.
*
*      INSERT wa_trackno INTO ist_trackno INDEX
*                            zmm_ims_ctrl-current_line.
*    ELSE.
*-018 : End
  MODIFY ist_trackno FROM wa_trackno INDEX
                        zmm_ims_ctrl-current_line.

*    ENDIF.                                      "-018
*+018 : Start
  IF sy-subrc NE 0.

    APPEND wa_trackno TO ist_trackno.

*    INSERT wa_trackno INTO ist_trackno INDEX
*                        zmm_ims_ctrl-current_line.
  ENDIF.

*  ENDIF.
*+018 : End

ENDMODULE.                 " read_table_control_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*  To Merge IMS tracking nos with ref. to processe IMS tracking number
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE g_ok_code.

    WHEN 'MRGE'.

      save_ok = ok_code.

      CLEAR ok_code.

      CASE save_ok.

        WHEN 'SAVE'.

          CLEAR : g_sy_subrc.

          PERFORM merge_ims_track_nos CHANGING g_sy_subrc.

          IF g_sy_subrc = 4.


            CLEAR save_ok.

          ELSE.

            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.

          ENDIF.

*+012 : Process guide for IMS Merge program
        WHEN 'HLP1'.
          PERFORM disp_process_guide USING 'IMSHELP2'.
*+012 : End

*+018 : Start
        WHEN 'DEL'.
          PERFORM del_ims_line.
*+018 : End
      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_CURR  INPUT
*&---------------------------------------------------------------------*
* F4 help - Currency field
*----------------------------------------------------------------------*
MODULE get_lov_curr INPUT.

  REFRESH : ist_return_tab,
            ist_tcurt.

  SELECT waers ltext FROM tcurt INTO TABLE ist_tcurt
                     WHERE spras = 'E'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'WAERS'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-WAERS'
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

  wa_zmm_ims-waers =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_CURR  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALID_TRACKNO  INPUT
*&---------------------------------------------------------------------*
* To validate tracking no. : Screen 0400
*----------------------------------------------------------------------*
MODULE valid_trackno INPUT.

  IF NOT wa_zmm_ims-trackno IS INITIAL.

    SELECT * FROM ZMM_IMS INTO WA_ZMM_IMS UP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF sy-subrc <> 0.

      MESSAGE e792(zmm) WITH wa_zmm_ims-trackno.

    ENDIF.

    IF wa_zmm_ims-lvorm = 'X'.

      MESSAGE e814(zmm) WITH wa_zmm_ims-trackno.

    ENDIF.

  ENDIF.

  SELECT * FROM ZMM_IMS_STATUS INTO WA_ZMM_IMS_STATUS UP TO 1 ROWS
 WHERE TRACKNO = WA_ZMM_IMS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

ENDMODULE.                 " VALID_TRACKNO  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0400  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0400 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " CANCEL_0400  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*  To navigate to screen 0500
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  g_ok_code = 'MODI'.

  PERFORM lock_record USING wa_zmm_ims-trackno
                            wa_zmm_ims-tracktyp.

  IF wa_zmm_ims-tracktyp = 'M'.

    g_grv_ses_lbl    = text-054.
    g_grv_ses_io_lbl = text-055.

  ELSEIF wa_zmm_ims-tracktyp = 'S'.

    g_grv_ses_lbl = text-056.
    g_grv_ses_io_lbl = text-057.

  ENDIF.

  CALL SCREEN 500.

ENDMODULE.                 " USER_COMMAND_0400  INPUT

*&---------------------------------------------------------------------*
*&      Module  CANCEL_0500  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0500 INPUT.

  save_ok = ok_code.
  CLEAR ok_code.

  CASE g_ok_code.

    WHEN 'MODI'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR : g_ans.

          PERFORM confirm_input  USING    text-009
                                          '1'
                                 CHANGING g_ans.

          IF g_ans = '2'.

            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.

            PERFORM unlock_record USING wa_zmm_ims-trackno
                                        wa_zmm_ims-tracktyp.

            LEAVE TO SCREEN 400.

          ELSEIF g_ans = '1'.

            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.

          ENDIF.
      ENDCASE.

  ENDCASE.
ENDMODULE.                 " CANCEL_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*  To perform operations like update record etc by pressing the
*  respective button at application tool bar.
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  CASE g_ok_code.

    WHEN 'MODI'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM update_data_0500.
          CLEAR save_ok.
          CLEAR g_ok_code.
          LEAVE TO SCREEN 400.

      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  cancel_0600  INPUT
*&---------------------------------------------------------------------*
*  To exit from screen at any time
*----------------------------------------------------------------------*
MODULE cancel_0600 INPUT.

  save_ok = ok_code.

  CLEAR ok_code.

  CASE save_ok.

    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.

      CLEAR : g_ans.

      PERFORM confirm_input  USING  text-059
                                       '1'
                              CHANGING g_ans.
      IF g_ans = '1'.

        CLEAR save_ok.

        LEAVE TO SCREEN 0.

      ELSEIF g_ans = '2'.

      ENDIF.

  ENDCASE.

ENDMODULE.                 " cancel_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOV_TRACKNO  INPUT
*&---------------------------------------------------------------------*
* To get F4 help on plant
*----------------------------------------------------------------------*
MODULE get_lov_trackno INPUT.

  REFRESH : ist_return_tab,
            ist_track_bl_f4,
            ist_track_bl_f4_t.

  SELECT * FROM zmm_ims_status
    INTO CORRESPONDING FIELDS OF TABLE ist_track_bl_f4_t
       WHERE tracktyp  = 'F' AND
             mbli_stat NE 'G'.

  IF NOT ist_track_bl_f4_t[] IS INITIAL.

    SELECT * FROM zmm_ims
      INTO CORRESPONDING FIELDS OF TABLE ist_track_bl_f4
        FOR ALL ENTRIES IN ist_track_bl_f4_t
           WHERE trackno  = ist_track_bl_f4_t-trackno AND
                 tracktyp = ist_track_bl_f4_t-tracktyp.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TRACKNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_TRACK_BL_TC-TRACKNO'
      value_org       = 'S'
    TABLES
      value_tab       = ist_track_bl_f4
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.

  wa_track_bl_tc-trackno =  ist_return_tab-fieldval.

ENDMODULE.                 " GET_LOV_TRACKNO  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_TRACKNO_BL  INPUT
*&---------------------------------------------------------------------*
* To validate tracking No. : Screen 0600
*----------------------------------------------------------------------*
MODULE chk_trackno_bl INPUT.

  IF NOT wa_track_bl_tc-trackno IS INITIAL.

    CLEAR : wa_zmm_ims_dtl.

    SELECT SINGLE * FROM zmm_ims_status INTO wa_zmm_ims_dtl
       WHERE trackno   = wa_track_bl_tc-trackno AND
             tracktyp  = 'F' AND
             mbli_stat NE 'G'.

    IF sy-subrc <> 0.

      MESSAGE e817(zmm).

    ENDIF.

  ENDIF.

*+018 : Start

  IF NOT wa_track_bl_tc-bukrs       IS INITIAL AND
     NOT wa_track_bl_tc-mblnr_inv   IS INITIAL AND
     NOT wa_track_bl_tc-mblnr_invdt IS INITIAL.

    PERFORM chk_fi_docno USING wa_track_bl_tc-trackno
                               wa_track_bl_tc-bukrs
                               wa_track_bl_tc-mblnr_inv
                               wa_track_bl_tc-mblnr_invdt.
  ENDIF.

*+018 : End
ENDMODULE.                 " CHK_TRACKNO_BL  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control_0600  INPUT
*&---------------------------------------------------------------------*
*  Move table control table data into internal table ist_track_bl
*----------------------------------------------------------------------*
MODULE read_table_control_0600 INPUT.

  CLEAR : g_lines.

  MOVE-CORRESPONDING wa_track_bl_tc TO wa_track_bl.

  DESCRIBE TABLE ist_track_bl LINES g_lines.

  IF g_lines <= 20.

    INSERT wa_track_bl INTO ist_track_bl INDEX
                          zmm_ims_bl_ctrl-current_line.
  ELSE.

    MODIFY ist_track_bl FROM wa_track_bl INDEX
                          zmm_ims_bl_ctrl-current_line.
  ENDIF.

ENDMODULE.                 " read_table_control_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  REFRESH_INT_TAB_0600  INPUT
*&---------------------------------------------------------------------*
*       To refresh internal table ist_trackno
*----------------------------------------------------------------------*
MODULE refresh_int_tab_0600 INPUT.

  DESCRIBE TABLE ist_track_bl LINES g_lines.

  IF g_lines <= 20.

    REFRESH ist_track_bl.

  ENDIF.

ENDMODULE.                 " REFRESH_INT_TAB_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*  To settle IMS tracking nos with ref. to processe IMS tracking number
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.

  save_ok = ok_code.

  CLEAR ok_code.

  CASE save_ok.

    WHEN 'SAVE'.

      CLEAR : g_ans.

      PERFORM confirm_input  USING text-009
                                   '1'
                             CHANGING g_ans.
      IF g_ans = 1.

        PERFORM save_data_600.

      ENDIF.

      CLEAR save_ok.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  PROC_IMS_TRACKNO  INPUT
*&---------------------------------------------------------------------*
* IMS Merge : To process IMS tracking Nos. before PBO / Commit work
*----------------------------------------------------------------------*
MODULE proc_ims_trackno INPUT.

  SORT ist_trackno BY trackno.

  DELETE ADJACENT DUPLICATES FROM ist_trackno COMPARING trackno.

  DELETE ist_trackno WHERE trackno IS INITIAL.

ENDMODULE.                 " PROC_IMS_TRACKNO  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LOV_INDPER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_lov_indper INPUT.
  CLEAR i_name.
  SELECT bname, name_textc FROM user_addr
    INTO TABLE @DATA(it_indper).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-zzindper'
      value_org       = 'S'
    TABLES
      value_tab       = it_indper
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
  wa_zmm_ims-zzindper =  ist_return_tab-fieldval.

  DATA: BEGIN OF dynfield OCCURS 10.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF dynfield.
  dynfield-fieldname = ist_return_tab-retfield.

  dynfield-fieldvalue = ist_return_tab-fieldval.

  APPEND dynfield.

  IF wa_zmm_ims-zzindper IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_zmm_ims-zzindper
      IMPORTING
        output = wa_zmm_ims-zzindper.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
*    SELECT SINGLE name_textc FROM user_addr INTO @DATA(name)
*      WHERE bname = @wa_zmm_ims-zzindper.
     SELECT  name_textc FROM user_addr INTO @DATA(name) UP TO 1 ROWS
      WHERE bname = @wa_zmm_ims-zzindper ORDER BY bname. ENDSELECT.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
    IF sy-subrc = 0.
      wa_zmm_ims-zzname = name.
    ENDIF.

  ENDIF.

  dynfield-fieldname = 'WA_ZMM_IMS-ZZNAME'.

  dynfield-fieldvalue = wa_zmm_ims-zzname.

  APPEND dynfield.

  dynfield-fieldname = 'I_NAME'.

  dynfield-fieldvalue = wa_zmm_ims-zzname.

  APPEND dynfield.

* UPDATE THE DYNPRO VALUES.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dynfield
    EXCEPTIONS
      OTHERS     = 8.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_ZZNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_zzname INPUT.

*  DATA: BEGIN OF dynfield OCCURS 10.
*          INCLUDE STRUCTURE dynpread.
*  DATA: END   OF dynfield.
*  dynfield-fieldname = ist_return_tab-retfield.
*
*  dynfield-fieldvalue = ist_return_tab-fieldval.
*
*  APPEND dynfield.
  DATA: i_zzinder TYPE zmm_ims-zzindper.
  IF wa_zmm_ims-zzindper IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_zmm_ims-zzindper
      IMPORTING
        output = wa_zmm_ims-zzindper.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
*    SELECT SINGLE bname name_textc FROM user_addr INTO (i_zzinder,i_name)
*      WHERE bname = wa_zmm_ims-zzindper.
    SELECT bname name_textc FROM user_addr INTO (i_zzinder,i_name) UP TO 1 ROWS
      WHERE bname = wa_zmm_ims-zzindper ORDER BY bname. ENDSELECT.
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
    IF sy-subrc = 0.
      wa_zmm_ims-zzname = i_name.
    ELSE.
      MESSAGE 'Enter Correct CPF Number' TYPE 'E'.
    ENDIF.

  ENDIF.

  IF wa_zmm_ims-intendor_section IS NOT INITIAL.

    SELECT SINGLE
        intendor_section
 FROM   zims_ind_sec
 INTO   @DATA(it_sec)
        WHERE intendor_section = @wa_zmm_ims-intendor_section.
    IF sy-subrc = 0.

    ELSE.
      MESSAGE 'Enter Correct Indentor Section' TYPE 'E'.
    ENDIF.

  ENDIF.
*  i_name = wa_zmm_ims-zzname.

  dynfield-fieldname = 'WA_ZMM_IMS-ZZNAME'.

  dynfield-fieldvalue = wa_zmm_ims-zzname.

  APPEND dynfield.

  dynfield-fieldname = 'I_NAME'.

  dynfield-fieldvalue = i_name.

  APPEND dynfield.

* UPDATE THE DYNPRO VALUES.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dynfield
    EXCEPTIONS
      OTHERS     = 8.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      IF rad1 = 'X'.
        CALL SCREEN '0650'.
      ELSEIF rad2 = 'X'.
        CALL SCREEN '0650'..
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CANCEL_650  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE cancel_650 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR save_ok.
      CLEAR g_ok_code.
      CLEAR : wa_zmm_ims_status ,zmm_ims_rio-forwarded_to,g_disagree_txt,
        wa_zmm_ims_status-trackno,zmm_ims_rio-zemail.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHK_VALID_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE chk_valid_100 INPUT.


  IF wa_zmm_ims_status-trackno IS INITIAL.

  ELSE.

    SELECT * FROM ZMM_IMS_STATUS UP TO 1 ROWS

 WHERE TRACKNO = WA_ZMM_IMS_STATUS-TRACKNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF rad1 = 'X'.
      IF sy-subrc = 0 AND ( zmm_ims_status-tracktyp = 'S' OR  zmm_ims_status-tracktyp = 'M' ).
        IF zmm_ims_status-mblnr_stk IS INITIAL AND  zmm_ims_status-mblnr_rcpt IS INITIAL.
          MESSAGE 'Return within OVL not possible' TYPE 'E'.
        ENDIF.
      ENDIF.

      IF sy-subrc = 0 AND zmm_ims_status-tracktyp = 'F'.
        IF zmm_ims_status-status IS INITIAL.
          MESSAGE 'Return within OVL not possible' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
    SELECT * FROM zmm_ims_status
      WHERE trackno = wa_zmm_ims_status-trackno
      AND mbll_stat = 'G'.
    ENDSELECT.
    IF sy-subrc = 0.

      MESSAGE 'RIO not possible. Document already posted' TYPE 'E'.
    ELSE.
    ENDIF.

  ENDIF.

  IF rad2 = 'X'.
    SELECT * FROM zmm_ims_rio INTO TABLE @DATA(i_rio)
      WHERE trackno = @wa_zmm_ims_status-trackno
      ORDER BY zdate_on , ztime_at DESCENDING.
    SORT i_rio DESCENDING BY zdate_on ztime_at.

    READ TABLE i_rio INTO DATA(w_rio) INDEX 1.

    IF ok_code = 'AGRE' AND w_rio-qcc_asn = 'D'.
      MESSAGE 'Please Accept from within the organisation' TYPE 'E'.
    ENDIF.

  ELSE.
    SELECT * FROM zmm_ims_rio INTO TABLE i_rio
     WHERE trackno = wa_zmm_ims_status-trackno
     ORDER BY zdate_on ztime_at DESCENDING.
    SORT i_rio DESCENDING BY zdate_on ztime_at.

    READ TABLE i_rio INTO w_rio INDEX 1.

    IF ok_code = 'AGRE' AND w_rio-qcc_asn = 'T'.
      MESSAGE 'Please Accept from outside the organisation' TYPE 'E'.
    ENDIF.


  ENDIF.
ENDMODULE.

MODULE check_cpf.
  DATA: v_cpf TYPE usr21-bname.
  IF zmm_ims_rio-forwarded_to IS NOT INITIAL.
    v_cpf = zmm_ims_rio-forwarded_to.
    SHIFT v_cpf LEFT DELETING LEADING '0'.
    SELECT SINGLE * FROM usr21 INTO @DATA(wa_usr)
     WHERE  bname = @v_cpf.
    IF sy-subrc NE 0.
      MESSAGE 'Please enter correct CPF No.' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FILL_MAIL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_mail INPUT.
  CLEAR : ztrack,zmm_ims_rio-zemail.

  IF rad2 = 'X'.

    ztrack = wa_zmm_ims_status-trackno+0(6).

    CLEAR:wa_lfa1_del,wa_adr6_del.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ztrack
      IMPORTING
        output = ztrack.

    SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF
    wa_lfa1_del WHERE lifnr = ztrack.

    SELECT * FROM ADR6 INTO CORRESPONDING FIELDS OF
 WA_ADR6_DEL UP TO 1 ROWS WHERE ADDRNUMBER = WA_LFA1_DEL-ADRNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    zmm_ims_rio-zemail =  wa_adr6_del-smtp_addr.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0650  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0650 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CLEAR : wa_zmm_ims_rio-timestamp,wa_zmm_ims_rio-qcc_asn,wa_zmm_ims_rio-disagree_by_in,
   wa_zmm_ims_rio-agree_by_in,wa_zmm_ims_rio-zdate_on,wa_zmm_ims_rio-ztime_at,
   wa_zmm_ims_rio-disagree_qc,wa_zmm_ims_rio-forwarded_to,wa_zmm_ims_rio-bukrs.

  CASE save_ok.
    WHEN 'AGRE'.
      PERFORM chk_status USING 'A'.
      CLEAR : g_ret.
      PERFORM chk_remarks CHANGING g_ret.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      IF rad1 = 'X'.
        """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
        PERFORM chk_forwarded_to USING zmm_ims_rio-forwarded_to.
        """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      ENDIF.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      IF g_ret = 'X'.
        PERFORM upd_ims_db_table USING 'A'.
      ELSE.
        CLEAR : save_ok,zmm_ims_rio-zemail.
        MESSAGE i236(zmm).
      ENDIF.

    WHEN 'DISA'.

      CLEAR : g_ret.
      PERFORM chk_remarks CHANGING g_ret.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      IF rad1 = 'X'.
        """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
        PERFORM chk_forwarded_to USING zmm_ims_rio-forwarded_to.
        """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""
      ENDIF.
      """" """Added by anamika on 26/10/2018 for CR 6000000297 """""""

      IF g_ret = 'X'.
        PERFORM chk_status USING 'D'.
        PERFORM upd_ims_db_table USING 'D'.
      ELSE.

        CLEAR : save_ok,zmm_ims_rio-zemail.

        MESSAGE i236(zmm).

      ENDIF.


    WHEN 'MIS5'.                                  "+007

      SUBMIT zmm_ims_rio_log VIA SELECTION-SCREEN AND RETURN.

*      when OTHERS.
      """" """commented by anamika on 26/10/2018 for CR 6000000297 """""""
*  IF rad2 = 'X'.
*    CLEAR : ztrack.
*    ztrack = WA_ZMM_IMS_STATUS-TRACKNO+0(6).
*
*     CLEAR:wa_lfa1_del,wa_adr6_del.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = ztrack
*    IMPORTING
*      output = ztrack.
*
*  SELECT SINGLE * FROM lfa1 INTO CORRESPONDING FIELDS OF
*  wa_lfa1_del WHERE lifnr = ztrack.
*
*  SELECT SINGLE * FROM adr6 INTO CORRESPONDING FIELDS OF
*  wa_adr6_del WHERE addrnumber = wa_lfa1_del-adrnr.
*
*    zmm_ims_rio-zemail =  wa_adr6_del-smtp_addr.
*  ENDIF.
      """" """Commented by anamika on 26/10/2018 for CR 6000000297 """""""
*


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_GEMINV  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_geminv INPUT.
  DATA : wa_bill TYPE zgem_billdet.
  IF wa_zmm_ims-gem_invoice_no IS NOT INITIAL.
    SELECT SINGLE * FROM zgem_billdet INTO wa_bill
      WHERE gem_invoice_no = wa_zmm_ims-gem_invoice_no.

    IF sy-subrc NE 0.
      MESSAGE 'GeM invoice not available' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_GEMINV  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_geminv INPUT.

  SELECT i~gem_invoice_no , i~order_id , e~ebeln , e~lifnr , l~name1
    FROM zgem_bill AS i
    INNER JOIN ekko AS e
    ON i~order_id EQ e~zgempo
    INNER JOIN lfa1 AS l
    ON e~lifnr EQ l~lifnr
  INTO TABLE @DATA(it_geminv)
    WHERE e~bsart IN ( 'MMGM' , 'MMGS' )
    AND   e~procstat EQ '05'.

  SORT it_geminv BY gem_invoice_no.
  DELETE ADJACENT DUPLICATES FROM it_geminv COMPARING gem_invoice_no.
  DELETE it_geminv WHERE ebeln NE wa_zmm_ims-ebeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'GEM_INVOICE_NO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'WA_ZMM_IMS-GEM_INVOICE_NO'
      value_org       = 'S'
    TABLES
      value_tab       = it_geminv
      return_tab      = ist_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
  wa_zmm_ims-gem_invoice_no =  ist_return_tab-fieldval.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_INDUSTRYFLD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_industryfld INPUT.
  DATA : wa_indfld TYPE lfa1 .
  DATA : wa_t016t  TYPE t016t .
  DATA : l_lifnr_in TYPE lfa1-lifnr .


  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG' OR g_ok_code = 'DISP' .

* To check Vendor Code
*Convert non-leading zero values of LIFNR to concatenating leading zeros. Else belowe SELECT statement will not fetch the record.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_zmm_ims-lifnr
      IMPORTING
        output = l_lifnr_in.

*  IF NOT wa_zmm_ims-LIFNR IS INITIAL .
**    IF NOT wa_zmm_ims-BRSCH IS INITIAL .
    SELECT SINGLE * FROM lfa1 INTO wa_indfld
    WHERE lifnr = l_lifnr_in.
    IF sy-subrc = 0.
      MOVE wa_indfld-brsch TO wa_zmm_ims-brsch .
    ENDIF."sy-subrc = 0.
**    ENDIF ."IF NOT zmm_ims-BRSCH IS INITIAL .
*  ENDIF."IF NOT zmm_ims-LIFNR IS INITIAL .

*Find The Description of Industry Type
    SELECT SINGLE * FROM t016t INTO wa_t016t
    WHERE brsch = wa_zmm_ims-brsch AND spras = 'E' .

    IF sy-subrc = 0 .
      MOVE wa_t016t-brtxt TO wa_zmm_ims-brtxt .
    ENDIF.

  ENDIF .

ENDMODULE.
