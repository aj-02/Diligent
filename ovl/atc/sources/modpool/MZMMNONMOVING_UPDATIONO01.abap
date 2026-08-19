*--- MAIN PROGRAM: MZMMNONMOVING_UPDATIONO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMNONMOVING_UPDATIONO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS '101'.
  SET TITLEBAR '101'.

ENDMODULE.                 " STATUS_0101  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_101'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_101_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_DISP LINES TC_101-lines.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS '102'.
  SET TITLEBAR '102'.

ENDMODULE.                 " STATUS_0102  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_102'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_102_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_DISP_STOCK LINES TC_102-lines.
ENDMODULE.
