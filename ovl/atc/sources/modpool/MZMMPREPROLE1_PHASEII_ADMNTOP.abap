*--- MAIN PROGRAM: MZMMPREPROLE1_PHASEII_ADMNTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 67.
************************************************************************

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZIC_PREP_ROLEREQ, ZIC_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp, zpm_prep_roledes, v_t357, zice_prep_module,
ZMM_PREP_STATUS,zps_prep_roledes,zps_prep_service,zps_prep_project,
zps_prep_asst_ex,zps_prep_loc,t001,zpp_prep_roledes,ZPP_PREP_DROLEEX,
zsd_prep_roledes,zqm_prep_roledes, ZPP_PREP_GENERIC,zhelp_pproles1,
zqm_prep_loc, zqm_prep_asset, tvta, ZSD_PREP_LDGGRP,zmm_prep_crcdesg,
zps_prep_loca,usr21,ADRP.

TYPE-POOLS CXTAB .


Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

TYPES : BEGIN OF ty_t024,
         ekgrp like t024-ekgrp,
         eknam like t024-eknam,
        END of ty_t024.

TYPES: BEGIN OF ty_m_fistb.
TYPES: g_mark.
        include structure m_fistb.
TYPES: END OF ty_m_fistb.

TYPES : BEGIN OF ty_data,
          pernr     LIKE pa0027-pernr,
          begda     LIKE pa0001-begda,
          endda     LIKE pa0001-endda,
          name      LIKE pa0001-ename,
          bukrs     LIKE pa0001-bukrs,
          werks     LIKE pa0001-werks,
          persk     LIKE pa0001-persk,
          kbu01     LIKE pa0027-kbu01,
          kgb01     LIKE pa0027-kgb01,
          kst01     LIKE pa0027-kst01,
          designo   LIKE pa9930-designo,
          r_p_cd    LIKE pa9930-r_p_cd,
          version   LIKE pa9930-version,
          designation LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          DISC_CD   LIKE zdesignation_rev-DISC_CD,
          sbmod     type pa0001-sbmod,
        END OF ty_data.

Data: it_tab type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type,
      wa_pa0027 type pa0027.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
*Begin of <RD1K963151>.
DATA : ist_data1 TYPE STANDARD  TABLE OF ty_data with header line.
DATA : ist_data2 TYPE STANDARD  TABLE OF ty_data with header line.
*Begin of <RD1K963151>.
DATA : it_m_fistb TYPE STANDARD TABLE OF ty_m_fistb.

****************************************************************
types:
begin of ty_view_apx,
        selc(1) type c.
        include structure bcos_appx.
types: end of ty_view_apx.

constants: cs_x(1) value 'X'.

data : g_apx_exist(1).

data: begin of gs_win_head.
        include structure soxwd.
data: end of gs_win_head.

DATA : gt_cont like soli occurs 0 with header line,
       gv_filetype like rlgrap-filetype,
       gv_filename type string,
       g_apx_cnt like bcos_appx-appxno,
       g_apx_ptr like bcos_appx-firstl,
       g_apx_bin_ptr like bcos_appx-firstl,
       gt_ac_cont like soli occurs 0 with header line,
       gt_ac_contx like solix occurs 0 with header line,
       gt_view_apx type ty_view_apx occurs 0 with header line,
       gt_ac_apx like bcos_appx occurs 5 with header line,
       gt_contx like solix occurs 0 with header line.
****************************************************************
data g_object_id         like soodk.
data g_attachments  like sood5 occurs 0 with header line.
data g_attachments_read type c.
data on  type c value 'X'.
****************************************************************

DATA : TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

DATA  dynnr like sy-dynnr.

DATA  g_mode.
DATA  okcode like sy-ucomm.
DATA  g_lock.
DATA  g_hd_copied.
DATA  g_cors.
DATA  g_char(120).
DATA  g_line1(120).
DATA : cpf_lfb1(08) type c.

*&spwizard: type for the data of tablecontrol 'TABCTRL100'
types: begin of t_TABCTRL100,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         role_desc like zmm_prep_roledes-brief_desc,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-receipt_loc,
         SLOC like ZIC_PREP_ROLEREI-sloc,
         flag,       "flag for mark column
         srno like ZIC_PREP_ROLEREI-srno,
         approver like ZIC_PREP_ROLEREI-approver,
         rej_fl like ZIC_PREP_ROLEREI-rej_fl,
         rej_id like ZIC_PREP_ROLEREI-rej_id,
         rej_date like ZIC_PREP_ROLEREI-rej_date,
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
         status like ZIC_PREP_ROLEREI-status,
       end of t_TABCTRL100.

data: ist_itemtab type standard table of ZIC_PREP_ROLEREI.
data: wa_itemtab like ZIC_PREP_ROLEREI.

***********************************************************************
data : ist_colsscreen type table of cxtab_column-screen.
data : ist_column type standard table of cxtab_column with non-unique
default key.
***********************************************************************

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

DATA: L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.

DATA  G_TDNAME(12).

DATA: BEGIN OF LINES20 OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES20.

Data: g2_lines like tline.

DATA: BEGIN OF LINES_CORS OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF LINES_CORS.

DATA: BEGIN OF g_LINES OCCURS 20.
        INCLUDE STRUCTURE TLINE.
DATA: END OF g_LINES.

***************************************************************

*&spwizard: internal table for tablecontrol 'TABCTRL100'
data:     g_TABCTRL100_itab   type t_TABCTRL100 occurs 0,
          g_TABCTRL100_wa     type t_TABCTRL100. "work area
data:     g_TABCTRL100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
controls: TABCTRL100 type tableview using screen 0100.
DATA cols LIKE LINE OF TABCTRL100-cols.

*&spwizard: lines of tablecontrol 'TABCTRL100'
Data:Begin of g_linefrto ,
       line_fr type i,
       line_to type i,
      End of g_linefrto.
Data: g_linefrto_itab like table of g_linefrto.
data : g_TABCTRL100_lines  like sy-loopc.
DATA : it_cond like table of g_char.
DATA : g_select(2).
DATA : g_select_flag.
DATA : it_t024 TYPE STANDARD TABLE OF t024.
DATA : wa_t024 like line of it_t024.
DATA : it_t024_1 TYPE STANDARD TABLE OF t024.
DATA : role_desc(40).
DATA : okcode_100 like sy-ucomm.
DATA : g_line(120).
DATA : help_list_flag.
DATA : wa_m_fistb type ty_m_fistb.
DATA : lines like sy-index.
DATA : flag_s_fundc value 'X'.
DATA : lines_index like sy-index.
DATA : ZDOCNUMB(12).
DATA : insert_items.
DATA : old_ok_code like sy-ucomm.
DATA : g_srno like sy-index.
DATA : old_doc_no like ZIC_PREP_ROLEREQ-docno.
DATA : g_line132(132) type c.
Data : g_cores_sender like tline-tdline.
Data : g_user(2).
DATA : g_user_found.
DATA : err_flg.
DATA : tab1_lines like sy-index.
DATA : tab2_lines like sy-index.
DATA : flag1, flag2.
DATA  read_flag.
DATA  g_ins_flag.
DATA  g_cursor_line like sy-stepl.
DATA  g_curr_line like sy-stepl.
DATA  g_current_line like sy-stepl.
DATA  g_curr_line_100 like sy-stepl.
DATA  g_curr_line_110 like sy-stepl.
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  g_reset_fl.
DATA  g_docno like ZIC_PREP_ROLEREQ-docno.
DATA  g_app_rel.
DATA  g_release like ZIC_PREP_ROLEREQ-req_cr_fl.
DATA  g_approve like ZIC_PREP_ROLEREQ-req_app_fl.
DATA  g_approve1 like ZIC_PREP_ROLEREQ-req_app1_fl.
DATA  g_i like sy-index.
DATA  g_tc_lines like sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl like sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  g_role_name_prev like ZIC_PREP_ROLEREI-ROLE_NAME.
DATA  g_role_name_flag.
DATA  g_persa like pa0001-werks.
DATA  g_approve0 like ZIC_PREP_ROLEREQ-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  CRC_CHECK_FL.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  old_userid like ZIC_PREP_ROLEREQ-userid.
DATA  g_val_err.
DATA  g_lines_2 like sy-index.
DATA  old_ok_code_crc like old_ok_code.
DATA  g_crc_fl.
DATA  G_CCODE like ZIC_PREP_ROLEREQ-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  G_CCODE_CROSSCO like ZIC_PREP_ROLEREQ-CCODE.
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL110,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         shop_no like ZIC_PREP_ROLEREI-shop_no,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex like zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
       end of t_TABLCTRL110.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_itab   type t_TABLCTRL110 occurs 0,
          g_TABLCTRL110_wa     type t_TABLCTRL110. "work area
data:     g_TABLCTRL110_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
data:     moduleid(3).
data:     new_moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
types: begin of t_TABLCTRL111,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         SHOP_NO like ZIC_PREP_ROLEREI-SHOP_NO,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_itab   type t_TABLCTRL111 occurs 0,
          g_TABLCTRL111_wa     type t_TABLCTRL111. "work area
data:     g_TABLCTRL111_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
controls: TABLCTRL111 type tableview using screen 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_lines  like sy-loopc.
DATA      g_curr_line_111 like sy-stepl.
DATA  check_role_flag.
DATA   : ist_item like table of zic_prep_rolerei.
DATA   : wa_item like line of ist_item.
DATA  g_l4.
DATA  modulemm_fl.
DATA  moduleid_save like zic_prep_rolerei-moduleid.
DATA  g_mult_module_fl.
DATA : STATUS_DESC like ZMM_PREP_STATUS-STATUS_DESC.
data : it_module1 like table of zic_modules.
DATA : wa_module1 like line of it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  g_choice_app.

*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
types: begin of t_TABLCTRL112,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         SERVICE like ZIC_PREP_ROLEREI-SERVICE,
         PROJECT like ZIC_PREP_ROLEREI-PROJECT,
         LOCATION like ZIC_PREP_ROLEREI-LOCATION,
*         REGION like ZIC_PREP_ROLEREI-REGION,
         ASSET like ZIC_PREP_ROLEREI-ASSET,
         BASIN like ZIC_PREP_ROLEREI-BASIN,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         role_desc like zmm_prep_roledes-brief_desc,
       end of t_TABLCTRL112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_itab   type t_TABLCTRL112 occurs 0,
          g_TABLCTRL112_wa     type t_TABLCTRL112. "work area
data:     g_TABLCTRL112_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
controls: TABLCTRL112 type tableview using screen 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_lines  like sy-loopc.
DATA  module_changed_flag.
** POV & checks
types :
        begin of asset_ty,
              ccode type ZIC_PREP_ROLEREQ-CCODE,
              asset type ZQM_PREP_ASSET-ASSET,
              a_desc type Zchar80,
        end of asset_ty.

types :
        begin of basin_ty,
              ccode type ZIC_PREP_ROLEREQ-CCODE,
              basin type ZIC_PREP_ROLEREI-BASIN,
              b_desc type Zchar80,
        end of basin_ty.

  DATA : it_basin type table of basin_ty with header line.
  DATA : it_asset type table of asset_ty with header line.
  DATA : it_location type table of zps_prep_loc with header line.
  DATA : it_loca     type table of zps_prep_loc with header line.
  DATA : it_project type table of zps_prep_project with header line.
  DATA : it_service type table of zps_prep_service with header line.
  DATA : it_plant like table of zqm_prep_loc with header line.
DATA  g_curr_line_112 like sy-stepl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
types: begin of t_TABLCTRL113,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RES like ZIC_PREP_ROLEREI-RES,
         CTF_SLOC like ZIC_PREP_ROLEREI-CTF_SLOC,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_itab   type t_TABLCTRL113 occurs 0,
          g_TABLCTRL113_wa     type t_TABLCTRL113. "work area
data:     g_TABLCTRL113_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
controls: TABLCTRL113 type tableview using screen 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_lines  like sy-loopc.
DATA  g_curr_line_113 like sy-stepl.

*****************
types :
   begin of res_ty,
     res like zpp_prep_res-res,
   end of res_ty.
data : it_res type table of res_ty with header line.
*****************
DATA  pp_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL114'
types: begin of t_TABLCTRL114,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SALE_ORG like ZIC_PREP_ROLEREI-SALE_ORG,
         DIV like ZIC_PREP_ROLEREI-DIV,
         SHIP_POINT like ZIC_PREP_ROLEREI-SHIP_POINT,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_itab   type t_TABLCTRL114 occurs 0,
          g_TABLCTRL114_wa     type t_TABLCTRL114. "work area
data:     g_TABLCTRL114_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
controls: TABLCTRL114 type tableview using screen 0114.

DATA   : it_tvswz like table of tvswz with header line.
DATA   : it_tvko like table of tvko with header line.
DATA   : it_tvkos like table of tvkos with header line.
DATA   : it_tvstz like table of tvstz with header line.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_lines  like sy-loopc.
DATA  g_curr_line_114 like sy-stepl.
DATA  sd_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
types: begin of t_TABLCTRL115,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         ASSET_QM like ZIC_PREP_ROLEREI-ASSET_QM,
         ROLE_DESC like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
       end of t_TABLCTRL115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_itab   type t_TABLCTRL115 occurs 0,
          g_TABLCTRL115_wa     type t_TABLCTRL115. "work area
data:     g_TABLCTRL115_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
controls: TABLCTRL115 type tableview using screen 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_lines  like sy-loopc.
DATA      g_curr_line_115 like sy-stepl.
DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
**
DATA : ist_seltab1 like table of rsparams.
DATA : seltab1 like rsparams.
DATA  qm_not_ok.
DATA  g_error_fundc.
DATA  set_disc_fi_flag.
***********************************************************
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
DATA  attach_fl.
DATA  g_choice_more.
