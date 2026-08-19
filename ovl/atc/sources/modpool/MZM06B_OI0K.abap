*--- MAIN PROGRAM: MZM06B_OI0K ---*
*eject
***********************************************************************
*         PAI-Module  MM06BI0K   Bestellanforderungen                 *
*         Alphabetisch geordnet; hier beginnned mit 'K'               *
***********************************************************************

*eject
*----------------------------------------------------------------------*
*  Konfiguration anzeigen                                              *
*----------------------------------------------------------------------*
MODULE KONFIGURATION.

*-- Konfiguration nur bei Positionen mit konfigurierbarem Material ----
IF EBAN-CUOBJ IS INITIAL AND EBAN-KZKFG NE KZKFG-KAN.
* abort if not configured and not configurable (allow new conf)
   IF OK-CODE EQ KONF.
      CLEAR OK-CODE.
      MESSAGE E819 WITH EBAN-BNFPO.
   ENDIF.
ENDIF.

IF OK-CODE EQ SPACE AND
   SELFCODE EQ KONF.
   CLEAR DUNKEL.
   OK-CODE = SELFCODE.
ENDIF.

CHECK OK-CODE EQ KONF OR
      OK-CODE EQ NEXD.

IF OK-CODE EQ NEXD.
   CHECK TRTYP NE HIN.
ENDIF.

CLEAR DUNKEL.
CLEAR OK-CODE.

*-- Momentanen Selektionsfcode sichern, wenn auf dem Bild noch andere
*-- Funktionen möglich sind -------------------------------------------*
SAVFCODE = SELFCODE.

DATA L_FLAG_CONFIG_OF_ITEM_CHANGED TYPE C VALUE ' '.

CALL FUNCTION 'ME_DISPLAY_CONFIGURATION'
     EXPORTING
          I_EBAN  = EBAN
*         I_EKKO  = EKKO
*         I_EKPO  = EKPO
          I_AKTYP = AKTYP
     IMPORTING
          E_CUOBJ = EBAN-CUOBJ
          E_CHANGED = L_FLAG_CONFIG_OF_ITEM_CHANGED

     EXCEPTIONS
          OTHERS  = 1.

* if changeflag is set, set updateflags for order, item and config etc
IF L_FLAG_CONFIG_OF_ITEM_CHANGED = 'X'.
   VB_UPDKZ = 'X'. "general updateflag for whole purchase requisition
   EBAN-KZKFG = KZKFG-EIG.   "mark config as own (no copying nescessary)
   READ TABLE BSN WITH KEY BSNKEY BINARY SEARCH.
   IF SY-SUBRC = 0.
      BSN-CONFUPD = CON_UPDCONF. "Updateflag configuration
      BSN-KZKFG = KZKFG-EIG. "mark config as own (no copying nescessary)
      BSN-CUOBJ = EBAN-CUOBJ.
      MODIFY BSN INDEX SY-TABIX.
   ELSE.
      MESSAGE a013(CONF_IN_PURCH) WITH 'BSN-UPDATE in MM06BI0K'.
   ENDIF.
   MESSAGE S001(CONF_IN_PURCH) WITH EBAN-BNFPO. "config changed
ENDIF.

*-- Gesicherten Selektionsfcode wieder zurückladen --------------------*
SELFCODE = SAVFCODE.

ENDMODULE.

*end of MM06BI0K ******************************************************
