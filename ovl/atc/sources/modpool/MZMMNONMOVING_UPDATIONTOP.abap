*--- MAIN PROGRAM: MZMMNONMOVING_UPDATIONTOP ---*
*&---------------------------------------------------------------------*
*&  Include           MZMMNONMOVING_UPDATIONTOP
*&---------------------------------------------------------------------*

DATA:OK_CODE TYPE SY-UCOMM.

TABLES:MARA,KLAH,KSSK,AUSP,ZMM_NM_HISTORY.

DATA:REMOVENM TYPE CHAR1,
     APPLYNM TYPE SY-UCOMM,
     LEONELAKHAPP TYPE CHAR1,
     MOREONELAKHAPP TYPE CHAR1.



 data: l_fyear type char4,
       l_fyear_fr type char4,
        l_fyear_frST type char6,
         l_fyear_frCT type char6,
       l_fyear_fr1 type char4,
*       v_date_from type sy-datum,
*       v_date_to type sy-datum,
       total_consumption type GSVBR,
       itab_mara type TABLE OF mara,
       itab_mver type TABLE OF mver,
       itab_s032 TYPE TABLE OF s032,
       itab_s032_copy TYPE TABLE OF s032,
       ITAB_MBEWH TYPE TABLE OF MBEWH ,
        WA_s032 LIKE LINE  OF  itab_s032 ,
       WA_s032_copy LIKE LINE OF itab_s032_copy ,
       wa_mver type mver,
       wa_mara type mara,
       WA_MBEWH LIKE LINE OF ITAB_MBEWH,
       count_success type numc4,
       count_success1 type char10,
       v_sucess type  char120.


 TYPES:begin of ty_disp,
   SEL TYPE CHAR1,
   matnr type matnr,
   consp type GSVBR,
   END OF ty_disp.

    TYPES:begin of ty_disp_STOCK,
   SEL TYPE CHAR1,
   matnr type matnr,
   WBWBEST type WBWBEST,
   consp type GSVBR,
    STOCK_FIRST1 type CHAR30,
   END OF ty_disp_STOCK.


   data:itab_disp type TABLE OF ty_disp,
         itab_disp_STOCK TYPE TABLE OF ty_disp_STOCK,
          wa_disp_STOCK LIKE LINE OF itab_disp_STOCK,
        wa_disp like line of itab_disp.


*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_101' ITSELF
CONTROLS: TC_101 TYPE TABLEVIEW USING SCREEN 0101.

DATA : g_ans,
      v_stock_VALUE TYPE s032-WBWBEST,
*  v_stock_VALUE TYPE  CHAR30,
       total_STOCK_FIRST TYPE  MBEWH-SALK3,
total_STOCK_FIRST1 TYPE CHAR30,
V_NORECORDS(6) TYPE n,
 V_GL  TYPE CHAR4.
*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_102' ITSELF
CONTROLS: TC_102 TYPE TABLEVIEW USING SCREEN 0102.



select-options: s_matnr for mara-matnr .

SELECTION-SCREEN BEGIN OF SCREEN 400 AS SUBSCREEN.
 selection-screen begin of block b1 with frame title text-005.
select-options: s_matkl FOR mara-matkl.
 selection-screen end of block b1.
 SELECTION-SCREEN END OF SCREEN 400 .
