*--- MAIN PROGRAM: MZMMTMSTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMPURTDRNUMGENTOP                                         *
*&                                                                     *
*&---------------------------------------------------------------------*
TYPE-POOLS: esp1.                                           "+002

TABLES : zmm_pur_trtyp,
         zmm_pur_tender_d,
         zmm_pur_tender_d_st,
         tstct,
         t024,
         dd07v,
         dfies,
         cdhdr,
        cdpos,ekko.

*Start*****************************************************************

TABLES : zmm_tms,
         zmm_tms_general,
         zmm_tms_tc,
         zmm_tms_tb,
         zmm_tms_pb,
         zmm_tms_epc.

TABLES : zmm_tmst. "Text table - zmm_tmst

CONTROLS : tms_ctrl TYPE TABSTRIP.

CONTROLS : tms_ctrl_tndr TYPE TABLEVIEW USING SCREEN 0300.

CONTROLS : tms_ctrl_gen  TYPE TABLEVIEW USING SCREEN 0400.

CONTROLS : tms_ctrl_tc   TYPE TABLEVIEW USING SCREEN 0500.

CONTROLS : tms_ctrl_tb   TYPE TABLEVIEW USING SCREEN 0600.

CONTROLS : tms_ctrl_pb   TYPE TABLEVIEW USING SCREEN 0700.

CONTROLS : tms_ctrl_epc  TYPE TABLEVIEW USING SCREEN 0800.
*End*******************************************************************
*---------------------------------------------------------------------*
*                Types                                                *
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_tabtype,
        fcode LIKE rsmpe-func,
      END OF ty_tabtype.
TYPES: BEGIN OF ty_ekpo,
        ebeln TYPE ekpo-ebeln,
        aedat TYPE ekpo-aedat,
        banfn TYPE ekpo-banfn,
        anfnr TYPE ekpo-anfnr,
      END OF ty_ekpo.

""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014  FOR  CHECKING ROLES FOR IC MM/L2/L3 , L1
                                                            "RD1K994950
types:begin of ty_agr_users,
    mandt type mandt,
    uname type xubname,
    agr_name type agr_name,
    from_dat type agr_fdate,
    to_dat type agr_tdate,

end of ty_agr_users.

DATA:itab_agr_users type table of ty_agr_users.
"END OF ADDITION BY LIPSY ON 27.10.2014 FOR  CHECKING ROLES FOR IC MM/L2/L3 , L1
                                                            "RD1K994950
""""""""""""""""""""""""""""""""""""


DATA : g_ok_100     LIKE sy-ucomm,
       g_sav_ok_100 LIKE g_ok_100.
DATA : g_action,
       g_option.

DATA l1_date TYPE sy-datum.

DATA : ist_tab TYPE STANDARD TABLE OF ty_tabtype WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
       wa_tab TYPE ty_tabtype.

*Start*****************************************************************
DATA : wa_zmm_tms TYPE zmm_tms.

DATA : BEGIN OF wa_cpa_dtl,
         ename TYPE pa0001-ename,
         desig_text TYPE zdesignation_rev-desig_text,
       END OF wa_cpa_dtl.

DATA : wa_indentor_dtl LIKE wa_cpa_dtl,
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 27.10.2014  FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
       wa_ICMM_dtl like wa_cpa_dtl,
       wa_L1_dtl   like wa_cpa_dtl,
"END OF ADDITION BY LIPSY ON 27.10.2014 FOR  NEW FIELDS IC MM/L2/L3 , L1
                                                            "RD1K994950
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
       wa_tc_mem1      LIKE wa_cpa_dtl,
       wa_tc_mem2      LIKE wa_cpa_dtl,
       wa_tc_mem3      LIKE wa_cpa_dtl,
       wa_tc_mem4      LIKE wa_cpa_dtl,
       wa_tc_mem5      LIKE wa_cpa_dtl,
       wa_tdrsigner    LIKE wa_cpa_dtl.

DATA : wa_tc_mem1_s    LIKE wa_cpa_dtl,
       wa_tc_mem2_s    LIKE wa_cpa_dtl,
       wa_tc_mem3_s    LIKE wa_cpa_dtl,
       wa_tc_mem4_s    LIKE wa_cpa_dtl,
       wa_tc_mem5_s    LIKE wa_cpa_dtl.

*Declartion of structure & internal table for storing pf-status
DATA : BEGIN OF wa_pf_status,
        fcode LIKE rsmpe-func,
      END OF wa_pf_status.

DATA : ist_pf_status LIKE STANDARD TABLE OF wa_pf_status WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

* Declartion of structure & internal table for storing Instructions for
* TMS : Price bid
DATA : ist_zmm_tmst TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst  TYPE zmm_tmst.

* Declartion of structure & internal table for storing Instructions for
* General : Methodology - Specfic
DATA : ist_zmm_tmst_spfc TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst_spfc  TYPE zmm_tmst.

*+001 : Start
* Declartion of structure & internal table for storing Instructions for
* TMS : EPC
DATA : ist_zmm_tmst_epc TYPE TABLE OF zmm_tmst,
       wa_zmm_tmst_epc  TYPE zmm_tmst.
*+001 : End

DATA : BEGIN OF ist_lines OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines.

DATA : BEGIN OF ist_lines_spfc OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines_spfc.

*+001 : Start
DATA : BEGIN OF ist_lines_epc OCCURS 0,
       vdata LIKE pplog-vdata,
       opera(1),
      END OF ist_lines_epc.
*+001 : End

*+002 : Start
DATA : ist_mesg   TYPE esp1_message_tab_type WITH HEADER LINE.
*+002 : End

* Structure : Attachment
DATA : ist_att_files TYPE TABLE OF swotobjid,
       wa_att_files  TYPE swotobjid.

DATA : g_dynnr TYPE sy-dynnr,
       g_tcode TYPE sy-tcode.

DATA : ok_code       TYPE sy-ucomm ,
       save_ok       TYPE sy-ucomm ,
       g_ok_code     TYPE sy-ucomm,
       g_ok_code_300 TYPE sy-ucomm.     "+006

DATA : g_exec(1) VALUE 'X'.

DATA : g_ans(1),
       g_txt(132),
       g_disp(1).

DATA : g_dmode(1),
       g_chg_flg(1),
       g_dmode_spfc(1),
       g_chg_spfc(1).

*+001 : Start
DATA : g_dmode_epc(1),
       g_chg_epc(1).
*+001 : End

DATA : g_ret_1 TYPE sy-subrc,
       g_ret_2 TYPE sy-subrc.

DATA : g_reg  TYPE c VALUE 'X',  "Methodology : Regular
       g_spfc TYPE c.            "Methodology : Specific

DATA : g_tndr_proc(40),
       g_tndr_typ(40).

DATA : g_pbo_bidrs(1). "shortlisted bidders for PBO
*End*******************************************************************

*18.10.2012 : Start
DATA : g_loi_dt1(20),
       g_loi_dt2(20),
       g_loi_dt3(20).

DATA : g_tm TYPE zmm_tms_tc-tc_member1.
*18.10.2012 : End
DATA : it_eban LIKE eban OCCURS 0 ,
       t_cdpos LIKE cdpos OCCURS 0 WITH HEADER LINE,
       tcdhdr  LIKE cdhdr OCCURS 0 WITH HEADER LINE,
       lt_cdshw LIKE cdshw OCCURS 0 WITH HEADER LINE.
DATA : objectid LIKE cdhdr-objectid,
       objectclass LIKE cdhdr-objectclas.

*DATA : g_no_pr TYPE c.                                  "-006
DATA  BEGIN OF it_sval OCCURS 0.
        INCLUDE STRUCTURE sval.
DATA  END   OF it_sval.
DATA :        wrk_retcode.
DATA l_ttext(10).
DATA : g_check(1) VALUE 'X'.
DATA :g_rel_stat TYPE zmm_tms-rel_stat.
DATA : ist_ekpo TYPE TABLE OF ty_ekpo,
       wa_ekpo  TYPE ty_ekpo,
       wa_ekko TYPE ekko.

*+004 : Start
DATA : g_loekz TYPE eban-loekz,
       g_frgkz TYPE eban-frgkz.
*+004 : End

DATA : g_banfn TYPE eban-banfn.                  "+008

DATA : g_chk(1).                                 "+007

DATA : g_pr_rcpt_dt TYPE zmm_tms-pr_rcpt_dt.     "+007



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""ADDED BY LIPSY ON 03.11.2014  FOR total pr value
                                                            "RD1K994950
data : v_pr_val type gswrt,
      ist_eban_all TYPE TABLE OF zmm_pur_tender_d,
      ist_eban type TABLE OF eban,
      ist_eban_t  type TABLE OF eban,
      wa_eban_all LIKE LINE OF  ist_eban_all,
      wa_eban LIKE LINE OF ist_eban,
      wa_eban_t LIKE LINE OF  ist_eban_t.


data : wa_erate  type bapi1093_0.


""""""""""""""""""""""""""""""""""
"comment by lipsy on 27.02.2015 for increasing field length RD1K995870
*data : l_fval type gswrt.             " Total Value of Item
"end of comment by lipsy on 27.02.2015 for increasing field length RD1K995870
""""""""""""""

data : l_rate_type   type bapi1093_1-rate_type, " Exchange Rate Type
       l_from_curr   type bapi1093_1-from_curr, " From Currency
       l_to_curr     type bapi1093_1-to_currncy," To Currency
       l_trans_dt    type bapi1093_2-trans_date," Date
       l_erate       type gswrt.                " Total Value of Item

data : l_rval type p decimals 2. " Rounded Value

data : l_temp  type currency1034,
       l_rlwrt type currency1034,
       v_mes_txt type  char120.






"""end of ADDition  BY LIPSY ON 03.11.2014  FOR  total pr value
                                                            "RD1K994950
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
TYPES : BEGIN OF TY_DATA,
          PERNR     LIKE PA0027-PERNR,
          BEGDA     LIKE PA0001-BEGDA,
          ENDDA     LIKE PA0001-ENDDA,
          NAME      LIKE PA0001-ENAME,
          BUKRS     LIKE PA0001-BUKRS,
          WERKS     LIKE PA0001-WERKS,
          PERSK     LIKE PA0001-PERSK,
          KBU01     LIKE PA0027-KBU01,
          KGB01     LIKE PA0027-KGB01,
          KST01     LIKE PA0027-KST01,
          DESIGNO   LIKE PA9930-DESIGNO,
          R_P_CD    LIKE PA9930-R_P_CD,
          VERSION   LIKE PA9930-VERSION,
          DESIGNATION LIKE ZDESIGNATION_REV-SDESIG_TEXT,
          ADESIGNATION LIKE ZDESIGNATION_REV-ADESIG_TEXT,
          DISC_CD   LIKE ZDESIGNATION_REV-DISC_CD,
          SBMOD     TYPE PA0001-SBMOD,
        END OF TY_DATA.

DATA : IST_DATA TYPE STANDARD  TABLE OF TY_DATA WITH HEADER LINE.
data : wa_data type ty_data.
DATA : L_DATE TYPE DATUM.
data : l_mm,l_fi,l_indentor.
data : l_disc_cd_1 type ty_data-disc_cd,
      l_disc_cd_2 type ty_data-disc_cd,
      l_disc_cd_3 type ty_data-disc_cd,
      l_disc_cd_4 type ty_data-disc_cd,
      l_disc_cd_5 type ty_data-disc_cd,
      l_disc_cd_1s type ty_data-disc_cd,
      l_disc_cd_2s type ty_data-disc_cd,
      l_disc_cd_3s type ty_data-disc_cd,
      l_disc_cd_4s type ty_data-disc_cd,
      l_disc_cd_5s type ty_data-disc_cd.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""added by lipsy on 26.02.2015 for change history of tc members RD1K995870

data:wa_zmm_tms_tco TYPE zmm_tms_tc,
     wa_zmm_tms_tcn TYPE zmm_tms_tc,
     V_REL_OLD TYPE C,
      V_REL_NEW  TYPE C,
     XZMM_TMS LIKE zmm_tms OCCURS 0 WITH HEADER LINE,
      yZMM_TMS LIKE  zmm_tms OCCURS 0 WITH HEADER LINE.

data : l_fval type currency1034.
data: v_initial TYPE c.



"""""""""""""""""end of addition  by lipsy on 26.02.2015 for change history of tc members RD1K995870


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""
"ADDED BY LIPSY ON 9.05.2015 RD1K997136

DATA:WA_TENDER_OLD TYPE ZMM_PUR_TENDER_D,
      WA_TENDER_NEW TYPE ZMM_PUR_TENDER_D.

"END OF ADDITION BY LIPSY ON 9.05.2015 RD1K997136
"""""""""""""""""""""""""""""""""""""
