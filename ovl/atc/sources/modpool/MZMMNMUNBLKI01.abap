*--- MAIN PROGRAM: MZMMNMUNBLKI01 ---*
***INCLUDE MZMMNMUNBLKI01 .
*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: modify table
MODULE tct100_modify INPUT.
  MOVE-CORRESPONDING zmm_nmblkcddt TO g_tct100_wa.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line.
  IF sy-subrc <> 0.
    APPEND g_tct100_wa TO g_tct100_itab.
  ENDIF.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: mark table
MODULE tct100_mark INPUT.
  IF tct100-line_sel_mode = 1 AND
     g_tct100_wa-flag = 'X'.
    LOOP AT g_tct100_itab INTO g_tct100_wa
      WHERE flag = 'X'.
      g_tct100_wa-flag = ''.
      MODIFY g_tct100_itab
        FROM g_tct100_wa
        TRANSPORTING flag.
    ENDLOOP.
    g_tct100_wa-flag = 'X'.
  ENDIF.
  MODIFY g_tct100_itab
    FROM g_tct100_wa
    INDEX tct100-current_line
    TRANSPORTING flag.
ENDMODULE.

*&spwizard: input module for tc 'TCT100'. do not change this line!
*&spwizard: process user command
MODULE tct100_user_command INPUT.
  IF sy-ucomm+0(6) = 'TCT100'.
*  OK_CODE = sy-ucomm.
    ok_code = ok_code100.
    PERFORM user_ok_tc USING    'TCT100'
                                'G_TCT100_ITAB'
                                'FLAG'
                       CHANGING ok_code.
    CLEAR:ok_code100,ok_code.
  ENDIF.
*  sy-ucomm = OK_CODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code100.
    WHEN 'BAC' OR 'CAN'.
      PERFORM back_confirm.
      CLEAR ok_code100.
    WHEN 'CREATE'.
*    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*                  ID 'ACTVT' FIELD  '01'
*                  ID 'ACTVT' FIELD  '02'.
*
*    If sy-subrc <> 0.
*      message e124(zmm_oth).
*    Endif.

*Begin CR no: 30008546 MM Non-moving material workflow  CAB_ALOK
*perform DISABLE_CREATE. TYPE 'E'
           CLEAR ok_code100.
     MESSAGE e236(zmm_oth).
     exit.
*      g_mode = 'CRE'.
*      CLEAR ok_code100.
*End CR no: 30008546 MM Non-moving material workflow CAB_ALOK


    WHEN 'CHANGE'.
      g_mode = 'CHA'.
      CLEAR ok_code100.
    WHEN 'DISPLAY'.
      g_mode = 'DIS'.
      CLEAR ok_code100.
    WHEN 'DELETE'.
      g_mode = 'DEL'.
      CLEAR ok_code100.
    WHEN 'RELEASE'.
      g_mode = 'REL'.
      CLEAR ok_code100.
    WHEN 'APPROVE'.
      g_mode = 'APR'.
      CLEAR ok_code100.
    WHEN 'ATTACH'.
      PERFORM attach_file.
      CLEAR ok_code100.
    WHEN 'LIST'.
      PERFORM list_file.
      CLEAR ok_code100.
    WHEN 'DELATTACH'.
      PERFORM del_attachment.
      clear ok_code100.
    WHEN 'HELP'.
      PERFORM guidelines.
      CLEAR ok_code100.
    WHEN 'CIRCULAR'.
      PERFORM circular.
      CLEAR ok_code100.
    WHEN 'UNBLOCK'.
      PERFORM unblock_matcode.
      IF g_mesg <> 'X'.
        message i126(zmm_oth).
      ENDIF.
      IF zmm_nmblkcdhd_st-status = 'C'.
        PERFORM send_mail_to_reqn.
      ENDIF.
*      CLEAR okcode_100.
*      if g_choice = 'J'.
*       clear g_choice.
*       PERFORM clear_var.
*       leave program.
*      endif.
    WHEN 'SAV'.
      PERFORM save_request.
*      PERFORM clear_var.
*      CLEAR okcode_100.
    WHEN 'CORRES'.
      CLEAR ok_code100.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
    WHEN 'REPORT'.
      clear ok_code100.
      SUBMIT ZMM_MAT_NMCODES VIA SELECTION-SCREEN AND RETURN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_ctrl_uebernehmen1 INPUT.
  gv_xthead_updkz = 0.

  CALL METHOD gv_text_editor1->get_text_as_stream
       IMPORTING
            text       =  lt_text_table1
            is_modified = gv_xthead_updkz
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
     ( g_mode = 'REL' ) OR ( g_mode = 'BLK' ) OR
     ( g_mode = 'APR' ).
    CALL METHOD gv_text_editor2->get_text_as_stream
         IMPORTING
              text       =  lt_text_table2
              is_modified = gv_xthead_updkz
         EXCEPTIONS
              error_dp               = 1
              error_cntl_call_method = 2
              OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
         TABLES
              text_stream = lt_text_table2
              itf_text    = tlinetab2.
  ENDIF.

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
  DATA : l_hd_reqno LIKE zmm_nmblkcdhd,
         l_result type c,
         l_ans TYPE c.
***Intializing**********
  CLEAR:  g_hd_copied,g_tct100_copied,g_result.
  REFRESH: tlinetab1,tlinetab2,lines_cors.
  REFRESH: lt_text_table1,lt_text_table2.

*************************
  IF g_mode = 'CHA'.

    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
           WHERE reqno = zmm_nmblkcdhd_st-reqno.
*** Check for deletion.
    IF l_hd_reqno-lvorm = 'X'.
      MESSAGE i087(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
      LEAVE TO SCREEN 100.
    ENDIF.
***To check for original creator........
    IF l_hd_reqno-reqcpf <> sy-uname.
      MESSAGE e096(zmm_oth) WITH l_hd_reqno-reqcpf.
    ENDIF.
*** To check for C/AC/IC request.
    IF l_hd_reqno-status = 'C' OR
       l_hd_reqno-status = 'AC'.
      MESSAGE e104(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
    ENDIF.
    IF l_hd_reqno-status = 'IC'.
      MESSAGE e112(zmm_oth) WITH zmm_nmblkcdhd_st-reqno.
    ENDIF.

***Check for Release reset
    IF l_hd_reqno-relflag = 'X' .
***Change option
     CALL FUNCTION 'K_KKB_POPUP_RADIO2'
        EXPORTING
          i_title         =  'Change Options'
          i_text1         =  'Attach Doc (No release reset)'
          i_text2         =  'Any Change (Release reset)'
          i_default       =  1
       IMPORTING
         I_RESULT        =   g_result
       EXCEPTIONS
           CANCEL        = 1
           OTHERS        = 2.
      IF sy-subrc <> 0.
         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF g_result = '2'.
        g_relflag = 'J'.
        zmm_nmblkcdhd_st-relflag = ''.
        zmm_nmblkcdhd_st-appflag = ''.
      ENDIF.
    ENDIF.
  ELSEIF g_mode = 'REL'.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-reqcpf <> sy-uname.
        MESSAGE e107(zmm_oth) WITH l_hd_reqno-reqcpf.
      ENDIF.
      IF NOT l_hd_reqno-relflag IS INITIAL.
        MESSAGE e125(zmm_oth) WITH l_hd_reqno-reqno.
      ENDIF.
    ENDIF.

  ELSEIF g_mode = 'APR'.
****authority Check
    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
                  ID 'FRGCO' FIELD 'L1'. "#EC *

    IF sy-subrc <> 0.
      MESSAGE e123(zmm_oth).
    ENDIF.
****checking the release of the request.
    CLEAR l_hd_reqno.
    SELECT SINGLE * INTO l_hd_reqno FROM zmm_nmblkcdhd
          WHERE reqno = zmm_nmblkcdhd_st-reqno.
    IF sy-subrc = 0.
      IF l_hd_reqno-relflag = ''.
        MESSAGE i120(zmm_oth) WITH l_hd_reqno-reqno.
        PERFORM clear_var.
*        leave to screen 0.
      ENDIF.
      IF NOT l_hd_reqno-appflag IS INITIAL.
        MESSAGE e037(zmm_oth) WITH l_hd_reqno-reqno.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                 " check_reqno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_plant INPUT.
  DATA : l_werks LIKE t001w-werks.
  IF NOT zmm_nmblkcdhd_st-werks IS INITIAL.
    SELECT SINGLE werks INTO l_werks FROM t001w
           WHERE werks = zmm_nmblkcdhd_st-werks.
    IF sy-subrc <> 0.
      MESSAGE e033(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_tel  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_tel INPUT.
  DATA : tel_len TYPE i.
  tel_len = strlen( zmm_nmblkcdhd_st-tel ).
  IF  zmm_nmblkcdhd_st-tel CN ' 0123456789-'.
    MESSAGE e059(zmm_oth).
  ELSE.
    IF tel_len < 7.
      MESSAGE e060(zmm_oth).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_tel  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_user  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_user INPUT.
  DATA: l_user LIKE soud3,
        l_userfld(40) type c.
  Clear: l_user, l_userfld.

  get cursor field l_userfld.

  case l_userfld.
    when 'ZMM_NMBLKCDHD_ST-REQCPF'.
      l_user = zmm_nmblkcdhd_st-reqcpf.
    when 'ZMM_NMBLKCDHD_ST-RELBY'.
      l_user = zmm_nmblkcdhd_st-relby.
    when 'ZMM_NMBLKCDHD_ST-APPBY'.
      l_user = zmm_nmblkcdhd_st-appby.
  endcase.
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

ENDMODULE.                 " show_user  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.
ENDMODULE.                 " USER_COMMAND_0103  INPUT

AT USER-COMMAND.
  DATA : l_okcode103 LIKE sy-ucomm.
  CLEAR l_okcode103.

  l_okcode103 = sy-ucomm.
  IF g_mode = 'REL'.
    CASE l_okcode103.
      WHEN 'AGREE'.
        g_rel = 'Y'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
      WHEN 'DISAGREE'.
        g_rel = 'N'.
        CLEAR l_okcode103.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Module  get_details  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_details INPUT.
  DATA: l_objek LIKE ausp-objek,
        l100_blkdt LIKE zmm_nmblkcddt.

*  SELECT SINGLE objek INTO l_objek FROM ausp
*         WHERE objek = zmm_nmblkcddt-matcode
*         AND   atinn = ( SELECT atinn FROM cabn
*                                WHERE atnam = 'Z_ONGC_REASON' )
*         AND   klart = '001'
*         AND   atwrt = 'NM'.
SELECT SINGLE ZZMBPR FROM MARA INTO l_objek
  WHERE MATNR = zmm_nmblkcddt-matcode
  AND ZZMBPR = 'NM'.


  IF sy-subrc <> 0.
    MESSAGE e090(zmm_oth).
  ELSE.
    zmm_nmblkcddt-mstae = 'NM'.
  ENDIF.
  SELECT MAKTX INTO ZMM_NMBLKCDDT-MATDESC
 FROM MAKT UP TO 1 ROWS WHERE MATNR = ZMM_NMBLKCDDT-MATCODE
 ORDER BY PRIMARY KEY .
 ENDSELECT.
  SELECT SINGLE meins INTO
               zmm_nmblkcddt-uom
         FROM mara
         WHERE matnr = zmm_nmblkcddt-matcode.

***Checking for the same code in other request
  IF g_mode = 'CRE'.
    SELECT * INTO L100_BLKDT FROM ZMM_NMBLKCDDT UP TO 1 ROWS
 WHERE MATCODE = G_TCT100_WA-MATCODE AND UNBLKBY = ''
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tct100_wa-matcode l100_blkdt-reqno.
    ENDIF.
  ELSEIF g_mode = 'CHA'.
    SELECT * INTO L100_BLKDT FROM ZMM_NMBLKCDDT UP TO 1 ROWS
 WHERE REQNO <> ZMM_NMBLKCDHD_ST-REQNO AND MATCODE = G_TCT100_WA-MATCODE AND UNBLKBY = ''
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e094(zmm_oth) WITH g_tct100_wa-matcode l100_blkdt-reqno.
    ENDIF.
  ENDIF.


ENDMODULE.                 " get_details  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_req INPUT.
  PERFORM confirm_exit.
ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  show_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_code INPUT.
  DATA : l_matcode LIKE zmm_matblock_dt-matcode.

  l_matcode = zmm_nmblkcddt-matcode.
  SET PARAMETER ID 'MAT' FIELD l_matcode.
  CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.

ENDMODULE.                 " show_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME1 INPUT.
CLEAR NAME1.
IF NOT ZMM_NMBLKCDHD_ST-REQCPF IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME1
  WHERE PERNR = ZMM_NMBLKCDHD_ST-REQCPF.
  ENDIF.
ENDMODULE.                 " SHOW_NAME1  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME2 INPUT.
CLEAR NAME2.
IF NOT ZMM_NMBLKCDHD_ST-RELBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME2
  WHERE PERNR = ZMM_NMBLKCDHD_ST-RELBY.
  ENDIF.
ENDMODULE.                 " SHOW_NAME2  INPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_NAME3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_NAME3 INPUT.
CLEAR NAME3.
IF NOT ZMM_NMBLKCDHD_ST-APPBY IS INITIAL.
SELECT SINGLE ENAME FROM PA0001 INTO NAME3
  WHERE PERNR = ZMM_NMBLKCDHD_ST-APPBY.
  ENDIF.
ENDMODULE.                 " SHOW_NAME3  INPUT
