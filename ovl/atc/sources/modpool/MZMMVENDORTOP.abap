*--- MAIN PROGRAM: MZMMVENDORTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMVENDORTOP                                               *
*&                                                                     *
*&--------------------------- ------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 24/11/2008      <RD1K960611>    SAB_SUMODH
*
*1) New Structure Declared.
************************************************************************

FUNCTION-POOL sza1 MESSAGE-ID am.
TYPE-POOLS vrm .
TYPE-POOLS: szadr, slis.
*----------------------------------------------------------------------*
* Tables                                                               *
*----------------------------------------------------------------------*
TABLES :
  lfa1,lfb1,lfm1,lfbk, ekko, bsik, t001w, msg_log, msg_text,
  zmm_hvencrt,zmm_dvencrt,addr1_val,zmm_hvenext,zmm_dvenext,
  addr1_data,zmm_vend_unblock, stxh, bnka,
  zfivmsbank, zmm_vms_ifsc , zmm_vms_cnd , zfivms_brd, icon,
  zauth_user, adrc, sood , zmm_vend_block, agr_users.

DATA : udm    TYPE char5,
       state  TYPE char2,
       code   TYPE char2,
       number TYPE char7,
       ud_no  TYPE char19.


*----------------------------------------------------------------------*
* constants                                                            *
*----------------------------------------------------------------------*

CONSTANTS c_nr_range_nr LIKE  inri-nrrangenr VALUE  '01'.
CONSTANTS c_nr_object   LIKE  inri-object VALUE 'ZMM_VCREQ1'.
CONSTANTS c_nr_obj_ext  LIKE  inri-object VALUE 'ZMM_VCEXT1'.
CONSTANTS c_nr_object1  LIKE  inri-object VALUE 'ZMM_VCUNBL'.
CONSTANTS: c_line_length TYPE i VALUE 72.

TYPES  :  ty_texttable(c_line_length) TYPE c OCCURS 0.

*----------------------------------------------------------------------*
* Internal Tables                                                      *
*----------------------------------------------------------------------*

DATA  : BEGIN OF ist_vend OCCURS 0,
          mark,
          rej_flg,
          vend    LIKE zmm_dvencrt,
          fnd_flg,               "'Y' - FOUND 'X'-NFOUND
        END OF ist_vend.
DATA  : BEGIN OF ist_gui OCCURS 0 ,
          fcode LIKE rsmpe-func,
        END OF ist_gui .

DATA  : BEGIN OF ist_t005t OCCURS 0 ,
          land1 LIKE t005t-land1,
          landx LIKE t005t-landx,
        END OF ist_t005t .

DATA  : BEGIN OF ist_t005u OCCURS 0 ,
          bland LIKE t005u-bland,
          bezei LIKE t005u-bezei,
        END OF ist_t005u.

DATA  : BEGIN OF ist_t016t OCCURS 0 ,
          brsch LIKE t016t-brsch,
          brtxt LIKE t016t-brtxt,
        END OF ist_t016t.

DATA  : BEGIN OF ist_tcurt OCCURS 0 ,
          waers LIKE tcurt-waers,
          ltext LIKE tcurt-ltext,
        END OF ist_tcurt.

DATA  : BEGIN OF ist_req OCCURS 0 ,
          reqno    LIKE zmm_hvencrt-reqno,
          bukrs    LIKE zmm_hvencrt-bukrs,
          erfdt    LIKE zmm_hvencrt-erfdt,
          ass_flag LIKE zmm_hvencrt-ass_flag,
          lifnr    LIKE zmm_vend_unblock-lifnr,     "080911 CAB_SUDHIR
          ernam    LIKE zmm_vend_unblock-ernam,     "080911 CAB_SUDHIR
        END OF ist_req.
* Begin of <> on 10022012
DATA  : BEGIN OF ist_requnbl OCCURS 0 ,
          reqno       LIKE zmm_vend_unblock-reqno,
          bukrs       LIKE zmm_vend_unblock-bukrs,
          lifnr       LIKE zmm_vend_unblock-lifnr,
          ernam       LIKE zmm_vend_unblock-ernam,
          erfdt       LIKE zmm_vend_unblock-erfdt,
          zrelease    LIKE zmm_vend_unblock-zrelease,
          releasedby  LIKE zmm_vend_unblock-releasedby,
          zapprove    LIKE zmm_vend_unblock-zapprove,
          approvedby  LIKE zmm_vend_unblock-approvedby,
          ass_flag    LIKE zmm_hvencrt-ass_flag,
          assigned_by LIKE zmm_vend_unblock-assigned_by,
          assign_date LIKE zmm_vend_unblock-assign_date,
        END OF ist_requnbl.

* End of <> on 10022012
* Begin of <> on 30122010
DATA  : BEGIN OF ist_rsn OCCURS 0 ,
*          blk_unblk LIKE zmm_vms_reason-blk_unblk,
          zreason LIKE zmm_vms_reason-zreason,
        END OF ist_rsn.
* End of <> on 30122010
DATA: BEGIN OF ist_bdcstatus OCCURS 0,
        reqno(10),
        indx      LIKE msg_text-indx,
        tcode     LIKE bdcmsgcoll-tcode,
        dyname    LIKE bdcmsgcoll-dyname,
        dynumb    LIKE bdcmsgcoll-dynumb,
        msgtyp    LIKE bdcmsgcoll-msgtyp,
        fldname   LIKE bdcmsgcoll-fldname,
        msgtx     LIKE msg_text-msgtx.
DATA : END OF ist_bdcstatus.

DATA : BEGIN OF ist_vendor OCCURS 0.
        INCLUDE STRUCTURE zmm_addreq.
DATA : END OF ist_vendor.

*------ VENDOR FOUND FROM LFA1------------
DATA : BEGIN OF ist_vendor1 OCCURS 0.
        INCLUDE STRUCTURE zmm_venadd.
DATA :  namestring TYPE string.                             "(100).
DATA : END OF ist_vendor1.
*----- VENDOR FOUND FROM LFA1------------

DATA  : BEGIN OF ist_extn OCCURS 0,
          mark.
        INCLUDE STRUCTURE zmm_dvenext.
DATA  : name1  LIKE zmm_dvencrt-name1,
        name2  LIKE  zmm_dvencrt-name2,
        sortl  LIKE  zmm_dvencrt-sortl,
        stras1 LIKE	zmm_dvencrt-stras1,
        suppl1 LIKE	zmm_dvencrt-suppl1,
        suppl2 LIKE	zmm_dvencrt-suppl2,
        suppl3 LIKE	zmm_dvencrt-suppl3,
        ort01  LIKE  zmm_dvencrt-ort01,
        ort02  LIKE  zmm_dvencrt-ort02,
        pstlz  LIKE  zmm_dvencrt-pstlz,
        regio  LIKE  zmm_dvencrt-regio,
        land1  LIKE  zmm_dvencrt-land1,
        telf1  LIKE  zmm_dvencrt-telf1,
        telfx  LIKE  zmm_dvencrt-telfx,
        email  LIKE  zmm_dvencrt-email,
        brsch  LIKE  zmm_dvencrt-brsch,
        stcd1  LIKE  zmm_dvencrt-stcd1,
        stcd2  LIKE  zmm_dvencrt-stcd2,
        END OF ist_extn.
*dATA :  End of ist_extn.

DATA  : BEGIN OF ist_acc_grp OCCURS 0 ,
          ktokk LIKE t077y-ktokk,
          txt30 LIKE t077y-txt30,
        END OF ist_acc_grp .

*Data  : Begin of ist_string occurs 0 ,
*          name1 like lfa1-name1,
*        End of ist_string.

DATA  : BEGIN OF ist_plant OCCURS 0 ,
          werks LIKE t024w-werks,
        END OF ist_plant.

DATA  : BEGIN OF ist_cities OCCURS 0 ,
          ort01 LIKE zmm_cities-ort01,
*          LTEXT like ZMM_CITIES-LTEXT,
        END OF ist_cities .

DATA: BEGIN OF ist_linetab OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF ist_linetab.

DATA: BEGIN OF ist_linetab_temp OCCURS 20.
        INCLUDE STRUCTURE tline.
DATA: END OF ist_linetab_temp.

DATA  : BEGIN OF ist_lifnr OCCURS 0 ,
          lifnr LIKE lfa1-lifnr,
          ebeln LIKE ekpo-ebeln,
          eindt LIKE eket-eindt,
        END OF ist_lifnr.


*{   REPLACE        OCQK901323                                        2
*\TYPES:BEGIN OF ty_lfa1.
TYPES:BEGIN OF ty_lfa1.
*}   REPLACE
*{   REPLACE        OCQK901323                                        3
*\        INCLUDE STRUCTURE lfa1.
        INCLUDE STRUCTURE lfa1.
*}   REPLACE
*{   DELETE         OCQK901323                                        1
*\TYPES : j_1ipanno TYPE j_1ipanno,
*}   DELETE

*{   REPLACE        OCQK901323                                        4
*\        END OF ty_lfa1.
       types: END OF ty_lfa1.
*}   REPLACE

DATA: ist_lfa1 TYPE TABLE OF ty_lfa1 WITH HEADER LINE.

DATA  :
  dyfields             LIKE dynpread OCCURS 1 WITH HEADER LINE,
  ist_texttable        TYPE ty_texttable,
****  ist_lfa1 LIKE STANDARD TABLE OF lfa1 WITH HEADER LINE,
  ist_lfa2             TYPE STANDARD TABLE OF lfa1,
  wa_lfa2              TYPE lfa1,
  ist_zmm_dvencrt      LIKE STANDARD TABLE OF zmm_dvencrt WITH HEADER
LINE,
  ist_row_del          LIKE STANDARD TABLE OF zmm_dvencrt WITH HEADER LINE,
  ist_kredk            LIKE STANDARD TABLE OF m_kredk WITH HEADER LINE,
  ist_bdcdata          LIKE bdcdata  OCCURS 0  WITH HEADER LINE,
  ist_bdcstatus2       LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
* ist_cities like standard table of zmm_cities with header line,
  ist_dist             LIKE STANDARD TABLE OF zmm_districts WITH HEADER LINE,
  ist_dvenext          LIKE STANDARD TABLE OF zmm_dvenext WITH HEADER LINE,
  ist_zmm_vend_unblock LIKE STANDARD TABLE OF zmm_vend_unblock,
  ist_msg_text         LIKE STANDARD TABLE OF msg_text WITH HEADER LINE,
  ist_temp             LIKE STANDARD TABLE OF zmm_dvencrt WITH HEADER LINE.

CONTROLS:
  tab_ctl  TYPE TABLEVIEW USING SCREEN 220,
  tab_srch TYPE TABLEVIEW USING SCREEN 230,
  tab_ext  TYPE TABLEVIEW USING SCREEN 320,
  tab_unbl TYPE TABLEVIEW USING SCREEN 420,
  tab_bl   TYPE TABLEVIEW USING SCREEN 450.
*----------------------------------------------------------------------*
* Data declarations for long text                                      *
*----------------------------------------------------------------------*

DATA :
  w_container   TYPE REF TO cl_gui_custom_container,
  w_split_cont1 TYPE REF TO cl_gui_easy_splitter_container,
  w_split_cont2 TYPE REF TO cl_gui_easy_splitter_container,
  w_editor1     TYPE REF TO cl_gui_textedit,                   " text editor
  w_editor2     TYPE REF TO cl_gui_textedit,                   " text editor
  w_repid       LIKE sy-repid.

*----------------------------------------------------------------------*
* Work Area Declaration                                                *
*----------------------------------------------------------------------*
DATA : wa_hvencrt LIKE zmm_hvencrt,
       wa_dvencrt LIKE zmm_dvencrt,
       wa_vend    LIKE ist_vend,
       wa_adr6    LIKE adr6.                            "04082011 SS
DATA : wa_extn LIKE ist_extn.
DATA : wa_addr1_complete TYPE szadr_addr1_complete.
DATA : wa_user_address  LIKE  addr3_val.
DATA : wa_user_usr03  LIKE  usr03.
DATA : wa_addr1_tab TYPE szadr_addr1_line.
DATA : wa_zmm_vend_unblock LIKE zmm_vend_unblock.

*----------------------------------------------------------------------*
* Global Data Declaration                                              *
*----------------------------------------------------------------------*
DATA : ok_code TYPE sy-ucomm,
       save_ok TYPE sy-ucomm.

DATA : g_trans_mode(2). "(N)ew  (M)odify (D)isplay "g_trans_mode 02022012
DATA : g_detail_lines  LIKE sy-loopc.
DATA : g_rec_found(4) TYPE n.
DATA : g_vend_cnt(4) TYPE n.
DATA : g_opn_flg.                    "for activating scr fields
DATA : g_ans,g_crt1,g_crt2,g_crt3.
DATA : g_req_num(8).
DATA : g_vend(3) TYPE n.
DATA : g_add_row_no(3) TYPE n.       "row no of tab_ctl in 220
DATA : g_scr TYPE sy-dynnr.
DATA : g_mess(30).
DATA : g_src_button.
DATA : g_str(10).
DATA : g_no_vend.
DATA : g_status_icon LIKE icons-text.
DATA : g_icon_header LIKE icons-text.

""""""""""""""""""""""""
"comment by lipsy 23.11.2015 RD1K999141

*DATA : g_mark(5) TYPE n.

"end of comment by lipsy 23.11.2015 RD1K999141
"""""""""""""""""""""""""""
DATA : g_linno LIKE sy-linno .
DATA : g_fname(30) TYPE c .
DATA : l_count(2) TYPE n.
DATA : g_bdc_flag.
DATA : g_id    TYPE vrm_id,
       g_list  TYPE vrm_values,
       g_value LIKE LINE OF g_list.
DATA : g_r_count TYPE sy-stepl.
DATA : g_vend_err.
DATA : g_addrnumber LIKE addr1_sel-addrnumber.
DATA : g_mod_button.
DATA : g_rej_all.
DATA : g_stat(10).
DATA : g_loc_text(30).
DATA : g_com_text(30).
DATA : g_ltext_mod.
DATA : g_src.
DATA : g_report_flag.
DATA : g_unblock_vendor.
DATA : g_block_vendor.    "SS

DATA : g_dynnr1 LIKE sy-dynnr.
DATA : g_dynnr2 LIKE sy-dynnr.
DATA : g_lifnr LIKE lfa1-lifnr.
DATA : g_datar LIKE sy-datar.
DATA : g_analyse.
DATA : g_dyn_text_header(20).
DATA : g_ok_code_9010 LIKE sy-ucomm.
DATA : g_call_prog LIKE sy-repid.
DATA : g_call_screen LIKE sy-dynnr.
DATA :
  g_cursorfield(30),
  g_cursorline      TYPE n,
  g_firsttime       VALUE 'X',
  g_index           LIKE sy-tabix.


***ranges
RANGES : r_ktokk FOR t077k-ktokk.
DATA  del_zmm_dvencrt.
DATA : ist_list LIKE STANDARD TABLE OF abaplist.
DATA : g_user_command LIKE  sy-ucomm.
DATA : g_actvt(2) TYPE n.
DATA : g_frgco TYPE frgco.
DATA : BEGIN OF ist_reqn OCCURS 0,
         reqno        LIKE zmm_hvencrt-reqno,
         reqcl        LIKE zmm_hvencrt-reqcl,
         ddtext       LIKE dd07v-ddtext,
         bukrs        LIKE zmm_hvencrt-bukrs,
         reqloc       LIKE zmm_hvencrt-reqloc,
         ernam        LIKE zmm_hvencrt-ernam,
         erfdt        LIKE zmm_hvencrt-erfdt,
         released_by  LIKE zmm_hvencrt-released_by,         "10012012
         release_date LIKE zmm_hvencrt-release_date,        "10012012
       END OF ist_reqn.
DATA:  ist_fcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       l_layout  TYPE slis_layout_alv,
       ls_events TYPE slis_alv_event OCCURS 0,
       it_events TYPE slis_alv_event,
       repid     LIKE sy-repid.

DATA : g_ok_9000 LIKE sy-ucomm.
DATA : g_assign.  "gcu 25.01.06

*------ VENDOR BLOCK ------------------------------------*

DATA  : BEGIN OF ist_bl OCCURS 0,
          mark.
        INCLUDE STRUCTURE zmm_vend_block.
DATA  : name1      LIKE  zmm_dvencrt-name1,
        name2      LIKE  zmm_dvencrt-name2,
        sortl      LIKE  zmm_dvencrt-sortl,
        stras1     LIKE	zmm_dvencrt-stras1,
        suppl1     LIKE	zmm_dvencrt-suppl1,
        suppl2     LIKE	zmm_dvencrt-suppl2,
        suppl3     LIKE	zmm_dvencrt-suppl3,
        ort01      LIKE  zmm_dvencrt-ort01,
        ort02      LIKE  zmm_dvencrt-ort02,
        pstlz      LIKE  zmm_dvencrt-pstlz,
        regio      LIKE  zmm_dvencrt-regio,
        land1      LIKE  zmm_dvencrt-land1,
        telf1      LIKE  zmm_dvencrt-telf1,
        telfx      LIKE  zmm_dvencrt-telfx,
        email      LIKE  zmm_dvencrt-email,
        brsch      LIKE  zmm_dvencrt-brsch,
        stcd1      LIKE  zmm_dvencrt-stcd1,
        stcd2      LIKE  zmm_dvencrt-stcd2,
        mob_number TYPE zmm_dvencrt-mob_number,
        END OF ist_bl.
* Begin of <> on 05012011
DATA  : BEGIN OF ist_bl_temp OCCURS 0,
          mark.
        INCLUDE STRUCTURE zmm_vend_block.
DATA  : name1      LIKE  zmm_dvencrt-name1,
        name2      LIKE  zmm_dvencrt-name2,
        sortl      LIKE  zmm_dvencrt-sortl,
        stras1     LIKE	zmm_dvencrt-stras1,
        suppl1     LIKE	zmm_dvencrt-suppl1,
        suppl2     LIKE	zmm_dvencrt-suppl2,
        suppl3     LIKE	zmm_dvencrt-suppl3,
        ort01      LIKE  zmm_dvencrt-ort01,
        ort02      LIKE  zmm_dvencrt-ort02,
        pstlz      LIKE  zmm_dvencrt-pstlz,
        regio      LIKE  zmm_dvencrt-regio,
        land1      LIKE  zmm_dvencrt-land1,
        telf1      LIKE  zmm_dvencrt-telf1,
        telfx      LIKE  zmm_dvencrt-telfx,
        email      LIKE  zmm_dvencrt-email,
        brsch      LIKE  zmm_dvencrt-brsch,
        stcd1      LIKE  zmm_dvencrt-stcd1,
        stcd2      LIKE  zmm_dvencrt-stcd2,
        mob_number TYPE zmm_dvencrt-mob_number,
        END OF ist_bl_temp.
DATA : wa_bl_temp  LIKE ist_bl_temp.
* End of <> on 05012011
DATA : ist_zmm_vend_block LIKE STANDARD TABLE OF zmm_vend_block,
       wa_zmm_vend_block  TYPE zmm_vend_block.
*------ VENDOR UNBLOCK ------------------------------------*

DATA  : BEGIN OF ist_unbl OCCURS 0,
          mark.
        INCLUDE STRUCTURE zmm_vend_unblock.
*DATA  : sperm LIKE lfa1-sperm,                              "-SP006
*        sperr LIKE lfa1-sperr,                              "-SP006
DATA  : name1  LIKE zmm_dvencrt-name1,
        name2  LIKE  zmm_dvencrt-name2,
        sortl  LIKE  zmm_dvencrt-sortl,
        stras1 LIKE	zmm_dvencrt-stras1,
        suppl1 LIKE	zmm_dvencrt-suppl1,
        suppl2 LIKE	zmm_dvencrt-suppl2,
        suppl3 LIKE	zmm_dvencrt-suppl3,
        ort01  LIKE  zmm_dvencrt-ort01,
        ort02  LIKE  zmm_dvencrt-ort02,
        pstlz  LIKE  zmm_dvencrt-pstlz,
        regio  LIKE  zmm_dvencrt-regio,
        land1  LIKE  zmm_dvencrt-land1,
        telf1  LIKE  zmm_dvencrt-telf1,
        telfx  LIKE  zmm_dvencrt-telfx,
*        email LIKE  zmm_dvencrt-email,                    "SS 03082011
        brsch  LIKE  zmm_dvencrt-brsch,
        stcd1  LIKE  zmm_dvencrt-stcd1,
        stcd2  LIKE  zmm_dvencrt-stcd2,
*        mob_number type zmm_dvencrt-mob_number,             "SP013
        END OF ist_unbl.

DATA : wa_unbl LIKE LINE OF ist_unbl.

*DATA : wa_unbl TYPE ist_unbl.
* Begin of <> on 05012011
DATA  : BEGIN OF ist_unbl_temp OCCURS 0,
          mark.
        INCLUDE STRUCTURE zmm_vend_unblock.
DATA  : name1  LIKE zmm_dvencrt-name1,
        name2  LIKE  zmm_dvencrt-name2,
        sortl  LIKE  zmm_dvencrt-sortl,
        stras1 LIKE	zmm_dvencrt-stras1,
        suppl1 LIKE	zmm_dvencrt-suppl1,
        suppl2 LIKE	zmm_dvencrt-suppl2,
        suppl3 LIKE	zmm_dvencrt-suppl3,
        ort01  LIKE  zmm_dvencrt-ort01,
        ort02  LIKE  zmm_dvencrt-ort02,
        pstlz  LIKE  zmm_dvencrt-pstlz,
        regio  LIKE  zmm_dvencrt-regio,
        land1  LIKE  zmm_dvencrt-land1,
        telf1  LIKE  zmm_dvencrt-telf1,
        telfx  LIKE  zmm_dvencrt-telfx,
*        email LIKE  zmm_dvencrt-email,               "SS 03082011
        brsch  LIKE  zmm_dvencrt-brsch,
        stcd1  LIKE  zmm_dvencrt-stcd1,
        stcd2  LIKE  zmm_dvencrt-stcd2,
*        mob_number type zmm_dvencrt-mob_number,
        END OF ist_unbl_temp.
DATA : wa_unbl_temp  LIKE ist_unbl_temp.
* End of <> on 05012011
*----- Push Button Dynamic Behaviour ----------------------*
DATA :notes TYPE smp_dyntxt.
DATA: text_1(20) VALUE '  Write Notes'.
DATA: text_2(20) VALUE '   Read Notes'.
DATA: text_3(20) VALUE '   No Notes'.

DATA:   BEGIN OF tlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA:   END OF tlinetab.

DATA:   BEGIN OF tinlinetab OCCURS 10.
        INCLUDE STRUCTURE tline.
DATA:   END OF tinlinetab.

DATA : g_ok_code_dele TYPE sy-ucomm.                        "+SP006

DATA : g_sperm TYPE lfa1-sperm,
       g_sperr TYPE lfa1-sperr,
       g_blrfq LIKE ist_unbl-blrfq,                  "+SP006
       g_loevm TYPE lfa1-loevm.                      "SS 06122010
*+SP007 - Internal table & Structure for storing obligatory fields
*         fetched from Z-table ZMM_VENCHK
DATA : ist_zmm_venchk TYPE TABLE OF zmm_venchk,
       wa_zmm_venchk  TYPE  zmm_venchk.

*+SP007 - Global variables
DATA : g_vat(3),
       g_cst(3),
       g_pan(3),
       g_stx(3),
       g_bnk(3),
       g_gst(3).

*Begin of <RD1K960611>.
TYPES : BEGIN OF wa_lfa,
          lifnr TYPE lfa1-lifnr,
          land1 TYPE lfa1-land1,
          name1 TYPE lfa1-name1,
          name2 TYPE lfa1-name2,
          ort01 TYPE lfa1-ort01,
          adrnr TYPE lfa1-adrnr,
          """"""""""""""""""""""""""""""""""""""
          " ADDed  BY LIPSY on 23.11.2015 RD1K999141

          pstlz TYPE lfa1-pstlz,

          "End of ADDition  BY LIPSY on 23.11.2015 RD1K999141
          """"""""""""""""""""""""""""""""""""""""""
        END OF wa_lfa.

DATA : itab    TYPE  TABLE OF wa_lfa,
       wa_lfa5 TYPE wa_lfa.

TYPES :  BEGIN OF wa_lfa1,
           lifnr TYPE lfa1-lifnr,
           land1 TYPE lfa1-land1,
           name1 TYPE lfa1-name1,
           name2 TYPE lfa1-name2,
           ort01 TYPE lfa1-ort01,
           adrnr TYPE lfa1-adrnr,
         END OF wa_lfa1.

DATA : itab1   TYPE TABLE OF wa_lfa1,
       wa_lfa6 TYPE wa_lfa1.

*End of <RD1K960611>.
* Begin of <RD1K968710> on 11-05-10
DATA : g_okcode931 TYPE sy-ucomm,
       g_okcode319 TYPE sy-ucomm,
       g_okcode321 TYPE sy-ucomm,
       g_okcode281 TYPE sy-ucomm,
       g_okcode109 TYPE sy-ucomm,
       g_okcode531 TYPE sy-ucomm.
CONSTANTS : g_nrobj     LIKE nriv-object     VALUE 'ZFI_VMSBNK',
            g_nrobj1    TYPE nrobj           VALUE 'ZVMS_BNKEM', "added by ss on 3/9/21
            g_nrrangenr LIKE inrdp-nrrangenr VALUE '01'.

DATA : g_spantext(9),
       g_title_release(30) VALUE 'Approved by Head of Department',
       g_title_approve(30) VALUE 'Released by VMC',
       g_title_assign(30)  VALUE 'Assigned by CVP',
       g_create,
       g_release,
       g_reject            VALUE 'X'.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC319'
TYPES: BEGIN OF t_tc319,
         reqno          LIKE zfivmsbank-reqno,
         srno           LIKE zfivmsbank-srno,
         lifnr          LIKE zfivmsbank-lifnr,
         name1          LIKE zfivmsbank-name1,
         bankl          LIKE zfivmsbank-bankl,
         bankn          LIKE zfivmsbank-bankn,
         koinh          LIKE zfivmsbank-koinh,
         bankl_new      LIKE zfivmsbank-bankl_new,
         bankn_new      LIKE zfivmsbank-bankn_new,
         koinh_new      LIKE zfivmsbank-koinh_new,
         ccode          LIKE zfivmsbank-ccode,
         username       LIKE zfivmsbank-username,
         cpf            LIKE zfivmsbank-cpf,
         status         LIKE zfivmsbank-status,
         attach         LIKE zfivmsbank-attach,
         zlist          LIKE zfivmsbank-zlist,
         hof_cpf_no     LIKE zfivmsbank-hof_cpf_no,
         hof_name       LIKE zfivmsbank-hof_name,
         hof_rldate     LIKE zfivmsbank-hof_rldate,
         hof_zremarks   LIKE zfivmsbank-hof_zremarks,
         vmc_cpf_no     LIKE zfivmsbank-vmc_cpf_no,
         vmc_name       LIKE zfivmsbank-vmc_name,
         vmc_apdate     LIKE zfivmsbank-vmc_apdate,
         vmc_zremarks   LIKE zfivmsbank-vmc_zremarks,
         cvp_cpf_no     LIKE zfivmsbank-cvp_cpf_no,
         cvp_name       LIKE zfivmsbank-cvp_name,
         cvp_assdate    LIKE zfivmsbank-cvp_assdate,
         registration   LIKE zfivmsbank-registration,
         deregistration LIKE zfivmsbank-deregistration,
         zvendtimestamp LIKE zfivmsbank-zvendtimestamp,     "06092011
         sel319,
         exist,        "Flag for already exist lifnr
         zflag          LIKE zfivmsbank-zflag,              "RD1K979928 by Sudhir Sharma

       END OF t_tc319.

TYPES: BEGIN OF t_tc321,
         reqno          LIKE zfivmsbank-reqno,
         srno           LIKE zfivmsbank-srno,
         lifnr          LIKE zfivmsbank-lifnr,
         name1          LIKE zfivmsbank-name1,
         bankl          LIKE zfivmsbank-bankl,
         bankn          LIKE zfivmsbank-bankn,
         koinh          LIKE zfivmsbank-koinh,
         bankl_new      LIKE zfivmsbank-bankl_new,
         bankn_new      LIKE zfivmsbank-bankn_new,
         koinh_new      LIKE zfivmsbank-koinh_new,
         ccode          LIKE zfivmsbank-ccode,
         username       LIKE zfivmsbank-username,
         cpf            LIKE zfivmsbank-cpf,
         status         LIKE zfivmsbank-status,
         attach         LIKE zfivmsbank-attach,
         zlist          LIKE zfivmsbank-zlist,
         hof_cpf_no     LIKE zfivmsbank-hof_cpf_no,
         hof_name       LIKE zfivmsbank-hof_name,
         hof_rldate     LIKE zfivmsbank-hof_rldate,
         hof_zremarks   LIKE zfivmsbank-hof_zremarks,
         vmc_cpf_no     LIKE zfivmsbank-vmc_cpf_no,
         vmc_name       LIKE zfivmsbank-vmc_name,
         vmc_apdate     LIKE zfivmsbank-vmc_apdate,
         vmc_zremarks   LIKE zfivmsbank-vmc_zremarks,
         cvp_cpf_no     LIKE zfivmsbank-cvp_cpf_no,
         cvp_name       LIKE zfivmsbank-cvp_name,
         cvp_assdate    LIKE zfivmsbank-cvp_assdate,
         registration   LIKE zfivmsbank-registration,
         deregistration LIKE zfivmsbank-deregistration,
         zvendtimestamp LIKE zfivmsbank-zvendtimestamp,     "06092011
         sel321,
         exist,        "Flag for already exist lifnr
         zflag          LIKE zfivmsbank-zflag,              "RD1K979928 by Sudhir Sharma
         zbnkt          LIKE zfivmsbank-zbnkt,
       END OF t_tc321.


*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC319'
DATA:     g_tc319_itab       TYPE t_tc319 OCCURS 0,
          g_tc319_itab_temp  TYPE t_tc319 OCCURS 0,
          g_tc319_itab_temp9 TYPE t_tc319 OCCURS 0,
          g_tc319_wa         TYPE t_tc319, "work area
          g_tc319_wa_temp    TYPE t_tc319,
          g_tc319_wa_as      TYPE t_tc319.

DATA:     g_tc321_itab      TYPE t_tc321 OCCURS 0,
          g_tc321_itab_temp TYPE t_tc321 OCCURS 0,
          g_tc321_wa        TYPE t_tc321, "work area
          g_tc321_wa_temp   TYPE t_tc321,
          g_tc321_wa_as     TYPE t_tc321.

DATA:     g_tc319_copied,           "copy flag
          g_tc321_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC319' ITSELF
CONTROLS: tc319 TYPE TABLEVIEW USING SCREEN 0319.
CONTROLS: tc321 TYPE TABLEVIEW USING SCREEN 0321.

*&SPWIZARD: LINES OF TABLECONTROL 'TC319'
DATA:     g_tc319_lines  LIKE sy-loopc.
DATA:     g_tc321_lines  LIKE sy-loopc.

DATA : BEGIN OF wa_object_doc_g,
         bankl LIKE zmm_vms_ifsc-bankl,
         banka LIKE bnka-banka,
       END OF wa_object_doc_g.

DATA : ist_object_f4_doc_g LIKE STANDARD TABLE OF wa_object_doc_g
       INITIAL SIZE 100.
DATA : wa_bnka TYPE bnka,
       wa_lfbk TYPE lfbk.
* End of <RD1K968710>

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC109'
TYPES: BEGIN OF t_tc109,
         reqno    LIKE zfivmsbank-reqno,
         username LIKE zfivmsbank-username,
         cdate    LIKE zfivmsbank-cdate,
         status   LIKE zfivmsbank-status,
         sel109,
       END OF t_tc109.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC109'
DATA:     g_tc109_itab       TYPE t_tc109 OCCURS 0,
          g_tc109_itab_temp  TYPE t_tc109 OCCURS 0,
          g_tc109_itab_temp9 TYPE t_tc109 OCCURS 0,
          g_tc109_wa         TYPE t_tc109. "work area
DATA:     g_tc109_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC109' ITSELF
CONTROLS: tc109 TYPE TABLEVIEW USING SCREEN 0109.

*&SPWIZARD: LINES OF TABLECONTROL 'TC109'
DATA:     g_tc109_lines  LIKE sy-loopc.

**&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC531'
*TYPES: BEGIN OF T_TC531,
*         REQNO LIKE ZFIVMSBANK-REQNO,
*         LIFNR LIKE ZFIVMSBANK-LIFNR,
*         BANKL LIKE ZFIVMSBANK-BANKL,
*         BANKN LIKE ZFIVMSBANK-BANKN,
*         KOINH LIKE ZFIVMSBANK-KOINH,
*         USERNAME LIKE ZFIVMSBANK-USERNAME,
*         CDATE LIKE ZFIVMSBANK-CDATE,
*         CPUTM LIKE ZFIVMSBANK-CPUTM,
*         STATUS LIKE ZFIVMSBANK-STATUS,
*         SEL531,
*       END OF T_TC531.
*
**&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC531'
*DATA:     G_TC531_ITAB      TYPE T_TC531 OCCURS 0,
*          G_TC531_ITAB_TEMP TYPE T_TC531 OCCURS 0,
*          G_TC531_WA     TYPE T_TC531. "work area
*DATA:     G_TC531_COPIED.           "copy flag
*
**&SPWIZARD: DECLARATION OF TABLECONTROL 'TC531' ITSELF
*CONTROLS: TC531 TYPE TABLEVIEW USING SCREEN 0531.
DATA : ist_zfivmsbank TYPE TABLE OF zfivmsbank,
       wa_zfivmsbank  TYPE zfivmsbank,
       g_zvms_reqno   TYPE zfivmsbank-reqno,
       wa_icon        TYPE icon.

***Working Area
DATA  g_att_files_wa LIKE swotobjid.
***Internal Table.
DATA  g_att_files LIKE TABLE OF swotobjid.
DATA : exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
***
DATA : g_docno_lifnr LIKE zfivmsbank-lifnr.
DATA : docno_lifnr TYPE zfivmsbank-zvendtimestamp."   like ZFIVMSBANK-LIFNR. 06092011 RD1K977563
DATA : g_docno       LIKE zfivmsbank-reqno.
DATA : att_fl, g_attachment.

DATA : g_username LIKE zfivmsbank-username,
       g_cpf      LIKE zfivmsbank-cpf,
       g_ccode    LIKE zfivmsbank-ccode.
DATA : wa_zauth_user  TYPE zauth_user,
       g_ap, g_rj, g_new, g_exist , g_exist_ztable, g_vmc,
       g_lifnr1       TYPE zfivmsbank-lifnr,
       g_reqno        TYPE zfivmsbank-reqno.                "270911

DATA : wa_lfb1 TYPE lfb1.

DATA : BEGIN OF ist_rdata_sbi OCCURS 0,
         span(24),
         koinh_new  TYPE zfivmsbank-koinh_new,
         bankn_new  TYPE zfivmsbank-bankn_new,
         bankl_new  TYPE zfivmsbank-bankl_new,

         street     TYPE zfivms_brd-street,
         str_suppl1 TYPE zfivms_brd-street,
         tel_number TYPE zfivms_brd-street,
         city1      TYPE zfivms_brd-street,

         vmc_apdate TYPE zfivmsbank-vmc_apdate,
         vmc_aptime TYPE zfivmsbank-vmc_aptime,
         status     TYPE zfivmsbank-status,
*         reqno type zfivmsbank-reqno,
*         srno  type zfivmsbank-srno,
*         lifnr      type zfivmsbank-lifnr,
*         bankl_new  type zfivmsbank-bankl_new,
*         bankn_new  type zfivmsbank-bankn_new,
*         koinh_new  type zfivmsbank-koinh_new,
*         registration  type zfivmsbank-registration,
       END OF ist_rdata_sbi.

DATA : BEGIN OF ist_ddata_sbi OCCURS 0,
         span(24),
         koinh_new  TYPE zfivmsbank-koinh_new,
         benf(10),
         bankn_new  TYPE zfivmsbank-bankn_new,
         bankl_new  TYPE zfivmsbank-bankl_new,

         vmc_apdate TYPE zfivmsbank-vmc_apdate,
         vmc_aptime TYPE zfivmsbank-vmc_aptime,
         status     TYPE zfivmsbank-status,
*         reqno type zfivmsbank-reqno,
*         srno  type zfivmsbank-srno,
*
*         lifnr  type zfivmsbank-lifnr,
*         bankl  type zfivmsbank-bankl,
*         bankn  type zfivmsbank-bankn,
*         koinh  type zfivmsbank-koinh,
*         deregistration  type zfivmsbank-deregistration,
       END OF ist_ddata_sbi.
DATA : l_rsbi        TYPE i,
       l_dsbi        TYPE i,
       g_filename    TYPE string,
       g_date_rd(10),
       g_time_rd(06),
       wa_adrc       TYPE adrc,
       wa_sood       TYPE sood,
       wa_zfivms_brd TYPE zfivms_brd.
DATA : ist_agr_users TYPE TABLE OF agr_users,
       wa_agr_users  TYPE agr_users.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC531'
TYPES: BEGIN OF t_tc531,
         reqno          LIKE zfivmsbank-reqno,
         srno           LIKE zfivmsbank-srno,
         lifnr          LIKE zfivmsbank-lifnr,
         name1          LIKE zfivmsbank-name1,
         bankl          LIKE zfivmsbank-bankl,
         bankn          LIKE zfivmsbank-bankn,
         koinh          LIKE zfivmsbank-koinh,
         bankl_new      LIKE zfivmsbank-bankl_new,
         bankn_new      LIKE zfivmsbank-bankn_new,
         koinh_new      LIKE zfivmsbank-koinh_new,
         ccode          LIKE zfivmsbank-ccode,
         username       LIKE zfivmsbank-username,
         cpf            LIKE zfivmsbank-cpf,
         cdate          LIKE zfivmsbank-cdate,
         cputm          LIKE zfivmsbank-cputm,
         status         LIKE zfivmsbank-status,
         attach         LIKE zfivmsbank-attach,
         zlist          LIKE zfivmsbank-zlist,
         hof_cpf_no     LIKE zfivmsbank-hof_cpf_no,
         hof_name       LIKE zfivmsbank-hof_name,
         hof_rldate     LIKE zfivmsbank-hof_rldate,
         hof_rltime     LIKE zfivmsbank-hof_rltime,
         hof_zremarks   LIKE zfivmsbank-hof_zremarks,
         vmc_cpf_no     LIKE zfivmsbank-vmc_cpf_no,
         vmc_name       LIKE zfivmsbank-vmc_name,
         vmc_apdate     LIKE zfivmsbank-vmc_apdate,
         vmc_aptime     LIKE zfivmsbank-vmc_aptime,
         vmc_zremarks   LIKE zfivmsbank-vmc_zremarks,
         cvp_cpf_no     LIKE zfivmsbank-cvp_cpf_no,
         cvp_name       LIKE zfivmsbank-cvp_name,
         cvp_assdate    LIKE zfivmsbank-cvp_assdate,
         cvp_asstime    LIKE zfivmsbank-cvp_asstime,
         registration   LIKE zfivmsbank-registration,
         deregistration LIKE zfivmsbank-deregistration,
         sel531,
         approve,                                   "Approve Check Box
         reject,                                    "Reject  Check Box
         zflag          LIKE zfivmsbank-zflag,         "02042012 by SS
         zbnkt          LIKE zfivmsbank-zbnkt,        " Added on 1.3.2021
       END OF t_tc531.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC531'
DATA:     g_tc531_itab       TYPE t_tc531 OCCURS 0,
          g_tc531_itab_temp  TYPE t_tc531 OCCURS 0,
          g_tc531_itab_temp9 TYPE t_tc531 OCCURS 0,
          g_tc531_wa         TYPE t_tc531. "work area
DATA:     g_tc531_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC531' ITSELF
CONTROLS: tc531 TYPE TABLEVIEW USING SCREEN 0531.

*&SPWIZARD: LINES OF TABLECONTROL 'TC531'
DATA:     g_tc531_lines  LIKE sy-loopc.

* Begin of <> on 111010 for MM by Sudhir Sharma
DATA:   g_exec(1) VALUE 'X'.                                "+011
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        wa_t100 TYPE t100.
DATA: lifnr        TYPE zfivmsbank-lifnr,
      ccode        TYPE zfivmsbank-ccode,
      g_strlen1(4),
      g_strlen2(4).
* End of <>
DATA : g_message(250) .                                     "080911 SS
DATA : g_check TYPE c .     "231211 SS RD1K978300
* Begin of <> on 27122011
DATA : ist_zfivmsbank_bankl TYPE TABLE OF zfivmsbank,
       wa_zfivmsbank_bankl  TYPE zfivmsbank.
* End of <> on 27121
* Begin of <> on 19062012
DATA :  BEGIN OF wa_lfbk_lfa1,
          lifnr TYPE lfa1-lifnr,
          sperr TYPE lfa1-sperr,
        END OF wa_lfbk_lfa1.

DATA : ist_lfbk_lfa1 LIKE STANDARD TABLE OF wa_lfbk_lfa1
       INITIAL SIZE 100.
* end of <> on 19062012
DATA  l_f_bdc.
DATA : g_cors,                             "Äll foru var added on 17052013 by Sudhir Sharma RD1K984792
       g_asy_reqno TYPE zfivmsbank-reqno,
       g_asy_lifnr TYPE zfivmsbank-lifnr,
       g_asy_uname TYPE sy-uname.


""""""""""""""""""""""""added by lipsy on 28.05.2013
"""""""""for making mobile phone number 10 digits

DATA: l_len_mob TYPE char2.

""""""""""""end of addition by lipsy  on 28.05.2013
""""""""""""""
""""""""""""""""""""""""added by lipsy on 29.05.2013
""""""""""""""""for getting telephone for particular userid
DATA   :it_9205 TYPE  STANDARD TABLE OF  pa9205,
        wa_9205 TYPE pa9205.

TYPES:BEGIN OF ty_usr21_telnr,
        bname      TYPE usr21-bname,
        persnumber TYPE usr21-persnumber,
      END OF ty_usr21_telnr.

TYPES:BEGIN OF ty_adrp_telnr,
        name_text  TYPE  adrp-name_text,
        persnumber TYPE  adrp-persnumber,
      END OF ty_adrp_telnr.

DATA   :itab_usr21  TYPE  TABLE OF ty_usr21_telnr,
        itab_adrp   TYPE  TABLE OF ty_adrp_telnr,
        wa_usr21    LIKE LINE OF itab_usr21,
        wa_adrp     LIKE LINE OF itab_adrp,
        wa_unbl_rej LIKE LINE OF ist_unbl,
        wa_bl_rej   LIKE LINE OF ist_bl.

DATA: v_user             TYPE adrp-name_text,
      g_block_vendor_att,
      v_lines_old        TYPE sy-linno,
      v_lines_new        TYPE sy-linno,
      l_name             TYPE vrm_id,
      l_list             TYPE vrm_values,
      l_value            LIKE LINE OF l_list.

DATA: it_arg_user TYPE  TABLE OF agr_users.

DATA txt_num TYPE i.
""""""""""""""""""""""""end of add by lipsy on 29.05.2013
DATA l_vend_unblock_reqno_old TYPE zmm_vend_unblock-reqno.
""""""""""""""""""""""""""""""




DATA: objtype        LIKE bapi4001_1-objtype,
      obj_id         LIKE bapi4001_1-objkey,
      obj_id_ext     LIKE bapi4001_1-extension,
      context        LIKE bapi4001_1-context,
      address_number LIKE adrc-addrnumber,
      bapiad1vl      LIKE bapiad1vl OCCURS 0 WITH HEADER LINE,
      bapiad1vl_x    LIKE bapiad1vlx OCCURS 0 WITH HEADER LINE,
      bapiadtel      LIKE bapiadtel OCCURS 0 WITH HEADER LINE,
      bapiadtel_x    LIKE bapiadtelx OCCURS 0 WITH HEADER LINE,
      bapiadsmtp     LIKE bapiadsmtp OCCURS 0 WITH HEADER LINE,
      bapiadsmt_x    LIKE bapiadsmtx OCCURS 0 WITH HEADER LINE,
      return         LIKE bapiret2 OCCURS 0.
DATA l_lfnr TYPE string.
DATA l_unblock_create_flag(1).


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 4.12.2014 for vendor no display " RD1K994952
DATA:g_lifnr_check LIKE lfa1-lifnr,
     g_lifnr_rfq   LIKE lfa1-lifnr,
     count_pan     TYPE n,
     wa_vend_pan   LIKE ist_vend,
     v_reqnoassgn  TYPE zmm_vend_unblock-reqno.
"end of addition by lipsy on 4.12.2014 for vendor no display " RD1K994952
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
DATA : g_okcode152 TYPE sy-ucomm,
       g_srch_flag.

******************** Start of addition by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*******************

DATA :g_pan_wa      TYPE j_1imovend.
DATA : g_ans_pan.

******************** End of addition by  Anamika on 25.02.2015 for Warning message for pan  RD1K996460*******************

*+SP015 : Start
CONTROLS : vms_ctrl_tp TYPE TABLEVIEW USING SCREEN 0750.

* Declartion of wa & internal table for storing pf-status
DATA : BEGIN OF wa_pf_status,
         fcode LIKE rsmpe-func,
       END OF wa_pf_status.

DATA: ist_pf_status LIKE STANDARD TABLE OF wa_pf_status WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10.

DATA : BEGIN OF wa_zmm_vms_tp_set_tc.
        INCLUDE STRUCTURE zmm_vms_tp_set.
DATA : name1 TYPE zmm_dvencrt-name1.
DATA : sel(1).
DATA END OF wa_zmm_vms_tp_set_tc.

DATA : ist_zmm_vms_tp_set LIKE TABLE OF wa_zmm_vms_tp_set_tc,
       wa_zmm_vms_tp_set  LIKE wa_zmm_vms_tp_set_tc.

DATA : BEGIN OF wa_upd_vnd_rp_dtl,
         lifnr           TYPE zmm_dvencrt-lifnr,
         rel_partner_flg TYPE zmm_dvencrt-rel_partner_flg,
       END OF wa_upd_vnd_rp_dtl.

DATA : ist_upd_vnd_rp_dtl LIKE TABLE OF wa_upd_vnd_rp_dtl.

DATA : g_ok_code_700 TYPE sy-ucomm.

DATA : g_lifnr_750     TYPE zmm_dvencrt-lifnr,
       g_curs_name(30).

*+SP015 : End


""""""""""""""""""""""""""""""""""""""""""""
"ADDED BY LIPSY ON 2.07.2015 RD1K997727
****Working Area for attaching and listing files
DATA  g_att_files_wa_ch LIKE swotobjid.
***Internal Table.
DATA :g_att_files_ch LIKE TABLE OF swotobjid.


TYPES :BEGIN OF ty_attach_check,
         instid_a TYPE sibfboriid,
         typeid_a TYPE sibftypeid,
       END OF ty_attach_check.

DATA : exclude_tab_ch LIKE soxet OCCURS 0 WITH HEADER LINE.
DATA:save_ok_ext       TYPE sy-ucomm,
     v_exist_pan       TYPE char1,
     itab_pan_details  TYPE TABLE OF zmm_dvencrt,
     itab_attach_check TYPE TABLE OF  ty_attach_check.
"END OF ADDITION BY LIPSY ON 2.07.2015 RD1K997727
DATA: it_vms_ind TYPE TABLE OF zmm_vms_industry,
      wa_vms_ind LIKE LINE OF it_vms_ind.
""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""
"added by lipsy on 21.09.2015 for srm vendor replicate RD1K998437

DATA:  l_logsys(32),
       itab_return_srm TYPE  TABLE OF zsrmvendorres,
       v_ptner         TYPE zmm_hvencrt-srmid,
       l_vatno         TYPE  zmm_dvencrt-stcd1,
       l_len_vat       TYPE i,
       flag_gst        TYPE i,
       l_cstno         TYPE zmm_dvencrt-stcd2,
       l_len_cst       TYPE i.

"end of addition by lipsy on 21.09.2015 for srm vendor replicate RD1K998437

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""
"ADDed  BY LIPSY on 23.11.2015 RD1K999141

DATA: v_reqcl_new    TYPE zmm_hvencrt-reqcl,
      itab_lifnr_pan TYPE TABLE OF j_1imovend,
      wa_lifnr_pan   LIKE LINE OF  itab_lifnr_pan,
      v_index_pan    TYPE sy-tabix,
      ist_lfa3       TYPE TABLE OF ty_lfa1 WITH HEADER LINE.


DATA:v_name1_correct LIKE lfa1-name1,
     v_name1_c       LIKE lfa1-name1.

DATA: lt_result           TYPE match_result_tab,
      ls_result           TYPE match_result,
      count_name1(2)      TYPE n,
      v_offset            TYPE  match_result-offset,
      g_mark1             TYPE c,
      count_srm_replicate TYPE i,
      wa_return_srm       TYPE  zsrmvendorres,
      wa_lfa1_compare     TYPE lfa1,
      wa_adrc_compare     TYPE adrc,
      wa_adrc_comparetel  TYPE adrc,
      wa_adr6_compare     TYPE adr6,
      wa_pan_compare      TYPE j_1imovend,
      v_lfa1_name         TYPE lfa1-name1,
      v_lfa1_city         TYPE lfa1-ort01,
      v_lfa1_street1      TYPE  lfa1-stras,
      v_lfa1_street2      TYPE adrc-str_suppl1,
      v_lfa1_street3      TYPE adrc-str_suppl2,
      v_lfa1_country      TYPE  lfa1-land1,
      v_lfa1_pan          TYPE   j_1imovend-j_1ipanno,
      v_lfa1_mail         TYPE  adr6-smtp_addr,
      v_ros_name          TYPE zmm_dvencrt-name1,
      v_ros_city          TYPE zmm_dvencrt-ort01,
      v_ros_street1       TYPE zmm_dvencrt-stras1,
      v_ros_street2       TYPE zmm_dvencrt-suppl1,
      v_ros_street3       TYPE zmm_dvencrt-suppl2,
      v_ros_country       TYPE zmm_dvencrt-land1,
      v_ros_pan           TYPE zmm_dvencrt-j_1ipanno,
      v_lfa1_vendor       TYPE  lfa1-lifnr,
      v_lfa1_loevm        TYPE  lfa1-loevm,
      v_lfa1_sperr        TYPE  lfa1-sperr,
      v_lfa1_sperm        TYPE  lfa1-sperm,
      v_lfa1_sperq        TYPE  lfa1-sperq,
      v_lfa1_sperz        TYPE  lfa1-sperz,
      lv_blocked          TYPE char1,
      v_ros_mail          TYPE zmm_dvencrt-email,
      lt_lfm_extend       TYPE TABLE OF lfm1,
      wa_lfm_extend       LIKE LINE  OF lt_lfm_extend,
      v_lifnr_extend      TYPE char10,
      v_return            TYPE char1.

"End of ADDition  BY LIPSY on 23.11.2015 RD1K999141
""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""
"added by lipsy on 28.12.2015


TYPES : BEGIN OF wa_lfa_srmrp,
          mandt TYPE sy-mandt,
          lifnr TYPE lfa1-lifnr,
          land1 TYPE lfa1-land1,
          name1 TYPE lfa1-name1,
          name2 TYPE lfa1-name2,
          ort01 TYPE lfa1-ort01,
          adrnr TYPE lfa1-adrnr,
          """"""""""""""""""""""""""""""""""""""
          " ADDed  BY LIPSY on 23.11.2015 RD1K999141

          pstlz TYPE lfa1-pstlz,

          "End of ADDition  BY LIPSY on 23.11.2015 RD1K999141
          """"""""""""""""""""""""""""""""""""""""""
        END OF wa_lfa_srmrp.

DATA:  wa_lfa1_srm      TYPE wa_lfa_srmrp,
       v_lifnr_update   TYPE lfa1-lifnr,
       obj_id_new       LIKE bapi4001_1-objkey,
       objtype_new      LIKE bapi4001_1-objtype,
       context_new      LIKE bapi4001_1-context,
       v_objty_new      TYPE ad_ownertp,
       v_addnr_new      TYPE ad_addrnum,
       l_adrnr_new      TYPE lfa1-adrnr,
       v_contx_new      TYPE ad_context VALUE '0001',
       bapiadsmtp_new   LIKE bapiadsmtp OCCURS 0 WITH HEADER LINE,
       bapiadsmt_x_new  LIKE bapiadsmtx OCCURS 0 WITH HEADER LINE,
       bapiadtel_new    LIKE bapiadtel OCCURS 0 WITH HEADER LINE,
       bapiadtel_x_new  LIKE bapiadtelx OCCURS 0 WITH HEADER LINE,
       return_new       LIKE bapiret2 OCCURS 0,
       v_lifnr_srm_repl TYPE char10,
       v_lifnr_mk03     TYPE zmm_dvencrt-lifnr,

       wa_postal        TYPE lfa1,
       wa_postal1       TYPE lfa1,
       v_user_comm      TYPE char12,
       return_reject    TYPE char10,
       wa_vend_mail     LIKE ist_vend,
       v_called         TYPE char1.

DATA:v_reqcl_srm        TYPE zmm_hvencrt-reqcl,
     wa_hvencrt_reqstat TYPE zmm_hvencrt,
     g_vendor_present   TYPE lifnr,
     addrno             TYPE bapi4001_1-addr_no.
"end of addition by lipsy on 28.12.2015
""""""""""""""""""""""""""""""""
*
TYPES: BEGIN OF ty_lfb1,
         lifnr TYPE lfb1-lifnr,
         burks TYPE lfb1-bukrs,
       END OF ty_lfb1.
*
TYPES:    BEGIN OF ty_gst_item,
            sel          TYPE c,
            vendor_no    TYPE lifnr,
            company_code TYPE zmm_gst_upd_item-company_code,
            ven_class    TYPE zmm_gst_upd_item-ven_class,
            gst_no       TYPE zmm_gst_upd_item-gst_no,
            remarks      TYPE zmm_gst_upd_item-remarks,
            request      TYPE zmm_gst_upd_item-request_no,

          END OF ty_gst_item.
**DATA  : BEGIN OF it_upd_ITEM OCCURS 0,
**           sel TYPE C,
**        VENDOR_NO TYPE LIFNR,
**        COMPANY_CODE TYPE ZMM_GST_UPD_ITEM-COMPANY_CODE,
**        VEN_CLASS TYPE ZMM_GST_UPD_ITEM-VEN_CLASS,
**        GST_NO TYPE ZMM_GST_UPD_ITEM-GST_NO,
**        REMARKS TYPE ZMM_GST_UPD_ITEM-REMARKS,
**        REQUEST type ZMM_GST_UPD_ITEM-REQUEST_NO,
**         END OF it_upd_ITEM.
*
*
*
DATA : it_zmm_gst_upd  TYPE TABLE OF zmm_gst_upd,
       wa_zmm_gst_upd  TYPE zmm_gst_upd,
       it_upd_item     TYPE STANDARD TABLE OF ty_gst_item,
       wa_upd_item     TYPE ty_gst_item,
       it_zmm_gst_upd1 TYPE TABLE OF zmm_gst_upd,
       wa_zmm_gst_upd1 TYPE zmm_gst_upd,
       it_lfb1         TYPE TABLE OF ty_lfb1,
       wa_lfb1_1       TYPE ty_lfb1.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_UPD' ITSELF
CONTROLS: tc_upd TYPE TABLEVIEW USING SCREEN 9031.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_UPD'
DATA:     g_tc_upd_lines  LIKE sy-loopc.

DATA: s_lfa1   TYPE lfa1,
      v_ccode  TYPE bukrs,
      flag_rf,
      flag_scr.


***Data declaration for New Bank screen SS
DATA:  cb_nor, cb_emd.   "added by ss

*** BOC on 1.4.21 for OVC by ss
DATA : g_id1    TYPE vrm_id,
       g_list1  TYPE vrm_values,
       g_value1 LIKE LINE OF g_list1.


** Added by ss on 1.6.21
*TABLES: ZFIWTIN_TAN_EXEM.
*DATA: gv_ACCNO TYPE ZFIWTIN_TAN_EXEM-LIFNR,
*      gv_BUKRS TYPE ZFIWTIN_TAN_EXEM-BUKRS,
*      lv_flag1(1).

*TYPES: BEGIN OF TY_TAX,
*          SECTION_CODE  TYPE ZFIWTIN_TAN_EXEM-SECTION_CODE,
*          CERT_NO       TYPE ZFIWTIN_TAN_EXEM-WT_EXNR,
*          EXEMPT_RATE   TYPE ZFIWTIN_TAN_EXEM-WT_EXRT,
*          EXEMPT_BEGIN  TYPE ZFIWTIN_TAN_EXEM-WT_EXDF,
*          EXEMPT_END    TYPE ZFIWTIN_TAN_EXEM-WT_EXDT,
*          EXEMPT_REASON TYPE ZFIWTIN_TAN_EXEM-WT_WTEXRS,
*          tax_type      TYPE ZFIWTIN_TAN_EXEM-WITHT,
*          tax_type_desc TYPE char40,
*          tax_code      TYPE ZFIWTIN_TAN_EXEM-WT_WITHCD,
*          tax_code_desc TYPE char40,
*          exempt_amount TYPE ZFIWTIN_TAN_EXEM-EXEM_THRESHOLD,
*          waers         TYPE ZFIWTIN_TAN_EXEM-WAERS,
*      END OF ty_tax.
*
*DATA: it_tax TYPE STANDARD TABLE OF ty_tax,
*      wa_tax TYPE ty_tax.
*
*CONTROLS: tc_tax TYPE TABLEVIEW USING SCREEN 9120.
*DATA: G_TAX_LINES  LIKE SY-LOOPC.
*data: it_tab_tab TYPE STANDARD TABLE OF ZFIWTIN_TAN_EXEM.
