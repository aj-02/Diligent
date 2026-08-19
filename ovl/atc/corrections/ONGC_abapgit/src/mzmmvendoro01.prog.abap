*----------------------------------------------------------------------*
***INCLUDE MZMMVENDORO01 .
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 24/11/2008      <RD1K960611>    SAB_SUMODH
*
*1)Literal Error Modified.
************************************************************************
*
*TYPES: BEGIN OF TY_LFB1,
*        LIFNR TYPE LFB1-LIFNR,
*        BURKS TYPE LFB1-BUKRS,
*      END OF TY_LFB1,
*
*      BEGIN OF TY_GST_ITEM,
*        sel TYPE C,
*        VENDOR_NO TYPE LIFNR,
*        COMPANY_CODE TYPE ZMM_GST_UPD_ITEM-COMPANY_CODE,
*        VEN_CLASS TYPE ZMM_GST_UPD_ITEM-VEN_CLASS,
*        GST_NO TYPE ZMM_GST_UPD_ITEM-GST_NO,
*        REMARKS TYPE ZMM_GST_UPD_ITEM-REMARKS,
*        REQUEST type ZMM_GST_UPD_ITEM-REQUEST_NO,
*
*      END OF ty_gst_item.
*DATA  : BEGIN OF it_upd_ITEM OCCURS 0,
*           sel TYPE C,
*        VENDOR_NO TYPE LIFNR,
*        COMPANY_CODE TYPE ZMM_GST_UPD_ITEM-COMPANY_CODE,
*        VEN_CLASS TYPE ZMM_GST_UPD_ITEM-VEN_CLASS,
*        GST_NO TYPE ZMM_GST_UPD_ITEM-GST_NO,
*        REMARKS TYPE ZMM_GST_UPD_ITEM-REMARKS,
*        REQUEST type ZMM_GST_UPD_ITEM-REQUEST_NO,
*         END OF it_upd_ITEM.
*
*
*
*DATA : it_zmm_gst_upd TYPE TABLE OF ZMM_GST_UPD,
*       wa_zmm_gst_upd TYPE ZMM_GST_UPD,
**       it_upd_ITEM TYPE standard table of TY_GST_ITEM,
*       wa_upd_ITEM TYPE TY_GST_ITEM,
*       it_zmm_gst_upd1 TYPE TABLE OF ZMM_GST_UPD,
*       wa_zmm_gst_upd1 TYPE ZMM_GST_UPD,
*       IT_LFB1 TYPE TABLE OF TY_LFB1,
*       WA_LFB1_1 TYPE TY_LFB1.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_UPD' ITSELF
*CONTROLS: TC_UPD TYPE TABLEVIEW USING SCREEN 9031.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_UPD'
*DATA:     G_TC_UPD_LINES  LIKE SY-LOOPC.


*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       gui for screen 100
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CLEAR : ist_gui.
  REFRESH ist_gui.
  IF ist_gui[] IS INITIAL.
    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
  ENDIF.
  IF sy-ucomm = 'EXTN'.
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
  ENDIF.

  PERFORM authority_check.

  ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005
  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "+SP005

  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.
  SET TITLEBAR 'TITLE1'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE status_0931 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0931 OUTPUT.
* Begin of <> on 10.12.12
*  SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
*  SET TITLEBAR 'TITLE15'.
* End of <> on 10.12.12
* Begin of <> on 04042012   Commented / Uncommented on 19062012 20062012 Uncommented on 28072012
* Begin of <> on 16122010
  DATA : l_main, "(C),
         l_c1  , "(B),
         l_pre.  "(A).
* End of <> on 16122010
  CLEAR : ist_gui.
  REFRESH ist_gui.
  REFRESH g_tc319_itab.
* Begin of <> on 10122010
  SHIFT g_cpf LEFT DELETING LEADING '0'.
  SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
  WHERE uname = g_cpf.
  READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
  IF sy-subrc = 0.
    l_main = 'X'.
  ENDIF.

  READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name = 'D:FI_VEM_BANKDETAILS_PREAUDIT'. "'FI_VEM_MASTER_CREATE_XXX'. 15122010
  IF sy-subrc = 0.
    l_pre = 'X'.

  ENDIF.

  READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name = 'D:FI_VEM_BANKDETAILS_EMD'. "'FI_VEM_MASTER_CREATE_XXX'. 15122010
  IF sy-subrc = 0.
    l_c1 = 'X'.

  ENDIF.

  READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name = 'D:FI_VEM_MAINTAIN_EMD'. "'FI_VEM_MASTER_CREATE_XXX'. 15122010
  IF sy-subrc = 0.
    l_pre = 'X'.

  ENDIF.


  READ TABLE ist_agr_users INTO wa_agr_users WITH KEY agr_name = 'D:FI_FM_PR_RELEASE_C1'.
*  READ TABLE ist_agr_users into wa_agr_users with key agr_name = 'C:SM_FIFM_PR_RELEASE_C1'.
  IF sy-subrc = 0.
    l_c1 = 'X'.
*    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui .
*
*
*    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
*    SET TITLEBAR 'TITLE15'.

*      else.        "14122010 "15122010 16122010
*        SET PF-STATUS 'PF_IFSC' . "EXCLUDING ist_gui.
*        SET TITLEBAR 'TITLE15'.
  ENDIF.
* Begin of <> on 16122010
  IF  l_main = 'X' AND  l_c1 = 'X' AND l_pre = 'X' .
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui .  270911
    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui . "270911

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.

  ELSEIF  l_c1 = 'X'   AND  l_pre = 'X'  .
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui .  "270911
    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui . "270911

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.

  ELSEIF  l_main = 'X' AND  l_c1 = 'X'.
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui .   "270911
    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui . "270911

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.


  ELSEIF  l_main = 'X' AND  l_pre = 'X'.
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui .  "270911
    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui . "270911
    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.


  ELSEIF  l_main = 'X'.
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui .  "270911
    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui . "270911

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.

  ELSEIF  l_c1 = 'X'.
    ist_gui-fcode = 'CREATE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHANGE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui .   "270911
    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui . "270911

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.

  ELSEIF  l_pre = 'X'.
    ist_gui-fcode = 'RELEASE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui .

    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
    SET TITLEBAR 'TITLE15'.
  ELSE.
*      MESSAGE e505(zmm).
    MESSAGE 'you are not authorized to use this option' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 100.

* Begin of <> on 06072011
* Begin of <> on 24122010         "14022011   "16022011
*  else.
*
*    SET PF-STATUS 'PF_IFSC'. " EXCLUDING ist_gui.
*    SET TITLEBAR 'TITLE15'.
* End of <> on 24122010
* End of <> on 06072011
  ENDIF.
* End of <> on 16122010
* End of <> on 04042012 Commented / Uncommented 19062012 20062012 Uncommented on 28072012


* End of <> on 10122010
*  IF ist_gui[] IS INITIAL.
*    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
*  ENDIF.
*  IF sy-ucomm = 'EXTN'.
*    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
*  ENDIF.
*
*  PERFORM authority_check.
*
*  ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui .
*  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
* bEGIN OF COMMENT ON 10122010
*  shift g_cpf left deleting leading '0'.
*  select single * from zauth_user into wa_zauth_user
*                                 where bname = g_cpf
*                          and primary_module = 'FI'.
*  if sy-subrc <> 0.
**      ist_gui-fcode = 'RELEASE'  . APPEND ist_gui . CLEAR ist_gui .
**      ist_gui-fcode = 'APPROVED' . APPEND ist_gui . CLEAR ist_gui .
**      ist_gui-fcode = 'ASSIGN'   . APPEND ist_gui . CLEAR ist_gui .
*
*    SET PF-STATUS 'PF_IFSC' EXCLUDING ist_gui.
*    SET TITLEBAR 'TITLE15'.
**        message e105(zfi).
*
*  else.
*    SET PF-STATUS 'PF_IFSC' . "EXCLUDING ist_gui.
*    SET TITLEBAR 'TITLE15'.
*  endif.
* eND OF <> ON 10122010
*  SET PF-STATUS 'PF_IFSC' . "EXCLUDING ist_gui.
*  SET TITLEBAR 'TITLE15'.
*  IF g_okcode931 EQ 'CRBK'.
*    IF n_rb1 = 'X'.
*      CALL SCREEN 0319.
**      CALL SCREEN 0319. "Commented by ss on 22/2/21
*    ELSEIF e_rb1 = abap_true.
*      CALL SCREEN 0321.
*    ENDIF.


*  IF g_okcode931 NE 'CREATE' and cb_nor ne 'X' and cb_emd ne 'X'.
*    LOOP AT SCREEN.
**checkbox is invisible when ok_code is not equal to 'CREATE'
*      IF screen-name = 'CB_NOR'.
*        screen-input = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*      ELSEIF screen-name = 'CB_EMD'.
*        screen-input = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*      ENDIF.
*
*    ENDLOOP.
*  ELSE.
*
*    LOOP AT SCREEN.
*
**checkbox is visible when ok_code is equal to 'CREATE'
*      IF screen-name = 'CB_EMD'.
*        screen-active = 1.
*        screen-invisible = 0.
*        MODIFY SCREEN.
*
*      ELSEIF screen-name = 'CB_NOR' .
*
*        screen-active = 1.
*        screen-invisible = 0.
*        MODIFY SCREEN.
*
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
ENDMODULE.                 " STATUS_0931  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       gui for screen 200
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  DATA :l_vend_count(2) TYPE n.
  CLEAR : ist_vend,l_vend_count.



  PERFORM gui_status_set.

  CASE g_trans_mode.
    WHEN 'N'.
      SET TITLEBAR 'TITLE2'.
      IF NOT ist_vend[] IS INITIAL.
        DESCRIBE TABLE ist_vend LINES l_vend_count.
        READ TABLE ist_vend INDEX l_vend_count.
        IF sy-subrc IS INITIAL.
          IF ist_vend-fnd_flg = 'X'.
            PERFORM set_pfstatus USING 'SAVE'.
            SET TITLEBAR 'TITLE2'.
          ELSEIF ist_vend-fnd_flg = ' '.
            IF ist_lfa1[] IS INITIAL.
              CHECK ok_code NE 'RETI'.
              PERFORM set_pfstatus USING 'RETI'.
            ELSE.
              PERFORM set_pfstatus USING 'CLEA'.
              PERFORM set_pfstatus USING 'RETI'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'M'.
      SET TITLEBAR 'TITLE5'.
      IF NOT ist_vend[] IS INITIAL.
        IF g_ltext_mod = 'X'.
          PERFORM set_pfstatus USING 'SAVE'.
        ENDIF.
        CLEAR ist_vend.
        READ TABLE ist_vend INDEX g_vend.
        IF sy-subrc IS INITIAL.
          IF ist_vend-fnd_flg = ' '.
            IF ist_lfa1[] IS INITIAL .
              CHECK ok_code NE 'RETI'.
              PERFORM set_pfstatus USING 'RETI'.
            ELSE.
              PERFORM gui_status_set.
              PERFORM set_pfstatus USING 'CLEA'.
              PERFORM set_pfstatus USING 'RETI'.
            ENDIF.
            SET TITLEBAR 'TITLE5'.
          ELSEIF ist_vend-fnd_flg = 'M'.
            IF g_ans = 2 .
            ELSE.
              PERFORM set_pfstatus USING 'SAVE'.
            ENDIF.
            SET TITLEBAR 'TITLE5'.
          ELSE.
            READ TABLE ist_vend WITH KEY fnd_flg = 'M'.
            IF sy-subrc IS INITIAL.
              PERFORM set_pfstatus USING 'SAVE'.
              SET TITLEBAR 'TITLE5'.
              """""""""""""""""""""""""
              "ADD BY LIPSY

            ELSE.

              IF sy-uname+0(3) = 'CMM'.

                PERFORM set_pfstatus USING 'SAVE'.

              ENDIF.

              "EADD BY LIPSY
              """"""""""""""""""""""

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      """"""""""""""""""""""""""""
      "added by lipsy on 6.07.2013 RD1K997727
      DELETE  ist_gui WHERE fcode = 'ATCH' OR fcode = 'LIST'.
      "end of addition  by lipsy on 6.07.2013 RD1K997727
      """""""""""""""""""""""""""""""""""
    WHEN 'X'.
      SET TITLEBAR 'TITLE3'.
      IF NOT ist_vend[] IS INITIAL.
        PERFORM set_pfstatus USING 'DELE'.
      ENDIF.
      """""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 6.07.2013 RD1K997727
      DELETE  ist_gui WHERE  fcode = 'LIST'.
      "end of addition  by lipsy on 6.07.2013 RD1K997727
      """"""""""""""""""""""""""""""""""""""""""""""""""""
    WHEN 'R'.
      SET TITLEBAR 'TITLE4'.
      IF NOT ist_vend[] IS INITIAL.
        PERFORM set_pfstatus USING 'RELS'.
      ENDIF.
      """"""""""""""""""
      "added by lipsy on 6.07.2013 RD1K997727
      DELETE  ist_gui WHERE  fcode = 'LIST'.
      "end of addition  by lipsy on 6.07.2013 RD1K997727
      """"""""""""""""""""""""""""
    WHEN 'D'.
      SET TITLEBAR 'TITLE6'.

      """"""""""""""""""""""""""""
      "added by lipsy on 6.07.2013 RD1K997727
      DELETE  ist_gui WHERE  fcode = 'LIST'.
      "end of addition  by lipsy on 6.07.2013 RD1K997727
      """""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""
      """""""added by lipsy on 12.01.2016
      IF sy-ucomm = 'CHNGREPL' OR v_user_comm = 'CHNGREPL'.
        IF g_report_flag = 'X'.
*        if ZMM_HVENCRT-released_by is initial.
          DELETE  ist_gui WHERE  fcode = 'SAVE'.

*   endif.
        ENDIF.
      ENDIF.
      ""end of addition by lipsy on 12.01.2016
      """"""""""""""""""""""""""""""""

    WHEN 'A'.

      SET TITLEBAR 'TITLE7'.
      IF NOT ist_vend[] IS INITIAL.
        PERFORM set_pfstatus USING 'ASSN'.
      ENDIF.
      """""""""""""""""""""""""""""""""
      "added by lipsy on 6.07.2013 RD1K997727
      DELETE  ist_gui WHERE  fcode = 'LIST'.
      "end of addition  by lipsy on 6.07.2013 RD1K997727
      """""""""""""""""""""""""""""""""""""
  ENDCASE.

  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       set screen attributes for 210 screen
*----------------------------------------------------------------------*
MODULE set_screen_attr OUTPUT.
  LOOP AT SCREEN.
    CASE g_trans_mode.
      WHEN 'N'.
        IF screen-group1 = 'G2' OR screen-group1 = 'G3' OR
           screen-group1 = 'G5' OR screen-group1 = 'G6'.
          screen-input = '0'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'S1' AND NOT ist_lfa1[] IS INITIAL.
          screen-input = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.



      WHEN 'M' OR 'D' OR 'X' OR 'R' OR 'A'.
        IF  screen-group1 = 'G2' OR screen-group1 = 'G4' OR
            screen-group1 = 'G1' OR screen-group1 = 'G5' OR
            screen-group1 = 'G6' OR screen-group1 = 'L1'.
          IF zmm_hvencrt-reqno = ' '.
            screen-input = '0'.
            screen-invisible = '1'.
            MODIFY SCREEN.
            CONTINUE.
          ELSE.
            screen-input = '0'.
            IF ( g_trans_mode = 'D' OR g_trans_mode = 'X' OR
                 g_trans_mode = 'A' ) AND
               ( screen-group1 = 'G5' OR screen-group1 = 'G6' ).
              screen-invisible = '0'.
            ENDIF.
            IF screen-group1 = 'L1'.
              screen-input = '1'.
            ENDIF.
            MODIFY SCREEN.
            CONTINUE.
          ENDIF.
        ENDIF.
        IF screen-group1 = 'G3' AND zmm_hvencrt IS INITIAL.
          screen-input = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'S1' AND NOT ist_lfa1[] IS INITIAL.
          screen-input = '1'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.

    IF screen-group1 = 'G1'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'S1' AND g_src_button = 'X'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

* Following code added by GCU on 25.01.06
  LOOP AT SCREEN.
    IF screen-name = 'ZMM_HVENCRT-REQNO'.
      IF zmm_hvencrt-reqno <> ''.
*        IF g_trans_mode <> 'A'.     "-RK 31.05.06
        screen-input = 0.
        MODIFY SCREEN.
*        ENDIF.                       "-RK 31.05.06
      ENDIF.

      IF g_trans_mode = 'A' .
        IF g_assign = 'X'.
          screen-input = 0.
          g_assign = ''.
        ELSE.
          screen-input = 1.
          g_assign = 'X'.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""
    "ADDED BY LIPSY ON 4.11.2015  RD1K998995
    IF g_trans_mode = 'N' .
      IF screen-name = 'ZMM_HVENCRT-UDYOG_AADHAAR'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    "END OF ADDITION BY LIPSY ON 4.11.2015  RD1K998995


    """"""""""""""""""""""""""""""""""""""""""

    """"""""""""""""
    "added by lipsy on 2.12.2015 RD1K999141
    IF g_trans_mode = 'M' .
      IF zmm_hvencrt-reqno IS NOT INITIAL.
        IF  sy-uname+0(3) = 'CMM'.
          IF screen-name = 'ZMM_HVENCRT-REQCL'.
            screen-input = '1'.
            screen-invisible = '0'.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF g_report_flag = 'X'.
      IF  sy-uname+0(3) = 'CMM'.
        IF screen-group1 = 'RPC'.
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.

        """""""""""""""""""""""""""
        "added by lipsy 8.02.2016
      ELSE.
        IF screen-group1 = 'RPC'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
        "eadded by lipsy 8.02.2016
        """""""""""""""""""""""""""""
      ENDIF.

      """""""""""""""""
*   LIPSY 6.1.2016
      IF  sy-uname+0(3) = 'CMM'.
        IF screen-name = 'RELEASE_THRU_REPORT' .
          screen-invisible = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF sy-ucomm = 'CHNGREPL' OR  v_user_comm = 'CHNGREPL'.
        IF g_trans_mode = 'D'.
          IF screen-name = 'ZMM_HVENCRT-REQCL'.
            IF zmm_hvencrt-reqcl = 'N' OR zmm_hvencrt-reqcl = 'IR' .
*   if ZMM_HVENCRT-released_by is initial.
              screen-input = '1'.
              g_trans_mode = 'M'.
*   endif.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

* *LIPSY 6.1.2016
      """"""""""""""""""

    ELSE.
      IF screen-group1 = 'RPC'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.
    "end of addition by lipsy on 2.12.2015 RD1K999141
    """""""""""""""""

  ENDLOOP.
*  end of add - gcu

  DESCRIBE TABLE ist_lfa1 LINES g_rec_found.
  tab_srch-lines = g_rec_found.
  tab_ctl-lines = '99'.
ENDMODULE.                 " SET_SCREEN_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       Initialize screen 210
*----------------------------------------------------------------------*
MODULE init_screen OUTPUT.
  DATA l_tdname LIKE stxh-tdname.
  CONCATENATE 'NOTE' zmm_hvencrt-reqno INTO l_tdname.

  CASE g_trans_mode.
    WHEN 'N'.
      zmm_hvencrt-erfdt = sy-datum.
      zmm_hvencrt-ernam = sy-uname.

      """"""""uncommented by lipsy on 29.05.2013
* Begin of Comment on 17052013
***   """"added by lipsy on 19.02.2013 for telephone no
      SELECT * FROM  pa9205 INTO
   CORRESPONDING FIELDS OF TABLE it_9205
   WHERE pernr = sy-uname  AND
         subty = '01' AND
         endda = '99991231' .

      IF sy-subrc = 0.          "" It means PHONE NO. has been found

        SORT  it_9205 BY begda DESCENDING .
        READ TABLE it_9205 INTO wa_9205 INDEX 1  .
        zmm_hvencrt-tel = wa_9205-zphone+1(10).

      ENDIF.


      SELECT bname persnumber
      FROM usr21
      INTO CORRESPONDING FIELDS OF TABLE itab_usr21
                        WHERE bname = sy-uname.

      READ TABLE itab_usr21 INTO wa_usr21 INDEX 1.

      IF sy-subrc EQ 0.
        SELECT persnumber name_text
       FROM adrp
       INTO CORRESPONDING FIELDS OF TABLE itab_adrp
       WHERE persnumber = wa_usr21-persnumber.

        READ TABLE itab_adrp INTO wa_adrp INDEX 1.  "#EC CI_NOORDER

        v_user = wa_adrp-name_text.


      ENDIF.
* End of <> 17052013
      """"""""""""""""""uncommented by lipsy on 29.05.2013 for telephone no
      """"""""""""""end of addition by lipsy on 19.02.2013

      notes-text = text_1.
*     notes-text = '@DH@'.
    WHEN OTHERS.
      SELECT SINGLE * FROM stxh WHERE
                           tdobject = 'ZMMVC' AND
                           tdname = l_tdname AND
                           tdid = 'NOTE' AND
                           tdspras = 'EN'.
      IF sy-subrc = 0.
        notes-text = text_2.
      ELSE.
        IF g_trans_mode = 'D' OR
           g_trans_mode = 'X' OR
           g_trans_mode = 'R'.
          notes-text = text_3.
        ELSE.
          notes-text = text_1.
        ENDIF.
      ENDIF.

      """""""""""""""""""""""""""
      "ADDED BY LIPSY 12.1.2016
      IF g_trans_mode = 'D'.
        IF g_report_flag = 'X'.
          IF sy-ucomm = 'CHNGREPL' OR v_user_comm = 'CHNGREPL' .
            IF zmm_hvencrt-released_by IS INITIAL.

              notes-text = text_1.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.


      "END OF ADDITION BY LIPSY  12.1.2016
      """"""""""""""""""""""""""""
  ENDCASE.
ENDMODULE.                 " INIT_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTR_220  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attr_220 OUTPUT.
  CLEAR ist_vend.
  IF  zmm_hvencrt-bukrs = 'OVL'
    OR zmm_hvencrt-bukrs = 'OVC'.  "BOC by SS on 21.3.21
    LOOP AT SCREEN.
      CASE g_trans_mode.
        WHEN 'N' OR 'M'.
          IF NOT ist_vend[] IS INITIAL.
            READ TABLE ist_vend INDEX tab_ctl-current_line.
            IF sy-subrc IS INITIAL.
              CHECK ist_vend-fnd_flg = 'X' OR ist_vend-fnd_flg = 'M'.

              IF screen-group1 = 'B2'
                 AND wa_vend-vend-j_1kftbus = 'OEM'.
                IF g_trans_mode = 'M' AND g_src_button = ' '.
                  screen-input = '0'.
                ELSE.
                  screen-input = '1'.
                  screen-required = '1'.
                ENDIF.
                MODIFY SCREEN.
              ENDIF.

*----- type of business field to be enabled for pmat -----------*
              IF screen-group1 = 'B1'.
*              IF ZMM_HVENCRT-EKORG = 'PMAT'.   "commented on 5.12.2005
                IF zmm_hvencrt-ktokk = 'IMMI' OR
                   zmm_hvencrt-ktokk = 'IMMF'.
                  screen-input = '1'.
                  screen-required = '1'.
                  IF g_trans_mode = 'M' AND g_src_button = ' '.
                    screen-input = '0'.
                  ENDIF.
                ELSE.
                  screen-invisible = '1'.
                  screen-input = '0'.
                ENDIF.
                MODIFY SCREEN.
              ENDIF.
*----- end of type of bus. code --------------------------------*
*----- type of PAN field to be required & enabled for pmat -----------* 16052014
              IF screen-group4 = 'PAN'.
                IF zmm_hvencrt-ktokk = 'IMMI' OR
                   zmm_hvencrt-ktokk = 'SVWI'.
                  screen-input = '1'.
                  screen-required = '1'.
                ENDIF.
                MODIFY SCREEN.
              ENDIF.
*----- CODE FOR MODIFY ROW BUTTON IN CHANGE MODE ----------------*
              IF ( screen-group1 = 'T1' OR screen-group1 = 'T2' OR
                   screen-group1 = 'B1' OR screen-group1 = 'B2' ) AND
                   g_trans_mode = 'M' AND g_mod_button <> ' ' AND
                   ist_vend-mark = 'X'.
                screen-input = '1'.
                IF wa_vend-vend-j_1kftbus = 'OTHERS' AND
                   screen-group1 = 'B2'.
                  screen-input = 0.
                ENDIF.

                """"""""""""""""""""""""""""""""""""""""
                """""""""""""""""""""""""""""""""""""""
                """""""""""""""""""""""""""""""""""""""""""""""""""""""
                "code added by lipsy for making mobile
                "number compulsory during vendor change on 26.08.2013 RD1K979902

                IF (   screen-name = 'WA_VEND-VEND-MOB_NUMBER' ) AND
                                g_trans_mode = 'M' .
                  screen-required = '1'.
                ENDIF.
                "end of code added by lipsy for making mobile
                "number compulsory during vendor change on 26.08.2013 RD1K979902
                """"""""""""""""""""""""""""""""""""""""
                """"""""""""""""""""""""""


                """""""""""""""""""""""""""""""""""""""""
                IF ( screen-name = 'WA_VEND-VEND-CIN_NUMBER' ) .
                  IF wa_vend-vend-j_1ipanno IS NOT INITIAL AND wa_vend-vend-cin_number IS INITIAL.
                    DATA chk_pan(1) TYPE c.
                    chk_pan = wa_vend-vend-j_1ipanno+3(1).
                    IF chk_pan = 'C'.
                      screen-input    = '1' .
                      screen-required = '1' .
                    ENDIF.
                  ENDIF.
                ENDIF.



                PERFORM upd_screen_attr_220.                  "+SP007

                PERFORM upd_screen_attr_bank_220.             "+SP010

                MODIFY SCREEN.
                CONTINUE.
              ENDIF.

              """""""""""""""""""""""""""""""""""""""
              """"""""""""""""""""""""""



*---- CODE1 START FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*

              IF ( screen-group1 = 'T1' OR screen-group1 = 'T2' ) AND
                   g_trans_mode = 'N'.
                screen-input = '1'.
                MODIFY SCREEN.
              ELSEIF ( screen-group1 = 'T1' OR screen-group1 = 'T2' ) AND
                 g_trans_mode = 'M' AND g_src_button = 'X' AND
                 ist_vend-fnd_flg = 'M'. "and
                screen-input = '1'.
                MODIFY SCREEN.
              ENDIF.

              IF ( zmm_hvencrt-ass_flag = 'P' OR
              zmm_hvencrt-ass_flag = 'R' ) AND
              NOT wa_vend IS INITIAL AND screen-group1 = 'T5'.
                screen-input = 1.
                MODIFY SCREEN.
              ENDIF.

*---- CODE1 END FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*

              IF screen-group1 = 'T2'  AND
                 screen-name = 'WA_VEND-VEND-ORT01' AND
                 g_vend GE tab_ctl-current_line.
                screen-input = '1'.
                screen-required = '1'.
                MODIFY SCREEN.
              ENDIF.

              IF ( ( zmm_hvencrt-ktokk = 'IMMI' OR
                     zmm_hvencrt-ktokk = 'SVWI' )  AND
                   ( zmm_hvencrt-ekorg = 'PMAT' OR
                     zmm_hvencrt-ekorg = 'PSRV' ) ) AND
                     screen-name = 'WA_VEND-VEND-LAND1'.

*                BOC on 21.3.2021 by ss
*                WA_VEND-VEND-LAND1 = 'IN'.
                IF zmm_hvencrt-bukrs = 'OVC'.
                  wa_vend-vend-land1 = 'CO'.
                ELSE.
                  wa_vend-vend-land1 = 'IN'.
                ENDIF.
*                EOC by ss

                screen-input = '0'.
                screen-required = '0'.
                MODIFY SCREEN.
              ENDIF.

              IF screen-group1 = 'T1' AND
                 g_vend EQ tab_ctl-current_line AND
                 g_src_button <> ' ' .
                screen-input = '1' .
                IF screen-name = 'WA_VEND-VEND-STRAS1' OR
                   screen-name = 'WA_VEND-VEND-PSTLZ' OR
                   screen-name = 'WA_VEND-VEND-REGIO' OR
                   screen-name = 'WA_VEND-VEND-LAND1' OR
                   screen-name = 'WA_VEND-VEND-BRSCH' OR
                   screen-name = 'WA_VEND-VEND-WAERS' OR
*                 SCREEN-NAME = 'WA_VEND-VEND-ORT02' OR
                  """"""""""""""
                  """"""added by lipsy on 9.02.2013  RD1K979902 for making mobile number mandatory
                  screen-name = 'WA_VEND-VEND-MOB_NUMBER' OR
                  "end of addition by lipsy on 9.02.2013  RD1K979902
                  """""""""""""""""""
                   screen-name = 'WA_VEND-VEND-EMAIL' OR  "RD1K976705 CR No.30005915 062011
                   screen-name = 'WA_VEND-VEND-SORTL'.
                  screen-required = '1'.
                ENDIF.
                IF zmm_hvencrt-bukrs = 'OVL'. " Bipin
                  IF ( zmm_hvencrt-ktokk = 'IMMF' OR
                       zmm_hvencrt-ktokk = 'SVWF' ) AND
                     ( screen-name = 'WA_VEND-VEND-ORT02' OR
                       screen-name = 'WA_VEND-VEND-PSTLZ' OR
                       screen-name = 'WA_VEND-VEND-REGIO' ).
                    screen-required = '0'.

                    IF screen-name = 'WA_VEND-VEND-PSTLZ'.
                      screen-required = '1'.
                    ENDIF.
                  ENDIF.
                ENDIF.

                IF ( ( zmm_hvencrt-ktokk = 'IMMI' OR
                       zmm_hvencrt-ktokk = 'SVWI' )  AND
                     ( zmm_hvencrt-ekorg = 'PMAT' OR
                       zmm_hvencrt-ekorg = 'PSRV' ) ) AND
                     screen-name = 'WA_VEND-VEND-LAND1'.

*   BOC on 21.3.21 by ss changes for  Company Code 'OVC'
*    wa_vend-vend-land1 = 'IN'.
                  IF zmm_hvencrt-bukrs = 'OVC'.
                    wa_vend-vend-land1 = 'CO'.
                  ELSE.
                    wa_vend-vend-land1 = 'IN'.
                  ENDIF.

*    EOC on 21.3.21 by ss


                  screen-input = '0'.
                  screen-required = '0'.
                ENDIF.

                PERFORM upd_screen_attr_220.                  "+SP007

                PERFORM upd_screen_attr_bank_220.             "+SP010

                MODIFY SCREEN.
                CONTINUE.
              ENDIF.

              IF tab_ctl-current_line LT g_vend AND
                 g_src_button <> ' ' AND
                 screen-group1 = 'T2'.
                screen-input = '0' .
                MODIFY SCREEN.
              ENDIF.

*+SP015 : Start
*Set Related Partner as a mandatory field
              IF   screen-group1 = 'SRP' AND
                 ( zmm_hvencrt-ktokk = 'IMMF' OR
                   zmm_hvencrt-ktokk = 'IMMI' OR
                   zmm_hvencrt-ktokk = 'SVWF' OR
                   zmm_hvencrt-ktokk = 'SVWF' ).

                screen-input    = '1'.
*             screen-required = '1'.
                screen-required = '0'.
                MODIFY SCREEN.

              ENDIF.
*+SP015 : End

            ELSE.
*---- CODE2 START FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*
              IF ( zmm_hvencrt-ass_flag = 'P' OR
                   zmm_hvencrt-ass_flag = 'R' ) AND
                   wa_vend IS INITIAL.
                IF screen-group1 = 'T1' OR screen-group1 = 'T2'.
                  screen-input = '0'.
                  screen-required = '0'.
                  MODIFY SCREEN.
                  CONTINUE.
                ENDIF.
              ENDIF.

            ENDIF.
*---- CODE2 END FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*
          ENDIF.

*Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
*IF  ZMM_HVENCRT-KTOKK = 'LAQ1' AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER' or screen-name = 'WA_VEND-VEND-EMAIL' ).
*                   screen-required = '0'.
*                MODIFY SCREEN.
*endif.
*END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572

        WHEN 'D' OR 'X' OR 'R' OR 'A'.
          IF screen-group1 = 'T1' OR screen-group1 = 'T2' OR
             screen-group1 = 'T5' OR screen-group1 = 'T6' OR
             screen-group1 = 'T7'.
            IF screen-group1 = 'T6' AND g_trans_mode = 'A' AND
               tab_ctl-current_line LE g_vend.
              screen-input = 1.
            ELSE.
              screen-input = '0' .
            ENDIF.
            IF ( screen-group1 = 'T7' OR  screen-group1 = 'T5' ) AND
                 g_trans_mode = 'A' AND
                 tab_ctl-current_line LE g_vend.
              screen-input = 1.
            ENDIF.
            MODIFY SCREEN.
            CONTINUE.
          ENDIF.

      ENDCASE.
**BOC by ss on 22.3.21
      IF zmm_hvencrt-bukrs = 'OVC'.
        IF screen-name   = 'WA_VEND-VEND-GST_NO'.
          screen-input    = '0' .
          MODIFY SCREEN.
        ENDIF.

        IF  screen-name    = 'WA_VEND-VEND-VEN_CLASS'.
          screen-input    = '0' .
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
**      EOC by ss on 22.3.21
    ENDLOOP.

*Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
    LOOP AT SCREEN.
      IF  zmm_hvencrt-ktokk = 'LAQ1'
         AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER'
                 OR screen-name = 'WA_VEND-VEND-EMAIL' ).
        screen-required = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919
    LOOP AT SCREEN.
      IF  ( zmm_hvencrt-ktokk = 'NOMI' OR zmm_hvencrt-ktokk = 'SHYG' )
         AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER'
                 OR screen-name = 'WA_VEND-VEND-EMAIL' ).
        screen-required = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
*End RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919
*End RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
  ELSE.
    PERFORM screen_attribte_ocl.
  ENDIF.
*
*  IF zmm_hvencrt-reqno is not initial and zmm_hvencrt-reqcl = 'R'.
*    MESSAGE 'This request has been rejected, No changes possible' type 'E'.
*  ENDIF.


  IF zmm_hvencrt-bukrs <> 'OVC'.  " added by ss on 30.3.21
    IF zmm_hvencrt-reqcl = 'IR' AND g_trans_mode = 'M'.
      LOOP AT SCREEN.
        IF screen-group4 = 'OAR' OR screen-group4 = 'PAN'.
          screen-input = '1' .
        ELSE.
          screen-input = '0'.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ELSE.     " BOC by ss on 30.3.321
    LOOP AT SCREEN.
      IF screen-group4 = 'PAN'.
        screen-input = '0' .
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.    " EOC by ss on 30.3.21
ENDMODULE.                 " SET_SCREEN_ATTR_220  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTR_230  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attr_230 OUTPUT.
  IF NOT ist_lfa1[] IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'S1' AND g_trans_mode = 'N'.
        screen-input = '0'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
      IF screen-group1 = 'S2' AND g_trans_mode = 'N' AND
         g_vend LE tab_srch-current_line.
        screen-input = '1'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " SET_SCREEN_ATTR_230  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_ROWS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_rows OUTPUT.
  g_detail_lines = sy-loopc.

ENDMODULE.                 " GET_ROWS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DIS_BUTT  OUTPUT
*&---------------------------------------------------------------------*
*       button behaviour during modes
*----------------------------------------------------------------------*
MODULE dis_butt OUTPUT.
  LOOP AT SCREEN.
    CASE g_trans_mode.
      WHEN 'N'.
        IF screen-group1 = 'C1'.
          screen-input = '0' .
          screen-invisible = '1'.
        ENDIF.
      WHEN 'M'.
        IF screen-group1 = 'C1' AND
           screen-group2 = 'A1'.
          screen-input = '0' .
          screen-invisible = '1'.
        ENDIF.
      WHEN 'D' OR 'X' OR 'R' OR 'A'.
        IF screen-group1 = 'C1' OR screen-group1 = 'T1'.
          IF screen-name = 'DEL' OR screen-name = 'MOD' OR
             screen-name = 'UNDO' OR ( screen-name = 'ANAL' AND
             g_trans_mode <> 'A' ).
            screen-input = '0' .
            screen-invisible = '1'.
          ENDIF.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
    CONTINUE.
  ENDLOOP.

ENDMODULE.                 " DIS_BUTT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_REC_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_rec_status OUTPUT.
  CLEAR g_status_icon.
  IF NOT wa_vend IS INITIAL.
    MOVE wa_vend-vend-bankl TO lfbk-bankl.
    MOVE wa_vend-vend-banks TO lfbk-banks.
    CASE g_trans_mode.
      WHEN 'M' OR 'D' OR 'X' OR 'A'.
        IF wa_vend-vend-lifnr <> ' '.
          PERFORM create_icon USING 'ICON_CHECKED'
                             CHANGING g_status_icon.
          EXIT.
        ENDIF.
        IF wa_vend-vend-del_flag = 'X'.
          PERFORM create_icon USING 'ICON_DELETE'
                              CHANGING g_status_icon.
          EXIT.
        ELSE.
          IF wa_vend-vend-rsn <> ' '.
            PERFORM create_icon USING 'ICON_INCOMPLETE'
                               CHANGING g_status_icon.
            EXIT.
          ENDIF.
          """"""""
          "add by lipsy
*  break-point.

          v_reqcl_srm = zmm_hvencrt-reqcl.
          IF v_user_comm = 'CHNGREPL'.
            IF  v_reqcl_srm = 'MS'.
              IF v_reqcl_srm NE zmm_hvencrt-reqcl.
                zmm_hvencrt-reqcl = v_reqcl_srm.

              ENDIF.
            ENDIF.
          ENDIF.
          "eadd by lipsy
          """""""""""""""""
          SELECT SINGLE * FROM zmm_hvencrt WHERE
                               reqno = zmm_hvencrt-reqno.  "#EC CI_NOORDER
          "
          "ADD BY LIPSY
          IF v_user_comm = 'CHNGREPL'.
            IF  v_reqcl_srm = 'MS'.
              zmm_hvencrt-reqcl = v_reqcl_srm.
            ENDIF.
          ENDIF.
          "eadd by lipsy
          "
          IF zmm_hvencrt-rel_flag <> ' ' AND g_trans_mode <> 'M'.
            PERFORM create_icon USING 'ICON_RELEASE'
                            CHANGING g_status_icon.
            EXIT.
          ENDIF.
        ENDIF.

    ENDCASE.
  ENDIF.
ENDMODULE.                 " SET_REC_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0310 OUTPUT.
  SET PF-STATUS ''.

ENDMODULE.                 " STATUS_0310  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_PBO_310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_pbo_310 OUTPUT.

  LOOP AT  SCREEN.
    CASE g_trans_mode.
      WHEN 'N'.
        IF screen-group1 = 'OC'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.

      WHEN 'M' OR 'D' OR 'R' OR 'X' OR 'A'.
        IF screen-group1 = 'TC'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " SCREEN_PBO_310  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  DATA : l_text31(12).
  CLEAR : ist_gui,ist_vend,l_vend_count.
  REFRESH : ist_gui.

  IF ist_gui[] IS INITIAL.
    ist_gui-fcode = 'CREA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DISP' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'ADDC' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UPDTADDR' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UPDTBANK'.  APPEND ist_gui . CLEAR ist_gui. "+SP009.
    ist_gui-fcode = 'SEARCH'.    APPEND ist_gui . CLEAR ist_gui.   "111010 BY SS
    ist_gui-fcode = 'BLOC'.      APPEND ist_gui . CLEAR ist_gui.   "061210 BY SS
  ENDIF.

  CASE g_trans_mode.
    WHEN 'N'.
      IF g_unblock_vendor = 'X'.

        """""""""""""""""""""""""""""""""

        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "+SP005

        """"""""""""""""""""""""""""""""""""""""
        ist_gui-fcode = 'HELP' . APPEND ist_gui . CLEAR ist_gui . "170212 BY SS
        SET TITLEBAR 'TITLE21'.
* Begin of <> on 06122010
      ELSEIF g_block_vendor = 'X'.

        """"""""""""""""""""
        "added by lipsy on 1.04.2013 RD1K983016
        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
        ist_gui-fcode = 'HELP' . APPEND ist_gui . CLEAR ist_gui .

        "end of addition by lipsy on 1.04.2013 RD1K983016
        """"""""""""""""""""""
        SET TITLEBAR 'TITLE931'.
* End of <> on 06122010
      ELSE.
        ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005
        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "+SP005

        SET TITLEBAR 'TITLE9'.
      ENDIF.
    WHEN 'M'.
*      IF NOT ist_extn[] IS INITIAL.     13022011
      PERFORM set_pfstatus USING 'CHAN'.
*      ENDIF.
      IF g_unblock_vendor = 'X'.
        SET TITLEBAR 'TITLE10'.
      ELSEIF g_block_vendor = 'X'.
        SET TITLEBAR  'TITLE318'.
      ENDIF.
    WHEN 'D' OR 'RL' OR 'AP'.
      CLEAR l_text31.

      IF g_unblock_vendor = 'X'.
* Begin of <> on 13022012
        """"""""""""""""""""""""""
        "commented by lipsy on 4.03.2013
*        if g_trans_mode = 'D'.
*        ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui .
*        ELSE.
        "end of comment by lipsy on 6.03.2013
        """""""""""""""""""""""""
        "commented by lipsy on 27.08.2013 for getting list ,attach tabs in release RD1K983016

*        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .


        "end of comment by lipsy on 27.08.2013 for getting list ,attach tabs in release RD1K983016

        """""""""""""""""""""""""""""""""""""""""""""""
        """"""""""""""""""""""""""""""
        "commented by lipsy on 4.03.2013

*         ENDIF.
        "end of comment  by lipsy on 6.03.2013
        """"""""""""""""""""""""
        ist_gui-fcode = 'HELP' . APPEND ist_gui . CLEAR ist_gui .
* End of <> on 13022012
        ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
        """"""""""""""""""""""""""""""""""""""""""""""""""""

        ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF g_trans_mode = 'D'.
          ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          l_text31 = 'Display'.
        ELSEIF g_trans_mode = 'RL'.
          IF wa_zmm_vend_unblock-zrelease = 'X'.
            ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          ENDIF.
          l_text31 = 'Release'.
        ELSEIF g_trans_mode = 'AP'.
          IF wa_zmm_vend_unblock-zapprove = 'X'.
            ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          ENDIF.
          l_text31 = 'Approve'.
        ENDIF.
        SET TITLEBAR 'TITLE22' WITH l_text31.
      ELSEIF g_block_vendor = 'X'.
        """""""""
        "added by lipsy on 1.04.2013 RD1K983016
*   if g_trans_mode = 'D'.
*        ELSE.
*        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
*   ENDIF.

        ist_gui-fcode = 'HELP' . APPEND ist_gui . CLEAR ist_gui .
        ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .

        IF g_trans_mode = 'D'.
          ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          l_text31 = 'Display'.
        ELSEIF g_trans_mode = 'RL'.
          IF wa_zmm_vend_block-zrelease = 'X'.
            ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          ENDIF.
          l_text31 = 'Release'.
        ELSEIF g_trans_mode = 'AP'.
          IF wa_zmm_vend_block-zapprove = 'X'.
            ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
          ENDIF.
          l_text31 = 'Approve'.
        ENDIF.

        "end  of addition  by lipsy on 1.04.2013 RD1K983016
        """"""""""


        ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui .

        """""""""""""""""""""""""""""""""""""""""
        "commented by lipsy on 2.04.2013 RD1K983016
*        SET TITLEBAR 'TITLE99'.
        "end of comment by lipsy on 2.04.2013 RD1K983016
        """"""""""""""""""""""""""""""""""""""

        """"""""""""""""""""""""""""""""""
        "added by lipsy on 2.04.2013 RD1K983016

        SET  TITLEBAR 'TITLE98' WITH l_text31.
        "end  of addition  by lipsy on 2.04.2013 RD1K983016
        """"""""""""""""""""""""""""""""""""


      ELSE.
        ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005
        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "+SP005

        SET TITLEBAR 'TITLE11'.
      ENDIF.

    WHEN 'R'.
      IF NOT ist_extn[] IS INITIAL.
        PERFORM set_pfstatus USING 'RELS'.
      ENDIF.
      SET TITLEBAR 'TITLE12'.
    WHEN 'X'.
      IF NOT ist_extn[] IS INITIAL.
        PERFORM set_pfstatus USING 'DELE'.
      ENDIF.
      ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005


      """"""""""""""""""""""""""""""""""""""""""""""""""""""
      "ADDED BY LIPSY ON 2.07.2015 RD1K997727
      IF save_ok_ext = 'EXTN'.
        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
      ENDIF.
      "END OF ADDITION BY LIPSY ON 2.07.2015 RD1K997727
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""
      IF g_block_vendor = 'X'.
        SET TITLEBAR 'TITLE31'.
      ELSE.
        SET TITLEBAR 'TITLE13'.
      ENDIF.
    WHEN 'A'.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      "added by lipsy on 10.12.2014 for changing status to ir by assigner  RD1K994952.

      IF zmm_vend_unblock-reqclu  = 'IR'.
      ELSE.
        "end of addition  by lipsy on 10.12.2014 for changing status to ir by assigner  RD1K994952.
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 10.12.2014 for changing status to ir by assigner  RD1K994952.
      ENDIF.
      "end of addition  by lipsy on 10.12.2014 for changing status to ir by assigner  RD1K994952.
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


      ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "+SP005
      """""""""""""""""""""""""""""""""""""""""

      "ADDED BY LIPSY ON 2.07.2015 RD1K997727
      IF save_ok_ext = 'EXTN'.
        ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui .
      ENDIF.
      "END OF ADDITION BY LIPSY ON 2.07.2015 RD1K997727

      """""""""""""""""""""""""""""""""


      IF g_unblock_vendor = 'X'.
        PERFORM set_pfstatus USING 'UNBL'.
        SET TITLEBAR 'TITLE24'.
      ELSEIF g_block_vendor = 'X'.
        PERFORM set_pfstatus USING 'BLOC'.
        SET TITLEBAR 'TITLE932'.
      ELSE.
        PERFORM set_pfstatus USING 'ASSN'.
        SET TITLEBAR 'TITLE14'.
      ENDIF.
  ENDCASE.
  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.

***  CLEAR : ist_gui.
***  REFRESH ist_gui.
**** Begin of <> on 10022012
****  IF ist_gui[] IS INITIAL.
****    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .   "02022012 RD1K978796
*****    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui . "-rk004
****    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'UPDTADDR' . APPEND ist_gui . CLEAR ist_gui .
****    ist_gui-fcode = 'UPDTBANK'. APPEND ist_gui . CLEAR ist_gui. "+SP009.
***** Begin of <> on 111010 by Sudhir Sharma
****    ist_gui-fcode = 'SEARCH'.   APPEND ist_gui . CLEAR ist_gui.
****    ist_gui-fcode = 'BLOC'.   APPEND ist_gui . CLEAR ist_gui.
****    ist_gui-fcode = 'HELP'.   APPEND ist_gui . CLEAR ist_gui. "17102011
***** End of <> on 111010
****    AUTHORITY-CHECK OBJECT 'ZMMVCE'
****                  ID 'ACTVT' FIELD :'95'.
****    IF sy-subrc = 0.
****      IF g_trans_mode = 'U'.
****        DELETE ist_gui WHERE fcode = 'CHAN'.
***** BEGIN OF <> ON 02022012
****        DELETE ist_gui WHERE fcode = 'RELS'.
****        DELETE ist_gui WHERE fcode = 'APPR'.
****        DELETE ist_gui WHERE fcode = 'ASSN'.  "uncommented on 020212
****
****      ENDIF.
****    ELSE.
*****      MESSAGE e397(ZMM).             "07022012
*****      IF g_trans_mode = 'U'.
*****        DELETE ist_gui WHERE fcode = 'CHAN'.
*****      ENDIF.
***** END OF <> ON 02022012
****    ENDIF.
****
****    IF g_trans_mode <> 'U'.
****      SET TITLEBAR 'TITLE8'.
****    ELSE.
****      SET TITLEBAR 'TITLE20'.
****    ENDIF.
****  ENDIF.
****
****  IF sy-ucomm = 'EXTN' OR sy-ucomm = 'OPT1'.
****    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
****    CHECK g_trans_mode = 'E'.
****    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .
****
****  ENDIF.
****
****  ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "SP005
****  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "SP005
**** Additional new Code added
****  IF ist_gui[] IS INITIAL.
****  AUTHORITY-CHECK OBJECT 'ZMMVCE'
****                 ID 'ACTVT' FIELD :'95'.
****  IF sy-subrc <> 0.
****
****      ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
****      ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
****      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
****      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
****
****  ENDIF.
**** ENDIF.
**** Begin of <> on 02032012
***  g_cpf = sy-uname.
***  shift g_cpf left deleting leading '0'.
***  select * from agr_users into CORRESPONDING FIELDS OF TABLE ist_agr_users
***  where uname = g_cpf and agr_name in ('D:MM_PUR_PO_APPROVE_IM',
***                                       'D:MM_PUR_PO_APPROVE_L3',
***                                       'D:MM_SRV_IND_APPROVE_L3',
***                                       'D:MM_PUR_PO_APPROVE_L2',
***                                       'D:MM_SRV_IND_APPROVE_L2',
***                                       'D:MM_PUR_PO_APPROVE_L1',
***                                       'D:MM_SRV_IND_APPROVE_L1',
***                                       'D:MM_SRV_IND_APPROVE_1A',
***                                       'D:MM_SRV_IND_APPROVE_1b',
***                                       'D:MM_SRV_IND_APPROVE_1c',
***                                       'D:MM_SRV_IND_APPROVE_1d',
***                                       'D:MM_SRV_IND_APPROVE_1E').
***  if sy-subrc <> 0.
***    select * from agr_users into CORRESPONDING FIELDS OF TABLE ist_agr_users
***    where uname = g_cpf and agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
***      if sy-subrc <> 0.
***        ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
***        ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
***        SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***      else.
***        ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
***        SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***      endif.
***    else.
***      select * from agr_users into CORRESPONDING FIELDS OF TABLE ist_agr_users
***      where uname = g_cpf and agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
***      if sy-subrc <> 0.
****   End of <> on 02032012
***        ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
***        SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***      else.
***        SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***      endif.
***    endif.
****  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.
***
**** Begin of <> on 17102013
***  if G_TRANS_MODE = 'E'.
***    refresh ist_gui.
***    ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
***    SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
***    SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
***  endif.
**** End of <> on 17102013

  CLEAR : ist_gui.
  REFRESH ist_gui.
* Begin of <> on 10022012
*  IF ist_gui[] IS INITIAL.
*    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .   "02022012 RD1K978796
**    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui . "-rk004
*    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'UPDTADDR' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'UPDTBANK'. APPEND ist_gui . CLEAR ist_gui. "+SP009.
** Begin of <> on 111010 by Sudhir Sharma
*    ist_gui-fcode = 'SEARCH'.   APPEND ist_gui . CLEAR ist_gui.
*    ist_gui-fcode = 'BLOC'.   APPEND ist_gui . CLEAR ist_gui.
*    ist_gui-fcode = 'HELP'.   APPEND ist_gui . CLEAR ist_gui. "17102011
** End of <> on 111010
*    AUTHORITY-CHECK OBJECT 'ZMMVCE'
*                  ID 'ACTVT' FIELD :'95'.
*    IF sy-subrc = 0.
*      IF g_trans_mode = 'U'.
*        DELETE ist_gui WHERE fcode = 'CHAN'.
** BEGIN OF <> ON 02022012
*        DELETE ist_gui WHERE fcode = 'RELS'.
*        DELETE ist_gui WHERE fcode = 'APPR'.
*        DELETE ist_gui WHERE fcode = 'ASSN'.  "uncommented on 020212
*
*      ENDIF.
*    ELSE.
**      MESSAGE e397(ZMM).             "07022012
**      IF g_trans_mode = 'U'.
**        DELETE ist_gui WHERE fcode = 'CHAN'.
**      ENDIF.
** END OF <> ON 02022012
*    ENDIF.
*
*    IF g_trans_mode <> 'U'.
*      SET TITLEBAR 'TITLE8'.
*    ELSE.
*      SET TITLEBAR 'TITLE20'.
*    ENDIF.
*  ENDIF.
*
*  IF sy-ucomm = 'EXTN' OR sy-ucomm = 'OPT1'.
*    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
*    CHECK g_trans_mode = 'E'.
*    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .
*
*  ENDIF.
*
*  ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "SP005
*  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "SP005
* Additional new Code added
*  IF ist_gui[] IS INITIAL.
*  AUTHORITY-CHECK OBJECT 'ZMMVCE'
*                 ID 'ACTVT' FIELD :'95'.
*  IF sy-subrc <> 0.
*
*      ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
*      ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
*      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
*      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
*
*  ENDIF.
* ENDIF.
* Begin of <> on 02032012
  g_cpf = sy-uname.
  SHIFT g_cpf LEFT DELETING LEADING '0'.
  SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
  WHERE uname = g_cpf AND agr_name IN ('D:MM_PUR_PO_APPROVE_IM',
                                       'D:MM_PUR_PO_APPROVE_L3',
                                       'D:MM_SRV_IND_APPROVE_L3',
                                       'D:MM_PUR_PO_APPROVE_L2',
                                       'D:MM_SRV_IND_APPROVE_L2',
                                       'D:MM_PUR_PO_APPROVE_L1',
                                       'D:MM_SRV_IND_APPROVE_L1',
                                       'D:MM_SRV_IND_APPROVE_1A',
                                       'D:MM_SRV_IND_APPROVE_1b',
                                       'D:MM_SRV_IND_APPROVE_1c',
                                       'D:MM_SRV_IND_APPROVE_1d',
                                       'D:MM_SRV_IND_APPROVE_1E').
  IF sy-subrc <> 0.

    SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
    WHERE uname = g_cpf AND agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
    IF sy-subrc <> 0.
      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ELSE.
      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ENDIF.
  ELSE.
    SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
    WHERE uname = g_cpf AND agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
    IF sy-subrc <> 0.
* End of <> on 02032012
      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ELSE.
      SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ENDIF.
  ENDIF.
* Begin of <> on 17102013
  IF g_trans_mode = 'E'.
    REFRESH ist_gui.
    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
    SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
    SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .
    SET PF-STATUS 'PF_400' EXCLUDING ist_gui.
  ENDIF.


ENDMODULE.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_screen_310 OUTPUT.
  CASE g_trans_mode.
    WHEN 'N'.
      zmm_hvenext-erfdt = sy-datum.
      zmm_hvenext-ernam = sy-uname.
    WHEN 'M'.

  ENDCASE.

ENDMODULE.                 " INIT_SCREEN_310  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCR_ATTR_320  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_scr_attr_320 OUTPUT.
  g_detail_lines = sy-loopc.
  LOOP AT SCREEN.
    CASE g_trans_mode.
      WHEN 'N'.
        IF screen-group2 = '110' AND
           ist_extn-ekorg = 'POBV' .
          screen-input = '1'.
          screen-required = '1'.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      WHEN 'D' OR 'X' OR 'R' OR 'A'.
        IF screen-group1 = 'TC'.
          screen-input = '0'.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDMODULE.                 " SET_SCR_ATTR_320  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_tc_lines  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_tc_lines OUTPUT.
  DATA l_lines TYPE i.
  IF NOT ist_extn[] IS INITIAL.
    DESCRIBE TABLE ist_extn LINES l_lines.
    IF l_lines GE g_detail_lines.
      l_lines = l_lines + 1.
      MOVE l_lines TO tab_ext-lines.
    ENDIF.
  ENDIF.
  CLEAR : save_ok,ok_code.

ENDMODULE.                 " set_tc_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  D0500_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE d0500_status OUTPUT.
  SET PF-STATUS 'ADDR'.
ENDMODULE.                 " D0500_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  D0500_READ_ADDRESS  OUTPUT
*&---------------------------------------------------------------------*
*       READ ADDRESS TO DISPLAY IN DIALOG BOX
*----------------------------------------------------------------------*
MODULE d0500_read_address OUTPUT.

  PERFORM get_complete_vendor_address USING g_addrnumber.

ENDMODULE.                 " D0500_READ_ADDRESS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PORG_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       PURCHASE ORGN. LIST DROP DOWN
*----------------------------------------------------------------------*
MODULE get_porg_list OUTPUT.

  PERFORM list_box USING 'IST_EXTN-EKORG'.

ENDMODULE.                 " GET_PORG_LIST  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_ADDRESS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disp_address OUTPUT.
  DATA wa_lfa1 LIKE lfa1.
  DATA l_werks LIKE ist_extn-werks.
  DATA l_pstlz TYPE lfa1-pstlz.
  DATA: telf1_ro TYPE telf1,
        telfx_fx TYPE telfx.                                "081111 SS
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 4.12.2014 for vendor no display " RD1K994952
  DATA:g_lifnr_disp LIKE lfa1-lifnr,
       v_vendor_old LIKE lfa1-lifnr.
  "end of addition by lipsy on 4.12.2014 for vendor no display " RD1K994952
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  CLEAR :g_addrnumber.
* Begin of <> on 21042011
  DATA : l_flag.
  IF NOT ist_unbl IS INITIAL.
    IF ok_code = 'ENTE' AND l_flag IS INITIAL.
      l_flag = 'X'.
* Begin of <> on 20042011
*   if OK_CODE <> 'SAVE'.
* End of <> on 20042011
      ist_unbl_temp[] = ist_unbl[].    "05012011 by Sudhir Sharma
    ENDIF.
  ENDIF.

  IF g_unblock_vendor = 'X'.
    g_lifnr = ist_unbl-lifnr.
  ELSE.
    g_lifnr = ist_extn-lifnr.
  ENDIF.

  IF ( NOT g_lifnr IS INITIAL ) AND
    """""""""""""""""""""""""""""""""""""""""""""""
    """""""commented by lipsy on 19.12.2014 for getting vendor names in case of  more than  vendors
    " RD1K994952
*    ( ( g_trans_mode = 'N' AND  l_unblock_create_flag is initial   )
"end of comment by lipsy on 19.12.2014 for getting vendor names in case of  more than  vendors
    " RD1K994952
    """""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
     """""""added by lipsy on 19.12.2014 for getting vendor names in case of  more than  vendors
    " RD1K994952

( ( g_trans_mode = 'N' AND ( l_unblock_create_flag IS INITIAL  OR  v_vendor_old NE g_lifnr ) )
     """""end of addition by lipsy on 19.12.2014 for getting vendor names in case of  more than  vendors
    " RD1K994952
 """"""""""""""""""""""""""""""""""""""""""""""""""""
     OR  g_trans_mode = 'D'

   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""added by lipsy on 12.12.2014 for getting vendor's name in all modes  " RD1K994952
    OR g_trans_mode = 'M'  OR g_trans_mode = 'RL' OR g_trans_mode = 'A' OR  g_trans_mode = 'AP'


     """""end of addition by lipsy on 12.12.2014 for getting vendor's name in all modes  " RD1K994952
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    ).
    " the above condition make sure that data is only fetched once for creation(mode = 'N') and multiple times for display(mode = 'D').

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "commented by lipsy on 4.12.2014 for vendor no display " RD1K994952
*    SELECT SINGLE * FROM lfa1 INTO wa_lfa1 WHERE
*                                        lifnr = g_lifnr.
    ""end of comment by lipsy on 4.12.2014 for vendor no display " RD1K994952
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "added by lipsy on 4.12.2014 for vendor no display " RD1K994952

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = g_lifnr
      IMPORTING
        output = g_lifnr_disp.


    SELECT SINGLE * FROM lfa1 INTO wa_lfa1 WHERE
                                        lifnr = g_lifnr_disp.
    ""end of addition by lipsy on 4.12.2014 for vendor no display " RD1K994952

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    IF g_unblock_vendor = 'X'.

      g_sperm = ist_unbl-sperm.                             "+SP006
      g_sperr = ist_unbl-sperr.                             "+SP006
      g_blrfq = ist_unbl-blrfq.                             "+SP006
      g_loevm = ist_unbl-loevm.                             "SS 06122010

      IF wa_lfa1-pstlz IS INITIAL.
        l_pstlz = ist_unbl-pstlz.                           "SS 081111
        MOVE-CORRESPONDING wa_lfa1 TO ist_unbl.
        ist_unbl-pstlz = l_pstlz.
      ELSE.
        MOVE-CORRESPONDING wa_lfa1 TO ist_unbl.
      ENDIF.                                                "SS 081111
*+SP013 - Mobile Number
      SELECT SINGLE tel_number FROM adr2 INTO (ist_unbl-mob_number)
                              WHERE addrnumber = wa_lfa1-adrnr AND
                                    r3_user    = '3'.  "#EC CI_NOORDER

*+SP013 - End

*+SP006 - Additional Address
      ist_unbl-sperm = g_sperm.
      ist_unbl-sperr = g_sperr.
      ist_unbl-blrfq = g_blrfq.
      ist_unbl-loevm = g_loevm.                              "SS 06122010


      MOVE wa_lfa1-stras      TO ist_unbl-stras1.

      SELECT SINGLE str_suppl1 str_suppl2 str_suppl3 location FROM  adrc
                   INTO (ist_unbl-suppl1,ist_unbl-suppl2,ist_unbl-suppl3,
                                             ist_unbl-ort02)
                                        WHERE addrnumber = wa_lfa1-adrnr.  "#EC CI_NOORDER

      SELECT SINGLE smtp_addr FROM adr6 INTO (ist_unbl-email)
                                WHERE addrnumber = wa_lfa1-adrnr.  "#EC CI_NOORDER
*+SP006 - end
      l_unblock_create_flag = 'X'." In ceate mode data should be fetched only once...this flag prevents
      """"""""""""""""""""
      "add by lipsy 19.12.2014 for getting vendor names in case of  more than  vendors
      " RD1K994952
      v_vendor_old = g_lifnr.
      "eadd by lipsy 19.12.2014 for getting vendor names in case of  more than  vendors
      " RD1K994952
      """"""""""""""""""""""""""""
    ELSE.                        " fetching of data on every press of ENTER key..so corrected data remains on screen.
      l_werks = ist_extn-werks.
      MOVE-CORRESPONDING wa_lfa1 TO ist_extn.
      ist_extn-telf1 = telf1_ro.
      ist_extn-telfx = telfx_fx.
      ist_extn-werks = l_werks.
    ENDIF.
  ENDIF.
ENDMODULE.                 " DISP_ADDRESS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       gui for logg dialog box
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS 'LOGG'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       Initialize control for text editor
*----------------------------------------------------------------------*
MODULE init_control OUTPUT.
  PERFORM create_container.
ENDMODULE.                 " INIT_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POP_TEXT1  OUTPUT
*&---------------------------------------------------------------------*
*       populate long text
*----------------------------------------------------------------------*
MODULE pop_text1 OUTPUT.
  IF NOT g_trans_mode EQ 'N'.
    PERFORM populate_text.
  ENDIF.

ENDMODULE.                 " POP_TEXT1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_COUNTRY_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_country_list OUTPUT.

  PERFORM list_box USING 'WA_VEND-VEND-LAND1'.

ENDMODULE.                 " GET_COUNTRY_LIST  OUTPUT
*{   INSERT         OCPK900113                                        1
MODULE get_ven_class_list OUTPUT.

  PERFORM list_box USING 'WA_VEND-VEND-VEN_CLASS'.

ENDMODULE.
*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  SET_BUTTON_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_button_attr OUTPUT.

  CASE g_trans_mode.
    WHEN 'D'.
      LOOP AT SCREEN.
        IF screen-group1 = 'E10'.
          screen-invisible = 1.
          MODIFY SCREEN.
          EXIT.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.                 " SET_BUTTON_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_data OUTPUT.
  DATA : BEGIN OF ist_gui1 OCCURS 0 ,
           fcode LIKE rsmpe-func,
         END OF ist_gui1 .

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  NEW-PAGE NO-TITLE.

*  ULINE 1(91).

  IF g_src = '1'.
    ist_gui1-fcode = 'AGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'DAGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    SET PF-STATUS 'DECI' EXCLUDING ist_gui1.
*
*    WRITE : / '**                     For request details go to DISPLAY
*                   **' COLOR 7.

    WRITE : / '**                     For request details go to DISPLAY'
                    & '**' COLOR 7.


    SKIP 1.
********CAB_AJIT 24.01.2006 Request No  length icreased to 10 chars ****

    WRITE : /1(1) sy-vline, 2(10)'Request' COLOR 4,
             12(1) sy-vline,13(30)'Name1' COLOR 4,
             44(1) sy-vline,45(10)'Name2' COLOR 4,
             56(1) sy-vline,57(20)'City'  COLOR 4,
             78(1) sy-vline .

    LOOP AT ist_vendor.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE :/1(1) sy-vline,2(10) ist_vendor-reqno COLOR 3,  "#EC CI_NOORDER
              12(1) sy-vline,13(30) ist_vendor-name1 COLOR 3,  "#EC CI_NOORDER
              44(1) sy-vline,45(10) ist_vendor-name2 COLOR 3,  "#EC CI_NOORDER
              56(1) sy-vline,57(20) ist_vendor-ort01 COLOR 3,  "#EC CI_NOORDER
              78(1) sy-vline .  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    ENDLOOP.

********CAB_AJIT 24.01.2006 ********************************************
  ELSEIF g_src = '2'.
    ist_gui1-fcode = 'AGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'DAGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    SET PF-STATUS 'DECI' EXCLUDING ist_gui1.

    WRITE : / '**Similar vendor(s) already figure in the Search Result'
                 & '**' COLOR 7.
    SKIP 1.
    ULINE 1(79).
    WRITE : /1(1) sy-vline, 2(10)'Vendor' COLOR 4,
             13(1) sy-vline,14(30)'Name1' COLOR 4,
             45(1) sy-vline,47(10)'Name2' COLOR 4,
             57(1) sy-vline,58(20)'City'  COLOR 4,
             79(1) sy-vline .

    ULINE /1(79).
    LOOP AT ist_vendor1.
      WRITE :/1(1) sy-vline,2(10) ist_vendor1-lifnr COLOR 5,
              13(1) sy-vline,14(30) ist_vendor1-name1 COLOR 5,
              45(1) sy-vline,47(10) ist_vendor1-name2 COLOR 5,
              57(1) sy-vline,58(20) ist_vendor1-ort01 COLOR 5,
              79(1) sy-vline.
    ENDLOOP.
    ULINE /1(79).

  ELSEIF g_src = '3'.
    ist_gui1-fcode = 'USE' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'NEW' . APPEND ist_gui1 . CLEAR ist_gui1.
    SET PF-STATUS 'DECI' EXCLUDING ist_gui1.

    WRITE : / 'Acknowledgement'  COLOR 3.
    ULINE /1(80).
    WRITE  / sy-vline. WRITE :AT 2 text-301. WRITE AT 80 sy-vline.
    WRITE  / sy-vline. WRITE :AT 2 text-302. WRITE AT 80 sy-vline.
    WRITE  / sy-vline. WRITE :AT 2 text-303. WRITE AT 80 sy-vline.
    WRITE  / sy-vline. WRITE :AT 2 text-304. WRITE AT 80 sy-vline.
    ULINE /1(80).
*    WRITE : / text-301.     WRITE AT 80 sy-vline.
*    WRITE : / text-302.
*    WRITE : / text-303.
*    WRITE : / text-304.
  ELSEIF g_src = '4'.

    ist_gui1-fcode = 'AGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'DAGR' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'USE' . APPEND ist_gui1 . CLEAR ist_gui1.
    ist_gui1-fcode = 'NEW' . APPEND ist_gui1 . CLEAR ist_gui1.
    SET PF-STATUS 'DECI' EXCLUDING ist_gui1.
    WRITE : / '**  Unassigned Requests already exist for these Vendors **' COLOR 7.
    SKIP 1.
********CAB_AJIT 24.01.2006 Request No  length icreased to 10 chars ****
    ULINE 1(81).
    WRITE : /1(1)  sy-vline, 2(4) 'Srno' COLOR 4,
             6(1)  sy-vline, 7(30) 'Name1' COLOR 4,
             37(1) sy-vline, 38(10) 'Name2' COLOR 4,
             48(1) sy-vline, 49(20) 'City' COLOR 4,
             69(1) sy-vline, 70(10) 'Request'  COLOR 4,
             81(1) sy-vline .
    ULINE /1(81).
    LOOP AT ist_vendor.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      WRITE :/1(1)  sy-vline, 2(4)  ist_vendor-seqno COLOR 3,  "#EC CI_NOORDER
             6(1)  sy-vline,  7(30)  ist_vendor-name1 COLOR 3,  "#EC CI_NOORDER
             37(1) sy-vline,  38(10) ist_vendor-name2 COLOR 3,  "#EC CI_NOORDER
             48(1) sy-vline,  49(20) ist_vendor-ort01 COLOR 3,  "#EC CI_NOORDER
             69(1) sy-vline,  70(10) ist_vendor-reqno COLOR 3,  "#EC CI_NOORDER
             81(1) sy-vline .  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

    ENDLOOP.
    ULINE /1(81).
  ENDIF.
  CLEAR ist_gui1.
  REFRESH ist_gui1.
ENDMODULE.                 " DISPLAY_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'DECI'.
  SET TITLEBAR 'STIT'.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CITY_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       LISTBOX FOR CITY
*----------------------------------------------------------------------*
MODULE get_city_list OUTPUT.

  PERFORM list_box USING 'WA_VEND-VEND-ort01'.

ENDMODULE.                 " GET_CITY_LIST  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       SET CURSOR
*----------------------------------------------------------------------*
MODULE set_cursor OUTPUT.

  CASE sy-dynnr.
    WHEN '0220'.
      CHECK g_trans_mode = 'N'. "OR g_trans_mode = 'M'.
      IF NOT zmm_hvencrt-bukrs IS INITIAL AND
         ist_vend[] IS INITIAL.
        SET CURSOR FIELD 'WA_VEND-VEND-NAME1' LINE 1.
      ELSEIF NOT zmm_hvencrt-bukrs IS INITIAL AND
             NOT ist_vend[] IS INITIAL  .
        SET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
*    WHEN '0420'.
*      SET CURSOR FIELD g_cursorfield LINE g_cursorline.         "-rk004
*{+rk004
    WHEN '0410'.
      CASE g_trans_mode.
        WHEN 'N'.
          SET CURSOR FIELD 'ZMM_VEND_UNBLOCK-BUKRS'.
        WHEN 'M' OR 'D' OR 'A' OR 'X' OR 'RL'.  "RL ADDED ON 02022012
          SET CURSOR FIELD 'ZMM_VEND_UNBLOCK-REQNO'.
      ENDCASE.
    WHEN '0420'.
      CASE g_trans_mode.
        WHEN 'N'.
          IF NOT zmm_vend_unblock-bukrs IS INITIAL.
            SET CURSOR FIELD g_cursorfield LINE g_cursorline.
          ENDIF.
      ENDCASE.
*}+rk004
  ENDCASE.
ENDMODULE.                 " SET_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_tab_unbl_lines  OUTPUT
*&---------------------------------------------------------------------*
*       defaults
*----------------------------------------------------------------------*
MODULE get_tab_unbl_lines OUTPUT.

  g_detail_lines = sy-loopc.
  tab_unbl-lines = '9999'.

ENDMODULE.                 " get_tab_unbl_lines  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_410  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_screen_410 OUTPUT.
  IF NOT ist_zmm_vend_unblock[] IS INITIAL.
    READ TABLE ist_zmm_vend_unblock INTO wa_zmm_vend_unblock INDEX 1.
    zmm_vend_unblock-erfdt = wa_zmm_vend_unblock-erfdt.
    zmm_vend_unblock-ernam = wa_zmm_vend_unblock-ernam.
    zmm_vend_unblock-bukrs = wa_zmm_vend_unblock-bukrs.
    IF g_trans_mode <> 'N'.
      zmm_vend_unblock-assigned_by = wa_zmm_vend_unblock-assigned_by.
      zmm_vend_unblock-assign_date = wa_zmm_vend_unblock-assign_date.
      zmm_vend_unblock-releasedon = wa_zmm_vend_unblock-releasedon. "sy-datum.
      zmm_vend_unblock-releasedby = wa_zmm_vend_unblock-releasedby. "sy-uname.
      zmm_vend_unblock-approvedon = wa_zmm_vend_unblock-approvedon. "sy-datum.
      zmm_vend_unblock-approvedby = wa_zmm_vend_unblock-approvedby. "sy-uname.
    ENDIF.

    LOOP AT ist_zmm_vend_unblock INTO wa_zmm_vend_unblock.
      SELECT SINGLE * FROM lfa1 WHERE lifnr = wa_zmm_vend_unblock-lifnr.
*    wa_zmm_vend_unblock-zpstlz = lfa1-pstlz.                "05032012
      MOVE-CORRESPONDING wa_zmm_vend_unblock TO ist_unbl.
      MOVE wa_zmm_vend_unblock-zpstlz TO ist_unbl-pstlz.
      IF zmm_vend_unblock-sperq IS INITIAL.
        zmm_vend_unblock-sperq = wa_zmm_vend_unblock-sperq.
      ENDIF.

*-SP006
*    IF sy-subrc = 0.
*      ist_unbl-sperm = ist_lfa1-sperm.
*      ist_unbl-sperr = ist_lfa1-sperr.
*    ENDIF.
*-SP006


******** added by cab_dns  CR #30010171 ********
      ist_unbl_temp = ist_unbl.

      """"""""""""""""""""""""""""""""""""

      """""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
      READ TABLE ist_unbl WITH KEY lifnr = ist_unbl-lifnr.

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""



      IF sy-subrc = 0.

        DATA : l_index TYPE sy-tabix.
        l_index  = sy-tabix.
*  ist_unbl  = ist_unbl_temp.

        MODIFY ist_unbl INDEX l_index.

      ELSE.

        APPEND ist_unbl.
      ENDIF.

******** added by cab_dns  CR #30010171 ********

* APPEND ist_unbl.



      CLEAR: ist_unbl,ist_unbl_temp.
    ENDLOOP.

  ENDIF.

  CASE g_trans_mode.
    WHEN 'N'.
      zmm_vend_unblock-erfdt = sy-datum.
      zmm_vend_unblock-ernam = sy-uname.
    WHEN 'D'.
      zmm_vend_unblock-assigned_by = wa_zmm_vend_unblock-assigned_by.
      zmm_vend_unblock-assign_date = wa_zmm_vend_unblock-assign_date.
* Begin of <> on 02022012
    WHEN 'RL'.
      zmm_vend_unblock-releasedon = wa_zmm_vend_unblock-releasedon. "sy-datum.
      zmm_vend_unblock-releasedby = wa_zmm_vend_unblock-releasedby. "sy-uname.
    WHEN 'AP'.
      zmm_vend_unblock-approvedon = wa_zmm_vend_unblock-approvedon. "sy-datum.
      zmm_vend_unblock-approvedby = wa_zmm_vend_unblock-approvedby. "sy-uname.
* End of <> on 02022012
  ENDCASE.

*{-rk
*Note this is for Blocking field in unblock header screen
*  PERFORM list_box USING 'ZMM_VEND_UNBLOCK-SPERQ'.
*}-rk
  """""""""""added by lipsy on 20.02.2013 for correspondence AND REQUEST STATUS and assigned by
  IF g_trans_mode <> 'N'.
    IF  zmm_vend_unblock-assigned_by IS INITIAL OR
     zmm_vend_unblock-assign_date IS INITIAL OR
       zmm_vend_unblock-approvedon IS  INITIAL OR
      zmm_vend_unblock-approvedby IS INITIAL.
      LOOP AT  ist_zmm_vend_unblock INTO wa_zmm_vend_unblock.
        IF wa_zmm_vend_unblock-assigned_by IS NOT INITIAL OR
         wa_zmm_vend_unblock-assign_date IS NOT INITIAL.
          zmm_vend_unblock-assigned_by = wa_zmm_vend_unblock-assigned_by.
          zmm_vend_unblock-assign_date = wa_zmm_vend_unblock-assign_date.

        ENDIF.
        IF wa_zmm_vend_unblock-approvedby IS NOT INITIAL OR
            wa_zmm_vend_unblock-approvedon IS NOT INITIAL.
          zmm_vend_unblock-approvedby = wa_zmm_vend_unblock-approvedby.
          zmm_vend_unblock-approvedon = wa_zmm_vend_unblock-approvedon.
        ENDIF.

      ENDLOOP.

    ENDIF.
  ENDIF.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  """""""""""""""added by lipsy on 12.12.2014 for preventing overwriting from previous request no
  " " RD1K994952

  IF g_trans_mode = 'A' AND zmm_vend_unblock-reqclu IS NOT INITIAL
    AND  v_reqnoassgn = zmm_vend_unblock-reqno.

  ELSE.

    """""""""""""""end of addition by lipsy on 12.12.2014 for preventing overwriting from previous request no
    " RD1K994952
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    zmm_vend_unblock-reqclu = wa_zmm_vend_unblock-reqclu.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""added by lipsy on 12.12.2014 for preventing overwriting from previous request no
    " RD1K994952
  ENDIF.
  """""""""""""""end of addition by lipsy on 12.12.2014for preventing overwriting from previous request no
  " RD1K994952
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  CONCATENATE 'NOTE' zmm_vend_unblock-reqno INTO l_tdname.
  CASE g_trans_mode.
    WHEN 'N'.
      notes-text = text_1.
    WHEN OTHERS.
      SELECT SINGLE * FROM stxh WHERE
                           tdobject = 'ZMMVC' AND
                           tdname = l_tdname AND
                           tdid = 'NOTE' AND
                           tdspras = 'EN'.
      IF sy-subrc = 0.
        notes-text = text_2.
        g_cors = 'X'.   "Commented on 17052013 by Sudhir Sharma
      ELSE.
        IF g_trans_mode = 'D' OR
           g_trans_mode = 'X' OR
           g_trans_mode = 'RL'.
          notes-text = text_3.
          g_cors = ''.
        ELSE.
          notes-text = text_1.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "added by lipsy on 8.12.2014 for  correction of correspondence check box " RD1K994952
          g_cors  = ''.
          "end of addition by lipsy on 8.12.2014 for  correction of correspondence check box " RD1K994952
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        ENDIF.
      ENDIF.
  ENDCASE.

  """"""""""""""""""""end of addition  by lipsy on 20.02.2013 for correspondence

  """""""""""""""""""""""""""""""""""""""""""""""""""""
  "added by lipsy on 16.12.2014 for request change in unblock " RD1K994952

  v_reqnoassgn = zmm_vend_unblock-reqno.

  "end of addition by lipsy on 16.12.2014 for  request change in unblock " RD1K994952
  """""""""""""""""""""""""""""""""""""""""""""""""""

ENDMODULE.                 " INIT_SCREEN_410  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  screen_pbo_410  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_pbo_410 OUTPUT.
  LOOP AT  SCREEN.
    CASE g_trans_mode.

      WHEN 'D' OR 'A' OR 'M' OR 'X' OR 'RL' OR 'AP' . "RL AP ADDED ON 02022012
        IF screen-group1 = 'UNB'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "added by lipsy on 12.12.2014 for  making request status editable in assign " RD1K994952
        IF g_trans_mode = 'A'.

          IF screen-name = 'ZMM_VEND_UNBLOCK-REQCLU'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.

        ENDIF.

        "end of addition by lipsy on 12.12.2014 for  making request status editable in assign " RD1K994952
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      WHEN 'N'.
        IF screen-group1 = 'CRE'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDMODULE.                 " screen_pbo_410  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_screen_attr_420  OUTPUT
*&---------------------------------------------------------------------*
*       set screen attributes in 420
*----------------------------------------------------------------------*
MODULE set_screen_attr_420 OUTPUT.

  CASE g_trans_mode.
*    WHEN 'A' OR 'D'.                                       "-RK004
*    WHEN 'A' OR 'D' OR 'X'.                        "+RK004 "-SP006
* Begin of <> on 03082011
    WHEN 'N' OR 'M'.
      IF NOT ist_unbl-lifnr IS INITIAL AND
             ( ist_unbl-email IS INITIAL OR
             ist_unbl-mob_number IS INITIAL OR
             ist_unbl-pstlz IS INITIAL ).
        LOOP AT SCREEN.
          IF screen-name = 'IST_UNBL-EMAIL'  OR
             screen-name = 'IST_UNBL-MOB_NUMBER' OR
             screen-name = 'IST_UNBL-PSTLZ'.
            screen-input = 1.
            screen-required = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.


* End of <> 03082011
* Begin of <RD1K978300> 081111
*      IF NOT IST_UNBL-LIFNR IS INITIAL AND IST_UNBL-PSTLZ IS INITIAL.
*        LOOP AT SCREEN.
*          IF SCREEN-NAME = 'IST_UNBL-PSTLZ'.
*            SCREEN-INPUT = 1.
*            SCREEN-REQUIRED = 1.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
* End of <RD1K978300> on 081111
    WHEN 'D' OR 'X' OR 'RL' OR 'AP'.    "RL AP ADDED 02022012                  "+SP006
      LOOP AT SCREEN.
        IF screen-group1 = '100'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.

*+SP006 - Assign
    WHEN 'A'.
      LOOP AT SCREEN.
        IF screen-group2 = 'BLK'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.

*+SP006
  ENDCASE.


  """""""""""""""""
  "added by lipsy on 4.03.2013
  IF   g_trans_mode = 'A' OR g_trans_mode = 'AP'.
    LOOP AT SCREEN.
      IF screen-name = 'IST_UNBL-REJNU'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'IST_UNBL-REJNU'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.


  IF g_trans_mode = 'M'.
    IF NOT ist_unbl-lifnr IS INITIAL .
      LOOP AT SCREEN.
        IF screen-name = 'IST_UNBL-EMAIL' OR
           screen-name = 'IST_UNBL-MOB_NUMBER' OR
           screen-name = 'IST_UNBL-PSTLZ'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
* End of <> 03082011
* Begin of <RD1K978300> 081111
*      IF NOT IST_UNBL-LIFNR IS INITIAL .
*        LOOP AT SCREEN.
*          IF SCREEN-NAME = 'IST_UNBL-PSTLZ'.
*            SCREEN-INPUT = 1.
*            SCREEN-REQUIRED = 1.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*        ENDIF.
  ENDIF.
  "end of addition by lipsy on 4.03.2013

  """"""""""""""

ENDMODULE.                 " set_screen_attr_420  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  disable_button_420  OUTPUT
*&---------------------------------------------------------------------*
*       disable button in 420
*----------------------------------------------------------------------*
MODULE disable_button_420 OUTPUT.
  CASE g_trans_mode.
    WHEN 'D' OR 'X' OR 'RL' OR 'AP'. " RL & AP 02022012
      LOOP AT SCREEN.
        IF screen-group1 = '110'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDMODULE.                 " disable_button_420  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_control_9010  OUTPUT
*&---------------------------------------------------------------------*
*       ROUTINE FOR EXPAND BUTTON
*----------------------------------------------------------------------*
MODULE init_control_9010 OUTPUT.
  DATA p_icon LIKE icons-text.

  IF g_call_screen = '210'.
    p_icon = 'ICON_DATA_AREA_COLLAPSE'.
  ELSE.
    p_icon = 'ICON_DATA_AREA_EXPAND'.

  ENDIF.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = p_icon
      add_stdinf            = 'X'
    IMPORTING
      result                = g_icon_header
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " init_control_9010  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_TEXT_9020  OUTPUT
*&---------------------------------------------------------------------*
*       DYNAMIC TEXT DISPLAY
*----------------------------------------------------------------------*
MODULE set_text_9020 OUTPUT.

  g_dyn_text_header = 'Header Details'.

ENDMODULE.                 " SET_TEXT_9020  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_320  OUTPUT
*&---------------------------------------------------------------------*
*       SET CURSOR IN VENDOR EXTENSION TABLE CONTROL
*----------------------------------------------------------------------*
MODULE set_cursor_320 OUTPUT.

  IF NOT g_cursorfield IS INITIAL AND
     NOT g_cursorline IS INITIAL.
    SET CURSOR FIELD g_cursorfield LINE g_cursorline.
  ENDIF.
ENDMODULE.                 " SET_CURSOR_320  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pop_message OUTPUT.
  IMPORT g_report_flag FROM MEMORY ID 'VEND'.

  CHECK g_report_flag <> 'X'.
  CHECK g_firsttime = 'X'.
  CLEAR g_firsttime.
* Begin of <> on 111010 by Sudhir Sharma
  IF g_exec = 'X'.

    CLEAR g_exec.

    CALL FUNCTION 'ZMM_POPUP_VMS_MESSAGE'
      EXPORTING
        arbgb             = 'ZMM'
        msgnr             = '861'
        msgty             = 'I'
      EXCEPTIONS
        user_cancel       = 1
        message_not_found = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.
* End of <> on 111010
*  MESSAGE i803(zmm) WITH text-p01.
** Begin of <RD1K968710> on 19-11-09 by Sudhir Sharma
*  CALL FUNCTION 'ZMM_MASS_SHOW_CONFIG_MESSAGE'
*    EXPORTING
*      arbgb             = 'ZMM'
*      msgnr             = '603'
*      msgty             = 'W'
*    EXCEPTIONS
*      user_cancel       = 1
*      message_not_found = 2
*      OTHERS            = 3.
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
* End of <RD1K968710> on 19-11-09
ENDMODULE.                 " POP_MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_rec_status_unblock  OUTPUT
*&---------------------------------------------------------------------*
*       Record status
*----------------------------------------------------------------------*
MODULE set_rec_status_unblock OUTPUT.

  IF ist_unbl-del_flag = 'X'.
    PERFORM create_icon USING 'ICON_DELETE'
                        CHANGING g_status_icon.
  ELSEIF ist_unbl-ass_flag = 'X'.
    PERFORM create_icon USING 'ICON_CHECKED'
                     CHANGING g_status_icon.

    """""""""""""""""
    "added by lipsy on 4.03.2013
  ELSEIF ist_unbl-rejnu NE ''.
    PERFORM create_icon USING 'ICON_INCOMPLETE'
                                  CHANGING g_status_icon.
    "end of addition by lipsy on 4.03.2013
    """"""""""""""""

  ENDIF.

ENDMODULE.                 " set_rec_status_unblock  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0319  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0319 OUTPUT.
* Begin of <> on 17072012
  DATA : l_cpf,
         l_ncpf.
* End of <> on 17072012
  CASE g_okcode931.
    WHEN 'CREATE'.
      g_spantext = 'Create'.
      SET PF-STATUS 'S319'.
      SET TITLEBAR 'T319' WITH g_spantext.

    WHEN 'CHANGE'.
* Begin of <> on 17072012
      READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY cpf = g_cpf.
      IF sy-subrc = 0.
        l_cpf = 'X'.
      ENDIF.
* End of <> on 17072012
* Begin of <> 15122010
      SHIFT g_cpf LEFT DELETING LEADING '0'.                "20062012
      READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY cpf = g_cpf.
      IF sy-subrc = 0.
* Begin of <> on 17072012
        l_ncpf = 'X'.
      ENDIF.
      IF l_cpf = 'X' OR l_ncpf = 'X'.
* End of <> on 17072012
* End of <> 15122010
        g_spantext = 'Change'.
        SET TITLEBAR 'T319' WITH g_spantext.

        READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY status = 'NEW'.
        IF sy-subrc = 0.
          SET PF-STATUS 'S319'.
        ELSE.
* Begin of <RD1K977307> 27072011
          READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY status = 'REJECTED BY HOF'.
          IF sy-subrc = 0.
            SET PF-STATUS 'S319'.
          ELSE.
            READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY status = 'REJECTED BY VMC'.
            IF sy-subrc = 0.
              SET PF-STATUS 'S319'.
            ELSE.
* End of <RD1K977307> 27072011
              ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
              SET PF-STATUS 'S319' EXCLUDING ist_gui.
            ENDIF.
          ENDIF.
        ENDIF.
* End of <> 27072011
* Begin of <> 15122010
      ELSE.
        g_okcode931 = 'DISPLAY'.
        g_spantext = 'Display'.
        ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .

        SET PF-STATUS 'S319' EXCLUDING ist_gui.
        SET TITLEBAR 'T319' WITH g_spantext.
      ENDIF.
* End of <> 15122010
    WHEN 'DISPLAY'.
      g_spantext = 'Display'.
      ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .

      SET PF-STATUS 'S319' EXCLUDING ist_gui.
      SET TITLEBAR 'T319' WITH g_spantext.

    WHEN OTHERS.
      SET PF-STATUS 'S319'.
      SET TITLEBAR 'T319'.

  ENDCASE.

ENDMODULE.                 " STATUS_0319  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC319'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc319_init OUTPUT.
  IF g_okcode931 <> 'CREATE'.

    IF g_tc319_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZFIVMSBANK'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC319_itab'
*
      SELECT * FROM zfivmsbank
      INTO CORRESPONDING FIELDS
      OF TABLE g_tc319_itab WHERE reqno = zfivmsbank-reqno.

      g_tc319_itab_temp[] = g_tc319_itab[].

      g_tc319_copied = 'X'.
      REFRESH CONTROL 'TC319' FROM SCREEN '0319'.
    ENDIF.

    LOOP AT g_tc319_itab INTO g_tc319_wa.  "Added on 230911
      CLEAR g_tc319_wa-sel319.
      MODIFY g_tc319_itab FROM g_tc319_wa.
    ENDLOOP.
  ELSE.

    REFRESH CONTROL 'TC319' FROM SCREEN '0319'.

  ENDIF.




ENDMODULE.                    "TC319_INIT OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC319'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc319_move OUTPUT.

  MOVE-CORRESPONDING g_tc319_wa TO zfivmsbank.
  IF  zfivmsbank-ccode IS NOT INITIAL.
    g_ccode = zfivmsbank-ccode.
  ENDIF.
ENDMODULE.                    "TC319_MOVE OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC319'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc319_get_lines OUTPUT.
  g_tc319_lines = sy-loopc.
ENDMODULE.                    "TC319_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE0319  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute0319 OUTPUT.

  IF g_okcode931 = 'CREATE'.
    LOOP AT SCREEN.                                         "28062010
      IF screen-name = 'ZFIVMSBANK-STATUS'.
*        SCREEN-NAME = 'TC319_DELETE' OR
        screen-invisible = '0'.                             "'1'.
        MODIFY SCREEN.
      ELSEIF screen-group3 = '003'.                         "230911
*      SCREEN-NAME = 'TC319_ATTACH' OR                      "230911
*      SCREEN-NAME = 'TC319_ZLIST' .
        screen-invisible = '1'.
        MODIFY SCREEN.
      ELSEIF screen-name = 'G_CCODE'.                    " Added on 5.4.21 by ss
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
*      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF g_okcode931 = 'CHANGE'.
* Begin of <> on 03122010
    READ TABLE g_tc319_itab INTO g_tc319_wa WITH KEY status = 'NEW'.
    IF sy-subrc <> 0.
      LOOP AT SCREEN.
        IF screen-name = 'TC319_INSERT' OR
           screen-name = 'TC319_DELETE'. " OR
*           SCREEN-NAME = 'ZFIVMSBANK-STATUS'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ELSE.
* End of <> on 03122010
      LOOP AT SCREEN.
        IF screen-name = 'ZFIVMSBANK-STATUS'.
          screen-invisible = '0' . "'1'. "04092010
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ELSEIF g_okcode931 = 'DISPLAY' OR
         g_okcode931 = 'DELETE'.
    LOOP AT SCREEN.
      IF screen-name = 'TC319_INSERT' OR
         screen-name = 'TC319_DELETE' OR
         screen-name = 'TC319_ATTACH'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT SCREEN .                  "270911 "12102011
* Begin of <> on 01062012
      IF screen-group3 = '001' OR screen-group3 = '002' OR screen-group3 = '004'.
*      IF SCREEN-GROUP3 <> '003'.
* End of <> on 01062012
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " SCREEN_ATTRIBUTE0319  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0281  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0281 OUTPUT.
  CASE g_okcode931.
    WHEN 'CHANGE'.
      g_spantext = 'Change'.
      SET PF-STATUS 'S281'.
      SET TITLEBAR 'T281' WITH g_spantext.

    WHEN 'DISPLAY'.
      g_spantext = 'Display'.

      SET PF-STATUS 'S281' EXCLUDING ist_gui.
      SET TITLEBAR 'T281' WITH g_spantext.

    WHEN OTHERS.
      SET PF-STATUS 'S281'.
      SET TITLEBAR 'T281'.
  ENDCASE.

ENDMODULE.                 " STATUS_0281  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_ENTRY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_entry INPUT.
  DATA : l_len  TYPE i.

  IF NOT zfivmsbank-reqno IS INITIAL.
* Begin of <> on 290911
    l_len = strlen( zfivmsbank-reqno ).
    WHILE l_len < '10'.
      CONCATENATE '0' zfivmsbank-reqno INTO zfivmsbank-reqno.
      l_len = l_len + 1.
    ENDWHILE.
* End of <> on 290911


*    *Changed on 25.2.2021
    IF cb_nor EQ 'X'.
      SELECT SINGLE * FROM zfivmsbank INTO wa_zfivmsbank WHERE reqno = zfivmsbank-reqno AND  zbnkt EQ ' '..  "#EC CI_NOORDER
    ELSEIF cb_emd = 'X'.
      SELECT SINGLE * FROM zfivmsbank INTO wa_zfivmsbank WHERE reqno = zfivmsbank-reqno AND zbnkt NE ' '.  "#EC CI_NOORDER


    ENDIF.
*******    End  on 25.2.2021

    IF sy-subrc <> 0.
      MESSAGE e098(zfi).                   "e092(zfi) 190911]
    ENDIF.
  ELSE.
    MESSAGE e092(zfi).
  ENDIF.
ENDMODULE.                 " CHECK_ENTRY  INPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE319_TC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute319_tc OUTPUT.

  IF g_okcode931 = 'CREATE'.
    DESCRIBE TABLE g_tc319_itab LINES l_lines.
    IF l_lines > 0.
      LOOP AT SCREEN.
        IF g_tc319_wa-lifnr IS INITIAL.
          IF screen-name = 'ZFIVMSBANK-LIFNR'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
* Begin of <> on 17062012
        IF g_tc319_wa-status = 'NEW' OR
          g_tc319_wa-status = 'APPROVED BY HOF 'OR
          g_tc319_wa-status = 'RELEASE BY VMC ' OR
          g_tc319_wa-status = 'RELEASE BY VMC FOR OVL' OR
*          G_TC319_WA-STATUS = 'REGISTRATION SUCCESSFUL' OR "added by ss on 9/3/21
          g_tc319_wa-status = 'SENT TO SBI'.

          IF screen-name = 'ZFIVMSBANK-BANKL_NEW' OR
             screen-name = 'ZFIVMSBANK-BANKN_NEW' OR
             screen-name = 'ZFIVMSBANK-KOINH_NEW'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
*        if G_TC319_WA-STATUS = 'REJECTED BY VMC' or
*           G_TC319_WA-STATUS = ''.
          IF screen-name = 'ZFIVMSBANK-BANKL_NEW' OR
             screen-name = 'ZFIVMSBANK-BANKN_NEW' OR
             screen-name = 'ZFIVMSBANK-KOINH_NEW'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
* End of <> on 17062012
*        if not G_TC319_WA-exist is initial and not G_TC319_WA-lifnr is initial.
*          if SCREEN-NAME = 'ZFIVMSBANK-LIFNR' OR            "08092010
*             SCREEN-NAME = 'ZFIVMSBANK-BANKL' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKN' OR
*             SCREEN-NAME = 'ZFIVMSBANK-KOINH' OR
*             SCREEN-GROUP2 = '002'.
*            SCREEN-INPUT = 0.
*            MODIFY SCREEN.
*          endif.
*
*        elseif not G_TC319_WA-sel319 is initial and not G_TC319_WA-lifnr is initial.
*          if SCREEN-NAME = 'ZFIVMSBANK-LIFNR' OR            "28062010
*             SCREEN-NAME = 'ZFIVMSBANK-BANKL' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKN' OR
*             SCREEN-NAME = 'ZFIVMSBANK-KOINH'.
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*          endif.
*        elseif G_TC319_WA-lifnr is initial.
*          IF SCREEN-NAME = 'ZFIVMSBANK-LIFNR'. "OR 09062010
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*          endif.
*        elseif G_TC319_WA-STATUS = 'REJECTED BY VMC'.
**          if SCREEN-NAME = 'ZFIVMSBANK-LIFNR' OR            "09062010
**             SCREEN-NAME = 'ZFIVMSBANK-BANKL' OR
**             SCREEN-NAME = 'ZFIVMSBANK-BANKN' OR
**             SCREEN-NAME = 'ZFIVMSBANK-KOINH' OR
*
**            SCREEN-GROUP2 = '002'.
*          if SCREEN-NAME = 'ZFIVMSBANK-BANKL_NEW' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKN_NEW' OR
*             SCREEN-NAME = 'ZFIVMSBANK-KOINH_NEW'.
*             SCREEN-INPUT = 1.
*             MODIFY SCREEN.
*          endif.
*        endif.
      ENDLOOP.
    ENDIF.
    CLEAR : l_lines .
  ELSEIF g_okcode931 = 'CHANGE'.
    DESCRIBE TABLE g_tc319_itab LINES l_lines.
    IF l_lines > 0.
* Begin of <> on 12102011
      IF g_tc319_wa-status = 'NEW'.
        LOOP AT SCREEN.
          IF screen-name = 'ZFIVMSBANK-LIFNR'  OR
             screen-group2 = '002'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF  screen-group4 = '004'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.

*      if G_TC319_WA-status = 'APPROVED BY HOF' or
*         G_TC319_WA-status = 'REJECTED BY HOF'.
*        LOOP AT SCREEN.
*          IF SCREEN-NAME = 'ZFIVMSBANK-LIFNR' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKL' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKN' OR
*             SCREEN-NAME = 'ZFIVMSBANK-KOINH' OR
*             SCREEN-GROUP2 = '002'.
*            SCREEN-INPUT = 0.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      else.
*        LOOP AT SCREEN.
*          IF SCREEN-NAME = 'ZFIVMSBANK-LIFNR' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKL' OR
*             SCREEN-NAME = 'ZFIVMSBANK-BANKN' OR
*             SCREEN-NAME = 'ZFIVMSBANK-KOINH' OR
*             SCREEN-GROUP2 = '002'.
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      endif.
* End of <> on 12102011
    ENDIF.
    CLEAR l_lines.
  ENDIF.
ENDMODULE.                 " SCREEN_ATTRIBUTE319_TC  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC109'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc109_init OUTPUT.
  IF g_tc109_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZFIVMSBANK'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC109_itab'
    IF g_okcode931 = 'APPROVED'. "'RELEASE'.  "270911
*{CR 30007948 added if-endif. for SBS
      IF g_ccode = 'SBS'.
        SELECT * FROM zfivmsbank
           INTO CORRESPONDING FIELDS
           OF TABLE g_tc109_itab WHERE ccode IN ('SBS' ,'SBW') AND status = 'NEW'.
      ELSE.
*}CR 30007948 added if-endif. for SBS

** BOC by ss on 7.4.21

        SELECT * FROM zfivmsbank
     INTO CORRESPONDING FIELDS
     OF TABLE g_tc109_itab WHERE ( ccode = 'OVL' OR ccode = 'OVC' )
                            AND status = 'NEW'.

        IF cb_nor = 'X'.
          DELETE g_tc109_itab WHERE reqno+0(3) = 'EMD'.
        ELSEIF cb_emd = 'X'.
          DELETE g_tc109_itab WHERE reqno+0(3) NE 'EMD'.
        ENDIF.

**      EOC by ss on 7.4.21

*        SELECT * FROM ZFIVMSBANK
*           INTO CORRESPONDING FIELDS
*           OF TABLE G_TC109_ITAB WHERE CCODE = G_CCODE AND STATUS = 'NEW'. "commented by ss on 7.4.21
      ENDIF.
    ELSEIF g_okcode931 = 'RELEASE'. "'APPROVED'.  "270911
      SELECT * FROM zfivmsbank
         INTO CORRESPONDING FIELDS
* Begin of <> on 15122010
          OF TABLE g_tc109_itab WHERE status = 'APPROVED BY HOF'.
*         OF TABLE G_TC109_ITAB WHERE ccode = g_ccode and STATUS = 'APPROVED BY HOF'.
* End of <> on 15122010
    ENDIF.

    g_tc109_copied = 'X'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SORT g_tc109_itab BY reqno.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    DELETE ADJACENT DUPLICATES FROM g_tc109_itab COMPARING reqno.
    g_tc109_itab_temp9[] = g_tc109_itab[].
    REFRESH CONTROL 'TC109' FROM SCREEN '0109'.
  ENDIF.
ENDMODULE.                    "TC109_INIT OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC109'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc109_move OUTPUT.
  MOVE-CORRESPONDING g_tc109_wa TO zfivmsbank.
ENDMODULE.                    "TC109_MOVE OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC109'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc109_get_lines OUTPUT.
  g_tc109_lines = sy-loopc.
ENDMODULE.                    "TC109_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0109  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0109 OUTPUT.
  SET PF-STATUS 'S109'.
  IF g_okcode931 = 'APPROVED'. "'RELEASE'.       "270911
    SET TITLEBAR 'T109' WITH g_title_release.  "#EC CI_USAGE_OK[2370131]
  ELSEIF g_okcode931 = 'RELEASE'. "'APPROVED'.   "270911
    SET TITLEBAR 'T109' WITH g_title_approve.  "#EC CI_USAGE_OK[2370131]
  ENDIF.
ENDMODULE.                 " STATUS_0109  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0531  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0531 OUTPUT.
  SET PF-STATUS 'S531'.
  IF g_okcode931 = 'APPROVED'. "'RELEASE'.  270911
    SET TITLEBAR 'T531' WITH g_title_release.
  ELSEIF g_okcode931 = 'RELEASE'. "'APPROVED'.  270911
    SET TITLEBAR 'T531' WITH g_title_approve.
  ENDIF.
*  SET TITLEBAR 'T531'.

ENDMODULE.                 " STATUS_0531  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC531'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc531_init OUTPUT.
  IF g_tc531_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZFIVMSBANK'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC531_itab'

    IF g_okcode931 = 'RELEASE'. "'APPROVED'. 270911
      SELECT * FROM zfivmsbank
      INTO CORRESPONDING FIELDS
      OF TABLE g_tc531_itab WHERE reqno  = g_tc109_wa-reqno
                              AND status = 'APPROVED BY HOF'.
    ELSE.
* Begin of <> on 22062012
      SELECT * FROM zfivmsbank
      INTO CORRESPONDING FIELDS
      OF TABLE g_tc531_itab WHERE reqno = g_tc109_wa-reqno
                             AND status = 'NEW'.
*      SELECT * FROM ZFIVMSBANK
*      INTO CORRESPONDING FIELDS
*      OF TABLE G_TC531_ITAB where reqno = G_TC109_WA-reqno .

* End of <> on 22062012
    ENDIF.


    g_tc531_itab_temp[] = g_tc531_itab[].
    g_tc531_copied = 'X'.
    REFRESH CONTROL 'TC531' FROM SCREEN '0531'.
  ELSE.
    LOOP AT g_tc531_itab INTO g_tc531_wa.  "Added on 290911
      CLEAR g_tc531_wa-sel531.
      MODIFY g_tc531_itab FROM g_tc531_wa.
    ENDLOOP.
    REFRESH CONTROL 'TC531' FROM SCREEN '0531'.
  ENDIF.
ENDMODULE.                    "TC531_INIT OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC531'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc531_move OUTPUT.
  IF g_tc531_wa-approve IS INITIAL.
    MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
  ELSE.
    MOVE-CORRESPONDING g_tc531_wa TO zfivmsbank.
    g_release = 'X'.
    g_reject  = ''.
  ENDIF.
ENDMODULE.                    "TC531_MOVE OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_DETAILS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_details OUTPUT.
  DATA : l_date            TYPE datum,
         wa_usr02          TYPE usr02,
         wa_pa0105         TYPE pa0105,
         wa_pa0001         TYPE pa0001,
         wa_zmm_vms_cr_new TYPE zmm_vms_cr_new,
         wa_zmm_vms_crusr  TYPE zmm_vms_crusr.

  SELECT SINGLE * FROM usr02 INTO wa_usr02 WHERE bname = sy-uname.
  IF sy-subrc NE 0.
    MESSAGE e043(zhelp).
  ELSE.

    MOVE sy-datum TO l_date.
****    Start of change on 09.08.2016 for OVl
*-------Commented & Added by Manisha bh.Dt:08.08.2017----------*
**    SELECT SINGLE * FROM zpa0105 INTO wa_pa0105 WHERE usrid = sy-uname.
**    IF sy-subrc = 0.
**      SELECT SINGLE * FROM zpa0001 INTO wa_pa0001 WHERE pernr  =  wa_pa0105-pernr AND
**                                                       sprps  = ' '              AND
**                                                       endda  >= l_date          AND
**                                                       begda <= sy-datum.
**      IF sy-subrc = 0.
**        g_username =  wa_pa0001-ename.
**       ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ g_cpf      =  wa_pa0001-pernr.
**        g_ccode    =  wa_pa0001-bukrs.
**      ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*    SELECT SINGLE * FROM zpa0001 INTO wa_pa0001 WHERE pernr  =  sy-uname      AND
*                                                      sprps  = ' '            AND
*                                                      endda  >= l_date        AND
*                                                      begda <= sy-datum.
    SELECT * FROM zpa0001 INTO wa_pa0001 UP TO 1 ROWS WHERE pernr  =  sy-uname      AND
                                                      sprps  = ' '            AND
                                                      endda  >= l_date        AND
                                                      begda <= sy-datum ORDER BY PRIMARY KEY.
    ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc = 0.
      g_username =  wa_pa0001-ename.
      g_cpf      =  wa_pa0001-pernr.
*      G_CCODE    =  WA_PA0001-BUKRS.   " commeneted on 5.4.2021 by ss for OVC
*    ENDIF.
*--------------------------------------------------------------*
****    End of change on 09.08.2016 for OVL
*    zfivmsbank-username =  wa_pa0001-ename.
*    zfivmsbank-cpf      =  wa_pa0001-pernr.
*    zfivmsbank-ccode    =  wa_pa0001-bukrs.
****    Start of change on 31.08.2016 for OVl
    ELSE.
*------------Commented & Added by Manisha bh.dt:09.08.2017-------------*
**      SELECT SINGLE * FROM zmm_vms_crusr INTO wa_zmm_vms_crusr WHERE core_user_id = sy-uname.
**      IF sy-subrc = 0.
**        SELECT SINGLE * FROM zpa0105 INTO wa_pa0105 WHERE usrid = wa_zmm_vms_crusr-cpf_no.
**        IF sy-subrc = 0.
**          SELECT SINGLE * FROM zpa0001 INTO wa_pa0001 WHERE pernr  =  wa_pa0105-pernr AND
**                                                           sprps  = ' '              AND
**                                                           endda  >= l_date          AND
**                                                           begda <= sy-datum.
**          IF sy-subrc = 0.
**            g_username =  wa_pa0001-ename.
**            g_cpf      =  wa_pa0001-pernr.
**            g_ccode    =  wa_pa0001-bukrs.
**          ENDIF.
**        ENDIF.
**      ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*      SELECT SINGLE * FROM zmm_vms_cr_new INTO wa_zmm_vms_cr_new WHERE core_user_id = sy-uname.
      SELECT * FROM zmm_vms_cr_new INTO wa_zmm_vms_cr_new UP TO 1 ROWS WHERE core_user_id = sy-uname ORDER BY PRIMARY KEY.
      ENDSELECT.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      IF sy-subrc = 0.
        SELECT SINGLE * FROM zpa0001 INTO wa_pa0001 WHERE pernr =  wa_zmm_vms_cr_new-cpf_no AND
                                                         sprps  = ' '                       AND
                                                         endda  >= l_date                   AND
                                                         begda <= sy-datum.  "#EC CI_NOORDER

        IF sy-subrc = 0.
          g_username =  wa_pa0001-ename.
          g_cpf      =  sy-uname. "wa_pa0001-pernr.
*          G_CCODE    =  WA_PA0001-BUKRS.     " commented on 7.4.21 by ss
        ENDIF.
*      ENDIF.
*-----------------------------------------*
****    End of change on 31.08.2016 for OVL
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " USER_DETAILS  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC531'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc531_get_lines OUTPUT.
  g_tc531_lines = sy-loopc.
ENDMODULE.                    "TC531_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE_0531  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute_0531 OUTPUT.
  IF g_okcode931 = 'APPROVED'. "'RELEASE'.  "270911
    LOOP AT SCREEN.
      IF screen-name = 'ZFIVMSBANK-VMC_ZREMARKS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF g_okcode931 = 'RELEASE'. "'APPROVED'.  270911
    LOOP AT SCREEN.
      IF screen-name = 'ZFIVMSBANK-HOF_ZREMARKS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " SCREEN_ATTRIBUTE_0531  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0430  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0430 OUTPUT.
  CLEAR : ist_gui.
  REFRESH ist_gui.
  IF ist_gui[] IS INITIAL.
    ist_gui-fcode = 'CLEA' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'RETI' . APPEND ist_gui . CLEAR ist_gui .
*    ist_gui-fcode = 'CHAN' . APPEND ist_gui . CLEAR ist_gui .
    """"""""""""""""""""""""""""""""""""""""""""

    ist_gui-fcode = 'RELS' . APPEND ist_gui . CLEAR ist_gui .


    """"""""""""""""""""""""""""""
*    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui . "-rk004
    ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'REPO' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UNBL' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'SINP' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UPDTADDR' . APPEND ist_gui . CLEAR ist_gui .
    ist_gui-fcode = 'UPDTBANK'.  APPEND ist_gui . CLEAR ist_gui. "+SP009.
* Begin of <> on 111010 by Sudhir Sharma
    ist_gui-fcode = 'SEARCH'.   APPEND ist_gui . CLEAR ist_gui.
    ist_gui-fcode = 'BLOC'.     APPEND ist_gui . CLEAR ist_gui.
    ist_gui-fcode = 'HELP'.   APPEND ist_gui . CLEAR ist_gui. "17102011
* End of <> on 111010
  ENDIF.

  AUTHORITY-CHECK OBJECT 'ZMMVCE'
                 ID 'ACTVT' FIELD :'95'.
  IF sy-subrc = 0.
    IF g_trans_mode = 'B'.
      DELETE ist_gui WHERE fcode = 'CHAN'.
      DELETE ist_gui WHERE fcode = 'ASSN'.
    ENDIF.
  ELSE.
    IF g_trans_mode = 'B'.
      DELETE ist_gui WHERE fcode = 'CHAN'.
    ENDIF.
  ENDIF.

  SET TITLEBAR 'TITLE30'.


  IF sy-ucomm = 'EXTN' OR sy-ucomm = 'OPT1'.
    ist_gui-fcode = 'EXTN' . APPEND ist_gui . CLEAR ist_gui .
    CHECK g_trans_mode = 'E'.
    ist_gui-fcode = 'DELE' . APPEND ist_gui . CLEAR ist_gui .

  ENDIF.

  ist_gui-fcode = 'ATCH' . APPEND ist_gui . CLEAR ist_gui . "SP005
  ist_gui-fcode = 'LIST' . APPEND ist_gui . CLEAR ist_gui . "SP005

  SET PF-STATUS 'PF_MAIN' EXCLUDING ist_gui.




ENDMODULE.                 " STATUS_0430  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN_PBO_440  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_pbo_440 OUTPUT.
  LOOP AT  SCREEN.
    CASE g_trans_mode.

        "commented by lipsy on 12.06.2013 for making request open for release rl
*      WHEN 'D' OR 'A' OR 'M' OR 'X'.
        "end of comment by lipsy on 12.06.2013 for making request open for release rl

        """""""""""""""""""""
        "added by lipsy on 12.06.2013 for making request open for release rl

      WHEN 'D' OR 'A' OR 'M' OR 'X' OR 'RL' OR 'AP'.

        "end of addition by lipsy on 12.06.2013
        """""""""""""

        IF screen-group1 = 'UNB'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      WHEN 'N'.
        IF screen-group1 = 'CRE'.
          screen-input = 1.
          screen-required = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDMODULE.                 " SCREEN_PBO_440  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_440  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_screen_440 OUTPUT.
  IF NOT ist_zmm_vend_block[] IS INITIAL.
    READ TABLE ist_zmm_vend_block INTO wa_zmm_vend_block INDEX 1.
    zmm_vend_block-erfdt = wa_zmm_vend_block-erfdt.
    zmm_vend_block-ernam = wa_zmm_vend_block-ernam.
    zmm_vend_block-bukrs = wa_zmm_vend_block-bukrs.

    """"""""""""""""'added by lipsy on 2.08.2013 for release strategy in block
    """"""""" RD1K979902

    IF g_trans_mode <> 'N'.
      zmm_vend_block-assigned_by = wa_zmm_vend_block-assigned_by.
      zmm_vend_block-assign_date = wa_zmm_vend_block-assign_date.
      zmm_vend_block-releasedon = wa_zmm_vend_block-releasedon. "sy-datum.
      zmm_vend_block-releasedby = wa_zmm_vend_block-releasedby. "sy-uname.
      zmm_vend_block-approvedon = wa_zmm_vend_block-approvedon. "sy-datum.
      zmm_vend_block-approvedby = wa_zmm_vend_block-approvedby. "sy-uname.
    ENDIF.

    """""""""""" RD1K979902
    """"""""""""end of addition by lipsy on 2.08.2013 for release strategy in block
  ENDIF.

  CASE g_trans_mode.
    WHEN 'N'.
      zmm_vend_block-erfdt = sy-datum.
      zmm_vend_block-ernam = sy-uname.
    WHEN 'D'.
      zmm_vend_block-assigned_by = wa_zmm_vend_block-assigned_by.
      zmm_vend_block-assign_date = wa_zmm_vend_block-assign_date.

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""
      """"""""""""""""'added by lipsy on 2.08.2013 for release strategy in block
      """"""""" RD1K979902
    WHEN 'RL'.
      zmm_vend_block-releasedon = wa_zmm_vend_block-releasedon. "sy-datum.
      zmm_vend_block-releasedby = wa_zmm_vend_block-releasedby. "sy-uname.
    WHEN 'AP'.
      zmm_vend_block-approvedon = wa_zmm_vend_block-approvedon. "sy-datum.
      zmm_vend_block-approvedby = wa_zmm_vend_block-approvedby.

      """""""""""" RD1K979902
      """"""""""""end of addition by lipsy on 2.08.2013 for release strategy in block
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


  ENDCASE.

  """""""""""""""""""""""""""""""""
  """""""""""added by lipsy on 02.08.2013 for correspondence AND REQUEST STATUS and assigned by
  """"""""" RD1K979902
  IF g_trans_mode <> 'N'.
    IF  zmm_vend_block-assigned_by IS INITIAL OR
     zmm_vend_block-assign_date IS INITIAL OR
       zmm_vend_block-approvedon IS  INITIAL OR
      zmm_vend_block-approvedby IS INITIAL.
      LOOP AT  ist_zmm_vend_block INTO wa_zmm_vend_block.
        IF wa_zmm_vend_block-assigned_by IS NOT INITIAL OR
         wa_zmm_vend_block-assign_date IS NOT INITIAL.
          zmm_vend_block-assigned_by = wa_zmm_vend_block-assigned_by.
          zmm_vend_block-assign_date = wa_zmm_vend_block-assign_date.

        ENDIF.
        IF wa_zmm_vend_block-approvedby IS NOT INITIAL OR
            wa_zmm_vend_block-approvedon IS NOT INITIAL.
          zmm_vend_block-approvedby = wa_zmm_vend_block-approvedby.
          zmm_vend_block-approvedon = wa_zmm_vend_block-approvedon.
        ENDIF.

      ENDLOOP.

    ENDIF.
  ENDIF.


  zmm_vend_block-reqclu = wa_zmm_vend_block-reqclu.
  CONCATENATE 'NOTE' zmm_vend_block-reqno INTO l_tdname.
  CASE g_trans_mode.
    WHEN 'N'.
      notes-text = text_1.
    WHEN OTHERS.
      SELECT SINGLE * FROM stxh WHERE
                           tdobject = 'ZMMVC' AND
                           tdname = l_tdname AND
                           tdid = 'NOTE' AND
                           tdspras = 'EN'.
      IF sy-subrc = 0.
        notes-text = text_2.
        g_cors = 'X'.   "Commented on 17052013 by Sudhir Sharma
      ELSE.
        IF g_trans_mode = 'D' OR
           g_trans_mode = 'X' OR
           g_trans_mode = 'RL'.
          notes-text = text_3.
          g_cors = ''.
        ELSE.
          notes-text = text_1.
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          "added by lipsy on 8.12.2014 for  correction of correspondence check box " RD1K994952
          g_cors  = ''.
          "end of addition by lipsy on 8.12.2014 for  correction of correspondence check box " RD1K994952
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        ENDIF.
      ENDIF.
  ENDCASE.

  """"""""" RD1K979902

  """"""""""""""""""""end of addition  by lipsy on 02.08.2013 for correspondence



  """""""""""""""""""""""""""""""""



ENDMODULE.                 " INIT_SCREEN_440  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_440  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_440 OUTPUT.
  CASE sy-dynnr.
    WHEN '0220'.
      CHECK g_trans_mode = 'N'. "OR g_trans_mode = 'M'.
      IF NOT zmm_hvencrt-bukrs IS INITIAL AND
         ist_vend[] IS INITIAL.
        SET CURSOR FIELD 'WA_VEND-VEND-NAME1' LINE 1.
      ELSEIF NOT zmm_hvencrt-bukrs IS INITIAL AND
             NOT ist_vend[] IS INITIAL  .
        SET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
*    WHEN '0420'.
*      SET CURSOR FIELD g_cursorfield LINE g_cursorline.         "-rk004
*{+rk004
    WHEN '0440'.
      CASE g_trans_mode.
        WHEN 'N'.
          SET CURSOR FIELD 'ZMM_VEND_BLOCK-BUKRS'.

          "commented by lipsy on 12.06.2013
*        WHEN 'M' OR 'D' OR 'A' OR 'X'.
          "end of comment by lipsy on 12.06.2013
          """""""""""""""""""
*added by lipsy on 12.06.2013
        WHEN 'M' OR 'D' OR 'A' OR 'X' OR 'RL'.
          "end of addition by lipsy on 12.06.2013
          """""""""""""""""""""""""""
          SET CURSOR FIELD 'ZMM_VEND_BLOCK-REQNO'.
      ENDCASE.
    WHEN '0450'.
      CASE g_trans_mode.
        WHEN 'N'.
          IF NOT zmm_vend_block-bukrs IS INITIAL.
            SET CURSOR FIELD g_cursorfield LINE g_cursorline.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " SET_CURSOR_440  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISABLE_BUTTON_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disable_button_450 OUTPUT.
  CASE g_trans_mode.

      "commented by lipsy on 12.06.2013
*    WHEN 'D' OR 'X'.
      "end of comment by lipsy on 12.06.2013

      """""""""""""""""""
      "added by lipsy on 12.06.2013 for including release
    WHEN 'D' OR 'X' OR 'RL'.
      "end of addition  by lipsy on 12.06.2013  including release

      """""""""""""""""""""""

      LOOP AT SCREEN.
        IF screen-group1 = '110'.
          screen-input = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDMODULE.                 " DISABLE_BUTTON_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISP_ADDRESS_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE disp_address_450 OUTPUT.
* DATA wa_lfa1 LIKE lfa1.
*  DATA l_werks LIKE ist_extn-werks.

* Begin of <> on 21042011
*  break cab_sudhir.
*  data : l_flag1.
** Begin of <> on 28042011
*  if l_flag1 is initial and not ist_bl is initial.
*      l_flag1 = 'X'.
*      ist_bl_temp[] = ist_bl[].
*  endif.
*  if not ist_bl is initial.
*    read table ist_bl index 1.
*    if sy-subrc = 0.
*      if not ist_bl-rsn is initial.
*        if ok_code = 'ENTE' and l_flag1 is initial.
*          l_flag1 = 'X'.
** End of <> on 21042011
*          ist_bl_temp[] = ist_bl[].    "05012011 by Sudhir Sharma
*        endif.
*      endif.
*    endif.
*  endif.
* End of <> on 28042011
  CLEAR :g_addrnumber.

  IF g_block_vendor = 'X'.
    g_lifnr = ist_bl-lifnr.
  ELSE.
    g_lifnr = ist_extn-lifnr.
  ENDIF.

  IF NOT g_lifnr IS INITIAL.
    SELECT SINGLE * FROM lfa1 INTO wa_lfa1 WHERE
                                        lifnr = g_lifnr.

    IF g_block_vendor = 'X'.

      g_sperm = ist_bl-sperm.
      g_sperr = ist_bl-sperr.
      g_blrfq = ist_bl-blrfq.
      g_loevm = ist_bl-loevm.

      MOVE-CORRESPONDING wa_lfa1 TO ist_bl.

*+SP013 - Mobile Number
      SELECT SINGLE tel_number FROM adr2 INTO (ist_bl-mob_number)
                              WHERE addrnumber = wa_lfa1-adrnr AND
                                    r3_user    = '3'.  "#EC CI_NOORDER

*+SP013 - End

*+SP006 - Additional Address
      ist_bl-sperm = g_sperm.
      ist_bl-sperr = g_sperr.
      ist_bl-blrfq = g_blrfq.
      ist_bl-loevm = g_loevm.                              "SS 06122010

      MOVE wa_lfa1-stras      TO ist_bl-stras1.

      SELECT SINGLE str_suppl1 str_suppl2 str_suppl3 location FROM  adrc
                   INTO (ist_bl-suppl1,ist_bl-suppl2,ist_bl-suppl3,
                                             ist_bl-ort02)
                                        WHERE addrnumber = wa_lfa1-adrnr.  "#EC CI_NOORDER

      SELECT SINGLE smtp_addr FROM adr6 INTO (ist_bl-email)
                                WHERE addrnumber = wa_lfa1-adrnr.  "#EC CI_NOORDER
*+SP006 - end

    ELSE.
      l_werks = ist_extn-werks.
      MOVE-CORRESPONDING wa_lfa1 TO ist_extn.
      ist_extn-werks = l_werks.
    ENDIF.
  ENDIF.
ENDMODULE.                 " DISP_ADDRESS_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TAB_UNBL_LINES_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_tab_unbl_lines_450 OUTPUT.
  g_detail_lines = sy-loopc.
  tab_bl-lines = '9999'.
ENDMODULE.                 " GET_TAB_UNBL_LINES_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN_ATTR_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen_attr_450 OUTPUT.
  CASE g_trans_mode.
*    WHEN 'A' OR 'D'.                                       "-RK004
*    WHEN 'A' OR 'D' OR 'X'.                        "+RK004 "-SP006

      "commented by lipsy on 12.06.2013 for making vendor ,reason greyed for release
*    WHEN 'D' OR 'X'.                                        "+SP006
      "end of comment   by lipsy on 12.06.2013 for making vendor ,reason greyed for release

      "added by lipsy on 12.06.2013 for making vendor ,reason greyed for release
    WHEN 'D' OR 'X' OR 'RL'.
      "end of add by lipsy on 12.06.2013 for making vendor ,reason greyed for release

      LOOP AT SCREEN.
        IF screen-group1 = '100'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.

*+SP006 - Assign
    WHEN 'A'.
      LOOP AT SCREEN.
        IF screen-group2 = 'BLK'.
          screen-input = 0.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.
      ENDLOOP.

*+SP006
  ENDCASE.
ENDMODULE.                 " SET_SCREEN_ATTR_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_REC_STATUS_BLOCK_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_rec_status_block_450 OUTPUT.
  IF ist_bl-del_flag = 'X'.
    PERFORM create_icon USING 'ICON_DELETE'
                        CHANGING g_status_icon.
  ELSEIF ist_bl-ass_flag = 'X'.
    PERFORM create_icon USING 'ICON_CHECKED'
                     CHANGING g_status_icon.

  ENDIF.
ENDMODULE.                 " SET_REC_STATUS_BLOCK_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_cursor_450 OUTPUT.
  CASE sy-dynnr.
    WHEN '0220'.
      CHECK g_trans_mode = 'N'. "OR g_trans_mode = 'M'.
      IF NOT zmm_hvencrt-bukrs IS INITIAL AND
         ist_vend[] IS INITIAL.
        SET CURSOR FIELD 'WA_VEND-VEND-NAME1' LINE 1.
      ELSEIF NOT zmm_hvencrt-bukrs IS INITIAL AND
             NOT ist_vend[] IS INITIAL  .
        SET CURSOR FIELD g_cursorfield LINE g_cursorline.
      ENDIF.
*    WHEN '0420'.
*      SET CURSOR FIELD g_cursorfield LINE g_cursorline.         "-rk004
*{+rk004
    WHEN '0440'.
      CASE g_trans_mode.
        WHEN 'N'.
          SET CURSOR FIELD 'ZMM_VEND_BLOCK-BUKRS'.
        WHEN 'M' OR 'D' OR 'A' OR 'X'.
          SET CURSOR FIELD 'ZMM_VEND_BLOCK-REQNO'.
      ENDCASE.
    WHEN '0450'.
      CASE g_trans_mode.
        WHEN 'N'.
          IF NOT zmm_vend_block-bukrs IS INITIAL.
            SET CURSOR FIELD g_cursorfield LINE g_cursorline.
          ENDIF.
      ENDCASE.
*}+rk004
  ENDCASE.
ENDMODULE.                 " SET_CURSOR_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_TAB_BL_LINES_450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_tab_bl_lines_450 OUTPUT.

  g_detail_lines = sy-loopc.
  tab_unbl-lines = '9999'.

ENDMODULE.                 " GET_TAB_BL_LINES_450  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0430_NEW  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0430_new OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  CLEAR : ist_gui.
  REFRESH ist_gui.

  g_cpf = sy-uname.
  SHIFT g_cpf LEFT DELETING LEADING '0'.
  SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
  WHERE uname = g_cpf AND agr_name IN ('D:MM_PUR_PO_APPROVE_IM',
                                       'D:MM_PUR_PO_APPROVE_L3',
                                       'D:MM_SRV_IND_APPROVE_L3',
                                       'D:MM_PUR_PO_APPROVE_L2',
                                       'D:MM_SRV_IND_APPROVE_L2',
                                       'D:MM_PUR_PO_APPROVE_L1',
                                       'D:MM_SRV_IND_APPROVE_L1',
                                       'D:MM_SRV_IND_APPROVE_1A',
                                       'D:MM_SRV_IND_APPROVE_1b',
                                       'D:MM_SRV_IND_APPROVE_1c',
                                       'D:MM_SRV_IND_APPROVE_1d',
                                       'D:MM_SRV_IND_APPROVE_1E').
  IF sy-subrc <> 0.
    SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
    WHERE uname = g_cpf AND agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
    IF sy-subrc <> 0.
      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_430' EXCLUDING ist_gui.
    ELSE.
      ist_gui-fcode = 'APPR' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_430' EXCLUDING ist_gui.
    ENDIF.
  ELSE.
    SELECT * FROM agr_users INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
    WHERE uname = g_cpf AND agr_name = 'D:FI_VEM_MASTER_MAINTAIN'.
    IF sy-subrc <> 0.

      ist_gui-fcode = 'ASSN' . APPEND ist_gui . CLEAR ist_gui .
      SET PF-STATUS 'PF_430' EXCLUDING ist_gui.
    ELSE.
      SET PF-STATUS 'PF_430' EXCLUDING ist_gui.
    ENDIF.
  ENDIF.


ENDMODULE.                 " STATUS_0430_NEW  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0152  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0152 OUTPUT.
  SET PF-STATUS 'S152'.
  SET TITLEBAR 'T152'.
ENDMODULE.                 " STATUS_0152  OUTPUT

*+SP015 : Start
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
* Set PF Status & Title : Screen 0700
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  SET PF-STATUS 'S700'.
  SET TITLEBAR 'T700'.

ENDMODULE.                 " STATUS_0700  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0750  OUTPUT
*&---------------------------------------------------------------------*
* Set PF Status & Title : Screen 0750
*----------------------------------------------------------------------*
MODULE status_0750 OUTPUT.

*  SET PF-STATUS 'S750'.

  CASE g_ok_code_700.

    WHEN 'SRP'.                   "Set Related Party

      SET PF-STATUS 'S750'.

      SET TITLEBAR 'T750S'.

    WHEN 'RRP'.                   "Release Related Party

      REFRESH ist_pf_status.

      MOVE 'CHKA' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'UCHK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'BLNK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S750' EXCLUDING ist_pf_status.

      SET TITLEBAR 'T750R'.

    WHEN 'ARPC'.         "Approve Related Party(C1) - Incharge Finance

      REFRESH ist_pf_status.

      MOVE 'CHKA' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'UCHK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'BLNK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S750' EXCLUDING ist_pf_status.

      SET TITLEBAR 'T750AC'.

    WHEN 'ARP'.                   "Approve Related Party(L1)

      REFRESH ist_pf_status.

      MOVE 'CHKA' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'UCHK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      MOVE 'BLNK' TO wa_pf_status-fcode.
      APPEND wa_pf_status TO ist_pf_status.

      SET PF-STATUS 'S750' EXCLUDING ist_pf_status.

      SET TITLEBAR 'T750A'.
  ENDCASE.

ENDMODULE.                 " STATUS_0750  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_ATTR_0750  OUTPUT
*&---------------------------------------------------------------------*
* To initialize screen attributes
*----------------------------------------------------------------------*
MODULE init_screen_attr_0750 OUTPUT.

  IF g_ok_code_700 = 'RRP'  OR
     g_ok_code_700 = 'ARPC' OR
     g_ok_code_700 = 'ARP'.

    LOOP AT SCREEN.

      IF screen-group1 = 'SRP'.

        screen-input = '0'.
        MODIFY SCREEN.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDMODULE.                 " INIT_SCREEN_ATTR_0750  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_0750  OUTPUT
*&---------------------------------------------------------------------*
*   To move Vendor's related partner record into table control
*----------------------------------------------------------------------*
MODULE fill_table_control_0750 OUTPUT.
  MOVE-CORRESPONDING wa_zmm_vms_tp_set TO wa_zmm_vms_tp_set_tc.
ENDMODULE.                 " FILL_TABLE_CONTROL_0750  OUTPUT
*+SP015 : End
*&---------------------------------------------------------------------*
*&      Module  STATUS_0240  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0240 OUTPUT.
  SET PF-STATUS '0240'.
  SET TITLEBAR '240'.

ENDMODULE.                 " STATUS_0240  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SCREEN_ATTRIBTE_OCL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM screen_attribte_ocl .


  LOOP AT SCREEN.
    CASE g_trans_mode.
      WHEN 'N' OR 'M'.
        IF NOT ist_vend[] IS INITIAL.
          READ TABLE ist_vend INDEX tab_ctl-current_line.
          IF sy-subrc IS INITIAL.
            CHECK ist_vend-fnd_flg = 'X' OR ist_vend-fnd_flg = 'M'.

            IF screen-group1 = 'B2'
               AND wa_vend-vend-j_1kftbus = 'OEM'.
              IF g_trans_mode = 'M' AND g_src_button = ' '.
                screen-input = '0'.
              ELSE.
                screen-input = '1'.
                screen-required = '1'.
              ENDIF.
              MODIFY SCREEN.
            ENDIF.

*----- type of business field to be enabled for pmat -----------*
            IF screen-group1 = 'B1'.
*              IF ZMM_HVENCRT-EKORG = 'PMAT'.   "commented on 5.12.2005
              IF zmm_hvencrt-ktokk = 'IMMI' OR
                 zmm_hvencrt-ktokk = 'IMMF'.
                screen-input = '1'.
                screen-required = '1'.
                IF g_trans_mode = 'M' AND g_src_button = ' '.
                  screen-input = '0'.
                ENDIF.
              ELSE.
                screen-invisible = '1'.
                screen-input = '0'.
              ENDIF.
              MODIFY SCREEN.
            ENDIF.
*----- end of type of bus. code --------------------------------*
*----- type of PAN field to be required & enabled for pmat -----------* 16052014
            IF screen-group4 = 'PAN'.
              IF zmm_hvencrt-ktokk = 'IMMI' OR
                 zmm_hvencrt-ktokk = 'SVWI' OR zmm_hvencrt-ktokk = 'IMMF' OR zmm_hvencrt-ktokk = 'SVWF'.
                screen-input = '1'.
                screen-required = '1'.
              ENDIF.
              MODIFY SCREEN.
            ENDIF.
*----- CODE FOR MODIFY ROW BUTTON IN CHANGE MODE ----------------*
            IF ( screen-group1 = 'T1' OR screen-group1 = 'T2' OR
                 screen-group1 = 'B1' OR screen-group1 = 'B2' ) AND
                 g_trans_mode = 'M' AND g_mod_button <> ' ' AND
                 ist_vend-mark = 'X'.
              screen-input = '1'.
              IF wa_vend-vend-j_1kftbus = 'OTHERS' AND
                 screen-group1 = 'B2'.
                screen-input = 0.
              ENDIF.

              """"""""""""""""""""""""""""""""""""""""
              """""""""""""""""""""""""""""""""""""""
              """""""""""""""""""""""""""""""""""""""""""""""""""""""
              "code added by lipsy for making mobile
              "number compulsory during vendor change on 26.08.2013 RD1K979902

              IF (   screen-name = 'WA_VEND-VEND-MOB_NUMBER' ) AND
                              g_trans_mode = 'M' .
                screen-required = '1'.
              ENDIF.
              "end of code added by lipsy for making mobile
              "number compulsory during vendor change on 26.08.2013 RD1K979902
              """"""""""""""""""""""""""""""""""""""""
              """"""""""""""""""""""""""


              """""""""""""""""""""""""""""""""""""""""



              PERFORM upd_screen_attr_220.                  "+SP007

              PERFORM upd_screen_attr_bank_220.             "+SP010

              MODIFY SCREEN.
              CONTINUE.
            ENDIF.

            """""""""""""""""""""""""""""""""""""""
            """"""""""""""""""""""""""



*---- CODE1 START FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*

            IF ( screen-group1 = 'T1' OR screen-group1 = 'T2' ) AND
                 g_trans_mode = 'N'.
              screen-input = '1'.
              MODIFY SCREEN.
            ELSEIF ( screen-group1 = 'T1' OR screen-group1 = 'T2' ) AND
               g_trans_mode = 'M' AND g_src_button = 'X' AND
               ist_vend-fnd_flg = 'M'. "and
              screen-input = '1'.
              MODIFY SCREEN.
            ENDIF.

            IF ( zmm_hvencrt-ass_flag = 'P' OR
            zmm_hvencrt-ass_flag = 'R' ) AND
            NOT wa_vend IS INITIAL AND screen-group1 = 'T5'.
              screen-input = 1.
              MODIFY SCREEN.
            ENDIF.

*---- CODE1 END FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*

            IF screen-group1 = 'T2'  AND
               screen-name = 'WA_VEND-VEND-ORT01' AND
               g_vend GE tab_ctl-current_line.
              screen-input = '1'.
              screen-required = '1'.
              MODIFY SCREEN.
            ENDIF.

            IF ( ( zmm_hvencrt-ktokk = 'IMMI' OR
                   zmm_hvencrt-ktokk = 'SVWI' OR

  zmm_hvencrt-ktokk = 'IMMF' OR
  zmm_hvencrt-ktokk = 'SVWF'
 )  AND
                 ( zmm_hvencrt-ekorg = 'PMAT' OR
                   zmm_hvencrt-ekorg = 'PSRV' ) ) AND
                   screen-name = 'WA_VEND-VEND-LAND1'.
*    BOC on 21.3.21 by ss changes for  Company Code 'OVC'
*    wa_vend-vend-land1 = 'IN'.
              IF zmm_hvencrt-bukrs = 'OVC'.
                wa_vend-vend-land1 = 'CO'.
              ELSE.
                wa_vend-vend-land1 = 'IN'.
              ENDIF.
*    EOC on 21.3.21 by ss


              screen-input = '0'.
              screen-required = '0'.
              MODIFY SCREEN.
            ENDIF.

            IF screen-group1 = 'T1' AND
               g_vend EQ tab_ctl-current_line AND
               g_src_button <> ' ' .
              screen-input = '1' .
              IF screen-name = 'WA_VEND-VEND-STRAS1' OR
                 screen-name = 'WA_VEND-VEND-PSTLZ' OR
                 screen-name = 'WA_VEND-VEND-REGIO' OR
                 screen-name = 'WA_VEND-VEND-LAND1' OR
                 screen-name = 'WA_VEND-VEND-BRSCH' OR
                 screen-name = 'WA_VEND-VEND-WAERS' OR
*                 SCREEN-NAME = 'WA_VEND-VEND-ORT02' OR
                """"""""""""""
                """"""added by lipsy on 9.02.2013  RD1K979902 for making mobile number mandatory
                screen-name = 'WA_VEND-VEND-MOB_NUMBER' OR
                "end of addition by lipsy on 9.02.2013  RD1K979902
                """""""""""""""""""
                 screen-name = 'WA_VEND-VEND-EMAIL' OR  "RD1K976705 CR No.30005915 062011
                 screen-name = 'WA_VEND-VEND-SORTL'.
                screen-required = '1'.
              ENDIF.
              IF zmm_hvencrt-bukrs = 'OVL'. " Bipin
                IF (  zmm_hvencrt-ktokk = 'IMMI' OR
                     zmm_hvencrt-ktokk = 'SVWI' OR

    zmm_hvencrt-ktokk = 'IMMF' OR
    zmm_hvencrt-ktokk = 'SVWF' ) AND
                   ( screen-name = 'WA_VEND-VEND-ORT02' OR
                     screen-name = 'WA_VEND-VEND-PSTLZ' OR
                     screen-name = 'WA_VEND-VEND-REGIO' ).
                  screen-required = '0'.

                  IF screen-name = 'WA_VEND-VEND-PSTLZ'.
                    screen-required = '1'.
                  ENDIF.
                ENDIF.
              ENDIF.

              IF ( ( zmm_hvencrt-ktokk = 'IMMI' OR
                     zmm_hvencrt-ktokk = 'SVWI' OR

  zmm_hvencrt-ktokk = 'IMMF' OR
  zmm_hvencrt-ktokk = 'SVWF'


                )  AND
                   ( zmm_hvencrt-ekorg = 'PMAT' OR
                     zmm_hvencrt-ekorg = 'PSRV' ) ) AND
                   screen-name = 'WA_VEND-VEND-LAND1'.

*     BOC on 21.3.21 by ss changes for  Company Code 'OVC'
*    wa_vend-vend-land1 = 'IN'.
                IF zmm_hvencrt-bukrs = 'OVC'.
                  wa_vend-vend-land1 = 'CO'.
                ELSE.
                  wa_vend-vend-land1 = 'IN'.
                ENDIF.
*    EOC on 21.3.21 by ss

*                WA_VEND-VEND-LAND1 = 'IN'.
                screen-input = '0'.
                screen-required = '0'.
              ENDIF.

              PERFORM upd_screen_attr_220.                  "+SP007

              PERFORM upd_screen_attr_bank_220.             "+SP010

              MODIFY SCREEN.
              CONTINUE.
            ENDIF.

            IF tab_ctl-current_line LT g_vend AND
               g_src_button <> ' ' AND
               screen-group1 = 'T2'.
              screen-input = '0' .
              MODIFY SCREEN.
            ENDIF.

*+SP015 : Start
*Set Related Partner as a mandatory field
            IF   screen-group1 = 'SRP' AND
               ( zmm_hvencrt-ktokk = 'IMMF' OR
                 zmm_hvencrt-ktokk = 'IMMI' OR
                 zmm_hvencrt-ktokk = 'SVWF' OR
                 zmm_hvencrt-ktokk = 'SVWF' ).

              screen-input    = '1'.
*             screen-required = '1'.
              screen-required = '0'.
              MODIFY SCREEN.

            ENDIF.
*+SP015 : End

          ELSE.
*---- CODE2 START FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*
            IF ( zmm_hvencrt-ass_flag = 'P' OR
                 zmm_hvencrt-ass_flag = 'R' ) AND
                 wa_vend IS INITIAL.
              IF screen-group1 = 'T1' OR screen-group1 = 'T2'.
                screen-input = '0'.
                screen-required = '0'.
                MODIFY SCREEN.
                CONTINUE.
              ENDIF.
            ENDIF.

          ENDIF.
*---- CODE2 END FOR SCREEN WHEN REJECTION OF LINE ITEM ----------*
        ENDIF.

*Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
*IF  ZMM_HVENCRT-KTOKK = 'LAQ1' AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER' or screen-name = 'WA_VEND-VEND-EMAIL' ).
*                   screen-required = '0'.
*                MODIFY SCREEN.
*endif.
*END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572

      WHEN 'D' OR 'X' OR 'R' OR 'A'.
        IF screen-group1 = 'T1' OR screen-group1 = 'T2' OR
           screen-group1 = 'T5' OR screen-group1 = 'T6' OR
           screen-group1 = 'T7'.
          IF screen-group1 = 'T6' AND g_trans_mode = 'A' AND
             tab_ctl-current_line LE g_vend.
            screen-input = 1.
          ELSE.
            screen-input = '0' .
          ENDIF.
          IF ( screen-group1 = 'T7' OR  screen-group1 = 'T5' ) AND
               g_trans_mode = 'A' AND
               tab_ctl-current_line LE g_vend.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
          CONTINUE.
        ENDIF.

    ENDCASE.
  ENDLOOP.

*Begin RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572
  LOOP AT SCREEN.
    IF  zmm_hvencrt-ktokk = 'LAQ1'
       AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER'
               OR screen-name = 'WA_VEND-VEND-EMAIL' ).
      screen-required = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*END RD1K994280 CAB_ALOK VMS: Modifications regarding LAQ  - CR 30011572

*Begin RD1K996796 CAB_SANDEEP  ZMMVMS: Modifications regarding SHYG - CR 30012586
*Begin RD1K995096 CAB_ALOK ZMMVMS: Modifications regarding NOMI - CR 30011919
  LOOP AT SCREEN.
    IF  ( zmm_hvencrt-ktokk = 'NOMI' OR zmm_hvencrt-ktokk = 'SHYG' )
       AND ( screen-name = 'WA_VEND-VEND-MOB_NUMBER'
               OR screen-name = 'WA_VEND-VEND-EMAIL' ).
      screen-required = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9030  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9030 OUTPUT.
  SET PF-STATUS 'HSN_UPD'.
  SET TITLEBAR 'GST'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9030 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'UP'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.

    WHEN 'CRET'.
      CALL SCREEN  9031.
*      call SCREEN  9032.

*      call screen 9033.


    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9031  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9031 OUTPUT.
  SET PF-STATUS 'HSN_UPD_COMM'.
  SET TITLEBAR 'GST  Update'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9031  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE  user_command_9031 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'UP'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'SUB_CRT'.

      PERFORM check_input.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input .


*  IF IT_ZMM_GST_UPD IS INITIAL.
*
*    MESSAGE 'Please provide input' TYPE 'S'.
*
*   else.
*
*     SELECT lifnr
*            BUKRS
*       INTO CORRESPONDING FIELDS OF TABLE it_lfb1
*       FROM lfb1
*       FOR ALL ENTRIES IN IT_ZMM_GST_UPD
*       WHERE lifnr = IT_ZMM_GST_UPD-VENDOR_NO.
*
*       IF  it_lfb1 IS INITIAL.
*
*          LOOP AT IT_ZMM_GST_UPD INTO WA_ZMM_GST_UPD.
*
*            WA_ZMM_GST_UPD-REMARKS = 'Vendor not found'.
*            modify it_zmm_gst_upd FROM wa_zmm_gst_upd.
*          ENDLOOP.
*
*       ENDIF.
*
*  ENDIF.



ENDFORM.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_UPD'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_upd_change_tc_attr OUTPUT.
  DESCRIBE TABLE it_upd_item LINES tc_upd-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_UPD'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_upd_get_lines OUTPUT.
  g_tc_upd_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9100 OUTPUT.
  SET PF-STATUS 'PF_9100'.
  SET TITLEBAR 'ST_9100'.
  udm = 'UDYAM'.
  IF flag_rf = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'GRP'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
      IF screen-group1 = 'GP'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF flag_scr = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'GRP'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
      IF screen-group1 = 'GP'.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    SELECT SINGLE * FROM setleaf INTO @DATA(t_acc1) WHERE setname = 'ZFI_UDYOG' AND valfrom = @s_lfa1-brsch.
    IF sy-subrc NE 0.
      LOOP AT SCREEN .
        IF screen-group1 = 'UD'.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  TC321_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc321_init OUTPUT.
  IF g_okcode931 <> 'CREATE'.
*     AND g_okcode931 <> 'ENTER' . "added by ss
    IF g_tc321_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZFIVMSBANK'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC321_itab'
      SELECT * FROM zfivmsbank
      INTO CORRESPONDING FIELDS
      OF TABLE g_tc321_itab WHERE reqno = zfivmsbank-reqno AND
                                  zbnkt NE ' '.

      g_tc321_itab_temp[] = g_tc321_itab[].

      g_tc321_copied = 'X'.
      REFRESH CONTROL 'TC321' FROM SCREEN '0321'.
    ENDIF.

    LOOP AT g_tc321_itab INTO g_tc321_wa.  "Added on 230911
      CLEAR g_tc321_wa-sel321.
      MODIFY g_tc321_itab FROM g_tc321_wa.
    ENDLOOP.
  ELSE.

    REFRESH CONTROL 'TC321' FROM SCREEN '0321'.
  ENDIF.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE321_TC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute321_tc OUTPUT.
  IF g_okcode931 = 'CREATE'.
    DESCRIBE TABLE g_tc321_itab LINES l_lines.

    IF l_lines > 0.

      LOOP AT SCREEN.
        IF g_tc321_wa-lifnr IS INITIAL.
          IF screen-name = 'ZFIVMSBANK-LIFNR'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
* Begin of <> on 17062012
        IF g_tc321_wa-status = 'NEW' OR
           g_tc321_wa-status = 'APPROVED BY HOF 'OR
           g_tc321_wa-status = 'RELEASE BY VMC ' OR
           g_tc321_wa-status = 'RELEASE BY VMC FOR OVL' OR
*           G_TC321_WA-STATUS = 'REGISTRATION SUCCESSFUL' OR "added by ss on 9/3/21
           g_tc321_wa-status = 'SENT TO SBI'.

          IF screen-name = 'ZFIVMSBANK-BANKL_NEW' OR
             screen-name = 'ZFIVMSBANK-BANKN_NEW' OR
             screen-name = 'ZFIVMSBANK-KOINH_NEW'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ELSE.

          IF screen-name = 'ZFIVMSBANK-BANKL_NEW' OR
             screen-name = 'ZFIVMSBANK-BANKN_NEW' OR
             screen-name = 'ZFIVMSBANK-KOINH_NEW'.
*            SCREEN-NAME = 'ZFIVMSBANK-ZBNKT'.      "commented on 3.5.21 by ss
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.
    CLEAR : l_lines .
  ELSEIF g_okcode931 = 'CHANGE'.
    DESCRIBE TABLE g_tc321_itab LINES l_lines.
    IF l_lines > 0.

      IF g_tc321_wa-status = 'NEW'.
        LOOP AT SCREEN.
          IF screen-name = 'ZFIVMSBANK-LIFNR'  OR
             screen-group2 = '002'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
**          Commented on 3.5.21 by ss
*          IF SCREEN-NAME = 'ZFIVMSBANK-ZBNKT'.
*            SCREEN-INPUT = 1.
*            MODIFY SCREEN.
*          ENDIF.

        ENDLOOP.
      ELSE.
        LOOP AT SCREEN.
          IF  screen-group4 = '004'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.



    ENDIF.
    CLEAR l_lines.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC321_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc321_get_lines OUTPUT.
  g_tc321_lines = sy-loopc.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0321  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0321 OUTPUT.

* Begin of <> on 17072012
  DATA : l_cpf1,
         l_ncpf1.
* End of <> on 17072012
  CASE g_okcode931.
    WHEN 'CREATE'.
      g_spantext = 'Create'.
      SET PF-STATUS 'S319'.
      SET TITLEBAR 'T319' WITH g_spantext.

    WHEN 'CHANGE'.
* Begin of <> on 17072012
      READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY cpf = g_cpf.
      IF sy-subrc = 0.
        l_cpf = 'X'.
      ENDIF.
* End of <> on 17072012
* Begin of <> 15122010
      SHIFT g_cpf LEFT DELETING LEADING '0'.                "20062012
      READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY cpf = g_cpf.
      IF sy-subrc = 0.
* Begin of <> on 17072012
        l_ncpf1 = 'X'.
      ENDIF.
      IF l_cpf1 = 'X' OR l_ncpf1 = 'X'.
* End of <> on 17072012
* End of <> 15122010
        g_spantext = 'Change'.
        SET TITLEBAR 'T319' WITH g_spantext.

        READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY status = 'NEW'.
        IF sy-subrc = 0.
          SET PF-STATUS 'S319'.
        ELSE.
* Begin of <RD1K977307> 27072011
          READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY status = 'REJECTED BY HOF'.
          IF sy-subrc = 0.
            SET PF-STATUS 'S319'.
          ELSE.
            READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY status = 'REJECTED BY VMC'.
            IF sy-subrc = 0.
              SET PF-STATUS 'S319'.
            ELSE.
* End of <RD1K977307> 27072011
              ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .
              SET PF-STATUS 'S319' EXCLUDING ist_gui.
            ENDIF.
          ENDIF.
        ENDIF.
* End of <> 27072011
* Begin of <> 15122010
      ELSE.
        g_okcode931 = 'DISPLAY'.
        g_spantext = 'Display'.
        ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .

        SET PF-STATUS 'S319' EXCLUDING ist_gui.
        SET TITLEBAR 'T319' WITH g_spantext.
      ENDIF.
* End of <> 15122010
    WHEN 'DISPLAY'.
      g_spantext = 'Display'.
      ist_gui-fcode = 'SAVE' . APPEND ist_gui . CLEAR ist_gui .

      SET PF-STATUS 'S319' EXCLUDING ist_gui.
      SET TITLEBAR 'T319' WITH g_spantext.

    WHEN OTHERS.
      SET PF-STATUS 'S319'.
      SET TITLEBAR 'T319'.

  ENDCASE.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SCREEN_ATTRIBUTE0321  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE screen_attribute0321 OUTPUT.

  IF g_okcode931 = 'CREATE'.
    LOOP AT SCREEN.                                         "28062010
      IF screen-name = 'ZFIVMSBANK-STATUS'.
*        SCREEN-NAME = 'TC319_DELETE' OR
        screen-invisible = '0'.                             "'1'.
        MODIFY SCREEN.
      ELSEIF screen-group3 = '003'.                         "230911
*      SCREEN-NAME = 'TC319_ATTACH' OR                      "230911
*      SCREEN-NAME = 'TC319_ZLIST' .
        screen-invisible = '1'.
        MODIFY SCREEN.
      ELSEIF screen-name = 'G_CCODE'.   "added on 7.4.21 by ss
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
*      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF g_okcode931 = 'CHANGE'.
* Begin of <> on 03122010
    READ TABLE g_tc321_itab INTO g_tc321_wa WITH KEY status = 'NEW'.
    IF sy-subrc <> 0.
      LOOP AT SCREEN.
        IF screen-name = 'TC321_INSERT' OR
           screen-name = 'TC321_DELETE'. " OR
*           SCREEN-NAME = 'ZFIVMSBANK-STATUS'.
          screen-invisible = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ELSE.
* End of <> on 03122010
      LOOP AT SCREEN.
        IF screen-name = 'ZFIVMSBANK-STATUS'.
          screen-invisible = '0' . "'1'. "04092010
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ELSEIF g_okcode931 = 'DISPLAY' OR
         g_okcode931 = 'DELETE'.
    LOOP AT SCREEN.
      IF screen-name = 'TC321_INSERT' OR
         screen-name = 'TC321_DELETE' OR
         screen-name = 'TC321_ATTACH'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT SCREEN .                  "270911 "12102011
* Begin of <> on 01062012
      IF screen-group3 = '001' OR screen-group3 = '002' OR screen-group3 = '004'.
*      IF SCREEN-GROUP3 <> '003'.
* End of <> on 01062012
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC321_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc321_move OUTPUT.

  MOVE-CORRESPONDING g_tc321_wa TO zfivmsbank.
  IF  zfivmsbank-ccode IS NOT INITIAL.
    g_ccode = zfivmsbank-ccode.
  ENDIF.
ENDMODULE.
