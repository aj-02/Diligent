*--- MAIN PROGRAM: MZMMSRMCLUPDI01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FCODE_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Function Code Exit
*----------------------------------------------------------------------*
module fcode_exit input.
  case ok_code.
    when 'BACK' or 'EXIT' or 'CANCEL'.
      if ok_code_90 ne 'DISP'.
        perform alert_before_exit.
        if g_ans = '1' or ist_tc100[]  is initial.
          perform clear_global.
          leave to screen '90' .
        endif.
      else.
        perform clear_global.
        leave to screen '90' .
      endif.
  endcase.
endmodule.                 " FCODE_EXIT  INPUT

*&spwizard: input module for tc 'TC105'. do not change this line!
*&spwizard: modify table
module tc100_modify input.
  move-corresponding wa_tc100 to wa_100.
  wa_100-slno = tc100-current_line.
  wa_tc100-slno = tc100-current_line.
  modify ist_tc100
    from wa_100
     index tc100-current_line.
  if sy-subrc ne 0.
    append wa_100 to ist_tc100.
  endif.
endmodule.

*&spwizard: input modul for tc 'TC100'. do not change this line!
*&spwizard: mark table
module tc100_mark input.
  data: g_tc100_wa2 like line of ist_tc100.
  if tc100-line_sel_mode = 1.
    loop at ist_tc100 into g_tc100_wa2
      where smark = 'X'.
      g_tc100_wa2-smark = ''.
      modify ist_tc100
        from g_tc100_wa2
        transporting smark.
    endloop.
  endif.
  modify ist_tc100
    from wa_tc100
    index tc100-current_line
    transporting smark.
endmodule.

*&spwizard: input module for tc 'TC100'. do not change this line!
*&spwizard: process user command
module tc100_user_command input.
  ok_code = sy-ucomm.
  perform user_ok_tc using    'TC100'
                              'IST_TC100'
                              'SMARK'
                     changing ok_code.
  sy-ucomm = ok_code.
  case ok_code.
    when 'SAVE'.
      if g_dup ne 'X'.

        delete ist_tc100 where matnr =  space.
        if not ist_tc100[] is initial.
          perform popup_confirm.
        endif.
      endif.
*** Gererate  Request number
      if g_ans = '1'.
        perform get_request_no.
        perform run_bdc_mm02.
        perform update_request.
        perform display_data.
      endif.
    when 'IMPF'.
      perform get_import_file.
      perform load_data_in_tc.
  endcase.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  check_manr  INPUT
*&---------------------------------------------------------------------*
*       check Matereial Document no
*----------------------------------------------------------------------*
module check_matnr input.
  data: l_matnr like mara-matnr .
  if ok_code_90 = 'CREA' and ok_code ne  'TC100_DELE'.
    select single matnr from mara into l_matnr
      where matnr = wa_tc100-matnr .
    if sy-subrc ne 0.
      message e096(zmm) with  wa_tc100-matnr .
    endif.
  endif.
 endmodule.                 " check_manr  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0090  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0090 input.
  case ok_code_90  .
    when 'BACK' or 'EXIT' or 'CANCEL'.
      leave program.
    when 'CREA'  .
      refresh control 'TC100' from screen '100'.
      call screen '100'.
    when 'DISP'.
      call screen 105 starting at 10 5  ending at 45 8 .
  endcase.
endmodule.                 " USER_COMMAND_0090  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       User Commands
*----------------------------------------------------------------------*
module user_command_0105 input.
  case sy-ucomm  .
    when 'BACK' or '%EX' or 'RW' .
      set screen 0.
      perform clear_global.
      leave  screen  .
    when 'ENTER'.
      perform get_data.
      call screen '100'.
  endcase .
endmodule.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*   vALIDATE INPUT REQUEST NO
*----------------------------------------------------------------------*
module check_input input.
  perform check_reqno.
endmodule.                 " CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*&      Module  valid_input  INPUT
*&---------------------------------------------------------------------*
*       Check for Valid input Material code.
*----------------------------------------------------------------------*
module check_dup_matnr input.
  perform check_duplicate.
endmodule.                 " valid_input  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_set_cursor  INPUT
*&---------------------------------------------------------------------*
*       Get/Set Cursor Field
*----------------------------------------------------------------------*
module get_set_cursor input.
  perform set_cursor_field.
  perform vlidate_srm_class.
endmodule.                 " get_set_cursor  INPUT
