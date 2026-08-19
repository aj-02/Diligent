*--- MAIN PROGRAM: MZMMMATEXTNF01 ---*
*----------------------------------------------------------------------*
*   INCLUDE ZMMMATEXTF001                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  check_fields  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_fields INPUT.
  DATA : g_ans(1).
  IF ok_code = 'BACK' OR ok_code = 'EXIT'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
              titlebar              = text-a01
              text_question         = text-a02
              text_button_1         = 'Yes'
              text_button_2         = 'No'
              display_cancel_button = ' '
              start_column          = 20
              start_row             = 15
         IMPORTING
              answer                = g_ans.

    IF g_ans = '1'.
      CLEAR g_ans.
      LEAVE PROGRAM.
    ELSE.
      CLEAR : ok_code,save_ok.
      SET SCREEN sy-dynnr.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_fields  INPUT
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_data.
  DATA: l_fnm LIKE rlgrap-filename.
  CALL FUNCTION 'F4_FILENAME'
       IMPORTING
            file_name = p_file.


  l_fnm = p_file.

  IF l_fnm IS INITIAL.
    MESSAGE e733(zmm).
  ENDIF.

  CALL FUNCTION 'WS_UPLOAD'
       EXPORTING
            filename                = l_fnm
            filetype                = 'DAT'
       TABLES
            data_tab                = ist_matr
       EXCEPTIONS
            conversion_error        = 1
            file_open_error         = 2
            file_read_error         = 3
            invalid_type            = 4
            no_batch                = 5
            unknown_error           = 6
            invalid_table_width     = 7
            gui_refuse_filetransfer = 8
            customer_error          = 9
            OTHERS                  = 10.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT ist_matr.
      MOVE-CORRESPONDING ist_matr TO g_tabctrl_wa.
      APPEND g_tabctrl_wa TO g_tabctrl_itab.
    ENDLOOP.
  ENDIF.
  IF save_ok101 = 'CHAN' .
    IF zmm_matextension-req_cpf <> sy-uname.
      MESSAGE e726(zmm).
    ENDIF.
  ENDIF.


ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_matnr.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

    l_sytabix = sy-tabix.

    SELECT SINGLE * FROM mara WHERE matnr = g_tabctrl_wa-matnr
                                AND mstae EQ space
                                AND lvorm NE 'X'.
    IF sy-subrc <> 0.
      wa_message-srno = g_tabctrl_wa-srno.
      wa_message-msgtype1 = 'A'.
      wa_message-msgtext1 = 'Invalid Matcode'.
      APPEND wa_message TO ist_message.
    ELSE.
      CLEAR wa_message-msgtext1 .
      CLEAR wa_message-msgtype1.
    ENDIF.
    g_tabctrl_wa-msgtext1  = wa_message-msgtext1.
    g_tabctrl_wa-msgtype1  = wa_message-msgtype1.

    MODIFY g_tabctrl_itab FROM g_tabctrl_wa
    INDEX L_SYTABIX
    TRANSPORTING msgtext1 msgtype1.

    CLEAR wa_message-msgtext1 .
    CLEAR wa_message-msgtype1.

  ENDLOOP.

  CLEAR g_tabctrl_wa.
  CLEAR wa_message-msgtext1 .
  CLEAR wa_message-msgtype1.

ENDFORM.                    " CHECK_MATNR
*&---------------------------------------------------------------------*
*&      Form  CHECK_MRPCNTRL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*
FORM check_mrpcntrl.
  DATA : l_mrp TYPE agr_users-uname.
  DATA : l_uname TYPE agr_users-uname,
         l_agr_name TYPE agr_users-agr_name.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

    l_sytabix = sy-tabix..
    CLEAR l_mrp.
    CLEAR l_agr_name.
    CLEAR l_uname.

    l_uname = g_tabctrl_wa-mrpctrl.
    l_agr_name = 'D:MM_MAT_IND_APPROVE_02'.

   SELECT SINGLE uname agr_name INTO (l_mrp,l_agr_name)  FROM agr_users
                                  WHERE uname =  l_uname
                                  AND agr_name = l_agr_name.

    IF sy-subrc <> 0.
      wa_message-srno = g_tabctrl_wa-srno.
      wa_message-msgtype2 = 'B'.
      wa_message-msgtext2 = 'Invalid MRP Controller'.
    ELSE.
      CLEAR wa_message-msgtext2.
      CLEAR wa_message-msgtype2.
    ENDIF.

    g_tabctrl_wa-msgtext2 = wa_message-msgtext2.
    g_tabctrl_wa-msgtype2 = wa_message-msgtype2.

    MODIFY g_tabctrl_itab FROM g_tabctrl_wa
    INDEX L_SYTABIX
    TRANSPORTING msgtext2 msgtype2.

    CLEAR wa_message-msgtext2.
    CLEAR wa_message-msgtype2.

  ENDLOOP.

  CLEAR g_tabctrl_wa.
  CLEAR wa_message-msgtext2.
  CLEAR wa_message-msgtype2.
ENDFORM.                    " CHECK_MRPCNTRL
*&---------------------------------------------------------------------*
*&      Form  DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete.


  DELETE g_tabctrl_itab WHERE mark = 'X'.


ENDFORM.                    " DELETE
*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_fields.
  PERFORM check_mrpcntrl.
  PERFORM check_matnr.
  PERFORM check_extn.
  PERFORM val_type.
  PERFORM check_plant.
ENDFORM.                    " CHECK_FIELDS
*&---------------------------------------------------------------------*
*&      Module  tabctrl_mark  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tabctrl_mark INPUT.


ENDMODULE.                 " tabctrl_mark  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_flag  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_flag INPUT.
*modify g_TABCTRL_itab from mara
ENDMODULE.                 " modify_flag  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_sel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_sel INPUT.
  MOVE mark TO g_tabctrl_wa-mark.
  MODIFY g_tabctrl_itab
      FROM g_tabctrl_wa
      INDEX tabctrl-current_line
      TRANSPORTING mark.

ENDMODULE.                 " modify_sel  INPUT
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_all.
  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.
    g_tabctrl_wa-mark = 'X'.
    MODIFY g_tabctrl_itab
        FROM g_tabctrl_wa
        TRANSPORTING mark.
  ENDLOOP.



ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deselect_all.
  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.
    g_tabctrl_wa-mark = ' '.
    MODIFY g_tabctrl_itab
        FROM g_tabctrl_wa
        TRANSPORTING mark.
  ENDLOOP.
ENDFORM.                    " DESELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  INSER_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM inser_line.
  INSERT INITIAL LINE INTO TABLE g_tabctrl_itab.
ENDFORM.                    " INSER_LINE
*&---------------------------------------------------------------------*
*&      Module  set_comititem  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_comititem OUTPUT.
  DATA : l_val LIKE mbew-vmbkl,
         l_konts LIKE t030-konts,
         l_bukrs LIKE t001k-bukrs,
         l_fipos LIKE skb1-fipos.
  DATA : l_cnt(3) TYPE c.

  CLEAR l_cnt.

  CLEAR l_val.
  CLEAR l_konts.
  CLEAR l_bukrs.
  CLEAR l_fipos.

  l_cnt = l_cnt + 1.

  SELECT SINGLE vmbkl INTO l_val FROM mbew
                         WHERE matnr = g_tabctrl_wa-matnr.

  IF sy-subrc = 0.

    SELECT SINGLE konts INTO l_konts FROM t030 WHERE ktosl = 'BSX'
                                                 AND bwmod = 'ONGC'
                                                 AND bklas  = l_val.
    IF sy-subrc = 0.

      SELECT SINGLE bukrs INTO l_bukrs FROM t001k
                                WHERE bwkey = g_tabctrl_wa-werks.

      IF sy-subrc = 0.

       SELECT SINGLE fipos INTO l_fipos FROM skb1 WHERE saknr = l_konts
                                           AND bukrs = l_bukrs.

      ENDIF.
    ENDIF.
  ENDIF.

  g_tabctrl_wa-fipos = l_fipos.
  g_tabctrl_wa-dismm = 'ND'.
  g_tabctrl_wa-srno = l_cnt.
  MOVE g_tabctrl_wa-fipos TO fmfpo-fipos.

ENDMODULE.                 " set_comititem  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXTN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_extn.

  DATA : BEGIN OF it_bwtar OCCURS 0,
         bwtar LIKE mbew-bwtar,
         END OF it_bwtar.
  DATA : l_bwtar TYPE mbew-bwtar.
  CLEAR l_pstat.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.
    CLEAR l_pstat.

    l_sytabix = sy-tabix.

    SELECT SINGLE pstat  FROM marc INTO l_pstat
                       WHERE matnr = g_tabctrl_wa-matnr
                         AND werks = g_tabctrl_wa-werks.


    IF sy-subrc = 0.
      SEARCH l_pstat FOR 'V' .
      IF sy-subrc = 0.
        SEARCH l_pstat FOR 'Q' .
        IF sy-subrc = 0.
          SEARCH l_pstat FOR 'L'.
          IF sy-subrc = 0.
            SEARCH l_pstat FOR 'D'.
            IF sy-subrc = 0.
              SEARCH l_pstat FOR 'E'.
              IF sy-subrc = 0.
                SEARCH l_pstat FOR 'B' .
                IF sy-subrc = 0.

                  CLEAR l_bwtar.

                  SELECT * FROM mbew APPENDING CORRESPONDING FIELDS
                                   OF TABLE it_bwtar
                                   WHERE matnr = g_tabctrl_wa-matnr
                                    AND  bwkey = g_tabctrl_wa-werks.

                  LOOP AT it_bwtar WHERE bwtar <> space.
                    IF it_bwtar-bwtar = g_tabctrl_wa-val_type.
                      wa_message-srno = g_tabctrl_wa-srno.
                      wa_message-msgtype3 = 'C'.
                      wa_message-msgtext3 = 'Matcode already extended'.
                    ELSE.
                      CLEAR wa_message-msgtext3 .
                      CLEAR wa_message-msgtype3.
                    ENDIF.
                  ENDLOOP.
                  g_tabctrl_wa-msgtext3 = wa_message-msgtext3.
                  g_tabctrl_wa-msgtype3 = wa_message-msgtype3.

                  MODIFY g_tabctrl_itab FROM g_tabctrl_wa
                  INDEX L_SYTABIX
                  TRANSPORTING msgtext3 msgtype3.

                  CLEAR wa_message-msgtext3 .
                  CLEAR wa_message-msgtype3.

                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR g_tabctrl_wa.
  CLEAR wa_message-msgtext3 .
  CLEAR wa_message-msgtype3.

ENDFORM.                    " CHECK_EXTN
*&---------------------------------------------------------------------*
*&      Form  CREATE_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_req.
  DATA : count(10) TYPE c.
  CLEAR count.
  IF save_ok101 = 'CREA'.

    SELECT  MAX( req_no ) INTO count FROM zmm_matextension.

    IF count = 0.
      count = 1.
    ELSE.
      count = count + 1.
    ENDIF.


    LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.



      zmm_matextension-req_date = sy-datum.
      zmm_matextension-req_cpf  = sy-uname.

      zmm_matextension-req_no = count .

      zmm_matextnmast-req_date = sy-datum.
      zmm_matextnmast-req_cpf  = sy-uname.

      zmm_matextnmast-req_no = count .


      MOVE-CORRESPONDING g_tabctrl_wa TO zmm_matextension.
      MOVE-CORRESPONDING g_tabctrl_wa TO zmm_matextnmast.
      INSERT INTO zmm_matextension VALUES zmm_matextension.
      INSERT INTO zmm_matextnmast VALUES zmm_matextnmast.
    ENDLOOP.
    MESSAGE i728(zmm) WITH zmm_matextension-req_no .
    LEAVE TO SCREEN '099'.

  ELSEIF save_ok101 = 'CHAN'.
    LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

      zmm_matextension-req_no = zmm_matextension-req_no .

      zmm_matextnmast-req_date = zmm_matextension-req_date.
      zmm_matextnmast-req_cpf  = zmm_matextension-req_cpf.

      zmm_matextnmast-req_no = zmm_matextension-req_no .

      zmm_matextnmast-remarks = zmm_matextnmast-remarks.

      MOVE-CORRESPONDING g_tabctrl_wa TO zmm_matextension.
      MOVE-CORRESPONDING g_tabctrl_wa TO zmm_matextnmast.

      MODIFY zmm_matextension.
      MODIFY zmm_matextnmast.
    ENDLOOP.
    MESSAGE i730(zmm) WITH zmm_matextension-req_no .
    LEAVE TO SCREEN '099'.
  ENDIF.
ENDFORM.                    " CREATE_REQ
*&---------------------------------------------------------------------*
*&      Form  GET_USERID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_userid.


ENDFORM.                    " GET_USERID
*&---------------------------------------------------------------------*
*&      Module  SET_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_screen OUTPUT.
  IF save_ok101 = 'DISP'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MATEXTNMAST-REQ_NO'.
        screen-input = 1.
        MODIFY SCREEN.
      ELSE.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF save_ok101 = 'CHAN'.
    LOOP AT SCREEN.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF save_ok101 = 'DELE'.
    LOOP AT SCREEN.
      IF screen-name = 'ZMM_MATEXTNMAST-REQ_NO'.
        screen-input = 1.
        MODIFY SCREEN.
      ELSE.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " SET_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'STATUS_101'.
  SET TITLEBAR 'TITLE101'.
ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  ok_code101 = sy-ucomm.

  save_ok101 = ok_code101.
  CLEAR ok_code101.

  CASE save_ok101.

    WHEN 'DISP'.

      g_flag = 'X'.
      g_tabctrl_copied = space.
      CALL SCREEN 100.

    WHEN 'CREA'.

      g_flag = 'Y'.
      CALL SCREEN 100.

    WHEN 'CHAN'.

      g_flag = 'Z'.
      g_tabctrl_copied = space.

      CALL SCREEN 100.

    WHEN 'DELE'.

      g_tabctrl_copied = space.

      CALL SCREEN 100.


  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Form  SAVE_TABC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_tabc.
  IF save_ok101 = 'CREA'.
    APPEND g_tabctrl_wa TO g_tabctrl_itab.
  ELSEIF save_ok101 = 'CHAN'.
    PERFORM create_req.
  ENDIF.

ENDFORM.                    " SAVE_TABC
*&---------------------------------------------------------------------*
*&      Form  DELETE_REQ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_req.
  IF save_ok101 = 'DELE'.
    IF zmm_matextension-req_cpf <> sy-uname.
      MESSAGE e726(zmm).
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
              titlebar              = text-a01
              text_question         = text-a04
              text_button_1         = 'Yes'
              text_button_2         = 'No'
              display_cancel_button = ' '
              start_column          = 20
              start_row             = 15
         IMPORTING
              answer                = g_ans.

    IF g_ans = '1'.

    DELETE FROM zmm_matextension WHERE req_no = zmm_matextension-req_no.
     DELETE FROM zmm_matextnmast WHERE req_no = zmm_matextension-req_no.

    ELSE.
      CLEAR : ok_code,save_ok.
      SET SCREEN sy-dynnr.
    ENDIF.


  ENDIF.



ENDFORM.                    " DELETE_REQ
*&---------------------------------------------------------------------*
*&      Form  VAL_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM val_type.
  DATA : l_matnr(2) TYPE c,
         l_valtyp(4) TYPE c.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

    L_SYTABIX = SY-TABIX.

    CLEAR l_matnr.
    CLEAR l_valtyp.

    l_matnr = g_tabctrl_wa-matnr+0(2).
    l_valtyp = g_tabctrl_wa-val_type+0(3).

    IF l_matnr LT '17'.
      IF l_valtyp NE 'STI'.
        wa_message-srno = g_tabctrl_wa-srno.
        wa_message-msgtype4 = 'D'.
        wa_message-msgtext4 = 'Valtype should be STI*'.
      ELSE.
        CLEAR wa_message-msgtext4 .
        CLEAR wa_message-msgtype4.
      ENDIF.

      g_tabctrl_wa-msgtext4 = wa_message-msgtext4.
      g_tabctrl_wa-msgtype4 = wa_message-msgtype4.

      MODIFY g_tabctrl_itab FROM g_tabctrl_wa
      INDEX L_SYTABIX
      TRANSPORTING msgtext4 msgtype4.

      CLEAR wa_message-msgtext4 .
      CLEAR wa_message-msgtype4.

    ELSEIF l_matnr BETWEEN '21' AND '43'.
      IF l_valtyp NE 'SPI'.
        wa_message-srno = g_tabctrl_wa-srno.
        wa_message-msgtype4 = 'E'.
        wa_message-msgtext4 = 'Valtype should be SPI*'.
      ELSE.
        CLEAR wa_message-msgtext4 .
        CLEAR wa_message-msgtype4.
      ENDIF.
      g_tabctrl_wa-msgtext4 = wa_message-msgtext4.
      g_tabctrl_wa-msgtype4 = wa_message-msgtype4.

      MODIFY g_tabctrl_itab FROM g_tabctrl_wa
      INDEX L_SYTABIX
      TRANSPORTING msgtext4 msgtype4.

      clear wa_message-msgtext4 .
      clear wa_message-msgtype4.

    ENDIF.
  ENDLOOP.

  CLEAR g_tabctrl_wa.
  clear wa_message-msgtext4 .
  clear wa_message-msgtype4.

ENDFORM.                    " VAL_TYPE
*&---------------------------------------------------------------------*
*&      Form  LIST_MESG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM list_mesg.

ENDFORM.                    " LIST_MESG
*&---------------------------------------------------------------------*
*&      Form  check_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_message.
  CLEAR msgcnt.

  msg_flag = space.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

    IF g_tabctrl_wa-msgtext1 IS INITIAL
     AND g_tabctrl_wa-msgtext2 IS INITIAL
      AND g_tabctrl_wa-msgtext3 IS INITIAL
      AND g_tabctrl_wa-msgtext4 IS INITIAL.


    ELSE.
      msgcnt = msgcnt + 1.
    ENDIF.

  ENDLOOP.

  IF msgcnt IS INITIAL.
    msg_flag = 'X'.
  ENDIF.

  CLEAR g_tabctrl_wa.

ENDFORM.                    " check_message
*&---------------------------------------------------------------------*
*&      Form  SORT_ASC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_asc.

  SORT g_tabctrl_itab ASCENDING BY matnr.

ENDFORM.                    " SORT_ASC
*&---------------------------------------------------------------------*
*&      Form  SORT_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_desc.

  SORT g_tabctrl_itab DESCENDING BY matnr.

ENDFORM.                    " SORT_DESC
*&---------------------------------------------------------------------*
*&      Form  FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM filter.

  READ  TABLE tabctrl-cols WITH  KEY selected = 'X' INTO
      wa_tabctrl_cols .

ENDFORM.                    " FILTER
*&---------------------------------------------------------------------*
*&      Form  COPY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy.
  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa WHERE mark = 'X'.
    CLEAR g_tabctrl_wa-mark.
    APPEND g_tabctrl_wa TO  g_tabctrl_itab.
    MODIFY g_tabctrl_itab
        FROM g_tabctrl_wa
        TRANSPORTING mark.
  ENDLOOP.
ENDFORM.                    " COPY
*&---------------------------------------------------------------------*
*&      Form  read_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_message.
  SORT ist_message BY srno.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.
  ENDLOOP.

ENDFORM.                    " read_message
*&---------------------------------------------------------------------*
*&      Form  CHECK_PLANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_plant.
  DATA : l_plant TYPE t001w-werks.

  LOOP AT g_tabctrl_itab INTO g_tabctrl_wa.

    L_SYTABIX = SY-TABIX.

    CLEAR l_plant.

    SELECT SINGLE werks INTO l_plant FROM t001w WHERE  werks =
    g_tabctrl_wa-werks.
    IF sy-subrc <> 0.

      wa_message-srno = g_tabctrl_wa-srno.
      wa_message-msgtype5 = 'F'.
      wa_message-msgtext5 = 'Plant does not exist'.
    ELSE.
      CLEAR wa_message-msgtext5 .
      CLEAR wa_message-msgtype5.
    ENDIF.
    g_tabctrl_wa-msgtext5  = wa_message-msgtext5.
    g_tabctrl_wa-msgtype5  = wa_message-msgtype5.

    MODIFY g_tabctrl_itab FROM g_tabctrl_wa
    INDEX l_sytabix
    TRANSPORTING msgtext5 msgtype5.

    CLEAR wa_message-msgtext5 .
    CLEAR wa_message-msgtype5.

  ENDLOOP.
  CLEAR g_tabctrl_wa.
  CLEAR wa_message-msgtext5 .
  CLEAR wa_message-msgtype5.

ENDFORM.                    " CHECK_PLANT
