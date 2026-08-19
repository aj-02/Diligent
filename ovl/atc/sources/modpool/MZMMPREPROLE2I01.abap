*--- MAIN PROGRAM: MZMMPREPROLE2I01 ---*

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  okcode = sy-ucomm.

  Case okcode.

    When 'BAC' OR 'CAN'.

      perform bac_confirm.
*      refresh control 'TABCTRL100' from screen '0100'.
      clear okcode.
      leave program.

    When 'CREATE'.

      g_mode = 'CRE'.
      clear okcode.

    When 'CHANGE'.

      g_mode = 'CHA'.
      clear okcode.

    When 'DISPLAY'.

      g_mode = 'DIS'.
      clear okcode.

    When 'DELETE'.

      g_mode = 'DEL'.
      clear okcode.

    when 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      clear okcode.

    when 'RELEASE'.

      g_mode = 'REL'.
      clear okcode.

    when 'APPROVE'.

      g_mode = 'APR'.
      clear okcode.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
module TABCTRL100_modify input.

  if ZMM_PREP_ROLEREI-rej_fl is initial.
    clear : ZMM_PREP_ROLEREI-rej_id, ZMM_PREP_ROLEREI-rej_date.
  endif.

  move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.

  select single * from zmm_prep_rolegrp where role_type =
                  ZMM_PREP_ROLEREI-role_name.

  if ZMM_PREP_ROLEREI-rej_fl = ''.

    if sy-subrc = 0 and old_ok_code = 'APPROVE'.
      if zmm_prep_rolegrp-approver1 = g_user
         or zmm_prep_rolegrp-approver2 = g_user
         or zmm_prep_rolegrp-approver3 = g_user.
      else.

        if okcode_100 = 'SAV'.
          if err_flg <> 'X'.
            err_flg = 'X'.
            clear : sy-ucomm, okcode_100.
          endif.
          message e047(zhelp) with zmm_prep_rolegrp-role_type.
        endif.
      endif.
    endif.

  endif.

  if not g_TABCTRL100_wa-role_name is initial.
    select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
    if sy-subrc = 0.
      g_TABCTRL100_wa-role_desc = zmm_prep_roledes-brief_desc.
    endif.
  endif.

  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line.

  if sy-subrc <> 0.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if g_cursor_line = sy-stepl and okcode_100 = 'COPY'.
    append g_TABCTRL100_wa to g_TABCTRL100_itab.
  endif.

  if g_cursor_line = sy-stepl and okcode_100 = 'TABCTRL100_DELE' and
        g_TABCTRL100_wa-rej_fl <> ''.
    g_rej_fl = 'X'.
  endif.

endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
module TABCTRL100_mark input.
  if TABCTRL100-line_sel_mode = 1 and
     g_TABCTRL100_wa-flag = 'X'.
    loop at g_TABCTRL100_itab into g_TABCTRL100_wa
      where flag = 'X'.
      g_TABCTRL100_wa-flag = ''.
      modify g_TABCTRL100_itab
        from g_TABCTRL100_wa
        transporting flag.
    endloop.
    g_TABCTRL100_wa-flag = 'X'.
  endif.
  modify g_TABCTRL100_itab
    from g_TABCTRL100_wa
    index TABCTRL100-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
module TABCTRL100_user_command input.
  OKCODE = sy-ucomm.
  if g_rej_fl <> 'X'.
    perform user_ok_tc using    'TABCTRL100'
                                'G_TABCTRL100_ITAB'
                                'FLAG'
                       changing OKCODE.
  else.
    clear g_rej_fl.
  endif.
  sy-ucomm = OKCODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-PLANT' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.

  DATA   : it_bukrs type table of zd_t001w_bukrs with header line.

  select * from zd_t001w_bukrs into corresponding fields of
             table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'WERKS'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-PLANT'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_BUKRS
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-GRP' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.

  DATA : l_ekgrp like t024-ekgrp.
  refresh : it_cond.
  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
  space.
  IF ZMM_PREP_ROLEREQ-CCODE = 'SBS' or ZMM_PREP_ROLEREQ-CCODE = 'SBW'.
    g_select = 'R%'.
    g_select_flag = 'X'.
  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'JOR'.
    g_select = 'L%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'ANK'.
    g_select = 'A%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'BDA'.
    g_select = 'B%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'CBY'.
    g_select = 'C%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'AMD'.
    g_select = 'D%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'MHN'.
    g_select = 'E%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'JDH'.
    g_select = 'G%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'RJY'.
    g_select = 'K%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'SIL'.
    g_select = 'S%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'AGT'.
    g_select = 'T%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'MBP'.
    g_select = 'W%'.
    g_select_flag = 'X'.

  ENDIF.
  IF ZMM_PREP_ROLEREQ-CCODE = 'KKL'.
    g_select = 'M%'.
    g_select_flag = 'X'.

    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
    g_select = 'V%'.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024_1 where (it_cond).
    refresh it_cond.
    append lines of it_t024_1 to it_t024.
    refresh it_t024_1.

  ENDIF.
*
  if ZMM_PREP_ROLEREQ-CCODE <> 'KKL'.
    refresh it_cond.
    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
    append g_line1 to it_cond.
    select * from t024 into table it_t024 where (it_cond).
    refresh it_cond.
  endif.

  if g_select_flag <> 'X'.
    select * from t024 into table it_t024 where
            ( ekgrp not between 'A' and 'EZZ' ) and
            ( ekgrp not between 'K' and 'MZZ' ) and
            ( ekgrp not between 'G' and 'GZZ' ) and
            ( ekgrp not between 'R' and 'TZZ' ) and
            ( ekgrp not between 'V' and 'WZZ' ).
  endif.

  data : loop_step like sy-stepl.
  Data : l_role_name like ZMM_PREP_ROLEREI-ROLE_NAME.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

  if l_role_name = 'M6' or  l_role_name = 'M7' or
      l_role_name = 'M8'.

  else.

    if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

      loop at it_t024 into wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        if l_ekgrp+1(1) between '0' and 'A'.
          delete it_t024.
        endif.

      endloop.


    else.

      loop at it_t024 into wa_t024.

        l_ekgrp = wa_t024-ekgrp.

        if l_ekgrp+1(1) < '0'  or
        l_ekgrp+1(1) > 'A'.
          delete it_t024.
        endif.

      endloop.

    endif.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'EKGRP'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-GRP'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_t024
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_t024,IST_RETURN_TAB.
  FREE : it_t024,IST_RETURN_TAB.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and screen-input = 0
.
      dis_flag = 'X'.
    endif.

  endloop.

  TYPES : Begin of z_role_des,
              role_type like zmm_prep_roledes-role_type,
              brief_desc like zmm_prep_roledes-brief_desc,
              sort_field like zmm_prep_roledes-brief_desc,
              mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
            end of z_role_des.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : it_role type table of z_role_des with header line.

  if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.


    select * from zmm_prep_rolecrc into corresponding fields of
                 table it_role.

  else.


    select * from zmm_prep_roledes into corresponding fields of
               table it_role.

  endif.

  sort it_role ascending by sort_field.

  if old_ok_code <> 'DISPLAY'.

    clear ZMM_PREP_ROLEREI-ROLE_NAME.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'ROLE_TYPE'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-ROLE_NAME'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = IT_ROLE
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.
*  if old_ok_code = 'DISPLAY'.
*     clear ZMM_PREP_ROLEREI-ROLE_NAME.
*  Endif.
  REFRESH:IT_ROLE,IST_RETURN_TAB.
  FREE : IT_ROLE,IST_RETURN_TAB.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_header_data INPUT.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.

  case okcode_100.

    When 'BAC' OR 'CAN'.
      perform exit_confirm.
    When 'EXT'.
      leave program.

    When 'CREATE'.

      old_ok_code = okcode_100.

    When 'CHANGE'.

      old_ok_code = okcode_100.

    When 'RELEASE'.

      old_ok_code = okcode_100.


    When 'APPROVE'.

      old_ok_code = okcode_100.

    when 'COPY'.


    When 'DISPLAY'.

      old_ok_code = okcode_100.

*    When 'MULTI'.
*
*      call screen 120 STARTING AT 10 5
*                  ENDING   AT 90 15.
*      clear okcode_100.
*

    when 'ROLE_CR'.

      if ZMM_PREP_ROLEREQ-STATUS = 'C'.
        message e086(zhelp).
      else.
*            perform status_update.
        perform create_roles.
      endif.

    WHEN 'SAV'.

      if old_ok_code = 'DELETE'.
        if ZMM_PREP_ROLEREQ-USERIDCR = sy-uname.
          Perform delete_request.
        else.
          message e056(ZHELP).
        endif.
      else.

        describe table g_TABCTRL100_itab lines g_lines_rl.
*        if g_lines_rl = 0.
*          clear okcode_100.
*          message i103(zhelp).
*        else.
          Perform check_items.
          Perform Save_request.
*        endif.
      endif.

    When 'MULTI'.

      call screen 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      clear okcode_100.


    WHEN 'DELETE'.

      old_ok_code = okcode_100.

    WHEN 'SUIM'.

      CALL SCREEN 120.
      if okcode_100 = 'BAC'.
        clear old_ok_code.
      endif.

    WHEN 'LIST'.

      perform list_files.
      if ( zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR' ) and
         sy-tcode <> 'ZMM_ARMS_ADMN'.
        old_ok_code = 'DISPLAY'.
      else.
        old_ok_code = 'CHANGE'.
      endif.

    WHEN 'ATTACH'.

      perform attach_files.
      if zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR'.
        old_ok_code = 'DISPLAY'.
      else.
        old_ok_code = 'CHANGE'.
      endif.
      g_reset_change = 'X'.

    WHEN 'CORR'.

      Call Screen 105 starting at 85 05 ending at 148 24.
      if g_clines <> 0.
        corr_code = okcode_100.
      endif.
      clear okcode_100.
      g_reset_change = 'X'.

    when 'ROLE_DEL'.

      refresh : ist_seltab.
      clear   : seltab.

      seltab-selname = 'P_REM'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
      concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
*          seltab-low   = p_docno.
      append seltab to ist_seltab.

      seltab-selname = 'P_REM1'.
      seltab-sign    = 'I'.
      seltab-option = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
      seltab-low   = zmm_prep_rolereq-userid.
      append seltab to ist_seltab.

      if zmm_prep_rolereq-status = 'C' or
         zmm_prep_rolereq-status = 'IC' or
         zmm_prep_rolereq-status = 'IR'..
        message e121(zhelp).

      else.

        submit ZHELPROLE3 WITH SELECTION-TABLE ist_seltab and return.

        get parameter id 'ZROLEREQNO' field ZROLEREQNO.

        get parameter id 'EXIT_VALUE' field g_exit_value.

        if not ZROLEREQNO is initial and ZROLEREQNO <> '00000000' and
          g_exit_value <> 'X'.
          submit ZBC_ROLE_REP01_RFC_DEL and return.
*            perform send_sapmail.
        else.
          set parameter id 'EXIT_VALUE' field ''.
          clear g_exit_value.
        endif.

      endif.

    when 'MAIL'.

      perform confirm_mail.

    when 'SUMMARY'.

      call transaction 'ZMMAUTHSUMMARY' and skip first screen.

    when 'POSTING'.

      call transaction 'ZMMUSERDATA' and skip first screen.

    WHEN OTHERS.

      clear okcode_100.


  endcase.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_ok_code INPUT.

  if sy-ucomm = 'DBLCLK'.
    clear sy-ucomm.
  endif.
  okcode_100 = sy-ucomm.
  clear : g_srno, err_flg.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_current_line  = g_cursor_line.
  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_data INPUT.

  if not zmm_prep_rolereq-docno is initial.

*  data : l_docno like zmm_prep_rolereq-docno.

    l_docno = zmm_prep_rolereq-docno.


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

    zmm_prep_rolereq-docno = l_docno.

  endif.


  if old_doc_no <> ZMM_PREP_ROLEREq-docno.
    clear: g_hd_copied.
    perform destroy_ctrl.

  endif.

ENDMODULE.                 " clear_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.

  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       =  LT_TEXT_TABLE1
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE1
            ITF_TEXT    = TLINETAB1.
*
  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' ).

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
         IMPORTING
              TEXT       =  LT_TEXT_TABLE2
              IS_MODIFIED = GV_XTHEAD_UPDKZ
         EXCEPTIONS
              ERROR_DP               = 1
              ERROR_CNTL_CALL_METHOD = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              TEXT_STREAM = LT_TEXT_TABLE2
              ITF_TEXT    = TLINETAB2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0105 INPUT.

  Data: okcode105 like sy-ucomm.

  okcode105 = sy-ucomm.

  Case okcode105.
    When 'OK'.
      describe table tlinetab2 lines g_clines.
      clear okcode105.
    When 'CANCEL'.
      refresh tlinetab2[].
      clear okcode105.
  Endcase.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-SLOC' and screen-input = 0.
      dis_flag = 'X'.
    endif.

  endloop.

  Data : l_plant like ZMM_PREP_ROLEREI-PLANT.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'PLANT'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_plant.

  DATA   : it_t001l type table of t001l with header line.
  DATA   : wa_t001l like t001l.
  DATA   : l_zarea like zmm_consm-zarea.

  select * from t001l into corresponding fields of
             table it_t001l  where werks = l_plant.

  if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

    loop at it_t001l into wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if sy-subrc = 0.

        if l_zarea+0(1) <> 'M'.
          delete it_t001l.
        endif.

      else.

        delete it_t001l.

      endif.

    endloop.

  else.

    loop at it_t001l into wa_t001l.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if sy-subrc = 0.

        if l_zarea+0(1) = 'M'.
          delete it_t001l.
        endif.

      else.

        delete it_t001l.

      endif.

    endloop.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LGORT'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-SLOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_t001l
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:IT_t001l,IST_RETURN_TAB.
  FREE : IT_t001l,IST_RETURN_TAB.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

  loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and screen-input = 0.
        dis_flag = 'X'.
      endif.

  endloop.


  data : it_approver like table of zmm_prep_approve.
  data : wa_approver like zmm_prep_approve.

  data : it_approver1 like table of zmm_prep_app_CRC.
  data : wa_approver1 like zmm_prep_app_CRC.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

     if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*
*
*              if l_role_name = 'M11'.
*
*                  loop at it_approver into wa_approver.
*
*                    if wa_approver-M11_FLAG <> 'X'.
*                      delete it_approver.
*                    endif.
*
*                  endloop.
*
*              endif.
*
*      endif.


*      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*         if l_role_name = 'M11'.
*
*            loop at it_approver into wa_approver.
*
*                if wa_approver-M11_FLAG <> 'X'.
*                    delete it_approver.
*                 endif.
*
*            endloop.
*
*         endif.
*
*      endif.
*******************************************************
           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.

 if old_ok_code = 'DISPLAY'.
     dis_flag = 'X'.
  endif.

 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'APP_LEVEL'.
 append g_field_wa to g_field_tab.
 g_field_wa-tabname = 'ZMM_PREP_APPROVE'.
 g_field_wa-fieldname = 'L_DESC'.
 append g_field_wa to g_field_tab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'APP_LEVEL'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-APPROVER'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_approver
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_approver,IST_RETURN_TAB.
  FREE : it_approver,IST_RETURN_TAB.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

  loop at screen.

    if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC' and screen-input =
0.
      dis_flag = 'X'.
    endif.

  endloop.

  data : it_recpt like table of zmm_location.
  data : wa_recpt like zmm_location.

  CALL FUNCTION 'DYNP_GET_STEPL'
       IMPORTING
            POVSTEPL        = loop_step
       EXCEPTIONS
            STEPL_NOT_FOUND = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
       EXPORTING
            STRUC = 'ZMM_PREP_ROLEREI'
            FIELD = 'ROLE_NAME'
            index = loop_step
            REPID = SY-CPROG
            DYNNR = '0100'
       IMPORTING
            VALUE = l_role_name.

  select * from zmm_location into table it_recpt.


  if l_role_name = 'M12'.

    loop at it_recpt into wa_recpt.

      if wa_recpt-loccg <> 'RL'.
        delete it_recpt.
      endif.

    endloop.

  endif.


  if l_role_name = 'M17'.

    loop at it_recpt into wa_recpt.

      if wa_recpt-loccg <> 'CF'.
        delete it_recpt.
      endif.

    endloop.

  endif.

  if old_ok_code = 'DISPLAY'.
    dis_flag = 'X'.
  endif.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'LOCCD'
            DYNPPROG        = SY-CPROG
            DYNPNR          = SY-DYNNR
            DYNPROFIELD     = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'
            VALUE_ORG       = 'S'
            DISPLAY         = dis_flag
       TABLES
            VALUE_TAB       = it_recpt
            RETURN_TAB      = IST_RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.

  IF SY-SUBRC <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    clear dis_flag.
  ENDIF.

  REFRESH:it_recpt,IST_RETURN_TAB.
  FREE : it_recpt,IST_RETURN_TAB.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  if sy-ucomm = 'EXT'.
    leave program.
  endif.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.

  old_doc_no = ZMM_PREP_ROLEREq-docno.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_fund_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_fund_data INPUT.
  data l_fundc_no like sy-index.
  clear l_fundc_no.
  loop at it_m_fistb into wa_m_fistb.
    if wa_m_fistb-g_mark = 'X'.
      l_fundc_no = l_fundc_no + 1.
      case l_fundc_no.
        when 2.
          ZMM_PREP_ROLEREQ-fundc2 = wa_m_fistb-fictr.
        when 3.
          ZMM_PREP_ROLEREQ-fundc3 = wa_m_fistb-fictr.
        when 4.
          ZMM_PREP_ROLEREQ-fundc4 = wa_m_fistb-fictr.
        when 5.
          message e078(zhelp).
      endcase.
    endif.
  endloop.

ENDMODULE.                 " validate_fund_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE record_rej_id_data INPUT.
  if ZMM_PREP_ROLEREI-rej_id is initial.
    ZMM_PREP_ROLEREI-rej_id = sy-uname.
    ZMM_PREP_ROLEREI-rej_date = sy-datum.
  endif.

  if not ZMM_PREP_ROLEREI-rej_fl is initial and
     ZMM_PREP_ROLEREI-rej_fl_save is initial.

    select single * from  ZMM_PREP_REJ_LIS  where
      rej_code = ZMM_PREP_ROLEREI-rej_fl .
    if sy-subrc <> 0.
      g_e_fl = 'X'.
      message e111(zhelp).
    else.
      if sy-uname+0(1) = 'C' and
                    ZMM_PREP_ROLEREI-rej_fl = 'F'.
      else.
        g_e_fl = 'X'.
        message e111(zhelp).
      endif.
    endif.
  endif.

ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data INPUT.

  if g_read_fl <> 'X'.

    select single * from zmm_prep_roledes where role_type =
                      ZMM_PREP_ROLEREI-role_name.


  elseif g_e_fl = 'X'.
    clear g_e_fl.

  else.

    clear  ZMM_PREP_ROLEREI-RECEIPT_LOC.
    clear  ZMM_PREP_ROLEREI-SLOC.
    clear  ZMM_PREP_ROLEREI-plant.
    clear  ZMM_PREP_ROLEREI-grp.
    clear  ZMM_PREP_ROLEREI-approver.

    clear g_read_fl.
  endif.

  l_role_name = ZMM_PREP_ROLEREI-role_name.

**********************************************************

  if old_ok_code <> 'DISPLAY'.

    select single * from zmm_prep_roledes  where
              role_type = ZMM_PREP_ROLEREI-role_name.
    if sy-subrc <> 0.
      message e067(zhelp) with ZMM_PREP_ROLEREI-role_name.
    else.
** put validation for MM discipline roles????
      if zmm_prep_roledes-mm_disc_flag = 'X'.

        if ZMM_PREP_ROLEREQ-disc_mm_flag = 'X'.
        else.
          message e081(zhelp) with ZMM_PREP_ROLEREI-role_name.
        endif.

      endif.

    endif.

    if not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from zd_t001w_bukrs into corresponding fields of
                 table it_bukrs  where bukrs = ZMM_PREP_ROLEREQ-CCODE
                                    and werks = ZMM_PREP_ROLEREI-PLANT.
      if sy-subrc <> 0.
        g_e_fl = 'X'.
        message e068(zhelp) with ZMM_PREP_ROLEREI-role_name.
      endif.

    endif.


************finding group*******************

    refresh : it_cond, it_t024, it_t024_1.
    clear   : wa_t024.
    concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
    space.
    IF ZMM_PREP_ROLEREQ-CCODE = 'SBS' or ZMM_PREP_ROLEREQ-CCODE = 'SBW'.
      g_select = 'R%'.
      g_select_flag = 'X'.
    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'JOR'.
      g_select = 'L%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'ANK'.
      g_select = 'A%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'BDA'.
      g_select = 'B%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'CBY'.
      g_select = 'C%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'AMD'.
      g_select = 'D%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'MHN'.
      g_select = 'E%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'JDH'.
      g_select = 'G%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'RJY'.
      g_select = 'K%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'SIL'.
      g_select = 'S%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'AGT'.
      g_select = 'T%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'MBP'.
      g_select = 'W%'.
      g_select_flag = 'X'.

    ENDIF.
    IF ZMM_PREP_ROLEREQ-CCODE = 'KKL'.
      g_select = 'M%'.
      g_select_flag = 'X'.

      concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
      append g_line1 to it_cond.
      select * from t024 into table it_t024 where (it_cond).
      refresh it_cond.
      g_select = 'V%'.
      concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
      append g_line1 to it_cond.
      select * from t024 into table it_t024_1 where (it_cond).
      refresh it_cond.
      append lines of it_t024_1 to it_t024.
      refresh it_t024_1.

    ENDIF.
*
    if ZMM_PREP_ROLEREQ-CCODE <> 'KKL'.
      refresh it_cond.
      concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
      append g_line1 to it_cond.
      select * from t024 into table it_t024 where (it_cond).
      refresh it_cond.
    endif.

    if g_select_flag <> 'X'.
      select * from t024 into table it_t024 where
              ( ekgrp not between 'A' and 'EZZ' ) and
              ( ekgrp not between 'K' and 'MZZ' ) and
              ( ekgrp not between 'G' and 'GZZ' ) and
              ( ekgrp not between 'R' and 'TZZ' ) and
              ( ekgrp not between 'V' and 'WZZ' ).
    endif.


    if l_role_name = 'M6' or  l_role_name = 'M7' or
        l_role_name = 'M8'.

    else.

      if ZMM_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.

        loop at it_t024 into wa_t024.

          l_ekgrp = wa_t024-ekgrp.

          if l_ekgrp+1(1) between '0' and 'A'.
            delete it_t024.
          endif.

        endloop.


      else.

        loop at it_t024 into wa_t024.

          l_ekgrp = wa_t024-ekgrp.

          if l_ekgrp+1(1) < '0'  or
          l_ekgrp+1(1) > 'A'.
            delete it_t024.
          endif.

        endloop.

      endif.

    endif.


**
    if  not ZMM_PREP_ROLEREI-GRP is initial.

      loop at it_t024 into wa_t024.

        if ZMM_PREP_ROLEREI-GRP = wa_t024-ekgrp.
          grp_flag = 'X'.
        endif.

      endloop.

      if grp_flag = 'X'.
        clear grp_flag.
      else.
        g_e_fl = 'X'.
        message e069(zhelp).
      endif.

    endif.

***************************

    clear : l_zarea, wa_t001l.
    refresh it_t001l.

    if ( ZMM_PREP_ROLEREI-role_name = 'M13' or
       ZMM_PREP_ROLEREI-role_name = 'M14' or
        ZMM_PREP_ROLEREI-role_name = 'M16' or
        ZMM_PREP_ROLEREI-role_name = 'M18' or
        ZMM_PREP_ROLEREI-role_name = 'M19' ) and
        not ZMM_PREP_ROLEREI-PLANT is initial.

      select * from t001l into corresponding fields of
                   table it_t001l  where werks = ZMM_PREP_ROLEREI-PLANT.

      if  sy-subrc <> 0.
        g_e_fl = 'X'.
        message e074(zhelp).
      endif.

    endif.

    if ZMM_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

      loop at it_t001l into wa_t001l.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          if l_zarea+0(1) <> 'M'.
            delete it_t001l.
          endif.

        else.

          delete it_t001l.

        endif.

      endloop.

    else.

      loop at it_t001l into wa_t001l.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          if l_zarea+0(1) = 'M'.
            delete it_t001l.
          endif.

        else.

          delete it_t001l.

        endif.

      endloop.

    endif.

    if  not ZMM_PREP_ROLEREI-SLOC is initial.

      loop at it_t001l into wa_t001l.

        if ZMM_PREP_ROLEREI-SLOC = wa_t001l-lgort.
          loc_flag = 'X'.
        endif.

      endloop.

      if loc_flag = 'X'.
        clear loc_flag.
      else.
        g_e_fl = 'X'.
        message e073(zhelp).
      endif.

    endif.


***************************

    clear wa_recpt.
    refresh it_recpt.

    if ( ZMM_PREP_ROLEREI-role_name = 'M12' or
       ZMM_PREP_ROLEREI-role_name = 'M17' ) and
       not ZMM_PREP_ROLEREI-receipt_loc is initial.

      select * from zmm_location into table it_recpt.

      if ZMM_PREP_ROLEREI-role_name = 'M12'.

        loop at it_recpt into wa_recpt.

          if wa_recpt-loccg <> 'RL'.
            delete it_recpt.
          endif.

        endloop.

      endif.


      if ZMM_PREP_ROLEREI-role_name = 'M17'.

        loop at it_recpt into wa_recpt.

          if wa_recpt-loccg <> 'CF'.
            delete it_recpt.
          endif.

        endloop.

      endif.

    endif.

    if  not ZMM_PREP_ROLEREI-RECEIPT_LOC is initial.

      loop at it_recpt into wa_recpt.

        if ZMM_PREP_ROLEREI-receipt_loc = wa_recpt-loccd.
          loc_flag = 'X'.
        endif.

      endloop.

      if loc_flag = 'X'.
        clear loc_flag.
      else.
        g_e_fl = 'X'.
        message e075(zhelp).
      endif.

    endif.
*****************************
*****************************22.05.06

if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'.

      select * from zmm_prep_app_CRC into table it_approver1.

     else.

      select * from zmm_prep_approve into table it_approver.

     endif.

           if l_role_name = 'M11S'.  "22.05.06

                loop at it_approver into wa_approver.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-M11S_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.

             if l_role_name = 'M11M'.

                loop at it_approver into wa_approver.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver-MM_FLAG <> 'X'
                        or wa_approver-M11M_FLAG <> 'X'.
                        delete it_approver.
                     endif.
                  when OTHERS.
                      if wa_approver-MM_FLAG = 'X'
                         or wa_approver-M11M_FLAG <> 'X'.
                          delete it_approver.
                      endif.
                 endcase.

                endloop.

             endif.
**************************************************22.05.06

        if l_role_name = 'M8'.

            loop at it_approver into wa_approver.

                if wa_approver-M8_FLAG <> 'X'.
                    delete it_approver.
                 endif.

            endloop.

         endif.

         if old_ok_code = 'CRCROLES' or ZMM_PREP_ROLEREQ-CRC_FL = 'X'..

             if l_role_name = 'M3'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

             if l_role_name = 'M3A'. "22.05.06

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3A_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

             endif.

            if l_role_name = 'M3B'.

                loop at it_approver1 into wa_approver1.

                    if wa_approver1-M3B_FLAG <> 'X'.
                        delete it_approver1.
                     endif.

             endloop.

           endif.                       " 22.05.06


             if l_role_name = 'M11S'.

                loop at it_approver1 into wa_approver1.

                 case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11S_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11S_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

            if l_role_name = 'M11M'.

                loop at it_approver1 into wa_approver1.

                case ZMM_PREP_ROLEREQ-DISC_MM_FLAG.

                  when 'X'.
                     if wa_approver1-MM_FLAG <> 'X'
                        or wa_approver1-M11M_FLAG <> 'X'.
                        delete it_approver1.
                     endif.
                  when OTHERS.
                      if wa_approver1-MM_FLAG = 'X'
                         or wa_approver1-M11M_FLAG <> 'X'.
                          delete it_approver1.
                      endif.
                 endcase.

                endloop.

             endif.

             it_approver[] = it_approver1[].

         endif.
*********************************************22.05.06

if  not ZMM_PREP_ROLEREI-APPROVER is initial.

       loop at it_approver into wa_approver.

           if ZMM_PREP_ROLEREI-APPROVER = wa_approver-app_level.
              approver_flag = 'X'.
           endif.

       endloop.

       if approver_flag = 'X'.
          clear approver_flag.
       else.
          g_e_fl = 'X'.
          g_read_fl = 'X'.
          g_field = 'ZMM_PREP_ROLEREI-APPROVER'.
          move-corresponding ZMM_PREP_ROLEREI to g_TABCTRL100_wa.
          modify g_TABCTRL100_itab
                    from g_TABCTRL100_wa
                      index TABCTRL100-current_line.
          g_i = TABCTRL100-current_line.
          message e135(zhelp).
          call screen 100.

       endif.

   endif.

*****************************

  endif.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_lineitem_data1 INPUT.

  select single * from zmm_prep_roledes where role_type =
                    ZMM_PREP_ROLEREI-role_name.

  g_read_fl = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_srno INPUT.
  clear g_srno.
  loop at g_TABCTRL100_itab into g_TABCTRL100_wa.
    g_srno = g_srno + 1.
    g_TABCTRL100_wa-srno = g_srno.
    modify g_TABCTRL100_itab from g_TABCTRL100_wa.
  endloop.
  describe table g_TABCTRL100_itab  lines g_lines_rl.
  describe table g_TABCTRL100_itab  lines TABCTRL100-lines.
  clear g_srno.
ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_data INPUT.
g_role_name_prev = ZMM_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT
