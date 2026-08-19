*--- MAIN PROGRAM: MZMMMATEXTNO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE ZMMMATEXTO01                                               *
*----------------------------------------------------------------------*

module TABCTRL_init output.

  IF SAVE_OK101 = 'CHAN' .
    if g_TABCTRL_itab is initial.

      select * from ZMM_MATEXTENSION
         into corresponding fields
         of table g_TABCTRL_itab
         WHERE REQ_NO = ZMM_MATEXTNMAST-REQ_NO.
    endif.

  ELSEIF SAVE_OK101 = 'DISP'
  OR SAVE_OK101 = 'DELE'.

    select * from ZMM_MATEXTENSION
       into corresponding fields
       of table g_TABCTRL_itab
       WHERE REQ_NO = ZMM_MATEXTNMAST-REQ_NO.


  ELSEif SAVE_OK101 = 'CREA' .
    if g_TABCTRL_copied is initial.
      clear ZMM_MATEXTENSION-REQ_NO.
      select * from ZMM_MATEXTENSION
         into corresponding fields
         of table g_TABCTRL_itab
         WHERE REQ_NO = ZMM_MATEXTNMAST-REQ_NO.

      g_TABCTRL_copied = 'X'.

    ENDIF.
  endif.
endmodule.

*---------------------------------------------------------------------*
*       MODULE TABCTRL_move OUTPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module TABCTRL_move output.

  data l_lines like sy-stepl.

  if sy-stepl eq 1.
    describe table g_TABCTRL_itab lines l_lines.
    TABCTRL-lines = l_lines.
  endif.


  IF NOT g_TABCTRL_ITAB IS INITIAL.
    g_TABCTRL_WA-srno = TABCTRL-current_line.
    g_TABCTRL_WA-DISMM = 'ND'.
  ENDIF.

  move-corresponding g_TABCTRL_wa to ZMM_MATEXTENSION.
  move-corresponding g_TABCTRL_wa to usr04.
  move g_TABCTRL_wa-mark TO MARK.
  move g_TABCTRL_wa-fipos TO fmfpo-fipos.
  move g_TABCTRL_wa-msgtYPE  TO wa_message-msgtype.
  move g_TABCTRL_wa-msgtext  TO wa_message-msgtext.


endmodule.

*---------------------------------------------------------------------*
*       MODULE TABCTRL_get_lines OUTPUT                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module TABCTRL_get_lines output.
  DATA : N(3) TYPE C.

  DESCRIBE TABLE g_TABCTRL_itab LINES N.
  g_TABCTRL_lines = N.
endmodule.
**&---------------------------------------------------------------------
**
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  CLEAR TAB.
  MOVE 'DLTE' TO WA_TAB-FCODE.
  APPEND WA_TAB TO TAB.


  IF upl_flag = 'X'.
    SET PF-STATUS 'STATUS_100' EXCLUDING TAB.
    SET TITLEBAR 'TITLE'.
  ELSEIF SAVE_OK101 = 'DELE'.
    SET PF-STATUS 'STATUS_100' . "EXCLUDING 'MESG'.
    SET TITLEBAR 'TITLE'.
  ELSE.
    SET PF-STATUS 'STATUS_100' EXCLUDING 'DLTE' .
    SET TITLEBAR 'TITLE'.

  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_date  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_date OUTPUT.
  IF SAVE_OK101 = 'CREA'.

    zMM_matEXTENSION-req_date = sy-datum.
    zMM_matEXTENSION-req_cpf  = sy-uname.
    zMM_matEXTENSION-req_no   = space.

if not   zmm_matextnmast-remarks is initial.

    zmm_matextnmast-remarks   = zmm_matextnmast-remarks.

endif.

  ELSE.

    IF L_LINES = 0.
      zMM_matEXTENSION-req_date = SPACE.
      zMM_matEXTENSION-req_cpf  = SPACE.
      zMM_matEXTENSION-req_no   = space.
      zmm_matextnmast-remarks   = space.

    ELSE.
      select REq_DATE REQ_CPF from ZMM_MATEXTENSION
         into (zMM_matEXTENSION-req_date,zMM_matEXTENSION-req_CPF)
         WHERE REQ_NO = ZMM_MATEXTENSION-REQ_NO.
      ENDSELECT.


      select single remarks from zmm_matextnmast into
                        l_remark
                        where req_no = ZMM_MATEXTENSION-REQ_NO.

      if     zmm_matextnmast-remarks   = space.
        zmm_matextnmast-remarks = l_remark.
      else.
        if
        zmm_matextnmast-remarks   = l_remark.
          move l_remark to zmm_matextnmast-remarks.
        endif.
      endif.

    ENDIF.
  ENDIF.
ENDMODULE.                 " set_date  OUTPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  set_tabctrl_screen  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_tabctrl_screen output.
  loop at screen.

    if save_ok101 = 'DISP' OR save_ok101 = 'DELE'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    else.

      IF SCREEN-NAME = 'FMFPO-FIPOS'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    endif.

  endloop.
  tabctrl-fixed_cols = 5.
endmodule.                 " set_tabctrl_screen  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_remark  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_remark output.

  zmm_matextnmast-remarks = zmm_matextnmast-remarks.

endmodule.                 " set_remark  OUTPUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  set_message  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_message output.

  LOOP AT g_TABCTRL_itab INTO g_TABCTRL_WA.

    L_SYTABIX = SY-TABIX.

    concatenate g_TABCTRL_WA-msgtype1 g_TABCTRL_WA-msgtype2
                g_TABCTRL_WA-msgtype3 g_TABCTRL_WA-msgtype4
                g_TABCTRL_WA-msgtype5
                into g_TABCTRL_WA-msgtype . "separated by '/'.

    concatenate g_TABCTRL_WA-msgtext1 g_TABCTRL_WA-msgtext2
                g_TABCTRL_WA-msgtext3 g_TABCTRL_WA-msgtext4
                g_TABCTRL_WA-msgtext5
                into g_TABCTRL_WA-msgtext separated by '/'.

    SHIFT g_TABCTRL_WA-msgtext RIGHT DELETING TRAILING space.

    SHIFT g_TABCTRL_WA-msgtext RIGHT DELETING TRAILING '/'.

    SHIFT g_TABCTRL_WA-msgtext LEFT DELETING LEADING space.

    SHIFT g_TABCTRL_WA-msgtext LEFT DELETING LEADING '/'.

    REPLACE '///' WITH '/' INTO g_TABCTRL_WA-msgtext.
    REPLACE '//' WITH '/' INTO g_TABCTRL_WA-msgtext.


    modify g_TABCTRL_itab from g_TABCTRL_wa
    index l_sytabix
    transporting  msgtype msgtext.

  endloop.
endmodule.                 " set_message  OUTPUT
