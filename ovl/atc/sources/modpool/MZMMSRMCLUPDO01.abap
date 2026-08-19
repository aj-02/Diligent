*--- MAIN PROGRAM: MZMMSRMCLUPDO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMSRMCLUPDO01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  set_status_100  OUTPUT
*&---------------------------------------------------------------------*
*       Set Pf Status
*----------------------------------------------------------------------*

MODULE set_status_100 OUTPUT.
  IF ok_code_90 = 'DISP' OR ist_tc100[] IS INITIAL.
    ist_tab-fcode = 'SAVE'.
    APPEND ist_tab .
  ELSE.
    REFRESH ist_tab.
    CLEAR ist_tab .
  ENDIF.

  SET PF-STATUS 'S100'  EXCLUDING ist_tab.
  IF ok_code_90 = 'CREA'.
    SET TITLEBAR 'T100' WITH text-t02.
  ELSEIF ok_code_90 = 'DISP'.
    SET TITLEBAR 'T100' WITH text-t03 zmm_srm_mat_clas-reqno.
  ENDIF.
  PERFORM get_usr_date.
  PERFORM check_table_initial.
ENDMODULE.                 " set_status_100  OUTPUT

*&spwizard: output module for tc 'TC100'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE tc100_change_tc_attr OUTPUT.
  DESCRIBE TABLE ist_tc100 LINES tc100-lines.
  IF ok_code_90 = 'DISP'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G01' .
        screen-input  = 0.
        MODIFY SCREEN.
      ELSEIF  screen-group1 = 'MOD' OR
              screen-group1 = 'PAG' OR
              screen-group1 = 'MAR' OR
              screen-group2 = 'G02'.
        screen-invisible = 1.
        MODIFY SCREEN.

      ENDIF.
    ENDLOOP.

    LOOP AT tc100-cols INTO cols.
      IF cols-screen-name  = 'WA_TC100-MATNR' OR
          cols-screen-name = 'WA_TC100-SRMCLASS'.
        cols-screen-input = 0.
        MODIFY tc100-cols FROM cols .
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.

*&spwizard: output module for tc 'TC100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tc100_get_lines OUTPUT.
  g_tc100_lines = sy-loopc  .
  PERFORM assign_srlno       .
  PERFORM check_srm_class .
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  GEN_SET  OUTPUT
*&---------------------------------------------------------------------*
*       General  Settings
*----------------------------------------------------------------------*
MODULE gen_set OUTPUT.
  DATA: l_tabix(5) TYPE n.
  CLEAR l_tabix.
  LOOP AT ist_tc100 INTO wa_100.
    IF NOT wa_100-matnr IS INITIAL.
      l_tabix = l_tabix + 1.
      wa_100-slno = l_tabix.
      MODIFY ist_tc100 FROM wa_100.
    ENDIF.
  ENDLOOP.
  PERFORM get_maktx.
  PERFORM append_lines.
ENDMODULE.                 " GEN_SET  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0090  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0090 OUTPUT.
  SET PF-STATUS 'S90'.
  SET TITLEBAR 'T90'.
ENDMODULE.                 " STATUS_0090  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       PF Status
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS 'S105'.
  SET TITLEBAR 'T105'.
ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Set Cursor.
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.
  PERFORM set_cursor_field.
ENDMODULE.                 " SET_CURSOR  OUTPUT
