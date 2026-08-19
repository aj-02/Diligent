
REPORT ZF_EDIT_CLEARING  MESSAGE-ID FB LINE-SIZE 132.

************************************************************************
* This program is not intended to run DIRECTLY. This program is used
* to clear entries in FI related tables.
* DO NOT EXECUTE THIS PROGRAM.
************************************************************************
TABLES: BSIS, BSAS, BSEG, BKPF, T001, BSIK, BSAK, BSID, BSAD.
SELECTION-SCREEN BEGIN OF BLOCK 001.
PARAMETERS: P_BUKRS LIKE BSEG-BUKRS MEMORY ID BUK,
            P_BELNR LIKE BSEG-BELNR MEMORY ID BLN,
            P_GJAHR LIKE BSEG-GJAHR MEMORY ID GJR,
            P_BUZEI LIKE BSEG-BUZEI OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS:  P_AUGBL LIKE BSEG-AUGBL,
             P_AUGDT LIKE BSEG-AUGDT.
SELECTION-SCREEN SKIP.
PARAMETERS: P_ECHTL AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK 001.
* konsistente Ausgleichsinformation ?
IF ( P_AUGBL IS INITIAL AND NOT P_AUGDT IS INITIAL ) OR
   ( NOT P_AUGBL IS INITIAL AND P_AUGDT IS INITIAL ).
  MESSAGE E000 WITH 'p_augbl and p_augdt must be both init or both set'.
ENDIF.

* gibts den buchungskreis
SELECT SINGLE * FROM  T001 WHERE  BUKRS  = P_BUKRS.
IF SY-SUBRC <> 0.
  MESSAGE E000 WITH 'Companycode' P_BUKRS 'does not exist'.
ENDIF.

* gibts den Kopf zu der zu ändernden bseg-zeile
SELECT SINGLE * FROM  BKPF
       WHERE  BUKRS  = T001-BUKRS
       AND    BELNR  = P_BELNR
       AND    GJAHR  = P_GJAHR.
IF SY-SUBRC <> 0.
  MESSAGE E000 WITH P_BUKRS P_BELNR P_GJAHR 'no header'.
ENDIF.

* gibts die zu ändernde Belegzeile
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
SELECT SINGLE * FROM  BSEG
       WHERE  BUKRS  = BKPF-BUKRS
       AND    BELNR  = BKPF-BELNR
       AND    GJAHR  = BKPF-GJAHR
       AND    BUZEI  = P_BUZEI.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
IF SY-SUBRC <> 0.
  MESSAGE E000 WITH P_BELNR P_BUZEI 'no such line'.
ENDIF.
* Koart 'M' kann nicht ausgeglichen werden
IF BSEG-KOART = 'M' AND NOT P_AUGBL IS INITIAL.
  MESSAGE E000 WITH 'Material accounts cannot be cleared'.
ENDIF.
* Keine OPVW der Zeile der Anlagenzeile ?
IF BSEG-KOART = 'A' AND NOT P_AUGBL IS INITIAL AND NOT BSEG-XHRES = 'X'.
  MESSAGE E000 WITH 'Line item not OI managed, clearing not possible'.
ENDIF.

* Keine OPVW der Zeile der Sachkontenzeile ?
IF BSEG-KOART = 'S' AND NOT P_AUGBL IS INITIAL AND NOT BSEG-XOPVW = 'X'.
  MESSAGE E000 WITH 'Line item not OI managed, clearing not possible'.
ENDIF.



*----------------------------------------------------------------------*
*       ab hier ist die Belegselektion abgeschlossen                   *
*----------------------------------------------------------------------*

WRITE: / BSEG-BUKRS COLOR COL_KEY,
         BSEG-BELNR COLOR COL_KEY,
         BSEG-GJAHR COLOR COL_KEY,
         BSEG-BUZEI COLOR COL_KEY,
         BSEG-BSCHL COLOR COL_NORMAL,
         BSEG-KOART COLOR COL_NORMAL,
         BSEG-SHKZG COLOR COL_NORMAL,
         BSEG-DMBTR COLOR COL_NORMAL.  "#EC CI_FLDEXT_OK[2610650]
WRITE :/3(13) 'before update' COLOR COL_NORMAL,
         BSEG-AUGDT COLOR COL_POSITIVE,
         BSEG-AUGBL COLOR COL_POSITIVE.
* -------------------------------------------------------------------- *
*          neue Ausgleichsinformation in bseg stellen.                 *
* -------------------------------------------------------------------- *

WRITE :/3(13) 'after update' COLOR COL_NORMAL,
         P_AUGDT COLOR COL_POSITIVE,
         P_AUGBL COLOR COL_POSITIVE.
         SKIP.
IF P_ECHTL = 'X'.
" Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
* S/4: BSEG clearing fields may be changed only by SAP standard programs; direct UPDATE not allowed.
*      Reset clearing via the standard posting interface (programmatic FBRA). Old code retained:
  DATA: lv_augbl_old TYPE bseg-augbl.
  lv_augbl_old = bseg-augbl.
*  PERFORM DELETE_OLD_INDEX. "<-- Löschen des Index
*  BSEG-AUGDT = P_AUGDT.
*  BSEG-AUGCP = P_AUGDT.
*  BSEG-AUGBL = P_AUGBL.
*  PERFORM MAKE_NEW_INDEX.   "<-- Neu erezugen
*  UPDATE BSEG.              "<-- Bseg updaten
  IF lv_augbl_old IS NOT INITIAL.
    CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
         i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
    CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = bseg-bukrs
         i_augbl = lv_augbl_old i_gjahr = bseg-gjahr i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
    CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
  ENDIF.
" Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
ENDIF.
* -------------------------------------------------------------------- *
*                     Ende des Hauptprogramms                          *
* -------------------------------------------------------------------- *

* -------------------------------------------------------------------- *
*                Neuerzeugen einer Indextabelle                        *
* -------------------------------------------------------------------- *
DEFINE MAKE_ANY_NEW_INDEX.

  MOVE-CORRESPONDING BKPF TO &1.
  MOVE-CORRESPONDING BSEG TO &1.

  IF &2 CA 'R'. "<-- Abstimmkonto von DKA.
   &1-ZUONR = BSEG-HZUON.
  ENDIF.

  INSERT &1.
  WRITE:/3 'Insert' COLOR COL_NORMAL,
           '&1' COLOR COL_NORMAL,
           'sy-subrc =' COLOR COL_NORMAL NO-GAP,
           SY-SUBRC COLOR COL_NORMAL NO-GAP.
END-OF-DEFINITION.
* -------------------------------------------------------------------- *
*               Löschen in einer Indextabelle                          *
* -------------------------------------------------------------------- *

DEFINE DELETE_ANY_OLD_INDEX.
       DELETE FROM  &1
       WHERE  BUKRS  = BSEG-BUKRS
       AND    &2  = BSEG-&2
       AND    GJAHR  = BSEG-GJAHR
       AND    BELNR  = BSEG-BELNR
       AND    BUZEI  = BSEG-BUZEI.
   WRITE :/3 'Delete' COLOR COL_NORMAL,
             '&1' COLOR COL_NORMAL,
             'sy-subrc =' COLOR COL_NORMAL NO-GAP,
              SY-SUBRC COLOR COL_NORMAL,
             'sy-dbcnt =' COLOR COL_NORMAL NO-GAP,
             SY-DBCNT COLOR COL_NORMAL.
END-OF-DEFINITION.


*&---------------------------------------------------------------------*
*&      Form  DELETE_OLD_INDEX
*&---------------------------------------------------------------------*
FORM DELETE_OLD_INDEX.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

IF ( BSEG-KOART CA 'SM' AND BSEG-XKRES = 'X' ) OR
   ( BSEG-KOART CA 'DKA' AND BSEG-XHRES = 'X' ).
*   DELETE_ANY_OLD_INDEX BSIS HKONT.
*   DELETE_ANY_OLD_INDEX BSAS HKONT.
ENDIF.
IF BSEG-KOART = 'D'.
*   DELETE_ANY_OLD_INDEX BSID KUNNR.
*   DELETE_ANY_OLD_INDEX BSAD KUNNR.
ENDIF.
IF BSEG-KOART = 'K'.
*   DELETE_ANY_OLD_INDEX BSIK LIFNR.
*   DELETE_ANY_OLD_INDEX BSAK LIFNR.
ENDIF.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
ENDFORM.                    " DELETE_OLD_INDEX

*&---------------------------------------------------------------------*
*&      Form  MAKE_NEW_INDEX
*&---------------------------------------------------------------------*

FORM MAKE_NEW_INDEX.
DATA: TABS(4) TYPE C,
      TABD(4) TYPE C,
      TABK(4) TYPE C.

IF   ( BSEG-KOART CA 'DKA' AND BSEG-XHRES = 'X' ).
   IF BSEG-AUGBL IS INITIAL.
*       MAKE_ANY_NEW_INDEX BSIS 'R'. "R = Abstimmkonto
   ELSE.
*       MAKE_ANY_NEW_INDEX BSAS 'R'. "R = Abstimmkonto
   ENDIF.
ENDIF.

IF ( BSEG-KOART CA 'SM' AND BSEG-XKRES = 'X' ).
   IF BSEG-AUGBL IS INITIAL.
*       MAKE_ANY_NEW_INDEX BSIS 'N'.  "N = Normal
   ELSE.
*       MAKE_ANY_NEW_INDEX BSAS 'N'.  "N = Normal
   ENDIF.
ENDIF.
IF BSEG-KOART CA 'D'.
   IF BSEG-AUGBL IS INITIAL.
*      MAKE_ANY_NEW_INDEX BSID 'N'. "N = Normal
   ELSE.
*      MAKE_ANY_NEW_INDEX BSAD 'N'. "N = Normal
   ENDIF.
ENDIF.

IF BSEG-KOART = 'K'.
   IF BSEG-AUGBL = SPACE.
*      MAKE_ANY_NEW_INDEX BSIK 'N'. "N = Normal
   ELSE.
*      MAKE_ANY_NEW_INDEX BSAK 'N'. "N = Normal
   ENDIF.

ENDIF.
ENDFORM.                    " MAKE_NEW_INDEX
