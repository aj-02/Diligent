*--- MAIN PROGRAM: MZM06B_OI0I ---*
*eject
************************************************************************
*                                                                      *
* PAI Module Bestellanforderung                                        *
*     Module alphabetisch geordnet; hier alle mit "I" beginnend        *
*                                                                      *
************************************************************************


*eject                                                                 *
*----------------------------------------------------------------------*
* Verarbeitung der Inline-Texte    (Loop)                              *
*----------------------------------------------------------------------*
*
MODULE INLINE_TEXT_PAI.

CHECK REQUEST_KZ NE SPACE OR
      ( RM06B-SELKZ EQ 'X' AND SELFCODE EQ TEDE ).
PERFORM INLINE_TEXT_PAI.

ENDMODULE.

