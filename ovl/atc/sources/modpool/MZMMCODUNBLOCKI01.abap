*--- MAIN PROGRAM: MZMMCODUNBLOCKI01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 25/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete F.M POPUP_TO_CONFRIM_STEP replaced with POPUP_TO_CONFRIM.
************************************************************************


*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: modify table
MODULE tct110_modify INPUT.
  MODIFY g_tc110_itab
    FROM g_tc110_wa
    INDEX tct110-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc110_wa TO g_tc110_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input modul for tc 'TCT110'. do not change this line!
*&spwizard: mark table
MODULE tct110_mark INPUT.
  DATA: g_tct110_wa2 LIKE LINE OF g_tc110_itab.
  IF tct110-line_sel_mode = 1.
    LOOP AT g_tc110_itab INTO g_tct110_wa2
      WHERE mark = 'X'.
      g_tct110_wa2-mark = ''.
      MODIFY g_tc110_itab
        FROM g_tct110_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc110_itab
    FROM g_tc110_wa
    INDEX tct110-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT110'. do not change this line!
*&spwizard: process user command
MODULE tct110_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT110'.
*  ok_code = sy-ucomm.
    ok_code = okcode_100.

    PERFORM user_ok_tc USING    'TCT110'
                                'G_TC110_ITAB'
                                'MARK'
                       CHANGING ok_code.
    CLEAR:okcode_100,ok_code.
  ENDIF.
*  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  PERFORM confirm_exit.

ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
*  GET CURSOR FIELD g_curfield.
***To populate the username in the Req Number search help.
  SET PARAMETER ID 'XUS' FIELD sy-uname.
***
  CASE zmm_matblockhd_st-mtart.
    WHEN 'ZCAP'.
      dynnr = '0130'.
    WHEN 'ZSPR'.
      dynnr = '0120'.
    WHEN 'ZSTO'.
      dynnr = '0110'.
    WHEN 'ZDIS'.
      dynnr = '0140'.
    WHEN OTHERS.
*        dynnr = '0101'.
      dynnr = '0110'.
  ENDCASE.

  CASE okcode_100.
    WHEN 'BAC' OR 'CAN'.
      PERFORM back_confirm.
      CLEAR okcode_100.
    WHEN 'CREATE'.
      g_mode = 'CRE'.
      CLEAR okcode_100.
    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR okcode_100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR okcode_100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR okcode_100.
    WHEN 'RELEASE'.
      g_mode = 'REL'.
      CLEAR okcode_100.
    WHEN 'UNBLOCK'.
      PERFORM unblock_matcode.
      IF zmm_matblockhd_st-reqcl = 'C'.
        PERFORM send_mail_to_reqn.
      ENDIF.
      CLEAR okcode_100.
      IF g_choice = 'J'.
        CLEAR g_choice.
        PERFORM clear_var.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'SAV'.
      PERFORM save_request.
*      PERFORM clear_var.
*      CLEAR okcode_100.
    WHEN 'CORRES'.
      CLEAR okcode_100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
  ENDCASE.
**************************************************************
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: modify table
MODULE tct120_modify INPUT.
  MODIFY g_tc120_itab
    FROM g_tc120_wa
    INDEX tct120-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc120_wa TO g_tc120_itab.
  ENDIF.

ENDMODULE.

*&spwizard: input modul for tc 'TCT120'. do not change this line!
*&spwizard: mark table
MODULE tct120_mark INPUT.
  DATA: g_tct120_wa2 LIKE LINE OF g_tc120_itab.
  IF tct120-line_sel_mode = 1.
    LOOP AT g_tc120_itab INTO g_tct120_wa2
      WHERE mark = 'X'.
      g_tct120_wa2-mark = ''.
      MODIFY g_tc120_itab
        FROM g_tct120_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc120_itab
    FROM g_tc120_wa
    INDEX tct120-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT120'. do not change this line!
*&spwizard: process user command
MODULE tct120_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT120'.
*  ok_code = sy-ucomm.
    ok_code = okcode_100.
    PERFORM user_ok_tc USING    'TCT120'
                                'G_TC120_ITAB'
                                'MARK'
                       CHANGING ok_code.
    CLEAR: ok_code,okcode_100.
  ENDIF.
*  sy-ucomm = ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.
  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
    IMPORTING
      text                   = lt_text_table1
      is_modified            = gv_xthead_updkz
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      text_stream = lt_text_table1
      itf_text    = tlinetab1.
*
  IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ).
    CALL METHOD gv_text_editor2->get_text_as_stream
      IMPORTING
        text                   = lt_text_table2
        is_modified            = gv_xthead_updkz
      EXCEPTIONS
        error_dp               = 1
        error_cntl_call_method = 2
        OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        text_stream = lt_text_table2
        itf_text    = tlinetab2.
  ENDIF..

ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  DATA: okcode105 LIKE sy-ucomm.

  okcode105 = sy-ucomm.

  CASE okcode105.
    WHEN 'OK'.
      CLEAR okcode105.
    WHEN 'CANCEL'.
      REFRESH tlinetab2[].
      CLEAR okcode105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_reqno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_reqno INPUT.
  DATA : l_hd_reqno LIKE zmm_matblock_hd,
         l_ans      TYPE c.
***Intializing**********
  CLEAR g_hd_copied.
  CLEAR: g_tct110_copied,g_tct120_copied,g_tct130_copied.
  REFRESH: tlinetab1,tlinetab2,lines_cors.
  REFRESH: lt_text_table1,lt_text_table2.

*************************
  IF g_mode = 'CHA'.

    SELECT SINGLE * INTO l_hd_reqno FROM zmm_matblock_hd
           WHERE reqno = zmm_matblockhd_st-reqno.
*** Check for deletion.
    IF l_hd_reqno-lvorm = 'X'.
      MESSAGE i087(zmm_oth) WITH zmm_matblockhd_st-reqno.
      LEAVE TO SCREEN 100.
    ENDIF.
***To check for original creator........
    IF l_hd_reqno-reqcpf <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-reqcpf.
    ENDIF.
*** To check for C/AC/IC request.
    IF l_hd_reqno-reqcl = 'C' OR
       l_hd_reqno-reqcl = 'AC'.
      MESSAGE e104(zmm_oth) WITH zmm_matblockhd_st-reqno.
    ENDIF.
    IF l_hd_reqno-reqcl = 'IC'.
      MESSAGE e112(zmm_oth) WITH zmm_matblockhd_st-reqno.
    ENDIF.
***Check for Release reset
    IF l_hd_reqno-rel_flag = 'X'.
      " Begin of <RD1K960036>.
*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*           EXPORTING
*                defaultoption = 'N'
*                textline1     = 'Release will be reset. Proceed ?'
*                titel         = 'Release Reset'
*           IMPORTING
*                answer        = l_ans.

      DATA : l_answer(1) TYPE c.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Release Reset '
          text_question         = 'Release will be reset. Proceed ?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = l_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF sy-subrc = 0.
        CASE l_answer.
          WHEN '1'.
            MOVE 'J' TO l_ans.
          WHEN '2'.
            MOVE 'N' TO l_ans.
        ENDCASE.
      ENDIF.

      " End of <RD1K960036>.

      IF l_ans = 'J'.
        g_relflag = 'J'.
        zmm_matblockhd_st-rel_flag = ''.
      ELSE.
        PERFORM clear_var.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ELSEIF g_mode = 'REL'.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_matblock_hd
          WHERE reqno = zmm_matblockhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-reqcpf <> sy-uname.
        MESSAGE e107(zmm_oth) WITH l_hd_reqno-reqcpf.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_reqno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_spell  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell INPUT.
  PERFORM spell_check USING g_tc110_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.
    DATA : l_answer1(1) TYPE c.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors? '
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_answer1
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_answer1.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc110_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct110-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC110_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc110_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc110_wa-errcd = 'S'.
      g_tc110_wa-errcd = ''.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_spell  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_matblockhd_st-tel ).
  IF  zmm_matblockhd_st-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_tel  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.
  DATA : l_werks LIKE t001w-werks.
  IF NOT zmm_matblockhd_st-werks IS INITIAL.
    SELECT SINGLE werks INTO l_werks FROM t001w
           WHERE werks = zmm_matblockhd_st-werks.
    IF sy-subrc <> 0.
      MESSAGE e033(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcode110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode110 INPUT.
  DATA:l_tc110    TYPE ty_tc110,
       l110_blkdt LIKE zmm_matblock_dt.

  IF ( g_mode = 'CRE' OR
       g_mode = 'CHA' ) AND
       zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc110_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
**
  IF g_mode = 'CRE'.
    SELECT * INTO l110_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc110_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc110_wa-matcode l110_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l110_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc110_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc110_wa-matcode l110_blkdt-reqno.
    ENDIF.
  ENDIF.
**
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc110,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc110_itab INTO l_tc110 INDEX g_selline.
*    IF g_cfld = 'G_TC110_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc110-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " check_matcode110  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode INPUT.
  DATA: l_blkdt LIKE zmm_matblock_dt.
  DATA: l_tc120 TYPE ty_tc120.
  IF ( g_mode = 'CRE' OR g_mode = 'CHA' )
     AND zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc120_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
***
  IF g_mode = 'CRE'.
    SELECT * INTO l_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc120_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc120_wa-matcode l_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc120_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc120_wa-matcode l_blkdt-reqno.
    ENDIF.
  ENDIF.
***
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc120,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc120_itab INTO l_tc120 INDEX g_selline.
*    IF g_cfld = 'G_TC120_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc120-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

* clear: g_cfld,l_tc130,g_selline.
*  GET CURSOR LINE g_selline.
*  get cursor field g_cfld.
*  read table g_tc130_itab into l_tc130 index g_selline.
*  IF g_cfld = 'G_TC130_WA-MATCODE'.
*    set parameter id 'MAT' field l_tc130-matcode.
*    call transaction 'MM03' and skip first screen.
*  ENDIF.
* clear sy-ucomm.


ENDMODULE.                 " check_matcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_partno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_partno INPUT.

  PERFORM check_splchar USING g_tc120_wa-npartno.
  IF NOT g_oputdata IS INITIAL.
    g_tc120_wa-npartno = g_oputdata .
  ENDIF.
**To clear new part number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-npartno.
  ENDIF.
**

ENDMODULE.                 " check_partno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_mdlno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_mdlno INPUT.

*  PERFORM check_splchar USING g_tc120_wa-nmdlno.
*  g_tc120_wa-nmdlno = g_oputdata .
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_mdlno TYPE zmm_mdl-mdlno.
  lv_mdlno = g_tc120_wa-nmdlno.
*  IF NOT g_tc120_wa-nmdlno IS INITIAL.
  IF NOT lv_mdlno IS INITIAL.
    SELECT SINGLE * FROM zmm_mdl
*           WHERE mdlno = g_tc120_wa-nmdlno.
           WHERE mdlno = lv_mdlno.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e111(zmm_oth).
    ENDIF.
  ENDIF.
**To clear new model number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-nmdlno.
  ENDIF.
**
ENDMODULE.                 " check_mdlno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_spell_spr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell_spr INPUT.
  PERFORM spell_check USING g_tc120_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.
    DATA : l_answer2(1) TYPE c.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors?'
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_answer2
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_answer2.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc120_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct120-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC120_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc120_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc120_wa-errcd = 'S'.
      g_tc120_wa-errcd = ''.
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_spell_spr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate INPUT.
  DATA: l_sto TYPE ty_tc110.
  CLEAR : g_clrndesc.

  READ TABLE g_tc110_itab INTO l_sto
                          WITH KEY matcode = g_tc110_wa-matcode.
  IF sy-subrc = 0.
    IF l_sto-srno <> g_tc110_wa-srno.
      MESSAGE e093(zmm_oth).
    ENDIF.
  ENDIF.
***
*  IF g_tc110_wa-omatdesc IS INITIAL.

  SELECT maktx INTO g_tc110_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE matnr = g_tc110_wa-matcode
 ORDER BY PRIMARY KEY .
  ENDSELECT.
*  ENDIF.
*  IF g_tc110_wa-ouom IS INITIAL OR
*     g_tc110_wa-mstae IS INITIAL.
  SELECT SINGLE meins mstae INTO
               (g_tc110_wa-ouom,g_tc110_wa-mstae)
         FROM mara
         WHERE matnr = g_tc110_wa-matcode.
*  ENDIF.
*******To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************
ENDMODULE.                 " check_duplicate  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate_spr  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_spr INPUT.
  DATA : l_mara LIKE mara.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_matnr TYPE mara-matnr,
        lv_objek TYPE ausp-objek.
  READ TABLE g_tc120_itab WITH KEY matcode = g_tc120_wa-matcode.
  IF sy-subrc = 0.
    MESSAGE e093(zmm_oth).
  ENDIF.
***
***Material Description
*  IF NOT g_tc120_wa-matcode IS INITIAL.
  lv_matnr = g_tc120_wa-matcode.
  lv_objek = g_tc120_wa-matcode.

  SELECT maktx INTO g_tc120_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE
*    matnr = g_tc120_wa-matcode
    matnr = lv_matnr
 ORDER BY PRIMARY KEY .
  ENDSELECT.
***UOM, OEM, Part Number
  SELECT SINGLE * INTO l_mara FROM mara
*         WHERE matnr = g_tc120_wa-matcode.
         WHERE matnr = lv_matnr.
  IF sy-subrc = 0.
    g_tc120_wa-mstae   = l_mara-mstae.
    g_tc120_wa-ouom    = l_mara-meins.
    g_tc120_wa-ooem    = l_mara-mfrnr.
    g_tc120_wa-opartno = l_mara-mfrpn.
***Model Number
    SELECT atinn FROM cabn INTO g_modelcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_MODELCODE'
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc <> 0.
      g_modelcode_no = ''.
    ENDIF.

*    SELECT atwrt INTO g_tc120_wa-omdlno
    SELECT atwrt INTO @DATA(lv_omdlno)
 FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc120_wa-matcode
      objek = @lv_objek
      AND atinn = @g_modelcode_no
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    g_tc120_wa-omdlno = lv_omdlno+0(30) .  "#EC CI_FLDEXT_OK[2215424]
***Capital Code
    SELECT atinn FROM cabn INTO g_capcode_no UP TO 1 ROWS
 WHERE atnam = 'Z_ONGC_CAPCODE'
 ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc <> 0.
      g_capcode_no = ''.
    ENDIF.
    SELECT atwrt INTO g_tc120_wa-ocapno
 FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc120_wa-matcode
      objek = lv_objek
      AND atinn = g_capcode_no
 ORDER BY PRIMARY KEY .
    ENDSELECT.
  ENDIF.
*  ENDIF.
  "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
*******To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************


ENDMODULE.                 " check_duplicate_spr  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_noem  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_noem INPUT.
  IF NOT g_tc120_wa-noem IS INITIAL.
    SELECT SINGLE * FROM lfa1
           WHERE lifnr = g_tc120_wa-noem.
    IF sy-subrc <> 0.
      MESSAGE e105(zmm_oth) WITH g_tc120_wa-noem.
    ENDIF.
  ENDIF.
**To clear new oem if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-noem.
  ENDIF.
**
ENDMODULE.                 " check_noem  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_ncapno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_ncapno INPUT.
  IF NOT g_tc120_wa-ncapno IS INITIAL.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc120_wa-ncapno.
    IF sy-subrc <> 0.
      MESSAGE e106(zmm_oth) WITH g_tc120_wa-ncapno.
    ENDIF.
  ENDIF.
**To clear new part number if entered, incase of change in matcode.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-ncapno.
  ENDIF.
  CLEAR g_clrndesc.
**
ENDMODULE.                 " check_ncapno  INPUT

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: modify table
MODULE tct130_modify INPUT.
  MODIFY g_tc130_itab
    FROM g_tc130_wa
    INDEX tct130-current_line.
  IF sy-subrc <> 0.
    APPEND g_tc130_wa TO g_tc130_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input modul for tc 'TCT130'. do not change this line!
*&spwizard: mark table
MODULE tct130_mark INPUT.
  DATA: g_tct130_wa2 LIKE LINE OF g_tc130_itab.
  IF tct130-line_sel_mode = 1.
    LOOP AT g_tc130_itab INTO g_tct130_wa2
      WHERE mark = 'X'.
      g_tct130_wa2-mark = ''.
      MODIFY g_tc130_itab
        FROM g_tct130_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY g_tc130_itab
    FROM g_tc130_wa
    INDEX tct130-current_line
    TRANSPORTING mark.
ENDMODULE.

*&spwizard: input module for tc 'TCT130'. do not change this line!
*&spwizard: process user command
MODULE tct130_user_command INPUT.

  IF sy-ucomm+0(6) = 'TCT130'.
    ok_code = okcode_100.
    PERFORM user_ok_tc USING    'TCT130'
                                'G_TC130_ITAB'
                                'MARK'
                     CHANGING ok_code.
    CLEAR: ok_code,okcode_100.
  ENDIF.
*  sy-ucomm = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  check_matcode130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcode130 INPUT.
  DATA: l130_blkdt LIKE zmm_matblock_dt.
  DATA: l_tc130 TYPE ty_tc130.
  IF ( g_mode = 'CRE' OR g_mode = 'CHA' )
     AND zmm_matblockhd_st-reqcl <> 'IR'.
    SELECT SINGLE * FROM mara
           WHERE matnr = g_tc130_wa-matcode
           AND   mtart = zmm_matblockhd_st-mtart
           AND   mstae IN ('PC','TC').
    IF sy-subrc <> 0.
      MESSAGE e090(zmm_oth).
    ENDIF.
  ENDIF.
***
  IF g_mode = 'CRE'.
    SELECT * INTO l130_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE matcode = g_tc130_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc130_wa-matcode l130_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO l130_blkdt FROM zmm_matblock_dt UP TO 1 ROWS
  WHERE reqno <> zmm_matblockhd_st-reqno AND matcode = g_tc130_wa-matcode AND unblkby = ''
  ORDER BY PRIMARY KEY .
    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tc130_wa-matcode l130_blkdt-reqno.
    ENDIF.
  ENDIF.

***
*  IF sy-ucomm = 'DBLCLK'.
*    CLEAR: g_cfld,l_tc130,g_selline.
*    GET CURSOR LINE g_selline.
*    GET CURSOR FIELD g_cfld.
*    READ TABLE g_tc130_itab INTO l_tc130 INDEX g_selline.
*    IF g_cfld = 'G_TC130_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc130-matcode.
*      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " check_matcode130  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate_cap  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_duplicate_cap INPUT.
  DATA : l130_mara LIKE mara.
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  READ TABLE g_tc130_itab WITH KEY matcode = g_tc130_wa-matcode.
  IF sy-subrc = 0.
    MESSAGE e093(zmm_oth).
  ENDIF.
***
***Material Description
*  IF NOT g_tc130_wa-matcode IS INITIAL.
  lv_matnr = g_tc130_wa-matcode.
  SELECT maktx INTO g_tc130_wa-omatdesc
 FROM makt UP TO 1 ROWS WHERE
*    matnr = g_tc130_wa-matcode
    matnr = lv_matnr
 ORDER BY PRIMARY KEY .
  ENDSELECT.
***UOM, OEM, Part Number
  SELECT SINGLE * INTO l130_mara FROM mara
*         WHERE matnr = g_tc130_wa-matcode.
         WHERE matnr = lv_matnr.
  IF sy-subrc = 0.
    g_tc130_wa-mstae  = l130_mara-mstae.
    g_tc130_wa-ouom   = l130_mara-meins.

***Material Location
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_PLACE_OF_USE_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.
    lv_objek = g_tc130_wa-matcode.
*    SELECT atwrt INTO g_tc130_wa-omatloc
    SELECT atwrt INTO @DATA(lv_omatloc)
FROM ausp UP TO 1 ROWS
*      WHERE objek = g_tc130_wa-matcode
      WHERE objek = @lv_objek
      AND atinn = @g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
    g_tc130_wa-omatloc = g_tc130_wa-omatloc+0(30).  "#EC CI_FLDEXT_OK[2215424]
***Material life
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_LIFE_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atflv INTO g_tc130_wa-omat_life
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
***Material Cost
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_COST_OF_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atflv INTO g_tc130_wa-omatcost
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
***Material Category
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_GROUP_CAPITAL'
ORDER BY PRIMARY KEY .
    ENDSELECT.

*    SELECT atwrt INTO g_tc130_wa-omatcatg
    SELECT atwrt INTO @DATA(lv_omatcatg)
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = @lv_objek
      AND atinn = @g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
g_tc130_wa-omatcatg = lv_omatcatg+0(30).   "#EC CI_FLDEXT_OK[2215424]
***Material Group
    CLEAR g_atinn130.
    SELECT atinn INTO g_atinn130 FROM cabn UP TO 1 ROWS
WHERE atnam = 'Z_ONGC_GROUP_OF_SPARES'
ORDER BY PRIMARY KEY .
    ENDSELECT.

    SELECT atwrt INTO g_tc130_wa-omatgp
FROM ausp UP TO 1 ROWS WHERE
*      objek = g_tc130_wa-matcode
      objek = lv_objek
      AND atinn = g_atinn130
ORDER BY PRIMARY KEY .
    ENDSELECT.
  ENDIF.
  "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
***To clear the proposed material description if any,
  g_clrndesc = 'Y'.
***********************

ENDMODULE.                 " check_duplicate_cap  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

ENDMODULE.                 " USER_COMMAND_0103  INPUT

AT USER-COMMAND.
  IF g_mode = 'REL'.
    CASE sy-ucomm.
      WHEN 'AGREE'.
        g_rel = 'Y'.
        CLEAR sy-ucomm.
        LEAVE TO SCREEN 0.
      WHEN 'DISAGREE'.
        g_rel = 'N'.
        CLEAR sy-ucomm.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Module  check_spell_cap  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_spell_cap INPUT.
  PERFORM spell_check USING g_tc130_wa-matdesc.
  IF g_errflag = 'Y'.

    " Begin of <RD1K960036>.
*    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*      EXPORTING
*        textline1 = 'There are spelling errors in description(s)'
*        textline2            = 'Proceed with errors? '
*        titel                = 'Spelling Errors'
**
*      IMPORTING
*         answer               = g_ans.

    DATA : l_variable.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Spelling Errors '
        text_question         = 'There are spelling errors in description(s)'
                                & 'Proceed with errors?'
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
      IMPORTING
        answer                = l_variable
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      CASE l_variable.
        WHEN '1'.
          MOVE 'J' TO g_ans.
        WHEN '2'.
          MOVE 'N' TO g_ans.
      ENDCASE.
    ENDIF.

    " End of <RD1K960036>.

    IF g_ans = 'J'.
      g_tc130_wa-errcd = 'S'.
    ELSE.
      GET CURSOR LINE g_cursor_line.
      g_curr_line = tct130-top_line + g_cursor_line - 1.
      SET CURSOR FIELD 'G_TC130_WA-MATDESC' LINE g_curr_line.
      MESSAGE e114(zmm_oth) WITH g_tc130_wa-matdesc.
    ENDIF.
    CLEAR g_errflag.
  ELSE.
    IF g_tc130_wa-errcd = 'S'.
      g_tc130_wa-errcd = ''.
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_spell_cap  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_newdesc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_newdesc INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc110_wa-matdesc.
  ENDIF.
  CLEAR g_clrndesc.
ENDMODULE.                 " clear_newdesc  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_ndesc120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_ndesc120 INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc120_wa-matdesc.
  ENDIF.
ENDMODULE.                 " clear_ndesc120  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_ndesc130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_ndesc130 INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matdesc.
  ENDIF.

ENDMODULE.                 " clear_ndesc130  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matloc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matloc INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matloc.
  ENDIF.
ENDMODULE.                 " check_matloc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matgp  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matgp INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matgp.
  ENDIF.

ENDMODULE.                 " check_matgp  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcost  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcost INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matcost.
  ENDIF.
ENDMODULE.                 " check_matcost  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matlife  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matlife INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-mat_life.
  ENDIF.
  CLEAR g_clrndesc.

****Life less than 100.
  IF g_tc130_wa-mat_life > 100.
    MESSAGE e115(zmm_oth).
  ENDIF.
ENDMODULE.                 " check_matlife  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_user INPUT.
  DATA l_user LIKE soud3.
* clear: g_fname.
**
* GET CURSOR FIELD g_fname.
*  CASE g_fname.
*    WHEN 'ZMM_MATBLOCKHD_ST-REQCPF'.
  l_user = zmm_matblockhd_st-reqcpf.
*  ENDCASE.
* IF sy-ucomm = 'DBLCLK'.
  CALL FUNCTION 'SO_ADDRESS_SHOW'
    EXPORTING
      user                       = l_user
    EXCEPTIONS
      parameter_error            = 1
      user_not_exist             = 2
      x_error                    = 3
      operation_no_authorization = 4
      OTHERS                     = 5.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*  clear sy-ucomm.
* Endif.
ENDMODULE.                 " show_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_code INPUT.
  DATA : l_matcode LIKE zmm_matblock_dt-matcode.
*IF sy-ucomm = 'DBLCLK'.
  CLEAR: g_cfld,l_tc110,g_selline.
*    GET CURSOR LINE g_selline.
  GET CURSOR FIELD g_cfld.

  CASE g_cfld.
    WHEN 'G_TC110_WA-MATCODE'.
      l_matcode = g_tc110_wa-matcode.
    WHEN 'G_TC120_WA-MATCODE'.
      l_matcode = g_tc120_wa-matcode.
    WHEN 'G_TC130_WA-MATCODE'.
      l_matcode = g_tc130_wa-matcode.
    WHEN 'G_TC120_WA-NCAPNO'.
      l_matcode = g_tc120_wa-ncapno.
    WHEN 'G_TC120_WA-OCAPNO'.
      l_matcode = g_tc120_wa-ocapno.
  ENDCASE.
*    READ TABLE g_tc110_itab INTO l_tc110 INDEX g_selline.
*    IF g_cfld = 'G_TC110_WA-MATCODE'.
*      SET PARAMETER ID 'MAT' FIELD l_tc110-matcode.
  SET PARAMETER ID 'MAT' FIELD l_matcode.
  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
*    ENDIF.
*    CLEAR sy-ucomm.
*  ENDIF.

ENDMODULE.                 " show_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcatg  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcatg INPUT.
  IF g_clrndesc = 'Y'.
    CLEAR g_tc130_wa-matcatg.
  ENDIF.

ENDMODULE.                 " check_matcatg  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matcatg_val  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matcatg_val INPUT.
  "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

  DATA: lv_atwrt_1 TYPE zmmcdcap_usrgp_v-atwrt.
  lv_atwrt_1 = g_tc130_wa-matcatg.
  IF NOT g_tc130_wa-matcatg IS INITIAL.
    SELECT SINGLE * FROM zmmcdcap_usrgp_v
*           WHERE atwrt = g_tc130_wa-matcatg.
           WHERE atwrt = lv_atwrt_1.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e117(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_matcatg_val  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matlocval  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_matlocval INPUT.
  IF NOT g_tc130_wa-matloc IS INITIAL.
    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 12.06.2026

    DATA: lv_atwrt TYPE zmmcdcap_loc_v-atwrt.
    lv_atwrt = g_tc130_wa-matloc.
    SELECT SINGLE * FROM zmmcdcap_loc_v
*           WHERE atwrt = g_tc130_wa-matloc.
           WHERE atwrt = lv_atwrt.
    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 12.06.2026
    IF sy-subrc <> 0.
      MESSAGE e118(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_matlocval  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_oem  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_oem INPUT.
  DATA : l_oem LIKE zmm_matblock_dt-ooem.
  CLEAR: g_cfld,g_selline.

  GET CURSOR FIELD g_cfld.

  CASE g_cfld.
    WHEN 'G_TC120_WA-OOEM'.
      l_oem = g_tc120_wa-ooem.
    WHEN 'G_TC120_WA-NOEM'.
      l_oem = g_tc120_wa-noem..
  ENDCASE.
  "Begin of ATC Correction 29.04.2026
*      SET PARAMETER ID 'LIF' FIELD l_oem.
*      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.

  SELECT partner FROM v_cvi_vend_link
INTO @DATA(lv_partner) UP TO 1 ROWS WHERE lifnr = @l_oem
ORDER BY PRIMARY KEY .
  ENDSELECT.

  DATA(request) = NEW cl_bupa_navigation_request( ).
  request->set_partner_number( lv_partner ).     " import your BP number here
  CALL METHOD request->set_bupa_activity
    EXPORTING
      iv_value = request->gc_activity_display.
  DATA(options) = NEW cl_bupa_dialog_joel_options( ).
  options->set_navigation_disabled( abap_true ).
  cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
  iv_options = options ).
  "End of ATC Correction 29.04.2026

ENDMODULE.                 " show_oem  INPUT
