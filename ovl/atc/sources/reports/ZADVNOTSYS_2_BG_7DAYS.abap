*--- MAIN PROGRAM: ZADVNOTSYS_2_BG_7DAYS ---*
*&---------------------------------------------------------------------*
*& Report  ZADVNOTSYS_2_BG_7DAYS
*&
* Title      :  Advance Notification System - BG/ LC expiry 7 days   *
*                                                                     *
* FS No.     : Final - FS-MM-Adv-Notif-Sys.docx                       *
*                                                                     *
* Author     : Amit Moza             Date : 16.04.2013                *
*                                                                     *
*                                                                     *
*                                                                     *
* Login Id   : CAB_AMITMOZA                                           *
*                                                                     *
*                                                                     *
*                                                                     *
* Description: This program will send SAPMail & SMS to inform user    *
*              about impending expiry of validity of EMD/SD - 7 days. *
*                                                                     *
* Tran. Code : ZMM_ANS1_BG7                                           *
*                                                                     *
***********************************************************************
* CHANGE HISTORY                                                      *
*                                                                     *
* Mod Date    Changed by    Description                 Chng ID       *
*                                                                     *
* 20/09/2013  CAB_SPYADAV   Changes as Per CR No.         001         *
*                           30009742                                  *
*                                                                     *
***********************************************************************

REPORT  zadvnotsys_2_bg_7days.
*********Data declaration***********
TABLES : zmm_emddtl,
**taken from ZMMPOLOG*******************************************
        dd04t,
        cdhdr,
        cdpos,
        dd03l,
        dd41v,
        t685t,
        vbpa,
        tpart,
        konvc,
        ekko.

DATA: wflag,
      wchangenr LIKE cdhdr-changenr.

DATA: indtext(60) TYPE c.

DATA: BEGIN OF icdhdr OCCURS 50.
        INCLUDE STRUCTURE cdhdr.
DATA: END OF icdhdr.

DATA: BEGIN OF icdshw OCCURS 50.
        INCLUDE STRUCTURE cdshw.
DATA: END OF icdshw.

DATA: BEGIN OF ekkey,
        ebeln LIKE eket-ebeln,
        ebelp LIKE eket-ebelp,
        etenr LIKE eket-etenr,

      END OF ekkey.

DATA: BEGIN OF itab OCCURS 50,
        BEGIN OF ekkey,
          ebeln LIKE eket-ebeln,
          ebelp LIKE eket-ebelp,
          etenr LIKE eket-etenr,
        END OF ekkey,
        changenr LIKE cdhdr-changenr,
        udate    LIKE cdhdr-udate,
        utime    LIKE cdhdr-utime,
        username LIKE cdhdr-username,
        chngind  LIKE cdshw-chngind,
        ftext    LIKE cdshw-ftext,
        outlen   LIKE cdshw-outlen,
        f_old    LIKE cdshw-f_old,
        f_new    LIKE cdshw-f_new,
      END OF itab.

DATA: it_itab1 LIKE TABLE OF itab,
      it_itab2 LIKE TABLE OF itab,
      wa_itab1 LIKE LINE OF itab,
      wa_itab2 LIKE LINE OF itab,
      wa_itab3 LIKE LINE OF itab,
      wa_itab4 LIKE LINE OF itab,
      wa_itab5 LIKE LINE OF itab,
      wa_itab6 LIKE LINE OF itab.
DATA: old_objectid LIKE cdhdr-objectid.

FIELD-SYMBOLS: <f_old>, <f_new>.
**end ZMMPOLOG***********************************************.
DATA: BEGIN OF final,
  ebeln LIKE eket-ebeln,
  txz01 TYPE txz01,
  name TYPE name1_gp,
  username LIKE cdhdr-username,
  END OF final.

DATA: it_final1 LIKE STANDARD TABLE OF final,
      wa_final1 LIKE LINE OF it_final1.

DATA : it_emddtl1 TYPE TABLE OF zmm_emddtl,
       wa_emddtl1  TYPE zmm_emddtl,
       it_emddtl2 TYPE TABLE OF zmm_emddtl,    ""EMD TABLE
       wa_emddtl2  TYPE zmm_emddtl,
       it_emddtl3 TYPE TABLE OF zmm_emddtl,    ""SD TABLE
       wa_emddtl3  TYPE zmm_emddtl,
       it_ekpo1 TYPE TABLE OF ekpo,
       wa_ekpo1 TYPE ekpo,
       it_ekpo2 TYPE TABLE OF ekpo,
       wa_ekpo2 TYPE ekpo.

DATA: BEGIN OF ekpoko,
        txz01 TYPE zworkdesc,
        submi TYPE submi,
        name1 TYPE name1_gp,
        username LIKE cdhdr-username,
      END OF ekpoko.

DATA: it_ekpoko1 LIKE TABLE OF ekpoko,
      wa_ekpoko1 LIKE LINE OF it_ekpoko1,
      wa_ekpoko2 LIKE LINE OF it_ekpoko1,
      wa_ekpoko3 LIKE LINE OF it_ekpoko1,
      it_ekpoko2 LIKE TABLE OF ekpoko,
      it_ekpoko3 LIKE TABLE OF ekpoko.

DATA: ydate LIKE sy-datum ,
      uname LIKE cdhdr-username. ",
"P_DATE like sy-datum.
DATA : repid LIKE sy-repid,
        n(2) TYPE n VALUE 20.
DATA: l_text10 TYPE ad_smtpadr,
      l_text11 TYPE ad_smtpadr,
      docname1 TYPE ad_smtpadr,
      docname2 TYPE ad_smtpadr .

*******ALV DECLARATION******************
TYPE-POOLS: icon,
             slis.

DATA : ist_fcat  TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       ist_events TYPE slis_alv_event,
       ist_events1 TYPE slis_alv_event OCCURS 0,
       ist_layout   TYPE  slis_layout_alv,
       ist_listheader TYPE slis_t_listheader,
       wa_listheader TYPE slis_listheader.

******xls mail declaration
DATA:   it_message TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0
WITH HEADER LINE.
DATA:   it_attach TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0
WITH HEADER LINE.
CONSTANTS : d(1) VALUE '-',
        e(1) VALUE '/',
        c(1) VALUE '.'.
DATA: l_edd3 TYPE eindt,
       l_edd4(10).
DATA:   t_packing_list LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
t_contents LIKE solisti1 OCCURS 0 WITH HEADER LINE,
t_receivers LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
t_attachment LIKE solisti1 OCCURS 0 WITH HEADER LINE,
t_object_header LIKE solisti1 OCCURS 0 WITH HEADER LINE,
w_cnt TYPE i,
w_sent_all(1) TYPE c,
w_doc_data LIKE sodocchgi1,
gd_error    TYPE sy-subrc,
gd_reciever TYPE sy-subrc,
 p_email   TYPE somlreci1-receiver.

***********selection-screen*********
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.

PARAMETERS: p_date LIKE sy-datum.  " obligatory.

SELECTION-SCREEN END OF BLOCK a1.

START-OF-SELECTION.
  IF p_date IS INITIAL.
    p_date = sy-datum.
  ENDIF.

  ydate = p_date + 7 .
  SELECT * FROM zmm_emddtl
    INTO CORRESPONDING FIELDS OF TABLE it_emddtl1
    WHERE ( inst_type = 'BG'  OR inst_type = 'LC')
    AND inst_vdt = ydate
    AND status <> 'D'.

  LOOP AT it_emddtl1 INTO wa_emddtl1.
    IF wa_emddtl1-trans = 'EMD'.
      APPEND wa_emddtl1 TO it_emddtl2.
    ELSEIF wa_emddtl1-trans = 'SDT'.
      APPEND wa_emddtl1 TO it_emddtl3.
      CLEAR wa_emddtl1.
    ENDIF.
  ENDLOOP.

**EMD begins*****************************
  LOOP AT it_emddtl2 INTO wa_emddtl2.
    IF wa_emddtl2-ebeln = ''.                             " e-tender
      SELECT SINGLE workdesc FROM zmm_pur_tender_d
        INTO wa_ekpoko1-txz01
        WHERE submi = wa_emddtl2-ebidno .

      SELECT SINGLE name1 FROM lfa1
           INTO wa_ekpoko1-name1
           WHERE lifnr = wa_emddtl2-vendno.

      wa_ekpoko1-submi = wa_emddtl2-ebidno.
      wa_ekpoko1-username = wa_emddtl2-crby.
      APPEND wa_ekpoko1 TO it_ekpoko1.
      CLEAR : wa_ekpoko1 , wa_emddtl2.


    ELSE.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
*      SELECT SINGLE txz01 FROM ekpo                         " Normal
*        INTO  wa_ekpoko1-txz01
*        WHERE ebeln = wa_emddtl2-ebeln
*        AND loekz = ''.
 SELECT TXZ01 FROM EKPO   UP TO 1 ROWS INTO WA_EKPOKO1-TXZ01 WHERE
EBELN = WA_EMDDTL2-EBELN AND LOEKZ = ''  ORDER BY  EBELN EBELP .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC

      wa_ekpoko1-submi = wa_emddtl2-tendno.

      SELECT SINGLE name1 FROM lfa1
        INTO wa_ekpoko1-name1
        WHERE lifnr = wa_emddtl2-vendno.

      wa_ekpoko1-username = wa_emddtl2-crby.

      APPEND wa_ekpoko1 TO it_ekpoko1.
      CLEAR : wa_ekpoko1.

      SELECT SINGLE workdesc tdrsigner ernam FROM zmm_pur_tender_d
       INTO (wa_ekpoko1-txz01, wa_ekpoko1-username , uname)
       WHERE submi = wa_emddtl2-tendno .

      wa_ekpoko1-submi = wa_emddtl2-tendno.

      SELECT SINGLE name1 FROM lfa1
        INTO wa_ekpoko1-name1
        WHERE lifnr = wa_emddtl2-vendno.

      APPEND wa_ekpoko1 TO it_ekpoko1.

      CLEAR : wa_ekpoko1-username.

      wa_ekpoko1-username = uname.

      APPEND wa_ekpoko1 TO it_ekpoko1.

      CLEAR : wa_ekpoko1 , wa_emddtl2,uname.

    ENDIF.
  ENDLOOP.
  SORT it_ekpoko1 BY username submi txz01 name1.
  DELETE ADJACENT DUPLICATES FROM it_ekpoko1.


*****************SDT BEGINS***********************
  LOOP AT it_emddtl3 INTO wa_emddtl3.
**taken from ZMMPOLOG****************************
    SELECT * FROM ekko WHERE ebeln = wa_emddtl3-ebeln.
      CLEAR : cdhdr ,wa_itab1 ,wa_itab2 , wa_itab3.
      CLEAR cdpos.
      cdhdr-objectclas = 'EINKBELEG'.
      cdhdr-objectid   = ekko-ebeln.
      PERFORM getchgdocs.
    ENDSELECT.

    SORT itab BY udate DESCENDING ekkey-ebeln changenr ekkey-ebelp
                  ekkey-etenr.
    READ TABLE itab INTO wa_itab1
     WITH KEY ftext = 'Release Indicator: Purchasing Document'
     f_new = 'S'.

    IF sy-subrc EQ 0.
      READ TABLE itab INTO wa_itab2
       WITH KEY ftext = 'Release status'
        f_new = 'XXX'.
      READ TABLE itab INTO wa_itab6
       WITH KEY ftext = 'Release status'
        f_new = 'XX'.
      READ TABLE itab INTO wa_itab3
       WITH KEY ftext = 'Release status'
        f_new = 'X'.
      APPEND wa_itab2 TO it_itab1.
      APPEND wa_itab6 TO it_itab1.
      APPEND wa_itab3 TO it_itab1.
    ENDIF.
    REFRESH: itab.
    CLEAR : wa_itab1 ,wa_itab2, wa_itab3, wa_itab6.
**end of ZMMPOLOG*********************************
  ENDLOOP.
  CLEAR : wa_emddtl3.
*  APPEND LINES OF IT_ITAB1 TO IT_ITAB2.               """backing up all  X and XXX
  DELETE it_itab1  WHERE ekkey-ebeln = ''.
*  DELETE IT_ITAB2 WHERE EKKEY-EBELN = ''.
  LOOP AT it_itab1 INTO wa_itab5.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
*    SELECT SINGLE * FROM ekpo
*      INTO wa_ekpo2
*      WHERE ebeln = wa_itab5-ekkey-ebeln
*      AND loekz = ''.
 SELECT * FROM EKPO   UP TO 1 ROWS INTO WA_EKPO2 WHERE EBELN =
WA_ITAB5-EKKEY-EBELN AND LOEKZ = ''  ORDER BY  EBELN EBELP .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
    MOVE-CORRESPONDING wa_ekpo2 TO wa_final1.             ""FETCH ITEM DESCRIPTION FROM EKPO
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
*    SELECT SINGLE * FROM zmm_emddtl                      ""FETCH VENDOR NAME FROM LIFNR
*       INTO wa_emddtl3
*       WHERE ebeln = wa_itab5-ekkey-ebeln .
 SELECT * FROM ZMM_EMDDTL   UP TO 1 ROWS INTO WA_EMDDTL3 WHERE EBELN =
WA_ITAB5-EKKEY-EBELN   ORDER BY  TRANS DOCNO ITEM_NO .   ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC
    SELECT SINGLE name1 FROM lfa1
   INTO wa_final1-name
   WHERE lifnr = wa_emddtl3-vendno.
    wa_final1-username = wa_itab5-username.
    APPEND wa_final1 TO it_final1.
    CLEAR : wa_ekpo2 , wa_final1 ,wa_emddtl3.
  ENDLOOP.
  SORT it_final1 BY username ebeln txz01 name.
  DELETE ADJACENT DUPLICATES FROM it_final1.

  LOOP AT it_final1 INTO wa_final1.
    wa_ekpoko1-submi = wa_final1-ebeln.
    wa_ekpoko1-txz01 = wa_final1-txz01.
    wa_ekpoko1-name1 = wa_final1-name.
    wa_ekpoko1-username = wa_final1-username.
    APPEND wa_ekpoko1 TO it_ekpoko1.
    CLEAR wa_ekpoko1.
  ENDLOOP.
********SEND MAIL AND SMS******
  CLEAR: wa_ekpoko2.

*+001 : Send email to Incharge-MM & L3, additionally
  DATA : BEGIN OF wa_inchrg_mm,
            submi    TYPE ekko-submi,
            txz01    TYPE txz01,
            username TYPE cdhdr-username,
            name1    TYPE name1_gp,
            ekgrp    TYPE ekko-ekgrp,
            deptt(2),
          END OF wa_inchrg_mm.

  DATA : ist_inchrg_mm   LIKE TABLE OF wa_inchrg_mm,
         ist_inchrg_mm_s LIKE TABLE OF wa_inchrg_mm.  "Subsitute Incharge

  DATA : BEGIN OF wa_agr_users,
          agr_name TYPE agr_users-agr_name,
          uname    TYPE agr_users-uname,
         END OF wa_agr_users.

  DATA : ist_agr_users   LIKE TABLE OF wa_agr_users,
         ist_agr_users_1 LIKE TABLE OF wa_agr_users.

  DATA : l_role1 TYPE agr_users-agr_name,
         l_role2 TYPE agr_users-agr_name,
         l_role3 TYPE agr_users-agr_name.

  DATA : l_eknam TYPE t024-eknam,
         l_deptt(2) VALUE 'MM'.

  LOOP AT it_ekpoko1 INTO wa_ekpoko1.

    CLEAR : wa_inchrg_mm,
            l_eknam.

    MOVE-CORRESPONDING wa_ekpoko1 TO wa_inchrg_mm.

    SELECT SINGLE ekgrp FROM ekko INTO wa_inchrg_mm-ekgrp
        WHERE ebeln = wa_inchrg_mm-submi.

    IF sy-subrc NE 0.

      SELECT SINGLE ekgrp FROM zmm_pur_tender_d INTO wa_inchrg_mm-ekgrp
          WHERE submi = wa_inchrg_mm-submi.

    ENDIF.

    SELECT SINGLE eknam FROM t024 INTO l_eknam
       WHERE ekgrp = wa_inchrg_mm-ekgrp.

    FIND FIRST OCCURRENCE OF l_deptt IN l_eknam.

    IF sy-subrc EQ 0.
      wa_inchrg_mm-deptt = 'MM'.
    ELSE.
      wa_inchrg_mm-deptt = 'L3'.
    ENDIF.

    APPEND wa_inchrg_mm TO ist_inchrg_mm.

  ENDLOOP.

  LOOP AT ist_inchrg_mm INTO wa_inchrg_mm.

    REFRESH : ist_agr_users,
              ist_agr_users_1.

    CLEAR : wa_agr_users.

    IF wa_inchrg_mm-deptt = 'MM'.
*Add new incharge MM having following authorizations
*  - D:MM_PUR_PO_APPROVE_IM
*  - Purchasing group
      l_role1 = 'D:MM_PUR_PO_APPROVE_IM'.

      CONCATENATE 'MM_PUR_PO_%_PGRP_'  wa_inchrg_mm-ekgrp INTO  l_role3.

    ELSE.
* Add new Users having L3 as well as Purchasing group authorization
      l_role1 = 'D:MM_PUR_PO_APPROVE_L3'.

      CONCATENATE 'MM_PUR_PO_%_PGRP_'  wa_inchrg_mm-ekgrp INTO  l_role3.

    ENDIF.

*Check existing PO/tender creater / releasing authority have purchasing
*group authorization, if not remove from the list.
" Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 06.06.2026  FOR ATC
*    SELECT SINGLE agr_name uname FROM agr_users INTO wa_agr_users
*                WHERE agr_name LIKE l_role3            AND
*                      uname    = wa_inchrg_mm-username AND
*                      to_dat   GE sy-datum .
 SELECT AGR_NAME UNAME FROM AGR_USERS   UP TO 1 ROWS INTO WA_AGR_USERS
WHERE AGR_NAME LIKE L_ROLE3 AND UNAME = WA_INCHRG_MM-USERNAME AND
TO_DAT GE SY-DATUM   ORDER BY  AGR_NAME UNAME FROM_DAT TO_DAT .
ENDSELECT.
" Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 06.06.2026 FOR ATC

    IF sy-subrc EQ 0.

      wa_inchrg_mm-username = wa_agr_users-uname.

      APPEND wa_inchrg_mm TO ist_inchrg_mm_s.

    ENDIF.

    CLEAR : wa_agr_users.

*Add new incharge MM having following authorizations
*  - D:MM_PUR_PO_APPROVE_IM
*  - Purchasing group
*      OR
* Add new Users having L3 as well as Purchasing group authorization
    SELECT agr_name uname FROM agr_users
            INTO CORRESPONDING FIELDS OF TABLE ist_agr_users
               WHERE  agr_name = l_role1   AND
                      to_dat   GE sy-datum .

    IF NOT ist_agr_users[] IS INITIAL.

      SELECT agr_name uname FROM agr_users
                INTO CORRESPONDING FIELDS OF TABLE ist_agr_users_1
                  FOR ALL ENTRIES IN ist_agr_users
                    WHERE agr_name LIKE l_role3          AND
                          uname    = ist_agr_users-uname AND
                          to_dat   GE sy-datum .

    ENDIF.

    IF NOT ist_agr_users_1[] IS INITIAL.

      LOOP AT ist_agr_users_1 INTO wa_agr_users.

        READ TABLE it_ekpoko1 INTO wa_ekpoko1
                        WITH KEY submi    = wa_inchrg_mm-submi
                                 username = wa_agr_users-uname.

        IF sy-subrc NE 0.

          wa_inchrg_mm-username = wa_agr_users-uname.

          APPEND wa_inchrg_mm TO ist_inchrg_mm_s.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

  SORT ist_inchrg_mm_s BY submi username.

  DELETE ADJACENT DUPLICATES FROM ist_inchrg_mm_s COMPARING submi username.

* Modify internal table it_ekpoko1
  IF NOT ist_inchrg_mm_s[] IS INITIAL.

    REFRESH : it_ekpoko1.

*Add existing/new MM users as well as Users haing L3 authorization
    LOOP AT ist_inchrg_mm_s INTO wa_inchrg_mm.
      MOVE-CORRESPONDING wa_inchrg_mm TO wa_ekpoko1.
      APPEND wa_ekpoko1 TO it_ekpoko1.
    ENDLOOP.

  ENDIF.
*+001 : End

  LOOP AT it_ekpoko1 INTO wa_ekpoko2.
    p_email = wa_ekpoko2-username.

* Send SMS
    PERFORM send_sms
    USING p_email
          wa_ekpoko2-submi
          wa_ekpoko2-name1.

    CLEAR:  wa_ekpoko2.

  ENDLOOP.
  SORT it_ekpoko1 BY username.
  APPEND LINES OF it_ekpoko1  TO it_ekpoko2 .
******take out Unique Usernames from IT_EKPOKO1  into IT_FINAL2
  DELETE ADJACENT DUPLICATES FROM it_ekpoko2
    COMPARING username.
  REFRESH:it_ekpoko3.
  CLEAR: wa_ekpoko1 , wa_ekpoko2 , wa_ekpoko3.
  LOOP AT it_ekpoko2 INTO wa_ekpoko2.
    LOOP AT it_ekpoko1 INTO wa_ekpoko1.
      IF wa_ekpoko1-username = wa_ekpoko2-username.
        APPEND wa_ekpoko1 TO it_ekpoko3.
        CLEAR: wa_ekpoko1.
      ENDIF.
    ENDLOOP.

    p_email = wa_ekpoko2-username.
*   Populate table with details to be entered into .xls file
    PERFORM build_xls_data_table.
* Populate message body text
    PERFORM populate_email_message_body.
*     Naming Document
    l_edd3 = sy-datum + 7.
    CONCATENATE l_edd3+6(2) l_edd3+4(2) l_edd3+0(4) INTO l_edd4 SEPARATED BY d.
    l_text10 = l_edd4.
    l_text11 = 'BG/LC - Validity '.
    CONCATENATE l_text11 l_text10 INTO docname1 SEPARATED BY space.
*    CONCATENATE  L_TEXT10 'xls' into DOCNAME2 SEPARATED BY C.
* Send file by email as .xls speadsheet
    PERFORM send_file_as_email_attachment
    TABLES it_message
    it_attach
    USING p_email
    docname1        "'Example.xls'
    'XLS'
    'filename.xls'
    ' '
    ' '
    ' '
    CHANGING gd_error
    gd_reciever.
    CLEAR:  wa_ekpoko3.
    REFRESH: it_message ,it_attach ,it_ekpoko3.
  ENDLOOP.

*******************************

**********DISPLAY DATA IN ALV************
  PERFORM generate_fcat.
  PERFORM event_get.
  PERFORM fill_data_alvgrid.
********************************************

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  GENERATE_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_fcat .
  ist_fcat-fieldname  = 'SUBMI'.
  ist_fcat-tabname    = 'IT_EKPOKO1'.
  ist_fcat-ddictxt    = 'L'.
  ist_fcat-seltext_l  = 'Purch.Doc/Coll.No.'.
  ist_fcat-outputlen  = '15' .
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname  = 'TXZ01'.
  ist_fcat-tabname    = 'IT_EKPOKO1'.
  ist_fcat-ddictxt    = 'L'.
  ist_fcat-seltext_l  = 'Description'.
  ist_fcat-outputlen  = '40' .
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname  = 'NAME1'.
  ist_fcat-tabname    = 'IT_EKPOKO1'.
  ist_fcat-ddictxt    = 'L'.
  ist_fcat-seltext_l  = 'Name'.
  ist_fcat-outputlen  = '40' .
  APPEND ist_fcat.
  CLEAR ist_fcat.

  ist_fcat-fieldname  = 'USERNAME'.
  ist_fcat-tabname    = 'IT_EKPOKO1'.
  ist_fcat-ddictxt    = 'L'.
  ist_fcat-seltext_l  = 'CPF No.'.
  ist_fcat-outputlen  = '15' .
  APPEND ist_fcat.
  CLEAR ist_fcat.
ENDFORM.                    " GENERATE_FCAT
*&---------------------------------------------------------------------*
*&      Form  FILL_DATA_ALVGRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_data_alvgrid .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
               i_callback_program = repid
               is_layout          = ist_layout
               i_callback_user_command = 'USER_COMMAND'
               it_fieldcat        = ist_fcat[]
               i_default          = 'X'
               i_save             = 'A'
               it_events          = ist_events1
*             I_SCREEN_START_COLUMN = n
          TABLES
               t_outtab           = it_ekpoko1.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.                    " FILL_DATA_ALVGRID
*&---------------------------------------------------------------------*
*&      Form  GETCHGDOCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM getchgdocs .
  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      date_of_change    = cdhdr-udate
      objectclass       = cdhdr-objectclas
      objectid          = cdhdr-objectid
      time_of_change    = cdhdr-utime
      username          = cdhdr-username
    TABLES
      i_cdhdr           = icdhdr
    EXCEPTIONS
      no_position_found = 1
      OTHERS            = 2.

  CHECK sy-subrc EQ 0.
  DELETE icdhdr WHERE change_ind EQ 'I'.
  CHECK NOT icdhdr[] IS INITIAL.
  LOOP AT icdhdr.
    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
      EXPORTING
        changenumber      = icdhdr-changenr
      IMPORTING
        header            = cdhdr
      TABLES
        editpos           = icdshw
      EXCEPTIONS
        no_position_found = 1
        OTHERS            = 2.
    CHECK sy-subrc EQ 0.
    LOOP AT icdshw.
      CHECK icdshw-text_case EQ space.
      MOVE-CORRESPONDING icdshw TO itab.
      MOVE-CORRESPONDING icdhdr TO itab.
      MOVE icdshw-tabkey+3 TO itab-ekkey.
      APPEND itab.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " GETCHGDOCS



*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UCOMM      text
*      -->SELFIELD   text
*----------------------------------------------------------------------*
FORM user_command USING ucomm TYPE sy-ucomm
                        selfield TYPE slis_selfield.

  IF NOT selfield-value IS INITIAL.
    CASE ucomm.
      WHEN '&IC1'.
        READ TABLE it_ekpoko1 INDEX selfield-tabindex INTO wa_ekpoko2.
        IF sy-subrc EQ 0.
          IF selfield-fieldname = 'SUBMI' .


            IF selfield-value+0(1) = '4'.
              SET PARAMETER ID 'BES' FIELD selfield-value.
              CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

            ELSEIF selfield-value+0(1) = '5'.
              SET PARAMETER ID 'BES' FIELD selfield-value.
              CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

            ELSEIF selfield-value+0(1) = '8'.
              SET PARAMETER ID 'CTR' FIELD selfield-value.
              CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.

            ELSEIF selfield-value+0(1) = '9'.
              SET PARAMETER ID 'CTR' FIELD selfield-value.
              CALL TRANSACTION 'ME33K' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  event_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM event_get.
  repid = sy-repid.

  ist_events-name = 'USER_COMMAND'.
  ist_events-form =  'USER_COMMAND'.
  APPEND ist_events TO ist_events1.
  CLEAR ist_events.
*
*  IST_events-name = slis_ev_top_of_page.
*  IST_events-form =  'TOP_OF_PAGE'.
*  APPEND IST_events TO ist_events1.
*  CLEAR IST_events.

ENDFORM.                    "event_get
*&---------------------------------------------------------------------*
*&      Form  BUILD_XLS_DATA_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_xls_data_table .
  CONSTANTS:
     con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
     con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.

  CONCATENATE 'Purch Doc/Coll No.' 'Short Desc.' 'Vendor Name'
    INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach  INTO it_attach.
  APPEND  it_attach.
  LOOP AT it_ekpoko3 INTO wa_ekpoko3.
    CONCATENATE wa_ekpoko3-submi  wa_ekpoko3-txz01 wa_ekpoko3-name1
    INTO it_attach SEPARATED BY con_tab.
    CONCATENATE con_cret it_attach  INTO it_attach.
    APPEND  it_attach.
  ENDLOOP.
ENDFORM.                    " BUILD_XLS_DATA_TABLE
*&---------------------------------------------------------------------*
*&      Form  POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_email_message_body .
  DATA: l_edd TYPE eindt,
       l_edd2(10).
  CONSTANTS : c(1) VALUE '.'.
  DATA:   l_text1 TYPE ad_smtpadr,
        l_text2 TYPE ad_smtpadr,
        l_text3 TYPE ad_smtpadr,
        l_text4 TYPE ad_smtpadr,
        l_text5 TYPE ad_smtpadr,
        l_text6 TYPE ad_smtpadr,
        l_text7 TYPE ad_smtpadr,
        l_text8 TYPE ad_smtpadr,
        l_text9 TYPE ad_smtpadr.

  CONSTANTS crlf(2) VALUE %_cr_lf.

  REFRESH it_message.
  l_text1 = 'Dear Sir or Madam,'.
  l_text2 = crlf.
  l_text3 = 'A gentle reminder from the Advance Notification System. The validity of EMD/SD for the Purchase documents created/ released by you will expire on'.
  l_edd = sy-datum + 7.
  CONCATENATE l_edd+6(2) l_edd+4(2) l_edd+0(4) INTO l_edd2 SEPARATED BY c.
  l_text4 = l_edd2.
  l_text5 =  '. The list is attached.'.
  l_text6 = crlf.
  l_text9 = 'Best Wishes'.
  l_text8 = crlf.
  l_text7 =  'ICE Team'.
  CONCATENATE l_text1 l_text2  l_text3 l_text4 l_text5 l_text6 l_text9  l_text8 l_text7  INTO it_message SEPARATED BY space.

  APPEND it_message.

ENDFORM.                    " POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------*
*&      Form  SEND_FILE_AS_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_MESSAGE  text
*      -->P_IT_ATTACH  text
*      -->P_P_EMAIL  text
*      -->P_DOCNAME2  text
*      -->P_0885   text
*      -->P_0886   text
*      -->P_0887   text
*      -->P_0888   text
*      -->P_0889   text
*      <--P_GD_ERROR  text
*      <--P_GD_RECIEVER  text
*----------------------------------------------------------------------*
FORM send_file_as_email_attachment  TABLES pit_message
pit_attach
USING p_email
p_mtitle
p_format
p_filename
p_attdescription
p_sender_address
p_sender_addres_type
CHANGING p_error
p_reciever.

  DATA: ld_error    TYPE sy-subrc,
ld_reciever TYPE sy-subrc,
ld_mtitle LIKE sodocchgi1-obj_descr,
ld_email LIKE  somlreci1-receiver,
ld_format TYPE  so_obj_tp ,
ld_attdescription TYPE  so_obj_nam ,
ld_attfilename TYPE  so_obj_des ,
ld_sender_address LIKE  soextreci1-receiver,
ld_sender_address_type LIKE  soextreci1-adr_typ,
ld_receiver LIKE  sy-subrc.

  ld_email   = p_email.
  ld_mtitle = p_mtitle.
  ld_format              = p_format.
  ld_attdescription      = p_attdescription.
  ld_attfilename         = p_filename.
  ld_sender_address      = p_sender_address.
  ld_sender_address_type = p_sender_addres_type.

* Fill the document data.
  w_doc_data-doc_size = 1.

* Populate the subject/generic message attributes
  w_doc_data-obj_langu = sy-langu.
  w_doc_data-obj_name  = 'SAPRPT'.
  w_doc_data-obj_descr = ld_mtitle .
  w_doc_data-sensitivty = 'F'.

* Fill the document data and get size of attachment
  CLEAR w_doc_data.
  READ TABLE it_attach INDEX w_cnt.
  w_doc_data-doc_size =
  ( w_cnt - 1 ) * 255 + STRLEN( it_attach ).
  w_doc_data-obj_langu  = sy-langu.
  w_doc_data-obj_name   = 'SAPRPT'.
  w_doc_data-obj_descr  = ld_mtitle.
  w_doc_data-sensitivty = 'F'.
  CLEAR t_attachment.
  REFRESH t_attachment.
  t_attachment[] = pit_attach[].

* Describe the body of the message
  CLEAR t_packing_list.
  REFRESH t_packing_list.
  t_packing_list-transf_bin = space.
  t_packing_list-head_start = 1.
  t_packing_list-head_num = 0.
  t_packing_list-body_start = 1.
  DESCRIBE TABLE it_message LINES t_packing_list-body_num.
  t_packing_list-doc_type = 'RAW'.
  APPEND t_packing_list.

* Create attachment notification
  t_packing_list-transf_bin = 'X'.
  t_packing_list-head_start = 1.
  t_packing_list-head_num   = 1.
  t_packing_list-body_start = 1.

  DESCRIBE TABLE t_attachment LINES t_packing_list-body_num.
  t_packing_list-doc_type   =  ld_format.
  t_packing_list-obj_descr  =  ld_attdescription.
  t_packing_list-obj_name   =  ld_attfilename.
  t_packing_list-doc_size   =  t_packing_list-body_num * 255.
  APPEND t_packing_list.

* Add the recipients email address
  CLEAR t_receivers.
  REFRESH t_receivers.
  t_receivers-receiver = ld_email.
  t_receivers-rec_type = 'B'."'U'.        " 'B' is for internal SAP mail and 'U' for external
  t_receivers-com_type = 'INT'.
  t_receivers-notif_del = 'X'.
  t_receivers-notif_ndel = 'X'.
  t_receivers-express =   'X'.
  APPEND t_receivers.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = w_doc_data
      put_in_outbox              = 'X'
      sender_address             = ld_sender_address
      sender_address_type        = ld_sender_address_type
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = w_sent_all
    TABLES
      packing_list               = t_packing_list
      contents_bin               = t_attachment
      contents_txt               = it_message
      receivers                  = t_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

* Populate zerror return code
  ld_error = sy-subrc.

* Populate zreceiver return code
  LOOP AT t_receivers.
    ld_receiver = t_receivers-retrn_code.
  ENDLOOP.

ENDFORM.                    " SEND_FILE_AS_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------*
*&      Form  SEND_SMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_EMAIL  text
*----------------------------------------------------------------------*
FORM send_sms  USING p_email
 p_submi
 p_name1.
  DATA   :it_9205 TYPE  STANDARD TABLE OF  pa9205,
          wa_9205 TYPE pa9205 .
  DATA   : mob_no(12) TYPE c.
  CONSTANTS : c(1) VALUE '.'.
  REFRESH :it_9205.
  CLEAR   :wa_9205 .
  DATA: http_client TYPE REF TO if_http_client .
  DATA: wf_string TYPE string ,
        result    TYPE string ,
        r_str     TYPE string .
  DATA:   l_text1 TYPE ad_smtpadr,
          l_text2 TYPE ad_smtpadr,
          l_text3 TYPE ad_smtpadr,
          l_text4 TYPE ad_smtpadr,
          l_text5 TYPE ad_smtpadr,
          l_text6 TYPE ad_smtpadr,
           l_text7 TYPE ad_smtpadr.
  DATA : sms_text(170)  TYPE c.
  DATA: l_edd TYPE eindt,
         l_edd2(10).
  DATA: result_tab TYPE TABLE OF string.
  CONSTANTS crlf(2) VALUE %_cr_lf.
  SELECT * FROM  pa9205 APPENDING
   CORRESPONDING FIELDS OF TABLE it_9205
   WHERE pernr = p_email AND
         subty = '01' AND
         endda = '99991231' .
  CLEAR mob_no.
  IF sy-subrc = 0.          "" It means PHONE NO. has been found

    SORT  it_9205 BY begda DESCENDING .

    READ TABLE it_9205 INTO wa_9205 INDEX 1  .

    CONCATENATE '91' wa_9205-zphone+1(10) INTO  mob_no .

* SENDING SMS
    CLEAR: wf_string ,  l_text1 ,l_text2 , l_text3 .

    l_edd = sy-datum + 7.
    CONCATENATE l_edd+6(2) l_edd+4(2) l_edd+0(4) INTO l_edd2 SEPARATED BY c.
    l_text1 = 'Validity of EMD/SD for'.
    l_text4 = p_submi.
    l_text5 = p_name1.
    l_text6 = 'is due to expire on'.
    l_text2 = l_edd2.
    l_text3 = '. ICE Team'.
    l_text7 = crlf.
    CONCATENATE l_text1 l_text4 l_text5  l_text6 l_text2 l_text3  INTO sms_text SEPARATED BY space.
    CONCATENATE
    'http://10.205.48.190:13013/cgi-bin/sendsms?'
    'username=ongc&password=ongc12&from=ONGC&to='
*  919968282246+919968282468&text=Hellow+Test+4&remLen=147
* 'http://www.webservicex.net/SendSMS.asmx/SendSMSToIndia?MobileNumber='
    mob_no "m_no
   '&text='
   sms_text
   '&remLen=180'
    INTO
    wf_string .

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = wf_string
      IMPORTING
        client             = http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    CALL METHOD http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2.

    CALL METHOD http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.
    CLEAR result .
    result = http_client->response->get_cdata( ).

    REFRESH result_tab .
    SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab.

***Added for memory overflow problem
    CALL METHOD http_client->close( ).
  ELSE.
  ENDIF.
ENDFORM.                    " SEND_SMS

*--- INCLUDE: %_CABAP ---*
type-pool ABAP .


************************************************************************
* WARNING!!!!! DO NOT CHANGE ANY OF THE FOLLOWING TYPES! WARNING !!!!! *
* !!!!!!!! All types have to synchronized with ABAP kernel types !!!!! *
************************************************************************

************************************************************************
* NAMES WITH PREFIX "ABAP_" DECLARED IN THE DDIC
* MUST NOT BE REDEFINED HERE!
************************************************************************
* abap_encod
* abap_endia
* abap_repl

************************************************************************
**** GENERAL ***********************************************************
types:
  ABAP_BOOL type C length 1.
* constants for abap_bool
constants:
  ABAP_TRUE      type ABAP_BOOL value 'X',
  ABAP_FALSE     type ABAP_BOOL value ' ',
  ABAP_UNDEFINED type ABAP_BOOL value '-',
  ABAP_ON        type ABAP_BOOL value 'X',
  ABAP_OFF       type ABAP_BOOL value ' '.


************************************************************************
**** DESCRIBE   ********************************************************
constants:
  ABAP_MAX_ABS_TYPE_NAME_LN   type I value        200,
  ABAP_MAX_CLASS_NAME_LN      type I value         30,
  ABAP_MAX_INTF_NAME_LN       type I value         30,
  ABAP_MAX_COMP_NAME_LN       type I value         30,
  ABAP_MAX_KEY_NAME_LN        type I value        255,
  ABAP_MAX_CLASS_COMP_NAME_LN type I value         61,
  ABAP_MAX_EDIT_MASK_LN       type I value          7,
  ABAP_MAX_HELP_ID_LN         type I value         62,
  ABAP_MAX_DB_STRING_LN       type I value  536870912,
  ABAP_MAX_DB_RAWSTRING_LN    type I value 1073741824.



types:
* type kinds
  ABAP_TYPEKIND     type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPECATEGORY type C length 1, " check CL_ABAP_TYPEDESCR for values
  ABAP_TYPEPROPKIND type C length 1,
  ABAP_STRUCTKIND   type C length 1,
  ABAP_TABLEKIND    type C length 1,
  ABAP_KEYDEFKIND   type C length 1,
  ABAP_CLASSKIND    type C length 1,
  ABAP_INTFKIND     type C length 1,
  ABAP_PARMKIND     type C length 1,
* misc
  ABAP_EDITMASK     type C length ABAP_MAX_EDIT_MASK_LN,
  ABAP_HELPID       type C length ABAP_MAX_HELP_ID_LN,
  ABAP_VISIBILITY   type C length 1,
* name types
  ABAP_TYPENAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_ABSTYPENAME  type C length ABAP_MAX_ABS_TYPE_NAME_LN,
  ABAP_COMPNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_KEYNAME      type C length ABAP_MAX_KEY_NAME_LN,
  ABAP_KEYCOMPNAME  type          ABAP_KEYNAME,
  ABAP_CLASSNAME    type C length ABAP_MAX_CLASS_NAME_LN,
  ABAP_INTFNAME     type C length ABAP_MAX_INTF_NAME_LN,
  ABAP_ATTRNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_METHNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_EVNTNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
  ABAP_PARMNAME     type C length ABAP_MAX_COMP_NAME_LN,
  ABAP_EXCPNAME     type C length ABAP_MAX_COMP_NAME_LN,
* structure component description
  begin of ABAP_COMPDESCR,
    LENGTH    type I,
    DECIMALS  type I,
    TYPE_KIND type ABAP_TYPEKIND,
    NAME      type ABAP_COMPNAME,
  end of ABAP_COMPDESCR,
  ABAP_COMPDESCR_TAB type standard table of ABAP_COMPDESCR
                     with key NAME,
  begin of ABAP_COMPONENTDESCR,
    NAME       type STRING,
    TYPE       type ref to CL_ABAP_DATADESCR,
    AS_INCLUDE type ABAP_BOOL,
    SUFFIX     type STRING,
  end of ABAP_COMPONENTDESCR,
  ABAP_COMPONENT_TAB type standard table of ABAP_COMPONENTDESCR
                     with key NAME,
  begin of ABAP_SIMPLE_COMPONENTDESCR,
    NAME type STRING,
    TYPE type ref to CL_ABAP_DATADESCR,
  end of ABAP_SIMPLE_COMPONENTDESCR,
  ABAP_COMPONENT_SYMBOL_TAB type hashed table of ABAP_SIMPLE_COMPONENTDESCR
                            with unique key NAME,
  ABAP_COMPONENT_VIEW_TAB   type standard table of ABAP_SIMPLE_COMPONENTDESCR
                          with key NAME,
* key description of tables
  begin of ABAP_KEYDESCR,
    NAME type ABAP_KEYNAME,
  end of ABAP_KEYDESCR,
  ABAP_KEYDESCR_TAB type standard table of ABAP_KEYDESCR
                    with key NAME,
* description of all secondary keys and primary key of tables
  begin of ABAP_TABLE_KEYCOMPDESCR,
    NAME type ABAP_KEYCOMPNAME,
  end of ABAP_TABLE_KEYCOMPDESCR,
  begin of ABAP_TABLE_KEYDESCR,
    COMPONENTS  type standard table of ABAP_TABLE_KEYCOMPDESCR
                         with non-unique default key
                         initial size 4,
    NAME        type ABAP_COMPNAME,
    IS_PRIMARY  type ABAP_BOOL,
    ACCESS_KIND type ABAP_TABLEKIND,
    IS_UNIQUE   type ABAP_BOOL,
    KEY_KIND    type ABAP_KEYDEFKIND,
  end of ABAP_TABLE_KEYDESCR,
  ABAP_TABLE_KEYDESCR_TAB type standard table of ABAP_TABLE_KEYDESCR
                          with non-unique key NAME
                          initial size 2,
* map for mapping table key names to table key aliases
  begin of ABAP_KEY_ALIAS_PAIR,
    NAME  type ABAP_COMPNAME,
    ALIAS type ABAP_COMPNAME,
  end of ABAP_KEY_ALIAS_PAIR,
  ABAP_KEY_ALIAS_MAP type sorted table of ABAP_KEY_ALIAS_PAIR
                          with non-unique key NAME
                          with unique sorted key KEY_ALIAS components ALIAS
                          initial size 2,
* parameter description (methods and event)
  begin of ABAP_PARMDESCR,
    LENGTH      type I,
    DECIMALS    type I,
    TYPE_KIND   type ABAP_TYPEKIND,
    NAME        type ABAP_PARMNAME,
    PARM_KIND   type ABAP_PARMKIND,
    BY_VALUE    type ABAP_BOOL,
    IS_OPTIONAL type ABAP_BOOL,
  end of ABAP_PARMDESCR,
  ABAP_PARMDESCR_TAB type standard table of ABAP_PARMDESCR
                     with key NAME,
* exception description (method and event)
  begin of ABAP_EXCPDESCR,
    NAME         type ABAP_EXCPNAME,
    IS_RESUMABLE type ABAP_BOOL, "abap_false for old exceptions,
    "abap_true or abap_false for class based exceptions
  end of ABAP_EXCPDESCR,
  ABAP_EXCPDESCR_TAB type standard table of ABAP_EXCPDESCR
                     with key NAME,
* exposed and access friend description
  begin of ABAP_FRNDDESCR,
    NAME type ABAP_CLASSNAME,
  end of ABAP_FRNDDESCR,
  ABAP_FRNDDESCR_TAB type standard table of ABAP_FRNDDESCR
                     with key NAME,
* included interfaces / interface implementation description
  begin of ABAP_INTFDESCR,
    NAME         type ABAP_INTFNAME,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_INTFDESCR,
  ABAP_INTFDESCR_TAB type standard table of ABAP_INTFDESCR
                     with key NAME,
* type definition inside class / interface
  begin of ABAP_TYPEDEF,
    NAME         type ABAP_TYPENAME,
    ALIAS_FOR    type ABAP_TYPENAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
  end of ABAP_TYPEDEF,
  ABAP_TYPEDEF_TAB type standard table of ABAP_TYPEDEF
                     with key NAME,
* attribute description
  begin of ABAP_ATTRDESCR,
    LENGTH       type I,
    DECIMALS     type I,
    NAME         type ABAP_ATTRNAME,
    TYPE_KIND    type ABAP_TYPEKIND,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    IS_CONSTANT  type ABAP_BOOL,
    IS_VIRTUAL   type ABAP_BOOL,
    IS_READ_ONLY type ABAP_BOOL,
    ALIAS_FOR    type ABAP_ATTRNAME,
  end of ABAP_ATTRDESCR,
  ABAP_ATTRDESCR_TAB type standard table of ABAP_ATTRDESCR
                     with key NAME,
* method description
  begin of ABAP_METHDESCR,
    PARAMETERS       type ABAP_PARMDESCR_TAB,
    EXCEPTIONS       type ABAP_EXCPDESCR_TAB,
    NAME             type ABAP_METHNAME,
    FOR_EVENT        type ABAP_EVNTNAME,
    OF_CLASS         type ABAP_CLASSNAME,
    VISIBILITY       type ABAP_VISIBILITY,
    IS_INTERFACE     type ABAP_BOOL,
    IS_INHERITED     type ABAP_BOOL,
    IS_REDEFINED     type ABAP_BOOL,
    IS_ABSTRACT      type ABAP_BOOL,
    IS_FINAL         type ABAP_BOOL,
    IS_CLASS         type ABAP_BOOL,
    ALIAS_FOR        type ABAP_METHNAME,
    IS_RAISING_EXCPS type ABAP_BOOL, "abap_true if method declaration has a raising clause
    "abap_false otherwise
  end of ABAP_METHDESCR,
  ABAP_METHDESCR_TAB type standard table of ABAP_METHDESCR
                     with key NAME,
* event description
  begin of ABAP_EVNTDESCR,
    PARAMETERS   type ABAP_PARMDESCR_TAB,
    NAME         type ABAP_EVNTNAME,
    VISIBILITY   type ABAP_VISIBILITY,
    IS_INTERFACE type ABAP_BOOL,
    IS_INHERITED type ABAP_BOOL,
    IS_CLASS     type ABAP_BOOL,
    ALIAS_FOR    type ABAP_EVNTNAME,
  end of ABAP_EVNTDESCR,
  ABAP_EVNTDESCR_TAB type standard table of ABAP_EVNTDESCR
                     with key NAME,

* table for get_friend_types
  ABAP_FRNDTYPES_TAB type standard table of ref to CL_ABAP_TYPEDESCR
                     with key TABLE_LINE.


************************************************************************
************* DYNAMIC CALL FUNCTION ************************************
types:
* CALL FUNCTION ... PARAMETER-TABLE
  begin of ABAP_FUNC_PARMBIND,
    VALUE     type ref to DATA,
    TABLES_WA type ref to DATA,
    KIND      type I,
    NAME      type ABAP_PARMNAME,
  end of ABAP_FUNC_PARMBIND,
  ABAP_FUNC_PARMBIND_TAB type sorted table of ABAP_FUNC_PARMBIND
                         with unique key KIND NAME,
* CALL FUNCTION ... EXCEPTION-TABLE
  begin of ABAP_FUNC_EXCPBIND,
    MESSAGE type ref to DATA,
    VALUE   type I,
    NAME    type ABAP_EXCPNAME,
  end of ABAP_FUNC_EXCPBIND,
  ABAP_FUNC_EXCPBIND_TAB type hashed table of ABAP_FUNC_EXCPBIND
                         with unique key NAME.

constants:
  ABAP_FUNC_EXPORTING type ABAP_FUNC_PARMBIND-KIND value 10,
  ABAP_FUNC_IMPORTING type ABAP_FUNC_PARMBIND-KIND value 20,
  ABAP_FUNC_TABLES    type ABAP_FUNC_PARMBIND-KIND value 30,
  ABAP_FUNC_CHANGING  type ABAP_FUNC_PARMBIND-KIND value 40.

************************************************************************
************* DYNAMIC INVOKE *******************************************
types:
* PARAMETER-TABLE
  begin of ABAP_PARMBIND,
    NAME  type ABAP_PARMNAME,
    KIND  type ABAP_PARMKIND,
    VALUE type ref to DATA,
  end of ABAP_PARMBIND,
  ABAP_PARMBIND_TAB type hashed table of ABAP_PARMBIND
                    with unique key NAME,
* EXCEPTION-TABLE
  begin of ABAP_EXCPBIND,
    NAME  type ABAP_EXCPNAME,
    VALUE type I,
  end of ABAP_EXCPBIND,
  ABAP_EXCPBIND_TAB type hashed table of ABAP_EXCPBIND
                    with unique key NAME.


************************************************************************
**** Types for CL_ABAP_CHAR_UTILITIES **********************************
types:
  ABAP_CHAR1(1)           type C,
  ABAP_CR_LF(2)           type C,
  ABAP_BYTE_ORDER_MARK(2) type X,
  ABAP_BYTE_ORDER_UTF8(3) type X.


************************************************************************
**** CONVERSION ********************************************************
types:
  ABAP_ENCODING type ABAP_ENCOD,
  ABAP_ENDIAN   type ABAP_ENDIA.

************************************************************************
**** CALL TRANSFORMATION ***********************************************

* PARAMETER TABLE
types:
  ABAP_TRANS_PARMNAME  type STRING,
  ABAP_TRANS_PARMVALUE type STRING,
  ABAP_TRANS_PARMREF   type ref to DATA.

types:
  begin of ABAP_TRANS_PARMBIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMVALUE,
  end of ABAP_TRANS_PARMBIND,
  begin of ABAP_TRANS_PARM_OBJ_BIND,
    NAME  type ABAP_TRANS_PARMNAME,
    VALUE type ABAP_TRANS_PARMREF,
  end of ABAP_TRANS_PARM_OBJ_BIND.

types:
  ABAP_TRANS_PARMBIND_TAB
      type standard table of ABAP_TRANS_PARMBIND with key NAME,
  ABAP_TRANS_PARM_OBJ_BIND_TAB
      type sorted table of ABAP_TRANS_PARM_OBJ_BIND with unique key NAME.

* OBJECT TABLE
types:
  ABAP_TRANS_OBJNAME type STRING.

types:
  begin of ABAP_TRANS_OBJBIND,
    NAME  type ABAP_TRANS_OBJNAME,
    VALUE type ref to OBJECT,
  end of ABAP_TRANS_OBJBIND.

types:
  ABAP_TRANS_OBJBIND_TAB
      type standard table of ABAP_TRANS_OBJBIND with key NAME.

* SOURCE TABLE
types:
  ABAP_TRANS_SRCNAME type STRING.

types:
  begin of ABAP_TRANS_SRCBIND,
    NAME  type ABAP_TRANS_SRCNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_SRCBIND.

types:
  ABAP_TRANS_SRCBIND_TAB
       type standard table of ABAP_TRANS_SRCBIND with key NAME,
  ABAP_TRANS_SRCBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_SRCBIND with unique key NAME.

* RESULT TABLE
types:
  ABAP_TRANS_RESNAME type STRING.

types:
  begin of ABAP_TRANS_RESBIND,
    NAME  type ABAP_TRANS_RESNAME,
    VALUE type ref to DATA,
  end of ABAP_TRANS_RESBIND.

types:
  ABAP_TRANS_RESBIND_TAB
       type standard table of ABAP_TRANS_RESBIND with key NAME,
  ABAP_TRANS_RESBIND_TAB_SORTED
       type sorted table of ABAP_TRANS_RESBIND with unique key NAME.

*--- INCLUDE: CL_ABAP_DATADESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_DATADESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: CL_ABAP_TYPEDESCR=============CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_TYPEDESCR and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: %_CIHTTP ---*
TYPE-POOL ihttp .


*------------------------------------------------------------------
* table of registered handler class instances
*------------------------------------------------------------------
TYPES:
        BEGIN OF ihttp_ext_instance,
          extension  TYPE seoclsname,
          refpointer TYPE REF TO if_http_extension,
          url        TYPE string,
        END   OF ihttp_ext_instance.

TYPES:
       ihttp_ext_instances TYPE STANDARD TABLE OF ihttp_ext_instance
                             WITH KEY url.

" http client instances
TYPES:
        BEGIN OF ihttp_client_instance,
          name            TYPE string,
          client          TYPE REF TO cl_abap_weak_reference,
          state           TYPE i,
          path_translated TYPE string, "established for MI application view and debugger (in CL_MI_SEMANTIC_TREE_ICF)
        END   OF ihttp_client_instance.

TYPES:
        ihttp_client_instances TYPE STANDARD TABLE OF
                                  ihttp_client_instance WITH KEY name.

* --
* administration of server objects in case of
* local calls (CREATE_INTERNAL) and in HTTP_DISPATCH_REQUEST
* --
TYPES: BEGIN OF ihttp_local_server_instance,
         client_name   TYPE string,
         server        TYPE REF TO if_http_server,
       END OF ihttp_local_server_instance.

TYPES:
        ihttp_local_server_instances TYPE STANDARD TABLE OF
                      ihttp_local_server_instance WITH KEY client_name.

*
* -- ICF recorder exchange (upload/download) types
*
TYPES:
        BEGIN OF ihttp_recorder_action,
          client       TYPE symandt,
          user         TYPE syuname,
          action       TYPE i,
          time_stamp   TYPE timestampl,
        END OF ihttp_recorder_action.

TYPES: ihttp_recorder_actions
          TYPE STANDARD TABLE OF ihttp_recorder_action.

TYPES:
        BEGIN OF ihttp_recorder_attribute,
           type      TYPE i,
           version   TYPE i,
           entry     TYPE xstring,
        END OF ihttp_recorder_attribute.

TYPES: ihttp_recorder_attributes
           TYPE TABLE OF ihttp_recorder_attribute WITH KEY type.

* -- for recorder logon procedure (based on user/password or rfc ticket)
TYPES:
        BEGIN OF ihttp_recorder_logon,
          version        TYPE i,
          logon_client   TYPE symandt,
          logon_username TYPE syuname,
          logon_password TYPE string,
          logon_language TYPE sylangu,
          logon_ticket   TYPE xstring,
        END OF ihttp_recorder_logon.

CONSTANTS:
        ihttp_recorder_x_entry_size  TYPE i VALUE 500.

TYPES:
        BEGIN OF ihttp_recorder_x,
            entry(ihttp_recorder_x_entry_size)   TYPE x,
        END   OF ihttp_recorder_x,

        ihttp_recorder_x_version(1)              TYPE x.

* -- ICF Recorder runtime info
TYPES:
        BEGIN OF ihttp_recorder_field,
          range  TYPE i,
          index  TYPE i,
          name   TYPE string,
          value  TYPE string,
        END OF ihttp_recorder_field.

TYPES: ihttp_recorder_fields
            TYPE TABLE OF ihttp_recorder_field WITH KEY range.

TYPES:
* for CL_HTTP_RESPONSE (SET_COMPRESSION)
        BEGIN OF ihttp_icfparameter,
           compression_supported TYPE i,
           protocol        TYPE string,
           accept_encoding TYPE string,
        END OF ihttp_icfparameter.

* -- cache for ICF runtime
TYPES:
        BEGIN OF ihttp_rmemory_icfhandlst,
          icfhandlst               TYPE icfhandlst,
          header_fields            TYPE tihttpnvp,
          script_name              TYPE string,
          path_info                TYPE string,
        END OF ihttp_rmemory_icfhandlst,

        BEGIN OF ihttp_runtime_memory,
          version  TYPE i,
          host     TYPE i,
          path     TYPE string,
          servtbl  TYPE TABLE OF ihttp_rmemory_icfhandlst
                                  WITH KEY script_name,
          actlogin TYPE icflogin,
          urlsuffix TYPE string,
        END OF ihttp_runtime_memory.

* send last page IF_HTTP_SERVER
TYPES:
       BEGIN OF ihttp_service_page,
         kind       TYPE c,
         header     TYPE sotr_conc,
         body       TYPE sotr_conc,
         redirect   TYPE string,
         redirect_code TYPE i,
       END OF ihttp_service_page.
*
* mapping of options/extensions for ICF service from application aoutput
* string into generic service string "container"
*
TYPES:
        BEGIN OF ihttp_icfservice_extension,
          kind       TYPE i,
          version    TYPE i,
          content    TYPE string,
        END OF ihttp_icfservice_extension.
TYPES:
        ihttp_icfservice_extensions TYPE STANDARD TABLE OF
                  ihttp_icfservice_extension WITH KEY kind.
*
* mapping of authentication code to the name of the authentication method
*
TYPES:
        BEGIN OF ihttp_authmethod_identifier,
          code TYPE i,
          name TYPE string,
        END OF ihttp_authmethod_identifier.
TYPES:
        ihttp_authmethod_mapping TYPE TABLE OF ihttp_authmethod_identifier
          WITH KEY code.

*------------------------------------------------------------------
* constants
*------------------------------------------------------------------

* ICF virtual host number
CONSTANTS:
  ihttp_vhost_default             TYPE i VALUE 0.

* authorization types
CONSTANTS:
  ihttp_auth_type_basic_auth      TYPE i VALUE 1.

* authorization types
CONSTANTS:
  ihttp_user_agent_unknown       TYPE i VALUE -1, " ?
  ihttp_user_agent_null          TYPE i VALUE 0,  " ?
  ihttp_user_agent_nn            TYPE i VALUE 1,  " netscape navigator
  ihttp_user_agent_ie            TYPE i VALUE 2,  " ms internet explorer
  ihttp_user_agent_sapwebapp     TYPE i VALUE 3,
  ihttp_user_agent_opera         TYPE i VALUE 4,
  ihttp_user_agent_mozilla       TYPE i VALUE 5,
  ihttp_user_agent_mz            TYPE i VALUE 5,
  ihttp_user_agent_safari        TYPE i VALUE 6.

* cache invalidation modes
CONSTANTS:
  ihttp_inv_literal              TYPE i VALUE 0,
  ihttp_inv_wildcard             TYPE i VALUE 1,
  ihttp_inv_etag                 TYPE i VALUE 2.


* cache invalidation scope
CONSTANTS:
  ihttp_inv_local                TYPE i VALUE 0,
  ihttp_inv_global               TYPE i VALUE 1.

* use virtual host index fron request to determine the cache
CONSTANTS:
  ihttp_vhost_fromreq            TYPE i value -1.

* encoding types (cl_http_utility=>string_to_fields etc.)
CONSTANTS:
  ihttp_enc_none                 TYPE i VALUE 0,
  ihttp_enc_base64               TYPE i VALUE 1,
  ihttp_enc_url64                TYPE i VALUE 5.


*
* system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
*
CONSTANTS:
  ihttp_scid_get_status               TYPE i VALUE  1,
  ihttp_scid_set_status               TYPE i VALUE  2,
  ihttp_scid_add_multipart            TYPE i VALUE  3,
  ihttp_scid_append_cdata             TYPE i VALUE  4,
  ihttp_scid_append_data              TYPE i VALUE  5,
  ihttp_scid_get_cdata                TYPE i VALUE  6,
  ihttp_scid_get_cookie               TYPE i VALUE  7,
  ihttp_scid_get_data                 TYPE i VALUE  8,
  ihttp_scid_get_form_field           TYPE i VALUE  9,
  ihttp_scid_get_form_fields          TYPE i VALUE 10,
  ihttp_scid_get_header_field         TYPE i VALUE 11,
  ihttp_scid_get_header_fields        TYPE i VALUE 12,
  ihttp_scid_get_multipart            TYPE i VALUE 13,
  ihttp_scid_instantiate              TYPE i VALUE 14,
  ihttp_scid_num_multiparts           TYPE i VALUE 15,
  ihttp_scid_serialize                TYPE i VALUE 16,
  ihttp_scid_set_cdata                TYPE i VALUE 17,
  ihttp_scid_add_cookie               TYPE i VALUE 18,
  ihttp_scid_set_data                 TYPE i VALUE 19,
  ihttp_scid_add_form_field           TYPE i VALUE 20,
  ihttp_scid_add_form_fields          TYPE i VALUE 21,
  ihttp_scid_add_header_field         TYPE i VALUE 22,
  ihttp_scid_add_header_fields        TYPE i VALUE 23,
  ihttp_scid_create_message           TYPE i VALUE 24,
  ihttp_scid_delete_message           TYPE i VALUE 25,
  ihttp_scid_remove_header_field      TYPE i VALUE 26,
  ihttp_scid_remove_cookie            TYPE i VALUE 27,
  ihttp_scid_get_message_data         TYPE i VALUE 28,
  ihttp_scid_get_cookie_field         TYPE i VALUE 30,
  ihttp_scid_add_cookie_field         TYPE i VALUE 31,
  ihttp_scid_remove_form_field        TYPE i VALUE 32,
  ihttp_scid_get_authorization        TYPE i VALUE 33,
  ihttp_scid_url_escape               TYPE i VALUE 34,
  ihttp_scid_url_unescape             TYPE i VALUE 35,
  ihttp_scid_html_escape              TYPE i VALUE 36,
  ihttp_scid_base64_escape            TYPE i VALUE 37,
  ihttp_scid_base64_unescape          TYPE i VALUE 38,
  ihttp_scid_set_authorization        TYPE i VALUE 39,
  ihttp_scid_str_to_field_list        TYPE i VALUE 40,
  ihttp_scid_field_list_to_str        TYPE i VALUE 41,
  ihttp_scid_get_user_agent           TYPE i VALUE 46,
  ihttp_scid_get_cookies              TYPE i VALUE 48,
  ihttp_scid_get_uri_parameter        TYPE i VALUE 49,
  ihttp_scid_append_cdata2            TYPE i VALUE 50,
  ihttp_scid_get_form_field_cs        TYPE i VALUE 51,
  ihttp_scid_get_form_fields_cs       TYPE i VALUE 53,
  ihttp_scid_compress_data            TYPE i VALUE 54,
  ihttp_scid_compress_supported       TYPE i VALUE 56,
  ihttp_scid_get_proto_version        TYPE i VALUE 57,
  ihttp_scid_del_hfield_secure        TYPE i VALUE 60,
  ihttp_scid_del_cookie_secure        TYPE i VALUE 61,
  ihttp_scid_del_ffield_secure        TYPE i VALUE 62,
  ihttp_scid_suppr_content_type       TYPE i VALUE 63,
  ihttp_scid_call_is_implemented      TYPE i VALUE 64,
  ihttp_scid_copy_message             TYPE i VALUE 65,
  ihttp_scid_get_request_method       TYPE i VALUE 66,
  ihttp_scid_get_message_length       TYPE i VALUE 67,
  ihttp_scid_get_content_type         TYPE i VALUE 68,
  ihttp_scid_set_proto_version        TYPE i VALUE 69,
  ihttp_scid_set_request_method       TYPE i VALUE 70,
  ihttp_scid_set_content_type         TYPE i VALUE 72,
  ihttp_scid_get_serialized_leng      TYPE i VALUE 73,
  ihttp_scid_http_redirect            TYPE i VALUE 74,
  ihttp_scid_get_data2                TYPE i VALUE 76,
  ihttp_scid_get_data_length          TYPE i VALUE 77,
  ihttp_scid_url_escape_2             TYPE i VALUE 78,
  ihttp_scid_url_unescape_2           TYPE i VALUE 79,
  ihttp_scid_html_escape2             TYPE i VALUE 80,
  ihttp_scid_crc32_checksum           TYPE i VALUE 81,
  ihttp_scid_set_request_message      TYPE i VALUE 82,
  ihttp_scid_jscript_escape           TYPE i VALUE 83,
  ihttp_scid_url_normalize            TYPE i VALUE 84,
  ihttp_scid_check_uri                TYPE i VALUE 85,
  ihttp_scid_base64_escape_x          TYPE i VALUE 86,
  ihttp_scid_base64_unescape_x        TYPE i VALUE 87,
  ihttp_scid_get_form_field_2         TYPE i VALUE 90,
  ihttp_scid_get_form_fields_2        TYPE i VALUE 91,
  ihttp_scid_suppr_content_len        TYPE i VALUE 92,
  ihttp_scid_url_path_escape          TYPE i VALUE 93,
  ihttp_scid_xmlhtml_escape_xss       TYPE i VALUE 94,
  ihttp_scid_jscript_escape_xss       TYPE i VALUE 95,
  ihttp_scid_url_escape_xss           TYPE i VALUE 96,
  ihttp_scid_css_escape_xss           TYPE i VALUE 97,
  ihttp_scid_instname_encode          TYPE i VALUE 98,
  ihttp_scid_serialize_with_opt       TYPE i VALUE 99,
  ihttp_scid_str_to_cookie_hash       TYPE i VALUE 100,
  ihttp_scid_suppr_charset            TYPE i VALUE 101,
  ihttp_scid_suppr_f_fields_body      TYPE i VALUE 102,
  ihttp_scid_preserve_mp_boundry      TYPE i VALUE 103,
  ihttp_scid_get_serversentevent      TYPE i VALUE 104.
*
* return code for non-existing (ICT_ENOTIMPL) syscalls
*
CONSTANTS:
  ihttp_syscall_not_implemented       TYPE i VALUE 4.

* option for IF_HTTP_UTILITY~ESCAPE_HTML parameter KEEP_NUM_CHAR_REF
* if set, HTML numeric character references are not escaped.
* if HTML_ESCAPE_ATTRIBUTE the character = is also escaped.
* The option JSCRIPT_ESCAPE_IN_HTML is for IF_HTTP_UTILITY~ESCAPE_JAVASCRIPT
CONSTANTS:
  ihttp_keep_num_char_ref             TYPE i VALUE 1,
  ihttp_html_escape_attribute         TYPE i VALUE 2,
  ihttp_jscript_escape_in_html        TYPE i VALUE 4.

* options for serialize (not exposed to application)
* see krn/ict/ictxxabap.c for details
CONSTANTS:
  ihttp_serialize_tilde_fld           TYPE i VALUE 1,
  ihttp_serialize_hide_sensitive      TYPE i VALUE 2,
  ihttp_serialize_header_only         TYPE i VALUE 4.

* -- icf recorder constants

CONSTANTS: ihttp_c_timezone_utc         TYPE tznzone VALUE IS INITIAL.

CONSTANTS:
  ihttp_start_modify_record             TYPE i VALUE 1, " enqueue step
  ihttp_cont_modify_record              TYPE i VALUE 2, " continue modi.
  ihttp_canc_modify_record              TYPE i VALUE 3, " cancel modi.
  ihttp_end_modify_record               TYPE i VALUE 4, " dequeue step
  ihttp_show_record                     TYPE i VALUE 5,
  ihttp_show_failed_logon_record        TYPE i VALUE 6,
  ihttp_delete_record                   TYPE i VALUE 7,
  ihttp_execute_record_request          TYPE i VALUE 8,
  ihttp_execute_record_request_o        TYPE i VALUE 9, "origin exec.
  ihttp_execute_record_request_l        TYPE i VALUE 10,"local exec.
  ihttp_download_record                 TYPE i VALUE 11,
  ihttp_upload_record                   TYPE i VALUE 12,
  ihttp_activate_protocol_action        TYPE i VALUE 13,
  ihttp_copy_record                     TYPE i VALUE 14,
  ihttp_delete_recorder_client          TYPE i VALUE 15,
  ihttp_start_admin_record              TYPE i VALUE 16, " enqueue step
  ihttp_cont_admin_record               TYPE i VALUE 17, " continue modi
  ihttp_canc_admin_record               TYPE i VALUE 18, " cancel modi.
  ihttp_end_admin_record                TYPE i VALUE 19, " dequeue step
  ihttp_show_protocol_record            TYPE i VALUE 20. " dequeue step


CONSTANTS:
   ihttp_recorder_attrib_version     TYPE  i VALUE 1,
   ihttp_recorder_attrib_action      TYPE  i VALUE 2,
   ihttp_recorder_attrib_logon       TYPE  i VALUE 3,
   ihttp_recorder_attrib_fields      TYPE  i VALUE 4.

* -- recorder level for ICF server
CONSTANTS:
   ihttp_record_playback              TYPE  i VALUE -100,
   ihttp_record_failed_auth           TYPE  i VALUE 1,
   ihttp_record_request_status        TYPE  i VALUE 2,
   ihttp_record_request               TYPE  i VALUE 3,
   ihttp_record_response_status       TYPE  i VALUE 4,
   ihttp_record_response              TYPE  i VALUE 5,
   ihttp_record_last_possibility      TYPE  i VALUE 6,
   ihttp_record_with_cookie           TYPE  i VALUE 100.

* -- recorder level for ICF client
CONSTANTS:
   ihttp_record_crequest_status       TYPE  i VALUE 1,
   ihttp_record_crequest              TYPE  i VALUE 2,
   ihttp_record_cresponse_status      TYPE  i VALUE 3,
   ihttp_record_cresponse             TYPE  i VALUE 4,
   ihttp_record_clast_possibility     TYPE  i VALUE 5.

*constants:
*   ihttp_record_accept_cookie_id      type  i value -100,
*   ihttp_record_send_cookie_id        type  i value -200.

CONSTANTS:
* LOGON
   ihttp_recorder_status_logon      TYPE  icfstatus VALUE '1',
* DOWNLOAD
   ihttp_recorder_status_download   TYPE  icfstatus VALUE '2',
* UPLOAD
   ihttp_recorder_status_upload     TYPE  icfstatus VALUE '4',
* COPY
   ihttp_recorder_status_copy       TYPE  icfstatus VALUE '10'.

CONSTANTS:
   ihttp_recorder_client_oblig   TYPE  icfrecoder_lmethod VALUE '1',
   ihttp_recorder_client_hfield  TYPE  icfrecoder_lmethod VALUE '2',
   ihttp_recorder_client_ffield  TYPE  icfrecoder_lmethod VALUE '3',
   ihttp_recorder_client_context TYPE  icfrecoder_lmethod VALUE '4',
   ihttp_recorder_client_service TYPE  icfrecoder_lmethod VALUE '5',
   ihttp_recorder_client_server  TYPE  icfrecoder_lmethod VALUE '6'.

CONSTANTS:
   ihttp_recorder_langu_oblig   TYPE  icfrecoder_lmethod VALUE '1',
   ihttp_recorder_langu_hfield  TYPE  icfrecoder_lmethod VALUE '2',
   ihttp_recorder_langu_ffield  TYPE  icfrecoder_lmethod VALUE '3',
   ihttp_recorder_langu_context TYPE  icfrecoder_lmethod VALUE '4',
   ihttp_recorder_langu_service TYPE  icfrecoder_lmethod VALUE '5',
   ihttp_recorder_langu_server  TYPE  icfrecoder_lmethod VALUE '6',
   ihttp_recorder_langu_accept  TYPE  icfrecoder_lmethod VALUE '7',
   ihttp_recorder_langu_slogin  TYPE  icfrecoder_lmethod VALUE '8'.


CONSTANTS:
   ihttp_recorder_user_oblig   TYPE  c VALUE '1',
   ihttp_recorder_user_hfield  TYPE  c VALUE '2',
   ihttp_recorder_user_ffield  TYPE  c VALUE '3',
   ihttp_recorder_user_service TYPE  c VALUE '4',
   ihttp_recorder_user_bauth   TYPE  c VALUE '5',
   ihttp_recorder_auser_hfield TYPE  c VALUE '6',
   ihttp_recorder_auser_ffield TYPE  c VALUE '7',
   ihttp_recorder_auser_bauth  TYPE  c VALUE '8'.

CONSTANTS:
   ihttp_recorder_passwd_oblig   TYPE  c VALUE '1',
   ihttp_recorder_passwd_hfield  TYPE  c VALUE '2',
   ihttp_recorder_passwd_ffield  TYPE  c VALUE '3',
   ihttp_recorder_passwd_service TYPE  c VALUE '4',
   ihttp_recorder_passwd_bauth   TYPE  c VALUE '5'.

CONSTANTS:
   ihttp_recorder_bauth_ticket  TYPE c VALUE '1',
   ihttp_recorder_sso_ticket    TYPE c VALUE '2',
   ihttp_recorder_ssorej_ticket TYPE c VALUE '3',
   ihttp_recorder_r3auth_ticket TYPE c VALUE '4',
   ihttp_recorder_x509_ticket   TYPE c VALUE '5',
   ihttp_recorder_saml_ticket   TYPE c VALUE '6',
   ihttp_recorder_oauth2_ticket TYPE c VALUE '7',
   ihttp_recorder_spnego_ticket TYPE c VALUE '8'.

CONSTANTS:
   ihttp_recorder_break_token   TYPE icfchar4 VALUE '=',
   ihttp_recorder_tickets_token TYPE icfchar4 VALUE '-T:',
   ihttp_recorder_auth_token    TYPE icfchar4 VALUE '-a:',
   ihttp_recorder_user_token    TYPE icfchar4 VALUE '-u:',
   ihttp_recorder_users_token   TYPE icfchar4 VALUE '-U:',
   ihttp_recorder_passwds_token TYPE icfchar4 VALUE '-P:',
   ihttp_recorder_client_token  TYPE icfchar4 VALUE '-c:',
   ihttp_recorder_clients_token TYPE icfchar4 VALUE '-C:',
   ihttp_recorder_langu_token   TYPE icfchar4 VALUE '-l:',
   ihttp_recorder_langus_token  TYPE icfchar4 VALUE '-L:',
   ihttp_recorder_subrc_token   TYPE icfchar4 VALUE '-r:',
   ihttp_recorder_saprc_token   TYPE icfchar4 VALUE '-R:'.

CONSTANTS:
* -- E: for upload/download messages
   ihttp_recorder_ext_message_e  TYPE icfexternal_message VALUE 'E'.

CONSTANTS:
   ihttp_recorder_message_type_i  TYPE icfmsgtype VALUE 'I',
   ihttp_recorder_exp_mstype      TYPE icfmsgtype VALUE 'A'.

CONSTANTS:
   ihttp_recorder_exp_mandt TYPE symandt         VALUE '000',
   ihttp_recorder_exp_msgid TYPE icfrecoder_uuid VALUE 'FFFF',
   ihttp_icf_admin_msgid    TYPE icfrecoder_uuid VALUE 'AAAA'.

CONSTANTS:
  ihttp_recorder_role_sextern     TYPE char2 VALUE 'SE',
  ihttp_recorder_role_slocal      TYPE char2 VALUE 'SL',
  ihttp_recorder_role_cextern     TYPE char2 VALUE 'CE',
  ihttp_recorder_role_clocal      TYPE char2 VALUE 'CL'.

CONSTANTS:
   ihttp_recorder_exp_date_basis TYPE sydatum VALUE '20010101',
   ihttp_recorder_def_exp_day    TYPE i VALUE 30, "-> ~ 1 Month
   ihttp_recorder_def_exp_time   TYPE syuzeit VALUE '000000'.

CONSTANTS:
   ihttp_recorder_protocol_http  TYPE c       VALUE '1',
   ihttp_recorder_protocol_https TYPE c       VALUE '2'.

* -- Taskhandler performance (perfinterval)
CONSTANTS: ihttp_opcode_open_interval     TYPE x VALUE 17,
           ihttp_opcode_close_interval    TYPE x VALUE 18.


*
* Header, Form and Cookie Fields used in ICF
*
CONSTANTS:
  ihttp_c_sap_recorder     TYPE string VALUE 'sap-recorder',
  ihttp_c_sap_recorder_sid TYPE string VALUE 'sap-recorder_sid',
  ihttp_c_sap_recorder_aut TYPE string VALUE 'sap-rauth'.

*
* Maximum number of recorder entries per user account
* Maximum number of failed logon entries per client
*
CONSTANTS:
  ihttp_recorder_max_usr_entries  TYPE i VALUE 100,
  ihttp_recorder_max_log_entries  TYPE i VALUE 500.

* icf service extension kindes
CONSTANTS:
  ihttp_icfservice_extension_its  TYPE i VALUE 1,
  ihttp_icfservice_extension_bsp  TYPE i VALUE 2,
  ihttp_icfservice_extension_sam  TYPE i VALUE 3. "saml logon procedure


CONSTANTS:
  ihttp_icfservice_action_pack    TYPE i VALUE 1,
  ihttp_icfservice_action_unpack  TYPE i VALUE 2.

CONSTANTS:
  ihttp_recorder_field_range_loc   TYPE i VALUE 1, "locale information
  ihttp_recorder_field_range_exe   TYPE i VALUE 2, "execute_request
  ihttp_recorder_field_range_cck   TYPE i VALUE 3, "client cookie
  ihttp_recorder_field_range_clo   TYPE i VALUE 4, "client logon popup
  ihttp_recorder_field_range_cre   TYPE i VALUE 5, "client redirect
  ihttp_recorder_field_range_col   TYPE i VALUE 6, "client obj. length
  ihttp_recorder_field_range_sol   TYPE i VALUE 7. "server obj. length

CONSTANTS:
  ihttp_recorder_field_name_ext   TYPE char32 VALUE 'IF_HTTP_EXTENSION',
  ihttp_recorder_field_name_ccoo  TYPE char32
                                  VALUE 'PROPERTYTYPE_ACCEPT_COOKIE'.

*
* /system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
*

*--- INCLUDE: CL_ABAP_WEAK_REFERENCE========CT ---*
*" dummy include to reduce generation dependencies between
*" class CL_ABAP_WEAK_REFERENCE and it's users.
*" touched if any type reference has been changed

*--- INCLUDE: IF_HTTP_EXTENSION=============IT ---*

*--- INCLUDE: IF_HTTP_SERVER================IT ---*

*--- INCLUDE: %_CSLIS ---*
type-pool slis .

types: slis_list_type(1) type n,
       slis_char_1(1) type c,
       slis_text40(40) type c.

types: slis_tabname(30) type c,
       slis_fieldname(30) type c,
       slis_sel_tab_field(60) type c,
       slis_formname(30) type c,
       slis_entry(60) type c,
       slis_edit_mask(60) type c,
       slis_coldesc(4) type c.

*Accessibility
types: slis_qinfo_alv type alv_s_qinf,
       slis_t_qinfo_alv type slis_qinfo_alv occurs 0.

*types: begin of slis_filtered_entries,
*         index type i,
*       end of slis_filtered_entries.
types: slis_t_filtered_entries type i occurs 0.

*--- Structure for additional fieldcat
types: begin of slis_add_fieldcat,
         fieldname type slis_fieldname,
         web_field type slis_fieldname,
         href_hndl type i,
       end of slis_add_fieldcat.
types: slis_t_add_fieldcat type slis_add_fieldcat occurs 0.

*--- Structure for reprep-initialization
types: begin of slis_reprep_id,
         tool(2) type c,
         appl(4) type c,
         subc(2) type c,
         onam(54) type c,
       end of slis_reprep_id.

types: begin of slis_reprep_communication,
         stop(1) type c,
       end of slis_reprep_communication.

*** Structure for colors
types: begin of slis_color,
         col type i,
         int type i,
         inv type i,
       end of slis_color.

types: begin of slis_coltypes,
         heacolfir      type slis_color, " heading_cols_first
         heacolnex      type slis_color, " heading_cols_nex
         hearowfir      type slis_color, " heading_rows_first
         hearownex      type slis_color, " heading_rows_next
         lisbodfir      type slis_color, " list_body_first
         lisbodnex      type slis_color, " list_body_next
         lisbod         type slis_color, " list_body
         higcolkey      type slis_color, " highlight_col_key
         higcol         type slis_color, " highlight_col
         higrow         type slis_color, " highlight_row
         higsum         type slis_color, " highlight_sum
         higsumhig      type slis_color, " highlight_sum_high
         higsumlow      type slis_color, " highlight_sum_low
         higins         type slis_color, " highlight_inserted
         higpos         type slis_color, " highlight_positive
         higneg         type slis_color, " highlight_negative
         hig            type slis_color, " highlight
         heahie         type slis_color, " heading_hier
         lisbodhie      type slis_color, " list_body_hierinfo
       end of slis_coltypes.

*** Fieldcat
types: begin of slis_fieldcat_main0,
         row_pos        like sy-curow, " output in row
         col_pos        like sy-cucol, " position of the column
         fieldname      type slis_fieldname,
         tabname        type slis_tabname,
         currency(5)    type c,
         cfieldname     type slis_fieldname, " field with currency unit
         ctabname       type slis_tabname,   " and table
         ifieldname     type slis_fieldname, " initial column
         quantity(3)    type c,
         qfieldname     type slis_fieldname, " field with quantity unit
         qtabname       type slis_tabname,   " and table
         round          type i,        " round in write statement
         exponent(3)       type c,     " exponent for floats
         key(1)         type c,        " column with key-color
         icon(1)        type c,        " as icon
         symbol(1)      type c,        " as symbol
         checkbox(1)    type c,        " as checkbox
         just(1)        type c,        " (R)ight (L)eft (C)ent.
         lzero(1)       type c,        " leading zero
         no_sign(1)     type c,        " write no-sign
         no_zero(1)     type c,        " write no-zero
         no_convext(1)  type c,
         edit_mask      type slis_edit_mask,                "
         emphasize(4)   type c,        " emphasize
         fix_column(1)   type c,       " Spalte fixieren
         do_sum(1)      type c,        " sum up
         no_out(1)      type c,        " (O)blig.(X)no out
         tech(1)        type c,        " technical field
         outputlen      like dd03p-outputlen,
         offset         type dd03p-outputlen,     " offset
         seltext_l      like dd03p-scrtext_l, " long key word
         seltext_m      like dd03p-scrtext_m, " middle key word
         seltext_s      like dd03p-scrtext_s, " short key word
         ddictxt(1)     type c,        " (S)hort (M)iddle (L)ong
         rollname       like dd03p-rollname,
         datatype       like dd03p-datatype,
         inttype        like dd03p-inttype,
         intlen         like dd03p-intlen,
         lowercase      like dd03p-lowercase,
         decfloat_style type outputstyle,          " B20K8A2GF0
         parameter0     type char30,
         parameter1     type char30,
         parameter2     type char30,
         parameter3     type char30,
         parameter4     type char30,
         parameter5     type int4,
         parameter6     type int4,
         parameter7     type int4,
         parameter8     type int4,
         parameter9     type int4,
       end of slis_fieldcat_main0.

types: begin of slis_fieldcat_main1,
         ref_fieldname  like dd03p-fieldname,
         ref_tabname    like dd03p-tabname,
         roundfieldname type slis_fieldname,
         roundtabname   type slis_tabname,
         decimalsfieldname type slis_fieldname,
         decimalstabname   type slis_tabname,
         decimals_out(6)   type c,     " decimals in write statement
         text_fieldname type slis_fieldname,
         reptext_ddic   like dd03p-reptext,   " heading (ddic)
         ddic_outputlen like dd03p-outputlen,
       end of slis_fieldcat_main1.

types: begin of slis_fieldcat_main.
include type slis_fieldcat_main0.
include type slis_fieldcat_main1.
types: end of slis_fieldcat_main.

types: begin of slis_fieldcat_alv_spec,
         key_sel(1)     type c,        " field not obligatory
         no_sum(1)      type c,        " do not sum up
         sp_group(4)    type c,        " group specification
         reprep(1)      type c,        " selection for rep/rep
         input(1)       type c,        " input
         edit(1)        type c,        " internal use only
         hotspot(1)     type c,        " hotspot
       end of slis_fieldcat_alv_spec.

types: begin of slis_fieldcat_alv.
include type slis_fieldcat_main.
include type slis_fieldcat_alv_spec.
types: end of slis_fieldcat_alv.

types: begin of slis_fieldcat_alv1.
include type slis_fieldcat_main1.
types: end of slis_fieldcat_alv1.

types: slis_t_fieldcat_alv type slis_fieldcat_alv occurs 1.

* Events for Callback
types: begin of slis_event_exit.
types:   ucomm like sy-ucomm,
         before(1) type c,
         after(1) type c,
       end of slis_event_exit.
types: slis_t_event_exit type slis_event_exit occurs 1.

* Callback Interface structure for non display subtotals text
types: begin of slis_subtot_text,
         criteria type slis_fieldname,
         keyword  like dd03p-reptext,
         criteria_text(255) type c,
         max_len  like dd03p-outputlen,
         display_text_for_subtotal(255) type c,
       end of slis_subtot_text.

*** Layout
types: begin of slis_print_alv0,
         print(1) type c,              " print to spool
         prnt_title(1) type c,         " moment to print the title
       end of slis_print_alv0.

types: begin of slis_print_alv1,
         no_print_selinfos(1) type c,  " display no selection infos
         no_coverpage(1) type c,                            "
         no_new_page(1) type c,                             "
         reserve_lines type i,         " lines reserved for end of page
         no_print_listinfos(1) type c, " display no listinfos
         no_change_print_params(1) type c,  " don't change linesize
         no_print_hierseq_item(1) type c,  "don't expand item
         print_ctrl type ALV_S_Pctl,
       end of slis_print_alv1.

types: begin of slis_print_alv.
include type alv_s_prnt.
include type slis_print_alv1.
types: end of slis_print_alv.

types: begin of slis_layout_main,
         dummy,
       end of slis_layout_main.

types: begin of slis_layout_alv_spec0,
         no_colhead(1) type c,         " no headings
         no_hotspot(1) type c,         " headings not as hotspot
         zebra(1) type c,              " striped pattern
         no_vline(1) type c,           " columns separated by space
         no_hline(1) type c,        "rows separated by space B20K8A0N5D
         cell_merge(1) type c,         " not suppress field replication
         edit(1) type c,               " for grid only
         edit_mode(1) type c,          " for grid only
         numc_sum(1)     type c,       " totals for NUMC-Fields possib.
         no_input(1) type c,           " only display fields
         f2code like sy-ucomm,                              "
         reprep(1) type c,             " report report interface active
         no_keyfix(1) type c,          " do not fix keycolumns
         expand_all(1) type c,         " Expand all positions
         no_author(1) type c,          " No standard authority check
*        PF-status
         def_status(1) type c,         " default status  space or 'A'
         item_text(20) type c,         " Text for item button
         countfname type lvc_fname,
       end of slis_layout_alv_spec0.

types: begin of slis_layout_alv_spec1,
*        Display options
         colwidth_optimize(1) type c,
         no_min_linesize(1) type c,    " line size = width of the list
         min_linesize like sy-linsz,   " if initial min_linesize = 80
         max_linesize like sy-linsz,   " Default 250
         window_titlebar like sy-title,
         no_uline_hs(1) type c,
*        Exceptions
         lights_fieldname type slis_fieldname," fieldname for exception
         lights_tabname type slis_tabname, " fieldname for exception
         lights_rollname like dfies-rollname," rollname f. exceptiondocu
         lights_condense(1) type c,    " fieldname for exception
*        Sums
         no_sumchoice(1) type c,       " no choice for summing up
         no_totalline(1) type c,       " no total line
         no_subchoice(1) type c,       " no choice for subtotals
         no_subtotals(1) type c,       " no subtotals possible
         no_unit_splitting type c,     " no sep. tot.lines by inh.units
         totals_before_items type c,   " diplay totals before the items
         totals_only(1) type c,        " show only totals
         totals_text(60) type c,       " text for 1st col. in total line
         subtotals_text(60) type c,    " text for 1st col. in subtotals
*        Interaction
         box_fieldname type slis_fieldname, " fieldname for checkbox
         box_tabname type slis_tabname," tabname for checkbox
         box_rollname like dd03p-rollname," rollname for checkbox
         expand_fieldname type slis_fieldname, " fieldname flag 'expand'
         hotspot_fieldname type slis_fieldname, " fieldname flag hotspot
         confirmation_prompt,          " confirm. prompt when leaving
         key_hotspot(1) type c,        " keys as hotspot " K_KEYHOT
         flexible_key(1) type c,       " key columns movable,...
         group_buttons(1) type c,      " buttons for COL1 - COL5
         get_selinfos(1) type c,       " read selection screen
         group_change_edit(1) type c,  " Settings by user for new group
         no_scrolling(1) type c,       " no scrolling
*        Detailed screen
         detail_popup(1) type c,       " show detail in popup
         detail_initial_lines(1) type c, " show also initial lines
         detail_titlebar like sy-title," Titlebar for detail
*        Display variants
         header_text(20) type c,       " Text for header button
         default_item(1) type c,       " Items as default
*        colour
         info_fieldname type slis_fieldname, " infofield for listoutput
         coltab_fieldname type slis_fieldname, " colors
*        others
         list_append(1) type c,       " no call screen
         xifunckey type aqs_xikey,    " eXtended interaction(SAPQuery)
         xidirect type flag,          " eXtended INTeraction(SAPQuery)
         dtc_layout type dtc_s_layo,  "Layout for configure the Tabstip
         allow_switch_to_list(1) type c, "ACC: Switch from FullGrid to List
       end of slis_layout_alv_spec1.

types: begin of slis_layout_alv_spec.
include type slis_layout_alv_spec0.
include type slis_layout_alv_spec1.
types: end of slis_layout_alv_spec.

types: begin of slis_layout_alv.
include type slis_layout_main.
include type slis_layout_alv_spec.
types: end of slis_layout_alv.

types: begin of slis_layout_alv1.
include type slis_layout_main.
include type slis_layout_alv_spec1.
types: end of slis_layout_alv1.

*--- Structure for the excluding table (function codes)
types: begin of slis_extab,
         fcode like rsmpe-func,
       end of slis_extab.
*--- Lineinfo before output
types: begin of slis_lineinfo,
         tabname type slis_tabname,
         tabindex like sy-tabix,
         subtot(1) type c,
         subtot_level(2) type n,
         endsum(1) type c,
         sumindex like sy-tabix,
         linsz like sy-linsz,
         linno like sy-linno,
       end of slis_lineinfo.
*--- Structure for scrolling in list
types: begin of slis_list_scroll,
         lsind like sy-lsind,
         cpage like sy-cpage,
         staro like sy-staro,
         staco like sy-staco,
         cursor_line like sy-curow,
         cursor_offset like sy-cucol,
       end of slis_list_scroll.
* information cursor position ALV
types: begin of slis_selfield,
         tabname type slis_tabname,
         tabindex like sy-tabix,
         sumindex like sy-tabix,
         endsum(1) type c,
         sel_tab_field type slis_sel_tab_field,
         value type slis_entry,
         before_action(1) type c,
         after_action(1) type c,
         refresh(1) type c,
         ignore_multi(1) type c, " ignore selection by checkboxes (F2)
         col_stable(1) type c,
         row_stable(1) type c,
*        colwidth_optimize(1) type c,
         exit(1) type c,
         fieldname type slis_fieldname,
         grouplevel type i,
         collect_from type i,
         collect_to type i,
       end of slis_selfield.

*--- excluding table
types: slis_t_extab type slis_extab occurs 1.
* special groups for column selection
types: begin of slis_sp_group_alv,
         sp_group(4) type c,
         text(40) type c,
       end of slis_sp_group_alv.
types: slis_t_sp_group_alv type slis_sp_group_alv occurs 1.

* information for sort and subtotals
types: begin of slis_sortinfo_alv,
*        spos(2) type n,
         spos like alvdynp-sortpos,
         fieldname type slis_fieldname,
         tabname type slis_fieldname,
*        up(1) type c,
*        down(1) type c,
*        group(2) type c,
*        subtot(1) type c,
         up like alvdynp-sortup,
         down like alvdynp-sortdown,
         group like alvdynp-grouplevel,
         subtot like alvdynp-subtotals,
         comp(1) type c,
         expa(1) type c,
         obligatory(1) type c,
       end of slis_sortinfo_alv.
types: slis_t_sortinfo_alv type slis_sortinfo_alv occurs 1.
* information for selections
types: begin of slis_seldis1_alv,
         field like dfies-fieldname,
         table like dfies-tabname,
         stext(40),
         valuf(80),
         valut(80),
         sign0(1),
         optio(2),
         ltext(40),
         stype(1),
         length type p,
         no_text(1),
         inttype like dfies-inttype,
         fieldname type slis_fieldname,
         tabname type slis_tabname,
         org_selname type rsscr_name,  "introduced this FO 09.01.00
       end of slis_seldis1_alv.

types: slis_seldis_alv type slis_seldis1_alv occurs 1.

* filter
types: begin of slis_filter_alv0,
         fieldname type slis_fieldname,
         tabname type slis_tabname,
         seltext(40),
         valuf(80),
         valut(80),
         valuf_int(80),
         valut_int(80),
         sign0(1),
         sign_icon(4),
         optio(2),
         stype(1),
         decimals like dfies-decimals,
         intlen like dfies-intlen,
         convexit like dfies-convexit,
         edit_mask type slis_edit_mask,
         lowercase like dfies-lowercase,
         inttype like dfies-inttype,
         datatype like dfies-datatype,
         exception(1) type c,
         no_sign(1) type c,
         or(1) type c,
         order type order,
         cqvalue(5) type c,
       end of slis_filter_alv0.

types: begin of slis_filter_alv1,
         ref_fieldname like dfies-fieldname,
         ref_tabname like dfies-tabname,
         ddic_outputlen like dfies-outputlen,
       end of slis_filter_alv1.

types: begin of slis_filter_alv.
include type slis_filter_alv0.
include type slis_filter_alv1.
types: end of slis_filter_alv.
types: slis_t_filter_alv type slis_filter_alv occurs 1.

* delete or add an entry in the select-option info
types: begin of slis_selentry_hide_alv,
         mode(1) type c,               "(D)elete (A)dd
         selname like rsparams-selname.
include type slis_seldis1_alv.
types  end of slis_selentry_hide_alv.
types: slis_t_selentry_hide_alv type slis_selentry_hide_alv occurs 1.

* delete or add an entry in the select-option info
types: begin of slis_sel_hide_alv,
         mode(1) type c,               "(R)eplace or (C)hange
         t_entries type slis_t_selentry_hide_alv,
       end of slis_sel_hide_alv.
* Header table for top of page
types: begin of slis_listheader,
         typ(1) type c,   " H = Header, S = Selection, A = Action
         key(20) type c,
         info type slis_entry,
       end of slis_listheader.
types: slis_t_listheader type slis_listheader occurs 1.
*--- Structure for specific color settings
types: begin of slis_specialcol_alv,
         fieldname type slis_fieldname,
         color     type slis_color,
         nokeycol(1) type c,
       end of slis_specialcol_alv.
types: slis_t_specialcol_alv type slis_specialcol_alv occurs 1.
*--- Structure for event handling
types: begin of slis_alv_event,
        name(30),
        form(30),
      end of slis_alv_event.
types: slis_t_event type slis_alv_event occurs 0.
*--- Structure for key information
types: begin of slis_keyinfo_alv,
         header01 type slis_fieldname,
         item01 type slis_fieldname,
         header02 type slis_fieldname,
         item02 type slis_fieldname,
         header03 type slis_fieldname,
         item03 type slis_fieldname,
         header04 type slis_fieldname,
         item04 type slis_fieldname,
         header05 type slis_fieldname,
         item05 type slis_fieldname,
       end of slis_keyinfo_alv.
*--- Structure for callback CALLER_EXIT and REUSE_ALV_POPUP_TO_SELECT
types: begin of slis_data_caller_exit,
        dummy like sy-repid,
        without_load_variant(1),
        callback_header_transport type slis_formname,
        columnopt(1),
      end of slis_data_caller_exit.

types: begin of slis_status,
         callback_program like sy-repid,
         callback_pf_status_set type slis_formname,
         callback_user_command  type slis_formname,
         counter_of_lists_added type i,
         actual_list_to_display type i,
         flg_to_be_refreshed,
         it_excluding type slis_t_extab,
         print type slis_print_alv,
         flg_checkboxes_active,
         flg_overview_active,
         flg_intcheck(1) type c,
       end of slis_status.
* Exporting structure
types: begin of slis_exit_by_user,
         back(1) type c,
         exit(1) type c,
         cancel(1) type c,
       end of slis_exit_by_user.

constants:
* Events
slis_ev_item_data_expand   type slis_formname value 'ITEM_DATA_EXPAND',
slis_ev_reprep_sel_modify  type slis_formname value 'REPREP_SEL_MODIFY',
slis_ev_caller_exit_at_start type slis_formname value 'CALLER_EXIT',
slis_ev_user_command       type slis_formname value 'USER_COMMAND',
slis_ev_top_of_page        type slis_formname value 'TOP_OF_PAGE',
slis_ev_data_changed       type slis_formname value 'DATA_CHANGED',
slis_ev_top_of_coverpage   type slis_formname value 'TOP_OF_COVERPAGE',
slis_ev_end_of_coverpage   type slis_formname value 'END_OF_COVERPAGE',
slis_ev_foreign_top_of_page type slis_formname
                                       value 'FOREIGN_TOP_OF_PAGE',
slis_ev_foreign_end_of_page type slis_formname
                                       value 'FOREIGN_END_OF_PAGE',
slis_ev_pf_status_set      type slis_formname value 'PF_STATUS_SET',
slis_ev_list_modify        type slis_formname value 'LIST_MODIFY',
slis_ev_top_of_list        type slis_formname value 'TOP_OF_LIST',
slis_ev_end_of_page        type slis_formname value 'END_OF_PAGE',
slis_ev_end_of_list        type slis_formname value 'END_OF_LIST',
slis_ev_after_line_output  type slis_formname value 'AFTER_LINE_OUTPUT',
slis_ev_before_line_output type slis_formname value
                                                   'BEFORE_LINE_OUTPUT',
slis_ev_subtotal_text      type slis_formname value 'SUBTOTAL_TEXT',
slis_ev_grouplevel_change  type slis_formname value 'GROUPLEVEL_CHANGE',
slis_ev_context_menu       type slis_formname value 'CONTEXT_MENU',

slis_ev_print_top_of_list  type slis_formname value 'PRINT_TOP_OF_LIST',
slis_ev_print_end_of_list  type slis_formname value 'PRINT_END_OF_LIST'.

*lowercase for DDIC_SCAN
types: slis_fieldinfo type fieldinfo.
types: begin of slis_fieldinfo2.
types: lowercase type c.
       include type slis_fieldinfo.
types: end of slis_fieldinfo2.
types: slis_t_fieldinfo2 type standard table of slis_fieldinfo2.

*--- INCLUDE: CL_ABAP_CHAR_UTILITIES========CU ---*
"! Some elementary utilities for processing of characters
class CL_ABAP_CHAR_UTILITIES definition
  public
  final
  create private .

*"* public components of class CL_ABAP_CHAR_UTILITIES
*"* do not include other source files here!!!
public section.

  types:
    TY_NUMBER_FORMAT type n length 4 .

  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the byte order in the container is little-endian.
  constants BYTE_ORDER_MARK_LITTLE type ABAP_BYTE_ORDER_MARK value 'FFFE' ##NO_TEXT.
  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the byte order in the container is big-endian.
  constants BYTE_ORDER_MARK_BIG type ABAP_BYTE_ORDER_MARK value 'FEFF' ##NO_TEXT.
  "! You can write this byte sequence into a type X or XSTRING container to indicate that
  "! the encoding in the container is UTF-8.
  constants BYTE_ORDER_MARK_UTF8 type ABAP_BYTE_ORDER_UTF8 value 'EFBBBF' ##NO_TEXT.
  "! CHARSIZE is the factor by which you have to multiply the declared length of a type C field
  "! to obtain the size of the field in bytes. In the current release, CHARSIZE is always 2.
  constants CHARSIZE type I value %_CHARSIZE ##NO_TEXT.
  "! The current byte order ('B' for big-endian or 'L' for little-endian, depending on the
  "! operating system of the application server).
  constants ENDIAN type ABAP_ENDIAN value %_ENDIAN ##NO_TEXT.
  "! MINCHAR and MAXCHAR can be used in binary comparisons, e.g., IF with the operators
  "! <, >, <=, >=, BETWEEN and the statement SORT without AS TEXT. Do not try to convert
  "! MINCHAR or MAXCHAR to upper case and do not use operations that implicitly convert to
  "! upper case, such as SEARCH, CS, NS, CP, or NP. Do not use MINCHAR and MAXCHAR in
  "! code page conversions. Some software components and UI technologies treat MINCHAR as
  "! the end of a text field.
  constants MINCHAR type ABAP_CHAR1 value %_MINCHAR ##NO_TEXT.
  "! See MINCHAR.
  constants MAXCHAR type ABAP_CHAR1 value %_MAXCHAR ##NO_TEXT.
  "! Tab character in the system character set. Most UI technologies do not display this character properly.
  constants HORIZONTAL_TAB type ABAP_CHAR1 value %_HORIZONTAL_TAB ##NO_TEXT.
  "! Vertical tab stop character in the system character set. Most UI technologies do not display this character properly.
  constants VERTICAL_TAB type ABAP_CHAR1 value %_VERTICAL_TAB ##NO_TEXT.
  "! This character serves as an end of line character in the system character set.
  "! Most UI technologies do not display this character properly.
  constants NEWLINE type ABAP_CHAR1 value %_NEWLINE ##NO_TEXT.
  "! This attribute contains a CR/LF pair (Carriage Return/Line Feed) in the system character set.
  "! Most UI technologies do not display this character properly.
  constants CR_LF type ABAP_CR_LF value %_CR_LF ##NO_TEXT.
  "! Form feed character in the system character set. Most UI technologies do not display this character properly.
  constants FORM_FEED type ABAP_CHAR1 value %_FORMFEED ##NO_TEXT.
  "! Backspace character in system character set. Most UI technologies do not display this character properly.
  constants BACKSPACE type ABAP_CHAR1 value %_BACKSPACE ##NO_TEXT.

  "! For given endian ('L' or 'B'), get the number format.
  class-methods ENDIAN_TO_NUMBER_FORMAT
    importing
      !ENDIAN type ABAP_ENDIAN
    returning
      value(NUMBER_FORMAT) type TY_NUMBER_FORMAT .

  "! For given number format, get the endian ('L' or 'B').
  class-methods NUMBER_FORMAT_TO_ENDIAN
    importing
      !NUMBER_FORMAT type TY_NUMBER_FORMAT
    returning
      value(ENDIAN) type ABAP_ENDIAN .

  "! Returns a string that contains the white-space characters most commonly used.
  "! (Some less commonly used space characters are not returned by this method.)
  class-methods GET_SIMPLE_SPACES_FOR_CUR_CP
    returning
      value(S_STR) type STRING .

  "! Returns ABAP_TRUE if the parameter VAL starts with the second half of a UTF-16 surrogate pair,
  "! i.e., with a 16-bit unit in the range DC00 .. DFFF (hexadecimal).
  "! Note: The built-in function charlen returns 2 if its parameter starts with a complete UTF-16 surrogate pair.
  "! (A UTF-16 surrogate pair consists of two 16-bit units, i.e. 4 bytes, that form one UTF-16 character.
  "! Most characters need only 2 bytes.)
  class-methods STARTS_WITH_BROKEN_SURROGATE
    importing
      !VAL type CSEQUENCE
    returning
      value(RET) type ABAP_BOOL .

  "! Returns ABAP_TRUE if the parameter VAL ends with the first half of a UTF-16 surrogate pair,
  "! i.e., with a 16-bit unit in the range D800 .. DBFF (hexadecimal).
  class-methods ENDS_WITH_BROKEN_SURROGATE
    importing
      !VAL type CSEQUENCE
    returning
      value(RET) type ABAP_BOOL .

*--- INCLUDE: CL_COMMUNICATION_TARGET_ROOT==CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_COMMUNICATION_TARGET_ROOT and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: CL_HTTP_CLIENT================CU ---*
class CL_HTTP_CLIENT definition
  public
  create private

  global friends CL_APC_WSP_CLIENT
                 CL_APC_WS_CLIENT
                 CL_HTTP_REQUEST
                 CL_HTTP_RESPONSE
                 CL_WEB_HTTP_RESPONSE
                 CL_ICM_CONNECTION_TEST
                 CL_ICM_TESTING .

public section.
*"* public components of class CL_HTTP_CLIENT
*"* do not include other source files here!!!
  type-pools ABAP .

  interfaces IF_HTTP_CLIENT .

  aliases REQUEST
    for IF_HTTP_CLIENT~REQUEST .
  aliases RESPONSE
    for IF_HTTP_CLIENT~RESPONSE .
  aliases CREATE_ABS_URL
    for IF_HTTP_CLIENT~CREATE_ABS_URL .
  aliases CREATE_REL_URL
    for IF_HTTP_CLIENT~CREATE_REL_URL .
  aliases ESCAPE_URL
    for IF_HTTP_CLIENT~ESCAPE_URL .

  constants SCHEMETYPE_HTTPS type I value 2 ##NO_TEXT.
  constants SCHEMETYPE_HTTP type I value 1 ##NO_TEXT.
  constants CO_REDIRECT_TRIAL type I value 5 ##NO_TEXT.
  constants CO_AUTHENTICATE_TRIAL type I value 3 ##NO_TEXT.
  class-data C_COMPRESSION_SUPPORTED type I read-only .
  constants HTTP_NO_OPEN_CONNECTION_ERROR type SYSUBRC value 1002 ##NO_TEXT.
  constants HTTP_PROCESSING_FAILED_ERROR type SYSUBRC value 1003 ##NO_TEXT.
  constants HTTP_INVALID_STATE_ERROR type SYSUBRC value 1001 ##NO_TEXT.
  data M_PATH_PREFIX type STRING read-only .
  data M_USE_SCC type SAP_BOOL read-only value ABAP_FALSE ##NO_TEXT.
  class-data M_CONNECTION type SYSUUID_C read-only .
  data M_COUNTER type I read-only .

  class-methods GET_CLIENT_KERNEL_VERSION
    returning
      value(VERSION) type I .
  class-methods CLASS_CONSTRUCTOR .
  class-methods _APPEND_XSTRING_TO_STRING
    importing
      !SOURCE type XSTRING
    changing
      !DEST type STRING .
  class-methods _APPEND_STRING_TO_XSTRING
    importing
      !SOURCE type STRING
    changing
      !DEST type XSTRING .
  methods CONSTRUCTOR
    exceptions
      CREATE_MESSAGE_FAILED .
  class-methods CREATE_BY_CLOUD_DESTINATION
    importing
      !I_NAME type CHAR38
      !I_COMM_ARR_UUID type UUID optional
      !I_SERVICE_INSTANCE_NAME type SVC_INSTANCE_NAME optional
    returning
      value(CLIENT) type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      DESTINATION_NOT_FOUND
      DESTINATION_NO_AUTHORITY
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  class-methods CREATE_BY_DESTINATION
    importing
      !DESTINATION type C
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      DESTINATION_NOT_FOUND
      DESTINATION_NO_AUTHORITY
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_SECSTORE_ADM .
  class-methods CREATE_INTERNAL
    importing
      !VIRTUAL_HOST type I default IHTTP_VHOST_DEFAULT
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  class-methods CREATE_BY_URL
    importing
      !URL type STRING
      !PROXY_HOST type STRING optional
      !PROXY_SERVICE type STRING optional
      !SSL_ID type SSFAPPLSSL optional
      !SAP_USERNAME type SYUNAME optional
      !SAP_CLIENT type SYMANDT optional
      !PROXY_USER type STRING optional
      !PROXY_PASSWD type STRING optional
      !DO_NOT_USE_CLIENT_CERT type ABAP_BOOL default ABAP_FALSE
      !USE_SCC type ABAP_BOOL default ABAP_FALSE
      !SCC_LOCATION_ID type STRING optional
      !OAUTH_PROFILE type OA2C_PROFILE optional
      !OAUTH_CONFIG type OA2C_CONFIGURATION optional
      !SSL_HOSTNAME type STRING optional
      !SSL_CIPHER_SUITES type STRING optional
      !SSL_SNI_DISABLED type ABAP_BOOL default ABAP_FALSE
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR
      PSE_NOT_FOUND
      PSE_NOT_DISTRIB
      PSE_ERRORS
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT .
  class-methods CREATE
    importing
      !HOST type STRING
      value(SERVICE) type STRING optional
      !PROXY_HOST type STRING optional
      !PROXY_SERVICE type STRING optional
      !SCHEME type I default SCHEMETYPE_HTTP
      !SSL_ID type SSFAPPLSSL optional
      !SAP_USERNAME type SYUNAME optional
      !SAP_CLIENT type SYMANDT optional
      !DO_NOT_USE_CLIENT_CERT type ABAP_BOOL default ABAP_FALSE
      !SSL_HOSTNAME type STRING optional
      !SSL_CIPHER_SUITES type STRING optional
      !SSL_SNI_DISABLED type ABAP_BOOL default ABAP_FALSE
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      ARGUMENT_NOT_FOUND
      PLUGIN_NOT_ACTIVE
      INTERNAL_ERROR .
  methods DESTRUCTOR .
  class-methods GET_LAST_ERROR
    exporting
      !CODE type SYSUBRC
      !MESSAGE type STRING .
  methods SEND_AND_CLOSE
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED
      HTTP_IS_NOT_SUPPORTED .
  class-methods SET_OAUTH_TOKEN
    importing
      !I_OAUTH_PROFILE type OA2C_PROFILE
      !I_OAUTH_CONFIG type OA2C_CONFIGURATION optional
      !IO_HTTP_CLIENT type ref to IF_HTTP_CLIENT
      !I_PARAM_KIND type STRING optional
      !I_FORCE_OAUTH2_REQUEST type ABAP_BOOL default ABAP_FALSE
    exceptions
      OA2C_SET_TOKEN_ERROR
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_CONFIG
      OA2C_INVALID_PARAMETERS
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_SECSTORE_ADM .
  methods SET_OAUTH2C_INFO
    importing
      !IO_OA2C_CLIENT type ref to CL_OA2C_CLIENT
    returning
      value(R_RETURNCODE) type I .
  methods SET_OAUTH2C_INFO_EXT
    importing
      !IO_OA2C_CLIENT type ref to CL_OA2C_CLIENT
    returning
      value(R_RETURNCODE) type I .
  class-methods CREATE_BY_COM_TARGET
    importing
      !COMMUNICATION_TARGET type ref to CL_COMMUNICATION_TARGET_ROOT
    exporting
      !CLIENT type ref to IF_HTTP_CLIENT
    exceptions
      INTERNAL_ERROR
      COM_TAR_NOT_FOUND
      COM_TAR_INVALID
      COM_TAR_READ_ERROR
      APPL_DEST_NOT_FOUND
      APPL_DEST_INACTIVE
      APPL_DEST_INVALID
      NO_DEFAULT_APPL_DEST_EXISTS
      DESTINATION_READ_ERROR
      INVALID_PROXY_PORT
      READING_SCCPROXY_FAILED
      PLUGIN_NOT_ACTIVE
      INVALID_PORT
      ERROR_CREATING_TICKET
      NO_AUTHORITY_FOR_SSLID_SPKI
      PSEFILE_NOT_FOUND
      OA2C_INVALID_CONFIG
      OA2C_MISSING_AUTHORIZATION
      OA2C_INVALID_SCOPE
      OA2C_INVALID_GRANT
      OA2C_INVALID_PARAMETERS
      OA2C_SET_TOKEN_ERROR
      OA2C_SECSTORE_ADM .

*--- INCLUDE: CL_OA2C_CLIENT================CT ---*
*"* dummy include to reduce generation dependencies between
*"* class CL_OA2C_CLIENT and it's users.
*"* touched if any type reference has been changed

*--- INCLUDE: DB__SSEL ---*
* INCLUDE DB__SSEL

*--- INCLUDE: IF_HTTP_CLIENT================IU ---*
*"* components of interface IF_HTTP_CLIENT
interface IF_HTTP_CLIENT
  public .


  constants VERSION type STRING value '1.0' ##NO_TEXT.
  data REQUEST type ref to IF_HTTP_REQUEST .
  data RESPONSE type ref to IF_HTTP_RESPONSE .
  data PROPERTYTYPE_LOGON_POPUP type I .
  constants CO_DISABLED type I value 0 ##NO_TEXT.
  constants CO_EVENT type I value 3 ##NO_TEXT.
  constants CO_PROMPT type I value 2 ##NO_TEXT.
  constants CO_ENABLED type I value 1 ##NO_TEXT.
  data PROPERTYTYPE_REDIRECT type I .
  data PROPERTYTYPE_APPLY_SPROXY type I .
  data PROPERTYTYPE_ACCEPT_COOKIE type I .
  data PROPERTYTYPE_SEND_W3C_TRACE type I .
  data PROPERTYTYPE_SEND_SAP_PASSPORT type I .
  constants CO_TIMEOUT_DEFAULT type I value 0 ##NO_TEXT.
  constants CO_TIMEOUT_INFINITE type I value -1 ##NO_TEXT.
  constants CO_COMPRESS_BASED_ON_MIME_TYPE type I value 2 ##NO_TEXT.
  constants CO_COMPRESS_IN_ALL_CASES type I value 1 ##NO_TEXT.
  constants CO_COMPRESS_NONE type I value 0 ##NO_TEXT.
  data PROPERTYTYPE_ACCEPT_COMPRESS type I .
  data PATH_PREFIX type STRING read-only .
  data OAUTH_LAST_ERR_TXT type STRING .

  events EVENTKIND_HANDLE_COOKIE
    exporting
      value(CLIENT) type ref to IF_HTTP_CLIENT optional
      value(COOKIES) type TIHTTPCKI optional .

  class-methods ESCAPE_HTML
    importing
      !UNESCAPED type STRING
    returning
      value(ESCAPED) type STRING .
  class-methods ESCAPE_URL
    importing
      !UNESCAPED type STRING
    returning
      value(ESCAPED) type STRING .
  class-methods UNESCAPE_URL
    importing
      !ESCAPED type STRING
    returning
      value(UNESCAPED) type STRING .
  class-methods LISTEN
    returning
      value(CLIENT) type ref to IF_HTTP_CLIENT
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_NO_OPEN_CONNECTION .
  methods AUTHENTICATE
    importing
      !PROXY_AUTHENTICATION type C default ' '
      !CLIENT type SYMANDT optional
      !USERNAME type STRING
      !PASSWORD type ICF_PASSWORD
      !LANGUAGE type SYLANGU optional .
  methods APPEND_FIELD_URL
    importing
      !NAME type STRING
      !VALUE type STRING
    changing
      !URL type STRING .
  methods CREATE_ABS_URL
    importing
      !PROTOCOL type STRING default ''
      !HOST type STRING default ''
      !PORT type STRING default ''
      !PATH type STRING default ''
      !QUERYSTRING type STRING default ''
      !STATEFUL type I default -1
    returning
      value(URL) type STRING .
  methods CREATE_REL_URL
    importing
      !PATH type STRING default ''
      !QUERYSTRING type STRING default ''
      !STATEFUL type I default -1
    returning
      value(URL) type STRING .
  methods CLOSE
    exceptions
      HTTP_INVALID_STATE .
  methods RECEIVE
    exporting
      !SSE_ENABLED type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods RECEIVE_SSE_MSG default fail
    exporting
      !SSE_MSG type STRING
      !FINAL_MSG type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods RECEIVE_SSE_BATCH default fail
    exporting
      !SSE_BATCH type STRING_TABLE
      !FINAL_BATCH type ABAP_BOOL
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED .
  methods GET_LAST_ERROR
    exporting
      !CODE type SYSUBRC
      !MESSAGE type STRING
      !MESSAGE_CLASS type ARBGB
      !MESSAGE_NUMBER type MSGNR .
  methods SEND
    importing
      !REQUEST_SSE type ABAP_BOOL default ABAP_FALSE
      !TIMEOUT type I default CO_TIMEOUT_DEFAULT
    preferred parameter TIMEOUT
    exceptions
      HTTP_COMMUNICATION_FAILURE
      HTTP_INVALID_STATE
      HTTP_PROCESSING_FAILED
      HTTP_INVALID_TIMEOUT .
  methods REFRESH_COOKIE
    exceptions
      HTTP_ACTION_FAILED
      HTTP_PROCESSING_FAILED .
  methods REFRESH_REQUEST
    exceptions
      HTTP_ACTION_FAILED .
  methods REFRESH_RESPONSE
    exceptions
      HTTP_ACTION_FAILED .
  methods SET_COMPRESSION
    importing
      !OPTIONS type I default CO_COMPRESS_BASED_ON_MIME_TYPE
    exceptions
      COMPRESSION_NOT_POSSIBLE .
  methods SEND_SAP_LOGON_TICKET .
  methods SEND_SAP_ASSERTION_TICKET
    importing
      !CLIENT type SYMANDT
      !SYSTEM_ID type SYSYSID
    exceptions
      ARGUMENT_NOT_FOUND .
  methods IS_SCC_IN_USE default ignore
    returning
      value(IS_SCC_IN_USE) type ABAP_BOOLEAN .
  methods ENABLE_PATH_PREFIX .
endinterface.

*--- INCLUDE: IF_HTTP_ENTITY================IU ---*
*"* components of interface IF_HTTP_ENTITY
interface IF_HTTP_ENTITY
  public .


  constants CO_ENCODING_RAW type I value 0 ##NO_TEXT.
  constants CO_ENCODING_URL type I value 1 ##NO_TEXT.
  constants CO_ENCODING_HTML type I value 2 ##NO_TEXT.
  constants CO_ENCODING_WML type I value 3 ##NO_TEXT.
  constants CO_COMPRESS_NONE type I value 0 ##NO_TEXT.
  constants CO_COMPRESS_BASED_ON_MIME_TYPE type I value 2 ##NO_TEXT.
  constants CO_COMPRESS_IN_ALL_CASES type I value 1 ##NO_TEXT.
  constants CO_COMPRESS_DISABLED type I value 4 ##NO_TEXT.
  constants CO_PROTOCOL_VERSION_1_0 type I value 1000 ##NO_TEXT.
  constants CO_PROTOCOL_VERSION_1_1 type I value 1001 ##NO_TEXT.
  constants CO_REQUEST_METHOD_GET type STRING value 'GET' ##NO_TEXT.
  constants CO_REQUEST_METHOD_POST type STRING value 'POST' ##NO_TEXT.
  constants CO_COOKIE_ENCODING_RAW type I value 1 ##NO_TEXT.
  constants CO_COOKIE_ENCODING_URL_ENCODED type I value 0 ##NO_TEXT.
  constants CO_FORMFIELD_ENCODING_RAW type I value 1 ##NO_TEXT.
  constants CO_FORMFIELD_ENCODING_ENCODED type I value 2 ##NO_TEXT.
  constants CO_QUERY_STRING type I value 0 ##NO_TEXT.
  constants CO_BODY type I value 1 ##NO_TEXT.
  constants CO_QUERY_STRING_BEFORE_BODY type I value 2 ##NO_TEXT.
  constants CO_BODY_BEFORE_QUERY_STRING type I value 3 ##NO_TEXT.
  constants CO_CONTENT_CHECK_ALWAYS type HTTP_CONTENT_CHECK value 'A' ##NO_TEXT.
  constants CO_CONTENT_CHECK_NEVER type HTTP_CONTENT_CHECK value 'N' ##NO_TEXT.
  constants CO_CONTENT_CHECK_PROFILE type HTTP_CONTENT_CHECK value ' ' ##NO_TEXT.
  data FORMFIELD_ENCODING type I read-only .
  constants CO_DETAIL_INFO_LOGON_REQUIRED type STRING value 'ICFLOGONREQUIRED' ##NO_TEXT.
  constants CO_DETAIL_INFO_HOST_NOT_FOUND type STRING value 'ICFVIRTUALHOSTNOTFOUND' ##NO_TEXT.
  constants CO_DETAIL_INFO_TENANT_MAINT type STRING value 'ICMERUNLEVELINTERNAL' ##NO_TEXT.

  methods ADD_COOKIE_FIELD
    importing
      !COOKIE_NAME type STRING
      !COOKIE_PATH type STRING optional
      !FIELD_NAME type STRING
      !FIELD_VALUE type STRING
      !BASE64 type I default 1 .
  methods ADD_MULTIPART
    importing
      !SUPPRESS_CONTENT_LENGTH type ABAP_BOOL default ABAP_FALSE
    returning
      value(ENTITY) type ref to IF_HTTP_ENTITY .
  methods APPEND_CDATA
    importing
      !DATA type STRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods APPEND_CDATA2
    importing
      !DATA type STRING
      !ENCODING type I default CO_ENCODING_RAW
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods APPEND_DATA
    importing
      !DATA type XSTRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods DELETE_COOKIE_SECURE
    importing
      !NAME type STRING
      !PATH type STRING default `` .
  methods DELETE_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default `` .
  methods DELETE_FORM_FIELD_SECURE
    importing
      !NAME type STRING .
  methods DELETE_FORM_FIELD
    importing
      !NAME type STRING .
  methods DELETE_HEADER_FIELD_SECURE
    importing
      !NAME type STRING .
  methods DELETE_HEADER_FIELD
    importing
      !NAME type STRING .
  methods FROM_XSTRING
    importing
      !DATA type XSTRING .
  methods GET_CDATA
    returning
      value(DATA) type STRING .
  methods GET_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default ``
      !COOKIE_ENCODING type I default 0
    exporting
      !VALUE type STRING
      !DOMAIN type STRING
      !EXPIRES type STRING
      !SECURE type I .
  methods GET_COOKIES
    importing
      !COOKIE_ENCODING type I default 0
    changing
      !COOKIES type TIHTTPCKI .
  methods GET_COOKIE_FIELD
    importing
      !COOKIE_NAME type STRING
      !COOKIE_PATH type STRING optional
      !FIELD_NAME type STRING
      !BASE64 type I default 1
    returning
      value(FIELD_VALUE) type STRING .
  methods GET_DATA
    importing
      !OFFSET type I default 0
      !LENGTH type I default -1
      value(VIRUS_SCAN_PROFILE) type VSCAN_PROFILE default '/SIHTTP/HTTP_UPLOAD'
      !VSCAN_SCAN_ALWAYS type HTTP_CONTENT_CHECK default IF_HTTP_ENTITY=>CO_CONTENT_CHECK_PROFILE
    returning
      value(DATA) type XSTRING .
  methods GET_FORM_FIELD_CS
    importing
      !NAME type STRING
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    returning
      value(VALUE) type STRING .
  methods GET_FORM_FIELD
    importing
      !NAME type STRING
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    returning
      value(VALUE) type STRING .
  methods GET_FORM_FIELDS_CS
    importing
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_FORM_FIELDS
    importing
      !FORMFIELD_ENCODING type I default 0
      !SEARCH_OPTION type I default 3
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_HEADER_FIELD
    importing
      !NAME type STRING
    returning
      value(VALUE) type STRING .
  methods GET_HEADER_FIELDS
    changing
      !FIELDS type TIHTTPNVP .
  methods GET_LAST_ERROR
    returning
      value(RC) type I .
  methods GET_MULTIPART
    importing
      !INDEX type I
    returning
      value(ENTITY) type ref to IF_HTTP_ENTITY .
  methods NUM_MULTIPARTS
    returning
      value(NUM) type I .
  methods SET_CDATA
    importing
      !DATA type STRING
      !OFFSET type I default 0
      !LENGTH type I default -1 .
  methods SET_COOKIE
    importing
      !NAME type STRING
      !PATH type STRING default ``
      !VALUE type STRING
      !DOMAIN type STRING default ``
      !EXPIRES type STRING default ``
      !SECURE type I default 0
      !COOKIE_ENCODING type I default 0 .
  methods SET_DATA
    importing
      !DATA type XSTRING
      !OFFSET type I default 0
      !LENGTH type I default -1
      !VSCAN_SCAN_ALWAYS type HTTP_CONTENT_CHECK default IF_HTTP_ENTITY=>CO_CONTENT_CHECK_PROFILE
      value(VIRUS_SCAN_PROFILE) type VSCAN_PROFILE default '/SIHTTP/HTTP_DOWNLOAD' .
  methods SET_FORM_FIELD
    importing
      !NAME type STRING
      !VALUE type STRING .
  methods SET_FORM_FIELDS
    importing
      !FIELDS type TIHTTPNVP
      !MULTIVALUE type INT4 default 0 .
  methods SET_HEADER_FIELD
    importing
      !NAME type STRING
      !VALUE type STRING .
  methods SET_HEADER_FIELDS
    importing
      !FIELDS type TIHTTPNVP .
  methods TO_XSTRING
    returning
      value(DATA) type XSTRING .
  methods SET_COMPRESSION
    importing
      !DISABLE_EXTENDED_CHECKS type ABAP_BOOL default ABAP_FALSE
      !OPTIONS type I default CO_COMPRESS_BASED_ON_MIME_TYPE
    preferred parameter OPTIONS .
  methods SET_CONTENT_TYPE
    importing
      !CONTENT_TYPE type STRING .
  methods GET_CONTENT_TYPE
    returning
      value(CONTENT_TYPE) type STRING .
  methods GET_VERSION
    returning
      value(VERSION) type I .
  methods GET_SERIALIZED_MESSAGE_LENGTH
    exporting
      value(BODY_LENGTH) type I
      value(HEADER_LENGTH) type I .
  methods SET_FORMFIELD_ENCODING
    importing
      !FORMFIELD_ENCODING type I .
  methods SUPPRESS_CONTENT_TYPE
    importing
      !SUPPRESS type ABAP_BOOL default ABAP_TRUE .
  methods SUPPRESS_CHARSET default fail
    importing
      !SUPPRESS type ABAP_BOOL default ABAP_TRUE .
  methods GET_DATA_LENGTH
    exporting
      value(DATA_LENGTH) type I .
  methods PRESERVE_MULTIPART_BOUNDARY default fail
    importing
      !PRESERVE type ABAP_BOOL default ABAP_TRUE .
endinterface.

*--- INCLUDE: IF_HTTP_REQUEST===============IT ---*

*--- INCLUDE: IF_HTTP_RESPONSE==============IU ---*
*"* components of interface IF_HTTP_RESPONSE
interface IF_HTTP_RESPONSE
  public .


  interfaces IF_HTTP_ENTITY .

  aliases CO_COMPRESS_BASED_ON_MIME_TYPE
    for IF_HTTP_ENTITY~CO_COMPRESS_BASED_ON_MIME_TYPE .
  aliases CO_COMPRESS_DISABLED
    for IF_HTTP_ENTITY~CO_COMPRESS_DISABLED .
  aliases CO_COMPRESS_IN_ALL_CASES
    for IF_HTTP_ENTITY~CO_COMPRESS_IN_ALL_CASES .
  aliases CO_COMPRESS_NONE
    for IF_HTTP_ENTITY~CO_COMPRESS_NONE .
  aliases CO_ENCODING_HTML
    for IF_HTTP_ENTITY~CO_ENCODING_HTML .
  aliases CO_ENCODING_RAW
    for IF_HTTP_ENTITY~CO_ENCODING_RAW .
  aliases CO_ENCODING_URL
    for IF_HTTP_ENTITY~CO_ENCODING_URL .
  aliases CO_ENCODING_WML
    for IF_HTTP_ENTITY~CO_ENCODING_WML .
  aliases CO_FORMFIELD_ENCODING_ENCODED
    for IF_HTTP_ENTITY~CO_FORMFIELD_ENCODING_ENCODED .
  aliases CO_FORMFIELD_ENCODING_RAW
    for IF_HTTP_ENTITY~CO_FORMFIELD_ENCODING_RAW .
  aliases CO_PROTOCOL_VERSION_1_0
    for IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_0 .
  aliases CO_PROTOCOL_VERSION_1_1
    for IF_HTTP_ENTITY~CO_PROTOCOL_VERSION_1_1 .
  aliases CO_REQUEST_METHOD_GET
    for IF_HTTP_ENTITY~CO_REQUEST_METHOD_GET .
  aliases CO_REQUEST_METHOD_POST
    for IF_HTTP_ENTITY~CO_REQUEST_METHOD_POST .
  aliases FORMFIELD_ENCODING
    for IF_HTTP_ENTITY~FORMFIELD_ENCODING .
  aliases ADD_COOKIE_FIELD
    for IF_HTTP_ENTITY~ADD_COOKIE_FIELD .
  aliases ADD_MULTIPART
    for IF_HTTP_ENTITY~ADD_MULTIPART .
  aliases APPEND_CDATA
    for IF_HTTP_ENTITY~APPEND_CDATA .
  aliases APPEND_CDATA2
    for IF_HTTP_ENTITY~APPEND_CDATA2 .
  aliases APPEND_DATA
    for IF_HTTP_ENTITY~APPEND_DATA .
  aliases DELETE_COOKIE
    for IF_HTTP_ENTITY~DELETE_COOKIE .
  aliases DELETE_COOKIE_SECURE
    for IF_HTTP_ENTITY~DELETE_COOKIE_SECURE .
  aliases DELETE_FORM_FIELD
    for IF_HTTP_ENTITY~DELETE_FORM_FIELD .
  aliases DELETE_FORM_FIELD_SECURE
    for IF_HTTP_ENTITY~DELETE_FORM_FIELD_SECURE .
  aliases DELETE_HEADER_FIELD
    for IF_HTTP_ENTITY~DELETE_HEADER_FIELD .
  aliases DELETE_HEADER_FIELD_SECURE
    for IF_HTTP_ENTITY~DELETE_HEADER_FIELD_SECURE .
  aliases FROM_XSTRING
    for IF_HTTP_ENTITY~FROM_XSTRING .
  aliases GET_CDATA
    for IF_HTTP_ENTITY~GET_CDATA .
  aliases GET_CONTENT_TYPE
    for IF_HTTP_ENTITY~GET_CONTENT_TYPE .
  aliases GET_COOKIE
    for IF_HTTP_ENTITY~GET_COOKIE .
  aliases GET_COOKIES
    for IF_HTTP_ENTITY~GET_COOKIES .
  aliases GET_COOKIE_FIELD
    for IF_HTTP_ENTITY~GET_COOKIE_FIELD .
  aliases GET_DATA
    for IF_HTTP_ENTITY~GET_DATA .
  aliases GET_FORM_FIELD
    for IF_HTTP_ENTITY~GET_FORM_FIELD .
  aliases GET_FORM_FIELDS
    for IF_HTTP_ENTITY~GET_FORM_FIELDS .
  aliases GET_FORM_FIELDS_CS
    for IF_HTTP_ENTITY~GET_FORM_FIELDS_CS .
  aliases GET_FORM_FIELD_CS
    for IF_HTTP_ENTITY~GET_FORM_FIELD_CS .
  aliases GET_HEADER_FIELD
    for IF_HTTP_ENTITY~GET_HEADER_FIELD .
  aliases GET_HEADER_FIELDS
    for IF_HTTP_ENTITY~GET_HEADER_FIELDS .
  aliases GET_LAST_ERROR
    for IF_HTTP_ENTITY~GET_LAST_ERROR .
  aliases GET_MULTIPART
    for IF_HTTP_ENTITY~GET_MULTIPART .
  aliases GET_SERIALIZED_MESSAGE_LENGTH
    for IF_HTTP_ENTITY~GET_SERIALIZED_MESSAGE_LENGTH .
  aliases GET_VERSION
    for IF_HTTP_ENTITY~GET_VERSION .
  aliases NUM_MULTIPARTS
    for IF_HTTP_ENTITY~NUM_MULTIPARTS .
  aliases SET_CDATA
    for IF_HTTP_ENTITY~SET_CDATA .
  aliases SET_COMPRESSION
    for IF_HTTP_ENTITY~SET_COMPRESSION .
  aliases SET_CONTENT_TYPE
    for IF_HTTP_ENTITY~SET_CONTENT_TYPE .
  aliases SET_COOKIE
    for IF_HTTP_ENTITY~SET_COOKIE .
  aliases SET_DATA
    for IF_HTTP_ENTITY~SET_DATA .
  aliases SET_FORMFIELD_ENCODING
    for IF_HTTP_ENTITY~SET_FORMFIELD_ENCODING .
  aliases SET_FORM_FIELD
    for IF_HTTP_ENTITY~SET_FORM_FIELD .
  aliases SET_FORM_FIELDS
    for IF_HTTP_ENTITY~SET_FORM_FIELDS .
  aliases SET_HEADER_FIELD
    for IF_HTTP_ENTITY~SET_HEADER_FIELD .
  aliases SET_HEADER_FIELDS
    for IF_HTTP_ENTITY~SET_HEADER_FIELDS .
  aliases SUPPRESS_CHARSET
    for IF_HTTP_ENTITY~SUPPRESS_CHARSET .
  aliases SUPPRESS_CONTENT_TYPE
    for IF_HTTP_ENTITY~SUPPRESS_CONTENT_TYPE .
  aliases TO_XSTRING
    for IF_HTTP_ENTITY~TO_XSTRING .

  methods DELETE_COOKIE_AT_CLIENT
    importing
      !NAME type STRING
      !PATH type STRING default ''
      !DOMAIN type STRING default '' .
  methods GET_STATUS
    exporting
      !CODE type I
      !REASON type STRING .
  methods REDIRECT
    importing
      !URL type STRING
      !PERMANENTLY type I default 0
      !EXPLANATION type STRING default ''
      !PROTOCOL_DEPENDENT type I default 0 .
  methods SERVER_CACHE_EXPIRE_ABS
    importing
      !EXPIRES_ABS_DATE type D optional
      !EXPIRES_ABS_TIME type T optional
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SERVER_CACHE_EXPIRE_DEFAULT
    importing
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SERVER_CACHE_EXPIRE_REL
    importing
      !EXPIRES_REL type I
      !ETAG type CHAR32 optional
      !BROWSER_DEPENDENT type BOOLEAN default ' '
      !NO_UFO_CACHE type BOOLEAN default ' ' .
  methods SET_STATUS
    importing
      !CODE type I
      !REASON type STRING
      !DETAILED_INFO type STRING optional .
  methods SERVER_CACHE_BROWSER_DEPENDENT
    importing
      !DEPENDENT type BOOLEAN default 'X' .
  methods GET_RAW_MESSAGE
    returning
      value(DATA) type XSTRING .
  methods COPY
    returning
      value(RESPONSE) type ref to IF_HTTP_RESPONSE .
endinterface.
