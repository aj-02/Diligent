*--- MAIN PROGRAM: MZROLEAUTHF01 ---*
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
