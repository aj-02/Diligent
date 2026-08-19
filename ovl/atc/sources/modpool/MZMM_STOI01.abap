*--- MAIN PROGRAM: MZMM_STOI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMM_STOI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  case okcode.
    when 'CANC' or 'EXIT' or 'BACK'.
      leave to screen '0'.
  endcase.

ENDMODULE.                 " exit  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit200 INPUT.
  case okcode.
    when 'CANC' or 'EXIT' or 'BACK'.
      leave to screen '0'.
  endcase.
ENDMODULE.                 " exit200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  data:l_tabix like sy-tabix,
  var(22),
  l_rec,
l_ebelp like ist_display-ebelp.
  case okcode.
    when 'SEL'.
      loop at ist_display.
        ist_display-sel = 'X'.
        modify ist_display index sy-tabix.
      endloop.
      sel_flag = 'X'.
    when 'UNSEL'.
      loop at ist_display where sel = 'X'.
        ist_display-sel = ' '.
        modify ist_display index sy-tabix.
      endloop.
      loop at ist_display.
      endloop.
      sel_flag = ' '.
    when 'DISP'.
      clear ist_display.
      read table ist_display with key sel = 'X'.
      set parameter id 'BES' field ist_display-ebeln.
      call transaction 'ME23N' and skip first screen.
      set screen '0200'.
    when 'DELETE'.
      delete ist_display1 where sel <> 'X'.
      if sel_flag = ' ' and not ist_display1 is initial.
        refresh ist_display.
        ist_display[] = ist_display1[].
        refresh ist_display1.
      endif.

      perform open_group.

      loop at ist_display where sel = 'X'.
        l_tabix = sy-tabix.
*        if l_rec = ' '.
        perform bdc_dynpro      using 'SAPMM06E' '0105'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RM06E-BSTNR'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'RM06E-BSTNR'
                                      IST_DISPLAY-EBELN.
*        endif.
*        if ist_display-ebelp > 15.
*          ist_display-ebelp = ist_display-ebelp - 14.
*          if ist_display-ebelp < 10.
*            condense ist_display-ebelp.
*            concatenate '0' ist_display-ebelp into ist_display-ebelp.
*            concatenate 'RM06E-TCSELFLAG(' ist_display-ebelp(2) ')'
*            into var.
*          else.
            concatenate 'RM06E-TCSELFLAG(' ist_display-ebelp+3(2) ')'
            into var.
*          endif.

        perform bdc_dynpro      using 'SAPMM06E' '0120'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RM06E-TCSELFLAG(01)'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'RM06E-EBELP'
                                       ist_display-ebelp.


        perform bdc_dynpro      using 'SAPMM06E' '0120'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RM06E-TCSELFLAG(01)'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=DL'.
        perform bdc_field       using  'RM06E-TCSELFLAG(01)'
                                       'X'.



*        else.
*          concatenate 'RM06E-TCSELFLAG(' ist_display-ebelp+3(2) ')'
*          into var.
*          perform bdc_dynpro      using 'SAPMM06E' '0120'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        VAR.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=DL'.
**          perform bdc_field       using 'RM06E-EBELP'
**                                        '1'.
*          perform bdc_field       using  VAR
*                                         'X'.
*
*        endif.

*        l_rec = 'X'.
        perform bdc_dynpro      using 'SAPMM06E' '0120'.
        perform bdc_field       using 'BDC_CURSOR'
                                       'RM06E-TCSELFLAG(01)'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=BU'.

*        perform bdc_dynpro      using 'SAPMM06E' '0120'.
*
*        perform bdc_field       using 'BDC_OKCODE'
*                                      '/00'.
*
*
        perform bdc_dynpro      using 'SAPLSPO1' '0300'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=YES'.
        perform bdc_transaction using 'ME22' .

        if sy-subrc = 0.
          message S349(zmm).
          delete ist_display index l_tabix. "where sel = 'X' .
        endif.
      endloop.

      perform close_group.





    when 'COMP'.
      refresh ist_display1.
      import ist_count from memory id 'COUNT'.
      perform open_group.
      loop at ist_display where sel = 'X'.
        l_tabix = sy-tabix.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MECHOB'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0002'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEOK'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_SELECT-EBELN'.
        perform bdc_field       using 'MEPO_SELECT-EBELN'
                                      ist_display-ebeln.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEV4001BUTTON'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=TABIDT6'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        do ist_display-ebelp times.
          perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=FORWARD3200'.
          perform bdc_field       using 'DYN_6000-LIST'
                              '                                      1'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'MEPO1313-ELIKZ'.
        enddo.
        perform bdc_field       using 'MEPO1313-ELIKZ'
                                      'X'.

        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO1313-ELIKZ'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MESAVE'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEBACK'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO1211-EMATN(01)'.

        perform bdc_transaction using 'ME22N'.
        if sy-subrc = 0.
          message S350(zmm).
          delete ist_display index l_tabix.
        endif.

      endloop.
      perform close_group.
    when 'LOCK'.
      perform open_group.
      loop at ist_display where sel = 'X'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MECHOB'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0002'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEOK'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_SELECT-EBELN'.
        perform bdc_field       using 'MEPO_SELECT-EBELN'
                                      ist_display-ebeln.
        perform bdc_field       using 'MEPO_SELECT-BSTYP_F'
                                      'X'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEV4001BUTTON'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEPO1211MALL'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MEPO1211LOCK'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLMEGUI' '0014'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=MESAVE'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'MEPO_TOPLINE-BSART'.
        perform bdc_dynpro      using 'SAPLSPO2' '0101'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=OPT1'.
        perform bdc_transaction using 'ME22N'.
      endloop.

      perform close_group.
    when 'BACK'.
      leave to screen '1000'.
  endcase.
  clear okcode.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_selected_lines  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_selected_lines INPUT.
  modify ist_display from ist_display index tbc_200-current_line.
  clear g_count.
ENDMODULE.                 " move_selected_lines  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_data INPUT.
  if okcode = 'DISP'. " or okcode = 'DELETE' or okcode = 'COMP'.
    loop at ist_display where sel = 'X'.
      g_count = g_count + 1.
    endloop..
    if g_count <> 1.
      clear okcode.
      message e348(zmm).
      refresh ist_display1.
      clear g_count.
    endif.
  endif.


ENDMODULE.                 " check_data  INPUT
