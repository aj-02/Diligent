*--- MAIN PROGRAM: MZROLEAUTHI01 ---*
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
