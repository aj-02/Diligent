*--- MAIN PROGRAM: MZMMMPNO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMMPNO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  clear : ist_gui.
  refresh ist_gui.

  IF NOT g_function IS INITIAL.
    Perform fcode_table.
  ENDIF.

  case g_function.
    when 'DIS' .
      ist_gui-fcode = 'UPD' .
      append ist_gui .
      clear ist_gui .
  endcase.

  PERFORM read_function_text.
  SET PF-STATUS 'MPN01' EXCLUDING ist_gui.  "#EC CI_USAGE_OK[2348023]
  SET TITLEBAR 'MPNTIT' WITH g_fctext.

ENDMODULE.                 " STATUS_9001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_init  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
module G_NEW_MPN_init output.
  if g_G_NEW_MPN_copied is initial.
    select * from ZMM_MPN into corresponding fields of table ist_mpn.
    g_G_NEW_MPN_copied = 'X'.
    refresh control 'G_NEW_MPN' from screen '9010'.
  endif.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_move  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
module G_NEW_MPN_move output.
  clear ist_mara.
  move-corresponding wa_mpn to ZMM_MPN.
  wa_makt-maktx = wa_mpn-maktx.
  read table ist_mara1 into ist_mara with key matnr = wa_mpn-matnr.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
module G_NEW_MPN_get_lines output.
  g_G_NEW_MPN_lines = sy-loopc.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_SRC_MPN_change_tc_attr  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
module G_SRC_MPN_change_tc_attr output.
  describe table IST_MPN_SRCH lines G_SRC_MPN-lines.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_SRC_MPN_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
module G_SRC_MPN_get_lines output.
  g_G_SRC_MPN_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  set_scr_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_scr_attr OUTPUT.

  LOOP AT SCREEN.

    IF g_function = 'CRE' or
       g_function = 'CHG'.
      IF not wa_mpn-matnr is initial and screen-group2 = '103'.
        screen-required = 1.
      ENDIF.
    ENDIF.

    IF g_function = 'DEL' or
       g_function = 'CHG' or
       g_function = 'DIS'.
      IF screen-group2 = '105'.
        screen-input = 1.
        screen-required = 1.
      ENDIF.
      IF screen-group2 = '107'.
        screen-input = 0.
      ENDIF.
    ENDIF.

    IF g_function = 'DEL' or
       g_function = 'DIS'.
      IF screen-group2 = '103'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    modify screen.

  ENDLOOP.

ENDMODULE.                 " set_scr_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_other_data  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
MODULE get_other_data OUTPUT.

  if g_function = 'CRE'.
    zmm_mpn-ersda = sy-datum.
    zmm_mpn-ernam = sy-uname.
  endif.


ENDMODULE.                 " get_other_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_CERTIFIACTE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_CERTIFIACTE OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  clear : ist_gui1.
  refresh ist_gui1.
*  SET PF-STATUS 'CER_GUI'.
  NEW-PAGE NO-TITLE.
  if g_token is initial.
    ist_gui1-fcode = 'OLD' . append ist_gui1 . clear ist_gui1.
    ist_gui1-fcode = 'NEW' . append ist_gui1 . clear ist_gui1.

    SET PF-STATUS 'CER_GUI' EXCLUDING ist_gui1.

  Write : / '               MPN Certificate                           '
                                            Color 3.
  Write : / '---------------------------------------------------------'.
    Write : / text-301.
    Write : / text-302.
    Write : / text-303.
  else.
    ist_gui1-fcode = 'AGRE' . append ist_gui1 . clear ist_gui1.
    ist_gui1-fcode = 'DISAG' . append ist_gui1 . clear ist_gui1.
    SET PF-STATUS 'CER_GUI' EXCLUDING ist_gui1.

    SET TITLEBAR 'DATA'.
    ULINE 1(91).

    Write : /1(1) SY-VLINE, 2(10)'Material', 13(1) SY-VLINE,
            14(20)'Description', 35(1) SY-VLINE,
            37(10)'Vendor',48(1) SY-VLINE,
            50(40)'Part No' , 91(1) SY-VLINE .
    ULINE /1(91).
*    Write : 13(20)'Description' COLOR 7.
*    Write : 35(10)'Vendor' COLOR 7.
*    Write : 47(10)'Part No.' COLOR 7.
    Loop at ist_pop_list.
      write :/2(10) ist_pop_list-matnr.   "#EC CI_FLDEXT_OK[2215424]
      write : 12(22) ist_pop_list-maktx.
      write : 37(10) ist_pop_list-mfrnr.
      write : 50(40) ist_pop_list-mfrpn.
    Endloop.
    clear g_token.
  endif.
ENDMODULE.                 " DISPLAY_CERTIFIACTE  OUTPUT
