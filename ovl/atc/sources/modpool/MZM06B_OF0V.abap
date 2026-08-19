*--- MAIN PROGRAM: MZM06B_OF0V ---*
*  129623  25.11.1998  CF  4.5B  REPOS nicht änderbar bei unkont. Pos.
***********************************************************************
*  Form-Routinen   Bestellanforderungsabwicklung  MM06BF0V
*  Alphabetisch geordnet; hier beginnend mit 'V'
***********************************************************************

*---------------------------------------------------------------------*
*       Pruefen Daten fuer veraenderte Banf-Positionen                *
*---------------------------------------------------------------------*
FORM ver_pos_banf.

  CLEAR: auswahl3, auswahl4, auswahl5.

  IF eban-reswk NE *eban-reswk.
    IF eban-reswk NE space.
* Lieferwerk wurde geändert --> prüfen
      PERFORM reswk.
    ELSE.
* Lieferwerk zurückgesetzt --> Lieferant auch zurücknehmen
      CLEAR: eban-flief, eban-infnr, eban-konnr, eban-ktpnr,
             eban-vrtyp.
    ENDIF.
  ENDIF.

  CLEAR mt06e.
  CLEAR mt06b.
  CLEAR mtcom.
*------ Materialnummer eingegeben -------------------------------------*
  IF eban-matnr NE space.
*......Pruefen Material
    IF eban-werks NE space.
      PERFORM werks USING eban-werks space 'X'  "wegen T001K
                    CHANGING t001w t001k t001.
    ENDIF.
    PERFORM lesen_material USING eban-matnr eban-ematn
                                 eban-werks 'X' space eban-mprof
                                 eban-pstyp.
*  IF EBAN-RESWK NE SPACE AND EBAN-RESWK NE *EBAN-RESWK.
*     PERFORM LESEN_MATERIAL_RESWK
*                   USING EBAN-MATNR EBAN-WERKS EBAN-RESWK.
*  ENDIF.
    PERFORM dispodaten_merken.
  ENDIF.

*------ Pruefen Positionstyp und Kontierungstyp------------------------*
  CALL FUNCTION 'ME_ITEM_CATEGORY_INPUT'
       EXPORTING
            epstp = rm06b-epstp
       IMPORTING
            pstyp = eban-pstyp
            ptext = t163y-ptext.

*------ Pruefen vorhandene Bezugsquelle auf Verträglichkeit -----------*
  IF eban-konnr NE space OR eban-flief NE space OR eban-reswk NE space.
    IF aktyp NE anz AND ( sy-dyngr NE 'UEBB' OR
                          eban-reswk NE *eban-reswk OR
                          eban-matkl NE *eban-matkl ).
      PERFORM bezugsquelle_1.
*     PERFORM KNTTP_UMLAG(SAPFMMEX) USING
*                                EBAN-PSTYP EBAN-BSTYP EBAN-KNTTP
*                                EBAN-MATNR MT06E-WERTU *MT06E-WERTU.
    ENDIF.
  ENDIF.

  IF t160-vorga NE vorga-bgen.
    PERFORM pstyp_knttp_neu(sapfmmex) USING
                        eban-pstyp eban-bsart bstyp-banf eban-knttp
                        mtcom-werks mtcom-matnr
                        mt06e-wertu
                        CHANGING t163 t163k.
  ELSE.
    PERFORM pstyp_knttp_neu(sapfmmex) USING
                        eban-pstyp eban-bsart 'F' eban-knttp
                        mtcom-werks mtcom-matnr
                        mt06e-wertu
                        CHANGING t163 t163k.
  ENDIF.

*------ Setzen Feldauswahlfelder --------------------------------------*
  auswahl3(2) = 'PT'.
  auswahl3+2(1) = eban-pstyp.
  auswahl3+3(1) = 'B'.

*------ Banf aus Vertriebsbeleg erstellt - nur bedingte Änderungen ----*
  IF eban-estkz EQ 'V'.
    auswahl4 = 'ESTV'.
  ENDIF.

*------ Banf aus Fertigungsauftrag erstellt - nur bedingte Änderungen -*
  IF eban-estkz EQ 'F'.
    auswahl4 = 'ESTF'.
  ENDIF.

*------ Banf über Direktbeschaffung erstellt- nur bedingte Änderungen -*
  IF eban-estkz EQ 'D'.
    auswahl4 = 'ESTD'.
  ENDIF.

*------ Banf gelöscht - Keine Änderungen mehr möglich -----------------*
  IF eban-loekz NE space.
    auswahl4 = 'AKTA'.
  ENDIF.

*------ Prüfen Kontierungstyp -----------------------------------------*
  IF eban-knttp NE space.
    SELECT SINGLE * FROM t163k WHERE knttp EQ eban-knttp.
    kntimod = t163k-kntdy.
  ELSE.                                                     "126923
    CLEAR t163k.                                            "126923
  ENDIF.

*-- Klartext Loeschkennezeichen ---------------------------------------*
  CLEAR rm06b-loetx.
  IF eban-loekz NE space.
    rm06b-loetx = text-112.
  ENDIF.
  rm06b-mein1 = eban-meins.

*------ Pruefen Einkaufsgruppe ----------------------------------------*
  IF eban-ekgrp NE *eban-ekgrp AND
     eban-ekgrp NE space.
    PERFORM ekgrp(sapfmmex) USING eban-ekgrp
                            CHANGING t024.
  ENDIF.

*------ Pruefen Werk --------------------------------------------------*
  IF eban-werks NE space.
    PERFORM werks USING eban-werks space 'X'
                  CHANGING t001w t001k t001.
    kordb = t001w-kordb.
  ENDIF.

  IF eban-waers IS INITIAL AND
     NOT eban-werks IS INITIAL.
    eban-waers = t001-waers.
  ENDIF.

*------ Pruefen Lieferdatum -------------------------------------------*
  IF rm06b-eeind NE space.
    PERFORM eban-lfdat USING space.
  ENDIF.

  IF rm06b-eeind = space AND eban-bsakz = 'R'.                "insert
    CLEAR eban-lfdat.                  "insert
  ENDIF.                               "insert

  IF NOT ( eban-lfdat IS INITIAL ).    "insert
    IF eban-matnr NE space.
      IF eban-lfdat NE *eban-lfdat OR
        eban-lpein NE *eban-lpein.
        PERFORM ermitteln_freigabedatum(sapfmmex) USING t001w mt06e
                                                CHANGING rm06b eban.
      ENDIF.
    ENDIF.
  ENDIF.                               "insert

*------ Pruefen Lieferwerk --------------------------------------------*
*F EBAN-RESWK NE SPACE.
*  IF EBAN-RESWK EQ EBAN-WERKS.
*     PERFORM ENACO(SAPFMMEX) USING '06' '395'.
*     CASE SY-SUBRC.
*        WHEN 1.
*           MESSAGE W395.
*        WHEN 2.
*           MESSAGE E395.
*     ENDCASE.
*  ENDIF.
*  PERFORM WERKS(SAPFMMEX) USING EBAN-RESWK SPACE SPACE.
*NDIF.
  PERFORM berechtigungen_pos.

*------ Pruefen Lagerort ----------------------------------------------*
  IF eban-lgort NE *eban-lgort AND
     eban-lgort NE space.
    PERFORM lgort(sapfmmex) USING eban-lgort eban-werks
                            CHANGING t001l.
  ENDIF.

*------ Materialklasse pruefen -- -------------------------------------*
  IF eban-matkl NE *eban-matkl AND
     eban-matkl NE space.
* Warengruppe prüfen
    PERFORM matkl(sapfmmex) USING eban-matkl
                            CHANGING t023 t023t.
* Sachkonto evtl. neu ermitteln
    PERFORM bsc_change_matkl.
  ENDIF.

*------ Masseinheit pruefen -------------------------------------------*
  IF eban-meins NE *eban-meins AND
     eban-meins NE space.
    PERFORM meins(sapfmmex) USING eban-meins.
  ENDIF.

  PERFORM menge_pruefen.

*------ Statusbezogene Auswahl setzen ---------------------------------*
  MOVE 'AKT ' TO auswahl1.
  MOVE aktyp TO auswahl1+3.

*-- Verfügbarkeitsprüfung ---------------------------------------------*
*IF EBAN-MENGE NE *EBAN-MENGE OR EBAN-LFDAT NE *EBAN-LFDAT OR
*   EBAN-RESWK NE *EBAN-RESWK OR EBAN-LOEKZ NE *EBAN-LOEKZ.
*   PERFORM AVAILABILITY_CHECK.
*ENDIF.

*------ Freigabezustandbezogene Auswahl setzen ------------------------*
  PERFORM set_frgzu_auswahl.

  IF trtyp NE anz.
    aktyp = ver.
  ELSE.
    aktyp = anz.
  ENDIF.

  PERFORM bsc_knttp_change.

ENDFORM.

***END MM06bF01*********************************************************
