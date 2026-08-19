*--- MAIN PROGRAM: MZFIPREPROLE1_PHASEIITOP ---*
*&---------------------------------------------------------------------*
*& Include MZFIPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapmzfipreprole               .

TABLES : zic_prep_rolereq, zic_prep_rolerei,  zusrmst,
         lfb1, fmzuob, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
         zmm_prep_rej_lis, zmm_prep_ex_app, soodk, sood5, zmm_prep_rolecrc, zauth_excp,
         v_t357, zice_prep_module,zmm_prep_status,t001, zauth_user, zauth_head, zauth_item,
         zfi_prep_roledes,zmm_prep_rsn,zfi_prep_submod.

TYPE-POOLS cxtab .

TYPES : BEGIN OF z_submod_des,
          sub_module LIKE zfi_prep_submod-sub_module,
        END OF z_submod_des.

DATA   : it_submod TYPE TABLE OF z_submod_des WITH HEADER LINE.

TYPES :
  BEGIN OF ty_b_area,
    gsber LIKE tgsb-gsber,
  END OF ty_b_area.

DATA   : it_b_area TYPE TABLE OF ty_b_area WITH HEADER LINE.


TYPES :
  BEGIN OF ty_f_ctr,
    fictr LIKE zic_prep_rolerei-fund_ctr_gp,
  END OF ty_f_ctr.

DATA   : it_f_ctr1 TYPE TABLE OF ty_f_ctr WITH HEADER LINE.
DATA   : it_f_ctr TYPE TABLE OF ty_f_ctr WITH HEADER LINE.
DATA   : it_module LIKE TABLE OF zic_modules.

DATA: status_icon   TYPE icons-text,
      icon_name(20) TYPE c,
      icon_text(10) TYPE c.

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

DATA : ist_seltab LIKE TABLE OF rsparams.
DATA : seltab LIKE rsparams.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data WITH HEADER LINE.
DATA : it_m_fistb TYPE STANDARD TABLE OF ty_m_fistb.

****************************************************************
TYPES:
  BEGIN OF ty_view_apx,
    selc(1) TYPE c.
        INCLUDE STRUCTURE bcos_appx.
TYPES: END OF ty_view_apx.

CONSTANTS: cs_x(1) VALUE 'X'.

DATA : g_apx_exist(1).
DATA : okcode_insert_line TYPE i.  "Var for clearing insert line table
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

DATA  g_mode.
DATA  okcode LIKE sy-ucomm.
DATA  g_lock.
DATA  g_hd_copied.
DATA  g_cors.
DATA  g_char(120).
DATA  g_line1(120).
DATA : cpf_lfb1(08) TYPE c.

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
DATA : g_flag.
*--------------------------------------

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

DATA: ist_itemtab_del TYPE STANDARD TABLE OF zic_prep_delrole.
DATA: wa_itemtab_del LIKE zic_prep_delrole.


***********************************************************************
DATA : ist_colsscreen TYPE TABLE OF cxtab_column-screen.
DATA : ist_column TYPE STANDARD TABLE OF cxtab_column WITH NON-UNIQUE
DEFAULT KEY.
***********************************************************************

*---------------------------------------------------------------------*
* Tree
*---------------------------------------------------------------------*

DATA: gv_splitter  TYPE REF TO cl_gui_easy_splitter_container,
      gv_splitter1 TYPE REF TO cl_gui_easy_splitter_container,
      gv_splitter2 TYPE REF TO cl_gui_easy_splitter_container.

DATA: gv_custom_container TYPE REF TO cl_gui_custom_container.

DATA: gv_text_editor  TYPE REF TO cl_gui_textedit,
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
DATA  old_disc_fi_flag.  "Changed for FI discipline
DATA  set_disc_fi_flag.
DATA  crc_check_fl.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files LIKE TABLE OF swotobjid.
DATA g_att_files_wa LIKE swotobjid.
DATA  old_userid LIKE zic_prep_rolereq-userid.
DATA  g_val_err.
DATA  g_lines_2 LIKE sy-index.
DATA  old_ok_code_crc LIKE old_ok_code.
DATA  g_crc_fl.
DATA  g_ccode LIKE zic_prep_rolereq-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(90).

****************************
DATA : g_field_tab LIKE TABLE OF dfies.
DATA : g_field_wa  LIKE dfies.
DATA  approver_flag.
DATA  g_ccode_crossco LIKE zic_prep_rolereq-ccode.

*&spwizard: type for the data of tablecontrol 'TABLCTRL110'
TYPES: BEGIN OF t_tablctrl110,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         plant        LIKE zic_prep_rolerei-plant,
         grp          LIKE zic_prep_rolerei-grp,
         sloc         LIKE zic_prep_rolerei-sloc,
         receipt_loc  LIKE zic_prep_rolerei-receipt_loc,
         approver     LIKE zic_prep_rolerei-approver,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         rej_id       LIKE zic_prep_rolerei-rej_id,
         rej_date     LIKE zic_prep_rolerei-rej_date,
         rej_fl_save  LIKE zic_prep_rolerei-rej_fl_save,
         shop_no      LIKE zic_prep_rolerei-shop_no,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         gl_account   LIKE skb1-saknr,
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
         docno            LIKE zic_prep_rolerei-docno,
         moduleid         LIKE zic_prep_rolerei-moduleid,
         srno             LIKE zic_prep_rolerei-srno,
         role_name        LIKE zic_prep_rolerei-role_name,
         plant            LIKE zic_prep_rolerei-plant,
         grp              LIKE zic_prep_rolerei-grp,
         sloc             LIKE zic_prep_rolerei-sloc,
         receipt_loc      LIKE zic_prep_rolerei-receipt_loc,
         approver         LIKE zic_prep_rolerei-approver,
         status           LIKE zic_prep_rolerei-status,
         role_request     LIKE zic_prep_rolerei-role_request,
         rej_fl           LIKE zic_prep_rolerei-rej_fl,
         rej_id           LIKE zic_prep_rolerei-rej_id,
         rej_date         LIKE zic_prep_rolerei-rej_date,
         rej_fl_save      LIKE zic_prep_rolerei-rej_fl_save,
         shop_no          LIKE zic_prep_rolerei-shop_no,
         role_desc        LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
         gl_account       LIKE zic_prep_rolerei-gl_account,
         bussiness_area   LIKE zic_prep_rolerei-bussiness_area,
         fund_ctr_gp      LIKE zic_prep_rolerei-fund_ctr_gp,
         jva_grp          LIKE zic_prep_rolerei-jva_grp,
         sub_module       LIKE zic_prep_rolerei-sub_module,
         role_sensitivity LIKE zic_prep_rolerei-role_sensitivity,
         fr_date_auth     LIKE zic_prep_rolerei-fr_date_auth,
         to_date_auth     LIKE zic_prep_rolerei-to_date_auth,
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
DATA  modulefi_fl.
DATA  moduleid_save LIKE zic_prep_rolerei-moduleid.
DATA  g_mult_module_fl.
DATA : status_desc LIKE zmm_prep_status-status_desc.
DATA : it_module1 LIKE TABLE OF zic_modules.
DATA : wa_module1 LIKE LINE OF it_module1.
DATA  fi_not_ok.
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
    asset  TYPE zic_prep_rolerei-basin,
    a_desc TYPE zchar80,
  END OF asset_ty.

TYPES :
  BEGIN OF basin_ty,
    ccode  TYPE zic_prep_rolereq-ccode,
    basin  TYPE zic_prep_rolerei-basin,
    b_desc TYPE zchar80,
  END OF basin_ty.

DATA   : it_basin TYPE TABLE OF basin_ty WITH HEADER LINE.
DATA : it_asset TYPE TABLE OF asset_ty WITH HEADER LINE.
DATA : it_location TYPE TABLE OF zps_prep_loc WITH HEADER LINE.
DATA : it_project TYPE TABLE OF zps_prep_project WITH HEADER LINE.
DATA : it_service TYPE TABLE OF zps_prep_service WITH HEADER LINE.
DATA  g_curr_line_112 LIKE sy-stepl.

*&spwizard: type for the data of tablecontrol 'TABLCTRL113'
TYPES: BEGIN OF t_tablctrl113,
         docno        LIKE zic_prep_rolerei-docno,
         moduleid     LIKE zic_prep_rolerei-moduleid,
         srno         LIKE zic_prep_rolerei-srno,
         role_name    LIKE zic_prep_rolerei-role_name,
         plant        LIKE zic_prep_rolerei-plant,
         sloc         LIKE zic_prep_rolerei-sloc,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         res          LIKE zic_prep_rolerei-res,
         ctf_sloc     LIKE zic_prep_rolerei-ctf_sloc,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
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
         plant        LIKE zic_prep_rolerei-plant,
         status       LIKE zic_prep_rolerei-status,
         role_request LIKE zic_prep_rolerei-role_request,
         rej_fl       LIKE zic_prep_rolerei-rej_fl,
         sale_org     LIKE zic_prep_rolerei-sale_org,
         div          LIKE zic_prep_rolerei-div,
         ship_point   LIKE zic_prep_rolerei-ship_point,
         role_desc    LIKE zmm_prep_roledes-brief_desc,
         flag,       "flag for mark column
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


*&spwizard: lines of tablecontrol 'TABLCTRL114'
DATA:     g_tablctrl114_lines  LIKE sy-loopc.
DATA  g_curr_line_114 LIKE sy-stepl.

DATA : ist_dyfields   LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA  g_user_assign TYPE c.

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
        END OF out_roles,

        BEGIN OF out_roles1,
          userid           LIKE sy-uname,
          role_type        LIKE zic_prep_rolerei-role_name,
          role_name        LIKE vagratts-agr_name,
          fr_date_auth(10),
          to_date_auth(10),
        END OF out_roles1,


        BEGIN OF userids,
          cpfno LIKE sy-uname,
        END OF userids.

TYPES : BEGIN OF del_roles,
          userid    LIKE sy-uname,
          role_name LIKE vagratts-agr_name,
        END OF del_roles.

DATA : it_roles TYPE STANDARD TABLE OF in_roles.
DATA : l_old_ok_code.
DATA  g_reset_change.
DATA  ok_code_assign TYPE string.
DATA : it_roles0 TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1 TYPE STANDARD TABLE OF out_roles.
DATA : it_roles2 TYPE STANDARD TABLE OF out_roles1 WITH HEADER LINE.
DATA : it_agr_users TYPE STANDARD TABLE OF agr_users .
DATA : it_role_del_data TYPE TABLE OF del_roles.
DATA : wa_role_del_data TYPE del_roles.
DATA : wa_agr_users LIKE agr_users.
DATA  wa_roles LIKE LINE OF it_roles.
DATA : wa_rolesz TYPE t_tablctrl111.
DATA : wa_roles1 TYPE out_roles.
DATA : wa_roles2 TYPE out_roles1.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA  gl_ans.
DATA  : flag.
DATA : p1_file LIKE rlgrap-filename VALUE 'C:\role_upload.txt'.
DATA  zrolereqno LIKE zmm_prep_rolereq-docno.
DATA  g_role_flag.
DATA  g_list_proc_flag.
DATA  g_userid LIKE wa_roles1-userid.
DATA : flag_start, l_color(2) TYPE i.
DATA  l_initial.
DATA : g_lines1 LIKE sy-index.
DATA  disp_flag.
DATA  g_clines LIKE sy-index.
DATA  corr_code LIKE sy-ucomm.
DATA  g_exit_value.
DATA  g_ans_mail.
DATA  status_process.
DATA  status_choice.
DATA  g_status_update_flag.
DATA  g_status_update_rolereq.
DATA  g_request_close_flag.
DATA  g_request_close_flag_p.
DATA  g_request_close_flag_h.
DATA  g_request_close_flag_r.
DATA  get_parm_flag.
DATA  okcode_dblclk LIKE sy-ucomm.
DATA  g_curfield(60).
DATA  g_i80.
DATA  g_rej_fl.

***&spwizard: data declaration for tablecontrol 'TABLECTRL_215'
*&spwizard: definition of ddic-table
TABLES:   zic_prep_delrole.

*&spwizard: type for the data of tablecontrol 'TABLECTRL_215'
TYPES: BEGIN OF t_tablectrl_215,
         moduleid     LIKE zic_prep_delrole-moduleid,
         srno         LIKE zic_prep_delrole-srno,
         role_name    LIKE zic_prep_delrole-role_name,
         fr_date_auth LIKE zic_prep_delrole-fr_date_auth,
         to_date_auth LIKE zic_prep_delrole-to_date_auth,
         flag,       "flag for mark column
         role_sel,
       END OF t_tablectrl_215.

TYPES: BEGIN OF t_tablectrl1_215,
         agr_name LIKE agr_users-agr_name,
         from_dat LIKE agr_users-from_dat,
         to_dat   LIKE agr_users-to_dat,
         flag,       "flag for mark column
       END OF t_tablectrl1_215.


*&spwizard: internal table for tablecontrol 'TABLECTRL_215'
DATA:     g_tablectrl_215_itab TYPE t_tablectrl_215 OCCURS 0,
          g_tablectrl_215_wa   TYPE t_tablectrl_215. "work area
DATA:     g_tablectrl_215_copied.           "copy flag

DATA:    g_tablectrl_215_itab1 TYPE t_tablectrl1_215 OCCURS 0,
         g_tablectrl_215_wa1   TYPE t_tablectrl1_215. "work area


*&spwizard: declaration of tablecontrol 'TABLECTRL_215' itself
CONTROLS: tablectrl_215 TYPE TABLEVIEW USING SCREEN 0215.

*&spwizard: lines of tablecontrol 'TABLECTRL_215'
DATA:     g_tablectrl_215_lines  LIKE sy-loopc.
DATA  l_del_request. "Flag to konw if Request Created is  Delete Request

DATA : BEGIN OF wa_zic_prep_delrole.
        INCLUDE STRUCTURE zic_prep_delrole.
DATA : role_sel.
DATA : END OF wa_zic_prep_delrole.
DATA  save_old_ok_code LIKE old_ok_code.
DATA  status_process_flag.




************************* Data declaration : by Bipin Shukla for GRC Risk analysis **************

DATA : wa_grcdata TYPE zic_prep_rolereq.
TYPE-POOLS icon.
DATA gicon(4) TYPE c.
DATA : risk_desc TYPE string.
DATA : gt_icon TYPE TABLE OF zgrc_sod_result,
       wa_icon TYPE zgrc_sod_result.
DATA : gt_icon1 TYPE TABLE OF zgrc_sod_result,
       wa_icon1 TYPE zgrc_sod_result.

DATA : tcode      TYPE sy-ucomm,
       reqnum_ex  TYPE zic_prep_rolereq-docno,
       reqnum_alv TYPE zic_prep_rolereq-docno,
       lv_counter TYPE i VALUE 0,
       grc_flag,
       lv_count   TYPE i,
       lv_rcount  TYPE i,
       lv_risk    TYPE i,
       reqno      TYPE zic_prep_rolereq-docno.

*************************Data declaration for FORM GRC_RISK_ANALYSIS. start ***********

DATA : gt_bucket   TYPE TABLE OF zic_prep_rolerei,
       wa_bucket   TYPE zic_prep_rolerei,
       gt_bucket1  TYPE zgrc_fi_ttyp,
       wa_bucket1  TYPE zgrc_fi_tabc,
       gt_eroles   TYPE ztb_final1,
       wa_eroles   TYPE ztb_final,
       gt_eroles1  TYPE ztb_final1,
       wa_eroles1  TYPE ztb_final,
       gt_output   TYPE grac_t_sod_prm_viol_det,
       wa_output   TYPE grac_s_sod_prm_viol_det,
       gt_rdesc    TYPE zecc_risk_desc_tt,
       wa_rdesc    TYPE zecc_risk_desc,
       gt_violdtl  TYPE grac_t_sod_prm_viol_det,
       wa_violdtl  TYPE grac_s_sod_prm_viol_det,
       gt_viol_dtl TYPE TABLE OF zgrc_viol_dtl,
       wa_viol_dtl TYPE zgrc_viol_dtl.


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
       lv_ind  TYPE i.

DATA : v_snum1 TYPE n LENGTH 10.
DATA : lv_snum1 TYPE n LENGTH 10.

DATA : lv_lines TYPE sy-dbcnt.
DATA : gd_percent TYPE i.
DATA : lv_indx1 TYPE sy-tabix.

DATA : check_okcode TYPE c.

DATA : it_tvarv TYPE TABLE OF tvarvc,
       wa_tvarv TYPE tvarvc.

DATA : lv_grccall TYPE c.
DATA : lv_subrc TYPE sy-subrc.


DATA : gt_risk TYPE TABLE OF zgrc_sod_result,
       wa_risk TYPE zgrc_sod_result.

DATA : gt_text TYPE TABLE OF lvc_txt132,
       gw_text TYPE  lvc_txt132.

DATA : rej_ex     TYPE  zic_prep_rolerei-rej_fl,
       status_ex  TYPE zic_prep_rolereq-status,
       okcode_ex  TYPE sy-ucomm,
       oc_9001_rj TYPE sy-ucomm,
       oc_9002_rj TYPE sy-ucomm,
       oc_9003_rj TYPE sy-ucomm,
       oc_9004_rj TYPE sy-ucomm,
       crt_name   TYPE zic_prep_rolereq-useridcr,
       tcode_rj   TYPE sy-tcode,
       okcode_rj  TYPE sy-ucomm.

DATA : gt_bucket_ex TYPE TABLE OF zic_prep_rolerei,
       wa_bucket_ex TYPE zic_prep_rolerei.


DATA : zice_comment TYPE zice_arms_comment,
       zice_ex      TYPE zice_arms_comment,
       lv_expo      TYPE c.


DATA : gt_log TYPE TABLE OF zgrc_log,
       wa_log TYPE zgrc_log.


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

DATA  : lv_rfc TYPE rfcdest.
DATA  : lv_rfc_1 TYPE rfcdest.
DATA  : lv_rfc_2 TYPE rfcdest.

DATA : gt_fi_usr TYPE TABLE OF agr_users,
       wa_fi_usr TYPE          agr_users.
************************data declaration to sent mail at first level approvel : by Bipin Shukla


*************************Data declaration for FORM GRC_RISK_ANALYSIS. end *************

************************* Data declaration : by Bipin Shukla for GRC Risk analysis *******************

DATA: zget_number(8) TYPE n,
      v_message_as   TYPE c,
      zitem_no       LIKE zauth_item-item_no,
      v_message_unas TYPE  char120.
DATA: v_moduleid(3),
      v_remarks_head TYPE zauth_head-remarks,
      zuserid        LIKE zic_prep_rolereq-useridcr,
      zapprover      LIKE zic_prep_rolereq-useridap.
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
DATA: g_role_itab   TYPE t_role OCCURS 0 WITH HEADER LINE,
      s_itab        type t_role.

DATA: it_agr TYPE STANDARD TABLE OF bapiagr,
      wa_agr TYPE bapiagr.
