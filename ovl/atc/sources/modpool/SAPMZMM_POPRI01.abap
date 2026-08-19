*--- MAIN PROGRAM: SAPMZMM_POPRI01 ---*
*----------------------------------------------------------------------*
***INCLUDE SAPMZMM_POPRI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
CASE OK_CODE.
  WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.


WHEN OTHERS.
  IF RD1 = 'X'.
    CALL TRANSACTION 'ZMM_POPRSUM1'.

  ELSEIF RD2 = 'X'.
    PERFORM POPUP_TO_DISPLAY_TEXT.
    CALL TRANSACTION 'ZMM_POPRSUM'.
ENDIF.


  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
