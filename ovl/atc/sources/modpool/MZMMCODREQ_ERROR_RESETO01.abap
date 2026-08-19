*--- MAIN PROGRAM: MZMMCODREQ_ERROR_RESETO01 ---*
***INCLUDE MZMMCODREQO01 .
*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
module TABCTRL100_change_tc_attr output.
  describe table IST_SRCHLP lines TABCTRL100-lines.
endmodule.

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABCTRL100_get_lines output.
 if wa_srchlp-filter_flag = ''.
  g_TABCTRL100_lines = sy-loopc.
 endif.
endmodule.


*&spwizard: output module for tc 'TABCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABCTRL110_init output.
******Local data********
  Data: l_110lns type i,
        l_tdname like thead-tdname,
        l_stxl   like stxl.

*************************
*  check_code = sy-ucomm.
  clear : g_ok_code110 , sy-ucomm , g_ok_code115.

*refresh ist_message.

*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABCTRL110_itab'
*****Addition*****************
  IF g_TABCTRL110_copied is initial.
    if ( g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSTO' )
       or g_mode = 'REL'.

      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABCTRL110_itab
      where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
    endif.
***to delete the internal table entries which does not
***belongs to a partiular codifier's assigned class.
    if sy-tcode = 'ZCODG'.
      select single * from zmm_cdcodifier
             where codifier = sy-uname.
      if sy-subrc = 0.
       loop at g_TABCTRL110_itab into g_tabctrl110_wa.
        select single * from zmm_cdcodifier
               where codifier = sy-uname
               and   matgp    = g_tabctrl110_wa-matgp.
        if sy-subrc <> 0.
         delete g_TABCTRL110_itab index sy-tabix.
        endif.
       endloop.
      endif.
    endif.
****

    g_TABCTRL110_copied = 'X'.
    refresh control 'TABCTRL110' from screen '0110'.
  ENDIF.
**********************************************
***To check, if long text maintained or not
  Case g_mode.
    WHEN 'CRE'.
      IF not g_TABCTRL110_itab[] is initial.
        loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
          concatenate 'CDDS' '9999999999' g_TABCTRL110_wa-srno
           into l_tdname.
          perform check_lt_exist using l_tdname.
          if not g_lines[] is initial.
            read table g_lines into g2_lines index 1.
            if not g2_lines-tdline is initial.
              g_TABCTRL110_wa-dsflag = 'X'.
              modify g_TABCTRL110_itab from g_TABCTRL110_wa
                  transporting dsflag
                  where srno = g_TABCTRL110_wa-srno.
              clear g_TABCTRL110_wa-dsflag.
            else.
              g_TABCTRL110_wa-dsflag = ''.
              modify g_TABCTRL110_itab from g_TABCTRL110_wa
                  transporting dsflag
                  where srno = g_TABCTRL110_wa-srno.
            endif.
            clear g2_lines.
          endif.
        endloop.
      ENDIF.
    WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
      loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
        concatenate 'CDDS' zmm_cdhd_st-reqno g_TABCTRL110_wa-srno
        into l_tdname.
        perform check_lt_exist using l_tdname.
        if not g_lines[] is initial.
          read table g_lines into g2_lines index 1.
          if not g2_lines-tdline is initial.
            g_TABCTRL110_wa-dsflag = 'X'.
            modify g_TABCTRL110_itab from g_TABCTRL110_wa
                 transporting dsflag
                 where srno = g_TABCTRL110_wa-srno.
            clear g_TABCTRL110_wa-dsflag.
          else.
            g_TABCTRL110_wa-dsflag = ''.
            modify g_TABCTRL110_itab from g_TABCTRL110_wa
                 transporting dsflag
                 where srno = g_TABCTRL110_wa-srno.
          endif.
          clear g2_lines.
        endif.
      endloop.
  ENDCASE.

**********************************************
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    describe table g_TABCTRL110_itab lines l_110lns.
    if l_110lns < 99.
      TABCTRL110-lines = 99.
    endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
module TABCTRL110_move output.
  Data: l_srno type i,
        l_srnoflag type c,
        l_itab110 type t_TABCTRL110.
*************************************************************

  move-corresponding g_TABCTRL110_wa to ZMM_CDITEM.
  if ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ).
   concatenate g_TABCTRL110_wa-desc1
               g_TABCTRL110_wa-desc2
               g_TABCTRL110_wa-desc3
               g_TABCTRL110_wa-desc4
               g_TABCTRL110_wa-user_desc
          into g_TABCTRL110_wa-desc_fin
          separated by space.

    condense g_TABCTRL110_wa-desc_fin.

    IF not g_TABCTRL110_wa-desc_fin is initial.
*     move TABCTRL110-current_line
*       to g_TABCTRL110_wa-SRNO.
**********To get the maximum srno in the internal table***
      clear: l_srno,l_srnoflag.
      describe table g_TABCTRL110_itab lines l_srno.
      while l_srnoflag <> 'S'.
        read table g_TABCTRL110_itab into l_itab110
             with key srno = l_srno.
        if sy-subrc <> 0.
          l_srnoflag = 'S'.
        else.
          l_srno = l_srno + 1.
        endif.
      endwhile.
************************************************************
      if g_TABCTRL110_wa-SRNO = 0.
        move l_srno to g_TABCTRL110_wa-SRNO.
      endif.
    ENDIF.

*
    if TABCTRL110-current_line = g_curr_line_110.

      if not g_mat_fnd is initial.
        move g_mat_fnd to ZMM_CDITEM-mat_fnd.
       else.
        if do_not_change_flag = 'X'.
*            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
          clear do_not_change_flag.
        else.
          move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
        endif.
        if g_mat_fnd_flag = 'X'.
          move g_mat_fnd to ZMM_CDITEM-mat_fnd.
          clear g_mat_fnd_flag.
        endif.
      endif.

    endif.

    if g_TABCTRL110_wa-dsflag = 'X'.
      g_long_text_warning = 'X'.
    endif.

    move g_TABCTRL110_wa-SRNO to ZMM_CDITEM-SRNO.
    move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
  endif.
******
  IF sy-tcode = 'ZCODG'.
    concatenate g_TABCTRL110_wa-desc1
                g_TABCTRL110_wa-desc2
                g_TABCTRL110_wa-desc3
                g_TABCTRL110_wa-desc4
                g_TABCTRL110_wa-user_desc
          into  g_TABCTRL110_wa-desc_fin
          separated by space.

    condense g_TABCTRL110_wa-desc_fin.
    move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
  ENDIF.
endmodule.
***********************************************************************
*&spwizard: output module for tc 'TABCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABCTRL110_get_lines output.
  g_TABCTRL110_lines = sy-loopc.
endmodule.
************************************************************************
*&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL130_init output.

  if g_TABLCTRL130_copied is initial.
*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABLCTRL130_itab'
    if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZCAP'.
      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABLCTRL130_itab where
         reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
    Endif.
    g_TABLCTRL130_copied = 'X'.
    refresh control 'TABLCTRL130' from screen '0130'.
*    if g_mode = 'CRE'.
*      TABlCTRL130-lines = 10.
*    endif.
  endif.

*****
  if g_mode <> 'CRE'.
    loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
      Clear l_tdname.
      concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
      into l_tdname.
      Select single * into l_stxl from stxl
             where TDOBJECT = 'ZMMCD'
             and   TDNAME   = l_tdname
             and   TDID     = 'CDDS'.
      if sy-subrc = 0.
        g_TABLCTRL130_wa-dsflag = 'X'.
        modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
               transporting dsflag
               where srno = g_TABLCTRL130_wa-srno.
      endif.
    endloop.
  endif.
****
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    TABlCTRL130-lines = 99.
  endif.
endmodule.
***********************************************************************
*&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL130_move output.
  Data: l_itab130 type t_TABLCTRL130.
  move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
  if ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ).
    condense g_TABLCTRL130_wa-desc_fin.

    if not g_TABLCTRL130_wa-desc_fin is initial.
*     move TABLCTRL130-current_line
*       to g_TABLCTRL130_wa-SRNO.
**********To get the maximum srno in the internal table***
      clear: l_srno,l_srnoflag.
      describe table g_TABLCTRL130_itab lines l_srno.
      while l_srnoflag <> 'S'.
        read table g_TABLCTRL130_itab into l_itab130
             with key srno = l_srno.
        if sy-subrc <> 0.
          l_srnoflag = 'S'.
        else.
          l_srno = l_srno + 1.
        endif.
      endwhile.
      if g_TABLCTRL130_wa-SRNO = 0.
        move l_srno to g_TABLCTRL130_wa-SRNO.
      endif.

    endif.
    if TABLCTRL130-current_line = g_curr_line_130.
      move g_mat_fnd to ZMM_CDITEM-mat_fnd.
    else.
      move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
    endif.

    move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
    move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.
  endif.


endmodule.
************************************************************************
*&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL130_get_lines output.
  g_TABLCTRL130_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  Perform fill_sttab.
  SET PF-STATUS 'OPTNS' excluding it_tab1.
  case g_mode.
    when 'CRE'.
      SET TITLEBAR 'MATCODE_TTL' with ' - CREATE'.
    when 'CHA'.
      SET TITLEBAR 'MATCODE_TTL' with ' - CHANGE'.
    when 'DIS'.
      SET TITLEBAR 'MATCODE_TTL' with '- DISPLAY'.
    when 'DEL'.
      SET TITLEBAR 'MATCODE_TTL' with ' - DELETE'.
    when others.
      SET TITLEBAR 'MATCODE_TTL'.
  endcase.
*+260405*********
*If g_mode = 'APR' and OKCODE_100 = 'APPROVE'.
*    Perform find_user.
*endif.
*-260405
*Perform chng_attr_100.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

  Case g_mode.
* clear sy-ucomm.
    When ''.
      loop at screen.
        screen-input = 0.
        modify screen.
      endloop.
    When 'CRE'.
      loop at screen.
        if screen-name = 'ZMM_CDHD_ST-REQNO' OR
           screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
           screen-name = 'ZMM_CDHD_ST-REQCL'.
          screen-input = 0.
          modify screen.
        Endif.
        if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
           screen-input     = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.
        if screen-name = 'T_TECHAUTH'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.

      endloop.
    When 'CHA'.
      If zmm_cdhd_st-reqno is initial.
        loop at screen.
          if screen-name <> 'ZMM_CDHD_ST-REQNO'.
            screen-input = 0.
            modify screen.
          endif.
        endloop.
      Else.
        loop at screen.
          if screen-group1 = '02'.
            screen-input = 0.
            modify screen.
          endif.
          if screen-name = 'ZMM_CDHD_ST-MTART' or
             screen-name = 'ZMM_CDHD_ST-STATUS_FLAG' or
             screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
             screen-name = 'ZMM_CDHD_ST-REQCL'.
            screen-input = 0.
            modify screen.
          endif.
         if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
           screen-input     = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
         Endif.
        if screen-name = 'T_TECHAUTH'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.
        endloop.
      Endif.
    When 'REL'.
      loop at screen.
        if screen-name  = 'ZMM_CDHD_ST-STATUS_FLAG' or
           Screen-name  = 'ZMM_CDHD_ST-REQNO' or
           Screen-name  = 'P_REM'             or
           screen-name  = 'G_SH_CAPEQT'       or
           screen-name  = 'G_SH_MFR'          or
           screen-name  = 'G_SH_MDLNO'        OR
           screen-name  = 'ZMM_CDHD_ST-REQCL'.
          screen-input = 1.
          modify screen.
        Else.
          screen-input = 0.
          modify screen.
        Endif.
        if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
           screen-input     = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.
        if screen-name = 'T_TECHAUTH'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.

      endloop.

    When 'APR'.
      If zmm_cdhd_st-reqno is initial.
        loop at screen.
          if screen-name <> 'ZMM_CDHD_ST-REQNO'.
            screen-input = 0.
            modify screen.
          endif.
        endloop.
      Else.
        loop at screen.
          if screen-name = 'ZMM_CDHD_ST-APPROVE_MRP'.
            if  g_user = 'M' .
              screen-input = 1.
              modify screen.
            Else.
              screen-input = 0.
              modify screen.
            Endif.
          Elseif screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
****Addition*************************************
           if g_user = 'M'.
              if g_techapr_visible = 'Y'.
                screen-invisible = 0.
                screen-input     = 0.
              else.
                screen-invisible = 1.
              endif.
              modify screen.
           endif.
****End******************************************
            if g_user = 'L'.
              screen-input = 1.
              modify screen.
            Else.
              screen-input = 0.
              modify screen.
            Endif.
****Addition*************************************
          Elseif screen-name = 'T_TECHAUTH'.
            if g_user = 'M'.
              if g_techapr_visible = 'Y'.
                screen-invisible = 0.
              else.
                screen-invisible = 1.
              endif.
              modify screen.
            endif.
****End******************************************
          Else.
            screen-input = 0.
            modify screen.
          Endif.
          IF screen-name = 'P_REM'.
            screen-input = 1.
            modify screen.
          ENDIF.
        endloop.
      endif.
*040405-E

    When others.
      Loop at screen.
        if screen-name = 'ZMM_CDHD_ST-REQNO' or
           screen-name = 'DD'                or
           screen-name = 'P_REM'             or
           screen-name = 'ADNL_DESC'         or
           screen-name = 'G_SH_CAPEQT'       or
           screen-name = 'G_SH_MFR'          or
           screen-name = 'G_SH_MDLNO'.
          screen-input = 1.
        else.
          screen-input = 0.
        endif.
        modify screen.
*
        If screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
           screen-input     = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.
*
        If screen-name = 'T_TECHAUTH'.
          if g_techapr_visible = 'Y'.
           screen-invisible = 0.
          else.
           screen-invisible = 1.
          endif.
          modify screen.
        Endif.
*
        If screen-name = 'ZMM_CDHD_ST-REQCL'.
          if sy-tcode  = 'ZCODG'.
             screen-input = 1.
          else.
             screen-input = 0.
          endif.
          modify screen.
        Endif.

      endloop.
  Endcase.
  loop at screen.
   if sy-tcode <> 'ZCODG'.
    if screen-name = 'ZMM_MODIFIER-MATGRP'.
      screen-invisible = 1.
      modify screen.
    elseif screen-name = 'PB_CPMC'.
      screen-invisible = 1.
      modify screen.
    elseif screen-name = 'PB_UNDOCPMC'.
      screen-invisible = 1.
      modify screen.
    endif.
   endif.
  endloop.
  perform tcode_zcodg_attr.
ENDMODULE.                 " scr100_attr  OUTPUT


*&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL140_init output.
*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABLCTRL140_itab'
  if g_TABLCTRL140_copied is initial.
    if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABLCTRL140_itab where reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
    Endif.    .
    g_TABLCTRL140_copied = 'X'.
    refresh control 'TABLCTRL140' from screen '0140'.
  endif.
*****
  If g_mode <> 'CRE'.
    loop at g_TABLCTRL140_itab into g_TABLCTRL140_wa.
      Clear l_tdname.
      concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL140_wa-srno
      into l_tdname.
      Select single * into l_stxl from stxl
             where TDOBJECT = 'ZMMCD'
             and   TDNAME   = l_tdname
             and   TDID     = 'CDDS'.
      if sy-subrc = 0.
        g_TABLCTRL140_wa-dsflag = 'X'.
        modify g_TABLCTRL140_itab from g_TABLCTRL140_wa
               transporting dsflag
               where srno = g_TABLCTRL140_wa-srno.
      endif.
    endloop.
  Endif.
****

  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    TABlCTRL140-lines = 99.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL140_move output.
  move-corresponding g_TABLCTRL140_wa to ZMM_CDITEM.
  if g_mode = 'CRE'.
    concatenate g_TABLCTRL140_wa-desc1
                g_TABLCTRL140_wa-user_desc
           into g_TABLCTRL140_wa-desc_fin
           separated by space.
    condense g_TABLCTRL140_wa-desc_fin.
    if not g_TABLCTRL140_wa-desc_fin is initial.
      move TABLCTRL140-current_line
        to g_TABLCTRL140_wa-SRNO.
    endif.

    move g_TABLCTRL140_wa-SRNO to ZMM_CDITEM-SRNO.
    move g_TABLCTRL140_wa-desc_fin to ZMM_CDITEM-desc_fin.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL140_get_lines output.
  g_TABLCTRL140_lines = sy-loopc.
endmodule.

*&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: copy ddic-table to itab
module TABLCTRL120_init output.
Data : l_120lns type i.

*  check_code = sy-ucomm.
*  clear        sy-ucomm .

*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABLCTRL120_itab'
*****Addition*****************
  if g_TABLCTRL120_copied is initial.
    if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABLCTRL120_itab
      where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
    endif.
***to delete the internal table entries which does not
***belongs to a partiular codifier's assigned class.
    if sy-tcode = 'ZCODG'.
      select single * from zmm_cdcodifier
             where codifier = sy-uname.
      if sy-subrc = 0.
       loop at g_TABCTRL110_itab into g_tabctrl110_wa.
        select single * from zmm_cdcodifier
               where codifier = sy-uname
               and   matgp    = g_tabctrl110_wa-matgp.
        if sy-subrc <> 0.
         delete g_TABCTRL110_itab index sy-tabix.
        endif.
       endloop.
      endif.
    endif.
****

    g_TABLCTRL120_copied = 'X'.
    refresh control 'TABLCTRL120' from screen '0120'.
  endif.
*****
***To check, if long text maintained or not
  Case g_mode.
    WHEN 'CRE'.
      IF not g_TABLCTRL120_itab[] is initial.
        loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
          concatenate 'CDDS' '9999999999' g_TABLCTRL120_wa-srno
           into l_tdname.
          perform check_lt_exist using l_tdname.
          if not g_lines[] is initial.
            read table g_lines into g2_lines index 1.
            if not g2_lines-tdline is initial.
              g_TABLCTRL120_wa-dsflag = 'X'.
              modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
                  transporting dsflag
                  where srno = g_TABLCTRL120_wa-srno.
              clear g_TABLCTRL120_wa-dsflag.
            else.
              g_TABLCTRL120_wa-dsflag = ''.
              modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
                  transporting dsflag
                  where srno = g_TABLCTRL120_wa-srno.
            endif.
            clear g2_lines.
          endif.
        endloop.
      ENDIF.
    WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
      loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
        concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL120_wa-srno
        into l_tdname.
        perform check_lt_exist using l_tdname.
        if not g_lines[] is initial.
          read table g_lines into g2_lines index 1.
          if not g2_lines-tdline is initial.
            g_TABLCTRL120_wa-dsflag = 'X'.
            modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
                 transporting dsflag
                 where srno = g_TABLCTRL120_wa-srno.
            clear g_TABLCTRL120_wa-dsflag.
          else.
            g_TABLCTRL120_wa-dsflag = ''.
            modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
                 transporting dsflag
                 where srno = g_TABLCTRL120_wa-srno.
          endif.
          clear g2_lines.
        endif.
      endloop.
  ENDCASE.

**********************************************
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    describe table g_TABLCTRL120_itab lines l_120lns.
    if l_120lns < 99.
      TABLCTRL120-lines = 99.
    endif.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL120_move output.
  Data: l_itab120 type t_TABLCTRL120,
        lc_itab120 type t_TABLCTRL120 occurs 0.
***********************************************************
  move-corresponding g_TABLCTRL120_wa to ZMM_CDITEM.
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
*    concatenate g_TABLCTRL120_wa-desc1
*                g_TABLCTRL120_wa-user_desc
*           into g_TABLCTRL120_wa-desc_fin
*           separated by space.
*    condense g_TABLCTRL120_wa-desc_fin.
    if not g_TABLCTRL120_wa-desc_fin is initial.
*     move TABLCTRL120-current_line
*       to g_TABLCTRL120_wa-SRNO.
**********To get the maximum srno in the internal table***
      clear: l_srno,l_srnoflag.
      refresh lc_itab120.
      append lines of g_TABLCTRL120_itab to lc_itab120.
      delete lc_itab120 where srno = 0.
      describe table lc_itab120 lines l_srno.
*     describe table g_TABLCTRL120_itab lines l_srno.
      while l_srnoflag <> 'S'.
        read table g_TABLCTRL120_itab into l_itab120
             with key srno = l_srno.
        if sy-subrc <> 0.
          l_srnoflag = 'S'.
        else.
          l_srno = l_srno + 1.
        endif.
      endwhile.
      if g_TABLCTRL120_wa-SRNO = 0.
        move l_srno to g_TABLCTRL120_wa-SRNO.
      endif.

************************************************************
    endif.

    if TABLCTRL120-current_line = g_curr_line_120.
      move g_mat_fnd to ZMM_CDITEM-mat_fnd.
    else.
      move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
    endif.

    move g_TABLCTRL120_wa-SRNO to ZMM_CDITEM-SRNO.
    move g_TABLCTRL120_wa-desc_fin to ZMM_CDITEM-desc_fin.
  endif.
endmodule.

*&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: get lines of tablecontrol
module TABLCTRL120_get_lines output.
  g_TABLCTRL120_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  GET_MATTY_TCT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_MATTY_TCT OUTPUT.
  Perform fill_mattyp_itemdt.
  set parameter id 'ZMATGP' field ''.
  set parameter id 'MTA' field ZMM_CDHD_ST-MTART.
  if dynnr is initial.
    dynnr = '0101'.
  Endif.

ENDMODULE.                 " GET_MATTY_TCT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_material_helpdata  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_material_helpdata OUTPUT.
if   okcode_100 = 'CAPEQT'   or       " 17-06-05.
     okcode_100 = 'MDLNO'.
     clear okcode_100.
Else.
  G_MATTY = ZMM_CDHD_ST-MTART.
  sel_flag = check_pos.
  if g_hits_par_oth = 'X'.
    FIELD1 = 'ZMM_CDITEM-DESC4'.
  endif.
  CASE g_matty.
    WHEN 'ZSTO'.
      IF not desc11 is initial .
        If FIELD1 = 'ZMM_CDITEM-DESC1'.
          REFRESH IST_SRCHLP.
          clear : DESC22 ,DESC33 , DESC44.
          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.

        If FIELD1 = 'ZMM_CDITEM-DESC2'.
          clear : DESC33, DESC44.
          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.

        If FIELD1 = 'ZMM_CDITEM-DESC3'.
          clear : DESC44.
          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.

        If FIELD1 = 'ZMM_CDITEM-DESC4'.
          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.

        If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.
      ENDIF.

    WHEN 'ZSPR'.

      If FIELD1 = 'ZMM_CDITEM-PARTNO' .

        PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.

        REFRESH IST_SRCHLP.
        clear : DESC11, DESC22 ,DESC33 , DESC44.
        PERFORM SELECT_HELP_DATA using
                      G_PARTNO
                      DESC11
                      DESC22
                      DESC33
                      DESC44
                      DESC55
                      G_MATGP
                      G_MATTY
                   changing sel_flag.
      Endif.

      If FIELD1 = 'ZMM_CDITEM-DESC1' .

        clear : DESC22 ,DESC33 , DESC44.
        PERFORM SELECT_HELP_DATA using
                      G_PARTNO
                      DESC11
                      DESC22
                      DESC33
                      DESC44
                      DESC55
                      G_MATGP
                      G_MATTY
                   changing sel_flag.

      Endif.

      If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
        PERFORM SELECT_HELP_DATA using
                      G_PARTNO
                      DESC11
                      DESC22
                      DESC33
                      DESC44
                      DESC55
                      G_MATGP
                      G_MATTY
                   changing sel_flag.
      Endif.

      WHEN 'ZCAP'.
        Perform get_srchlp_zcap.
        describe table ist_srchlp lines g_mat_fnd.
  ENDCASE.

  if g_matty = 'ZSTO'.
    PERFORM SELECT_MATERIAL_DETAILS.
  elseif g_matty = 'ZSPR'.
    PERFORM SELECT_MATERIAL_DETAILS1.
  endif.
Endif.
ENDMODULE.                 " get_material_helpdata  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.
*
  IF not g_mode is initial.
    if g_mode <> 'CRE' and g_hd_copied is initial.
      if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' ).
        if not zmm_cdhd_st-reqno is initial.
          perform lock_reqhd.
        endif.
      endif.

      select single * from ZMM_CDHD
          into corresponding fields of ZMM_CDHD_ST
           where REQNO = zmm_cdhd_st-reqno.
*       move ZMM_CDHD-status to app_fl2.
      if sy-subrc = 0.
        g_hd_copied = 'X'.
*        If g_user = ''.
           Perform Change_restrict.
*        Else.
*          Perform CHANGE_MRP.
*        Endif.
        Perform Change_Rel.  "using l_cdhd.
        If g_mode = 'APR'.
          Perform REL_APR_STATUS.
        Endif.
      Endif.
    Endif.
  ELSE.
    if sy-tcode = 'ZCODG' and g_hd_copied is initial.
      select single * from ZMM_CDHD
          into corresponding fields of ZMM_CDHD_ST
           where REQNO = zmm_cdhd_st-reqno.
      if sy-subrc = 0.
        g_hd_copied = 'X'.
      endif.
    endif.
  ENDIF.
  set parameter id 'ZMAT_TY' field zmm_cdhd_st-mtart.
  perform get_correspondense.
ENDMODULE.                 " header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_change_col_attr OUTPUT.
  Case g_mode.
    When 'CRE' OR 'CHA'.
      loop at screen.
        if screen-name = 'FILTER' or
           screen-name = 'SORTU' or
           screen-name = 'SORTD'.
          screen-input = 0.
          modify screen.
        endif.
*      if screen-name = 'ZMM_CDITEM-DESCFIN'.
        if screen-name = 'ZMM_CDITEM-COMP_FLG'.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL' OR 'REL'.
      loop at screen.
        if ( screen-name <> 'ZMM_CDITEM-REQ_LT' ).
          screen-input = 0.
          modify screen.
        endif.
        if g_mode = 'DIS' OR g_mode = 'REL'.
          if screen-name = 'FILTER' OR
             screen-name = 'SORTU'  OR
             screen-name = 'SORTD'.
            screen-input = 1.
            modify screen.
          endif.
        endif.
      endloop.
    When 'APR'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-COMP_FLG' OR
           screen-name = 'ZMM_CDITEM-REQ_LT'  OR
           screen-name = 'SORTU'  OR
           screen-name = 'SORTD'.
          screen-input  = 1.
          modify screen.
        else.
          screen-input  = 0.
          modify screen.
        endif.
      endloop.
  Endcase.

  IF sy-tcode = 'ZCODG'.
   loop at screen.
    if screen-name = 'TABCTRL110_DELETE'.
       screen-input = 0.
       modify screen.
    elseif screen-name = 'TABLCTRL120_DELETE'.
        screen-input = 0.
       modify screen.
    elseif screen-name = 'TABLCTRL130_DELETE'.
        screen-input = 0.
       modify screen.
    elseif screen-name = 'TABLCTRL140_DELETE'.
        screen-input = 0.
       modify screen.
    endif.
   endloop.
  ENDIF.

ENDMODULE.                 " TABCTRL110_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_change_field_attr OUTPUT.
*   get parameter id 'ZMATGP' field g_matgp.

*   g_TABCTRL110_wa-matgp = g_matgp.

  SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
 WHERE DESC1 = G_TABCTRL110_WA-DESC1
 AND MATGRP = G_TABCTRL110_WA-MATGP
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc <> 0.
    g_parno = '1'.
  endif.

  if sy-subrc = 0.

    if  zmm_modifier-desc2 is initial.
      g_parno = '1'.
    elseif  zmm_modifier-desc3 is initial.
      g_parno = '2'.
    elseif  zmm_modifier-desc4 is initial.
      g_parno = '3'.
    else.
      g_parno = '4'.
    endif.

  endif.


  case 'X'.

    when ZMM_CDITEM-OTH1.
*      if g_other <> 'X'.
*         clear: ZMM_CDITEM-OTH2, ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
*      endif.
      g_parno = '1'.
    when ZMM_CDITEM-OTH2.
*      if g_other <> 'X'.
*        clear: ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
*      endif.
      g_parno = '2'.
    when ZMM_CDITEM-OTH3.
*      if g_other <> 'X'.
*          clear: ZMM_CDITEM-OTH4.
*      endif.
      g_parno = '3'.
    when ZMM_CDITEM-OTH4.
      g_parno = '4'.
  endcase.
*
  loop at screen.
    case g_parno.
     when '0'.
        if screen-name = 'ZMM_CDITEM-DESC1'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
     when '5'.
        if screen-name = 'ZMM_CDITEM-DESC1'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
     when '1'.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
     when '2'.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
     when '3'.
        if screen-name = 'ZMM_CDITEM-DESC4' .
          screen-input = 0.
          modify screen.
        endif.
     when '4'.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 1.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 1.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 1.
          modify screen.
        endif.
    endcase.
  endloop.


  Case g_mode.
    When 'CRE' OR 'CHA'.
      loop at screen.
*      if screen-name = 'ZMM_CDITEM-DESC_FIN'.
        if screen-name = 'ZMM_CDITEM-COMP_FLG'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABCTRL110_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
        case g_parno.
          when '5'.
            if screen-name = 'ZMM_CDITEM-DESC1'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
          when '1'.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
*Addition ***** ****************************************
            IF not g_TABCTRL110_wa-desc1 is initial.
              IF screen-name = 'ZMM_CDITEM-UOM'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*End*********** ****************************************

          when '2'.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.

            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
*Addition ***** *****************************************
            IF screen-name = 'ZMM_CDITEM-DESC2'.
              screen-required = 1.
              modify screen.
            ENDIF.

            IF not g_TABCTRL110_wa-desc2 is initial.
              IF screen-name = 'ZMM_CDITEM-UOM'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*End*********** *****************************************

          when '3'.
            if screen-name = 'ZMM_CDITEM-DESC4' .
              screen-input = 0.
              modify screen.
            endif.
*Addition ***** *****************************************
            IF screen-name = 'ZMM_CDITEM-DESC2'.
              screen-required = 1.
              modify screen.
            ENDIF.
            IF not g_TABCTRL110_wa-desc2 is initial.
              IF screen-name = 'ZMM_CDITEM-DESC3'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
            IF not g_TABCTRL110_wa-desc3 is initial.
              IF screen-name = 'ZMM_CDITEM-UOM'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*End*********** *****************************************
          when '4'.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 1.
              screen-required = 1.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 1.
              modify screen.
            endif.
*Addition ***** ****************************************
            IF not g_TABCTRL110_wa-desc2 is initial.
              IF screen-name = 'ZMM_CDITEM-DESC3'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*End*********** *****************************************
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 1.
              modify screen.
            endif.
*Addition ***** *****************************************
            IF not g_TABCTRL110_wa-desc3 is initial.
              IF screen-name = 'ZMM_CDITEM-DESC4'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
            IF not g_TABCTRL110_wa-desc4 is initial.
              IF screen-name = 'ZMM_CDITEM-UOM'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*End*********** *****************************************
        endcase.
*Addition ***** ****************************************
        if not g_tabctrl110_wa-matcode is initial.
          if screen-group4 = 'MC'.
            screen-input = 0.
            modify screen.
          endif.
        endif.
*End*********** ****************************************
        if screen-name = 'ZMM_CDITEM-REJ_FLG'.
         screen-input = 0.
         modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL' OR
         'REL' .
      loop at screen.
        if screen-name = 'ZMM_CDITEM-REQ_LT' OR
           screen-name = 'PB_ADNL_DESC'.
           screen-input = 1.
           modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
    WHEN 'APR'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-REQ_LT' OR
           Screen-name = 'ZMM_CDITEM-COMP_FLG' OR
           screen-name = 'ZMM_CDITEM-REJ_FLG'.
          screen-input = 1.
          modify screen.
        else.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
  Endcase.
  perform tcode_zcodg_attr.

ENDMODULE.                 " TABCTRL110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0115  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0115 OUTPUT.
*clear sy-ucomm.
*clear g_ok_code115.
*
  if sy-ucomm <> ''.
     g_ok_code110 = sy-ucomm.
  endif.
  clear sy-ucomm.
  export g_tabctrl110_wa-oth1 to memory id 'OTH1'.
   select single WGBEZ from T023T into g_matgp_desc where MATKL =
   g_matgp and spras = sy-langu.

*concatenate g_tabctrl110_wa-oth1 g_tabctrl110_wa-oth2
*g_tabctrl110_wa-oth3 g_tabctrl110_wa-oth4 into g_oth.
  set pf-status 'STAT115'.
***********Below part Commented****************************
***********Added in other module***************************
*  IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
*     g_desc1 = g_tabctrl110_wa-desc1.
*     g_desc2 = g_tabctrl110_wa-desc2.
*     g_desc3 = g_tabctrl110_wa-desc3.
*     g_desc4 = g_tabctrl110_wa-desc4.
*     g_matgp = g_tabctrl110_wa-matgp.
*     concatenate g_desc1 g_desc2
*                 g_desc3 g_desc4 into g_desc1_4
*                 separated by space.
*     user_desc_len = 87 - strlen( g_desc1_4 ).
*
**    If g_tabctrl110_wa-User_desc <> ''.
**      If g_user_desc = ''.
**        g_user_desc = g_tabctrl110_wa-User_desc.
**      else.
**      Endif.
**    Endif.

**    If g_tabctrl110_wa-User_desc <> g_user_desc.
**    Else.
**        g_user_desc = g_tabctrl110_wa-User_desc.
**    Endif.
*    If g_ok_code110 = 'PB_AD'.
*      g_user_desc = g_tabctrl110_wa-User_desc.
*    Endif.
*
*    loop at screen.
*      If screen-name = 'G_USER_DESC'.
*        screen-length = user_desc_len.
*        screen-input = 1.
*        modify screen.
*      Elseif screen-name = 'OK' or
*             screen-name = 'CANC'.
*        screen-input = 1.
*        modify screen.
*      Else.
*        screen-input = 0.
*        modify screen.
*      Endif.
***
*      If g_mode = 'DIS' or g_mode = 'REL' or g_mode = 'APR'.
*        If screen-group1 = 'G1'.
*          screen-input = 0.
*          modify screen.
*        Endif.
*      Endif.
***
*    Endloop.
*
*  Else.  "g_ok_code <> 'PB_AD'
*    concatenate g_desc1 g_desc2
*                g_desc3 g_desc4
*                into g_desc1_4
*                separated by space.
*
*    user_desc_len = 87 - strlen( g_desc1_4 ).
*    If G_screen115_1st is initial.
*
*      If g_mode <> 'CHA'.
*        clear g_user_desc.
*      Endif.
*
*      Case 'OTHER'.
*        when g_tabctrl110_wa-desc1.
*          If g_desc1 = 'OTHER'.
*            g_desc1 = ''.
*          Endif.
*          If g_matgp = 'XX'.
*            g_matgp = ''.
*          Endif.
*          Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
*        when g_tabctrl110_wa-desc2.
*          g_desc1 = g_tabctrl110_wa-desc1.
**        g_desc2 = ''.
**        g_desc3 = ''.
**        g_desc4 = ''.
*
*          loop at screen.
*            if screen-name = 'G_DESC1' or
*               screen-name = 'G_USER_DESC' or
*               screen-name = 'G_MATGP'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*        when g_tabctrl110_wa-desc3.
*          g_desc1 = g_tabctrl110_wa-desc1.
*          g_desc2 = g_tabctrl110_wa-desc2.
**          g_desc3 = ''.
**          g_desc4 = ''.
*
*          loop at screen.
*            if screen-name = 'G_DESC1' or
*               screen-name = 'G_DESC2' or
*               screen-name = 'G_USER_DESC' or
*               screen-name = 'G_MATGP'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*        when g_tabctrl110_wa-desc4.
*          g_desc1 = g_tabctrl110_wa-desc1.
*          g_desc2 = g_tabctrl110_wa-desc2.
*          g_desc3 = g_tabctrl110_wa-desc3.
**          g_desc4 = ''.
*
*          loop at screen.
*            if screen-name = 'G_DESC1' or
*               screen-name = 'G_DESC2' or
*               screen-name = 'G_DESC3' or
*               screen-name = 'G_MATGP' or
*               screen-name = 'G_USER_DESC'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*      Endcase.
*
*      loop at screen.
*        if screen-name = 'G_USER_DESC' and sy-ucomm = 'PB_AD'.
*          screen-length = 40.
*          screen-input = 1.
*          modify screen.
*        endif.
*      Endloop.
*    Else.
*      loop at screen.
*        if screen-name = 'G_USER_DESC'.
*          screen-length = user_desc_len.
*          screen-input = 1.
*          modify screen.
*        Elseif screen-name = 'G_MATGP'.
*          screen-input = 0.
*          modify screen.
*        endif.
*
**        If g_spellerror = 'X'.
**          if  screen-name = 'G_DESC1' or
**              screen-name = 'G_DESC2' or
**              screen-name = 'G_DESC3' or
**              screen-name = 'G_DESC4' .
**            screen-input = 1.
**            modify screen.
**          Endif.
**
**        Else.
**          if screen-name = 'G_DESC1' or
**             screen-name = 'G_DESC2' or
**             screen-name = 'G_DESC3' or
**             screen-name = 'G_DESC4' .
**            screen-input = 0.
**            modify screen.
**          Endif.
**        Endif.
*        if screen-name = 'ADNL_DESC'.
*          screen-input = 0.
*          modify screen.
*        Endif.
**    If g_tabctrl110_wa-desc1 <> 'OTHER'.
**       if screen-name = zmm_cditem-matgp.
**          screen-input = 0.
**       Endif.
**    Endif.
*      Endloop.
*    Endif.
*  Endif.
**clear g_ok_code110.

*********Comment End *************************************************
***********************************************************************
ENDMODULE.                 " STATUS_0115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ist_alphanum  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ist_alphanum OUTPUT.
  g_lineno = '1'.
  if check_flag = 'X'.
    EXIT.
  endif.
  check_flag = 'X'.
  Data : l_num type i.
  do 10 times.
    wa_alphanum = l_num.
    append wa_alphanum to ist_alphanum.
    l_num = l_num + 1.
  enddo.
  clear l_num.
  do 26 times.
    wa_alphanum = alpha+l_num(1).
*translate wa_alphanum to upper case.
    append wa_alphanum to ist_alphanum.
    l_num = l_num + 1.
  enddo.
ENDMODULE.                 " ist_alphanum  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_set_arrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_set_arrib OUTPUT.

  loop at screen.
    if screen-name = 'DD' and ( wa_srchlp-mark = '1'
                              or wa_srchlp-matnr is initial ) .
      screen-invisible = '1'.
      modify screen.
    endif.
  endloop.

ENDMODULE.                 " TABCTRL100_set_arrib  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CONTROL_VORBEREITEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CONTROL_VORBEREITEN OUTPUT.

  if gv_splitter is initial.
    create object gv_custom_container
                  exporting container_name = 'C_CTRL_MAT_SPECS'
                  .

    create object gv_splitter
           exporting
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  endif.

ENDMODULE.                 " SPLITTER_CONTROL_VORBEREITEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TEXT_CONTROL_VORBEREITEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CONTROL_VORBEREITEN OUTPUT.

  if gv_text_editor is initial.
    create object gv_text_editor
       exporting
            parent = gv_splitter->bottom_right_container
            wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
            wordwrap_to_linebreak_mode = cl_gui_textedit=>false
       exceptions
            error_cntl_create      = 1
            error_cntl_init        = 2
            error_cntl_link        = 3
            error_dp_create        = 4
            gui_type_not_supported = 5.
  endif.

  perform text_control_eingabebereit.
  perform text_control_set_text_table.

ENDMODULE.                 " TEXT_CONTROL_VORBEREITEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0117  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0117 OUTPUT.
  SET PF-STATUS SPACE.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0117  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL120_change_field_attr OUTPUT.

*   get parameter id 'ZMATGP' field g_matgp.

*   g_TABCTRL110_wa-matgp = g_matgp.

  SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
 WHERE DESC1 =
 G_TABLCTRL120_WA-DESC1
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  if sy-subrc <> 0.
    g_parno = '1'.
  endif.

  if sy-subrc = 0.

    if  zmm_modifier-desc2 is initial.
      g_parno = '1'.
    elseif  zmm_modifier-desc3 is initial.
      g_parno = '2'.
    elseif  zmm_modifier-desc4 is initial.
      g_parno = '3'.
    else.
      g_parno = '4'.
    endif.

  endif.


  case 'X'.

    when ZMM_CDITEM-OTH1.
      clear: ZMM_CDITEM-OTH2, ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
      g_parno = '1'.
    when ZMM_CDITEM-OTH2.
      clear: ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
      g_parno = '2'.
    when ZMM_CDITEM-OTH3.
      clear: ZMM_CDITEM-OTH4.
      g_parno = '3'.
    when ZMM_CDITEM-OTH4.
      g_parno = '4'.

  endcase.
*
  loop at screen.
    case g_parno.
      when '0'.
        if screen-name = 'ZMM_CDITEM-DESC1'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
      when '5'.
        if screen-name = 'ZMM_CDITEM-DESC1'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_CDITEM-USER_DESC'.
          screen-input = 1.
          modify screen.
        endif.

      when '1'.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-USER_DESC'.
          screen-input = 1.
          modify screen.
        endif.
      when '2'.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-USER_DESC'.
          screen-input = 1.
          modify screen.
        endif.
      when '3'.
        if screen-name = 'ZMM_CDITEM-DESC4' .
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-USER_DESC'.
          screen-input = 1.
          modify screen.
        endif.
      when '4'.
        if screen-name = 'ZMM_CDITEM-DESC2'.
          screen-input = 1.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC3'.
          screen-input = 1.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-DESC4'.
          screen-input = 1.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-USER_DESC'.
          screen-input = 1.
          modify screen.
        endif.
    endcase.
  endloop.


  Case g_mode.
    When 'CRE'.
      loop at screen.
        if Not g_TABLCTRL120_wa-partno IS INITIAL .
           if screen-name = 'ZMM_CDITEM-DESC_FIN' or
              screen-name = 'ZMM_CDITEM-UOM'      or
              screen-name = 'ZMM_CDITEM-CAP_CODE'.
              screen-required = 1.
              modify screen.
           endif.
         else.
           if screen-name = 'ZMM_CDITEM-DESC_FIN' or
              screen-name = 'ZMM_CDITEM-UOM'      or
              screen-name = 'ZMM_CDITEM-CAP_CODE'.
              screen-input = 0.
              modify screen.
           endif.
        endif.
****
        if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
           if screen-name = 'ZMM_CDITEM-MDLNO'    or
              screen-name = 'ZMM_CDITEM-MANU'.
              screen-required = 1.
              modify screen.
           endif.
        else.
           if screen-name = 'ZMM_CDITEM-MDLNO'    or
              screen-name = 'ZMM_CDITEM-MANU'.
              screen-input = 0.
              modify screen.
           endif.
        endif.
****
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL120_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
****
        if screen-name = 'ZMM_CDITEM-REJ_FLG'.
         screen-input = 0.
         modify screen.
        endif.
****
        case g_parno.

          when '5'.

            if screen-name = 'ZMM_CDITEM-DESC1'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-USER_DESC'.
              screen-input = 1.
              modify screen.
            endif.

          when '1'.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
          when '2'.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
          when '3'.
            if screen-name = 'ZMM_CDITEM-DESC4' .
              screen-input = 0.
              modify screen.
            endif.
          when '4'.
            if screen-name = 'ZMM_CDITEM-DESC2'.
              screen-input = 1.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 1.
              modify screen.
            endif.
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 1.
              modify screen.
            endif.
        endcase.
      endloop.
    When 'CHA'.
      loop at screen.
        if Not g_TABLCTRL120_wa-partno IS INITIAL .
           if screen-name = 'ZMM_CDITEM-DESC_FIN' or
              screen-name = 'ZMM_CDITEM-UOM'      or
              screen-name = 'ZMM_CDITEM-CAP_CODE'.
              screen-required = 1.
              modify screen.
           endif.
         else.
           if screen-name = 'ZMM_CDITEM-DESC_FIN' or
              screen-name = 'ZMM_CDITEM-UOM'      or
              screen-name = 'ZMM_CDITEM-CAP_CODE'.
              screen-input = 0.
              modify screen.
           endif.
        endif.
****
        if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
           if screen-name = 'ZMM_CDITEM-MDLNO'    or
              screen-name = 'ZMM_CDITEM-MANU'.
              screen-required = 1.
              modify screen.
           endif.
        else.
           if screen-name = 'ZMM_CDITEM-MDLNO'    or
              screen-name = 'ZMM_CDITEM-MANU'.
              screen-input = 0.
              modify screen.
           endif.
        endif.
****

        if screen-name = 'ZMM_CDITEM-REJ_FLG'.
         screen-input = 0.
         modify screen.
        endif.

        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL120_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL' OR 'REL'.
      loop at screen.
        if screen-name <> 'ZMM_CDITEM-REQ_LT'.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
  Endcase.
  perform tcode_zcodg_attr.

ENDMODULE.                 " TABLCTRL120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL130_change_field_attr OUTPUT.
  Case g_mode.
    When 'CRE'.
      Loop at screen.
        If g_TABLCTRL130_wa-DESC_FIN is initial.
          if screen-name = 'ZMM_CDITEM-REJ_FLG' or
             screen-name = 'ZMM_CDITEM-MATCOST' or
             screen-name = 'ZMM_CDITEM-MATCATG' OR
             screen-name = 'ZMM_CDITEM-MATLOC' or
             screen-name = 'ZMM_CDITEM-WRKNG_LIFE' or
             screen-name = 'ZMM_CDITEM-SPA_GRP'.
             screen-input = 0.
             modify screen.
          endif.
        Else.
          If screen-name = 'ZMM_CDITEM-MATCOST' OR
             screen-name = 'ZMM_CDITEM-MATCATG' OR
             screen-name = 'ZMM_CDITEM-MATLOC'  OR
             screen-name = 'ZMM_CDITEM-WRKNG_LIFE' .
             screen-required = 1.
             modify screen.
          endif.
        Endif.
        if screen-name = 'ZMM_CDITEM-REJ_FLG' or
           screen-name = 'ZMM_CDITEM-SPA_GRP'.
          screen-input = 0.
          modify screen.
        endif.

        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF zmm_cditem-desc_fin is initial.
*          IF g_TABLCTRL130_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
      Endloop.
      set cursor field 'ZMM_CDITEM-MATCOST'.
    When 'CHA'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL130_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-SPA_GRP' OR
           screen-name = 'ZMM_CDITEM-REJ_FLG'.
           screen-input = 0.
           modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL'.
      loop at screen.
        if screen-name <> 'ZMM_CDITEM-REQ_LT'.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
  Endcase.
  perform tcode_zcodg_attr.
  If sy-tcode = 'ZCODG'.
     loop at screen.
        if screen-name = 'ZMM_CDITEM-SPA_GRP'.
           screen-input = 1.
           screen-required = 1.
           modify screen.
        endif.
     endloop.
  Endif.
ENDMODULE.                 " TABLCTRL130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL140_change_field_attr OUTPUT.
  Case g_mode.
    When 'CRE'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-DESC_FIN'.
          screen-input = 0.
          modify screen.
        endif.
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL140_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
      endloop.
    When 'CHA'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL140_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL'.
      loop at screen.
        if screen-name <> 'ZMM_CDITEM-REQ_LT'.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
  Endcase.

ENDMODULE.                 " TABLCTRL140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0105 OUTPUT.
  SET PF-STATUS 'STAT105'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CTRL_VORBEREITEN OUTPUT.
  if gv_splitter1 is initial.
    create object gv_custom_container
                  exporting container_name = 'C_DIS'.


    create object gv_splitter1
           exporting
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.
  endif.
  if gv_splitter2 is initial.

    create object gv_custom_container
                  exporting container_name = 'C_WRT'.


    create object gv_splitter2
           exporting
                  parent = gv_custom_container
                  orientation = 1
                  sash_position = 1.

  endif.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_VORBEREITEN OUTPUT.
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
  endif.
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
  endif.

  perform text_control_eingabebereit.
  perform text_control_set_text_table.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN OUTPUT
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

  if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
     ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.

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
  endif.
  if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
     ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.

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
    endif.
  endif.

  perform text_control_eingabebereit1.
  perform text_control_set_text_table1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  spell_ins_modi  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE spell_ins_modi OUTPUT.
*if g_user <> 'X'.
*loop at screen.
*If screen-name = 'SPELL' or
*   screen-name = 'INS_MODIFIERS'.
*   screen-input = 0.
*   modify screen.
*Endif.
*Endloop.
*Endif.
ENDMODULE.                 " spell_ins_modi  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZE OUTPUT.
  perform get_correspondense.
ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_mattytext  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_mattytext OUTPUT.
  Select single ddtext into g_mattytext from dd07t
         where domname    = 'ZMATTY'
         and   ddlanguage = sy-langu
         and   DOMVALUE_L = zmm_cdhd_st-mtart.
  if sy-subrc <> 0.
    g_mattytext = ''.
  endif.
***Plant Description
  Select single name1 into g_plantdesc from t001w
         where werks = zmm_cdhd_st-werks.
  if sy-subrc <> 0.
    g_plantdesc = ''.
  endif.
***Location Description
  Select single bldg into g_locdesc from zlocmst
         where locid = zmm_cdhd_st-reqloc.
  if sy-subrc <> 0.
    g_locdesc = ''.
  endif.
ENDMODULE.                 " get_mattytext  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_MESSAGES OUTPUT.

  suppress dialog.

  Leave to list-processing and return to screen 0.

  if g_long_text_warning <> 'X'.

    wa_message-srno = '000'.
    wa_message-msgtype = 'W'.
    wa_message-msgcode = 'C'.
wa_message-msgtext = 'Detailed specifications can be entered if'
 &'required.'.
    append wa_message to ist_message.
    wa_message-srno = '   '.
    wa_message-msgtype = 'W'.
    wa_message-msgcode = 'C'.
wa_message-msgtext = 'The same will get defaulted in the PR/PO documents '.
    append wa_message to ist_message.
    clear  g_long_text_warning.

  endif.

  SET PF-STATUS SPACE.

  loop at ist_message into wa_message.
    if  wa_message-srno <> '   '.
      skip.
    endif.
    write: wa_message-srno, '|', wa_message-msgtype, '|',
wa_message-msgtext.
  endloop.

ENDMODULE.                 " WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_check  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_check OUTPUT.

*if sy-ucomm = 'CHECK'.
  if check_code = 'CHECK'.
    loop at g_TABCTRL110_itab into g_TABCTRL110_wa.

      if g_TABCTRL110_wa-mat_fnd > 0.

        wa_message-srno = g_TABCTRL110_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'There is a list of material codes available as per selection.'.
        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.

        append wa_message to ist_message.


        wa_message-srno = g_TABCTRL110_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'Have you checked the detailed speifications(if any)'.

        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'in the  materials  list  appearing  in  the search help?'.

        append wa_message to ist_message.

      endif.

      clear wa_message.
    endloop.
*   Perform spell_check1.
*   if g_spellerror = 'X'.
*
*      wa_message-msgtype = 'W'.
*      wa_message-srno    = '000'.
*      wa_message-msgcode = 'S'.
*      wa_message-msgtext = 'Spelling  Errors'.
*      append wa_message to ist_message.
*   Endif.

    describe table g_TABCTRL110_itab lines check_lines.

    if check_lines > 0.

      Call Screen 102 starting at 10 05 ending at 100 15.

    else.

      message i028(zmm_oth).

    endif.

    clear : g_TABCTRL110_wa-dsflag,  g_long_text_warning .

  endif.

ENDMODULE.                 " TABCTRL110_check  OUTPUT
*_______________________________________________________________________
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_change_col_attr OUTPUT.

  if ZMM_CDHD_ST-MTART = 'ZSTO' OR ZMM_CDHD_ST-MTART = 'ZCAP'.
    LOOP AT TABCTRL100-cols INTO cols WHERE index GT 5.
      cols-invisible = '1'.
      if cols-screen-name = 'WA_SRCHLP-MAKTX'.
        cols-vislength = '65'.
      Endif.
      MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
    ENDLOOP.
  Elseif ZMM_CDHD_ST-MTART = 'ZSPR'.
    LOOP AT TABCTRL100-cols INTO cols.
      if cols-screen-name = 'WA_SRCHLP-MAKTX'.
        cols-vislength = '40'.
        MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
      Endif.
    ENDLOOP.
  endif.

ENDMODULE.                 " TABCTRL100_change_col_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.
*  SET PF-STATUS SPACE.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0103 OUTPUT.
  SET PF-STATUS 'STAT_REL'.

ENDMODULE.                 " STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_CERTI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_CERTI OUTPUT.
*+060505
  SUPPRESS DIALOG.
  SET PF-STATUS 'STAT_REL'.

  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
Case g_mode .
  When 'REL'.
    If ( g_user = 'M' or g_user = 'L' or zmm_cdhd_st-reqcpf = sy-uname )
.
    Write : / '                   Acknowledgement        '
            Color 3.
    Write : / '-----------------------------------------------------'.
    write : / 'The details in the request have been checked and'.
    Write : / 'confirmed. Please process the request for generation'.
    write : / 'of new Material Code.'.
  Else.
      Message i042(zmm_oth).
      leave to screen 0.
  Endif.

 When 'APR' .
  If  g_user = 'M'.
  Write : / '                   Acknowledgement                       '
           Color 5.
    Write : / '-----------------------------------------------------'.
    write : / 'The details in the request have been rechecked and'.
    Write : / 'confirmed. Please process the request for generation'.
    write : / 'of new Material Code.'.
  Else.
    message i043(zmm_oth).
    leave to screen 0.
  Endif.
Endcase.

ENDMODULE.                 " WRITE_CERTI  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0150 OUTPUT.
  SET PF-STATUS 'STATUS150'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0150  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_sh_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_sh_attr OUTPUT.
 case zmm_cdhd_st-mtart.
     when 'ZSTO' or 'ZCAP' or 'ZDIS'.
       loop at screen.
        if screen-group2 = 'SH'.
         screen-invisible = 1.
         modify screen.
        endif.
       endloop.
 endcase.
ENDMODULE.                 " scr100_sh_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Set_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Set_attrib OUTPUT.

************************************************************************
Case G_MODE.
  When 'DIS' OR 'DEL' OR 'REL' OR 'APR'.
    IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
     g_desc1 = g_tabctrl110_wa-desc1.
     g_desc2 = g_tabctrl110_wa-desc2.
     g_desc3 = g_tabctrl110_wa-desc3.
     g_desc4 = g_tabctrl110_wa-desc4.
     IF g_tabctrl110_wa-matgp <> 'XX'.
      g_matgp = g_tabctrl110_wa-matgp.
     ENDIF.
     g_user_desc = g_tabctrl110_wa-user_desc.
     concatenate g_desc1 g_desc2
                 g_desc3 g_desc4 into g_desc1_4
                 separated by space.
     user_desc_len = 87 - strlen( g_desc1_4 ).
     Loop at screen.
       If screen-group1 = 'G1'.
          screen-input = 0.
          modify screen.
        Endif.
        IF screen-name = 'G_USER_DESC'.
          screen-length = user_desc_len.
          modify screen.
        ENDIF.
     Endloop.
    ENDIF.
  WHEN 'CRE' OR 'CHA'.
    concatenate g_desc1 g_desc2
                g_desc3 g_desc4
                into g_desc1_4
                separated by space.

    user_desc_len = 87 - strlen( g_desc1_4 ).

*    If G_screen115_1st is initial.
     Case 'OTHER'.
        when g_tabctrl110_wa-desc1.
          If g_desc1 = 'OTHER'.
            g_desc1 = ''.
          Endif.
          If g_matgp = 'XX'.
            g_matgp = ''.
          Endif.
          Loop at screen.
            If screen-name = 'G_USER_DESC'.
               screen-input = 0.
               screen-length = 40.
              modify screen.
            Endif.
          Endloop.
** User enter material group in the screen 115, if 'OTHER'
** is selected in the main attribute
          Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
**
        when g_tabctrl110_wa-desc2.
          g_desc1 = g_tabctrl110_wa-desc1.
          Loop at screen.
            If screen-name = 'G_DESC1' or
               screen-name = 'G_USER_DESC' or
               screen-name = 'G_MATGP'.
              screen-input = 0.
              modify screen.
            Endif.
          Endloop.

        when g_tabctrl110_wa-desc3.
          g_desc1 = g_tabctrl110_wa-desc1.
          g_desc2 = g_tabctrl110_wa-desc2.
          Loop at screen.
            If screen-name = 'G_DESC1' or
               screen-name = 'G_DESC2' or
               screen-name = 'G_USER_DESC' or
               screen-name = 'G_MATGP'.
              screen-input = 0.
              modify screen.
            Endif.
          Endloop.

        when g_tabctrl110_wa-desc4.
          g_desc1 = g_tabctrl110_wa-desc1.
          g_desc2 = g_tabctrl110_wa-desc2.
          g_desc3 = g_tabctrl110_wa-desc3.
          loop at screen.
            If screen-name = 'G_DESC1' or
               screen-name = 'G_DESC2' or
               screen-name = 'G_DESC3' or
               screen-name = 'G_MATGP' or
               screen-name = 'G_USER_DESC'.
              screen-input = 0.
              modify screen.
            Endif.
          Endloop.

      Endcase.
****
         Perform other_sectime.
****
     Case g_ok_code115.
      When 'A_DESC'.
       loop at screen.
         if screen-name = 'G_USER_DESC'.
          screen-length = user_desc_len.
          screen-input = 1.
          modify screen.
         endif.
       Endloop.
      ENDCASE.


      IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
         g_desc1 = g_tabctrl110_wa-desc1.
         g_desc2 = g_tabctrl110_wa-desc2.
         g_desc3 = g_tabctrl110_wa-desc3.
         g_desc4 = g_tabctrl110_wa-desc4.
         g_matgp = g_tabctrl110_wa-matgp.
         IF G_screen115_1st is initial.
          g_user_desc = g_tabctrl110_wa-user_desc.
          G_screen115_1st = 'X'.
         ENDIF.
         concatenate g_desc1 g_desc2
                     g_desc3 g_desc4 into g_desc1_4
                     separated by space.
         user_desc_len = 87 - strlen( g_desc1_4 ).
         loop at screen.
           if screen-name = 'G_DESC1' or
              screen-name = 'G_DESC2' or
              screen-name = 'G_DESC3' or
              screen-name = 'G_DESC4' or
              screen-name = 'G_MATGP'.
            screen-input  = 0.
            modify screen.
           elseif screen-name = 'G_USER_DESC'.
            screen-length = user_desc_len.
            screen-input  = 1.
            modify screen.
           endif.
         endloop.
      ENDIF.
Endcase.

IF sy-tcode = 'ZCODG' .
     g_desc1 = g_tabctrl110_wa-desc1.
     g_desc2 = g_tabctrl110_wa-desc2.
     g_desc3 = g_tabctrl110_wa-desc3.
     g_desc4 = g_tabctrl110_wa-desc4.
     IF g_tabctrl110_wa-matgp <> 'XX'.
      g_matgp = g_tabctrl110_wa-matgp.
     ENDIF.
     concatenate g_desc1 g_desc2
                g_desc3 g_desc4
                into g_desc1_4
                separated by space.
     user_desc_len = 87 - strlen( g_desc1_4 ).
     g_user_desc = g_tabctrl110_wa-user_desc.

     IF g_ok_code110 = 'PB_AD'.
       loop at screen.
           if screen-name = 'G_DESC1' or
              screen-name = 'G_DESC2' or
              screen-name = 'G_DESC3' or
              screen-name = 'G_DESC4' or
              screen-name = 'G_MATGP'.
            screen-input  = 0.
            modify screen.
           elseif screen-name = 'G_USER_DESC'.
            screen-length = user_desc_len.
            screen-input  = 1.
            modify screen.
           endif.
       endloop.
     ELSE.
       loop at screen.
         if screen-name = 'G_DESC1'.
           if ZMM_CDITEM-OTH1 = 'X'.
             screen-input = 1.
           else.
             screen-input = 0.
           endif.
             modify screen.
         elseif screen-name = 'G_DESC2'.
           if ZMM_CDITEM-OTH1 = 'X' OR
              ZMM_CDITEM-OTH2 = 'X'.
              screen-input = 1.
           else.
              screen-input = 0.
           endif.
           modify screen.
         elseif screen-name = 'G_DESC3'.
           if ZMM_CDITEM-OTH1 = 'X' OR
              ZMM_CDITEM-OTH2 = 'X' OR
              ZMM_CDITEM-OTH3 = 'X'.
              screen-input = 1.
           else.
              screen-input = 0.
           endif.
              modify screen.
         elseif screen-name = 'G_DESC4'.
           if ZMM_CDITEM-OTH1 = 'X' OR
              ZMM_CDITEM-OTH2 = 'X' OR
              ZMM_CDITEM-OTH3 = 'X' OR
              ZMM_CDITEM-OTH4 = 'X'.
              screen-input = 1.
           else.
              screen-input = 0.
           endif.
           modify screen.
         elseif screen-name = 'G_USER_DESC'.
            screen-length = user_desc_len.
            screen-input  = 0.
            modify screen.
         endif.
        endloop.
     ENDIF.

     Case g_ok_code115.
      When 'A_DESC'.
       loop at screen.
          if  screen-name = 'G_DESC1' or
              screen-name = 'G_DESC2' or
              screen-name = 'G_DESC3' or
              screen-name = 'G_DESC4' or
              screen-name = 'G_MATGP'.
              screen-input  = 0.
            modify screen.
          elseif screen-name = 'G_USER_DESC'.
            screen-length = user_desc_len.
            screen-input = 1.
            modify screen.
         endif.
       Endloop.
      ENDCASE.

Endif.
************************************************************************
*  IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
*     g_desc1 = g_tabctrl110_wa-desc1.
*     g_desc2 = g_tabctrl110_wa-desc2.
*     g_desc3 = g_tabctrl110_wa-desc3.
*     g_desc4 = g_tabctrl110_wa-desc4.
*     g_matgp = g_tabctrl110_wa-matgp.
*
*     concatenate g_desc1 g_desc2
*                 g_desc3 g_desc4 into g_desc1_4
*                 separated by space.
*     user_desc_len = 87 - strlen( g_desc1_4 ).
*
*    If g_ok_code110 = 'PB_AD'.
*      g_user_desc = g_tabctrl110_wa-User_desc.
*    Endif.
*
*    loop at screen.
*      If screen-name = 'G_USER_DESC'.
*        screen-length = user_desc_len.
*        screen-input = 1.
*        modify screen.
*      Elseif screen-name = 'OK' or
*             screen-name = 'CANC'.
*        screen-input = 1.
*        modify screen.
*      Else.
*        screen-input = 0.
*        modify screen.
*      Endif.
***
*      If g_mode = 'DIS' or g_mode = 'REL' or g_mode = 'APR'.
*        If screen-group1 = 'G1'.
*          screen-input = 0.
*          modify screen.
*        Endif.
*      Endif.
***
*    Endloop.
*
*  Else.  "g_ok_code <> 'PB_AD'
*    concatenate g_desc1 g_desc2
*                g_desc3 g_desc4
*                into g_desc1_4
*                separated by space.
*
*    user_desc_len = 87 - strlen( g_desc1_4 ).
*    If G_screen115_1st is initial.
*
*      If g_mode <> 'CHA'.
*        clear g_user_desc.
*      Endif.
*
*      Case 'OTHER'.
*        when g_tabctrl110_wa-desc1.
*          If g_desc1 = 'OTHER'.
*            g_desc1 = ''.
*          Endif.
*          If g_matgp = 'XX'.
*            g_matgp = ''.
*          Endif.
*          Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
*        when g_tabctrl110_wa-desc2.
*          g_desc1 = g_tabctrl110_wa-desc1.
*          Loop at screen.
*            If screen-name = 'G_DESC1' or
*               screen-name = 'G_USER_DESC' or
*               screen-name = 'G_MATGP'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*        when g_tabctrl110_wa-desc3.
*          g_desc1 = g_tabctrl110_wa-desc1.
*          g_desc2 = g_tabctrl110_wa-desc2.
*          loop at screen.
*            if screen-name = 'G_DESC1' or
*               screen-name = 'G_DESC2' or
*               screen-name = 'G_USER_DESC' or
*               screen-name = 'G_MATGP'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*        when g_tabctrl110_wa-desc4.
*          g_desc1 = g_tabctrl110_wa-desc1.
*          g_desc2 = g_tabctrl110_wa-desc2.
*          g_desc3 = g_tabctrl110_wa-desc3.
*          loop at screen.
*            if screen-name = 'G_DESC1' or
*               screen-name = 'G_DESC2' or
*               screen-name = 'G_DESC3' or
*               screen-name = 'G_MATGP' or
*               screen-name = 'G_USER_DESC'.
*              screen-input = 0.
*              modify screen.
*            Endif.
*          Endloop.
*
*      Endcase.
*
*      loop at screen.
*        if screen-name = 'G_USER_DESC' and sy-ucomm = 'PB_AD'.
*          screen-length = 40.
*          screen-input = 1.
*          modify screen.
*        endif.
*      Endloop.
*    Else.
*      loop at screen.
*        if screen-name = 'G_USER_DESC'.
*          screen-length = user_desc_len.
*          screen-input = 1.
*          modify screen.
*        Elseif screen-name = 'G_MATGP'.
*          screen-input = 0.
*          modify screen.
*        endif.
*        if screen-name = 'ADNL_DESC'.
*          screen-input = 0.
*          modify screen.
*        Endif.
*      Endloop.
*    Endif.
*  Endif.
**clear g_ok_code110.

ENDMODULE.                 " Set_attrib  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  get_coddesc  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_coddesc OUTPUT.
if not zmm_cditem-cap_code is initial.
 SELECT MAKTX INTO ZMM_CDITEM-CAP_NAME FROM MAKT UP TO 1 ROWS
 WHERE MATNR = ZMM_CDITEM-CAP_CODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
 if sy-subrc <> 0.
*    message e041(zmm_oth) with zmm_cditem-cap_code.
     zmm_cditem-cap_name = ''.
 Endif.
Endif.
ENDMODULE.                 " get_coddesc  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL120_check  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL120_check OUTPUT.
clear g_mat_fnd.
if check_code = 'CHECK'.
    loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.

      if g_TABLCTRL120_wa-mat_fnd > 0.

        wa_message-srno = g_TABLCTRL120_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'There is a list of material codes available as per selection.'.
        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.

        append wa_message to ist_message.


        wa_message-srno = g_TABLCTRL120_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'Have you checked the detailed speifications(if any)'.

        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'in the  materials  list  appearing  in  the search help?'.

        append wa_message to ist_message.

      endif.

      clear wa_message.
    endloop.

    describe table g_TABLCTRL120_itab lines check_lines.

    if check_lines > 0.

      Call Screen 102 starting at 10 05 ending at 100 15.

    else.

      message i028(zmm_oth).

    endif.

    clear : g_TABLCTRL120_wa-dsflag,  g_long_text_warning .

  endif.

ENDMODULE.                 " TABCTRL120_check  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0116 OUTPUT.
  SET PF-STATUS 'STAT115'.
ENDMODULE.                 " STATUS_0116  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  loopat_matty_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  get_srchitab  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_srchitab OUTPUT.
IF zmm_cdhd_st-mtart = 'ZSPR'.
 If NOT g_fst_srchlp IS INITIAL.
  IF g_sh_capeqt  = '' and
     g_sh_mfr     = '' and
     g_sh_mdlno   = ''.
     ist_srchlp = ist_srchlp_cpo.
  ELSE.
     ist_srchlp = ist_srchlp_cp.
  ENDIF.
 Else.
  append lines of ist_srchlp to ist_srchlp_cpo.
  If FIELD1 = 'ZMM_CDITEM-PARTNO' .
   g_fst_srchlp = 'X'.
  ENDIF.
 Endif.
* g_fst_srchlp = 'X'.
ENDIF.
ENDMODULE.                 " get_srchitab  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Modelno_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Modelno_LIST OUTPUT.
 SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  SET PF-STATUS SPACE.
  NEW-PAGE NO-TITLE.
  sort ist_modifier_check_list by matgrp desc1.
  if ZMM_CDHD_ST-MTART = 'ZSTO'.
           WRITE : / 'Select group :' .
        ULINE.
        Loop at ist_modifier_check_list .
           WRITE: / ist_modifier_check_list-matgrp,
                     ist_modifier_check_list-desc1 COLOR COL_POSITIVE
INTENSIFIED OFF .
           HIDE ist_modifier_check_list-matgrp.
        Endloop.
  else.
        WRITE : / 'List of Models similar to :' , ist_sval_org COLOR
      col_total.
        ULINE.
        Loop at ist_mdl.
           WRITE: / ist_mdl-mdlno COLOR COL_POSITIVE INTENSIFIED OFF.  "#EC CI_FLDEXT_OK[2215424]
           HIDE ist_mdl-mdlno.
        Endloop.
    endif.

ENDMODULE.                 " Modelno_LIST  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  techauth_visiblity  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE techauth_visiblity OUTPUT.
clear g_techapr_visible.
read table g_TABCTRL110_itab into g_TABCTRL110_wa with key oth1 = 'X'.
if sy-subrc = 0.
 g_techapr_visible = 'Y'.
else.
 g_techapr_visible = ''.
endif.

*loop at   g_TABCTRL110_itab
*       into g_TABCTRL110_wa.
*  if g_TABCTRL110_wa-oth1 = 'X'.
*     g_techapr_visible = 'Y'.
*     exit.
*  else.
*     g_techapr_visible = ''.
*  endif.
*endloop.

ENDMODULE.                 " techauth_visiblity  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_line  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_line OUTPUT.

case zmm_cdhd_st-mtart.
    when 'ZCAP'.
    If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
       SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN' LINE 1.
    Else.
       SET CURSOR FIELD g_curfield130 LINE G_CURR_LINE_130 .
    Endif.
    When 'ZSPR'.
      If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
        SET CURSOR FIELD 'ZMM_CDITEM-PARTNO' LINE 1.
      Else.
       SET CURSOR FIELD g_curfield120 LINE G_CURR_LINE_120 .
      Endif.
    When 'ZSTO'.
      If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
          SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE 1.
      Else.
         SET CURSOR FIELD g_curfield110 LINE G_CURR_LINE_110.
      Endif.
Endcase.


ENDMODULE.                 " set_cursor_line  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL130_check  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL130_check OUTPUT.

 if check_code = 'CHECK'.
    loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.

      if g_TABLCTRL130_wa-mat_fnd > 0.

        wa_message-srno = g_TABLCTRL130_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'There is a list of material codes available as per selection.'.
        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
      wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.

        append wa_message to ist_message.


        wa_message-srno = g_TABLCTRL130_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'Have you checked the detailed speifications(if any)'.

        append wa_message to ist_message.

        wa_message-srno = '   '.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'B'.
      wa_message-msgtext =
      'in the  materials  list  appearing  in  the search help?'.

        append wa_message to ist_message.

      endif.

      clear wa_message.
    endloop.
*   Perform spell_check1.
*   if g_spellerror = 'X'.
*
*      wa_message-msgtype = 'W'.
*      wa_message-srno    = '000'.
*      wa_message-msgcode = 'S'.
*      wa_message-msgtext = 'Spelling  Errors'.
*      append wa_message to ist_message.
*   Endif.

    describe table g_TABLCTRL130_itab lines check_lines.

    if check_lines > 0.

      Call Screen 102 starting at 10 05 ending at 100 15.

    else.

      message i028(zmm_oth).

    endif.

    clear : g_TABLCTRL130_wa-dsflag,  g_long_text_warning .

  endif.


ENDMODULE.                 " TABLCTRL130_check  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  change_restrict  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE change_restrict OUTPUT.
Form Change_restrict.

*
*
  If ( g_mode = 'CHA' or g_mode ='REL' ) and zmm_cdhd_st-REQCPF <> ''
.
   If sy-uname <> zmm_cdhd_st-REQCPF.
        If  g_user = ''.
            message i020(zmm_oth).
            Perform Clear_var.
            leave to screen 100.
        Elseif g_user = 'M'.
*            AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                       ID 'WERKS' Field zmm_cdhd_st-werks
*                       ID 'ACTVT'  dummy. "FIELD '01'.
*            If sy-subrc <> 0.
*                g_change_auth = 'X'.
*            leave to screen 100.
*            Endif.

        Endif.
   Endif.
  Endif.
Endform.
*ENDMODULE.                 " change_restrict  OUTPUT
