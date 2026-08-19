*--- MAIN PROGRAM: MZMMMERO01 ---*
***INCLUDE MZMMMERO01 .

*---------------------------------------------------------------------*
*       MODULE TC_81_init OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.
*{   INSERT         OCPK900087                                        1
MODULE tc_83_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9083'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.
*}   INSERT
*{   INSERT         OCDK902852                                        2
MODULE tc_85_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9085'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.

MODULE status_9085 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014.
ENDMODULE.

MODULE tc_86_init OUTPUT.
  IF g_tc_81_copied IS INITIAL.
    IF NOT ( g_tc_81_itab[] IS INITIAL ).
      g_tc_81_copied = 'X'.
    ENDIF.
    REFRESH CONTROL 'TC_81' FROM SCREEN '9086'.
  ENDIF.
*  tc_81-lines = 200.
    tc_81-lines = 100.

ENDMODULE.

MODULE status_9086 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014.
ENDMODULE.
*}   INSERT

*---------------------------------------------------------------------*
*       MODULE TC_81_move OUTPUT                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_move OUTPUT.

*{   INSERT         OCPK900087                                        1
IF g_tc_81_wa-MATNR is NOT INITIAL.

  clear: g_tc_81_wa-steuc.
  SELECT
 STEUC INTO G_TC_81_WA-STEUC FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

     clear: g_tc_81_wa-taxim.
  SELECT
 TAXIM INTO G_TC_81_WA-TAXIM FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

ENDIF.
*}   INSERT

  MOVE-CORRESPONDING g_tc_81_wa TO zmm_mecs.

  IF g_ok_82 NE 'DISPLAY'.
    IF NOT ( zmm_mecs-remrk IS INITIAL ).
      CALL FUNCTION 'ICON_CREATE'
           EXPORTING
                name   = 'ICON_LED_RED'
           IMPORTING
                result = icon.
    ENDIF.
  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.
*{   INSERT         OCPK900087                                        1
MODULE tc_83_move OUTPUT.

*{   INSERT         OCPK900087                                        1
IF g_tc_81_wa-MATNR is NOT INITIAL.

IF g_tc_81_wa-steuc IS INITIAL.
 SELECT
 STEUC INTO G_TC_81_WA-STEUC FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.

ENDIF.


IF g_tc_81_wa-taxim IS INITIAL.
 SELECT
 TAXIM INTO G_TC_81_WA-TAXIM FROM ZMM_CDITEM UP TO 1 ROWS WHERE MATCODE = G_TC_81_WA-MATNR
 ORDER BY PRIMARY KEY .
 ENDSELECT.
ENDIF.



ENDIF.
*}   INSERT

  MOVE-CORRESPONDING g_tc_81_wa TO zmm_mecs.

  IF g_ok_82 NE 'DISPLAY'.
    IF NOT ( zmm_mecs-remrk IS INITIAL ).
      CALL FUNCTION 'ICON_CREATE'
           EXPORTING
                name   = 'ICON_LED_RED'
           IMPORTING
                result = icon.
    ENDIF.
  ENDIF.

  MOVE g_lines TO tc_lines.

  IF NOT ( g_tc_81_wa IS INITIAL ).
    MOVE tc_81-current_line TO tc_81_line.
  ENDIF.

ENDMODULE.
*}   INSERT

*---------------------------------------------------------------------*
*       MODULE TC_81_get_lines OUTPUT                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE tc_81_get_lines OUTPUT.
  g_tc_81_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9081  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9081 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9081  OUTPUT
*{   INSERT         OCDK902852                                        1
MODULE status_9083 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 .
ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9080 OUTPUT.
*{   INSERT         OCPK900087                                        1
 SET PF-STATUS 'ZMM01_1'.
*}   INSERT
*{   DELETE         OCPK900087                                        2
*\  SET PF-STATUS 'ZMM01' .
*}   DELETE
  SET TITLEBAR '001' WITH text-014 text-015.
ENDMODULE.                 " STATUS_9080  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9082 OUTPUT.
  PERFORM pfstatus.
*  SET PF-STATUS 'ZMM03' .
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.                 " STATUS_9082  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_81_attr OUTPUT.

  CASE g_ok_80.

    WHEN 'CREATE' OR 'CHANGE'.

      LOOP AT tc_81-cols INTO htc_cols.
        IF htc_cols-screen-group1 EQ 'INV'.
          htc_cols-invisible = 'X'.
        ELSEIF htc_cols-screen-group1 EQ 'CHN'.
          htc_cols-screen-input = 1.
          htc_cols-screen-active = 1.
        ENDIF.
        MODIFY tc_81-cols FROM htc_cols.

      ENDLOOP.

    WHEN 'DISPLAY'.

      LOOP AT tc_81-cols INTO htc_cols.
        htc_cols-screen-input = 0.
        MODIFY tc_81-cols FROM htc_cols.
      ENDLOOP.
      LOOP AT SCREEN.
        IF SCREEN-group3 = 'GR3'.
          SCREEN-INPUT = 1.
        ELSE.
        screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

  ENDCASE.

ENDMODULE.                 " tc_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_line_items OUTPUT.
  CLEAR g_lines.
  DESCRIBE TABLE g_tc_81_itab LINES g_lines.
ENDMODULE.                 " get_line_items  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE refresh_itabs OUTPUT.
  REFRESH g_tc_81_itab.
  CLEAR  g_docno .
  REFRESH CONTROL 'TC_81' FROM SCREEN '9081'.
  clear r_mat_grp.
  refresh r_mat_grp.
ENDMODULE.                 " refresh_itabs  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  srn_81_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE srn_81_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-BUKRS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        2
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-DOCNO'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        1
        LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSEIF SCREEN-GROUP3 = 'GR3'.
        screen-input = 1.
       ELSE.
         SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
*{   INSERT         OCPK900087                                        3
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
*{   INSERT         OCPK900087                                        4
IF ZMM_MECS-MATNR is NOT INITIAL.

*  select SINGLE  steuc
*    INTO zmm_mecs-steuc
*    FROM



ENDIF.
*}   INSERT


ENDMODULE.                 " srn_81_attr  OUTPUT
*{   INSERT         OCPK900087                                        1
MODULE srn_83_attr OUTPUT.

  IF g_ok_80 EQ 'CHANGE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-BUKRS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        2
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.

  IF g_ok_80 EQ 'CREATE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MEMS-DOCNO'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*{   INSERT         OCPK900087                                        1
        LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
  IF g_ok_80 EQ 'DISPLAY'.
    LOOP AT SCREEN.
      IF screen-group2 = 'VIW'.
        screen-invisible = 1.
      ELSEIF SCREEN-GROUP3 = 'GR3'.
        screen-input = 1.
       ELSE.
         SCREEN-INPUT = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
*{   INSERT         OCPK900087                                        3
  LOOP AT screen.
          IF screen-name = 'ZMM_MECS-STEUC'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

        ENDLOOP.
*}   INSERT
  ENDIF.
*{   INSERT         OCPK900087                                        4
IF ZMM_MECS-MATNR is NOT INITIAL.

*  select SINGLE  steuc
*    INTO zmm_mecs-steuc
*    FROM



ENDIF.
*}   INSERT


ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  move_docno  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE move_docno OUTPUT.
  MOVE g_docno TO zmm_mems-docno.
ENDMODULE.                 " move_docno  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_req_flds  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_req_flds OUTPUT.
Perform get_matnr_desc using g_tc_81_wa-matnr.
loop at screen.
 if screen-group2 EQ 'REQ' and wa_makt-maktx <> ' ' and
    screen-required = '0'.
  screen-required = '1'.
  modify screen.
  exit.
 endif.
endloop.

ENDMODULE.                 " set_req_flds  OUTPUT
*{   INSERT         OCDK902852                                        1
MODULE status_9084 OUTPUT.
  SET PF-STATUS 'ZMM02' EXCLUDING fcode.
  SET TITLEBAR '001' WITH text-014 g_ok_80.
ENDMODULE.

MODULE USER_COMMAND_9084 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.

    WHEN 'BTNC'.

      AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '01'.

      IF SY-SUBRC ne 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9083.

      ENDIF.



      WHEN 'BTNE'.
        AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '02'.

      IF SY-SUBRC NE 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9086.

      ENDIF.




    WHEN 'BTNA'.

      AUTHORITY-CHECK OBJECT 'ZMM_HSNURQ'
    ID 'ZHSNUPD' FIELD '03'.

      IF SY-SUBRC NE 0.

        MESSAGE 'You are not authorized' TYPE 'S'.

        else.
          LEAVE TO SCREEN 9085.

      ENDIF.




       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.


  ENDCASE.


ENDMODULE.

MODULE USER_COMMAND_9085 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.



       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.

      when 'APPGET'.

        perform get_data.

        when 'HSNUPD'.

       CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '1'.

                        WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.


                  LOOP AT  G_TC_81_ITAB INTO G_TC_81_WA.
                        clear: wa_marc.

                        select SINGLE *
                          INTO wa_marc
                          from marc
                          where matnr = G_TC_81_WA-MATNR AND
                                werks = G_TC_81_WA-WERKS.

                          IF wa_marc IS NOT INITIAL.
                                    wa_marc-STEUC = G_TC_81_WA-STEUC.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
* S/4 (note 2206980): direct MARC update -> BAPI_MATERIAL_SAVEDATA (STEUC -> PLANTDATA-CTRL_CODE)
*                                    modify marc from wa_marc.
                            DATA: ls_head_m1 TYPE bapimathead, ls_marc_m1 TYPE bapi_marc,
                                  ls_marcx_m1 TYPE bapi_marcx, ls_ret_m1 TYPE bapiret2,
                                  lv_mtart_m1 TYPE mara-mtart, lv_mbrsh_m1 TYPE mara-mbrsh.
                            SELECT SINGLE mtart, mbrsh FROM mara INTO (@lv_mtart_m1, @lv_mbrsh_m1) WHERE matnr = @G_TC_81_WA-MATNR.
                            CLEAR: ls_head_m1, ls_marc_m1, ls_marcx_m1, ls_ret_m1.
                            ls_head_m1-material_long = G_TC_81_WA-MATNR.
                            ls_head_m1-ind_sector    = lv_mbrsh_m1.
                            ls_head_m1-matl_type     = lv_mtart_m1.
                            ls_marc_m1-plant     = G_TC_81_WA-WERKS.
                            ls_marc_m1-ctrl_code = G_TC_81_WA-STEUC.
                            ls_marcx_m1-plant     = G_TC_81_WA-WERKS.
                            ls_marcx_m1-ctrl_code = 'X'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
                            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'  "#EC CI_USAGE_OK[2438131]
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
                              EXPORTING headdata = ls_head_m1 plantdata = ls_marc_m1 plantdatax = ls_marcx_m1
                              IMPORTING return = ls_ret_m1.
                            IF ls_ret_m1-type CA 'EA'.
                              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                            ELSE.
                              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
                            ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC

                          ENDIF.



                          clear: wa_mlan, gv_COUNC.

                          select single  counc
                            INTO GV_COUNC
                            from t001w
                            where werks = G_TC_81_WA-WERKS .

                          select SINGLE *
                          INTO wa_mlan
                          from mlan
                          where matnr = G_TC_81_WA-MATNR AND
                                ALAND = gv_counc.

                          IF wa_mlan IS NOT INITIAL.
                                    wa_mlan-TAXIM = G_TC_81_WA-TAXIM.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
* S/4 (note 2206980): direct MLAN update -> BAPI_MATERIAL_SAVEDATA (TAXIM -> TAXCLASSIFICATIONS-TAX_IND, DEPCOUNTRY=ALAND)
*                                    modify mlan from wa_mlan.
                            DATA: ls_head_m2 TYPE bapimathead, ls_ret_m2 TYPE bapiret2,
                                  lt_tax_m2 TYPE STANDARD TABLE OF bapi_mlan, ls_tax_m2 TYPE bapi_mlan,
                                  lv_mtart_m2 TYPE mara-mtart, lv_mbrsh_m2 TYPE mara-mbrsh.
                            SELECT SINGLE mtart, mbrsh FROM mara INTO (@lv_mtart_m2, @lv_mbrsh_m2) WHERE matnr = @G_TC_81_WA-MATNR.
                            CLEAR: ls_head_m2, ls_ret_m2, ls_tax_m2. REFRESH lt_tax_m2.
                            ls_head_m2-material_long = G_TC_81_WA-MATNR.
                            ls_head_m2-ind_sector    = lv_mbrsh_m2.
                            ls_head_m2-matl_type     = lv_mtart_m2.
                            ls_tax_m2-depcountry = gv_counc.
                            ls_tax_m2-tax_ind    = G_TC_81_WA-TAXIM.
                            APPEND ls_tax_m2 TO lt_tax_m2.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
                            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'  "#EC CI_USAGE_OK[2438131]
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
                              EXPORTING headdata = ls_head_m2
                              IMPORTING return = ls_ret_m2
                              TABLES taxclassifications = lt_tax_m2.
                            IF ls_ret_m2-type CA 'EA'.
                              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
                            ELSE.
                              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
                            ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC

                          ENDIF.





                  ENDLOOP.

               MESSAGE 'Request has been approved' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.

        when 'HSNREJ'.


        CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '2'.

                         WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

               MESSAGE 'Request has been rejected' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.


  ENDCASE.


ENDMODULE.

MODULE USER_COMMAND_9086 INPUT.
G_OK_80 = SY-UCOMM.
  CASE G_OK_80.



       WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      PERFORM CONFIRM_USER_ACTION.

      when 'CHGGET'.

        perform get_dataC.


        when 'HSNSAV'.

       CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_C.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                            FLG = 0.

                            perform check_data.



                            IF FLG EQ 0.

                              WA_ZMM_HSN_UPD-CHANGED_by = sy-uname.
                              WA_ZMM_HSN_UPD-CHANGED_ON = sy-datum.

                              modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

                              clear: it_zmm_hsn_upd_itm, wa_zmm_hsn_upd_itm.

                              delete from  zmm_hsn_upd_itm where  req_no = docno_c.

                               sort g_tc_81_itab by matnr werks.
                                delete ADJACENT DUPLICATES FROM g_tc_81_itab.

                                 LOOP AT  G_TC_81_ITAB INTO G_TC_81_WA.

                        clear: wa_zmm_hsn_upd_itm.

                        wa_zmm_hsn_upd_itm-mandt = sy-mandt.
                        wa_zmm_hsn_upd_itm-req_no = docno_c.
                        wa_zmm_hsn_upd_itm-matnr = g_tc_81_wa-matnr.
                        wa_zmm_hsn_upd_itm-werks = g_tc_81_wa-werks.
                        wa_zmm_hsn_upd_itm-steuc = g_tc_81_wa-steuc.
                        wa_zmm_hsn_upd_itm-taxim = g_tc_81_wa-taxim.
                       insert into zmm_hsn_upd_itm values wa_zmm_hsn_upd_itm.

                  ENDLOOP.

               MESSAGE 'Request has been saved' TYPE  'S'.

               CLEAR: DOCNO_C, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                            ENDIF.


















                  ENDIF.


           ENDIF.

        when 'HSNREJ'.


        CLEAR:  WA_ZMM_HSN_UPD.
         SELECT  SINGLE *
           INTO WA_ZMM_HSN_UPD
           FROM ZMM_HSN_UPD

           WHERE REQ_NO = DOCNO_A.

           IF WA_ZMM_HSN_UPD IS INITIAL.


             MESSAGE 'No data found' TYPE  'S'.

             else.
                  IF  WA_ZMM_HSN_UPD-req_st eq '1'.

                     MESSAGE 'Request already approved' TYPE  'S'.


                    elseif  WA_ZMM_HSN_UPD-req_st eq '2'.

                       MESSAGE 'Request already rejected ' TYPE  'S'.


                      elseif  WA_ZMM_HSN_UPD-req_st eq '3'.

                         MESSAGE 'Request has been deleted' TYPE  'S'.



                      else.

                        WA_ZMM_HSN_UPD-req_st = '2'.

                         WA_ZMM_HSN_UPD-RELEASED_BY = sy-uname.
                        WA_ZMM_HSN_UPD-RELEASED_ON = sy-datum.
               modify ZMM_HSN_UPD from WA_ZMM_HSN_UPD.

               MESSAGE 'Request has been rejected' TYPE  'S'.

               CLEAR: DOCNO_A, WA_ZMM_HSN_UPD,IT_ZMM_HSN_UPD_ITM,WA_ZMM_HSN_UPD_ITM,G_TC_81_ITAB,G_TC_81_WA.

                  ENDIF.


           ENDIF.


  ENDCASE.


ENDMODULE.
*}   INSERT
