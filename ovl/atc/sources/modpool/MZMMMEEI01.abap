*--- MAIN PROGRAM: MZMMMEEI01 ---*
***INCLUDE MZMMMEEI01 .
*---------------------------------------------------------------------*
*       MODULE TC_PARENT_MARK INPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_mark INPUT.


  IF tc_parent-line_sel_mode = 1 AND g_tc_parent_wa-flag = 'X'.
    LOOP AT g_tc_parent_itab INTO g_tc_parent_wa WHERE flag = 'X'.
      g_tc_parent_wa-flag = ''.
      MODIFY g_tc_parent_itab FROM g_tc_parent_wa TRANSPORTING flag.
    ENDLOOP.
    g_tc_parent_wa-flag = 'X'.
  ENDIF.

  MODIFY g_tc_parent_itab
    FROM g_tc_parent_wa
    INDEX tc_parent-current_line
    TRANSPORTING flag.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_USER_COMMAND INPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_user_command INPUT.

  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_PARENT'
                              'G_TC_PARENT_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  EXIT  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " EXIT  INPUT

*---------------------------------------------------------------------*
*       MODULE TAB_CHILD_ACTIVE_TAB_GET INPUT                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tab_child_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_tab_child-tab1.
      g_tab_child-pressed_tab = c_tab_child-tab1.
    WHEN c_tab_child-tab2.
      g_tab_child-pressed_tab = c_tab_child-tab2.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_7000  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE user_command_7000 INPUT.

ENDMODULE.                 " USER_COMMAND_7000  INPUT

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MODIFY INPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_modify INPUT.
  MOVE-CORRESPONDING zmm_mecs TO g_tc_child_wa.
  MODIFY g_tc_child_itab
    FROM g_tc_child_wa
    INDEX tc_child-current_line.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MARK INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_mark INPUT.

  MODIFY g_tc_child_itab FROM g_tc_child_wa
                         INDEX tc_child-current_line
                         TRANSPORTING flag.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_USER_COMMAND INPUT                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_CHILD'
                              'G_TC_CHILD_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  CASE sy-ucomm.
    WHEN 'CHECK'.
      PERFORM check_record.
    WHEN 'EXTND'.
      PERFORM populate_record.
      g_extnd_flag = 'X'.
*      PERFORM send_mail.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0110  INPUT

*---------------------------------------------------------------------*
*       MODULE TC_MSG_user_command INPUT                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_MSG'
                              'IST_MSG'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
