*--- MAIN PROGRAM: MZMMUOMO01 ---*
***INCLUDE MZMMMERO01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_init OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
  ENDIF.
  tc_81-lines = 999.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_81_move OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_move OUTPUT.


  MOVE-CORRESPONDING g_tc_81_wa TO wa_zmm_uom_d.

**  IF g_ok_82 NE 'DISPLAY'.
**    IF NOT ( zmm_mecs-remrk IS INITIAL ).
**      CALL FUNCTION 'ICON_CREATE'
**           EXPORTING
**                name   = 'ICON_LED_RED'
**           IMPORTING
**                result = icon.
**    ENDIF.
**  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE TC_81_get_lines OUTPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_get_lines OUTPUT.
  g_tc_81_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9081  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9081 OUTPUT.
  SET PF-STATUS 'ZMM02'  .
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9081  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9080 OUTPUT.
  SET PF-STATUS 'ZMM01' .
  SET TITLEBAR '001' WITH text-014 .
ENDMODULE.                 " STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9082 OUTPUT.
  PERFORM pfstatus.
*  SET PF-STATUS 'ZMM03' .
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_81_attr OUTPUT.

  CASE g_ok_80.

    WHEN 'CREATE' OR 'CHANGE'.

      LOOP AT tc_81-cols INTO htc_cols.
        IF htc_cols-screen-group1 EQ 'INV'.
          htc_cols-invisible = 'X'.
        ELSEIF htc_cols-screen-group1 EQ 'CHN'.
          htc_cols-screen-input = 1.
          htc_cols-screen-active = 1.
        ENDIF.
        MODIFY tc_81-cols FROM htc_cols.

      ENDLOOP.

    WHEN 'DISPLAY' or 'DELETE'.

      LOOP AT tc_81-cols INTO htc_cols.
        htc_cols-screen-input = 0.
        MODIFY tc_81-cols FROM htc_cols.
      ENDLOOP.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.

  ENDCASE.

ENDMODULE.                 " tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_line_items OUTPUT.
  CLEAR g_lines.
  DESCRIBE TABLE g_tc_81_itab LINES g_lines.
ENDMODULE.                 " get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE refresh_itabs OUTPUT.
  REFRESH g_tc_81_itab.
  CLEAR  g_docno .
  REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
ENDMODULE.                 " refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE srn_81_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'WA_ZMM_UOM_H-DOCNO' OR
         screen-name = 'WA_ZMM_UOM_H-ERSDA'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'WA_ZMM_UOM_H-DOCNO' or
         screen-name = 'WA_ZMM_UOM_H-ERSDA' .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY' or g_ok_80 EQ 'DELETE'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  move_docno  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_docno OUTPUT.
  MOVE g_docno TO wa_zmm_uom_h-docno.
ENDMODULE.                 " move_docno  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_req_flds  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_req_flds OUTPUT.
Perform get_matnr_desc using g_tc_81_wa-matnr.

Check g_ok_80 = 'CREATE'.
Data: l_dimid type t006-dimid.
Clear l_dimid.

   SELECT SINGLE dimid INTO l_dimid FROM t006 WHERE
       msehi = g_tc_81_wa-meins.

If g_tc_81_wa-meins = 'NO' OR
   l_dimid = 'AAAADL'.
   wa_zmm_uom_d-uom_str1 = 'NON CONVERTIBLE UOM'.
Else.
Perform get_uom_conv   using g_tc_81_wa-meins.
Endif.
loop at screen.
 if screen-group2 EQ 'REQ' and wa_makt-maktx <> ' ' and
    screen-required = '0'.
  screen-required = '1'.
  modify screen.
  exit.
 endif.
endloop.

ENDMODULE.                 " set_req_flds  OUTPUT
