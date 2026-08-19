*--- MAIN PROGRAM: MZMMCDCELLTABMAINTO01 ---*
***INCLUDE MZMMCDCELLTABMAINTO01 .
*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT110_init output.
  if g_TCT110_copied is initial.
*&spwizard: copy ddic-table 'ZMM_CDCODIFIER'
*&spwizard: into internal table 'g_TCT110_itab'
   select * from ZMM_CDCODIFIER
       into corresponding fields
       of table g_TCT110_itab.

    g_TCT110_copied = 'X'.
    refresh control 'TCT110' from screen '0110'.
  endif.
*  if not g_itab_cp110[] is initial.
*   refresh control 'TCT110' from screen '0110'.
*  endif.
endmodule.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: move itab to dynpro
module TCT110_move output.
  move-corresponding g_TCT110_wa to ZMM_CDCODIFIER.
endmodule.

*&spwizard: output module for tc 'TCT110'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT110_get_lines output.
  g_TCT110_lines = sy-loopc.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT120_init output.
*  clear g_modifier.
*  refresh g_tct120_itab.
  if g_TCT120_copied is initial.
*&spwizard: copy ddic-table 'ZMM_MODIFIER'
*&spwizard: into internal table 'g_TCT120_itab'
*   perform make_select_statement.
   if zmm_modifier_st-desc1 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab.
   else.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1 = zmm_modifier_st-desc1.
   endif.
    g_TCT120_copied = 'X'.
    refresh control 'TCT120' from screen '0120'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: move itab to dynpro
module TCT120_move output.
  move-corresponding g_TCT120_wa to ZMM_MODIFIER.
endmodule.

*&spwizard: output module for tc 'TCT120'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT120_get_lines output.
  g_TCT120_lines = sy-loopc.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT130_init output.
  if g_TCT130_copied is initial.
*&spwizard: copy ddic-table 'TER15'
*&spwizard: into internal table 'g_TCT130_itab'
    select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu.
    g_TCT130_copied = 'X'.
    refresh control 'TCT130' from screen '0130'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: move itab to dynpro
module TCT130_move output.
  move-corresponding g_TCT130_wa to TER15.
endmodule.

*&spwizard: output module for tc 'TCT130'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT130_get_lines output.
  g_TCT130_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  fill_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_dynnr OUTPUT.
  case tabscr_cd-activetab.
    when 'CDF'.
      dynnr = '0110'.
    when 'MDF'.
      dynnr = '0120'.
    when 'DIC'.
      dynnr = '0130'.
    when 'MDL'.
      dynnr = '0140'.
    when others.
      dynnr = '0110'.
      tabscr_cd-activetab = 'CDF'.
   endcase.

ENDMODULE.                 " fill_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'OPTNS'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: copy ddic-table to itab
module TCT140_init output.
  if g_TCT140_copied is initial.
*&spwizard: copy ddic-table 'ZMM_MDL'
*&spwizard: into internal table 'g_TCT140_itab'
    select * from ZMM_MDL
       into corresponding fields
       of table g_TCT140_itab.
    g_TCT140_copied = 'X'.
    refresh control 'TCT140' from screen '0140'.
  endif.
endmodule.

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: move itab to dynpro
module TCT140_move output.
  move-corresponding g_TCT140_wa to ZMM_MDL.
endmodule.

*&spwizard: output module for tc 'TCT140'. do not change this line!
*&spwizard: get lines of tablecontrol
module TCT140_get_lines output.
  g_TCT140_lines = sy-loopc.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  TCT140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT140_change_field_attr OUTPUT.
  loop at screen.
    if screen-name = 'ZMM_MDL-MDLNO'.
      if not g_TCT140_wa-mdlno is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
  endloop.
ENDMODULE.                 " TCT140_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT130_change_field_attr OUTPUT.
 loop at screen.
    if screen-name = 'TER15-BEGRIFF'.
      if not g_TCT130_wa-begriff is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
  endloop.

ENDMODULE.                 " TCT130_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT120_change_field_attr OUTPUT.
  loop at screen.
    if screen-name = 'ZMM_MODIFIER-MATGRP'.
       if not g_tct120_wa-matgrp is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC1'.
       if not g_tct120_wa-desc1 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC2'.
       if not g_tct120_wa-desc2 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC3'.
       if not g_tct120_wa-desc3 is initial.
         screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_MODIFIER-DESC4'.
       if not g_tct120_wa-desc4 is initial.
         screen-input = 0.
        modify screen.
       endif.
    endif.
  endloop.
ENDMODULE.                 " TCT120_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TCT110_change_field_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TCT110_change_field_attr OUTPUT.
 loop at screen.
    if screen-name = 'ZMM_CDCODIFIER-CODIFIER'.
       if not g_tct110_wa-codifier is initial.
        screen-input = 0.
        modify screen.
       endif.
    elseif screen-name = 'ZMM_CDCODIFIER-MATGP'.
      if not g_tct110_wa-matgp is initial.
        screen-input = 0.
        modify screen.
      endif.
    elseif screen-name = 'ZMM_CDCODIFIER-STATUS'.
      if not g_tct110_wa-status is initial.
        screen-input = 0.
        modify screen.
      endif.
    endif.
 endloop.
ENDMODULE.                 " TCT110_change_field_attr  OUTPUT
