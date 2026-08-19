*--- MAIN PROGRAM: MZROLEAUTHTOP ---*
*----------------------------------------------------------------------*
***INCLUDE MZUSRROLEREQTOP .
*----------------------------------------------------------------------*

*-----------------------------------------------------------------------
*                                TABLES
*-----------------------------------------------------------------------

tables : zauth_user_role,
         tstct,
         agr_users,
         agr_define,
         usr02,
         usr21,
         adrp,
         zauth_head,
         zauth_item,
         zroledel_head,
         zroledel_item.
*-----------------------------------------------------------------------
*                                Variables
*-----------------------------------------------------------------------

data: g_userid    like zauth_user_role-my_cpf_no,
      g_subuserid like zauth_user_role-my_cpf_no,
      g_uname(50) type c,
      g_subuname(50) type c,
      g_sdate     like zauth_user_role-from_dat,
      g_edate     like zauth_user_role-to_dat,
      g_reason    like zauth_user_role-reason,
      g_perno like usr21-persnumber,
      g_role_text like agr_texts-text,
      g_reqno like zauth_user_role-req_no,
      g_del_reqno    like zroledel_head-roledel_req_no,
      g_ref_reqno    like zauth_user_role-req_no,
      g_delegated_by like zauth_user_role-my_cpf_no,
      g_delegated_to like zauth_user_role-sub_cpf_no,
      g_from_date    like zauth_user_role-from_dat,
      g_to_date      like zauth_user_role-to_dat,
      g_reqno_ref like zauth_user_role-req_no.

data :g_myuserid    like zauth_user_role-my_cpf_no,
      g_mysubuserid like zauth_user_role-my_cpf_no,
      g_myuname(50) type c,
      g_mysubuname(50) type c,
      g_mysdate     like zauth_user_role-from_dat,
      g_myedate     like zauth_user_role-to_dat,
      g_action type c,
      g_save_flag,
      g_primod like zauth_head-primod,
      g_str  type string,
      g_disptext type string.
data: g_days type i,
      g_status(10) type c,
      g_oo_no(100) type c.


data: wa_roledel_head   type  zroledel_head,
      wa_roledel_item   type  zroledel_item.

ranges r_date for zauth_user_role-from_dat.

data : ok_code like sy-ucomm,
       ok_200 like sy-ucomm,
       ok_300 like sy-ucomm,

       save_code like sy-ucomm.

*-----------------------------------------------------------------------
*                                Types
*-----------------------------------------------------------------------

types : begin of ty_fcode,
        fcode like rsmpe-func,
        end of ty_fcode.

types : begin of ty_auth1,
        req_no      like zauth_user_role-req_no,
        itemno     like zauth_user_role-itemno,
        my_cpf_no  like zauth_user_role-my_cpf_no,
        sub_cpf_no like zauth_user_role-sub_cpf_no,
        agr_name   like agr_users-agr_name,
        text       like agr_texts-text,
        from_dat   like zauth_user_role-from_dat,
        to_dat     like zauth_user_role-to_dat,
        reason     like zauth_user_role-reason,
        oonumber   like zauth_head-oonumber,

        ernam      like zauth_user_role-ernam,
        erfdt      like zauth_user_role-erfdt,
        timestamp  like oifbbp1-ftmstm,
        mark       type c,
        loekz      type c,
        end of ty_auth1.

types : begin of ty_auth2,
*        my_cpf_no like  zauth_user_role-my_cpf_no,
*        sub_cpf_no like  zauth_user_role-sub_cpf_no,
        agr_name like agr_users-agr_name,
        text like agr_texts-text,
        from_dat like zauth_user_role-from_dat,
        to_dat like zauth_user_role-to_dat,
        loekz type c,
        end of ty_auth2.

*types : begin of ty_assign,
*        agr_name   LIKE agr_users-agr_name,
*        text       LIKE agr_texts-text,
*        from_dat   LIKE zauth_user_role-from_dat,
*        to_dat     LIKE zauth_user_role-to_dat,
*        end of ty_assign.

*-----------------------------------------------------------------------
*                    Internal Tables
*-----------------------------------------------------------------------

data : ist_auth1    type standard table of ty_auth1 with header line,
       ist_auth_del type standard table of ty_auth1 with header line,
       ist_auth1_copy type standard table of ty_auth1 with header line,
       ist_roledel_item  type standard table of zroledel_item
                                                       with header line,

       ist_fcode type standard table of ty_fcode with
       non-unique default key initial size 10,

       ist_auth2_cpfno type standard table of ty_auth2 with header line,
       ist_auth2_subcpfno type standard table of ty_auth2 with header
       line.

*       ist_assign type standard table of ty_assign with header line.

data: ist_zauthitem type standard table of zauth_item with header line.

data:  ist_refer like sval occurs 0 with header line.
*-----------------------------------------------------------------------
*                    Structure
*-----------------------------------------------------------------------

data : wa_fcode type ty_fcode.

data : ist_auth_st type ty_auth1.
*      ist_ass_st type ty_assign.

* Menu Painter - Input/Output Fields.
types: begin of tab_type,
        fcode like rsmpe-func,
       end of tab_type.

data: tab type standard table of tab_type with
          non-unique default key initial size 10,
      wa_tab type tab_type.

** Globle OK_CODE fields.
data: okcode_9000 like sy-ucomm.

*-----------------------------------------------------------------------
*                    Table Control
*-----------------------------------------------------------------------

controls tctrl_100 type tableview using screen 100.
controls tctrl_110 type tableview using screen 110.
controls tctrl_300 type tableview using screen 300.

*Begin of <RD1K963159>.
data : g_att_files like table of swotobjid.
data : g_att_files_wa like swotobjid.
data : l_val like zauth_user_role-req_no.
DATA : ALLOWED_CHAR(10) VALUE '0123456789',
       lv_userid like zauth_user_role-my_cpf_no,
       lv_flag(1) TYPE c." for setting value in screen.
*End of <RD1K963159>.

data : ok_code_9001 type sy-ucomm.
data : ok_code_9002 type sy-ucomm.
