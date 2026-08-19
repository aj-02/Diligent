*--- MAIN PROGRAM: MZMMMERTOP ---*
*&---------------------------------------------------------------------*
*& Include MZMMMERTOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  SAPMZMMMER MESSAGE-ID ZMM.

TABLES: ZMM_MEMS, ZMM_MECS, MARA, T001W, T149D, T001K, T141T, FMFPO,
T320,MSG_LOG, MSG_TEXT.

TYPES: BEGIN OF T_TC_81,
         MATNR LIKE ZMM_MECS-MATNR,
         WERKS LIKE ZMM_MECS-WERKS,
         BWTAR LIKE ZMM_MECS-BWTAR,
         DISMM LIKE ZMM_MECS-DISMM,
         PSTAT LIKE ZMM_MECS-PSTAT,
         SFLAG LIKE ZMM_MECS-SFLAG,
         ERSDA LIKE ZMM_MECS-ERSDA,
         ERNAM LIKE ZMM_MECS-ERNAM,
         LAEDA LIKE ZMM_MECS-LAEDA,
         AENAM LIKE ZMM_MECS-AENAM,
         REMRK LIKE ZMM_MECS-REMRK,
         FIPOS LIKE ZMM_MECS-FIPOS,
         FLAG,
*{   INSERT         OCPK900065                                        1
*******************Modified for HSN***********************************
  STEUC LIKE ZMM_MECS-STEUC,
  TAXIM LIKE ZMM_MECS-TAXIM,
**********************************************************************
*}   INSERT
       END OF T_TC_81.

CONTROLS: TC_81 TYPE TABLEVIEW USING SCREEN 9081.

DATA:     G_TC_81_ITAB   TYPE T_TC_81 OCCURS 0,
          G_TC_81_WA     TYPE T_TC_81.

DATA:     G_TC_81_COPIED.
DATA:     G_TC_81_LINES    LIKE SY-LOOPC.
DATA:     OK_CODE          LIKE SY-UCOMM.

DATA:     G_OK_80          LIKE SY-UCOMM.
DATA:     G_OK_81          LIKE SY-UCOMM.
DATA:     G_OK_82          LIKE SY-UCOMM.

DATA:     G_LINES          LIKE SY-LOOPC.
DATA:     G_DOCNO          LIKE ZMM_MEMS-DOCNO.

DATA: HTC_COLS TYPE CXTAB_COLUMN.

DATA: FCODE LIKE RSMPE-FUNC.
DATA: TC_81_LINE(3) TYPE C.
DATA: TC_LINES LIKE SY-LOOPC.

DATA: RC        LIKE INRI-RETURNCODE,
      NUMBER(7) TYPE C.

DATA: IST_ZMM_MECS TYPE TABLE OF ZMM_MECS.
DATA: WA_ZMM_MECS TYPE ZMM_MECS.

DATA:  CT_SORT  TYPE  LVC_T_SORT.
DATA:  IT_FIELDCAT TYPE	LVC_T_FCAT.
DATA:  WA_IT TYPE LVC_S_FCAT.

DATA:  IT_SELECTED_COLS TYPE  LVC_T_COL.
DATA:  IS_LAYOUT         TYPE LVC_S_LAYO.
DATA:  IS_SELFIELD         TYPE LVC_S_SELF.
DATA:  IT_GROUPS         TYPE LVC_T_SGRP.
DATA:  CT_FILTER         TYPE LVC_T_FILT.

DATA: BEGIN OF TEMP OCCURS 0,
      REMRK TYPE ZMM_MEMS-REMRK,
      END OF TEMP.

TYPES: BEGIN OF T_BWTAR,
       BWTAR TYPE BWTAR_D,
       END OF T_BWTAR.

DATA: BWTAR TYPE TABLE OF T_BWTAR.
DATA: WA_BWTAR TYPE T_BWTAR.

TYPES: BEGIN OF TAB_TYPE,
        FCODE LIKE RSMPE-FUNC,
      END OF TAB_TYPE.

DATA: ICON  LIKE ICONS-TEXT.

DATA: TAB TYPE STANDARD TABLE OF TAB_TYPE WITH
               NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
      WA_TAB TYPE TAB_TYPE.

DATA : IST_DEL TYPE TABLE OF ZMM_MECS WITH HEADER LINE.

DATA : WA_MAKT LIKE MAKT.                                   "+rk002

*-------start of add by rk004 ----------------------------*
DATA : G_NUM(2).
DATA : G_BUTXT LIKE T001-BUTXT.
RANGES : R_MAT_GRP FOR G_NUM.

DATA IST_RETURN_TAB  LIKE STANDARD TABLE OF DDSHRETVAL WITH  HEADER
                                              LINE.
DATA  : BEGIN OF IST_T001 OCCURS 0 ,
          BUKRS LIKE T001-BUKRS,
          BUTXT LIKE T001-BUTXT,
        END OF IST_T001.
*-------end of add by rk004 ----------------------------*

TYPES:  BEGIN OF T_MSG,
         DOCNO LIKE ZMM_MEMS-DOCNO,
         MATNR  LIKE MARA-MATNR,
         WERKS  LIKE MARC-WERKS,
         MSGTYP LIKE BDCMSGCOLL-MSGTYP,
         BWTAR  LIKE RMMG1-BWTAR,
         MSGV1  LIKE BDCMSGCOLL-MSGV1,
       END OF T_MSG.
TYPES : BEGIN OF T_MM01,
          DOCNO LIKE ZMM_MEMS-DOCNO,                        "+rk003
          MATNR LIKE RMMG1-MATNR, "Material Code
          WERKS LIKE RMMG1-WERKS, "Plant
          BWTAR LIKE RMMG1-BWTAR, "Valuation Type
          LGNUM LIKE RMMG1-LGNUM, "Warehouse number
          VKORG LIKE RMMG1-VKORG, "Sales Org
          PRODH LIKE MVKE-PRODH,  "Product hierarchy
          MTART LIKE RMMG1-MTART, "Material type
          PRCTR LIKE MARC-PRCTR,  "Profit Center
          DISPO LIKE MARC-DISPO,  "MRP controller
          BWTTY LIKE MBEW-BWTTY,  "Valuation category
          BKLAS LIKE MBEW-BKLAS,  "Valuation Class
*{   INSERT         OCPK900065                                        2
STEUC LIKE zmm_mems-steuc,
  TAXIM TYPE mlan-TAXIM,
*}   INSERT
        END OF T_MM01.

DATA: G_MM01_IST TYPE STANDARD TABLE OF   T_MM01,
      G_MM01_WA TYPE T_MM01,
      IST_MSG TYPE STANDARD TABLE OF T_MSG,
      WA_MSG  TYPE T_MSG.
DATA:     G_CHECK_FLAG,
          G_EXTND_FLAG,
          G_REPRT_FLAG.
DATA: G_EXIST,  G_ALL, G_ONLY_SECOND, G_MAIL.

DATA: LS_HEADDATA   TYPE BAPIMATHEAD.
DATA: LT_HEADDATA   TYPE STANDARD TABLE OF BAPIMATHEAD.

DATA: LT_ZMM_MEMS TYPE STANDARD TABLE OF ZMM_MEMS,
      LS_ZMM_MEMS TYPE ZMM_MEMS,
      LT_ZMM_MECS TYPE STANDARD TABLE OF ZMM_MECS,
      LS_ZMM_MECS TYPE ZMM_MECS.

TYPE-POOLS: SLIS.
DATA: ID_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV.
DATA: WA_FIELDCAT   TYPE SLIS_FIELDCAT_ALV.
DATA V_REPID TYPE SY-REPID .

DATA: WA_MESG TYPE BAPI_MATRETURN2,
      RETURNMESSAGES TYPE STANDARD TABLE OF BAPI_MATRETURN2.

DATA: W_AGR_USERS TYPE AGR_USERS.

""
"added by lipsy on 20.08.2015  RD1K998283

types:begin of ty_lgnum,
  lgnum type lgnum,
  END OF ty_lgnum.

  data:ITab_T320 TYPE TABLE OF ty_lgnum,

  G_MM01_sec TYPE STANDARD TABLE OF   T_MM01.

"end of addition by lipsy on 20.08.2015  RD1K998283
""
*{   INSERT         OCDK902682                                        3
 data: gv_steuc TYPE t604f-steuc,
       gv_TAXIM TYPE TMKM1-TAXIM,
       gv_land1 TYPE t604f-land1,
       flg TYPE int4,
       req_st TYPE zmm_hsn_upd-req_st,
       gv_req1 TYPE zmm_hsn_upd-REQ_NO,
       DOCNO_A TYPE ZMM_HSN_UPD-REQ_NO,
       DOCNO_C TYPE ZMM_HSN_UPD-REQ_NO,
       gv_req TYPE zmm_hsn_upd-REQ_NO,
       wa_zmm_hsn_upd TYPE  zmm_hsn_upd,
       wa_zmm_hsn_upd_itm TYPE  zmm_hsn_upd_itm,
       it_zmm_hsn_upd_itm TYPE TABLE OF zmm_hsn_upd_itm,
       wa_marc TYPE marc,
       wa_mlan TYPE mlan,
       gv_COUNC TYPE t001w-COUNC,
       gv_msg type  char255.


*}   INSERT
