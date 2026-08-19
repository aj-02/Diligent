*&---------------------------------------------------------------------*
*& Report  ZF_FILL_MISSING_AUGGJ_NGLM
*& Version 002 : 02  May 2008
*&---------------------------------------------------------------------*
*& !!!!!!!!!!!!!! To be RUN by SAP / SAP Guidance Only !!!!!!!!!!!!!!!!!
*&----------------------------------------------------------------------
*& AUGGJ missing could cause trouble in processing of BSE_CLR during
*& of phase-1 documents in NewGL Migration.
*&
*& This program will,
*& Fill missing AUGGJ in BSEG;BSA* which could cause trouble in migration
*&
*& Migration date is taken as the basis of start of AUGDT selection for clearings
*&
*& BUKRS are obtained from Migration plan, these are ignored if the selection of
*& BUKRS is entered in the selections directly.
*&
*& Run in background in test mode first(default) and check the output before
*& running in update mode
*&
*& Limitations:
*& Does not correct BSEG if BSA* is alright
*& Not yet good for mass corrections, run in test mode first !
*& Special Features:
*& Export a back up to RFDT all the values of corrections ( But happens
*& at the end; Any manual termination in between may not export correctly)
*&---------------------------------------------------------------------*

REPORT  ZF_FILL_MISSING_AUGGJ_NGLM.

TYPE-POOLS: ABAP.

TABLES: T001,BKPF,BSEG,BSAS,BSAK,BSAD.

TYPES : T_BKPF TYPE BKPF.

DATA:  WA_BKPF TYPE BKPF.

DATA:  BEGIN OF WA_BSEG.
INCLUDE type BSEG.
DATA:  CORR TYPE CHAR1,
       AUGGJ_NEW TYPE BSEG-AUGGJ,
       END OF WA_BSEG.

DATA:  BEGIN OF WA_BSAS.
INCLUDE type BSAS.
DATA:  CORR TYPE CHAR1,
       AUGGJ_NEW TYPE BSAS-AUGGJ,
       END OF WA_BSAS.

DATA:  BEGIN OF WA_BSAD.
INCLUDE TYPE BSAD.
DATA:  CORR TYPE CHAR1,
       AUGGJ_NEW TYPE BSAD-AUGGJ,
       END OF WA_BSAD.

DATA:  BEGIN OF WA_BSAK.
INCLUDE type BSAK.
DATA:  CORR TYPE CHAR1,
       AUGGJ_NEW TYPE BSAK-AUGGJ,
       END OF WA_BSAK.

** ITABs for selection/correction

DATA : IT_BKPF LIKE STANDARD table of WA_BKPF with header line,
       IT_BSEG LIKE STANDARD table of WA_BSEG with header line,
       IT_BSAS LIKE STANDARD table of WA_BSAS with header line,
       IT_BSAD LIKE STANDARD table of WA_BSAD with header line,
       IT_BSAK LIKE STANDARD table of WA_BSAK with header line.



** Migration Data
DATA: T_BUKRS TYPE FAGL_T_BUKRS,              " Company Codes for Migration plan
      T_MIG_DATA TYPE FAGL_T_MIG_MGPLN_EXT,   " Migration Status Data for the plan
      S_MIG_DATA type FAGL_S_MIG_MGPLN_EXT,   " Migration Status Data for the plan
      T_MIG_PLAN TYPE FAGL_T_MGPLN,           " Migration Plan
      L_MIGDT TYPE FAGL_S_MIG_MGPLN_EXT-MIGDT." Migration Date : Date of Migration


DATA : Begin of WA_CLEARING_DOC,
       BUKRS TYPE T001-BUKRS,
       AUGDT TYPE BSAS-AUGDT,
       AUGBL TYPE BSAS-AUGBL,
       BELNR TYPE BSAS-BELNR,
       GJAHR TYPE BSAS-GJAHR,
       BUZEI TYPE BSAS-BUZEI,
       AUGGJ TYPE BSAS-AUGGJ,
       HKONT TYPE BSAS-HKONT,
       LIFNR TYPE BSAK-LIFNR,
       KUNNR TYPE BSAD-KUNNR,
       CNT_UPD_BSAS TYPE I,
       CNT_UPD_BSAK TYPE I,
       CNT_UPD_BSAD TYPE I,
       CNT_UPD_BSEG TYPE I,
       CNT_UPD_CLR  TYPE I,
       CORR  TYPE CHAR1,

       End of WA_CLEARING_DOC.

DATA:  IT_CLEARING_DOC_BSAS LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.
DATA:  IT_CLEARING_DOC_BSAK LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.
DATA:  IT_CLEARING_DOC_BSAD LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.

DATA:  CNT_BSAS_OLD TYPE I,CNT_BSAS_NEW TYPE I,CNT_BSAD_OLD TYPE I ,CNT_BSAD_NEW TYPE I.
DATA:  CNT_BSAK_OLD TYPE I,CNT_BSAK_NEW TYPE I,CNT_BSEG_OLD TYPE I ,CNT_BSEG_NEW TYPE I.

DATA:  CNT_TEMP_BSAS TYPE I,CNT_TEMP_BSEG TYPE I,CNT_TEMP_BSAK TYPE I,CNT_TEMP_BSAD TYPE I,CNT_TEMP TYPE I,CNT_DISP_BSEG TYPE I.

** Database update counters

DATA: CNT_UPD_BSAS TYPE I.
DATA: CNT_UPD_BSAK TYPE I.
DATA: CNT_UPD_BSAD TYPE I.
DATA: CNT_UPD_BSEG TYPE I.
DATA: CNT_UPD_CLR  TYPE I.
DATA: CNT_UPD_TOT  TYPE I.


** export key for RFDT
DATA: exp_key(22) TYPE c.
DATA: BEGIN OF rfdt_key,
      key1(7) TYPE c VALUE 'AUGJ_UP',
      date    LIKE sy-datlo,
      time    LIKE sy-timlo,
      END OF rfdt_key.
DATA  EXP_TAB TYPE CHAR4.
** Selections

SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-SEL.

PARAMETERS:        P_BUKRS  TYPE T001-BUKRS.
SELECT-OPTIONS:    S_BELNR  FOR BKPF-BELNR,
                   S_GJAHR  FOR BKPF-GJAHR,
                   S_AUGBL  FOR BSAS-AUGBL,
                   S_AUGDT  FOR BSAS-AUGDT.

PARAMETERS:        P_MG_PLN TYPE FAGL_MIG_001-MGPLN OBLIGATORY.

SELECTION-SCREEN END OF BLOCK SEL.

SELECTION-SCREEN BEGIN OF BLOCK UPD WITH FRAME TITLE TEXT-UPD.
PARAMETERS:     CHK_GL      AS CHECKBOX DEFAULT ABAP_TRUE,
                CHK_VEND    AS CHECKBOX DEFAULT ABAP_FALSE,
                CHK_CUST    AS CHECKBOX DEFAULT ABAP_FALSE,
                P_D_LIST   AS CHECKBOX DEFAULT ABAP_TRUE MODIF ID INC,
                P_E_RFDT AS CHECKBOX DEFAULT ABAP_TRUE MODIF ID INC,
                P_UPDATE   AS CHECKBOX DEFAULT ABAP_FALSE MODIF ID INC.
SELECTION-SCREEN END OF BLOCK UPD.

***********************************************************************
*********** Start of selection****************************************

START-OF-SELECTION.

  IF P_UPDATE = ABAP_TRUE.
    WRITE  : / ' START OF RUN IN UPDATE MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
  ELSE.
    WRITE  : / ' START OF RUN IN TEST MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
  ENDIF.
  ULINE (120).

** Check for migration company codes/date etc.
  PERFORM MIGRATION_DATA_CHECK.

** Select the data for correction

  IF CHK_GL = ABAP_TRUE.
    WRITE / : ' GL ACCOUNT CLEARINGS'.
    NEW-LINE.
    CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
    PERFORM GET_DATA_BSAS.
  ENDIF.

  IF CHK_VEND = ABAP_TRUE.
    WRITE / : ' VENDOR ACCOUNT CLEARINGS'.
    NEW-LINE.
    CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
    PERFORM GET_DATA_BSAK.
  ENDIF.

  IF CHK_CUST = ABAP_TRUE.
    WRITE / : ' CUSTOMER ACCOUNT CLEARINGS'.
    NEW-LINE.
    CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
    PERFORM GET_DATA_BSAD.
  ENDIF.

  NEW-LINE.
  ULINE (120).
  FORMAT COLOR 3.
  WRITE:/ sy-vline NO-GAP, 'CORR = X -> To be Corrected / Test   Mode   '.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR 3.
  WRITE:/ sy-vline NO-GAP, '       U -> Updated         / Update Mode   '.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR 3.
  WRITE:/ sy-vline NO-GAP, '       E -> Error in Update / To be Analyzed'.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR 3.
  WRITE:/ sy-vline NO-GAP, '       N -> Could not get AUGGJ/ClearingYear'.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  ULINE (120).

  IF P_UPDATE = ABAP_TRUE.
    WRITE  : / 'END OF RUN IN UPDATE MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
  ELSE.
    WRITE  : / 'END OF RUN IN TEST MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
  ENDIF.
  ULINE (120).
*********** All Over! *************************************************
***********************************************************************


*&---------------------------------------------------------------------*
*&      Form  MIGRATION_DATA_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MIGRATION_DATA_CHECK .

** Get the company codes involved in the migration plan
  CALL FUNCTION 'FAGL_GET_BUKRS_LEDGER_IN_MGPLN'
    EXPORTING
      I_MGPLN       = P_MG_PLN
    IMPORTING
      ET_BUKRS      = T_BUKRS
    EXCEPTIONS
      INVALID_INPUT = 1
      NO_DATA_FOUND = 2
      OTHERS        = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

** Clear out the selection of BUKRS if selected already in the parameters

  IF NOT P_BUKRS IS INITIAL.
    CLEAR T_BUKRS.
    REFRESH T_BUKRS.
    APPEND P_BUKRS TO T_BUKRS.
  ENDIF.

** End Filter

** Get Migration Date
  CLEAR T_MIG_PLAN.
  REFRESH T_MIG_PLAN.

  APPEND P_MG_PLN TO T_MIG_PLAN. "Next FM takes only IT of plans.

  CALL FUNCTION 'FAGL_MIG_GET_ALL_MGPLN_DATA_EX'
    EXPORTING
      IT_MGPLN          = T_MIG_PLAN
    IMPORTING
      ET_MGPLN_DATA_EXT = T_MIG_DATA
    EXCEPTIONS
      INTERNAL_ERROR    = 1
      NO_DATA_FOUND     = 2
      OTHERS            = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

** Got the migration date for the Migration Plan selected.
*{   REPLACE        TNGK900040                                        1
*\  READ TABLE T_MIG_DATA WITH KEY MG_START = 'X' MG_END = ' ' MGPLN = P_MG_PLN INTO S_MIG_DATA.
  READ TABLE T_MIG_DATA WITH KEY MGPLN = P_MG_PLN INTO S_MIG_DATA. "MG_START = 'X' MG_END = ' '
*}   REPLACE
  L_MIGDT = S_MIG_DATA-MIGDT.


ENDFORM.                    " MIGRATION_DATA_CHECK
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BSAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_BSAS .

  SELECT   DISTINCT BUKRS
                    HKONT
                    AUGDT
                    AUGBL
              FROM bsas
              APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAS
              FOR ALL ENTRIES IN T_BUKRS
                WHERE BUKRS EQ  T_BUKRS-BUKRS
                  AND AUGDT GE  L_MIGDT
                  AND AUGBL IN  S_AUGBL
                  AND AUGDT IN  S_AUGDT
                  AND BELNR IN  S_BELNR
                  AND GJAHR IN  S_GJAHR
*{   REPLACE        TNGK900040                                        1
*\                  AND AUGGJ EQ  SPACE.
                  AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

  CLEAR: IT_BSEG,WA_BSEG,IT_BSAS.
  REFRESH: IT_BSEG,IT_BSAS.

** Header
  FORMAT COLOR 1.
  ULINE (120).
  WRITE:/ sy-vline NO-GAP,
          'Clearings Involved in Correction',
      120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  FORMAT COLOR 4.
  WRITE:/ sy-vline NO-GAP,
      (5) 'BUKRS',
      (10) 'AUGDT',
      (10) 'AUGBL',
      (12) 'HKONT',
      (5) 'AUGGJ',
      (8) 'UPD_BSEG',
     (8) 'UPD_BSAS',
     (8) 'UPD_CLR',
     (4) 'CORR'.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  ULINE (120).


  IF P_D_LIST = ABAP_TRUE.
    FORMAT COLOR 2.
    WRITE:/ sy-vline NO-GAP,
        (5) 'BUKRS',
        (10) 'BELNR',
        (10) 'GJAHR',
        (5)  'BUZEI',
        (10) 'AUGDT',
        (10) 'AUGBL',
        (12) 'HKONT',
        (9) 'AUGGJ_OLD',
        (9) 'AUGGJ_NEW',
        (5) 'TABLE',
        (5) 'CORR'.
    WRITE:120 sy-vline NO-GAP.
    ULINE (120).
    FORMAT COLOR OFF.

  ENDIF.

** End Header

  LOOP AT IT_CLEARING_DOC_BSAS. " Loop at the set and get the lines for clearing

    CLEAR : CNT_UPD_BSAS,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAS_OLD,CNT_BSEG_NEW,CNT_BSAS_NEW.

** Documentatoin of update or test mode
    IF P_UPDATE = ABAP_TRUE.
      IT_CLEARING_DOC_BSAS-CORR = 'U'.
    ELSE.
      IT_CLEARING_DOC_BSAS-CORR = 'X'.
    ENDIF.

    MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAS,CNT_UPD_BSEG.

    DESCRIBE TABLE IT_BSAS  LINES CNT_BSAS_OLD.

    SELECT * FROM BSAS APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAS
             WHERE BUKRS =  IT_CLEARING_DOC_BSAS-BUKRS
             AND   HKONT =  IT_CLEARING_DOC_BSAS-HKONT
             AND   AUGDT =  IT_CLEARING_DOC_BSAS-AUGDT
             AND   AUGBL =  IT_CLEARING_DOC_BSAS-AUGBL
*{   REPLACE        TNGK900040                                        2
*\             AND   AUGGJ EQ SPACE.
             AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

    IF SY-SUBRC = 0.

      DESCRIBE TABLE IT_BSAS LINES CNT_BSAS_NEW.

      CLEAR CNT_TEMP_BSAS.

      CNT_TEMP_BSAS = CNT_BSAS_OLD.

      WHILE CNT_TEMP_BSAS LT CNT_BSAS_NEW.

        CNT_TEMP_BSAS = CNT_TEMP_BSAS + 1.
        READ TABLE IT_BSAS INDEX CNT_TEMP_BSAS INTO WA_BSAS.  "#EC CI_NOORDER
        IF SY-SUBRC = 0.
          IF WA_BSAS-AUGBL = WA_BSAS-BELNR.
            IT_CLEARING_DOC_BSAS-AUGGJ = WA_BSAS-GJAHR.
            MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
** Update the internal table with the new value
            EXIT. " Got the Required Clearing Year, exit while loop.
          ENDIF.
        ENDIF.

**  Try Finding AUGGJ with help from BKPF
        IF IT_CLEARING_DOC_BSAS-AUGGJ EQ SPACE AND CNT_TEMP_BSAS = CNT_BSAS_NEW.
          READ TABLE IT_BSAS INDEX CNT_BSAS_NEW INTO IT_BSAS.  "#EC CI_NOORDER
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
              WHERE        BUKRS =  IT_BSAS-BUKRS
                     AND   BELNR =  IT_BSAS-BELNR
                     AND   GJAHR =  IT_BSAS-GJAHR
                     AND   BUZEI =  IT_BSAS-BUZEI.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          IF SY-SUBRC = 0.
            SELECT SINGLE * FROM BKPF INTO WA_BKPF
                 WHERE BUKRS = IT_CLEARING_DOC_BSAS-BUKRS
                 AND   BELNR eq IT_CLEARING_DOC_BSAS-AUGBL
                 AND   CPUDT eq WA_BSEG-AUGCP.  "#EC CI_NOORDER

            IF SY-SUBRC = 0.
              IT_CLEARING_DOC_BSAS-AUGGJ = WA_BKPF-GJAHR.
              MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
            ENDIF.
          ENDIF.
        ENDIF.  " Try Finding AUGGJ with help from BKPF
      ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition


      IF IT_CLEARING_DOC_BSAS-AUGGJ NE SPACE.

** Modify the IT and update the database with new values.
        CNT_TEMP = CNT_BSAS_OLD + 1.
        LOOP AT IT_BSAS FROM  CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
          IT_BSAS-AUGGJ_NEW = IT_CLEARING_DOC_BSAS-AUGGJ.
          IT_BSAS-CORR  = 'X'.
          MODIFY IT_BSAS FROM IT_BSAS.
          IF P_UPDATE = ABAP_TRUE.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*            UPDATE BSAS SET AUGGJ =  IT_CLEARING_DOC_BSAS-AUGGJ
*                       WHERE BUKRS = IT_BSAS-BUKRS
*                         AND HKONT = IT_BSAS-HKONT
*                         AND AUGDT = IT_BSAS-AUGDT
*                         AND AUGBL = IT_BSAS-AUGBL
*                         AND BELNR = IT_BSAS-BELNR
*                         AND GJAHR = IT_BSAS-GJAHR
*                         AND BUZEI = IT_BSAS-BUZEI.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
            IF SY-SUBRC = 0.
              IT_BSAS-CORR = 'U'.
              CNT_UPD_BSAS = CNT_UPD_BSAS + sy-dbcnt.
            ELSE.
              IT_BSAS-CORR = 'E'.
              IT_CLEARING_DOC_BSAS-CORR = 'E'.
              MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
            ENDIF.
            MODIFY IT_BSAS FROM IT_BSAS.
          ELSE.
            CNT_UPD_BSAS = CNT_UPD_BSAS + 1.
          ENDIF.
        ENDLOOP.

** Modify the IT and update database for BSEG with new AUGGJ
        CNT_TEMP =  CNT_BSAS_OLD + 1.

        DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
        LOOP AT IT_BSAS FROM CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
          DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.

          SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
                WHERE BUKRS = IT_BSAS-BUKRS
                AND   BELNR = IT_BSAS-BELNR
                AND   GJAHR = IT_BSAS-GJAHR
                AND   BUZEI = IT_BSAS-BUZEI
*{   REPLACE        TNGK900040                                        3
*\                AND   AUGGJ EQ SPACE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                AND ( AUGGJ =  SPACE OR AUGGJ = '' ).  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*}   REPLACE

          IF SY-SUBRC = 0.
            DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
            CNT_TEMP_BSEG = CNT_BSEG_OLD.

            WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.

              CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
              READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
              IF SY-SUBRC = 0.
                IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAS-AUGGJ.
                IT_BSEG-CORR  = 'X'.
                MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
** Update the values to the internal table with new AUGGJ
                IF P_UPDATE = ABAP_TRUE.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
*                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAS-AUGGJ
*                             WHERE BUKRS = IT_BSEG-BUKRS
*                               AND BELNR = IT_BSEG-BELNR
*                               AND GJAHR = IT_BSEG-GJAHR
*                               AND BUZEI = IT_BSEG-BUZEI
**{   REPLACE        TNGK900040                                        4
**\                               AND AUGGJ EQ SPACE.
                  MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
*}   REPLACE
                  IF SY-SUBRC = 0.
                    IT_BSEG-CORR = 'U'.
                    CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
                  ELSE.
                    IT_BSEG-CORR = 'E'.
                    IT_CLEARING_DOC_BSAS-CORR = 'E'.
                    MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
                  ENDIF.
                  MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
                ELSE.
                  CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
                ENDIF.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.

      ELSE.
        IT_CLEARING_DOC_BSAS-CORR = 'N'.
        MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
      ENDIF.

      IT_CLEARING_DOC_BSAS-CNT_UPD_BSAS = CNT_UPD_BSAS.
      IT_CLEARING_DOC_BSAS-CNT_UPD_BSEG = CNT_UPD_BSEG.

      CNT_UPD_CLR =  CNT_UPD_BSAS + CNT_UPD_BSEG.

      IT_CLEARING_DOC_BSAS-CNT_UPD_CLR  = CNT_UPD_CLR.
      CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.

      MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.

    ENDIF.      " Clearing Documents in a Clearing

** Display the clearing info
    FORMAT COLOR 4.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    WRITE:/ sy-vline NO-GAP,
        (5) IT_CLEARING_DOC_BSAS-BUKRS,  "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAS-AUGDT,  "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAS-AUGBL,  "#EC CI_NOORDER
        (12) IT_CLEARING_DOC_BSAS-HKONT,  "#EC CI_NOORDER
        (5) IT_CLEARING_DOC_BSAS-AUGGJ,  "#EC CI_NOORDER
        (8) CNT_UPD_BSEG,
       (8)  CNT_UPD_BSAS,
        (8) CNT_UPD_CLR.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    FORMAT COLOR 3.
    WRITE : (4) IT_CLEARING_DOC_BSAS-CORR.  "#EC CI_NOORDER
    FORMAT COLOR OFF.
    WRITE:120 sy-vline NO-GAP.
    FORMAT COLOR OFF.

    IF P_D_LIST = ABAP_TRUE.

      CNT_TEMP = CNT_DISP_BSEG + 1.
      LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
        FORMAT COLOR 2.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSEG-BUKRS,
            (10) IT_BSEG-BELNR,
            (10) IT_BSEG-GJAHR,
            (5)  IT_BSEG-BUZEI,
            (10) IT_BSEG-AUGDT,
            (10) IT_BSEG-AUGBL,
            (12) IT_BSEG-HKONT,
            (9) IT_BSEG-AUGGJ,
            (9) IT_BSEG-AUGGJ_NEW,  "#EC CI_NOORDER
            (5) 'BSEG'.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        FORMAT COLOR 3.
        WRITE: (5) IT_BSEG-CORR.
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP.
        FORMAT COLOR OFF.

      ENDLOOP.

      CNT_TEMP = CNT_BSAS_OLD + 1.
      LOOP AT IT_BSAS FROM  CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
        FORMAT COLOR 2.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSAS-BUKRS,
            (10) IT_BSAS-BELNR,
            (10) IT_BSAS-GJAHR,
            (5)  IT_BSAS-BUZEI,
            (10) IT_BSAS-AUGDT,
            (10) IT_BSAS-AUGBL,
            (12) IT_BSAS-HKONT,
            (9) IT_BSAS-AUGGJ,
            (9) IT_BSAS-AUGGJ_NEW,  "#EC CI_NOORDER
            (5) 'BSAS'.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        FORMAT COLOR 3.
        WRITE: (5) IT_BSAS-CORR.
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP.
        FORMAT COLOR OFF.
      ENDLOOP.

    ENDIF.
    ULINE (120).

  ENDLOOP.      " Clearing Document Set

** Export to RFDT all the selected entries
** Exporting only at the end to get even BSEG entries, may miss values if
** Program terminates due to some error in between

  EXP_TAB = 'BSAS'.
  PERFORM EXPORT_RFDT USING EXP_TAB.

** Display total count and legend
  FORMAT COLOR 5.
  WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  ULINE (120).
ENDFORM.                    " GET_DATA_BSAS
*&---------------------------------------------------------------------*
*&      Form  EXPORT_RFDT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EXP_TAB  text
*----------------------------------------------------------------------*
FORM EXPORT_RFDT  USING    P_EXP_TAB.
  IF P_E_RFDT = ABAP_TRUE AND P_UPDATE = ABAP_TRUE.
    rfdt_key-date = sy-datlo.
    rfdt_key-time = sy-timlo.


    CASE P_EXP_TAB.
      WHEN 'BSAS'.
        rfdt_key-key1(7) = 'AUGJ_AS'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        EXPORT
        IT_CLEARING_DOC_BSAS
        IT_BSAS
        IT_BSEG  "#EC CI_FLDEXT_OK[3320010]
      TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        IF sy-subrc = 0.
          CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
        exp_key.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 3.
          WRITE:/ sy-vline NO-GAP,
                  'TABLE RFDT EXPORT FILE KEY:',
               50 sy-vline NO-GAP.
          FORMAT COLOR 2 INTENSIFIED OFF.
          WRITE:/ sy-vline NO-GAP,
                  exp_key,
               50 sy-vline NO-GAP.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 2 INTENSIFIED ON.
        ENDIF.
      WHEN 'BSAD'.
        rfdt_key-key1(7) = 'AUGJ_AD'.
        EXPORT
        IT_CLEARING_DOC_BSAD "#EC CI_FLDEXT_OK[2215424]
        IT_BSAD "#EC CI_FLDEXT_OK[2215424]
        IT_BSEG "#EC CI_FLDEXT_OK[2215424]
      TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
        IF sy-subrc = 0.
          CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
        exp_key.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 3.
          WRITE:/ sy-vline NO-GAP,
                  'TABLE RFDT EXPORT FILE KEY:',
               50 sy-vline NO-GAP.
          FORMAT COLOR 2 INTENSIFIED OFF.
          WRITE:/ sy-vline NO-GAP,
                  exp_key,
               50 sy-vline NO-GAP.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 2 INTENSIFIED ON.
        ENDIF.
      WHEN 'BSAK'.
        rfdt_key-key1(7) = 'AUGJ_AK'.
        EXPORT
        IT_CLEARING_DOC_BSAK "#EC CI_FLDEXT_OK[2215424]
        IT_BSAK "#EC CI_FLDEXT_OK[2215424]
        IT_BSEG "#EC CI_FLDEXT_OK[2215424]
      TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
        IF sy-subrc = 0.
          CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
        exp_key.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 3.
          WRITE:/ sy-vline NO-GAP,
                  'TABLE RFDT EXPORT FILE KEY:',
               50 sy-vline NO-GAP.
          FORMAT COLOR 2 INTENSIFIED OFF.
          WRITE:/ sy-vline NO-GAP,
                  exp_key,
               50 sy-vline NO-GAP.
          NEW-LINE.
          ULINE (50).
          FORMAT COLOR 2 INTENSIFIED ON.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " EXPORT_RFDT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BSAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_BSAK .

  SELECT DISTINCT BUKRS
                  LIFNR
                  AUGDT
                  AUGBL
             FROM bsak
              APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAK
              FOR ALL ENTRIES IN T_BUKRS
                WHERE BUKRS EQ  T_BUKRS-BUKRS
                  AND AUGDT GE  L_MIGDT
                  AND AUGBL IN  S_AUGBL
                  AND AUGDT IN  S_AUGDT
                  AND BELNR IN  S_BELNR
                  AND GJAHR IN  S_GJAHR
*{   REPLACE        TNGK900040                                        1
*\                  AND AUGGJ EQ  SPACE.
                  AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

  CLEAR: IT_BSEG,WA_BSEG,IT_BSAK.
  REFRESH: IT_BSEG,IT_BSAK.

** Header
  FORMAT COLOR 1.
  ULINE (120).
  WRITE:/ sy-vline NO-GAP,
          'Clearings Involved in Correction',
      120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  FORMAT COLOR 4.
  WRITE:/ sy-vline NO-GAP,
      (5) 'BUKRS',
      (10) 'AUGDT',
      (10) 'AUGBL',
      (12) 'LIFNR',
      (5) 'AUGGJ',
      (8) 'UPD_BSEG',
     (8) 'UPD_BSAK',
     (8) 'UPD_CLR',
     (4) 'CORR'.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  ULINE (120).


  IF P_D_LIST = ABAP_TRUE.
    FORMAT COLOR 2.
    WRITE:/ sy-vline NO-GAP,
        (5) 'BUKRS',
        (10) 'BELNR',
        (10) 'GJAHR',
        (5)  'BUZEI',
        (10) 'AUGDT',
        (10) 'AUGBL',
        (12) 'LIFNR',
        (9) 'AUGGJ_OLD',
        (9) 'AUGGJ_NEW',
        (5) 'TABLE',
        (5) 'CORR'.
    WRITE:120 sy-vline NO-GAP.
    ULINE (120).
    FORMAT COLOR OFF.

  ENDIF.

** End Header

  LOOP AT IT_CLEARING_DOC_BSAK. " Loop at the set and get the lines for clearing

    CLEAR : CNT_UPD_BSAK,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAK_OLD,CNT_BSEG_NEW,CNT_BSAK_NEW.

** Documentatoin of update or test mode
    IF P_UPDATE = ABAP_TRUE.
      IT_CLEARING_DOC_BSAK-CORR = 'U'.
    ELSE.
      IT_CLEARING_DOC_BSAK-CORR = 'X'.
    ENDIF.
    MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAK,CNT_UPD_BSEG.

    DESCRIBE TABLE IT_BSAK  LINES CNT_BSAK_OLD.

    SELECT * FROM BSAK APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAK
             WHERE BUKRS =  IT_CLEARING_DOC_BSAK-BUKRS
             AND   LIFNR =  IT_CLEARING_DOC_BSAK-LIFNR
             AND   AUGDT =  IT_CLEARING_DOC_BSAK-AUGDT
             AND   AUGBL =  IT_CLEARING_DOC_BSAK-AUGBL
*{   REPLACE        TNGK900040                                        2
*\             AND   AUGGJ EQ SPACE.
             AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

    IF SY-SUBRC = 0.

      DESCRIBE TABLE IT_BSAK LINES CNT_BSAK_NEW.
      CLEAR CNT_TEMP_BSAK.

      CNT_TEMP_BSAK = CNT_BSAK_OLD.
      WHILE CNT_TEMP_BSAK LT CNT_BSAK_NEW.
        CNT_TEMP_BSAK = CNT_TEMP_BSAK + 1.
        READ TABLE IT_BSAK INDEX CNT_TEMP_BSAK INTO WA_BSAK.  "#EC CI_NOORDER
        IF SY-SUBRC = 0.
          IF WA_BSAK-AUGBL = WA_BSAK-BELNR.
            IT_CLEARING_DOC_BSAK-AUGGJ = WA_BSAK-GJAHR.
            MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
** Update the internal table with the new value
            EXIT. " Got the Required Clearing Year, exit while loop.
          ENDIF.
        ENDIF.

**  Try Finding AUGGJ with help from BKPF
        IF IT_CLEARING_DOC_BSAK-AUGGJ EQ SPACE AND CNT_TEMP_BSAK = CNT_BSAK_NEW.
          READ TABLE IT_BSAK INDEX CNT_BSAK_NEW INTO  IT_BSAK.  "#EC CI_NOORDER
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
              WHERE        BUKRS =  IT_BSAK-BUKRS
                     AND   BELNR =  IT_BSAK-BELNR
                     AND   GJAHR =  IT_BSAK-GJAHR
                     AND   BUZEI =  IT_BSAK-BUZEI.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          IF SY-SUBRC = 0.
            SELECT SINGLE * FROM BKPF INTO WA_BKPF
                 WHERE BUKRS = IT_CLEARING_DOC_BSAK-BUKRS
                 AND   BELNR = IT_CLEARING_DOC_BSAK-AUGBL
                 AND   CPUDT = WA_BSEG-AUGCP.  "#EC CI_NOORDER

            IF SY-SUBRC = 0.
              IT_CLEARING_DOC_BSAK-AUGGJ = WA_BKPF-GJAHR.
              MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
            ENDIF.
          ENDIF.
        ENDIF.  " Try Finding AUGGJ with help from BKPF
      ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition


      IF IT_CLEARING_DOC_BSAK-AUGGJ NE SPACE.

** Modify the IT and update the database with new values.
        CNT_TEMP = CNT_BSAK_OLD + 1.
        LOOP AT IT_BSAK FROM  CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
          IT_BSAK-AUGGJ_NEW = IT_CLEARING_DOC_BSAK-AUGGJ.
          IT_BSAK-CORR  = 'X'.
          MODIFY IT_BSAK FROM IT_BSAK.
          IF P_UPDATE = ABAP_TRUE.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*            UPDATE BSAK SET AUGGJ =  IT_CLEARING_DOC_BSAK-AUGGJ
*                       WHERE BUKRS = IT_BSAK-BUKRS
*                         AND LIFNR = IT_BSAK-LIFNR
*                         AND AUGDT = IT_BSAK-AUGDT
*                         AND AUGBL = IT_BSAK-AUGBL
*                         AND BELNR = IT_BSAK-BELNR
*                         AND GJAHR = IT_BSAK-GJAHR
*                         AND BUZEI = IT_BSAK-BUZEI.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
            IF SY-SUBRC = 0.
              IT_BSAK-CORR = 'U'.
              CNT_UPD_BSAK = CNT_UPD_BSAK + sy-dbcnt.
            ELSE.
              IT_BSAK-CORR = 'E'.
              IT_CLEARING_DOC_BSAK-CORR = 'E'.
              MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
            ENDIF.
            MODIFY IT_BSAK FROM IT_BSAK.
          ELSE.
            CNT_UPD_BSAK = CNT_UPD_BSAK + 1.
          ENDIF.
        ENDLOOP.

** Modify the IT and update database for BSEG with new AUGGJ
        CNT_TEMP =  CNT_BSAK_OLD + 1.

        DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
        LOOP AT IT_BSAK FROM CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
          DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.

          SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
                WHERE BUKRS = IT_BSAK-BUKRS
                AND   BELNR = IT_BSAK-BELNR
                AND   GJAHR = IT_BSAK-GJAHR
                AND   BUZEI = IT_BSAK-BUZEI
*{   REPLACE        TNGK900040                                        3
*\                AND   AUGGJ EQ SPACE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                AND ( AUGGJ =  SPACE OR AUGGJ = '' ).  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*}   REPLACE

          IF SY-SUBRC = 0.
            DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
            CNT_TEMP_BSEG = CNT_BSEG_OLD.

            WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.

              CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
              READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
              IF SY-SUBRC = 0.
                IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAK-AUGGJ.
                IT_BSEG-CORR  = 'X'.
                MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
** Update the values to the internal table with new AUGGJ
                IF P_UPDATE = ABAP_TRUE.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
*                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAK-AUGGJ
*                             WHERE BUKRS = IT_BSEG-BUKRS
*                               AND BELNR = IT_BSEG-BELNR
*                               AND GJAHR = IT_BSEG-GJAHR
*                               AND BUZEI = IT_BSEG-BUZEI
**{   REPLACE        TNGK900040                                        4
**\                               AND AUGGJ EQ SPACE.
                  MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC

                  IF SY-SUBRC = 0.
                    IT_BSEG-CORR = 'U'.
                    CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
                  ELSE.
                    IT_BSEG-CORR = 'E'.
                    IT_CLEARING_DOC_BSAK-CORR = 'E'.
                    MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
                  ENDIF.
                  MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
                ELSE.
                  CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
                ENDIF.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.

      ELSE.
        IT_CLEARING_DOC_BSAK-CORR = 'N'.
        MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
      ENDIF.

      IT_CLEARING_DOC_BSAK-CNT_UPD_BSAK = CNT_UPD_BSAK.
      IT_CLEARING_DOC_BSAK-CNT_UPD_BSEG = CNT_UPD_BSEG.

      CNT_UPD_CLR =  CNT_UPD_BSAK + CNT_UPD_BSEG.

      IT_CLEARING_DOC_BSAK-CNT_UPD_CLR  = CNT_UPD_CLR.
      CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.

      MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.

    ENDIF.      " Clearing Documents in a Clearing

** Display the clearing info
    FORMAT COLOR 4.
    WRITE:/ sy-vline NO-GAP,
        (5) IT_CLEARING_DOC_BSAK-BUKRS,   "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAK-AUGDT,  "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAK-AUGBL, "#EC CI_NOORDER
        (12) IT_CLEARING_DOC_BSAK-LIFNR, "#EC CI_NOORDER
        (5) IT_CLEARING_DOC_BSAK-AUGGJ, "#EC CI_NOORDER
        (8) CNT_UPD_BSEG, "#EC CI_NOORDER
       (8)  CNT_UPD_BSAK, "#EC CI_NOORDER
        (8) CNT_UPD_CLR.  "#EC CI_NOORDER
    FORMAT COLOR 3.
    WRITE : (4) IT_CLEARING_DOC_BSAK-CORR.  "#EC CI_NOORDER
    FORMAT COLOR OFF.
    WRITE:120 sy-vline NO-GAP.
    FORMAT COLOR OFF.

    IF P_D_LIST = ABAP_TRUE.

      CNT_TEMP = CNT_DISP_BSEG + 1.
      LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
        FORMAT COLOR 2.
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSEG-BUKRS, "#EC CI_NOORDER
            (10) IT_BSEG-BELNR, "#EC CI_NOORDER
            (10) IT_BSEG-GJAHR, "#EC CI_NOORDER
            (5)  IT_BSEG-BUZEI, "#EC CI_NOORDER
            (10) IT_BSEG-AUGDT, "#EC CI_NOORDER
            (10) IT_BSEG-AUGBL, "#EC CI_NOORDER
            (12) IT_BSEG-LIFNR, "#EC CI_NOORDER
            (9) IT_BSEG-AUGGJ, "#EC CI_NOORDER
            (9) IT_BSEG-AUGGJ_NEW, "#EC CI_NOORDER
            (5) 'BSEG'.  "#EC CI_NOORDER
        FORMAT COLOR 3.
        WRITE: (5) IT_BSEG-CORR. "#EC CI_NOORDER
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP. "#EC CI_NOORDER
        FORMAT COLOR OFF.

      ENDLOOP.

      CNT_TEMP = CNT_BSAK_OLD + 1.
      LOOP AT IT_BSAK FROM  CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
        FORMAT COLOR 2.
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSAK-BUKRS, "#EC CI_NOORDER
            (10) IT_BSAK-BELNR, "#EC CI_NOORDER
            (10) IT_BSAK-GJAHR, "#EC CI_NOORDER
            (5)  IT_BSAK-BUZEI, "#EC CI_NOORDER
            (10) IT_BSAK-AUGDT, "#EC CI_NOORDER
            (10) IT_BSAK-AUGBL, "#EC CI_NOORDER
            (12) IT_BSAK-LIFNR, "#EC CI_NOORDER
            (9) IT_BSAK-AUGGJ, "#EC CI_NOORDER
            (9) IT_BSAK-AUGGJ_NEW, "#EC CI_NOORDER
            (5) 'BSAK'.  "#EC CI_NOORDER
        FORMAT COLOR 3.
        WRITE: (5) IT_BSAK-CORR.
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP.
        FORMAT COLOR OFF.
      ENDLOOP.

    ENDIF.
    ULINE (120).

  ENDLOOP.      " Clearing Document Set

** Export to RFDT all the selected entries
** Exporting only at the end to get even BSEG entries, may miss values if
** Program terminates due to some error in between

  EXP_TAB = 'BSAK'.
  PERFORM EXPORT_RFDT USING EXP_TAB.

** Display total count and legend
  FORMAT COLOR 5.
  WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT. "#EC CI_NOORDER
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP. "#EC CI_NOORDER
  ULINE (120).
ENDFORM.                    " GET_DATA_BSAK
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_BSAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_BSAD .

  SELECT DISTINCT BUKRS
                  KUNNR
                  AUGDT
                  AUGBL
             FROM BSAD
              APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAD
              FOR ALL ENTRIES IN T_BUKRS
                WHERE BUKRS EQ  T_BUKRS-BUKRS
                  AND AUGDT GE  L_MIGDT
                  AND AUGBL IN  S_AUGBL
                  AND AUGDT IN  S_AUGDT
                  AND BELNR IN  S_BELNR
                  AND GJAHR IN  S_GJAHR
*{   REPLACE        TNGK900040                                        1
*\                  AND AUGGJ EQ  SPACE.
                  AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

  CLEAR: IT_BSEG,WA_BSEG,IT_BSAD.
  REFRESH: IT_BSEG,IT_BSAD.

** Header
  FORMAT COLOR 1.
  ULINE (120).
  WRITE:/ sy-vline NO-GAP,
          'Clearings Involved in Correction',
      120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  FORMAT COLOR 4.
  WRITE:/ sy-vline NO-GAP,
      (5) 'BUKRS',
      (10) 'AUGDT',
      (10) 'AUGBL',
      (12) 'KUNNR',
      (5) 'AUGGJ',
      (8) 'UPD_BSEG',
     (8) 'UPD_BSAD',
     (8) 'UPD_CLR',
     (4) 'CORR'.
  WRITE:120 sy-vline NO-GAP.
  FORMAT COLOR OFF.
  ULINE (120).


  IF P_D_LIST = ABAP_TRUE.
    FORMAT COLOR 2.
    WRITE:/ sy-vline NO-GAP,
        (5) 'BUKRS',
        (10) 'BELNR',
        (10) 'GJAHR',
        (5)  'BUZEI',
        (10) 'AUGDT',
        (10) 'AUGBL',
        (12) 'KUNNR',
        (9) 'AUGGJ_OLD',
        (9) 'AUGGJ_NEW',
        (5) 'TABLE',
        (5) 'CORR'.
    WRITE:120 sy-vline NO-GAP.
    ULINE (120).
    FORMAT COLOR OFF.

  ENDIF.

** End Header

  LOOP AT IT_CLEARING_DOC_BSAD. " Loop at the set and get the lines for clearing

    CLEAR : CNT_UPD_BSAD,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAD_OLD,CNT_BSEG_NEW,CNT_BSAD_NEW.

** Documentatoin of update or test mode
    IF P_UPDATE = ABAP_TRUE.
      IT_CLEARING_DOC_BSAD-CORR = 'U'.
    ELSE.
      IT_CLEARING_DOC_BSAD-CORR = 'X'.
    ENDIF.
    MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAD,CNT_UPD_BSEG.

    DESCRIBE TABLE IT_BSAD  LINES CNT_BSAD_OLD.

    SELECT * FROM BSAD APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAD
             WHERE BUKRS =  IT_CLEARING_DOC_BSAD-BUKRS
             AND   KUNNR =  IT_CLEARING_DOC_BSAD-KUNNR
             AND   AUGDT =  IT_CLEARING_DOC_BSAD-AUGDT
             AND   AUGBL =  IT_CLEARING_DOC_BSAD-AUGBL
*{   REPLACE        TNGK900040                                        2
*\             AND   AUGGJ EQ SPACE.
             AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
*}   REPLACE

    IF SY-SUBRC = 0.

      DESCRIBE TABLE IT_BSAD LINES CNT_BSAD_NEW.
      CLEAR CNT_TEMP_BSAD.

      CNT_TEMP_BSAD = CNT_BSAD_OLD.
      WHILE CNT_TEMP_BSAD LT CNT_BSAD_NEW.
        CNT_TEMP_BSAD = CNT_TEMP_BSAD + 1.
        READ TABLE IT_BSAD INDEX CNT_TEMP_BSAD INTO WA_BSAD.  "#EC CI_NOORDER
        IF SY-SUBRC = 0.
          IF WA_BSAD-AUGBL = WA_BSAD-BELNR.
            IT_CLEARING_DOC_BSAD-AUGGJ = WA_BSAD-GJAHR.
            MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
** Update the internal table with the new value
            EXIT. " Got the Required Clearing Year, exit while loop.
          ENDIF.
        ENDIF.

**  Try Finding AUGGJ with help from BKPF
        IF IT_CLEARING_DOC_BSAD-AUGGJ EQ SPACE AND CNT_TEMP_BSAD = CNT_BSAD_NEW.
          READ TABLE IT_BSAD INDEX CNT_BSAD_NEW INTO IT_BSAD.  "#EC CI_NOORDER
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
              WHERE        BUKRS =  IT_BSAD-BUKRS
                     AND   BELNR =  IT_BSAD-BELNR
                     AND   GJAHR =  IT_BSAD-GJAHR
                     AND   BUZEI =  IT_BSAD-BUZEI.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          IF SY-SUBRC = 0.
            SELECT SINGLE * FROM BKPF INTO WA_BKPF
                 WHERE BUKRS = IT_CLEARING_DOC_BSAD-BUKRS
                 AND   BELNR = IT_CLEARING_DOC_BSAD-AUGBL
                 AND   CPUDT = WA_BSEG-AUGCP.  "#EC CI_NOORDER

            IF SY-SUBRC = 0.
              IT_CLEARING_DOC_BSAD-AUGGJ = WA_BKPF-GJAHR.
              MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
            ENDIF.
          ENDIF.
        ENDIF.  " Try Finding AUGGJ with help from BKPF
      ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition


      IF IT_CLEARING_DOC_BSAD-AUGGJ NE SPACE.

** Modify the IT and update the database with new values.
        CNT_TEMP = CNT_BSAD_OLD + 1.
        LOOP AT IT_BSAD FROM  CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
          IT_BSAD-AUGGJ_NEW = IT_CLEARING_DOC_BSAD-AUGGJ.
          IT_BSAD-CORR  = 'X'.
          MODIFY IT_BSAD FROM IT_BSAD.
          IF P_UPDATE = ABAP_TRUE.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*            UPDATE BSAD SET AUGGJ =  IT_CLEARING_DOC_BSAD-AUGGJ
*                       WHERE BUKRS = IT_BSAD-BUKRS
*                         AND KUNNR = IT_BSAD-KUNNR
*                         AND AUGDT = IT_BSAD-AUGDT
*                         AND AUGBL = IT_BSAD-AUGBL
*                         AND BELNR = IT_BSAD-BELNR
*                         AND GJAHR = IT_BSAD-GJAHR
*                         AND BUZEI = IT_BSAD-BUZEI.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
            IF SY-SUBRC = 0.
              IT_BSAD-CORR = 'U'.
              CNT_UPD_BSAD = CNT_UPD_BSAD + sy-dbcnt.
            ELSE.
              IT_BSAD-CORR = 'E'.
              IT_CLEARING_DOC_BSAD-CORR = 'E'.
              MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
            ENDIF.
            MODIFY IT_BSAD FROM IT_BSAD.
          ELSE.
            CNT_UPD_BSAD = CNT_UPD_BSAD + 1.
          ENDIF.
        ENDLOOP.

** Modify the IT and update database for BSEG with new AUGGJ
        CNT_TEMP =  CNT_BSAD_OLD + 1.

        DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
        LOOP AT IT_BSAD FROM CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
          DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.

          SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
                WHERE BUKRS = IT_BSAD-BUKRS
                AND   BELNR = IT_BSAD-BELNR
                AND   GJAHR = IT_BSAD-GJAHR
                AND   BUZEI = IT_BSAD-BUZEI
*{   REPLACE        TNGK900040                                        3
*\                AND   AUGGJ EQ SPACE.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
                AND ( AUGGJ =  SPACE OR AUGGJ = '' ).  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*}   REPLACE

          IF SY-SUBRC = 0.
            DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
            CNT_TEMP_BSEG = CNT_BSEG_OLD.

            WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.

              CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
              READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
              IF SY-SUBRC = 0.
                IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAD-AUGGJ.
                IT_BSEG-CORR  = 'X'.
                MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
** Update the values to the internal table with new AUGGJ
                IF P_UPDATE = ABAP_TRUE.

" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
*                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAD-AUGGJ
*                             WHERE BUKRS = IT_BSEG-BUKRS
*                               AND BELNR = IT_BSEG-BELNR
*                               AND GJAHR = IT_BSEG-GJAHR
*                               AND BUZEI = IT_BSEG-BUZEI
**{   REPLACE        TNGK900040                                        4
**\                               AND AUGGJ EQ SPACE.
                  MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
*}   REPLACE
                  IF SY-SUBRC = 0.
                    IT_BSEG-CORR = 'U'.
                    CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
                  ELSE.
                    IT_BSEG-CORR = 'E'.
                    IT_CLEARING_DOC_BSAD-CORR = 'E'.
                    MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
                  ENDIF.
                  MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
                ELSE.
                  CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
                ENDIF.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.

      ELSE.
        IT_CLEARING_DOC_BSAD-CORR = 'N'.
        MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
      ENDIF.

      IT_CLEARING_DOC_BSAD-CNT_UPD_BSAD = CNT_UPD_BSAD.
      IT_CLEARING_DOC_BSAD-CNT_UPD_BSEG = CNT_UPD_BSEG.

      CNT_UPD_CLR =  CNT_UPD_BSAD + CNT_UPD_BSEG.

      IT_CLEARING_DOC_BSAD-CNT_UPD_CLR  = CNT_UPD_CLR.
      CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.

      MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.

    ENDIF.      " Clearing Documents in a Clearing

** Display the clearing info
    FORMAT COLOR 4.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    WRITE:/ sy-vline NO-GAP,
        (5) IT_CLEARING_DOC_BSAD-BUKRS,  "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAD-AUGDT,  "#EC CI_NOORDER
       (10) IT_CLEARING_DOC_BSAD-AUGBL,  "#EC CI_NOORDER
        (12) IT_CLEARING_DOC_BSAD-KUNNR,  "#EC CI_NOORDER
        (5) IT_CLEARING_DOC_BSAD-AUGGJ,  "#EC CI_NOORDER
        (8) CNT_UPD_BSEG,
       (8)  CNT_UPD_BSAD,
        (8) CNT_UPD_CLR.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    FORMAT COLOR 3.
    WRITE : (4) IT_CLEARING_DOC_BSAD-CORR.  "#EC CI_NOORDER
    FORMAT COLOR OFF.
    WRITE:120 sy-vline NO-GAP.
    FORMAT COLOR OFF.

    IF P_D_LIST = ABAP_TRUE.

      CNT_TEMP = CNT_DISP_BSEG + 1.
      LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
        FORMAT COLOR 2.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSEG-BUKRS,
            (10) IT_BSEG-BELNR,
            (10) IT_BSEG-GJAHR,
            (5)  IT_BSEG-BUZEI,
            (10) IT_BSEG-AUGDT,
            (10) IT_BSEG-AUGBL,
            (12) IT_BSEG-KUNNR,
            (9) IT_BSEG-AUGGJ,
            (9) IT_BSEG-AUGGJ_NEW,  "#EC CI_NOORDER
            (5) 'BSEG'.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        FORMAT COLOR 3.
        WRITE: (5) IT_BSEG-CORR.
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP.
        FORMAT COLOR OFF.

      ENDLOOP.

      CNT_TEMP = CNT_BSAD_OLD + 1.
      LOOP AT IT_BSAD FROM  CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
        FORMAT COLOR 2.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        WRITE:/ sy-vline NO-GAP,
            (5) IT_BSAD-BUKRS,
            (10) IT_BSAD-BELNR,
            (10) IT_BSAD-GJAHR,
            (5)  IT_BSAD-BUZEI,
            (10) IT_BSAD-AUGDT,
            (10) IT_BSAD-AUGBL,
            (12) IT_BSAD-KUNNR,
            (9) IT_BSAD-AUGGJ,
            (9) IT_BSAD-AUGGJ_NEW,  "#EC CI_NOORDER
            (5) 'BSAD'.  "#EC CI_NOORDER
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        FORMAT COLOR 3.
        WRITE: (5) IT_BSAD-CORR.
        FORMAT COLOR OFF.
        WRITE:120 sy-vline NO-GAP.
        FORMAT COLOR OFF.
      ENDLOOP.

    ENDIF.
    ULINE (120).

  ENDLOOP.      " Clearing Document Set

** Export to RFDT all the selected entries
** Exporting only at the end to get even BSEG entries, may miss values if
** Program terminates due to some error in between

  EXP_TAB = 'BSAD'.
  PERFORM EXPORT_RFDT USING EXP_TAB.

** Display total count and legend
  FORMAT COLOR 5.
  WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT.
  FORMAT COLOR OFF.
  WRITE:120 sy-vline NO-GAP.
  ULINE (120).

ENDFORM.                    " GET_DATA_BSAD
