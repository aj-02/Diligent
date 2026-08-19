*--- MAIN PROGRAM: MZMMNONMOVING_UPDATIONF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMNONMOVING_UPDATIONF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REMOVE_NM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM remove_nm .


      clear : l_fyear,l_fyear_fr.
      call function 'ZGM_GET_FISCAL_YEAR'
        exporting
          i_date = sy-datum
          i_fyv  = 'V3'
        importing
          e_fy   = l_fyear.

*
*concatenate l_fyear '03' '31' INTO v_date_to.
*
   l_fyear_fr =   l_fyear - 2.
*
*concatenate l_fyear_fr '04' '01' into v_date_from.

refresh:itab_mara[],itab_disp[],itab_mver[].
SELECT * from mara
into CORRESPONDING FIELDS OF TABLE
itab_mara
WHERE
ZZMBPR = 'NM'.

if itab_mara[] is not INITIAL.
    select * from mver
    into CORRESPONDING FIELDS OF TABLE
      itab_mver
    FOR ALL ENTRIES IN itab_mara
    where matnr = itab_mara-matnr
    AND gjahr BETWEEN   l_fyear_fr   and l_fyear.

endif.

loop at itab_mara into wa_mara.
  clear:total_consumption.

  loop at itab_mver into wa_mver where matnr = wa_mara-matnr.


   if  wa_mver-gjahr  = l_fyear_fr.

total_consumption =   total_consumption  +  wa_mver-gsv04
+ wa_mver-gsv05 + wa_mver-gsv06 + wa_mver-gsv07 + wa_mver-gsv08 + wa_mver-gsv09 + wa_mver-gsv10 + wa_mver-gsv11 + wa_mver-gsv12.
*  total_consumption =   total_consumption  +

ENDIF.
 l_fyear_fr1   = l_fyear_fr + 1.

    if wa_mver-gjahr =  l_fyear_fr1 .

  total_consumption =   total_consumption  + wa_mver-gsv01 + wa_mver-gsv02 + wa_mver-gsv03 + wa_mver-gsv04
+ wa_mver-gsv05 + wa_mver-gsv06 + wa_mver-gsv07 + wa_mver-gsv08 + wa_mver-gsv09 + wa_mver-gsv10 + wa_mver-gsv11 + wa_mver-gsv12.

endif.

   if  wa_mver-gjahr  =  l_fyear.
total_consumption =   total_consumption  + wa_mver-gsv01 + wa_mver-gsv02 + wa_mver-gsv03 .
*  total_consumption =   total_consumption  +

ENDIF.


endloop.


if total_consumption  > 0.

  wa_disp-matnr = wa_mara-matnr.

 wa_disp-consp  = total_consumption.

  append wa_disp to itab_disp.

  endif.


  endloop.



CALL SCREEN 101.


ENDFORM.                    " REMOVE_NM
*&---------------------------------------------------------------------*
*&      Form  POP_UP_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pop_up_confirm  USING    p_title
                              p_question..
 CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = p_title
      text_question         = p_question
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = g_ans.
ENDFORM.                    " POP_UP_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  APPLY_NM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM apply_nm .

*BREAK-POINT.
*
*s_matnr-sign = 'I'.
*s_matnr-OPTION = 'EQ'.
*s_matnr-low = '010001023'.
*
*     append s_matnr.
*
**s_matnr-sign = 'I'.
**s_matnr-OPTION = 'EQ'.
**s_matnr-low = '010001023'.
**   s_matnr-low = '010103044'.
**
**     append s_matnr.
*
* leave to list-processing and return to screen 0.
*
*  set pf-status space.
*
*  suppress dialog.
*
*     SUBMIT zRMCB0100_copy1
*
*
**                   WITH SL_WERKS IN R_WERKS
*
*                   WITH SL_matnr in s_matnr
*
*                  WITH SL_SPMON = '201301'
*
*                   AND RETURN   EXPORTING LIST TO MEMORY.
*
*
*
*
*
*check sy-subrc eq 0.
*
*DATA: ABAPLIST LIKE ABAPLIST OCCURS 0.
*
*CALL FUNCTION 'LIST_FROM_MEMORY'
*
*   TABLES
*
*   LISTOBJECT = ABAPLIST
*
*   EXCEPTIONS
*
*   NOT_FOUND = 1
*
*   OTHERS = 2.
*
*
*BREAK-POINT.
*DATA INT_S000(3072) TYPE C OCCURS 0 WITH HEADER LINE.
*DATA textlines(3072) TYPE C OCCURS 0 WITH HEADER LINE.
*TYPES : BEGIN OF st_budget,
*        row(30) TYPE c,
*          END OF st_budget.
*DATA :ist_budget TYPE STANDARD TABLE OF st_budget,
*      wa_budget TYPE st_budget.
*
*  DATA: BEGIN OF ist_ascitab OCCURS 1,
*         line(1000),
*        END OF ist_ascitab.
*
*  DATA : wa_ascitab LIKE ist_ascitab.
*
*call function 'LIST_TO_ASCI'
*
*   tables
*
*   listobject = ABAPLIST
**   listasci = ist_ascitab
*   listasci = INT_S000
*
*   exceptions
*
*   empty_list = 1
*
*   list_index_invalid = 2
*
*   others = 3.



*  IF NOT ist_ascitab[] IS INITIAL.
*    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
**    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
**{Begin of CR 30007900
*    CLEAR :ist_budget,
*           wa_budget.
*
*    REFRESH ist_budget.
*
*    SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.
*
*    endif.


refresh:itab_mara[],itab_s032[],  itab_s032_copy[],itab_disp_STOCK[],itab_mver[].


clear : l_fyear,l_fyear_fr.
      call function 'ZGM_GET_FISCAL_YEAR'
        exporting
          i_date = sy-datum
          i_fyv  = 'V3'
        importing
          e_fy   = l_fyear.
clear:  V_GL.
     V_GL =  l_fyear+2(2).
      CONDENSE  V_GL.

      IF MOREONELAKHAPP = 'X'.
      CONCATENATE 'GL' V_GL INTO V_GL.
      ENDIF.


      IF LEONELAKHAPP = 'X'.
      CONCATENATE 'LL' V_GL INTO V_GL.
      ENDIF.

        l_fyear_fr =   l_fyear - 2.

 CONCATENATE   l_fyear '03' INTO  l_fyear_frCT.
 CONCATENATE   l_fyear_fr '03' INTO  l_fyear_frST.

SELECT * from mara
into CORRESPONDING FIELDS OF TABLE
itab_mara
WHERE
ZZMBPR = ''
and mtart in ('ZSTO','ZSPR')
and mATKL in s_matkl.

  clear:wa_mara,wa_disp_stock.

  if itab_mara[] is not initial.

*     select MATNR WBWBEST from s032 into CORRESPONDING FIELDS OF table itab_s032
*     for ALL ENTRIES IN itab_mara
*                    where matnr = itab_mara-matnr .

**       REFRESH:itab_s032[].
*
*     select MATNR WBWBEST from s032 into CORRESPONDING FIELDS OF table itab_s032
*     for ALL ENTRIES IN itab_mara
*                    where matnr = itab_mara-matnr  and
*                          VRSIO =  '000'.

         select * from mver
    into CORRESPONDING FIELDS OF TABLE
      itab_mver
    FOR ALL ENTRIES IN itab_mara
    where matnr = itab_mara-matnr
    AND gjahr BETWEEN   l_fyear_fr   and l_fyear.




*      select MATNR SALK3 from mbewh into CORRESPONDING FIELDS OF TABLE ITAB_MBEWH
*        FOR ALL ENTRIES IN ITAB_MARA
*                    where matnr = itab_mara-matnr and
**                          bwkey = p_werks  and
*                          bwtar = ''       and
*                          lfgja =  l_fyear_fr   and
*                          lfmon = '01'.

   endif.

*   itab_s032_copy[] = itab_s032[].
*
*   sort  itab_s032_copy[] by matnr .



*   delete ADJACENT DUPLICATES FROM  itab_s032_copy[] COMPARING matnr.
*   loop at itab_s032_copy INTO  wa_s032_copy.

*   s_matnr =    wa_s032_copy-matnr.
*s_matnr = '010001023'.
*
*     append s_matnr.
*
*   s_matnr = '010103044'.
*
*     append s_matnr.

*     endloop.






CLEAR: wa_s032_copy, wa_mver,wa_s032,v_stock_VALUE,total_consumption,TOTAL_STOCK_FIRST1.
*   loop at itab_s032_copy into wa_s032_copy.
LOOP AT ITAB_MARA INTO WA_MARA.

CLEAR: v_stock_VALUE,TOTAL_STOCK_FIRST1.

*     select MATNR WBWBEST from s032 into CORRESPONDING FIELDS OF table itab_s032
*     for ALL ENTRIES IN itab_mara
*                    where matnr = itab_mara-matnr .


*     loop at itab_s032 into wa_s032 where matnr = wa_s032_copy-matnr .
*
*     v_stock_VALUE =    v_stock_VALUE + wa_s032-WBWBEST.
*
*
*     endloop.

  wa_disp_STOCK-matnr =  wa_MARA-matnr.
*    wa_disp_STOCK-matnr =  wa_s032_copy-matnr.


    clear:total_consumption.

  loop at itab_mver into wa_mver where matnr = wa_MARA-matnr." wa_s032_copy-matnr.


   if  wa_mver-gjahr  = l_fyear_fr.

total_consumption =   total_consumption  +  wa_mver-gsv04
+ wa_mver-gsv05 + wa_mver-gsv06 + wa_mver-gsv07 + wa_mver-gsv08 + wa_mver-gsv09 + wa_mver-gsv10 + wa_mver-gsv11 + wa_mver-gsv12.
*  total_consumption =   total_consumption  +

ENDIF.
 l_fyear_fr1   = l_fyear_fr + 1.

    if wa_mver-gjahr =  l_fyear_fr1 .

  total_consumption =   total_consumption  + wa_mver-gsv01 + wa_mver-gsv02 + wa_mver-gsv03 + wa_mver-gsv04
+ wa_mver-gsv05 + wa_mver-gsv06 + wa_mver-gsv07 + wa_mver-gsv08 + wa_mver-gsv09 + wa_mver-gsv10 + wa_mver-gsv11 + wa_mver-gsv12.

endif.

   if  wa_mver-gjahr  =  l_fyear.
total_consumption =   total_consumption  + wa_mver-gsv01 + wa_mver-gsv02 + wa_mver-gsv03 .
*  total_consumption =   total_consumption  +

ENDIF.


endloop.

*
*if total_consumption  = 0.
*
*  wa_disp-matnr = wa_mara-matnr.

 wa_disp_stock-consp  = total_consumption.
*
*  append wa_disp to itab_disp.
*
*  endif.

CLEAR:total_STOCK_FIRST .

*LOOP AT ITAB_MBEWH INTO WA_MBEWH WHERE MATNR = wa_s032_copy-matnr.

*total_STOCK_FIRST =   total_STOCK_FIRST  +  WA_MBEWH-SALK3.

*ENDLOOP.



"ENDING STOCK
IF  total_consumption  is initial .

REFRESH:itab_s032[].
       select MATNR WBWBEST from s032 into CORRESPONDING FIELDS OF table itab_s032

                    where matnr = WA_mara-matnr
                    AND
                    VRSIO =  '000'.

CLEAR:wa_s032.

     loop at itab_s032 into wa_s032 where matnr = wa_MARA-matnr .

     v_stock_VALUE =    v_stock_VALUE + wa_s032-WBWBEST.

     endloop.






*CLEAR:s_matnr.
*REFRESH:s_matnr[].
*s_matnr-sign = 'I'.
*s_matnr-OPTION = 'EQ'.
* s_matnr-low =  wa_MARA-matnr." wa_s032_copy-matnr .
*
*     append s_matnr.
*
*     BREAK-POINT.
*         SUPPRESS DIALOG.
**    SET SCREEN 0.
*
*     SUBMIT RMCB0100
*
**                   WITH SL_WERKS IN R_WERKS
*
*                   WITH SL_matnr in s_matnr
*
*                  WITH SL_SPMON = l_fyear_frCT
*
*                   AND RETURN   EXPORTING LIST TO MEMORY.
*
*
*
*check sy-subrc eq 0.
*
*DATA: ABAPLIST LIKE ABAPLIST OCCURS 0.
*
*CALL FUNCTION 'LIST_FROM_MEMORY'
*
*   TABLES
*
*   LISTOBJECT = ABAPLIST
*
*   EXCEPTIONS
*
*   NOT_FOUND = 1
*
*   OTHERS = 2.
*
*
*
**DATA INT_S000(1024) TYPE C OCCURS 0 WITH HEADER LINE.
*DATA textlines(3072) TYPE C OCCURS 0 WITH HEADER LINE.
*TYPES : BEGIN OF st_budget,
*        row(30) TYPE c,
*          END OF st_budget.
*DATA :ist_budget TYPE STANDARD TABLE OF st_budget,
*      wa_budget TYPE st_budget.
*
*  DATA: BEGIN OF ist_ascitab OCCURS 1,
*         line(1000),
*        END OF ist_ascitab.
*
*  DATA : wa_ascitab LIKE ist_ascitab.
*  REFRESH:ist_ascitab[].
*
*call function 'LIST_TO_ASCI'
*
*   tables
*
*   listobject = ABAPLIST
*   listasci = ist_ascitab
**   listasci = INT_S000
*
*   exceptions
*
*   empty_list = 1
*
*   list_index_invalid = 2
*
*   others = 3.
*
*
*
*  IF NOT ist_ascitab[] IS INITIAL.
*    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
**    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
**{Begin of CR 30007900
*    CLEAR :ist_budget,
*           wa_budget.
*
*    REFRESH ist_budget.
*
*    SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.
*
*    endif.
*
*    READ TABLE ist_budget INTO WA_BUDGET INDEX 6.

ENDIF.


"
*CONDENSE v_stock_VALUE .
  wa_disp_STOCK-WBWBEST  = v_stock_VALUE.
 IF  total_consumption  is initial  and v_stock_VALUE NE '0.00'. " v_stock_VALUE > '100000'.
CLEAR:s_matnr.
REFRESH:s_matnr[].
s_matnr-sign = 'I'.
s_matnr-OPTION = 'EQ'.
 s_matnr-low =  wa_mara-matnr .

     append s_matnr.

     SUBMIT RMCB0100

*                   WITH SL_WERKS IN R_WERKS

                   WITH SL_matnr in s_matnr

                  WITH SL_SPMON = l_fyear_frST

                   AND RETURN EXPORTING LIST TO MEMORY.






check sy-subrc eq 0.

DATA: ABAPLIST LIKE ABAPLIST OCCURS 0.

CALL FUNCTION 'LIST_FROM_MEMORY'

   TABLES

   LISTOBJECT = ABAPLIST

   EXCEPTIONS

   NOT_FOUND = 1

   OTHERS = 2.



DATA INT_S000(1024) TYPE C OCCURS 0 WITH HEADER LINE.
DATA textlines(3072) TYPE C OCCURS 0 WITH HEADER LINE.
TYPES : BEGIN OF st_budget,
        row(30) TYPE c,
          END OF st_budget.
DATA :ist_budget TYPE STANDARD TABLE OF st_budget,
      wa_budget TYPE st_budget.

  DATA: BEGIN OF ist_ascitab OCCURS 1,
         line(1000),
        END OF ist_ascitab.

  DATA : wa_ascitab LIKE ist_ascitab.
  REFRESH:ist_ascitab[].

call function 'LIST_TO_ASCI'

   tables

   listobject = ABAPLIST
   listasci = ist_ascitab


   exceptions

   empty_list = 1

   list_index_invalid = 2

   others = 3.



  IF NOT ist_ascitab[] IS INITIAL.
    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.

    CLEAR :ist_budget,
           wa_budget.

    REFRESH ist_budget.

    SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.

    endif.

    READ TABLE ist_budget INTO WA_BUDGET INDEX 6.
    total_STOCK_FIRST1 = WA_BUDGET-ROW.
     if    total_STOCK_FIRST1 CA '123456789'.
       ELSE.
      CLEAR:total_STOCK_FIRST1.
       ENDIF.
ENDIF.

condense total_STOCK_FIRST1.
wa_disp_STOCK-stock_first1 =  total_STOCK_FIRST1.

IF MOREONELAKHAPP = 'X'.

 IF  total_consumption  is initial  and  v_stock_VALUE > '100000' AND total_STOCK_FIRST1  IS NOT INITIAL.

  append wa_disp_STOCK to itab_disp_STOCK.


  ENDIF.

ENDIF.


IF LEONELAKHAPP = 'X'.


  IF  total_consumption  is initial  and  v_stock_VALUE LE '100000' AND total_STOCK_FIRST1  IS NOT INITIAL.




  if wa_mara-ZZNMFLG is initial.
  append wa_disp_STOCK to itab_disp_STOCK.
endif.

  ENDIF.

  ENDIF.
 clear: wa_mara.
     endloop.

 DESCRIBE TABLE itab_disp_STOCK LINES V_NORECORDS.



  CALL SCREEN 102.
ENDFORM.                    " APPLY_NM
