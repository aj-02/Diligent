*--- MAIN PROGRAM: MZROLEAUTHO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZUSRROLEREQO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  tstct_single_read  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module tstct_single_read output.
  CALL FUNCTION 'TSTCT_SINGLE_READ'
    EXPORTING
      sprache    = sy-langu
      tcode      = sy-tcode
    IMPORTING
      wtstct     = tstct
    EXCEPTIONS
      wrong_call = 1
      others     = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
endmodule.                 " tstct_single_read  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.

*  PERFORM pf_status.
  describe table ist_auth1 lines tctrl_100-lines.

endmodule.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  fill_tctrl_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module fill_tctrl_100 output.
* read table ist_auth1 into ist_auth_st index tctrl_100-current_line.

*  loop at screen.
*
*    if ok_code = 'DISPROLE'.
*
*      screen-input = 1.
*      screen-invisible = '0'.
**      Loop at screen.
**        If screen-name = 'IST_AUTH_ST-MARK'.
**           screen-input = 1.
**           modify screen.
**        Endif.
**      Endloop.
*      modify screen.
*
*    else.
*
*      screen-input = 0.
*      screen-invisible = '1'.
*      modify screen.
*
*    endif.
*
*  endloop.
  move ist_auth1 to ist_auth_st.

endmodule.                 " fill_tctrl_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Get_name  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_name output.
*Begin of <RD1K963161>.
  condense g_userid.
  move g_userid to lv_userid.
*End of <RD1K963161>.
  if okcode_9000 ne 'MANAGER'.
    if sy-uname+0(1) = 'C' .

    else.
      authority-check object 'M_EINK_FRG' id 'FRGCO' field   'L2'.
      if sy-subrc = 0.
        g_userid = sy-uname.
      else.
        authority-check object 'M_EINK_FRG' id 'FRGCO' field   'L1'.
        if sy-subrc = 0.
          g_userid = sy-uname.
        else.
          authority-check object 'M_EINK_FRG' id 'FRGCO' field   'HS'.
          if sy-subrc = 0.
            g_userid = sy-uname.
          else.
            authority-check object 'M_EINK_FRG' id 'FRGCO' field   'HL'.
            if sy-subrc = 0.
              g_userid = sy-uname.
            else.
              authority-check object 'M_EINK_FRG' id 'FRGCO' field   'HC'.
              if sy-subrc = 0.
                g_userid = sy-uname.
              else.
                authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1A'.
                if sy-subrc = 0.
                  g_userid = sy-uname.
                else.
                  authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1B'.
                  if sy-subrc = 0.
                    g_userid = sy-uname.
                  else.
                    authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1C'.
                    if sy-subrc = 0.
                      g_userid = sy-uname.
                    else.
                      authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1D'.
                      if sy-subrc = 0.
                        g_userid = sy-uname.
                      else.
                        authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1E'.
                        if sy-subrc = 0.
                          g_userid = sy-uname.
                        else.
                          authority-check object 'M_EINK_FRG' id 'FRGCO' field   '1F'.
                          if sy-subrc = 0.
                            g_userid = sy-uname.
                          else.
                            authority-check object 'M_EINK_FRG' id 'FRGCO' field   'DI'.
                            if sy-subrc = 0.
                              g_userid = sy-uname.
                            else.
                              authority-check object 'M_EINK_FRG' id 'FRGCO' field   'DF'.
                              if sy-subrc = 0.
                                g_userid = sy-uname.
                              else.
                                authority-check object 'M_EINK_FRG' id 'FRGCO' field   'CS'.
                                if sy-subrc = 0.
                                  g_userid = sy-uname.
                                else.
                                  authority-check object 'M_EINK_FRG' id 'FRGCO' field   'BO'.
                                  if sy-subrc = 0.
                                    g_userid = sy-uname.
                                  else.
                                    authority-check object 'M_EINK_FRG' id 'FRGCO' field   'MD'.
                                    if sy-subrc = 0.
                                      g_userid = sy-uname.
                                    else.
                                      authority-check object 'M_EINK_FRG' id 'FRGCO' field   'EC'.
                                      if sy-subrc = 0.
                                        g_userid = sy-uname.
                                      else.
                                        authority-check object 'M_EINK_FRG' id 'FRGCO' field   'L3'.
                                        if sy-subrc = 0.
                                          g_userid = sy-uname.
                                        else.
                                          authority-check object 'M_EINK_FRG' id 'FRGCO' field   'IM'.
                                          if sy-subrc = 0.
                                            g_userid = sy-uname.
                                          else.
                                            message e808(zbc).
                                          endif.
                                        endif.
                                      endif.
                                    endif.
                                  endif.
                                endif.
                              endif.
                            endif.
                          endif.
                        endif.
                      endif.
                    endif.
                  endif.
                endif.
              endif.
            endif.
          endif.
        endif.
      endif.
    endif.
  endif.
*Begin of <RD1K963161>.
  if okcode_9000 = 'MANAGER'.
*    IF lv_flag = ' '.
    g_userid = ' ' .
  endif.

  if okcode_9000 = 'MANAGER'."  AND SY-UCOMM = ' '.
    g_userid = lv_userid.
  endif.
*End of <RD1K963161>.
  if ok_200 = 'CREATE'.
*       g_userid = sy-uname.

    SELECT MY_CPF_NO INTO G_USERID FROM ZAUTH_USER_ROLE UP TO 1 ROWS
 WHERE REQ_NO = G_REQNO_REF
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  endif.
  select single persnumber into g_perno from usr21
                where bname = g_userid.

  if sy-subrc = 0 and not g_perno is initial.
    select single name_text into g_uname from adrp
                  where persnumber = g_perno.
  endif.

  if not g_subuserid is initial.

    select single persnumber into g_perno from usr21
                  where bname = g_subuserid.

    if sy-subrc = 0 and not g_perno is initial.
      select single name_text into g_subuname from adrp
                    where persnumber = g_perno.
    endif.


  endif.

endmodule.                 " Get_name  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_scr_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_scr_attr output.
  data l_emode(10) type c.
  if okcode_9000 = 'CREA'.
    l_emode = 'Create - '.
  elseif okcode_9000 = 'CHAN'.
    l_emode = 'Change - '.
  elseif okcode_9000 = 'DISP'.
    l_emode = 'Display - '.
  elseif okcode_9000 = 'DELETE'.
    l_emode = 'Delete - '.
  elseif okcode_9000 = 'DISPROLE'.
    l_emode = 'Display Roles - '.
*Begin of <RD1K963161>.
  elseif okcode_9000 = 'MANAGER'.
    l_emode = 'Support Manager - '.
*End of <RD1K963161>.
  endif.
* Begin of <RD1K963735> - as per the solman Call : 30001691 on 05/05/2009
  if okcode_9000 = 'MANAGER'.
    delete tab where fcode = 'ATTACH'.
  endif.
* End of <RD1K963735> - as per the solman Call : 30001691 on 05/05/2009
* SET PF STATUS AND TITLE
  if ok_200 = 'CREATE'.
    l_emode = 'Create - '.
    clear: wa_tab. refresh tab.
    move 'DELETE' to wa_tab-fcode.
    append wa_tab to tab.
    set titlebar 'M200' with l_emode.
    set pf-status 'PFS300' excluding tab.

  else.
    set titlebar 'AUTH' with l_emode.
    set pf-status 'ST_9000' excluding tab.
  endif.
  if okcode_9000 eq 'CREA'.
    l_emode = ' Create - '.
    if sy-uname+0(1) = 'C' or sy-uname+0(1) = 'R' .
    else.
      G_USERID = sy-uname.
    endif.
    loop at screen.

      if screen-group1 = 'G01'.
        screen-input = 0.
        screen-invisible = '1'.
        modify screen.
      endif.

      if screen-group1 = 'G02'.
        screen-input = 1.
*          screen-invisible = '0'.
        modify screen.
      endif.


      if sy-uname+0(1) = 'C' or sy-uname+0(1) = 'R' .
        if screen-group1 = 'G04'.
          screen-input = 1.
          modify screen.
        endif.
      else.
        if screen-group1 = 'G04'.
          if screen-name = 'G_USERID'.
            screen-input = 0.
            modify screen.
          endif.
        endif.
      endif.

    endloop.

  elseif okcode_9000 eq 'CHAN'.
    l_emode = ' Change - '.

    loop at screen.

      if screen-group1 = 'G01'.
        screen-input = 1.
        screen-invisible = '0'.
        modify screen.
      endif.

      if screen-group1 = 'G02'.
        screen-input = 0.
*          screen-invisible = '1'.
        modify screen.
      endif.

    endloop.

  elseif okcode_9000 eq 'DISP'.
    l_emode = ' Display - '.

    loop at screen.

      screen-input = 0.
      modify screen.


      if screen-group1 = 'G01'.
        screen-input = 1.
        screen-invisible = '0'.
        modify screen.
      endif.

      if screen-group2 = 'G03'.
        screen-input = 0.
*        screen-required = '1'.
        modify screen.
      endif.

    endloop.

  elseif ok_200 eq 'CREATE'.
    l_emode = ' Create with reference - '.
*break cab_mansuri.
    loop at screen.

      screen-input = 0.
      screen-invisible = '0'.
      modify screen.

    endloop.

  elseif okcode_9000 eq 'DELETE'.
    l_emode = ' Delete - '.


    loop at screen.

      screen-input = 0.
      modify screen.


      if screen-group1 = 'G01'.
        screen-input = 1.
        screen-invisible = '0'.
        modify screen.
      endif.

      if screen-group2 = 'G03'.
        screen-input = 0.
*        screen-required = '1'.
        modify screen.
      endif.

    endloop.
*Begin of <RD1K963161>.
  elseif okcode_9000 eq 'MANAGER'.
    l_emode = 'Support Manager - '.
    loop at screen.

      if screen-group1 = 'G01'.
        screen-input = 0.
        screen-invisible = '1'.
        modify screen.
      endif.

      if screen-group1 = 'G02'.
        screen-input = 1.
        screen-invisible = '0'.
        modify screen.
      endif.

      if sy-uname+0(1) = 'C' or sy-uname+0(1) = 'R' or sy-uname+0(1) = '1'
      or sy-uname+0(1) = '2' or sy-uname+0(1) = '3' or sy-uname+0(1) = '4'
      or sy-uname+0(1) = '5' or sy-uname+0(1) = '6' or sy-uname+0(1) = '7'
      or sy-uname+0(1) = '8' or sy-uname+0(1) = '9' .
        if screen-group1 = 'G04'.
          screen-input = 1.
          modify screen.
        endif.

      endif.

    endloop.
*End of <RD1K963161>.
  endif.

*  set titlebar 'AUTH' with l_emode.

endmodule.                 " set_scr_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Move_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module move_data output.
  move-corresponding ist_auth1 to ist_auth_st.
endmodule.                 " Move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Prepare_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module prepare_data output.
  if sy-tcode  = 'ZAUTH_ASSIGN'.
    set screen  0. leave to screen 100.
  endif.

  check save_code ne 'FCTDEL'.

  perform clear_all.


  get parameter id 'ZMYID' field g_myuserid.
  get parameter id 'ZSBID' field g_mysubuserid.
  get parameter id 'ZSDAT' field g_mysdate.
  get parameter id 'ZEDAT' field g_myedate.

  select  req_no into g_reqno from zauth_user_role
                                   where my_cpf_no  = g_myuserid    and
                                         sub_cpf_no = g_mysubuserid and
                                         from_dat   = g_mysdate     and
                                          to_dat     = g_myedate ORDER BY PRIMARY KEY.



  endselect.


  select * from zauth_user_role into corresponding
                                  fields of table ist_auth1
                                  where req_no = g_reqno ORDER BY PRIMARY KEY.



  select single persnumber into g_perno from usr21
                where bname = g_myuserid.

  if sy-subrc = 0 and not g_perno is initial.
    select single name_text into g_myuname from adrp
                  where persnumber = g_perno.
  endif.

  clear g_perno.

  select single persnumber into g_perno from usr21
                where bname = g_mysubuserid.
  if sy-subrc = 0 and not g_perno is initial.
    select single name_text from adrp into g_mysubuname
                        where persnumber = g_perno.
  endif.

  clear g_role_text.
  loop at ist_auth1.
    SELECT TEXT INTO G_ROLE_TEXT FROM AGR_TEXTS UP TO 1 ROWS
 WHERE AGR_NAME = IST_AUTH1-AGR_NAME AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.
      ist_auth1-text = g_role_text.
      modify ist_auth1 index sy-tabix transporting text.
    endif.
  endloop.

  delete ist_auth1 where loekz ne space.

endmodule.                 " Prepare_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0110 output.

  perform pf_status.

endmodule.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_scr_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_scr_attrib output.
  data l_del(3) type c value 'DEL'.

  get parameter id 'ZDELE' field l_del.

  if l_del = 'DEN'.
    loop at screen.
      if screen-group1 = 'D1'.
        screen-invisible = 1.
        modify screen.
      endif.
    endloop.
  endif.

endmodule.                 " set_scr_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_9000 output.

  g_disptext = 'Display'.

  clear: g_sdate, g_edate, g_reqno, g_subuname,
         g_subuserid,g_reqno_ref,g_reason,
         g_userid .
  clear wa_tab.
  refresh tab.

  move 'SAVE' to wa_tab.
  append wa_tab to tab.

  move 'DISPROLE' to wa_tab.
  append wa_tab to tab.

*Begin of <RD1K963159>.
  move 'ATTACH' to wa_tab.
  append wa_tab to tab.

  move 'LIST' to wa_tab.
  append wa_tab to tab.

  move 'DELETE' to wa_tab.
  append wa_tab to tab.
*End of <RD1K963159>.

  if sy-uname+0(1) <> 'C' .
    move 'ROLEBLK' to wa_tab.
    append wa_tab to tab.

  endif.
*Begin of <RD1K963161>.
*For Checking the Authorisation of the User for Displaying the Button Role Creation by Support Manager.
  data : it_role  type agr_name.
  clear : it_role.
  select single agr_name from agr_users into it_role where agr_name like 'C:PO_HEAD_SUPPORT_MGR%' and uname  = sy-uname.
  if sy-subrc ne 0.
    move 'MANAGER' to wa_tab.
    append wa_tab to tab.
  endif.
*End of <RD1K963161>.
  set pf-status 'ST_9000' excluding tab.
  set titlebar 'AUTH'.

endmodule.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_data output.
  data: l_lines type i.
  describe table ist_auth1_copy lines l_lines.
  if l_lines > 0.
    ist_auth1[] = ist_auth1_copy[].
  endif.

endmodule.                 " get_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0200 output.
  move 'DELETE' to wa_tab.
  append wa_tab to tab.

  set pf-status 'PF200' excluding tab.
  set titlebar 'M200'  .

endmodule.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0300 output.
  clear: wa_tab, tab.
  move 'ROLEBLK' to wa_tab.
  append wa_tab to tab.

  if ok_200 = 'DELETE'.  .
    move 'SAVE' to wa_tab.
    append wa_tab to tab.

    l_emode = 'Delete - '.
  endif.
  if ok_200 = 'DISPLAY'.  .
    move 'SAVE' to wa_tab.
    append wa_tab to tab.
    l_emode = 'Display - '.
  endif.

  set titlebar 'M200' with l_emode.
  set pf-status 'PFS300' excluding tab.

endmodule.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_roledel_item_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_roledel_item_data output.

  check not g_del_reqno is initial.
  refresh ist_roledel_item.

  select single * from zroledel_head where roledel_req_no = g_del_reqno.

  select  item_no role  into corresponding fields of table
  ist_roledel_item from zroledel_item where roledel_req_no = g_del_reqno.

  describe table ist_roledel_item lines tctrl_300-lines.

  SELECT * FROM ZAUTH_USER_ROLE UP TO 1 ROWS

 WHERE REQ_NO = ZROLEDEL_HEAD-REF_REQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc = 0.
    g_delegated_by = zauth_user_role-my_cpf_no.
    g_delegated_to = zauth_user_role-sub_cpf_no.
    g_from_date    = zauth_user_role-from_dat.
    g_to_date      = zauth_user_role-to_dat.
    g_ref_reqno    = zauth_user_role-req_no.
  else.
    clear: g_delegated_by, g_delegated_to,
          g_from_date, g_to_date, g_ref_reqno.
  endif.
endmodule.                 " get_roledel_item_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  fill_tbc300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module fill_tbc300 output.
  zroledel_item-item_no = ist_roledel_item-item_no.
  zroledel_item-role    = ist_roledel_item-role.
endmodule.                 " fill_tbc300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_req_no  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module get_req_no output.

  clear ok_code.

  refresh ist_refer.


  move : 'ZROLEDEL_HEAD'   to   ist_refer-tabname,
         'ROLEDEL_REQ_NO'  to   ist_refer-fieldname,
         'X'               to   ist_refer-field_obl.

  append ist_refer.

  g_str = 'Select Assigned Request no for Curtail'.

  get parameter id 'ZAUTHREQ' field ist_refer-value.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = g_str
    TABLES
      fields          = ist_refer
    EXCEPTIONS
      error_in_fields = 0
      others          = 0.

  read table ist_refer with key fieldname = 'ROLEDEL_REQ_NO'.
  g_del_reqno = ist_refer-value.
  select single * from zroledel_head
                     where roledel_req_no = g_del_reqno.
  if sy-subrc <> 0.
    message e812(zbc).
  endif.
  set parameter id 'ZAUTHREQ' field ' '.

endmodule.                 " get_req_no  OUTPUT
