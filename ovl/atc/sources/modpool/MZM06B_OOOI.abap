*--- MAIN PROGRAM: MZM06B_OOOI ---*
*----------------------------------------------------------------------*
*   INCLUDE MM06BOOI
*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_TDP_FIELDS
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form determine_tdp_fields.

  g_matnr = eban-matnr.
  g_werks = eban-werks.
  perform marc_lookup.

  if g_taxgrp eq space.
    screen-input     = 0.
    screen-invisible = 1.
  else.
    if eban-matnr ne space.
      if eban-flief ne space or
         eban-reswk ne space.
        if screen-name = 'EBAN-OIHANTYP'.
          screen-input = 1.
          screen-invisible = 0.
        elseif screen-name = 'EBAN-OIINEX'.
          screen-input = 1.
          screen-invisible = 0.
        elseif screen-name = 'EBAN-OITAXFROM'.
          screen-input = 0.
          screen-invisible = 0.
        endif.
      else.
        screen-input = 0.
        screen-invisible = 1.
      endif.
    endif.
  endif.
endform.                               " DETERMINE_TDP_FIELDS

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TDP_HEADINGS
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_tdp_headings.

  if bsn-flief ne space.
    screen-invisible = 0.
  else.
    screen-invisible = 1.
  endif.

endform.                               " DISPLAY_TDP_HEADINGS

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TDP_FIELDS
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_tdp_fields.

  move: eban-matnr to g_matnr,
        eban-werks to g_werks.

  perform marc_lookup.

  if g_taxgrp = space.
    screen-invisible = 1.
    screen-input = 0.
  endif.

endform.                               " DISPLAY_TDP_FIELDS
*&---------------------------------------------------------------------*
*&      Form  MODIFY_TDP_FIELDS
*&---------------------------------------------------------------------*
form modify_tdp_fields.

  if eban-oihantyp is initial.
    screen-invisible = 1.
  endif.

endform.                    " MODIFY_TDP_FIELDS
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0300 output.
   set pf-status 'S300'.
   set titlebar 'T300'.

endmodule.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0305  OUTPUT
*&---------------------------------------------------------------------*
*       PF Status of screen 305.
*----------------------------------------------------------------------*
module status_0305 output.
  set pf-status 'S305'.
  set titlebar 'T305'.

endmodule.                 " STATUS_0305  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  t305_move_data  OUTPUT
*&---------------------------------------------------------------------*
*       Move data from ist_remark into table control.
*----------------------------------------------------------------------*
module t305_move_data output.

   move-corresponding wa_remark to wa_tc305 .

endmodule.                 " t305_move_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  move_sel  OUTPUT
*&---------------------------------------------------------------------*
*      Move Selected Rejected Item to internal table
*----------------------------------------------------------------------*
module move_sel output.
*loop at sel.
*  move sel-bnfpo to wa_remark-bnfpo.
*  append wa_remark to ist_remark.
*endloop.
endmodule.                 " move_sel  OUTPUT
