*--- MAIN PROGRAM: MZMMMEETOP ---*
*&---------------------------------------------------------------------*
*& INCLUDE MZMMMEETOP                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
TABLES:
 t001, t100, zmm_mems, zmm_mecs, msichtausw, t320, t141t, marc, makt.

TYPES: BEGIN OF t_tc_parent,
        docno LIKE zmm_mems-docno,
        bukrs LIKE zmm_mems-bukrs,    "+rk006
        ersda LIKE zmm_mems-ersda,
        ernam LIKE zmm_mems-ernam,
        laeda LIKE zmm_mems-laeda,
        aenam LIKE zmm_mems-aenam ,
        flag,       "FLAG FOR MARK COLUMN
       END OF t_tc_parent.

TYPES: BEGIN OF t_tc_child,
         docno LIKE zmm_mecs-docno,
         matnr LIKE zmm_mecs-matnr,
         werks LIKE zmm_mecs-werks,
         bwtar LIKE zmm_mecs-bwtar,
         dismm LIKE zmm_mecs-dismm,
         flag,       "FLAG FOR MARK COLUMN
       END OF t_tc_child.

TYPES: BEGIN OF tab_type,
        fcode LIKE rsmpe-func,
      END OF tab_type.

CONSTANTS: BEGIN OF c_tab_child,
             tab1 LIKE sy-ucomm VALUE 'TAB_CHILD_FC1',
             tab2 LIKE sy-ucomm VALUE 'TAB_CHILD_FC2',
           END OF c_tab_child.

CONTROLS: tc_parent TYPE TABLEVIEW USING SCREEN 7000.
CONTROLS: tab_child TYPE TABSTRIP.
CONTROLS: tc_child TYPE TABLEVIEW USING SCREEN 7001.
CONTROLS: tc_msg TYPE TABLEVIEW USING SCREEN 7002.


DATA:      BEGIN OF g_tab_child,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPMZMMMEE',
             pressed_tab LIKE sy-ucomm VALUE c_tab_child-tab1,
           END OF g_tab_child.

DATA:     g_tc_parent_itab   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_istb   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_copy   TYPE t_tc_parent OCCURS 0,
          g_tc_parent_wa     TYPE t_tc_parent.           "WORK AREA
DATA:     g_tc_parent_copied.                            "COPY FLAG
DATA:     g_tc_parent_lines  LIKE sy-loopc,
            tc_parent_lines  LIKE sy-loopc.              "+rk004

DATA:     g_tc_child_itab   TYPE t_tc_child OCCURS 0,
          g_tc_child_wa     TYPE t_tc_child.             "WORK AREA
DATA:     g_tc_child_copied.                             "COPY FLAG
DATA:     g_tc_child_lines  LIKE sy-loopc,
            tc_child_lines  LIKE sy-loopc.
DATA:     tab TYPE STANDARD TABLE OF tab_type WITH
          NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
          wa_tab TYPE tab_type.

DATA:     g_check_flag,
          g_extnd_flag,
          g_reprt_flag.

DATA:     ok_code LIKE sy-ucomm.

TABLES : t001w.

*----------------------------------------------------------------------*

TYPES : BEGIN OF t_mm01,
          docno LIKE zmm_mems-docno,     "+rk003
          matnr LIKE rmmg1-matnr, "Material Code
          werks LIKE rmmg1-werks, "Plant
          bwtar LIKE rmmg1-bwtar, "Valuation Type
          lgnum LIKE rmmg1-lgnum, "Warehouse number
          vkorg LIKE rmmg1-vkorg, "Sales Org
          prodh LIKE mvke-prodh,  "Product hierarchy
          mtart LIKE rmmg1-mtart, "Material type
          prctr LIKE marc-prctr,  "Profit Center
          dispo LIKE marc-dispo,  "MRP controller
          bwtty LIKE mbew-bwtty,  "Valuation category
          bklas LIKE mbew-bklas,  "Valuation Class
          zksel TYPE zksel,
        END OF t_mm01.

TYPES:  BEGIN OF t_msg,
          docno LIKE zmm_mems-docno,     "+rk003
          matnr  LIKE mara-matnr,
          werks  LIKE marc-werks,        "+rk001
          msgtyp LIKE bdcmsgcoll-msgtyp,
          bwtar  LIKE rmmg1-bwtar,
          msgv1  LIKE bdcmsgcoll-msgv1,
        END OF t_msg.

TYPES: BEGIN OF t_check,
          matnr LIKE mara-matnr,
          laeda LIKE mara-laeda,
          aenam LIKE mara-aenam,
          vpsta LIKE mara-vpsta,
          pstat LIKE mara-pstat,
       END OF t_check.


DATA: ist_msg TYPE t_msg OCCURS 0.
DATA: wa_msg  TYPE t_msg.

DATA: BEGIN OF g_mm01_del OCCURS 0,
      docno LIKE zmm_mecs-docno,          "+rk003
      matnr LIKE rmmg1-matnr,             "Material Code
      bwtar LIKE rmmg1-bwtar,
      END OF g_mm01_del.

DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: nodata VALUE '/'.
DATA:     g_tc_msg_lines  LIKE sy-loopc.

DATA: wa_check TYPE t_check.
DATA: ist_zksel TYPE zksel.
DATA: g_exist,  g_all, g_only_second, g_mail.

DATA: BEGIN OF it_views OCCURS 0,
      text  TYPE c,
      END OF it_views.

DATA: G_NEWR, G_PEND, G_COMP.        "+rk003

data :g_qmatnr like qmat-matnr,
      g_qwerks like qmat-werks,
      g_qart like  qmat-art.

data : wa_qmat like qmat.


DATA: g_mm01_ist        TYPE   t_mm01 OCCURS 0.
DATA: g_mm01_wa         TYPE   t_mm01.
data : g_tmp_wa type t_mm01.

   DATA: plants LIKE marc_werk OCCURS 0 WITH HEADER LINE.
   DATA: l_mstring(480).
   DATA: l_subrc LIKE sy-subrc.
   DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
   DATA: cupdate LIKE ctu_params-updmode VALUE 'S'.
   DATA: smalllog TYPE c." VALUE 'X'.
