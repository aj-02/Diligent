*--- MAIN PROGRAM: SAPMZOVL_JV_CC_PBO ---*
*&---------------------------------------------------------------------*
*&  Include           SAPMZOVL_JV_CC_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
*  SET PF-STATUS 'ZPF_STATUS'.
*  SET TITLEBAR 'ZTITLE'.

  IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL AND lfct_9000 IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      IF screen-group2 = 'DIS' AND gwa_jv_cc-del_ind NE 'X' AND ( gwa_jv_cc-status_pm  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_fc  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_pfo = 'REJECTED'
                                                            OR    gwa_jv_cc-status_rp  = 'REJECTED'
                                                            OR    gwa_jv_cc-status_rev = 'REJECTED' ).  " added by ss on 24.8.21
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF lfct_9000 NE 'DELE'.
    LOOP AT SCREEN.
      IF screen-group1 = 'CHA'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

    gwa_jv_cc-prj_cord = sy-uname.
  ENDIF.

  IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL AND lfct_9000 IS INITIAL.
    LOOP AT SCREEN.
    IF screen-group4 = 'NA1' AND ( gwa_jv_cc-status_pm  EQ 'REJECTED' OR  gwa_jv_cc-status_pm  EQ 'PENDING'
                             OR    gwa_jv_cc-status_fc  EQ 'PENDING'
                             OR    gwa_jv_cc-status_pfo EQ 'PENDING'
                             OR    gwa_jv_cc-status_rp  EQ 'PENDING'
                             OR    gwa_jv_cc-status_rev EQ 'PENDING' ).
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*****************************************************************************************

  IF r1 = 'X'.
    IF gwa_jv_cc-prj_cord = sy-uname.
       LOOP AT SCREEN.
       IF screen-name = 'CHA1' .
           screen-input = 1.
         MODIFY SCREEN.
       ENDIF.
       ENDLOOP.
    ELSE.
      LOOP AT SCREEN.
      IF screen-name = 'CHA1' .
          screen-input = 1.
          screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

************************************

IF CHA_WF IS NOT INITIAL.

  IF CHA_WF = '/CHA_PM'.
      LOOP AT SCREEN.
       IF ( screen-name = 'GWA_JV_CC-PRJ_MAN' OR screen-name = 'UP_WFBT ' ).
        screen-input = 1.
       MODIFY SCREEN.
       ENDIF.
      ENDLOOP.
  ENDIF.
ENDIF.
******************************************************************************************

  IF gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vtext FROM t8jvt INTO gv_vtext WHERE vname = gwa_jv_cc-vname
                                                 AND bukrs = gwa_jv_cc-bukrs
                                                 AND spras = 'E'.
  ENDIF.

  IF gwa_jv_cc-prj_cord IS NOT INITIAL.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
*    SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
  ENDIF.

  IF gwa_jv_cc-prj_man IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man.
  ENDIF.

  IF gwa_jv_cc-fc_approver IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver.
  ENDIF.

  IF gwa_jv_cc-pf_officer IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer.
  ENDIF.

  IF gwa_jv_cc-rp_approver IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver.
  ENDIF.


  IF gwa_jv_cc-ccreqno IS NOT INITIAL.  " Added by ss on 6.8.2021
    SELECT NRCOMM FROM ZJV_CC_COMM_LOG
 INTO GWA_CLOG-NRCOMM UP TO 1 ROWS WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

   IF gwa_clog-bnk_dtls IS INITIAL.
    SELECT BNK_DTLS FROM ZJV_CC_COMM_LOG
 INTO GWA_CLOG-BNK_DTLS UP TO 1 ROWS WHERE CCREQNO EQ GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.
   ENDIF.
  ENDIF.

**  BOC by ss on 24.8.21 for displaying username data for Reviewer
  IF gwa_jv_cc-reviewer IS NOT INITIAL.
    SELECT SINGLE name_last FROM user_addr
                            INTO gv_name6
                            WHERE bname = gwa_jv_cc-reviewer.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MOD_FILL_PROJECT_CORDINATOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mod_fill_project_cordinator OUTPUT.
*  gv_prj_cord = sy-uname.

  CREATE OBJECT editor_container
    EXPORTING
      container_name              = 'TEXTEDITOR'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.

  CREATE OBJECT text_editor
    EXPORTING
      parent                     = editor_container
      wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
      wordwrap_position          = line_length
      wordwrap_to_linebreak_mode = cl_gui_textedit=>true.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9010 OUTPUT.
  SET PF-STATUS 'ZSTATUS'.
  SET TITLEBAR 'ZTITLE'.
*  CALL SCREEN 9010.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TS 'TS_9020'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE ts_9020_active_tab_set OUTPUT.
  IF flag_disp = 'X'.
    CLEAR flag_disp.
    ts_9020-activetab = g_ts_9020-pressed_tab = c_ts_9020-tab3.
  ELSE.
    ts_9020-activetab = g_ts_9020-pressed_tab.
  ENDIF.
  CASE g_ts_9020-pressed_tab.
    WHEN c_ts_9020-tab1.
      IF gwa_jv_cc-ccreqno IS NOT INITIAL.
        CLEAR: gwa_jv_cc, lfct_9000, gv_vtext, gv_name1, gv_name2,
                 gv_name3, gv_name4, gv_name5,gv_name6, gwa_clog.
      ENDIF.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab2.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab3.
      g_ts_9020-subscreen = '9000'.
    WHEN c_ts_9020-tab4.
      g_ts_9020-subscreen = '9000'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9020 OUTPUT.

  SET PF-STATUS 'ZPFS_SAVE'.
*  SET TITLEBAR 'ZTITLE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9030  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9030 OUTPUT.
  SET PF-STATUS 'ZPF_STATUS'.
*  SET TITLEBAR 'ZTITLE'.

  CLEAR: appr, fwd.
  IF gwa_jv_cc-ccreqno IS NOT INITIAL AND flag_data = 'X'.
    IF gwa_jv_cc-created_on IS NOT INITIAL
           AND gwa_jv_cc-del_ind IS INITIAL.

**  For Projet Manager
      IF r2 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
*            appr = 'Forward    '. " commented by ss on 24.8.21
            appr = 'Fwd to IPF'. " added by ss on 24.8.21
          ENDIF.
**       Added by ss on 24.8.21 for adding the
**          forward to Reviewer  button text
          IF screen-name = 'FWD' .
            fwd = 'Fwd to Reviewer'.
          ENDIF.
**         BOC by ss on 24.8.21
          IF  ( screen-name = 'APPR' or screen-name = 'REJ')
            and gwa_jv_cc-status_pm = 'PENDING' and GWA_JV_CC-REVIEWER is INITIAL..
            screen-input = 1.
          ELSEIF ( screen-name = 'REJ' or screen-name = 'FWD' )
            AND gwa_jv_cc-status_pm = 'PENDING' and GWA_JV_CC-REVIEWER is NOT INITIAL.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
**   EOC by ss
**        For Incharge Project Finance
      ELSEIF r3 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Concurr    '.
          ENDIF.
          IF screen-name = 'FWD'.
            fwd = 'Fwd to PFO '.
          ENDIF.
**          Commented by ss on 6.9.21
*          IF screen-group4 = 'APP' AND gwa_jv_cc-status_fc = 'PENDING'
*            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD').
***            Added by ss on 25.8.21
*            IF GWA_JV_CC-REVIEWER is INITIAL.
*                screen-input = 1.
*            ELSE.
*              IF gwa_jv_cc-status_rev = 'APPROVED'.
*                screen-input = 1.
*               else.
*                 screen-input = 0.
*              ENDIF.
*            ENDIF.
***            EOC by ss.
**            screen-input = 1.  "commented by ss on 25.8.21
*          ELSE.
*            screen-input = 0.
*          ENDIF.
**End of Comments by ss on 9.9.21


**  Added by ss on 9.9.2021
          IF screen-group4 = 'APP'.
           if  gwa_jv_cc-STATUS_REV is not INITIAL.

            IF ( gwa_jv_cc-status_rev = 'APPROVED' and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

            ELSEIF ( gwa_jv_cc-status_rev = 'APPROVED' and
                     gwa_jv_cc-status_fc =  'PENDING'   and
                     gwa_jv_cc-status_pfo = 'APPROVED' ).

              screen-input = 1.
           ELSE.
             screen-input = 0.
          ENDIF.

         else.

            IF ( gwa_jv_cc-status_rev is INITIAL  and
                 gwa_jv_cc-status_fc =  'PENDING' and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

            ELSEIF ( gwa_jv_cc-status_rev is INITIAL  and
                     gwa_jv_cc-status_fc =  'PENDING'   and
                     gwa_jv_cc-status_pfo = 'APPROVED' ).

              screen-input = 1.
           ELSE.
             screen-input = 0.
          ENDIF.
      endif.
      MODIFY SCREEN.
  endif.

**          EOC  by  ss 9.9.21
**   Commented on 6.9.21
*          IF screen-group4 = 'PFO' AND gwa_jv_cc-status_fc = 'PENDING'
*            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD')
*            AND gwa_jv_cc-status_pfo = 'PENDING'.
***            Added by ss on 25.8.21
*            IF GWA_JV_CC-REVIEWER is INITIAL.
*                screen-input = 1.
*            ELSE.
*              IF gwa_jv_cc-status_rev = 'APPROVED'.
*                screen-input = 1.
*              else.
*                screen-input = 0.
*              ENDIF.
*            ENDIF.
*             ELSE.
**            screen-input = 0.
**          ENDIF.
***            EOC by ss.
**            screen-input = 1.
*          ENDIF.
**          End of comment
************BOC by ss *

          IF screen-group4 = 'PFO' .
               IF ( gwa_jv_cc-status_rev = 'APPROVED' and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.

               ELSEIF (  gwa_jv_cc-status_rev IS INITIAL and
                 gwa_jv_cc-status_fc =  'PENDING'   and
                 gwa_jv_cc-status_pfo = 'PENDING' ).

                 screen-input = 1.
                else.
                  screen-input = 0.
               ENDIF.
          ENDIF.
**********************  EOC by ss on 6.9.21
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.

*          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSEIF r4 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-name = 'FWD'.
            fwd = 'Submit     '.
          ENDIF.
          IF screen-group4 = 'PFO' AND gwa_jv_cc-status_pfo = 'FORWARD'
            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD' ).
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

      ELSEIF r5 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-group4 = 'APP' AND gwa_jv_cc-status_rp = 'PENDING' AND gwa_jv_cc-status_fc = 'APPROVED'.
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.

**       Added by ss on 24.8.21
      ELSEIF r8 = 'X'.
        LOOP AT SCREEN.
          IF screen-name = 'APPR'.
            appr = 'Approve    '.
          ENDIF.
          IF screen-group4 = 'APP' AND gwa_jv_cc-status_rev = 'PENDING'
            AND ( gwa_jv_cc-status_pm = 'APPROVED' or gwa_jv_cc-status_pm = 'FORWARD' ).
            screen-input = 1.
          ELSE.
            screen-input = 0.
          ENDIF.
          IF screen-group3 = 'DIS'.
            screen-input = 1.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
**  EOC by ss
      ENDIF.

    ELSEIF gwa_jv_cc-created_on IS NOT INITIAL AND gwa_jv_cc-del_ind IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group3 = 'DIS'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        IF screen-name = 'GWA_CLOG-COMM_TXT'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
        IF screen-name = 'GWA_CLOG-BNK_DTLS'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group3 = 'DIS'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      IF screen-name = 'GWA_CLOG-COMM_TXT'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
       IF screen-name = 'GWA_CLOG-BNK_DTLS'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* IF ts_9020-activetab = c_ts_9020-tab3 AND gwa_jv_cc-ccreqno IS NOT INITIAL .
    LOOP AT SCREEN.
    IF screen-group4 = 'NA1' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
      IF gwa_jv_cc-status_pm NE 'PENDING' AND r2 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_rev  NE 'PENDING' AND r8 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
*      ELSEIF gwa_jv_cc-status_fc  EQ 'PENDING' AND r3 = 'X'.
*        screen-input = 0.
*        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_fc  NE 'PENDING' AND gwa_jv_cc-status_pfo NE 'PENDING' AND r3 = 'X'.
*         IF screen-group3 = 'NA2'.
           screen-input = 0.
           MODIFY SCREEN.
*         ENDIF.
      ELSEIF gwa_jv_cc-status_pfo EQ 'FORWARD' AND r3 = 'X'.
*         IF screen-group3 = 'NA2'.
           screen-input = 0.
           MODIFY SCREEN.
*         ENDIF.
      ELSEIF gwa_jv_cc-status_pfo EQ 'APPROVED' AND r4 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ELSEIF gwa_jv_cc-status_rp  NE 'PENDING' AND r5 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
     ENDIF.

     IF screen-group4 = 'NA1' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'APPROVED' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

     IF screen-group3 = 'NA2' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

     IF screen-group3 = 'NA2' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND gwa_jv_cc-status_pfo EQ 'PENDING' AND r3 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
     ENDIF.
     ENDIF.

*     IF screen-name = 'GWA_CLOG-COMM_TXT' AND gwa_jv_cc-ccreqno IS NOT INITIAL .
*       IF gwa_jv_cc-status_fc  EQ 'PENDING' AND r3 = 'X'.
*        screen-input = 1.
*        MODIFY SCREEN.
*       ENDIF.
*     ENDIF.
*       IF gwa_jv_cc-status_fc  EQ 'APPROVED' AND gwa_jv_cc-status_pfo EQ 'APPROVED' AND r3 = 'X'.
*        screen-input = 0.
*        MODIFY SCREEN.
*       ENDIF.
*     ENDIF.

    ENDLOOP.
*  ENDIF.

****************************************************************************************
LOOP AT SCREEN.
  IF ( SCREEN-NAME = 'CHA2' or SCREEN-NAME = 'CHA3' or SCREEN-NAME = 'CHA4'  ).
     screen-input = 1.
     screen-invisible = 1.
     MODIFY SCREEN.
  ENDIF.
  IF SCREEN-NAME = 'UP_WFBT'.
     screen-input = 0.
     MODIFY SCREEN.
  ENDIF.
ENDLOOP.

IF r2 = 'X'.
   IF gwa_jv_cc-prj_man = sy-uname.
    LOOP AT SCREEN.
    IF  screen-name = 'CHA2' .
        screen-input = 1.
        screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
    ENDLOOP.
   ENDIF.

  ELSEIF r3 = 'X'.
   IF gwa_jv_cc-fc_approver = sy-uname.
*     IF gwa_jv_cc-status_pfo = 'FORWARD'.
*        LOOP AT SCREEN.
*        IF screen-name = 'CHA4' .
*         screen-input = 1.
*         screen-invisible = 0.
*         MODIFY SCREEN.
*        ENDIF.
*       ENDLOOP.
*     ELSE.
        LOOP AT SCREEN.
        IF  screen-name = 'CHA3' OR screen-name = 'CHA4'.
            screen-input = 1.
            screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.
        ENDLOOP.
*     ENDIF.
   ENDIF.

  ELSEIF r4 = 'X'.
   IF gwa_jv_cc-pf_officer = sy-uname.
    LOOP AT SCREEN.
    IF screen-name = 'CHA4' .
        screen-input = 1.
        screen-invisible = 0.
      MODIFY SCREEN.
    ENDIF.
    ENDLOOP.
   ENDIF.

*  ELSEIF r5 = 'X'.
*   IF gwa_jv_cc-rp_approver = sy-uname.
*    LOOP AT SCREEN.
*    IF screen-name = 'CHA4'.
*        screen-input = 1.
*      MODIFY SCREEN.
*    ENDIF.
*    ENDLOOP.
*   ENDIF.
  ENDIF.

***************************************

IF CHA_WF IS NOT INITIAL.

  IF CHA_WF = '/CHA_PF'.
      LOOP AT SCREEN.
        IF ( screen-name = 'GWA_JV_CC-FC_APPROVER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
           screen-invisible = 0.
         MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
   SAVE_WF = 'UP_PF'.

  ELSEIF CHA_WF = '/CHA_PFO'.
      LOOP AT SCREEN.
       IF ( screen-name = 'GWA_JV_CC-PF_OFFICER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
           screen-invisible = 0.
         MODIFY SCREEN.
       ENDIF.
      ENDLOOP.
   SAVE_WF = 'UP_PFO'.

  ELSEIF CHA_WF = '/CHA_RP'.
      LOOP AT SCREEN.
        IF ( screen-name = 'GWA_JV_CC-RP_APPROVER' OR screen-name = 'UP_WFBT ' ).
          screen-input = 1.
          screen-invisible = 0.
         MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
     SAVE_WF = 'UP_RP'.
  ENDIF.
  CLEAR CHA_WF.

ENDIF.
**********************************************************************************************

  IF gwa_jv_cc-vname IS NOT INITIAL.
    SELECT SINGLE vtext FROM t8jvt INTO gv_vtext WHERE vname = gwa_jv_cc-vname
                                                   AND bukrs = gwa_jv_cc-bukrs
                                                   AND spras = 'E'.
  ENDIF.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 12.06.2026  FOR ATC
  IF gwa_jv_cc-prj_cord IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name1 WHERE bname = gwa_jv_cc-prj_cord ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-prj_man IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name2 WHERE bname = gwa_jv_cc-prj_man ORDER BY name_last.ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-fc_approver IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver.
        SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name3 WHERE bname = gwa_jv_cc-fc_approver ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-pf_officer IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name4 WHERE bname = gwa_jv_cc-pf_officer ORDER BY name_last. ENDSELECT.
  ENDIF.

  IF gwa_jv_cc-rp_approver IS NOT INITIAL.
*    SELECT SINGLE name_last FROM user_addr INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name5 WHERE bname = gwa_jv_cc-rp_approver ORDER BY name_last. ENDSELECT.
  ENDIF.

**  Added by ss on 24.8.21
  IF gwa_jv_cc-reviewer IS NOT INITIAL..
*    SELECT SINGLE name_last FROM user_addr INTO gv_name6 WHERE bname = gwa_jv_cc-REVIEWER.
    SELECT name_last FROM user_addr UP TO 1 ROWS INTO gv_name6 WHERE bname = gwa_jv_cc-REVIEWER ORDER BY name_last. ENDSELECT.
  ENDIF.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 12.06.2026 FOR ATC
**  Fetch data for Remark field
  SELECT NRCOMM FROM ZJV_CC_COMM_LOG INTO GWA_CLOG-NRCOMM UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT BNK_DTLS FROM ZJV_CC_COMM_LOG INTO GWA_CLOG-BNK_DTLS UP TO 1 ROWS WHERE CCREQNO = GWA_JV_CC-CCREQNO
 ORDER BY PRIMARY KEY .
 ENDSELECT.

**  EOC by ss on 24.8.21
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9040  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_9040 OUTPUT.

  SET PF-STATUS 'ZPF_BANKSTAT'.
  LOOP AT SCREEN.
    IF screen-group1 = 'GRP'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9050  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_9050 OUTPUT.
  IF ok_code EQ 'UPDTBANK'.  "added by ss on 4.5.21
    CLEAR: wa_bank, ok_code.
  ENDIF.
  SET PF-STATUS 'ZSTAT'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9060  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9060 OUTPUT.
  SET PF-STATUS 'ZSTAT_DEL'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
