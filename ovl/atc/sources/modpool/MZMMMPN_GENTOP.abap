*--- MAIN PROGRAM: MZMMMPN_GENTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMMPN_GENTOP                                              *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMMPN_GEN     .

*include bdcrecx1.

type-pools:tumls.

tables:
   zmm_mpn,
   merrdat,
   BGR00,
   BMM00,
   BMMH1.

types: begin of t_TC_REQUEST,
         DOCNO like ZMM_MPN-DOCNO,
         BUKRS like ZMM_MPN-BUKRS,
         ERSDA like ZMM_MPN-ERSDA,
         ERNAM like ZMM_MPN-ERNAM,
         flag,       "flag for mark column
       end of t_TC_REQUEST.

data:     g_TC_REQUEST_itab   type t_TC_REQUEST occurs 0,
          g_TC_REQUEST_wa     type t_TC_REQUEST. "work area
data:     g_TC_REQUEST_copied.           "copy flag

controls: TC_REQUEST type tableview using screen 9000.

data:     g_TC_REQUEST_lines  like sy-loopc.

data:     OK_CODE like sy-ucomm.

data :    g_req_type(1).

CONSTANTS: BEGIN OF C_TS_REQUEST,
             TAB1 LIKE SY-UCOMM VALUE 'TS_REQUEST_FC1',
             TAB2 LIKE SY-UCOMM VALUE 'TS_REQUEST_FC2',
             TAB3 LIKE SY-UCOMM VALUE 'TS_REQUEST_FC3',
           END OF C_TS_REQUEST.

CONTROLS:  TS_REQUEST TYPE TABSTRIP.
DATA:      BEGIN OF G_TS_REQUEST,
             SUBSCREEN   LIKE SY-DYNNR,
             PROG        LIKE SY-REPID VALUE 'SAPMZMMMPN_GEN',
             PRESSED_TAB LIKE SY-UCOMM VALUE C_TS_REQUEST-TAB1,
           END OF G_TS_REQUEST.

types: begin of t_TC_DETAILS,
         DOCNO like ZMM_MPN-DOCNO,
         ERNAM like ZMM_MPN-ERNAM,
         MATNR like ZMM_MPN-MATNR,
         MFRNR like ZMM_MPN-MFRNR,
         MFRPN like ZMM_MPN-MFRPN,
         flag,       "flag for mark column
       end of t_TC_DETAILS.

types: begin of ty_mpncode,
         matnr like mara-matnr,
         mfrnr like mara-mfrnr,
         mfrpn like mara-mfrpn,
         bmatn like mara-bmatn,
       end of ty_mpncode.

data:     g_TC_DETAILS_itab   type t_TC_DETAILS occurs 0,
          g_TC_DETAILS_wa     type t_TC_DETAILS. "work area
data:     g_TC_DETAILS_copied.           "copy flag

data :   ist_bmatn type standard table of ty_mpncode.
data :   wa_bmatn type ty_mpncode.

controls: TC_DETAILS type tableview using screen 9001.

data:     g_TC_DETAILS_lines  like sy-loopc.

types: begin of ty_log,
          DOCNO like ZMM_MPN-DOCNO,
          ERNAM like ZMM_MPN-ERNAM,
          MATNR like MERRDAT-MATNR,
          MSGTY like MERRDAT-MSGTY,
          MSGNO like MERRDAT-MSGNO,
          MSGV1(255),          " like MERRDAT-MSGV1,
       end of ty_log.

DATA:  ist_log type ty_log occurs 0.
DATA:  wa_log type ty_log.
data : ist_list like standard table of ABAPLIST.
DATA:  ist_merrdat type merrdat occurs 0.
DATA:  wa_merrdat type merrdat.
DATA:  ist_lsmw_log(255) occurs 0.
DATA:  wa_lsmw_log(255).

controls: TC_LOG type tableview using screen 9002.

data: g_tc_log_lines like sy-loopc.
DATA : g_rec_found(4) TYPE n.

DATA :BEGIN OF ist_mara OCCURS 0,
        bmatn like mara-bmatn,
      END OF ist_mara.
DATA :wa_mara like mara-bmatn.
*------DATA DECLARATION FOR LSMW ----------------------------*
DATA : begin of wa_mpn,
       matkl(9),
       int_mat(9),
       mfrpn(40),
       mfrnr(10),
       end of wa_mpn.

data:
  init_BGR00 like BGR00,
  init_BMM00 like BMM00,
  init_BMMH1 like BMMH1.

*----- buffer to hold file data -----------------------------*
DATA:
  BEGIN OF gt_buffer OCCURS 0,
    record TYPE tumls_segment,
    data(7960) TYPE c,
  END OF gt_buffer.

* Fields that are made available to the user:
DATA:
  g_project TYPE tumls_project Value 'ZMM_ALL_PL',
  g_subproj TYPE tumls_subproj value 'ZMM_ALL',
  g_object TYPE tumls_objectnew value 'ZMM_MPN_CR',
  g_record TYPE tumls_segment,         " name of current record
  g_cnt_records_transferred TYPE i,
  g_cnt_transactions_transferred TYPE i,
  g_dsn_out TYPE tumls_filename,
  g_userid LIKE sy-uname,
  g_groupname(12),
  g_nodata.

DATA:
  g_return   LIKE sy-subrc,
  g_lockuser LIKE sy-uname.

DATA:
  g_skip_record,
  g_transfer_record,
  g_skip_transaction,
  g_transfer_transaction.

CONSTANTS:
  YES VALUE 'X',
  NO VALUE ' '.

*To send mail

data: ist_objcont like solisti1 occurs 5 with header line.

data: ist_reclist like somlreci1 occurs 5 with header line.

data: wa_doc_chng like sodocchgi1.

data: g_entries like sy-tabix.

data: g_name(15).


*Submit report as job(i.e. in background)
data: g_jobname like tbtcjob-jobname value
                             'CHANGE PART NUMBER'.
data: g_jobcount like tbtcjob-jobcount,
      g_host like msxxlist-host.
data: begin of wa_starttime.
        include structure tbtcstrt.
data: end of wa_starttime.
data: g_starttimeimmediate like btch0000-char1.

data: g_ok_2000 like sy-ucomm.
data: g_ok_9000 like sy-ucomm.
*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   IST_BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.

tables:   MARA, MAKT.

types: begin of t_TC_MATNR_PRTNO,
         MATNR like MARA-MATNR,
         MAKTX LIKE MAKT-MAKTX,
         MFRPN like MARA-MFRPN,
         MFRNR like MARA-MFRNR,
       end of t_TC_MATNR_PRTNO.

data:     g_TC_MATNR_PRTNO_itab   type t_TC_MATNR_PRTNO occurs 0,
          g_TC_MATNR_PRTNO_wa     type t_TC_MATNR_PRTNO. "work area
data:     g_TC_MATNR_PRTNO_copied.           "copy flag

controls: TC_MATNR_PRTNO type tableview using screen 9003.

data:     g_TC_MATNR_PRTNO_lines  like sy-loopc.
