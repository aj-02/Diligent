*--- MAIN PROGRAM: MZMMEMD_ARCHTOP_ARCH ---*
*&---------------------------------------------------------------------*
*& Include MZMMEMDTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
PROGRAM sapmzmmemd  .
TABLES: zmm_emdhdr    ,
        zmm_emddtl    ,
        zmm_emdref    ,
        zmm_emdrscode ,
        cdpos ,
        cdhdr ,
        t001  , "Company Codes
        lfb1  .
CONTROLS : tc_105  TYPE TABLEVIEW USING SCREEN '0105',
           tc_120  TYPE TABLEVIEW USING SCREEN '0120',
           tc_135  TYPE TABLEVIEW USING SCREEN '0135',
           tc_145  TYPE TABLEVIEW USING SCREEN '0145',
           tc_155  TYPE TABLEVIEW USING SCREEN '0155'.
CONTROLS : ts_115  TYPE TABSTRIP .
DATA: ok_code      LIKE sy-ucomm ,
      prev_okcode  LIKE sy-ucomm ,
      set_okcode   LIKE sy-ucomm ,
      tc_col       LIKE LINE OF tc_105-cols  .
*&-------------------------------------------------------------------
*  Type Pool
*&-------------------------------------------------------------------
TYPE-POOLS vrm.
TYPES: BEGIN OF tab_type,
        fcode LIKE rsmpe-func,
      END OF tab_type.
*&-------------------------------------------------------------------

TYPES : BEGIN OF ty_ekko ,
        ebeln     LIKE ekko-ebeln ,
        ekgrp     LIKE ekko-ekgrp ,
        submi     LIKE ekko-submi ,
        lifnr     LIKE ekko-lifnr ,
       END OF    ty_ekko.
TYPES: BEGIN OF  ty_tabtype,
          fcode LIKE rsmpe-func,
       END OF    ty_tabtype.

*types: begin of ty_emddtl,
*       trans     type zmm_emdhdr-trans    ,
*       status    type zmm_emddtl-status   ,
*       ri_stat   type zmm_emddtl-ri_stat  ,                 "+003
*       ri_reqno  type zmm_emddtl-ri_reqno ,                 "+003
*       stat_desc(30)                      ,
*       docno     type zmm_emddtl-docno    ,
*       ebeln     type zmm_emddtl-ebeln    ,
*       item_no   type zmm_emddtl-item_no  ,
*       inst_type type zmm_emddtl-inst_type,
*       instno    type zmm_emddtl-instno   ,
*       instdt    type zmm_emddtl-instdt   ,
*       inst_vdt  type zmm_emddtl-inst_vdt ,
*       bank      type zmm_emddtl-bank     ,
*       branch    type zmm_emddtl-branch   ,
*       amount    type zmm_emddtl-amount   ,
*       currency  type zmm_emddtl-currency ,
*       addr1     type zmm_emddtl-addr1    ,
*       addr2     type zmm_emddtl-addr2    ,
*       rscode    type zmm_emddtl-rscode   ,
*       remark    type zmm_emddtl-remark   ,
*       sel                                ,
*       check                              ,
*      end of  ty_emddtl.

DATA : ty_emddtl TYPE zmm_emd_status.

TYPES:  BEGIN OF ty_emdref,
  itemno   TYPE zmm_emdref-itemno   ,
  trans    TYPE zmm_emdref-trans    ,
  refdoc   TYPE zmm_emdref-refdoc   ,
  docno    TYPE zmm_emdref-docno    ,
  ebeln    TYPE zmm_emdref-ebeln    ,
  status   TYPE zmm_emdref-status   ,
  stat_desc(30)                     ,
  amount   TYPE zmm_emdref-amount   ,
  currency TYPE zmm_emdref-currency ,
  rscode   TYPE zmm_emdref-rscode   ,
  remark   TYPE zmm_emdref-remark   ,
END OF ty_emdref.

DATA: g_task_cd    TYPE vrm_id,
      g_task_list  TYPE vrm_values,
      g_task_value LIKE LINE OF g_task_list.
*&-------------------------------------------------------------------
*                 GLOBAL Variable Declaration                         *
*&--------------------------------------------------------------------&*
DATA:  g_action(40)      ,
       g_vcode  LIKE ekko-submi ,
       g_tendno LIKE ekko-lifnr ,
       g_vname  LIKE lfa1-name1 ,
       g_ekgrp  LIKE ekko-ekgrp .

DATA: g_okhdr  ,           "To check Header Info. Entered
      g_line  TYPE i,
      g_save_h      ,        "To Check Header Data insert
      g_save_i      ,        "To Check Item   Data insert
      g_amount TYPE zmm_emdhdr-amount  ,
      g_balamt TYPE zmm_emdhdr-amount  .

DATA: g_docno TYPE xblnr  , "Document no at Header Level
      g_idocno  TYPE zmm_emdhdr-docno ,
      g_ans ,
      g_titel(30)        ,
      g_sc_ans           ,  "For Save Changes
      g_dansw            ,  "For Delete Doc.
      g_status(50)       ,  "To display Doc. Status in Screen 105.
      g_hstatus(50)      , "To display Doc. Status in Screen 105.
      g_reset            ,  "Flag for Reset Document Status
      g_error            ,
      g_reset_status     .
DATA: g_ransw     ,
      g_ref       ,
      g_rfqpo(20) ,
      g_text(35)  .

DATA: g_rfc ,      " Flag for Popup conf. Screen '0110'.
      g_doccat(11) ,
      g_rfc_chk        ."Flag for Refund/Forfeit/EMD-SD Conv.
DATA: g_tot_ref TYPE zmm_emdref-amount. "Total refund amount in refund
"table
DATA : g_crea_by    LIKE  sy-uname ,
       g_crea_on    LIKE  sy-datum ,
       g_chan_by    LIKE  sy-uname ,
       g_chan_on    LIKE  sy-datum ,
       g_stat       LIKE  zmm_emdhdr-status ,
       g_h_status   LIKE  zmm_emdhdr-status .
DATA:  g_amt        TYPE zmm_emdhdr-amount ,
       g_lines      TYPE sy-tabix  ,
       g_dynnr      LIKE sy-dynnr VALUE '0130',
       g_docstat ,     "Global Document status
       g_locname     LIKE  zmm_emdloc-locname ,
       g_ans_ad                               ,
       g_itemno      LIKE zmm_emddtl-item_no  ,
       g_ebeln       LIKE ekko-ebeln   ,
       g_tfxm                          .
*&--------------------------------------------------------------------&*
*                 Work Area Declaration                                *
*&--------------------------------------------------------------------&*
DATA: wa_tab  TYPE ty_tabtype,
      wa_ekko TYPE ekko      ,
      wa_lfa1 TYPE lfa1.

DATA : wa_emdhdr      TYPE zmm_emdhdr ,
       wa_emddtl      TYPE  zmm_emd_status ,
       wa_emddtl01    TYPE zmm_emddtl.

DATA: wa_tc105        TYPE  zmm_emd_status ,
      wa_tc135        TYPE  zmm_emd_status ,
      wa_tc145        TYPE  zmm_emd_status ,
      wa_tc155        TYPE  zmm_emd_status.

DATA: wa_emdref       TYPE  zmm_emdref,
      wa_emdref_01    TYPE  ty_emdref ,
      wa_emdref_02    TYPE  ty_emdref .

* Begin of <RD1K963111>
DATA: lt_emdref TYPE TABLE OF zmm_emdref.
DATA: lt_emddtl TYPE TABLE OF zmm_emddtl,
      wa_emddtl1 TYPE zmm_emddtl.
* End of <RD1K963111>

DATA: wa_emdhdr_t02   LIKE zmm_emdhdr  ,
      wa_emdref_t01   TYPE  ty_emdref .

*&--------------------------------------------------------------------&*
*                Internal Table Declration                             *
*&--------------------------------------------------------------------&*

DATA:  ist_ekko TYPE TABLE OF ty_ekko ,
       ist_ret_tab        TYPE TABLE  OF ddshretval WITH HEADER LINE,
       ist_field_tab      TYPE TABLE OF dfies WITH  HEADER LINE     ,
       ist_tab TYPE STANDARD TABLE OF ty_tabtype WITH HEADER LINE ,
       ist_tabnew TYPE STANDARD TABLE OF ty_tabtype WITH HEADER LINE . .

DATA: ist_emddtl     LIKE TABLE OF   wa_emddtl  ,
      ist_emddtl01   LIKE TABLE OF   zmm_emddtl ,
      ist_emdhdr     TYPE TABLE OF   zmm_emdhdr ,
      ist_del_emddtl LIKE TABLE OF  wa_emddtl ,
      ist_dtl TYPE STANDARD TABLE OF zmm_emddtl WITH HEADER LINE .

DATA: ist_emddtl_t01 TYPE TABLE OF  zmm_emd_status  ,
      ist_emdref     TYPE TABLE OF  zmm_emdref  .

DATA: ist_emdref_01  LIKE TABLE OF   wa_emdref_01 .
DATA  ist_dd07v      TYPE TABLE OF dd07v         .

* Internal table for change history
DATA :   ist_scrdtl TYPE TABLE OF  zmm_emd_status WITH HEADER LINE ,
         ist_chngind TYPE TABLE OF cdtxt WITH HEADER LINE ,
         ist_nemddtl LIKE zmm_emddtl ,
         ist_oemddtl LIKE zmm_emddtl .
RANGES : r_insttype FOR zmm_emddtl-inst_type .
*&--------------------------------------------------------------------&*
*SRM Changes Addtional Variables.
DATA  g_ttype(3).
*&--------------------------------------------------------------------&*
DATA  g_reqtext(20).
DATA  g_reqno TYPE zmm_emddtl-ri_reqno.
DATA  g_bstyp TYPE zmm_emdhdr-bstyp .
DATA  g_firet.
DATA  g_mmret.
DATA: l_result.

*** SRM E-Bid & Vendor validation
* Begin of <RD1K963111>
DATA zallow TYPE c.
* End of <RD1K963111>

* Changing the Bidder Tender Fee Exemption Program - Manikandan.
DATA lv_srm_update_status TYPE char1.

* Changing the Document Deletion for Tender & ETenders - Manikandan
DATA l_logsys(32) TYPE c.

DATA : g_pmc(1).                                      "+007

********************************Archived Retrival Declarations**********************************
 TYPES : BEGIN OF stype_aind_str1,
         archindex           LIKE  aind_str1-archindex,
         itype               LIKE  aind_str1-itype,
         skey                LIKE  aind_str1-skey,
       END OF stype_aind_str1,
       stab_aind_str1        TYPE STANDARD TABLE OF stype_aind_str1 WITH DEFAULT KEY.

DATA : g_s_aind_str1_ais     TYPE  stype_aind_str1,
       g_t_aind_str1_ais     TYPE  stab_aind_str1.

TYPES: BEGIN OF stype_fields,
        fieldname            TYPE  aind_str3-fieldname,
      END OF   stype_fields,
      stab_fields            TYPE STANDARD TABLE OF stype_fields WITH DEFAULT KEY.

DATA : g_s_all_fields        TYPE  stype_fields,
       g_t_all_fields        TYPE  stab_fields.
TYPES : BEGIN OF ty_frange,
          fieldname          TYPE  fieldname,
          selopt_t           TYPE STANDARD TABLE OF rsdsselopt WITH DEFAULT KEY,
        END OF ty_frange.

DATA : g_s_selopt            TYPE  rsdsselopt,
       g_s_frange            TYPE  ty_frange,
       g_t_frange            TYPE  TABLE OF  ty_frange.
TYPES: BEGIN OF stype_as_key,
         archivekey          LIKE  arcid_vbrk-archivekey,
         archiveofs          LIKE  arcid_vbrk-offst,
       END OF stype_as_key,
       stab_as_key           TYPE STANDARD TABLE OF stype_as_key WITH DEFAULT KEY.
DATA : l_t_as_key            TYPE  stab_as_key,
       g_s_as_key            TYPE  stype_as_key .

DATA:  l_handle              LIKE sy-tabix.
DATA:  ct_ekko               TYPE STANDARD TABLE OF ekko.
DATA : it_ekko_arch          TYPE TABLE OF ekko ,
       wa_ekko_arch          like LINE OF it_ekko_arch ,
       g_lifnr_arch          type ekko-lifnr ,
       g_aedat_arch          type ekko-aedat ,
       g_reswk_arch          type ekko-reswk.
* data : p_arch.
********************************Archived Retrival Declarations**********************************
