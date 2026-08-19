*--- MAIN PROGRAM: MZMMUOMI01 ---*
***INCLUDE MZMMMERI01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_modify INPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_modify input.

*  PERFORM get_commitment_number.

*  PERFORM validate_records.

*  IF NOT ( zmm_mecs IS INITIAL ).
*    zmm_mecs-dismm = 'ND'.
*  ENDIF.

  move-corresponding wa_zmm_uom_d to g_tc_81_wa.


  modify g_tc_81_itab  from g_tc_81_wa  index tc_81-current_line.

  if sy-subrc ne 0.
    append g_tc_81_wa to g_tc_81_itab.
  endif.

  delete g_tc_81_itab  where matnr eq space.

endmodule.

*---------------------------------------------------------------------*
*       MODULE TC_81_mark INPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_mark input.
  if tc_81-line_sel_mode = 1 and
     g_tc_81_wa-flag = 'X'.
    loop at g_tc_81_itab into g_tc_81_wa where flag = 'X'.
      g_tc_81_wa-flag = ''.
      modify g_tc_81_itab from g_tc_81_wa transporting flag.
    endloop.
    g_tc_81_wa-flag = 'X'.
  endif.
  modify g_tc_81_itab from g_tc_81_wa index tc_81-current_line
    transporting flag.
endmodule.

*---------------------------------------------------------------------*
*       MODULE TC_81_user_command INPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module tc_81_user_command input.
  ok_code = sy-ucomm.
  perform user_ok_tc using    'TC_81'
                              'G_TC_81_ITAB'
                              'FLAG'
                     changing ok_code.
  sy-ucomm = ok_code.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit input.

  refresh g_tc_81_itab.
  clear g_tc_81_wa.
  clear g_tc_81_copied.

  if sy-dynnr eq 9080.
    leave program.
  else.
    leave to  screen 9080.
  endif.
endmodule.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9081  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9081 input.
  g_ok_81 = sy-ucomm.
  case g_ok_81.
    when 'SAVE'.
      perform save_9081.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      perform confirm_user_action.
  endcase.


endmodule.                 " USER_COMMAND_9081  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9080 input.
  g_ok_80 = sy-ucomm.
  case g_ok_80.
    when 'CREATE'.
      perform assign_sy_values.
      leave to screen 9081.
    when 'CHANGE'.
      leave to screen 9082.
    when 'DISPLAY'.
      leave to screen 9082.
    when 'DELETE'.
      leave to screen 9082.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      leave program.
  endcase.
endmodule.                 " USER_COMMAND_9080  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_9082 input.

  g_ok_82 = sy-ucomm.

  move g_docno to wa_zmm_uom_h-docno.

  Select single * into wa_zmm_uom_h  from zmm_uom_h where
     docno = g_docno.

  If sy-subrc = 0.
    perform get_itab_data.
    call screen 9081.
  Else.

     message i360(ZMM) with g_docno.
       clear g_docno.
  endif.

*  case g_ok_82.
*    when 'CHANGE' or 'DISPLAY'.
*      perform get_itab_data.
**      fcode = 'SAVE'.
**      LEAVE SCREEN.
*       call screen 9081.
*    when 'DELETE'.
*      perform get_delete_itab_data.
**      LEAVE SCREEN.
*       call screen 9081.
*
*    when 'BACK' or 'EXIT' or 'CANCEL'.
**      SET SCREEN 9080.
**      LEAVE SCREEN.
*       leave to screen 9080.
*  endcase.


endmodule.                 " USER_COMMAND_9082  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_user input.
  if g_ok_80 eq 'CHANGE' or g_ok_80 eq  'DELETE'.
    perform check_user.
  endif.

endmodule.                 " check_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VALUE_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  check_matnr  INPUT
*&---------------------------------------------------------------------*
*       check material validity routine
*----------------------------------------------------------------------*
module check_matnr input.

check not wa_zmm_uom_d-matnr is initial.

  call function 'MARA_READ'
       exporting
            i_matnr  = wa_zmm_uom_d-matnr
       exceptions
            no_entry = 1
            others   = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  read table g_tc_81_itab into g_tc_81_wa
  with key matnr = wa_zmm_uom_d-matnr.
  if sy-subrc = 0.
     clear wa_zmm_uom_d-matnr.
     message e366(zmm).
  endif.

  Clear: wa_zmm_uom_d-meinh, wa_zmm_uom_d-umrez.
  Select single  MEINS into
    wa_zmm_uom_d-meins  from MARA
  where matnr = wa_zmm_uom_d-matnr.

*  if wa_zmm_uom_d-meins = 'NO'.
*     message e367(zmm) with wa_zmm_uom_d-matnr.
*  endif.


endmodule.                 " check_matnr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_plant input.
select single * from t001w where
    werks = wa_zmm_uom_h-werks.
if sy-subrc <> 0.
   message e020(zmm) with wa_zmm_uom_h-werks.
endif.
endmodule.                 " check_plant  INPUT
