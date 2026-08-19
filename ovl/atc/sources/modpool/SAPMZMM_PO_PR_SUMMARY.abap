*--- MAIN PROGRAM: SAPMZMM_PO_PR_SUMMARY ---*
*&---------------------------------------------------------------------*
*& Module Pool       SAPMZMM_PO_PR_SUMMARY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*

*                                                                     *
* Title      : Report on summary of orders placed                     *
*                                                                     *
* FS No.     : FS-MM-Report On POs Placed                             *
* CR No .    : 30009557                                               *
* Author     : Lipsy swain              Date : 18.10.2013             *
*                                                                     *
*                                                                     *
*                                                                     *
* Login Id   : CAB_LIPSY                                              *
*                                                                     *
*                                                                     *
*                                                                     *
* Description: Report on summary of orders placed                     *
*(providing options for basic and dynamic  report of pr,po,ola,tender *
*numbers and valueof  material-spares,stores,capital and services     *
*during a particular period in the form of alv and smartform)         *
* Tran. Code : zmm_totalprocurement                                   *
*                                                                     *
*                                                                     *


* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                               *
*                                                                     *

*&                                                                    *
*&

*&---------------------------------------------------------------------*
PROGRAM SAPMZMM_PO_PR_SUMMARY.

INCLUDE SAPMZMM_POPPRTOP.
INCLUDE sapmzmm_popro01.

INCLUDE sapmzmm_popri01.

INCLUDE sapmzmm_poprf01.

*--- INCLUDE: SAPMZMM_POPPRTOP ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZMM_POPPRTOP
*&---------------------------------------------------------------------*

DATA:OK_CODE TYPE SY-UCOMM.
DATA: RD1 ,RD2.

*--- INCLUDE: SAPMZMM_POPRF01 ---*
*----------------------------------------------------------------------*
***INCLUDE SAPMZMM_POPRF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPUP_TO_DISPLAY_TEXT .
 CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      titel        = 'Important Information'
      textline1    = 'Please use this  for dynamic selection'
*      textline2    = 'else the output may be slow'
      start_column = 25
      start_row    = 6.
ENDFORM.                    " POPUP_TO_DISPLAY_TEXT

*--- INCLUDE: SAPMZMM_POPRI01 ---*
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

*--- INCLUDE: SAPMZMM_POPRO01 ---*
*----------------------------------------------------------------------*
***INCLUDE SAPMZMM_POPRO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
