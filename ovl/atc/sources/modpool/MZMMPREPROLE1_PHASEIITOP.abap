*--- MAIN PROGRAM: MZMMPREPROLE1_PHASEIITOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 68.
*  3) CR No. 30012322  RD1K996279 CAB_SUDHIR

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* 24.02.2015   <RD1K996042>  CAB_SPYADAV    CR 30012295(LIPSY)         *
*                                          (Simultaneous assignment of *
*                                           MM  and OLM roles          *
*                                          during approval)            *
*&                                                                     *
*&                                                                     *
* 19.03.2015   <RD1K996555>  CAB_SPYADAV   CR 30012482(LIPSY)          *
*                                          (Simultaneous assignment of *
*                                           cross company ,multi module
*                                           roles,during approval      *
"                                          ,SRM Module introductin)    *
*&                                                                     *
*&                                                                     *
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


************************************************************************

PROGRAM  sapmzmmpreprole               .

TABLES : zic_prep_rolereq, zic_prep_rolerei, zmm_prep_roledes, zusrmst,
         lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
         zmm_prep_rej_lis, zmm_prep_ex_app, soodk, sood5, zmm_prep_rolecrc,
         zmm_prep_sl_excp, zpm_prep_roledes, v_t357, zice_prep_module,
         zmm_prep_status,zps_prep_roledes,zps_prep_service,zps_prep_project,
         zps_prep_asst_ex,zps_prep_loc,t001,zpp_prep_roledes,zpp_prep_droleex,
         zsd_prep_roledes,zqm_prep_roledes, zpp_prep_generic,zhelp_pproles1,
         zqm_prep_loc, zqm_prep_asset, tvta, zsd_prep_ldggrp,zmm_prep_crcdesg,
         zps_prep_loca, zps_prep_serv_rl,zhs_prep_roledes, agr_users,fmhisv , pa9205,
         zol_prep_roledes, zol_prep_rolerei,
         zfi_prep_roledes, ""ZFI_PREP_ROLEREI,
         """""""""""""""""""""""""""""""""""""""""""""
         "commented by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
*.
         "end of comment by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
         """""""""""""""""""""""""""""""""
         """""""""""""""""""""""""""""""""""""
         "added by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042
         zhelp_mmroles_rc,zmm_prep_role_sl,zmm_prep_crcimii,zauth_user,zauth_head,agr_define, zauth_excp,
         zauth_item,usr21,
         "end of addition by lipsy on 20.02.2015 for simultaneous assignment of roles with approval RD1K996042

         """""""""""""""""""""""""""""""""""""""""""""""""

         """""""""""""""""""""""""""""""""""""""""""""""""""""""""
         "addition by lipsy  for srm module introduction on 20.02.2015 RD1K996555
         zsr_prep_roledes.
"end of addition by lipsy  for srm module introduction on 20.02.2015 RD1K996555


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

TYPE-POOLS cxtab .


TYPES: BEGIN OF tab_type,
         fcode LIKE rsmpe-func,
       END OF tab_type.

TYPES : BEGIN OF ty_t024,
          ekgrp LIKE t024-ekgrp,
          eknam LIKE t024-eknam,
        END OF ty_t024.

TYPES: BEGIN OF ty_m_fistb.
TYPES: g_mark.
        INCLUDE STRUCTURE m_fistb.
TYPES: END OF ty_m_fistb.

TYPES : BEGIN OF ty_data,
          pernr        LIKE pa0027-pernr,
          begda        LIKE pa0001-begda,
          endda        LIKE pa0001-endda,
          name         LIKE pa0001-ename,
          bukrs        LIKE pa0001-bukrs,
          werks        LIKE pa0001-werks,
          persk        LIKE pa0001-persk,
          kbu01        LIKE pa0027-kbu01,
          kgb01        LIKE pa0027-kgb01,
          kst01        LIKE pa0027-kst01,
          designo      LIKE pa9930-designo,
          r_p_cd       LIKE pa9930-r_p_cd,
          version      LIKE pa9930-version,
          designation  LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          disc_cd      LIKE zdesignation_rev-disc_cd,
          sbmod        TYPE pa0001-sbmod,
        END OF ty_data.

DATA: it_tab    TYPE STANDARD TABLE OF tab_type WITH
      NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      wa_tab    TYPE tab_type,
      wa_pa0027 TYPE pa0027.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data WITH HEADER LINE.
DATA : it_m_fistb  TYPE STANDARD TABLE OF ty_m_fistb,
*Begin of <RD1K963151>.
       wa_fistb    TYPE  ty_m_fistb,
       it_m_fistb1 TYPE STANDARD TABLE OF ty_m_fistb WITH HEADER LINE,
       wa_fistb1   TYPE  ty_m_fistb.
*End of <RD1K963151>.

DATA : txt1(80).
****************************************************************
TYPES:
  BEGIN OF ty_view_apx,
    selc(1) TYPE c.
        INCLUDE STRUCTURE bcos_appx.
TYPES: END OF ty_view_apx.

CONSTANTS: cs_x(1) VALUE 'X'.

DATA : g_apx_exist(1).

DATA: BEGIN OF gs_win_head.
        INCLUDE STRUCTURE soxwd.
DATA: END OF gs_win_head.

DATA : gt_cont       LIKE soli OCCURS 0 WITH HEADER LINE,
       gv_filetype   LIKE rlgrap-filetype,
       gv_filename   TYPE string,
       g_apx_cnt     LIKE bcos_appx-appxno,
       g_apx_ptr     LIKE bcos_appx-firstl,
       g_apx_bin_ptr LIKE bcos_appx-firstl,
       gt_ac_cont    LIKE soli OCCURS 0 WITH HEADER LINE,
       gt_ac_contx   LIKE solix OCCURS 0 WITH HEADER LINE,
       gt_view_apx   TYPE ty_view_apx OCCURS 0 WITH HEADER LINE,
       gt_ac_apx     LIKE bcos_appx OCCURS 5 WITH HEADER LINE,
       gt_contx      LIKE solix OCCURS 0 WITH HEADER LINE.
****************************************************************
DATA g_object_id         LIKE soodk.
DATA g_attachments  LIKE sood5 OCCURS 0 WITH HEADER LINE.
DATA g_attachments_read TYPE c.
DATA on  TYPE c VALUE 'X'.
****************************************************************

DATA : tab TYPE STANDARD TABLE OF tab_type WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

DATA  dynnr LIKE sy-dynnr.

DATA : lv_old      TYPE char2,
       lv_new      TYPE char2,
       l_answer(1) TYPE c.

DATA  g_mode.
DATA  okcode LIKE sy-ucomm.
DATA  g_lock.
DATA  g_hd_copied.
DATA  g_cors.
DATA  g_char(120).
DATA  g_line1(120).
* Begin of <RD1K981840>
*DATA : cpf_lfb1(08) type c.
DATA : cpf_lfb1 TYPE persno.
* End of <RD1K981840>
*&spwizard: type for the data of tablecontrol 'TABCTRL100'
TYPES: BEGIN OF t_tabctrl100,
         docno        LIKE zic_prep_rolerei-docno,
         role_request LIKE zic_prep_rolerei-role_request,
         role_name    LIKE zic_prep_rolerei-role_name,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         sloc         LIKE zic_prep_rolerei-sloc,
         flag,       "flag for mark column
         srno         LIKE zic_prep_rolerei-srno,
         approver     LIKE zic_prep_rolerei-approver,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         status       LIKE zic_prep_rolerei-status,
       END OF t_tabctrl100.

DATA: ist_itemtab TYPE STANDARD TABLE OF zic_prep_rolerei.
DATA: wa_itemtab LIKE zic_prep_rolerei.

***********************************************************************
DATA : ist_colsscreen TYPE TABLE OF cxtab_column-screen.
DATA : ist_column TYPE STANDARD TABLE OF cxtab_column WITH NON-UNIQUE
DEFAULT KEY.
***********************************************************************

*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*

DATA: gv_splitter  TYPE REF TO cl_gui_easy_splitter_container, "#EC NEEDED
      gv_splitter1 TYPE REF TO cl_gui_easy_splitter_container,
      gv_splitter2 TYPE REF TO cl_gui_easy_splitter_container.

DATA: gv_custom_container TYPE REF TO cl_gui_custom_container.

DATA: gv_text_editor  TYPE REF TO cl_gui_textedit,          "#EC NEEDED
      gv_text_editor1 TYPE REF TO cl_gui_textedit,
      gv_text_editor2 TYPE REF TO cl_gui_textedit.

DATA : display_flag LIKE  lv70t-xflag VALUE space.

DATA: BEGIN OF tlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab.
DATA: BEGIN OF tlinetab1 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab1.
DATA: BEGIN OF tlinetab2 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF tlinetab2.

CONSTANTS: gc_text_line_length TYPE i VALUE 132.

TYPES: text_table_type(gc_text_line_length) TYPE c OCCURS 0.

DATA: lt_text_table  TYPE text_table_type,
      lt_text_table1 TYPE text_table_type,
      lt_text_table2 TYPE text_table_type.


DATA: gv_xthead_updkz TYPE i.

DATA: BEGIN OF tinlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA: END OF tinlinetab.

DATA: ls_thead LIKE thead OCCURS 0 WITH HEADER LINE.

DATA: l_thead LIKE ls_thead OCCURS 0 WITH HEADER LINE.

DATA  g_tdname(12).

DATA: BEGIN OF lines20 OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF lines20.

DATA: g2_lines LIKE tline.

DATA: BEGIN OF lines_cors OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF lines_cors.

DATA: BEGIN OF g_lines OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF g_lines.

***************************************************************

*&spwizard: internal table for tablecontrol 'TABCTRL100'
DATA:     g_tabctrl100_itab TYPE t_tabctrl100 OCCURS 0,
          g_tabctrl100_wa   TYPE t_tabctrl100. "work area
DATA:     g_tabctrl100_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABCTRL100' itself
CONTROLS: tabctrl100 TYPE TABLEVIEW USING SCREEN 0100.
DATA cols LIKE LINE OF tabctrl100-cols.

*&spwizard: lines of tablecontrol 'TABCTRL100'
DATA:BEGIN OF g_linefrto ,
       line_fr TYPE i,
       line_to TYPE i,
     END OF g_linefrto.
DATA: g_linefrto_itab LIKE TABLE OF g_linefrto.
DATA : g_tabctrl100_lines  LIKE sy-loopc.
DATA : it_cond LIKE TABLE OF g_char.
DATA : g_select(2).
DATA : g_select_flag.
DATA : it_t024 TYPE STANDARD TABLE OF t024.
DATA : wa_t024 LIKE LINE OF it_t024.
DATA : it_t024_1 TYPE STANDARD TABLE OF t024.
DATA : role_desc(40).
DATA : okcode_100 LIKE sy-ucomm.
DATA : okcode_100_p LIKE sy-ucomm. " + BY BIPIN TO VALIDATE POP UP MESSAGE
DATA : g_line(120).
DATA : help_list_flag.
DATA : wa_m_fistb TYPE ty_m_fistb.
DATA : lines LIKE sy-index.
DATA : flag_s_fundc VALUE 'X'.
DATA : lines_index LIKE sy-index.
DATA : zdocnumb(12).
DATA : insert_items.
DATA : old_ok_code LIKE sy-ucomm.
DATA : g_srno LIKE sy-index.
DATA : old_doc_no LIKE zic_prep_rolereq-docno.
DATA : g_line132(132) TYPE c.
DATA : g_cores_sender LIKE tline-tdline.
DATA : g_user(2).
DATA : g_user_found.
DATA : err_flg.
DATA : tab1_lines LIKE sy-index.
DATA : tab2_lines LIKE sy-index.
DATA : flag1, flag2.
DATA  read_flag.
DATA  g_ins_flag.
DATA  g_cursor_line LIKE sy-stepl.
DATA  g_curr_line LIKE sy-stepl.
DATA  g_current_line LIKE sy-stepl.
DATA  g_curr_line_100 LIKE sy-stepl.
DATA  g_curr_line_110 LIKE sy-stepl.
DATA  g_curr_line_117 LIKE sy-stepl.
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  g_reset_fl.
DATA  g_docno LIKE zic_prep_rolereq-docno.
DATA  g_app_rel.
DATA  g_release LIKE zic_prep_rolereq-req_cr_fl.
DATA  g_approve LIKE zic_prep_rolereq-req_app_fl.
DATA  g_approve1 LIKE zic_prep_rolereq-req_app1_fl.
DATA  g_i LIKE sy-index.
DATA  g_tc_lines LIKE sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl LIKE sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  g_role_name_prev LIKE zic_prep_rolerei-role_name.
DATA  g_role_name_flag.
DATA  g_persa LIKE pa0001-werks.
DATA  g_approve0 LIKE zic_prep_rolereq-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  crc_check_fl.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files LIKE TABLE OF swotobjid.
DATA g_att_files_wa LIKE swotobjid.
DATA : exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
*************************
DATA  old_userid LIKE zic_prep_rolereq-userid.
DATA  g_val_err.
DATA  g_lines_2 LIKE sy-index.
DATA  old_ok_code_crc LIKE old_ok_code.
DATA  g_crc_fl.
DATA  g_ccode LIKE zic_prep_rolereq-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
DATA : g_field_tab LIKE TABLE OF dfies.
DATA : g_field_wa  LIKE dfies.
DATA  approver_flag.
DATA  g_ccode_crossco LIKE zic_prep_rolereq-ccode.
DATA : crc_pos(132).

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
TYPES: BEGIN OF t_tablctrl110,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tablctrl110.

*&spwizard: internal table for tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl110_itab TYPE t_tablctrl110 OCCURS 0,
          g_tablctrl110_wa   TYPE t_tablctrl110. "work area
DATA:     g_tablctrl110_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
CONTROLS: tablctrl110 TYPE TABLEVIEW USING SCREEN 0110.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl110_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.
DATA:     moduleid(3).
DATA:     new_moduleid(3).
DATA      old_moduleid(3).

*&spwizard: type for the data of tablecontrol 'TABLCTRL111'
TYPES: BEGIN OF t_tablctrl111,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         flag,       "flag for mark column
       END OF t_tablctrl111.

*&spwizard: internal table for tablecontrol 'TABLCTRL111'
DATA:     g_tablctrl111_itab TYPE t_tablctrl111 OCCURS 0,
          g_tablctrl111_wa   TYPE t_tablctrl111. "work area
DATA:     g_tablctrl111_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL111' itself
CONTROLS: tablctrl111 TYPE TABLEVIEW USING SCREEN 0111.

*&spwizard: lines of tablecontrol 'TABLCTRL111'
DATA:     g_tablctrl111_lines  LIKE sy-loopc.
DATA      g_curr_line_111 LIKE sy-stepl.
DATA  check_role_flag.
DATA   : ist_item LIKE TABLE OF zic_prep_rolerei.
DATA   : wa_item LIKE LINE OF ist_item.
DATA  g_l4.
DATA  modulemm_fl.
DATA  moduleid_save LIKE zic_prep_rolerei-moduleid.
DATA  g_mult_module_fl.
DATA : status_desc LIKE zmm_prep_status-status_desc.
DATA : it_module1 LIKE TABLE OF zic_modules.
DATA : wa_module1 LIKE LINE OF it_module1.
DATA  mm_not_ok.
DATA  pm_not_ok.
DATA  ps_not_ok.
DATA  hs_not_ok.
DATA  g_choice_app.

*&spwizard: type for the data of tablecontrol 'TABLCTRL112'
TYPES: BEGIN OF t_tablctrl112,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         service      LIKE zic_prep_rolerei-service,
         project      LIKE zic_prep_rolerei-project,
         location     LIKE zic_prep_rolerei-location,
*         REGION like ZIC_PREP_ROLEREI-REGION,
         asset        LIKE zic_prep_rolerei-asset,
         basin        LIKE zic_prep_rolerei-basin,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
       END OF t_tablctrl112.

*&spwizard: internal table for tablecontrol 'TABLCTRL112'
DATA:     g_tablctrl112_itab TYPE t_tablctrl112 OCCURS 0,
          g_tablctrl112_wa   TYPE t_tablctrl112. "work area
DATA:     g_tablctrl112_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL112' itself
CONTROLS: tablctrl112 TYPE TABLEVIEW USING SCREEN 0112.

*&spwizard: lines of tablecontrol 'TABLCTRL112'
DATA:     g_tablctrl112_lines  LIKE sy-loopc.
DATA  module_changed_flag.
** POV & checks
TYPES :
  BEGIN OF asset_ty,
    ccode  TYPE zic_prep_rolereq-ccode,
    asset  TYPE zqm_prep_asset-asset,
    a_desc TYPE zchar80,
  END OF asset_ty.

TYPES :
  BEGIN OF basin_ty,
    ccode  TYPE zic_prep_rolereq-ccode,
    basin  TYPE zic_prep_rolerei-basin,
    b_desc TYPE zchar80,
  END OF basin_ty.

DATA : it_basin TYPE TABLE OF basin_ty WITH HEADER LINE.
DATA : it_asset TYPE TABLE OF asset_ty WITH HEADER LINE.
DATA : it_location TYPE TABLE OF zps_prep_loc WITH HEADER LINE.
DATA : it_loca     TYPE TABLE OF zps_prep_loc WITH HEADER LINE.
DATA : it_project TYPE TABLE OF zps_prep_project WITH HEADER LINE.
DATA : it_service TYPE TABLE OF zps_prep_service WITH HEADER LINE.
DATA : it_plant LIKE TABLE OF zqm_prep_loc WITH HEADER LINE.
DATA  g_curr_line_112 LIKE sy-stepl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
TYPES: BEGIN OF t_tablctrl113,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         sloc         LIKE zic_prep_rolerei-sloc,
         res          LIKE zic_prep_rolerei-res,
         ctf_sloc     LIKE zic_prep_rolerei-ctf_sloc,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl113.

*&spwizard: internal table for tablecontrol 'TABLCTRL113'
DATA:     g_tablctrl113_itab TYPE t_tablctrl113 OCCURS 0,
          g_tablctrl113_wa   TYPE t_tablctrl113. "work area
DATA:     g_tablctrl113_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL113' itself
CONTROLS: tablctrl113 TYPE TABLEVIEW USING SCREEN 0113.

*&spwizard: lines of tablecontrol 'TABLCTRL113'
DATA:     g_tablctrl113_lines  LIKE sy-loopc.
DATA  g_curr_line_113 LIKE sy-stepl.

*****************
TYPES :
  BEGIN OF res_ty,
    res LIKE zpp_prep_res-res,
  END OF res_ty.
DATA : it_res TYPE TABLE OF res_ty WITH HEADER LINE.
*****************
DATA  pp_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL114'
TYPES: BEGIN OF t_tablctrl114,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         sale_org     LIKE zic_prep_rolerei-sale_org,
         div          LIKE zic_prep_rolerei-div,
         ship_point   LIKE zic_prep_rolerei-ship_point,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl114.

*&spwizard: internal table for tablecontrol 'TABLCTRL114'
DATA:     g_tablctrl114_itab TYPE t_tablctrl114 OCCURS 0,
          g_tablctrl114_wa   TYPE t_tablctrl114. "work area
DATA:     g_tablctrl114_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL114' itself
CONTROLS: tablctrl114 TYPE TABLEVIEW USING SCREEN 0114.

DATA   : it_tvswz LIKE TABLE OF tvswz WITH HEADER LINE.
DATA   : it_tvko LIKE TABLE OF tvko WITH HEADER LINE.
DATA   : it_tvkos LIKE TABLE OF tvkos WITH HEADER LINE.
DATA   : it_tvstz LIKE TABLE OF tvstz WITH HEADER LINE.

*&spwizard: lines of tablecontrol 'TABLCTRL114'
DATA:     g_tablctrl114_lines  LIKE sy-loopc.
DATA  g_curr_line_114 LIKE sy-stepl.
DATA  sd_not_ok.

*&spwizard: type for the data of tablecontrol 'TABLCTRL115'
TYPES: BEGIN OF t_tablctrl115,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         asset_qm     LIKE zic_prep_rolerei-asset_qm,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
       END OF t_tablctrl115.

*&spwizard: internal table for tablecontrol 'TABLCTRL115'
DATA:     g_tablctrl115_itab TYPE t_tablctrl115 OCCURS 0,
          g_tablctrl115_wa   TYPE t_tablctrl115. "work area
DATA:     g_tablctrl115_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL115' itself
CONTROLS: tablctrl115 TYPE TABLEVIEW USING SCREEN 0115.

*&spwizard: lines of tablecontrol 'TABLCTRL115'
DATA:     g_tablctrl115_lines  LIKE sy-loopc.
DATA      g_curr_line_115 LIKE sy-stepl.
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
**
DATA : ist_seltab1 LIKE TABLE OF rsparams.
DATA : seltab1 LIKE rsparams.
DATA  qm_not_ok.
DATA  g_error_fundc.
DATA  set_disc_fi_flag.
***********************************************************
DATA  it_pos LIKE STANDARD TABLE OF zmm_prep_crcdesg WITH HEADER LINE.
DATA  attach_fl.
DATA  g_choice_more.
DATA  g_choice_rel.

*&spwizard: type for the data of tablecontrol 'TABLCTRL116'
TYPES: BEGIN OF t_tablctrl116,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         flag,       "flag for mark column
       END OF t_tablctrl116.

*&spwizard: internal table for tablecontrol 'TABLCTRL116'
DATA:     g_tablctrl116_itab TYPE t_tablctrl116 OCCURS 0,
          g_tablctrl116_wa   TYPE t_tablctrl116. "work area
DATA:     g_tablctrl116_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL116' itself
CONTROLS: tablctrl116 TYPE TABLEVIEW USING SCREEN 0116.

*&spwizard: lines of tablecontrol 'TABLCTRL116'
DATA:     g_tablctrl116_lines  LIKE sy-loopc.
DATA  g_curr_line_116 LIKE sy-stepl.

DATA : ist_return_tab3 LIKE STANDARD TABLE OF dynpread WITH HEADER LINE.

*Begin of <RD1K963151>
TYPES : BEGIN OF str_fmhisv,
          fikrs     TYPE 	fikrs,
          hivarnt   TYPE  fm_hivarnt,
          fistl     TYPE  fistl,
          hiroot_st TYPE  fm_fictr_t,
          parent_st TYPE  fm_fictr_p,
          next_st   TYPE fm_fictr_n,
          child_st  TYPE  fm_fictr_c,
          hilevel	  TYPE fm_hilevel,
        END OF str_fmhisv.

DATA :it_fmhisv TYPE TABLE OF str_fmhisv WITH HEADER LINE,
      wa_fmhisv TYPE str_fmhisv.
*End of <RD1K963151>.

DATA   :it_9205 TYPE  STANDARD TABLE OF  pa9205,
        wa_9205 TYPE pa9205.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC_117'
TYPES: BEGIN OF t_tc_117,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tc_117.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC_117'
DATA:     g_tc_117_itab TYPE t_tc_117 OCCURS 0,
          g_tc_117_wa   TYPE t_tc_117. "work area
DATA:     g_tc_117_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_117' ITSELF
CONTROLS: tc_117 TYPE TABLEVIEW USING SCREEN 0117.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_117'
DATA:     g_tc_117_lines  LIKE sy-loopc.

********************** data declaration by bipin ****************************************
DATA :  reqnum_ex  TYPE zic_prep_rolereq-docno,
        oc_9001_rj TYPE sy-ucomm,
        oc_9002_rj TYPE sy-ucomm,
        oc_9003_rj TYPE sy-ucomm,
        crt_name   TYPE zic_prep_rolereq-useridcr,
        tcode_rj   TYPE sy-tcode,
        okcode_rj  TYPE sy-ucomm.



DATA : it_tvarv TYPE TABLE OF tvarvc,
       wa_tvarv TYPE tvarvc.

DATA : lv_grccall TYPE c.
DATA : lv_subrc TYPE sy-subrc.


DATA : lv_counter TYPE i VALUE 0.

DATA : wa_grcdata TYPE zic_prep_rolereq.
TYPE-POOLS icon.
DATA gicon(4) TYPE c.

DATA : risk_desc TYPE string.

DATA : gt_icon TYPE TABLE OF zgrc_sod_result,
       wa_icon TYPE zgrc_sod_result.

DATA : gt_icon1 TYPE TABLE OF zgrc_sod_result,
       wa_icon1 TYPE zgrc_sod_result.

DATA : lv_count TYPE i.


DATA : lv_lines TYPE sy-dbcnt.
DATA : gd_percent TYPE i.
DATA : lv_indx1 TYPE sy-tabix.

DATA : check_okcode TYPE c.

*************************Data declaration for FORM GRC_RISK_ANALYSIS. start ***********

DATA : gt_bucket      TYPE TABLE OF zic_prep_rolerei,
       wa_bucket      TYPE zic_prep_rolerei,
       gt_crmodule    TYPE TABLE OF zic_prep_rolerei,
       wa_crmodule    TYPE zic_prep_rolerei,
       gt_bucket1     TYPE zgrc_fi_ttyp,
       wa_bucket1     TYPE zgrc_fi_tabc,
       gt_eroles      TYPE ztb_final1,
       wa_eroles      TYPE ztb_final,
       gt_eroles1     TYPE ztb_final1,
       wa_eroles1     TYPE ztb_final,
       gt_output      TYPE grac_t_sod_prm_viol_det,
       wa_output      TYPE grac_s_sod_prm_viol_det,
       gt_rdesc       TYPE zecc_risk_desc_tt,
       wa_rdesc       TYPE zecc_risk_desc,
       gt_violdtl     TYPE grac_t_sod_prm_viol_det,
       wa_violdtl     TYPE grac_s_sod_prm_viol_det,
       gt_cp_risk     TYPE zecc_risk_desc_tt,
       gt_action_risk TYPE zecc_risk_desc_tt,
       wa_action_risk TYPE zecc_risk_desc,
       wa_cp_risk     TYPE zecc_risk_desc,
       gt_viol_dtl    TYPE TABLE OF zgrc_viol_dtl,
       wa_viol_dtl    TYPE zgrc_viol_dtl.


DATA : gt_bucket_ex   TYPE TABLE OF zic_prep_rolerei,
       wa_bucket_ex   TYPE zic_prep_rolerei,
       gt_crmodule_ex TYPE TABLE OF zic_prep_rolerei,
       wa_crmodule_ex TYPE zic_prep_rolerei.

DATA : okcode_ex TYPE sy-ucomm.



TYPES : BEGIN OF ty_userinfo,
          userid        TYPE  xubname,
          designation   TYPE  ad_dprtmnt,
          persa         TYPE  persa,
          rsn_code      TYPE  zrsn_code,
          telno         TYPE  zchar40,
          ccode         TYPE  bukrs,
          fundc1        TYPE  fm_fictr,
          persk         TYPE  persk,
          reasonforauth TYPE zchar40,
          costc         TYPE kostl,
          desig_level   TYPE zchar02,
          name          TYPE name_last,
          name1         TYPE pbtxt,
          rsn_text1     TYPE char40,
        END OF ty_userinfo.

TYPES : BEGIN OF ty_buk_role,
          docno              TYPE  zchar12,
          moduleid           TYPE  z_module,
          srno               TYPE  zsrno,
          role_name          TYPE  zchar04,
          plant              TYPE  zchar04,
          grp                TYPE  zchar03,
          sloc               TYPE  zchar04,
          receipt_loc        TYPE  zchar04,
          approver           TYPE  zchar02,
          status             TYPE  zchar01,
          role_request       TYPE  zchar12_req,
          rej_fl             TYPE  zchar01,
          rej_id             TYPE  xubname,
          rej_date           TYPE  zrefdate,
          rej_fl_save        TYPE  zchar01,
          shop_no            TYPE  zchar03,
          role_desc          TYPE  zchar40,
          flag               TYPE  char1,
          gl_account         TYPE  saknr,
          bussiness_area     TYPE  gsber,
          fund_ctr_gp        TYPE  fistl,
          jva_grp            TYPE  bukrs,
          sub_module         TYPE  zchar04,
          role_sensitivity   TYPE  zchar01,
          fr_date_auth       TYPE  zrefdate,
          to_date_auth       TYPE  zchar04,
          role_type_ex       TYPE  zchar02,
          sale_org           TYPE  vkorg,
          div                TYPE  spart,
          ship_point         TYPE  vstel,
          asset              TYPE  zchar03_a,
          basin              TYPE  zchar03_b,
          project            TYPE  zchar02_p,
          location           TYPE  zchar02_l,
          asset_qm           TYPE  zchar04,
          res                TYPE  arbpl,
          ctf_sloc           TYPE  zchar04,
          userid             TYPE  syuname,
          role_type          TYPE  zchar04,
          role_name_final    TYPE  role_name,
          fr_date_auth_final TYPE  char10,
          to_date_auth_final TYPE char10,
        END OF ty_buk_role.


DATA : gt_userinfo    TYPE TABLE OF ty_userinfo,
       wa_userinfo    TYPE ty_userinfo,
       gt_buk_role    TYPE TABLE OF ty_buk_role,
       wa_buk_role    TYPE ty_buk_role,
       gt_final_tb    TYPE TABLE OF zgrc_sod_result,
       wa_final_tb    TYPE zgrc_sod_result,
       gt_output_temp TYPE STANDARD TABLE OF zgrc_sod_result,
       gs_output_temp TYPE zgrc_sod_result.

FIELD-SYMBOLS: <fs_final> TYPE zgrc_sod_result.
DATA :gt_item_fieldcat    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_list_top_of_page TYPE slis_t_listheader,
      gt_events           TYPE slis_t_event,
      fs_eventcat         LIKE LINE OF gt_events,
      gt_layout           TYPE slis_layout_alv.

DATA : v_snum TYPE n LENGTH 10.
DATA : lv_snum TYPE n LENGTH 10,
*      LV_DOCNO TYPE ZGRC_SOD_RESULT-DOCNO,
       lv_ind  TYPE i.

DATA : v_snum1 TYPE n LENGTH 10.
DATA : lv_snum1 TYPE n LENGTH 10.

DATA : gt_risk TYPE TABLE OF zgrc_sod_result,
       wa_risk TYPE zgrc_sod_result.

DATA : gt_log TYPE TABLE OF zgrc_log,
       wa_log TYPE zgrc_log.

DATA : gt_text TYPE TABLE OF lvc_txt132,
       gw_text TYPE  lvc_txt132.


DATA : zice_ex TYPE zice_arms_comment,
       lv_expo TYPE c.

DATA : lv_risk   TYPE i,
       lv_rcount TYPE i.


************************data declaration to sent mail at first level approvel : by Bipin Shukla
DATA: docdata      TYPE sodocchgi1,
      objpack      TYPE TABLE OF sopcklsti1 WITH HEADER LINE,
      objpack_line LIKE LINE OF objpack,
      gt_objhead   TYPE TABLE OF solisti1,
      wa_objhead   TYPE solisti1,
      objbin       TYPE TABLE OF solisti1,
      gt_reclist   TYPE TABLE OF somlreci1,
      lv_tab_lines TYPE sy-tabix,
      wa_reclist   TYPE somlreci1.


DATA : gt_urinfo TYPE TABLE OF pa0105,
       wa_urinfo TYPE pa0105.

DATA : gt_uname TYPE TABLE OF pa0002,
       wa_uname TYPE pa0002.

DATA : lv_urname TYPE pad_nachn.

DATA : gt_appinfo TYPE TABLE OF pa0105,
       wa_appinfo TYPE pa0105.

DATA : gt_appname TYPE TABLE OF pa0002,
       wa_appname TYPE pa0002.

DATA : lv_appname TYPE pad_nachn.


DATA : gt_role_usr TYPE TABLE OF agr_users,
       wa_role_usr TYPE          agr_users.

DATA  : lv_rfc     TYPE rfcdest,
        lv_msg_var TYPE i.

DATA: it_call TYPE TABLE OF tvarvc,
      wa_call TYPE tvarvc.

DATA  : lv5_rfc TYPE rfcdest.
DATA  : lv6_rfc TYPE rfcdest.
DATA  : lv7_rfc TYPE rfcdest.
DATA  : lv8_rfc TYPE rfcdest.
DATA  : lv9_rfc TYPE rfcdest.



************************data declaration to sent mail at first level approvel : by Bipin Shukla

*  DATA : lv_lines TYPE I.
*DATA : LV_LINES1 TYPE SY-DBCNT.
*DATA : GD_PERCENT TYPE I.
*DATA : LV_INDX1 TYPE SY-TABIX.
*
*DATA : CHECK_OKCODE TYPE C.

*************************Data declaration for FORM GRC_RISK_ANALYSIS. end *************

********************** data declaration by bipin *************************************************
* Begin of <> on 24032014
CONSTANTS: objtype TYPE borident-objtype VALUE 'ZGOS'.
TYPES: BEGIN OF exclude_type,
         fcode LIKE rsmpe-func,
       END OF exclude_type.
DATA: manager    TYPE REF TO cl_gos_manager,
      obj        TYPE borident,
      exclude_wa TYPE exclude_type.
DATA: lt_set_values TYPE TABLE OF rgsb4,
      g_tcode1(8),
      g_tcode       TYPE sy-ucomm,
      uname         TYPE sy-uname.
* End of <>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""added by lipsy on 13.02.2015 for simultaneous assignment of roles with approval RD1K996042
*--------Purpose: Sending mail to user
DATA : object_content LIKE solisti1  OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF objhead OCCURS 5.
        INCLUDE STRUCTURE solisti1.
DATA : END OF objhead.

DATA : BEGIN OF document_data.
        INCLUDE STRUCTURE sodocchgi1.
DATA : END OF document_data.
DATA : receivers TYPE TABLE OF   somlreci1  .
DATA : wa_receivers TYPE somlreci1.
DATA : sent_to_all   LIKE  sonv-flag.


TYPES : BEGIN OF ty_data_assn,
          pernr        LIKE pa0027-pernr,
          begda        LIKE pa0001-begda,
          endda        LIKE pa0001-endda,
          name         LIKE pa0001-ename,
          bukrs        LIKE pa0001-bukrs,
          werks        LIKE pa0001-werks,
          persk        LIKE pa0001-persk,
          kbu01        LIKE pa0027-kbu01,
          kgb01        LIKE pa0027-kgb01,
          kst01        LIKE pa0027-kst01,
          designo      LIKE pa9930-designo,
          r_p_cd       LIKE pa9930-r_p_cd,
          version      LIKE pa9930-version,
          designation  LIKE zdesignation_rev-sdesig_text,
          adesignation LIKE zdesignation_rev-adesig_text,
          disc_cd      LIKE zdesignation_rev-disc_cd,
          sbmod        TYPE pa0001-sbmod,
        END OF ty_data_assn.

TYPES : BEGIN OF in_roles,
          role_type(04),
          role_name        LIKE vagratts-agr_name,
          fr_date_auth(10),
          to_date_auth(10),
        END OF in_roles,

        BEGIN OF out_roles,
          userid           LIKE sy-uname,
          role_name        LIKE vagratts-agr_name,
          fr_date_auth(10),
          to_date_auth(10),
        END OF out_roles.

TYPES : BEGIN OF del_roles,
          userid    LIKE sy-uname,
          role_name LIKE vagratts-agr_name,
        END OF del_roles.

DATA : it_roles       TYPE STANDARD TABLE OF in_roles,
       it_roles0      TYPE STANDARD TABLE OF in_roles,
       it_roles1      TYPE STANDARD TABLE OF out_roles,
       it_roles1_addl TYPE STANDARD TABLE OF out_roles,
       it_roles_olm   TYPE STANDARD TABLE OF in_roles.


DATA :  ist_data2 TYPE STANDARD  TABLE OF ty_data_assn WITH HEADER LINE,
        ist_data1 TYPE STANDARD  TABLE OF ty_data_assn WITH HEADER LINE.

DATA : wa_roles     TYPE in_roles,
       wa_roles_olm LIKE LINE OF it_roles_olm.
DATA: wa_itemtab_sl    LIKE zic_prep_rolerei,
      wa_item_req      LIKE LINE OF g_tablctrl110_itab,
      wa_role_del_data TYPE del_roles.
DATA : wa_roles1 TYPE out_roles.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA : lv_min_desig TYPE zmin_desig,
       lv_curr_role TYPE persk.
DATA : p1_file LIKE rlgrap-filename VALUE 'C:\role_upload.txt'.
DATA  gl_ans.
DATA  g_role_flag.
DATA  zrolereqno LIKE zmm_prep_rolereq-docno.
DATA  corr_code LIKE sy-ucomm.
DATA  status_process.
DATA  status_process_flag.
DATA  status_choice.
DATA  : flag.
DATA  gl_ans_save.
DATA  g_request_close_flag_p.
DATA  g_request_close_flag_h.
DATA  g_request_close_flag_r.
DATA  l_old_ok_code.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA : g_userid LIKE wa_roles1-userid,
       l_color  TYPE i.

DATA : ist_seltab LIKE TABLE OF rsparams.
DATA : seltab2 LIKE rsparams.
DATA  zuserid LIKE zic_prep_rolereq-useridcr.
DATA  zapprover LIKE zic_prep_rolereq-useridap.
DATA : p_rem1(40),
       p_rem2(10).
DATA l_options TYPE ctu_params.
DATA: BEGIN OF upl_tab OCCURS 0,
        cpf_no   TYPE zauth_item-cpf_no,
        role     TYPE zauth_item-role,
******************************************
        from_dat LIKE usagr-from_dat,
        to_dat   LIKE usagr-to_dat,

********************************************
      END OF upl_tab.
DATA: BEGIN OF upl_tabx OCCURS 0,
        cpf_no       TYPE zauth_item-cpf_no,
        role         TYPE zauth_item-role,
*****************************************************************
        from_dat(10),
        to_dat(10) ,
*****************************************************************
        role_na(1),
        user_na(1),
        remarks(50),
      END OF upl_tabx.
DATA  zfilename LIKE rscat-evfile.
DATA  zfilename1 LIKE rlgrap-filename.
TYPES: BEGIN OF t_role,
         item_no   LIKE zauth_item-item_no,
         cpf_no    LIKE zauth_item-cpf_no,
         role      LIKE zauth_item-role,
         text      LIKE agr_texts-text,
         from_dat  LIKE usagr-from_dat,
         to_dat    LIKE usagr-to_dat,
*****************************************************************
         user_name LIKE adrp-name_text,
         flag,       "flag for mark column
       END OF t_role.

* INTERNAL TABLE FOR TABLECONTROL 'ROLE'
DATA:     g_role_itab   TYPE t_role OCCURS 0 WITH HEADER LINE.
DATA: s_itab type t_role.
DATA:  zitem_no LIKE zauth_item-item_no.
DATA: zget_number(8) TYPE n.
DATA: l_agr_users1 LIKE TABLE OF agr_users WITH HEADER LINE .
DATA:v_remarks_head TYPE zauth_head-remarks.
DATA:  wa_rolesz_olm  TYPE  t_tc_117,
       v_moduleid(3),
       v_message_as   TYPE c,
       v_message_unas TYPE  char120.

DATA: v_release TYPE c.
"""""end of addition  by lipsy on 13.02.2015 for simultaneous assignment of roles with approval RD1K996042
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"addition by lipsy  for srm module introduction on 2.03.2015 RD1K996555
TYPES: BEGIN OF t_tablctrl118,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         role_type_ex LIKE zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
         agr_name(30),
       END OF t_tablctrl118.

DATA:     g_tablctrl118_itab TYPE t_tablctrl118 OCCURS 0,
          g_wa_pgrp          TYPE t_tablctrl118, "work area
          g_tablctrl118_wa   TYPE t_tablctrl118. "work area
DATA:     g_tablctrl118_copied.           "copy flag

*&spwizard: declaration of tablecontrol 'TABLCTRL110' itself
CONTROLS: tablctrl118 TYPE TABLEVIEW USING SCREEN 0118.

*&spwizard: lines of tablecontrol 'TABLCTRL110'
DATA:     g_tablctrl118_lines  LIKE sy-loopc.
DATA  g_curr_line_118 LIKE sy-stepl.


DATA:it_roles_srm TYPE STANDARD TABLE OF in_roles,
     wa_roles_srm LIKE LINE OF it_roles_srm.
DATA: l_logsys(32),
p_uname TYPE xubname.

TYPES :BEGIN OF ty_srmp,
         mandt     TYPE mandt,
         userid    LIKE zic_prep_rolereq-userid,
         role_name LIKE zic_prep_rolerei-role_name,
         ccode     LIKE zic_prep_rolereq-ccode,
         grp       LIKE zic_prep_rolerei-grp,
         from_dat  TYPE sy-datum,
         to_dat    TYPE sy-datum,
       END OF ty_srmp.


TYPES:BEGIN OF ty_return,
        mandt     TYPE mandt,
        uname     TYPE persno,
        grp       TYPE zic_prep_rolerei-grp,
        role_name TYPE zic_prep_rolerei-role_name,
        status    TYPE char2,
      END OF ty_return.

DATA:it_roles_srmp TYPE TABLE OF ty_srmp,
     wa_roles_srmp LIKE LINE OF it_roles_srmp,
     wa_zbcusrmst  TYPE zbcusrmst,
     p_fname       TYPE zbcusrmst-first_name,
     p_lname       TYPE zbcusrmst-last_name,
     p_ccode       TYPE bukrs.
DATA:g_line_srm(120).
DATA:grp_flag_srm.

DATA:itab_return     TYPE TABLE OF ty_return,
     wa_return       LIKE LINE OF  itab_return,
     v_srm_st        TYPE c,
     l_flag_msg      TYPE c,
     v_app           TYPE c,
     p_grp           TYPE zchar03,
     p_role          TYPE zic_prep_rolerei-role_name,
     v_exist         TYPE char1,
     v_rolereq-docno TYPE  zauth_head-auth_req_no,
     p_uname_sms     TYPE persno,
     g_userid_n      TYPE persno,
     v_message_srm   TYPE char120,
     count_grp(4)    TYPE n,
     g_user_l2(2).
"end of addition by lipsy  for srm module introduction on 2.03.2015 RD1K996555
""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 22.05.2015 RD1K997318
DATA:itab_agr_users TYPE TABLE OF agr_users,
     v_grp_comp     TYPE char5.
"end of addition by lipsy on 22.05.2015 RD1K997318
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*------------Added by Manisha bh.Dt:09.02.2018--------*
DATA : wa_zmm_vms_cr_new TYPE zmm_vms_cr_new,
       wa_pa0001         TYPE pa0001.
*-----------------------------------------------------*
TYPES :
  BEGIN OF ty_bukrs,
    werks LIKE zd_t001w_bukrs-werks,
    name1 LIKE zd_t001w_bukrs-name1,
  END OF ty_bukrs.

DATA   : it_bukrs TYPE TABLE OF ty_bukrs WITH HEADER LINE.

DATA: it_agr TYPE STANDARD TABLE OF bapiagr,
      wa_agr TYPE bapiagr.
