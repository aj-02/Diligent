*--- MAIN PROGRAM: MZMMUOMTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMUOMTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

program  sapmzmmuom message-id zmm.

tables:  mara, t001w, t006 .

types: begin of t_tc_81,
         matnr like ZMM_MECS-MATNR,
         maktx like makt-maktx,
         meins like mara-meins,
*         meinh LIKE SMEINH-MEINH,
*         umrez LIKE SMEINH-UMREZ,
         ersda like zmm_mecs-ersda,
         ernam like zmm_mecs-ernam,
         laeda like zmm_mecs-laeda,
         aenam like zmm_mecs-aenam,
         uom_str1  type zmm_uom_d-uom_str1 ,
         uom_str2  type zmm_uom_d-uom_str2 ,

*         fipos LIKE zmm_mecs-fipos,
          flag,
       end of t_tc_81.

controls: tc_81 type tableview using screen 9081.

data:     g_tc_81_itab   type t_tc_81 occurs 0,
          g_tc_81_wa     type t_tc_81.

data:     g_tc_81_copied.
data:     g_tc_81_lines    like sy-loopc.
data:     ok_code          like sy-ucomm.

data:     g_ok_80          like sy-ucomm.
data:     g_ok_81          like sy-ucomm.
data:     g_ok_82          like sy-ucomm.

data:     g_lines          like sy-loopc.
data:     g_docno          like zmm_uom_h-docno.
*DATA:     g_text1(132)  type C.
*DATA:     g_text2(132)  type C.
data: htc_cols type cxtab_column.

data: fcode like rsmpe-func.
data: tc_81_line(3) type c.
data: tc_lines like sy-loopc.

data: rc        like inri-returncode,
      number(7) type c.

data: ist_zmm_uom_d type table of zmm_uom_d.
data: wa_zmm_uom_d  type zmm_uom_d.
data: wa_zmm_uom_h  type zmm_uom_h.

data:  ct_sort	type	lvc_t_sort.
data:  it_fieldcat type	lvc_t_fcat.
data:  wa_it type lvc_s_fcat.

data:  it_selected_cols	type	lvc_t_col.
data:  is_layout	       type	lvc_s_layo.
data:  is_selfield	       type	lvc_s_self.
data:  it_groups	       type	lvc_t_sgrp.
data:  ct_filter	       type	lvc_t_filt.

types: begin of tab_type,
        fcode like rsmpe-func,
      end of tab_type.

data: icon  like icons-text.

data: tab type standard table of tab_type with
               non-unique default key initial size 10,
      wa_tab type tab_type.

data : ist_del type table of zmm_uom_d with header line.
data :  l_itab type table of zmm_uom_d with header line..
data : wa_makt like makt.
