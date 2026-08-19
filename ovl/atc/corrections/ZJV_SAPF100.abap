***********************************************************************
* Date        Transport     USERID       Description
* 06/10/2008  <RD1K960036>  SAB_PUNIT    1) Added new include to
*                                           resolved the syntax error.
***********************************************************************
* Foreign currency revaluation of open items AND balances
REPORT sapf100 MESSAGE-ID fr NO STANDARD PAGE HEADING. "#EC CI_USAGE_OK[2270335]

* database selection
TYPE-POOLS: rsds.

TABLES: tcurr, t001a,
        t044a, t044b,
        t001, t033, bsbw,
        rfdt,
        kna1,  knb1,
        lfa1,   lfb1,
        ska1,   skat, skb1,  ekko,
        skc1c,                         "used for RFSBEW00
        *skc1c,                                             "#EC NEEDED
        bkpf, bseg, bsid, bsis, bsik,bsed, bsec,
        x001, t030h, t003, t030b,  t009,t074,
*       t030hb, t030u, (no called with FB
        bhdgd, fimsg,
        rfsdo, sscrfields,rfpdo3,
        zjv_fcurr_val.

* posting table
DATA:
  BEGIN OF buchung OCCURS 10,       "Tabelle der gebuchten Betraege
    hwtyp(1),
    bukrs    LIKE bkpf-bukrs,
    hkont    LIKE bseg-hkont,
    budat    LIKE bkpf-budat,
    belnr    LIKE bkpf-belnr,
    post(6)  TYPE p,         "Zaehler / Schl. fuer Belege
    buzei    LIKE bseg-buzei,
    waers    LIKE bkpf-waers,
    dmbtr    LIKE bseg-dmbtr,
    hwaer    LIKE tcurd-hwaer,
    bktxt    LIKE bkpf-bktxt,
    bschl    LIKE bseg-bschl,
    konto    LIKE bseg-hkont,

    msgno    LIKE fimsg-msgno,
    msgid    LIKE fimsg-msgid,
    monat    LIKE bkpf-monat.
*       INCLUDE STRUCTURE RFSBEW_INCL.
DATA:  vbund      LIKE bseg-vbund,
       gsber      LIKE bseg-gsber,
       sgtxt      LIKE bseg-sgtxt,
       faedt      LIKE bsega-netdt,
       bdiff_rem  LIKE bseg-dmbe2,     "additional remeasurement   y
       hwaer_rem  LIKE x001-hwae2,
       dmbe2_t033 LIKE bseg-dmbe2,  "additional postings T033
       dmbe3_t033 LIKE bseg-dmbe3,
       dmbe1_t033 LIKE bseg-dmbe2,
       fimsg      LIKE fimsg,
       END OF buchung.

DATA: BEGIN OF tdd07v OCCURS 20.
        INCLUDE STRUCTURE dd07v.
DATA: END OF tdd07v.

DATA  akonts LIKE bseg-hkont.          "rec.account from master record
INCLUDE fiuums40.                      "Umsetzung 4.0
* Tabelle fuer das Buchen
* contains all necessary data for posting the reval. differences
DATA:
  BEGIN OF bu_waertab  OCCURS 50,   "Buchen der Bewertung
    bukrs     LIKE bseg-bukrs,
    curtp     LIKE t001a-curtp,
    hwtyp(1),                                           " 1 2 3
    storno(1),                     "      Flag für Stornbuchung
    x_no_op,                       "      bei Saldenbewertung
    hkont     LIKE bseg-hkont,
    ta_waers  LIKE bkpf-waers,
    vbund     LIKE bseg-vbund,
    gsber     LIKE bseg-gsber.
*hier kommt der Variable Teil
*       INCLUDE STRUCTURE RFSBEW_INCL.
DATA:
  aflag(1),                      "Betrag ist Aufwand
  dmshb(12)     TYPE p,
  hwaer         LIKE tcurd-hwaer,
*
  bdiff_rem(12) TYPE p,          "remeasured value
  hwaer_rem     LIKE tcurd-hwaer,  "remeasured
*
  belnr         LIKE bseg-belnr,                              "
  buzei         LIKE bseg-buzei,
  END OF bu_waertab.
* already cleared items have to be reversed separatelly
* the old realized difference will be reversed and
* with the augdt
DATA:BEGIN OF bu_waertab_clear OCCURS 50,   "Buchen der Bewertung
       augbl LIKE bseg-augbl,                              "
       augdt LIKE bseg-augdt.
        INCLUDE STRUCTURE bu_waertab.
DATA:   shkzg     LIKE bseg-shkzg,
        new_belnr LIKE bseg-belnr,
        new_budat LIKE bkpf-budat,
        END OF bu_waertab_clear.
DATA: co_pa_flag.
DATA: sbew_special_periods(1).         "is marked to valuatae
"period 12-16 when P_period = 'X'
* batch-input
DATA: BEGIN OF ftpost OCCURS 20.
        INCLUDE STRUCTURE ftpost.
DATA: END OF ftpost.

DATA: post_line     LIKE ftpost-count,     "zaehler buchungszeilen
      post_count(6) TYPE p,            "anzahl gebuchter Belege
      post_now(1).                     "wenn buchen
DATA: bi_filled_flag,                  "data in batch input session
      bi_open_flag.                    "something was posted
* table contains wrong postings
DATA:
     BEGIN OF bu_waertab_err  OCCURS 50.    "Buchen der Bewertung
        INCLUDE STRUCTURE bu_waertab.
DATA:  text(80),
      END OF bu_waertab_err.

* documents cleared sorted by clearing document
* the documents listed in new_belnr have to be reversed in case
* clearing reversal happens
DATA: BEGIN OF f100_bel OCCURS 100,
        bukrs LIKE bkpf-bukrs,
        augbl LIKE bseg-augbl,
        augdt LIKE bseg-augdt,
        belnr LIKE bkpf-belnr,
        budat LIKE bkpf-budat,
      END OF f100_bel.

DATA  curtp_rem LIKE t033-curtp.
DATA: gd_t033_rem LIKE t033.
DATA: hwtyp2, hwtyp3.

* fuer Pruefung Feld und Waehrung eines Waehrungstyps pro bukrs
DATA: BEGIN OF haus,
        field(1),                      "in welchem feld steht die HW
        waers    LIKE tcurd-hwaer,
        curtp    LIKE x001-curt2,
      END OF haus.
DATA: rem_haus  LIKE haus,
      rem2_haus LIKE haus.

* used for testing
DATA:
*  is ebeln and ebelp for GR/IR accounts
*  is BSEG-REBZ
*  is belnr
*  is space for Saldenbewertung
  BEGIN OF bezugsnr,
    nr LIKE bseg-zuonr,         "fuer gruppierung von positione
    ja LIKE bseg-gjahr,
    zz LIKE bseg-buzei,
  END OF bezugsnr,
*
  ok LIKE sy-subrc.

* arranges the relevant document (by account or group )
* to determine the balance per currency to derive the rate
* and to revaluate
* all documents for one account
DATA: BEGIN OF belege OCCURS 300,
        zbukr    LIKE bkpf-bukrs,
        waers    LIKE bkpf-waers,    "evtl erste HW
        bezugsnr LIKE bezugsnr,   "bezug pro
        koart    LIKE bseg-koart,
        konto    LIKE f107v-konto,
        bukrs    LIKE bkpf-bukrs,    "Originalbuchungskreis
        gsber    LIKE bseg-gsber.
*hier kommt der variable teil
*       INCLUDE STRUCTURE RFSBEW_INCL.
DATA:
  gjahr      LIKE bkpf-gjahr,
  belnr      LIKE bseg-belnr,
  buzei      LIKE bseg-buzei,
  shkzg      LIKE bseg-shkzg,
  dmbtr(12)  TYPE p,
  wrbtr(12)  TYPE p,
  gbetr      LIKE bseg-gbetr,    "kurgesicherter Betrag
  kursra(12),               "Kurssicherung aus Beleg
  kursr(12),                "Kurs der Bewertung
  umskz      LIKE bseg-umskz,
  blart      LIKE bkpf-blart,
  budat      LIKE bkpf-budat,
  augbl      LIKE bseg-augbl,
  augdt      LIKE bseg-augdt,
  rdiff(12)  TYPE p,         "realiserte Differenz
  rdiffn(12) TYPE p,        "realiserte Differenz neu
  bdiff(12)  TYPE p,         "alte bewdiff
  bwdiff(12) TYPE p,        "neue bewdiff
  ta_waers   LIKE bkpf-waers,
  hkont      LIKE bseg-hkont,
  vbund      LIKE bseg-vbund,
  wflag(1)   TYPE c,          "reset revaluation
  bdiff_rem  LIKE belege-bwdiff, "remeasured difference


* just for information - not used in logic
  hwtyp(1),
  curtp      LIKE t001a-curtp,
  dmbe2(12)  TYPE p,
  dmbe3(12)  TYPE p,
  bdif2(12)  TYPE p,        "alte bewdiff  2
  bwdif2(12) TYPE p,        "neue bewdiff  2
  bdif3(12)  TYPE p,        "alte bewdiff  3
  bwdif3(12) TYPE p,        "neue bewdiff  3
  rdif2(12)  TYPE p,        "realiserte Differenz
  rdif3(12)  TYPE p,        "realiserte Differenz
  END OF belege.
DATA: bdiff_delta(12) TYPE p.          "delta new /old difference
* used to sort the data
* it is empty when a grouping by konzern or BEWGP is used
DATA: BEGIN OF sort,
        koart     LIKE bseg-koart,
        hkont     LIKE bseg-hkont,
        vbund     LIKE bseg-vbund,
*        konto like belege-konto,
        konto(30), "account + empfg

      END OF sort.
*locks an account during the update
DATA: BEGIN OF lock_tab OCCURS 0,
        bukrs LIKE bkpf-bukrs,
        koart LIKE bseg-koart,
        konto LIKE belege-konto,
      END OF lock_tab.
DATA: locked LIKE sy-subrc.            "lock is ok
* all documents associated to one posting
DATA: BEGIN OF belege_upd OCCURS 300,
        bukrs     LIKE bkpf-bukrs,
        gjahr     LIKE bkpf-gjahr,
        belnr     LIKE bseg-belnr,
        buzei     LIKE bseg-buzei,
        hwtyp     LIKE belege-hwtyp,
        bdiff     LIKE bseg-bdiff,
        rdiff     LIKE bseg-rdiff,
        augbl     LIKE bseg-augbl,
        bdiff_rem LIKE bseg-bdiff,
      END OF belege_upd.
DATA:  t_bsbw LIKE bsbw OCCURS 0 WITH HEADER LINE.
DATA:  t_bsbw_new LIKE bsbw OCCURS 0 WITH HEADER LINE.
*======================*
* declarations for ALV *
*======================*
INCLUDE <line>.
INCLUDE <icon>.
*
DATA: h_variant        LIKE disvariant.
DATA: selkey LIKE sy-tabix.            "counter fuer Konten
* type pool declarations
TYPE-POOLS: slis.
DATA:   gl_bhdgd         TYPE bhdgd.
DATA:   t_fieldcat          TYPE slis_t_fieldcat_alv WITH HEADER LINE,
        t_events            TYPE slis_t_event WITH HEADER LINE,
        t_event_exit        TYPE slis_t_event_exit WITH HEADER LINE,
        t_slis_sort         TYPE slis_t_sortinfo_alv,
        t_slis_layout_alv   TYPE slis_layout_alv,
        t_slis_print_alv    TYPE slis_print_alv,
        gt_list_top_of_page TYPE slis_t_listheader,
        h_tabname_header    TYPE slis_tabname,
        h_tabname_item      TYPE slis_tabname,

        h_repid             LIKE sy-repid,
        h_user_command      TYPE slis_formname,
        h_set_pf_status     TYPE slis_formname.
* zweite tabelle (Druck Buchungen)
DATA: caller(40).
DATA:   t2_fieldcat       TYPE slis_t_fieldcat_alv WITH HEADER LINE.
* dritte tabelle Druck der Meldungen
DATA:   t3_fieldcat       TYPE slis_t_fieldcat_alv WITH HEADER LINE.

DATA: BEGIN OF t_fimsg OCCURS 100.
        INCLUDE STRUCTURE fimsg.
DATA: END OF t_fimsg.

*===========*
* Main list *
*===========*
DATA: BEGIN OF list_item OCCURS 100,
        zbukr      LIKE bwpos-zbukr,
        bewgp      LIKE bwpos-gruppe,
        koart      LIKE bseg-koart,
        hkont      LIKE bseg-hkont,
        altkt      LIKE skb1-altkt,
        konto      LIKE f107v-konto,
* hier kommen die Belege
        waers      LIKE bkpf-waers,
        bezugsnr   LIKE bezugsnr,          "bezug pro
        gsber      LIKE bseg-gsber,
        gjahr      LIKE bkpf-gjahr,
        belnr      LIKE bseg-belnr,
        buzei      LIKE bseg-buzei,
        shkzg      LIKE bseg-shkzg,
        wrbtr(10)  TYPE p,
        dmbtr(10)  TYPE p,
        bwwrt(10)  TYPE p,                "bewerteter Betrag
        gbetr      LIKE bseg-gbetr,           "kurgesicherter Betrag
        kursra     LIKE bseg-kursr,
        kursr      LIKE resreval-kursu,       "verwendeter Kurs like kursu
        umskz      LIKE bseg-umskz,
        kursf      LIKE bkpf-kursf,           "Anschaffungskurs
*      kursf like revalc-fw_ankurs,
        blart      LIKE bkpf-blart,
        budat      LIKE bkpf-budat,
        augbl      LIKE bseg-augbl,
        bdiff      LIKE bwpos-bwshb_old,      "old diff
        bwdiff     LIKE bwpos-bwshb_net,     "neue bewdiff
        bubetr(10) TYPE p,               "differenz die gebucht wird
*      bubetr(10) like bseg-dmbtr,          "differenz die gebucht wird
        rdiff      LIKE bseg-rdiff,          "realiserte Differenz
        rdiffn     LIKE bseg-rdiff,          "realiserte Differenz
        bukrs      LIKE bkpf-bukrs,           "Originalbuchungskreis
        vbund      LIKE bseg-vbund,
        txt50      LIKE skat-txt50.           "Sachkontenlangtext
DATA: bdiff_rem LIKE bwpos-bwshb_net.  "remeasured difference
DATA: hwaer_rem LIKE x001-hwae2.
* variabler teil
*       INCLUDE STRUCTURE RFSBEW_INCL.
DATA:
  hwaer LIKE tcurd-hwaer,
*     selkey      like sy-tabix,
  END OF list_item.
*
*=========*
* end ALV *
*=========*

DATA:
  cnt_belg TYPE i,               "belegzaehler gesamt

  maxup(8) TYPE n VALUE 1000,      "allow 1000 updates per posting
  anzup(8) TYPE n.


*information about active currency types and
DATA: BEGIN OF bk_methode OCCURS 20,   "Methoden pro bukrs
        bukrs      LIKE bkpf-bukrs,
        meth1      LIKE t044a-bwmet,        "Bewertungsmethode
        meth2      LIKE t044a-bwmet,
        meth3      LIKE t044a-bwmet,
        hwae1      LIKE tcurd-hwaer,        "Hauswaehrung
        hwae2      LIKE t001-waers,
        hwae3      LIKE t001-waers,
        curt1      LIKE x001-curt2,         "waehrungstyp 10,30..60
        curt2      LIKE x001-curt2,
        curt3      LIKE x001-curt2,
        curs2      LIKE x001-basw2,
        curs3      LIKE x001-basw2,
        hwaer_rem  LIKE t001-waers,
        typ_rem(1),
      END OF bk_methode.

DATA: dk_konzs LIKE kna1-konzs.        "Summenfeld


* SKV accounts should not be valuated
DATA: BEGIN OF t030skv OCCURS 300,
        hkont LIKE bsis-hkont,
      END OF t030skv.

* these are the GR/IR accounts
DATA: BEGIN OF t_grir OCCURS 10,
        ktopl LIKE t001-ktopl,
        hkont LIKE bseg-hkont,
      END OF t_grir,
      grir_flag.                       "is a gr/ir account
DATA: flag_onli.
CONSTANTS:
  xon TYPE xfeld        VALUE 'X',      "Flag eingeschaltet
  off TYPE xfeld        VALUE ' '.      "Flag ausgeschaltet
*   no_entry  TYPE cfeld        VALUE '!'.      "Kein Eintrag
* daten fuer bewertungsbereiche
CONSTANTS:
  methode LIKE bsbw-methd VALUE '1'.   "muss 1 sein = FW Bewertung

RANGES: curr_sel FOR bkpf-waers.
* wird später fuer RFSBEW00_incl benoetigt, damit nicht von-bis Wert
TYPE-POOLS: sscr.
* Definition des Objekts, das an den  RESTRICTION übergeben
DATA restrict TYPE sscr_restrict.
* Hilfsobjekte zum Füllen von RESTRICT
DATA: opt_list TYPE sscr_opt_list,
      ass      TYPE sscr_ass.

* free selections.
DATA: fs_f1_icon LIKE smp_dyntxt.      "f1 taste
DATA: lfa1_clauses        TYPE rsds_where,  lfa1_clauses_filled.
DATA: lfb1_clauses        TYPE rsds_where,  lfb1_clauses_filled.
DATA: bsik_clauses        TYPE rsds_where,  bsik_clauses_filled.

DATA: kna1_clauses        TYPE rsds_where,  kna1_clauses_filled.
DATA: knb1_clauses        TYPE rsds_where,  knb1_clauses_filled.
DATA: bsid_clauses        TYPE rsds_where,  bsid_clauses_filled.

DATA: ska1_clauses        TYPE rsds_where,  ska1_clauses_filled.
DATA: skb1_clauses        TYPE rsds_where,  skb1_clauses_filled.
DATA: gt_callback LIKE ldbcb    OCCURS 0 WITH HEADER LINE,
      seltab      TYPE rsparams OCCURS 0 WITH HEADER LINE.
DATA: bsis_clauses        TYPE rsds_where,  bsis_clauses_filled.

DATA: bseg_clauses        TYPE rsds_where,  bseg_clauses_filled.
DATA: bkpf_clauses        TYPE rsds_where,  bkpf_clauses_filled.
*
DATA: sdf_expressions TYPE rsds_texpr. "for SDF
DATA: sdf_expressions_line TYPE rsds_expr. "for SDF

*==================================*
* declarations for application log *
*==================================*
* global data
DATA: g_s_log      TYPE bal_s_log,
      g_log_handle TYPE balloghndl,
      g_dummy      TYPE c,
      g_e_msg      TYPE  boolean.

* priority clas
CONSTANTS:
  probclass_very_high TYPE bal_s_msg-probclass VALUE '1',
  probclass_high      TYPE bal_s_msg-probclass VALUE '2',
  probclass_medium    TYPE bal_s_msg-probclass VALUE '3',
  probclass_low       TYPE bal_s_msg-probclass VALUE '4',
  probclass_none      TYPE bal_s_msg-probclass VALUE ' '.
* message types
CONSTANTS:
  msgty_x    TYPE sy-msgty            VALUE 'X',
  msgty_a    TYPE sy-msgty            VALUE 'A',
  msgty_e    TYPE sy-msgty            VALUE 'E',
  msgty_w    TYPE sy-msgty            VALUE 'W',
  msgty_i    TYPE sy-msgty            VALUE 'I',
  msgty_s    TYPE sy-msgty            VALUE 'S',
  msgty_none TYPE sy-msgty            VALUE ' '.
DATA: t_spono LIKE schedman_spool .
DATA: gt_spono LIKE t_spono OCCURS 0.

INCLUDE rkasmawf.             "<     necessary for Workflow
INCLUDE schedman_events.          "Events for Wokflow

DEFINE check_currency.
* check foreign currency
  if p_curtp1 = '10'.
    check &1 ne t001-waers.
  elseif p_curtp1 = bk_methode-curt2.
    if bk_methode-curs2 = '1'.
      check &1 ne bk_methode-hwae2.
    endif.
  elseif p_curtp1 = bk_methode-curt3.
    if bk_methode-curs3 = '1'.
      check &1 ne bk_methode-hwae3.
    endif.
  elseif p_curtp1 <> bk_methode-curt3.
    check 0 = 1.                       "keine parallele Währung
  endif.
END-OF-DEFINITION.
*===================*
* selection-screens *
*===================*
SELECTION-SCREEN FUNCTION KEY 1.       "free selectons

SELECTION-SCREEN BEGIN OF BLOCK 001
                 WITH FRAME.           "TITLE TEXT-001.
SELECT-OPTIONS:
            bukrs      FOR bkpf-bukrs.
PARAMETERS: stichtag LIKE rfpdo-sbewstag,
            bwmet1   LIKE rfpdo1-f100meth.
* currencytyp and reval-area
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-069.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS: p_curtp1 LIKE rfpdo3-sbewcurtp  DEFAULT '10'.

SELECTION-SCREEN COMMENT 42(25) text-062.
SELECTION-SCREEN POSITION 70.
PARAMETERS:
           p_bwber       LIKE rfpdo3-allgbwbe.
SELECTION-SCREEN END OF LINE.
*
SELECTION-SCREEN END OF BLOCK 001.
*Batch input --------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1020 AS SUBSCREEN.
PARAMETERS: post_upd LIKE rfpdo-f100pupd MODIF ID sld.
PARAMETERS: no_post(1) NO-DISPLAY.         "used be JVA
PARAMETERS: par_bi LIKE rfpdo1-f100buch   DEFAULT ' '.
PARAMETERS: par_bnam LIKE rfpdo-allgbina,
*           par_sgtx  like bseg-sgtxt,
            p_bldat  LIKE rfpdo-allgedat,
            p_bbudat LIKE rfpdo-allgbdat,    "Buchungsdatum
            p_bbupem LIKE rfpdo-allgbupe,    "Buper-Monat
            st_budat LIKE rfpdo-allgsdat,    "Buchungsdatum storno
            p_sbupem LIKE rfpdo-allgsbup.    "Buper-Monat   storno
*Do not use t030h von non OI accounts
PARAMETERS: no_t030h(1) NO-DISPLAY  DEFAULT ' '.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_storno   LIKE rfpdo3-allgstor DEFAULT ' '.    "
*----flex hauptbuch
SELECT-OPTIONS:
             incl_fld  FOR rfpdo3-sbewfnam         "Feldnamen
                       NO INTERVALS NO-DISPLAY.    "not supported yet

**** Added by SAB_KBHAT on 13.01.2006

SELECTION-SCREEN SKIP 2.

SELECT-OPTIONS: s_vname FOR bseg-vname NO-EXTENSION OBLIGATORY,
                s_recid FOR bseg-recid NO-EXTENSION OBLIGATORY,
                s_egrup FOR bseg-egrup NO-EXTENSION OBLIGATORY.

**** End of addition by SAB_KBHAT

SELECTION-SCREEN END OF SCREEN 1020.
*---Output information  --------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1060 AS SUBSCREEN.
*sELECTION-SCREEN COMMENT 1(40) text-069.
SELECTION-SCREEN: BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-029.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS p_lvar   LIKE h_variant-variant DEFAULT space.
SELECTION-SCREEN POSITION POS_HIGH.
SELECTION-SCREEN: PUSHBUTTON (15) text-028 USER-COMMAND con1.
SELECTION-SCREEN END OF LINE.
PARAMETERS:
  title  LIKE rfpdo-allgline,
  xaltkt LIKE rfpdo1-allgaltk.   "alternative ktonummer
PARAMETERS:          filename LIKE rfpdo1-f100xfil.
PARAMETERS:          p_zbukrs LIKE rfpdo3-allgzbuk.
* Zusammenfassung und Buchung in den Zielbukrs (auch Customizing)
SELECTION-SCREEN END OF SCREEN 1060.
*----FASB 52---------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1011 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK 6 WITH FRAME TITLE text-055.

PARAMETER:           p_remon
*                              as checkbox,
                               LIKE rfpdo3-f100xrem,
                     p_remsct LIKE tcurr-kurst DEFAULT 'M',
                     p_bwber2 LIKE rfpdo3-sbewrembwber.
SELECTION-SCREEN END OF BLOCK 6.
*election-screen skip 1.
SELECTION-SCREEN BEGIN OF BLOCK 7 WITH FRAME TITLE text-060.
*
PARAMETER:           p_transl LIKE rfpdo3-sbewtrans.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) text-063 FOR FIELD fromctp.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS:fromctp LIKE  rfpdo3-sbewcurtp.
SELECTION-SCREEN COMMENT 42(25) text-062 FOR FIELD frombwb.
SELECTION-SCREEN POSITION 58.
SELECTION-SCREEN POSITION 70.
PARAMETERS:  frombwb LIKE rfpdo3-allgbwbe.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK 7.
SELECTION-SCREEN END OF SCREEN 1011.

*--------Selections for AP and AR---------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1080 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK ap1.
PARAMETERS:      x_ap     LIKE rfpdo-f010kred  DEFAULT ' '.
SELECT-OPTIONS:  kkonto   FOR lfb1-lifnr  MATCHCODE OBJECT kred.
PARAMETERS:      x_ar     LIKE rfpdo-f010debi DEFAULT ' '.
SELECT-OPTIONS:  dkonto   FOR knb1-kunnr  MATCHCODE OBJECT debi.
*
SELECT-OPTIONS:  akonto   FOR bseg-hkont  MATCHCODE OBJECT sako.
SELECTION-SCREEN END OF BLOCK ap1.
SELECTION-SCREEN END OF SCREEN 1080.
*-select options for GL Accounts------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1050 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK gl1.
PARAMETERS:      x_gl     LIKE rfpdo-f123sakn DEFAULT ' '.
PARAMETER:       x_salbew AS    CHECKBOX.
SELECT-OPTIONS:  skonto   FOR bseg-hkont  MATCHCODE OBJECT sako.
*
PARAMETERS:      pa_weren  RADIOBUTTON GROUP 0001. "no were
PARAMETERS:      pa_were  LIKE rfpdo1-f100were
                             RADIOBUTTON GROUP 0001. "use po data
PARAMETERS:      pa_weref RADIOBUTTON GROUP 0001. "use FI data
*
SELECT-OPTIONS:  s_gracc  FOR rfpdo3-f100graccts. "WE/RE accts

PARAMETERS:     p_plcacc LIKE rfpdo3-sbewplc,
                p_period LIKE rfpdo3-sbewbalance.
*select-options      s_no_acc for rfsdo-sbewnoac.
SELECT-OPTIONS:     s_kdfsl    FOR skb1-kdfsl.
SELECT-OPTIONS:     s_gsber    FOR skc1c-gsber.

SELECTION-SCREEN END OF BLOCK gl1.

SELECTION-SCREEN END OF SCREEN 1050.
*---------------------------------------------------------------------

* gl and ap and ar
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
SELECTION-SCREEN INCLUDE BLOCKS gl1.
*election-screen skip 1.
SELECTION-SCREEN INCLUDE BLOCKS ap1.
SELECT-OPTIONS:  belnr    FOR bkpf-belnr,
                 waehrung FOR bkpf-waers.
SELECTION-SCREEN END OF SCREEN 1100.
PARAMETER:

           fs_dyns TYPE rsds_type NO-DISPLAY,
           fs_num LIKE sy-tfill   NO-DISPLAY.


*---------------------------------------------------------------------
*-----------------------------------------------------------------------
*PARAMETERS:
*                 P_NOSTOR RADIOBUTTON GROUP 0001,
*                 P_RESTOR RADIOBUTTON GROUP 0001,
*                 P_STORE   RADIOBUTTON GROUP 0001,
*                 STOR_NAM LIKE RFPDO3-ALLGALVNAM.
DATA:             p_nostor,
                  p_restor,
                  p_store,
                  stor_nam.



*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF TABBED BLOCK tabbl FOR 16 LINES.

SELECTION-SCREEN TAB (16) tabs1020 USER-COMMAND ucom1020
                     DEFAULT SCREEN 1020.
SELECTION-SCREEN TAB (15) tabs1100 USER-COMMAND ucom1100
                     DEFAULT SCREEN 1100.
SELECTION-SCREEN TAB (15) tabs1060 USER-COMMAND ucom1060
                     DEFAULT SCREEN 1060.
SELECTION-SCREEN TAB (15) tabs1011 USER-COMMAND ucom1011
                     DEFAULT SCREEN 1011.


SELECTION-SCREEN END OF BLOCK tabbl.
************************************************************************


FIELD-GROUPS: header,
              daten.                   "Einzelbelege

INSERT belege-zbukr                    "evtl zielbukr
         skb1-xopvw                    "to separate between nop and ops
         dk_konzs                      "summenbegriff
         sort-koart
         sort-hkont
         sort-vbund
         sort-konto
       belege-waers
                    INTO header.
INSERT:  belege
                INTO daten.

FIELD-SYMBOLS: <fwsaldo>, <hwsaldo>, <hwsaldo1>.

INITIALIZATION.

  tabs1060 = 'Ausgabe'(001).
  tabs1020 = 'Buchungen'(003).
  tabs1011 = 'FASB52'(012).
  tabs1100 = 'Selektionen'(014).




  opt_list-name = xon.
  opt_list-options-eq = xon.
  APPEND opt_list TO restrict-opt_list_tab.
  ass-kind = 'S'.
  ass-name = 'INCL_FLD'.
  ass-sg_main = 'I'.
  ass-sg_addy = ' '.
  ass-op_main = xon.
  ass-op_addy = xon.
  APPEND ass TO restrict-ass_tab.
  CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
    EXPORTING
      restriction = restrict
    EXCEPTIONS
      OTHERS      = 1.

*--alv used for F4
  h_repid = sy-repid.
  h_variant-report     = h_repid.
  h_variant-log_group  = '0001'.

* Setzen Default-Sichtag
  stichtag = sy-datlo.
  stichtag+6(2) = '01'.
  stichtag = stichtag - 1.

* icon freie selection
  PERFORM fs_set_sscrtexts_dynsel CHANGING fs_f1_icon.
  sscrfields-functxt_01 = fs_f1_icon.
* psb = fs_F1_icon-ICON_TEXT .


AT SELECTION-SCREEN OUTPUT.
  IF sy-dynnr = '1100' OR sy-dynnr = '1000'.
    PERFORM fs_set_sscrtexts_dynsel CHANGING fs_f1_icon.
*    PSB =  fs_F1_icon-icon_text.
    sscrfields-functxt_01 = fs_f1_icon.
  ENDIF.
*
* PERFORM: FLEX_FELDER_ERL_AUFBAUEN USING 'RFSBEW_INCL'.
**** Added by SAB_KBHAT on 13.01.2006

  PERFORM fill_custom_fields.

**** End of Addition by SAB_KBHAT

AT SELECTION-SCREEN ON bukrs.
  IF sy-dynnr = '1000'.
    CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'
      EXPORTING
        xdatabase = 'B'
      TABLES
        xbukreis  = bukrs.
  ENDIF.

AT SELECTION-SCREEN ON p_zbukrs.
  IF p_zbukrs <> space AND sy-dynnr = '1060'.
    SELECT SINGLE * FROM t001 WHERE bukrs = p_zbukrs.
    IF sy-subrc <> 0.
      MESSAGE e058(00) WITH  p_zbukrs space space space.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON stichtag.
  IF stichtag IS INITIAL.
    MESSAGE e361.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_lvar.
  h_variant-variant = p_lvar.
  PERFORM f4_for_s_lvar   USING h_variant.
  p_lvar = h_variant-variant.
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR stor_nam.
** PERFORM f4_for_stor_nam   USING stor_nam.

AT SELECTION-SCREEN ON bwmet1.
  IF t044a-bwmet NE bwmet1 AND bwmet1 <> space.
    SELECT SINGLE * FROM t044a WHERE bwmet =  bwmet1.
    IF sy-subrc NE 0.
      MESSAGE e362.
    ENDIF.
  ENDIF.
  IF bwmet1 = space
    AND ( sscrfields-ucomm = 'ONLI' OR sscrfields-ucomm = 'PRIN' ).
    CLEAR sscrfields-ucomm.
    MESSAGE e055(00).
  ENDIF.



AT SELECTION-SCREEN ON p_bwber.
  IF p_bwber2 = p_bwber AND p_bwber NE space.
    MESSAGE e012.
  ENDIF.

AT SELECTION-SCREEN ON p_bwber2.
  IF sy-dynnr = '1011'.
    IF NOT p_bwber2 IS INITIAL.
      SELECT SINGLE * FROM t033 WHERE bwber = p_bwber2.
      IF sy-subrc NE 0.
        MESSAGE e058(00) WITH p_bwber2 space space space.
      ENDIF.
* remeasurement not in lc (because posting would not work)
      IF t033-curtp = p_curtp1 AND p_remon <> space.        "H335756
        MESSAGE e011.
      ENDIF.
      PERFORM check_curtp USING t033-curtp.
      IF p_bwber2 = p_bwber.
        MESSAGE e012.
      ENDIF.
    ENDIF.
  ENDIF.
*AT SELECTION-SCREEN ON INCL_FLD.
*  PERFORM CHECK_INCL_FLD.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR INCL_FLD-LOW.
*  PERFORM F4_FOR_INCL_FLD USING INCL_FLD-LOW.



*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
* Auf die User-Commands reagieren
  CASE sscrfields-ucomm.
*   WHEN 'UCOMM1'.                     "Tabreiter wechseln
*     tabstrip-activetab = 'UCOMM1'.
*     tabstrip-dynnr = 1.
    WHEN 'UCOM1100'.
*  change screen for A/P
*     if sy-tcode = 'F.05'.
*     if ( X_AP <> space or X_ar <> space )
*       and ( X_GL = space and x_salbew = space ).
*       tabbl-dynnr   = 1100.
*     endif.

    WHEN 'SEL1'.
      IF sy-dynnr = '1100'.            "Selektionen
        CLEAR: sy-ucomm, sscrfields-ucomm.
        PERFORM free_selections.
        CHECK 0 = 1.
      ENDIF.
    WHEN 'FC01'.                       "function key
      IF sy-dynnr = '1000'.                                 "
        CLEAR: sy-ucomm, sscrfields-ucomm.
        PERFORM free_selections.
        CHECK 0 = 1.
      ENDIF.
    WHEN 'CON1'.                       "Ausgabeliste konfigurieren
*     if sy-dynnr = '1000'.
      IF sy-dynnr = '1000'.
        PERFORM list_config_list USING 'SAPF100'
                                       'LISTE'.  "which form
      ENDIF.
  ENDCASE.
  IF sy-dynnr = '1000'.
    IF p_bwber NE space.
      SELECT SINGLE * FROM t033 WHERE bwber = p_bwber.
      IF sy-subrc NE 0.
        MESSAGE e058(00) WITH p_bwber space space space.
      ELSE.
        p_curtp1 = t033-curtp.
      ENDIF.
    ENDIF.
    IF p_curtp1 = space. MESSAGE e055(00). ENDIF.
    PERFORM check_curtp USING p_curtp1.
  ENDIF.

*     for update you need a valuation area
  IF post_upd <> space AND p_remon <> space AND p_bwber = space.
    MESSAGE  e014.
*        'Bei bilanzwirksamer Bewertung und'
*        'und Bewertungsdifferenz umrechnen'
*        'muss ein Bewertungsbereich verwendet werden'.
  ENDIF.

*------1011
  IF sy-dynnr = '1011'.
    IF NOT frombwb IS INITIAL.
      SELECT SINGLE * FROM t033 WHERE bwber = frombwb.
      IF sy-subrc NE 0.
        MESSAGE e058(00) WITH frombwb space space space.
      ENDIF.
      fromctp = t033-curtp.

      IF frombwb = p_bwber.
        MESSAGE e012.
      ENDIF.
    ENDIF.
    PERFORM check_curtp USING fromctp.


    IF p_remon <> space AND p_transl <> space.
      MESSAGE e329.
    ENDIF.
    IF p_transl <> space.
      IF fromctp IS INITIAL.
        MESSAGE e055(00).
      ENDIF.
      IF fromctp NE '10'.
        MESSAGE e013.
      ENDIF.
    ENDIF.
    IF p_remon <> space.
      curtp_rem = space.
      SELECT SINGLE curtp
                      FROM t033 INTO curtp_rem
                                WHERE bwber = p_bwber2.
      IF curtp_rem = space.
        MESSAGE e055(00).
      ENDIF.
    ENDIF.
  ENDIF.
*---------------
* perform check_bwmetxx using bwmet1.
* if p_curtp1 = space. message e055(00). endif.

* belegupdate geht nur mit batchinput
  IF post_upd NE space.
    IF par_bi IS INITIAL.
      par_bi = 'X'.
      MESSAGE i584.
    ENDIF.
    IF par_bnam = space.
      par_bnam = sy-repid.
    ENDIF.
  ENDIF.
**** Added by SAB_KBHAT on 13.01.2006

  PERFORM fill_custom_fields.

**** End of Addition by SAB_KBHAT
*--check only if user enters start
  CHECK sscrfields-ucomm = 'ONLI' OR sscrfields-ucomm = 'PRIN'.
* if x_salbew = 'X'.
*   perform s_build_noacc.
* endif.


  PERFORM check_before_start.
  CLOSE DATASET filename.
  IF sscrfields-ucomm = 'ONLI'.
    flag_onli = 'X'.
  ELSE.
    flag_onli = ' '.
  ENDIF.
************************************************************************
START-OF-SELECTION.

****  Added by SAB_KBHAT on 13.01.2006
  PERFORM buffer_selection.
****  End of addition by SAB_KBHAT
  CLEAR gt_callback.
** for reval areas store the values ALWAYS
  IF p_bwber <> space AND par_bi <> space.
    post_upd = 'X'.
  ENDIF.
**
* display old values
*  IF STOR_NAM NE SPACE AND P_RESTOR NE SPACE.
*    PERFORM RESTORE.
*    EXIT.
*  ENDIF.

  PERFORM log_almsg_init.
  PERFORM schedman_start_stop USING 'START'.

* Batch-Input-Vorarbeiten
  IF p_bbudat IS INITIAL.
    p_bbudat = stichtag.
  ENDIF.

  IF st_budat IS INITIAL.
    st_budat = p_bbudat + 1.
  ENDIF.

  IF p_bldat IS INITIAL.
    p_bldat = p_bbudat.
  ENDIF.

  PERFORM read_t044a USING  bwmet1.

* estimate gr_ir accounts
  PERFORM gr_ir_build_tab.
  CLEAR t001.

  PERFORM check_before_start.
* lock company code
  IF post_upd <> space AND p_bwber = space.
    PERFORM enqueue USING 'ON'.
    PERFORM set_t042x.
  ENDIF.
  COMMIT WORK.

* Tabelle UMS40 wegen Umsetzung nach 4.0 einlesen
  IMPORT ums40 FROM DATABASE rfdt(fu) ID 'UMS40'.

  CLEAR haus.

  IF p_bwber NE space.
    SELECT SINGLE * FROM t033 WHERE bwber = p_bwber.
    IF sy-subrc NE 0.
      MESSAGE e058(00) WITH p_bwber space space space.
    ENDIF.
*   set variables
    p_curtp1 = t033-curtp.
  ENDIF.

  IF NOT p_bwber2 IS INITIAL.
    SELECT SINGLE *
                    FROM t033 INTO gd_t033_rem
                              WHERE bwber = p_bwber2.
    curtp_rem = gd_t033_rem-curtp.
  ENDIF.
  IF NOT frombwb IS INITIAL.
    SELECT SINGLE curtp
                    FROM t033 INTO fromctp
                              WHERE bwber = frombwb.
  ENDIF.

  PERFORM free_selections_build.

* read balances of g/l accounts
  IF x_salbew NE space.
    PERFORM sdf_sbew00.
  ENDIF.

* A/R open items
  IF  x_ar  <> space.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      PERFORM build_bk_methode USING t001-bukrs.
* setup waehrung select-option
      PERFORM fill_curr_sel USING bk_methode-bukrs.

      PERFORM select_bsid USING 'BSID'.
      PERFORM select_bsid USING 'BSAD'.

    ENDSELECT.
  ENDIF.

* A/P open items
  IF  x_ap  <> space.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      PERFORM build_bk_methode USING t001-bukrs.
* setup currency select-option
      PERFORM fill_curr_sel USING bk_methode-bukrs.

      PERFORM select_bsik USING 'BSIK'.
      PERFORM select_bsik USING 'BSAK'.

    ENDSELECT.
  ENDIF.

* G/L Open items
  IF  x_gl  <> space.
    CLEAR: belege, bseg.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      PERFORM t030skv_set.
      PERFORM build_bk_methode USING t001-bukrs.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT * FROM skb1
                         WHERE bukrs = t001-bukrs           "H204475
                         AND   saknr IN skonto
                         AND   xopvw = 'X'
                         AND   kdfsl IN s_kdfsl
                          AND   (skb1_clauses-where_tab).  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
        IF ska1_clauses_filled = 'X'.
          SELECT SINGLE saknr  FROM ska1 INTO ska1-saknr
                               WHERE  saknr = skb1-saknr
                               AND   (ska1_clauses-where_tab).
          CHECK sy-subrc = 0.
        ENDIF.
*     Account may not be SKV
        READ TABLE t030skv WITH KEY
                hkont = skb1-saknr BINARY SEARCH.
        IF sy-subrc = 0.
          CHECK 0 = 1.                 "no skv account
        ENDIF.
*       determine whether gr/ir accounts are selected
        PERFORM gr_ir_check CHANGING skb1-xopvw
                                     grir_flag.
        CHECK   skb1-xopvw =  'X'.
*       commented out because some gl accounts have no
*       extra correction account
*       if s_no_acc-low ne space.
*          check: not ( skb1-saknr in s_no_acc ).
*       endif.

        PERFORM fill_curr_sel USING bk_methode-bukrs.

        dk_konzs = space.
        IF t044a-gl_grup NE space.
          PERFORM get_dkonzs_gl CHANGING dk_konzs.
        ENDIF.
        PERFORM select_bsis USING 'BSIS'.
        PERFORM select_bsis USING 'BSAS'.
      ENDSELECT.                       "skb1
    ENDSELECT.
  ENDIF.

END-OF-SELECTION.

* revaluate the extracted items and balances

  CLEAR bseg.
  SORT.
  LOOP.

    AT NEW belege-zbukr.
      SELECT SINGLE * FROM t001 WHERE bukrs = belege-zbukr.
      ska1-ktopl = t001-ktopl.
      PERFORM build_bk_methode USING t001-bukrs.
      IF NOT bk_methode-hwaer_rem IS INITIAL.
        IF NOT gd_t033_rem-curtp2 IS INITIAL.
          PERFORM derive_hauswaers
                      USING
                         t001-bukrs
                         gd_t033_rem-curtp
                      CHANGING
                         rem_haus.
          PERFORM derive_hauswaers
                      USING
                         t001-bukrs
                         gd_t033_rem-curtp2
                      CHANGING
                         rem2_haus.
          IF rem_haus-waers NE rem2_haus-waers.
            CLEAR gd_t033_rem-curtp2.
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM get_co_pa_flag USING belege-bukrs
                            CHANGING co_pa_flag.
    ENDAT.


    AT NEW sort-hkont.
*     Zuruecksetzen Hauptbuchkonten-Tabellen
      grir_flag = space.
      IF pa_were NE space AND belege-koart = 'S'
        AND  skb1-xopvw = 'X'.
        skb1-saknr = belege-hkont.
        PERFORM gr_ir_check CHANGING skb1-xopvw
                                     grir_flag.
      ENDIF.
    ENDAT.

    AT NEW sort-konto.
      REFRESH: belege, lock_tab.
    ENDAT.

* alle belege eines (kontokorrentkontos) zwischenspeichern
    AT daten.
      APPEND belege.
      IF post_upd <> space AND p_bwber = space.
        MOVE-CORRESPONDING belege TO lock_tab.
        IF lock_tab-koart = 'S' AND belege-belnr NE space.
          lock_tab-konto = belege-hkont.
        ENDIF.
        COLLECT lock_tab.
      ENDIF.
    ENDAT.



    AT END OF sort-konto.

*   Hauwaehrung bewerten
      IF bk_methode-meth1 NE space.
*    Belege bewerten + drucken
        PERFORM belege2 USING '1'.
      ELSEIF bk_methode-meth2 NE space.
* Hauswaehrung 2 .
        PERFORM belege2 USING '2'.
      ELSEIF bk_methode-meth3 NE space.
* Hauswaehrung 3 .
        PERFORM belege2 USING '3'.
      ENDIF.

      IF post_upd <> space AND p_bwber = space.
        LOOP AT lock_tab.
          PERFORM ausgleich_sperren_s USING lock_tab-koart
                                            lock_tab-konto
                                            lock_tab-bukrs
                                     CHANGING locked.
          IF locked <> 0. EXIT. ENDIF.
        ENDLOOP.
      ENDIF.

*     belege = space.
      LOOP AT belege.

        AT NEW waers.
          SUM.
          bdiff_delta = belege-bwdiff - belege-bdiff.
        ENDAT.
        AT NEW bezugsnr.
          SUM.
*     revaluation by document (and references)
          IF t044a-xsalb = space.
            SUM.
            bdiff_delta = belege-bwdiff - belege-bdiff.
          ENDIF.
        ENDAT.


*       for listings
        IF locked = 0.
          PERFORM list_item_fill.

          IF belege-bdiff NE belege-bwdiff.
            PERFORM fill_bu_waertab.   "and record docum for upda

            ADD 1 TO anzup.
          ELSEIF post_upd <> space AND p_bwber <> space
                 AND grir_flag = space.
            MOVE-CORRESPONDING belege TO belege_upd. "#EC CI_FLDEXT_OK[2610650]
            APPEND belege_upd.
          ENDIF.
        ENDIF.
        IF post_upd NE space AND anzup GE maxup.
          PERFORM posting.             "post everything in bu_waert.
        ENDIF.

      ENDLOOP.
      IF post_upd <> space AND p_bwber = space.
        LOOP AT lock_tab.
          PERFORM ausgleich_entsperren_s USING lock_tab-koart
                                            lock_tab-konto
                                            lock_tab-bukrs.
        ENDLOOP.
      ENDIF.

    ENDAT.

    AT END OF sort-hkont.
* force posting to get rid of update documents
      IF post_upd NE space.
        PERFORM posting.               "post everything in bu_waert.
      ENDIF.
    ENDAT.

    AT LAST.
      PERFORM posting.
    ENDAT.
  ENDLOOP.


  PERFORM enqueue USING 'OFF'.

  PERFORM file_close.

  PERFORM posting_document USING 'CLOSE'.

  PERFORM log_posting_errors.
* store data
*  IF P_STORE NE SPACE.
*   CLEAR FIMSG.
*     FIMSG-MSGID = 'FR'.
*     FIMSG-MSGTY = 'I'.
*     FIMSG-MSGNO = '007'.
*     FIMSG-MSGV1 = STOR_NAM.
*     PERFORM LOG_FIMSG USING '01'.
*     CALL FUNCTION 'FI_MESSAGE_GET'
*          TABLES
*               T_FIMSG    = T_FIMSG
*          EXCEPTIONS
*               OTHERS     = 0.
*     PERFORM LIST_STORE USING 'E'.  "export
* ENDIF.
  IF flag_onli <> space.    "nur online - nicht drucken
    PERFORM schedman_start_stop USING 'STOP'.
  ENDIF.

* start output
  PERFORM liste.
  IF flag_onli = space          "nur bei Druck oder Batch
    OR sy-batch = 'X'.
    PERFORM schedman_start_stop USING 'STOP'.
  ENDIF.
* begin of <RD1K960036>
*  include SAPF100_i1.
*  include SAPF100_sbew.
*  include SAPF100_postings.
  INCLUDE zsapf100_i1_new.
  INCLUDE zsapf100_sbew_new.
  INCLUDE zsapf100_postings_new.
* end of <RD1K960036>

************************************************************************
************************************************************************


*&--------------------------------------------------------------------*
*&      FORM EXTRACT                                                  *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM extract.
  IF belege-belnr <> space.
    CHECK:
           belege-wrbtr NE 0.

* select additional fields from bseg
    IF belege-koart <> 'S' OR  fs_num > 0.
      IF bseg_clauses_filled = 'X'.
        SELECT SINGLE rdiff FROM bseg
                      INTO CORRESPONDING FIELDS OF bseg
                                 WHERE bukrs = belege-bukrs
                                 AND belnr   = belege-belnr
                                 AND gjahr   = belege-gjahr
                                 AND buzei   = belege-buzei
                                 AND (bseg_clauses-where_tab).
        CHECK sy-subrc = 0.
      ENDIF.

      SELECT SINGLE rdiff rdif2 rdif3 gbetr kursr
                    bdiff bdif2 bdif3    "to be sure...
                    xhkom
                      FROM bseg
                      INTO CORRESPONDING FIELDS OF bseg
                                 WHERE bukrs = belege-bukrs
                                 AND belnr   = belege-belnr
                                 AND gjahr   = belege-gjahr
                                 AND buzei   = belege-buzei.
      CHECK sy-subrc = 0.
    ENDIF.

*----get hedged value from rebzg---------------------------------------
    IF NOT bseg-rebzg IS INITIAL AND t044a-xsich NE space.

      SELECT SINGLE waers FROM bkpf
                            INTO bseg-pswsl
                            WHERE bukrs = belege-bukrs
                            AND   belnr = bseg-rebzg
                            AND   gjahr = bseg-rebzj.
      IF belege-waers = bseg-pswsl.
        SELECT SINGLE gbetr kursr
                        FROM bseg
                        INTO CORRESPONDING FIELDS OF bseg
                                   WHERE bukrs = belege-bukrs
                                   AND belnr   = bseg-rebzg
                                   AND gjahr   = bseg-rebzj
                                   AND buzei   = bseg-rebzz.
        IF sy-subrc = 0.
          belege-gbetr = bseg-gbetr. belege-kursr = bseg-kursr.
          IF belege-gbetr > belege-wrbtr.  "always positive values
            bseg-gbetr = belege-wrbtr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*----------------------------------------------------------------------
*  bestimmen der bezugsnummer --- used for grouping -------------------
    bezugsnr = space.
*   pruefen ob cpd konto
    IF bseg-xcpdd NE space.
      SELECT SINGLE * FROM bsec WHERE bukrs = belege-bukrs
                                AND   gjahr = belege-gjahr
                                AND   belnr = belege-belnr
                                AND   buzei = belege-buzei.
*     bezugsnr = bsec-empfg.
    ELSE.
      bsec-empfg = space.
    ENDIF.
*   kein cpd konto

*     gibt es keine bezugsnummer wird die belegnummer verwendet
    IF bseg-rebzj =  '0000'.
      bezugsnr-nr = belege-belnr.
      bezugsnr-ja = belege-gjahr.
      bezugsnr-zz = belege-buzei.
    ELSE.
      bezugsnr-nr = bseg-rebzg.
      bezugsnr-ja = bseg-rebzj.
      bezugsnr-zz = bseg-rebzz.
    ENDIF.
* bei werekonten.
    IF grir_flag = 'X' AND bseg-ebeln NE space.
      CONCATENATE bseg-ebeln bseg-ebelp INTO bezugsnr.
*     bezugsnr = bseg-ebeln.
*     bezugsnr-ja = bseg-ebelp.
    ENDIF.
    belege-bezugsnr = bezugsnr.
*----------------------------------------------------------------------

    CLEAR: belege-kursr, belege-kursra.
* use hedging ---------------------------------------------------------

    IF ( t044a-xsich = 'X' AND bseg-ebeln IS INITIAL ).
      belege-kursra = bseg-kursr. belege-gbetr = bseg-gbetr.
      belege-kursr  = bseg-kursr.
    ELSE.
      CLEAR: belege-kursra, belege-gbetr.
    ENDIF.
  ENDIF.  "only for documents
*----------------------------------------------------------------------
* buchungskreis mit Zielbuchungskreis ueberschreiben
  belege-zbukr = belege-bukrs.
  IF p_zbukrs NE space.
    belege-zbukr = p_zbukrs.
  ENDIF.
* Bewertung zurücksetzen
  IF t044a-xreset NE space.
    belege-wflag = '0'.
  ELSE.
    belege-wflag = '1'.
  ENDIF.
  sort-hkont = belege-hkont.
* ----check for changed rec. account ---------------------------------
  IF belege-koart NE 'S'
   AND  bseg-xhkom = space.  "kein willentlich geändertes Hkont

    IF belege-umskz NE space.
      IF t074-umskz NE belege-umskz
         OR t074-hkont NE akonts.
*   Aktuelles Sonderhauptbuchkonto aus Tabelle 074 ermitteln
        SELECT SINGLE * FROM t074 WHERE ktopl = t001-ktopl
                                  AND   koart = belege-koart
                                  AND   umskz = belege-umskz
                                  AND   hkont = akonts.
        IF sy-subrc <> 0. t074-skont = space. ENDIF.
      ENDIF.
      IF t074-skont NE space.
        sort-hkont = t074-skont.       "neues sonderhauptbuchkonto
      ENDIF.
    ELSE.
      sort-hkont = akonts.
    ENDIF.
  ENDIF.                               "kontoart
* --------------------------------------------------------------------

* damit werden keine at Zeitpunkte durchgefuehrt.
  IF dk_konzs NE space AND grir_flag = space.
    sort-koart = space.
    sort-hkont = space.
    sort-vbund = space.
    sort-konto = space.
  ELSE.
    sort-koart = belege-koart.
    sort-vbund = belege-vbund.
    sort-konto = belege-konto.
    IF bseg-xcpdd <> space.
      WRITE bsec-empfg TO sort-konto+10.
    ENDIF.
*   in sort-hkont is the (changed) hkont
  ENDIF.

* get old value Bdiff (set to zero)
*  IF p_bwber NE space.
*    PERFORM bsbw_get.
*  ENDIF.
*
* setup from value (WRBTR) and BDIFF (old difference) -----------------
  belege-ta_waers = belege-waers.
  belege-hwtyp = space.
  IF p_transl = space.
    IF p_bwber NE space.
      belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
      bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.
    ENDIF.
    belege-hwtyp = space.

    IF bk_methode-meth1 NE space.
      belege-hwtyp = '1'.
      belege-rdiff = bseg-rdiff.
    ELSEIF bk_methode-meth2 NE space.
      IF bk_methode-curs2 = '2'.
        belege-waers = bk_methode-hwae1.
        belege-wrbtr = belege-dmbtr + belege-bdiff.
      ENDIF.
      belege-dmbtr = belege-dmbe2.
      belege-bwdiff = belege-bwdif2.
      belege-bdiff = belege-bdif2.
      belege-rdiff = bseg-rdif2.
      belege-hwtyp = '2'.
    ELSEIF bk_methode-meth3 NE space.
      IF bk_methode-curs3 = '2'.
        belege-waers = bk_methode-hwae1.
        belege-wrbtr = belege-dmbtr + belege-bdiff.
      ENDIF.
      belege-dmbtr = belege-dmbe3.
      belege-bwdiff = belege-bwdif3.
      belege-bdiff = belege-bdif3.
      belege-rdiff = bseg-rdif3.
      belege-hwtyp = '3'.
    ENDIF.
  ELSE.
* translation active
* setup from value (WRBTR) and BDIFF (old difference) -----------------
* wrbtr = dmbtr + bdiff
* bdiff (old) is set to zero

    PERFORM bsbw_translation_op.


    IF frombwb <> space.
      t_bsbw-bwshb = 0.
      LOOP AT t_bsbw WHERE curtp = fromctp  AND bwber = frombwb.
        EXIT.
      ENDLOOP.
    ELSE.
      CASE fromctp.
        WHEN bk_methode-curt1. t_bsbw-bwshb = belege-bdiff.
        WHEN bk_methode-curt2. t_bsbw-bwshb = belege-bdif2.
        WHEN bk_methode-curt3. t_bsbw-bwshb = belege-bdif3.
        WHEN OTHERS. t_bsbw-bwshb = 0.
      ENDCASE.
    ENDIF.
* build belege-wrbtr from the local currencie(s)
* this is the revaluated amount
    IF fromctp      = '10'.
      belege-waers = bk_methode-hwae1.
      belege-wrbtr = belege-dmbtr +  t_bsbw-bwshb.
    ELSEIF fromctp   =  bk_methode-curt2.
      belege-waers = bk_methode-hwae2.
      belege-wrbtr = belege-dmbe2 + t_bsbw-bwshb.
    ELSEIF fromctp   =  bk_methode-curt3.
      belege-waers = bk_methode-hwae3.
      belege-wrbtr = belege-dmbe3 + t_bsbw-bwshb.
    ENDIF.
* do not use the old difference
    belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
    bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.
* dmbtr is the to value -----------------
    IF bk_methode-meth1 NE space.
      belege-hwtyp = '1'.
    ELSEIF bk_methode-meth2 NE space.
      belege-dmbtr = belege-dmbe2.
      belege-hwtyp = '2'.
    ELSEIF bk_methode-meth3 NE space.
      belege-dmbtr = belege-dmbe3.
      belege-hwtyp = '3'.
    ENDIF.
* get remeasurement value and adds it to belege-dmbtr.
    LOOP AT t_bsbw WHERE curtp = curtp_rem AND bwber = p_bwber2.
      ADD t_bsbw-bwshb TO belege-dmbtr.
    ENDLOOP.

  ENDIF.

  IF belege-shkzg = 'H'.
    belege-dmbtr = 0 - belege-dmbtr.
    belege-wrbtr = 0 - belege-wrbtr.
    belege-bdiff = 0 - belege-bdiff.
    belege-rdiff = 0 - belege-rdiff.
  ELSE.

  ENDIF.
* set old and new value equal
  belege-bwdiff = belege-bdiff.
* --------------------------------------------------------------------
  CHECK belege-hwtyp NE space.

* normally revaluaton works from
* wrbtr / dmbtr or
* dmbtr+diff / dmbtr2 or dmbtr3
* from curr / to currency
* for translation


  EXTRACT daten.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM belege2                                                  *
*---------------------------------------------------------------------*
* allow revaluation to original value if a previos val.dif in the
* document. the difference is set to zero.
* Bewertung des Hauswaehrungsbetrags 2
FORM belege2 USING parw.
  DATA: fc_balance(12) TYPE p.
  DATA: fwb_flag.
  DATA: gnb_flag(1).                   "for GR/IR accts
  DATA: f_currency LIKE bkpf-waers,
        lc_amount  LIKE belege-dmbtr,
        fc_amount  LIKE belege-wrbtr,
        fc_gbetr   LIKE belege-gbetr,    "gesicherter Betrag
        t_curs     LIKE  x001-basw2.
  PERFORM umgebung USING parw.
  IF parw = '2'.
    t_curs = bk_methode-curs2.
  ELSEIF  parw = '3'.
    t_curs = bk_methode-curs3.
  ENDIF.
************************* neuer loop ueber belege
  SORT belege BY zbukr
                 waers
                 bezugsnr
                   koart
                   konto
                 belnr.
* belege = space.
  LOOP AT belege.
    AT NEW waers.
*       Bestimmung des Geld-, Brief-, oder Mittelkurses
      IF t044a-xsalk = 'X'.            "Saldo aus Konto
        SUM.
        fc_balance = belege-wrbtr.
      ENDIF.
    ENDAT.

    AT NEW bezugsnr.
      SUM.
      gnb_flag = space.
      IF  belege-dmbtr < 0 OR belege-dmbe2 < 0 OR belege-dmbe3 < 0.
        gnb_flag = '1'.
      ENDIF.
      IF t044a-xsalr = 'X'.
*       Bestimmung des Geld-, Brief-, oder Mittelkurses
        fc_balance = belege-wrbtr.
      ENDIF.
    ENDAT.

    IF grir_flag NE space AND pa_were <> space. "if is a gr/ir account
      IF gnb_flag <> '1' AND NOT s_gracc[] IS INITIAL.
        IF belege-hkont IN s_gracc.
          gnb_flag = '1'.
        ENDIF.
      ENDIF.
      IF gnb_flag NE '1'.

*     delete entry, because it is not valued
*     and no longer needed
        DELETE belege WHERE bezugsnr = belege-bezugsnr.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF belege-wflag = '1'.
*     get currency rate type
      IF fc_balance >= 0.
        tcurr-kurst = t044a-kurss.
      ELSE.
        tcurr-kurst = t044a-kursh.
      ENDIF.

      lc_amount = belege-dmbtr.
*     cursr = '1'.   "original T-Waers.
      f_currency = belege-waers.
      fc_amount = belege-wrbtr.
*     if foreign currency then revaluate
      IF haus-waers       NE f_currency.
*       parallel currencies cannot use gbetr
        IF parw NE '1'.
          fc_gbetr  = 0.
        ELSE.
          fc_gbetr = belege-gbetr.
        ENDIF.
        PERFORM fc_revaluation
             USING fc_amount f_currency
                   haus-waers  lc_amount
                   fc_gbetr
             CHANGING belege-bwdiff
                      belege-kursr.
      ELSE.
*       use local currency as foreign currency
        belege-bwdiff = fc_amount - lc_amount.
      ENDIF.
    ELSE.
      belege-bwdiff = 0.
    ENDIF.
    belege-rdiffn = belege-rdiff.
    IF NOT belege-augbl IS INITIAL AND p_bwber = space
                       AND grir_flag = space.
      belege-rdiffn = belege-rdiff - ( belege-bwdiff - belege-bdiff ).
    ENDIF.

    MODIFY belege TRANSPORTING bwdiff
                               rdiffn
                               kursr.
  ENDLOOP.

* check the revaluation method

  LOOP AT belege.

    AT NEW waers.
*     Balance revaluation
      IF t044a-xsalb NE space.
        SUM.
        PERFORM fc_fwb_flag USING belege-bwdiff belege-bdiff
                         CHANGING fwb_flag.
      ENDIF.
    ENDAT.

    AT NEW bezugsnr.
      SUM.
*     revaluation by document (and references)
      IF t044a-xsalb = space.
        PERFORM fc_fwb_flag USING belege-bwdiff belege-bdiff
                         CHANGING fwb_flag.
      ENDIF.
    ENDAT.


*   set new difference according to the method
    IF  fwb_flag  = '0'.
      belege-bwdiff = belege-bdiff.    "use old difference
      CLEAR belege-kursr.
* allow revaluation to original value if a previos val.dif in the
* document. the difference is set to zero.
      IF t044a-xnwpr <> space AND belege-bdiff NE 0.
        belege-bwdiff = 0.
        CLEAR belege-kursr.
      ENDIF.
      MODIFY belege TRANSPORTING bwdiff
                                 kursr.
    ENDIF.

    IF p_remon NE space AND belege-bwdiff <> 0
      AND bk_methode-hwaer_rem NE space.
* remeasure new difference
      lc_amount = 0. fc_gbetr = 0.
      fc_amount = belege-bwdiff.
      tcurr-kurst = p_remsct.
      PERFORM fc_revaluation
           USING fc_amount  haus-waers
                 bk_methode-hwaer_rem lc_amount
                 fc_gbetr
           CHANGING belege-bdiff_rem
                    belege-kursr.

      MODIFY belege TRANSPORTING bdiff_rem.
    ENDIF.

*   write data into file
    IF filename NE space AND belege-belnr NE space.
      PERFORM file_append.
    ENDIF.


  ENDLOOP.
ENDFORM.
* check according to valuation principle the new difference
FORM fc_fwb_flag USING neu LIKE belege-bwdiff
                    alt LIKE belege-bdiff
              CHANGING o_flag.
  o_flag = '0'.
  IF t044a-xaufw = 'X'.                "Always
    o_flag = '1'.
*         Posten muss abgewertet sein
  ELSEIF t044a-xnwpr = 'X'.            "niederstwerprinzip
    IF neu < 0.
      o_flag = '1'.
    ENDIF.
*         Posten muss staerker abgewertet sein als letzte Bewertung
  ELSEIF t044a-xsnwp <> space.         "strenges NW-Prinzip
    IF neu LE alt.
      o_flag = '1'.
    ENDIF.
  ELSEIF t044a-xnabw <> space.         "only Profi
    IF neu  > 0.
      o_flag = '1'.
    ENDIF.
  ELSEIF t044a-xreset <> space. " Always revaluate when parameter reset
    o_flag = '1'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  build_bk_methode
*&---------------------------------------------------------------------*
*       determine currency types and valuation methods for company code
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_bk_methode USING bukrs   LIKE t001-bukrs.
  READ TABLE bk_methode WITH KEY bukrs BINARY SEARCH.
  IF sy-subrc NE 0.
    CLEAR x001.
*   Bestimmen der Waehrungstypen in einem Buchungskreis.
    CALL FUNCTION 'FI_CURRENCY_INFORMATION'
      EXPORTING
        i_bukrs = bukrs
      IMPORTING
        e_x001  = x001
      EXCEPTIONS
        OTHERS  = 0.

*   Ist ueberhaupt Bewertungskreis 1 vorhanden ?
    SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
    CLEAR bk_methode.
    bk_methode-hwae1 = t001-waers.
    bk_methode-hwae2 = x001-hwae2.
    bk_methode-hwae3 = x001-hwae3.
    bk_methode-curt1 = '10'.
    bk_methode-curt2 = x001-curt2.
    bk_methode-curt3 = x001-curt3.
    bk_methode-curs2 = x001-basw2.
    bk_methode-curs3 = x001-basw3.
*   bewertung 1 (fuer dmshb)
    bk_methode-meth1 = space.
    IF p_curtp1 = '10'.
      bk_methode-meth1 =  bwmet1.
* bewertung in DMBE2
    ELSEIF p_curtp1 = x001-curt2.
      bk_methode-meth2 =  bwmet1.
*   dritte waehrung
    ELSEIF p_curtp1 = x001-curt3.
      bk_methode-meth3 = bwmet1.
    ENDIF.
    CLEAR bk_methode-typ_rem.
    CLEAR bk_methode-hwaer_rem.
    IF p_remon <> space.
      CASE curtp_rem.
        WHEN bk_methode-curt2.
          bk_methode-typ_rem = '2'.
          bk_methode-hwaer_rem = bk_methode-hwae2.
        WHEN bk_methode-curt3.
          bk_methode-typ_rem  = '3'.
          bk_methode-hwaer_rem = bk_methode-hwae3.
        WHEN bk_methode-curt1.  "10
          bk_methode-typ_rem  = '1'.
          bk_methode-hwaer_rem = bk_methode-hwae1.
      ENDCASE.
    ENDIF.                             "remon
    bk_methode-bukrs = bukrs.
    APPEND bk_methode.
    SORT bk_methode BY bukrs.
  ENDIF.
  IF NOT p_transl IS INITIAL.
    bk_methode-curs2 = '2'.    "use local currency
    bk_methode-curs3 = '2'.    "use local currency
  ENDIF.
*     Wenn Bewertungsmethode nicht space ist,
*     WIRD BEWERTUNGSKREIS BEARBEITET.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM READ_T004A                                               *
*&--------------------------------------------------------------------*
*       read valuation method                                         *
*---------------------------------------------------------------------*
FORM read_t044a USING bwmet LIKE t044a-bwmet.
  STATICS: obwmet LIKE t044a-bwmet.
  IF obwmet <> bwmet.
    SELECT SINGLE * FROM t044a WHERE bwmet = bwmet.
    IF sy-subrc NE 0.
      MESSAGE s363.
      STOP.
    ENDIF.
    obwmet = bwmet.
    SELECT SINGLE * FROM t044b WHERE bwmet = bwmet
                              AND spras   = sy-langu.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM UMGEBUNG                                                 *
*&---------------------------------------------------------------------*
*        determine valuation method, local currency and currency type  *
*----------------------------------------------------------------------*
FORM umgebung USING hwtype LIKE haus-field.
*     aus dem Waehrungstyp laesst sich die Bewertungsmethode
*     rueckschliessen
  IF hwtype = '1'.
    t044a-bwmet = bk_methode-meth1.
    haus-curtp  = bk_methode-curt1.
    haus-waers = bk_methode-hwae1.   haus-field = '1'.
  ENDIF.
  IF hwtype = '2'.
    t044a-bwmet = bk_methode-meth2.
    haus-curtp  = bk_methode-curt2.
    haus-waers = bk_methode-hwae2.   haus-field = '2'.
  ENDIF.
  IF hwtype = '3'.
    t044a-bwmet = bk_methode-meth3.
    haus-curtp  = bk_methode-curt3.
    haus-waers = bk_methode-hwae3.   haus-field = '3'.
  ENDIF.
  PERFORM read_t044a USING t044a-bwmet.
* Hauswaehrung festlegen
  t001-waers = haus-waers.  "t001-waers wird in Batch headin wieder gel.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM AUSGLEICH_SPERREN_S                                      *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  X                                                             *
*---------------------------------------------------------------------*
FORM ausgleich_sperren_s USING asp_koart asp_konto asp_bukrs
                         CHANGING  return LIKE sy-subrc.
  STATICS:
    enq_koart LIKE bseg-koart,
    enq_konto LIKE bseg-lifnr,
    enq_bukrs LIKE bkpf-bukrs.
  DATA: char(12).
  CHECK asp_koart NE enq_koart
     OR asp_konto NE enq_konto
     OR asp_bukrs NE enq_bukrs.
  CASE asp_koart.
    WHEN 'D'.
      CALL FUNCTION 'ENQUEUE_EFKNB1AS'
        EXPORTING
          kunnr          = asp_konto
          bukrs          = asp_bukrs
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
    WHEN 'K'.
      CALL FUNCTION 'ENQUEUE_EFLFB1AS'
        EXPORTING
          lifnr          = asp_konto
          bukrs          = asp_bukrs
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
    WHEN 'S'.
      CALL FUNCTION 'ENQUEUE_EFSKB1AS'
        EXPORTING
          saknr          = asp_konto
          bukrs          = asp_bukrs
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
  ENDCASE.
  return = sy-subrc.

  CASE sy-subrc.
    WHEN 1.
      char(12) = sy-msgv1.
*     MESSAGE s287(f5) WITH ASP_KONTO ASP_BUKRS CHAR(12).
      MESSAGE e287(f5) WITH  asp_konto
                             asp_bukrs
                             char
                             INTO g_dummy.

      PERFORM log_almsg USING '06'.
    WHEN 2.
*     MESSAGE s288.
      MESSAGE e288(f5).
      PERFORM log_almsg USING '06'.
  ENDCASE.
  enq_koart = asp_koart.
  enq_konto = asp_konto.
  enq_bukrs = asp_bukrs.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM AUSGLEICH_ENTSPERREN_S                                   *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ASP_KOART                                                     *
*  -->  ASP_KONTO                                                     *
*  -->  ASP_BUKRS                                                     *
*---------------------------------------------------------------------*
FORM ausgleich_entsperren_s USING asp_koart asp_konto asp_bukrs.
  STATICS:
    enq_koart LIKE bseg-koart,
    enq_konto LIKE bseg-lifnr,
    enq_bukrs LIKE bkpf-bukrs.

  CHECK asp_koart NE enq_koart
     OR asp_konto NE enq_konto
     OR asp_bukrs NE enq_bukrs.
  CASE asp_koart.
    WHEN 'D'.
      CALL FUNCTION 'DEQUEUE_EFKNB1AS'
        EXPORTING
          kunnr = asp_konto
          bukrs = asp_bukrs.
    WHEN 'K'.
      CALL FUNCTION 'DEQUEUE_EFLFB1AS'
        EXPORTING
          lifnr = asp_konto
          bukrs = asp_bukrs.
    WHEN 'S'.
      CALL FUNCTION 'DEQUEUE_EFSKB1AS'
        EXPORTING
          saknr = asp_konto
          bukrs = asp_bukrs.
  ENDCASE.

  enq_koart = asp_koart.
  enq_konto = asp_konto.
  enq_bukrs = asp_bukrs.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM enqueue                                                  *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  x                                                             *
*---------------------------------------------------------------------*
FORM enqueue USING x.
  DATA: user LIKE sy-msgv1.
  CHECK post_upd NE space.             "nur bei Postenupdate
  IF x = 'ON'.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
               ID 'BUKRS' FIELD t001-bukrs
               ID 'ACTVT' FIELD '01'.
      IF NOT sy-subrc EQ 0.
        CONCATENATE text-s15 t001-bukrs INTO user SEPARATED BY space.
        MESSAGE e812 WITH text-003 user.
        STOP.
      ENDIF.
    ENDSELECT.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      CALL FUNCTION 'ENQUEUE_EFT001EX'
        EXPORTING
          mandt          = sy-mandt
          bukrs          = t001-bukrs
          _scope         = '1'
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 2.
      IF sy-subrc NE 0.
        user = sy-msgv1.
        MESSAGE e369 WITH t001-bukrs user. "sy-msgv1.
        STOP.
      ENDIF.
    ENDSELECT.
  ELSE.
    SELECT * FROM t001 WHERE bukrs IN bukrs.
      CALL FUNCTION 'DEQUEUE_EFT001EX'
        EXPORTING
          mandt = sy-mandt
          bukrs = t001-bukrs.
*     enq_bukrs = t001-bukrs.
    ENDSELECT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM CHECK_BWMETXX                                            *
*&---------------------------------------------------------------------*
*        checks bei at selection screen........                        *
*----------------------------------------------------------------------*
FORM check_bwmetxx USING xx LIKE t044a-bwmet.
  IF xx NE space.
* sind die Batch-input daten vollstaendig
    IF t044a-blart = space AND par_bi NE space.
      MESSAGE e363.
    ENDIF.
    IF
       t044a-xfile = 'X' AND filename = space.
      MESSAGE e377.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM GET_CURTP                                                *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ICURTP                                                        *
*---------------------------------------------------------------------*
FORM check_curtp USING icurtp.
  TABLES: dcobjdef.
  dcobjdef-name = 'CURTP'.
  CHECK icurtp NE space.

  DESCRIBE TABLE tdd07v LINES sy-tfill.
  IF sy-tfill = 0.
    CALL FUNCTION 'DDUT_DOMVALUES_GET'
      EXPORTING
        name      = dcobjdef-name
        langu     = sy-langu
*       TEXTS_ONLY    = ' '
      TABLES
        dd07v_tab = tdd07v
      EXCEPTIONS
        OTHERS    = 0.
  ENDIF.

*
  LOOP AT tdd07v WHERE domvalue_l = icurtp.
  ENDLOOP.
  IF sy-subrc NE 0.
    MESSAGE e002(00).
  ENDIF.
  IF icurtp = '00'.
    MESSAGE e264(fc) WITH icurtp.
  ENDIF.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM check_before_start                                       *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_before_start.
  IF bwmet1 = space.
    MESSAGE e055(00).
  ENDIF.

  PERFORM check_bwmetxx USING bwmet1.
  IF p_zbukrs NE space.
    PERFORM check_zbukrs.
  ENDIF.
  IF filename NE space.
***    Start of UC Check changes 20.06.2016
*    OPEN DATASET filename FOR OUTPUT.
    OPEN DATASET filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
****    End of Uc chech changes 20.06.2016
    IF sy-subrc NE 0.
      MESSAGE e474 WITH filename.
    ENDIF.
  ELSE.
    IF t044a-xfile <> space.
      tabbl-dynnr   = 1060.
      tabbl-activetab = '1060'.
      MESSAGE e377.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM DERIVE_HAUSWAERS                                         *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_BUKRS                                                       *
*  -->  I_CURT                                                        *
*---------------------------------------------------------------------*
FORM derive_hauswaers USING    i_bukrs
                               i_curt
                      CHANGING ihaus STRUCTURE haus.
  SELECT SINGLE * FROM t001 WHERE bukrs = i_bukrs.
  IF i_curt = '10'.
    ihaus-waers = t001-waers. ihaus-field = '1'.
  ELSE.
    CLEAR x001.
*     Bestimmen der Waehrungstypen in einem Buchungskreis.
    CALL FUNCTION 'FI_CURRENCY_INFORMATION'
      EXPORTING
        i_bukrs = i_bukrs
      IMPORTING
        e_x001  = x001
      EXCEPTIONS
        OTHERS  = 0.

    IF x001-curt2 = i_curt.
      ihaus-waers = x001-hwae2. ihaus-field = '2'.
    ELSEIF x001-curt3 = i_curt.
      ihaus-waers = x001-hwae3. ihaus-field = '3'.
    ELSE.
      ihaus-waers = space.   ihaus-field = space.
    ENDIF.
  ENDIF.

ENDFORM.                               " DERIVE_HAUSWAERS
*&--------------------------------------------------------------------*
*&      FORM  bsbw_translation_op                                     *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM bsbw_translation_op.
  CHECK belege-belnr NE space.
  REFRESH t_bsbw.
  SELECT * FROM bsbw INTO TABLE t_bsbw
                           WHERE bukrs = belege-bukrs
                           AND    belnr = belege-belnr
                           AND    gjahr = belege-gjahr
                           AND    buzei = belege-buzei
                           AND    methd = methode.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM BSBW_GET                                                 *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM bsbw_get.
  belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
* RDIFF darf nicht verwendet werden
  bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.

  EXIT. "do not use old values because postings are reversed

  SELECT SINGLE * FROM bsbw
                            WHERE bukrs = belege-bukrs
                           AND    belnr = belege-belnr
                           AND    gjahr = belege-gjahr
                           AND    buzei = belege-buzei
                           AND    curtp = p_curtp1
                           AND    bwber = p_bwber
                           AND    methd = methode.
  CHECK sy-subrc = 0.

* old value
  belege-bdiff = belege-bdif2  = belege-bdif3  = bsbw-bwshb.

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM BSBW_WRITE                                               *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM bsbw_update USING icurtp LIKE t001a-curtp
                       ibwber LIKE t033-bwber
                       iact TYPE string.
  LOOP AT belege_upd.
    MOVE-CORRESPONDING belege_upd TO t_bsbw_new.
    IF iact <> 'REM'.
      t_bsbw_new-bwshb = belege_upd-bdiff.
    ELSE.
      t_bsbw_new-bwshb = belege_upd-bdiff_rem.
    ENDIF.
    t_bsbw_new-datum = sy-datum.
    t_bsbw_new-curtp = icurtp.
    t_bsbw_new-bwber = ibwber.
    t_bsbw_new-methd = methode.
    APPEND t_bsbw_new.
    cnt_belg = cnt_belg + 1.
  ENDLOOP.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM bsbw_update_db                                           *
*&--------------------------------------------------------------------*
FORM bsbw_update_db.
  DELETE bsbw  FROM TABLE t_bsbw_new.  "delete old
  INSERT bsbw  FROM TABLE t_bsbw_new ACCEPTING DUPLICATE KEYS.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form f100_bel_rfdt
*&---------------------------------------------------------------------*
*       store data
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f100_bel_rfdt TABLES if100_bel STRUCTURE f100_bel.

  DATA: BEGIN OF f100_tab OCCURS 10.
          INCLUDE STRUCTURE bkpf_key.
  DATA: END OF f100_tab.

  DATA: BEGIN OF bkpf_key.
          INCLUDE STRUCTURE bkpf_key.
  DATA: END OF bkpf_key.

  LOOP AT if100_bel.
    AT NEW augdt.
      REFRESH f100_tab.
      CLEAR bkpf_key.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      SELECT * FROM bkpf WHERE bukrs = if100_bel-bukrs
                         AND   belnr = if100_bel-augbl ORDER BY PRIMARY KEY.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
*        SELECT augbl FROM bseg INTO bseg-augbl
*             WHERE bukrs = bkpf-bukrs
*             AND   gjahr = bkpf-gjahr
*             AND   belnr = bkpf-belnr
*             AND   augdt = if100_bel-augdt
*             AND   augbl = bkpf-belnr ORDER BY PRIMARY KEY.
        SELECT ClearingJournalEntry AS augbl
          FROM i_operationalacctgdocitem
          WHERE CompanyCode          = @bkpf-bukrs
            AND FiscalYear           = @bkpf-gjahr
            AND AccountingDocument   = @bkpf-belnr
            AND ClearingDate         = @if100_bel-augdt
            AND ClearingJournalEntry = @bkpf-belnr
          ORDER BY CompanyCode, AccountingDocument, FiscalYear, AccountingDocumentItem
          INTO @bseg-augbl.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          EXIT.
        ENDSELECT.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING bkpf TO bkpf_key.
          EXIT. "#EC CI_NOORDER
        ENDIF.
      ENDSELECT.

      IF sy-subrc = 0.
*   get old values
        PERFORM f100_bel_get TABLES f100_tab
                             USING  bkpf_key 'I'.
      ELSE.
        MESSAGE i600(fr) WITH text-007
                              if100_bel-bukrs
                              if100_bel-augbl
                         INTO g_dummy.
        PERFORM log_almsg USING '50'.
*       WRITE: / 'Ausgleichsbeleg nicht gefunden'(007),IF100_BEL-BUKRS,
*                                     IF100_BEL-AUGBL.
        MOVE-CORRESPONDING if100_bel TO bkpf_key.
      ENDIF.
    ENDAT.
*   get new document
*    SELECT SINGLE * FROM bkpf WHERE bukrs = if100_bel-bukrs
*                              AND   budat = if100_bel-budat
*                              AND   belnr = if100_bel-belnr.
    SELECT * FROM bkpf UP TO 1 ROWS WHERE bukrs = if100_bel-bukrs
                              AND   budat = if100_bel-budat
                              AND   belnr = if100_bel-belnr ORDER BY PRIMARY KEY. ENDSELECT.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING bkpf TO f100_tab.
      COLLECT f100_tab.
    ELSE.
      MESSAGE i600(fr) WITH text-011
                            if100_bel-bukrs
                            if100_bel-belnr
                       INTO g_dummy.
      PERFORM log_almsg USING '50'.
*     WRITE: / 'Rücknahme Beleg für Ausgleich fehlt'(011),
*                                   IF100_BEL-BUKRS,
*                                   IF100_BEL-belnr.
    ENDIF.

    AT END OF augdt.
*   export values
      PERFORM f100_bel_get TABLES f100_tab
                           USING  bkpf_key 'E'.

    ENDAT.
  ENDLOOP.
  REFRESH if100_bel.

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM F100_BEL_GET                                             *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBKPF_TAB                                                     *
*  -->  IKEY                                                          *
*  -->  MODE                                                          *
*---------------------------------------------------------------------*
FORM f100_bel_get TABLES ibkpf_tab STRUCTURE bkpf_key
                  USING ikey LIKE bkpf_key
                        mode TYPE c.
  DATA: BEGIN OF bkpf_tab OCCURS 10.
          INCLUDE STRUCTURE bkpf_key.
  DATA: END OF bkpf_tab.

  DATA:    BEGIN OF f100id,            "maybe only 22 char
             progr(4) TYPE c VALUE 'F100', " Programmname
             bukrs    LIKE bkpf-bukrs,
             belnr    LIKE bkpf-belnr,
             gjahr    LIKE bkpf-gjahr,
           END OF f100id.

  MOVE-CORRESPONDING ikey TO f100id.
* f100id-mandt = sy-mandt.
  IF mode = 'E'.
    bkpf_tab[] = ibkpf_tab[].
    EXPORT bkpf_tab TO DATABASE rfdt(f2)  CLIENT sy-mandt
                      ID f100id.
  ELSEIF mode = 'I'.
    IMPORT bkpf_tab FROM DATABASE rfdt(f2) CLIENT sy-mandt
                               ID f100id.
    IF sy-subrc <> 0.
      f100id-gjahr = f100id-gjahr - 1.  "test again with prior year
      IMPORT bkpf_tab FROM DATABASE rfdt(f2) ID f100id.
    ENDIF.
    LOOP AT bkpf_tab WHERE gjahr <> ikey-gjahr.
      DELETE bkpf_tab.      "delete wrong entries
    ENDLOOP.
    ibkpf_tab[] = bkpf_tab[].
  ENDIF.

ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM  account_determination                                   *
*&--------------------------------------------------------------------*
*       holt Konten fuer die FW-Buchungen                             *
*---------------------------------------------------------------------*
FORM account_determination USING iccode LIKE t001-bukrs
                       icurrency LIKE bkpf-waers
                       iaccount LIKE t030h-hkont
                       ibwber LIKE t030hb-bwber
                       icurtp LIKE t030h-curtp
                       ixno_op TYPE c.

  DATA: l_use_t030h.
  l_use_t030h = 'X'.
  IF ixno_op = 'X' AND no_t030h = 'X'.
    l_use_t030h = space.
  ENDIF.

  CALL FUNCTION 'FI_ACCT_DET_UXD'
    EXPORTING
      i_ccode          = iccode
      i_account        = iaccount
      i_currency       = icurrency
      i_reval_area     = ibwber
      i_curtp          = icurtp
      i_use_t030h      = l_use_t030h
    IMPORTING
      e_corr_account   = t030h-lkorr
      e_profit_account = t030h-lhbew
      e_loss_account   = t030h-lsbew
    EXCEPTIONS
      no_account_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    IF ibwber NE space.
      CALL FUNCTION 'FI_ACCT_DET_UXD'
        EXPORTING
          i_ccode          = iccode
          i_account        = iaccount
          i_currency       = icurrency
*         i_reval_area     = ibwber   "<<<now without
          i_curtp          = icurtp
          i_use_t030h      = l_use_t030h
        IMPORTING
          e_corr_account   = t030h-lkorr
          e_profit_account = t030h-lhbew
          e_loss_account   = t030h-lsbew
        EXCEPTIONS
          no_account_found = 1
          OTHERS           = 2.
    ENDIF.
  ENDIF.
  IF sy-subrc <> 0.
    ok = 0.
    MESSAGE e257(fr) WITH iccode
                          ibwber
                          iaccount
                     INTO g_dummy.
    PERFORM log_almsg USING '13'.
    CLEAR t030h.
    ok = 0.
    IF t030h-lkorr IS INITIAL. WRITE text-133 TO t030h-lkorr. ENDIF.
    IF t030h-lsbew IS INITIAL. WRITE text-134 TO t030h-lsbew. ENDIF.
    IF t030h-lhbew IS INITIAL. WRITE text-135 TO t030h-lhbew. ENDIF.


  ELSE.
    ok = 1.
    PERFORM: check_account USING iaccount CHANGING t030h-lkorr ok,
             check_account USING iaccount CHANGING t030h-lsbew ok,
             check_account USING iaccount CHANGING t030h-lhbew ok.
  ENDIF.

ENDFORM.
FORM account_determination_rxd USING iccode LIKE t001-bukrs
                       icurrency LIKE bkpf-waers
                       iaccount LIKE t030h-hkont
*not possible          ibwber like t030hb-bwber
                       icurtp LIKE t030h-curtp.

  CALL FUNCTION 'FI_ACCT_DET_UXD'
    EXPORTING
      i_ccode          = iccode
      i_account        = iaccount
      i_currency       = icurrency
*     i_reval_area     = ibwber
      i_curtp          = icurtp
    IMPORTING
      e_corr_account   = t030h-lkorr
      e_profit_account = t030h-lhbew
      e_loss_account   = t030h-lsbew
      e_rxd_profit_acc = t030h-lhrea
      e_rxd_loss_acc   = t030h-lsrea
    EXCEPTIONS
      no_account_found = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    ok = 0.
    MESSAGE e257(fr) WITH iccode
                          space
                          iaccount
                     INTO g_dummy.
    PERFORM log_almsg USING '13'.
    CLEAR t030h.
    ok = 0.
  ELSE.
    ok = 1.
    PERFORM: check_account USING iaccount CHANGING t030h-lkorr ok,
             check_account USING iaccount CHANGING t030h-lsbew ok,
             check_account USING iaccount CHANGING t030h-lhbew ok.
    IF post_upd <> space.
      PERFORM: check_account USING iaccount CHANGING t030h-lhrea ok,
               check_account USING iaccount CHANGING t030h-lsrea ok.
    ENDIF.
  ENDIF.

ENDFORM.

*&--------------------------------------------------------------------*
*&      FORM CHECK_ACCOUNT                                            *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IKONTO                                                        *
*---------------------------------------------------------------------*
FORM  check_account USING ihkont LIKE t030h-lkorr
                    CHANGING ikonto LIKE t030h-lkorr
                             iok    LIKE ok.
  STATICS: BEGIN OF exists OCCURS 10,
             bukrs LIKE skb1-bukrs,
             saknr LIKE skb1-saknr,
           END OF exists.

  READ TABLE exists WITH KEY bukrs = t001-bukrs
                         saknr = ikonto BINARY SEARCH.
  IF sy-subrc NE 0.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    SELECT SINGLE * FROM skb1  WHERE bukrs = t001-bukrs
                            AND   saknr = ikonto.  "#EC CI_DB_OPERATION_OK[2431747]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    IF sy-subrc =  0.
      exists-bukrs = skb1-bukrs.
      exists-saknr = skb1-saknr.
      COLLECT exists.
    ELSE.
      IF ikonto NE space.
        MESSAGE e884 WITH ikonto
                              t001-bukrs
                              ihkont
                         INTO g_dummy.
      ELSE.
        fimsg-msgv1 = ''' '''.
        MESSAGE e885 WITH fimsg-msgv1
                              t001-bukrs
                              ihkont
                         INTO g_dummy.
      ENDIF.
      PERFORM log_almsg USING '13'.
      iok = 0.
    ENDIF.
  ENDIF.
*
  IF iok = 0 AND ikonto = space. ikonto = text-130. ENDIF.
* message e106(f5).
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM FILE_CLOSE                                               *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM file_close.
* write name of seq. file
  CHECK filename NE space.
  CLOSE DATASET filename.
*
  MESSAGE i600(fr) WITH text-300
                        space
                        space
                   INTO g_dummy.
  PERFORM log_almsg USING '10'.
*
  MESSAGE i600(fr) WITH text-301
                        filename
                        space
                   INTO g_dummy.
  PERFORM log_almsg USING '11'.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM FC_REVALUATION                                                 *
*&---------------------------------------------------------------------*
*  Umrechnung Fremd- in Hauswaehrung: Stichtags-Bewertung
*---------------------------------------------------------------------*
*       Daten einer Belegposition                                     *
*  -->  Source Amount (eg dmshb)
*  -->  teilgesicherter Amount (eg gbtr)
*  -->  target currency
*  <--  Bwdiff    Bewertungsdifferenz in Hauswaehrung                 *
*---------------------------------------------------------------------*
FORM fc_revaluation USING
                     s_amount LIKE belege-wrbtr
                     s_waers  LIKE haus-waers
                     t_waers  TYPE bkpf-waers
                     t_amount LIKE belege-dmbtr
                     s_gbetr  TYPE bseg-gbetr

                     CHANGING ibwdiff LIKE belege-bwdiff
                              s_kursr LIKE belege-kursr.
  DATA: diff(12) TYPE p.

  DATA:
    l_gebtr  LIKE bseg-gbetr,
    uwrshb   LIKE belege-wrbtr,      "amount not hedged
    l_reval1 LIKE belege-dmbtr,     "reval. hedged amount
    l_reval2 LIKE l_reval1.
  l_gebtr = s_gbetr.
  uwrshb = s_amount.                   "wrshb
  l_reval1  = 0.
  l_reval2  = t_amount.                "dmshb
* revaluate the hedged amount
  IF t044a-xsich = 'X' AND s_gbetr NE 0.
    IF s_amount LT 0.
      l_gebtr = - l_gebtr.
      IF s_amount GT l_gebtr.
        l_gebtr = s_amount.
      ENDIF.
    ELSE.
      IF s_amount LT l_gebtr.
        l_gebtr = s_amount.
      ENDIF.
    ENDIF.
    uwrshb  = s_amount -  l_gebtr
                                 .
    bseg-kursr = s_kursr.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        foreign_amount   = l_gebtr
        foreign_currency = s_waers
        local_currency   = t_waers
        type_of_rate     = tcurr-kurst
        date             = stichtag
        rate             = bseg-kursr  "gesicherter k.
      IMPORTING
        local_amount     = l_reval1
      EXCEPTIONS
        error_message    = 1
        OTHERS           = 6.
*   move error messages to log
    IF sy-subrc NE 0.
      PERFORM log_almsg USING '08'.
    ENDIF.
  ENDIF.
* revaluate the amount not hegded (rest of it)
  IF uwrshb NE 0.
    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        foreign_amount   = uwrshb
        foreign_currency = s_waers
        local_currency   = t_waers
        type_of_rate     = tcurr-kurst
        date             = stichtag
      IMPORTING
        local_amount     = l_reval2
        exchange_rate    = s_kursr  "verw.Kurs
      EXCEPTIONS
        error_message    = 1
        OTHERS           = 1.
*   move error messages to log
    IF sy-subrc NE 0.
      l_reval2 = t_amount     - l_reval1.
      PERFORM log_almsg USING '08'.
    ENDIF.
  ELSE.
    l_reval2 = 0.
  ENDIF.

  l_reval2 = l_reval2 + l_reval1.
  ibwdiff = l_reval2 - t_amount.
*rounding
  diff =  abs( l_reval2 - t_amount ).
  IF diff LE t044a-mindiff.
    ibwdiff = 0.
  ENDIF.
* new difference

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM FILL_BU_WAERTAB                                          *
*&---------------------------------------------------------------------*
*        save differences for each item, also save rdiff if any
*----------------------------------------------------------------------*
FORM fill_bu_waertab.
* setup table for posting
  MOVE-CORRESPONDING belege TO bu_waertab.
  IF belege-belnr = space.
    bu_waertab-x_no_op = 'X'.
  ELSE.
    CLEAR bu_waertab-x_no_op.
  ENDIF.

  bu_waertab-hwaer_rem = bk_methode-hwaer_rem.
  bu_waertab-ta_waers = belege-ta_waers.  "original transaction waers
  bu_waertab-storno = space.
  bu_waertab-bukrs = belege-bukrs.
* czech post line for each item otherwise condense
  IF t044a-xpost = space.
    CLEAR: bu_waertab-belnr,
           bu_waertab-buzei.
  ENDIF.

* post the delta between new and old difference
  bu_waertab-dmshb = belege-bwdiff - belege-bdiff.
*   BDIFF DELTA IS Uused for aflag
*  if t044a-xsalb = space.
*    bdiff_delta = bu_waertab-dmshb.
*  endif.

  PERFORM collect_bu_waertab USING bu_waertab-dmshb
                                   bdiff_delta.
*   reverse GR/IR immediately in case of update
  IF grir_flag <> space AND post_upd <> space
    AND p_bwber =  space.                                   "H316012
    bu_waertab-storno = 'C'.
    PERFORM collect_bu_waertab USING bu_waertab-dmshb
                                     bdiff_delta.
  ENDIF.
*
* change sign for credit amounts
  IF post_upd NE space AND belege-belnr NE space.
    MOVE-CORRESPONDING belege TO belege_upd. "#EC CI_FLDEXT_OK[2610650]
*   if belege-dmbtr < 0.
    IF belege-shkzg = 'H'.
      belege_upd-bdiff = - belege-bwdiff.
      belege_upd-bdiff_rem = - belege-bdiff_rem.
    ELSE.
      belege_upd-bdiff =  belege-bwdiff.
      belege_upd-bdiff_rem =  belege-bdiff_rem.
    ENDIF.
    belege_upd-bukrs = belege-bukrs.
*correct RXD of cleared items
* Cleared items have to be reversed
    IF NOT belege-augbl IS INITIAL AND p_bwber = space
                       AND grir_flag = space.
      belege_upd-rdiff = belege-rdiffn.
*     if belege-dmbtr < 0.
      IF belege-shkzg = 'H'.
        belege_upd-rdiff = 0 - belege_upd-rdiff.
      ENDIF.
*     IF BELEGE-BDIFF NE BELEGE-BWDIFF.
      MOVE-CORRESPONDING bu_waertab TO bu_waertab_clear.
*
      bu_waertab_clear-shkzg = belege-shkzg.
      bu_waertab_clear-storno = 'R'.
      bu_waertab_clear-dmshb = belege-rdiff.
      PERFORM collect_bu_waertab_clear USING bu_waertab_clear-dmshb
                                       bu_waertab_clear-dmshb.
*     post the corrected realised difference
      bu_waertab_clear-dmshb = belege-bwdiff - belege-bdiff  "neu - alt
                          - belege-rdiff.
      bu_waertab_clear-storno = 'N'.
      PERFORM collect_bu_waertab_clear USING bu_waertab_clear-dmshb
                                       bu_waertab_clear-dmshb.
*     ENDIF.
    ENDIF.                             "cleared items
*   store values for update
    APPEND belege_upd.

  ENDIF.

ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM COLLECT_BU_WAERTAB                                       *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  WERT                                                          *
*---------------------------------------------------------------------*
FORM collect_bu_waertab USING wert LIKE belege-rdiff
                              ibal.
  CHECK wert <> 0.
  IF ibal > 0.                         "Profit
    bu_waertab-aflag  = space.
  ELSE.                                "Loss
    bu_waertab-aflag  = 'X'.
  ENDIF.
  bu_waertab-hwaer = haus-waers.
  bu_waertab-curtp = haus-curtp.

  COLLECT bu_waertab.

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM COLLECT_BU_WAERTAB_CLEAR                                 *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  WERT                                                          *
*  -->  IBAL                                                          *
*---------------------------------------------------------------------*
FORM collect_bu_waertab_clear USING wert LIKE belege-rdiff
                              ibal.
  IF wert NE 0.
    IF ibal > 0.                       "Profit
      bu_waertab_clear-aflag  = space.
    ELSEIF ibal         < 0.           "Loss
      bu_waertab_clear-aflag  = 'X'.
    ENDIF.
    bu_waertab_clear-hwaer = haus-waers.
    IF co_pa_flag = 'X' AND belege-koart NE 'S'.
      bu_waertab_clear-augdt = belege-augdt.
      bu_waertab_clear-augbl = belege-augbl.
    ELSE.
      bu_waertab_clear-augbl = space.
*      clear bu_waertab_clear-augdt.
      CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
        EXPORTING
          day_in            = belege-augdt
        IMPORTING
          last_day_of_month = bu_waertab_clear-augdt
        EXCEPTIONS
          OTHERS            = 4.
      IF sy-subrc <> 0.
        bu_waertab_clear-augdt = belege-augdt.
      ENDIF.
    ENDIF.
    COLLECT bu_waertab_clear.
  ENDIF.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM Bseg_update                                              *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM bseg_update.
  DATA: table(10).
  LOOP AT belege_upd.
* read bseg for indices
    SELECT SINGLE FOR UPDATE * FROM bseg WHERE bukrs = belege_upd-bukrs
                              AND   belnr = belege_upd-belnr
                              AND   gjahr = belege_upd-gjahr
                              AND   buzei = belege_upd-buzei.
    CHECK sy-subrc = 0.
    IF belege_upd-augbl NE bseg-augbl.
*     Fehler beim Belegupdate &1 &2 &3 &4
      MESSAGE e479(fr) WITH belege_upd-bukrs
                            belege_upd-gjahr
                            belege_upd-belnr
                            'BSEG'
                       INTO g_dummy.
      PERFORM log_almsg USING '23'.
      sy-subrc = 4.
      CHECK 1 = 0.
    ENDIF.

* ---one of this values has changed --------------------------
    CASE belege_upd-hwtyp.
      WHEN '1'.
        bseg-bdiff = belege_upd-bdiff.
      WHEN '2'.
        bseg-bdif2 = belege_upd-bdiff.
      WHEN '3'.
        bseg-bdif3 = belege_upd-bdiff.
    ENDCASE.
*
    IF NOT belege_upd-augbl IS INITIAL.
      CASE belege_upd-hwtyp.
        WHEN '1'.
          bseg-rdiff = belege_upd-rdiff.
        WHEN '2'.
          bseg-rdif2 = belege_upd-rdiff.
        WHEN '3'.
          bseg-rdif3 = belege_upd-rdiff.
      ENDCASE.
*     set reason for not allowed for reversal
      bseg-xragl = '1'.
*     begin note 409364
      CALL FUNCTION 'BREAKDOWN_RELATION_FI_DOC_SUB'
        EXPORTING
          i_bukrs = belege_upd-bukrs
          i_belnr = belege_upd-belnr
          i_gjahr = belege_upd-gjahr
          i_koart = bseg-koart.
*     end note 409364
    ENDIF.

* ---------------------------------------------------------------
    UPDATE bseg

            SET bdiff = bseg-bdiff
                bdif2 = bseg-bdif2
                bdif3 = bseg-bdif3
                rdiff = bseg-rdiff
                rdif2 = bseg-rdif2
                rdif3 = bseg-rdif3
                xragl = bseg-xragl

                WHERE bukrs = bseg-bukrs
                              AND   belnr = bseg-belnr
                              AND   gjahr = bseg-gjahr
                              AND   buzei = bseg-buzei.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
*     Fehler beim Belegupdate &1 &2 &3 &4
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      MESSAGE e479(fr) WITH  belege_upd-bukrs
                             belege_upd-gjahr  "#EC CI_FLDEXT_OK[2610650]
                             belege_upd-belnr
                             'BSEG'
                       INTO g_dummy.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
      PERFORM log_almsg USING '23'.
      CHECK 1 = 0.
    ELSE.
*...write entry in table BWFI_AEDAT...................................*
      IF sy-subrc = 0.
        CALL FUNCTION 'OPEN_FI_PERFORM_00005011_P'
          EXPORTING
            i_chgtype   = 'U'
            i_origin    = 'SAPF100 UPDATE'
            i_tabname   = 'BSEG'
             i_structure = bseg "#EC CI_FLDEXT_OK[2610650]
          EXCEPTIONS
            error       = 1
            OTHERS      = 2.
      ENDIF.
    ENDIF.

*------- Übernahmestatus im Belegkopf fortschreiben --------------------
    LOOP AT ums40 WHERE bukrs = belege_upd-bukrs.
      UPDATE bkpf SET duefl = 'A' WHERE belnr = belege_upd-belnr
                                  AND   bukrs = belege_upd-bukrs
                                  AND   gjahr = belege_upd-gjahr
                                  AND   duefl = 'X'.
      EXIT.
    ENDLOOP.

    CASE bseg-koart.
      WHEN 'D'.
        IF bseg-augdt = '00000000'.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026

*          UPDATE bsid
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs    AND    kunnr = bseg-kunnr
*             AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
*             AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
*             AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*             AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
          table = 'BSID'.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert note 200576
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'SAPF100 UPDATE'
                i_tabname     = 'BSID'
                i_where_bukrs = bseg-bukrs
                i_where_kunnr = bseg-kunnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert note 200576
        ELSE.
          "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*          UPDATE bsad
*            SET bdiff = bseg-bdiff
*                bdif2 = bseg-bdif2
*                bdif3 = bseg-bdif3
*                xragl = bseg-xragl
*            WHERE bukrs = bseg-bukrs    AND    kunnr = bseg-kunnr
*            AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
*            AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
*            AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*            AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
          "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
          table = 'BSAD'.

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'SAPF100 UPDATE'
                i_tabname     = 'BSAD'
                i_where_bukrs = bseg-bukrs
                i_where_kunnr = bseg-kunnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
        ENDIF.
      WHEN 'K'.
        IF bseg-augdt = '00000000'.
 "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*          UPDATE bsik
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs    AND    lifnr = bseg-lifnr
*             AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
*             AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
*             AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*             AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
          table = 'BSIK'.

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'SAPF100 UPDATE'
                i_tabname     = 'BSIK'
                i_where_bukrs = bseg-bukrs
                i_where_lifnr = bseg-lifnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
        ELSE.
 "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*          UPDATE bsak
*            SET bdiff = bseg-bdiff
*                bdif2 = bseg-bdif2
*                bdif3 = bseg-bdif3
*                xragl = bseg-xragl
*            WHERE bukrs = bseg-bukrs    AND    lifnr = bseg-lifnr
*            AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
*            AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
*            AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*            AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
          "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
          table = 'BSAK'.

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
          IF sy-subrc EQ 0.
            CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'SAPF100 UPDATE'
                i_tabname     = 'BSAK'
                i_where_bukrs = bseg-bukrs
                i_where_lifnr = bseg-lifnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                OTHERS        = 1.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
        ENDIF.
    ENDCASE.
* Sachkonto oder Mitbuchkonto
    IF bseg-koart = 'S'
      OR bseg-xhres NE space.
      IF bseg-koart <> 'S'.
        bseg-zuonr = bseg-hzuon.
      ENDIF.
      IF bseg-augdt = '00000000'.
 "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*        UPDATE bsis
*           SET bdiff = bseg-bdiff
*               bdif2 = bseg-bdif2
*               bdif3 = bseg-bdif3
*           WHERE bukrs = bseg-bukrs    AND    hkont = bseg-hkont
*           AND   zuonr = bseg-zuonr    AND    augdt = bseg-augdt
*           AND   augbl = bseg-augbl
*           AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*           AND   buzei = bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        table = 'BSIS'.
      ELSE.
"Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
*        UPDATE bsas
*          SET bdiff = bseg-bdiff
*              bdif2 = bseg-bdif2
*              bdif3 = bseg-bdif3
*              xragl = bseg-xragl
*          WHERE bukrs = bseg-bukrs    AND    hkont = bseg-hkont
*                                      AND    augdt = bseg-augdt
*          AND   zuonr = bseg-zuonr
*          AND   augbl = bseg-augbl
*          AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
*          AND   buzei = bseg-buzei.
"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
        table = 'BSAS'.
      ENDIF.
    ENDIF.


    IF sy-subrc NE 0.
*     Fehler beim Belegupdate &1 &2 &3 &4
      MESSAGE e479(fr) WITH belege_upd-bukrs
                            belege_upd-gjahr
                            belege_upd-belnr
                            table
                       INTO g_dummy.
      PERFORM log_almsg USING '23'.
* try again
 "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
      CASE table.
        WHEN 'BSID'.
*          UPDATE bsid
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND kunnr = bseg-kunnr   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
        WHEN 'BSAD'.
*          UPDATE bsad
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND kunnr = bseg-kunnr   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.

        WHEN 'BSIK'.
*          UPDATE bsik
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND lifnr = bseg-lifnr   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.

        WHEN 'BSAK'.
*          UPDATE bsak
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND lifnr = bseg-lifnr   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.

        WHEN 'BSIS'.
*          UPDATE bsis
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND hkont = bseg-hkont   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.

        WHEN 'BSAS'.
*          UPDATE bsas
*             SET bdiff = bseg-bdiff
*                 bdif2 = bseg-bdif2
*                 bdif3 = bseg-bdif3
*             WHERE bukrs = bseg-bukrs
*             AND hkont = bseg-hkont   AND gjahr = bseg-gjahr
*             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
      ENDCASE.
*"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
      CHECK 1 = 0.
    ENDIF.
    cnt_belg = cnt_belg + 1.
  ENDLOOP.

ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM SET_T042X                                                *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* - notify payment program, that the valuation program was run for
*   these accounts and company codes
* - the payment program will then read again the latest val differences
*   from the database
* - tell SAPF110 to reread date when it was a update run for BDIFF
*---------------------------------------------------------------------*
FORM set_t042x.
  TABLES: t042x.
* only necessary when update in bdiff
  CHECK p_bwber IS INITIAL.

  t042x-laufd = sy-datum.
  t042x-laufi = 'F100XX'.
  t042x-datum = sy-datum.
  t042x-uzeit = sy-uzeit.
  t001 = space.

*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT * FROM t001 WHERE bukrs IN bukrs ORDER BY PRIMARY KEY.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    t042x-bukrs = t001-bukrs.
    IF  x_ar  <> space.
      t042x-koart = 'D'.
      MODIFY t042x.
    ENDIF.
    IF  x_ap  <> space.
      t042x-koart = 'K'.
      MODIFY t042x.
    ENDIF.
  ENDSELECT.
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM T030SKV_SET                                              *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
********** SKV Konten duerfen nicht bewerten werden ****************
FORM t030skv_set.
  REFRESH t030skv.
  TABLES: t030.
  IF  p_bwber IS INITIAL AND NOT post_upd EQ space.
    SELECT * FROM t030 WHERE  ktosl = 'SKV' AND ktopl = t001-ktopl ORDER BY PRIMARY KEY.
      t030skv-hkont = t030-konts .
      COLLECT t030skv.
      t030skv-hkont = t030-konth.
      COLLECT t030skv.
    ENDSELECT.
  ENDIF.
  SORT t030skv.
ENDFORM.
*&--------------------------------------------------------------------*
*&      FORM gr_ir_get_order.                                         *
*&--------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Read the Order because the Goods received part may be               *
* in local currency only, when the customer uses the old mm           *
* transaction.                                                        *
*---------------------------------------------------------------------*
FORM gr_ir_get_order.
  STATICS: x_ekbe LIKE ekbe   OCCURS 0 WITH HEADER LINE.
  DATA   : x_ekbes LIKE ekbes   OCCURS 0 WITH HEADER LINE.
  DATA   : x_ekbez LIKE ekbez   OCCURS 0 WITH HEADER LINE.
  STATICS: x_ekbz LIKE ekbz    OCCURS 0 WITH HEADER LINE.
  DATA   : x_ekbnk LIKE ekbnk   OCCURS 0 WITH HEADER LINE.
  STATICS: l_ebeln LIKE ekko-ebeln.
  STATICS: l_ebelp LIKE ekpo-ebelp.




  IF l_ebeln NE bseg-ebeln.
    SELECT SINGLE * FROM ekko WHERE ebeln = bseg-ebeln.
    l_ebeln = ekko-ebeln. l_ebelp = space.
  ELSE.
    sy-subrc = 0.
  ENDIF.
  CHECK sy-subrc = 0.

  CHECK belege-waers NE ekko-waers.

  bkpf-awkey = space.

* special case ekko-waers = parallel currency
  IF x001-bukrs NE belege-bukrs.
    CALL FUNCTION 'FI_CURRENCY_INFORMATION'
      EXPORTING
        i_bukrs = belege-bukrs
      IMPORTING
        e_x001  = x001
      EXCEPTIONS
        OTHERS  = 0.

  ENDIF.

* use parallel amount if ekko-waers equals parallel waers 06051998

  IF belege-dmbe2 NE 0 AND ekko-waers = x001-hwae2.
    belege-waers = ekko-waers. belege-waers = ekko-waers.
    belege-wrbtr = belege-dmbe2.
  ELSEIF belege-dmbe3 NE 0 AND ekko-waers = x001-hwae3.
    belege-waers = ekko-waers. belege-waers = ekko-waers.
    belege-wrbtr = belege-dmbe3.
  ENDIF.
  CHECK belege-waers NE ekko-waers.
*
  bseg-kursr = ekko-wkurs.
  IF l_ebeln <> bseg-ebeln OR l_ebelp <> bseg-ebelp.
    REFRESH: x_ekbe, x_ekbz.
    l_ebelp = bseg-ebelp.
    CALL FUNCTION 'ME_READ_HISTORY'
      EXPORTING
        ebeln  = bseg-ebeln
        ebelp  = bseg-ebelp
        webre  = 'E'
      TABLES
        xekbe  = x_ekbe
        xekbes = x_ekbes
        xekbez = x_ekbez
        xekbnk = x_ekbnk
        xekbz  = x_ekbz
      EXCEPTIONS
        OTHERS = 4.
  ELSE.
    sy-subrc = 0.
  ENDIF.
  IF sy-subrc = 0.
    CLEAR: x_ekbe.                     "06051998     bseg-wrbtr.
    LOOP AT x_ekbe WHERE waers = ekko-waers.
      IF x_ekbe-dmbtr = belege-dmbtr AND x_ekbe-wrbtr NE 0.
        belege-wrbtr = x_ekbe-wrbtr.
        belege-waers = ekko-waers.
*           check awkey
        IF bkpf-awkey = space.
          SELECT SINGLE awkey FROM bkpf INTO bkpf-awkey
                       WHERE bukrs = belege-bukrs
                       AND   belnr = belege-belnr
                       AND   gjahr = belege-gjahr.
          IF sy-subrc = 0 AND bkpf-awkey CS x_ekbe-belnr.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
*      oder in Bezugsnebenkosten
    CHECK belege-waers NE ekko-waers.
    LOOP AT x_ekbz WHERE waers = ekko-waers.
      IF x_ekbz-dmbtr = belege-dmbtr AND x_ekbz-wrbtr NE 0.
        belege-wrbtr = x_ekbz-wrbtr.
        belege-waers = ekko-waers.
        bkpf-waers = ekko-waers.
        EXIT.
      ENDIF.
    ENDLOOP.

*      calculate from local currency into Ekko-  currency
*      because the value was not found in the EKBE
    CHECK belege-waers NE ekko-waers.
    LOOP AT x_ekbe.
      IF x_ekbe-arewr = belege-dmbtr.
        IF t003-blart NE belege-blart.
          SELECT SINGLE * FROM t003 WHERE blart = belege-blart.
          IF t003-kurst = space. t003-kurst = 'M'. ENDIF.
        ENDIF.
*           calculate foreign currency.
        bseg-dmbtr = belege-dmbtr.
        CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
          EXPORTING
            local_amount     = bseg-dmbtr
            foreign_currency = ekko-waers
            local_currency   = t001-waers
            type_of_rate     = t003-kurst
            rate             = ekko-wkurs
            date             = belege-budat
          IMPORTING
            foreign_amount   = bseg-wrbtr
          EXCEPTIONS
            error_message    = 1
            OTHERS           = 1.
        IF sy-subrc = 0.
          belege-waers = ekko-waers.
          bkpf-waers = ekko-waers.
          belege-wrbtr = bseg-wrbtr.

        ELSE.
*             perform log_almsg using '12'.
        ENDIF.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM GR_IR_BUILD_TAB                                          *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM gr_ir_build_tab.
  CHECK: NOT x_gl IS INITIAL.          "only used when OI and GL
  SELECT * FROM t030 WHERE ktosl = 'WRX' ORDER BY PRIMARY KEY.
    t_grir-ktopl = t030-ktopl.
    t_grir-hkont = t030-konts.
    COLLECT t_grir.
  ENDSELECT.
  SORT t_grir.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM GR_IR_CHECK                                              *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SKB1-XOPVW                                                    *
*---------------------------------------------------------------------*
FORM gr_ir_check CHANGING eopvw TYPE c
                          e_flag TYPE c.
* GR_ir in selopt in table WRX
  IF skb1-saknr IN s_gracc AND NOT s_gracc[] IS INITIAL.
    sy-subrc = 0.
  ELSE.
    READ TABLE t_grir WITH KEY ktopl = t001-ktopl
                                 hkont = skb1-saknr
                                 BINARY SEARCH.
  ENDIF.
  IF sy-subrc NE 0.
* es ist kein we/er konto
    e_flag = space.
  ELSE.
    e_flag = 'X'.
    IF pa_were = space AND pa_weref = space.
      eopvw = space.                   "do not use this account
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM SELECT_BSID                                              *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ITAB                                                          *
*---------------------------------------------------------------------*
FORM select_bsid USING itab.
  DATA: knx_sel.
  RANGES: st_augdt FOR bseg-augdt OCCURS 1.
  IF itab = 'BSID'.
  ELSE.
    st_augdt-low = stichtag.
    st_augdt-sign = 'I'.
    st_augdt-option = 'GT'.
    APPEND st_augdt.
  ENDIF.

  SELECT * FROM (itab) INTO bsid "#EC CI_FLDEXT_OK[2610650]
                     WHERE bukrs = t001-bukrs
                     AND   kunnr IN dkonto
                     AND   waers IN waehrung
                     AND   bstat = space
                     AND   augdt IN st_augdt
                     AND   budat LE stichtag
                     AND   hkont IN akonto
                     AND   belnr IN belnr
                     AND  (bsid_clauses-where_tab) ORDER BY PRIMARY KEY.

* is it foreign currency
    check_currency bsid-waers.

    IF bsid-umskz NE space.
* Pruefen, ob Wechsel zu bewerten ist
      IF bsid-umsks = 'W'.
*       CHECK: BSID-WVERW = SPACE.      "nicht extrahieren
        IF bsid-wverw NE space.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          SELECT SINGLE wverd FROM bsed INTO bsed-wverd
                                        WHERE bukrs = bsid-bukrs
                                        AND   belnr = bsid-belnr
                                        AND   gjahr = bsid-gjahr  "#EC CI_FLDEXT_OK[2610650]
                                        AND   buzei = bsid-buzei.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
          IF p_transl EQ space.
            CHECK bsed-wverd GT stichtag.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF t044a-ar_grup NE space AND bsid-kunnr NE kna1-kunnr.
      PERFORM get_dkonzs_ar CHANGING dk_konzs.
      kna1-kunnr = bsid-kunnr.
    ENDIF.

    MOVE-CORRESPONDING bsid TO belege. "#EC CI_FLDEXT_OK[2610650]
    belege-konto = bsid-kunnr.
    belege-koart = 'D'.

    bseg-rebzg = bsid-rebzg.
    bseg-rebzj = bsid-rebzj.
    bseg-rebzz = bsid-rebzz.
    bseg-xcpdd = bsid-xcpdd.

    IF bsid-xcpdd = 'X'.
      SELECT SINGLE * FROM kna1 WHERE kunnr = belege-konto.
      bseg-xcpdd = kna1-xcpdk.
    ENDIF.

    IF knb1-kunnr NE bsid-kunnr
       OR knb1-bukrs NE bsid-bukrs.
*    setup info from master data
      SELECT SINGLE *  FROM knb1 INTO knb1
                       WHERE  kunnr = bsid-kunnr
                       AND    bukrs = bsid-bukrs.
      akonts = knb1-akont.

* free selections
      knx_sel = space.
      IF kna1_clauses_filled = 'X'.
        SELECT SINGLE kunnr  FROM kna1 INTO kna1-kunnr
                             WHERE  kunnr = knb1-kunnr
                             AND   (kna1_clauses-where_tab).
        IF sy-subrc <> 0. knx_sel = 'X'. ENDIF.
      ENDIF.
      CHECK knx_sel = space.

      IF knb1_clauses_filled = 'X'.
        SELECT SINGLE kunnr  FROM knb1 INTO knb1-kunnr
                             WHERE  kunnr = knb1-kunnr
                             AND    bukrs = bsid-bukrs
                             AND   (knb1_clauses-where_tab).
        IF sy-subrc <> 0. knx_sel = 'X'. ENDIF.
      ENDIF.
    ENDIF.
    CHECK knx_sel = space.

    PERFORM extract.

  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM get_dkonzs_AR                                            *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  e_group                                                       *
*---------------------------------------------------------------------*
FORM get_dkonzs_ar CHANGING e_group LIKE dk_konzs.
  SELECT SINGLE konzs FROM kna1 INTO  e_group
                                WHERE kunnr = bsid-kunnr.
  IF e_group = space.
    e_group = bsid-kunnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM SELECT_BSIK                                              *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ITAB                                                          *
*---------------------------------------------------------------------*
FORM select_bsik USING itab.
  DATA: lfx_sel.
  RANGES: st_augdt FOR bseg-augdt OCCURS 1.
  IF itab = 'BSIK'.
  ELSE.
    st_augdt-low = stichtag.
    st_augdt-sign = 'I'.
    st_augdt-option = 'GT'.
    APPEND st_augdt.
  ENDIF.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  SELECT * FROM (itab) INTO  bsik  "#EC CI_FLDEXT_OK[2610650]
                     WHERE bukrs =  t001-bukrs
                     AND   lifnr IN kkonto
                     AND   waers IN waehrung
                     AND   bstat = space
                     AND   augdt IN st_augdt  "#EC CI_FLDEXT_OK[2610650]
                     AND   budat LE stichtag
                     AND   hkont IN akonto
                     AND   belnr IN belnr
                     AND  (bsik_clauses-where_tab) ORDER BY PRIMARY KEY.
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

* is it foreign currency
    check_currency bsik-waers.

    IF t044a-ap_grup NE space.
      PERFORM get_dkonzs_ap CHANGING dk_konzs.
      lfa1-lifnr = bsik-lifnr.
    ENDIF.

    MOVE-CORRESPONDING bsik TO belege. "#EC CI_FLDEXT_OK[2610650]
    belege-konto = bsik-lifnr.
    belege-koart = 'K'.

    bseg-rebzg = bsik-rebzg.
    bseg-rebzj = bsik-rebzj.
    bseg-rebzz = bsik-rebzz.
    bseg-xcpdd = bsik-xcpdd.

    IF bsik-xcpdd = 'X'.
      SELECT SINGLE * FROM lfa1 WHERE lifnr = belege-konto.
      bseg-xcpdd = lfa1-xcpdk.
    ENDIF.

    IF     lfb1-lifnr NE bsik-lifnr
        OR lfb1-bukrs NE bsik-bukrs.
*    setup info from master data
      SELECT SINGLE *  FROM    lfb1 INTO lfb1
                       WHERE   lifnr = bsik-lifnr
                       AND     bukrs = bsik-bukrs.
      akonts = lfb1-akont.

* free selections
      lfx_sel = space.
      IF lfa1_clauses_filled = 'X'.
        SELECT SINGLE lifnr  FROM lfa1 INTO lfa1-lifnr
                             WHERE  lifnr = lfb1-lifnr
                             AND   (lfa1_clauses-where_tab).
        IF sy-subrc <> 0. lfx_sel = 'X'. ENDIF.
      ENDIF.
      CHECK lfx_sel = space.

      IF lfb1_clauses_filled = 'X'.
        SELECT SINGLE lifnr  FROM lfb1 INTO lfb1-lifnr
                             WHERE  lifnr = lfb1-lifnr
                             AND    bukrs = bsik-bukrs
                             AND   (lfb1_clauses-where_tab).
        IF sy-subrc <> 0. lfx_sel = 'X'. ENDIF.
      ENDIF.
    ENDIF.
    CHECK lfx_sel = space.

    PERFORM extract.

  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_dkonzs_AP
*&---------------------------------------------------------------------*
*       .........
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_dkonzs_ap CHANGING e_group LIKE dk_konzs.
  SELECT SINGLE konzs FROM lfa1 INTO e_group
                                WHERE lifnr = bsik-lifnr.
  IF e_group = space.
    e_group = bsik-lifnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM SELECT_BSIS                                              *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ITAB                                                          *
*---------------------------------------------------------------------*
FORM select_bsis USING itab.
  RANGES: st_augdt FOR bseg-augdt OCCURS 1.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
  RANGES: l_curr_sel FOR bkpf-waers.  "#EC CI_FLDEXT_OK[2610650]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---

* GR/IR accounts have GR in local currency
  IF grir_flag = space.
    l_curr_sel[] = curr_sel[].
  ENDIF.

  IF itab = 'BSIS'.
  ELSE.
    st_augdt-low = stichtag.
    st_augdt-sign = 'I'.
*--- BEGIN OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    st_augdt-option = 'GT'.  "#EC CI_FLDEXT_OK[2610650]
*--- END OF CHANGE BY SAP_ABAP 08.08.2026 FOR ATC ---
    APPEND st_augdt.
  ENDIF.
  SELECT * FROM (itab) "#EC CI_FLDEXT_OK[2610650]
       INTO CORRESPONDING FIELDS OF bsis
              WHERE bukrs = skb1-bukrs
              AND   budat LE stichtag
              AND   augdt IN st_augdt
              AND   hkont = skb1-saknr
              AND   waers IN waehrung
              AND   waers IN l_curr_sel
              AND   bstat = space
              AND   belnr IN belnr
              AND (bsis_clauses-where_tab).
    MOVE-CORRESPONDING bsis TO belege. "#EC CI_FLDEXT_OK[2610650]
    CLEAR belege-konto.
    belege-koart = 'S'.

    SELECT SINGLE rdiff rdif2 rdif3 gbetr kursr
                  bdiff bdif2 bdif3
                  rebzj rebzg rebzz    "sachkonten
                  ebeln ebelp          "evtl were
                    FROM bseg
                    INTO CORRESPONDING FIELDS OF bseg
                               WHERE bukrs = belege-bukrs
                               AND belnr   = belege-belnr
                               AND gjahr   = belege-gjahr
                               AND buzei   = belege-buzei.
* ist es ein werekonto
    IF grir_flag <> space AND bseg-ebeln <> space
      AND pa_were <> space.            "
      PERFORM gr_ir_get_order.
      bsis-waers = belege-waers.       "use ekko-wars.
    ELSE.
      bseg-ebeln = space.
    ENDIF.
* is it foreign currency
    check_currency bsis-waers.

    CHECK belege-waers IN waehrung.
*   setup proper value vor wrbtr in case of translation
    IF belege-wrbtr = 0.
      IF bk_methode-meth2 NE space
        AND bk_methode-curs2 = '2'.
        belege-wrbtr = belege-dmbtr + belege-bdiff.
      ELSEIF bk_methode-meth3 NE space
        AND bk_methode-curs3 = '2'.
        belege-wrbtr = belege-dmbtr + belege-bdiff.
      ENDIF.
    ENDIF.
    PERFORM extract.

  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  get_dkonzs_GL                                            *
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_dkonzs_gl CHANGING e_group LIKE dk_konzs.
  e_group = skb1-bewgp.

  IF e_group = space.
    e_group = skb1-saknr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_ZBUKRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_zbukrs.
  DATA: BEGIN OF zhaus.
          INCLUDE STRUCTURE haus.
  DATA: END OF zhaus.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_zbukrs.
  IF sy-subrc NE 0.
    MESSAGE e817 WITH p_zbukrs.
  ENDIF.
* allow only one curtp

  IF p_bwber = space.
    t033-curtp = p_curtp1.
  ENDIF.
* hauswaehrungen herausfinden
  PERFORM derive_hauswaers USING t001-bukrs t033-curtp
                           CHANGING zhaus.
  SELECT * FROM t001 WHERE bukrs IN bukrs.
    PERFORM derive_hauswaers USING t001-bukrs t033-curtp
                             CHANGING haus.
    CHECK haus-waers NE space.         "no parallel currency
* Einschränkung: Hauwaehrungen müssen identisch sein (logische Einschr.)
* Ausserdem muss die Reihenfolge der parallele Währungen uebereinstimmen
* das ist eine reine programmtechnische Einschränkung. Damit ist
* sichergestellt das immer die korrekten Betraege addiert werden,
* denn es koennte ja in bukrs 0001 in dmbe2 der typ 30 und in
* bukrs 0002 in dmbe2 der typ 20 sein, und er typ 30 dmbe3.
*
    IF zhaus-waers NE haus-waers OR zhaus-field NE haus-field.
      MESSAGE e181.
    ENDIF.
  ENDSELECT.
ENDFORM.                               " CHECK_ZBUKRS
*&---------------------------------------------------------------------*
*&      Form  FILL_CURR_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T001_BUKRS  text
*----------------------------------------------------------------------*
FORM fill_curr_sel USING    p_t001_bukrs LIKE t001-bukrs.
  REFRESH curr_sel.
  IF p_curtp1 = '10'.
    curr_sel-low    = bk_methode-hwae1.
    curr_sel-option = 'NE'.
    curr_sel-sign   = 'I'.
    APPEND curr_sel.
  ENDIF.
ENDFORM.                               " FILL_CURR_SEL
*&---------------------------------------------------------------------*
*&      Form  CHECK_INCL_FLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_incl_fld.
*  loop at incl_fld.
*    loop at fieldtab_glu1
*     where fieldname = incl_fld-low.
*      exit.
*    endloop.
*    if sy-subrc ne 0.
*      message e600 with text-002 incl_fld-low.
*    endif.
** already defined
** show the already defined fields
**   LOOP AT L_T_F INTO L_T_F_LINE.
**     IF L_T_F_LINE = INCL_FLD-LOW.
**       DELETE INCL_FLD.
**       MESSAGE I600 WITH TEXT-003 INCL_FLD-LOW.
**     ENDIF.
**   ENDLOOP.
**  endloop.
ENDFORM.                               " CHECK_INCL_FLD
*&---------------------------------------------------------------------*
*&       FORM f4_for_incl_fld                                          *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  feld                                                          *
*---------------------------------------------------------------------*
FORM f4_for_incl_fld USING feld.

* Aufruf
*  data:
*      f4ret like ddshretval occurs 1 with header line.
*
*  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
*       EXPORTING
*            retfield   = 'FIELDNAME'
*            value_org  = 'S'
*       TABLES
*            value_tab  = f4tab
*            return_tab = f4ret.

* Wert übernehmen
*  check not f4ret[] is initial.
*  read table f4ret index 1.
*  feld = f4ret-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*&       FORM schedman_start_stop                                      *
*&---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  icommand                                                      *
*---------------------------------------------------------------------*
FORM schedman_start_stop USING icommand.

  STATICS: ls_key_static LIKE schedman_key.

  DATA: gs_key      LIKE schedman_key.

  DATA: ld_worklist_flag(1).
  DATA:  ls_detail   LIKE schedman_detail_user.
  DATA:  lt_selkrit  LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE.
  DATA:  lt_param    LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE.
  DATA:  ls_witem    LIKE scma_witem.
  DATA: ls_scma_event LIKE scma_event.
  DATA: ls_ext              LIKE schedman_ext.
  DATA: ls_message LIKE schedman_message,
        ld_objects LIKE smmain-nr_of_objects,
        ld_aplstat LIKE smmain-aplstat.
* muss in scmatasks
  ls_detail-repid = 'SAPF100'.         "sy-repid.
  ls_detail-variante = sy-slset.       "<<die variante
  ls_detail-application = 'FI-GL'.
* save some select-options
  CLEAR lt_selkrit.
  lt_selkrit-structure = 'BKPF'.
  lt_selkrit-field     = 'BUKRS'.
  LOOP AT bukrs.
*   lt_selkrit-entry     =  .
    MOVE-CORRESPONDING bukrs TO lt_selkrit.
    APPEND lt_selkrit.
  ENDLOOP.
*
  lt_param-entry     = 1.
  lt_param-optio = 'EQ'.
  lt_param-structure = 'RFPDO'.
  lt_param-field     = 'SBEWSTAG'.
  lt_param-low    = stichtag.
  APPEND lt_param.
*
  lt_param-structure = 'RFPDO'.
  lt_param-field     = 'ALLGLINE'.
  lt_param-low    = title.
  APPEND lt_param.
*
  lt_param-structure = 'RFPDO1'.
  lt_param-field     = 'F100METH'.
  lt_param-low    = bwmet1.
  APPEND lt_param.


  IF icommand = 'START'.
*.fill information from Workflow-include into structure
    CLEAR ls_witem.
    ls_witem-wf_witem = wf_witem.
    ls_witem-wf_wlist = wf_wlist.
    CALL FUNCTION 'KPEP_MONI_INIT_RECORD'
      EXPORTING
        ls_detail  = ls_detail
        ls_witem   = ls_witem
*       LS_APPL    =
*       LD_WORKLIST_FLAG = ' '
      IMPORTING
        ls_key     = ls_key_static
      TABLES
        lt_selkrit = lt_selkrit
        lt_param   = lt_param.
  ELSEIF icommand = 'STOP'.
    ld_aplstat  = '0'.
    IF g_e_msg ='X'.
      ld_aplstat  = '4'.    "set status for schedman
      IF sy-batch = 'X'.
        MESSAGE s348(sy).
      ENDIF.
    ENDIF. "error occurred

*.Tell workflow to stop or to go on
    CLEAR ls_scma_event.
*  IF LD_APLSTAT = '4' OR LD_APLSTAT = 'A'.
*     LS_SCMA_EVENT-WF_EVENT = CS_WF_EVENTS-ERROR.
*  ELSE.
    ls_scma_event-wf_event = cs_wf_events-finished.
*  ENDIF.

    ls_scma_event-wf_witem = wf_witem.
    ls_scma_event-wf_okey = wf_okey.

    CALL FUNCTION 'KPEP_MONI_CLOSE_RECORD'
      EXPORTING
        ls_key        = ls_key_static
*       LS_MESSAGE    =
*       LD_OBJECTS    =
*       LS_EXT        =
*       LS_RL         =
        ls_scma_event = ls_scma_event
      TABLES
        lt_spool      = gt_spono
      CHANGING
        ld_aplstat    = ld_aplstat
      EXCEPTIONS
*       NO_ID_GIVEN   = 1
        OTHERS        = 0.


  ENDIF.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FREE_SELECTIONS
*&---------------------------------------------------------------------*
*       free selections
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM free_selections.
*? DATA BEGIN OF P_TABLES OCCURS 10.
*?          INCLUDE STRUCTURE RSDSTABS.
*?  DATA END   OF P_TABLES.
  DATA BEGIN OF tables_tab OCCURS 10.
          INCLUDE STRUCTURE rsdstabs.
  DATA END   OF tables_tab.
*Felder obiger Tabellen
  DATA: BEGIN OF fields OCCURS 10.
          INCLUDE STRUCTURE rsdsfields.
  DATA: END   OF fields.
  DATA: BEGIN OF fields_not OCCURS 10.
          INCLUDE STRUCTURE rsdsfields.
  DATA: END   OF fields_not.

  DATA:ds_expr_tab TYPE rsds_expr_tab.
  DATA:ds_expr_tab_line LIKE rsdsexpr.

  DATA: ds_texpr  TYPE rsds_expr.

  DATA: selection_id LIKE  rsdynsel-selid.
  IF x_ap <> space.
* credit
    tables_tab-prim_tab = 'LFA1'. APPEND tables_tab.
    tables_tab-prim_tab = 'LFB1'. APPEND tables_tab.
    tables_tab-prim_tab = 'BSIK'. APPEND tables_tab.
  ENDIF.
*
  IF x_ar <> space.
    tables_tab-prim_tab = 'KNA1'. APPEND tables_tab.
    tables_tab-prim_tab = 'KNB1'. APPEND tables_tab.
    tables_tab-prim_tab = 'BSID'. APPEND tables_tab.
  ENDIF.

  IF x_gl <> space OR x_salbew NE space.
    tables_tab-prim_tab = 'SKA1'. APPEND tables_tab.
    tables_tab-prim_tab = 'SKB1'. APPEND tables_tab.
  ENDIF.

  IF x_gl <> space.
    tables_tab-prim_tab = 'BSIS'. APPEND tables_tab.
  ENDIF.
  IF x_ap <> space OR x_ar <> space OR x_gl <> space.
    tables_tab-prim_tab = 'BSEG'. APPEND tables_tab.
  ENDIF.
* do not allow empty selection table
  DESCRIBE TABLE tables_tab LINES sy-tfill.
  IF sy-tfill = 0. MESSAGE e124. ENDIF.
* fill fields from previous fs_dyns in case it was in variant
  LOOP AT fs_dyns-texpr INTO ds_texpr.

    ds_expr_tab = ds_texpr-expr_tab.
    fields-tablename = ds_texpr-tablename.
    LOOP AT ds_expr_tab INTO ds_expr_tab_line
            WHERE fieldname <> space.
      fields-fieldname = ds_expr_tab_line-fieldname.
      COLLECT fields.
    ENDLOOP.
  ENDLOOP.
*** because these are already on the selection-screen nur bei 'F'
*fields_not-TABLENAME = tables_tab-PRIM_TAB.
*fields_not-FIELDNAME = 'BUKRS'. append fields_not.
*fields_not-FIELDNAME = 'WAERS'. append fields_not.
*fields_not-FIELDNAME = 'LIFNR'. append fields_not.
*fields_not-FIELDNAME = 'HKONT'. append fields_not.
*fields_not-FIELDNAME = 'KUNNR'. append fields_not.
*fields_not-FIELDNAME = 'BELNR'. append fields_not.
***
***
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'T'
*         Alte Abgrenzungen erscheinen wieder
      expressions              = fs_dyns-texpr
*     FIELD_GROUPS_KEY         =
*     RESTRICTION              =
*     ALV                      =
*     CURR_QUAN_PROG           = SY-CPROG
*     CURR_QUAN_RELATION       =
    IMPORTING
      selection_id             = selection_id
      where_clauses            = fs_dyns-clauses
      expressions              = fs_dyns-texpr
      field_ranges             = fs_dyns-trange
      number_of_active_fields  = fs_num
    TABLES
      tables_tab               = tables_tab
      fields_tab               = fields
*     FIELD_DESC               =
*     FIELD_TEXTS              =
*     EVENTS                   =
*     EVENT_FIELDS             =
      fields_not_selected      = fields_not
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK sy-subrc = 0.
  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      selection_id            = selection_id
      title                   = 'Freie Selektion '(013)
*     FRAME_TEXT              = ' '
*     STATUS                  =
*     AS_WINDOW               = ' '
*     START_ROW               = 2
*     START_COL               = 2
*     NO_INTERVALS            = ' '
*     JUST_DISPLAY            = ' '
*     PFKEY                   =
*     ALV                     = ' '
*     TREE_VISIBLE            = 'X'
*     DIAG_TEXT_1             =
*     DIAG_TEXT_2             =
*     WARNING_TITLE           =
    IMPORTING
      where_clauses           = fs_dyns-clauses
      expressions             = fs_dyns-texpr
      field_ranges            = fs_dyns-trange
      number_of_active_fields = fs_num
    TABLES
      fields_tab              = fields
*     FCODE_TAB               =
      fields_not_selected     = fields_not
    EXCEPTIONS
*     internal_error          =
*     no_action               =
*     selid_not_found         =
*     illegal_status          =
      OTHERS                  = 0.






ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FS_SET_SSCRTEXTS_DYNSEL
*&---------------------------------------------------------------------*
*       Text für Drucktaste
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fs_set_sscrtexts_dynsel CHANGING p_text " LIKE SSCRTEXTS-DYNSEL.
                                             LIKE smp_dyntxt.
  DATA l_text LIKE smp_dyntxt.

  MOVE: icon_fencing TO l_text-icon_id,
        'Free selections'(270) TO l_text-text.              "#EC *

  IF fs_num > 0.
    WRITE fs_num TO l_text-icon_text(2).
    MOVE 'active'(271) TO l_text-icon_text+3.               "#EC *
  ENDIF.
  p_text = l_text.

ENDFORM.                               " SET_SSCRTEXTS_DYNSEL
*&---------------------------------------------------------------------*
*&      Form FREE_SELECTIONS_BUILD
*&---------------------------------------------------------------------*
*       Build free selections
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM free_selections_build.
* free selections.
  CLEAR bseg_clauses.
* MOVE 'BSEG' TO DS_CLAUSES-TABLENAME.
  READ TABLE fs_dyns-clauses
             WITH KEY 'BSEG'               INTO bseg_clauses.
  IF sy-subrc = 0. bseg_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses
             WITH KEY 'BKPF'               INTO bkpf_clauses.
  IF sy-subrc = 0. bkpf_clauses_filled = 'X'. ENDIF.
*
  READ TABLE fs_dyns-clauses WITH KEY 'LFA1' INTO lfa1_clauses.
  IF sy-subrc = 0. lfa1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'LFB1' INTO lfb1_clauses.
  IF sy-subrc = 0. lfb1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'BSIK' INTO bsik_clauses.
  IF sy-subrc = 0. bsik_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'KNA1' INTO kna1_clauses.
  IF sy-subrc = 0. kna1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'KNB1' INTO knb1_clauses.
  IF sy-subrc = 0. knb1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'BSID' INTO bsid_clauses.
  IF sy-subrc = 0. bsid_clauses_filled = 'X'. ENDIF.
* Open items G/L
  READ TABLE fs_dyns-clauses WITH KEY 'SKA1' INTO ska1_clauses.
  IF sy-subrc = 0. ska1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'SKB1' INTO skb1_clauses.
  IF sy-subrc = 0. skb1_clauses_filled = 'X'. ENDIF.
  READ TABLE fs_dyns-clauses WITH KEY 'BSIS' INTO bsis_clauses.
  IF sy-subrc = 0. bsis_clauses_filled = 'X'. ENDIF.
* G/L non open items for
  READ TABLE fs_dyns-texpr WITH KEY 'SKA1' INTO sdf_expressions_line.
  APPEND sdf_expressions_line TO sdf_expressions.           "11102000
  READ TABLE fs_dyns-texpr WITH KEY 'SKB1' INTO sdf_expressions_line.
  APPEND sdf_expressions_line TO sdf_expressions.           "11102000
ENDFORM.
FORM get_co_pa_flag USING ibukrs LIKE t001-bukrs
                          xflag.
  DATA: l_rf048_a LIKE  rf048_a.
  DATA: gjahr LIKE bkpf-gjahr.
  gjahr = sy-datum(4).
  CALL FUNCTION 'BREAKDOWN_ACTIVITY_GET'
    EXPORTING
      i_bukrs           = ibukrs
      i_gjahr           = gjahr
    IMPORTING
      e_fields          = l_rf048_a
    EXCEPTIONS
      bukrs_not_defined = 1
      OTHERS            = 2.
  IF l_rf048_a-xprctr NE space.
    xflag = 'X'.
  ELSE.
    xflag = space.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  buffer_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM buffer_selection.

  DATA: wa_fcurr_val     TYPE zjv_fcurr_val,
        lt_fcurr_val     TYPE TABLE OF zjv_fcurr_val,
        l_time_stamp(15) TYPE c.

  CLEAR wa_fcurr_val.
  SELECT SINGLE * FROM zjv_fcurr_val
    INTO wa_fcurr_val
   WHERE user_name = sy-uname.

  wa_fcurr_val-vname = s_vname-low.
  wa_fcurr_val-bukrs = bukrs-low.
  wa_fcurr_val-recid = s_recid-low.
  wa_fcurr_val-egrup = s_egrup-low.
  wa_fcurr_val-crdate = sy-datum.

  IF sy-subrc = 0.

    CONCATENATE sy-datum sy-uzeit INTO l_time_stamp.
    wa_fcurr_val-time_stamp = l_time_stamp.

    UPDATE zjv_fcurr_val FROM wa_fcurr_val.

  ELSE.

    wa_fcurr_val-user_name = sy-uname.
    CONCATENATE sy-datum sy-uzeit INTO l_time_stamp.
    wa_fcurr_val-time_stamp = l_time_stamp.
    wa_fcurr_val-mandt = sy-mandt.

    APPEND wa_fcurr_val TO lt_fcurr_val.

    INSERT zjv_fcurr_val FROM TABLE lt_fcurr_val.

  ENDIF.


ENDFORM.                    " buffer_selection
*&---------------------------------------------------------------------*
*&      Form  fill_custom_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_custom_fields.

  IF s_vname IS INITIAL.

    REFRESH: s_vname.

    SELECT SINGLE vname FROM zjv_fcurr_val
       INTO s_vname-low
      WHERE user_name = sy-uname.

    IF sy-subrc EQ 0.

      APPEND: s_vname.

    ENDIF.

  ENDIF.

  IF s_recid IS INITIAL.

    REFRESH: s_recid.

    SELECT SINGLE recid FROM zjv_fcurr_val
       INTO s_recid-low
      WHERE user_name = sy-uname.

    IF sy-subrc EQ 0.

      APPEND: s_recid.

    ENDIF.

  ENDIF.

  IF s_egrup IS INITIAL.

    REFRESH: s_egrup.

    SELECT SINGLE egrup FROM zjv_fcurr_val
       INTO s_egrup-low
      WHERE user_name = sy-uname.

    IF sy-subrc EQ 0.

      APPEND: s_egrup.

    ENDIF.

  ENDIF.

ENDFORM.                    " fill_custom_fields
