*--- MAIN PROGRAM: SAPMZMMNONMOVING_UPDATION ---*
*&---------------------------------------------------------------------*
*& Report  SAPMZMMNONMOVING_UPDATION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT SAPMZMMNONMOVING_UPDATION.

INCLUDE MZMMNONMOVING_UPDATIONTOP.
INCLUDE mzmmnonmoving_updationo01.
INCLUDE mzmmnonmoving_updationi01.

INCLUDE mzmmnonmoving_updationf01.

*--- INCLUDE: %_CCXTAB ---*
TYPE-POOL CXTAB .

TYPES:
       CXTAB_COLUMN type scxtab_column,
       CXTAB_CONTROL type scxtab_control,
       CXTAB_TABSTRIP type scxtab_tabstrip.

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL

*--- INCLUDE: MZMMNONMOVING_UPDATIONF01 ---*
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

*--- INCLUDE: MZMMNONMOVING_UPDATIONI01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMNONMOVING_UPDATIONI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
case ok_code.

 when 'BACK' OR 'EXIT' OR 'CANCEL'.

 LEAVE PROGRAM.

when 'EXECUTE'.

  IF REMOVENM = 'X'.


    PERFORM REMOVE_NM.

  ENDIF.

  if APPLYNM = 'X'.


perform apply_nm.
endif.



ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  case ok_code.

 when 'BACK' OR 'EXIT' OR 'CANCEL'.

call screen 100.

when 'APRMAT'.

clear:g_ans.
  PERFORM POP_UP_CONFIRM USING TEXT-001 TEXT-002.

*  IF REMOVENM = 'X'.
*
*
*    PERFORM REMOVE_NM.
*
*  ENDIF.

 if g_ans = '1'.
   clear:COUNT_SUCCESS .
   clear:wa_disp.
   loop at itab_disp into wa_disp where sel = 'X'.


      UPDATE MARA SET ZZMBPR = ''
                     ZZNMFLG = ''
       where matnr = wa_disp-matnr.

     IF sy-subrc = 0.
  ZMM_NM_HISTORY-MATNR = wa_disp-matnr.
 ZMM_NM_HISTORY-OLD_VALUE = 'NM'.
 ZMM_NM_HISTORY-NEW_VALUE = ''.
 ZMM_NM_HISTORY-crtime = sy-uzeit.
 ZMM_NM_HISTORY-CRBY = SY-UNAME.
 ZMM_NM_HISTORY-CRON = SY-DATUM.

MODIFY  ZMM_NM_HISTORY FROM  ZMM_NM_HISTORY.

** update classification data
     SELECT * FROM KLAH UP TO 1 ROWS

 WHERE KLART = '001' AND CLASS = 'Z_ONGC_BLOCK'
 ORDER BY PRIMARY KEY .
 ENDSELECT.
        IF sy-subrc = 0.
            DELETE FROM KSSK
              where objek = wa_disp-matnr
                AND   clint = klah-clint
                AND   klart = '001'.

            DELETE FROM  AUSP
              WHERE  objek = wa_disp-matnr
              AND    KLART = '001'
              AND ATWRT = 'NM'.
        ENDIF.



COUNT_SUCCESS = COUNT_SUCCESS + 1.

ENDIF.



ENDLOOP.

clear:count_success1.

count_success1 = count_success.

  call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  =  count_success1
        importing
          output =   count_success1.


IF COUNT_SUCCESS GE 1.

concatenate 'Congrats !' count_success1 'Records Updated'  into v_sucess  SEPARATED BY space.

MESSAGE s735(zmm) WITH v_sucess.
CALL SCREEN 100.

  ENDIF.

ELSE.

  CALL SCREEN 101.

  ENDIF.


ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_101_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_101_modify INPUT.
if sy-ucomm = 'ALL'.
 wa_DISP-sel = 'X'.
 modify itab_DISP
    from wa_DISP
    index tc_101-current_line transporting sel .

 endif.

   if sy-ucomm = 'DELSEL'.
 wa_DISP-sel = ''.
 modify itab_DISP
    from wa_DISP
    index tc_101-current_line transporting sel .

 endif.


 if sy-ucomm = 'APRMAT' or sy-ucomm = '' .

 modify itab_DISP
    from wa_DISP
    index tc_101-current_line transporting sel .

 endif.


ENDMODULE.                 " TC_101_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.
case ok_code.

 when 'BACK' OR 'EXIT' OR 'CANCEL'.

call screen 100.

when 'APRVAPLY'.


clear:g_ans.
  PERFORM POP_UP_CONFIRM USING TEXT-003 TEXT-004.

*  IF REMOVENM = 'X'.
*
*
*    PERFORM REMOVE_NM.
*
*  ENDIF.

 if g_ans = '1'.
   clear:COUNT_SUCCESS .
   clear:wa_disp_stock.
   loop at itab_disp_stock into wa_disp_stock where sel = 'X'.

IF MOREONELAKHAPP = 'X'.
  clear: wa_mara.

  READ TABLE itab_mara into wa_mara with key matnr  = wa_disp_stock-matnr.

  if wa_mara-ZZNMFLG is initial.
      UPDATE MARA SET ZZMBPR = 'NM'
                    ZZNMFLG = V_GL
      where matnr = wa_disp_stock-matnr.


  else.
       UPDATE MARA SET ZZMBPR = 'NM'
      where matnr = wa_disp_stock-matnr.

    endif.




  IF sy-subrc = 0.

 ZMM_NM_HISTORY-MATNR = wa_disp_stock-matnr.
 ZMM_NM_HISTORY-OLD_VALUE = ''.
 ZMM_NM_HISTORY-NEW_VALUE = 'NM'.
 ZMM_NM_HISTORY-crtime = sy-uzeit.
 ZMM_NM_HISTORY-CRBY = SY-UNAME.
 ZMM_NM_HISTORY-CRON = SY-DATUM.

 MODIFY  ZMM_NM_HISTORY FROM  ZMM_NM_HISTORY.


** update classification data
*     SELECT SINGLE * FROM KLAH
*               WHERE klart  = '001'
*               AND   class  = 'Z_ONGC_BLOCK'.
*        IF sy-subrc = 0.
*            DELETE FROM KSSK
*              where objek = wa_disp-matnr
*                AND   clint = klah-clint
*                AND   klart = '001'.
*
*            DELETE FROM  AUSP
*              WHERE  objek = wa_disp-matnr
*              AND    KLART = '001'
*              AND ATWRT = 'NM'.
*        ENDIF.



COUNT_SUCCESS = COUNT_SUCCESS + 1.
ENDIF.
ENDIF.


IF LEONELAKHAPP = 'X'.


*  clear: wa_mara.
*
*  READ TABLE itab_mara into wa_mara with key matnr  = wa_disp_stock-matnr.
*
*  if wa_mara-ZZNMFLG is initial.
      UPDATE MARA SET
            ZZNMFLG = V_GL
       where matnr = wa_disp_stock-matnr.

*  else.
*
* endif.






  IF sy-subrc = 0.

* ZMM_NM_HISTORY-MATNR = wa_disp_stock-matnr.
* ZMM_NM_HISTORY-OLD_VALUE = ''.
* ZMM_NM_HISTORY-NEW_VALUE = 'NM'.
*  ZMM_NM_HISTORY-crtime = sy-uzeit.
* ZMM_NM_HISTORY-CRBY = SY-UNAME.
* ZMM_NM_HISTORY-CRON = SY-DATUM.
*
* MODIFY  ZMM_NM_HISTORY FROM  ZMM_NM_HISTORY.


** update classification data
*     SELECT SINGLE * FROM KLAH
*               WHERE klart  = '001'
*               AND   class  = 'Z_ONGC_BLOCK'.
*        IF sy-subrc = 0.
*            DELETE FROM KSSK
*              where objek = wa_disp-matnr
*                AND   clint = klah-clint
*                AND   klart = '001'.
*
*            DELETE FROM  AUSP
*              WHERE  objek = wa_disp-matnr
*              AND    KLART = '001'
*              AND ATWRT = 'NM'.
*        ENDIF.



COUNT_SUCCESS = COUNT_SUCCESS + 1.
ENDIF.
ENDIF.


ENDLOOP.

clear:count_success1.

count_success1 = count_success.

  call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  =  count_success1
        importing
          output =   count_success1.


IF COUNT_SUCCESS GE 1.

concatenate 'Congrats !' count_success1 'Records Updated'  into v_sucess  SEPARATED BY space.

MESSAGE s735(zmm) WITH v_sucess.
CALL SCREEN 100.

  ENDIF.

ELSE.

  CALL SCREEN 102.

  ENDIF.


ENDCASE.

ENDMODULE.                 " USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*&      Module  TC_102_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_102_modify INPUT.
if sy-ucomm = 'ALL_APL'.
 wa_DISP_stock-sel = 'X'.
 modify itab_DISP_stock
    from wa_DISP_stock
    index tc_102-current_line transporting sel .

 endif.

   if sy-ucomm = 'DESAPL'.
 wa_DISP_stock-sel = ''.
 modify itab_DISP_stock
    from wa_DISP_stock
    index tc_102-current_line transporting sel .

 endif.


 if sy-ucomm = 'APRVAPLY' or sy-ucomm = ''.

 modify itab_DISP_stock
    from wa_DISP_stock
    index tc_102-current_line transporting sel .

 endif.


ENDMODULE.                 " TC_102_MODIFY  INPUT

*--- INCLUDE: MZMMNONMOVING_UPDATIONO01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMMNONMOVING_UPDATIONO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS '101'.
  SET TITLEBAR '101'.

ENDMODULE.                 " STATUS_0101  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_101'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_101_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_DISP LINES TC_101-lines.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS '102'.
  SET TITLEBAR '102'.

ENDMODULE.                 " STATUS_0102  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_102'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_102_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITAB_DISP_STOCK LINES TC_102-lines.
ENDMODULE.

*--- INCLUDE: MZMMNONMOVING_UPDATIONTOP ---*
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
