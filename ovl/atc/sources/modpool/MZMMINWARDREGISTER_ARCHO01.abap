*--- MAIN PROGRAM: MZMMINWARDREGISTER_ARCHO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMINWARDREGISTERO01                                      *
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 26/09/2008      <RD1K960036>    SAB_SUMODH
*
* 1) Removed the Problematic Statement Error in Line 50.
************************************************************************


*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*& For PF Status & Title bar selection
*----------------------------------------------------------------------*
module status_9000 output.

  clear: g_ok_code, sy-ucomm.
  g_mode = 'Main Menu'.
* start of change on 17/7/2003 to get the values from memory in case of
* GR pending report, in case of GR pending report user should get only
* the display option (Report ZMM_GRSTOC_PENDING).

  data : l_chg(1) .
  import l_chg from memory id 'GR' .
  if   sy-subrc <> 0 .
* End of change on 17/7/2003
    if  sy-ucomm = 'INW'.
      case 'X'.
        when g_crea.
          g_mode = 'Create'.
        when g_disp.
          g_mode = 'Display'.
        when g_chan.
          g_mode = 'Change'.
        when g_dele.
          g_mode = 'Delete'.
      endcase.

    endif.
  else .
* start of change on 17/7/2003 to allow user to go only in display mode
* in case of report ZMM_GRSTOC_PENDING.
    g_status = 'X' .
    g_disp = 'X' .
    g_crea = ' ' .
    g_chan = ' ' .
    " Begin of <RD1K960036>.
    free memory .                                           "#EC *
    " End of <RD1K960036>.


  endif .
* End of change on 17/7/2003 .
  set titlebar  'INWARD' with g_mode.
  set pf-status 'INWARD2'.

endmodule.                 " STATUS_9000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*& To set Title Bar & mode
*----------------------------------------------------------------------*
module status_9010 output.

*  if g_flg = 'Y'.

*    if  sy-ucomm = 'INW'.
  case 'X'.
    when g_crea.
      g_mode = 'Create'.
    when g_disp.
      g_mode = 'Display'.
    when g_chan.
      g_mode = 'Change'.
    when g_dele.
      g_mode = 'Delete'.
  endcase.
*    endif.

  set pf-status 'INWARD1'.
  set titlebar  'INWARD' with g_mode.

*  endif.

endmodule.                 " STATUS_9010  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  fetch_data_9010  OUTPUT
*&---------------------------------------------------------------------*
*& To fetch data if RCN no. is keyed in
*----------------------------------------------------------------------*
module fetch_data_9010 output.

  if not zmm_inwardhd-rcnno is initial.
    if g_flg = 'Y'.

      select single * from zmm_cnfrcnhd
        where rcnno = zmm_inwardhd-rcnno.
      if sy-subrc ne 0 .
        message e000 with 'No record found in RCN Table. Check input.'.
      else.
        if zmm_cnfrcnhd-inwrflg = 'I'.
          message e028 with zmm_inwardhd-rcnno.
        endif.
      endif.
      select * into table ist_inwarddt from zmm_cnfrcndt
        where rcnno = zmm_inwardhd-rcnno.
      if ist_inwarddt[] is initial .
        message e000 with 'No record found in RCN Table. Check input.'.
      else.

        loop at ist_inwarddt.
          select single * from zmm_cnfinwr
            where inwrd = ist_inwarddt-inwrd.
          if sy-subrc eq 0.
            move: zmm_cnfinwr-indat   to ist_inwarddt-indat,
                  zmm_cnfinwr-indelno to ist_inwarddt-indelno,
                  zmm_cnfinwr-lrben   to ist_inwarddt-lrben,
                  zmm_cnfinwr-lrdat   to ist_inwarddt-lrdat,
                  zmm_cnfinwr-docty   to ist_inwarddt-docty,
                  zmm_cnfinwr-ccncd   to ist_inwarddt-ccncd,
                  zmm_cnfinwr-actwt   to ist_inwarddt-actwt,
                  zmm_cnfinwr-wtuom   to ist_inwarddt-wtuom,
                  zmm_cnfinwr-wtchr   to ist_inwarddt-wtchr,
                  zmm_cnfinwr-chwtuom to ist_inwarddt-chwtuom,
                  zmm_cnfinwr-packs   to ist_inwarddt-packs.
            if not ist_inwarddt-indelno is initial.
* Inserted on 14.07.2003
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ist_inwarddt-indelno
                IMPORTING
                  output = ist_inwarddt-indelno.

*End of insertion 14.07.2003

              select single * from likp
                where vbeln = ist_inwarddt-indelno.
              if sy-subrc eq 0.
                move: likp-lfdat to ist_inwarddt-lfdat,
                      likp-traid to ist_inwarddt-traid.
              endif.
            endif.
            modify ist_inwarddt.
          endif.
        endloop.
      endif .
      describe table ist_inwarddt lines disprec-lines.
      g_flg = 'N'.
    endif.
  else.
*    if not ist_inwarddt[] is initial.
*      DESCRIBE TABLE ist_inwarddt LINES disprec-lines.
*     endif.
  endif.

endmodule.                 " fetch_data_9010  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  block_editing  OUTPUT
*&---------------------------------------------------------------------*
*& To disable certain fields in Table Control
*----------------------------------------------------------------------*
module block_editing output.

  if not zmm_inwardhd-rcnno is initial
     or  g_mode = 'Display'
     or  g_mode = 'Delete'.

    loop at screen.
      " if screen-group1 = 'IN1' or
      if  g_mode = 'Display'    or
        g_mode = 'Delete'.
        screen-input = 0.
        modify screen.

      endif.
    endloop.
  endif.

  IF g_mode = 'SAVE' AND err = 'X'.

    loop at screen.
      if screen-group1 = 'IN1'.
        screen-input = 1.
        screen-active = 1.
        modify screen.
      endif.
    endloop.
    CLEAR: err.
  ENDIF.

  if g_mode = 'Change'.
    loop at screen.
      if screen-group2 = 'IN2'.
        screen-input = 0.
        modify screen.
      endif.
    endloop.
  endif.

  IF g_mode = 'Create'.
    loop at screen.
     IF screen-name = 'ZMM_INWARDHD-EBELN' and EKKO-LIFNR is not INITIAL.
      screen-input = 0.
      modify screen.
    endif.
    endloop.
  ENDIF.

endmodule.                 " block_editing  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  status_9020  OUTPUT
*&---------------------------------------------------------------------*
*& Title & PF Status setting for screen 9020
*----------------------------------------------------------------------*
module status_9020 output.
*g_crea = 'Display'.
*  if not sy-ucomm is initial.
*    case 'X'.
*      when g_crea.
*        g_mode = 'Create'.
*      when g_chan.
*        g_mode = 'Change'.
*      when g_disp.
*        g_mode = 'Display'.
*      when g_dele.
*        g_mode = 'Delete'.
*    endcase.
*  endif.
*
*  clear ist_tab_type .
*  refresh ist_tab_type .
*
*  set pf-status 'INWARD2'.
*
*  set titlebar  'INWARD' with g_mode.
*
*  get parameter id 'ZINWNO' field zmm_inwardhd-inwno.
g_crea = 'Display'.
  if not sy-ucomm is initial.
    case 'X'.
      when g_crea.
        g_mode = 'Create'.
      when g_chan.
        g_mode = 'Change'.
      when g_disp.
        loop at screen.
          if screen-name = 'P_ARCH'.
             screen-invisible = 0.
             modify screen.
          endif.
        endloop.
        g_mode = 'Display'.
      when g_dele.
        g_mode = 'Delete'.
    endcase.
  endif.

  clear ist_tab_type .
  refresh ist_tab_type .

  set pf-status 'INWARD2'.

  set titlebar  'INWARD' with g_mode.

  get parameter id 'ZINWNO' field zmm_inwardhd-inwno.


endmodule.                 " status_9020  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  status_9030  OUTPUT
*&---------------------------------------------------------------------*
*& Title & PF Status setting for screen 9030
*----------------------------------------------------------------------*
module status_9030 output.

  if not sy-ucomm is initial.
    case 'X'.
      when g_crea.
        g_mode = 'Create'.
      when g_chan.
        g_mode = 'Change'.
        set pf-status 'INWARD1'.
      when g_disp.
        g_mode = 'Display'.
        set pf-status 'INWARD2'.
      when g_dele.
        g_mode = 'Delete'.
        set pf-status 'INWARD3'.
    endcase.
  endif.

  set titlebar  'INWARD' with g_mode.

endmodule.                 " status_9030  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_attr OUTPUT.
  loop at screen.


* Begin of <> on 13112013
    SHIFT ist_inwarddt-indelno LEFT DELETING LEADING '0'.


    if not ZMM_INWARDHD-EBELN is initial.
      if g_ksskflag <> 'X' and g_ksskflag is INITIAL.

        if screen-name = 'IST_INWARDDT-INDELNO'.
          screen-input = 1.
*          screen-required = 1.
          modify screen.
        endif.
      endif.
    endif.

* End of <> 13112013


    if g_mode = 'Create' OR  g_mode = 'Change'.
* Begin of <> on 13112013


      if  IST_INWARDDT-LADNO is initial.
        if screen-name = 'IST_INWARDDT-LADDT' OR
          screen-name = 'IST_INWARDDT-LADCUR' OR
          screen-name = 'IST_INWARDDT-LADAMT'.
          screen-active = 0.
          modify screen.
        endif.
      ELSE.
        if screen-name = 'IST_INWARDDT-LADDT' OR
            screen-name = 'IST_INWARDDT-LADCUR' OR
            screen-name = 'IST_INWARDDT-LADAMT'.

          screen-active  = 1.
          screen-INPUT = 1.

          modify screen.
        endif.
      endif."cab_dns


* End of <> on 13112013

**      IF screen-name = 'IST_INWARDDT-LADDT' AND not IST_INWARDDT-LADNO is initial .
**        screen-required = 1.
**          set CURSOR FIELD IST_INWARDDT-LADDT.
**      ENDIF.
**
**      if screen-name = 'IST_INWARDDT-LADCUR'.
**        if NOT IST_INWARDDT-LADAMT IS INITIAL.
**          screen-required = 1.
**          set CURSOR FIELD IST_INWARDDT-LADAMT.
**          modify screen.
**        endif.
**      endif.


      if NOT ZMM_INWARDHD-RCNNO is initial.
        if screen-name = 'IST_INWARDDT-LADCUR'.
          if NOT IST_INWARDDT-LADCUR IS INITIAL.
            screen-input = 0.
            modify screen.
          endif.
        endif.
        if screen-name = 'IST_INWARDDT-LRDAT'.
          if not IST_INWARDDT-LRDAT is initial.
            screen-input = 0.
            modify screen.
          endif.
        endif.
      endif.
*       endif.
    endif.
    if g_mode = 'Change'.
      if NOT ZMM_INWARDHD-RCNNO is initial.
        if screen-name = 'IST_INWARDDT-LADCUR'.
          if NOT IST_INWARDDT-LADCUR IS INITIAL.
            screen-input = 0.
            modify screen.
          endif.
        endif.
        if screen-name = 'IST_INWARDDT-LRDAT'.
          if not IST_INWARDDT-LRDAT is initial.
            screen-input = 0.
            modify screen.
          endif.
        endif.
      endif.
    endif.
  endloop.
* Begin of <> on 06122013
*break cab_sudhir.

  if not g_sus_asn-deliv_ext is initial.
    if not ist_inwarddt-indelno is initial.
      if ist_inwarddt-lrben is initial or
         ist_inwarddt-lrdat is initial or
         ist_inwarddt-docty is initial or
         ist_inwarddt-packr is initial or
         ist_inwarddt-packs is initial or
         ist_inwarddt-itemsrecd is initial.

        loop at screen.
          if screen-name = 'IST_INWARDDT-LRBEN'     OR
             screen-name = 'IST_INWARDDT-LRDAT'     OR
             screen-name = 'IST_INWARDDT-DOCTY'     OR
             screen-name = 'IST_INWARDDT-PACKS'     OR
             screen-name = 'IST_INWARDDT-PACKR'     OR
             screen-name = 'IST_INWARDDT-ITEMSRECD'.

            screen-required = 1.
            IF ist_inwarddt-packs is initial.
              set CURSOR FIELD ist_inwarddt-packs.
            ENDIF.

            message s994(zmm).

            modify screen.
          endif.
        endloop.
      endif.
    endif.
  endif.

* End of <> on 06122013
* 11122013

* 11122013
*  if not ZMM_INWARDHD-EBELN is initial.                     " 25112013
*    if ist_inwarddt-lrben is initial or
*   ist_inwarddt-lrdat is initial or
*   ist_inwarddt-docty is initial or
*   ist_inwarddt-packr is initial or
*   ist_inwarddt-packs is initial or
*   ist_inwarddt-itemsrecd is initial.
*  set cursor FIELD ist_inwarddt-lrben line DISPREC-CURRENT_LINE.
*      loop at screen.
*        if screen-name = 'IST_INWARDDT-PACKS' OR
*           screen-name = 'IST_INWARDDT-PACKS' OR
*           screen-name = 'IST_INWARDDT-ITEMSRECD'.
*          screen-required = 1.
*          modify screen.
*        endif.
*      endloop.
*
*      message e994(zmm).
*    endif.
*  endif.

ENDMODULE.                 " field_attr  OUTPUT
