*--- MAIN PROGRAM: MZMMPREPROLE1TOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZMM_PREP_ROLEREQ, ZMM_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, usr02, pa0027,t500p,
ZMM_PREP_REJ_LIS, ZMM_PREP_EX_APP, soodk, sood5, ZMM_PREP_ROLECRC,
zmm_prep_sl_excp,zmm_prep_crcdesg.

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
DATA : crc_pos(132).


*&spwizard: type for the data of tablecontrol 'TABCTRL100'
types: begin of t_TABCTRL100,
         DOCNO like ZMM_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZMM_PREP_ROLEREI-ROLE_REQUEST,
         ROLE_NAME like ZMM_PREP_ROLEREI-ROLE_NAME,
         PLANT like ZMM_PREP_ROLEREI-PLANT,
         GRP like ZMM_PREP_ROLEREI-GRP,
         role_desc like zmm_prep_roledes-brief_desc,
         RECEIPT_LOC like zmm_prep_ROLEREI-receipt_loc,
         SLOC like zmm_prep_ROLEREI-sloc,
         flag,       "flag for mark column
         srno like ZMM_PREP_ROLEREI-srno,
         approver like ZMM_PREP_ROLEREI-approver,
         rej_fl like ZMM_PREP_ROLEREI-rej_fl,
         rej_id like ZMM_PREP_ROLEREI-rej_id,
         rej_date like ZMM_PREP_ROLEREI-rej_date,
         rej_fl_save like ZMM_PREP_ROLEREI-rej_fl_save,
         status like ZMM_PREP_ROLEREI-status,
         role_type_ex like zmm_prep_rolerei-role_type_ex,
         crc_pos(132),
       end of t_TABCTRL100.

data: ist_itemtab type standard table of zmm_prep_rolerei.
data: wa_itemtab like zmm_prep_rolerei.

***********************************************************************
data : ist_colsscreen type table of cxtab_column-screen.
data : ist_column type standard table of cxtab_column with non-unique
default key.
***********************************************************************

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
DATA : old_doc_no like ZMM_PREP_ROLEREq-docno.
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
DATA  grp_flag.
DATA  plant_flag.
DATA  loc_flag.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  g_reset_fl.
DATA  g_docno like ZMM_PREP_ROLEREq-docno.
DATA  g_app_rel.
DATA  g_release like ZMM_PREP_ROLEREQ-req_cr_fl.
DATA  g_approve like ZMM_PREP_ROLEREQ-req_app_fl.
DATA  g_approve1 like ZMM_PREP_ROLEREQ-req_app1_fl.
DATA  g_i like sy-index.
DATA  g_tc_lines like sy-index.
DATA  g_comm_fl.
DATA  g_read_fl.
DATA  g_lines_rl like sy-index.
DATA  g_field(40).
DATA  g_e_fl.
DATA  g_role_name_prev like ZMM_PREP_ROLEREI-ROLE_NAME.
DATA  g_role_name_flag.
DATA  g_persa like pa0001-werks.
DATA  g_approve0 like ZMM_PREP_ROLEREQ-req_app1_fl.
DATA  old_disc_mm_flag.
DATA  set_disc_mm_flag.
DATA  CRC_CHECK_FL.
DATA  g_fundc_flag.
DATA  g_text(40).
************************
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  old_userid like ZMM_PREP_ROLEREq-userid.
DATA  g_val_err.
DATA  g_lines_2 like sy-index.
DATA  old_ok_code_crc like old_ok_code.
DATA  g_crc_fl.
DATA  G_CCODE like ZMM_PREP_ROLEREQ-ccode.
DATA  g_approver_level(6).
DATA  g_approve_text(80).

****************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  G_CCODE_CROSSCO like ZMM_PREP_ROLEREQ-CCODE.
DATA  g_error_fundc.
DATA  attach_fl.
DATA  status_ir_fl.
DATA  g_choice_more.
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
