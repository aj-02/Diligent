*--- MAIN PROGRAM: MZMMCODREQTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCODREQTOP .                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Removed the Screen Consistency Error By Declaring the G_OK_CODE103.
************************************************************************

PROGRAM  SAPMZMMCODREQ.
*******************Tables**********************************************
Tables: Mara, Makt, Zmm_cdhd,zmm_cditem,Zmm_modifier,ZMM_CDHD_ST,
        ZMM_CODREQ_RSN,t001w,dd07t,zmm_mdl,zmm_cdcodifier,zmm_cap_group.

*******************Types************************************************
Types : Begin of ty_srchlp,
          mark,
          srno   type i,
          matnr  like mara-matnr,
          lineno type i,
          wrkst  like mara-wrkst,
          maktg  like makt-maktg,
          maktx(88),
          meins  like mara-meins,
          mfrpn  like mara-mfrpn,
          mfrnr  like mara-MFRNR,  "Manufacturer
          atwrt  like ausp-atwrt,  "capital equipment code
          mdlno  like ausp-atwrt,  "model number
* start of change by yogesh RD1K962288
          zzcap_code TYPE mara-zzcap_code,
          ZZMODELNO TYPE mara-ZZMODELNO,
          ZZOEM_NAME type mara-ZZOEM_NAME,
          ZZCAP_NAME TYPE mara-ZZCAP_NAME,
* end of change by yogesh RD1K962288
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

*****************Types defined to display selected option from status***
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
line.

DATA:wa_cap_group1 like line of it_cap_group1.
data: OK_CODE      like sy-ucomm.
Data: G_OK_CODE115 like sy-ucomm.
Data: g_spr_par(3) type c.

*****************Data Screen 100*******************************
Data: g_mode(3)  type c,
      okcode_100 like sy-ucomm.
DATA  dynnr like sy-dynnr.

Data : G_sel_col(30),
       g_cursor_line like sy-stepl,
       g_curr_line like sy-stepl,
       "added by lipsy <RD1K979105> for getting correct vendor details
       g_curr_line_vendor like sy-stepl.
       "end of addition by lipsy
Data : g_mattytext like DD07V-DDTEXT,
       g_plantdesc like t001w-name1,
       g_locdesc   like dd07v-ddtext.
*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
controls: TABCTRL100 type tableview using screen 0100.
DATA: cols LIKE LINE OF TABCTRL100-cols.


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
*{   INSERT         OCPK900087                                        1
*********************Add HSN code*************************************
STEUC LIKE ZMM_CDITEM-STEUC,
  TAXIM LIKE ZMM_CDITEM-TAXIM,
**********************************************************************
*}   INSERT
         USER_DESC like ZMM_CDITEM-USER_DESC,
         DESC_FIN like ZMM_CDITEM-DESC_FIN,
         DESC_CDCELL like ZMM_CDITEM-DESC_CDCELL,
         UOM like ZMM_CDITEM-UOM,
         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         CODCRBY like ZMM_CDITEM-CODCRBY,
         CODCRDT like ZMM_CDITEM-CODCRDT,
         matgp like ZMM_CDITEM-matgp,
         req_lt,     " for requisitioner bush button
         mat_fnd like zmm_cditem-mat_fnd,
         dsflag type c,
       end of t_TABCTRL110.

types: begin of t_TABCTRL110_a,
         SRNO(4) ,
         MATCODE(12),
         rej_flg(6),
         COMP_FLG(6),
         mat_fnd(6),
         OTH1(4),
         DESC1(20),
         OTH2(4),
         DESC2(20),
         OTH3(4),
         DESC3(20),
         OTH4(4),
         DESC4(20),
*{   INSERT         OCPK900087                                        2
STEUC(16),
  TAXIM(2),
*}   INSERT
         USER_DESC(20),
         DESC_FIN(88),
         UOM(3),
         HAZ_FLG(10),
         GRWGT(10),
         WTUNIT(8),
         GRVOL(10),
         VOLUNIT(8),
         ENVMAT(8),
         SHLF_LIFE1(10),
         DMS(6),
         CODBY(12),
         CODDT(12),
         CODCRBY(12),
         CODCRDT(12),
         matgp(6),
         dsflag(6),
       end of t_TABCTRL110_a,

       begin of t_TABCTRL120_a,
         SRNO(4) ,
         MATCODE(12),
         rej_flg(6),
         COMP_FLG(6),
         mat_fnd(6),
         PARTNO(40),
         DESC_FIN(88),
*{   INSERT         OCPK900087                                        9
 STEUC(16),
         TAXIM(2),
*}   INSERT
         UOM(3),
         CAP_CODE(12),
         CAP_NAME(88),
         SUBASS(30),
         OTH_MDL(8),
         MDLNO(30),
         MANU(12),
         HAZ_FLG(10),
         GRWGT(10),
         WTUNIT(8),
         GRVOL(10),
         VOLUNIT(8),
         ENVMAT(8),
         SHLF_LIFE1(10),
         DMS(6),
         CODBY(12),
         CODDT(12),
         CODCRBY(12),
         CODCRDT(6),
         matgp(6),
*{   INSERT         OCPK900087                                        6

*}   INSERT
         dsflag(6),

       end of t_TABCTRL120_a,

       begin of t_TABCTRL130_a,
         SRNO(4) ,
         MATCODE(12),
         rej_flg(6),
         COMP_FLG(6),
         mat_fnd(6),
         DESC_FIN(88),
         DESC_CDCELL(87),
         UOM(3),
         MATCOST(15),
         MATCATG(30),
         MATLOC(30),
         WRKNG_LIFE(10),
         SPA_GRP(10),
         HAZ_FLG(10),
         GRWGT(10),
         WTUNIT(8),
         GRVOL(10),
         VOLUNIT(8),
         ENVMAT(8),
         SHLF_LIFE1(10),
         DMS(6),
         CODBY(12),
         CODDT(12),
         CODCRBY(12),
         CODCRDT(6),
*{   INSERT         OCPK900087                                        7
STEUC(16),
         TAXIM(2),
*}   INSERT
         dsflag(6),

       end of t_TABCTRL130_a.



*&spwizard: internal table for tablecontrol 'TABCTRL110'
data:     g_TABCTRL110_itab   type t_TABCTRL110 occurs 0,
          g_TABCTRL110_wa     type t_TABCTRL110. "work area
data:     g_TABCTRL110_copied.           "copy flag

data : wa_zmm_cditem like zmm_cditem.
data : ist_zmm_cditem like table of wa_zmm_cditem with header line.
Data:  g_itab_del110  type T_TABCTRL110 OCCURS 0.

*&spwizard: declaration of tablecontrol 'TABCTRL110' itself
controls: TABCTRL110 type tableview using screen 0110.
Data : cols110 like line of tabctrl110-cols.
*&spwizard: lines of tablecontrol 'TABCTRL110'
data:     g_TABCTRL110_lines  like sy-loopc.

****Long Text for 110*************************************************
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.
DATA : BEGIN OF ist_dtspecs OCCURS 0.
        INCLUDE STRUCTURE tline.
DATA : END OF ist_dtspecs.
Data : g_stxl like stxl.

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
         DESC_CDCELL like ZMM_CDITEM-DESC_CDCELL,
         UOM like ZMM_CDITEM-UOM,
         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         CODCRBY like ZMM_CDITEM-CODCRBY,
         CODCRDT like ZMM_CDITEM-CODCRDT,
         matgp like ZMM_CDITEM-matgp,
         MATCOST like ZMM_CDITEM-MATCOST,
         MATCATG like ZMM_CDITEM-MATCATG,
         MATLOC like ZMM_CDITEM-MATLOC,
         WRKNG_LIFE like ZMM_CDITEM-WRKNG_LIFE,
         SPA_GRP like ZMM_CDITEM-SPA_GRP,
         dsflag type c,
         req_lt,     " for requisitioner bush button
         flag,       "flag for mark column
*{   INSERT         OCPK900087                                        5
STEUC LIKE ZMM_CDITEM-STEUC,
  TAXIM LIKE ZMM_CDITEM-TAXIM,
*}   INSERT
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
         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         CODCRBY like ZMM_CDITEM-CODCRBY,
         CODCRDT like ZMM_CDITEM-CODCRDT,
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
*{   INSERT         OCPK900087                                        8
      steuc TYPE zmm_cditem-STEUC,
      taxim TYPe zmm_cditem-TAXIM,
*}   INSERT
         UOM like ZMM_CDITEM-UOM,
         CAP_CODE like ZMM_CDITEM-CAP_CODE,
         SUBASS like ZMM_CDITEM-SUBASS,
         CAP_NAME like ZMM_CDITEM-CAP_NAME,
         OTH_MDL  like ZMM_CDITEM-OTH_MDL,
         MDLNO like ausp-atwrt,
         MANU like ZMM_CDITEM-MANU,
         HAZ like ZMM_CDITEM-HAZ,
         HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
         ST_COND like ZMM_CDITEM-ST_COND,
         PACK_COND like ZMM_CDITEM-PACK_COND,
         GRWGT like ZMM_CDITEM-GRWGT,
         WTUNIT like ZMM_CDITEM-WTUNIT,
         GRVOL like ZMM_CDITEM-GRVOL,
         VOLUNIT like ZMM_CDITEM-VOLUNIT,
         ENVMAT like ZMM_CDITEM-ENVMAT,
         TEMPCOND like ZMM_CDITEM-TEMPCOND,
         SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
         INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
         CRC_MAT like ZMM_CDITEM-CRC_MAT,
         DMS like ZMM_CDITEM-DMS,
         CODBY like ZMM_CDITEM-CODBY,
         CODDT like ZMM_CDITEM-CODDT,
         CODCRBY like ZMM_CDITEM-CODCRBY,
         CODCRDT like ZMM_CDITEM-CODCRDT,
         matgp like ZMM_CDITEM-matgp,
         req_lt,     " for requisitioner bush button
         flag,       "flag for mark column
         mat_fnd like zmm_cditem-mat_fnd,
         dsflag type c,
  "added by lipsy on 04.09.2012 <RD1K979105> for adding another column of vendor name
*{   INSERT         OCPK900087                                        4

*}   INSERT
         name1 TYPE NAME1_GP,
  "end of addition by lipsy on 04.09.2012
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
*{   INSERT         OCPK900087                                        3
DATA STEUC(16).
*}   INSERT

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
Data  g_user_descx(87).
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
DATA  g_capcode like ausp-atwrt.
DATA  g_techapr_visible.
DATA  g_req_change.
DATA  IST_SVAL_org(30).
DATA  g_cursor_fld130(40).
DATA  g_curr_line_130 type sy-stepl.
DATA  g_atinn like cabn-atinn.
DATA  g_atwrt like ausp-atwrt.
DATA G_ZZMAGR TYPE MARA-ZZMAGR.
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
DATA  g_new_cap_range.
DATA  g_spell_ans.
DATA  g_user_logged like sy-uname.
DATA  g_matcode_fl.
DATA  g_prev_desc_fin like zmm_cditem-desc_fin.
DATA  g_desc_fin_chng.
DATA  g_matty1 like g_matty.
DATA  g_first_time_flag.
DATA  do_not_change_flag1.
DATA: g_dstext(80) type c,
      g_dschoice type c.
DATA  g_grpcount type i.
DATA  g_coduser  type c.
DATA  g_len_ex87.  " +
DATA  g_desc_fin like zmm_cditem-desc_fin.
DATA  g_cditem like zmm_cditem.
DATA  g_Current_line type sy-stepl.
DATA  G_Duplicate_rec.
Data  g_cditem_itab like table of zmm_cditem.
Data: p1_file LIKE rlgrap-filename .
DATA  g_file_flag.
DATA  G_OK_CODE103 LIKE sy-ucomm.

"added by lipsy on 3.09.2012 <RD1K979105> for attaching files,getting vendor details

*  ***Working Area for attaching and listing files
 Data  g_att_files_wa like SWOTOBJID.
***Internal Table.
  DATA : g_att_files like table of SWOTOBJID.

data : exclude_tab like soxet occurs 0 with header line.

"""""""""""""FOR ATTACHING PROCESS GUIDE
 DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
  DATA : wa_att_files LIKE swotobjid.


TYPES:BEGIN OF ty_lfa1,
      lifnr TYPE lifnr,
      name1  TYPE NAME1_GP,
  END OF ty_lfa1.

data :itab_lfa1 TYPE TABLE OF ty_lfa1,
      wa_lfa1 LIKE LINE OF itab_lfa1,
      v_vendor TYPE NAME1_GP,
      g_fname(30) TYPE c ,
      s_lifnr  TYPE lfa1-lifnr,
      count type i.


""""""""for sending sms to requistioner


DATA   :It_9205 TYPE  STANDARD TABLE OF  PA9205,
        Wa_9205 TYPE PA9205 .

DATA   : mob_no(12) TYPE C.


DATA: http_client TYPE REF TO if_http_client .
DATA: wf_string TYPE string ,
      result    TYPE string .
DATA: result_tab TYPE TABLE OF string.

DATA:R_USER_SMS  TYPE SY-UNAME.
DATA : Sms_text(170)  TYPE C.

DATA:   L_TEXT1 TYPE AD_SMTPADR,
        L_TEXT2 TYPE AD_SMTPADR,
        L_TEXT3 TYPE AD_SMTPADR,
        L_TEXT4 TYPE AD_SMTPADR,
        L_TEXT5 TYPE AD_SMTPADR.







"end of addition by lipsy on 3.09.2012
