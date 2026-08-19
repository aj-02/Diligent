*--- MAIN PROGRAM: MZMMTMSI01 ---*
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
*&      Module  INIT_GLOBAL_VAR  INPUT
*&---------------------------------------------------------------------*
* To initialize global variables
*----------------------------------------------------------------------*
MODULE init_global_var INPUT.

  CLEAR : zmm_pur_tender_d_st,
          wa_zmm_tms.

  CLEAR : zmm_tms,
          zmm_tms_general,
          zmm_tms_tc,
          zmm_tms_tb,
          zmm_tms_pb,
          zmm_tms_epc.

  CLEAR : wa_cpa_dtl,
          wa_indentor_dtl,
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
" RD1K994950
           wa_icmm_dtl,
           wa_l1_dtl,

"END OF ADDITION BY LIPSY ON 27.10.2014 FOR GETTING  NAME & DESIGNATION FOR  NEW FIELDS IC MM/L2/L3 , L1
" RD1K994950
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          wa_tc_mem1,
          wa_tc_mem2,
          wa_tc_mem3,
          wa_tc_mem4.

  CLEAR : ist_lines,
          ist_zmm_tmst,
          wa_zmm_tmst.

  CLEAR : g_option,
          g_dmode,
          g_chg_flg,
          g_dmode_spfc,
          g_chg_spfc.

*+001 : Start
  CLEAR : g_dmode_epc,
          g_chg_epc.
*+001 : End

  CLEAR : g_tndr_proc,
          g_tndr_typ.

  tms_ctrl-activetab = 'TDTL'.
  g_dynnr = '0300'.

*Set default vaule of Radio Button for TMS : General sub-screen
  g_reg = 'X'.
  CLEAR g_spfc.

*Set default value for shortlisted bidders for PBO
  g_pbo_bidrs = 'X'.

*18.10.2012 : Start
  g_loi_dt1 = text-002.
  g_loi_dt2 = text-003.
  g_loi_dt3 = text-004.
*18.10.2012 : End

*+007 : Start
*Pre bid conference status
  zmm_tms_tc-pbc_stat =  'N'.
*Reopening of sale required
  zmm_tms_tc-reo_tsal_stat = 'N'.
*+007 : End
ENDMODULE.                 " INIT_GLOBAL_VAR  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
* To call screen 200.
* Lock the record(s) in case of change/delete before calling screen 0200
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  g_ok_code = ok_code.
  CLEAR ok_code.

*+002 : Start
  PERFORM chk_authority USING sy-uname
                              g_ok_code.
*+002 : End

  CASE g_ok_code.

    WHEN 'NEW'.
      g_tcode = 'ZMMTDR1'.

      CALL SCREEN '0200'.

    WHEN 'CHNG'.

      g_tcode = 'ZMMTDR2'.

      CALL SCREEN '0150'.

    WHEN 'DISP'.

      g_tcode = 'ZMMTDR3'.

      g_dmode = 'X'.
      g_dmode_spfc = 'X'.

      g_dmode_epc = 'X'.                                    "+001

      CALL SCREEN '0150'.

*+002 : Start
    WHEN 'APRV'.

      g_tcode = 'ZMMTDR3'.

      g_dmode = 'X'.
      g_dmode_spfc = 'X'.

      g_dmode_epc = 'X'.

      CALL SCREEN '0150'.
*+002 : End

*Plan to Procure Reports - PRs ->RFQs -> PO/RC
    WHEN 'PTPR'.
      SUBMIT zmm_srv_ptp_new VIA SELECTION-SCREEN AND RETURN.

    WHEN 'HELP'.

      PERFORM disp_process_guide USING 'TMSHLP'.

    WHEN 'REP'.

      SUBMIT zmm_tms_status VIA SELECTION-SCREEN AND RETURN.
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

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.

    WHEN 'DISP'.

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.

*+002 : Start
    WHEN 'APRV'.

      PERFORM check_validation_150 USING zmm_pur_tender_d_st-submi.

      PERFORM get_editor_data USING zmm_pur_tender_d_st-submi.
*+002 : End
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

*   WHEN 'CHNG'.                                            "-002
    WHEN 'CHNG' OR 'APRV'.                                  "+002

      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.

        CALL METHOD cl_binary_relation=>refresh_links.

*Lock record
        PERFORM lock_record USING zmm_pur_tender_d_st-submi.

        CALL SCREEN '0200'.

      ENDIF.

    WHEN 'DISP'.

      CALL METHOD cl_binary_relation=>refresh_links.

      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.

        CALL SCREEN '0200'.

      ENDIF.

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
          CLEAR : g_ans,g_txt.

          g_txt  = text-001.
          g_disp = 'X'.

          PERFORM confirm_input.
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
          CLEAR : g_ans,g_txt.

          g_txt = text-001.
          g_disp = 'X'.

          PERFORM confirm_input.
          IF g_ans = '2'.
            CLEAR g_ans.
            CLEAR ok_code.
            CLEAR save_ok.
            PERFORM unlock_record USING zmm_pur_tender_d_st-submi.
            LEAVE TO SCREEN 100.
          ELSEIF g_ans = '1'.
            CLEAR g_ans.
            CLEAR ok_code.
            ok_code = 'SAVE'.
            """""""""""""""""""""""""""""""""""""""""
            "added by lipsy on 8.05.2015 for changing release status on save RD1K997136
            UPDATE zmm_tms SET
            rel_stat = ''
            WHERE submi = zmm_pur_tender_d_st-submi.
            "end of addition by lipsy on 8.05.2015 for changing release status on save RD1K997136

            """"""""""""""""""""""""""""""""""""""""""""""""""""""


          ENDIF.

      ENDCASE.

*+002 : Start
    WHEN 'APRV'.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          CLEAR ok_code.
          CLEAR save_ok.
          PERFORM unlock_record USING zmm_pur_tender_d_st-submi.
          LEAVE TO SCREEN 100.
      ENDCASE.
*+002 : End

    WHEN 'DISP'.                                            "-002
      IF sy-tcode = 'ZMMTMSDISP'.
*        LEAVE TO SCREEN 0.
        LEAVE PROGRAM.
      ENDIF.
      CASE save_ok.
        WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
          LEAVE TO SCREEN 100.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " CANCEL_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*  To perform operations like save/delete record etc by pressing the
*  respective button at application tool bar & Tabstrip.
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE g_ok_code.


    WHEN 'NEW'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.

*+007 : Start
          CLEAR : g_chk.

          PERFORM chk_required_input CHANGING g_chk.

          IF g_chk = 'X'.

**            tms_ctrl-activetab = 'TGEN'.
**            g_dynnr = '0400'.
**            CLEAR save_ok.
            tms_ctrl-activetab = 'TTC'.
            g_dynnr = '0500'.
            CLEAR save_ok.
          ELSE.
*+007 : End
            PERFORM save_data.
            CLEAR save_ok.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ENDIF.                                 "+007

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

*        WHEN 'MJOR'.
*          g_mjor = save_ok.
*          PERFORM major_highlight_text.
*          CLEAR save_ok.
*
*        WHEN 'DOPER'.
*          g_doper = save_ok.
*          PERFORM days_oper_text.
*          CLEAR save_ok.
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

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'ATCH'.
          PERFORM attach_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

*        WHEN 'DOPER'.
*          g_doper = save_ok.
*          PERFORM days_oper_text.
*          CLEAR save_ok.

      ENDCASE.

*+002 : Start
    WHEN 'APRV'.   " SY-UCOMM is removed  due to automatic relase
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'SAVE'.
          PERFORM upd_rel_status.
          CLEAR save_ok.

          IF ist_mesg[] IS INITIAL.
            CLEAR g_ok_code.
            LEAVE TO SCREEN 100.
          ENDIF.

        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'ATCH'.
          PERFORM attach_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

      ENDCASE.
*+002 : End

    WHEN 'DISP'.
      save_ok = ok_code.
      CLEAR ok_code.

      CASE save_ok.
        WHEN 'TDTL'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0300'.
          CLEAR save_ok.

        WHEN 'TGEN'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0400'.
          CLEAR save_ok.

        WHEN 'TTC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0500'.
          CLEAR save_ok.

        WHEN 'TTB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0600'.
          CLEAR save_ok.

        WHEN 'TPB'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0700'.
          CLEAR save_ok.

        WHEN 'TEPC'.
          tms_ctrl-activetab = save_ok.
          g_dynnr = '0800'.
          CLEAR save_ok.

        WHEN 'LIST'.
          PERFORM list_files.
          CLEAR save_ok.

*+007 : Display PR Receipt Date log :Start
        WHEN 'HIST'.
          SUBMIT zmm_tms_pr_rcpt_dt_log
                   WITH p_submi = zmm_pur_tender_d_st-submi
                   AND RETURN.

*+007 : End

*        WHEN 'DOPER'.
*          PERFORM days_oper_text.
*          CLEAR save_ok.

      ENDCASE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

*  g_sav_ok_100 = g_ok_100.
*  CLEAR g_ok_100.
*  DATA l_ttext(10).
*
*  CASE g_sav_ok_100.
*    WHEN 'BACK'.
*      PERFORM confirm_step.
*    WHEN 'CANC'.
*      PERFORM confirm_step.
*    WHEN 'BU'.
**-----Validation on Start Date of selling tender &
**                   Last Date of selling tender.
*      PERFORM validate_date_req.
**-----Converts the date and time fields into time stamp format
*      PERFORM oif_conv_date_time_ts.
**-----Save the Data in DB Table
*      PERFORM prepare_saving ON COMMIT.
*      COMMIT WORK.
*      IF NOT zmm_pur_tender_d_st-submi IS INITIAL.
*        CONCATENATE tstct-ttext+15(6) 'd' INTO l_ttext.
*        MESSAGE i023(zmmpurtdr) WITH zmm_pur_tender_d_st-submi l_ttext.
*        PERFORM clear_para.
*      ENDIF.
*
*  ENDCASE.

* IF sy-ucomm = 'MORE'.                          "-006
  IF g_ok_code_300 = 'MORE' AND
     NOT zmm_pur_tender_d_st-banfn IS INITIAL.   "+006

    REFRESH it_sval.
    CLEAR   it_sval.

    PERFORM fill_sval.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*       check_existence = 'X'
*       popup_title     = text-003 "-006
        popup_title     = text-019 "+006
      IMPORTING
        returncode      = wrk_retcode
      TABLES
        fields          = it_sval
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.

*+006 : Start
*    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

    LOOP AT it_sval.
*Purchase requisition 2
      IF it_sval-fieldname = 'BANFN2' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn2.

      ENDIF.

*Purchase requisition 3
      IF it_sval-fieldname = 'BANFN3' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn3.

      ENDIF.

*Purchase requisition 4
      IF it_sval-fieldname = 'BANFN4' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn4.

      ENDIF.

*Purchase requisition 5
      IF it_sval-fieldname = 'BANFN5' AND
         NOT it_sval-value IS INITIAL.

        MOVE it_sval-value TO zmm_pur_tender_d_st-banfn5.

      ENDIF.
    ENDLOOP.

*    ENDIF.
*+006 : End


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """ADDED BY LIPSY ON 4.11.2014  FOR  total pr value
                                                            "RD1K994950




    """"""""""get all prs
    REFRESH:ist_eban[].


    CLEAR: wa_eban.

*PR 1
    IF NOT  zmm_pur_tender_d_st-banfn IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.
*PR 2
    IF NOT  zmm_pur_tender_d_st-banfn2 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn2 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 3
    IF NOT  zmm_pur_tender_d_st-banfn3 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn3 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 4
    IF NOT  zmm_pur_tender_d_st-banfn4 IS INITIAL.
      MOVE zmm_pur_tender_d_st-banfn4 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

*PR 5
    IF NOT  zmm_pur_tender_d_st-banfn5 IS INITIAL.
      MOVE  zmm_pur_tender_d_st-banfn5 TO wa_eban-banfn.
      APPEND wa_eban TO ist_eban.
    ENDIF.

    CLEAR: wa_eban_all.


    SORT ist_eban BY banfn.
    DELETE ADJACENT DUPLICATES FROM ist_eban.



    """""""""get all items
    REFRESH: ist_eban_t[].
    IF ist_eban[] IS NOT INITIAL.
      SELECT banfn bnfpo statu txz01 menge preis waers werks badat FROM eban
        INTO CORRESPONDING FIELDS OF TABLE ist_eban_t
        FOR ALL ENTRIES IN  ist_eban[]
        WHERE banfn = ist_eban-banfn.
    ENDIF.

*     bsart ne 'SWO'   and
*               statu =  'N'     and
*               loekz ne 'X'     and
*               frgkz =  'B'     and
*               erdat ge l_erdat.


    CLEAR:wa_eban,l_fval .

    LOOP AT ist_eban INTO wa_eban.

      CLEAR : wa_eban_t,l_rate_type,l_from_curr,
      l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp,v_pr_val.

      LOOP AT ist_eban_t INTO wa_eban_t WHERE banfn = wa_eban-banfn.
        """"""""""""""""""""""""""""""
        "add by lipsy on 8.07.2015 RD1K997763
        IF wa_eban_t-loekz = ''.
          "end of addition by lipsy on 8.07.2015 RD1K997763
          """""""""""""""""""""""""""""
          IF wa_eban_t-waers NE 'INR'.

            CLEAR : wa_erate,
                    l_rval.

            MOVE 'M'             TO l_rate_type.
            MOVE wa_eban_t-waers TO l_from_curr.
            MOVE 'INR'           TO l_to_curr.
            MOVE wa_eban_t-badat TO l_trans_dt.

            CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
              EXPORTING
                rate_type  = l_rate_type
                from_curr  = l_from_curr
                to_currncy = l_to_curr
                date       = l_trans_dt
              IMPORTING
                exch_rate  = wa_erate.

            CALL FUNCTION 'ROUND'
              EXPORTING
                decimals      = 2
                input         = wa_erate-exch_rate
                sign          = '+'
              IMPORTING
                output        = l_rval
              EXCEPTIONS
                input_invalid = 1
                overflow      = 2
                type_invalid  = 3
                OTHERS        = 4.

            IF sy-subrc <> 0.
*            message id sy-msgid type 'I' number sy-msgno
*                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.

            l_temp  =  wa_eban_t-preis * wa_eban_t-menge .
            l_rlwrt =  l_temp * l_rval.
            l_erate =  l_rlwrt.

            l_fval = l_fval + l_erate.

          ELSE.

            l_temp = wa_eban_t-preis * wa_eban_t-menge.

            l_fval = l_fval + l_temp.

          ENDIF.



          CLEAR : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp.

          """""""""
          "add by lipsy on 8.07.2015 RD1K997763
        ENDIF.
        "end of addition by lipsy on 8.07.2015 RD1K997763
        """"""""""""
      ENDLOOP.


      CLEAR:wa_eban.
    ENDLOOP.

    MOVE l_fval TO v_pr_val.




    """end of ADDition BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""









    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""






  ENDIF.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  PERFORM confirm_step.
  IF g_action EQ '1'.
    CALL FUNCTION 'DEQUEUE_EZ_SUBMI'
      EXPORTING
        mode_zmm_pur_tender_d = 'E'
        mandt                 = sy-mandt
        submi                 = zmm_pur_tender_d_st-submi.
  ENDIF.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_data INPUT.
*Get the Purchasing group Description

  CALL FUNCTION 'MEX_READ_T024'
    EXPORTING
      im_ekgrp  = zmm_pur_tender_d_st-ekgrp
    IMPORTING
      ex_t024   = t024
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*Get Document type Description
  SELECT SINGLE * FROM zmm_pur_trtyp WHERE
                           bsart = zmm_pur_tender_d_st-bsart.
  IF sy-subrc NE 0.
    MESSAGE e814(f5) WITH zmm_pur_tender_d_st-bsart.
  ENDIF.

  zmm_pur_tender_d_st-bstyp = zmm_pur_trtyp-bstyp.

  l1_date = sy-datum + 7.

  IF zmm_pur_tender_d_st-tdrdt >= sy-datum AND
      zmm_pur_tender_d_st-tdrdt <= l1_date.
  ELSE.

*   IF sy-tcode = 'ZMMTDR1'.
    IF g_tcode = 'ZMMTDR1'.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """commenteD BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
*      CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*        EXPORTING
*          popup_title  = 'Invalid Tender Date'
*          is_error     = 'X'
*          message_text = 'Tender Date should not be greater than 7 Days from Todays Date'
**         START_COLUMN = 25
**         START_ROW    =                                                                                         6
*        .
      """end of comment BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """addED BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950



      MESSAGE e157(zmm_oth).

      """end of addition BY LIPSY ON 27.10.2014  FOR  error message
                                                            "RD1K994950



      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""





    ENDIF.

  ENDIF.

* IF sy-tcode = 'ZMMTDR1'.
  IF g_tcode = 'ZMMTDR1'.

    IF NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.
      IF zmm_pur_tender_d_st-tdrdt > zmm_pur_tender_d_st-st_sel_dt.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*        CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
*          EXPORTING
*            popup_title  = 'Invalid Tender Start Date'
*            is_error     = 'X'
*            message_text = 'Tender sale Start Date should be greater than or equal to Tender Date'.
**         START_COLUMN       = 25
**         START_ROW          = 6
        message: 'Tender sale Start Date should be greater than or equal to Tender Date' type 'W'.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026        .
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " validate_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_SUBMI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_submi INPUT.

* CHECK NOT sy-tcode = 'ZMMTDR1'.
  CHECK NOT g_tcode = 'ZMMTDR1'.
  CHECK g_option IS INITIAL.
  SELECT SINGLE * FROM zmm_pur_tender_d INTO zmm_pur_tender_d_st WHERE
                  submi = zmm_pur_tender_d_st-submi.
  IF sy-subrc NE 0.
    MESSAGE e019(06) WITH zmm_pur_tender_d_st-submi.
  ENDIF.
  g_option = 'X'.
*----------Lock and unlock functions
  CALL FUNCTION 'ENQUEUE_EZ_SUBMI'
    EXPORTING
      mode_zmm_pur_tender_d = 'E'
      mandt                 = sy-mandt
      submi                 = zmm_pur_tender_d_st-submi
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " READ_SUBMI  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lstdt  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lstdt INPUT.
*+008 : Start
  IF g_ok_code NE 'NEW'.

    IF zmm_pur_tender_d_st-bsart+0(2) EQ 'MO'  OR
       zmm_pur_tender_d_st-bsart      EQ 'SGO' OR
       zmm_pur_tender_d_st-bsart EQ 'SOT'      OR
       zmm_pur_tender_d_st-bsart EQ 'MRCO'.


      """"""""""""""""""""""""""""""""""""""""""""""""""""""""

      """""""""""""""""""""""""""""""""""""""""""""""""
      "comment by lipsy on 5.11.2014 FOR new validations in RD1K994950
*      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL OR
*         zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.
*
*        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-ST_SEL_DT'.
*
*        MESSAGE e008(zmmpurtdr).
*
*      ENDIF.

      "end of comment by lipsy on 5.11.2014 FOR new validations in RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "add by lipsy on 5.11.2014 FOR new validations in RD1K994950


      IF zmm_pur_tender_d_st-st_sel_dt IS INITIAL
      AND  zmm_pur_tender_d_st-sch_st_sel_dt < sy-datum.
        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-ST_SEL_DT'.
        PERFORM err_msg USING '008'.
      ENDIF.




      IF  zmm_pur_tender_d_st-lt_sel_dt IS INITIAL
     AND zmm_pur_tender_d_st-sch_lt_sel_dt < sy-datum.
        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-LT_SEL_DT'.
        PERFORM err_msg USING '038'.

      ENDIF.




      "end of addition by lipsy on 5.11.2014 FOR new validations in RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""


    ENDIF.

  ENDIF.
*+008 : End

  CHECK NOT zmm_pur_tender_d_st-lt_sel_dt IS INITIAL.

  IF zmm_pur_tender_d_st-lt_sel_dt <= zmm_pur_tender_d_st-st_sel_dt.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
    IF g_ok_code = 'DISP'.

    ELSE.

      "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      MESSAGE e010(zmmpurtdr).
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """ADDED BY LIPSY ON 30.10.2014  FOR  removing error in display mode RD1K994950
    ENDIF.

    "END OF ADDITION BY LIPSY ON 30.10.2014 FOR removing error in display mode RD1K994950

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDIF.

ENDMODULE.                 " validate_lstdt  INPUT
*&---------------------------------------------------------------------*
*&      Module  read_tdrsts  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_tdrsts INPUT.

  DATA l_value LIKE dd07l-domvalue_l.

  MOVE zmm_pur_tender_d_st-tdrsts TO l_value.

  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      domname  = 'ZTDRSTS'
      value    = l_value
      langu    = sy-langu
    IMPORTING
      dd07v_wa = dd07v.

ENDMODULE.                 " read_tdrsts  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES
*----------------------------------------------------------------------*
MODULE get_editor_data INPUT.
  PERFORM get_editor USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA_SPFC  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES_SPFC
*----------------------------------------------------------------------*
MODULE get_editor_data_spfc INPUT.
  PERFORM get_editor_spfc USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA_SPFC  INPUT

*+001 : Start
*&---------------------------------------------------------------------*
*&      Module  GET_EDITOR_DATA_EPC  INPUT
*&---------------------------------------------------------------------*
*  To Populate Editor Data into Internal table - IST_LINES_EPC
*----------------------------------------------------------------------*
MODULE get_editor_data_epc INPUT.
  PERFORM get_editor_epc USING 'X'.
ENDMODULE.                 " GET_EDITOR_DATA_EPC  INPUT
*+001 : End

*&---------------------------------------------------------------------*
*&      Module  FILL_NAME_DESIGN_0500  INPUT
*&---------------------------------------------------------------------*
* To get name & desgination of tender committee / indentor etc.
*----------------------------------------------------------------------*
MODULE fill_name_design_0500 INPUT.

  PERFORM get_name_desgn USING zmm_tms_tc.

ENDMODULE.                 " FILL_NAME_DESIGN_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0500  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date
*----------------------------------------------------------------------*
MODULE chk_dates_0500 INPUT.

*Constitution of TC( Ist TC Notice)
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_form_sch_dt
                                 zmm_tms_tc-tc_form_act_dt
                                 'ZMM_TMS_TC-TC_FORM_SCH_DT'
                                 'ZMM_TMS_TC-TC_FORM_ACT_DT'.

*Date of TC meeting for BEC & Major Qualifying Criteria
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_met_sch_dt
                                 zmm_tms_tc-tc_met_act_dt
                                 'ZMM_TMS_TC-TC_MET_SCH_DT'
                                 'ZMM_TMS_TC-TC_MET_ACT_DT'.

*BEC formulation TC approval
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_aprv_sch_dt
                                 zmm_tms_tc-tc_aprv_act_dt
                                 'ZMM_TMS_TC-TC_APRV_SCH_DT'
                                 'ZMM_TMS_TC-TC_APRV_ACT_DT'.

*Date of approval of TC meeting - Prebid confer. issues
  PERFORM chk_sch_act_date USING zmm_tms_tc-tc_met_pb_sch_dt
                                 zmm_tms_tc-tc_met_pb_act_dt
                                 'ZMM_TMS_TC-TC_MET_PB_SCH_DT'
                                 'ZMM_TMS_TC-TC_MET_PB_ACT_DT'.

*Date of Issue of amendments after PBC
  PERFORM chk_sch_act_date USING zmm_tms_tc-amd_issu_sch_dt
                                 zmm_tms_tc-amd_issu_act_dt
                                 'ZMM_TMS_TC-AMD_ISSU_SCH_DT'
                                 'ZMM_TMS_TC-AMD_ISSU_ACT_DT'.

**Re-Opening of tender sale
*  PERFORM chk_sch_act_date USING zmm_tms_tc-reo_tsal_sch_dt
*                                 zmm_tms_tc-reo_tsal_act_dt
*                                 'ZMM_TMS_TC-REO_TSAL_SCH_DT'
*                                 'ZMM_TMS_TC-REO_TSAL_ACT_DT'.
**Re-Closing of tender sale
*  PERFORM chk_sch_act_date USING zmm_tms_tc-rec_tsal_sch_dt
*                                 zmm_tms_tc-rec_tsal_act_dt
*                                 'ZMM_TMS_TC-REC_TSAL_SCH_DT'
*                                 'ZMM_TMS_TC-REC_TSAL_ACT_DT'.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 4.11.2014  FOR  comparing tc meeting and tc approval date RD1K994950

  IF zmm_tms_tc-tc_met_sch_dt  GT  zmm_tms_tc-tc_aprv_sch_dt.

    MESSAGE e158(zmm_oth).

  ENDIF.

  """end of ADDition BY LIPSY ON 4.11.2014  FOR   comparing tc meeting and tc approval date RD1K994950
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

ENDMODULE.                 " CHK_DATES_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0600  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0600
*----------------------------------------------------------------------*
MODULE chk_dates_0600 INPUT.

* TBO
  PERFORM chk_sch_act_date USING zmm_tms_tb-tend_op_sch_dt
                                 zmm_tms_tb-tend_op_act_dt
                                 'ZMM_TMS_TB-TEND_OP_SCH_DT'
                                 'ZMM_TMS_TB-TEND_OP_ACT_DT'.

* CS preparation
  PERFORM chk_sch_act_date USING zmm_tms_tb-cs_prep_sch_dt
                                 zmm_tms_tb-cs_prep_act_dt
                                 'ZMM_TMS_TB-CS_PREP_SCH_DT'
                                 'ZMM_TMS_TB-CS_PREP_ACT_DT'.

* CS vetting
  PERFORM chk_sch_act_date USING zmm_tms_tb-cs_vet_sch_dt
                                 zmm_tms_tb-cs_vet_act_dt
                                 'ZMM_TMS_TB-CS_VET_SCH_DT'
                                 'ZMM_TMS_TB-CS_VET_ACT_DT'.

* Bid forwarding to indentor
  PERFORM chk_sch_act_date USING zmm_tms_tb-bid_fwd_sch_dt
                                 zmm_tms_tb-bid_fwd_act_dt
                                 'ZMM_TMS_TB-BID_FWD_SCH_DT'
                                 'ZMM_TMS_TB-BID_FWD_ACT_DT'.

* Date of receipt of technical comments
  PERFORM chk_sch_act_date USING zmm_tms_tb-tc_rcpt_sch_dt
                                 zmm_tms_tb-tc_rcpt_act_dt
                                 'ZMM_TMS_TB-TC_RCPT_SCH_DT'
                                 'ZMM_TMS_TB-TC_RCPT_ACT_DT'.

* TCs for techno-commercial bid evaluation
  PERFORM chk_sch_act_date USING zmm_tms_tb-tbid_eval_sch_dt
                                 zmm_tms_tb-tbid_eval_act_dt
                                 'ZMM_TMS_TB-TBID_EVAL_SCH_DT'
                                 'ZMM_TMS_TB-TBID_EVAL_ACT_DT'.
* Clarification sought-1st round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif1_sch_dt
                                 zmm_tms_tb-clarif1_act_dt
                                 'ZMM_TMS_TB-CLARIF1_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF1_ACT_DT'.

* Last date of clarification-1st round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif1_l_sch_dt
                                 zmm_tms_tb-clarif1_l_act_dt
                                 'ZMM_TMS_TB-CLARIF1_L_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF1_L_ACT_DT'.

* Clarification sought-last round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif2_sch_dt
                                 zmm_tms_tb-clarif2_act_dt
                                 'ZMM_TMS_TB-CLARIF2_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF2_ACT_DT'.

* Last date of clarification-last round
  PERFORM chk_sch_act_date USING zmm_tms_tb-clarif2_l_sch_dt
                                 zmm_tms_tb-clarif2_l_act_dt
                                 'ZMM_TMS_TB-CLARIF2_L_SCH_DT'
                                 'ZMM_TMS_TB-CLARIF2_L_ACT_DT'.

* Date of Vetting of unpriced commercial statement
  PERFORM chk_sch_act_date USING zmm_tms_tb-ucs_vett_sch_dt
                                 zmm_tms_tb-ucs_vett_act_dt
                                 'ZMM_TMS_TB-UCS_VETT_SCH_DT'
                                 'ZMM_TMS_TB-UCS_VETT_ACT_DT'.

* Date of receipt of Final tech comments
  PERFORM chk_sch_act_date USING zmm_tms_tb-ftc_rcpt_sch_dt
                                 zmm_tms_tb-ftc_rcpt_act_dt
                                 'ZMM_TMS_TB-FTC_RCPT_SCH_DT'
                                 'ZMM_TMS_TB-FTC_RCPT_ACT_DT'.

* Date of TC meeting for shortlisting of bids
  PERFORM chk_sch_act_date USING zmm_tms_tb-sb_tc_mt_sch_dt
                                 zmm_tms_tb-sb_tc_mt_act_dt
                                 'ZMM_TMS_TB-SB_TC_MT_SCH_DT'
                                 'ZMM_TMS_TB-SB_TC_MT_ACT_DT'.

* Date of approval of TC meeting for shortlisting of bids
  PERFORM chk_sch_act_date USING zmm_tms_tb-sb_tc_apv_sch_dt
                                 zmm_tms_tb-sb_tc_apv_act_dt
                                 'ZMM_TMS_TB-SB_TC_APV_SCH_DT'
                                 'ZMM_TMS_TB-SB_TC_APV_ACT_DT'.

ENDMODULE.                 " CHK_DATES_0600  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0700  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0700
*----------------------------------------------------------------------*
MODULE chk_dates_0700 INPUT.

* Opening of price bids
  PERFORM chk_sch_act_date USING zmm_tms_pb-pr_bid_op_sch_dt
                                 zmm_tms_pb-pr_bid_op_act_dt
                                 'ZMM_TMS_PB-PR_BID_OP_SCH_DT'
                                 'ZMM_TMS_PB-PR_BID_OP_ACT_DT'.
* First TC date
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc1_sch_dt
                                 zmm_tms_pb-tc1_act_dt
                                 'ZMM_TMS_PB-TC1_SCH_DT'
                                 'ZMM_TMS_PB-TC1_ACT_DT'.

* Date of approval of first TC
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc1_aprv_sch_dt
                                 zmm_tms_pb-tc1_aprv_act_dt
                                 'ZMM_TMS_PB-TC1_APRV_SCH_DT'
                                 'ZMM_TMS_PB-TC1_APRV_ACT_DT'.

* Date of Final TC for award
  PERFORM chk_sch_act_date USING zmm_tms_pb-tc_awrd_sch_dt
                                 zmm_tms_pb-tc_awrd_act_dt
                                 'ZMM_TMS_PB-TC_AWRD_SCH_DT'
                                 'ZMM_TMS_PB-TC_AWRD_ACT_DT'.

* Approval of Award
  PERFORM chk_sch_act_date USING zmm_tms_pb-aprv_awrd_sch_dt
                                 zmm_tms_pb-aprv_awrd_act_dt
                                 'ZMM_TMS_PB-APRV_AWRD_SCH_DT'
                                 'ZMM_TMS_PB-APRV_AWRD_ACT_DT'.
* Date of LOI - First
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_1_sch_dt
                                 zmm_tms_pb-loi_1_act_dt
                                 'ZMM_TMS_PB-LOI_1_SCH_DT'
                                 'ZMM_TMS_PB-LOI_1_ACT_DT'.

* Date of LOI - Second / Last
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_2_sch_dt
                                 zmm_tms_pb-loi_2_act_dt
                                 'ZMM_TMS_PB-LOI_2_SCH_DT'
                                 'ZMM_TMS_PB-LOI_2_ACT_DT'.

* Date of LOI - Third
  PERFORM chk_sch_act_date USING zmm_tms_pb-loi_3_sch_dt
                                 zmm_tms_pb-loi_3_act_dt
                                 'ZMM_TMS_PB-LOI_3_SCH_DT'
                                 'ZMM_TMS_PB-LOI_3_ACT_DT'.
* Date of issue of PO / Contract
  PERFORM chk_sch_act_date USING zmm_tms_pb-po_issue_sch_dt
                                 zmm_tms_pb-po_issue_act_dt
                                 'ZMM_TMS_PB-PO_ISSUE_SCH_DT'
                                 'ZMM_TMS_PB-PO_ISSUE_ACT_DT'.

ENDMODULE.                 " CHK_DATES_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DATES_0800  INPUT
*&---------------------------------------------------------------------*
* To check Schdule / Actual date : Sub Screen 0800
*----------------------------------------------------------------------*
MODULE chk_dates_0800 INPUT.

*18.10.2012 - Commented : Start
** Date of TC for EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-tc_epc_sch_dt
*                                 zmm_tms_epc-tc_epc_act_dt
*                                 'ZMM_TMS_EPC-TC_EPC_SCH_DT'
*                                 'ZMM_TMS_EPC-TC_EPC_ACT_DT'.
*
** Date of endorsement of TC minutes for EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-tc_endors_sch_dt
*                                 zmm_tms_epc-tc_endors_act_dt
*                                 'ZMM_TMS_EPC-TC_ENDORS_SCH_DT'
*                                 'ZMM_TMS_EPC-TC_ENDORS_ACT_DT'.
*
** Date of submission of Agenda brief to EPC
*  PERFORM chk_sch_act_date USING zmm_tms_epc-agnd_sub_sch_dt
*                                 zmm_tms_epc-agnd_sub_act_dt
*                                 'ZMM_TMS_EPC-AGND_SUB_SCH_DT'
*                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
*
** Date of EPC meeting
*  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_meet_sch_dt
*                                 zmm_tms_epc-epc_meet_act_dt
*                                 'ZMM_TMS_EPC-EPC_MEET_SCH_DT'
*                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.
*
** Date of Endorsement by Concerned Director
*  PERFORM chk_sch_act_date USING zmm_tms_epc-dr_endors_sch_dt
*                                 zmm_tms_epc-dr_endors_act_dt
*                                 'ZMM_TMS_EPC-DR_ENDORS_SCH_DT'
*                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.
*
** Date of receipt of summary minutes of EPC meeting
*  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smr_sch_dt
*                                 zmm_tms_epc-epc_smr_act_dt
*                                 'ZMM_TMS_EPC-EPC_SMR_SCH_DT'
*                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.
*18.10.2012 : End

*18.10.2012 - Commented : Start
* Date of submission of EPC agenda for endorsement by Director
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_agnda_sch_dt
                                 zmm_tms_epc-epc_agnda_act_dt
                                 'ZMM_TMS_EPC-EPC_AGNDA_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_AGNDA_ACT_DT'.

* Date of Endorsement by Concerned Director
  PERFORM chk_sch_act_date USING zmm_tms_epc-dr_endors_sch_dt
                                 zmm_tms_epc-dr_endors_act_dt
                                 'ZMM_TMS_EPC-DR_ENDORS_SCH_DT'
                                 'ZMM_TMS_EPC-DR_ENDORS_ACT_DT'.

* Date of submission of Agenda in EPC cell
  PERFORM chk_sch_act_date USING zmm_tms_epc-agnd_sub_sch_dt
                                 zmm_tms_epc-agnd_sub_act_dt
                                 'ZMM_TMS_EPC-AGND_SUB_SCH_DT'
                                 'ZMM_TMS_EPC-AGND_SUB_ACT_DT'.
* Date of EPC meeting
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_meet_sch_dt
                                 zmm_tms_epc-epc_meet_act_dt
                                 'ZMM_TMS_EPC-EPC_MEET_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_MEET_ACT_DT'.

* Date of receipt of summary minutes of EPC meeting
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smr_sch_dt
                                 zmm_tms_epc-epc_smr_act_dt
                                 'ZMM_TMS_EPC-EPC_SMR_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_SMR_ACT_DT'.

* Date of receipt of summary note from EPC
  PERFORM chk_sch_act_date USING zmm_tms_epc-epc_smrn_sch_dt
                                 zmm_tms_epc-epc_smrn_act_dt
                                 'ZMM_TMS_EPC-EPC_SMRN_SCH_DT'
                                 'ZMM_TMS_EPC-EPC_SMRN_ACT_DT'.
*18.10.2012 : End
ENDMODULE.                 " CHK_DATES_0800  INPUT

*&---------------------------------------------------------------------*
*&      Module  READ_TEXT  INPUT
*&---------------------------------------------------------------------*
* To read Tender Process/ Tender Type
*----------------------------------------------------------------------*
MODULE read_text INPUT.

  CLEAR : g_tndr_proc,
          g_tndr_typ.

  IF NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.

    SELECT SINGLE nat_proc_desc FROM znat_proc
          INTO g_tndr_proc
             WHERE zznat_proc = zmm_pur_tender_d_st-tndr_proc.

*    PERFORM read_text USING   'ZNATPROC'
*                               zmm_pur_tender_d_st-tndr_proc
*                      CHANGING g_tndr_proc.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-tnndr_typ IS INITIAL.

    PERFORM read_text USING   'ZZTEN_TYP'
                               zmm_pur_tender_d_st-tnndr_typ
                      CHANGING g_tndr_typ.
  ENDIF.

ENDMODULE.                 " READ_TEXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  CALC_PBO_BIDDERS  INPUT
*&---------------------------------------------------------------------*
* To derive shortlisted biider(s) for PBO
*----------------------------------------------------------------------*
MODULE calc_pbo_bidders INPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

* IF NOT zmm_tms_pb-no_sl_bidders IS INITIAL AND g_pbo_bidrs = 'X'.
*      IF g_pbo_bidrs = 'X'.

      zmm_tms_pb-no_sl_bidders = zmm_tms_tc-no_offer -
                                 zmm_tms_tb-no_bid_rej.

      IF zmm_tms_pb-no_sl_bidders LT 0.

        CLEAR : zmm_tms_pb-no_sl_bidders.

      ENDIF.

*      CLEAR g_pbo_bidrs.

*      ENDIF.

  ENDCASE.

ENDMODULE.                 " CALC_PBO_BIDDERS  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_ACT_DATES_0800  INPUT
*&---------------------------------------------------------------------*
* To check EPC dates
*----------------------------------------------------------------------*
MODULE chk_act_dates_0800 INPUT.

  PERFORM chk_act_date.

ENDMODULE.                 " CHK_ACT_DATES_0800  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHK_SUBS_TC_MEM  INPUT
*&---------------------------------------------------------------------*
* To check substitute TC Member
*----------------------------------------------------------------------*
MODULE chk_subs_tc_mem INPUT.

*TC Member 1
  IF NOT zmm_tms_tc-tc_ms1_chk IS INITIAL.

    IF zmm_tms_tc-tc_member1_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER1_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member1 IS INITIAL AND
             zmm_tms_tc-tc_member1 = zmm_tms_tc-tc_member1_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER1_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member1_s
                                       'ZMM_TMS_TC-TC_MEMBER1_S'
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 2
  IF NOT zmm_tms_tc-tc_ms2_chk IS INITIAL.

    IF zmm_tms_tc-tc_member2_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER2_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member2 IS INITIAL AND
             zmm_tms_tc-tc_member2 = zmm_tms_tc-tc_member2_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER2_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member2_s
                                       'ZMM_TMS_TC-TC_MEMBER2_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 3
  IF NOT zmm_tms_tc-tc_ms3_chk IS INITIAL.

    IF zmm_tms_tc-tc_member3_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER3_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member3 IS INITIAL AND
             zmm_tms_tc-tc_member3 = zmm_tms_tc-tc_member3_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER3_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member3_s
                                       'ZMM_TMS_TC-TC_MEMBER3_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member4
                                       zmm_tms_tc-tc_member5.
    ENDIF.

  ENDIF.

*TC Member 4
  IF NOT zmm_tms_tc-tc_ms4_chk IS INITIAL.

    IF zmm_tms_tc-tc_member4_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER4_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member4 IS INITIAL AND
             zmm_tms_tc-tc_member4 = zmm_tms_tc-tc_member4_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER4_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member4_s
                                       'ZMM_TMS_TC-TC_MEMBER4_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member5.

    ENDIF.

  ENDIF.

*TC Member 5
  IF NOT zmm_tms_tc-tc_ms5_chk IS INITIAL.

    IF zmm_tms_tc-tc_member5_s IS INITIAL.

      SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER5_S'.

      MESSAGE i032(zmmpurtdr).

    ELSE.

      IF NOT zmm_tms_tc-tc_member5 IS INITIAL AND
             zmm_tms_tc-tc_member5 = zmm_tms_tc-tc_member5_s.

        SET CURSOR FIELD 'ZMM_TMS_TC-TC_MEMBER5_S'.

        MESSAGE e033(zmmpurtdr).

      ENDIF.

      PERFORM chk_dup_sub_tc_mem USING zmm_tms_tc-tc_member5_s
                                       'ZMM_TMS_TC-TC_MEMBER5_S'
                                       zmm_tms_tc-tc_member1
                                       zmm_tms_tc-tc_member2
                                       zmm_tms_tc-tc_member3
                                       zmm_tms_tc-tc_member4.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CHK_SUBS_TC_MEM  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_DUP_TC_MEM_0500  INPUT
*&---------------------------------------------------------------------*
* To check duplicate TC Member
*----------------------------------------------------------------------*
MODULE chk_dup_tc_mem_0500 INPUT.
***********************************************************************
*                             TC Member                               *
***********************************************************************
  IF NOT zmm_tms_tc-tc_member1 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member1
                                 'ZMM_TMS_TC-TC_MEMBER1'
                                 zmm_tms_tc-tc_member2
                                 'ZMM_TMS_TC-TC_MEMBER2'
                                 zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member2 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member2
                                 'ZMM_TMS_TC-TC_MEMBER2'
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member3 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member3
                                 'ZMM_TMS_TC-TC_MEMBER3'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member4 IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member4
                                 'ZMM_TMS_TC-TC_MEMBER4'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member5
                                 'ZMM_TMS_TC-TC_MEMBER5'.
  ENDIF.

***********************************************************************
*                   Substitute TC Member                              *
***********************************************************************
  IF NOT zmm_tms_tc-tc_member1_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member1_s
                                 'ZMM_TMS_TC-TC_MEMBER1_S'
                                 zmm_tms_tc-tc_member2_s
                                 'ZMM_TMS_TC-TC_MEMBER2_S'
                                 zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member2_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member2_s
                                 'ZMM_TMS_TC-TC_MEMBER2_S'
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member3_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member3_s
                                 'ZMM_TMS_TC-TC_MEMBER3_S'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

  IF NOT zmm_tms_tc-tc_member4_s IS INITIAL.

    PERFORM chk_dup_tc_mem USING zmm_tms_tc-tc_member4_s
                                 'ZMM_TMS_TC-TC_MEMBER4_S'
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 g_tm
                                 ''
                                 zmm_tms_tc-tc_member5_s
                                 'ZMM_TMS_TC-TC_MEMBER5_S'.
  ENDIF.

ENDMODULE.                 " CHK_DUP_TC_MEM_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALID_EMPID_0500  INPUT
*&---------------------------------------------------------------------*
* To check employee ID (CPF No.)
*----------------------------------------------------------------------*
MODULE valid_empid_0500 INPUT.

*  IF .
*
*  ENDIF.

  IF sy-ucomm = 'SAVE'.
    IF zmm_tms_tc-tc_stat = 'X' .
      IF zmm_tms_tc-tc_member1 IS INITIAL OR
       zmm_tms_tc-tc_member2 IS INITIAL.

        MESSAGE 'Please Enter TC Mamber' TYPE 'E'.
      ENDIF.


    ENDIF.
  ENDIF.


ENDMODULE.                 " VALID_EMPID_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_NO_BID_REJ  INPUT
*&---------------------------------------------------------------------*
* To check No. of bids rejected on commercial/technical grounds
* (Technical tab / Screen 0600)
*----------------------------------------------------------------------*
MODULE chk_no_bid_rej INPUT.

  IF zmm_tms_tb-no_bid_rej GT zmm_tms_tc-no_offer.

    MESSAGE e036(zmmpurtdr) WITH zmm_tms_tc-no_offer.

  ELSE.

    zmm_tms_pb-no_sl_bidders = zmm_tms_tc-no_offer -
                               zmm_tms_tb-no_bid_rej.

  ENDIF.

ENDMODULE.                 " CHK_NO_BID_REJ  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PR_MANDATORY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_pr_mandatory INPUT.

*+006 : Start
  CLEAR : g_ok_code_300.

  g_ok_code_300 = sy-ucomm.

  CLEAR sy-ucomm.

  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

    IF zmm_pur_tender_d_st-banfn IS INITIAL AND
       g_ok_code_300 NE 'PCHK'.
*+006 : End
*   IF zmm_pur_tender_d_st-banfn IS INITIAL.            "-006
*     IF g_no_pr <> 'X'.                                "-006
      IF zmm_pur_tender_d_st-prchk NE 'X'.              "+006
        MESSAGE e321(zmm) WITH text-015 .
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_PR_MANDATORY  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INITIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_initial INPUT.
*  data : l_bstyp TYPE zmm_pur_trtyp-bstyp.
*  clear : l_bstyp.
*
*  select single BSTYP
*    into l_bstyp
*    from ZMM_PUR_TRTYP
*    where BSART = ZMM_PUR_TENDER_D_ST-BSART.
*  if sy-subrc = 0.
*    if l_bstyp = 'L'.
*    else.
*      MESSAGE e321(zmm) WITH text-016 .
*    endif.
*  endif.
  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
*    IF zmm_pur_tender_d_st-bstyp = 'C'.
*      IF zmm_pur_tender_d_st-tndr_fee IS INITIAL.
*        MESSAGE e321(zmm) WITH text-016 .
*      ENDIF.
*    ENDIF.
*+006 : Start
    IF zmm_pur_tender_d_st-tndr_val LE 0.
      MESSAGE e321(zmm) WITH text-020.
    ENDIF.
*+006 : End
  ENDIF.
ENDMODULE.                 " CHECK_INITIAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_NAME_DESIG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_name_desig INPUT.
  IF NOT zmm_pur_tender_d_st-tdrsigner IS INITIAL.

    PERFORM get_name_design USING    zmm_pur_tender_d_st-tdrsigner
                            CHANGING wa_tdrsigner-ename
                                     wa_tdrsigner-desig_text.
  ELSE.

    CLEAR : wa_tdrsigner.

  ENDIF.
ENDMODULE.                 " FILL_NAME_DESIG  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOPUB  INPUT            +003  CR 30009068.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_dopub INPUT.


ENDMODULE.                 " CHECK_DOPUB  INPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_NITDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_nitdate INPUT.
  PERFORM display_nitdate.                       "+008
*-008 : Start
*  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
*    IF NOT zmm_pur_tender_d_st-tndr_val IS INITIAL OR
*      NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL.
*      IF zmm_pur_tender_d_st-tndr_val < 500000 OR
*         zmm_pur_tender_d_st-tndr_proc = 10 OR
*         zmm_pur_tender_d_st-tndr_proc = 11 OR
*         zmm_pur_tender_d_st-tndr_proc = 12 OR
*         zmm_pur_tender_d_st-tndr_proc = 13 OR
*         zmm_pur_tender_d_st-tndr_proc = 14 OR
*         zmm_pur_tender_d_st-tndr_proc = 15 OR
*         zmm_pur_tender_d_st-tndr_proc =  7 OR
*         zmm_pur_tender_d_st-tndr_proc =  8 OR
*         zmm_pur_tender_d_st-tndr_proc =  9.
*        LOOP AT SCREEN.
*          IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*            screen-input = 0.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*-008 : End
ENDMODULE.                 " DISPLAY_NITDATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALID_BANFN  INPUT
*&---------------------------------------------------------------------*
* To Validate purchase requisition : Screen 0300
*----------------------------------------------------------------------*
MODULE valid_banfn INPUT.

  CLEAR : g_loekz,
          g_frgkz.
  IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.

*+008 : PR does not exist message - Start
    CLEAR g_banfn.
    SELECT SINGLE banfn FROM eban INTO (g_banfn)
       WHERE banfn =  zmm_pur_tender_d_st-banfn.

    IF sy-subrc EQ 0.
*+008 : End

      SELECT SINGLE loekz frgkz FROM eban INTO (g_loekz,g_frgkz)
         WHERE banfn =  zmm_pur_tender_d_st-banfn
*+005 : Start
           AND loekz NE 'X'
           AND frgkz = 'B'.
*+005 : End

*-005 : Start
*    IF g_loekz = 'X'.
*
*      MESSAGE e970(zmm) WITH zmm_pur_tender_d_st-banfn.
*
*    ELSEIF g_frgkz NE 'B'.
*-005 : End

      IF sy-subrc NE 0.                                   "+005

        MESSAGE e971(zmm) WITH zmm_pur_tender_d_st-banfn.

      ENDIF.

*+008 : Start
    ELSE.
      MESSAGE e407(06).
    ENDIF.
*+008 : End

  ENDIF.


ENDMODULE.                 " VALID_BANFN  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_NIT_DATE  INPUT
*&---------------------------------------------------------------------*
* To make NIT date mandatory if tender value is more than 5 lakhs
*----------------------------------------------------------------------*
MODULE check_nit_date INPUT.

  IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'. "+009

*    IF zmm_pur_tender_d_st-tndr_val GT 5000000 AND
    IF zmm_pur_tender_d_st-tndr_val GT 1000000 AND "added by cab_dns 04082015
       zmm_pur_tender_d_st-nitdate IS INITIAL.

*+008 : Start
      IF zmm_pur_tender_d_st-tndr_proc = 10 OR
         zmm_pur_tender_d_st-tndr_proc = 11 OR
         zmm_pur_tender_d_st-tndr_proc = 12 OR
         zmm_pur_tender_d_st-tndr_proc = 13 OR
         zmm_pur_tender_d_st-tndr_proc = 14 OR
         zmm_pur_tender_d_st-tndr_proc = 15 OR
         zmm_pur_tender_d_st-tndr_proc =  7 OR
         zmm_pur_tender_d_st-tndr_proc =  8 OR
         zmm_pur_tender_d_st-tndr_proc =  9.
      ELSE.
*+008 : End
        PERFORM display_nitdate.

        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-NITDATE'.

        MESSAGE e321(zmm) WITH text-021.

      ENDIF.                                       "+008

    ENDIF.

    IF NOT zmm_pur_tender_d_st-nitdate   IS INITIAL AND
       NOT zmm_pur_tender_d_st-st_sel_dt IS INITIAL.

      IF zmm_pur_tender_d_st-nitdate GT zmm_pur_tender_d_st-st_sel_dt.

        SET CURSOR FIELD 'ZMM_PUR_TENDER_D_ST-NITDATE'.

        MESSAGE e363(zmm).

      ENDIF.

    ENDIF.

  ENDIF.                                         "+009

ENDMODULE.                 " CHECK_NIT_DATE  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHK_PR_RCPT_DT  INPUT
*&---------------------------------------------------------------------*
* To check PR Receipt Date
*----------------------------------------------------------------------*
MODULE chk_pr_rcpt_dt INPUT.

  IF g_ok_code NE 'DISP'.


    IF NOT zmm_pur_tender_d_st-banfn  IS INITIAL AND
            zmm_tms_general-pr_rcpt_dt IS INITIAL.
**----------Start of change 30.06.2016 14:18:21 REKHA  -------------------
*      MESSAGE e127(zmm_oth).
**----------End  of change 30.06.2016 14:18:21 REKHA  -----------------


    ELSE.

      IF zmm_tms_general-pr_rcpt_dt GT sy-datum.

        MESSAGE e141(zmm_oth).

      ELSE.

* Set default value of EPC type under price bid tab as EPC type under
* General tab
        IF zmm_tms_pb-epc_typ_pb IS INITIAL.

          MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb.

          PERFORM get_no_rfq_maint USING    zmm_pur_tender_d_st-banfn
                                   CHANGING zmm_tms_pb-no_req.

        ENDIF.

        PERFORM calc_various_dates USING  zmm_pur_tender_d_st-bstyp
                                          zmm_tms_general-pr_rcpt_dt.
      ENDIF.

    ENDIF.

    """""""""""""""""""""""""""""""""
    "added by lipsy on 11.05.2015 RD1K997136
    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.

      IF zmm_tms_general-epc_typ = 'E' .

        """""""""""""""""""""""""""""""""""
        """"commented by lipsy on 25.05.2015 RD1K997320

*ZMM_TMS_PB-EPC_TYP_PB = 'E'.


        ""end of comment by lipsy on 25.05.2015 RD1K997320

        """""""""""""""""""""""""""""""""""""""""""""

        zmm_tms_tc-cpa = 'EPC'.

        """""""""""""""""""""""""""""""""""""""""
        """"added by lipsy on 25.05.2015 RD1K997320

        CLEAR:wa_cpa_dtl-ename,wa_cpa_dtl-desig_text.

      ELSE.
        IF zmm_tms_tc-cpa = 'EPC'.
          CLEAR:zmm_tms_tc-cpa.
        ENDIF.

        ""end of addition by lipsy on 25.05.2015 RD1K997320
        """""""""""""""""""""""""""""""""""""""""""

      ENDIF.


    ENDIF.

    "end of addition  by lipsy on 11.05.2015 RD1K997136
    """""""""""""""""""""""""""""""""""""

  ENDIF.

ENDMODULE.                 " CHK_PR_RCPT_DT  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_PRE_BID_DT_0500  INPUT
*&---------------------------------------------------------------------*
* To calculate scheduled date :
*  - Receipt of querry from Bidders
*  - Scrutiny and PBC Date
*----------------------------------------------------------------------*
MODULE set_pre_bid_dt_0500 INPUT.

  IF g_ok_code NE 'DISP'.

    IF zmm_pur_tender_d_st-bstyp = 'C'.

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

    ELSEIF zmm_pur_tender_d_st-bstyp = 'L'.

      PERFORM set_pre_bid_l_dt USING  zmm_tms_tc-pbc_stat
                                      zmm_pur_tender_d_st-tndr_val
                                      zmm_pur_tender_d_st-sch_tdrdt
                                      zmm_tms_tc-verf_iss_sch_dt
                                      zmm_tms_general-lstk
                             CHANGING zmm_tms_tc-rcpt_bid_sch_dt
                                      zmm_tms_tc-pbc_sch_dt
                                      zmm_tms_tc-amd_issu_sch_dt
                                      zmm_tms_tc-subm_dl_sch_dt.

    ENDIF.

  ENDIF.

ENDMODULE.                 " SET_PRE_BID_DT_0500  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALID_EPC_TYP_PB  INPUT
*&---------------------------------------------------------------------*
* Validate EPC Type in Price Bid
*----------------------------------------------------------------------*
MODULE valid_epc_typ_pb INPUT.

  IF zmm_tms_general-epc_typ NE zmm_tms_pb-epc_typ_pb.

    IF zmm_tms_general-epc_typ = 'D' AND
       zmm_tms_pb-epc_typ_pb   = 'E'.

    ELSEIF zmm_tms_general-epc_typ = 'N' AND
         ( zmm_tms_pb-epc_typ_pb   = 'E' OR
           zmm_tms_pb-epc_typ_pb   = 'D' ).

    ELSE.

      MOVE zmm_tms_general-epc_typ TO zmm_tms_pb-epc_typ_pb.

    ENDIF.

  ENDIF.

ENDMODULE.                 " VALID_EPC_TYP_PB  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_ICMM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_icmm INPUT.



  IF  zmm_tms_tc-ic_mm IS NOT INITIAL.

    SHIFT zmm_tms_tc-ic_mm  LEFT DELETING LEADING '0'.





    REFRESH:itab_agr_users[].
    SELECT mandt uname agr_name from_dat to_dat
        FROM agr_users
        INTO CORRESPONDING FIELDS OF TABLE itab_agr_users
        WHERE uname = zmm_tms_tc-ic_mm
        AND agr_name IN ('D:MM_PUR_PO_APPROVE_IM','D:MM_SRV_IND_APPROVE_L2',
     'D:MM_SRV_IND_APPROVE_L3')
        AND to_dat >= sy-datum.
    IF sy-subrc = 0.
    ELSE.
      MESSAGE 'Please enter correct IC MM' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_ICMM  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_L1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_l1 INPUT.
  IF  zmm_tms_tc-l1 IS NOT INITIAL.

    SHIFT zmm_tms_tc-l1 LEFT DELETING LEADING '0'.



    REFRESH:itab_agr_users[].
    SELECT mandt uname agr_name from_dat to_dat
          FROM agr_users
          INTO CORRESPONDING FIELDS OF TABLE itab_agr_users
          WHERE uname =  zmm_tms_tc-l1
          AND agr_name IN
    ('D:MM_SRV_IND_APPROVE_L1' ,'D:MM_SRV_IND_APPROVE_1A','D:MM_SRV_IND_APPROVE_1B','D:MM_SRV_IND_APPROVE_1C'
     ,'D:MM_SRV_IND_APPROVE_1D','D:MM_SRV_IND_APPROVE_1E' )
     AND to_dat >= sy-datum.
    IF sy-subrc = 0.
    ELSE.
      MESSAGE 'Please enter correct L1' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_L1  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_MM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mm INPUT.
  IF NOT zmm_tms_tc-tc_member1_s IS INITIAL.
    PERFORM check_mm USING zmm_tms_tc-tc_member1_s.
*          CHANGING l_disc_cd_1s.
  ELSEIF NOT zmm_tms_tc-tc_member1 IS INITIAL.
    PERFORM check_mm USING zmm_tms_tc-tc_member1.
*          CHANGING l_disc_cd_1.
  ENDIF.
ENDMODULE.                 " CHECK_MM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_fi INPUT.
  IF NOT zmm_tms_tc-tc_member2_s IS INITIAL.
    PERFORM check_fi USING zmm_tms_tc-tc_member2_s.
  ELSEIF NOT zmm_tms_tc-tc_member2 IS INITIAL.
    PERFORM check_fi USING zmm_tms_tc-tc_member2.
  ENDIF.

ENDMODULE.                 " CHECK_FI  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INDENTOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_indentor INPUT.

  IF NOT zmm_tms_tc-tc_member3_s IS INITIAL.
    PERFORM check_indentor USING zmm_tms_tc-tc_member3_s.
  ELSEIF NOT zmm_tms_tc-tc_member3 IS INITIAL.
    PERFORM check_indentor USING zmm_tms_tc-tc_member3.
  ENDIF.



ENDMODULE.                 " CHECK_INDENTOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_CPA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_cpa INPUT.
  DATA:p_ename_cpa TYPE pa0001-ename.

**----------Start of change 27.06.2016 16:51:26 -------------------
*SELECT SINGLE ename FROM pa0001 INTO p_ename_cpa
*         WHERE pernr = zmm_tms_tc-cpa  AND
*               endda = '99991231'.
*
  SELECT SINGLE ename FROM zpa0001 INTO p_ename_cpa
         WHERE pernr = zmm_tms_tc-cpa  AND
               endda = '99991231'.
**----------End  of change 27.06.2016 16:51:26 -----------------

  IF sy-subrc NE 0.

    IF  zmm_tms_tc-cpa = 'EPC'.

      IF zmm_tms_general-epc_typ = 'E' OR zmm_tms_pb-epc_typ_pb = 'E'.
      ELSE.
        IF g_ok_code = 'DISP'.
        ELSE.
          MESSAGE 'Please Enter valid CPF no' TYPE 'E'.
        ENDIF.
      ENDIF.

    ELSE.
      IF g_ok_code = 'DISP'.
      ELSE.
        MESSAGE 'Please Enter valid CPF no' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDATE_CPA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TENDER_VAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tender_val INPUT.

  IF zmm_pur_tender_d_st-tndr_val LE 0.

    MESSAGE 'Tender value should be greater than Zero' TYPE 'W'.
  ENDIF.

ENDMODULE.                 " CHECK_TENDER_VAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TNDR_PROC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tndr_proc INPUT.

  IF zmm_pur_tender_d_st-bstyp = 'B' OR
     zmm_pur_tender_d_st-bstyp = 'L' OR
     zmm_pur_tender_d_st-bstyp = 'S'.

    zmm_pur_tender_d_st-tndr_proc = '17'.

  ELSEIF zmm_pur_tender_d_st-bstyp = 'C' .

    zmm_pur_tender_d_st-tndr_proc = '16'.

  ENDIF.


ENDMODULE.                 " FILL_TNDR_PROC  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_APHA_NUMARIC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_apha_numaric INPUT.

  IF zmm_pur_tender_d_st-dlg_offic CA sy-abcde OR zmm_pur_tender_d_st-dlg_offic CA '0123456789'.
  ELSE.
    MESSAGE 'Dealing officer code can only be alpha numeric' TYPE 'E'.
  ENDIF.



ENDMODULE.                 " CHECK_APHA_NUMARIC  INPUT
