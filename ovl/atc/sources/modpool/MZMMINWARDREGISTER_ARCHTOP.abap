*--- MAIN PROGRAM: MZMMINWARDREGISTER_ARCHTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMINWARDREGISTERTOP                                       *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapmzmminwardregister
  NO STANDARD PAGE HEADING     "Switch off standard heading
  LINE-SIZE  85                "Width is 80 characters
  LINE-COUNT 65                "Page length is 65 lines
  MESSAGE-ID zmm.

TABLES : zmm_inwardhd,         "Inward Register - Header
*        zmm_inwarddt,         "Inward Register - Detail
         zmm_cnfrcnhd,         "RECEIPT CONVOY NOTE HEADER FOR CNF-MM
         zmm_cnfrcndt,         "RECEIPT CONVOY NOTE DETAILS FOR CNF-MM
         zmm_cnfinwr,          "INWARD ENTRY TABLE FOR C N F - MM
         zmm_location,         "LOCATION TABLE
         mkpf,                 "Header: Material Document
         likp,                 "SD Document: Delivery Header Data
         lfa1,                 "Vendor Master (General Section)
         t001w,                "Plants/Branches
         ekko,                 "Purchasing Document Header
         kssk,                 "Allocation Table: Object to Class
         tcurc.                "Currency Codes
DATA: g_ok_code LIKE  sy-ucomm.
DATA: g_crea    VALUE 'X', g_chan, g_disp, g_dele, g_mode(30),
      g_flg     TYPE  c VALUE 'Y'.

DATA : BEGIN OF ist_tab_type OCCURS 0,
        fcode LIKE rsmpe-func,          "Menu Painter: Object code
 END OF ist_tab_type.

DATA: BEGIN OF ist_inwardhd1 OCCURS 0.
        INCLUDE STRUCTURE zmm_inwardhd.
DATA: END OF ist_inwardhd1.

DATA: BEGIN OF ist_inwarddt OCCURS 0.
        INCLUDE STRUCTURE zmm_inwarddt.
DATA:   indat LIKE zmm_cnfinwr-indat,  "Date on which the record created
        lfdat LIKE likp-lfdat,         "Delivery date
        traid LIKE likp-traid,         "Means-of-transport ID
        mark(1),
END OF ist_inwarddt.

DATA: BEGIN OF ist_inwarddt1 OCCURS 0.
        INCLUDE STRUCTURE zmm_inwarddt.
DATA: END OF ist_inwarddt1.
Data: wa_lips like lips.
data: g_recid(3) type n,
* start of change on 18/7/2003. From ZMM_GRSTOC_PENDING the control
* comes to this program and again from this program the control should
* go back to ZMM_GRSTOC_PENDING.
g_status(1) .

* end of change on 18/7/2003

CONTROLS: disprec  TYPE TABLEVIEW USING SCREEN 9010 ,
          disprec1 TYPE TABLEVIEW USING SCREEN 9030 .
* BEGIN OF <> ON 06112013
data : g_ksskflag,
       g_srmsusflag,
       g_sus_asn type BBP_INBD_L,
       IT_INB_DELIVERY_DETAIL type BBP_INBD_D occurs 0,
       g_RETURN type  BAPIRETURN occurs 0,
       G_LOGSYS(32),
       GI_OBJECT_ID TYPE CRMD_ORDERADM_H-OBJECT_ID,
       GE_HEADER    TYPE ZBBP_PDS_SUSASN_HEADER_D, " OCCURS 0,
       GE_ITEM      TYPE ZBBP_PDS_SUSASN_ITEM_D   OCCURS 0,
       wa_kssk      type kssk,
       ist_tcurc    type table of tcurc,
       wa_tcurc     type tcurc.
* END OF <>
DATA l_ebeln_old TYPE ZMM_INWARDHD-EBELN .
DATA l_ebeln_.
DATA: err(1), l_req.
************************************************archived retrival declarations**********************************
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
 data : p_arch.
