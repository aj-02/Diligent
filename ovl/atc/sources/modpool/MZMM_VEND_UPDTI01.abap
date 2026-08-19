*--- MAIN PROGRAM: MZMM_VEND_UPDTI01 ---*
***INCLUDE ZMM_VEND_UPDTI01 .
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  CALL FUNCTION 'ZMM_MAINTAIN_VENDOR'
            .

ENDMODULE.                 " USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                 " EXIT  INPUT
