*--- MAIN PROGRAM: MZMMPREPROLE1O01 ---*
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

  SET PF-STATUS 'OPTNS' excluding it_tab.

 case old_ok_code.
    when 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' with ': Create Request'.
    when 'CROSSCO'.
      SET TITLEBAR 'PREP_TITLE' with
      ': Cross Company '.
    when 'CRCROLES'.
      SET TITLEBAR 'PREP_TITLE' with ': CRC '.
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

  l_docno = zmm_prep_rolereq-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

  zmm_prep_rolereq-docno = l_docno.

endif.

if  g_hd_copied <> 'X'.
*
if old_ok_code is initial and okcode_100 is initial.

   else.

   if ( old_ok_code = 'CREATE' or old_ok_code = 'CROSSCO' ) and
                                    okcode_100 is initial.

    else.

      if ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
          or ( old_ok_code = 'RELEASE' )
          or ( OLD_OK_CODE = 'APPROVE' ).
        if not zmm_prep_rolereq-docno is initial.
          perform lock_reqhd.
        endif.
      endif.

      if sy-subrc = 0 and not zmm_prep_rolereq-docno is initial.

*        g_hd_copied = 'X'.

        clear g_TABCTRL100_itab.
        refresh g_TABCTRL100_itab.

        select * from ZMM_PREP_ROLEREI into corresponding
                  fields of table g_TABCTRL100_itab
                    where DOCNO = ZMM_PREP_ROLEREQ-docno.

**************************
       clear g_srno.
**************************

      endif.

      if not ZMM_PREP_ROLEREQ-docno is initial.

        select single * from ZMM_PREP_ROLEREQ
                   where DOCNO = ZMM_PREP_ROLEREQ-docno.

        if sy-subrc = 0 .

            g_hd_copied = 'X'.

            if ZMM_PREP_ROLEREQ-comm_fl = 'X' and old_ok_code = 'CHANGE'
.
*                  perform verify1.
                  perform verify2.
            endif.

            perform validations.

        else.
           message i101(zhelp) with ZMM_PREP_ROLEREQ-docno.
        endif.

       endif.

      endif.

*      select single * from ZMM_PREP_RSN
*                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.
*
*      if sy-subrc = 0.
*
*          ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.
*
*      endif.

       select single * from T500P
                 where PERSA = ZMM_PREP_ROLEREQ-PERSA.

      if sy-subrc = 0.

          ZMM_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      endif.


   endif.

endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZMM_PREP_ROLEREQ-RSN_CODE.

      if sy-subrc = 0.

          ZMM_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

      endif.

    if ZMM_PREP_ROLEREQ-fundc <> '' and ZMM_PREP_ROLEREQ-REASON1 = ''.

       set cursor field 'ZMM_PREP_ROLEREQ-REASON1'.
        message i100(zhelp).
    endif.

    perform get_correspondense.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
*             perform pop_up_message.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
            screen-input = 0.
            modify screen.
       endif.

       if ( screen-name = 'ZMM_PREP_ROLEREQ-FUNDC' ) and
                   g_error_fundc = 'X'.
            screen-input = 1.
            clear g_error_fundc.
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

       if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
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

       if screen-name = 'TABCTRL100_DELETE' or
           screen-name = 'TABCTRL100_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
       endif.

       if g_user = 'L1' and screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP1_FL'
.
              screen-input = 1.
              modify screen.
       endif.

       if ( g_user = 'IM' ) and
           screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP0_FL'.
              screen-input = 1.
              modify screen.
       endif.
       if ( g_user = 'L3' ) and
           screen-name = 'ZMM_PREP_ROLEREQ-REQ_APP_FL'.
              screen-input = 1.
              modify screen.
       endif.

       if screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZMM_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.

       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-FUNDC' or
          screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
          screen-input = 0.
          modify screen.
       endif.

    endloop.

    when 'CROSSCO'.

     loop at screen.

       if screen-group1 = 'GP1' or
           screen-group4 = 'GP4'.
           screen-input = 1.
           if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-required = 0.
           else.
              screen-required = 1.
           endif.
           modify screen.
       endif.

       if screen-group2 = 'GP2'.
            screen-required = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

        if screen-group3 = 'GPC' .
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-CCODE' and
          not ZMM_PREP_ROLEREQ-CCODE is initial .
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZMM_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN'.
           screen-active = 0.
           screen-invisible = 1.
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

        if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

    endloop.

    when 'CRCROLES'.

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

       if ( screen-name = 'ZMM_PREP_ROLEREQ-PERSA' ).
           if ZMM_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZMM_PREP_ROLEREQ-PERSA, ZMM_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.


          if ( screen-name = 'ZMM_PREP_ROLEREQ-FR_DATE_AUTH' or
                screen-name = 'ZMM_PREP_ROLEREQ-TO_DATE_AUTH' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 0.
          else.
            if ( screen-name = 'ZMM_PREP_ROLEREQ-OFF_ORDER_NO' or
                screen-name = 'ZMM_PREP_ROLEREQ-OFF_ORDER_DATE' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 1.
            endif.

           endif.

           if ( screen-name = 'OONO' or screen-name = 'DT1'  or
                screen-name = 'DT2' or screen-name = 'DT3' ).
                screen-invisible = 0.
                screen-active = 1.
           endif.

            modify screen.

          if screen-name = 'ZMM_PREP_ROLEREQ-REASON1'.
         if not ZMM_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.
*added on 26/12/2006
        if screen-name = 'ZMM_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 1.
              modify screen.
        endif.

    endloop.

ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform get_user.

*  describe table g_TABCTRL100_itab lines TABCTRL100-lines.

*  if g_TABCTRL100_copied is initial.
   if g_hd_copied is initial.
*&spwizard: copy ddic-table 'ZMM_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABCTRL100_itab'
*    select * from ZMM_PREP_ROLEREI
*       into corresponding fields
*       of table g_TABCTRL100_itab.
*    g_TABCTRL100_copied = 'X'.
    refresh control 'TABCTRL100' from screen '0100'.
    data l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    set parameter id 'BUK' field l_fis_initial.
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
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
     SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZMM_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZMM_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_crcdesg-crc_pos to crc_pos.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZMM_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.

  endif.
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
  WRITE :'Selected Values for Company Code :',ZMM_PREP_ROLEREQ-CCODE
          COLOR COL_HEADING.
  ULINE.
  if flag_s_fundc = 'X'.
    PERFORM HELP_LIST.
  endif.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.
   SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

  if old_ok_code <> 'CRCROLES'.
      if old_ok_code = 'CREATE'.
      elseif ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
         CRC_CHECK_FL = 'X'.
      endif.
  else.
      CRC_CHECK_FL = 'X'.
  endif.

   if CRC_CHECK_FL <> 'X' .

      clear CRC_CHECK_FL.

    select single * from zmm_prep_roledes where role_type =
                                              g_TABCTRL100_wa-role_name.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

                if zmm_prep_roledes-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_roledes-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

       endloop.

    else.

       loop at screen.

         if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZMM_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZMM_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZMM_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
       endif.

        if screen-name = 'ZMM_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZMM_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-required = 1.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-required = 1.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZMM_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.                   screen-required = 1.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.                   screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'CRC_POS' and
              ( ZMM_PREP_ROLEREI-role_name <> 'M3B' and
                ZMM_PREP_ROLEREI-role_name <> 'M11S' and
                ZMM_PREP_ROLEREI-role_name <> 'M11M' ).
                if old_ok_code <> 'APPROVE'.
                    screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and
               ( ZMM_PREP_ROLEREI-role_name = 'M3B' or
                ZMM_PREP_ROLEREI-role_name = 'M11S' or
                ZMM_PREP_ROLEREI-role_name = 'M11M' ).
.          screen-input = 1.
        elseif screen-name = 'ZMM_PREP_ROLEREI-APPROVER' and
               ( ZMM_PREP_ROLEREI-role_name <> 'M3B' and
                ZMM_PREP_ROLEREI-role_name <> 'M11S' and
                ZMM_PREP_ROLEREI-role_name <> 'M11M' ).
           screen-input = 0.
        endif.

        modify screen.
*

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

endif.

else.

         loop at screen.

              screen-input = 0.
              modify screen.
*
         endloop.
*

endif.

loop at screen.

if ZMM_PREP_ROLEREI-REJ_FL <> ''.
   screen-input = 0.
   modify screen.
endif.

endloop.


**************************************************************
if old_ok_code = 'DELETE'.

    loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

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

  if ( old_ok_code = 'CREATE' )
  or ( old_ok_code = 'CROSSCO' )
  or ( old_ok_code = 'CRCROLES' )
  or ( old_ok_code = 'CHANGE' )
  or ( old_ok_code = 'RELEASE' )
  or ( OLD_OK_CODE = 'APPROVE' )
  or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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
  if ( old_ok_code = 'CREATE' )
      or ( old_ok_code = 'CROSSCO' )
      or ( old_ok_code = 'CRCROLES' )
      or ( old_ok_code = 'CHANGE' )
      or ( old_ok_code = 'RELEASE' )
      or ( OLD_OK_CODE = 'APPROVE' )
       or ( old_ok_code = 'DISPLAY' and zmm_prep_rolereq-comm_fl = 'X' )
  .

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

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

if not g_TABCTRL100_itab[] is initial .

  sort g_TABCTRL100_itab
  by role_name plant grp sloc receipt_loc approver.
  delete adjacent duplicates from g_TABCTRL100_itab
  comparing role_name plant grp sloc receipt_loc approver role_type_ex
  crc_pos.

endif.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZMM_PREP_ROLEREI-ROLE_NAME' line g_curr_line.
endif.
clear sy-ucomm.
ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

if ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
   g_text = ' : Cross Company Authorisation'.
   SET TITLEBAR 'PREP_TITLE' with g_text.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.
if old_ok_code = 'CREATE' and ( okcode_100 = '' or
    okcode_100 = 'CREATE' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    move 'LIST' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.
if old_ok_code = 'CHANGE' and ( okcode_100 = '' or
    okcode_100 = 'CHANGE' or okcode_100 = 'LIST' ) .
    if ZMM_PREP_ROLEREQ-CRC_FL = 'X' or
       ZMM_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    else.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    endif.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DELETE' and ( okcode_100 = '' or
    okcode_100 = 'DELETE' or okcode_100 = 'LIST') .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DISPLAY'
   and zmm_prep_rolereq-comm_fl = 'X'.
   SET PF-STATUS 'OPTNS' excluding it_tab.
else.

  if old_ok_code = 'DISPLAY' and ( okcode_100 = '' or
      okcode_100 = 'DISPLAY' or okcode_100 = 'LIST') .
      move 'ATTACH' to wa_tab-fcode.
      append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS' excluding it_tab.
  endif.

endif.

if old_ok_code = 'APPROVE' and ( okcode_100 = '' or
    okcode_100 = 'APPROVE' or okcode_100 = 'LIST') .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if ZMM_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC Authorisation'.
    SET TITLEBAR 'PREP_TITLE' with g_text.
endif.

ENDMODULE.                 " set_title  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ICE_ARMS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ICE_ARMS OUTPUT.

if sy-tcode = 'ZMM_ARMS'.

CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
  EXPORTING
   TITEL              = 'ZMM_ARMS Transaction'
   TEXTLINE1          = 'This transaction has been discontinued'
   TEXTLINE2          = 'Please use ZICE_ARMS in place of ZMM_ARMS'
*   START_COLUMN       = 25
*   START_ROW          = 6
          .
endif.
LEAVE PROGRAM.
ENDMODULE.                 " ICE_ARMS  OUTPUT
