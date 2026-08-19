*--- MAIN PROGRAM: SAPMZOVL_JV_CC_PAI ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
*  PERFORM sub_exit.
*  PERFORM sub_btn_press.

  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.


  IF ok_code = 'CHNG'.
    lfct_9000 = ok_code.
  ENDIF.

  IF ok_code = 'DELE'.
    lfct_9000 = ok_code.

    gwa_jv_cc-deleted_on = sy-datum.
    gwa_jv_cc-del_ind = 'X'.
    MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING del_ind deleted_on.

    gwa_clog-ccreqno  = gwa_jv_cc-ccreqno.
    gwa_clog-mandt    = sy-mandt.
    gwa_clog-ent_date = sy-datum.
    gwa_clog-ent_time = sy-uzeit.
    gwa_clog-username = gwa_jv_cc-prj_cord.
    IF gwa_jv_cc-prj_cord IS NOT INITIAL.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*      SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
      SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
    ENDIF.
    gwa_clog-name_text = gv_name1.
    MODIFY zjv_cc_comm_log FROM gwa_clog.
    PERFORM del_mail.
    CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5, gwa_clog.
    LEAVE TO TRANSACTION 'ZJVCC'.
  ENDIF.
  IF ts_9020-activetab NE 'TS_9020_DISP'.
    IF lfct_9000 IS INITIAL AND gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-subrc = 0 AND r1 = 'X' AND sy-uname = gwa_jv_cc-prj_cord.
      ELSE.
        MESSAGE 'Ýou are not authorized for this option' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    IF ok_code = ' ' AND lfct_9000 NE 'CHNG'.
      SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    ENDIF.
  ENDIF.

*************************************************************************
   CLEAR CHA_WF.
  IF ok_code = '/CHA_PM'.
     CHA_WF = '/CHA_PM'.
  ELSEIF ok_code = '/CHA_PF'.
     CHA_WF = '/CHA_PF'.
  ELSEIF ok_code = '/CHA_PFO'.
     CHA_WF = '/CHA_PFO'.
  ELSEIF ok_code = '/CHA_RP'.
     CHA_WF = '/CHA_RP'.
  ENDIF.
************************************

  IF ok_code = '/UP_WF'.
    SELECT PRJ_MAN FROM ZJV_CASH_CALL INTO @DATA(UP_PM) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PRJ_CORD = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-prj_man = UP_PM.

      ELSE.
        UPDATE zjv_cash_call SET PRJ_MAN = gwa_jv_cc-prj_man
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND PRJ_CORD = sy-uname.
      ENDIF.
  ENDIF.
*************************************************************************

  CLEAR: ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_VNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_vname INPUT.
  TYPES : BEGIN OF ty_vname,
            vname TYPE t8jv-vname,
            vtext TYPE t8jvt-vtext,
          END OF ty_vname.

  DATA: lt_read1 TYPE STANDARD TABLE OF dynpread,
        ls_read1 TYPE dynpread.
  DATA : lit_vname  TYPE TABLE OF ty_vname,
         lit_vname1 TYPE TABLE OF ty_vname,
         lit_t8j9a  TYPE TABLE OF t8j9a.

  DATA : lwa_vname TYPE ty_vname,
         lwa_t8j9a TYPE t8j9a.

  DATA : lv_bukrs1 TYPE bukrs.
  REFRESH: lit_vname[], lit_vname1[].
  ls_read1-fieldname = 'GWA_JV_CC-BUKRS'.
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

  CLEAR: ls_read1.
  READ TABLE lt_read1 INTO ls_read1 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs1 = ls_read1-fieldvalue.
  ENDIF.

*  SELECT DISTINCT vname FROM t8jv
*     INTO CORRESPONDING FIELDS OF TABLE lit_vname WHERE
*    bukrs = lv_bukrs1.
*  IF sy-subrc EQ 0.
*    SORT lit_vname.
*  ENDIF.
  .
*  IF sy-subrc EQ 0.

  SELECT v~vname t~vtext FROM t8jv AS v INNER JOIN t8jvt AS t ON v~bukrs = t~bukrs
    AND v~vname = t~vname
   INTO CORRESPONDING FIELDS OF TABLE lit_vname WHERE
    v~bukrs = lv_bukrs1
    AND v~vtype EQ '2'.
  IF sy-subrc EQ 0.
    SORT lit_vname.
    DELETE ADJACENT DUPLICATES FROM lit_vname COMPARING vname.
  ENDIF.
*  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-VNAME'
      value_org       = 'S'
    TABLES
      value_tab       = lit_vname
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.

MODULE mod_approver INPUT.
  TYPES: BEGIN OF ty_user,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user.
  DATA: lit_user   TYPE STANDARD TABLE OF ty_user,
        lit_return TYPE STANDARD TABLE OF ddshretval,
        lwa_return TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-FC_APPROVER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user
      return_tab      = lit_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return INTO lwa_return.
*      gv_fc_approver = lwa_return-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver1 INPUT.
  TYPES: BEGIN OF ty_user1,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user1.
  DATA: lit_user1   TYPE STANDARD TABLE OF ty_user1,
        lit_return1 TYPE STANDARD TABLE OF ddshretval,
        lwa_return1 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user1.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-RP_APPROVER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user1
      return_tab      = lit_return1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return1 INTO lwa_return1.
*      gv_rp_approver = lwa_return1-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver2 INPUT.
  TYPES: BEGIN OF ty_user2,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user2.
  DATA: lit_user2   TYPE STANDARD TABLE OF ty_user2,
        lit_return2 TYPE STANDARD TABLE OF ddshretval,
        lwa_return2 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user2.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PRJ_MAN'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user2
      return_tab      = lit_return2
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return2 INTO lwa_return2.
*      gv_jv_acc = lwa_return2-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver3 INPUT.
  TYPES: BEGIN OF ty_user3,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user3.
  DATA: lit_user3   TYPE STANDARD TABLE OF ty_user3,
        lit_return3 TYPE STANDARD TABLE OF ddshretval,
        lwa_return3 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user3.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CB_ACC1'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user3
      return_tab      = lit_return3
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return3 INTO lwa_return3.
*      gv_cb_acc = lwa_return3-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver4 INPUT.
  TYPES: BEGIN OF ty_user4,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user4.
  DATA: lit_user4   TYPE STANDARD TABLE OF ty_user4,
        lit_return4 TYPE STANDARD TABLE OF ddshretval,
        lwa_return4 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user4.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PF_OFFICER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user4
      return_tab      = lit_return4
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return4 INTO lwa_return4.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.

MODULE mod_approver5 INPUT.
  TYPES: BEGIN OF ty_user5,
           bname     TYPE bname,
           name_last TYPE name_text,
         END OF ty_user5.
  DATA: lit_user5   TYPE STANDARD TABLE OF ty_user5,
        lit_return5 TYPE STANDARD TABLE OF ddshretval,
        lwa_return5 TYPE ddshretval.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user5.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-TREASURY1'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user5
      return_tab      = lit_return5
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return5 INTO lwa_return5.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_WAERS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_waers INPUT.
  TYPES : BEGIN OF ty_t8jc2,
            fundcur TYPE jv_fundcur,
          END OF ty_t8jc2.

  DATA: lt_read3 TYPE STANDARD TABLE OF dynpread,
        ls_read3 TYPE dynpread.
  DATA : lit_fundcur TYPE TABLE OF ty_t8jc2,
         lit_t8jg    TYPE TABLE OF t8jg.

  DATA : lwa_t8jg  TYPE t8jg.

  DATA : lv_bukrs3 TYPE bukrs,
         lv_vname3 TYPE jv_name,
         lv_egrup3 TYPE jv_egroup.

  ls_read3-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read3 TO lt_read3.
  CLEAR : ls_read3.

  ls_read3-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read3 TO lt_read3.
  CLEAR : ls_read3.

*  ls_read3-fieldname = 'GWA_JV_CC-BUKRS'.
*  APPEND ls_read3 TO lt_read3.
*  CLEAR : ls_read3.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read3
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

  CLEAR: ls_read3.
  READ TABLE lt_read3 INTO ls_read3 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs3 = ls_read3-fieldvalue.
  ENDIF.

  CLEAR: ls_read3.
  READ TABLE lt_read3 INTO ls_read3 WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc = 0.
    lv_vname3 = ls_read3-fieldvalue.
  ENDIF.

  CLEAR: ls_read3.

  SELECT DISTINCT fundcur FROM t8jc2
     INTO TABLE lit_fundcur WHERE
    bukrs = lv_bukrs3 AND
    vname = lv_vname3."" AND
*    egrup = lv_egrup3.
  IF sy-subrc EQ 0.
    SORT lit_fundcur.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FUNDCUR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-WAERS'
      value_org       = 'S'
    TABLES
      value_tab       = lit_fundcur
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_PARTNER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_prctr INPUT.
  TYPES : BEGIN OF ty_cepc,
            prctr TYPE prctr,
            ktext TYPE ktext,
          END OF ty_cepc.

  DATA: lt_read TYPE STANDARD TABLE OF dynpread,
        ls_read TYPE dynpread.
  DATA : it_prctr TYPE TABLE OF ty_cepc.
  DATA : lv_bukrs TYPE bukrs,
         lv_vname TYPE jv_name.

  ls_read-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read TO lt_read.
  CLEAR : ls_read.

  ls_read-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read TO lt_read.
  CLEAR : ls_read.

*  ls_read-fieldname = 'GV_ETYPE'.
*  APPEND ls_read TO lt_read.
*  CLEAR : ls_read.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read
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

  CLEAR: ls_read.
  READ TABLE lt_read INTO ls_read WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs = ls_read-fieldvalue.
  ENDIF.

  READ TABLE lt_read INTO ls_read WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc EQ 0.
    lv_vname = ls_read-fieldvalue.
  ENDIF.

  CLEAR: ls_read.

  SELECT c~prctr t~ktext FROM cepc AS c INNER JOIN cepct AS t ON
    c~prctr EQ t~prctr
    AND c~kokrs EQ t~kokrs
    INTO TABLE it_prctr
    WHERE c~kokrs = 'OVL'.
*    AND vname = lv_vname.

  SORT it_prctr.
  DELETE ADJACENT DUPLICATES FROM it_prctr COMPARING prctr.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PRCTR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-PRCTR'
      value_org       = 'S'
    TABLES
      value_tab       = it_prctr
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_EGRUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_egrup INPUT.
  TYPES : BEGIN OF ty_t8jg,
            egrup TYPE jv_egroup,
          END OF ty_t8jg.

  DATA: lt_read2 TYPE STANDARD TABLE OF dynpread,
        ls_read2 TYPE dynpread.
  DATA : it_egrup TYPE TABLE OF ty_t8jg.

  DATA : lv_bukrs2 TYPE bukrs,
         lv_vname2 TYPE jv_name.

  ls_read2-fieldname = 'GWA_JV_CC-BUKRS'.
  APPEND ls_read2 TO lt_read2.
  CLEAR : ls_read2.

  ls_read2-fieldname = 'GWA_JV_CC-VNAME'.
  APPEND ls_read2 TO lt_read2.
  CLEAR : ls_read2.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      translate_to_upper   = 'X'
    TABLES
      dynpfields           = lt_read2
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

  CLEAR: ls_read2.
  READ TABLE lt_read2 INTO ls_read2 WITH KEY fieldname = 'GWA_JV_CC-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs2 = ls_read2-fieldvalue.
  ENDIF.

  READ TABLE lt_read2 INTO ls_read2 WITH KEY fieldname = 'GWA_JV_CC-VNAME'.
  IF sy-subrc EQ 0.
    lv_vname2 = ls_read2-fieldvalue.
  ENDIF.

  SELECT DISTINCT egrup FROM t8jg INTO TABLE it_egrup WHERE
    bukrs = lv_bukrs2 AND
    vname = lv_vname2.
  IF sy-subrc EQ 0.
    SORT : it_egrup[].
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EGRUP'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-EGRUP'
      value_org       = 'S'
    TABLES
      value_tab       = it_egrup
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9010 INPUT.
*  CLEAR ok_code.
  IF r1 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project Coordinator'.
    flag_disp = 'X'.
    CALL SCREEN 9020.
  ELSEIF r2 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project Manager'.
    CALL SCREEN 9030.
  ELSEIF r3 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Incharge Project Finance'.
    CALL SCREEN 9030.
  ELSEIF r4 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Project FI Officer / Junior Accounting Pool'.
    CALL SCREEN 9030.
  ELSEIF r5 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Regional President'.
    CALL SCREEN 9030.
  ELSEIF r6 = 'X'.
    CALL TRANSACTION 'ZJVCCREP'.
  ELSEIF r7 = 'X'.   "added by ss on 16.4.21
    CALL SCREEN 9040.
**    BOC by ss on 23.8.21
  ELSEIF r8 = 'X'.
    SET TITLEBAR 'ZT_DYNA' WITH 'JV Cash Call Management - Reviewer'.
    CALL SCREEN 9030.
**    EOC by ss on 23.8.21
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EX  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ex INPUT.
  IF ok_code = 'BACK' OR ok_code = 'CANC' OR ok_code = 'EXIT'.
    IF sy-dynnr = '9030' OR sy-dynnr = '9020'
          OR sy-dynnr = '9040'.   "added by ss on 16.4.21
      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3,
             gv_name4, gv_name5, gv_name6, gwa_clog, flag_data,
      wa_bank , zfi_bank_payee-bankn.

      LEAVE TO SCREEN 9010.
    ELSE.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'TS_9020'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE ts_9020_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_ts_9020-tab1.
      g_ts_9020-pressed_tab = c_ts_9020-tab1.
    WHEN c_ts_9020-tab2.
      g_ts_9020-pressed_tab = c_ts_9020-tab2.
    WHEN c_ts_9020-tab3.
      g_ts_9020-pressed_tab = c_ts_9020-tab3.
    WHEN c_ts_9020-tab4.
      g_ts_9020-pressed_tab = c_ts_9020-tab4.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9020 INPUT.
  DATA: v_gjahr TYPE gjahr,
        num(5)  TYPE c  VALUE '00000'.
*        num1(5) TYPE c.
  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.

  IF ok_code = 'SAVE'.
**BOC by ss on 20.9.21**
    IF gwa_jv_cc-partn IS NOT INITIAL.
      SELECT SINGLE * FROM lfb1 INTO @DATA(ls_tab) WHERE lifnr EQ @gwa_jv_cc-partn AND bukrs EQ @gwa_jv_cc-bukrs.
      IF sy-subrc NE 0.
        MESSAGE 'The mentioned partner is not created as Vendor.' TYPE 'E'.
      ENDIF.
    ENDIF.
**  EOC by ss on 20.9.21**



    IF  ts_9020-activetab = c_ts_9020-tab1.
      CALL FUNCTION 'GET_CURRENT_YEAR'
        EXPORTING
          bukrs = gwa_jv_cc-bukrs
          date  = sy-datum
        IMPORTING
*         CURRM =
          curry = gwa_jv_cc-gjahr
*         PREVM =
*         PREVY =
        .

      SELECT ccreqno FROM zjv_cash_call INTO TABLE @DATA(it_ccreq) WHERE gjahr = @gwa_jv_cc-gjahr
*                                                                   AND BUKRS = @GWA_JV_CC-BUKRS   " Commented by ss on 5.8.21
                                                                   AND vname = @gwa_jv_cc-vname
        ORDER BY ccreqno DESCENDING.

      IF it_ccreq IS NOT INITIAL.
*        SORT it_ccreq DESCENDING.

        READ TABLE it_ccreq INTO DATA(wa_ccreq) INDEX 1.
        num = wa_ccreq-ccreqno+10(5).
        num = num + 1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = num
          IMPORTING
            output = num.

      ELSE.
        num = '00001'.
      ENDIF.
*       num1 = num.
      CONCATENATE gwa_jv_cc-vname gwa_jv_cc-gjahr num INTO gwa_jv_cc-ccreqno.
      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = gwa_jv_cc-status_pm = gwa_jv_cc-status_rp = 'PENDING'.
      gwa_jv_cc-status_rev = 'PENDING'.  " added by ss on 24.8.21
      gwa_jv_cc-created_on = sy-datum.
      gwa_jv_cc-mandt = sy-mandt.

      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_cord.
      gwa_clog-name_text = gv_name1.
      MODIFY  zjv_cc_comm_log FROM gwa_clog.

      PERFORM crea_mail USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
      PERFORM trea_mail USING gv_name5 gwa_jv_cc-ccreqno.
      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5, gwa_clog, gv_name6 .
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF ts_9020-activetab = c_ts_9020-tab3 AND lfct_9000 = 'CHNG'.

      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = gwa_jv_cc-status_pm = gwa_jv_cc-status_rp = 'PENDING'.
      gwa_jv_cc-status_rev = 'PENDING'.  " added by ss on 24.8.21
      gwa_jv_cc-changed_on = sy-datum.

      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_cord.
      gwa_clog-name_text = gv_name1.
      GWA_CLOG-BNK_DTLS  = GWA_CLOG-BNK_DTLS.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

*      SELECT * FROM zjv_cc_comm_log INTO @DATA(UPD_BNK) WHERE ccreqno
       UPDATE zjv_cc_comm_log SET BNK_DTLS  = GWA_CLOG-BNK_DTLS WHERE ccreqno = gwa_jv_cc-ccreqno.

      PERFORM chng_mail USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
      PERFORM chng_mail_pm USING gwa_jv_cc-prj_man gv_name1 gwa_jv_cc-ccreqno.
*      CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2, gv_name3, gv_name4, gv_name5.
      CLEAR: lfct_9000.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSE.

      MESSAGE 'Not allowed in display mode' TYPE 'E'.
    ENDIF.
  ENDIF.

  DATA ls_sodocchgi1 TYPE sodocchgi1.
  DATA  g_att_files LIKE TABLE OF swotobjid.
*  DATA g_att_files_wa LIKE swotobjid.
  DATA FILE_DETAILS TYPE  SOOD5.
  DATA  g_att_files2 LIKE TABLE OF swotobjid.
  CLEAR g_att_files_wa.
  REFRESH g_att_files.

  IF ok_code = 'ATTACH'.
    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      APPEND g_att_files_wa TO g_att_files.

                               .
      CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
          attachment_data     = ls_sodocchgi1
          attachment_type     = 'DOC'
        TABLES
          application_objects = g_att_files.


    ENDIF.
  ENDIF.

  IF ok_code = 'LOG'.


    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.


    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.
**************************************************************************************************************************
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.
**************************************************************************************************************************

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSE.
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.

      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.

      IF gt_otf_hr IS NOT INITIAL.
        CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
          TABLES
            otf_table = gt_otf_hr-otfdata[].
      ENDIF.

    ENDIF.
  ENDIF.


  IF ok_code = 'LIST'.
    CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
    g_att_files_wa-objtype = 'ATT'.
    g_att_files_wa-objkey = gwa_jv_cc-ccreqno.


                                                   .
    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa.


  ENDIF.

  CLEAR: ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9030 INPUT.

  IF  lt_month[] IS INITIAL.
    SELECT * FROM t247 INTO TABLE lt_month
    WHERE spras = sy-langu.
  ENDIF.
  READ TABLE lt_month INTO ls_month WITH KEY mnr = gwa_jv_cc-opp_month+0(2).
  IF sy-subrc = 0.
    month = ls_month-ktx.
  ENDIF.

  IF ok_code = 'APPR'.
    IF r2 = 'X'.

      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      MOVE: g_att_files_wa-objkey  TO ls_object-instid,
            g_att_files_wa-objtype TO ls_object-typeid,
            g_att_files_wa-logsys  TO ls_logsys,
            ls_catid_bo        TO ls_object-catid.

      TRY.

          CALL METHOD cl_binary_relation=>read_links_of_binrel
            EXPORTING
              is_object   = ls_object
              ip_logsys   = ls_logsys
              ip_relation = ls_relation
*             ip_role     = ls_role
*             ip_propnam  =
*             ip_no_buffer = SPACE
            IMPORTING
              et_links    = lt_links
*             et_roles    =
            .
        CATCH cx_obl_parameter_error .
        CATCH cx_obl_internal_error .
        CATCH cx_obl_model_error .
      ENDTRY.

      IF lt_links[] IS INITIAL.
        MESSAGE 'Attachment Missing' TYPE 'E'.
      ENDIF.

*  ENDIF.
      gwa_jv_cc-status_pm = 'APPROVED'.
      gwa_jv_cc-status_rev = 'APPROVED'.   " ( added by ss on 24.8.21) - NOTE
      MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING status_pm.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_man.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail USING gwa_jv_cc-fc_approver gv_name2 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

*****      BOC  by ss on 18.6.21
    ELSEIF r3 = 'X'.    " Incharge project finance
      gwa_jv_cc-status_fc = gwa_jv_cc-status_pfo = 'APPROVED'.
*      IF gv_name6 is INITIAL.
*          GWA_JV_CC-STATUS_REV = ''.
*      ENDIF.

      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_fc status_pfo.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM appr_mail_fc USING gwa_jv_cc-rp_approver gv_name3 gwa_jv_cc-ccreqno.
*      PERFORM TREA_MAIL USING GV_NAME5 GWA_JV_CC-CCREQNO.
      LEAVE TO TRANSACTION 'ZJVCC'.


    ELSEIF r5 = 'X'.

      PERFORM post_doc.
      IF gwa_jv_cc-belnr IS NOT INITIAL.
*        PERFORM APPR_MAIL_RP USING GV_NAME5 GWA_JV_CC-CCREQNO.
*        PERFORM CNB_MAIL USING GV_NAME5 GWA_JV_CC-CCREQNO.

        gwa_jv_cc-status_rp = 'APPROVED'.

        MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_rp.

        gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
        gwa_clog-mandt = sy-mandt.
        gwa_clog-ent_date = sy-datum.
        gwa_clog-ent_time = sy-uzeit.
        gwa_clog-username = gwa_jv_cc-rp_approver.
        gwa_clog-name_text = gv_name5.
        MODIFY zjv_cc_comm_log FROM gwa_clog.

        PERFORM appr_mail_rp USING gv_name5 gwa_jv_cc-ccreqno.
        PERFORM cnb_mail USING gv_name5 gwa_jv_cc-ccreqno.

      ENDIF.
      LEAVE TO TRANSACTION 'ZJVCC'.

*          BOC by ss on 24.8.21
    ELSEIF r8 = 'X'.

      gwa_jv_cc-status_rev = 'APPROVED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username =  gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name6.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM appr_mail_rev USING gwa_jv_cc-fc_approver
                                  gv_name3
                                  gwa_jv_cc-ccreqno.
*      PERFORM TREA_MAIL USING GV_NAME6 GWA_JV_CC-CCREQNO.
      LEAVE TO TRANSACTION 'ZJVCC'.
*      EOC by ss on 24.8.21

    ENDIF.
  ENDIF.

  IF ok_code = 'REJT'.
    IF r2 = 'X'.
      gwa_jv_cc-status_pm = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc .""TRANSPORTING status_pm.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-prj_man.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name2 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r3 = 'X'.
      gwa_jv_cc-status_fc = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_fc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name3 gwa_jv_cc-ccreqno.
*    ELSEIF r4 = 'X'.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r5 = 'X'.
      gwa_jv_cc-status_rp = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc."" TRANSPORTING status_rp.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-rp_approver.
      gwa_clog-name_text = gv_name5.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name5 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

**      Added by ss on 24.8.21
    ELSEIF r8 = 'X'.
      gwa_jv_cc-status_rev = 'REJECTED'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.
      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name6.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM rej_mail USING gwa_jv_cc-prj_cord gv_name6 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
**      EOC by ss on 24.8.2021
    ENDIF.
  ENDIF.

  IF ok_code = 'FPFO'.
    IF r3 = 'X'.

******       Added by ss on 18.6.21
      gwa_jv_cc-status_pfo = 'FORWARD'.   "When PFO SUBMIT the req.
      MODIFY zjv_cash_call FROM gwa_jv_cc .
**********      End by ss on 18.6.21

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-fc_approver.
      gwa_clog-name_text = gv_name3.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail1 USING gwa_jv_cc-pf_officer gv_name3 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.
    ELSEIF r4 = 'X'.

******       Added by ss on 18.6.21
      gwa_jv_cc-status_pfo = 'APPROVED'.   "When PFO SUBMIT the req.
      gwa_jv_cc-status_fc = 'PENDING'.   "When PFO SUBMIT the req.
      MODIFY zjv_cash_call FROM gwa_jv_cc .
**********      End by ss on 18.6.21


      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-pf_officer.
      gwa_clog-name_text = gv_name4.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail2 USING gwa_jv_cc-fc_approver gv_name4 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

**   Added by ss on 24.8.21
    ELSEIF r2 = 'X'.


      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2)
      gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.

      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      MOVE: g_att_files_wa-objkey  TO ls_object-instid,
            g_att_files_wa-objtype TO ls_object-typeid,
            g_att_files_wa-logsys  TO ls_logsys,
            ls_catid_bo        TO ls_object-catid.

      TRY.

          CALL METHOD cl_binary_relation=>read_links_of_binrel
            EXPORTING
              is_object   = ls_object
              ip_logsys   = ls_logsys
              ip_relation = ls_relation
*             ip_role     = ls_role
*             ip_propnam  =
*             ip_no_buffer = SPACE
            IMPORTING
              et_links    = lt_links
*             et_roles    =
            .
        CATCH cx_obl_parameter_error .
        CATCH cx_obl_internal_error .
        CATCH cx_obl_model_error .
      ENDTRY.

      IF lt_links[] IS INITIAL.
        MESSAGE 'Attachment Missing' TYPE 'E'.
      ENDIF.



      gwa_jv_cc-status_pm = 'FORWARD'.
      gwa_jv_cc-status_fc = 'PENDING'.
      MODIFY zjv_cash_call FROM gwa_jv_cc.

      gwa_clog-ccreqno = gwa_jv_cc-ccreqno.
      gwa_clog-mandt = sy-mandt.
      gwa_clog-ent_date = sy-datum.
      gwa_clog-ent_time = sy-uzeit.
      gwa_clog-username = gwa_jv_cc-reviewer.
      gwa_clog-name_text = gv_name2.
      MODIFY zjv_cc_comm_log FROM gwa_clog.

      PERFORM fw_mail_rev USING gwa_jv_cc-reviewer gv_name6 gwa_jv_cc-ccreqno.
      LEAVE TO TRANSACTION 'ZJVCC'.

    ENDIF.


  ENDIF.


  IF ok_code = 'ATTACH'.
    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
      g_att_files_wa-objtype = 'ATT'.
      g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

      APPEND g_att_files_wa TO g_att_files.

      CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
        EXPORTING
          attachment_data     = ls_sodocchgi1
          attachment_type     = 'DOC'
        TABLES
          application_objects = g_att_files.

    ENDIF.
  ENDIF.

  IF ok_code = 'LOG'.
    DATA : v_fm1 TYPE rs38l_fnam.
*
*    DATA: is_control_param  TYPE ssfctrlop,
*          is_composer_param TYPE ssfcompop,
*          is_job_info       TYPE ssfcrescl,
*          v_objectid        TYPE cdhdr-objectid.
*
*    DATA: iwa_ssfcrescl TYPE ssfcrescl,
*          iw_spoolids   TYPE rspoid,
*          iw_ssfctrlop  TYPE ssfctrlop,
*          lwa_ssfcompop TYPE ssfcompop,
**     gt_otf       TYPE ssfcrescl,
*          lwa_line      TYPE itcoo,
*          it_otf_hr     TYPE ssfcrescl,
*          it_otf        TYPE ssfcrescl.


*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.

    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.


    IF gwa_jv_cc-ccreqno IS NOT INITIAL.
      SELECT * FROM zjv_cc_comm_log INTO TABLE git_clog WHERE ccreqno = gwa_jv_cc-ccreqno.

************************************************************************************************************************
        CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*       g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
        g_att_files_wa-objtype = 'ATT'.
        g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

        APPEND g_att_files_wa TO g_att_files2.

         IF g_att_files2 IS NOT INITIAL.
               PERFORM GET_FILE .
         ENDIF.
************************************************************************************************************************

      IF gwa_jv_cc-vtype = '1'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COMM'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm1
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ELSEIF gwa_jv_cc-vtype = '2'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZJV_CASH_CALL_COML'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = v_fm1
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

      CALL FUNCTION v_fm1
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          wa_req             = gwa_jv_cc
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
        TABLES
          it_log             = git_clog
          file_details1      = file_details1
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.

      IF gt_otf_hr IS NOT INITIAL.
        CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
          TABLES
            otf_table = gt_otf_hr-otfdata[].
      ENDIF.

    ENDIF.
  ENDIF.

  IF ok_code IS INITIAL AND gwa_jv_cc-ccreqno IS NOT INITIAL.
    SELECT * FROM ZJV_CASH_CALL INTO GWA_JV_CC UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      IF r2 = 'X' AND sy-uname = gwa_jv_cc-prj_man.
        flag_data = 'X'.

      ELSEIF r3 = 'X' AND sy-uname = gwa_jv_cc-fc_approver.
        flag_data = 'X'.

      ELSEIF r4 = 'X' AND sy-uname = gwa_jv_cc-pf_officer.
        flag_data = 'X'.

      ELSEIF r5 = 'X' AND sy-uname = gwa_jv_cc-rp_approver.
        flag_data = 'X'.
**               Added by ss on 24.8.21
      ELSEIF r8 = 'X' AND sy-uname = gwa_jv_cc-reviewer.
        flag_data = 'X'.

      ELSE.
*        MESSAGE 'You are not authorized for this option' TYPE 'I' DISPLAY LIKE 'E'.
*        LEAVE TO SCREEN 9010.
      ENDIF.

    ENDIF.
  ENDIF.

  IF ok_code = 'LIST'.
    CONCATENATE gwa_jv_cc-ccreqno+0(6) gwa_jv_cc-ccreqno+8(2) gwa_jv_cc-ccreqno+13(2) INTO g_att_files_wa-logsys.
*  g_att_files_wa-logsys = gwa_jv_cc-ccreqno.
    g_att_files_wa-objtype = 'ATT'.
    g_att_files_wa-objkey = gwa_jv_cc-ccreqno.

    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
      EXPORTING
        application_object = g_att_files_wa.

  ENDIF.
*******************************************************************
   CLEAR CHA_WF.
  IF ok_code = '/CHA_PM'.
     CHA_WF = '/CHA_PM'.
  ELSEIF ok_code = '/CHA_PF'.
     CHA_WF = '/CHA_PF'.
  ELSEIF ok_code = '/CHA_PFO'.
     CHA_WF = '/CHA_PFO'.
  ELSEIF ok_code = '/CHA_RP'.
     CHA_WF = '/CHA_RP'.
  ENDIF.

************************************

  IF ok_code = '/UP_WF'.
    IF save_wf = 'UP_PF'.
      SELECT FC_APPROVER FROM ZJV_CASH_CALL INTO @DATA(UP_PF) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PRJ_MAN = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-fc_approver = UP_PF.

      ELSE.
        UPDATE zjv_cash_call SET fc_approver = gwa_jv_cc-fc_approver
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND PRJ_MAN = sy-uname.
      ENDIF.

    ELSEIF save_wf = 'UP_PFO'.
      SELECT PF_OFFICER FROM ZJV_CASH_CALL INTO @DATA(UP_PFO) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND FC_APPROVER = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-pf_officer = UP_PFO.

      ELSE.
        UPDATE zjv_cash_call SET pf_officer = gwa_jv_cc-pf_officer
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND fc_approver = sy-uname.
      ENDIF.

    ELSEIF save_wf = 'UP_RP'.
      SELECT RP_APPROVER FROM ZJV_CASH_CALL INTO @DATA(UP_RP) UP TO 1 ROWS
 WHERE CCREQNO = @GWA_JV_CC-CCREQNO AND PF_OFFICER = @SY-UNAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF GWA_JV_CC-rp_approver = UP_RP.

      ELSE.
        UPDATE zjv_cash_call SET rp_approver = gwa_jv_cc-rp_approver
                             WHERE CCREQNO = gwa_jv_cc-ccreqno
                             AND pf_officer = sy-uname.
      ENDIF.

   ENDIF.
  ENDIF.
*************************************************************************

  CLEAR ok_code.

ENDMODULE.


MODULE mod_attach INPUT.
  DATA: p_filename TYPE ibipparms-path.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'GV_ATTACH'
    IMPORTING
      file_name     = p_filename.
  IF p_filename IS NOT INITIAL.
*    gv_attach = p_filename.
  ENDIF.
***-  Begin of change ABAPUSER01 Dated 2/19/2019
***- Declaration of a table with Solix type 255 character length
*  DATA LT_MAILHEX TYPE TABLE OF SOLIX.
***- Calling function module to upload GUI in an internal table
*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                      = GV_ATTACH
*     FILETYPE                      = 'BIN'
*    tables
*      data_tab                      = LT_MAILHEX
*   EXCEPTIONS
*     FILE_OPEN_ERROR               = 1
*     FILE_READ_ERROR               = 2
*     NO_BATCH                      = 3
*     GUI_REFUSE_FILETRANSFER       = 4
*     INVALID_TYPE                  = 5
*     NO_AUTHORITY                  = 6
*     UNKNOWN_ERROR                 = 7
*     BAD_DATA_FORMAT               = 8
*     HEADER_NOT_ALLOWED            = 9
*     SEPARATOR_NOT_ALLOWED         = 10
*     HEADER_TOO_LONG               = 11
*     UNKNOWN_DP_ERROR              = 12
*     ACCESS_DENIED                 = 13
*     DP_OUT_OF_MEMORY              = 14
*     DISK_FULL                     = 15
*     DP_TIMEOUT                    = 16
*     OTHERS                        = 17.
***- If no file uploaded in system then triggering-error message            .
*  IF sy-subrc is not INITIAL .
*  MESSAGE i999(zz) WITH 'Error in reading file for upload'(002).
** Implement suitable error handling here
*  ENDIF.
***-End of change ABAPUSER01 Dated 2/19/2019
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9000 INPUT.
  TYPES: BEGIN OF ty_reqno,
           ccreqno TYPE zccreqno,
           bukrs   TYPE bukrs,
         END OF ty_reqno.
  DATA: it_reqno TYPE STANDARD TABLE OF ty_reqno,
        it_ret   TYPE STANDARD TABLE OF ddshretval,
        wa_ret   TYPE ddshretval.
  SELECT ccreqno bukrs FROM zjv_cash_call
    INTO TABLE it_reqno.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CCREQNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CCREQNO'
      value_org       = 'S'
    TABLES
      value_tab       = it_reqno
      return_tab      = it_ret
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT it_ret INTO wa_ret.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9030 INPUT.
  TYPES: BEGIN OF ty_ccreqno,
           ccreqno TYPE zccreqno,
           status  TYPE zccstatus,
         END OF ty_ccreqno.
  DATA: it_ccreqno TYPE STANDARD TABLE OF ty_ccreqno,
        it_retn    TYPE STANDARD TABLE OF ddshretval,
        wa_retn    TYPE ddshretval.

  IF r2 = 'X'.
    SELECT ccreqno status_pm FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_pm = 'PENDING'.

  ELSEIF r3 = 'X'.
    SELECT ccreqno status_fc FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_fc = 'PENDING'.

  ELSEIF r4 = 'X'.
    SELECT ccreqno status_pfo FROM zjv_cash_call
      INTO TABLE it_ccreqno WHERE status_pfo = 'FORWARD'.

  ELSEIF r5 = 'X'.
    SELECT ccreqno status_rp FROM zjv_cash_call
  INTO TABLE it_ccreqno WHERE status_rp = 'PENDING'.

**      BOC by ss on 25.8.21
**      F4 data fetch for Reviewer
  ELSEIF r8 = 'X'.
    SELECT ccreqno status_rev FROM zjv_cash_call
    INTO TABLE it_ccreqno WHERE status_rev = 'PENDING'.
**   EOC by ss on 25.8.21
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CCREQNO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-CCREQNO'
      value_org       = 'S'
    TABLES
      value_tab       = it_ccreqno
      return_tab      = it_retn
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT it_retn INTO wa_retn.
*      gv_pf_officer = lwa_return4-fieldval.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VAL_VNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_vname INPUT.
  IF gwa_jv_cc-bukrs IS NOT INITIAL AND gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vname FROM t8jv
     INTO @DATA(v_vname) WHERE
      vname = @gwa_jv_cc-vname AND
      bukrs = @gwa_jv_cc-bukrs .
*      AND operator NE 'JV-OVL'.
    IF sy-subrc NE 0.
      MESSAGE 'Invalid entry, please enter correct data' TYPE 'E'.
    ENDIF.

    SELECT SINGLE vtype FROM t8jv
       INTO gwa_jv_cc-vtype WHERE
      vname = gwa_jv_cc-vname AND
      bukrs = gwa_jv_cc-bukrs.
*      AND operator NE 'JV-OVL'.

    IF gwa_jv_cc-vtype EQ '2'.
      SELECT SINGLE operator FROM t8jv
       INTO gwa_jv_cc-partn WHERE
      vname = gwa_jv_cc-vname AND
      bukrs = gwa_jv_cc-bukrs AND
      vtype = gwa_jv_cc-vtype.

    ELSE.
      gwa_jv_cc-partn = 'JV-OVL'.
*      operator NE 'JV-OVL',.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_data INPUT.

  SELECT SINGLE bname FROM usr01
    INTO @DATA(v_bname) WHERE bname = @gwa_jv_cc-prj_cord.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-prj_cord.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-prj_man.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-prj_man.
*   call SCREEN 9000.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-fc_approver.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-fc_approver.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-rp_approver.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-rp_approver.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-treasury1.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-treasury1.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.
  IF  gwa_jv_cc-treasury2 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-treasury2.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-treasury2.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.
  IF  gwa_jv_cc-treasury3 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-treasury3.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc) WITH gwa_jv_cc-treasury3.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.

  SELECT SINGLE bname FROM usr01
 INTO v_bname WHERE bname = gwa_jv_cc-cb_acc1.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc) WITH gwa_jv_cc-cb_acc1.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.
  IF  gwa_jv_cc-cb_acc2 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-cb_acc2.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-cb_acc2.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.
  IF  gwa_jv_cc-cb_acc3 IS NOT INITIAL.
    SELECT SINGLE bname FROM usr01
   INTO v_bname WHERE bname = gwa_jv_cc-cb_acc3.
    IF sy-subrc NE 0.
      MESSAGE e001(zfi_cc) WITH gwa_jv_cc-cb_acc3.
*   LEAVE TO SCREEN sy-dynnr.
    ENDIF.
  ENDIF.

  SELECT SINGLE bname FROM usr01
INTO v_bname WHERE bname = gwa_jv_cc-pf_officer.
  IF sy-subrc NE 0.
    MESSAGE e001(zfi_cc)  WITH gwa_jv_cc-pf_officer.
*   LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  IF gwa_jv_cc-recoff = '2' AND gwa_clog-nrcomm IS INITIAL.
    MESSAGE e002(zfi_cc).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  DEL_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHNG_MAIL_PM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_JV_CC_PRJ_MAN  text
*      -->P_GV_NAME1  text
*      -->P_GWA_JV_CC_CCREQNO  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9050 INPUT.
  IF ok_code = 'SAVE'.

*    TABLES: ZFI_BANK_DETAILS.
***    wa_bank- = I_PAYEE
*
*    DATA: BNUM(7) TYPE C.
*
*    SELECT MAX( BANKL ) FROM ZFI_BANK_DETAILS INTO @DATA(GS_BANK).
*
*    IF GS_BANK IS NOT INITIAL.
**    wa_bank-bankl = gs_bank.
*      BNUM = GS_BANK+3(7) + 1.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          INPUT  = BNUM
*        IMPORTING
*          OUTPUT = BNUM.
*
*      CONCATENATE 'BEN' BNUM INTO WA_BANK-BANKL.
**    wa_bank-bankl = wa_bank-bankl+3(7) + 1.
*    ELSE.
*      WA_BANK-BANKL = 'BEN0000001'.
*    ENDIF.
*        ORDER BY CCREQNO DESCENDING.
    SELECT SINGLE * FROM zfi_bank_details INTO @DATA(gs_bank)
      WHERE bankn = @wa_bank-bankn.

    IF sy-subrc EQ 0.
      MESSAGE 'Bank account already exits' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.
***  Added by ss on 23.9.2021
*    SELECT max( sno ) from ZFI_BANK_DETAILS INTO lv_no.
*
*    lv_no = lv_no + 1.
*    wa_bank-sno = lv_no.
*    CLEAR lv_no.
***  EOC by ss on 23.9.2021

    INSERT zfi_bank_details FROM wa_bank.
    IF sy-subrc = 0.
      MESSAGE 'Beneficiary added successfully' TYPE 'I'.
    ENDIF.
    CLEAR: wa_bank.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9040 INPUT.

*CLEAR: ZFI_BANK_PAYEE-BANKN, WA_BANK, GWA_JV_CC-VALUE_DATE.

  ok_code = sy-ucomm.
  IF ok_code = 'UPDTBANK'.
    CALL SCREEN 9050.

  ELSEIF ok_code = 'DELETE'.
    CALL SCREEN 9060.

  ELSEIF ok_code = 'SAVE'.
    SELECT * FROM ZJV_CASH_CALL INTO @DATA(GS_CC) UP TO 1 ROWS
 WHERE CCREQNO EQ @GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    IF gs_cc-status_rp NE 'APPROVED'.
      MESSAGE 'Cash Call Request not approved by RP' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

    IF gwa_jv_cc-ccreqno IS NOT INITIAL AND zfi_bank_payee-bankn IS NOT INITIAL
      AND wa_bank-bankn IS NOT INITIAL AND gwa_jv_cc-value_date IS NOT INITIAL .



*      SELECT SINGLE refno FROM zjv_cash_call
*                          INTO @DATA(lv_num)
*                          WHERE ccreqno EQ @gwa_jv_cc-ccreqno.
*
*      IF lv_num IS INITIAL.
*
***   BOC by ss on 23.9.2021
*        CALL FUNCTION 'NUMBER_GET_NEXT'
*          EXPORTING
*            nr_range_nr = g_nrrangenr
*            object      = g_nrobj1
*          IMPORTING
*            number      = l_docno.
*
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.
*
*
*        gwa_jv_cc-refno1 = l_docno.
*
*        UPDATE zjv_cash_call SET pbankn = zfi_bank_payee-bankn
*                                 bbankn = wa_bank-bankn
*                                 value_date = gwa_jv_cc-value_date
*                                 refno =  gwa_jv_cc-refno1
*                           WHERE ccreqno = gwa_jv_cc-ccreqno.
*      ELSE.
***    EOC by ss on 23.9.2021

        UPDATE zjv_cash_call SET pbankn = zfi_bank_payee-bankn
                                   bbankn = wa_bank-bankn
                                   value_date = gwa_jv_cc-value_date
                             WHERE ccreqno = gwa_jv_cc-ccreqno.
*      ENDIF.
      IF sy-subrc = 0.
        MESSAGE 'Record update successfully' TYPE 'I'.
        LEAVE TO TRANSACTION 'ZJVCC'.
      ENDIF.
    ELSE.

      MESSAGE 'Fill in all the required fields' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

  ELSEIF ok_code = 'FORMS'.
    DATA : v_msg TYPE string.
    CLEAR : gs_cc.
    SELECT * FROM ZJV_CASH_CALL INTO GS_CC UP TO 1 ROWS
 WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.


    IF gs_cc-bbankn IS INITIAL OR gs_cc-pbankn IS INITIAL .
      MESSAGE 'Please link Cash call Request with Bank account' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

** added by ss on 16.7.21
    IF gs_cc-value_date IS INITIAL.
      MESSAGE 'Kindly enter the value date' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.
**   EOC by ss on 16.7.21

    IF gs_cc-status_rp NE 'APPROVED'.
      MESSAGE 'Cash Call Request not approved by RP' TYPE 'I'.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

**    BOC on 13.5
    SELECT SINGLE * FROM zfi_bank_payee INTO @DATA(wa_payee)
                          WHERE bankn EQ @gs_cc-pbankn.

    IF wa_payee-currency NE gs_cc-waers.

*if GS_CC-WAERS is INITIAL.




      SELECTION-SCREEN BEGIN OF SCREEN 600 TITLE act AS WINDOW.
      PARAMETERS: lv_dmbtr TYPE dmbtr.
      SELECTION-SCREEN END OF SCREEN 600.


      CONCATENATE 'Amount in' wa_payee-currency INTO act SEPARATED BY space.

      IF gs_cc-dmbtr IS NOT INITIAL.
        lv_dmbtr = gs_cc-dmbtr.
      ENDIF.

*INITIALIZATION.
*    %_lv_dmbtr_%_app_%-text = 'Carrier ID'.

      CALL SELECTION-SCREEN '0600' STARTING AT 10 10.

      IF lv_dmbtr IS INITIAL.
        CONCATENATE 'Enter Amount in' wa_payee-currency INTO v_msg SEPARATED BY space.
        MESSAGE v_msg TYPE 'E'.
      ENDIF.

      UPDATE zjv_cash_call SET dmbtr = lv_dmbtr
                           WHERE ccreqno
                           EQ gwa_jv_cc-ccreqno.

      CLEAR: lv_dmbtr, v_msg.

*ENDIF.
    ENDIF.
**  EOC on 13.5

    CLEAR :  gt_otf_hr-otfdata[],gt_otf,gt_otf_hr-otfdata.
*   **    *  *      *--control parameters
    lw_ssfctrlop-getotf    = 'X'. " To get the OTF data
    lw_ssfctrlop-preview   = 'X'." To get the preview of the form
    lw_ssfctrlop-no_dialog = 'X'." To hide the print priview
*      *screen
    lw_ssfctrlop-device    = 'PRINTER'.

*--output options
    wa_ssfcompop-tdpageslct  = space.         "all pages
    wa_ssfcompop-tdcopies    = 1.             "one copy
    wa_ssfcompop-tddest      = 'LP01'.        "name of printer
    wa_ssfcompop-tdnoprev    = ' '.           "preview
    wa_ssfcompop-tdcover     = space.         "no cover page
    wa_ssfcompop-tdsuffix1   = 'LP01'.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZCC_AUTHORITY_LETTER'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = v_fm
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION v_fm
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        control_parameters = lw_ssfctrlop
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
        output_options     = wa_ssfcompop
        user_settings      = ' '
        ccreqno            = gwa_jv_cc-ccreqno
      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
        job_output_info    = gt_otf
*       JOB_OUTPUT_OPTIONS =
*        TABLES
*       IT_LOG             = GIT_CLOG
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].
    CLEAR gt_otf.


    IF wa_payee-country EQ 'IN' AND  wa_bank-bank_country NE 'IN'.   "added 12.5
*    IF GS_CC-PBANKN NE '10604101'.               " commented on 12.5
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZCC_FORM_A2'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          fm_name            = v_fm
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


      CALL FUNCTION v_fm
        EXPORTING
*         ARCHIVE_INDEX      =
*         ARCHIVE_INDEX_TAB  =
*         ARCHIVE_PARAMETERS =
          control_parameters = lw_ssfctrlop
*         MAIL_APPL_OBJ      =
*         MAIL_RECIPIENT     =
*         MAIL_SENDER        =
          output_options     = wa_ssfcompop
          user_settings      = ' '
          ccreqno            = gwa_jv_cc-ccreqno
        IMPORTING
*         DOCUMENT_OUTPUT_INFO       =
          job_output_info    = gt_otf
*         JOB_OUTPUT_OPTIONS =
*        TABLES
*         IT_LOG             = GIT_CLOG
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

      CLEAR : gt_otf.
    ENDIF.

*IF   WA_BANK-BANK_COUNTRY EQ 'IN'.  " added by ss on 16.7.2021
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZCC_FEMA_FORM'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = v_fm
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION v_fm
      EXPORTING
*       ARCHIVE_INDEX      =
*       ARCHIVE_INDEX_TAB  =
*       ARCHIVE_PARAMETERS =
        control_parameters = lw_ssfctrlop
*       MAIL_APPL_OBJ      =
*       MAIL_RECIPIENT     =
*       MAIL_SENDER        =
        output_options     = wa_ssfcompop
        user_settings      = ' '
*       CCREQNO            = GWA_JV_CC-CCREQNO
      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
        job_output_info    = gt_otf
*       JOB_OUTPUT_OPTIONS =
*        TABLES
*       IT_LOG             = GIT_CLOG
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    APPEND LINES OF gt_otf-otfdata[] TO  gt_otf_hr-otfdata[].

    CLEAR : gt_otf.

*endif.   " added by ss on 16.7.21

    IF gt_otf_hr IS NOT INITIAL.
      CALL FUNCTION 'HR_IT_DISPLAY_WITH_PDF'
* EXPORTING
*   IV_PDF          =
        TABLES
          otf_table = gt_otf_hr-otfdata[].
    ENDIF.
  ENDIF.
*  ENDIF.

  CLEAR: ok_code.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_REQNO_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_reqno_9040 INPUT.
  TYPES: BEGIN OF ty_req,
           ccreqno   TYPE zjv_cash_call-ccreqno,
           status_rp TYPE zjv_cash_call-status_pm,
         END OF ty_req.

  DATA: it_tab TYPE STANDARD TABLE OF ty_req.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT ccreqno status_rp FROM zjv_cash_call INTO TABLE it_tab
    WHERE status_rp = 'APPROVED'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'CCREQNO'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'GWA_JV_CC-CCREQNO'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_tab
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_BANKL_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_bankl_9040 INPUT.
  TYPES: BEGIN OF ty_req1,
*           BANKL TYPE ZFI_BANK_DETAILS-BANKL,
           bankn        TYPE zfi_bank_details-bankn,
           name1        TYPE zfi_bank_details-name1,
           banka        TYPE zfi_bank_details-banka,
           bank_addr    TYPE zfi_bank_details-bank_addr,
           bank_country TYPE zfi_bank_details-bank_country,  " added on 12.5
         END OF ty_req1.


  DATA: it_tab1 TYPE STANDARD TABLE OF ty_req1.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT * FROM zfi_bank_details INTO CORRESPONDING FIELDS OF TABLE it_tab1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'BANKN'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'WA_BANK-BANKN'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_tab1
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_BANK_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bank_data INPUT.
  DATA: v_bankn TYPE bankn.

** BOC on 6.5.21 by ss
  IF gwa_jv_cc-ccreqno IS NOT INITIAL.
    SELECT * FROM ZJV_CASH_CALL INTO @DATA(WA_TAB) UP TO 1 ROWS
 WHERE CCREQNO EQ @GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc EQ 0 AND wa_tab-pbankn IS NOT INITIAL
                     AND wa_tab-bbankn IS NOT INITIAL .
      zfi_bank_payee-bankn = wa_tab-pbankn.
      wa_bank-bankn        = wa_tab-bbankn.
      gwa_jv_cc-value_date = wa_tab-value_date.

*      SHIFT wa_tab-refno LEFT DELETING LEADING '0'. "added by ss on 23.9.2021
*      gwa_jv_cc-refno1      = wa_tab-refno.  "added by ss on 23.9.2021

    ENDIF.
    CLEAR wa_tab.
  ENDIF.
**  EOC on 6.5.21.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_9050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  IF ok_code = 'BACK'.
    CLEAR wa_bank.
    CALL SCREEN 9040.

  ELSEIF ok_code = 'CANC'.
    LEAVE TO TRANSACTION 'ZJVCC'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9060  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9060 INPUT.
  IF ok_code = 'DELETE'.
    DELETE FROM zfi_bank_details WHERE bankn = wa_bank-bankn.
    IF sy-subrc = 0.

      MESSAGE 'The record is deleted' TYPE 'I'.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_BANKN_PAYEE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_bankn_payee INPUT.
  TYPES: BEGIN OF ty_payee,
           bankn    TYPE zfi_bank_payee-bankn,
           name1    TYPE zfi_bank_payee-name1,
           street   TYPE zfi_bank_payee-street,
           city1    TYPE zfi_bank_payee-city1,
           country  TYPE zfi_bank_payee-country,  " added on 12.5
           currency TYPE zfi_bank_payee-currency,
         END OF ty_payee.



  DATA: it_payee TYPE STANDARD TABLE OF ty_payee.
*        IT_RETN    TYPE STANDARD TABLE OF DDSHRETVAL,
*        WA_RETN    TYPE DDSHRETVAL.


  SELECT * FROM zfi_bank_payee INTO CORRESPONDING FIELDS OF TABLE it_payee.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'BANKN'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'ZFI_BANK_PAYEE-BANKN'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*     IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_payee
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*     EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  COUNTRY_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*


MODULE country_code INPUT.
  SELECT land1, landx FROM t005t INTO TABLE @DATA(it_ccode).

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield    = 'LAND1'
*     PVALKEY     = ' '
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'WA_BANK-BANK_ADDR_ALPHA2'
*     STEPL       = 0
*     WINDOW_TITLE           =
*     VALUE       = ' '
      value_org   = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY     = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     CALLBACK_METHOD        =
*     MARK_TAB    =
*        IMPORTING
*     USER_RESET  =
    TABLES
      value_tab   = it_ccode
*     FIELD_TAB   =
*     RETURN_TAB  =
*     DYNPFLD_MAPPING        =
*        EXCEPTIONS
*     PARAMETER_ERROR        = 1
*     NO_VALUES_FOUND        = 2
*     OTHERS      = 3
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PAYEE_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_payee_data INPUT.
  v_bankn = wa_bank-bankn.
  CLEAR wa_bank.
  IF v_bankn IS NOT INITIAL.
    SELECT SINGLE * FROM zfi_bank_details INTO wa_bank WHERE bankn =
v_bankn.
  ENDIF.
  CLEAR v_bankn.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DATE_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE date_validate INPUT.


  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date = gwa_jv_cc-value_date.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_APPROVER6  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_approver6 INPUT.

*  TYPES: BEGIN OF TY_USER,
*           BNAME     TYPE BNAME,
*           NAME_LAST TYPE NAME_TEXT,
*         END OF TY_USER.
  DATA: lit_user6   TYPE STANDARD TABLE OF ty_user,
        lit_return6 TYPE STANDARD TABLE OF ddshretval.
*        LWA_RETURN TYPE DDSHRETVAL.
  SELECT bname name_last FROM user_addr
    INTO TABLE lit_user6.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GWA_JV_CC-REVIEWER'
      value_org       = 'S'
    TABLES
      value_tab       = lit_user6
      return_tab      = lit_return6
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.
    LOOP AT lit_return6 INTO lwa_return.
*      gv_fc_approver = lwa_return-fieldval.
    ENDLOOP.
  ENDIF.
*    CLear lwa_return.

ENDMODULE.
