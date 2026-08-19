*--- MAIN PROGRAM: ZADVNOTSYS_SCREEN ---*
*&---------------------------------------------------------------------*
*& Module Pool       ZADVNOTSYS_SCREEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  ZADVNOTSYS_SCREEN.
INCLUDE ZADVNOTSYS_TOP.
INCLUDE ZADVNOTSYS_O01.
INCLUDE ZADVNOTSYS_I01.
INCLUDE ZADVNOTSYS_F01.

*--- INCLUDE: ZADVNOTSYS_F01 ---*
*&---------------------------------------------------------------------*
*&  Include           ZADVNOTSYS_F01
*&---------------------------------------------------------------------*

*--- INCLUDE: ZADVNOTSYS_I01 ---*
*&---------------------------------------------------------------------*
*&  Include           ZADVNOTSYS_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.
  OKCODE_101 = SY-UCOMM.
  CLEAR SY-UCOMM.
CASE OKCODE_101.
  WHEN 'ADV_1'.
    CALL TRANSACTION 'ZMMANSREPORT_PO'.

  WHEN 'ADV_2'.
     CALL TRANSACTION 'ZMMANSREPORT_BG'.

  WHEN 'PCT'.
     CALL TRANSACTION 'ZMM_ANSCONSUMIM_REP'.

  WHEN 'PC60'.
     CALL TRANSACTION 'ZMM_ANSCONSUML2_REP'.

  WHEN 'PC365'.
     CALL TRANSACTION 'ZMM_ANSCONSUML1_REP'.

  WHEN 'BACK' OR 'CAN' OR 'EXIT'.
    LEAVE PROGRAM.
    ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT

*--- INCLUDE: ZADVNOTSYS_O01 ---*
*&---------------------------------------------------------------------*
*&  Include           ZADVNOTSYS_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS 'OPTNS'.
  SET TITLEBAR 'ADV. NOT. SYSTEM'.

ENDMODULE.                 " STATUS_0101  OUTPUT

*--- INCLUDE: ZADVNOTSYS_TOP ---*
*&---------------------------------------------------------------------*
*&  Include           ZADVNOTSYS_TOP
*&---------------------------------------------------------------------*



DATA : okcode_101 like sy-ucomm.
