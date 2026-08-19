*--- MAIN PROGRAM: MZMMCODREQ_ERROR_RESETTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCODREQTOP                                               *
*&                                                                     *
*&---------------------------------------------------------------------*
PROGRAM  SAPMZMMCODREQ.
*******************Tables**********************************************
Tables: Mara, Makt, Zmm_cdhd,Zmm_modifier,ZMM_CDHD_ST,
        ZMM_CODREQ_RSN,t001w,dd07t,zmm_cdcodifier. " zmm_mdl zmm_cditem
*******************Types************************************************
TYPES: BEGIN OF ty_zmm_mdl,
  mandt type mandt,
         reqno            TYPE zmatreqno,
         srno             type numc3,
         matcode          TYPE char9,
         rej_flg          TYPE zrejflag,
         comp_flg         TYPE zcompflag,
         rsn              TYPE zrsn,
         oth1             TYPE char1,
         desc1            TYPE zdesc_1,
         oth2             TYPE char1,
         desc2            TYPE zdesc_2,
         oth3             TYPE char1,
         desc3            TYPE zdesc_3,
         oth4             TYPE char1,
         desc4            TYPE zdesc_4,
         steuc            TYPE steuc,
         user_desc        TYPE zdesc5,
         desc_fin         TYPE zdesc88,
         desc_cdcell      TYPE zdesc87,
         uom              TYPE meins,
         partno           TYPE mfrpn,
         cap_code         TYPE zmatcod,
         cap_name         TYPE zdesc88,
         subass           TYPE zsubass,
         spa_grp          TYPE char2,
         oth_mdl          TYPE char1,
         mdlno            TYPE ausp-atwrt,
         manu             TYPE lifnr,
         auth_vend_code   TYPE lifnr,
         auth_vend_name   TYPE name1_gp,
         haz              TYPE stoff,
         haz_flg          TYPE zhaz,
         st_cond          TYPE raube,
         pack_cond        TYPE magrv,
         grwgt            TYPE brgew,
         wtunit           TYPE gewei,
         grvol            TYPE volum,
         volunit          TYPE voleh,
         envmat           TYPE zyn,
         tempcond         TYPE tempb,
         shlf_life        TYPE zshlf,
         shlf_life1       TYPE zshlf1,
         insur_mat        TYPE zyn,
         crc_mat          TYPE zyn,
         dms              TYPE doknr,
         codby            TYPE xubname,
         coddt            TYPE sydatum,
         codcrby          TYPE xubname,
         codcrdt          TYPE sydatum,
         deprt            TYPE afasl,
         astcls           TYPE zastcls,
         mat_life         TYPE zmatlife,
         matcost          TYPE zmatcost,
         matcatg          TYPE zmatcatg,
         matloc           TYPE zmatloc,
         valcls           TYPE bklas,
         wrkng_life       TYPE zshlf,
         matgp            TYPE char2,
         lvorm            TYPE lvorm,
         mat_fnd          type num4,
         dsflag           TYPE zdsflag,
         taxim            TYPE taxim1,
       END OF ty_zmm_mdl.

       data: zmm_mdl type ty_zmm_mdl.
TYPES: BEGIN OF ty_ZMM_CDITEM,
  mandt type mandt,
         reqno            TYPE zmatreqno,
         srno             TYPE numc3,
         matcode          TYPE char9,
         rej_flg          TYPE zrejflag,
         comp_flg         TYPE zcompflag,
         rsn              TYPE zrsn,
         oth1             TYPE char1,
         desc1            TYPE zdesc_1,
         oth2             TYPE char1,
         desc2            TYPE zdesc_2,
         oth3             TYPE char1,
         desc3            TYPE zdesc_3,
         oth4             TYPE char1,
         desc4            TYPE zdesc_4,
         steuc            TYPE steuc,
         user_desc        TYPE zdesc5,
         desc_fin         TYPE zdesc88,
         desc_cdcell      TYPE zdesc87,
         uom              TYPE meins,
         partno           TYPE mfrpn,
         cap_code         TYPE zmatcod,
         cap_name         TYPE zdesc88,
         subass           TYPE zsubass,
         spa_grp          TYPE char2,
         oth_mdl          TYPE char1,
         mdlno            TYPE ausp-atwrt,
         manu             TYPE lifnr,
         auth_vend_code   TYPE lifnr,
         auth_vend_name   TYPE name1_gp,
         haz              TYPE stoff,
         haz_flg          TYPE zhaz,
         st_cond          TYPE raube,
         pack_cond        TYPE magrv,
         grwgt            TYPE brgew,
         wtunit           TYPE gewei,
         grvol            TYPE volum,
         volunit          TYPE voleh,
         envmat           TYPE zyn,
         tempcond         TYPE tempb,
         shlf_life        TYPE zshlf,
         shlf_life1       TYPE zshlf1,
         insur_mat        TYPE zyn,
         crc_mat          TYPE zyn,
         dms              TYPE doknr,
         codby            TYPE xubname,
         coddt            TYPE sydatum,
         codcrby          TYPE xubname,
         codcrdt          TYPE sydatum,
         deprt            TYPE afasl,
         astcls           TYPE zastcls,
         mat_life         TYPE zmatlife,
         matcost          TYPE zmatcost,
         matcatg          TYPE ausp-atwrt,
         matloc           TYPE ausp-atwrt,
         valcls           TYPE bklas,
         wrkng_life       TYPE zshlf,
         matgp            TYPE char2,
         lvorm            TYPE lvorm,
         mat_fnd          TYPE numc4,
         dsflag           TYPE zdsflag,
         taxim            TYPE taxim1,
      END OF ty_ZMM_CDITEM.
      data: ZMM_CDITEM type ty_ZMM_CDITEM.
Types : Begin of ty_srchlp,
          mark,
          srno   type i,
          matnr  like mara-matnr,
          lineno type i,
*---------
*          maktx  like makt-maktx,
          wrkst  like mara-wrkst,
          maktg  like makt-maktg,
          maktx(88),
*--------
          meins  like mara-meins,
          mfrpn  like mara-mfrpn,
*--------
          mfrnr  like mara-MFRNR,  "Manufacturer
          atwrt  like ausp-atwrt,  "capital equipment code
          mdlno  like ausp-atwrt,  "model number
          Filter_flag ,
        End of ty_srchlp,

        Begin of ty_message,
          srno(3)  type c,
          msgtype  type c,
          msgcode  type c,
          msgtext(80) type c,
        End of ty_message,

        Begin of ty_alpha_num1,
          alpha type c,
          number(3) type c,
        End of ty_alpha_num1.

Data : wa_message type ty_message.
Data : ist_message like standard table of wa_message.
Data : it_alpha_num1 type standard table of ty_alpha_num1 with header
line.

data : begin of A,
         mark,
         A like zmm_cditem,
       end of A.
Data: wa_spatbl like A.
Types : char20(20) type c.
************************************************************************
********Type define for displaying only selected option from the status.
************************************************************************
Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type,
       Begin of ty_alphanum,
          alphanum(1) type c,
       end of ty_alphanum.
Data: it_tab1 type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.

******************Structures********************************************
Data: wa_srchlp type ty_srchlp,
      wa_srchlpmk03 type ty_srchlp.
Data: wa_srchlp1 like wa_srchlp.
Data: wa_codmod  like zmm_modifier.
Data: wa_alphanum type ty_alphanum.
Data: wa_char type c.
Data: ist_alphanum type table of ty_alphanum.
DATA: alpha(26) type c value 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
Data: ist_codmod like table of wa_codmod.
Data: ist_spatbl like table of wa_spatbl.
******************Internal Tables***************************************
Data: ist_srchlp like standard table of wa_srchlp,
      ist_srchlp_cp like standard table of wa_srchlp,
      ist_srchlp_cpo like standard table of wa_srchlp,
      it_cap_group1 like standard table of zmm_cap_group with header
line
.

data: OK_CODE      like sy-ucomm.
Data: G_OK_CODE115 like sy-ucomm.
Data: g_spr_par(3) type c.
*****************Data Screen-100*******************************
Data: g_mode(3)  type c,
      okcode_100 like sy-ucomm.
DATA  dynnr like sy-dynnr.

Data : G_sel_col(30),
       g_cursor_line like sy-stepl,
       g_curr_line like sy-stepl.
Data : g_mattytext like DD07V-DDTEXT,
       g_plantdesc like t001w-name1,
       g_locdesc   like dd07v-ddtext.
*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
controls: TABCTRL100 type tableview using screen 0100.
DATA cols LIKE LINE OF TABCTRL100-cols.

*&spwizard: lines of tablecontrol 'TABCTRL100'
data:     g_TABCTRL100_lines  like sy-loopc.

*&spwizard: type for the data of tablecontrol 'TABCTRL110'
types: begin of t_TABCTRL110,
         FLAG,
         SRNO like ZMM_CDITEM-SRNO,
         MATCODE like ZMM_CDITEM-MATCODE,
         rej_flg like ZMM_CDITEM-REJ_FLG,
         COMP_FLG like ZMM_CDITEM-COMP_FLG,
         RSN like ZMM_CDITEM-RSN,
         OTH1 like ZMM_CDITEM-OTH1,
         DESC1 like ZMM_CDITEM-DESC1,
         OTH2 like ZMM_CDITEM-OTH2,
         DESC2 like ZMM_CDITEM-DESC2,
         OTH3 like ZMM_CDITEM-OTH3,
         DESC3 like ZMM_CDITEM-DESC3,
         OTH4 like ZMM_CDITEM-OTH4,
         DESC4 like ZMM_CDITEM-DESC4,
         USER_DESC like ZMM_CDITEM-USER_DESC,
         DESC_FIN like ZMM_CDITEM-DESC_FIN,
         UOM like ZMM_CDITEM-UOM,
*         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         matgp like ZMM_CDITEM-matgp,
         req_lt,     " for requisitioner bush button
*         flag,       "flag for mark column
         mat_fnd like zmm_cditem-mat_fnd,
         dsflag type c,
       end of t_TABCTRL110.

*&spwizard: internal table for tablecontrol 'TABCTRL110'
data:     g_TABCTRL110_itab   type t_TABCTRL110 occurs 0,
          g_TABCTRL110_wa     type t_TABCTRL110. "work area
data:     g_TABCTRL110_copied.           "copy flag

data : wa_zmm_cditem like zmm_cditem.
data : ist_zmm_cditem like table of wa_zmm_cditem with header line.
Data:  g_itab_del110  type T_TABCTRL110 OCCURS 0.

*&spwizard: declaration of tablecontrol 'TABCTRL110' itself
controls: TABCTRL110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TABCTRL110'
data:     g_TABCTRL110_lines  like sy-loopc.

****Long Text for 110*******************************************
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.
DATA : BEGIN OF ist_dtspecs OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA : END OF ist_dtspecs.
Data : g_stxl like stxl.
******************Screen-130******************************************
*&spwizard: type for the data of tablecontrol 'TABLCTRL130'
types: begin of t_TABLCTRL130,
         SRNO like ZMM_CDITEM-SRNO,
         MATCODE like ZMM_CDITEM-MATCODE,
         COMP_FLG like ZMM_CDITEM-COMP_FLG,
         rej_flg like ZMM_CDITEM-REJ_FLG,
         RSN like ZMM_CDITEM-RSN,
         OTH1 like ZMM_CDITEM-OTH1,
         DESC1 like ZMM_CDITEM-DESC1,
         USER_DESC like ZMM_CDITEM-USER_DESC,
         DESC_FIN like ZMM_CDITEM-DESC_FIN,
         UOM like ZMM_CDITEM-UOM,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         matgp like ZMM_CDITEM-matgp,
         MATCOST like ZMM_CDITEM-MATCOST,
         MATCATG like ZMM_CDITEM-matcatg,
         MATLOC like ZMM_CDITEM-matloc,
         WRKNG_LIFE like ZMM_CDITEM-WRKNG_LIFE,
         SPA_GRP like ZMM_CDITEM-SPA_GRP,
         dsflag type c,
         req_lt,     " for requisitioner bush button
         flag,       "flag for mark column
         mat_fnd like zmm_cditem-mat_fnd,
       end of t_TABLCTRL130.

*&spwizard: internal table for tablecontrol 'TABLCTRL130'
data:     g_TABLCTRL130_itab   type t_TABLCTRL130 occurs 0,
          g_TABLCTRL130_wa     type t_TABLCTRL130. "work area
data:     g_TABLCTRL130_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL130' itself
controls: TABLCTRL130 type tableview using screen 0130.

*&spwizard: lines of tablecontrol 'TABLCTRL130'
data:     g_TABLCTRL130_lines  like sy-loopc.
DATA      g_CURFIELD(40).
Data:     g_itab_del130  type T_TABLCTRL130 OCCURS 0.

******************Screen-140******************************************
*&spwizard: type for the data of tablecontrol 'TABLCTRL140'
types: begin of t_TABLCTRL140,
         SRNO like ZMM_CDITEM-SRNO,
         MATCODE like ZMM_CDITEM-MATCODE,
         COMP_FLG like ZMM_CDITEM-COMP_FLG,
         RSN like ZMM_CDITEM-RSN,
         OTH1 like ZMM_CDITEM-OTH1,
         DESC1 like ZMM_CDITEM-DESC1,
         USER_DESC like ZMM_CDITEM-USER_DESC,
         DESC_FIN like ZMM_CDITEM-DESC_FIN,
         UOM like ZMM_CDITEM-UOM,
*         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         dsflag type c,
         req_lt,     " for requisitioner bush button
         flag,       "flag for mark column
       end of t_TABLCTRL140.

*&spwizard: internal table for tablecontrol 'TABLCTRL140'
data:     g_TABLCTRL140_itab   type t_TABLCTRL140 occurs 0,
          g_TABLCTRL140_wa     type t_TABLCTRL140. "work area
data:     g_TABLCTRL140_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL140' itself
controls: TABLCTRL140 type tableview using screen 0140.

*&spwizard: lines of tablecontrol 'TABLCTRL140'
data:     g_TABLCTRL140_lines  like sy-loopc.
Data:     g_itab_del140  type T_TABLCTRL140 OCCURS 0.

******************Screen-120******************************************
*&spwizard: type for the data of tablecontrol 'TABLCTRL120'
types: begin of t_TABLCTRL120,
         SRNO like ZMM_CDITEM-SRNO,
         MATCODE like ZMM_CDITEM-MATCODE,
         rej_flg like ZMM_CDITEM-REJ_FLG,
         COMP_FLG like ZMM_CDITEM-COMP_FLG,
         RSN like ZMM_CDITEM-RSN,
         PARTNO like ZMM_CDITEM-PARTNO,
         OTH1 like ZMM_CDITEM-OTH1,
         DESC1 like ZMM_CDITEM-DESC1,
         USER_DESC like ZMM_CDITEM-USER_DESC,
         DESC_FIN like ZMM_CDITEM-DESC_FIN,
         UOM like ZMM_CDITEM-UOM,
         CAP_CODE like ZMM_CDITEM-CAP_CODE,
         CAP_NAME like ZMM_CDITEM-CAP_NAME,
         OTH_MDL  like ZMM_CDITEM-OTH_MDL,
         MDLNO like ausp-atwrt,
         MANU like ZMM_CDITEM-MANU,
*         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         matgp like ZMM_CDITEM-matgp,
         req_lt,     " for requisitioner bush button
         flag,       "flag for mark column
         mat_fnd like zmm_cditem-mat_fnd,
         dsflag type c,
       end of t_TABLCTRL120.

*&spwizard: internal table for tablecontrol 'TABLCTRL120'
data:     g_TABLCTRL120_itab   type t_TABLCTRL120 occurs 0,
          g_TABLCTRL120_wa     type t_TABLCTRL120. "work area
data:     g_TABLCTRL120_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL120' itself
controls: TABLCTRL120 type tableview using screen 0120.

*&spwizard: lines of tablecontrol 'TABLCTRL120'
data:     g_TABLCTRL120_lines  like sy-loopc.
Data:     g_itab_del120  type T_TABLCTRL120 OCCURS 0.

Data : ist_sval1 like sval  occurs 0 with header line.
Data : ist_sval2 like sval  occurs 0 with header line.
Data : ist_sval3 like sval  occurs 0 with header line.
Data : ist_sval4 like sval  occurs 0 with header line.

**********************Global Data*****************************
DATA  sel_flag.
DATA  desc(22).
data  DESC11(25).
data  DESC22(20).
data  DESC33(20).
data  DESC44(18).
DATA  DESC55 like zmm_cditem-user_desc.
DATA  DESCP5 like zmm_cditem-user_desc.

DATA  FIELD(30).
DATA  FIELD1(30).
DATA  g_matgp(9).
DATA  g_matgpo(2).
Data  g_reqno(10).
Data  g_request_no(10).
DATA  l_MATTYPE.
DATA  g_MATTY(4).
DATA  g_lineno type i.
DATA  descp1(25).
DATA  descp2(20).
DATA  descp3(20).
DATA  descp4(18).
DATA  check_pos.
DATA  g_parno.
Data  g_user_desc(87).  "pop up
DATA  user_desc_len type i.  "pop up
DATA  g_partnoc like zmm_cditem-partno.
DATA  g_partno(80) type c.
DATA  G_FIELD(40).
DATA  check_flag.
DATA  check_flag1.
DATA : G_Desc1(25),G_Desc2(20),G_Desc3(20),G_Desc4(18).
DATA  G_screen115_1st.
DATA  check_flag2.
DATA  g_hd_copied.
DATA  g_desc1_4(87).
DATA  g_choice.
Data: begin of wa_spell_line,
        tdformat like tline-tdformat,
        tdline like tline-tdline,
        srno   like zmm_cditem-srno,
        spell_err,
      End of wa_spell_line.

DATA  ist_spell_line like table of wa_spell_line with header line.
DATA  IST_SPELL_LINE1 like table of wa_spell_line with header line.
Data : ist_sval like sval  occurs 0 with header line.   "GZSPR
Data : ist_mdl like table of zmm_mdl with header line.  "GZSPR

Data  g_user. " value 'X'.
DATA  g_other.
Data  g_spellcheck.
DATA  g_spellerror.

*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*
DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.

DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT,
      GV_TEXT_EDITOR1 TYPE REF TO CL_GUI_TEXTEDIT,
      GV_TEXT_EDITOR2 TYPE REF TO CL_GUI_TEXTEDIT .

DATA : DISPLAY_FLAG LIKE  LV70T-XFLAG VALUE SPACE.

DATA: BEGIN OF TLINETAB OCCURS 10.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB.
DATA: BEGIN OF TLINETAB1 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB1.
DATA: BEGIN OF TLINETAB2 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TLINETAB2.

CONSTANTS: GC_TEXT_LINE_LENGTH TYPE I VALUE 132.

TYPES: TEXT_TABLE_TYPE(GC_TEXT_LINE_LENGTH) TYPE C OCCURS 0.

DATA: LT_TEXT_TABLE TYPE TEXT_TABLE_TYPE,
      LT_TEXT_TABLE1 TYPE TEXT_TABLE_TYPE,
      LT_TEXT_TABLE2 TYPE TEXT_TABLE_TYPE.


DATA: GV_XTHEAD_UPDKZ TYPE I.

DATA: BEGIN OF TINLINETAB OCCURS 10.
        INCLUDE STRUCTURE TLINE.
DATA: END OF TINLINETAB.

DATA: LS_THEAD LIKE THEAD OCCURS 0 WITH HEADER LINE.

DATA : L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.

DATA  G_TDNAME(12).

DATA: BEGIN OF LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES.

Data: g2_lines like tline.

DATA: BEGIN OF LINES_CORS OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES_CORS.

DATA: BEGIN OF g_LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF g_LINES.


DATA  g_mat_fnd type sy-index.
DATA  g_curr_line_110 like sy-stepl.
DATA  g_curr_line_120 like sy-stepl.
DATA  g_curr_line_100 like sy-stepl.
DATA  g_insrflg.

Data  g_cores_sender like tline-tdline.

DATA  seltab like rsparams.
DATA  ist_seltab like table of rsparams.
DATA  wa_rsn like ZMM_CODREQ_RSN.
DATA  matgen_flag.
DATA  TABCTRL110_check_flag.

DATA  app_fl2.
DATA  g_hits_par.
DATA  g_matcode like ZMM_CDITEM-MATCODE.
DATA  g_lineno_old like g_lineno.
DATA  do_not_change_flag.
DATA  g_mat_fnd_flag.
DATA  check_others.
DATA  g_desc_flag.
DATA  g_saveflag.
DATA  g_spell_check.
DATA  g_check_flag.
DATA  ist_modifier_check_list like table of zmm_modifier with header
line.
DATA  check_list_lines like sy-index.
DATA  wa_modifier_check_list like zmm_modifier.
DATA  g_long_text_warning.
DATA  g_hits_par_oth.
DATA  matgrp_change_flag.
DATA  matgrp_orig like ZMM_CDITEM-matgp.
Data: G_OK_CODE110 like sy-ucomm.
*+
DATA  g_modi_exists.
DATA  g_curr_line1 like g_curr_line.
DATA: BEGIN OF CHECKTAB OCCURS 0,
       BEGRIFF(60),
       TERMBEGR(60),
       ART(1),
      END OF CHECKTAB.
DATA  g_user_found.
Data g_oth.
DATA check_code like sy-ucomm.
DATA  g_lock.
DATA  check_lines like sy-index.
DATA: wa_tabctrl110_cols like line of tabctrl110-cols,
      wa_tablctrl120_cols like line of tablctrl120-cols,
      wa_tablctrl130_cols like line of tablctrl130-cols,
      wa_tablctrl140_cols like line of tablctrl140-cols.
DATA: g_filname(40) type c,
      g_filval(40) type c.
DATA  g_filname1(40) type c.
DATA  g_delflag.
DATA  g_sel_colsort(40) type c.
*******************************************************************
DATA  g_line132(132) type c.
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
      End of g_linefrto.
Data: g_linefrto_itab like table of g_linefrto.
DATA  g_matgp_desc(20).
DATA  g_sh_partno.
Data  g_cors.
DATA  g_order(10) type c.
Data : g_sh_capeqt , g_sh_mdlno, g_sh_mfr.
DATA  g_fst_srchlp.
DATA  g_curs_ln type i.
DATA  g_mfrnr type lif16.
DATA  g_techapr_visible.
DATA  g_req_change.
DATA  IST_SVAL_org(30).
DATA  g_cursor_fld130(40).
DATA  g_curr_line_130 type sy-stepl.
DATA  g_atinn like cabn-atinn.
DATA  g_atwrt like ausp-atwrt.
DATA  g_confdel.
DATA  g_curfield110(40).
DATA  g_curfield120(40).
DATA  g_curfield130(40).
DATA  g_matgp_selected.
Data  g_change_auth.
DATA  it_cap_group.
DATA  it_alpha_num.
DATA  a_choice.
DATA  g_srno type ZMM_CDITEM-SRNO.
*Data  g_curs_ln1 type sy-tabix.
