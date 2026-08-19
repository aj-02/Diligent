*--- MAIN PROGRAM: MZFIPREPROLE1_PHASEIIO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  IF sy-tcode = 'ZIC_AUTH_FI_REP'.
    GET PARAMETER ID 'ZOLDCODE_FI' FIELD old_ok_code.
    GET PARAMETER ID 'ZMODULEID_FI' FIELD moduleid.
    GET PARAMETER ID 'ZUSERID_FI' FIELD zic_prep_rolereq-userid.
    PERFORM fill_sttab_assign.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ELSE.

    IF get_parm_flag <> 'X'.
      GET PARAMETER ID 'ZOLDCODE_FI' FIELD old_ok_code.
      GET PARAMETER ID 'ZMODULEID_FI' FIELD moduleid.
      GET PARAMETER ID 'ZUSERID_FI' FIELD zic_prep_rolereq-userid.
      GET PARAMETER ID 'ZRSN_CODE_FI' FIELD zic_prep_rolereq-rsn_code.
      GET PARAMETER ID 'ZTELNO_FI' FIELD zic_prep_rolereq-telno.
      GET PARAMETER ID 'ZDOCNO_FI' FIELD zic_prep_rolereq-docno.
      get_parm_flag = 'X'.
      CLEAR sy-ucomm.
    ELSE.
      CLEAR sy-ucomm.
    ENDIF.
*    PERFORM FILL_STTAB.
    SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
  ENDIF.

  PERFORM fill_sttab.   "sy-tcode

  CASE old_ok_code.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
    WHEN 'CROSSCO'.
      SET TITLEBAR 'PREP_TITLE' WITH
      ': Cross Company '.
    WHEN 'CRCROLES'.
      SET TITLEBAR 'PREP_TITLE' WITH ': CRC '.
    WHEN 'CHANGE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Change Request'.
    WHEN 'DISPLAY'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Display Request'.
    WHEN 'DELETE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Delete Request'.
    WHEN 'RELEASE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Release Request'.
    WHEN 'APPROVE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Approve Request'.
    WHEN 'ROLE_DEL'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Delete Role Request'.

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.




*** ********* changes done by Bipin
  DATA lv_docno TYPE zchar12.
  IF zic_prep_rolereq-docno IS INITIAL.
    GET PARAMETER ID 'ZREQNO' FIELD zic_prep_rolereq-docno.
    lv_docno = zic_prep_rolereq-docno.
    DELETE gt_icon1 WHERE docno NE zic_prep_rolereq-docno.
    IF zic_prep_rolereq-docno IS  NOT INITIAL.
      CLEAR zic_prep_rolereq-docno.
    ENDIF.
  ELSE.
    lv_docno = zic_prep_rolereq-docno.
  ENDIF.
  CLEAR : gt_icon.
  SELECT * FROM zgrc_sod_result INTO CORRESPONDING FIELDS OF TABLE gt_icon WHERE docno = lv_docno.
  IF sy-subrc EQ 0.
    gt_icon1[] = gt_icon[].
  ENDIF.
  DESCRIBE TABLE gt_icon1 LINES lv_count.
  IF sy-tcode EQ 'ZIC_AUTH_FI' OR sy-tcode EQ 'ZIC_AUTH_FI_REP'.
    IF lv_count EQ 1.
      gicon = '@08@'. "GREEN
      risk_desc = 'No Risk'.
    ELSEIF lv_count GT 1.
      gicon = '@0A@'. "RED
      risk_desc = 'Risk found'.
    ELSEIF lv_count EQ 0.
      gicon = '@09@'. " YELLOW
      risk_desc = 'Risk Anlys in progress'.
    ENDIF.
  ENDIF.
************* End of changes : bipin shukla

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_header_data OUTPUT.

  IF NOT zic_prep_rolereq-docno IS INITIAL.

    DATA : l_docno LIKE zic_prep_rolereq-docno.

    l_docno = zic_prep_rolereq-docno.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = l_docno
      IMPORTING
        output = l_docno.

    zic_prep_rolereq-docno = l_docno.

  ENDIF.

  IF  g_hd_copied <> 'X'.
*
    IF old_ok_code IS INITIAL AND okcode_100 IS INITIAL.

    ELSE.

      IF ( old_ok_code = 'CREATE' OR old_ok_code = 'CROSSCO' ) AND
                                       okcode_100 IS INITIAL.


      ELSE.

        IF ( old_ok_code = 'CHANGE' ) OR ( old_ok_code = 'DELETE' )
            OR ( old_ok_code = 'RELEASE' )
            OR ( old_ok_code = 'APPROVE' ).
          IF NOT zic_prep_rolereq-docno IS INITIAL.
            PERFORM lock_reqhd.
          ENDIF.
        ENDIF.

**      if sy-subrc = 0 and not ZIC_PREP_ROLEREQ-docno is initial.

*        g_hd_copied = 'X'.

**        clear g_TABCTRL100_itab.
**        refresh g_TABCTRL100_itab.

**        select * from ZIC_PREP_ROLEREI into corresponding
**                  fields of table g_TABCTRL100_itab
**                    where DOCNO = ZIC_PREP_ROLEREQ-docno.

**************************
**       clear g_srno.
**************************

**      endif.

        IF NOT zic_prep_rolereq-docno IS INITIAL.

          SELECT SINGLE * FROM zic_prep_rolereq INTO zic_prep_rolereq
                     WHERE docno = zic_prep_rolereq-docno.

          IF sy-subrc = 0 .

            IF g_l4 = 'X' AND old_ok_code = 'APPROVE'.
              zic_prep_rolereq-radio_fl = 'X'.
            ENDIF.
*start..   Code Addition for Delete Roles By CAB_PAREEK ..26-12-06
            IF  zic_prep_rolereq-delimit = 'X'.
              l_del_request = 'X'.
            ENDIF.


*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

            SELECT DISTINCT moduleid FROM zic_prep_rolerei INTO
           CORRESPONDING FIELDS OF TABLE it_module1 WHERE docno =
           zic_prep_rolereq-docno.
****
            SORT IT_MODULE1 BY MODULEID. READ TABLE it_module1 INDEX 1 INTO wa_module1.
            IF moduleid IS INITIAL.
              moduleid = wa_module1-moduleid.
            ENDIF.
****
            DATA : l_module_lines LIKE sy-index.

            DESCRIBE TABLE it_module1 LINES l_module_lines.

            IF l_module_lines > 1.
              g_mult_module_fl = 'X'.
            ENDIF.

            g_hd_copied = 'X'.
** check line items modulewise/initialise
            g_tablctrl110_copied = ''.
            g_tablctrl111_copied = ''.


**

            IF zic_prep_rolereq-comm_fl = 'X' AND old_ok_code = 'CHANGE'.

              PERFORM verify2.
            ENDIF.

            PERFORM validations.

          ELSE.
            MESSAGE i101(zhelp) WITH zic_prep_rolereq-docno.
          ENDIF.

        ENDIF.

      ENDIF.

      SELECT SINGLE * FROM t500p
                 WHERE persa = zic_prep_rolereq-persa.

      IF sy-subrc = 0.

        zic_prep_rolereq-name1 = t500p-name1.

      ENDIF.


    ENDIF.

  ENDIF.

  SELECT SINGLE * FROM zmm_prep_rsn
             WHERE reason = zic_prep_rolereq-rsn_code.

  IF sy-subrc = 0.

    zic_prep_rolereq-rsn_text1 = zmm_prep_rsn-description.

  ENDIF.

  SELECT SINGLE * FROM zmm_prep_status
             WHERE status_code = zic_prep_rolereq-status .

  IF sy-subrc = 0.

    status_desc = zmm_prep_status-status_desc.

  ENDIF.


  IF zic_prep_rolereq-fundc <> '' AND zic_prep_rolereq-reason1 = ''.

    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-REASON1'.
    MESSAGE i100(zhelp).
  ENDIF.

  PERFORM crc_module_checking.

  PERFORM get_correspondence.

  IF ( old_ok_code = 'CREATE' OR old_ok_code = 'ROLE_DEL' )
     AND zic_prep_rolereq-to_date_auth IS INITIAL.

    zic_prep_rolereq-fr_date_auth = sy-datum.
    zic_prep_rolereq-to_date_auth = '99991231'.
  ENDIF.



ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_attr OUTPUT.
*WRITE icon_green_light AS ICON to gicon.
  CASE old_ok_code.

    WHEN ''.

      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 'CREATE'.




      LOOP AT SCREEN.
************************* START OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION
        IF screen-name = 'GRC_RISK' AND sy-tcode EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'SEC_LEVEL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'GICON' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RAL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'RISK_DESC' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

************************* END OF CHNGES : BY BIPIN SHUKLA : TO HIDE FROM REQUEST CREATION
        IF screen-group1 = 'GP1'.
          IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          IF zic_prep_rolereq-rsn_code = '01'.
            screen-input = 1.
*             perform pop_up_message.
          ELSE.
            CLEAR : zic_prep_rolereq-persa, zic_prep_rolereq-name1.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'. " and moduleid <> ''.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'ROLE_DEL'.

      LOOP AT SCREEN.

        IF screen-group1 = 'GP1'.
          IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          IF zic_prep_rolereq-rsn_code = '01'.
            screen-input = 1.
*             perform pop_up_message.
          ELSE.
            CLEAR : zic_prep_rolereq-persa, zic_prep_rolereq-name1.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID' AND moduleid <> ''.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.


    WHEN 'CHANGE'.

      LOOP AT SCREEN.

        IF screen-group1 = 'GP1'.
          IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
            screen-input = 0.
          ELSE.
            screen-input = 1.
            screen-required = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 0.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

****        if screen-group3 = 'GPC' .
****          screen-invisible = 1.
****          modify screen.
****        endif.

        IF ( screen-name = 'ZIC_PREP_ROLEREQ-PERSA' ).
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
***************************** changes by : bipin shukla : suggested by : praveen kumar :05/09/2013
        IF  screen-name = 'GRC_RAL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
***************************** changes by : bipin shukla : suggested by : praveen kumar :05/09/2013



      ENDLOOP.

    WHEN 'RELEASE'.

      LOOP AT SCREEN.
***************************************        ,Changes By Bipin
        IF screen-name = 'GRC_RISK' AND sy-tcode EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.


        IF  screen-name = 'GICON' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'GRC_RAL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  screen-name = 'GRC_RPL' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name = 'RISK_DESC' AND sy-tcode EQ 'ZIC_AUTH_FI' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
***************************************        ,Changes By Bipin
        IF screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ELSEIF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl <> 'X'.
          screen-active = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT zic_prep_rolereq-fundc IS INITIAL.
            screen-input = 1.
            screen-required = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'APPROVE'.


      LOOP AT SCREEN.

        IF screen-group1 = 'GP1'.
          screen-input = 0.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group2 = 'GP2'.
          screen-input = 1.
          screen-required = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-DISC_FI_FLAG'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_NO'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-OFF_ORDER_DATE'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREQ-FUNDC'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.


*       if screen-name = 'TABCTRL100_DELETE' or
*           screen-name = 'TABCTRL100_INSERT' or
*           screen-name = 'COPY'.
*              screen-input = 0.
*              modify screen.
*       endif.

        IF g_user = 'HF' AND screen-name = 'ZIC_PREP_ROLEREQ-REQ_APPFI_FL'
                 .
          screen-input = 1.
          MODIFY SCREEN.
        ENDIF.
**************************************        CHANGES BY BIPIN

        IF g_user NE 'HF'  AND screen-name = 'GRC_RISK'  AND sy-tcode EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF g_user NE 'HF'  AND screen-name = 'GICON'  AND sy-tcode EQ 'ZIC_AUTH_FI'.
          screen-invisible = 1.
*         SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

*        IF  SCREEN-NAME = 'GRC_RAL'  AND SY-TCODE EQ 'ZIC_AUTH_FI' AND OLD_OK_CODE EQ 'APPROVE'.
*          SCREEN-INVISIBLE = 1.
*         SCREEN-INPUT = 0.
*          MODIFY SCREEN.
*        ENDIF.
*
*        IF  SCREEN-NAME = 'GRC_RPL'  AND SY-TCODE EQ 'ZIC_AUTH_FI' AND OLD_OK_CODE EQ 'APPROVE'.
*          SCREEN-INVISIBLE = 1.
*         SCREEN-INPUT = 0.
*          MODIFY SCREEN.
*        ENDIF.

*IF G_USER = 'HF'  AND SCREEN-NAME = 'GICON' AND SY-TCODE EQ 'ZIC_AUTH_FI'.
*
**  IF ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.
**    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
*    SELECT * FROM ZGRC_SOD_RESULT INTO CORRESPONDING FIELDS OF TABLE GT_ICON WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
*
**  BREAK-POINT.
*    GT_ICON1[] = GT_ICON[].
*
*    DELETE GT_ICON1 WHERE DOCNO NE ZIC_PREP_ROLEREQ-DOCNO.
*
**    IF ZIC_PREP_ROLEREQ-DOCNO IS  NOT INITIAL.
**      CLEAR ZIC_PREP_ROLEREQ-DOCNO.
**    ENDIF.
**  ENDIF.
*  DESCRIBE TABLE GT_ICON1 LINES LV_COUNT.
** CHECK LV_COUNT.
*  IF SY-TCODE NE 'ZIC_AUTH_FI'.
*    IF LV_COUNT EQ 1.
*      GICON = '@08@'. "GREEN
*    ELSEIF LV_COUNT GT 1.
*      GICON = '@09@'. " YELLOW
*    ELSEIF LV_COUNT EQ 0.
*      GICON = '@0A@'. "RED
*    ENDIF.
*  ENDIF.
*          SCREEN-INVISIBLE = 0.
**         SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*      ENDIF.
*  endif.
***************************************      END OF CHANGES


      ENDLOOP.


    WHEN 'DISPLAY'.

      LOOP AT SCREEN.



        IF screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'       OR
*          screen-name = 'MODULEID'    or
           screen-name = 'DETAILS'     OR
           screen-name = 'F'     OR
           screen-name = 'CORR' OR screen-name = 'STAT' OR
           screen-name = 'M'    OR screen-name = 'TABCTRL100_PREVIOUS'
                                OR screen-name = 'TABCTRL100_NEXT' OR screen-name = 'GRC_RAL'
          OR screen-name = 'GRC_RPL' OR screen-name = 'GRC_RISK'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC' AND zic_prep_rolereq-crc_fl = 'X'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-name = 'MODULEID'.
          screen-input = 1.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.
        IF screen-name = 'ZIC_PREP_ROLEREQ-PERSA' AND
                          ok_code_assign = 'ASSIGN'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DELETE'.

      LOOP AT SCREEN.

        IF screen-name = 'ZIC_PREP_ROLEREQ-DOCNO' OR screen-name = 'CORR'
                                                  OR screen-name = 'STAT'
             .
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ELSE.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group3 = 'GPC'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

  ENDCASE.

  IF ok_code_assign = 'ASSIGN'.
    LOOP AT SCREEN.
      IF screen-name = 'ZIC_PREP_ROLEREQ-DOCNO'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.

      IF screen-name = 'ZIC_PREP_ROLEREQ-PERSA'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
*  bEGIN OF CHANGES BY Bipin
*      IF G_USER = 'HF'  AND SCREEN-NAME = 'GRC_RISK' AND SY-TCODE EQ 'ZIC_AUTH_FI_REP'.
*        SCREEN-INVISIBLE = 1.
*         SCREEN-INPUT = 1.
*        MODIFY SCREEN.
*      ENDIF.

      IF g_user = 'HF'  AND screen-name = 'SEC_LEVEL' AND sy-tcode EQ 'ZIC_AUTH_FI_REP' .
        screen-invisible = 1.
*         SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
*      IF G_USER = 'HF'  AND SCREEN-NAME = 'GICON' AND SY-TCODE EQ 'ZIC_AUTH_FI_REP'.
*        SCREEN-INVISIBLE = 1.
**         SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*      ENDIF.
      IF  screen-name = 'RISK_DESC' AND sy-tcode EQ 'ZIC_AUTH_FI' .
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.


*  ENd OF CHANGES BY Bipin
    ENDLOOP.
    save_old_ok_code = old_ok_code.
*    OLD_OK_CODE = 'DISPLAY'.
  ENDIF.

ENDMODULE.                 " scr100_attr  OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tabctrl100_init OUTPUT.

  PERFORM get_user.

**   if g_hd_copied is initial.
**    refresh control 'TABCTRL100' from screen '0100'.

  IF sy-tcode = 'ZIC_AUTH_FI_REP'.
    PERFORM upload1_file.
    GET PARAMETER ID 'ZOLDCODE' FIELD l_old_ok_code.

    IF l_old_ok_code = 'X'.
      GET PARAMETER ID 'ZREQNO' FIELD zic_prep_rolereq-docno.
*      old_ok_code = 'DISPLAY'.
      ok_code_assign = 'ASSIGN'.
    ENDIF.
    ok_code_assign = 'ASSIGN'.
  ENDIF.



  DATA l_fis_initial.
  SET PARAMETER ID 'FIS' FIELD l_fis_initial.
  SET PARAMETER ID 'BUK' FIELD l_fis_initial.
  SET PARAMETER ID 'ZOLDCODE' FIELD sy-ucomm.

**  endif.

ENDMODULE.                    "TABCTRL100_init OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tabctrl100_move OUTPUT.
  MOVE-CORRESPONDING g_tabctrl100_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.

    zic_prep_rolerei-docno = zic_prep_rolereq-docno.

    SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                 zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zfi_prep_roledes-brief_desc TO role_desc.
    ENDIF.

  ENDIF.
ENDMODULE.                    "TABCTRL100_move OUTPUT

*&spwizard: output module for tc 'TABCTRL100'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tabctrl100_get_lines OUTPUT.
  g_tabctrl100_lines = sy-loopc.
ENDMODULE.                    "TABCTRL100_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
*  MOVE 'REQ1' to WA_TAB.
*  APPEND WA_TAB to TAB.
  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
          COLOR COL_HEADING.
  ULINE.
  IF flag_s_fundc = 'X'.
    PERFORM help_list.
  ENDIF.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_120 OUTPUT.
  SET PF-STATUS 'STATUS_120'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE initialize OUTPUT.

  PERFORM get_correspondence.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE splitter_ctrl_vorbereiten1 OUTPUT.

  IF gv_splitter1 IS INITIAL.
    CREATE OBJECT gv_custom_container
      EXPORTING
        container_name = 'C_DIS'.

    CREATE OBJECT gv_splitter1
      EXPORTING
        parent        = gv_custom_container
        orientation   = 1
        sash_position = 1.
  ENDIF.

  IF ( old_ok_code = 'CREATE' )
  OR ( old_ok_code = 'CROSSCO' )
  OR ( old_ok_code = 'CRCROLES' )
  OR ( old_ok_code = 'CHANGE' )
  OR ( ok_code_assign = 'ASSIGN' )
  OR ( old_ok_code = 'RELEASE' )
  OR ( old_ok_code = 'APPROVE' )
  OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X' AND
       zic_prep_rolereq-status <> 'C' ).

    IF gv_splitter2 IS INITIAL.

      CREATE OBJECT gv_custom_container
        EXPORTING
          container_name = 'C_WRT'.


      CREATE OBJECT gv_splitter2
        EXPORTING
          parent        = gv_custom_container
          orientation   = 1
          sash_position = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_vorbereiten1 OUTPUT.

  IF gv_text_editor1 IS INITIAL.
    CREATE OBJECT gv_text_editor1
      EXPORTING
        parent                     = gv_splitter1->bottom_right_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
        wordwrap_to_linebreak_mode = cl_gui_textedit=>false
      EXCEPTIONS
        error_cntl_create          = 1
        error_cntl_init            = 2
        error_cntl_link            = 3
        error_dp_create            = 4
        gui_type_not_supported     = 5.
    flag1 = 'X'.
  ENDIF.
  IF ( old_ok_code = 'CREATE' )
      OR ( old_ok_code = 'CROSSCO' )
      OR ( old_ok_code = 'CRCROLES' )
      OR ( old_ok_code = 'CHANGE' )
      OR ( ok_code_assign = 'ASSIGN' )
      OR ( old_ok_code = 'RELEASE' )
      OR ( old_ok_code = 'APPROVE' )
       OR ( old_ok_code = 'DISPLAY' AND zic_prep_rolereq-comm_fl = 'X'
            AND zic_prep_rolereq-status <> 'C').

    IF gv_text_editor2 IS INITIAL.
      CREATE OBJECT gv_text_editor2
        EXPORTING
          parent                     = gv_splitter2->bottom_right_container
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_windowborder
          wordwrap_to_linebreak_mode = cl_gui_textedit=>false
        EXCEPTIONS
          error_cntl_create          = 1
          error_cntl_init            = 2
          error_cntl_link            = 3
          error_dp_create            = 4
          gui_type_not_supported     = 5.
      flag2 = 'X'.
    ENDIF.
  ENDIF.

  PERFORM text_control_eingabebereit1.
  PERFORM text_control_set_text_table1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr100_col_attrib OUTPUT.

**LOOP AT TABCTRL100-cols INTO cols WHERE index GT 10.
**      cols-invisible = '1'.
**      MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.
**
**LOOP AT TABCTRL100-cols INTO cols WHERE index = 11.
**    cols-invisible = '0'.
**    MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
**ENDLOOP.

ENDMODULE.                 " scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup OUTPUT.

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

  IF NOT g_tabctrl100_itab[] IS INITIAL .

    SORT g_tabctrl100_itab
    BY role_name plant grp sloc receipt_loc approver.
    DELETE ADJACENT DUPLICATES FROM g_tabctrl100_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.

  DESCRIBE TABLE g_tabctrl100_itab LINES tabctrl100-lines.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_110 OUTPUT.

  DESCRIBE TABLE g_tablctrl110_itab LINES tablctrl110-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE g_curr_line_110
.
  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title OUTPUT.

  IF sy-tcode = 'ZIC_AUTH_FI_REP'.
    PERFORM set_title_assign.
  ELSE.
    IF old_ok_code = 'CREATE' AND ( okcode_100 = '' OR
        okcode_100 = 'CREATE' ) .
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.
    IF old_ok_code = 'CHANGE' AND ( okcode_100 = '' OR
        okcode_100 = 'CHANGE' OR okcode_100 = 'LIST' ) .
      IF zic_prep_rolereq-crc_fl = 'X' OR
         zic_prep_rolereq-crossco_fl = 'X'.
      ELSE.
        MOVE 'ATTACH' TO wa_tab-fcode.
        APPEND wa_tab TO it_tab.
      ENDIF.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.

    IF old_ok_code = 'DELETE' AND ( okcode_100 = '' OR
        okcode_100 = 'DELETE' OR okcode_100 = 'LIST' ) .
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.

    IF old_ok_code = 'DISPLAY'
       AND zic_prep_rolereq-comm_fl = 'X'.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ELSE.

      IF old_ok_code = 'DISPLAY' AND ( okcode_100 = '' OR
          okcode_100 = 'DISPLAY' OR okcode_100 = 'LIST' ) .
        MOVE 'ATTACH' TO wa_tab-fcode.
        APPEND wa_tab TO it_tab.
        SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
      ENDIF.

    ENDIF.

    IF old_ok_code = 'APPROVE' AND ( okcode_100 = '' OR
        okcode_100 = 'APPROVE' OR okcode_100 = 'LIST' ) .
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.

    IF old_ok_code = 'ROLE_DEL' AND ( okcode_100 = '' OR
        okcode_100 = 'ROLE_DEL' ) .
      MOVE 'ATTACH' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      MOVE 'LIST' TO wa_tab-fcode.
      APPEND wa_tab TO it_tab.
      SET PF-STATUS 'OPTNS' EXCLUDING it_tab.
    ENDIF.


  ENDIF.   "Endif for sy-tcode

ENDMODULE.                 " set_title  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_dynnr OUTPUT.
  IF dynnr IS INITIAL.
    dynnr = '101'.
  ENDIF.


  CASE moduleid.

    WHEN 'FI'.
      IF old_ok_code = 'ROLE_DEL' OR l_del_request = 'X'.
        dynnr = '0215'.
      ELSE.
        dynnr = '0111'.
      ENDIF.

*  when 'PM'.
*    dynnr = '0111'.
*  when 'PS'.
*    dynnr = '0112'.
*  when 'PP'.
*    dynnr = '0113'.
*  when 'SD'.
*    dynnr = '0114'.

  ENDCASE.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr110_col_attrib OUTPUT.

  LOOP AT tablctrl110-cols INTO cols WHERE index GT 10.
    cols-invisible = '1'.
    MODIFY tablctrl110-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

  LOOP AT tablctrl110-cols INTO cols WHERE index = 11.
    cols-invisible = '0'.
    MODIFY tablctrl110-cols FROM cols INDEX sy-tabix.
  ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_110 OUTPUT.

  IF NOT g_tablctrl110_itab[] IS INITIAL .

    SORT g_tablctrl110_itab
    BY role_name plant grp sloc receipt_loc approver.
    DELETE ADJACENT DUPLICATES FROM g_tablctrl110_itab
    COMPARING role_name plant grp sloc receipt_loc approver.

  ENDIF.

  DESCRIBE TABLE g_tablctrl110_itab LINES tablctrl110-lines.

ENDMODULE.                 " delete_dup_110  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE tablctrl111_init OUTPUT.
  IF g_tablctrl111_copied IS INITIAL AND old_ok_code <> 'CREATE'.
    REFRESH g_tablctrl111_itab[].
    CLEAR   g_tablctrl111_itab.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    SELECT * FROM zic_prep_rolerei
       INTO CORRESPONDING FIELDS
       OF TABLE g_tablctrl111_itab WHERE moduleid = 'FI' AND
                docno = zic_prep_rolereq-docno.
    g_tablctrl111_copied = 'X'.
    REFRESH CONTROL 'TABLCTRL111' FROM SCREEN '0111'.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
MODULE tablctrl111_move OUTPUT.

  MOVE-CORRESPONDING g_tablctrl111_wa TO zic_prep_rolerei.
  IF NOT zic_prep_rolerei-role_name IS INITIAL.
    zic_prep_rolerei-docno = zic_prep_rolereq-docno.
    SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                zic_prep_rolerei-role_name.
    IF sy-subrc = 0 .
      MOVE zfi_prep_roledes-brief_desc TO role_desc.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE tablctrl111_get_lines OUTPUT.
  g_tablctrl111_lines = sy-loopc.
ENDMODULE.                    "TABLCTRL111_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE delete_dup_111 OUTPUT.
  IF NOT g_tablctrl111_itab[] IS INITIAL .

    SORT g_tablctrl111_itab
    BY role_name gl_account bussiness_area fund_ctr_gp jva_grp.
    DELETE ADJACENT DUPLICATES FROM g_tablctrl111_itab
    COMPARING role_name gl_account bussiness_area fund_ctr_gp jva_grp.

  ENDIF.

  DESCRIBE TABLE g_tablctrl111_itab LINES tablctrl111-lines.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tablctrl111_attrib OUTPUT.


  IF old_ok_code = 'CREATE' OR old_ok_code = 'CHANGE'.


    LOOP AT SCREEN.


      IF screen-name = 'ZIC_PREP_ROLEREI-SUB_MODULE'.

        IF old_ok_code <> 'APPROVE' .
          .          screen-input = 1.
*           g_field = 'ZIC_PREP_ROLEREI-SUB_MODULE'.
        ELSE.
          screen-input = 0.
        ENDIF.
      ELSEIF screen-name = 'G_TABLCTRL111_WA-FLAG'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.

      IF screen-name = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
         NOT g_tablctrl111_wa-sub_module IS INITIAL.
        screen-input = 1.
        g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MODIFY SCREEN.
      ENDIF.

*Start code to open for input the fields of lineitem as role selected
      IF NOT g_tablctrl111_wa-role_name IS INITIAL.

        IF old_ok_code = 'CREATE' AND
                zic_prep_rolerei-to_date_auth IS INITIAL.
          zic_prep_rolerei-fr_date_auth = sy-datum.
          zic_prep_rolerei-to_date_auth = zic_prep_rolereq-to_date_auth.
        ENDIF.

        SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                      zic_prep_rolerei-role_name.
        IF sy-subrc <> 0.
          g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          MESSAGE i118(zhelp).
        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-GL_ACCOUNT' .

          IF zfi_prep_roledes-gl_account = 'X' AND
             old_ok_code <> 'APPROVE'.
            screen-input = 1.
            IF g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
              g_field = 'ZIC_PREP_ROLEREI-GL_ACCOUNT'..
            ENDIF.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-gl_account.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-FUND_CTR_GP' .

          IF zfi_prep_roledes-fund_ctr_grp = 'X' AND
             old_ok_code <> 'APPROVE'.
            screen-input = 1.
            IF g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
              g_field = 'ZIC_PREP_ROLEREI-FUND_CTR_GP'.
            ENDIF.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-fund_ctr_gp.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-BUSSINESS_AREA'
.
          IF zfi_prep_roledes-bussiness_area = 'X' AND
             old_ok_code <> 'APPROVE'.
            IF g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
              g_field = 'ZIC_PREP_ROLEREI-BUSSINESS_AREA'.
            ENDIF.
            screen-input = 1.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-bussiness_area.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.
        IF screen-name = 'ZIC_PREP_ROLEREI-JVA_GRP' .
          IF zfi_prep_roledes-jva_grp = 'X' AND
             old_ok_code <> 'APPROVE'.
            screen-input = 1.
            IF g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
              g_field = 'ZIC_PREP_ROLEREI-JVA_GRP'.
            ENDIF.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-jva_grp.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'STATUS_ICON'
.
          IF zfi_prep_roledes-role_sensitivity = 'X' AND
             old_ok_code <> 'APPROVE'.
            screen-input = 0.
            g_tablctrl111_wa-role_sensitivity = 'X'.
*                          break-point.
            icon_name = 'ICON_JAPAN'.
*                          icon_name = 'ICON_AUGP'.
            icon_text =  text-001.
            PERFORM icon_create.

            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-role_sensitivity.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-FR_DATE_AUTH'
.
          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
*                          ZIC_PREP_ROLEREI-FR_DATE_AUTH = sy-datum.
*                          g_TABLCTRL111_wa-fr_date_auth = sy-datum.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-fr_date_auth.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF screen-name = 'ZIC_PREP_ROLEREI-TO_DATE_AUTH'
.
          IF old_ok_code <> 'APPROVE'.
            screen-input = 1.
*                          ZIC_PREP_ROLEREI-To_DATE_AUTH = '99991231'.
*                          g_TABLCTRL111_wa-to_date_auth = '99991231'.
            MODIFY SCREEN.
          ELSE.
            CLEAR zic_prep_rolerei-to_date_auth.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        IF sy-ucomm = 'TABLCTRL111_INSR'.
          g_field = 'ZIC_PREP_ROLEREI-SUB_MODULE'.
        ENDIF.

      ENDIF.
*End code to open for input the fields of line item as per role selected

      IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
        old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.


    ENDLOOP.
  ENDIF.



**
**  loop at screen.
**
**    if ZIC_PREP_ROLEREI-REJ_FL <> ''.
**      screen-input = 0.
**      modify screen.
**    endif.
**
**  endloop.

*Start --  for display the screen control 111
  IF old_ok_code = 'DISPLAY' OR old_ok_code = 'APPROVE' OR old_ok_code =
 'BAC' OR old_ok_code = 'RELEASE' OR ok_code = 'BAC' OR
 ok_code_assign = 'ASSIGN'. "or ok_code = 'SAV'

    LOOP AT SCREEN.
      IF NOT g_tablctrl111_wa-role_name IS INITIAL.

        SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                      zic_prep_rolerei-role_name.
        IF sy-subrc <> 0.
          g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          MESSAGE i118(zhelp).
        ENDIF.

        IF screen-name = 'STATUS_ICON'
.
          IF zfi_prep_roledes-role_sensitivity = 'X' AND
             old_ok_code <> 'APPROVE'.
            screen-input = 0.
            g_tablctrl111_wa-role_sensitivity = 'X'.
*                          break-point.
            icon_name = 'ICON_JAPAN'.
*                          icon_name = 'ICON_AUGP'.
            icon_text =  text-001.
            PERFORM icon_create.

            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
*End --  for display the screen control 111

  IF old_ok_code = 'APPROVE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          old_ok_code = 'APPROVE' AND zic_prep_rolerei-rej_fl_save = ''.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.

      IF NOT g_tablctrl111_wa-role_name IS INITIAL.

        SELECT SINGLE * FROM zfi_prep_roledes WHERE role_type =
                      zic_prep_rolerei-role_name.
        IF sy-subrc <> 0.
          g_field = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          MESSAGE i118(zhelp).
        ENDIF.

        IF screen-name = 'STATUS_ICON'
.
          IF zfi_prep_roledes-role_sensitivity = 'X'.
            screen-input = 0.
            g_tablctrl111_wa-role_sensitivity = 'X'.
*                          break-point.
            icon_name = 'ICON_JAPAN'.
*                          icon_name = 'ICON_AUGP'.
            icon_text =  text-001.
            PERFORM icon_create.

            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

**************************************************************
  IF old_ok_code = 'DELETE'.

    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.


  IF ok_code_assign = 'ASSIGN' AND zic_prep_rolereq-status <> 'C'.

    LOOP AT SCREEN.
      IF screen-name = 'ZIC_PREP_ROLEREI-STATUS'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.

      IF screen-name = 'ZIC_PREP_ROLEREI-REJ_FL'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.


    ENDLOOP.
  ENDIF.


ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_111 OUTPUT.

  DESCRIBE TABLE g_tablctrl111_itab LINES tablctrl111-lines.

  IF NOT g_field IS INITIAL.
    SET CURSOR FIELD g_field LINE g_i.
    CLEAR g_field.
  ELSE.
    IF g_i = 0.
      g_i = 1.
    ENDIF.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-SUB_MODULE' LINE g_i.

  ENDIF.

  CLEAR sy-ucomm.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_col_attrib OUTPUT.
  LOOP AT tablctrl111-cols INTO cols WHERE index GT 15.
    cols-invisible = '1'.
    MODIFY tablctrl111-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDMODULE.                 " scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_210 OUTPUT.
  SET PF-STATUS 'STATUS_210'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_210  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE select_data OUTPUT.

  g_release = zic_prep_rolereq-req_cr_fl.
  g_approve = zic_prep_rolereq-req_app_fl.
  g_approve0 = zic_prep_rolereq-req_app0_fl.
  g_approve1 = zic_prep_rolereq-req_app1_fl.

  SELECT SINGLE * FROM zic_prep_rolereq
                  WHERE docno = zic_prep_rolereq-docno.

  IF zic_prep_rolereq-req_cr_fl IS INITIAL.
    zic_prep_rolereq-req_cr_fl = g_release.
  ENDIF.
  IF zic_prep_rolereq-req_app_fl IS INITIAL.
    zic_prep_rolereq-req_app_fl = g_approve.
  ENDIF.
  IF zic_prep_rolereq-req_app1_fl IS INITIAL.
    zic_prep_rolereq-req_app1_fl = g_approve1.
  ENDIF.

  IF zic_prep_rolereq-req_app0_fl IS INITIAL.
    zic_prep_rolereq-req_app0_fl = g_approve0.
  ENDIF.


  CLEAR : g_release, g_approve, g_approve0, g_approve1.

*  select single * from zic_prep_rolereq
*  where docno = zic_prep_rolereq-docno.

  SELECT * FROM zic_prep_rolerei INTO TABLE ist_item
  WHERE docno = zic_prep_rolereq-docno.

ENDMODULE.                 " SELECT_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA_210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE select_data_210 OUTPUT.
* This module is to display the existing roles of the user

  TYPES: BEGIN OF ty_assign_role,
           uname     LIKE agr_users-uname,
           agr_name  LIKE agr_users-agr_name,
           from_date LIKE agr_users-from_dat,
           to_date   LIKE agr_users-to_dat,
         END OF ty_assign_role.

  DATA: it_assign_role TYPE STANDARD TABLE OF ty_assign_role,
        wa_assign_role TYPE ty_assign_role. "work area
  DATA: username LIKE agr_users-uname.

  SELECT uname agr_name from_dat to_dat FROM agr_users INTO TABLE
         it_assign_role WHERE uname = zic_prep_rolereq-userid.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  WRITE : /'Details of the ROLES Already assigned to User'.
  WRITE : /.
  WRITE : / ' Role Name                     From Date        To Date'.
  WRITE : /.
  LOOP AT it_assign_role INTO wa_assign_role.
    WRITE : / wa_assign_role-agr_name.
    WRITE : wa_assign_role-from_date.
    WRITE : '    '.
    WRITE : wa_assign_role-to_date.
  ENDLOOP.


ENDMODULE.                 " SELECT_DATA_210  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA_211  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE select_data_211 OUTPUT.
* This module is to display the existing roles of the user

  TYPES: BEGIN OF ty_delimit_role,
*         uname like agr_users-uname,
           agr_name  LIKE agr_users-agr_name,
           from_date LIKE agr_users-from_dat,
           to_date   LIKE agr_users-to_dat,
         END OF ty_delimit_role.

  DATA: it_delimit_role TYPE STANDARD TABLE OF ty_delimit_role,
        wa_delimit_role TYPE ty_delimit_role. "work area


*  SELECT uname agr_name from_dat to_dat FROM agr_users INTO TABLE
  SELECT agr_name from_dat to_dat FROM agr_users INTO TABLE
         it_delimit_role WHERE uname = zic_prep_rolereq-userid.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  WRITE : /'Details of the ROLES Already assigned to User'.
  WRITE : /.
  WRITE : / ' Role Name                     From Date        To Date'.
  WRITE : /.
  LOOP AT it_assign_role INTO wa_assign_role.
    WRITE : / wa_delimit_role-agr_name.
    WRITE : wa_delimit_role-from_date.
    WRITE : '    '.
    WRITE : wa_delimit_role-to_date.
  ENDLOOP.


ENDMODULE.                 " SELECT_DATA_211  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE scr111_attrib OUTPUT.
  LOOP AT SCREEN.
    IF old_ok_code = 'APPROVE'.
      IF screen-name = 'TABLCTRL111_DELETE' OR
             screen-name = 'TABLCTRL111_INSERT' OR
             screen-name = 'COPY'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  validate_module  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_module INPUT.



  IF old_ok_code = 'CREATE'  OR
      old_ok_code = 'CHANGE'.

    IF NOT moduleid IS INITIAL.

      SELECT  moduleid FROM zice_prep_module INTO CORRESPONDING FIELDS
    OF TABLE it_module  WHERE zice_prep_module~moduleid = moduleid.

      IF sy-subrc <> 0.
        g_e_fl = 'X'.
        g_field = 'MODULEID'.
        g_i = g_curr_line.
        MESSAGE e054(zhelp).

      ENDIF.

    ENDIF.

  ENDIF.


ENDMODULE.                 " validate_module  INPUT

*&---------------------------------------------------------------------*
*&      Module  set_title_assign  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_title_assign OUTPUT.

  IF l_old_ok_code = 'X' AND g_reset_change <> 'X'.
    PERFORM auth_check.
  ELSE.
    CLEAR g_reset_change.
  ENDIF.


  IF zic_prep_rolereq-status = 'C' OR
       zic_prep_rolereq-status = 'IC'.
**     or
**     zic_prep_rolereq-status = 'IR'..
    MOVE 'ROLE_DEL' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.

    SET PF-STATUS 'OPTNS1' EXCLUDING it_tab..
  ENDIF.

  IF old_ok_code = 'DISPLAY'.
    MOVE 'ROLE_DEL' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    MOVE 'ROLE_CR' TO wa_tab-fcode.
    APPEND wa_tab TO it_tab.
    SET PF-STATUS 'OPTNS1' EXCLUDING it_tab.
  ENDIF.

  SET TITLEBAR 'PREP_TITLE' WITH g_text.

ENDMODULE.                 " set_title_assign  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  value_list_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_list_120 OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  SET PF-STATUS 'STATUS_120' EXCLUDING tab.
  CLEAR : wa_tab.
  REFRESH : tab.
  WRITE :'Selected Values for Company Code :',zic_prep_rolereq-ccode
          COLOR COL_HEADING.
  ULINE.
  IF flag_s_fundc = 'X' AND okcode_100 <> 'SUIM'.
    PERFORM help_list.
  ENDIF.

  IF okcode_100 = 'SUIM'.
    PERFORM help_suim.
  ENDIF.

ENDMODULE.                 " value_list_120  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE select_data_200 OUTPUT.
  SELECT SINGLE * FROM zic_prep_rolereq
  WHERE docno = zic_prep_rolereq-docno.

  SELECT * FROM zic_prep_rolerei INTO TABLE ist_item
  WHERE docno = zic_prep_rolereq-docno.

ENDMODULE.                 " SELECT_DATA_200  OUTPUT
