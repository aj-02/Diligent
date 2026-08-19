*--- MAIN PROGRAM: MZMMCODREQI01 ---*
************************************************************************
*  Date            Transport      USERID        Description
* 30/09/2008      <RD1K960036>    SAB_SUMODH
*
*1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
*
************************************************************************
***INCLUDE MZMMCODREQI01 .
*&spwizard: input modul for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
MODULE TABCTRL100_MARK INPUT.
  DATA: G_TABCTRL100_WA2 LIKE LINE OF IST_SRCHLP.
  IF TABCTRL100-LINE_SEL_MODE = 1.
    LOOP AT IST_SRCHLP INTO G_TABCTRL100_WA2
      WHERE MARK = 'X'.
      G_TABCTRL100_WA2-MARK = ''.
      MODIFY IST_SRCHLP
        FROM G_TABCTRL100_WA2
        TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY IST_SRCHLP
    FROM WA_SRCHLP
    INDEX TABCTRL100-CURRENT_LINE
    TRANSPORTING MARK.
ENDMODULE.                    "TABCTRL100_mark INPUT
*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
MODULE TABCTRL100_USER_COMMAND INPUT.
*  OKCODE_100 = sy-ucomm.   <<SBD - 080905>>
  GET CURSOR FIELD G_CURFIELD.
  IF G_CURFIELD = 'ZMM_CDHD_ST-MTART' .
    CASE ZMM_CDHD_ST-MTART.
      WHEN 'ZCAP'.
        DYNNR = '0130'.
      WHEN 'ZSPR'.
        DYNNR = '0120'.
      WHEN 'ZSTO'.
        DYNNR = '0110'.
      WHEN 'ZDIS'.
        DYNNR = '0140'.
      WHEN OTHERS.
        DYNNR = '0101'.
    ENDCASE.
  ENDIF.
****Calling transaction MK03 for vendor.
  READ TABLE IST_SRCHLP INTO WA_SRCHLPMK03 INDEX G_CURR_LINE_100.
*  G_MFRNR  = WA_SRCHLPMK03-MFRNR.
  G_CAPCODE = WA_SRCHLPMK03-ZZCAP_CODE.
*  IF G_CURFIELD = 'WA_SRCHLP-MFRNR'. "and g_cursor_line = sy-stepl.
*    IF NOT G_MFRNR IS INITIAL.
*      SET PARAMETER ID 'LIF' FIELD G_MFRNR.
*      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
*    ENDIF.
*  ENDIF.

****Caliing transaction MM03 for capital code
  IF G_CURFIELD = 'WA_SRCHLP-ZZCAP_CODE'. "and g_cursor_line = sy-stepl. "CHANGE BY YOGESH
    IF NOT G_CAPCODE IS INITIAL.
      SET PARAMETER ID 'MAT' FIELD WA_SRCHLPMK03-ZZCAP_CODE.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

ENDMODULE.                    "TABCTRL100_user_command INPUT

*    &spwizard: modify table
MODULE TABCTRL110_MODIFY INPUT.
  DATA : G_OTH_LEVEL.
  G_OK_CODE110 = SY-UCOMM.
  CLEAR G_FIELD.
*{   INSERT         OCPK900087                                        1

*}   INSERT

  IF ZMM_CDITEM-OTH1 = 'X' OR
     ZMM_CDITEM-OTH2 = 'X' OR
     ZMM_CDITEM-OTH3 = 'X' OR
     ZMM_CDITEM-OTH4 = 'X'.
  ELSE.
    REPLACE 'M' WITH '' INTO ZMM_CDITEM-COMP_FLG.
  ENDIF.

  MOVE-CORRESPONDING ZMM_CDITEM TO G_TABCTRL110_WA.

  CONCATENATE G_TABCTRL110_WA-OTH1 G_TABCTRL110_WA-OTH2
              G_TABCTRL110_WA-OTH3 G_TABCTRL110_WA-OTH4 INTO G_OTH.

  IF G_OK_CODE110 = 'PB_AD'.

    IF G_CURSOR_LINE = SY-STEPL.

      G_USER_DESCX = G_TABCTRL110_WA-USER_DESC.

      PERFORM POPUP_USERDESC.
      IF G_OK_CODE115 = 'OK115'.
        PERFORM GC_FIELDS_115.

      ELSEIF G_OK_CODE115 = 'CANC'.
        G_TABCTRL110_WA-USER_DESC = G_USER_DESCX.

      ENDIF.
    ENDIF.
  ENDIF.

  CASE 'X'.
    WHEN G_TABCTRL110_WA-OTH1.

      CONCATENATE 'ZMM_CDITEM-DESC' '1' INTO G_FIELD.
    WHEN G_TABCTRL110_WA-OTH2.
      CONCATENATE 'ZMM_CDITEM-DESC' '2' INTO G_FIELD.

    WHEN G_TABCTRL110_WA-OTH3.
      CONCATENATE 'ZMM_CDITEM-DESC' '3' INTO G_FIELD.

    WHEN G_TABCTRL110_WA-OTH4.
      CONCATENATE 'ZMM_CDITEM-DESC' '4' INTO G_FIELD.

    WHEN OTHERS.

  ENDCASE.

*commented by on 24-08-05 to change DBLCLK behaviour in CHANGE mode.
*  if g_mode = 'CHA' and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' )
*     and  g_field = g_curfield and g_cursor_line = sy-stepl.
**   and
**        TABCTRL110_wa-oth1 = 'X' or
**        g_TABCTRL110_wa-oth2 = 'X'  or
**        g_TABCTRL110_wa-oth3 = 'X'  or
**        g_TABCTRL110_wa-oth4 = 'X' )
**
*    g_desc1 = g_tabctrl110_wa-desc1.
*    g_desc2 = g_tabctrl110_wa-desc2.
*    g_desc3 = g_tabctrl110_wa-desc3.
*    g_desc4 = g_tabctrl110_wa-desc4.
*    g_matgp = g_tabctrl110_wa-matgp.
*    select single WGBEZ from T023T into g_matgp_desc where MATKL =
*    g_matgp and spras = sy-langu.
*    if sy-subrc <> 0.
*      g_matgp = ''.
*    Endif.
*    G_USER_DESC = g_tabctrl110_wa-user_desc.
*    Perform popup_userdesc.
*    clear g_field.
*    If g_ok_code115 = 'OK115'.
*      Perform GC_Fields_115.
**          g_tabctrl110_wa-oth1 = ''.
*    Endif.
*
*  Endif.
* END: commented by on 24-08-05 to change DBLCLK behaviour in
* CHANGE mode.

  IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
    G_MATCODE = ZMM_CDITEM-MATCODE.
    IF NOT G_MATCODE IS INITIAL.
      SET PARAMETER ID 'MAT' FIELD G_MATCODE.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

*  PERFORM attrib_parno.

  IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND G_CURSOR_LINE = SY-STEPL.

    IF TABCTRL110_CHECK_FLAG = 'X'.
      G_HITS_PAR = '1'.
    ENDIF.

    DESC11 = G_TABCTRL110_WA-DESC1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.
    IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
        AND TABCTRL110_CHECK_FLAG = 'X'.
      G_HITS_PAR = '1'.
      IF G_OK_CODE115 <> 'OK115'.
        CLEAR  TABCTRL110_CHECK_FLAG.
      ENDIF.
    ENDIF.
    IF NOT G_TABCTRL110_WA-MATGP IS INITIAL.
      G_MATGP = G_TABCTRL110_WA-MATGP.
    ELSE.
      GET PARAMETER ID 'ZMATGP' FIELD G_MATGP .
      G_TABCTRL110_WA-MATGP = G_MATGP .
    ENDIF.
    IF G_TABCTRL110_WA-DESC1 <> 'OTHER'.
      PERFORM TABCTRL110_DESC1_CHECK.
      IF TABCTRL110_CHECK_FLAG = 'X'.
        G_HITS_PAR = '1'.
      ENDIF.
    ENDIF.
    IF G_TABCTRL110_WA-DESC1 = 'OTHER'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      G_TABCTRL110_WA-OTH1 = 'X'.
      G_HITS_PAR = '4'.
      G_HITS_PAR_OTH = 'X'.
      PERFORM POPUP_USERDESC.
      IF G_OK_CODE115 = 'OK115'.
        PERFORM GC_FIELDS_115.
      ENDIF.
      PERFORM MOVE_DESCRIPTIONS.
    ELSEIF G_TABCTRL110_WA-OTH1 = 'X'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      G_HITS_PAR = '4'.
      G_HITS_PAR_OTH = 'X'..
      DESCP1 = G_TABCTRL110_WA-DESC1.
    ELSE.
      CLEAR G_TABCTRL110_WA-OTH1.
      DESCP1 = G_TABCTRL110_WA-DESC1.
    ENDIF.
    CHECK_POS = '1'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-DESC2' AND G_CURSOR_LINE = SY-STEPL..
    G_MATGP = G_TABCTRL110_WA-MATGP.
    G_TABCTRL110_WA-DESC1 = ZMM_CDITEM-DESC1.
    DESCP1 = G_TABCTRL110_WA-DESC1.
    IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
       AND TABCTRL110_CHECK_FLAG = 'X'.
      G_HITS_PAR = '2'.
*      clear : g_TABCTRL110_wa-desc3,
*              g_TABCTRL110_wa-desc4,
*              g_TABCTRL110_wa-oth3,
*              g_TABCTRL110_wa-oth4,
*              g_TABCTRL110_wa-user_desc,
*              TABCTRL110_check_flag.
    ENDIF.
    SET PARAMETER ID 'ZDESC_1' FIELD G_TABCTRL110_WA-DESC1.
    IF G_TABCTRL110_WA-DESC2 <> 'OTHER'.
      PERFORM TABCTRL110_DESC2_CHECK.
      IF TABCTRL110_CHECK_FLAG = 'X'.
        G_HITS_PAR = '2'.
      ENDIF.
    ENDIF.
    IF G_TABCTRL110_WA-DESC2 = 'OTHER'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      G_TABCTRL110_WA-OTH2 = 'X'.
      G_HITS_PAR_OTH = 'X'.
      G_HITS_PAR = '4'.
      PERFORM POPUP_USERDESC.
      IF G_OK_CODE115 = 'OK115'.
        PERFORM GC_FIELDS_115.
      ENDIF.
      PERFORM MOVE_DESCRIPTIONS.
    ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      CLEAR G_HITS_PAR.
      DESCP2 = G_TABCTRL110_WA-DESC2.
    ELSE.
      CLEAR G_TABCTRL110_WA-OTH2.
      DESCP2 = G_TABCTRL110_WA-DESC2.
    ENDIF.
    FIELD1 = 'ZMM_CDITEM-DESC2'.
    CHECK_POS = '2'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-DESC3' AND G_CURSOR_LINE = SY-STEPL.
    G_MATGP = G_TABCTRL110_WA-MATGP.
    DESCP1 = G_TABCTRL110_WA-DESC1.
    DESCP2 = G_TABCTRL110_WA-DESC2.
    IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
       AND TABCTRL110_CHECK_FLAG = 'X'.
      G_HITS_PAR = '3'.
*      clear : g_TABCTRL110_wa-desc4,
*              g_TABCTRL110_wa-oth4,
*              g_TABCTRL110_wa-user_desc,
*              TABCTRL110_check_flag.
    ENDIF.
    IF G_TABCTRL110_WA-DESC3 <> 'OTHER'.
      PERFORM TABCTRL110_DESC3_CHECK.
      IF TABCTRL110_CHECK_FLAG = 'X'.
        G_HITS_PAR = '3'.
      ENDIF.
    ENDIF.
    IF G_TABCTRL110_WA-DESC3 = 'OTHER'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      G_TABCTRL110_WA-OTH3 = 'X'.
      G_HITS_PAR_OTH = 'X'.
      G_HITS_PAR = '4'.
      PERFORM POPUP_USERDESC.
      IF G_OK_CODE115 = 'OK115'.
        PERFORM GC_FIELDS_115.
      ENDIF.
      PERFORM MOVE_DESCRIPTIONS.
    ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      CLEAR G_HITS_PAR.
      DESCP3 = G_TABCTRL110_WA-DESC3.
    ELSE.
      CLEAR G_TABCTRL110_WA-OTH3.
      DESCP3 = G_TABCTRL110_WA-DESC3.
    ENDIF.

    FIELD1 = 'ZMM_CDITEM-DESC3'.
    CHECK_POS = '3'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-DESC4' AND G_CURSOR_LINE = SY-STEPL.
    G_MATGP = G_TABCTRL110_WA-MATGP.
    DESCP1 = G_TABCTRL110_WA-DESC1.
    DESCP2 = G_TABCTRL110_WA-DESC2.
    DESCP3 = G_TABCTRL110_WA-DESC3.
    IF G_TABCTRL110_WA-DESC4 <> 'OTHER'.
      PERFORM TABCTRL110_DESC4_CHECK.
      IF TABCTRL110_CHECK_FLAG = 'X'.
        G_HITS_PAR = '4'.
      ENDIF.
    ENDIF.
    IF G_TABCTRL110_WA-DESC4 = 'OTHER'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      G_TABCTRL110_WA-OTH4 = 'X'.
      G_HITS_PAR_OTH = 'X'.
      G_HITS_PAR = '4'.
      PERFORM POPUP_USERDESC.
      IF G_OK_CODE115 = 'OK115'.
        PERFORM GC_FIELDS_115.
      ENDIF.
      PERFORM MOVE_DESCRIPTIONS.

      G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
    ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
      DO_NOT_CHANGE_FLAG1 = 'X'.
      CLEAR G_HITS_PAR.
      DESCP4 = G_TABCTRL110_WA-DESC4.
    ELSE.
      CLEAR G_TABCTRL110_WA-OTH4.
      DESCP4 = G_TABCTRL110_WA-DESC4.
    ENDIF.
    FIELD1 = 'ZMM_CDITEM-DESC4'.
    CHECK_POS = '4'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND G_CURSOR_LINE = SY-STEPL.
    DESCP5 = G_TABCTRL110_WA-USER_DESC.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    CHECK_POS = '5'.
  ENDIF.
****Addition for Copy of Description**********************************
  IF G_CURFIELD = 'ZMM_CDITEM-DESC_CDCELL' AND G_CURSOR_LINE = SY-STEPL.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
*    check_pos = '5'.
  ENDIF.
****End                             **********************************

  IF G_TABCTRL110_WA-COMP_FLG IS INITIAL AND
     NOT G_TABCTRL110_WA-RSN IS INITIAL.
    MOVE SPACE TO G_TABCTRL110_WA-RSN.
  ELSEIF NOT G_TABCTRL110_WA-COMP_FLG IS INITIAL.
    CLEAR WA_RSN.
    SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
   WHERE REASON = G_TABCTRL110_WA-COMP_FLG.
    G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
    CLEAR WA_RSN.
  ENDIF.
* for codifier
*
  CONCATENATE G_TABCTRL110_WA-DESC1
                G_TABCTRL110_WA-DESC2
                G_TABCTRL110_WA-DESC3
                G_TABCTRL110_WA-DESC4
                G_TABCTRL110_WA-USER_DESC
           INTO G_TABCTRL110_WA-DESC_FIN
           SEPARATED BY SPACE.

  CONDENSE G_TABCTRL110_WA-DESC_FIN.
  MODIFY G_TABCTRL110_ITAB
    FROM G_TABCTRL110_WA
    INDEX TABCTRL110-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR
       G_TABCTRL110_WA-DESC2 = 'OTHER' OR
       G_TABCTRL110_WA-DESC3 = 'OTHER' OR
       G_TABCTRL110_WA-DESC4 = 'OTHER'.
    ELSE.
      APPEND G_TABCTRL110_WA TO G_TABCTRL110_ITAB.
    ENDIF.
  ENDIF.
  IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
         AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
    PERFORM GET_SRNO.
  ENDIF.
ENDMODULE.                    "TABCTRL110_modify INPUT

*&spwizard: mark table
MODULE TABCTRL110_MARK INPUT.
  IF TABCTRL110-LINE_SEL_MODE = 1 AND
     G_TABCTRL110_WA-FLAG = 'X'.
    LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
      WHERE FLAG = 'X'.
      G_TABCTRL110_WA-FLAG = ''.
      MODIFY G_TABCTRL110_ITAB
        FROM G_TABCTRL110_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABCTRL110_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABCTRL110_ITAB
    FROM G_TABCTRL110_WA
    INDEX TABCTRL110-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABCTRL110_mark INPUT

*&spwizard: input module for tc 'TABCTRL110'. do not change this line!
*&spwizard: process user command
MODULE TABCTRL110_USER_COMMAND INPUT.

  IF CHECK_POS = '1'.

    SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
    SET PARAMETER ID 'ZDESC_2' FIELD ''.
    SET PARAMETER ID 'ZDESC_3' FIELD ''.
    SET PARAMETER ID 'ZDESC_4' FIELD ''.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '2'.

    SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
    SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
    SET PARAMETER ID 'ZDESC_3' FIELD ''.
    SET PARAMETER ID 'ZDESC_4' FIELD ''.

    DESC11 = DESCP1.
    DESC22 = DESCP2.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '3'.

    SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
    SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
    SET PARAMETER ID 'ZDESC_3' FIELD DESCP3.
    SET PARAMETER ID 'ZDESC_4' FIELD ''.

    DESC11 = DESCP1.
    DESC22 = DESCP2.
    DESC33 = DESCP3.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '4'.

    SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
    SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
    SET PARAMETER ID 'ZDESC_3' FIELD DESCP3.
    SET PARAMETER ID 'ZDESC_4' FIELD DESCP4.

    DESC11 = DESCP1.
    DESC22 = DESCP2.
    DESC33 = DESCP3.
    DESC44 = DESCP4.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '5'.

    CASE G_PARNO.
      WHEN '2'.
        CLEAR DESCP3.
        CLEAR DESCP4.
      WHEN '3'.
        CLEAR DESCP4.
    ENDCASE.

    DESC11 = DESCP1.
    DESC22 = DESCP2.
    DESC33 = DESCP3.
    DESC44 = DESCP4.
    DESC55 = DESCP5.

  ENDIF.

  G_LINENO = G_CURR_LINE.
  G_MATGPO = G_MATGP.

  GET CURSOR FIELD G_CURFIELD.

ENDMODULE.                    "TABCTRL110_user_command INPUT

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL130_MODIFY INPUT.
  ZMM_CDITEM-UOM = 'NO'.
*
  IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
    G_MATCODE = ZMM_CDITEM-MATCODE.
    IF NOT G_MATCODE IS INITIAL.
      SET PARAMETER ID 'MAT' FIELD G_MATCODE.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

*
  MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL130_WA.
  MODIFY G_TABLCTRL130_ITAB
       FROM G_TABLCTRL130_WA
         INDEX TABLCTRL130-CURRENT_LINE.

  IF SY-SUBRC <> 0 .
    IF G_MODE = 'CRE' .
      APPEND G_TABLCTRL130_WA TO G_TABLCTRL130_ITAB.
    ELSE.
      IF G_MODE = 'CHA' AND ZMM_CDITEM-SRNO = '' AND OKCODE_100 = 'SAV'.
      ELSE.
        APPEND G_TABLCTRL130_WA TO G_TABLCTRL130_ITAB.
      ENDIF.
    ENDIF.
  ENDIF.

  IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
         AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
    PERFORM GET_SRNO.
  ENDIF.

ENDMODULE.                    "TABLCTRL130_modify INPUT

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL130_MARK INPUT.
  IF TABLCTRL130-LINE_SEL_MODE = 1 AND
     G_TABLCTRL130_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL130_WA-FLAG = ''.
      MODIFY G_TABLCTRL130_ITAB
        FROM G_TABLCTRL130_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL130_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL130_ITAB
    FROM G_TABLCTRL130_WA
    INDEX TABLCTRL130-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL130_mark INPUT

*&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL130_USER_COMMAND INPUT.

  IF CHECK_POS = '1'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '5'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = DESCP5.
  ENDIF.

ENDMODULE.                    "TABLCTRL130_user_command INPUT

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL140_MODIFY INPUT.
  MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL140_WA.
  IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND SY-STEPL = G_CURR_LINE.
    DESCP1 = G_TABLCTRL140_WA-DESC1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.
    IF G_TABLCTRL140_WA-DESC1 <> 'OTHER'.
      PERFORM TABLCTRL140_DESC1_CHECK.
    ENDIF.
    IF G_TABLCTRL140_WA-DESC1 = 'OTHER'.
      G_TABLCTRL140_WA-OTH1 = 'X'.
      PERFORM POPUP_USERDESC.
      G_TABLCTRL140_WA-USER_DESC = G_USER_DESC.
    ELSEIF G_TABLCTRL140_WA-OTH1 = 'X'.
      DESCP1 = G_TABLCTRL140_WA-DESC1.
    ELSE.
      CLEAR G_TABLCTRL140_WA-OTH1.
      DESCP1 = G_TABLCTRL140_WA-DESC1.
    ENDIF.
    CHECK_POS = '1'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND SY-STEPL = G_CURR_LINE.
    DESCP5 = G_TABLCTRL140_WA-USER_DESC.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    CHECK_POS = '5'.
  ENDIF.

  MODIFY G_TABLCTRL140_ITAB
    FROM G_TABLCTRL140_WA
    INDEX TABLCTRL140-CURRENT_LINE.
*
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL140_WA TO G_TABLCTRL140_ITAB.
  ENDIF.
*
  IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
    AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
    PERFORM GET_SRNO.
  ENDIF.

ENDMODULE.                    "TABLCTRL140_modify INPUT

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL140_MARK INPUT.
  IF TABLCTRL140-LINE_SEL_MODE = 1 AND
     G_TABLCTRL140_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL140_WA-FLAG = ''.
      MODIFY G_TABLCTRL140_ITAB
        FROM G_TABLCTRL140_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL140_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL140_ITAB
    FROM G_TABLCTRL140_WA
    INDEX TABLCTRL140-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL140_mark INPUT

*&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL140_USER_COMMAND INPUT.
  IF CHECK_POS = '1'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '5'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = DESCP5.
  ENDIF.

  G_LINENO = G_CURR_LINE.

ENDMODULE.                    "TABLCTRL140_user_command INPUT

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL120_MODIFY INPUT.
  G_SH_PARTNO = 'X'.
  MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL120_WA.

*  SELECT SINGLE ATINN FROM CABN INTO G_ATINN WHERE
*  ATNAM = 'Z_ONGC_GROUP_OF_SPARES'.
*
*  SELECT SINGLE ATWRT FROM AUSP INTO G_ATWRT WHERE
*  OBJEK = G_TABLCTRL120_WA-CAP_CODE AND ATINN = G_ATINN.

   SELECT SINGLE ZZMAGR FROM MARA INTO G_ZZMAGR WHERE MATNR = G_TABLCTRL120_WA-CAP_CODE.

   G_TABLCTRL120_WA-MATGP = G_ZZMAGR.

*  CLEAR G_ATINN.

*
  IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
    G_MATCODE = ZMM_CDITEM-MATCODE.
    IF NOT G_MATCODE IS INITIAL.
      SET PARAMETER ID 'MAT' FIELD G_MATCODE.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

****Calling transaction MK03 for vendor.

  IF SY-TCODE = 'ZCODG'.

    G_MFRNR  = ZMM_CDITEM-MANU.

    IF G_CURFIELD = 'ZMM_CDITEM-MANU'. "and g_cursor_line = sy-stepl.
      IF NOT G_MFRNR IS INITIAL.

"Begin of atc correction on 29.04.2026

*        SET PARAMETER ID 'LIF' FIELD G_MFRNR.
*        CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
        DATA(l_vend) = CONV lifnr( g_mfrnr ).
        SELECT PARTNER FROM V_CVI_VEND_LINK
 INTO @DATA(LV_PARTNER) UP TO 1 ROWS WHERE LIFNR = @L_VEND
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          IF sy-subrc IS INITIAL.

       DATA(request) = NEW cl_bupa_navigation_request( ).
        request->set_partner_number( lv_partner ).     " import your BP number here
        CALL METHOD request->set_bupa_activity
          EXPORTING
            iv_value = request->gc_activity_display.

       DATA(options) = NEW cl_bupa_dialog_joel_options( ).
          options->set_navigation_disabled( abap_true ).
          cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
                                                      iv_options = options ).
          ENDIF.
"End of atc correction on 29.04.2026

      ENDIF.
    ENDIF.

  ENDIF.

*
  IF G_CURFIELD = 'ZMM_CDITEM-PARTNO' AND SY-STEPL = G_CURSOR_LINE.
    IF G_PARTNOC <> G_TABLCTRL120_WA-PARTNO.
      CLEAR : G_TABLCTRL120_WA-DESC1,
              G_TABLCTRL120_WA-OTH1,
              G_TABLCTRL120_WA-USER_DESC.
    ENDIF.
    G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
    FIELD1 = 'ZMM_CDITEM-PARTNO'.
    IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' ) .
      CLEAR : G_TABCTRL110_WA-DESC1,DESCP1.
    ENDIF.
    CHECK_POS = '0'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND SY-STEPL = G_CURSOR_LINE.
    DESCP1 = G_TABLCTRL120_WA-DESC1.
    FIELD1 = 'ZMM_CDITEM-DESC1'.

    IF G_TABLCTRL120_WA-DESC1 <> 'OTHER'.
      PERFORM TABLCTRL120_DESC1_CHECK.
    ENDIF.
    IF G_TABLCTRL120_WA-DESC1 = 'OTHER'.
      G_TABLCTRL120_WA-OTH1 = 'X'.
      PERFORM POPUP_USERDESC.
      G_TABLCTRL120_WA-USER_DESC = G_USER_DESC.
    ELSEIF G_TABLCTRL120_WA-OTH1 = 'X'.
      G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
    ELSE.
      CLEAR G_TABLCTRL120_WA-OTH1.
      G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
    ENDIF.
    CHECK_POS = '1'.
  ENDIF.

  IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND SY-STEPL = G_CURSOR_LINE.
    DESCP5 = G_TABLCTRL120_WA-USER_DESC.
    FIELD1 = 'ZMM_CDITEM-USER_DESC'.
    CHECK_POS = '5'.
  ENDIF.

  MODIFY G_TABLCTRL120_ITAB
    FROM G_TABLCTRL120_WA
    INDEX TABLCTRL120-CURRENT_LINE.

*
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL120_WA TO G_TABLCTRL120_ITAB.
  ENDIF.
*
  IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
      AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
    PERFORM GET_SRNO.
  ENDIF.

  G_LINENO = G_CURR_LINE.



"added by lipsy on 0n 05.09.2012 <RD1K979105> to get vendor name

if g_mode = 'CRE' OR g_mode = 'CHA'.
     REFRESH:itab_lfa1.

  if g_TABLCTRL120_itab is not INITIAL.
  select lifnr name1
       FROM lfa1
       INTO CORRESPONDING FIELDS OF TABLE  itab_lfa1
       FOR ALL ENTRIES IN g_TABLCTRL120_itab
       WHERE lifnr =  g_TABLCTRL120_itab-manu.
  endif.

  CLEAR:WA_LFA1.

      READ TABLE itab_lfa1 INTO wa_lfa1 with key lifnr = g_TABLCTRL120_wa-manu.
       g_TABLCTRL120_wa-name1 = wa_lfa1-name1.
       MODIFY  g_TABLCTRL120_itab FROM g_TABLCTRL120_wa
        TRANSPORTING name1
        where manu = g_TABLCTRL120_wa-manu .
ENDIF.
 "end of addition on 05.09.2012
ENDMODULE.                    "TABLCTRL120_modify INPUT

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL120_MARK INPUT.
  IF TABLCTRL120-LINE_SEL_MODE = 1 AND
     G_TABLCTRL120_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL120_WA-FLAG = ''.
      MODIFY G_TABLCTRL120_ITAB
        FROM G_TABLCTRL120_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL120_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL120_ITAB
    FROM G_TABLCTRL120_WA
    INDEX TABLCTRL120-CURRENT_LINE
    TRANSPORTING FLAG.

ENDMODULE.                    "TABLCTRL120_mark INPUT

*&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL120_USER_COMMAND INPUT.

  IF CHECK_POS = '0'.

    DESC11 = ''.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.
*
    IF FIELD1 = 'ZMM_CDITEM-PARTNO' AND
       SY-UCOMM = 'DBLCLK' OR SY-UCOMM = ''.
      G_CURS_LN = G_CURR_LINE_120.
      CLEAR : G_SH_CAPEQT,G_SH_MDLNO,G_SH_MFR,G_FST_SRCHLP.
      REFRESH: IST_SRCHLP_CPO.
    ENDIF.
*

  ENDIF.


  IF CHECK_POS = '1'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = ''.

  ENDIF.

  IF CHECK_POS = '5'.

    DESC11 = DESCP1.
    DESC22 = ''.
    DESC33 = ''.
    DESC44 = ''.
    DESC55 = DESCP5.
  ENDIF.

  OK_CODE = SY-UCOMM.

  IF OK_CODE = 'SAV' AND G_LINENO <> 0.

    PERFORM GET_MAT_FIND.

  ENDIF.

  PERFORM USER_OK_TC USING    'TABLCTRL120'
                              'G_TABLCTRL120_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
*
*perform get_cursor120.
*


ENDMODULE.                    "TABLCTRL120_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.
  DATA : L_ANS1.
  CASE OKCODE_100.
    WHEN 'BAC' OR 'CAN'.
      IF SY-TCODE = 'ZCODG'.
        PERFORM EXIT_CONFIRM.
      ENDIF.
      PERFORM BAC_CONFIRM.
      REFRESH IST_SRCHLP.
      REFRESH CONTROL 'TABCTRL100' FROM SCREEN '0100'.
      CLEAR G_CURR_LINE_120.
      CLEAR OKCODE_100.
    WHEN 'CR_MATCODE'.
      G_MODE = 'CRC'.
      IF NOT DYNNR IS INITIAL.
        PERFORM CREATE_MATCODE.
*        IF zmm_cdhd_st-reqcl = 'C' or
*           zmm_cdhd_st-reqcl = 'IR'.
*           perform send_mail_to_reqn.
*        ENDIF.
      ENDIF.
      CLEAR OKCODE_100.
    WHEN 'CREATE'.
      G_MODE = 'CRE'.
      CLEAR OKCODE_100.
    WHEN 'CHANGE'.
      G_MODE = 'CHA'.
      CLEAR OKCODE_100.
    WHEN 'DISPLAY'.
      G_MODE = 'DIS'.
      CLEAR OKCODE_100.
    WHEN 'DELETE'.
      G_MODE = 'DEL'.
      CLEAR OKCODE_100.
    WHEN 'SAV'.
      CLEAR OKCODE_100.   "gcu 24-10-05
      IF NOT ZMM_CDHD_ST-MTART IS INITIAL.
        PERFORM CHECK_ITEMS.
        PERFORM CHECK_DUPL_REC1.  "+
        IF NOT G_CDITEM_ITAB IS INITIAL.
          G_SAVEFLAG = 'N'.
          CLEAR G_CDITEM.
          REFRESH G_CDITEM_ITAB.
        ENDIF.
        IF G_SAVEFLAG = 'Y' AND G_CHECK_FLAG = ''.
          PERFORM SAVE_REQUEST.
        ELSE.
          MESSAGE I075(ZMM_OTH).
          CLEAR G_CHECK_FLAG.
        ENDIF.
      ENDIF.
      CLEAR OKCODE_100.
      CLEAR G_CURR_LINE_120.
      IF SY-TCODE = 'ZCODG'.
*        IF zmm_cdhd_st-reqcl = 'C' or
*           zmm_cdhd_st-reqcl = 'IR'.
*           perform send_mail_to_reqn.
*        ENDIF.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'RELEASE'.
      G_MODE = 'REL'.
      CLEAR OKCODE_100.
    WHEN 'APPROVE'.
      G_MODE = 'APR'.
      CLEAR OKCODE_100.
    WHEN 'DD'.
      PERFORM DISPLAY_TEXT.
      CLEAR OKCODE_100.
    WHEN 'REMLT'.
      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
      CLEAR OKCODE_100.
    WHEN 'INS_MODI'.
      PERFORM INSERT_MODIF.
      CLEAR OKCODE_100.
    WHEN 'SPELL'.

      IF ZMM_CDHD_ST-MTART = 'ZSTO'.
        PERFORM SPELL_CHECK1.
        PERFORM MODI_CHECK.
        CLEAR OKCODE_100.
      ELSEIF ZMM_CDHD_ST-MTART = 'ZSPR'.
        PERFORM SPELL_CHECK2.
        CLEAR OKCODE_100.
      ELSEIF ZMM_CDHD_ST-MTART = 'ZCAP'.
        PERFORM SPELL_CHECK3.
        CLEAR OKCODE_100.
      ENDIF.
    WHEN 'INS_MDL'.
      PERFORM INSERT_MDLNO. "ZSPR
      CLEAR OKCODE_100.
    WHEN 'REQLT'.
**Addition*******************************************<<SK18112005>>
      IF G_MODE = 'CRE' OR
          G_MODE = 'CHA'.
****End********************************************<<SK18112005>>
        G_DSTEXT = 'The detailed specifications will default in PR/PO.Continue?'.
        " Begin of <RD1K960036>.

*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*            DEFAULTOPTION  = 'N'
*            TEXTLINE1      = g_dstext
*            TITEL          = 'Confirm-Detail Specification'
*            START_COLUMN   = 25
*            START_ROW      = 6
*            CANCEL_DISPLAY = ''
*          IMPORTING
*            ANSWER         = g_dschoice.
        DATA : L_GET12(1) TYPE C.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR       = 'Confirm-Detail Specification'
            TEXT_QUESTION  = G_DSTEXT
            DEFAULT_BUTTON = '2'
            START_COLUMN   = 25
            START_ROW      = 6
          IMPORTING
            ANSWER         = L_GET12
          EXCEPTIONS
            TEXT_NOT_FOUND = 1
            OTHERS         = 2.
        IF SY-SUBRC = 0.
          CASE L_GET12.
            WHEN '1'.
              MOVE 'J' TO G_DSCHOICE.
            WHEN '2'.
              MOVE 'N' TO G_DSCHOICE.
          ENDCASE.
        ENDIF.
        " End of <RD1K960036>.
        IF G_DSCHOICE = 'J'.
          PERFORM LTXTDTSP.
        ENDIF.
**Addition*******************************************<<SK18112005>>
      ELSE.
        PERFORM LTXTDTSP.
      ENDIF.
****End********************************************<<SK18112005>>
      CLEAR OKCODE_100.
    WHEN 'MODNO' OR 'CAPEQT' OR 'MFR'.

      READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
      INDEX G_CURS_LN.
      REFRESH IST_SRCHLP_CP.
      APPEND LINES OF IST_SRCHLP_CPO TO IST_SRCHLP_CP.
      PERFORM SRCHLP_SPR_DEL.
      CLEAR OKCODE_100.

*** CAB_AJIT 03.02.2006 ************
    WHEN 'EXPORT'.
      PERFORM EXPORT_DATA.
      CLEAR OKCODE_100.
************************************
    WHEN 'CPMC'.
      " Begin of <RD1K960036>.

*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*         DEFAULTOPTION         = 'Y'
*          TEXTLINE1            = 'You are about to copy existing'
*          TEXTLINE2            = 'Material Code. Continue?'
*          TITEL                = 'Copy Existing Material Code'
*          START_COLUMN         = 25
*          START_ROW            = 6
**         CANCEL_DISPLAY       = 'X'
*       IMPORTING
*          ANSWER               = l_ans1 .
      DATA : L_GET13(1) TYPE C.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR       = 'Copy Existing Material Code '
          TEXT_QUESTION  = 'You are about to copy existing Material Code. Continue?'
          DEFAULT_BUTTON = '1'
          START_COLUMN   = 25
          START_ROW      = 6
        IMPORTING
          ANSWER         = L_GET13
        EXCEPTIONS
          TEXT_NOT_FOUND = 1
          OTHERS         = 2.
      IF SY-SUBRC = 0.
        CASE L_GET13.
          WHEN '1'.
            MOVE 'J' TO L_ANS1 .
          WHEN '2'.
            MOVE 'N' TO L_ANS1 .
        ENDCASE.
      ENDIF.
      " End of <RD1K960036>.
      CHECK L_ANS1 = 'J'.
      CLEAR L_ANS1.

* G_SRNO is being picked up thru Perform get_srno.
      READ TABLE IST_SRCHLP INTO WA_SRCHLP WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        CASE ZMM_CDHD_ST-MTART.
          WHEN 'ZSTO'.
            READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
                                           WITH KEY SRNO = G_SRNO.
            IF SY-SUBRC = 0.
              G_TABCTRL110_WA-MATCODE = WA_SRCHLP-MATNR.
              WA_SRCHLP-MARK = ''.
              G_TABCTRL110_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
              G_TABCTRL110_WA-COMP_FLG = 'A'.

              MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA
                    INDEX SY-TABIX TRANSPORTING COMP_FLG
                                                MATCODE HAZ.
              MODIFY  IST_SRCHLP FROM WA_SRCHLP
                       TRANSPORTING MARK WHERE MARK = 'X'.
            ENDIF.
*
          WHEN 'ZSPR'.
            READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
                                            WITH KEY SRNO = G_SRNO.
            IF SY-SUBRC = 0.
*
              G_TABLCTRL120_WA-MATCODE = WA_SRCHLP-MATNR.
              G_TABLCTRL120_WA-FLAG = ''.
              G_TABLCTRL120_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
              G_TABLCTRL120_WA-COMP_FLG = 'A'.
              MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
                    INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE
                                                     HAZ.
              CLEAR G_TABLCTRL120_WA.
            ENDIF.

*
          WHEN 'ZCAP'.
            READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
                                         WITH KEY SRNO = G_SRNO.
            IF SY-SUBRC = 0.
*
              G_TABLCTRL130_WA-MATCODE = WA_SRCHLP-MATNR.
*
              G_TABLCTRL130_WA-DESC_CDCELL = WA_SRCHLP-MAKTX.
              G_TABLCTRL130_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
              G_TABLCTRL130_WA-COMP_FLG = 'A'.
              MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
                    INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE
                                                DESC_CDCELL HAZ.
              CLEAR G_TABLCTRL130_WA.
            ENDIF.

*
        ENDCASE.
*
      ELSE.
        MESSAGE I040(ZMM_OTH) WITH 'from Search Help Table'.
      ENDIF.
    WHEN 'UNDO_CPMC'.
      " Begin of <RD1K960036>.
*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*         DEFAULTOPTION         = 'Y'
*          TEXTLINE1            = 'You are about to remove existing'
*          TEXTLINE2            = 'Material Code. Continue?'
*          TITEL                = 'Remove Existing Material Code'
*          START_COLUMN         = 25
*          START_ROW            = 6
**         CANCEL_DISPLAY       = 'X'
*       IMPORTING
*          ANSWER               = l_ans1 .

      DATA : L_GET14(1) TYPE C.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Remove Existing Material Code'
          TEXT_QUESTION         = 'You are about to remove existing Material Code. Continue?'
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = 'X'
          START_COLUMN          = 25
          START_ROW             = 6
        IMPORTING
          ANSWER                = L_GET14
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.
      IF SY-SUBRC = 0.
        CASE L_GET14.
          WHEN '1'.
            MOVE 'J' TO L_ANS1 .
          WHEN '2'.
            MOVE 'N' TO L_ANS1 .
        ENDCASE.
      ENDIF.
      " End of <RD1K960036>.
      CHECK L_ANS1 = 'J'.
      CLEAR L_ANS1.
      CASE ZMM_CDHD_ST-MTART.
        WHEN 'ZSTO'.
          READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
                                         WITH KEY FLAG = 'X'.
          IF SY-SUBRC = 0 AND G_TABCTRL110_WA-COMP_FLG = 'A'.
            G_TABCTRL110_WA-MATCODE = ''.
            G_TABCTRL110_WA-FLAG = ''.
            G_TABCTRL110_WA-COMP_FLG = G_TABCTRL110_WA-HAZ.
            MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA
                  INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE.
          ELSE.
            MESSAGE I040(ZMM_OTH).
          ENDIF.
*
        WHEN 'ZSPR'.
          READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
                                          WITH KEY FLAG = 'X'.
          IF SY-SUBRC = 0 AND G_TABLCTRL120_WA-COMP_FLG = 'A'.
            G_TABLCTRL120_WA-MATCODE = ''.
            G_TABLCTRL120_WA-FLAG = ''.
            G_TABLCTRL120_WA-COMP_FLG = G_TABLCTRL120_WA-HAZ.
            MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
                 INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE .
          ELSE.
            MESSAGE I040(ZMM_OTH).
          ENDIF.

*
        WHEN 'ZCAP'.
          READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
                                       WITH KEY FLAG = 'X'.
          IF SY-SUBRC = 0 AND G_TABLCTRL130_WA-COMP_FLG = 'A'.
            G_TABLCTRL130_WA-MATCODE  = ''.
            G_TABLCTRL130_WA-DESC_CDCELL = ''.
            G_TABLCTRL130_WA-FLAG     = ''.
            G_TABLCTRL130_WA-COMP_FLG = G_TABLCTRL130_WA-HAZ.
            MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
                  INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE.
          ELSE.
            MESSAGE I040(ZMM_OTH).
          ENDIF.

*
      ENDCASE.
"ADDED BY LIPSY ON 31.08.2012 <RD1K979105> for attaching files and process guides
    when 'ATTACH'.
    perform attach_files.
    CLEAR OKCODE_100.
     WHEN 'LIST'.
     PERFORM list_files.
     CLEAR OKCODE_100.
      WHEN 'HELP'.
      PERFORM DISP_PROCESS_GUIDE.
      CLEAR OKCODE_100.
 "END OF ADDITION BY LIPSY ON 31.08.2012
  ENDCASE.
*
  OK_CODE = SY-UCOMM.
  CHECK_CODE = SY-UCOMM.

  CASE ZMM_CDHD_ST-MTART.
    WHEN 'ZSTO'.
      PERFORM USER_OK_TC USING    'TABCTRL110'
                                  'G_TABCTRL110_ITAB'
                                  'FLAG'
                         CHANGING OK_CODE.
      CLEAR: OK_CODE, SY-UCOMM.
    WHEN 'ZCAP'.
      PERFORM USER_OK_TC USING    'TABLCTRL130'
                                  'G_TABLCTRL130_ITAB'
                                  'FLAG'
                         CHANGING OK_CODE.
      CLEAR: OK_CODE,SY-UCOMM.
    WHEN 'ZDIS'.
      PERFORM USER_OK_TC USING    'TABLCTRL140'
                                  'G_TABLCTRL140_ITAB'
                                  'FLAG'
                         CHANGING OK_CODE.
      CLEAR: OK_CODE,SY-UCOMM.

  ENDCASE.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR110 INPUT.
  CLEAR TABCTRL110_CHECK_FLAG.
  G_LINENO_OLD = G_LINENO.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR FIELD G_CURFIELD110.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURRENT_LINE  = G_CURSOR_LINE.
  G_CURR_LINE = TABCTRL110-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_110 = G_CURR_LINE.

ENDMODULE.                 " get_cursor  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor120 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE GET_CURSOR120 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR FIELD G_CURFIELD120.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL120-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_120 = G_CURR_LINE .

ENDMODULE.                 " get_cursor120  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor130 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE GET_CURSOR130 INPUT.
  DATA : L_CUR_FLDVAL(88).
  DATA : L_OFFSET TYPE I.
*
  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR FIELD G_CURFIELD OFFSET L_OFFSET VALUE L_CUR_FLDVAL.

  GET CURSOR FIELD G_CURFIELD130.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL130-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_130 = G_CURR_LINE.

ENDMODULE.                 " get_cursor130  INPUT

*---------------------------------------------------------------------*
*       MODULE get_cursor140 INPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE GET_CURSOR140 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL140-TOP_LINE + G_CURSOR_LINE - 1.

ENDMODULE.                 " get_cursor140  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0115 INPUT.
  DATA : FIELD_NAME(20).
  DATA : L_ANS.
  G_OK_CODE115 = SY-UCOMM.
  CASE G_OK_CODE115 .
    WHEN  ''.                                               "+
      PERFORM GET_ATTRIB_115.
      "+
    WHEN  'CANC' OR 'RW'.       "+


      CLEAR : G_DESC1,
              G_DESC2,
              G_DESC3,
              G_DESC4,
              G_USER_DESC,                                  "=
              G_SCREEN115_1ST,
              G_MATGP.
      IF G_OK_CODE110 <> 'PB_AD'.
        CLEAR : G_USER_DESC.       "+
      ENDIF.
      IF G_DESC1 = 'OTHER'.
        CLEAR ZMM_CDITEM-DESC1.
      ELSEIF G_DESC2 = 'OTHER'.
        CLEAR ZMM_CDITEM-DESC2.
      ELSEIF G_DESC3 = 'OTHER'.
        CLEAR ZMM_CDITEM-DESC3.
      ELSEIF G_DESC4 ='OTHER'.
        CLEAR ZMM_CDITEM-DESC4.
      ENDIF.

      IF ZMM_CDITEM-OTH1 = '' AND  G_TABCTRL110_WA-OTH1 = 'X'.
        CLEAR G_TABCTRL110_WA-OTH1.
        CLEAR G_MATGP.
      ENDIF.
      IF ZMM_CDITEM-OTH2 = '' AND  G_TABCTRL110_WA-OTH2 = 'X'.
        CLEAR G_TABCTRL110_WA-OTH2.
      ENDIF.

      IF ZMM_CDITEM-OTH3 = '' AND  G_TABCTRL110_WA-OTH3 = 'X'.
        CLEAR G_TABCTRL110_WA-OTH3.
      ENDIF.

      IF ZMM_CDITEM-OTH4 = '' AND  G_TABCTRL110_WA-OTH4 = 'X'.
        CLEAR G_TABCTRL110_WA-OTH4.
      ENDIF.

*      If g_tabctrl110_wa-desc1 = 'OTHER'.
*        clear :
*               zmm_cditem-desc1,
*               g_tabctrl110_wa-desc1,
*               g_tabctrl110_wa-oth1,
*               g_tabctrl110_wa-oth2,
*               g_tabctrl110_wa-oth3,
*               g_tabctrl110_wa-oth4,
*               g_matgp.
*      Elseif  g_tabctrl110_wa-desc2 = 'OTHER'.
*        clear :
*               zmm_cditem-desc2,
*               g_tabctrl110_wa-desc2,
*               g_tabctrl110_wa-oth2.
*      Elseif  g_tabctrl110_wa-desc3 = 'OTHER'.
*         clear :
*               zmm_cditem-desc3,
*               g_tabctrl110_wa-desc3,
*               g_tabctrl110_wa-oth3.
*      Elseif g_tabctrl110_wa-desc4 = 'OTHER'.
*               Clear :
*               zmm_cditem-desc4,
*               g_tabctrl110_wa-desc4,
*               g_tabctrl110_wa-oth3.
*      Endif.

      LEAVE TO SCREEN 0.
    WHEN  'A_DESC'.
      G_SCREEN115_1ST = 'X'.
*            Perform other_check.   "+
    WHEN 'OK115'.
      PERFORM CHECK_MODI.
      PERFORM CHECK_LENGTH.
      G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
      CLEAR IST_SPELL_LINE.
      IF  G_TABCTRL110_WA-OTH1  = 'X'.
        CONCATENATE G_DESC1 G_DESC2
         G_DESC3 G_DESC4
         G_USER_DESC INTO IST_SPELL_LINE-TDLINE
         SEPARATED BY SPACE.
        G_TABCTRL110_WA-COMP_FLG = ' M'.

      ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
        CONCATENATE G_DESC2 G_DESC3 G_DESC4 G_USER_DESC INTO
        IST_SPELL_LINE-TDLINE SEPARATED BY SPACE.
        G_TABCTRL110_WA-COMP_FLG = ' M'.

      ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
        CONCATENATE G_DESC3 G_DESC4 G_USER_DESC INTO
        IST_SPELL_LINE-TDLINE SEPARATED BY SPACE.
        G_TABCTRL110_WA-COMP_FLG = ' M'.

      ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
        CONCATENATE G_DESC4
        G_USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
        BY SPACE.
        G_TABCTRL110_WA-COMP_FLG = ' M'.

      ELSE.
        REPLACE 'M' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
        IST_SPELL_LINE-TDLINE = G_USER_DESC.
      ENDIF.

      APPEND IST_SPELL_LINE.

      EXPORT G_USER TO MEMORY ID 'G_USER1' .
      CLEAR G_SPELL_ANS.     "+
      CALL FUNCTION 'ZSPELL_CHECK'
        EXPORTING
          SPRACHE = 'EN'
        TABLES
          ILINE   = IST_SPELL_LINE.

      IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.

      IF NOT CHECKTAB[] IS INITIAL.

        " Begin of <RD1K960036>.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*          EXPORTING
*          TEXTLINE1            = 'There are spelling errors in description(s)'
*
*           TEXTLINE2            = 'Proceed with errors? '
*            TITEL                = 'Spelling Errors'
*                  START_COLUMN         = 25
*                  START_ROW            = 6
*                  CANCEL_DISPLAY       = 'X'
*         IMPORTING
*           ANSWER               = l_ans.
*
*        g_spell_ans = l_ans.

        DATA : L_VALUE(1) TYPE C.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
           TITLEBAR                    = 'Spelling Errors'
            TEXT_QUESTION               = 'There are spelling errors in description(s)'
                                          &'Proceed with errors? '
           DISPLAY_CANCEL_BUTTON       = 'X'
           START_COLUMN                = 25
           START_ROW                   = 6
         IMPORTING
           ANSWER                      = L_VALUE
         EXCEPTIONS
           TEXT_NOT_FOUND              = 1
           OTHERS                      = 2
                  .
        IF SY-SUBRC = 0.
          CASE L_VALUE.
            WHEN '1'.
              MOVE 'J' TO L_ANS.
            WHEN '2'.
              MOVE 'N' TO L_ANS.
          ENDCASE.
        ENDIF.

        IF L_ANS = 'J'.
          CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
          G_OTHER = 'X'.                                    "+
          IF G_TABCTRL110_WA-COMP_FLG+1(1) = 'M'.
            G_TABCTRL110_WA-COMP_FLG = 'SM'.
          ELSE.
            G_TABCTRL110_WA-COMP_FLG = 'S'.
          ENDIF.
*          g_tabctrl110_wa-rsn   = 'Spelling mistakes/Modifier not in
*                                   Attributes table'.
          LEAVE TO SCREEN 0.
        ELSE.
          G_TABCTRL110_WA-USER_DESC = ''.
*        g_user_desc = ''.
*
        ENDIF.
      ELSE.
        CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
        G_OTHER = 'X'.                                      "+
        REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
*        if g_tabctrl110_wa-COMP_FLG+0(1) = 'S'. "remove spell error
*          g_tabctrl110_wa-COMP_FLG = ' M'.
**          g_tabctrl110_wa-rsn   = 'Modifier not in Attributes table'.
*        Endif.

        """added by lipsy on 10.09.2012 <RD1K979105> to get pop-up message in sub-attributes

     DATA : L_GET1(1) TYPE C.
     CALL FUNCTION 'POPUP_TO_CONFIRM'
       EXPORTING
        TITLEBAR                    = 'proceed '
        DIAGNOSE_OBJECT             = 'ZMM_IMAC_TEXT'
         TEXT_QUESTION               = 'Do you still want to proceed ?'
        DEFAULT_BUTTON              = '2'
        START_COLUMN                = 25
        START_ROW                   = 6
      IMPORTING
        ANSWER                      = L_GET1
      EXCEPTIONS
     TEXT_NOT_FOUND              = 1
     OTHERS                      = 2
               .
IF SY-SUBRC = 0.
       CASE L_GET1.
         WHEN '1'.
           MOVE 'J' TO L_ANS.
         WHEN '2'.
           MOVE 'N' TO L_ANS.
       ENDCASE.
     ENDIF.

            if  l_ans = 'J'.
        "end of addition by lipsy on 10.09.2012
        LEAVE TO SCREEN 0.
      ENDIF. "ADDED BY LIPSY ON 10.09.2012 <RD1K979105> to get pop-up message in sub-attributes

      ENDIF.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0115  INPUT
*&---------------------------------------------------------------------*
*&      Module  TAbctrl110_value  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_VALUE INPUT.

  GET PARAMETER ID 'ZMATGP' FIELD G_MATGP .
  MOVE G_MATGP TO ZMM_CDITEM-MATGP.
***Addition*************************************=
  CLEAR: ZMM_CDITEM-DESC2,ZMM_CDITEM-DESC3,ZMM_CDITEM-DESC4,
         ZMM_CDITEM-USER_DESC.
***End******************************************=

ENDMODULE.                 " TAbctrl110_value  INPUT
*&---------------------------------------------------------------------*
*&      Module  SCREEN100_initialize  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN100_INITIALIZE INPUT.
  PERFORM CHECK_DELREQ. "Check request deletion
  CLEAR G_HD_COPIED.
  CLEAR: G_TABCTRL110_COPIED,G_TABLCTRL120_COPIED,G_TABLCTRL130_COPIED.
****If reqno change from one mat type to another, clear the*************
****Search help tablecontrol********************************************
  REFRESH: IST_SRCHLP.
  REFRESH CONTROL 'TABCTRL100' FROM SCREEN '0100'.
  CLEAR: FIELD1.
*
ENDMODULE.                 " SCREEN100_initialize  INPUT

*&---------------------------------------------------------------------*
*&      Module  TEXT_CONTROL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CONTROL_UEBERNEHMEN INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT                   = LT_TEXT_TABLE
      IS_MODIFIED            = GV_XTHEAD_UPDKZ
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = LT_TEXT_TABLE
      ITF_TEXT    = TLINETAB.

ENDMODULE.                 " TEXT_CONTROL_UEBERNEHMEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit_req  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_REQ INPUT.
  .
  PERFORM EXIT_CONFIRM.
*   .
ENDMODULE.                 " exit_req  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR100 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABCTRL100-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_100 = G_CURR_LINE.

ENDMODULE.                 " get_cursor100  INPUT
*&      Module  SCREEN100_initialize1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN100_INITIALIZE1 INPUT.

  REFRESH IST_SRCHLP.
  REFRESH G_TABCTRL110_ITAB.
  CLEAR G_TABCTRL110_ITAB.
  CLEAR ZMM_CDITEM.
  CLEAR G_MAT_FND.
  PERFORM CLEAR_SRCHLP_PARMS.

ENDMODULE.                 " SCREEN100_initialize1  INPUT
*&---------------------------------------------------------------------*
*&      Module  longtext  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE LONGTEXT INPUT.
  DATA: L_OKDTSP LIKE SY-UCOMM.

  L_OKDTSP = SY-UCOMM.
  CASE L_OKDTSP.
    WHEN 'REQLT'.
*
      PERFORM LTXTDTSP.
      CLEAR: L_OKDTSP,SY-UCOMM.
  ENDCASE.

ENDMODULE.                 " longtext  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT                   = LT_TEXT_TABLE1
      IS_MODIFIED            = GV_XTHEAD_UPDKZ
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = LT_TEXT_TABLE1
      ITF_TEXT    = TLINETAB1.

  CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT                   = LT_TEXT_TABLE2
      IS_MODIFIED            = GV_XTHEAD_UPDKZ
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = LT_TEXT_TABLE2
      ITF_TEXT    = TLINETAB2.


ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  TREE_CTRL_EMPFANGEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TREE_CTRL_EMPFANGEN INPUT.

ENDMODULE.                 " TREE_CTRL_EMPFANGEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  OTHER_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE OTHER_CHECK INPUT.
  PERFORM OTHER_CHECK.
ENDMODULE.                 " OTHER_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL110_check  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL110_CHECK INPUT.

  TABCTRL110_CHECK_FLAG = 'X'.
*
ENDMODULE.                 " TABCTRL110_check  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.
  GV_XTHEAD_UPDKZ = 0.

  CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
    IMPORTING
      TEXT                   = LT_TEXT_TABLE1
      IS_MODIFIED            = GV_XTHEAD_UPDKZ
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      OTHERS                 = 3.

  CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
    TABLES
      TEXT_STREAM = LT_TEXT_TABLE1
      ITF_TEXT    = TLINETAB1.
*
  IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
     ( G_MODE = 'REL' ) OR ( G_MODE = 'APR' ) OR
     ( G_MODE = 'MRP' ) OR SY-TCODE = 'ZCODG'.

    CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
      IMPORTING
        TEXT                   = LT_TEXT_TABLE2
        IS_MODIFIED            = GV_XTHEAD_UPDKZ
      EXCEPTIONS
        ERROR_DP               = 1
        ERROR_CNTL_CALL_METHOD = 2
        OTHERS                 = 3.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      TABLES
        TEXT_STREAM = LT_TEXT_TABLE2
        ITF_TEXT    = TLINETAB2.
  ENDIF..
ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0105 INPUT.
  DATA: OKCODE105 LIKE SY-UCOMM.

  OKCODE105 = SY-UCOMM.

  CASE OKCODE105.
    WHEN 'OK'.
      CLEAR OKCODE105.
    WHEN 'CANCEL'.
      REFRESH TLINETAB2[].
      CLEAR OKCODE105.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE WRITE_MESSAGES INPUT.

  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  SET PF-STATUS SPACE.
  LOOP AT IST_MESSAGE INTO WA_MESSAGE.
    WRITE: / WA_MESSAGE-SRNO, WA_MESSAGE-MSGTYPE,WA_MESSAGE-MSGCODE,
                  WA_MESSAGE-MSGTEXT.
  ENDLOOP.

ENDMODULE.                 " WRITE_MESSAGES  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.

  REFRESH IST_MESSAGE.

ENDMODULE.                 " USER_COMMAND_0102  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_CHECK_DESC1 INPUT.
  DATA L_CNT TYPE I.
  DATA L_DESC_FIN_LEN TYPE I.
  DATA L_DESC(87).
*{   INSERT         OCPK900087                                        2
*DATA: BEGIN OF WA_T604F,
*      LAND1 TYPE LAND1,
*      STEUC TYPE STEUC,
*  END OF WA_T604F,
*  ZMSG110 TYPE STRING.
*}   INSERT

  IF ZMM_CDITEM-DESC1 <> 'OTHER' . "+
    SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1.
    IF SY-SUBRC <> 0.
      MESSAGE E002(ZMM_OTH).
    ELSE.
*{   INSERT         OCPK900087                                        1
**DATA: BEGIN OF WA_T604F,
**      LAND1 TYPE LAND1,
**      STEUC TYPE STEUC,
**  END OF WA_T604F,
**  ZMSG110 TYPE STRING.
**LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
**READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = ZMM_CDITEM-DESC1.
**STEUC = G_TABCTRL110_WA-STEUC.
**STEUC = ZMM_CDITEM-STEUC.
* SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = ZMM_CDITEM-STEUC.
*ENDSELECT.
*  IF SY-SUBRC <> 0.
**
**IF WA_T604F IS INITIAL.
*
* CONCATENATE ZMM_CDITEM-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
* MESSAGE ZMSG110 TYPE 'E'.
**MESSAGE ID '00' TYPE 'E' NUMBER '058' WITH STEUC '' '' 'T604F'.
*
*endif.
*ELSE.

*}   INSERT
      SELECT COUNT(*) INTO L_CNT FROM ZMM_MODIFIER
                      WHERE DESC1 = ZMM_CDITEM-DESC1.
      IF L_CNT > 1.
*
        CLEAR MATGRP_CHANGE_FLAG.
        PERFORM TABCTRL110_DESC1_CHECK.
      ENDIF.
    ENDIF.
*
  ENDIF.

  IF ZMM_CDITEM-USER_DESC <> ''.
    CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
                ZMM_CDITEM-DESC4 INTO G_DESC1_4.
    CONDENSE G_DESC1_4.
    CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
    IF SY-SUBRC <> 0.
      MESSAGE I073(ZMM_OTH).
      CLEAR ZMM_CDITEM-USER_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TABLE110_check_desc1  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_CHECK_DESC2 INPUT.
*  Data l_desc_fin_len type i.
*  Data l_desc87(87).

  IF ZMM_CDITEM-DESC2 <> 'OTHER'.  "+
*   IF zmm_cditem-oth2 <> 'X' .      "+
    SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                               DESC2 = ZMM_CDITEM-DESC2 .

    IF SY-SUBRC <> 0.
      MESSAGE E002(ZMM_OTH).
    ENDIF.
  ENDIF.

  IF ZMM_CDITEM-USER_DESC <> ''.
    CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
                ZMM_CDITEM-DESC4 INTO G_DESC1_4.
    CONDENSE G_DESC1_4.
    CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
    IF SY-SUBRC <> 0.
      MESSAGE I073(ZMM_OTH).
      CLEAR ZMM_CDITEM-USER_DESC.
    ENDIF.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc2  INPUT

*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_CHECK_DESC3 INPUT.
*  Data l_desc_fin_len type i.
*  Data l_desc87(87).
*
  IF ZMM_CDITEM-DESC3 <> 'OTHER'.
    SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                            DESC2 = ZMM_CDITEM-DESC2 AND
                                                DESC3 = ZMM_CDITEM-DESC3.

    IF SY-SUBRC <> 0.
      MESSAGE E002(ZMM_OTH).
    ENDIF.
  ENDIF.

  IF ZMM_CDITEM-USER_DESC <> ''.
    CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
                ZMM_CDITEM-DESC4 INTO G_DESC1_4.
    CONDENSE G_DESC1_4.
    CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
    IF SY-SUBRC <> 0.
      MESSAGE I073(ZMM_OTH).
      CLEAR ZMM_CDITEM-USER_DESC.
    ENDIF.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc3  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLE110_check_desc4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_CHECK_DESC4 INPUT.
*  Data l_desc_fin_len type i.
*  Data l_desc87(87).

  IF ZMM_CDITEM-DESC4 <> 'OTHER'.
    SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
                                            DESC2 = ZMM_CDITEM-DESC2 AND
                                            DESC3 = ZMM_CDITEM-DESC3 AND
                                                DESC4 = ZMM_CDITEM-DESC4.

    IF SY-SUBRC <> 0.
      MESSAGE E002(ZMM_OTH).
    ENDIF.
  ENDIF.

  IF ZMM_CDITEM-USER_DESC <> ''.
    CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
                ZMM_CDITEM-DESC4 INTO G_DESC1_4.
    CONDENSE G_DESC1_4.
    CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
    IF SY-SUBRC <> 0.
      MESSAGE I073(ZMM_OTH).
      CLEAR ZMM_CDITEM-USER_DESC.
    ENDIF.
  ENDIF.

ENDMODULE.                 " TABLE110_check_desc4  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0150 INPUT.

  CASE SY-UCOMM.

    WHEN 'OK150'.

      LEAVE TO SCREEN 0.

    WHEN 'CAN150'.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_plant  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PLANT INPUT.
  DATA : L_WERKS LIKE T001W-WERKS.
  IF NOT ZMM_CDHD_ST-WERKS IS INITIAL.
    SELECT SINGLE WERKS INTO L_WERKS FROM T001W
           WHERE WERKS = ZMM_CDHD_ST-WERKS.
    IF SY-SUBRC <> 0.
      MESSAGE E033(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_plant  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_location  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_LOCATION INPUT.
  DATA : L_LOCID LIKE ZLOCMST-LOCID.
  IF NOT ZMM_CDHD_ST-REQLOC IS INITIAL.
    SELECT SINGLE LOCID INTO L_LOCID FROM  ZLOCMST
           WHERE LOCID = ZMM_CDHD_ST-REQLOC.
    IF SY-SUBRC <> 0.
      MESSAGE E036(ZMM_OTH).
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_location  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_matgp_desc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_MATGP_DESC INPUT.
  SELECT SINGLE WGBEZ FROM T023T INTO G_MATGP_DESC WHERE MATKL =
  G_MATGP AND SPRAS = SY-LANGU.
  IF SY-SUBRC <> 0.
    G_MATGP = ''.
  ENDIF.

ENDMODULE.                 " get_matgp_desc  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_capcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CAPCODE INPUT.

  PERFORM VALIDATE_CAPCODE.

ENDMODULE.                 " check_capcode  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_modelno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MODELNO INPUT.
  DATA:  L_STRLEN TYPE I, K TYPE I.
  DATA : L_LASTCHAR.
  DATA:  L_ANS2,X.
  DATA : IST_SVAL_TEMP(30).
  DATA : G_TABLCTRL120_WA1 LIKE G_TABLCTRL120_WA.
*  data : g_tablctrl120_wa2 like g_tablctrl120_wa.
*  If sy-tcode <> 'ZCODG'.
  REFRESH IST_MDL. CLEAR IST_MDL.

  IF ZMM_CDITEM-MDLNO <> 'OTHER'. "and zmm_cditem-oth_mdl = ''.
    SELECT SINGLE * FROM ZMM_MDL
           WHERE MDLNO = ZMM_CDITEM-MDLNO.
    IF SY-SUBRC <> 0.
      MOVE G_TABLCTRL120_WA TO G_TABLCTRL120_WA1.

      READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA1 WITH KEY
      MDLNO = ZMM_CDITEM-MDLNO.

      IF SY-SUBRC = 0.
        IF G_TABLCTRL120_WA1-OTH_MDL = 'X'.
          ZMM_CDITEM-OTH_MDL = G_TABLCTRL120_WA1-OTH_MDL.
***          if zmm_cditem-comp_flg ca 'L'.  " to prevent LL
***          Else.
***           replace ' ' with 'L' into zmm_cditem-comp_flg.
***          Endif.
        ENDIF.
      ELSE.
        MESSAGE E044(ZMM_OTH).
***        move ' L' to zmm_cditem-comp_flg.
      ENDIF.
    ELSE.
      REPLACE 'L' WITH  '' INTO ZMM_CDITEM-COMP_FLG.
      MOVE '' TO ZMM_CDITEM-OTH_MDL.
    ENDIF.
  ELSE.
    REFRESH IST_SVAL.
    CLEAR   IST_SVAL.
    CLEAR   IST_SVAL_TEMP.

    MOVE : 'ZMM_CDITEM'  TO IST_SVAL-TABNAME,
           'MDLNO'       TO IST_SVAL-FIELDNAME,
           'X'           TO IST_SVAL-FIELD_OBL.
    APPEND IST_SVAL.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
*       NO_VALUE_CHECK        = ' '
        POPUP_TITLE           = 'Enter Model No.'
        START_COLUMN          = '5'
        START_ROW             = '5'
      TABLES
        FIELDS                = IST_SVAL.

    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    TRANSLATE IST_SVAL-VALUE TO UPPER CASE.
    READ TABLE IST_SVAL INDEX 1.
    ZMM_MDL-MDLNO = IST_SVAL-VALUE.  "#EC CI_FLDEXT_OK[2215424]

    IF NOT IST_SVAL-VALUE IS INITIAL.
*      read table ist_sval index 1.
      L_STRLEN = STRLEN( IST_SVAL-VALUE ).
      IST_SVAL_ORG = IST_SVAL-VALUE.

      TRANSLATE  IST_SVAL-VALUE USING
'.%-%,%+%*%_%^%?%"%!% %$%:%;%`%"%/%\%<%>%=%§%#%~%(%)%|%<%>%@%{%}%[%]%~%'
  .
      IST_SVAL-VALUE = IST_SVAL-VALUE+0(L_STRLEN).
      L_STRLEN = L_STRLEN + 1.
      K = 0.
      DO L_STRLEN TIMES.
        X =  IST_SVAL-VALUE+K(1).
        IF X <> '%'.
          CONCATENATE IST_SVAL_TEMP '%' X INTO IST_SVAL_TEMP.
          CONDENSE IST_SVAL_TEMP NO-GAPS.
        ENDIF.
        K = K + 1 .
        X = ''.
      ENDDO.
      IST_SVAL-VALUE = IST_SVAL_TEMP.
      SELECT * FROM ZMM_MDL INTO TABLE IST_MDL WHERE MDLNO LIKE
      IST_SVAL-VALUE ORDER BY PRIMARY KEY.
      IF SY-SUBRC <> 0.
*        zmm_cditem-mdlno = zmm_mdl-mdlno.  "* <<07.10.05>>
*  Added on  07-10-05 to remove all special chars at the end except
*  ',",),#,+
        L_STRLEN = STRLEN( ZMM_MDL-MDLNO ).
        L_STRLEN = L_STRLEN - 1.
        L_LASTCHAR = ZMM_MDL-MDLNO+L_STRLEN(1).  "#EC CI_FLDEXT_OK[2215424]
        IF L_LASTCHAR = '''' OR
           L_LASTCHAR = '"' OR
           L_LASTCHAR = ')' OR
           L_LASTCHAR = '#' OR
           L_LASTCHAR = '+' .
          ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO.
        ELSE.
          IF L_LASTCHAR BETWEEN '0' AND '9' OR
             L_LASTCHAR BETWEEN 'A' AND 'Z'.
            ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO.
          ELSE.
            ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO+0(L_STRLEN).  "#EC CI_FLDEXT_OK[2215424]
          ENDIF.
        ENDIF.
** End add 07-10-05

        ZMM_CDITEM-OTH_MDL = 'X'.
***        IF zmm_cditem-comp_flg+0(1) ='S'.
***          zmm_cditem-comp_flg = 'SL'.
***        Else.
***          zmm_cditem-comp_flg = ' L'.
***        Endif.

      ELSE.

        TRANSLATE IST_SVAL-VALUE USING '% '.
        CONDENSE IST_SVAL-VALUE NO-GAPS.

        LOOP AT IST_MDL.
          TRANSLATE  IST_MDL-MDLNO USING
 '. - , + * _ ^ ? " ! $ : ; ` " / \ < > = § # ~ ( ) | < > @ { } [ ] ~ '.
          CONDENSE IST_MDL-MDLNO NO-GAPS.
          IF IST_MDL-MDLNO <> IST_SVAL-VALUE.
            DELETE IST_MDL INDEX SY-TABIX.
          ENDIF.
        ENDLOOP.
        IF NOT IST_MDL[] IS INITIAL.
          CALL SCREEN 104 STARTING AT 40 2
                       ENDING   AT 80 18.
        ELSE.
          ZMM_CDITEM-MDLNO = IST_SVAL-VALUE.
          ZMM_CDITEM-OTH_MDL = 'X'.
***          replace ' ' with 'L' into zmm_cditem-comp_flg.
        ENDIF.
        IF ZMM_CDITEM-MDLNO = 'OTHER'. " In case OTHER is entered in
*                                        popup
          ZMM_CDITEM-MDLNO = ''.
          ZMM_CDITEM-OTH_MDL = ''.

        ENDIF.
      ENDIF.
    ELSE.
      ZMM_CDITEM-MDLNO = ''.

    ENDIF.
  ENDIF.

  IF ZMM_CDITEM-MDLNO = ''.
    MESSAGE E044(ZMM_OTH).
  ELSE.
* Added on 26-10-2005 to remove LL etc problem in comp_flg field
    IF ZMM_CDITEM-OTH_MDL = 'X'.
      IF ZMM_CDITEM-COMP_FLG+0(1) ='S'.
        ZMM_CDITEM-COMP_FLG = 'SL'.
      ELSE.
        ZMM_CDITEM-COMP_FLG = ' L'.
      ENDIF.
    ELSE.
      IF ZMM_CDITEM-COMP_FLG+0(1) ='S'.
        ZMM_CDITEM-COMP_FLG = 'S'.
      ELSE.
        ZMM_CDITEM-COMP_FLG = ''.
      ENDIF.
    ENDIF.
  ENDIF.
*Endif.
ENDMODULE.                 " check_modelno  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_matgp  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_MATGP INPUT.
* Check only stores group is selected
  IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR G_TABCTRL110_WA-OTH1 = 'X'.
    IF G_MATGP GT '16' OR G_MATGP LT '07'.
      MESSAGE E049(ZMM_OTH).
    ENDIF.
  ENDIF.

ENDMODULE.                 " check_matgp  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_OTHER INPUT.
*
  IF ZMM_CDITEM-OTH1 = 'X' OR
     ZMM_CDITEM-OTH2 = 'X' OR
     ZMM_CDITEM-OTH3 = 'X' OR
     ZMM_CDITEM-OTH4 = 'X'.

  ELSE.
    REPLACE 'M' WITH '' INTO ZMM_CDITEM-COMP_FLG.
  ENDIF.
ENDMODULE.                 " check_other  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_fld  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_FLD INPUT.
  DATA : L_CDITEMC LIKE ZMM_CDITEM.
  CLEAR : L_CDITEMC.
**
  GET CURSOR FIELD G_CURSOR_FLD130.
  IF ZMM_CDITEM-DESC_FIN IS INITIAL.
    MESSAGE I007(ZMM_OTH).
    SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN'.
  ENDIF.
**
  IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
    SELECT * INTO L_CDITEMC FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE DESC_FIN = ZMM_CDITEM-DESC_FIN
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF SY-SUBRC = 0.
      IF G_MODE = 'CHA'.
        IF L_CDITEMC-REQNO <> ZMM_CDHD_ST-REQNO.
          MESSAGE I074(ZMM_OTH)
          WITH L_CDITEMC-REQNO L_CDITEMC-SRNO.
        ENDIF.
      ELSE.
        MESSAGE I074(ZMM_OTH)
        WITH L_CDITEMC-REQNO L_CDITEMC-SRNO.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " get_cursor_fld  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_MATCATG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CHARACTERSTICS_MATCATG INPUT.
*
  DATA : L_ATWRT LIKE CAWN-ATWRT.
*
  SELECT SINGLE ATWRT FROM ZMMCDCAP_USRGP_V INTO L_ATWRT WHERE ATWRT =
    ZMM_CDITEM-MATCATG.
  IF SY-SUBRC <> 0.
    MESSAGE E051(ZMM_OTH).
  ENDIF.

ENDMODULE.                 " Check_characterstics_MATCATG  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_MATLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CHARACTERSTICS_MATLOC INPUT.
*
  SELECT SINGLE ATWRT FROM ZMMCDCAP_LOC_V INTO L_ATWRT WHERE ATWRT =
    ZMM_CDITEM-MATLOC.
  IF SY-SUBRC <> 0 .
    MESSAGE E051(ZMM_OTH).
  ENDIF.
ENDMODULE.                 " Check_characterstics_MATLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_characterstics_SPAGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CHARACTERSTICS_SPAGRP INPUT.
  SELECT SINGLE ATWRT FROM ZMMCDCAP_SPRGP_V INTO L_ATWRT WHERE ATWRT =
    ZMM_CDITEM-SPA_GRP.  "#EC CI_FLDEXT_OK[2215424]
  IF SY-SUBRC <> 0.
    MESSAGE E051(ZMM_OTH).
  ENDIF.

ENDMODULE.                 " Check_characterstics_SPAGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_WRKNG_LIFE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_WRKNG_LIFE INPUT.
*
  TRANSLATE ZMM_CDITEM-WRKNG_LIFE TO UPPER CASE.
  CONDENSE ZMM_CDITEM-WRKNG_LIFE NO-GAPS.
  IF ZMM_CDITEM-WRKNG_LIFE
  CA '.-'',#~`!@#$%^&*()<>/:;"ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    MESSAGE E058(ZMM_OTH).
  ENDIF.
ENDMODULE.                 " Check_WRKNG_LIFE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.
  DATA : TEL_LEN TYPE I.
  TEL_LEN = STRLEN( ZMM_CDHD_ST-TEL ).
  IF  ZMM_CDHD_ST-TEL CN ' 0123456789-'.
    MESSAGE E059(ZMM_OTH).
  ELSE.
    IF TEL_LEN < 7.
      MESSAGE E060(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  Check_werks  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_WERKS INPUT.
  AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
             ID 'WERKS' FIELD ZMM_CDHD_ST-WERKS
             ID 'ACTVT'  FIELD '01'.
  IF SY-SUBRC <> 0.
    G_CHANGE_AUTH = 'X'.
    MESSAGE E062(ZMM_OTH) WITH ZMM_CDHD_ST-WERKS.

  ENDIF.

ENDMODULE.                 " Check_werks  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHeck_OEM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_OEM INPUT.
  DATA : L_MANUF_TY1 TYPE LFA1-J_1KFTBUS.
  DATA : L_MANUF_DEL TYPE LFA1-LOEVM.

  SELECT SINGLE J_1KFTBUS LOEVM FROM LFA1 INTO (L_MANUF_TY1,L_MANUF_DEL)
             WHERE LIFNR =  ZMM_CDITEM-MANU.

  IF L_MANUF_DEL = 'X'.

    MESSAGE E082(ZMM_OTH) WITH ZMM_CDITEM-MANU.

  ELSE.

    IF SY-SUBRC = 0 AND L_MANUF_TY1 <> 'OEM'.

      " Begin of <RD1K960036>.

*      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*        EXPORTING
*          DEFAULTOPTION        = 'N'
*          TEXTLINE1            = 'This vendor is not OEM'
*         TEXTLINE2            =  'Continue? '
*          TITEL                = 'Vendor'
**             START_COLUMN         = 25
**             START_ROW            = 6
**             CANCEL_DISPLAY       = 'X'
*       IMPORTING
*         ANSWER               = l_ans

      DATA : L_GET15(1) TYPE C.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Vendor'
          TEXT_QUESTION         = 'This vendor is not OEM Continue?'
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = 'X'
          START_COLUMN          = 25
          START_ROW             = 6
        IMPORTING
          ANSWER                = L_GET15
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.
      IF SY-SUBRC = 0.
        CASE L_GET15.
          WHEN '1'.
            MOVE 'J' TO L_ANS.
          WHEN '2'.
            MOVE 'N' TO L_ANS.
        ENDCASE.
      ENDIF.
      " End of <RD1K960036>.
      .
      IF L_ANS <> 'J'.
        ZMM_CDITEM-MANU = ''.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                 " CHeck_OEM  INPUT
*&---------------------------------------------------------------------*
*&      Module  Desc_fin_change  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DESC_FIN_CHANGE INPUT.
*  Data:l_cditemd  like  zmm_cditem.
* changing hits for existing descriptions.
  IF G_MODE = 'CHA' AND OKCODE_100 = 'SAV' AND ZMM_CDITEM-MATCOST <> 0.
    G_DESC_FIN_CHNG = 'X'.
    PERFORM GET_SRCHLP_ZCAP.
    DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
    ZMM_CDITEM-MAT_FND = G_MAT_FND.
    CLEAR G_DESC_FIN_CHNG.
  ENDIF.

ENDMODULE.                 " Desc_fin_change  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CAP_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CAP_CODE INPUT.

  DATA : L_CSP_CODE LIKE ZMM_CDITEM-CAP_CODE.

  DATA  :  IST_RETURN_TAB1 LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.

  TABLES : CABN, AUSP.
  TYPES  : BEGIN OF MOD_MARA,
              MATNR LIKE MARA-MATNR,
              MTART LIKE MARA-MTART,
              MAKTX LIKE MAKT-MAKTX,
           END OF MOD_MARA.
  DATA   : IST_MOD_MARA TYPE TABLE OF MOD_MARA WITH HEADER LINE.
  DATA   : IST_MARA LIKE TABLE OF MARA WITH HEADER LINE.
  DATA   : WA_MARA LIKE LINE OF IST_MARA.
  DATA   : L_MAKTX LIKE MAKT-MAKTX.

  SELECT * FROM CABN UP TO 1 ROWS
 WHERE ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
 ORDER BY PRIMARY KEY .
 ENDSELECT.

  SELECT A~MATNR A~MTART C~MAKTX  INTO CORRESPONDING FIELDS OF TABLE
                      IST_MOD_MARA
                      FROM MARA AS A  INNER JOIN AUSP AS B
                      ON A~MATNR = B~OBJEK
                      INNER JOIN MAKT AS C
                      ON A~MATNR = C~MATNR
                      WHERE B~ATINN = CABN-ATINN AND
                      B~ATWRT <> ''.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATNR'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZMM_CDITEM-CAP_CODE'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IST_MOD_MARA
      RETURN_TAB      = IST_RETURN_TAB1
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.

  ENDIF.

  REFRESH:IST_MOD_MARA,IST_RETURN_TAB1.
  FREE : IST_MOD_MARA,IST_RETURN_TAB1.

ENDMODULE.                 " POV_CAP_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_uom  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_UOM INPUT.
  DATA: L_CDITEMS LIKE ZMM_CDITEM.
  IF OKCODE_100 = 'SAV' AND ZMM_CDITEM-UOM IS INITIAL.
    MESSAGE E071(ZMM_OTH).
  ENDIF.

***To check the duplicate entry in other request.
  IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
    SELECT * INTO L_CDITEMS FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE DESC_FIN = ZMM_CDITEM-DESC_FIN AND UOM = ZMM_CDITEM-UOM
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF SY-SUBRC = 0.
      IF G_MODE = 'CHA'.
        IF L_CDITEMS-REQNO <> ZMM_CDHD_ST-REQNO.
          MESSAGE I074(ZMM_OTH)
          WITH L_CDITEMS-REQNO L_CDITEMS-SRNO.
        ENDIF.
      ELSE.
        MESSAGE I074(ZMM_OTH)
        WITH L_CDITEMS-REQNO L_CDITEMS-SRNO.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMODULE.                 " check_uom  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_duplicate_rec  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DUPLICATE_REC INPUT.

  DATA:L_130W TYPE T_TABLCTRL130.
  DATA:L_110 TYPE TABLE OF T_TABCTRL110,
       L_120 TYPE TABLE OF T_TABLCTRL120,
       L_130 TYPE TABLE OF T_TABLCTRL130,
       L_140 TYPE TABLE OF T_TABLCTRL140,
       L_CDITEM   LIKE  ZMM_CDITEM.
  CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN.
  REFRESH: L_110,L_120,L_130,L_140.
**Addition-Duplicate Check*******************=
  IF G_MODE = 'CHA' OR G_MODE = 'CRE'.
    CASE ZMM_CDHD_ST-MTART.
      WHEN 'ZSTO'.
*{   INSERT         OCPK900087                                        1
*DATA: BEGIN OF WA_T604F,
*      LAND1 TYPE LAND1,
*      STEUC TYPE STEUC,
*  END OF WA_T604F,
*  ZMSG110 TYPE STRING.
*LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
*
* SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = G_TABCTRL110_WA-STEUC.
*ENDSELECT.
*
*IF WA_T604F IS INITIAL.
*
* CONCATENATE G_TABCTRL110_WA-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
* MESSAGE ZMSG110 TYPE 'E'.
*
*ENDIF.
*
*CLEAR: G_TABCTRL110_WA, WA_T604F.
*ENDLOOP.



*}   INSERT
        APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
        SORT L_110 BY DESC_FIN UOM ASCENDING.
        DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
        IF SY-SUBRC = 0.
          MESSAGE I072(ZMM_OTH).
          IF OKCODE_100 = 'SAV'.
            CLEAR OKCODE_100.
          ENDIF.
        ENDIF.
      WHEN 'ZSPR'.
        APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
        SORT L_120 BY DESC_FIN UOM CAP_CODE MDLNO MANU ASCENDING.
        DELETE ADJACENT DUPLICATES FROM L_120
               COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
        IF SY-SUBRC = 0.
          MESSAGE I072(ZMM_OTH).
          IF OKCODE_100 = 'SAV'.
            CLEAR OKCODE_100.
          ENDIF.
        ENDIF.
      WHEN 'ZCAP'.
        APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
        SORT L_130 BY DESC_FIN ASCENDING.
        DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
        IF SY-SUBRC = 0.
          MESSAGE I072(ZMM_OTH).
          IF OKCODE_100 = 'SAV'.
            CLEAR OKCODE_100.
          ENDIF.
        ENDIF.
      WHEN 'ZDIS'.
        APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
        SORT L_140 BY DESC_FIN ASCENDING.
        DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
        IF SY-SUBRC = 0.
          MESSAGE I072(ZMM_OTH).
          IF OKCODE_100 = 'SAV'.
            CLEAR OKCODE_100.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
**End****************************************=
ENDMODULE.                    "check_duplicate_rec INPUT
*&---------------------------------------------------------------------*
*&      Module  duplicate_inothreq  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DUPLICATE_INOTHREQ INPUT.
  DATA: L_CDITEMP LIKE ZMM_CDITEM.
  IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
    SELECT * INTO L_CDITEMP FROM ZMM_CDITEM UP TO 1 ROWS
 WHERE PARTNO = ZMM_CDITEM-PARTNO AND DESC_FIN = ZMM_CDITEM-DESC_FIN AND UOM = ZMM_CDITEM-UOM AND CAP_CODE = ZMM_CDITEM-CAP_CODE AND MDLNO = ZMM_CDITEM-MDLNO AND MANU = ZMM_CDITEM-MANU
 ORDER BY PRIMARY KEY .
 ENDSELECT.
    IF SY-SUBRC = 0.
      IF G_MODE = 'CHA'.
        IF L_CDITEMP-REQNO <> ZMM_CDHD_ST-REQNO.
          MESSAGE I074(ZMM_OTH)
          WITH L_CDITEMP-REQNO L_CDITEMP-SRNO.
        ENDIF.
      ELSE.
        MESSAGE I074(ZMM_OTH)
        WITH L_CDITEMP-REQNO L_CDITEMP-SRNO.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " duplicate_inothreq  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_OTHER1 INPUT.
  IF OKCODE_100 = 'SAV'.
    IF ZMM_CDITEM-DESC1 = 'OTHER'.
      CLEAR OKCODE_100.
      MESSAGE E029(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_other1  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE CHECK_OTHER2 INPUT.
  IF OKCODE_100 = 'SAV'.
    IF ZMM_CDITEM-DESC2 = 'OTHER'.
      CLEAR OKCODE_100.
      MESSAGE E029(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_other1  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other3 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE CHECK_OTHER3 INPUT.
  IF OKCODE_100 = 'SAV'.
    IF ZMM_CDITEM-DESC3 = 'OTHER'.
      CLEAR OKCODE_100.
      MESSAGE E029(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_other1  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_other4 INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE CHECK_OTHER4 INPUT.
  IF OKCODE_100 = 'SAV'.
    IF ZMM_CDITEM-DESC4 = 'OTHER'.
      CLEAR OKCODE_100.
      MESSAGE E029(ZMM_OTH).
    ENDIF.
  ENDIF.
ENDMODULE.                 " check_other4 INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUEST_FILE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_REQUEST_FILE INPUT.

if OKCODE_100 = 'ATTACH' OR OKCODE_100 = 'LIST' .
if ZMM_CDHD_ST-REQNO is INITIAL.
 MESSAGE 'ENTER REQUEST NO' TYPE 'E'.
endif.
ENDIF.
ENDMODULE.                 " CHECK_REQUEST_FILE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_VENDOR_DETAILS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_VENDOR_DETAILS INPUT.

*added by lipsy on 0n 05.09.2012 <RD1K979105> to get vendor details on double click

 get CURSOR LINE g_curr_line_vendor.

 read TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA with KEY srno = g_curr_line_vendor.
CLEAR:g_fname,s_lifnr.
if sy-subrc = 0.
 GET CURSOR FIELD g_fname .
    IF g_fname = 'ZMM_CDITEM-MANU'  AND
    SY-UCOMM = 'DBLCLK' .
 if count = 0.
 SUBMIT ZMM_VEN_SHLP  AND RETURN WITH s_lifnr eq G_TABLCTRL120_WA-manu .
if  sy-subrc  =  0.
count = count + 1.
 endif.
   ENDIF.
   endif.

   endif.
ENDMODULE.                 " GET_VENDOR_DETAILS  INPUT
*&---------------------------------------------------------------------*
*&      Module  ERNAM_FLD_DCLK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ERNAM_FLD_DCLK INPUT.

DATA l_user_dblclk  LIKE soud3.
  CLEAR : g_fname,l_user_dblclk.

if sy-ucomm = 'DBLCLK'.
  GET CURSOR FIELD g_fname.
  CASE g_fname.
    WHEN 'ZMM_CDHD_ST-APPCPF'.
      l_user_dblclk = ZMM_CDHD_ST-APPCPF.
      PERFORM details_ondblclk.

    WHEN 'ZMM_CDHD_ST-REQCPF'.
  l_user_dblclk = ZMM_CDHD_ST-REQCPF.
    PERFORM details_ondblclk.
  ENDCASE.

  ENDIF.

ENDMODULE.                 " ERNAM_FLD_DCLK  INPUT

*{   INSERT         OCPK900087                                        1
*&---------------------------------------------------------------------*
*&      Module  TABLE110_CHECK_STEUC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLE110_CHECK_STEUC INPUT.
  DATA: HSN TYPE T604F-STEUC.

        IF ZMM_CDITEM-STEUC IS NOT INITIAL.
          CLEAR : HSN .
          SELECT SINGLE STEUC
            INTO HSN
            FROM T604F
            WHERE STEUC = ZMM_CDITEM-STEUC.
            IF HSN  IS INITIAL.
              MESSAGE E503(ZMM_OTH).


            ENDIF.



        ENDIF.



ENDMODULE.
*}   INSERT
