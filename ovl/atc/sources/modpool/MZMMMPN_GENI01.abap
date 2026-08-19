*--- MAIN PROGRAM: MZMMMPN_GENI01 ---*
*&---------------------------------------------------------------------*
*&      Module  TC_REQUEST_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_REQUEST_mark input.
  if TC_REQUEST-line_sel_mode = 1 and g_TC_REQUEST_wa-flag = 'X'.
    loop at g_TC_REQUEST_itab into g_TC_REQUEST_wa where flag = 'X'.
      g_TC_REQUEST_wa-flag = ''.
      modify g_TC_REQUEST_itab from g_TC_REQUEST_wa transporting flag.

    endloop.
    g_TC_REQUEST_wa-flag = 'X'.
  endif.
  modify g_TC_REQUEST_itab from g_TC_REQUEST_wa index
                           TC_REQUEST-current_line transporting flag.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  TC_REQUEST_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_REQUEST_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TC_REQUEST'
                              'G_TC_REQUEST_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  clear : G_TS_REQUEST,
          wa_log,
          wa_merrdat,
          g_TC_DETAILS_wa,
          g_TC_request_wa.
  clear : ist_log,
          ist_merrdat,
          g_TC_DETAILS_itab,
          g_TC_request_itab.

  LEAVE TO SCREEN 0.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  TS_REQUEST_ACTIVE_TAB_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* INPUT MODULE FOR TABSTRIP 'TS_REQUEST': GETS ACTIVE TAB
MODULE TS_REQUEST_ACTIVE_TAB_GET INPUT.
  OK_CODE = SY-UCOMM.
  CASE OK_CODE.
    WHEN C_TS_REQUEST-TAB1.
      G_TS_REQUEST-PRESSED_TAB = C_TS_REQUEST-TAB1.
    WHEN C_TS_REQUEST-TAB2.
      G_TS_REQUEST-PRESSED_TAB = C_TS_REQUEST-TAB2.
    WHEN C_TS_REQUEST-TAB3.
      G_TS_REQUEST-PRESSED_TAB = C_TS_REQUEST-TAB3.
** SAB_sumodh
*     when 'GENE'.
*       PERFORM INSERT_PROCESS.
** sab_sumodh

    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  TC_DETAILS_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_DETAILS_mark input.
  if TC_DETAILS-line_sel_mode = 1 and
     g_TC_DETAILS_wa-flag = 'X'.
    loop at g_TC_DETAILS_itab into g_TC_DETAILS_wa
      where flag = 'X'.
      g_TC_DETAILS_wa-flag = ''.
      modify g_TC_DETAILS_itab
        from g_TC_DETAILS_wa
        transporting flag.
    endloop.
    g_TC_DETAILS_wa-flag = 'X'.
  endif.
  modify g_TC_DETAILS_itab
    from g_TC_DETAILS_wa
    index TC_DETAILS-current_line
    transporting flag.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  TC_DETAILS_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_DETAILS_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TC_DETAILS'
                              'G_TC_DETAILS_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  tc_log_user_command  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_log_user_command INPUT.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TC_LOG'
                              'IST_LOG'
                              ' '
                     changing OK_CODE.
  sy-ucomm = OK_CODE.

ENDMODULE.                 " tc_log_user_command  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       Generate MPN Code through LSMW
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9001 INPUT.

  IF SY-UCOMM = 'GENE'.
    CLEAR gt_buffer.
    REFRESH gt_buffer.
    IF NOT g_TC_DETAILS_itab[] IS INITIAL.
      PERFORM GET_DATA_LSMW.
*      PERFORM SCH_LSMW.
      PERFORM INSERT_PROCESS.
*      PERFORM CLOSE_JOB.
      PERFORM POPULATE_LOG.
      PERFORM SEND_MAIL.
    ENDIF.
    PERFORM unlock_records.
    perform clear_source_tables.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_9001  INPUT

*---------------------------------------------------------------------*
*       MODULE TC_MATNR_PRTNO_user_command INPUT                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module TC_MATNR_PRTNO_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TC_MATNR_PRTNO'
                              'G_TC_MATNR_PRTNO_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
