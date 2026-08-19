*--- MAIN PROGRAM: MZMMCONVINSSPRSNVSO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMCONVINSSPRSNVSO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0100.
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*   To set the pf status & title for screen 0200.
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'S200'.
  SET TITLEBAR 'T200'.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  init_screen_0200  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen 0200 : Item Details
*----------------------------------------------------------------------*
MODULE init_screen_0200 OUTPUT.
*  loop at resv_ctrl-cols into wa_resvitem_tctrl-cols.
*
*    if wa_resvitem_tctrl-cols-screen-name = 'WA_RESVITEM_TC-BDMNG'.
*      if not wa_resvitem-charg_r is initial.
*        wa_resvitem_tctrl-cols-screen-output = '1'.
*        wa_resvitem_tctrl-cols-screen-input  = '0'.
*
*        modify resv_ctrl-cols from wa_resvitem_tctrl-cols.
*"        index resv_ctrl-current_line.
*        exit.
**      else.
**        wa_resvitem_tctrl-cols-screen-output = '1'.
**        wa_resvitem_tctrl-cols-screen-input  = '0'.
**
**        modify resv_ctrl-cols from wa_resvitem_tctrl-cols.
*      endif.
*    endif.
*
*  endloop.
ENDMODULE.                 " init_screen_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_0200  OUTPUT
*&---------------------------------------------------------------------*
*   To move reservation detail record into table control
*----------------------------------------------------------------------*
MODULE FILL_TABLE_CONTROL_0200 OUTPUT.
  move-corresponding wa_resvitem to wa_resvitem_tc.
ENDMODULE.                 " FILL_TABLE_CONTROL_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  REFRESH_WA_0200  OUTPUT
*&---------------------------------------------------------------------*
* To refresh structure wa_resvitem
*----------------------------------------------------------------------*
MODULE REFRESH_WA_0200 OUTPUT.
  clear wa_resvitem.
ENDMODULE.                 " REFRESH_WA_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0200  OUTPUT
*&---------------------------------------------------------------------*
* To initialize data for screen 0200
*----------------------------------------------------------------------*
MODULE INIT_DATA_0200 OUTPUT.
  if g_change = '1'.
    describe table ist_resvitem lines g_lines.
    resv_ctrl-lines = g_lines.
    g_change = '0'.
  endif.
ENDMODULE.                 " INIT_DATA_0250  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_DATA_0100  OUTPUT
*&---------------------------------------------------------------------*
* To initialize data for screen 0100
*----------------------------------------------------------------------*
MODULE INIT_DATA_0100 OUTPUT.
  gohead-bldat = sy-datum.
  gohead-budat = sy-datum.
ENDMODULE.                 " INIT_DATA_0100  OUTPUT
