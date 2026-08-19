*--- MAIN PROGRAM: MZMMCODUNBLOCKTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMCODUNBLOCKTOP                                           *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMCODUNBLOCK .
*************************Tables*************************************
Tables : zmm_matblock_hd, zmm_matblock_dt,ZMM_MATBLOCKHD_ST,
         mara, t141, cabn,lfa1,zmm_mdl,ausp,stxh,zmm_cdcodifier,
         zmm_blkcodifier,ZMMCDCAP_LOC_V,ZMMCDCAP_USRGP_V.

*************************Types*****************************************

types: begin of ty_tc110,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-labst,
         c_stock    like mard-labst,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         res_nm     like zmm_matblock_dt-res_nm,
         mark,
       end of ty_tc110.
types: begin of ty_tc120,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-umlme,
         c_stock    like mard-umlme,
         opartno    like zmm_matblock_dt-npartno,
         npartno    like zmm_matblock_dt-npartno,
         ooem       like zmm_matblock_dt-noem,
         noem       like zmm_matblock_dt-noem,
         omdlno     like zmm_matblock_dt-nmdlno,
         nmdlno     like zmm_matblock_dt-nmdlno,
         ocapno     like zmm_matblock_dt-ncapno,
         ncapno     like zmm_matblock_dt-ncapno,
         res_nm     like zmm_matblock_dt-res_nm,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         mark,
       end of ty_tc120.
types: begin of ty_tc130,
         srno       like zmm_matblock_dt-srno,
         matcode    like zmm_matblock_dt-matcode,
         errcd      like zmm_matblock_dt-errcd,
         omatdesc   like zmm_matblock_dt-matdesc,
         matdesc    like zmm_matblock_dt-matdesc,
         ouom       like mara-meins,
         p_stock    like mard-umlme,
         c_stock    like mard-umlme,
         omatcatg    like zmm_matblock_dt-omatcatg,
         matcatg    like zmm_matblock_dt-matcatg,
         omatloc     like zmm_matblock_dt-omatloc,
         matloc     like zmm_matblock_dt-matloc,
         omatgp      like zmm_matblock_dt-omatgp,
         matgp      like zmm_matblock_dt-matgp,
         omatcost    like zmm_matblock_dt-omatcost,
         matcost    like zmm_matblock_dt-matcost,
         omat_life   like zmm_matblock_dt-omat_life,
         mat_life   like zmm_matblock_dt-mat_life,
         res_nm     like zmm_matblock_dt-res_nm,
         unblkby    like zmm_matblock_dt-unblkby,
         unblkdt    like zmm_matblock_dt-unblkdt,
         mstae      like zmm_matblock_dt-mstae,
         mark,
       end of ty_tc130.


Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

***********Work Area***************************************************
Data : g_tc110_wa type ty_tc110,
       g_tc120_wa type ty_tc120,
       g_tc130_wa type ty_tc130.

***********Internal Tables*********************************************
Data: g_tc110_itab like table of g_tc110_wa with header line,
      g_tc120_itab like table of g_tc120_wa with header line,
      g_tc130_itab like table of g_tc130_wa with header line.
Data: g_itab_del110  type ty_tc110 OCCURS 0,
      g_itab_del120  type ty_tc120 OCCURS 0,
      g_itab_del130  type ty_tc130 OCCURS 0.

Data: it_tab1 type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.


*&spwizard: declaration of tablecontrol 'TCT110' itself
controls: TCT110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TCT110'
data:     g_TCT110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
************************************************************************
Data: g_mode(3)  type c,
      okcode_100 like sy-ucomm.
DATA  dynnr like sy-dynnr.
DATA  g_CURFIELD(40).

*&spwizard: declaration of tablecontrol 'TCT120' itself
controls: TCT120 type tableview using screen 0120.

*&spwizard: lines of tablecontrol 'TCT120'
data:     g_TCT120_lines  like sy-loopc.

*&spwizard: declaration of tablecontrol 'TCT130' itself
controls: TCT130 type tableview using screen 0130.

*&spwizard: lines of tablecontrol 'TCT130'
data:     g_TCT130_lines  like sy-loopc.
*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*
DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER, "#EC NEEDED
      GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
      GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.

DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT, "#EC NEEDED
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
DATA:    col110 LIKE LINE OF TCT110-cols,
         col120 LIKE LINE OF TCT120-cols,
         col130 LIKE LINE OF TCT130-cols.

**********Data Declaration -General..***********************************
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.

Data : g_item like zmm_matblock_dt,
       wa_matblock_dt like zmm_matblock_dt,
       itab_matblock_dt like table of zmm_matblock_dt with header line.
Data : g_hd_copied type c,
       g_tct110_copied type c,
       g_tct120_copied type c,
       g_tct130_copied type c.
data:  g_relflag type c,
       G_REQNO(10) type c,
       g_request_no(10) type c,
       g_cors,
       g_line132(132) type c.
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
      End of g_linefrto.
Data: g_linefrto_itab like table of g_linefrto.
Data : g_capcode_no   like ausp-atinn.
Data : g_modelcode_no like ausp-atinn.
Data : g_errflag type c,
       g_cursor_line like sy-stepl,
       g_curr_line like sy-stepl.
Data : g_cfld(40) type c.
Data : g_cores_sender like tline-tdline,
       g_iputdata like tline-tdline,
       g_oputdata like tline-tdline,
       g_iputstring like tline-tdline.
data:  g_choice,g_ans,
       g_selline like sy-stepl.
Data : g_desclen type i,
       g_wrkst(48) type c,
       g_wrkst39(40) type c.
data:  g_rel type c,
       g_clrndesc type c,
       g_lock type c,
       g_section type c.
data  g_normt(3) type c.
data  g_fname(30) type c.
Data  g_atinn130 LIKE cabn-atinn.
