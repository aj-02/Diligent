*--- MAIN PROGRAM: SAPMZMM_VEND_UPDT ---*
*&---------------------------------------------------------------------*
*& Module pool       SAPMZMM_VEND_UPDT                                 *
*&---------------------------------------------------------------------*
*                                                                     *
* Title      : Vendor Details Update                                   *
*                                                                     *
* FS No.     : +++++++++++++++++++++++++++++++++++++++++++++++++++++
*                                                                     *
* Author     : Ajit Singh             Date : 26/07/2007               *
*                                                                     *
* Login Id   : CAB_AJIT                                               *
*                                                                     *
* Description: Vendor Details Update                                   *
*                                                                     *
* Tran. Code :
*                                                                     *
**********************************************************************

INCLUDE MZMM_VEND_UPDTTOP.

INCLUDE MZMM_VEND_UPDTO01.

INCLUDE MZMM_VEND_UPDTI01.

INCLUDE MZMM_VEND_UPDTF01.

*--- INCLUDE: MZMM_VEND_UPDTF01 ---*
***INCLUDE ZMM_VEND_UPDTF01 .

*--- INCLUDE: MZMM_VEND_UPDTI01 ---*
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

*--- INCLUDE: MZMM_VEND_UPDTO01 ---*
***INCLUDE ZMM_VEND_UPDTO01 .
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_9000 output.
  SET PF-STATUS 'UPDT_STAT'.
*  SET TITLEBAR 'xxx'.

endmodule.                 " STATUS_9000  OUTPUT

*--- INCLUDE: MZMM_VEND_UPDTTOP ---*
*&---------------------------------------------------------------------*
*& Include ZMM_VEND_UPDTTOP                                           *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  ZMM_VEND_UPDTTOP                 .
