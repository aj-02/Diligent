*--- MAIN PROGRAM: MZM06B_OF0W ---*
***INCLUDE MM06BF0W .
*---------------------------------------------------------------------*
*         Pruefen Werk                                                *
*---------------------------------------------------------------------*
FORM WERKS USING WRK_WERKS WRK_EKORG WRK_BUPRU
           CHANGING WRK_T001W STRUCTURE T001W
                    WRK_T001K STRUCTURE T001K
                    WRK_T001  STRUCTURE T001.

  PERFORM WERKS(SAPFMMEX) USING WRK_WERKS WRK_EKORG WRK_BUPRU TRTYP
                          CHANGING WRK_T001W
                                   WRK_T001K
                                   WRK_T001.

ENDFORM.
