*--- MAIN PROGRAM: MZMMPREPROLE3O01 ---*

*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  Perform fill_sttab.

  if old_ok_code = 'CREATE' or old_ok_code = 'CHANGE' or
      old_ok_code = 'DISPLAY' or old_ok_code = 'DELETE' or
      sy-tcode = 'ZMM_AUTH_CORETEAM'.

    SET PF-STATUS 'OPTNS1' excluding it_tab.

  else.

    SET PF-STATUS 'OPTNS'.

  endif.

  case sy-ucomm.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' with ': Change Request'.
    when 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' with ': Display Request'.
    when 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' with ': Delete Request'.
    when 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' with ': Release Request'.
    when 'APPROVE'.
      SET TITLEBAR 'PREP_TITLE' with ': Approve Request'.

    when others.
      SET TITLEBAR 'PREP_TITLE' with ''.
  endcase.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.

  if not zmm_prep_rolereq-docno is initial.

    data : l_docno like zmm_prep_rolereq-docno.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = zmm_prep_rolereq-docno
         IMPORTING
              OUTPUT = l_docno.

    zmm_prep_rolereq-docno = l_docno.

  endif.

  if  g_hd_copied <> 'X'.
*
    if old_ok_code is initial and okcode_100 is initial.

    else.

      if old_ok_code = 'CREATE' and okcode_100 is initial.

      else.

        if ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
            or ( old_ok_code = 'RELEASE' )
            or ( OLD_OK_CODE = 'APPROVE' ).
          if not zmm_prep_rolereq-docno is initial and g_lock <> 'Y'.
            perform lock_reqhd.
          endif.
        endif.

        if sy-subrc = 0 and not zmm_prep_rolereq-docno is initial.

          g_hd_copied = 'X'.

          select * from ZMM_PREP_ROLEREI into corresponding
                   fields of table g_TABCTRL100_itab
                   where DOCNO = ZMM_PREP_ROLEREQ-docno and
                   ( ( role_name like 'M%' ) or ( role_name like 'C%' )
).
        endif.

        if not ZMM_PREP_ROLEREQ-docno is initial.

          select single * from ZMM_PREP_ROLEREQ
                     where DOCNO = ZMM_PREP_ROLEREQ-docno.

          if sy-subrc = 0 .

            perform validations.

          endif.

        endif.

      endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.

      ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

    endif.

  endif.

  perform get_correspondense.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

*  if l_old_ok_code = 'X' and g_reset_change <> 'X'.
*    perform auth_check.
*  else.
*    clear g_reset_change.
*  endif.

  CASE old_ok_code.

    when ''.

      loop at screen.
        screen-input = 0.
        modify screen.
      endloop.

    when 'CREATE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-required = 0.
          modify screen.
        endif.


      endloop.

    when 'CHANGE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group3 = 'GPC' .
          if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
            screen-active = 1.
          else.
            screen-active = 0.
          endif.
          screen-invisible = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-NAME1' ).
          screen-input = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL <> 'X'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
          if not ZMM_PREP_ROLEREQ-FUNDC is initial.
            screen-input = 1.
            screen-required = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

      endloop.

    when 'RELEASE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'APPROVE'.

      loop at screen.

        if screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          modify screen.
        endif.

        if screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'TABCTRL100_DELETE'.
          screen-input = 0.
          modify screen.
        endif.

      if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
   .
          screen-input = 1.
          modify screen.
        endif.
        if ( g_user = 'IM' or g_user = 'L3' ) and
            screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
          screen-input = 1.
          modify screen.
        endif.

      endloop.

    when 'DISPLAY'.

      loop at screen.

       if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
                                                  or screen-name = 'M'
                                 or screen-name = 'TABCTRL100_PREVIOUS'
                                    or screen-name = 'TABCTRL100_NEXT'.
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

        if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
           screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREQ-USERID' or
          screen-name = 'ZMM_PREP_ROLEREQ-RSN_CODE' or
          screen-name = 'ZMM_PREP_ROLEREQ-TELNO' .
          screen-input = 0.
          modify screen.
        endif.

      endloop.

    when 'DELETE'.

      loop at screen.

      if screen-name = 'ZMM_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
                                                or screen-name = 'STAT'
   .
          screen-input = 1.
          screen-required = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.

        if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN' ) and ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          screen-active = 0.
          screen-invisible = 1.
          modify screen.
        endif.

      endloop.


  ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform check_list_processing.

  perform get_user.

  PERFORM upload1_file.

  if g_hd_copied is initial.
*&spwizard: copy ddic-table 'ZMM_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABCTRL100_itab'
*    select * from ZMM_PREP_ROLEREI
*       into corresponding fields
*       of table g_TABCTRL100_itab.
*    g_TABCTRL100_copied = 'X'.
    data : l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    refresh control 'TABCTRL100' from screen '0100'.
  endif.

  GET PARAMETER ID 'ZOLDCODE' field l_old_ok_code.

  if l_old_ok_code = 'X'.
    GET PARAMETER ID 'ZREQNO' field ZMM_PREP_ROLEREQ-DOCNO.
    old_ok_code = 'CHANGE'.
  endif.

endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
module TABCTRL100_move output.
  move-corresponding g_TABCTRL100_wa to ZMM_PREP_ROLEREI.
  if not ZMM_PREP_ROLEREI-role_name is initial.
    ZMM_PREP_ROLEREI-DOCNO = ZMM_PREP_ROLEREQ-DOCNO.
    if old_ok_code = 'CRCROLES' or zmm_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        move zmm_prep_rolecrc-brief_desc to role_desc.
      endif.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZMM_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0.
        move zmm_prep_crcdesg-CRC_POS to CRC_POS.
      endif.
     else.
      select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.
  endif.
*  move g_TABCTRL100_wa-role_desc to role_desc.
endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABCTRL100_get_lines output.
  g_TABCTRL100_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  value_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*  MOVE 'REQ1' to WA_TAB.
*  APPEND WA_TAB to TAB.
  SET PF-STATUS 'STATUS_120' excluding TAB.
  clear : WA_TAB.
  refresh : TAB.
  WRITE :'Current Roles of User:', ZMM_PREP_ROLEREQ-USERID
  COLOR COL_HEADING.
  ULINE.
  if flag_s_fundc = 'X' and okcode_100 <> 'SUIM'.
    PERFORM HELP_LIST.
  endif.

  if okcode_100 = 'SUIM'.
    perform help_suim.
  endif.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.
  perform hide.
  SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_attrib OUTPUT.

  if old_ok_code = 'DISPLAY'.

   loop at screen.

      screen-input = 0.
      modify screen.

    endloop.

  endif.

  if old_ok_code <> 'DISPLAY' .

    select single * from zmm_prep_roledes where role_type =
                                              g_TABCTRL100_wa-role_name.

    if sy-subrc = 0.

      loop at screen.

        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

*          if old_ok_code <> 'APPROVE'.
*            screen-input = 1.
*          else.
            screen-input = 0.
*          endif.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if sy-tcode = 'ZMM_AUTH_CORETEAM' and
              screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
              old_ok_code = 'CHANGE' and ZMM_PREP_ROLEREI-REJ_FL = ''.
          screen-input = 1.
          modify screen.
        endif.

        if sy-tcode = 'ZMM_AUTH_CORETEAM' and
              screen-name = 'ZMM_PREP_ROLEREI-STATUS'
              and ZMM_PREP_ROLEREQ-CRC_FL = 'X'
              and ZMM_PREP_ROLEREI-role_request = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-STATUS' and
           ZMM_PREP_ROLEREI-role_request <> ''.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
           ZMM_PREP_ROLEREI-role_request <> ''.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .

*          if zmm_prep_roledes-plant = 'X' and
*                        old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP'.

*          if zmm_prep_roledes-P_GRP = 'X' and
*                        old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

*          if zmm_prep_roledes-APP_LEVEL = 'X' and
*                      old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

*          if zmm_prep_roledes-S_LOC = 'X' and
*                    old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

*          if zmm_prep_roledes-R_LOC = 'X' and
*                    old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.

      endloop.

    else.

**      loop at screen.
**
**        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
**                          not old_ok_code is initial .
**          screen-input = 1.
**          modify screen.
**        else.
**          screen-input = 0.
**          modify screen.
**        endif.

**      endloop.

      if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

        SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        if sy-subrc = 0.

          loop at screen.

            if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

*              if old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*              else.
                screen-input = 0.
*              endif.
              modify screen.
            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL'
              and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
              screen-input = 1.
              modify screen.
            endif.


            if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .


*              if zmm_prep_rolecrc-plant = 'X' and
*                                   old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-GRP' .


*              if zmm_prep_rolecrc-P_GRP = 'X' and
*                                   old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

      if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

*          if zmm_prep_roledes-APP_LEVEL = 'X' and
*                      old_ok_code <> 'APPROVE'.
*            .
*            screen-input = 1.
*            modify screen.
*          else.
            screen-input = 0.
            modify screen.
*          endif.

        endif.



            if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

*              if zmm_prep_rolecrc-S_LOC = 'X' and
*                        old_ok_code <> 'APPROVE'.
*                .
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.
            endif.

            if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

*              if zmm_prep_rolecrc-R_LOC = 'X' and
*                        old_ok_code <> 'APPROVE'.
*                .
*                screen-input = 1.
*                modify screen.
*              else.
                screen-input = 0.
                modify screen.
*              endif.

            endif.

          endloop.

        else.

          loop at screen.

            if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
                               not old_ok_code is initial.
              screen-input = 1.
              modify screen.

              if not ZMM_PREP_ROLEREI-ROLE_NAME is initial.
                message i116(zhelp) with ZMM_PREP_ROLEREI-ROLE_NAME.
              endif.
            else.
              screen-input = 0.
              modify screen.
            endif.

          endloop.

        endif.

      endif.
**
    endif.

  else.
    loop at screen.

      screen-input = 0.
      modify screen.

    endloop.
*

  endif.
ENDMODULE.                 " TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZE OUTPUT.

  perform get_correspondense.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.

  if gv_splitter1 is initial.
    create object gv_custom_container
                  exporting container_name = 'C_DIS'.

    create object gv_splitter1
           exporting
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  endif.

  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' ).

    if gv_splitter2 is initial.

      create object gv_custom_container
                    exporting container_name = 'C_WRT'.


      create object gv_splitter2
             exporting
                    parent = gv_custom_container
                    orientation = 1
                    sash_position = 1.

    endif.
  endif.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.

  if gv_text_editor1 is initial.
    create object gv_text_editor1
       exporting
            parent = gv_splitter1->bottom_right_container
            wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>false
       exceptions
            error_cntl_create      = 1
            error_cntl_init        = 2
            error_cntl_link        = 3
            error_dp_create        = 4
            gui_type_not_supported = 5.
    flag1 = 'X'.
  endif.
  if ( old_ok_code = 'CREATE' ) or ( old_ok_code = 'CHANGE' )
      or ( old_ok_code = 'RELEASE' )
      or ( OLD_OK_CODE = 'APPROVE' ).

    if gv_text_editor2 is initial.
      create object gv_text_editor2
         exporting
              parent = gv_splitter2->bottom_right_container
              wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
              wordwrap_to_linebreak_mode = cl_gui_textedit=>false
         exceptions
              error_cntl_create      = 1
              error_cntl_init        = 2
              error_cntl_link        = 3
              error_dp_create        = 4
              gui_type_not_supported = 5.
      flag2 = 'X'.
    endif.
  endif.

  perform text_control_eingabebereit1.
  perform text_control_set_text_table1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_col_attrib OUTPUT.

  LOOP AT TABCTRL100-cols INTO cols WHERE index GT 11.
    cols-invisible = '1'.
    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT TABCTRL100-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
  ENDLOOP.


ENDMODULE.                 " scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup OUTPUT.

  if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

    sort g_TABCTRL100_itab
    by role_name plant grp sloc receipt_loc approver.

    delete adjacent duplicates from g_TABCTRL100_itab
    comparing role_name plant grp receipt_loc sloc approver.

  endif.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.
  describe table g_tabctrl100_itab lines tabctrl100-lines.
  if not g_field is initial.
    set cursor field g_field line g_i.
    clear g_field.
  endif.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

  if l_old_ok_code = 'X' and g_reset_change <> 'X'.
    perform auth_check.
  else.
    clear g_reset_change.
  endif.

  if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    g_text = ' : Cross Company'.
  endif.
  if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC'.
  endif.

  if ZMM_PREP_ROLEREQ-STATUS = 'C' or
     ZMM_PREP_ROLEREQ-STATUS = 'IC' or
     zmm_prep_rolereq-status = 'IR'..
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.

    set pf-status 'OPTNS1' excluding it_tab..
  endif.

  if old_ok_code = 'DISPLAY'.
    move 'ROLE_DEL' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'ROLE_CR' to wa_tab-fcode.
    append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS1' excluding it_tab.
  endif.


  SET TITLEBAR 'PREP_TITLE' with g_text.

ENDMODULE.                 " set_title  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_0100_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_0100_AUTH OUTPUT.
  select single * from zmm_prep_usrcont where
             bname = sy-uname.
  if sy-subrc <> 0.
    message i104(zhelp).
    old_ok_code = 'DISPLAY'.
  endif.

ENDMODULE.                 " CHECK_0100_AUTH  OUTPUT
