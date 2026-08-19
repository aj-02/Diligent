*--- MAIN PROGRAM: MZMMCDCELLTABMAINTTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCDCELLTABMAINTTOP                                       *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMCDCELLTABMAINT         .

***&spwizard: data declaration for tablecontrol 'TCT110'
*&spwizard: definition of ddic-table
tables:   ZMM_CDCODIFIER.
Controls: tabscr_cd type tabstrip.

*&spwizard: type for the data of tablecontrol 'TCT110'
types: begin of t_TCT110,
         CODIFIER like ZMM_CDCODIFIER-CODIFIER,
         MATGP like ZMM_CDCODIFIER-MATGP,
         STATUS like ZMM_CDCODIFIER-STATUS,
         flag,       "flag for mark column
       end of t_TCT110.

*&spwizard: internal table for tablecontrol 'TCT110'
data:     g_TCT110_itab   type t_TCT110 occurs 0,
          g_TCT110_wa     type t_TCT110. "work area
data:     g_TCT110_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT110' itself
controls: TCT110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TCT110'
data:     g_TCT110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm,
          OKCODE100 like sy-ucomm.

***&spwizard: data declaration for tablecontrol 'TCT120'
*&spwizard: definition of ddic-table
tables:   ZMM_MODIFIER.

*&spwizard: type for the data of tablecontrol 'TCT120'
types: begin of t_TCT120,
         MATGRP like ZMM_MODIFIER-MATGRP,
         DESC1 like ZMM_MODIFIER-DESC1,
         DESC2 like ZMM_MODIFIER-DESC2,
         DESC3 like ZMM_MODIFIER-DESC3,
         DESC4 like ZMM_MODIFIER-DESC4,
         CREATED_BY like ZMM_MODIFIER-CREATED_BY,
         CREATE_DATE like ZMM_MODIFIER-CREATE_DATE,
         flag,       "flag for mark column
       end of t_TCT120.

*&spwizard: internal table for tablecontrol 'TCT120'
data:     g_TCT120_itab   type t_TCT120 occurs 0,
          g_TCT120_wa     type t_TCT120. "work area
data:     g_TCT120_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT120' itself
controls: TCT120 type tableview using screen 0120.

*&spwizard: lines of tablecontrol 'TCT120'
data:     g_TCT120_lines  like sy-loopc.

***&spwizard: data declaration for tablecontrol 'TCT130'
*&spwizard: definition of ddic-table
tables:   TER15.

*&spwizard: type for the data of tablecontrol 'TCT130'
types: begin of t_TCT130,
         BEGRIFF like TER15-BEGRIFF,
         CR_USER like TER15-CR_USER,
         DATEMOD like TER15-DATEMOD,
         flag,       "flag for mark column
       end of t_TCT130.

*&spwizard: internal table for tablecontrol 'TCT130'
data:     g_TCT130_itab   type t_TCT130 occurs 0,
          g_TCT130_wa     type t_TCT130. "work area
data:     g_TCT130_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT130' itself
controls: TCT130 type tableview using screen 0130.

*&spwizard: lines of tablecontrol 'TCT130'
data:     g_TCT130_lines  like sy-loopc.

***&spwizard: data declaration for tablecontrol 'TCT140'
*&spwizard: definition of ddic-table
tables:   ZMM_MDL.

*&spwizard: type for the data of tablecontrol 'TCT140'
types: begin of t_TCT140,
         MDLNO like ZMM_MDL-MDLNO,
         CREBY like ZMM_MDL-CREBY,
         CREDT like ZMM_MDL-CREDT,
         flag,       "flag for mark column
       end of t_TCT140.

*&spwizard: internal table for tablecontrol 'TCT140'
data:     g_TCT140_itab   type t_TCT140 occurs 0,
          g_TCT140_wa     type t_TCT140. "work area
data:     g_TCT140_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT140' itself
controls: TCT140 type tableview using screen 0140.

*&spwizard: lines of tablecontrol 'TCT140'
data:     g_TCT140_lines  like sy-loopc.
**
DATA:  dynnr like sy-dynnr value '0110',
       zmm_modifier_st like zmm_modifier,
       g_word like ter15-begriff,
       g_mdlno like zmm_mdl-mdlno,
       g_init type c,
       g_sav110 type c,
       g_sav120 type c,
       g_sav130 type c,
       g_sav140 type c.
Data : g_selstr(300) type c.
Data : g_wa_del110 type t_tct110,
       g_wa_del120 type t_tct120,
       g_wa_del130 type t_tct130,
       g_wa_del140 type t_tct140.
DATA : g_itab_del110 type table of t_tct110,
       g_itab_cp110 type table of t_tct110,
       g_itab_del120 type table of t_tct120,
       g_itab_cp120 type table of t_tct120,
       g_itab_del130 type table of t_tct130,
       g_itab_cp130 type table of t_tct130,
       g_itab_del140 type table of t_tct140,
       g_itab_cp140 type table of t_tct140.
DATA: g_cdcodifier_wa like zmm_cdcodifier,
      g_cdcodifier_itab like zmm_cdcodifier occurs 0.
Data: g_modifier_wa like zmm_modifier,
      g_modifier_itab like zmm_modifier occurs 0.
Data: g_ter15_wa like ter15,
      g_ter15_itab like ter15 occurs 0.
Data: g_mdl_wa    like zmm_mdl,
      g_mdl_itab  like zmm_mdl occurs 0.
