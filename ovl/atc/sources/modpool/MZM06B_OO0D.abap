*--- MAIN PROGRAM: MZM06B_OO0D ---*
*eject
***********************************************************************
* MM06BO0D  PBO-Module Banfverarbeitung                               *
*           Alphabetisch geordnet; hier beginnend mit 'D'             *
***********************************************************************

*---------------------------------------------------------------------*
*       Dynpro dunkel prozessieren                                    *
*---------------------------------------------------------------------*
MODULE DUNKEL OUTPUT.

IF DUNKEL EQ 'X'.
   IF SY-DYNNR = '0103'.
      CHECK SELFCODE EQ TEDE OR SELFCODE EQ TECO OR SELFCODE EQ TERE.
   ENDIF.
   IF SY-DYNNR = '0102' AND
      SY-BINPT NE SPACE.
      EXIT.
   ENDIF.
   SUPPRESS DIALOG.
ENDIF.

ENDMODULE.

*end*******************************************************************
