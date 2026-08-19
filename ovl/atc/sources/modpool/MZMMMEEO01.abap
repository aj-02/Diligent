*--- MAIN PROGRAM: MZMMMEEO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMMEEO01                                                 *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_INIT OUTPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_init OUTPUT.
  IF g_tc_parent_copied IS INITIAL.
    g_tc_parent_copied = 'X'.
    REFRESH CONTROL 'TC_PARENT' FROM SCREEN '7000'.
  ENDIF.

  DESCRIBE TABLE g_tc_parent_itab LINES tc_parent_lines.  "+rk004

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_MOVE OUTPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_move OUTPUT.
  MOVE-CORRESPONDING g_tc_parent_wa TO zmm_mems.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_PARENT_GET_LINES OUTPUT                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_parent_get_lines OUTPUT.
  g_tc_parent_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE status_7000 OUTPUT.
  SET PF-STATUS 'ZMME01'.
  IF G_NEWR = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-006 .
  ELSEIF G_PEND = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-010 .
  ELSEIF G_COMP = 'X'.
    SET TITLEBAR 'ME1' WITH text-005 text-011 .
  ENDIF.
ENDMODULE.                 " STATUS_7000  OUTPUT

*---------------------------------------------------------------------*
*       MODULE TAB_CHILD_ACTIVE_TAB_SET OUTPUT                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tab_child_active_tab_set OUTPUT.
  tab_child-activetab = g_tab_child-pressed_tab.
  CASE g_tab_child-pressed_tab.
    WHEN c_tab_child-tab1.
      g_tab_child-subscreen = '7001'.
    WHEN c_tab_child-tab2.
      g_tab_child-subscreen = '7002'.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_INIT OUTPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_init OUTPUT.

  IF NOT g_tc_parent_itab[] IS INITIAL.
    REFRESH g_tc_parent_istb.
    LOOP AT g_tc_parent_itab INTO g_tc_parent_wa  WHERE flag = 'X'.
      APPEND g_tc_parent_wa TO g_tc_parent_istb.

    ENDLOOP.
  ENDIF.
  IF g_tc_parent_copy[] <> g_tc_parent_istb[].
    IF NOT g_tc_parent_istb[] IS INITIAL.
      SELECT * FROM zmm_mecs
               INTO CORRESPONDING FIELDS OF TABLE g_tc_child_itab
               FOR ALL ENTRIES IN g_tc_parent_istb
               WHERE docno  EQ g_tc_parent_istb-docno. "AND -rk006
*                     ernam  EQ g_tc_parent_istb-ernam  AND -rk006
*                     ersda  EQ g_tc_parent_istb-ersda. "-rk006
      SORT g_tc_child_itab.
      g_tc_parent_copy[] = g_tc_parent_istb[].
    ELSE.
      REFRESH : g_tc_child_itab, g_tc_parent_copy, g_tc_parent_istb .
      REFRESH : ist_msg.
      CLEAR : g_check_flag, g_extnd_flag, g_reprt_flag.
    ENDIF.
    REFRESH CONTROL 'TC_CHILD' FROM SCREEN '7001'.
  ENDIF.

  DESCRIBE TABLE g_tc_child_itab LINES tc_child_lines.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_MOVE OUTPUT                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_move OUTPUT.
  MOVE-CORRESPONDING g_tc_child_wa TO zmm_mecs.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_CHILD_GET_LINES OUTPUT                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_child_get_lines OUTPUT.
  g_tc_child_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  SET_BUTTON_ATTRIBUTE  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE set_button_attribute OUTPUT.

  LOOP AT SCREEN.
    IF screen-name EQ 'PB_CHECK'.
      IF NOT g_tc_child_itab[] IS INITIAL.
        screen-invisible = '0'.
      ELSE.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    IF screen-name EQ 'PB_EXTND'.
      IF NOT g_tc_child_itab[] IS INITIAL.
        IF g_check_flag = 'X'.
          screen-invisible = '0'.
        ELSE.
          screen-invisible = '1'.
        ENDIF.
      ELSE.
        screen-invisible = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                 " SET_BUTTON_ATTRIBUTE  OUTPUT

*---------------------------------------------------------------------*
*       MODULE TC_MSG_change_tc_attr OUTPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_change_tc_attr OUTPUT.
  DESCRIBE TABLE ist_msg LINES tc_msg-lines.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_MSG_get_lines OUTPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_msg_get_lines OUTPUT.
  g_tc_msg_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  delete_ist_message  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_ist_message OUTPUT.

*  DELETE ist_msg WHERE msgv1 CS 'type'.
*  DELETE ist_msg WHERE msgv1 CS 'exists'.
*  DELETE ist_msg WHERE msgv1 CS 'Field'.
*  DELETE ist_msg WHERE msgv1 CS 'text'.
*  DELETE ist_msg WHERE msgv1 CS 'tax'.
*  DELETE ist_msg WHERE msgv1 CS 'price'.


ENDMODULE.                 " delete_ist_message  OUTPUT
