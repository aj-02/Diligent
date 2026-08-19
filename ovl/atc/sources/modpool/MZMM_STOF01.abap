*--- MAIN PROGRAM: MZMM_STOF01 ---*
*----------------------------------------------------------------------*
***INCLUDE MZMM_STOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0211   text
*      -->P_0212   text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    " bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  bdc_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0336   text
*----------------------------------------------------------------------*
FORM BDC_TRANSACTION USING TCODE.
  REFRESH MESSTAB.
  DATA: CTUMODE LIKE CTU_PARAMS-DISMODE value 'N'.
  CALL TRANSACTION TCODE USING BDCDATA
                   MODE   CTUMODE
                   UPDATE 'S'
                   MESSAGES INTO MESSTAB.
*  CALL FUNCTION 'BDC_INSERT'
*       EXPORTING
*            TCODE     = TCODE
*       TABLES
*            DYNPROTAB = BDCDATA.
  REFRESH BDCDATA.
ENDFORM.                    " bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  open_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_group.
  DATA:GROUP LIKE APQI-GROUPID,
       UNAME LIKE APQI-USERID.
  GROUP = 'X'.
  UNAME = SY-UNAME.

  CALL FUNCTION 'BDC_OPEN_GROUP'
       EXPORTING
            CLIENT = SY-MANDT
            GROUP  = GROUP
            USER   = SY-UNAME.
ENDFORM.                    " open_group
*&---------------------------------------------------------------------*
*&      Form  close_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_group.
  CALL FUNCTION 'BDC_CLOSE_GROUP'.

ENDFORM.                    " close_group
