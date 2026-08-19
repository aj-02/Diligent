*--- MAIN PROGRAM: MZMMMPNI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMMPNI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       user handler for screen 9001
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.

  if g_function is initial.
    g_function = g_ok_9001.
    g_obj_code = g_ok_9001. "used in statusbar display
  endif.

  clear g_ok_9001. clear zmm_mpn.
  leave to screen 9010.
ENDMODULE.                 " USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_scr  INPUT
*&---------------------------------------------------------------------*
*       exit screen / program
*----------------------------------------------------------------------*
MODULE exit_scr INPUT.

  if sy-dynnr = '9001'.
    set screen 0.
    leave to screen 0.
  else.
    g_exit = g_ok_9010.
    clear g_ok_9010.
    perform confirm_step.
  endif.

ENDMODULE.                 " exit_scr  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9010  INPUT
*&---------------------------------------------------------------------*
*       user handler for screen 9010
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9010 INPUT.

  case g_ok_9010.
    when 'UPD'.
      clear g_ok_9010.
      PERFORM VERIFY_CERTIFICATE.
      CHECK SY-UCOMM = 'AGRE' .
      perform save_database.
      check g_dup is initial.
      perform clear_memory.
      leave to screen '9001'.
*    when ' '.
*      perform get_search_results.
*      perform chk_item_search_result.
  endcase.

ENDMODULE.                 " USER_COMMAND_9010  INPUT

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_modify  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
module G_NEW_MPN_modify input.
  perform chk_org_new_vend_part.
  perform chk_item_open_request.
  perform get_search_results using zmm_mpn-matnr.
*  perform chk_item_search_result.
  perform fetch_matnr using zmm_mpn-mfrpn.
  IF SY-UCOMM = 'AGRE' OR
     SY-UCOMM = 'OLD'.
    CLEAR ist_mpn_srch.
    REFRESH ist_mpn_srch.
    EXIT.
  ELSE.
    move-corresponding ZMM_MPN to wa_mpn.
    wa_mpn-maktx = wa_makt-maktx.
    modify ist_mpn from wa_mpn index
                                   G_NEW_MPN-current_line.
    if sy-subrc <> 0.
      append wa_mpn to ist_mpn.
    endif.
  ENDIF.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_mark  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
module G_NEW_MPN_mark input.
  if G_NEW_MPN-line_sel_mode = 1. "and G_G_NEW_MPN_WA-FLAG = 'X'.
*wa_mpn-flag = 'X'.
    loop at ist_mpn into wa_mpn where flag = 'X'.
      wa_mpn-flag = ''.
      modify ist_mpn from wa_mpn transporting flag.
    endloop.
    wa_mpn-flag = 'X'.
  endif.
  modify ist_mpn from wa_mpn index G_NEW_MPN-current_line
                                             transporting flag.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_NEW_MPN_user_command  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
module G_NEW_MPN_user_command input.
  G_OK_9010 = sy-ucomm.
  perform user_ok_tc using    'G_NEW_MPN'
                              'ist_mpn'
                              'FLAG'
                     changing G_OK_9010.
  sy-ucomm = G_OK_9010.

endmodule.

*&---------------------------------------------------------------------*
*&      Module  G_SRC_MPN_user_command  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
module G_SRC_MPN_user_command input.
  G_OK_9010 = sy-ucomm.
  perform user_ok_tc using    'G_SRC_MPN'
                              'IST_MPN_SRCH'
                              ' '
                     changing G_OK_9010.
  sy-ucomm = G_OK_9010.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  validate_cocode  INPUT
*&---------------------------------------------------------------------*
*       validate company code
*----------------------------------------------------------------------*
MODULE validate_cocode INPUT.

  if not zmm_mpn-bukrs is initial.
    if ist_t001[] is initial.
      perform get_valid_cocodes.
    endif.
    read table ist_t001 with key bukrs = zmm_mpn-bukrs.
    if sy-subrc <> 0.
      message e431(zmm).
    else.
      g_butxt = ist_t001-butxt.
    endif.
  endif.

ENDMODULE.                 " validate_cocode  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cocode  INPUT
*&---------------------------------------------------------------------*
*       company code help
*----------------------------------------------------------------------*
MODULE get_cocode INPUT.

  Perform get_valid_cocodes.

  if not ist_t001[] is initial.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
         EXPORTING
              RETFIELD        = 'BUKRS'
              DYNPPROG        = sy-cprog
              DYNPNR          = sy-dynnr
              VALUE_ORG       = 'S'
         TABLES
              VALUE_TAB       = ist_t001
              RETURN_TAB      = ist_return_tab
         EXCEPTIONS
              PARAMETER_ERROR = 1
              NO_VALUES_FOUND = 2
              OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    ZMM_MPN-BUKRS = ist_return_tab-fieldval.
  endif.

ENDMODULE.                 " get_cocode  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       validate material
*----------------------------------------------------------------------*
MODULE VALIDATE INPUT.
  clear ist_mara.

  CALL FUNCTION 'MARA_READ'
       EXPORTING
            I_MATNR   = zmm_mpn-matnr
            I_SPRACHE = SY-LANGU
       IMPORTING
            E_MAKT    = wa_makt
            E_MARA    = ist_mara
       EXCEPTIONS
            NO_ENTRY  = 1
            OTHERS    = 2.
  IF SY-SUBRC <> 0.
    msg_log-msgno = sy-msgno.
    msg_log-msgty = sy-msgty.
    msg_log-msgid = sy-msgid.

    CALL FUNCTION 'MESSAGE_TEXTS_READ'
         EXPORTING
              msg_log_imp  = msg_log
         IMPORTING
              msg_text_exp = msg_text
         EXCEPTIONS
              OTHERS       = 1.

    message e735(ZMM) with msg_text-msgtx.

  ELSE.
    IF ist_mara-mfrnr is initial or ist_mara-mfrpn is initial.
      Message e330(zmm) with TEXT-005 zmm_mpn-matnr.
    ENDIF.

    IF not zmm_mpn-matnr+0(2) in r_mat_grp.
      message e735(ZMM) with 'Only Spares Material allowed'.
    ELSE.
*      read table ist_mpn into wa_mpn with key matnr = zmm_mpn-matnr.
*      if sy-subrc is initial.
*        Message e366(zmm).
*      else.
*        perform get_search_results using zmm_mpn-matnr.
      append ist_mara to ist_mara1.
*      endif.
    ENDIF.

  ENDIF.

ENDMODULE.                 " VALIDATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_ranges  INPUT
*&---------------------------------------------------------------------*
*       valid material codes
*----------------------------------------------------------------------*
MODULE init_ranges INPUT.

  r_mat_grp-sign = 'I'.
  r_mat_grp-option = 'BT'.
  r_mat_grp-low = '21'.
  r_mat_grp-high = '42'.
  append r_mat_grp.

ENDMODULE.                 " init_ranges  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_data  INPUT
*&---------------------------------------------------------------------*
*       get data from table zmm_mpn based on request no
*----------------------------------------------------------------------*
MODULE get_data INPUT.

  if g_function = 'CHG'.
select * from zmm_mpn into table ist_zmmmpn where docno = zmm_mpn-docno
                                                        and sflag = 'N' ORDER BY PRIMARY KEY.
  else.
select * from zmm_mpn into table ist_zmmmpn where docno = zmm_mpn-docno ORDER BY PRIMARY KEY.
  endif.
*------- VALIDATION DURING CHANGE/DELETION OF DOCNO.-------*
  IF NOT ist_zmmmpn[] IS INITIAL AND SY-SUBRC IS INITIAL.
    READ TABLE ist_zmmmpn INDEX 1.
    IF SY-SUBRC IS INITIAL AND SY-UNAME <> ist_zmmmpn-ernam AND
       ( g_function = 'CHG' OR g_function = 'DEL' ).
       Message s353(ZMM).
       Leave to screen 9001.
    ENDIF.
  ENDIF.
*--------END OF DOCNO CHG/DEL VALIDATION ------------------*
  if sy-subrc is initial.
    clear :ist_mpn, ist_mpn_srch.
    refresh :ist_mpn, ist_mpn_srch.
    loop at ist_zmmmpn.
      move-corresponding ist_zmmmpn to zmm_mpn.
      move-corresponding ist_zmmmpn to wa_mpn.
      CALL FUNCTION 'MARA_READ'
           EXPORTING
                I_MATNR   = zmm_mpn-matnr
                I_SPRACHE = SY-LANGU
           IMPORTING
                E_MAKT    = wa_makt
                E_MARA    = ist_mara
           EXCEPTIONS
                NO_ENTRY  = 1
                OTHERS    = 2.
      move wa_makt-maktx to wa_mpn-maktx.
      append wa_mpn to ist_mpn.
      append ist_mara to ist_mara1.
    endloop.
  else.
    message e803(zmm) with text-001.
  endif.

  clear ist_zmmmpn.
  refresh ist_zmmmpn.
ENDMODULE.                 " get_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_dclk  INPUT
*&---------------------------------------------------------------------*
*       routine handler - db click
*----------------------------------------------------------------------*
MODULE user_dclk INPUT.
  GET CURSOR FIELD L_CURSORFIELD.
  CASE L_CURSORFIELD.
    WHEN 'ZMM_MPN-MATNR'.
      perform get_search_results using zmm_mpn-matnr.
    WHEN 'IST_MPN_SRCH-BMATN'.
      SET PARAMETER ID 'MAT' FIELD IST_MPN_SRCH-BMATN.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    WHEN 'IST_MARA-MFRNR' .
      SET PARAMETER ID 'LIF' FIELD IST_MARA-MFRNR.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
*      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
      CALL FUNCTION 'MIGO_DIALOG'
                .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    WHEN 'IST_MPN_SRCH-MFRNR'.
      SET PARAMETER ID 'LIF' FIELD IST_MPN_SRCH-MFRNR.
      CALL FUNCTION 'MIGO_DIALOG'
                .
*      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
    WHEN 'IST_MPN_SRCH-MFRPN'.
      perform fetch_matnr using zmm_mpn-mfrpn.
  ENDCASE.

ENDMODULE.                 " user_dclk  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_docno  INPUT
*&---------------------------------------------------------------------*
*       f4 help routine
*----------------------------------------------------------------------*
MODULE get_docno INPUT.

  clear : ist_docno, ist_return_tab.
  refresh : ist_docno, ist_return_tab.

  if g_function = 'CHG'.
    select distinct docno bukrs ernam ersda from zmm_mpn
                    into table ist_docno where sflag = 'N'.
  else.
    select distinct docno bukrs ernam ersda from zmm_mpn
                                            into table ist_docno.
  endif.
  if not ist_docno[] is initial.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
         EXPORTING
              RETFIELD        = 'DOCNO'
              DYNPPROG        = sy-cprog
              DYNPNR          = sy-dynnr
              VALUE_ORG       = 'S'
              WINDOW_TITLE    = 'Requests in Ztable'
         TABLES
              VALUE_TAB       = ist_docno
              RETURN_TAB      = ist_return_tab
         EXCEPTIONS
              PARAMETER_ERROR = 1
              NO_VALUES_FOUND = 2
              OTHERS          = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    ZMM_MPN-DOCNO = ist_return_tab-fieldval.
  ELSE.
    Message i735(zmm) with text-003.
  endif.

ENDMODULE.                 " get_docno  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_vendor  INPUT
*&---------------------------------------------------------------------*
*       validate vendor routine
*----------------------------------------------------------------------*
MODULE validate_vendor INPUT.

  select single * from lfa1 into wa_lfa1 where lifnr = zmm_mpn-mfrnr.
  if sy-subrc <> 0.
    message e011(zmm) with zmm_mpn-mfrnr.
  endif.

ENDMODULE.                 " validate_vendor  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_duplicate_entry  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE chk_duplicate_entry INPUT.

  read table ist_mpn into wa_mpn with key matnr = zmm_mpn-matnr
                                          mfrnr = zmm_mpn-mfrnr
                                          mfrpn = zmm_mpn-mfrpn.
  if sy-subrc is initial.
    Message e735(zmm) with text-205.
  endif.

ENDMODULE.                 " chk_duplicate_entry  INPUT
*&---------------------------------------------------------------------*
*&      Module  chk_dclk  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE chk_dclk INPUT.
  check sy-ucomm = '/CS'.
  GET CURSOR LINE g_linno .
  read table ist_mpn into wa_mpn index g_linno.
  if sy-subrc is initial.
    perform fetch_matnr using wa_mpn-mfrpn.
  endif.
ENDMODULE.                 " chk_dclk  INPUT
