*--- MAIN PROGRAM: MZM06B_OF0U ---*
*eject
***********************************************************************
*  Form-Routinen   Bestellanforderungsabwicklung  MM06BF0U
*  Alphabetisch geordnet; hier beginnend mit 'U'
***********************************************************************
* 17.12.97 SM Einkäufergruppe/Materialklasse aus Materialstamm
* 123010 13.11.1998 MK: HTN - Übernahme der HTN-Daten in der Bestellanf.
*---------------------------------------------------------------------*
*       Uebertragen Materialdaten                                     *
*---------------------------------------------------------------------*
FORM uebernahme_material.

  eban-txz01 = mt06e-maktx.            "Kurztext
  IF mt06e-matkl NE space.                                  "H75385
    eban-matkl = mt06e-matkl.          "Warengruppe
  ENDIF.                                                    "H75385
  IF eban-meins NE mt06e-meins AND
     NOT eban-meins IS INITIAL.
    PERFORM enaco(sapfmmex) USING '06' '147'.
    IF sy-subrc NE 0.
      MESSAGE w147 WITH mt06e-meins.
    ENDIF.
  ENDIF.
  eban-meins = mt06e-meins.            "Mengeneinheit
  rm06b-mein1 = mt06e-meins.           "Mengeneinheit f. Anzeige
*BAN-BATOL = MT06E-BATOL.              "Wiedervorlage
  eban-plifz = mt06e-plifz.            "Planlieferzeit ab 4.0C
  eban-webaz = mt06e-webaz.            "WE-Bearbeitungszeit
  eban-dispo = mt06e-dispo.            "Disponent
  IF eban-lgort IS INITIAL.
    eban-lgort = mt06e-lgfsb.
  ENDIF.

  IF mt06e-ekgrp NE space.  "nur, wenn Einkaufssicht gepflegt "H75385
    AUTHORITY-CHECK OBJECT 'M_BANF_EKG'                     "H75385
         ID 'ACTVT' FIELD '01'                              "H75385
         ID 'EKGRP' FIELD mt06e-ekgrp.                      "H75385
    IF sy-subrc IS INITIAL.                                 "H75385
      eban-ekgrp = mt06e-ekgrp.
    ENDIF.                                                  "H75385
  ENDIF.                                                    "H75385

  IF mtcor-rmbew EQ space.                                  "377839
    IF mt06e-vprsv NE space.
      eban-preis = mt06e-verpr.        "Durchschnittspreis
      IF mt06e-vprsv EQ 'S'.           "Standardpreis
        eban-preis = mt06e-stprs.
      ENDIF.
      eban-peinh = mt06e-peinh.        "Preiseinheit
      eban-waers = t001-waers.         "Waehrung              "122268
    ENDIF.
  ENDIF.

* Konfigurationsdaten
  IF eban-cuobj IS INITIAL.
    IF NOT mt06e-cuobj IS INITIAL.     "Werkskonfiguration
      eban-kzkfg = kzkfg-fre.
      eban-cuobj = mt06e-cuobj.
      eban-satnr = mt06e-stdpd.
    ELSE.
      IF NOT mt06e-cuobf IS INITIAL.   "Mandantenkonfiguration
        eban-kzkfg = kzkfg-fre.
        eban-cuobj = mt06e-cuobf.
        eban-satnr = mt06e-satnr.
      ENDIF.
    ENDIF.
  ENDIF.
  eban-attyp = mt06e-attyp.
  IF eban-cuobj IS INITIAL AND mt06e-kzkfg NE space.  "derzeit auch
    eban-kzkfg = kzkfg-kan.            "bei Sammelartikel
  ENDIF.
  IF mt06e-kzkfg NE space AND mt06e-attyp NE attyp-var.
    eban-satnr = eban-matnr.
  ENDIF.

  IF NOT mt06e-mprof IS INITIAL.
    eban-mprof = mt06e-mprof.                               "123010
  ENDIF.                                                    "123010
  IF NOT mt06e-bmatn IS INITIAL.                            "123010
    eban-matnr = mt06e-bmatn.                               "123010
    eban-ematn = mtcom-matnr.                               "123010
  ENDIF.                                                    "123010
  IF NOT mt06e-mfrnr IS INITIAL.                            "123010
    eban-mfrnr = mt06e-mfrnr.                               "123010
  ENDIF.                                                    "123010
  IF NOT mt06e-mfrpn IS INITIAL.                            "123010
    eban-mfrpn = mt06e-mfrpn.                               "123010
  ENDIF.                                                    "123010

ENDFORM.

***END MM06bF01*********************************************************
