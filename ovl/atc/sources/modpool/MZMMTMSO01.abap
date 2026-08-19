*--- MAIN PROGRAM: MZMMTMSO01 ---*
*&---------------------------------------------------------------------*
*&      Module  POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
* To popup important information messages as user execute tr. code
* ZMMIMS.
*----------------------------------------------------------------------*
MODULE pop_message OUTPUT.

  IF g_exec = 'X'.

    CLEAR g_exec.
*
    CALL FUNCTION 'ZMM_POPUP_TMS_MESSAGE'
      EXPORTING
        arbgb             = 'ZMM'
        msgnr             = '861'
        msgty             = 'I'
      EXCEPTIONS
        user_cancel       = 1
        message_not_found = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDMODULE.                 " POP_MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR  'T100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0250  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE status_0150 OUTPUT.
  SET PF-STATUS 'S150'.
  SET TITLEBAR 'T150'.
ENDMODULE.                 " STATUS_0250  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*     To set the pf status & title for screen 0200.
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW'.

      REFRESH ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
*     SET PF-STATUS 'S200'.
      SET TITLEBAR 'T200'.

    WHEN 'CHNG'.

      REFRESH ist_pf_status.
      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
*     SET PF-STATUS 'S200'.
      SET TITLEBAR 'T20C'.

    WHEN 'DISP'.
      REFRESH ist_pf_status.
      MOVE 'SAVE' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
      SET TITLEBAR 'T20D'.

*+002 : Start
    WHEN 'APRV'.

      REFRESH ist_pf_status.
      MOVE 'LIST' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'ATCH' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S200' EXCLUDING ist_pf_status.
      SET TITLEBAR 'T20A'.
*+002 : End

  ENDCASE.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  REFRESH ist_tab.

  CASE sy-tcode.
    WHEN 'ZMMTDR3'.
*      GET PARAMETER ID 'SUB' FIELD zmm_pur_tender_d_st-submi.
      MOVE 'BU' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
      MOVE 'TDRGE' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
    WHEN 'ZMMTDR2'.
      MOVE 'TDRGE' TO wa_tab-fcode.
      APPEND wa_tab TO ist_tab.
      IF g_option IS INITIAL.
        MOVE 'BU' TO wa_tab-fcode.
        APPEND wa_tab TO ist_tab.
      ENDIF.
  ENDCASE.

  IF g_action = 'X'.
    MOVE 'TDRGE' TO wa_tab-fcode.
    APPEND wa_tab TO ist_tab.
  ENDIF.

  SET PF-STATUS '100' EXCLUDING ist_tab.
  SET TITLEBAR '001' WITH tstct-ttext.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DEFA-DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE defa-data OUTPUT.
*Get the title with refrence to T.code
  CALL FUNCTION 'TSTCT_SINGLE_READ'
    EXPORTING
      sprache    = sy-langu
*     tcode      = sy-tcode
      tcode      = g_tcode
    IMPORTING
      wtstct     = tstct
    EXCEPTIONS
      wrong_call = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*-----Get Current Fiscal year
  IF NOT zmm_pur_tender_d_st-tdrsigner IS INITIAL.

    PERFORM get_name_design USING    zmm_pur_tender_d_st-tdrsigner
                            CHANGING wa_tdrsigner-ename
                                     wa_tdrsigner-desig_text.
  ELSE.

    CLEAR : wa_tdrsigner.

  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """ADDED BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950

  if g_ok_code_300 = 'MORE' ." TO RESTRICT ONLY AT THE MOMENT CASES OF PR ENTRY.
  ELSE.

    if zmm_pur_tender_d_st-submi is not initial.
      refresh:ist_eban_all[].
      select banfn banfn2 banfn3 banfn4 banfn5 from zmm_pur_tender_d  "+001
           into corresponding fields of table ist_eban_all
                where submi = zmm_pur_tender_d_st-submi.


      """"""""""get all prs
      refresh:ist_eban[].

      if not ist_eban_all[] is initial.
        clear:wa_eban_all,wa_eban.
        loop at ist_eban_all into wa_eban_all.

*PR 1
          if  wa_eban_all-banfn is not INITIAL.
            move  wa_eban_all-banfn to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.
*PR 2
          if not  wa_eban_all-banfn2 is initial.
            move  wa_eban_all-banfn2 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 3
          if not  wa_eban_all-banfn3 is initial.
            move  wa_eban_all-banfn3 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 4
          if not  wa_eban_all-banfn4 is initial.
            move  wa_eban_all-banfn4 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

*PR 5
          if not  wa_eban_all-banfn5 is initial.
            move  wa_eban_all-banfn5 to wa_eban-banfn.
            append wa_eban to ist_eban.
          endif.

          clear: wa_eban_all,wa_eban.
        endloop.

        sort ist_eban by banfn.
        delete adjacent duplicates from ist_eban.

      endif.

      """""""""get all items
      if ist_eban[] IS not INITIAL.
        select banfn bnfpo statu txz01 menge preis waers werks badat from eban
          into corresponding fields of table ist_eban_t
          FOR ALL ENTRIES IN  ist_eban[]
          where banfn = ist_eban-banfn.
      endif.

*     bsart ne 'SWO'   and
*               statu =  'N'     and
*               loekz ne 'X'     and
*               frgkz =  'B'     and
*               erdat ge l_erdat.


      clear:wa_eban.

      clear:l_fval.
      loop at ist_eban into wa_eban.

        clear : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp,v_pr_val.

        loop at ist_eban_t into wa_eban_t where banfn = wa_eban-banfn.

"""""""""""""""""""
"add by lipsy on 8.07.2015 RD1K997763
if wa_eban_t-loekz = ''.
"end of addition by lipsy on 8.07.2015 RD1K997763
""""""""""""""""""
          if wa_eban_t-waers ne 'INR'.

            clear : wa_erate,
                    l_rval.

            move 'M'             to l_rate_type.
            move wa_eban_t-waers to l_from_curr.
            move 'INR'           to l_to_curr.
            move wa_eban_t-badat to l_trans_dt.

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
                others        = 4.

            if sy-subrc <> 0.
*              message id sy-msgid type 'I' number sy-msgno
*                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.

            l_temp  =  wa_eban_t-preis * wa_eban_t-menge .
            l_rlwrt =  l_temp * l_rval.
            l_erate =  l_rlwrt.

            l_fval = l_fval + l_erate.

          else.

            l_temp = wa_eban_t-preis * wa_eban_t-menge.

            l_fval = l_fval + l_temp.

          endif.



          clear : wa_eban_t,l_rate_type,l_from_curr,
        l_to_curr,l_trans_dt,wa_erate,l_rval,l_rlwrt,l_erate,l_temp.

""""""""""
"add by lipsy on 8.07.2015 RD1K997763
endif.
"end of addition  by lipsy on 8.07.2015 RD1K997763
"""""""""""""
        endloop.


        clear:wa_eban.
      endloop.

      move l_fval to v_pr_val.

    endif.

  ENDIF.
  """end of ADDition BY LIPSY ON 27.10.2014  FOR  total pr value
                                                            "RD1K994950
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* CHECK sy-tcode = 'ZMMTDR1'.
  CHECK g_tcode = 'ZMMTDR1'.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = sy-datum
    IMPORTING
      e_gjahr        = zmm_pur_tender_d_st-mjahr
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Added by Kalpesh

  IF zmm_pur_tender_d_st-tdrdt IS INITIAL.

    zmm_pur_tender_d_st-tdrdt = sy-datum.

  ENDIF.

**

ENDMODULE.                 " DEFA-DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attr OUTPUT.

  LOOP AT SCREEN.
    IF zmm_pur_tender_d_st-bsart+0(1) = 'E'.
      IF screen-group3 = 'SRM'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*---Create Mode
*    IF sy-tcode = 'ZMMTDR1' OR
*       g_option = 'X'.

    IF g_tcode = 'ZMMTDR1' OR
       g_option = 'X'.

      IF screen-name = 'ZMM_PUR_TENDER_D_ST-SUBMI'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
*      IF zmm_pur_tender_d_st-bstyp = 'C'.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ELSE.
*        CLEAR zmm_pur_tender_d_st-nitdate.
*      ENDIF.
    ENDIF.
*---Change or Display Mode
*   IF sy-tcode NE 'ZMMTDR1'.
    IF g_tcode NE 'ZMMTDR1'.

      IF screen-name = 'ZMM_PUR_TENDER_D_ST-SUBMI'.
        screen-required = '1'.
        MODIFY SCREEN.
      ENDIF.
      IF screen-group1 = '110'.
        IF g_option IS INITIAL.
          screen-input = '0'.
          screen-invisible = '1'.
        ELSE.
          screen-input = '1'.
          screen-invisible = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*---Change Mode
*   IF sy-tcode EQ 'ZMMTDR2'.
    IF g_tcode EQ 'ZMMTDR2'.

      IF screen-group2 = '111'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
      IF zmm_pur_tender_d_st-tdrsts = 'C' OR
         zmm_pur_tender_d_st-tdrsts = 'X'.
        IF screen-group4 = '113'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

   """"""""""""""""""""""""""""""""
    "added by lipsy on 27.02.2015 RD1K995870

    if sy-uname+0(3) = 'CMM'.
 if zmm_pur_tender_d_st-tdrsts = 'X'.
if screen-name = 'ZMM_PUR_TENDER_D_ST-TNDR_FEE' or
screen-name = 'ZMM_PUR_TENDER_D_ST-TNDR_PROC' or
screen-name =  'ZMM_PUR_TENDER_D_ST-TNNDR_TYP' or
screen-name =  'ZMM_PUR_TENDER_D_ST-TNDR_VAL' .
screen-input = 1.
MODIFY SCREEN.
endif.
endif.
endif.

     "end of addition by lipsy on 27.02.2015 RD1K995870

   """""""""""""""""""""""""""""""""""""""""""
    ENDIF.

*---Display Mode
*   IF sy-tcode EQ 'ZMMTDR3'.

    IF g_tcode EQ 'ZMMTDR3' OR sy-ucomm = 'ZMMTMSDISP'.
      IF screen-group1 = '110'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.

*+007 : Start
      IF zmm_pur_tender_d_st-prchk EQ 'X'.
        IF screen-group2 = 'DIS'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF screen-group2 = 'DIS'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
*+007 : End

    ENDIF.

*+006 : Start
    IF g_ok_code = 'NEW' OR g_ok_code = 'CHNG'.
      IF zmm_pur_tender_d_st-prchk EQ 'X'.

        IF screen-group3 = 'PR'.
*        CLEAR zmm_pur_tender_d_st-banfn.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSEIF zmm_pur_tender_d_st-prchk IS INITIAL.

        IF screen-group3 = 'PR'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
    ENDIF.
*+006 : End

  ENDLOOP.
* Begin of <RD1K985058> on 21052013 by Sudhir Sharma
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
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
* End of <> on 21052013
*---Start NN 03.09.2003
* CHECK sy-tcode EQ 'ZMMTDR2'.
  CHECK g_tcode EQ 'ZMMTDR2'.

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
    LOOP AT SCREEN.
      IF screen-group2 = 'DSP'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.

*      IF zmm_pur_tender_d_st-bstyp = 'C'.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '1'.
*          MODIFY SCREEN.
*        ENDIF.
*      ELSE.
*        CLEAR zmm_pur_tender_d_st-nitdate.
*        IF screen-name = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*          screen-input = '0'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDIF.

    ENDLOOP.
  ENDIF.
*---ENd NN 03.09.2003

ENDMODULE.                 " set_screen_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  check_authorisation  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_authorisation OUTPUT.
  PERFORM authority_check_tcode.
ENDMODULE.                 " check_authorisation  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_COMMON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_screen_common OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

      IF zmm_tms_general-epc_typ = 'N'.

        LOOP AT SCREEN.
          IF screen-group4 = 'EPC'.
            screen-input  = '0'.
            screen-output = '1'.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.

        g_dmode_epc = 'X'.                                  "+001

      ELSE.                                                 "+001

        CLEAR : g_dmode_epc.                                "+001

      ENDIF.

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 22.10.2014 for making actual date of technical bid,price bid greyed RD1K994950

      LOOP AT SCREEN.


        if zmm_pur_tender_d_st-bsart+0(2) = 'ET'.
          if screen-name = 'ZMM_TMS_TB-TEND_OP_ACT_DT' or screen-name = 'ZMM_TMS_PB-PR_BID_OP_ACT_DT'.
            if sy-uname+0(3) = 'CMM' .
            else.
              screen-input = 0.
            endif.
            MODIFY SCREEN.
          endif.
        endif.

      ENDLOOP.


      "end of addition  by lipsy on 22.10.2014 for making actual date of technical bid,price bid greyed RD1K994950
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 11.05.2015 RD1K997136
if ZMM_TMS_GENERAL-EPC_TYP = 'E'.

  """""""""""""""""""""""""""""""""
  """"commented by lipsy on 25.05.2015 RD1K997320
  " or ZMM_TMS_PB-EPC_TYP_PB = 'E'.

  "end of comment by lipsy on 25.05.2015 RD1K997320

  """"""""""""""""""""""""""""""""""""""

ZMM_TMS_TC-CPA = 'EPC'.

""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""
""""added by lipsy on 25.05.2015 RD1K997320

clear:wa_cpa_dtl-ename,wa_cpa_dtl-desig_text.

else.
  if ZMM_TMS_TC-CPA = 'EPC'.
    clear:ZMM_TMS_TC-CPA.
    endif.

""end of addition by lipsy on 25.05.2015 RD1K997320
"""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""

  endif.

"""""""""""""""""""""""""""""""""""""""""""""""""""
""""commented by lipsy on 25.05.2015 RD1K997320

*if ZMM_TMS_GENERAL-EPC_TYP = 'E' .
*
*  ZMM_TMS_PB-EPC_TYP_PB = 'E'.
*
*  endif.

  """""""""""""end of comment by lipsy on 25.05.2015 RD1K997320
  """"""""""""""""""""""""""""""""""""""""""""""""
"end of addition  by lipsy on 11.05.2015 RD1K997136

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


*   WHEN 'DISP'.                                            "-002
    WHEN 'DISP' OR 'APRV'.                                  "+002
      LOOP AT SCREEN.
        IF screen-group3 = '003'.
          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

  ENDCASE.


  """""""""""""""""
  """"""""added by lipsy on 15.05.2015 RD1K997136
  if ZMM_TMS_TC-CPA is not initial.

    call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  = ZMM_TMS_TC-CPA
        importing
          output = ZMM_TMS_TC-CPA.

    endif.

  "end of addition by lipsy on 15.05.2015 RD1K997136
  """"""""""""""""""""""

ENDMODULE.                 " INIT_SCREEN_COMMON  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_0400  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0400
*----------------------------------------------------------------------*
MODULE init_screen_0400 OUTPUT.

  CASE g_ok_code.

    WHEN 'NEW' OR 'CHNG'.

      LOOP AT SCREEN.

        IF g_spfc = 'X'.

          CLEAR g_dmode_spfc.

          IF screen-group2 = 'MET'.
            screen-input   = '0'.
            screen-output  = '1'.
            MODIFY SCREEN.
          ENDIF.

        ELSE.

          g_dmode_spfc = 'X'.

          IF screen-group2 = 'MET'.
            screen-input   = '1'.
            screen-output  = '1'.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

      ENDLOOP.

*   WHEN 'DISP'.                                            "-002
    WHEN 'DISP' OR 'APRV'.                                  "+002
      LOOP AT SCREEN.
        IF screen-group2 = 'MET'.
          screen-input   = '0'.
          screen-output  = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " INIT_SCREEN_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_0500  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0500
*----------------------------------------------------------------------*
MODULE init_screen_0500 OUTPUT.

  """""""""""""""""""""""""
  "added by lipsy on 2.03.2015  for making tender commitee default RD1K995870

if  v_initial is INITIAL.
 ZMM_TMS_TC-TC_STAT = 'X'.
 v_initial = 'X'.
endif.

  "end of addition by lipsy on 2.03.2015  for making tender commitee default RD1K995870
  """"""""""""""""""""""""""

  LOOP AT SCREEN.

    IF zmm_tms_tc-tc_stat = 'X'.

      IF screen-group2 = 'CHK'.
        screen-input     = '1'.
        screen-invisible = '0'.
        MODIFY SCREEN.
      ENDIF.

*18.10.2012 : Start
***********************************************************************
* Set attribute of check box
***********************************************************************
      IF zmm_tms_tc-tc_member1 IS INITIAL.

        IF screen-group4 = 'CK1'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK1'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member2 IS INITIAL.

        IF screen-group4 = 'CK2'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK2'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member3 IS INITIAL.

        IF screen-group4 = 'CK3'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK3'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member4 IS INITIAL.

        IF screen-group4 = 'CK4'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK4'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_member5 IS INITIAL.

        IF screen-group4 = 'CK5'.

          screen-input  = '0'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ELSE.

        IF screen-group4 = 'CK5'.

          screen-input  = '1'.
          screen-output = '1'.
          MODIFY SCREEN.

        ENDIF.

      ENDIF.

***********************************************************************
* Set attribute of substitute tc member
***********************************************************************
      IF zmm_tms_tc-tc_ms1_chk = 'X'.

        IF screen-group4 = 'SB1'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB1'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member1_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms2_chk = 'X'.

        IF screen-group4 = 'SB2'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB2'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member2_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms3_chk = 'X'.

        IF screen-group4 = 'SB3'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB3'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member3_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms4_chk = 'X'.

        IF screen-group4 = 'SB4'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB4'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member4_s.

        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms5_chk = 'X'.

        IF screen-group4 = 'SB5'.
          screen-input     = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'SB5'.
          screen-input     = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.

          CLEAR : zmm_tms_tc-tc_member5_s.

        ENDIF.

      ENDIF.

***********************************************************************
* Set attribute of tc member
***********************************************************************
      IF zmm_tms_tc-tc_ms1_chk = 'X'.

        IF screen-group4 = 'TC1'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC1'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms2_chk = 'X'.

        IF screen-group4 = 'TC2'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC2'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms3_chk = 'X'.

        IF screen-group4 = 'TC3'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC3'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms4_chk = 'X'.

        IF screen-group4 = 'TC4'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC4'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-tc_ms5_chk = 'X'.

        IF screen-group4 = 'TC5'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'TC5'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.

      IF zmm_tms_tc-pbc_stat = 'Y'.

        IF screen-group4 = 'PBC'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'PBC'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
*+18.10.2012 : End

    ELSE.

      IF screen-group2 = 'CHK'.
        screen-input     = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.

*+18.10.2012 : Start
      IF zmm_tms_tc-pbc_stat = 'Y'.

        IF screen-group4 = 'PBC'.
          screen-input     = '1'.
          MODIFY SCREEN.
        ENDIF.

      ELSE.

        IF screen-group4 = 'PBC'.
          screen-input     = '0'.
          MODIFY SCREEN.
        ENDIF.

      ENDIF.
*+18.10.2012 : End

    ENDIF.

*+007 : Start
* Enable fields : 1. Request for tender enquiries from bidders
*                 2. Verification & issue of tender to bidders
* If tender is limited tender
    IF zmm_pur_tender_d_st-bstyp NE 'L'.

      IF screen-group4 = 'LTD'.
        screen-input = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

*+007 : End

*+009 : Start
    IF zmm_tms_general-epc_typ = 'E'.
      IF screen-group1 = 'CPA'.

  """"""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 15.05.2015 for making cpa open  RD1K997136

     if SCREEN-NAME = 'ZMM_TMS_TC-CPA'.
     ELSE.
  "end of addition by lipsy on 15.05.2015 for making cpa open  RD1K997136
  """""""""""""""""""""""""""""""""""""""""""""""""""""

        screen-input    = '0'.

 """""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 15.05.2015 for making cpa open  RD1K997136

    endif.

  "end of addition by lipsy on 15.05.2015 for making cpa open    RD1K997136

 """"""""""""""""""""""""""""""""""""""""""""""""


        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*+009 : End

  ENDLOOP.

ENDMODULE.                 " INIT_SCREEN_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0700
*----------------------------------------------------------------------*
MODULE set_editor OUTPUT.
  PERFORM set_editor USING g_dmode.
ENDMODULE.                 " SET_EDITOR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR_SPFC  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0400
*----------------------------------------------------------------------*
MODULE set_editor_spfc OUTPUT.
  PERFORM set_editor_spfc USING g_dmode_spfc.
ENDMODULE.                 " SET_EDITOR_SPFC  OUTPUT

*+001 : Start
*&---------------------------------------------------------------------*
*&      Module  SET_EDITOR_EPC  OUTPUT
*&---------------------------------------------------------------------*
*   To Set editor in change/display mode : Screen 0800
*----------------------------------------------------------------------*
MODULE set_editor_epc OUTPUT.
  PERFORM set_editor_epc USING g_dmode_epc.
ENDMODULE.                 " SET_EDITOR_EPC  OUTPUT
*+001 : End

*&---------------------------------------------------------------------*
*&      Module  SET_LOI_FIELD  OUTPUT
*&---------------------------------------------------------------------*
* To set screen attribute of LOI fields
*----------------------------------------------------------------------*
MODULE set_loi_field OUTPUT.

  IF zmm_tms_pb-no_pos GT 3.

*    CLEAR : zmm_tms_pb-loi_1_sch_dt,
*            zmm_tms_pb-loi_1_act_dt,
*            zmm_tms_pb-loi_2_sch_dt,
*            zmm_tms_pb-loi_2_act_dt,
*            zmm_tms_pb-loi_3_sch_dt,
*            zmm_tms_pb-loi_3_act_dt.
    CLEAR : zmm_tms_pb-loi_2_sch_dt,
            zmm_tms_pb-loi_2_act_dt.

    CLEAR : g_loi_dt2,g_loi_dt3.

*    g_loi_dt2 = text-005.
    g_loi_dt3 = text-005.
    LOOP AT SCREEN.

*      IF screen-group4 = 'LOI'.
*
*        screen-input = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*
*      ENDIF.
      IF screen-group4 = '002'.

        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.

      ENDIF.
    ENDLOOP.

  ELSE.

*    CLEAR : zmm_tms_pb-loi_1_sch_dt,
*            zmm_tms_pb-loi_1_act_dt,
*            zmm_tms_pb-loi_2_sch_dt,
*            zmm_tms_pb-loi_2_act_dt.
    IF zmm_tms_pb-no_pos EQ 2.
      CLEAR : zmm_tms_pb-loi_3_sch_dt,
              zmm_tms_pb-loi_3_act_dt.
    ENDIF.
    IF zmm_tms_pb-no_pos EQ 1.
      CLEAR : zmm_tms_pb-loi_2_sch_dt,
              zmm_tms_pb-loi_2_act_dt.
      CLEAR : zmm_tms_pb-loi_3_sch_dt,
              zmm_tms_pb-loi_3_act_dt.
    ENDIF.
    g_loi_dt2 = text-003.
    g_loi_dt3 = text-004.

  ENDIF.

ENDMODULE.                 " SET_LOI_FIELD  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DEFAULT_PR_PO_REL_DT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE default_pr_po_rel_dt OUTPUT.

*In table CDPOS, Put  OBJECTCLAS- BANF OBJECTID- PR NumberFNAME- FRGKZ
*Execute.
*Take lowest CHANGENR and put it in table CDHDR in field CHANGENR.
*Also enter OBJECTCLAS- BANF, OBJECTID- PR Number and get UDATE.
*-007 : Start
*  DATA : ist_cdhdr TYPE TABLE OF cdhdr,
*         ist_cdpos TYPE TABLE OF cdpos,
*         ist_cdpos_po TYPE TABLE OF cdpos,
*         wa_cdpos TYPE cdpos,
*         wa_cdhdr TYPE cdhdr,
*         l_ebeln TYPE eban-ebeln.
*
*  CLEAR : ist_cdhdr ,ist_cdpos,l_ebeln.
*  REFRESH : ist_cdhdr ,ist_cdpos.
*-007 : End

*+007 : Start
  DATA : l_ebeln TYPE eban-ebeln.
*+007 : End

  PERFORM read_change_doc USING 'BANF'  zmm_pur_tender_d_st-banfn  'FRGKZ'
        CHANGING zmm_tms_general-pr_ff_rel_dt.

  SELECT EBELN FROM EBAN
 INTO L_EBELN UP TO 1 ROWS WHERE BANFN = ZMM_PUR_TENDER_D_ST-BANFN
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT SINGLE SUBMI from ekko INTO @data(v_SUBMI)
    WHERE ebeln = @l_ebeln.

    IF v_SUBMI Ne zmm_pur_tender_d_st-submi .
    clear l_ebeln.
    ENDIF.


  PERFORM read_change_doc USING 'EINKBELEG'  l_ebeln  'FRGKE'
        CHANGING zmm_tms_general-po_ff_rel_dt.
*  DATA : BEGIN  OF ist_editpos OCCURS 0 .
*          INCLUDE STRUCTURE cdshw .
*  DATA :  user LIKE sy-uname ,
*          date LIKE sy-datum ,
*  END OF ist_editpos .
*  DATA :   i_editpos TYPE TABLE OF cdshw WITH HEADER LINE .
*  DATA : wa_header LIKE cdhdr .
*  objectclass = 'BANF'.
*  objectid = ZMM_PUR_TENDER_D_ST-BANFN.
*  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
*    EXPORTING
*      objectclass = objectclass
*      objectid    = objectid
*      username    = space
*    TABLES
*      i_cdhdr     = tcdhdr
*    EXCEPTIONS
*      OTHERS      = 1.
*
*  IF sy-subrc =  0.
*
*    SORT tcdhdr asCENDING BY changenr.
*    READ TABLE tcdhdr index 1.
**    LOOP AT  tcdhdr .
*    CLEAR : i_editpos, ist_editpos , wa_header .
*    REFRESH i_editpos .
*    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*      EXPORTING
*        changenumber            = tcdhdr-changenr
*      IMPORTING
*        header                  = wa_header
*      TABLES
*        editpos                 = i_editpos
*      EXCEPTIONS
*        no_position_found       = 1
*        wrong_access_to_archive = 2
*        OTHERS                  = 3.
*    IF sy-subrc =  0.
*      LOOP AT i_editpos WHERE fname = 'FRGKZ' .
**          MOVE-CORRESPONDING i_editpos TO ist_editpos.
**          ist_editpos-user = wa_header-username .
**          ist_editpos-date = wa_header-udate .
**          APPEND ist_editpos .
*        ZMM_TMS_GENERAL-PR_FF_REL_DT = ist_cdhdr-udate.
*      ENDLOOP.
*    ENDIF.
**    ENDLOOP .
*  endif.
*  SORT tcdhdr asCENDING BY changenr.
*  READ TABLE tcdhdr index 1.
*data : ist_cdpos TYPE STANDARD TABLE OF cdpos.
*
*    SELECT * FROM cdpos
*          INTO TABLE ist_cdpos
*          WHERE objectclas EQ 'BANF' AND
**                tabname EQ 'EKKO' AND
*                objectid EQ tcdhdr-objectid AND
*                changenr EQ tcdhdr-changenr AND
*                fname EQ ' FRGKZ'.

*  ZMM_TMS_GENERAL-PR_FF_REL_DT = tcdhdr-udate.
*  read table tcdhdr index 1.
*  CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*    EXPORTING
*      changenumber = tcdhdr-changenr
*    TABLES
*      editpos      = lt_cdshw
*    EXCEPTIONS
*      OTHERS       = 1.
*
*  LOOP AT lt_cdshw.
*    IF lt_cdshw-fname EQ 'FRGKZ'.
*
*    endif.
*  endloop.
*  if not ZMM_PUR_TENDER_D_ST-SUBMI is initial.
**  ZMM_TMS_GENERAL-PO_FF_REL_DT
*    select single * from ekko
*    where submi = ZMM_PUR_TENDER_D_ST-SUBMI
*    and ebeln = '4010009865'.
*
*
*    DATA: BEGIN OF ICDHDR OCCURS 50.
*            INCLUDE STRUCTURE CDHDR.
*    DATA: END OF ICDHDR.
*
*    DATA: BEGIN OF ICDSHW OCCURS 50.
*            INCLUDE STRUCTURE CDSHW.
*    DATA: END OF ICDSHW.
*
*    DATA: BEGIN OF ITAB OCCURS 50,
*            BEGIN OF EKKEY,
*              EBELN LIKE EKET-EBELN,
*              EBELP LIKE EKET-EBELP,
*
*              ETENR LIKE EKET-ETENR,
*            END OF EKKEY,
*            CHANGENR LIKE CDHDR-CHANGENR,
*            UDATE    LIKE CDHDR-UDATE,
*            UTIME    LIKE CDHDR-UTIME,
*            USERNAME LIKE CDHDR-USERNAME,
*            CHNGIND  LIKE CDSHW-CHNGIND,
*            FTEXT    LIKE CDSHW-FTEXT,
*            OUTLEN   LIKE CDSHW-OUTLEN,
*            F_OLD    LIKE CDSHW-F_OLD,
*            F_NEW    LIKE CDSHW-F_NEW,
*          END OF ITAB.
*    CLEAR CDHDR.
*    CLEAR CDPOS.
*    CDHDR-OBJECTCLAS = 'EINKBELEG'.
*    CDHDR-OBJECTID   = EKKO-EBELN.
*
*    CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
*      EXPORTING
*        DATE_OF_CHANGE    = CDHDR-UDATE
*        OBJECTCLASS       = CDHDR-OBJECTCLAS
*        OBJECTID          = CDHDR-OBJECTID
*        TIME_OF_CHANGE    = CDHDR-UTIME
*        USERNAME          = CDHDR-USERNAME
*      TABLES
*        I_CDHDR           = ICDHDR
*      EXCEPTIONS
*        NO_POSITION_FOUND = 1
*        OTHERS            = 2.
*
*    CHECK SY-SUBRC EQ 0.
*    DELETE ICDHDR WHERE CHANGE_IND EQ 'I'.
*    CHECK NOT ICDHDR[] IS INITIAL.
*    LOOP AT ICDHDR.
**    CHECK ICDHDR-UDATE IN XUDATE.
**    CHECK ICDHDR-USERNAME IN XNAME.
*      CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
*        EXPORTING
*          CHANGENUMBER      = ICDHDR-CHANGENR
*        IMPORTING
*          HEADER            = CDHDR
*        TABLES
*          EDITPOS           = ICDSHW
*        EXCEPTIONS
*          NO_POSITION_FOUND = 1
*          OTHERS            = 2.
*      CHECK SY-SUBRC EQ 0.
*      LOOP AT ICDSHW.
*        CHECK ICDSHW-TEXT_CASE EQ SPACE.
*        MOVE-CORRESPONDING ICDSHW TO ITAB.
*        MOVE-CORRESPONDING ICDHDR TO ITAB.
*        MOVE ICDSHW-TABKEY+3 TO ITAB-EKKEY.
*        APPEND ITAB.
*      ENDLOOP.
*    ENDLOOP.

*  endif.

ENDMODULE.                 " DEFAULT_PR_PO_REL_DT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PID_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_pid_0150 OUTPUT.

  IF sy-tcode = 'ZMMTMSDISP' AND g_check = 'X'.

    g_ok_code = 'DISP'.

    CLEAR g_check.

    GET PARAMETER ID 'ZTMS' FIELD zmm_pur_tender_d_st-submi.
    g_dynnr = '0300'.
  ENDIF.
ENDMODULE.                 " GET_PID_0150  OUTPUT
**&---------------------------------------------------------------------*
**&      Module  CHECK_VAL_PROC  OUTPUT *Added by CAB_DHIRAJ : Start +003
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE CHECK_VAL_PROC OUTPUT.
*
*   CLEAR : g_tndr_proc,
*          g_tndr_val.
*g_tndr_proc = zmm_pur_tender_d_st-tndr_proc.
*g_tndr_val = zmm_pur_tender_d_st-tndr_val.
*IF NOT zmm_pur_tender_d_st-tndr_proc IS INITIAL AND
*   NOT zmm_pur_tender_d_st-tndr_val IS INITIAL.
*
*    IF zmm_pur_tender_d_st-tndr_val gt 5000000  AND
*      ( zmm_pur_tender_d_st-tndr_proc eq '1' OR
*       zmm_pur_tender_d_st-tndr_proc eq '16' OR
*      zmm_pur_tender_d_st-tndr_proc eq '17' OR
*      zmm_pur_tender_d_st-tndr_proc eq '2' OR
*      zmm_pur_tender_d_st-tndr_proc eq '3' OR
*      zmm_pur_tender_d_st-tndr_proc eq '4' OR
*      zmm_pur_tender_d_st-tndr_proc eq '5' OR
*       zmm_pur_tender_d_st-tndr_proc eq '6' ).
*      LOOP AT SCREEN.
*      IF SCREEN-NAME = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*        SCREEN-REQUIRED = 1.
*        SCREEN-INPUT = 1.
**        SCREEN-ACTIVE = 1.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*     ELSE.
** DATA: ZMM_PUR_TENDER_D_ST-NITDATE.
*
*
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = 'ZMM_PUR_TENDER_D_ST-NITDATE'.
*        SCREEN-REQUIRED = 0.
*        SCREEN-INPUT = 0.
**        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*
*    ENDIF.
**ELSE.
**   LOOP AT SCREEN.
**      IF SCREEN-NAME = ZMM_PUR_TENDER_D_ST-NITDATE.
**        SCREEN-INPUT = 0.
**        MODIFY SCREEN.
**      ENDIF.
**    ENDLOOP.
**ENDIF.
*ENDIF.
*ENDMODULE.                 " CHECK_VAL_PROC  OUTPUT *Added by CAB_DHIRAJ : end +003

*&---------------------------------------------------------------------*
*&      Module  CALC_VARIOUS_DATES  OUTPUT
*&---------------------------------------------------------------------*
* To calculate various dates
*----------------------------------------------------------------------*
MODULE calc_various_dates OUTPUT.

  IF g_ok_code NE 'DISP'.

    IF NOT zmm_pur_tender_d_st-banfn IS INITIAL AND
           zmm_tms_general-pr_rcpt_dt IS INITIAL.

**----------Start of change 30.06.2016 14:21:44 REKHA  -------------------
**   MESSAGE i127(zmm_oth). " Commented
**----------End  of change 30.06.2016 14:21:44 REKHA  -----------------


    ELSE.

      IF NOT zmm_pur_tender_d_st-banfn IS INITIAL AND
         NOT zmm_tms_general-pr_rcpt_dt IS INITIAL.

        PERFORM calc_various_dates USING  zmm_pur_tender_d_st-bstyp
                                          zmm_tms_general-pr_rcpt_dt.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " CALC_VARIOUS_DATES  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTRIB_0700  OUTPUT
*&---------------------------------------------------------------------*
* Set screen attribute : screen 0700
*----------------------------------------------------------------------*
MODULE set_screen_attrib_0700 OUTPUT.

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    LOOP AT SCREEN.

      IF screen-group1 = 'EPC'.
        if ( screen-name = 'ZMM_TMS_PB-PR_BID_OP_ACT_DT' and sy-uname+0(3) = 'CMM' ).
        else.
          screen-input = '0'.
        endif.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ELSE.

    LOOP AT SCREEN.

      IF screen-group1 = 'EPC'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                 " SET_SCREEN_ATTRIB_0700  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_DEFAULT_VAL_0700  OUTPUT
*&---------------------------------------------------------------------*
* To set default value of EPC Type for price bid
*   - EPC Type for Price Bid
*   - Nos. of RFQ maintained
*----------------------------------------------------------------------*
MODULE set_default_val_0700 OUTPUT.

  IF zmm_tms_pb-pr_bid_op_act_dt IS INITIAL.

    zmm_tms_pb-epc_typ_pb = zmm_tms_general-epc_typ.

  ENDIF.

  IF NOT zmm_pur_tender_d_st-banfn IS INITIAL.

    PERFORM get_no_rfq_maint USING    zmm_pur_tender_d_st-banfn
                             CHANGING zmm_tms_pb-no_req.

  ENDIF.

ENDMODULE.                 " SET_DEFAULT_VAL_0700  OUTPUT
