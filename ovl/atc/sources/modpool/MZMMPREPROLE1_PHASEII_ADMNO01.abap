*--- MAIN PROGRAM: MZMMPREPROLE1_PHASEII_ADMNO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 345.
************************************************************************
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
*      SET PF-STATUS 'OPTNSX' excluding it_tab.
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

if not ZIC_PREP_ROLEREQ-docno is initial.

  data : l_docno like ZIC_PREP_ROLEREQ-docno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              INPUT  = l_docno
         IMPORTING
              OUTPUT = l_docno.

  ZIC_PREP_ROLEREQ-docno = l_docno.

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
        if not ZIC_PREP_ROLEREQ-docno is initial.
          perform lock_reqhd.
        endif.
      endif.

**      if sy-subrc = 0 and not ZIC_PREP_ROLEREQ-docno is initial.

*        g_hd_copied = 'X'.

**        clear g_TABCTRL100_itab.
**        refresh g_TABCTRL100_itab.

**        select * from ZIC_PREP_ROLEREI into corresponding
**                  fields of table g_TABCTRL100_itab
**                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

**************************
**       clear g_srno.
**************************

**      endif.

      if not ZIC_PREP_ROLEREQ-docno is initial.

        select single * from ZIC_PREP_ROLEREQ
                   where DOCNO = ZIC_PREP_ROLEREQ-docno.

        if sy-subrc = 0 .

            if g_l4 = 'X' and old_ok_code = 'APPROVE'.
               ZIC_PREP_ROLEREQ-RADIO_FL = 'X'.
            endif.

*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

           select distinct moduleid from zic_prep_rolerei into
           corresponding fields of table it_module1 where DOCNO =
           ZIC_PREP_ROLEREQ-DOCNO.
****
           SORT IT_MODULE1 BY MODULEID. read table it_module1 index 1 into wa_module1.
           if moduleid is initial.
             moduleid = wa_module1-moduleid.
**** 13/04/07
             old_moduleid = moduleid.
           endif.
****
           data : l_module_lines like sy-index.

           describe table it_module1 lines l_module_lines.

           if l_module_lines > 1.
              g_mult_module_fl = 'X'.
           endif.

            g_hd_copied = 'X'.
** check line items modulewise/initialise
            g_TABLCTRL110_copied = ''.
            g_TABLCTRL111_copied = ''.
            g_TABLCTRL112_copied = ''.
            g_TABLCTRL113_copied = ''.
            g_TABLCTRL114_copied = ''.
            g_TABLCTRL115_copied = ''.

**
*
*            if ZIC_PREP_ROLEREQ-comm_fl = 'X' and old_ok_code =
*'CHANGE'
*.
*              perform verify2.
*            endif.

            perform validations.

        else.
           message i101(zhelp) with ZIC_PREP_ROLEREQ-docno.
        endif.

       endif.

      endif.

      select single * from T500P
                 where PERSA = ZIC_PREP_ROLEREQ-PERSA.

      if sy-subrc = 0.

          ZIC_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      endif.


   endif.

endif.

      select single * from ZMM_PREP_RSN
                 where REASON = ZIC_PREP_ROLEREQ-RSN_CODE.

      if sy-subrc = 0.

          ZIC_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

      endif.

      select single * from ZMM_PREP_STATUS
                 where STATUS_CODE = ZIC_PREP_ROLEREQ-STATUS .

      if sy-subrc = 0.

          STATUS_DESC = ZMM_PREP_STATUS-STATUS_DESC.

      endif.


    if ZIC_PREP_ROLEREQ-fundc <> '' and ZIC_PREP_ROLEREQ-REASON1 = ''.

       set cursor field 'ZIC_PREP_ROLEREQ-REASON1'.
        message i100(zhelp).
    endif.

    perform crc_module_checking.

    perform get_correspondence.

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

  when 'CREATE' or 'ROLE_DEL'.

     loop at screen.

       if screen-group1 = 'GP1'.
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 1.
         endif.
          modify screen.
       endif.

       if screen-group2 = 'GP2'.
            screen-required = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
*             perform pop_up_message.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and moduleid <> ''
           and ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and old_ok_code = 'ROLE_DEL'.
           MODULEID = 'FI'.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
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
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 0.
         endif.
          modify screen.
       endif.

       if screen-group2 = 'GP2'.
         if moduleid <> 'MM' and screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
         else.
          screen-input = 1.
          screen-required = 0.
         endif.
          modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-USERID' and
           ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-group3 = 'GPC' .
           if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
             screen-active = 1.
           else.
             screen-active = 0.
           endif.
           screen-invisible = 0.
           modify screen.
       endif.

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
            screen-input = 0.
            modify screen.
       endif.

      if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

*Begin of <RD1K963151>.
if screen-name = 'ZIC_PREP_ROLEREQ-USERIDCR' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    endif.


IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-CR_DATE' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.

IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERIDAP' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.


IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-APP_DATE' AND SY-UCOMM = ' '.
    screen-input = 1.
    screen-output = 1.
    MODIFY SCREEN.
    ENDIF.
*End of <RD1K963151>.
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

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
            screen-input = 1.
            modify screen.
       endif.

       if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
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

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 0.
              modify screen.
       endif.

*       if screen-name = 'TABCTRL100_DELETE' or
*           screen-name = 'TABCTRL100_INSERT' or
*           screen-name = 'COPY'.
*              screen-input = 0.
*              modify screen.
*       endif.

       if g_user = 'L1' and screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP1_FL'
.
              screen-input = 1.
              modify screen.
       endif.

       if ( g_user = 'IM' ) and
           screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP0_FL'.
              screen-input = 1.
              modify screen.
       endif.
       if ( g_user = 'L3' ) and
           screen-name = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
              screen-input = 1.
              modify screen.
       endif.

       if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       elseif screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL <> 'X'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.

       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-FUNDC' or
          screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          screen-input = 0.
          modify screen.
       endif.

     endloop.

    when 'CROSSCO'.

     loop at screen.

       if screen-group1 = 'GP1' or
           screen-group4 = 'GP4'.
           screen-input = 1.
           if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
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

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC' .
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID' and moduleid <> ''
           and ZIC_PREP_ROLEREQ-USERID <> ''.
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-CCODE' and
          not ZIC_PREP_ROLEREQ-CCODE is initial .
           screen-input = 0.
           modify screen.
       endif.

       if screen-name = 'ZIC_PREP_ROLEREQ-FUNDC_FL' or
          screen-name = 'IN'.
           screen-active = 0.
           screen-invisible = 1.
           modify screen.
       endif.

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
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

       if screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'       or
*          screen-name = 'MODULEID'    or
          screen-name = 'DETAILS'     or
          screen-name = 'CORR' or screen-name = 'STAT' or
          screen-name = 'M'    or screen-name = 'TABCTRL100_PREVIOUS'
                               or screen-name = 'TABCTRL100_NEXT'.
           screen-input = 1.
           screen-required = 1.
           modify screen.
       else.
           screen-input = 0.
           modify screen.
       endif.

        if screen-group3 = 'GPC' and ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
           screen-active = 1.
           screen-invisible = 0.
           modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 1.
*           screen-required = 1.
           modify screen.
       endif.


    endloop.

    when 'DELETE'.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREQ-DOCNO' or screen-name = 'CORR'
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

       if ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
           if ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
             screen-input = 1.
           else.
            clear : ZIC_PREP_ROLEREQ-PERSA, ZIC_PREP_ROLEREQ-NAME1.
            screen-input = 0.
           endif.
           modify screen.
       endif.

       if screen-group3 = 'GPC'.
           screen-input = 0.
           screen-invisible = 1.
           modify screen.
       endif.

       if screen-name = 'MODULEID'.
           screen-input = 0.
           modify screen.
       endif.

          if ( screen-name = 'ZIC_PREP_ROLEREQ-FR_DATE_AUTH' or
                screen-name = 'ZIC_PREP_ROLEREQ-TO_DATE_AUTH' ).
            screen-input = 1.
            screen-invisible = 0.
            screen-required = 0.
          else.
            if ( screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_NO' or
                screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_DATE' ).
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

        if screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
         if not ZIC_PREP_ROLEREQ-FUNDC is initial.
          screen-input = 1.
          screen-required = 1.
         else.
          screen-input = 0.
         endif.
         modify screen.
       endif.

*added on 05/03/2007
        if screen-name = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
              screen-input = 1.
              modify screen.
        endif.

    endloop.

ENDCASE.
ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL100_init output.

  perform check_auth.

  perform get_user.

**   if g_hd_copied is initial.
**    refresh control 'TABCTRL100' from screen '0100'.
    data l_fis_initial.
    set parameter id 'FIS' field l_fis_initial.
    set parameter id 'BUK' field l_fis_initial.
**  endif.

endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
module TABCTRL100_move output.
  move-corresponding g_TABCTRL100_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    if old_ok_code = 'CRCROLES' or ZIC_PREP_ROLEREQ-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
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
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
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
      elseif ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
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

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

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

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABCTRL100_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                            not old_ok_code is initial.
            screen-input = 1.
            modify screen.

            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial.
              message i116(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
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

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

perform get_correspondence.

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
  or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X' and
       ZIC_PREP_ROLEREQ-STATUS <> 'C' ).

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
       or ( old_ok_code = 'DISPLAY' and ZIC_PREP_ROLEREQ-comm_fl = 'X'
            and ZIC_PREP_ROLEREQ-STATUS <> 'C').

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

**LOOP AT TABCTRL100-cols INTO cols WHERE index GT 10.
**      cols-invisible = '1'.
**      MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.
**
**LOOP AT TABCTRL100-cols INTO cols WHERE index = 11.
**    cols-invisible = '0'.
**    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.

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
  comparing role_name plant grp sloc receipt_loc approver.

endif.

describe table g_TABCTRL100_itab lines TABCTRL100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_110 OUTPUT.

describe table g_TABLCTRL110_itab lines TABLCTRL110-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_110
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

if ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
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
    if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or
       ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    else.
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    endif.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DELETE' and ( okcode_100 = '' or
    okcode_100 = 'DELETE' or okcode_100 = 'LIST' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if old_ok_code = 'DISPLAY'
   and ZIC_PREP_ROLEREQ-comm_fl = 'X'.
   SET PF-STATUS 'OPTNS' excluding it_tab.
else.

  if old_ok_code = 'DISPLAY' and ( okcode_100 = '' or
      okcode_100 = 'DISPLAY' or okcode_100 = 'LIST' ) .
      move 'ATTACH' to wa_tab-fcode.
      append wa_tab to it_tab.
      SET PF-STATUS 'OPTNS' excluding it_tab.
  endif.

endif.

if old_ok_code = 'APPROVE' and ( okcode_100 = '' or
    okcode_100 = 'APPROVE' or okcode_100 = 'LIST' ) .
    move 'ATTACH' to wa_tab-fcode.
    append wa_tab to it_tab.
    SET PF-STATUS 'OPTNS' excluding it_tab.
endif.

if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    g_text = ' : CRC Authorisation'.
    SET TITLEBAR 'PREP_TITLE' with g_text.
endif.

ENDMODULE.                 " set_title  OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL110_init output.
  if g_TABLCTRL110_copied is initial and old_ok_code <> 'CREATE'.

    refresh g_TABLCTRL110_itab[].
    clear   g_TABLCTRL110_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL110_itab where moduleid = 'MM' and
                docno = zic_prep_rolereq-docno ORDER BY PRIMARY KEY.
    g_TABLCTRL110_copied = 'X'.
    read table g_tablctrl110_itab into g_tablctrl110_wa index 1.
    if sy-subrc = 0.
       MODULEID = g_tablctrl110_wa-moduleid.
    endif.
    refresh control 'TABLCTRL110' from screen '0110'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL110_move output.

  move-corresponding g_TABLCTRL110_wa to ZIC_PREP_ROLEREI.

  if not ZIC_PREP_ROLEREI-role_name is initial.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    if old_ok_code = 'CRCROLES' or zic_prep_rolereq-crc_fl = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 .
         move zmm_prep_rolecrc-brief_desc to role_desc.
     endif.
     SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      if sy-subrc = 0 and ZIC_PREP_ROLEREI-PLANT <> ''.
         move zmm_prep_crcdesg-crc_pos to crc_pos.
     endif.
    else.
      select single * from zmm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zmm_prep_roledes-brief_desc to role_desc.
     endif.
    endif.

  endif.

endmodule.

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL110_get_lines output.
  g_TABLCTRL110_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_dynnr OUTPUT.
if dynnr is initial.
   dynnr = '101'.
endif.
case moduleid.

  when 'MM'.
    dynnr = '0110'.
  when 'PM'.
    dynnr = '0111'.
  when 'PS'.
    dynnr = '0112'.
  when 'PP'.
    dynnr = '0113'.
  when 'SD'.
    dynnr = '0114'.
  when 'QM'.
    dynnr = '0115'.

endcase.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_col_attrib OUTPUT.

LOOP AT TABLCTRL110-cols INTO cols WHERE index GT 11.
      cols-invisible = '1'.
      MODIFY TABLCTRL110-cols FROM cols INDEX sy-tabix.
ENDLOOP.

LOOP AT TABLCTRL110-cols INTO cols WHERE index = 12.
    cols-invisible = '0'.
    MODIFY TABLCTRL110-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_110 OUTPUT.

if not g_TABLCTRL110_itab[] is initial .

  sort g_TABLCTRL110_itab
  by role_name plant grp sloc receipt_loc approver.
  delete adjacent duplicates from g_TABLCTRL110_itab
  comparing role_name plant grp sloc receipt_loc approver.

endif.

describe table g_TABLCTRL110_itab lines TABLCTRL110-lines.

ENDMODULE.                 " delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL110_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

  if old_ok_code <> 'CRCROLES'.
      if old_ok_code = 'CREATE'.
      elseif ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
         CRC_CHECK_FL = 'X'.
      endif.
  else.
      CRC_CHECK_FL = 'X'.
  endif.

   if CRC_CHECK_FL <> 'X' .

      clear CRC_CHECK_FL.

    select single * from zmm_prep_roledes where role_type =
                                              g_TABLCTRL110_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zmm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP'.

            if zmm_prep_roledes-P_GRP = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
             else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER'.

              if zmm_prep_roledes-APP_LEVEL = 'X' and
                          old_ok_code <> 'APPROVE'.
                  screen-input = 1.
                  modify screen.
              else.
                  screen-input = 0.
                  modify screen.
              endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

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

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

  if ZIC_PREP_ROLEREQ-CRC_FL = 'X' or old_ok_code = 'CRCROLES'.

    SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 G_TABLCTRL110_WA-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

    if sy-subrc = 0.

     loop at screen.

       if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .


           if zmm_prep_rolecrc-plant = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-GRP' .


           if zmm_prep_rolecrc-P_GRP = 'X' and
                                old_ok_code <> 'APPROVE'.
                      screen-input = 1.
                      modify screen.
           else.
                      screen-input = 0.
                      modify screen.
           endif.

        endif.


        if screen-name = 'ZIC_PREP_ROLEREI-SLOC'.

                if zmm_prep_rolecrc-S_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                else.
                    screen-input = 0.
                    modify screen.
                endif.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

                if zmm_prep_rolecrc-R_LOC = 'X' and
                          old_ok_code <> 'APPROVE'.
.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.
**
        if screen-name = 'CRC_POS' and
              ( ZIC_PREP_ROLEREI-role_name <> 'M3B' and
                ZIC_PREP_ROLEREI-role_name <> 'M11S' and
                ZIC_PREP_ROLEREI-role_name <> 'M11M' ).
                if old_ok_code <> 'APPROVE'.
                    screen-required = 1.
                    screen-input = 1.
                    modify screen.
                  else.
                    screen-input = 0.
                    modify screen.
                endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and
               ( ZIC_PREP_ROLEREI-role_name = 'M3B' or
                ZIC_PREP_ROLEREI-role_name = 'M11S' or
                ZIC_PREP_ROLEREI-role_name = 'M11M' ).
.          screen-input = 1.
        elseif screen-name = 'ZIC_PREP_ROLEREI-APPROVER' and
               ( ZIC_PREP_ROLEREI-role_name <> 'M3B' and
                ZIC_PREP_ROLEREI-role_name <> 'M11S' and
                ZIC_PREP_ROLEREI-role_name <> 'M11M' ).
           screen-input = 0.
        endif.

        modify screen.

**

     endloop.

     else.

       loop at screen.

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                            not old_ok_code is initial.
            screen-input = 1.
            modify screen.

            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial.
              message i116(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
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

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

ENDMODULE.                 " TABLCTRL110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL111_init output.
  if g_TABLCTRL111_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL111_itab[].
    clear   g_TABLCTRL111_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL111_itab where moduleid = 'PM' and
                docno = zic_prep_rolereq-docno.
    g_TABLCTRL111_copied = 'X'.
    refresh control 'TABLCTRL111' from screen '0111'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL111_move output.

move-corresponding g_TABLCTRL111_wa to ZIC_PREP_ROLEREI.
if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zpm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zpm_prep_roledes-brief_desc to role_desc.
     endif.
endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL111_get_lines output.
  g_TABLCTRL111_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_111 OUTPUT.
if not g_TABLCTRL111_itab[] is initial .

  sort g_TABLCTRL111_itab
  by role_name plant shop_no.
  delete adjacent duplicates from g_TABLCTRL111_itab
  comparing role_name plant shop_no.

endif.

describe table g_TABLCTRL111_itab lines TABLCTRL111-lines.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL111_attrib OUTPUT.
  if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zpm_prep_roledes where role_type =
                                              g_TABLCTRL111_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zpm_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SHOP_NO' .

            if zpm_prep_roledes-shop_no = 'X' and
                          old_ok_code <> 'APPROVE'.
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_111 OUTPUT.

describe table g_TABLCTRL111_itab lines TABLCTRL111-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_111
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_col_attrib OUTPUT.

LOOP AT TABLCTRL111-cols INTO cols WHERE index GT 8.
      cols-invisible = '1'.
      MODIFY TABLCTRL111-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECT_DATA OUTPUT.

    g_release = ZIC_PREP_ROLEREQ-req_cr_fl.
    g_approve = ZIC_PREP_ROLEREQ-req_app_fl.
    g_approve0 = ZIC_PREP_ROLEREQ-req_app0_fl.
    g_approve1 = ZIC_PREP_ROLEREQ-req_app1_fl.

    select single * from ZIC_PREP_ROLEREQ
                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

    if ZIC_PREP_ROLEREQ-req_cr_fl is initial.
      ZIC_PREP_ROLEREQ-req_cr_fl = g_release.
    endif.
    if ZIC_PREP_ROLEREQ-req_app_fl is initial.
      ZIC_PREP_ROLEREQ-req_app_fl = g_approve.
    endif.
    if ZIC_PREP_ROLEREQ-req_app1_fl is initial.
      ZIC_PREP_ROLEREQ-req_app1_fl = g_approve1.
    endif.

    if ZIC_PREP_ROLEREQ-req_app0_fl is initial.
      ZIC_PREP_ROLEREQ-req_app0_fl = g_approve0.
    endif.


    clear : g_release, g_approve, g_approve0, g_approve1.

*  select single * from zic_prep_rolereq
*  where docno = zic_prep_rolereq-docno.

  select * from zic_prep_rolerei into table ist_item
  where docno = zic_prep_rolereq-docno.

ENDMODULE.                 " SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  data : l_desc(30).

  sort ist_item descending.

  loop at ist_item into wa_item.
   case wa_item-moduleid.
    when 'MM'.
        perform check_module_status_mm.
    when 'PM'.
          perform check_module_status_pm.
    when 'PS'.
          perform check_module_status_ps.
    when 'PP'.
          perform check_module_status_pp.
    when 'SD'.
          perform check_module_status_sd.
    when 'QM'.
          perform check_module_status_qm.
   endcase.
  endloop.

  loop at ist_item into wa_item.

  case wa_item-moduleid .

  when 'MM'.

    at new moduleid.

    write :/.

    if mm_not_ok = 'X'.
     format intensified on color 6.
    else.
     format intensified on color 5.
    endif.

    write: / 'MM Module', 'Role', 'Description',
           at 48  'Plant',
           at 53  'PurGp',
           at 59  'Sloc',
           at 64  'RecptLoc',
           at 73  'User level' .

     format intensified off color off.

*     uline.

     endat.

     if ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT BRIEF_DESC FROM ZMM_PREP_ROLECRC INTO L_DESC UP TO 1 ROWS
 WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     else.

      select single brief_desc from zmm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    endif.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 53 wa_item-grp,
             at 59 wa_item-sloc,
             at 64 wa_item-receipt_loc,
             at 73 wa_item-approver.

  when 'PM'.

    at new moduleid.

        WRITE /.

     if pm_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PM Module', 'Role', 'Description',
           at 48  'Plant',
           at 54  'ShopNo'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zpm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 54 wa_item-shop_no.

**
  when 'PS'.

    at new moduleid.

        WRITE /.

     if ps_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PS Module', 'Role', 'Description',
           at 48  'Service',
           at 56  'Project',
           at 64  'Location',
           at 73  'Asset',
           at 79  'Basin'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zps_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-service,
             at 56 wa_item-project,
             at 64 wa_item-location,
             at 73 wa_item-asset,
             at 79 wa_item-basin.

***

 when 'PP'.

    at new moduleid.

        WRITE /.

     if pp_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'PP Module', 'Role', 'Description',
           at 48  'Plant',
           at 56  'Sloc',
           at 64  'Resource',
           at 73  'CTF_sloc'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zpp_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 56 wa_item-sloc,
             at 64 wa_item-res,
             at 73 wa_item-CTF_sloc.

  when 'SD'.

    at new moduleid.

        WRITE /.

     if sd_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'SD Module', 'Role', 'Description',
           at 48  'S_Org',
           at 56  'Div',
           at 64  'Plant',
           at 73  'ShPt'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zsd_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-sale_org,
             at 56 wa_item-div,
             at 64 wa_item-plant,
             at 73 wa_item-ship_point.

    when 'QM'.

    at new moduleid.

        WRITE /.

     if qm_not_ok = 'X'.
       format intensified on color 6.
     else.
       format intensified on color 5.
     endif.
        write: / 'QM Module', 'Role', 'Description',
           at 48  'Plant',
           at 56  'Asset'.

        format intensified off color off.

*        uline.
    endat.

    select single brief_desc from zqm_prep_roledes into l_desc
          where ROLE_TYPE = wa_item-role_name.

    write: / wa_item-moduleid, at 12 wa_item-role_name, at 17 l_desc,
             at 48 wa_item-plant,
             at 56 wa_item-asset_qm.

  endcase.

*
    HIDE : wa_item-moduleid, wa_item-role_name, wa_item-plant,
             wa_item-grp, wa_item-sloc, wa_item-receipt_loc,
             wa_item-approver, wa_item-service, wa_item-project,
             wa_item-location,wa_item-region,wa_item-asset,
             wa_item-basin,wa_item-res, wa_item-CTF_sloc,
             wa_item-sale_org,wa_item-div,wa_item-plant,
             wa_item-ship_point,wa_item-asset_qm.

  endloop.

ENDMODULE.                 " value_list1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL111_DELETE' or
           screen-name = 'TABLCTRL111_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_attrib OUTPUT.

 loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL110_DELETE' or
           screen-name = 'TABLCTRL110_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL112_init output.
  if g_TABLCTRL112_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL112_itab[].
    clear   g_TABLCTRL112_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL112_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL112_itab where moduleid = 'PS' and
                docno = zic_prep_rolereq-docno.
    g_TABLCTRL112_copied = 'X'.
    refresh control 'TABLCTRL112' from screen '0112'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL112_move output.

  move-corresponding g_TABLCTRL112_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zps_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zps_prep_roledes-brief_desc to role_desc.
     endif.
endif.

endmodule.

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL112_get_lines output.
  g_TABLCTRL112_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_col_attrib OUTPUT.
LOOP AT TABLCTRL112-cols INTO cols WHERE index GT 11.
      cols-invisible = '1'.
      MODIFY TABLCTRL112-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr112_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL112_DELETE' or
           screen-name = 'TABLCTRL112_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL112_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> '' and
    not g_TABLCTRL112_wa-role_name is initial.

    select single * from zps_prep_roledes where role_type =
                      g_TABLCTRL112_wa-role_name.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SERVICE' .

*            if zps_prep_roledes-service = 'X' and
             if old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PROJECT' .

            if zps_prep_roledes-project = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-LOCATION' .

            if zps_prep_roledes-location = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

*        if screen-name = 'ZIC_PREP_ROLEREI-REGION' .
*
*            if zps_prep_roledes-region = 'X' and
*                          old_ok_code <> 'APPROVE'.
*                screen-input = 1.
*                modify screen.
*            else.
*                screen-input = 0.
*                modify screen.
*            endif.
*
*        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-ASSET' .

            if zps_prep_roledes-asset = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-BASIN' .

            if zps_prep_roledes-basin = 'X' and
                          old_ok_code <> 'APPROVE'.
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.
     endif.
endif.

if old_ok_code = 'DISPLAY'.

       loop at screen.
          screen-input = 0.
          modify screen.
        endloop.

 endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

ENDMODULE.                 " TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_112 OUTPUT.

describe table g_TABLCTRL112_itab lines TABLCTRL112-lines.

if not g_field is initial.
      set cursor field g_field line g_i.
      clear g_field.
else.
      set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_112
.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_112  OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL113_init output.
  if g_TABLCTRL113_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL113_itab[].
    clear   g_TABLCTRL113_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL113_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL113_itab where moduleid = 'PP' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL113_copied = 'X'.
    refresh control 'TABLCTRL113' from screen '0113'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL113_move output.
  move-corresponding g_TABLCTRL113_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zpp_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zpp_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL113_get_lines output.
  g_TABLCTRL113_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL113_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zpp_prep_roledes where role_type =
                                              g_TABLCTRL113_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zpp_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SLOC' .

            if zpp_prep_roledes-sloc = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-RES'.

             select * from zpp_prep_res into corresponding fields of
             table it_res  where role_type = ZIC_PREP_ROLEREI-ROLE_NAME
             and plant = ZIC_PREP_ROLEREI-PLANT.

            if sy-subrc = 0  and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-CTF_SLOC' .

         select single * from ZPP_PREP_DROLEEX where
             role_type = ZIC_PREP_ROLEREI-ROLE_NAME and
             plant = ZIC_PREP_ROLEREI-PLANT and
             sloc = ZIC_PREP_ROLEREI-SLOC.

            if sy-subrc = 0 and
                          old_ok_code <> 'APPROVE'.
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

ENDMODULE.                 " TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_113 OUTPUT.

describe table g_TABLCTRL113_itab lines TABLCTRL113-lines.

if not g_field is initial.
     set cursor field g_field line g_i.
     clear g_field.
else.
     set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_113.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_col_attrib OUTPUT.
LOOP AT TABLCTRL113-cols INTO cols WHERE index GT 9.
      cols-invisible = '1'.
      MODIFY TABLCTRL113-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr113_attrib OUTPUT.

loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL113_DELETE' or
           screen-name = 'TABLCTRL113_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr113_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL114_init output.
  if g_TABLCTRL114_copied is initial and old_ok_code <> 'CREATE'.
    refresh g_TABLCTRL114_itab[].
    clear   g_TABLCTRL114_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL114_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL114_itab where moduleid = 'SD' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL114_copied = 'X'.
    refresh control 'TABLCTRL114' from screen '0114'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL114_move output.
**13/04/07
  clear ZIC_PREP_ROLEREI-REJ_FL_SAVE.
  move-corresponding g_TABLCTRL114_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zsd_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zsd_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL114_get_lines output.
  g_TABLCTRL114_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_col_attrib OUTPUT.

LOOP AT TABLCTRL114-cols INTO cols WHERE index GT 9.
      cols-invisible = '1'.
      MODIFY TABLCTRL114-cols FROM cols INDEX sy-tabix.
ENDLOOP.

ENDMODULE.                 " scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr114_attrib OUTPUT.

loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL114_DELETE' or
           screen-name = 'TABLCTRL114_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.

ENDMODULE.                 " scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL114_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zsd_prep_roledes where role_type =
                                              g_TABLCTRL114_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if zsd_prep_roledes-plant = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SALE_ORG' .

            if zsd_prep_roledes-sale_org = 'X' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-DIV'.

             if zsd_prep_roledes-div = 'X'  and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-SHIP_POINT' .

             if zsd_prep_roledes-ship_point = 'X'  and
                          old_ok_code <> 'APPROVE'.
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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

ENDMODULE.                 " TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_114  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_114 OUTPUT.

describe table g_TABLCTRL114_itab lines TABLCTRL114-lines.

if not g_field is initial.
     set cursor field g_field line g_i.
     clear g_field.
else.
     set cursor field 'ZIC_PREP_ROLEREI-ROLE_NAME' line g_curr_line_114.
endif.

clear sy-ucomm.

ENDMODULE.                 " set_cursor_114  OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL115_init output.
  if g_TABLCTRL115_copied is initial and old_ok_code <> 'CREATE'.
  refresh g_TABLCTRL115_itab[].
    clear   g_TABLCTRL115_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL115_itab'
    select * from ZIC_PREP_ROLEREI
       into corresponding fields
       of table g_TABLCTRL115_itab where
       moduleid = 'QM' and
       docno = zic_prep_rolereq-docno.
    g_TABLCTRL115_copied = 'X'.
    refresh control 'TABLCTRL115' from screen '0115'.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL115_move output.
  move-corresponding g_TABLCTRL115_wa to ZIC_PREP_ROLEREI.
  if not ZIC_PREP_ROLEREI-role_name is initial.
  ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
      select single * from zqm_prep_roledes where role_type =
                  ZIC_PREP_ROLEREI-role_name.
      if sy-subrc = 0 .
         move zqm_prep_roledes-brief_desc to role_desc.
     endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL115_get_lines output.
  g_TABLCTRL115_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_col_attrib OUTPUT.
LOOP AT TABLCTRL115-cols INTO cols WHERE index GT 7.
      cols-invisible = '1'.
      MODIFY TABLCTRL115-cols FROM cols INDEX sy-tabix.
ENDLOOP.
ENDMODULE.                 " scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr115_attrib OUTPUT.
loop at screen.
  if old_ok_code = 'APPROVE'.
    if screen-name = 'TABLCTRL115_DELETE' or
           screen-name = 'TABLCTRL115_INSERT' or
           screen-name = 'COPY'.
              screen-input = 0.
              modify screen.
    endif.
  endif.
endloop.
ENDMODULE.                 " scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL115_attrib OUTPUT.

if old_ok_code <> 'DISPLAY' and old_ok_code <> ''.

    select single * from zqm_prep_roledes where role_type =
                                              g_TABLCTRL115_wa-role_name
.

    if sy-subrc = 0.

    loop at screen.

        if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

          if old_ok_code <> 'APPROVE'.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
          old_ok_code = 'APPROVE' and ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          screen-input = 1.
          modify screen.
        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-PLANT' .

            if ZIC_PREP_ROLEREQ-CCODE = 'MUM' and
               ZIC_PREP_ROLEREI-ROLE_NAME = 'Q1' and
                          old_ok_code <> 'APPROVE'.
                screen-input = 1.
                modify screen.
            else.
                screen-input = 0.
                modify screen.
            endif.

        endif.

        if screen-name = 'ZIC_PREP_ROLEREI-ASSET_QM' .

        select single * from zqm_prep_asset where ccode =
                                              ZIC_PREP_ROLEREQ-ccode.

            if sy-subrc = 0 and
               ZIC_PREP_ROLEREI-ROLE_NAME = 'Q2' and
                          old_ok_code <> 'APPROVE'.
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

         if screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' and
                        not old_ok_code is initial and
                        old_ok_code <> 'APPROVE'.
            screen-input = 1.
            modify screen.
            if not ZIC_PREP_ROLEREI-ROLE_NAME is initial .
              message i115(zhelp) with ZIC_PREP_ROLEREI-ROLE_NAME.
            endif.
         else.
            screen-input = 0.
            modify screen.
         endif.

       endloop.

    endif.

else.

   loop at screen.
      screen-input = 0.
      modify screen.
    endloop.

endif.

loop at screen.

if ZIC_PREP_ROLEREI-REJ_FL <> ''.
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
ENDMODULE.                 " TABLCTRL115_attrib  OUTPUT
