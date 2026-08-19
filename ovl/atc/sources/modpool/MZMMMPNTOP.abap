*--- MAIN PROGRAM: MZMMMPNTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMMPNTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMMPN                    .
*------------------------------------------------------------------*
*                            Tables                                *
*------------------------------------------------------------------*
tables : zmm_mpn, msg_log, msg_text.

*---------------------------------------------------------------------*
*                Types                                                *
*---------------------------------------------------------------------*
Data  : Begin of ist_gui occurs 0 ,
          fcode like rsmpe-func,
        End of ist_gui .

*------------------------------------------------------------------*
*                            Data                                  *
*------------------------------------------------------------------*
data : g_ok_9001 like sy-ucomm,
       g_ok_9010 like sy-ucomm,
       g_function like sy-ucomm,
       g_exit like sy-ucomm,
       g_action(1),
       g_butxt like t001-butxt,
       g_fctext(10) type c,
       g_obj_code like rsmptexts-obj_code.

data ist_return_tab  LIKE STANDARD TABLE OF ddshretval WITH  HEADER
                                              LINE.
data ist_mara LIKE STANDARD TABLE OF mara with header line.
data ist_mara1 LIKE STANDARD TABLE OF mara.
data ist_zmmmpn LIKE STANDARD TABLE OF zmm_mpn with header line.

Data  : Begin of ist_t001 occurs 0 ,
          bukrs like t001-bukrs,
          butxt like t001-butxt,
        End of ist_t001.

Data  : Begin of ist_docno occurs 0 ,
          docno like zmm_mpn-docno,
          bukrs like zmm_mpn-bukrs,
          ernam like zmm_mpn-ernam,
          ersda like zmm_mpn-ersda,
        End of ist_docno.

*& type for the data of tablecontrol 'G_NEW_MPN'
types: begin of t_g_new_mpn,
         matnr like zmm_mpn-matnr,
         maktx like makt-maktx,
         mfrnr like zmm_mpn-mfrnr,
         mfrpn like zmm_mpn-mfrpn,
         mpnco like zmm_mpn-mpnco,
         flag,       "flag for mark column
       end of t_g_new_mpn.

data:     ist_mpn   type t_G_NEW_MPN occurs 0,
          wa_mpn     type t_G_NEW_MPN. "work area
data:     g_G_NEW_MPN_copied.           "copy flag

controls: G_NEW_MPN type tableview using screen 9010.

data:     g_G_NEW_MPN_lines  like sy-loopc.


data : begin of ist_mpn_srch occurs 0,
        name1 like lfa1-name1,
        bmatn like mara-bmatn.        "matcode
        include structure wa_mpn.    "mpn no in matnr
data : end of ist_mpn_srch.

controls: G_SRC_MPN type tableview using screen 9010.

data:     g_G_SRC_MPN_lines  like sy-loopc.

data : wa_makt like makt.
data : wa_lfa1 like lfa1.
data : g_num(2).
DATA: rc LIKE inri-returncode,
      g_docno(7) TYPE c.

ranges : r_mat_grp for g_num.

data : g_vendor like zmm_mpn-mfrnr.
data : g_partno like zmm_mpn-mfrpn.
data : g_dup.

data: g_ok_2000 like sy-ucomm. "for certificate screen
data: g_token.
Data  : Begin of ist_pop_list occurs 0 ,
          matnr like mara-matnr,
          maktx like makt-maktx,
          mfrnr like mara-mfrnr,
          mfrpn like mara-mfrpn,
        End of ist_pop_list.

DATA: L_CURSORFIELD(20).
DATA : g_linno LIKE sy-linno .
Data : Begin of ist_gui1 occurs 0 ,
         fcode like rsmpe-func,
       End of ist_gui1 .


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"added by lipsy on 28.8.2015 RD1K998398

type-pools:tumls.

tables:

   merrdat,
   bgr00,
   bmm00,
   bmmh1.

types: begin of t_tc_request,
         docno like zmm_mpn-docno,
         bukrs like zmm_mpn-bukrs,
         ersda like zmm_mpn-ersda,
         ernam like zmm_mpn-ernam,
         flag,       "flag for mark column
       end of t_tc_request.

data:     g_tc_request_itab   type t_tc_request occurs 0,
          g_tc_request_wa     type t_tc_request. "work area
data:     g_tc_request_copied.           "copy flag

controls: tc_request type tableview using screen 9000.

data:     g_tc_request_lines  like sy-loopc.

data:     ok_code like sy-ucomm.

data :    g_req_type(1).

constants: begin of c_ts_request,
             tab1 like sy-ucomm value 'TS_REQUEST_FC1',
             tab2 like sy-ucomm value 'TS_REQUEST_FC2',
             tab3 like sy-ucomm value 'TS_REQUEST_FC3',
           end of c_ts_request.

controls:  ts_request type tabstrip.
data:      begin of g_ts_request,
             subscreen   like sy-dynnr,
             prog        like sy-repid value 'SAPMZMMMPN_GEN',
             pressed_tab like sy-ucomm value c_ts_request-tab1,
           end of g_ts_request.

types: begin of t_tc_details,
         docno like zmm_mpn-docno,
         ernam like zmm_mpn-ernam,
         matnr like zmm_mpn-matnr,
         mfrnr like zmm_mpn-mfrnr,
         mfrpn like zmm_mpn-mfrpn,
         flag,       "flag for mark column
       end of t_tc_details.

types: begin of ty_mpncode,
         matnr like mara-matnr,
         mfrnr like mara-mfrnr,
         mfrpn like mara-mfrpn,
         bmatn like mara-bmatn,
       end of ty_mpncode.

data:     g_tc_details_itab   type t_tc_details occurs 0,
          g_tc_details_wa     type t_tc_details. "work area
data:     g_tc_details_copied.           "copy flag

data :   ist_bmatn type standard table of ty_mpncode.
data :   wa_bmatn type ty_mpncode.

controls: tc_details type tableview using screen 9001.

data:     g_tc_details_lines  like sy-loopc.

types: begin of ty_log,
          docno like zmm_mpn-docno,
          ernam like zmm_mpn-ernam,
          matnr like merrdat-matnr,
          msgty like merrdat-msgty,
          msgno like merrdat-msgno,
          msgv1(255),          " like MERRDAT-MSGV1,
       end of ty_log.

data:  ist_log type ty_log occurs 0.
data:  wa_log type ty_log.
data : ist_list like standard table of abaplist.
data:  ist_merrdat type merrdat occurs 0.
data:  wa_merrdat type merrdat.
data:  ist_lsmw_log(255) occurs 0.
data:  wa_lsmw_log(255).

controls: tc_log type tableview using screen 9002.

data: g_tc_log_lines like sy-loopc.
data : g_rec_found(4) type n.
*
data :begin of ist_mara2 occurs 0,
        bmatn like mara-bmatn,
      end of ist_mara2.
data :wa_mara like mara-bmatn.
*------DATA DECLARATION FOR LSMW ----------------------------*

data:
  init_bgr00 like bgr00,
  init_bmm00 like bmm00,
  init_bmmh1 like bmmh1.

*----- buffer to hold file data -----------------------------*
data:
  begin of gt_buffer occurs 0,
    record type tumls_segment,
    data(7960) type c,
  end of gt_buffer.

* Fields that are made available to the user:
data:
  g_project type tumls_project value 'ZMM_ALL_PL',
  g_subproj type tumls_subproj value 'ZMM_ALL',
  g_object type tumls_objectnew value 'ZMM_MPN_CR',
  g_record type tumls_segment,         " name of current record
  g_cnt_records_transferred type i,
  g_cnt_transactions_transferred type i,
  g_dsn_out type tumls_filename,
  g_userid like sy-uname,
  g_groupname(12),
  g_nodata.

data:
  g_return   like sy-subrc,
  g_lockuser like sy-uname.

data:
  g_skip_record,
  g_transfer_record,
  g_skip_transaction,
  g_transfer_transaction.

constants:
  yes value 'X',
  no value ' '.

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
data: g_ok_9000 like sy-ucomm.
*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
data:   ist_bdcdata like bdcdata    occurs 0 with header line.

tables:   mara, makt.

types: begin of t_tc_matnr_prtno,
         matnr like mara-matnr,
         maktx like makt-maktx,
         mfrpn like mara-mfrpn,
         mfrnr like mara-mfrnr,
       end of t_tc_matnr_prtno.

data:     g_tc_matnr_prtno_itab   type t_tc_matnr_prtno occurs 0,
          g_tc_matnr_prtno_wa     type t_tc_matnr_prtno. "work area
data:     g_tc_matnr_prtno_copied.           "copy flag

controls: tc_matnr_prtno type tableview using screen 9003.

data:     g_tc_matnr_prtno_lines  like sy-loopc.

data: w_agr_users type agr_users.

 data: lv_syuname type sy-uname.

"end of addition by lipsy on 28.8.2015 RD1K998398

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




*&---------------------------------------------------------------------*
*&      List Processing commands
*&---------------------------------------------------------------------*

AT USER-COMMAND.
  SET SCREEN 0.
  LEAVE SCREEN.
