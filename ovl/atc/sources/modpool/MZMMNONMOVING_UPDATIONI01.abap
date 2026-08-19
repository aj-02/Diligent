*--- MAIN PROGRAM: MZMMNONMOVING_UPDATIONI01 ---*
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
