*--- MAIN PROGRAM: MZMMPREPROLE3_PHASEIII01 ---*
*----------------------------------------------------------------------*
*   INCLUDE MZMMPREPROLEI01                                            *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
************************************************************************
*  Date            Transport      USERID        Description
* 30/04/2009      <RD1K963151>    SAB_SUMODH
*
*1)Change in Line 1020.
************************************************************************
MODULE USER_COMMAND_0100 INPUT.

  OKCODE = SY-UCOMM.

  CASE OKCODE.

    WHEN 'BAC' OR 'CAN'.

      PERFORM BAC_CONFIRM.
*      refresh control 'TABCTRL100' from screen '0100'.
      CLEAR OKCODE.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      G_MODE = 'CRE'.
      CLEAR OKCODE.

    WHEN 'CHANGE'.

      G_MODE = 'CHA'.
      CLEAR OKCODE.

    WHEN 'DISPLAY'.

      G_MODE = 'DIS'.
      CLEAR OKCODE.

    WHEN 'DELETE'.

      G_MODE = 'DEL'.
      CLEAR OKCODE.

    WHEN 'SAVE'.

*        perform check_items.
*        Perform Check_dupl_rec1.
      .
*        Perform Save_request.

      CLEAR OKCODE.

    WHEN 'RELEASE'.

      G_MODE = 'REL'.
      CLEAR OKCODE.

    WHEN 'APPROVE'.

      G_MODE = 'APR'.
      CLEAR OKCODE.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: modify table
MODULE TABCTRL100_MODIFY INPUT.

  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.

*  if old_ok_code = 'CRCROLES' or  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
*
*  else.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

*  endif.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER.
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABCTRL100_WA-ROLE_NAME IS INITIAL.
**
    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.
      SELECT * FROM ZMM_PREP_ROLECRC UP TO 1 ROWS
 WHERE ROLE_TYPE =
 ZIC_PREP_ROLEREI-ROLE_NAME
 ORDER BY PRIMARY KEY .
 ENDSELECT.
      IF SY-SUBRC = 0.
*        g_srno = g_srno + 1.
        G_TABCTRL100_WA-ROLE_DESC = ZMM_PREP_ROLECRC-BRIEF_DESC.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC = 0.
*        g_srno = g_srno + 1.
        G_TABCTRL100_WA-ROLE_DESC = ZMM_PREP_ROLEDES-BRIEF_DESC.
*        g_TABCTRL100_wa-srno = g_srno.
      ENDIF.

    ENDIF.
**
  ENDIF.
  MODIFY G_TABCTRL100_ITAB
    FROM G_TABCTRL100_WA
    INDEX TABCTRL100-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABCTRL100_WA TO G_TABCTRL100_ITAB.
  ENDIF.

  IF G_TABCTRL100_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABCTRL100_WA-FLAG.
    APPEND G_TABCTRL100_WA TO G_TABCTRL100_ITAB.
  ENDIF.

ENDMODULE.                    "TABCTRL100_modify INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: mark table
MODULE TABCTRL100_MARK INPUT.
  IF TABCTRL100-LINE_SEL_MODE = 1 AND
     G_TABCTRL100_WA-FLAG = 'X'.
    LOOP AT G_TABCTRL100_ITAB INTO G_TABCTRL100_WA
      WHERE FLAG = 'X'.
      G_TABCTRL100_WA-FLAG = ''.
      MODIFY G_TABCTRL100_ITAB
        FROM G_TABCTRL100_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABCTRL100_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABCTRL100_ITAB
    FROM G_TABCTRL100_WA
    INDEX TABCTRL100-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABCTRL100_mark INPUT

*&spwizard: input module for tc 'TABCTRL100'. do not change this line!
*&spwizard: process user command
MODULE TABCTRL100_USER_COMMAND INPUT.
**  OKCODE = sy-ucomm.
**  perform user_ok_tc using    'TABCTRL100'
**                              'G_TABCTRL100_ITAB'
**                              'FLAG'
**                     changing OKCODE.
**  sy-ucomm = OKCODE.
ENDMODULE.                    "TABCTRL100_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_PLANT INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-PLANT' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
                                               WITH  HEADER LINE.
  TYPES :
           BEGIN OF TY_BUKRS,
             WERKS LIKE ZD_T001W_BUKRS-WERKS,
             NAME1 LIKE ZD_T001W_BUKRS-NAME1,
           END OF TY_BUKRS.

  DATA   : IT_BUKRS TYPE TABLE OF TY_BUKRS WITH HEADER LINE.

  SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
             TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-PLANT'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_BUKRS
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    CONCATENATE '000'  ZIC_PREP_ROLEREQ-USERID INTO CPF_LFB1.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : L_EKGRP LIKE T024-EKGRP.
*  refresh : it_cond.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.

*if ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*  concatenate '''' '%' ZIC_PREP_ROLEREQ-CCODE '-' 'IND' ''''
*  into g_line1.
*  select * from t024 into table it_t024 where TELFX like g_line1.
*else.
*endif.

  DATA : LOOP_STEP LIKE SY-STEPL.
  DATA : L_ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0110'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF L_ROLE_NAME = 'M6' OR  L_ROLE_NAME = 'M7' OR
      L_ROLE_NAME = 'M8'.
    CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
    SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
  ELSE.
    IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
      CONCATENATE '%' G_CCODE '%' 'IND' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
      CONCATENATE  '%' G_CCODE '%' 'MM' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ENDIF.
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKGRP'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKNAM'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'EKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T024
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  FREE : IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR G_FIELD_WA.

ENDMODULE.                 " POV_GRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

  TYPES : BEGIN OF Z_ROLE_DES,
            ROLE_TYPE LIKE ZMM_PREP_ROLEDES-ROLE_TYPE,
            BRIEF_DESC LIKE ZMM_PREP_ROLEDES-BRIEF_DESC,
            DETAIL_DESC1 LIKE ZMM_PREP_ROLEDES-DETAIL_DESC1,
            DETAIL_DESC2 LIKE ZMM_PREP_ROLEDES-DETAIL_DESC2,
            SORT_FIELD LIKE ZMM_PREP_ROLEDES-BRIEF_DESC,
            MM_DISC_FLAG LIKE ZMM_PREP_ROLEDES-MM_DISC_FLAG,
          END OF Z_ROLE_DES.

*  DATA   : it_role type table of zmm_prep_roledes with header line.
  DATA   : IT_ROLE TYPE TABLE OF Z_ROLE_DES WITH HEADER LINE.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_ROLECRC INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  ELSE.

    SELECT * FROM ZMM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  ENDIF.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_header_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_HEADER_DATA INPUT.

  IF OLD_OK_CODE = 'DISPLAY' OR OLD_OK_CODE = 'CHANGE' OR
        OLD_OK_CODE = 'DELETE' OR OLD_OK_CODE = 'CREATE' OR
        OLD_OK_CODE = 'CROSSCO' OR ( OLD_OK_CODE = 'CRCROLES' )
        OR OLD_OK_CODE = 'RELEASE' OR ( OLD_OK_CODE = 'APPROVE' ).

    IF NOT  ZIC_PREP_ROLEREQ-USERID IS INITIAL.
      PERFORM CHECK_TEL.
    ENDIF.

    IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CROSSCO' OR
       OLD_OK_CODE = 'CRCROLES'.

      IF  ZIC_PREP_ROLEREQ-PERSA IS INITIAL AND
          ZIC_PREP_ROLEREQ-RSN_CODE = '01'.
        PERFORM POP_UP_MESSAGE.
      ENDIF.

      IF  ZIC_PREP_ROLEREQ-USERID IS INITIAL.
        MESSAGE E035(ZHELP).
      ENDIF.

      IF  ZIC_PREP_ROLEREQ-USERID <> OLD_USERID AND
        OLD_USERID <> ''.
        CLEAR  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
        CLEAR  ZIC_PREP_ROLEREQ-CCODE.
        CLEAR  ZIC_PREP_ROLEREQ-FUNDC1.
        CLEAR  ZIC_PREP_ROLEREQ-FUNDC.
        CLEAR  ZIC_PREP_ROLEREQ-S_DESC.
        CLEAR  ZIC_PREP_ROLEREQ-RSN_CODE.
        CLEAR  ZIC_PREP_ROLEREQ-RSN_TEXT1.
        CLEAR  ZIC_PREP_ROLEREQ-REASON1.
        CLEAR  ZIC_PREP_ROLEREQ-TELNO.
        CLEAR  ZIC_PREP_ROLEREQ-NAME.
        CLEAR  ZIC_PREP_ROLEREQ-DESIGNATION.
        CLEAR SET_DISC_MM_FLAG.
        CLEAR HELP_LIST_FLAG.
        REFRESH IT_M_FISTB.
        CLEAR WA_M_FISTB.
      ENDIF.

*        select single * from zusrmst where cpfno =
*                                    ZIC_PREP_ROLEREQ-userid.

      SELECT SINGLE * FROM USR02 WHERE BNAME =
                                  ZIC_PREP_ROLEREQ-USERID.

      IF SY-SUBRC NE 0.
        MESSAGE E043(ZHELP).
      ELSE.
*          concatenate zusrmst-first_name zusrmst-last_name into
*          zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-name = zusrmst-last_name.
*           ZIC_PREP_ROLEREQ-designation = zusrmst-designation.

        SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
             A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
           D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
           D~DISC_CD AS DISC_CD
             INTO CORRESPONDING FIELDS OF TABLE IST_DATA
        FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
              ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                 ON C~DESIGNO = D~DESIG_CODE AND
                     C~R_P_CD  = D~R_P_CD AND
                     C~VERSION = D~VERSION )
                  WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                        A~SPRPS = ' ' AND
                        A~ENDDA = '99991231' AND
                        C~SPRPS = ' ' AND
                        C~ENDDA = '99991231' .

        IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
          ZIC_PREP_ROLEREQ-NAME = IST_DATA-NAME.
          ZIC_PREP_ROLEREQ-DESIGNATION = IST_DATA-DESIGNATION.
          IF IST_DATA-DISC_CD = '36' AND SET_DISC_MM_FLAG <> 'X'.
            ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
            SET_DISC_MM_FLAG = 'X'.
          ENDIF.
***************************************************31.05.2006
          IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CRCROLES'.
            ZIC_PREP_ROLEREQ-CCODE = IST_DATA-BUKRS.
          ELSE.
            G_CCODE_CROSSCO        = IST_DATA-BUKRS.
          ENDIF.

***************************************************31.05.2006
*            if ist_data-disc_cd = '36' and
*             ZIC_PREP_ROLEREQ-disc_mm_flag <> old_disc_mm_flag.
*                 ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*            endif.

          IF OLD_OK_CODE = 'CREATE'.
            IF  ZIC_PREP_ROLEREQ-PERSA <> IST_DATA-WERKS AND
               NOT  ZIC_PREP_ROLEREQ-PERSA IS INITIAL.
              MESSAGE E108(ZHELP).
            ENDIF.
          ENDIF.

        ENDIF.

        CLEAR : IST_DATA.
        REFRESH : IST_DATA.

** Change company code, fund centre, costcentre logic 02.02.2006


        CONCATENATE '000'  ZIC_PREP_ROLEREQ-USERID INTO CPF_LFB1.

*          select single * from lfb1 where lifnr = cpf_lfb1.

* Select Company-KBU01, Cost Centre-kst01
* from pa0027  .
        CLEAR WA_PA0027.

        SELECT *
 FROM PA0027 INTO WA_PA0027 UP TO 1 ROWS WHERE PERNR = CPF_LFB1 AND ENDDA = '99991231' AND SPRPS = ' '
 ORDER BY PRIMARY KEY .
 ENDSELECT. " SPRPS - Lock Indicator 'X'

        IF SY-SUBRC = 0.
          IF OLD_OK_CODE <> 'CROSSCO'.
            CONCATENATE  '''' '%' WA_PA0027-KST01
                         '''' INTO  G_LINE1.
            CONCATENATE  'OBJNR'  'LIKE' G_LINE1 INTO G_LINE1
            SEPARATED BY SPACE.
            REFRESH :  IT_COND.
            APPEND G_LINE1 TO IT_COND.
            SELECT * FROM FMZUOB UP TO 1 ROWS
 WHERE (IT_COND)
 ORDER BY PRIMARY KEY .
 ENDSELECT.
          ENDIF.
          IF SY-SUBRC = 0.
            IF OLD_OK_CODE = 'CREATE' OR OLD_OK_CODE = 'CRCROLES'.
              ZIC_PREP_ROLEREQ-FUNDC1 = FMZUOB-FISTL.
              ZIC_PREP_ROLEREQ-FUNDC_FL = 'X'.
*               ZIC_PREP_ROLEREQ-CCODE = wa_pa0027-kbu01+0(3).
              ZIC_PREP_ROLEREQ-COSTC = WA_PA0027-KST01.
            ELSE.
*              G_CCODE_CROSSCO        = wa_pa0027-kbu01+0(3).
              ZIC_PREP_ROLEREQ-COSTC = WA_PA0027-KST01.
            ENDIF.

            SELECT * FROM CSKT UP TO 1 ROWS
 WHERE
 KOSTL = ZIC_PREP_ROLEREQ-COSTC
 ORDER BY PRIMARY KEY .
 ENDSELECT.

            IF SY-SUBRC =  0.
              ZIC_PREP_ROLEREQ-S_DESC = CSKT-LTEXT.
            ENDIF.

            REFRESH IT_COND[].
            CLEAR IT_COND.
          ELSE.
          ENDIF.
        ENDIF.

      ENDIF.

    ELSE.

***************************************************

***************************************************

      IF  ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.
        MESSAGE E041(ZHELP).
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_header_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  user_command_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_100 INPUT.

  IF OKCODE_DBLCLK = 'DBLCLK'.

    CALL TRANSACTION 'ZROLE_REQ2_COPY' AND SKIP FIRST SCREEN.

    CLEAR OKCODE_DBLCLK.

  ENDIF.


  CASE OKCODE_100.

    WHEN 'BAC' OR 'CAN'.
      PERFORM EXIT_CONFIRM.
    WHEN 'EXT'.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'CHANGE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'RELEASE'.

      OLD_OK_CODE = OKCODE_100.


    WHEN 'APPROVE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'COPY'.


    WHEN 'DISPLAY'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'ROLE_CR'.

      IF ZIC_PREP_ROLEREQ-STATUS = 'C'.
        MESSAGE E086(ZHELP).
      ELSE.
        CASE MODULEID.
          WHEN 'MM'.
            PERFORM CREATE_ROLES.
          WHEN 'PM'.
            PERFORM CREATE_ROLES_PM.
          WHEN 'PS'.
            PERFORM CREATE_ROLES_PS.
          WHEN 'PP'.
            PERFORM CREATE_ROLES_PP.
          WHEN 'SD'.
            PERFORM CREATE_ROLES_SD.
          WHEN 'QM'.
            PERFORM CREATE_ROLES_QM.
          WHEN 'HSE'.
            PERFORM CREATE_ROLES_HS.
          WHEN 'OLM'.
            PERFORM CREATE_ROLES_OLM.

            """""""""""""
          WHEN 'SRM'.
            PERFORM CREATE_ROLES_SRM.
            """""""""""""
        ENDCASE.
      ENDIF.

    WHEN 'SAV'.

      IF OLD_OK_CODE = 'DELETE'.

        IF  ZIC_PREP_ROLEREQ-USERIDCR = SY-UNAME.

*            if  ZIC_PREP_ROLEREQ-STATUS = 'N' or  " 30/05/2006

          IF  ZIC_PREP_ROLEREQ-STATUS = ''.
            PERFORM DELETE_REQUEST.
          ELSE.
            MESSAGE E138(ZHELP).
          ENDIF.
        ELSE.
          MESSAGE E056(ZHELP).
        ENDIF.
      ELSE.
        IF OLD_OK_CODE = 'RELEASE' AND
               ZIC_PREP_ROLEREQ-REQ_CR_FL <> 'X'.
          MESSAGE I083(ZHELP).

        ELSEIF OLD_OK_CODE = 'RELEASE' AND G_LINES_RL = 0.
          MESSAGE I089(ZHELP).

        ELSEIF OLD_OK_CODE = 'APPROVE' AND
              (  ZIC_PREP_ROLEREQ-REQ_APP_FL <> 'X' AND
               ZIC_PREP_ROLEREQ-REQ_APP0_FL <> 'X' AND
               ZIC_PREP_ROLEREQ-REQ_APP1_FL <> 'X' ).
          MESSAGE I087(ZHELP).
        ELSE.
**          Perform check_items.
          IF MODULEID <> 'MM'.
            G_APPROVER_LEVEL = 'L3'.
          ENDIF.
          PERFORM SAVE_REQUEST.
        ENDIF.
**       endif.
      ENDIF.

    WHEN 'MULTI'.

*      clear help_list_flag.

      CALL SCREEN 120 STARTING AT 10 5
                  ENDING   AT 90 15.
      CLEAR OKCODE_100.


    WHEN 'DELETE'.

      OLD_OK_CODE = OKCODE_100.

    WHEN 'SUIM'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      SUBMIT ZMMPREPROLE_ROLE_CREATE_REP WITH SELECTION-TABLE IST_SELTAB
      AND RETURN.

    WHEN 'DELETED_RL'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM_X'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      SUBMIT ZMMPREPROLE_DEL_REP WITH SELECTION-TABLE IST_SELTAB
      AND RETURN.

*      CALL SCREEN 120.
*      if okcode_100 = 'BAC'.
*        clear old_ok_code.
*      endif.

    WHEN 'LIST'.

      PERFORM LIST_FILES.
      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
        OLD_OK_CODE = 'DISPLAY'.
      ELSE.
        OLD_OK_CODE = 'CHANGE'.
      ENDIF.
      G_RESET_CHANGE = 'X'.


    WHEN 'ATTACH'.

      PERFORM ATTACH_FILES.
      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'.
        OLD_OK_CODE = 'DISPLAY'.
      ELSE.
        OLD_OK_CODE = 'CHANGE'.
      ENDIF.
      G_RESET_CHANGE = 'X'.

    WHEN 'CORR'.

      CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
      IF G_CLINES <> 0.
        CORR_CODE = OKCODE_100.
      ENDIF.

      CLEAR OKCODE_100.
      G_RESET_CHANGE = 'X'.

    WHEN 'ROLE_DEL'.

      REFRESH : IST_SELTAB.
      CLEAR   : SELTAB.

      SELTAB-SELNAME = 'P_REM'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
      CONCATENATE ZIC_PREP_ROLEREQ-DOCNO ' -ARMS-' MODULEID '-' INTO
SELTAB-LOW.
*          seltab-low   = p_docno.
      APPEND SELTAB TO IST_SELTAB.

      SELTAB-SELNAME = 'P_REM1'.
      SELTAB-SIGN    = 'I'.
      SELTAB-OPTION = 'EQ'.
*          concatenate zmm_prep_rolereq-docno ' -' into seltab-low.
      SELTAB-LOW   = ZIC_PREP_ROLEREQ-USERID.
      APPEND SELTAB TO IST_SELTAB.

      IF ZIC_PREP_ROLEREQ-STATUS = 'C' OR
         ZIC_PREP_ROLEREQ-STATUS = 'IC'.
**         or
**         zic_prep_rolereq-status = 'IR'..
        MESSAGE E121(ZHELP).

      ELSE.

        SUBMIT ZHELPROLE3 WITH SELECTION-TABLE IST_SELTAB AND RETURN.

        GET PARAMETER ID 'ZROLEREQNO' FIELD ZROLEREQNO.

        GET PARAMETER ID 'EXIT_VALUE' FIELD G_EXIT_VALUE.

        IF NOT ZROLEREQNO IS INITIAL AND ZROLEREQNO <> '00000000' AND
          G_EXIT_VALUE <> 'X'.
          SUBMIT ZBC_ROLE_REP01_RFC_DEL AND RETURN.
*
          SET PARAMETER ID 'ZROLEREQNO' FIELD ''.
          CLEAR ZROLEREQNO.
*            perform send_sapmail.
        ELSE.
          SET PARAMETER ID 'EXIT_VALUE' FIELD ''.
          CLEAR G_EXIT_VALUE.
        ENDIF.

      ENDIF.

      CLEAR SY-UCOMM.

    WHEN 'MAIL'.

      PERFORM CONFIRM_MAIL.

    WHEN 'SUMMARY'.

      SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                  FIELD ZIC_PREP_ROLEREQ-DOCNO.

      CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.


    WHEN 'POSTING'.

      SET PARAMETER ID 'XUS'
                  FIELD ZIC_PREP_ROLEREQ-USERID.

*Begin of <RD1K963151>.
*      CALL TRANSACTION 'ZMMUSERDATA_MULT' AND SKIP FIRST SCREEN.
      CALL TRANSACTION  'ZMMUSERDATA' AND SKIP FIRST SCREEN.
*End of <<RD1K963151>.

    WHEN 'STAT_MOD'.

      SET PARAMETER ID 'ZROLEREQNOFORDETAILS'
                  FIELD ZIC_PREP_ROLEREQ-DOCNO.

      CALL SCREEN 200 STARTING AT 10 15  ENDING AT 90 25.

    WHEN OTHERS.

      CLEAR OKCODE_100.


  ENDCASE.

ENDMODULE.                 " user_command_100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0120 INPUT.


ENDMODULE.                 " USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*&      Module  move_ok_code  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MOVE_OK_CODE INPUT.


*  ********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.
  OKCODE_RJ = OLD_OK_CODE.
  CRT_NAME = ZIC_PREP_ROLEREQ-USERIDCR.
  TCODE_RJ = SY-TCODE.

  EXPORT OKCODE_RJ TO MEMORY ID 'OKCODE_RJ'.
  EXPORT CRT_NAME TO MEMORY ID 'CRT_NAME_RJ'.
  EXPORT TCODE_RJ TO MEMORY ID 'TCODE_IM'.
********************* Added by Bipin to export the value for ZGRC_RISK_NALYSIS_RESULT.

  IF SY-UCOMM = 'DBLCLK'.
    OKCODE_DBLCLK = SY-UCOMM.
    CLEAR SY-UCOMM.
  ENDIF.
  OKCODE_100 = SY-UCOMM.

  CLEAR :  ERR_FLG.

  CASE OKCODE.
    WHEN 'GRC_RISK'.

      CLEAR GT_BUCKET_EX.

      IF MODULEID = 'MM'.
        LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.

          MOVE-CORRESPONDING G_TABLCTRL110_WA TO WA_BUCKET_EX.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET_EX TO GT_BUCKET_EX.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF MODULEID = 'SD'.
        LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.

          MOVE-CORRESPONDING G_TABLCTRL114_WA TO WA_BUCKET_EX.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET_EX TO GT_BUCKET_EX.
*    CLEAR WA_BUCKET.
        ENDLOOP.
      ELSEIF MODULEID = 'PP'.
        LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.

          MOVE-CORRESPONDING G_TABLCTRL113_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'PM'.
        LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.

          MOVE-CORRESPONDING G_TABLCTRL111_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'PS'.
        LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.

          MOVE-CORRESPONDING G_TABLCTRL112_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ELSEIF MODULEID = 'HSE'.
        LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA.

          MOVE-CORRESPONDING G_TABLCTRL116_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.


      ELSEIF MODULEID = 'QM'.
        LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.

          MOVE-CORRESPONDING G_TABLCTRL115_WA TO WA_BUCKET.
          WA_BUCKET-DOCNO = ZIC_PREP_ROLEREQ-DOCNO.
          APPEND WA_BUCKET TO GT_BUCKET.
*    CLEAR WA_BUCKET.
        ENDLOOP.

      ENDIF.

      EXPORT GT_BUCKET_EX TO MEMORY ID 'TABLE_IM'.

      SELECT * FROM TVARVC INTO CORRESPONDING FIELDS OF TABLE IT_TVARV
      WHERE NAME = 'ZGRC_CALL'.
      READ TABLE IT_TVARV INTO WA_TVARV WITH KEY NAME = 'ZGRC_CALL'.
      LV_GRCCALL = WA_TVARV-LOW.

      LV_GRCCALL = WA_TVARV-LOW.
      CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
        EXPORTING
          RFCDESTINATION = 'GRDCLNT500'
        IMPORTING
*         MSGV1          =
*         MSGV2          =
          RFC_SUBRC      = LV_SUBRC.
      IF  LV_GRCCALL = 'X' AND LV_SUBRC = '0'.

        REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
        EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
        OKCODE_EX = OLD_OK_CODE.
        EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
*        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + COMMENT BY VIKAS
        CALL TRANSACTION 'ZGRC_RISK_RESULT'. " + aDDED BY VIKAS

        IMPORT OC_9001_RJ FROM MEMORY ID 'OC_9001_IM'.
        IF OC_9001_RJ = 'REJECT'.
          LEAVE PROGRAM.
        ENDIF.

        IF OLD_OK_CODE EQ 'CREATE' OR OLD_OK_CODE EQ 'CHANGE'.
*          LEAVE PROGRAM."-BY VIKAS
          RETURN."+ by Vikas
*          LEAVE TO SCREEN 0.
*          SET SCREEN
        ENDIF.

*        IMPORT LV_EXPO FROM MEMORY ID 'LV_IMP'.
*********************************End of changes : Changes by Bipin Shukla on 24 july 2013
*        IF LV_EXPO = ''. " ADDED BY BIPIN
*          PERFORM SAVE_REQUEST.
*        ENDIF.       " ADDED BY BIPIN

      ENDIF.
*      CLEAR REQNUM_EX.
*      CLEAR: OKCODE.
*      CLEAR OKCODE_EX.
    WHEN 'GRC_RAL1'.
      REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
      EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
      OKCODE_EX = OLD_OK_CODE.
      EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_SEC_RESULT'.

      CLEAR REQNUM_EX.
      CLEAR OKCODE_EX.

    WHEN  'GRC_RPL1'.
      REQNUM_EX = ZIC_PREP_ROLEREQ-DOCNO.
      EXPORT REQNUM_EX TO MEMORY ID 'REQNUM_IM'.
      OKCODE_EX = OLD_OK_CODE.
      EXPORT OKCODE_EX TO MEMORY ID 'OKCODE_IM'.
      CALL TRANSACTION 'ZGRC_VIOL'.

      CLEAR REQNUM_EX.
      CLEAR OKCODE_EX.

    WHEN OTHERS.
  ENDCASE.

**  get cursor line g_cursor_line.
**  g_curr_line = g_cursor_line.
**  g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
**  g_curr_line_100 = g_curr_line.

ENDMODULE.                 " move_ok_code  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_DATA INPUT.

  IF NOT  ZIC_PREP_ROLEREQ-DOCNO IS INITIAL.

*    DATA : l_docno LIKE  zic_prep_rolereq-docno.

    CLEAR L_DOCNO.

    L_DOCNO =  ZIC_PREP_ROLEREQ-DOCNO.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = L_DOCNO
      IMPORTING
        OUTPUT = L_DOCNO.

    ZIC_PREP_ROLEREQ-DOCNO = L_DOCNO.

  ENDIF.
*Begin of <RD1K963151>.
  PERFORM LOCK_REQHD.
*End of <RD1K963151>.
  IF OLD_DOC_NO <>  ZIC_PREP_ROLEREQ-DOCNO.
    CLEAR G_HD_COPIED.
    PERFORM DESTROY_CTRL.
  ENDIF.

  IF NOT MODULEID IS INITIAL AND OLD_MODULEID <> MODULEID.
    G_TABLCTRL110_COPIED = ''.
    G_TABLCTRL111_COPIED = ''.

    """""""""""""""""
    G_TABLCTRL118_COPIED = ''.

    """""""""""""
  ENDIF.

ENDMODULE.                 " clear_data  INPUT
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
  IF ( OLD_OK_CODE = 'CREATE' )
  OR ( OLD_OK_CODE = 'CROSSCO' )
  OR ( OLD_OK_CODE = 'CRCROLES' )
  OR ( OLD_OK_CODE = 'CHANGE' )
  OR ( OLD_OK_CODE = 'RELEASE' )
  OR ( OLD_OK_CODE = 'APPROVE' )
   OR ( OLD_OK_CODE = 'DISPLAY' AND  ZIC_PREP_ROLEREQ-STATUS = 'IR' )
  .

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
      DESCRIBE TABLE TLINETAB2 LINES G_CLINES.
      CLEAR OKCODE105.
    WHEN 'CANCEL'.
      REFRESH TLINETAB2[].
      CLEAR OKCODE105.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SLOC INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SLOC' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : L_PLANT LIKE ZIC_PREP_ROLEREI-PLANT.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'PLANT'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_PLANT.


  DATA   : IT_T001L TYPE TABLE OF T001L WITH HEADER LINE.
  DATA   : IT_EXCP_SL TYPE TABLE OF ZMM_PREP_SL_EXCP WITH HEADER LINE.
  DATA   : WA_T001L LIKE T001L.
  DATA   : L_ZAREA LIKE ZMM_CONSM-ZAREA.

  SELECT * FROM T001L INTO CORRESPONDING FIELDS OF
             TABLE IT_T001L  WHERE WERKS = L_PLANT.

  IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

    LOOP AT IT_T001L INTO WA_T001L.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF SY-SUBRC = 0.

        IF L_ZAREA+0(1) <> 'M'.
          DELETE IT_T001L.
        ENDIF.

      ELSE.

        DELETE IT_T001L.

      ENDIF.

    ENDLOOP.

  ELSE.

    LOOP AT IT_T001L INTO WA_T001L.

      SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

      IF SY-SUBRC = 0.

        IF L_ZAREA+0(1) = 'M'.
          DELETE IT_T001L.
        ENDIF.

      ELSE.

        DELETE IT_T001L.

      ENDIF.

    ENDLOOP.

  ENDIF.

  SELECT * FROM ZMM_PREP_SL_EXCP INTO TABLE IT_EXCP_SL.

************************************

  LOOP AT IT_EXCP_SL.

    READ TABLE IT_T001L WITH KEY WERKS = IT_EXCP_SL-WERKS
    LGORT = IT_EXCP_SL-LGORT.

    IF SY-SUBRC = 0.

      DELETE IT_T001L WHERE WERKS = IT_EXCP_SL-WERKS
      AND LGORT = IT_EXCP_SL-LGORT.

    ENDIF.

  ENDLOOP.

************************************
  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'WERKS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'LGORT'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T001L'.
  G_FIELD_WA-FIELDNAME = 'LGOBE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LGORT'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SLOC'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T001L
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T001L,IST_RETURN_TAB,G_FIELD_TAB..
  FREE  : IT_T001L,IST_RETURN_TAB,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_SLOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_APPROVER INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-APPROVER' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : IT_APPROVER LIKE TABLE OF ZMM_PREP_APPROVE.
  DATA : WA_APPROVER LIKE ZMM_PREP_APPROVE.

  DATA : IT_APPROVER1 LIKE TABLE OF ZMM_PREP_APP_CRC.
  DATA : WA_APPROVER1 LIKE ZMM_PREP_APP_CRC.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

    SELECT * FROM ZMM_PREP_APP_CRC INTO TABLE IT_APPROVER1.

  ELSE.

    SELECT * FROM ZMM_PREP_APPROVE INTO TABLE IT_APPROVER.

  ENDIF.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
*
*
*              if l_role_name = 'M11'.
*
*                  loop at it_approver into wa_approver.
*
*                    if wa_approver-M11_FLAG <> 'X'.
*                      delete it_approver.
*                    endif.
*
*                  endloop.
*
*              endif.
*
*      endif.


*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*         if l_role_name = 'M11'.
*
*            loop at it_approver into wa_approver.
*
*                if wa_approver-M11_FLAG <> 'X'.
*                    delete it_approver.
*                 endif.
*
*            endloop.
*
*         endif.
*
*      endif.
*******************************************************
  IF L_ROLE_NAME = 'M11S'.                                  "22.05.06

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

        WHEN 'X'.
          IF WA_APPROVER-MM_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
        WHEN OTHERS.
          IF WA_APPROVER-M11S_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.

  IF L_ROLE_NAME = 'M11M'.

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

        WHEN 'X'.
          IF WA_APPROVER-MM_FLAG <> 'X'
             OR WA_APPROVER-M11M_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
        WHEN OTHERS.
          IF WA_APPROVER-MM_FLAG = 'X'
             OR WA_APPROVER-M11M_FLAG <> 'X'.
            DELETE IT_APPROVER.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDIF.
**************************************************22.05.06

  IF L_ROLE_NAME = 'M8'.

    LOOP AT IT_APPROVER INTO WA_APPROVER.

      IF WA_APPROVER-M8_FLAG <> 'X'.
        DELETE IT_APPROVER.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

    IF L_ROLE_NAME = 'M3'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M3A'.                                 "22.05.06

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3A_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M3B'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

        IF WA_APPROVER1-M3B_FLAG <> 'X'.
          DELETE IT_APPROVER1.
        ENDIF.

      ENDLOOP.

    ENDIF.                                                  " 22.05.06


    IF L_ROLE_NAME = 'M11S'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

*                    if wa_approver1-M11S_FLAG <> 'X'.
*                        delete it_approver1.
*                    endif.
        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER1-MM_FLAG <> 'X'
               OR WA_APPROVER1-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER1-MM_FLAG = 'X'
               OR WA_APPROVER1-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M11M'.

      LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

*                    if wa_approver1-M11M_FLAG <> 'X'.
*                        delete it_approver1.
*                     endif.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER1-MM_FLAG <> 'X'
               OR WA_APPROVER1-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER1-MM_FLAG = 'X'
               OR WA_APPROVER1-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER1.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IT_APPROVER[] = IT_APPROVER1[].

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_APPROVE'.
  G_FIELD_WA-FIELDNAME = 'APP_LEVEL'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_APPROVE'.
  G_FIELD_WA-FIELDNAME = 'L_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'APP_LEVEL'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-APPROVER'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_APPROVER
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_APPROVER,IST_RETURN_TAB, IT_APPROVER1,G_FIELD_TAB.
  FREE  : IT_APPROVER,IST_RETURN_TAB, IT_APPROVER1,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_APPROVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_RECEIPT_LOC INPUT.

  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-RECEIPT_LOC' AND SCREEN-INPUT =
0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


  DATA : IT_RECPT LIKE TABLE OF ZMM_LOCATION.
  DATA : WA_RECPT LIKE ZMM_LOCATION.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_ROLE_NAME.

  SELECT * FROM ZMM_LOCATION INTO TABLE IT_RECPT.


  IF L_ROLE_NAME = 'M12'.

    LOOP AT IT_RECPT INTO WA_RECPT.

      IF WA_RECPT-LOCCG <> 'RL'.
        DELETE IT_RECPT.
      ENDIF.

    ENDLOOP.

  ENDIF.


  IF L_ROLE_NAME = 'M17'.

    LOOP AT IT_RECPT INTO WA_RECPT.

      IF WA_RECPT-LOCCG <> 'CF'.
        DELETE IT_RECPT.
      ENDIF.

    ENDLOOP.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCCD'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCCG'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_LOCATION'.
  G_FIELD_WA-FIELDNAME = 'LOCDS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'LOCCD'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_RECPT
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_RECPT,IST_RETURN_TAB,G_FIELD_TAB.
  FREE  : IT_RECPT,IST_RETURN_TAB,G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_RECEIPT_LOC  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  IF SY-UCOMM = 'EXT'.
    LEAVE PROGRAM.
  ENDIF.

ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_DATA INPUT.

  OLD_DOC_NO =  ZIC_PREP_ROLEREQ-DOCNO.
  OLD_USERID =  ZIC_PREP_ROLEREQ-USERID.
  OLD_DISC_MM_FLAG =  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.
  OLD_MODULEID = MODULEID.

ENDMODULE.                 " check_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

*SELECT single *
*       FROM pa0027
*       INTO wa_pa0027
*       WHERE pernr = cpf_lfb1 AND
*             endda = '99991231' AND
*             sprps = ' ' . " SPRPS - Lock Indicator 'X'
*
*G_CCODE = wa_pa0027-kbu01+0(3).

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

*  clear g_e_fl.

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                      ZIC_PREP_ROLEREI-ROLE_NAME.

      IF SY-SUBRC <> 0.
        G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE I117(ZHELP).
      ENDIF.

    ELSE.
      SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                      ZIC_PREP_ROLEREI-ROLE_NAME.
      IF SY-SUBRC <> 0.
        G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
        MESSAGE I118(ZHELP).
      ENDIF.

    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-RECEIPT_LOC.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-GRP.
    CLEAR  ZIC_PREP_ROLEREI-APPROVER.

    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-RECEIPT_LOC.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-GRP.
    CLEAR  ZIC_PREP_ROLEREI-APPROVER.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.

*  select single * from zmm_prep_roledes  where
*            role_type = ZIC_PREP_ROLEREI-role_name.
*  if sy-subrc <> 0.
*       message e067(zhelp) with ZIC_PREP_ROLEREI-role_name.
*  else.

** put validation for MM discipline roles????

    IF OLD_OK_CODE = 'CRCROLES'.

    ELSE.

      IF ZMM_PREP_ROLEDES-MM_DISC_FLAG = 'X'.

        IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
        ELSE.
          IF ZIC_PREP_ROLEREI-ROLE_NAME <> ''.
            MESSAGE E081(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

*  endif.

    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                 TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                    AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      ENDIF.

    ENDIF.

************finding group*******************

    REFRESH : IT_COND, IT_T024, IT_T024_1.
    CLEAR   : WA_T024.
*  concatenate 'EKGRP'  'LIKE'  into g_line1  separated by
*  space.
*  IF G_CCODE = 'SBS' or G_CCODE = 'SBW'.
*    g_select = 'R%'.
*    g_select_flag = 'X'.
*  ENDIF.
**  IF G_CCODE = 'JOR'.
*  IF G_CCODE = 'DVP'.
*    g_select = 'L%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'ANK'.
*    g_select = 'A%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'BDA' or G_CCODE = 'BDW'.
*    g_select = 'B%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'CBY'.
*    g_select = 'C%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AMD'.
*    g_select = 'D%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MHN'.
*    g_select = 'E%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'JDH'.
*    g_select = 'G%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'RJY'.
*    g_select = 'K%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'SIL'.
*    g_select = 'S%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'AGT'.
*    g_select = 'T%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'MBP'.
*    g_select = 'W%'.
*    g_select_flag = 'X'.
*
*  ENDIF.
*  IF G_CCODE = 'KKL'.
*    g_select = 'M%'.
*    g_select_flag = 'X'.
*
*    concatenate g_line1+0(10)  '''' g_select '''' into g_line1 .
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*    g_select = 'V%'.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024_1 where (it_cond).
*    refresh it_cond.
*    append lines of it_t024_1 to it_t024.
*    refresh it_t024_1.
*
*  ENDIF.
**
*  if G_CCODE <> 'KKL'.
*    refresh it_cond.
*    concatenate  g_line1+0(10)  '''' g_select '''' into g_line1.
*    append g_line1 to it_cond.
*    select * from t024 into table it_t024 where (it_cond).
*    refresh it_cond.
*  endif.
*
*  if g_select_flag <> 'X'.
*    select * from t024 into table it_t024 where
*            ( ekgrp not between 'A' and 'EZZ' ) and
*            ( ekgrp not between 'K' and 'MZZ' ) and
*            ( ekgrp not between 'G' and 'GZZ' ) and
*            ( ekgrp not between 'R' and 'TZZ' ) and
*            ( ekgrp not between 'V' and 'WZZ' ).
*  endif.
*
*
* if l_role_name = 'M6' or  l_role_name = 'M7' or
*     l_role_name = 'M8'.
*
* else.
*
*      if  ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*
*            loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) between '0' and 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*
*      else.
*
*          loop at it_t024 into wa_t024.
*
*             l_ekgrp = wa_t024-ekgrp.
*
*              if l_ekgrp+1(1) < '0'  or
*              l_ekgrp+1(1) > 'A'.
*                delete it_t024.
*              endif.
*
*          endloop.
*
*      endif.
*
* endif.
*
**
    IF G_TABLCTRL110_WA-ROLE_NAME = 'M6' OR
        G_TABLCTRL110_WA-ROLE_NAME = 'M7' OR
        G_TABLCTRL110_WA-ROLE_NAME = 'M8'.
      CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
      IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
        CONCATENATE '%' G_CCODE '%' 'IND' '%'
        INTO G_LINE1.
        SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
      ELSE.
        CONCATENATE  '%' G_CCODE '%' 'MM' '%'
        INTO G_LINE1.
        SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
      ENDIF.
    ENDIF.
**
    IF  NOT ZIC_PREP_ROLEREI-GRP IS INITIAL.

      LOOP AT IT_T024 INTO WA_T024.

*           if ZIC_PREP_ROLEREI-GRP = wa_t024-ekgrp.
*              grp_flag = 'X'.
*           endif.

        IF G_TABLCTRL110_WA-GRP = WA_T024-EKGRP.
          GRP_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF GRP_FLAG = 'X'.
        CLEAR GRP_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_READ_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
        MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.
        MODIFY G_TABCTRL100_ITAB
                  FROM G_TABCTRL100_WA
                    INDEX TABCTRL100-CURRENT_LINE.
        G_I = TABCTRL100-CURRENT_LINE.
        MESSAGE I069(ZHELP).
        CALL SCREEN 100.

      ENDIF.

    ENDIF.

***************************

    CLEAR : L_ZAREA, WA_T001L.
    REFRESH IT_T001L.

    IF ( ZIC_PREP_ROLEREI-ROLE_NAME = 'M13' OR
       ZIC_PREP_ROLEREI-ROLE_NAME = 'M14' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M16' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M18' OR
        ZIC_PREP_ROLEREI-ROLE_NAME = 'M19' ) AND
        NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM T001L INTO CORRESPONDING FIELDS OF
                   TABLE IT_T001L  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT.

      IF  SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        MESSAGE E074(ZHELP).

      ENDIF.

    ENDIF.

    IF  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.

      LOOP AT IT_T001L INTO WA_T001L.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF SY-SUBRC = 0.

          IF L_ZAREA+0(1) <> 'M'.
            DELETE IT_T001L.
          ENDIF.

        ELSE.

          DELETE IT_T001L.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT IT_T001L INTO WA_T001L.

        SELECT ZAREA FROM ZMM_CONSM INTO L_ZAREA UP TO 1 ROWS
 WHERE ZLOC = WA_T001L-LGORT
 ORDER BY PRIMARY KEY .
 ENDSELECT.

        IF SY-SUBRC = 0.

          IF L_ZAREA+0(1) = 'M'.
            DELETE IT_T001L.
          ENDIF.

        ELSE.

          DELETE IT_T001L.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF  NOT ZIC_PREP_ROLEREI-SLOC IS INITIAL.

      LOOP AT IT_T001L INTO WA_T001L.

        IF ZIC_PREP_ROLEREI-SLOC = WA_T001L-LGORT.
          LOC_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF LOC_FLAG = 'X'.
        CLEAR LOC_FLAG.
      ELSE.
** cab_ajit 07.02.2006
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
        MESSAGE E073(ZHELP).

      ENDIF.

    ENDIF.


***************************

    CLEAR WA_RECPT.
    REFRESH IT_RECPT.

    IF ( ZIC_PREP_ROLEREI-ROLE_NAME = 'M12' OR
       ZIC_PREP_ROLEREI-ROLE_NAME = 'M17' ) AND
       NOT ZIC_PREP_ROLEREI-RECEIPT_LOC IS INITIAL.

      SELECT * FROM ZMM_LOCATION INTO TABLE IT_RECPT.

      IF ZIC_PREP_ROLEREI-ROLE_NAME = 'M12'.

        LOOP AT IT_RECPT INTO WA_RECPT.

          IF WA_RECPT-LOCCG <> 'RL'.
            DELETE IT_RECPT.
          ENDIF.

        ENDLOOP.

      ENDIF.


      IF ZIC_PREP_ROLEREI-ROLE_NAME = 'M17'.

        LOOP AT IT_RECPT INTO WA_RECPT.

          IF WA_RECPT-LOCCG <> 'CF'.
            DELETE IT_RECPT.
          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

    IF  NOT ZIC_PREP_ROLEREI-RECEIPT_LOC IS INITIAL.

      LOOP AT IT_RECPT INTO WA_RECPT.

        IF ZIC_PREP_ROLEREI-RECEIPT_LOC = WA_RECPT-LOCCD.
          LOC_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF LOC_FLAG = 'X'.
        CLEAR LOC_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-RECEIPT_LOC'.
        MESSAGE E075(ZHELP).

      ENDIF.

    ENDIF.


*****************************
*****************************22.05.06

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'.

      SELECT * FROM ZMM_PREP_APP_CRC INTO TABLE IT_APPROVER1.

    ELSE.

      SELECT * FROM ZMM_PREP_APPROVE INTO TABLE IT_APPROVER.

    ENDIF.

    IF L_ROLE_NAME = 'M11S'.                                "22.05.06

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER-MM_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER-M11S_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.

    IF L_ROLE_NAME = 'M11M'.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

          WHEN 'X'.
            IF WA_APPROVER-MM_FLAG <> 'X'
               OR WA_APPROVER-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
          WHEN OTHERS.
            IF WA_APPROVER-MM_FLAG = 'X'
               OR WA_APPROVER-M11M_FLAG <> 'X'.
              DELETE IT_APPROVER.
            ENDIF.
        ENDCASE.

      ENDLOOP.

    ENDIF.
**************************************************22.05.06

    IF L_ROLE_NAME = 'M8'.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        IF WA_APPROVER-M8_FLAG <> 'X'.
          DELETE IT_APPROVER.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF OLD_OK_CODE = 'CRCROLES' OR  ZIC_PREP_ROLEREQ-CRC_FL = 'X'..

      IF L_ROLE_NAME = 'M3'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M3A'.                               "22.05.06

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3A_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M3B'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          IF WA_APPROVER1-M3B_FLAG <> 'X'.
            DELETE IT_APPROVER1.
          ENDIF.

        ENDLOOP.

      ENDIF.                                                " 22.05.06


      IF L_ROLE_NAME = 'M11S'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

            WHEN 'X'.
              IF WA_APPROVER1-MM_FLAG <> 'X'
                 OR WA_APPROVER1-M11S_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
            WHEN OTHERS.
              IF WA_APPROVER1-MM_FLAG = 'X'
                 OR WA_APPROVER1-M11S_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      IF L_ROLE_NAME = 'M11M'.

        LOOP AT IT_APPROVER1 INTO WA_APPROVER1.

          CASE  ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

            WHEN 'X'.
              IF WA_APPROVER1-MM_FLAG <> 'X'
                 OR WA_APPROVER1-M11M_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
            WHEN OTHERS.
              IF WA_APPROVER1-MM_FLAG = 'X'
                 OR WA_APPROVER1-M11M_FLAG <> 'X'.
                DELETE IT_APPROVER1.
              ENDIF.
          ENDCASE.

        ENDLOOP.

      ENDIF.

      IT_APPROVER[] = IT_APPROVER1[].

    ENDIF.
*********************************************22.05.06

    IF  NOT ZIC_PREP_ROLEREI-APPROVER IS INITIAL.

      LOOP AT IT_APPROVER INTO WA_APPROVER.

        IF ZIC_PREP_ROLEREI-APPROVER = WA_APPROVER-APP_LEVEL.
          APPROVER_FLAG = 'X'.
        ENDIF.

      ENDLOOP.

      IF APPROVER_FLAG = 'X'.
        CLEAR APPROVER_FLAG.
      ELSE.
        G_E_FL = 'X'.
        G_READ_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-APPROVER'.
        MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABCTRL100_WA.
        MODIFY G_TABCTRL100_ITAB
                  FROM G_TABCTRL100_WA
                    INDEX TABCTRL100-CURRENT_LINE.
        G_I = TABCTRL100-CURRENT_LINE.
        MESSAGE E135(ZHELP).
        CALL SCREEN 100.

      ENDIF.

    ENDIF.


  ENDIF.

ENDMODULE.                 " validate_lineitem_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE RECORD_REJ_ID_DATA INPUT.

*if old_ok_code <> 'DISPLAY' and old_ok_code <> 'CHANGE'.
**
  IF ZIC_PREP_ROLEREI-REJ_ID IS INITIAL.
    ZIC_PREP_ROLEREI-REJ_ID = SY-UNAME.
    ZIC_PREP_ROLEREI-REJ_DATE = SY-DATUM.
  ENDIF.

  IF NOT ZIC_PREP_ROLEREI-REJ_FL IS INITIAL AND
     ZIC_PREP_ROLEREI-REJ_FL_SAVE IS INITIAL.

    SELECT SINGLE * FROM  ZMM_PREP_REJ_LIS  WHERE
      REJ_CODE = ZIC_PREP_ROLEREI-REJ_FL .
    IF SY-SUBRC <> 0.
      G_E_FL = 'X'.
      MESSAGE E111(ZHELP).
    ELSE.
      IF SY-UNAME+0(1) = 'C' AND
                    ZIC_PREP_ROLEREI-REJ_FL = 'F' OR
****
                    ZIC_PREP_ROLEREI-REJ_FL = 'A'.
      ELSE.
        G_E_FL = 'X'.
        MESSAGE E111(ZHELP).

*      if g_user = 'L1' and ZIC_PREP_ROLEREI-rej_fl <> 'R'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      elseif g_user = 'L3' and ZIC_PREP_ROLEREI-rej_fl <> 'B'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      elseif g_user = 'IM' and ZIC_PREP_ROLEREI-rej_fl <> 'I'.
*        g_e_fl = 'X'.
*        message e111(zhelp).
*      endif.
      ENDIF.
    ENDIF.
  ENDIF.
**
*endif.
ENDMODULE.                 " record_rej_id_data  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_TEL INPUT.

  DATA : TEL_LEN TYPE I.
  TEL_LEN = STRLEN(  ZIC_PREP_ROLEREQ-TELNO ).
  IF   ZIC_PREP_ROLEREQ-TELNO CN ' 0123456789-'.
    MESSAGE E097(ZHELP).
  ELSE.
    IF TEL_LEN < 7.
      MESSAGE E098(ZHELP).
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_TEL  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA1 INPUT.

  IF OLD_OK_CODE = 'CRCROLES'.

    SELECT SINGLE * FROM ZMM_PREP_ROLECRC WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.
  ELSE.

    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data1  INPUT
*&---------------------------------------------------------------------*
*&      Module  clear_read  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CLEAR_READ INPUT.
  CLEAR G_READ_FL.
ENDMODULE.                 " clear_read  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL110_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL110_ITAB FROM G_TABLCTRL110_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL110_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL110_ITAB  LINES TABLCTRL110-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno  INPUT
*&---------------------------------------------------------------------*
*&      Module  delete_dup  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DELETE_DUP INPUT.
  IF NOT G_TABCTRL100_ITAB[] IS INITIAL .

    DELETE ADJACENT DUPLICATES FROM G_TABCTRL100_ITAB
    COMPARING ROLE_NAME PLANT GRP SLOC RECEIPT_LOC APPROVER.

  ENDIF.
ENDMODULE.                 " delete_dup  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_data  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_DATA INPUT.
  G_ROLE_NAME_PREV = ZIC_PREP_ROLEREI-ROLE_NAME.
ENDMODULE.                 " init_data  INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL110_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL110_WA.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER.
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABLCTRL110_WA-ROLE_NAME IS INITIAL.
    SELECT SINGLE * FROM ZMM_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0.
      G_TABLCTRL110_WA-ROLE_DESC = ZMM_PREP_ROLEDES-BRIEF_DESC.
    ENDIF.
  ENDIF.

  MODIFY G_TABLCTRL110_ITAB
     FROM G_TABLCTRL110_WA
     INDEX TABLCTRL110-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL110_WA TO G_TABLCTRL110_ITAB.
  ENDIF.

  IF G_CURR_LINE_110 = SY-STEPL AND OKCODE_100 = 'COPY'.
    APPEND G_TABLCTRL110_WA TO G_TABLCTRL110_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
  G_CURR_LINE_110 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_110 = SY-STEPL AND OKCODE_100 = 'TABLCTRL110_DELE' AND
        G_TABLCTRL110_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL110_modify INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL110_MARK INPUT.
  IF TABLCTRL110-LINE_SEL_MODE = 1 AND
     G_TABLCTRL110_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL110_ITAB INTO G_TABLCTRL110_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL110_WA-FLAG = ''.
      MODIFY G_TABLCTRL110_ITAB
        FROM G_TABLCTRL110_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL110_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL110_ITAB
    FROM G_TABLCTRL110_WA
    INDEX TABLCTRL110-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL110_mark INPUT

*&spwizard: input module for tc 'TABLCTRL110'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL110_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL110'
                              'G_TABLCTRL110_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL110_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_110 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL110-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_110 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_110  INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL111_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL111_WA.

  SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL111_WA-ROLE_DESC = ZPM_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL111_ITAB
    FROM G_TABLCTRL111_WA
    INDEX TABLCTRL111-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL111_WA TO G_TABLCTRL111_ITAB.
  ENDIF.

  IF G_TABLCTRL111_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL111_WA-FLAG.
    APPEND G_TABLCTRL111_WA TO G_TABLCTRL111_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_111 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_111 = SY-STEPL AND OKCODE_100 = 'TABLCTRL111_DELE' AND
        G_TABLCTRL111_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL111_modify INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL111_MARK INPUT.
  IF TABLCTRL111-LINE_SEL_MODE = 1 AND
     G_TABLCTRL111_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL111_WA-FLAG = ''.
      MODIFY G_TABLCTRL111_ITAB
        FROM G_TABLCTRL111_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL111_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL111_ITAB
    FROM G_TABLCTRL111_WA
    INDEX TABLCTRL111-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL111_mark INPUT

*&spwizard: input module for tc 'TABLCTRL111'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL111_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL111'
                              'G_TABLCTRL111_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL111_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_111 INPUT.

  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL111-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_111 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_111  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA11 INPUT.

  SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data11  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA11A INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                 TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                    AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      IF ZIC_PREP_ROLEREQ-CCODE = 'BDW' OR
         ZIC_PREP_ROLEREQ-CCODE = 'SBW'.
      ELSE.
        DELETE IT_ROLE WHERE ROLE_TYPE = 'PM14' OR
        ROLE_TYPE = 'PM15' OR ROLE_TYPE = 'PM16'.
      ENDIF.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " validate_lineitem_data11a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO11 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL111_ITAB INTO G_TABLCTRL111_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL111_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL111_ITAB FROM G_TABLCTRL111_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL111_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL111_ITAB  LINES TABLCTRL111-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno11  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_PM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*

  SELECT * FROM ZPM_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF ZIC_PREP_ROLEREQ-CCODE = 'BDW' OR
     ZIC_PREP_ROLEREQ-CCODE = 'SBW'.
  ELSE.
    DELETE IT_ROLE WHERE ROLE_TYPE = 'PM14' OR
    ROLE_TYPE = 'PM15' OR ROLE_TYPE = 'PM16'.
  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZPM_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE_PM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_SHOP_NO INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-SHOP_NO' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.


*  DATA  :  IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
*                                               WITH  HEADER LINE.
  TYPES :
           BEGIN OF TY_SHOP,
             WERKS LIKE T357-WERKS,
             BEBER LIKE T357-BEBER,
             FING  LIKE T357-FING,
           END OF TY_SHOP.

  DATA   : IT_SHOP TYPE TABLE OF TY_SHOP WITH HEADER LINE.

  SELECT * FROM T357 INTO CORRESPONDING FIELDS OF
             TABLE IT_SHOP  WHERE WERKS =  '53C1' OR
                                  WERKS =  '24C1'.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BEBER'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-SHOP_NO'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_SHOP
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_BUKRS,IST_RETURN_TAB.
  FREE : IT_BUKRS,IST_RETURN_TAB.

ENDMODULE.                 " POV_SHOP_NO  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_MODULEID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_MODULEID INPUT.
  DATA : IT_MODULE LIKE TABLE OF ZIC_MODULES.
  DATA : WA_MODULE LIKE ZIC_MODULES.

*  data : l_docno like zic_prep_rolereq-DOCNO.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREQ'
      FIELD = 'DOCNO'
      REPID = SY-CPROG
      DYNNR = '0100'
    IMPORTING
      VALUE = L_DOCNO.


  IF OLD_OK_CODE <> 'CREATE' .

    SELECT DISTINCT MODULEID FROM ZIC_PREP_ROLEREI INTO CORRESPONDING
    FIELDS OF TABLE IT_MODULE WHERE DOCNO = L_DOCNO.

  ELSE.

    SELECT  MODULEID FROM ZICE_PREP_MODULE INTO CORRESPONDING FIELDS
    OF TABLE IT_MODULE.
  ENDIF.

  LOOP AT IT_MODULE INTO WA_MODULE.
    SELECT SINGLE * FROM ZICE_PREP_MODULE WHERE MODULEID =
    WA_MODULE-MODULEID.
    WA_MODULE-Z_DESC = ZICE_PREP_MODULE-Z_DESC.
    MODIFY IT_MODULE FROM WA_MODULE.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MODULEID'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'MODULEID'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_MODULE
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_MODULE,IST_RETURN_TAB.
  FREE  : IT_MODULE,IST_RETURN_TAB.

ENDMODULE.                 " POV_MODULEID  INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL112_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL112_WA.
  SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL112_WA-ROLE_DESC = ZPM_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL112_ITAB
   FROM G_TABLCTRL112_WA
   INDEX TABLCTRL112-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL112_WA TO G_TABLCTRL112_ITAB.
  ENDIF.

  IF G_TABLCTRL112_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL111_WA-FLAG.
    APPEND G_TABLCTRL112_WA TO G_TABLCTRL112_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
  G_CURR_LINE_112 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_112 = SY-STEPL AND OKCODE_100 = 'TABLCTRL112_DELE' AND
        G_TABLCTRL112_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.

ENDMODULE.                    "TABLCTRL112_modify INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL112_MARK INPUT.
  IF TABLCTRL112-LINE_SEL_MODE = 1 AND
     G_TABLCTRL112_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL112_WA-FLAG = ''.
      MODIFY G_TABLCTRL112_ITAB
        FROM G_TABLCTRL112_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL112_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL112_ITAB
    FROM G_TABLCTRL112_WA
    INDEX TABLCTRL112-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL112_mark INPUT

*&spwizard: input module for tc 'TABLCTRL112'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL112_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL112'
                              'G_TABLCTRL112_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL112_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_112 INPUT.
  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL112-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_112 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_112  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA12 INPUT.
  SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data12  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA12A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  ZIC_PREP_ROLEREI-PROJECT.
    CLEAR  ZIC_PREP_ROLEREI-LOCATION.
*  clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  ZIC_PREP_ROLEREI-ASSET.
    CLEAR  ZIC_PREP_ROLEREI-BASIN.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SERVICE.
    CLEAR  ZIC_PREP_ROLEREI-PROJECT.
    CLEAR  ZIC_PREP_ROLEREI-LOCATION.
*      clear  ZIC_PREP_ROLEREI-REGION.
    CLEAR  ZIC_PREP_ROLEREI-ASSET.
    CLEAR  ZIC_PREP_ROLEREI-BASIN.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-SERVICE IS INITIAL.

      SELECT * FROM ZPS_PREP_SERVICE INTO CORRESPONDING FIELDS OF
                 TABLE IT_SERVICE WHERE
                 SERVICE = ZIC_PREP_ROLEREI-SERVICE.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SERVICE'.
        G_I = G_CURR_LINE_112.
        MESSAGE E169(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-PROJECT IS INITIAL.

      SELECT * FROM ZPS_PREP_PROJECT INTO CORRESPONDING FIELDS OF
                 TABLE IT_PROJECT WHERE
                 SERVICE = ZIC_PREP_ROLEREI-SERVICE AND
                 PROJECT = ZIC_PREP_ROLEREI-PROJECT.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PROJECT'.
        G_I = G_CURR_LINE.
        MESSAGE E170(ZHELP) WITH ZIC_PREP_ROLEREI-PROJECT.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-LOCATION IS INITIAL.

      SELECT * FROM ZPS_PREP_LOCA INTO CORRESPONDING FIELDS OF
             TABLE IT_LOCA WHERE CCODE = ZIC_PREP_ROLEREQ-CCODE
             AND LOCATION = ZIC_PREP_ROLEREI-LOCATION AND
             SERVICE = ZIC_PREP_ROLEREI-SERVICE.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-LOCATION'.
        G_I = G_CURR_LINE.
        MESSAGE E171(ZHELP) WITH ZIC_PREP_ROLEREI-LOCATION.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ASSET IS INITIAL.

      IF ZIC_PREP_ROLEREQ-CCODE = 'MUM'.
        SELECT * FROM ZPS_PREP_ASST_EX INTO CORRESPONDING FIELDS OF
              TABLE IT_ASSET WHERE CCODE = 'MUM' AND
                    ASSET = ZIC_PREP_ROLEREI-ASSET.

        IF SY-SUBRC <> 0 AND ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
          G_I = G_CURR_LINE.
          MESSAGE E172(ZHELP) WITH ZIC_PREP_ROLEREI-ASSET.
        ENDIF.

      ELSE.
        IF ZIC_PREP_ROLEREI-ASSET <> ZIC_PREP_ROLEREQ-CCODE AND
           ZIC_PREP_ROLEREI-ASSET <> 'ALL'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-ASSET'.
          G_I = G_CURR_LINE.
          MESSAGE E172(ZHELP) WITH ZIC_PREP_ROLEREI-ASSET.
        ENDIF.
      ENDIF.
    ENDIF.


    IF NOT ZIC_PREP_ROLEREI-BASIN IS INITIAL.

      IF ZIC_PREP_ROLEREI-BASIN <> ZIC_PREP_ROLEREQ-CCODE AND
          ZIC_PREP_ROLEREI-BASIN <> 'ALL'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-BASIN'.
        G_I = G_CURR_LINE.
        MESSAGE E173(ZHELP) WITH ZIC_PREP_ROLEREI-BASIN.
      ENDIF.

    ENDIF.



    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPS_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data12a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno12  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO12 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL112_ITAB INTO G_TABLCTRL112_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL112_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL112_ITAB FROM G_TABLCTRL112_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL112_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL112_ITAB  LINES TABLCTRL112-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " change_srno12  INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL113_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL113_WA.

  SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL113_WA-ROLE_DESC = ZPP_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL113_ITAB
  FROM G_TABLCTRL113_WA
  INDEX TABLCTRL113-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL113_WA TO G_TABLCTRL113_ITAB.
  ENDIF.

  IF G_TABLCTRL113_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL113_WA-FLAG.
    APPEND G_TABLCTRL113_WA TO G_TABLCTRL113_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
   G_CURR_LINE_113 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL113_modify INPUT

*&spwizard: input module for tc 'TABLCTRL113'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL113_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL113'
                              'G_TABLCTRL113_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL113_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_113 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL113-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_113 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_113  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA13 INPUT.
  SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.

ENDMODULE.                 " validate_lineitem_data13  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA13A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZPP_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-RES.
    CLEAR  ZIC_PREP_ROLEREI-CTF_SLOC.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SLOC.
    CLEAR  ZIC_PREP_ROLEREI-RES.
    CLEAR  ZIC_PREP_ROLEREI-CTF_SLOC.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                     TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                        AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE_113.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-SLOC IS INITIAL.

      SELECT SINGLE * FROM T001L INTO CORRESPONDING FIELDS OF
               IT_T001L  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT
               AND LGORT = ZIC_PREP_ROLEREI-SLOC.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SLOC'.
        G_I = G_CURR_LINE.
        MESSAGE E073(ZHELP) WITH ZIC_PREP_ROLEREI-SLOC.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-RES IS INITIAL.

      SELECT SINGLE * FROM ZPP_PREP_RES INTO CORRESPONDING FIELDS OF
             IT_RES  WHERE ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME
             AND
             PLANT = ZIC_PREP_ROLEREI-PLANT
             AND
             RES = ZIC_PREP_ROLEREI-RES.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-RES'.
        G_I = G_CURR_LINE.
        MESSAGE E183(ZHELP) WITH ZIC_PREP_ROLEREI-RES.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-CTF_SLOC IS INITIAL.

      SELECT SINGLE * FROM ZPP_PREP_DROLEEX WHERE ROLE_TYPE =
          ZIC_PREP_ROLEREI-ROLE_NAME
          AND PLANT = ZIC_PREP_ROLEREI-PLANT
          AND SLOC = ZIC_PREP_ROLEREI-SLOC
          AND CTF_SLOC = ZIC_PREP_ROLEREI-CTF_SLOC.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-CTF_SLOC'.
        G_I = G_CURR_LINE.
        MESSAGE E073(ZHELP) WITH ZIC_PREP_ROLEREI-CTF_SLOC.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZPP_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data13a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno13  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO13 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL113_ITAB INTO G_TABLCTRL113_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL113_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL113_ITAB FROM G_TABLCTRL113_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL113_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL113_ITAB  LINES TABLCTRL113-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno13  INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL114_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL114_WA.

  SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL114_WA-ROLE_DESC = ZPP_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL114_ITAB
    FROM G_TABLCTRL114_WA
    INDEX TABLCTRL114-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL114_WA TO G_TABLCTRL114_ITAB.
  ENDIF.

  IF G_TABLCTRL114_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL114_WA-FLAG.
    APPEND G_TABLCTRL114_WA TO G_TABLCTRL114_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_114 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL114_modify INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL114_MARK INPUT.
  IF TABLCTRL114-LINE_SEL_MODE = 1 AND
     G_TABLCTRL114_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL114_WA-FLAG = ''.
      MODIFY G_TABLCTRL114_ITAB
        FROM G_TABLCTRL114_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL114_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL114_ITAB
    FROM G_TABLCTRL114_WA
    INDEX TABLCTRL114-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL114_mark INPUT

*&spwizard: input module for tc 'TABLCTRL114'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL114_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL114'
                              'G_TABLCTRL114_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL114_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_114 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL114-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_114 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_114  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA14 INPUT.

ENDMODULE.                 " validate_lineitem_data14  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA14A INPUT.

  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZSD_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ELSE.
      G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SALE_ORG.
    CLEAR  ZIC_PREP_ROLEREI-DIV.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SHIP_POINT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SALE_ORG.
    CLEAR  ZIC_PREP_ROLEREI-DIV.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR  ZIC_PREP_ROLEREI-SHIP_POINT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


    IF NOT ZIC_PREP_ROLEREI-PLANT IS INITIAL.

      SELECT * FROM ZD_T001W_BUKRS INTO CORRESPONDING FIELDS OF
                     TABLE IT_BUKRS  WHERE BUKRS =  ZIC_PREP_ROLEREQ-CCODE
                                        AND WERKS = ZIC_PREP_ROLEREI-PLANT.
      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.
        G_I = G_CURR_LINE_114.
        MESSAGE E068(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-SALE_ORG IS INITIAL.

      SELECT SINGLE * FROM TVKO CLIENT SPECIFIED INTO CORRESPONDING FIELDS
               OF IT_TVKO  WHERE MANDT = SY-MANDT AND
               BUKRS =  ZIC_PREP_ROLEREQ-CCODE AND
               VKORG = ZIC_PREP_ROLEREI-SALE_ORG.

      IF SY-SUBRC <> 0 AND ZIC_PREP_ROLEREI-SALE_ORG <> 'ALL'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
        G_I = G_CURR_LINE_114.
        MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
***
      ELSEIF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
              ZIC_PREP_ROLEREQ-FUNDC1 = 'MUMPHPOP' AND
          ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPSP' AND         "12102015
              ZIC_PREP_ROLEREI-SALE_ORG <> 'HZRS'.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
        G_I = G_CURR_LINE_114.
        MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
      ELSE.
        IF ZIC_PREP_ROLEREQ-CCODE = 'MUM' AND
        ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPOP' AND
            ZIC_PREP_ROLEREQ-FUNDC1 <> 'MUMPHPSP' AND       "12102015
        ZIC_PREP_ROLEREI-SALE_ORG = 'HZRS'.
          G_E_FL = 'X'.
          G_FIELD = 'ZIC_PREP_ROLEREI-SALE_ORG'.
          G_I = G_CURR_LINE_114.
          MESSAGE E186(ZHELP) WITH ZIC_PREP_ROLEREI-SALE_ORG.
        ENDIF.
***
      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-DIV IS INITIAL.

      SELECT SINGLE * FROM TVKOS CLIENT SPECIFIED INTO CORRESPONDING
               FIELDS OF IT_TVKOS  WHERE MANDT = SY-MANDT AND
               VKORG =  ZIC_PREP_ROLEREI-SALE_ORG AND
               SPART =  ZIC_PREP_ROLEREI-DIV.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-DIV'.
        G_I = G_CURR_LINE_114.
        MESSAGE E187(ZHELP) WITH ZIC_PREP_ROLEREI-DIV.

      ENDIF.

    ENDIF.


    IF NOT ZIC_PREP_ROLEREI-SHIP_POINT IS INITIAL.

      SELECT SINGLE * FROM TVSWZ INTO CORRESPONDING FIELDS OF
            IT_TVSWZ  WHERE WERKS = ZIC_PREP_ROLEREI-PLANT AND
            VSTEL = ZIC_PREP_ROLEREI-SHIP_POINT.

      IF SY-SUBRC <> 0.
        G_E_FL = 'X'.
        G_FIELD = 'ZIC_PREP_ROLEREI-SHIP_POINT'.
        G_I = G_CURR_LINE.
        MESSAGE E188(ZHELP) WITH ZIC_PREP_ROLEREI-SHIP_POINT.

      ENDIF.

    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZSD_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.

ENDMODULE.                 " validate_lineitem_data14a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno14  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO14 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL114_ITAB INTO G_TABLCTRL114_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL114_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL114_ITAB FROM G_TABLCTRL114_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL114_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL114_ITAB  LINES TABLCTRL114-LINES.
  CLEAR G_SRNO.

ENDMODULE.                 " change_srno14  INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL115_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL115_WA.
  SELECT SINGLE * FROM ZQM_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL115_WA-ROLE_DESC = ZQM_PREP_ROLEDES-BRIEF_DESC.
  MODIFY G_TABLCTRL115_ITAB
    FROM G_TABLCTRL115_WA
    INDEX TABLCTRL115-CURRENT_LINE.
  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL115_WA TO G_TABLCTRL115_ITAB.
  ENDIF.

  IF G_TABLCTRL115_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL115_WA-FLAG.
    APPEND G_TABLCTRL115_WA TO G_TABLCTRL115_ITAB.
  ENDIF.
  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_115 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.
ENDMODULE.                    "TABLCTRL115_modify INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL115_MARK INPUT.
  IF TABLCTRL115-LINE_SEL_MODE = 1 AND
     G_TABLCTRL115_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL115_WA-FLAG = ''.
      MODIFY G_TABLCTRL115_ITAB
        FROM G_TABLCTRL115_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL115_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL115_ITAB
    FROM G_TABLCTRL115_WA
    INDEX TABLCTRL115-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL115_mark INPUT

*&spwizard: input module for tc 'TABLCTRL115'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL115_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL115'
                              'G_TABLCTRL115_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL115_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_115 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL115-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_115 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_115  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA15 INPUT.

ENDMODULE.                 " validate_lineitem_data15  INPUT
*&---------------------------------------------------------------------*
*&      Module  validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA15A INPUT.

ENDMODULE.                 " validate_lineitem_data15a  INPUT
*&---------------------------------------------------------------------*
*&      Module  change_srno15  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO15 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL115_ITAB INTO G_TABLCTRL115_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL115_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL115_ITAB FROM G_TABLCTRL115_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL115_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL115_ITAB  LINES TABLCTRL115-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " change_srno15  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_CRC_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_CRC_POS INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'CRC_POS' AND SCREEN-INPUT = 0.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  data : loop_step like sy-stepl.
  DATA : L_ROLE_TYPE LIKE ZIC_PREP_ROLEREI-ROLE_NAME.
  DATA : IST_RETURN_TAB1 LIKE STANDARD TABLE OF DSELC WITH HEADER LINE.
  DATA : IST_RETURN_TAB2 LIKE STANDARD TABLE OF DYNPREAD WITH HEADER
         LINE.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0110'
    IMPORTING
      VALUE = L_ROLE_TYPE.

  SELECT * FROM ZMM_PREP_CRCDESG INTO CORRESPONDING FIELDS OF
             TABLE IT_POS WHERE ROLE_TYPE = L_ROLE_TYPE
*Begin of <RD1K962817>.
     AND STATUS  = 'active'.
*End of <RD1K962817>.
  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'CRC_POS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'CRC_ORDER_AUTH'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE_EX'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
*Begin of <RD1K962817>.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_POS'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'ROLE_DESCRIPTION'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZMM_PREP_CRCDESG'.
  G_FIELD_WA-FIELDNAME = 'MIN_DESIGNATION'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
*End of <RD1K962817>.

  IST_RETURN_TAB1-FLDNAME = 'ROLE_TYPE_EX'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZIC_PREP_ROLEREI-ROLE_TYPE_EX'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.

  IST_RETURN_TAB1-FLDNAME = 'ROLE_TYPE'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.

*Begin of <RD1K962817>.
  IST_RETURN_TAB1-FLDNAME = 'MIN_DESIGNATION'.
  IST_RETURN_TAB1-DYFLDNAME = 'ZMM_PREP_CRCDESG-MIN_DESIGNATION'.
  APPEND IST_RETURN_TAB1 TO IST_RETURN_TAB1.
*End of <RD1K962817>.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CRC_POS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'CRC_POS'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_POS
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
      DYNPFLD_MAPPING = IST_RETURN_TAB1
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE IST_RETURN_TAB WITH KEY FIELDNAME = 'CRC_POS'.
    IST_RETURN_TAB2-FIELDNAME = IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDVALUE = IST_RETURN_TAB-FIELDVAL.
    IST_RETURN_TAB2-STEPL = LOOP_STEP.
    APPEND IST_RETURN_TAB2 TO IST_RETURN_TAB2.
    READ TABLE IST_RETURN_TAB WITH KEY FIELDNAME = 'ROLE_TYPE_EX'.
    CONCATENATE 'ZIC_PREP_ROLEREI-' IST_RETURN_TAB-FIELDNAME INTO
    IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDNAME = IST_RETURN_TAB-FIELDNAME.
    IST_RETURN_TAB2-FIELDVALUE = IST_RETURN_TAB-FIELDVAL.
    IST_RETURN_TAB2-STEPL = LOOP_STEP.
    APPEND IST_RETURN_TAB2 TO IST_RETURN_TAB2.


    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        DYNAME               = SY-CPROG
        DYNUMB               = SY-DYNNR
      TABLES
        DYNPFIELDS           = IST_RETURN_TAB2
      EXCEPTIONS
        INVALID_ABAPWORKAREA = 1
        INVALID_DYNPROFIELD  = 2
        INVALID_DYNPRONAME   = 3
        INVALID_DYNPRONUMMER = 4
        INVALID_REQUEST      = 5
        NO_FIELDDESCRIPTION  = 6
        UNDEFIND_ERROR       = 7
        OTHERS               = 8.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLEAR DIS_FLAG.

  ENDIF.

*Begin of <RD1K962817>.
  IST_RETURN_TAB3[] = IST_RETURN_TAB2[].
*  REFRESH:it_pos,g_field_tab,ist_return_tab,ist_return_tab1.
  REFRESH:IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1,IST_RETURN_TAB2.
*End of <RD1K962817>.
  FREE  : IT_POS,G_FIELD_TAB,IST_RETURN_TAB,IST_RETURN_TAB1.

ENDMODULE.                 " POV_CRC_POS  INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: modify table
MODULE TABLCTRL116_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL116_WA.

  SELECT SINGLE * FROM ZHS_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL116_WA-ROLE_DESC = ZHS_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL116_ITAB
    FROM G_TABLCTRL116_WA
    INDEX TABLCTRL116-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL116_WA TO G_TABLCTRL116_ITAB.
  ENDIF.

  IF G_TABLCTRL116_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL116_WA-FLAG.
    APPEND G_TABLCTRL116_WA TO G_TABLCTRL116_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_116 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

ENDMODULE.                    "TABLCTRL116_modify INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: mark table
MODULE TABLCTRL116_MARK INPUT.
  IF TABLCTRL116-LINE_SEL_MODE = 1 AND
     G_TABLCTRL116_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL116_ITAB INTO G_TABLCTRL116_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL116_WA-FLAG = ''.
      MODIFY G_TABLCTRL116_ITAB
        FROM G_TABLCTRL116_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL116_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL116_ITAB
    FROM G_TABLCTRL116_WA
    INDEX TABLCTRL116-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                    "TABLCTRL116_mark INPUT

*&spwizard: input module for tc 'TABLCTRL116'. do not change this line!
*&spwizard: process user command
MODULE TABLCTRL116_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL116'
                              'G_TABLCTRL116_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TABLCTRL116_user_command INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_HSE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_HSE INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

  SELECT * FROM ZHS_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
               TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZHS_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.

ENDMODULE.                 " POV_ROLE_HSE  INPUT
*&---------------------------------------------------------------------*
*&      Module  get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_116 INPUT.

  GET CURSOR FIELD G_CURFIELD.
  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL116-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_116 = G_CURR_LINE.

ENDMODULE.                 " get_cursor_line_116  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA17 INPUT.
  SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                   ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA17  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA17A  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA17A INPUT.
  IF  ZIC_PREP_ROLEREQ-CROSSCO_FL = 'X' OR OLD_OK_CODE = 'CROSSCO'.

    SELECT A~PERNR A~BEGDA A~ENDDA A~ENAME AS NAME A~BUKRS  A~WERKS
                 A~PERSK A~SBMOD  C~DESIGNO C~R_P_CD C~VERSION
               D~SDESIG_TEXT AS DESIGNATION D~ADESIG_TEXT AS ADESIGNATION
               D~DISC_CD AS DISC_CD
                 INTO CORRESPONDING FIELDS OF TABLE IST_DATA
            FROM ( ( PA0001 AS A INNER JOIN PA9930 AS C
                  ON A~PERNR = C~PERNR ) INNER JOIN ZDESIGNATION_REV AS D
                     ON C~DESIGNO = D~DESIG_CODE AND
                         C~R_P_CD  = D~R_P_CD AND
                         C~VERSION = D~VERSION )
                      WHERE A~PERNR =  ZIC_PREP_ROLEREQ-USERID AND
                            A~SPRPS = ' ' AND
                            A~ENDDA = '99991231' AND
                            C~SPRPS = ' ' AND
                            C~ENDDA = '99991231' .

    IF SY-SUBRC = 0.
"Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
*      READ TABLE ist_data INDEX 1.
      READ TABLE ist_data INDEX 1.     "#EC CI_NOORDER
"Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 11.06.2026 FOR ATC
      G_CCODE = IST_DATA-BUKRS.
    ENDIF.

  ELSE.

    G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.

  ENDIF.

  IF G_READ_FL <> 'X'.

    SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC <> 0.
      G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
      MESSAGE I118(ZHELP).
    ENDIF.

  ELSEIF G_E_FL = 'X'.
    CLEAR G_E_FL.
  ELSE.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
    CLEAR G_READ_FL.

  ENDIF.

  IF G_ROLE_NAME_FLAG = 'X'.
    CLEAR G_ROLE_NAME_FLAG.
    CLEAR  ZIC_PREP_ROLEREI-SHOP_NO.
    CLEAR  ZIC_PREP_ROLEREI-PLANT.
  ENDIF.


  G_FIELD = 'ZIC_PREP_ROLEREI-PLANT'.

  G_I = G_CURR_LINE.

  L_ROLE_NAME = ZIC_PREP_ROLEREI-ROLE_NAME.

**********************************************************

  IF OLD_OK_CODE <> 'DISPLAY'.


*    IF NOT zic_prep_rolerei-plant IS INITIAL.
*
*      SELECT * FROM zd_t001w_bukrs INTO CORRESPONDING FIELDS OF
*                 TABLE it_bukrs  WHERE bukrs =  zic_prep_rolereq-ccode
*                                    AND werks = zic_prep_rolerei-plant.
*      IF sy-subrc <> 0.
*        g_e_fl = 'X'.
*        g_field = 'ZIC_PREP_ROLEREI-PLANT'.
*        g_i = g_curr_line.
*        MESSAGE e068(zhelp) WITH zic_prep_rolerei-role_name.
*
*      ENDIF.
*
*    ENDIF.

    IF NOT ZIC_PREP_ROLEREI-ROLE_NAME IS INITIAL.

      SELECT * FROM ZOL_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
                  TABLE IT_ROLE.

*      IF zic_prep_rolereq-ccode = 'BDW' OR
*         zic_prep_rolereq-ccode = 'SBW'.
*      ELSE.
*        DELETE it_role WHERE role_type = 'PM14' OR
*        role_type = 'PM15' OR role_type = 'PM16'.
*      ENDIF.

      LOOP AT IT_ROLE .
        IF IT_ROLE-ROLE_TYPE = ZIC_PREP_ROLEREI-ROLE_NAME.
          CHECK_ROLE_FLAG = 'X'.
        ENDIF.
      ENDLOOP.

      IF CHECK_ROLE_FLAG = 'X'.
        CLEAR CHECK_ROLE_FLAG.
      ELSE.
        MESSAGE E164(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME
        ZIC_PREP_ROLEREQ-CCODE .
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA17A  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL117_WA.

  SELECT SINGLE * FROM ZOL_PREP_ROLEDES WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  G_TABLCTRL117_WA-ROLE_DESC = ZOL_PREP_ROLEDES-BRIEF_DESC.

  MODIFY G_TABLCTRL117_ITAB
    FROM G_TABLCTRL117_WA
    INDEX TABLCTRL117-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL117_WA TO G_TABLCTRL117_ITAB.
  ENDIF.

  IF G_TABLCTRL117_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL117_WA-FLAG.
    APPEND G_TABLCTRL117_WA TO G_TABLCTRL117_ITAB.
  ENDIF.

  IF G_CURFIELD = 'ZIC_PREP_ROLEREI-ROLE_REQUEST' AND
    G_CURR_LINE_117 = SY-STEPL.
    SET PARAMETER ID 'ZAUTHREQ' FIELD ZIC_PREP_ROLEREI-ROLE_REQUEST.
  ENDIF.

  IF G_CURR_LINE_117 = SY-STEPL AND OKCODE_100 = 'TABLCTRL117_DELE' AND
        G_TABLCTRL117_WA-REJ_FL <> ''.
    G_REJ_FL = 'X'.
  ENDIF.
ENDMODULE.                 " TABLCTRL117_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_MARK INPUT.
  IF TABLCTRL117-LINE_SEL_MODE = 1 AND
       G_TABLCTRL117_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL117_ITAB INTO G_TABLCTRL117_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL117_WA-FLAG = ''.
      MODIFY G_TABLCTRL117_ITAB
        FROM G_TABLCTRL117_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL117_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL117_ITAB
    FROM G_TABLCTRL117_WA
    INDEX TABLCTRL117-CURRENT_LINE
    TRANSPORTING FLAG.
ENDMODULE.                 " TABLCTRL117_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO17  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO17 INPUT.

  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL117_ITAB INTO G_TABLCTRL117_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL117_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL117_ITAB FROM G_TABLCTRL117_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL117_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL117_ITAB  LINES TABLCTRL117-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " CHANGE_SRNO17  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL117_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL117_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL117'
                              'G_TABLCTRL117_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                 " TABLCTRL117_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_OLM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_OLM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

*  TYPES : Begin of z_role_des,
*            role_type like zmm_prep_roledes-role_type,
*            brief_desc like zmm_prep_roledes-brief_desc,
*            DETAIL_DESC1 like zmm_prep_roledes-detail_desc1,
*            DETAIL_DESC2 like zmm_prep_roledes-detail_desc2,
*            sort_field like zmm_prep_roledes-brief_desc,
*            mm_disc_flag like zmm_prep_roledes-mm_disc_flag,
*          end of z_role_des.

*  DATA   : it_role type table of z_role_des with header line.
*

  SELECT * FROM ZOL_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

*  IF zic_prep_rolereq-ccode = 'BDW' OR
*     zic_prep_rolereq-ccode = 'SBW'.
*  ELSE.
*    DELETE it_role WHERE role_type = 'PM14' OR
*    role_type = 'PM15' OR role_type = 'PM16'.
*  ENDIF.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZOL_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC2'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.
ENDMODULE.                 " POV_ROLE_OLM  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CURSOR_LINE_118 INPUT.
  GET CURSOR FIELD G_CURFIELD.

  GET CURSOR LINE G_CURSOR_LINE.
  G_CURR_LINE = G_CURSOR_LINE.
  G_CURR_LINE = TABLCTRL118-TOP_LINE + G_CURSOR_LINE - 1.
  G_CURR_LINE_118 = G_CURR_LINE.

ENDMODULE.                 " GET_CURSOR_LINE_118  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATASRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA118 INPUT.
  SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.

  IF G_ROLE_NAME_PREV <> ZIC_PREP_ROLEREI-ROLE_NAME AND
              NOT G_ROLE_NAME_PREV IS INITIAL.
    G_ROLE_NAME_FLAG = 'X'.
  ENDIF.
  G_READ_FL = 'X'.
ENDMODULE.                 " VALIDATE_LINEITEM_DATASRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_SRMROLE INPUT.
  clear:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = ZIC_PREP_ROLEREQ-USERID.
    p_role = ZIC_PREP_ROLEREI-role_name.
    p_grp = ZIC_PREP_ROLEREI-GRP.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE P_role TO UPPER CASE.

    if  p_role = 'S3'.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'P'.

        MESSAGE e165(zmm_oth) WITH ZIC_PREP_ROLEREI-ROLE_NAME.

      endif.


    endif.

  ENDIF.
  IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG = 'X'.
    IF  p_role = 'S2'.
      MESSAGE e167(zmm_oth) WITH ZIC_PREP_ROLEREI-ROLE_NAME.
    ENDIF.
  ENDIF.
ENDMODULE.                 " VALIDATE_SRMROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_SRMGRP INPUT.
  clear:l_logsys.



  SELECT SINGLE logsys FROM zmm_logsys INTO l_logsys
  WHERE  appl = 'SRM'.

  """"""calling srm

  IF NOT l_logsys  IS INITIAL.





    p_uname = ZIC_PREP_ROLEREQ-USERID.
    p_grp = ZIC_PREP_ROLEREI-GRP.
    p_role = ZIC_PREP_ROLEREI-role_name.

    TRANSLATE p_grp TO UPPER CASE.
    TRANSLATE P_role TO UPPER CASE.

    if p_grp  is not INITIAL.
      CALL FUNCTION 'ZSRM_ROLE_ASSIGN_CHECK' DESTINATION l_logsys
        EXPORTING
          p_uname = p_uname
          p_grp   = p_grp
          p_role  = p_role
        IMPORTING
          v_exist = v_exist.

      IF v_exist = 'Y'.

        MESSAGE e164(zmm_oth) WITH ZIC_PREP_ROLEREI-GRP.

      endif.

      IF v_exist = 'N'.

        MESSAGE e169(zmm_oth) WITH ZIC_PREP_ROLEREI-GRP.

      endif.


    endif.

  endif.



  CLEAR:COUNT_GRP,G_WA_PGRP.

  LOOP AT G_TABLCTRL118_ITAB INTO G_WA_PGRP WHERE  GRP = ZIC_PREP_ROLEREI-GRP  .
    if G_WA_PGRP-GRP  is not initial.
      COUNT_GRP = COUNT_GRP + 1.
    ENDIF.
  ENDLOOP.
  IF  COUNT_GRP > '1'.
    MESSAGE e092(ZHELP).
  ENDIF.
ENDMODULE.                 " VALIDATE_SRMGRP  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_LINEITEM_DATA1118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDATE_LINEITEM_DATA1118 INPUT.
  clear:G_LINE_srm.
  CONCATENATE  '%' ZIC_PREP_ROLEREQ-CCODE '%' '%'
  INTO G_LINE_srm.

  SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE_srm.


**

  IF  NOT ZIC_PREP_ROLEREI-GRP IS INITIAL.

    LOOP AT IT_T024 INTO WA_T024.

      IF ZIC_PREP_ROLEREI-GRP = WA_T024-EKGRP.
        GRP_FLAG_srm = 'X'.
      ENDIF.

    ENDLOOP.

    IF GRP_FLAG_srm = 'X'.
      CLEAR GRP_FLAG_srm.
    ELSE.
*        G_E_FL = 'X'.
*        G_READ_FL = 'X'.
*        G_FIELD = 'ZIC_PREP_ROLEREI-GRP'.
      MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL118_WA.
      MODIFY G_TABLCTRL118_ITAB
                FROM G_TABLCTRL118_WA
                  INDEX TABLCTRL118-CURRENT_LINE.
*        G_I = TABLCTRL110-CURRENT_LINE.
      MESSAGE I069(ZHELP).
      CALL SCREEN 100.
    ENDIF.
  endif.
ENDMODULE.                 " VALIDATE_LINEITEM_DATA1118  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MODIFY INPUT.
  MOVE MODULEID TO ZIC_PREP_ROLEREI-MODULEID.
  IF ZIC_PREP_ROLEREI-REJ_FL IS INITIAL.
    CLEAR : ZIC_PREP_ROLEREI-REJ_ID, ZIC_PREP_ROLEREI-REJ_DATE.
  ENDIF.
  MOVE-CORRESPONDING ZIC_PREP_ROLEREI TO G_TABLCTRL118_WA.

  SELECT SINGLE * FROM ZMM_PREP_ROLEGRP WHERE ROLE_TYPE =
                    ZIC_PREP_ROLEREI-ROLE_NAME.

  IF SY-SUBRC <> 0 .
    G_VAL_ERR = 'X'.
    MESSAGE I102(ZHELP) WITH ZIC_PREP_ROLEREI-ROLE_NAME .
    G_FIELD = 'ZIC_PREP_ROLEREI-ROLE_NAME'.
  ENDIF.

  IF ZIC_PREP_ROLEREI-REJ_FL = ''.

    IF SY-SUBRC = 0 AND OLD_OK_CODE = 'APPROVE'.
      IF ZMM_PREP_ROLEGRP-APPROVER1 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER2 = G_USER
         OR ZMM_PREP_ROLEGRP-APPROVER3 = G_USER
   """"""""""""""""""""""""
      "added by lipsy for l2 approver on 20.03.2015 RD1K996555
            OR ( MODULEID = 'SRM' AND ZMM_PREP_ROLEGRP-APPROVER1 = G_USER_L2 )
       "End of addition by lipsy for l2 approver on 20.03.2015 RD1K996555
    """"""""""""""""""""
        .
      ELSE.

        IF OKCODE_100 = 'SAV'.
          IF ERR_FLG <> 'X'.
            ERR_FLG = 'X'.
            CLEAR : SY-UCOMM, OKCODE_100.
          ENDIF.
          MESSAGE E047(ZHELP) WITH ZMM_PREP_ROLEGRP-ROLE_TYPE.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  IF NOT G_TABLCTRL118_WA-ROLE_NAME IS INITIAL.

    SELECT SINGLE * FROM ZSR_PREP_ROLEDES WHERE ROLE_TYPE =
                  ZIC_PREP_ROLEREI-ROLE_NAME.
    IF SY-SUBRC = 0.
      G_TABLCTRL118_WA-ROLE_DESC = ZSR_PREP_ROLEDES-BRIEF_DESC.
*Begin  of <RD1K962817>.
*        IF G_TABLCTRL118_WA-ROLE_NAME = 'M8'.
*          G_TABLCTRL118_WA-APPROVER = ZIC_PREP_ROLEREQ-PERSK.
*        ENDIF.
*End of <RD1K962817>.
*        if  not g_tablctrl110_wa-APPROVER is  INITIAL and ZIC_PREP_ROLEREI-ROLE_NAME = 'M8'.
*          loop AT SCREEN.
*            if screen-group2 = 'MOD'.
**              screen-active = 1.
**              screen-output =  1.
*              screen-input = 0.
**              screen-intensified = 0.
*              MODIFY SCREEN .
*              ENDIF.
*              endloop.
*endif.

    ENDIF.

  ENDIF.

  MODIFY G_TABLCTRL118_ITAB
     FROM G_TABLCTRL118_WA
     INDEX TABLCTRL118-CURRENT_LINE.

  IF SY-SUBRC <> 0.
    APPEND G_TABLCTRL118_WA TO G_TABLCTRL118_ITAB.
  ENDIF.

  IF G_TABLCTRL118_WA-FLAG = 'X' AND OKCODE_100 = 'COPY'.
    CLEAR G_TABLCTRL118_WA-FLAG.
    APPEND G_TABLCTRL118_WA TO G_TABLCTRL118_ITAB.
  ENDIF.
ENDMODULE.                 " TABLCTRL118_MODIFY  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_MARK INPUT.
  IF TABLCTRL118-LINE_SEL_MODE = 1 AND
       G_TABLCTRL118_WA-FLAG = 'X'.
    LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA
      WHERE FLAG = 'X'.
      G_TABLCTRL118_WA-FLAG = ''.
      MODIFY G_TABLCTRL118_ITAB
        FROM G_TABLCTRL118_WA
        TRANSPORTING FLAG.
    ENDLOOP.
    G_TABLCTRL118_WA-FLAG = 'X'.
  ENDIF.
  MODIFY G_TABLCTRL118_ITAB
    FROM G_TABLCTRL118_WA
    INDEX TABLCTRL118-CURRENT_LINE.
ENDMODULE.                 " TABLCTRL118_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SRNO_118 INPUT.
  CLEAR G_SRNO.
  LOOP AT G_TABLCTRL118_ITAB INTO G_TABLCTRL118_WA.
    G_SRNO = G_SRNO + 1.
    G_TABLCTRL118_WA-SRNO = G_SRNO.
    MODIFY G_TABLCTRL118_ITAB FROM G_TABLCTRL118_WA.
  ENDLOOP.
  DESCRIBE TABLE G_TABLCTRL118_ITAB  LINES G_LINES_RL.
  DESCRIBE TABLE G_TABLCTRL118_ITAB  LINES TABLCTRL118-LINES.
  CLEAR G_SRNO.
ENDMODULE.                 " CHANGE_SRNO_118  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABLCTRL118_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLCTRL118'
                              'G_TABLCTRL118_ITAB'
                              'FLAG'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                 " TABLCTRL118_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_ROLE_SRM INPUT.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-ROLE_NAME' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.



  SELECT * FROM ZSR_PREP_ROLEDES INTO CORRESPONDING FIELDS OF
             TABLE IT_ROLE.

  SORT IT_ROLE ASCENDING BY SORT_FIELD.

  IF OLD_OK_CODE <> 'DISPLAY'.

    CLEAR ZIC_PREP_ROLEREI-ROLE_NAME.

  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'ROLE_TYPE'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'BRIEF_DESC'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'ZSR_PREP_ROLEDES'.
  G_FIELD_WA-FIELDNAME = 'DETAIL_DESC1'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ROLE_TYPE'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-ROLE_NAME'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_ROLE
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  FREE  : IT_ROLE,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR : G_FIELD_WA.
ENDMODULE.                 " POV_ROLE_SRM  INPUT
*&---------------------------------------------------------------------*
*&      Module  POV_GRP_SRM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE POV_GRP_SRM INPUT.
  G_CCODE =  ZIC_PREP_ROLEREQ-CCODE.


  LOOP AT SCREEN.

    IF SCREEN-NAME = 'ZIC_PREP_ROLEREI-GRP' AND SCREEN-INPUT = 0
.
      DIS_FLAG = 'X'.
    ENDIF.

  ENDLOOP.

**  DATA : L_EKGRP LIKE T024-EKGRP.
*  DATA : LOOP_STEP LIKE SY-STEPL.
*  DATA : L_ROLE_NAME LIKE ZIC_PREP_ROLEREI-ROLE_NAME.
*
*  DATA L_DISC_MM_FLAG LIKE ZIC_PREP_ROLEREQ-DISC_MM_FLAG.

*  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
*       EXPORTING
*            STRUC = 'ZIC_PREP_ROLEREQ'
*            FIELD = 'DISC_MM_FLAG'
*            REPID = SY-CPROG
*            DYNNR = '0100'
*       IMPORTING
*            VALUE = l_disc_mm_flag.
*
*  ZIC_PREP_ROLEREQ-DISC_MM_FLAG = l_disc_mm_flag.

  CALL FUNCTION 'DYNP_GET_STEPL'
    IMPORTING
      POVSTEPL        = LOOP_STEP
    EXCEPTIONS
      STEPL_NOT_FOUND = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
  ENDIF.

  CALL FUNCTION 'SWD_DYNPRO_FIELD_GET'
    EXPORTING
      STRUC = 'ZIC_PREP_ROLEREI'
      FIELD = 'ROLE_NAME'
      INDEX = LOOP_STEP
      REPID = SY-CPROG
      DYNNR = '0118'
    IMPORTING
      VALUE = L_ROLE_NAME.

  IF L_ROLE_NAME = 'S1' OR  L_ROLE_NAME = 'S2' .
    CONCATENATE '%' G_CCODE '%' INTO G_LINE1.
    SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.

  ELSE.
    IF ZIC_PREP_ROLEREQ-DISC_MM_FLAG <> 'X'.
*      concatenate '%' G_CCODE '-' 'IND' '%'
*      into g_line1.
      CONCATENATE '%' G_CCODE '%' 'IND' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ELSE.
*      concatenate  '%' G_CCODE '-' 'MM' '%'
*      into g_line1.
      CONCATENATE  '%' G_CCODE '%' 'MM' '%'
      INTO G_LINE1.
      SELECT * FROM T024 INTO TABLE IT_T024 WHERE TELFX LIKE G_LINE1.
    ENDIF.
  ENDIF.

  IF OLD_OK_CODE = 'DISPLAY'.
    DIS_FLAG = 'X'.
  ENDIF.

  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKGRP'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.
  G_FIELD_WA-TABNAME = 'T024'.
  G_FIELD_WA-FIELDNAME = 'EKNAM'.
  APPEND G_FIELD_WA TO G_FIELD_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'EKGRP'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'ZIC_PREP_ROLEREI-GRP'
      VALUE_ORG       = 'S'
      DISPLAY         = DIS_FLAG
    TABLES
      VALUE_TAB       = IT_T024
      FIELD_TAB       = G_FIELD_TAB
      RETURN_TAB      = IST_RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CLEAR DIS_FLAG.

  ENDIF.

  REFRESH:IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  FREE : IT_T024,IST_RETURN_TAB, G_FIELD_TAB.
  CLEAR G_FIELD_WA.
ENDMODULE.                 " POV_GRP_SRM  INPUT
