*--- MAIN PROGRAM: MZMMPREPROLE3TOP ---*
************************************************************************
*  Date            Transport      USERID        Description
* 06/10/2008      <RD1K960036>    SAB_SUMODH
*
*  1) Length Specification is Not Allowed for TYPE I. (Line 266)
************************************************************************
*&---------------------------------------------------------------------*
*& Include MZMMPREPROLETOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMPREPROLE               .

TABLES : ZMM_PREP_ROLEREQ, ZMM_PREP_ROLEREI, ZMM_PREP_ROLEDES, zusrmst,
lfb1, fmzuob, zmm_prep_rsn, cskt, zmm_prep_rolegrp, zhelp_mmroles,
zmm_prep_role_sl, zhelp_mmroles_rc,ZMM_PREP_REJ_LIS, zmm_prep_rolecrc,
zmm_prep_usrcont,zmm_prep_crcdesg.

Types: Begin of tab_type,
         fcode like RSMPE-FUNC,
       end of tab_type.

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
          sbmod     type pa0001-sbmod,
        END OF ty_data.

Data: it_tab type standard table of tab_type with
      non-unique default key initial size 10,
      wa_tab type tab_type.

data : p1_file LIKE rlgrap-filename value 'C:\role_upload.txt'.

DATA : it_roles TYPE STANDARD TABLE OF in_roles.
DATA : it_roles0 TYPE STANDARD TABLE OF in_roles.
DATA : it_roles1 TYPE STANDARD TABLE OF out_roles.
DATA : it_roles1_addl TYPE STANDARD TABLE OF out_roles.
DATA : it_agr_users type standard table of agr_users .
DATA : it_role_del_data type table of del_roles.
DATA : wa_role_del_data type del_roles.
DATA : wa_agr_users like agr_users.
DATA : wa_roles TYPE in_roles.   " work area

DATA : WA_ROLES1 type out_roles.

DATA : ist_seltab like table of rsparams.
DATA : seltab like rsparams.

DATA : ist_data TYPE STANDARD  TABLE OF ty_data with header line.
DATA : it_m_fistb TYPE STANDARD TABLE OF ty_m_fistb.

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

         ROLE_NAME like ZMM_PREP_ROLEREI-ROLE_NAME,
         DOCNO like ZMM_PREP_ROLEREI-DOCNO,
         ROLE_REQUEST like ZMM_PREP_ROLEREI-ROLE_REQUEST,

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

       end of t_TABCTRL100.

data:     ist_itemtab type standard table of zmm_prep_rolerei.
data:     wa_itemtab like zmm_prep_rolerei.
DATA:     wa_rolesz type t_TABCTRL100.

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
DATA : wa_t024 like t024.
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
DATA : read_flag.
DATA : disp_flag.
DATA : g_lines1 like sy-index.
DATA  ZROLEREQNO like ZMM_PREP_ROLEREq-docno.
DATA  g_ans_mail.
DATA  : Flag.
DATA  gl_ans.
DATA  g_userid like wa_roles1-userid.
" Begin of <RD1K960036>.
*DATA : flag_start, l_color(2) type I.
DATA : flag_start, l_color type I.
" End of <RD1K960036>.
DATA  g_clines like sy-index..
DATA  corr_code like sy-ucomm.
DATA  g_role_flag.
DATA  g_cursor_line like sy-stepl.
DATA  g_curr_line like sy-stepl.
DATA  g_current_line like sy-stepl.
DATA  g_curr_line_100 like sy-stepl.
DATA  dis_flag.
DATA  g_fundc_err_flag.
DATA  l_old_ok_code.
DATA  g_reset_change.
DATA  l_initial.
DATA  g_list_proc_flag.
DATA  g_ctrl_flag.
DATA  grp_flag.
DATA  loc_flag.
DATA  g_rej_fl.
DATA  g_i like sy-index.
DATA  g_reset_fl.
DATA  g_docno like ZMM_PREP_ROLEREQ-docno..
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
DATA  g_text(40).
DATA  g_att_files like table of SWOTOBJID.
data g_att_files_wa like SWOTOBJID.
DATA  wa_dat1(10).
DATA  wa_dat2(10).
DATA  g_exit_value.
***************************************
data : g_field_tab like table of dfies.
data : g_field_wa  like dfies.
DATA  approver_flag.
DATA  g_role_name_prev like ZMM_PREP_ROLEREI-ROLE_NAME.
DATA  okcode_dblclk like sy-ucomm.
DATA  g_curfield(60).
DATA  g_i80.
DATA  status_process.
DATA  status_choice.
DATA  CRC_POS(120) type c.
DATA  it_pos like standard table of zmm_prep_crcdesg with header line.
