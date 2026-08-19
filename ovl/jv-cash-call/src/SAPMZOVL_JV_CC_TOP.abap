*--- MAIN PROGRAM: SAPMZOVL_JV_CC_TOP ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_TOP
*&---------------------------------------------------------------------*
PROGRAM sapmzovl_jv_cash_call.

**&&-- Declaration of global varibles

**&&-- End of Declaration of global variables

**&&-- Declaration of global internal tables
TABLES: ZFI_BANK_PAYEE.
DATA : git_clog TYPE STANDARD TABLE OF zjv_cc_comm_log.
**&&-- End of Declaration of global internal tables

**&&-- Declaration of global workareas
DATA : gwa_jv_cc TYPE zjv_cash_call,
       gwa_clog  TYPE zjv_cc_comm_log.
**&&-- End of declaration of global workareas.

**&&-- Declaration for TextBox
DATA: line_length      TYPE i VALUE 175,
      editor_container TYPE REF TO cl_gui_custom_container,
      text_editor      TYPE REF TO cl_gui_textedit,
      text_tab_1       LIKE STANDARD TABLE OF line,
      text_tab         LIKE STANDARD TABLE OF tline.

DATA : wa_text_tab   TYPE tline,
       wa_text_tab_1 TYPE line.
**&&-- End of Declaration for Textbox

DATA: r1 TYPE c,
      r2 TYPE c,
      r3 TYPE c,
      r4 TYPE c,
      r5 TYPE c,
      r6 TYPE c,"" VALUE 'X',
      r7 TYPE c,     "added by ss on 16.4.21
      r8 TYPE c.    " added by ss on 23.8.21.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'TS_9020'
CONSTANTS: BEGIN OF c_ts_9020,
             tab1 LIKE sy-ucomm VALUE 'TS_9020_CREA',
             tab2 LIKE sy-ucomm VALUE 'TS_9020_CHNG',
             tab3 LIKE sy-ucomm VALUE 'TS_9020_DISP',
             tab4 LIKE sy-ucomm VALUE 'TS_9020_DELE',
           END OF c_ts_9020.
*&SPWIZARD: DATA FOR TABSTRIP 'TS_9020'
CONTROLS:  ts_9020 TYPE TABSTRIP.
DATA:      BEGIN OF g_ts_9020,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPMZOVL_JV_CASH_CALL',
             pressed_tab LIKE sy-ucomm VALUE c_ts_9020-tab1,
           END OF g_ts_9020.
DATA:      ok_code LIKE sy-ucomm.
DATA:  lfct_9000 LIKE sy-ucomm,
       flag_disp,
       flag_data.
DATA:  appr(11) TYPE c,
       fwd(16)  TYPE c.
DATA: gv_vtext TYPE ltext_8jv,
      gv_name1 TYPE ad_namtext,
      gv_name2 TYPE ad_namtext,
      gv_name3 TYPE ad_namtext,
      gv_name4 TYPE ad_namtext,
      gv_name5 TYPE ad_namtext,
      gv_name6 TYPE ad_namtext. " added by ss on 23.8.21 for reviewer

DATA: is_object       TYPE sibflporb,
      ep_save_request TYPE sgs_flag,
      it_objects      TYPE STANDARD TABLE OF sibflporb,
      lt_month        TYPE TABLE OF t247,
      ls_month        TYPE t247.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        wa_t100  TYPE t100,
        bapiret2 TYPE STANDARD TABLE OF bapiret2,
        month(3) TYPE c.

DATA : v_fm TYPE rs38l_fnam.

DATA: ls_control_param  TYPE ssfctrlop,
      ls_composer_param TYPE ssfcompop,
      ls_job_info       TYPE ssfcrescl,
      lv_objectid       TYPE cdhdr-objectid.

DATA: ls_object   TYPE SIBFLPORB,
      ls_logsys   TYPE LOGSYS.
DATA: lt_links    TYPE OBL_T_LINK.
CONSTANTS: ls_relation TYPE OBLRELTYPE      VALUE 'ATTA',
            ls_catid_bo LIKE ls_object-catid VALUE 'BO'.

DATA: wa_ssfcrescl TYPE ssfcrescl,
      lw_spoolids  TYPE rspoid,
      lw_ssfctrlop TYPE ssfctrlop,
      wa_ssfcompop TYPE ssfcompop,
*     gt_otf       TYPE ssfcrescl,
      wa_line      TYPE itcoo,
      gt_otf_hr    TYPE ssfcrescl,
      gt_otf       TYPE ssfcrescl,

      li_otf       TYPE TABLE OF itcoo,
      li_otf1      TYPE TABLE OF itcoo,
      li_pdf_tab   TYPE TABLE OF tline,
      v_len_in     TYPE i,
      v_bin_file   TYPE xstring.

       DATA: t_objbin   LIKE solix   OCCURS 0 WITH HEADER LINE,
       sub             TYPE sood-objdes,
       lx_document_bcs TYPE REF TO cx_document_bcs VALUE IS INITIAL.

** Added by ss on 18.4.21
 DATA: wa_bank TYPE zfi_bank_details.

** Added by ss on 23.9.2021
* data: l_docno      TYPE zfivmsbank-reqno,
*       GWA_JV_CC-REFNO1  TYPE zjv_cash_call-refno,
* G_NRRANGENR  LIKE INRDP-NRRANGENR VALUE '01',
* G_NROBJ1     TYPE NROBJ           VALUE 'ZCC_BNKREF'.

data attachments like sood5 occurs 0 with header line.
DATA  g_att_files_WA LIKE swotobjid.
DATA FILE_DETAILS1 LIKE sood2 occurs 0 with header line.
*DATA FILE_DETAILS TYPE  SOOD5.
DATA CHA_WF(10) TYPE C.
DATA SAVE_WF(10) TYPE C.
