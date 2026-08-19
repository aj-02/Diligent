*--- MAIN PROGRAM: MZMMMPN_GENO01 ---*
*&---------------------------------------------------------------------*
*&      Module  TC_REQUEST_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_REQUEST_init output.
  DESCRIBE TABLE g_TC_REQUEST_itab LINES g_rec_found.
  TC_REQUEST-LINES = g_rec_found.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TC_REQUEST_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_REQUEST_move output.
  move-corresponding g_TC_REQUEST_wa to ZMM_MPN.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TC_REQUEST_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_REQUEST_get_lines output.
  g_TC_REQUEST_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'MPN01'.
  IF g_req_type = 'N'.
    SET TITLEBAR 'MPNT1' with text-005 text-006.
  ELSEIF g_req_type = 'C'.
    SET TITLEBAR 'MPNT1' with text-005 text-007.
  ENDIF.
ENDMODULE.                 " STATUS_9000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TS_REQUEST_ACTIVE_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
* OUTPUT MODULE FOR TABSTRIP 'TS_REQUEST': SETS ACTIVE TAB
MODULE TS_REQUEST_ACTIVE_TAB_SET OUTPUT.
  TS_REQUEST-ACTIVETAB = G_TS_REQUEST-PRESSED_TAB.
  CASE G_TS_REQUEST-PRESSED_TAB.
    WHEN C_TS_REQUEST-TAB1.
      G_TS_REQUEST-SUBSCREEN = '9001'.
    WHEN C_TS_REQUEST-TAB2.
      G_TS_REQUEST-SUBSCREEN = '9002'.
    WHEN C_TS_REQUEST-TAB3.
      G_TS_REQUEST-SUBSCREEN = '9003'.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  TC_DETAILS_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_DETAILS_init output.
  if not g_TC_REQUEST_itab[] is initial .
    loop at g_TC_REQUEST_itab into g_TC_REQUEST_wa where flag = 'X'.
      select * from zmm_mpn appending corresponding fields of table
                 g_tc_details_itab where docno = g_TC_REQUEST_wa-docno
                                   and sflag = 'N'.
      if sy-subrc = 0.
        clear ist_log.
      endif.
      clear g_TC_REQUEST_wa-flag.
      modify g_TC_REQUEST_itab from g_TC_REQUEST_wa transporting flag.
    endloop.
  endif.
  if not g_tc_details_itab[] is initial.
    sort g_tc_details_itab.
    delete adjacent duplicates from g_tc_details_itab.
  endif.

  if not  g_tc_details_itab[] is initial.
    perform check_orig_mpncode.
    sort g_tc_details_itab.
    delete adjacent duplicates from g_tc_details_itab.
  endif.
  DESCRIBE TABLE g_tc_details_itab LINES TC_DETAILS-LINES.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TC_DETAILS_get_lines  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC_DETAILS_get_lines output.
  g_TC_DETAILS_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  get_log_lines  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_log_lines OUTPUT.
  g_tc_log_lines = sy-loopc.
ENDMODULE.                 " get_log_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_DETAILS_move  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_DETAILS_move OUTPUT.
  move-corresponding g_TC_DETAILS_wa to ZMM_MPN.
ENDMODULE.                 " TC_DETAILS_move  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_button_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_button_attr OUTPUT.
  DATA : l_flag.
  clear l_flag.

  IF g_TC_DETAILS_itab[] IS INITIAL.
    l_flag = '1'.
  ELSE.
    read table g_TC_DETAILS_itab with key flag = 'X' transporting no
                                                     fields.
    check sy-subrc <> 0.
    l_flag = '1'.
  ENDIF.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = '100'.
      SCREEN-INVISIBLE = l_flag.
      MODIFY SCREEN.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " set_button_attr  OUTPUT

*---------------------------------------------------------------------*
*       MODULE TC_MATNR_PRTNO_init OUTPUT                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module TC_MATNR_PRTNO_init output.

  if not g_TC_DETAILS_itab[] is initial.
    select matnr mfrnr mfrpn from MARA into corresponding fields of
                             table g_TC_MATNR_PRTNO_itab for all entries
                             in g_TC_DETAILS_itab where
                             mfrpn = g_TC_DETAILS_itab-mfrpn.

    if not g_TC_MATNR_PRTNO_itab[] is initial.
      loop at g_TC_MATNR_PRTNO_itab into g_TC_MATNR_PRTNO_wa.
        if g_TC_MATNR_PRTNO_wa-matnr+0(1) = '9'.
          delete g_TC_MATNR_PRTNO_itab index sy-tabix.
        else.
          select single maktx from makt into g_TC_MATNR_PRTNO_wa-maktx
                               where matnr = g_TC_MATNR_PRTNO_wa-matnr.
          modify g_TC_MATNR_PRTNO_itab FROM g_TC_MATNR_PRTNO_wa.
        endif.
      endloop.
    endif.

  endif.
  DESCRIBE TABLE g_TC_MATNR_PRTNO_itab LINES TC_MATNR_PRTNO-lines.
endmodule.


*---------------------------------------------------------------------*
*       MODULE TC_MATNR_PRTNO_get_lines OUTPUT                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
module TC_MATNR_PRTNO_get_lines output.
  move-corresponding g_TC_MATNR_PRTNO_wa to mara.
  makt-maktx = g_TC_MATNR_PRTNO_wa-maktx.
  g_TC_MATNR_PRTNO_lines = sy-loopc.
endmodule.
