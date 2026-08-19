*--- MAIN PROGRAM: MZMMPREPROLE3_PHASEIITOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Removed EPC Error: Length
*                                           specification for type I.
************************************************************************
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 334.
************************************************************************

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZIC_PREP_ROLEREQ, ZIC_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
zhelp_mmroles, zmm_prep_role_sl, zhelp_mmroles_rc,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp, zpm_prep_roledes, zps_prep_roledes, v_t357,
zmm_prep_usrcont, zauth_user,
zice_prep_module, ZMM_PREP_STATUS,t001,zpp_prep_roledes,
zpp_prep_generic,zsd_prep_roledes,ZPP_PREP_DROLEEX,
zsd_prep_level,zpp_prep_res,zsd_prep_area,zqm_prep_roledes,
zhelp_qmroles,zqm_prep_loc,zqm_prep_asset,zmm_prep_crcdesg,
zps_prep_loca,zhs_prep_roledes,ZMM_PREP_CRCIMII,zOL_prep_roledes

*.

"""""""
,ZSR_PREP_ROLEDES.
"""""""""

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

TYPES : begin of in_roles,
            Role_type(04),
            Role_name like vagratts-agr_name,
            fr_date_auth(10),
            to_date_auth(10),
        end of in_roles,

        begin of out_roles,
            Userid like sy-uname,
            Role_name like vagratts-agr_name,
            fr_date_auth(10),
            to_date_auth(10),
        end of out_roles,

        begin of userids,
            cpfno like sy-uname,
        end of userids.

types : begin of del_roles,
            Userid like sy-uname,
            Role_name like vagratts-agr_name,
        end of del_roles.


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

data : p1_file LIKE rlgrap-filename value 'C:\role_upload.txt'.

DATA : it_roles TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_pm TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_ps TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_pp TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_sd TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1_pp like standard table of zhelp_pproles1.
DATA : it_roles1_pp_tmp like standard table of zhelp_pproles1.
DATA : it_roles2_pp like standard table of zpp_prep_droleex.
DATA : it_roles3_pp like standard table of zpp_prep_drole.
DATA : it_roles_qm TYPE STANDARD TABLE OF in_roles.
DATA : it_roles_hs TYPE STANDARD TABLE OF in_roles.
**Code added by CAB_AMITMOZA   CR:30007580 WR:RD1K983325  dt:18.03.2013
DATA : it_roles_olm TYPE STANDARD TABLE OF in_roles.
DATA  WA_ROLES_olm like line of it_roles_olm.
**Code end by CAB_AMITMOZA   CR:30007580 WR:RD1K983325
DATA : it_roles0 TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1 TYPE STANDARD TABLE OF out_roles.
DATA : it_roles1_addl TYPE STANDARD TABLE OF out_roles.
DATA : it_agr_users type standard table of agr_users .
DATA : it_role_del_data type table of del_roles.
DATA : wa_role_del_data type del_roles.
DATA : wa_agr_users like agr_users.
DATA : wa_roles TYPE in_roles.   " work area
DATA : wa_roles1_pp like zhelp_pproles1.
DATA : wa_roles2_pp like zpp_prep_droleex.
DATA : wa_roles3_pp like zpp_prep_drole.
DATA : WA_ROLES1 type out_roles.

DATA : ist_seltab like table of rsparams.
DATA : seltab like rsparams.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
DATA : ist_data1 TYPE STANDARD  TABLE OF ty_data with header line.
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
DATA : cpf_lfb1(10) type c.

*--------Purpose: Sending mail to user
data : object_content like solisti1  occurs 0 with header line.
data : begin of objhead occurs 5.
        include structure solisti1.
data : end of objhead.

data : begin of document_data.
        include structure sodocchgi1.
data : end of document_data.
data : receivers type table of   somlreci1  .
data : wa_receivers type somlreci1.
data : sent_to_all   like  sonv-flag.
DATA : g_flag.
*--------------------------------------


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
DATA  disp_flag.
DATA  g_ins_flag.
DATA : g_lines1 like sy-index.
DATA  ZROLEREQNO like ZMM_PREP_ROLEREq-docno.
*Begin of <RD1K963151>.
DATA  zuserid like ZIC_PREP_ROLEREQ-USERIDCR.
DATA  zapprover like ZIC_PREP_ROLEREQ-USERIDAP.
*End of <RD1K963151>.
DATA  g_ans_mail.
DATA  : Flag.
DATA  gl_ans.
DATA  g_userid like wa_roles1-userid..
* begin of <RD1K960036>
* Length specification is not allowed for type I
*DATA : flag_start, l_color(2) type I.
DATA : flag_start, l_color type I.
* end of <RD1K960036>
DATA  g_clines like sy-index..
DATA  corr_code like sy-ucomm.
DATA  g_role_flag.

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
DATA  l_old_ok_code.
DATA  g_reset_change.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA  g_ctrl_flag.

DATA  g_rej_fl.

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
DATA  i080.
DATA  g_status_update_flag.
DATA  g_status_update_rolereq.
DATA  g_request_close_flag.
DATA  g_request_close_flag_P.
DATA  g_request_close_flag_H.
DATA  g_request_close_flag_R.

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
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA  g_exit_value.

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

DATA  okcode_dblclk like sy-ucomm.
DATA  g_curfield(60).
DATA  g_i80.
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL110,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
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
DATA:     wa_rolesz type t_TABLCTRL110.

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL110 type tableview using screen 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL110_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.
data:     moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
types: begin of t_TABLCTRL111,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         SHOP_NO like ZIC_PREP_ROLEREI-SHOP_NO,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
       end of t_TABLCTRL111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_itab   type t_TABLCTRL111 occurs 0,
          g_TABLCTRL111_wa     type t_TABLCTRL111. "work area
data:     g_TABLCTRL111_copied.           "copy flag
DATA:     wa_rolesz_pm type t_TABLCTRL111.

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
controls: TABLCTRL111 type tableview using screen 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
data:     g_TABLCTRL111_lines  like sy-loopc.
DATA      g_curr_line_111 like sy-stepl.
DATA  check_role_flag.
DATA  WA_ROLES_PM like line of it_roles_pm.
DATA  WA_ROLES_PS like line of it_roles_ps.
DATA  WA_ROLES_PP like line of it_roles_pp.
DATA  wa_roles_sd like line of it_roles_sd.
DATA  wa_roles_qm like line of it_roles_qm.
DATA  wa_roles_hs like line of it_roles_hs.

DATA  status_choice.
DATA   : ist_item like table of zic_prep_rolerei.
DATA   : wa_item like line of ist_item.
DATA  status_process.
DATA  g_mult_module_fl.
DATA : STATUS_DESC like ZMM_PREP_STATUS-STATUS_DESC.
data : it_module1 like table of zic_modules.
DATA : wa_module1 like line of it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  hs_not_ok.
*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
types: begin of t_TABLCTRL112,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         SERVICE like ZIC_PREP_ROLEREI-SERVICE,
         PROJECT like ZIC_PREP_ROLEREI-PROJECT,
         LOCATION like ZIC_PREP_ROLEREI-LOCATION,
         ASSET like ZIC_PREP_ROLEREI-ASSET,
         BASIN like ZIC_PREP_ROLEREI-BASIN,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
       end of t_TABLCTRL112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_itab   type t_TABLCTRL112 occurs 0,
          g_TABLCTRL112_wa     type t_TABLCTRL112. "work area
data:     g_TABLCTRL112_copied.           "copy flag
DATA:     wa_rolesz_ps type t_TABLCTRL112.

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
controls: TABLCTRL112 type tableview using screen 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
data:     g_TABLCTRL112_lines  like sy-loopc.
DATA:     g_curr_line_112 like sy-loopc .
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
  DATA : it_loca  type table of zps_prep_loc with header line.
  DATA : it_location type table of zps_prep_loc with header line.
  DATA : it_project type table of zps_prep_project with header line.
  DATA : it_service type table of zps_prep_service with header line.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
types: begin of t_TABLCTRL113,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         RES like ZIC_PREP_ROLEREI-RES,
         CTF_SLOC like ZIC_PREP_ROLEREI-CTF_SLOC,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_itab   type t_TABLCTRL113 occurs 0,
          g_TABLCTRL113_wa     type t_TABLCTRL113. "work area
data:     g_TABLCTRL113_copied.           "copy flag
DATA:     wa_rolesz_pp type t_TABLCTRL113.

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
controls: TABLCTRL113 type tableview using screen 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
data:     g_TABLCTRL113_lines  like sy-loopc.
DATA  g_curr_line_113 like sy-loopc.
DATA  wa_flag.
DATA  wa_flag1.
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
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         SALE_ORG like ZIC_PREP_ROLEREI-SALE_ORG,
         DIV like ZIC_PREP_ROLEREI-DIV,
         SHIP_POINT like ZIC_PREP_ROLEREI-SHIP_POINT,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_itab   type t_TABLCTRL114 occurs 0,
          g_TABLCTRL114_wa     type t_TABLCTRL114. "work area
data:     g_TABLCTRL114_copied.           "copy flag
DATA:     wa_rolesz_sd type t_TABLCTRL114.

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
controls: TABLCTRL114 type tableview using screen 0114.

DATA   : it_tvswz like table of tvswz with header line.
DATA   : it_tvko like table of tvko with header line.
DATA   : it_tvkos like table of tvkos with header line.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
data:     g_TABLCTRL114_lines  like sy-loopc.
DATA:     g_curr_line_114 like sy-loopc.

DATA  sd_not_ok.
DATA  check_plant_fl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
types: begin of t_TABLCTRL115,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         ASSET_QM like ZIC_PREP_ROLEREI-ASSET_QM,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save like ZIC_PREP_ROLEREI-rej_fl_save,
       end of t_TABLCTRL115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_itab   type t_TABLCTRL115 occurs 0,
          g_TABLCTRL115_wa     type t_TABLCTRL115. "work area
data:     g_TABLCTRL115_copied.           "copy flag
DATA:     wa_rolesz_qm type t_TABLCTRL115.

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
controls: TABLCTRL115 type tableview using screen 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
data:     g_TABLCTRL115_lines  like sy-loopc.
DATA  g_curr_line_115 like sy-index.
DATA  qm_not_ok.
***
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
DATA  gl_ans_save.
DATA  status_process_flag.

*&spwizard: type for the data of tablecontrol 'TABLCTRL116'
types: begin of t_TABLCTRL116,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL116.

*&spwizard: internal table for tablecontrol 'TABLCTRL116'
data:     g_TABLCTRL116_itab   type t_TABLCTRL116 occurs 0,
          g_TABLCTRL116_wa     type t_TABLCTRL116. "work area
data:     g_TABLCTRL116_copied.           "copy flag
DATA:     wa_rolesz_hs type t_TABLCTRL116.

*&spwizard: declaration of tablecontrol 'TABLCTRL116' itself
controls: TABLCTRL116 type tableview using screen 0116.

*&spwizard: lines of tablecontrol 'TABLCTRL116'
data:     g_TABLCTRL116_lines  like sy-loopc.
DATA  g_curr_line_116 like sy-index.

*Begin of <RD1K962817>.
DATA : ist_return_tab3 LIKE STANDARD TABLE OF dynpread WITH HEADER LINE.

DATA : LV_MIN_DESIG TYPE ZMIN_DESIG,
       LV_CURR_ROLE TYPE PERSK.
*End of <RD1K962817>.


**Code added by CAB_AMITMOZA   CR:30007580  WR:RD1K983325 dt:18.03.2013
*&spwizard: type for the data of tablecontrol 'TABLCTRL117'
types: begin of t_TABLCTRL117,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
*           ROLE_NAME(04) ,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         role_desc like zmm_prep_roledes-brief_desc,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         flag,       "flag for mark column
       end of t_TABLCTRL117.

*&spwizard: internal table for tablecontrol 'TABLCTRL117'
data:     g_TABLCTRL117_itab   type t_TABLCTRL117 occurs 0,
          g_TABLCTRL117_wa     type t_TABLCTRL117. "work area
data:     g_TABLCTRL117_copied.           "copy flag
DATA:     wa_rolesz_OLM type t_TABLCTRL117.

*&spwizard: declaration of tablecontrol 'TABLCTRL117' itself
controls: TABLCTRL117 type tableview using screen 0117.

*&spwizard: lines of tablecontrol 'TABLCTRL117'
data:     g_TABLCTRL117_lines  like sy-loopc.
DATA  g_curr_line_117 like sy-index.

***************************************** Added by Bipin
DATA : GT_BUCKET_EX TYPE TABLE OF ZIC_PREP_ROLEREI,
       WA_BUCKET_EX TYPE ZIC_PREP_ROLEREI.

DATA :  REQNUM_EX  TYPE ZIC_PREP_ROLEREQ-DOCNO.


DATA : GT_BUCKET TYPE TABLE OF ZIC_PREP_ROLEREI,
       WA_BUCKET TYPE ZIC_PREP_ROLEREI.

DATA : IT_TVARV TYPE TABLE OF TVARVC,
       WA_TVARV TYPE TVARVC.

DATA : LV_GRCCALL TYPE C.
DATA : LV_SUBRC TYPE SY-SUBRC.

DATA : OKCODE_EX TYPE SY-UCOMM,
      OC_9001_RJ TYPE SY-UCOMM.

DATA : GT_ICON TYPE TABLE OF ZGRC_SOD_RESULT,
       WA_ICON TYPE ZGRC_SOD_RESULT.

DATA : GT_ICON1 TYPE TABLE OF ZGRC_SOD_RESULT,
       WA_ICON1 TYPE ZGRC_SOD_RESULT.

DATA : LV_COUNT TYPE I.

TYPE-POOLS ICON.
DATA GICON(4) TYPE C.

DATA : RISK_DESC TYPE STRING.

   DATA :     CRT_NAME TYPE ZIC_PREP_ROLEREQ-USERIDCR,
        TCODE_RJ TYPE SY-TCODE,
        OKCODE_RJ TYPE SY-UCOMM.


***************************************** Added by Bipin


**Code END by CAB_AMITMOZA   CR:30007580  WR:RD1K983325


""""""""""""""""""""
*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
types: begin of t_TABLCTRL118,
         DOCNO like ZIC_PREP_ROLEREI-DOCNO,
         MODULEID like ZIC_PREP_ROLEREI-MODULEID,
         SRNO like ZIC_PREP_ROLEREI-SRNO,
         ROLE_NAME like ZIC_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZIC_PREP_ROLEREI-PLANT,
         GRP like ZIC_PREP_ROLEREI-GRP,
         SLOC like ZIC_PREP_ROLEREI-SLOC,
         RECEIPT_LOC like ZIC_PREP_ROLEREI-RECEIPT_LOC,
         APPROVER like ZIC_PREP_ROLEREI-APPROVER,
         STATUS like ZIC_PREP_ROLEREI-STATUS,
         ROLE_REQUEST like ZIC_PREP_ROLEREI-ROLE_REQUEST,
         REJ_FL like ZIC_PREP_ROLEREI-REJ_FL,
         REJ_ID like ZIC_PREP_ROLEREI-REJ_ID,
         REJ_DATE like ZIC_PREP_ROLEREI-REJ_DATE,
         REJ_FL_SAVE like ZIC_PREP_ROLEREI-REJ_FL_SAVE,
         shop_no like ZIC_PREP_ROLEREI-shop_no,
         role_desc like zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex like zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
       end of t_TABLCTRL118.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL118_itab   type t_TABLCTRL118 occurs 0,
          g_wa_pgrp TYPE T_TABLCTRL118,"work area
          g_TABLCTRL118_wa     type t_TABLCTRL118. "work area
data:     g_TABLCTRL118_copied.           "copy flag
*DATA:     wa_rolesz type t_TABLCTRL110.

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
controls: TABLCTRL118 type tableview using screen 0118.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
data:     g_TABLCTRL118_lines  like sy-loopc.
DATA  g_curr_line_118 like sy-stepl.


data:it_roles_srm TYPE STANDARD TABLE OF in_roles,
      wa_roles_srm LIKE LINE OF it_roles_srm.
DATA: l_logsys(32),
p_uname type XUBNAME.

TYPES :BEGIN OF ty_srmp,
  mandt TYPE mandt,
  userid LIKE zic_prep_rolereq-userid,
  ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME,
  CCODE LIKE ZIC_PREP_ROLEREQ-CCODE,
  GRP LIKE ZIC_PREP_ROLEREI-GRP,
  FROM_DAT TYPE sy-datum,
  TO_DAT   TYPE sy-datum,
  END OF ty_srmp.


  TYPES:BEGIN OF ty_return,
    MANDT TYPE mandt,
UNAME TYPE persno,
GRP TYPE ZIC_PREP_ROLEREI-GRP,
ROLE_NAME type ZIC_PREP_ROLEREI-ROLE_NAME,
STATUS TYPE char2,
END OF ty_return.

  data:it_roles_srmp TYPE TABLE OF ty_srmp,
      wa_roles_srmp LIKE LINE OF it_roles_srmp,
      WA_ZBCUSRMST TYPE ZBCUSRMST,
      p_fname TYPE ZBCUSRMST-FIRST_NAME,
      p_lname TYPE ZBCUSRMST-LAST_NAME,
      p_ccode TYPE bukrs.
data:g_line_srm(120).
data:grp_flag_srm.

data:itab_return TYPE TABLE OF ty_return,
     wa_return LIKE LINE OF  itab_return,
     v_srm_st TYPE C,
     l_flag_msg type c,
       V_APP TYPE c,
     p_grp  TYPE ZCHAR03,
     p_role TYPE ZIC_PREP_ROLEREI-ROLE_NAME,
     v_exist TYPE char1,
    v_rolereq-DOCNO type  ZAUTH_HEAD-AUTH_REQ_NO ,
    p_uname_sms TYPE persno,
    G_USERID_n TYPE persno,
    v_message_srm TYPE char120,
    count_grp(4) TYPE n,
    g_user_l2(2).

""""""""""""""""""""""""
