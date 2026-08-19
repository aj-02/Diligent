*--- MAIN PROGRAM: MZMMTMSF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMPURTDRNUMGENF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_validation_150
*&---------------------------------------------------------------------*
* To validate tender number
*----------------------------------------------------------------------*
*      -->P_SUBMI  Tender Number
*----------------------------------------------------------------------*
FORM check_validation_150 USING p_submi.

  CLEAR : g_pr_rcpt_dt.                              "+007

  IF NOT p_submi IS INITIAL.

    SELECT SINGLE * FROM zmm_pur_tender_d
             INTO zmm_pur_tender_d_st
               WHERE submi = p_submi.

    IF sy-subrc NE 0.
      MESSAGE e019(06) WITH zmm_pur_tender_d_st-submi.
    ENDIF.

    SELECT SINGLE * FROM  zmm_tms INTO wa_zmm_tms
           WHERE submi = p_submi.

    IF sy-subrc = 0.

*+002 : Start
      IF g_ok_code = 'APRV' AND wa_zmm_tms-rel_stat = 'X'.
        MESSAGE e963(zmm) WITH zmm_pur_tender_d_st-submi.
      ENDIF.
*+002 : End

      """"""""""""""""""""""""
      "added by lipsy on 31.03.2015 for release status changes RD1K995870
*      IF g_ok_code = 'CHNG'.
*        IF wa_zmm_tms-rel_stat = 'X'.
*          CALL FUNCTION 'POPUP_TO_CONFIRM'
*            EXPORTING
*              titlebar       = 'Derelease tender?'
*              text_question  = 'Tender is already released. Do you want to continue?'
**             text_question  = 'Tender is already released. It will be dereleased. Do you want to continue?'
**             TEXT_QUESTION  = 'Do you want to save the data entered ?
*              text_button_1  = 'Yes'
*              text_button_2  = 'No'
**             display_cancel_button = g_disp
*              default_button = '1'
*            IMPORTING
*              answer         = g_ans.
*
*          IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*          ENDIF.
*          IF g_ans = '1'.
*
*            """"""""""""""""""""""""""""""""
*            "commented by lipsy on 8.05.2015 for changing release status on save RD1K997136
**    update zmm_tms set
**    rel_stat = ''
**    where submi = zmm_pur_tender_d_st-submi.
*            "end of comment by lipsy on 8.05.2015 for changing release status on save RD1K997136
*            """"""""""""""""""""""""""""""""""""""""""""""""""""""""
*          ELSE.
*            LEAVE TO SCREEN 0.
*          ENDIF.
**         MESSAGE e963(zmm_oth) WITH zmm_pur_tender_d_st-submi.
*        ENDIF.
*      ENDIF.
      "End of addition by lipsy on 31.03.2015 for release status changes RD1K995870
      """""""""""""""""""""""""""""""""""""""""

      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_general.

*+007 : Start
      IF g_ok_code = 'CHNG'.
        MOVE zmm_tms_general-pr_rcpt_dt TO g_pr_rcpt_dt.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """""""""""""added by lipsy on 26.02.2015 for tracking tc member changes  RD1K995870
        IF g_ok_code = 'CHNG' .
          CLEAR: wa_zmm_tms_tco.
          MOVE-CORRESPONDING wa_zmm_tms TO wa_zmm_tms_tco.


          """"""""""""""""""""""
          "added by lipsy on 9.05.2015 for for tracking pr changes  RD1K997136
          MOVE-CORRESPONDING zmm_pur_tender_d_st TO wa_tender_old.

          "end of addition by lipsy on 9.05.2015 for tracking pr changes  RD1K997136
          """"""""""""""""""
        ENDIF.
        """"""""end of addition by lipsy on 26.02.2015 for tracking tc member changes  RD1K995870
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDIF.


      """""""""""""""""""
      """""""""""""added by lipsy on 26.02.2015 for tracking release status changes  RD1K995870
      IF  g_ok_code = 'APRV' OR g_ok_code = 'CHNG' .
        v_rel_old = wa_zmm_tms-rel_stat.
        SELECT SINGLE rel_stat FROM zmm_tms INTO v_rel_new WHERE submi = zmm_pur_tender_d_st-submi.
      ENDIF.
      """"""""end of addition by lipsy on 26.02.2015 for tracking release status changes  RD1K995870

      """""""""""""""""""""""""
*+007 : End

*Methodology
      IF wa_zmm_tms-mthlogy = 'R'.
        g_reg = 'X'.
        CLEAR g_spfc.
      ELSEIF wa_zmm_tms-mthlogy = 'M'.
        g_spfc = 'X'.
        CLEAR g_reg.
      ENDIF.

      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_tc.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_tb.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_pb.
      MOVE-CORRESPONDING wa_zmm_tms TO zmm_tms_epc.

      MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb. "+007

      PERFORM get_name_desgn USING zmm_tms_tc.

    ENDIF.
    IF zmm_tms_pb-pr_bid_op_sch_dt IS INITIAL.

      IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.                "+004

        SELECT * FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE ist_ekpo
          WHERE banfn = zmm_pur_tender_d_st-banfn
          AND loekz = ''.

        IF NOT ist_ekpo[] IS INITIAL.
          SORT ist_ekpo ASCENDING BY aedat.
          READ TABLE ist_ekpo INTO wa_ekpo INDEX 1.
          IF NOT wa_ekpo-anfnr IS INITIAL.
            SELECT SINGLE * FROM ekko INTO CORRESPONDING FIELDS OF wa_ekko
              WHERE ebeln = wa_ekpo-anfnr.
            IF sy-subrc = 0.
              zmm_tms_pb-pr_bid_op_sch_dt =  wa_ekko-zzpb_op_dt.
              zmm_tms_tb-tend_op_sch_dt  = wa_ekko-zztb_op_dt.
              zmm_tms_tc-pbc_dt  = wa_ekko-zzpre_bid_dt .
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.                                                      "+004
    ENDIF.
    g_rel_stat = wa_zmm_tms-rel_stat.
  ENDIF.

  g_option = 'X'.     "?????

ENDFORM.                    " check_validation_150

*&---------------------------------------------------------------------*
*&      Form  get_name_desgn
*&---------------------------------------------------------------------*
* To get name & desgination of tender committee / indentor etc.
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC  Tender Committee
*----------------------------------------------------------------------*
FORM get_name_desgn USING p_zmm_tms_tc STRUCTURE zmm_tms_tc.

*Get CPA Name & Desgination
  IF NOT p_zmm_tms_tc-cpa IS INITIAL.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "commented by lipsy on 18.05.2015 for cpa filled with epc RD1K997136

*    PERFORM get_name_design USING p_zmm_tms_tc-cpa
*                            CHANGING wa_cpa_dtl-ename
*                                     wa_cpa_dtl-desig_text.

    "end of  commented by lipsy on 18.05.2015 for cpa filled with epc RD1K997136
    """""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""
    "added by lipsy on 18.05.2015 for cpa filled with epc RD1K997136

    PERFORM get_name_design_cpa USING p_zmm_tms_tc-cpa
                            CHANGING wa_cpa_dtl-ename
                                     wa_cpa_dtl-desig_text.
    "eadded by lipsy on 18.05.2015 for cpa filled with epc RD1K997136
    """"""""""""""""""""""""""""""""""""""""""
  ELSE.

    CLEAR : wa_cpa_dtl.

  ENDIF.

*Get Indentor Name & Desgination
  IF NOT p_zmm_tms_tc-indentor IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-indentor
                            CHANGING wa_indentor_dtl-ename
                                     wa_indentor_dtl-desig_text.
  ELSE.

    CLEAR : wa_indentor_dtl.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
*Get IC MM Name & Desgination
  IF NOT p_zmm_tms_tc-ic_mm IS INITIAL.
    SHIFT p_zmm_tms_tc-ic_mm RIGHT DELETING TRAILING space.
    OVERLAY p_zmm_tms_tc-ic_mm  WITH '0000000000'.
    PERFORM get_name_design USING    p_zmm_tms_tc-ic_mm
                            CHANGING wa_icmm_dtl-ename
                                     wa_icmm_dtl-desig_text.
  ELSE.

    CLEAR : wa_icmm_dtl.

  ENDIF.





*Get L1 Name & Desgination
  IF NOT p_zmm_tms_tc-l1 IS INITIAL.
    SHIFT p_zmm_tms_tc-l1 RIGHT DELETING TRAILING space.
    OVERLAY p_zmm_tms_tc-l1  WITH '0000000000'.
    PERFORM get_name_design USING    p_zmm_tms_tc-l1
                            CHANGING wa_l1_dtl-ename
                                     wa_l1_dtl-desig_text.
  ELSE.

    CLEAR : wa_l1_dtl.

  ENDIF.

  "END OF ADDITION BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950



  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member1 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member1
                            CHANGING wa_tc_mem1-ename
                                     wa_tc_mem1-desig_text.
  ELSE.

    CLEAR : wa_tc_mem1.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member2 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member2
                            CHANGING wa_tc_mem2-ename
                                     wa_tc_mem2-desig_text.
  ELSE.

    CLEAR : wa_tc_mem2.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member3 IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member3
                            CHANGING wa_tc_mem3-ename
                                     wa_tc_mem3-desig_text.
  ELSE.

    CLEAR : wa_tc_mem3.

  ENDIF.

*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member4 IS INITIAL.

    PERFORM get_name_design USING p_zmm_tms_tc-tc_member4
                            CHANGING wa_tc_mem4-ename
                                     wa_tc_mem4-desig_text.
  ELSE.

    CLEAR : wa_tc_mem4.

  ENDIF.

*18.10.2012 : Start
*Get TC Member Name & Desgination
  IF NOT p_zmm_tms_tc-tc_member5 IS INITIAL.

    PERFORM get_name_design USING p_zmm_tms_tc-tc_member5
                            CHANGING wa_tc_mem5-ename
                                     wa_tc_mem5-desig_text.
  ELSE.

    CLEAR : wa_tc_mem5.

  ENDIF.

*Get Substitute TC member Name & Desgination 1
  IF NOT p_zmm_tms_tc-tc_member1_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member1_s
                            CHANGING wa_tc_mem1_s-ename
                                     wa_tc_mem1_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem1_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 2
  IF NOT p_zmm_tms_tc-tc_member2_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member2_s
                            CHANGING wa_tc_mem2_s-ename
                                     wa_tc_mem2_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem2_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 3
  IF NOT p_zmm_tms_tc-tc_member3_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member3_s
                            CHANGING wa_tc_mem3_s-ename
                                     wa_tc_mem3_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem3_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 4
  IF NOT p_zmm_tms_tc-tc_member4_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member4_s
                            CHANGING wa_tc_mem4_s-ename
                                     wa_tc_mem4_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem4_s.

  ENDIF.

*Get Substitute TC member Name & Desgination 5
  IF NOT p_zmm_tms_tc-tc_member5_s IS INITIAL.

    PERFORM get_name_design USING    p_zmm_tms_tc-tc_member5_s
                            CHANGING wa_tc_mem5_s-ename
                                     wa_tc_mem5_s-desig_text.
  ELSE.

    CLEAR : wa_tc_mem5_s.

  ENDIF.
*18.10.2012 : End
ENDFORM.                    "check_validation_150

*&---------------------------------------------------------------------*
*&      Form  get_name_design
*&---------------------------------------------------------------------*
* To get name & desgination
*----------------------------------------------------------------------*
*      -->P_PERNR   CPF No.
*      <--P_ENAME   Employee name
*      <--P_design  Employee desgination
*----------------------------------------------------------------------*
FORM get_name_design USING    p_pernr
                     CHANGING p_ename
                              p_design.

  DATA : l_designo TYPE pa9930-designo,
         l_r_p_cd  TYPE pa9930-r_p_cd,
         l_version TYPE pa9930-version.


**---------- Changes Start date 27.06.2016 16:48:19-------------------
*  SELECT SINGLE ename FROM pa0001 INTO p_ename
*         WHERE pernr = p_pernr AND
*               endda = '99991231'.


  SELECT ENAME FROM ZPA0001 INTO P_ENAME UP TO 1 ROWS
 WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**---------- Changes  Ending Date 27.06.2016 16:48:19-----------------


  IF sy-subrc NE 0.
***    start of change 20.06.2016
**    IF P_PERNR+0(1) <> 'C'.
**
**      MESSAGE E035(ZMMPURTDR).
**    ENDIF.
***    End of change 20.06.2016
  ENDIF.


**----------Start of change 27.06.2016 16:55:33 -------------------
*  SELECT SINGLE DESIGNO R_P_CD VERSION FROM PA9930
*         INTO (L_DESIGNO,L_R_P_CD,L_VERSION)
*            WHERE PERNR = P_PERNR AND
*                  ENDDA = '99991231'.

  SELECT DESIGNO R_P_CD VERSION FROM ZPA9930
 INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:55:33 -----------------
  IF sy-subrc = 0.

    SELECT SINGLE desig_text FROM zdesignation_rev
         INTO p_design
            WHERE desig_code = l_designo AND
                  r_p_cd     = l_r_p_cd AND
                  version    = l_version.
  ENDIF.

ENDFORM.                    "get_name_design

*&---------------------------------------------------------------------
*
*&      Form  lock_record
*&---------------------------------------------------------------------*
*  To lock the records in case of Updation
*----------------------------------------------------------------------*
*  -->  p_submi   Tender number
*----------------------------------------------------------------------*
FORM lock_record USING p_submi.

  CALL FUNCTION 'ENQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = p_submi
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " lock_record

*&---------------------------------------------------------------------*
*&      Form  unlock_record
*&---------------------------------------------------------------------*
*       To release to Locked record(s).
*----------------------------------------------------------------------*
*  -->  p_submi   Tender number
*----------------------------------------------------------------------*
FORM unlock_record USING p_submi.

  CALL FUNCTION 'DEQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = p_submi.

ENDFORM.                    " unlock_record


*&---------------------------------------------------------------------*
*&      Form  confirm_input
*&---------------------------------------------------------------------*
*  In case of cancel or exit ,Display warning message.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_input.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Alert '
      text_question         = g_txt
*     TEXT_QUESTION         = 'Do you want to save the data entered ?
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      display_cancel_button = g_disp
      default_button        = '1'
    IMPORTING
      answer                = g_ans.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " confirm_input

*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*   To insert new data into master and details tables.
*----------------------------------------------------------------------*
FORM save_data.

  CLEAR : g_ret_1,
         g_ret_2.

*-----Validation on Start Date of selling tender &
*                   Last Date of selling tender.
  PERFORM validate_date_req.
*-----Converts the date and time fields into time stamp format
  PERFORM oif_conv_date_time_ts.
*-----Save the Data in DB Table
  PERFORM prepare_saving ON COMMIT.

*Added by CAB_SPYADAV : Start
  PERFORM save_data_tms ON COMMIT.

  IF g_ret_1 = 0 AND g_ret_2 = 0.
*Added by CAB_SPYADAV : End

*   IF   g_chg_flg = 'X' OR g_chg_spfc = 'X'.                    "-001
    IF   g_chg_flg = 'X' OR g_chg_spfc = 'X' OR g_chg_epc = 'X'. "+001
      PERFORM save_editor_data.
    ENDIF.

    COMMIT WORK.

    "comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
*    PERFORM upd_purq_profile.                               "+008
    "end of comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870

    MESSAGE i037(zmmpurtdr).                                "+001
**----------Start of change 29.06.2016 15:18:06 REKHA  -------------------
**    MESSAGE i039(zmmpurtdr). " Due to automatic release .
**----------End  of change 29.06.2016 15:18:06 REKHA  -----------------

    IF NOT zmm_pur_tender_d_st-submi IS INITIAL.
      CONCATENATE tstct-ttext+15(6) 'd' INTO l_ttext.
      MESSAGE i023(zmmpurtdr) WITH zmm_pur_tender_d_st-submi l_ttext.
      PERFORM clear_para.
    ENDIF.

*Added by CAB_SPYADAV : Start
  ELSE.
    ROLLBACK WORK.
*    PERFORM clear_para.
    MESSAGE e033(zpm).
  ENDIF.
*Added by CAB_SPYADAV : End

ENDFORM.                    "save_data

*&---------------------------------------------------------------------*
*&      Form  generate_tender_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_tender_number.

  DATA : l_number(3) TYPE n,
         lsubmi      LIKE zmm_pur_tender_d_st-srno.

  SELECT SINGLE * FROM zmm_pur_trtyp WHERE bsart EQ
                                           zmm_pur_tender_d_st-bsart.

  SELECT MAX( srno )  INTO lsubmi FROM zmm_pur_tender_d
                       WHERE ekgrp     EQ zmm_pur_tender_d_st-ekgrp
                       AND   dlg_offic EQ zmm_pur_tender_d_st-dlg_offic
                       AND   mjahr     EQ zmm_pur_tender_d_st-mjahr.

  IF sy-subrc NE 0.
    l_number = '001'.
  ELSEIF sy-subrc EQ 0.
    l_number = lsubmi + 1.
  ENDIF.

  zmm_pur_tender_d_st-srno = l_number.

  CONCATENATE zmm_pur_tender_d_st-ekgrp
              zmm_pur_tender_d_st-dlg_offic
              zmm_pur_trtyp-bstyp
              zmm_pur_tender_d_st-mjahr+2(2)
              l_number INTO zmm_pur_tender_d_st-submi.


ENDFORM.                    " generate_tender_number
*&---------------------------------------------------------------------*
*&      Form  CLEAR_PARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_para.

  CLEAR : g_action,
          zmm_pur_tender_d_st,
          g_sav_ok_100,
          g_ok_100,
          g_option.

  LEAVE TO TRANSACTION sy-tcode.

ENDFORM.                    " CLEAR_PARA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_SAVING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_saving.

  DATA l_ok(1).

*Commented by CAB_SPYADAV : Start
*  CASE sy-tcode.
**---Create
*    WHEN 'ZMMTDR1'.
*Commented by CAB_SPYADAV : End
*Generate the tender number
  l1_date = sy-datum + 7.
  l_ok = 'X'.

  IF zmm_pur_tender_d_st-tdrdt >= sy-datum AND
      zmm_pur_tender_d_st-tdrdt <= l1_date.
  ELSE.



    CLEAR l_ok.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """commentED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
*    CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*      EXPORTING
*        popup_title  = 'Invalid Tender Date'
*        is_error     = 'X'
*        message_text = 'Tender Date should not be greater than 7 Days from Todays Date'.

    """end of comment BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """addED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950


    MESSAGE e157(zmm_oth).

    """end of addition BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  ENDIF.

  IF NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.
    IF zmm_pur_tender_d_st-tdrdt > zmm_pur_tender_d_st-st_sel_dt.
      CLEAR l_ok.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*        EXPORTING
*          popup_title  = 'Invalid Tender Start Date'
*          is_error     = 'X'
*          message_text = 'Tender sale Start Date should be greater than or equal to Tender Date'.
      MESSAGE: 'Tender sale Start Date should be greater than or equal to Tender Date' type 'W'.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
    ENDIF.
  ENDIF.

  IF l_ok = 'X'.
    PERFORM generate_tender_number.
    zmm_pur_tender_d_st-ernam = sy-uname.
    zmm_pur_tender_d_st-erfdt = sy-datum.
    zmm_pur_tender_d_st-bstyp = zmm_pur_trtyp-bstyp.
    INSERT zmm_pur_tender_d FROM zmm_pur_tender_d_st.

*Added by CAB_SPYADAV : Start
    IF sy-subrc = 0.

      g_ret_1 = 0.

    ELSE.

      g_ret_1 = 4.

    ENDIF.
*Added by CAB_SPYADAV : End
  ENDIF.

*Commented by CAB_SPYADAV : Start
**---Change
*    WHEN 'ZMMTDR2'.
*      UPDATE zmm_pur_tender_d SET:
*                              tdrtxt    = zmm_pur_tender_d_st-tdrtxt
*                              st_sel_dt = zmm_pur_tender_d_st-st_sel_dt
*                              lt_sel_dt = zmm_pur_tender_d_st-lt_sel_dt
*                              tdrsts    = zmm_pur_tender_d_st-tdrsts
*                              tdrsigner = zmm_pur_tender_d_st-tdrsigner
*                              banfn     = zmm_pur_tender_d_st-banfn
*                              workdesc  = zmm_pur_tender_d_st-workdesc
*                              nitdate   = zmm_pur_tender_d_st-nitdate
*                              aeusn     = sy-uname
*                              aedtm     = sy-datum
*                              timestamp = zmm_pur_tender_d_st-timestamp
*             WHERE submi = zmm_pur_tender_d_st-submi.
*  ENDCASE.
*Commented by CAB_SPYADAV : End

ENDFORM.                    " PREPARE_SAVING

*&---------------------------------------------------------------------*
*&      Form  save_data_tms
*&---------------------------------------------------------------------*
* Insert TMS data in TMS table - ZMM_TMS
*----------------------------------------------------------------------*
FORM save_data_tms.

  CLEAR : wa_zmm_tms.

  MOVE zmm_pur_tender_d_st-submi TO wa_zmm_tms-submi.

  MOVE-CORRESPONDING zmm_tms_general TO wa_zmm_tms.

*Methodology
  IF g_reg = 'X'.
    wa_zmm_tms-mthlogy = 'R'.
  ELSEIF g_spfc = 'X'.
    wa_zmm_tms-mthlogy = 'M'.
  ENDIF.

  MOVE-CORRESPONDING zmm_tms_tc      TO wa_zmm_tms.
  MOVE-CORRESPONDING zmm_tms_tb      TO wa_zmm_tms.
  MOVE-CORRESPONDING zmm_tms_pb      TO wa_zmm_tms.

*EPC tab should get disabled if EPC case is chosen as 'N'.
  IF zmm_tms_general-epc_typ NE 'N'. "Non-EPC
    MOVE-CORRESPONDING zmm_tms_epc     TO wa_zmm_tms.
  ENDIF.

**----------Start of change 27.06.2016 17:22:03 -------------------
  wa_zmm_tms-rel_stat = 'X' .
**----------End  of change 27.06.2016 17:22:03 -----------------



  MODIFY zmm_tms FROM wa_zmm_tms.

  IF sy-subrc = 0.
    g_ret_2 = 0.

    """""""""""""""""""""""""""""""""
    "added by lipsy on 9.05.2015  RD1K997136.

**----------Start of change 29.06.2016 15:06:24 REKHA  Commented to make automatic release  -------------------
**    UPDATE ZMM_TMS SET
**    REL_STAT = ''
**    WHERE SUBMI = ZMM_PUR_TENDER_D_ST-SUBMI.
**----------End  of change 29.06.2016 15:06:24 REKHA   -----------------


    "end of addition by lipsy on 9.05.2015 RD1K997136
    """""""""""""""""""""""""""""""""""""""""""
  ELSE.
    g_ret_2 = 4.
  ENDIF.

ENDFORM.                    "save_data_tms

*&---------------------------------------------------------------------*
*&      Form  update_data
*&---------------------------------------------------------------------*
*   To update existing records in detail tables
*          ZMM_PUR_TENDER_D
*          ZMM_TMS
*----------------------------------------------------------------------*
FORM update_data.

  CLEAR : g_ret_1,
          g_ret_2.

*-----Validation on Start Date of selling tender &
*                   Last Date of selling tender.
  PERFORM validate_date_req.
*-----Converts the date and time fields into time stamp format
  PERFORM oif_conv_date_time_ts.
*-----Save the Data in DB Table
  PERFORM save_data_tender ON COMMIT.

*Added by CAB_SPYADAV : Start
  PERFORM save_data_tms ON COMMIT.

  IF g_ret_1 = 0 AND g_ret_2 = 0.

*   IF   g_chg_flg = 'X' OR g_chg_spfc = 'X'.                    "-001
    IF   g_chg_flg = 'X' OR g_chg_spfc = 'X' OR g_chg_epc = 'X'. "+001
      PERFORM save_editor_data.
    ENDIF.

    PERFORM chng_doc_pr_rcpt_dt USING wa_zmm_tms-submi
                                      zmm_tms_general-pr_rcpt_dt
                                      g_pr_rcpt_dt.              "+007




    COMMIT WORK.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""added by lipsy on 26.02.2015 for tracking tc members changes RD1K995870
    CLEAR:wa_zmm_tms_tcn.
    MOVE-CORRESPONDING zmm_tms_tc  TO wa_zmm_tms_tcn.
*BREAK-POINT.
    PERFORM chng_doc_tc USING wa_zmm_tms-submi
                             wa_zmm_tms_tco
                             wa_zmm_tms_tcn.

    COMMIT WORK.


    """"""""""""""""""""""""""""""""""""""""""""
    "added by lipsy on 9.05.2015 for tracking pr changes  RD1K997136
    MOVE-CORRESPONDING zmm_pur_tender_d_st TO wa_tender_new.
    PERFORM chng_doc_tender_pr USING wa_zmm_tms-submi
                                     wa_tender_old
                                     wa_tender_new.
    COMMIT WORK.

    "end of addition by lipsy on 9.05.2015  for tracking pr changes   RD1K997136
    """"""""""""""""""""""""""""""""""""""""""""
    """""""""""""end of addition  by lipsy on 26.02.2015 for tracking tc members changes RD1K995870


    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
*    PERFORM upd_purq_profile.                               "+008
    """""""end comment by lipsy on 24.03.2015 for removing eprofile removal  RD1K995870
    MESSAGE i037(zmmpurtdr).                                "+001

* **----------Start of change 29.06.2016 15:09:18 REKHA for making release on create only  -------------------
*  MESSAGE I039(ZMMPURTDR).
* *----------End  of change 29.06.2016 15:09:18 REKHA  -----------------

    MESSAGE i947(zmm) WITH zmm_pur_tender_d_st-submi.
*   PERFORM clear_para.
  ELSE.
    ROLLBACK WORK.
*    PERFORM clear_para.
    MESSAGE e033(zpm).
  ENDIF.

  PERFORM unlock_record USING zmm_pur_tender_d_st-submi.

ENDFORM.                    "update_data

*&---------------------------------------------------------------------*
*&      Form  save_data_tender
*&---------------------------------------------------------------------*
* Modify tender data - ZMM_PUR_TENDER_D
*----------------------------------------------------------------------**----------------------------------------------------------------------*
FORM save_data_tender.

  MODIFY zmm_pur_tender_d FROM zmm_pur_tender_d_st.

  IF sy-subrc = 0.

    g_ret_1 = 0.

  ELSE.

    g_ret_1 = 4.

  ENDIF.

ENDFORM.                    "save_data_tender

*&---------------------------------------------------------------------*
*&      Form  oif_conv_date_time_ts
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM oif_conv_date_time_ts.
  DATA l_timestamp LIKE oifbbp1-ftmstm.

  CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
    EXPORTING
      i_datum           = sy-datum
      i_time            = sy-uzeit
    IMPORTING
      e_timestamp       = l_timestamp
    EXCEPTIONS
      date_not_received = 1
      time_not_received = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  zmm_pur_tender_d_st-timestamp = l_timestamp.

ENDFORM.                    " oif_conv_date_time_ts
*&---------------------------------------------------------------------*
*&      Form  validate_date_req
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_date_req.

  CHECK zmm_pur_tender_d_st-bsart+0(1) NE 'E'.

  IF zmm_pur_tender_d_st-tdrdt IS INITIAL.
    MESSAGE e027(zmmpurtdr).
  ENDIF.

  IF g_ok_code NE 'NEW'.                         "+008
    IF zmm_pur_tender_d_st-bsart+0(2) EQ 'MO'  OR
       zmm_pur_tender_d_st-bsart      EQ 'SGO' OR
       zmm_pur_tender_d_st-bsart EQ 'SOT'      OR
       zmm_pur_tender_d_st-bsart EQ 'MRCO'.

      """""""""""""""""""""""""""""""""""""""""""""""""
      "comment by lipsy  on 5.11.2014 FOR new validations in RD1K994950
*      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL OR
*         zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.
*
*
*        PERFORM err_msg USING '008'.
*
*        endif.

      "end of comment by lipsy on 5.11.2014  FOR new validations in RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "add by lipsy on 5.11.2014 FOR new validations in RD1K994950

      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL
       AND  zmm_pur_tender_d_st-sch_st_sel_dt < sy-datum.
        PERFORM err_msg USING '008'.
      ENDIF.


      IF     zmm_pur_tender_d_st-lt_sel_dt IS INITIAL
       AND zmm_pur_tender_d_st-sch_lt_sel_dt < sy-datum.
        PERFORM err_msg USING '038'.

        "end of addition by lipsy on 5.11.2014 FOR new validations in RD1K994950
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      ENDIF.
    ENDIF.

    """"""""""""""
    "added by lipsy on 1.04.2015 ""RD1K995870
    IF  zmm_tms_pb-pr_bid_op_act_dt IS NOT INITIAL AND zmm_tms_tb-tend_op_act_dt IS NOT INITIAL.
      IF  zmm_tms_pb-pr_bid_op_act_dt LT zmm_tms_tb-tend_op_act_dt.
        PERFORM err_msg USING '040'.
      ENDIF.
    ENDIF.

    IF  zmm_tms_pb-pr_bid_op_act_dt IS NOT INITIAL AND zmm_tms_pb-loi_1_act_dt  IS NOT INITIAL.
      IF zmm_tms_pb-loi_1_act_dt LT zmm_tms_pb-pr_bid_op_act_dt.
        PERFORM err_msg USING '041'.
      ENDIF.
    ENDIF.
    "end of addition by lipsy on 1.04.2015 ""RD1K995870

    """""""""""""


  ENDIF.                                           "+008

*---Start NN 03.09.2003
  IF zmm_pur_tender_d_st-bsart = 'MLLM' OR
     zmm_pur_tender_d_st-bsart = 'MLLN' OR
     zmm_pur_tender_d_st-bsart = 'MLMM' OR
     zmm_pur_tender_d_st-bsart = 'MLMN' OR
     zmm_pur_tender_d_st-bsart = 'MRCM' OR
     zmm_pur_tender_d_st-bsart = 'MRCN' OR
     zmm_pur_tender_d_st-bsart = 'MSTA' OR
     zmm_pur_tender_d_st-bsart = 'SBP'  OR
     zmm_pur_tender_d_st-bsart = 'SGL'  OR
     zmm_pur_tender_d_st-bsart = 'SLT'  OR
     zmm_pur_tender_d_st-bsart = 'SST'.

    FIELD-SYMBOLS: <f1>.
    FIELD-SYMBOLS: <f2>.

    DATA : tabn(20)   TYPE c,
           fieldn(15) TYPE c,
           rc.
    tabn = 'ZMM_PUR_TENDER_D'.

    LOOP AT SCREEN.
      CHECK screen-group2 EQ 'DSP'.
      ASSIGN (screen-name) TO <f1>.
      IF NOT <f1> IS INITIAL.
        SEARCH screen-name FOR '-'.
        sy-fdpos = sy-fdpos + 1.
        ASSIGN screen-name+sy-fdpos(10) TO <f2>.
        MOVE <f2> TO fieldn.
        PERFORM get_ftext(rddfie00) USING tabn fieldn sy-langu
                                    CHANGING dfies rc.
        IF rc EQ 0.
          SET CURSOR FIELD fieldn LINE sy-stepl.
          MESSAGE e024(zmmpurtdr) WITH dfies-scrtext_m
                                       zmm_pur_tender_d_st-bsart.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
*---End NN 03.09.2003
ENDFORM.                    " validate_date_req
*&---------------------------------------------------------------------*
*&      Form  err_msg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0264   text
*----------------------------------------------------------------------*
FORM err_msg USING    p_msgnr.

*+007 : Start
  DATA : l_dtyp TYPE t100c-msgts.

  IF g_ok_code = 'DISP'.
    l_dtyp = 'W'.
  ELSE.
    l_dtyp = 'E'.
  ENDIF.
*+007 : End

  CALL FUNCTION 'CUSTOMIZED_MESSAGE'
    EXPORTING
      i_arbgb = 'ZMMPURTDR'
*     i_dtype = 'E' "-007
      i_dtype = l_dtyp            "+007
      i_msgnr = p_msgnr.

ENDFORM.                    " err_msg
*&---------------------------------------------------------------------*
*&      Form  authority_check_tcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM authority_check_tcode.
  IF sy-tcode = 'ZMMTMSDISP'.
    g_tcode = 'ZMMTDR3'.
  ENDIF.
  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
*     tcode  = sy-tcode
      tcode  = g_tcode
    EXCEPTIONS
      ok     = 1
      not_ok = 2
      OTHERS = 3.
  IF sy-subrc <> 1.
*   MESSAGE e077(s#) WITH sy-tcode.
    MESSAGE e077(s#) WITH g_tcode.
  ENDIF.
ENDFORM.                    " authority_check_tcode
*&---------------------------------------------------------------------*
*&      Form  confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirm_step.
  IF sy-tcode NE 'ZMMTDR3'.
    PERFORM  confirm_action  USING  text-200 text-201 g_action.
    IF g_action EQ '1'.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ELSE.
    IF sy-calld NE space.
      LEAVE.
    ELSE.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                    " confirm_step
*&---------------------------------------------------------------------*
*&      Form  confirm_action
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_200  text
*      -->P_TEXT_201  text
*      -->P_G_ACTION  text
*----------------------------------------------------------------------*
FORM confirm_action USING l_title  l_question l_action.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = l_title
      text_question         = l_question
      text_button_1         = 'Yes'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'No'
      icon_button_2         = 'ICON_REJECT'
      default_button        = '1'
      display_cancel_button = 'X'
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = g_action
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " confirm_action

*&---------------------------------------------------------------------*
*&      Form  set_editor
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor  USING    p_dmode.
  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_editor

*&---------------------------------------------------------------------*
*&      Form  set_editor_spfc
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor_spfc  USING    p_dmode.
  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL_S'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines_spfc
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " set_editor_spfc

*+001 : Start
*&---------------------------------------------------------------------*
*&      Form  set_editor_epc
*&---------------------------------------------------------------------*
*      To invoke editor in change/display mode
*----------------------------------------------------------------------*
*      -->P_DMODE  Mode
*----------------------------------------------------------------------*
FORM set_editor_epc  USING    p_dmode.

  CALL FUNCTION 'RH_EDITOR_SET'
    EXPORTING
      repid          = sy-repid
      dynnr          = g_dynnr
      controlname    = 'TMS_CUST_CTRL_E'
      max_cols       = 80
*     MAX_LINES      =
      show_tool      = ''
      show_status    = ''
*     STATUS_TEXT    = ''
      display_mode   = p_dmode
    TABLES
      lines          = ist_lines_epc
    EXCEPTIONS
      create_error   = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " set_editor_epc
*+001 : End

*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_flg = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR

*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR_SPFC
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor_spfc  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL_S'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines_spfc
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_spfc = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR_SPFC

*+001 : Start
*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR_EPC
*&---------------------------------------------------------------------*
*   To Get Editor Data
*----------------------------------------------------------------------*
*      -->P_CHNG - flag
*----------------------------------------------------------------------*
FORM get_editor_epc  USING p_chng.

  DATA : l_chg(1).

  CALL FUNCTION 'RH_EDITOR_GET'
    EXPORTING
      controlname    = 'TMS_CUST_CTRL_E'
    IMPORTING
      changed        = l_chg
    TABLES
      lines          = ist_lines_epc
    EXCEPTIONS
      internal_error = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF NOT p_chng IS INITIAL.
    g_chg_epc = l_chg.
  ENDIF.

ENDFORM.                    " GET_EDITOR_EPC
*+001 : End

*&---------------------------------------------------------------------*
*&      Form  save_editor_data
*&---------------------------------------------------------------------*
*     To save editor Data
*----------------------------------------------------------------------*
FORM save_editor_data.

  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines WHERE vdata = ''.

  LOOP AT ist_lines.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'P'.
    MOVE ist_lines-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'P'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'P'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.

***********************************************************************
  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines_spfc WHERE vdata = ''.

  LOOP AT ist_lines_spfc.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'M'.
    MOVE ist_lines_spfc-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'M'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'M'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.

***********************************************************************
*+001 : Start : EPC long text
  REFRESH : ist_zmm_tmst.
  CLEAR   : wa_zmm_tmst.

  DELETE ist_lines_epc WHERE vdata = ''.

  LOOP AT ist_lines_epc.
    wa_zmm_tmst-submi    = zmm_pur_tender_d_st-submi.
    wa_zmm_tmst-tabseqnr = wa_zmm_tmst-tabseqnr + 1.
    wa_zmm_tmst-lttyp    = 'E'.
    MOVE ist_lines_epc-vdata TO wa_zmm_tmst-tline.

    APPEND wa_zmm_tmst TO ist_zmm_tmst.
  ENDLOOP.

  SELECT SINGLE * FROM zmm_tmst
     WHERE submi = wa_zmm_tmst-submi AND
           lttyp = 'E'.

  IF sy-subrc = 0.                          " Update
    DELETE FROM zmm_tmst
             WHERE submi = wa_zmm_tmst-submi AND lttyp = 'E'.
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ELSE.                                     " Create
    MODIFY zmm_tmst FROM TABLE ist_zmm_tmst.
  ENDIF.
*+001 : End

ENDFORM.                    " save_editor_data

*&---------------------------------------------------------------------*
*&      Form  get_editor_data
*&---------------------------------------------------------------------*
*   To fetch data from Transparent table ZMM_TMST - Editor
*----------------------------------------------------------------------*
*      -->P_SUBMI  Tender No.
*----------------------------------------------------------------------*
FORM get_editor_data USING p_submi.

  REFRESH : ist_lines,
            ist_lines_spfc.

  REFRESH : ist_lines_epc.                                  "+001

*TMS : Long text - Price Bid
  SELECT * FROM zmm_tmst INTO TABLE ist_zmm_tmst
     WHERE submi = p_submi.

  IF sy-subrc = 0.
    LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                              WHERE lttyp = 'P'.
      MOVE wa_zmm_tmst-tline TO ist_lines-vdata.
      APPEND ist_lines.
    ENDLOOP.
  ENDIF.

*TMS : Long text - General Methodology : Specfic
  LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                            WHERE lttyp = 'M'.
    MOVE wa_zmm_tmst-tline TO ist_lines_spfc-vdata.
    APPEND ist_lines_spfc.
  ENDLOOP.

*+001 : Start
*TMS : Long text - EPC
  LOOP AT ist_zmm_tmst INTO wa_zmm_tmst
                            WHERE lttyp = 'E'.
    MOVE wa_zmm_tmst-tline TO ist_lines_epc-vdata.
    APPEND ist_lines_epc.
  ENDLOOP.
*+001 : End

  REFRESH : ist_zmm_tmst.

  CLEAR   : wa_zmm_tmst.

ENDFORM.                    " get_editor_data

*&---------------------------------------------------------------------*
*&      Form  CHK_SCH_ACT_DATE
*&---------------------------------------------------------------------*
* To validate scheduled & actual date
*----------------------------------------------------------------------*
*      -->P_SCH_DT     Scheduled date
*      -->P_ACT_DT     Actual date
*      -->P_SCH_DT_FN  Scheduled date : Dynpro field name
*      -->P_ACT_DT_FN  Actual date : Dynpro field name
*----------------------------------------------------------------------*
FORM chk_sch_act_date  USING    p_sch_dt
                                p_act_dt
                                p_sch_dt_fn
                                p_act_dt_fn.

************************************************************************
*  IF NOT p_sch_dt IS INITIAL.
*
*    IF p_sch_dt GT sy-datum.
*
*      SET CURSOR FIELD p_sch_dt_fn.
*
*      MESSAGE e028(zmmpurtdr).
*
*    ENDIF.
*
*    IF NOT p_act_dt IS INITIAL.
*
*      IF p_act_dt LT p_sch_dt.
*
*        SET CURSOR FIELD p_act_dt_fn.
*
*        MESSAGE e030(zmmpurtdr).
*
*      ENDIF.
*
*    ENDIF.
*
*  ELSE.
*
*    IF NOT p_act_dt IS INITIAL.
*
*      SET CURSOR FIELD p_sch_dt_fn.
*
*      MESSAGE e029(zmmpurtdr).
*
*    ENDIF.
*
*  ENDIF.
***********************************************************************

***********************************************************************
  IF NOT p_act_dt IS INITIAL.

    IF p_act_dt GT sy-datum.

      SET CURSOR FIELD p_act_dt_fn.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
      IF g_ok_code = 'DISP'.

      ELSE.

        "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        MESSAGE e031(zmmpurtdr).


        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """ADDED BY LIPSY ON 30.10.2014  FOR removing error in display mode RD1K994950

      ENDIF.
      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ENDIF.

    IF p_sch_dt IS INITIAL.

      SET CURSOR FIELD p_sch_dt_fn.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
      IF g_ok_code = 'DISP'.

      ELSE.

        "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        MESSAGE e029(zmmpurtdr).
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        """ADDED BY LIPSY ON 30.10.2014  FOR removing error in display mode RD1K994950

      ENDIF.
      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    ENDIF.

  ENDIF.
***********************************************************************

ENDFORM.                    " CHK_SCH_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  attach_files
*&---------------------------------------------------------------------*
* To attach files in tender document
*----------------------------------------------------------------------*
FORM attach_files.

  REFRESH : ist_att_files.
  CLEAR   : wa_att_files.

  wa_att_files-logsys  = zmm_pur_tender_d_st-submi.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  APPEND wa_att_files TO ist_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      attachment_data     = ''
      attachment_type     = 'DOC'
    TABLES
      application_objects = ist_att_files.


ENDFORM.                    " attach_files

*&---------------------------------------------------------------------*
*&      Form  list_files
*&---------------------------------------------------------------------*
* To display list of files attached in the tender document
*----------------------------------------------------------------------*
FORM list_files.

  CLEAR   : wa_att_files.

  wa_att_files-logsys  = zmm_pur_tender_d_st-submi.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
    EXPORTING
      application_object = wa_att_files.

ENDFORM.                    " list_files

*&---------------------------------------------------------------------*
*&      Form  disp_process_guide
*&---------------------------------------------------------------------*
* To display process guide - TMS
*----------------------------------------------------------------------*
FORM disp_process_guide USING p_logsys.

  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.

  CLEAR : wa_att_files.

  wa_att_files-logsys  = p_logsys.
  wa_att_files-objtype = 'ATT'.
  wa_att_files-objkey  = '01'.

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

ENDFORM.                    " disp_process_guide
*&---------------------------------------------------------------------*
*&      Form  READ_TEXT
*&---------------------------------------------------------------------*
*  To tender process / tender type text
*----------------------------------------------------------------------*
*      -->P_DNAME Domain name
*      -->P_PROC  Tender process / Type
*      <--P_text  text
*----------------------------------------------------------------------*
FORM read_text  USING    p_dname
                         p_proc
                CHANGING p_text.

  DATA : wa_dd07v TYPE dd07v,
         l_value  TYPE dd07l-domvalue_l.

  MOVE p_proc TO l_value.

  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      domname  = p_dname
      value    = l_value
      langu    = sy-langu
    IMPORTING
      dd07v_wa = wa_dd07v.

  MOVE wa_dd07v-ddtext TO p_text.

ENDFORM.                    " READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  CHK_ACT_DATE
*&---------------------------------------------------------------------*
* To check actual date : EPC : Screen 0800
*----------------------------------------------------------------------*
FORM chk_act_date .

* Date of submission of EPC agenda for endorsement by Director
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_agnda_act_dt
                                 'ZMM_TMS_EPC-EPC_AGNDA_ACT_DT'.

* Date of Endorsement by Concerned Director
  PERFORM chk_epc_act_date USING zmm_tms_epc-dr_endors_act_dt
                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.

* Date of submission of Agenda in EPC cell
  PERFORM chk_epc_act_date USING zmm_tms_epc-agnd_sub_act_dt
                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
* Date of EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_meet_act_dt
                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.

* Date of receipt of summary minutes of EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_smr_act_dt
                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.

* Date of receipt of summary note from EPC
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_smrn_act_dt
                                 'ZMM_TMS_EPC-EPC_SMRN_ACT_DT'.
*+001 : Start
* Date of last EPC meeting
  PERFORM chk_epc_act_date USING zmm_tms_epc-epc_fmeet_act_dt
                                 'ZMM_TMS_EPC-EPC_FMEET_ACT_DT'.
*+001 : End
ENDFORM.                    " CHK_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  CHK_EPC_ACT_DATE
*&---------------------------------------------------------------------*
* To validate EPC actual date
*----------------------------------------------------------------------*
*      -->P_ACT_DT     Actual date
*      -->P_ACT_DT_FN  Actual date : Dynpro field name
*----------------------------------------------------------------------*
FORM chk_epc_act_date  USING    p_act_dt
                                p_act_dt_fn.
  IF NOT p_act_dt IS INITIAL.

    IF p_act_dt GT sy-datum.

      SET CURSOR FIELD p_act_dt_fn.

      MESSAGE e031(zmmpurtdr).

    ENDIF.

  ENDIF.

ENDFORM.                    " CHK_EPC_ACT_DATE

*&---------------------------------------------------------------------*
*&      Form  CHK_DUP_TC_MEM
*&---------------------------------------------------------------------*
* * To check duplicate TC Member (With other TC Member)
*----------------------------------------------------------------------*
*      -->P_TC_MEMBER1   TC Member
*      -->P_TC_MEMBER1_F TC_Member field
*      -->P_TC_MEMBER2  TC Member
*      -->P_TC_MEMBER2_F TC_Member field
*      -->P_TC_MEMBER3  TC Member
*      -->P_TC_MEMBER3_F TC_Member field
*      -->P_TC_MEMBER4  TC Member
*      -->P_TC_MEMBER4_F TC_Member field
*      -->P_TC_MEMBER5  TC Member
*      -->P_TC_MEMBER5_F TC_Member field
*----------------------------------------------------------------------*
FORM chk_dup_tc_mem  USING    p_tc_member1
                              p_tc_member1_f
                              p_tc_member2
                              p_tc_member2_f
                              p_tc_member3
                              p_tc_member3_f
                              p_tc_member4
                              p_tc_member4_f
                              p_tc_member5
                              p_tc_member5_f.

  IF NOT p_tc_member2 IS INITIAL AND
         p_tc_member1 = p_tc_member2.

    SET CURSOR FIELD p_tc_member2_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member3 IS INITIAL AND
         p_tc_member1 = p_tc_member3.

    SET CURSOR FIELD p_tc_member3_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member4 IS INITIAL AND
         p_tc_member1 = p_tc_member4.

    SET CURSOR FIELD p_tc_member4_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member5 IS INITIAL AND
         p_tc_member1 = p_tc_member5.

    SET CURSOR FIELD p_tc_member5_f.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

ENDFORM.                    " CHK_DUP_TC_MEM

*&---------------------------------------------------------------------*
*&      Form  CHK_DUP_SUB_TC_MEM
*&---------------------------------------------------------------------*
* To check duplicate substitute TC member (with TC member)
*----------------------------------------------------------------------*
*      -->P_TC_MEMBER_S   Substitute TC member
*      -->P_TC_MEMBER_SF  Substitute TC member field
*      -->P_TC_MEMBER2    TC member
*      -->P_TC_MEMBER3    TC member
*      -->P_TC_MEMBER4    TC member
*      -->P_TC_MEMBER5    TC member
*----------------------------------------------------------------------*
FORM chk_dup_sub_tc_mem  USING    p_tc_member_s
                                  p_tc_member_sf
                                  p_tc_member2
                                  p_tc_member3
                                  p_tc_member4
                                  p_tc_member5.

  IF NOT p_tc_member2 IS INITIAL AND
         p_tc_member_s = p_tc_member2.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member3 IS INITIAL AND
         p_tc_member_s = p_tc_member3.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member4 IS INITIAL AND
         p_tc_member_s = p_tc_member4.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

  IF NOT p_tc_member5 IS INITIAL AND
         p_tc_member_s = p_tc_member5.

    SET CURSOR FIELD p_tc_member_sf.

    MESSAGE e034(zmmpurtdr).

  ENDIF.

ENDFORM.                    " CHK_DUP_SUB_TC_MEM

*&---------------------------------------------------------------------*
*&      Form  CHK_AUTHORITY
*&---------------------------------------------------------------------*
* To check authorized user
*----------------------------------------------------------------------*
*      -->P_UNAME  User name
*      -->P_SYCOD  User action
*----------------------------------------------------------------------*
FORM chk_authority  USING    p_uname
                             p_sycod.

  DATA : l_agr_name TYPE agr_users-agr_name.
  IF p_uname+0(1) <> 'C'.
    IF ( p_sycod = 'DISP' OR p_sycod = 'REP' ).
      SELECT AGR_NAME FROM AGR_USERS INTO L_AGR_NAME UP TO 1 ROWS
 WHERE ( AGR_NAME = TEXT-017 ) AND UNAME = P_UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc NE 0 AND l_agr_name IS INITIAL.

        CASE p_sycod.
          WHEN 'NEW'.
            MESSAGE e043(zpm) WITH text-009.
          WHEN 'CHNG'.
            MESSAGE e043(zpm) WITH text-010.
          WHEN 'DISP'.
            MESSAGE e043(zpm) WITH text-011.
          WHEN 'APRV'.
            MESSAGE e043(zpm) WITH text-012.
        ENDCASE.

      ENDIF.
    ELSE.
      SELECT AGR_NAME FROM AGR_USERS INTO L_AGR_NAME UP TO 1 ROWS
 WHERE ( AGR_NAME = TEXT-007 OR AGR_NAME = TEXT-008 ) AND UNAME = P_UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc NE 0 AND l_agr_name IS INITIAL.

        CASE p_sycod.
          WHEN 'NEW'.
            MESSAGE e043(zpm) WITH text-009.
          WHEN 'CHNG'.
            MESSAGE e043(zpm) WITH text-010.
          WHEN 'DISP'.
            MESSAGE e043(zpm) WITH text-011.
          WHEN 'APRV'.
            MESSAGE e043(zpm) WITH text-012.
        ENDCASE.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHK_AUTHORITY
*&---------------------------------------------------------------------*
*&      Form  UPD_REL_STATUS
*&---------------------------------------------------------------------*
* To update TMS release status : DB table ZMM_TMS
*----------------------------------------------------------------------*
FORM upd_rel_status .

**----------Start of change 29.06.2016 14:55:25 -------------------
** PERFORM CHK_TMS_REQ_DATA.
**----------End  of change 29.06.2016 14:55:25 -----------------


  IF ist_mesg[] IS INITIAL.

    UPDATE zmm_tms
         SET rel_stat = 'X'
            WHERE submi = zmm_pur_tender_d_st-submi.

    IF sy-subrc EQ 0.

      COMMIT WORK.
      MESSAGE i962(zmm) WITH zmm_pur_tender_d_st-submi.

      """""""""""""""""""""""""""""""""""""""""""""""
      """""""""""""added by lipsy on 26.02.2015 for tracking tc members changes RD1K995870

      CLEAR:wa_zmm_tms_tcn.
      v_rel_new = 'X'.
      PERFORM chng_doc_tc USING wa_zmm_tms-submi
                               wa_zmm_tms_tco
                               wa_zmm_tms_tcn.

      COMMIT WORK.
      """""""""""""end of addition  by lipsy on 26.02.2015 for tracking tc members changes RD1K995870


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""


      PERFORM unlock_record USING zmm_pur_tender_d_st-submi.

    ELSE.
      ROLLBACK WORK.
      MESSAGE e033(zpm).
    ENDIF.

  ENDIF.

ENDFORM.                    " UPD_REL_STATUS

*&---------------------------------------------------------------------*
*&      Form  CHK_TMS_REQ_DATA
*&---------------------------------------------------------------------*
* To check all mandatory fields before releasing tender document
* - Tender Status
* - Opening of price bids
* - Technical Bid Opening
*----------------------------------------------------------------------*
FORM chk_tms_req_data .

  DATA : l_lineno LIKE mesg-zeile.

  REFRESH : ist_mesg.

*+006 : Start
  IF zmm_pur_tender_d_st-banfn IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '974'.
    ist_mesg-msgv1 = text-057.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.
*+006 : End

*+005 : Start
  IF zmm_tms_general-pr_rcpt_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '972'.
    ist_mesg-msgv1 = text-018.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.
*+005 : End

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '960'.
    ist_mesg-msgv1 = text-013.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 10.03.2015 for loi date  RD1K995870
  IF zmm_tms_pb-loi_1_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM_OTH'.
    ist_mesg-msgno = '162'.
    ist_mesg-msgv1 = text-061.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.



  "end of addition by lipsy on 10.03.2015 for loi date  RD1K995870
  """"""""""""""""""""""""""""""""""""""""""""""""""""



  IF zmm_tms_tb-tend_op_act_dt IS INITIAL.

    ist_mesg-msgty = 'E'.
    ist_mesg-msgid = 'ZMM'.
    ist_mesg-msgno = '961'.
    ist_mesg-msgv1 = text-014.

    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

*+007 : Start
*+009 : Start
  IF zmm_tms_general-epc_typ = 'E'. "BEC approved by the EPC
  ELSE.
*+009 : End
    IF zmm_tms_tc-cpa IS INITIAL.

      ist_mesg-msgty = 'E'.
      ist_mesg-msgid = 'ZMM'.
      ist_mesg-msgno = '981'.
      ist_mesg-msgv1 = text-058.

      l_lineno = l_lineno + 1.
      ist_mesg-lineno = l_lineno.

      APPEND ist_mesg.

    ENDIF.

  ENDIF.                                         "+009

  IF zmm_tms_tc-tc_stat = 'X' AND
     zmm_tms_tc-tc_member1 IS INITIAL AND
     zmm_tms_tc-tc_member2 IS INITIAL AND
     zmm_tms_tc-tc_member3 IS INITIAL.

    ist_mesg-msgty = 'E'.

    """""""""""""""""""""""""""""""""""
    "comment by lipsy on 10.03.2015 for loi date  RD1K995870
*    ist_mesg-msgid = 'ZMM'.

    """"""""""""""""""""""""""""""""""""
    "comment by lipsy on 10.03.2015 for loi date  RD1K995870
*    ist_mesg-msgno = '981'.
    "end of comment by lipsy on 10.03.2015  for loi date  RD1K995870
    """"""""""""""""""""""""""""""""""
    """"""
    """"""""""""""""""""""""""""""
*    "add by lipsy on 10.03.2015  for 3 tc members  RD1K995870
    ist_mesg-msgid = 'ZMM_OTH'.
    ist_mesg-msgno = '238'.
*    "end of addition by lipsy on 10.03.2015  for 3 tc members   RD1K995870

    """"""""""""""""""""""""""""""""""
    """"""""""
    """"""""""""""""""""""""""""""""""""""""

    ist_mesg-msgv1 = text-059.

    """""""""""""""""""""""""""""""""""



    l_lineno = l_lineno + 1.
    ist_mesg-lineno = l_lineno.

    APPEND ist_mesg.

  ENDIF.

*+007 : End
  IF NOT ist_mesg[] IS INITIAL.

    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        i_message_tab = ist_mesg.

  ENDIF.

ENDFORM.                    " CHK_TMS_REQ_DATA
*&---------------------------------------------------------------------*
*&      Form  FILL_SVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_sval .
*+006 : Start
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
    CLEAR it_sval-field_attr.
  ELSE.
    it_sval-field_attr = '02'. "Display mode
  ENDIF.
*+006 " End

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN2'.
* it_sval-fieldtext  = 'PR2'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn2.  "+006
  it_sval-fieldtext  = 'Purchase Req.(2)'.          "+006
  it_sval-field_obl  = ''.

  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN3'.
* it_sval-fieldtext  = 'PR3'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn3.  "+006
  it_sval-fieldtext  = 'Purchase Req.(3)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN4'.
* it_sval-fieldtext  = 'PR4'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn4.  "+006
  it_sval-fieldtext  = 'Purchase Req.(4)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.

  it_sval-tabname    = 'ZMM_PUR_TENDER_D_ST'.
  it_sval-fieldname  = 'BANFN5'.
* it_sval-fieldtext  = 'PR5'.                       "-006
* it_sval-field_attr = ' '.                         "-006
  it_sval-value      = zmm_pur_tender_d_st-banfn5.  "+006
  it_sval-fieldtext  = 'Purchase Req.(5)'.          "+006
  it_sval-field_obl  = ''.
  APPEND it_sval.
ENDFORM.                    " FILL_SVAL
*&---------------------------------------------------------------------*
*&      Form  READ_CHANGE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1400   text
*      -->P_ZMM_PUR_TENDER_D_ST_BANFN  text
*      -->P_1402   text
*      <--P_ZMM_TMS_GENERAL_PR_FF_REL_DT  text
*----------------------------------------------------------------------*
FORM read_change_doc  USING  p_class
                             p_objectid
                             p_fname
                      CHANGING p_zdate.
*+007 : Start
  DATA : ist_cdhdr    TYPE TABLE OF cdhdr,
         ist_cdpos    TYPE TABLE OF cdpos,
         ist_cdpos_po TYPE TABLE OF cdpos,
         wa_cdpos     TYPE cdpos,
         wa_cdhdr     TYPE cdhdr.
*+007 : End

  CLEAR : ist_cdpos, wa_cdpos,ist_cdhdr,wa_cdhdr.
  REFRESH : ist_cdpos, ist_cdhdr.
  SELECT * FROM cdpos
    INTO CORRESPONDING FIELDS OF TABLE ist_cdpos
    WHERE   objectclas EQ p_class AND
                 objectid EQ p_objectid AND
                  fname EQ p_fname ORDER BY PRIMARY KEY.
  SORT ist_cdpos ASCENDING BY changenr.
  IF p_fname = 'FRGKE'.
    LOOP AT ist_cdpos INTO wa_cdpos
      WHERE value_new = 'S'.
      APPEND wa_cdpos TO ist_cdpos_po.
    ENDLOOP.
    ist_cdpos[] = ist_cdpos_po[].
    SORT ist_cdpos ASCENDING BY changenr.
  ENDIF.
  READ TABLE ist_cdpos INTO wa_cdpos INDEX 1.
  SELECT * FROM cdhdr
  INTO CORRESPONDING FIELDS OF TABLE ist_cdhdr
  WHERE   objectclas EQ  p_class AND
               objectid EQ p_objectid AND
                changenr EQ wa_cdpos-changenr.


  READ TABLE ist_cdhdr INTO wa_cdhdr INDEX 1.
  p_zdate = wa_cdhdr-udate.
ENDFORM.                    " READ_CHANGE_DOC

*&---------------------------------------------------------------------*
*&      Form  calc_various_dates
*&---------------------------------------------------------------------*
* To calculate various dates based on PR Receipt Date
*----------------------------------------------------------------------*
*      -->P_TEND_TYP   Tender Type
*      -->P_PR_RCPTDT  PR Receipt Date
*----------------------------------------------------------------------*
FORM calc_various_dates USING  p_tend_typ
                               p_pr_rcptdt.

  DATA : l_tval_stat(1).

  IF p_tend_typ = 'C'.             "Open Tender

*Approval of Dir/EPC required
*Approval of BEC &MQC
    IF zmm_tms_general-epc_typ = 'E'. "EPC

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 28. "33.

    ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 13.

    ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

      zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 18.

    ENDIF.

* Scheduled Tender date (NIT Date) i.e.
* NIT scheduled date field = zmm_pur_tender_d_st-sch_tdrdt
    zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 7.

*Scheduled tender sale opening
    zmm_pur_tender_d_st-sch_st_sel_dt = zmm_pur_tender_d_st-sch_tdrdt.

*Scheduled tender sale closing
    zmm_pur_tender_d_st-sch_lt_sel_dt
                                   = zmm_pur_tender_d_st-sch_tdrdt + 21.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
    PERFORM set_pre_bid_dt USING    zmm_tms_tc-pbc_stat
                                    zmm_pur_tender_d_st-sch_lt_sel_dt
                                    zmm_tms_general-lstk
                           CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                    zmm_tms_tc-pbc_sch_dt
                                    zmm_tms_tc-tc_met_pb_sch_dt
                                    zmm_tms_tc-reo_tsal_stat
                                    zmm_tms_tc-amd_issu_sch_dt
                                    zmm_tms_tc-reo_tsal_sch_dt
                                    zmm_tms_tc-rec_tsal_sch_dt
                                    zmm_tms_tc-subm_dl_sch_dt.

    IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
      zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
      zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
      zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
      zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
      zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
      zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
      IF zmm_tms_tb-no_rnd_clrf = 0.

        zmm_tms_tb-sb_tc_apv_sch_dt = zmm_tms_tb-tbid_eval_sch_dt + 3.

      ELSE.

        zmm_tms_tb-sb_tc_apv_sch_dt = zmm_tms_tb-tbid_eval_sch_dt +
                              ( zmm_tms_tb-no_rnd_clrf * 20 ).

      ENDIF.

*Scheduled opening of price bids
      zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 5.

*Scheduled CS preparation date
      zmm_tms_pb-cs_prep_dt_sch = zmm_tms_pb-pr_bid_op_sch_dt + 3.

*Scheduled CS vetting date
      zmm_tms_pb-cs_vett_dt_sch = zmm_tms_pb-cs_prep_dt_sch + 4.

*Scheduled date of final TC (for award)
      zmm_tms_pb-tc_awrd_sch_dt = zmm_tms_pb-cs_vett_dt_sch + 5.

*Scheduled date of approval of award
      IF zmm_tms_pb-epc_typ_pb EQ zmm_tms_general-epc_typ.

        IF zmm_tms_general-epc_typ = 'E'. "EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

        ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

        ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

        ENDIF.

      ELSE.

        IF zmm_tms_pb-epc_typ_pb = 'E'. "EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

        ELSEIF zmm_tms_pb-epc_typ_pb = 'D'. "Director

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

        ELSEIF zmm_tms_pb-epc_typ_pb = 'N'. "Non-EPC

          zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

        ENDIF.

      ENDIF.

*Scheduled date of first LOI
      IF NOT zmm_tms_pb-aprv_awrd_sch_dt IS INITIAL.

        zmm_tms_pb-loi_1_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 1.

*Scheduled date of EMD release of unsuccessful bidder(s)
        zmm_tms_pb-emd_rel_ub_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 7.

      ENDIF.

*Scheduled date of receipt of PBG
      IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

        zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

      ENDIF.

    ENDIF.

  ELSEIF p_tend_typ = 'L'.             "Limited Tender

*Tender Value Status
    IF zmm_pur_tender_d_st-tndr_val GT 2500000.

      l_tval_stat = 'A'.

    ELSEIF zmm_pur_tender_d_st-tndr_val BETWEEN 500000 AND 2500000.

      l_tval_stat = 'B'.

    ELSE.

      l_tval_stat = 'C'.

    ENDIF.

    CASE l_tval_stat.

      WHEN 'A'.           "Tender value more than 2500000
*Approval of Dir/EPC required
*Approval of BEC &MQC
        IF zmm_tms_general-epc_typ = 'E'. "EPC

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 28.

        ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 13.

        ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

          zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 18.

        ENDIF.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 7.

*Scheduled request for tender enquiries from bidders
        zmm_tms_tc-tnd_enq_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 10.

*Scheduled verification & issue of tender to bidders
        zmm_tms_tc-verf_iss_sch_dt = zmm_tms_tc-tnd_enq_sch_dt + 6.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
          IF zmm_tms_tb-no_rnd_clrf IS INITIAL.

            zmm_tms_tb-sb_tc_apv_sch_dt
                    = zmm_tms_tb-tbid_eval_sch_dt + 3.

          ELSE.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt +
                        ( zmm_tms_tb-no_rnd_clrf * 20 ).

          ENDIF.

*Scheduled opening of price bids
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 5.

*Scheduled CS preparation date
          zmm_tms_pb-cs_prep_dt_sch = zmm_tms_pb-pr_bid_op_sch_dt + 3.

*Scheduled CS vetting date
          zmm_tms_pb-cs_vett_dt_sch = zmm_tms_pb-cs_prep_dt_sch + 4.

*Scheduled date of final TC (for award)
          zmm_tms_pb-tc_awrd_sch_dt = zmm_tms_pb-cs_vett_dt_sch + 5.

*Scheduled date of approval of award
          IF zmm_tms_pb-epc_typ_pb EQ zmm_tms_general-epc_typ.

            IF zmm_tms_general-epc_typ = 'E'. "EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

            ELSEIF zmm_tms_general-epc_typ = 'D'. "Director

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

            ELSEIF zmm_tms_general-epc_typ = 'N'. "Non-EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

            ENDIF.

          ELSE.

            IF zmm_tms_pb-epc_typ_pb = 'E'. "EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 18.

            ELSEIF zmm_tms_pb-epc_typ_pb = 'D'. "Director

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 8.

            ELSEIF zmm_tms_pb-epc_typ_pb = 'N'. "Non-EPC

              zmm_tms_pb-aprv_awrd_sch_dt = zmm_tms_pb-tc_awrd_sch_dt + 3.

            ENDIF.

          ENDIF.

*Scheduled date of first LOI
          IF NOT zmm_tms_pb-aprv_awrd_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 1.

*Scheduled date of EMD release of unsuccessful bidder(s)
            zmm_tms_pb-emd_rel_ub_sch_dt = zmm_tms_pb-aprv_awrd_sch_dt + 7.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

      WHEN 'B'.   "Tender Value between 500000 and 2500000

*Approval of BEC &MQC
        zmm_tms_tc-tc_aprv_sch_dt = p_pr_rcptdt + 10.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = zmm_tms_tc-tc_aprv_sch_dt + 5.

*Scheduled request for tender enquiries from bidders
        zmm_tms_tc-tnd_enq_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 10.

*Scheduled verification & issue of tender to bidders
        zmm_tms_tc-verf_iss_sch_dt = zmm_tms_tc-tnd_enq_sch_dt + 6.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt + 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt + 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 8.

*Scheduled date of approval of tc meeting for shortlisting of bids
          IF zmm_tms_tb-no_rnd_clrf IS INITIAL.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt + 2.

          ELSE.

            zmm_tms_tb-sb_tc_apv_sch_dt
                      = zmm_tms_tb-tbid_eval_sch_dt +
                        ( zmm_tms_tb-no_rnd_clrf * 20 ).
          ENDIF.

          CLEAR : "zmm_tms_pb-pr_bid_op_sch_dt,       "-009
                  zmm_tms_pb-cs_prep_dt_sch,
                  zmm_tms_pb-cs_vett_dt_sch,
                  zmm_tms_pb-tc_awrd_sch_dt,
                  zmm_tms_pb-aprv_awrd_sch_dt.

*+009 : Start
* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.
*+009 : End

*Scheduled date of first LOI
          IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

      WHEN 'C'.   "Tender Value less than 500000

        CLEAR : zmm_tms_tc-tc_aprv_sch_dt,
                zmm_tms_tc-tnd_enq_sch_dt,
                zmm_tms_tc-verf_iss_sch_dt.

*Scheduled Tender date
        zmm_pur_tender_d_st-sch_tdrdt = p_pr_rcptdt.

* To calculate scheduled date : Receipt of querry from Bidders &
* Scrutiny and PBC Date
        PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                        zmm_pur_tender_d_st-tndr_val
                                        zmm_pur_tender_d_st-sch_tdrdt
                                        zmm_tms_tc-verf_iss_sch_dt
                                        zmm_tms_general-lstk
                               CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                        zmm_tms_tc-pbc_sch_dt
                                        zmm_tms_tc-amd_issu_sch_dt
                                        zmm_tms_tc-subm_dl_sch_dt.

        IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
          zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
          zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt. "+ 4.

*Scheduled CS vetting date
          zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 1. "4.

*Scheduled bid forwarding to indentor
          zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt. " + 1.

*Scheduled date of receipt of technical comments
          zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt. "+ 7.

*Scheduled TCs for techno-commerical bid evaluation
          zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 2. "8.


*Scheduled date of approval of tc meeting for shortlisting of bids
          zmm_tms_tb-sb_tc_apv_sch_dt
                                = zmm_tms_tb-tbid_eval_sch_dt + 2.

          CLEAR : "zmm_tms_pb-pr_bid_op_sch_dt,  "-008
                  zmm_tms_pb-cs_prep_dt_sch,
                  zmm_tms_pb-cs_vett_dt_sch,
                  zmm_tms_pb-tc_awrd_sch_dt,
                  zmm_tms_pb-aprv_awrd_sch_dt.

*+008 : Start
* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
          zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.
*+008 : End

*Scheduled date of first LOI
          IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

            zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

          ENDIF.

*Scheduled date of receipt of PBG
          IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

            zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

          ENDIF.

        ENDIF.

    ENDCASE.

*+008 : Logic for Single tender/Board Purchase  : Start
* To get various dates based on PR Receipt Date
  ELSEIF p_tend_typ = 'S' OR             "Single Tender
         p_tend_typ = 'B'.               "Board Purchase

    CLEAR : zmm_tms_tc-tc_aprv_sch_dt,
            zmm_tms_tc-tnd_enq_sch_dt,
            zmm_tms_tc-verf_iss_sch_dt.

*Scheduled Tender date
    zmm_pur_tender_d_st-sch_tdrdt = p_pr_rcptdt.

* To calculate scheduled date : Submission deadline of tender
    zmm_tms_tc-subm_dl_sch_dt = zmm_pur_tender_d_st-sch_tdrdt + 21.

    IF NOT zmm_tms_tc-subm_dl_sch_dt IS INITIAL.

*Scheduled technical bid opening date
      zmm_tms_tb-tend_op_sch_dt = zmm_tms_tc-subm_dl_sch_dt.

*Scheduled CS preparation date
      zmm_tms_tb-cs_prep_sch_dt = zmm_tms_tb-tend_op_sch_dt. "+ 4.

*Scheduled CS vetting date
      zmm_tms_tb-cs_vet_sch_dt = zmm_tms_tb-cs_prep_sch_dt + 1. "4.

*Scheduled bid forwarding to indentor
      zmm_tms_tb-bid_fwd_sch_dt = zmm_tms_tb-tend_op_sch_dt. " + 1.

*Scheduled date of receipt of technical comments
      zmm_tms_tb-tc_rcpt_sch_dt = zmm_tms_tb-bid_fwd_sch_dt. "+ 7.

*Scheduled TCs for techno-commerical bid evaluation
      zmm_tms_tb-tbid_eval_sch_dt = zmm_tms_tb-tc_rcpt_sch_dt + 2. "8.


*Scheduled date of approval of tc meeting for shortlisting of bids
      zmm_tms_tb-sb_tc_apv_sch_dt
                            = zmm_tms_tb-tbid_eval_sch_dt + 2.

      CLEAR : zmm_tms_pb-cs_prep_dt_sch,
              zmm_tms_pb-cs_vett_dt_sch,
              zmm_tms_pb-tc_awrd_sch_dt,
              zmm_tms_pb-aprv_awrd_sch_dt.

* Schedule Price bid opening date should be equal to schedule Technical
* Bid Opening date
      zmm_tms_pb-pr_bid_op_sch_dt = zmm_tms_tb-tend_op_sch_dt.

*Scheduled date of first LOI
      IF NOT zmm_tms_tb-sb_tc_apv_sch_dt IS INITIAL.

        zmm_tms_pb-loi_1_sch_dt = zmm_tms_tb-sb_tc_apv_sch_dt + 1.

      ENDIF.

*Scheduled date of receipt of PBG
      IF NOT zmm_tms_pb-loi_1_sch_dt IS INITIAL.

        zmm_tms_pb-pbg_rcpt_sch_dt = zmm_tms_pb-loi_1_sch_dt + 15.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    "calc_various_dates

*&---------------------------------------------------------------------*
*&      Form  CHK_REQUIRED_INPUT
*&---------------------------------------------------------------------*
* To validate If user enters PR number, then PR receipt date should
* be mandatory.
*----------------------------------------------------------------------*
*      <--P_CHK  Check Status
*----------------------------------------------------------------------*
FORM chk_required_input  CHANGING p_chk.
**----------Start of change 01.07.2016 11:11:01 REKHA  -------------------
*  IF NOT zmm_pur_tender_d_st-banfn  IS INITIAL AND
*         zmm_tms_general-pr_rcpt_dt IS INITIAL.


**Code commented to make  date as non mandatory
* p_chk = 'X'.
*
*    MESSAGE i127(zmm_oth).



*  ENDIF.
*  **----------End  of change 01.07.2016 11:11:01 REKHA  -----------------

**----------Start of change 06.07.2016 11:03:51 REKHA to make follwinf field mandatory   -------------------

  IF zmm_tms_tc-cpa IS INITIAL OR zmm_tms_tc-indentor IS INITIAL
  OR zmm_tms_tc-ic_mm IS INITIAL OR zmm_tms_tc-l1 IS INITIAL .
    p_chk = 'X'.
*
    MESSAGE i502(zmm_oth).
  ENDIF.
**----------End  of change 06.07.2016 11:03:51 REKHA  -----------------



ENDFORM.                    " CHK_REQUIRED_INPUT

*&---------------------------------------------------------------------*
*&      Form  SET_PRE_BID_DT
*&---------------------------------------------------------------------*
* To calculate scheduled date
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*----------------------------------------------------------------------*
*      -->P_PBC_STAT         Pre bid conference status
*      -->P_ST_SCH_LT_SEL    Schedule last date of selling tender
*      -->P_LSTK             LSTK Project type
*      <--P_RCPT_BID_SCH_DT  Date of receipt of querry from Bidders
*      <--P_PBC_SCH_DT       Pre bid conference date
*      <--P_TC_MET_PB_SCH_DT Date of approval of TC meeting - Prebid ...
*      <--P_REO_TSAL_STAT    Reopening of sale required
*      <--P_AMD_ISSU_SCH_DT  Date of Issue of amendments after PBC
*      <--P_REO_TSAL_SCH_DT  Re-Opening of tender sale
*      <--P_REC_TSAL_SCH_DT  Re-Closing of tender sale
*      <-P_SUBM_DL_SCH_DT    Submission Deadline of Tender
*----------------------------------------------------------------------*
FORM set_pre_bid_dt  USING    p_pbc_stat
                              p_st_sch_lt_sel
                              p_lstk
                     CHANGING p_rcpt_bid_sch_dt
                              p_pbc_sch_dt
                              p_tc_met_pb_sch_dt
                              p_reo_tsal_stat
                              p_amd_issu_sch_dt
                              p_reo_tsal_sch_dt
                              p_rec_tsal_sch_dt
                              p_subm_dl_sch_dt.

  IF p_pbc_stat = 'Y' AND NOT p_st_sch_lt_sel IS INITIAL.

*Scheduled date of receipt of querry from Bidders
    p_rcpt_bid_sch_dt = p_st_sch_lt_sel + 7.

*Scheduled scrutiny and PBC Date
    p_pbc_sch_dt = p_rcpt_bid_sch_dt + 8.

*Scheduled date of approval of TC meeting - Prebid confer. Issue
    p_tc_met_pb_sch_dt = p_pbc_sch_dt + 8.

    IF p_reo_tsal_stat = 'Y'.
*Date of Issue of amendments after PBC
      p_amd_issu_sch_dt = p_pbc_sch_dt + 13.

*Re-Opening of tender sale
*     p_reo_tsal_sch_dt = p_amd_issu_sch_dt.
      p_reo_tsal_sch_dt = p_amd_issu_sch_dt + 7.

*Re-Closing of tender sale
*     p_rec_tsal_sch_dt = p_amd_issu_sch_dt + 15.
      p_rec_tsal_sch_dt = p_reo_tsal_sch_dt + 15.

    ELSE.
*Date of Issue of amendments after PBC
      p_amd_issu_sch_dt = p_pbc_sch_dt + 8.

      CLEAR : p_reo_tsal_sch_dt,
              p_rec_tsal_sch_dt.
    ENDIF.

  ELSE.

    CLEAR : p_rcpt_bid_sch_dt,
            p_pbc_sch_dt,
            p_tc_met_pb_sch_dt,
            p_amd_issu_sch_dt,
            p_reo_tsal_sch_dt,
            p_rec_tsal_sch_dt.

*    p_reo_tsal_stat = 'N'.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-sch_lt_sel_dt IS INITIAL OR
     NOT p_amd_issu_sch_dt IS INITIAL OR
     NOT p_rec_tsal_sch_dt IS INITIAL.

    PERFORM calc_subm_deadline USING p_pbc_stat
                                     p_lstk
                                     p_reo_tsal_stat
                                     zmm_pur_tender_d_st-sch_lt_sel_dt
                                     p_amd_issu_sch_dt
                                     p_rec_tsal_sch_dt
                                 CHANGING p_subm_dl_sch_dt.
  ENDIF.

ENDFORM.                    " SET_PRE_BID_DT

*&---------------------------------------------------------------------*
*&      Form  CALC_SUBM_DEADLINE
*&---------------------------------------------------------------------*
* to calculate submission deadline
*----------------------------------------------------------------------*
*      -->P_PBC_STAT        Pre bid conference status
*      -->P_LSTK_STAT       LSTK
*      -->P_REO_TSAL_STAT   Reopening of sale required
*      -->P_ST_SCH_LT_SEL   Last date of selling tender
*      -->P_AMD_ISSU_SCH_DT Date of Issue of amendments after PBC
*      -->P_REC_TSAL_SCH_DT Re-Closing of tender sale
*      <--P_SUBM_DL_SCH_DT  Submission Deadline
*----------------------------------------------------------------------*
FORM calc_subm_deadline  USING    p_pbc_stat
                                  p_lstk
                                  p_reo_tsal_stat
                                  p_st_sch_lt_sel
                                  p_amd_issu_sch_dt
                                  p_rec_tsal_sch_dt
                         CHANGING p_subm_dl_sch_dt.

  CASE p_reo_tsal_stat. "Reopening of sale required

    WHEN 'N'.

      CASE p_lstk. "LSTK

        WHEN 'P'. "Process Platforms

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 51.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 40.

              ENDIF.

          ENDCASE.

        WHEN 'O'. "Other LSTK Projects

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 36.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 25.

              ENDIF.

          ENDCASE.

        WHEN 'N'. "No

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_amd_issu_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_amd_issu_sch_dt + 21.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 10.

              ENDIF.

          ENDCASE.

      ENDCASE.

    WHEN 'Y'.

      CASE p_lstk. "LSTK

        WHEN 'P'. "Process Platforms

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 51.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 40.

              ENDIF.

          ENDCASE.

        WHEN 'O'. "Other LSTK Projects

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 36.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 25.

              ENDIF.

          ENDCASE.

        WHEN 'N'. "No

          CASE p_pbc_stat. "Pre bid conference status

            WHEN 'Y'.

              IF NOT p_rec_tsal_sch_dt IS INITIAL.

                p_subm_dl_sch_dt = p_rec_tsal_sch_dt + 21.

              ENDIF.

            WHEN 'N'.

              IF NOT p_st_sch_lt_sel IS INITIAL.

                p_subm_dl_sch_dt = p_st_sch_lt_sel + 10.

              ENDIF.

          ENDCASE.

      ENDCASE.

  ENDCASE.

ENDFORM.                    " CALC_SUBM_DEADLINE

*&---------------------------------------------------------------------*
*&      Form  SET_PRE_BID_L_DT
*&---------------------------------------------------------------------*
* To calculate scheduled date
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*  -
*  -
*----------------------------------------------------------------------*
*      -->P_PBC_STAT         Pre bid conference status
*      -->P_TNDR_VAL         Tender value
*      -->P_SCH_TDRDT        Schedule tender date
*      -->P_VERF_ISS_SCH_DT  Scheduled verification & issue of tender..
*      -->P_LSTK             LSTK Project type
*      <--P_RCPT_BID_SCH_DT  Date of receipt of querry from Bidders
*      <--P_PBC_SCH_DT       Pre bid conference date
*      <--P_AMD_ISSU_SCH_DT  Date of Issue of amendments after PBC
*      <-P_SUBM_DL_SCH_DT    Submission Deadline of Tender
*----------------------------------------------------------------------*
FORM set_pre_bid_l_dt  USING    p_pbc_stat
                                p_tndr_val
                                p_sch_tdrdt
                                p_verf_iss_sch_dt
                                p_lstk
                       CHANGING p_rcpt_bid_sch_dt
                                p_pbc_sch_dt
                                p_amd_issu_sch_dt
                                p_subm_dl_sch_dt.

  DATA : l_tval_stat(1),
         l_reo_tsal_stat(1) VALUE 'N',
         l_date             TYPE sy-datum.

*Tender Value Status
  IF p_tndr_val GT 2500000.

    l_tval_stat = 'A'.

  ELSEIF p_tndr_val BETWEEN 500000 AND 2500000.

    l_tval_stat = 'B'.

  ELSE.

    l_tval_stat = 'C'.

  ENDIF.

  IF p_pbc_stat = 'Y' AND NOT p_verf_iss_sch_dt IS INITIAL.

    IF l_tval_stat = 'A'.

*Scheduled date of receipt of querry from Bidders
      p_rcpt_bid_sch_dt = p_verf_iss_sch_dt + 7.

*Scheduled scrutiny and PBC Date
      p_pbc_sch_dt = p_rcpt_bid_sch_dt + 8.

*Date of Issue of amendments after PBC[Approval & Issue of PBC Minutes]
      p_amd_issu_sch_dt = p_pbc_sch_dt + 8.

    ELSE.

      CLEAR : p_rcpt_bid_sch_dt,
              p_pbc_sch_dt,
              p_amd_issu_sch_dt.

    ENDIF.

  ENDIF.

  IF l_tval_stat = 'A'.

    IF NOT p_verf_iss_sch_dt IS INITIAL OR
       NOT  p_amd_issu_sch_dt IS INITIAL.

      PERFORM calc_subm_deadline USING p_pbc_stat
                                       p_lstk
                                       l_reo_tsal_stat
                                       p_verf_iss_sch_dt
                                       p_amd_issu_sch_dt
                                       l_date
                                    CHANGING p_subm_dl_sch_dt.

    ENDIF.

  ELSEIF l_tval_stat = 'B'.

    p_subm_dl_sch_dt = p_verf_iss_sch_dt + 10.

  ELSEIF l_tval_stat = 'C'.

    p_subm_dl_sch_dt = p_sch_tdrdt + 21.

  ENDIF.

ENDFORM.                    " SET_PRE_BID_L_DT

*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_PR_RCPT_DT
*&---------------------------------------------------------------------*
* To maintain log : PR receipt date
*----------------------------------------------------------------------*
*      -->P_SUBMI            Tender No.
*      -->P_PR_RCPT_DT_N     PR Receipt Date(new)
*      -->P_PR_RCPT_DT_O     PR Receipt Date(old)
*----------------------------------------------------------------------*
FORM chng_doc_pr_rcpt_dt USING p_submi
                               p_pr_rcpt_dt_n
                               p_pr_rcpt_dt_o.

  DATA : wa_zmm_tms_o TYPE  zmm_tms,
         wa_zmm_tms_n TYPE  zmm_tms.

  DATA : ist_chngind TYPE TABLE OF cdtxt WITH HEADER LINE.

  DATA : l_objectid TYPE cdhdr-objectid.

  l_objectid = p_submi.

*  MOVE-CORRESPONDING zmm_tms TO wa_zmm_tms_n.
*  MOVE-CORRESPONDING zmm_tms TO wa_zmm_tms_o.

  wa_zmm_tms_n-pr_rcpt_dt = p_pr_rcpt_dt_n.

  wa_zmm_tms_o-pr_rcpt_dt = p_pr_rcpt_dt_o.

  CALL FUNCTION 'ZPR_RCPT_DT_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
      object_change_indicator = 'U'
      n_zmm_tms               = wa_zmm_tms_n
      o_zmm_tms               = wa_zmm_tms_o
      upd_zmm_tms             = 'U'
    TABLES
      icdtxt_zpr_rcpt_dt      = ist_chngind.

ENDFORM.                    " CHNG_DOC_PR_RCPT_DT

*&---------------------------------------------------------------------*
*&      Form  GET_NO_RFQ_MAINT
*&---------------------------------------------------------------------*
* To get Nos. of RFQ maintained
*----------------------------------------------------------------------*
*      -->P_BANFN   PR No.
*      <--P_NO_REQ  No. of RFQ
*----------------------------------------------------------------------*
FORM get_no_rfq_maint  USING    p_banfn
                       CHANGING p_no_req.
  DATA : BEGIN OF wa_ebeln,
           banfn TYPE eban-banfn,
           ebeln TYPE ekko-ebeln,
         END OF wa_ebeln.

  DATA : ist_ebeln LIKE TABLE OF wa_ebeln.

  DATA : l_count TYPE sy-tabix.

  SELECT banfn ebeln FROM m_mekke
       INTO CORRESPONDING FIELDS OF TABLE ist_ebeln
          WHERE banfn =  p_banfn.

  IF NOT ist_ebeln[] IS INITIAL.

    SORT ist_ebeln BY ebeln.

    DELETE ADJACENT DUPLICATES FROM ist_ebeln  COMPARING ebeln.

    SELECT COUNT( * ) FROM ekko INTO l_count
         FOR ALL ENTRIES IN ist_ebeln
             WHERE ebeln = ist_ebeln-ebeln AND
                   statu = 'A'.

    IF sy-subrc = 0.
      p_no_req = l_count.
    ELSE.
      CLEAR p_no_req.
    ENDIF.

  ELSE.

    CLEAR p_no_req.

  ENDIF.

ENDFORM.                    " GET_NO_RFQ_MAINT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_NITDATE
*&---------------------------------------------------------------------*
* To set I/O attribute of screen field NIIT Date in Create/Change mode
*----------------------------------------------------------------------*
FORM display_nitdate .
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
    IF NOT zmm_pur_tender_d_st-tndr_val IS INITIAL OR
      NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.
      IF zmm_pur_tender_d_st-tndr_val < 500000 OR
         zmm_pur_tender_d_st-tndr_proc = 10 OR
         zmm_pur_tender_d_st-tndr_proc = 11 OR
         zmm_pur_tender_d_st-tndr_proc = 12 OR
         zmm_pur_tender_d_st-tndr_proc = 13 OR
         zmm_pur_tender_d_st-tndr_proc = 14 OR
         zmm_pur_tender_d_st-tndr_proc = 15 OR
         zmm_pur_tender_d_st-tndr_proc =  7 OR
         zmm_pur_tender_d_st-tndr_proc =  8 OR
         zmm_pur_tender_d_st-tndr_proc =  9.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
            screen-input = 0.
            MODIFY SCREEN.
            CLEAR zmm_pur_tender_d_st-nitdate.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " DISPLAY_NITDATE

*&---------------------------------------------------------------------*
*&      Form  UPD_PURQ_PROFILE
*&---------------------------------------------------------------------*
* Update Procurement Profile of  Purchase Requistion
*----------------------------------------------------------------------*
FORM upd_purq_profile.

  DATA: BEGIN OF ist_eban OCCURS 0.
          INCLUDE STRUCTURE ueban.
  DATA:     upd(1) TYPE c,
            del(1) TYPE c,
            END OF ist_eban.

  DATA : ist_eban_f LIKE TABLE OF ist_eban WITH HEADER LINE.

  DATA: pe_t_xeban      LIKE ueban OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_xebkn      LIKE uebkn OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_yeban   LIKE ueban OCCURS 0 WITH HEADER LINE,
        pe_t_yeban_t LIKE ueban OCCURS 0 WITH HEADER LINE.

  DATA: pe_t_yebkn      LIKE uebkn OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF wa_banfn,
           banfn TYPE eban-banfn,
         END OF wa_banfn.

  DATA : ist_banfn   LIKE TABLE OF wa_banfn.

  IF zmm_pur_tender_d_st-bsart+0(2) = 'ET' AND
     NOT zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn2 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn2 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn3 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn3 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT zmm_pur_tender_d_st-banfn4 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn4 TO wa_banfn-banfn.
      APPEND wa_banfn TO ist_banfn.
    ENDIF.

    IF NOT ist_banfn[] IS INITIAL.

      LOOP AT ist_banfn INTO wa_banfn.

        REFRESH : ist_eban,
                  pe_t_yeban_t,
                  pe_t_xeban,
                  pe_t_xebkn,
                  pe_t_yeban,
                  pe_t_yebkn.

        CLEAR : ist_eban,
                pe_t_yeban_t,
                pe_t_xeban,
                pe_t_xebkn,
                pe_t_yeban,
                pe_t_yebkn.

        SELECT * FROM eban
           INTO CORRESPONDING FIELDS OF TABLE ist_eban
                 WHERE banfn = wa_banfn-banfn.

        SORT ist_eban BY banfn bnfpo.

        LOOP AT ist_eban.

          MOVE-CORRESPONDING ist_eban TO pe_t_yeban_t.

          APPEND pe_t_yeban_t.

        ENDLOOP.

        LOOP AT ist_eban.

          CLEAR : ist_eban-eprofile.

          ist_eban-kz = 'U'.

          MODIFY ist_eban INDEX sy-tabix TRANSPORTING eprofile kz.

        ENDLOOP.

        LOOP AT ist_eban.

          LOOP AT pe_t_yeban_t WHERE banfn = ist_eban-banfn AND
                                     bnfpo = ist_eban-bnfpo.

            MOVE-CORRESPONDING ist_eban TO pe_t_xeban.

            APPEND pe_t_xeban.

            MOVE-CORRESPONDING pe_t_yeban_t TO pe_t_yeban.

            APPEND pe_t_yeban.

          ENDLOOP.

        ENDLOOP.

        CALL FUNCTION 'Z_ME_CREATE_REQ'
          TABLES
            xeban = pe_t_xeban.

        CALL FUNCTION 'ME_UPDATE_REQUISITION'
          TABLES
            xeban = pe_t_xeban
            xebkn = pe_t_xebkn
            yeban = pe_t_yeban
            yebkn = pe_t_yebkn.

      ENDLOOP.

    ENDIF.

  ENDIF.

ENDFORM.                    "UPD_PURQ_PROFILE
*&---------------------------------------------------------------------*
*&      Form  CHECK_MM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER1  text
*----------------------------------------------------------------------*
FORM check_mm  USING p_zmm_tms_tc_tc_member1.
*               CHANGING l_disc_cd type ty_data-disc_cd.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data.

  MOVE sy-datum TO l_date.

  IF NOT  p_zmm_tms_tc_tc_member1 IS INITIAL.
**----------Start of change 27.06.2016 16:50:44 -------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*           D~DISC_CD AS DISC_CD
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                 ON C~DESIGNO = D~DESIG_CODE AND
*                     C~R_P_CD  = D~R_P_CD AND
*                     C~VERSION = D~VERSION )
*                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER1 AND
*                        A~SPRPS = ' '     AND
**Begin of <RD1K964434>.
**                        a~endda = '99991231' AND
*                         A~ENDDA GE L_DATE AND
**End of <RD1K964434>.
*                         C~SPRPS = ' ' AND
**Begin of <RD1K964434>.
**                        c~endda = '99991231' .
*                         C~ENDDA GE L_DATE .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
            a~persk a~sbmod  c~designo c~r_p_cd c~version
          d~sdesig_text AS designation d~adesig_text AS adesignation
          d~disc_cd AS disc_cd
            INTO CORRESPONDING FIELDS OF TABLE ist_data
       FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
             ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                ON c~designo = d~desig_code AND
                    c~r_p_cd  = d~r_p_cd AND
                    c~version = d~version )
                 WHERE a~pernr =  p_zmm_tms_tc_tc_member1 AND
                       a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                        a~endda GE l_date AND
*End of <RD1K964434>.
                        c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                        c~endda GE l_date .
**----------End  of change 27.06.2016 16:50:44 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF wa_data-disc_cd <> '36'.
      CLEAR p_zmm_tms_tc_tc_member1.
      MESSAGE e206(zmm_oth) WITH text-202.
    ENDIF.
*    l_disc_cd_1 = wa_DATA-DISC_CD.
*    if wa_DATA-DISC_CD = '36'.
*      l_mm = 'X'.
*    endif.
*    if wa_DATA-DISC_CD = '13'.
*      l_fi = 'X'.
*    endif.
  ENDIF.

ENDFORM.                    " CHECK_MM
*&---------------------------------------------------------------------*
*&      Form  CHECK_FI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER2_S  text
*----------------------------------------------------------------------*
FORM check_fi  USING    p_zmm_tms_tc_tc_member2_s.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data .

  MOVE sy-datum TO l_date.

  IF NOT p_zmm_tms_tc_tc_member2_s IS INITIAL.
**----------Start of change 27.06.2016 16:51:53 -------------------
**
**    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
**             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
**           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
**           D~DISC_CD AS DISC_CD
**             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
**        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
**              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
**                 ON C~DESIGNO = D~DESIG_CODE AND
**                     C~R_P_CD  = D~R_P_CD AND
**                     C~VERSION = D~VERSION )
**                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER2_S AND
**                        A~SPRPS = ' '     AND
***Begin of <RD1K964434>.
***                        a~endda = '99991231' AND
**                         A~ENDDA GE L_DATE AND
***End of <RD1K964434>.
**                         C~SPRPS = ' ' AND
***Begin of <RD1K964434>.
***                        c~endda = '99991231' .
**                         C~ENDDA GE L_DATE .


    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
         a~persk a~sbmod  c~designo c~r_p_cd c~version
       d~sdesig_text AS designation d~adesig_text AS adesignation
       d~disc_cd AS disc_cd
         INTO CORRESPONDING FIELDS OF TABLE ist_data
    FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
          ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
             ON c~designo = d~desig_code AND
                 c~r_p_cd  = d~r_p_cd AND
                 c~version = d~version )
              WHERE a~pernr =  p_zmm_tms_tc_tc_member2_s AND
                    a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                     a~endda GE l_date AND
*End of <RD1K964434>.
                     c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                     c~endda GE l_date .
**----------End  of change 27.06.2016 16:51:53 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF wa_data-disc_cd <> '13'.
      CLEAR p_zmm_tms_tc_tc_member2_s.
      MESSAGE e206(zmm_oth) WITH text-203.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_FI
*&---------------------------------------------------------------------*
*&      Form  CHECK_INDENTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZMM_TMS_TC_TC_MEMBER3_S  text
*----------------------------------------------------------------------*
FORM check_indentor  USING    p_zmm_tms_tc_tc_member3_s.
  CLEAR :  ist_data , wa_data.
  REFRESH : ist_data .

  MOVE sy-datum TO l_date.

  IF NOT p_zmm_tms_tc_tc_member3_s IS INITIAL.
**----------Start of change 27.06.2016 16:53:39 -------------------
*    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
*             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
*           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
*           D~DISC_CD AS DISC_CD
*             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
*        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
*              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
*                 ON C~DESIGNO = D~DESIG_CODE AND
*                     C~R_P_CD  = D~R_P_CD AND
*                     C~VERSION = D~VERSION )
*                  WHERE A~PERNR =  P_ZMM_TMS_TC_TC_MEMBER3_S AND
*                        A~SPRPS = ' '     AND
**Begin of <RD1K964434>.
**                        a~endda = '99991231' AND
*                         A~ENDDA GE L_DATE AND
**End of <RD1K964434>.
*                         C~SPRPS = ' ' AND
**Begin of <RD1K964434>.
**                        c~endda = '99991231' .
*                         C~ENDDA GE L_DATE .

    SELECT a~pernr a~begda a~endda a~ename AS name a~bukrs  a~werks
            a~persk a~sbmod  c~designo c~r_p_cd c~version
          d~sdesig_text AS designation d~adesig_text AS adesignation
          d~disc_cd AS disc_cd
            INTO CORRESPONDING FIELDS OF TABLE ist_data
       FROM ( ( zpa0001 AS a INNER JOIN zpa9930 AS c
             ON a~pernr = c~pernr ) INNER JOIN zdesignation_rev AS d
                ON c~designo = d~desig_code AND
                    c~r_p_cd  = d~r_p_cd AND
                    c~version = d~version )
                 WHERE a~pernr =  p_zmm_tms_tc_tc_member3_s AND
                       a~sprps = ' '     AND
*Begin of <RD1K964434>.
*                        a~endda = '99991231' AND
                        a~endda GE l_date AND
*End of <RD1K964434>.
                        c~sprps = ' ' AND
*Begin of <RD1K964434>.
*                        c~endda = '99991231' .
                        c~endda GE l_date .
**----------End  of change 27.06.2016 16:53:39 -----------------

    SORT ist_data BY endda DESCENDING.
    READ TABLE ist_data INTO wa_data INDEX 1.

    IF ( wa_data-disc_cd = '13' OR wa_data-disc_cd = '36' ).
      CLEAR p_zmm_tms_tc_tc_member3_s.
      MESSAGE e206(zmm_oth) WITH text-204.
    ENDIF.
  ENDIF.
ENDFORM.                    " CHECK_INDENTOR
*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_TMS  text
*----------------------------------------------------------------------*
FORM chng_doc_tc  USING    p_submi_tc  p_wa_zmm_tms_tco p_wa_zmm_tms_tcn.
  DATA : wa_zmm_tms_o_tc TYPE  zmm_tms,
         wa_zmm_tms_n_tc TYPE  zmm_tms.

  DATA : ist_chngind_tc TYPE TABLE OF cdtxt WITH HEADER LINE.
  DATA : l_objectid_tc TYPE cdhdr-objectid.


  l_objectid_tc =  p_submi_tc.

  MOVE-CORRESPONDING p_wa_zmm_tms_tcn TO  wa_zmm_tms_n_tc .
  wa_zmm_tms_n_tc-rel_stat = v_rel_new.

  MOVE-CORRESPONDING p_wa_zmm_tms_tco TO wa_zmm_tms_o_tc .
  wa_zmm_tms_o_tc-rel_stat = v_rel_old.


  CALL FUNCTION 'ZMM_TC_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid_tc
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZMM_TC       = ' '
      n_zmm_tms               = wa_zmm_tms_n_tc
      o_zmm_tms               = wa_zmm_tms_o_tc
      upd_zmm_tms             = 'U'
    TABLES
      icdtxt_zmm_tc           = ist_chngind_tc.


ENDFORM.                    " CHNG_DOC_TC
*&---------------------------------------------------------------------*
*&      Form  CHNG_DOC_TENDER_PR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZMM_TMS_SUBMI  text
*      -->P_WA_TENDER_OLD  text
*      -->P_WA_TENDER_NEW  text
*----------------------------------------------------------------------*
FORM chng_doc_tender_pr  USING    p_submi_pr
                                  p_wa_tender_old
                                  p_wa_tender_new.
  DATA : wa_tender_o TYPE  zmm_pur_tender_d,
         wa_tender_n TYPE  zmm_pur_tender_d.

  DATA : ist_chngind_pr TYPE TABLE OF cdtxt WITH HEADER LINE.
  DATA : l_objectid_pr TYPE cdhdr-objectid.


  l_objectid_pr =  p_submi_pr.

  MOVE-CORRESPONDING p_wa_tender_new TO  wa_tender_n .
  MOVE-CORRESPONDING p_wa_tender_old TO wa_tender_o.


  CALL FUNCTION 'ZMM_TEND_BN_WRITE_DOCUMENT'
    EXPORTING
      objectid                = l_objectid_pr
      tcode                   = sy-tcode
      utime                   = sy-uzeit
      udate                   = sy-datum
      username                = sy-uname
*     PLANNED_CHANGE_NUMBER   = ' '
      object_change_indicator = 'U'
*     PLANNED_OR_REAL_CHANGES = ' '
*     NO_CHANGE_POINTERS      = ' '
*     UPD_ICDTXT_ZMM_TEND_BN  = ' '
      n_zmm_pur_tender_d      = wa_tender_n
      o_zmm_pur_tender_d      = wa_tender_o
      upd_zmm_pur_tender_d    = 'U'
    TABLES
      icdtxt_zmm_tend_bn      = ist_chngind_pr.
ENDFORM.                    " CHNG_DOC_TENDER_PR
*&---------------------------------------------------------------------*
*&      Form  GET_NAME_DESIGN_CPA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ZMM_TMS_TC_CPA  text
*      <--P_WA_CPA_DTL_ENAME  text
*      <--P_WA_CPA_DTL_DESIG_TEXT  text
*----------------------------------------------------------------------*
FORM get_name_design_cpa  USING    p_pernr
                          CHANGING p_ename
                                   p_design.


  DATA : l_designo TYPE pa9930-designo,
         l_r_p_cd  TYPE pa9930-r_p_cd,
         l_version TYPE pa9930-version.

**----------Start of change 27.06.2016 16:54:34 -------------------
*  SELECT SINGLE ENAME FROM PA0001 INTO P_ENAME
*         WHERE PERNR = P_PERNR AND
*               ENDDA = '99991231'.

  SELECT ENAME FROM ZPA0001 INTO P_ENAME UP TO 1 ROWS
 WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:54:34 -----------------

  IF sy-subrc NE 0.
    IF p_pernr+0(1) <> 'C'.
      """"""""""""""""""""""""""""""""""""""""""""""


      IF  zmm_tms_tc-cpa = 'EPC'.

        """""""""""""
        "commented by lipsy  22.05.2015 RD1K997320
* if zmm_tms_general-epc_typ = 'E' or zmm_tms_pb-epc_typ_pb = 'E'.
* else.
* message 'Please Enter valid CPF no' type 'E'.
* endif.

        "end of comment by lipsy  22.05.2015 RD1K997320
      ELSE.

        """"""""""""""""""""""""""""""""""""""
        "added by  lipsy on 22.05.2015 RD1K997320

        """""""""""""""""""""""""""""""""""""""""""""""
        "commented by lipsy on 27.05.2015 RD1K997318

*   if  p_pernr = '00000000'.
        "end of comment by lipsy on 27.05.2015 RD1K997318
        """"""""""""""""""""""""""""""""""""""""""

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 27.05.2015 RD1K997318

        IF  p_pernr+0(1) = '0'.
          "end of addition by lipsy on 27.05.2015 RD1K997318

          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
        ELSE.

          "end of addition by lipsy on 22.05.2015 RD1K997320
          """""""""""""""""""""""""""""""""""""""""""""""""""""""
          MESSAGE e035(zmmpurtdr).

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "added by  lipsy on 22.05.2015 RD1K997320

        ENDIF.
        "end of addition by lipsy on 22.05.2015 RD1K997320
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      ENDIF.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""



  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""

**----------Start of change 27.06.2016 16:56:20 -------------------
*  SELECT SINGLE DESIGNO R_P_CD VERSION FROM PA9930
*         INTO (L_DESIGNO,L_R_P_CD,L_VERSION)
*            WHERE PERNR = P_PERNR AND
*                  ENDDA = '99991231'.

  SELECT DESIGNO R_P_CD VERSION FROM ZPA9930
 INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = P_PERNR AND ENDDA = '99991231'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
**----------End  of change 27.06.2016 16:56:20 -----------------
  IF sy-subrc = 0.

    SELECT SINGLE desig_text FROM zdesignation_rev
         INTO p_design
            WHERE desig_code = l_designo AND
                  r_p_cd     = l_r_p_cd AND
                  version    = l_version.
  ENDIF.
ENDFORM.                    " GET_NAME_DESIGN_CPA
