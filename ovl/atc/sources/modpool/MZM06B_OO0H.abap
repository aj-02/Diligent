*--- MAIN PROGRAM: MZM06B_OO0H ---*
*eject
************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Banfabwicklung                      *
*     Module alphabetisch geordnet; hier beginnend mit "H"             *
*                                                                      *
************************************************************************

*eject
*----------------------------------------------------------------------*
* Hilfsfelder Statistikbild                                            *
*----------------------------------------------------------------------*
MODULE HILFSFELDER_STAT OUTPUT.

*--- Text zum Status --------------------------------------------------*
CASE EBAN-STATU.
   WHEN 'N'. RM06B-STATX = TEXT-015.
   WHEN 'A'. RM06B-STATX = TEXT-013.
   WHEN 'B'. RM06B-STATX = TEXT-014.
   WHEN 'K'. RM06B-STATX = TEXT-019.
   WHEN 'L'. RM06B-STATX = TEXT-020.
   WHEN 'S'. RM06B-STATX = TEXT-025.
ENDCASE.

*--- Text zum Status --------------------------------------------------*
CASE EBAN-ESTKZ.
   WHEN 'R'. RM06B-ESTTX = TEXT-016.
   WHEN 'B'. RM06B-ESTTX = TEXT-017.
   WHEN 'V'. RM06B-ESTTX = TEXT-018.
   WHEN 'U'. RM06B-ESTTX = TEXT-021.
   WHEN 'F'. RM06B-ESTTX = TEXT-022.
   WHEN 'D'. RM06B-ESTTX = TEXT-024.
   WHEN 'A'. RM06B-ESTTX = TEXT-026.
ENDCASE.

*--- Text zum Fixierungskennzeichen -----------------------------------*
CLEAR RM06B-FIXTX.
IF EBAN-FIXKZ NE SPACE.
   RM06B-FIXTX = TEXT-023.
ENDIF.

*--- Text zum Freigabekennzeichen -------------------------------------*
SELECT SINGLE * FROM T161U WHERE SPRAS EQ SY-LANGU
                             AND FRGKZ EQ EBAN-FRGKZ.
IF SY-SUBRC NE 0.
   CLEAR T161U.
ENDIF.

*--- Text zum Lagerort ------------------------------------------------*
CLEAR T001L.
IF EBAN-LGORT NE SPACE.
   SELECT SINGLE * FROM T001L WHERE WERKS EQ EBAN-WERKS
                              AND   LGORT EQ EBAN-LGORT.
ENDIF.

*--- Text zum Kontierungstyp ------------------------------------------*
IF EBAN-KNTTP NE SPACE.
   SELECT SINGLE * FROM T163I WHERE SPRAS EQ SY-LANGU
                              AND   KNTTP EQ EBAN-KNTTP.
ENDIF.

*--- Gesamtwert der Position berechnen --------------------------------*
IF EBAN-PEINH NE 0.
   REFE1 = EBAN-PREIS * EBAN-MENGE / 1000 / EBAN-PEINH.
ELSE.
   REFE1 = 0.
ENDIF.
IF REFE1 LE MAXWERT.
   RM06B-GSWRT = REFE1.
ELSE.
   RM06B-GSWRT = MAXWERT.
ENDIF.

*--- Datum Erfassungsblatt --------------------------------------------*
IF NOT EBAN-LBLNI IS INITIAL.
  RM06B-ERDAT = EBAN-BEDAT.
ENDIF.

ENDMODULE.
