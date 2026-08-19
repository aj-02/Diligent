*--- MAIN PROGRAM: MZM06B_OI0A ---*
*-------------------------------------------------------------------
***INCLUDE MM06BI0A .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  AVAILABILITY_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
MODULE AVAILABILITY_CHECK INPUT.

   IF EBAN-MENGE NE *EBAN-MENGE OR
      EBAN-LFDAT NE *EBAN-LFDAT OR
      EBAN-LOEKZ NE *EBAN-LOEKZ OR    "LOEKZ läuft eigentlich über
      EBAN-RESWK NE *EBAN-RESWK OR    "OKCODE_ENTS, ruft Detailbild
      EBAN-FRGDT NE *EBAN-FRGDT.      "nicht auf        "459368
      AC_MODE = AUTOMATIC.
      PERFORM AVAILABILITY_CHECK.
   ENDIF.

ENDMODULE.                 " AVAILABILITY_CHECK  INPUT
