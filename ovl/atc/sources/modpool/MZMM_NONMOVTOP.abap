*--- MAIN PROGRAM: MZMM_NONMOVTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMM_NONMOVTOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMM_NONMOV.
type-pools: icon.

Tables:ZMM_NMBLKCDHD_ST,ZMM_NMBLKCDHD,ZMM_NMBLKCDDT,
       STXH,AUSP,CABN,KLAH,KSSK,srrelroles,PA9205.
*************Types******************************************************
Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

Types: Begin of t_tx100,
         matcode like mara-matnr,
         res_nm like zmm_nmblkcddt-res_nm,
       End of t_tx100.
***&spwizard: data declaration for tablecontrol 'TCT100'
*&spwizard: definition of ddic-table
*tables:   ZMM_NMBLKCDDT.

*&spwizard: type for the data of tablecontrol 'TCT100'
types: begin of t_TCT100,

         SRNO like ZMM_NMBLKCDDT-SRNO,
         MATCODE like ZMM_NMBLKCDDT-MATCODE,
         mstae   like ZMM_NMBLKCDDT-mstae,
         ERRCD like ZMM_NMBLKCDDT-ERRCD,
         MATDESC like ZMM_NMBLKCDDT-MATDESC,
         PLANT_STK like ZMM_NMBLKCDDT-PLANT_STK,
         ONGC_STK like ZMM_NMBLKCDDT-ONGC_STK,
         UOM like ZMM_NMBLKCDDT-UOM,
         RES_NM like ZMM_NMBLKCDDT-RES_NM,
         CMGVBR like ZMM_NMBLKCDDT-CMGVBR,
         ongc_cons like ZMM_NMBLKCDDT-ongc_cons,
         UNBLKBY like ZMM_NMBLKCDDT-UNBLKBY,
         UNBLKDT like ZMM_NMBLKCDDT-UNBLKDT,
         flag,       "flag for mark column
         ICON like ZMM_NMBLKCDDT-ICON,
         STATUS like ZMM_NMBLKCDDT-STATUS,
         DECISION LIKE ZMM_NMBLKCDDT-DECISION,
         CY_CONS_ONGC	LIKE ZMM_NMBLKCDDT-CY_CONS_ONGC,
         CY_CONS_DATE_ONGC  LIKE ZMM_NMBLKCDDT-CY_CONS_DATE_ONGC,       "19.05.2014 Last cons. date in CY across ONGC
         CY_CONS_PLANT  LIKE ZMM_NMBLKCDDT-CY_CONS_PLANT,
         CY_CONS_DATE_PLANT  LIKE ZMM_NMBLKCDDT-CY_CONS_DATE_PLANT,      "19.05.2014 Last cons. date in CY in plant
         LAST_CONS_ONGC	LIKE ZMM_NMBLKCDDT-LAST_CONS_ONGC,
         LAST_CONS_DATE_ONGC  LIKE ZMM_NMBLKCDDT-LAST_CONS_DATE_ONGC,
         LAST_CONS_PLANT  LIKE ZMM_NMBLKCDDT-LAST_CONS_PLANT,
         LAST_CONS_DATE_PLANT	LIKE ZMM_NMBLKCDDT-LAST_CONS_DATE_PLANT,

       end of t_TCT100.

*&spwizard: internal table for tablecontrol 'TCT100'
data:     g_TCT100_itab   type t_TCT100 occurs 0,
          g_TCT100_wa     type t_TCT100. "work area
data:     g_TCT100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TCT100' itself
controls: TCT100 type tableview using screen 0100.

*&spwizard: lines of tablecontrol 'TCT100'
data:     g_TCT100_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
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

********Data: g2_lines like tline.

DATA: BEGIN OF LINES_CORS OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES_CORS.

DATA: BEGIN OF g_LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF g_LINES.

**************Structure and Working Area *********************
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
End of g_linefrto.
Data : wa_nmblkcddt like zmm_nmblkcddt.
Data : g_cores_sender like tline-tdline.
DATA: ist_textid like thead,
      wa_textid  like thead,
      ist_textid_items like thead occurs 0.
Data: g_ex100_wa type t_tx100.
Data  g_att_files_wa like SWOTOBJID.
DATA  g_att_files like table of SWOTOBJID.

**************Internal Tables**********************************
Data: it_tab1 type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.
Data: g_linefrto_itab like table of g_linefrto.
Data: itab_nmblkcddt like table of zmm_nmblkcddt with header line.
Data: g_itab_del100  type t_tct100 OCCURS 0.
Data: g_tx100_itab type t_tx100 occurs 0,
      g_ex100_itab type t_tx100 occurs 0.
data : exclude_tab like soxet occurs 0 with header line.
**************Global data**************************************
Data : g_mode(3)  type c,
      ok_code100 like sy-ucomm.
Data : g_cors type c,
       g_choice type c,
       g_rel type c,
       g_app type c,
       g_line132(132) type c,
       g_hd_copied type c,
       g_relflag type c,
       G_REQNO(10) type c,
       g_request_no(10) type c.
data  g_txlines type i.
data:  g_recstat, g_errstat,G_ERRCD_M.
data  g_tctlines type i.
data  g_result.
data  g_mesg.
data  g_attach.

 CONSTANTS: g_c_asc TYPE char10 value 'ASC'.

 DATA   :It_9205 TYPE  STANDARD TABLE OF  PA9205,
        Wa_9205 TYPE PA9205 .

 DATA : NAME1 TYPE EMNAM,
        NAME2 TYPE EMNAM,
        NAME3 TYPE EMNAM.



DATA G_USER_BUKRS type bukrs.
data: g_user_pernr type pernr_d.
data: ist_agr_users_plant type TABLE OF agr_users,  " list of roles of type MM_INDENT_MUM_PLANT_*
      wa_agr_users_plant type agr_users.
types: begin of ty_plant,
       plant TYPE werks_d,
       end of ty_plant.
data: ist_plant type TABLE OF  ty_plant,  " list of PLANTs
      wa_plant type  ty_plant.

data: ist_agr_users_pgrp type TABLE OF agr_users,  " list of roles of type MM_PUR_PO_MUM_PGRP_*
      wa_agr_users_pgrp type agr_users.

types: begin of ty_pgrp,
       EKGRP TYPE EKGRP,
       end of ty_pgrp.
data: ist_pgrp type TABLE OF  ty_pgrp,  " list of PGRP
      wa_pgrp type  ty_pgrp.

DATA : IST_FIELD LIKE  DFIES OCCURS 1 WITH HEADER LINE.
DATA : IST_DYNPFLD_MAPPING LIKE STANDARD TABLE OF DSELC
                                       WITH  HEADER LINE.
DATA : IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                       WITH  HEADER LINE.
DATA FLAG_HDR_COPIED(1).
DATA G_REL_FLAG(1).
DATA flag_dont_clear(1).

TYPES: BEGIN OF ty_user,
         uname type XUBNAME,
         ename type EMNAM,
       END OF ty_user.

Data: L_ROLE1 type agr_name,
      L_ROLE2 type agr_name,
      L_ROLE3 type agr_name.
*begin RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853
Data: L_ROLE1A type agr_name.
*end RD1K995092 CAB_ALOK correction of workflow in NM - adll 1 - CR 30011853

DATA : g_id TYPE vrm_id,
       g_list TYPE vrm_values,
       g_value  LIKE LINE OF g_list.

DATA : g_list_inc TYPE vrm_values,
       g_value_inc  LIKE LINE OF g_list.


Data: WA_APPROVER type ty_user. " for structure def in forms
DATA FLAG_CLEAR_OLD_APPR_CHAIN(1).
DATA FLAG_CLEAR_OLD_Status(1).
data: ANS_CONFIRM_ACTION(1).
