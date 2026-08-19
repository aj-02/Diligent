*--- MAIN PROGRAM: MZM06B_OIR1 ---*
*----------------------------------------------------------------------*
***INCLUDE MM06BIR1 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  RM06B-BNFPO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module rm06b-bnfpo input.

  perform rm06b-bnfpo.

endmodule.                 " RM06B-BNFPO  INPUT
*&---------------------------------------------------------------------*
*&      Module  chck_line_sel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module chck_line_sel input.

  data : l_ln type i .
  describe table sel lines l_ln .

  if  ( sy-ucomm = 'SFBU' ) .
    if l_ln is initial .
      sy-ucomm = '  ' .
      ok-code = ' ' .
      message i002(zme54) . set screen '0106' .
    endif .
  endif .
endmodule.                 " chck_line_sel  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_BDP  INPUT
*&---------------------------------------------------------------------*
*       Check whether Input PR No having BDP clasue which is available
* in zmm_annual_limit or not, If so then do other checks
* Added by shibu on 29.06.2005
*----------------------------------------------------------------------*
module check_bdp input.

  if not eban-banfn is initial and
     rm06b-frgab = '01' and ok-code = 'SF' and g_bsakz ne 'R'  .
    perform get_bdp_info.
    if  g_bdp_exist = 'X'.
      perform get_pr_tot tables ist_eban01  .
      perform get_detail_t16.
    endif.
  endif.
endmodule.                 " CHECK_BDP  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_final_release  INPUT
*&---------------------------------------------------------------------*
*      Validations Before Final Release
*----------------------------------------------------------------------*
module check_final_release input.
  if not ( rm06b-frgab = '01'   or rm06b-frgab = '02' or
           rm06b-frgab = 'DI'   or rm06b-frgab = 'DF' or
           rm06b-frgab = 'MD'   or rm06b-frgab = 'BO' or
           rm06b-frgab = 'EC'   or rm06b-frgab = 'BV' )
     and ok-code = 'SF'  and g_bsakz ne 'R'.
*  PERFORM get_user_role.
    perform check_bdp_bf_final_rel.
    if g_bdp_exist ='X'.
      perform get_bdp_info_annual.
      perform get_pr_tot  tables ist_eban01.
      perform get_rel_code .
    endif.
*    perform get_annual_limit.
  endif.
endmodule.                 " check_final_release  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_doc_category  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_doc_category input.
  perform get_doc_cat.
endmodule.                 " get_doc_category  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_doc_bdp  INPUT
*&---------------------------------------------------------------------*
*       Check BDP in PR Document
*----------------------------------------------------------------------*
module check_doc_bdp input.
  if sy-ucomm = 'SF'.
    perform check_send_message.
  endif.
endmodule.                 " check_doc_bdp  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_reset  INPUT
*&---------------------------------------------------------------------*
*       Check for Reset
*----------------------------------------------------------------------*
module check_reset input.
  data: l_frgkz .
  clear  l_frgkz .

  if sy-ucomm = 'NF'.
* perform check_bdp_rel_code.
    perform check_release_ind changing l_frgkz.
    if l_frgkz = 'B'.
      call screen 300 starting at 10 6  ending at 74 12.
    endif.
  endif.
endmodule.                 " check_reset  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*      User Command for screen 300
*----------------------------------------------------------------------*
module user_command_0300 input.

  case sy-ucomm.
    when 'BACK' or '%EX' or 'RW'.
      set screen 0.
      leave screen.
    when 'NAGR'.
       set screen 0.
      leave.
*      leave to  transaction  'ZME54'.
      leave to  transaction  'ZME54_O'.

    when 'AGRR'.
      set screen 0.
      leave screen.
  endcase.
endmodule.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0305  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0305 input.
  data: l_ans .
  case sy-ucomm.
    when 'BACK' or '%EX' or 'RW'.
      leave.
*      leave to transaction 'ZME54'.
      leave to transaction 'ZME54_O'.
    when 'SVRM'.
      call function 'POPUP_TO_CONFIRM'
           exporting
                titlebar      = text-s04
                text_question = text-s05
                icon_button_1 = 'Yes '
                icon_button_2 = 'No'
           importing
                answer        = l_ans.

      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      if l_ans = '1'.
        set screen 0.
        leave screen.
      elseif l_ans = 'A'.
        set screen '0305'.
      elseif l_ans = '2'.
        leave.
*        leave to transaction 'ZME54'.
          leave to transaction 'ZME54_O'.
      endif.
  endcase.
endmodule.                 " USER_COMMAND_0305  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_tc305_data  INPUT
*&---------------------------------------------------------------------*
*       Modify TC 305 data.
*----------------------------------------------------------------------*
module modify_tc305_data input.
  move-corresponding wa_tc305 to wa_remark.
  modify ist_remark from wa_remark index tc305-current_line.

endmodule.                 " modify_tc305_data  INPUT
