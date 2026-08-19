*--- MAIN PROGRAM: MZM06B_OF0A ---*
*&---------------------------------------------------------------------*
*&   ADD_BZTEK (special routine for Note 74393, not used in standard)  *
*&---------------------------------------------------------------------*
FORM ADD_BZTEK USING LFDAT LIKE EBAN-LFDAT
                     PSTTR LIKE MDPA-PSTTR.

   DATA: HDATUM LIKE EBAN-LFDAT.
   IF MTCOM-MATNR NE EBAN-MATNR OR MTCOM-WERKS NE EBAN-WERKS.
      PERFORM MATERIAL_LESEN_AENDERN USING EBAN-MATNR EBAN-WERKS.
   ENDIF.
   HDATUM = LFDAT - MT06E-PLIFZ.
   IF HDATUM GT SY-DATLO.
      PSTTR = HDATUM.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
           EXPORTING
                CORRECT_OPTION = '-'
                DATE = HDATUM
                FACTORY_CALENDAR_ID = T001W-FABKL
           IMPORTING
                DATE = HDATUM
           EXCEPTIONS
                OTHERS = 01.
      IF SY-SUBRC EQ 0 AND HDATUM GT SY-DATLO.
         PSTTR = HDATUM.
      ENDIF.
   ENDIF.

ENDFORM.
