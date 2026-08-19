*--- MAIN PROGRAM: MZMM_NONMOVI01 ---*
***INCLUDE MZMM_NONMOVI01 .
*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: modify table
MODULE tct100_modify INPUT.
  MOVE-CORRESPONDING zmm_nmblkcddt TO g_tct100_wa.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line.
  IF sy-subrc <> 0.
    APPEND g_tct100_wa TO g_tct100_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: mark table
MODULE tct100_mark INPUT.
  IF tct100-line_sel_mode = 1 AND
     g_tct100_wa-flag = 'X'.
    LOOP AT g_tct100_itab INTO g_tct100_wa
      WHERE flag = 'X'.
      g_tct100_wa-flag = ''.
      MODIFY g_tct100_itab
        FROM g_tct100_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tct100_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line
    TRANSPORTING flag.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: process user command
MODULE tct100_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT100'.
*  OK_CODE = sy-ucomm.
    ok_code = ok_code100.
    PERFORM user_ok_tc USING    'TCT100'
                                'G_TCT100_ITAB'
                                'FLAG'
                       CHANGING ok_code.
    CLEAR:ok_code100,ok_code.
  ENDIF.
*  sy-ucomm = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code100.
    WHEN 'BAC' OR 'CAN'.
      PERFORM back_confirm.
      CLEAR ok_code100.
    WHEN 'CREATE'.
*    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                  ID 'ACTVT' FIELD  '01'
*                  ID 'ACTVT' FIELD  '02'.
*
*    If sy-subrc <> 0.
*      message e124(zmm_oth).
*    Endif.
      g_mode = 'CRE'.
      CLEAR ok_code100.
    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR ok_code100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR ok_code100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR ok_code100.
****    WHEN 'RELEASE'.       " displays SUBMIT button in GUI Status. Discarded. SAVE & RELEASE Merged
****      g_mode = 'REL'.
****      CLEAR ok_code100.
    WHEN 'PROCGUIDE'.
      PERFORM SHOW_PROCESS_HELP.
      CLEAR ok_code100.
    WHEN 'SAV'.   " SAV/RELEASE for Creator
      PERFORM save_request.
      if flag_dont_clear = 'X'.
         flag_dont_clear = ''.  " restore the flag
      else.
        PERFORM clear_var.
      endif.
      CLEAR ok_code100.
    WHEN 'CORRES'.
      CLEAR ok_code100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
    WHEN 'REPORT'.
      clear ok_code100.
      SUBMIT ZMM_MAT_NMCODES VIA SELECTION-SCREEN AND RETURN.

**" discarded:  WHEN 'SUBMIT'.   " by requisitioner to L3/L4  "  Save & Release screens now Merged.
**      clear ok_code100.
**      perform validate_reqno.
**      perform submit_request.

   WHEN 'SAVL3L4' OR 'SAVL2' OR 'SAVL1L2' OR 'SAVDIR'.
      perform SAVE_DATA.
      clear ok_code100.
*      PERFORM clear_var.
*      leave to SCREEN 0.

   WHEN 'RELL3L4' OR 'RELL2' OR 'RELL1L2'.       " 'RELL1L2': now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
**** Row Status: clear STATUS_AT_REVERSAL to release control on query-reply communication.
**        if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
**           ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
**        endif.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'REJL3L4' OR  'REJL2' OR 'REJL1L2' OR 'REJDIR'.         "  'REJL1L2': now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'REVL3L4' OR 'REVL2' OR 'REVL1L2' OR 'REVDIR'..           " 'REVL1L2' : now for L1 only .
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
**    Row Status: Save current status as STATUS_AT_REVERSAL to control
*        query-reply communication.
        if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''.
           ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ZMM_NMBLKCDHD_ST-NM_STATUS.
        endif.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'APPRDIR'.
      perform confirm_action.
      if ANS_CONFIRM_ACTION = '1'.
        perform validate_before_rel_rej_rev.
        perform REL_REJ_REV.
        clear ok_code100.
        PERFORM clear_var.
        leave to SCREEN 0.
      else.
        clear ok_code100.
      endif.

   WHEN 'KEEP'.
      PERFORM KEEP_IN_INBOX. "keep the workitem in the inbox, decide later
      PERFORM clear_var.
      leave to SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.
  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
       IMPORTING
            text       =  lt_text_table1
            is_modified = gv_xthead_updkz
       EXCEPTIONS
            error_dp               = 1
            error_cntl_call_method = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            text_stream = lt_text_table1
            itf_text    = tlinetab1.
*
  IF ( g_mode = 'CRE' ) OR
    ( g_mode = 'CHA' ) OR
     ( sy-tcode = 'ZMMNMWF2' ) OR
     ( sy-tcode = 'ZMMNMWFL2' ) OR
     ( sy-tcode = 'ZMMNMWF3' ) OR
     ( sy-tcode = 'ZMMNMWF4' ).


    CALL METHOD gv_text_editor2->get_text_as_stream
         IMPORTING
              text       =  lt_text_table2
              is_modified = gv_xthead_updkz
         EXCEPTIONS
              error_dp               = 1
              error_cntl_call_method = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              text_stream = lt_text_table2
              itf_text    = tlinetab2.
  ENDIF.

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  DATA: okcode105 LIKE sy-ucomm.

  okcode105 = sy-ucomm.

  CASE okcode105.
    WHEN 'OK'.
      CLEAR okcode105.
    WHEN 'CANCEL'.
      REFRESH tlinetab2[].
      CLEAR okcode105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_reqno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_reqno INPUT.
  DATA : l_hd_reqno LIKE zmm_nmblkcdhd,
         l_result type c,
         l_ans TYPE c.
***Intializing**********
  CLEAR:  g_hd_copied,g_tct100_copied,g_result.
  REFRESH: tlinetab1,tlinetab2,lines_cors.
  REFRESH: lt_text_table1,lt_text_table2.

*************************
  IF g_mode = 'CHA'.

    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
           WHERE reqno = zmm_nmblkcdhd_st-reqno.
*** Check for deletion.
    IF l_hd_reqno-lvorm = 'X'.
      MESSAGE i087(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
      LEAVE TO SCREEN 100.
    ENDIF.


*        if zmm_nmblkcdhd_st-ID_CREATOR is INITIAL.
        if l_hd_reqno-ID_CREATOR is INITIAL and l_hd_reqno-REQCPF is NOT INITIAL.
            MESSAGE e237(zmm_oth). "Pls input a request no. created thro' tcode ZMMNMREQ only.
        endif.


    IF l_hd_reqno-id_creator <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-id_creator.
    ENDIF.

** Check: Only 'NEW' request can be changed
    IF l_hd_reqno-nm_status <> 'NEW'.

      MESSAGE e201(zmm_oth) WITH l_hd_reqno-nm_status. "Request is not with the creator(Current Status: &).
    ENDIF.



****  ELSEIF g_mode = 'REL'.
****    CLEAR l_hd_reqno.
****    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
****          WHERE reqno = zmm_nmblkcdhd_st-reqno.
****    IF sy-subrc = 0.
****
******* Check for deletion.
****    IF l_hd_reqno-lvorm = 'X'.
****      MESSAGE i087(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
****      LEAVE TO SCREEN 100.
****    ENDIF.
****
****    IF l_hd_reqno-id_creator <> sy-uname.
****      MESSAGE e096(zmm_oth) WITH l_hd_reqno-id_creator.
****    ENDIF.
****
****
****** Check: Only 'NEW' request can be changed
****    IF l_hd_reqno-nm_status <> 'NEW'.
****      MESSAGE e201(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
****    ENDIF.
****    ENDIF.

  ENDIF.

ENDMODULE.                 " check_reqno  INPUT


********************&---------------------------------------------------------------------*
********************&      Module  check_plant  INPUT
********************&---------------------------------------------------------------------*
********************       text
********************----------------------------------------------------------------------*
*******************MODULE check_plant INPUT.
*******************  DATA : l_werks LIKE t001w-werks.
*******************  IF NOT zmm_nmblkcdhd_st-werks IS INITIAL.
*******************    SELECT SINGLE werks INTO l_werks FROM t001w
*******************           WHERE werks = zmm_nmblkcdhd_st-werks.
*******************    IF sy-subrc <> 0.
*******************      MESSAGE e033(zmm_oth).
*******************    ENDIF.
*******************  ENDIF.
*******************ENDMODULE.                 " check_plant  INPUT


*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_nmblkcdhd_st-tel ).
  IF  zmm_nmblkcdhd_st-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_tel  INPUT


*****************************&---------------------------------------------------------------------*
*****************************&      Module  show_user  INPUT
*****************************&---------------------------------------------------------------------*
*****************************       text
*****************************----------------------------------------------------------------------*
****************************MODULE show_user INPUT.
****************************  DATA: l_user LIKE soud3,
****************************        l_userfld(40) type c.
****************************  Clear: l_user, l_userfld.
****************************
****************************  get cursor field l_userfld.
****************************
****************************  case l_userfld.
****************************    when 'ZMM_NMBLKCDHD_ST-REQCPF'.
****************************      l_user = zmm_nmblkcdhd_st-reqcpf.
****************************    when 'ZMM_NMBLKCDHD_ST-RELBY'.
****************************      l_user = zmm_nmblkcdhd_st-relby.
****************************    when 'ZMM_NMBLKCDHD_ST-APPBY'.
****************************      l_user = zmm_nmblkcdhd_st-appby.
****************************  endcase.
****************************  CALL FUNCTION 'SO_ADDRESS_SHOW'
****************************       EXPORTING
****************************            user                       = l_user
****************************       EXCEPTIONS
****************************            parameter_error            = 1
****************************            user_not_exist             = 2
****************************            x_error                    = 3
****************************            operation_no_authorization = 4
****************************            OTHERS                     = 5.
****************************
****************************  IF sy-subrc <> 0.
***************************** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*****************************         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
****************************  ENDIF.
****************************
****************************ENDMODULE.                 " show_user  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.
ENDMODULE.                 " USER_COMMAND_0103  INPUT

AT USER-COMMAND.
  DATA : l_okcode103 LIKE sy-ucomm.
  CLEAR l_okcode103.

  l_okcode103 = sy-ucomm.

    CASE l_okcode103.
      WHEN 'AGREE'.
        g_rel = 'Y'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
      WHEN 'DISAGREE'.
        g_rel = 'N'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
    ENDCASE.


*&---------------------------------------------------------------------*
*&      Module  get_details  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_details INPUT.
  DATA: l_objek LIKE ausp-objek,
        l100_blkdt LIKE zmm_nmblkcddt.

*  SELECT SINGLE objek INTO l_objek FROM ausp
*         WHERE objek = zmm_nmblkcddt-matcode
*         AND   atinn = ( SELECT atinn FROM cabn
*                                WHERE atnam = 'Z_ONGC_REASON' )
*         AND   klart = '001'
*         AND   atwrt = 'NM'.

SELECT SINGLE ZZMBPR FROM MARA INTO l_objek
  WHERE MATNR = zmm_nmblkcddt-matcode
  AND ZZMBPR = 'NM'.


  IF sy-subrc <> 0.
    MESSAGE e221(zmm_oth).
  ENDIF.
** mat description
  SELECT MAKTX
 FROM MAKT INTO ZMM_NMBLKCDDT-MATDESC UP TO 1 ROWS WHERE MATNR = ZMM_NMBLKCDDT-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
** mat unit
  SELECT SINGLE meins
    FROM mara
      INTO zmm_nmblkcddt-uom
        WHERE matnr = zmm_nmblkcddt-matcode.

***Check for the same code in other requests (hold)


ENDMODULE.                 " get_details  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  if OK_CODE100 = 'CLK_WERKS' or OK_CODE100 = 'CLK_EKGRP' . " Plant or Purchase Grp has been changes
** Issue: when plant and purchase grp change, old values in appr chain (Drop-down)
** remains on the screen. clear it.
    FLAG_CLEAR_OLD_APPR_CHAIN = 'X'.
    clear OK_CODE100.
  elseif OK_CODE100 = 'CLK_DECISION'.
    FLAG_CLEAR_OLD_STATUS = 'X'.
    clear OK_CODE100.
  else.
    PERFORM confirm_exit.
  endif.
ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_code INPUT.
  DATA : l_matcode LIKE zmm_matblock_dt-matcode.

  l_matcode = zmm_nmblkcddt-matcode.
  SET PARAMETER ID 'MAT' FIELD l_matcode.
  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " show_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
***MODULE SHOW_NAME_CREATOR INPUT.
***
***PERFORM SHOW_NAME_CREATOR.
***
***
***ENDMODULE.                 " SHOW_NAME  INPUT


*&---------------------------------------------------------------------*
*&      Module  LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_PLANT INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'AGR_NAME'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDHD_ST-WERKS'
      value_org       = 'S'
    tables
      value_tab       = ist_plant
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDHD_ST-WERKS = ist_return_tab-fieldval.

ENDMODULE.                 " LOV_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_PGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_PGRP INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'EKGRP'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDHD_ST-EKGRP'
      value_org       = 'S'
    tables
      value_tab       = ist_pgrp
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDHD_ST-EKGRP = ist_return_tab-fieldval.
ENDMODULE.                 " LOV_PGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_ICON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_ICON INPUT.

**    Row Status : set icon as per decision
*type-pools: icon.
*@0A@ - Red light
*@08@ - Green light
*@09@ - Yellow light
*ICON_GREEN_LIGHT/ICON_YELLOW_LIGHT/ICON_RED_LIGHT

  IF ZMM_NMBLKCDDT-DECISION = 'REJECT'.
    write ICON_RED_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'ACCEPT'..
    write ICON_GREEN_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'QUERY'.
    write ICON_YELLOW_LIGHT as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = 'REPLY'.
    write ICON_ENVELOPE_CLOSED as ICON to ZMM_NMBLKCDDT-ICON.
  ELSEIF ZMM_NMBLKCDDT-DECISION = '' .
    write ICON_LED_INACTIVE as ICON to ZMM_NMBLKCDDT-ICON.
  ENDIF.


ENDMODULE.                 " SET_ICON  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_STATUS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS INPUT.
** moved: now at the time of saving of details
*  IF ZMM_NMBLKCDDT-DECISION = 'REJECT'.
*     ZMM_NMBLKCDDT-STATUS = 'REJECTED'.
*  ELSEIF ZMM_NMBLKCDDT-DECISION = 'ACCEPT'.
*     ZMM_NMBLKCDDT-STATUS = 'ACCEPTED'.
*  ELSEIF ZMM_NMBLKCDDT-DECISION = ''.
*     ZMM_NMBLKCDDT-STATUS = ''.
*  ENDIF.



ENDMODULE.                 " SET_STATUS  INPUT

*******&---------------------------------------------------------------------*
*******&      Module  LOV_L2  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_L2 INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_L2 type TABLE OF ty_user.
******
******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
******
******   select A~uname
******     into CORRESPONDING FIELDS OF TABLE IST_L2
******       from ( agr_users as A
******              INNER JOIN  agr_users as B on B~uname = A~uname )
******       where A~agr_name = L_ROLE1
******             and B~agr_name = 'D:MM_PUR_PO_APPROVE_L2'
******             and A~from_dat <=   sy-datum
******             and A~to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L2'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_L2
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_L2 = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
******
*******&---------------------------------------------------------------------*
*******&      Module  LOV_L1  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_L1 INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_L1 type TABLE OF ty_user.
******
******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
******
******   select A~uname
******     into CORRESPONDING FIELDS OF TABLE IST_L1
******       from ( agr_users as A
******              INNER JOIN  agr_users as B on B~uname = A~uname )
******       where A~agr_name = L_ROLE1
******             and B~agr_name = 'D:MM_PUR_PO_APPROVE_L1'
******             and A~from_dat <=   sy-datum
******             and A~to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_L1'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_L1
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_L1 = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
******
*******&---------------------------------------------------------------------*
*******&      Module  LOV_DIR  INPUT
*******&---------------------------------------------------------------------*
*******       text
*******----------------------------------------------------------------------*
******MODULE LOV_DIR INPUT.
******refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
******  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .
******
******clear: L_ROLE1 ,
******       L_ROLE2 ,
******       L_ROLE3 .
******
******data: IST_DIR type TABLE OF ty_user.
******
*******CONCATENATE 'MM_INDENT_' ZMM_NMBLKCDHD_ST-BUKRS '_PLANT_' ZMM_NMBLKCDHD_ST-WERKS INTO L_ROLE1.
*******   select A~uname
*******     into CORRESPONDING FIELDS OF TABLE IST_DIR
*******       from ( agr_users as A
*******              INNER JOIN  agr_users as B on B~uname = A~uname )
*******       where A~agr_name = L_ROLE1
*******             and B~agr_name = 'D:MM_SRV_IND_APPROVE_DI'
*******             and A~from_dat <=   sy-datum
*******             and A~to_dat >=  sy-datum.
******
******   select uname
******     into CORRESPONDING FIELDS OF TABLE IST_DIR
******       from agr_users
******       where agr_name = 'D:MM_SRV_IND_APPROVE_DI'
******             and from_dat <=   sy-datum
******             and to_dat >=  sy-datum.
******
******  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
******    exporting
******      retfield        = 'uname'
******      dynpprog        = sy-cprog
******      dynpnr          = sy-dynnr
******      dynprofield     = 'ZMM_NMBLKCDHD_ST-ID_DIRECTOR'
******      value_org       = 'S'
******    tables
******      value_tab       = IST_DIR
******      field_tab       = ist_field
******      return_tab      = ist_return_tab
******      dynpfld_mapping = ist_dynpfld_mapping
******    exceptions
******      parameter_error = 1
******      no_values_found = 2
******      others          = 3.
******  if sy-subrc <> 0.
******    message id sy-msgid type sy-msgty number sy-msgno
******            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
******  endif.
******
******  ZMM_NMBLKCDHD_ST-ID_DIRECTOR = ist_return_tab-fieldval.
******
******
******
******ENDMODULE.                 " LOV_L2  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_RES_NM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_RES_NM INPUT.
refresh: ist_field, ist_return_tab, ist_dynpfld_mapping.
  clear: ist_dynpfld_mapping, ist_field, ist_return_tab .

data: IST_ZMM_NM_REASONS type TABLE OF ZMM_NM_REASONS.

   select RES_NM
     into CORRESPONDING FIELDS OF TABLE IST_ZMM_NM_REASONS
       from ZMM_NM_REASONS.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = 'RES_NM'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'ZMM_NMBLKCDDT-RES_NM'
      value_org       = 'S'
    tables
      value_tab       = IST_ZMM_NM_REASONS
      field_tab       = ist_field
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_dynpfld_mapping
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  ZMM_NMBLKCDDT-RES_NM = ist_return_tab-fieldval.


ENDMODULE.                 " LOV_RES_NM  INPUT


*&---------------------------------------------------------------------*
*&      Module  LOV_INCHARGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_INCHARGE INPUT.

    PERFORM LOV_INCHARGE .

ENDMODULE.                 " LOV_INCHARGE  INPUT


MODULE LOV_L2 INPUT.

    PERFORM LOV_L2 .

ENDMODULE.                 " LOV_L2 INPUT

MODULE LOV_L1 INPUT.

    PERFORM LOV_L1 .

ENDMODULE.                 " LOV_L1  INPUT

MODULE LOV_DIR INPUT.

    PERFORM LOV_DIR .

ENDMODULE.                 " LOV_DIR  INPUT

*&---------------------------------------------------------------------*
*&      Module  CLEAR_OLD_VRM_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_OLD_APPR_CHAIN INPUT.

  PERFORM CLEAR_OLD_APPR_CHAIN.

ENDMODULE.                 " CLEAR_OLD_APPR_CHAIN  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_PLANT_STK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_PLANT_STK INPUT.
  PERFORM SHOW_PLANT_STK.

ENDMODULE.                 " SHOW_PLANT_STK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_ONGC_STK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_ONGC_STK INPUT.
  PERFORM SHOW_ONGC_STK.

ENDMODULE.                 " SHOW_ONGC_STK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_PLANT_CONS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_PLANT_CONS INPUT.
  PERFORM SHOW_PLANT_CONS.
ENDMODULE.                 " SHOW_PLANT_CONS  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_ONGC_CONS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_ONGC_CONS INPUT.
  PERFORM SHOW_ONGC_CONS.
ENDMODULE.                 " SHOW_ONGC_CONS  INPUT
*&---------------------------------------------------------------------*
*&      Module  LOV_DECISION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LOV_DECISION INPUT.
** make Lov as per the level and STATUS_AT_REVERSAL

 DATA: g_t_id TYPE vrm_id,
       g_t_list TYPE vrm_values,
       g_t_value LIKE LINE OF g_t_list.


 Types: begin of ty_decision ,
         Decision type ZNM_DECISION ,
         end of ty_decision .
 data: ist_decision type table of ty_decision,
       wa_decision type ty_decision.

 Refresh: ist_decision ,g_t_list.
 CLEAR: wa_decision, g_t_list.

 IF sy-tcode = 'ZMMNMREQ'.
   wa_decision-decision = 'REJECT'.
   append wa_decision to ist_decision.
   wa_decision-decision = 'REPLY'.
   append wa_decision to ist_decision.
  ELSEIF  sy-tcode = 'ZMMNMWF2'
       or sy-tcode = 'ZMMNMWF3'
          or sy-tcode = 'ZMMNMWFL2'.

    if ZMM_NMBLKCDHD_ST-STATUS_AT_REVERSAL = ''. " fresh request
      wa_decision-decision = 'ACCEPT'.
      append wa_decision to ist_decision.
    else.                                        " reverted request
      wa_decision-decision = 'REPLY'.
      append wa_decision to ist_decision.
    endif.
      wa_decision-decision = 'REJECT'.
      append wa_decision to ist_decision.
      wa_decision-decision = 'QUERY'.
      append wa_decision to ist_decision.

  ELSEIF sy-tcode = 'ZMMNMWF4'.
    wa_decision-decision = 'ACCEPT'.
    append wa_decision to ist_decision.
    wa_decision-decision = 'REJECT'.
    append wa_decision to ist_decision.
    wa_decision-decision = 'QUERY'.
    append wa_decision to ist_decision.
  endif.

  Loop at ist_decision into wa_decision .
    CLEAR g_t_value.
    g_t_value-key  = wa_decision-decision.
    APPEND g_t_value TO g_t_list.
  Endloop.

  g_t_id = 'ZMM_NMBLKCDDT-DECISION'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = g_t_id
      values = g_t_list.

ENDMODULE.                 " LOV_DECISION  INPUT
