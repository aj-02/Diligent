*--- MAIN PROGRAM: MZMMPREPROLE3_PHASEIIO01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEO01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  PERFORM FILL_STTAB.

  IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CHANGE' OR
      OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'DELETE' OR
      SY-TCODE = 'ZIC_AUTH_CORETEAM'.

    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB.

  ELSE.

    SET PF-STATUS 'OPTNS'.

  ENDIF.

  CASE SY-UCOMM.
    WHEN 'CREATE'.
      SET TITLEBAR 'PREP_TITLE' WITH ': Create Request'.
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

    WHEN OTHERS.
      SET TITLEBAR 'PREP_TITLE' WITH ''.
  ENDCASE.

  DATA LV_DOCNO TYPE ZCHAR12.

  IF ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.
    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
    LV_DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    DELETE GT_ICON1 WHERE DOCNO NE ZIC_PREP_ROLEREQ-DOCNO.
    IF ZIC_PREP_ROLEREQ-DOCNO IS  NOT INITIAL.
      CLEAR ZIC_PREP_ROLEREQ-DOCNO.
    ENDIF.
  ELSE.
    LV_DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
  ENDIF.
  SELECT * FROM ZGRC_SOD_RESULT INTO CORRESPONDING FIELDS OF TABLE GT_ICON WHERE DOCNO = LV_DOCNO.
  GT_ICON1[] = GT_ICON[].
  DESCRIBE TABLE GT_ICON1 LINES LV_COUNT.
  IF SY-TCODE EQ 'ZIC_AUTH_CORETEAM' ." OR SY-TCODE EQ 'ZIC_AUTH_FI_REP'.
    IF LV_COUNT EQ 1.
      GICON = '@08@'. "GREEN
      RISK_DESC = 'No Risk'.
    ELSEIF LV_COUNT GT 1.
      GICON = '@0A@'. "RED
      RISK_DESC = 'Risk found'.
    ELSEIF LV_COUNT EQ 0.
      GICON = '@09@'. " YELLOW
      RISK_DESC = 'Risk Anlys in progress'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_HEADER_DATA OUTPUT.

  IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

    DATA : L_DOCNO LIKE ZIC_PREP_ROLEREQ-DOCNO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ZIC_PREP_ROLEREQ-DOCNO
      IMPORTING
        OUTPUT = L_DOCNO.

    ZIC_PREP_ROLEREQ-DOCNO = L_DOCNO.

  ENDIF.

  IF  G_HD_COPIED <> 'X'.
*
    IF OLD_OK_CODE IS INITIAL AND OKCODE_100 IS INITIAL.

    ELSE.

      IF OLD_OK_CODE = 'CREATE'  AND OKCODE_100 IS INITIAL.

      ELSE.

        IF ( OLD_OK_CODE = 'CHANGE' ) OR ( OLD_OK_CODE = 'DELETE' )
            OR ( OLD_OK_CODE = 'RELEASE' )
            OR ( OLD_OK_CODE = 'APPROVE' ).
          IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL AND G_LOCK <> 'Y'.
            PERFORM LOCK_REQHD.
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

        IF NOT ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

          SELECT SINGLE * FROM ZIC_PREP_ROLEREQ
                     WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

**
          ZIC_PREP_ROLEREQ-COMM_FL = 'X'.

          IF SY-SUBRC = 0 .

*           select single moduleid from zic_prep_rolerei into
*           moduleid where DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

            SELECT DISTINCT MODULEID FROM ZIC_PREP_ROLEREI INTO
            CORRESPONDING FIELDS OF TABLE IT_MODULE1 WHERE DOCNO =
            ZIC_PREP_ROLEREQ-DOCNO.

            SORT IT_MODULE1 BY MODULEID. IF SY-SUBRC <> 0.

              SELECT DISTINCT MODULEID FROM ZIC_PREP_DELROLE INTO
              CORRESPONDING FIELDS OF TABLE IT_MODULE1 WHERE DOCNO =
              ZIC_PREP_ROLEREQ-DOCNO.

            SORT IT_MODULE1 BY MODULEID. ENDIF.

            DATA : L_MODULE_LINES LIKE SY-INDEX.

            DESCRIBE TABLE IT_MODULE1 LINES L_MODULE_LINES.

            READ TABLE IT_MODULE1 INTO WA_MODULE1 WITH KEY
                 MODULEID = 'FI'.
            IF SY-SUBRC = 0 AND WA_MODULE1-MODULEID = 'FI'.
              SET PARAMETER ID 'ZOLDCODE_FI' FIELD 'ASSIGN'.
              SET PARAMETER ID 'ZMODULEID_FI' FIELD 'FI'.
              SET PARAMETER ID 'ZUSERID_FI' FIELD ZIC_PREP_ROLEREQ-USERID.
              LEAVE TO TRANSACTION 'ZIC_AUTH_FI_REP' .
            ENDIF.

            IF L_MODULE_LINES > 1.
              G_MULT_MODULE_FL = 'X'.
            ENDIF.


            G_HD_COPIED = 'X'.
** check line items modulewise/initialise
            G_TABLCTRL110_COPIED = ''.
            G_TABLCTRL111_COPIED = ''.
            G_TABLCTRL112_COPIED = ''.
            G_TABLCTRL113_COPIED = ''.
            G_TABLCTRL114_COPIED = ''.
            G_TABLCTRL115_COPIED = ''.
            G_TABLCTRL116_COPIED = ''.
""""""
    G_TABLCTRL117_COPIED = ''.
   G_TABLCTRL118_COPIED = ''.
 """"""""
**

            IF ZIC_PREP_ROLEREQ-COMM_FL = 'X' AND OLD_OK_CODE = 'CHANGE'
            AND SY-TCODE <> 'ZIC_AUTH_CORETEAM'.

              PERFORM VERIFY2.

            ENDIF.

            PERFORM VALIDATIONS.

          ELSE.
            MESSAGE I101(ZHELP) WITH ZIC_PREP_ROLEREQ-DOCNO.
          ENDIF.

        ENDIF.

      ENDIF.

      SELECT SINGLE * FROM T500P
                 WHERE PERSA = ZIC_PREP_ROLEREQ-PERSA.

      IF SY-SUBRC = 0.

        ZIC_PREP_ROLEREQ-NAME1 = T500P-NAME1.

      ENDIF.


    ENDIF.

  ENDIF.

  SELECT SINGLE * FROM ZMM_PREP_RSN
             WHERE REASON = ZIC_PREP_ROLEREQ-RSN_CODE.

  IF SY-SUBRC = 0.

    ZIC_PREP_ROLEREQ-RSN_TEXT1 = ZMM_PREP_RSN-DESCRIPTION.

  ENDIF.

  SELECT SINGLE * FROM ZMM_PREP_STATUS
             WHERE STATUS_CODE = ZIC_PREP_ROLEREQ-STATUS .

  IF SY-SUBRC = 0.

    STATUS_DESC = ZMM_PREP_STATUS-STATUS_DESC.

  ENDIF.


  IF ZIC_PREP_ROLEREQ-FUNDC <> '' AND ZIC_PREP_ROLEREQ-REASON1 = ''.

    SET CURSOR FIELD 'ZIC_PREP_ROLEREQ-REASON1'.
    MESSAGE I100(ZHELP).
  ENDIF.

  PERFORM GET_CORRESPONDENCE.

ENDMODULE.                 " get_header_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_attr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR100_ATTR OUTPUT.

  CASE OLD_OK_CODE.

    WHEN ''.

      LOOP AT SCREEN.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN 'CREATE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.


      ENDLOOP.

    WHEN 'CHANGE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          IF MODULEID <> 'MM' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC'.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          IF MODULEID <> 'MM' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC'.
            SCREEN-INPUT = 0.
          ELSE.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP3 = 'GPC' .
          IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
            SCREEN-ACTIVE = 1.
          ELSE.
            SCREEN-ACTIVE = 0.
          ENDIF.
          SCREEN-INVISIBLE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERID' AND
           ZIC_PREP_ROLEREQ-USERID <> ''.
          SCREEN-INPUT = 0.
*           screen-required = 1.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-NAME1' ).
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL <> 'X'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REASON1'.
          IF NOT ZIC_PREP_ROLEREQ-FUNDC IS INITIAL.
            SCREEN-INPUT = 1.
            SCREEN-REQUIRED = 1.
          ELSE.
            SCREEN-INPUT = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'RELEASE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 0.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_CR_FL'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'APPROVE'.

      LOOP AT SCREEN.

        IF SCREEN-GROUP1 = 'GP1'.
          SCREEN-INPUT = 0.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP2 = 'GP2'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DISC_MM_FLAG'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'TABCTRL100_DELETE'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF G_USER = 'L1' AND SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_APP1_FL'
     .
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.
        IF ( G_USER = 'IM' OR G_USER = 'L3' ) AND
            SCREEN-NAME = 'ZIC_PREP_ROLEREQ-REQ_APP_FL'.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DISPLAY'.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DOCNO' OR SCREEN-NAME = 'CORR'
                                                 OR SCREEN-NAME = 'STAT'
                                                 OR SCREEN-NAME = 'M'
                                              OR SCREEN-NAME = 'MODULEID'
                                             OR SCREEN-NAME = 'DETAILS'
                                  OR SCREEN-NAME = 'TABCTRL100_PREVIOUS'
                                     OR SCREEN-NAME = 'TABCTRL100_NEXT'.
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP3 = 'GPC' AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
          SCREEN-ACTIVE = 1.
          SCREEN-INVISIBLE = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
           SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-USERID' OR
          SCREEN-NAME = 'ZIC_PREP_ROLEREQ-RSN_CODE' OR
          SCREEN-NAME = 'ZIC_PREP_ROLEREQ-TELNO' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    WHEN 'DELETE'.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREQ-DOCNO' OR SCREEN-NAME = 'CORR'
                                                  OR SCREEN-NAME = 'STAT'
     .
          SCREEN-INPUT = 1.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ELSE.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF ( SCREEN-NAME = 'ZIC_PREP_ROLEREQ-FUNDC_FL' OR
          SCREEN-NAME = 'IN' ) AND ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
          SCREEN-ACTIVE = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.


  ENDCASE.

ENDMODULE.                 " TABCTRL100_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0105 OUTPUT.

  SET PF-STATUS 'STAT105'.

ENDMODULE.                 " STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INITIALIZE OUTPUT.

  PERFORM GET_CORRESPONDENCE.

ENDMODULE.                 " INITIALIZE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.

  IF GV_SPLITTER1 IS INITIAL.
    CREATE OBJECT GV_CUSTOM_CONTAINER
      EXPORTING
        CONTAINER_NAME = 'C_DIS'.

    CREATE OBJECT GV_SPLITTER1
      EXPORTING
        PARENT        = GV_CUSTOM_CONTAINER
        ORIENTATION   = 1
        SASH_POSITION = 1.
  ENDIF.

  IF ( OLD_OK_CODE = 'CREATE' )
  OR ( OLD_OK_CODE = 'CROSSCO' )
  OR ( OLD_OK_CODE = 'CRCROLES' )
  OR ( OLD_OK_CODE = 'CHANGE' )
  OR ( OLD_OK_CODE = 'RELEASE' )
  OR ( OLD_OK_CODE = 'APPROVE' )
  OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

    IF GV_SPLITTER2 IS INITIAL.

      CREATE OBJECT GV_CUSTOM_CONTAINER
        EXPORTING
          CONTAINER_NAME = 'C_WRT'.


      CREATE OBJECT GV_SPLITTER2
        EXPORTING
          PARENT        = GV_CUSTOM_CONTAINER
          ORIENTATION   = 1
          SASH_POSITION = 1.

    ENDIF.
  ENDIF.

ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.

  IF GV_TEXT_EDITOR1 IS INITIAL.
    CREATE OBJECT GV_TEXT_EDITOR1
      EXPORTING
        PARENT                     = GV_SPLITTER1->BOTTOM_RIGHT_CONTAINER
        WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
        WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>FALSE
      EXCEPTIONS
        ERROR_CNTL_CREATE          = 1
        ERROR_CNTL_INIT            = 2
        ERROR_CNTL_LINK            = 3
        ERROR_DP_CREATE            = 4
        GUI_TYPE_NOT_SUPPORTED     = 5.
    FLAG1 = 'X'.
  ENDIF.
  IF ( OLD_OK_CODE = 'CREATE' )
      OR ( OLD_OK_CODE = 'CROSSCO' )
      OR ( OLD_OK_CODE = 'CRCROLES' )
      OR ( OLD_OK_CODE = 'CHANGE' )
      OR ( OLD_OK_CODE = 'RELEASE' )
      OR ( OLD_OK_CODE = 'APPROVE' )
       OR ( OLD_OK_CODE = 'DISPLAY' AND ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

    IF GV_TEXT_EDITOR2 IS INITIAL.
      CREATE OBJECT GV_TEXT_EDITOR2
        EXPORTING
          PARENT                     = GV_SPLITTER2->BOTTOM_RIGHT_CONTAINER
          WORDWRAP_MODE              = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
          WORDWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>FALSE
        EXCEPTIONS
          ERROR_CNTL_CREATE          = 1
          ERROR_CNTL_INIT            = 2
          ERROR_CNTL_LINK            = 3
          ERROR_DP_CREATE            = 4
          GUI_TYPE_NOT_SUPPORTED     = 5.
      FLAG2 = 'X'.
    ENDIF.
  ENDIF.

  PERFORM TEXT_CONTROL_EINGABEBEREIT1.
  PERFORM TEXT_CONTROL_SET_TEXT_TABLE1.

ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr100_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR100_COL_ATTRIB OUTPUT.

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
MODULE DELETE_DUP OUTPUT.

*if not g_TABCTRL100_itab[] is initial and okcode_100 <> 'COPY'.

  IF NOT G_TABCTRL100_ITAB[] IS INITIAL .

    SORT G_TABCTRL100_ITAB
    BY ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.
    DELETE ADJACENT DUPLICATES FROM G_TABCTRL100_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.

  DESCRIBE TABLE G_TABCTRL100_ITAB LINES TABCTRL100-LINES.

ENDMODULE.                 " delete_dup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_110 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL110_ITAB LINES TABLCTRL110-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_title  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_TITLE OUTPUT.

  IF L_OLD_OK_CODE = 'X' AND G_RESET_CHANGE <> 'X'.
    PERFORM AUTH_CHECK.
  ELSE.
    CLEAR G_RESET_CHANGE.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X'.
    G_TEXT = ' : Cross Company'.
  ENDIF.
  IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
    G_TEXT = ' : CRC'.
  ENDIF.

  IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
       ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**     or
**     zic_prep_rolereq-status = 'IR'..
    MOVE 'ROLE_DEL' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ROLE_CR' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.

    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB..
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    MOVE 'ROLE_DEL' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    MOVE 'ROLE_CR' TO WA_TAB-FCODE.
    APPEND WA_TAB TO IT_TAB.
    SET PF-STATUS 'OPTNS1' EXCLUDING IT_TAB.
  ENDIF.

  SET TITLEBAR 'PREP_TITLE' WITH G_TEXT.

ENDMODULE.                 " set_title  OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL110_INIT OUTPUT.
  IF G_TABLCTRL110_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.

    REFRESH G_TABLCTRL110_ITAB[].
    CLEAR   G_TABLCTRL110_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL110_ITAB WHERE MODULEID = 'MM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO ORDER BY PRIMARY KEY.
    G_TABLCTRL110_COPIED = 'X'.
    READ TABLE G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA INDEX 1.
    IF SY-SUBRC = 0.
      MODULEID = G_TABLCTRL110_WA-MODULEID.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL110' FROM SCREEN '0110'.
  ENDIF.
ENDMODULE.                    "TABLCTRL110_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL110_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL110_WA TO ZIC_PREP_ROLEREI.

  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

    IF OLD_OK_CODE = 'CRCROLES' OR ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_ROLECRC-BRIEF_DESC TO ROLE_DESC.
      ENDIF.
      SELECT * FROM ZMM_PREP_CRCDESG UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME AND ROLE_TYPE_EX = ZIC_PREP_ROLEREI-ROLE_TYPE_EX
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_CRCDESG-CRC_POS TO CRC_POS.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0 .
        MOVE ZMM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.                    "TABLCTRL110_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL110_GET_LINES OUTPUT.
  G_TABLCTRL110_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL110_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_DYNNR OUTPUT.
  IF DYNNR IS INITIAL.
    DYNNR = '101'.
  ENDIF.
  CASE MODULEID.

    WHEN 'MM'.
      DYNNR = '0110'.
    WHEN 'PM'.
      DYNNR = '0111'.
    WHEN 'PS'.
      DYNNR = '0112'.
    WHEN 'PP'.
      DYNNR = '0113'.
    WHEN 'SD'.
      DYNNR = '0114'.
    WHEN 'QM'.
      DYNNR = '0115'.
    WHEN 'HSE'.
      DYNNR = '0116'.
    WHEN 'OLM'.
      DYNNR = '0117'.

  """"""""""""""""""""""""
       WHEN 'SRM'.
      DYNNR = '0118'.
  """"""""""""""

  ENDCASE.
ENDMODULE.                 " set_dynnr  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR110_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL110-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL110-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

  LOOP AT TABLCTRL110-COLS INTO COLS WHERE INDEX = 12.
    COLS-INVISIBLE = '0'.
    MODIFY TABLCTRL110-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr110_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP_110 OUTPUT.

  IF NOT G_TABLCTRL110_ITAB[] IS INITIAL .

    SORT G_TABLCTRL110_ITAB
    BY ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.
    DELETE ADJACENT DUPLICATES FROM G_TABLCTRL110_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.

  DESCRIBE TABLE G_TABLCTRL110_ITAB LINES TABLCTRL110-LINES.

ENDMODULE.                 " delete_dup_110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL110_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL110_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL110_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

*        if sy-tcode = 'ZIC_AUTH_CORETEAM' and
*              screen-name = 'ZIC_PREP_ROLEREI-REJ_FL' and
*              old_ok_code = 'CHANGE' and ZIC_PREP_ROLEREI-REJ_FL = ''.
*          screen-input = 1.
*          modify screen.
*        endif.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.


        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      IF ZIC_PREP_ROLEREQ-CRC_FL = 'X' OR OLD_OK_CODE = 'CRCROLES'.

        SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                                                  G_TABLCTRL110_WA-ROLE_NAME
    .

        IF SY-SUBRC = 0.

          LOOP AT SCREEN.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ENDIF.


            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' .

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ELSE.

          LOOP AT SCREEN.

            IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                               NOT OLD_OK_CODE IS INITIAL.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.

              IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
                MESSAGE I116(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
              ENDIF.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

  ELSE.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

ENDMODULE.                 " TABLCTRL110_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL111_INIT OUTPUT.
  IF G_TABLCTRL111_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL111_ITAB[].
    CLEAR   G_TABLCTRL111_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL111_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL111_ITAB WHERE MODULEID = 'PM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL111_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL111' FROM SCREEN '0111'.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL111_MOVE OUTPUT.

  MOVE-CORRESPONDING G_TABLCTRL111_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL111_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL111_GET_LINES OUTPUT.
  G_TABLCTRL111_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL111_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP_111 OUTPUT.
  IF NOT G_TABLCTRL111_ITAB[] IS INITIAL .

    SORT G_TABLCTRL111_ITAB
    BY ROLE_NAME PLANT SHOP_NO.
    DELETE ADJACENT DUPLICATES FROM G_TABLCTRL111_ITAB
    COMPARING ROLE_NAME PLANT REJ_FL SHOP_NO.

  ENDIF.

  DESCRIBE TABLE G_TABLCTRL111_ITAB LINES TABLCTRL111-LINES.

ENDMODULE.                 " delete_dup_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL111_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL111_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL111_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_111 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL111_ITAB LINES TABLCTRL111-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR111_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL111-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL111-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr111_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABCTRL100_init  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCTRL100_INIT OUTPUT.

  PERFORM CHECK_LIST_PROCESSING.

  PERFORM GET_USER.

  PERFORM UPLOAD1_FILE.

  IF G_HD_COPIED IS INITIAL.

    DATA L_FIS_INITIAL.
    SET PARAMETER ID 'FIS' FIELD L_FIS_INITIAL.
    SET PARAMETER ID 'BUK' FIELD L_FIS_INITIAL.
  ENDIF.

  GET PARAMETER ID 'ZOLDCODE' FIELD L_OLD_OK_CODE.

  IF L_OLD_OK_CODE = 'X'.
    GET PARAMETER ID 'ZREQNO' FIELD ZIC_PREP_ROLEREQ-DOCNO.
    OLD_OK_CODE = 'CHANGE'.
  ENDIF.

ENDMODULE.                 " TABCTRL100_init  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_120 OUTPUT.

  PERFORM HIDE.
  SET PF-STATUS 'STATUS_120'.

ENDMODULE.                 " STATUS_120  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALUE_LIST OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  SET PF-STATUS 'STATUS_120' EXCLUDING TAB.
  CLEAR : WA_TAB.
  REFRESH : TAB.
  WRITE :'Selected Values for Company Code :',ZIC_PREP_ROLEREQ-CCODE
          COLOR COL_HEADING.
  ULINE.
  IF FLAG_S_FUNDC = 'X' AND OKCODE_100 <> 'SUIM'.
    PERFORM HELP_LIST.
  ENDIF.

  IF OKCODE_100 = 'SUIM'.
    PERFORM HELP_SUIM.
  ENDIF.

ENDMODULE.                 " value_list  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECT_DATA OUTPUT.
  SELECT SINGLE * FROM ZIC_PREP_ROLEREQ
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

  SELECT * FROM ZIC_PREP_ROLEREI INTO TABLE IST_ITEM
  WHERE DOCNO = ZIC_PREP_ROLEREQ-DOCNO.

ENDMODULE.                 " SELECT_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  value_list1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALUE_LIST1 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  DATA : L_DESC(30).
  SORT IST_ITEM DESCENDING.

  LOOP AT IST_ITEM INTO WA_ITEM.
    CASE WA_ITEM-MODULEID.
      WHEN 'MM'.
        PERFORM CHECK_MODULE_STATUS_MM.
      WHEN 'PM'.
        PERFORM CHECK_MODULE_STATUS_PM.
      WHEN 'PS'.
        PERFORM CHECK_MODULE_STATUS_PS.
      WHEN 'PP'.
        PERFORM CHECK_MODULE_STATUS_PP.
      WHEN 'SD'.
        PERFORM CHECK_MODULE_STATUS_SD.
      WHEN 'QM'.
        PERFORM CHECK_MODULE_STATUS_QM.
      WHEN 'HSE'.
        PERFORM CHECK_MODULE_STATUS_HSE.
    ENDCASE.
  ENDLOOP.

  LOOP AT IST_ITEM INTO WA_ITEM.

    CASE WA_ITEM-MODULEID .

      WHEN 'MM'.

        AT NEW MODULEID.

          WRITE :/.

          IF MM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.

          WRITE: / 'MM Module', 'Role', 'Description',
                 AT 48  'Plant',
                 AT 53  'PurGp',
                 AT 59  'Sloc',
                 AT 64  'RecptLoc',
                 AT 73  'User level' .

          FORMAT INTENSIFIED OFF COLOR OFF.

*     uline.

        ENDAT.

        IF ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

          SELECT BRIEF_DESC FROM ZMM_PREP_ROLECRC INTO L_DESC UP TO 1 ROWS
 WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        ELSE.

          SELECT SINGLE BRIEF_DESC FROM ZMM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        ENDIF.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 53 WA_ITEM-GRP,
                 AT 59 WA_ITEM-SLOC,
                 AT 64 WA_ITEM-RECEIPT_LOC,
                 AT 73 WA_ITEM-APPROVER.

      WHEN 'PM'.

        AT NEW MODULEID.

          WRITE /.

          IF PM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.

          WRITE: / 'PM Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 54  'ShopNo'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 54 WA_ITEM-SHOP_NO.
**
      WHEN 'PS'.

        AT NEW MODULEID.

          WRITE /.

          IF PS_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'PS Module', 'Role', 'Description',
             AT 48  'Service',
             AT 56  'Project',
             AT 64  'Location',
             AT 73  'Asset',
             AT 79  'Basin'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPS_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-SERVICE,
                 AT 56 WA_ITEM-PROJECT,
                 AT 64 WA_ITEM-LOCATION,
                 AT 73 WA_ITEM-ASSET,
                 AT 79 WA_ITEM-BASIN.

***

      WHEN 'PP'.

        AT NEW MODULEID.

          WRITE /.

          IF PP_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'PP Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 56  'Sloc',
             AT 64  'Resource',
             AT 73  'CTF_sloc'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZPP_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 56 WA_ITEM-SLOC,
                 AT 64 WA_ITEM-RES,
                 AT 73 WA_ITEM-CTF_SLOC.

      WHEN 'SD'.

        AT NEW MODULEID.

          WRITE /.

          IF SD_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'SD Module', 'Role', 'Description',
             AT 48  'S_Org',
             AT 56  'Div',
             AT 64  'Plant',
             AT 73  'ShPt'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZSD_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-SALE_ORG,
                 AT 56 WA_ITEM-DIV,
                 AT 64 WA_ITEM-PLANT,
                 AT 73 WA_ITEM-SHIP_POINT.

      WHEN 'QM'.

        AT NEW MODULEID.

          WRITE /.

          IF QM_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'QM Module', 'Role', 'Description',
             AT 48  'Plant',
             AT 56  'Asset'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZQM_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC,
                 AT 48 WA_ITEM-PLANT,
                 AT 56 WA_ITEM-ASSET_QM.

      WHEN 'HSE'.

        AT NEW MODULEID.

          WRITE /.

          IF HS_NOT_OK = 'X'.
            FORMAT INTENSIFIED ON COLOR 6.
          ELSE.
            FORMAT INTENSIFIED ON COLOR 5.
          ENDIF.
          WRITE: / 'HSE Module', 'Role', 'Description'.

          FORMAT INTENSIFIED OFF COLOR OFF.

*        uline.
        ENDAT.

        SELECT SINGLE BRIEF_DESC FROM ZHS_PREP_ROLEDES INTO L_DESC
              WHERE ROLE_TYPE = WA_ITEM-ROLE_NAME.

        WRITE: / WA_ITEM-MODULEID, AT 12 WA_ITEM-ROLE_NAME, AT 17 L_DESC.

    ENDCASE.

*
*
    HIDE : WA_ITEM-MODULEID, WA_ITEM-ROLE_NAME, WA_ITEM-PLANT,
             WA_ITEM-GRP, WA_ITEM-SLOC, WA_ITEM-RECEIPT_LOC,
             WA_ITEM-APPROVER, WA_ITEM-SERVICE, WA_ITEM-PROJECT,
             WA_ITEM-LOCATION,WA_ITEM-REGION,WA_ITEM-ASSET,
             WA_ITEM-BASIN,WA_ITEM-RES, WA_ITEM-CTF_SLOC,
             WA_ITEM-SALE_ORG,WA_ITEM-DIV,WA_ITEM-PLANT,
             WA_ITEM-SHIP_POINT.

  ENDLOOP.
**************************************
ENDMODULE.                 " value_list1  OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL112_INIT OUTPUT.
  IF G_TABLCTRL112_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL112_ITAB[].
    CLEAR   G_TABLCTRL112_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL112_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL112_ITAB WHERE
       MODULEID = 'PS' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL112_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL112' FROM SCREEN '0112'.
  ENDIF.
ENDMODULE.                    "TABLCTRL112_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL112_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL112_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPS_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL112_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL112_GET_LINES OUTPUT.
  G_TABLCTRL112_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL112_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL112_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL112_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SERVICE' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PROJECT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-LOCATION' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ASSET' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-BASIN' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_112 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL112_ITAB LINES TABLCTRL112-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_112  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR112_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL112-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL112-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr112_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr112_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR112_ATTRIB OUTPUT.

  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL112_DELETE' OR
             SCREEN-NAME = 'TABLCTRL112_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr112_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL113_INIT OUTPUT.

  IF G_TABLCTRL113_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL113_ITAB[].
    CLEAR   G_TABLCTRL113_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL113_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL113_ITAB WHERE MODULEID = 'PP' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL113_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL113' FROM SCREEN '0113'.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL113_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL113_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZPP_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL113_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL113_GET_LINES OUTPUT.
  G_TABLCTRL113_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL113_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR113_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL113-COLS INTO COLS WHERE INDEX GT 10.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL113-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr113_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR113_ATTRIB OUTPUT.
  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL113_DELETE' OR
             SCREEN-NAME = 'TABLCTRL113_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL113_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL113_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RES' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-CTF_SLOC' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL113_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_113  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_113 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL113_ITAB LINES TABLCTRL113-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_113.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_113  OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL114_INIT OUTPUT.
  IF G_TABLCTRL114_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL114_ITAB[].
    CLEAR   G_TABLCTRL114_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL114_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL114_ITAB WHERE MODULEID = 'SD' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL114_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL114' FROM SCREEN '0114'.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL114_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL114_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZSD_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL114_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL114_GET_LINES OUTPUT.
  G_TABLCTRL114_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL114_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR114_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL114-COLS INTO COLS WHERE INDEX GT 10.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL114-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.


ENDMODULE.                 " scr114_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR114_ATTRIB OUTPUT.

  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL114_DELETE' OR
             SCREEN-NAME = 'TABLCTRL114_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " scr114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL114_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.


  IF OLD_OK_CODE <> 'DISPLAY'.

    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL114_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
          OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
               SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
               AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
               AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
***

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SALE_ORG' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-DIV'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHIP_POINT' .
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL114_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_114  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_114 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL114_ITAB LINES TABLCTRL114-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_114.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_114  OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL115_INIT OUTPUT.
  IF G_TABLCTRL115_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL115_ITAB[].
    CLEAR   G_TABLCTRL115_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL115_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL115_ITAB WHERE
       MODULEID = 'QM' AND
       DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL115_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL115' FROM SCREEN '0115'.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL115_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL115_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZQM_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZQM_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL115_GET_LINES OUTPUT.
  G_TABLCTRL115_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL115_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR115_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL115-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL115-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.
ENDMODULE.                 " scr115_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR115_ATTRIB OUTPUT.
  LOOP AT SCREEN.
    IF OLD_OK_CODE = 'APPROVE'.
      IF SCREEN-NAME = 'TABLCTRL115_DELETE' OR
             SCREEN-NAME = 'TABLCTRL115_INSERT' OR
             SCREEN-NAME = 'COPY'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                 " scr115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_115  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_115 OUTPUT.
  DESCRIBE TABLE G_TABLCTRL115_ITAB LINES TABLCTRL115-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_115.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " set_cursor_115  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL115_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL115_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

ENDMODULE.                 " TABLCTRL115_attrib  OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: copy ddic-table to itab
MODULE TABLCTRL116_INIT OUTPUT.
  IF G_TABLCTRL116_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL116_ITAB[].
    CLEAR   G_TABLCTRL116_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL116_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL116_ITAB WHERE MODULEID = 'HSE' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL116_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL116' FROM SCREEN '0116'.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_init OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: move itab to dynpro
MODULE TABLCTRL116_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL116_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZHS_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                    "TABLCTRL116_move OUTPUT

*&spwizard: output module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE TABLCTRL116_GET_LINES OUTPUT.
  G_TABLCTRL116_LINES = SY-LOOPC.
ENDMODULE.                    "TABLCTRL116_get_lines OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL116_ATTRIB OUTPUT.

  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL116_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDMODULE.                 " TABLCTRL116_attrib  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  set_cursor_116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_116 OUTPUT.

  DESCRIBE TABLE G_TABLCTRL116_ITAB LINES TABLCTRL116-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_111
.
  ENDIF.

  CLEAR SY-UCOMM.

ENDMODULE.                 " set_cursor_116  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_116  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_116 OUTPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL116-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_116 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_116  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_DATA OUTPUT.
  G_ROLE_NAME_PREV = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data16  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA16 OUTPUT.

  SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data16  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  scr116_col_attrib  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR116_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL116-COLS INTO COLS WHERE INDEX GT 6.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL116-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " scr116_col_attrib  OUTPUT
************************************************************************
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_INIT OUTPUT.
  IF G_TABLCTRL117_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.
    REFRESH G_TABLCTRL117_ITAB[].
    CLEAR   G_TABLCTRL117_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL117_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL117_ITAB WHERE MODULEID = 'OLM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    G_TABLCTRL117_COPIED = 'X'.
    REFRESH CONTROL 'TABLCTRL117' FROM SCREEN '0117'.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR117_COL_ATTRIB OUTPUT.
  LOOP AT TABLCTRL117-COLS INTO COLS WHERE INDEX GT 8.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL117-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

ENDMODULE.                 " SCR117_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL117_WA TO ZIC_PREP_ROLEREI.
  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0 .
      MOVE ZOL_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_GET_LINES OUTPUT.
  G_TABLCTRL117_LINES = SY-LOOPC.
ENDMODULE.                 " TABLCTRL117_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_ATTRIB OUTPUT.
  IF OLD_OK_CODE = 'DISPLAY'.

    LOOP AT SCREEN.

      SCREEN-INPUT = 0.
      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY' .

    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                                              G_TABLCTRL117_WA-ROLE_NAME
.

    IF SY-SUBRC = 0.

      LOOP AT SCREEN.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
         OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
              OLD_OK_CODE = 'CHANGE' AND ZIC_PREP_ROLEREI-REJ_FL = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SY-TCODE = 'ZIC_AUTH_CORETEAM' AND
              SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS'
              AND ZIC_PREP_ROLEREQ-CRC_FL = 'X'
              AND ZIC_PREP_ROLEREI-ROLE_REQUEST = ''.
          SCREEN-INPUT = 1.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-STATUS' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
           ZIC_PREP_ROLEREI-ROLE_REQUEST <> ''.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

****
        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' .

          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT SCREEN.

        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDLOOP.

    ENDIF.

  ENDIF.
ENDMODULE.                 " TABLCTRL117_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_117 OUTPUT.
  DESCRIBE TABLE G_TABLCTRL117_ITAB LINES TABLCTRL117-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_110
.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " SET_CURSOR_117  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_INIT OUTPUT.
IF G_TABLCTRL118_COPIED IS INITIAL AND OLD_OK_CODE <> 'CREATE'.

    REFRESH G_TABLCTRL118_ITAB[].
    CLEAR   G_TABLCTRL118_ITAB.
*&spwizard: copy ddic-table 'ZIC_PREP_ROLEREI'
*&spwizard: into internal table 'g_TABLCTRL110_itab'
    SELECT * FROM ZIC_PREP_ROLEREI
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLCTRL118_ITAB WHERE MODULEID = 'SRM' AND
                DOCNO = ZIC_PREP_ROLEREQ-DOCNO ORDER BY PRIMARY KEY.
    G_TABLCTRL110_COPIED = 'X'.
    READ TABLE G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA INDEX 1.
    IF SY-SUBRC = 0.
      MODULEID = G_TABLCTRL118_WA-MODULEID.
    ENDIF.
    REFRESH CONTROL 'TABLCTRL118' FROM SCREEN '0118'.
  ENDIF.


ENDMODULE.                 " TABLCTRL118_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCR118_COL_ATTRIB OUTPUT.

  LOOP AT TABLCTRL118-COLS INTO COLS WHERE INDEX GT 11.
    COLS-INVISIBLE = '1'.
    MODIFY TABLCTRL118-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.

  LOOP AT TABLCTRL118-COLS INTO COLS WHERE INDEX = 12.
    COLS-INVISIBLE = '0'.
    MODIFY TABLCTRL118-COLS FROM COLS INDEX SY-TABIX.
  ENDLOOP.
ENDMODULE.                 " SCR118_COL_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MOVE OUTPUT.
  MOVE-CORRESPONDING G_TABLCTRL118_WA TO ZIC_PREP_ROLEREI.

  IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.
    ZIC_PREP_ROLEREI-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.


      SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0 .
        MOVE ZSR_PREP_ROLEDES-BRIEF_DESC TO ROLE_DESC.
      ENDIF.


  ENDIF.
ENDMODULE.                 " TABLCTRL118_MOVE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_GET_LINES OUTPUT.
  G_TABLCTRL118_LINES = SY-LOOPC.
ENDMODULE.                 " TABLCTRL118_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_ATTRIB OUTPUT.
 IF OLD_OK_CODE <> 'DISPLAY' AND OLD_OK_CODE <> ''.


      SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                                                G_TABLCTRL118_WA-ROLE_NAME.

      IF SY-SUBRC = 0.

        LOOP AT SCREEN.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.

            IF OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
            ELSE.
              SCREEN-INPUT = 0.
            ENDIF.
            MODIFY SCREEN.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-REJ_FL' AND
            OLD_OK_CODE = 'APPROVE' AND ZIC_PREP_ROLEREI-REJ_FL_SAVE = ''.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' .

            IF ZSR_PREP_ROLEDES-PLANT = 'X' AND
                          OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP'.

            IF ZSR_PREP_ROLEDES-P_GRP = 'X' AND
                          OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.

            IF ZSR_PREP_ROLEDES-APP_LEVEL = 'X' AND
                        OLD_OK_CODE <> 'APPROVE'.
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

*Begin of <RD1K962817>.
*          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER'.
*            IF G_TABLCTRL118_WA-ROLE_NAME = 'M8'.
*              IF ZSR_PREP_ROLEDES-APP_LEVEL = 'X' AND
*                          OLD_OK_CODE <> 'APPROVE'.
*
*                SCREEN-INPUT = 0.
*
*                MODIFY SCREEN.
*              ELSE.
*                SCREEN-INPUT = 0.
*                MODIFY SCREEN.
*              ENDIF.
*
*            ENDIF.
*          ENDIF.
*End of <RD1K962817>.
          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC'.

            IF ZSR_PREP_ROLEDES-S_LOC = 'X' AND
                      OLD_OK_CODE <> 'APPROVE'.
              .
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.
          ENDIF.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.

            IF ZSR_PREP_ROLEDES-R_LOC = 'X' AND
                      OLD_OK_CODE <> 'APPROVE'.
              .
              SCREEN-INPUT = 1.
              MODIFY SCREEN.
            ELSE.
              SCREEN-INPUT = 0.
              MODIFY SCREEN.
            ENDIF.

          ENDIF.

        ENDLOOP.

      ELSE.

        LOOP AT SCREEN.

          IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND
                         NOT OLD_OK_CODE IS INITIAL AND
                         OLD_OK_CODE <> 'APPROVE'.
            SCREEN-INPUT = 1.
            MODIFY SCREEN.
            IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL .
              MESSAGE I115(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
            ENDIF.
          ELSE.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.

        ENDLOOP.

      ENDIF.

*    ELSE.



*    ENDIF.

  ELSE.

    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
*
    ENDLOOP.
*

  ENDIF.

  LOOP AT SCREEN.

    IF ZIC_PREP_ROLEREI-REJ_FL <> ''.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


**************************************************************
  IF OLD_OK_CODE = 'DELETE'.

    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " TABLCTRL118_ATTRIB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_118  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_118 OUTPUT.
DESCRIBE TABLE G_TABLCTRL118_ITAB LINES TABLCTRL118-LINES.

  IF NOT G_FIELD IS INITIAL.
    SET CURSOR FIELD G_FIELD LINE G_I.
    CLEAR G_FIELD.
  ELSE.
    SET CURSOR FIELD 'ZIC_PREP_ROLEREI-ROLE_NAME' LINE G_CURR_LINE_118
.
  ENDIF.

  CLEAR SY-UCOMM.
ENDMODULE.                 " SET_CURSOR_118  OUTPUT
