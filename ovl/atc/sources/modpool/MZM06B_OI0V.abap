*--- MAIN PROGRAM: MZM06B_OI0V ---*
*eject
***********************************************************************
*         PAI-Module  MM06BI0V   Bestellanforderungen                 *
*         Alphabetisch geordnet; hier beginnnend mit 'V'              *
***********************************************************************

*---------------------------------------------------------------------*
*       Verarbeiten Verteilungskennzeichen Multikontirung             *
*---------------------------------------------------------------------*
MODULE VRTKZ INPUT.

CASE EBAN-VRTKZ.
  WHEN '1'.
    RM06B-MKNTW = '3     '.      "3 Nachkommastellen bei Menge
  WHEN '2'.
    RM06B-MKNTW = '1     '.      "1 Nachkommastellen bei Prozent
  WHEN OTHERS.
    RM06B-MKNTW = '3     '.      "3 Nachkommastellen bei Menge
ENDCASE.

ENDMODULE.

*end of mm06bi02 ******************************************************
