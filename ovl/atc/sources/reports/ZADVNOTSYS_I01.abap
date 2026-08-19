*--- MAIN PROGRAM: ZADVNOTSYS_I01 ---*
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
