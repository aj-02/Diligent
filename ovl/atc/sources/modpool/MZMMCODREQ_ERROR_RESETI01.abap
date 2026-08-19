*--- MAIN PROGRAM: MZMMCODREQ_ERROR_RESETI01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 30/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
*
*
************************************************************************
***INCLUDE MZMMCODREQI01 .
*&spwizard: input modul for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
module TABCTRL100_mark input.
  data: g_TABCTRL100_wa2 like line of IST_SRCHLP.
  if TABCTRL100-line_sel_mode = 1.
    loop at IST_SRCHLP into g_TABCTRL100_wa2
      where MARK = 'X'.
      g_TABCTRL100_wa2-MARK = ''.
      modify IST_SRCHLP
        from g_TABCTRL100_wa2
        transporting MARK.
    endloop.
  endif.
  modify IST_SRCHLP
    from WA_SRCHLP
    index TABCTRL100-current_line
    transporting MARK.
endmodule.

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
module TABCTRL100_user_command input.
  OKCODE_100 = sy-ucomm.
  GET CURSOR FIELD g_CURFIELD.
  if g_curfield = 'ZMM_CDHD_ST-MTART' .
    Case ZMM_CDHD_ST-MTART.
      when 'ZCAP'.
        dynnr = '0130'.
      when 'ZSPR'.
        dynnr = '0120'.
      when 'ZSTO'.
        dynnr = '0110'.
      when 'ZDIS'.
        dynnr = '0140'.
      when others.
        dynnr = '0101'.
    endcase.
  Endif.
  perform user_ok_tc using    'TABCTRL100'
                              'IST_SRCHLP'
                              'MARK'
                     changing OKCODE_100.
  sy-ucomm = OKCODE_100.
****Calling transaction MK03 for vendor.
  read table ist_srchlp into wa_srchlpmk03 index g_curr_line_100.
  g_mfrnr  = WA_SRCHLPmk03-mfrnr.
  if g_curfield = 'WA_SRCHLP-MFRNR'. "and g_cursor_line = sy-stepl.
*    g_mfrnr     =  WA_SRCHLP-MFRNR.
    if not g_mfrnr is initial.
      "Begin of ATC Correction 29.04.2026
*      set parameter id 'LIF' field g_mfrnr.
*      call transaction 'MK03' and skip first screen.
      DATA(l_vend) = CONV Lifnr( g_mfrnr ).
      SELECT PARTNER FROM V_CVI_VEND_LINK
 INTO @DATA(LV_PARTNER) UP TO 1 ROWS WHERE LIFNR = @L_VEND
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      DATA(request) = NEW cl_bupa_navigation_request( ).
      request->set_partner_number( lv_partner ).     " import your BP number here
      CALL METHOD request->set_bupa_activity
      EXPORTING
      iv_value = request->gc_activity_display.
      DATA(options) = NEW cl_bupa_dialog_joel_options( ).
      options->set_navigation_disabled( abap_true ).
      cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
      iv_options = options ).
      "End of ATC Correction 29.04.2026
    endif.
  endif.
*****End.

endmodule.
*&spwizard: input module for tc 'TABCTRL110'. do not change this line!
*&spwizard: modify table
*--------------------------------------------------------------------
module TABCTRL110_modify input.
*---------------------------------------------------------------------
*Data : g_field like g_curfield.
  data : g_oth_level.
  g_ok_code110 = sy-ucomm.
  clear g_field.

  if zmm_cditem-oth1 = 'X' or
     zmm_cditem-oth2 = 'X' or
     zmm_cditem-oth3 = 'X' or
     zmm_cditem-oth4 = 'X'.
  Else.
    replace 'M' with '' into zmm_cditem-comp_flg.
  Endif.

  move-corresponding ZMM_CDITEM to g_TABCTRL110_wa.

*  modify g_TABCTRL110_itab
*    from g_TABCTRL110_wa
*    index TABCTRL110-current_line.
*
***** Addition
*  if sy-subrc <> 0.
*    append g_TABCTRL110_wa to g_TABCTRL110_itab.
*  endif.
*****

*++++++++260405
  concatenate g_tabctrl110_wa-oth1 g_tabctrl110_wa-oth2
              g_tabctrl110_wa-oth3 g_tabctrl110_wa-oth4 into g_oth.

  if g_ok_code110 = 'PB_AD'.
*   and g_oth = ''.
    if g_cursor_line = sy-stepl.

      Perform popup_userdesc.
      If g_ok_code115 = 'OK115'.
        Perform GC_Fields_115.

      Endif.
    Endif.
  Endif.

  Case 'X'.
    When g_TABCTRL110_wa-oth1.
*       g_oth_level = '1'.
      concatenate 'ZMM_CDITEM-DESC' '1' into g_field.
    When g_TABCTRL110_wa-oth2.
      concatenate 'ZMM_CDITEM-DESC' '2' into g_field.
*       g_oth_level = '2'.
    When g_TABCTRL110_wa-oth3.
      concatenate 'ZMM_CDITEM-DESC' '3' into g_field.
*       g_oth_level = '3'.
    When g_TABCTRL110_wa-oth4.
      concatenate 'ZMM_CDITEM-DESC' '4' into g_field.
*       g_oth_level = '4'.
    when others.
*       g_oth_level = ''.

  Endcase.

*++240405
  if g_mode = 'CHA' and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' )
     and  g_field = g_curfield and g_cursor_line = sy-stepl.
*   and
*        TABCTRL110_wa-oth1 = 'X' or
*        g_TABCTRL110_wa-oth2 = 'X'  or
*        g_TABCTRL110_wa-oth3 = 'X'  or
*        g_TABCTRL110_wa-oth4 = 'X' )
*
    g_desc1 = g_tabctrl110_wa-desc1.
    g_desc2 = g_tabctrl110_wa-desc2.
    g_desc3 = g_tabctrl110_wa-desc3.
    g_desc4 = g_tabctrl110_wa-desc4.
    g_matgp = g_tabctrl110_wa-matgp.
*
    select single WGBEZ from T023T into g_matgp_desc where MATKL =
    g_matgp and spras = sy-langu.
    if sy-subrc <> 0.
      g_matgp = ''.
    Endif.
    G_USER_DESC = g_tabctrl110_wa-user_desc.
    Perform popup_userdesc.
    clear g_field.
    If g_ok_code115 = 'OK115'.
      Perform GC_Fields_115.
*          g_tabctrl110_wa-oth1 = ''.
    Endif.

  Endif.
*----240405

  if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
    g_matcode = ZMM_CDITEM-MATCODE.
    if not g_matcode is initial.
      set parameter id 'MAT' field g_matcode.
      call transaction 'MM03' and skip first screen.
    endif.
  endif.

*  PERFORM attrib_parno.

  if g_curfield = 'ZMM_CDITEM-DESC1' and g_cursor_line = sy-stepl.

*  if desc11 <> g_TABCTRL110_wa-desc1.
*
*      clear  : g_TABCTRL110_wa-desc2,
*               g_TABCTRL110_wa-desc3,
*               g_TABCTRL110_wa-desc4,
*               g_TABCTRL110_wa-oth2,
*               g_TABCTRL110_wa-oth3,
*               g_TABCTRL110_wa-oth4,
*               g_TABCTRL110_wa-user_desc.
*  endif.

    if TABCTRL110_check_flag = 'X'.
      g_hits_par = '1'.
    endif.

    desc11 = g_TABCTRL110_wa-desc1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.
    if ( g_mode = 'CRE' or g_mode = 'CHA' )
        and TABCTRL110_check_flag = 'X'.
      g_hits_par = '1'.
*      and g_TABCTRL110_wa-oth1 = 'X'.
      If g_ok_code115 <> 'OK115'.
*         clear : g_TABCTRL110_wa-desc2,
*                g_TABCTRL110_wa-desc3,
*                g_TABCTRL110_wa-desc4,
*                g_TABCTRL110_wa-oth2,
*                g_TABCTRL110_wa-oth3,
*                g_TABCTRL110_wa-oth4,
*                g_TABCTRL110_wa-user_desc,
        clear  TABCTRL110_check_flag.
      Endif.
    Endif.
    if not g_TABCTRL110_wa-matgp is initial.
      g_matgp = g_TABCTRL110_wa-matgp.
    else.
      get parameter id 'ZMATGP' field g_matgp .
      g_TABCTRL110_wa-matgp = g_matgp .
    endif.
    if g_TABCTRL110_wa-desc1 <> 'OTHER'.
      perform TABCTRL110_desc1_check.
      if TABCTRL110_check_flag = 'X'.
        g_hits_par = '1'.
      endif.
*        if not ZMM_CDITEM-OTH1 is initial.
*           Perform popup_userdesc1.
*        endif.
    endif.
    if g_TABCTRL110_wa-desc1 = 'OTHER'.
      g_TABCTRL110_wa-OTH1 = 'X'.
*       g_hits_par = '0'.
      g_hits_par = '4'.
      g_hits_par_oth = 'X'.
*        g_TABCTRL110_wa-OTH2 = ''.
*        g_TABCTRL110_wa-OTH3 = ''.
*        g_TABCTRL110_wa-OTH4 = ''.
*        g_TABCTRL110_wa-USER_DESC = ''.

*        clear: g_TABCTRL110_wa-desc1,   "
*               g_TABCTRL110_wa-desc2,   "
*               g_TABCTRL110_wa-desc3,   "
*               g_TABCTRL110_wa-desc4.   "
      Perform popup_userdesc.
      If g_ok_code115 = 'OK115'.
        Perform GC_Fields_115.
      endif.
      Perform move_descriptions.
    elseif g_TABCTRL110_wa-OTH1 = 'X'.
      g_hits_par = '4'.
      g_hits_par_oth = 'X'..
      descp1 = g_TABCTRL110_wa-desc1.
    else.
      clear g_TABCTRL110_wa-OTH1.
      descp1 = g_TABCTRL110_wa-desc1.
    endif.
    check_pos = '1'.
  endif.

  if g_curfield = 'ZMM_CDITEM-DESC2' and g_cursor_line = sy-stepl..
    g_matgp = g_TABCTRL110_wa-matgp.
    g_TABCTRL110_wa-desc1 = zmm_cditem-desc1.
    descp1 = g_TABCTRL110_wa-desc1.
    if ( g_mode = 'CRE' or g_mode = 'CHA' )
       and TABCTRL110_check_flag = 'X'.
      g_hits_par = '2'.
*    and g_TABCTRL110_wa-oth2 = 'X'.
      clear : g_TABCTRL110_wa-desc3,
              g_TABCTRL110_wa-desc4,
              g_TABCTRL110_wa-oth3,
              g_TABCTRL110_wa-oth4,
              g_TABCTRL110_wa-user_desc,
              TABCTRL110_check_flag.
    endif.
    set parameter id 'ZDESC_1' field g_TABCTRL110_wa-desc1.
*    descp2 = g_TABCTRL110_wa-desc2.
    if g_TABCTRL110_wa-desc2 <> 'OTHER'.
      perform TABCTRL110_desc2_check.
      if TABCTRL110_check_flag = 'X'.
        g_hits_par = '2'.
      endif.
*        if not ZMM_CDITEM-OTH2 is initial.
*           Perform popup_userdesc2.
*        endif.
    endif.
    if g_TABCTRL110_wa-desc2 = 'OTHER'.
      g_TABCTRL110_wa-OTH2 = 'X'.
      g_hits_par_oth = 'X'.
      g_hits_par = '4'.
*       g_TABCTRL110_wa-OTH3 = ''.
*       g_TABCTRL110_wa-OTH4 = ''.
*       g_TABCTRL110_wa-USER_DESC = ''.

*               g_TABCTRL110_wa-desc2,   "
*               g_TABCTRL110_wa-desc3,   "
*               g_TABCTRL110_wa-desc4.   "
      Perform popup_userdesc.
      If g_ok_code115 = 'OK115'.
        Perform GC_Fields_115.
      endif.
      Perform move_descriptions.
    elseif g_TABCTRL110_wa-OTH2 = 'X'.
      clear g_hits_par.
      descp2 = g_TABCTRL110_wa-desc2.
    else.
      clear g_TABCTRL110_wa-OTH2.
      descp2 = g_TABCTRL110_wa-desc2.
    endif.
*    set parameter id 'ZDESC_2' field desc22.
    FIELD1 = 'ZMM_CDITEM-DESC2'.
    check_pos = '2'.
  endif.

  if g_curfield = 'ZMM_CDITEM-DESC3' and g_cursor_line = sy-stepl.
    g_matgp = g_TABCTRL110_wa-matgp.
    descp1 = g_TABCTRL110_wa-desc1.
    descp2 = g_TABCTRL110_wa-desc2.
    if ( g_mode = 'CRE' or g_mode = 'CHA' )
       and TABCTRL110_check_flag = 'X'.
      g_hits_par = '3'.
*    and g_TABCTRL110_wa-oth3 = 'X'.
      clear : g_TABCTRL110_wa-desc4,
              g_TABCTRL110_wa-oth4,
              g_TABCTRL110_wa-user_desc,
              TABCTRL110_check_flag.
    endif.
*    descp3 = g_TABCTRL110_wa-desc3.
    if g_TABCTRL110_wa-desc3 <> 'OTHER'.
      perform TABCTRL110_desc3_check.
      if TABCTRL110_check_flag = 'X'.
        g_hits_par = '3'.
      endif.
*        if not ZMM_CDITEM-OTH3 is initial.
*           Perform popup_userdesc3.
*        endif.
    endif.
    if g_TABCTRL110_wa-desc3 = 'OTHER'.
      g_TABCTRL110_wa-OTH3 = 'X'.
      g_hits_par_oth = 'X'.
      g_hits_par = '4'.
*       g_TABCTRL110_wa-OTH4 = ''.
*       g_TABCTRL110_wa-USER_DESC = ''.

*               g_TABCTRL110_wa-desc3,   "
*               g_TABCTRL110_wa-desc4.   "
      Perform popup_userdesc.
      If g_ok_code115 = 'OK115'.
        Perform GC_Fields_115.
      endif.
      Perform move_descriptions.
    elseif g_TABCTRL110_wa-OTH3 = 'X'.
      clear g_hits_par.
      descp3 = g_TABCTRL110_wa-desc3.
    else.
      clear g_TABCTRL110_wa-OTH3.
      descp3 = g_TABCTRL110_wa-desc3.
    endif.
*    set parameter id 'ZDESC_3' field desc33.

    FIELD1 = 'ZMM_CDITEM-DESC3'.
    check_pos = '3'.
  endif.

  if g_curfield = 'ZMM_CDITEM-DESC4' and g_cursor_line = sy-stepl.
    g_matgp = g_TABCTRL110_wa-matgp.
    descp1 = g_TABCTRL110_wa-desc1.
    descp2 = g_TABCTRL110_wa-desc2.
    descp3 = g_TABCTRL110_wa-desc3.
*    descp4 = g_TABCTRL110_wa-desc4.
    if g_TABCTRL110_wa-desc4 <> 'OTHER'.
      perform TABCTRL110_desc4_check.
      if TABCTRL110_check_flag = 'X'.
        g_hits_par = '4'.
      endif.
*        if not ZMM_CDITEM-OTH4 is initial.
*           Perform popup_userdesc4.
*        endif.
    endif.
    if g_TABCTRL110_wa-desc4 = 'OTHER'.
      g_TABCTRL110_wa-OTH4 = 'X'.
      g_hits_par_oth = 'X'.
      g_hits_par = '4'.
*       g_TABCTRL110_wa-USER_DESC = ''.
*               g_TABCTRL110_wa-desc4.   "

      Perform popup_userdesc.
      If g_ok_code115 = 'OK115'.
        Perform GC_Fields_115.
      endif.
      Perform move_descriptions.

      g_TABCTRL110_wa-user_desc = g_user_desc.
    elseif g_TABCTRL110_wa-OTH4 = 'X'.
      clear g_hits_par.
      descp4 = g_TABCTRL110_wa-desc4.
    else.
      clear g_TABCTRL110_wa-OTH4.
      descp4 = g_TABCTRL110_wa-desc4.
    endif.
*    set parameter id 'ZDESC_3' field desc33.

    FIELD1 = 'ZMM_CDITEM-DESC4'.
    check_pos = '4'.
  endif.

  if g_curfield = 'ZMM_CDITEM-USER_DESC' and g_cursor_line = sy-stepl.
    descp5 = g_TABCTRL110_wa-user_desc.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    check_pos = '5'.
  endif.

  if g_TABCTRL110_wa-comp_flg is initial and
     not g_TABCTRL110_wa-rsn is initial.
    move space to g_TABCTRL110_wa-rsn.
  elseif not g_TABCTRL110_wa-comp_flg is initial.
    clear wa_rsn.
    select single * from ZMM_CODREQ_RSN into wa_rsn
   where reason = g_TABCTRL110_wa-comp_flg.
    g_TABCTRL110_wa-rsn = wa_rsn-description.
    clear wa_rsn.
  endif.
*****Addition************************************
*
  if sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl.
    if g_curfield = 'ZMM_CDITEM-DESC1' and zmm_cditem-oth1 = 'X'.
      Perform popup_userdesc.
    elseif g_curfield = 'ZMM_CDITEM-DESC2' and zmm_cditem-oth2 = 'X'.
      Perform popup_userdesc.
    elseif g_curfield = 'ZMM_CDITEM-DESC3' and zmm_cditem-oth3 = 'X'.
      Perform popup_userdesc.
    elseif g_curfield = 'ZMM_CDITEM-DESC4' and zmm_cditem-oth4 = 'X'.
      Perform popup_userdesc.
    endif.
*     ( zmm_cditem-oth1 = 'X'  OR  zmm_cditem-oth2 = 'X'    OR
*       zmm_cditem-oth3 = 'X'  OR  zmm_cditem-oth4 = 'X' ).
*    Perform popup_userdesc.
    clear g_field.
    If g_ok_code115 = 'OK115'.
      Perform GC_Fields_115.
    Endif.
  endif.
*****End*****************************************
  modify g_TABCTRL110_itab
    from g_TABCTRL110_wa
    index TABCTRL110-current_line.

**** Addition
  if sy-subrc <> 0.
    append g_TABCTRL110_wa to g_TABCTRL110_itab.
  endif.
****
*

  if sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
         and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
    Perform get_srno.
  Endif.
endmodule.

*&spwizard: input module for tc 'TABCTRL110'. do not change this line!
*&spwizard: mark table
module TABCTRL110_mark input.
  if TABCTRL110-line_sel_mode = 1 and
     g_TABCTRL110_wa-flag = 'X'.
    loop at g_TABCTRL110_itab into g_TABCTRL110_wa
      where flag = 'X'.
      g_TABCTRL110_wa-flag = ''.
      modify g_TABCTRL110_itab
        from g_TABCTRL110_wa
        transporting flag.
    endloop.
    g_TABCTRL110_wa-flag = 'X'.
  endif.
  modify g_TABCTRL110_itab
    from g_TABCTRL110_wa
    index TABCTRL110-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABCTRL110'. do not change this line!
*&spwizard: process user command
module TABCTRL110_user_command input.

  if check_pos = '1'.

    set parameter id 'ZDESC_1' field descp1.
    set parameter id 'ZDESC_2' field ''.
    set parameter id 'ZDESC_3' field ''.
    set parameter id 'ZDESC_4' field ''.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '2'.

    set parameter id 'ZDESC_1' field descp1.
    set parameter id 'ZDESC_2' field descp2.
    set parameter id 'ZDESC_3' field ''.
    set parameter id 'ZDESC_4' field ''.

    desc11 = descp1.
    desc22 = descp2.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '3'.

    set parameter id 'ZDESC_1' field descp1.
    set parameter id 'ZDESC_2' field descp2.
    set parameter id 'ZDESC_3' field descp3.
    set parameter id 'ZDESC_4' field ''.

    desc11 = descp1.
    desc22 = descp2.
    desc33 = descp3.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '4'.

    set parameter id 'ZDESC_1' field descp1.
    set parameter id 'ZDESC_2' field descp2.
    set parameter id 'ZDESC_3' field descp3.
    set parameter id 'ZDESC_4' field descp4.

    desc11 = descp1.
    desc22 = descp2.
    desc33 = descp3.
    desc44 = descp4.
    desc55 = ''.

  endif.

  if check_pos = '5'.

    case g_parno.
      when '2'.
        clear descp3.
        clear descp4.
      when '3'.
        clear descp4.
    endcase.

    desc11 = descp1.
    desc22 = descp2.
    desc33 = descp3.
    desc44 = descp4.
    desc55 = descp5.

  endif.

  if g_hits_par_oth = 'X'.

    set parameter id 'ZDESC_1' field descp1.
    set parameter id 'ZDESC_2' field descp2.
    set parameter id 'ZDESC_3' field descp3.
    set parameter id 'ZDESC_4' field descp4.

    desc11 = descp1.
    desc22 = descp2.
    desc33 = descp3.
    desc44 = descp4.
    desc55 = ''.

*   clear g_hits_par_oth.

  endif.

  g_lineno = g_curr_line.
  g_matgpo = g_matgp.

  get cursor field g_curfield.
*  OK_CODE = sy-ucomm.
*  perform user_ok_tc using    'TABCTRL110'
*                              'G_TABCTRL110_ITAB'
*                              'FLAG'
*                     changing OK_CODE.
*  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: modify table
module TABLCTRL130_modify input.
  ZMM_CDITEM-UOM = 'NO'.
*
  if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
    g_matcode = ZMM_CDITEM-MATCODE.
    if not g_matcode is initial.
      set parameter id 'MAT' field g_matcode.
      call transaction 'MM03' and skip first screen.
    endif.
  endif.

*
  move-corresponding ZMM_CDITEM to g_TABLCTRL130_wa.
  modify g_TABLCTRL130_itab
    from g_TABLCTRL130_wa
    index TABLCTRL130-current_line.
  if sy-subrc <> 0.
    append g_TABLCTRL130_wa to g_TABLCTRL130_itab.
  endif.
  If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
         and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
    Perform get_srno.
  Endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: mark table
module TABLCTRL130_mark input.
  if TABLCTRL130-line_sel_mode = 1 and
     g_TABLCTRL130_wa-flag = 'X'.
    loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa
      where flag = 'X'.
      g_TABLCTRL130_wa-flag = ''.
      modify g_TABLCTRL130_itab
        from g_TABLCTRL130_wa
        transporting flag.
    endloop.
    g_TABLCTRL130_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL130_itab
    from g_TABLCTRL130_wa
    index TABLCTRL130-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: process user command
module TABLCTRL130_user_command input.

  if check_pos = '1'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '5'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = descp5.
  endif.

*  OK_CODE = sy-ucomm.
*  perform user_ok_tc using    'TABLCTRL130'
*                              'G_TABLCTRL130_ITAB'
*                              'FLAG'
*                     changing OK_CODE.
*  sy-ucomm = OK_CODE.

endmodule.

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: modify table
module TABLCTRL140_modify input.
  move-corresponding ZMM_CDITEM to g_TABLCTRL140_wa.
*  modify g_TABLCTRL140_itab
*    from g_TABLCTRL140_wa
*    index TABLCTRL140-current_line.
************Addition********
*  if sy-subrc <> 0.
*    append g_TABLCTRL140_wa to g_TABLCTRL140_itab.
*  endif.
****************************
  if g_curfield = 'ZMM_CDITEM-DESC1' and sy-STEPL = g_curr_line.
    descp1 = g_TABLCTRL140_wa-desc1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.
    if g_TABLCTRL140_wa-desc1 <> 'OTHER'.
      perform TABLCTRL140_desc1_check.
    endif.
    if g_TABLCTRL140_wa-desc1 = 'OTHER'.
      g_TABLCTRL140_wa-OTH1 = 'X'.
      Perform popup_userdesc.
      g_TABLCTRL140_wa-user_desc = g_user_desc.
    elseif g_TABLCTRL140_wa-OTH1 = 'X'.
      descp1 = g_TABLCTRL140_wa-desc1.
    else.
      clear g_TABLCTRL140_wa-OTH1.
      descp1 = g_TABLCTRL140_wa-desc1.
    endif.
    check_pos = '1'.
  endif.

  if g_curfield = 'ZMM_CDITEM-USER_DESC' and sy-STEPL = g_curr_line.
    descp5 = g_TABLCTRL140_wa-user_desc.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    check_pos = '5'.
  endif.

  modify g_TABLCTRL140_itab
    from g_TABLCTRL140_wa
    index TABLCTRL140-current_line.
***********Addition********
  if sy-subrc <> 0.
    append g_TABLCTRL140_wa to g_TABLCTRL140_itab.
  endif.
***************************
  If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
    and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
    Perform get_srno.
  Endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: mark table
module TABLCTRL140_mark input.
  if TABLCTRL140-line_sel_mode = 1 and
     g_TABLCTRL140_wa-flag = 'X'.
    loop at g_TABLCTRL140_itab into g_TABLCTRL140_wa
      where flag = 'X'.
      g_TABLCTRL140_wa-flag = ''.
      modify g_TABLCTRL140_itab
        from g_TABLCTRL140_wa
        transporting flag.
    endloop.
    g_TABLCTRL140_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL140_itab
    from g_TABLCTRL140_wa
    index TABLCTRL140-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: process user command
module TABLCTRL140_user_command input.
  if check_pos = '1'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '5'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = descp5.
  endif.

  g_lineno = g_curr_line.

*  OK_CODE = sy-ucomm.
*  perform user_ok_tc using    'TABLCTRL140'
*                              'G_TABLCTRL140_ITAB'
*                              'FLAG'
*                     changing OK_CODE.
*  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: modify table
module TABLCTRL120_modify input.
  g_sh_partno = 'X'.
  move-corresponding ZMM_CDITEM to g_TABLCTRL120_wa.

*

  SELECT ATINN FROM CABN INTO G_ATINN UP TO 1 ROWS WHERE
 ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT ATWRT FROM AUSP INTO G_ATWRT UP TO 1 ROWS WHERE
 OBJEK = G_TABLCTRL120_WA-CAP_CODE AND ATINN = G_ATINN
 ORDER BY PRIMARY KEY .  "#EC CI_FLDEXT_OK[2215424]
 ENDSELECT.

  g_TABLCTRL120_wa-matgp = g_atwrt.

  clear g_atinn.

*
  if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
    g_matcode = ZMM_CDITEM-MATCODE.
    if not g_matcode is initial.
      set parameter id 'MAT' field g_matcode.
      call transaction 'MM03' and skip first screen.
    endif.
  endif.

*

  if g_curfield = 'ZMM_CDITEM-PARTNO' and sy-STEPL = g_curr_line.
    if g_partnoc <> g_TABLCTRL120_wa-partno.
      clear : g_TABLCTRL120_wa-desc1,
              g_TABLCTRL120_wa-oth1,
              g_TABLCTRL120_wa-user_desc.
*               g_TABLCTRL120_wa-desc3,
*               g_TABLCTRL120_wa-desc4,
*               g_TABLCTRL120_wa-oth2,
*               g_TABLCTRL120_wa-oth3,
*               g_TABLCTRL120_wa-oth4.
    endif.
    g_partnoc = g_TABLCTRL120_wa-partno.
    FIELD1 = 'ZMM_CDITEM-PARTNO'.
    if ( g_mode = 'CRE' or g_mode = 'CHA' ) .
*    and g_TABCTRL110_wa-oth1 = 'X'.
      clear : g_TABCTRL110_wa-desc1,
              descp1.
    endif.
    check_pos = '0'.
  endif.

  if g_curfield = 'ZMM_CDITEM-DESC1' and sy-STEPL = g_curr_line.
    descp1 = g_TABLCTRL120_wa-desc1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.

    if g_TABLCTRL120_wa-desc1 <> 'OTHER'.
      perform TABLCTRL120_desc1_check.
    endif.
    if g_TABLCTRL120_wa-desc1 = 'OTHER'.
      g_TABLCTRL120_wa-OTH1 = 'X'.
      Perform popup_userdesc.
      g_TABLCTRL120_wa-user_desc = g_user_desc.
    elseif g_TABLCTRL120_wa-OTH1 = 'X'.
      g_partnoc = g_TABLCTRL120_wa-partno.
    else.
      clear g_TABLCTRL120_wa-OTH1.
      g_partnoc = g_TABLCTRL120_wa-partno.
    endif.
    check_pos = '1'.
  endif.

  if g_curfield = 'ZMM_CDITEM-USER_DESC' and sy-STEPL = g_curr_line.
    descp5 = g_TABLCTRL120_wa-user_desc.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    check_pos = '5'.
  endif.

  modify g_TABLCTRL120_itab
    from g_TABLCTRL120_wa
    index TABLCTRL120-current_line.

**** Addition
  if sy-subrc <> 0.
    append g_TABLCTRL120_wa to g_TABLCTRL120_itab.
  endif.
****
  If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
      and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
    Perform get_srno.
  Endif.

endmodule.

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: mark table
module TABLCTRL120_mark input.
  if TABLCTRL120-line_sel_mode = 1 and
     g_TABLCTRL120_wa-flag = 'X'.
    loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa
      where flag = 'X'.
      g_TABLCTRL120_wa-flag = ''.
      modify g_TABLCTRL120_itab
        from g_TABLCTRL120_wa
        transporting flag.
    endloop.
    g_TABLCTRL120_wa-flag = 'X'.
  endif.
  modify g_TABLCTRL120_itab
    from g_TABLCTRL120_wa
    index TABLCTRL120-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: process user command
module TABLCTRL120_user_command input.

  if check_pos = '0'.

    desc11 = ''.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.
**Addition************************************************
    if FIELD1 = 'ZMM_CDITEM-PARTNO' AND
       sy-ucomm = 'DBLCLK' OR sy-ucomm = ''.
      g_curs_ln = g_curr_line_120.
      clear : g_sh_capeqt,g_sh_mdlno,g_sh_mfr,g_fst_srchlp.
      Refresh: ist_srchlp_cpo.
    endif.
**End of addition*****************************************

  endif.


  if check_pos = '1'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = ''.

  endif.

  if check_pos = '5'.

    desc11 = descp1.
    desc22 = ''.
    desc33 = ''.
    desc44 = ''.
    desc55 = descp5.
  endif.

  g_lineno = g_curr_line.

*  OK_CODE = sy-ucomm.
*  perform user_ok_tc using    'TABLCTRL120'
*                              'G_TABLCTRL120_ITAB'
*                              'FLAG'
*                     changing OK_CODE.
*  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_100 INPUT.
  Case okcode_100.
*    When 'EXT'.
*      perform clear_var.
*      leave program.
    When 'BAC' OR 'CAN'.
      perform bac_confirm.
      refresh ist_srchlp.
      refresh control 'TABCTRL100' from screen '0100'.
      clear okcode_100.
    when 'CR_MATCODE'.
      g_mode = 'CRC'.
      if not dynnr is initial.
        Perform create_matcode.
      endif.
      clear okcode_100.
    When 'CREATE'.
      g_mode = 'CRE'.
*      set parameter id 'ZDESC_2' field ''.
      clear okcode_100.
    When 'CHANGE'.
      g_mode = 'CHA'.
      clear okcode_100.
    When 'CHANGE_E'.
      g_mode = 'CHE'.
      Perform Save_request.
    When 'DISPLAY'.
      g_mode = 'DIS'.
      clear okcode_100.
    When 'DELETE'.
      g_mode = 'DEL'.
      clear okcode_100.
    when 'SAV'.
      If not zmm_cdhd_st-mtart is initial.
        perform check_items.
        if g_saveflag = 'Y' AND g_check_flag = ''.
          Perform Save_request.
        else.
          clear g_check_flag.
        endif.
      Endif.
      clear okcode_100.
    when 'RELEASE'.
      g_mode = 'REL'.
      clear okcode_100.
    when 'APPROVE'.
      g_mode = 'APR'.
      clear okcode_100.
    when 'DD'.
      Perform Display_text.
      clear okcode_100.
    when 'REMLT'.
      Call Screen 105 starting at 85 05 ending at 148 24.
      clear okcode_100.
    WHEN 'INS_MODI'.
      perform insert_modif.
      clear okcode_100.
    WHEN 'SPELL'.
*
      if ZMM_CDHD_ST-MTART = 'ZSTO'.
        perform spell_check1.
        Perform modi_check.
        clear okcode_100.
      Elseif ZMM_CDHD_ST-MTART = 'ZSPR'.
        perform spell_check2.
        clear okcode_100.
      Elseif ZMM_CDHD_ST-MTART = 'ZCAP'.
        perform spell_check3.
        clear okcode_100.
      Endif.
    WHEN 'INS_MDL'.
      perform insert_mdlno. "ZSPR
      clear okcode_100.
    WHEN 'REQLT'.
      perform ltxtdtsp.
      clear okcode_100.
    When 'MODNO' OR 'CAPEQT' OR 'MFR'.
*      g_curs_ln = g_curr_line_120.
      read table g_tablctrl120_itab into g_tablctrl120_wa
      index g_curs_ln.
      refresh ist_srchlp_cp.
      append lines of ist_srchlp_cpo to ist_srchlp_cp.
      perform srchlp_spr_del.
      clear okcode_100.
*      refresh control 'TABCTRL100' from screen '0100'.

*    when 'CHECK'.
*      Call Screen 102 starting at 10 05 ending at 140 15.
    When 'CPMC'.

* g_SRNO is being picked up thru Perform get_srno.
      read table ist_srchlp into wa_srchlp with key mark = 'X'.
      if sy-subrc = 0.
        Case zmm_cdhd_st-mtart.
          When 'ZSTO'.
            read table g_tabctrl110_itab into g_tabctrl110_wa
                                           with key SRNO = G_SRNO.
            If sy-subrc = 0.
              If g_tabctrl110_wa-comp_flg = ''.
               g_tabctrl110_wa-matcode = wa_srchlp-matnr.
*               g_tabctrl110_wa-flag = ''.
               g_tabctrl110_wa-comp_flg = 'A'.
               modify g_tabctrl110_itab from g_tabctrl110_wa
                     index sy-tabix transporting flag comp_flg matcode.
              Endif.
            Endif.
*               Perform cp_matcode.
          When 'ZSPR'.
            read table g_tablctrl120_itab into g_tablctrl120_wa
                                            with key SRNO = G_SRNO.
            If sy-subrc = 0.
              If g_tablctrl120_wa-comp_flg = ''.
               g_tablctrl120_wa-matcode = wa_srchlp-matnr.
*               g_tablctrl120_wa-flag = ''.
               g_tablctrl120_wa-COMP_FLG = 'A'.
               modify g_tablctrl120_itab from g_tablctrl120_wa
                     index sy-tabix transporting flag comp_flg matcode .
              Endif.
            Endif.

*            Perform cp_matcode.
          When 'ZCAP'.
            read table g_tablctrl130_itab into g_tablctrl130_wa
                                         with key SRNO = G_SRNO.
            If sy-subrc = 0.
              If g_tablctrl130_wa-comp_flg = ''.
               g_tablctrl130_wa-matcode = wa_srchlp-matnr.
*               g_tablctrl130_wa-flag = ''.
               g_tablctrl130_wa-comp_flg = 'A'.
               modify g_tablctrl130_itab from g_tablctrl130_wa
                     index sy-tabix transporting flag comp_flg matcode.
             Endif.
            Endif.

*            Perform cp_matcode.
        Endcase.
*        clear G_SRNO.
      Else.
        message i040(zmm_oth) with 'from Search Help'.
      Endif.
    When 'UNDO_CPMC'.
        Case zmm_cdhd_st-mtart.
          When 'ZSTO'.
            read table g_tabctrl110_itab into g_tabctrl110_wa
                                           with key FLAG = 'X'.
            If sy-subrc = 0 and g_tabctrl110_wa-comp_flg = 'A'.
               g_tabctrl110_wa-matcode = ''.
               g_tabctrl110_wa-flag = ''.
               g_tabctrl110_wa-comp_flg = ''.
               modify g_tabctrl110_itab from g_tabctrl110_wa
                     index sy-tabix transporting flag comp_flg matcode.
            Else.
               message i040(Zmm_oth).
            Endif.
*               Perform cp_matcode.
          When 'ZSPR'.
            read table g_tablctrl120_itab into g_tablctrl120_wa
                                            with key FLAG = 'X'.
              If sy-subrc = 0 and g_tablctrl120_wa-comp_flg = 'A'.
                g_tablctrl120_wa-matcode = ''.
                g_tablctrl120_wa-flag = ''.
                g_tablctrl120_wa-COMP_FLG = ''.
                modify g_tablctrl120_itab from g_tablctrl120_wa
                     index sy-tabix transporting flag comp_flg matcode .
              Else.
                message i040(Zmm_oth).
              Endif.

*            Perform cp_matcode.
          When 'ZCAP'.
            read table g_tablctrl130_itab into g_tablctrl130_wa
                                         with key FLAG = 'X'.
            If sy-subrc = 0 and g_tablctrl130_wa-comp_flg = 'A'.
               g_tablctrl130_wa-matcode  = ''.
               g_tablctrl130_wa-flag     = ''.
               g_tablctrl130_wa-comp_flg = ''.
               modify g_tablctrl130_itab from g_tablctrl130_wa
                     index sy-tabix transporting flag comp_flg matcode.
            Else.
               message i040(Zmm_oth).
            Endif.

*            Perform cp_matcode.
        Endcase.

Endcase.
*******Addition*********************************
OK_CODE = sy-ucomm.
check_code = sy-ucomm.

CASE zmm_cdhd_st-mtart.
  WHEN 'ZSTO'.
    perform user_ok_tc using    'TABCTRL110'
                                'G_TABCTRL110_ITAB'
                                'FLAG'
                       changing OK_CODE.
    clear: ok_code, sy-ucomm.
  WHEN 'ZSPR'.
    perform user_ok_tc using    'TABLCTRL120'
                                'G_TABLCTRL120_ITAB'
                                'FLAG'
                       changing OK_CODE.
    clear: ok_code,sy-ucomm.
  WHEN 'ZCAP'.
    perform user_ok_tc using    'TABLCTRL130'
                                'G_TABLCTRL130_ITAB'
                                'FLAG'
                       changing OK_CODE.
    clear: ok_code,sy-ucomm.
  WHEN 'ZDIS'.
    perform user_ok_tc using    'TABLCTRL140'
                                'G_TABLCTRL140_ITAB'
                                'FLAG'
                       changing OK_CODE.
    clear: ok_code,sy-ucomm.
ENDCASE.


ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor110 INPUT.
  clear TABCTRL110_check_flag.
*
  g_lineno_old = g_lineno.

  get cursor field g_curfield.

  get cursor field g_curfield110.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABCTRL110-top_line + g_cursor_line - 1.
  g_curr_line_110 = g_curr_line.

*  if g_lineno ne g_curr_line.
*     clear g_hits_par.
*  endif.

ENDMODULE.                 " get_cursor  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor120 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE get_cursor120 INPUT.

  get cursor field g_curfield.

  get cursor field g_curfield120.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL120-top_line + g_cursor_line - 1.
  g_curr_line_120 = g_curr_line .

ENDMODULE.                 " get_cursor120  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor130 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE get_cursor130 INPUT.

  get cursor field g_curfield.
  get cursor field g_curfield130.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL130-top_line + g_cursor_line - 1.
  g_curr_line_130 = g_curr_line.

ENDMODULE.                 " get_cursor130  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor140 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE get_cursor140 INPUT.

  get cursor field g_curfield.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABLCTRL140-top_line + g_cursor_line - 1.

ENDMODULE.                 " get_cursor140  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0115 INPUT.
  data : field_name(20).
  Data : l_ans.
*
  g_ok_code115 = sy-ucomm.
  Case g_ok_code115 .
    when  ''.
      Perform check_modi.
    when  'CANC' or 'RW'.
      clear : g_desc1,
              g_desc2,
              g_desc3,
              g_desc4,
              g_user_desc,
              g_screen115_1st.
      Perform reset_other.
      If g_ok_code110 <> 'PB_AD'.
        clear : g_user_desc.
      Endif.
      leave to screen 0.
    when  'A_DESC'.
      g_screen115_1st = 'X'.
*            Perform other_check.
    when 'OK115'.
      Perform check_modi.
      g_TABCTRL110_wa-USER_DESC = g_user_desc.
      clear ist_spell_line.

      If  g_TABCTRL110_wa-oth1  = 'X'.
        concatenate g_desc1 g_desc2
         g_desc3 g_desc4
         g_user_desc into ist_spell_line-tdline
         separated by space.
        g_tabctrl110_wa-COMP_FLG = ' M'.

      Elseif g_TABCTRL110_wa-oth2 = 'X'.
        concatenate g_desc2 g_desc3 g_desc4 g_user_desc into
        ist_spell_line-tdline separated by space.
        g_tabctrl110_wa-COMP_FLG = ' M'.

      Elseif g_TABCTRL110_wa-oth3 = 'X'.
        concatenate g_desc3 g_desc4 g_user_desc into
        ist_spell_line-tdline separated by space.
        g_tabctrl110_wa-COMP_FLG = ' M'.

      Elseif g_TABCTRL110_wa-oth4 = 'X'.
        concatenate g_desc4
        g_user_desc into ist_spell_line-tdline separated
        by space.
        g_tabctrl110_wa-COMP_FLG = ' M'.

      Else.
*+130705
        replace 'M' with '' into g_tabctrl110_wa-COMP_FLG.
*-130705
        ist_spell_line-tdline = g_user_desc.
      Endif.

      append ist_spell_line.

      EXPORT G_USER TO MEMORY ID 'G_USER1' .
      CALL FUNCTION 'ZSPELL_CHECK'
           EXPORTING
                SPRACHE = 'EN'
           TABLES
                ILINE   = ist_spell_line.

      IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB'.

      if not checktab[] is initial.
" Begin of <RD1K960036>.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*                   TEXTLINE1            = 'There are spelling errors in description(s)'
*           TEXTLINE2            = 'Proceed with errors? '
*            TITEL                = 'Spelling Errors'
**                  START_COLUMN         = 25
**                  START_ROW            = 6
**                  CANCEL_DISPLAY       = 'X'
*         IMPORTING
*           ANSWER               = l_ans.


      DATA : L_ANSWER(1) TYPE C.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
           TITLEBAR                    = 'Spelling Errors '
            TEXT_QUESTION               = 'There are spelling errors in description(s)'
                                          &'Proceed with errors? '
           DISPLAY_CANCEL_BUTTON       = 'X'
           START_COLUMN                = 25
           START_ROW                   = 6
         IMPORTING
           ANSWER                      = L_ANSWER
         EXCEPTIONS
           TEXT_NOT_FOUND              = 1
           OTHERS                      = 2
                  .
        IF SY-subrc = 0.

          CASE L_ANSWER.
            WHEN '1'.
              MOVE 'J' TO L_ANS.
              WHEN '2'.
                MOVE 'N' TO L_ANS.
                ENDCASE.

        ENDIF.
" End of <RD1K960036>.
        If l_ans = 'J'.
          clear : g_screen115_1st,user_desc_len.
          g_other = 'X'.
          If g_tabctrl110_wa-COMP_FLG+1(1) = 'M'.
            g_tabctrl110_wa-COMP_FLG = 'SM'.
          Else.
            g_tabctrl110_wa-COMP_FLG = 'S'.
          Endif.
*          g_tabctrl110_wa-rsn   = 'Spelling mistakes/Modifier not in
*                                   Attributes table'.
          leave to screen 0.
        Else.
          Loop at screen.
            if screen-name = 'G_DESC1' or
               screen-name = 'G_DESC2' or
               screen-name = 'G_DESC3' or
               screen-name = 'G_DESC4'.
              screen-input = 1.
              modify screen.
            Endif.
          Endloop.
        endif.
      Else.
        clear : g_screen115_1st,user_desc_len.
        g_other = 'X'.
        replace 'S' with '' into g_tabctrl110_wa-COMP_FLG.
*        if g_tabctrl110_wa-COMP_FLG+0(1) = 'S'. "remove spell error
*          g_tabctrl110_wa-COMP_FLG = ' M'.
**          g_tabctrl110_wa-rsn   = 'Modifier not in Attributes table'.
*        Endif.
        leave to screen 0.

      Endif.
  Endcase.



ENDMODULE.                 " USER_COMMAND_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  TAbctrl110_value  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAbctrl110_value INPUT.

  get parameter id 'ZMATGP' field g_matgp .
  move g_matgp to ZMM_CDITEM-MATGP.

ENDMODULE.                 " TAbctrl110_value  INPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN100_initialize  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN100_initialize INPUT.
  Perform check_delreq.
  clear g_hd_copied.
  clear g_TABCTRL110_copied.
***Addition ****************************************
****If reqno change from one mat type to another, to clear the
****Search help tablecontrol.
  refresh: ist_srchlp.
  refresh control 'TABCTRL100' from screen '0100'.
  clear: FIELD1.
***End *********************************************
ENDMODULE.                 " SCREEN100_initialize  INPUT

*&---------------------------------------------------------------------*
*&      Module  TEXT_CONTROL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CONTROL_UEBERNEHMEN INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       = LT_TEXT_TABLE
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE
            ITF_TEXT    = TLINETAB.

ENDMODULE.                 " TEXT_CONTROL_UEBERNEHMEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  Perform bac_confirm.
  leave program.
ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor100 INPUT.

  get cursor field g_curfield.

  get cursor line g_cursor_line.
  g_curr_line = g_cursor_line.
  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " get_cursor100  INPUT
*&      Module  SCREEN100_initialize1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN100_initialize1 INPUT.

  refresh ist_srchlp.
  refresh g_TABCTRL110_itab.
  clear g_tabctrl110_itab.
  clear zmm_cditem.
  clear g_mat_fnd.
  PERFORM clear_srchlp_parms.

ENDMODULE.                 " SCREEN100_initialize1  INPUT
*&---------------------------------------------------------------------*
*&      Module  longtext  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE longtext INPUT.
  Data: l_okdtsp like sy-ucomm.

  l_okdtsp = sy-ucomm.
  CASE l_okdtsp.
    WHEN 'REQLT'.
*
      perform ltxtdtsp.
      clear: l_okdtsp,sy-ucomm.
  ENDCASE.

ENDMODULE.                 " longtext  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       =  LT_TEXT_TABLE1
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE1
            ITF_TEXT    = TLINETAB1.

  CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       =  LT_TEXT_TABLE2
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE2
            ITF_TEXT    = TLINETAB2.


ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  TREE_CTRL_EMPFANGEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TREE_CTRL_EMPFANGEN INPUT.

ENDMODULE.                 " TREE_CTRL_EMPFANGEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  OTHER_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE OTHER_CHECK INPUT.
  Perform other_check.
ENDMODULE.                 " OTHER_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_check INPUT.

  TABCTRL110_check_flag = 'X'.
*g_check_flag          = 'X'.

ENDMODULE.                 " TABCTRL110_check  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
       IMPORTING
            TEXT       =  LT_TEXT_TABLE1
            IS_MODIFIED = GV_XTHEAD_UPDKZ
       EXCEPTIONS
            ERROR_DP               = 1
            ERROR_CNTL_CALL_METHOD = 2
            OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
       TABLES
            TEXT_STREAM = LT_TEXT_TABLE1
            ITF_TEXT    = TLINETAB1.
**
  IF ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) or ( g_mode = 'APR' ) OR
     ( g_mode = 'MRP' ) or sy-tcode = 'ZCODG'.

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
         IMPORTING
              TEXT       =  LT_TEXT_TABLE2
              IS_MODIFIED = GV_XTHEAD_UPDKZ
         EXCEPTIONS
              ERROR_DP               = 1
              ERROR_CNTL_CALL_METHOD = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              TEXT_STREAM = LT_TEXT_TABLE2
              ITF_TEXT    = TLINETAB2.
  ENDIF..
ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0105 INPUT.
  Data: okcode105 like sy-ucomm.

  okcode105 = sy-ucomm.

  Case okcode105.
    When 'OK'.
      clear okcode105.
    When 'CANCEL'.
      refresh tlinetab2[].
      clear okcode105.
  Endcase.
ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_MESSAGES INPUT.

  Leave to list-processing and return to screen 0.
  set pf-status space.
  loop at ist_message into wa_message.
    write: / wa_message-srno, wa_message-msgtype,wa_message-msgcode,
                  wa_message-msgtext.
  endloop.

ENDMODULE.                 " WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.

  refresh ist_message.

ENDMODULE.                 " USER_COMMAND_0102  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_check_desc2 INPUT.

  IF zmm_cditem-desc2 <> 'OTHER'.
   select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
                                              desc2 = zmm_cditem-desc2 .

    if sy-subrc <> 0.
      message e002(zmm_oth).
    endif.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc2  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_check_desc3 INPUT.

  IF zmm_cditem-desc3 <> 'OTHER'.
   select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
                                           desc2 = zmm_cditem-desc2 and
                                               desc3 = zmm_cditem-desc3.

    if sy-subrc <> 0.
      message e002(zmm_oth).
    endif.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc3  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_check_desc4 INPUT.

  IF zmm_cditem-desc4 <> 'OTHER'.
   select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
                                           desc2 = zmm_cditem-desc2 and
                                           desc3 = zmm_cditem-desc3 and
                                               desc4 = zmm_cditem-desc4.

    if sy-subrc <> 0.
      message e002(zmm_oth).
    endif.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc4  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_check_desc1 INPUT.
  Data l_cnt type i.

  IF zmm_cditem-desc1 <> 'OTHER'.
    select single * from zmm_modifier where desc1 = zmm_cditem-desc1.
    if sy-subrc <> 0.
      message e002(zmm_oth).
    else.
      Select count(*) into l_cnt from zmm_modifier
                      where desc1 = zmm_cditem-desc1.
      If l_cnt > 1.
        perform TABCTRL110_desc1_check.
      Endif.
    endif.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0103 INPUT.

ENDMODULE.                 " USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0150 INPUT.

  case sy-ucomm.

    when 'OK150'.

      leave to screen 0.

    when 'CAN150'.

      leave to screen 0.

  endcase.

ENDMODULE.                 " USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.
  Data : l_werks like t001w-werks.
  IF not zmm_cdhd_st-werks is initial.
    Select single werks into l_werks from t001w
           where werks = zmm_cdhd_st-werks.
    if sy-subrc <> 0.
      message e033(zmm_oth).
    endif.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_location  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_location INPUT.
  Data : l_locid like ZLOCMST-locid.
  IF not zmm_cdhd_st-reqloc is initial.
    Select single locid into l_locid from  zlocmst
           where locid = zmm_cdhd_st-reqloc.
    if sy-subrc <> 0.
      message e036(zmm_oth).
    endif.
  ENDIF.

ENDMODULE.                 " check_location  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_matgp_desc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_matgp_desc INPUT.
  select single WGBEZ from T023T into g_matgp_desc where MATKL =
  g_matgp and spras = sy-langu.
  if sy-subrc <> 0.
    g_matgp = ''.
  Endif.

ENDMODULE.                 " get_matgp_desc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_capcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_capcode INPUT.
  Data : l_capcode like mara-matnr.
  if not zmm_cditem-cap_code is initial.
    Select single matnr into l_capcode from mara
    where matnr = zmm_cditem-cap_code and
          mtart = 'ZCAP'.
    if sy-subrc <> 0.
      message e041(zmm_oth) with zmm_cditem-cap_code.
    Endif.
  Endif.

ENDMODULE.                 " check_capcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_modelno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_modelno INPUT.
  data: l_strlen type I, K type I.
  data: l_ans2,X.
  data : ist_sval_temp(30).

  refresh ist_mdl. clear ist_mdl.
  If zmm_cditem-mdlno <> 'OTHER'.
    Select single * from zmm_mdl into zmm_mdl
     where mdlno = zmm_cditem-mdlno.
    if sy-subrc <> 0.
      message e044(zmm_oth).
      move ' L' to zmm_cditem-comp_flg.
    else.
      replace 'L' with  '' into zmm_cditem-comp_flg.
      move '' to zmm_cditem-oth_mdl.
    endif.
  Else.
    refresh ist_sval.
    clear   ist_sval.
    clear   ist_sval_temp.

    move : 'ZMM_CDITEM'  to ist_sval-TABNAME,
           'MDLNO'       to ist_sval-FIELDNAME,
           'X'           to ist_sval-FIELD_OBL.
    append ist_sval.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*   NO_VALUE_CHECK        = ' '
        POPUP_TITLE           = 'Enter Model No.'
        START_COLUMN          = '5'
        START_ROW             = '5'
      TABLES
        FIELDS                = ist_sval
* EXCEPTIONS
*   ERROR_IN_FIELDS       = 1
*   OTHERS                = 2
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    read table ist_sval index 1.
    zmm_mdl-mdlno = IST_SVAL-value.  "#EC CI_FLDEXT_OK[2215424]
    If not IST_SVAL-value is initial.
*      read table ist_sval index 1.
      l_strlen = strlen( ist_sval-value ).
      IST_SVAL_org = ist_sval-value.

      Translate  ist_sval-value using
'.%-%,%+%*%_%^%?%"%!% %$%:%;%`%"%/%\%<%>%=%§%#%~%(%)%|%<%>%@%{%}%[%]%~%'
.
      ist_sval-value = ist_sval-value+0(l_strlen).
      l_strlen = l_strlen + 1.
      K = 0.
      do l_strlen times.
        X =  ist_sval-value+K(1).
        if X <> '%'.
          concatenate ist_sval_temp '%' X into ist_sval_temp.
          condense ist_sval_temp no-gaps.
        Endif.
        K = K + 1 .
        X = ''.
      Enddo.
      ist_sval-value = ist_sval_temp.
      select * from zmm_mdl into table ist_mdl where mdlno like
      ist_sval-value ORDER BY PRIMARY KEY.
      if sy-subrc <> 0.
        zmm_cditem-mdlno = zmm_mdl-mdlno.
        zmm_cditem-oth_mdl = 'X'.
        IF zmm_cditem-comp_flg+0(1) ='S'.
          zmm_cditem-comp_flg = 'SL'.
        Else.
          zmm_cditem-comp_flg = ' L'.
        Endif.

      Else.

        Translate ist_sval-value using '% '.
        condense ist_sval-value no-gaps.

        Loop at ist_mdl.
          Translate  ist_mdl-mdlno using
 '. - , + * _ ^ ? " ! $ : ; ` " / \ < > = § # ~ ( ) | < > @ { } [ ] ~ '.
          condense ist_mdl-mdlno no-gaps.
          If ist_mdl-mdlno <> ist_sval-value.
            delete ist_mdl index sy-tabix.
          Endif.
        Endloop.
        CALL SCREEN 104 STARTING AT 40 2
                        ENDING   AT 80 18.
        If zmm_Cditem-mdlno = 'OTHER'.
          zmm_cditem-mdlno = ''.
        Endif.
      Endif.
    Else.
      zmm_cditem-mdlno = ''.

    Endif.
  Endif.
ENDMODULE.                 " check_modelno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matgp  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matgp INPUT.
* Check only stores group is selected
  if g_tabctrl110_wa-desc1 = 'OTHER' or g_tabctrl110_wa-oth1 = 'X'.
    if g_matgp > '16' or g_matgp < '07'.
      message e049(zmm_oth).
    Endif.
  Endif.

ENDMODULE.                 " check_matgp  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_other INPUT.
*
  if zmm_cditem-oth1 = 'X' or
     zmm_cditem-oth2 = 'X' or
     zmm_cditem-oth3 = 'X' or
     zmm_cditem-oth4 = 'X'.

  Else.
    replace 'M' with '' into zmm_cditem-comp_flg.
  Endif.
ENDMODULE.                 " check_other  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_fld  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_fld INPUT.
*
  get cursor field g_cursor_fld130.
  if zmm_cditem-desc_fin is initial.
    message i007(zmm_oth).
    set cursor field 'ZMM_CDITEM-DESC_FIN'.
  Endif.

ENDMODULE.                 " get_cursor_fld  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_MATCATG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Check_characterstics_MATCATG INPUT.
*
  Data : l_atwrt like cawn-atwrt.
*  Check g_cursor_fld130 <> 'ZMM_CDITEM-DESC_FIN'.
  select single atwrt from zmmcdcap_usrgp_v into l_atwrt where atwrt =
    ZMM_CDITEM-MATCATG.
  If sy-subrc <> 0.
    message e051(zmm_oth).
  Endif.

ENDMODULE.                 " Check_characterstics_MATCATG  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_MATLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Check_characterstics_MATLOC INPUT.
*
*  Check g_cursor_fld130 <> 'ZMM_CDITEM-DESC_FIN'.

  select single atwrt from zmmcdcap_loc_v into l_atwrt where atwrt =
    ZMM_CDITEM-MATLOC.
  If sy-subrc <> 0.
    message e051(zmm_oth).
  Endif.

ENDMODULE.                 " Check_characterstics_MATLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_SPAGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Check_characterstics_SPAGRP INPUT.
  select single atwrt from zmmcdcap_sprgp_v into l_atwrt where atwrt =
    ZMM_CDITEM-SPA_GRP.  "#EC CI_FLDEXT_OK[2215424]
  If sy-subrc <> 0.
    message e051(zmm_oth).
  Endif.

ENDMODULE.                 " Check_characterstics_SPAGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_WRKNG_LIFE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Check_WRKNG_LIFE INPUT.

If ZMM_CDITEM-WRKNG_LIFE CA '.-,#~`!@#$%^&*()<>/:;"'''.
   message e058(zmm_oth).
Endif.
ENDMODULE.                 " Check_WRKNG_LIFE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.
data : tel_len type i.
tel_len = strlen( ZMM_CDHD_ST-TEL ).
  if  ZMM_CDHD_ST-TEL CO '0123456789'.
      message e059(zmm_oth).
  Else.
     if tel_len < 4.
       message e060(zmm_oth).
     Endif.
  Endif.
ENDMODULE.                 " CHECK_TEL  INPUT
