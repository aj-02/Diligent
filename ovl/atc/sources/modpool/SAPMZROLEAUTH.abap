*--- MAIN PROGRAM: SAPMZROLEAUTH ---*

PROGRAM sapmzusrrolereq .
***********************************************************************
* Program    : SAPMZUSRROLEREQ                                        *
*                                                                     *
* Title      : User Authorization                                     *
*                                                                     *
* FS No      :                                                        *
*                                                                     *
* Author     : Kalpesh B.                 Date :                      *
*                                                                     *
* Login Id   : SAB_KALPESH                                            *
*                                                                     *
* Desciption : User assign roles to another user when he goes on      *
*              transfer or leave for the given period                 *
*                                                                     *
* Transaction Code : ZAUTH_ASSIGN                                     *
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
*                                                                     *
*                                                                     *
***********************************************************************

INCLUDE mzroleauthtop.
*INCLUDE MZUSRROLEREQTOP.

INCLUDE mzroleautho01.
*INCLUDE MZUSRROLEREQO01.

INCLUDE mzroleauthi01.
*INCLUDE MZUSRROLEREQI01.

INCLUDE mzroleauthf01.
*INCLUDE MZUSRROLEREQF01.

*--- INCLUDE: %_CCXTAB ---*
TYPE-POOL CXTAB .

TYPES:
       CXTAB_COLUMN type scxtab_column,
       CXTAB_CONTROL type scxtab_control,
       CXTAB_TABSTRIP type scxtab_tabstrip.

*--- INCLUDE: MZROLEAUTHF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZUSRROLEREQF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  prepare_saving
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_saving.
  data g_ans.
  data g_rema(80) type c.
  data g_item like ist_zauthitem-item_no.
  data g_tit type string.

*Begin of <>
*  if not g_reqno is initial.
  if not L_VAL is initial.
*End of <>.
    concatenate 'Change request no' L_VAL into g_tit
      separated by space.
  else.
    g_tit = 'Create New Request'.
  endif.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = g_tit
      text_question  = 'Are you sure you want to Save data?'
      text_button_1  = 'Ja'(004)
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'Nein'(005)
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
    IMPORTING
      answer         = g_ans
    EXCEPTIONS
      text_not_found = 1
      others         = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  if g_ans = '1'.
    if okcode_9000 = 'CREA'.
      clear g_reqno.

*    CLEAR g_ans.
*    IF g_sdate LT sy-datum.  "and okcode_9000 <> 'CHAN'.
*      MESSAGE e091(zbc).
*    ENDIF.

      clear zauth_user_role.
      read table ist_auth1 index 1.

*    SELECT MAX( req_no ) INTO g_reqno FROM zauth_user_role.
*    g_reqno = g_reqno + 1.

*    if okcode_9000 = 'CREA' or okcode_9000 = 'REFER'.
*      clear g_reqno.
*Begin of <RD1K963161>.
*      perform get_next_number.
*End of <RD1K963161>.
*    endif.

      clear zauth_head.

      concatenate 'Assign Roles of User' g_userid
                  'To' g_subuserid 'for period' g_sdate 'to' g_edate
      into g_rema separated by space.
*Begin of <RD1K963161>.
*      zauth_head-auth_req_no = g_reqno.
      zauth_head-auth_req_no = L_VAL.
*End of <RD1K963161>.
      zauth_head-auth_req_date = sy-datum.
      zauth_head-requested_by = sy-uname.
      zauth_head-remarks = g_rema.
      zauth_head-released_on = sy-datum.
      zauth_head-approved_on = sy-datum.
      zauth_head-approved_by = sy-uname.
      zauth_head-oonumber    = g_oo_no.
      clear ist_auth1.
      refresh ist_zauthitem.
      clear ist_zauthitem.

      clear g_item.

      loop at ist_auth1.
        ist_zauthitem-auth_req_no = zauth_head-auth_req_no.
        ist_zauthitem-item_no = g_item + 1.
        g_item = g_item + 1.
        ist_zauthitem-cpf_no = g_subuserid.
        ist_zauthitem-role = ist_auth1-agr_name.
        ist_zauthitem-from_dat = g_sdate.
*      ist_zauthitem-to_dat = g_edate.
        ist_zauthitem-to_dat = ist_auth1-to_dat.
        append ist_zauthitem.
*Begin of <RD1K963161>.
*        move g_reqno to ist_auth1-req_no.
        move L_VAL to ist_auth1-req_no.
*End of <RD1K963161>.
        move g_sdate to ist_auth1-from_dat.
        move g_edate to ist_auth1-to_dat.
        move g_subuserid to ist_auth1-sub_cpf_no.
        move g_reason to ist_auth1-reason.

        modify ist_auth1 index sy-tabix
            transporting req_no from_dat to_dat sub_cpf_no reason.
      endloop.

      loop at ist_auth1.
        move-corresponding ist_auth1 to zauth_user_role.
        modify zauth_user_role.
      endloop.

      modify zauth_head .
      modify zauth_item from table ist_zauthitem.

*      if sy-subrc = 0.
**Begin of <RD1K963161>.
**        message i093(zbc) with g_reqno.
*        call function 'ZXX_SU02'
*        destination 'ROLE_ASN_RFC'
*       exporting
*       auth_req_no                 = l_val
*       exceptions
*      role_assignment_error       = 1.
*if sy-subrc = 0.
*         message i093(zbc) with l_val..
**End of <RD1K963161>.       .
*      endif.
*      endif.
    endif.
*Begin of <RD1K963161>.
    break cab_rama.
    if g_ans = '1'.
      if OKCODE_9000 = 'MANAGER'.
        clear l_val.
        PERFORM get_next_number.
        if g_reqno is NOT INITIAL.
          clear zauth_user_role.
          read table ist_auth1 index 1.
          clear zauth_head.

          concatenate 'Assign Roles of User' g_userid
                     'To' g_subuserid 'for period' g_sdate 'to' g_edate
          into g_rema separated by space.
          zauth_head-auth_req_no = L_VAL.
          zauth_head-auth_req_date = sy-datum.
          zauth_head-requested_by = sy-uname.
          zauth_head-remarks = g_rema.
          zauth_head-released_on = sy-datum.
          zauth_head-approved_on = sy-datum.
          zauth_head-approved_by = sy-uname.
          zauth_head-oonumber    = g_oo_no.
          clear ist_auth1.
          refresh ist_zauthitem.
          clear ist_zauthitem.

          clear g_item.

          loop at ist_auth1.
            ist_zauthitem-auth_req_no = zauth_head-auth_req_no.
            ist_zauthitem-item_no = g_item + 1.
            g_item = g_item + 1.
            ist_zauthitem-cpf_no = g_subuserid.
            ist_zauthitem-role = ist_auth1-agr_name.
            ist_zauthitem-from_dat = g_sdate.
            ist_zauthitem-to_dat = ist_auth1-to_dat.
            append ist_zauthitem.
            move L_VAL to ist_auth1-req_no.
            move g_sdate to ist_auth1-from_dat.
            move g_edate to ist_auth1-to_dat.
            move g_subuserid to ist_auth1-sub_cpf_no.
            move g_reason to ist_auth1-reason.

            modify ist_auth1 index sy-tabix
                transporting req_no from_dat to_dat sub_cpf_no reason.
          endloop.

          loop at ist_auth1.
            move-corresponding ist_auth1 to zauth_user_role.
            modify zauth_user_role.
          endloop.

          modify zauth_head .
          modify zauth_item from table ist_zauthitem.

*      if sy-subrc = 0.
*         message i093(zbc) with l_val..
*         clear l_val.
*    endif.
        endif.
      endif.
*End of <RD1K963161>.
      if ok_200 = 'CREATE'.

        select max( roledel_req_no ) into g_del_reqno from
         zroledel_head .


        add 1 to g_del_reqno.
        EXPORT g_del_reqno to MEMORY id 'ID3'.
        move g_del_reqno to wa_roledel_head-roledel_req_no.
        move sy-datum to    wa_roledel_head-roledel_req_date.
        move sy-datum to    wa_roledel_head-released_on.
        move sy-datum to    wa_roledel_head-approved_on.
        wa_roledel_head-requested_by = sy-uname.
        wa_roledel_head-approved_by = sy-uname.
        wa_roledel_head-ref_reqno   = g_reqno_ref.
        insert into zroledel_head values wa_roledel_head.
        if sy-subrc <> 0.
          message i806(zbc).
        else.

          loop at ist_auth1.
            wa_roledel_item-roledel_req_no = g_del_reqno.
            wa_roledel_item-item_no = ist_auth1-itemno.
            wa_roledel_item-cpf_no  = g_subuserid.
            wa_roledel_item-role    = ist_auth1-agr_name.
*Begin of <RD1K963161>.
            wa_roledel_item-from_dat = ist_auth1-from_dat.
            wa_roledel_item-to_dat = ist_auth1-to_dat.
*End of <RD1K963161>.
            insert into zroledel_item values wa_roledel_item.
            if sy-subrc <> 0.
              message i807(zbc).
            endif.
          endloop.
          message i809(zbc) with g_del_reqno.
        endif.

      endif.
    endif.
  endif.

*if OK_200 = 'CREATE' and OKCODE_9000 = 'CURTAIL'.
*  SUBMIT ZBC_ROLE_REP01_RFC_DEL and RETURN.
*  endif.
endform.                    " prepare_saving

*&---------------------------------------------------------------------*
*&      Form  clear_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form clear_all.

  clear : g_userid,
  g_perno,
          g_subuserid,
          g_reqno,
          g_uname,
          g_subuname,
          g_sdate,
          g_edate,
          g_reason,
          ist_auth1,
          ist_auth_st.

  refresh control 'TCTRL_100' from screen 100.

  refresh: ist_auth1, ist_auth1_copy.
  clear zauth_user_role.
endform.                    " clear_all

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form get_data.
  data : l_del(3) type c value 'FOR'.

  data l_loekz type c.

  clear : g_perno, save_code.
  refresh : ist_auth1, ist_auth2_cpfno, ist_auth2_subcpfno.


  ranges : r_mycpfdat for zauth_user_role-from_dat,
           r_subcpf for zauth_user_role-to_dat.

  set parameter id 'ZDELE' field l_del.


* Get subcpfno full name.
  select single persnumber into g_perno from usr21
                where bname = g_subuserid.
  if sy-subrc = 0 and not g_perno is initial.
    select single name_text from adrp into g_subuname
                        where persnumber = g_perno.
  endif.

* Get data to display in table control
  select agr_name from_dat to_dat
    from agr_users
    into corresponding fields of table ist_auth2_cpfno
    where uname = g_userid .

  sort ist_auth2_cpfno by agr_name.

  select agr_name from_dat to_dat
    from agr_users
    into corresponding fields of table ist_auth2_subcpfno
   where uname = g_subuserid .

  sort ist_auth2_subcpfno by agr_name.

  clear zauth_user_role.
  data: flag,
        wa_auth2 type ty_auth2 .

  loop at ist_auth2_cpfno.
    if g_sdate ge ist_auth2_cpfno-from_dat and
        g_edate le ist_auth2_cpfno-to_dat.

    else.
      flag = 'N'.
      clear: g_to_date.
*      BREAK-POINT.
      perform find_delegated_roles changing flag.

      if flag = 'N'.
        delete ist_auth2_cpfno.
      else.
        move ist_auth2_cpfno to wa_auth2.
        wa_auth2-to_dat = g_to_date.
        modify ist_auth2_cpfno from wa_auth2.
      endif.
    endif.
  endloop.

  loop at ist_auth2_subcpfno.
    if g_sdate ge ist_auth2_subcpfno-from_dat and
       g_edate le ist_auth2_subcpfno-to_dat.

    else.
      delete ist_auth2_subcpfno.
    endif.
  endloop.

  loop at ist_auth2_cpfno.
    SELECT TEXT INTO G_ROLE_TEXT FROM AGR_TEXTS UP TO 1 ROWS
 WHERE AGR_NAME = IST_AUTH2_CPFNO-AGR_NAME AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.
      ist_auth2_cpfno-text = g_role_text.
      modify ist_auth2_cpfno index sy-tabix transporting text.
    endif.
  endloop.

  loop at ist_auth2_subcpfno.
    SELECT TEXT INTO G_ROLE_TEXT FROM AGR_TEXTS UP TO 1 ROWS
 WHERE AGR_NAME = IST_AUTH2_SUBCPFNO-AGR_NAME AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    if sy-subrc = 0.
      ist_auth2_subcpfno-text = g_role_text.
      modify ist_auth2_subcpfno index sy-tabix transporting text.
    endif.
  endloop.

  loop at ist_auth2_cpfno.
    read table ist_auth2_subcpfno with key
                             agr_name = ist_auth2_cpfno-agr_name.
    if sy-subrc = 0.
      delete ist_auth2_cpfno.
    endif.

  endloop.

  delete adjacent duplicates from ist_auth2_cpfno comparing agr_name.
*--- Subtract roles defined in table ZROELS.


  data: l_role type zroles.
  loop at ist_auth2_cpfno.
    select single * into l_role from zroles
        where role = ist_auth2_cpfno-agr_name.
    if sy-subrc = 0.
      delete ist_auth2_cpfno.
    endif.

  endloop.


*--- Subtract end.


  refresh ist_auth2_subcpfno.

  read table ist_auth2_cpfno index 1.
  if sy-subrc ne 0.
   message e803(zmm) with 'Roles between Source & Target ID are common'
 sy-uname.
  endif.

  loop at ist_auth2_cpfno.
    move-corresponding ist_auth2_cpfno to ist_auth1.
    if ist_auth1-to_dat le  g_edate   .

    else.
      move g_edate  to ist_auth1-to_dat.
    endif.
    move : g_sdate  to ist_auth1-from_dat,
         g_userid    to ist_auth1-my_cpf_no,
         g_subuserid to ist_auth1-sub_cpf_no,
         g_reason  to ist_auth1-reason,
         sy-uname    to ist_auth1-ernam,
         sy-datum    to ist_auth1-erfdt.

    CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
      EXPORTING
        i_datum           = sy-datum
        i_time            = sy-uzeit
      IMPORTING
        e_timestamp       = ist_auth1-timestamp
      EXCEPTIONS
        date_not_received = 1
        time_not_received = 2
        others            = 3.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    append ist_auth1.
  endloop.

  loop at ist_auth1.
    move : sy-tabix to ist_auth1-itemno .
    modify ist_auth1 index sy-tabix transporting itemno.
  endloop.

  delete ist_auth1 where loekz ne space.

  refresh ist_auth2_cpfno.
endform.                    " get_data

*&---------------------------------------------------------------------*
*&      Form  validate_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form validate_field.
  data : l_flag type c,
         l_flag2 type c.

data : ist_temp type standard table of zauth_user_role with header line.
data :ist_temp_1 type standard table of zauth_user_role with header line
.
  data : wa_temp_1 type zauth_user_role.

  if g_subuserid is initial or g_sdate is initial or g_edate is initial.
    message e090(zbc).
  endif.

  if sy-tcode <> 'ZDELEGATE'.
    if g_sdate lt sy-datum and okcode_9000 <> 'DISP'.
      message e091(zbc).
    endif.
  elseif sy-tcode = 'ZDELEGATE'.
    if g_edate lt sy-datum and okcode_9000 <> 'DISP'.
      message e900(zbc) with 'End date cannot be less than Current Date.Role Already deleted'.
    endif.
  endif.
  if g_edate lt g_sdate and okcode_9000 <> 'DISP'.
    message e092(zbc).
  endif.

  select single * from usr02 where bname = g_subuserid.
  if sy-subrc <> 0.
    message e089(zbc) with g_subuserid.
  endif.

  clear zauth_head.
*Begin of <RD1K963161>.
*  if okcode_9000 = 'CREA' .
  if okcode_9000 = 'CREA' or okcode_9000 = 'MANAGER'.
*End of <RD1K963161>.
    select * from zauth_user_role
    into table ist_temp
    where my_cpf_no = g_userid and sub_cpf_no = g_subuserid and
          assigned_by eq space .

    if sy-subrc = 0.

      loop at ist_temp.
        if g_sdate gt ist_temp-to_dat and
            g_edate gt ist_temp-to_dat.

          delete ist_temp.
        else.
        endif.
      endloop.

**{

*ist_temp_1[] = ist_temp[].
*
*sort ist_temp_1 by req_no.
*delete adjacent duplicates from ist_temp_1 comparing req_no.
*
      data : ist_zauth_user_role type standard table of zauth_user_role,
             wa_zauth_user_role type zauth_user_role.
      data : l_flag_err.
      clear l_flag_err.

      select * from zauth_user_role
      into corresponding fields of table ist_zauth_user_role
      where MY_CPF_NO = zauth_user_role-my_cpf_no
      and SUB_CPF_NO = zauth_user_role-sub_cpf_no
      and FROM_DAT = zauth_user_role-FROM_DAT
      and TO_DAT = zauth_user_role-to_DAT ORDER BY PRIMARY KEY.

      if sy-subrc = 0.
        read table ist_zauth_user_role into wa_zauth_user_role index 1.
        l_flag_err = 'X'.
      endif.
*
**select * from zroledel_head
**into corresponding fields of table ist_zauth_user_role
**for all entries in ist_temp_1
**where ref_reqno = ist_temp_1-req_no.
*
*data : wa_zauth_user_role type zauth_user_role.
*
*loop at ist_temp_1 into wa_temp_1.
*select single * from zroledel_head
*into corresponding fields of wa_zauth_user_role
*where ref_reqno = wa_temp_1-req_no.
*if sy-subrc = 0.
*
*else.
*l_flag_err = 'X'.
*endif.
*endloop.
      break cab_rama.
      if l_flag_err = 'X'.
        concatenate 'Roles are already assigned in Request no'
                    wa_zauth_user_role-req_no into g_str separated by
space.
        message e803(zmm) with g_str.
      endif.
**}
*      MESSAGE e106(zbc) WITH zauth_user_role-my_cpf_no
*                      zauth_user_role-sub_cpf_no.

*{commented
*      if not ist_temp[] is initial.
*
*        read table ist_temp index 1.
*        concatenate 'Roles are already assigned in Request no'
*                    ist_temp-req_no into g_str separated by space.
*        message e803(zmm) with g_str.
*
*      endif.
*}commented rama
*    SELECT SINGLE * FROM zauth_head
*        WHERE auth_req_no = zauth_user_role-req_no.
*
*    IF NOT zauth_head-released_on IS INITIAL.
*      MESSAGE e106(zbc) WITH zauth_user_role-my_cpf_no
*      zauth_user_role-sub_cpf_no.
*    ENDIF.

    endif.

  endif.

endform.                    " validate_field

*&---------------------------------------------------------------------*
*&      Form  F4help_start_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f4help_start_date.

  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month         = sy-datum
    IMPORTING
      select_date                  = g_sdate
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      date_after_range             = 2
      date_before_range            = 3
      date_invalid                 = 4
      factory_calendar_not_found   = 5
      holiday_calendar_not_found   = 6
      parameter_conflict           = 7
      others                       = 8.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " F4help_start_date

*&---------------------------------------------------------------------*
*&      Form  F4help_end_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f4help_end_date.
  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month         = sy-datum
    IMPORTING
      select_date                  = g_edate
    EXCEPTIONS
      calendar_buffer_not_loadable = 1
      date_after_range             = 2
      date_before_range            = 3
      date_invalid                 = 4
      factory_calendar_not_found   = 5
      holiday_calendar_not_found   = 6
      parameter_conflict           = 7
      others                       = 8.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " F4help_end_date
*&---------------------------------------------------------------------*
*&      Form  pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form pf_status.

  data l_del(3) type c value 'DEL'.

*move 'BACK' to wa_fcode.
*append wa_fcode to ist_fcode.

  move 'SAVE' to wa_fcode.
  append wa_fcode to ist_fcode.

*move 'CANC' to wa_fcode.
*append wa_fcode to ist_fcode.

  set pf-status '100' excluding ist_fcode.
  set titlebar 'T100' with tstct-ttext.

  read table ist_auth1 index 1.

  if not ist_auth1 is initial.

    refresh ist_fcode.

*move 'BACK' to wa_fcode.
*append wa_fcode to ist_fcode.

*move 'CANC' to wa_fcode.
*append wa_fcode to ist_fcode.

    get parameter id 'ZDELE' field l_del.

    if l_del = 'DEN'.
      move 'SAVE' to wa_fcode.
      append wa_fcode to ist_fcode.
    endif.

    set pf-status '100' excluding ist_fcode.

    set titlebar '110'.
  else.


  endif.

endform.                    " pf_status
*&---------------------------------------------------------------------*
*&      Form  delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form delete.
  loop at ist_auth_del where mark = 'X'.
    update zauth_user_role set loekz = 'D'
                               where req_no   = ist_auth_del-req_no and
                                       agr_name = ist_auth_del-agr_name.
  endloop.

  if sy-subrc = 0.
    message i102(zbc).
  endif.
  set screen 0.
  leave screen.

endform.                    " delete
*&---------------------------------------------------------------------*
*&      Form  refresh_clear_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form refresh_clear_all.
  clear : g_myuserid,
          g_mysubuserid,
          g_reqno,
          g_myuname,
          g_mysubuname,
          g_mysdate,
          g_myedate,
          ist_auth1,
          ist_auth_st,
          ist_auth_del.

  refresh : ist_auth1, ist_auth_del.

*free memory.

endform.                    " refresh_clear_all

*&---------------------------------------------------------------------*
*&      Form  popup_to_confirm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form popup_to_confirm using    l_text1
                               l_text2
                               l_action.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = l_text1
      text_question         = l_text2
      text_button_1         = 'YES'
      icon_button_1         = 'ICON_OKAY '
      text_button_2         = 'NO'
      icon_button_2         = 'ICON_REJECT '
      default_button        = '1'
      display_cancel_button = 'X'
      start_column          = 25
      start_row             = 6
    IMPORTING
      answer                = l_action
    EXCEPTIONS
      text_not_found        = 1
      others                = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " popup_to_confirm

*&---------------------------------------------------------------------*
*&      Form  exit_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form exit_screen.
  refresh : ist_auth1.
  clear : ist_auth_st,
          ist_auth1.
  clear: g_uname, g_status.
  refresh control 'TCTRL_100' from screen 100.
endform.                    " exit_screen
*&---------------------------------------------------------------------*
*&      Form  get_next_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form get_next_number.
  data: rc         like inri-returncode.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZROLEREQ'
      quantity                = '1'
    IMPORTING
      number                  = g_reqno
      returncode              = rc
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      others                  = 8.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
           with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  l_val = g_reqno.
endform.                    " get_next_number
*&---------------------------------------------------------------------*
*&      Form  get_reference
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_reference.

  refresh ist_refer.
  clear: g_reqno, g_reqno_ref,ist_refer-value.

  move : 'ZAUTH_USER_ROLE'   to   ist_refer-tabname,
         'REQ_NO'            to   ist_refer-fieldname,
         'X'                 to   ist_refer-field_obl.

  append ist_refer.

  g_str = 'Select Approved Request no for Reference'.

endform.                    " get_reference
*&---------------------------------------------------------------------*
*&      Form  pop_up_get_refer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_STR  text
*----------------------------------------------------------------------*
form pop_up_get_refer.
*  clear: g_reqno, g_reqno_ref,ist_refer-value.

  get parameter id 'ZAUTHREQ' field ist_refer-value.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title     = g_str
    TABLES
      fields          = ist_refer
    EXCEPTIONS
      error_in_fields = 0
      others          = 0.

  read table ist_refer with key fieldname = 'REQ_NO'.
  if sy-subrc = 0.
    g_reqno_ref = ist_refer-value.
    g_reqno =     ist_refer-value.
  endif.
  SELECT * FROM ZAUTH_USER_ROLE UP TO 1 ROWS
 WHERE
 REQ_NO = G_REQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-uname+0(1) = 'C' .
  else.
    if zauth_user_role-my_cpf_no <> sy-uname.
      message e814(zbc) with zauth_user_role-my_cpf_no.
    endif.
  endif.



  data: l_reqno type zroledel_head-roledel_req_no,
        l_date  type zroledel_head-roledel_req_date.

  SELECT ROLEDEL_REQ_NO ROLEDEL_REQ_DATE INTO
 ( L_REQNO , L_DATE ) FROM ZROLEDEL_HEAD UP TO 1 ROWS WHERE REF_REQNO = G_REQNO_REF
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  if sy-subrc = 0.
    message e813(zbc) with l_reqno  l_date.
  endif.

  refresh ist_auth1.

  select * from zauth_user_role
  into corresponding fields of table ist_auth1
        where req_no = g_reqno_ref ORDER BY PRIMARY KEY.

  if not ist_auth1[] is initial.

    clear zauth_head.
    select single * from zauth_head
        where auth_req_no = g_reqno_ref.

    if zauth_head-created_by is initial.
      concatenate 'Request:' g_reqno_ref
          'not assigned.Can not Curtail'
      into g_str separated by space.
      message e803(zmm) with g_str.
    endif.

    read table ist_auth1 index 1.

    if ist_auth1-to_dat < sy-datum.

      concatenate 'Request No: ' g_reqno_ref
          'is not revelent for reference. Please check!'
      into g_str separated by space.
*      message e803(zmm) with g_str.
      message e817(zbc).
    endif.

    g_subuserid = ist_auth1-sub_cpf_no.
*    g_sdate = sy-datum.   "ist_auth1-from_dat.
*    g_edate = sy-datum.
    g_sdate = ist_auth1-from_dat.
    g_edate = ist_auth1-to_dat.
    g_reason = ist_auth1-reason.
    g_oo_no  = zauth_head-oonumber.
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

  else.

    concatenate 'Request No: ' g_reqno_ref
        'not found!'
    into g_str separated by space.
    message e803(zmm) with g_str.

  endif.
  set parameter id 'ZAUTHREQ' field ' '.

*  g_ok_code1 = 'REFER'.
  clear : ist_refer.


endform.                    " pop_up_get_refer
*&---------------------------------------------------------------------*
*&      Form  find_delegated_roles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_FLAG  text
*----------------------------------------------------------------------*
form find_delegated_roles changing p_flag.

  data: l_reqno type zauth_user_role-req_no,
        l_created_by type zauth_head-created_by.

  SELECT REQ_NO TO_DAT INTO
 ( L_REQNO , G_TO_DATE ) FROM ZAUTH_USER_ROLE UP TO 1 ROWS WHERE SUB_CPF_NO = G_USERID AND TO_DAT GE G_SDATE AND TO_DAT LE G_EDATE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc = 0.
    select single created_by into l_created_by from zauth_head
    where auth_req_no = l_reqno.
    if sy-subrc = 0.
      p_flag = 'Y'.
    endif.
  endif.
endform.                    " find_delegated_roles
*&---------------------------------------------------------------------*
*&      Form  get_ref_delreq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_ref_delreq.
  clear ok_code.

  refresh ist_refer.

  clear: g_reqno,g_reqno_ref,ist_refer-value.

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
endform.                    " get_ref_delreq
*&---------------------------------------------------------------------*
*&      Form  save_data_300
*&---------------------------------------------------------------------*
*       text
*&---------------------------------------------------------------------*
*&      Form  ATTACH_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ATTACH_FILE .
  clear g_att_files_wa.
  refresh g_att_files.

  g_att_files_wa-logsys = l_val.
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.
  append g_att_files_wa to g_att_files.

  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
    EXPORTING
      attachment_data     = ''
      attachment_type     = 'DOC'
    TABLES
      application_objects = g_att_files.
endform.                    " ATTACH_FILE
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form LIST_DISPLAY .
  g_att_files_wa-logsys = g_reqno.
  g_att_files_wa-objtype = 'ATT'.
  g_att_files_wa-objkey = '01'.

  call function 'SO_WIND_ATTACHMENT_LIST_API1'
    exporting
      application_object       = g_att_files_wa
*   FUNCTION                 = ' '
* TABLES
*   FUNC_EXCLUDE             =
            .
endform.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_ROLES .
  data : AUTH_REQ_NO LIKE  ZAUTH_HEAD-AUTH_REQ_NO  .
  move l_val to AUTH_REQ_NO.
* call function 'ZXX_SU02'
***  DESTINATION 'CLNT200_V'
**destination 'ROLE_ASN_RFC'
*  exporting
*    auth_req_no                 = auth_req_no
* exceptions
*   role_assignment_error       = 1
**   OTHERS                      = 2
*
  export l_val to MEMORY id 'ID2'.
  submit zbc_role_rep01_rfc AND RETURN.
  if sy-subrc = 0.
*    message i093(zbc) with l_val.
*End of <RD1K963161>.       .
  endif.
ENDFORM.                    " ASSIGN_ROLES

*--- INCLUDE: MZROLEAUTHI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZUSRROLEREQI01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  Get_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data INPUT.
*  g_days = g_edate - g_sdate.
*  if okcode_9000 = 'CREA' and g_days > 30.
*    clear: g_sdate, g_edate.
*    message e803(zbc).
*  endif.

  IF okcode_9000 = 'CREA'.
    DESCRIBE TABLE ist_auth1_copy LINES l_lines.
    IF l_lines = 0.
      PERFORM get_data.
    ENDIF.
  ENDIF.
*Begin of <RD1K963161>.
  IF okcode_9000 = 'MANAGER'.
    DESCRIBE TABLE ist_auth1_copy LINES l_lines.
    IF l_lines = 0.
      PERFORM get_data.
    ENDIF.
  ENDIF.
*End of <RD1K963161>.
ENDMODULE.                 " Get_data  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_100 INPUT.

  PERFORM popup_to_confirm USING text-001 text-002 g_action.
  IF g_action EQ '1'.
    PERFORM exit_screen.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.                 " exit_100  INPUT

*&---------------------------------------------------------------------*
*&      Module  check_request  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_request INPUT.

  PERFORM validate_field.

ENDMODULE.                 " check_request  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'DEL'.
      DELETE ist_auth1 WHERE mark = 'X'.
      ist_auth1_copy[] = ist_auth1[].
      CLEAR ok_code.

    WHEN 'SAVE'.
      CLEAR ok_code.
      PERFORM prepare_saving ."ON COMMIT.
      COMMIT WORK.
*Begin of <RD1K963159>.
      if OKCODE_9000 ne 'CURTAIL'.
        PERFORM assign_roles.
      endif.
      if OK_200 = 'CREATE' and OKCODE_9000 = 'CURTAIL'.
        SUBMIT ZBC_ROLE_REP01_RFC_DEL and RETURN.
      endif.
*End of <RD1K963159>.
      PERFORM clear_all.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'STOP' OR  'BACK'.
      CLEAR ok_code.
      PERFORM popup_to_confirm USING text-001 text-002 g_action.
      IF g_action EQ '1'.
        PERFORM exit_screen.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.

*Begin of <RD1K963159>.
    WHEN 'ATTACH'.
      PERFORM attach_file.
    WHEN 'LIST'.
      PERFORM list_display.
*End of <RD1K963159>.
    WHEN 'DELETE'.
      DATA: l_action .
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = text-006
          text_question         = text-007
          text_button_1         = 'Yes'
          icon_button_1         = 'ICON_OKAY'
          text_button_2         = 'No'
          icon_button_2         = 'ICON_REJECT'
*         default_button        = '1'
          display_cancel_button = 'X'
          start_column          = 25
          start_row             = 6
        IMPORTING
          answer                = l_action
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      DATA: l_assigned_by(12) TYPE c.
      IF l_action = '1'.
        CLEAR l_assigned_by.
        SELECT SINGLE created_by INTO l_assigned_by
             FROM zauth_head
             WHERE auth_req_no = g_reqno .

        IF l_assigned_by = space.

          DELETE FROM zauth_user_role WHERE req_no = g_reqno.
          DELETE FROM zauth_head WHERE auth_req_no = g_reqno.
          IF sy-subrc = 0.
            MESSAGE i816(zbc).
            LEAVE TO SCREEN 9000.
          ENDIF.
        ELSE.
          MESSAGE i802(zbc).
        ENDIF.
      ENDIF.
      CLEAR ok_code.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  get_date  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_sdate INPUT.

  PERFORM f4help_start_date.

ENDMODULE.                    "get_sdate INPUT

*---------------------------------------------------------------------*
*       MODULE get_edate INPUT                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE get_edate INPUT.

  PERFORM f4help_end_date.

ENDMODULE.                 " get_date  INPUT

*&---------------------------------------------------------------------*
*&      Module  read_table_control  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_table_control INPUT.
  MODIFY ist_auth1 FROM ist_auth_st INDEX tctrl_100-current_line
                          TRANSPORTING mark.

ENDMODULE.                 " read_table_control  INPUT

*&---------------------------------------------------------------------*
*&      Module  delete_row  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_row INPUT.
  MODIFY ist_auth1 FROM ist_auth_st INDEX tctrl_110-current_line
                           TRANSPORTING mark.
ENDMODULE.                 " delete_row  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.
  CASE save_code.
    WHEN 'FCTDEL'.
      LOOP AT ist_auth1.
        MOVE ist_auth1 TO ist_auth_del.
        APPEND ist_auth_del.
      ENDLOOP.

      DELETE ist_auth1 WHERE mark = 'X'.

    WHEN 'SAVE'.
      PERFORM delete ON COMMIT.
      COMMIT WORK.
      PERFORM refresh_clear_all.
      LEAVE SCREEN.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*&      Module  FCODE_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fcode_exit INPUT.
  CASE ok_code.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' .

      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " FCODE_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  DATA: ch1.
  CLEAR g_oo_no.
  REFRESH: ist_auth1, ist_auth1_copy.
  CASE ok_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'ROLEBLK'.
      CALL TRANSACTION 'ZROLES'.
    WHEN 'CREA'.
*Begin of <RD1K963161>.
      PERFORM get_next_number.
*End of <RD1K963161>.
      okcode_9000 = ok_code.
      CLEAR: g_userid, g_subuserid, g_sdate, g_edate,
             ok_code.

      CLEAR tab.
      REFRESH tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHAN' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*      MOVE 'DELE' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
      MOVE 'REFER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ROLEBLK' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*Begin of <RD1K963124>.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'MANAGER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*End of <RD1K963124>.
      ch1 = sy-uname+0(1).
      IF ch1 = 'C' OR ch1 = 'R'.
        CALL SCREEN 100.
      ELSE.
*        move 'DISPROLE' to wa_tab-fcode.
*        append wa_tab to tab.

        CALL SCREEN 105.
      ENDIF.
    WHEN 'CHAN'.

      okcode_9000 = ok_code.
      CLEAR ok_code.

** to set the PF Status.
      CLEAR tab.
      REFRESH tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHAN' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'REFER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ROLEBLK' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*Begin of <RD1K963124>.
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'MANAGER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*End of <RD1K963124>.
      ch1 = sy-uname+0(1).
      IF ch1 = 'C' OR ch1 = 'R'.
        CALL SCREEN 100.
      ELSE.
        CALL SCREEN 105.
      ENDIF.

    WHEN 'DISP'.

      okcode_9000 = ok_code.
      CLEAR ok_code.

** to set the PF Status.
      CLEAR tab.
      REFRESH tab.
      MOVE 'CHAN' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'SAVE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'REFER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ROLEBLK' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*Begin of <RD1K963124>.
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'MANAGER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*End of <RD1K963124>.
      ch1 = sy-uname+0(1).
      IF ch1 = 'C' OR ch1 = 'R' .
        CALL SCREEN 100.
      ELSE.
        CALL SCREEN 105.
      ENDIF.

    WHEN 'DELETE'.

      okcode_9000 = ok_code.
      CLEAR ok_code.

      CLEAR tab.
      REFRESH tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHAN' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'SAVE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'REFER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ROLEBLK' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*Begin of <RD1K963124>.
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'MANAGER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
*End of <RD1K963124>.

      ch1 = sy-uname+0(1).
      IF ch1 = 'C' OR ch1 = 'R'.
        CALL SCREEN 100.
      ELSE.
        CALL SCREEN 105.
      ENDIF.

*    WHEN 'REFER'.
*
*      okcode_9000 = ok_code.
*      CLEAR ok_code.
*
*      CLEAR tab.
*      REFRESH tab.
*      MOVE 'CHAN' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'DISP' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'CREA' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'DELETE' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'REFER' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'DISPROLE' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*      MOVE 'CURTAILED' TO wa_tab-fcode.
*      APPEND wa_tab TO tab.
*
*      PERFORM get_reference.
*
*      PERFORM pop_up_get_refer.
*
*      IF sy-ucomm NE 'CANC'.
*
*        ch1 = sy-uname+0(1).
*        IF ch1 = 'C' OR ch1 = 'R'.
*          CALL SCREEN 100.
*        ELSE.
*          CALL SCREEN 105.
*        ENDIF.
*
*      ENDIF.
    WHEN 'CURTAIL'.

      okcode_9000 = ok_code.
      CLEAR ok_code.

      CLEAR tab.
      REFRESH tab.
      CALL SCREEN 200.
*Begin of <RD1K963124>.
    WHEN 'MANAGER'.
      okcode_9000 = ok_code.
      CLEAR ok_code.
      CLEAR tab.
      REFRESH tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHAN' TO wa_tab-fcode	.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'REFER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ROLEBLK' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'MANAGER' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      ch1 = sy-uname+0(1).
      IF ch1 = 'C' OR ch1 = 'R'  OR ch1 = '9' OR ch1 = '8'
         OR ch1 = '7'  OR ch1 = '6'  OR ch1 = '5'  OR ch1 = '4'
         OR ch1 = '3'  OR ch1 = '2'  OR ch1 = '1'.
        lv_flag = ' '.
        CALL SCREEN 100.
      ELSE.
        CALL SCREEN 105.
      ENDIF.
*End of <RD1K963124>.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_req_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_req_data INPUT.
*data: l_oo_no  type  zauth_head-oo_number.
  IF okcode_9000 EQ 'CHAN'  OR okcode_9000 EQ 'DISP'
      OR okcode_9000 EQ 'DELETE' OR okcode_9000 EQ 'MANAGER'
     AND NOT g_reqno IS INITIAL.

    CLEAR g_status.
    SELECT SINGLE created_by oonumber remarks INTO
    (l_assigned_by,g_oo_no,g_reason)
    FROM zauth_head
     WHERE auth_req_no = g_reqno.

    IF l_assigned_by <> space.
      g_status = 'ASSIGNED'.
    ELSE.
      g_status = 'NEW'.
    ENDIF.

    REFRESH ist_auth1.
    SELECT * FROM zauth_user_role
    INTO CORRESPONDING FIELDS OF TABLE ist_auth1
    WHERE req_no = g_reqno ORDER BY PRIMARY KEY.

*break cab_mansuri.
    IF NOT ist_auth1[] IS INITIAL.

      CLEAR zauth_head.
      SELECT SINGLE * FROM zauth_head
          WHERE auth_req_no = g_reqno.

      g_oo_no = zauth_head-oonumber.

      IF NOT zauth_head-created_by IS INITIAL AND
          okcode_9000 = 'CHAN'.
        g_str = 'Reqest no is already assigned.Changes not allowed.'.
        MESSAGE e803(zmm) WITH g_str.
      ENDIF.

      READ TABLE ist_auth1 INDEX 1.

      IF sy-uname+0(1) = 'C'  .

      ELSE.
        IF ist_auth1-my_cpf_no NE sy-uname .

          CONCATENATE 'Request no belongs to ' ist_auth1-my_cpf_no
                      'Sorry!.' INTO g_str SEPARATED BY space.
          MESSAGE e803(zmm) WITH g_str.

        ENDIF.
      ENDIF.

      g_userid = ist_auth1-my_cpf_no.
      g_subuserid = ist_auth1-sub_cpf_no.
      g_sdate = ist_auth1-from_dat.
      g_edate = ist_auth1-to_dat.
      g_reason = ist_auth1-reason.

    ELSE.

      CONCATENATE 'Request no' g_reqno 'Not Found!.'
      INTO g_str SEPARATED BY space.
      MESSAGE e803(zmm) WITH g_str.

    ENDIF.

    LOOP AT ist_auth1.

      SELECT TEXT INTO G_ROLE_TEXT FROM AGR_TEXTS UP TO 1 ROWS
 WHERE AGR_NAME = IST_AUTH1-AGR_NAME AND SPRAS = 'EN'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF sy-subrc = 0.
        ist_auth1-text = g_role_text.
        MODIFY ist_auth1 INDEX sy-tabix TRANSPORTING text.
      ENDIF.

    ENDLOOP.


  ENDIF.

ENDMODULE.                 " get_req_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_period  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_period INPUT.

  DATA: l_dor TYPE usr02-gltgb.
  CONDENSE: g_userid.
*Begin of <RD1K963161>.
  IF okcode_9000 = 'MANAGER'.
    IF g_userid IS INITIAL.
      LOOP AT SCREEN.
        screen-required = 1.
        MODIFY SCREEN.
      ENDLOOP.
    ELSE .
      MOVE g_userid TO lv_userid.
*      CLEAR g_userid.
    ENDIF.
  ENDIF.
  IF lv_userid IS NOT INITIAL.
    SELECT SINGLE * FROM usr02 WHERE bname = lv_userid.
    IF sy-subrc <> 0.
      MESSAGE e089(zbc) WITH g_userid.
    ENDIF.
  ENDIF.

  IF lv_userid IS INITIAL.
    LOOP AT SCREEN .
      screen-required = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF lv_userid IS NOT INITIAL AND g_subuserid IS NOT INITIAL .
    IF  lv_userid = g_subuserid.
      MESSAGE e803(zmm) WITH 'Roles between Source & Target ID are common'.
    ENDIF.
  ENDIF.
*End of <RD1K963161>.
  SELECT SINGLE gltgb INTO l_dor FROM usr02 WHERE
  bname = g_userid.
  IF sy-subrc = 0 AND l_dor <> '00000000'.
    IF g_edate > l_dor.
      g_edate = l_dor.
    ENDIF.
  ENDIF.

  g_days = g_edate - g_sdate.
  IF g_days > 30.
    CLEAR:   g_edate.
    MESSAGE e803(zbc).
  ENDIF.

  IF okcode_9000 = 'CURTAIL'.
    IF g_edate LT sy-datum.
      MESSAGE e817(zbc).
    ENDIF.
  ENDIF.

ENDMODULE.                 " validate_period  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_reason  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_reason INPUT.
  IF g_reason IS INITIAL.
    MESSAGE e804(zbc).
  ENDIF.
ENDMODULE.                 " validate_reason  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_oono  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_oono INPUT.
  IF g_oo_no IS INITIAL.
    MESSAGE e805(zbc).
  ENDIF.
ENDMODULE.                 " validate_oono  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      clear ok_200.
      LEAVE TO SCREEN 9000.
    WHEN 'CREATE' .
      CLEAR tab.
      REFRESH tab.
      MOVE 'CREA' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CHAN' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'DISP' TO wa_tab-fcode.
      APPEND wa_tab TO tab.

      MOVE 'DISPROLE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.
      MOVE 'CURTAIL' TO wa_tab-fcode.
      APPEND wa_tab TO tab.

      MOVE 'DELETE' TO wa_tab-fcode.
      APPEND wa_tab TO tab.

      PERFORM get_reference.
      if sy-tcode = 'ZDELEGATE'.
        call selection-screen 9001.
      else.
        PERFORM pop_up_get_refer .
      endif.
      IF sy-ucomm NE 'CANC'.
        ok_200 = 'CREATE'.
        CLEAR ok_code.
        ch1 = sy-uname+0(1).
        IF ch1 = 'C' OR ch1 = 'R'.
          CALL SCREEN 100.
        ELSE.
          CALL SCREEN 105.
        ENDIF.

      ENDIF.

    WHEN 'DISPLAY' OR 'DELETE'.
      ok_200 = ok_code.
      if sy-tcode = 'ZDELEGATE'.
        call selection-screen 9002.
      else.
        PERFORM get_ref_delreq.
      endif.
      IF sy-uname+0(1) = 'C'.
        CALL SCREEN 300.
      ELSE.
        CALL SCREEN 350.
      ENDIF.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE ok_code.

    WHEN 'BACK'.
      LEAVE TO SCREEN 9000.
*    When 'CREATE'.
*      PERFORM get_reference.
*      PERFORM pop_up_get_refer.
*
*      IF sy-ucomm NE 'CANC'.
*        ok_300 = ok_code.
*        clear ok_code.
*        ch1 = sy-uname+0(1).
*        IF ch1 = 'C' OR ch1 = 'R'.
*          CALL SCREEN 100.
*        ELSE.
*          CALL SCREEN 105.
*        ENDIF.
*
*      ENDIF.

    WHEN 'DELETE'.

      SELECT * FROM ZAUTH_USER_ROLE UP TO 1 ROWS
 WHERE
 REQ_NO = G_REQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF sy-uname+0(1) = 'C' .
      ELSE.
        IF zauth_user_role-my_cpf_no <> sy-uname.
          MESSAGE e815(zbc) WITH zauth_user_role-my_cpf_no.
        ENDIF.
      ENDIF.


      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = text-006
          text_question         = text-007
          text_button_1         = 'Yes'
          icon_button_1         = 'ICON_OKAY'
          text_button_2         = 'No'
          icon_button_2         = 'ICON_REJECT'
*         default_button        = '1'
          display_cancel_button = 'X'
          start_column          = 25
          start_row             = 6
        IMPORTING
          answer                = l_action
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


      IF l_action = '1'.

        IF zroledel_head-deleted_by = space.
          DELETE FROM zroledel_head WHERE roledel_req_no = g_del_reqno.
          DELETE FROM zroledel_item WHERE roledel_req_no = g_del_reqno.
          MESSAGE i811(zbc) WITH g_del_reqno.
          LEAVE TO SCREEN 9000.
        ELSE.
          MESSAGE i810(zbc) WITH g_del_reqno.
        ENDIF.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  POP_UP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pop_up INPUT.
  DATA  : ist_return_tab LIKE STANDARD TABLE OF ddshretval WITH  HEADER LINE.
  DATA  : ist_return_tab1 LIKE STANDARD TABLE OF dselc WITH HEADER LINE.
  TYPES : BEGIN OF str_role,
          req_no TYPE znumc8,
          my_cpf_no  TYPE zchar12,
          sub_cpf_no TYPE ychar12,
          ernam TYPE ernam,
          erfdt TYPE ZERFDT,
          from_dat TYPE begda,
          to_dat TYPE zdate,
          reason TYPE zauth_reason,
          END OF str_role.

  DATA  : itab TYPE TABLE OF str_role,
          wa_itab TYPE str_role.

  SELECT req_no my_cpf_no  sub_cpf_no ernam erfdt  from_dat to_dat reason
         FROM zauth_user_role INTO CORRESPONDING FIELDS OF  TABLE itab.

  SORT itab BY req_no.
  DELETE ADJACENT DUPLICATES FROM itab COMPARING req_no.

  ist_return_tab1-fldname = 'REQ_NO'.
  ist_return_tab1-dyfldname = 'ZAUTH_USER_ROLE-REQ_NO'.
  APPEND ist_return_tab1 TO ist_return_tab1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'REQ_NO'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = 'REQ_NO'
      value_org       = 'S'
    TABLES
      value_tab       = itab
      return_tab      = ist_return_tab
      dynpfld_mapping = ist_return_tab1
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE .
    zauth_user_role-req_no = ist_return_tab-fieldval.
  ENDIF.
ENDMODULE.                 " POP_UP  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_USER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module VALIDATE_USER input.
  DATA : l_user TYPE XUBNAME.
  CONDENSE :g_userid.
  if not g_userid is initial.
    select single bname from usr21 INTO l_user where bname = g_userid.
    if sy-subrc ne 0.
      MESSAGE e803(zmm) WITH 'The user not found' g_userid.
    endif.
  endif.
endmodule.                 " VALIDATE_USER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POP_UP_CURTAIL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POP_UP_CURTAIL INPUT.
  TYPES : BEGIN OF str_role_c,
            ROLEDEL_REQ_NO type ZROLEDEL_HEAD-ROLEDEL_REQ_NO,
  REQUESTED_BY type ZROLEDEL_HEAD-ROLEDEL_REQ_NO,
  REF_REQNO type ZROLEDEL_HEAD-ROLEDEL_REQ_NO,
  DELETED_ON type ZROLEDEL_HEAD-ROLEDEL_REQ_NO,
        my_cpf_no  TYPE zchar12,
            sub_cpf_no TYPE ychar12,
            END OF str_role_c.

  DATA  : itab_c TYPE TABLE OF str_role_c,
          wa_itab_c TYPE str_role_c.

  if sy-tcode = 'ZDELEGATE'.
    break cab_rama.

  endif.


ENDMODULE.                 " POP_UP_CURTAIL  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.
  case ok_code_9001.
    when ''.
      if not ZAUTH_USER_ROLE-REQ_NO is initial.
        g_reqno_ref = ZAUTH_USER_ROLE-REQ_NO.
        g_reqno =     ZAUTH_USER_ROLE-REQ_NO.
      endif.

      SELECT * FROM ZAUTH_USER_ROLE UP TO 1 ROWS
 WHERE
 REQ_NO = G_REQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-uname+0(1) = 'C' .
      else.
        if zauth_user_role-my_cpf_no <> sy-uname.
          message e814(zbc) with zauth_user_role-my_cpf_no.
        endif.
      endif.



      data: l_reqno type zroledel_head-roledel_req_no,
            l_date  type zroledel_head-roledel_req_date.

      SELECT ROLEDEL_REQ_NO ROLEDEL_REQ_DATE INTO
 ( L_REQNO , L_DATE ) FROM ZROLEDEL_HEAD UP TO 1 ROWS WHERE REF_REQNO = G_REQNO_REF
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      if sy-subrc = 0.
        message e813(zbc) with l_reqno  l_date.
      endif.

      refresh ist_auth1.

      select * from zauth_user_role
      into corresponding fields of table ist_auth1
            where req_no = g_reqno_ref ORDER BY PRIMARY KEY.

      if not ist_auth1[] is initial.

        clear zauth_head.
        select single * from zauth_head
            where auth_req_no = g_reqno_ref.

        if zauth_head-created_by is initial.
          concatenate 'Request:' g_reqno_ref
              'not assigned.Can not Curtail'
          into g_str separated by space.
          message e803(zmm) with g_str.
        endif.

        read table ist_auth1 index 1.

        if ist_auth1-to_dat < sy-datum.

          concatenate 'Request No: ' g_reqno_ref
              'is not revelent for reference. Please check!'
          into g_str separated by space.
*      message e803(zmm) with g_str.
          message e817(zbc).
        endif.

        g_subuserid = ist_auth1-sub_cpf_no.
*    g_sdate = sy-datum.   "ist_auth1-from_dat.
*    g_edate = sy-datum.
        g_sdate = ist_auth1-from_dat.
        g_edate = ist_auth1-to_dat.
        g_reason = ist_auth1-reason.
        g_oo_no  = zauth_head-oonumber.
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

      else.

        concatenate 'Request No: ' g_reqno_ref
            'not found!'
        into g_str separated by space.
        message e803(zmm) with g_str.

      endif.
      set parameter id 'ZAUTHREQ' field ' '.

*  g_ok_code1 = 'REFER'.
      clear : ist_refer.
      leave to screen 0.
    when 'BACK'.
      leave to screen 9000.
  endcase.


ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_INPUT INPUT.
  ok_code_9001 = sy-ucomm.
  if not OK_CODE_9001 = 'BACK'.
    if ZAUTH_USER_ROLE-REQ_NO is initial.
      message e900(zbc) with 'Please Enter Request No.'.
    endif.
  elseif OK_CODE_9001 = 'BACK'.
    leave to screen 200.
  endif.
ENDMODULE.                 " CHECK_INPUT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9002 INPUT.
OK_CODE_9002 = SY-UCOMM.
  case ok_code_9002.
    when ''.
      clear ok_code.

      g_del_reqno = ZROLEDEL_HEAD-ROLEDEL_REQ_NO.

      select single * from zroledel_head
                         where roledel_req_no = g_del_reqno.
      if sy-subrc <> 0.
        message e812(zbc).
      endif.

      set parameter id 'ZAUTHREQ' field ' '.
      leave to screen 0.
    when 'BACK'.
      leave to screen 9000.
  endcase.
ENDMODULE.                 " USER_COMMAND_9002  INPUT

*--- INCLUDE: MZROLEAUTHO01 ---*
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

*--- INCLUDE: MZROLEAUTHTOP ---*
*----------------------------------------------------------------------*
***INCLUDE MZUSRROLEREQTOP .
*----------------------------------------------------------------------*

*-----------------------------------------------------------------------
*                                TABLES
*-----------------------------------------------------------------------

tables : zauth_user_role,
         tstct,
         agr_users,
         agr_define,
         usr02,
         usr21,
         adrp,
         zauth_head,
         zauth_item,
         zroledel_head,
         zroledel_item.
*-----------------------------------------------------------------------
*                                Variables
*-----------------------------------------------------------------------

data: g_userid    like zauth_user_role-my_cpf_no,
      g_subuserid like zauth_user_role-my_cpf_no,
      g_uname(50) type c,
      g_subuname(50) type c,
      g_sdate     like zauth_user_role-from_dat,
      g_edate     like zauth_user_role-to_dat,
      g_reason    like zauth_user_role-reason,
      g_perno like usr21-persnumber,
      g_role_text like agr_texts-text,
      g_reqno like zauth_user_role-req_no,
      g_del_reqno    like zroledel_head-roledel_req_no,
      g_ref_reqno    like zauth_user_role-req_no,
      g_delegated_by like zauth_user_role-my_cpf_no,
      g_delegated_to like zauth_user_role-sub_cpf_no,
      g_from_date    like zauth_user_role-from_dat,
      g_to_date      like zauth_user_role-to_dat,
      g_reqno_ref like zauth_user_role-req_no.

data :g_myuserid    like zauth_user_role-my_cpf_no,
      g_mysubuserid like zauth_user_role-my_cpf_no,
      g_myuname(50) type c,
      g_mysubuname(50) type c,
      g_mysdate     like zauth_user_role-from_dat,
      g_myedate     like zauth_user_role-to_dat,
      g_action type c,
      g_save_flag,
      g_primod like zauth_head-primod,
      g_str  type string,
      g_disptext type string.
data: g_days type i,
      g_status(10) type c,
      g_oo_no(100) type c.


data: wa_roledel_head   type  zroledel_head,
      wa_roledel_item   type  zroledel_item.

ranges r_date for zauth_user_role-from_dat.

data : ok_code like sy-ucomm,
       ok_200 like sy-ucomm,
       ok_300 like sy-ucomm,

       save_code like sy-ucomm.

*-----------------------------------------------------------------------
*                                Types
*-----------------------------------------------------------------------

types : begin of ty_fcode,
        fcode like rsmpe-func,
        end of ty_fcode.

types : begin of ty_auth1,
        req_no      like zauth_user_role-req_no,
        itemno     like zauth_user_role-itemno,
        my_cpf_no  like zauth_user_role-my_cpf_no,
        sub_cpf_no like zauth_user_role-sub_cpf_no,
        agr_name   like agr_users-agr_name,
        text       like agr_texts-text,
        from_dat   like zauth_user_role-from_dat,
        to_dat     like zauth_user_role-to_dat,
        reason     like zauth_user_role-reason,
        oonumber   like zauth_head-oonumber,

        ernam      like zauth_user_role-ernam,
        erfdt      like zauth_user_role-erfdt,
        timestamp  like oifbbp1-ftmstm,
        mark       type c,
        loekz      type c,
        end of ty_auth1.

types : begin of ty_auth2,
*        my_cpf_no like  zauth_user_role-my_cpf_no,
*        sub_cpf_no like  zauth_user_role-sub_cpf_no,
        agr_name like agr_users-agr_name,
        text like agr_texts-text,
        from_dat like zauth_user_role-from_dat,
        to_dat like zauth_user_role-to_dat,
        loekz type c,
        end of ty_auth2.

*types : begin of ty_assign,
*        agr_name   LIKE agr_users-agr_name,
*        text       LIKE agr_texts-text,
*        from_dat   LIKE zauth_user_role-from_dat,
*        to_dat     LIKE zauth_user_role-to_dat,
*        end of ty_assign.

*-----------------------------------------------------------------------
*                    Internal Tables
*-----------------------------------------------------------------------

data : ist_auth1    type standard table of ty_auth1 with header line,
       ist_auth_del type standard table of ty_auth1 with header line,
       ist_auth1_copy type standard table of ty_auth1 with header line,
       ist_roledel_item  type standard table of zroledel_item
                                                       with header line,

       ist_fcode type standard table of ty_fcode with
       non-unique default key initial size 10,

       ist_auth2_cpfno type standard table of ty_auth2 with header line,
       ist_auth2_subcpfno type standard table of ty_auth2 with header
       line.

*       ist_assign type standard table of ty_assign with header line.

data: ist_zauthitem type standard table of zauth_item with header line.

data:  ist_refer like sval occurs 0 with header line.
*-----------------------------------------------------------------------
*                    Structure
*-----------------------------------------------------------------------

data : wa_fcode type ty_fcode.

data : ist_auth_st type ty_auth1.
*      ist_ass_st type ty_assign.

* Menu Painter - Input/Output Fields.
types: begin of tab_type,
        fcode like rsmpe-func,
       end of tab_type.

data: tab type standard table of tab_type with
          non-unique default key initial size 10,
      wa_tab type tab_type.

** Globle OK_CODE fields.
data: okcode_9000 like sy-ucomm.

*-----------------------------------------------------------------------
*                    Table Control
*-----------------------------------------------------------------------

controls tctrl_100 type tableview using screen 100.
controls tctrl_110 type tableview using screen 110.
controls tctrl_300 type tableview using screen 300.

*Begin of <RD1K963159>.
data : g_att_files like table of swotobjid.
data : g_att_files_wa like swotobjid.
data : l_val like zauth_user_role-req_no.
DATA : ALLOWED_CHAR(10) VALUE '0123456789',
       lv_userid like zauth_user_role-my_cpf_no,
       lv_flag(1) TYPE c." for setting value in screen.
*End of <RD1K963159>.

data : ok_code_9001 type sy-ucomm.
data : ok_code_9002 type sy-ucomm.
