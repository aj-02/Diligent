*--- MAIN PROGRAM: MZMMSRMCLUPDTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMSRMCLUPDTOP                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Date        Transport     USERID       Description
* 12/09/2008  <RD1K960036>  SAB_PUNIT    1) Declared Screen fields in
*                                           programs to remove screen
*                                           inconsistency errors
************************************************************************
program  sapmzmmsrmclupd               .
tables: zmm_srm_mat_clas,stxh.

data: ok_code like sy-ucomm .
data: begin of wa_tc100 ,
        slno(5)   type n   ,
        werks     type t001w-werks,
        matnr     type mara-matnr ,
        maktx     type makt-maktx ,
        srmclass  type char70  ,
        errtext(60)               ,
        smark                     ,
        dclass                    ,
      end of wa_tc100.

data: ist_tc100 like table of wa_tc100     .
data: wa_100 like wa_tc100.
data: g_uname like sy-uname ,
      g_sydate(10).
data: g_remarks(60) .

*&spwizard: declaration of tablecontrol 'TC100' itself
controls: tc100 type tableview using screen 0100.
data: cols like line of tc100-cols.
*&spwizard: lines of tablecontrol 'TC100'
data:     g_tc100_lines  like sy-loopc.
data: icon  like icons-text.
data  g_reqno(10).
data: ok_code_90 like sy-ucomm.

data: begin of wa_disp,
      slno(4)         ,
      matnr(40)       ,
      srmclass        ,
      reqno(10)       ,
      end of wa_disp.


data: begin of wa_data  ,
      matnr     type mara-matnr ,
      srmclass  type zsrmclass  ,
      end of wa_data.

data:  ist_data like table of wa_data,
       ist_disp like table of wa_disp.
data   g_ans.
data:  g_werks type t001w-werks.
data:  bdcdata like bdcdata    occurs 0 with header line.
data:  messtab like bdcmsgcoll occurs 0 with header line.

types: begin of  ty_tabtype,
          fcode like rsmpe-func,
       end of    ty_tabtype.
data: ist_tab type standard table of ty_tabtype with header line .

data:  ist_msg   type  table of bdcmsgcoll with header line      .
data:  wa_msg type   bdcmsgcoll .
data:  ist_mat_clas  type table of zmm_srm_mat_clas.
data:  wa_mat_clas   type  zmm_srm_mat_clas .
data  ok_code_105 like sy-ucomm.
data: header like  thead .
data: ist_lines type table of  tline.
data: wa_lines type tline  .
data: g_dup.
data:  g_CURSORFIELD(20).
* begin of <RD1K960036>
DATA OK_CODE_1O5 LIKE sy-ucomm.
* end of <RD1K960036>
