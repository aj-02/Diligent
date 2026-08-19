*--- MAIN PROGRAM: MZMMCDCELLTABMAINTI01 ---*
***INCLUDE MZMMCDCELLTABMAINTI01 .
*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: modify table
module TCT110_modify input.
  move-corresponding ZMM_CDCODIFIER to g_TCT110_wa.
  modify g_TCT110_itab
    from g_TCT110_wa
    index TCT110-current_line.
  if sy-subrc <> 0.
    append g_TCT110_wa to g_TCT110_itab.
  endif.
  g_sav110 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: mark table
module TCT110_mark input.
  if TCT110-line_sel_mode = 1 and
     g_TCT110_wa-flag = 'X'.
     loop at g_TCT110_itab into g_TCT110_wa
       where flag = 'X'.
       g_TCT110_wa-flag = ''.
       modify g_TCT110_itab
         from g_TCT110_wa
         transporting flag.
     endloop.
     g_TCT110_wa-flag = 'X'.
  endif.
  modify g_TCT110_itab
    from g_TCT110_wa
    index TCT110-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: process user command
module TCT110_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT110'
                              'G_TCT110_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: modify table
module TCT120_modify input.
  move-corresponding ZMM_MODIFIER to g_TCT120_wa.
  move sy-uname to g_tct120_wa-created_by.
  move sy-datum to g_tct120_wa-create_date.
  modify g_TCT120_itab
    from g_TCT120_wa
    index TCT120-current_line.
  if sy-subrc <> 0.
    append g_TCT120_wa to g_TCT120_itab.
  endif.
  g_sav120 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: mark table
module TCT120_mark input.
  if TCT120-line_sel_mode = 1 and
     g_TCT120_wa-flag = 'X'.
     loop at g_TCT120_itab into g_TCT120_wa
       where flag = 'X'.
       g_TCT120_wa-flag = ''.
       modify g_TCT120_itab
         from g_TCT120_wa
         transporting flag.
     endloop.
     g_TCT120_wa-flag = 'X'.
  endif.
  modify g_TCT120_itab
    from g_TCT120_wa
    index TCT120-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: process user command
module TCT120_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT120'
                              'G_TCT120_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: modify table
module TCT130_modify input.
  move-corresponding TER15 to g_TCT130_wa.
  move sy-uname to g_tct130_wa-cr_user.
  move sy-datum to g_tct130_wa-datemod.
  modify g_TCT130_itab
    from g_TCT130_wa
    index TCT130-current_line.
  if sy-subrc <> 0.
    append g_TCT130_wa to g_TCT130_itab.
  endif.
  g_sav130 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: mark table
module TCT130_mark input.
  if TCT130-line_sel_mode = 1 and
     g_TCT130_wa-flag = 'X'.
     loop at g_TCT130_itab into g_TCT130_wa
       where flag = 'X'.
       g_TCT130_wa-flag = ''.
       modify g_TCT130_itab
         from g_TCT130_wa
         transporting flag.
     endloop.
     g_TCT130_wa-flag = 'X'.
  endif.
  modify g_TCT130_itab
    from g_TCT130_wa
    index TCT130-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: process user command
module TCT130_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT130'
                              'G_TCT130_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
 Case okcode100.
   When 'BAC' or 'CAN' or 'EXT'.
   clear: g_sav110,g_sav120,g_sav130,g_sav140.
    set screen 0.
    leave screen.
   When 'SAV'.
***
    delete from zmm_cdcodifier
           where codifier is null.
    delete from zmm_modifier
           where matgrp is null and
                 desc1  is null and
                 desc2  is null.
    delete from zmm_mdl
           where mdlno is null.
    delete from ter15
           where begriff is null and
                 spras = sy-langu.
***
    if not g_itab_del110 is initial.
      loop at g_itab_del110 into g_wa_del110.
        delete from zmm_cdcodifier
        where codifier = g_wa_del110-codifier and
              matgp    = g_wa_del110-matgp  and
              status   = g_wa_del110-status.
      endloop.
    endif.

    if not g_itab_del120 is initial.
      loop at g_itab_del120 into g_wa_del120.
        delete from zmm_modifier
        where matgrp = g_wa_del120-matgrp and
              desc1  = g_wa_del120-desc1 and
              desc2  = g_wa_del120-desc2 and
              desc3  = g_wa_del120-desc3 and
              desc4  = g_wa_del120-desc4.
      endloop.
    endif.

    if not g_itab_del130 is initial.
      loop at g_itab_del130 into g_wa_del130.
        delete from ter15
        where begriff  = g_wa_del130-begriff and
              spras    = sy-langu.
      endloop.
    endif.

    if not g_itab_del140 is initial.
      loop at g_itab_del140 into g_wa_del140.
        delete from zmm_mdl
        where mdlno  = g_wa_del140-mdlno.
      endloop.
    endif.
*Saving Codifier table changes.
   IF g_sav110 = 'Y'.
    loop at g_tct110_itab into g_tct110_wa
         where not codifier is initial.
     move-corresponding g_tct110_wa to g_cdcodifier_wa.
     append g_cdcodifier_wa to g_cdcodifier_itab.
    endloop.
    modify  zmm_cdcodifier from table g_cdcodifier_itab.
   ENDIF.
*Saving Modifier table changes.
   IF g_sav120 = 'Y'.
    loop at g_tct120_itab into g_tct120_wa
         where not desc1 is initial and
               not desc2 is initial.
     move-corresponding g_tct120_wa to g_modifier_wa.
*     move sy-uname to g_modifier_wa-created_by.
*     move sy-datum to g_modifier_wa-create_date.
     append g_modifier_wa to g_modifier_itab.
    endloop.
    modify  zmm_modifier from  table g_modifier_itab.
   ENDIF.
*Saving Dictionary table changes.
   IF g_sav130 = 'Y'.
    loop at g_tct130_itab into g_tct130_wa
         where not begriff is initial.
     move-corresponding g_tct130_wa to g_ter15_wa.
*     move sy-uname to g_ter15_wa-cr_user.
*     move sy-datum to g_ter15_wa-datemod.
     move sy-langu to g_ter15_wa-spras.
     append g_ter15_wa to g_ter15_itab.
    endloop.
    modify  ter15 from table g_ter15_itab.
   ENDIF.

   IF g_sav140 = 'Y'.
    loop at g_tct140_itab into g_tct140_wa
         where not mdlno is initial..
     move-corresponding g_tct140_wa to g_mdl_wa.
*     move sy-uname to g_ter15_wa-cr_user.
*     move sy-datum to g_ter15_wa-datemod.
     append g_mdl_wa to g_mdl_itab.
    endloop.
    modify  zmm_mdl from table g_mdl_itab.
   ENDIF.

   commit work.
   message i080(zmm_oth).
   set screen 0.
   leave screen.

   when 'CDF' or 'MDF' or 'DIC' or 'MDL'.
     tabscr_cd-activetab = okcode100.
 Endcase.
*
 IF tabscr_cd-activetab = 'MDF'.
    OK_CODE = sy-ucomm.

    perform user_ok_tc using  'TCT120'
                              'G_TCT120_ITAB'
                              'FLAG'
                     changing OK_CODE.
*    clear ok_code.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'CDF'.
    OK_CODE = sy-ucomm.
    perform user_ok_tc using  'TCT110'
                              'G_TCT110_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'DIC'.
    OK_CODE = sy-ucomm.

    perform user_ok_tc using  'TCT130'
                              'G_TCT130_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
 ELSEIF tabscr_cd-activetab = 'MDL'.
    OK_CODE = sy-ucomm.
    perform user_ok_tc using  'TCT140'
                              'G_TCT140_ITAB'
                              'FLAG'
                     changing OK_CODE.
    sy-ucomm = OK_CODE.
*    clear ok_code.
 ENDIF.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_desc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_desc INPUT.
 IF not zmm_modifier_st-desc1 is initial.
   translate zmm_modifier_st-desc1 using '*%'.
   condense zmm_modifier_st-desc1. " no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc2 is initial.
   translate zmm_modifier_st-desc2 using '*%'.
   condense zmm_modifier_st-desc2. " no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc3 is initial.
   translate zmm_modifier_st-desc3 using '*%'.
   condense zmm_modifier_st-desc3. "  no-gaps.
 ENDIF.
 IF not zmm_modifier_st-desc4 is initial.
   translate zmm_modifier_st-desc4 using '*%'.
   condense zmm_modifier_st-desc4." no-gaps.
 ENDIF.

 if    zmm_modifier_st-desc1 is initial
   and zmm_modifier_st-matgrp is initial
   and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab.
 elseif not zmm_modifier_st-matgrp is initial
        and zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp.
 elseif not zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp
       and   desc1  like zmm_modifier_st-desc1.
 elseif not zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and not zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where matgrp = zmm_modifier_st-matgrp
       and   desc1  like zmm_modifier_st-desc1
       and   desc2  like zmm_modifier_st-desc2.
 elseif zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1  like zmm_modifier_st-desc1.
 elseif zmm_modifier_st-matgrp is initial
        and not zmm_modifier_st-desc1 is initial
        and not zmm_modifier_st-desc2 is initial.
    select * from ZMM_MODIFIER
       into corresponding fields
       of table g_TCT120_itab
       where desc1  like zmm_modifier_st-desc1
       and   desc2  like zmm_modifier_st-desc2.
 endif.
   refresh control 'TCT120' from screen '0120'.

ENDMODULE.                 " check_desc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_word  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_word INPUT.
   data: l_word like ter15-begriff,
         l_len type i.
 IF not g_word is initial.
   translate g_word using '*%'.
   condense g_word."no-gaps.
 ENDIF.
 IF g_word is initial.
    select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu.
 ELSE.
*   l_len = strlen( g_word ).
   select * from TER15
       into corresponding fields
       of table g_TCT130_itab
    where spras = sy-langu
    and begriff like g_word.
*    delete g_tct130_itab where begriff+0(l_len) <> g_word.
 ENDIF.
ENDMODULE.                 " check_word  INPUT

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: modify table
module TCT140_modify input.
  translate zmm_mdl-mdlno to upper case.
  move-corresponding ZMM_MDL to g_TCT140_wa.
  translate g_TCT140_wa-mdlno to upper case.
  move sy-uname to g_tct140_wa-creby.
  move sy-datum to g_tct140_wa-credt.
  modify g_TCT140_itab
    from g_TCT140_wa
    index TCT140-current_line.
  if sy-subrc <> 0.
    append g_TCT140_wa to g_TCT140_itab.
  endif.
  g_sav140 = 'Y'.
endmodule.

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: mark table
module TCT140_mark input.
  if TCT140-line_sel_mode = 1 and
     g_TCT140_wa-flag = 'X'.
     loop at g_TCT140_itab into g_TCT140_wa
       where flag = 'X'.
       g_TCT140_wa-flag = ''.
       modify g_TCT140_itab
         from g_TCT140_wa
         transporting flag.
     endloop.
     g_TCT140_wa-flag = 'X'.
  endif.
  modify g_TCT140_itab
    from g_TCT140_wa
    index TCT140-current_line
    transporting flag.
endmodule.

*&spwizard: input module for tc 'TCT140'. do not change this line!
*&spwizard: process user command
module TCT140_user_command input.
  OK_CODE = sy-ucomm.
  perform user_ok_tc using    'TCT140'
                              'G_TCT140_ITAB'
                              'FLAG'
                     changing OK_CODE.
  sy-ucomm = OK_CODE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  check_mdlno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mdlno INPUT.
  Data: l_mdlno like zmm_mdl-mdlno.

 IF not g_mdlno is initial.
   translate g_mdlno to upper case.
   translate g_mdlno using '*%'.
   condense g_mdlno." no-gaps.
 ENDIF.

 IF g_mdlno is initial.
    select * from zmm_mdl
       into corresponding fields
       of table g_TCT140_itab.
 ELSE.
*   l_len = strlen( g_word ).
   select * from zmm_mdl
       into corresponding fields
       of table g_TCT140_itab
    where mdlno like g_mdlno.
 ENDIF.

ENDMODULE.                 " check_mdlno  INPUT
