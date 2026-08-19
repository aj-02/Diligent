*--- MAIN PROGRAM: MZM06B_OTOP ---*
*eject
program sapmm06b message-id 06.
*{   INSERT         SO7K000061                                        1
* SO4K000089 V Barth 3.1H -> 4.0B Migration 030798
* IS-Oil Downstream amendment                               "SO3K002606
* 3.0A   P Denyer                                           "SO3K002606
*}   INSERT
************************************************************************
* Daten  SAPMM06B 'Bestellanforderungen'                               *
************************************************************************

* 89684  03.12.1997  4.0B  KB  Check auf Mußeingaben numerischer Felder
* 88865  22.01.1998  3.1I  CF  Cursorposition nach Detailfunktion

constants con_updconf value 'U'.       "Update-Kz für Konfiguration

*----------------------------------------------------------------------*
*         Tabellen                                                     *
*----------------------------------------------------------------------*

tables: eban, *eban,                   "Banf-Position
        ebkn, *ebkn,                   "Banf-Kontierungsposition
        aeban,                         "Allg. Daten Banf
        ebanw, *ebanw, ebanadd,        "Arbeitsstrukturen Banf
        bqpim,                         "Bezugsquellenprüfung Export
        bqpex,                         "Bezugsquellenprüfung Import
        mchar,                         "Materialcharge
        mtcom,               "Kommunikationsbereich Materialstamm
       *mtcom,               "Kommunikationsbereich Materialstamm
      mtcor,               "Kommunikationsbereich Materialstamm Return
     *mtcor,               "Kommunikationsbereich Materialstamm Return
        mt06b,                         "Bewertungsdaten für Einkauf
        mt06e,                         "Einkaufsview des Materialstamms
       *mt06e,                         "Einkaufsview des Materialstamms
        mt61d,                         "Materialstamm Disposition
        mdcp,                          "Dispodaten
        mdpa,                          "Komponenten
       *mdpa,                          "Komponenten
        lfa1,                          "Lieferantenstamm allgemein
       *lfa1,                          "Lieferantenstamm allgemein
        wakh,                          "Aktionen
        wakp,                          "Aktionen
        ska1,                          "Sachkontenstamm
        skb1,                          "Sachkontenstamm
       *eina,                          "Infosatz
        eord,                          "Orderbuch
        ekko, ekpo,                    "Kontrakte/Lieferplaene
       *ekko, *ekpo,         "Kontrakte/Lieferplaene        "QTK
        thead,                         "Textheader
        rm06b, *rm06b,                 "E/A Tab
        rm06e,                         "E/A Tab Einkaufsbeleg
        comsrv,                        "Kommunikation Dienstleistung
        ceban, *ceban,                 "Kommunikation Freigabe
        kntbl,                         "Kontierungsblock export
        kntbe,                         "Kontierungsblock import
        ek05n,                         "neue Kontierungsobjekte Einkauf
        cobl,                          "neuer Kontierungsblock
       *cobl,                          "neuer Kontierungsblock
        tmp_spec,                      "Muster-LV
        tstc, tstct, tprg, t001w, *t001w,
        t009, t023, t023t, t024, t160, t160v, t161,
        t161t, t162, t163, *t163,
        t161s, t001, t165p, t168, t168f, t168t, ttxid, ttxit,
        ttxob, t163k, t001k, t162k, tbsl, t163y, t163i, t001l,
        t161u, t160c, t160d, t161v, t165, t16fc, t16fg, t16fd,
        tmppf,                         "MPN-Abwicklung
        meico.                         "MPN-Abwicklung Infosatz lesen

tables : t16fv.

tables:  zmm_annual_limit.
include mm06bttc.                      "4.0 Table Control
include mm06btac.               "Datendeklaration Verfügbarkeitsprüfung
type-pools: mmmfd.                     "4.6 Metafield Definitions
include mm_messages_mac.               "4.6 Makrodef. Messages

*---- Beginn der Strukturen für Freigabeverfahren ---------------------*
data:   begin of t_geban_new  occurs 30.
        include structure eban.
data:   end   of t_geban_new.
data:   begin of t_geban_old  occurs 30.
        include structure eban.
data:   end   of t_geban_old.
data:   begin of t_gebkn_new  occurs 30.
        include structure ebkn.
data:   end   of t_gebkn_new.
data:   begin of t_gebkn_old  occurs 30.
        include structure ebkn.
data:   end   of t_gebkn_old.

data: begin of save_eban occurs 20.
        include structure eban.
data: end of save_eban.

data: begin of save_xeban occurs 20.
        include structure eban.
data: end of save_xeban.

data: begin of xeban_wf occurs 20.
        include structure ueban.
data: end of xeban_wf.

data: begin of yeban_wf occurs 20.
        include structure ueban.
data: end of yeban_wf.

data: begin of hbsn occurs 10.
        include structure ebanw.
data: end of hbsn.

data  hsetf.                           "Hilfsfeld für Setzen FRG

*---- Beginn der Strukturen für Inline-Textverarbeitung ---------------*
data:   begin of tlinetab occurs 30.   "Zeilen Langtext
        include structure tline.
data:   end   of tlinetab.

data:   begin of tinlinetab occurs 10. "Inline-Zeilen Langtext
        include structure tline.
data:   end   of tinlinetab.

data:   begin of theadtab occurs 20.   "Header Langtext
        include structure thead.
data:    neu,
         fixie,
         selkz,
        end   of theadtab.

data:   begin of reftext occurs 20.    "Header Langtext
        include structure thead.
data:   end   of reftext.

data:   begin of htext,                "Hilfsstruktur für Textheader
           tdobject     like thead-tdobject,
           tdname       like thead-tdname,
           tdid         like thead-tdid,
           tdspras      like thead-tdspras,
         end of  htext.

data:   begin of textheader occurs 0.
        include structure txhd.
data:   end of textheader.

data: begin of nfields occurs 10,                           "89684/KB
         dynnr like sy-dynnr,                               "89684/KB
         fname like dynpread-fieldname,                     "89684/KB
      end of nfields.                                       "89684/KB

*- Tabelle für select-options -----------------------------------------*
ranges: sel_banfn for eban-banfn.

data:   txfunction(1)  type c,         "Änderungsfkt. zu Text
        hnewname like thead-tdname,    "für Umbenennen der Texte
        finline_count  like sy-stepl,  "Anzahl Inline_Textzeilen
        text_loop_count like sy-stepl, "Anzahl Loopzeilen
        langtext like rm06i-ltex1,     "Langtextzeile Sapscript
        format like rm06i-form1,       "Format Sapscript
        save_dunkel,                   "Dunkelsicherung
        default_absatz like rm06i-form1 value '* ',
        default_zeile  like rm06i-form1 value '/ ',
        feldleng(2) type p,            "Feldlänge für Describe
        request_screen,
        request_kz,
        request_kz_global,
        santw,                         "Antwort von Loss_of_data
        titel(3) type c,               "CUA-Titel
        uebbmod,                       "Erfassungsmodus Übersicht
        kntimod,                       "Erfassungsmodus Kontierung
       anfr_spras like sy-langu,       "Sprache der letzten Anfrage
        anfr_ebeln like ekko-ebeln,    "Nummer der letzten Anfrage
       eban_entries like sy-tfill,     "Anzahl gefundener Banftexte
        cs_possible,
        cs_done,
        pps_banf,      "Banf kann manuell nicht erweitert werden
        h_bnfpo like eban-bnfpo,
        savebnfpo like eban-bnfpo,
        h-subrc like sy-subrc,
        message_returncode like sy-subrc,  "availability check
        cqflag.                        "committed quantities

*- Hilfsfelder für Barcodeerfassung -----------------------------------*
data:    ar_object like  toaom-ar_object,
         barcode_id like  toav0-arc_doc_id.

data:   l_bnfpo like eban-bnfpo,                            "49328
        l_menge like eban-menge,                            "49328
        l_lfdat like eban-lfdat,                            "49328
        l_frgdt like eban-frgdt,                            "49328
         l_flief like eban-flief.

data:   t-firstind like sy-tfill,      "Textindizes
        t-aktind   like sy-tfill,
        t-merkind  like sy-tfill,      "für Cursorselection
        t-pagind   like sy-tfill,
        t-maxind   like sy-tfill,
        t-mintv    like sy-tfill,      "Block von
        t-mintb    like sy-tfill,      "Block bis
        t-minta    like sy-tfill,
        t-nextind  like sy-tfill.

data:   vb_updkz,                      "Flag für Verbuchung
        call_updkz,                    "Kz. Update in Call-Dialog
        buch_kz,                       "Kennzeichen noch zu sichern
        posaend,                       "Kennzeichen Positionsaenderung
        pfstat(4) type c,              "Pf-Status
        p_zeile like sy-linno,
        message_flag.

data  mode.
data    txz01_no_change.

*... Felder zur MPN-Abwicklung .......................................*
data: mpn value 'X',
      sl_matnr like eban-matnr.
data:  s_mprof like eban-mprof.


*---- Ende der Strukturen für Inline-Textverarbeitung -----------------*
*eject
*----------------------------------------------------------------------*
*         Common Data Part                                             *
*----------------------------------------------------------------------*
include fmmexcom.

data: push_anla(30).                   "Pushbutton für Anlagenkont.
data: duksc.                           "Dummykontierungsbild
data: proc_anla.                       "Merker für Verbuchung

*----------------------------------------------------------------------*
*       Datenfelder                                                    *
*----------------------------------------------------------------------*
*----- Konstanten -----------------------------------------------------*
data:
            kdy_val(8) value '/110/310', "Parameter für MK03
            kflagno type c value '1',  "Keine Kontierungsaend.
*------- Werte zum OK-Code:
            anla(4) value 'ANLA',      "Anlagen erzeugen
            seiv(4) value 'VW  ',      "Eine Seite vor
            seir(4) value 'RW  ',      "Eine Seite zurueck
            sein(4) value 'VS  ',      "letzte Seite
            sei1(4) value 'RS  ',      "erste Seite
            mark(4) value 'MARK',      "Markieren Zeile
            neup(4) value 'NP  ',      "Neue Position
            uebb(4) value 'AB  ',      "Uebersichtsbild
            refr(4) value 'RF  ',      "Referenzdaten bereitstellen
            bref(4) value 'BRF ',      "Referenzdaten bereitstellen
            frmo(4) value 'AFM ',      "Freigabemöglichkeiten
            frue(4) value 'AF  ',      "Freigabezustand Übersicht
            frde(4) value 'AFP ',      "Freigabezustand Detail
            setf(4) value 'SF  ',      "Freigeben
            sfbu(4) value 'SFBU',      "Freigeben+Buchen
            delf(4) value 'NF  ',      "Rücknahme Freigabe
            buch(4) value 'BU  ',      "Buchen
            ende(4) value 'EN  ',      "Ende Bearbeitung
            ente(4) value 'ENTE',      "Enter
            dele(4) value 'DL  ',      "Löschen
            aedp(4) value 'AV  ',      "Änderungen
            ordr(4) value 'ORDR',      "Orderbuch
            konf(4) value 'KONF',      "Konfiguration
            back(4) value 'BACK',      "Zurück
            refd(4) value 'REFD',      "Referenz dunkel
            refh(4) value 'REFH',      "Referenz hell
            stap(4) value 'AS  ',      "Statistik Position
            ents(4) value 'ES  ',      "Entsperren Position
            exit(4) value 'XIT',       "Abbrechen
            deta(4) value 'DETA',      "Detailbild
            knti(4) value 'KN  ',      "Kontierungen
            knwe(4) value 'KWE ',      "Kontierungswiederholung ein
            knwa(4) value 'KWA ',      "Kontierungswiederholung aus
            kntb(4) value 'KNTB',      "Kontierungsblock Detail
            lohn(4) value 'LB  ',      "Komponenten
            fmit(4) value 'FMIT',      "Finanzmittel
            lbst(4) value 'LBST',      "Neue Stücklistenauflösung
            dien(4) value 'DIEN',      "Leistungsblock
            lim(4) value 'LIM ',       "Limitdefinitionen
            pote(4) value 'TXP ',      "Positionstexte
            teco(4) value 'TECO',      "Text kopieren
            tere(4) value 'TERE',      "Text löschen
            tede(4) value 'TEDE',      "Langtextbild
            nexd(4) value 'NEXD',      "Naechstes Detailbild
            nexp(4) value 'NEXP',      "Naechste Position
            fsim(4) value 'FSIM',      "Freigabe Simulieren
            info(4) value 'ME13',      "Infosatz
            orda(4) value 'ME16',      "Orderbuch
            best(4) value 'ME23',      "Bestellung
            besa(4) value 'ME25',      "Alle Bestellungen
            rahm(4) value 'ME33',      "Rahmenverträge
            quot(4) value 'ME3Q',      "Rahmenverträge
            lief(4) value 'MK03',      "Lieferant
            mate(4) value 'MM30',      "Material
            matb(4) value 'TX08',      "Bestände
            gebe(4) value 'GEBE',      "Generieren Bestellung
            umod(4) value 'UMOD',      "Wechseln Darstellung
            detd like sy-ucomm value 'DETD'. "Anlieferungsanschrift
*------- Werte zum Vorgang
*DATA:       FRGB(2) VALUE 'BF',          "Banf-Freigabe
*            BGEN(2) VALUE 'BB',          "Bestellung mit Lief.Auswahl
*            BANF(2) VALUE 'B '.          "Bestellanforderung
*------Ablaufsteuerung ------------------------------------------------*
data: xkonstat,                        "Verarbeitungstatus Kontierungspo
        xpstyp like t163k-kzvbr,       "Verbuchungskennzeichen
        dynpronummer like sy-dynnr,    "Hilfsfeld Dynpronummer
        request,                       "Hilfsfeld Bild prozessiert
        request_bsc,                   "Request Kontierung
*       OK-CODE(5),                    "Funktionseingabe PF-Taste
        ok-code like t185f-fcode,      "Funktionseingabe PF-Taste
        calfcode like ok-code,         "Funktionscode nach Call
        diafcode like ok-code,         "Funktionscode nach Dialog
        oldfcode like ok-code,         "Funktionscode gehalten
        retfcode like ok-code,         "Funktionscode retten
        savfcode like ok-code,         "Funktionscode sichern
        selfcode like ok-code,         "Funktionscode Selektion
        loopfcode like ok-code,        "Funktionscode im Loop
       endfcode like ok-code,          "Funktionscode Dunkelbearbeitung
       comfcode like cm61q-rcode,      "Funktionscode Komponentenbearb.
       enddunkel(4) type c,            "Hilfsfeld     Dunkelbearbeitung
        referenz type c,               "Referenzvorgang
        callflg type c,                "Callkennzeichen
        msg_identification like sy-uzeit,  "Message Handler
       auto,                           "Kennz. gecallt aus Sammelfreig.
        frgpop,                        "Freigabepopup
        start_variante,
        tc_view_row type cxtab_column,
        htitel(30),                    "Titel Freigabepopup
        alle,                          "Kz. alle Positionen
        nexpo,                         "Kz. nächste Position
        pre02kz,                       "Kz. Pre-Read erfolgt
        count like sy-tfill,           "Zahl Zeilen in int. Tabelle
        zeile like sy-linno,           "Cursorposition
        zeile_pick like sy-linno,      "Cursorposition
        feld(11),                      "Feldname
        h-ind(3) type p,               "Hilfsfeld Index
        return like sy-subrc,          "Returncode
        retco,                         "Returncode
        savaktyp,                      "Hilfsfeld für AKTYP
        loopexit,                      "Kz. exit aus Loop
        dir_poscall like eban-bnfpo,   "Positionsnummer Call
        dir_diencall like eban-bnfpo,
        dien_no,
        lb_updkz,                      "Kennz. Komponentenupdate
        cursor_line like sy-stepl,     "Cursorposition           "88865
        answer,                        "Antwort aus Pop-UP
*------- Direktwerte zur Antwort --------------------------------------*
             ansy value 'J',
             ansn value 'N',
             ansa value 'A'.

*eject
*------Bild-und Feldauswahl -------------------------------------------*
data: i(3) type p,                     "Index Feldauswahlleiste
      string(128) type c,              "Work fuer Feldauswahlleiste
      dunkel,                          " X = Bild dunkel prozessieren
    callkz(2) type p,                  "wenn gt 0 -> im Call prozessier.
      savcallkz.

*----- Hilfsfelder Kontierung -----------------------------------------*
data: h-gjahr like bkpf-gjahr,         "Hilfsfeld Geschäftsjahr
      h-bukrs like t001-bukrs,         "Hilfsfeld Buchungskreis
      h-monat like bkpf-monat,         "Hilfsfeld Geschäftsmonat
*     H-BSCHL LIKE BSEG-BSCHL,         "Hilfsfeld buchungsschlüssel
      h-maske(100) type c,             "Hilfsfeld Feldauswahl
      h-prctr like ebkn-prctr,         "Hilfsfeld Profit Center
      h-sakto like ebkn-sakto,         "Hilfsfeld Sachkonto
      h-kostl like ebkn-kostl,         "Hilfsfeld Kostenstelle
      h-aufnr like ebkn-aufnr.         "Hilfsfeld Auftrag

*----- Hilfsfelder Freigabe -------------------------------------------*
data: rel_no_changes,                                       "124369
      rel_no_changes_general.                               "124369
data: hgswrt like ceban-gswrt,
      f1 type f.
data: wfakt,
      wfpos like eban-bnfpo.
data: hfrgzu like eban-frgzu,
      hfrgkz like eban-frgkz,
      hfrgrl like eban-frgrl.

data: h_sy-tabix like sy-tabix.
data  change_ok.                       "Banfen aus Aufträgen

*------Funktionale Variable -------------------------------------------*
data: xbsakz,                          "Bestellartenkennzeichen
      xlvknz,                          "Kennzeichen LV-INFO
      ebanpo like eban-bnfpo,          "Letzte Banfposition
      baninc like eban-bnfpo,          "Increment fuer Banf-Position
      ebknpo like ebkn-zebkn,          "Letzte Kontierungsposition
      index_ebkn  like sy-tabix,       "EBKN Index beim Aendern
      char(30) type c,                 "Hilfsfeld Copyfunktion
      text1(10) type c,                "Hilfsfeld Bildtitel

*------Indizes für Tabelle BSN - int. Tab. der Banf-Positionen --------*
     b-pagind like sy-tabix,           "Seitenindex auf Schnellerf.bild
      b-aktind like sy-tabix,          "Aktueller Index Banfposition
      b-maxind like sy-tabix,          "Maximaler Index Banfposition
      b-lopind like sy-tabix,          "Anzahl Loopzeilen

*------Indizes für Tabelle BSC - int. Tab. für Kontierungspositionen --*
     k-pagind like sy-tabix,           "Seitenindex auf Schnellerf.bild
      k-aktind like sy-tabix,          "Aktueller Index Banfposition
      k-maxind like sy-tabix,          "Maximaler Index Banfposition
      k-firstind like sy-tabix,        "Erste Position
      k-lopind like sy-tabix,          "Anzahl Loopzeilen

*------Indizes für Tabelle RFT - int. Tab. bei Referenzbearbeitung ----*
      r-pagind like sy-tabix,          "Seitenindex auf Referenzbearb.
      r-aktind like sy-tabix,          "Aktueller Index Referenzbearb.
      r-maxind like sy-tabix,          "Maximaler Index Referenzbearb.
      r-firstind like sy-tabix,        "Erste Position  Referenzbearb.
      r-lopind like sy-tabix,          "Anzahl Loopzeilen

*------Indizes für Tabelle BSNB - Tab der Bezugswege ------------------*
      bb-pagind like sy-tabix,         "Seitenindex
      bb-aktind like sy-tabix,         "Aktueller Index
      bb-maxind like sy-tabix,         "Maximaler Index
      bb-lopind like sy-tabix.         "Anzahl Loopzeilen

*------- Direktwert zur Pruefung von Nettowertueberlaeufen ------------*
data: maxwert like rm06b-gswrt value '9999999999999'.       "27.07.05
*data: maxwert like rm06b-gswrt value '9999999999.99'.

*------- Hilfsfelder Finanzmittelrechnung -----------------------------*
data: fmakt,                           "Finanzmittelrechnung aktiv?
      fmesc,                           "Abbrechen gewählt auf Popup
      display.                         "nur Anzeige

*eject
*----- Hilfsfelder ----------------------------------------------------*
data: hfeld(2) type p,
      kordb,                           "Orderbuchpflicht?
      h-esokz,                         "Einkaufssonderkennzeichen
      h-lpein like eban-lpein,         "Hilfsfeld Datumsart
      xlpein  like eban-lpein,         "Hilfsfeld Datumsart
      h-lfdat like eban-lfdat,         "Hilfsfeld Lieferdatum
      hnrran  like t161-numki,         "Hilfsfeld Nummernkreisintervall
      h-text1(40),                     "Hilfsfeld Text
      h-text2(40),                     "Hilfsfeld Text
      relev,                           "Disporelevanz ?
      disp_ok,                         "Dispsatz erstellt ?
     exitflag,                     "Kennzeichen Fehler in Unterroutine
      ordr_msg_flag,                   "Warnung ausgegeben
      eord_flief like eban-flief,      "Fester Lieferant aus Orderbuch
      eord_reswk like eban-reswk,      "Festes Lieferwerk aus Orderbuch
     eord_konnr like eban-konnr,   "Fester Rahmenvertrag aus Orderbuch
    eord_ktpnr like eban-ktpnr,   "Position des Vertrags aus Orderbuch
      ebanpo_help like eban-bnfpo,     "Letzte Banfposition
      ebknpo_help like ebkn-zebkn,     "Letzte Banfkontierungsposition
      datum1(6) type p,                "Hilfsfeld Datum absolut
      hbsart like eban-bsart,          "Hilfsfeld Bestellart
      refe1(16) type p,                "Rechenfeld
      refew like ekpo-netwr,           "Wertrechenfeld
      indexa     like sy-tabix,        "Allgemeiner Index
      indexb     like sy-tabix,        "Allgemeiner Index
      indexc     like sy-tabix,        "Allgemeiner Index

      summ_menge like ebkn-menge,   "Kontrollfeld fuer Multikontierung
      summ_vproz(5) type p decimals 1, "Kontrollf. f. Multikontierung

      business_object like nast-objtype,   "generische Objektservices

      xlifnr like eban-flief,          "Lieferant
      xktknr like eban-konnr,          "Kontraktnummer
      xktpnr like eban-ktpnr,          "Kontraktposition
      xanzko(3) type p,                "Anzahl Kontrakte
      xsgbyc(1) type x,                "Hilfsfeld fuer RKIN
      zaehler(2) type p,               "Allgemeiner Zaehler
      additional_lines like sy-tabix.
*------- Hilfsfelder Berechtigungsprüfung -----------------------------*
data:    xactvt like tact-actvt,       "Hilfsfeld Aktivität
         xactxt(10),                   "Hilfsfeld Aktivitätstext
         xobjekt(10),                  "Hilfsfeld Objekt
         xobjtxt(15),                  "Hilfsfeld Objekttext
         xfldtxt(15),                  "Hilfsfeld Feldtext
         xberpos,                      "Kz. Pos ausgelassen wg Ber.
         xfrgpos,                      "Kz. Pos ausgelassen wg Freigabe
         aendber  like tact-actvt value '08',
       aendanz,                        "Kz. Änderungsbelegberechtigung
         efube like t160d-efubu,       "Funktionsberechtigung
         evopa like t160v-evopa.       "Vorschlagswerte

data: begin of seltab occurs 5,        "Übergabetabelle zum Submit and.
         name(8),                      "Reports
         type(4) value 'INCL',
         wert(20),
      end of seltab.

*------- MINT ( Feldleiste der markierten Positionen bei Blockmark.) --*
data:    begin of mint,
           bnfpv like eban-bnfpo,
           bnfpb like eban-bnfpo,
           bnfpa like eban-bnfpo,
         end of mint.

*eject
*------- Interne Tabelle fuer Banfpositionsdaten --------------------*
data: begin of bsn occurs 10.
        include structure ebanw.
data: end of bsn.
*------- Key zum Lesen BSN -------------------------------------------*
data: begin of bsnkey,
         mandt like eban-mandt,
         banfn like eban-banfn,
         bnfpo like eban-bnfpo,
      end of bsnkey.

*------- Abgebrochene Positionen --------------------------------------*
data: begin of bsna occurs 10,
         bnfpo like eban-bnfpo,
      end of bsna.

*-- Tabelle der Banfs, die in eine Bestellung umgesetzt werden --------*
data: begin of bat occurs 10.
        include structure eban.
data:   updkz.
data: end of bat.

*------- Int. Tab. für Banfs pro Bezugsweg ----------------------------*
data: begin of bsnb occurs 10,
         flief like eban-flief,
         ekorg like eban-ekorg,
         konnr like eban-konnr,
         name1 like lfa1-name1,
         zaehl(3) type p,
         ebeln like eban-ebeln,
      end of bsnb.

data: begin of xbsnb,
         flief like eban-flief,
         ekorg like eban-ekorg,
         konnr like eban-konnr,
         ktpnr like eban-ktpnr,
      end of xbsnb.

*------- Int. Tab. für selektierte Banf zur Bestellerzeugung ----------*
data: begin of bsns occurs 20,
         bnfpo like eban-bnfpo,
      end of bsns.

*------- Interne Tabelle fuer Banfkontierungsdaten ------------------*
data: begin of bsc occurs 10.          "Banf-Kontierungs-Pool
        include structure ebkn.
data:    update,
      end of bsc.

*------- Key zum Lesen BSC -------------------------------------------*
data: begin of bsckey,
         mandt like ebkn-mandt,
         banfn like ebkn-banfn,
         bnfpo like ebkn-bnfpo,
         zebkn like ebkn-zebkn,
      end of bsckey.

*------- Banfkontierungen für Bestellgenerierung --------------------*
data: begin of bbc occurs 10.
        include structure ebkn.
data: end of bbc.

*------- BSCW ( Position mit der zu wiederholenden Kontierung ) -------*
data:    begin of bscw occurs 5,
           knttp like eban-knttp,
           bnfpo like eban-bnfpo,
           skgef like sy-calld,        "Kz. Sachkonto gefunden, 4.0 CF
         end of bscw.

*------- ACC_TAB ( Tabelle für Kontierungsübergabe an SRV ) -----------*
data:    begin of acc_tab occurs 30.
        include structure ueskn.
data:    end of acc_tab.

*------- Interne Tabelle fuer Dispsatzerstellung --------------------*
data: begin of dis occurs 10.
        include structure edisp.
data: end of dis.

*------- DISKEY ( Tabellenkey ) ---------------------------------------*
data: begin of diskey,
        matnr like eban-matnr,
        werks like eban-werks,
      end of diskey.

*------- RFT ( Tabelle der Referenzdaten ) ----------------------------*
data: begin of rft occurs 50.
        include structure eban.
data:   update,
        rfpst like eban-pstyp,
        rfknt like eban-knttp,
        rfwrk like eban-werks,
        rflgo like eban-lgort,
      end of rft.

*------- RFTKEY ( Tabellenkey ) ---------------------------------------*
data: begin of rftkey,
        mandt like eban-mandt,
        banfn like eban-banfn,
        bnfpo like eban-bnfpo,
      end of rftkey.

*------- SEL ( Tabelle der selektierten Positionen )-------------------*
data:    begin of sel occurs 50,
           bnfpo like eban-bnfpo,
           kz,
         end of sel.

*------- Kontierungsdaten für Komponenten -----------------------------*
data: begin of xmdlb occurs 10.
        include structure mdlb.
data: end of xmdlb.

*eject
*------- Vorschlagsdaten Banf -----------------------------------------*
data: begin of veban,
         ekgrp like eban-ekgrp,
         werks like eban-werks,
         lgort like eban-lgort,
         bednr like eban-bednr,
         badat like eban-badat,
         lpein like eban-lpein,
         lfdat like eban-lfdat,
         frgdt like eban-frgdt,
         pstyp like eban-pstyp,
         knttp like eban-knttp,
         afnam like eban-afnam,
         matkl like eban-matkl,
         reswk like eban-reswk,
      end of veban.

*------ EXCL ( Tabelle für CUA-PF-STATUS  )  --------------------------*
data:    begin of excl occurs 20,
           funktion(4),
         end of excl.

*------ Sicherung T001W -----------------------------------------------*
data:    begin of st001w.
        include structure t001w.
data:    end of st001w.

*------ XORD ( Tabelle der Orderbuchsätze ) ---------------------------
data:    begin of xord occurs 0.
        include structure eord.
data:    end of xord.

*------ trwin (Tabelle für Kommunikation RWIN) ------------------------
data: begin of trwin occurs 5,
        function like trwpr-function,
      end of trwin.

*------ Tabellen für Pre-read Material --------------------------------
data:    begin of xpre02 occurs 10.
        include structure pre02.
data:    end of xpre02.

data:    begin of ypre02 occurs 50.
        include structure pre02.
data:    end of ypre02.

*------- Quota Adjustment ---------------------------------------------*
data: begin of gs_quota,
        qunum like eban-qunum,
        qupos like eban-qupos,
        menge like eban-menge,
        bsmng like eban-bsmng,
     end of gs_quota.

*------- fuer Aenderungsbeleg -----------------------------------------*
data: objektklasse  like cdhdr-objectclas value 'BANF',
      objektid      like cdhdr-objectid,
      aendernr      like cdhdr-changenr,
      tablename     like cdpos-tabname,
      change_ind(1) type c             value 'U',
      docu_del(1)   type c             value ' ',
      ergebnis(1)   type c.

* ehemalige FMMEXCOM-Felder
* DATA: BIMUKONT, CATTKZ.

*------- Hilfsfelder Kontierungsblock ---------------------------------*
data: progn like sy-cprog,
      dynnr like tcobl-dynnr,
      selbsc like sy-stepl,
      cobl_pai_msg,
      cobl_full_always,                "für batch-input
      esc_used,
      fcode_used,
      need_full,
      kein_muss,     "kein Mußfeld in Kontierungsfeldauswahl
      cobl_pruefen,
      dien_function.

data: begin of int_coblf occurs 20.
        include structure coblf.
data: end of int_coblf.

*------- Hilfsfelder Revisionsstand -----------------------------------*
data: h_select.                        "F4 mit Auswahl

data: h_first_obl_check value 'X'.     "erstes Mal Buchen durchgeführt

data: begin of tdummy occurs 1,
        x.
data: end of tdummy.

*------- Field-Symbols ------------------------------------------------*
field-symbols: <f1>,
               <f2>.

include fmmexdir.
include fm06lccd.
include fm06bcdt.
include fm06bu02.

* Felder für Anschluß DVS
data: doknr like drad-doknr,
      dokar like drad-dokar,
      doktl like drad-doktl,
      dokvr like drad-dokvr,
      objky like drad-objky,
      dokob like drad-dokob value 'EBAN',
      update_flag.

data: begin of doktab occurs 0.
        include structure drad.
data: end of doktab.
*{   INSERT         SO7K000061                                        2
*   IS-Oil Amendment
include mm06btoi.                                           "S03K002606
*}   INSERT
data: v_strlen type i,
      l_frga(8) type c.
data : l_new_frgzu like eban-frgzu.
data : l_syucomm like sy-ucomm .

*----------------------------------------------------------------------*
* Variable declaration for BDP Clause.
data: begin of wa_eban01                ,
       banfn      type   eban-banfn      ,
       bnfpo      type   eban-bnfpo      ,
       werks      type   eban-werks      ,
       waers      type   eban-waers      ,
       menge      type   eban-menge      ,
       preis      type   eban-preis      ,
       peinh      type   eban-peinh      ,
       badat      type   eban-badat      ,
       zzcpfno    type   eban-zzcpfno    ,
       zzesclevel type   eban-zzesclevel ,
       zzbdp      type  eban-zzbdp      ,
       frgst      type   eban-frgst      ,
       frggr      type   eban-frggr      ,
       lfdat      type   eban-lfdat      ,
       gjahr      type   gjahr           ,
*       prtot      type   j_1iaddval      ,
        prtot      type   scprcurr       ,
       fyear      type   bkpf-gjahr      ,
       loekz      type   eban-loekz      ,
     end of wa_eban01.

data: ist_eban01 like table of wa_eban01 with header line .

data: begin of ist_agr occurs 0,
         agr_name  like agr_users-agr_name,
end of ist_agr.
data: wa_annual_limit like zmm_annual_limit.
data: ist_annual_limit type table of zmm_annual_limit.

data  g_posrole type zmm_annual_limit-posrole..
data  g_rel_code_found.
data: g_rel_canc.
data  g_bsakz.
data  g_bdp_exist.
data: wa_geban_old like  t_geban_old .
data: wa_geban_new like  t_geban_new .
data: g_reset_rel    .
data  ist_sline(80) occurs 0.
data: g_remark type trm080-text .
data: begin of wa_remark,
      banfn  type eban-banfn ,
      bnfpo  type eban-bnfpo ,
      remark(80)             ,
      end of wa_remark.
data: ist_remark like table of wa_remark with header line.
controls: tc305 type tableview using screen '0305'.
data: wa_tc305 like wa_remark.
*----------------------------------------------------------------------*
