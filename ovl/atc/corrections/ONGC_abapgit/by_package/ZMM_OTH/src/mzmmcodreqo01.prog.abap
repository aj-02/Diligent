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
*{   INSERT         OCPK900087                                        1
*DATA: BEGIN OF WA_T604F,
*      LAND1 TYPE LAND1,
*      STEUC TYPE STEUC,
*  END OF WA_T604F,
*  ZMSG110 TYPE STRING.
*LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
*
* SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = G_TABCTRL110_WA-STEUC.
*ENDSELECT.
*
*IF WA_T604F IS INITIAL.
*
* CONCATENATE G_TABCTRL110_WA-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
* MESSAGE ZMSG110 TYPE 'E'.
*
*ENDIF.
*
*CLEAR: G_TABCTRL110_WA, WA_T604F.
*ENDLOOP.

*}   INSERT
******Local data********
  Data: l_110lns type i,
        l_tdname like thead-tdname,
        l_stxl   like stxl.

*************************
*
  clear : g_ok_code110 , sy-ucomm , g_ok_code115.

*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABCTRL110_itab'
*
  IF g_TABCTRL110_copied is initial.
    if ( g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSTO' )
       or g_mode = 'REL'.

      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABCTRL110_itab
      where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
    endif.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if sy-tcode = 'ZCODG'.
      select single * from zmm_cdcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        delete g_TABCTRL110_itab where rej_flg = 'RM' or
                                       rej_flg = 'RT'.
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
          concatenate 'CDDS' g_user_logged g_TABCTRL110_wa-srno
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
    if l_110lns < 999.
      TABCTRL110-lines = 999.
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
*
  move-corresponding g_TABCTRL110_wa to ZMM_CDITEM.
  if ( g_mode = 'CRE' ) OR
     ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ).
* --  Commented + moving this to GC_FIELD115.
*---  to take care of duplicate record check.
    clear g_desc1_4.
    concatenate g_TABCTRL110_wa-desc1
                g_TABCTRL110_wa-desc2
                g_TABCTRL110_wa-desc3
                g_TABCTRL110_wa-desc4
                into g_desc1_4 separated by space.
    condense g_desc1_4.
    condense g_TABCTRL110_wa-user_desc.

    concatenate g_desc1_4 g_TABCTRL110_wa-user_desc
    into g_TABCTRL110_wa-desc_fin
    separated by space.
*    concatenate g_TABCTRL110_wa-desc1
*                g_TABCTRL110_wa-desc2
*                g_TABCTRL110_wa-desc3
*                g_TABCTRL110_wa-desc4
*                g_TABCTRL110_wa-user_desc
*           into g_TABCTRL110_wa-desc_fin
*           separated by space.

    condense g_TABCTRL110_wa-desc_fin.

*----------- End comment +.

**********To get the maximum srno in the internal table***
    IF not g_TABCTRL110_wa-desc_fin is initial.
      clear: l_srno,l_srnoflag.
      if g_TABCTRL110_wa-SRNO = 0.
        perform get_nextsrno_sto.
        move l_srno to g_TABCTRL110_wa-SRNO.
        modify g_TABCTRL110_itab from g_TABCTRL110_wa
        index tabctrl110-current_line transporting srno.
      endif.
    ENDIF.

*
    if TABCTRL110-current_line = g_curr_line_110.

      if not g_mat_fnd is initial.
        move g_mat_fnd to ZMM_CDITEM-mat_fnd.
      else.
        if do_not_change_flag = 'X' .
          clear do_not_change_flag.
        else.
          move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
        endif.
        if g_mat_fnd_flag = 'X'.
          move g_mat_fnd to ZMM_CDITEM-mat_fnd.
          clear g_mat_fnd_flag.
        endif.
      endif.

      if do_not_change_flag1 = 'X'.
        move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
        clear do_not_change_flag1.
      endif.

    endif.

    if g_TABCTRL110_wa-dsflag = 'X'.
      g_long_text_warning = 'X'.
    endif.

    move g_TABCTRL110_wa-SRNO to ZMM_CDITEM-SRNO.
    move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
  endif.
*
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
    if g_TABCTRL110_wa-desc_cdcell is initial.
     g_TABCTRL110_wa-desc_cdcell = g_TABCTRL110_wa-desc_fin+0(87).
    endif.
    move g_TABCTRL110_wa-desc_cdcell to ZMM_CDITEM-desc_cdcell.
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
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if sy-tcode = 'ZCODG'.
      select single * from zmm_cdcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        delete g_TABLCTRL130_itab where rej_flg = 'RM' or
                                        rej_flg = 'RT'.
        select single * from zmm_cdcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          loop at g_TABLCTRL130_itab into g_tablctrl130_wa.
            select single * from zmm_cdcodifier
                   where codifier = sy-uname
                   and   matgp    = g_tablctrl130_wa-matgp.
            if sy-subrc <> 0.
              delete g_TABLCTRL130_itab index sy-tabix.
            endif.
          endloop.
        endif.
      endif.
    endif.
*
    g_TABLCTRL130_copied = 'X'.
    refresh control 'TABLCTRL130' from screen '0130'.
*
  endif.
*
***To check, if long text maintained or not
  Case g_mode.
    WHEN 'CRE'.
      IF not g_TABLCTRL130_itab[] is initial.
        loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
          concatenate 'CDDS' g_user_logged g_TABLCTRL130_wa-srno
           into l_tdname.
          perform check_lt_exist using l_tdname.
          if not g_lines[] is initial.
            read table g_lines into g2_lines index 1.
            if not g2_lines-tdline is initial.
              g_TABLCTRL130_wa-dsflag = 'X'.
              modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
                  transporting dsflag
                  where srno = g_TABLCTRL130_wa-srno.
              clear g_TABLCTRL130_wa-dsflag.
            else.
              g_TABLCTRL130_wa-dsflag = ''.
              modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
                  transporting dsflag
                  where srno = g_TABLCTRL130_wa-srno.
            endif.
            clear g2_lines.
          endif.
        endloop.
      ENDIF.
    WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
      loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
        concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
        into l_tdname.
        perform check_lt_exist using l_tdname.
        if not g_lines[] is initial.
          read table g_lines into g2_lines index 1.
          if not g2_lines-tdline is initial.
            g_TABLCTRL130_wa-dsflag = 'X'.
            modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
                 transporting dsflag
                 where srno = g_TABLCTRL130_wa-srno.
            clear g_TABLCTRL130_wa-dsflag.
          else.
            g_TABLCTRL130_wa-dsflag = ''.
            modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
                 transporting dsflag
                 where srno = g_TABLCTRL130_wa-srno.
          endif.
          clear g2_lines.
        endif.
      endloop.
  ENDCASE.
*  if g_mode <> 'CRE'.
*    loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
*      Clear l_tdname.
*      concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
*      into l_tdname.
*      Select single * into l_stxl from stxl
*             where TDOBJECT = 'ZMMCD'
*             and   TDNAME   = l_tdname
*             and   TDID     = 'CDDS'.
*      if sy-subrc = 0.
*        g_TABLCTRL130_wa-dsflag = 'X'.
*        modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
*               transporting dsflag
*               where srno = g_TABLCTRL130_wa-srno.
*      endif.
*    endloop.
*  endif.
*
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    TABlCTRL130-lines = 999.
  endif.
endmodule.
***********************************************************************
*&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL130_move output.
  Data: l_itab130 type t_TABLCTRL130,
        lc_itab130 type t_TABLCTRL130 occurs 0.
***********************************************************
  move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    if not g_TABLCTRL130_wa-desc_fin is initial.
**********To get the maximum srno in the internal table***
      clear: l_srno,l_srnoflag.
*
      if g_TABLCTRL130_wa-SRNO = 0.
        perform get_nextsrno_cap.
        move l_srno to g_TABLCTRL130_wa-SRNO.
        modify g_tablctrl130_itab from g_TABLCTRL130_wa index
             tablctrl130-current_line transporting srno.
      endif.
************************************************************
    endif.

******Begin of Original Coding  commented

*  Data: l_itab130 type t_TABLCTRL130.
*  move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
*  if ( g_mode = 'CRE' ) OR
*     ( g_mode = 'CHA' ).
*    condense g_TABLCTRL130_wa-desc_fin.
*
*    if not g_TABLCTRL130_wa-desc_fin is initial.
**     move TABLCTRL130-current_line
**       to g_TABLCTRL130_wa-SRNO.
***********To get the maximum srno in the internal table***
*      clear: l_srno,l_srnoflag.
*      describe table g_TABLCTRL130_itab lines l_srno.
*      while l_srnoflag <> 'S'.
*        read table g_TABLCTRL130_itab into l_itab130
*             with key srno = l_srno.
*        if sy-subrc <> 0.
*          l_srnoflag = 'S'.
*        else.
*          l_srno = l_srno + 1.
*        endif.
*      endwhile.
*      if g_TABLCTRL130_wa-SRNO = 0.
*        move l_srno to g_TABLCTRL130_wa-SRNO.
*      endif.
*    endif.

*    if TABLCTRL130-current_line = g_curr_line_130.
*      move g_mat_fnd to ZMM_CDITEM-mat_fnd.
*    else.
*      move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
*    endif.
*
*    move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
*    move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.

*****End  Original Coding  commented

    if g_TABLCTRL130_wa-Desc_fin is initial.
      clear  g_mat_fnd.
    endif.

    If okcode_100 = 'TABLCTRL130_DELE'.
      move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
    Else.
      If TABLCTRL130-current_line = g_curr_line_130.
        move g_mat_fnd to ZMM_CDITEM-mat_fnd.
      Else.
        move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
      Endif.
    Endif.

*
    If  g_TABLCTRL130_wa-SRNO <> 0.
      move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
      move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.
    endif.
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
      SET TITLEBAR 'MATCODE_TTL' with ': Create Request'.
    when 'CHA'.
      SET TITLEBAR 'MATCODE_TTL' with ': Change Request'.
    when 'DIS'.
      SET TITLEBAR 'MATCODE_TTL' with ': Display Request'.
    when 'DEL'.
      SET TITLEBAR 'MATCODE_TTL' with ': Delete Request'.
    when 'REL'.
      SET TITLEBAR 'MATCODE_TTL' with ': Release Request'.
    when 'APR'.
      if g_user = 'M'.
        SET TITLEBAR 'MATCODE_TTL' with ': Approve Req-MRP'.
      elseif g_user = 'L'.
        SET TITLEBAR 'MATCODE_TTL' with ': Approve Req-TAA'.
      endif.
    when others.
      SET TITLEBAR 'MATCODE_TTL' with ''.
  endcase.
*
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.

  Case g_mode.
*
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
           screen-name  = 'G_SH_MDLNO' .
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
*
            if g_user = 'M'.
              if g_techapr_visible = 'Y'.
                screen-invisible = 0.
                screen-input     = 0.
              else.
                screen-invisible = 1.
              endif.
              modify screen.
            endif.
*
            if g_user = 'L'.
              screen-input = 1.
              modify screen.
            Else.
              screen-input = 0.
              modify screen.
            Endif.
*
          Elseif screen-name = 'T_TECHAUTH'.
            if g_user = 'M'.
              if g_techapr_visible = 'Y'.
                screen-invisible = 0.
              else.
                screen-invisible = 1.
              endif.
              modify screen.
            endif.
*
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
*
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
*        If screen-name = 'ZMM_CDHD_ST-REQCL'.
*          if sy-tcode  = 'ZCODG'.
*            screen-input = 1.
*          else.
*            screen-input = 0.
*          endif.
*          modify screen.
*        Endif.

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
*
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
*
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    TABlCTRL140-lines = 999.
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

*&spwizard: copy ddic-table 'ZMM_CDITEM'
*&spwizard: into internal table 'g_TABLCTRL120_itab'
*****Addition*****************
  if g_TABLCTRL120_copied is initial.
    if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
      select * from ZMM_CDITEM
         into corresponding fields
         of table g_TABLCTRL120_itab
      where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
 "added by lipsy on 04.09.2012 <RD1K979105> for creating a new column for vendor name
     refresh:itab_lfa1.

 if g_TABLCTRL120_itab is not initial.
     select lifnr name1
       FROM lfa1
       INTO CORRESPONDING FIELDS OF TABLE  itab_lfa1
       FOR ALL ENTRIES IN g_TABLCTRL120_itab
       WHERE lifnr =  g_TABLCTRL120_itab-manu.
 endif.

     loop at g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
       clear:wa_lfa1.
       READ TABLE itab_lfa1 INTO wa_lfa1 with key lifnr = g_TABLCTRL120_wa-manu.
       g_TABLCTRL120_wa-name1 = wa_lfa1-name1.
       MODIFY  g_TABLCTRL120_itab FROM g_TABLCTRL120_wa
        TRANSPORTING name1
        where manu = g_TABLCTRL120_wa-manu .
     ENDLOOP.
 "end of addition by lipsy on 04.09.2012
    endif.
***to delete the internal table entries which do not
***belong to a partiular codifier's assigned class
    if sy-tcode = 'ZCODG'.
      select single * from zmm_cdcodifier
              where codifier = sy-uname
              and   matgp    = ''
              and   status   = 'A'.
      if sy-subrc <> 0.
        delete g_TABLCTRL120_itab where rej_flg = 'RM' or
                                        rej_flg = 'RT'.
        select single * from zmm_cdcodifier
               where codifier = sy-uname.
        if sy-subrc = 0.
          loop at g_TABLCTRL120_itab into g_tablctrl120_wa.
            select single * from zmm_cdcodifier
                   where codifier = sy-uname
                   and   matgp    = g_tablctrl120_wa-matgp.
            if sy-subrc <> 0.
              delete g_TABLCTRL120_itab index sy-tabix.
            endif.
          endloop.
        endif.
      endif.
    endif.
*
    g_TABLCTRL120_copied = 'X'.
    refresh control 'TABLCTRL120' from screen '0120'.
  endif.
*
***To check, if long text maintained or not
  Case g_mode.
    WHEN 'CRE'.
      IF not g_TABLCTRL120_itab[] is initial.
        loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
          concatenate 'CDDS' g_user_logged g_TABLCTRL120_wa-srno
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
    if l_120lns < 999.
      TABLCTRL120-lines = 999.
    endif.
  endif.
  "added by lipsy on 7.09.2012 <RD1K979105> to get correct vendor details on double click.
  CLEAR:count.
  "end of addition by lipsy on 07.09.2012
endmodule.

*&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: move itab to dynpro
module TABLCTRL120_move output.
  Data: l_itab120 type t_TABLCTRL120,
        lc_itab120 type t_TABLCTRL120 occurs 0.
***********************************************************
  move-corresponding g_TABLCTRL120_wa to ZMM_CDITEM.
  "added by lipsy on 05.09.2012 <RD1K979105> for getting vendor name for original equipment
*  data:v_vendor TYPE NAME1_GP.
  CLEAR:v_vendor.
  move g_TABLCTRL120_wa-name1 to v_vendor.
  "end of addition by lipsy on 05.09.2012
  if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
    if not g_TABLCTRL120_wa-partno is initial.
**********To get the maximum srno in the internal table***
      clear: l_srno,l_srnoflag.
      if g_TABLCTRL120_wa-SRNO = 0.
        perform get_nextsrno_spr.
        move l_srno to g_TABLCTRL120_wa-SRNO.
        modify g_tablctrl120_itab from g_TABLCTRL120_wa index
             tablctrl120-current_line transporting srno.
      endif.
************************************************************
    endif.

    if g_TABLCTRL120_wa-partno is initial.
      clear  g_mat_fnd.
    endif.

    if ok_code = 'TABLCTRL120_DELE'.
      move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
    else.
****Changes***********************************<<SK20102005>>
      if TABLCTRL120-current_line = g_curr_line_120.
        move g_mat_fnd to ZMM_CDITEM-mat_fnd.
      else.
        move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
      endif.
*****End***************************************<<SK20102005>>
    endif.

*
    if  g_TABLCTRL120_wa-SRNO <> 0.
      move g_TABLCTRL120_wa-SRNO to ZMM_CDITEM-SRNO.
      move g_TABLCTRL120_wa-desc_fin to ZMM_CDITEM-desc_fin.
    endif.
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
  if   okcode_100 = 'CAPEQT'   or
       okcode_100 = 'MDLNO'.
    clear okcode_100.
  Else.
    G_MATTY = ZMM_CDHD_ST-MTART.
    sel_flag = check_pos.
*
    CASE g_matty.
      WHEN 'ZSTO'.
        IF not desc11 is initial .
*{   INSERT         OCPK900087                                       12
*DATA: BEGIN OF WA_T604F,
*      LAND1 TYPE LAND1,
*      STEUC TYPE STEUC,
*  END OF WA_T604F,
*  ZMSG110 TYPE STRING.
**LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
*READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = DESC11.
*STEUC = G_TABCTRL110_WA-STEUC.
* SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = STEUC.
*ENDSELECT.
*
*IF WA_T604F IS INITIAL.
*
* CONCATENATE STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
* MESSAGE ZMSG110 TYPE 'S' DISPLAY LIKE 'E'.
*
*
*ELSE.

*}   INSERT
          If FIELD1 = 'ZMM_CDITEM-DESC1'.
            REFRESH IST_SRCHLP.
            clear : DESC22 ,DESC33 , DESC44.
*{   INSERT         OCPK900087                                        9
*READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = DESC11.
*STEUC = G_TABCTRL110_WA-STEUC.
*}   INSERT
            PERFORM SELECT_HELP_DATA using
                          G_PARTNO
                          DESC11
                          DESC22
                          DESC33
                          DESC44
*{   INSERT         OCPK900087                                        1
**********************************************************************
*                          STEUC
**********************************************************************
*}   INSERT
                          DESC55
                          G_MATGP
                          G_MATTY
                       changing sel_flag.
          Endif.
*{   INSERT         OCPK900087                                       10
*IF SY-SUBRC = 0.

*}   INSERT

          If FIELD1 = 'ZMM_CDITEM-DESC2'.
            clear : DESC33, DESC44.
            PERFORM SELECT_HELP_DATA using
                          G_PARTNO
                          DESC11
                          DESC22
                          DESC33
                          DESC44
*{   INSERT         OCPK900087                                        2
*STEUC
*}   INSERT
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
*{   INSERT         OCPK900087                                        3
*STEUC
*}   INSERT
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
*{   INSERT         OCPK900087                                        4
*STEUC
*}   INSERT
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
*{   INSERT         OCPK900087                                        5
*STEUC
*}   INSERT
                          DESC55
                          G_MATGP
                          G_MATTY
                       changing sel_flag.
          Endif.
        ENDIF.
*{   INSERT         OCPK900087                                       13
*ENDIF.
*}   INSERT

        If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
          perform search_copyofdesc.
        Endif.

      WHEN 'ZSPR'.

        If FIELD1 = 'ZMM_CDITEM-PARTNO' .

          PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
*
          clear : DESC11, DESC22 ,DESC33 , DESC44.

          PERFORM SELECT_HELP_DATA using
                        G_PARTNO
                        DESC11
                        DESC22
                        DESC33
                        DESC44
*{   INSERT         OCPK900087                                        6
*STEUC
*}   INSERT
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
*{   INSERT         OCPK900087                                        7
*STEUC
*}   INSERT
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
*{   INSERT         OCPK900087                                        8
*STEUC
*}   INSERT
                        DESC55
                        G_MATGP
                        G_MATTY
                     changing sel_flag.
        Endif.

      WHEN 'ZCAP'.
        Perform get_srchlp_zcap.
        Describe table ist_srchlp lines g_mat_fnd.
    ENDCASE.

    if g_matty = 'ZSTO'.
*{   INSERT         OCPK900087                                       14
*IF WA_T604F IS NOT INITIAL.

*}   INSERT
      PERFORM SELECT_MATERIAL_DETAILS.
*{   INSERT         OCPK900087                                       15

*ENDIF.
*}   INSERT
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
***
      if sy-tcode = 'ZCODG'.
        perform lock_reqhd.
      endif.
*

     """""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""added by lipsy on 10.09.2013 for getting correct request no in other than creation mode RD1K982397.

               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                 EXPORTING
               INPUT         = zmm_cdhd_st-reqno
                 IMPORTING
               OUTPUT        =  zmm_cdhd_st-reqno.




      "end of addition by lipsy on 10.09.2013 for getting correct request no in other than  creation mode RD1K982397.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'


      select single * from ZMM_CDHD
          into corresponding fields of ZMM_CDHD_ST
           where REQNO = zmm_cdhd_st-reqno.
      g_first_time_flag = 'X'.
      If g_user = 'Z' and zmm_cdhd_st-reqno <> ''.
        Perform set_g_user. " For g_user = 'Z' <<03.10.05>>
      Endif.
*
      if sy-subrc = 0.
        g_hd_copied = 'X'.
*
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

  """"""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""added by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.

  PERFORM get_tel_creation.

  "end of addition by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""


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
           screen-name = 'SORTD' or
           screen-name = 'EXPORT'.
          screen-input = 0.
          modify screen.
        elseif screen-name = 'INS_MODIFIERS' or
               screen-name = 'INS_MDLNO'.
          screen-invisible = 1.
          modify screen.
        endif.
*
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
          if screen-name = 'SORTU'  OR
             screen-name = 'SORTD' OR
             screen-name = 'EXPORT'.
             if screen-name = 'EXPORT'.
               screen-invisible = 0.
               screen-input = 1.
             else.
               screen-input = 1.
             endif.
            modify screen.
          elseif screen-name = 'INS_MODIFIERS' or
                 screen-name = 'INS_MDLNO'.
            screen-invisible = 1.
            modify screen.
          endif.
        endif.
      endloop.
    When 'APR'.
      loop at screen.
        if screen-name = 'ZMM_CDITEM-COMP_FLG' OR
           screen-name = 'ZMM_CDITEM-REQ_LT'  OR
           screen-name = 'SORTU'  OR
           screen-name = 'SORTD'  OR
           screen-name = 'SPELL'.
          screen-input  = 1.
          modify screen.
        elseif screen-name = 'INS_MODIFIERS' or
               screen-name = 'INS_MDLNO'.
          screen-invisible = 1.
          modify screen.
        else.
          screen-input  = 0.
          modify screen.
        endif.
      endloop.
  Endcase.

  IF sy-tcode = 'ZCODG'.
    loop at screen.
      if screen-name = 'TABCTRL110_DELETE' or
         screen-name = 'TABLCTRL120_DELETE' or
         screen-name = 'TABLCTRL130_DELETE' or
         screen-name = 'TABLCTRL140_DELETE' or
         screen-name = 'FILTER'.
        screen-input = 0.
        modify screen.
      elseif screen-name = 'SPELL' or
             screen-name = 'INS_MODIFIER' or
             screen-name = 'INS_MDLNO'.
        screen-input = 1.
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
*
  SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS

 WHERE DESC1 = G_TABCTRL110_WA-DESC1 AND MATGRP = G_TABCTRL110_WA-MATGP
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
*
      g_parno = '1'.
    when ZMM_CDITEM-OTH2.
*
      g_parno = '2'.
    when ZMM_CDITEM-OTH3.
*
      g_parno = '3'.
    when ZMM_CDITEM-OTH4.
      g_parno = '4'.
  endcase.

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
*    When 'CRE' OR 'CHA' OR 'COD'.  "GCU 101105
      loop at screen.
*
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
*
            IF not g_TABCTRL110_wa-desc1 is initial.
              IF screen-name = 'ZMM_CDITEM-UOM'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*
          when '2'.
            if screen-name = 'ZMM_CDITEM-DESC3'.
              screen-input = 0.
              modify screen.
            endif.

            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 0.
              modify screen.
            endif.
*
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
*
          when '3'.
            if screen-name = 'ZMM_CDITEM-DESC4' .
              screen-input = 0.
              modify screen.
            endif.
*
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
*
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
*
            IF not g_TABCTRL110_wa-desc2 is initial.
              IF screen-name = 'ZMM_CDITEM-DESC3'.
                screen-required = 1.
                modify screen.
              ENDIF.
            ENDIF.
*
            if screen-name = 'ZMM_CDITEM-DESC4'.
              screen-input = 1.
              modify screen.
            endif.
*
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
*
        endcase.
*
        if not g_tabctrl110_wa-matcode is initial.
          if screen-group4 = 'MC'.
            screen-input = 0.
            modify screen.
          endif.
        endif.
*
        if screen-name = 'ZMM_CDITEM-REJ_FLG' or
           screen-name = 'ZMM_CDITEM-DESC_CDCELL'.
          screen-input = 0.
          modify screen.
        endif.
      endloop.
    When 'DIS' OR 'DEL' OR
         'REL' .
      loop at screen.
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
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
** commented on 03-09-05 TO CORRECT ADDTION DESC PROBLEM IN THE LINE
** WHERE THER ARE NO 'OTHER' ENTERIES.
*  if sy-ucomm <> ''.
*    g_ok_code110 = sy-ucomm.
*  endif.
* End comment.

  clear sy-ucomm.
  export g_tabctrl110_wa-oth1 to memory id 'OTH1'.
  select single WGBEZ from T023T into g_matgp_desc where MATKL =
  g_matgp and spras = sy-langu.

  clear zmm_modifier.
  select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
MATGRP = zmm_cditem-MATGP.

  set pf-status 'STAT115'.
*
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
*
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
*
        if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
          if screen-name = 'ZMM_CDITEM-MDLNO'  or
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
*
        if screen-name = 'ZMM_CDITEM-REQ_LT'.
          IF g_TABLCTRL120_wa-desc_fin is initial.
            screen-input = 0.
          ELSE.
            screen-input = 1.
          ENDIF.
          modify screen.
        endif.
*
        if screen-name = 'ZMM_CDITEM-REJ_FLG'.
          screen-input = 0.
          modify screen.
        endif.
*
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
        if not g_tablctrl120_wa-matcode is initial.
          if screen-group4 = 'MC'.
            screen-input = 0.
            modify screen.
          endif.
        endif.
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
*
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
*

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

        if not g_tablctrl120_wa-matcode is initial.
          if screen-group4 = 'MC'.
            screen-input = 0.
            modify screen.
          endif.
        endif.

      endloop.
    When 'DIS' OR 'DEL' OR 'REL'.
      loop at screen.
        if screen-name <> 'ZMM_CDITEM-REQ_LT'.
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

ENDMODULE.                 " TABLCTRL120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL130_change_field_attr OUTPUT.
  Case g_mode.
    When 'CRE' OR 'CHA'.
      Loop at screen.
        If g_TABLCTRL130_wa-DESC_FIN is initial.
          if screen-name = 'ZMM_CDITEM-REJ_FLG' or
             screen-name = 'ZMM_CDITEM-MATCOST' or
             screen-name = 'ZMM_CDITEM-MATCATG' OR
             screen-name = 'ZMM_CDITEM-MATLOC' or
             screen-name = 'ZMM_CDITEM-WRKNG_LIFE' or
*             screen-name = 'ZMM_CDITEM-DESC_CDCELL' or
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
           screen-name = 'ZMM_CDITEM-SPA_GRP' or
           screen-name = 'ZMM_CDITEM-DESC_CDCELL'.
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

        if not g_tablctrl130_wa-matcode is initial.
          if screen-group4 = 'MC'.
            screen-input = 0.
            modify screen.
          endif.
        endif.

      Endloop.
      set cursor field 'ZMM_CDITEM-MATCOST'.
    When 'DIS' OR 'DEL' OR 'REL'.
      loop at screen.
        if screen-name <> 'ZMM_CDITEM-REQ_LT'.
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
  IF not g_cditem_itab is initial.

    SET PF-STATUS SPACE.
  write: / 'Duplicate Records existing in the following requests' color
  7
  .
    Write: / '---------------------------------------------------'.
    Write : / 'Ln No ' Color 5,   'Request No. Srno  Desc'  .
    loop at g_cditem_itab into g_cditem.
      Write: /(5)  g_cditem-mat_fnd color 5.
      Write:(11) g_cditem-Reqno.
      Write:(4)  g_cditem-srno.
      Write:(87) g_cditem-desc_fin.
    Endloop.

  Else.
    if g_long_text_warning <> 'X' and sy-tcode = 'ZCODG'.

      wa_message-srno = '000'.
      wa_message-msgtype = 'W'.
      wa_message-msgcode = 'C'.

      wa_message-msgtext = 'Detailed specifications can be entered if required.' .
*      wa_message-msgtext = text-001.

      append wa_message to ist_message.
      wa_message-srno = '   '.
      wa_message-msgtype = 'W'.
      wa_message-msgcode = 'C'.

      wa_message-msgtext = 'The same will get defaulted in the PR/PO documents ' .
*      wa_message-msgtext = text-002.

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
  Endif.
ENDMODULE.                 " WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_check  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_check OUTPUT.

*
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


      if sy-tcode <> 'ZCODG'.

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

      endif.

      if g_TABCTRL110_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
        wa_message-srno = g_TABCTRL110_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'Z'.
        wa_message-msgtext =
        'Detail Specification has been maintained for this line item'.

        append wa_message to ist_message.
      endif.

      clear wa_message.
    endloop.
*
    describe table g_TABCTRL110_itab lines check_lines.

    if check_lines > 0.

      Call Screen 102 starting at 10 05 ending at 100 15.

    else.

      message i028(zmm_oth).

    endif.

    clear : g_TABCTRL110_wa-dsflag,  g_long_text_warning .

  endif.

ENDMODULE.                 " TABCTRL110_check  OUTPUT
*
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
*
  SUPPRESS DIALOG.
  SET PF-STATUS 'STAT_REL'.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*
  NEW-PAGE NO-TITLE.
  Case g_mode .
    When 'REL'.
   If ( g_user = 'M' or g_user = 'L' or zmm_cdhd_st-reqcpf = sy-uname )
              .
Write : / '                   Acknowledgement                         '
                        Color 3.
Write : / '-----------------------------------------------------------'.
   Write : / 'The Material Search has been done using tcode ZMMMATHELP'.
WRite : / 'and MM03. Relevant material code not available. The details'.
     write : / 'in the request have been checked and confirmed. Please'.
   Write : / 'process the request for generation of new Material Code.'.

      Else.
        Message i042(zmm_oth).
        leave to screen 0.
      Endif.

    When 'APR' .
      If  g_user = 'M'.
  Write : / '                   Acknowledgement                       '
                                         Color 5.
      Write : / '-----------------------------------------------------'.
        write: / 'The details in the request have been rechecked and'.
       Write : / 'confirmed. Please process the request for generation'.
        write: / 'of new Material Code.'.
      Else.
        message i043(zmm_oth).
        leave. "to screen 0.
      Endif.
   when 'COD'.
    IF OKCODE_100 = 'INS_MODI'.
     Write : / 'Following Modifiers will be inserted' color 6.
     write : /.
     if not zmm_modifier-desc1 is initial.
        Write : / '1. ',zmm_modifier-desc1.
     Endif.
     if not zmm_modifier-desc2 is initial.
        Write : / '2. ',zmm_modifier-desc2.
     Endif.
     if not zmm_modifier-desc3 is initial.
        Write : / '3. ',zmm_modifier-desc3.
     Endif.
     if not zmm_modifier-desc4 is initial.
        Write : / '4. ',zmm_modifier-desc4.
     Endif.

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
  PERFORM GET_PARNO.
  Case G_MODE.

    When 'DIS' OR 'DEL' OR 'REL' OR 'APR' .
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
        condense g_desc1_4.

        user_desc_len = 86 - strlen( g_desc1_4 ).

        Loop at screen.
          If screen-group1 = 'G1'.
            screen-input = 0.
            modify screen.
          Endif.
          IF screen-name = 'G_USER_DESC' and user_desc_len > 0.
            screen-length = user_desc_len.
            modify screen.
          ENDIF.
        Endloop.
      ENDIF.
    WHEN 'CRE' OR 'CHA' OR 'COD'.
      If sy-tcode <> 'ZCODG'.
        concatenate g_desc1 g_desc2 g_desc3 g_desc4 into g_desc1_4
                                             separated by space.
        condense g_desc1_4.
        user_desc_len = 86 - strlen( g_desc1_4 ).
      Endif.
      Case 'OTHER'.
        when g_tabctrl110_wa-desc1.
          if  g_tabctrl110_wa-srno = ''. "New line
            If sy-ucomm <> ''.
              g_desc1 = ''.
            Endif.
            move  'X'  to g_tabctrl110_wa-oth1.
            move  'X'  to g_tabctrl110_wa-oth2.
            move  'X'  to g_tabctrl110_wa-oth3.
            move  'X'  to g_tabctrl110_wa-oth4.
          Else.
            read table g_tabctrl110_itab into
                   g_tabctrl110_wa index g_curr_line_110.
            g_desc1 = g_tabctrl110_wa-desc1. "change existing line
            g_desc2 = g_tabctrl110_wa-desc2.
            g_desc3 = g_tabctrl110_wa-desc3.
            g_desc4 = g_tabctrl110_wa-desc4.
            G_USER_DESc = g_tabctrl110_wa-user_desc.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth1.
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
            If g_parno = 3 and screen-name = 'G_DESC4'.
              screen-input = 0.
              modify screen.
            Endif.
            If g_parno = 2 and ( screen-name = 'G_DESC3' or
                                 screen-name = 'G_DESC4' ).
              screen-input = 0.
              modify screen.
            Endif.

            If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
              screen-input = 0.
              modify screen.
            Endif.

            IF screen-name = 'G_DESC3' or screen-name = 'G_DESC4'.
              screen-required = 0.
              modify screen.
            Endif.
          Endloop.

        when g_tabctrl110_wa-desc2.
          If g_tabctrl110_wa-srno = ''. "New line
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = ''.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth2.
            move  'X'  to g_tabctrl110_wa-oth3.
            move  'X'  to g_tabctrl110_wa-oth4.
          Else.                                  "existing line
            read table g_tabctrl110_itab into
              g_tabctrl110_wa index g_curr_line_110.
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = g_tabctrl110_wa-desc2.
            If g_desc2 = 'OTHER'.
              g_desc2 = ''.
            Endif.
            IF g_parno = 2.  " GCU 27-10-2005
              g_desc3 = ''.
              g_desc4 = ''.
            Elseif g_parno = 3.
              g_desc3 = g_tabctrl110_wa-desc3.
              g_desc4 = ''.
            Else.
              g_desc3 = g_tabctrl110_wa-desc3.
              g_desc4 = g_tabctrl110_wa-desc4.
            Endif.
            G_USER_DESc = g_tabctrl110_wa-user_desc.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth2.
          Endif.
          Loop at screen.
            If screen-name = 'G_DESC1' or
               screen-name = 'G_USER_DESC' or
               screen-name = 'G_MATGP'.
              screen-input = 0.
              modify screen.
            Endif.
            If g_parno = 3 and screen-name = 'G_DESC4'.
              screen-input = 0.
              modify screen.
            Endif.
            If g_parno = 2 and ( screen-name = 'G_DESC3' or
                                 screen-name = 'G_DESC4' ).
              screen-input = 0.
              modify screen.
            Endif.
            If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
              screen-input = 0.
              modify screen.
            Endif.

          Endloop.

        when g_tabctrl110_wa-desc3.
          If g_tabctrl110_wa-srno = ''. "New line
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = g_tabctrl110_wa-desc2.
            If sy-ucomm <> ''. "Enter Pressed
              g_desc3 = ''.
            Endif.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth3.
            move  'X'  to g_tabctrl110_wa-oth4.
          Else.
            read table g_tabctrl110_itab into
                     g_tabctrl110_wa index g_curr_line_110.
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = g_tabctrl110_wa-desc2.
            g_desc3 = g_tabctrl110_wa-desc3.
            if g_desc3 = 'OTHER'.
              g_desc3 = ''.
            Endif.
            IF g_parno = 2.
              g_desc3 = ''.
              g_desc4 = ''.
            ELSEIF g_parno = 3.   " GCU 27-10-2005
              g_desc3 = g_tabctrl110_wa-desc3.
              g_desc4 = ''.
            Else.
              g_desc4 = g_tabctrl110_wa-desc4.
            Endif.

            G_USER_DESc = g_tabctrl110_wa-user_desc.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth3.
          Endif.

          Loop at screen.
            If screen-name = 'G_DESC1'     or
               screen-name = 'G_DESC2'     or
               screen-name = 'G_USER_DESC' or
               screen-name = 'G_MATGP'.
              screen-input = 0.
              modify screen.
            Endif.
            If g_parno = 3 and screen-name = 'G_DESC4'.
              screen-input = 0.
              modify screen.
            Endif.
            If g_parno = 2 and ( screen-name = 'G_DESC3' or
                                 screen-name = 'G_DESC4' ).

              screen-input = 0.
              modify screen.
            Endif.
            If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
              screen-input = 0.
              modify screen.
            Endif.

          Endloop.

        when g_tabctrl110_wa-desc4.
          If g_tabctrl110_wa-srno = ''. "New line
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = g_tabctrl110_wa-desc2.
            g_desc3 = g_tabctrl110_wa-desc3.
            g_desc4 = ''.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth4.
          Else.
            read table g_tabctrl110_itab into
                     g_tabctrl110_wa index g_curr_line_110.
            g_desc1 = g_tabctrl110_wa-desc1.
            g_desc2 = g_tabctrl110_wa-desc2.
            g_desc3 = g_tabctrl110_wa-desc3.
            g_desc4 = g_tabctrl110_wa-desc4.
            if g_desc4 = 'OTHER'.
              g_desc4 = ''.
            Endif.

            G_USER_DESc = g_tabctrl110_wa-user_desc.
            g_matgp = g_tabctrl110_wa-matgp.
            move  'X'  to g_tabctrl110_wa-oth4.
          Endif.

          loop at screen.
            If screen-name = 'G_DESC1' or
               screen-name = 'G_DESC2' or
               screen-name = 'G_DESC3' or
               screen-name = 'G_MATGP' or
               screen-name = 'G_USER_DESC'.
              screen-input = 0.
              modify screen.
            Endif.
            If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
              screen-input = 0.
              modify screen.
            Endif.

          Endloop.

      Endcase.

      If g_ok_code115 = 'A_DESC'.
        Perform set_addnl_desc.
      Elseif g_ok_code115 = 'OK115' and g_ok_code110 = 'PB_AD' and
             g_spell_ans = 'N'.
        Perform set_addnl_desc.

      Elseif g_ok_code115 = 'OK115' and g_spell_ans = 'N'.
        Perform other_sectime.   "+
      Elseif  g_ok_code115 = ''.
        Perform other_sectime.   "+
      Elseif g_ok_code115 = 'OK115' and g_len_ex87 = 'X'.
        g_len_ex87 = ''.
        Perform other_sectime.   "+

      Endif.

      Case g_ok_code115.
        When 'A_DESC'.
          loop at screen.
            if screen-name = 'G_USER_DESC' AND USER_DESC_LEN > 0..
              screen-length = user_desc_len.
              screen-input = 1.
              modify screen.
            endif.
          Endloop.
        When 'CANC' or 'RW'.
          IF g_spell_ans = 'N'.
          Endif.
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
        condense g_desc1_4.
        user_desc_len = 86 - strlen( g_desc1_4 ).
        loop at screen.
          if screen-name = 'G_DESC1' or
             screen-name = 'G_DESC2' or
             screen-name = 'G_DESC3' or
             screen-name = 'G_DESC4' or
             screen-name = 'G_MATGP'.
            screen-input  = 0.
            modify screen.
          elseif screen-name = 'G_USER_DESC' AND USER_DESC_LEN > 0 .
            screen-length = user_desc_len.
            screen-input  = 1.
            modify screen.
          elseif screen-name = 'G_USER_DESC' AND USER_DESC_LEN <= 0 .
            screen-input  = 0.
          endif.
        endloop.
      ENDIF.
  Endcase.

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
*
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
  data : l_Manuf_ty type lfa1-J_1KFTBUS.
  clear g_mat_fnd.
  if check_code = 'CHECK'.
    loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
*
      select single J_1KFTBUS from lfa1 into l_manuf_ty where lifnr =
          g_TABLCTRL120_wa-manu.
      if sy-subrc = 0 and l_Manuf_ty <> 'OEM'.
        wa_message-srno = g_TABLCTRL120_wa-srno .
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'A'.
        concatenate 'Vendor' g_TABLCTRL120_wa-manu
        'Not an OEM' into wa_message-msgtext separated by space.
        append wa_message to ist_message.
      Endif.
*
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

      if sy-tcode <> 'ZCODG'.

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

      endif.

      if g_TABLCTRL120_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
        wa_message-srno = g_TABLCTRL120_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'Z'.
        wa_message-msgtext =
        'Detail Specification has been maintained for this line item'.

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
*
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

  if ZMM_CDHD_ST-MTART = 'ZSTO'.
    WRITE : / 'Select group :' .
    ULINE.
    Loop at ist_modifier_check_list .
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE: / ist_modifier_check_list-matgrp,  "#EC CI_NOORDER
                ist_modifier_check_list-desc1 COLOR COL_POSITIVE
INTENSIFIED OFF .  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
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

ENDMODULE.                 " techauth_visiblity  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_line  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_line OUTPUT.
  data : l_curr_row type sy-stepl.
  data : l_old_top_line type sy-stepl.
  data : g_cursor_line_in_tc like sy-loopc.

  If g_mode = 'CRE' or g_mode = 'CHA' or g_mode = 'DIS' or g_mode =
        'APR' or g_mode = 'COD' or g_mode = 'REL'.
.
    case zmm_cdhd_st-mtart.
      when 'ZCAP'.
*        If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
        If g_curfield = 'ZMM_CDHD_ST-TEL'.
          SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN' LINE 1.
        Else.
           g_cursor_line_in_tc = G_CURR_LINE_130 -
                                 Tablctrl130-top_line + 1.
           SET CURSOR FIELD g_curfield130 LINE g_cursor_line_in_tc.

*          SET CURSOR FIELD g_curfield130 LINE G_CURR_LINE_130 .
        Endif.
      When 'ZSPR'.
        If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
          SET CURSOR FIELD 'ZMM_CDITEM-PARTNO' LINE 1.
        Else.
           g_cursor_line_in_tc = G_CURR_LINE_120 -
                                 Tablctrl120-top_line + 1.

           SET CURSOR FIELD g_curfield120 LINE g_cursor_line_in_tc.

        Endif.
      When 'ZSTO'.
        clear g_parno.
        l_curr_row = g_Current_line.
        clear g_parno.
*        l_curr_row = G_CURR_LINE_110 - TABCTRL110-TOP_LINE + 1 .
*       Else.
*        l_curr_row = G_CURR_LINE_110.
*       ENDIF.
        If sy-tcode = 'ZCODG' or g_mode = 'DIS' or g_mode = 'REL' or
           g_mode = 'APR'.
           g_cursor_line_in_tc = G_CURR_LINE_110 -
                                 Tabctrl110-top_line + 1.

           SET CURSOR FIELD g_curfield110 LINE g_cursor_line_in_tc.
           check 1 = 2.
        Endif.
        If g_curfield = 'ZMM_CDHD_ST-TEL'.
          SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE 1.
        Else.

          If  tabctrl110-top_line <> l_old_top_line .
            SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE l_curr_row.
            l_old_top_line = tabctrl110-top_line.
            check 1 = 2.
          Endif.
          IF g_curfield110 = 'ZMM_CDITEM-DESC1'.
            Perform get_parno1.
            If g_parno = '1'.
              SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
            Else.
              SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE l_curr_row.
            Endif.

*           SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE G_CURR_LINE_110.
          Elseif g_curfield110 = 'ZMM_CDITEM-DESC2'.
            Perform get_parno1.
            If g_parno = '2'.
              If ZMM_CDITEM-UOM is initial.
                SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
              Else.
                SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE l_curr_row.
              Endif.
            Else.
              SET CURSOR FIELD 'ZMM_CDITEM-DESC3' LINE l_curr_row.
            Endif.
          Elseif g_curfield110 = 'ZMM_CDITEM-DESC3'.
            Perform get_parno1.
            If g_parno = '3'.
              If ZMM_CDITEM-UOM is initial.
                SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
              Else.
                SET CURSOR FIELD 'ZMM_CDITEM-DESC3' LINE l_curr_row.
              Endif.
            Else.
              SET CURSOR FIELD 'ZMM_CDITEM-DESC4' LINE l_curr_row.
            Endif.
          Elseif g_curfield110 = 'ZMM_CDITEM-DESC4'.
            If ZMM_CDITEM-UOM is initial.
              SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
            Else.
              SET CURSOR FIELD 'ZMM_CDITEM-DESC4' LINE l_curr_row.
            Endif.

          Elseif g_curfield110 = 'ZMM_CDITEM-UOM'.
*           TABCTRL110-TOP_LINE = G_CURR_LINE_110 .
*           TABCTRL110-CURRENT_LINE = G_CURR_LINE_110 + 1.
*           G_CURR_LINE_110 = G_CURR_LINE_110 + 1.

            SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE l_curr_row.
*        Elseif g_curfield110 = 'ZMM_CDITEM-ST_COND'  .
*           G_CURR_LINE_110 = G_CURR_LINE_110 + 1.
*           SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE G_CURR_LINE_110.
          Endif.
        Endif.
        l_old_top_line = tabctrl110-top_line.

    Endcase.
  Endif.
*
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

     if sy-tcode <> 'ZCODG'.

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

      endif.

      if g_TABLCTRL130_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
        wa_message-srno = g_TABLCTRL130_wa-srno.
        wa_message-msgtype = 'W'.
        wa_message-msgcode = 'Z'.
        wa_message-msgtext =
        'Detail Specification has been maintained for this line item'.

        append wa_message to ist_message.
      endif.

      clear wa_message.
    endloop.
*
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
  select single reqcpf werks from zmm_cdhd into (zmm_Cdhd_st-reqcpf ,
      zmm_Cdhd_st-werks) where reqno = zmm_cdhd_st-reqno.

  If ( g_mode = 'CHA' or g_mode ='REL' or g_mode = 'APR' )
       and zmm_cdhd_st-REQCPF <> ''
.
    If sy-uname <> zmm_cdhd_st-REQCPF.
      If  g_user = '' and ( g_mode = 'CHA' or g_mode = 'REL' ).
        message i020(zmm_oth).
        Perform Clear_var.
        leave to screen 100.
      Elseif g_user = 'M'.
        AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
                   ID 'WERKS' Field zmm_cdhd_st-werks
                   ID 'ACTVT'  FIELD '01'.
        If sy-subrc <> 0.
          g_change_auth = 'X'.
          message i061(zmm_oth) with zmm_cdhd_st-werks.
          Perform Clear_var.
*
          leave to screen 100.
        Endif.

      Endif.
    Elseif g_user = '' and g_mode = 'APR'.
      message i043(zmm_oth).
      Perform Clear_var.
      leave to screen 100.
    Endif.
  Endif.
Endform.
*ENDMODULE.                 " change_restrict  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_multi_sel_line  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_multi_sel_line OUTPUT.
  If sy-tcode = 'ZCODG'.
    TABLCTRL120-LINE_SEL_MODE = 2.
  Endif.
ENDMODULE.                 " set_multi_sel_line  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Status_104  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE Status_104 OUTPUT.
If okcode_100 = 'INS_MODI'.
   set pf-status '104'.
Endif.
ENDMODULE.                 " Status_104  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tabctrl110_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tabctrl110_attr OUTPUT.
 if ZMM_CDHD_ST-MTART = 'ZSTO' and sy-tcode <> 'ZCODG'.
    LOOP AT TABCTRL110-cols INTO cols110 WHERE index EQ 17.
      cols110-invisible = '1'.
      MODIFY TABCTRL110-cols FROM cols110 INDEX sy-tabix.
    ENDLOOP.
  endif.
ENDMODULE.                 " tabctrl110_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POP_MESSAGE OUTPUT.
 CALL FUNCTION 'ZMM_POPUP_IMAC_MESSAGE'
      EXPORTING
        arbgb             = 'ZMM'
        msgnr             = '861'
        msgty             = 'I'
      EXCEPTIONS
        user_cancel       = 1
        message_not_found = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL SCREEN '0100'.

ENDMODULE.                 " POP_MESSAGE  OUTPUT
